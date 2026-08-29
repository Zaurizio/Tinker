package Tinker.demo.service;

import Tinker.demo.dto.turma.PublicacaoSimuladoDTO;
import Tinker.demo.dto.turma.PublicarSimuladoDTO;
import Tinker.demo.dto.questao.QuestaoDTO;
import Tinker.demo.dto.simulado.CorrecaoQuestaoSimuladoDTO;
import Tinker.demo.dto.turma.CorrigirQuestaoPublicadaDTO;
import Tinker.demo.dto.turma.ConcluirSimuladoPublicadoDTO;
import Tinker.demo.dto.turma.ConclusaoSimuladoDTO;
import Tinker.demo.dto.turma.RespostaConclusaoSimuladoDTO;
import Tinker.demo.dto.turma.ResultadoIndividualSimuladoDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.ConflitoDominioException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.model.Simulado;
import Tinker.demo.model.Turma;
import Tinker.demo.model.TurmaSimulado;
import Tinker.demo.model.Questao;
import Tinker.demo.model.QuestaoSimuid;
import Tinker.demo.model.Relatorio;
import Tinker.demo.model.RelatorioSimulado;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.RelatorioRepository;
import Tinker.demo.repository.RelatorioSimuladoRepository;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.SimuladoRepository;
import Tinker.demo.repository.TurmaSimuladoRepository;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.security.TipoUsuario;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
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
    private final QuestaoRepository questaoRepository;
    private final QuestaoMapper questaoMapper;
    private final RelatorioRepository relatorioRepository;
    private final RelatorioSimuladoRepository relatorioSimuladoRepository;

    public TurmaSimuladoService(
            TurmaService turmaService,
            TurmaSimuladoRepository turmaSimuladoRepository,
            SimuladoRepository simuladoRepository,
            QuestaoSimuRepository questaoSimuRepository,
            QuestaoRepository questaoRepository,
            QuestaoMapper questaoMapper,
            RelatorioRepository relatorioRepository,
            RelatorioSimuladoRepository relatorioSimuladoRepository) {
        this.turmaService = turmaService;
        this.turmaSimuladoRepository = turmaSimuladoRepository;
        this.simuladoRepository = simuladoRepository;
        this.questaoSimuRepository = questaoSimuRepository;
        this.questaoRepository = questaoRepository;
        this.questaoMapper = questaoMapper;
        this.relatorioRepository = relatorioRepository;
        this.relatorioSimuladoRepository = relatorioSimuladoRepository;
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

    @Transactional(readOnly = true)
    public List<QuestaoDTO> listarQuestoes(
            UsuarioAutenticado usuario,
            String codigo,
            String idPublicacao) {
        turmaService.validarCodigo(codigo);
        Turma turma = turmaService.buscarAtiva(codigo);
        turmaService.exigirAcesso(usuario, turma);

        TurmaSimulado publicacao = turmaSimuladoRepository
                .findByIdPublicacaoAndCodTurmaAndAtivo(idPublicacao, codigo, ATIVO)
                .orElseThrow(this::publicacaoNaoEncontrada);
        Simulado simulado = simuladoRepository.findById(publicacao.getCodSimulado())
                .orElseThrow(this::publicacaoNaoEncontrada);

        List<Integer> questoesIds = questaoSimuRepository
                .findCodQuestoesByCodSimulado(simulado.getCodSimulado());
        if (questoesIds.isEmpty()) {
            return List.of();
        }
        return questaoRepository
                .findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(questoesIds, ATIVO)
                .stream()
                .map(questaoMapper::paraDTO)
                .toList();
    }

    @Transactional
    public CorrecaoQuestaoSimuladoDTO corrigirQuestao(
            UsuarioAutenticado usuario,
            String codigo,
            String idPublicacao,
            Integer questaoId,
            CorrigirQuestaoPublicadaDTO dados) {
        exigirAluno(usuario);
        turmaService.validarCodigo(codigo);
        Turma turma = turmaService.buscarAtiva(codigo);
        turmaService.exigirAcesso(usuario, turma);

        TurmaSimulado publicacao = turmaSimuladoRepository
                .findByIdPublicacaoAndCodTurmaAndAtivo(idPublicacao, codigo, ATIVO)
                .orElseThrow(this::publicacaoNaoEncontrada);
        Simulado simulado = simuladoRepository.findById(publicacao.getCodSimulado())
                .orElseThrow(this::publicacaoNaoEncontrada);
        Questao questao = questaoRepository.findById(questaoId)
                .filter(encontrada -> ATIVO.equals(encontrada.getAtivo()))
                .orElseThrow(this::questaoNaoEncontrada);
        if (!questaoSimuRepository.existsById(
                new QuestaoSimuid(simulado.getCodSimulado(), questaoId))) {
            throw questaoNaoEncontrada();
        }

        boolean acertou = CorretorQuestao.corrigir(questao, dados.getAlternativa());
        String tipoUsuario = usuario.tipoUsuario().name();
        Relatorio relatorio = relatorioRepository
                .findByCodQuestAndEmailAndTipoUsu(questaoId, usuario.email(), tipoUsuario)
                .orElseGet(() -> {
            Relatorio novo = new Relatorio();
            novo.setCodQuest(questaoId);
            novo.setEmail(usuario.email());
            return novo;
        });
        relatorio.setAcertouErrou(acertou ? 1 : 0);
        relatorio.setTipoUsu(tipoUsuario);
        relatorioRepository.save(relatorio);

        return new CorrecaoQuestaoSimuladoDTO(questaoId, acertou);
    }

    @Transactional
    public ConclusaoSimuladoDTO concluir(
            UsuarioAutenticado usuario,
            String codigo,
            String idPublicacao,
            ConcluirSimuladoPublicadoDTO dados) {
        exigirAluno(usuario);
        turmaService.validarCodigo(codigo);
        Turma turma = turmaService.buscarAtiva(codigo);
        turmaService.exigirAcesso(usuario, turma);

        TurmaSimulado publicacao = turmaSimuladoRepository
                .findByIdPublicacaoAndCodTurmaAndAtivo(idPublicacao, codigo, ATIVO)
                .orElseThrow(this::publicacaoNaoEncontrada);
        Simulado simulado = simuladoRepository.findById(publicacao.getCodSimulado())
                .orElseThrow(this::publicacaoNaoEncontrada);

        List<Integer> idsAssociadosOrdenados = questaoSimuRepository
                .findCodQuestoesByCodSimulado(simulado.getCodSimulado());
        List<Questao> questoesAtivas = idsAssociadosOrdenados.isEmpty()
                ? List.of()
                : questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
                        idsAssociadosOrdenados,
                        ATIVO);
        if (questoesAtivas.isEmpty()) {
            throw new DadosInvalidosException(
                    "SIMULADO_SEM_QUESTOES_ATIVAS",
                    "O simulado nao possui questoes ativas para concluir.");
        }
        if (dados == null || dados.getRespostas() == null || dados.getRespostas().isEmpty()) {
            throw new DadosInvalidosException(
                    "RESPOSTAS_OBRIGATORIAS",
                    "Informe todas as respostas do simulado.");
        }

        Map<Integer, RespostaConclusaoSimuladoDTO> respostasPorQuestao = new LinkedHashMap<>();
        for (RespostaConclusaoSimuladoDTO resposta : dados.getRespostas()) {
            if (resposta == null || resposta.getQuestaoId() == null) {
                throw new DadosInvalidosException(
                        "QUESTAO_OBRIGATORIA",
                        "Todas as respostas devem informar a questao.");
            }
            if (respostasPorQuestao.putIfAbsent(resposta.getQuestaoId(), resposta) != null) {
                throw new DadosInvalidosException(
                        "QUESTAO_REPETIDA",
                        "Cada questao deve possuir exatamente uma resposta.");
            }
        }

        Set<Integer> idsAssociados = new LinkedHashSet<>(idsAssociadosOrdenados);
        if (!idsAssociados.containsAll(respostasPorQuestao.keySet())) {
            throw questaoNaoEncontrada();
        }
        Map<Integer, Questao> questoesPorId = new LinkedHashMap<>();
        questoesAtivas.forEach(questao -> questoesPorId.put(questao.getCodQuestao(), questao));
        Set<Integer> idsEsperados = questoesPorId.keySet();
        if (!respostasPorQuestao.keySet().containsAll(idsEsperados)) {
            throw new DadosInvalidosException(
                    "RESPOSTAS_INCOMPLETAS",
                    "Todas as questoes ativas devem ser respondidas.");
        }
        if (!idsEsperados.containsAll(respostasPorQuestao.keySet())) {
            throw new DadosInvalidosException(
                    "QUESTAO_EXTRA",
                    "A conclusao contem uma questao inexistente ou inativa.");
        }

        Map<Integer, Boolean> resultadosPorQuestao = new LinkedHashMap<>();
        int acertos = 0;
        for (Map.Entry<Integer, Questao> entrada : questoesPorId.entrySet()) {
            RespostaConclusaoSimuladoDTO resposta = respostasPorQuestao.get(entrada.getKey());
            boolean acertou = CorretorQuestao.corrigir(
                    entrada.getValue(), resposta.getAlternativa());
            resultadosPorQuestao.put(entrada.getKey(), acertou);
            if (acertou) {
                acertos++;
            }
        }
        int quantidadeQuestoes = questoesPorId.size();
        int erros = quantidadeQuestoes - acertos;

        for (Map.Entry<Integer, Boolean> resultadoQuestao : resultadosPorQuestao.entrySet()) {
            String tipoUsuario = usuario.tipoUsuario().name();
            Relatorio relatorio = relatorioRepository
                    .findByCodQuestAndEmailAndTipoUsu(
                            resultadoQuestao.getKey(), usuario.email(), tipoUsuario)
                    .orElseGet(() -> {
                Relatorio novo = new Relatorio();
                novo.setCodQuest(resultadoQuestao.getKey());
                novo.setEmail(usuario.email());
                return novo;
            });
            relatorio.setAcertouErrou(resultadoQuestao.getValue() ? 1 : 0);
            relatorio.setTipoUsu(tipoUsuario);
            relatorioRepository.save(relatorio);
        }

        RelatorioSimulado resultado = relatorioSimuladoRepository
                .findByCodSimuladoAndEmailAluno(simulado.getCodSimulado(), usuario.email())
                .orElseGet(RelatorioSimulado::new);
        resultado.setCodSimulado(simulado.getCodSimulado());
        resultado.setEmailAluno(usuario.email());
        resultado.setAcertos(acertos);
        resultado.setErros(erros);
        relatorioSimuladoRepository.save(resultado);

        return new ConclusaoSimuladoDTO(
                simulado.getCodSimulado(),
                quantidadeQuestoes,
                acertos,
                erros,
                true);
    }

    @Transactional(readOnly = true)
    public ResultadoIndividualSimuladoDTO consultarResultado(
            UsuarioAutenticado usuario,
            String codigo,
            String idPublicacao) {
        exigirAluno(usuario);
        turmaService.validarCodigo(codigo);
        Turma turma = turmaService.buscarAtiva(codigo);
        turmaService.exigirAcesso(usuario, turma);

        TurmaSimulado publicacao = turmaSimuladoRepository
                .findByIdPublicacaoAndCodTurmaAndAtivo(idPublicacao, codigo, ATIVO)
                .orElseThrow(this::publicacaoNaoEncontrada);
        Simulado simulado = simuladoRepository.findById(publicacao.getCodSimulado())
                .orElseThrow(this::publicacaoNaoEncontrada);

        RelatorioSimulado resultado = relatorioSimuladoRepository
                .findByCodSimuladoAndEmailAluno(simulado.getCodSimulado(), usuario.email())
                .orElse(null);
        if (resultadoValido(resultado)) {
            return resultadoCompleto(simulado.getCodSimulado(), resultado);
        }

        List<Integer> idsAssociados = questaoSimuRepository
                .findCodQuestoesByCodSimulado(simulado.getCodSimulado());
        int quantidadeQuestoesAtual = idsAssociados.isEmpty()
                ? 0
                : questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
                        idsAssociados,
                        ATIVO).size();
        return new ResultadoIndividualSimuladoDTO(
                simulado.getCodSimulado(),
                quantidadeQuestoesAtual,
                false,
                null,
                null);
    }

    private ResultadoIndividualSimuladoDTO resultadoCompleto(
            Integer simuladoId,
            RelatorioSimulado resultado) {
        return new ResultadoIndividualSimuladoDTO(
                simuladoId,
                resultado.getAcertos() + resultado.getErros(),
                true,
                resultado.getAcertos(),
                resultado.getErros());
    }

    private boolean resultadoValido(RelatorioSimulado resultado) {
        if (resultado == null
                || resultado.getAcertos() == null
                || resultado.getErros() == null
                || resultado.getAcertos() < 0
                || resultado.getErros() < 0) {
            return false;
        }
        long quantidadeRealizada = (long) resultado.getAcertos() + resultado.getErros();
        return quantidadeRealizada <= Integer.MAX_VALUE;
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

    private RecursoNaoEncontradoException questaoNaoEncontrada() {
        return new RecursoNaoEncontradoException(
                "QUESTAO_NAO_ENCONTRADA",
                "A questao nao foi encontrada.");
    }

    private void exigirAluno(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() != TipoUsuario.ALUNO) {
            throw new AcessoNegadoException(
                    "ACESSO_NEGADO",
                    "Esta operacao e permitida somente para aluno.");
        }
    }

    public record ResultadoPublicacao(PublicacaoSimuladoDTO publicacao, boolean nova) {
    }
}
