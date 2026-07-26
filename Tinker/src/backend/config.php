<?php
//$conn = new mysqli("localhost", "root", "", "loja");
    $conn = new mysqli("143.106.241.4", "cl204179", "cl*27042009", "cl204179");

    if ($conn->connect_error) {
        die("Erro na conexão: " . $conn->connect_error);
    }   
