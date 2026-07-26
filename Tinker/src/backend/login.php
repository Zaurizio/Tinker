<?php 
    session_start();
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");
    header("Content-Type: application/json");
    require_once "./config.php" ;
    
    $erros = [];
    if (empty($_POST["email"])) $erros[] = "Email é obrigatório";
    if (empty($_POST["senha"])) $erros[] = "Senha é obrigatória";

    if (count($erros) > 0) {
        echo json_encode(["sucesso" => false, "mensagem" => implode(", ", $erros)]);
        exit;
    }
    
    $email = $_POST["email"];
    $senha = $_POST["senha"];

    $sql = "SELECT count(*) from Aluno where email = '$email' and senha = '$senha'";

    $resultado = $conn->query($sql);
    $linha = $resultado->fetch_row(); 
    $count = (int)$linha[0];

    if($count==1){
        $sql2 = "SELECT * from Aluno where email = '$email' and senha = '$senha'";
        $resultado2 = $conn->query($sql2);
        $linha2 = $resultado2->fetch_assoc();
        $_SESSION['email'] = $email;
        $_SESSION['senha'] = $senha;
        $nome = $linha2['nome'];
        $sobrenome = $linha2['sobrenome'];
        echo json_encode(["sucesso" => true, "mensagem" => "Login realizado!", "email" => $email, 
            "nome" => $nome, "sobrenome" => $sobrenome]);
    }
    else{
        echo json_encode(["sucesso" => false, "mensagem" => implode(", ", $erros)]);
    }