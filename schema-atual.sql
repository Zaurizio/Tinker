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
-- Dumping data for table `Administrador`
--

LOCK TABLES `Administrador` WRITE;
/*!40000 ALTER TABLE `Administrador` DISABLE KEYS */;
INSERT INTO `Administrador` VALUES ('rafa',123);
/*!40000 ALTER TABLE `Administrador` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Aluno`
--

LOCK TABLES `Aluno` WRITE;
/*!40000 ALTER TABLE `Aluno` DISABLE KEYS */;
INSERT INTO `Aluno` VALUES ('a','a','','a','a','1952-11-30',0),('aa','aa','','11','aa','1999-11-11',0),('adfdfd@','asfddafad','','sadadfda','afadfadf','1951-11-11',0),('afd@s','asdd',NULL,'sfghf','fdghf','2001-09-11',1),('asdaf@','dafdf','','dafffd1','adfdf1','2001-11-11',0),('asdsda','sada','','dfadf','dfdaf','2001-11-11',0),('c@','asdfdaf','','adfagd','adgagf','2013-12-31',1),('cc@c','c','','caco','c','1990-11-11',1),('dfdsfdfd@','asdfadf','','adfadfd','adfdfd','1987-11-11',1),('dfsgdgdg','sdfggg','','sdghgh','gdshgdh','1900-11-11',1),('fafa@fa','1234',NULL,'rfafa','faff','2001-09-11',1),('faffa@a','1234',NULL,'rafael','graco','2001-09-11',1),('g@gmail.com','123456',NULL,'Gustavo','Zaurizio','2001-09-11',1),('gabi@g','1234',NULL,'gabi','graca','2001-09-11',1),('gu@gz','123',NULL,'gu','gz','2001-09-11',1),('gustavozau@d','123',NULL,'gustavo','zau','2001-09-11',1),('lucas@gg','zdasddf',NULL,'lucas','asad','2001-09-11',1),('lucasg@gmail.com','123456',NULL,'Lucas ','Gabriela','2001-09-11',1),('priscila@gmail','123456',NULL,'Tânia','Basso','2001-09-11',1),('rafa@f','123',NULL,'rafa','fadfafd','2001-09-11',1),('rafaafa@a','1234',NULL,'xgdhf','dfsfsf','2001-09-11',1),('saddadd@','sadada','','dafdf','dfdaf','2014-11-11',1),('saddfdf@','sadafdaf','','dafadfd','adffdaf','2001-11-11',0),('sadfadfdaf@','adfdfd','','dfafdfad','dfadfdaf','1950-02-28',0),('sadfdf@','adfdf','','adfdff','dafdafad','2001-11-11',0),('sdfsgsgss@ad','adasdffs',NULL,'asfd','fsgs','2001-09-11',1),('sffsgfs','sfgfsgsf','','fsgfsgsf','fsgfsg','1960-11-11',1),('vcfoigoiabado@gmail','sdafadf','','adfdfdaf','adfdafdaf','2001-09-11',1);
/*!40000 ALTER TABLE `Aluno` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Aluno_Turma`
--

LOCK TABLES `Aluno_Turma` WRITE;
/*!40000 ALTER TABLE `Aluno_Turma` DISABLE KEYS */;
INSERT INTO `Aluno_Turma` VALUES ('c@','6',1),('cc','4',0),('cc','6',0),('g@gmail.com','11',1),('g@gmail.com','12',1),('vcfoigoiabado@gmail','1',0),('vcfoigoiabado@gmail','3',0),('vcfoigoiabado@gmail','4',1);
/*!40000 ALTER TABLE `Aluno_Turma` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Conteudo_Quest`
--

LOCK TABLES `Conteudo_Quest` WRITE;
/*!40000 ALTER TABLE `Conteudo_Quest` DISABLE KEYS */;
/*!40000 ALTER TABLE `Conteudo_Quest` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Cronograma`
--

LOCK TABLES `Cronograma` WRITE;
/*!40000 ALTER TABLE `Cronograma` DISABLE KEYS */;
/*!40000 ALTER TABLE `Cronograma` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Estudio_Aluno`
--

LOCK TABLES `Estudio_Aluno` WRITE;
/*!40000 ALTER TABLE `Estudio_Aluno` DISABLE KEYS */;
INSERT INTO `Estudio_Aluno` VALUES ('111,111,111-11','aa','aaaaa','1','aeda','2qasas','111,1111-1111','adasf','sdadfa','(11)11111-1111','1adfasdgsr',NULL,1),('111,222,222-22','asdafa','asdffe','11','3adf','asdav','676,7676-7679','afdf','dcdaf','(69)69696-9696','cscvsfbgdnhfjmgd',NULL,0),('492,305,285-96','Shrek Sensual','Rua das sapecagens','69','sensualidades e seduções','67','384,5238-5766','Seduções','SP','(90)48577-3858','OmaisSensualGostoso@gmail.com',_binary 'System.Byte[]',0),('999,999,999-99','Gil Goiaba','Rua das Goiabas','6769','Árvores','casa 12','676,7676-7767','Pomares','Goiás','(69)69696-9696','pegounagoiaba@gmail.com',_binary 'System.Byte[]',0);
/*!40000 ALTER TABLE `Estudio_Aluno` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Estudio_Aluno_Turma`
--

LOCK TABLES `Estudio_Aluno_Turma` WRITE;
/*!40000 ALTER TABLE `Estudio_Aluno_Turma` DISABLE KEYS */;
INSERT INTO `Estudio_Aluno_Turma` VALUES (1,'111,111,111-11',2,0),(2,'111,111,111-11',1,1),(3,'999,999,999-99',1,1),(4,'111,222,222-22',2,1),(5,'111,222,222-22',2,1),(6,'999,999,999-99',2,0),(7,'492,305,285-96',1,0);
/*!40000 ALTER TABLE `Estudio_Aluno_Turma` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Estudio_Login`
--

LOCK TABLES `Estudio_Login` WRITE;
/*!40000 ALTER TABLE `Estudio_Login` DISABLE KEYS */;
INSERT INTO `Estudio_Login` VALUES ('','',0),('lucas','123',1),('rafa','123',2),('teste','123',1);
/*!40000 ALTER TABLE `Estudio_Login` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Estudio_Modalidade`
--

LOCK TABLES `Estudio_Modalidade` WRITE;
/*!40000 ALTER TABLE `Estudio_Modalidade` DISABLE KEYS */;
INSERT INTO `Estudio_Modalidade` VALUES (1,'Pilates',50,12,2,0),(2,'Zumba',64,22,13,1),(3,'Box',75,21,4,0),(4,'Ballet',120,10,2,0),(5,'Teste222',150,10,2,1);
/*!40000 ALTER TABLE `Estudio_Modalidade` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Estudio_Turma`
--

LOCK TABLES `Estudio_Turma` WRITE;
/*!40000 ALTER TABLE `Estudio_Turma` DISABLE KEYS */;
INSERT INTO `Estudio_Turma` VALUES (1,3,'Lucas','Quinta-feira','12:05',1,0),(2,3,'Rafael','Quinta-feira','13:00',2,0),(3,4,'Priscila','qua','19:30',0,1);
/*!40000 ALTER TABLE `Estudio_Turma` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `HorarioMult`
--

LOCK TABLES `HorarioMult` WRITE;
/*!40000 ALTER TABLE `HorarioMult` DISABLE KEYS */;
/*!40000 ALTER TABLE `HorarioMult` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Professor`
--

LOCK TABLES `Professor` WRITE;
/*!40000 ALTER TABLE `Professor` DISABLE KEYS */;
INSERT INTO `Professor` VALUES ('000000000000000000','0','7',0,'',NULL),('11111111111','1111111111113','1111111111112222',0,'',NULL),('a','a','a',1,'aa',''),('affa','affa','affa',1,'affa',''),('asfdfd@','asdafdf','sdfdfda',1,'saasds',''),('asffad','131431','31434',0,'',NULL),('bb','bb','bb',1,'bb',''),('daagdhagd','fgadhgd','gdhgdhgdh',1,'adfdf',''),('dfdssgf','sfagf','fssgdhgd',1,'dghgdghgd',''),('gilgoiaba@gamil.com','vcfoigoiabado','Gil',1,'Goiaba',''),('goiaba@gmail','wddew','wfwfwr',1,'wrfrwfrwr',''),('qererwrw','werwrwr','rwtrtert',1,'wtrtrwrtrwtrw',''),('safdff@','afdfdf','dafadf',1,'adfafffa',''),('sdfsfg','sfgfsg','fsgsfgs',1,'gfsgfg','');
/*!40000 ALTER TABLE `Professor` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Quest_Simu`
--

LOCK TABLES `Quest_Simu` WRITE;
/*!40000 ALTER TABLE `Quest_Simu` DISABLE KEYS */;
/*!40000 ALTER TABLE `Quest_Simu` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Questao`
--

LOCK TABLES `Questao` WRITE;
/*!40000 ALTER TABLE `Questao` DISABLE KEYS */;
INSERT INTO `Questao` VALUES (1,'teste',1999,'1','teste','','teste',NULL,NULL,NULL,NULL,NULL,NULL,'teste',0),(2,'asf',1967,'Primeira Fase','asf','asf','asf','','asf','asf','asf','asf','asf','B',1),(3,'UniTrivial',1967,'Segundo Dia','Matemática','Função Seno','asdad',_binary 'System.Byte[]','addad','asdad','asdad','asdasd','asdd','D',1),(4,'adfadf',1967,'Segundo Dia','adfda','dffdaa','afafdafdaa','','adfadfafdaff','adfdadfa','fdaffafdaadfd','adadfaf','dfdafddaff','C',0),(5,'UniTrivial',1967,'Segundo Dia','Português','Análise Sintática','adfghj',_binary 'System.Byte[]','','','','','','dsfghj',1);
/*!40000 ALTER TABLE `Questao` ENABLE KEYS */;
UNLOCK TABLES;

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
  `tipo_usu` varchar(8) NOT NULL,
  PRIMARY KEY (`cod_quest`,`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Relatorio_Questao`
--

LOCK TABLES `Relatorio_Questao` WRITE;
/*!40000 ALTER TABLE `Relatorio_Questao` DISABLE KEYS */;
INSERT INTO `Relatorio_Questao` VALUES (2,'g@gmail.com',1,''),(3,'g@gmail.com',0,'');
/*!40000 ALTER TABLE `Relatorio_Questao` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Relatorio_Simulado`
--

LOCK TABLES `Relatorio_Simulado` WRITE;
/*!40000 ALTER TABLE `Relatorio_Simulado` DISABLE KEYS */;
/*!40000 ALTER TABLE `Relatorio_Simulado` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Simulado`
--

LOCK TABLES `Simulado` WRITE;
/*!40000 ALTER TABLE `Simulado` DISABLE KEYS */;
/*!40000 ALTER TABLE `Simulado` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Turma`
--

LOCK TABLES `Turma` WRITE;
/*!40000 ALTER TABLE `Turma` DISABLE KEYS */;
INSERT INTO `Turma` VALUES ('10','afggdhh','goiaba@gmail',1),('11','bolas','g@gmail.com',1),('12','Matematica-Fuvest','g@gmail.com',1),('4','Turma da Goiaba','goiaba@gmail',1),('5','a','a',0),('6','dc','bb',0),('7','abc','a',0),('8','adfddaf','goiaba@gmail',1),('9','afggdhhfj','goiaba@gmail',1);
/*!40000 ALTER TABLE `Turma` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `Turma_Simulado`
--

LOCK TABLES `Turma_Simulado` WRITE;
/*!40000 ALTER TABLE `Turma_Simulado` DISABLE KEYS */;
/*!40000 ALTER TABLE `Turma_Simulado` ENABLE KEYS */;
UNLOCK TABLES;

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

-- Dump completed on 2026-08-27 17:08:15
