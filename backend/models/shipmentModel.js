const pool = require('./db');

const Shipment = {
  async create({ order_id, shipment_date, courier_name, tracking_number, notes }) {
    const [result] = await pool.query(
      `INSERT INTO shipments (order_id, shipment_date, courier_name, tracking_number, notes)
       VALUES (?, ?, ?, ?, ?)`,
      [order_id, shipment_date, courier_name, tracking_number, notes]
    );
    return result.insertId;
  },

  async findByOrder(orderId) {
    const [rows] = await pool.query('SELECT * FROM shipments WHERE order_id = ?', [orderId]);
    return rows[0] || null;
  },

  async findAll() {
    const [rows] = await pool.query(`
      SELECT s.*, o.status AS order_status, o.total_amount, o.total_sarees,
        u.name AS user_name, u.email AS user_email
      FROM shipments s
      JOIN orders o ON s.order_id = o.id
      JOIN users u ON o.user_id = u.id
      ORDER BY s.shipment_date DESC
    `);
    return rows;
  },

  async update(id, { shipment_date, courier_name, tracking_number, notes }) {
    await pool.query(
      `UPDATE shipments SET shipment_date = ?, courier_name = ?, tracking_number = ?, notes = ? WHERE id = ?`,
      [shipment_date, courier_name, tracking_number, notes, id]
    );
  },

  async setNotified(id) {
    await pool.query('UPDATE shipments SET notified_at = NOW() WHERE id = ?', [id]);
  },

  async findById(id) {
    const [rows] = await pool.query('SELECT * FROM shipments WHERE id = ?', [id]);
    return rows[0] || null;
  },
};

module.exports = Shipment;
