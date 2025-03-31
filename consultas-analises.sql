-- Queries Complexas e Perguntas de Negócio

-- 1. Quantos pedidos foram feitos por cada cliente? (Agrupamento e Contagem)
-- Pergunta de Negócio: Quais clientes são os mais frequentes e precisam de mais atenção?

SELECT
    c.nome AS nome_cliente,
    COUNT(p.pedido_id) AS total_pedidos
FROM
    Cliente c
LEFT JOIN
    Pedido p ON c.cliente_id = p.cliente_id
GROUP BY
    c.nome
ORDER BY
    total_pedidos DESC;

-- 2. Algum vendedor também é fornecedor? (Subquery e Junção)
-- Pergunta de Negócio: Há conflitos de interesse ou oportunidades de otimização ao ter vendedores que também são fornecedores?

SELECT
    v.nome AS nome_vendedor,
    f.nome AS nome_fornecedor
FROM
    Vendedor v
INNER JOIN
    VendedorFornecedor vf ON v.vendedor_id = vf.vendedor_id
INNER JOIN
    Fornecedor f ON vf.fornecedor_id = f.fornecedor_id;

-- 3. Relação de produtos, fornecedores e estoques (Junção Múltipla)
-- Pergunta de Negócio: Quais produtos estão em falta e de quais fornecedores precisamos solicitar mais?

SELECT
    p.nome AS nome_produto,
    f.nome AS nome_fornecedor,
    e.quantidade AS quantidade_estoque
FROM
    Produto p
INNER JOIN
    Estoque e ON p.produto_id = e.produto_id
INNER JOIN
    Fornecedor f ON e.fornecedor_id = f.fornecedor_id
ORDER BY
    p.nome;

-- 4. Relação de nomes dos fornecedores e nomes dos produtos que fornecem (Junção e Agrupamento)
-- Pergunta de Negócio: Quais fornecedores são os principais para cada categoria de produto?

SELECT
    f.nome AS nome_fornecedor,
    STRING_AGG(DISTINCT p.nome, ', ') AS produtos_fornecidos
FROM
    Fornecedor f
INNER JOIN
    Estoque e ON f.fornecedor_id = e.fornecedor_id
INNER JOIN
    Produto p ON e.produto_id = p.produto_id
GROUP BY
    f.nome
ORDER BY
    f.nome;


-- 5. Clientes que fizeram pedidos com status 'Entregue' (Subquery e Filtro)
-- Pergunta de Negócio: Qual a satisfação dos clientes que já receberam seus pedidos? (Usar essa lista para pesquisa de satisfação)

SELECT
    c.nome AS nome_cliente,
    c.email AS email_cliente
FROM
    Cliente c
WHERE
    c.cliente_id IN (SELECT DISTINCT cliente_id FROM Pedido WHERE status_pedido = 'Entregue');

-- 6. Valor total gasto por cada cliente (Agrupamento, Soma e Ordenação)
-- Pergunta de Negócio: Quais são nossos melhores clientes em termos de receita gerada?

SELECT
    c.nome AS nome_cliente,
    SUM(p.valor_total) AS total_gasto
FROM
    Cliente c
INNER JOIN
    Pedido p ON c.cliente_id = p.cliente_id
GROUP BY
    c.nome
ORDER BY
    total_gasto DESC;

-- 7. Produtos mais vendidos (Agrupamento, Soma e Ordenação)
-- Pergunta de Negócio: Quais produtos são os mais populares e devemos manter em estoque constante?

SELECT
    p.nome AS nome_produto,
    SUM(ip.quantidade) AS total_vendido
FROM
    Produto p
INNER JOIN
    ItemPedido ip ON p.produto_id = ip.produto_id
GROUP BY
    p.nome
ORDER BY
    total_vendido DESC;

-- 8. Média de valor dos pedidos por forma de pagamento (Agrupamento e Média)
-- Pergunta de Negócio: Qual forma de pagamento gera os pedidos de maior valor?

SELECT
    fp.tipo_pagamento,
    AVG(p.valor_total) AS media_valor_pedido
FROM
    FormaPagamento fp
INNER JOIN
    Pedido p ON fp.forma_pagamento_id = p.forma_pagamento_id
GROUP BY
    fp.tipo_pagamento
ORDER BY
    media_valor_pedido DESC;

-- 9. Número de pedidos por status de entrega (Agrupamento e Contagem)
-- Pergunta de Negócio: Quantos pedidos estão em cada fase da entrega? (Monitoramento do processo de entrega)

SELECT
    e.status_entrega,
    COUNT(e.pedido_id) AS total_pedidos
FROM
    Entrega e
GROUP BY
    e.status_entrega
ORDER BY
    total_pedidos DESC;

-- 10. Clientes que usaram cartão de crédito e o valor total dos seus pedidos (Junção, Filtro e Soma)
-- Pergunta de Negócio: Quais clientes que pagam com cartão de crédito são os que mais gastam?

SELECT
    c.nome AS nome_cliente,
    SUM(p.valor_total) AS total_gasto_cartao
FROM
    Cliente c
INNER JOIN
    Pedido p ON c.cliente_id = p.cliente_id
INNER JOIN
    FormaPagamento fp ON p.forma_pagamento_id = fp.forma_pagamento_id
WHERE
    fp.tipo_pagamento = 'Cartão de Crédito'
GROUP BY
    c.nome
ORDER BY
    total_gasto_cartao DESC;

-- 11. Vendedores que realizaram mais vendas (Agrupamento, Contagem e Ordenação)
-- Pergunta de Negócio: Quais são os vendedores de melhor desempenho?

SELECT
    v.nome AS nome_vendedor,
    COUNT(p.pedido_id) AS total_vendas
FROM
    Vendedor v
LEFT JOIN
    Pedido p ON v.vendedor_id = p.vendedor_id
GROUP BY
    v.nome
ORDER BY
    total_vendas DESC;

-- 12. Categorias de produtos com maior faturamento (Agrupamento, Soma e Ordenação)
-- Pergunta de Negócio: Quais categorias de produtos são as mais lucrativas?

SELECT
    cat.nome AS nome_categoria,
    SUM(ip.preco_unitario * ip.quantidade) AS total_faturado
FROM
    Categoria cat
INNER JOIN
    Produto prod ON cat.categoria_id = prod.categoria_id
INNER JOIN
    ItemPedido ip ON prod.produto_id = ip.produto_id
GROUP BY
    cat.nome
ORDER BY
    total_faturado DESC;

-- 13. Fornecedores que entregaram produtos com atraso (Subquery)
-- Pergunta de Negócio: Quais fornecedores estão causando atrasos nas entregas?

SELECT DISTINCT
    f.nome AS nome_fornecedor
FROM
    Fornecedor f
INNER JOIN
    Estoque e ON f.fornecedor_id = e.fornecedor_id
INNER JOIN
    Produto p ON e.produto_id = p.produto_id
INNER JOIN
    ItemPedido ip ON p.produto_id = ip.produto_id
INNER JOIN
    Pedido ped ON ip.pedido_id = ped.pedido_id
INNER JOIN
    Entrega entrega ON ped.pedido_id = entrega.pedido_id
WHERE
    entrega.data_entrega_real > entrega.data_entrega_prevista;

--14. Qual o valor médio do pedido, considerando apenas os pedidos entregues?

SELECT AVG(valor_total) AS valor_medio_pedidos_entregues
FROM Pedido
WHERE pedido_id IN (SELECT pedido_id FROM Entrega WHERE status_entrega = 'Entregue');

--15. Qual a data do primeiro pedido de cada cliente?

SELECT c.nome, MIN(data_pedido) AS data_primeiro_pedido
FROM Cliente c
JOIN Pedido p ON c.cliente_id = p.cliente_id
GROUP BY c.nome
ORDER BY data_primeiro_pedido;