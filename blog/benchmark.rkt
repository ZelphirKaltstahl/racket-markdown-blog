#lang racket

(provide benchmark)

(define (benchmark proc n-times)
  (time
   (for/list ([i (in-range n-times)])
     (proc))))

;; example:
#;(benchmark (λ () (proc))
           100)
