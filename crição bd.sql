-- Criação do Banco de Dados
CREATE DATABASE ecommerce;

-- Conectar ao banco de dados
\c ecommerce

-- Tabela Cliente
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    tipo CHAR(2) NOT NULL CHECK (tipo IN ('PF', 'PJ')),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela ClientePF
CREATE TABLE cliente_pf (
    id_cliente INT PRIMARY KEY,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    data_nascimento DATE,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE
);

-- Tabela ClientePJ
CREATE TABLE cliente_pj (
    id_cliente INT PRIMARY KEY,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    razao_social VARCHAR(100) NOT NULL,
    inscricao_estadual VARCHAR(20),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE
);

-- Tabela Endereço
CREATE TABLE endereco (
    id_endereco SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(10),
    complemento VARCHAR(50),
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    uf CHAR(2) NOT NULL,
    cep VARCHAR(10) NOT NULL,
    tipo VARCHAR(20) NOT NULL, -- 'ENTREGA', 'FATURAMENTO', 'AMBOS'
    principal BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE
);

-- Tabela Vendedor
CREATE TABLE vendedor (
    id_vendedor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    avaliacao DECIMAL(3,1) DEFAULT 0.0
);

-- Tabela Fornecedor
CREATE TABLE fornecedor (
    id_fornecedor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    contato VARCHAR(100),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela Categoria
CREATE TABLE categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao VARCHAR(200)
);

-- Tabela Produto
CREATE TABLE produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    id_categoria INT NOT NULL,
    id_vendedor INT NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    peso DECIMAL(10,2),
    dimensoes VARCHAR(50),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id_vendedor)
);

-- Tabela ProdutoFornecedor
CREATE TABLE produto_fornecedor (
    id_produto INT,
    id_fornecedor INT,
    quantidade INT NOT NULL CHECK (quantidade >= 0),
    custo_unitario DECIMAL(10,2) NOT NULL,
    data_ultima_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_produto, id_fornecedor),
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor)
);

-- Tabela Estoque
CREATE TABLE estoque (
    id_estoque SERIAL PRIMARY KEY,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade >= 0),
    localizacao VARCHAR(50),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

-- Trigger para atualizar data_atualizacao do estoque
CREATE OR REPLACE FUNCTION update_estoque_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_estoque_timestamp
BEFORE UPDATE ON estoque
FOR EACH ROW
EXECUTE FUNCTION update_estoque_timestamp();

-- Tabela Pagamento
CREATE TABLE pagamento (
    id_pagamento SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- 'CARTAO_CREDITO', 'BOLETO', 'PIX', 'TRANSFERENCIA'
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE', -- 'PENDENTE', 'APROVADO', 'REJEITADO', 'CANCELADO'
    detalhes JSONB, -- Armazena detalhes específicos do pagamento conforme o tipo
    principal BOOLEAN DEFAULT FALSE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- Tabela Pedido
CREATE TABLE pedido (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'CRIADO', -- 'CRIADO', 'PAGO', 'EM_SEPARACAO', 'ENVIADO', 'ENTREGUE', 'CANCELADO'
    valor_subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    valor_frete DECIMAL(10,2) NOT NULL DEFAULT 0,
    valor_desconto DECIMAL(10,2) NOT NULL DEFAULT 0,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    id_endereco_entrega INT NOT NULL,
    id_pagamento INT,
    nota_fiscal VARCHAR(50),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_endereco_entrega) REFERENCES endereco(id_endereco),
    FOREIGN KEY (id_pagamento) REFERENCES pagamento(id_pagamento)
);

-- Tabela ItemPedido
CREATE TABLE item_pedido (
    id_item SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantidade * preco_unitario) STORED,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

-- Tabela Entrega
CREATE TABLE entrega (
    id_entrega SERIAL PRIMARY KEY,
    id_pedido INT UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AGUARDANDO_ENVIO', -- 'AGUARDANDO_ENVIO', 'EM_TRANSITO', 'ENTREGUE', 'CANCELADA'
    codigo_rastreio VARCHAR(50),
    transportadora VARCHAR(100),
    previsao_entrega DATE,
    data_envio TIMESTAMP,
    data_entrega TIMESTAMP,
    observacoes TEXT,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE
);

-- Função para calcular o total do pedido
CREATE OR REPLACE FUNCTION calcular_total_pedido()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza o subtotal do pedido
    UPDATE pedido
    SET valor_subtotal = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM item_pedido
        WHERE id_pedido = NEW.id_pedido
    )
    WHERE id_pedido = NEW.id_pedido;
    
    -- Atualiza o total do pedido
    UPDATE pedido
    SET valor_total = valor_subtotal + valor_frete - valor_desconto
    WHERE id_pedido = NEW.id_pedido;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar o total do pedido após inserção ou atualização de item_pedido
CREATE TRIGGER calcular_total_pedido_insert
AFTER INSERT ON item_pedido
FOR EACH ROW
EXECUTE FUNCTION calcular_total_pedido();

CREATE TRIGGER calcular_total_pedido_update
AFTER UPDATE ON item_pedido
FOR EACH ROW
EXECUTE FUNCTION calcular_total_pedido();

CREATE TRIGGER calcular_total_pedido_delete
AFTER DELETE ON item_pedido
FOR EACH ROW
EXECUTE FUNCTION calcular_total_pedido();

-- Função para verificar estoque ao adicionar item ao pedido
CREATE OR REPLACE FUNCTION verificar_estoque()
RETURNS TRIGGER AS $$
DECLARE
    estoque_disponivel INT;
BEGIN
    -- Verifica se há estoque disponível
    SELECT quantidade INTO estoque_disponivel
    FROM estoque
    WHERE id_produto = NEW.id_produto;
    
    IF estoque_disponivel IS NULL THEN
        RAISE EXCEPTION 'Produto não encontrado no estoque';
    END IF;
    
    IF estoque_disponivel < NEW.quantidade THEN
        RAISE EXCEPTION 'Estoque insuficiente. Disponível: %, Solicitado: %', estoque_disponivel, NEW.quantidade;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificar estoque antes de inserir ou atualizar item_pedido
CREATE TRIGGER verificar_estoque_insert
BEFORE INSERT ON item_pedido
FOR EACH ROW
EXECUTE FUNCTION verificar_estoque();

CREATE TRIGGER verificar_estoque_update
BEFORE UPDATE ON item_pedido
FOR EACH ROW
WHEN (OLD.quantidade <> NEW.quantidade)
EXECUTE FUNCTION verificar_estoque();

-- Função para atualizar estoque após confirmação de pedido
CREATE OR REPLACE FUNCTION atualizar_estoque_apos_pedido()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o status do pedido mudou para "PAGO", reduzir estoque
    IF NEW.status = 'PAGO' AND OLD.status <> 'PAGO' THEN
        UPDATE estoque e
        SET quantidade = e.quantidade - i.quantidade
        FROM item_pedido i
        WHERE i.id_pedido = NEW.id_pedido AND e.id_produto = i.id_produto;
    
    -- Se o status do pedido mudou de "PAGO" para "CANCELADO", restaurar estoque
    ELSIF NEW.status = 'CANCELADO' AND OLD.status = 'PAGO' THEN
        UPDATE estoque e
        SET quantidade = e.quantidade + i.quantidade
        FROM item_pedido i
        WHERE i.id_pedido = NEW.id_pedido AND e.id_produto = i.id_produto;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar estoque após alteração no status do pedido
CREATE TRIGGER atualizar_estoque_pedido
AFTER UPDATE ON pedido
FOR EACH ROW
WHEN (OLD.status <> NEW.status)
EXECUTE FUNCTION atualizar_estoque_apos_pedido();

-- Garantia de tipo de cliente
CREATE OR REPLACE FUNCTION verificar_tipo_cliente()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se um cliente PF já tem registro como PJ ou vice-versa
    IF TG_TABLE_NAME = 'cliente_pf' THEN
        IF EXISTS (SELECT 1 FROM cliente_pj WHERE id_cliente = NEW.id_cliente) THEN
            RAISE EXCEPTION 'Cliente já está cadastrado como PJ';
        END IF;
    ELSIF TG_TABLE_NAME = 'cliente_pj' THEN
        IF EXISTS (SELECT 1 FROM cliente_pf WHERE id_cliente = NEW.id_cliente) THEN
            RAISE EXCEPTION 'Cliente já está cadastrado como PF';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificar tipo de cliente
CREATE TRIGGER verificar_tipo_cliente_pf
BEFORE INSERT ON cliente_pf
FOR EACH ROW
EXECUTE FUNCTION verificar_tipo_cliente();

CREATE TRIGGER verificar_tipo_cliente_pj
BEFORE INSERT ON cliente_pj
FOR EACH ROW
EXECUTE FUNCTION verificar_tipo_cliente();

-- Criação de índices para otimização de consultas
CREATE INDEX idx_cliente_email ON cliente(email);
CREATE INDEX idx_cliente_pf_cpf ON cliente_pf(cpf);
CREATE INDEX idx_cliente_pj_cnpj ON cliente_pj(cnpj);
CREATE INDEX idx_produto_nome ON produto(nome);
CREATE INDEX idx_produto_categoria ON produto(id_categoria);
CREATE INDEX idx_produto_vendedor ON produto(id_vendedor);
CREATE INDEX idx_pedido_cliente ON pedido(id_cliente);
CREATE INDEX idx_pedido_status ON pedido(status);
CREATE INDEX idx_pedido_data ON pedido(data_pedido);
CREATE INDEX idx_item_pedido_produto ON item_pedido(id_produto);
CREATE INDEX idx_entrega_codigo ON entrega(codigo_rastreio);
CREATE INDEX idx_fornecedor_nome ON fornecedor(nome);
CREATE INDEX idx_endereco_cliente ON endereco(id_cliente);
