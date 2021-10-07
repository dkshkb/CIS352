#lang racket

(require "../../pagerank.rkt")

(define r0 '#hash((n0 . 1/5)
                  (n1 . 1/5)
                  (n2 . 1/5)
                  (n3 . 1/5)
                  (n4 . 1/5)))

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

(print-hash (step-pagerank r0 (/ 85 100) g0))
(print-hash (step-pagerank (step-pagerank r0 (/ 85 100) g0) (/ 85 100) g0))

(with-output-to-file "output"
  (lambda ()
    (print-hash (step-pagerank r0 (/ 85 100) g0))
    (print-hash (step-pagerank (step-pagerank r0 (/ 85 100) g0) (/ 85 100) g0))))

