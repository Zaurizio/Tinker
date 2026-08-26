package Tinker.demo.controller;

import Tinker.demo.dto.LoginRequest;
import Tinker.demo.dto.LoginResponse;
import Tinker.demo.model.Aluno;
import Tinker.demo.repository.AlunoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/login")
public class LoginController {

    @Autowired
    private AlunoRepository alunoRepository;

    @PostMapping
    public ResponseEntity<?> login(@RequestBody LoginRequest dados) {
        Optional<Aluno> alunoOpt = alunoRepository.findById(dados.getEmail());

        if (alunoOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("E-mail ou senha incorretos");
        }

        Aluno aluno = alunoOpt.get();

        if (aluno.getSenha() == null || !aluno.getSenha().equals(dados.getSenha())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("E-mail ou senha incorretos");
        }

        LoginResponse resposta = new LoginResponse(aluno.getEmail(), aluno.getNome(), aluno.getSobrenome());
        return ResponseEntity.ok(resposta);
    }
}