DROP SCHEMA IF EXISTS article;
CREATE SCHEMA article CHAR SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE article;
DROP TABLE IF EXISTS Meta;
CREATE TABLE `Meta` (
  `Id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `Title` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `AuthorFullName` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `LastEditedTimestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `_DB_META_CREATEDTIMESTAMP` timestamp NOT NULL DEFAULT current_timestamp(),
  `_DB_META_MODIFIEDTIMESTAMP` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`Id`),
  KEY `idx1` (`Title`) USING BTREE,
  KEY `idx2` (`Title`),
  FULLTEXT KEY `FTK_TitleAuthorFullName` (`Title`,`AuthorFullName`)
)
;

DROP TABLE IF EXISTS Context;
CREATE TABLE `Context` (
  `MetaId` INTEGER UNSIGNED NOT NULL,
  `Body` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `_DB_META_CREATEDTIMESTAMP` timestamp NOT NULL DEFAULT current_timestamp(),
  `_DB_META_MODIFIEDTIMESTAMP` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`MetaId`),
  KEY `Context_Meta_Id_fk` (`MetaId`),
  FULLTEXT KEY `FTK_Body` (`Body`),
  CONSTRAINT `Context_Meta_Id_fk` FOREIGN KEY (`MetaId`) REFERENCES `Meta` (`Id`)
)
;

DROP USER IF EXISTS 'api'@'%';
CREATE USER 'api'@'%' IDENTIFIED BY '*#zEfcB6wJn3pQPKpoBT3qBsd%aDZo8E';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, CREATE TEMPORARY TABLES ON article.* TO 'api'@'%';
# GRANT ALL ON *.* TO 'api'@'%';