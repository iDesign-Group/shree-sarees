-- Shree Sarees Database Schema
-- Run this script to create all tables

CREATE DATABASE IF NOT EXISTS shree_sarees;
USE shree_sarees;

-- Godowns
CREATE TABLE godowns (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  location VARCHAR(255)
);

-- Racks
CREATE TABLE racks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  godown_id INT,
  rack_number VARCHAR(20),
  FOREIGN KEY (godown_id) REFERENCES godowns(id)
);

-- Shelves
CREATE TABLE shelves (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rack_id INT,
  shelf_number VARCHAR(20),
  FOREIGN KEY (rack_id) REFERENCES racks(id)
);

-- Products
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_code VARCHAR(50) UNIQUE NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  set_size INT NOT NULL,
  price_per_saree DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Images (multiple per product)
CREATE TABLE product_images (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  image_path VARCHAR(500),
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Inventory (Inward Stock)
-- Note: total_sarees is computed at application level since MySQL generated columns
-- cannot reference other tables. We store it directly.
CREATE TABLE inventory (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  shelf_id INT,
  bundle_count INT NOT NULL,
  total_sarees INT NOT NULL,
  inward_date DATE NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (shelf_id) REFERENCES shelves(id)
);

-- Users
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(15),
  role ENUM('admin','broker','shop_owner') DEFAULT 'broker',
  password_hash VARCHAR(255) NOT NULL,
  login_expiry DATETIME NULL,
  is_active TINYINT DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  status ENUM('pending','confirmed','shipped','delivered') DEFAULT 'pending',
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total_sarees INT,
  total_amount DECIMAL(12,2),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Order Items
CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  bundles_ordered INT NOT NULL,
  sarees_count INT NOT NULL,
  price_per_saree_at_order DECIMAL(10,2),
  bundle_cost DECIMAL(12,2),
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Shipments
CREATE TABLE shipments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT UNIQUE,
  shipment_date DATE,
  courier_name VARCHAR(150),
  tracking_number VARCHAR(100),
  notes TEXT,
  notified_at DATETIME NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id)
);
