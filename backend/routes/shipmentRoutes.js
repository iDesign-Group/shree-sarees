const express = require('express');
const router = express.Router();
const shipmentController = require('../controllers/shipmentController');
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');

// Admin only
router.post('/', verifyToken, adminOnly, shipmentController.create);
router.put('/:id', verifyToken, adminOnly, shipmentController.update);

// Authenticated
router.get('/', verifyToken, shipmentController.list);
router.get('/:orderId', verifyToken, shipmentController.byOrder);

module.exports = router;
