# 🌱 EcoWallet - Digital Bank Sampah

![Status](https://img.shields.io/badge/status-active-success.svg)
![Platform](https://img.shields.io/badge/platform-Flutter-blue.svg)
![Backend](https://img.shields.io/badge/backend-Node.js-green.svg)
![Database](https://img.shields.io/badge/database-MySQL-orange.svg)

Aplikasi mobile bank sampah digital dengan perhitungan bonus otomatis dan integrasi berita lingkungan. Mendukung role-based access untuk Client dan Admin dalam satu aplikasi.

---

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Teknologi](#-teknologi)
- [Instalasi](#-instalasi)
- [Konfigurasi Network](#-konfigurasi-network)
- [Kredensial Default](#-kredensial-default)
- [Cara Penggunaan](#-cara-penggunaan)
- [API Documentation](#-api-documentation)
- [SubCPMK](#-subcpmk)
- [Troubleshooting](#-troubleshooting)
- [Screenshots](#-screenshots)

---

## ✨ Fitur Utama

### 👤 Client

- **Registrasi & Login** dengan sistem approval admin
- **Dashboard Interaktif**
  - Tampilan balance real-time
  - 3 berita lingkungan terkini dari NewsAPI
  - Quick action buttons
- **Deposit Sampah**
  - Pilih jenis sampah
  - Input estimasi berat
  - Upload foto via camera
  - Preview estimasi earning dengan info bonus
- **Riwayat Transaksi**
  - Status badge (Pending/Approved/Rejected)
  - Detail berat dan earning
  - Filter berdasarkan status
- **Halaman About**
  - Informasi aplikasi
  - Credits untuk NewsAPI (SubCPMK 2)

### 👨‍💼 Admin

- **Dashboard Admin** dengan navigasi ke semua fitur
- **User Approval Center**
  - List pending users (is_active=0)
  - Approve/Reject dengan satu klik
- **Waste Type Management**
  - CRUD jenis sampah
  - Set harga per kg
  - Konfigurasi bonus threshold & amount
- **Transaction Validation**
  - List pending deposits
  - Input berat aktual
  - Tampilan detail perhitungan (SubCPMK 3):
    - Base price
    - Bonus applied (YES/NO)
    - Effective price
    - Total earning

---

## 🛠 Teknologi

### Backend
- **Node.js** + Express.js
- **MySQL** untuk database
- **JWT** untuk autentikasi
- **Bcrypt** untuk hashing password
- **Multer** untuk upload foto

### Frontend
- **Flutter** (Dart)
- **Provider** untuk state management
- **Google Fonts** (Outfit)
- **Image Picker** untuk camera
- **HTTP** untuk API calls

### External API
- **NewsAPI.org** untuk berita lingkungan

---

## 🚀 Instalasi

### Prerequisites

- Node.js (v14+)
- MySQL (v8.0+)
- Flutter (v3.0+)
- Android Studio / Xcode (untuk emulator)

### 1. Clone Repository

```bash
git clone <repository-url>
cd ecowallet
```

### 2. Setup Backend

```bash
cd backend
npm install
```

**Setup Database:**

```bash
# Login ke MySQL
mysql -u root -p

# Di MySQL prompt:
CREATE DATABASE ecowallet_db;
USE ecowallet_db;
source config/schema.sql;
exit;
```

**Jalankan Backend:**

```bash
npm start
# atau untuk development:
npm run dev
```

Backend akan berjalan di `http://localhost:3000`

### 3. Setup Flutter

```bash
cd ..
flutter pub get
flutter run
```

---

## 🌐 Konfigurasi Network

Sesuaikan `lib/config/api_config.dart` berdasarkan platform:

### Android Emulator ✅ (Default)

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

`10.0.2.2` adalah IP khusus yang mengarah ke `localhost` komputer host.

### iOS Simulator

```dart
static const String baseUrl = 'http://localhost:3000';
```

### Real Device (HP Fisik)

1. **Cari IP komputer:**

   **Windows:**
   ```bash
   ipconfig
   # Cari IPv4 Address, contoh: 192.168.1.5
   ```

   **Mac/Linux:**
   ```bash
   ifconfig
   # atau
   ip addr
   ```

2. **Update konfigurasi:**

   ```dart
   static const String baseUrl = 'http://192.168.1.5:3000';
   ```

3. **Pastikan:**
   - HP dan komputer dalam WiFi yang sama
   - Firewall tidak memblokir port 3000

---

## 🔑 Kredensial Default

### Admin Account

```
Email: admin@ecowallet.com
Password: admin123
```

### Test User

Buat via registrasi di aplikasi (perlu approval admin)

---

## 📖 Cara Penggunaan

### Flow 1: Registrasi & Approval

1. **Register** user baru via app
2. Login sebagai **admin**
3. Buka **User Approval**
4. **Approve** user baru
5. User bisa login sekarang

### Flow 2: Deposit Sampah (Client)

1. Login sebagai **client**
2. Tap **"Deposit"** di home
3. Pilih **jenis sampah**
4. Input **estimasi berat** (lihat preview earning)
5. **Take photo** dengan camera
6. Tap **"Submit Deposit"**
7. Tunggu admin validasi

### Flow 3: Validasi Transaksi (Admin)

1. Login sebagai **admin**
2. Buka **Transaction Validation**
3. Pilih **pending transaction**
4. Input **berat aktual** setelah ditimbang
5. Tap **"Approve & Calculate"**
6. Lihat **detail perhitungan** dengan bonus logic
7. Balance client otomatis terupdate

---

## 📡 API Documentation

### Base URL

```
http://localhost:3000/api
```

### Authentication

Gunakan JWT token di header:

```
Authorization: Bearer <token>
```

### Endpoints

#### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register user baru (is_active=0) |
| POST | `/auth/login` | Login (cek is_active) |

#### Users (Admin)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users/pending` | List pending users |
| PUT | `/users/:id/approve` | Approve user |
| DELETE | `/users/:id/reject` | Reject user |
| GET | `/users/me` | Get current user |

#### Waste Types

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/waste-types` | List all waste types |
| POST | `/waste-types` | Create (Admin) |
| PUT | `/waste-types/:id` | Update (Admin) |
| DELETE | `/waste-types/:id` | Delete (Admin) |

#### Transactions

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/transactions` | Submit deposit (Client) |
| GET | `/transactions` | Get user transactions |
| GET | `/transactions/pending` | Get pending (Admin) |
| PUT | `/transactions/:id/validate` | Validate & calculate (Admin) |

---

## 🎯 SubCPMK

### SubCPMK 2: Integrasi Public API ✅

**Implementasi:**
- API: NewsAPI.org
- Key: `8a199d5809834ea99c959640de78fdf5`
- Endpoint: `/v2/everything`
- Keywords: `environment OR waste OR recycling`
- Display: Home screen (3 latest articles)
- Credits: About screen

**File:**
- `lib/services/news_service.dart`
- `lib/screens/client/home_screen.dart`
- `lib/screens/client/about_screen.dart`

### SubCPMK 3: Logika Perhitungan ✅

**Algoritma Bonus:**

```javascript
if (actualWeight > bonusThreshold && bonusAmount > 0) {
  effectivePrice = basePrice + bonusAmount;
  bonusApplied = true;
} else {
  effectivePrice = basePrice;
  bonusApplied = false;
}

totalEarning = actualWeight * effectivePrice;
```

**Contoh:**
- Waste: Plastik PET
- Base price: Rp 3.000/kg
- Bonus threshold: 10 kg
- Bonus amount: Rp 500/kg
- Actual weight: **12 kg** ✅

**Hasil:**
- Effective price: Rp 3.500/kg (3.000 + 500)
- Total earning: **Rp 42.000** (12 × 3.500)

**File:**
- `backend/routes/transactions.js` (line 225-236)
- `lib/screens/admin/transaction_validation_screen.dart`

---

## 🛠 Troubleshooting

### ❌ Error: Connection refused / Endpoint not found

**Penyebab:**
- Backend tidak running
- IP address salah
- Port diblokir firewall

**Solusi:**
1. Cek backend: `npm start` di folder `backend/`
2. Verifikasi IP di `lib/config/api_config.dart`
3. Test endpoint: `curl http://10.0.2.2:3000/api`

### ❌ Error: Account pending approval

**Penyebab:**
- User baru belum di-approve admin (is_active=0)

**Solusi:**
1. Login sebagai admin
2. Buka "User Approval"
3. Approve user yang pending

### ❌ Error: type 'String' is not a subtype of type 'num'

**Penyebab:**
- MySQL mengirim numeric sebagai String

**Solusi:**
- Sudah diperbaiki dengan `_parseDouble()` helper di semua model

### ❌ Error: Only image files are allowed

**Penyebab:**
- Foto tidak memiliki contentType yang benar

**Solusi:**
- Sudah diperbaiki dengan explicit `contentType: MediaType('image', 'jpeg')`

### ❌ News tidak muncul

**Penyebab:**
- Tidak ada koneksi internet
- NewsAPI quota habis

**Solusi:**
1. Cek koneksi internet
2. Test API: https://newsapi.org/v2/everything?q=environment&apiKey=8a199d5809834ea99c959640de78fdf5
3. Pull to refresh di home screen

---

## 📸 Screenshots

*(Add screenshots here)*

---

## 📝 Database Schema

### users
```sql
- id (PK)
- name
- email (UNIQUE)
- password (hashed)
- role (client/admin)
- is_active (0/1)
- balance
- created_at
```

### waste_types
```sql
- id (PK)
- name
- price_per_kg
- bonus_threshold
- bonus_amount
- created_at
```

### transactions
```sql
- id (PK)
- user_id (FK)
- waste_type_id (FK)
- estimated_weight
- actual_weight
- photo_url
- total_earning
- status (pending/approved/rejected)
- created_at
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

MIT License - feel free to use this project for learning purposes.

---

## 👨‍💻 Developer

**EcoWallet** - Digital Bank Sampah Application
Built with ❤️ using Flutter & Node.js

---

## 📞 Support

Jika ada pertanyaan atau issue, silakan buat issue di repository ini.

**Happy Coding! 🌱♻️**
