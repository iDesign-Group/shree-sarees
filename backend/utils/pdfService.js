const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const MAROON = '#6D1C2E';
const GOLD = '#C9A84C';
const LIGHT_BG = '#FAF7F2';
const TEXT_DARK = '#1C1C1C';
const TEXT_GREY = '#6B6B6B';

// Fetch an image from URL as buffer (for product images)
async function fetchImageBuffer(imageUrl) {
  try {
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer', timeout: 5000 });
    return Buffer.from(response.data);
  } catch {
    return null;
  }
}

// Resolve product image URL to an absolute URL
function resolveImageUrl(imagePath) {
  if (!imagePath) return null;
  if (imagePath.startsWith('http')) return imagePath;
  const base = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
  return `${base}/${imagePath.replace(/^\//, '')}`;
}

/**
 * Draw the header (logo text + title)
 */
function drawHeader(doc, title) {
  doc.rect(0, 0, doc.page.width, 70).fill(MAROON);
  doc.font('Helvetica-Bold').fontSize(22).fillColor(GOLD).text('Shree Sarees', 40, 18);
  doc.font('Helvetica').fontSize(11).fillColor('#FFFFFF').text(title, 40, 46);
  doc.fillColor(TEXT_DARK);
  doc.y = 90;
}

/**
 * Draw order meta info block
 */
function drawOrderMeta(doc, order, storeName, storeAddress, storePhone) {
  const startY = doc.y;
  let boxH = 52;
  if (storeName) {
    boxH = 78;
    if (storeAddress) boxH += 36;
    if (storePhone) boxH += 16;
  }
  doc.rect(30, startY, doc.page.width - 60, boxH).fill(LIGHT_BG);
  doc.fillColor(TEXT_DARK);

  doc.font('Helvetica-Bold').fontSize(11).text(`Order #${order.id}`, 45, startY + 10);
  doc.font('Helvetica').fontSize(10).fillColor(TEXT_GREY)
    .text(`Date: ${new Date(order.order_date || order.created_at || Date.now()).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}`, 45, startY + 26);

  let y = startY + 42;
  if (storeName) {
    doc.font('Helvetica-Bold').fontSize(10).fillColor(MAROON).text('Store:', 45, y);
    doc.font('Helvetica').fontSize(10).fillColor(TEXT_DARK).text(storeName, 88, y);
    y += 16;
    if (storeAddress) {
      doc.font('Helvetica-Bold').fontSize(9).fillColor(MAROON).text('Address:', 45, y);
      doc.font('Helvetica').fontSize(9).fillColor(TEXT_GREY).text(storeAddress, 45, y + 12, { width: doc.page.width - 90 });
      y += 36;
    }
    if (storePhone) {
      doc.font('Helvetica-Bold').fontSize(9).fillColor(MAROON).text('Contact:', 45, y);
      doc.font('Helvetica').fontSize(9).fillColor(TEXT_DARK).text(storePhone, 92, y);
    }
  }

  doc.y = startY + boxH + 8;
  doc.fillColor(TEXT_DARK);
}

/**
 * Draw a single product row with optional image and optional godown info
 */
async function drawProductRow(doc, item, imageBuffer, showGodown) {
  const rowHeight = 110;
  const startY = doc.y;
  const pageWidth = doc.page.width;

  // Check page overflow
  if (startY + rowHeight > doc.page.height - 60) {
    doc.addPage();
    doc.y = 40;
  }

  const y = doc.y;
  doc.rect(30, y, pageWidth - 60, rowHeight - 6).stroke('#E8E0D5');

  // Product image
  const imgX = 40;
  const imgY = y + 8;
  const imgSize = 80;
  if (imageBuffer) {
    try {
      doc.image(imageBuffer, imgX, imgY, { width: imgSize, height: imgSize, fit: [imgSize, imgSize] });
    } catch {
      doc.rect(imgX, imgY, imgSize, imgSize).stroke('#E8E0D5');
      doc.font('Helvetica').fontSize(8).fillColor(TEXT_GREY).text('No Image', imgX + 20, imgY + 34);
    }
  } else {
    doc.rect(imgX, imgY, imgSize, imgSize).stroke('#E8E0D5');
    doc.font('Helvetica').fontSize(8).fillColor(TEXT_GREY).text('No Image', imgX + 20, imgY + 34);
  }

  // Product details
  const detailX = imgX + imgSize + 14;
  doc.font('Helvetica-Bold').fontSize(11).fillColor(TEXT_DARK).text(item.product_name, detailX, y + 10);
  doc.font('Helvetica').fontSize(9).fillColor(TEXT_GREY).text(`Code: ${item.product_code}`, detailX, y + 25);

  // Stats grid
  const stats = [
    { label: 'Bundles', value: item.bundles_ordered },
    { label: 'Sarees/Bundle', value: item.set_size || (item.sarees_count / item.bundles_ordered) },
    { label: 'Total Sarees', value: item.sarees_count },
    { label: 'Cost/Bundle', value: `\u20B9${Number((item.bundle_cost / item.bundles_ordered)).toLocaleString('en-IN')}` },
    { label: 'Total Cost', value: `\u20B9${Number(item.bundle_cost).toLocaleString('en-IN')}` },
  ];

  let sx = detailX;
  let sy = y + 42;
  stats.forEach((s, i) => {
    if (i === 3) { sx = detailX; sy = y + 70; }
    doc.font('Helvetica').fontSize(8).fillColor(TEXT_GREY).text(s.label, sx, sy);
    doc.font('Helvetica-Bold').fontSize(9).fillColor(TEXT_DARK).text(String(s.value), sx, sy + 11);
    sx += 95;
  });

  // Godown info (only for godown copy)
  if (showGodown && item.godown_name) {
    doc.font('Helvetica').fontSize(8).fillColor(MAROON)
      .text(`Godown: ${item.godown_name}  |  Rack: ${item.rack_number}  |  Shelf: ${item.shelf_number}`, detailX, y + 90);
  }

  doc.y = y + rowHeight;
}

/**
 * Draw totals footer
 */
function drawTotals(doc, order) {
  if (doc.y + 60 > doc.page.height - 40) doc.addPage();
  const y = doc.y + 10;
  doc.rect(30, y, doc.page.width - 60, 50).fill(LIGHT_BG);
  doc.font('Helvetica-Bold').fontSize(11).fillColor(MAROON)
    .text(`Total Sarees: ${order.total_sarees}`, 45, y + 10);
  doc.font('Helvetica-Bold').fontSize(13).fillColor(TEXT_DARK)
    .text(`Grand Total: \u20B9${Number(order.total_amount).toLocaleString('en-IN')}`, 45, y + 28);
  doc.fillColor(TEXT_GREY);
}

/**
 * Generate BROKER PDF — store details + product images, bundles, costs
 * Returns a Buffer
 */
async function generateBrokerPDF(order, items, storeName, storeAddress, storePhone) {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ margin: 30, size: 'A4' });
      const buffers = [];
      doc.on('data', chunk => buffers.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(buffers)));
      doc.on('error', reject);

      drawHeader(doc, `Order Copy — ${storeName || 'Order'}`);
      drawOrderMeta(doc, order, storeName, storeAddress, storePhone);

      doc.font('Helvetica-Bold').fontSize(12).fillColor(MAROON).text('Order Items', 30, doc.y + 6);
      doc.moveDown(0.3);

      for (const item of items) {
        const imageUrl = item.images && item.images[0] ? resolveImageUrl(item.images[0].image_path) : null;
        const imgBuf = imageUrl ? await fetchImageBuffer(imageUrl) : null;
        await drawProductRow(doc, item, imgBuf, false);
        doc.moveDown(0.3);
      }

      drawTotals(doc, order);

      doc.font('Helvetica').fontSize(9).fillColor(TEXT_GREY)
        .text('Payment due within 60 days. Thank you for your order.', 30, doc.page.height - 40, { align: 'center' });

      doc.end();
    } catch (err) {
      reject(err);
    }
  });
}

/**
 * Generate GODOWN COPY PDF — same as broker but with godown/rack/shelf info
 * Saved to disk and returns the file path
 */
async function generateGodownPDF(order, itemsWithInventory, storeName) {
  const dir = path.join(__dirname, '../storage/order_pdfs');
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  const filePath = path.join(dir, `order_${order.id}_godown.pdf`);

  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ margin: 30, size: 'A4' });
      const stream = fs.createWriteStream(filePath);
      doc.pipe(stream);
      stream.on('finish', () => resolve(filePath));
      stream.on('error', reject);

      drawHeader(doc, `Godown Copy — Order #${order.id}`);
      drawOrderMeta(doc, order, storeName, order.store_address || null, order.store_phone || null);

      doc.font('Helvetica-Bold').fontSize(12).fillColor(MAROON).text('Order Items (Godown Copy)', 30, doc.y + 6);
      doc.moveDown(0.3);

      for (const item of itemsWithInventory) {
        const imageUrl = item.images && item.images[0] ? resolveImageUrl(item.images[0].image_path) : null;
        const imgBuf = imageUrl ? await fetchImageBuffer(imageUrl) : null;
        await drawProductRow(doc, item, imgBuf, true);
        doc.moveDown(0.3);
      }

      drawTotals(doc, order);

      doc.font('Helvetica').fontSize(8).fillColor(TEXT_GREY)
        .text('Internal Use Only — Godown Copy', 30, doc.page.height - 40, { align: 'center' });

      doc.end();
    } catch (err) {
      reject(err);
    }
  });
}

module.exports = { generateBrokerPDF, generateGodownPDF };
