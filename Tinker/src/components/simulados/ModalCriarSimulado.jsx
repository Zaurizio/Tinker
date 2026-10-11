import { useState } from "react";
import estiloModal from "./ModalSimulado.module.css";

function ModalCriarSimulado({ onFechar, onSalvar, salvando, erro }) {
  const [titulo, setTitulo] = useState("");

  const handleSubmit = (event) => {
    event.preventDefault();
    if (salvando || !titulo.trim()) return;

    onSalvar(titulo);
  };

  return (
    <div className={estiloModal.overlay}>
      <div className={estiloModal.modal}>
        <h2 className={estiloModal.titulo}>Criar Novo Simulado</h2>
        <p className={estiloModal.descricao}>Dê um nome para o seu simulado.</p>
        <form onSubmit={handleSubmit} className={estiloModal.formulario}>
          <input
            type="text"
            id="nomeSimulado"
            value={titulo}
            onChange={(event) => setTitulo(event.target.value)}
            placeholder="Ex: Simulado ENEM Matemática"
            className={estiloModal.input}
            disabled={salvando}
            required
          />
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
              disabled={salvando}
            >
              Cancelar
            </button>
            <button
              type="submit"
              className={estiloModal.botaoPrimario}
              disabled={salvando || !titulo.trim()}
            >
              {salvando ? "Criando..." : "Criar Simulado"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalCriarSimulado;
