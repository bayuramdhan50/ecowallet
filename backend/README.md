# EcoWallet Backend

Backend API untuk aplikasi EcoWallet - Sistem manajemen bank sampah dengan approval user dan perhitungan bonus otomatis.

## Features

- 🔐 **Authentication**: Register & Login dengan JWT
- ✅ **User Approval**: Admin approve/reject user baru (is_active check)
- 🗑️ **Waste Type Management**: CRUD jenis sampah dengan harga dan bonus
- 💰 **Transaction Calculation**: Logika perhitungan otomatis dengan bonus (SubCPMK 3)
- 📊 **Balance Management**: Tracking saldo user otomatis

## Tech Stack

- Node.js + Express
- MySQL 2
- JWT Authentication
- Bcrypt Password Hashing
- Multer File Upload

## Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Database

Buat database MySQL dan import schema:

```bash
mysql -u root -p < config/schema.sql
```

Atau manual:
```sql
CREATE DATABASE ecowallet_db;
```

Kemudian import `config/schema.sql` via MySQL Workbench atau command line.

### 3. Environment Variables

File `.env` sudah tersedia. Jika perlu ubah, edit sesuai konfigurasi MySQL Anda:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=ecowallet_db
```

### 4. Create Uploads Directory

```bash
mkdir uploads
```

### 5. Run Server

```bash
npm start
```

Atau dengan auto-reload (development):

```bash
npm run dev
```

Server akan berjalan di `http://localhost:3000`

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register user baru (is_active=0)
- `POST /api/auth/login` - Login (check is_active)

### Users (Admin)

- `GET /api/users/pending` - List user pending
- `PUT /api/users/:id/approve` - Approve user
- `DELETE /api/users/:id/reject` - Reject user
- `GET /api/users/me` - Get profile

### Waste Types

- `GET /api/waste-types` - List semua jenis sampah
- `POST /api/waste-types` - Create (Admin)
- `PUT /api/waste-types/:id` - Update (Admin)
- `DELETE /api/waste-types/:id` - Delete (Admin)

### Transactions

- `POST /api/transactions` - Submit deposit
- `GET /api/transactions` - Get user transactions
- `GET /api/transactions/pending` - Get pending (Admin)
- `PUT /api/transactions/:id/validate` - Validate & calculate (Admin)

## Default Admin Account

```
Email: admin@ecowallet.com
Password: admin123
```

## Calculation Logic (SubCPMK 3)

```javascript
if (actual_weight > bonus_threshold) {
  effective_price = base_price + bonus_amount
} else {
  effective_price = base_price
}

total_earning = actual_weight × effective_price
```

Contoh:
- Plastik: Rp 3.000/kg, bonus threshold 10kg, bonus +Rp 500/kg
- Input: 12kg
- Kalkulasi: 12 × (3.000 + 500) = Rp 42.000

## Sample Data

Database schema sudah include sample data:
- Admin user
- 4 jenis sampah (Plastik, Kertas, Logam, Botol Kaca)

## License

ISC
