#lang racket

(provide (contract-out [assert-with-err-msg (->* (any/c
                                                  (-> any/c boolean?))
                                                 (#:error-message string?)
                                                 void?
                                                 #;(should we use `any` here?))]))

(define (assert-with-err-msg something
                             predicate?
                             #:error-message [error-message "Assertion Error"])
  ;;(display "Asserting predicate of the following something:") (newline)
  ;;(display something) (newline) (newline)
  (unless (predicate? something)
    (error error-message)))
