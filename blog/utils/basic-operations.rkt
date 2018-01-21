#lang racket

(provide atom?)

(define (atom? sth)
  (and (not (pair? sth))
       (not (null? sth))))
