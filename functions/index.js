const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

const { defineSecret } = require('firebase-functions/params');

const STRIPE_SECRET_KEY = defineSecret('STRIPE_SECRET_KEY');
const NOVA_POSHTA_API_KEY = defineSecret('NOVA_POSHTA_API_KEY');

admin.initializeApp();

const NP_API_URL = 'https://api.novaposhta.ua/v2.0/json/';

function toNumber(v, fallback = 0) {
  if (typeof v === 'number' && Number.isFinite(v)) return v;
  if (typeof v === 'string') {
    const parsed = Number(String(v).trim().replace(',', '.'));
    return Number.isFinite(parsed) ? parsed : fallback;
  }
  return fallback;
}

function toMinorUnits(amount, currency = 'uah') {
  // Stripe: most currencies are 2 decimals. UAH is 2.
  const decimals = (String(currency).toLowerCase() === 'jpy') ? 0 : 2;
  const factor = Math.pow(10, decimals);
  return Math.round(toNumber(amount, 0) * factor);
}

function assertNonEmptyString(value, fieldName) {
  const v = String(value || '').trim();
  if (!v) throw new HttpsError('invalid-argument', `${fieldName} is required.`);
  return v;
}

async function npPost(apiKey, modelName, calledMethod, methodProperties) {
  const res = await fetch(NP_API_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
    body: JSON.stringify({
      apiKey,
      modelName,
      calledMethod,
      methodProperties,
    }),
  });

  const text = await res.text();
  if (!res.ok) {
    throw new HttpsError('internal', `Nova Poshta HTTP ${res.status}: ${text}`);
  }

  let json;
  try {
    json = JSON.parse(text);
  } catch (_) {
    throw new HttpsError('internal', 'Nova Poshta returned invalid JSON.');
  }

  if (!json || typeof json !== 'object') {
    throw new HttpsError('internal', 'Unexpected Nova Poshta response format.');
  }

  if (json.success === false) {
    const msg = Array.isArray(json.errors) && json.errors.length
      ? json.errors.join('\n')
      : (Array.isArray(json.warnings) && json.warnings.length ? json.warnings.join('\n') : 'Nova Poshta request failed.');
    throw new HttpsError('failed-precondition', msg);
  }

  return json;
}

function pickUserCityRef(userDoc) {
  if (!userDoc || typeof userDoc !== 'object') return '';
  // Project currently stores only basic fields. Support common variants.
  const candidates = [
    userDoc.cityRef,
    userDoc.senderCityRef,
    userDoc.npCityRef,
    userDoc.novaPoshtaCityRef,
    userDoc.deliveryCityRef,
    userDoc.settlementRef,
    userDoc.npSettlementRef,
  ];
  for (const c of candidates) {
    const v = String(c || '').trim();
    if (v) return v;
  }
  return '';
}

function pickAuctionDimensions(auctionDoc) {
  const d = (auctionDoc && typeof auctionDoc === 'object') ? auctionDoc : {};
  // Support both new top-level fields and a nested "dimensions" object.
  const dim = (d.dimensions && typeof d.dimensions === 'object') ? d.dimensions : {};
  const weightKG = toNumber(d.weightKG ?? dim.weightKG ?? dim.weight ?? d.weight, 1.0);
  const lengthCM = toNumber(d.lengthCM ?? dim.lengthCM ?? dim.length, 10.0);
  const widthCM = toNumber(d.widthCM ?? dim.widthCM ?? dim.width, 10.0);
  const heightCM = toNumber(d.heightCM ?? dim.heightCM ?? dim.height, 10.0);
  return { weightKG, lengthCM, widthCM, heightCM };
}

function userNotificationsCol(db, uid) {
  return db.collection('users').doc(uid).collection('notifications');
}

async function createNotification(db, uid, payload) {
  if (!uid) return;
  const ref = userNotificationsCol(db, uid).doc();
  await ref.set({
    type: String(payload.type || 'generic'),
    title: String(payload.title || 'Сповіщення'),
    body: String(payload.body || ''),
    auctionId: payload.auctionId || null,
    category: payload.category || null,
    actorUid: payload.actorUid || null,
    read: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

function requireAuth(request) {
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }
  return request.auth.uid;
}

function requireAdmin(request) {
  const uid = requireAuth(request);
  const isAdmin = request.auth.token && request.auth.token.admin === true;
  if (!isAdmin) {
    throw new HttpsError('permission-denied', 'Admin privileges required.');
  }
  return uid;
}

exports.purchaseTicket = onCall({ cors: true }, async (request) => {
  const uid = requireAuth(request);
  const lotteryId = String(request.data.lotteryId || '').trim();
  const quantityRaw = request.data.quantity;
  const quantity = Number.isFinite(quantityRaw) ? Number(quantityRaw) : parseInt(String(quantityRaw || '1'), 10);

  if (!lotteryId) {
    throw new HttpsError('invalid-argument', 'lotteryId is required.');
  }
  if (!Number.isInteger(quantity) || quantity < 1 || quantity > 10) {
    throw new HttpsError('invalid-argument', 'quantity must be 1..10');
  }

  const db = admin.firestore();
  const userRef = db.collection('users').doc(uid);
  const lotteryRef = db.collection('lotteries').doc(lotteryId);

  const ticketIds = [];

  await db.runTransaction(async (tx) => {
    const [userSnap, lotterySnap] = await Promise.all([tx.get(userRef), tx.get(lotteryRef)]);

    if (!lotterySnap.exists) {
      throw new HttpsError('not-found', 'Lottery not found.');
    }
    const lottery = lotterySnap.data() || {};
    if (String(lottery.status || 'active') !== 'active') {
      throw new HttpsError('failed-precondition', 'Lottery is not active.');
    }

    const endsAt = lottery.endsAt;
    if (endsAt && endsAt.toDate) {
      if (endsAt.toDate().getTime() <= Date.now()) {
        throw new HttpsError('failed-precondition', 'Lottery already ended.');
      }
    }

    const ticketPrice = Number(lottery.ticketPrice || 0);
    if (!Number.isInteger(ticketPrice) || ticketPrice <= 0) {
      throw new HttpsError('failed-precondition', 'Invalid ticketPrice.');
    }

    const maxTickets = lottery.maxTickets == null ? null : Number(lottery.maxTickets);
    const ticketsSold = Number(lottery.ticketsSold || 0);
    const newSold = ticketsSold + quantity;
    if (maxTickets != null && Number.isFinite(maxTickets) && newSold > maxTickets) {
      throw new HttpsError('failed-precondition', 'No more tickets available.');
    }

    const user = userSnap.data() || {};
    const balance = Number(user.balance || 0);
    if (!Number.isInteger(balance) || balance < 0) {
      throw new HttpsError('failed-precondition', 'Invalid user balance.');
    }

    const totalPrice = ticketPrice * quantity;
    if (balance < totalPrice) {
      throw new HttpsError('failed-precondition', 'Insufficient balance.');
    }

    // Ensure user doc exists.
    if (!userSnap.exists) {
      tx.set(userRef, {
        uid,
        balance: balance,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }

    tx.update(userRef, {
      balance: balance - totalPrice,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    tx.update(lotteryRef, {
      ticketsSold: newSold,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Create tickets with sequential numbers for O(1) winner selection.
    for (let i = 0; i < quantity; i++) {
      const number = ticketsSold + i + 1;
      const ticketRef = db.collection('tickets').doc();
      const ticketId = ticketRef.id;
      ticketIds.push(ticketId);

      const ticketData = {
        lotteryId,
        userId: uid,
        number,
        price: ticketPrice,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      tx.set(ticketRef, ticketData);
      // Mirror to user subcollection for safe querying.
      tx.set(userRef.collection('tickets').doc(ticketId), ticketData);

      // Optional ledger entry
      tx.set(userRef.collection('transactions').doc(), {
        type: 'ticket_purchase',
        lotteryId,
        ticketId,
        amount: -ticketPrice,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

  return { ticketIds };
});

// TASK-3: Secure checkout payment creation (server-side pricing).
exports.createOrderPayment = onCall(
  {
    cors: true,
    secrets: [STRIPE_SECRET_KEY, NOVA_POSHTA_API_KEY],
  },
  async (request) => {
    const buyerUid = requireAuth(request);

    const auctionId = assertNonEmptyString(request.data?.auctionId, 'auctionId');
    const deliveryCityRef = assertNonEmptyString(request.data?.deliveryCityRef, 'deliveryCityRef');
    const deliveryWarehouseRef = assertNonEmptyString(request.data?.deliveryWarehouseRef, 'deliveryWarehouseRef');

    const db = admin.firestore();

    // 1) Load auction
    const auctionRef = db.collection('auctions').doc(auctionId);
    const auctionSnap = await auctionRef.get();
    if (!auctionSnap.exists) {
      throw new HttpsError('not-found', 'Auction not found.');
    }
    const auction = auctionSnap.data() || {};

    const lotPrice = toNumber(auction.currentPrice ?? auction.price ?? auction.buyoutPrice, 0);
    if (!Number.isFinite(lotPrice) || lotPrice <= 0) {
      throw new HttpsError('failed-precondition', 'Invalid auction price.');
    }

    const sellerId = String(auction.sellerId || '').trim();
    if (!sellerId) {
      throw new HttpsError('failed-precondition', 'Auction sellerId is missing.');
    }

    // 2) Load seller profile (for sender city)
    const sellerSnap = await db.collection('users').doc(sellerId).get();
    if (!sellerSnap.exists) {
      throw new HttpsError('failed-precondition', 'Seller profile not found.');
    }
    const seller = sellerSnap.data() || {};
    const sellerCityRef = pickUserCityRef(seller);
    if (!sellerCityRef) {
      throw new HttpsError(
        'failed-precondition',
        'Seller city is not configured (missing cityRef in users/{sellerId}).'
      );
    }

    // 3) Calculate shipping via Nova Poshta (server-side)
    // Read Nova Poshta API key from Firebase Secret when running in Cloud Functions.
    // For local development you can set the environment variable
    // `NOVA_POSHTA_API_KEY` (do NOT commit it to the repo).
    let npKey = '';
    try {
      npKey = NOVA_POSHTA_API_KEY.value();
    } catch (e) {
      // If secrets are not configured in the environment (e.g., local dev),
      // fall back to process.env. This allows local testing without hardcoding
      // a key into source control. Ensure you set the env var in your shell.
      npKey = process.env.NOVA_POSHTA_API_KEY || '';
    }

    if (!npKey) {
      throw new HttpsError('failed-precondition', 'NOVA_POSHTA_API_KEY is not configured. Provide it via Firebase Secret or set process.env.NOVA_POSHTA_API_KEY for local testing.');
    }

    const { weightKG } = pickAuctionDimensions(auction);

    const npRes = await npPost(
      npKey,
      'InternetDocument',
      'getPrice',
      {
        CitySender: sellerCityRef,
        CityRecipient: deliveryCityRef,
        Weight: weightKG,
        ServiceType: 'WarehouseWarehouse',
        Cost: lotPrice,
        CargoType: 'Cargo',
        SeatsAmount: '1',
      }
    );

    const npData = Array.isArray(npRes.data) ? npRes.data : [];
    const shippingPrice = toNumber(npData?.[0]?.Cost, 0);
    if (!Number.isFinite(shippingPrice) || shippingPrice <= 0) {
      throw new HttpsError('failed-precondition', 'Failed to calculate shipping price.');
    }

    // 4) Commission
    const commissionRate = 0.05;
    const commission = Math.round(lotPrice * commissionRate * 100) / 100;

    // 5) Total
    const totalAmount = lotPrice + shippingPrice + commission;
    if (!Number.isFinite(totalAmount) || totalAmount <= 0) {
      throw new HttpsError('internal', 'Invalid total amount.');
    }

    // 6) Stripe PaymentIntent
    const stripeKey = STRIPE_SECRET_KEY.value();
    if (!stripeKey) {
      throw new HttpsError('failed-precondition', 'STRIPE_SECRET_KEY is not configured.');
    }

    const stripe = require('stripe')(stripeKey);
    const currency = 'uah';
    const amountMinor = toMinorUnits(totalAmount, currency);

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountMinor,
      currency,
      metadata: {
        auctionId,
        buyerUid,
        sellerId,
        deliveryCityRef,
        deliveryWarehouseRef,
      },
      automatic_payment_methods: { enabled: true },
    });

    // 7) Return pricing breakdown
    return {
      clientSecret: paymentIntent.client_secret,
      calculatedShippingPrice: shippingPrice,
      commission,
      totalAmount,
      currency,
    };
  }
);

exports.drawWinner = onCall({ cors: true }, async (request) => {
  requireAdmin(request);

  const lotteryId = String(request.data.lotteryId || '').trim();
  if (!lotteryId) {
    throw new HttpsError('invalid-argument', 'lotteryId is required.');
  }

  const db = admin.firestore();
  const lotteryRef = db.collection('lotteries').doc(lotteryId);

  await db.runTransaction(async (tx) => {
    const lotterySnap = await tx.get(lotteryRef);
    if (!lotterySnap.exists) {
      throw new HttpsError('not-found', 'Lottery not found.');
    }

    const lottery = lotterySnap.data() || {};
    if (String(lottery.status || 'active') !== 'active') {
      throw new HttpsError('failed-precondition', 'Lottery is not active.');
    }

    const ticketsSold = Number(lottery.ticketsSold || 0);
    if (!Number.isInteger(ticketsSold) || ticketsSold <= 0) {
      throw new HttpsError('failed-precondition', 'No tickets sold.');
    }

    // Pick a random ticket number (1..ticketsSold)
    const winningNumber = 1 + Math.floor(Math.random() * ticketsSold);

    // Find ticket by (lotteryId, number)
    const ticketsQuery = db.collection('tickets')
      .where('lotteryId', '==', lotteryId)
      .where('number', '==', winningNumber)
      .limit(1);

    const ticketsSnap = await tx.get(ticketsQuery);
    const ticketDoc = ticketsSnap.docs[0];
    if (!ticketDoc) {
      throw new HttpsError('internal', 'Winning ticket not found. Ensure indexes are deployed.');
    }

    const ticket = ticketDoc.data();
    const winnerUserId = ticket.userId;

    const ticketPrice = Number(lottery.ticketPrice || 0);
    const prize = ticketPrice * ticketsSold;

    // Mark lottery ended with winner.
    tx.update(lotteryRef, {
      status: 'ended',
      winnerUserId,
      winnerTicketId: ticketDoc.id,
      winningNumber,
      prize,
      endedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Credit winner.
    const winnerRef = db.collection('users').doc(winnerUserId);
    const winnerSnap = await tx.get(winnerRef);
    const currentBalance = Number((winnerSnap.data() || {}).balance || 0);
    tx.set(winnerRef, {
      uid: winnerUserId,
      balance: currentBalance + prize,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    tx.set(winnerRef.collection('transactions').doc(), {
      type: 'lottery_win',
      lotteryId,
      ticketId: ticketDoc.id,
      amount: prize,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { ok: true };
});

// Optional: auto-draw winners every minute for lotteries whose endsAt passed.
// This is safe but requires Cloud Scheduler to be enabled.
exports.autoDrawWinners = onSchedule('every 1 minutes', async () => {
  const db = admin.firestore();
  const now = admin.firestore.Timestamp.now();

  const snap = await db.collection('lotteries')
    .where('status', '==', 'active')
    .where('endsAt', '<=', now)
    .limit(10)
    .get();

  for (const doc of snap.docs) {
    const lotteryId = doc.id;
    try {
      // Use the same logic as drawWinner but without admin auth.
      await db.runTransaction(async (tx) => {
        const lotterySnap = await tx.get(doc.ref);
        const lottery = lotterySnap.data() || {};
        if (String(lottery.status || 'active') !== 'active') return;

        const ticketsSold = Number(lottery.ticketsSold || 0);
        if (!Number.isInteger(ticketsSold) || ticketsSold <= 0) {
          tx.update(doc.ref, {
            status: 'ended',
            endedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return;
        }

        const winningNumber = 1 + Math.floor(Math.random() * ticketsSold);
        const ticketsQuery = db.collection('tickets')
          .where('lotteryId', '==', lotteryId)
          .where('number', '==', winningNumber)
          .limit(1);

        const ticketsSnap = await tx.get(ticketsQuery);
        const ticketDoc = ticketsSnap.docs[0];
        if (!ticketDoc) return;

        const ticket = ticketDoc.data();
        const winnerUserId = ticket.userId;
        const ticketPrice = Number(lottery.ticketPrice || 0);
        const prize = ticketPrice * ticketsSold;

        tx.update(doc.ref, {
          status: 'ended',
          winnerUserId,
          winnerTicketId: ticketDoc.id,
          winningNumber,
          prize,
          endedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        const winnerRef = db.collection('users').doc(winnerUserId);
        const winnerSnap = await tx.get(winnerRef);
        const currentBalance = Number((winnerSnap.data() || {}).balance || 0);
        tx.set(winnerRef, {
          uid: winnerUserId,
          balance: currentBalance + prize,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        tx.set(winnerRef.collection('transactions').doc(), {
          type: 'lottery_win',
          lotteryId,
          ticketId: ticketDoc.id,
          amount: prize,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      console.error('autoDrawWinners error', lotteryId, e);
    }
  }

  return null;
});

// -----------------------------
// Auction in-app notifications
// -----------------------------

exports.onAuctionCreatedNotifyCategory = onDocumentCreated('auctions/{auctionId}', async (event) => {
  const db = admin.firestore();
  const data = event.data && event.data.data ? event.data.data() : null;
  if (!data) return;

  const auctionId = event.params.auctionId;
  const title = String(data.title || 'Лот');
  const category = String(data.category || '').trim();
  const sellerId = String(data.sellerId || '').trim();

  if (!category) return;

  // Notify users who subscribed to this category.
  // Users opt-in via `users/{uid}.subscribedCategories`.
  const snap = await db
    .collection('users')
    .where('subscribedCategories', 'array-contains', category)
    .limit(200)
    .get();

  if (snap.empty) return;

  const batch = db.batch();
  for (const doc of snap.docs) {
    const uid = doc.id;
    if (!uid || uid === sellerId) continue;

    const ref = userNotificationsCol(db, uid).doc();
    batch.set(ref, {
      type: 'new_auction',
      title: 'Новий лот у категорії',
      body: `${category}: ${title}`,
      auctionId,
      category,
      actorUid: sellerId || null,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  return;
});

exports.onAuctionBidCreatedNotifyOutbid = onDocumentCreated('auctions/{auctionId}/bids/{bidId}', async (event) => {
  const db = admin.firestore();
  const bid = event.data && event.data.data ? event.data.data() : null;
  if (!bid) return;

  const auctionId = event.params.auctionId;
  const bidderId = String(bid.userId || '').trim();
  const amount = Number(bid.amount || 0);
  if (!auctionId || !bidderId) return;

  const auctionRef = db.collection('auctions').doc(auctionId);
  const auctionSnap = await auctionRef.get();
  const auction = auctionSnap.data() || {};
  const title = String(auction.title || 'Лот');
  const sellerId = String(auction.sellerId || '').trim();

  // Find previous top bidder by taking 2nd item in amount-desc list.
  const bidsSnap = await auctionRef.collection('bids')
    .orderBy('amount', 'desc')
    .limit(2)
    .get();

  if (bidsSnap.docs.length >= 2) {
    const prev = bidsSnap.docs[1].data() || {};
    const prevUid = String(prev.userId || '').trim();
    if (prevUid && prevUid !== bidderId) {
      await createNotification(db, prevUid, {
        type: 'outbid',
        title: 'Вашу ставку перебили',
        body: `Лот: ${title}. Нова ставка: ${amount}`,
        auctionId,
        actorUid: bidderId,
      });
    }
  }

  // Optional: notify seller about a new bid.
  if (sellerId && sellerId !== bidderId) {
    await createNotification(db, sellerId, {
      type: 'new_bid',
      title: 'Нова ставка на ваш лот',
      body: `Лот: ${title}. Ставка: ${amount}`,
      auctionId,
      actorUid: bidderId,
    });
  }

  return;
});

exports.onAuctionSoldNotifyParticipants = onDocumentUpdated('auctions/{auctionId}', async (event) => {
  const db = admin.firestore();
  const before = event.data && event.data.before ? event.data.before.data() : null;
  const after = event.data && event.data.after ? event.data.after.data() : null;
  if (!before || !after) return;

  const auctionId = event.params.auctionId;
  const beforeStatus = String(before.status || 'active');
  const afterStatus = String(after.status || 'active');
  if (beforeStatus === afterStatus) return;

  if (afterStatus !== 'sold') return;

  const title = String(after.title || 'Лот');
  const sellerId = String(after.sellerId || '').trim();
  const winnerId = String(after.winnerId || '').trim();
  if (!sellerId || !winnerId) return;

  await Promise.all([
    createNotification(db, winnerId, {
      type: 'auction_won',
      title: 'Ви виграли лот',
      body: `Лот: ${title}. Можна звʼязатись з продавцем.`,
      auctionId,
      actorUid: sellerId,
    }),
    createNotification(db, sellerId, {
      type: 'auction_sold',
      title: 'Ваш лот купили',
      body: `Лот: ${title}. Можна звʼязатись з покупцем.`,
      auctionId,
      actorUid: winnerId,
    }),
  ]);

  return;
});
