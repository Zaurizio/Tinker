package Tinker.demo.service;

import Tinker.demo.dto.calendario.CriarEventoDTO;
import Tinker.demo.dto.calendario.EventoCalendarioDTO;
import Tinker.demo.dto.calendario.RecorrenciaEvento;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.ConflitoDominioException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.model.HorarioMult;
import Tinker.demo.model.HorarioMultid;
import Tinker.demo.repository.HorarioMultRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;

@Service
public class CalendarioService {

    public static final int LIMITE_REPETICOES = 365;
    private static final float INICIO_DIA_INTEIRO = -1.0f;
    private static final String FIM_DIA_INTEIRO = "DIA_INTEIRO";

    private final HorarioMultRepository repository;
    private final Clock clock;

    @Autowired
    public CalendarioService(HorarioMultRepository repository) {
        this(repository, Clock.systemDefaultZone());
    }

    CalendarioService(HorarioMultRepository repository, Clock clock) {
        this.repository = repository;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public List<EventoCalendarioDTO> listar(UsuarioAutenticado usuario) {
        validarUsuarioPermitido(usuario);
        return repository.findByEmailOrderByDataAscHorarioInicioAsc(usuario.email()).stream()
                .map(this::paraDTO)
                .toList();
    }

    @Transactional
    public List<EventoCalendarioDTO> criar(UsuarioAutenticado usuario, CriarEventoDTO entrada) {
        validarUsuarioPermitido(usuario);
        String titulo = entrada.titulo() == null ? "" : entrada.titulo().trim();
        if (titulo.isEmpty()) {
            throw new DadosInvalidosException("TITULO_OBRIGATORIO", "O título é obrigatório.");
        }
        validarHorariosEData(entrada);
        int total = validarEObterRepeticoes(entrada);

        List<HorarioMult> ocorrencias = new ArrayList<>(total);
        for (int indice = 0; indice < total; indice++) {
            LocalDate data = dataDaOcorrencia(entrada.data(), entrada.recorrencia(), indice);
            float inicio = Boolean.TRUE.equals(entrada.diaInteiro())
                    ? INICIO_DIA_INTEIRO : paraFloat(entrada.horarioInicio());
            HorarioMultid id = new HorarioMultid(usuario.email(), data, inicio);
            if (repository.existsById(id)) {
                throw new ConflitoDominioException(
                        "EVENTO_JA_EXISTE", "Já existe um evento nesse dia e horário.");
            }

            HorarioMult evento = new HorarioMult();
            evento.setEmail(usuario.email());
            evento.setData(data);
            evento.setHorarioInicio(inicio);
            evento.setHorarioFim(Boolean.TRUE.equals(entrada.diaInteiro())
                    ? FIM_DIA_INTEIRO : entrada.horarioFim().toString());
            evento.setTitulo(titulo);
            evento.setDiaInteiro(Boolean.TRUE.equals(entrada.diaInteiro()));
            evento.setCor(entrada.cor());
            ocorrencias.add(evento);
        }

        return repository.saveAll(ocorrencias).stream().map(this::paraDTO).toList();
    }

    private void validarUsuarioPermitido(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() == TipoUsuario.ADMINISTRADOR) {
            throw new AcessoNegadoException(
                    "CALENDARIO_NAO_PERMITIDO", "Administrador não possui calendário pessoal.");
        }
    }

    private void validarHorariosEData(CriarEventoDTO entrada) {
        LocalDate hoje = LocalDate.now(clock);
        if (entrada.data().isBefore(hoje)) {
            throw passado();
        }
        if (Boolean.TRUE.equals(entrada.diaInteiro())) {
            return;
        }
        if (entrada.horarioInicio() == null || entrada.horarioFim() == null) {
            throw new DadosInvalidosException(
                    "HORARIOS_OBRIGATORIOS", "Horários inicial e final são obrigatórios.");
        }
        if (!entrada.horarioFim().isAfter(entrada.horarioInicio())) {
            throw new DadosInvalidosException(
                    "INTERVALO_INVALIDO", "O horário final deve ser maior que o horário inicial.");
        }
        if (entrada.data().equals(hoje)
                && !LocalDateTime.of(entrada.data(), entrada.horarioInicio()).isAfter(LocalDateTime.now(clock))) {
            throw passado();
        }
    }

    private int validarEObterRepeticoes(CriarEventoDTO entrada) {
        if (entrada.recorrencia() == RecorrenciaEvento.NENHUMA) {
            if (entrada.repeticoes() != null && entrada.repeticoes() != 1) {
                throw new DadosInvalidosException(
                        "REPETICOES_INVALIDAS", "Evento sem recorrência aceita no máximo uma ocorrência.");
            }
            return 1;
        }
        if (entrada.repeticoes() == null || entrada.repeticoes() < 2
                || entrada.repeticoes() > LIMITE_REPETICOES) {
            throw new DadosInvalidosException(
                    "REPETICOES_INVALIDAS",
                    "Eventos recorrentes exigem entre 2 e " + LIMITE_REPETICOES + " repetições.");
        }
        return entrada.repeticoes();
    }

    private LocalDate dataDaOcorrencia(LocalDate original, RecorrenciaEvento recorrencia, int indice) {
        return switch (recorrencia) {
            case NENHUMA -> original;
            case DIARIA -> original.plusDays(indice);
            case SEMANAL -> original.plusWeeks(indice);
            case MENSAL -> {
                YearMonth mes = YearMonth.from(original).plusMonths(indice);
                yield mes.atDay(Math.min(original.getDayOfMonth(), mes.lengthOfMonth()));
            }
        };
    }

    private EventoCalendarioDTO paraDTO(HorarioMult evento) {
        boolean diaInteiro = Boolean.TRUE.equals(evento.getDiaInteiro());
        LocalTime inicio = diaInteiro ? null : deFloat(evento.getHorarioInicio());
        LocalTime fim = diaInteiro ? null : LocalTime.parse(evento.getHorarioFim());
        String id = evento.getData() + "|" + (diaInteiro ? "DIA_INTEIRO" : inicio);
        return new EventoCalendarioDTO(
                id, evento.getTitulo(), evento.getData(), inicio, fim, diaInteiro, evento.getCor());
    }

    private float paraFloat(LocalTime horario) {
        return horario.getHour() + horario.getMinute() / 60.0f;
    }

    private LocalTime deFloat(float horario) {
        int minutosTotais = Math.round(horario * 60);
        return LocalTime.of(minutosTotais / 60, minutosTotais % 60);
    }

    private DadosInvalidosException passado() {
        return new DadosInvalidosException(
                "EVENTO_NO_PASSADO", "Não é possível criar evento em data ou horário que já passou.");
    }
}
