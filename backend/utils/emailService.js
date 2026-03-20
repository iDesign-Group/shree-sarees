const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// Order Confirmation Email — with broker PDF as attachment
const sendOrderConfirmation = async (toEmail, order, items, brokerPdfBuffer) => {
  const itemRows = items.map(item =>
    `<tr>
      <td style="padding:8px 12px;border-bottom:1px solid #E8E0D5;">${item.product_name} (${item.product_code})</td>
      <td style="padding:8px 12px;border-bottom:1px solid #E8E0D5;text-align:center;">${item.bundles_ordered}</td>
      <td style="padding:8px 12px;border-bottom:1px solid #E8E0D5;text-align:center;">${item.sarees_count / item.bundles_ordered}</td>
      <td style="padding:8px 12px;border-bottom:1px solid #E8E0D5;text-align:center;">${item.sarees_count}</td>
      <td style="padding:8px 12px;border-bottom:1px solid #E8E0D5;text-align:right;">\u20B9${Number(item.bundle_cost / item.bundles_ordered).toLocaleString('en-IN')}</td>
      <td style="padding:8px 12px;border-bottom:1px solid #E8E0D5;text-align:right;">\u20B9${Number(item.bundle_cost).toLocaleString('en-IN')}</td>
    </tr>`
  ).join('');

  const html = `
    <div style="font-family:'Inter',Arial,sans-serif;max-width:620px;margin:0 auto;background:#FAF7F2;padding:24px;">
      <div style="background:#6D1C2E;padding:20px 24px;border-radius:8px 8px 0 0;">
        <h1 style="font-family:'Playfair Display',Georgia,serif;color:#C9A84C;margin:0;font-size:24px;">Shree Sarees</h1>
      </div>
      <div style="background:#FFFFFF;padding:24px;border-radius:0 0 8px 8px;box-shadow:0 2px 12px rgba(0,0,0,0.08);">
        <h2 style="font-family:'Playfair Display',Georgia,serif;color:#1C1C1C;margin-top:0;">Order Confirmed \u2705</h2>
        <p style="color:#6B6B6B;">Your order <strong style="color:#C9A84C;">#${order.id}</strong> has been placed successfully.</p>
        ${order.store_name ? `<p style="color:#6B6B6B;"><strong>Store:</strong> ${order.store_name}</p>` : ''}
        <table style="width:100%;border-collapse:collapse;margin:16px 0;">
          <thead>
            <tr style="background:#FAF7F2;">
              <th style="padding:8px 12px;text-align:left;color:#6D1C2E;font-size:13px;">Product</th>
              <th style="padding:8px 12px;text-align:center;color:#6D1C2E;font-size:13px;">Bundles</th>
              <th style="padding:8px 12px;text-align:center;color:#6D1C2E;font-size:13px;">Sarees/Bundle</th>
              <th style="padding:8px 12px;text-align:center;color:#6D1C2E;font-size:13px;">Total Sarees</th>
              <th style="padding:8px 12px;text-align:right;color:#6D1C2E;font-size:13px;">Cost/Bundle</th>
              <th style="padding:8px 12px;text-align:right;color:#6D1C2E;font-size:13px;">Total</th>
            </tr>
          </thead>
          <tbody>${itemRows}</tbody>
        </table>
        <div style="border-top:2px solid #C9A84C;padding-top:12px;margin-top:8px;">
          <p style="margin:4px 0;"><strong>Total Sarees:</strong> ${order.total_sarees}</p>
          <p style="margin:4px 0;font-size:18px;"><strong>Grand Total: \u20B9${Number(order.total_amount).toLocaleString('en-IN')}</strong></p>
        </div>
        <p style="color:#6B6B6B;font-size:13px;margin-top:16px;">\uD83D\uDCCE Please find your order copy attached as a PDF.</p>
        <p style="color:#6B6B6B;font-size:13px;">Payment due within 60 days.</p>
      </div>
      <p style="text-align:center;color:#6B6B6B;font-size:11px;margin-top:16px;">&copy; Shree Sarees. All rights reserved.</p>
    </div>
  `;

  const mailOptions = {
    from: process.env.EMAIL_FROM,
    to: toEmail,
    subject: `Order Confirmed \u2013 Shree Sarees #${order.id}`,
    html,
  };

  if (brokerPdfBuffer) {
    mailOptions.attachments = [{
      filename: `Order_${order.id}_Shree_Sarees.pdf`,
      content: brokerPdfBuffer,
      contentType: 'application/pdf',
    }];
  }

  try {
    await transporter.sendMail(mailOptions);
    return true;
  } catch (err) {
    console.error('Email send error (order confirmation):', err);
    return false;
  }
};

// Shipment Notification Email
const sendShipmentNotification = async (toEmail, order, shipment) => {
  const html = `
    <div style="font-family:'Inter',Arial,sans-serif;max-width:600px;margin:0 auto;background:#FAF7F2;padding:24px;">
      <div style="background:#6D1C2E;padding:20px 24px;border-radius:8px 8px 0 0;">
        <h1 style="font-family:'Playfair Display',Georgia,serif;color:#C9A84C;margin:0;font-size:24px;">Shree Sarees</h1>
      </div>
      <div style="background:#FFFFFF;padding:24px;border-radius:0 0 8px 8px;box-shadow:0 2px 12px rgba(0,0,0,0.08);">
        <h2 style="font-family:'Playfair Display',Georgia,serif;color:#1C1C1C;margin-top:0;">Your Order Has Been Shipped!</h2>
        <p style="color:#6B6B6B;">Order <strong style="color:#C9A84C;">#${order.id}</strong> is on its way.</p>
        <div style="background:#FAF7F2;border-left:4px solid #6D1C2E;padding:16px;border-radius:0 8px 8px 0;margin:16px 0;">
          <p style="margin:4px 0;"><strong>Courier:</strong> ${shipment.courier_name}</p>
          <p style="margin:4px 0;"><strong>Tracking Number:</strong> ${shipment.tracking_number}</p>
          <p style="margin:4px 0;"><strong>Shipment Date:</strong> ${shipment.shipment_date}</p>
          ${shipment.notes ? `<p style="margin:4px 0;"><strong>Notes:</strong> ${shipment.notes}</p>` : ''}
        </div>
      </div>
      <p style="text-align:center;color:#6B6B6B;font-size:11px;margin-top:16px;">&copy; Shree Sarees. All rights reserved.</p>
    </div>
  `;

  try {
    await transporter.sendMail({
      from: process.env.EMAIL_FROM,
      to: toEmail,
      subject: `Your Order Has Been Shipped \u2013 Shree Sarees #${order.id}`,
      html,
    });
    return true;
  } catch (err) {
    console.error('Email send error (shipment):', err);
    return false;
  }
};

module.exports = { sendOrderConfirmation, sendShipmentNotification };
