#lang racket

; Get faster-miniKanren here https://github.com/michaelballantyne/faster-miniKanren
(require "../faster-miniKanren/mk.rkt"
         "./shallow.rkt")

(run* (x) (eval-programo `(run 1 (z) (== 'cat z))
                         x))

(run* (x) (eval-programo `(run 1 (z) (== ,x z))
                         'cat))

(run 4 (e1 e2) (eval-programo `(run 1 (z) (disj ,e1
                                                ,e2))
                              'cat))
