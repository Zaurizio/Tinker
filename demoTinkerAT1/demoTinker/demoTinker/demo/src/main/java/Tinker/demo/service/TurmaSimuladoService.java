package Tinker.demo.service;

import Tinker.demo.dto.turma.PublicacaoSimuladoDTO;
import Tinker.demo.dto.turma.PublicarSimuladoDTO;
import Tinker.demo.exception.ConflitoDominioException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.model.Simulado;
import Tinker.demo.model.Turma;
import Tinker.demo.model.TurmaSimulado;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.SimuladoRepository;
import Tinker.demo.repository.TurmaSimuladoRepository;
import Tinker.demo.security.UsuarioAutenticado;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

@Service
public class TurmaSimuladoService {

    private static final Integer ATIVO = 1;
    private static final Integer INATIVO = 0;
    private static final ZoneId FUSO_HORARIO = ZoneId.of("America/Sao_Paulo");

    private final TurmaService turmaService;
    private final TurmaSimuladoRepository turmaSimuladoRepository;
    private final SimuladoRepository simuladoRepository;
    private final QuestaoSimuRepository questaoSimuRepository;

    public TurmaSimuladoService(
            TurmaService turmaService,
            TurmaSimuladoRepository turmaSimuladoRepository,
            SimuladoRepository simuladoRepository,
            QuestaoSimuRepository questaoSimuRepository) {
        this.turmaService = turmaService;
        this.turmaSimuladoRepository = turmaSimuladoRepository;
        this.simuladoRepository = simuladoRepository;
        this.questaoSimuRepository = questaoSimuRepository;
    }

    @Transactional(readOnly = true)
    public List<PublicacaoSimuladoDTO> listar(UsuarioAutenticado usuario, String codigo) {
        turmaService.validarCodigo(codigo);
        Turma turma = turmaService.buscarAtiva(codigo);
        turmaService.exigirAcesso(usuario, turma);

        return turmaSimuladoRepository
                .findByCodTurmaAndAtivoOrderByDataPublicacaoDesc(codigo, ATIVO)
                .stream()
                .map(publicacao -> simuladoRepository.findById(publicacao.getCodSimulado())
                        .map(simulado -> paraDTO(publicacao, simulado)))
                .flatMap(java.util.Optional::stream)
                .toList();
    }

    @Transactional
    public ResultadoPublicacao publicar(
            UsuarioAutenticado usuario,
            String codigo,
            PublicarSimuladoDTO dados) {
        turmaService.exigirProfessor(usuario);
        turmaService.validarCodigo(codigo);
        Turma turma = turmaService.buscarAtiva(codigo);
        turmaService.exigirCriador(usuario, turma);

        Simulado simulado = simuladoRepository.findById(dados.getSimuladoId())
                .filter(encontrado -> usuario.email().equals(encontrado.getEmailProf()))
                .orElseThrow(this::simuladoNaoEncontrado);

        List<TurmaSimulado> existentes = turmaSimuladoRepository
                .findByCodTurmaAndCodSimuladoOrderByIdPublicacaoAsc(
                        codigo,
                        simulado.getCodSimulado());
        if (existentes.stream().anyMatch(publicacao -> ATIVO.equals(publicacao.getAtivo()))) {
            throw new ConflitoDominioException(
                    "SIMULADO_JA_PUBLICADO",
                    "O simulado ja esta publicado nesta turma.");
        }
        if (!existentes.isEmpty()) {
            TurmaSimulado publicacao = existentes.get(0);
            publicacao.setAtivo(ATIVO);
            publicacao.setDataPublicacao(agora());
            turmaSimuladoRepository.save(publicacao);
            return new ResultadoPublicacao(paraDTO(publicacao, simulado), false);
        }

        TurmaSimulado publicacao = new TurmaSimulado();
        publicacao.setIdPublicacao(UUID.randomUUID().toString());
        publicacao.setCodSimulado(simulado.getCodSimulado());
        publicacao.setCodTurma(codigo);
        publicacao.setAtivo(ATIVO);
        publicacao.setDataPublicacao(agora());
        turmaSimuladoRepository.save(publicacao);
        return new ResultadoPublicacao(paraDTO(publicacao, simulado), true);
    }

    @Transactional
    public void despublicar(UsuarioAutenticado usuario, String codigo, String idPublicacao) {
        turmaService.exigirProfessor(usuario);
        turmaService.validarCodigo(codigo);
        Turma turma = turmaService.buscarAtiva(codigo);
        turmaService.exigirCriador(usuario, turma);

        TurmaSimulado publicacao = turmaSimuladoRepository
                .findByIdPublicacaoAndCodTurmaAndAtivo(idPublicacao, codigo, ATIVO)
                .orElseThrow(this::publicacaoNaoEncontrada);
        publicacao.setAtivo(INATIVO);
        turmaSimuladoRepository.save(publicacao);
    }

    private PublicacaoSimuladoDTO paraDTO(TurmaSimulado publicacao, Simulado simulado) {
        return new PublicacaoSimuladoDTO(
                publicacao.getIdPublicacao(),
                simulado.getCodSimulado(),
                simulado.getNome(),
                simulado.getDescricao(),
                questaoSimuRepository.countByCodSimulado(simulado.getCodSimulado()),
                publicacao.getDataPublicacao());
    }

    private String agora() {
        return OffsetDateTime.now(FUSO_HORARIO).format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
    }

    private RecursoNaoEncontradoException simuladoNaoEncontrado() {
        return new RecursoNaoEncontradoException(
                "SIMULADO_NAO_ENCONTRADO",
                "O simulado nao foi encontrado.");
    }

    private RecursoNaoEncontradoException publicacaoNaoEncontrada() {
        return new RecursoNaoEncontradoException(
                "PUBLICACAO_NAO_ENCONTRADA",
                "A publicacao nao foi encontrada.");
    }

    public record ResultadoPublicacao(PublicacaoSimuladoDTO publicacao, boolean nova) {
    }
}
