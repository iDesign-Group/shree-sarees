const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');
const { checkLoginExpiry } = require('../middleware/loginExpiryMiddleware');

// Auth
router.post('/login', userController.login);

// Current user
router.get('/me', verifyToken, checkLoginExpiry, userController.me);

// Admin only
router.get('/', verifyToken, adminOnly, userController.list);
router.post('/', verifyToken, adminOnly, userController.create);
router.put('/:id', verifyToken, adminOnly, userController.update);
router.delete('/:id', verifyToken, adminOnly, userController.delete);

module.exports = router;
