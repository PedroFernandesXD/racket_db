#lang racket

(require db)

(define (cnn) (postgresql-connect #:user "postgres"
                                  #:password "ama"
                                  #:port 5432
                                  #:server "localhost"
                                  #:database "trab_db"))

(define tb-cond
  "CREATE TABLE trab_db.tb_condominio
  (
    cod_condominio serial NOT NULL,
    nome    character varying(30),
    cidade  character varying(30),
    bairro  character varying(30),
    rua character varying(40) COLLATE pg_catalog.\"default\",
    num integer,
    tempo timestamp,
    gasto numeric,
    CONSTRAINT tb_condominio_pkey PRIMARY KEY (cod_condominio)
 )"
)

(define tb-prd
  "CREATE TABLE trab_db.tb_predio
  (
    cod_predio serial NOT NULL,
    num integer,
    gasto numeric,
    tempo timestamp,
    CONSTRAINT tb_predio_pkey PRIMARY KEY (cod_predio)
  )"
)

(define tb-apart
  "CREATE TABLE trab_db.tb_apartamento
  (
    cod_apartamento serial NOT NULL,
    nome_proprietario character varying COLLATE pg_catalog.\"default\",
    telefone integer,
    tempo timestamp,
    gasto numeric,
    CONSTRAINT tb_apartamento_pkey PRIMARY KEY (cod_apartamento)
)")

(define tb-com
  "CREATE TABLE trab_db.tb_comodo
  (
    cod_comodo serial NOT NULL,
    nome_comodo character varying COLLATE pg_catalog.\"default\",
    tempo timestamp,
    gasto numeric,
    CONSTRAINT tb_comodo_pkey PRIMARY KEY (cod_comodo)
)")

(define tb-tmd
  "CREATE TABLE trab_db.tb_tomada
    (
        cod_tomada serial NOT NULL,
        tempo timestamp,
        gastotomada numeric,
        CONSTRAINT tb_tomada_pkey PRIMARY KEY (cod_tomada)
    )")

(define tb-loc-tmd-com
  "CREATE TABLE trab_db.loc_tomada_comodo
  (
    cod_tomada integer NOT NULL,
    cod_comodo integer,
    CONSTRAINT loc_tomada_comodo_pkey PRIMARY KEY (cod_tomada),
    CONSTRAINT cod_comodo FOREIGN KEY (cod_comodo)
        REFERENCES trab_db.tb_comodo (cod_comodo) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT cod_tomada FOREIGN KEY (cod_tomada)
        REFERENCES trab_db.tb_tomada (cod_tomada) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
  )"
 )

(define tb-loc-com-apart
  "CREATE TABLE trab_db.loc_comodo_apartamento
(
    cod_comodo integer NOT NULL,
    cod_apartamento integer,
    CONSTRAINT loc_comodo_apartamento_pkey PRIMARY KEY (cod_comodo),
    CONSTRAINT cod_apartamento FOREIGN KEY (cod_apartamento)
        REFERENCES trab_db.tb_apartamento (cod_apartamento) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT cod_comodo FOREIGN KEY (cod_comodo)
        REFERENCES trab_db.tb_comodo (cod_comodo) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)")

(define tb-loc-apart-prd
"CREATE TABLE trab_db.loc_apartamento_predio
(
    cod_apartamento integer NOT NULL,
    cod_predio integer,
    CONSTRAINT loc_apartamento_predio_pkey PRIMARY KEY (cod_apartamento),
    CONSTRAINT cod_apartamento FOREIGN KEY (cod_apartamento)
        REFERENCES trab_db.tb_apartamento (cod_apartamento) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT cod_predio FOREIGN KEY (cod_predio)
        REFERENCES trab_db.tb_predio (cod_predio) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)")

(define tb-loc-prd-cond
  "CREATE TABLE trab_db.loc_predio_condominio
(
    cod_predio integer NOT NULL,
    cod_condominio integer,
    CONSTRAINT loc_predio_condominio_pkey PRIMARY KEY (cod_predio),
    CONSTRAINT cod_condominio FOREIGN KEY (cod_condominio)
        REFERENCES trab_db.tb_condominio (cod_condominio) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT cod_predio FOREIGN KEY (cod_predio)
        REFERENCES trab_db.tb_predio (cod_predio) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)")

(define list-tb (list tb-cond tb-prd tb-apart tb-com tb-tmd tb-loc-tmd-com tb-loc-com-apart tb-loc-apart-prd tb-loc-prd-cond))

#|
(define (creat-tb)
  (cnn)
  (for ([i list-tb])
    (if (empty? i)
        (printf "Tabelas criadas.\n")
        (query-exec (cnn) i)))
  (disconnect (cnn)))
|#

(define (creat-tb)
  (let loop ([i list-tb])
    (if (empty? i)
        (printf "Tabelas Criadas.\n")
        (and (query-exec (cnn) (car i)) (loop (cdr i)))
        ))
  (disconnect (cnn)))
        