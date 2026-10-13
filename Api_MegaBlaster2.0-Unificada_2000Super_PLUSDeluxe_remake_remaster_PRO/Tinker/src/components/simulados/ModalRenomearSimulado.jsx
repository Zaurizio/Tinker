import { useEffect, useRef, useState } from "react";
import estiloModal from "./ModalSimulado.module.css";

function ModalRenomearSimulado({
  tituloAtual,
  onFechar,
  onConfirmar,
  renomeando,
  erro,
}) {
  const [titulo, setTitulo] = useState(tituloAtual);
  const inputRef = useRef(null);
  const tituloNormalizado = titulo.trim();
  const tituloAtualNormalizado = tituloAtual.trim();
  const envioInvalido =
    !tituloNormalizado || tituloNormalizado === tituloAtualNormalizado;

  useEffect(() => {
    inputRef.current?.select();
  }, []);

  function handleSubmit(event) {
    event.preventDefault();
    if (renomeando || envioInvalido) return;

    onConfirmar(tituloNormalizado);
  }

  return (
    <div className={estiloModal.overlay}>
      <div className={estiloModal.modal}>
        <h2 className={estiloModal.titulo}>Renomear simulado</h2>
        <form className={estiloModal.formulario} onSubmit={handleSubmit}>
          <input
            ref={inputRef}
            type="text"
            className={estiloModal.input}
            value={titulo}
            onChange={(event) => setTitulo(event.target.value)}
            disabled={renomeando}
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
              disabled={renomeando}
            >
              Cancelar
            </button>
            <button
              type="submit"
              className={estiloModal.botaoPrimario}
              disabled={renomeando || envioInvalido}
            >
              {renomeando ? "Renomeando..." : "Renomear"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalRenomearSimulado;
