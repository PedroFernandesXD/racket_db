#lang at-exp racket

(require db)

(define user-admin "postgres")
(define password-admin "1234")

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
                      #:database "trab"))



;;----------INPUT VALORES SIMULADO DE CORRENTE TOMADA 1 E 2-------------------------;;
;; USE: (input1 "postgres" "ama")

(define (input1 user password)
  (query-exec (cnn-user user password)
              (let ([c (cr1)])
                (string-append
                 "insert into trab_db.tb_tomada(tempo,gasto) values ('now',"
                 (number->string (/ (* c 110) 1000))
                 ")")))
  (disconnect (cnn-user user password)))


(define (input2 user password)
  (query-exec (cnn-user user password)
             (let ([c (cr2)])
              (string-append
               "INSERT INTO trab_db.tb_tomada(tempo,gasto) values ('now',"
               (number->string (/ (* c 110) 1000)) ")")))
  (disconnect (cnn-user user password)))


(define (simular x)
  (let loop ([i 10])
    (if (not (zero? i))
        (and (and x (sleep 1)) (printf "Simulacao Completa.\n"))
        (loop (- i 1)))
    ))

(define (read-port)
  (for ([i 10])
    (if (zero? i)
        (display "OK")
        (input1 "postgres" "12345"))))

;;---------------------------------INSERT CONDOMINIO---------------------------------;;

(define (insert-cond user password nome cidade bairro rua num)
  (query-exec (cnn-user user password)
              (format "INSERT INTO trab_db.tb_condominio(nome,cidade,bairro,rua,num) VALUES (~a ,~a ,~a ,~a ,~a)" nome cidade bairro rua num))
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

(define (insert-tmd user password cod_tomada gasto)
  (query-exec (cnn-user user password)
              (format "INSERT INTO trab_db.tb_tomada(cod_tomada,tempo,gasto)
                  VALUES(~a,'now',~a)" cod_tomada gasto))
  (disconnect (cnn-user user password)))


;;---------------------------------SELECT CONDOMINIO---------------------------------;;

(define (string-cond col)
  (format "SELECT (~a) FROM trab_db.tb_condominio" col))

  
;; imprimir o enderenco dos condominio
;; USE EXEMPLE: (select-enderenco "postgres" "ama")
(define (select-cond user senha)
  (for ([cod (query-list (cnn-user user senha) (string-cond "cod_condominio"))]
        [nome (query-list (cnn-user user senha) (string-cond "nome"))]
        [cidade (query-list (cnn-user user senha) (string-cond "cidade"))]
        [bairro (query-list (cnn-user user senha) (string-cond "bairro"))]
        [rua (query-list (cnn-user user senha) (string-cond "rua"))]
        [num (query-list (cnn-user user senha) (string-cond "num"))]
        )
    (printf "Codigo_Cond: ~a\nNome: ~a \nEnderenço: ~a ~a ~a ~a \n" cod nome cidade bairro rua num))
  (disconnect (cnn-user user senha)))


;;--------------------------------SELECT PREDIO-------------------------------------------;;

(define (string-prd col)
 (format "SELECT (~a) FROM trab_db.tb_predio" col))

(define (select-pdr user senha)
  (for ([cod (query-list (cnn-user user senha) (string-prd "cod_predio"))]
        [num (query-list (cnn-user user senha) (string-cond "num"))] )
    (printf "codigo_predio: ~a\nNum: ~a\n" cod num))
  (disconnect (cnn-user user senha)))

;;-------------------------SELECT APARTAMENTO ---------------------------------;;
(define (string-apart col)
  (format "SELECT (~a) FROM trab_db.tb_apartamento" col))


(define (select-apart user senha)
  (for ([cod (query-list (cnn-user user senha) (string-apart "cod_apartamento"))]
        [nome (query-list (cnn-user user senha) (string-apart "nome_proprietario"))]
        [tel (query-list (cnn-user user senha) (string-apart "telefone"))]
        )
    (printf "Codigo_apartamento: ~a\nNome Proprietario: ~a\n Telefone: ~a\n" cod nome tel))
  (disconnect (cnn-user user senha)))

;;------------------------SELECT COMODO--------------------------------------------;;

(define (string-com col)
  (format "SELECT (~a) FROM trab_db.tb_comodo" col))


(define (select-com user senha)
  (let loop ([cod (query-list (cnn-user user senha) (string-com "cod_comodo"))]
             [nome (query-list (cnn-user user senha) (string-com "nome_comodo"))]
        )
    (printf "Codigo_comodo: ~a\nNome_Comodo: ~a" cod nome))
  (disconnect (cnn-user user senha)))

;;----------------------SELECT TOMADA -----------------------------------------------;;

(define (string-tmd col)
  (format "SELECT (~a) FROM trab_db.tb_tomada" col))

(define (select-tmd user senha)
  (for ([cod   (query-list (cnn-user user senha) (string-tmd "cod_tomada"))]
        [tempo (query-list (cnn-user user senha) (string-tmd "tempo"))] 
        [gasto (query-list (cnn-user user senha) (string-tmd "gasto"))]
        )
    (printf "Codigo_predio: ~a\nGasto: ~a\nTempo: ~a" cod gasto tempo))
  (disconnect (cnn-user user senha)))


(define (busca)
  (query-rows (cnn-user "postgres" "12345") "SELECT * FROM trab_db.tb_tomada"))

;;(disconnect (cnn-user user password))
;;(disconnect (cnn-admin))

