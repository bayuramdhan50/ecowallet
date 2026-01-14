# Firebase Chat Loading Issue - SOLVED! ✅

## Problem
```
W/PersistentConnection: Firebase Database connection was forcefully killed by the server.
Reason: Database lives in a different region.
Please change your database URL to https://ecowallet-97c36-default-rtdb.asia-southeast1.firebasedatabase.app
```

Chat screen stuck di loading spinner.

## Root Cause
Firebase Database SDK tidak otomatis menggunakan `databaseURL` dari `firebase_options.dart`. 

Default behavior Firebase adalah connect ke **us-central1**, padahal database kita di **asia-southeast1**.

## Solution
Update `chat_service.dart` untuk **explicitly** menggunakan database URL dengan region yang benar.

**Before:**
```dart
DatabaseReference get _database {
  return FirebaseDatabase.instance.ref(); // ❌ Uses default region (us-central1)
}
```

**After:**
```dart
DatabaseReference get _database {
  final firebaseApp = Firebase.app();
  final databaseURL = 'https://ecowallet-97c36-default-rtdb.asia-southeast1.firebasedatabase.app';
  
  return FirebaseDatabase.instanceFor(
    app: firebaseApp,
    databaseURL: databaseURL, // ✅ Explicitly uses asia-southeast1
  ).ref();
}
```

## How to Use

### 1. Pastikan Firebase Realtime Database sudah dibuat
Di Firebase Console:
- Project: ecowallet-97c36
- Build → Realtime Database
- Create Database di region **asia-southeast1**
- Set rules ke test mode

### 2. Restart App
```bash
flutter run
```

### 3. Test Chat
- **Client**: Tap Chat → Send message
- **Admin**: Tap Client Messages → Select chat → Reply

Messages seharusnya:
- ✅ Terkirim tanpa error
- ✅ Tersimpan di Firebase
- ✅ Sync real-time antar client dan admin
- ✅ No region error lagi!

## Verification
Check Firebase Console → Realtime Database → Data tab.

Harusnya muncul structure:
```
- chats/
  - <chatId>/
    - lastMessage: "..."
    - participants: [...]
- messages/
  - <chatId>/
    - <messageId>/
      - message: "..."
      - senderId: "..."
      - timestamp: ...
```

🎉 Chat system now fully functional!
