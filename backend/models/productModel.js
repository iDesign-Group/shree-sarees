const pool = require('./db');

const Product = {
  async findAll() {
    const [rows] = await pool.query(`
      SELECT p.*,
        (SELECT SUM(i.bundle_count) FROM inventory i WHERE i.product_id = p.id) AS total_bundles,
        (SELECT SUM(i.total_sarees) FROM inventory i WHERE i.product_id = p.id) AS total_sarees_in_stock
      FROM products p
      ORDER BY p.created_at DESC
    `);
    // Attach images
    for (const row of rows) {
      const [images] = await pool.query('SELECT * FROM product_images WHERE product_id = ?', [row.id]);
      row.images = images;
    }
    return rows;
  },

  async findById(id) {
    const [rows] = await pool.query(`
      SELECT p.*,
        (SELECT SUM(i.bundle_count) FROM inventory i WHERE i.product_id = p.id) AS total_bundles,
        (SELECT SUM(i.total_sarees) FROM inventory i WHERE i.product_id = p.id) AS total_sarees_in_stock
      FROM products p WHERE p.id = ?
    `, [id]);
    if (rows.length === 0) return null;
    const product = rows[0];
    const [images] = await pool.query('SELECT * FROM product_images WHERE product_id = ?', [id]);
    product.images = images;
    return product;
  },

  async create({ product_code, product_name, set_size, price_per_saree }) {
    const [result] = await pool.query(
      'INSERT INTO products (product_code, product_name, set_size, price_per_saree) VALUES (?, ?, ?, ?)',
      [product_code, product_name, set_size, price_per_saree]
    );
    return result.insertId;
  },

  async update(id, { product_code, product_name, set_size, price_per_saree }) {
    await pool.query(
      'UPDATE products SET product_code = ?, product_name = ?, set_size = ?, price_per_saree = ? WHERE id = ?',
      [product_code, product_name, set_size, price_per_saree, id]
    );
  },

  async delete(id) {
    await pool.query('DELETE FROM products WHERE id = ?', [id]);
  },

  async addImage(product_id, image_path) {
    const [result] = await pool.query(
      'INSERT INTO product_images (product_id, image_path) VALUES (?, ?)',
      [product_id, image_path]
    );
    return result.insertId;
  },

  async deleteImage(imageId) {
    const [rows] = await pool.query('SELECT * FROM product_images WHERE id = ?', [imageId]);
    if (rows.length > 0) {
      await pool.query('DELETE FROM product_images WHERE id = ?', [imageId]);
    }
    return rows[0] || null;
  },

  async count() {
    const [rows] = await pool.query('SELECT COUNT(*) as count FROM products');
    return rows[0].count;
  },
};

module.exports = Product;
