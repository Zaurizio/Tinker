import { FiSearch } from "react-icons/fi";
import estiloBarraBusca from "./BarraBusca.module.css";

function BarraBusca({ placeholder = "Pesquisar...", value, onChange }) {
  return (
    <div className={estiloBarraBusca.campoBusca}>
      <FiSearch className={estiloBarraBusca.icone} />
      <input
        type="text"
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className={estiloBarraBusca.input}
      />
    </div>
  );
}

export default BarraBusca;