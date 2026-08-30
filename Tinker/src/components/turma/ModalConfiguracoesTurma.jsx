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
  const [editandoNome, setEditandoNome] = useState(false);
  const [nome, setNome] = useState(turma.nome);
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState("");

  async function handleSalvarNome(evento) {
    evento.preventDefault();
    const nomeTratado = nome.trim();
    if (!nomeTratado || salvando) return;

    setSalvando(true);
    setErro("");

    try {
      await onRenomear(nomeTratado);
      setEditandoNome(false);
    } catch (erroRenomeacao) {
      setErro(
        formatarErroApi(erroRenomeacao, "Não foi possível renomear a turma."),
      );
    } finally {
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

        <div className={estiloConfig.identidade}>
          <div className={estiloConfig.foto}>
            <MdGroups aria-hidden="true" />
          </div>

          {editandoNome ? (
            <form
              className={estiloConfig.formNome}
              onSubmit={handleSalvarNome}
            >
              <input
                type="text"
                className={estiloModal.input}
                value={nome}
                onChange={(evento) => setNome(evento.target.value)}
                maxLength={45}
                autoFocus
                disabled={salvando}
              />
              <div className={estiloConfig.acoesNome}>
                <button
                  type="button"
                  className={estiloModal.botaoSecundario}
                  onClick={() => {
                    setNome(turma.nome);
                    setErro("");
                    setEditandoNome(false);
                  }}
                  disabled={salvando}
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  className={estiloModal.botaoPrimario}
                  disabled={salvando}
                >
                  {salvando ? "Salvando..." : "Salvar"}
                </button>
              </div>
            </form>
          ) : (
            <h3 className={estiloConfig.nomeTurma}>{turma.nome}</h3>
          )}
        </div>

        {erro && (
          <p className={estiloModal.erro} role="alert">
            {erro}
          </p>
        )}

        {!editandoNome && (
          <div className={estiloConfig.opcoes}>
            <button
              type="button"
              className={estiloConfig.opcao}
              onClick={() => setEditandoNome(true)}
            >
              Renomear turma
            </button>
            <button
              type="button"
              className={`${estiloConfig.opcao} ${estiloConfig.opcaoDestrutiva}`}
              onClick={onSolicitarExclusao}
            >
              Excluir turma
            </button>
          </div>
        )}

        <div className={estiloModal.acoes}>
          <button
            type="button"
            className={estiloModal.botaoSecundario}
            onClick={onFechar}
          >
            Fechar
          </button>
        </div>
      </div>
    </div>
  );
}

export default ModalConfiguracoesTurma;
