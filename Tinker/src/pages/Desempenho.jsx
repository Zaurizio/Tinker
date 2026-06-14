// Desempenho.jsx
import React from 'react';
import CardDesempenhoGeral from '../components/desempenho/CardDesempenhoGeral';
import CardMateriaDestaque from '../components/desempenho/CardMateriaDestaque';
import CardDesempenhoPorDisciplina from '../components/desempenho/CardDesempenhoPorDisciplina';
import styles from './Desempenho.module.css';
import CardMetrica from '../components/desempenho/CardMetrica';

const Desempenho = () => {
  // Dados de exemplo. No futuro, estes virão de um estado ou de uma API.
  const dadosDesempenho = {
    taxaAcertosGeral: 67,
    materiaMaiorAcerto: { nome: 'Matemática', taxa: 88 },
    materiaMenorAcerto: { nome: 'Português', taxa: 62 },
    questoesRespondidas: 1250,
    simuladosFeitos: 15,
    disciplinas: [
      // Exemplo de dados para a tabela, se houver questões respondidas
      // { nome: 'Matemática', acertos: 150, erros: 20, total: 170, taxaAcerto: 88 },
      // { nome: 'Português', acertos: 100, erros: 60, total: 160, taxaAcerto: 62 },
    ],
  };

  return (
    <div className={styles.container}>
      <h1 className={styles.tituloPagina}>Meu Desempenho</h1>

      <div className={styles.gridCards}>
        <div className={styles.cardGeral}>
          <CardDesempenhoGeral taxaAcertos={dadosDesempenho.taxaAcertosGeral} />
        </div>

        <div className={styles.cardsMenores}>
          <CardMateriaDestaque
            titulo="Matéria com maior taxa de acerto"
            materia={dadosDesempenho.materiaMaiorAcerto.nome}
            taxa={dadosDesempenho.materiaMaiorAcerto.taxa}
            corDestaque="var(--cor-primaria-destaque)"
            corFundoDestaque="var(--cor-primaria-destaque-fundo)"
            corBordaDestaque="var(--cor-primaria-destaque-borda)"
          />
          <CardMateriaDestaque
            titulo="Matéria com menor taxa de acerto"
            materia={dadosDesempenho.materiaMenorAcerto.nome}
            taxa={dadosDesempenho.materiaMenorAcerto.taxa}
            corDestaque="var(--cor-desempenho-alerta)"
            corFundoDestaque="var(--cor-desempenho-alerta-fundo)"
            corBordaDestaque="var(--cor-desempenho-alerta-borda)"
          />
          {/* Card para Número de questões respondidas */}
          <CardMetrica
            titulo="Questões Respondidas"
            valor="127"
          />
          <CardMetrica
            titulo="Simulados feitos"
            valor="4"
          />
        </div>
      </div>

      <div className={styles.cardDisciplina}>
        <CardDesempenhoPorDisciplina dadosDisciplinas={dadosDesempenho.disciplinas} />
      </div>
    </div>
  );
};

export default Desempenho;
