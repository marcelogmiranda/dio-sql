-- =====================================================
-- Consultas SQL para Análise e Gestão da Clínica Veterinária
-- =====================================================

-- 1. Qual é o faturamento mensal da clínica nos últimos 6 meses?
SELECT 
    TO_CHAR(data_pagamento, 'YYYY-MM') AS mes,
    SUM(valor) AS faturamento_total
FROM pagamentos
WHERE data_pagamento >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY TO_CHAR(data_pagamento, 'YYYY-MM')
ORDER BY mes DESC;

-- 2. Quais são os serviços mais realizados na clínica?
SELECT 
    ts.nome AS tipo_servico,
    COUNT(a.agendamento_id) AS quantidade,
    SUM(c.preco_final) AS valor_total,
    ROUND(AVG(c.preco_final), 2) AS valor_medio
FROM agendamentos a
JOIN tipos_servicos ts ON a.tipo_servico_id = ts.tipo_servico_id
JOIN consultas c ON a.agendamento_id = c.agendamento_id
WHERE a.status = 'Finalizado'
GROUP BY ts.nome
ORDER BY quantidade DESC;

-- 3. Qual é a taxa de ocupação dos veterinários?
SELECT 
    v.nome AS veterinario,
    COUNT(a.agendamento_id) AS total_agendamentos,
    SUM(ts.duracao_estimada) AS minutos_ocupados,
    ROUND(SUM(ts.duracao_estimada)::numeric / 
          (COUNT(DISTINCT DATE(a.data_hora)) * 480) * 100, 2) AS taxa_ocupacao_percentual
FROM agendamentos a
JOIN veterinarios v ON a.veterinario_id = v.veterinario_id
JOIN tipos_servicos ts ON a.tipo_servico_id = ts.tipo_servico_id
WHERE a.data_hora >= CURRENT_DATE - INTERVAL '30 days'
  AND a.status IN ('Finalizado', 'Em andamento')
GROUP BY v.nome
ORDER BY taxa_ocupacao_percentual DESC;

-- 4. Quais são os clientes mais frequentes e seu valor total gasto?
SELECT 
    c.nome AS cliente,
    COUNT(DISTINCT a.agendamento_id) AS total_visitas,
    SUM(p.valor) AS valor_total_gasto,
    COUNT(DISTINCT an.animal_id) AS qtd_animais,
    MAX(p.data_pagamento) AS ultima_visita
FROM clientes c
JOIN animais an ON c.cliente_id = an.cliente_id
JOIN agendamentos a ON an.animal_id = a.animal_id
JOIN consultas co ON a.agendamento_id = co.agendamento_id
JOIN pagamentos p ON co.consulta_id = p.consulta_id
WHERE p.status = 'Concluído'
GROUP BY c.nome
ORDER BY total_visitas DESC, valor_total_gasto DESC
LIMIT 20;

-- 5. Qual é a distribuição de pacientes por espécie e raça?
SELECT 
    e.nome AS especie,
    COALESCE(r.nome, 'Não especificada') AS raca,
    COUNT(a.animal_id) AS quantidade,
    ROUND(COUNT(a.animal_id) * 100.0 / (SELECT COUNT(*) FROM animais), 2) AS percentual
FROM animais a
JOIN especies e ON a.especie_id = e.especie_id
LEFT JOIN racas r ON a.raca_id = r.raca_id
GROUP BY e.nome, r.nome
ORDER BY e.nome, quantidade DESC;

-- 6. Quais animais estão com vacinas atrasadas?
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

-- 7. Qual é a taxa de agendamentos cancelados e os principais motivos?
SELECT 
    CASE WHEN ag.observacao IS NULL THEN 'Não informado' 
         ELSE ag.observacao END AS motivo_cancelamento,
    COUNT(*) AS quantidade,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) FROM agendamentos 
        WHERE status = 'Cancelado'
    ), 2) AS percentual
FROM agendamentos ag
WHERE ag.status = 'Cancelado'
GROUP BY motivo_cancelamento
ORDER BY quantidade DESC;

-- Taxa geral de cancelamentos
SELECT 
    COUNT(CASE WHEN status = 'Cancelado' THEN 1 END) AS total_cancelados,
    COUNT(*) AS total_agendamentos,
    ROUND(COUNT(CASE WHEN status = 'Cancelado' THEN 1 END) * 100.0 / COUNT(*), 2) AS taxa_cancelamento
FROM agendamentos
WHERE data_hora >= CURRENT_DATE - INTERVAL '90 days';

-- 8. Quais são os medicamentos mais prescritos e seu impacto no estoque?
SELECT 
    m.nome AS medicamento,
    COUNT(p.prescricao_id) AS total_prescricoes,
    SUM(p.quantidade) AS quantidade_total,
    m.estoque AS estoque_atual,
    ROUND(m.estoque * 1.0 / (SUM(p.quantidade) / 
          (EXTRACT(DAY FROM CURRENT_DATE - MIN(co.data_hora_inicio)) / 30)), 1) AS meses_restantes
FROM prescricoes p
JOIN medicamentos m ON p.medicamento_id = m.medicamento_id
JOIN consultas co ON p.consulta_id = co.consulta_id
GROUP BY m.nome, m.estoque
ORDER BY total_prescricoes DESC;

-- 9. Qual é o ticket médio por tipo de animal e faixa etária?
SELECT 
    e.nome AS especie,
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, a.data_nascimento)) < 1 THEN 'Filhote (< 1 ano)'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, a.data_nascimento)) BETWEEN 1 AND 7 THEN 'Adulto (1-7 anos)'
        ELSE 'Idoso (> 7 anos)'
    END AS faixa_etaria,
    COUNT(DISTINCT co.consulta_id) AS total_consultas,
    ROUND(AVG(co.preco_final), 2) AS ticket_medio,
    MIN(co.preco_final) AS valor_minimo,
    MAX(co.preco_final) AS valor_maximo
FROM animais a
JOIN especies e ON a.especie_id = e.especie_id
JOIN agendamentos ag ON a.animal_id = ag.animal_id
JOIN consultas co ON ag.agendamento_id = co.agendamento_id
WHERE a.data_nascimento IS NOT NULL
GROUP BY e.nome, faixa_etaria
ORDER BY e.nome, faixa_etaria;

-- 10. Como está a sazonalidade de atendimentos ao longo do ano?
SELECT 
    EXTRACT(MONTH FROM data_hora) AS mes,
    TO_CHAR(data_hora, 'Month') AS nome_mes,
    COUNT(*) AS total_agendamentos,
    COUNT(DISTINCT animal_id) AS total_animais,
    ROUND(AVG(
        CASE WHEN EXISTS (
            SELECT 1 FROM consultas c 
            WHERE c.agendamento_id = agendamentos.agendamento_id
        ) THEN 1.0 ELSE 0.0 END
    ) * 100, 2) AS taxa_comparecimento
FROM agendamentos
WHERE data_hora >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY EXTRACT(MONTH FROM data_hora), TO_CHAR(data_hora, 'Month')
ORDER BY mes;

-- 11. Quais são os dias e horários com maior demanda?
SELECT 
    EXTRACT(DOW FROM data_hora) AS dia_semana,
    TO_CHAR(data_hora, 'Day') AS nome_dia,
    EXTRACT(HOUR FROM data_hora) AS hora,
    COUNT(*) AS total_agendamentos
FROM agendamentos
WHERE data_hora >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY dia_semana, nome_dia, hora
ORDER BY total_agendamentos DESC;

-- 12. Qual é a eficiência dos veterinários (tempo médio por consulta)?
SELECT 
    v.nome AS veterinario,
    COUNT(co.consulta_id) AS total_consultas,
    ROUND(AVG(EXTRACT(EPOCH FROM (co.data_hora_fim - co.data_hora_inicio)) / 60), 2) AS tempo_medio_minutos,
    ROUND(AVG(co.preco_final), 2) AS valor_medio_consulta
FROM veterinarios v
JOIN agendamentos a ON v.veterinario_id = a.veterinario_id
JOIN consultas co ON a.agendamento_id = co.agendamento_id
WHERE co.data_hora_fim IS NOT NULL
GROUP BY v.nome
ORDER BY tempo_medio_minutos;

-- 13. Quais são os diagnósticos mais comuns por espécie?
WITH diagnosticos_normalizados AS (
    SELECT 
        e.nome AS especie,
        TRIM(REGEXP_SPLIT_TO_TABLE(LOWER(co.diagnostico), '[,;.]')) AS diagnostico_individual
    FROM consultas co
    JOIN agendamentos a ON co.agendamento_id = a.agendamento_id
    JOIN animais an ON a.animal_id = an.animal_id
    JOIN especies e ON an.especie_id = e.especie_id
    WHERE co.diagnostico IS NOT NULL AND co.diagnostico != ''
)
SELECT 
    especie,
    diagnostico_individual,
    COUNT(*) AS ocorrencias,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY especie), 2) AS percentual
FROM diagnosticos_normalizados
WHERE LENGTH(diagnostico_individual) > 3
GROUP BY especie, diagnostico_individual
HAVING COUNT(*) > 2
ORDER BY especie, ocorrencias DESC;

-- 14. Qual o tempo médio entre o agendamento e a realização da consulta?
SELECT 
    ts.nome AS tipo_servico,
    ROUND(AVG(EXTRACT(EPOCH FROM (a.data_hora - a.data_criacao)) / 86400), 1) AS dias_espera_media,
    MIN(EXTRACT(EPOCH FROM (a.data_hora - a.data_criacao)) / 86400) AS dias_espera_minima,
    MAX(EXTRACT(EPOCH FROM (a.data_hora - a.data_criacao)) / 86400) AS dias_espera_maxima,
    COUNT(*) AS total_agendamentos
FROM agendamentos a
JOIN tipos_servicos ts ON a.tipo_servico_id = ts.tipo_servico_id
WHERE a.status = 'Finalizado'
GROUP BY ts.nome
ORDER BY dias_espera_media DESC;

-- 15. Qual o índice de fidelização de clientes (retorno após primeira consulta)?
WITH primeira_consulta AS (
    SELECT 
        c.cliente_id,
        MIN(a.data_hora) AS primeira_data
    FROM clientes c
    JOIN animais an ON c.cliente_id = an.cliente_id
    JOIN agendamentos a ON an.animal_id = a.animal_id
    GROUP BY c.cliente_id
),
consultas_subsequentes AS (
    SELECT 
        c.cliente_id,
        COUNT(DISTINCT a.agendamento_id) AS total_consultas,
        MAX(a.data_hora) - MIN(a.data_hora) AS periodo_relacionamento
    FROM clientes c
    JOIN animais an ON c.cliente_id = an.cliente_id
    JOIN agendamentos a ON an.animal_id = a.animal_id
    GROUP BY c.cliente_id
)
SELECT 
    COUNT(CASE WHEN cs.total_consultas > 1 THEN 1 END) AS clientes_retornaram,
    COUNT(pc.cliente_id) AS total_clientes,
    ROUND(COUNT(CASE WHEN cs.total_consultas > 1 THEN 1 END) * 100.0 / COUNT(pc.cliente_id), 2) AS taxa_retorno,
    ROUND(AVG(CASE WHEN cs.total_consultas > 1 THEN cs.total_consultas ELSE NULL END), 2) AS media_consultas_por_cliente_fiel,
    ROUND(AVG(EXTRACT(DAY FROM cs.periodo_relacionamento) / 30), 1) AS media_meses_relacionamento
FROM primeira_consulta pc
JOIN consultas_subsequentes cs ON pc.cliente_id = cs.cliente_id
WHERE pc.primeira_data < CURRENT_DATE - INTERVAL '3 months';

-- 16. Como está evoluindo o cadastro de novos clientes?
SELECT 
    TO_CHAR(data_cadastro, 'YYYY-MM') AS mes,
    COUNT(*) AS novos_clientes,
    SUM(COUNT(*)) OVER (ORDER BY TO_CHAR(data_cadastro, 'YYYY-MM')) AS total_acumulado
FROM clientes
WHERE data_cadastro >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY TO_CHAR(data_cadastro, 'YYYY-MM')
ORDER BY mes;

-- 17. Análise de rentabilidade por procedimento
SELECT 
    ts.nome AS tipo_servico,
    COUNT(co.consulta_id) AS quantidade,
    ROUND(AVG(co.preco_final), 2) AS preco_medio_cobrado,
    ts.preco_base AS preco_base,
    ROUND(AVG(co.preco_final) - ts.preco_base, 2) AS diferenca_media,
    ROUND((AVG(co.preco_final) - ts.preco_base) / ts.preco_base * 100, 2) AS percentual_ajuste
FROM tipos_servicos ts
JOIN agendamentos a ON ts.tipo_servico_id = a.tipo_servico_id
JOIN consultas co ON a.agendamento_id = co.agendamento_id
WHERE a.status = 'Finalizado'
GROUP BY ts.nome, ts.preco_base
ORDER BY percentual_ajuste DESC;

-- 18. Quais clientes não retornam há mais de 6 meses e deveriam ser contatados?
SELECT 
    c.nome AS cliente,
    c.telefone,
    c.email,
    COUNT(an.animal_id) AS total_animais,
    MAX(a.data_hora) AS ultima_visita,
    CURRENT_DATE - MAX(a.data_hora) AS dias_sem_visita
FROM clientes c
JOIN animais an ON c.cliente_id = an.cliente_id
JOIN agendamentos a ON an.animal_id = a.animal_id
WHERE c.ativo = TRUE
GROUP BY c.cliente_id, c.nome, c.telefone, c.email
HAVING MAX(a.data_hora) < CURRENT_DATE - INTERVAL '6 months'
   AND MAX(a.data_hora) > CURRENT_DATE - INTERVAL '12 months'
ORDER BY dias_sem_visita DESC;

-- 19. Qual a efetividade dos tratamentos (taxa de retorno pelo mesmo problema)?
WITH consultas_problemas AS (
    SELECT 
        an.animal_id,
        a.agendamento_id,
        a.data_hora,
        LOWER(co.sintomas) AS sintomas,
        LOWER(co.diagnostico) AS diagnostico
    FROM consultas co
    JOIN agendamentos a ON co.agendamento_id = a.agendamento_id
    JOIN animais an ON a.animal_id = an.animal_id
    WHERE co.sintomas IS NOT NULL AND co.diagnostico IS NOT NULL
)
SELECT 
    cp1.diagnostico,
    COUNT(DISTINCT cp1.animal_id) AS total_animais,
    COUNT(DISTINCT cp1.agendamento_id) AS total_ocorrencias,
    ROUND(COUNT(DISTINCT cp1.agendamento_id)::numeric / COUNT(DISTINCT cp1.animal_id), 2) AS media_recorrencia,
    ROUND(AVG(cp2.data_hora - cp1.data_hora), 1) AS media_dias_reincidencia
FROM consultas_problemas cp1
JOIN consultas_problemas cp2 ON 
    cp1.animal_id = cp2.animal_id AND
    cp1.agendamento_id <> cp2.agendamento_id AND
    cp1.data_hora < cp2.data_hora AND
    (
        cp2.sintomas LIKE '%' || cp1.sintomas || '%' OR
        cp2.diagnostico LIKE '%' || cp1.diagnostico || '%'
    )
GROUP BY cp1.diagnostico
HAVING COUNT(DISTINCT cp1.animal_id) > 2
ORDER BY media_recorrencia DESC;

-- 20. Qual a previsão de agendamentos para as próximas semanas?
SELECT 
    DATE_TRUNC('week', data_hora) AS semana,
    TO_CHAR(DATE_TRUNC('week', data_hora), 'DD/MM/YYYY') AS inicio_semana,
    COUNT(*) AS total_agendamentos,
    STRING_AGG(DISTINCT v.nome, ', ') AS veterinarios,
    COUNT(DISTINCT a.animal_id) AS total_animais,
    SUM(ts.preco_base) AS receita_prevista
FROM agendamentos a
JOIN veterinarios v ON a.veterinario_id = v.veterinario_id
JOIN tipos_servicos ts ON a.tipo_servico_id = ts.tipo_servico_id
WHERE data_hora > CURRENT_DATE AND data_hora < CURRENT_DATE + INTERVAL '4 weeks'
AND status NOT IN ('Cancelado', 'Finalizado')
GROUP BY DATE_TRUNC('week', data_hora)
ORDER BY semana;
