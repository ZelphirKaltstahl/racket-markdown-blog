#lang racket

(require srfi/13
         racket/set
         "basic-operations.rkt"
         "contract-predicates.rkt")

(provide
 (contract-out
  [substring-position (-> string? string? integer?)]
  [list-join (-> list? any/c list?)]
  [take-n-or-less (-> list? (and/c integer-or-infinity? positive?) list?)]
  [take-from-up-to (-> list? integer? (and/c integer-or-infinity? positive?) list?)]
  [build-list-conditionally (-> list? boolean? (-> any/c) list?)]
  [replace-in-list (-> list? integer? any/c list?)]
  [insert-at-pos (-> list? integer? any/c list?)]
  [unique-items-list (-> list? list?)]
  [get-maximum (-> list? number?)]
  [max-length (-> list? (-> any/c number?) number?)]
  [apply-filtered* (-> (-> any/c any/c) (-> any/c any/c) list? list?)]))

(define (substring-position hay needle)
  (string-contains hay needle))

(define (list-join a-list sep)
  (define (iter remaining res)
    (cond [(empty? remaining) res]
          [else (cons sep
                      (cons (car remaining)
                            (iter (cdr remaining) res)))]))
  (cdr (iter a-list '())))

(define (take-n-or-less a-list n)
  (define (iter remaining result n)
    (cond [(= n 0) result]
          [(empty? remaining) result]
          [else (iter (cdr remaining)
                      (cons (car remaining) result)
                      (- n 1))]))
  (reverse (iter a-list '() n)))

(define (take-from-up-to lst start end)
  (let ([len (length lst)])
    (cond [(<= end start) '()]  ;; end before or at start
          [(> end (sub1 len)) (drop lst start)]  ;; end after last index of list
          ;; standard case
          [else (let* ([new-lst (drop lst start)]
                       [new-len (length new-lst)]
                       [new-end (- end start)]
                       [to-drop-right (- len end)])
                  (drop-right new-lst to-drop-right))])))

(define (build-list-conditionally existing-list condition elem-creating-proc)
  (cond [condition (cond [(empty? existing-list) (list (elem-creating-proc))]
                         ;; append "dissolves one layers of listiness"
                         ;; (append '(1 2 3) '(4 5 6)) -> '(1 2 3 4 5 6)
                         ;; so we need to wrap in a list here to get valid `xexpr`s
                         [else (append existing-list (list (elem-creating-proc)))])]
        [else existing-list]))

;; This way of replacing in a list is not very performant:
#;(define (replace-in-list1 lst position replacement)
  (displayln lst)
  (let ([vec (list->vector lst)])
    (displayln vec)
    (vector-set! vec position replacement)
    (vector->list vec)))

(define (replace-in-list lst position replacement)
  (define (iter remaining current-pos result)
    (cond [(empty? remaining) result]
          [(= position current-pos) (iter (cdr remaining)
                                          (add1 current-pos)
                                          (cons replacement result))]
          [else (iter (cdr remaining)
                      (add1 current-pos)
                      (cons (car remaining) result))]))
  (reverse (iter lst 0 '())))


(define (insert-at-pos lst pos x)
  (define-values (before after) (split-at lst pos))
  (append before (cons x after)))


(define (unique-items-list a-list)
  (set->list (list->set a-list)))

(define (max-length a-list length-proc)
  (get-maximum (map length-proc a-list)))

(define (get-maximum a-list)
  (define (iter current-max remaining-elems)
    (cond [(empty? remaining-elems) current-max]
          [(> (car remaining-elems) current-max) (iter (car remaining-elems) (cdr remaining-elems))]
          [else (iter current-max (cdr remaining-elems))]))
  (iter -inf.0 a-list))

(define (apply-filtered* pred? proc lst)
  (cond [(null? lst) '()]
        [(atom? lst) (cond [(pred? lst) (proc lst)]
                           [else lst])]
        [(pred? (car lst)) (cons (proc (car lst))
                                 (apply-filtered* pred? proc (cdr lst)))]
        [else (cons (apply-filtered* pred? proc (car lst))
                    (apply-filtered* pred? proc (cdr lst)))]))
