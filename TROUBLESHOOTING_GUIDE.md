# Panduan Perbaikan Error Chat & Analytics

## 🔧 Error yang Diperbaiki

### 1. ✅ Firebase Database Region Error
**Error Message:**
```
Firebase Database connection was forcefully killed by the server.
Database lives in a different region.
Please change your database URL to https://ecowallet-97c36-default-rtdb.asia-southeast1.firebasedatabase.app
```

**Penyebab:** 
Firebase mencoba connect ke region default (us-central1) padahal database ada di asia-southeast1

**Solusi:**
- Database URL sudah benar di `firebase_options.dart`
- Update `chat_service.dart` untuk menggunakan database reference dengan benar

### 2. ✅ Analytics Error "Failed to fetch personal statistics"
**Error Message:**
```
Error loading statistics: Exception: Error: Exception: Failed to fetch personal statistics
```

**Penyebab:**
- Token tidak tersimpan dengan key yang benar
- Auth header tidak lengkap

**Solusi:**
1. Update `auth_service.dart` untuk save token dengan 2 keys:
   - `'auth_token'` - untuk auth umum
   - `'token'` - untuk analytics service
   - `'userId'` - untuk chat service

2. Update `analytics_service.dart`:
   - Validasi token sebelum request
   - Tambah Content-Type header
   - Enhanced error logging untuk debugging

## 📝 File yang Diupdate

### 1. `lib/services/auth_service.dart`
```dart
// Saat login, simpan dengan 3 keys berbeda
await prefs.setString('auth_token', token);
await prefs.setString('token', token); // For analytics
await prefs.setString('userId', user.id.toString()); // For chat
```

### 2. `lib/services/chat_service.dart`
```dart
// Update database reference menjadi getter
DatabaseReference get _database {
  return FirebaseDatabase.instance.ref();
}
```

### 3. `lib/services/analytics_service.dart`
```dart
// Validasi token sebelum request
if (token == null || token.isEmpty) {
  throw Exception('No authentication token found. Please login again.');
}

// Headers lengkap
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
}
```

### 4. `lib/main.dart`
```dart
// Handle Firebase duplicate initialization
} on FirebaseException catch (e) {
  if (e.code == 'duplicate-app') {
    print('Firebase already initialized, skipping...');
  }
}
```

## 🚀 Cara Testing Ulang

### **PENTING: LOGIN ULANG DULU!**

Data token dan userId hanya akan tersimpan setelah login ulang. Tanpa ini, error akan tetap muncul.

### Langkah Testing:

1. **Stop app yang sedang running**
2. **Uninstall app** atau **Clear app data**
   ```bash
   adb shell pm clear com.example.ecowallet
   ```
3. **Run app baru**
   ```bash
   flutter run
   ```
4. **LOGIN ULANG** dengan kredensial yang sama
5. **Test Chat:**
   - Client → Tap "Chat" button
   - Send message
   - ✅ Harusnya tidak ada error "User not logged in"
   - ✅ Harusnya tidak ada error region
   
6. **Test Analytics:**
   - Client → Tap "Analytics" button
   - ✅ Harusnya data muncul (jika sudah ada transaksi)
   - ✅ Error message sekarang lebih jelas jika ada masalah

## 🔍 Debug Logging

Sekarang ada debug prints untuk membantu troubleshooting:

### Chat Service:
```
Error getting database reference: <error details>
```

### Analytics Service:
```
Fetching my stats with token: eyJhbGciO...
Analytics response status: 200
Analytics response body: {...}
Analytics error details: <error>
```

Cek di **Debug Console** untuk melihat log ini.

## ⚠️ Catatan Penting

### Untuk Chat Berfungsi:
1. ✅ Firebase Realtime Database harus **enabled** di Firebase Console
2. ✅ Database **rules** harus diset (allow authenticated read/write)
3. ✅ User harus **login ulang** untuk mendapat userId

### Untuk Analytics Berfungsi:
1. ✅ Backend harus **running** (`npm run dev`)
2. ✅ User harus **login ulang** untuk mendapat token
3. ✅ User harus punya **transaksi** untuk data muncul di charts

### Firebase Database Rules (Set di Firebase Console):

```json
{
  "rules": {
    "chats": {
      ".read": true,
      ".write": true
    },
    "messages": {
      ".read": true,
      ".write": true
    }
  }
}
```

**Note:** Rules di atas untuk testing. Untuk production, gunakan rules yang lebih strict berdasarkan auth.

## 🎯 Expected Behavior Setelah Fix

### Chat:
- ✅ Connect ke Firebase tanpa error region
- ✅ Client bisa send message ke admin
- ✅ Admin bisa lihat semua chat dan reply
- ✅ Messages sync real-time

### Analytics:
- ✅ Data statistik muncul (Total Earnings, Transactions, etc.)
- ✅ Charts render dengan benar
- ✅ Error messages lebih informatif jika ada masalah
- ✅ Refresh button works

## 🐛 Jika Masih Ada Error

Cek debug console dan screenshot error message yang baru. Error messages sekarang lebih detail dan akan membantu identify masalah spesifik:

- **"No authentication token found. Please login again."** → Belum login ulang
- **"Failed to fetch <xxx> statistics"** → Backend issue atau endpoint error
- **Firebase connection errors** → Database rules atau network issue
