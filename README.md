# Sistema de Gestão de Oficina Mecânica

## Descrição do Projeto
Este projeto consiste na modelagem de um banco de dados relacional para a gestão de uma oficina mecânica. O objetivo é armazenar e gerenciar as informações de clientes, veículos, mecânicos, ordens de serviço e peças utilizadas.

## Estrutura do Banco de Dados
O banco de dados foi modelado para atender às seguintes necessidades:
- Cadastro de clientes e seus veículos.
- Gerenciamento de ordens de serviço (OS).
- Registro de serviços e peças utilizados em cada OS.
- Equipes de mecânicos responsáveis pelos reparos.

## Criticas e Melhorias na Narrativa
A narrativa original possuía algumas lacunas que foram preenchidas com as seguintes melhorias:
- Adição de uma entidade `clientes`, para relacionar veículos a seus proprietários.
- Inclusão de uma tabela `equipes` e seu relacionamento com mecânicos, pois a narrativa menciona equipes sem detalhar sua estrutura.
- Separação de `servicos` e `pecas`, permitindo um controle mais refinado de cada item em uma OS.
- Definição de status para a OS, permitindo melhor controle de seu andamento.

## Estrutura das Tabelas
O banco de dados contém as seguintes tabelas principais:
- `clientes`: Armazena dados dos clientes.
- `veiculos`: Relacionado aos clientes, armazena informações dos veículos.
- `mecanicos`: Registra os profissionais e suas especialidades.
- `equipes`: Agrupa mecânicos em equipes de trabalho.
- `ordens_servico`: Gerencia as OS emitidas.
- `servicos`: Registra serviços possíveis.
- `pecas`: Armazena informações de peças utilizadas.
- `os_servicos` e `os_pecas`: Relacionam serviços e peças a cada OS emitida.

## Configuração do Banco de Dados
1. Instale o PostgreSQL em seu sistema.
2. Execute o script `oficina_postgres.sql` para criar as tabelas.
3. Configure permissões e usuários conforme necessário.

## Considerações Finais
Esse esquema foi desenvolvido para garantir a integridade dos dados e facilitar a administração da oficina. Para futuras melhorias, pode-se considerar a inclusão de históricos de manutenção, controle de estoque e emissão de relatórios detalhados.

