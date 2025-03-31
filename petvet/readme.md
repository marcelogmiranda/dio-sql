# PetVet - Projeto de Banco de Dados para Clínica Veterinária

## Visão Geral

**PetVet** é um sistema de gerenciamento de banco de dados projetado para uma clínica veterinária, com o objetivo de otimizar operações como o gerenciamento de clientes, animais, agendamentos, consultas, vacinações, prescrições, pagamentos e muito mais. Este projeto inclui um esquema de banco de dados PostgreSQL, gatilhos, visões e consultas SQL analíticas para suportar as operações diárias e as necessidades de inteligência de negócios da clínica.

O banco de dados é estruturado para lidar com entidades principais como clientes, animais, veterinários, serviços e transações financeiras, com recursos adicionais como gatilhos automatizados para gerenciamento de estoque, conflitos de agendamento e lembretes de vacinação. As visões e consultas analíticas fornecem insights sobre o desempenho da clínica, comportamento dos clientes e eficiência operacional.

## Estrutura do Projeto

O projeto é composto pelos seguintes componentes principais:

1. **Esquema do Banco de Dados** (`schema.sql`): Define a estrutura do banco de dados, incluindo tabelas, restrições, índices e dados iniciais.
2. **Gatilhos e Funções** (`triggers.sql`): Implementa processos automatizados, como atualização de status de agendamentos, gerenciamento de estoque de medicamentos e cálculo de cronogramas de vacinação.
3. **Visões** (`views.sql`): Fornece visões predefinidas para acesso rápido a dados agregados, como agendas diárias, controle de vacinação e relatórios financeiros.
4. **Consultas Analíticas** (`queries.sql`): Contém consultas SQL para análise de negócios, como receita mensal, popularidade de serviços e taxas de retenção de clientes.
5. **Diagrama Entidade-Relacionamento** (`petvet_erd.png`): Uma representação visual do esquema do banco de dados e das relações entre as entidades.

## Pré-requisitos

Para configurar e executar o banco de dados PetVet, certifique-se de ter o seguinte:

- **PostgreSQL**: Versão 12 ou superior instalada no seu sistema.
- **pgAdmin** ou outro cliente PostgreSQL (opcional, para facilitar o gerenciamento do banco de dados).
- **Git**: Para clonar o repositório.
- Uma interface de linha de comando (como o `psql`) ou uma ferramenta gráfica para executar scripts SQL.

## Instruções de Configuração

Siga estas etapas para configurar o banco de dados PetVet em sua máquina local:

### 1. Clonar o Repositório

Clone o repositório Git para sua máquina local:

```bash
git clone <url-do-repositório>
cd petvet
```

Substitua `<url-do-repositório>` pela URL do seu repositório Git.

### 2. Instalar o PostgreSQL (se ainda não estiver instalado)

- **Windows/Mac/Linux**: Baixe e instale o PostgreSQL no [site oficial](https://www.postgresql.org/download/).
- Certifique-se de que o serviço PostgreSQL está em execução:
  - No Linux: `sudo service postgresql start`
  - No Windows: Inicie o serviço pelo aplicativo Serviços.
  - No macOS (se instalado via Homebrew): `brew services start postgresql`

### 3. Criar o Banco de Dados

Faça login no PostgreSQL como o usuário `postgres` (ou outro usuário com privilégios administrativos):

```bash
psql -U postgres
```

Crie o banco de dados `petvet`:

```sql
CREATE DATABASE petvet
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
```

Saia do prompt do `psql`:

```sql
\q
```

### 4. Executar os Scripts SQL

Os scripts SQL devem ser executados na seguinte ordem para garantir a configuração correta das tabelas, gatilhos, visões e dados.

#### 4.1. Criar Tabelas e Inserir Dados Iniciais

Execute o script de criação do esquema para configurar as tabelas, restrições, índices e dados iniciais:

```bash
psql -U postgres -d petvet -f schema.sql
```

Este script cria todas as tabelas necessárias (como `clientes`, `animais`, `agendamentos`, etc.) e as popula com dados iniciais, como espécies comuns, raças, serviços, vacinas e medicamentos.

#### 4.2. Configurar Gatilhos e Funções

Execute o script de gatilhos para implementar processos automatizados:

```bash
psql -U postgres -d petvet -f triggers.sql
```

Este script configura gatilhos para:
- Atualizar o status dos agendamentos quando as consultas começam ou terminam.
- Gerenciar o estoque de medicamentos após prescrições.
- Verificar a disponibilidade do veterinário durante o agendamento.
- Calcular a data da próxima dose de vacina.
- Atualizar o status de pagamento das consultas.

#### 4.3. Criar Visões

Execute o script de visões para criar visões predefinidas para relatórios e uso operacional:

```bash
psql -U postgres -d petvet -f views.sql
```

Este script cria visões como:
- `vw_animais_completo`: Informações detalhadas sobre animais e clientes.
- `vw_agenda_dia`: Agenda de agendamentos diários.
- `vw_historico_animal`: Histórico de consultas por animal.
- `vw_controle_vacinacao`: Status e lembretes de vacinação.
- `vw_relatorio_financeiro`: Resumo financeiro mensal.

#### 4.4. Executar Consultas Analíticas (Opcional)

O arquivo `queries.sql` contém consultas SQL analíticas para insights de negócios. Você pode executar essas consultas individualmente usando o `psql` ou uma ferramenta gráfica como o pgAdmin.

Para executar uma consulta específica, abra o arquivo `queries.sql` em um editor de texto, copie a consulta desejada e execute-a no `psql`:

```bash
psql -U postgres -d petvet
```

Em seguida, cole e execute a consulta. Por exemplo, para verificar a receita mensal:

```sql
SELECT 
    TO_CHAR(data_pagamento, 'YYYY-MM') AS mes,
    SUM(valor) AS faturamento_total
FROM pagamentos
WHERE data_pagamento >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY TO_CHAR(data_pagamento, 'YYYY-MM')
ORDER BY mes DESC;
```

Alternativamente, você pode executar o arquivo `queries.sql` inteiro para ver todos os resultados:

```bash
psql -U postgres -d petvet -f queries.sql
```

### 5. Verificar a Configuração

Para confirmar que o banco de dados foi configurado corretamente, você pode verificar o seguinte:

- Listar todas as tabelas no banco de dados `petvet`:

```sql
psql -U postgres -d petvet -c "\dt"
```

- Verificar o número de registros em tabelas principais:

```sql
SELECT COUNT(*) FROM clientes;
SELECT COUNT(*) FROM animais;
SELECT COUNT(*) FROM agendamentos;
```

- Testar uma visão, como a agenda diária:

```sql
SELECT * FROM vw_agenda_dia;
```

### 6. Explorar o Diagrama Entidade-Relacionamento

O arquivo `petvet_erd.png` fornece uma representação visual do esquema do banco de dados. Abra este arquivo para entender as relações entre entidades como `clientes`, `animais`, `agendamentos` e `consultas`.

## Uso

Após configurar o banco de dados, você pode usá-lo para:

- **Gerenciar Operações**: Adicionar novos clientes, animais, agendamentos e consultas usando comandos SQL `INSERT` ou um aplicativo front-end conectado ao banco de dados.
- **Acompanhar Vacinações**: Usar a visão `vw_controle_vacinacao` para monitorar os cronogramas de vacinação e contatar clientes para doses futuras.
- **Analisar Desempenho**: Executar consultas do arquivo `queries.sql` para obter insights sobre receita, popularidade de serviços, retenção de clientes e mais.
- **Automatizar Processos**: Aproveitar os gatilhos para automatizar tarefas como atualização de status de agendamentos, gerenciamento de estoque e lembretes de agendamento.

## Exemplos de Consultas

Aqui estão algumas consultas de exemplo que você pode executar para explorar o banco de dados:

### Verificar a Receita Mensal

```sql
SELECT 
    TO_CHAR(data_pagamento, 'YYYY-MM') AS mes,
    SUM(valor) AS faturamento_total
FROM pagamentos
WHERE data_pagamento >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY TO_CHAR(data_pagamento, 'YYYY-MM')
ORDER BY mes DESC;
```

### Listar Animais com Vacinas Atrasadas

```sql
SELECT 
    a.nome AS nome_animal,
    c.nome AS nome_tutor,
    c.telefone,
    v.nome AS vacina,
    MAX(vac.data_aplicacao) AS ultima_aplicacao,
    MAX(vac.proxima_dose) AS data_proxima_dose,
    CURRENT_DATE - MAX(vac.proxima_dose) AS dias_atraso
FROM animais a
JOIN clientes c ON a.cliente_id = c.cliente_id
JOIN vacinacoes vac ON a.animal_id = vac.animal_id
JOIN vacinas v ON vac.vacina_id = v.vacina_id
WHERE a.ativo = TRUE
GROUP BY a.animal_id, a.nome, c.nome, c.telefone, v.nome
HAVING MAX(vac.proxima_dose) < CURRENT_DATE
ORDER BY dias_atraso DESC;
```

### Visualizar a Agenda de Hoje

```sql
SELECT * FROM vw_agenda_dia;
```



## Contato

Para perguntas ou suporte, entre em contato com os mantenedores do projeto em mmiranda@unigex.com.br.
