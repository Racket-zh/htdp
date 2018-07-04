#lang scribble/doc
@(require "common.rkt" "std-grammar.rkt" "prim-ops.rkt"
          (for-label lang/htdp-intermediate))


@title[#:tag "intermediate"]{中级}

@section-index["ISL"]

@declare-exporting[lang/htdp-intermediate]

@grammar

@racketgrammar*+qq[
#:literals (define define-struct lambda cond else if and or require lib planet
            local let let* letrec time check-expect check-random check-within check-error check-satisfied)
(expr check-satisfied check-expect check-random check-within check-member-of check-range check-error require)
[program (code:line def-or-expr #, @dots)]
[def-or-expr definition
             expr
             test-case
             library-require]
[definition (define (name variable variable #, @dots) expr)
            (define name expr)
            (define name (lambda (variable variable #, @dots) expr))
            (define-struct name (name #, @dots))]
[expr (local [definition #, @dots] expr)
      (letrec ([name expr-for-let] #, @dots) expr)
      (let ([name expr-for-let] #, @dots) expr)
      (let* ([name expr-for-let] #, @dots) expr)
      (code:line (name expr expr #, @dots) )
      (cond [expr expr] #, @dots [expr expr])
      (cond [expr expr] #, @dots [else expr])
      (if expr expr expr)
      (and expr expr expr #, @dots)
      (or expr expr expr #, @dots)
      (time expr)
      (code:line name)
      (code:line @#,elem{@racketvalfont{'}@racket[_quoted]})
      (code:line @#,elem{@racketvalfont{`}@racket[_quasiquoted]})
      (code:line @#,elem{@racketvalfont{'}@racket[()]}) 
      number
      boolean 
      string
      character]
[expr-for-let (lambda (variable variable #, @dots) expr)
              expr]
]

@prim-nonterms[("intermediate") define define-struct]

@prim-variables[("intermediate") empty true false .. ... .... ..... ......]

@; ----------------------------------------------------------------------

@section[#:tag "intermediate-syntax"]{中级的语法}


@(intermediate-forms lambda
                     local
                     letrec
                     let*
                     let
                     time
                     define
                     define-struct)

@; ----------------------------------------------------------------------

@section[#:tag "intermediate-common-syntax"]{通用的语法}

以下语法在@emph{中级}中的行为和@secref["beginner-abbr"]中相同。

@(beginner-abbr-forms quote quasiquote unquote unquote-splicing)

@(define-forms/normal define)
@(define-form/explicit-lambda define lambda)

@(prim-forms 
                     ("intermediate")
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
                     #:with-beginner-function-call #t)




@section[#:tag "intermediate-pre-defined" ]{预定义函数}

后续小节列出了编程语言中内置的函数。所有其他函数要么从教学包中导入，要么必须在程序中定义。

@(require (submod lang/htdp-intermediate procedures))
@(render-sections (docs) #'here "htdp-intermediate")

@;prim-op-defns['(lib "htdp-intermediate.rkt" "lang") #'here '()]

