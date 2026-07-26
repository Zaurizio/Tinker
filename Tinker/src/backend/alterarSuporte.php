<?php
    session_start();
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");
    header("Content-Type: application/json");
    require_once "./config.php" ;

    $erros = [];
    if (empty($_POST["nome"])) $erros[] = "Nome é obrigatório";
    if (empty($_POST["sobrenome"])) $erros[] = "Sobrenome é obrigatório";
    //if (preg_match('/\d/', $_POST["nome"])) $erros[] = "Nome deve conter apenas letras";
    //if (preg_match('/\d/', $_POST["sobrenome"])) $erros[] = "Sobrenome deve conter apenas letras";

    if (count($erros) > 0) {
        echo json_encode(["sucesso" => false, "mensagem" => implode(", ", $erros)]);
        exit;
    }

    $nome = $_POST["nome"] ;
    $sobrenome = $_POST["sobrenome"];
    $email = $_POST['email'];

    $sql = "UPDATE Aluno set nome = '$nome', sobrenome = '$sobrenome' WHERE email = '$email'";

    $resultado = $conn->query($sql);

    if($resultado){
       echo json_encode(["sucesso" => true, "mensagem" => "Alteração realizado!"]);
    }
    else{
        echo json_encode(["sucesso" => false, "mensagem" => implode(", ", $erros)]);  
    }