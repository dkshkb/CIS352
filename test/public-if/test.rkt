#lang racket

(require "../../interp-ce.rkt")

(define prog
  '(if (equal? 4 5)
       #t
       (if (null? '())
           #f
           #t)))

(with-output-to-file "output"
                     (lambda ()
                       (print (interp-ce prog)))
                     #:exists 'replace)
