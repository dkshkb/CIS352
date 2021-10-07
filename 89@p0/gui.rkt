#lang racket

;; If you are a student of CIS352 you do not have to modify this file
;;
;; GUI for Tic-Tac-Toe
;; CIS352 -- Spring 2021
;; Author: Chang Liu under advising of Kris Micinski

(require 2htdp/universe)
(require 2htdp/image)
(require racket/cmdline)
(require "./p0.rkt")

(define ai (make-parameter #f))
(define verbose-mode (make-parameter #f))
(define boardsize (make-parameter "3"))

;; command line parser
(define parser
  (command-line
    #:once-each
      [("-a" "--aimode") "AI mode?" (ai #t)]
      [("-v" "--verbose") "Run with verbose messages" (verbose-mode #t)]
    #:multi
      [("-k" "--size") lf ; flag takes one argument
                            "The size of the board"
                            (boardsize lf)]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Do NOT modify code below
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; board is the list for board
; mode #t is AI mode, #f is human interactive mode
; size is the size of board, 
; win indicates whether this world has a winner
; verbose indicates the info output to screen 
(define-struct game (board mode verbose size win))


;;; The cross for Player X
(define cross
  (add-line (line 50 50 "blue")
            0 50 50 0 "blue"))

;;; The circle for player O
(define crcle
  (circle 25 "solid" "red"))

;;; The empty place holder in case of some overlapping mess
(define empt
  (circle 25 "solid" "white"))  

;; World -> Image renderer
(define (render game)
  (define lst (game-board game))
  (define v (game-verbose game))
  (define k (game-size game))
  (define win (game-win game))
  (define winner (if (equal? win 'X) "X" "O"))

  (define baseboard
    (overlay/align
     "left"
     "top"
     (apply overlay/align
            `("right" "bottom"
                      ,@(map (lambda (x) (rectangle (* 100 (add1 x)) (* k 100) "outline" "black")) (range 0 k))))
     (apply overlay/align
            `("left" "top" ,@(map (lambda (x) (rectangle (* k 100) (* 100 (add1 x)) "outline" "black")) (range 0 k))))))

  ; Place 
  (define (place lst acc size)
    (define po (- (* size size) (length lst)))
    (define xpo (quotient po size))
    (define ypo (remainder po size))
    (define shape (if (null? lst) empt (match (car lst) ['X cross] ['E empt] ['O crcle])))
    (if (null? lst) (rotate -90 (flip-vertical acc)) 
                    (place (cdr lst) (underlay/xy acc (+ (* xpo 100) 25) (+ (* ypo 100) 25) shape) size)))

  ; If the game is over...
  (if (or (sequence-ormap (lambda (x) (equal? 'E x)) lst) win)
    ; Draw the graph and override board
    (if win                  
            (overlay/align "middle" "top"  
                              (place lst baseboard k)     
                              (overlay/align "middle" "bottom" (text (string-join `("Winner:" ,winner ", click to exit")) 26 "red")  
                                  (rectangle (* 100 k) (+ 50(* 100 k)) "outline" "transparent")))
            (overlay/align "middle" "top"  
                              (place lst baseboard k)     
                              (overlay/align "middle" "bottom" (text (string-join `("Exit")) 26 "black")  
                                  (rectangle (* 100 k) (+ 50(* 100 k)) "outline" "transparent"))))

    ; Board is filled, no winner
    (overlay/align "middle" "top"  
                  (place lst baseboard k)     
                  (overlay/align "middle" "bottom" (text (string-join `("Board full, click to exit")) 26 "red")  
                      (rectangle (* 100 k) (+ 50(* 100 k)) "outline" "transparent")))))

; As function name :P
(define (mouse-handler game x y MouseEvent)
  (define lst (game-board game))
  (define mode (game-mode game))
  (define v (game-verbose game))
  (define k (game-size game))
  (define row (quotient y 100))
  (define col (quotient x 100))
  (define win (game-win game))
  (define player (next-player lst))
  (define winner (if win win (if (winner? lst) (winner? lst) #f)))
  (if (and mode (equal? player 'O) (not winner))
      (make-game (make-move lst (first (calculate-next-move lst 'O)) (second (calculate-next-move lst 'O)) 'O) mode v k winner)  
      (if (equal? MouseEvent "button-up")
          (if (> y (* k 100)) (exit)
              ; Debug mode
              (if v (begin  
                      (printf "Before this move board list status: ~a\n" lst)
                      (printf "The move made is at: (~a, ~a)\n" row col)
                      (printf "This time the calculated player to move is: ~a\n" player)
                      (printf "Valid-move? indicates the output: ~a\n" (valid-move? lst row col player))
                      (printf "The calculated board after move is: ~a\n" (if (and (valid-move? lst row col player) (not win)) (make-move lst row col player) lst))
                      (printf "After the move calculated winner is: ~a\n" (winner? (make-move lst row col player)))
                      (printf "=================ENDSTEP=================\n")
                      (if (and (valid-move? lst row col player) (not win))
                          (make-game (make-move lst row col player) mode v k winner)
                          (make-game lst mode v k winner)))
                  (if (and (valid-move? lst row col player) (not win))
                      (make-game (make-move lst row col player) mode v k winner)
                      (make-game lst mode v k winner))))
          (make-game lst mode v k winner))))

; Initialize a board list
(define (bd-init n acc)
  (if (zero? n)
      (flatten acc)
      (bd-init (- n 1) (append acc '(E)))))

(define bd-size (string->number (boardsize)))
(define bd (bd-init (* bd-size bd-size) '()))

; main function
(big-bang (make-game bd (ai) (verbose-mode) bd-size #f)
          (on-mouse mouse-handler)
          (to-draw render (+ 5 (* bd-size 100)) (+ 55 (* bd-size 100))))
