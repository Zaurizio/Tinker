# Especificação da API e do banco — Tinker

## 1. Objetivo e fontes

Este documento consolida as regras atuais do Tinker, o estado real do banco e a menor estrutura final recomendada para API, banco e integração web.

- `schema.sql` é referência histórica.
- `schema-atual.sql` é o dump mais recente, mas ainda não é o schema final.
- **Atual** significa que a estrutura já aparece no dump recente.
- **Obrigatória** significa que uma migration futura será necessária.
- **API** significa que a garantia pode permanecer na aplicação enquanto ela for o único escritor.
- **Adiável** significa melhoria não bloqueante para a primeira integração.
- Este documento não executa SQL nem cria migrations.

## 2. Regras confirmadas

### 2.1 Contas, cadastro e login

- `Aluno` e `Professor` continuam como tabelas separadas; não será criada uma tabela central `Usuario`.
- Cadastro público exige `tipoUsuario` e aceita `ALUNO` ou `PROFESSOR`.
- O mesmo e-mail pode existir uma vez em `Aluno` e uma vez em `Professor`.
- Não existe unicidade global entre tipos. Repetição dentro da mesma tabela continua proibida.
- Login exige `email`, `senha` e `tipoUsuario`; a API consulta somente a tabela do tipo escolhido.
- JWT e principal autenticado identificam a conta por `email + tipoUsuario`.
- Senhas de aluno e professor usam BCrypt. Nenhuma resposta, DTO ou log expõe senha ou hash.
- Conta com `ativo = 0` não autentica.
- A regra de criação de professor somente por administrador está revogada.
- `Administrador` permanece separado apenas nas funções administrativas ainda necessárias e não recebe automaticamente administração de turmas.
- Somente conta `PROFESSOR` cria turma ou publica/despublica simulados.

### 2.2 Questões avulsas

- Aluno ou professor ativo responde diretamente uma questão uma única vez.
- A identidade da resposta é `email + tipoUsuario + questão`.
- A resposta avulsa é definitiva, bloqueia nova resposta no mesmo contexto e entra no desempenho.
- A API recebe a alternativa, consulta o gabarito e calcula o resultado. O cliente não envia `acertou` confiável.
- Resposta avulsa não se confunde com marcação temporária em simulado.

### 2.3 Resolução de simulados

- Marcar uma alternativa produz correção imediata para o usuário.
- Enquanto faltar qualquer questão, respostas, acertos e erros são temporários e não são persistidos.
- A correção temporária não cria relatório, tentativa ou progresso.
- Sair antes da conclusão descarta propositalmente o estado. Ao voltar, tudo aparece desmarcado e zerado.
- Somente depois de marcar todas as questões o frontend envia a resolução completa.
- O payload contém as alternativas escolhidas, não acertos, erros ou totais confiáveis.
- A API revalida acesso, questões, completude e alternativas; recalcula respostas e totais.
- Cada conta possui somente um resultado definitivo por simulado: sempre a conclusão mais recente.
- Na primeira conclusão, resultado, respostas e totais são criados em uma única transação.
- Ao concluir novamente, a API substitui cabeçalho e respostas anteriores na mesma transação. Se qualquer etapa falhar, rollback preserva integralmente o resultado anterior.
- Resoluções abandonadas não entram no desempenho e não alteram o resultado definitivo anterior.
- Simulado sem conclusão exibe somente quantidade de questões e estado não concluído.
- Simulado concluído exibe `Completo`, total, acertos e botão `Recomeçar`.
- `Recomeçar` inicia resolução local desmarcada e zerada; não reaproveita respostas anteriores.

### 2.4 Recomeçar — decisão definitiva

- Não haverá histórico de várias tentativas.
- O resultado definitivo é sempre a conclusão mais recente.
- Ao clicar em `Recomeçar`, alternativas e contadores ficam somente no frontend.
- Enquanto a nova resolução estiver incompleta, o resultado anterior permanece salvo e continua alimentando card e desempenho.
- Sair antes de concluir descarta apenas a resolução temporária.
- A nova conclusão substitui atomicamente o cabeçalho e todas as respostas anteriores.
- Card e desempenho consultam somente esse resultado definitivo atual.

### 2.5 Turmas

- Somente professor ativo cria turma.
- Apenas o professor criador administra membros e publica/despublica simulados.
- Alunos e professores participam como membros.
- Professor visitante é membro comum.
- O código público possui exatamente oito dígitos, é texto e preserva zeros à esquerda, por exemplo `00182745`.
- A API gera o código, verifica colisão no banco e tenta novamente.
- Turma possui somente membros e simulados publicados.
- Não existe publicação, salvamento, cópia ou associação de evento com turma.
- Membro não resolve diretamente o simulado original publicado. O card oferece `Adicionar a meus simulados`.
- Ao adicionar, a API cria um `Simulado` pessoal, copia suas associações `Quest_Simu` e registra o salvamento na mesma transação.
- A cópia é independente: alterações, exclusão ou despublicação do original não a modificam.
- Cada conta salva uma publicação uma vez enquanto a cópia existir. Excluir a cópia remove o controle e permite salvar novamente se a publicação continuar ativa.

### 2.6 Calendário pessoal

- Aluno e professor possuem calendários independentes, identificados por `email + tipoUsuario`.
- Eventos não possuem relação com turma.
- Título e data são obrigatórios; cor usa `#RRGGBB`.
- Dia inteiro exige horários nulos; evento com horário exige início e fim, com fim posterior ao início.
- Criação no passado permanece proibida; ocorrências já passadas podem continuar armazenadas.
- Recorrência: `NAO_REPETE`, `DIARIA`, `SEMANAL`, `MENSAL` ou `ANUAL`.
- Limites por criação, incluindo a primeira ocorrência: 365 diárias, 52 semanais, 12 mensais ou 5 anuais.
- É possível remover uma ocorrência ou uma série, sempre conferindo o dono autenticado.

## 3. Estado real do banco atualizado

### 3.1 Mudanças em relação ao schema histórico

| Estrutura | Histórico | Dump atual |
|---|---|---|
| `Aluno.senha` | `varchar(20)` | `varchar(100)` |
| `Professor.senha` | `varchar(20)` | `varchar(100)` |
| `HorarioMult` | sem título, dia inteiro e cor | adiciona `titulo varchar(45) NOT NULL`, `dia_inteiro tinyint NULL`, `cor varchar(45) NULL` |
| resposta de questão | `Relatorio` | substituição nominal por `Relatorio_Questao`, mantendo as três colunas antigas |
| resultado de simulado | inexistente | nova `Relatorio_Simulado` |
| `Turma.cod_turma` | `int AUTO_INCREMENT` | `varchar(8)` sem geração automática |
| PK de `Turma` | (`cod_turma`,`nome_turma`,`email_prof`) | somente (`cod_turma`) |
| publicação de simulado | inexistente | nova `Turma_Simulado` |

As demais tabelas do dump histórico permanecem estruturalmente iguais.

### 3.2 Avaliação das estruturas atuais

| Tabela | Aproveitamento | Problema conhecido |
|---|---|---|
| `Aluno`, `Professor` | contas separadas e senhas ampliadas | e-mail ainda limitado a 50; regras ficam na API |
| `Administrador` | conta administrativa legada | `login varchar(10)` e `senha int NULL` não atendem hash moderno |
| `Questao` | catálogo e gabarito | `resposta mediumtext`; faltam checks A–E |
| `Simulado` | definição de simulado | ownership sem check; `conclusao` mistura definição com resultado; `tempo float` |
| `Quest_Simu` | associação das questões | sem FKs explícitas |
| `Relatorio_Questao` | ponto de partida para resposta avulsa | não diferencia tipo nem guarda alternativa |
| `Relatorio_Simulado` | agregado provisório | não aceita professor nem possui respostas detalhadas; sua unicidade atual não inclui o tipo |
| `Turma` | código textual e PK simples | não garante oito dígitos nem FK do criador |
| `Aluno_Turma` | vínculo legado de aluno | `cod_turma int` incompatível; não aceita professor |
| `Turma_Simulado` | publicação básica | tipos frágeis, sem FKs/unique, data textual e sem controle de salvamento |
| `HorarioMult` | candidato a evento pessoal | PK/horários inadequados; sem tipo, série ou recorrência |
| `Cronograma` | agendamento simples por data | sobrepõe calendário e também não diferencia tipo |
| `Conteudo_Quest`, `Estudio_*` | legado fora do contrato | uso deve ser auditado antes de remoção |

### 3.3 Bloqueios atuais

- `Aluno_Turma.cod_turma int` é incompatível com `Turma.cod_turma varchar(8)`.
- `Aluno_Turma` não representa professor membro.
- `varchar(8)` limita o máximo, mas não garante exatamente oito dígitos.
- `Relatorio_Questao` colide aluno e professor homônimos e não registra alternativa.
- `Relatorio_Simulado` já limita uma linha por simulado/aluno, coerente com resultado único, mas não aceita professor, não inclui o tipo na chave e não possui respostas detalhadas.
- `HorarioMult` e `Cronograma` colidem contas de tipos distintos com o mesmo e-mail.
- `Turma_Simulado.id_publicacao` é texto, `data_publicacao` é texto, `ativo` aceita nulo e faltam FKs e `UNIQUE(cod_turma,cod_simulado)`.
- E-mails variam entre 45 e 50 caracteres nos vínculos.
- Faltam FKs centrais.
- Entidades JPA e repositories ainda refletem o schema histórico.

## 4. Estrutura mínima final recomendada

### 4.1 Contas

Manter `Aluno` e `Professor` separadas:

| Coluna | Alvo mínimo |
|---|---|
| `email` | `varchar(254) NOT NULL`, PK/unique dentro da própria tabela |
| `senha` | `varchar(100) NOT NULL` |
| `nome`, `sobrenome` | obrigatórios |
| `nascimento` | obrigatório somente para aluno enquanto o schema exigir |
| `foto` | opcional |
| `ativo` | `tinyint(1) NOT NULL DEFAULT 1` |

Não criar índice, trigger ou validação de unicidade entre as duas tabelas. `Administrador` pode permanecer separado; antes de autenticação administrativa real, precisa de identificador compatível com e-mail e senha textual para hash.

### 4.2 Respostas avulsas

Remodelar `Relatorio_Questao` como registro definitivo exclusivamente avulso:

| Coluna | Alvo mínimo |
|---|---|
| `id_resposta` | `bigint AUTO_INCREMENT`, PK |
| `email_usuario` | `varchar(254) NOT NULL` |
| `tipo_usuario` | `enum('ALUNO','PROFESSOR') NOT NULL` |
| `cod_quest` | `int NOT NULL`, FK para `Questao` |
| `alternativa_selecionada` | `char(1) NOT NULL`, A–E |
| `acertou` | `tinyint(1) NOT NULL` |
| `respondida_em` | data/hora obrigatória |

Obrigatório: `UNIQUE(email_usuario,tipo_usuario,cod_quest)`. Não gravar aqui respostas de simulado.

### 4.3 Resultado definitivo do simulado

Remodelar `Relatorio_Simulado` como o único resultado concluído atual da conta naquele simulado:

| Coluna | Alvo mínimo |
|---|---|
| `cod_simulado` | `int NOT NULL`, FK para `Simulado` |
| `email_usuario` | `varchar(254) NOT NULL` |
| `tipo_usuario` | `enum('ALUNO','PROFESSOR') NOT NULL` |
| `total_questoes` | `int NOT NULL` positivo |
| `acertos`, `erros` | `int NOT NULL` não negativos |
| `concluida_em` | data/hora obrigatória |
| `tempo_segundos` | opcional e não negativo, se a duração for mantida |

PK recomendada: (`email_usuario`,`tipo_usuario`,`cod_simulado`). Ela garante exatamente um resultado definitivo por conta/simulado. Check: `acertos + erros = total_questoes`. A existência da linha significa conclusão; não existe resultado parcial.

### 4.4 Respostas do resultado atual

Criar `Resposta_Simulado`, representando somente as respostas do resultado definitivo atual:

| Coluna | Alvo mínimo |
|---|---|
| `email_usuario` | parte da PK/FK composta do resultado |
| `tipo_usuario` | parte da PK/FK composta do resultado |
| `cod_simulado` | parte da PK/FK composta do resultado |
| `cod_quest` | FK para `Questao`, parte da PK |
| `alternativa_selecionada` | `char(1) NOT NULL`, A–E |
| `acertou` | `tinyint(1) NOT NULL` |

PK (`email_usuario`,`tipo_usuario`,`cod_simulado`,`cod_quest`) e FK composta para `Relatorio_Simulado`. Na primeira conclusão, cabeçalho e respostas são inseridos juntos. Na reconclusão, a API bloqueia/localiza o resultado atual e substitui cabeçalho e conjunto de respostas dentro de uma única transação; rollback mantém o conjunto anterior intacto.

### 4.5 Turma e membros

`Turma`:

| Coluna | Alvo mínimo |
|---|---|
| `cod_turma` | `char(8) NOT NULL`, PK, check `^[0-9]{8}$` |
| `nome_turma` | `varchar(45) NOT NULL` inicialmente |
| `email_prof` | `varchar(254) NOT NULL`, FK para `Professor` |
| `ativo` | `tinyint(1) NOT NULL DEFAULT 1` |

O próprio código é a identidade da turma; não é necessário adicionar ID numérico interno.

Substituir `Aluno_Turma` por `Turma_Membro`:

| Coluna | Alvo mínimo |
|---|---|
| `cod_turma` | `char(8) NOT NULL`, FK |
| `email_membro` | `varchar(254) NOT NULL` |
| `tipo_usuario` | `enum('ALUNO','PROFESSOR') NOT NULL` |
| `papel` | `enum('CRIADOR','MEMBRO') NOT NULL DEFAULT 'MEMBRO'` |
| `ativo` | `tinyint(1) NOT NULL DEFAULT 1` |
| `entrou_em` | data/hora opcional |

PK (`cod_turma`,`email_membro`,`tipo_usuario`). Turma e associação `CRIADOR` são criadas na mesma transação.

### 4.6 Publicação de simulados

Corrigir `Turma_Simulado`:

| Coluna | Alvo mínimo |
|---|---|
| `id_publicacao` | `bigint AUTO_INCREMENT`, PK |
| `cod_turma` | `char(8) NOT NULL`, FK |
| `cod_simulado` | `int NOT NULL`, FK |
| `data_publicacao` | `datetime NOT NULL` |
| `ativo` | `tinyint(1) NOT NULL DEFAULT 1` |

Obrigatório: `UNIQUE(cod_turma,cod_simulado)`. Republicar reativa a linha. Título ou texto nunca são usados como identidade.

Criar `Simulado_Salvo` como controle da cópia pessoal:

| Coluna | Alvo mínimo |
|---|---|
| `id_publicacao` | FK para `Turma_Simulado`, parte da PK |
| `email_usuario` | `varchar(254) NOT NULL`, parte da PK |
| `tipo_usuario` | `enum('ALUNO','PROFESSOR') NOT NULL`, parte da PK |
| `cod_simulado_pessoal` | `int NOT NULL`, FK e `UNIQUE` para a cópia criada |
| `data_salvamento` | `datetime NOT NULL` |

PK (`id_publicacao`,`email_usuario`,`tipo_usuario`) impede salvar a mesma publicação novamente enquanto a cópia existir. A transação de salvamento cria o novo `Simulado` com dono correspondente, copia todas as linhas de `Quest_Simu` e então cria `Simulado_Salvo`; falha em qualquer etapa desfaz tudo. Excluir a cópia pessoal remove também o controle na mesma transação. O original e a cópia não mantêm propagação de alterações.

Não criar `Turma_Evento`, `Evento_Salvo` ou qualquer associação/cópia de evento.

### 4.7 Calendário pessoal

`HorarioMult` e `Cronograma` se sobrepõem: ambas guardam itens por data/e-mail, mas apenas `HorarioMult` recebeu parte dos campos visuais. Não devem permanecer como duas fontes gerais do mesmo calendário.

Recomendação mínima: evoluir `HorarioMult` para evento pessoal, com possível renomeação futura para `Evento`, e manter `Cronograma` como legado até confirmar se possui uso exclusivo para agendamento de simulado. Não removê-lo sem auditoria de uso/dados.

| Coluna do evento pessoal | Alvo mínimo |
|---|---|
| `id_evento` | `bigint AUTO_INCREMENT`, PK |
| `email_usuario` | `varchar(254) NOT NULL` |
| `tipo_usuario` | `enum('ALUNO','PROFESSOR') NOT NULL` |
| `titulo` | `varchar(150) NOT NULL` |
| `data` | `date NOT NULL` |
| `horario_inicio`, `horario_fim` | `time NULL` |
| `dia_inteiro` | `tinyint(1) NOT NULL DEFAULT 0` |
| `cor` | `char(7) NOT NULL` |
| `id_serie` | `char(36) NULL` |
| `recorrencia` | enum dos cinco valores confirmados |
| `ativo` | `tinyint(1) NOT NULL DEFAULT 1` |

Uma ocorrência é uma linha; séries compartilham `id_serie`. Não é necessária `Evento_Serie`. Não existe `cod_turma` nem origem publicada.

## 5. Mudanças obrigatórias no banco

1. Uniformizar e-mails em até 254 caracteres sem unicidade global.
2. Preservar capacidade BCrypt e adequar `Administrador` antes de autenticação moderna.
3. Garantir oito dígitos em `Turma` e criar FK do professor criador.
4. Substituir `Aluno_Turma` por membership tipado.
5. Remodelar `Relatorio_Questao` para resposta avulsa tipada.
6. Remodelar `Relatorio_Simulado` como resultado definitivo único e criar `Resposta_Simulado`.
7. Corrigir `Turma_Simulado` e criar `Simulado_Salvo` com as constraints de publicação, conta e cópia.
8. Corrigir o calendário para dono tipado, PK própria, tipos de horário, recorrência e remoção lógica.
9. Decidir o papel residual de `Cronograma` depois de auditoria, sem mantê-lo como segunda fonte geral.
10. Criar índices de consulta por dono, turma, simulado, tentativa, data e ativo.

## 6. Validações que podem permanecer na API

- Normalização e formato de e-mail.
- Seleção do repository pelo `tipoUsuario`.
- BCrypt, JWT e ocultação de dados sensíveis/gabarito.
- Existência de usuário em relações polimórficas por e-mail/tipo.
- Geração segura do código e repetição em colisão; banco garante formato e unicidade.
- Somente professor cria turma e somente criador administra/publica.
- Professor visitante permanece membro.
- Ownership e estado de questão/simulado/turma.
- Correção temporária sem chamar repositories de relatório.
- Completude, ausência de duplicatas, cálculo dos resultados e substituição atômica do resultado atual.
- Cópia transacional do simulado publicado, de `Quest_Simu` e do controle `Simulado_Salvo`.
- Limites de recorrência e validações de data, hora e cor.

## 7. Alterações opcionais ou adiáveis

- `Administrador.ativo` e ampliação do perfil administrativo.
- Padronizar indicadores `ativo` como boolean/check.
- Ampliar nomes de turma/simulado se o produto exigir.
- Imagem/cor de turma e `Simulado.data_criacao`/exclusão lógica.
- Metadados adicionais do resultado concluído.
- Triggers de integridade polimórfica se surgirem escritores externos.
- Remoção de `Estudio_*`, `Conteudo_Quest` e `Cronograma` somente após auditoria própria.

## 8. Entidades e repositories esperados

### Divergências JPA atuais

- `Turma.codTurma` e `TurmaRepository` usam `Integer`/`IDENTITY`; o dump usa texto não autogerado.
- `AlunoTurma` e seu ID composto ainda usam código inteiro.
- `Relatorio` aponta para a tabela inexistente `Relatorio`, não `Relatorio_Questao`.
- Faltam entidades/repositories para `Relatorio_Simulado`, suas respostas, `Turma_Simulado` e o controle de salvamento.
- `HorarioMult` não mapeia `titulo`, `dia_inteiro` e `cor`.
- Login consulta somente aluno, não recebe tipo e compara senha em texto.
- Controllers CRUD expõem entities e não aplicam a matriz final de autorização.

### Alvo da API

- Entidades: `Aluno`, `Professor`, `Adm` se mantido, `Questao`, `Simulado`, `QuestaoSimu`, `RespostaAvulsa`, `ResultadoSimulado`, `RespostaSimulado`, `Turma`, `TurmaMembro`, `TurmaSimulado`, `SimuladoSalvo` e `Evento` pessoal.
- `TurmaRepository<Turma,String>`.
- Repositories de conta por e-mail dentro do próprio tipo.
- Repositories de resposta avulsa, resultado/respostas atuais, membro, publicação, salvamento e evento com consultas por conta tipada/ownership.

Não criar entidades apenas para cristalizar os formatos insuficientes atuais de `Relatorio_Simulado` e `Aluno_Turma`; esses mapeamentos finais dependem das migrations.

## 9. DTOs finais esperados

```text
LoginRequestDTO { email, senha, tipoUsuario: "ALUNO"|"PROFESSOR" }
AuthResponseDTO {
  token, tipo: "Bearer", expiraEm,
  usuario: { email, nome, sobrenome, tipoUsuario }
}
CadastroUsuarioRequestDTO {
  nome, sobrenome, email, senha, tipoUsuario,
  nascimento? // obrigatório para ALUNO enquanto o schema exigir
}
UsuarioResumoDTO { email, nome, sobrenome, tipoUsuario }
UsuarioPerfilDTO { email, nome, sobrenome, nascimento?, fotoUrl?, tipoUsuario, ativo }
AtualizarPerfilDTO { nome, sobrenome, nascimento?, foto? }
AlterarSenhaDTO { senhaAtual, novaSenha }

QuestaoDTO {
  id, vestibular, instituicao?, ano, fase?, disciplina, conteudo,
  enunciado, imagemUrl?, alternativas: [{ id: "A"|...|"E", texto }],
  respondidaAvulsa?, alternativaSelecionadaAvulsaId?
}
PaginaQuestaoDTO { itens, temMais, total, pagina, tamanho }
RespostaAvulsaRequestDTO { alternativaSelecionadaId }
RespostaResultadoDTO {
  questaoId, alternativaSelecionadaId, alternativaCorretaId, correta, bloqueada
}
CorrecaoTemporariaRequestDTO { questaoId, alternativaSelecionadaId }
CorrecaoTemporariaDTO {
  questaoId, alternativaSelecionadaId, correta, persistida: false
}

CriarSimuladoDTO { titulo, descricao?, tempoMinutos? }
GerarSimuladoDTO { titulo, descricao?, tempoMinutos?, filtros, quantidadeQuestoes }
QuestaoIdsDTO { questoesIds: [integer] }
SimuladoResumoDTO {
  id, titulo, descricao?, dataCriacao?, quantidadeQuestoes,
  status: "nao_concluido"|"completo",
  resultadoDefinitivo?: { acertos, erros, totalQuestoes, concluidaEm }
}
SimuladoDetalheDTO { ...SimuladoResumoDTO, tempoMinutos?, questoes }
ConcluirSimuladoDTO {
  respostas: [{ questaoId, alternativaSelecionadaId }]
}
ResultadoSimuladoDTO {
  simuladoId, totalQuestoes, acertos, erros, concluidaEm,
  respostas: [{ questaoId, alternativaSelecionadaId, alternativaCorretaId, correta }]
}

CriarTurmaDTO { nome }
EntrarTurmaDTO { codigo }
TurmaResumoDTO { codigo, nome, criador, quantidadeMembros, imagem?, cor? }
TurmaDetalheDTO { ...TurmaResumoDTO, papelUsuario: "CRIADOR"|"MEMBRO" }
MembroTurmaDTO { email, nome, tipoUsuario, papel, fotoPerfil?, ativo }
PublicarSimuladoDTO { simuladoId }
PublicacaoSimuladoDTO {
  idPublicacao, simuladoId, titulo, dataPublicacao, quantidadeQuestoes,
  ativo, salvoPeloUsuario
}
SalvarSimuladoDTO { sucesso, simuladoPessoalId, jaAdicionado }

CriarEventoDTO {
  titulo, data, horarioInicio?, horarioFim?, diaInteiro, cor,
  recorrencia: "NAO_REPETE"|"DIARIA"|"SEMANAL"|"MENSAL"|"ANUAL"
}
EventoCalendarioDTO {
  id, title, start, end?, allDay, color,
  extendedProps: { serieId?, recorrencia, data, horarioInicio?, horarioFim? }
}

DesempenhoResumoDTO {
  taxaAcertosGeral, questoesRespondidas,
  questoesAvulsasRespondidas, questoesEmSimuladosConcluidos,
  simuladosConcluidos,
  disciplinas: [{ nome, porcentagemAcertos, acertos, questoesFeitas, possuiRespostas }]
}
ErroDTO { codigo, mensagem, campos? }
```

`QuestaoDTO` não expõe gabarito. A correção temporária informa apenas `correta`; `alternativaCorretaId` e o gabarito completo aparecem somente após resposta avulsa definitiva ou conclusão definitiva do simulado. Não existem DTOs de evento em turma.

## 10. Endpoints necessários

### Autenticação e perfil

| Rota | Acesso | Função |
|---|---|---|
| `POST /api/auth/cadastros` | público | cria aluno ou professor conforme tipo |
| `POST /api/auth/login` | público | autentica somente no tipo informado |
| `GET /api/me` | aluno/professor | perfil próprio |
| `PUT /api/me` | aluno/professor | atualiza perfil próprio |
| `PUT /api/me/senha` | aluno/professor | troca senha |
| `DELETE /api/me` | aluno/professor | inativa conta |

### Questões e desempenho

| Rota | Acesso | Função |
|---|---|---|
| `GET /api/questoes` | autenticado | filtros/paginação sem gabarito |
| `GET /api/questoes/{id}` | autenticado | detalhe sem gabarito |
| `POST /api/questoes/{id}/resposta` | aluno/professor | resposta avulsa definitiva |
| `GET /api/me/desempenho` | aluno/professor | agrega somente dados definitivos |

### Simulados e resultado definitivo

| Rota | Acesso | Função |
|---|---|---|
| `GET /api/simulados` | aluno/professor | lista acessíveis |
| `POST /api/simulados` | aluno/professor | cria pessoal |
| `POST /api/simulados/gerar` | aluno/professor | gera por filtros |
| `GET /api/simulados/{id}` | dono da instância pessoal | detalhe; durante recomeço, resultado anterior continua apenas como resumo definitivo |
| `PATCH /api/simulados/{id}` | dono | altera campos permitidos |
| `DELETE /api/simulados/{id}` | dono | exclui conforme política |
| `POST /api/simulados/{id}/correcoes` | usuário com acesso | corrige temporariamente sem escrita |
| `PUT /api/simulados/{id}/resultado` | dono da instância pessoal | cria o resultado se ausente ou substitui cabeçalho/respostas atomicamente |
| `GET /api/simulados/{id}/resultado` | dono da instância pessoal | retorna somente o resultado definitivo atual |

Não existe endpoint para salvar progresso parcial nem listar resultados anteriores. `Recomeçar` limpa o estado local; a nova conclusão usa `PUT .../resultado`. O simulado original publicado não pode ser resolvido diretamente: primeiro deve ser copiado para a conta do membro.

### Turmas

| Rota | Acesso | Função |
|---|---|---|
| `GET /api/turmas` | autenticado | lista associações da conta tipada |
| `POST /api/turmas` | professor | cria turma e membro criador |
| `POST /api/turmas/entradas` | aluno/professor | entra pelo código de oito dígitos |
| `GET /api/turmas/{codigo}` | membro | detalhe/papel |
| `DELETE /api/turmas/{codigo}` | criador | inativa turma |
| `GET /api/turmas/{codigo}/membros` | membro | lista membros |
| `DELETE /api/turmas/{codigo}/membros/me` | membro comum | sai |
| `DELETE /api/turmas/{codigo}/membros/{tipo}/{email}` | criador | remove membro |
| `GET /api/turmas/{codigo}/simulados` | membro | lista publicações |
| `POST /api/turmas/{codigo}/simulados` | criador | publica simulado |
| `DELETE /api/turmas/{codigo}/simulados/{publicacaoId}` | criador | despublica |
| `POST /api/publicacoes-simulado/{publicacaoId}/salvamentos` | membro | cria cópia pessoal, copia questões e registra controle atomicamente |

Não existem endpoints de evento em turma.

### Calendário pessoal

| Rota | Acesso | Função |
|---|---|---|
| `GET /api/eventos?inicio=&fim=` | aluno/professor | lista eventos pessoais ativos |
| `POST /api/eventos` | aluno/professor | cria ocorrência/série |
| `GET /api/eventos/{id}` | dono | detalhe |
| `DELETE /api/eventos/{id}` | dono | remove ocorrência |
| `DELETE /api/eventos/series/{idSerie}` | dono | remove série |

## 11. Matriz de permissões

| Operação | Aluno | Professor membro | Professor criador | Administrador |
|---|---:|---:|---:|---:|
| Cadastro público | sim | sim | sim | não se aplica |
| Responder questão/simulado | sim | sim | sim | não |
| Criar simulado pessoal | sim | sim | sim | não |
| Criar turma | não | sim | sim | não automaticamente |
| Entrar em turma | sim | sim | já é criador | não automaticamente |
| Ver membros/publicações | sim | sim | sim | não automaticamente |
| Administrar membros | não | não | sim | não automaticamente |
| Publicar/despublicar simulado | não | não | sim | não automaticamente |
| Adicionar publicação aos próprios simulados | sim | sim | sim | não automaticamente |
| Gerir calendário pessoal | sim | sim | sim | não |
| Publicar evento em turma | não existe | não existe | não existe | não existe |

## 12. Validações essenciais

### Contas

- Tipo obrigatório e limitado a aluno/professor no cadastro/login.
- E-mail normalizado, válido e com até 254 caracteres.
- Duplicidade verificada somente na tabela escolhida.
- Nascimento obrigatório para aluno enquanto `Aluno.nascimento` for `NOT NULL`.
- BCrypt antes da gravação e verificador apropriado no login.

### Questões e resultado de simulado

- Questão existente/ativa e alternativa existente.
- Gabarito A–E aponta para alternativa preenchida.
- Resposta avulsa repetida retorna `409 RESPOSTA_JA_REGISTRADA`.
- A conclusão contém exatamente uma resposta para cada `Quest_Simu`, sem ausentes, extras ou duplicadas.
- API recalcula tudo e cria ou substitui cabeçalho/respostas em uma transação.
- A substituição bloqueia/localiza o resultado atual; rollback preserva o cabeçalho e as respostas anteriores.
- Correção temporária informa apenas `correta`, não devolve `alternativaCorretaId` e não usa repository de resultado/resposta.

### Turmas e calendário

- Código segue `^[0-9]{8}$` e permanece texto.
- Somente professor cria; somente criador administra/publica.
- Entrada cria ou reativa membro em turma ativa.
- Criador não remove a si mesmo enquanto a turma existir.
- Salvar publicação exige membro e publicação ativos; a transação cria cópia, questões e controle juntos.
- O unique de `Simulado_Salvo` torna repetição idempotente/conflitante. Excluir a cópia remove o controle na mesma transação.
- Dono do evento sempre vem do JWT.
- Dia inteiro exige horários nulos; caso contrário ambos são obrigatórios e fim é posterior.
- Cor segue `^#[0-9A-Fa-f]{6}$`.

Erros: `400` formato, `401` autenticação, `403` papel, `404` recurso inexistente/inacessível e `409` duplicidade/estado conflitante.

## 13. Exclusão e inativação

| Estrutura | Comportamento |
|---|---|
| `Aluno`, `Professor`, `Questao` | `ativo = 0`; preservar histórico |
| `Turma` | `ativo = 0`; associações/publicações ficam invisíveis |
| `Turma_Membro` | `ativo = 0`; reentrada reativa |
| `Turma_Simulado` | `ativo = 0`; republicação reativa |
| evento pessoal | `ativo = 0` por ocorrência ou série |
| resposta avulsa | definitiva, sem PUT/DELETE comum |
| resultado/respostas de simulado | substituíveis somente por nova conclusão completa e atômica |
| `Simulado_Salvo` | removido junto com a cópia pessoal; permite salvar novamente se a publicação estiver ativa |
| progresso incompleto | nunca existe no banco |

## 14. Ordem das futuras correções do banco

1. Backup/plano de reversão e identificação de dados provisórios.
2. Uniformizar contas, e-mails e senhas sem unicidade global.
3. Corrigir `Turma` para `char(8)`, check numérico, FK e índices.
4. Criar `Turma_Membro` e aposentar `Aluno_Turma` após tratar dados provisórios.
5. Remodelar `Relatorio_Questao`.
6. Remodelar `Relatorio_Simulado` como resultado único e criar `Resposta_Simulado` com FK/PK composta.
7. Corrigir `Turma_Simulado` e criar `Simulado_Salvo`.
8. Corrigir evento pessoal e separar o papel residual de `Cronograma`.
9. Aplicar índices/constraints e validar em teste.
10. Só então avaliar limpeza legada e itens adiáveis.

Nenhuma migration de evento de turma deve ser criada.

## 15. Ordem de implementação da API

### Antes da próxima alteração do banco

1. DTOs e validações de cadastro/login com `tipoUsuario`.
2. Seleção explícita de `AlunoRepository`/`ProfessorRepository`, BCrypt e JWT com e-mail/tipo.
3. DTOs de saída e bloqueio da serialização de senha/hash.
4. Camada de serviço, erros uniformes e autorização básica.
5. Testes de contrato para contas, tipo, ausência de persistência parcial e permissões.
6. Corrigir somente mapeamentos inequívocos do dump atual, como ID textual de `Turma`; não criar entidades finais sobre tabelas insuficientes.

### Depois das migrations obrigatórias

7. Alinhar entities/repositories de respostas, resultado atual, membros, publicações, salvamentos e eventos.
8. Questões seguras e resposta avulsa definitiva.
9. Simulados e `Quest_Simu` com ownership.
10. Correção temporária sem gabarito/escrita e criação ou substituição transacional do resultado.
11. Desempenho apenas com respostas definitivas.
12. Turmas, membros e publicação/despublicação.
13. Calendário exclusivamente pessoal.
14. Desabilitar CRUDs inseguros e completar testes de autorização/concorrência.

## 16. Ordem posterior de integração do frontend

1. Cliente HTTP comum, JWT, `401` e erros padronizados.
2. Login/cadastro com tipo; remover PHP e simulação de autenticação.
3. Perfil e senha sem trânsito de hash.
4. Questões com resposta avulsa definitiva.
5. Simulados com estado local temporário, descarte ao sair e envio único da resolução completa.
6. Cards com `Completo`, total, acertos e `Recomeçar`.
7. Desempenho somente de persistência definitiva.
8. Turmas: criação apenas para professor e código de oito dígitos.
9. Detalhe da turma somente com `Simulados` e `Membros`; remover aba/componentes/serviços/dados de eventos em turma.
10. Publicação/despublicação somente pelo criador e `Adicionar a meus simulados` para membros.
11. Cópias pessoais independentes e indicação `salvoPeloUsuario` no card publicado.
12. Calendário pessoal ligado à sessão tipada.
13. Remover dados simulados e backend PHP legado ao final.

## 17. Relação com o frontend atual

O frontend é referência visual, não fonte final das regras:

- autenticação simulada usa apenas e-mail/senha e duplicidade global;
- cadastro ainda chama PHP e não seleciona tipo nem coleta nascimento;
- questões já ocultam gabarito na listagem e simulam correção;
- detalhe do simulado mantém respostas localmente, compatível com descarte, mas não envia criação/substituição atômica do resultado;
- cards mantêm `respondidas`, `acertos` e `em_andamento`, que não podem representar progresso incompleto persistido;
- turmas usam IDs numéricos e códigos alfanuméricos de seis caracteres simulados;
- ainda existem aba, componentes, serviços e dados de eventos em turma, todos obsoletos;
- calendário já representa dia inteiro, horários, cor e recorrência, mas usa `usuarioId` simulado e ainda copia eventos de turma.
- o serviço simulado já esboça cópia pessoal de publicação; a integração real deve fazê-la junto com `Quest_Simu` e `Simulado_Salvo` em uma transação.

## 18. Consolidação final

### Decisões confirmadas

- Cadastro/login tipados; e-mail pode repetir entre aluno/professor.
- JWT identifica e-mail/tipo; senhas usam BCrypt.
- Resposta avulsa é definitiva.
- Respostas de simulado são temporárias até conclusão total; sair descarta.
- Existe um único resultado definitivo por conta/simulado; nova conclusão o substitui atomicamente e rollback preserva o anterior.
- Somente professor cria turma; somente criador administra/publica.
- Código tem oito dígitos e é texto.
- Turmas possuem apenas membros e simulados.
- Simulado publicado precisa ser adicionado como cópia pessoal independente antes de ser resolvido; salvamento é único e transacional enquanto a cópia existir.
- Calendário é exclusivamente pessoal e tipado.

### Decisões de recomeço e salvamento

Não resta decisão aberta: `Recomeçar` substitui somente após nova conclusão completa, sem histórico; `Adicionar a meus simulados` cria cópia pessoal independente e controle de salvamento transacional.

### Problemas bloqueantes

- Tipo incompatível em `Aluno_Turma`; membership sem professor.
- Código sem check de oito dígitos.
- Resposta avulsa sem tipo.
- Resultado de simulado sem tipo de usuário e respostas atuais detalhadas.
- Publicação sem integridade ou controle de salvamento adequado.
- Calendário sem tipo e com estruturas sobrepostas.
- JPA divergente do dump.

### Mudanças mínimas obrigatórias

- Uniformizar identidades/e-mails, criar membership tipado, remodelar respostas/resultados, corrigir publicação/salvamento, calendário e código da turma.

### Primeira etapa da API que pode continuar agora

Implementar o contrato de conta tipada: DTOs de cadastro/login, seleção do repository correspondente, BCrypt, JWT com `email + tipoUsuario`, DTOs de saída e testes. Isso usa as tabelas separadas já existentes.

### Ponto exato da próxima alteração do banco

Antes de implementar persistência definitiva de resposta avulsa, substituição do resultado de simulado, professor membro, publicação/salvamento íntegros ou calendário de contas com o mesmo e-mail. A API não deve consolidar entities/repositories finais desses recursos sobre as tabelas atuais insuficientes.
