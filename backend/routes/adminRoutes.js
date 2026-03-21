const express = require('express');
const bcrypt = require('bcrypt');
const router = express.Router();
const User = require('../models/userModel');
const Product = require('../models/productModel');
const Inventory = require('../models/inventoryModel');
const Order = require('../models/orderModel');
const Shipment = require('../models/shipmentModel');

// Admin session check middleware
const adminSession = (req, res, next) => {
  if (req.session && req.session.admin) {
    res.locals.admin = req.session.admin;
    res.locals.adminToken = req.session.adminToken;
    return next();
  }
  res.redirect('/admin/login');
};

// Login page
router.get('/login', (req, res) => {
  res.render('login', { error: null });
});

const jwt = require('jsonwebtoken');

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findByEmail(email);

    if (!user || user.role !== 'admin') {
      return res.render('login', { error: 'Invalid admin credentials.' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.render('login', { error: 'Invalid admin credentials.' });
    }

    // Set session
    req.session.admin = { id: user.id, name: user.name, email: user.email, role: user.role };

    // Generate JWT token and store in session to pass to EJS
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    req.session.adminToken = token; // <- store token in session

    res.redirect('/admin/dashboard');
  } catch (err) {
    console.error(err);
    res.render('login', { error: 'Login failed. Please try again.' });
  }
});

router.get('/logout', (req, res) => {
  req.session.destroy();
  res.redirect('/admin/login');
});

// Dashboard
router.get('/', adminSession, (req, res) => res.redirect('/admin/dashboard'));
router.get('/dashboard', adminSession, async (req, res) => {
  try {
    const totalProducts = await Product.count();
    const totalBundles = await Inventory.totalBundles();
    const pendingOrders = await Order.countByStatus('pending');
    const totalUsers = await User.count();
    const recentOrders = await Order.findAll();
    res.render('dashboard', {
      page: 'dashboard',
      totalProducts, totalBundles, pendingOrders, totalUsers,
      recentOrders: recentOrders.slice(0, 10),
    });
  } catch (err) {
    console.error(err);
    res.render('dashboard', { page: 'dashboard', totalProducts: 0, totalBundles: 0, pendingOrders: 0, totalUsers: 0, recentOrders: [] });
  }
});

// Products
router.get('/products', adminSession, async (req, res) => {
  try {
    const products = await Product.findAll();
    res.render('products', { page: 'products', products });
  } catch (err) {
    console.error(err);
    res.render('products', { page: 'products', products: [] });
  }
});

// Inventory
router.get('/inventory', adminSession, async (req, res) => {
  try {
    const inventory = await Inventory.findAll();
    const products = await Product.findAll();
    const godowns = await Inventory.getGodowns();
    res.render('inventory', { page: 'inventory', inventory, products, godowns });
  } catch (err) {
    console.error(err);
    res.render('inventory', { page: 'inventory', inventory: [], products: [], godowns: [] });
  }
});

// Orders
router.get('/orders', adminSession, async (req, res) => {
  try {
    const orders = await Order.findAll();
    res.render('orders', { page: 'orders', orders });
  } catch (err) {
    console.error(err);
    res.render('orders', { page: 'orders', orders: [] });
  }
});

// Shipments
router.get('/shipments', adminSession, async (req, res) => {
  try {
    const shipments = await Shipment.findAll();
    const orders = await Order.findAll();
    res.render('shipments', {
      page: 'shipments',
      shipments,
      orders: orders.filter(o => o.status === 'confirmed' || o.status === 'shipped')
    });
  } catch (err) {
    console.error(err);
    res.render('shipments', { page: 'shipments', shipments: [], orders: [] });
  }
});

// Delivery Challan
router.get('/delivery-challan', adminSession, async (req, res) => {
  try {
    const orderId = req.query.orderId ? Number(req.query.orderId) : null;
    const challanItems = await Order.getDeliveryChallanItems(orderId);
    // Group by order_id
    const ordersMap = {};
    for (const row of challanItems) {
      if (!ordersMap[row.order_id]) {
        ordersMap[row.order_id] = {
          order_id: row.order_id,
          order_date: row.order_date,
          status: row.status,
          store_name: row.store_name,
          store_address: row.store_address,
          store_phone: row.store_phone,
          customer_name: row.customer_name,
          items: [],
        };
      }
      ordersMap[row.order_id].items.push({
        item_id: row.item_id,
        product_id: row.product_id,
        product_code: row.product_code,
        product_name: row.product_name,
        image_url: row.image_url,
        bundles_ordered: row.bundles_ordered,
        sarees_count: row.sarees_count,
        set_size: row.set_size,
        price_per_saree_at_order: row.price_per_saree_at_order,
        bundle_cost: row.bundle_cost,
        godown_name: row.godown_name,
        rack_number: row.rack_number,
        shelf_number: row.shelf_number,
      });
    }
    const orders = Object.values(ordersMap).map((order) => {
      const items = order.items.map((item) => {
        const rawPath = item.image_url || '';
        let image_url = null;
        if (rawPath) {
          if (/^https?:\/\//i.test(rawPath)) {
            image_url = rawPath;
          } else {
            const normalized = rawPath.replace(/\\/g, '/').replace(/^\/?uploads\//i, '');
            image_url = `/uploads/${normalized}`;
          }
        }

        const bundleCost = Number(item.bundle_cost || 0);
        const bundlesOrdered = Number(item.bundles_ordered || 0);
        const pricePerBundle = bundlesOrdered > 0 ? bundleCost / bundlesOrdered : 0;
        return { ...item, image_url, pricePerBundle };
      });

      const totalBundles = items.reduce((sum, item) => sum + Number(item.bundles_ordered || 0), 0);
      const totalSarees = items.reduce((sum, item) => sum + Number(item.sarees_count || 0), 0);
      const totalAmount = items.reduce((sum, item) => sum + Number(item.bundle_cost || 0), 0);

      return {
        ...order,
        items,
        totalBundles,
        totalSarees,
        totalAmount,
        creditPeriodLabel: order.credit_period_days ? `${order.credit_period_days} days` : 'Not specified',
      };
    });
    res.render('delivery-challan', {
      page: 'delivery-challan',
      orders,
      selectedOrderId: orderId,
    });
  } catch (err) {
    console.error(err);
    res.render('delivery-challan', { page: 'delivery-challan', orders: [], selectedOrderId: null });
  }
});

// Users
router.get('/users', adminSession, async (req, res) => {
  try {
    const users = await User.findAll();
    res.render('users', { page: 'users', users });
  } catch (err) {
    console.error(err);
    res.render('users', { page: 'users', users: [] });
  }
});

module.exports = router;
