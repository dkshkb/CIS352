#lang racket

;;; Project 0 Tic-tac-toe with Racket
;;; 
;;; Please immediately read README.md

(provide board?
         next-player
          valid-move?
          make-move
          winner?
          calculate-next-move)

;; 
;; Useful utility functions
;;

; Returns the number of elements in l for which the predicate f
; evaluates to #t. For example:
;
;    (count (lambda (x) (> x 0)) '(-5 0 1 -3 3 4)) => 3
;    (count (lambda (x) (= x 0)) '(-5 0 1 -3 3 4)) => 1
(define (count f l)
  (cond [(empty? l) 0]
        [(f (car l)) (add1 (count f (cdr l)))]
        [else (count f (cdr l))]))

;; 
;; Your solution begins here
;; 

; Check whether a list is a valid board
(define (board? lst)
  (cond [(not (check-if-square? lst)) #f]
        [(not (check-if-only-xoe? lst)) #f]
        [(not (x-o-differ-by-at-most-1? lst)) #f]
        [(not (x-move-first? lst)) #f]
        [else #t]))

;; The following are some helper functions for board?

;;check if the length of a list is square of some integer
(define check-if-square?
  (lambda (lst)
    (integer? (sqrt (count (lambda (x) #t) lst)))))
;;check if only contains 'X 'O 'E
(define (check-if-only-xoe? lst)
  (cond [(empty? lst) #t]
        [(equal? (car lst) 'X) (check-if-only-xoe? (cdr lst))]
        [(equal? (car lst) 'O) (check-if-only-xoe? (cdr lst))]
        [(equal? (car lst) 'E) (check-if-only-xoe? (cdr lst))]
        [else #f]))
;;check the number of a symbols in a list
(define (number-of-symbol x lst)
  (if (empty? lst) 0
      (if (equal? x (car lst))
          (+ 1 (number-of-symbol x (cdr lst)))
          (number-of-symbol x (cdr lst)))))
;;absolute value
(define abs (lambda (x)
              (if (< x 0) (- 0 x) x)))
;;check if the number of 'X and 'O differ by at most 1
(define (x-o-differ-by-at-most-1? lst) 
  (< (abs (- (number-of-symbol 'X lst) (number-of-symbol 'O lst))) 2))
;;check 'X moves first (check only one X on the board case)
(define x-move-first? (lambda (lst)
                       (if (empty? lst) #t
                           (if (not (empty? (cdr lst))) #t
                               (if (equal? 'X (car lst)) #t
                                   #f)))))

;;; From the board, calculate who is making a move this turn
(define (next-player board)
  (if (equal?
       (number-of-symbol 'X board) (number-of-symbol 'O board))
      'X
      'O))

;;; If player ('X or 'O) want to make a move, check whether it's this
;;; player's turn and the position on the board is empty ('E)
(define (valid-move? board row col player)
  (if (not (list? board)) #f
      (if (not (board? board)) #f
          (if (not (and (number? row) (number? col))) #f
              (if (not (or (equal? player 'X) (equal? player 'O))) #f
                  (if (or (>
                           (+ (* row (sqrt (count (lambda (x) #t) board))) col)
                           (- (count (lambda (x) #t) board) 1))
                          (< row 0)
                          (< col 0)
                          (> (+ 1 row) (sqrt (count (lambda (x) #t) board)))
                          (> (+ 1 col) (sqrt (count (lambda (x) #t) board))))
                          #f
                          (if (not (equal? 'E
                                      (n-of-list
                                       (+ (* row (sqrt (count (lambda (x) #t) board))) col) board)))
                              #f
                              (if (equal? (next-player board) player) #t #f))))))))
      
;;Helper function: get the n-th element of a list
(define (n-of-list n lst)
  (if (equal? n 0) (car lst)
      (n-of-list (- n 1) (cdr lst))))

           
;;; To make a move, replace the position at row col to player ('X or 'O)
(define (make-move board row col player)
  (replace-element (+ (* row (sqrt (count (lambda (x) #t) board))) col) board player))
  
;;Helper function: replace n-th element of a list with p
(define (replace-element n lst p)
  (if (equal? n 0)
      (cons p (cdr lst))
      (cons (car lst) (replace-element (- n 1) (cdr lst) p))))
;;; To determine whether there is a winner?
;;TEST (winner? '(X O X X O E O O X)) -> 'O FINE
(define (winner? board)
  (cond
    [(full-col? board 'X 0) 'X] 
    [(full-col? board 'O 0) 'O]
    [(full-row? board 'X 0) 'X]
    [(full-row? board 'O 0) 'O]
    [(upperleft-lowerright? board 'X 0) 'X]
    [(upperleft-lowerright? board 'O 0) 'O]
    [(upperright-lowerleft? board 'X 1) 'X]
    [(upperright-lowerleft? board 'O 1) 'O]
    [else #f]))
    

;;Helper: check if it has a row (any row) full
;;(define (full-row-or-col? board player)
  
;;if board is 3*3, n ranges 0,1,2, otherwise return #f
;;chekc for n-th col
;;TEST CASE (full-col-helper 1 '(X O X X O E O O X) 'O) -> #t FINE
(define (full-col-helper n board player) ;;n means col-index which is full
  (if (< n 0) #f
      (if (not (equal? player (n-of-list n board))) #f
          (if (>
               (+ n (sqrt (count (lambda (x) #t) board)))
               (- (count (lambda (x) #t) board) 1))
              #t
              (full-col-helper (+ n (sqrt (count (lambda (x) #t) board))) board player)))))
;;set initial i=0, if board is 3*3, check from i = 0,1,2, any case is #t will return #t
;;So, (full-col? board player 0) will check if player is full of any col
;;TEST '(X O X X O E O O X) FINE
;;(full-col? '(X O X X O E O O X) 'O 0) -> #t
(define (full-col? board player i)
  (if (not (< i (sqrt (count (lambda (x) #t) board)))) #f
      (if (full-col-helper i board player) #t
          (full-col? board player (+ i 1)))))

;;check for if n-th row
;;if it's 3*3, n ranges 0,1,2 , otherwise it will return #f
;;(full-row-helper 1 '(E E E X X X E E E) 'X) should return #t
;;(full-row-helper 2 '(E E E X X X E E E) 'X) should return #f
(define (full-row-helper n board player) ;;n means row-index which is full
  (if (or (< n 0) (> n (- (sqrt (count (lambda (x) #t) board)) 1))) #f
      (if (not (equal? player (n-of-list (* n (sqrt (count (lambda (x) #t) board))) board))) #f
          (x-n-continue board
                        (* n (sqrt (count (lambda (x) #t) board)))
                        (sqrt (count (lambda (x) #t) board))))))

(define (full-row? board player i)
  (if (not (< i (sqrt (count (lambda (x) #t) board)))) #f
      (if (full-row-helper i board player) #t
          (full-row? board player (+ i 1)))))
  
;;Helper: start from x-th element, continuous n elements in a list are the same
;;for example (x-n-continue '(1 2 2 2 3) 1 3) should return #t;  (x-n-continue '(1 2 2 2 3) 1 3) returns #f
(define (x-n-continue lst x n) ;;n must be a nonnegative integer
  (if (equal? n 0) #t
      (if (equal? n 1) #t
          (if (not (equal? (n-of-list x lst) (n-of-list (+ x (- n 1)) lst))) #f
              (x-n-continue lst x (- n 1))))))

;;check if win by diagonal upperleft to lowerright
;;initial i=0
;;(upperleft-lowerright? '(X O O O X O O O X) 'X 0) -> #t
(define (upperleft-lowerright? board player i) ;; i=0..(n-1) index: i*(n-1)
  (if (> i (- (sqrt (count (lambda (x) #t) board)) 1)) #t
      (if (not (equal? (n-of-list (* i (+ 1 (sqrt (count (lambda (x) #t) board)))) board) player)) #f
          (upperleft-lowerright? board player (+ i 1)))))
                                               
;; SOME BUG HERE      
;;(upperright-lowerleft? '(O O X O X O X O O) 'X 1)
;;(upperright-lowerleft? '(O O O X O O X O O X O O X O O O) 'X 1) -> #t
;;(upperright-lowerleft? '(O X X O) 'X 1) -> #t
(define (upperright-lowerleft? board player i) ;; i=1..n index: i*(n-1)
  (if (> i (sqrt (count (lambda (x) #t) board)))
      #t
      (if (not (equal? (n-of-list (* i (- (sqrt (count (lambda (x) #t) board)) 1)) board) player)) #f
          (upperright-lowerleft? board player (+ i 1)))))
                                              

                
;;; The board is the list containing E O X 
;;; Player will always be 'O
;;; returns a pair of x and y
;;TEST CASE (calculate-next-move '(X O E X O E O X X) 'O) -> '(0 2) FINE
;;TEST CASE (calculate-next-move '(O E E X X E E E E) 'O) -> '(1 2) FINE
(define (calculate-next-move board player)
  (calculate-next-move-helper board 0 -inf.0 '(0 0) player))
  
  
;;Helper: (calculate-next-move-helper board index current-best player)
;;initialize index = 0, current-score = -inf.0
;;current-next-move = (cons 0 0)
;;(minimax board ai-player) -> score
;;(make-move board row col player) -> new board after making move
;;(valid-move? board row col player) -> #t/#f
(define (calculate-next-move-helper board index current-max-score current-next-move player)
  (let ([row (quotient index (sqrt (count (lambda (x) #t) board)))]
        [col (remainder index (sqrt (count (lambda (x) #t) board)))])
  (if (> (add1 index) (length board))
      current-next-move
      (if (not (valid-move? board row col player))
          (calculate-next-move-helper board (add1 index) current-max-score current-next-move player)
          (match (minimax (make-move board row col player) player)
            [1 (list row col)]
            [(? (lambda (x) (> x current-max-score)) current-max-score-update)
             (calculate-next-move-helper
                   board (add1 index) current-max-score-update (list row col) player)]
            [_ (calculate-next-move-helper board (add1 index) current-max-score current-next-move player)])))))
          
;;          (if (> (minimax (make-move board row col player) player) current-max-score)
;;              (if (equal? (minimax (make-move board row col player) player) 1)
;;                  (list row col)
;;                  (calculate-next-move-helper
;;                   board (add1 index) (minimax (make-move board row col player) player) (list row col) player))
;;             (calculate-next-move-helper board (add1 index) current-max-score current-next-move player))))))

;;Helper function opposite-player
(define (opposite-player p)
  (match p
    ['O 'X]
    ['X 'O]))
;;Helper: check if the game is tie
(define (tie? board)
  (define num-O (number-of-symbol 'O board))
  (define num-X (number-of-symbol 'X board))
  (if (equal? (winner? board) #f)
      (equal? (length board) (+ num-O num-X))
      #f))

;;Helper: find-max-score
;;initial current-max = -inf.0 ,player is to keep track of the player we want to win
;;initial index = 0
;;(make-move board row col player) -> new board after making move
;;(valid-move? board row col player) -> #t/#f
;;TESE CASE (find-max-score '(X O E E X E E O E) 0 -inf.0 'X) -> 1 FINE
;;TEST CASE (find-max-score '(X O E X O E O E X) 0 -inf.0 'X) -> -1 FINE

;;TEST CASE (find-max-score '(X E E E E E E E E) 0 -inf.0 'O) -> 0 FINE
(define (find-max-score board index current-max player) 
  (let ([row (quotient index (sqrt (count (lambda (x) #t) board)))]
        [col (remainder index (sqrt (count (lambda (x) #t) board)))]
        [next-p (next-player board)])
  (if (> (+ index 1) (length board))
      current-max
      (if (not (valid-move? board row col next-p))
          (find-max-score board (add1 index) current-max player)
          (match (minimax (make-move board row col next-p) player)
            [1 1]
            [(? (lambda(x) (> x current-max)) current-max-update)
             (find-max-score board (add1 index) current-max-update player)]
            [_ (find-max-score board (add1 index) current-max player)])))))
          
;;          (if (> (minimax (make-move board row col next-p) player) current-max)
;;              (find-max-score board (add1 index) (minimax (make-move board row col next-p) player) player)
;;              (find-max-score board (add1 index) current-max player))))))

;;Helper: find-min-score
;;initialize current-min = +inf.0 index = 0
;;TEST CASE (find-min-score '(X O E X O E O X X) 0 +inf.0 'X) -> -1 FINE
;;TEST CASE (find-min-score '(X O X X O E O E X) 0 +inf.0 'X) -> -1 FINE
(define (find-min-score board index current-min player) 
  (let ([row (quotient index (sqrt (count (lambda (x) #t) board)))]
        [col (remainder index (sqrt (count (lambda (x) #t) board)))]
        [next-p (next-player board)])
  (if (> (+ index 1) (length board))
      current-min
      (if (not (valid-move? board row col next-p))
          (find-min-score board (add1 index) current-min player)
          (match (minimax (make-move board row col next-p) player)
            [-1 -1]
            [(? (lambda(x) (< x current-min)) current-min-update)
             (find-min-score board (add1 index) current-min-update player)]
            [_ (find-min-score board (add1 index) current-min player)])))))
;;          (if (< (minimax (make-move board row col next-p) player) current-min)
;;              (find-min-score board (add1 index) (minimax (make-move board row col next-p) player) player)
;;              (find-min-score board (add1 index) current-min player))))))

;;Helper: (score board player) ,player is the player we want to win
;;That's only for base case 
(define (score board player) ;;TESTED
  (if (equal? (winner? board) player)
      1
      (if (equal? (winner? board) (opposite-player player))
          -1
          (if (tie? board)
              0
              #f)))) ;;no score yet will return #f

;;Helper function minimax, return a score
;;TEST CASE (minimax '(X O E X O E O X X) 'X) -> -1 FINE
;;TEST CASE (minimax '(X O E X O E O E X) 'X) -> -1 FINE
;;TEST CASE (minimax '(X O X X O E O O X) 'X) -> -1 FINE (base case)
;;TEST CASE (minimax '(X E E E O E E E E) 'O) -> 0 FINE
;;TEST CASE (minimax '(X E E E E E E E E) 'O) -> 0 FINE, but slow, wait for one minute
;;(minimax '(E E E E E E E E E) 'O) -> 0 Take more than 5 mins
(define (minimax board ai-player)               ;;TESTED base case
  (if (not (equal? (score board ai-player) #f))
      (score board ai-player)
      (if (equal? (next-player board) ai-player)
          (find-max-score board 0 -inf.0 ai-player)
          (find-min-score board 0 +inf.0 ai-player))))


                  
                  
                  
               
      