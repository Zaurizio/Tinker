import React, { useState, useRef } from 'react';
import styles from './CardSimulado.module.css';
import SimuladoOptions from './SimuladoOptions';

const CardSimulado = ({ simulado, onMoveToFolder, onDelete, onRename, onDownload, onChangeCop }) => {
    const [showMenu, setShowMenu] = useState(false);
    const [menuPosition, setMenuPosition] = useState({ top: 0, left: 0, shouldGoUp: false });
    const buttonRef = useRef(null); // Referência para o botão de três pontinhos
    const cardRef = useRef(null); // NOVO: Referência para o CardSimulado

    const handleToggleMenu = (event) => {
        event.stopPropagation();

        if (showMenu) {
            setShowMenu(false);
            return;
        }

        const buttonRect = buttonRef.current.getBoundingClientRect();
        const cardRect = cardRef.current.getBoundingClientRect(); // NOVO: Posição do card
        const viewportHeight = window.innerHeight || document.documentElement.clientHeight;

        // NOVO CÁLCULO: Posição do menu relativa ao CardSimulado
        // O 'top' é a distância do botão até o topo do card, mais um pequeno offset
        let top = buttonRect.bottom - cardRect.top + 5; // 5px de espaçamento
        // O 'left' é a distância do botão até a esquerda do card
        let left = buttonRect.left - cardRect.left;

        // Lógica para verificar se o menu vaza para baixo
        const menuHeightEstimate = 180; // Ajuste conforme a altura real do seu menu
        const spaceBelowViewport = viewportHeight - buttonRect.bottom; // Espaço do botão até o fim da viewport

        let shouldGoUp = false;
        // Se o menu, posicionado abaixo do botão, for vazar da viewport
        // E se houver espaço suficiente acima do botão na viewport
        if (spaceBelowViewport < menuHeightEstimate && buttonRect.top > menuHeightEstimate) {
            shouldGoUp = true;
            // Se for para cima, o 'top' precisa ser ajustado para a parte superior do botão
            // e o CSS fará o resto com translateY(-100%)
            top = buttonRect.top - cardRect.top - 5; // 5px de espaçamento acima do botão
        }

        setMenuPosition({ top, left, shouldGoUp });
        setShowMenu(true);
    };

    const handleCloseMenu = () => {
        setShowMenu(false);
    };

    // Handlers para as ações do menu (mantidos como estavam)
    const handleMoveToFolderClick = () => { onMoveToFolder(simulado.id); handleCloseMenu(); };
    const handleDeleteClick = () => { onDelete(simulado.id); handleCloseMenu(); };
    const handleRenameClick = () => { onRename(simulado.id, simulado.nome); handleCloseMenu(); };
    const handleDownloadClick = () => { onDownload(simulado.id); handleCloseMenu(); };
    const handleChangeCopClick = () => { onChangeCop(simulado.id); handleCloseMenu(); };

    return (
        <div className={styles.cardSimulado} onClick={handleCloseMenu} ref={cardRef}> {/* Adicione a referência ao card */}
            <div className={styles.header}>
                <h3 className={styles.simuladoTitle}>{simulado.nome}</h3>
                <button
                    ref={buttonRef}
                    className={styles.menuButton}
                    onClick={handleToggleMenu}
                >
                    ...
                </button>
                {showMenu && (
                    <SimuladoOptions
                        onClose={handleCloseMenu}
                        position={menuPosition}
                        onMoveToFolder={handleMoveToFolderClick}
                        onDelete={handleDeleteClick}
                        onRename={handleRenameClick}
                        onDownload={handleDownloadClick}
                        onChangeCop={handleChangeCopClick}
                    />
                )}
            </div>
            <p className={styles.simuladoDescription}>{simulado.descricao || "Nenhuma descrição disponível."}</p>
        </div>
    );
};

export default CardSimulado;