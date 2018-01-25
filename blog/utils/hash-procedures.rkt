#lang racket

(require "list-operations.rkt"
         "string-operations.rkt")
(provide (contract-out [my-hash-map
                        (-> hash? (-> any/c any/c) hash?)]
                       [hash-pretty-print
                        (-> hash? (-> any/c any/c boolean?) hash?)]
                       [nested-hash-get
                        (->* (hash?) () #:rest (listof any/c) any/c)]))

(define (my-hash-map h f)
  (make-immutable-hash
   (hash-map h
             (lambda (k v) (f k v)))))

(define (nested-hash-get a-hash . keys)
  (cond
    [(empty? keys) a-hash]
    [else
     (apply nested-hash-get
            (hash-ref a-hash (first keys))
            (rest keys))]))

(define (hash-pretty-print a-hash keys-compare-proc)
  (let* ([sorted-keys (sort (hash-keys a-hash) keys-compare-proc)]
         [min-length-before-hash (max-length sorted-keys
                                             (λ (a-key) (string-length (path->string a-key))))])
    (map (λ (a-key)
           (let ([additional-spaces#
                  (- min-length-before-hash (string-length (path->string a-key)))])
             (display a-key)
             (display ": ")
             (display (string-repeat additional-spaces# " "))
             (displayln (hash-ref a-hash a-key))))
         sorted-keys)))
