const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');

admin.initializeApp();

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
