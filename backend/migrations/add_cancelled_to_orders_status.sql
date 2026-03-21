-- Ensure MySQL can store 'cancelled' on orders.status.
-- If your column is ENUM without 'cancelled', the UPDATE in cancel() may
-- coerce to empty or wrong value, and APIs/clients can mis-read status.
--
-- Run once on your database (adjust schema name if needed):

USE shree_sarees;

ALTER TABLE orders
  MODIFY COLUMN status ENUM('pending','confirmed','shipped','delivered','cancelled')
  NOT NULL DEFAULT 'pending';
