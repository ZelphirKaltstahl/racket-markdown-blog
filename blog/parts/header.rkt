#lang racket

(require web-server/servlet)

(provide render-header)

(define (render-header
          #:page-title [page-title "NO TITLE"]
          #:default-css-imports [default-css-imports (list "/css/blog.css"
                                                           "/css/post.css"
                                                           "/css/code.css"
                                                           "/css/post-toc.css"
                                                           "/css/pygments/github-style.css")]
          #:special-css-imports [special-css-imports '()]
          #:default-js-imports [default-js-imports '()]
          #:special-js-imports [special-js-imports '()])
  `(head (title ,page-title)
         ,@(render-meta-data)
         ,@(map render-css-import default-css-imports)
         ,@(map render-css-import special-css-imports)
         ,@(map render-js-import default-js-imports)
         ,@(map render-js-import special-js-imports)
         ))

(define (render-css-import path)
  `(link ((rel "stylesheet") (href ,path))))

(define (render-js-import path)
  `(script ((type "text/javascript") (src ,path))))

(define (render-meta-data)
  (list `(meta ((charset "UTF-8")))
        `(meta ((name "description") (content "personal blog")))
        `(meta ((name "author")
                (content "anonymous")))
        `(meta ((name "keywords")
                (content ,(string-join (list "web culture criticism"
                                             "philosophy"
                                             "ethics"
                                             "free software")
                                       ","))))))
