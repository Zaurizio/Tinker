package Tinker.demo.controller;

import Tinker.demo.dto.auth.LoginRequestDTO;
import Tinker.demo.dto.auth.LoginResponseDTO;
import Tinker.demo.exception.CredenciaisInvalidasException;
import Tinker.demo.mapper.LoginMapper;
import Tinker.demo.model.Aluno;
import Tinker.demo.repository.AlunoRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/login")
public class LoginController {

    @Autowired
    private AlunoRepository alunoRepository;

    @Autowired
    private LoginMapper loginMapper;

    @PostMapping
    public ResponseEntity<LoginResponseDTO> login(@Valid @RequestBody LoginRequestDTO dados) {
        Optional<Aluno> alunoOpt = alunoRepository.findById(dados.getEmail());

        if (alunoOpt.isEmpty()) {
            throw new CredenciaisInvalidasException();
        }

        Aluno aluno = alunoOpt.get();

        if (aluno.getSenha() == null || !aluno.getSenha().equals(dados.getSenha())) {
            throw new CredenciaisInvalidasException();
        }

        return ResponseEntity.ok(loginMapper.paraResposta(aluno));
    }
}
