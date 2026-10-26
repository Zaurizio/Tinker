package Tinker.demo.service;

import org.springframework.stereotype.Component;

import java.security.SecureRandom;

@Component
public class GeradorCodigoTurma {

    private static final int LIMITE = 100_000_000;
    private final SecureRandom random = new SecureRandom();

    public String gerar() {
        return String.format("%08d", random.nextInt(LIMITE));
    }
}
