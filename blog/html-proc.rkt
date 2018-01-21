#lang racket

(require xml
         web-server/servlet)

(provide finalize-html-content)

(define (add-doctype html-string)
  (string-append "<!DOCTYPE html>\n"
                 html-string))

;; expects a single xexpr
;; + converts to string
;; + adds html doctype
(define (finalize-html-content html-content)
  (add-doctype (xexpr->string html-content)))

(define (xexpr->xml-string-pretty x)
  (with-output-to-string
   (λ ()
     (display-xml/content
      (xexpr->xml x)))))
