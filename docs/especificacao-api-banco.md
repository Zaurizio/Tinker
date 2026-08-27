# Especificação da API e do banco — Tinker

## 1. Objetivo

Este documento consolida as regras definitivas do Tinker, o estado atual do banco e a estrutura mínima necessária para a API. Como o projeto é um TCC de curso técnico, validações simples devem permanecer na API quando não exigirem mudança estrutural.

- `schema.sql` é referência histórica; `schema-atual.sql` é o dump mais recente.
- **Atual** significa que a estrutura já existe.
- **Mudança futura obrigatória** significa uma das cinco alterações da seção 5.
- **API** significa que a regra pode ser garantida pela aplicação.
- Este documento não cria migrations nem executa SQL.

## 2. Regras confirmadas

### 2.1 Contas

- `Aluno` e `Professor` permanecem separados. Cadastro, login e JWT identificam `email + tipoUsuario`.
- O mesmo e-mail pode existir uma vez em cada tipo de conta.
- Senhas usam BCrypt; conta inativa não autentica; senha e hash nunca são expostos.

### 2.2 Turmas e membros

- Somente professor ativo cria turma.
- `Turma.email_prof` identifica o professor criador, que é o único professor relacionado à turma.
- Professores não entram em turmas criadas por outros professores. Somente alunos entram pelo código.
- `Aluno_Turma` continua sendo usada para alunos membros. Não criar `Turma_Membro` nem adicionar `tipo_usuario` a `Aluno_Turma`.
- O código é texto com exatamente oito dígitos numéricos e preserva zeros à esquerda, por exemplo `00182745`. A API gera, valida `^[0-9]{8}$`, verifica colisão e tenta novamente.
- Somente o criador administra alunos e publica/despublica simulados.
- Turmas contêm apenas alunos membros e simulados. Não existem eventos em turma.

### 2.3 Questões avulsas

- Aluno e professor podem responder questões avulsas.
- A resposta é definitiva, não pode ser repetida e entra no desempenho por disciplina.
- A API recebe a alternativa, consulta o gabarito e calcula o acerto.
- `Relatorio_Questao` precisará diferenciar `ALUNO` e `PROFESSOR`, pois o e-mail pode existir nos dois tipos.
- `alternativa_selecionada` é opcional: necessária apenas se a interface precisar recuperar depois qual alternativa foi marcada; não é necessária só para bloquear repetição e calcular acerto.

### 2.4 Resolução e resultado de simulados

- Somente alunos possuem resultado persistido de simulado.
- Durante a resolução, alternativas, acertos e erros permanecem no frontend. Sair antes de responder tudo descarta o progresso.
- A correção temporária informa somente se acertou ou errou, sem persistir e sem revelar a alternativa correta.
- Depois de responder tudo, o frontend envia todas as alternativas. A API valida a completude e recalcula os totais.
- `Relatorio_Simulado` guarda somente `cod_simulado`, `email_aluno`, `acertos` e `erros`.
- Não criar `Resposta_Simulado`, não guardar respostas individuais e não guardar histórico de tentativas.
- Cada aluno possui um resultado por simulado. Nova conclusão atualiza a mesma linha.
- Durante recomeço incompleto ou abandono, o resultado anterior permanece salvo.
- O card concluído mostra `Completo`, total de questões, acertos e `Recomeçar`.

### 2.5 Desempenho

- O desempenho por disciplina usa exclusivamente respostas avulsas de `Relatorio_Questao`.
- Resultados de simulados não são distribuídos por disciplina e não exigem respostas individuais.
- `Relatorio_Simulado` pode fornecer apenas métricas gerais, como simulados concluídos e acertos em simulados, se necessário.

### 2.6 Simulados publicados e salvos

- O botão `Adicionar a meus simulados` cria uma cópia pessoal independente e copia as associações de `Quest_Simu`.
- Mudanças ou exclusão do original não alteram a cópia.
- `Simulado_Salvo` é necessária para manter `salvoPeloUsuario`, impedir duplicatas e permitir salvar novamente após excluir a cópia.
- Nome, descrição ou lista de questões nunca identificam cópias.
- Criar cópia, copiar `Quest_Simu` e registrar `Simulado_Salvo` é uma transação. Excluir a cópia remove também esse controle.

### 2.7 Calendário

- O calendário é pessoal para aluno e professor e identifica `email + tipoUsuario`.
- A API gera as ocorrências diárias, semanais, mensais ou anuais.
- `id_serie` só é obrigatória se `Excluir todos` permanecer. Com apenas exclusão individual, pode ser dispensada.
- Não criar tabela separada para séries nem relacionar eventos a turmas.

## 3. Estado atual do banco

| Estrutura | Aproveitamento e limitação |
|---|---|
| `Aluno`, `Professor` | contas separadas; senhas já comportam BCrypt |
| `Questao` | catálogo e gabarito; formato da resposta pode ser validado na API |
| `Simulado`, `Quest_Simu` | definição e associação das questões |
| `Relatorio_Questao` | base das respostas avulsas; ainda não diferencia o tipo da conta |
| `Relatorio_Simulado` | pode ser reaproveitada para o último total de cada aluno por simulado |
| `Turma` | `cod_turma` já é `varchar(8)`; `email_prof` identifica o criador |
| `Aluno_Turma` | associação correta dos alunos; `cod_turma int` ainda é incompatível |
| `Turma_Simulado` | base da publicação; falta controle permanente de cópia salva |
| `HorarioMult` / `Cronograma` | bases legadas do calendário; ainda não distinguem o tipo da conta |

Limitações que realmente exigem mudança futura:

1. incompatibilidade de tipo entre `Aluno_Turma.cod_turma` e `Turma.cod_turma`;
2. colisão de aluno e professor homônimos em `Relatorio_Questao`;
3. ausência de `Simulado_Salvo`;
4. colisão de tipos de conta no calendário;
5. ausência de identificador de série, relevante somente se houver `Excluir todos`.

Não são bloqueios e podem ficar na API: ampliar todos os e-mails para 254 caracteres; criar `CHECK` do código; transformar `Questao.resposta` em `char(1)`; transformar `Simulado.tempo`; e adicionar FKs/checks que a API consegue validar enquanto for o único escritor.

## 4. Estrutura mínima futura

### 4.1 Turmas

Manter `Turma` e `Aluno_Turma`. Alterar somente `Aluno_Turma.cod_turma` para o mesmo tipo textual de oito posições de `Turma.cod_turma`. O professor é identificado exclusivamente por `Turma.email_prof` e não recebe linha de membro.

### 4.2 Respostas avulsas

Manter `Relatorio_Questao` e acrescentar distinção de tipo, para que a identidade lógica seja `email + tipoUsuario + cod_quest`. A alternativa marcada continua opcional conforme a necessidade da interface.

### 4.3 Resultado de simulado

Reaproveitar `Relatorio_Simulado` com seus quatro campos atuais. A chave deve garantir um único resultado por aluno e simulado; `acertos` e `erros` são sobrescritos na nova conclusão. O total é obtido de `Quest_Simu`. Nenhuma tabela de resposta ou tentativa é necessária.

### 4.4 Simulados salvos

Criar `Simulado_Salvo` com referências inequívocas para publicação, conta que salvou e simulado pessoal copiado. A estrutura deve sustentar `salvoPeloUsuario`, impedir segunda cópia enquanto a primeira existir e permitir novo salvamento depois da exclusão.

### 4.5 Calendário

Evoluir a estrutura escolhida de evento para identificar o dono por `email + tipoUsuario`. Cada ocorrência é uma linha gerada pela API. Adicionar `id_serie` somente se a exclusão conjunta continuar; não criar tabela de séries.

## 5. Lista mínima de mudanças futuras no banco

1. Mudar `Aluno_Turma.cod_turma` para o mesmo tipo textual de oito posições de `Turma.cod_turma`.
2. Diferenciar aluno e professor em `Relatorio_Questao`.
3. Criar `Simulado_Salvo`.
4. Diferenciar aluno e professor no calendário.
5. Adicionar `id_serie` ao calendário somente se `Excluir todos` permanecer.

Nenhuma outra mudança de banco é obrigatória no escopo confirmado.

## 6. Entidades e repositories esperados

Antes das mudanças futuras:

- entidades `Aluno`, `Professor`, `Questao`, `Simulado`, `QuestaoSimu`, `Turma`, `AlunoTurma`, `TurmaSimulado` e o resultado agregado de `Relatorio_Simulado`;
- `Turma.codTurma` e `TurmaRepository` usam `String`, sem `IDENTITY`;
- repositories de conta por tipo, turma, alunos da turma, publicação e resultado agregado;
- a entidade de resultado possui somente os quatro campos existentes e é restrita a aluno.

Depois de cada mudança correspondente:

- `AlunoTurma` e seu ID composto passam a usar código textual;
- `RespostaAvulsa` mapeia `Relatorio_Questao` com identidade tipada;
- `SimuladoSalvo` consulta por publicação, conta e cópia;
- evento pessoal consulta pelo dono tipado e, opcionalmente, pela série.

Não criar entidades/repositories de membro genérico, resposta de simulado, tentativa ou evento de turma.

## 7. DTOs esperados

```text
LoginRequestDTO { email, senha, tipoUsuario: "ALUNO"|"PROFESSOR" }
CadastroUsuarioRequestDTO { nome, sobrenome, email, senha, tipoUsuario, nascimento? }
AuthResponseDTO { token, tipo: "Bearer", expiraEm, usuario }
UsuarioResumoDTO { email, nome, sobrenome, tipoUsuario }

QuestaoDTO { id, disciplina, conteudo, enunciado, alternativas, respondidaAvulsa? }
RespostaAvulsaRequestDTO { alternativaSelecionadaId }
RespostaAvulsaDTO { questaoId, correta, bloqueada, alternativaSelecionadaId? }

SimuladoResumoDTO {
  id, titulo, quantidadeQuestoes, status: "nao_concluido"|"completo",
  resultado?: { acertos, erros }
}
CorrecaoTemporariaRequestDTO { questaoId, alternativaSelecionadaId }
CorrecaoTemporariaDTO { questaoId, correta, persistida: false }
ConcluirSimuladoDTO { respostas: [{ questaoId, alternativaSelecionadaId }] }
ResultadoSimuladoDTO { simuladoId, totalQuestoes, acertos, erros }

CriarTurmaDTO { nome }
EntrarTurmaDTO { codigo }
TurmaResumoDTO { codigo, nome, professorCriador, quantidadeAlunos }
AlunoTurmaDTO { email, nome, fotoPerfil?, ativo }
PublicarSimuladoDTO { simuladoId }
PublicacaoSimuladoDTO {
  idPublicacao, simuladoId, titulo, quantidadeQuestoes, ativo, salvoPeloUsuario
}
SalvarSimuladoDTO { sucesso, simuladoPessoalId, jaAdicionado }

CriarEventoDTO { titulo, data, horarioInicio?, horarioFim?, diaInteiro, cor, recorrencia }
EventoCalendarioDTO { id, title, start, end?, allDay, color, serieId? }
DesempenhoResumoDTO {
  questoesAvulsasRespondidas, taxaAcertosGeral,
  disciplinas: [{ nome, porcentagemAcertos, acertos, questoesFeitas }],
  simuladosConcluidos?, acertosEmSimulados?
}
ErroDTO { codigo, mensagem, campos? }
```

`QuestaoDTO` não expõe gabarito e a correção temporária não revela a alternativa correta. Não existem DTOs de respostas persistidas de simulado, tentativas, professor membro ou evento em turma.

## 8. Endpoints

### Autenticação, perfil e questões

| Rota | Acesso | Função |
|---|---|---|
| `POST /api/auth/cadastros` | público | cria conta do tipo informado |
| `POST /api/auth/login` | público | autentica no tipo informado |
| `GET /api/me` | aluno/professor | perfil próprio |
| `PUT /api/me` | aluno/professor | atualiza perfil próprio |
| `PUT /api/me/senha` | aluno/professor | troca senha |
| `GET /api/questoes` | autenticado | lista sem gabarito |
| `GET /api/questoes/{id}` | autenticado | detalhe sem gabarito |
| `POST /api/questoes/{id}/resposta` | aluno/professor | resposta avulsa definitiva |
| `GET /api/me/desempenho` | aluno/professor | desempenho por disciplina com `Relatorio_Questao` |

### Simulados

| Rota | Acesso | Função |
|---|---|---|
| `GET /api/simulados` | aluno/professor | lista pessoais |
| `POST /api/simulados` | aluno/professor | cria pessoal |
| `GET /api/simulados/{id}` | dono | detalhe e último total, se houver |
| `POST /api/simulados/{id}/correcoes` | dono | correção temporária sem escrita/gabarito |
| `PUT /api/simulados/{id}/resultado` | aluno dono | recalcula e cria/atualiza o único total |
| `GET /api/simulados/{id}/resultado` | aluno dono | último total agregado |

Não existe endpoint para progresso parcial, respostas persistidas ou histórico.

### Turmas e publicações

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
| `GET /api/turmas/{codigo}/simulados` | criador/aluno membro | lista publicações |
| `POST /api/turmas/{codigo}/simulados` | criador | publica |
| `DELETE /api/turmas/{codigo}/simulados/{publicacaoId}` | criador | despublica |
| `POST /api/publicacoes-simulado/{publicacaoId}/salvamentos` | aluno membro | cria cópia e controle |

Não existem rotas de professor entrar, membro genérico ou evento em turma.

### Calendário pessoal

| Rota | Acesso | Função |
|---|---|---|
| `GET /api/eventos?inicio=&fim=` | aluno/professor | lista eventos pessoais |
| `POST /api/eventos` | aluno/professor | API cria ocorrência(s) |
| `DELETE /api/eventos/{id}` | dono | exclui uma ocorrência |
| `DELETE /api/eventos/series/{idSerie}` | dono | exclui série, somente se a opção existir |

## 9. Permissões

| Operação | Aluno | Professor criador | Outro professor | Administrador |
|---|---:|---:|---:|---:|
| Responder questão avulsa | sim | sim | sim | não |
| Persistir resultado de simulado | sim | não | não | não |
| Criar simulado pessoal | sim | sim | sim | não |
| Criar turma | não | sim | sim, em outra turma | não automaticamente |
| Entrar em turma | sim | já é criador | não | não |
| Administrar alunos | não | sim | não | não automaticamente |
| Publicar/despublicar | não | sim | não | não automaticamente |
| Adicionar publicação | sim | não | não | não |
| Gerir calendário pessoal | sim | sim | sim | não |
| Publicar evento em turma | não existe | não existe | não existe | não existe |

## 10. Validações na API

- Selecionar conta pelo tipo no cadastro/login e incluir `email + tipoUsuario` no JWT.
- Normalizar e validar e-mail; impedir duplicidade somente dentro do tipo.
- Gerar código textual de oito dígitos e verificar colisão.
- Autorizar criação/administração por `Turma.email_prof`; permitir entrada somente a aluno.
- Validar membership, publicação ativa e ownership.
- Corrigir resposta avulsa no servidor e bloquear repetição pela identidade tipada.
- Correção temporária retorna apenas `correta` e não usa repository de relatório.
- Conclusão exige uma resposta para cada `Quest_Simu`, recalcula totais e faz upsert do único `Relatorio_Simulado` do aluno.
- Cópia, `Quest_Simu` e `Simulado_Salvo` são criados atomicamente.
- Calendário valida dono tipado, datas, horários, cor e recorrência.

Usar `400` para formato, `401` para autenticação, `403` para permissão, `404` para recurso inacessível e `409` para duplicidade/estado conflitante.

## 11. Ordem de implementação da API

### Antes da próxima mudança no banco

1. DTOs de cadastro/login tipado, repositories corretos, BCrypt e JWT.
2. DTOs de saída seguros, serviços e erros uniformes.
3. Catálogo de questões e simulados sem gabarito.
4. Correção temporária sem persistência.
5. Validação da conclusão e reaproveitamento de `Relatorio_Simulado` para o último total.
6. Criação de turma, código textual e autorização pelo `email_prof`.
7. Publicação/despublicação básica conforme o schema atual.
8. Calendário pessoal básico apenas onde não houver ambiguidade de conta.
9. Testes de contrato, autorização e ausência de persistência parcial.

### Depois da mudança correspondente

10. Entrada/gestão de alunos após alinhar `Aluno_Turma.cod_turma`.
11. Resposta avulsa para os dois tipos após diferenciar `Relatorio_Questao`.
12. `Adicionar a meus simulados` permanente após criar `Simulado_Salvo`.
13. Calendário seguro para e-mails iguais após diferenciar o tipo.
14. `Excluir todos` somente após adicionar `id_serie`, se a opção continuar.

## 12. Ordem futura de integração do frontend

1. Cliente HTTP, JWT e erros padronizados.
2. Cadastro/login tipado; remover autenticação simulada/PHP.
3. Perfil e senha sem trânsito de hash.
4. Questões avulsas definitivas.
5. Simulados com estado local, descarte ao sair e envio único ao completar.
6. Cards com `Completo`, total, acertos e `Recomeçar`.
7. Desempenho por disciplina só com respostas avulsas; métricas gerais de simulados separadas.
8. Turmas: professor cria, aluno entra, código com oito dígitos.
9. Detalhe apenas com alunos e simulados; remover eventos e professor membro.
10. Publicação pelo criador e `Adicionar a meus simulados` pelo aluno membro.
11. Cópias independentes e `salvoPeloUsuario` via `Simulado_Salvo`.
12. Calendário pessoal tipado; `Excluir todos` apenas com `id_serie`.
13. Remover dados simulados e PHP legado ao final.

## 13. Consolidação

- O professor criador é o único professor da turma; `Aluno_Turma` contém somente alunos.
- O código da turma é texto com oito dígitos e pode ser validado na API.
- Simulados persistem apenas o último total agregado de cada aluno, sem alternativas ou tentativas.
- Desempenho por disciplina usa apenas `Relatorio_Questao`.
- `Adicionar a meus simulados` cria cópia independente e exige `Simulado_Salvo`.
- Calendário é pessoal e tipado; não há tabela de séries nem eventos em turma.
- As únicas mudanças futuras obrigatórias são as cinco da seção 5.

Antes delas, podem avançar autenticação tipada, BCrypt/JWT, DTOs seguros, catálogo, correção temporária, validação da conclusão, resultado agregado atual, criação/autorização de turmas, publicação básica, calendário não ambíguo e testes. Cada recurso bloqueado aguarda somente sua mudança correspondente, não uma remodelagem geral do banco.
