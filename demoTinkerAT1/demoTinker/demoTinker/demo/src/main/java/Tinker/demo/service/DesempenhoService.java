package Tinker.demo.service;

import Tinker.demo.dto.desempenho.DesempenhoDTO;
import Tinker.demo.dto.desempenho.DesempenhoDisciplinaDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.model.Questao;
import Tinker.demo.model.Relatorio;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.RelatorioRepository;
import Tinker.demo.repository.RelatorioSimuladoRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
public class DesempenhoService {

    private final RelatorioRepository relatorioRepository;
    private final QuestaoRepository questaoRepository;
    private final RelatorioSimuladoRepository relatorioSimuladoRepository;

    public DesempenhoService(
            RelatorioRepository relatorioRepository,
            QuestaoRepository questaoRepository,
            RelatorioSimuladoRepository relatorioSimuladoRepository) {
        this.relatorioRepository = relatorioRepository;
        this.questaoRepository = questaoRepository;
        this.relatorioSimuladoRepository = relatorioSimuladoRepository;
    }

    @Transactional(readOnly = true)
    public DesempenhoDTO consultar(UsuarioAutenticado usuario) {
        exigirAluno(usuario);
        int simuladosConcluidos = contarSimuladosConcluidos(usuario);
        List<Relatorio> relatorios = relatorioRepository.findByEmailAndTipoUsu(
                usuario.email(), usuario.tipoUsuario().name());
        if (relatorios.isEmpty()) {
            return vazio(simuladosConcluidos);
        }

        List<Integer> questoesIds = relatorios.stream()
                .map(Relatorio::getCodQuest)
                .filter(Objects::nonNull)
                .distinct()
                .toList();
        Map<Integer, Questao> questoesPorId = new HashMap<>();
        questaoRepository.findAllById(questoesIds)
                .forEach(questao -> questoesPorId.put(questao.getCodQuestao(), questao));

        Map<String, Totais> totaisPorDisciplina = new java.util.TreeMap<>();
        for (Relatorio relatorio : relatorios) {
            if (!resultadoValido(relatorio.getAcertouErrou())) {
                continue;
            }
            Questao questao = questoesPorId.get(relatorio.getCodQuest());
            String disciplina = questao == null ? null : normalizarDisciplina(questao.getDisciplina());
            if (disciplina == null) {
                continue;
            }
            totaisPorDisciplina.computeIfAbsent(disciplina, ignorada -> new Totais())
                    .adicionar(relatorio.getAcertouErrou());
        }

        if (totaisPorDisciplina.isEmpty()) {
            return vazio(simuladosConcluidos);
        }

        List<DesempenhoDisciplinaDTO> disciplinas = totaisPorDisciplina.entrySet().stream()
                .map(entrada -> paraDTO(entrada.getKey(), entrada.getValue()))
                .toList();
        int questoesRespondidas = disciplinas.stream()
                .mapToInt(DesempenhoDisciplinaDTO::questoesFeitas).sum();
        int totalAcertos = disciplinas.stream()
                .mapToInt(DesempenhoDisciplinaDTO::numeroAcertos).sum();

        DesempenhoDisciplinaDTO maior = disciplinas.get(0);
        DesempenhoDisciplinaDTO menor = disciplinas.get(0);
        for (DesempenhoDisciplinaDTO disciplina : disciplinas) {
            if (disciplina.percentualAcertos() > maior.percentualAcertos()) {
                maior = disciplina;
            }
            if (disciplina.percentualAcertos() < menor.percentualAcertos()) {
                menor = disciplina;
            }
        }

        return new DesempenhoDTO(
                questoesRespondidas,
                totalAcertos,
                percentual(totalAcertos, questoesRespondidas),
                maior,
                menor,
                disciplinas,
                simuladosConcluidos);
    }

    private int contarSimuladosConcluidos(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() != TipoUsuario.ALUNO) {
            return 0;
        }
        return (int) relatorioSimuladoRepository.countByEmailAluno(usuario.email());
    }

    private DesempenhoDisciplinaDTO paraDTO(String disciplina, Totais totais) {
        return new DesempenhoDisciplinaDTO(
                disciplina,
                percentual(totais.acertos, totais.respondidas),
                totais.acertos,
                totais.respondidas);
    }

    private int percentual(int acertos, int respondidas) {
        return respondidas == 0 ? 0 : (int) Math.round(acertos * 100.0 / respondidas);
    }

    private boolean resultadoValido(Integer resultado) {
        return Integer.valueOf(0).equals(resultado) || Integer.valueOf(1).equals(resultado);
    }

    private String normalizarDisciplina(String disciplina) {
        if (disciplina == null || disciplina.isBlank()) {
            return null;
        }
        return disciplina.trim();
    }

    private DesempenhoDTO vazio(int simuladosConcluidos) {
        return new DesempenhoDTO(0, 0, 0, null, null, List.of(), simuladosConcluidos);
    }

    private void exigirAluno(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() == TipoUsuario.ADMINISTRADOR) {
            throw new AcessoNegadoException(
                    "ACESSO_NEGADO",
                    "Esta operacao e permitida somente para aluno.");
        }
    }

    private static class Totais {
        private int respondidas;
        private int acertos;

        private void adicionar(int resultado) {
            respondidas++;
            acertos += resultado;
        }
    }
}
