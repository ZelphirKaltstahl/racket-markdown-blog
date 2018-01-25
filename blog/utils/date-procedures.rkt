#lang racket

(require racket/date)

;; which date?
(provide (contract-out [make-simple-germany-date
                        (-> (integer-in 1 31)
                            (integer-in 1 12)
                            exact-integer?
                            date?)]
                       [simple-date-equal?
                        (-> date? date? boolean?)]
                       [my-date->string
                        (-> date? string?)]
                       [make-simple-date-from-iso-string
                        (-> string? date?)]
                       [day-month-year->yearday
                        (-> (integer-in 1 31)
                            (integer-in 1 12)
                            exact-integer?
                            (integer-in 0 365))]
                       [make-iso-string-from-date
                        (-> date? string?)]))

#;(provide (all-defined-out))

;; === WORKING WITH DATES ===
(define (simple-date-equal? date1 date2)
  (and (equal? (date-year date1) (date-year date2))
       (equal? (date-month date1) (date-month date2))
       (equal? (date-day date1) (date-day date2))))

(define (my-date->string a-date)
  (date-display-format 'iso-8601)
  (define (at-least-two-digits num-string)
    (if (= (string-length num-string) 1)
        (string-append "0" num-string)
        num-string))
  (let
    ([iso-date-string (date->string a-date)]
      [week-day-number-to-string
        (hash
          0 "Sun"
          1 "Mon"
          2 "Tue"
          3 "Wed"
          4 "Thu"
          5 "Fri"
          6 "Sat")])
    (string-append
     (string-join (map at-least-two-digits (string-split iso-date-string "-")) "-")
     ", "
     (hash-ref week-day-number-to-string (date-week-day a-date) "unknown"))))

(define (make-simple-date-from-iso-string iso-date-string)
  (let*
    ([parts (string-split iso-date-string "-")]
      [year (string->number (first parts))]
      [month (string->number (second parts))]
      [day (string->number (third parts))])
    (make-simple-germany-date day month year)))

;; Given a day, month, and year, return the weekday
;; http://stackoverflow.com/a/13432738/1829329
(define (day-month-year->weekday day month year)
  (let*
    ([local-secs (find-seconds 0 0 0 day month year #t)]
      [the-date (seconds->date local-secs)])
    (date-week-day the-date)))

;; Given a day, month, and year, return the year-day
;; http://stackoverflow.com/a/13432738/1829329
(define (day-month-year->yearday day month year)
  (let*
    ([local-secs (find-seconds 0 0 0 day month year #t)]
      [the-date (seconds->date local-secs)])
    (date-year-day the-date)))

(define (make-iso-string-from-date date)
  (string-join (map number->string
                    (list (date-year date)
                          (date-month date)
                          (date-day date)))
               "-"))

(define (make-simple-germany-date day month year)
  (date
    0 0 0
    day month year
    (day-month-year->weekday day month year)
    (day-month-year->yearday day month year)
    #t
    7200))
