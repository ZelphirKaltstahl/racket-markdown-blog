#lang racket

(require "../html-proc.rkt"
         "../utils/list-operations.rkt"
         "../parts/header.rkt"
         "post-renderer.rkt"
         (prefix-in gregor: gregor))

(provide create-blog-renderer)

(define (create-blog-renderer
         #:max-posts [max-posts +inf.0]
         #:min-date [min-date (gregor:->datetime/utc
                               (gregor:with-timezone (gregor:datetime 2000)
                                                     "Europe/Berlin"))]
         #:posts-per-page# [posts-per-page# +inf.0]
         #:page-number [page-number 0]
         #:flag-add-separators [flag-add-separators #t]
         #:post-separator [post-separator `(hr ((class "post-separator")))]
         #:blog-title [blog-title "Blog of Complaining"]
         #:blog-language [blog-language "en"])

  (λ (post-renderer
      page-links-renderer
      posts
      active-page#)
    (define (post-date<? post-1 post-2)
      (gregor:datetime<? (PostMetadata-creation-date (Post-metadata post-1))
                         (PostMetadata-creation-date (Post-metadata post-2))))

    (define (post-date>min-date? a-post)
      (gregor:datetime>=? (PostMetadata-creation-date (Post-metadata a-post))
                          min-date))

    (define (render-blog-page posts-for-page total-posts#)
      (finalize-html-content
       `(html ((lang ,blog-language))
              ,(render-header #:page-title blog-title)
              ,(render-page-body posts-for-page total-posts#))))

    (define (render-page-body posts total-posts#)
      ;; uses flag-add-separators
      `(body (h1 ((class "blog-title")) ,blog-title)
             ,@(if flag-add-separators
                   (add-separators-between (render-posts posts))
                   (render-posts posts))
             ,(page-links-renderer total-posts# posts-per-page# active-page#)))

    (define (add-separators-between posts)
      (list-join posts post-separator))

    (define (render-posts posts)
      (map post-renderer posts))

    (let* ([posts (filter post-date>min-date? posts)]
           [posts (sort posts post-date<?)]
           [posts (take-n-or-less posts max-posts)]
           [from-index (* posts-per-page# page-number)]
           [to-index (+ from-index posts-per-page#)]
           [posts-for-page (take-from-up-to posts from-index to-index)])
      (render-blog-page posts-for-page (length posts)))))
