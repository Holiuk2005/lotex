# Lotex Backend

Lightweight Express backend that stores auction data and profile information in Firestore and uploads files to Firebase Storage using Firebase Admin SDK.

Features
- POST `/api/auctions` - create auction and upload optional image (multipart form)
- GET `/api/auctions` - list auctions
- GET `/api/auctions/:id` - get auction details
- POST `/api/profile/:uid` - update profile (name/phone) and optional avatar image

Quick start (local)
1. Install dependencies:

```bash
cd backend
npm install
```

2. Service account / credentials
- Create a Firebase service account JSON in Firebase Console -> Project Settings -> Service Accounts -> Generate new private key.
- Set `GOOGLE_APPLICATION_CREDENTIALS` env var to the path of that JSON, or place the JSON on the server and export the variable.

Example (Windows PowerShell):

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\service-account.json"
$env:FIREBASE_STORAGE_BUCKET = "lotex-4890a.appspot.com"
$env:ALLOWED_ORIGINS = "http://localhost:5000"
npm start
```

3. Test endpoints
- Create auction (multipart/form-data):

```bash
curl -X POST http://localhost:8080/api/auctions \
  -F "title=Test lot" \
  -F "description=Nice item" \
  -F "startPrice=10" \
  -F "endDate=2026-01-01T00:00:00.000Z" \
  -F "userId=testuser123" \
  -F "image=@./test.jpg"
```

- Update profile (multipart):

```bash
curl -X POST http://localhost:8080/api/profile/USER_UID \
  -F "name=Ivan" \
  -F "phone=380501234567" \
  -F "image=@./avatar.jpg"
```

Deployment
- Build and push Docker image, then deploy to Cloud Run or other container platform. Ensure the runtime has access to a service account with Firestore and Storage permissions or set `GOOGLE_APPLICATION_CREDENTIALS`.

Notes
- For production, prefer signed URLs instead of `file.makePublic()`.
- Add authentication (verify Firebase ID tokens) on the server to restrict writes to authorized users.
- Adjust CORS settings in `.env`.

