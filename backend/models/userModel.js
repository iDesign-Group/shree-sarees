const pool = require('./db');

const User = {
  async findAll() {
    const [rows] = await pool.query(
      'SELECT id, name, email, phone, role, login_expiry, is_active, created_at FROM users ORDER BY created_at DESC'
    );
    return rows;
  },

  async findById(id) {
    const [rows] = await pool.query(
      'SELECT id, name, email, phone, role, login_expiry, is_active, created_at FROM users WHERE id = ?',
      [id]
    );
    return rows[0] || null;
  },

  async findByEmail(email) {
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    return rows[0] || null;
  },

  async create({ name, email, phone, role, password_hash, login_expiry }) {
    const [result] = await pool.query(
      'INSERT INTO users (name, email, phone, role, password_hash, login_expiry) VALUES (?, ?, ?, ?, ?, ?)',
      [name, email, phone, role, password_hash, login_expiry || null]
    );
    return result.insertId;
  },

  async update(id, { name, email, phone, role, login_expiry, is_active }) {
    await pool.query(
      'UPDATE users SET name = ?, email = ?, phone = ?, role = ?, login_expiry = ?, is_active = ? WHERE id = ?',
      [name, email, phone, role, login_expiry || null, is_active, id]
    );
  },

  async updatePassword(id, password_hash) {
    await pool.query('UPDATE users SET password_hash = ? WHERE id = ?', [password_hash, id]);
  },

  async setLoginExpiry(id, expiry) {
    await pool.query('UPDATE users SET login_expiry = ? WHERE id = ?', [expiry, id]);
  },

  async delete(id) {
    await pool.query('DELETE FROM users WHERE id = ?', [id]);
  },

  async count() {
    const [rows] = await pool.query('SELECT COUNT(*) as count FROM users');
    return rows[0].count;
  },
};

module.exports = User;
