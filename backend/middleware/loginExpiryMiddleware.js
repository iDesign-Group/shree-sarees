const pool = require('../models/db');

// Check login_expiry for shop_owner role
const checkLoginExpiry = async (req, res, next) => {
  if (!req.user || req.user.role !== 'shop_owner') {
    return next();
  }

  try {
    const [rows] = await pool.query(
      'SELECT login_expiry FROM users WHERE id = ? AND is_active = 1',
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'User not found or inactive.' });
    }

    const { login_expiry } = rows[0];
    if (!login_expiry || new Date(login_expiry) < new Date()) {
      return res.status(401).json({
        error: 'Session expired. Please contact your broker.',
        code: 'SESSION_EXPIRED',
      });
    }

    next();
  } catch (err) {
    console.error('Login expiry check error:', err);
    return res.status(500).json({ error: 'Internal server error.' });
  }
};

module.exports = { checkLoginExpiry };
