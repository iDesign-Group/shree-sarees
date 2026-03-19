const Order = require('../models/orderModel');
const Product = require('../models/productModel');
const User = require('../models/userModel');
const { sendOrderConfirmation } = require('../utils/emailService');

const orderController = {
  // POST /api/orders
  async create(req, res) {
    try {
      const { items } = req.body; // [{ product_id, bundles_ordered }]
      if (!items || items.length === 0) {
        return res.status(400).json({ error: 'Order must have at least one item.' });
      }

      let total_sarees = 0;
      let total_amount = 0;
      const processedItems = [];

      for (const item of items) {
        const product = await Product.findById(item.product_id);
        if (!product) {
          return res.status(404).json({ error: `Product ${item.product_id} not found.` });
        }

        const sarees_count = item.bundles_ordered * product.set_size;
        const bundle_cost = sarees_count * product.price_per_saree;

        processedItems.push({
          product_id: item.product_id,
          bundles_ordered: item.bundles_ordered,
          sarees_count,
          price_per_saree: product.price_per_saree,
          bundle_cost,
          product_name: product.product_name,
          product_code: product.product_code,
        });

        total_sarees += sarees_count;
        total_amount += bundle_cost;
      }

      const orderId = await Order.create({
        user_id: req.user.id,
        total_sarees,
        total_amount,
        items: processedItems,
      });

      const order = await Order.findById(orderId);

      // Send confirmation email
      const user = await User.findById(req.user.id);
      if (user && user.email) {
        sendOrderConfirmation(user.email, order, processedItems);
      }

      res.status(201).json(order);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to place order.' });
    }
  },

  // GET /api/orders
  async list(req, res) {
    try {
      let orders;
      if (req.user.role === 'admin') {
        orders = await Order.findAll();
      } else {
        orders = await Order.findByUser(req.user.id);
      }
      res.json(orders);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch orders.' });
    }
  },

  // GET /api/orders/:id
  async detail(req, res) {
    try {
      const order = await Order.findById(req.params.id);
      if (!order) return res.status(404).json({ error: 'Order not found.' });

      // Non-admin can only see own orders
      if (req.user.role !== 'admin' && order.user_id !== req.user.id) {
        return res.status(403).json({ error: 'Forbidden.' });
      }

      res.json(order);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch order.' });
    }
  },

  // PUT /api/orders/:id/status (admin)
  async updateStatus(req, res) {
    try {
      const { status } = req.body;
      const validStatuses = ['pending', 'confirmed', 'shipped', 'delivered'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({ error: 'Invalid status.' });
      }

      await Order.updateStatus(req.params.id, status);
      res.json({ message: `Order status updated to ${status}.` });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to update order status.' });
    }
  },
};

module.exports = orderController;
