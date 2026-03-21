-- Store contact for delivery challan / communications
-- Run once on your MySQL database:

USE shree_sarees;

ALTER TABLE orders
  ADD COLUMN store_phone VARCHAR(32) NULL
  AFTER store_address;
