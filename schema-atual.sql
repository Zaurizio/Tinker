CREATE DATABASE  IF NOT EXISTS `cl204179` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `cl204179`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 143.106.241.4    Database: cl204179
-- ------------------------------------------------------
-- Server version	8.0.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Administrador`
--

DROP TABLE IF EXISTS `Administrador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Administrador` (
  `login` varchar(10) NOT NULL,
  `senha` int DEFAULT NULL,
  PRIMARY KEY (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Aluno`
--

DROP TABLE IF EXISTS `Aluno`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Aluno` (
  `email` varchar(50) NOT NULL,
  `senha` varchar(100) NOT NULL,
  `foto` longblob,
  `nome` varchar(20) NOT NULL,
  `sobrenome` varchar(50) NOT NULL,
  `nascimento` date NOT NULL,
  `ativo` int DEFAULT '1',
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Aluno_Turma`
--

DROP TABLE IF EXISTS `Aluno_Turma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Aluno_Turma` (
  `email_aluno` varchar(45) NOT NULL,
  `cod_turma` varchar(8) NOT NULL,
  `ativo` int DEFAULT '1',
  PRIMARY KEY (`email_aluno`,`cod_turma`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Conteudo_Quest`
--

DROP TABLE IF EXISTS `Conteudo_Quest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Conteudo_Quest` (
  `idConteudo_Quest` int NOT NULL,
  `cod_quest` varchar(45) NOT NULL,
  `conteudo` varchar(45) NOT NULL,
  PRIMARY KEY (`idConteudo_Quest`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cronograma`
--

DROP TABLE IF EXISTS `Cronograma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Cronograma` (
  `data` date NOT NULL,
  `cod_simulado` int DEFAULT NULL,
  `email` varchar(45) NOT NULL,
  PRIMARY KEY (`data`,`email`),
  KEY `cpf_idx` (`email`),
  KEY `cod_simulado_idx` (`cod_simulado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Estudio_Aluno`
--

DROP TABLE IF EXISTS `Estudio_Aluno`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Estudio_Aluno` (
  `CPFAluno` varchar(15) NOT NULL,
  `nomeAluno` varchar(45) DEFAULT NULL,
  `ruaAluno` varchar(45) DEFAULT NULL,
  `numeroAluno` varchar(45) DEFAULT NULL,
  `bairroAluno` varchar(45) DEFAULT NULL,
  `complementoAluno` varchar(45) DEFAULT NULL,
  `CEPAluno` varchar(45) DEFAULT NULL,
  `cidadeAluno` varchar(45) DEFAULT NULL,
  `estadoAluno` varchar(45) DEFAULT NULL,
  `telefoneAluno` varchar(45) DEFAULT NULL,
  `emailAluno` varchar(45) DEFAULT NULL,
  `fotoAluno` longblob,
  `ativo` int DEFAULT '0',
  PRIMARY KEY (`CPFAluno`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Estudio_Aluno_Turma`
--

DROP TABLE IF EXISTS `Estudio_Aluno_Turma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Estudio_Aluno_Turma` (
  `idEstudio_Aluno_Turma` int NOT NULL AUTO_INCREMENT,
  `idAluno` varchar(15) DEFAULT NULL,
  `idTurma` int DEFAULT NULL,
  `ativo` int DEFAULT '0',
  PRIMARY KEY (`idEstudio_Aluno_Turma`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Estudio_Login`
--

DROP TABLE IF EXISTS `Estudio_Login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Estudio_Login` (
  `usuario` varchar(45) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `senha` varchar(8) CHARACTER SET latin1 COLLATE latin1_bin DEFAULT NULL,
  `tipo` int DEFAULT NULL,
  PRIMARY KEY (`usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Estudio_Modalidade`
--

DROP TABLE IF EXISTS `Estudio_Modalidade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Estudio_Modalidade` (
  `idEstudio_Modalidade` int NOT NULL AUTO_INCREMENT,
  `descricaoModalidade` varchar(45) DEFAULT NULL,
  `precoModalidade` float DEFAULT NULL,
  `qtdAlunos` int DEFAULT NULL,
  `qtdAulas` int DEFAULT NULL,
  `ativo` int DEFAULT '0',
  PRIMARY KEY (`idEstudio_Modalidade`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Estudio_Turma`
--

DROP TABLE IF EXISTS `Estudio_Turma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Estudio_Turma` (
  `idEstudio_Turma` int NOT NULL AUTO_INCREMENT,
  `idModalidade` int DEFAULT NULL,
  `professorTurma` varchar(45) DEFAULT NULL,
  `diaSemanaTurma` varchar(45) DEFAULT NULL,
  `horaTurma` varchar(45) DEFAULT NULL,
  `nAlunosMatriculadosTurma` int DEFAULT '0',
  `ativoTurma` int DEFAULT '0',
  PRIMARY KEY (`idEstudio_Turma`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `HorarioMult`
--

DROP TABLE IF EXISTS `HorarioMult`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `HorarioMult` (
  `email` varchar(45) NOT NULL,
  `data` date NOT NULL,
  `horario_inicio` float NOT NULL,
  `horario_fim` varchar(45) NOT NULL,
  `disciplina` varchar(20) DEFAULT NULL,
  `conteudo` varchar(20) DEFAULT NULL,
  `descricao` varchar(300) DEFAULT NULL,
  `titulo` varchar(45) NOT NULL,
  `dia_inteiro` tinyint DEFAULT NULL,
  `cor` varchar(45) DEFAULT NULL,
  `serie` int DEFAULT NULL,
  PRIMARY KEY (`email`,`data`,`horario_inicio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Professor`
--

DROP TABLE IF EXISTS `Professor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Professor` (
  `email` varchar(50) NOT NULL,
  `senha` varchar(100) NOT NULL,
  `nome` varchar(60) NOT NULL,
  `ativo` int DEFAULT '1',
  `sobrenome` varchar(70) NOT NULL,
  `foto` longblob,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Quest_Simu`
--

DROP TABLE IF EXISTS `Quest_Simu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Quest_Simu` (
  `cod_simulado` int NOT NULL,
  `cod_quest` int NOT NULL,
  PRIMARY KEY (`cod_simulado`,`cod_quest`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Questao`
--

DROP TABLE IF EXISTS `Questao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Questao` (
  `cod_questao` int NOT NULL AUTO_INCREMENT,
  `vestibular` varchar(10) NOT NULL,
  `ano` year NOT NULL,
  `fase` varchar(15) DEFAULT NULL,
  `disciplina` varchar(20) NOT NULL,
  `conteudo` varchar(25) NOT NULL,
  `enunciado` mediumtext NOT NULL,
  `imagem` longblob,
  `alternativaA` mediumtext,
  `alternativaB` mediumtext,
  `alternativaC` mediumtext,
  `alternativaD` mediumtext,
  `alternativaE` mediumtext,
  `resposta` mediumtext NOT NULL,
  `ativo` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`cod_questao`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Relatorio_Questao`
--

DROP TABLE IF EXISTS `Relatorio_Questao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Relatorio_Questao` (
  `cod_quest` int NOT NULL,
  `email` varchar(45) NOT NULL,
  `acertou/errou` int NOT NULL,
  `tipo_usu` varchar(10) NOT NULL,
  PRIMARY KEY (`cod_quest`,`email`,`tipo_usu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Relatorio_Simulado`
--

DROP TABLE IF EXISTS `Relatorio_Simulado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Relatorio_Simulado` (
  `cod_simulado` int NOT NULL,
  `email_aluno` varchar(45) NOT NULL,
  `acertos` int DEFAULT NULL,
  `erros` int DEFAULT NULL,
  PRIMARY KEY (`cod_simulado`,`email_aluno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Simulado`
--

DROP TABLE IF EXISTS `Simulado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Simulado` (
  `cod_simulado` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(20) NOT NULL,
  `descricao` varchar(300) DEFAULT NULL,
  `conclusao` int NOT NULL DEFAULT '0',
  `tempo` float DEFAULT NULL,
  `email_aluno` varchar(45) DEFAULT NULL,
  `email_prof` varchar(45) DEFAULT NULL,
  `tipo_usu` varchar(8) NOT NULL,
  PRIMARY KEY (`cod_simulado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Turma`
--

DROP TABLE IF EXISTS `Turma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Turma` (
  `cod_turma` varchar(8) NOT NULL,
  `nome_turma` varchar(45) NOT NULL,
  `email_prof` varchar(45) NOT NULL,
  `ativo` int DEFAULT '1',
  PRIMARY KEY (`cod_turma`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Turma_Simulado`
--

DROP TABLE IF EXISTS `Turma_Simulado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Turma_Simulado` (
  `cod_simulado` int NOT NULL,
  `cod_turma` varchar(8) NOT NULL,
  `ativo` int DEFAULT NULL,
  `id_publicacao` varchar(45) NOT NULL,
  `data_publicacao` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_publicacao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'cl204179'
--

--
-- Dumping routines for database 'cl204179'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-29 10:43:00
