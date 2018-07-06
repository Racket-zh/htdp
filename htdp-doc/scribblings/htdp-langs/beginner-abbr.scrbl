#lang scribble/doc

@(require "common.rkt" "std-grammar.rkt" "prim-ops.rkt" (for-label lang/htdp-beginner-abbr))

@title[#:tag "beginner-abbr"]{初级+缩写的表}

@section-index["BSL+"]

@declare-exporting[lang/htdp-beginner-abbr]

@grammar 

@i1-2-expl

@i2-3-expl

@racketgrammar*+qq[
#:literals (define define-struct lambda cond else if and or require lib planet
            check-expect check-random check-within check-error check-satisfied)
(name check-satisfied check-expect check-random check-within check-member-of check-range check-error require)
[program (code:line def-or-expr #, @dots)]
[def-or-expr definition
             expr
             test-case
             library-require]
[definition (define (name variable variable #, @dots) expr)
            (define name expr)
            (define name (lambda (variable variable #, @dots) expr))
            (define-struct name (name #, @dots))]
[expr (code:line (name expr expr #, @dots))
      (code:line (prim-op expr #, @dots))
      (cond [expr expr] #, @dots [expr expr])
      (cond [expr expr] #, @dots [else expr])
      (if expr expr expr)
      (and expr expr expr #, @dots)
      (or expr expr expr #, @dots)
      name
      (code:line @#,elem{@racketvalfont{'}@racket[_quoted]})
      (code:line @#,elem{@racketvalfont{`}@racket[_quasiquoted]})
      (code:line @#,elem{@racketvalfont{'}@racket[()]})
      number
      boolean
      string
      character]
]

@prim-nonterms[("beginner-abbr") define define-struct]

@prim-variables[("beginner-abbr") empty true false .. ... .... ..... ......]

@; ----------------------------------------

@section[#:tag "beginner-abbr-syntax"]{初级+缩写的表的语法}

@(beginner-abbr-forms quote quasiquote unquote unquote-splicing)



@; ----------------------------------------------------------------------
@section[#:tag "beginner-abbr-common-syntax"]{通用的语法}

以下语法在@emph{初级+缩写的表}中的行为和@secref["beginner"]中相同。

@(define-forms/normal define)
@(define-form/explicit-lambda define lambda)


@prim-forms[("beginner-abbr")
            define 
            lambda
            define-struct []
            define-wish
            cond
            else
            if
            and 
            or
            check-expect
            check-random
	    check-satisfied
            check-within
            check-error
            check-member-of
            check-range
            require
            true false
             #:with-beginner-function-call #t]


@; ----------------------------------------

@section[#:tag "beginner-abbr-pre-defined"]{预定义函数}

@pre-defined-fun

@(require (submod lang/htdp-beginner-abbr procedures))
@(render-sections (docs) #'here "htdp-beginner-abbr")

@;prim-op-defns['(lib "htdp-beginner-abbr.rkt" "lang") #'here '()]
