import estiloQuest from "./Questoes.module.css";
import PainelBuscaQuestoes from "../components/questoes/PainelBuscaQuestoes";

function Questoes() {
  return (
    <section className={estiloQuest.paginaQuestoes}>
      <header className={estiloQuest.topo}>
        <h1 className={estiloQuest.titulo}>Buscar Questões</h1>
      </header>

      <PainelBuscaQuestoes />
    </section>
  );
}

export default Questoes;