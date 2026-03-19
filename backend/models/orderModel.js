const pool = require('./db');

const Order = {
  async create({ user_id, total_sarees, total_amount, items }) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const [orderResult] = await conn.query(
        'INSERT INTO orders (user_id, total_sarees, total_amount) VALUES (?, ?, ?)',
        [user_id, total_sarees, total_amount]
      );
      const orderId = orderResult.insertId;

      for (const item of items) {
        await conn.query(
          `INSERT INTO order_items (order_id, product_id, bundles_ordered, sarees_count, price_per_saree_at_order, bundle_cost)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [orderId, item.product_id, item.bundles_ordered, item.sarees_count, item.price_per_saree, item.bundle_cost]
        );
      }

      await conn.commit();
      return orderId;
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  },

  async findAll() {
    const [rows] = await pool.query(`
      SELECT o.*, u.name AS user_name, u.email AS user_email
      FROM orders o
      JOIN users u ON o.user_id = u.id
      ORDER BY o.order_date DESC
    `);
    return rows;
  },

  async findByUser(userId) {
    const [rows] = await pool.query(`
      SELECT o.* FROM orders o WHERE o.user_id = ? ORDER BY o.order_date DESC
    `, [userId]);
    return rows;
  },

  async findById(id) {
    const [rows] = await pool.query(`
      SELECT o.*, u.name AS user_name, u.email AS user_email
      FROM orders o
      JOIN users u ON o.user_id = u.id
      WHERE o.id = ?
    `, [id]);
    if (rows.length === 0) return null;

    const order = rows[0];
    const [items] = await pool.query(`
      SELECT oi.*, p.product_code, p.product_name, p.set_size
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = ?
    `, [id]);
    order.items = items;
    return order;
  },

  async updateStatus(id, status) {
    await pool.query('UPDATE orders SET status = ? WHERE id = ?', [status, id]);
  },

  async countByStatus(status) {
    if (status) {
      const [rows] = await pool.query('SELECT COUNT(*) as count FROM orders WHERE status = ?', [status]);
      return rows[0].count;
    }
    const [rows] = await pool.query('SELECT COUNT(*) as count FROM orders');
    return rows[0].count;
  },
};

module.exports = Order;
