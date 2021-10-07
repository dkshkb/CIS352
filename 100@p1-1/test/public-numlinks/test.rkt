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

(with-output-to-file "output"
  (lambda ()
    (print (num-links g0 'n0))
    (print (num-links g0 'n1))
    (print (num-links g0 'n2))
    (print (num-links g0 'n3))
    (print (num-links g0 'n4))))

