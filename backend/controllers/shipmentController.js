const Shipment = require('../models/shipmentModel');
const Order = require('../models/orderModel');
const { sendShipmentNotification } = require('../utils/emailService');

const shipmentController = {
  // POST /api/shipments (admin)
  async create(req, res) {
    try {
      const { order_id, shipment_date, courier_name, tracking_number, notes } = req.body;
      if (!order_id || !courier_name || !tracking_number) {
        return res.status(400).json({ error: 'Order ID, courier name, and tracking number are required.' });
      }

      const order = await Order.findById(order_id);
      if (!order) return res.status(404).json({ error: 'Order not found.' });

      const id = await Shipment.create({
        order_id, shipment_date, courier_name, tracking_number, notes,
      });

      // Update order status to shipped
      await Order.updateStatus(order_id, 'shipped');

      // Send notification email
      const shipment = await Shipment.findById(id);
      const sent = await sendShipmentNotification(order.user_email, order, shipment);
      if (sent) await Shipment.setNotified(id);

      res.status(201).json({ id, message: 'Shipment created and notification sent.' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to create shipment.' });
    }
  },

  // GET /api/shipments/:orderId
  async byOrder(req, res) {
    try {
      const shipment = await Shipment.findByOrder(req.params.orderId);
      if (!shipment) return res.status(404).json({ error: 'Shipment not found for this order.' });
      res.json(shipment);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch shipment.' });
    }
  },

  // GET /api/shipments
  async list(req, res) {
    try {
      const shipments = await Shipment.findAll();
      res.json(shipments);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to fetch shipments.' });
    }
  },

  // PUT /api/shipments/:id (admin)
  async update(req, res) {
    try {
      const { shipment_date, courier_name, tracking_number, notes } = req.body;
      await Shipment.update(req.params.id, { shipment_date, courier_name, tracking_number, notes });

      // Re-send notification
      const shipment = await Shipment.findById(req.params.id);
      if (shipment) {
        const order = await Order.findById(shipment.order_id);
        if (order) {
          const sent = await sendShipmentNotification(order.user_email, order, shipment);
          if (sent) await Shipment.setNotified(req.params.id);
        }
      }

      res.json({ message: 'Shipment updated. Email sent to buyer.' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to update shipment.' });
    }
  },
};

module.exports = shipmentController;
