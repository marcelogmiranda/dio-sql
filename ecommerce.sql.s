-- Criando o banco de dados
CREATE DATABASE ecommerce;

-- Usando o banco de dados
USE ecommerce;

-- Tabela de Clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    tipo_pessoa CHAR(1) CHECK (tipo_pessoa IN ('F', 'J')) NOT NULL, -- 'F' para Física, 'J' para Jurídica
    documento VARCHAR(18) UNIQUE NOT NULL CHECK (LENGTH(documento) IN (11, 14)) -- CPF (11) ou CNPJ (14)
);

-- Tabela de Endereços
CREATE TABLE enderecos (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id) ON DELETE CASCADE,
    cep VARCHAR(9) NOT NULL,
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(255),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL
);

-- Tabela de Fornecedores
CREATE TABLE fornecedores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    contato VARCHAR(100)
);

-- Tabela de Produtos
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0),
    fornecedor_id INT REFERENCES fornecedores(id) ON DELETE SET NULL
);

-- Tabela de Estoque
CREATE TABLE estoque (
    id SERIAL PRIMARY KEY,
    produto_id INT UNIQUE REFERENCES produtos(id) ON DELETE CASCADE,
    quantidade INT NOT NULL CHECK (quantidade >= 0)
);

-- Tabela de Pedidos
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id) ON DELETE CASCADE,
    endereco_id INT REFERENCES enderecos(id) ON DELETE SET NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_pagamento VARCHAR(50) CHECK (status_pagamento IN ('Pendente', 'Pago', 'Cancelado')) NOT NULL,
    status_entrega VARCHAR(50) CHECK (status_entrega IN ('Processando', 'Enviado', 'Entregue', 'Cancelado')) NOT NULL,
    codigo_rastreamento VARCHAR(50) UNIQUE
);

-- Tabela de Itens do Pedido
CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_id INT REFERENCES produtos(id) ON DELETE CASCADE,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
    UNIQUE (pedido_id, produto_id)
);

-- Tabela de Pagamentos (várias formas para um pedido)
CREATE TABLE pagamentos (
    id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedidos(id) ON DELETE CASCADE,
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    metodo_pagamento VARCHAR(50) CHECK (metodo_pagamento IN ('Cartão de Crédito', 'Boleto', 'PIX', 'Transferência', 'Dinheiro')) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('Aprovado', 'Rejeitado', 'Pendente')) NOT NULL
);

-- Atualização de estoque ao fazer pedido
CREATE OR REPLACE FUNCTION atualizar_estoque()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT quantidade FROM estoque WHERE produto_id = NEW.produto_id) < NEW.quantidade THEN
        RAISE EXCEPTION 'Estoque insuficiente para o produto %', NEW.produto_id;
    ELSE
        UPDATE estoque SET quantidade = quantidade - NEW.quantidade WHERE produto_id = NEW.produto_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_estoque
BEFORE INSERT ON itens_pedido
FOR EACH ROW EXECUTE FUNCTION atualizar_estoque();
