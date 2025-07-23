CREATE TABLE IF NOT EXISTS `oil_wells` (
  `id` INT NOT NULL,
  `owner` VARCHAR(50),
  `oil_amount` INT DEFAULT 0,
  `maintained` TINYINT DEFAULT 0,
  PRIMARY KEY (`id`)
);
