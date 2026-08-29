import React, { useState, useRef } from 'react';
import styles from './CardSimulado.module.css';
import SimuladoOptions from './SimuladoOptions';

const CardSimulado = ({
    simulado,
    onAbrir,
    onRenomear,
    onBaixar,
    onExcluir,
    somenteLeitura = false,
}) => {
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

    const handleAbrirSimulado = () => {
        handleCloseMenu();
        onAbrir(simulado.id);
    };

    const handleKeyDown = (event) => {
        if (event.target !== event.currentTarget) return;

        if (event.key === "Enter" || event.key === " ") {
            event.preventDefault();
            handleAbrirSimulado();
        }
    };

    // Handlers para as ações do menu (mantidos como estavam)
    const handleRenomearClick = () => {
        handleCloseMenu();
        onRenomear(simulado);
    };

    const handleBaixarClick = () => {
        handleCloseMenu();
        onBaixar(simulado);
    };

    const handleExcluirClick = () => {
        handleCloseMenu();
        onExcluir(simulado);
    };

    if (somenteLeitura) {
        return (
            <article className={`${styles.cardSimulado} ${styles.cardSomenteLeitura}`}>
                <div className={styles.header}>
                    <h3 className={styles.simuladoTitle}>{simulado.titulo}</h3>
                </div>
                {simulado.descricao && (
                    <p className={styles.simuladoDescription}>{simulado.descricao}</p>
                )}
                <p className={styles.simuladoMeta}>
                    {simulado.quantidadeQuestoes} questões
                    {simulado.tempo !== null && ` · ${simulado.tempo} min`}
                </p>
                <div className={styles.acoesSomenteLeitura}>
                    <button
                        type="button"
                        className={styles.botaoRenomear}
                        onClick={() => onRenomear(simulado)}
                    >
                        Renomear
                    </button>
                </div>
            </article>
        );
    }

    return (
        <div
            className={styles.cardSimulado}
            onClick={handleAbrirSimulado}
            onKeyDown={handleKeyDown}
            ref={cardRef}
            role="button"
            tabIndex={0}
        >
            <div className={styles.header}>
                <h3 className={styles.simuladoTitle}>{simulado.titulo}</h3>
                <button
                    type="button"
                    ref={buttonRef}
                    className={styles.menuButton}
                    onClick={handleToggleMenu}
                    aria-label={`Abrir opções de ${simulado.titulo}`}
                >
                    ...
                </button>
                {showMenu && (
                    <SimuladoOptions
                        onClose={handleCloseMenu}
                        position={menuPosition}
                        onAbrir={handleAbrirSimulado}
                        onRenomear={handleRenomearClick}
                        onBaixar={handleBaixarClick}
                        onExcluir={handleExcluirClick}
                    />
                )}
            </div>
            <p className={styles.simuladoDescription}>
                {simulado.quantidadeQuestoes} questões · {simulado.respondidas} respondidas · {simulado.acertos} acertos
            </p>
        </div>
    );
};

export default CardSimulado;
