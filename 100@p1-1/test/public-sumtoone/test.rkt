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
    (print (foldl + 0 (hash-values (step-pagerank (mk-initial-pagerank g0) (/ 85 100) g0))))))
