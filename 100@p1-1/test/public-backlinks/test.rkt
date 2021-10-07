#lang racket

(require "../../pagerank.rkt")

(define g0 '((n2 n0)
             (n1 n4)
             (n4 n0)
             (n1 n3)
             (n2 n1)
             (n0 n1)
             (n3 n4)
             (n0 n4)
             (n4 n1)
             (n4 n2)
             (n1 n0)))

(define print-set (lambda (s)
                    (print (sort (set->list s) symbol<?))))

(with-output-to-file "output"
  (lambda ()
    (print-set (get-backlinks g0 'n0))
    (print-set (get-backlinks g0 'n1))
    (print-set (get-backlinks g0 'n2))
    (print-set (get-backlinks g0 'n3))
    (print-set (get-backlinks g0 'n4))))

