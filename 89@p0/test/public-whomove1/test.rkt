#lang racket

(require "../../p0.rkt")

(with-output-to-file "output"
                     (lambda ()
                       (print (next-player '(E E E
                                            X O X  
                                            X E O)))))
