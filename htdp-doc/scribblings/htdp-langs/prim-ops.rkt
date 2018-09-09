#lang at-exp racket/base
(provide prim-variables
         prim-forms
         define-forms/normal
         define-form/explicit-lambda
         beginner-abbr-forms
         intermediate-forms
         prim-ops
         prim-op-defns)

(require "common.rkt"
         scribble/decode
         scribble/struct
         scribble/racket
         scribble/eval
	 racket/sandbox
         racket/list
         racket/pretty
         syntax/docprovide
	 (for-label lang/htdp-intermediate)
         (for-syntax racket/base))

(define (maybe-make-table l t)
  (if (paragraph? t)
      (make-paragraph
       (append l (cons " "
                       (paragraph-content t))))
      (make-table
       "prototype"
       (list (list (make-flow (list (make-paragraph l)))
                   (make-flow (list t)))))))

(define-syntax-rule
  (mk-eval defs ...)
  ;; ==>
  (let ([me (make-base-eval)])
    (define run? #f)
    (call-in-sandbox-context me (lambda () (error-print-source-location #f) (sandbox-output 'string)))
    (interaction-eval #:eval me '(require test-engine/racket-tests))
    (interaction-eval #:eval me defs)
    ...
    (lambda (x) (begin0 (me x) (unless run? (set! run? #t) (me '(test)))))))

@(define e1 (mk-eval (require test-engine/racket-tests) (define (fahrenheit->celsius f) (* 5/9 (- f 32)))))

@(define evil
(mk-eval
 (require racket/list)
 (require racket/bool)
 (require test-engine/racket-tests)
(define (sorted? l)
  (cond
    [(empty? (rest l)) #true]
    [else (and (<= (first l) (second l)) (sorted? (rest l)))]))

(define (htdp-sort l)
  (cond
    [(empty? l) l]
    [else (insert (first l) (htdp-sort (rest l)))]))

(define (insert x l)
  (cond
    [(empty? l) (list x)]
    [else (if (<= x (first l)) (cons x l) (cons (first l) (insert x (rest l))))]))
))

(define (typeset-type type)
  (let-values ([(in out) (make-pipe)])
    (parameterize ([pretty-print-columns 50])
      (pretty-write type out))
    (port-count-lines! in)
    (read-syntax #f in)))

(define (sort-category category)
  (sort
   (cadr category)
   (lambda (x y)
     (string<=? (symbol->string (car x))
                (symbol->string (car y))))))


(define (make-proto func ctx-stx)
  (maybe-make-table
   (list
    (hspace 2)
    (to-element (datum->syntax ctx-stx (car func)))
    (hspace 1)
    ":"
    (hspace 1))
   (to-paragraph
    (typeset-type (cadr func)))))

(define-syntax-rule
  (prim-variables (section-prefix) empty true false dots ...)
  ;; ===>
  (make-splice
   (list
    @section[#:tag (string-append section-prefix " Pre-Defined Variables")]{预定义变量}

    @defthing[empty empty?]{
      空表。}

   @defthing[true boolean?]{
      @code{#true}值。}

   @defthing[false boolean?]{
      @code{#false}值。}

    @section[#:tag (string-append section-prefix " Template Variables")]{模板变量}
    @defidform[dots]{表明定义是模版的占位符。} ...
    )))

;; ----------------------------------------

(define-syntax-rule (define-forms/normal define)
  (gen-define-forms/normal #'define @racket[define]))

(define (gen-define-forms/normal define-id define-elem)
  ;; Since `define' has a source location different from the use site,
  ;; use the `#:id [spec-id bind-id]' form in `defform*':
  (list
   @defform*[#:id [define define-id]
             [(define (name variable variable ...) expression)]]{

   定义名为@racket[name]的函数。@racket[expression]为函数体。调用函数时，实际参数值会替换函数体中的@racket[variable]们。新表达式的值就是函数的返回值。

   函数名不能与其他函数或变量相同。}

   @defform/none[(@#,define-elem name expression)]{

   定义名为@racket[name]的变量，其值为@racket[expression]的值。变量名不能与其他函数或变量相同，而且@racket[name]自身也不能出现在@racket[expression]中。}))

;; ----------------------------------------

(define-syntax-rule (define-form/explicit-lambda define lambda)
  (gen-define-form/explicit-lambda @racket[define]
                                   #'lambda @racket[lambda]))

(define (gen-define-form/explicit-lambda define-elem lambda-id lambda-elem)
  (list
   @defform/none[(#,define-elem name (#,lambda-elem (variable variable ...) expression))]{

   另一种定义函数的方法。@racket[name]是函数名，它不能与其他函数或变量相同。

   除了这种语法之外，不能使用@defidform/inline[#,lambda-id]。}))

;; ----------------------------------------

(define-syntax-rule (prim-forms
                     (section-prefix)
                     define
                     lambda
                     define-struct [ds-extra ...]
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
                     true
                     false
                     #:with-beginner-function-call with-beginner-function-call)
  (gen-prim-forms #'define-struct @racket[define-struct] (list ds-extra ...)
                  #'cond @racket[cond]
                  #'else @racket[else]
                  #'if @racket[if]
                  #'or @racket[or]
                  #'and @racket[and]
                  #'check-expect @racket[check-expect]
                  #'check-random @racket[check-random]
		  #'check-satisfied @racket[check-satisfied]
                  #'check-within @racket[check-within]
                  #'check-error @racket[check-error]
                  #'check-member-of @racket[check-member-of]
                  #'check-range @racket[check-range]
                  #'require @racket[require]
                  @racket[#true] @racket[#false]
                  with-beginner-function-call))

(define (gen-prim-forms define-struct-id define-struct-elem ds-extras
                        cond-id cond-elem
                        else-id else-elem
                        if-id if-elem
                        or-id or-elem
                        and-id and-elem
                        check-expect-id check-expect-elem
                        check-random-id check-random-elem
			check-satisfied-id check-satisfied-elem
                        check-within-id check-within-elem
                        check-error-id check-error-elem
                        check-member-of-id check-member-of-elem
                        check-range-id check-range-elem
                        require-id require-elem
                        true-elem false-elem
                        with-beginner-function-call)
  (list
   @; ----------------------------------------------------------------------

  @defform*[#:id [define-struct define-struct-id]
            [(define-struct structure-name (field-name ...))]]{

   定义名为@racket[structure-name]的新结构体。结构体的字段名由@racket[field-name]们给定。@define-struct-elem 会定义下列函数：

   @itemize[

     @item{@racketidfont{make-}@racket[structure-name] ：读入和结构体字段数一样多的参数，并创建结构体的新实例。}

     @item{@racket[structure-name]@racketidfont{-}@racket[field-name] ：读入结构体实例，返回名为@racket[field-name]字段的值。}

     @item{@racket[structure-name]@racketidfont{?} ：读入任意值，如果该值是结构体的实例就返回@true-elem 。}
   ]

   由@define-struct-elem 引入的新函数名必须不同与其他函数或变量，否则@define-struct-elem 会报告错误。

   @ds-extras}

  #|

  @defform*[[(define-wish name)]]{

  Defines a function called @racket[name] that we wish exists but have not
  implemented yet. The wished-for function can be called with one argument, and
  are reported in the test report for the current program.

  The name of the function cannot be the same as another function or variable.}


  @defform/none[#:literals (define-wish)
                (define-wish name expression)]{
  Similar to the above form, defines a wished-for function named @racket[name]. If the
  wished-for function is called with one value, it returns the values of @racket[expression]. }
  |#

  @; ----------------------------------------------------------------------

  @(if with-beginner-function-call
       @defform/none[(name expression expression ...)]{
        调用名为@racket[name]的函数。函数调用的返回值是@racket[name]函数体的值，其中每个函数的参数都被替换为对应@racket[expression]的值。

        名为@racket[name]的函数必须在可以调用之前定义。参数@racket[expression]的数量必须和函数所期望的参数数量一致。}
       @elem[])

  @; ----------------------------------------------------------------------

  @defform*[#:id [cond cond-id]
            #:literals (else)
            [(cond [question-expression answer-expression] ...)
             (#,cond-elem [question-expression answer-expression]
                          ...
                          [#,else-elem answer-expression])]]{

    根据条件选择子句。@racket[cond]找出第一个计算为@true-elem
    的@racket[question-expression]，然后计算对应的@racket[answer-expression]。

    如果没有@racket[question-expression]的计算结果为@true-elem ，那么@cond-elem
    的值是@else-elem 子句中的@racket[answer-expression]。如果不存在@else-elem
    子句，@cond-elem 报告错误。如果某个@racket[question-expression]的值既不是@true-elem
    也不是@false-elem ，@cond-elem 也报告错误。

    不能在@|cond-elem|之外使用@defidform/inline[#,else-id]。}

  @; ----------------------------------------------------------------------

  @defform*[#:id [if if-id]
            [(if question-expression
		 then-answer-expression
		 else-answer-expression)]]{

   如果@racket[question-expression]的值是@true-elem ，@if-elem
   计算@racket[then-answer-expression]的值。如果测试得到@false-elem
   ，@if-elem 计算@racket[else-answer-expression]的值。

   如果@racket[question-expression]既不是@true-elem 也不是@false-elem
   ，@if-elem 报告错误。}

  @; ----------------------------------------------------------------------

  @defform*[#:id [and and-id]
            [(and expression expression expression ...)]]{

    如果所有@racket[expression]都求值为@|true-elem|，@and-elem
    表达式求值为@true-elem
    。如果任何@racket[expression]是@|false-elem|，@and-elem
    表达式计算为@false-elem （并且此表达式右侧的表达式不会被求值）。

    如果任何一个表达式求值既不是@true-elem 也不是@false-elem
    ，@and-elem 报告错误。}

  @; ----------------------------------------------------------------------


  @defform*[#:id [or or-id]
            [(or expression expression expression ...)]]{

    只要一个@racket[expression]求值为@true-elem ，@or-elem
    表达式就求值为@true-elem
   （并且此表达式右侧的表达式不会被求值）。如果所有@racket[expression]都是@|false-elem|，@or-elem
    表达式求值为@|false-elem|。

    如果任何一个表达式求值既不是@true-elem 也不是@false-elem
    ，@or-elem 报告错误。}

  @; ----------------------------------------------------------------------

  @defform*[#:id [check-expect check-expect-id]
            [(check-expect expression expected-expression)]]{

   检查第一个@racket[expression]求得的值和@racket[expected-expression]相同。

@;%
@(begin
#reader scribble/comment-reader
(racketblock

(check-expect (fahrenheit->celsius 212) 100)
(check-expect (fahrenheit->celsius -40) -40)

(define (fahrenheit->celsius f)
  (* 5/9 (- f 32)))
))
@;%
@racket[check-expect]表达式必须被放在教学语言的顶层。它还可以出现在程序的任何地方，包括被测试函数定义之前。这样放置@racket[check-expect]的话，程序员通过工作示例向未来的阅读者传达程序背后的意图，从而使阅读函数定义变得多余。

@racket[expr]或@racket[expected-expr]返回非精确数或函数是一种错误。对非精确数，简单比较它们@italic{原则上}就是错误的。取而代之的做法，测试它们是否在某个很小的区间内；参见@racket[check-within]。至于函数（参见中级及之后的语言），函数的比较是不可操作的。
}

  @defform*[#:id [check-random check-random-id]
            [(check-random expression expected-expression)]]{

   检查第一个@racket[expression]求得的值和@racket[expected-expression]相同。

@racket[check-random]为其两个部分提供相同的随机数生成器。如果两者以相同的顺序从相同的区间中取@racket[random]数的话，它们会得到相同的随机数。

以下是@racket[check-random]用途的简单示例：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
(define WIDTH 100)
(define HEIGHT (* 2 WIDTH))

(define-struct player (name x y))
;; @italic{Player}是@racket[(make-player String Nat Nat)]

;; String -> Player

(check-random (create-randomly-placed-player "David Van Horn")
	      (make-player "David Van Horn" (random WIDTH) (random HEIGHT)))

(define (create-randomly-placed-player name)
  (make-player name (random WIDTH) (random HEIGHT)))
))
@;%
注意这里两个部分以同样的数值、同样的顺序调用@racket[random]。如果两者调用@racket[random]的区间不同，检查应该会失败:
@;%
@(begin
#reader scribble/comment-reader
(racketblock
;; String -> @italic{Player}

(check-random (create-randomly-placed-player "David Van Horn")
	      (make-player "David Van Horn" (random WIDTH) (random HEIGHT)))

(define (create-randomly-placed-player name)
  (local ((define h (random HEIGHT))
          (define w (random WIDTH)))
    (make-player name w h)))
))
@;%

@racket[expr]或@racket[expected-expr]返回非精确数或函数是一种错误；详情参见@racket[check-expect]的说明。
}

  @defform*[#:id [check-satisfied check-satisfied-id]
            [(check-satisfied expression predicate)]]{

   检查第一个@racket[expression]是否满足名为@racket[predicate]的谓词（单参数函数）。回忆一下，``满足''的意思是``函数对输入值返回@racket[#true]。''

以下是@racket[check-satisfied]的简单示例：
@interaction[
#:eval
(mk-eval
 (require test-engine/racket-tests))
(check-satisfied 1 odd?)
]
@interaction[
#:eval
(mk-eval
 (require test-engine/racket-tests))
(check-satisfied 1 even?)
]

一般来说，@racket[check-satisfied]使程序员可以使用已经定义好的函数来编写测试套件：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
;; [cons Number [List-of Number]] -> Boolean
;; 测试@racket[htdp-sort]的函数

(check-expect (sorted? (list 1 2 3)) #true)
(check-expect (sorted? (list 2 1 3)) #false)

(define (sorted? l)
  (cond
    [(empty? (rest l)) #true]
    [else (and (<= (first l) (second l)) (sorted? (rest l)))]))

;; [List-of Number] -> [List-of Number]
;; 创建输入数值表的排序版本

(check-satisfied (htdp-sort (list 1 2 0 3)) sorted?)

(define (htdp-sort l)
  (cond
    [(empty? l) l]
    [else (insert (first l) (htdp-sort (rest l)))]))

;; Number [List-of Number] -> [List-of Number]
;; 将@racket[x]插入[l]中的合适位置上
;; @bold{假设}@racket[l]按降序排列
;; 返回值也按降序排列
(define (insert x l)
  (cond
    [(empty? l) (list x)]
    [else (if (<= x (first l)) (cons x l) (cons (first l) (insert x (rest l))))]))
))
@;%

是的，@racket[htdp-sort] 的返回值满足@racket[sorted?]谓词：
@interaction[
#:eval evil
(check-satisfied (htdp-sort (list 1 2 0 3)) sorted?)
]
}

  @defform*[#:id [check-within check-within-id]
            [(check-within expression expected-expression delta)]]{

  检查@racket[expression]表达式的值是否结构上等同于@racket[expected-expression]表达式返回的值；前一个表达式中所有的数值都必须在后一个表达式对应数值的@racket[delta]范围内。

@;%
@(begin
#reader scribble/comment-reader
(racketblock
(define-struct roots (x sqrt))
;; RT is [List-of (make-roots Number Number)]

(define (roots-table xs)
  (map (lambda (a) (make-roots a (sqrt a))) xs))
))
@;%

鉴于嵌套数据中存在非精确数，@racket[check-within]是正确的测试工具，如果@racket[delta]足够大，测试就会通过：
@examples[
#:eval
(mk-eval
 (require test-engine/racket-tests)
 (define-struct roots (x sqrt) #:transparent)
 (define (roots-table xs) (map (lambda (a) (make-roots a (sqrt a))) xs)))

(check-within (roots-table (list 1. 2. 3.))
              (list
	        (make-roots 1. 1.)
	        (make-roots 2  1.414)
	        (make-roots 3  1.713))
              .1)
]
反之，如果@racket[delta]很小，测试就会失败：
@examples[
#:eval
(mk-eval
 (require test-engine/racket-tests)
(define-struct roots (x sqrt)
  #:transparent
  #:methods gen:custom-write
  [(define (write-proc x port mode)
     (display `(make-roots ,(roots-x x) ,(roots-sqrt x)) port))])
 (define (roots-table xs) (map (lambda (a) (make-roots a (sqrt a))) xs)))

(check-within (roots-table (list 2.))
              (list
	        (make-roots 2  1.414))
              .00001)
]

  @racket[expressions]或@racket[expected-expression]返回函数是一种错误；详情参见@racket[check-expect]的说明。

  如果@racket[delta]不是数值，@check-within-elem 报告错误。}

  @defform*[#:id [check-error check-error-id]
            [(check-error expression expected-error-message)
             (#,check-error-elem expression)]]{

   检查@racket[expression]报告错误，并且如果有错误信息的话，它符合@racket[expected-error-message]的值。

这是一个典型的初级语言中需要用到@racket[check-error]的例子：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
(define sample-table
  '(("matthias" 10)
    ("matthew"  20)
    ("robby"    -1)
    ("shriram"  18)))

;; [List-of [list String Number]] String -> Number
;; 求@racket[table]中对应于@racket[s]的数值

(define (lookup table s)
  (cond
    [(empty? table) (error (string-append s " not found"))]
    [else (if (string=? (first (first table)) s)
              (second (first table))
              (lookup (rest table)))]))
))
@;%

考虑以下两个例子：

@examples[
#:eval (mk-eval
 (require test-engine/racket-tests racket/list)
(define sample-table
  '(("matthias" 10)
    ("matthew"  20)
    ("robby"    -1)
    ("shriram"  18)))

(define (lookup table s)
  (cond
    [(empty? table) (error (string-append s " not found"))]
    [else (if (string=? (first (first table)) s)
              (second (first table))
              (lookup (rest table) s))]))
)
(check-expect (lookup sample-table "matthew") 20)
]

@examples[
#:eval (mk-eval
 (require test-engine/racket-tests racket/list)
(define sample-table
  '(("matthias" 10)
    ("matthew"  20)
    ("robby"    -1)
    ("shriram"  18)))

(define (lookup table s)
  (cond
    [(empty? table) (error (string-append s " not found"))]
    [else (if (string=? (first (first table)) s)
              (second (first table))
              (lookup (rest table) s))]))
)
(check-error (lookup sample-table "kathi") "kathi not found")
]
}


  @defform*[#:id [check-member-of check-member-of-id]
            [(check-member-of expression expression expression ...)]]{

   检查第一个@racket[expression]的值是后面某个@racket[expression]表达式的值。

@;%
@(begin
#reader scribble/comment-reader
(racketblock
;; [List-of X] -> X
;; 从输入表@racket[l]中随机选择一个元素
(define (pick-one l)
  (list-ref l (random (length l))))
))
@;%

@examples[#:eval
(mk-eval (require test-engine/racket-tests)
(define (pick-one l) (list-ref l (random (length l)))))

(check-member-of (pick-one '("a" "b" "c")) "a" "b" "c")
]

  任何@racket[expressions]返回函数都是错误；详情参见@racket[check-expect]的说明。
   }

  @defform*[#:id [check-range check-range-id]
            [(check-range expression low-expression high-expression)]]{

   检查第一个@racket[expression]的值是位于@racket[low-expression]和@racket[high-expression]值（包含）之间的数值。

@racket[check-range]形式最适合用来给返回非精确数的函数确定范围：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
;; [Real -> Real] Real -> Real
;; @racket[f]在@racket[x]的斜率是多少？
(define (differentiate f x)
  (local ((define epsilon .001)
          (define left (- x epsilon))
          (define right (+ x epsilon))
          (define slope
            (/ (- (f right) (f left))
               2 epsilon)))
    slope))

(check-range (differentiate sin 0) 0.99 1.00)
))
@;%

@racket[expression]、@racket[low-expression]或@racket[high-expression]返回函数或非精确数是一种错误；详情参见@racket[check-expect]的说明。}

  @; ----------------------------------------------------------------------

  @defform*[#:id [require require-id]
            [(require string)]]{

   使由@racket[string]指定的module中的定义在当前module（即文件）中可用，其中@racket[string]指向与相对于当前文件的文件。

   为了避免不同平台上路径的问题，这个@racket[string]受到好几种限制：@litchar{/}是目录之间的分隔符，@litchar{.}永远表示当前目录，@litchar{..}总是表示父目录，路径的元素只能包含@litchar{a}到@litchar{z}（大小写）、@litchar{0}到@litchar{9}、@litchar{-}、@litchar{_}和@litchar{.}，并且该字符串不能为空，也不能在开头或结尾位置包含@litchar{/}。}


  @defform/none[(#,require-elem module-name)]{

   访问已安装库中的文件。这里的库名是个标识符，其约束条件与相对路径字符串相同（尽管不包含引号），此外它不能包含@litchar{.}。}

  @defform/none[(#,require-elem (lib string string ...))]{

  访问已安装库中的文件，使其定义在当前module（即当前文件）中可用。第一个@racket[string]指定了库文件名，后续@racket[string]指定文件所在的collection（以及子collection等）。每个string都受到和@racket[(#,require-elem string)]中一样的限制。}


  @deftogether[(
  @defform/none[#:literals (planet)
                (#,require-elem (planet string (string string number number)))]{}
  @defform/none[#:literals (planet) (#,require-elem (planet id))]{}
  @defform/none[#:literals (planet) (#,require-elem (planet string))]{})]{

  访问在因特网上通过@|PLaneT|服务器分发的库，使其中的定义在当前module（即当前文件）中可用。

  planet requires的完整语法在@secref["require"
          #:doc '(lib "scribblings/reference/reference.scrbl")]中给出，但找到语法示例的最佳位置位于@link["http://planet.racket-lang.org"]{@PLaneT 服务器}上特定package的描述中。
}
))

;; ----------------------------------------

(define-syntax-rule
  (beginner-abbr-forms quote quasiquote unquote unquote-splicing)
  (gen-beginner-abbr-forms #'quote @racket[quote]
                           #'quasiquote @racket[quasiquote]
                           #'unquote @racket[unquote]
                           #'unquote-splicing @racket[unquote-splicing]))

(define (gen-beginner-abbr-forms quote-id quote-elem
                                 quasiquote-id quasiquote-elem
                                 unquote-id unquote-elem
                                 unquote-splicing-id unquote-splicing-elem)

  (list
   @deftogether[(
    @defform/none[(unsyntax @elem{@racketvalfont{'}@racket[name]})]
    @defform/none[(unsyntax @elem{@racketvalfont{'}@racket[part]})]
    @defform[#:id [quote quote-id] (quote name)]
    @defform/none[(#,quote-elem part)]
   )]{

    quote的name就是符号。quote的part是嵌套表的缩写形式。

    通常，这种引用由@litchar{'}写出，例如@racket['(apple
                                      banana)]，但也可以用@quote-elem
    来写，例如@racket[(@#,quote-elem (apple banana))]。}


   @deftogether[(
    @defform/none[(unsyntax @elem{@racketvalfont{`}@racket[name]})]
    @defform/none[(unsyntax @elem{@racketvalfont{`}@racket[part]})]
    @defform[#:id [quasiquote quasiquote-id]
             (quasiquote name)]
    @defform/none[(#,quasiquote-elem part)]
   )]{

    类似于@quote-elem ，但支持``unquote''表示跳出表达式。

    通常，quasiquote由反引号@litchar{`}写出，例如@racket[`(apple
                                        ,(+ 1 2))]，但也可以用@quasiquote-elem
    来写，例如@racket[(#, @quasiquote-elem (apple ,(+ 1 2)))]。}


   @deftogether[(
    @defform/none[(unsyntax @elem{@racketvalfont{,}@racket[expression]})]
    @defform[#:id [unquote unquote-id]
             (unquote expression)]
   )]{

    在单个quasiquote中，@racketfont{,}@racket[expression]跳出quote，将表达式计算的结果插入缩写的表中。

    在多个quasiquote中，@racketfont{,}@racket[expression]只是文本的@racketfont{,}@racket[expression]，@racket[expression]的quasiquote层数将被减一。

    通常，unquote由@litchar{,}写出，但也可以用@|unquote-elem|来写。}


   @deftogether[(
    @defform/none[(unsyntax @elem{@racketvalfont[",@"]@racket[expression]})]
    @defform[#:id [unquote-splicing unquote-splicing-id]
             (unquote-splicing expression)]
   )]{

    在单个quasiquote中，@racketfont[",@"]@racket[expression]跳出quote，表达式计算的结果应当是表，它会被拼接入所写的表中。

    在多个quasiquote中，拼接的unquote就和unquote一样；即，将quasiquote的层数减一。

    通常，拼接的unquote由@litchar{,}写出，单也可以用@|unquote-splicing-elem|来写。}

    ))


(define-syntax-rule
  (intermediate-forms lambda
                      local
                      letrec
                      let*
                      let
                      time
                      define
                      define-struct)
  (gen-intermediate-forms #'lambda @racket[lambda]
                          #'local @racket[local]
                          #'letrec @racket[letrec]
                          #'let* @racket[let*]
                          #'let @racket[let]
                          #'time @racket[time]
                          @racket[define]
                          @racket[define-struct]))

(define (gen-intermediate-forms lambda-id lambda-elem
                                local-id local-elem
                                letrec-id letrec-elem
                                let*-id let*-elem
                                let-id let-elem
                                time-id time-elem
                                define-elem
                                define-struct-elem
                                )
  (list

  @defform[#:id [local local-id]
           (local [definition ...] expression)]{

   将相关的定义组合提供给@racket[expression]使用。单个的@racket[definition]可以是@define-elem
   ，也可以是@|define-struct-elem|。

   计算@local-elem
   时，按顺序计算每个@racket[definition]，最后计算主体中的@racket[expression]。只有@local-elem
   内的表达式（包括@racket[definition]们的右侧、以及@racket[expression]）可以引用@racket[definition]们定义的名称。如果某个@local-elem
   中的定义和另一个全局绑定同名，内层的名称会遮盖掉全局绑定。也就是说，在@local-elem
   内，所用对该名称的引用全都指向内层定义。}

  @; ----------------------------------------------------------------------

  @defform[#:id [letrec letrec-id]
           (letrec ([name expr-for-let] ...) expression)]{

   类似于@local-elem
   ，单语法更简单。每个@racket[name]用对应@racket[expr-for-let]的值定义变量（或函数）。如果@racket[expr-for-let]是@lambda-elem
   ，@letrec-elem 就定义函数，否则就定义变量。}


  @defform[#:id [let* let*-id]
           (let* ([name expr-for-let] ...) expression)]{

   Like @letrec-elem, but each @racket[name] can only be used in
   @racket[expression], and in @racket[expr-for-let]s occuring after
   that @racket[name].}


  @defform[#:id [let let-id]
           (let ([name expr-for-let] ...) expression)]{

   类似于@letrec-elem
   ，但定义的@racket[name]们只能在最后的@racket[expression]中使用，而不能在@racket[name]们右侧的@racket[expr-for-let]们中使用。}

  @; ----------------------------------------------------------------------

  @defform[#:id [time time-id]
            (time expression)]{

   测量计算@racket[expression]所需的时间。完成对@racket[expression]的求值后，@racket[time]会打印出计算所用的时间（包括实际时间、CPU用时以及收集可用内存所花费的时间）。@time-elem
   的值是@racket[expression]的值。}))

;; ----------------------------------------

(define (prim-ops lib ctx-stx)
  (let ([ops (map (lambda (cat)
                    (cons (car cat)
                          (list (cdr cat))))
                  (lookup-documentation lib 'procedures))])
    (make-table
     #f
     (cons
      (list
       (make-flow
        (list
         (make-paragraph
          (list "In function calls, the function appearing immediately after the open parenthesis can be any functions
defined with " (racket define) " or " (racket define-struct) ", or any one of:")))))
      (apply
       append
       (map (lambda (category)
              (cons
               (list (make-flow
                      (list
                       (make-paragraph (list (hspace 1)
                                             (bold (car category)))))))
               (map (lambda (func)
                      (list
                       (make-flow
                        (list
                         (make-proto func ctx-stx)))))
                    (sort-category category))))
            ops))))))


(define (prim-op-defns lib ctx-stx not-in)
  (make-splice
   (let ([ops (map (lambda (cat)
                     (cons (car cat)
                           (list (cdr cat))))
                   (lookup-documentation lib 'procedures))]
         [not-in-ns (map (lambda (not-in-mod)
                           (let ([ns (make-base-namespace)])
                             (parameterize ([current-namespace ns])
                               (namespace-require `(for-label ,not-in-mod)))
                             ns))
                         not-in)])
     (apply
      append
      (map (lambda (category)
             (cons
              (subsection #:tag-prefix (format "~a" lib) (car category))
              (filter values
                      (map
                       (lambda (func)
                         (let ([id (datum->syntax ctx-stx (car func))])
                           (and (not (ormap
                                      (lambda (ns)
                                        (free-label-identifier=?
                                         id
                                         (parameterize ([current-namespace ns])
                                           (namespace-syntax-introduce (datum->syntax #f (car func))))))
                                      not-in-ns))
                                (let ([desc-strs (cddr func)])
                                  (defthing/proc
                                    (if (pair? (cadr func)) "function" "constant")
                                    id
                                    (to-paragraph (typeset-type (cadr func)))
                                    desc-strs)))))
                       (sort-category category)))))
           ops)))))

