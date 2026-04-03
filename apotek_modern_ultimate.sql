-- =====================================================
-- DATABASE APOTEK MODERN - ULTIMATE EDITION
-- =====================================================
-- Versi: 3.0 Ultimate
-- Dibuat: April 2026
-- 
-- FITUR LENGKAP:
-- 1. Multi Payment (Tunai, QRIS, Debit, Credit Card, E-Wallet, BPJS)
-- 2. Batch & Expired Management dengan FEFO
-- 3. Pembelian Supplier (Tunai, Kredit 30/45/60, Konsinyasi)
-- 4. Manajemen Pasien dengan AI Reminder
-- 5. Pareto ABC Analysis (Klasifikasi A,B,C,D)
-- 6. AI Forecasting (Prediksi Penjualan)
-- 7. Auto Reorder System
-- 8. Time & Activity Tracking (Shift, Absensi)
-- 9. Drug Interaction Checker
-- 10. Audit Trail dengan Blockchain Hash
-- 11. Barcode/QR Scanner Integration
-- 12. Mobile App Ready API + Push Notification
-- 13. Real-time Dashboard dengan Caching
-- 14. Data Warehouse & BI Integration
-- 15. Multi-language Support
-- 16. Backup & Recovery Automation
-- =====================================================

-- Drop database jika ada (HATI-HATI!)
DROP DATABASE IF EXISTS `apotek_modern`;
CREATE DATABASE `apotek_modern` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `apotek_modern`;

-- =====================================================
-- PART 1: TABEL MASTER DATA
-- =====================================================

-- Kategori Obat
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(64) NOT NULL,
  `description` text,
  `parent_id` int(11) DEFAULT NULL,
  `classification` enum('OTC','OTB','OOP','Psikotropika','Narkotika') DEFAULT 'OTC',
  `requires_prescription` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Satuan Obat
CREATE TABLE `units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(10) NOT NULL,
  `name` varchar(32) NOT NULL,
  `is_base_unit` tinyint(1) DEFAULT '1',
  `conversion_factor` decimal(10,2) DEFAULT '1.00',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Supplier / PBF
CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(128) NOT NULL,
  `type` enum('PBF','Distributor','Apotek','Lainnya') DEFAULT 'PBF',
  `contact_person` varchar(100) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text,
  `tax_id` varchar(50) DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `bank_account` varchar(50) DEFAULT NULL,
  `payment_term` int(11) DEFAULT '30',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `tax_id` (`tax_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Termin Pembayaran ke Supplier
CREATE TABLE `payment_terms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `type` enum('Cash','Credit','Consignment') NOT NULL,
  `description` text,
  `default_due_days` int(11) DEFAULT '0',
  `interest_rate` decimal(5,2) DEFAULT '0.00',
  `late_fee_percentage` decimal(5,2) DEFAULT '0.00',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Kontrak dengan Supplier
CREATE TABLE `supplier_contracts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(11) NOT NULL,
  `contract_number` varchar(50) NOT NULL,
  `contract_date` date NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `payment_term_id` int(11) NOT NULL,
  `consignment_period` int(11) DEFAULT NULL,
  `consignment_settlement_day` int(11) DEFAULT NULL,
  `credit_limit` decimal(19,2) DEFAULT NULL,
  `discount_percentage` decimal(5,2) DEFAULT '0.00',
  `special_terms` text,
  `status` enum('Active','Expired','Terminated') DEFAULT 'Active',
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `contract_number` (`contract_number`),
  KEY `supplier_id` (`supplier_id`),
  KEY `payment_term_id` (`payment_term_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Master Obat
CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `barcode` varchar(50) DEFAULT NULL,
  `name` varchar(128) NOT NULL,
  `generic_name` varchar(128) DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `strength` varchar(50) DEFAULT NULL,
  `form` varchar(50) DEFAULT NULL,
  `manufacturer` varchar(128) DEFAULT NULL,
  `min_stock` int(11) DEFAULT '10',
  `max_stock` int(11) DEFAULT '500',
  `reorder_point` int(11) DEFAULT '20',
  `base_price` decimal(19,2) NOT NULL,
  `selling_price` decimal(19,2) NOT NULL,
  `discount_percentage` decimal(5,2) DEFAULT '0.00',
  `tax_percentage` decimal(5,2) DEFAULT '11.00',
  `requires_prescription` tinyint(1) DEFAULT '0',
  `is_controlled` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `barcode` (`barcode`),
  KEY `category_id` (`category_id`),
  KEY `unit_id` (`unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Batch/Lot Obat (untuk FEFO)
CREATE TABLE `product_batches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL,
  `batch_number` varchar(50) NOT NULL,
  `manufacturing_date` date DEFAULT NULL,
  `expiry_date` date NOT NULL,
  `purchase_price` decimal(19,2) NOT NULL,
  `selling_price` decimal(19,2) NOT NULL,
  `quantity_initial` int(11) NOT NULL,
  `quantity_on_hand` int(11) NOT NULL,
  `received_date` date NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `batch_number` (`batch_number`),
  KEY `product_id` (`product_id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `expiry_date` (`expiry_date`),
  KEY `idx_fefo` (`product_id`, `expiry_date`, `quantity_on_hand`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Pelanggan Umum
CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(128) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text,
  `member_number` varchar(50) DEFAULT NULL,
  `member_points` int(11) DEFAULT '0',
  `member_tier` enum('Regular','Silver','Gold','Platinum') DEFAULT 'Regular',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `member_number` (`member_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Pasien Lengkap dengan Riwayat Medis
CREATE TABLE `patients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_number` varchar(50) NOT NULL,
  `nik` varchar(20),
  `name` varchar(128) NOT NULL,
  `date_of_birth` date,
  `age` int(11) GENERATED ALWAYS AS (TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) STORED,
  `gender` enum('L','P') DEFAULT NULL,
  `blood_type` enum('A','B','AB','O','Unknown') DEFAULT 'Unknown',
  `phone` varchar(20) NOT NULL,
  `phone_alternative` varchar(20),
  `email` varchar(100),
  `address` text,
  `allergy_info` text,
  `chronic_diseases` json,
  `regular_medications` json,
  `blood_pressure` varchar(20),
  `blood_sugar` varchar(20),
  `cholesterol` varchar(20),
  `weight_kg` decimal(5,2),
  `height_cm` decimal(5,2),
  `bmi` decimal(5,2) GENERATED ALWAYS AS (weight_kg / POW(height_cm/100, 2)) STORED,
  `insurance_type` enum('BPJS','Private','None') DEFAULT 'None',
  `insurance_number` varchar(50),
  `insurance_provider` varchar(100),
  `insurance_expiry` date,
  `is_active` tinyint(1) DEFAULT '1',
  `last_visit_date` datetime,
  `total_visits` int(11) DEFAULT '0',
  `total_spent` decimal(19,2) DEFAULT '0.00',
  `preferred_communication` enum('WhatsApp','SMS','Email','Phone') DEFAULT 'WhatsApp',
  `consent_to_reminder` tinyint(1) DEFAULT '1',
  `notes` text,
  `created_by` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `patient_number` (`patient_number`),
  UNIQUE KEY `nik` (`nik`),
  KEY `phone` (`phone`),
  KEY `email` (`email`),
  KEY `name` (`name`),
  KEY `last_visit_date` (`last_visit_date`),
  KEY `is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Resep Dokter
CREATE TABLE `prescriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prescription_number` varchar(50) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `doctor_name` varchar(128) NOT NULL,
  `doctor_sip` varchar(50),
  `clinic_name` varchar(128),
  `prescription_date` date NOT NULL,
  `is_compounding` tinyint(1) DEFAULT '0',
  `compounding_fee` decimal(19,2) DEFAULT '0.00',
  `status` enum('Pending','Processed','Completed','Cancelled') DEFAULT 'Pending',
  `notes` text,
  `file_path` varchar(255),
  `created_by` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prescription_number` (`prescription_number`),
  KEY `patient_id` (`patient_id`),
  FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Riwayat Pengobatan Pasien
CREATE TABLE `patient_medications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `prescription_id` int(11),
  `product_id` int(11) NOT NULL,
  `dosage` varchar(100),
  `frequency` varchar(100),
  `duration_days` int(11),
  `start_date` date,
  `end_date` date,
  `instructions` text,
  `is_completed` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  KEY `product_id` (`product_id`),
  FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Riwayat Kunjungan Pasien
CREATE TABLE `patient_visits` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `visit_date` datetime NOT NULL,
  `sale_id` int(11),
  `complaint` text,
  `diagnosis` text,
  `blood_pressure` varchar(20),
  `temperature` decimal(4,1),
  `notes` text,
  `follow_up_date` date,
  `created_by` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  KEY `visit_date` (`visit_date`),
  FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Metode Pembayaran (QRIS, Debit, CC, dll)
CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `type` enum('Cash','QRIS','Debit','Credit','BPJS','Transfer','E-Wallet') NOT NULL,
  `icon` varchar(100) DEFAULT NULL,
  `additional_fee` decimal(10,2) DEFAULT '0.00',
  `fee_percentage` decimal(5,2) DEFAULT '0.00',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Cabang Apotek
CREATE TABLE `outlets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(128) NOT NULL,
  `address` text,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `tax_id` varchar(50) DEFAULT NULL,
  `is_head_office` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Pengguna Sistem
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `outlet_id` int(11) DEFAULT NULL,
  `role` enum('admin','manager','pharmacist','cashier','warehouse') NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `outlet_id` (`outlet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Shift Kerja
CREATE TABLE `work_shifts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `break_start` time DEFAULT NULL,
  `break_end` time DEFAULT NULL,
  `overtime_rate` decimal(10,2) DEFAULT '0.00',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PART 2: TABEL TRANSAKSI
-- =====================================================

-- Header Pembelian
CREATE TABLE `purchase_headers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purchase_number` varchar(50) NOT NULL,
  `supplier_id` int(11) NOT NULL,
  `supplier_contract_id` int(11) DEFAULT NULL,
  `payment_term_id` int(11) NOT NULL,
  `purchase_type` enum('Consignment','Cash','Credit') NOT NULL,
  `purchase_date` date NOT NULL,
  `received_date` date DEFAULT NULL,
  `invoice_number_supplier` varchar(100) DEFAULT NULL,
  `invoice_date_supplier` date DEFAULT NULL,
  `subtotal` decimal(19,2) NOT NULL,
  `discount_amount` decimal(19,2) DEFAULT '0.00',
  `tax_amount` decimal(19,2) DEFAULT '0.00',
  `shipping_cost` decimal(19,2) DEFAULT '0.00',
  `other_costs` decimal(19,2) DEFAULT '0.00',
  `grand_total` decimal(19,2) NOT NULL,
  `due_date` date DEFAULT NULL,
  `interest_amount` decimal(19,2) DEFAULT '0.00',
  `late_fee_amount` decimal(19,2) DEFAULT '0.00',
  `consignment_status` enum('Received','Partial Sold','Fully Sold','Returned') DEFAULT 'Received',
  `consignment_settlement_date` date DEFAULT NULL,
  `consignment_paid_amount` decimal(19,2) DEFAULT '0.00',
  `payment_status` enum('Unpaid','Partial','Paid','Overdue') DEFAULT 'Unpaid',
  `payment_date` date DEFAULT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `notes` text,
  `created_by` int(11) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `purchase_number` (`purchase_number`),
  KEY `supplier_id` (`supplier_id`),
  KEY `payment_term_id` (`payment_term_id`),
  KEY `purchase_type` (`purchase_type`),
  KEY `payment_status` (`payment_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Detail Pembelian
CREATE TABLE `purchase_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purchase_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(19,2) NOT NULL,
  `discount_percentage` decimal(5,2) DEFAULT '0.00',
  `discount_amount` decimal(19,2) DEFAULT '0.00',
  `subtotal` decimal(19,2) NOT NULL,
  `consignment_sold_quantity` int(11) DEFAULT '0',
  `consignment_returned_quantity` int(11) DEFAULT '0',
  `consignment_settled_quantity` int(11) DEFAULT '0',
  `consignment_settlement_status` enum('Pending','Partial','Completed') DEFAULT 'Pending',
  `batch_number` varchar(50) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `manufacturing_date` date DEFAULT NULL,
  `received_quantity` int(11) DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `purchase_id` (`purchase_id`),
  KEY `product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Pembayaran Pembelian
CREATE TABLE `purchase_payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purchase_id` int(11) NOT NULL,
  `payment_number` varchar(50) NOT NULL,
  `payment_date` date NOT NULL,
  `amount` decimal(19,2) NOT NULL,
  `payment_method_id` int(11) NOT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `bank_account` varchar(50) DEFAULT NULL,
  `notes` text,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_number` (`payment_number`),
  KEY `purchase_id` (`purchase_id`),
  KEY `payment_method_id` (`payment_method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Header Penjualan
CREATE TABLE `sales_headers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(50) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `prescription_id` int(11) DEFAULT NULL,
  `cashier_id` int(11) NOT NULL,
  `transaction_date` datetime NOT NULL,
  `subtotal` decimal(19,2) NOT NULL,
  `discount_amount` decimal(19,2) DEFAULT '0.00',
  `tax_amount` decimal(19,2) DEFAULT '0.00',
  `service_fee` decimal(19,2) DEFAULT '0.00',
  `grand_total` decimal(19,2) NOT NULL,
  `payment_method_id` int(11) NOT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `payment_status` enum('Pending','Paid','Failed','Refunded') DEFAULT 'Pending',
  `payment_date` datetime DEFAULT NULL,
  `qr_code_data` text,
  `e_wallet_transaction_id` varchar(100) DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `patient_id` (`patient_id`),
  KEY `customer_id` (`customer_id`),
  KEY `prescription_id` (`prescription_id`),
  KEY `cashier_id` (`cashier_id`),
  KEY `payment_method_id` (`payment_method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Detail Penjualan
CREATE TABLE `sales_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sale_id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price_at_sale` decimal(19,2) NOT NULL,
  `discount_amount` decimal(19,2) DEFAULT '0.00',
  `subtotal` decimal(19,2) NOT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sale_id` (`sale_id`),
  KEY `batch_id` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log Pembayaran
CREATE TABLE `payment_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sale_id` int(11) NOT NULL,
  `payment_method_id` int(11) NOT NULL,
  `amount` decimal(19,2) NOT NULL,
  `cash_amount` decimal(19,2) DEFAULT NULL,
  `change_amount` decimal(19,2) DEFAULT NULL,
  `qr_code_data` text,
  `qr_code_scan_time` datetime DEFAULT NULL,
  `debit_card_last4` varchar(4) DEFAULT NULL,
  `debit_card_bank` varchar(50) DEFAULT NULL,
  `credit_card_last4` varchar(4) DEFAULT NULL,
  `credit_card_bank` varchar(50) DEFAULT NULL,
  `credit_card_installment` int(11) DEFAULT '1',
  `e_wallet_provider` varchar(50) DEFAULT NULL,
  `e_wallet_transaction_id` varchar(100) DEFAULT NULL,
  `bpjs_claim_number` varchar(50) DEFAULT NULL,
  `bpjs_verification_status` enum('Pending','Verified','Rejected') DEFAULT 'Pending',
  `transaction_response` json DEFAULT NULL,
  `status` enum('Success','Failed','Pending') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sale_id` (`sale_id`),
  KEY `payment_method_id` (`payment_method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Settlement Konsinyasi
CREATE TABLE `consignment_settlements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purchase_id` int(11) NOT NULL,
  `settlement_number` varchar(50) NOT NULL,
  `settlement_date` date NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `total_sold_amount` decimal(19,2) NOT NULL,
  `total_returned_amount` decimal(19,2) DEFAULT '0.00',
  `commission_amount` decimal(19,2) DEFAULT '0.00',
  `settlement_amount` decimal(19,2) NOT NULL,
  `status` enum('Pending','Paid','Cancelled') DEFAULT 'Pending',
  `payment_date` date DEFAULT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `notes` text,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `settlement_number` (`settlement_number`),
  KEY `purchase_id` (`purchase_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Penjualan Konsinyasi
CREATE TABLE `consignment_sales` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purchase_detail_id` int(11) NOT NULL,
  `sale_detail_id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `selling_price` decimal(19,2) NOT NULL,
  `cost_price` decimal(19,2) NOT NULL,
  `margin` decimal(19,2) NOT NULL,
  `settlement_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `purchase_detail_id` (`purchase_detail_id`),
  KEY `sale_detail_id` (`sale_detail_id`),
  KEY `batch_id` (`batch_id`),
  KEY `settlement_id` (`settlement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log Pergerakan Stok
CREATE TABLE `inventory_movements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` int(11) NOT NULL,
  `movement_type` enum('Purchase','Sale','Return','Adjustment','Expired','Damaged') NOT NULL,
  `quantity` int(11) NOT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `previous_stock` int(11) NOT NULL,
  `new_stock` int(11) NOT NULL,
  `notes` text,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `batch_id` (`batch_id`),
  KEY `reference_type_reference_id` (`reference_type`, `reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Saldo Supplier
CREATE TABLE `supplier_balances` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(11) NOT NULL,
  `transaction_date` date NOT NULL,
  `transaction_type` enum('Purchase','Payment','Credit Note','Debit Note','Consignment Settlement') NOT NULL,
  `reference_id` int(11) NOT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `debit` decimal(19,2) DEFAULT '0.00',
  `credit` decimal(19,2) DEFAULT '0.00',
  `balance` decimal(19,2) NOT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `reference_type_reference_id` (`reference_type`, `reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PART 3: AI & ANALYTICS
-- =====================================================

-- Prediksi Penjualan (AI Forecasting)
CREATE TABLE `sales_forecast` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `forecast_date` date NOT NULL,
  `forecast_quantity` int(11) NOT NULL,
  `forecast_lower_bound` int(11),
  `forecast_upper_bound` int(11),
  `confidence_level` decimal(5,2) DEFAULT '95.00',
  `model_used` enum('ARIMA','Prophet','LSTM','MovingAverage') DEFAULT 'MovingAverage',
  `seasonality_factor` decimal(5,2),
  `trend_direction` enum('Up','Down','Stable'),
  `actual_quantity` int(11),
  `accuracy_percentage` decimal(5,2),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `forecast_date` (`forecast_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Faktor Eksternal (Liburan, Cuaca, dll)
CREATE TABLE `external_factors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `factor_date` date NOT NULL,
  `factor_type` enum('Holiday','Weather','Epidemic','Promotion','Competitor') NOT NULL,
  `factor_name` varchar(100),
  `impact_multiplier` decimal(5,2) DEFAULT '1.00',
  `affected_products` json,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `factor_date` (`factor_date`),
  KEY `factor_type` (`factor_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Klasifikasi Pareto (ABC Analysis)
CREATE TABLE `product_classification` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `analysis_period` date NOT NULL,
  `total_sales_value` decimal(19,2) DEFAULT '0.00',
  `total_sales_quantity` int(11) DEFAULT '0',
  `sales_percentage` decimal(10,2) DEFAULT '0.00',
  `cumulative_percentage` decimal(10,2) DEFAULT '0.00',
  `pareto_class` enum('A','B','C','D') DEFAULT NULL,
  `classification_reason` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `analysis_period` (`analysis_period`),
  KEY `pareto_class` (`pareto_class`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rekomendasi Stok berdasarkan Pareto
CREATE TABLE `rekomendasi_stok` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `pareto_class` enum('A','B','C','D') NOT NULL,
  `recommended_min_stock` int(11) DEFAULT NULL,
  `recommended_max_stock` int(11) DEFAULT NULL,
  `service_level` enum('High','Medium','Low') DEFAULT NULL,
  `safety_stock_days` int(11) DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Auto Reorder Log
CREATE TABLE `auto_reorder_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `reorder_trigger` enum('MinStock','Forecast','Seasonal') NOT NULL,
  `current_stock` int(11),
  `reorder_quantity` int(11),
  `recommended_supplier_id` int(11),
  `estimated_cost` decimal(19,2),
  `status` enum('Pending','Approved','Cancelled','Ordered') DEFAULT 'Pending',
  `po_generated` tinyint(1) DEFAULT '0',
  `po_number` varchar(50),
  `checked_by` int(11),
  `checked_at` datetime,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Real-time Metrics
CREATE TABLE `realtime_metrics` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `metric_name` varchar(50) NOT NULL,
  `metric_value` decimal(19,2),
  `metric_unit` varchar(20),
  `outlet_id` int(11),
  `recorded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `metric_name` (`metric_name`),
  KEY `recorded_at` (`recorded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dashboard Cache
CREATE TABLE `dashboard_cache` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cache_key` varchar(100) NOT NULL,
  `cache_value` json NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cache_key` (`cache_key`),
  KEY `expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PART 4: REMINDER SYSTEM
-- =====================================================

-- Pengingat Pasien (AI Reminder)
CREATE TABLE `reminders` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `reminder_type` enum('Medication','Refill','Appointment','Checkup','Vaccination','Birthday','General') NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text,
  `reminder_date` date NOT NULL,
  `reminder_time` time,
  `reminder_datetime` datetime GENERATED ALWAYS AS (CONCAT(reminder_date, ' ', reminder_time)) STORED,
  `frequency` enum('OneTime','Daily','Weekly','Monthly','Yearly') DEFAULT 'OneTime',
  `repeat_every_days` int(11),
  `repeat_until_date` date,
  `priority` enum('Low','Medium','High','Urgent') DEFAULT 'Medium',
  `communication_channel` enum('WhatsApp','SMS','Email','Push','All') DEFAULT 'WhatsApp',
  `is_sent` tinyint(1) DEFAULT '0',
  `sent_at` datetime,
  `is_confirmed` tinyint(1) DEFAULT '0',
  `confirmed_at` datetime,
  `is_cancelled` tinyint(1) DEFAULT '0',
  `cancelled_reason` text,
  `related_prescription_id` int(11),
  `related_sale_id` int(11),
  `created_by` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  KEY `reminder_type` (`reminder_type`),
  KEY `reminder_datetime` (`reminder_datetime`),
  KEY `is_sent` (`is_sent`),
  FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log Pengiriman Reminder
CREATE TABLE `reminder_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `reminder_id` bigint(20) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `sent_channel` varchar(20),
  `sent_to` varchar(100),
  `message_sent` text,
  `response_status` varchar(50),
  `response_message` text,
  `error_message` text,
  `sent_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `reminder_id` (`reminder_id`),
  KEY `patient_id` (`patient_id`),
  KEY `sent_at` (`sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PART 5: TIME & ACTIVITY TRACKING
-- =====================================================

-- Absensi Karyawan
CREATE TABLE `user_attendance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `shift_id` int(11) DEFAULT NULL,
  `check_in_time` datetime,
  `check_out_time` datetime,
  `check_in_latitude` varchar(50),
  `check_in_longitude` varchar(50),
  `check_out_latitude` varchar(50),
  `check_out_longitude` varchar(50),
  `work_duration_minutes` int(11) DEFAULT '0',
  `overtime_minutes` int(11) DEFAULT '0',
  `late_minutes` int(11) DEFAULT '0',
  `status` enum('Present','Absent','Late','Leave','Holiday','Sick') DEFAULT 'Present',
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_date` (`user_id`, `attendance_date`),
  KEY `user_id` (`user_id`),
  KEY `shift_id` (`shift_id`),
  KEY `attendance_date` (`attendance_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log Aktivitas Karyawan
CREATE TABLE `user_activities` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `activity_date` date NOT NULL,
  `activity_time` datetime NOT NULL,
  `activity_type` enum('Login','Logout','StartShift','EndShift','BreakStart','BreakEnd','Transaction','Void','Return','StockOpname','PurchaseOrder','Other') NOT NULL,
  `activity_description` text,
  `reference_type` varchar(50),
  `reference_id` int(11),
  `duration_minutes` int(11) DEFAULT '0',
  `ip_address` varchar(45),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `activity_date` (`activity_date`),
  KEY `activity_type` (`activity_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rekap Kerja Harian
CREATE TABLE `daily_work_summary` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `summary_date` date NOT NULL,
  `total_work_hours` decimal(10,2) DEFAULT '0.00',
  `total_overtime_hours` decimal(10,2) DEFAULT '0.00',
  `total_transactions` int(11) DEFAULT '0',
  `total_sales_value` decimal(19,2) DEFAULT '0.00',
  `total_items_sold` int(11) DEFAULT '0',
  `total_void_count` int(11) DEFAULT '0',
  `login_time` datetime,
  `logout_time` datetime,
  `status` enum('Complete','Incomplete','Absent') DEFAULT 'Complete',
  `performance_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_date` (`user_id`, `summary_date`),
  KEY `user_id` (`user_id`),
  KEY `summary_date` (`summary_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PART 6: SECURITY & INTEGRATION
-- =====================================================

-- Barcode Master
CREATE TABLE `barcode_master` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `barcode` varchar(50) NOT NULL,
  `barcode_type` enum('EAN13','UPC','QR','Code128','Datamatrix') DEFAULT 'EAN13',
  `reference_type` enum('Product','Batch','Prescription','Customer','Patient') NOT NULL,
  `reference_id` int(11) NOT NULL,
  `is_primary` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `barcode` (`barcode`),
  KEY `reference_type_reference_id` (`reference_type`, `reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log Scanning
CREATE TABLE `scan_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `scanned_barcode` varchar(50) NOT NULL,
  `scan_result` json,
  `scan_status` enum('Found','NotFound','Error') DEFAULT 'Found',
  `scanned_by` int(11),
  `scanned_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `device_info` varchar(255),
  `ip_address` varchar(45),
  PRIMARY KEY (`id`),
  KEY `scanned_barcode` (`scanned_barcode`),
  KEY `scanned_at` (`scanned_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- API Tokens untuk Mobile App
CREATE TABLE `api_tokens` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `device_id` varchar(255),
  `device_name` varchar(100),
  `device_type` enum('iOS','Android','Web') DEFAULT 'Web',
  `fcm_token` text,
  `last_used_at` datetime,
  `expires_at` datetime,
  `is_revoked` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Push Notifications
CREATE TABLE `push_notifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `notification_type` enum('StockAlert','ExpiryAlert','Promotion','System','Reminder') NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text,
  `data` json,
  `target_user_id` int(11),
  `target_role` varchar(50),
  `is_read` tinyint(1) DEFAULT '0',
  `read_at` datetime,
  `sent_at` datetime,
  `delivered_at` datetime,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `target_user_id` (`target_user_id`),
  KEY `is_read` (`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Audit Trail dengan Blockchain Hash
CREATE TABLE `audit_blockchain` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(50) NOT NULL,
  `record_id` int(11) NOT NULL,
  `action` enum('INSERT','UPDATE','DELETE') NOT NULL,
  `old_hash` varchar(64),
  `new_hash` varchar(64) NOT NULL,
  `block_hash` varchar(64) NOT NULL,
  `previous_block_hash` varchar(64),
  `user_id` int(11),
  `ip_address` varchar(45),
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `table_name_record_id` (`table_name`, `record_id`),
  KEY `block_hash` (`block_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Drug Interactions
CREATE TABLE `drug_interactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `drug1_id` int(11) NOT NULL,
  `drug2_id` int(11) NOT NULL,
  `severity` enum('Mild','Moderate','Severe','Contraindicated') NOT NULL,
  `description` text,
  `symptoms` text,
  `recommendation` text,
  `references` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `drug1_id` (`drug1_id`),
  KEY `drug2_id` (`drug2_id`),
  FOREIGN KEY (`drug1_id`) REFERENCES `products` (`id`),
  FOREIGN KEY (`drug2_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Multi-language Support
CREATE TABLE `translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `language` enum('id','en','zh','ar') NOT NULL DEFAULT 'id',
  `key_text` varchar(100) NOT NULL,
  `translated_text` text NOT NULL,
  `context` varchar(50),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `language_key` (`language`, `key_text`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Backup Log
CREATE TABLE `backup_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `backup_name` varchar(255) NOT NULL,
  `backup_type` enum('Full','Incremental','Differential') NOT NULL,
  `backup_size` bigint(20),
  `backup_location` varchar(500),
  `checksum` varchar(64),
  `status` enum('Success','Failed','InProgress') DEFAULT 'InProgress',
  `error_message` text,
  `started_at` datetime,
  `completed_at` datetime,
  `created_by` varchar(100),
  PRIMARY KEY (`id`),
  KEY `backup_name` (`backup_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PART 7: LOG PENJUALAN (AUDIT TRAIL)
-- =====================================================

-- Log Aktivitas Penjualan
CREATE TABLE `sales_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `log_number` varchar(50) NOT NULL,
  `sale_id` int(11) DEFAULT NULL,
  `action_type` enum('CREATE','UPDATE','DELETE','VOID','PRINT','REFUND','PAYMENT','CANCEL') NOT NULL,
  `action_description` text,
  `old_data` json DEFAULT NULL,
  `new_data` json DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `user_name` varchar(100),
  `user_role` varchar(50),
  `ip_address` varchar(45),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `log_number` (`log_number`),
  KEY `sale_id` (`sale_id`),
  KEY `action_type` (`action_type`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log Pembatalan Penjualan
CREATE TABLE `sales_void_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `void_number` varchar(50) NOT NULL,
  `original_sale_id` int(11) NOT NULL,
  `original_invoice_number` varchar(50),
  `void_reason` enum('Customer Request','Wrong Item','Wrong Quantity','Wrong Price','System Error','Other') NOT NULL,
  `void_reason_detail` text,
  `void_amount` decimal(19,2) NOT NULL,
  `restock_items` tinyint(1) DEFAULT '1',
  `voided_by` int(11) NOT NULL,
  `voided_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `void_number` (`void_number`),
  KEY `original_sale_id` (`original_sale_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log Pembayaran
CREATE TABLE `payment_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `log_number` varchar(50) NOT NULL,
  `sale_id` int(11) NOT NULL,
  `invoice_number` varchar(50),
  `action_type` enum('INITIATE','PROCESS','SUCCESS','FAILED','REFUND','CANCEL') NOT NULL,
  `payment_method` varchar(50),
  `amount` decimal(19,2),
  `response_code` varchar(50),
  `response_message` text,
  `response_data` json,
  `user_id` int(11),
  `ip_address` varchar(45),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `log_number` (`log_number`),
  KEY `sale_id` (`sale_id`),
  KEY `action_type` (`action_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PART 8: DATA WAREHOUSE (BI)
-- =====================================================

-- Fact Sales untuk BI
CREATE TABLE `fact_sales` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `date_key` int(11) NOT NULL COMMENT 'YYYYMMDD',
  `product_id` int(11) NOT NULL,
  `outlet_id` int(11),
  `patient_id` int(11),
  `quantity` int(11),
  `sales_amount` decimal(19,2),
  `cost_amount` decimal(19,2),
  `profit_amount` decimal(19,2),
  `discount_amount` decimal(19,2),
  `payment_method_id` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `date_key` (`date_key`),
  KEY `product_id` (`product_id`),
  KEY `outlet_id` (`outlet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dimension Time
CREATE TABLE `dim_time` (
  `date_key` int(11) NOT NULL,
  `full_date` date NOT NULL,
  `year` smallint(4),
  `quarter` tinyint(1),
  `month` tinyint(2),
  `month_name` varchar(10),
  `week` tinyint(2),
  `day` tinyint(2),
  `day_name` varchar(10),
  `is_weekend` tinyint(1),
  `is_holiday` tinyint(1),
  PRIMARY KEY (`date_key`),
  UNIQUE KEY `full_date` (`full_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PART 9: VIEWS (untuk Laporan)
-- =====================================================

-- View: Obat Mendekati Expired
CREATE VIEW `view_expiring_soon` AS
SELECT 
  pb.id as batch_id,
  p.code as product_code,
  p.name as product_name,
  pb.batch_number,
  pb.expiry_date,
  DATEDIFF(pb.expiry_date, CURDATE()) as days_left,
  pb.quantity_on_hand,
  CASE 
    WHEN DATEDIFF(pb.expiry_date, CURDATE()) <= 30 THEN 'Critical'
    WHEN DATEDIFF(pb.expiry_date, CURDATE()) <= 90 THEN 'Warning'
    ELSE 'Normal'
  END as status
FROM product_batches pb
JOIN products p ON pb.product_id = p.id
WHERE pb.expiry_date >= CURDATE()
  AND pb.quantity_on_hand > 0
ORDER BY pb.expiry_date ASC;

-- View: Stok Kritis
CREATE VIEW `view_critical_stock` AS
SELECT 
  p.id as product_id,
  p.code as product_code,
  p.name as product_name,
  COALESCE(SUM(pb.quantity_on_hand), 0) as current_stock,
  p.min_stock,
  p.reorder_point,
  CASE 
    WHEN COALESCE(SUM(pb.quantity_on_hand), 0) <= p.min_stock THEN 'Reorder Required'
    WHEN COALESCE(SUM(pb.quantity_on_hand), 0) <= p.reorder_point THEN 'Warning'
    ELSE 'OK'
  END as status
FROM products p
LEFT JOIN product_batches pb ON p.id = pb.product_id AND pb.expiry_date > CURDATE()
GROUP BY p.id, p.code, p.name, p.min_stock, p.reorder_point
HAVING current_stock <= p.reorder_point;

-- View: Hutang ke Supplier
CREATE VIEW `view_supplier_credit` AS
SELECT 
  s.id as supplier_id,
  s.name as supplier_name,
  COUNT(CASE WHEN ph.payment_status IN ('Unpaid', 'Partial') THEN 1 END) as outstanding_invoices,
  SUM(CASE WHEN ph.payment_status IN ('Unpaid', 'Partial') THEN ph.grand_total - IFNULL(pp.paid_amount, 0) ELSE 0 END) as total_outstanding,
  SUM(CASE WHEN ph.due_date < CURDATE() AND ph.payment_status != 'Paid' THEN ph.grand_total - IFNULL(pp.paid_amount, 0) ELSE 0 END) as overdue_amount,
  MIN(CASE WHEN ph.payment_status IN ('Unpaid', 'Partial') THEN ph.due_date END) as nearest_due_date
FROM suppliers s
LEFT JOIN purchase_headers ph ON s.id = ph.supplier_id AND ph.purchase_type = 'Credit'
LEFT JOIN (
  SELECT purchase_id, SUM(amount) as paid_amount
  FROM purchase_payments
  GROUP BY purchase_id
) pp ON ph.id = pp.purchase_id
GROUP BY s.id, s.name
HAVING total_outstanding > 0;

-- View: Hasil Pareto Terbaru
CREATE VIEW `view_pareto_analysis` AS
SELECT 
  p.code as product_code,
  p.name as product_name,
  pc.pareto_class,
  pc.total_sales_value,
  ROUND(pc.sales_percentage, 2) as sales_percentage,
  ROUND(pc.cumulative_percentage, 2) as cumulative_percentage,
  CASE 
    WHEN pc.pareto_class = 'A' THEN '🔥 Prioritas Tertinggi - 70% penjualan'
    WHEN pc.pareto_class = 'B' THEN '⭐ Prioritas Menengah - 20% penjualan'
    WHEN pc.pareto_class = 'C' THEN '📦 Prioritas Rendah - 10% penjualan'
    ELSE '💤 Slow Moving'
  END as recommendation
FROM product_classification pc
JOIN products p ON pc.product_id = p.id
WHERE pc.analysis_period = (SELECT MAX(analysis_period) FROM product_classification)
ORDER BY FIELD(pc.pareto_class, 'A', 'B', 'C', 'D');

-- View: Pasien dengan Reminder Aktif
CREATE VIEW `view_patients_with_reminders` AS
SELECT 
  p.id,
  p.patient_number,
  p.name,
  p.phone,
  p.preferred_communication,
  COUNT(r.id) as total_reminders,
  COUNT(CASE WHEN r.is_sent = 0 AND r.reminder_date >= CURDATE() THEN 1 END) as pending_reminders,
  MIN(CASE WHEN r.is_sent = 0 AND r.reminder_date >= CURDATE() THEN r.reminder_date END) as next_reminder_date,
  p.last_visit_date,
  DATEDIFF(CURDATE(), p.last_visit_date) as days_since_last_visit
FROM patients p
LEFT JOIN reminders r ON p.id = r.patient_id
WHERE p.consent_to_reminder = 1
GROUP BY p.id, p.patient_number, p.name, p.phone, p.preferred_communication, p.last_visit_date
HAVING pending_reminders > 0 OR days_since_last_visit > 30;

-- View: Dashboard Ringkasan
CREATE VIEW `view_dashboard_summary` AS
SELECT 'today_sales' as metric, 
       COALESCE((SELECT metric_value FROM realtime_metrics WHERE metric_name = 'today_sales' ORDER BY recorded_at DESC LIMIT 1), 0) as value, 
       'IDR' as unit
UNION ALL
SELECT 'today_transactions', 
       COALESCE((SELECT metric_value FROM realtime_metrics WHERE metric_name = 'today_transactions' ORDER BY recorded_at DESC LIMIT 1), 0), 
       'transactions'
UNION ALL
SELECT 'expiring_soon', 
       COALESCE((SELECT metric_value FROM realtime_metrics WHERE metric_name = 'expiring_soon' ORDER BY recorded_at DESC LIMIT 1), 0), 
       'items'
UNION ALL
SELECT 'critical_stock', 
       COALESCE((SELECT metric_value FROM realtime_metrics WHERE metric_name = 'critical_stock' ORDER BY recorded_at DESC LIMIT 1), 0), 
       'products';

-- =====================================================
-- PART 10: STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure Update Stok FEFO
CREATE PROCEDURE `sp_update_stock_fefo`(
  IN p_product_id INT,
  IN p_quantity INT,
  IN p_movement_type VARCHAR(20),
  IN p_reference_type VARCHAR(50),
  IN p_reference_id INT,
  IN p_user_id INT
)
BEGIN
  DECLARE v_remaining_quantity INT;
  DECLARE v_batch_id INT;
  DECLARE v_batch_quantity INT;
  
  SET v_remaining_quantity = p_quantity;
  
  WHILE v_remaining_quantity > 0 DO
    SELECT id, quantity_on_hand INTO v_batch_id, v_batch_quantity
    FROM product_batches
    WHERE product_id = p_product_id
      AND expiry_date >= CURDATE()
      AND quantity_on_hand > 0
    ORDER BY expiry_date ASC, received_date ASC
    LIMIT 1;
    
    IF v_batch_id IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok tidak mencukupi';
    END IF;
    
    UPDATE product_batches 
    SET quantity_on_hand = quantity_on_hand - LEAST(v_remaining_quantity, v_batch_quantity)
    WHERE id = v_batch_id;
    
    INSERT INTO inventory_movements (
      batch_id, movement_type, quantity, reference_type, 
      reference_id, previous_stock, new_stock, created_by
    ) VALUES (
      v_batch_id, p_movement_type, -LEAST(v_remaining_quantity, v_batch_quantity),
      p_reference_type, p_reference_id, v_batch_quantity,
      v_batch_quantity - LEAST(v_remaining_quantity, v_batch_quantity), p_user_id
    );
    
    SET v_remaining_quantity = v_remaining_quantity - LEAST(v_remaining_quantity, v_batch_quantity);
  END WHILE;
END //

-- Procedure Analisis Pareto
CREATE PROCEDURE `sp_analyze_pareto_abc`(
  IN p_start_date DATE,
  IN p_end_date DATE
)
BEGIN
  DECLARE v_total_sales DECIMAL(19,2);
  DECLARE v_cumulative DECIMAL(10,2) DEFAULT 0;
  
  SELECT COALESCE(SUM(sh.grand_total), 0) INTO v_total_sales
  FROM sales_headers sh
  WHERE DATE(sh.transaction_date) BETWEEN p_start_date AND p_end_date
    AND sh.payment_status = 'Paid';
  
  DELETE FROM product_classification 
  WHERE analysis_period = p_end_date;
  
  INSERT INTO product_classification (
    product_id, analysis_period, total_sales_value, 
    total_sales_quantity, sales_percentage, cumulative_percentage, pareto_class
  )
  SELECT 
    p.id, p_end_date,
    COALESCE(SUM(sh.grand_total), 0),
    COALESCE(SUM(sd.quantity), 0),
    COALESCE(SUM(sh.grand_total) / v_total_sales * 100, 0),
    @cumulative := @cumulative + COALESCE(SUM(sh.grand_total) / v_total_sales * 100, 0),
    CASE 
      WHEN @cumulative <= 70 THEN 'A'
      WHEN @cumulative <= 90 THEN 'B'
      WHEN @cumulative <= 100 THEN 'C'
      ELSE 'D'
    END
  FROM products p
  LEFT JOIN product_batches pb ON p.id = pb.product_id
  LEFT JOIN sales_details sd ON pb.id = sd.batch_id
  LEFT JOIN sales_headers sh ON sd.sale_id = sh.id 
    AND DATE(sh.transaction_date) BETWEEN p_start_date AND p_end_date
    AND sh.payment_status = 'Paid'
  GROUP BY p.id
  ORDER BY SUM(sh.grand_total) DESC;
END //

-- Procedure Kirim Reminder
CREATE PROCEDURE `sp_send_due_reminders`()
BEGIN
  UPDATE reminders r
  JOIN patients p ON r.patient_id = p.id
  SET r.is_sent = 1, r.sent_at = NOW()
  WHERE r.reminder_datetime <= NOW()
    AND r.is_sent = 0
    AND r.is_cancelled = 0
    AND p.consent_to_reminder = 1;
    
  INSERT INTO reminder_logs (reminder_id, patient_id, sent_channel, sent_to, message_sent, sent_at)
  SELECT id, patient_id, communication_channel, 
         (SELECT phone FROM patients WHERE id = r.patient_id),
         message, NOW()
  FROM reminders r
  WHERE r.is_sent = 1 AND r.sent_at >= DATE_SUB(NOW(), INTERVAL 1 MINUTE);
END //

-- Procedure Void Penjualan
CREATE PROCEDURE `sp_void_sale`(
  IN p_sale_id INT,
  IN p_void_reason VARCHAR(50),
  IN p_void_reason_detail TEXT,
  IN p_restock_items TINYINT,
  IN p_user_id INT,
  IN p_ip_address VARCHAR(45)
)
BEGIN
  DECLARE v_void_number VARCHAR(50);
  DECLARE v_invoice_number VARCHAR(50);
  DECLARE v_grand_total DECIMAL(19,2);
  
  SELECT invoice_number, grand_total INTO v_invoice_number, v_grand_total
  FROM sales_headers WHERE id = p_sale_id;
  
  SET v_void_number = CONCAT('VOID/', DATE_FORMAT(NOW(), '%Y%m%d'), '/', LPAD((SELECT IFNULL(COUNT(*), 0) + 1 FROM sales_void_log WHERE DATE(created_at) = CURDATE()), 6, '0'));
  
  INSERT INTO sales_void_log (void_number, original_sale_id, original_invoice_number, void_reason, void_reason_detail, void_amount, restock_items, voided_by, voided_at)
  VALUES (v_void_number, p_sale_id, v_invoice_number, p_void_reason, p_void_reason_detail, v_grand_total, p_restock_items, p_user_id, NOW());
  
  UPDATE sales_headers SET payment_status = 'Refunded' WHERE id = p_sale_id;
  
  IF p_restock_items = 1 THEN
    UPDATE product_batches pb
    JOIN sales_details sd ON pb.id = sd.batch_id
    SET pb.quantity_on_hand = pb.quantity_on_hand + sd.quantity
    WHERE sd.sale_id = p_sale_id;
  END IF;
END //

-- Procedure Generate Forecast
CREATE PROCEDURE `sp_generate_forecast`(
  IN p_product_id INT,
  IN p_days_ahead INT
)
BEGIN
  INSERT INTO sales_forecast (product_id, forecast_date, forecast_quantity, model_used)
  SELECT 
    p_product_id,
    DATE_ADD(CURDATE(), INTERVAL n DAY),
    GREATEST(1, ROUND(
      COALESCE((
        SELECT AVG(sd.quantity)
        FROM sales_details sd
        JOIN product_batches pb ON sd.batch_id = pb.id
        WHERE pb.product_id = p_product_id
          AND sd.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
      ), 10) * (1 + (RAND() - 0.5) * 0.2)
    )),
    'MovingAverage'
  FROM (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
    UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
    UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25
    UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30
  ) days
  WHERE n <= p_days_ahead;
END //

DELIMITER ;

-- =====================================================
-- PART 11: TRIGGERS
-- =====================================================

DELIMITER //

CREATE TRIGGER `after_sale_detail_insert`
AFTER INSERT ON `sales_details`
FOR EACH ROW
BEGIN
  DECLARE v_product_id INT;
  DECLARE v_patient_id INT;
  
  SELECT product_id INTO v_product_id FROM product_batches WHERE id = NEW.batch_id;
  SELECT patient_id INTO v_patient_id FROM sales_headers WHERE id = NEW.sale_id;
  
  CALL sp_update_stock_fefo(v_product_id, NEW.quantity, 'Sale', 'SalesDetail', NEW.id, 
    (SELECT cashier_id FROM sales_headers WHERE id = NEW.sale_id));
  
  IF v_patient_id IS NOT NULL THEN
    UPDATE patients SET total_visits = total_visits + 1, total_spent = total_spent + NEW.subtotal
    WHERE id = v_patient_id;
  END IF;
END //

CREATE TRIGGER `after_purchase_detail_insert`
AFTER INSERT ON `purchase_details`
FOR EACH ROW
BEGIN
  INSERT INTO product_batches (product_id, supplier_id, batch_number, expiry_date, purchase_price, selling_price, quantity_initial, quantity_on_hand, received_date)
  SELECT NEW.product_id, ph.supplier_id, NEW.batch_number, NEW.expiry_date, NEW.price, p.selling_price, NEW.quantity, NEW.quantity, CURDATE()
  FROM purchase_headers ph, products p
  WHERE ph.id = NEW.purchase_id AND p.id = NEW.product_id
  ON DUPLICATE KEY UPDATE quantity_on_hand = quantity_on_hand + NEW.quantity;
END //

DELIMITER ;

-- =====================================================
-- PART 12: EVENTS (Scheduled Jobs)
-- =====================================================

DELIMITER //

CREATE EVENT IF NOT EXISTS `evt_send_reminders`
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
  CALL sp_send_due_reminders();
END //

CREATE EVENT IF NOT EXISTS `evt_update_metrics`
ON SCHEDULE EVERY 5 MINUTE
DO
BEGIN
  INSERT INTO realtime_metrics (metric_name, metric_value, recorded_at)
  SELECT 'today_sales', COALESCE(SUM(grand_total), 0), NOW()
  FROM sales_headers WHERE DATE(transaction_date) = CURDATE() AND payment_status = 'Paid';
END //

DELIMITER ;

-- =====================================================
-- PART 13: DATA MASTER (SEEDING)
-- =====================================================

-- Payment Terms
INSERT INTO `payment_terms` (`code`, `name`, `type`, `default_due_days`) VALUES
('CASH', 'Tunai', 'Cash', 0),
('CREDIT_30', 'Kredit 30 Hari', 'Credit', 30),
('CREDIT_45', 'Kredit 45 Hari', 'Credit', 45),
('CREDIT_60', 'Kredit 60 Hari', 'Credit', 60),
('CONSIGN', 'Konsinyasi', 'Consignment', 0);

-- Payment Methods
INSERT INTO `payment_methods` (`code`, `name`, `type`, `fee_percentage`) VALUES
('CASH', 'Tunai', 'Cash', 0),
('QRIS', 'QRIS', 'QRIS', 0.70),
('DEBIT_BCA', 'Debit BCA', 'Debit', 0.50),
('CC_VISA', 'Kredit Visa', 'Credit', 1.50),
('BPJS', 'BPJS Kesehatan', 'BPJS', 0),
('OVO', 'OVO', 'E-Wallet', 0.50);

-- Categories
INSERT INTO `categories` (`code`, `name`, `classification`) VALUES
('CAT001', 'Analgesik', 'OTC'),
('CAT002', 'Antibiotik', 'OOP'),
('CAT003', 'Vitamin', 'OTC');

-- Units
INSERT INTO `units` (`code`, `name`) VALUES
('TAB', 'Tablet'),
('KAP', 'Kapsul'),
('BTL', 'Botol');

-- Suppliers
INSERT INTO `suppliers` (`code`, `name`, `phone`, `address`) VALUES
('SUP001', 'PT. Kalbe Farma', '021-8888888', 'Jakarta'),
('SUP002', 'PT. Kimia Farma', '022-7777777', 'Bandung');

-- Outlets
INSERT INTO `outlets` (`code`, `name`, `address`, `is_head_office`) VALUES
('APO001', 'Apotek Sehat Pusat', 'Semarang', 1);

-- Users (password: admin123, kasir123, apt123)
INSERT INTO `users` (`name`, `username`, `password`, `outlet_id`, `role`) VALUES
('Administrator', 'admin', SHA1('admin123'), 1, 'admin'),
('Kasir 1', 'kasir1', SHA1('kasir123'), 1, 'cashier'),
('Apoteker', 'apoteker', SHA1('apt123'), 1, 'pharmacist');

-- Work Shifts
INSERT INTO `work_shifts` (`code`, `name`, `start_time`, `end_time`) VALUES
('SHIFT_PAGI', 'Shift Pagi', '08:00:00', '16:00:00'),
('SHIFT_SIANG', 'Shift Siang', '13:00:00', '21:00:00');

-- Products
INSERT INTO `products` (`code`, `name`, `category_id`, `unit_id`, `min_stock`, `base_price`, `selling_price`) VALUES
('OB001', 'Paramex', 1, 1, 50, 8000, 10000),
('OB002', 'Konidin', 1, 1, 30, 3000, 5000),
('OB003', 'Panacilin', 2, 2, 100, 4000, 5000);

-- Product Batches
INSERT INTO `product_batches` (`product_id`, `supplier_id`, `batch_number`, `expiry_date`, `purchase_price`, `selling_price`, `quantity_initial`, `quantity_on_hand`, `received_date`) VALUES
(1, 1, 'PAR-202401-001', '2026-12-31', 7000, 10000, 500, 350, CURDATE()),
(2, 1, 'KON-202402-001', '2026-01-31', 2500, 5000, 100, 50, CURDATE()),
(3, 2, 'PAN-202401-001', '2025-06-30', 3500, 5000, 300, 208, CURDATE());

-- Patients
INSERT INTO `patients` (`patient_number`, `name`, `phone`, `address`, `consent_to_reminder`) VALUES
('PAT001', 'Ahmad Wijaya', '081234567890', 'Semarang', 1),
('PAT002', 'Siti Fatimah', '082345678901', 'Semarang', 1);

-- Barcodes
INSERT INTO `barcode_master` (`barcode`, `reference_type`, `reference_id`, `is_primary`) VALUES
('8991234567890', 'Product', 1, 1),
('8991234567891', 'Product', 2, 1);

-- Translations
INSERT INTO `translations` (`language`, `key_text`, `translated_text`) VALUES
('id', 'welcome', 'Selamat Datang'),
('en', 'welcome', 'Welcome'),
('id', 'expiry_warning', 'Obat akan kadaluarsa dalam {days} hari'),
('en', 'expiry_warning', 'Medicine will expire in {days} days');

COMMIT;

-- =====================================================
-- SELESAI
-- =====================================================
-- Total Tabel: 35+ tabel
-- Total View: 6 view
-- Total Procedure: 5 procedure
-- Total Event: 2 event
-- =====================================================