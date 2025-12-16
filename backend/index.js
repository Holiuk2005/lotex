// Simple Express backend using Firebase Admin
// Endpoints:
// POST /api/auctions  (multipart form: image + title, description, startPrice, endDate, userId)
// GET  /api/auctions
// GET  /api/auctions/:id
// POST /api/profile/:uid (multipart form: optional image + name + phone)

const express = require('express');
const cors = require('cors');
const multer = require('multer');
const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');

const upload = multer({ storage: multer.memoryStorage() });
const app = express();
app.use(express.json());

// CORS origins configurable via env
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '*').split(',');
app.use(cors({
  origin: function(origin, callback){
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) return callback(null, true);
    return callback(new Error('Not allowed by CORS'));
  }
}));

// Initialize Firebase Admin
try {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined,
    });
  } else {
    // Fallback - rely on environment (e.g., Cloud Run service account)
    admin.initializeApp({
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined,
    });
  }
} catch (e) {
  console.error('Firebase admin init error:', e);
  process.exit(1);
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

// Health
app.get('/api/health', (req, res) => res.json({ ok: true, ts: Date.now() }));

// Create auction with optional image
app.post('/api/auctions', upload.single('image'), async (req, res) => {
  try {
    const { title, description, startPrice, endDate, userId } = req.body;
    if (!title || !startPrice || !endDate || !userId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const docRef = db.collection('auctions').doc();
    const auctionId = docRef.id;

    let imageUrl = '';
    if (req.file) {
      const file = bucket.file(`auctions/${auctionId}-${uuidv4()}.jpg`);
      await file.save(req.file.buffer, { metadata: { contentType: req.file.mimetype } });
      // Make publicly readable (simple approach). For production use signed URLs or auth rules.
      await file.makePublic();
      imageUrl = `https://storage.googleapis.com/${bucket.name}/${file.name}`;
    }

    const auctionData = {
      id: auctionId,
      authorId: userId,
      title,
      description: description || '',
      startPrice: Number(startPrice),
      currentPrice: Number(startPrice),
      imageUrl,
      endDate: admin.firestore.Timestamp.fromDate(new Date(endDate)),
      status: 'active',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      bids: [],
    };

    await docRef.set(auctionData);
    return res.json({ id: auctionId, ...auctionData });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: String(err) });
  }
});

// List auctions
app.get('/api/auctions', async (req, res) => {
  try {
    const snapshot = await db.collection('auctions').orderBy('createdAt', 'desc').get();
    const list = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
    res.json(list);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: String(err) });
  }
});

// Get auction
app.get('/api/auctions/:id', async (req, res) => {
  try {
    const doc = await db.collection('auctions').doc(req.params.id).get();
    if (!doc.exists) return res.status(404).json({ error: 'Not found' });
    res.json({ id: doc.id, ...doc.data() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: String(err) });
  }
});

// Update user profile (name/phone + optional avatar upload)
app.post('/api/profile/:uid', upload.single('image'), async (req, res) => {
  try {
    const uid = req.params.uid;
    const { name, phone } = req.body;

    let photoURL;
    if (req.file) {
      const file = bucket.file(`profile_images/${uid}-${uuidv4()}.jpg`);
      await file.save(req.file.buffer, { metadata: { contentType: req.file.mimetype } });
      await file.makePublic();
      photoURL = `https://storage.googleapis.com/${bucket.name}/${file.name}`;
    }

    const userDocRef = db.collection('users').doc(uid);
    const updateData = {};
    if (name) updateData.name = name;
    if (phone) updateData.phone = phone;
    if (photoURL) updateData.photoUrl = photoURL;
    if (Object.keys(updateData).length > 0) {
      updateData.updatedAt = admin.firestore.FieldValue.serverTimestamp();
      await userDocRef.set(updateData, { merge: true });
    }

    // Optionally update Firebase Auth profile
    try {
      const authUpdate = {};
      if (name) authUpdate.displayName = name;
      if (photoURL) authUpdate.photoURL = photoURL;
      if (Object.keys(authUpdate).length > 0) {
        await admin.auth().updateUser(uid, authUpdate);
      }
    } catch (e) {
      console.warn('Auth update failed (non-fatal):', e.message || e);
    }

    res.json({ ok: true, photoUrl: photoURL });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: String(err) });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Lotex backend listening on ${PORT}`));
