const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventoryController');
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');

// Admin only
router.post('/inward', verifyToken, adminOnly, inventoryController.inward);

// Authenticated
router.get('/', verifyToken, inventoryController.list);
router.get('/product/:id', verifyToken, inventoryController.byProduct);

// Cascading lookups
router.get('/godowns', verifyToken, inventoryController.godowns);
router.get('/racks/:godownId', verifyToken, inventoryController.racks);
router.get('/shelves/:rackId', verifyToken, inventoryController.shelves);

// Admin only — must be after static paths (e.g. not before /inward)
router.put('/:id', verifyToken, adminOnly, inventoryController.updateInward);

module.exports = router;
