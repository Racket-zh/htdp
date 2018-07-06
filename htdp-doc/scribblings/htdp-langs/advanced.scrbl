#lang scribble/doc
@(require "common.rkt" "std-grammar.rkt" "prim-ops.rkt"
          (for-label lang/htdp-advanced))

@title[#:tag "advanced"]{高级}

@section-index["ASL"]

@declare-exporting[lang/htdp-advanced]

@grammar

@racketgrammar*+qq[
#:literals (define define-struct define-datatype lambda λ cond else if and or require lib planet
            local let let* letrec time begin begin0 set! delay shared recur when case match unless
             ; match
             _ cons list list* struct vector box
            check-expect check-random check-within check-member-of
	    check-range check-error check-satisfied)
(expr  check-satisfied check-expect check-random check-within check-error check-member-of check-range require)
[program (code:line def-or-expr #, @dots)]
[def-or-expr definition
             expr
             test-case
             library-require]
[definition (define (name variable #, @dots) expr)
            (define name expr)
            (define-struct name (name #, @dots))
            (define-datatype name (name name #, @dots) #, @dots)]
[expr (begin expr expr #, @dots)
      (begin0 expr expr #, @dots)
      (set! variable expr)
      (delay expr)
      (lambda (variable #, @dots) expr)
      (λ (variable #, @dots) expr)
      (local [definition #, @dots] expr)
      (letrec ([name expr] #, @dots) expr)
      (shared ([name expr] #, @dots) expr)
      (let ([name expr] #, @dots) expr)
      (let name ([name expr] #, @dots) expr)
      (let* ([name expr] #, @dots) expr)
      (recur name ([name expr] #, @dots) expr)
      (code:line (expr expr #, @dots))
      (cond [expr expr] #, @dots [expr expr])
      (cond [expr expr] #, @dots [else expr])
      (case expr [(choice choice #, @dots) expr] #, @dots 
                 [(choice choice #, @dots) expr])
      (case expr [(choice choice #, @dots) expr] #, @dots 
                 [else expr])
      (match expr [pattern expr] #, @dots)
      (if expr expr expr)
      (when expr expr)
      (unless expr expr)
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
[choice (code:line name)
        number]
[pattern _
         name
         number
         true
         false
         string
         character
         @#,elem{@racketvalfont{'}@racket[_quoted]}
         @#,elem{@racketvalfont{`}@racket[_quasiquoted-pattern]}
         (cons pattern pattern)
         (list pattern #, @dots)
         (list* pattern #, @dots)
         (struct id (pattern #, @dots))
         (vector pattern #, @dots)
         (box pattern)]
[quasiquoted-pattern name
                     number
                     string
                     character
                     (quasiquoted-pattern #, @dots)
                     @#,elem{@racketvalfont{'}@racket[_quasiquoted-pattern]}
                     @#,elem{@racketvalfont{`}@racket[_quasiquoted-pattern]}
                     @#,elem{@racketfont[","]@racket[_pattern]}
                     @#,elem{@racketfont[",@"]@racket[_pattern]}]
]


@prim-nonterms[("advanced") define define-struct]

@prim-variables[("advanced") empty true false .. ... .... ..... ......]

@; ----------------------------------------------------------------------
@section[#:tag "advanced-syntax"]{高级的语法}

在高级语言中，可以用@racket[set!]来修改变量的值，@racket[define-struct]所定义的结构体也是可变的。@racket[define]和@racket[lambda]可以定义零参数的函数，函数调用也可以使用零个参数。


@defform[(lambda (variable #, @dots) expression)]{

创建函数，其函数体为@racket[expression]，它接收与给定@racket[variable]数量一样多的参数。}

@defform[(λ (variable #, @dots) expression)]{

希腊字母@racket[λ]是@racket[lambda]的同义词。}

@defform/none[(expression expression #, @dots)]{

调用第一个@racket[expression]计算所得的函数。函数调用的值是函数体的值，其中每个@racket[name]变量的实例都被替换为对应@racket[expression]的值。

被调用的函数必须来自函数调用之前出现的定义，或来自@racket[lambda]表达式。 参数@racket[expression]的数量必须与函数预期的参数数量相同。}

@; ----------------------------------------------------------------------


@defform[(define-datatype dataype-name [variant-name field-name #, @dots] #, @dots)]{

定义一组相关结构体的简写形式。以下@racket[define-datatype]：

@racketblock[
 (define-datatype datatype-name
   [variant-name field-name (unsyntax @racketidfont{#, @dots})]
   (unsyntax @racketidfont{...}))
]
等价于：
@racketblock[
 (define ((unsyntax @racket[datatype-name])? x)
   (or ((unsyntax @racket[variant-name])? x) (unsyntax @racketidfont{...})))
 (define-struct variant-name (field-name (unsyntax @racketidfont{...})))
 (unsyntax @racketidfont{...})
]}



@defform[(begin expression expression #, @dots)]{

按从左到右的顺序对@racket[expression]求值。@racket[begin]表达式的值是最后一个@racket[expression]的值。}



@defform[(begin0 expression expression #, @dots)]{

按从左到右的顺序对@racket[expression]求值。@racket[begin]表达式的值是第一个@racket[expression]的值。}



@defform[(set! variable expression)]{

计算@racket[expression]的值，然后对@racket[variable]赋值。@racket[variable]必须由@racket[define]、@racket[letrec]、@racket[let*]或@racket[let]定义。}


@defform[(delay expression)]{

返回对@racket[expression]求值的“承诺”。@racket[expression]不会被求值，直到这个承诺被@racket[force]强制求值；强制求值承诺时，结果会被记录，以后所有对该承诺的@racket[force]都会立即返回这个记住的值。}



@defform[(shared ([name expression] #, @dots) expression)]{

类似于@racket[letrec]，但当@racket[name]旁边的@racket[expression]是@racket[cons]、@racket[list]、@racket[vector]、quasiquote的表达式、或来自@racket[define-struct]的@racketidfont{make-}@racket[_struct-name]时，该@racket[expression]可以直接引用任意的@racket[name]，而不仅限于之前定义过的@racket[name]。因此，@racket[shared]可用于创建循环数据结构。}


@; ----------------------------------------------------------------------


@defform[(recur name ([name expression] #, @dots) expression)]{

递归循环的简写语法。第一个@racket[name]对应于递归函数的名称。括号中的@racket[name]是函数的参数，对应的@racket[expression]是初次调用函数时提供给参数的值。最后一个@racket[expression]是函数体。

更确切地说，以下@racket[recur]：

@racketblock[
(recur func-name ([arg-name arg-expression] (unsyntax @racketidfont{...}))
  body-expression)
]

等价于：

@racketblock[
(local [(define (func-name arg-name (unsyntax @racketidfont{...})) body-expression)]
  (func-name arg-expression (unsyntax @racketidfont{...})))
]}


@defform/none[(let name ([name expression] #, @dots) expression)]{

等价于@racket[recur]。}


@; ----------------------------------------------------------------------


@defform[(case expression [(choice #, @dots) expression] #, @dots [(choice #, @dots) expression])]{

@racket[case]语法包含一个或多个子句。子句由（括号中的）choice（选项）——可以是数值或名称——以及答案@racket[expression]组成。先计算第一个@racket[expression]，然后按顺序将其值和每个子句中的选项们比较。第一个匹配choice的行提供答案@racket[expression]，它的值就是整个@racket[case]的值。在choice中，数值匹配数值，而符号匹配其名称。如果没有任何一行包含匹配的choice，那么程序出错。
}

@defform/none[#:literals (case else)
              (case expression [(choice #, @dots) expression] #, @dots [else expression])]{

这种形式的@racket[case]的类似于前一种，唯一的区别是，如果没有子句包含与第一个@racket[expression]匹配的选项，那么执行@racket[else]子句。}

@; ----------------------------------------------------------------------


@defform[(match expression [pattern expression] #, @dots)]{

@racket[match]语法包含一个或多个方括号括起来的子句。子句由模式——对值的描述——和答案@racket[expression]组成。先计算第一个@racket[expression]，然后按顺序将其值与子句中的模式进行匹配。第一个包含匹配模式的子句提供答案@racket[expression]，它的值就是整个@racket[match]表达式的值。答案@racket[expression]还可以引用匹配模式中定义的标识符。如果没有子句包含匹配模式，那么程序出错。}

@; ----------------------------------------------------------------------


@defform[(when question-expression body-expression)]{

如果@racket[question-expression]求值为@racket[true]，那么@racket[when]表达式的值就是@racket[body-expression]的值，否则就是@racket[(void)]而且@racket[body-expression]不会被求值。如果计算@racket[question-expression]所得既不是@racket[true]也不是@racket[false]，那么程序出错。}

@defform[(unless question-expression body-expression)]{

类似于@racket[when]，但@racket[body-expression]在@racket[question-expression]计算为@racket[false]而不是@racket[true]时被求值。}


@section[#:tag "advanced-common-syntax"]{通用的语法}

以下语法在@emph{高级}中的行为和@secref["intermediate-lam"]中相同。


@(intermediate-forms lambda
                     local
                     letrec
                     let*
                     let
                     time
                     define
                     define-struct)


@(define-forms/normal define)

@(prim-forms ("advanced")
             define 
             lambda
             define-struct 
             @{在高级语言中，@racket[define-struct]会多引入一个函数：
              @itemize[
               @item{@racketidfont{set-}@racket[_structure-name]@racketidfont{-}@racket[_field-name]@racketidfont{!}
                ：读入结构体实例和值，对实例的字段赋值。}]}
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

@; ----------------------------------------

@section[#:tag "advanced-pre-defined"]{预定义函数}

@pre-defined-fun

@(require (submod lang/htdp-advanced procedures))
@(render-sections (docs) #'here "htdp-advanced")

@;prim-op-defns['(lib "htdp-advanced.rkt" "lang") #'here '()]
