const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');
const { checkLoginExpiry } = require('../middleware/loginExpiryMiddleware');

// Authenticated (all roles)
router.post('/', verifyToken, checkLoginExpiry, orderController.create);
router.get('/', verifyToken, checkLoginExpiry, orderController.list);
router.get('/:id', verifyToken, checkLoginExpiry, orderController.detail);

// Admin only
router.put('/:id/status', verifyToken, adminOnly, orderController.updateStatus);

module.exports = router;
