import estilos from "./CardDetalhesEvento.module.css";

function formatarData(data) {
  if (!data) return "";
  const [ano, mes, dia] = data.split("-").map(Number);
  return new Intl.DateTimeFormat("pt-BR", { dateStyle: "long" }).format(
    new Date(ano, mes - 1, dia, 12)
  );
}

export default function CardDetalhesEvento({
  evento,
  etapa,
  carregando,
  erroDetalhes,
  removendo,
  erroRemocao,
  onFechar,
  onRemover,
  onContinuar,
  onRemoverOcorrencia,
  onRemoverSerie,
}) {
  const operacaoEmAndamento = carregando || removendo;

  function handleCliqueOverlay(event) {
    if (event.target === event.currentTarget && !operacaoEmAndamento) onFechar();
  }

  return (
    <div className={estilos.overlay} onMouseDown={handleCliqueOverlay}>
      <section
        className={estilos.card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={evento ? "titulo-evento-selecionado" : undefined}
      >
        {carregando && <p className={estilos.estado}>Carregando evento...</p>}

        {!carregando && erroDetalhes && (
          <>
            <p className={estilos.erro} role="alert">{erroDetalhes}</p>
            <div className={estilos.acoes}>
              <button className={estilos.botaoSecundario} onClick={onFechar}>Fechar</button>
            </div>
          </>
        )}

        {!carregando && evento && etapa === "detalhes" && (
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
              <div><dt>Data:</dt><dd>{formatarData(evento.data)}</dd></div>
              {evento.tipo === "dia_inteiro" ? (
                <div><dt>Horário:</dt><dd>Dia inteiro</dd></div>
              ) : (
                <div>
                  <dt>Horário:</dt>
                  <dd>{evento.horarioInicio} – {evento.horarioFim}</dd>
                </div>
              )}
              {evento.recorrencia && (
                <div><dt>Recorrência:</dt><dd>{evento.recorrencia}</dd></div>
              )}
            </dl>
            {erroRemocao && <p className={estilos.erro} role="alert">{erroRemocao}</p>}
            <div className={estilos.acoes}>
              <button className={estilos.botaoSecundario} onClick={onFechar}>Fechar</button>
              <button className={estilos.botaoPerigo} onClick={onRemover}>Remover</button>
            </div>
          </>
        )}

        {!carregando && evento && etapa === "confirmacao" && (
          <>
            <h2 id="titulo-evento-selecionado" className={estilos.titulo}>Remover evento</h2>
            <p className={estilos.mensagem}>Tem certeza que deseja remover este evento?</p>
            {erroRemocao && <p className={estilos.erro} role="alert">{erroRemocao}</p>}
            <div className={estilos.acoes}>
              <button className={estilos.botaoSecundario} onClick={onFechar} disabled={operacaoEmAndamento}>Cancelar</button>
              <button className={estilos.botaoPerigo} onClick={onContinuar} disabled={operacaoEmAndamento}>
                {removendo ? "Removendo..." : "Continuar"}
              </button>
            </div>
          </>
        )}

        {!carregando && evento && etapa === "escolhaSerie" && (
          <>
            <h2 id="titulo-evento-selecionado" className={estilos.titulo}>Remover evento recorrente</h2>
            <p className={estilos.mensagem}>
              Deseja remover somente este evento ou todos os eventos desta sequência?
            </p>
            {erroRemocao && <p className={estilos.erro} role="alert">{erroRemocao}</p>}
            <div className={estilos.acoes}>
              <button className={estilos.botaoSecundario} onClick={onFechar} disabled={operacaoEmAndamento}>Cancelar</button>
              <button className={estilos.botaoSecundario} onClick={onRemoverOcorrencia} disabled={operacaoEmAndamento}>
                {removendo ? "Removendo..." : "Somente este"}
              </button>
              <button className={estilos.botaoPerigo} onClick={onRemoverSerie} disabled={operacaoEmAndamento}>
                {removendo ? "Removendo..." : "Todos"}
              </button>
            </div>
          </>
        )}
      </section>
    </div>
  );
}
