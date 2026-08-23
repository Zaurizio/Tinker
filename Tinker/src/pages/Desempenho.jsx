import { useEffect, useState } from "react";
import CardDesempenhoGeral from "../components/desempenho/CardDesempenhoGeral";
import CardDesempenhoPorDisciplina from "../components/desempenho/CardDesempenhoPorDisciplina";
import CardMateriaDestaque from "../components/desempenho/CardMateriaDestaque";
import CardMetrica from "../components/desempenho/CardMetrica";
import { obterResumoDesempenho } from "../services/desempenhoService";
import styles from "./Desempenho.module.css";

function Desempenho() {
  const [dadosDesempenho, setDadosDesempenho] = useState(null);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");

  useEffect(() => {
    let componenteMontado = true;

    async function carregarDesempenho() {
      setCarregando(true);
      setErro("");

      try {
        const dados = await obterResumoDesempenho();
        if (componenteMontado) setDadosDesempenho(dados);
      } catch {
        if (componenteMontado) {
          setErro("Não foi possível carregar seu desempenho. Tente novamente.");
        }
      } finally {
        if (componenteMontado) setCarregando(false);
      }
    }

    carregarDesempenho();
    return () => {
      componenteMontado = false;
    };
  }, []);

  return (
    <div className={styles.container}>
      <h1 className={styles.tituloPagina}>Meu Desempenho</h1>

      {carregando ? (
        <p className={styles.estado}>Carregando desempenho...</p>
      ) : erro ? (
        <p className={styles.erro} role="alert">{erro}</p>
      ) : !dadosDesempenho ? (
        <p className={styles.estado}>Nenhum dado de desempenho disponível.</p>
      ) : (
        <>
          <div className={styles.gridCards}>
            <div className={styles.cardGeral}>
              <CardDesempenhoGeral
                taxaAcertos={dadosDesempenho.taxaAcertosGeral}
                mensagem={dadosDesempenho.mensagemTaxaGeral}
              />
            </div>

            <div className={styles.cardsMenores}>
              <CardMateriaDestaque
                titulo="Matéria com maior taxa de acerto"
                materia={
                  dadosDesempenho.materiaMaiorAcerto?.nome ??
                  "Nenhuma questão respondida"
                }
                taxa={dadosDesempenho.materiaMaiorAcerto?.taxa ?? null}
                corDestaque="var(--cor-primaria-destaque)"
                corFundoDestaque="var(--cor-primaria-destaque-fundo)"
                corBordaDestaque="var(--cor-primaria-destaque-borda)"
              />
              <CardMateriaDestaque
                titulo="Matéria com menor taxa de acerto"
                materia={
                  dadosDesempenho.materiaMenorAcerto?.nome ??
                  "Nenhuma questão respondida"
                }
                taxa={dadosDesempenho.materiaMenorAcerto?.taxa ?? null}
                corDestaque="var(--cor-desempenho-alerta)"
                corFundoDestaque="var(--cor-desempenho-alerta-fundo)"
                corBordaDestaque="var(--cor-desempenho-alerta-borda)"
              />
              <CardMetrica
                titulo="Questões Respondidas"
                valor={dadosDesempenho.questoesRespondidas}
              />
              <CardMetrica
                titulo="Simulados feitos"
                valor={dadosDesempenho.simuladosFeitos}
              />
            </div>
          </div>

          <div className={styles.cardDisciplina}>
            <CardDesempenhoPorDisciplina
              dadosDisciplinas={dadosDesempenho.disciplinas}
            />
          </div>
        </>
      )}
    </div>
  );
}

export default Desempenho;
