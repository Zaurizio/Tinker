import { useState } from "react";
import estiloModal from "./ModalTurma.module.css";

function ModalEntrarTurma({ onFechar }) {
  const [codigo, setCodigo] = useState("");

  function handleSubmit(e) {
    e.preventDefault();
    console.log("Código digitado:", codigo);
    onFechar();
  }

  return (
    <div className={estiloModal.overlay} onClick={onFechar}>
      <div className={estiloModal.modal} onClick={(e) => e.stopPropagation()}>
        <h2 className={estiloModal.titulo}>Entrar em turma</h2>
        <p className={estiloModal.descricao}>
          Digite o código da turma compartilhado pelo administrador.
        </p>
        <form onSubmit={handleSubmit} className={estiloModal.formulario}>
          <input
            type="text"
            placeholder="Código da turma"
            value={codigo}
            onChange={(e) => setCodigo(e.target.value)}
            className={estiloModal.input}
            autoFocus
          />
          <div className={estiloModal.acoes}>
            <button type="button" className={estiloModal.botaoSecundario} onClick={onFechar}>
              Cancelar
            </button>
            <button type="submit" className={estiloModal.botaoPrimario}>
              Entrar
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalEntrarTurma;