-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Hôte : db
-- Généré le : ven. 19 déc. 2025 à 17:38
-- Version du serveur : 8.0.44
-- Version de PHP : 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `whatsapp`
--

-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

CREATE TABLE `messages` (
  `id` bigint UNSIGNED NOT NULL,
  `sender_id` bigint UNSIGNED NOT NULL,
  `receiver_id` bigint UNSIGNED NOT NULL,
  `content` varchar(200) DEFAULT NULL,
  `type` enum('text','image') NOT NULL DEFAULT 'text',
  `media_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `messages`
--

INSERT INTO `messages` (`id`, `sender_id`, `receiver_id`, `content`, `type`, `media_url`, `created_at`) VALUES
(1, 1, 2, 'Salut Bob', 'text', NULL, '2025-12-19 17:29:29'),
(2, 2, 1, 'Salut Alice', 'text', NULL, '2025-12-19 17:29:29'),
(3, 1, 2, 'Ça va ?', 'text', NULL, '2025-12-19 17:29:29'),
(4, 2, 1, 'Oui tranquille', 'text', NULL, '2025-12-19 17:29:29'),
(5, 1, 3, 'Hey Charlie', 'text', NULL, '2025-12-19 17:29:35'),
(6, 3, 1, 'Yo', 'text', NULL, '2025-12-19 17:29:35'),
(7, 1, 3, 'Tu bosses sur quoi ?', 'text', NULL, '2025-12-19 17:29:35'),
(8, 1, 2, 'Nouveau message test', 'text', NULL, '2025-12-19 17:36:05');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `phone` char(10) NOT NULL,
  `password` varchar(255) NOT NULL,
  `last_seen` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `phone`, `password`, `last_seen`, `created_at`, `updated_at`) VALUES
(1, 'Alice', 'Dupont', '0611111111', '$2y$10$dQ4RvSYNPIAwXE5VTLuOdesazLyc6LX.1HoVCpBREB63UMlAKeEEq', NULL, '2025-12-19 17:28:13', '2025-12-19 17:33:43'),
(2, 'Bob', 'Martin', '0611111112', '$2y$10$85ob2lOlou.eMQeKz9mNbO6cQFDOmCQ61vRbqmj.M4a3ShdFWwgV.', NULL, '2025-12-19 17:28:23', NULL),
(3, 'Charlie', 'Durand', '0611111113', '$2y$10$PqB0lYl08FU4HR/9T6MX4eg/B7ksZcZjspW35D2Mg1R4hcqP0JXLS', NULL, '2025-12-19 17:28:28', NULL);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conversation` (`sender_id`,`receiver_id`),
  ADD KEY `idx_created` (`created_at`),
  ADD KEY `fk_receiver` (`receiver_id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone` (`phone`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `fk_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

