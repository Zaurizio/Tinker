/*seta baixo*/ import { IoIosArrowDown } from "react-icons/io"; //<IoIosArrowDown />
/*seta cima*/ import { IoIosArrowUp } from "react-icons/io"; //<IoIosArrowUp />
import { useEffect, useMemo, useRef, useState } from "react";
import Checkbox from "@mui/material/Checkbox";
{/*useEffect: executa efeitos quando algo muda,
  useRef: guarda referencia de um elemento do DOM,
  useMemo: calcula valor derivado sem recalcular tudo a toa  
*/}
import estiloCampoSelM from "./CampoSelecaoMultipla.module.css";

function CampoSelecaoMultipla({
  /*props que vem de */
  label,
  placeholder,
  opcoes = [],
  selecionadas = [],
  onChange,
  desabilitado = false,
}) {
  const [aberto, setAberto] = useState(false); {/*se o painel está aberto*/}
  const [busca, setBusca] = useState(""); {/*guarda o que usuario digitou em busca*/}
  const [selecionadasTemporarias, setSelecionadasTemporarias] = useState(selecionadas);
  {/*guarda opções marcadas no painel*/}
  const [selecionadasSincronizadas, setSelecionadasSincronizadas] = useState(selecionadas);

  const containerRef = useRef(null); {/*cria referencia pra area do campo (se clicou dentro ou fora) ?*/}

  if (selecionadas !== selecionadasSincronizadas) {
    setSelecionadasSincronizadas(selecionadas);
    setSelecionadasTemporarias(selecionadas);
  } {/*selecionadas temporarias = selecionadas (?)*/}

  {/*se clicar fora sai do painel*/}
  useEffect(() => {
    function handleClickFora(event) {
      if (containerRef.current && !containerRef.current.contains(event.target)) { 
        /*se existe container e o clique não foi dentro dele*/
        setSelecionadasTemporarias(selecionadas);
        setBusca("");
        setAberto(false);
      }
    }

    document.addEventListener("mousedown", handleClickFora);
    return () => {
      document.removeEventListener("mousedown", handleClickFora);
    };
  }, [selecionadas]); {/*o que caralhos isso significa*/}

  const normalizarTexto = (texto) =>
    texto
      .normalize("NFD") /*separa acento da letra*/
      .replace(/[\u0300-\u036f]/g, "") /*remove acento separado*/
      .toLowerCase();

  const opcoesFiltradas = useMemo(() => {
    return opcoes.filter((opcao) =>
      normalizarTexto(opcao).startsWith(normalizarTexto(busca))
    );
  }, [opcoes, busca]);
  {/*cria nova lista opcoesFiltradas*/}

  function abrirPainel() {
    if (desabilitado) return;
    setSelecionadasTemporarias(selecionadas);
    setAberto(true);
  }

  function fecharPainel() {
    setSelecionadasTemporarias(selecionadas);
    setBusca("");
    setAberto(false);
  }

  {/*quando clica numa opção, add ou remove*/}
  function toggleOpcao(opcao) {
    const jaSelecionada = selecionadasTemporarias.includes(opcao);
    /*verifica se ja está selecionada*/

    if (jaSelecionada) {
      setSelecionadasTemporarias(
        selecionadasTemporarias.filter((item) => item !== opcao)
        /*se ja tiver selecionada tira de selecionadasTemporarias(marcadas)*/
      );
      return;
    }

    setSelecionadasTemporarias([...selecionadasTemporarias, opcao]);
    /*adiciona opçao*/
  }

  function aplicarSelecao() {
    onChange(selecionadasTemporarias); 
    {/*passa valor de selecionadasTemporarias pra filtros.disciplinas = selecionadas*/}
    setBusca("");
    setAberto(false);
  }

  function limparSelecao() {
    setSelecionadasTemporarias([]);
  }

  {/*mostra no campo o que tá selecionado*/}
  function gerarResumo() {
    if (selecionadas.length === 0) {
      return placeholder;
    }

    if (selecionadas.length === 1) {
      return selecionadas[0];
    }

    if (selecionadas.length === 2) {
      return `${selecionadas[0]}, ${selecionadas[1]}`;
    }

    return `${selecionadas[0]}, ${selecionadas[1]} +${selecionadas.length - 2}`;
  }

  return (
    <div className={estiloCampoSelM.campoSelecao}>
      <label className={estiloCampoSelM.label}>{label}</label>

      <div className={estiloCampoSelM.areaCampo} ref={containerRef}>
        <button
          type="button"
          className={`${estiloCampoSelM.botaoCampo} ${aberto ? estiloCampoSelM.botaoCampoAberto : ""} ${
            desabilitado ? estiloCampoSelM.botaoCampoDesabilitado : ""
          }`}
          onClick={() => (aberto ? fecharPainel() : abrirPainel())}
          disabled={desabilitado}
          aria-busy={desabilitado}
        >
          <span
            className={`${estiloCampoSelM.valorCampo} ${
              selecionadas.length === 0 ? estiloCampoSelM.placeholder : ""
            }`}
          >
            {gerarResumo()}
          </span>

          <span
            className={`${estiloCampoSelM.seta} ${aberto ? estiloCampoSelM.setaAberta : ""}`}
          >
            <IoIosArrowDown />
          </span>
        </button>

        {aberto && !desabilitado && (
          <div className={estiloCampoSelM.painelSelecao}>
            <div className={estiloCampoSelM.topoPainel}>
              <input
                type="text"
                value={busca}
                onChange={(event) => setBusca(event.target.value)}
                placeholder={`Pesquisar ${label.toLowerCase()}`}
                className={estiloCampoSelM.inputBusca}
              />
            </div>

            <div className={estiloCampoSelM.listaOpcoes}>
              {opcoesFiltradas.length > 0 ? (
                opcoesFiltradas.map((opcao) => (
                  <label key={opcao} className={estiloCampoSelM.itemOpcao}>
                    <Checkbox
                      checked={selecionadasTemporarias.includes(opcao)}
                      onChange={() => toggleOpcao(opcao)}
                      className={estiloCampoSelM.checkboxCustom}
                      disableRipple
                    />
                    <span>{opcao}</span>
                  </label>
                ))
              ) : (
                <div className={estiloCampoSelM.estadoVazio}>
                  Nenhuma opção encontrada.
                </div>
              )}
            </div>

            <div className={estiloCampoSelM.acoesPainel}>
              <button
                type="button"
                className={estiloCampoSelM.botaoLimpar}
                onClick={limparSelecao}
              >
                Limpar
              </button>

              <button
                type="button"
                className={estiloCampoSelM.botaoAplicar}
                onClick={aplicarSelecao}
              >
                Aplicar
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default CampoSelecaoMultipla;
