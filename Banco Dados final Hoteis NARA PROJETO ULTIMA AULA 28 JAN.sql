-- =====================================================
-- PROJETO NARA HOTELS - DIMENSÕES (D_) + FATOS (F_)
-- =====================================================

-- 1) Criação do banco de dados
CREATE DATABASE NARAHOTEIS;

-- 2) Seleciona o banco para uso
USE NARAHOTEIS;

-- =====================================================
-- 3) TABELAS DE DIMENSÃO (D_)
-- =====================================================

-- Dimensão: Data (d_data.csv)
CREATE TABLE d_data (
    data_id INT PRIMARY KEY,
    data_data DATE,
    ano INT,
    mes INT,
    nome_mes VARCHAR(10),
    trimestre INT,
    dia_semana INT,
    fim_de_semana_flag INT,
    feriado_flag INT,
    alta_temporada_flag INT);

-- Dimensão: Hotel (d_hotel.csv)
CREATE TABLE d_hotel (
    hotel_id INT PRIMARY KEY,
    nome VARCHAR(100),
    cidade VARCHAR(100),
    uf VARCHAR(20),
    categoria_estrelas INT,
    possui_spa_flag TINYINT
);

-- Dimensão: Tipo de Quarto (d_tipo_quarto.csv)
CREATE TABLE d_tipo_quarto (
    tipo_quarto_id INT PRIMARY KEY,
    tipo_quarto VARCHAR(50),
    capacidade INT
);

-- Dimensão: Canal (d_canal.csv)
CREATE TABLE d_canal (
    canal_id INT PRIMARY KEY,
    canal_nome VARCHAR(50),
    canal_grupo VARCHAR(20)
);

-- Dimensão: Agência (d_agencia.csv)
CREATE TABLE d_agencia (
    agencia_id INT PRIMARY KEY,
    nome VARCHAR(100),
    tipo VARCHAR(20),
    comissao_pct DECIMAL(6,3)
);
-- A coluna comissao_pct utiliza o tipo DECIMAL(6,3) para armazenar valores percentuais
-- com precisão, permitindo até 6 dígitos no total, sendo 3 casas decimais.

-- Dimensão: Plano Tarifário (d_plano_tarifario.csv)
CREATE TABLE d_plano_tarifario (
    rate_plan_id INT PRIMARY KEY,
    nome_plano VARCHAR(120),
    reembolsavel_flag INT,
    cafe_incluso_flag INT,
    politica_cancelamento VARCHAR(255)
);

-- Dimensão: Hóspede (d_hospede.csv)
CREATE TABLE d_hospede (
    hospede_id INT PRIMARY KEY,
    pais VARCHAR(50),
    uf VARCHAR(2),
    cidade VARCHAR(100),
    faixa_etaria VARCHAR(20),
    segmento VARCHAR(20)
);

-- Dimensão: Motivo de Cancelamento (d_motivo_cancelamento.csv)
CREATE TABLE d_motivo_cancelamento (
    motivo_id INT PRIMARY KEY,
    categoria VARCHAR(50),
    descricao VARCHAR(255)
);

-- =====================================================
-- 4) TABELAS FATO (F_)
-- (Tratadas pelo Python: f_reservanovo.csv, f_diarianovo.csv, f_reviewsnovo.csv)
-- =====================================================

-- Fato: Reservas (f_reservanovo.csv)  [delimitador ;]
CREATE TABLE f_reservanovo (
    reserva_id INT PRIMARY KEY,
    data_reserva_id INT,
    data_cancelamento_id INT,
    motivo_cancelamento_id INT,
    checkin_id INT,
    checkout_id INT,
    hotel_id INT,
    hospede_id INT,
    canal_id INT,
    agencia_id INT,
    rate_plan_id INT,
    tipo_quarto VARCHAR(50),
    status_reserva VARCHAR(20),
    adultos INT,
    criancas INT,
    valor_previsto DECIMAL(12,2),
    desconto DECIMAL(12,2),
    moeda VARCHAR(13),
    FOREIGN KEY (motivo_cancelamento_id) REFERENCES d_motivo_cancelamento(motivo_id),
	FOREIGN KEY (hotel_id) REFERENCES d_hotel(hotel_id),
	FOREIGN KEY (hospede_id) REFERENCES d_hospede(hospede_id),
	FOREIGN KEY (canal_id) REFERENCES d_canal(canal_id),
	FOREIGN KEY (agencia_id) REFERENCES d_agencia(agencia_id),
	FOREIGN KEY (rate_plan_id) REFERENCES d_plano_tarifario(rate_plan_id)
);

-- Fato: Diárias / Receita estimada (f_diarianovo.csv)  [delimitador ;]
CREATE TABLE f_diarianovo (
hotel_id INT,
data_id date,
tipo_quarto VARCHAR(100),
quartos_vendidos INT,
adr_estimado DECIMAL(12,2),
receita_diarias DECIMAL(14,2)
);
drop table f_diarianovo;

CREATE TABLE f_inventario_diario (
hotel_id INT,
data_id INT,
tipo_quarto VARCHAR(100),
quartos_total INT,
quartos_manutencao INT,
quartos_disponiveis INT,
FOREIGN KEY (hotel_id) REFERENCES d_hotel(hotel_id),
FOREIGN KEY (data_id) REFERENCES d_data(data_id)

);
-- falta subir o arquivo. --

-- Fato: Reviews (f_reviewsnovo.csv)  [delimitador ;]
CREATE TABLE f_reviewsnovo (
    review_id INT PRIMARY KEY,
    reserva_id INT,
    data_review_id INT,
    nota DECIMAL(4,1),
    limpeza DECIMAL(4,1),
    localizacao DECIMAL(4,1),
    atendimento DECIMAL(4,1),
    comentario_flag INT
);

CREATE TABLE f_pagamentos (
	pagamento_id INT PRIMARY KEY,
    reserva_id INT,
    data_pagamento_id INT,
    forma_pagamento VARCHAR(100),
    valor_pago DECIMAL(10,2),
    status_pagamento VARCHAR(100),
    taxa_gateway DECIMAL(10,2),
    FOREIGN KEY (reserva_id) REFERENCES f_reservanovo(reserva_id)
);


    
    
-- =====================================================
-- 5) IMPORTAÇÃO DOS CSVs
-- - Dimensões (D_): C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/
-- - Fatos (F_): C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/
-- =====================================================

SET GLOBAL local_infile = 1;

-- -------------------------------
-- 5.1) Carregamento das DIMENSÕES 
-- -------------------------------
LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/d_data.csv"
INTO TABLE d_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(data_id,data_data,ano,mes,nome_mes,trimestre,dia_semana,fim_de_semana_flag,feriado_flag,alta_temporada_flag);

SELECT* FROM d_data;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/d_hotel.csv"
INTO TABLE d_hotel
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(hotel_id, nome, cidade, uf, categoria_estrelas, possui_spa_flag);

SELECT* FROM d_hotel;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/d_tipo_quarto.csv"
INTO TABLE d_tipo_quarto
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tipo_quarto_id, tipo_quarto, capacidade);

SELECT* FROM d_tipo_quarto;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/d_canal.csv"
INTO TABLE d_canal
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(canal_id, canal_nome, canal_grupo);

SELECT* FROM d_canal;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/d_agencia.csv"
INTO TABLE d_agencia
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(agencia_id, nome, tipo, comissao_pct);

SELECT* FROM d_agencia;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/d_plano_tarifario.csv"
INTO TABLE d_plano_tarifario
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(rate_plan_id, nome_plano, reembolsavel_flag, cafe_incluso_flag, politica_cancelamento);

SELECT* FROM d_plano_tarifario;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/d_hospede.csv"
INTO TABLE d_hospede
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(hospede_id, pais, uf, cidade, faixa_etaria, segmento);

SELECT* FROM d_hospede;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/d_motivo_cancelamento.csv"
INTO TABLE d_motivo_cancelamento
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(motivo_id, categoria, descricao);

SELECT* FROM d_motivo_cancelamento;

-- -------------------------------
-- 5.2) Carregamento d FATOS 
-- -------------------------------

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/f_reservanovo.csv"
INTO TABLE f_reservanovo
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(reserva_id,data_reserva_id,data_cancelamento_id,motivo_cancelamento_id,checkin_id,checkout_id,hotel_id,hospede_id,canal_id, agencia_id,rate_plan_id,
tipo_quarto,status_reserva,adultos,criancas,valor_previsto,desconto,moeda);

SELECT* FROM f_reservanovo;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/f_diarianovo.csv"
INTO TABLE f_diarianovo
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(hotel_id, data_id, tipo_quarto, quartos_vendidos, adr_estimado, receita_diarias);

SELECT* FROM f_diarianovo;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/f_reviewsnovo.csv"
INTO TABLE f_reviewsnovo
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(review_id, reserva_id, data_review_id, nota, limpeza, localizacao, atendimento, comentario_flag)
;
SELECT* FROM f_reviewsnovo;

LOAD DATA INFILE "C:/Users/lucas.dionisio/Downloads/ProjetoHoteisNara/f_pagamentos.csv"
INTO TABLE f_pagamentos
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pagamento_id,reserva_id,data_pagamento_id,forma_pagamento,valor_pago,status_pagamento,taxa_gateway)
;
SELECT* FROM f_pagamentos;

-- =====================================================
-- PROJETO NARA HOTÉIS
-- CONSULTAS SQL (Queries Analíticas)
-- =====================================================
-- 1) Total de reservas realizadas por hotel
SELECT d_hotel.nome AS hotel,
       COUNT(f_reservanovo.reserva_id) AS total_reservas
FROM f_reservanovo
JOIN d_hotel
  ON f_reservanovo.hotel_id = d_hotel.hotel_id
GROUP BY d_hotel.nome;
#Esta consulta utiliza JOIN para relacionar as reservas aos hotéis e COUNT para contar
# quantas reservas existem em cada hotel, agrupando os resultados pelo nome do hotel.


-- 2) Quantidade de reservas por canal de venda
SELECT d_canal.canal_nome AS canal,
       COUNT(f_reservanovo.reserva_id) AS total_reservas
FROM f_reservanovo
JOIN d_canal
  ON f_reservanovo.canal_id = d_canal.canal_id
GROUP BY d_canal.canal_nome;
#Esta consulta relaciona as reservas com os canais de venda por meio de JOIN e utiliza
#GROUP BY para agrupar os dados por canal, permitindo contar as reservas de cada canal.



-- 3) Valor total previsto das reservas por hotel
SELECT d_hotel.nome AS hotel,
       SUM(f_reservanovo.valor_previsto) AS valor_total_previsto
FROM f_reservanovo
JOIN d_hotel
  ON f_reservanovo.hotel_id = d_hotel.hotel_id
GROUP BY d_hotel.nome;
#Esta consulta soma o valor previsto das reservas usando SUM e relaciona os dados
#com a tabela de hotéis para apresentar o valor total de reservas por hotel.


-- 4) Quantidade de reservas por status (ex.: confirmada, cancelada, concluída)
SELECT f_reservanovo.status_reserva AS status_reserva,
       COUNT(f_reservanovo.reserva_id) AS total_reservas
FROM f_reservanovo
GROUP BY f_reservanovo.status_reserva;
#Esta consulta agrupa as reservas de acordo com o status da reserva e utiliza COUNT
#para mostrar a quantidade de reservas em cada situação.

-- 5) Quantidade de reservas canceladas por motivo
SELECT d_motivo_cancelamento.descricao AS motivo_cancelamento,
       COUNT(f_reservanovo.reserva_id) AS total_cancelamentos
FROM f_reservanovo
JOIN d_motivo_cancelamento
  ON f_reservanovo.motivo_cancelamento_id = d_motivo_cancelamento.motivo_id
GROUP BY d_motivo_cancelamento.descricao;
#Esta consulta utiliza JOIN para associar as reservas aos motivos de cancelamento e
#COUNT para identificar quantas reservas foram canceladas por cada motivo.


-- 6) Nota média dos hotéis com base nas avaliações
SELECT d_hotel.nome AS hotel,
       AVG(f_reviewsnovo.nota) AS nota_media
FROM f_reviewsnovo
JOIN f_reservanovo
  ON f_reviewsnovo.reserva_id = f_reservanovo.reserva_id
JOIN d_hotel
  ON f_reservanovo.hotel_id = d_hotel.hotel_id
GROUP BY d_hotel.nome;
#Esta consulta relaciona avaliações, reservas e hotéis por meio de JOIN e utiliza AVG
#para calcular a nota média dos hotéis com base nas avaliações registradas.

-- 7) Quantidade de avaliações realizadas por hotel
SELECT d_hotel.nome AS hotel,
       COUNT(f_reviewsnovo.review_id) AS total_avaliacoes
FROM f_reviewsnovo
JOIN f_reservanovo
  ON f_reviewsnovo.reserva_id = f_reservanovo.reserva_id
JOIN d_hotel
  ON f_reservanovo.hotel_id = d_hotel.hotel_id
GROUP BY d_hotel.nome;
#Esta consulta utiliza JOIN para associar as avaliações aos hotéis e COUNT para
#contabilizar o número de avaliações realizadas para cada hotel.


-- 8) Receita total de diárias por hotel
SELECT d_hotel.nome AS hotel,
       SUM(f_diarianovo.receita_diarias) AS receita_total_diarias
FROM f_diarianovo
JOIN d_hotel
  ON f_diarianovo.hotel_id = d_hotel.hotel_id
GROUP BY d_hotel.nome;
#Esta consulta relaciona as diárias com os hotéis e utiliza SUM para calcular
#o total de receita gerada por diárias em cada hotel.

-- 9) ADR médio (diária média) por hotel
SELECT d_hotel.nome AS hotel,
       AVG(f_diarianovo.adr_estimado) AS adr_medio
FROM f_diarianovo
JOIN d_hotel
  ON f_diarianovo.hotel_id = d_hotel.hotel_id
GROUP BY d_hotel.nome;
#Esta consulta utiliza AVG para calcular a diária média estimada e JOIN para
#relacionar os dados de diárias com os respectivos hotéis.

-- 10) Quantidade de hóspedes por faixa etária
SELECT d_hospede.faixa_etaria AS faixa_etaria,
       COUNT(d_hospede.hospede_id) AS total_hospedes
FROM d_hospede
GROUP BY d_hospede.faixa_etaria;
#Esta consulta utiliza GROUP BY para agrupar os hóspedes por faixa etária e COUNT
#para identificar a quantidade de hóspedes em cada grupo.
