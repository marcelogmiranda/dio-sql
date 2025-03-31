# Desafio E-commerce - Modelagem de Banco de Dados

Este repositório contém a solução para o desafio de modelagem de banco de dados para um sistema de e-commerce utilizando PostgreSQL.

## Conteúdo

*   crição bd.sql:** Script SQL para criação do banco de dados, tabelas, chaves primárias, chaves estrangeiras e constraints.
*   inserção de dado em massa.sql:** Script SQL para preenchimento das tabelas com dados de exemplo (pelo menos 15 registros por tabela).
*   consultas-analises.sql:** Script SQL contendo queries de consulta simples e complexas para extrair informações do banco de dados.
*   Readme.md:** Este arquivo, contendo a descrição do projeto e instruções.

## Modelagem do Banco de Dados

A modelagem foi feita considerando as seguintes premissas:

*   **Cliente:** Suporte para clientes Pessoa Física (PF) e Pessoa Jurídica (PJ). Uma conta não pode ter informações de ambos os tipos.
*   **Pagamento:** Um cliente pode ter múltiplas formas de pagamento cadastradas.
*   **Entrega:** A entrega possui status e código de rastreio.

O diagrama ER (ecommerce\_er\_diagram.png) detalha as entidades, atributos e relacionamentos.

## Instruções

1.  **Criar o Banco de Dados:**

    *   Certifique-se de ter o PostgreSQL instalado.
    *   Execute o script `crição bd.sql` para criar a estrutura do banco de dados:
        ```bash
        psql -U seu_usuario -d postgres -f ecommerce_schema.sql
        ```
2.  **Preencher o Banco de Dados:**

    *   Execute o script `inserção de dado em massa.sql` para inserir dados nas tabelas:
        ```bash
        psql -U seu_usuario -d ecommerce -f ecommerce_data.sql
        ```

3.  **Executar as Queries:**

    *   Execute o script `consultas-analises.sql` ou copie e cole as queries no seu cliente PostgreSQL (ex: pgAdmin) para consultar os dados.
        ```bash
        psql -U seu_usuario -d ecommerce -f queries.sql
        ```

## Perguntas de Negócio e Queries

O arquivo `consultas-analises.sql` contém queries que respondem às seguintes perguntas de negócio:

*   Quantos pedidos foram feitos por cada cliente?
*   Algum vendedor também é fornecedor?
*   Relação de produtos, fornecedores e estoques.
*   Relação de nomes dos fornecedores e nomes dos produtos que fornecem.
*   ... (e as demais perguntas listadas nos scripts SQL)

Essas perguntas visam auxiliar no processo de tomada de decisão da empresa, fornecendo informações relevantes sobre clientes, produtos, vendas e entregas.

## Considerações Finais

Esta solução apresenta uma modelagem básica para um sistema de e-commerce.  Em um cenário real, mais tabelas e atributos poderiam ser adicionados para atender a requisitos específicos do negócio.  Além disso, índices adicionais poderiam ser criados para otimizar o desempenho das consultas.