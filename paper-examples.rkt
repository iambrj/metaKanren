#lang racket

(require "../faster-miniKanren/mk.rkt"
         "./metaKanren.rkt")

(run* (x)
  (eval-programo
    `(run* (z)
       (letrec-rel ((appendo (l1 l2 l)
                      (disj
                        (conj (== '() l1) (== l2 l))
                        (fresh (a)
                          (fresh (d)
                            (fresh (l3)
                              (conj (== (cons a d) l1)
                                    (conj (== (cons a l3) l)
                                          (delay (call-rel appendo d
                                                                   l2
                                                                   l3))))))))))
          (call-rel appendo '(1 2) '(3 4) z)))
    x))

(run* (x)
  (eval-programo
    `(run* (z)
       (letrec-rel ((appendo (l1 l2 l)
                      (disj
                        (conj (== '() l1) (== l2 l))
                        (fresh (a)
                          (fresh (d)
                            (fresh (l3)
                              (,x (== (cons a d) l1)
                                  (conj (== (cons a l3) l)
                                        (delay (call-rel appendo d
                                                                 l2
                                                                 l3))))))))))
          (call-rel appendo '(1 2) '(3 4) '(1 2 3 4))))
    '((_.))))

; Gives disj in addition to conj
(run* (x)
  (eval-programo
    `(run ,(peano 1) (z)
       (letrec-rel ((appendo (l1 l2 l)
                      (disj
                        (conj (== '() l1) (== l2 l))
                        (fresh (a)
                          (fresh (d)
                            (fresh (l3)
                              (,x (== (cons a d) l1)
                                  (conj (== (cons a l3) l)
                                        (delay (call-rel appendo d
                                                                 l2
                                                                 l3))))))))))
          (call-rel appendo '(1 2) '(3 4) '(1 2 3 4))))
    '((_.))))

(run 1 (x)
  (eval-programo
    `(run* (z)
       (letrec-rel ((five (f)
                      (== 5 f)))
          (call-rel five z)))
    x))

; Don't get what we expect when all examples are internally ground
(run 1 (e1 e2)
  (eval-programo
    `(run* (z)
       (letrec-rel ((five (f)
                      (== ,e1 ,e2)))
          (call-rel five 5)))
    '((_.))))

; Aha!
(run 1 (x)
  (eval-programo
    `(run* (z)
       (letrec-rel ((five (f)
                      (== 7 7)))
          (call-rel five 5)))
    x))

(run 3 (e1 e2)
  (eval-programo
    `(run* (z)
       (letrec-rel ((five (f)
                      (== ,e1 ,e2)))
          (call-rel five 5)))
    '((_.))))

(run 1 (e1 e2)
  (eval-programo
    `(run* (z)
       (letrec-rel ((five (f)
                      (== ,e1 ,e2)))
          (call-rel five z)))
    '(5)))

; External grounding, extra examples to avoid overfitting, and with symbolo to
; fasten queries
(run 1 (x y w)
  (symbolo x)
  (symbolo y)
  (symbolo w)
  (eval-programo
    `(run* (z)
       (letrec-rel ((appendo (l1 l2 l)
                      (disj
                        (conj (== '() l1) (== l2 l))
                        (fresh (a)
                          (fresh (d)
                            (fresh (l3)
                              (conj (== (cons a d) l1)
                                    (conj (== (cons a l3) l)
                                          (delay (call-rel appendo ,x
                                                                   ,y
                                                                   ,w))))))))))
          (conj (call-rel appendo '(cat dog) '() '(cat dog))
                (conj (call-rel appendo '(apple) '(peach) '(apple peach))
                      (call-rel appendo '(1 2) '(3 4) z)))))
    '((1 2 3 4))))

; Thanks for the example, @bollu!
(run* (count)
  (eval-programo
    `(run ,count (z)
       (disj (== z 1)
             (== z 2)))
    '(1 2)))

(run* (count answers)
  (eval-programo `(run ,count (z)
                    (disj (== z 1)
                          (== z 2)))
                 answers))
