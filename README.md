# Shree Sarees — Wholesale Saree Management System

Full-stack wholesale saree management system with a Node.js/Express backend, MySQL database, EJS admin panel, and Flutter mobile app.

---

## Prerequisites

| Tool | Version | Download |
|------|---------|----------|
| **Node.js** | v18+ | https://nodejs.org |
| **MySQL** | 8.0+ | https://dev.mysql.com/downloads |
| **Flutter** | 3.x (Dart ≥ 3.0) | https://docs.flutter.dev/get-started/install |
| **Android Studio** | Latest (for emulator) | https://developer.android.com/studio |

---

## Project Structure

```
shree-sarees/
├── database/           # SQL schema and seed data
│   ├── schema.sql      # 10 tables (godowns, racks, shelves, products, etc.)
│   └── seed.sql        # Sample data (4 godowns, 300 racks, 10 products, 3 users)
├── backend/            # Node.js + Express API + EJS Admin Panel
│   ├── app.js          # Entry point
│   ├── .env            # Environment variables (edit this!)
│   ├── controllers/    # Route handlers
│   ├── models/         # MySQL query helpers
│   ├── routes/         # API + admin routes
│   ├── middleware/      # JWT auth, login expiry
│   ├── utils/          # Email service (Nodemailer)
│   ├── views/          # EJS admin panel pages
│   └── public/         # CSS + JS for admin panel
└── flutter_app/        # Flutter mobile app
    └── lib/
        ├── main.dart
        ├── theme/      # AppTheme (colors, typography)
        ├── models/     # Data models
        ├── services/   # API client
        ├── providers/  # State management (Provider)
        ├── screens/    # Core + admin screens
        └── widgets/    # Reusable widgets
```

---

## 1. Database Setup

Open a MySQL client (MySQL Workbench, CLI, etc.) and run:

```sql
source F:/shree-sarees/database/schema.sql;
source F:/shree-sarees/database/seed.sql;
```

Or from the command line:

```sh
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql
```

This creates the `shree_sarees` database with all tables and seed data.

### Generate Real Password Hashes

The seed file inserts placeholder password hashes. After starting the backend (step 2), generate real hashes using the Node.js REPL:

```sh
node -e "const bcrypt = require('bcrypt'); bcrypt.hash('Admin@123', 10).then(h => console.log(h))"
```

Then update the users table:

```sql
USE shree_sarees;
UPDATE users SET password_hash = '<paste_hash_here>' WHERE email = 'admin@shreesarees.com';
UPDATE users SET password_hash = '<paste_hash_here>' WHERE email = 'rajesh@example.com';
UPDATE users SET password_hash = '<paste_hash_here>' WHERE email = 'suresh@example.com';
```

### Default Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@shreesarees.com | Admin@123 |
| Broker | rajesh@example.com | Admin@123 |
| Shop Owner | suresh@example.com | Admin@123 |

> ⚠️ Change all passwords before any production use.

---

## 2. Backend Setup

```sh
cd backend
npm install
```

### Configure Environment Variables

Edit `backend/.env` with your values:

```env
# Required — update these:
DB_PASSWORD=your_mysql_root_password
JWT_SECRET=a_long_random_string
SESSION_SECRET=another_long_random_string

# Optional — for email notifications:
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_gmail_app_password
```

> **Gmail SMTP**: You need a [Gmail App Password](https://support.google.com/accounts/answer/185833) (not your regular password). Enable 2FA first, then generate an App Password.

### Start the Server

```sh
# Development (auto-restart on changes)
npm run dev

# Production
npm start
```

The server starts at **http://localhost:3000**.

- **Admin Panel**: http://localhost:3000/admin
- **API Base**: http://localhost:3000/api

### API Endpoints Summary

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/login` | — | Login, returns JWT |
| GET | `/api/products` | JWT | List all products |
| GET | `/api/products/:id` | JWT | Product detail |
| POST | `/api/products` | Admin | Create product (multipart) |
| PUT | `/api/products/:id` | Admin | Update product |
| DELETE | `/api/products/:id` | Admin | Delete product |
| GET | `/api/inventory` | JWT | List inventory |
| POST | `/api/inventory` | Admin | Add inward stock |
| GET | `/api/orders` | JWT | List orders (own or all for admin) |
| POST | `/api/orders` | JWT | Place order |
| PUT | `/api/orders/:id/status` | Admin | Update order status |
| GET | `/api/shipments/:orderId` | JWT | Get shipment for order |
| POST | `/api/shipments` | Admin | Create shipment |
| GET | `/api/users` | Admin | List all users |
| POST | `/api/users` | Admin | Create user |
| GET | `/api/tally/export` | Admin | Tally XML export (stub) |

---

## 3. Flutter App Setup

```sh
cd flutter_app
flutter pub get
```

### Configure API URL

Edit `lib/services/api_service.dart` line 8:

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

| Scenario | URL |
|----------|-----|
| Android Emulator | `http://10.0.2.2:3000` (default) |
| Physical device (same Wi-Fi) | `http://<your-pc-ip>:3000` |
| iOS Simulator | `http://localhost:3000` |

> Find your PC's IP: run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) and use the IPv4 address.

### Create Flutter Project Files

The `flutter_app/` directory contains only `lib/` and `pubspec.yaml`. You need to generate the platform scaffolding:

```sh
cd flutter_app
flutter create . --project-name shree_sarees
```

This generates `android/`, `ios/`, `web/`, `windows/`, `test/`, etc. without overwriting existing `lib/` or `pubspec.yaml`.

### Run the App

Make sure the backend server is running first, then:

```sh
# List available devices
flutter devices

# Run on Android emulator
flutter run

# Run on specific device
flutter run -d <device_id>
```

---

## 4. Quick Start (TL;DR)

```sh
# 1. Database
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql

# 2. Backend
cd backend
npm install
# Edit .env with your DB_PASSWORD, JWT_SECRET, SESSION_SECRET
npm run dev
# Generate password hashes (see section 1) and update the users table

# 3. Flutter (in a new terminal)
cd flutter_app
flutter create . --project-name shree_sarees
flutter pub get
flutter run
```

---

## Architecture

### Backend

- **Express.js** — REST API + EJS server-rendered admin panel
- **MySQL2** — Connection pooling via `models/db.js`
- **JWT** — Stateless auth for API endpoints (`middleware/authMiddleware.js`)
- **Express Sessions** — Cookie-based auth for admin panel (`routes/adminRoutes.js`)
- **Multer** — Product image uploads to `uploads/products/`
- **Nodemailer** — Order confirmation + shipment notification emails
- **Role-based access** — `admin`, `broker`, `shop_owner` with per-route role checks
- **Login expiry** — Shop owners have a 15-minute session window

### Flutter App

- **Provider** — State management (auth, cart, products, orders)
- **Google Fonts** — Playfair Display (headings) + Inter (body)
- **Lucide Icons** — Consistent icon set
- **Responsive layout** — `NavigationRail` on tablet, `BottomNavigationBar` on mobile
- **Admin detection** — Admin users automatically see the admin dashboard

### Design System

| Token | Value |
|-------|-------|
| Primary | `#1B2A4A` (Navy) |
| Primary Dark | `#0F1D35` |
| Accent | `#C8A951` (Gold) |
| Background | `#F8F6F3` (Cream) |
| Surface | `#FFFFFF` |
| Text Primary | `#1A1A2E` |
| Text Secondary | `#6B7280` |
| Heading Font | Playfair Display |
| Body Font | Inter |

---

## Troubleshooting

**`ER_ACCESS_DENIED_ERROR`** — Check `DB_PASSWORD` in `.env` matches your MySQL root password.

**`ECONNREFUSED` on Flutter** — Make sure the backend is running. If using a physical device, update `baseUrl` to your PC's LAN IP and ensure both devices are on the same network.

**Seed password hashes don't work** — The seed uses placeholder hashes. Generate real bcrypt hashes as described in section 1.

**`flutter create .` overwrites files** — It won't overwrite existing `lib/` or `pubspec.yaml`. It only generates missing platform directories.

**Email sending fails** — Verify `SMTP_USER` and `SMTP_PASS` in `.env`. For Gmail, you must use an App Password with 2FA enabled.
