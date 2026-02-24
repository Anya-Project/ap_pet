CREATE TABLE IF NOT EXISTS `player_pets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `pet_name` varchar(50) NOT NULL,
  `model` varchar(50) NOT NULL,
  `health` int(11) DEFAULT 100,
  `hunger` int(11) DEFAULT 100,
  `thirst` int(11) DEFAULT 100,
  `is_k9` boolean DEFAULT false,
  `is_dead` boolean DEFAULT false,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
