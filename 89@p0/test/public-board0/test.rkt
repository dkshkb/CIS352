#lang racket

(require "../../p0.rkt")

(with-output-to-file "output"
                     (lambda ()
                       (print (board? '(E E X E E E E E E E E E X E E E)))))