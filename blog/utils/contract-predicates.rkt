#lang racket

(define integer-or-infinity?
  (λ (an-atom)
    (and (number? an-atom)
         (or (integer? an-atom)
             (= an-atom +inf.0)
             (= an-atom -inf.0)))))

(provide
 (contract-out
  [integer-or-infinity? (-> any/c boolean?)]))
