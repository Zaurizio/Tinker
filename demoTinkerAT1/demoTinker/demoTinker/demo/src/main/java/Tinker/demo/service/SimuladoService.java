package Tinker.demo.service;

import Tinker.demo.dto.simulado.AtualizarSimuladoDTO;
import Tinker.demo.dto.simulado.CriarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoDetalheDTO;
import Tinker.demo.dto.simulado.QuantidadeQuestoesSimuladoDTO;
import Tinker.demo.dto.simulado.QuestoesIdsDTO;
import Tinker.demo.dto.simulado.SimuladoResumoDTO;
import Tinker.demo.dto.simulado.GerarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoGeradoDTO;
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
        exigirUsuarioDeSimulado(usuario);
        List<Simulado> simulados = usuario.tipoUsuario() == TipoUsuario.ALUNO
                ? simuladoRepository.findByEmailAlunoAndTipoUsuOrderByCodSimuladoAsc(
                        usuario.email(), Simulado.TIPO_USUARIO_ALUNO)
                : simuladoRepository.findByEmailProfAndTipoUsuOrderByCodSimuladoAsc(
                        usuario.email(), Simulado.TIPO_USUARIO_PROFESSOR);

        return simulados.stream().map(this::resumo).toList();
    }

    @Transactional
    public SimuladoDetalheDTO criar(UsuarioAutenticado usuario, CriarSimuladoDTO dados) {
        exigirUsuarioDeSimulado(usuario);
        Simulado simulado = new Simulado();
        simulado.setNome(dados.getTitulo().trim());
        simulado.setDescricao(dados.getDescricao());
        simulado.setTempo(dados.getTempo());
        simulado.setConclusao(0);

        preencherProprietario(simulado, usuario);

        Simulado salvo = simuladoRepository.save(simulado);
        return detalhe(salvo, List.of());
    }

    @Transactional
    public SimuladoGeradoDTO gerar(UsuarioAutenticado usuario, GerarSimuladoDTO dados) {
        exigirUsuarioDeSimulado(usuario);
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
        preencherProprietario(simulado, usuario);

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
        relatorioSimuladoRepository.deleteByCodSimulado(id);
        questaoSimuRepository.deleteByCodSimulado(id);
        simuladoRepository.delete(simulado);
    }

    private Simulado buscarDoUsuario(UsuarioAutenticado usuario, Integer id) {
        exigirUsuarioDeSimulado(usuario);
        Simulado simulado = simuladoRepository.findById(id).orElseThrow(this::naoEncontrado);
        if (!pertenceAoUsuario(simulado, usuario)) {
            throw naoEncontrado();
        }
        return simulado;
    }

    private void preencherProprietario(Simulado simulado, UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            simulado.setEmailAluno(usuario.email());
            simulado.setEmailProf(null);
            simulado.setTipoUsu(Simulado.TIPO_USUARIO_ALUNO);
            return;
        }

        simulado.setEmailAluno(null);
        simulado.setEmailProf(usuario.email());
        simulado.setTipoUsu(Simulado.TIPO_USUARIO_PROFESSOR);
    }

    private boolean pertenceAoUsuario(Simulado simulado, UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            return Simulado.TIPO_USUARIO_ALUNO.equals(simulado.getTipoUsu())
                    && usuario.email().equals(simulado.getEmailAluno());
        }
        return Simulado.TIPO_USUARIO_PROFESSOR.equals(simulado.getTipoUsu())
                && usuario.email().equals(simulado.getEmailProf());
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

    private void exigirUsuarioDeSimulado(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() == TipoUsuario.ADMINISTRADOR) {
            throw new AcessoNegadoException(
                    "ACESSO_NEGADO",
                    "Administrador nao pode administrar simulados pessoais.");
        }
    }

    private void validarQuantidade(Integer quantidade) {
        if (quantidade == null || quantidade < 1 || quantidade > 50) {
            throw new DadosInvalidosException(
                    "QUANTIDADE_QUESTOES_INVALIDA",
                    "A quantidade de questoes deve estar entre 1 e 50.");
        }
    }

}
