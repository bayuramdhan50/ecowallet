-- EcoWallet Database Schema
-- Creates database and all required tables

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS ecowallet_db;
USE ecowallet_db;

-- Users Table
-- Stores both client and admin users
-- is_active: 0 (pending approval), 1 (active)
-- role: 'client' or 'admin'
CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('client', 'admin') DEFAULT 'client',
  is_active TINYINT(1) DEFAULT 0,
  balance DECIMAL(15, 2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Waste Types Table
-- Master data for different types of waste
-- bonus_threshold: minimum weight (kg) to get bonus
-- bonus_amount: additional price per kg when threshold met
CREATE TABLE IF NOT EXISTS waste_types (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  price_per_kg DECIMAL(10, 2) NOT NULL,
  bonus_threshold DECIMAL(10, 2) DEFAULT 0,
  bonus_amount DECIMAL(10, 2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Transactions Table
-- Records all waste deposit transactions
-- status: 'pending', 'approved', 'rejected'
CREATE TABLE IF NOT EXISTS transactions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  waste_type_id INT NOT NULL,
  estimated_weight DECIMAL(10, 2) NOT NULL,
  actual_weight DECIMAL(10, 2) DEFAULT NULL,
  photo_url VARCHAR(500) DEFAULT NULL,
  total_earning DECIMAL(15, 2) DEFAULT 0.00,
  status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (waste_type_id) REFERENCES waste_types(id) ON DELETE RESTRICT
);

-- Insert default admin user
-- Email: admin@ecowallet.com
-- Password: admin123 (hashed with bcrypt)
INSERT INTO users (name, email, password, role, is_active, balance) VALUES
('Admin EcoWallet', 'admin@ecowallet.com', '$2a$10$cuDd2gGahF6/k9gaaTHg7.h5QfuYPy.xuDV.Wa62j5tlhpV4wRDH6', 'admin', 1, 0.00);

-- Insert sample waste types with bonus configuration
INSERT INTO waste_types (name, price_per_kg, bonus_threshold, bonus_amount) VALUES
('Plastik', 3000.00, 10.00, 500.00),
('Kertas', 2000.00, 15.00, 300.00),
('Logam', 5000.00, 8.00, 1000.00),
('Botol Kaca', 1500.00, 20.00, 200.00);
