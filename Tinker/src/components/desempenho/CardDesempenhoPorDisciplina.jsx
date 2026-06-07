// CardDesempenhoPorDisciplina.jsx
import React from 'react';

import styles from './CardDesempenhoPorDisciplina.module.css';

const CardDesempenhoPorDisciplina = ({ dadosDisciplinas = [] }) => {
  const nenhumaQuestaoRespondida = dadosDisciplinas.length === 0;

  return (
    <div className={styles.card}>
      <h3 className={styles.titulo}>Desempenho por disciplina</h3>
      {nenhumaQuestaoRespondida ? (
        <p className={styles.mensagemVazia}>Nenhuma questão foi respondida ainda.</p>
      ) : (
        <div className={styles.tabelaContainer}>
          {/* Aqui você pode renderizar uma tabela com os dados das disciplinas */}
          {/* Exemplo de estrutura de tabela: */}
          <table>
            <thead>
              <tr>
                <th>Disciplina</th>
                <th>Acertos</th>
                <th>Erros</th>
                <th>Total</th>
                <th>Taxa de Acerto</th>
              </tr>
            </thead>
            <tbody>
              {dadosDisciplinas.map((disciplina, index) => (
                <tr key={index}>
                  <td>{disciplina.nome}</td>
                  <td>{disciplina.acertos}</td>
                  <td>{disciplina.erros}</td>
                  <td>{disciplina.total}</td>
                  <td>{disciplina.taxaAcerto}%</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default CardDesempenhoPorDisciplina;