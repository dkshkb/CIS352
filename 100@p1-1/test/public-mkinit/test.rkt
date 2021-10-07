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

(define (print-hash h)
  (for ([k (sort (hash-keys h) symbol<?)])
    (pretty-print `(,k ,(hash-ref h k)))))

(print-hash (mk-initial-pagerank g0))

(with-output-to-file "output"
  (lambda ()
    (print-hash (mk-initial-pagerank g0))))
