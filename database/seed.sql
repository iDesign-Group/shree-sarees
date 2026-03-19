-- Shree Sarees Seed Data
USE shree_sarees;

-- =============================================
-- Godowns (4)
-- =============================================
INSERT INTO godowns (name, location) VALUES
('Godown A - Main Warehouse', 'Surat, Gujarat'),
('Godown B - East Wing', 'Surat, Gujarat'),
('Godown C - West Wing', 'Surat, Gujarat'),
('Godown D - Overflow Store', 'Surat, Gujarat');

-- =============================================
-- Racks (75 per godown = 300 total)
-- =============================================
DELIMITER //
CREATE PROCEDURE seed_racks_and_shelves()
BEGIN
  DECLARE g INT DEFAULT 1;
  DECLARE r INT DEFAULT 1;
  DECLARE s INT DEFAULT 1;
  DECLARE rack_id_val INT;

  WHILE g <= 4 DO
    SET r = 1;
    WHILE r <= 75 DO
      INSERT INTO racks (godown_id, rack_number) VALUES (g, CONCAT('G', g, '-R', LPAD(r, 3, '0')));
      SET rack_id_val = LAST_INSERT_ID();

      -- 6 shelves per rack
      SET s = 1;
      WHILE s <= 6 DO
        INSERT INTO shelves (rack_id, shelf_number) VALUES (rack_id_val, CONCAT('S', s));
        SET s = s + 1;
      END WHILE;

      SET r = r + 1;
    END WHILE;
    SET g = g + 1;
  END WHILE;
END //
DELIMITER ;

CALL seed_racks_and_shelves();
DROP PROCEDURE seed_racks_and_shelves;

-- =============================================
-- Sample Products (10)
-- =============================================
INSERT INTO products (product_code, product_name, set_size, price_per_saree) VALUES
('SS-BNR-001', 'Banarasi Silk Heritage', 6, 1250.00),
('SS-KNJ-002', 'Kanjivaram Classic Gold', 6, 1800.00),
('SS-PTL-003', 'Patola Double Ikat', 4, 2200.00),
('SS-CHN-004', 'Chanderi Cotton Elegance', 8, 650.00),
('SS-BNG-005', 'Bangalore Silk Premium', 6, 950.00),
('SS-MSR-006', 'Mysore Crepe Royal', 6, 780.00),
('SS-TUS-007', 'Tussar Silk Natural', 4, 1100.00),
('SS-SAM-008', 'Sambalpuri Ikat Weave', 6, 880.00),
('SS-BHG-009', 'Bhagalpuri Tussar Print', 8, 520.00),
('SS-GDW-010', 'Gadwal Handloom Special', 4, 1650.00);

-- =============================================
-- Admin User (password: Admin@123)
-- bcrypt hash for 'Admin@123' with 10 rounds
-- =============================================
INSERT INTO users (name, email, phone, role, password_hash, is_active) VALUES
('Admin', 'admin@shreesarees.com', '9876543210', 'admin', '$2b$10$PLACEHOLDER_HASH_REPLACE_ON_FIRST_RUN', 1);

-- =============================================
-- Sample Broker and Shop Owner
-- =============================================
INSERT INTO users (name, email, phone, role, password_hash, is_active) VALUES
('Rajesh Broker', 'rajesh@example.com', '9876543211', 'broker', '$2b$10$PLACEHOLDER_HASH_REPLACE_ON_FIRST_RUN', 1),
('Suresh Textiles', 'suresh@example.com', '9876543212', 'shop_owner', '$2b$10$PLACEHOLDER_HASH_REPLACE_ON_FIRST_RUN', 1);
