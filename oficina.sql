-- Criando o banco de dados
CREATE DATABASE oficina;

-- Usando o banco de dados
\c oficina;

-- Tabela de Clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    endereco TEXT
);

-- Tabela de Veículos
CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id) ON DELETE CASCADE,
    placa VARCHAR(10) UNIQUE NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    ano INT NOT NULL
);

-- Tabela de Mecânicos
CREATE TABLE mecanicos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco TEXT,
    especialidade VARCHAR(50) NOT NULL
);

-- Tabela de Equipes
CREATE TABLE equipes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

-- Relacionamento Mecânicos <-> Equipes
CREATE TABLE equipe_mecanico (
    equipe_id INT REFERENCES equipes(id) ON DELETE CASCADE,
    mecanico_id INT REFERENCES mecanicos(id) ON DELETE CASCADE,
    PRIMARY KEY (equipe_id, mecanico_id)
);

-- Tabela de Ordens de Serviço (OS)
CREATE TABLE ordens_servico (
    id SERIAL PRIMARY KEY,
    veiculo_id INT REFERENCES veiculos(id) ON DELETE CASCADE,
    equipe_id INT REFERENCES equipes(id) ON DELETE SET NULL,
    data_emissao DATE NOT NULL DEFAULT CURRENT_DATE,
    data_conclusao DATE,
    valor_total DECIMAL(10,2) DEFAULT 0.00,
    status VARCHAR(20) CHECK (status IN ('Aberta', 'Em andamento', 'Concluída', 'Cancelada')) NOT NULL
);

-- Tabela de Serviços
CREATE TABLE servicos (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL,
    preco_mao_obra DECIMAL(10,2) NOT NULL
);

-- Tabela de Peças
CREATE TABLE pecas (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL
);

-- Tabela de Serviços executados na OS
CREATE TABLE os_servicos (
    os_id INT REFERENCES ordens_servico(id) ON DELETE CASCADE,
    servico_id INT REFERENCES servicos(id) ON DELETE CASCADE,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    PRIMARY KEY (os_id, servico_id)
);

-- Tabela de Peças utilizadas na OS
CREATE TABLE os_pecas (
    os_id INT REFERENCES ordens_servico(id) ON DELETE CASCADE,
    peca_id INT REFERENCES pecas(id) ON DELETE CASCADE,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    PRIMARY KEY (os_id, peca_id)
);
