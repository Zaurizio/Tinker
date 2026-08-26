package Tinker.demo.mapper;

import Tinker.demo.dto.auth.LoginResponseDTO;
import Tinker.demo.model.Aluno;
import org.springframework.stereotype.Component;

@Component
public class LoginMapper {

    public LoginResponseDTO paraResposta(Aluno aluno) {
        return new LoginResponseDTO(aluno.getEmail(), aluno.getNome(), aluno.getSobrenome());
    }
}
