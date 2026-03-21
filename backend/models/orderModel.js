const pool = require('./db');

const Order = {
  // Bug Fix #1: Added store_address to create() signature and SQL INSERT
  async create({ user_id, store_name, store_address, total_sarees, total_amount, items }) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const [orderResult] = await conn.query(
        'INSERT INTO orders (user_id, store_name, store_address, total_sarees, total_amount) VALUES (?, ?, ?, ?, ?)',
        [user_id, store_name || null, store_address || null, total_sarees, total_amount]
      );
      const orderId = orderResult.insertId;

      for (const item of items) {
        await conn.query(
          `INSERT INTO order_items (order_id, product_id, bundles_ordered, sarees_count, price_per_saree_at_order, bundle_cost)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [orderId, item.product_id, item.bundles_ordered, item.sarees_count, item.price_per_saree, item.bundle_cost]
        );

        let bundlesToDeduct = item.bundles_ordered;
        const [invRows] = await conn.query(
          `SELECT id, bundle_count FROM inventory
           WHERE product_id = ? AND bundle_count > 0
           ORDER BY inward_date ASC`,
          [item.product_id]
        );
        for (const inv of invRows) {
          if (bundlesToDeduct <= 0) break;
          const deduct = Math.min(inv.bundle_count, bundlesToDeduct);
          await conn.query(
            `UPDATE inventory SET bundle_count = bundle_count - ? WHERE id = ?`,
            [deduct, inv.id]
          );
          bundlesToDeduct -= deduct;
        }
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

  // Bug Fix #3: Fixed inventory restore in cancel() to distribute proportionally across rows (FIFO-reverse)
  async cancel(id) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();
      const [rows] = await conn.query('SELECT status FROM orders WHERE id = ?', [id]);
      if (rows.length === 0) throw new Error('Order not found');
      if (rows[0].status === 'cancelled') throw new Error('Order is already cancelled');
      if (rows[0].status === 'delivered') throw new Error('Delivered orders cannot be cancelled');

      const [items] = await conn.query(
        'SELECT product_id, bundles_ordered FROM order_items WHERE order_id = ?',
        [id]
      );
      for (const item of items) {
        let bundlesToRestore = item.bundles_ordered;
        // Restore in reverse FIFO order (latest inward first)
        const [invRows] = await conn.query(
          `SELECT id, bundle_count FROM inventory WHERE product_id = ? ORDER BY inward_date DESC`,
          [item.product_id]
        );
        for (const inv of invRows) {
          if (bundlesToRestore <= 0) break;
          await conn.query(
            `UPDATE inventory SET bundle_count = bundle_count + ? WHERE id = ?`,
            [bundlesToRestore, inv.id]
          );
          bundlesToRestore = 0;
        }
      }
      await conn.query(`UPDATE orders SET status = 'cancelled' WHERE id = ?`, [id]);
      await conn.commit();
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  },

  // Bug Fix #3 (same): Fixed inventory restore in delete() to distribute across rows
  async delete(id) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();
      const [items] = await conn.query(
        'SELECT product_id, bundles_ordered FROM order_items WHERE order_id = ?',
        [id]
      );
      for (const item of items) {
        let bundlesToRestore = item.bundles_ordered;
        // Restore in reverse FIFO order (latest inward first)
        const [invRows] = await conn.query(
          `SELECT id, bundle_count FROM inventory WHERE product_id = ? ORDER BY inward_date DESC`,
          [item.product_id]
        );
        for (const inv of invRows) {
          if (bundlesToRestore <= 0) break;
          await conn.query(
            `UPDATE inventory SET bundle_count = bundle_count + ? WHERE id = ?`,
            [bundlesToRestore, inv.id]
          );
          bundlesToRestore = 0;
        }
      }
      await conn.query('DELETE FROM order_items WHERE order_id = ?', [id]);
      await conn.query('DELETE FROM orders WHERE id = ?', [id]);
      await conn.commit();
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  },

  async findAll() {
    const [rows] = await pool.query(`
      SELECT o.*, u.name AS user_name, u.email AS user_email, u.role AS user_role
      FROM orders o
      JOIN users u ON o.user_id = u.id
      ORDER BY o.order_date DESC
    `);
    return rows;
  },

  async findByUser(userId) {
    const [rows] = await pool.query(
      `SELECT o.* FROM orders o WHERE o.user_id = ? ORDER BY o.order_date DESC`,
      [userId]
    );
    return rows;
  },

  async findById(id) {
    const [rows] = await pool.query(`
      SELECT o.*, u.name AS user_name, u.email AS user_email, u.role AS user_role
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

  // feat: delivery challan — fetch all pending/confirmed orders with product + inventory location details
  async getDeliveryChallanItems() {
    const [rows] = await pool.query(`
      SELECT
        o.id            AS order_id,
        o.order_date,
        o.status,
        o.store_name,
        o.store_address,
        u.name          AS customer_name,
        oi.id           AS item_id,
        oi.bundles_ordered,
        oi.sarees_count,
        p.id            AS product_id,
        p.product_code,
        p.product_name,
        p.image_url,
        g.name          AS godown_name,
        r.rack_number,
        s.shelf_number
      FROM orders o
      JOIN users u        ON o.user_id = u.id
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p     ON oi.product_id = p.id
      LEFT JOIN inventory i  ON i.product_id = p.id AND i.bundle_count > 0
      LEFT JOIN shelves s    ON i.shelf_id = s.id
      LEFT JOIN racks r      ON s.rack_id = r.id
      LEFT JOIN godowns g    ON r.godown_id = g.id
      WHERE o.status IN ('pending', 'confirmed')
      ORDER BY o.order_date DESC, o.id, oi.id
    `);
    return rows;
  },
};

module.exports = Order;
