import estilos from "./CardDetalhesEvento.module.css";

function formatarData(data) {
  if (!data) return "";
  const [ano, mes, dia] = data.split("-").map(Number);
  return new Intl.DateTimeFormat("pt-BR", { dateStyle: "long" }).format(
    new Date(ano, mes - 1, dia, 12),
  );
}

export default function CardDetalhesEvento({
  evento,
  confirmandoRemocao,
  removendo,
  erroRemocao,
  podeExcluir,
  onFechar,
  onSolicitarRemocao,
  onCancelarRemocao,
  onConfirmarRemocao,
}) {
  function handleCliqueOverlay(event) {
    if (event.target === event.currentTarget && !removendo) onFechar();
  }

  return (
    <div className={estilos.overlay} onMouseDown={handleCliqueOverlay}>
      <section
        className={estilos.card}
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-evento-selecionado"
      >
        {!confirmandoRemocao ? (
          <>
            <h2 id="titulo-evento-selecionado" className={estilos.titulo}>
              <span
                className={estilos.corEvento}
                style={{ backgroundColor: evento.cor }}
                aria-hidden="true"
              />
              {evento.titulo}
            </h2>
            <dl className={estilos.detalhes}>
              <div>
                <dt>Data:</dt>
                <dd>{formatarData(evento.data)}</dd>
              </div>
              {evento.diaInteiro ? (
                <div>
                  <dt>Horário:</dt>
                  <dd>Dia inteiro</dd>
                </div>
              ) : (
                <div>
                  <dt>Horário:</dt>
                  <dd>
                    {evento.horarioInicio} – {evento.horarioFim}
                  </dd>
                </div>
              )}
              <div>
                <dt>Cor:</dt>
                <dd>{evento.cor}</dd>
              </div>
            </dl>
            {erroRemocao && (
              <p className={estilos.erro} role="alert">
                {erroRemocao}
              </p>
            )}
            <div className={estilos.acoes}>
              <button className={estilos.botaoSecundario} onClick={onFechar}>
                Fechar
              </button>
              {podeExcluir && (
                <button
                  className={estilos.botaoPerigo}
                  onClick={onSolicitarRemocao}
                >
                  Remover
                </button>
              )}
            </div>
          </>
        ) : (
          <>
            <h2 id="titulo-evento-selecionado" className={estilos.titulo}>
              Remover evento
            </h2>
            <p className={estilos.mensagem}>
              Tem certeza que deseja remover esta ocorrência?
            </p>
            {erroRemocao && (
              <p className={estilos.erro} role="alert">
                {erroRemocao}
              </p>
            )}
            <div className={estilos.acoes}>
              <button
                className={estilos.botaoSecundario}
                onClick={onCancelarRemocao}
                disabled={removendo}
              >
                Cancelar
              </button>
              <button
                className={estilos.botaoPerigo}
                onClick={onConfirmarRemocao}
                disabled={removendo}
              >
                {removendo ? "Removendo..." : "Remover"}
              </button>
            </div>
          </>
        )}
      </section>
    </div>
  );
}
