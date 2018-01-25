#lang racket

(provide (contract-out [atom? (-> any/c boolean?)]))

(define (atom? sth)
  (and (not (pair? sth))
       (not (null? sth))))
