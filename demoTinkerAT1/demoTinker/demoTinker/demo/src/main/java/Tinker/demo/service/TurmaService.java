package Tinker.demo.service;

import Tinker.demo.dto.turma.CriarTurmaDTO;
import Tinker.demo.dto.turma.EntrarTurmaDTO;
import Tinker.demo.dto.turma.MembroTurmaDTO;
import Tinker.demo.dto.turma.TurmaDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.model.AlunoTurma;
import Tinker.demo.model.AlunoTurmaid;
import Tinker.demo.model.Turma;
import Tinker.demo.repository.AlunoRepository;
import Tinker.demo.repository.AlunoTurmaRepository;
import Tinker.demo.repository.ProfessorRepository;
import Tinker.demo.repository.TurmaRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class TurmaService {

    private static final Integer ATIVO = 1;
    private static final Integer INATIVO = 0;

    private final TurmaRepository turmaRepository;
    private final AlunoTurmaRepository alunoTurmaRepository;
    private final AlunoRepository alunoRepository;
    private final ProfessorRepository professorRepository;
    private final GeradorCodigoTurma geradorCodigoTurma;

    public TurmaService(
            TurmaRepository turmaRepository,
            AlunoTurmaRepository alunoTurmaRepository,
            AlunoRepository alunoRepository,
            ProfessorRepository professorRepository,
            GeradorCodigoTurma geradorCodigoTurma) {
        this.turmaRepository = turmaRepository;
        this.alunoTurmaRepository = alunoTurmaRepository;
        this.alunoRepository = alunoRepository;
        this.professorRepository = professorRepository;
        this.geradorCodigoTurma = geradorCodigoTurma;
    }

    @Transactional(readOnly = true)
    public List<TurmaDTO> listar(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() == TipoUsuario.PROFESSOR) {
            return turmaRepository
                    .findByEmailProfAndAtivoOrderByCodTurmaAsc(usuario.email(), ATIVO)
                    .stream()
                    .map(this::paraDTO)
                    .toList();
        }
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            List<String> codigos = alunoTurmaRepository
                    .findByEmailAlunoAndAtivoOrderByCodTurmaAsc(usuario.email(), ATIVO)
                    .stream()
                    .map(AlunoTurma::getCodTurma)
                    .toList();
            if (codigos.isEmpty()) {
                return List.of();
            }
            return turmaRepository
                    .findByCodTurmaInAndAtivoOrderByCodTurmaAsc(codigos, ATIVO)
                    .stream()
                    .map(this::paraDTO)
                    .toList();
        }
        throw acessoNegado();
    }

    @Transactional
    public TurmaDTO criar(UsuarioAutenticado usuario, CriarTurmaDTO dados) {
        exigirProfessor(usuario);

        String codigo;
        do {
            codigo = geradorCodigoTurma.gerar();
            validarCodigo(codigo);
        } while (turmaRepository.existsById(codigo));

        Turma turma = new Turma();
        turma.setCodTurma(codigo);
        turma.setNomeTurma(dados.getNome().trim());
        turma.setEmailProf(usuario.email());
        turma.setAtivo(ATIVO);
        return paraDTO(turmaRepository.save(turma));
    }

    @Transactional
    public TurmaDTO entrar(UsuarioAutenticado usuario, EntrarTurmaDTO dados) {
        exigirAluno(usuario);
        String codigo = dados.getCodigo();
        validarCodigo(codigo);
        Turma turma = buscarAtiva(codigo);

        AlunoTurmaid id = new AlunoTurmaid(usuario.email(), codigo);
        Optional<AlunoTurma> existente = alunoTurmaRepository.findById(id);
        AlunoTurma membership = existente.orElseGet(() -> {
            AlunoTurma nova = new AlunoTurma();
            nova.setEmailAluno(usuario.email());
            nova.setCodTurma(codigo);
            return nova;
        });

        if (!ATIVO.equals(membership.getAtivo())) {
            membership.setAtivo(ATIVO);
            alunoTurmaRepository.save(membership);
        } else if (existente.isEmpty()) {
            alunoTurmaRepository.save(membership);
        }

        return paraDTO(turma);
    }

    @Transactional(readOnly = true)
    public TurmaDTO detalhar(UsuarioAutenticado usuario, String codigo) {
        validarCodigo(codigo);
        Turma turma = buscarAtiva(codigo);
        exigirAcesso(usuario, turma);
        return paraDTO(turma);
    }

    @Transactional(readOnly = true)
    public List<MembroTurmaDTO> listarMembros(UsuarioAutenticado usuario, String codigo) {
        validarCodigo(codigo);
        Turma turma = buscarAtiva(codigo);
        exigirAcesso(usuario, turma);

        return alunoTurmaRepository
                .findByCodTurmaAndAtivoOrderByEmailAlunoAsc(codigo, ATIVO)
                .stream()
                .map(AlunoTurma::getEmailAluno)
                .map(alunoRepository::findById)
                .flatMap(java.util.Optional::stream)
                .filter(aluno -> ATIVO.equals(aluno.getAtivo()))
                .map(aluno -> new MembroTurmaDTO(
                        aluno.getEmail(),
                        aluno.getNome(),
                        aluno.getSobrenome()))
                .toList();
    }

    @Transactional
    public void sair(UsuarioAutenticado usuario, String codigo) {
        exigirAluno(usuario);
        validarCodigo(codigo);
        buscarAtiva(codigo);
        AlunoTurma membership = buscarMembershipAtivo(usuario.email(), codigo);
        membership.setAtivo(INATIVO);
        alunoTurmaRepository.save(membership);
    }

    @Transactional
    public void removerMembro(
            UsuarioAutenticado usuario,
            String codigo,
            String emailAluno) {
        exigirProfessor(usuario);
        validarCodigo(codigo);
        Turma turma = buscarAtiva(codigo);
        exigirCriador(usuario, turma);
        AlunoTurma membership = buscarMembershipAtivo(emailAluno, codigo);
        membership.setAtivo(INATIVO);
        alunoTurmaRepository.save(membership);
    }

    @Transactional
    public void desativar(UsuarioAutenticado usuario, String codigo) {
        exigirProfessor(usuario);
        validarCodigo(codigo);
        Turma turma = buscarAtiva(codigo);
        exigirCriador(usuario, turma);

        turma.setAtivo(INATIVO);
        List<AlunoTurma> memberships = alunoTurmaRepository
                .findByCodTurmaAndAtivoOrderByEmailAlunoAsc(codigo, ATIVO);
        memberships.forEach(membership -> membership.setAtivo(INATIVO));
        alunoTurmaRepository.saveAll(memberships);
        turmaRepository.save(turma);
    }

    void exigirAcesso(UsuarioAutenticado usuario, Turma turma) {
        if (usuario.tipoUsuario() == TipoUsuario.PROFESSOR
                && usuario.email().equals(turma.getEmailProf())) {
            return;
        }
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO
                && alunoTurmaRepository
                .findByEmailAlunoAndCodTurmaAndAtivo(usuario.email(), turma.getCodTurma(), ATIVO)
                .isPresent()) {
            return;
        }
        throw turmaNaoEncontrada();
    }

    void exigirCriador(UsuarioAutenticado usuario, Turma turma) {
        if (!usuario.email().equals(turma.getEmailProf())) {
            throw turmaNaoEncontrada();
        }
    }

    void exigirProfessor(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() != TipoUsuario.PROFESSOR) {
            throw acessoNegado();
        }
    }

    private void exigirAluno(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() != TipoUsuario.ALUNO) {
            throw acessoNegado();
        }
    }

    Turma buscarAtiva(String codigo) {
        return turmaRepository.findById(codigo)
                .filter(turma -> ATIVO.equals(turma.getAtivo()))
                .orElseThrow(this::turmaNaoEncontrada);
    }

    private AlunoTurma buscarMembershipAtivo(String emailAluno, String codigo) {
        return alunoTurmaRepository
                .findByEmailAlunoAndCodTurmaAndAtivo(emailAluno, codigo, ATIVO)
                .orElseThrow(this::membershipNaoEncontrado);
    }

    private TurmaDTO paraDTO(Turma turma) {
        String criadorNome = professorRepository.findById(turma.getEmailProf())
                .map(professor -> professor.getNome())
                .orElse("Professor");
        return new TurmaDTO(turma.getCodTurma(), turma.getNomeTurma(), criadorNome);
    }

    void validarCodigo(String codigo) {
        if (codigo == null || !codigo.matches("^[0-9]{8}$")) {
            throw new DadosInvalidosException(
                    "CODIGO_TURMA_INVALIDO",
                    "O codigo da turma deve conter exatamente oito digitos.");
        }
    }

    private AcessoNegadoException acessoNegado() {
        return new AcessoNegadoException(
                "ACESSO_NEGADO",
                "O tipo de usuario nao pode realizar esta operacao na turma.");
    }

    private RecursoNaoEncontradoException turmaNaoEncontrada() {
        return new RecursoNaoEncontradoException(
                "TURMA_NAO_ENCONTRADA",
                "A turma nao foi encontrada.");
    }

    private RecursoNaoEncontradoException membershipNaoEncontrado() {
        return new RecursoNaoEncontradoException(
                "MEMBRO_NAO_ENCONTRADO",
                "O aluno nao e membro ativo desta turma.");
    }
}
