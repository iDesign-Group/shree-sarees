const express = require('express');
const multer = require('multer');
const path = require('path');
const router = express.Router();
const productController = require('../controllers/productController');
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');
const { checkLoginExpiry } = require('../middleware/loginExpiryMiddleware');

// Multer config
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(__dirname, '..', 'uploads', 'products')),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = /jpeg|jpg|png|webp/;
    const ext = allowed.test(path.extname(file.originalname).toLowerCase());
    const mime = allowed.test(file.mimetype);
    cb(null, ext && mime);
  },
});

// Public (authenticated)
router.get('/', verifyToken, checkLoginExpiry, productController.list);
router.get('/:id', verifyToken, checkLoginExpiry, productController.detail);

// Admin only
router.post('/', verifyToken, adminOnly, productController.create);
router.put('/:id', verifyToken, adminOnly, productController.update);
router.delete('/:id', verifyToken, adminOnly, productController.delete);
router.post('/:id/images', verifyToken, adminOnly, upload.array('images', 10), productController.uploadImages);
router.delete('/:id/images/:imageId', verifyToken, adminOnly, productController.deleteImage);

module.exports = router;
