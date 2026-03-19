const express = require('express');
const router = express.Router();
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');
const Order = require('../models/orderModel');
const Inventory = require('../models/inventoryModel');

// GET /api/tally/export — Tally-compatible XML stub
router.get('/export', verifyToken, adminOnly, async (req, res) => {
  try {
    const orders = await Order.findAll();
    const inventory = await Inventory.findAll();

    let xml = '<?xml version="1.0" encoding="UTF-8"?>\n';
    xml += '<ENVELOPE>\n';
    xml += '  <HEADER>\n';
    xml += '    <TALLYREQUEST>Import Data</TALLYREQUEST>\n';
    xml += '  </HEADER>\n';
    xml += '  <BODY>\n';
    xml += '    <IMPORTDATA>\n';
    xml += '      <REQUESTDESC>\n';
    xml += '        <REPORTNAME>Vouchers</REPORTNAME>\n';
    xml += '      </REQUESTDESC>\n';
    xml += '      <REQUESTDATA>\n';

    // Orders as Sales Vouchers
    for (const order of orders) {
      const fullOrder = await Order.findById(order.id);
      xml += '        <TALLYMESSAGE xmlns:UDF="TallyUDF">\n';
      xml += `          <VOUCHER VCHTYPE="Sales" ACTION="Create">\n`;
      xml += `            <DATE>${new Date(order.order_date).toISOString().split('T')[0].replace(/-/g, '')}</DATE>\n`;
      xml += `            <VOUCHERNUMBER>SS-ORD-${order.id}</VOUCHERNUMBER>\n`;
      xml += `            <PARTYLEDGERNAME>${order.user_name || 'Customer'}</PARTYLEDGERNAME>\n`;
      xml += `            <AMOUNT>${order.total_amount}</AMOUNT>\n`;
      if (fullOrder && fullOrder.items) {
        for (const item of fullOrder.items) {
          xml += `            <INVENTORYENTRIES.LIST>\n`;
          xml += `              <STOCKITEMNAME>${item.product_name} (${item.product_code})</STOCKITEMNAME>\n`;
          xml += `              <QUANTITY>${item.sarees_count} pcs</QUANTITY>\n`;
          xml += `              <RATE>${item.price_per_saree_at_order}/pc</RATE>\n`;
          xml += `              <AMOUNT>${item.bundle_cost}</AMOUNT>\n`;
          xml += `            </INVENTORYENTRIES.LIST>\n`;
        }
      }
      xml += `          </VOUCHER>\n`;
      xml += '        </TALLYMESSAGE>\n';
    }

    xml += '      </REQUESTDATA>\n';
    xml += '    </IMPORTDATA>\n';
    xml += '  </BODY>\n';
    xml += '</ENVELOPE>';

    res.set('Content-Type', 'application/xml');
    res.send(xml);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to generate Tally export.' });
  }
});

module.exports = router;
