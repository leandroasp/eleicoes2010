# MySQL-Front 5.0  (Build 1.8)

/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE */;
/*!40101 SET SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES */;
/*!40103 SET SQL_NOTES='ON' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS */;
/*!40014 SET FOREIGN_KEY_CHECKS=0 */;


# Host: localhost    Database: eleicoes2010
# ------------------------------------------------------
# Server version 5.1.48-community

CREATE DATABASE `eleicoes2010` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `eleicoes2010`;

#
# Table structure for table abrangencias
#

CREATE TABLE `abrangencias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uf` varchar(2) DEFAULT NULL,
  `nome` varchar(30) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Dumping data for table abrangencias
#
LOCK TABLES `abrangencias` WRITE;
/*!40000 ALTER TABLE `abrangencias` DISABLE KEYS */;

/*!40000 ALTER TABLE `abrangencias` ENABLE KEYS */;
UNLOCK TABLES;

#
# Table structure for table candidatos
#

CREATE TABLE `candidatos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `numero` int(11) DEFAULT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `nome_urna` varchar(100) DEFAULT NULL,
  `sexo` varchar(1) DEFAULT NULL,
  `data_nasc` date DEFAULT NULL,
  `situacao` varchar(1) DEFAULT NULL,
  `descricao_situacao` varchar(30) DEFAULT NULL,
  `eleito` varchar(1) DEFAULT NULL,
  `partido_id` int(11) DEFAULT NULL,
  `cargo_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Dumping data for table candidatos
#
LOCK TABLES `candidatos` WRITE;
/*!40000 ALTER TABLE `candidatos` DISABLE KEYS */;

/*!40000 ALTER TABLE `candidatos` ENABLE KEYS */;
UNLOCK TABLES;

#
# Table structure for table cargos
#

CREATE TABLE `cargos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(1) DEFAULT NULL,
  `nome` varchar(30) DEFAULT NULL,
  `total_vagas` int(11) DEFAULT NULL,
  `final` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Dumping data for table cargos
#
LOCK TABLES `cargos` WRITE;
/*!40000 ALTER TABLE `cargos` DISABLE KEYS */;

/*!40000 ALTER TABLE `cargos` ENABLE KEYS */;
UNLOCK TABLES;

#
# Table structure for table coligacoes
#

CREATE TABLE `coligacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `numero` int(11) DEFAULT NULL,
  `nome` varchar(50) DEFAULT NULL,
  `tipo` varchar(1) DEFAULT NULL,
  `vagas` int(11) DEFAULT NULL,
  `composicao` varchar(100) DEFAULT NULL,
  `abrangencia_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_colig_abran` (`abrangencia_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Dumping data for table coligacoes
#
LOCK TABLES `coligacoes` WRITE;
/*!40000 ALTER TABLE `coligacoes` DISABLE KEYS */;

/*!40000 ALTER TABLE `coligacoes` ENABLE KEYS */;
UNLOCK TABLES;

#
# Table structure for table escalas
#

CREATE TABLE `escalas` (
  `cod_escala` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cod_medico` int(10) unsigned NOT NULL,
  `status` bit(1) NOT NULL,
  `data_cadastro` datetime NOT NULL,
  `data_alteracao` datetime NOT NULL,
  `cod_usuario` int(10) unsigned NOT NULL,
  PRIMARY KEY (`cod_escala`),
  KEY `fk_esc_med` (`cod_medico`),
  KEY `fk_esc_usu` (`cod_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

#
# Dumping data for table escalas
#
LOCK TABLES `escalas` WRITE;
/*!40000 ALTER TABLE `escalas` DISABLE KEYS */;

/*!40000 ALTER TABLE `escalas` ENABLE KEYS */;
UNLOCK TABLES;

#
# Table structure for table partidos
#

CREATE TABLE `partidos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `numero` int(11) DEFAULT NULL,
  `sigla` varchar(10) DEFAULT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `coligacao_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_part_colig` (`coligacao_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Dumping data for table partidos
#
LOCK TABLES `partidos` WRITE;
/*!40000 ALTER TABLE `partidos` DISABLE KEYS */;

/*!40000 ALTER TABLE `partidos` ENABLE KEYS */;
UNLOCK TABLES;

#
#  Foreign keys for table coligacoes
#

ALTER TABLE `coligacoes`
ADD CONSTRAINT `fk_colig_abran` FOREIGN KEY (`abrangencia_id`) REFERENCES `abrangencias` (`id`) ON UPDATE CASCADE;

#
#  Foreign keys for table partidos
#

ALTER TABLE `partidos`
ADD CONSTRAINT `fk_part_colig` FOREIGN KEY (`coligacao_id`) REFERENCES `coligacoes` (`id`) ON UPDATE CASCADE;


/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
