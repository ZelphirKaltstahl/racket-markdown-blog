#lang racket

(provide string-repeat)

(define (string-repeat n str)
  (apply string-append (make-list n str)))
