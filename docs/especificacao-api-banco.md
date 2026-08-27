# Especificação da API e do banco — Tinker

## 1. Objetivo

Este documento consolida as regras definitivas do Tinker, o estado de `schema-atual.sql` e o contrato esperado da API. O schema é tratado como dado de entrada: esta especificação não propõe alteração de banco, não cria migrations e não executa SQL.

- `schema.sql` é referência histórica; `schema-atual.sql` é o dump vigente.
- **Atual** significa que a estrutura já existe no dump vigente.
- **API** significa que a regra deve ser validada ou coordenada pela aplicação sobre a estrutura atual.
- Validações de domínio e autorização não devem ser delegadas ao cliente.

## 2. Regras confirmadas

### 2.1 Contas

- `Aluno` e `Professor` permanecem separados. Cadastro, login e JWT identificam `email + tipoUsuario`.
- O mesmo e-mail pode existir uma vez em cada tipo de conta.
- Senhas usam BCrypt; conta inativa não autentica; senha e hash nunca são expostos.

### 2.2 Turmas e membros

- Somente professor ativo cria turma.
- `Turma.email_prof` identifica o professor criador, que é o único professor relacionado à turma.
- Professores não entram em turmas criadas por outros professores. Somente alunos entram pelo código.
- `Aluno_Turma` contém somente alunos membros. Não criar membro genérico nem adicionar professor nessa associação.
- `Turma.cod_turma` e `Aluno_Turma.cod_turma` já são `varchar(8)` no schema atualizado.
- O código é texto com exatamente oito dígitos numéricos e preserva zeros à esquerda, por exemplo `00182745`. A API gera, valida `^[0-9]{8}$`, verifica colisão e tenta novamente.
- Somente o professor criador administra alunos e publica ou despublica simulados.
- Turmas contêm apenas alunos membros e publicações de simulados. Não existem eventos em turma.

### 2.3 Questões e último resultado

- Aluno e professor podem responder questões avulsas.
- Cada correção é calculada pela API a partir do gabarito e cria ou atualiza imediatamente `Relatorio_Questao`.
- A mesma regra vale para questões respondidas dentro de um simulado, mesmo que o simulado seja abandonado antes da conclusão.
- `Relatorio_Questao` representa somente o último resultado daquele usuário naquela questão.
- Responder novamente a mesma questão substitui o resultado anterior. Não existe bloqueio de repetição nem histórico de respostas.
- O desempenho por disciplina considera todas as linhas atuais de `Relatorio_Questao`, independentemente de a última resposta ter ocorrido de forma avulsa ou dentro de um simulado.
- A API recebe a alternativa selecionada, consulta o gabarito e persiste somente o resultado calculado. O cliente nunca informa diretamente se acertou.
- A coluna `tipo_usu` deve identificar o tipo de conta conforme o valor textual adotado pela API.
- A alternativa selecionada não precisa ser persistida para atender ao contrato atual.

### 2.4 Propriedade e publicação de simulados

- Somente professor cria ou gera simulados.
- `Simulado.email_prof` identifica o professor proprietário.
- Somente o professor proprietário pode editar título, descrição e tempo, adicionar ou remover questões e excluir o simulado.
- O professor publica o simulado original em uma turma por meio de `Turma_Simulado`.
- Para publicar, o mesmo professor deve ser proprietário do simulado e criador da turma.
- Um aluno ativo em `Aluno_Turma` pode abrir e responder o simulado enquanto a publicação estiver ativa.
- O acesso do aluno decorre da cadeia `Aluno_Turma → Turma_Simulado → Simulado`; ele não se torna proprietário.
- O aluno membro não pode editar o simulado nem suas questões estruturais e não pode excluí-lo ou publicá-lo.
- Alterações feitas pelo professor no original passam a valer para as publicações que apontam para ele.

### 2.5 Resolução e resultado geral de simulados

- O frontend mantém visualmente as alternativas marcadas e o progresso da tentativa em andamento.
- Cada solicitação de correção de questão atualiza imediatamente `Relatorio_Questao` e retorna apenas se a resposta está correta, sem revelar o gabarito.
- Abandonar um simulado apaga apenas o progresso visual mantido no frontend. Os últimos resultados já gravados em `Relatorio_Questao` permanecem.
- Quando todas as questões tiverem sido respondidas, o frontend envia o conjunto completo da conclusão.
- A API valida que há exatamente uma resposta válida para cada associação de `Quest_Simu`, recalcula todas as respostas e atualiza novamente os respectivos últimos resultados em `Relatorio_Questao`.
- Somente depois dessa validação integral a API cria ou atualiza `Relatorio_Simulado`.
- `Relatorio_Simulado` guarda somente `cod_simulado`, `email_aluno`, `acertos` e `erros`.
- Cada aluno possui no máximo um resultado geral por simulado. Uma nova conclusão substitui `acertos` e `erros` da mesma linha.
- Uma nova tentativa incompleta não apaga nem altera o resultado geral da conclusão anterior.
- O status de conclusão é individual por aluno e deriva da existência de `Relatorio_Simulado` para `(cod_simulado, email_aluno)`.
- `Simulado.conclusao` não determina o status de nenhum aluno e não deve ser usado pela API para esse fim.
- Não existe persistência de progresso parcial do simulado, conjunto de alternativas, tentativa ou histórico.

### 2.6 Desempenho

- O desempenho por disciplina usa `Relatorio_Questao` unido a `Questao.disciplina`.
- Como cada linha representa o último resultado por usuário e questão, `questoesFeitas`, acertos e percentual são calculados sobre esse estado atual, e não sobre o número histórico de tentativas.
- Questões corrigidas dentro de simulados entram no mesmo cálculo das questões avulsas.
- `Relatorio_Simulado` fornece métricas gerais separadas, como simulados concluídos e totais finais, mas não substitui a distribuição por disciplina.

### 2.7 Calendário

- O calendário é pessoal para aluno e professor e identifica `email + tipoUsuario`.
- A API gera as ocorrências diárias, semanais, mensais ou anuais.
- `id_serie` só é necessária se `Excluir todos` permanecer. Com apenas exclusão individual, pode ser dispensada.
- Não criar tabela separada para séries nem relacionar eventos a turmas.

## 3. Estado atual do banco

| Estrutura | Colunas ou chave relevantes | Uso e limitação atual |
|---|---|---|
| `Aluno`, `Professor` | PK `email`; dados e credenciais separados | contas separadas; senhas comportam BCrypt |
| `Questao` | `cod_questao`, `disciplina`, alternativas, `resposta`, `ativo` | catálogo, disciplina e gabarito |
| `Simulado` | `cod_simulado`, `nome`, `descricao`, `conclusao`, `tempo`, `email_aluno`, `email_prof`, `tipo_usu` | definição original; a API usa `email_prof` como proprietário e ignora `conclusao` como status individual |
| `Quest_Simu` | PK `(cod_simulado, cod_quest)` | questões pertencentes ao simulado original |
| `Turma` | `cod_turma varchar(8)`, `email_prof`, `ativo` | turma e professor criador |
| `Aluno_Turma` | PK `(email_aluno, cod_turma)`; `cod_turma varchar(8)` | membership ativo do aluno; o mapeamento JPA também deve usar texto |
| `Turma_Simulado` | `id_publicacao`, `cod_simulado`, `cod_turma`, `ativo`, `data_publicacao` | publicação do original na turma |
| `Relatorio_Questao` | PK `(cod_quest, email)`; `acertou/errou`, `tipo_usu` | último resultado por questão; a PK física não inclui o tipo da conta |
| `Relatorio_Simulado` | PK `(cod_simulado, email_aluno)`; `acertos`, `erros` | último resultado geral concluído de cada aluno |
| `HorarioMult` / `Cronograma` | estruturas legadas | calendário ainda possui ambiguidade entre tipos de conta |

Observações obrigatórias para a implementação sobre o schema atual:

1. `Aluno_Turma.cod_turma` já está alinhado a `Turma.cod_turma` como `varchar(8)`; entidades, IDs compostos, DTOs e parâmetros da API devem usar `String`.
2. `Simulado.tipo_usu` existe como `varchar(8) NOT NULL`. Está pendente definir o valor textual exato a gravar para simulados de professor, pois `"PROFESSOR"` possui nove caracteres e não cabe na coluna.
3. Até essa definição, criação e geração de simulados não têm um valor contratual final para `tipo_usu`; a API não deve truncar silenciosamente nem escolher uma abreviação sem decisão explícita.
4. `Relatorio_Questao.tipo_usu` existe, mas sua PK física é somente `(cod_quest, email)`. A API deve reconhecer essa limitação ao tratar e-mails iguais nos dois tipos de conta.
5. O schema não garante por FK, unicidade ou `CHECK` todas as regras de propriedade, publicação, membership e valores ativos; a API deve validá-las.

Este documento registra o schema como está e não prescreve mudança de banco nesta etapa.

## 4. Modelo de domínio esperado na API

### 4.1 Turmas e publicações

- `Turma` representa a turma criada pelo professor.
- `AlunoTurma` usa código textual e representa apenas aluno membro.
- `TurmaSimulado` representa uma publicação do simulado original.
- O serviço de publicação valida professor proprietário, professor criador da turma e publicação ativa.
- O serviço de leitura valida professor criador ou aluno membro ativo, conforme a operação.

### 4.2 Simulado

- `Simulado` é sempre criado por professor e tem `email_prof` preenchido com o usuário autenticado.
- `QuestaoSimu` mantém as questões do original.
- Operações estruturais usam autorização de proprietário, não membership.
- Operações de resolução do aluno exigem publicação ativa e membership ativo.
- `email_aluno` e `conclusao` não participam das decisões de propriedade ou status individual.

### 4.3 Último resultado por questão

- A entidade que mapeia `Relatorio_Questao` contém questão, e-mail, tipo de usuário e indicador de acerto.
- Toda correção faz upsert do último resultado dentro da mesma transação da operação.
- Correções avulsas e de simulados usam o mesmo serviço de cálculo e persistência.
- Não criar entidade de tentativa ou histórico de resposta.

### 4.4 Resultado geral do simulado

- `RelatorioSimulado` mantém somente os quatro campos existentes.
- O resultado só é salvo após validação integral das respostas contra `Quest_Simu`.
- A chave composta identifica um único resultado por aluno e simulado.
- O status apresentado ao aluno é derivado desse resultado.

### 4.5 Calendário

- O evento pessoal consulta pelo dono tipado e, opcionalmente, pela série.
- Não criar evento de turma.

## 5. Pendências de contrato sobre o schema atual

Estas pendências precisam de decisão ou tratamento na API; não constituem proposta de alteração do banco nesta etapa:

1. definir o valor textual exato de `Simulado.tipo_usu` que represente professor e caiba em `varchar(8)`;
2. definir o comportamento suportado quando aluno e professor compartilham o mesmo e-mail, considerando que a PK de `Relatorio_Questao` não inclui `tipo_usu`;
3. manter os códigos de turma como texto de oito dígitos em todas as camadas;
4. garantir por serviço a unicidade lógica de uma publicação ativa do mesmo simulado na mesma turma;
5. definir se `Excluir todos` continuará no calendário antes de assumir suporte a séries.

## 6. Entidades e repositories esperados

- Entidades: `Aluno`, `Professor`, `Questao`, `Simulado`, `QuestaoSimu`, `Turma`, `AlunoTurma`, `TurmaSimulado`, `Relatorio` e `RelatorioSimulado`.
- `Turma.codTurma`, `AlunoTurma.codTurma` e seus IDs compostos usam `String`, sem `IDENTITY`.
- `SimuladoRepository` consulta simulados do professor por `email_prof`.
- `TurmaSimuladoRepository` consulta por turma, simulado, publicação e estado ativo.
- `AlunoTurmaRepository` verifica membership por `email_aluno + cod_turma + ativo`.
- `RelatorioRepository` oferece consulta e upsert do último resultado por questão dentro das limitações da chave atual.
- `RelatorioSimuladoRepository` consulta e faz upsert por `cod_simulado + email_aluno`.
- Operações de exclusão do simulado tratam associações, publicações e resultados relacionados de forma transacional.
- Não criar entidades ou repositories de membro genérico, progresso de simulado, tentativa, histórico de resposta ou evento de turma.

## 7. DTOs esperados

```text
LoginRequestDTO { email, senha, tipoUsuario: "ALUNO"|"PROFESSOR" }
CadastroUsuarioRequestDTO { nome, sobrenome, email, senha, tipoUsuario, nascimento? }
AuthResponseDTO { token, tipo: "Bearer", expiraEm, usuario }
UsuarioResumoDTO { email, nome, sobrenome, tipoUsuario }

QuestaoDTO { id, disciplina, conteudo, enunciado, alternativas }
CorrigirQuestaoDTO { alternativaSelecionadaId }
ResultadoQuestaoDTO { questaoId, correta, persistida: true }

CriarSimuladoDTO { titulo, descricao?, tempo? }
GerarSimuladoDTO {
  titulo, descricao?, tempo?, quantidadeQuestoes,
  disciplinas?, conteudos?, vestibulares?, anos?
}
AtualizarSimuladoDTO { titulo?, descricao?, tempo? }
QuestoesSimuladoDTO { questoesIds }
SimuladoProfessorResumoDTO { id, titulo, quantidadeQuestoes }
SimuladoDetalheDTO { id, titulo, descricao?, tempo?, quantidadeQuestoes, questoes }

CriarTurmaDTO { nome }
EntrarTurmaDTO { codigo }
TurmaResumoDTO { codigo, nome, professorCriador, quantidadeAlunos }
AlunoTurmaDTO { email, nome, fotoPerfil?, ativo }
PublicarSimuladoDTO { simuladoId }
PublicacaoSimuladoDTO {
  idPublicacao, simuladoId, titulo, descricao?, tempo?, quantidadeQuestoes, ativo,
  statusAluno?: "nao_concluido"|"completo",
  resultadoAluno?: { acertos, erros }
}

CorrigirQuestaoSimuladoDTO { questaoId, alternativaSelecionadaId }
CorrecaoQuestaoSimuladoDTO { questaoId, correta, persistida: true }
ConcluirSimuladoDTO { respostas: [{ questaoId, alternativaSelecionadaId }] }
ResultadoSimuladoDTO { simuladoId, totalQuestoes, acertos, erros, status: "completo" }

CriarEventoDTO { titulo, data, horarioInicio?, horarioFim?, diaInteiro, cor, recorrencia }
EventoCalendarioDTO { id, title, start, end?, allDay, color, serieId? }
DesempenhoResumoDTO {
  questoesRespondidas, taxaAcertosGeral,
  disciplinas: [{ nome, porcentagemAcertos, acertos, questoesFeitas }],
  simuladosConcluidos?, acertosEmSimulados?
}
ErroDTO { codigo, mensagem, campos? }
```

`QuestaoDTO` não expõe gabarito. Toda correção retorna apenas se a alternativa está correta e informa que o último resultado foi persistido. Não existem DTOs de progresso persistido, tentativa ou histórico.

## 8. Endpoints

### Autenticação, perfil, questões e desempenho

| Rota | Acesso | Função |
|---|---|---|
| `POST /api/auth/cadastros` | público | cria conta do tipo informado |
| `POST /api/auth/login` | público | autentica no tipo informado |
| `GET /api/me` | aluno/professor | perfil próprio |
| `PUT /api/me` | aluno/professor | atualiza perfil próprio |
| `PUT /api/me/senha` | aluno/professor | troca senha |
| `GET /api/questoes` | autenticado | lista sem gabarito |
| `GET /api/questoes/{id}` | autenticado | detalhe sem gabarito |
| `POST /api/questoes/{id}/correcoes` | aluno/professor | calcula e atualiza imediatamente o último resultado |
| `GET /api/me/desempenho` | aluno/professor | desempenho por disciplina com todas as linhas atuais de `Relatorio_Questao` |

### Simulados do professor

| Rota | Acesso | Função |
|---|---|---|
| `GET /api/simulados` | professor | lista simulados de que é proprietário |
| `POST /api/simulados` | professor | cria simulado original |
| `POST /api/simulados/geracoes` | professor | gera simulado original e associa questões |
| `GET /api/simulados/{id}` | professor proprietário | detalhe do original |
| `PATCH /api/simulados/{id}` | professor proprietário | edita metadados |
| `POST /api/simulados/{id}/questoes` | professor proprietário | adiciona questões |
| `DELETE /api/simulados/{id}/questoes/{questaoId}` | professor proprietário | remove questão |
| `DELETE /api/simulados/{id}` | professor proprietário | exclui original e trata relações dependentes |

### Turmas, publicações e resolução pelo aluno

| Rota | Acesso | Função |
|---|---|---|
| `GET /api/turmas` | aluno/professor | lista turmas do aluno ou criadas pelo professor |
| `POST /api/turmas` | professor | cria turma |
| `POST /api/turmas/entradas` | aluno | entra pelo código |
| `GET /api/turmas/{codigo}` | criador/aluno membro | detalhe |
| `DELETE /api/turmas/{codigo}` | criador | inativa turma |
| `GET /api/turmas/{codigo}/alunos` | criador/aluno membro | lista alunos |
| `DELETE /api/turmas/{codigo}/alunos/me` | aluno membro | sai |
| `DELETE /api/turmas/{codigo}/alunos/{email}` | criador | remove aluno |
| `GET /api/turmas/{codigo}/simulados` | criador/aluno membro | lista publicações e, para aluno, seu status individual |
| `POST /api/turmas/{codigo}/simulados` | criador e proprietário do simulado | publica o original |
| `DELETE /api/turmas/{codigo}/simulados/{publicacaoId}` | criador | despublica |
| `GET /api/publicacoes-simulado/{publicacaoId}` | criador/aluno membro | abre o original publicado sem gabarito |
| `POST /api/publicacoes-simulado/{publicacaoId}/correcoes` | aluno membro | corrige uma questão e atualiza imediatamente `Relatorio_Questao` |
| `PUT /api/publicacoes-simulado/{publicacaoId}/resultado` | aluno membro | valida todas as respostas e cria ou atualiza `Relatorio_Simulado` |
| `GET /api/publicacoes-simulado/{publicacaoId}/resultado` | aluno membro | lê seu último resultado geral, se existente |

Não existe endpoint de persistência de progresso parcial ou histórico. O endpoint de conclusão pode repetir o cálculo e o upsert dos últimos resultados por questão para garantir que o total final foi produzido no servidor a partir do conjunto completo.

### Calendário pessoal

| Rota | Acesso | Função |
|---|---|---|
| `GET /api/eventos?inicio=&fim=` | aluno/professor | lista eventos pessoais |
| `POST /api/eventos` | aluno/professor | API cria ocorrência(s) |
| `DELETE /api/eventos/{id}` | dono | exclui uma ocorrência |
| `DELETE /api/eventos/series/{idSerie}` | dono | exclui série, somente se a opção existir |

## 9. Permissões

| Operação | Aluno membro | Professor proprietário/criador | Outro professor | Administrador |
|---|---:|---:|---:|---:|
| Responder questão avulsa | sim | sim | sim | não |
| Criar ou gerar simulado | não | sim | sim, como proprietário do próprio simulado | não automaticamente |
| Editar metadados ou questões do simulado | não | sim | não | não automaticamente |
| Excluir simulado | não | sim | não | não automaticamente |
| Criar turma | não | sim | sim, como criador de outra turma | não automaticamente |
| Entrar em turma | sim | não | não | não |
| Administrar alunos | não | sim | não | não automaticamente |
| Publicar ou despublicar simulado | não | sim | não | não automaticamente |
| Abrir simulado publicado | sim | sim | não | não automaticamente |
| Corrigir questão de simulado publicado | sim | não | não | não |
| Concluir e persistir resultado geral | sim | não | não | não |
| Editar simulado durante a resolução | não | sim | não | não automaticamente |
| Gerir calendário pessoal | sim | sim | sim | não |
| Publicar evento em turma | não existe | não existe | não existe | não existe |

Para as operações do aluno na publicação, “sim” pressupõe `Aluno_Turma.ativo = 1`, turma ativa e publicação ativa.

## 10. Validações e transações na API

- Selecionar conta pelo tipo no cadastro/login e incluir `email + tipoUsuario` no JWT.
- Normalizar e validar e-mail; impedir duplicidade somente dentro do tipo.
- Gerar código textual de oito dígitos e verificar colisão.
- Autorizar criação e administração de turma por `Turma.email_prof`; permitir entrada somente a aluno.
- Autorizar operações estruturais de simulado exclusivamente por `Simulado.email_prof`.
- Validar professor proprietário, professor criador da turma e publicação antes de publicar.
- Validar membership ativo, turma ativa e publicação ativa antes de o aluno abrir, corrigir ou concluir.
- Validar que a questão corrigida pertence ao `Quest_Simu` do simulado publicado.
- Calcular a correção no servidor, retornar somente `correta` e fazer upsert imediato de `Relatorio_Questao`.
- Ao repetir uma questão, substituir o indicador anterior; nunca criar histórico.
- Na conclusão, exigir uma resposta para cada `Quest_Simu`, rejeitar ausências, duplicidades e questões extras e recalcular o conjunto completo.
- Fazer os upserts de `Relatorio_Questao` e de `Relatorio_Simulado` da conclusão em uma transação.
- Não criar ou atualizar `Relatorio_Simulado` quando o conjunto estiver incompleto ou inválido.
- Obter status individual exclusivamente por `Relatorio_Simulado`; ignorar `Simulado.conclusao` para esse fim.
- Não confiar em e-mail, proprietário, acerto, totais ou status enviados pelo cliente.
- Ao excluir um simulado, tratar associações de questões, publicações e resultados relacionados de forma transacional.
- Calendário valida dono tipado, datas, horários, cor e recorrência.

Usar `400` para formato ou conjunto incompleto, `401` para autenticação, `403` para permissão, `404` para recurso inacessível e `409` para duplicidade ou estado conflitante.

## 11. Ordem futura de implementação da API

1. Alinhar entidades e IDs de turma ao `varchar(8)` já existente no schema.
2. Definir explicitamente o valor textual de `Simulado.tipo_usu` antes de habilitar criação e geração persistentes.
3. Restringir criação, geração, edição, gestão de questões e exclusão de simulados ao professor proprietário.
4. Implementar serviços autenticados de turma e membership com código textual.
5. Implementar publicação e despublicação do simulado original, com validações de propriedade e autoria da turma.
6. Implementar listagem e abertura da publicação para aluno membro, sempre sem gabarito.
7. Unificar a correção avulsa e a correção dentro de simulado com upsert imediato de `Relatorio_Questao`.
8. Implementar desempenho por disciplina incluindo os últimos resultados originados em qualquer contexto.
9. Implementar conclusão integral e transacional com upsert de `Relatorio_Simulado`.
10. Derivar cards e status individuais do aluno a partir de `Relatorio_Simulado`.
11. Corrigir exclusão transacional do original e tratamento de associações, publicações e resultados.
12. Implementar calendário pessoal apenas nos cenários compatíveis com a identidade disponível.
13. Cobrir contratos, autorização, repetição de resposta, abandono, conclusão incompleta e nova conclusão com testes.

## 12. Ordem futura de integração do frontend

1. Cliente HTTP, JWT e erros padronizados.
2. Cadastro/login tipado; remover autenticação simulada/PHP.
3. Perfil e senha sem trânsito de hash.
4. Questões avulsas com correção persistida e possibilidade de nova resposta.
5. Área do professor para criar, gerar, editar e excluir seus simulados.
6. Turmas: professor cria, aluno entra e o código mantém oito dígitos.
7. Publicação do original pelo professor e listagem para alunos membros.
8. Resolução da publicação com estado visual local e persistência de cada correção no backend.
9. Ao abandonar, descartar apenas o estado visual local; ao reabrir, iniciar uma nova resolução visual.
10. Ao completar, enviar o conjunto integral e exibir o resultado de `Relatorio_Simulado`.
11. Cards com status individual `Completo`, total, acertos e opção de responder novamente.
12. Desempenho por disciplina usando também os últimos resultados de questões respondidas em simulados.
13. Calendário pessoal tipado; `Excluir todos` apenas se houver suporte confirmado a série.
14. Remover dados simulados e PHP legado ao final.

## 13. Consolidação

- O professor é o único proprietário de um simulado e é identificado por `Simulado.email_prof`.
- O professor publica o original; o aluno membro resolve diretamente essa publicação e não adquire permissão de edição.
- Cada correção atualiza imediatamente o último resultado em `Relatorio_Questao`, inclusive durante um simulado incompleto.
- Repetir uma questão substitui o resultado anterior; não existe histórico.
- Abandonar a resolução descarta somente o progresso visual do frontend.
- `Relatorio_Simulado` é gravado apenas após conclusão integral e guarda somente acertos e erros finais.
- O status de conclusão é individual e vem de `Relatorio_Simulado`, nunca de `Simulado.conclusao`.
- O desempenho por disciplina inclui os últimos resultados de questões avulsas e de simulados.
- `Turma.cod_turma` e `Aluno_Turma.cod_turma` já são textos de oito posições no schema atualizado.
- Permanece pendente definir o texto de `Simulado.tipo_usu`, pois o valor por extenso não cabe em `varchar(8)`.
- Calendário é pessoal e tipado; não há eventos em turma.
