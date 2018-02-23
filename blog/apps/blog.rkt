#lang racket

(require yaml
         markdown/parse
         sha
         "../response.rkt"
         "blog-renderer.rkt"
         "post-renderer.rkt"
         "page-links-renderer.rkt"
         "unknown-page.rkt"
         "../utils/list-operations.rkt"
         "../utils/hash-procedures.rkt"
         "../code-highlighting.rkt")

(provide blog-app
         post-app
         tag-app)

(struct BlogConfig
  (posts-per-page
   ))

;; =========
;; CONSTANTS
;; =========
(define POSTS-DIRECTORY "../data/posts/")
(define METADATA-FILE-ENDING "meta")
(define CONFIG-HASH (file->yaml "config.yaml"))
(define CONFIG (BlogConfig (hash-ref CONFIG-HASH "posts-per-page")))

;; ===
;; APP
;; ===
(define (blog-app request [page 0])
  ;; (display "displaying blog page ") (displayln page)
  (send-success-response
   (let* ([posts (read-post-directory)]
          [posts-per-page (BlogConfig-posts-per-page CONFIG)]
          [page (if (> (* page posts-per-page) (length posts))
                    0
                    page)])
     (let* ([blog-renderer (create-blog-renderer #:posts-per-page# posts-per-page
                                                 #:page-number page)]
            [post-renderer (create-post-renderer)]
            [page-links-renderer (create-page-links-renderer)])
       (blog-renderer post-renderer
                      page-links-renderer
                      posts
                      page)))))

(define (post-app request post-id)
  (let* ([posts (filter (λ (a-post)
                          (= (PostMetadata-id (Post-metadata a-post)) post-id))
                        (read-post-directory))]
         [page 0])
    (cond [(empty? posts)
           #;(displayln "got no such post")
           (respond-unknown-file request)]
          [else (let* ([blog-renderer (create-blog-renderer)]
                       [post-renderer (create-post-renderer)]
                       [page-links-renderer (create-page-links-renderer)])
                  (send-success-response (blog-renderer post-renderer
                                                        page-links-renderer
                                                        posts
                                                        page)))])))

(define (tag-app request tag-name [page 0])
  (let* ([posts (filter (λ (a-post)
                          (member (string-downcase tag-name)
                                  (map string-downcase
                                       (PostMetadata-tags (Post-metadata a-post)))))
                        (read-post-directory))]
         [page 0])
    #;(displayln posts)
    (cond [(empty? posts) (respond-unknown-file request)]
          [else
           (let* ([blog-renderer (create-blog-renderer)]
                  [post-renderer (create-post-renderer)]
                  [page-links-renderer
                   (create-page-links-renderer #:prefix-parts (list "tag" tag-name))])
             (send-success-response (blog-renderer post-renderer
                                                   page-links-renderer
                                                   posts
                                                   page)))])))

;; =============
;; READING POSTS
;; =============
;; some global state for memoization
;; only want to render files again if their hash changed
(define post-hashes (make-hash))
(define metadata-hashes (make-hash))
(define read-metadatas (make-hash))
(define rendered-posts (make-hash))

;; access with
;; (hash-set! hash key v)
;; (hash-ref hash key [failure-result])
;; (bytes->hex-string (sha256 (string->bytes/utf-8 "test")))

(define (concat-with-posts-base-path file-path)
  (build-path POSTS-DIRECTORY file-path))

(define (read-post-directory)
  (let* ([filesystem-items (directory-list (string->path POSTS-DIRECTORY))]
         [files (filter file-exists? (map concat-with-posts-base-path filesystem-items))])
    (map read-post-from-file
         (filter-post-files files))))

(define (filter-post-files list-of-paths)
  (filter (λ (a-path)
            (and (file-extension-markdown? a-path)
                 (published-post? a-path)))
          list-of-paths))

;; path: a path to a file
(define (file-extension-markdown? path)
  (or (path-has-extension? path "md")
      (path-has-extension? path "mdown")
      (path-has-extension? path "markdown")))

(define (file-extension-metadata? path)
  (or (path-has-extension? path METADATA-FILE-ENDING)))

(define (published-post? path)
  #t)

(define (read-metadata-for-post metadata-path)
  (cond [(file-exists? metadata-path)
         ;; using `or` here because `file->yaml` returns `#f` for empty metadata files
         (PostMetadata-from-unserialized-yaml (or (file->yaml metadata-path)
                                                  (hash)))]
        [else
         ;; supply empty hash because no metadata has been found
         (PostMetadata-from-unserialized-yaml (hash))]))

(define (read-post-from-file path)
  ;; getting the paths straight ...
  (let* ([filename (path->string (file-name-from-path path))]
         [extension (bytes->string/utf-8 (path-get-extension path))]
         [extension-position (substring-position filename extension)]
         [filename-no-extension (substring filename 0 extension-position)]
         [metadata-path (concat-with-posts-base-path
                         (string->path
                          (string-append filename-no-extension "." "meta")))])
    ;; getting the hashes of metadata and posts ...
    (let* ([metadata-as-string (if (file-exists? metadata-path)
                                   (file->string metadata-path #:mode 'text)
                                   "")]
           [post-as-string (file->string path #:mode 'text)]
           [hash-of-metadata (bytes->hex-string
                              (sha256
                               (string->bytes/utf-8 metadata-as-string)))]
           [hash-of-post (bytes->hex-string
                          (sha256
                           (string->bytes/utf-8 post-as-string)))])
      ;; getting rendered metadata and content ...
      (let ([metadata (cond [(string=? (hash-ref metadata-hashes metadata-path "") hash-of-metadata)
                             (hash-ref read-metadatas metadata-path)]
                            [else
                             #;(displayln "metadata hashes did not match, reading metadata")
                             (let ([read-metadata (read-metadata-for-post metadata-path)])
                               (hash-set! metadata-hashes metadata-path hash-of-metadata)
                               (hash-set! read-metadatas metadata-path read-metadata)
                               read-metadata)])]
            [content (cond [(string=? (hash-ref post-hashes path "") hash-of-post)
                            (hash-ref rendered-posts path)]
                           [else
                            (displayln "post hashes did not match, rendering post")
                            (let ([rendered-post (highlight-code-xexprs (parse-markdown path))])
                              (hash-set! post-hashes path hash-of-post)
                              (hash-set! rendered-posts path rendered-post)
                              rendered-post)])])
        ;; make the post
        #;(hash-pretty-print metadata-hashes (λ (a-path b-path)
                                             (string<? (path->string a-path)
                                                       (path->string b-path))))
        #;(hash-pretty-print post-hashes (λ (a-path b-path)
                                         (string<? (path->string a-path)
                                                   (path->string b-path))))
        (Post-from-content content metadata)))))
