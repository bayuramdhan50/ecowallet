# Firebase Realtime Database Setup - Quick Guide

## ⚠️ Chat Tidak Berfungsi Tanpa Ini!

Firebase Realtime Database **WAJIB** diaktifkan agar chat berfungsi.

## Langkah Setup (5 Menit):

### 1. Buka Firebase Console
https://console.firebase.google.com

### 2. Pilih Project
- Klik project: **ecowallet-97c36**

### 3. Aktifkan Realtime Database
- Menu kiri: **Build** → **Realtime Database**
- Klik **"Create Database"**
- Pilih location: **asia-southeast1** (PENTING: sama dengan config!)
- Start in: **Test mode** ✅

### 4. Set Database Rules
Setelah database dibuat, klik tab **"Rules"**

Ganti rules dengan:
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

Klik **"Publish"**

### 5. Verifikasi
- Buka tab **"Data"**
- Harusnya muncul root database kosong
- URL database: `https://ecowallet-97c36-default-rtdb.asia-southeast1.firebasedatabase.app`

## ✅ Selesai!

Restart app dan test chat. Messages seharusnya bisa terkirim dan tersimpan.

## 🐛 Troubleshooting

**"Loading terus"**: Database belum dibuat
**"Permission denied"**: Rules belum di-set ke test mode
**"Region error"**: Location harus **asia-southeast1**
