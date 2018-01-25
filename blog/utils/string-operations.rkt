#lang racket

(provide (contract-out [string-repeat
                        (-> natural? string? string?)]))

(define (string-repeat n str)
  (apply string-append (make-list n str)))
