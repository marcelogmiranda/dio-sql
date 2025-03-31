-- =====================================================
-- Projeto de Banco de Dados para Clínica Veterinária
-- =====================================================

-- Criação do BD
CREATE DATABASE petvet
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- Criação das tabelas com constraints e defaults

-- Tabela de Clientes (Tutores dos animais)
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    endereco VARCHAR(200),
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    data_cadastro DATE DEFAULT CURRENT_DATE,
    ativo BOOLEAN DEFAULT TRUE
);

-- Índice para busca de clientes por nome
CREATE INDEX idx_clientes_nome ON clientes(nome);
-- Índice para busca de clientes por CPF
CREATE INDEX idx_clientes_cpf ON clientes(cpf);

-- Tabela de Espécies
CREATE TABLE especies (
    especie_id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

-- Tabela de Raças
CREATE TABLE racas (
    raca_id SERIAL PRIMARY KEY,
    especie_id INTEGER NOT NULL REFERENCES especies(especie_id) ON DELETE RESTRICT,
    nome VARCHAR(50) NOT NULL,
    UNIQUE(especie_id, nome)
);

-- Índice para busca de raças por nome
CREATE INDEX idx_racas_nome ON racas(nome);

-- Tabela de Animais (Pacientes)
CREATE TABLE animais (
    animal_id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(cliente_id) ON DELETE RESTRICT,
    nome VARCHAR(50) NOT NULL,
    especie_id INTEGER NOT NULL REFERENCES especies(especie_id) ON DELETE RESTRICT,
    raca_id INTEGER REFERENCES racas(raca_id) ON DELETE SET NULL,
    data_nascimento DATE,
    sexo CHAR(1) CHECK (sexo IN ('M', 'F')),
    cor VARCHAR(30),
    peso NUMERIC(5,2) CHECK (peso > 0),
    data_cadastro DATE DEFAULT CURRENT_DATE,
    ativo BOOLEAN DEFAULT TRUE,
    foto_url VARCHAR(255),
    observacoes TEXT
);

-- Índice para busca de animais por nome
CREATE INDEX idx_animais_nome ON animais(nome);
-- Índice para busca de animais por cliente
CREATE INDEX idx_animais_cliente ON animais(cliente_id);
-- Índice para busca de animais por espécie
CREATE INDEX idx_animais_especie ON animais(especie_id);

-- Tabela de Veterinários
CREATE TABLE veterinarios (
    veterinario_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    crmv VARCHAR(20) UNIQUE NOT NULL,
    especialidade VARCHAR(100),
    telefone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    data_contratacao DATE DEFAULT CURRENT_DATE,
    ativo BOOLEAN DEFAULT TRUE
);

-- Índice para busca de veterinários por nome
CREATE INDEX idx_veterinarios_nome ON veterinarios(nome);
-- Índice para busca de veterinários por CRMV
CREATE INDEX idx_veterinarios_crmv ON veterinarios(crmv);

-- Tabela de Tipos de Serviços
CREATE TABLE tipos_servicos (
    tipo_servico_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    preco_base NUMERIC(10,2) NOT NULL CHECK (preco_base >= 0),
    duracao_estimada INTEGER -- em minutos
);

-- Tabela de Agendamentos
CREATE TABLE agendamentos (
    agendamento_id SERIAL PRIMARY KEY,
    animal_id INTEGER NOT NULL REFERENCES animais(animal_id) ON DELETE RESTRICT,
    veterinario_id INTEGER NOT NULL REFERENCES veterinarios(veterinario_id) ON DELETE RESTRICT,
    tipo_servico_id INTEGER NOT NULL REFERENCES tipos_servicos(tipo_servico_id) ON DELETE RESTRICT,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendado' CHECK (status IN ('Agendado', 'Confirmado', 'Em andamento', 'Finalizado', 'Cancelado')),
    observacao TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para busca de agendamentos por data
CREATE INDEX idx_agendamentos_data ON agendamentos(data_hora);
-- Índice para busca de agendamentos por animal
CREATE INDEX idx_agendamentos_animal ON agendamentos(animal_id);
-- Índice para busca de agendamentos por veterinário
CREATE INDEX idx_agendamentos_veterinario ON agendamentos(veterinario_id);
-- Índice para busca de agendamentos por status
CREATE INDEX idx_agendamentos_status ON agendamentos(status);

-- Tabela de Consultas
CREATE TABLE consultas (
    consulta_id SERIAL PRIMARY KEY,
    agendamento_id INTEGER UNIQUE REFERENCES agendamentos(agendamento_id) ON DELETE RESTRICT,
    data_hora_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_hora_fim TIMESTAMP,
    sintomas TEXT,
    diagnostico TEXT,
    tratamento TEXT,
    observacoes TEXT,
    preco_final NUMERIC(10,2) CHECK (preco_final >= 0),
    pago BOOLEAN DEFAULT FALSE
);

-- Índice para busca de consultas por data
CREATE INDEX idx_consultas_data ON consultas(data_hora_inicio);

-- Tabela de Medicamentos
CREATE TABLE medicamentos (
    medicamento_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    fabricante VARCHAR(100),
    estoque INTEGER DEFAULT 0 CHECK (estoque >= 0),
    preco_unitario NUMERIC(10,2) NOT NULL CHECK (preco_unitario >= 0),
    principio_ativo VARCHAR(100),
    necessita_receita BOOLEAN DEFAULT FALSE
);

-- Índice para busca de medicamentos por nome
CREATE INDEX idx_medicamentos_nome ON medicamentos(nome);

-- Tabela de Prescrições
CREATE TABLE prescricoes (
    prescricao_id SERIAL PRIMARY KEY,
    consulta_id INTEGER NOT NULL REFERENCES consultas(consulta_id) ON DELETE CASCADE,
    medicamento_id INTEGER NOT NULL REFERENCES medicamentos(medicamento_id) ON DELETE RESTRICT,
    posologia TEXT NOT NULL,
    duracao VARCHAR(50) NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    observacoes TEXT
);

-- Tabela de Exames
CREATE TABLE exames (
    exame_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    preco NUMERIC(10,2) NOT NULL CHECK (preco >= 0)
);

-- Índice para busca de exames por nome
CREATE INDEX idx_exames_nome ON exames(nome);

-- Tabela de Exames Solicitados
CREATE TABLE exames_solicitados (
    exame_solicitado_id SERIAL PRIMARY KEY,
    consulta_id INTEGER NOT NULL REFERENCES consultas(consulta_id) ON DELETE CASCADE,
    exame_id INTEGER NOT NULL REFERENCES exames(exame_id) ON DELETE RESTRICT,
    data_solicitacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_realizacao TIMESTAMP,
    resultado TEXT,
    arquivo_resultado VARCHAR(255),
    observacoes TEXT,
    UNIQUE(consulta_id, exame_id)
);

-- Tabela de Vacinas
CREATE TABLE vacinas (
    vacina_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    intervalo_doses INTEGER, -- em dias
    preco NUMERIC(10,2) NOT NULL CHECK (preco >= 0)
);

-- Índice para busca de vacinas por nome
CREATE INDEX idx_vacinas_nome ON vacinas(nome);

-- Tabela de Vacinações
CREATE TABLE vacinacoes (
    vacinacao_id SERIAL PRIMARY KEY,
    animal_id INTEGER NOT NULL REFERENCES animais(animal_id) ON DELETE RESTRICT,
    vacina_id INTEGER NOT NULL REFERENCES vacinas(vacina_id) ON DELETE RESTRICT,
    veterinario_id INTEGER NOT NULL REFERENCES veterinarios(veterinario_id) ON DELETE RESTRICT,
    data_aplicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lote VARCHAR(50) NOT NULL,
    dose INTEGER DEFAULT 1,
    proxima_dose DATE,
    observacoes TEXT
);

-- Índice para busca de vacinações por animal
CREATE INDEX idx_vacinacoes_animal ON vacinacoes(animal_id);
-- Índice para busca de vacinações por data
CREATE INDEX idx_vacinacoes_data ON vacinacoes(data_aplicacao);

-- Tabela de Pagamentos
CREATE TABLE pagamentos (
    pagamento_id SERIAL PRIMARY KEY,
    consulta_id INTEGER REFERENCES consultas(consulta_id) ON DELETE RESTRICT,
    valor NUMERIC(10,2) NOT NULL CHECK (valor > 0),
    metodo_pagamento VARCHAR(50) NOT NULL,
    data_pagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    parcelas INTEGER DEFAULT 1 CHECK (parcelas >= 1),
    status VARCHAR(20) DEFAULT 'Concluído' CHECK (status IN ('Pendente', 'Concluído', 'Cancelado')),
    comprovante_url VARCHAR(255),
    observacoes TEXT
);

-- Índice para busca de pagamentos por consulta
CREATE INDEX idx_pagamentos_consulta ON pagamentos(consulta_id);
-- Índice para busca de pagamentos por status
CREATE INDEX idx_pagamentos_status ON pagamentos(status);

-- ============================
-- Triggers e Funções
-- ============================

-- Função e trigger para atualizar status do agendamento quando uma consulta é criada
CREATE OR REPLACE FUNCTION atualizar_status_agendamento()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE agendamentos SET status = 'Em andamento' WHERE agendamento_id = NEW.agendamento_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_consulta_iniciada
AFTER INSERT ON consultas
FOR EACH ROW
EXECUTE FUNCTION atualizar_status_agendamento();

-- Função e trigger para atualizar status do agendamento quando uma consulta é finalizada
CREATE OR REPLACE FUNCTION finalizar_agendamento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.data_hora_fim IS NOT NULL AND OLD.data_hora_fim IS NULL THEN
        UPDATE agendamentos SET status = 'Finalizado' WHERE agendamento_id = NEW.agendamento_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_consulta_finalizada
AFTER UPDATE ON consultas
FOR EACH ROW
EXECUTE FUNCTION finalizar_agendamento();

-- Função e trigger para atualizar estoque de medicamentos quando prescrito
CREATE OR REPLACE FUNCTION atualizar_estoque_medicamento()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE medicamentos SET estoque = estoque - NEW.quantidade 
    WHERE medicamento_id = NEW.medicamento_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_medicamento_prescrito
AFTER INSERT ON prescricoes
FOR EACH ROW
EXECUTE FUNCTION atualizar_estoque_medicamento();

-- Função e trigger para verificar disponibilidade do veterinário antes de agendar
CREATE OR REPLACE FUNCTION verificar_disponibilidade_veterinario()
RETURNS TRIGGER AS $$
DECLARE
    duracao INTEGER;
    conflito INTEGER;
BEGIN
    -- Obter a duração estimada do serviço
    SELECT duracao_estimada INTO duracao FROM tipos_servicos WHERE tipo_servico_id = NEW.tipo_servico_id;

    -- Verificar se existe agendamento conflitante (usando intervalo de tempo)
    SELECT COUNT(*) INTO conflito FROM agendamentos 
    WHERE veterinario_id = NEW.veterinario_id 
    AND status NOT IN ('Finalizado', 'Cancelado')
    AND (
        (data_hora <= NEW.data_hora AND data_hora + (duracao * interval '1 minute') > NEW.data_hora) OR
        (data_hora < NEW.data_hora + (duracao * interval '1 minute') AND data_hora >= NEW.data_hora)
    );

    IF conflito > 0 THEN
        RAISE EXCEPTION 'Veterinário não disponível neste horário';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_disponibilidade
BEFORE INSERT OR UPDATE ON agendamentos
FOR EACH ROW
EXECUTE FUNCTION verificar_disponibilidade_veterinario();

-- Função e trigger para calcular a data da próxima dose de vacina
CREATE OR REPLACE FUNCTION calcular_proxima_dose_vacina()
RETURNS TRIGGER AS $$
DECLARE
    intervalo INTEGER;
BEGIN
    -- Obter o intervalo entre doses da vacina
    SELECT intervalo_doses INTO intervalo FROM vacinas WHERE vacina_id = NEW.vacina_id;
    
    -- Se houver intervalo definido e não for a última dose, calcular a próxima
    IF intervalo IS NOT NULL THEN
        NEW.proxima_dose := NEW.data_aplicacao::date + (intervalo * interval '1 day');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calcular_proxima_vacina
BEFORE INSERT ON vacinacoes
FOR EACH ROW
EXECUTE FUNCTION calcular_proxima_dose_vacina();

-- Função e trigger para atualizar status de pagamento da consulta
CREATE OR REPLACE FUNCTION atualizar_status_pagamento_consulta()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Concluído' THEN
        UPDATE consultas SET pago = TRUE WHERE consulta_id = NEW.consulta_id;
    ELSE
        UPDATE consultas SET pago = FALSE WHERE consulta_id = NEW.consulta_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pagamento_concluido
AFTER INSERT OR UPDATE ON pagamentos
FOR EACH ROW
EXECUTE FUNCTION atualizar_status_pagamento_consulta();

-- ============================
-- Views
-- ============================

-- View para listar animais com informações do tutor
CREATE VIEW vw_animais_completo AS
SELECT 
    a.animal_id, 
    a.nome AS nome_animal, 
    a.data_nascimento, 
    a.sexo, 
    a.cor, 
    a.peso,
    e.nome AS especie, 
    r.nome AS raca, 
    c.cliente_id, 
    c.nome AS nome_tutor, 
    c.telefone
FROM animais a
JOIN clientes c ON a.cliente_id = c.cliente_id
JOIN especies e ON a.especie_id = e.especie_id
LEFT JOIN racas r ON a.raca_id = r.raca_id
WHERE a.ativo = TRUE;

-- View para consultas agendadas para o dia
CREATE VIEW vw_agenda_dia AS
SELECT 
    a.agendamento_id,
    a.data_hora,
    ts.nome AS tipo_servico,
    ts.duracao_estimada,
    an.nome AS nome_animal,
    an.animal_id,
    c.nome AS nome_cliente,
    c.telefone,
    v.nome AS nome_veterinario,
    a.status
FROM agendamentos a
JOIN animais an ON a.animal_id = an.animal_id
JOIN clientes c ON an.cliente_id = c.cliente_id
JOIN veterinarios v ON a.veterinario_id = v.veterinario_id
JOIN tipos_servicos ts ON a.tipo_servico_id = ts.tipo_servico_id
WHERE DATE(a.data_hora) = CURRENT_DATE
AND a.status NOT IN ('Finalizado', 'Cancelado')
ORDER BY a.data_hora;

-- View para histórico de consultas por animal
CREATE VIEW vw_historico_animal AS
SELECT 
    a.animal_id,
    a.nome AS nome_animal,
    c.nome AS nome_tutor,
    ag.data_hora,
    co.diagnostico,
    co.tratamento,
    v.nome AS veterinario,
    ts.nome AS tipo_servico
FROM animais a
JOIN clientes c ON a.cliente_id = c.cliente_id
JOIN agendamentos ag ON a.animal_id = ag.animal_id
JOIN consultas co ON ag.agendamento_id = co.agendamento_id
JOIN veterinarios v ON ag.veterinario_id = v.veterinario_id
JOIN tipos_servicos ts ON ag.tipo_servico_id = ts.tipo_servico_id
WHERE ag.status = 'Finalizado'
ORDER BY a.animal_id, ag.data_hora DESC;

-- View para controle de vacinação
CREATE VIEW vw_controle_vacinacao AS
SELECT 
    a.animal_id,
    a.nome AS nome_animal,
    c.nome AS nome_tutor,
    c.telefone,
    v.nome AS vacina,
    vac.data_aplicacao,
    vac.dose,
    vac.proxima_dose,
    CASE 
        WHEN vac.proxima_dose IS NOT NULL AND vac.proxima_dose <= CURRENT_DATE + interval '15 day' 
        THEN 'CONTATAR' 
        ELSE 'EM DIA' 
    END AS status
FROM animais a
JOIN clientes c ON a.cliente_id = c.cliente_id
JOIN vacinacoes vac ON a.animal_id = vac.animal_id
JOIN vacinas v ON vac.vacina_id = v.vacina_id
WHERE a.ativo = TRUE
ORDER BY a.animal_id, v.vacina_id, vac.data_aplicacao DESC;

-- View para relatório financeiro
CREATE VIEW vw_relatorio_financeiro AS
SELECT 
    DATE_TRUNC('month', p.data_pagamento) AS mes,
    SUM(p.valor) AS valor_total,
    COUNT(DISTINCT p.consulta_id) AS total_consultas,
    SUM(p.valor) / COUNT(DISTINCT p.consulta_id) AS ticket_medio,
    COUNT(DISTINCT c.cliente_id) AS total_clientes
FROM pagamentos p
JOIN consultas co ON p.consulta_id = co.consulta_id
JOIN agendamentos a ON co.agendamento_id = a.agendamento_id
JOIN animais an ON a.animal_id = an.animal_id
JOIN clientes c ON an.cliente_id = c.cliente_id
WHERE p.status = 'Concluído'
GROUP BY DATE_TRUNC('month', p.data_pagamento)
ORDER BY mes;

-- ============================
-- Inserção de dados iniciais
-- ============================

-- Inserção de tipos de espécies comuns
INSERT INTO especies (nome) VALUES 
('Canino'), 
('Felino'), 
('Ave'),
('Roedor'),
('Réptil');

-- Inserção de raças de cães
INSERT INTO racas (especie_id, nome) VALUES 
(1, 'Labrador Retriever'),
(1, 'Pastor Alemão'),
(1, 'Bulldog'),
(1, 'Poodle'),
(1, 'Golden Retriever'),
(1, 'Pinscher'),
(1, 'Shih Tzu'),
(1, 'Pit Bull'),
(1, 'SRD (Sem Raça Definida)');

-- Inserção de raças de gatos
INSERT INTO racas (especie_id, nome) VALUES 
(2, 'Siamês'),
(2, 'Persa'),
(2, 'Maine Coon'),
(2, 'Angorá'),
(2, 'Sphynx'),
(2, 'SRD (Sem Raça Definida)');

-- Inserção de tipos de serviços
INSERT INTO tipos_servicos (nome, descricao, preco_base, duracao_estimada) VALUES 
('Consulta de Rotina', 'Avaliação geral de saúde do animal', 120.00, 30),
('Consulta Emergencial', 'Atendimento de emergência', 200.00, 45),
('Vacinação', 'Aplicação de vacinas', 80.00, 15),
('Castração - Cão pequeno', 'Procedimento cirúrgico para cães até 10kg', 350.00, 90),
('Castração - Cão médio/grande', 'Procedimento cirúrgico para cães acima de 10kg', 450.00, 120),
('Castração - Gato', 'Procedimento cirúrgico para gatos', 300.00, 60),
('Exame de Sangue', 'Coleta e análise de sangue', 100.00, 20),
('Ultrassonografia', 'Exame de ultrassom', 180.00, 40),
('Limpeza Dentária', 'Procedimento de limpeza bucal', 250.00, 60);

-- Inserção de exames comuns
INSERT INTO exames (nome, descricao, preco) VALUES
('Hemograma Completo', 'Análise completa das células sanguíneas', 80.00),
('Perfil Bioquímico', 'Análise das funções hepática e renal', 120.00),
('Ultrassonografia Abdominal', 'Exame de imagem da cavidade abdominal', 180.00),
('Raio-X', 'Exame radiográfico', 150.00),
('Exame de Urina', 'Urinálise completa', 60.00),
('Exame de Fezes', 'Análise parasitológica', 50.00),
('Ecocardiograma', 'Exame de ultrassom do coração', 250.00),
('PCR', 'Teste para doenças infecciosas', 200.00);

-- Inserção de vacinas comuns
INSERT INTO vacinas (nome, descricao, intervalo_doses, preco) VALUES
('V8 ou V10 (Cães)', 'Vacina polivalente para cães', 21, 90.00),
('Antirrábica (Cães e Gatos)', 'Vacina contra raiva', 365, 70.00),
('Tríplice Felina', 'Vacina contra rinotraqueíte, calicivirose e panleucopenia', 21, 85.00),
('Giárdia (Cães)', 'Vacina contra giardíase', 21, 95.00),
('Gripe Canina', 'Vacina contra traqueobronquite infecciosa canina', 180, 80.00),
('FeLV (Felinos)', 'Vacina contra leucemia felina', 21, 100.00);

-- Inserção de medicamentos comuns
INSERT INTO medicamentos (nome, descricao, fabricante, estoque, preco_unitario, principio_ativo, necessita_receita) VALUES
('Drontal Plus', 'Vermífugo para cães', 'Bayer', 50, 35.00, 'Praziquantel, Pamoato de Pirantel, Febantel', FALSE),
('Frontline', 'Antipulgas e carrapatos', 'Merial', 40, 85.00, 'Fipronil', FALSE),
('Rimadyl', 'Anti-inflamatório para cães', 'Zoetis', 30, 95.00, 'Carprofeno', TRUE),
('Amoxicilina 250mg', 'Antibiótico para cães e gatos', 'Vetnil', 60, 45.00, 'Amoxicilina', TRUE),
('Dipirona Gotas', 'Analgésico e antitérmico', 'Biovet', 25, 30.00, 'Dipirona Sódica', FALSE),
('Prednisolona 20mg', 'Corticosteroide', 'Ouro Fino', 40, 40.00, 'Prednisolona', TRUE),
('Revolution (Gatos)', 'Antipulgas, carrapatos e vermes', 'Zoetis', 35, 90.00, 'Selamectina', FALSE);
