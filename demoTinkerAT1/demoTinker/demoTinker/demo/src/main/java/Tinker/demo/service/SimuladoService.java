package Tinker.demo.service;

import Tinker.demo.dto.simulado.AtualizarSimuladoDTO;
import Tinker.demo.dto.simulado.CriarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoDetalheDTO;
import Tinker.demo.dto.simulado.SimuladoResumoDTO;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.model.Simulado;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.RelatorioSimuladoRepository;
import Tinker.demo.repository.SimuladoRepository;
import Tinker.demo.repository.TurmaSimuladoRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class SimuladoService {

    private final SimuladoRepository simuladoRepository;
    private final QuestaoSimuRepository questaoSimuRepository;
    private final RelatorioSimuladoRepository relatorioSimuladoRepository;
    private final TurmaSimuladoRepository turmaSimuladoRepository;

    public SimuladoService(
            SimuladoRepository simuladoRepository,
            QuestaoSimuRepository questaoSimuRepository,
            RelatorioSimuladoRepository relatorioSimuladoRepository,
            TurmaSimuladoRepository turmaSimuladoRepository) {
        this.simuladoRepository = simuladoRepository;
        this.questaoSimuRepository = questaoSimuRepository;
        this.relatorioSimuladoRepository = relatorioSimuladoRepository;
        this.turmaSimuladoRepository = turmaSimuladoRepository;
    }

    @Transactional(readOnly = true)
    public List<SimuladoResumoDTO> listar(UsuarioAutenticado usuario) {
        List<Simulado> simulados;
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            simulados = simuladoRepository.findByEmailAlunoOrderByCodSimuladoAsc(usuario.email());
        } else if (usuario.tipoUsuario() == TipoUsuario.PROFESSOR) {
            simulados = simuladoRepository.findByEmailProfOrderByCodSimuladoAsc(usuario.email());
        } else {
            throw tipoNaoPermitido();
        }

        return simulados.stream().map(this::resumo).toList();
    }

    @Transactional
    public SimuladoDetalheDTO criar(UsuarioAutenticado usuario, CriarSimuladoDTO dados) {
        Simulado simulado = new Simulado();
        simulado.setNome(dados.getTitulo().trim());
        simulado.setDescricao(dados.getDescricao());
        simulado.setTempo(dados.getTempo());
        simulado.setConclusao(0);

        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            simulado.setEmailAluno(usuario.email());
            simulado.setEmailProf(null);
        } else if (usuario.tipoUsuario() == TipoUsuario.PROFESSOR) {
            simulado.setEmailAluno(null);
            simulado.setEmailProf(usuario.email());
        } else {
            throw tipoNaoPermitido();
        }

        Simulado salvo = simuladoRepository.save(simulado);
        return detalhe(salvo, List.of());
    }

    @Transactional(readOnly = true)
    public SimuladoDetalheDTO detalhar(UsuarioAutenticado usuario, Integer id) {
        Simulado simulado = buscarDoUsuario(usuario, id);
        List<Integer> questoesIds = questaoSimuRepository.findCodQuestoesByCodSimulado(id);
        return detalhe(simulado, questoesIds);
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
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            relatorioSimuladoRepository.deleteByCodSimuladoAndEmailAluno(id, usuario.email());
        }
        questaoSimuRepository.deleteByCodSimulado(id);
        simuladoRepository.delete(simulado);
    }

    private Simulado buscarDoUsuario(UsuarioAutenticado usuario, Integer id) {
        Simulado simulado = simuladoRepository.findById(id).orElseThrow(this::naoEncontrado);
        boolean pertence = usuario.tipoUsuario() == TipoUsuario.ALUNO
                && usuario.email().equals(simulado.getEmailAluno());
        pertence = pertence || usuario.tipoUsuario() == TipoUsuario.PROFESSOR
                && usuario.email().equals(simulado.getEmailProf());

        if (!pertence) {
            throw naoEncontrado();
        }
        return simulado;
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

    private DadosInvalidosException tipoNaoPermitido() {
        return new DadosInvalidosException(
                "TIPO_USUARIO_INVALIDO",
                "Simulados pessoais estao disponiveis apenas para aluno ou professor.");
    }
}
