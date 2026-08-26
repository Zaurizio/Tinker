# Especificação técnica — integração web, API Java e MySQL

## Escopo e classificação

Este documento consolida o contrato futuro entre o web React/Vite, a API Spring Boot e o schema MySQL do Tinker. Foi elaborado por leitura do web atual, do arquivo `demoTinkerAT1.zip` e do `schema.sql`; nenhum desses artefatos deve ser alterado nesta etapa.

As marcações usadas são:

- **Confirmada:** regra de negócio já decidida.
- **Obrigatória:** mudança mínima sem a qual o contrato confirmado não pode ser garantido.
- **Adiável:** melhoria recomendada, mas não bloqueia a primeira integração.
- **Aberta:** decisão ainda necessária antes de escrever a migration ou fechar o contrato.

Princípio central: manter as tabelas de conta separadas (`Aluno`, `Professor`, `Administrador`) e mudar o banco somente onde uma regra confirmada não cabe no modelo atual. Não haverá tabela central `Usuario`.

## 1. Resumo das decisões confirmadas

### 1.1 Usuários e autenticação

- O e-mail normalizado é a identificação de login e deve ser único entre todas as contas, mesmo distribuídas em tabelas diferentes.
- Aluno, professor e administrador autenticam-se pelo mesmo fluxo. O cadastro público cria apenas `Aluno`; `Professor` é criado pela administração.
- As senhas serão armazenadas exclusivamente como hash BCrypt (ou algoritmo de password hashing equivalente). Não existe descriptografia; nenhuma resposta, log ou DTO expõe hash ou senha.
- Os dados atuais de usuários são provisórios e podem ser removidos antes da adoção das novas restrições.
- A autenticação será stateless por JWT. Após login, a API emite token assinado com identidade, tipo de usuário e expiração; o web envia `Authorization: Bearer <token>` nas rotas protegidas.
- Todo PHP em `Tinker/src/backend` e as chamadas diretas a `login.php`, `cadastro.php` e `alterarSuporte.php` serão substituídos futuramente pela API Java; PHP não faz parte da solução-alvo.

### 1.2 Questões, simulados e respostas

- `Questao` mantém `alternativaA` a `alternativaE`. `alternativaE` já é anulável no schema; nenhuma alteração é necessária.
- Cada questão válida terá quatro ou cinco alternativas preenchidas. A API converte as colunas preenchidas no array do web e nunca entrega `resposta` em consultas destinadas à resolução.
- `Questao.resposta` adotará as letras `A`, `B`, `C`, `D` ou `E` como convenção persistida.
- `disciplina`, `conteudo` e `vestibular` continuam texto; não serão criados catálogos nesta versão.
- Alunos e professores podem responder questões e simulados; todo registro de resposta identifica `email_usuario` e `tipo_usuario`.
- Uma resposta avulsa, dada em `/questoes`, pertence ao contexto `AVULSA`. Cada usuário responde cada questão uma única vez nesse contexto; acerto ou erro torna a resposta definitiva.
- Uma resposta de simulado pertence ao contexto `SIMULADO` e ao trio usuário–simulado–questão. A mesma questão pode ser respondida novamente em outro simulado ou em uma cópia, sem que a resposta avulsa ou a de outro simulado a bloqueie.
- A unicidade de resposta será garantida no banco por usuário, tipo, questão e chave de contexto; a API também fará a validação e devolverá conflito sem sobrescrever.
- “Questões feitas” é a contagem de questões distintas respondidas. Simulado concluído só é refeito por uma nova cópia, com novas associações em `Quest_Simu` e sem respostas anteriores.
- O simulado é concluído automaticamente, na mesma transação da última resposta, quando a quantidade de questões distintas respondidas igualar a quantidade de questões associadas. `Simulado.tempo` é medido em minutos.
- Cópias são novos registros de `Simulado`, independentes do original. Editar/excluir/despublicar o original não altera nem apaga cópias já salvas.

### 1.3 Calendário

- O calendário completo do web será persistido em tabela própria. Cada linha de evento é uma ocorrência.
- Uma série agrupa ocorrências diárias, semanais, mensais ou anuais; é possível excluir uma ocorrência ou a série inteira.
- Na primeira versão, uma criação gera no máximo 365 ocorrências diárias, 52 semanais, 12 mensais ou 5 anuais, incluindo a ocorrência inicial.
- Eventos passados permanecem no banco.
- Uma publicação de turma referencia somente uma ocorrência. Ao salvar, cria-se uma ocorrência pessoal independente, sem recorrência; mudanças ou exclusões posteriores no original não se propagam.
- Ao excluir uma cópia salva de simulado ou evento, a API remove também seu registro em `Simulado_Salvo` ou `Evento_Salvo`; a publicação ativa poderá ser salva novamente.

### 1.4 Turmas

- Somente `Professor` cria turma. `Turma.email_prof` identifica o único criador e administrador.
- Aluno e professor podem ser membros. Professor em turma alheia é membro comum, usando sua própria conta, e pode responder e salvar simulados e salvar eventos exatamente como um aluno membro.
- O código público da turma tem exatamente seis caracteres, é único e não deve ser confundido com a chave numérica interna `cod_turma`.
- Somente o professor criador publica/despublica simulados e eventos ou remove membros. Membros podem entrar e sair.
- Despublicar oculta o item de quem não o salvou, preservando as cópias já criadas.

### 1.5 Administrador e itens adiados

- Nesta primeira versão, `Administrador` pode somente autenticar-se e criar contas de professores. Não gerencia turmas, questões, simulados, calendários, perfis de terceiros ou publicações.
- A solução definitiva para armazenamento/entrega de fotos e imagens e o envio do formulário de contato de suporte ficam adiados; isso não bloqueia as migrations nem os demais contratos.

### 1.6 Dados atuais e estratégia de mudança

- Todos os registros atuais são provisórios e podem ser apagados: contas, questões, simulados, relatórios, vínculos e quaisquer outros dados.
- Esta autorização elimina a necessidade de migrations de transformação ou inferência dos dados atuais. A alteração futura ainda deverá ocorrer exclusivamente por migration planejada e versionada; este documento não executa nem cria migrations.

## 2. Tabelas atuais mantidas

| Tabela real | Entidade/repository atual | Destino |
|---|---|---|
| `Aluno` | `Aluno` / `AlunoRepository` | Mantida como conta de aluno; ajustes de senha e comprimento de e-mail. |
| `Professor` | `Professor` / `ProfessorRepository` | Mantida como conta de professor; ajustes de senha e comprimento de e-mail. |
| `Administrador` | `Adm` / `AdmRepository` | Mantida como conta administrativa, com mudança de identificador para e-mail e senha textual com hash. |
| `Questao` | `Questao` / `QuestaoRepository` | Mantida; colunas de alternativas preservadas. |
| `Simulado` | `Simulado` / `SimuladoRepository` | Mantida como original ou cópia independente. |
| `Quest_Simu` | `QuestaoSimu` / `QuestaoSimuRepository` | Mantida como associação própria de cada simulado. |
| `Relatorio` | `Relatorio` / `RelatorioRepository` | Mantida como registro definitivo de resposta, com ampliação da chave. |
| `Turma` | `Turma` / `TurmaRepository` | Mantida, com chave simplificada e código público. |
| `Conteudo_Quest` | `ConteudoQuest` / `ConteudoQuestRepository` | Mantida por compatibilidade, mas não é catálogo obrigatório da v1. |
| `Cronograma` | `Cronograma` / `CronogramaRepository` | Mantida temporariamente; não representa o novo calendário. |
| `HorarioMult` | `HorarioMult` / `HorarioMultRepository` | Mantida temporariamente; não representa o novo calendário. |

As tabelas prefixadas por `Estudio_` não têm entidade na API Tinker e não são usadas pelo web React analisado. Permanecem fora do escopo; não devem receber novas dependências.

## 3. Alterações obrigatórias nas tabelas atuais

### 3.1 Matriz de alterações

| Tabela.coluna | Tipo atual | Tipo proposto / nulabilidade | Chave ou índice | Motivo e dependência | Classe |
|---|---|---|---|---|---|
| `Aluno.email` | `varchar(50) NOT NULL` | `varchar(254) NOT NULL` | PK atual; ver garantia global abaixo | Padronizar identificador e suportar e-mails válidos; autenticação, perfil e ownership. | Obrigatória |
| `Aluno.senha` | `varchar(20) NOT NULL` | `varchar(100) NOT NULL` | — | Um hash BCrypt não cabe em 20 caracteres; login e cadastro. | Obrigatória |
| `Professor.email` | `varchar(50) NOT NULL` | `varchar(254) NOT NULL` | PK atual | Mesmo identificador padronizado; login, turma e ownership. | Obrigatória |
| `Professor.senha` | `varchar(20) NOT NULL` | `varchar(100) NOT NULL` | — | Armazenar password hash; login e criação administrativa. | Obrigatória |
| `Administrador.login` | `varchar(10) NOT NULL` | renomear para `email varchar(254) NOT NULL` | PK | A decisão determina login por e-mail para todos; autenticação administrativa. | Obrigatória |
| `Administrador.senha` | `int NULL` | `varchar(100) NOT NULL` | — | Hash não é inteiro nem opcional; autenticação administrativa. | Obrigatória |
| `Turma` PK | (`cod_turma`,`nome_turma`,`email_prof`) | PK somente (`cod_turma`) | PK; índices/FKs conforme abaixo | O JPA atual (`Turma` com um `@Id`, `TurmaRepository<Turma,Integer>`) já assume chave simples. Corrigir Java para chave composta obrigaria IDs compostos em toda nova FK. Como `cod_turma` é `AUTO_INCREMENT` e já identifica a linha, simplificar a PK reduz a complexidade total e é obrigatória antes das tabelas associativas. | Obrigatória |
| `Turma.email_prof` | `varchar(45) NOT NULL` | `varchar(254) NOT NULL` | índice + FK para `Professor.email` | Criador/administrador único e integridade referencial. | Obrigatória |
| `Turma.codigo` | inexistente | `char(6) NOT NULL` | `UNIQUE` | Código público alfanumérico da turma; entrada por código. | Obrigatória |
| `Aluno_Turma` | tabela atual | substituir por `Turma_Membro` após migração/limpeza dos dados provisórios | — | Não representa professor membro nem papel. | Obrigatória |
| `Relatorio.id_relatorio` | inexistente | `bigint NOT NULL AUTO_INCREMENT` | PK | Substitui a PK atual sem tentar usar coluna gerada como chave primária. | Obrigatória |
| `Relatorio.email_usuario` | `email varchar(45) NOT NULL` | renomear para `email_usuario varchar(254) NOT NULL` | parte do índice único; sem FK polimórfica | Aluno ou professor pode responder; autenticação, progresso e desempenho. | Obrigatória |
| `Relatorio.tipo_usuario` | inexistente | `enum('ALUNO','PROFESSOR') NOT NULL` | parte do índice único | Resolve a tabela da conta sem criar `Usuario`. | Obrigatória |
| `Relatorio.contexto` | inexistente | `enum('AVULSA','SIMULADO') NOT NULL` | `CHECK` coerente com `cod_simulado` | Separa resposta direta da resposta dentro de simulado. | Obrigatória |
| `Relatorio.cod_simulado` | inexistente | `int NULL` | FK para `Simulado.cod_simulado`; índice | Nulo em resposta avulsa e obrigatório no contexto `SIMULADO`. | Obrigatória |
| `Relatorio.chave_contexto` | inexistente | `int GENERATED ALWAYS AS (COALESCE(cod_simulado,0)) STORED` | `UNIQUE(email_usuario,tipo_usuario,cod_quest,chave_contexto)` | MySQL permite vários `NULL` em índice único; a coluna gerada usa 0 para `AVULSA` e o ID real para simulado, garantindo uma resposta por contexto. | Obrigatória |
| `Relatorio.acertou/errou` | `int NOT NULL` | manter `int NOT NULL` inicialmente, aceitando somente 0/1 | `CHECK` recomendado na mesma migration | Preserva banco e registra resultado imutável. | Obrigatória |
| `Relatorio.alternativa_selecionada` | inexistente | `char(1) NOT NULL` | `CHECK IN ('A','B','C','D','E')` | Permite devolver o resultado e auditar sem derivar somente do booleano. | Obrigatória |
| `Questao.resposta` | `mediumtext NOT NULL` | `char(1) NOT NULL` | `CHECK IN ('A','B','C','D','E')` | Convenção inequívoca de gabarito; resposta e correção. | Obrigatória |
| `Simulado.email_aluno` | `varchar(45) NULL` | `varchar(254) NULL` | índice + FK para `Aluno.email` | Proprietário aluno de original/cópia. | Obrigatória |
| `Simulado.email_prof` | `varchar(45) NULL` | `varchar(254) NULL` | índice + FK para `Professor.email` | Proprietário professor. | Obrigatória |
| `Simulado` ownership | duas colunas atuais | manter ambas; exigir exatamente uma preenchida | `CHECK ((email_aluno IS NULL) <> (email_prof IS NULL))` | Evita tabela `Usuario` e define um único dono. API também valida. | Obrigatória |
| `Simulado.tempo` | `float NULL` | `int NULL`, em minutos | `CHECK (tempo IS NULL OR tempo > 0)` | Remove ambiguidade e alinha persistência/DTO à unidade definitiva. | Obrigatória |

### 3.2 Unicidade global de e-mail

MySQL não oferece uma restrição `UNIQUE` declarativa que cubra três tabelas. Como não será criada uma tabela central, a garantia inicial mínima fica na API:

1. um único serviço de criação/alteração de conta normaliza o e-mail e consulta `AlunoRepository`, `ProfessorRepository` e `AdmRepository` antes de inserir; e
2. todos os caminhos de escrita de contas passam por esse serviço e pela mesma transação de aplicação.

A checagem entre tabelas na API não protege contra escrita externa nem elimina completamente uma corrida entre inserções simultâneas em tabelas distintas. Triggers `BEFORE INSERT/UPDATE` seriam a menor garantia estritamente no banco, mas são **opcionais/adiáveis**, não obrigatórias para a primeira integração controlada. Tornam-se obrigatórias somente se houver mais de um escritor, importação direta ou exigência de integridade independente da API. Índices `UNIQUE` continuam obrigatórios dentro de cada tabela.

### 3.3 Questões

`Questao.alternativaE` já é `mediumtext NULL`; nenhuma migration será proposta para ela. A API monta `alternativas` na ordem A–E, omitindo E quando nula. A validação exige A–D não nulas para novas/alteradas questões, embora hoje essas quatro colunas também aceitem `NULL`; torná-las `NOT NULL` no banco é adiável após saneamento.

## 4. Tabelas novas obrigatórias

Os nomes abaixo seguem o padrão nominal do schema existente e resolvem somente as lacunas confirmadas.

### 4.1 `Turma_Membro`

| Coluna | Tipo / nulabilidade | Chave/índice | Uso |
|---|---|---|---|
| `cod_turma` | `int NOT NULL` | PK parcial, FK `Turma.cod_turma`, índice | Turma associada. |
| `email_membro` | `varchar(254) NOT NULL` | PK parcial | Identidade real do membro. |
| `tipo_usuario` | `enum('ALUNO','PROFESSOR') NOT NULL` | PK parcial ou `CHECK` | Indica em qual tabela validar o e-mail. |
| `papel` | `enum('ADMINISTRADOR','MEMBRO') NOT NULL DEFAULT 'MEMBRO'` | `CHECK`/índice | Autorização dentro da turma. |
| `ativo` | `tinyint(1) NOT NULL DEFAULT 1` | índice (`cod_turma`,`ativo`) | Entrada/saída/remoção recuperável. |

PK recomendada: (`cod_turma`,`email_membro`,`tipo_usuario`). Como a unicidade global de e-mail é regra confirmada, (`cod_turma`,`email_membro`) seria suficiente, mas incluir o tipo torna o vínculo autoexplicativo. FKs condicionais por `tipo_usuario` não são possíveis; a API valida a existência e o estado ativo em `Aluno` ou `Professor`. Trigger equivalente é opcional caso futuramente seja necessária proteção contra escritas externas.

O criador também terá uma linha `ADMINISTRADOR`, mas `Turma.email_prof` permanece a fonte autoritativa. O serviço garante: só o criador pode ter papel `ADMINISTRADOR`, exatamente um administrador ativo por turma e nenhum aluno nem professor visitante pode obter esse papel.

### 4.2 `Evento`

Uma tabela separada de séries não é necessária. Cada ocorrência é uma linha de `Evento`; ocorrências da mesma série compartilham `id_serie` e `recorrencia`.

| Coluna | Tipo / nulabilidade | Chave/índice | Uso |
|---|---|---|---|
| `id_evento` | `bigint NOT NULL AUTO_INCREMENT` | PK | Identidade da ocorrência. |
| `email_dono` | `varchar(254) NOT NULL` | índice (`email_dono`,`tipo_dono`,`data`) | Calendário pessoal. |
| `tipo_dono` | `enum('ALUNO','PROFESSOR') NOT NULL` | `CHECK` | Tipo da conta dona. |
| `titulo` | `varchar(150) NOT NULL` | — | Título. |
| `data` | `date NOT NULL` | índice | Data da ocorrência. |
| `horario_inicio` | `time NULL` | — | Nulo quando dia inteiro. |
| `horario_fim` | `time NULL` | — | Nulo quando dia inteiro. |
| `dia_inteiro` | `tinyint(1) NOT NULL DEFAULT 0` | — | Forma de exibição. |
| `cor` | `char(7) NOT NULL` | — | Cor hexadecimal `#RRGGBB`. |
| `id_serie` | `char(36) NULL` | índice (`id_serie`,`ativo`) | UUID compartilhado pelas ocorrências; nulo para evento isolado/cópia publicada. |
| `recorrencia` | `enum('NAO_REPETE','DIARIA','SEMANAL','MENSAL','ANUAL') NOT NULL DEFAULT 'NAO_REPETE'` | — | Frequência que originou a ocorrência. |
| `ativo` | `tinyint(1) NOT NULL DEFAULT 1` | índice com dono/data e série | Permite exclusão lógica de ocorrência ou série. |

Cada repetição é materializada em `Evento`. Excluir uma ocorrência atualiza apenas essa linha para `ativo = 0`; excluir a série atualiza todas as linhas ativas com o mesmo `id_serie`. Cópias publicadas recebem `id_serie = NULL` e `recorrencia = 'NAO_REPETE'`. A API limita cada criação a 365 ocorrências diárias, 52 semanais, 12 mensais ou 5 anuais; essa regra não exige coluna adicional.

### 4.3 Publicações e controles de salvamento

`Turma_Simulado`:

| Coluna | Tipo / nulabilidade | Chave/índice |
|---|---|---|
| `id_publicacao_simulado` | `bigint NOT NULL AUTO_INCREMENT` | PK |
| `cod_turma` | `int NOT NULL` | FK `Turma.cod_turma`, índice |
| `cod_simulado` | `int NOT NULL` | FK `Simulado.cod_simulado`, índice |
| `data_publicacao` | `datetime NOT NULL DEFAULT CURRENT_TIMESTAMP` | — |
| `ativo` | `tinyint(1) NOT NULL DEFAULT 1` | índice (`cod_turma`,`ativo`) |

Restrição `UNIQUE(cod_turma,cod_simulado)`; republicar reativa a mesma publicação. Não armazena título, questões nem dono.

`Simulado_Salvo`:

| Coluna | Tipo / nulabilidade | Chave/índice |
|---|---|---|
| `email_membro` | `varchar(254) NOT NULL` | PK parcial |
| `tipo_usuario` | `enum('ALUNO','PROFESSOR') NOT NULL` | PK parcial |
| `id_publicacao_simulado` | `bigint NOT NULL` | PK parcial, FK `Turma_Simulado` |
| `cod_simulado_copia` | `int NOT NULL` | `UNIQUE`, FK `Simulado.cod_simulado` |
| `data_salvamento` | `datetime NOT NULL DEFAULT CURRENT_TIMESTAMP` | — |

PK (`email_membro`,`tipo_usuario`,`id_publicacao_simulado`) impede salvamento repetido para aluno ou professor e liga publicação à cópia. A transação cria a cópia de `Simulado`, preenche o campo de dono correspondente ao tipo, copia suas linhas de `Quest_Simu` e só então cria o controle.

`Turma_Evento`:

| Coluna | Tipo / nulabilidade | Chave/índice |
|---|---|---|
| `id_publicacao_evento` | `bigint NOT NULL AUTO_INCREMENT` | PK |
| `cod_turma` | `int NOT NULL` | FK `Turma.cod_turma`, índice |
| `id_evento` | `bigint NOT NULL` | FK `Evento.id_evento`, índice |
| `data_publicacao` | `datetime NOT NULL DEFAULT CURRENT_TIMESTAMP` | — |
| `ativo` | `tinyint(1) NOT NULL DEFAULT 1` | índice (`cod_turma`,`ativo`) |

Restrição `UNIQUE(cod_turma,id_evento)`. `id_evento` é uma ocorrência, nunca a série.

`Evento_Salvo`:

| Coluna | Tipo / nulabilidade | Chave/índice |
|---|---|---|
| `email_membro` | `varchar(254) NOT NULL` | PK parcial |
| `tipo_usuario` | `enum('ALUNO','PROFESSOR') NOT NULL` | PK parcial |
| `id_publicacao_evento` | `bigint NOT NULL` | PK parcial, FK `Turma_Evento` |
| `id_evento_copia` | `bigint NOT NULL` | `UNIQUE`, FK `Evento.id_evento` |
| `data_salvamento` | `datetime NOT NULL DEFAULT CURRENT_TIMESTAMP` | — |

PK (`email_membro`,`tipo_usuario`,`id_publicacao_evento`) impede salvamento repetido. A cópia em `Evento` recebe dados atuais da ocorrência, novo dono, `id_serie = NULL` e nenhuma ligação de atualização com o original.

## 5. Alterações recomendadas, mas adiáveis

| Mudança | Motivo | Dependência |
|---|---|---|
| Renomear `Relatorio.acertou/errou` para `acertou` e usar `tinyint(1)` | A barra exige escaping em SQL/JPA e dificulta manutenção. | Pode ser feito depois com mapeamento `@Column`. |
| Tornar `Questao.alternativaA`–`alternativaD` `NOT NULL` | Reforça quatro alternativas mínimas no banco. | Requer saneamento prévio; API já deve validar. |
| Criar `Simulado.data_criacao datetime` | O web exibe `dataCriacao`; evita derivação inexistente. | Contrato pode temporariamente omitir/derivar. |
| Criar `Simulado.ativo tinyint(1)` | Permitiria inativação, consistente com outras entidades. | Até lá, exclusão é real. |
| Normalizar `ativo` existentes para `tinyint(1)` com `CHECK` | Clareza sem mudar semântica. | Não bloqueia a integração. |
| Remover `Cronograma`, `HorarioMult`, `Conteudo_Quest` e tabelas `Estudio_*` sem uso comprovado | Reduz legado. | Somente após auditoria de consumidores externos. |
| Versionar API sob `/api/v1` | Facilita evolução. | Pode começar com rotas atuais. |

## 6. Estruturas que não serão criadas

- Tabela central `Usuario`.
- Tabelas de catálogo para disciplina, conteúdo, vestibular/instituição ou ano.
- Tabela de alternativas; as cinco colunas de `Questao` permanecem.
- Tabela `Evento_Serie`; `Evento.id_serie` agrupa as ocorrências diretamente.
- Cópias completas dentro de `Turma_Simulado`, `Simulado_Salvo`, `Turma_Evento` ou `Evento_Salvo`.
- Coluna obrigatória de origem dentro de `Simulado`; `Simulado_Salvo` mantém o controle de origem/cópia.
- Segunda conta de aluno para professor membro.
- Sincronização entre original e cópia de simulado/evento.
- Persistência nova baseada em `Cronograma`/`HorarioMult` para o calendário completo.
- Qualquer fluxo PHP.

## 7. Autenticação e autorização

### 7.1 Autenticação

1. Normalizar e-mail com `trim` e lowercase em todas as entradas; a comparação deve usar a mesma regra/collation.
2. `POST /api/auth/login` procura, nessa transação lógica, uma conta ativa nas três tabelas e compara a senha com BCrypt.
3. A resposta contém o JWT, `email`, `nome`, `sobrenome` quando existir, `tipoUsuario` e expiração; nunca contém `senha`.
4. Endpoints autenticados retiram o e-mail e tipo do principal/token, nunca de um campo de ownership enviado pelo cliente.
5. Resposta de login inválido é sempre genérica (`401`), sem revelar se o e-mail existe ou em qual tabela.
6. Cadastro público verifica unicidade global, gera hash e insere somente em `Aluno`.

O JWT deve ser assinado com segredo/chave mantido fora do repositório, ter expiração validada no servidor e carregar somente claims mínimos (`sub` com e-mail, `tipoUsuario`, emissão e expiração). A duração, eventual refresh token e estratégia de revogação são configurações de segurança da implementação, não decisões bloqueantes de banco. Senha/hash deve ter `@JsonIgnore` provisoriamente e, na implementação correta, entities nunca devem ser retornadas diretamente; usar DTOs.

### 7.2 Matriz de autorização

| Ação | Aluno | Professor membro | Professor criador | Administrador |
|---|---:|---:|---:|---:|
| Login e perfil próprio | Sim | Sim | Sim | Somente login na v1 |
| Cadastro público de aluno | Público | — | — | — |
| Criar professor | Não | Não | Não | Sim |
| Criar turma | Não | Sim | Sim | Não |
| Entrar/sair de turma | Sim | Sim | Sim, mas não pode abandonar enquanto criador ativo | — |
| Listar conteúdo da turma | Se membro ativo | Se membro ativo | Sim | Não |
| Remover membro/publicar/despublicar | Não | Não | Sim | Não |
| Gerenciar questões globais | Não | Não por padrão | Não por padrão | Não na v1 |
| Responder questão avulsa ou de simulado próprio/salvo | Sim | Sim | Sim | Não |
| Gerenciar calendário próprio | Sim | Sim | Sim | Não |

## 8. Contrato de cada página do web com a API

| Rota/página real | Operações necessárias | Resultado principal |
|---|---|---|
| `/` (`Introducao`) | Nenhuma obrigatória | Conteúdo estático. |
| `/login` (`Login`) | login | `AuthResponseDTO`; remover `login.php`. |
| `/cadastro` (`Cadastro`) | cadastro público de aluno | `UsuarioResumoDTO`; remover `cadastro.php`. Nascimento é obrigatório no schema e precisa entrar no formulário ou tornar-se decisão de banco. |
| `/planos` (`Planos`) | Nenhuma na v1 | Conteúdo estático. |
| `/home` (`Home`) | resumo do usuário/desempenho | Cards e atalhos; pode compor endpoints existentes. |
| `/questoes` (`Questoes`) | busca paginada/filtros; responder avulsa uma vez; listar simulados; adicionar/remover questão de simulados | `PaginaQuestaoDTO`, `RespostaResultadoDTO` com contexto `AVULSA` e resumos de simulado. A API persiste em `Relatorio` com `cod_simulado = NULL`. |
| `/simulados` (`Simulados`) | listar, criar vazio, gerar por filtros, renomear, excluir | `SimuladoResumoDTO`. |
| `/simulados/:simuladoId` (`DetalhesSimulado`) | obter simulado, listar questões sem gabarito, responder uma vez | `SimuladoDetalheDTO`, `QuestaoDTO`, `RespostaResultadoDTO`. |
| `/desempenho` (`Desempenho`) | agregados das respostas avulsas e de simulados do usuário | `DesempenhoResumoDTO`, disponível a aluno e professor. |
| `/calendario` (`Calendario`) | listar, criar ocorrências/série, obter, excluir ocorrência ou série | Eventos no formato de calendário usado pelo web. |
| `/turma` (`Turma`) | listar minhas turmas, criar (professor), entrar por código | `TurmaResumoDTO`. |
| `/turma/:turmaId` e abas `/simulados`, `/eventos`, `/membros` (`DetalhesTurma`) | detalhe/papel, membros, publicações, publicar/despublicar, salvar cópia, sair/remover | DTOs de turma e publicação com `salvoPeloUsuario`. |
| `/suporte` (`Suporte`) | consultar/alterar perfil e senha próprios | DTO de perfil; remover `alterarSuporte.php`. O envio do formulário de contato fica fora da primeira integração e permanece sem endpoint. |

## 9. Inventário dos endpoints existentes aproveitáveis

A API atual não possui camada de service nem segurança e devolve entities diretamente; “aproveitável” significa reaproveitar entity/repository, parte da rota ou lógica CRUD após aplicar DTO, autorização, validação e proteção de senha.

| Controller / repository | Endpoints atuais | Aproveitamento e correções mínimas |
|---|---|---|
| `LoginController` / `AlunoRepository` | `POST /api/login` | Base parcial. Hoje só autentica aluno e compara texto puro. Substituir pelo fluxo unificado `/api/auth/login`. |
| `AlunoController` / `AlunoRepository` | `GET/POST /api/aluno`, `GET/PUT/DELETE /api/aluno/{email}` | Repository aproveitável. Restringir listagem/criação, usar DTO, hash e inativação; nunca devolver entity/senha. |
| `ProfessorController` / `ProfessorRepository` | CRUD equivalente em `/api/professor` | Repository aproveitável; criação apenas admin e exclusão por inativação. |
| `AdmController` / `AdmRepository` | CRUD em `/api/adm` | Somente repository/autenticação são aproveitáveis. Não expor CRUD administrativo genérico; na v1, admin apenas autentica e usa `POST /api/admin/professores`. |
| `QuestaoController` / `QuestaoRepository` | CRUD em `/api/questao` | Busca por ID e persistência aproveitáveis. GET público autenticado deve omitir gabarito; DELETE vira `ativo=0`. |
| `SimuladoController` / `SimuladoRepository` | CRUD em `/api/simulado` | Base CRUD aproveitável, mas filtrar por dono autenticado e preencher métricas via `Relatorio`. |
| `QuestaoSimuController` / `QuestaoSimuRepository` | `GET /api/questao-simu`, `GET .../simulado/{codSimulado}`, `POST`, `DELETE /{codSimulado}/{codQuestao}` | `findByCodSimulado` e associação composta são diretamente aproveitáveis após autorização. |
| `RelatorioController` / `RelatorioRepository` | CRUD `/api/relatorio` por (`codQuest`,`email`) | Estrutura parcial; ID deve incorporar usuário tipado e contexto avulso/simulado. PUT/DELETE comuns devem ser removidos para garantir imutabilidade. |
| `TurmaController` / `TurmaRepository` | CRUD `/api/turma` por `Integer` | Alinha-se ao banco somente após simplificar a PK. Acrescentar código, filtros por membro e autorização. |
| `AlunoTurmaController` / `AlunoTurmaRepository` | CRUD `/api/aluno-turma` | Não atende professor membro; será substituído por `TurmaMembro`/repository/controller. |
| `CronogramaController` / `CronogramaRepository` | CRUD `/api/cronograma` | Não atende título, horários, cor, recorrência ou múltiplos eventos/dia; não usar no calendário novo. |
| `HorarioMultController` / `HorarioMultRepository` | CRUD `/api/horario-mult` | Não atende séries/publicações e possui tipos incompatíveis (`float`/`varchar` para horários); não usar no calendário novo. |
| `ConteudoQuestController` / `ConteudoQuestRepository` | CRUD `/api/conteudo-quest` | Pode permanecer, mas o filtro v1 usa diretamente o texto de `Questao.conteudo`. |

Todos os `GET` de coleção atuais são irrestritos e todos os `DELETE` são físicos; não devem ser expostos assim na integração.

## 10. Endpoints a criar ou corrigir

### 10.1 Autenticação, conta, questões e desempenho

| HTTP / rota sugerida | Acesso | Entrada → saída | Tabelas | Atual |
|---|---|---|---|---|
| `POST /api/auth/login` | Público | `LoginRequestDTO` → `AuthResponseDTO` | `Aluno`, `Professor`, `Administrador` | Corrigir `/api/login`; só aluno/texto puro hoje. |
| `POST /api/auth/cadastro/aluno` | Público | `CadastroAlunoRequestDTO` → `UsuarioResumoDTO` | `Aluno` + checagem nas 3 contas | Adaptar POST `/api/aluno`; hoje expõe entity. |
| `POST /api/admin/professores` | Administrador | `CadastroProfessorRequestDTO` → `UsuarioResumoDTO` | `Professor` + checagem global | Adaptar POST `/api/professor`. |
| `GET /api/me` | Aluno/professor | — → `UsuarioPerfilDTO` | tabela da conta | Criar. Admin recebe sua identidade somente no login. |
| `PUT /api/me` | Aluno/professor | `AtualizarPerfilDTO` → `UsuarioPerfilDTO` | tabela da conta | Corrigir PUTs por e-mail. |
| `PUT /api/me/senha` | Aluno/professor | `AlterarSenhaDTO` → 204 | tabela da conta | Criar; substitui fluxo de suporte/PHP. |
| `DELETE /api/me` | Aluno/professor | — → 204 | tabela da conta | Corrigir DELETE para `ativo=0` quando disponível. |
| `GET /api/questoes` | Autenticado | query filtros/página/tamanho → `PaginaQuestaoDTO` | `Questao`, opcional `Quest_Simu` | Corrigir GET `/api/questao`; omitir gabarito. |
| `GET /api/questoes/{id}` | Autenticado | — → `QuestaoDTO` sem gabarito | `Questao` | Adaptar GET atual. |
| `POST /api/questoes/{id}/resposta` | Aluno/professor | `RespostaRequestDTO` sem contexto enviado → `RespostaResultadoDTO` | `Questao`, `Relatorio` | Criar para contexto `AVULSA`; usuário vem da autenticação. |
| `POST /api/simulados/{id}/respostas` | Aluno/professor dono da instância | `RespostaRequestDTO` → `RespostaResultadoDTO` | `Simulado`, `Quest_Simu`, `Questao`, `Relatorio` | Corrigir POST `/api/relatorio`; contexto `SIMULADO`, transação e conflito 409. |
| `GET /api/me/desempenho` | Aluno/professor | filtros opcionais de contexto → `DesempenhoResumoDTO` | `Relatorio`, `Questao`, `Simulado` | Criar. |

### 10.2 Simulados

| HTTP / rota sugerida | Acesso | Entrada → saída | Tabelas | Atual |
|---|---|---|---|---|
| `GET /api/simulados` | Aluno/professor | filtros do dono → lista `SimuladoResumoDTO` | `Simulado`, `Quest_Simu`, `Relatorio` | Corrigir GET `/api/simulado`. |
| `POST /api/simulados` | Aluno/professor | `CriarSimuladoDTO` → `SimuladoResumoDTO` | `Simulado` | Adaptar POST atual. |
| `POST /api/simulados/gerar` | Aluno/professor | `GerarSimuladoDTO` → resumo | `Questao`, `Simulado`, `Quest_Simu` | Criar. |
| `GET /api/simulados/{id}` | Dono | — → `SimuladoDetalheDTO` | `Simulado`, `Quest_Simu`, `Relatorio` | Adaptar GET atual. |
| `GET /api/simulados/{id}/questoes` | Dono | — → lista `QuestaoDTO` | `Quest_Simu`, `Questao`, `Relatorio` | Adaptar `GET /api/questao-simu/simulado/{id}` e buscar questões. |
| `PATCH /api/simulados/{id}` | Dono; não concluído conforme campos | `RenomearSimuladoDTO` → resumo | `Simulado` | Corrigir PUT atual. |
| `PUT /api/simulados/{id}/questoes` | Dono; não concluído | `QuestaoIdsDTO` → 204/lista IDs | `Quest_Simu` | Compor POST/DELETE atuais em transação. |
| `DELETE /api/simulados/{id}` | Dono | — → 204 | `Simulado`, `Quest_Simu`, `Relatorio`, `Simulado_Salvo` | Exclusão real enquanto não houver `ativo`; se for cópia salva, remove antes o vínculo para permitir novo salvamento. Não afeta outras cópias. |

### 10.3 Turmas e publicações

| HTTP / rota sugerida | Acesso | Entrada → saída | Tabelas | Atual |
|---|---|---|---|---|
| `GET /api/turmas` | Autenticado | — → lista `TurmaResumoDTO` | `Turma`, `Turma_Membro` | Corrigir GET `/api/turma`. |
| `POST /api/turmas` | Professor | `CriarTurmaDTO` → resumo | `Turma`, `Turma_Membro` | Adaptar POST atual; gera código 6 chars. |
| `POST /api/turmas/entrar` | Aluno/professor | `EntrarTurmaDTO` → resumo | `Turma`, `Turma_Membro` | Criar. |
| `GET /api/turmas/{id}` | Membro ativo | — → `TurmaDetalheDTO` | `Turma`, `Turma_Membro` | Adaptar GET atual. |
| `GET /api/turmas/{id}/membros` | Membro ativo | — → lista `MembroTurmaDTO` | `Turma_Membro`, contas | Substituir `AlunoTurmaController`. |
| `DELETE /api/turmas/{id}/membros/me` | Membro não criador | — → 204 | `Turma_Membro` | Criar; `ativo=0`. |
| `DELETE /api/turmas/{id}/membros/{tipo}/{email}` | Professor criador | — → 204 | `Turma`, `Turma_Membro` | Criar; `ativo=0`. |
| `DELETE /api/turmas/{id}` | Professor criador | — → 204 | `Turma` | Corrigir DELETE: `ativo=0`. |
| `GET /api/turmas/{id}/simulados` | Membro ativo | — → lista `PublicacaoSimuladoDTO` | `Turma_Simulado`, `Simulado`, `Simulado_Salvo` | Criar. |
| `POST /api/turmas/{id}/simulados` | Professor criador | `PublicarSimuladoDTO` → publicação | `Turma`, `Simulado`, `Turma_Simulado` | Criar. |
| `DELETE /api/turmas/{id}/simulados/{publicacaoId}` | Professor criador | — → 204 | `Turma_Simulado` | Criar; `ativo=0`. |
| `POST /api/publicacoes-simulado/{id}/salvar` | Aluno/professor membro | — → `SalvarSimuladoDTO` | publicação, `Simulado`, `Quest_Simu`, `Simulado_Salvo` | Criar; transacional e idempotente. |
| `GET /api/turmas/{id}/eventos` | Membro ativo | — → lista `PublicacaoEventoDTO` | `Turma_Evento`, `Evento`, `Evento_Salvo` | Criar. |
| `POST /api/turmas/{id}/eventos` | Professor criador | `PublicarEventoDTO` → publicação | `Turma`, `Evento`, `Turma_Evento` | Criar; valida dono e ocorrência. |
| `DELETE /api/turmas/{id}/eventos/{publicacaoId}` | Professor criador | — → 204 | `Turma_Evento` | Criar; `ativo=0`. |
| `POST /api/publicacoes-evento/{id}/salvar` | Membro ativo | — → `SalvarEventoDTO` | publicação, `Evento`, `Evento_Salvo` | Criar; cópia isolada e idempotente. |

### 10.4 Calendário

| HTTP / rota sugerida | Acesso | Entrada → saída | Tabelas | Atual |
|---|---|---|---|---|
| `GET /api/eventos?inicio=&fim=` | Autenticado | intervalo → lista `EventoCalendarioDTO` | `Evento` | Criar; controllers legados não atendem. |
| `POST /api/eventos` | Autenticado | `CriarEventoDTO` → lista de ocorrências | `Evento` | Criar transacionalmente; uma série compartilha UUID. |
| `GET /api/eventos/{id}` | Dono | — → `EventoDetalheDTO` | `Evento` | Criar. |
| `DELETE /api/eventos/{id}` | Dono | — → 204 | `Evento`, `Evento_Salvo` | Criar; remove o vínculo se for cópia salva e aplica `ativo=0`, permitindo salvar novamente. |
| `DELETE /api/eventos/series/{idSerie}` | Dono | — → 204 | `Evento` | Criar; `ativo=0` em todas as ocorrências da série. |

## 11. DTOs esperados

Campos de saída usam os nomes já consumidos pelo web sempre que possível.

```text
LoginRequestDTO { email, senha }
AuthResponseDTO { token, tipo: "Bearer", expiraEm, usuario: { email, nome, sobrenome, tipoUsuario } }
CadastroAlunoRequestDTO { nome, sobrenome, email, senha, nascimento }
CadastroProfessorRequestDTO { nome, sobrenome, email, senha }
UsuarioResumoDTO { email, nome, sobrenome, tipoUsuario }
UsuarioPerfilDTO { email, nome, sobrenome, nascimento?, fotoUrl?, tipoUsuario, ativo }
AtualizarPerfilDTO { nome, sobrenome, nascimento?, foto? }
AlterarSenhaDTO { senhaAtual, novaSenha }

QuestaoDTO {
  id, vestibular, instituicao, ano, fase, disciplina, conteudo,
  enunciado, imagemUrl?, alternativas: [{ id: "A"|"B"|"C"|"D"|"E", texto }],
  respondida?, alternativaSelecionadaId?, simuladosIds?
}
PaginaQuestaoDTO { itens: [QuestaoDTO], temMais, total, pagina, tamanho }
RespostaRequestDTO { questaoId, alternativaSelecionadaId }
RespostaResultadoDTO {
  questaoId, contexto: "AVULSA"|"SIMULADO", simuladoId?,
  alternativaSelecionadaId, alternativaCorretaId, correta, bloqueada: true
}

CriarSimuladoDTO { titulo, descricao?, tempoMinutos? }
GerarSimuladoDTO { titulo, descricao?, tempoMinutos?, filtros, quantidadeQuestoes }
QuestaoIdsDTO { questoesIds: [integer] }
SimuladoResumoDTO {
  id, titulo, descricao?, dataCriacao?, quantidadeQuestoes,
  respondidas, acertos, status: "nao_iniciado"|"em_andamento"|"concluido"
}
SimuladoDetalheDTO { ...SimuladoResumoDTO, tempoMinutos?, conclusao }

CriarTurmaDTO { nome }
EntrarTurmaDTO { codigo }
TurmaResumoDTO { id, nome, codigo, criador, quantidadeAlunos, imagem?, cor? }
TurmaDetalheDTO { ...TurmaResumoDTO, papelUsuario, usuarioAdministrador }
MembroTurmaDTO { email, nome, tipoUsuario, papel, fotoPerfil?, ativo }
PublicarSimuladoDTO { simuladoId }
PublicacaoSimuladoDTO {
  idPublicacao, simuladoId, titulo, dataPublicacao, quantidadeQuestoes, salvoPeloUsuario
}
SalvarSimuladoDTO { sucesso, simuladoPessoalId, jaAdicionado }
PublicarEventoDTO { eventoId }
PublicacaoEventoDTO {
  idPublicacao, eventoId, titulo, data, diaInteiro, horaInicio?, horaFim?,
  cor, dataPublicacao, serieId?, salvoPeloUsuario
}
SalvarEventoDTO { criado, eventoJaExistia, eventoPessoalId }

CriarEventoDTO {
  titulo, data, horarioInicio?, horarioFim?, diaInteiro,
  cor, recorrencia: "NAO_REPETE"|"DIARIA"|"SEMANAL"|"MENSAL"|"ANUAL"
}
EventoCalendarioDTO {
  id, title, start, end?, allDay, color,
  extendedProps: { serieId?, recorrencia, data, horarioInicio?, horarioFim? }
}

DesempenhoResumoDTO {
  taxaAcertosGeral, mensagemTaxaGeral, materiaMaiorAcerto?, materiaMenorAcerto?,
  questoesRespondidas, questoesAvulsasRespondidas, questoesEmSimuladosRespondidas,
  simuladosFeitos,
  disciplinas: [{ id?, nome, porcentagemAcertos, acertos, questoesFeitas, possuiRespostas }]
}
ErroDTO { codigo, mensagem, campos? }
```

`alternativaCorretaId` aparece somente após a gravação bem-sucedida da resposta ou em endpoints administrativos. `QuestaoDTO` comum nunca contém gabarito nem a coluna `resposta`.

## 12. Regras de validação

### Contas

- E-mail obrigatório, normalizado, formato válido, até 254 caracteres e único globalmente.
- Senha recebida somente em TLS e armazenada como hash BCrypt, nunca texto. Os parâmetros da política mínima serão configuração de segurança antes da implementação e não afetam a migration.
- `nome`/`sobrenome` respeitam os comprimentos reais até que migrations de ampliação sejam propostas.
- Cadastro público rejeita qualquer `tipoUsuario` enviado e sempre cria aluno.
- Conta com `ativo = 0` não autentica.

### Questões

- `alternativaA`–`D` preenchidas; E opcional. Não aceitar lacuna antes de uma alternativa posterior.
- `resposta` é letra maiúscula e aponta para alternativa preenchida.
- `ano`, `vestibular`, `disciplina`, `conteudo` e enunciado respeitam nulabilidade/comprimentos do schema.
- Consultas comuns filtram `Questao.ativo = 1`.

### Simulados e respostas

- Título obrigatório e até 20 caracteres enquanto `Simulado.nome` não for ampliado; descrição até 300.
- Quantidade para geração: inteiro de 1 a 200 e não maior que o número de questões encontradas.
- Questão adicionada precisa existir, estar ativa e não estar repetida no mesmo `Quest_Simu`.
- Somente o dono altera/exclui/lista conteúdo privado.
- Resposta avulsa exige aluno ou professor ativo, questão ativa e alternativa existente; o servidor fixa `contexto = AVULSA` e `cod_simulado = NULL`.
- Resposta de simulado exige aluno ou professor dono daquela instância, simulado não concluído, questão associada e alternativa existente; o servidor fixa `contexto = SIMULADO` e o ID da rota como `cod_simulado`.
- O insert em `Relatorio` é único por (`email_usuario`,`tipo_usuario`,`cod_quest`,`chave_contexto`) e imutável. Repetição no mesmo contexto retorna `409 RESPOSTA_JA_REGISTRADA`, nunca sobrescreve; contextos diferentes não colidem.
- O servidor calcula `acertou/errou`; o cliente não envia esse valor.
- Após cada resposta de simulado, a API conta respostas distintas daquele usuário/contexto. Ao atingir a quantidade de linhas de `Quest_Simu`, atualiza `Simulado.conclusao = 1` na mesma transação. Depois disso, associações e respostas não mudam.
- `tempoMinutos`, quando informado, é inteiro positivo e persiste em `Simulado.tempo` já migrado para `int`; nenhum contrato usa segundos.

### Turmas/publicações

- `codigo` exatamente seis caracteres `[A-Z0-9]`, gerado com aleatoriedade segura e tentativa novamente em colisão do índice único.
- Só professor ativo cria; o serviço grava `Turma` e sua associação administradora na mesma transação.
- Entrada exige turma ativa e cria/reativa membro; duplicata ativa retorna conflito amigável.
- Criador não pode sair/remover a si próprio enquanto a turma existir.
- Publicação exige que o criador seja dono do simulado/evento e que a ocorrência exista.
- Salvar exige aluno ou professor membro ativo e publicação ativa no instante da primeira gravação. Repetição é idempotente e retorna a cópia já vinculada.

### Eventos

- Título e data obrigatórios; cor no formato `#RRGGBB`.
- Dia inteiro exige horários nulos. Evento com horário exige ambos e `fim > início`.
- Criar evento no passado permanece proibido conforme o web atual; eventos já passados continuam armazenados.
- Recorrência materializa no máximo 365 ocorrências `DIARIA`, 52 `SEMANAL`, 12 `MENSAL` ou 5 `ANUAL`, incluindo a primeira. `NAO_REPETE` gera uma ocorrência. Cópia de ocorrência publicada não pertence à série.
- Todas as consultas/remoções conferem dono pelo principal autenticado.

Erros recomendados: `400` validação, `401` não autenticado, `403` sem papel, `404` recurso inexistente ou de outro dono quando necessário evitar enumeração, `409` duplicidade/estado definitivo e `422` regra semântica opcionalmente.

## 13. Exclusão e inativação

| Entidade/tabela | Comportamento definitivo nesta versão |
|---|---|
| `Aluno`, `Professor` | `ativo = 0`; não apagar. Preserva autoria, respostas e vínculos. |
| `Administrador` | Exclusão real hoje por falta de `ativo`; adicionar `ativo` é recomendação aberta/adiável. |
| `Questao` | `ativo = 0`; não apagar. Preserva simulados e relatórios. |
| `Turma` | `ativo = 0`; publicações ficam inativas/invisíveis. Cópias permanecem. |
| `Turma_Membro` | `ativo = 0` ao sair/remover; reentrada reativa a linha. |
| `Turma_Simulado`, `Turma_Evento` | `ativo = 0` ao despublicar; controles e cópias não são apagados. |
| `Simulado_Salvo`, `Evento_Salvo` | Não apagar ao despublicar. Quando o dono excluir a cópia, remover obrigatoriamente o controle na mesma transação; se a publicação continuar ativa, o usuário poderá salvá-la novamente. |
| `Evento` | `ativo = 0`. Uma ocorrência atualiza uma linha; uma série atualiza todas as linhas do mesmo `id_serie`. Publicações e cópias permanecem independentes. |
| `Simulado` | Exclusão real porque não há `ativo`; somente o próprio registro e suas `Quest_Simu`/respostas. Nunca apagar cópias independentes. |
| `Relatorio` | Sem endpoint de exclusão/edição para usuário; registro definitivo. Exclusão apenas administrativa excepcional e auditada. |
| `Quest_Simu` | Exclusão real somente enquanto o simulado não foi iniciado/concluído. |
| `Cronograma`, `HorarioMult`, `Conteudo_Quest`, `Estudio_*` | Sem mudança nesta etapa; comportamento legado fora do contrato novo. |

## 14. Ordem das futuras migrations

1. Backup técnico se desejado e remoção planejada de todos os registros provisórios, respeitando a ordem de FKs; não tentar inferir ou transformar respostas/vínculos legados.
2. Padronizar e-mails e senhas de `Aluno`, `Professor` e `Administrador`; migrar `login` administrativo para `email`.
3. Criar índices auxiliares e `UNIQUE` de e-mail dentro de cada tabela. Triggers entre tabelas ficam fora da migration mínima e podem ser adicionadas depois se houver escritores externos.
4. Simplificar a PK de `Turma` para `cod_turma`; acrescentar `codigo char(6) UNIQUE`; alinhar comprimentos e FKs de criador.
5. Após apagar os vínculos provisórios, criar `Turma_Membro` e aposentar `Aluno_Turma`; novas turmas passarão a criar a associação do professor criador na mesma transação.
6. Padronizar `Questao.resposta` para A–E, validar alternativas e aplicar tipo/check.
7. Alterar `Relatorio`: renomear e ampliar e-mail, acrescentar `tipo_usuario`, `contexto`, `cod_simulado` anulável, `chave_contexto` gerada e `alternativa_selecionada`; reconstruir chave/índices/FKs após apagar dados provisórios.
8. Ajustar comprimentos/FKs/check de ownership em `Simulado` e confirmar integridade de `Quest_Simu`.
9. Criar somente `Evento`, incluindo `id_serie`, `recorrencia` e `ativo`.
10. Criar `Turma_Simulado` e `Simulado_Salvo`.
11. Criar `Turma_Evento` e `Evento_Salvo`.
12. Aplicar mudanças adiáveis escolhidas, atualizar estatísticas e validar todas as constraints em ambiente de teste.

Cada passo deve ter migration versionada e reversão/backup planejado. Nenhuma migration é criada por este documento.

## 15. Ordem de implementação da API

1. Introduzir DTOs, mapeadores, tratamento uniforme de erros e impedir serialização de senhas nas rotas existentes.
2. Implementar segurança, BCrypt, principal com `email/tipoUsuario`, CORS restrito e autenticação dos três tipos.
3. Implementar serviço transacional de contas e unicidade global; cadastro público e criação administrativa de professor.
4. Alinhar entidades/IDs após migrations (`Adm`, `Turma`, `Relatorio`) e acrescentar repositories das tabelas novas.
5. Implementar consulta segura de questões e transformação de alternativas. CRUD administrativo de questões não integra a v1, pois o administrador só cria professores; carga inicial de questões será tratada como dado de implantação separado.
6. Implementar simulados e `Quest_Simu` com ownership; depois resposta imutável contextualizada por simulado e desempenho agregado.
7. Implementar turmas/membros e matriz de autorização.
8. Implementar publicação/salvamento transacional de simulados.
9. Implementar eventos, séries e exclusões.
10. Implementar publicação/salvamento transacional de eventos.
11. Implementar perfil/suporte, testes de autorização, concorrência/idempotência e testes de contrato com o web.
12. Depreciar/desabilitar endpoints CRUD inseguros antigos após migrar todos os consumidores.

## 16. Ordem de integração das páginas do web

1. Criar cliente HTTP comum, configuração de base URL, armazenamento/envio do JWT, interceptação de `401` e formato de erro.
2. `/login`, `/cadastro`, proteção do `LayoutPrivado` e logout; remover chamadas PHP dessas páginas.
3. `/suporte`/perfil; remover `alterarSuporte.php` e garantir que senha não trafegue em DTO de perfil.
4. `/questoes`, primeiro leitura/filtros/paginação e associação com simulados.
5. `/simulados` e `/simulados/:simuladoId`, incluindo resposta definitiva e estados 409.
6. `/desempenho` e cards de `/home`, agora derivados de respostas reais.
7. `/turma` e detalhe/membros com papéis reais.
8. Aba de simulados da turma, publicar/despublicar/salvar cópia.
9. `/calendario`, criação e exclusão de ocorrência/série.
10. Aba de eventos da turma, publicar ocorrência/despublicar/salvar cópia.
11. Remover dados simulados e, ao final, remover todo `Tinker/src/backend` e referências PHP.

## 17. Consolidação final

### 17.1 Decisões já fechadas

- Contas continuam separadas; e-mail é o login e não pode aparecer em mais de um tipo de conta.
- Cadastro público cria somente aluno; professor é cadastrado administrativamente; os três tipos fazem login.
- Autenticação usa JWT; o administrador, na v1, somente autentica e cria contas de professores.
- Todos os dados atuais são provisórios e podem ser apagados antes das migrations estruturais.
- Alunos e professores respondem questões avulsas e simulados, têm desempenho e podem possuir cópias.
- Resposta avulsa é definitiva por usuário e questão; resposta de simulado é definitiva por usuário, simulado e questão. Um contexto não bloqueia outro.
- Simulado conclui automaticamente após a última questão respondida e mede `tempo` em minutos.
- Professor visitante é membro comum. Só `Turma.email_prof`, o criador, administra a turma e publica/despublica.
- Cópias salvas são independentes dos originais e sobrevivem à despublicação.
- Uma ocorrência de evento é uma linha; séries usam `Evento.id_serie`; ocorrência e série são excluídas logicamente.
- Recorrências geram no máximo 365 ocorrências diárias, 52 semanais, 12 mensais ou 5 anuais.
- Excluir cópia salva remove seu vínculo de salvamento e permite salvar novamente enquanto a publicação estiver ativa.
- A estrutura só será alterada futuramente por migrations planejadas. Esta etapa é exclusivamente documental.

### 17.2 Alterações obrigatórias no banco

- Ampliar e uniformizar os campos de e-mail; ampliar senhas para hash e adaptar `Administrador` para e-mail.
- Simplificar a PK de `Turma` para `cod_turma`, criar `Turma.codigo char(6) UNIQUE` e alinhar o criador.
- Substituir `Aluno_Turma` por `Turma_Membro` com usuário tipado, papel e `ativo`.
- Remodelar `Relatorio` com PK substituta, usuário tipado, contexto, simulado anulável, alternativa selecionada e índice único baseado em `chave_contexto`.
- Padronizar `Questao.resposta` como A–E; `alternativaE` permanece anulável e não muda.
- Manter dono tipado de `Simulado` pelas duas colunas existentes e exigir exatamente uma preenchida.
- Criar `Evento` com dono tipado, ocorrência, `id_serie`, recorrência e `ativo`; não criar `Evento_Serie`.
- Criar `Turma_Simulado`, `Simulado_Salvo`, `Turma_Evento` e `Evento_Salvo`; os controles salvos usam `email_membro` + `tipo_usuario`.
- Criar índices e FKs não polimórficas necessários para consultas, ownership, publicações e cópias.
- Migrar `Simulado.tempo` de `float` para `int` com unidade em minutos.

### 17.3 Alterações que podem ficar somente na API

- Unicidade de e-mail entre as três tabelas, desde que a API seja o único escritor; cada tabela ainda terá seu próprio `UNIQUE`.
- Validação de existência/estado do usuário tipado em `Turma_Membro`, `Relatorio`, `Evento`, `Simulado_Salvo` e `Evento_Salvo`, pois uma FK condicional não é possível sem tabela central.
- Garantia de que só o criador tenha papel administrativo e de que professor visitante seja membro comum.
- Geração segura do código de turma, com repetição em colisão do índice `UNIQUE`.
- Geração/materialização das ocorrências dentro dos limites fixos e UUID de série.
- Seleção do campo de dono (`Simulado.email_aluno` ou `email_prof`) conforme o tipo autenticado.
- Hash/verificação de senha, transformação das alternativas em array, ocultação do gabarito e cálculo de acerto/desempenho.
- Validações semânticas e autorização de todos os endpoints.

Essas garantias precisam migrar para o banco somente se surgirem escritores externos, importações diretas ou uma exigência explícita de integridade independente da API. Nesse cenário, triggers são a alternativa mínima para regras entre tabelas; não fazem parte do conjunto obrigatório atual.

### 17.4 Alterações opcionais ou adiáveis

- Triggers de unicidade global e integridade polimórfica.
- `Administrador.ativo` e eventual ampliação de seus dados de perfil.
- Renomear `Relatorio.acertou/errou`, tornar alternativas A–D `NOT NULL` e normalizar todos os `ativo` para booleano/check.
- Adicionar `Simulado.data_criacao`, `Simulado.ativo`, `Turma.imagem` e `Turma.cor`.
- Versionar rotas em `/api/v1`, decidir armazenamento externo de imagens e remover tabelas legadas após auditoria.

### 17.5 Contratos de dados esperados pelo frontend

- Autenticação: `AuthResponseDTO` identifica `email`, nome e `tipoUsuario`, sem senha/hash.
- Questões: `QuestaoDTO.alternativas` contém quatro ou cinco itens e não contém gabarito antes da resposta.
- Resposta: `RespostaResultadoDTO` informa `contexto`, `simuladoId` quando aplicável, alternativa correta, acerto e bloqueio definitivo.
- Simulados: DTOs preservam `id`, `titulo`, `tempoMinutos`, contagens, status e ownership implícito pelo usuário autenticado; a última resposta retorna o estado concluído.
- Desempenho: agrega respostas avulsas e de simulados e expõe também os totais separados por contexto.
- Turmas: `TurmaDetalheDTO` informa o papel; professor visitante recebe `MEMBRO`, nunca `ADMINISTRADOR`.
- Publicações: DTOs informam `idPublicacao` e `salvoPeloUsuario`; salvar retorna a identidade da cópia pessoal para aluno ou professor.
- Calendário: `EventoCalendarioDTO` mantém o formato `id/title/start/end/allDay/color/extendedProps` consumido pelo web; somente eventos ativos são listados.

### 17.6 Dúvidas realmente bloqueantes restantes

**Nenhuma.** Não restou decisão de negócio ou de estrutura que impeça escrever as migrations mínimas na etapa futura.

Parâmetros de implementação como duração/renovação do JWT e política mínima/recuperação de senha deverão ser configurados antes da entrega de autenticação, mas não alteram o schema planejado e não são bloqueantes para escrever migrations. Armazenamento definitivo de fotos/imagens e envio do formulário de suporte foram explicitamente adiados e permanecem fora do escopo da primeira versão.

## Resultado arquitetural

A proposta mantém o núcleo atual (`Aluno`, `Professor`, `Administrador`, `Questao`, `Simulado`, `Quest_Simu`, `Relatorio`, `Turma`) e acrescenta somente membership genérico, um calendário de tabela única e associações de publicação/salvamento. A simplificação obrigatória da PK de `Turma` evita repetir `nome_turma` e `email_prof` em todas as FKs novas e alinha o banco ao `TurmaRepository<Turma,Integer>`. Usuários polimórficos são representados por e-mail + tipo e validados inicialmente na API; o banco garante as unicidades que realmente precisam resistir à concorrência, especialmente uma resposta por usuário, questão e contexto.
