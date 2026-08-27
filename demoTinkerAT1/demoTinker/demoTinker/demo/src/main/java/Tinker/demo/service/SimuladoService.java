package Tinker.demo.service;

import Tinker.demo.dto.simulado.AtualizarSimuladoDTO;
import Tinker.demo.dto.simulado.CriarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoDetalheDTO;
import Tinker.demo.dto.simulado.QuantidadeQuestoesSimuladoDTO;
import Tinker.demo.dto.simulado.QuestoesIdsDTO;
import Tinker.demo.dto.simulado.SimuladoResumoDTO;
import Tinker.demo.dto.simulado.GerarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoGeradoDTO;
import Tinker.demo.dto.simulado.CorrigirQuestaoSimuladoDTO;
import Tinker.demo.dto.simulado.CorrecaoQuestaoSimuladoDTO;
import Tinker.demo.dto.questao.QuestaoDTO;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.model.Simulado;
import Tinker.demo.model.Questao;
import Tinker.demo.model.QuestaoSimu;
import Tinker.demo.model.QuestaoSimuid;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.RelatorioSimuladoRepository;
import Tinker.demo.repository.SimuladoRepository;
import Tinker.demo.repository.TurmaSimuladoRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import Tinker.demo.specification.QuestaoSpecifications;

import java.util.List;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.Locale;

@Service
public class SimuladoService {

    private final SimuladoRepository simuladoRepository;
    private final QuestaoSimuRepository questaoSimuRepository;
    private final RelatorioSimuladoRepository relatorioSimuladoRepository;
    private final TurmaSimuladoRepository turmaSimuladoRepository;
    private final QuestaoRepository questaoRepository;
    private final QuestaoMapper questaoMapper;

    public SimuladoService(
            SimuladoRepository simuladoRepository,
            QuestaoSimuRepository questaoSimuRepository,
            RelatorioSimuladoRepository relatorioSimuladoRepository,
            TurmaSimuladoRepository turmaSimuladoRepository,
            QuestaoRepository questaoRepository,
            QuestaoMapper questaoMapper) {
        this.simuladoRepository = simuladoRepository;
        this.questaoSimuRepository = questaoSimuRepository;
        this.relatorioSimuladoRepository = relatorioSimuladoRepository;
        this.turmaSimuladoRepository = turmaSimuladoRepository;
        this.questaoRepository = questaoRepository;
        this.questaoMapper = questaoMapper;
    }

    @Transactional(readOnly = true)
    public List<SimuladoResumoDTO> listar(UsuarioAutenticado usuario) {
        exigirProfessor(usuario);
        List<Simulado> simulados =
                simuladoRepository.findByEmailProfOrderByCodSimuladoAsc(usuario.email());

        return simulados.stream().map(this::resumo).toList();
    }

    @Transactional
    public SimuladoDetalheDTO criar(UsuarioAutenticado usuario, CriarSimuladoDTO dados) {
        exigirProfessor(usuario);
        Simulado simulado = new Simulado();
        simulado.setNome(dados.getTitulo().trim());
        simulado.setDescricao(dados.getDescricao());
        simulado.setTempo(dados.getTempo());
        simulado.setConclusao(0);

        preencherProprietarioProfessor(simulado, usuario);

        Simulado salvo = simuladoRepository.save(simulado);
        return detalhe(salvo, List.of());
    }

    @Transactional
    public SimuladoGeradoDTO gerar(UsuarioAutenticado usuario, GerarSimuladoDTO dados) {
        exigirProfessor(usuario);
        validarQuantidade(dados.getQuantidadeQuestoes());

        Page<Questao> resultado = questaoRepository.findAll(
                QuestaoSpecifications.comFiltros(
                        dados.getDisciplinas(),
                        dados.getConteudos(),
                        dados.getVestibulares(),
                        dados.getAnos(),
                        null),
                PageRequest.of(
                        0,
                        dados.getQuantidadeQuestoes(),
                        Sort.by(Sort.Direction.ASC, "codQuestao")));

        if (resultado.getNumberOfElements() < dados.getQuantidadeQuestoes()) {
            throw new DadosInvalidosException(
                    "QUESTOES_INSUFICIENTES",
                    "Foram encontradas apenas " + resultado.getTotalElements()
                            + " questoes para os filtros informados.");
        }

        Simulado simulado = new Simulado();
        simulado.setNome(dados.getTitulo().trim());
        simulado.setDescricao(dados.getDescricao());
        simulado.setTempo(dados.getTempo());
        simulado.setConclusao(0);
        preencherProprietarioProfessor(simulado, usuario);

        Simulado salvo = simuladoRepository.save(simulado);
        List<QuestaoSimu> associacoes = resultado.getContent().stream()
                .map(questao -> new QuestaoSimu(salvo.getCodSimulado(), questao.getCodQuestao()))
                .toList();
        questaoSimuRepository.saveAll(associacoes);

        return new SimuladoGeradoDTO(
                salvo.getCodSimulado(),
                salvo.getNome(),
                associacoes.size());
    }

    @Transactional(readOnly = true)
    public SimuladoDetalheDTO detalhar(UsuarioAutenticado usuario, Integer id) {
        Simulado simulado = buscarDoUsuario(usuario, id);
        List<Integer> questoesIds = questaoSimuRepository.findCodQuestoesByCodSimulado(id);
        return detalhe(simulado, questoesIds);
    }

    @Transactional(readOnly = true)
    public List<QuestaoDTO> listarQuestoes(UsuarioAutenticado usuario, Integer id) {
        buscarDoUsuario(usuario, id);
        List<Integer> questoesIds = questaoSimuRepository.findCodQuestoesByCodSimulado(id);
        if (questoesIds.isEmpty()) {
            return List.of();
        }
        return questaoRepository
                .findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(questoesIds, 1)
                .stream()
                .map(questaoMapper::paraDTO)
                .toList();
    }

    @Transactional
    public QuantidadeQuestoesSimuladoDTO adicionarQuestoes(
            UsuarioAutenticado usuario,
            Integer id,
            QuestoesIdsDTO dados) {
        buscarDoUsuario(usuario, id);
        if (dados == null || dados.getQuestoesIds() == null || dados.getQuestoesIds().isEmpty()) {
            throw new DadosInvalidosException(
                    "QUESTOES_OBRIGATORIAS",
                    "Informe ao menos uma questao.");
        }

        Set<Integer> idsUnicos = new LinkedHashSet<>(dados.getQuestoesIds());
        if (idsUnicos.contains(null)) {
            throw new DadosInvalidosException(
                    "QUESTAO_INVALIDA",
                    "Os IDs das questoes devem ser informados.");
        }

        List<Questao> questoesAtivas = questaoRepository
                .findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(idsUnicos, 1);
        Set<Integer> idsEncontrados = questoesAtivas.stream()
                .map(Questao::getCodQuestao)
                .collect(java.util.stream.Collectors.toSet());
        if (!idsEncontrados.equals(idsUnicos)) {
            throw new RecursoNaoEncontradoException(
                    "QUESTAO_NAO_ENCONTRADA",
                    "Uma ou mais questoes nao existem ou estao inativas.");
        }

        Set<Integer> idsAssociados = new LinkedHashSet<>(
                questaoSimuRepository.findCodQuestoesByCodSimulado(id));
        List<QuestaoSimu> novasAssociacoes = idsUnicos.stream()
                .filter(questaoId -> !idsAssociados.contains(questaoId))
                .map(questaoId -> new QuestaoSimu(id, questaoId))
                .toList();
        if (!novasAssociacoes.isEmpty()) {
            questaoSimuRepository.saveAll(novasAssociacoes);
        }

        return new QuantidadeQuestoesSimuladoDTO(
                questaoSimuRepository.countByCodSimulado(id));
    }

    @Transactional
    public void removerQuestao(
            UsuarioAutenticado usuario,
            Integer id,
            Integer questaoId) {
        buscarDoUsuario(usuario, id);
        QuestaoSimuid associacaoId = new QuestaoSimuid(id, questaoId);
        if (!questaoSimuRepository.existsById(associacaoId)) {
            throw new RecursoNaoEncontradoException(
                    "ASSOCIACAO_NAO_ENCONTRADA",
                    "A questao nao esta associada ao simulado.");
        }
        questaoSimuRepository.deleteById(associacaoId);
    }

    @Transactional(readOnly = true)
    public CorrecaoQuestaoSimuladoDTO corrigirQuestao(
            UsuarioAutenticado usuario,
            Integer id,
            CorrigirQuestaoSimuladoDTO dados) {
        buscarDoUsuario(usuario, id);

        if (dados == null || dados.getQuestaoId() == null) {
            throw new DadosInvalidosException(
                    "QUESTAO_OBRIGATORIA",
                    "Informe a questao que sera corrigida.");
        }

        Integer questaoId = dados.getQuestaoId();
        if (!questaoSimuRepository.existsById(new QuestaoSimuid(id, questaoId))) {
            throw new RecursoNaoEncontradoException(
                    "QUESTAO_NAO_PERTENCE_AO_SIMULADO",
                    "A questao nao pertence ao simulado.");
        }

        Questao questao = questaoRepository.findById(questaoId)
                .filter(encontrada -> Integer.valueOf(1).equals(encontrada.getAtivo()))
                .orElseThrow(() -> new RecursoNaoEncontradoException(
                        "QUESTAO_NAO_ENCONTRADA",
                        "A questao nao existe ou esta inativa."));

        String alternativaId = normalizarAlternativa(dados.getAlternativaSelecionadaId());
        String textoSelecionado = textoAlternativa(questao, alternativaId);
        if (textoSelecionado == null || textoSelecionado.isBlank()) {
            throw new DadosInvalidosException(
                    "ALTERNATIVA_INEXISTENTE",
                    "A alternativa selecionada nao existe nesta questao.");
        }

        return new CorrecaoQuestaoSimuladoDTO(
                questaoId,
                respostaCorreta(questao, alternativaId, textoSelecionado));
    }

    @Transactional
    public SimuladoDetalheDTO atualizar(
            UsuarioAutenticado usuario,
            Integer id,
            AtualizarSimuladoDTO dados) {
        Simulado simulado = buscarDoUsuario(usuario, id);

        if (dados.getTitulo() != null) {
            if (dados.getTitulo().isBlank()) {
                throw new DadosInvalidosException(
                        "TITULO_OBRIGATORIO",
                        "O titulo nao pode ficar vazio.");
            }
            simulado.setNome(dados.getTitulo().trim());
        }
        if (dados.getDescricao() != null) {
            simulado.setDescricao(dados.getDescricao());
        }
        if (dados.getTempo() != null) {
            if (dados.getTempo() <= 0) {
                throw new DadosInvalidosException(
                        "TEMPO_INVALIDO",
                        "O tempo deve ser positivo.");
            }
            simulado.setTempo(dados.getTempo());
        }

        Simulado salvo = simuladoRepository.save(simulado);
        List<Integer> questoesIds = questaoSimuRepository.findCodQuestoesByCodSimulado(id);
        return detalhe(salvo, questoesIds);
    }

    @Transactional
    public void excluir(UsuarioAutenticado usuario, Integer id) {
        Simulado simulado = buscarDoUsuario(usuario, id);

        turmaSimuladoRepository.deleteByCodSimulado(id);
        questaoSimuRepository.deleteByCodSimulado(id);
        simuladoRepository.delete(simulado);
    }

    private Simulado buscarDoUsuario(UsuarioAutenticado usuario, Integer id) {
        exigirProfessor(usuario);
        Simulado simulado = simuladoRepository.findById(id).orElseThrow(this::naoEncontrado);
        if (!usuario.email().equals(simulado.getEmailProf())) {
            throw naoEncontrado();
        }
        return simulado;
    }

    private void preencherProprietarioProfessor(
            Simulado simulado,
            UsuarioAutenticado usuario) {
        simulado.setEmailAluno(null);
        simulado.setEmailProf(usuario.email());
        simulado.setTipoUsu(Simulado.TIPO_USUARIO_PROFESSOR);
    }

    private SimuladoResumoDTO resumo(Simulado simulado) {
        return new SimuladoResumoDTO(
                simulado.getCodSimulado(),
                simulado.getNome(),
                simulado.getDescricao(),
                simulado.getTempo(),
                questaoSimuRepository.countByCodSimulado(simulado.getCodSimulado()));
    }

    private SimuladoDetalheDTO detalhe(Simulado simulado, List<Integer> questoesIds) {
        return new SimuladoDetalheDTO(
                simulado.getCodSimulado(),
                simulado.getNome(),
                simulado.getDescricao(),
                simulado.getTempo(),
                questoesIds.size(),
                List.copyOf(questoesIds));
    }

    private RecursoNaoEncontradoException naoEncontrado() {
        return new RecursoNaoEncontradoException(
                "SIMULADO_NAO_ENCONTRADO",
                "O simulado nao foi encontrado.");
    }

    private void exigirProfessor(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() != TipoUsuario.PROFESSOR) {
            throw new AcessoNegadoException(
                    "ACESSO_NEGADO",
                    "Esta operacao de simulado e permitida somente para professor.");
        }
    }

    private void validarQuantidade(Integer quantidade) {
        if (quantidade == null || quantidade < 1 || quantidade > 50) {
            throw new DadosInvalidosException(
                    "QUANTIDADE_QUESTOES_INVALIDA",
                    "A quantidade de questoes deve estar entre 1 e 50.");
        }
    }

    private String normalizarAlternativa(String alternativaId) {
        if (alternativaId == null) {
            throw alternativaInvalida();
        }
        String normalizada = alternativaId.trim().toUpperCase(Locale.ROOT);
        if (!Set.of("A", "B", "C", "D", "E").contains(normalizada)) {
            throw alternativaInvalida();
        }
        return normalizada;
    }

    private DadosInvalidosException alternativaInvalida() {
        return new DadosInvalidosException(
                "ALTERNATIVA_INVALIDA",
                "A alternativa deve ser A, B, C, D ou E.");
    }

    private String textoAlternativa(Questao questao, String alternativaId) {
        return switch (alternativaId) {
            case "A" -> questao.getAlternativaA();
            case "B" -> questao.getAlternativaB();
            case "C" -> questao.getAlternativaC();
            case "D" -> questao.getAlternativaD();
            case "E" -> questao.getAlternativaE();
            default -> null;
        };
    }

    private boolean respostaCorreta(
            Questao questao,
            String alternativaId,
            String textoSelecionado) {
        String resposta = questao.getResposta();
        if (resposta == null) {
            return false;
        }
        String respostaNormalizada = resposta.trim();
        if (respostaNormalizada.matches("(?i)[A-E]")) {
            return alternativaId.equals(respostaNormalizada.toUpperCase(Locale.ROOT));
        }
        return textoSelecionado.trim().equals(respostaNormalizada);
    }
}
