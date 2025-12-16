# Firebase setup steps (manual)

1) Generate `firebase_options.dart` for native platforms (Android/iOS/macOS) locally using FlutterFire CLI.

```bash
# install if not installed
dart pub global activate flutterfire_cli
# run configure and follow interactive prompts
flutterfire configure --project "YOUR_FIREBASE_PROJECT_ID"
```

This will update `lib/firebase_options.dart` with platform-specific FirebaseOptions.

2) Apply CORS to your Storage bucket (needed for web uploads). Replace `YOUR_BUCKET` with your bucket name (usually PROJECT_ID.appspot.com).

```bash
# requires Google Cloud SDK (gsutil)
# authenticate first
gcloud auth login
# apply CORS
gsutil cors set cors.json gs://YOUR_BUCKET
```

3) Verify in browser:
- Run the app: `flutter run -d chrome --web-port 5000`
- Try create auction and upload an image; check Firestore `auctions` collection and Storage `auctions/` folder.

4) Notes / troubleshooting
- If you get CORS errors in browser console, confirm origins in `cors.json` match the page origin exactly (including protocol and port).
- For production, avoid `"*"` origin; list exact domains instead.
