#lang racket

; Get faster-miniKanren here https://github.com/michaelballantyne/faster-miniKanren
(require "../faster-miniKanren/mk.rkt")

(provide (all-defined-out))
 
; Evaluate a program by evaluating the goal expression after initializing
; the environment
(define (eval-programo program out)
    (fresh (q ge)
      (== `(run 1 (,q) ,ge) program)
      ; Interpreted logic variables are symbols
      (symbolo q)
      ; The environment (association list) maps interpreted logic variables
      ; to interpreting logic variables
      (eval-gexpro ge `((,q . ,out)))))
 
; Evaluate goal expression in an environment
(define (eval-gexpro expr env)
    (conde
      [(fresh (e1 e2 t)
         (== `(== ,e1 ,e2) expr)
         ; Evaluation of both terms should unify to the same term t
         (eval-texpro e1 env t)
         (eval-texpro e2 env t))]
      [(fresh (x x1 ge)
         (== `(fresh (,x) ,ge) expr)
         (symbolo x)
         ; Translate interpreted fresh logic variable into interpreting
         ; fresh logic variable by extending the environment
         (eval-gexpro ge `((,x . ,x1) . ,env)))]
      [(fresh (ge1 ge2)
         (== `(conj ,ge1 ,ge2) expr)
         ; Translate interpreted conjunction into interpreting conjunction
         (eval-gexpro ge1 env)
         (eval-gexpro ge2 env))]
      [(fresh (ge1 ge2)
         (== `(disj ,ge1 ,ge2) expr)
         ; Translate interpreted disjunction into interpreting disjunction
         (conde
           [(eval-gexpro ge1 env)]
           [(eval-gexpro ge2 env)]))]))
 
; Evaluate a term expression in an environment
(define (eval-texpro expr env val)
    (conde
      ; Quoted values are self-evaluating
      [(== `(quote ,val) expr)]
      ; Lookup interpreted logic variables in the environment
      [(symbolo expr) (lookupo expr env val)]))
 
; Search for a variable in an environment
(define (lookupo x env val)
    (fresh (y v d)
      (== `((,y . ,v) . ,d) env)
      (conde
        [(== x y) (== v val)]
        [(=/= x y)
         (lookupo x d val)])))
