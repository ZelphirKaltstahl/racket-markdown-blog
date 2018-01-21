#lang racket

(require pollen/unstable/pygments
         "utils/list-operations.rkt")

(provide highlight-code-xexprs)

;; replaces (pre ([class "brush: lang"]) ....) with pygmentized code xexpr
(define (highlight-code-xexprs list-of-xexprs)
  ;; define known languages
  (define KNOWN-LANGUAGES
    (list "python"
          "racket"
          "html"
          "css"
          "javascript"
          "erlang"
          "rust"
          "bash"
          "shell"
          "sh"))
  ;; check if it matches for a single language's match expression
  ;; if it mathces any language, return that language's name as a symbol
  (define (get-matching-language an-xexpr)
    (define (get-brush-language an-xexpr)
      (match an-xexpr
        [`(pre ([class ,brush-lang]) (code () ,code-text ...)) brush-lang]
        [_ #f]))
    (define (extract-lang-from-brush-lang brush-lang)
      (and brush-lang
           (list-ref (regexp-match #rx"brush: ([^ ]+)\\s*"
                                   brush-lang)
                     1)))
    (let* ([matched-lang (extract-lang-from-brush-lang (get-brush-language an-xexpr))]
           [in-known-languages (member matched-lang KNOWN-LANGUAGES)])
      (and in-known-languages (car in-known-languages))))

  (define (get-code-text-from-xexpr an-xexpr)
    (match an-xexpr
      [`(pre ([class ,brush-lang]) (code () ,code-text ...)) code-text]
      [_ ""]))

  ;; replace code in an xexpr with highlightable code
  ;; TODO: What happens if the code is in a lower level of the xexpr?
  (define (replace-code-in-single-xexpr an-xexpr)
    (let ([matching-language (get-matching-language an-xexpr)])
      (cond [matching-language (displayln (format "found code of language ~a" matching-language))
                               (code-highlight matching-language
                                               (get-code-text-from-xexpr an-xexpr))]
            [else an-xexpr])))

  ;; apply the check to all xexpr
  (apply-filtered* get-matching-language
                   replace-code-in-single-xexpr
                   list-of-xexprs)
  #;(map replace-code-in-single-xexpr list-of-xexprs))

(define (code-highlight language code)
  (let ([lines-of-code (string-join code "")])
    ;;(displayln (highlight language lines-of-code))
    (highlight language lines-of-code)))
