const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const userController = {
  // POST /api/auth/login
  async login(req, res) {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required.' });
      }

      const user = await User.findByEmail(email);
      if (!user || !user.is_active) {
        return res.status(401).json({ error: 'Invalid credentials.' });
      }

      const isMatch = await bcrypt.compare(password, user.password_hash);
      if (!isMatch) {
        return res.status(401).json({ error: 'Invalid credentials.' });
      }

      // Set login_expiry for shop_owner
      if (user.role === 'shop_owner') {
        const expiry = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
        await User.setLoginExpiry(user.id, expiry);
      }

      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role, name: user.name },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      res.json({
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Login failed.' });
    }
  },

  // GET /api/users (admin)
  async list(req, res) {
    try {
      const users = await User.findAll();
      res.json(users);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch users.' });
    }
  },

  // POST /api/users (admin)
  async create(req, res) {
    try {
      const { name, email, phone, role, password, login_expiry } = req.body;
      if (!name || !email || !password) {
        return res.status(400).json({ error: 'Name, email, and password are required.' });
      }

      const password_hash = await bcrypt.hash(password, 10);
      const id = await User.create({ name, email, phone, role, password_hash, login_expiry });
      const user = await User.findById(id);
      res.status(201).json(user);
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ error: 'Email already exists.' });
      }
      console.error(err);
      res.status(500).json({ error: 'Failed to create user.' });
    }
  },

  // PUT /api/users/:id (admin)
  async update(req, res) {
    try {
      const { name, email, phone, role, login_expiry, is_active, password } = req.body;
      await User.update(req.params.id, { name, email, phone, role, login_expiry, is_active });

      if (password) {
        const password_hash = await bcrypt.hash(password, 10);
        await User.updatePassword(req.params.id, password_hash);
      }

      const user = await User.findById(req.params.id);
      res.json(user);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to update user.' });
    }
  },

  // DELETE /api/users/:id (admin)
  async delete(req, res) {
    try {
      await User.delete(req.params.id);
      res.json({ message: 'User deleted.' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to delete user.' });
    }
  },

  // GET /api/users/me (any authenticated user)
  async me(req, res) {
    try {
      const user = await User.findById(req.user.id);
      if (!user) return res.status(404).json({ error: 'User not found.' });
      res.json(user);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch user.' });
    }
  },
};

module.exports = userController;
