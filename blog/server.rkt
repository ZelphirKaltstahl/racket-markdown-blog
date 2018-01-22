#lang racket

;; ==============
;; PREDEFINITIONS
;; ==============
(define (Mb-to-B n) (* n 1024 1024))
(define MAX-BYTES (Mb-to-B 128))
(define nil '())
(custodian-limit-memory (current-custodian) MAX-BYTES)

;; =======================
;; PROVIDING AND REQUIRING
;; =======================
(provide/contract
  (start (-> request? response?)))

(require web-server/templates
         web-server/servlet-env
         web-server/servlet
         web-server/dispatch
         racket/date
         "apps/unknown-page.rkt"
         "apps/blog.rkt")

;; ======
;; MACROS
;; ======
(define-syntax-rule (add-route route method proc)
  (dispatch-rules! blog-container
                   [route #:method method proc]))

;; ====================
;; ROUTES MANAGING CODE
;; ====================
(define (start request)
  ;; for now only calling the dispatch
  ;; we could put some action here, which shall happen before each dispatching
  (blog-dispatch request))

(define-container blog-container (blog-dispatch a-url))  ;; what can we do with a container?

(add-route ("") "get" blog-app)
(add-route ("page" (integer-arg)) "get" blog-app)
(add-route ("post" (integer-arg)) "get" post-app)
(add-route ("tag" (string-arg)) "get" tag-app)
(add-route ("tag" (string-arg) "page" (integer-arg)) "get" tag-app)

;; =================
;; RUNNING A SERVLET
;; =================
(serve/servlet
  start
  #:servlet-path "/index"  ; default URL
  #:extra-files-paths (list (build-path (current-directory) "static"))  ; directory for static files
  #:port 8000 ; the port on which the servlet is running
  #:servlet-regexp #rx""
  #:launch-browser? false  ; should racket show the servlet running in a browser upon startup?
  ;; #:quit? false  ; ???
  #:listen-ip false  ; the server will listen on ALL available IP addresses, not only on one specified
  #:server-root-path (current-directory)
  #:file-not-found-responder respond-unknown-file)

;; from the Racket documentation:
;; When you use web-server/dispatch with serve/servlet, you almost always want to use the #:servlet-regexp argument with the value "" to capture all top-level requests. However, make sure you don’t include an else in your rules if you are also serving static files, or else the filesystem server will never see the requests.
;; https://docs.racket-lang.org/web-server/dispatch.html
