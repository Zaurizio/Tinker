package Tinker.demo.service;

import Tinker.demo.dto.questao.PaginaQuestaoDTO;
import Tinker.demo.dto.questao.QuestaoDTO;
import Tinker.demo.dto.questao.CorrigirQuestaoDTO;
import Tinker.demo.dto.questao.CorrecaoQuestaoDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.model.Questao;
import Tinker.demo.model.Relatorio;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.RelatorioRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import Tinker.demo.specification.QuestaoSpecifications;

@Service
public class QuestaoService {

    private final QuestaoRepository questaoRepository;
    private final QuestaoMapper questaoMapper;
    private final RelatorioRepository relatorioRepository;

    public QuestaoService(
            QuestaoRepository questaoRepository,
            QuestaoMapper questaoMapper,
            RelatorioRepository relatorioRepository) {
        this.questaoRepository = questaoRepository;
        this.questaoMapper = questaoMapper;
        this.relatorioRepository = relatorioRepository;
    }

    @Transactional(readOnly = true)
    public PaginaQuestaoDTO listar(
            List<String> disciplinas,
            List<String> conteudos,
            List<String> vestibulares,
            List<Integer> anos,
            String trecho,
            int pagina,
            int tamanho) {
        validarPagina(pagina, tamanho);

        Pageable pageable = PageRequest.of(
                pagina,
                tamanho,
                Sort.by(Sort.Direction.ASC, "codQuestao"));
        Page<Questao> resultado = questaoRepository.findAll(
                QuestaoSpecifications.comFiltros(
                        disciplinas, conteudos, vestibulares, anos, trecho),
                pageable);
        List<QuestaoDTO> itens = resultado.getContent().stream()
                .map(questaoMapper::paraDTO)
                .toList();

        return new PaginaQuestaoDTO(
                itens,
                resultado.hasNext(),
                resultado.getTotalElements(),
                pagina,
                tamanho);
    }

    @Transactional(readOnly = true)
    public QuestaoDTO detalhar(Integer id) {
        Questao questao = questaoRepository.findById(id)
                .filter(item -> item.getAtivo() != null && item.getAtivo() == 1)
                .orElseThrow(() -> new RecursoNaoEncontradoException(
                        "QUESTAO_NAO_ENCONTRADA",
                        "A questao nao foi encontrada."));
        return questaoMapper.paraDTO(questao);
    }

    @Transactional
    public CorrecaoQuestaoDTO corrigir(
            UsuarioAutenticado usuario, Integer id, CorrigirQuestaoDTO dados) {
        if (usuario.tipoUsuario() == TipoUsuario.ADMINISTRADOR) {
            throw new AcessoNegadoException(
                    "ACESSO_NEGADO", "Administrador não pode responder questões.");
        }
        Questao questao = questaoRepository.findById(id)
                .filter(item -> Integer.valueOf(1).equals(item.getAtivo()))
                .orElseThrow(() -> new RecursoNaoEncontradoException(
                        "QUESTAO_NAO_ENCONTRADA", "A questão não foi encontrada."));
        boolean acertou = CorretorQuestao.corrigir(questao, dados.alternativa());
        String tipo = usuario.tipoUsuario().name();
        Relatorio relatorio = relatorioRepository
                .findByCodQuestAndEmailAndTipoUsu(id, usuario.email(), tipo)
                .orElseGet(Relatorio::new);
        relatorio.setCodQuest(id);
        relatorio.setEmail(usuario.email());
        relatorio.setTipoUsu(tipo);
        relatorio.setAcertouErrou(acertou ? 1 : 0);
        relatorioRepository.save(relatorio);
        return new CorrecaoQuestaoDTO(
                id,
                acertou,
                acertou ? null : CorretorQuestao.alternativaCorreta(questao));
    }

    private void validarPagina(int pagina, int tamanho) {
        if (pagina < 0) {
            throw new DadosInvalidosException(
                    "PAGINA_INVALIDA",
                    "A pagina deve ser maior ou igual a zero.");
        }
        if (tamanho < 1 || tamanho > 50) {
            throw new DadosInvalidosException(
                    "TAMANHO_PAGINA_INVALIDO",
                    "O tamanho da pagina deve estar entre 1 e 50.");
        }
    }
}
