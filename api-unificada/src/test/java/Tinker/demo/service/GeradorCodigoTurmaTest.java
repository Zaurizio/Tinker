package Tinker.demo.service;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

class GeradorCodigoTurmaTest {

    @Test
    void sempreGeraTextoComOitoDigitos() {
        GeradorCodigoTurma gerador = new GeradorCodigoTurma();

        for (int tentativa = 0; tentativa < 100; tentativa++) {
            assertTrue(gerador.gerar().matches("^[0-9]{8}$"));
        }
    }
}
