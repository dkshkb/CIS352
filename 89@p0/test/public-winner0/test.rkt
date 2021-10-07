#lang racket

(require "../../p0.rkt")

(with-output-to-file "output"
                     (lambda ()
                       (print (winner? '(X E E
                                              E X E 
                                              O E E)))))