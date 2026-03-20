-- Run this migration to add store_name support

-- 1. Add store_name column to orders
ALTER TABLE orders ADD COLUMN store_name VARCHAR(255) NULL AFTER user_id;

-- 2. Create store_names table for autocomplete suggestions
CREATE TABLE IF NOT EXISTS store_names (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_store (user_id, name),
  FOREIGN KEY (fk_store_user) REFERENCES users(id) ON DELETE CASCADE
);
