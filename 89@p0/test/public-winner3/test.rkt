#lang racket

(require "../../p0.rkt")

(with-output-to-file "output"
                     (lambda ()
                       (print (winner? '(X E O 
                                          E X O
                                          E O X)))))