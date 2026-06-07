import { useState } from "react";
import estiloModal from "./ModalTurma.module.css";

function ModalCriarTurma({ onFechar }) {
  const [nome, setNome] = useState("");

  function handleSubmit(e) {
    e.preventDefault();
    console.log("Turma criada:", nome);
    onFechar();
  }

  return (
    <div className={estiloModal.overlay} onClick={onFechar}>
      <div className={estiloModal.modal} onClick={(e) => e.stopPropagation()}>
        <h2 className={estiloModal.titulo}>Criar turma</h2>
        <p className={estiloModal.descricao}>
          Dê um nome para a sua turma. Um código será gerado automaticamente.
        </p>
        <form onSubmit={handleSubmit} className={estiloModal.formulario}>
          <input
            type="text"
            placeholder="Nome da turma"
            value={nome}
            onChange={(e) => setNome(e.target.value)}
            className={estiloModal.input}
            autoFocus
          />
          <div className={estiloModal.acoes}>
            <button type="button" className={estiloModal.botaoSecundario} onClick={onFechar}>
              Cancelar
            </button>
            <button type="submit" className={estiloModal.botaoPrimario}>
              Criar
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalCriarTurma;