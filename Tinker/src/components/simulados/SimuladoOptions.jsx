import { useEffect, useRef } from "react";
import { GoTrash } from "react-icons/go";
import { MdEditNote, MdOpenInNew, MdOutlineSaveAlt } from "react-icons/md";
import estilos from "./SimuladoOptions.module.css";

function SimuladoOptions({
  onClose,
  position,
  onAbrir,
  onRenomear,
  onBaixar,
  onExcluir,
}) {
  const menuRef = useRef(null);

  useEffect(() => {
    function handleClickOutside(event) {
      if (menuRef.current && !menuRef.current.contains(event.target)) {
        onClose();
      }
    }

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [onClose]);

  const menuStyle = {
    top: position.top,
    left: position.left,
    transform: position.shouldGoUp
      ? "translateY(-100%) translateY(90%)"
      : "translateY(0)",
  };

  return (
    <div
      ref={menuRef}
      className={estilos.dropdownMenu}
      style={menuStyle}
      onClick={(event) => event.stopPropagation()}
      role="menu"
    >
      <button type="button" className={estilos.opcao} onClick={onAbrir} role="menuitem">
        <MdOpenInNew className={estilos.icone} />
        Abrir
      </button>
      <button type="button" className={estilos.opcao} onClick={onRenomear} role="menuitem">
        <MdEditNote className={estilos.icone} />
        Renomear
      </button>
      <button type="button" className={estilos.opcao} onClick={onBaixar} role="menuitem">
        <MdOutlineSaveAlt className={estilos.icone} />
        Baixar
      </button>
      <button
        type="button"
        className={`${estilos.opcao} ${estilos.opcaoDestrutiva}`}
        onClick={onExcluir}
        role="menuitem"
      >
        <GoTrash className={estilos.icone} />
        Excluir
      </button>
    </div>
  );
}

export default SimuladoOptions;
