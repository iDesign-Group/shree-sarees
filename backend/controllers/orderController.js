const Order = require('../models/orderModel');
const Product = require('../models/productModel');
const User = require('../models/userModel');
const Store = require('../models/storeModel');
const Inventory = require('../models/inventoryModel');
const { sendOrderConfirmation } = require('../utils/emailService');
const { generateBrokerPDF, generateGodownPDF } = require('../utils/pdfService');

const orderController = {
  // POST /api/orders
  async create(req, res) {
    try {
      const { items, store_name, store_address, store_phone } = req.body;
      if (!items || items.length === 0) {
        return res.status(400).json({ error: 'Order must have at least one item.' });
      }
      if (req.user.role === 'broker') {
        if (!store_name || !store_name.trim()) {
          return res.status(400).json({ error: 'Store name is required for brokers.' });
        }
        if (!store_address || !String(store_address).trim()) {
          return res.status(400).json({ error: 'Store address is required for brokers.' });
        }
        if (!store_phone || !String(store_phone).trim()) {
          return res.status(400).json({ error: 'Store contact number is required for brokers.' });
        }
      }

      let total_sarees = 0;
      let total_amount = 0;
      const processedItems = [];

      for (const item of items) {
        const product = await Product.findById(item.product_id);
        if (!product) return res.status(404).json({ error: `Product ${item.product_id} not found.` });
        const sarees_count = item.bundles_ordered * product.set_size;
        const bundle_cost = sarees_count * product.price_per_saree;
        processedItems.push({
          product_id: item.product_id,
          bundles_ordered: item.bundles_ordered,
          sarees_count,
          set_size: product.set_size,
          price_per_saree: product.price_per_saree,
          bundle_cost,
          product_name: product.product_name,
          product_code: product.product_code,
          images: product.images || [],
        });
        total_sarees += sarees_count;
        total_amount += bundle_cost;
      }

      const orderId = await Order.create({
        user_id: req.user.id,
        store_name: store_name ? store_name.trim() : null,
        store_address: store_address ? String(store_address).trim() : null,
        store_phone: store_phone ? String(store_phone).trim() : null,
        total_sarees,
        total_amount,
        items: processedItems,
      });

      if (req.user.role === 'broker' && store_name && store_name.trim()) {
        await Store.save(req.user.id, store_name.trim());
      }

      const order = await Order.findById(orderId);
      const user = await User.findById(req.user.id);

      // Generate PDFs asynchronously (don't block response)
      setImmediate(async () => {
        try {
          // 1. Broker PDF — attach to email
          const brokerPdf = await generateBrokerPDF(
            order,
            processedItems,
            store_name ? store_name.trim() : null,
            store_address ? String(store_address).trim() : null,
            store_phone ? String(store_phone).trim() : null
          );

          // 2. Send email with PDF attached
          if (user && user.email) {
            await sendOrderConfirmation(user.email, order, processedItems, brokerPdf);
          }

          // 3. Godown Copy — fetch inventory info per product and save to disk
          const itemsWithInventory = await Promise.all(processedItems.map(async (item) => {
            const inv = await Inventory.findByProduct(item.product_id);
            const latest = inv && inv.length > 0 ? inv[0] : {};
            return {
              ...item,
              godown_name: latest.godown_name || null,
              rack_number: latest.rack_number || null,
              shelf_number: latest.shelf_number || null,
            };
          }));

          await generateGodownPDF(
            order,
            itemsWithInventory,
            store_name ? store_name.trim() : null
          );
        } catch (pdfErr) {
          console.error('PDF/Email generation error:', pdfErr);
        }
      });

      res.status(201).json(order);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to place order.' });
    }
  },

  // GET /api/orders
  async list(req, res) {
    try {
      const orders = req.user.role === 'admin'
        ? await Order.findAll()
        : await Order.findByUser(req.user.id);
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
      const validStatuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
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

  // POST /api/orders/:id/cancel
  async cancel(req, res) {
    try {
      const order = await Order.findById(req.params.id);
      if (!order) return res.status(404).json({ error: 'Order not found.' });
      if (req.user.role !== 'admin' && order.user_id !== req.user.id) {
        return res.status(403).json({ error: 'Forbidden.' });
      }
      await Order.cancel(req.params.id);
      res.json({ message: `Order #${req.params.id} has been cancelled and inventory restored.` });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: err.message || 'Failed to cancel order.' });
    }
  },

  // DELETE /api/orders/:id (admin)
  async remove(req, res) {
    try {
      const order = await Order.findById(req.params.id);
      if (!order) return res.status(404).json({ error: 'Order not found.' });
      await Order.delete(req.params.id);
      res.json({ message: `Order #${req.params.id} deleted and inventory restored.` });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to delete order.' });
    }
  },
};

module.exports = orderController;