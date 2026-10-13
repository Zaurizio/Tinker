import styles from "./CardDesempenhoPorDisciplina.module.css";

function CardDesempenhoPorDisciplina({ dadosDisciplinas = [] }) {
  return (
    <div className={styles.card}>
      <h3 id="titulo-desempenho-disciplinas" className={styles.titulo}>
        Desempenho por disciplina
      </h3>

      {dadosDisciplinas.length === 0 ? (
        <p className={styles.mensagemVazia}>Nenhuma questão respondida</p>
      ) : (
        <div className={styles.tabelaContainer}>
          <table aria-labelledby="titulo-desempenho-disciplinas">
            <thead>
              <tr>
                <th scope="col">Disciplina</th>
                <th scope="col">Porcentagem de acertos</th>
                <th scope="col">Número de acertos</th>
                <th scope="col">Questões feitas</th>
              </tr>
            </thead>
            <tbody>
              {dadosDisciplinas.map((disciplina) => (
                <tr key={disciplina.id}>
                  <td>{disciplina.nome}</td>
                  <td>{disciplina.porcentagemAcertos}%</td>
                  <td>{disciplina.acertos}</td>
                  <td>{disciplina.questoesFeitas}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default CardDesempenhoPorDisciplina;
