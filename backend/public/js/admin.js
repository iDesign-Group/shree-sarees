/* ═══════════════════════════════════════════════════
   SHREE SAREES — Admin Panel Client-Side JS
   ═══════════════════════════════════════════════════ */

// ── Toast Notifications ─────────────────────────────
function showToast(message, type = 'success') {
  const container = document.getElementById('toast-container');
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `<span>${message}</span>`;
  container.appendChild(toast);
  setTimeout(() => toast.remove(), 4000);
}

// ── Admin Token (stored in session, used for API calls from admin panel) ──
function getAdminToken() {
  return localStorage.getItem('adminToken') || '';
}

async function apiCall(url, method = 'GET', body = null) {
  const opts = {
    method,
    headers: { 'Content-Type': 'application/json' },
  };
  const token = getAdminToken();
  if (token) opts.headers['Authorization'] = `Bearer ${token}`;
  if (body) opts.body = JSON.stringify(body);

  const res = await fetch(url, opts);
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Request failed');
  return data;
}

// ═══════════════════════════════════════════════════
// PRODUCTS
// ═══════════════════════════════════════════════════

function openProductDrawer(product = null) {
  document.getElementById('productOverlay').classList.add('open');
  document.getElementById('productDrawer').classList.add('open');
  document.getElementById('drawerTitle').textContent = product ? 'Edit Product' : 'Add Product';

  if (product) {
    document.getElementById('productId').value = product.id;
    document.getElementById('productCode').value = product.product_code;
    document.getElementById('productName').value = product.product_name;
    document.getElementById('setSize').value = product.set_size;
    document.getElementById('pricePerSaree').value = product.price_per_saree;
    calcBundlePrice();
  } else {
    document.getElementById('productForm').reset();
    document.getElementById('productId').value = '';
    document.getElementById('bundlePriceCalc').textContent = 'Bundle Price: ₹0';
  }
}

function closeProductDrawer() {
  document.getElementById('productOverlay').classList.remove('open');
  document.getElementById('productDrawer').classList.remove('open');
}

function editProduct(product) {
  openProductDrawer(product);
}

function calcBundlePrice() {
  const setSize = parseInt(document.getElementById('setSize').value) || 0;
  const price = parseFloat(document.getElementById('pricePerSaree').value) || 0;
  const bundle = setSize * price;
  document.getElementById('bundlePriceCalc').textContent = `Bundle Price: ₹${bundle.toLocaleString('en-IN')}`;
}

async function saveProduct() {
  const id = document.getElementById('productId').value;
  const data = {
    product_code: document.getElementById('productCode').value,
    product_name: document.getElementById('productName').value,
    set_size: parseInt(document.getElementById('setSize').value),
    price_per_saree: parseFloat(document.getElementById('pricePerSaree').value),
  };

  try {
    if (id) {
      await apiCall(`/api/products/${id}`, 'PUT', data);
      showToast('Product updated successfully.');
    } else {
      await apiCall('/api/products', 'POST', data);
      showToast('Product created successfully.');
    }
    closeProductDrawer();
    setTimeout(() => location.reload(), 500);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function deleteProduct(id) {
  if (!confirm('Are you sure you want to delete this product?')) return;
  try {
    await apiCall(`/api/products/${id}`, 'DELETE');
    showToast('Product deleted.');
    setTimeout(() => location.reload(), 500);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

// ── Image Upload ────────────────────────────────────
function openImageUpload(productId) {
  document.getElementById('imageOverlay').classList.add('open');
  document.getElementById('imageDrawer').classList.add('open');
  document.getElementById('imageProductId').value = productId;
  loadProductImages(productId);
}

function closeImageDrawer() {
  document.getElementById('imageOverlay').classList.remove('open');
  document.getElementById('imageDrawer').classList.remove('open');
}

async function loadProductImages(productId) {
  try {
    const product = await apiCall(`/api/products/${productId}`);
    const grid = document.getElementById('imagePreview');
    grid.innerHTML = '';
    if (product.images) {
      product.images.forEach(img => {
        grid.innerHTML += `<div style="position:relative;">
          <img src="/${img.image_path}" class="img-thumb">
          <button onclick="deleteImage(${productId}, ${img.id})" style="position:absolute;top:2px;right:2px;background:#B00020;color:#fff;border:none;border-radius:50%;width:20px;height:20px;cursor:pointer;font-size:10px;">×</button>
        </div>`;
      });
    }
  } catch (err) {
    console.error(err);
  }
}

async function uploadImages() {
  const productId = document.getElementById('imageProductId').value;
  const input = document.getElementById('imageInput');
  const formData = new FormData();
  for (const file of input.files) formData.append('images', file);

  try {
    const token = getAdminToken();
    const res = await fetch(`/api/products/${productId}/images`, {
      method: 'POST',
      headers: token ? { 'Authorization': `Bearer ${token}` } : {},
      body: formData,
    });
    if (!res.ok) throw new Error('Upload failed');
    showToast('Images uploaded successfully.');
    loadProductImages(productId);
    input.value = '';
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function deleteImage(productId, imageId) {
  try {
    await apiCall(`/api/products/${productId}/images/${imageId}`, 'DELETE');
    showToast('Image deleted.');
    loadProductImages(productId);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

// ═══════════════════════════════════════════════════
// INVENTORY WIZARD
// ═══════════════════════════════════════════════════

let selectedProduct = null;

function filterProducts() {
  const search = document.getElementById('productSearch').value.toLowerCase();
  document.querySelectorAll('.product-select-card').forEach(card => {
    const name = card.dataset.name.toLowerCase();
    const code = card.dataset.code.toLowerCase();
    card.style.display = (name.includes(search) || code.includes(search)) ? '' : 'none';
  });
}

function selectProduct(el) {
  selectedProduct = {
    id: el.dataset.id,
    name: el.dataset.name,
    code: el.dataset.code,
    setSize: parseInt(el.dataset.setsize),
    stock: el.dataset.stock,
  };

  document.getElementById('selectedProductCard').innerHTML = `
    <div class="summary-row"><span>Product</span><strong>${selectedProduct.name}</strong></div>
    <div class="summary-row"><span>Code</span><span>${selectedProduct.code}</span></div>
    <div class="summary-row"><span>Set Size</span><span>${selectedProduct.setSize} per bundle</span></div>
    <div class="summary-row"><span>Current Stock</span><span>${selectedProduct.stock} bundles</span></div>
  `;

  wizardNext(2);
}

function calcTotalSarees() {
  if (!selectedProduct) return;
  const bundles = parseInt(document.getElementById('bundleCount').value) || 0;
  const total = bundles * selectedProduct.setSize;
  document.getElementById('totalSareesCalc').textContent = `Total Sarees: ${total}`;
}

function wizardNext(step) {
  // Hide all panels
  document.querySelectorAll('.wizard-panel').forEach(p => p.classList.remove('active'));
  document.getElementById(`panel${step}`).classList.add('active');

  // Update step indicators
  for (let i = 1; i <= 3; i++) {
    const ws = document.getElementById(`ws${i}`);
    ws.classList.remove('active', 'done');
    if (i < step) ws.classList.add('done');
    if (i === step) ws.classList.add('active');
  }
  for (let i = 1; i <= 2; i++) {
    const sl = document.getElementById(`sl${i}`);
    sl.classList.toggle('active', i < step);
  }

  // Show final summary on step 3
  if (step === 3) updateFinalSummary();
}

function wizardBack(step) {
  wizardNext(step);
}

function updateFinalSummary() {
  const bundles = parseInt(document.getElementById('bundleCount').value) || 0;
  if (!selectedProduct || !bundles) return;

  const summary = document.getElementById('finalSummary');
  summary.style.display = 'block';
  summary.innerHTML = `
    <div class="summary-row"><span>Product</span><strong>${selectedProduct.name} (${selectedProduct.code})</strong></div>
    <div class="summary-row"><span>Bundles</span><span>${bundles}</span></div>
    <div class="summary-row"><span>Total Sarees</span><strong>${bundles * selectedProduct.setSize}</strong></div>
  `;
}

async function loadRacks() {
  const godownId = document.getElementById('godownSelect').value;
  const rackSelect = document.getElementById('rackSelect');
  const shelfSelect = document.getElementById('shelfSelect');

  rackSelect.innerHTML = '<option value="">Loading...</option>';
  rackSelect.disabled = true;
  shelfSelect.innerHTML = '<option value="">Select Shelf</option>';
  shelfSelect.disabled = true;

  if (!godownId) return;

  try {
    const racks = await apiCall(`/api/inventory/racks/${godownId}`);
    rackSelect.innerHTML = '<option value="">Select Rack</option>';
    racks.forEach(r => {
      rackSelect.innerHTML += `<option value="${r.id}">${r.rack_number}</option>`;
    });
    rackSelect.disabled = false;
  } catch (err) {
    showToast('Failed to load racks.', 'error');
  }
}

async function loadShelves() {
  const rackId = document.getElementById('rackSelect').value;
  const shelfSelect = document.getElementById('shelfSelect');

  shelfSelect.innerHTML = '<option value="">Loading...</option>';
  shelfSelect.disabled = true;

  if (!rackId) return;

  try {
    const shelves = await apiCall(`/api/inventory/shelves/${rackId}`);
    shelfSelect.innerHTML = '<option value="">Select Shelf</option>';
    shelves.forEach(s => {
      shelfSelect.innerHTML += `<option value="${s.id}">${s.shelf_number}</option>`;
    });
    shelfSelect.disabled = false;
  } catch (err) {
    showToast('Failed to load shelves.', 'error');
  }

  updateFinalSummary();
}

async function submitInward() {
  const shelfId = document.getElementById('shelfSelect').value;
  const bundleCount = parseInt(document.getElementById('bundleCount').value);
  const inwardDate = document.getElementById('inwardDate').value;

  if (!selectedProduct || !bundleCount || !shelfId || !inwardDate) {
    showToast('Please complete all fields.', 'warning');
    return;
  }

  try {
    await apiCall('/api/inventory/inward', 'POST', {
      product_id: parseInt(selectedProduct.id),
      bundle_count: bundleCount,
      shelf_id: parseInt(shelfId),
      inward_date: inwardDate,
    });
    showToast('Inward stock recorded successfully!');
    setTimeout(() => location.reload(), 800);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

// ═══════════════════════════════════════════════════
// ORDERS
// ═══════════════════════════════════════════════════

function filterOrders(status, btn) {
  document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
  btn.classList.add('active');

  document.querySelectorAll('.order-row').forEach(row => {
    if (status === 'all' || row.dataset.status === status) {
      row.style.display = '';
    } else {
      row.style.display = 'none';
    }
  });

  // Hide all expandable rows when filtering
  document.querySelectorAll('.expandable-row').forEach(r => r.classList.remove('open'));
}

async function toggleOrderDetail(orderId) {
  const detailRow = document.getElementById(`detail-${orderId}`);
  if (detailRow.classList.contains('open')) {
    detailRow.classList.remove('open');
    return;
  }

  // Close all other detail rows
  document.querySelectorAll('.expandable-row').forEach(r => r.classList.remove('open'));

  try {
    const order = await apiCall(`/api/orders/${orderId}`);
    let html = '<table style="width:100%;font-size:12px;"><thead><tr><th>Product</th><th>Bundles</th><th>Sarees</th><th>₹/Saree</th><th>Amount</th></tr></thead><tbody>';
    if (order.items) {
      order.items.forEach(item => {
        html += `<tr>
          <td>${item.product_name} (${item.product_code})</td>
          <td>${item.bundles_ordered}</td>
          <td>${item.sarees_count}</td>
          <td>₹${Number(item.price_per_saree_at_order).toLocaleString('en-IN')}</td>
          <td>₹${Number(item.bundle_cost).toLocaleString('en-IN')}</td>
        </tr>`;
      });
    }
    html += '</tbody></table>';
    document.getElementById(`detail-content-${orderId}`).innerHTML = html;
    detailRow.classList.add('open');
  } catch (err) {
    showToast('Failed to load order details.', 'error');
  }
}

async function updateOrderStatus(orderId, status) {
  try {
    await apiCall(`/api/orders/${orderId}/status`, 'PUT', { status });
    showToast(`Order #${orderId} status updated to ${status}.`);
    setTimeout(() => location.reload(), 500);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

function openShipmentForOrder(orderId) {
      window.location.href = `/admin/shipments?orderId=${orderId}`;
}

// ═══════════════════════════════════════════════════
// SHIPMENTS
// ═══════════════════════════════════════════════════

function selectOrderForShipment(id, name, sarees, amount, status) {
  document.getElementById('shipmentOrderId').value = id;
  const summary = document.getElementById('shipmentOrderSummary');
  summary.style.display = 'block';
  summary.innerHTML = `
    <strong>Order #${id}</strong> — ${name}<br>
    <span style="font-size:12px;color:#6B6B6B;">${sarees} sarees | ₹${Number(amount).toLocaleString('en-IN')} | ${status}</span>
  `;
}

async function saveShipment() {
  const orderId = document.getElementById('shipmentOrderId').value;
  if (!orderId) {
    showToast('Please select an order first.', 'warning');
    return;
  }

  const data = {
    order_id: parseInt(orderId),
    courier_name: document.getElementById('courierName').value,
    tracking_number: document.getElementById('trackingNumber').value,
    shipment_date: document.getElementById('shipmentDate').value,
    notes: document.getElementById('shipmentNotes').value,
  };

  try {
    await apiCall('/api/shipments', 'POST', data);
    showToast('Shipment updated. Email sent to buyer. ✅');
    setTimeout(() => location.reload(), 800);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

// ═══════════════════════════════════════════════════
// USERS
// ═══════════════════════════════════════════════════

function openUserDrawer(user = null) {
  document.getElementById('userOverlay').classList.add('open');
  document.getElementById('userDrawer').classList.add('open');
  document.getElementById('userDrawerTitle').textContent = user ? 'Edit User' : 'Add User';

  if (user) {
    document.getElementById('userId').value = user.id;
    document.getElementById('userName').value = user.name;
    document.getElementById('userEmail').value = user.email;
    document.getElementById('userPhone').value = user.phone || '';
    document.getElementById('userRole').value = user.role;
    document.getElementById('userActive').value = user.is_active ? '1' : '0';
    document.getElementById('pwdHint').textContent = '(leave blank to keep current)';
    if (user.login_expiry) {
      document.getElementById('userExpiry').value = new Date(user.login_expiry).toISOString().slice(0, 16);
    }
    toggleExpiryField();
  } else {
    document.getElementById('userForm').reset();
    document.getElementById('userId').value = '';
    document.getElementById('pwdHint').textContent = '(required for new users)';
    toggleExpiryField();
  }
}

function closeUserDrawer() {
  document.getElementById('userOverlay').classList.remove('open');
  document.getElementById('userDrawer').classList.remove('open');
}

function editUser(user) {
  openUserDrawer(user);
}

function toggleExpiryField() {
  const role = document.getElementById('userRole').value;
  document.getElementById('expiryGroup').style.display = role === 'shop_owner' ? 'block' : 'none';
}

async function saveUser() {
  const id = document.getElementById('userId').value;
  const data = {
    name: document.getElementById('userName').value,
    email: document.getElementById('userEmail').value,
    phone: document.getElementById('userPhone').value,
    role: document.getElementById('userRole').value,
    is_active: parseInt(document.getElementById('userActive').value),
    login_expiry: document.getElementById('userExpiry').value || null,
  };

  const pwd = document.getElementById('userPassword').value;
  if (pwd) data.password = pwd;

  try {
    if (id) {
      await apiCall(`/api/users/${id}`, 'PUT', data);
      showToast('User updated successfully.');
    } else {
      if (!pwd) {
        showToast('Password is required for new users.', 'error');
        return;
      }
      await apiCall('/api/users', 'POST', data);
      showToast('User created successfully.');
    }
    closeUserDrawer();
    setTimeout(() => location.reload(), 500);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function deleteUser(id) {
  if (!confirm('Are you sure you want to delete this user?')) return;
  try {
    await apiCall(`/api/users/${id}`, 'DELETE');
    showToast('User deleted.');
    setTimeout(() => location.reload(), 500);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

// ═══════════════════════════════════════════════════
// COUNTDOWN CHIPS (Login Expiry)
// ═══════════════════════════════════════════════════

function updateCountdowns() {
  document.querySelectorAll('.countdown-chip').forEach(chip => {
    const expiry = new Date(chip.dataset.expiry);
    const now = new Date();
    const diff = expiry - now;

    const textEl = chip.querySelector('.countdown-text');
    if (diff <= 0) {
      textEl.textContent = 'Expired';
      chip.style.background = 'rgba(176,0,32,0.08)';
      chip.style.color = '#B00020';
    } else {
      const mins = Math.floor(diff / 60000);
      const secs = Math.floor((diff % 60000) / 1000);
      textEl.textContent = `${mins}m ${secs}s`;
    }
  });
}

// Update countdowns every second
setInterval(updateCountdowns, 1000);
document.addEventListener('DOMContentLoaded', updateCountdowns);
