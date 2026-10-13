import React, { useRef, useEffect } from 'react';
import estilos from './SimuladoOptions.module.css';

//icones
import { MdOutlineSaveAlt } from 'react-icons/md'; // Para Baixar
import { MdEditNote } from 'react-icons/md';       // Para Renomear
import { RiFolderTransferLine } from 'react-icons/ri'; // Para Mandar para pasta
import { VscSymbolColor } from 'react-icons/vsc';   // Para Mudar COP (símbolo de cor)
import { GoTrash } from 'react-icons/go';           // Para Excluir

const SimuladoOptions = ({ onClose, position, onMoveToFolder, onDelete, onRename, onDownload, onChangeCop }) => {
    const menuRef = useRef(null);

    // Efeito para fechar o menu ao clicar fora
    useEffect(() => {
        function handleClickOutside(event) {
            if (menuRef.current && !menuRef.current.contains(event.target)) {
                onClose(); // Chama a função onClose passada pelo pai
            }
        }

        document.addEventListener('mousedown', handleClickOutside);
        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, [onClose]);

    // Estilo dinâmico para posicionar o menu
    const menuStyle = {
        top: position.top,
        left: position.left,
        transform: position.shouldGoUp ? 'translateY(-100%) translateY(90%)' : 'translateY(0)',
    };

    return (
        <div
            ref={menuRef}
            className={estilos.dropdownMenu}
            style={menuStyle}
            onClick={(e) => e.stopPropagation()} // Impede que o clique no menu feche ele imediatamente
        >
            <ul>
                <li onClick={onDownload}>
                    <MdOutlineSaveAlt className={estilos.icon} /> Baixar
                </li>
                <li onClick={onRename}>
                    <MdEditNote className={estilos.icon} /> Renomear
                </li>
                {/* Se 'Mandar para pasta' for uma opção, adicione-a aqui */}
                {/* Por exemplo: */}
                {/* <li onClick={onMoveToFolder}>
                    <RiFolderTransferLine className={estilos.icon} /> Mandar para pasta
                </li> */}
                <li onClick={onChangeCop}>
                    <VscSymbolColor className={estilos.icon} /> Mudar cor
                </li>
                <li className={estilos.deleteOption} onClick={onDelete}>
                    <GoTrash className={estilos.icon} /> Excluir
                </li>
            </ul>
        </div>
    );
};

export default SimuladoOptions;