const express = require('express');
const router = express.Router();
const Store = require('../models/storeModel');
const { verifyToken } = require('../middleware/authMiddleware');
const { checkLoginExpiry } = require('../middleware/loginExpiryMiddleware');

// GET /api/stores — returns saved store names for current broker
router.get('/', verifyToken, checkLoginExpiry, async (req, res) => {
  try {
    const stores = await Store.getByUser(req.user.id);
    res.json(stores);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch store names.' });
  }
});

// POST /api/stores — save a new store name
router.post('/', verifyToken, checkLoginExpiry, async (req, res) => {
  try {
    const { name } = req.body;
    if (!name || !name.trim()) return res.status(400).json({ error: 'Store name is required.' });
    await Store.save(req.user.id, name);
    res.json({ message: 'Store name saved.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to save store name.' });
  }
});

module.exports = router;
