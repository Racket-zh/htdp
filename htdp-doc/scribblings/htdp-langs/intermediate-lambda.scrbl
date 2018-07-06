#lang scribble/doc
@(require "common.rkt" "std-grammar.rkt" "prim-ops.rkt"
          (for-label lang/htdp-intermediate-lambda))

@title[#:tag "intermediate-lam"]{中级+lambda}

@section-index["ISL+"]

@declare-exporting[lang/htdp-intermediate-lambda]

@grammar

@racketgrammar*+qq[
#:literals (define define-struct lambda λ cond else if and or require lib planet
            local let let* letrec time check-expect check-random
	    check-within check-member-of check-range check-error check-satisfied)
(expr check-satisfied check-expect check-random check-within check-member-of check-range check-error require)
[program (code:line def-or-expr #, @dots)]
[def-or-expr definition
             expr
             test-case
             library-require]
[definition (define (name variable variable #, @dots) expr)
            (define name expr)
            (define-struct name (name #, @dots))]
[expr (lambda (variable variable #, @dots) expr)
      (λ (variable variable #, @dots) expr)
      (local [definition #, @dots] expr)
      (letrec ([name expr] #, @dots) expr)
      (let ([name expr] #, @dots) expr)
      (let* ([name expr] #, @dots) expr)
      (code:line (expr expr expr #, @dots))
      (cond [expr expr] #, @dots [expr expr])
      (cond [expr expr] #, @dots [else expr])
      (if expr expr expr)
      (and expr expr expr #, @dots)
      (or expr expr expr #, @dots)
      (time expr)
      (code:line name)
      (code:line prim-op)
      (code:line @#,elem{@racketvalfont{'}@racket[_quoted]})
      (code:line @#,elem{@racketvalfont{`}@racket[_quasiquoted]})
      (code:line @#,elem{@racketvalfont{'}@racket[()]}) 
      number
      boolean 
      string
      character]
]

@prim-nonterms[("intm-w-lambda") define define-struct]

@prim-variables[("intm-w-lambda") empty true false .. ... .... ..... ......]


@; ----------------------------------------------------------------------

@section[#:tag "intm-w-lambda-syntax"]{中级+lambda的语法}


@defform[(lambda (variable variable #, @dots) expression)]{

创建函数，该函数接受与@racket[variable]数量一样多的参数，函数体为@racket[expression]。}

@defform[(λ (variable variable #, @dots) expression)]{

希腊字母@racket[λ]是@racket[lambda]的同义词。}



@defform/none[(expression expression expression #, @dots)]{

调用对第一个@racket[expression]求值得到的函数。函数调用的值是函数体的值，其中每个@racket[name]变量的实例被替换为对应@racket[expression]的值。

被调用的函数必须来自函数调用之前出现过的定义，或来自@racket[lambda]表达式。参数@racket[expression]的数量必须与函数预期的参数数量相同。}



@(intermediate-forms lambda
                     local
                     letrec
                     let*
                     let
                     time
                     define
                     define-struct)



@; ----------------------------------------------------------------------

@section[#:tag "intm-w-lambda-common-syntax"]{通用的语法}

以下语法在@emph{中级+lambda}中的行为和@secref["intermediate"]中相同。

@(define-forms/normal define)

@(beginner-abbr-forms quote quasiquote unquote unquote-splicing)

@(prim-forms ("intermediate-lam")
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
             #:with-beginner-function-call #f)

@section[#:tag "intm-w-lambda-pre-defined"]{预定义函数}

@pre-defined-fun

@(require (submod lang/htdp-intermediate-lambda procedures))
@(render-sections (docs) #'here "htdp-intermediate-lambda")

@;prim-op-defns['(lib "htdp-intermediate-lambda.rkt" "lang") #'here '()]
