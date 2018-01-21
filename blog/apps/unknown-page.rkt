#lang racket

(require "../response.rkt"
         "../html-proc.rkt"
         web-server/servlet)

(provide respond-unknown-file)

(define (respond-unknown-file req)
  (display "REQUEST:") (displayln req)
  (displayln "RESPONSE:") (displayln (finalize-html-content (render-404)))
  (make-response #:code 404
                 #:message #"ERROR"
                 (finalize-html-content (render-404))))

(define (render-404)
  `(html (head (title "404 - not found"))
         (body (h1 "unknown route"))))
