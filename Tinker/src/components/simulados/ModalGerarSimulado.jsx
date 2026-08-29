import { useState } from "react";
import estiloModal from "./ModalSimulado.module.css";

function ModalGerarSimulado({
  quantidadeQuestoes,
  onFechar,
  onConfirmar,
  gerando,
  erro,
}) {
  const [titulo, setTitulo] = useState("");

  function handleSubmit(event) {
    event.preventDefault();
    if (gerando || !titulo.trim()) return;

    onConfirmar(titulo);
  }

  return (
    <div className={estiloModal.overlay}>
      <div className={estiloModal.modal}>
        <h2 className={estiloModal.titulo}>Gerar simulado</h2>
        <p className={estiloModal.descricao}>
          Confirme o nome para gerar o simulado.
        </p>
        <p className={estiloModal.descricao}>
          Serão selecionadas {quantidadeQuestoes} questões com os filtros informados.
        </p>

        <form onSubmit={handleSubmit} className={estiloModal.formulario}>
          <input
            type="text"
            value={titulo}
            onChange={(event) => setTitulo(event.target.value)}
            placeholder="Ex: Simulado de revisão"
            className={estiloModal.input}
            disabled={gerando}
            maxLength={20}
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
              disabled={gerando}
            >
              Cancelar
            </button>
            <button
              type="submit"
              className={estiloModal.botaoPrimario}
              disabled={gerando || !titulo.trim()}
            >
              {gerando ? "Gerando..." : "Gerar simulado"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalGerarSimulado;
