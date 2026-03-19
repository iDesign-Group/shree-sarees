require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');

const app = express();

// ── Middleware ──────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use(express.static(path.join(__dirname, 'public')));

// ── Sessions (Admin Panel) ─────────────────────────
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 24 * 60 * 60 * 1000 }, // 24 hours
}));

// ── EJS View Engine ────────────────────────────────
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// ── API Routes ─────────────────────────────────────
const productRoutes = require('./routes/productRoutes');
const inventoryRoutes = require('./routes/inventoryRoutes');
const orderRoutes = require('./routes/orderRoutes');
const shipmentRoutes = require('./routes/shipmentRoutes');
const userRoutes = require('./routes/userRoutes');

app.use('/api/products', productRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/shipments', shipmentRoutes);
app.use('/api/users', userRoutes);
app.use('/api/auth', userRoutes);

// ── Tally Export Stub ──────────────────────────────
const tallyRoutes = require('./routes/tallyRoutes');
app.use('/api/tally', tallyRoutes);

// ── Admin Panel Routes ─────────────────────────────
const adminRoutes = require('./routes/adminRoutes');
app.use('/admin', adminRoutes);

// ── Root redirect ──────────────────────────────────
app.get('/', (req, res) => res.redirect('/admin'));

// ── Error Handler ──────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// ── Start Server ───────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Shree Sarees server running on http://localhost:${PORT}`);
});
