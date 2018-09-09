#lang at-exp racket

;; weed out: string-copy, eqv?, struct? -- no need for beginners, move to advanced
;; eq? is questionable, but okay if someone uses BSL to teach not out of HtDP
;;

(require mzlib/etc mzlib/list mzlib/math syntax/docprovide
         (for-syntax "firstorder.rkt")
         (for-syntax syntax/parse)
         (for-syntax racket/syntax))

;; Implements the procedures:
(require "teachprims.rkt" "teach.rkt" lang/posn lang/imageeq "provide-and-scribble.rkt")

(define-syntax (provide-and-wrap stx)
  (syntax-parse stx
    ; (defproc (name args ...) range w ...)
    [(provide-and-wrap wrap doc-tag:id requires (title df ...) ...)
     (let* ((defs (map syntax->list (syntax->list #'((df ...) ...))))
            (names (map extract-names defs))
            (tmps  (map generate-temporaries names))
            (internals (map (lambda (x)
                              (map (lambda (n)
                                     (syntax-parse n
                                       [(internal-name:id external-name:id) #'internal-name]
                                       [n:id #'n]))
                                   x))
                            names))
            (externals (map (lambda (x)
                              (map (lambda (n)
                                     (syntax-parse n
                                       [(internal-name:id external-name:id) #'external-name]
                                       [n:id #'n]))
                                   x))
                            names)))
       (with-syntax* ([((f ...) ...) tmps]
                      [((internal-name ...) ...) internals]
                      [((dg ...) ...)
                       (map (lambda (d.. f.. ex..)
                              (map (lambda (d f external-name)
                                     (syntax-case d ()
                                       [(defproc [name args ...] range w ...)
                                        #`(defproc [(#,f #,external-name) args ...] range w ...)]
                                       [(defthing name range w ...)
                                        #'(defthing name range w ...)]))
                                   d.. f.. ex..))
                            defs tmps externals)])
         #'(begin ;; create two modules:
             ;; one that makes definitions first-order
             (module+ with-wrapper
               (wrap f internal-name) ... ...
               (provide-and-scribble doc-tag requires (title dg ...) ...))
             ;; and one that doesn't
             (module+ without-wrapper
               (provide-and-scribble doc-tag requires (title df ...) ...)))))]))

;; MF: this is now an ugly kludge, left over from my original conversion of Matthew's docs for *SL
(define-syntax (in-rator-position-only stx)
  (syntax-case stx ()
    [(_ new-name orig-name)
     (let ([new (syntax new-name)]
           [orig (syntax orig-name)])
       (cond
         ;; Some things are not really functions:
         [(memq (syntax-e orig) '(pi e null eof))
          #'(define new-name orig-name)]
         [else
          #'(define-syntax new-name
              (make-first-order
               (lambda (stx)
                 (syntax-case stx ()
                   [(id . args) (syntax/loc stx (beginner-app orig-name . args))]
                   [_else
                    (raise-syntax-error
                     #f
                     "expected a function call, but there is no open parenthesis before this function"
                     stx)]))
               #'orig-name))]))]))

;; procedures with documentation:
(provide-and-wrap
 in-rator-position-only
 procedures

 (begin
   (require scribble/manual scribble/eval "sl-eval.rkt")
   (define (bsl)
     (define *bsl
       (bsl+-eval
        [
 (define c1 (circle 10 "solid" "green"))

 (define zero 0)

 (define one (list 1))

 (define q (make-posn "bye" 2))
 (define p (make-posn 2 -3))

 (define a (list (list 'a 22) (list 'b 8) (list 'c 70)))
 (define v (list 1 2 3 4 5 6 7 8 9 'A))
 (define w (list (list (list (list "bye") 3) #true) 42))
 (define z (list (list (list (list 'a 'b) 2 3) ) (list #false #true) "world"))
 (define y (list (list (list 1 2 3) #false "world")))
 (define x (list 2 "hello" #true))
 (define hello-2 (list 2 "hello" #true "hello"))]))
     (set! bsl (lambda () *bsl))
     *bsl))

 ("数值：整数、有理数、实数、复数、精确数、非精确数"
  @defproc[(number? [n any/c]) boolean?]{
 确定某个值是否为数值：
 @interaction[#:eval (bsl) (number? "hello world") (number? 42)]
}
  @defproc[(= [x number][y number][z number] ...) boolean?]{
 比较数值相等。
 @interaction[#:eval (bsl) (= 42 2/5)]
}
  @defproc[(< [x real][y real][z real] ...) boolean?]{
 比较（实）数小于。
 @interaction[#:eval (bsl) (< 42 2/5)]
}
  @defproc[(> [x real][y real][z real] ...) boolean?]{
 比较（实）数大于。
 @interaction[#:eval (bsl) (> 42 2/5)]
}
  @defproc[(<= [x real][y real][z real] ...) boolean?]{
 比较（实）数小于等于。
 @interaction[#:eval (bsl) (<= 42 2/5)]
}
  @defproc[(>= [x real][y real][z real] ...) boolean?]{
 比较（实）数大于等于。
 @interaction[#:eval (bsl) (>= 42 42)]
}
  @defproc[((beginner-+ +) [x number][y number][z number] ...) number]{
 @index["plus"]{}将所有数值相@index["add"]{加}。
 @interaction[#:eval (bsl) (+ 2/3 1/16) (+ 3 2 5 8)]
}
  @defproc[(- [x number][y number] ...) number]{
 从第一个数值中@index["subtract"]{减}去第二个（和后续）数值；如果只有一个参数，则对数值取相反数。
 @interaction[#:eval (bsl) (- 5) (- 5 3) (- 5 3 1)]
}
  @defproc[((beginner-* *) [x number][y number][z number] ...) number]{
 @index["times"]{}@index["product"]{}将所有数值相@index["multiply"]{乘}。
 @interaction[#:eval (bsl) (* 5 3) (* 5 3 2)]
}
  @defproc[((beginner-/ /) [x number][y number][z number] ...) number]{
 第一个数值@index["divide"]{除以}第二个（和后续）数值。
 @interaction[#:eval (bsl) (/ 12 2) (/ 12 2 3)]
}
  @defproc[(max [x real][y real] ...) real]{
 求@index["maximum"]{最大值}。
 @interaction[#:eval (bsl) (max 3 2 8 7 2 9 0)]
}
  @defproc[(min [x real][y real] ...) real]{
 求@index["minimum"]{最小值}。
 @interaction[#:eval (bsl) (min 3 2 8 7 2 9 0)]
}
  @defproc[(quotient [x integer][y integer]) integer]{
 将第一个整数（被除数）除以第二个整数（除数）来获得商@index[(list "divide" "quotient")]{商}。
 @interaction[#:eval (bsl) (quotient 9 2) (quotient 3 4)]
}
  @defproc[(remainder [x integer][y integer]) integer]{
 确定将第一个除以第二个整数（精确或不精确）的@index[(list "divide" "remainder")]{余数}。
 @interaction[#:eval (bsl) (remainder 9 2) (remainder 3 4)]
}
  @defproc[(modulo [x integer][y integer]) integer]{
 求第一个数字除以第二个数字的余数：
 @interaction[#:eval (bsl) (modulo 9 2) (modulo 3 -4)]
}
  @defproc[((beginner-sqr sqr) [x number]) number]{
 计算一个数的@index["square"]{平方}。
 @interaction[#:eval (bsl) (sqr 8)]
}
  @defproc[(sqrt [x number]) number]{
 计算一个数的平方根。
 @interaction[#:eval (bsl) (sqrt 9) (sqrt 2)]
}
  @defproc[(integer-sqrt [x integer]) complex]{
 计算一个整数的整数或虚整数平方根。
 @interaction[#:eval (bsl) (integer-sqrt 11) (integer-sqrt -11)]
}
  @defproc[(abs [x real]) real]{
 求实数的绝对值。
 @interaction[#:eval (bsl) (abs -12)]
}
  @defproc[(sgn [x real]) (union 1 #i1.0 0 #i0.0 -1 #i-1.0)]{
 求实数的符号。
 @interaction[#:eval (bsl) (sgn -12)]
}

  ;; exponents and logarithms
  @defproc[(expt [x number][y number]) number]{
 计算第一个数的第二个数次幂。
 @interaction[#:eval (bsl) (expt 16 1/2) (expt 3 -4)]
}
  @defproc[(exp [x number]) number]{
 求e的指数。
 @interaction[#:eval (bsl) (exp -2)]
}
  @defproc[(log [x number]) number]{
 求一个数（以e为底）的对数。
 @interaction[#:eval (bsl) (log 12)]
}

  ;; trigonometry
  @defproc[(sin [x number]) number]{
 计算数的@index["sine"]{正弦}值（弧度）。
 @interaction[#:eval (bsl) (sin pi)]
}
  @defproc[(cos [x number]) number]{
 计算数的@index["cosine"]{余弦}值（弧度）。
 @interaction[#:eval (bsl) (cos pi)]
}
  @defproc[(tan [x number]) number]{
 计算数的@index["tangent"]{正切}值（弧度）。
 @interaction[#:eval (bsl) (tan pi)]
}
  @defproc[(asin [x number]) number]{
 计算数的反正弦（正弦的倒数）。
 @interaction[#:eval (bsl) (asin 0)]
}
  @defproc[(acos [x number]) number]{
 计算数的反余弦（余弦的倒数）。
 @interaction[#:eval (bsl) (acos 0)]
}
  @defproc[(atan [x number]) number]{
 计算给定数的反正切值：
 @interaction[#:eval (bsl) (atan 0) (atan 0.5)]

 它还有一个双参数版本，@racket[(atan x y)]计算@racket[(atan (/ x y))]，不过x和y的符号确定结果的象限，在边界情况下结果往往比单参数版本更精确：
 @interaction[#:eval (bsl) (atan 3 4) (atan -2 -1)]
}
  @defproc[(sinh [x number]) number]{
 计算数的双曲正弦。
 @interaction[#:eval (bsl) (sinh 10)]
}
  @defproc[(cosh [x number]) number]{
 计算数的双曲余弦。
 @interaction[#:eval (bsl) (cosh 10)]
}

  ;; predicates
  @defproc[(exact? [x number]) boolean?]{
 判断某个数值是否精确。
 @interaction[#:eval (bsl) (exact? (sqrt 2))]
}
  @defproc[(integer? [x any/c]) boolean?]{
 判断某个值是否为整数（精确或不精确）。
 @interaction[#:eval (bsl) (integer? (sqrt 2))]
}
  @defproc[(zero? [x number]) boolean?]{
 判断某个数值是否为零。
 @interaction[#:eval (bsl) (zero? 2)]
}
  @defproc[(positive? [x real]) boolean?]{
 判断某个实数是否严格大于零。
 @interaction[#:eval (bsl) (positive? -2)]
}
  @defproc[(negative? [x real]) boolean?]{
 判断某个实数是否严格小于零。
 @interaction[#:eval (bsl) (negative? -2)]
}
  @defproc[(odd? [x integer]) boolean?]{
 判断某个整数（精确或不精确）是否为奇数。
 @interaction[#:eval (bsl) (odd? 2)]
}
  @defproc[(even? [x integer]) boolean?]{
 判断某个整数（精确或不精确）是否为偶数。
 @interaction[#:eval (bsl) (even? 2)]
}
  @defproc[(rational? [x any/c]) boolean?]{
 判断某个值是否为有理数。
 @interaction[#:eval (bsl)
              (rational? 1)
              (rational? -2.349)
              (rational? #i1.23456789)
              (rational? (sqrt -1))
              (rational? pi)
              (rational? e)
              (rational? 1-2i)]
 正如交互所表明的那样，教学语言将很多数值视为有理数。特别地，@racket[pi]是一个有理数，因为它只是对数学中π的有限近似。将@racket[rational?]理解为建议将这些数视为分数。
}
  @defproc[(inexact? [x number]) boolean?]{
 判断某个数值是否不精确。
 @interaction[#:eval (bsl) (inexact? 1-2i)]
}
  @defproc[(real? [x any/c]) boolean?]{
 判断某个值是否是实数。
 @interaction[#:eval (bsl) (real? 1-2i)]
}
  @defproc[(complex? [x any/c]) boolean?]{
 判断某个值是否是复数。
 @interaction[#:eval (bsl) (complex? 1-2i)]
}

  ;; common utilities
  @defproc[(add1 [x number]) number]{
 将给定的数值加一。
 @interaction[#:eval (bsl) (add1 2)]
}
  @defproc[(sub1 [x number]) number]{
 将给定的数值减一。
 @interaction[#:eval (bsl) (sub1 2)]
}
  @defproc[(lcm [x integer][y integer] ...) integer]{
 确定两个整数（精确或不精确）的最小公倍数。
 @interaction[#:eval (bsl) (lcm 6 12 8)]
}
  @defproc[(gcd [x integer][y integer] ...) integer]{
 确定两个整数（精确或不精确）的最大公约数。
 @interaction[#:eval (bsl) (gcd 6 12 8)]
}
  @defproc[(numerator [x rational?]) integer]{
 计算有理数的分子。
 @interaction[#:eval (bsl) (numerator 2/3)]
}
  @defproc[(denominator [x rational?]) integer]{
 计算有理数的分母。
 @interaction[#:eval (bsl) (denominator 2/3)]
}
  @defproc[(floor [x real]) integer]{
 求小于某个实数的最接近整数（精确或不精确）。参见@racket[round]。
 @interaction[#:eval (bsl) (floor 12.3)]
}
  @defproc[(ceiling [x real]) integer]{
 求大于某个实数的最接近整数（精确或不精确）。参见@racket[round]。
 @interaction[#:eval (bsl) (ceiling 12.3)]
}
  @defproc[(round [x real]) integer]{
 将实数舍入为整数（如果到两个数距离一样，舍入到偶数）。参见@racket[floor]和@racket[ceiling]。
 @interaction[#:eval (bsl) (round 12.3)]
}
  @defproc[(make-polar [x real ][y real]) number]{
 由绝对值和幅角创建复数。
 @interaction[#:eval (bsl) (make-polar 3 4)]
}
  @defproc[(make-rectangular [x real][y real]) number]{
 由实部和虚部创建复数。
 @interaction[#:eval (bsl) (make-rectangular 3 4)]
}
  @defproc[(real-part [x number]) real]{
 从复数中提取实部。
 @interaction[#:eval (bsl) (real-part 3+4i)]
}
  @defproc[(imag-part [x number]) real]{
 从复数中提取虚部。
 @interaction[#:eval (bsl) (imag-part 3+4i)]
}
  @defproc[(magnitude [x number]) real]{
 求复数的绝对值。
 @interaction[#:eval (bsl) (magnitude (make-polar 3 4))]
}
  @defproc[(angle [x number]) real]{
 从复数中提取幅角。
 @interaction[#:eval (bsl) (angle (make-polar 3 4))]
}
  @defproc[(conjugate [x number]) number]{
 翻转复数虚部的符号（共轭复数）。
 @interaction[#:eval (bsl)
              (conjugate 3+4i)
              (conjugate -2-5i)
              (conjugate (make-polar 3 4))
              ]
}
  @defproc[(exact->inexact [x number]) number]{
 将精确数转换为不精确数。
 @interaction[#:eval (bsl) (exact->inexact 12)]
}
  @defproc[(inexact->exact [x number]) number]{
 将不精确数转换为近似的精确数。
 @interaction[#:eval (bsl) (inexact->exact #i12)]
}
  @defproc[(number->string [x number]) string]{
 将数值转换为字符串。
 @interaction[#:eval (bsl) (number->string 42)]
}
  @defproc[(integer->char [x exact-integer?]) char]{
 在ASCII表中查找输入精确整数所对应的字符（如果存在的话）。
 @interaction[#:eval (bsl) (integer->char 42)]
}
  @defproc[((beginner-random random) [x natural]) natural]{
 生成小于输入精确自然数的随机自然数。
 @interaction[#:eval (bsl) (random 42)]
}
  @defproc[(current-seconds) integer]{
 确定当前时间，由（自平台特定的开始日期起）已经过的秒数形式给出。
 @interaction[#:eval (bsl) (current-seconds)]
}
  @defthing[e real]{欧拉数。
 @interaction[#:eval (bsl) e]
}
  @defthing[pi real]{圆的周长与其直径的比率。
 @interaction[#:eval (bsl) pi]
 })

 ("布尔值"
  @defproc[(boolean? [x any/c]) boolean?]{
 判断某个值是否为布尔值。
 @interaction[#:eval (bsl) (boolean? 42) (boolean? #false)]
}
  @defproc[(boolean=? [x boolean?][y boolean?]) boolean?]{
 判断两个布尔值是否相等。
 @interaction[#:eval (bsl) (boolean=? #true #false)]
}
  @defproc[(false? [x any/c]) boolean?]{
 判断值是否为false。
 @interaction[#:eval (bsl) (false? #false)]
}
  @defproc[((beginner-not not) [x boolean?]) boolean?]{
 对布尔值取反。
 @interaction[#:eval (bsl) (not #false)]
 }
   @defproc[((beginner-boolean->string boolean->string) [x boolean?]) string]{
 将布尔值转换为字符串。
 @interaction[#:eval (bsl) (boolean->string #false) (boolean->string #true)]
 })

 ("符号"
  @defproc[(symbol? [x any/c]) boolean?]{
 判断某个值是否为符号。
 @interaction[#:eval (bsl) (symbol? 'a)]
}
  @defproc[(symbol=? [x symbol][y symbol]) boolean?]{
 判断两个符号是否相等。
 @interaction[#:eval (bsl) (symbol=? 'a 'b)]
}
  @defproc[(symbol->string [x symbol]) string]{
 将符号转换为字符串。
 @interaction[#:eval (bsl) (symbol->string 'c)]
 })

 ("链表"
  @defproc[(cons? [x any/c]) boolean?]{
 判断某个值是否为cons构造的表。
 @interaction[#:eval (bsl-eval) (cons? (cons 1 '())) (cons? 42)]
}
  @defproc[(empty? [x any/c]) boolean?]{
 判断某个值是否为空表。
 @interaction[#:eval (bsl) (empty? '()) (empty? 42)]
}
  @defproc[((beginner-cons cons) [x any/x][y list?]) list?]{
 构造链表。
 @interaction[#:eval (bsl-eval) (cons 1 '())]
}
  @defproc[((beginner-first first) [x cons?]) any/c]{
 提取非空表的第一项。
 @interaction[#:eval (bsl) x (first x)]
}
  @defproc[((beginner-rest rest) [x cons?]) any/c]{
 提取非空表的其余项。
 @interaction[#:eval (bsl) x (rest x)]
}
  @defproc[(second [x list?]) any/c]{
 提取非空表的第二项。
 @interaction[#:eval (bsl) x (second x)]
}
  @defproc[(third [x list?]) any/c]{
 提取非空表的第三项。
 @interaction[#:eval (bsl) x (third x)]
}

  @defproc[(fourth [x list?]) any/c]{
 提取非空表的第四项。
 @interaction[#:eval (bsl) v (fourth v)]
}

  @defproc[(fifth [x list?]) any/c]{
 提取非空表的第五项。
 @interaction[#:eval (bsl) v (fifth v)]
}
  @defproc[(sixth [x list?]) any/c]{
 提取非空表的第六项。
 @interaction[#:eval (bsl) v (sixth v)]
}
  @defproc[(seventh [x list?]) any/c]{
 提取非空表的第七项。
 @interaction[#:eval (bsl) v (seventh v)]
}
  @defproc[(eighth [x list?]) any/c]{
 提取非空表的第八项。
 @interaction[#:eval (bsl) v (eighth v)]
}
  @defproc[(list-ref [x list?][i natural?]) any/c]{
 提取表的索引项。
 @interaction[#:eval (bsl) v (list-ref v 9)]
}
  @defproc[(list [x any/c] ... ) list?]{
 用参数构造表。
 @interaction[#:eval (bsl-eval) (list 1 2 3 4 5 6 7 8 9 0)]
}
  @defproc[(make-list [i natural-number] [x any/c]) list?]{
 创建@racket[i]个@racket[x]的链表.
 @interaction[#:eval (bsl-eval) (make-list 3 "hello")]
}
  @defproc[((beginner-list* list*) [x any/c]  ... [l list?]) list?]{
 通过将多个项添加到表中构造链表。
 @interaction[#:eval (bsl) x (list* 4 3 x)]
}
  @defproc[((beginner-range range) [start number][end number][step number]) list?]{
 通过从@racket[start]每步走过@racket[step]到@racket[end]构造表。
 @interaction[#:eval (bsl-eval) (range 0 10 2)]
}
  @defproc[((beginner-append append) [x list?][y list?][z list?]  ...) list?]{
 连接多个表中的项创建单个链表。
 @interaction[#:eval (bsl) (append (cons 1 (cons 2 '())) (cons "a" (cons "b" empty)))]
}
  @defproc[(length (l list?)) natural-number?]{
 计算表中的项的数量。
 @interaction[#:eval (bsl) x (length x)]
}
  @defproc[((beginner-memq memq) [x any/c][l list?]) boolean?]{
 判断某个值@racket[x]是否在某个表@racket[l]中，使用@racket[eq?]比较@racket[x]与@racket[l]中的项。
 @interaction[#:eval (bsl) x (memq (list (list 1 2 3)) x)]
}
  @defproc[((beginner-memq? memq?) [x any/c][l list?]) boolean?]{
 判断某个值@racket[x]是否在某个表@racket[l]中，使用@racket[eq?]比较@racket[x]与@racket[l]中的项。
 @interaction[#:eval (bsl) x (memq? (list (list 1 2 3)) x)]
}
  @defproc[(memv [x any/c][l list?]) (or/c #false list)]{
 判断某个值是否在表中，如果是的话，返回以x开头表的后半部分。（使用eqv?谓词比较值。）
 @interaction[#:eval (bsl) x (memv (list (list 1 2 3)) x)]
}
  @defproc[((beginner-member? member?) [x any/c][l list?]) boolean?]{
 判断某个值是否在表中（使用equal?进行比较）。
 @interaction[#:eval (bsl) x (member? "hello" x)]
}
  @defproc[((beginner-member member) [x any/c][l list?]) boolean?]{
 判断某个值是否在表中（使用equal?进行比较）。
 @interaction[#:eval (bsl) x (member "hello" x)]
}
  @defproc[((beginner-remove remove) [x any/c][l list?]) list?]{
 构造类似输入表的表，删除第一个匹配输入项的项（使用equal?进行比较）。
 @interaction[#:eval (bsl) x (remove "hello" x) hello-2 (remove "hello" hello-2)]
}
  @defproc[((beginner-remove-all remove-all) [x any/c][l list?]) list?]{
 构造类似输入表的表，删除输入项的所有出现（使用equal?进行比较）。
 @interaction[#:eval (bsl) x (remove-all "hello" x) hello-2 (remove-all "hello" hello-2)]
}
  @defproc[(reverse [l list?]) list]{
 创建链表的反转版本。
 @interaction[#:eval (bsl) x (reverse x)]
}
  @defproc[(assq [x any/c][l list?]) (union #false cons?)]{
 判断某个项是否是表中某个序对的第一项。（使用@racket[eq?]进行比较。）
 @interaction[#:eval (bsl) a (assq 'b a)]
}


  ;; LISP-ish selectors:
  @defproc[(null? [x any/c]) boolean?]{
 判断某个值是否为空表。
 @interaction[#:eval (bsl) (null? '()) (null? 42)]
}
  @defthing[null list]{空表的另一个名称
 @interaction[#:eval (bsl) null]
}
  @defproc[((beginner-car car) [x cons?]) any/c]{
 提取非空表的第一项。
 @interaction[#:eval (bsl) x (car x)]
}
  @defproc[((beginner-cdr cdr) [x cons?]) any/c]{
 提取非空表的其余项。
 @interaction[#:eval (bsl) x (cdr x)]
}
  @defproc[(cadr [x list?]) any/c]{
 LISP式的选择函数：@racket[(car (cdr x))].
 @interaction[#:eval (bsl) x (cadr x)]
}
  @defproc[(cdar [x list?]) list?]{
 LISP式的选择函数：@racket[(cdr (car x))].
 @interaction[#:eval (bsl) y (cdar y)]
}
  @defproc[(caar [x list?]) any/c]{
 LISP式的选择函数：@racket[(car (car x))].
 @interaction[#:eval (bsl) y (caar y)]
}
  @defproc[(cddr [x list?]) list? ]{
 LISP式的选择函数：@racket[(cdr (cdr x))].
 @interaction[#:eval (bsl) x (cddr x)]
}
  @defproc[(caddr [x list?]) any/c]{
 LISP式的选择函数：@racket[(car (cdr (cdr x)))].
 @interaction[#:eval (bsl) x (caddr x)]
}
  @defproc[(caadr [x list?]) any/c]{
 LISP式的选择函数：@racket[(car (car (cdr x)))].
 @interaction[#:eval (bsl) (caadr (cons 1 (cons (cons 'a '()) (cons (cons 'd '()) '()))))]
}
  @defproc[(caaar [x list?]) any/c]{
 LISP式的选择函数：@racket[(car (car (car (car x))))].
 @interaction[#:eval (bsl) w (caaar w)]
}
  @defproc[(cdaar [x list?]) any/c]{
 LISP式的选择函数：@racket[(cdr (car (car x)))].
 @interaction[#:eval (bsl) w (cdaar w)]
}
  @defproc[(cdadr [x list?]) any/c]{
 LISP式的选择函数：@racket[(cdr (car (cdr x)))].
 @interaction[#:eval (bsl) (cdadr (list 1 (list 2 "a") 3))]
}
  @defproc[(cadar [x list?]) any/c]{
 LISP式的选择函数：@racket[(car (cdr (car x)))].
 @interaction[#:eval (bsl) w (cadar w)]
}
  @defproc[(cddar [x list?]) any/c]{
 LISP式的选择函数：@racket[(cdr (cdr (car x)))]
 @interaction[#:eval (bsl) w (cddar w)]
}
  @defproc[(cdddr [x list?]) any/c]{
 LISP式的选择函数：@racket[(cdr (cdr (cdr x)))].
 @interaction[#:eval (bsl) v (cdddr v)]
}
  @defproc[(cadddr [x list?]) any/c]{
 LISP式的选择函数：@racket[(car (cdr (cdr (cdr x))))].
 @interaction[#:eval (bsl) v (cadddr v)]
}
  @defproc[(assoc [x any] [l (listof any)]) (union (listof any) #false)]{
 返回@racket[l]中第一个@racket[first]项@racket[equal?]于@racket[x]的序对；如果不存在这样的序对就返回@racket[#false]。
 @interaction[#:eval (bsl) (assoc "hello" '(("world" 2) ("hello" 3) ("good" 0)))]
}

  @defproc[((beginner-list? list?) [x any]) boolean?]{
 检查给定值是否为链表。
 @interaction[#:eval (bsl)
              (list? 42)
              (list? '())
              (list? (cons 1 (cons 2 '())))]}
  )

 ("Posn"
  ; @defproc[(posn) signature]{Signature for posns.}
  @defproc[(make-posn [x any/c][y any/c]) posn]{
 用任意两个值构造posn。
 @interaction[#:eval (bsl) (make-posn 3 3) (make-posn "hello" #true)]
}
  @defproc[(posn? [x any/c]) boolean?]{
 判断输入是否是posn。
 @interaction[#:eval (bsl) q (posn? q) (posn? 42)]
}
  @defproc[(posn-x [p posn]) any]{
 提取posn的x分量。
 @interaction[#:eval (bsl) p (posn-x p)]
}
  @defproc[(posn-y [p posn]) any]{
 提取posn的y分量。
 @interaction[#:eval (bsl) p (posn-y p)]
 })

 ("字符"
  @defproc[(char? [x any/c]) boolean?]{
 判断值是否为字符。
 @interaction[#:eval (bsl) (char? "a") (char? #\a)]
}
  @defproc[(char=? [c char][d char][e char] ...) boolean?]{
 判断字符是否相等。
 @interaction[#:eval (bsl) (char=? #\b #\a)]
}
  @defproc[(char<? [x char][d char][e char] ...) boolean?]{
 判断字符是否按严格增加的顺序排列。
 @interaction[#:eval (bsl) (char<? #\a #\b #\c)]
}
  @defproc[(char>? [c char][d char][e char] ...) boolean?]{
 判断字符是否按严格减少的顺序排列。
 @interaction[#:eval (bsl) (char>? #\A #\z #\a)]
}
  @defproc[(char<=? [c char][d char][e char] ...) boolean?]{
 判断字符是否按增加的顺序排列。
 @interaction[#:eval (bsl) (char<=? #\a #\a #\b)]
}
  @defproc[(char>=? [c char][d char][e char] ...) boolean?]{
 判断字符是否按减少的顺序排列。
 @interaction[#:eval (bsl) (char>=? #\b #\b #\a)]
}
  @defproc[(char-ci=? [c char][d char][e char] ...) boolean?]{
 判断两个字符是否以不区分大小写的方式相等。
 @interaction[#:eval (bsl) (char-ci=? #\b #\B)]
}
  @defproc[(char-ci<? [c char][d char][e char] ...) boolean?]{
 判断字符是否以不区分大小写的方式按严格增加的顺序排列。
 @interaction[#:eval (bsl) (char-ci<? #\B #\c) (char<? #\b #\B)]
}
  @defproc[(char-ci>? [c char][d char][e char] ...) boolean?]{
 判断字符是否以不区分大小写的方式按严格减少的顺序排列。
 @interaction[#:eval (bsl) (char-ci>? #\b #\B) (char>? #\b #\B)]
}
  @defproc[(char-ci<=? [c char][d char][e char] ...) boolean?]{
 判断字符是否以不区分大小写的方式按增加的顺序排列。
 @interaction[#:eval (bsl) (char-ci<=? #\b #\B) (char<=? #\b #\B)]
}
  @defproc[(char-ci>=? [c char][d char][e char] ...) boolean?]{
 判断字符是否以不区分大小写的方式按减少的顺序排列。
 @interaction[#:eval (bsl) (char-ci>=? #\b #\C) (char>=? #\b #\C)]
}
  @defproc[(char-numeric? [c char]) boolean?]{
 判断字符是否表示数字。
 @interaction[#:eval (bsl) (char-numeric? #\9)]
}
  @defproc[(char-alphabetic? [c char]) boolean?]{
 判断字符是否表示字母。
 @interaction[#:eval (bsl) (char-alphabetic? #\Q)]
}
  @defproc[(char-whitespace? [c char]) boolean?]{
 判断字符是否表示空格。
 @interaction[#:eval (bsl) (char-whitespace? #\tab)]
}
  @defproc[(char-upper-case? [c char]) boolean?]{
 判断字符是否是大写的。
 @interaction[#:eval (bsl) (char-upper-case? #\T)]
}
  @defproc[(char-lower-case? [c char]) boolean?]{
 判断字符是否是小写的。
 @interaction[#:eval (bsl) (char-lower-case? #\T)]
}
  @defproc[(char-upcase [c char]) char]{
 生成对应的大写字符。
 @interaction[#:eval (bsl) (char-upcase #\t)]
}
  @defproc[(char-downcase [c char]) char]{
 生成对应的小写字符。
 @interaction[#:eval (bsl) (char-downcase #\T)]
}
  @defproc[(char->integer [c char]) integer]{
 查找ASCII表中输入字符所对应的数值（如果有的话）。
 @interaction[#:eval (bsl) (char->integer #\a) (char->integer #\z)]
 })

 ("字符串"
  @defproc[(string? [x any/c]) boolean?]{
 判断值是否为字符串。
 @interaction[#:eval (bsl) (string? "hello world") (string? 42)]
}
  @defproc[(string-length [s string]) nat]{
 计算字符串的长度。
 @interaction[#:eval (bsl) (string-length "hello world")]
}
  @defproc[((beginner-string-ith string-ith) [s string][i natural-number]) 1string?]{
 提取@racket[s]中的第@racket[i]个字符。
 @interaction[#:eval (bsl) (string-ith "hello world" 1)]
}
  @defproc[((beginner-replicate replicate) [i natural-number][s string]) string]{
 重复@racket[s] @racket[i]次。
 @interaction[#:eval (bsl) (replicate 3 "h")]
}
  @defproc[((beginner-int->string int->string) [i integer]) string]{
 将[0,55295]或[57344,1114111]中的整数转换为单个字母的字符串。
 @interaction[#:eval (bsl) (int->string 65)]
}
  @defproc[((beginner-string->int string->int) [s string]) integer]{
 将单个字母的字符串转换为[0,55295]或[57344,1114111]中的整数。
 @interaction[#:eval (bsl) (string->int "a")]
}
  @defproc[((beginner-explode explode) [s string]) (listof string)]{
 将字符串转换为单字母字符串的表。
 @interaction[#:eval (bsl) (explode "cat")]
}
  @defproc[((beginner-implode implode) [l list?]) string]{
 将单字母字符串的表连接成一个字符串。
 @interaction[#:eval (bsl) (implode (cons "c" (cons "a" (cons "t" '()))))]
}
  @defproc[((beginner-string-numeric? string-numeric?) [s string]) boolean?]{
 判断字符串中的所有“字母”是否都是数字。
 @interaction[#:eval (bsl) (string-numeric? "123") (string-numeric? "1-2i")]
}
  @defproc[((beginner-string-alphabetic? string-alphabetic?) [s string]) boolean?]{
 判断字符串中的所有“字母”是否都是字母。
 @interaction[#:eval (bsl) (string-alphabetic? "123") (string-alphabetic? "cat")]
}
  @defproc[((beginner-string-whitespace? string-whitespace?) [s string]) boolean?]{
 判断字符串中的所有“字母”是否都是空格。
 @interaction[#:eval (bsl) (string-whitespace? (string-append " " (string #\tab #\newline #\return)))]
}
  @defproc[((beginner-string-upper-case? string-upper-case?) [s string]) boolean?]{
 判断字符串中的所有“字母”是否都是大写。
 @interaction[#:eval (bsl) (string-upper-case? "CAT")]
}
  @defproc[((beginner-string-lower-case? string-lower-case?) [s string]) boolean?]{
 判断字符串中的所有“字母”是否都是小写。
 @interaction[#:eval (bsl) (string-lower-case? "CAT")]
}
  @defproc[((beginner-string-contains? string-contains?) [s string] [t string]) boolean?]{
 判断第一个字符串是否出现在第二个字符串中。
 @interaction[#:eval (bsl) (string-contains? "at" "cat")]
}
  @defproc[((beginner-string-contains-ci? string-contains-ci?) [s string] [t string]) boolean?]{
 判断第一个字符串是否出现在第二个字符串中，不考虑字母的大小写。
 @interaction[#:eval (bsl) (string-contains-ci? "At" "caT")]
}
  @defproc[(string [c char] ...) string?]{
 用输入的字符构建字符串。
 @interaction[#:eval (bsl) (string #\d #\o #\g)]
}
  @defproc[(make-string [i natural-number][c char]) string]{
 生成一个长度为@racket[i]，内容为@racket[c]的字符串。
 @interaction[#:eval (bsl) (make-string 3 #\d)]
}
  @defproc[(string-ref [s string][i natural-number]) char]{
 从@racket[s]中提取第@racket[i]个字符。
 @interaction[#:eval (bsl) (string-ref "cat" 2)]
}
  @defproc[(substring [s string][i natural-number][j natural-number]) string]{
 提取从@racket[i]到@racket[j]（如果没有提供@racket[j]，就是到字符串尾）的子字符串。
 @interaction[#:eval (bsl) (substring "hello world" 1 5) (substring "hello world" 4)]
}
  @defproc[(string-copy [s string]) string]{
 复制字符串。@;why is it included?
 @interaction[#:eval (bsl) (string-copy "hello")]
}
  @defproc[(string-append [s string] ...) string]{
 连接几个字符串中的字符。
 @interaction[#:eval (bsl) (string-append "hello" " " "world" " " "good bye")]
}
  @defproc[(string-upcase [s string]) string]{
 生成和输入字符串类似的字符串，所有“字母”全部大写。
 @interaction[#:eval (bsl) (string-upcase "cat") (string-upcase "cAt")]
}

  @defproc[(string-downcase [s string]) string]{
 生成和输入字符串类似的字符串，所有“字母”全部小写。
 @interaction[#:eval (bsl) (string-downcase "CAT") (string-downcase "cAt")]
}

  @defproc[(string=? [s string][t string][x string] ...) boolean?]{
 判断所有字符串是否相等，字符对字符。
 @interaction[#:eval (bsl) (string=? "hello" "world") (string=? "bye" "bye")]
}
  @defproc[(string<? [s string][t string][x string] ...) boolean?]{
 判断字符串是否以按字典顺序严格递增排列。
 @interaction[#:eval (bsl) (string<? "hello" "world" "zoo")]
}
  @defproc[(string>? [s string][t string][x string] ...) boolean?]{
 判断字符串是否以按字典顺序严格递减排列。
 @interaction[#:eval (bsl) (string>?  "zoo" "world" "hello")]
}
  @defproc[(string<=? [s string][t string][x string] ...) boolean?]{
 判断字符串是否以按字典顺序递增排列。
 @interaction[#:eval (bsl) (string<=? "hello" "hello" "world" "zoo")]
}
  @defproc[(string>=? [s string][t string][x string] ...) boolean?]{
 判断字符串是否以按字典顺序递减排列。
 @interaction[#:eval (bsl) (string>=?  "zoo" "zoo" "world" "hello")]
}
  @defproc[(string-ci=?  [s string][t string][x string] ...) boolean?]{
 判断所有字符串是否相等，字符对字符，不区分大小写。
 @interaction[#:eval (bsl) (string-ci=?  "hello" "HellO")]
}
  @defproc[(string-ci<?  [s string][t string][x string] ...) boolean?]{
 判断字符串是否按字典顺序严格递增排列，不区分大小写。
 @interaction[#:eval (bsl) (string-ci<? "hello" "WORLD" "zoo")]
}
  @defproc[(string-ci>?  [s string][t string][x string] ...) boolean?]{
 判断字符串是否按字典顺序严格递减排列，不区分大小写。
 @interaction[#:eval (bsl) (string-ci>?  "zoo" "WORLD" "hello")]
}
  @defproc[(string-ci<=? [s string][t string][x string] ...) boolean?]{
 判断字符串是否按字典顺序递增排列，不区分大小写。
 @interaction[#:eval (bsl) (string-ci<=? "hello" "WORLD" "zoo")]
}
  @defproc[(string-ci>=? [s string][t string][x string] ...) boolean?]{
 判断字符串是否按字典顺序递减排列，不区分大小写。
 @interaction[#:eval (bsl) (string-ci>?  "zoo" "WORLD" "hello")]
}
  @defproc[(string->symbol [s string]) symbol]{
 将字符串转换为符号。
 @interaction[#:eval (bsl) (string->symbol "hello")]
}
  @defproc[(string->number [s string]) (union number #false)]{
 将字符串转换为数值，如果不可能则生成false。
 @interaction[#:eval (bsl) (string->number "-2.03") (string->number "1-2i")]
}
  @defproc[(string->list [s string]) (listof char)]{
 将字符串转换为字符的表。
 @interaction[#:eval (bsl) (string->list "hello")]
}
  @defproc[(list->string [l list?]) string]{
 将字符的表转换为字符串。
 @interaction[#:eval (bsl) (list->string (cons #\c (cons #\a (cons #\t '()))))]
}
  @defproc[(format [f string] [x any/c] ...) string]{
 格式化字符串，同时可以将值嵌入其中。
 @interaction[#:eval (bsl)
              (format "Dear Dr. ~a:" "Flatt")
              (format "Dear Dr. ~s:" "Flatt")
              (format "the value of ~s is ~a" '(+ 1 1) (+ 1 1))
              ]
 })

 ("图像"
  @defproc[(image? [x any/c]) boolean?]{
 判断值是否为图像。
 @interaction[#:eval (bsl) c1 (image? c1)]
}
  @defproc[(image=? [i image][j image]) boolean?]{
 判断两个图像是否相等。
 @interaction[#:eval (bsl)
              c1
              (image=? (circle 5 "solid" "green") c1)
              (image=? (circle 10 "solid" "green") c1)]
 })

 ("杂项"
  @defproc[(identity [x any/c]) any]{
 返回@racket[x]。
 @interaction[#:eval (bsl) (identity 42) (identity c1)  (identity "hello")]
}
  @defproc[((beginner-error error) [x any/c] ...) void?]{
 抛出错误，错误消息由输入值组合而成。如果任何输入值的打印表示太长的话，它会被截断并以“...”的形式放入字符串中。如果第一个值是个符号，它将被放在错误消息前部并后跟冒号。
 @interaction[#:eval (bsl) zero (if (= zero 0) (error "can't divide by 0") (/ 1 zero))]
}
  @defproc[((beginner-struct? struct?) [x any/c]) boolean?]{
 判断某个值是否为结构体。
 @interaction[#:eval (bsl) (struct? (make-posn 1 2)) (struct? 43)]
}
  @defproc[((beginner-equal? equal?) [x any/c][y any/c]) boolean?]{
 判断两个值在结构上是否相等，其中基本值以eqv?谓词进行比较。
 @interaction[#:eval (bsl) (equal? (make-posn 1 2) (make-posn (- 2 1) (+ 1 1)))]
}
  @defproc[(eq? [x any/c][y any/c]) boolean?]{
 从计算机的角度判断两个值是否（内涵）相等。
 @interaction[#:eval (bsl) (eq? (cons 1 '()) (cons 1 '())) one (eq? one one)]
}
  @defproc[(eqv? [x any/c][y any/c]) boolean?]{
 判断两个值是否（外延）相等，即从所用作用于其的函数角度来看。
 @interaction[#:eval (bsl) (eqv? (cons 1 '()) (cons 1 '())) one (eqv? one one)]
}
  @defproc[((beginner-=~ =~) [x number][y number][eps non-negative-real]) boolean?]{
 检查@racket[x]和@racket[y]是相距在@racket[eps]之内。
 @interaction[#:eval (bsl) (=~ 1.01 1.0 .1) (=~ 1.01 1.5 .1)]
}
  @defproc[((beginner-equal~? equal~?) [x any/c][y any/c][z non-negative-real]) boolean?]{
 用@racket[equal?]比较@racket[x]和@racket[y]是否相等，但在数值的情况下使用=~比较。
 @interaction[#:eval (bsl) (equal~? (make-posn 1.01 1.0) (make-posn 1.01 .99) .2)]
}
  @defthing[eof eof-object?]{表示文件结束的值：
 @interaction[#:eval (bsl) eof]
}
  @defproc[(eof-object? [x any/c]) boolean?]{
 判断某个值是否是文件结束值。
 @interaction[#:eval (bsl) (eof-object? eof) (eof-object? 42)]
}
  @defproc[((beginner-exit exit)) void]{
 对@racket[(exit)]求值就会终止正在运行的程序。
 }))
