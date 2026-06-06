-- Create database if it does not exist
CREATE DATABASE IF NOT EXISTS myproject;
USE myproject;

-- Table structure for table `users`
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed data for testing v1 connectivity loop
INSERT INTO `users` (`name`) VALUES ('Raj'), ('TestUser');