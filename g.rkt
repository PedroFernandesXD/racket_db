#lang at-exp racket

(require db)

(define user-admin "postgres")
(define password-admin "ama")

(define med1 (build-list 10 (lambda (x) (abs (sin x)))))
(define med2 (build-list 10 (lambda (x) (abs (cos x)))))

(define (cr1)
  (list-ref (cdr med1) (random 9)))

(define (cr2)
  (list-ref med2 (random 10)))

;; Conexao com outros usuarios.
;; USE: (cnn user password)
(define (cnn-user usuario senha)
  (postgresql-connect #:user usuario
                      #:password senha
                      #:server "localhost"
                      #:database "trab_db"))

;;----------INPUT VALORES SIMULADO DE CORRENTE TOMADA 1 E 2-------------------------;;
;; USE: (input1 "postgres" "ama")

(define (input1 user password)
  (query-exec (cnn-user user password)
              (let ([c (cr1)])
                (string-append
                 "insert into trab_db.tb_tomada(tempo,gastotomada) values ('now',"
                 (number->string (/ (* c 110) 1000))
                 ")")))
  (disconnect (cnn-user user password)))


(define (input2 user password)
  (query-exec (cnn-user user password)
             (let ([c (cr2)])
              (string-append
               "INSERT INTO trab_db.tb_tomada(tempo,gastotomada) values ('now',"
               (number->string (/ (* c 110) 1000)) ")")))
  (disconnect (cnn-user)))


(define (simular x)
  (let loop ([i 10])
    (if (not (zero? i))
        (and (and x (sleep 1)) (printf "Simulacao Completa.\n"))
        (loop (- i 1)))
    ))

;;---------------------------------INSERT CONDOMINIO---------------------------------;;



(define (insert-cond user password nome cidade bairro rua gasto)
  (query-exec (cnn-user user password)
              @~a{INSERT INTO trab_db.tb_condominio(nome,cidade,bairro,rua,num,tempo,gasto)
                  VALUES (?,?,?,?,?,'now',?)} nome cidade bairro rua gasto)
  (disconnect (cnn-user user password)))


;;----------------------------------INSERT PREDIO ------------------------------------;;

(define (insert-prd user password num gasto)
  (query-exec (cnn-user user password)
              @~a{INSERT INTO trab_db.tb_predio(num,gasto,tempo)
                  VALUES (?,?,'now')} num gasto)
  (disconnect (cnn-user user password)))


;;---------------------------------INSERT APARTAMENTO--------------------------------;;

(define (insert-apart user password nome-prop telefone gasto)
  (query-exec (cnn-user user password)
              @~a{INSERT INTO trab_db.tb_apartamento(nome_proprietario,telefone,tempo,gasto)
                  VALUES(?,?,'now',?)} nome-prop telefone gasto)
  (disconnect (cnn-user user password)))

;;--------------------------------INSERT COMODO--------------------------------------;;

(define (insert-com user password nome gasto)
  (query-exec (cnn-user user password)
              @~a{INSERT INTO trab_db.tb_comodo(nome_comodo,tempo,gasto)
                  VALUES (?,'now',?)} nome gasto)
  (disconnect (cnn-user user password)))

;;-------------------------------INSERT TOMADA---------------------------------------;;

(define (insert-tmd user password gasto)
  (query-exec (cnn-user user password)
              @~a{INSERT INTO trab_db.tb_tomada(tempo,gastotomada)
                  VALUES('now',?)} gasto)
  (disconnect (cnn-user user password)))


;;---------------------------------SELECT CONDOMINIO---------------------------------;;

(define (string-cond col)
  @~a{SELECT (?) FROM trab_db.tb_condominio} col)

  
;; imprimir o enderenco dos condominio
;; USE EXEMPLE: (select-enderenco "postgres" "ama")
(define (select-cond user senha)
  (for ([cod (query-list (cnn-user user senha) (string-cond "cod_condominio"))]
        [nome (query-list (cnn-user user senha) (string-cond "nome"))]
        [cidade (query-list (cnn-user user senha) (string-cond "cidade"))]
        [bairro (query-list (cnn-user user senha) (string-cond "bairro"))]
        [rua (query-list (cnn-user user senha) (string-cond "rua"))])
    @~a{Codigo_Cond: ~a\nRua: ~a\nNumero: ~a\n} cod rua )
  (disconnect (cnn-user user senha)))


;;(disconnect (cnn-user user password))
;;(disconnect (cnn-admin))