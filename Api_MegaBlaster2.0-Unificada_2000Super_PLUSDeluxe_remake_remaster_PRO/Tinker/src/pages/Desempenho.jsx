import { useEffect, useState } from "react";
import CardDesempenhoGeral from "../components/desempenho/CardDesempenhoGeral";
import CardDesempenhoPorDisciplina from "../components/desempenho/CardDesempenhoPorDisciplina";
import CardMateriaDestaque from "../components/desempenho/CardMateriaDestaque";
import CardMetrica from "../components/desempenho/CardMetrica";
import Skeleton from "../components/ui/Skeleton";
import { obterResumoDesempenho } from "../services/desempenhoService";
import { obterCache, definirCache } from "../services/cacheStore";
import { CHAVE_DESEMPENHO } from "../services/cacheChaves";
import { useEsqueletoAtrasado } from "../hooks/useEsqueletoAtrasado";
import styles from "./Desempenho.module.css";
import estiloGeral from "../components/desempenho/CardDesempenhoGeral.module.css";
import estiloMateria from "../components/desempenho/CardMateriaDestaque.module.css";
import estiloMetrica from "../components/desempenho/CardMetrica.module.css";
import estiloDisciplina from "../components/desempenho/CardDesempenhoPorDisciplina.module.css";

function DesempenhoSkeleton() {
  return (
    <>
      <div className={styles.gridCards}>
        <div className={styles.cardGeral}>
          <div className={estiloGeral.card} style={{ width: "100%" }} aria-hidden="true">
            <Skeleton height="1.5rem" width="65%" style={{ marginBottom: 7 }} />
            <div className={estiloGeral.graficoContainer}>
              <Skeleton width="120px" height="120px" radius="50%" />
            </div>
            <Skeleton height="1.2rem" width="80%" />
          </div>
        </div>

        <div className={styles.cardsMenores}>
          {[0, 1].map((indice) => (
            <div className={estiloMateria.card} key={`materia-${indice}`} aria-hidden="true">
              <Skeleton height="1.5rem" width="80%" style={{ marginBottom: 10 }} />
              <Skeleton height="2.4rem" width="65%" radius="12px" />
            </div>
          ))}
          {[0, 1].map((indice) => (
            <div className={estiloMetrica.card} key={`metrica-${indice}`} aria-hidden="true">
              <Skeleton height="1.1rem" width="70%" style={{ marginBottom: 8 }} />
              <Skeleton height="1.8rem" width="40%" />
            </div>
          ))}
        </div>
      </div>

      <div className={styles.cardDisciplina}>
        <div className={estiloDisciplina.card} aria-hidden="true">
          <Skeleton height="1.2em" width="240px" style={{ margin: "0 auto 15px" }} />
          <div style={{ display: "flex", flexDirection: "column", gap: 10, marginTop: 15 }}>
            <Skeleton height="1rem" width="100%" />
            <Skeleton height="1rem" width="100%" />
            <Skeleton height="1rem" width="100%" />
          </div>
        </div>
      </div>
    </>
  );
}

function Desempenho() {
  const [dadosDesempenho, setDadosDesempenho] = useState(
    () => obterCache(CHAVE_DESEMPENHO) ?? null,
  );
  const [carregando, setCarregando] = useState(
    () => obterCache(CHAVE_DESEMPENHO) === undefined,
  );
  const [erro, setErro] = useState("");
  const mostrarEsqueleto = useEsqueletoAtrasado(carregando);

  useEffect(() => {
    let componenteMontado = true;

    async function carregarDesempenho() {
      const emCache = obterCache(CHAVE_DESEMPENHO);
      setCarregando(emCache === undefined);
      setErro("");

      try {
        const dados = await obterResumoDesempenho();
        if (componenteMontado) {
          setDadosDesempenho(dados);
          definirCache(CHAVE_DESEMPENHO, dados);
        }
      } catch {
        if (componenteMontado && emCache === undefined) {
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
        mostrarEsqueleto ? <DesempenhoSkeleton /> : null
      ) : erro ? (
        <p className={styles.erro} role="alert">{erro}</p>
      ) : !dadosDesempenho ? (
        <p className={styles.estado}>Nenhum dado de desempenho disponível.</p>
      ) : !dadosDesempenho.possuiRespostas ? (
        <p className={styles.estado}>Você ainda não respondeu nenhuma questão.</p>
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
                titulo="Simulados Concluídos"
                valor={dadosDesempenho.simuladosConcluidos}
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
