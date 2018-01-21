#lang racket

(require "../utils/list-operations.rkt")
(provide create-page-links-renderer)


(define (create-page-links-renderer #:prefix-parts [prefix-parts '()])

  (λ (total-posts# posts-per-page# active-page#)

    (define (render-page-links total-posts#)
      (define (render-page-link page-index)
        `(a ((class ,(if (= page-index active-page#)
                         "page-link inactive"
                         "page-link active"))
             (href ,(apply string-append
                           (cons "/"  ; make link absolute, all the prefix parts should be given, so we should have the complete path
                                 (list-join (append prefix-parts
                                                    (list "page"
                                                          (number->string page-index)))
                                            "/")))))
            ,(number->string page-index)))

      (let* ([pages# (inexact->exact
                      (max (ceiling (/ total-posts# posts-per-page#))
                           1))]
             [rendered-page-links (for/list ([page-index (in-range pages#)])
                                    (render-page-link page-index))])
        `(div ((class "page-links"))
              (p ((class "page-links-label")) "Pages")
              ,@(list-join rendered-page-links `(span " - ")))))

    (render-page-links total-posts#)))
