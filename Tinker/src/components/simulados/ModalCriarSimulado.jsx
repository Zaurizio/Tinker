import { useState } from "react";
import estiloModal from "./ModalSimulado.module.css"; // Novo arquivo de estilo para modais de simulado

function ModalCriarSimulado({ onFechar, onSalvar }) {
  const [nomeSimulado, setNomeSimulado] = useState('');

  const handleSubmit = (event) => {
    event.preventDefault();
    if (nomeSimulado.trim()) { // Garante que o nome não está vazio
      onSalvar(nomeSimulado); // Chama a função passada pelo componente pai
    } else {
      alert('Por favor, digite um nome para o simulado.');
    }
  };

  return (
    <div className={estiloModal.overlay}>
      <div className={estiloModal.modal}>
        <h2 className={estiloModal.titulo}>Criar Novo Simulado</h2>
        <p className={estiloModal.descricao}>
          Dê um nome para o seu simulado.
        </p>
        <form onSubmit={handleSubmit} className={estiloModal.formulario}>
            <input
              type="text"
              id="nomeSimulado"
              value={nomeSimulado}
              onChange={(e) => setNomeSimulado(e.target.value)}
              placeholder="Ex: Simulado ENEM Matemática"
              className={estiloModal.input}
              required
            />
          <div className={estiloModal.acoes}>
            <button type="button" className={estiloModal.botaoSecundario} onClick={onFechar}>
              Cancelar
            </button>
            <button type="submit" className={estiloModal.botaoPrimario}>
              Criar Simulado
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalCriarSimulado;