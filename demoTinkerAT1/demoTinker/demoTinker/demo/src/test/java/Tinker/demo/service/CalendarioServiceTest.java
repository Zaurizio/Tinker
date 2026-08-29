package Tinker.demo.service;

import Tinker.demo.dto.calendario.CriarEventoDTO;
import Tinker.demo.dto.calendario.EventoCalendarioDTO;
import Tinker.demo.dto.calendario.RecorrenciaEvento;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.ConflitoDominioException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.model.HorarioMult;
import Tinker.demo.repository.HorarioMultRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneOffset;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class CalendarioServiceTest {

    private HorarioMultRepository repository;
    private CalendarioService service;

    @BeforeEach
    void configurar() {
        repository = mock(HorarioMultRepository.class);
        Clock clock = Clock.fixed(Instant.parse("2026-08-28T15:00:00Z"), ZoneOffset.UTC);
        service = new CalendarioService(repository, clock);
        when(repository.saveAll(any())).thenAnswer(invocacao -> invocacao.getArgument(0));
    }

    @Test
    void alunoListaSomentePeloProprioEmailSemEscrever() {
        when(repository.findByEmailOrderByDataAscHorarioInicioAsc("aluno@teste.com"))
                .thenReturn(List.of(evento("aluno@teste.com", "2026-09-01", 9f)));

        List<EventoCalendarioDTO> resultado = service.listar(aluno());

        assertEquals(1, resultado.size());
        verify(repository).findByEmailOrderByDataAscHorarioInicioAsc("aluno@teste.com");
        verify(repository, never()).save(any());
        verify(repository, never()).saveAll(any());
        verify(repository, never()).delete(any());
    }

    @Test
    void professorListaSomentePeloProprioEmail() {
        service.listar(professor());
        verify(repository).findByEmailOrderByDataAscHorarioInicioAsc("professor@teste.com");
    }

    @Test
    void administradorRecebe403() {
        AcessoNegadoException erro = assertThrows(AcessoNegadoException.class,
                () -> service.listar(new UsuarioAutenticado("admin@teste.com", TipoUsuario.ADMINISTRADOR)));
        assertEquals(403, erro.getStatus().value());
        verify(repository, never()).findAll();
    }

    @Test
    void alunoEProfessorComMesmoEmailCompartilhamCalendario() {
        String emailCompartilhado = "mesmo@teste.com";
        List<HorarioMult> eventos = List.of(evento(emailCompartilhado, "2026-09-01", 9f));
        when(repository.findByEmailOrderByDataAscHorarioInicioAsc(emailCompartilhado)).thenReturn(eventos);

        UsuarioAutenticado aluno = new UsuarioAutenticado(emailCompartilhado, TipoUsuario.ALUNO);
        UsuarioAutenticado professor = new UsuarioAutenticado(emailCompartilhado, TipoUsuario.PROFESSOR);

        assertEquals(service.listar(aluno), service.listar(professor));
        verify(repository, org.mockito.Mockito.times(2))
                .findByEmailOrderByDataAscHorarioInicioAsc(emailCompartilhado);
    }

    @Test
    void criacaoUsaEmailAutenticadoECriaEventoFuturo() {
        EventoCalendarioDTO criado = service.criar(aluno(), dto("2026-09-10", RecorrenciaEvento.NENHUMA, null)).get(0);

        verify(repository).existsById(new Tinker.demo.model.HorarioMultid("aluno@teste.com", LocalDate.of(2026, 9, 10), 14f));
        assertEquals("Prova", criado.titulo());
        assertFalse(Arrays.stream(CriarEventoDTO.class.getRecordComponents())
                .anyMatch(c -> c.getName().equals("email")));
    }

    @Test
    void rejeitaEventoNoPassado() {
        assertCodigo("EVENTO_NO_PASSADO", () ->
                service.criar(aluno(), dto("2026-08-27", RecorrenciaEvento.NENHUMA, null)));
    }

    @Test
    void rejeitaTituloVazio() {
        CriarEventoDTO vazio = new CriarEventoDTO("   ", LocalDate.of(2026, 9, 1),
                LocalTime.of(14, 0), LocalTime.of(15, 0), false, "#2F80ED",
                RecorrenciaEvento.NENHUMA, null);
        assertCodigo("TITULO_OBRIGATORIO", () -> service.criar(aluno(), vazio));
        verify(repository, never()).saveAll(any());
    }

    @Test
    void rejeitaHorarioFinalMenorOuIgualAoInicial() {
        CriarEventoDTO menor = new CriarEventoDTO("Prova", LocalDate.of(2026, 9, 1),
                LocalTime.of(14, 0), LocalTime.of(13, 59), false, "#2F80ED", RecorrenciaEvento.NENHUMA, null);
        CriarEventoDTO igual = new CriarEventoDTO("Prova", LocalDate.of(2026, 9, 1),
                LocalTime.of(14, 0), LocalTime.of(14, 0), false, "#2F80ED", RecorrenciaEvento.NENHUMA, null);
        assertCodigo("INTERVALO_INVALIDO", () -> service.criar(aluno(), menor));
        assertCodigo("INTERVALO_INVALIDO", () -> service.criar(aluno(), igual));
    }

    @Test
    void diaInteiroIgnoraHorarios() {
        CriarEventoDTO dto = new CriarEventoDTO("  Feriado  ", LocalDate.of(2026, 9, 1),
                null, null, true, "#2F80ED", RecorrenciaEvento.NENHUMA, null);
        EventoCalendarioDTO criado = service.criar(aluno(), dto).get(0);
        assertEquals("Feriado", criado.titulo());
        assertNull(criado.horarioInicio());
        assertNull(criado.horarioFim());
    }

    @Test
    void recorrenciaDiariaCriaOcorrenciasCorretas() {
        assertDatas(RecorrenciaEvento.DIARIA, 3,
                "2026-09-10", "2026-09-11", "2026-09-12");
    }

    @Test
    void recorrenciaSemanalCriaOcorrenciasCorretas() {
        assertDatas(RecorrenciaEvento.SEMANAL, 3,
                "2026-09-10", "2026-09-17", "2026-09-24");
    }

    @Test
    void recorrenciaMensalPreservaDiaOriginalQuandoPossivel() {
        List<EventoCalendarioDTO> criados = service.criar(aluno(), new CriarEventoDTO(
                "Prova", LocalDate.of(2027, 1, 31), LocalTime.of(14, 0), LocalTime.of(15, 30),
                false, "#2F80ED", RecorrenciaEvento.MENSAL, 3));
        assertEquals(List.of(LocalDate.of(2027, 1, 31), LocalDate.of(2027, 2, 28), LocalDate.of(2027, 3, 31)),
                criados.stream().map(EventoCalendarioDTO::data).toList());
    }

    @Test
    void recorrenciaNaoPodeSerInfinita() {
        assertCodigo("REPETICOES_INVALIDAS", () ->
                service.criar(aluno(), dto("2026-09-10", RecorrenciaEvento.DIARIA, null)));
        assertCodigo("REPETICOES_INVALIDAS", () ->
                service.criar(aluno(), dto("2026-09-10", RecorrenciaEvento.DIARIA, 366)));
    }

    @Test
    void conflitoAntesDaUltimaOcorrenciaNaoExecutaSaveAll() {
        when(repository.existsById(any())).thenReturn(false, true);
        assertThrows(ConflitoDominioException.class, () ->
                service.criar(aluno(), dto("2026-09-10", RecorrenciaEvento.DIARIA, 3)));
        verify(repository, never()).saveAll(any());
    }

    @Test
    void listagemPreservaOrdenacaoDoRepositorio() {
        HorarioMult primeiro = evento("aluno@teste.com", "2026-09-01", 8f);
        HorarioMult segundo = evento("aluno@teste.com", "2026-09-01", 14f);
        when(repository.findByEmailOrderByDataAscHorarioInicioAsc("aluno@teste.com"))
                .thenReturn(List.of(primeiro, segundo));
        assertEquals(List.of(LocalTime.of(8, 0), LocalTime.of(14, 0)),
                service.listar(aluno()).stream().map(EventoCalendarioDTO::horarioInicio).toList());
    }

    @Test
    void dtoDeRespostaNaoExpoeEmailNemEntidade() {
        assertEquals(List.of("id", "titulo", "data", "horarioInicio", "horarioFim", "diaInteiro", "cor"),
                Arrays.stream(EventoCalendarioDTO.class.getRecordComponents()).map(c -> c.getName()).toList());
        assertFalse(HorarioMult.class.isAssignableFrom(EventoCalendarioDTO.class));
    }

    private void assertDatas(RecorrenciaEvento recorrencia, int repeticoes, String... datas) {
        List<EventoCalendarioDTO> criados = service.criar(
                aluno(), dto("2026-09-10", recorrencia, repeticoes));
        assertEquals(Arrays.stream(datas).map(LocalDate::parse).toList(),
                criados.stream().map(EventoCalendarioDTO::data).toList());
    }

    private CriarEventoDTO dto(String data, RecorrenciaEvento recorrencia, Integer repeticoes) {
        return new CriarEventoDTO("  Prova  ", LocalDate.parse(data), LocalTime.of(14, 0),
                LocalTime.of(15, 30), false, "#2F80ED", recorrencia, repeticoes);
    }

    private HorarioMult evento(String email, String data, float inicio) {
        HorarioMult evento = new HorarioMult();
        evento.setEmail(email);
        evento.setData(LocalDate.parse(data));
        evento.setHorarioInicio(inicio);
        evento.setHorarioFim("15:30");
        evento.setTitulo("Evento");
        evento.setDiaInteiro(0);
        evento.setCor("#2F80ED");
        return evento;
    }

    private UsuarioAutenticado aluno() {
        return new UsuarioAutenticado("aluno@teste.com", TipoUsuario.ALUNO);
    }

    private UsuarioAutenticado professor() {
        return new UsuarioAutenticado("professor@teste.com", TipoUsuario.PROFESSOR);
    }

    private void assertCodigo(String codigo, Runnable acao) {
        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class, acao::run);
        assertEquals(codigo, erro.getCodigo());
    }
}
