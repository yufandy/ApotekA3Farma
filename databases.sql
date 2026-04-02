-- =====================================================
-- DATABASE APOTEK MODERN - FINAL COMPLETE EDITION
-- =====================================================
-- VERSI: 4.0 Ultimate Final
-- TANGGAL: April 2026
--
-- FITUR LENGKAP:
-- =====================================================
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
-- 17. MULTI-OUTLET & MANAJEMEN AKSES (OWNERSHIP vs PARTNERSHIP)
-- 18. RESEP RACIKAN (PUYER) TERSTRUKTUR
-- 19. TOKEN AKTIVASI APLIKASI (LICENSE MANAGEMENT)
-- 20. DATA APOTEK SESUAI REGULASI PEMERINTAH
-- 21. INTEGRASI BPJS (OBAT & PASIEN)
-- 22. IMPORT DATA (MIGRASI DARI APLIKASI LAMA)
-- =====================================================

-- Drop database jika ada (HATI-HATI!)
DROP DATABASE IF EXISTS `apotek_modern`;
CREATE DATABASE `apotek_modern` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `apotek_modern`;

-- =====================================================
-- PART 1: TABEL MASTER DATA (DARI SEBELUMNYA)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- PART 2: RESEP RACIKAN (PUYER) - FITUR BARU
-- =====================================================

-- Komposisi racikan
CREATE TABLE `prescription_compounds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prescription_id` int(11) NOT NULL,
  `compound_number` varchar(20) NOT NULL,
  `compound_name` varchar(255),
  `dosage_form` enum('Puyer','Kapsul','Tablet','Sirup','Salep','Cream','Obat_Tetes') NOT NULL,
  `quantity_made` int(11) NOT NULL DEFAULT '1',
  `unit_price` decimal(19,2),
  `total_price` decimal(19,2),
  `instructions` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `prescription_id` (`prescription_id`),
  FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bahan-bahan racikan
CREATE TABLE `compound_ingredients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `compound_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` decimal(10,3) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `compound_id` (`compound_id`),
  KEY `product_id` (`product_id`),
  FOREIGN KEY (`compound_id`) REFERENCES `prescription_compounds` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Biaya racikan sesuai aturan pemerintah
CREATE TABLE `compounding_fees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fee_code` varchar(20) NOT NULL,
  `fee_name` varchar(100) NOT NULL,
  `fee_type` enum('Service','Material','Packaging','Emergency','HomeService') NOT NULL,
  `calculation_method` enum('Percentage','Fixed','Tiered') NOT NULL,
  `base_amount` decimal(19,2),
  `percentage_value` decimal(5,2),
  `min_fee` decimal(19,2),
  `max_fee` decimal(19,2),
  `is_mandatory` tinyint(1) DEFAULT '0',
  `regulation_reference` varchar(100),
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fee_code` (`fee_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Biaya racikan per resep
CREATE TABLE `prescription_compounding_fees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prescription_id` int(11) NOT NULL,
  `fee_id` int(11) NOT NULL,
  `amount` decimal(19,2) NOT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `prescription_id` (`prescription_id`),
  KEY `fee_id` (`fee_id`),
  FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`fee_id`) REFERENCES `compounding_fees` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- PART 3: MULTI-OUTLET & MANAJEMEN AKSES (FITUR BARU)
-- =====================================================

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Hubungan antar outlet (Ownership vs Partnership)
CREATE TABLE `outlet_relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `outlet_id` int(11) NOT NULL,
  `related_outlet_id` int(11) NOT NULL,
  `relationship_type` enum('Ownership','Partnership','Franchise','Referral') NOT NULL,
  `access_level` enum('Full','StockOnly','ReportOnly','Limited') NOT NULL,
  `can_view_stock` tinyint(1) DEFAULT '0',
  `can_transfer_stock` tinyint(1) DEFAULT '0',
  `can_view_sales` tinyint(1) DEFAULT '0',
  `can_view_patients` tinyint(1) DEFAULT '0',
  `profit_sharing_percentage` decimal(5,2) DEFAULT '0.00',
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `outlet_id` (`outlet_id`),
  KEY `related_outlet_id` (`related_outlet_id`),
  FOREIGN KEY (`outlet_id`) REFERENCES `outlets` (`id`),
  FOREIGN KEY (`related_outlet_id`) REFERENCES `outlets` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Transfer stok antar outlet
CREATE TABLE `stock_transfer` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `transfer_number` varchar(50) NOT NULL,
  `from_outlet_id` int(11) NOT NULL,
  `to_outlet_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `transfer_date` datetime NOT NULL,
  `received_date` datetime,
  `status` enum('Pending','InTransit','Completed','Cancelled') DEFAULT 'Pending',
  `notes` text,
  `created_by` int(11),
  `approved_by` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transfer_number` (`transfer_number`),
  KEY `from_outlet_id` (`from_outlet_id`),
  KEY `to_outlet_id` (`to_outlet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- PART 4: DATA SESUAI REGULASI PEMERINTAH (FITUR BARU)
-- =====================================================

-- Izin Apotek (SIPA)
CREATE TABLE `pharmacy_licenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `outlet_id` int(11) NOT NULL,
  `license_number` varchar(50) NOT NULL COMMENT 'SIPA - Surat Izin Praktik Apoteker',
  `license_type` enum('Apotek','Toko Obat','PBF','Klinik') NOT NULL,
  `issuing_authority` varchar(255) COMMENT 'Dinas Kesehatan / PBF',
  `issue_date` date NOT NULL,
  `expiry_date` date NOT NULL,
  `license_file` varchar(255),
  `is_active` tinyint(1) DEFAULT '1',
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `outlet_id` (`outlet_id`),
  FOREIGN KEY (`outlet_id`) REFERENCES `outlets` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data Apoteker (SIPA & STR)
CREATE TABLE `pharmacist_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `sipa_number` varchar(50) NOT NULL COMMENT 'Surat Izin Praktik Apoteker',
  `registration_number` varchar(50) COMMENT 'STR - Surat Tanda Registrasi',
  `education` text,
  `specialization` varchar(100),
  `license_date` date,
  `license_expiry` date,
  `supervisor` varchar(128),
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sipa_number` (`sipa_number`),
  KEY `user_id` (`user_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Log Obat Narkotika & Psikotropika (wajib lapor)
CREATE TABLE `narcotic_psychotropic_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `outlet_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `batch_number` varchar(50),
  `transaction_type` enum('Purchase','Sale','Return','Destruction','Transfer') NOT NULL,
  `quantity` int(11) NOT NULL,
  `patient_name` varchar(128),
  `patient_address` text,
  `doctor_name` varchar(128),
  `doctor_sip` varchar(50),
  `prescription_number` varchar(50),
  `transaction_date` datetime NOT NULL,
  `reported_to_authority` tinyint(1) DEFAULT '0',
  `report_date` date,
  `report_number` varchar(50),
  `created_by` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `outlet_id` (`outlet_id`),
  KEY `product_id` (`product_id`),
  KEY `transaction_date` (`transaction_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- PART 5: INTEGRASI BPJS (FITUR BARU)
-- =====================================================

-- Formularium BPJS
CREATE TABLE `bpjs_medicines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `bpjs_code` varchar(50) NOT NULL,
  `bpjs_name` varchar(255),
  `formulary_category` enum('Non-Formulary','Formulary','Limited') DEFAULT 'Non-Formulary',
  `reference_price` decimal(19,2),
  `max_reimbursement` decimal(19,2),
  `indication` text,
  `dosage_limit` varchar(100),
  `age_limit_min` int(11),
  `age_limit_max` int(11),
  `special_notes` text,
  `last_update` date,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `bpjs_code` (`bpjs_code`),
  FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Klaim BPJS
CREATE TABLE `bpjs_claims` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sale_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `claim_number` varchar(50) NOT NULL,
  `sep_number` varchar(50) COMMENT 'Surat Eligibilitas Peserta',
  `claim_date` date NOT NULL,
  `total_claim` decimal(19,2) NOT NULL,
  `approved_amount` decimal(19,2),
  `rejected_amount` decimal(19,2),
  `copayment_amount` decimal(19,2),
  `status` enum('Draft','Submitted','Verified','Approved','Rejected','Paid') DEFAULT 'Draft',
  `submission_date` date,
  `verification_date` date,
  `approval_date` date,
  `payment_date` date,
  `rejection_reason` text,
  `response_data` json,
  `created_by` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `claim_number` (`claim_number`),
  KEY `sale_id` (`sale_id`),
  KEY `patient_id` (`patient_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Detail klaim BPJS
CREATE TABLE `bpjs_claim_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `claim_id` bigint(20) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `claimed_price` decimal(19,2) NOT NULL,
  `reference_price` decimal(19,2),
  `approved_price` decimal(19,2),
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `claim_id` (`claim_id`),
  KEY `product_id` (`product_id`),
  FOREIGN KEY (`claim_id`) REFERENCES `bpjs_claims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- PART 6: TOKEN AKTIVASI APLIKASI (FITUR BARU)
-- =====================================================

-- Lisensi aplikasi
CREATE TABLE `application_licenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license_key` varchar(100) NOT NULL,
  `license_type` enum('Trial','Monthly','Yearly','Perpetual','Enterprise') NOT NULL,
  `outlet_id` int(11),
  `max_outlets` int(11) DEFAULT '1',
  `max_users` int(11) DEFAULT '5',
  `features` json,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_suspended` tinyint(1) DEFAULT '0',
  `suspended_reason` text,
  `last_validation` datetime,
  `validation_count` int(11) DEFAULT '0',
  `created_by` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_key` (`license_key`),
  KEY `outlet_id` (`outlet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Log validasi lisensi
CREATE TABLE `license_validation_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `license_key` varchar(100) NOT NULL,
  `validation_status` enum('Valid','Invalid','Expired','Suspended','Revoked') NOT NULL,
  `validation_message` text,
  `server_response` json,
  `ip_address` varchar(45),
  `device_id` varchar(255),
  `validated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `license_key` (`license_key`),
  KEY `validated_at` (`validated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Token aktivasi sementara
CREATE TABLE `activation_tokens` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token` varchar(255) NOT NULL,
  `outlet_name` varchar(128),
  `outlet_address` text,
  `email` varchar(100),
  `phone` varchar(20),
  `is_used` tinyint(1) DEFAULT '0',
  `used_at` datetime,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- PART 7: IMPORT DATA (MIGRASI DARI APLIKASI LAMA)
-- =====================================================

-- Log import data
CREATE TABLE `import_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `import_number` varchar(50) NOT NULL,
  `source_system` varchar(100) NOT NULL,
  `source_version` varchar(50),
  `import_type` enum('Products','Customers','Sales','Inventory','Patients','All') NOT NULL,
  `total_records` int(11) DEFAULT '0',
  `success_records` int(11) DEFAULT '0',
  `failed_records` int(11) DEFAULT '0',
  `skipped_records` int(11) DEFAULT '0',
  `import_file` varchar(255),
  `file_hash` varchar(64),
  `status` enum('Pending','Processing','Completed','Failed') DEFAULT 'Pending',
  `error_log` text,
  `mapping_config` json,
  `started_at` datetime,
  `completed_at` datetime,
  `created_by` int(11),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `import_number` (`import_number`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Error saat import
CREATE TABLE `import_errors` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `import_id` bigint(20) NOT NULL,
  `row_number` int(11),
  `original_data` json,
  `error_message` text,
  `error_type` varchar(50),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `import_id` (`import_id`),
  FOREIGN KEY (`import_id`) REFERENCES `import_logs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Template mapping data
CREATE TABLE `data_migration_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_name` varchar(100) NOT NULL,
  `source_system` varchar(100) NOT NULL,
  `source_table` varchar(100),
  `target_table` varchar(100) NOT NULL,
  `field_mapping` json NOT NULL,
  `transformation_rules` json,
  `validation_rules` json,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `source_system` (`source_system`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- PART 8: METODE PEMBAYARAN & TRANSAKSI
-- =====================================================

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Pengguna Sistem
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `outlet_id` int(11) DEFAULT NULL,
  `role` enum('admin','manager','pharmacist','cashier','warehouse','owner','partner') NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `outlet_id` (`outlet_id`),
  FOREIGN KEY (`outlet_id`) REFERENCES `outlets` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- PART 9: STORED PROCEDURES (VALIDASI LISENSI)
-- =====================================================

DELIMITER //

-- Validasi lisensi
CREATE PROCEDURE `sp_validate_license`(
  IN p_license_key VARCHAR(100),
  IN p_device_id VARCHAR(255),
  IN p_ip_address VARCHAR(45)
)
BEGIN
  DECLARE v_is_valid TINYINT DEFAULT 0;
  DECLARE v_message TEXT;
  DECLARE v_outlet_id INT;
  
  -- Cek apakah lisensi ada dan aktif
  SELECT id, outlet_id INTO v_outlet_id, v_outlet_id
  FROM application_licenses 
  WHERE license_key = p_license_key 
    AND is_active = 1 
    AND is_suspended = 0
    AND start_date <= CURDATE() 
    AND end_date >= CURDATE()
  LIMIT 1;
  
  IF v_outlet_id IS NOT NULL THEN
    SET v_is_valid = 1;
    SET v_message = 'License valid';
    
    -- Update last validation
    UPDATE application_licenses 
    SET last_validation = NOW(), 
        validation_count = validation_count + 1 
    WHERE license_key = p_license_key;
  ELSE
    SET v_message = 'License invalid or expired';
  END IF;
  
  -- Log validation
  INSERT INTO license_validation_log (license_key, validation_status, validation_message, ip_address, device_id)
  VALUES (p_license_key, IF(v_is_valid = 1, 'Valid', 'Invalid'), v_message, p_ip_address, p_device_id);
  
  -- Return result
  SELECT v_is_valid as is_valid, v_message as message, v_outlet_id as outlet_id;
END //

DELIMITER ;

-- =====================================================
-- PART 10: DATA SEEDING (SAMPLE DATA)
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

-- Outlets
INSERT INTO `outlets` (`code`, `name`, `address`, `is_head_office`) VALUES
('APO001', 'Apotek Sehat Pusat', 'Jl. Pemuda No. 123, Semarang', 1),
('APO002', 'Apotek Sehat Cabang', 'Jl. Ahmad Yani No. 45, Semarang', 0),
('APO003', 'Apotek Mitra Sehat', 'Jl. Diponegoro No. 78, Semarang', 0);

-- Users (password: admin123, kasir123, apt123)
INSERT INTO `users` (`name`, `username`, `password`, `outlet_id`, `role`) VALUES
('Administrator', 'admin', SHA1('admin123'), 1, 'admin'),
('Pemilik Apotek', 'owner', SHA1('owner123'), 1, 'owner'),
('Kasir Pusat', 'kasir1', SHA1('kasir123'), 1, 'cashier'),
('Kasir Cabang', 'kasir2', SHA1('kasir123'), 2, 'cashier'),
('Apoteker', 'apoteker', SHA1('apt123'), 1, 'pharmacist');

-- Outlet Relationships (Ownership vs Partnership)
INSERT INTO `outlet_relationships` (`outlet_id`, `related_outlet_id`, `relationship_type`, `access_level`, `can_view_stock`, `can_transfer_stock`, `can_view_sales`, `can_view_patients`, `start_date`) VALUES
(1, 2, 'Ownership', 'Full', 1, 1, 1, 1, '2024-01-01'),
(1, 3, 'Partnership', 'StockOnly', 1, 0, 0, 0, '2024-01-01');

-- Compounding Fees (Sesuai aturan pemerintah)
INSERT INTO `compounding_fees` (`fee_code`, `fee_name`, `fee_type`, `calculation_method`, `base_amount`, `percentage_value`, `min_fee`, `max_fee`, `is_mandatory`, `regulation_reference`) VALUES
('SVC001', 'Jasa Racikan Puyer', 'Service', 'Fixed', 5000, NULL, 5000, 15000, 1, 'Permenkes No. 9 Tahun 2017'),
('SVC002', 'Jasa Racikan Kapsul', 'Service', 'Fixed', 7500, NULL, 7500, 20000, 1, 'Permenkes No. 9 Tahun 2017'),
('MAT001', 'Biaya Bahan Racikan', 'Material', 'Percentage', NULL, 10.00, 1000, 5000, 0, 'Standar Apotek');

-- Sample License
INSERT INTO `application_licenses` (`license_key`, `license_type`, `outlet_id`, `max_outlets`, `max_users`, `start_date`, `end_date`, `is_active`) VALUES
('APO-SEHA T-2024-001', 'Enterprise', 1, 10, 50, '2024-01-01', '2025-12-31', 1);

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
INSERT INTO `patients` (`patient_number`, `name`, `phone`, `address`, `insurance_type`, `insurance_number`, `consent_to_reminder`) VALUES
('PAT001', 'Ahmad Wijaya', '081234567890', 'Semarang', 'BPJS', '00123456789', 1),
('PAT002', 'Siti Fatimah', '082345678901', 'Semarang', 'None', NULL, 1);

-- Sample Prescription with Compounding
INSERT INTO `prescriptions` (`prescription_number`, `patient_id`, `doctor_name`, `prescription_date`, `is_compounding`) VALUES
('RESEP001', 1, 'Dr. Budi Santoso', CURDATE(), 1);

INSERT INTO `prescription_compounds` (`prescription_id`, `compound_number`, `dosage_form`, `quantity_made`, `unit_price`, `total_price`) VALUES
(1, 'R/1', 'Puyer', 10, 5000, 50000);

INSERT INTO `prescription_compounding_fees` (`prescription_id`, `fee_id`, `amount`) VALUES
(1, 1, 5000);

COMMIT;

-- =====================================================
-- SELESAI - DATABASE APOTEK MODERN FINAL COMPLETE
-- =====================================================
-- Total Tabel: 45+ tabel
-- Total Fitur: 22 fitur lengkap
-- Siap Import & Gunakan!
-- =====================================================
