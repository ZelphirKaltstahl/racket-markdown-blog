#lang racket

(provide assert-with-err-msg)

(define (assert-with-err-msg something
                             predicate?
                             #:error-message [error-message "Assertion Error"])
  ;;(display "Asserting predicate of the following something:") (newline)
  ;;(display something) (newline) (newline)
  (unless (predicate? something)
    (error error-message)))
