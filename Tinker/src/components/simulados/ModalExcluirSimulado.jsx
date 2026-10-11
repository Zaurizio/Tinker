import estiloModal from "./ModalSimulado.module.css";

function ModalExcluirSimulado({
  onFechar,
  onConfirmar,
  excluindo,
  erro,
}) {
  function handleConfirmar() {
    if (excluindo) return;
    onConfirmar();
  }

  return (
    <div className={estiloModal.overlay}>
      <div className={estiloModal.modal}>
        <h2 className={estiloModal.titulo}>Excluir simulado</h2>
        <p className={estiloModal.descricao}>
          Tem certeza que deseja excluir? O simulado deixará de existir em
          {" \"Meus simulados\"."}
        </p>

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
            disabled={excluindo}
          >
            Cancelar
          </button>
          <button
            type="button"
            className={estiloModal.botaoDestrutivo}
            onClick={handleConfirmar}
            disabled={excluindo}
          >
            {excluindo ? "Excluindo..." : "Excluir"}
          </button>
        </div>
      </div>
    </div>
  );
}

export default ModalExcluirSimulado;
