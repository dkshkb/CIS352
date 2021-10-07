#lang racket

;; Assignment 1: Implementing PageRank
;;
;; PageRank is a popular graph algorithm used for information
;; retrieval and was first popularized as an algorithm powering
;; the Google search engine. Details of the PageRank algorithm will be
;; discussed in class. Here, you will implement several functions that
;; implement the PageRank algorithm in Racket.
;;
;; Hints: 
;; 
;; - For this assignment, you may assume that no graph will include
;; any "self-links" (pages that link to themselves) and that each page
;; will link to at least one other page.
;;
;; - you can use the code in `testing-facilities.rkt` to help generate
;; test input graphs for the project. The test suite was generated
;; using those functions.
;;
;; - You may want to define "helper functions" to break up complicated
;; function definitions.

(provide graph?
         pagerank?
         num-pages
         num-links
         get-backlinks
         mk-initial-pagerank
         step-pagerank
         iterate-pagerank-until
         rank-pages)

;; This program accepts graphs as input. Graphs are represented as a
;; list of links, where each link is a list `(,src ,dst) that signals
;; page src links to page dst.
;; (-> any? boolean?)
(define (graph? glst)
  (and (list? glst)
       (andmap
        (lambda (element)
          (match element
                 [`(,(? symbol? src) ,(? symbol? dst)) #t]
                 [else #f]))
        glst)))

;; Our implementation takes input graphs and turns them into
;; PageRanks. A PageRank is a Racket hash-map that maps pages (each 
;; represented as a Racket symbol) to their corresponding weights,
;; where those weights must sum to 1 (over the whole map).
;; A PageRank encodes a discrete probability distribution over pages.
;;
;; The test graphs for this assignment adhere to several constraints:
;; + There are no "terminal" nodes. All nodes link to at least one
;; other node.
;; + There are no "self-edges," i.e., there will never be an edge `(n0
;; n0).
;; + To maintain consistenty with the last two facts, each graph will
;; have at least two nodes.
;; + There will be no "repeat" edges. I.e., if `(n0 n1) appears once
;; in the graph, it will not appear a second time.
;;
;; (-> any? boolean?)
(define (pagerank? pr)
  (and (hash? pr)
       (andmap symbol? (hash-keys pr))
       (andmap rational? (hash-values pr))
       ;; All the values in the PageRank must sum to 1. I.e., the
       ;; PageRank forms a probability distribution.
       (= 1 (foldl + 0 (hash-values pr)))))

;; Takes some input graph and computes the number of pages in the
;; graph. For example, the graph '((n0 n1) (n1 n2)) has 3 pages, n0,
;; n1, and n2.
;;
;; (-> graph? nonnegative-integer?)
(define (num-pages graph)
  (define (h g acc)
    (match g
      ['() acc]
      [`(,hd . ,tl)
       (cond
         [(and
           (andmap (lambda (x) (not (equal? x (first hd)))) acc)
           (andmap (lambda (x) (not (equal? x (second hd)))) acc))                       
          (h tl (cons (second hd) (cons (first hd) acc)))]
         [(and
           (andmap (lambda (x) (not (equal? (first hd) x))) acc)
           (ormap (lambda (x) (equal? (second hd) x)) acc))
          (h tl (cons (first hd) acc))]
         [(and
           (andmap (lambda (x) (not (equal? (second hd) x))) acc)
           (ormap (lambda (x) (equal? (first hd) x)) acc))
          (h tl (cons (second hd) acc))]
         [else (h tl acc)])]))
  (length (h graph '())))

;; Takes some input graph and computes the number of links emanating
;; from page. For example, (num-links '((n0 n1) (n1 n0) (n0 n2)) 'n0)
;; should return 2, as 'n0 links to 'n1 and 'n2.
;;
;; (-> graph? symbol? nonnegative-integer?)

(define (num-links graph page)
  (define (h g p acc)
    (match g
      ['() acc]
      [`(,hd . ,tl)
       (if (equal? (first hd) p) 
           (h tl p (cons hd acc))
           (h tl p acc))]))
(length (h graph page '())))

#|
(define (num-links graph page)
  (define (h g p acc)
    (match g
      ['() acc]
      [`(,hd . ,tl)
       (if (and
            (not (ormap (lambda (x)
                     (or
                      (and (equal? (first x) (first hd))
                           (equal? (second x) (second hd)))
                      (and (equal? (first x) (second hd))
                           (equal? (second x) (first hd)))))
                   acc))
            (and (equal? (first hd) p)
                 (not (equal? (second hd) p)))
            )
           (h tl p (cons hd acc))
           (h tl p acc))]))
(length (h graph page '())))
|#


;; Calculates a set of pages that link to page within graph. For
;; example, (get-backlinks '((n0 n1) (n1 n2) (n0 n2)) n2) should
;; return (set 'n0 'n1).
;;
;; (-> graph? symbol? (set/c symbol?))
(define (get-backlinks graph page)
  (define (h g p acc)
    (match g
      ['() acc]
      [`(,hd . ,tl)
       (if (equal? (second hd) page)
           (h tl p (set-add acc (first hd)))
           (h tl p acc))]))
  (h graph page (set)))
      
      
;; Generate an initial pagerank for the input graph g. The returned
;; PageRank must satisfy pagerank?, and each value of the hash must be
;; equal to (/ 1 N), where N is the number of pages in the given
;; graph.
;; (-> graph? pagerank?)
(define (mk-initial-pagerank graph)
  (define (h g acc)
    (match g
      ['() acc]
      [`(,hd . ,tl)
       (cond
         [(and
           (andmap (lambda (x) (not (equal? x (first hd)))) acc)
           (andmap (lambda (x) (not (equal? x (second hd)))) acc))                       
          (h tl (cons (second hd) (cons (first hd) acc)))]
         [(and
           (andmap (lambda (x) (not (equal? (first hd) x))) acc)
           (ormap (lambda (x) (equal? (second hd) x)) acc))
          (h tl (cons (first hd) acc))]
         [(and
           (andmap (lambda (x) (not (equal? (second hd) x))) acc)
           (ormap (lambda (x) (equal? (first hd) x)) acc))
          (h tl (cons (second hd) acc))]
         [else (h tl acc)])]))
  (let ([pr (/ 1 (num-pages graph))])
    (foldr (lambda (x y) (hash-set y x pr)) (hash) (h graph '()))))
           
;; Perform one step of PageRank on the specified graph. Return a new
;; PageRank with updated values after running the PageRank
;; calculation. The next iteration's PageRank is calculated as
;;
;; NextPageRank(page-i) = (1 - d) / N + d * S
;;
;; Where:
;;  + d is a specified "dampening factor." in range [0,1]; e.g., 0.85
;;  + N is the number of pages in the graph
;;  + S is the sum of P(page-j) for all page-j.
;;  + P(page-j) is CurrentPageRank(page-j)/NumLinks(page-j)
;;  + NumLinks(page-j) is the number of outbound links of page-j
;;  (i.e., the number of pages to which page-j has links).
;;
;; (-> pagerank? rational? graph? pagerank?)
(define (step-pagerank pr d graph)
  (define (h key-list acc)
    (match key-list
      ['() acc]
      [`(,hd . ,tl)
       (h tl (hash-set acc hd
            (+ (/ (- 1 d) (num-pages graph))
               (* d
                  
                  (foldr (lambda (x y) (+ (* (/ 1 (num-links graph x)) (hash-ref pr x)) y))
                        0
                        (set->list (get-backlinks graph hd)))))))]))
  (h (hash-keys pr) (hash)))

;; Iterate PageRank until the largest change in any page's rank is
;; smaller than a specified delta.
;;
;; (-> pagerank? rational? graph? rational? pagerank?)
(define (iterate-pagerank-until pr d graph delta)
  (define (h current-pr previous-pr d graph delta)
    (if (hash-empty? previous-pr)
        (h (step-pagerank current-pr d graph) current-pr d graph delta)
        (if (andmap
             (lambda (key) (< (abs (- (hash-ref current-pr key) (hash-ref previous-pr key))) delta))
             (hash-keys current-pr))
            current-pr
            (h (step-pagerank current-pr d graph) current-pr d graph delta))))
  (h pr (hash) d graph delta))

;; Given a PageRank, returns the list of pages it contains in ranked
;; order (from least-popular to most-popular) as a list. You may
;; assume that the none of the pages in the pagerank have the same
;; value (i.e., there will be no ambiguity in ranking)
;;
;; (-> pagerank? (listof symbol?))

;;(h pr (hash-keys pr) (car (hash-keys pr)))
(define (rank-pages pr)
  (define (h pr keys smallest)
    (match keys
      ['() smallest]
      [`(,hd . ,tl) (if (< (hash-ref pr hd) (hash-ref pr smallest))
                        (h pr tl hd)
                        (h pr tl smallest))]))
  (define (h1 pr acc)
    (match pr
      [(? hash-empty?) acc]
      [_ (h1
          (hash-remove pr (h pr (hash-keys pr) (car (hash-keys pr))))
          (cons (h pr (hash-keys pr) (car (hash-keys pr))) acc))]))
  (reverse (h1 pr '())))

                                
