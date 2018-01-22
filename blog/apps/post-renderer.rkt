#lang racket

(require (prefix-in xml: xml)
         markdown
         pollen/unstable/pygments
         "../response.rkt"
         "../benchmark.rkt"
         "../utils/assertions.rkt"
         "../utils/list-operations.rkt"
         web-server/servlet
         gregor)

(provide Post
         Post?
         Post-content
         Post-metadata
         PostMetadata
         PostMetadata-title
         PostMetadata-author
         PostMetadata-tags
         PostMetadata-creation-date
         PostMetadata-id
         Post-from-content
         PostMetadata-from-unserialized-yaml
         create-post-renderer)

;; =======
;; STRUCTS
;; =======
(define-struct Post
  (metadata
   content)
  #:transparent)

(define-struct PostMetadata
  (id
   title
   author
   creation-date
   tags)
  #:transparent)

(define (Post-from-content content metadata)
  (Post metadata content))

(define (PostMetadata-from-unserialized-yaml unserialized-yaml)
  ;; (display "creating PostMetadata from:") (displayln unserialized-yaml)
  (let ([id (hash-ref unserialized-yaml "id" 0)]
        [title (hash-ref unserialized-yaml "title" "no title")]
        [author (hash-ref unserialized-yaml "author" "anonymous")]
        [creation-date (parse-datetime (hash-ref unserialized-yaml "creation-date" "2017-01-01")
                                       "yyyy-MM-dd")]
        [tags (hash-ref unserialized-yaml "tags" (list))])
    (make-PostMetadata id title author creation-date tags)))

;; =========
;; RENDERING
;; =========
(define (create-post-renderer #:render-metadata [render-metadata #t]
                              #:render-toc [render-toc #t]
                              #:render-content [render-content #t])
  (λ (post)
    (define (render-post-metadata metadata)
      `(div ((class "post-metadata"))
            (h1 ((class "post-title")) ,(PostMetadata-title metadata))
            (div ((class "post-metadata-non-title"))
                 (ul ((class "post-metadata-list"))
                     (li ,(string-append "id: "
                                         (number->string (PostMetadata-id metadata))))
                     (li ,(string-append "Author: "
                                         (PostMetadata-author metadata)))
                     (li ,(string-append "Creation date: "
                                         (parameterize ([current-locale "en"])
                                           (~t (PostMetadata-creation-date metadata)
                                               "EEEE, dd. MMMM yyyy, (yyyy-MM-dd)"))))
                     (li (span "Tags: ")
                         ,@(list-join (map render-tag
                                           (PostMetadata-tags metadata))
                                      `(span ", ")))))))

    (define (render-tag a-tag)
      (let ([tag-link (string-append "/tag/" a-tag)])
        `(a ((class "post-tag-link") (href ,tag-link)) ,a-tag)))

    ;; content: list of xexpr
    (define (render-post-content content)
      `(div ((class "post-content"))
            ,@content))

    ;; content: list of xexpr
    (define (render-post-toc content)
      (let ([toc (toc content)])
        `(div ((class "post-toc"))
              ,(insert-at-pos (replace-in-list toc
                                               2
                                               `(div ((class "post-toc-inside")) ,(list-ref toc 2)))
                              2
                              '(h1 ((class "post-toc-heading")) "Table of contents")))))

    (let* ([rendering-content
            (build-list-conditionally '()
                                      render-metadata
                                      (λ () (render-post-metadata (Post-metadata post))))]
           ;; shadowing previous rendering-content
           [rendering-content
            (build-list-conditionally rendering-content
                                      render-toc
                                      (λ () (render-post-toc (Post-content post))))]
           ;; shadowing previous rendering-content
           [rendering-content
            (build-list-conditionally rendering-content
                                      render-content
                                      (λ () (render-post-content (Post-content post))))])
      ;; The original render function is not required any longer.
      ;; We can simply return the result.
      `(div ((class "post"))
            ,@rendering-content))))
