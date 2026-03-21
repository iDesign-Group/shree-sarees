const pool = require('./db');

const Inventory = {
  async addInward({ product_id, shelf_id, bundle_count, total_sarees, inward_date }) {
    const [result] = await pool.query(
      'INSERT INTO inventory (product_id, shelf_id, bundle_count, total_sarees, inward_date) VALUES (?, ?, ?, ?, ?)',
      [product_id, shelf_id, bundle_count, total_sarees, inward_date]
    );
    return result.insertId;
  },

  async findAll() {
    const [rows] = await pool.query(`
      SELECT i.*, p.product_code, p.product_name, p.set_size,
        s.shelf_number, r.rack_number, g.name AS godown_name,
        g.id AS godown_id, r.id AS rack_id
      FROM inventory i
      JOIN products p ON i.product_id = p.id
      JOIN shelves s ON i.shelf_id = s.id
      JOIN racks r ON s.rack_id = r.id
      JOIN godowns g ON r.godown_id = g.id
      ORDER BY i.inward_date DESC
    `);
    return rows;
  },

  async findByProduct(productId) {
    const [rows] = await pool.query(`
      SELECT i.*, s.shelf_number, r.rack_number, g.name AS godown_name
      FROM inventory i
      JOIN shelves s ON i.shelf_id = s.id
      JOIN racks r ON s.rack_id = r.id
      JOIN godowns g ON r.godown_id = g.id
      WHERE i.product_id = ?
      ORDER BY i.inward_date DESC
    `, [productId]);
    return rows;
  },

  /** Single inward row with location + product set_size (for corrections). */
  async findById(id) {
    const [rows] = await pool.query(
      `
      SELECT i.*, p.product_code, p.product_name, p.set_size,
        s.shelf_number, r.rack_number, g.name AS godown_name,
        g.id AS godown_id, r.id AS rack_id
      FROM inventory i
      JOIN products p ON i.product_id = p.id
      JOIN shelves s ON i.shelf_id = s.id
      JOIN racks r ON s.rack_id = r.id
      JOIN godowns g ON r.godown_id = g.id
      WHERE i.id = ?
    `,
      [id]
    );
    return rows[0] || null;
  },

  /**
   * Correct an inward line (wrong quantity / date / shelf).
   * total_sarees is recalculated from product set_size × bundle_count.
   */
  async updateInward(id, { bundle_count, shelf_id, inward_date }) {
    const row = await this.findById(id);
    if (!row) throw new Error('Inventory row not found');

    const bundle = parseInt(bundle_count, 10);
    if (!Number.isFinite(bundle) || bundle < 1) {
      throw new Error('Bundle count must be at least 1');
    }
    const shelfId = parseInt(shelf_id, 10);
    if (!Number.isFinite(shelfId)) throw new Error('Invalid shelf');

    const total_sarees = bundle * row.set_size;

    await pool.query(
      `UPDATE inventory SET bundle_count = ?, total_sarees = ?, shelf_id = ?, inward_date = ? WHERE id = ?`,
      [bundle, total_sarees, shelfId, inward_date, id]
    );

    return { ...row, bundle_count: bundle, total_sarees, shelf_id: shelfId, inward_date };
  },

  async totalBundles() {
    const [rows] = await pool.query('SELECT COALESCE(SUM(bundle_count), 0) AS total FROM inventory');
    return rows[0].total;
  },

  // Godown/Rack/Shelf cascading lookups
  async getGodowns() {
    const [rows] = await pool.query('SELECT * FROM godowns ORDER BY id');
    return rows;
  },

  async getRacksByGodown(godownId) {
    const [rows] = await pool.query('SELECT * FROM racks WHERE godown_id = ? ORDER BY rack_number', [godownId]);
    return rows;
  },

  async getShelvesByRack(rackId) {
    const [rows] = await pool.query('SELECT * FROM shelves WHERE rack_id = ? ORDER BY shelf_number', [rackId]);
    return rows;
  },
};

module.exports = Inventory;
