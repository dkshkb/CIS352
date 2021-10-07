#lang racket

(require "../../p0.rkt")

(with-output-to-file "output"
                     (lambda ()
                       (print (valid-move? '(X E E
                                              E X E
                                              O E E) 2 3 'O))))