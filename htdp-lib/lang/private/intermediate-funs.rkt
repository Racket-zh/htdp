#lang at-exp scheme/base

(require "teachprims.rkt" "and-or-map.rkt"
         lang/posn
         mzlib/etc
         (only-in racket/list argmin argmax)
         syntax/docprovide
         (for-syntax scheme/base))

;; Documents the procedures:
(require "provide-and-scribble.rkt")

(provide-and-scribble
  procedures

  (begin
    (require scribble/manual scribble/eval "sl-eval.rkt")
    (define (isl)
      (define *bsl
        (isl+-eval
	  [(define i 3)
	   (define a-list '(0 1 2 3 4 5 6 7 8 9))
	   (define threshold 3)]))
      (set! isl (lambda () *bsl))
      *bsl))

  (all-from-except beginner:
                   (submod lang/private/beginner-funs without-wrapper)
                   procedures + * / append) 
 
  ("数值（放宽条件）"
    @defproc[(+ [x number] ...) number]{
    将所有输入的数相加。
    在中级或后续语言中：@racket[+]对一个或零个数值也适用。
    @interaction[#:eval (isl) (+ 2/3 1/16) (+ 3 2 5 8) (+ 1) (+)]
    }
    @defproc[(* [x number] ...) number]{
    将所有输入的数相乘。
    在中级或后续语言中：@racket[*]对一个或零个数值也适用。
    @interaction[#:eval (isl) (* 5 3) (* 5 3 2) (* 2) (*)]
    }
    @defproc[(/ [x number] [y number] ...) number]{
    第一个数除以所有后续数。
    在中级或后续语言中：当作用于一个数时，@racket[/]计算倒数。
    @interaction[#:eval (isl) (/ 12 2) (/ 12 2 3) (/ 3)]
    }
    )
  
  ("Posn"
    @defproc[(posn) signature]{posn的签名。})

  ("链表"
    @defproc[((intermediate-append append) [l (listof any)] ...) (listof any)]{
    连接多个表为单个表。
    在中级或后续语言中：@racket[append]对一个或零个表也适用。
    @interaction[#:eval (isl)
		  (append (cons 1 (cons 2 '())) (cons "a" (cons "b" '())))
		  (append)]}
)
 
  ("高阶函数"
    @defproc[((intermediate-map map) [f (X ... -> Z)] [l (listof X)] ...) (listof Z)]{
    将函数作用于（一个或多个）链表中的每个项，创建新的链表：
    @codeblock{(map f (list x-1 ... x-n)) = (list (f x-1) ... (f x-n))}
    @codeblock{(map f (list x-1 ... x-n) (list y-1 ... y-n)) = (list (f x-1 y-1) ... (f x-n y-n))}
    @interaction[#:eval (isl) 
		  (map add1 '(3 -4.01 2/5)) 
		  (map (lambda (x) (list 'my-list (+ x 1))) '(3 -4.01 2/5))
                  (map (lambda (x y) (+ x (* x y))) '(3 -4 2/5) '(1 2 3))]
    }
    @defproc[(for-each [f (any ... -> any)] [l (listof any)] ...) void?]{
    将函数作用于（一个或多个）表中的每个项，仅取效果：
    @codeblock{(for-each f (list x-1 ... x-n)) = (begin (f x-1) ... (f x-n))}
    @interaction[#:eval (asl-eval)
		  (for-each (lambda (x) (begin (display x) (newline))) '(1 2 3))
		  ]
    }
    @defproc[((intermediate-filter filter) [p? (X -> boolean)] [l (listof X)]) (listof X)]{
    用谓词过滤表中的项。
    @interaction[#:eval (isl)
		  (filter odd? '(0 1 2 3 4 5 6 7 8 9))
		  threshold
		  (filter (lambda (x) (>= x threshold)) '(0 1 2 3 4 5 6 7 8 9))
		  ]
    }
    @defproc[((intermediate-foldr foldr) [f (X ... Y -> Y)] [base Y] [l (listof X)] ...) Y]{
    @codeblock{(foldr f base (list x-1 ... x-n)) = (f x-1 ... (f x-n base))}
    @codeblock{(foldr f base (list x-1 ... x-n) (list y-1 ... y-n))
                = (f x-1 y-1 ... (f x-n y-n base))}
    @interaction[#:eval (isl)
                 (foldr + 0 '(0 1 2 3 4 5 6 7 8 9))
                 a-list
                 (foldr (lambda (x r) (if (> x threshold) (cons (* 2 x) r) r)) '() a-list)
                 (foldr (lambda (x y r) (+ x y r)) 0 '(1 2 3) '(10 11 12))
                 ]
    }
    @defproc[((intermediate-foldl foldl) [f (X ... Y -> Y)] [base Y] [l (listof X)] ...) Y]{
    @codeblock{(foldl f base (list x-1 ... x-n)) = (f x-n ... (f x-1 base))}
    @codeblock{(foldl f base (list x-1 ... x-n) (list y-1 ... y-n))
                = (f x-n y-n ... (f x-1 y-1 base))}
    @interaction[#:eval (isl)
		  (foldl + 0 '(0 1 2 3 4 5 6 7 8 9))
		  a-list
		  (foldl (lambda (x r) (if (> x threshold) (cons (* 2 x) r) r)) '() a-list)
                  (foldl (lambda (x y r) (+ x y r)) 0 '(1 2 3) '(10 11 12))
		  ]
    }
    @defproc[(build-list [n nat] [f (nat -> X)]) (listof X)]{
    通过将@racket[f]应用于@racket[0]和@racket[(- n 1)]之间的数来构造链表：
    @codeblock{(build-list n f) = (list (f 0) ... (f (- n 1)))}
    @interaction[#:eval (isl)
		  (build-list 22 add1)
		  i
		  (build-list 3 (lambda (j) (+ j i)))
		  (build-list 5
		    (lambda (i)
		      (build-list 5
			(lambda (j)
			  (if (= i j) 1 0)))))
		  ]
    }
    @defproc[((intermediate-build-string build-string) [n nat] [f (nat -> char)]) string]{
    通过将@racket[f]应用于@racket[0]和@racket[(- n 1)]之间的数来构造字符串：
    @codeblock{(build-string n f) = (string (f 0) ... (f (- n 1)))}
    @interaction[#:eval (isl)
		  (build-string 10 integer->char)
		  (build-string 26 (lambda (x) (integer->char (+ 65 x))))]
    }
    @defproc[((intermediate-quicksort quicksort) [l (listof X)] [comp (X X -> boolean)]) (listof X)]{
    按@racket[comp]的顺序（使用快速排序算法）对l中的项排序。
    @interaction[#:eval (isl)
		  (quicksort '(6 7 2 1 3 4 0 5 9 8) <)]
    }
    @defproc[((intermediate-sort sort) [l (listof X)] [comp (X X -> boolean)]) (listof X)]{
    按@racket[comp]的顺序对l中的项排序。
    @interaction[#:eval (isl)
		  (sort '(6 7 2 1 3 4 0 5 9 8) <)]
    }
    @defproc[((intermediate-andmap andmap) [p? (X ... -> boolean)] [l (listof X) ...]) boolean]{
    判断@racket[p?]是否对@racket[l] ...中所有的项都成立：
    @codeblock{(andmap p (list x-1 ... x-n)) = (and (p x-1) ... (p x-n))}
    @codeblock{(andmap p (list x-1 ... x-n) (list y-1 ... y-n)) = (and (p x-1 y-1) ... (p x-n y-n))}
    @interaction[#:eval (isl)
		  (andmap odd? '(1 3 5 7 9))
		  threshold 
		  (andmap (lambda (x) (< x threshold)) '(0 1 2))
		  (andmap even? '())
                  (andmap (lambda (x f) (f x)) (list 0 1 2) (list odd? even? positive?))
		  ]
    }
    @defproc[((intermediate-ormap ormap)   [p? (X -> boolean)] [l (listof X)]) boolean]{
    判断@racket[p?]是否对@racket[l]中至少一个项成立：
    @codeblock{(ormap p (list x-1 ... x-n)) = (or (p x-1) ... (p x-n))}
    @codeblock{(ormap p (list x-1 ... x-n) (list y-1 ... y-n)) = (or (p x-1 y-1) ... (p x-n y-n))}
    @interaction[#:eval (isl)
		  (ormap odd? '(1 3 5 7 9))
		  threshold 
		  (ormap (lambda (x) (< x threshold)) '(6 7 8 1 5))
		  (ormap even? '())
                  (ormap (lambda (x f) (f x)) (list 0 1 2) (list odd? even? positive?))
		  ]
    }
    @defproc[(argmin [f (X -> real)] [l (listof X)]) X]{
    查找表中的（第一个）元素，该元素使函数的输出最小化。
    @interaction[#:eval (isl)
		  (argmin second '((sam 98) (carl 78) (vincent 93) (asumu 99)))
		  ]
    }
    @defproc[(argmax [f (X -> real)] [l (listof X)]) X]{
    查找表中的（第一个）元素，该元素使函数的输出最大化。
    @interaction[#:eval (isl)
		  (argmax second '((sam 98) (carl 78) (vincent 93) (asumu 99)))
		  ]
    }
    @defproc[(memf [p? (X -> any)] [l (listof X)]) (union #false (listof X))]{
    返回@racket[#false]如果@racket[p?]对@racket[l]中所有的项都返回@racket[#false]。如果@racket[p?]对@racket[l]中任意一个项返回@racket[#true]，@racket[memf]返回从该项开始的子表。
    @interaction[#:eval (isl)
		  (memf odd? '(2 4 6 3 8 0))
		  ]
    } 
    @defproc[(apply [f (X-1 ... X-N -> Y)] [x-1 X-1] ... [l (list X-i+1 ... X-N)]) Y]{
    使用表中的项作为参数调用函数：
    @codeblock{(apply f (list x-1 ... x-n)) = (f x-1 ... x-n)}
    @interaction[#:eval (isl)
		  a-list
		  (apply max a-list)
		  ]
    }
    @defproc[(compose [f (Y -> Z)] [g (X -> Y)]) (X -> Z)]{
    将一系列函数组成一个函数：
    @codeblock{(compose f g) = (lambda (x) (f (g x)))}
    @interaction[#:eval (isl)
		  ((compose add1 second) '(add 3))
		  (map (compose add1 second) '((add 3) (sub 2) (mul 4)))
		  ]
    }
    @defproc[(procedure? [x any]) boolean?]{
    判断值是否是函数。
    @interaction[#:eval (isl)
		  (procedure? cons)
		  (procedure? add1) 
		  (procedure? (lambda (x) (> x 22)))
		  ]
    }
    )
  )
