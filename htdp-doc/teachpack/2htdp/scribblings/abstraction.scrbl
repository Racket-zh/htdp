#lang scribble/doc

@(require "shared.rkt" scribble/manual scribble/eval
          (for-label
	    teachpack/2htdp/abstraction
	    (only-in lang/htdp-beginner require check-expect explode implode)
	    (except-in racket 
              require match
	      for/list for/or for/and for/sum for/product 
	      for*/list for*/or for*/and for*/sum for*/product
	      in-range in-naturals
	      )
	    ))	

@; ---------------------------------------------------------------------------------------------------

@teachpack["abstraction"]{抽象}

@author["Matthias Felleisen" "Racket-zh项目组译"]

@defmodule[#:require-form beginner-require 2htdp/abstraction #:use-sources (teachpack/2htdp/abstraction)]

@tt{abstract.rkt}教学包提供一些额外的抽象工具：解析（comprehension）和循环、匹配及代数数据类型。
其中大多数是其他Racket系列语言中完整功能的受限版本，
因此HtDP/2e（《程序设计方法》第二版）的学生不必纠结于复杂的语法。

HtDP/2e在一独立章节中介绍了循环和匹配，其唯一目的是让学生知悉强大语言机制的存在。

提供代数数据类型的理由是，有些人认为教授函数式编程的特性比教授普遍适用的程序设计思想更重要。

@history[#:added "1.1"]

@;-----------------------------------------------------------------------------
@section[#:tag "abstraction" #:tag-prefix "x"]{循环和解析}

@defform/subs[#:id for/list
              (for/list (comprehension-clause comprehension-clause ...) body-expr)
              ([comprehension-clause (name clause-expr)])]{
 使用@racket[comprehension-clause]们@bold{并行}提供的值的序列计算@racket[body-expr]。

 @racket[comprehension-clause](解析子句)在@racket[body-expr]中绑定它的@racket[name]。

 @racket[for/list]表达式计算所有的@racket[clause-expr]以生成值的序列。
 如果@racket[clause-expr]求值为
@itemlist[
 @item{链表，其项组成序列值；}
 @item{自然数@racket[n]，值的序列由数字@racket[0]、@racket[1]、…、@racket[(- n 1)]组成；}
 @item{字符串，序列的项为其中每个字符构成的字符串。}
]
 对于由@racket[in-range]和@racket[in-naturals]生成的序列，请见下文。

 最后，@racket[for/list]计算@racket[body-expr]，
 其中@racket[name] ...依次绑定到由@racket[clause-expr] ...确定的序列中的值。
@interaction[#:eval (make-base-eval '(require 2htdp/abstraction))
(for/list ((i 10))
  i)

(for/list ((i 2) (j '(a b)))
  (list i j))

(for/list ((c "abc"))
  c)
]

 当最短的序列耗尽时，计算停止。
@interaction[
(for/list ((i 2) (j '(a b c d e)))
  (list i j))
]
}

@defform[#:id for*/list 
         (for*/list (comprehension-clause comprehension-clause ...) body-expr)]{
 使用@bold{嵌套的}@racket[comprehension-clause]们提供的值的序列计算@racket[body-expr]。

 @racket[comprehension-clause]在@racket[body-expr]中，
 以及后续的@racket[comprehension-clause]中绑定它的@racket[name]。

@interaction[
(for*/list ((i 2) (j '(a b)))
  (list i j))

(for*/list ((i 5) (j i))
  (list i j))
]

 由于嵌套，计算@bold{不会}在最短序列耗尽时停止，
 因为@racket[comprehension-clause]们会被按顺序求值：
@interaction[
(for*/list ((i 2) (j '(a b c d e)))
  (list i j))
]
}

@defform[(for/or (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 返回第一个非@racket[#false]值，如果有的话，不然返回@racket[#false]。

@interaction[#:eval (make-base-eval '(require 2htdp/abstraction))
(for/or ([c "abcd"])
   (if (string=? "x" c) c #false))

(for/or ([c (list #false 1 #false 2)])
   c)
]
}

@defform[(for*/or (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for*/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 返回第一个非@racket[#false]值，如果有的话，不然返回@racket[#false]。

@interaction[
(for*/or ([i 2][j i])
   (if (> j i) (list i j) #false))
]
}

@defform[(for/and (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 如果任何一次计算@racket[body-expr]得到@racket[#false]，则循环停止并返回@racket[#false]；
 否则，循环返回最后一次计算@racket[body-expr]的结果。

@interaction[
(for/and ([c '(1 2 3)])
   (if (> c 4) c #false))

(for/and ([c '(1 2 3)])
   (if (< c 4) c #false))
]
}

@defform[(for*/and (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for*/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 如果任何一次计算@racket[body-expr]得到@racket[#false]，则循环停止并返回@racket[#false]；
 否则，循环返回最后一次计算@racket[body-expr]的结果。

@interaction[
(for*/and ([i 2][j i])
   (if (< j i) (list i j) #false))
]
}

@defform[(for/sum (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 将计算@racket[body-expr]所得的数值相加。

@interaction[
(for/sum ([i 2][j 8])
   (max i j))
]
}

@defform[(for*/sum (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for*/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 将计算@racket[body-expr]所得的数值相加。

@interaction[
(for*/sum ([i 2][j i])
   (min i j))
]
}

@defform[(for/product (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 将计算@racket[body-expr]所得的数值相乘。

@interaction[
(for/product ([i 2][j 3])
   (+ i j 1))
]
}

@defform[(for*/product (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for*/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 将计算@racket[body-expr]所得的数值相乘。

@interaction[
(for*/product ([i 2][j i])
   (+ i j 1))
]
}

@defform[(for/string (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 使用@racket[implode]收集@racket[body-expr]求值所得的单字符字符串。

@interaction[
#:eval 
(make-base-eval 
  '(require 2htdp/abstraction 
            (only-in lang/htdp-beginner string->int int->string)))
(for/string ([i "abc"])
   (int->string (+ (string->int i) 1)))
]
}

@defform[(for*/string (comprehension-clause comprehension-clause ...) body-expr)]{
 和@racket[for*/list]一样对@racket[comprehension-clause]生成的序列进行迭代。
 使用@racket[implode]收集@racket[body-expr]求值所得的单字符字符串。

@interaction[
#:eval 
(make-base-eval 
  '(require 2htdp/abstraction 
            (only-in lang/htdp-beginner string->int int->string)))
(for*/string ([i "ab"][j (- (string->int i) 90)])
   (int->string (+ (string->int i) j)))
]
}

@; -------------------------------------------------------
@defproc*[([(in-range [start natural-number/c] 
		      [end natural-number/c]
		      [step natural-number/c]) 
              sequence?]
	   [(in-range [end natural-number/c]) 
	      sequence?])]{
 生成@bold{有限}自然数序列。

 如果提供了@racket[start]、@racket[end]和@racket[step]，
 序列就是@racket[start]、@racket[(+ start step)]、@racket[(+
 start step step)]、…直到总和大于或等于@racket[end]。

@interaction[ 
(for/list ([i (in-range 1 10 3)]) i)
]

 如果只提供了@racket[end]，则@racket[start]默认为@racket[0]，
 @racket[step]默认为@racket[1]：
@interaction[
(for/list ([i (in-range 3)])
  i)

(for/list ([i (in-range 0 3 1)])
  i)
]
 }

@defproc[(in-naturals [start natural-number/c]) sequence?]{
  生成@racket[start]开始的@bold{无限}自然数序列。

@interaction[
#:eval
(make-base-eval)
(define (enumerate a-list)
  (for/list ([x a-list][i (in-naturals 1)])
    (list i x)))

(enumerate '(Maxwell Einstein Planck Heisenberg Feynman))
(enumerate '("Pinot noir" "Pinot gris" "Pinot blanc"))
]
}

@;-----------------------------------------------------------------------------
@section[#:tag "matching" #:tag-prefix "x"]{模式匹配}

@defform/subs[#:id match
              (match case-expr (pattern body-expr) ...)
              ([pattern 
                 name 
	         literal-constant
                 (cons pattern pattern)
                 (name pattern ...)
                 (? name)])]{
 和@racket[cond]一样求值，将@racket[case-expr]的值按顺序与所有@racket[pattern]匹配。
 第一个成功的匹配触发对应@racket[body-expr]的求值，其值即是整个@racket[match]表达式的值。

 常见的文字常量是数字、字符串、符号和@racket['()]。

 每个包含@racket[name]的模式都会在相应的@racket[body-expr]中绑定这些名称。

 值和模式的匹配根据以下规则进行。如果模式是
@itemlist[
@item{@racket[name]，它匹配任何值；}
@item{@racket[literal-constant]，它只匹配本文常量；}
@item{@racket[(cons pattern_1 pattern_2)]，它匹配@racket[cons]实例，
 并且其first/rest字段能和@racket[pattern_1]及@racket[pattern_2]匹配；}
@item{@racket[(name pattern ...)]，它匹配@racket[name]结构体类型的实例，
 并且其字段值能和@racket[pattern] ...匹配；} 
@item{@racket[(? name)]，如果@racket[name]是个谓词函数，并且它对给定的值返回@racket[#true]，
 那么匹配成功。}
]
 此外，如果给定的模式是@racket[name]、值是@racket[V]，
 那么在计算相应的@racket[body-expr]时，@racket[name]代表@racket[V]。
 
以下@racket[match]表达式将@racket[cons]第二个位置的@racket['()]和其他值区分开：
@interaction[#:eval (make-base-eval '(require 2htdp/abstraction))
(define (last-item l)
   (match l 
     [(cons lst '()) lst]
     [(cons fst rst) (last-item rst)]))

(last-item '(a b c))
]

使用@racket[?]，@racket[match]可以用谓词来区分任意值：
@interaction[#:eval (make-base-eval '(require 2htdp/abstraction))
(define (is-it-odd-or-even l)
   (match l 
     [(? even?) 'even]
     [(? odd?)  'odd]))

(is-it-odd-or-even '1)
(is-it-odd-or-even '2)
]

@racket[match]表达式也可以处理结构体实例：
@interaction[#:eval (make-base-eval '(require 2htdp/abstraction))
(define-struct doll (layer))

(define (inside a-doll)
  (match a-doll 
    [(? symbol?) a-doll]
    [(doll below) (inside below)]))

(inside (make-doll (make-doll 'wood)))
]
但请注意，模式仅使用@racket[doll]（结构体类型的名称），
而不是@racket[make-doll]（构造函数名称）。
}


@;-----------------------------------------------------------------------------
@section[#:tag "adt" #:tag-prefix "x"]{代数数据类型}

@defform/subs[#:id define-type
              (define-type type (variant (field predicate) ...) ...)
              ([type name]
	       [variant name]
	       [field name]
	       [predicate name])]{
 定义结构体类型@racket[variant] ...，其中字段为@racket[field] ...。
 此外，它会定义检查字段值满足指定谓词的构造函数。最后，
 它还定义@racket[type]为所有@racket[variant]结构体类型的并集的名称，
 定义@racket[type?]为判断值是否属于此类值的谓词。

考虑以下的类型定义：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
(define-type BTree
  (leaf (info number?))
  (node (left BTree?) (right BTree?)))
))
@;%
 它定义了两种结构体类型：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
(define-struct leaf (info))
(define-struct node (left right))
))
@;%
 当应用于除数值之外的任何其他值时@racket[make-leaf]构造函数会抛出错误，
 而@racket[make-node]仅接受@racket[BTree]的实例。
 最后，@racket[BTree?]是识别这种实例的谓词：
@interaction[#:eval (make-base-eval '(require 2htdp/abstraction) '(define-type BTree (leaf (info number?)) (node (left BTree?) (right BTree?))))
(make-leaf 42)
(make-node (make-leaf 42) (make-leaf 21))
(BTree? (make-node (make-leaf 42) (make-leaf 21)))
]
调用构造函数于错误类型的值时会失败：
@interaction[#:eval (make-base-eval '(require 2htdp/abstraction) '(define-type BTree (leaf (info number?)) (node (left BTree?) (right BTree?))))
(make-leaf 'four)
]
}

@defform[#:id type-case
         (type-case type case-expr (variant (field ...) body-expr) ...)]{
 像@racket[cond]一样求值，将@racket[case-expr]的值按顺序与所有@racket[variant]匹配。
 第一个成功的匹配触发对应@racket[body-expr]的求值，其值是整个类型@racket[type-case]的值。

 @racket[type-case]表达式还确保
 （1）@racket[variant]子句的集合覆盖@racket[type]中的所有变体的结构体类型定义，以及
 （2）每个@racket[variant]子句指定的字段数与@racket[type]定义指定的一样多。

在上述@racket[BTree]类型定义的作用域内：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
(define (depth t)
  (type-case BTree t
    [leaf (info) 0]
    [node (left right) (+ (max (depth left) (depth right)) 1)]))
))
@;%
 这个函数定义使用了@racket[BTree]的@racket[type-case]，其中包含两个子句：
 一个用于@racket[leaf]，一个用于@racket[node]。该函数计算输入树的深度。

@interaction[#:eval 
(make-base-eval 
 '(require 2htdp/abstraction) 
 '(define-type BTree (leaf (info number?)) (node (left BTree?) (right BTree?)))
 '(define (depth t)
    (type-case BTree t
      [leaf (info) 0]
      [node (left right) (+ (max (depth left) (depth right)) 1)])))

(depth (make-leaf 42))
(depth (make-node (make-leaf 42) (make-leaf 21)))
]
}
