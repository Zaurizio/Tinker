import { useEffect, useRef, useState } from "react";
import estiloModal from "./ModalTurma.module.css";

function ModalCriarTurma({ onCriar, onFechar }) {
  const [nome, setNome] = useState("");
  const [criando, setCriando] = useState(false);
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
    const nomeNormalizado = nome.trim();

    if (operacaoEmAndamentoRef.current) return;

    if (!nomeNormalizado) {
      setErro("Digite um nome para a turma.");
      return;
    }

    operacaoEmAndamentoRef.current = true;
    setCriando(true);
    setErro("");

    try {
      await onCriar({ nome: nomeNormalizado });
      if (componenteMontadoRef.current) onFechar();
    } catch (erroCriacao) {
      if (!componenteMontadoRef.current) return;

      setErro(
        erroCriacao instanceof Error
          ? `${erroCriacao.message}${erroCriacao.codigo ? ` (${erroCriacao.codigo})` : ""}`
          : "Não foi possível criar a turma.",
      );
      operacaoEmAndamentoRef.current = false;
      setCriando(false);
    }
  }

  return (
    <div className={estiloModal.overlay} onClick={criando ? undefined : onFechar}>
      <div
        className={estiloModal.modal}
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-criar-turma"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 id="titulo-criar-turma" className={estiloModal.titulo}>Criar turma</h2>
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
            disabled={criando}
            maxLength={45}
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
              disabled={criando}
            >
              Cancelar
            </button>
            <button type="submit" className={estiloModal.botaoPrimario} disabled={criando}>
              {criando ? "Criando..." : "Criar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalCriarTurma;
