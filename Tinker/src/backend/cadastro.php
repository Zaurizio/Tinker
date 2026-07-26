<?php 
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");
    header("Content-Type: application/json");
    require_once "./config.php" ;
    
    $erros = [];
    if (empty($_POST["nome"])) $erros[] = "Nome é obrigatório";
    if (empty($_POST["sobrenome"])) $erros[] = "Sobrenome é obrigatório";
    if (empty($_POST["email"])) $erros[] = "Email é obrigatório";
    if (empty($_POST["senha"])) $erros[] = "Senha é obrigatória";
    //if (preg_match('/\d/', $_POST["nome"])) $erros[] = "Nome deve conter apenas letras";
    //if (preg_match('/\d/', $_POST["sobrenome"])) $erros[] = "Sobrenome deve conter apenas letras";

    if (count($erros) > 0) {
        echo json_encode(["sucesso" => false, "mensagem" => implode(", ", $erros)]);
        exit;
    }
    
    $nome = $_POST["nome"] ;
    $sobrenome = $_POST["sobrenome"];
    $email = $_POST["email"];
    $senha = $_POST["senha"];

    $sql = "INSERT INTO Aluno(nome, sobrenome, email, senha, nascimento) VALUES('$nome', '$sobrenome', '$email', '$senha', '2001-09-11')";
    
    $resultado = $conn->query($sql);

    if($resultado){
       echo json_encode(["sucesso" => true, "mensagem" => "Cadastro realizado!"]);
    }
    else{
        echo json_encode(["sucesso" => false, "mensagem" => implode(", ", $erros)]);  
    }




