-- Inserindo dados na tabela Cliente
INSERT INTO Cliente (tipo_cliente, nome, cpf, cnpj, data_nascimento, email, telefone) VALUES
('PF', 'João Silva', '12345678901', NULL, '1980-05-10', 'joao.silva@email.com', '11999998888'),
('PF', 'Maria Souza', '98765432109', NULL, '1992-12-20', 'maria.souza@email.com', '21988887777'),
('PJ', 'Empresa ABC Ltda', NULL, '12345678000190', NULL, 'contato@abc.com.br', '31977776666'),
('PF', 'Pedro Oliveira', '45678901234', NULL, '1985-03-15', 'pedro.oliveira@email.com', '41966665555'),
('PJ', 'Tech Solutions S/A', NULL, '98765432000180', NULL, 'vendas@techsol.com.br', '51955554444'),
('PF', 'Ana Rodrigues', '65432109876', NULL, '1998-07-01', 'ana.rodrigues@email.com', '61944443333'),
('PJ', 'Global Commerce Inc.', NULL, '54321678000170', NULL, 'info@globalcom.com', '71933332222'),
('PF', 'Ricardo Santos', '32165498705', NULL, '1977-11-08', 'ricardo.santos@email.com', '81922221111'),
('PJ', 'Innovation Labs Ltda', NULL, '67890123000160', NULL, 'suporte@inno.com.br', '91911110000'),
('PF', 'Carla Pereira', '78901234567', NULL, '1989-09-25', 'carla.pereira@email.com', '12900009999'),
('PJ', 'United Brands S/A', NULL, '43210987000150', NULL, 'marketing@united.com', '13988889999'),
('PF', 'Lucas Ferreira', '23456789012', NULL, '1995-04-03', 'lucas.ferreira@email.com', '14977778888'),
('PJ', 'Prime Distribution Ltda', NULL, '34567890000140', NULL, 'financeiro@prime.com.br', '15966667777'),
('PF', 'Fernanda Costa', '56789012345', NULL, '1982-06-18', 'fernanda.costa@email.com', '16955556666'),
('PJ', 'Alpha Solutions S/A', NULL, '23456789000130', NULL, 'rh@alphasol.com', '17944445555');

-- Inserindo dados na tabela Endereco
INSERT INTO Endereco (cliente_id, logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES
(1, 'Rua das Flores', '123', 'Apto 101', 'Jardim', 'São Paulo', 'SP', '01234000'),
(2, 'Avenida Paulista', '456', 'Sala 202', 'Bela Vista', 'Rio de Janeiro', 'RJ', '20000000'),
(3, 'Rua da Praia', '789', NULL, 'Copacabana', 'Belo Horizonte', 'MG', '30000000'),
(4, 'Rua XV de Novembro', '1011', 'Casa 3', 'Centro', 'Porto Alegre', 'RS', '90000000'),
(5, 'Avenida Ipiranga', '1213', NULL, 'Bom Fim', 'Curitiba', 'PR', '80000000'),
(6, 'Rua Augusta', '1415', 'Apto 404', 'Consolação', 'Salvador', 'BA', '40000000'),
(7, 'Avenida Brasil', '1617', NULL, 'Barra', 'Brasília', 'DF', '70000000'),
(8, 'Rua Chile', '1819', 'Casa 5', 'Savassi', 'Manaus', 'AM', '69000000'),
(9, 'Avenida Afonso Pena', '2021', NULL, 'Funcionários', 'Recife', 'PE', '50000000'),
(10, 'Rua Bahia', '2223', 'Apto 606', 'Higienópolis', 'Goiânia', 'GO', '74000000'),
(11, 'Avenida Goiás', '2425', NULL, 'Setor Oeste', 'Fortaleza', 'CE', '60000000'),
(12, 'Rua Ceará', '2627', 'Casa 7', 'Aldeota', 'Belém', 'PA', '66000000'),
(13, 'Avenida Pará', '2829', NULL, 'Umarizal', 'Natal', 'RN', '59000000'),
(14, 'Rua Amazonas', '3031', 'Apto 808', 'Petrópolis', 'Campo Grande', 'MS', '79000000'),
(15, 'Avenida Mato Grosso', '3233', NULL, 'Jardim dos Estados', 'Cuiabá', 'MT', '78000000');

-- Inserindo dados na tabela FormaPagamento
INSERT INTO FormaPagamento (cliente_id, tipo_pagamento, numero_cartao, nome_titular, data_validade, codigo_seguranca) VALUES
(1, 'Cartão de Crédito', '1234567890123456', 'João Silva', '2025-12-01', '123'),
(2, 'Boleto Bancário', NULL, NULL, NULL, NULL),
(3, 'PIX', NULL, NULL, NULL, NULL),
(4, 'Cartão de Débito', '6543210987654321', 'Pedro Oliveira', '2024-11-01', '456'),
(5, 'Cartão de Crédito', '9876543210987654', 'Tech Solutions S/A', '2026-10-01', '789'),
(6, 'Boleto Bancário', NULL, NULL, NULL, NULL),
(7, 'PIX', NULL, NULL, NULL, NULL),
(8, 'Cartão de Crédito', '4321567809876543', 'Ricardo Santos', '2023-09-01', '012'),
(9, 'Cartão de Débito', '7654321098765432', 'Innovation Labs Ltda', '2027-08-01', '345'),
(10, 'Cartão de Crédito', '2109876543215678', 'Carla Pereira', '2024-07-01', '678'),
(11, 'Boleto Bancário', NULL, NULL, NULL, NULL),
(12, 'PIX', NULL, NULL, NULL, NULL),
(13, 'Cartão de Crédito', '8765432109876543', 'Prime Distribution Ltda', '2025-06-01', '901'),
(14, 'Cartão de Débito', '5432109876543210', 'Fernanda Costa', '2023-05-01', '234'),
(15, 'Cartão de Crédito', '3210987654321098', 'Alpha Solutions S/A', '2026-04-01', '567');

-- Inserindo dados na tabela Categoria
INSERT INTO Categoria (nome, descricao) VALUES
('Eletrônicos', 'Produtos eletrônicos em geral'),
('Livros', 'Livros de diversos gêneros'),
('Roupas', 'Vestuário para homens e mulheres'),
('Calçados', 'Calçados de diversos tipos'),
('Móveis', 'Móveis para casa e escritório'),
('Alimentos', 'Alimentos não perecíveis'),
('Bebidas', 'Bebidas em geral'),
('Brinquedos', 'Brinquedos para crianças'),
('Esporte e Lazer', 'Equipamentos esportivos e artigos de lazer'),
('Beleza e Saúde', 'Produtos de beleza e cuidados pessoais'),
('Informática', 'Computadores, notebooks e acessórios'),
('Games', 'Jogos e consoles'),
('Eletrodomésticos', 'Eletrodomésticos para casa'),
('Ferramentas', 'Ferramentas para construção e reparos'),
('Automotivo', 'Acessórios e peças para carros');

-- Inserindo dados na tabela Produto
INSERT INTO Produto (nome, descricao, preco, categoria_id) VALUES
('Smartphone', 'Smartphone Android com câmera de alta resolução', 1200.00, 1),
('Livro - Dom Casmurro', 'Romance clássico de Machado de Assis', 35.00, 2),
('Camiseta Masculina', 'Camiseta de algodão para homens', 50.00, 3),
('Tênis Esportivo', 'Tênis para prática de esportes', 150.00, 4),
('Sofá Retrátil', 'Sofá confortável para sala de estar', 800.00, 5),
('Arroz Branco', 'Arroz branco tipo 1', 25.00, 6),
('Refrigerante Cola', 'Refrigerante sabor cola', 8.00, 7),
('Boneca Barbie', 'Boneca para crianças', 40.00, 8),
('Bola de Futebol', 'Bola para prática de futebol', 60.00, 9),
('Shampoo', 'Shampoo para cabelos', 20.00, 10),
('Notebook', 'Notebook com processador Intel Core i5', 2500.00, 11),
('PlayStation 5', 'Console de videogame da Sony', 4500.00, 12),
('Geladeira', 'Geladeira frost free', 1800.00, 13),
('Furadeira', 'Furadeira elétrica para uso doméstico', 120.00, 14),
('Pneu para Carro', 'Pneu para carro aro 14', 250.00, 15);

-- Inserindo dados na tabela Fornecedor
INSERT INTO Fornecedor (nome, cnpj, email, telefone) VALUES
('Samsung', '00000000000100', 'contato@samsung.com', '11111111111'),
('Editora Abril', '00000000000200', 'vendas@abril.com.br', '22222222222'),
('Nike', '00000000000300', 'sac@nike.com', '33333333333'),
('Magazine Luiza', '00000000000400', 'atendimento@magalu.com.br', '44444444444'),
('Ambev', '00000000000500', 'faleconosco@ambev.com.br', '55555555555'),
('Mattel', '00000000000600', 'clientes@mattel.com', '66666666666'),
('Dell', '00000000000700', 'suporte@dell.com', '77777777777'),
('Sony', '00000000000800', 'contato@sony.com.br', '88888888888'),
('Electrolux', '00000000000900', 'sac@electrolux.com.br', '99999999999'),
('Bosch', '00000000001000', 'contato@bosch.com.br', '10101010101'),
('Pirelli', '00000000001100', 'faleconosco@pirelli.com', '12121212121'),
('Lojas Americanas', '00000000001200', 'atendimento@americanas.com.br', '13131313131'),
('Centauro', '00000000001300', 'sac@centauro.com.br', '14141414141'),
('Natura', '00000000001400', 'faleconosco@natura.net', '15151515151'),
('LG', '00000000001500', 'suporte@lge.com.br', '16161616161');

-- Inserindo dados na tabela Estoque
INSERT INTO Estoque (produto_id, fornecedor_id, quantidade) VALUES
(1, 1, 100),
(2, 2, 50),
(3, 3, 200),
(4, 3, 150),
(5, 4, 30),
(6, 5, 500),
(7, 5, 400),
(8, 6, 100),
(9, 13, 80),
(10, 14, 120),
(11, 7, 60),
(12, 8, 40),
(13, 9, 20),
(14, 10, 100),
(15, 11, 70);

-- Inserindo dados na tabela Pedido
INSERT INTO Pedido (cliente_id, valor_total, status_pedido, forma_pagamento_id) VALUES
(1, 1250.00, 'Entregue', 1),
(2, 70.00, 'Enviado', 2),
(3, 2600.00, 'Aguardando Pagamento', 3),
(4, 170.00, 'Em Preparação', 4),
(5, 4650.00, 'Entregue', 5),
(6, 60.00, 'Cancelado', 6),
(7, 10.00, 'Entregue', 7),
(8, 1260.00, 'Em Trânsito', 8),
(9, 2650.00, 'Entregue', 9),
(10, 60.00, 'Aguardando Pagamento', 10),
(11, 50.00, 'Enviado', 11),
(12, 10.00, 'Em Preparação', 12),
(13, 2550.00, 'Entregue', 13),
(14, 470.00, 'Em Trânsito', 14),
(15, 25.00, 'Cancelado', 15);

-- Inserindo dados na tabela ItemPedido
INSERT INTO ItemPedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 1200.00),
(1, 10, 1, 20.00),
(1, 7, 1, 30.00),
(2, 2, 2, 35.00),
(3, 11, 1, 2500.00),
(3, 7, 2, 50.00),
(3, 10, 1, 50.00),
(4, 3, 1, 50.00),
(4, 4, 1, 150.00),
(5, 12, 1, 4500.00),
(5, 6, 1, 100.00),
(5, 4, 1, 50.00),
(6, 8, 1, 40.00),
(6, 10, 1, 20.00),
(7, 7, 1, 8.00),
(7, 6, 1, 2.00),
(8, 1, 1, 1200.00),
(8, 8, 1, 40.00),
(8, 10, 1, 20.00),
(9, 11, 1, 2500.00),
(9, 10, 1, 50.00),
(9, 10, 1, 100.00),
(10, 3, 1, 40.00),
(10, 10, 1, 20.00),
(11, 3, 1, 40.00),
(11, 3, 1, 10.00),
(12, 7, 1, 8.00),
(12, 6, 1, 2.00),
(13, 11, 1, 2500.00),
(13, 3, 1, 50.00),
(14, 3, 1, 200.00),
(14, 10, 1, 50.00),
(14, 6, 1, 100.00),
(14, 2, 1, 20.00),
(15, 6, 1, 25.00);

-- Inserindo dados na tabela Entrega
INSERT INTO Entrega (pedido_id, status_entrega, codigo_rastreio, data_envio, data_entrega_prevista, data_entrega_real) VALUES
(1, 'Entregue', 'BR123456789BR', '2023-10-26', '2023-10-30', '2023-10-29'),
(2, 'Enviado', 'BR987654321BR', '2023-10-27', '2023-11-02', NULL),
(3, 'Aguardando Pagamento', NULL, NULL, NULL, NULL),
(4, 'Em Preparação', NULL, '2023-10-28', NULL, NULL),
(5, 'Entregue', 'BR567890123BR', '2023-10-29', '2023-11-03', '2023-11-02'),
(6, 'Cancelado', NULL, NULL, NULL, NULL),
(7, 'Entregue', 'BR234567890BR', '2023-10-30', '2023-11-04', '2023-11-03'),
(8, 'Em Trânsito', 'BR098765432BR', '2023-10-31', '2023-11-05', NULL),
(9, 'Entregue', 'BR678901234BR', '2023-11-01', '2023-11-06', '2023-11-05'),
(10, 'Aguardando Pagamento', NULL, NULL, NULL, NULL),
(11, 'Enviado', 'BR345678901BR', '2023-11-02', '2023-11-07', NULL),
(12, 'Em Preparação', NULL, '2023-11-03', NULL, NULL),
(13, 'Entregue', 'BR789012345BR', '2023-11-04', '2023-11-08', '2023-11-07'),
(14, 'Em Trânsito', 'BR456789012BR', '2023-11-05', '2023-11-09', NULL),
(15, 'Cancelado', NULL, NULL, NULL, NULL);

-- Inserindo dados na tabela Vendedor
INSERT INTO Vendedor (nome, cpf, email, telefone) VALUES
('Carlos Silva', '11122233344', 'carlos.silva@email.com', '11911112222'),
('Ana Paula', '22233344455', 'ana.paula@email.com', '21922223333'),
('Ricardo Oliveira', '33344455566', 'ricardo.oliveira@email.com', '31933334444'),
('Fernanda Souza', '44455566677', 'fernanda.souza@email.com', '41944445555'),
('Lucas Santos', '55566677788', 'lucas.santos@email.com', '51955556666'),
('Juliana Costa', '66677788899', 'juliana.costa@email.com', '61966667777'),
('Rafael Pereira', '77788899900', 'rafael.pereira@email.com', '71977778888'),
('Mariana Almeida', '88899900011', 'mariana.almeida@email.com', '81988889999'),
('Gustavo Rocha', '99900011122', 'gustavo.rocha@email.com', '91999990000'),
('Patrícia Nunes', '00011122233', 'patricia.nunes@email.com', '12900001111'),
('Leonardo Martins', '11122233300', 'leonardo.martins@email.com', '13911112222'),
('Isabela Correia', '22233344411', 'isabela.correia@email.com', '14922223333'),
('Thiago Fernandes', '33344455522', 'thiago.fernandes@email.com', '15933334444'),
('Camila Gonçalves', '44455566633', 'camila.goncalves@email.com', '16944445555'),
('Bruno Castro', '55566677744', 'bruno.castro@email.com', '17955556666');

-- Inserindo dados na tabela VendedorFornecedor
INSERT INTO VendedorFornecedor (vendedor_id, fornecedor_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 6),
(6, 7),
(7, 8),
(8, 9),
(9, 10),
(10, 11),
(11, 12),
(12, 13),
(13, 14),
(14, 15);

-- Atualizando a tabela Pedido para incluir vendedor_id
UPDATE Pedido SET vendedor_id = 1 WHERE pedido_id IN (1, 6, 11);
UPDATE Pedido SET vendedor_id = 2 WHERE pedido_id IN (2, 7, 12);
UPDATE Pedido SET vendedor_id = 3 WHERE pedido_id IN (3, 8, 13);
UPDATE Pedido SET vendedor_id = 4 WHERE pedido_id IN (4, 9, 14);
UPDATE Pedido SET vendedor_id = 5 WHERE pedido_id IN (5, 10, 15);