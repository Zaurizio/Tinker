import { useState } from "react";
import { MdGroups } from "react-icons/md";
import estiloModal from "../simulados/ModalSimulado.module.css";
import estiloConfig from "./ModalConfiguracoesTurma.module.css";

function formatarErroApi(erro, mensagemPadrao) {
  if (!(erro instanceof Error)) return mensagemPadrao;
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function ModalConfiguracoesTurma({
  turma,
  onFechar,
  onRenomear,
  onSolicitarExclusao,
}) {
  const [nome, setNome] = useState(turma.nome);
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState("");

  const nomeTratado = nome.trim();
  const houveAlteracao = nomeTratado !== "" && nomeTratado !== turma.nome;

  async function handleSalvar(evento) {
    evento.preventDefault();
    if (!houveAlteracao || salvando) return;

    setSalvando(true);
    setErro("");

    try {
      await onRenomear(nomeTratado);
      onFechar();
    } catch (erroRenomeacao) {
      setErro(
        formatarErroApi(erroRenomeacao, "Não foi possível renomear a turma."),
      );
      setSalvando(false);
    }
  }

  return (
    <div className={estiloModal.overlay} onClick={onFechar}>
      <div
        className={estiloModal.modal}
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-configuracoes-turma"
        onClick={(evento) => evento.stopPropagation()}
      >
        <h2 id="titulo-configuracoes-turma" className={estiloModal.titulo}>
          Configurações da turma
        </h2>

        <form onSubmit={handleSalvar}>
          <div className={estiloConfig.identidade}>
            <div className={estiloConfig.foto}>
              <MdGroups aria-hidden="true" />
            </div>

            <input
              type="text"
              className={`${estiloModal.input} ${estiloConfig.inputNome}`}
              value={nome}
              onChange={(evento) => setNome(evento.target.value)}
              maxLength={45}
              disabled={salvando}
              aria-label="Nome da turma"
            />
          </div>

          {erro && (
            <p className={estiloModal.erro} role="alert">
              {erro}
            </p>
          )}

          <div
            className={`${estiloModal.acoes} ${estiloConfig.acoesConfiguracoes}`}
          >
            <button
              type="button"
              className={`${estiloConfig.opcao} ${estiloConfig.opcaoDestrutiva}`}
              onClick={onSolicitarExclusao}
            >
              Excluir turma
            </button>
            <button
              type="button"
              className={estiloModal.botaoSecundario}
              onClick={onFechar}
              disabled={salvando}
            >
              Fechar
            </button>
            <button
              type="submit"
              className={estiloModal.botaoPrimario}
              disabled={salvando || !houveAlteracao}
            >
              {salvando ? "Salvando..." : "Salvar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalConfiguracoesTurma;
