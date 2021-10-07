;; testing-facilities
;;
;; Facilites for testing assignment 1.
;;
;; The tests were partially generated using:
;;
;;     (generate-random-graph N) (for various values of N)
;;     (generate-random-pagerank n) (for various values of N)
;;
;; You can generate random graphs by loading Racket and requiring this file:
;; > (require "testing-facilities.rkt")
;; > (generate-random-graph 5)
#lang racket

;; generate a random graph of a certain size. Our graph has several
;; properties necessary for PageRank to work out nicely:
;; 
;; - graphs will never include any "self-edges" (pages that link to themselves)
;; - graphs will not have any nodes which link to no other nodes
;; 
;; These two properties simplify the definition of the PageRank
;; algorithm, which implicitly assumes graphs have been normalized to
;; this format.
(define (generate-random-graph n)
  (define nodes (map (lambda (x) (string->symbol (format "n~a" x))) (range 0 n)))
  ;; Generate a random number between 0 and n-1 that excludes k
  (define (random-to-n-excluding n k)
    (let ([guess (random 0 n)])
      (if (= guess k) (random-to-n-excluding n k) guess)))
  ;; Calculuate a list of edges. Remove duplicates via list->set->list
  (set->list
   (list->set
    (foldl 
     ;; For each node, next-node, in [0,..,n-1]
     (lambda (next-node acc)
       ;; Generate some random number of edges of form `(,next-node ,o)
       (append acc (map (lambda (_) `(,(string->symbol (format "n~a" next-node))
                                      ;; Take care to ensure we don't include self-edges
                                      ,(string->symbol (format "n~a" (random-to-n-excluding n next-node)))))
                        ;; Take care to ensure that each node links to one thing
                        (range (random 1 n)))))
     '()
     (range n)))))

;; generate a random pagerank of a certain size
;; ensures that no two pagerank nodes have the same value
;; (useful for testing rank-pages)
(define (generate-random-pagerank n)
  (define divisor 1000000)
  (define expected-value (inexact->exact (round (* divisor (/ 1 n)))))
  (define bottom (inexact->exact (round (/ expected-value 2))))
  (define top (inexact->exact (round (+ expected-value (/ expected-value 2)))))
  (define (iter sum lst)
    (define next (/ (random bottom top) divisor))
    ;; Make sure not to repeat a number
    (if (member next lst)
        (iter sum lst)
        (if (> (+ sum next) 1)
            (cons (- 1 sum) lst)
            (iter (+ next sum) (cons next lst)))))
  (define l (iter 0 '()))
  (foldl (lambda (i v acc) (hash-set acc (string->symbol (format "node~a" i)) v)) (hash) (range 0 (length l)) l))

