#lang racket

(require "../../p0.rkt")

(with-output-to-file "output"
                     (lambda ()
                       (print (next-player '(X E E 
                                             E E E 
                                             X O O)))))
