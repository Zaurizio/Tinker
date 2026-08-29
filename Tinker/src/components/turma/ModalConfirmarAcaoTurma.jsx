import estiloModal from "../simulados/ModalSimulado.module.css";

function ModalConfirmarAcaoTurma({
  titulo,
  descricao,
  textoConfirmar,
  processando,
  erro,
  onConfirmar,
  onFechar,
}) {
  return (
    <div className={estiloModal.overlay}>
      <div className={estiloModal.modal} role="dialog" aria-modal="true">
        <h2 className={estiloModal.titulo}>{titulo}</h2>
        <p className={estiloModal.descricao}>{descricao}</p>

        {erro && (
          <p className={estiloModal.erro} role="alert">
            {erro}
          </p>
        )}

        <div className={estiloModal.acoes}>
          <button
            type="button"
            className={estiloModal.botaoSecundario}
            onClick={onFechar}
            disabled={processando}
          >
            Cancelar
          </button>
          <button
            type="button"
            className={estiloModal.botaoDestrutivo}
            onClick={onConfirmar}
            disabled={processando}
          >
            {processando ? "Processando..." : textoConfirmar}
          </button>
        </div>
      </div>
    </div>
  );
}

export default ModalConfirmarAcaoTurma;
