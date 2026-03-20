const pool = require('./db');

const Store = {
  async getByUser(userId) {
    const [rows] = await pool.query(
      'SELECT id, name FROM store_names WHERE user_id = ? ORDER BY name ASC',
      [userId]
    );
    return rows;
  },

  async save(userId, name) {
    const trimmed = name.trim();
    if (!trimmed) return;
    // Upsert — ignore if already exists for this user
    await pool.query(
      'INSERT IGNORE INTO store_names (user_id, name) VALUES (?, ?)',
      [userId, trimmed]
    );
  },
};

module.exports = Store;
