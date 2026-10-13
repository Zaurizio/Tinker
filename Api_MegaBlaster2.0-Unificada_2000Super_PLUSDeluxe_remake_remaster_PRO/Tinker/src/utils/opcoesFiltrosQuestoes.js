function unirConteudos(disciplinas) {
  const vistos = new Set();
  const resultado = [];

  disciplinas.forEach(({ conteudos }) => {
    (conteudos ?? []).forEach((conteudo) => {
      if (!vistos.has(conteudo)) {
        vistos.add(conteudo);
        resultado.push(conteudo);
      }
    });
  });

  return resultado.sort((a, b) => a.localeCompare(b, "pt-BR"));
}

export function obterConteudosDisponiveis(disciplinas, disciplinasSelecionadas) {
  if (!disciplinasSelecionadas || disciplinasSelecionadas.length === 0) {
    return unirConteudos(disciplinas);
  }

  const selecionadas = new Set(disciplinasSelecionadas);
  const relevantes = disciplinas.filter((disciplina) =>
    selecionadas.has(disciplina.nome)
  );

  return unirConteudos(relevantes);
}
