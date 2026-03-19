const Product = require('../models/productModel');
const path = require('path');
const fs = require('fs');

const productController = {
  // GET /api/products
  async list(req, res) {
    try {
      const products = await Product.findAll();
      res.json(products);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch products.' });
    }
  },

  // GET /api/products/:id
  async detail(req, res) {
    try {
      const product = await Product.findById(req.params.id);
      if (!product) return res.status(404).json({ error: 'Product not found.' });
      res.json(product);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch product.' });
    }
  },

  // POST /api/products (admin)
  async create(req, res) {
    try {
      const { product_code, product_name, set_size, price_per_saree } = req.body;
      if (!product_code || !product_name || !set_size || !price_per_saree) {
        return res.status(400).json({ error: 'All fields are required.' });
      }
      const id = await Product.create({ product_code, product_name, set_size, price_per_saree });
      const product = await Product.findById(id);
      res.status(201).json(product);
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ error: 'Product code already exists.' });
      }
      console.error(err);
      res.status(500).json({ error: 'Failed to create product.' });
    }
  },

  // PUT /api/products/:id (admin)
  async update(req, res) {
    try {
      const { product_code, product_name, set_size, price_per_saree } = req.body;
      await Product.update(req.params.id, { product_code, product_name, set_size, price_per_saree });
      const product = await Product.findById(req.params.id);
      res.json(product);
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ error: 'Product code already exists.' });
      }
      console.error(err);
      res.status(500).json({ error: 'Failed to update product.' });
    }
  },

  // DELETE /api/products/:id (admin)
  async delete(req, res) {
    try {
      const product = await Product.findById(req.params.id);
      if (!product) return res.status(404).json({ error: 'Product not found.' });

      // Delete image files
      for (const img of product.images) {
        const filePath = path.join(__dirname, '..', img.image_path);
        if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
      }

      await Product.delete(req.params.id);
      res.json({ message: 'Product deleted.' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to delete product.' });
    }
  },

  // POST /api/products/:id/images (admin) — Multer handles files
  async uploadImages(req, res) {
    try {
      if (!req.files || req.files.length === 0) {
        return res.status(400).json({ error: 'No images uploaded.' });
      }
      const images = [];
      for (const file of req.files) {
        const imagePath = `uploads/products/${file.filename}`;
        const imageId = await Product.addImage(req.params.id, imagePath);
        images.push({ id: imageId, image_path: imagePath });
      }
      res.status(201).json({ message: 'Images uploaded.', images });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to upload images.' });
    }
  },

  // DELETE /api/products/:id/images/:imageId (admin)
  async deleteImage(req, res) {
    try {
      const image = await Product.deleteImage(req.params.imageId);
      if (!image) return res.status(404).json({ error: 'Image not found.' });

      const filePath = path.join(__dirname, '..', image.image_path);
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);

      res.json({ message: 'Image deleted.' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to delete image.' });
    }
  },
};

module.exports = productController;
