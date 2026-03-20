const express = require('express');
const cors = require('cors');
const session = require('express-session');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));
app.use(session({
  secret: process.env.SESSION_SECRET || 'shree-sarees-secret',
  resave: false,
  saveUninitialized: false,
}));

// View engine (web admin panel)
app.set('view engine', 'ejs');
app.set('views', './views');

// Web admin panel routes
app.use('/admin', require('./routes/adminRoutes'));

// Flutter API routes
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/products', require('./routes/productRoutes'));
app.use('/api/orders', require('./routes/orderRoutes'));
app.use('/api/shipments', require('./routes/shipmentRoutes'));
app.use('/api/inventory', require('./routes/inventoryRoutes'));
app.use('/api/tally', require('./routes/tallyRoutes'));
app.use('/api/stores', require('./routes/storeRoutes'));

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
