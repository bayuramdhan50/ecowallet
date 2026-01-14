# Firebase Setup Instructions

## Prerequisites

Follow these steps to enable the real-time chat feature in EcoWallet.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: `ecowallet` (or your choice)
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android icon
2. Enter package name: `com.example.ecowallet`
3. Click "Register app"
4. Download `google-services.json`
5. Place file in `android/app/` directory

## Step 3: Configure FlutterFire

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run configuration (from project root)
flutterfire configure
```

This will:
- Detect your Firebase project
- Generate `lib/firebase_options.dart` automatically
- Configure Firebase for all platforms

## Step 4: Enable Realtime Database

1. In Firebase Console, go to **Build** → **Realtime Database**
2. Click "Create Database"
3. Choose location (select closest to your region)
4. Start in **Test mode** (for development)
5. Click "Enable"

## Step 5: Set Database Rules

In Realtime Database → Rules tab, use these rules:

```json
{
  "rules": {
    "chats": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "messages": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

Click "Publish" to save rules.

## Step 6: Test Configuration

1. Rebuild the app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. Test chat functionality:
   - Login as client
   - Open chat
   - Send message
   - Login as admin (on another device/emulator)
   - Verify message appears

## Troubleshooting

### Error: "FirebaseOptions not configured"
- Re-run `flutterfire configure`
- Ensure `google-services.json` is in `android/app/`

### Error: "Permission denied"
- Check Realtime Database rules
- Ensure rules allow authenticated access

### Messages not syncing
- Verify internet connection
- Check Firebase Console > Realtime Database > Data tab for messages
- Ensure both users are logged in

## Production Configuration

For production deployment:

1. Update database rules to be more restrictive:
   ```json
   {
     "rules": {
       "chats": {
         "$chatId": {
           ".read": "auth != null && data.child('participants').val().contains(auth.uid)",
           ".write": "auth != null"
         }
       },
       "messages": {
         "$chatId": {
           ".read": "auth != null",
           ".write": "auth != null"
         }
       }
     }
   }
   ```

2. Enable authentication in Firebase Console
3. Consider adding Firebase Authentication for better security

---

**Note**: Chat feature will be disabled if Firebase is not properly configured. The app will work normally except for chat functionality.
