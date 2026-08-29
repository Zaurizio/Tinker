import { useEffect, useRef, useState } from "react";
import estiloModal from "./ModalTurma.module.css";

function ModalEntrarTurma({ onEntrar, onFechar }) {
  const [codigo, setCodigo] = useState("");
  const [entrando, setEntrando] = useState(false);
  const [erro, setErro] = useState("");
  const operacaoEmAndamentoRef = useRef(false);
  const componenteMontadoRef = useRef(true);

  useEffect(() => {
    componenteMontadoRef.current = true;

    return () => {
      componenteMontadoRef.current = false;
    };
  }, []);

  async function handleSubmit(e) {
    e.preventDefault();
    const codigoNormalizado = codigo.trim();

    if (operacaoEmAndamentoRef.current) return;

    if (!/^\d{8}$/.test(codigoNormalizado)) {
      setErro("O código deve conter exatamente oito dígitos.");
      return;
    }

    operacaoEmAndamentoRef.current = true;
    setEntrando(true);
    setErro("");

    try {
      await onEntrar(codigoNormalizado);
      if (componenteMontadoRef.current) onFechar();
    } catch (erroEntrada) {
      if (!componenteMontadoRef.current) return;

      setErro(
        erroEntrada instanceof Error
          ? `${erroEntrada.message}${erroEntrada.codigo ? ` (${erroEntrada.codigo})` : ""}`
          : "Não foi possível entrar na turma.",
      );
      operacaoEmAndamentoRef.current = false;
      setEntrando(false);
    }
  }

  return (
    <div className={estiloModal.overlay} onClick={entrando ? undefined : onFechar}>
      <div
        className={estiloModal.modal}
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-entrar-turma"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 id="titulo-entrar-turma" className={estiloModal.titulo}>Entrar em turma</h2>
        <p className={estiloModal.descricao}>
          Digite o código da turma compartilhado pelo administrador.
        </p>
        <form onSubmit={handleSubmit} className={estiloModal.formulario}>
          <input
            type="text"
            placeholder="Código da turma"
            value={codigo}
            onChange={(e) => setCodigo(e.target.value.replace(/\D/g, ""))}
            className={estiloModal.input}
            disabled={entrando}
            inputMode="numeric"
            maxLength={8}
            autoFocus
          />
          {erro && (
            <div className={estiloModal.erro} role="alert">
              {erro}
            </div>
          )}
          <div className={estiloModal.acoes}>
            <button
              type="button"
              className={estiloModal.botaoSecundario}
              onClick={onFechar}
              disabled={entrando}
            >
              Cancelar
            </button>
            <button type="submit" className={estiloModal.botaoPrimario} disabled={entrando}>
              {entrando ? "Entrando..." : "Entrar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalEntrarTurma;
