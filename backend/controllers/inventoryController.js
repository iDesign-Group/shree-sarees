const Inventory = require('../models/inventoryModel');
const Product = require('../models/productModel');

const inventoryController = {
  // POST /api/inventory/inward (admin)
  async inward(req, res) {
    try {
      const { product_id, bundle_count, shelf_id, inward_date } = req.body;
      if (!product_id || !bundle_count || !shelf_id || !inward_date) {
        return res.status(400).json({ error: 'All fields are required.' });
      }

      // Fetch product to get set_size
      const product = await Product.findById(product_id);
      if (!product) return res.status(404).json({ error: 'Product not found.' });

      const total_sarees = bundle_count * product.set_size;

      const id = await Inventory.addInward({
        product_id, shelf_id, bundle_count, total_sarees, inward_date,
      });

      res.status(201).json({
        id,
        product_id,
        bundle_count,
        total_sarees,
        shelf_id,
        inward_date,
        message: `Inward recorded: ${bundle_count} bundles = ${total_sarees} sarees`,
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to record inward stock.' });
    }
  },

  // GET /api/inventory
  async list(req, res) {
    try {
      const inventory = await Inventory.findAll();
      res.json(inventory);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch inventory.' });
    }
  },

  // PUT /api/inventory/:id (admin) — correct inward quantity / date / shelf
  async updateInward(req, res) {
    try {
      const id = parseInt(req.params.id, 10);
      if (!Number.isFinite(id)) {
        return res.status(400).json({ error: 'Invalid inventory id.' });
      }
      const { bundle_count, shelf_id, inward_date } = req.body;
      if (bundle_count == null || !shelf_id || !inward_date) {
        return res.status(400).json({ error: 'bundle_count, shelf_id, and inward_date are required.' });
      }

      const updated = await Inventory.updateInward(id, {
        bundle_count,
        shelf_id,
        inward_date,
      });

      res.json({
        message: 'Inward record updated.',
        id: updated.id,
        bundle_count: updated.bundle_count,
        total_sarees: updated.total_sarees,
        shelf_id: updated.shelf_id,
        inward_date: updated.inward_date,
      });
    } catch (err) {
      console.error(err);
      if (err.message === 'Inventory row not found') {
        return res.status(404).json({ error: err.message });
      }
      if (
        err.message.includes('Bundle count') ||
        err.message.includes('Invalid shelf')
      ) {
        return res.status(400).json({ error: err.message });
      }
      res.status(500).json({ error: 'Failed to update inward stock.' });
    }
  },

  // GET /api/inventory/product/:id
  async byProduct(req, res) {
    try {
      const inventory = await Inventory.findByProduct(req.params.id);
      res.json(inventory);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch inventory for product.' });
    }
  },

  // Cascading lookups for admin panel
  async godowns(req, res) {
    try {
      const data = await Inventory.getGodowns();
      res.json(data);
    } catch (err) {
      res.status(500).json({ error: 'Failed to fetch godowns.' });
    }
  },

  async racks(req, res) {
    try {
      const data = await Inventory.getRacksByGodown(req.params.godownId);
      res.json(data);
    } catch (err) {
      res.status(500).json({ error: 'Failed to fetch racks.' });
    }
  },

  async shelves(req, res) {
    try {
      const data = await Inventory.getShelvesByRack(req.params.rackId);
      res.json(data);
    } catch (err) {
      res.status(500).json({ error: 'Failed to fetch shelves.' });
    }
  },
};

module.exports = inventoryController;
