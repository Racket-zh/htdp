#lang at-exp scheme/base
  (require "teachprims.rkt"
           mzlib/etc
           mzlib/list
           mzlib/pretty
           syntax/docprovide
           scheme/promise
           scheme/port
           "../posn.rkt"
           (for-syntax scheme/base))

(define advanced-list? list?)

;; Documents the procedures:
(require "provide-and-scribble.rkt")

(define pp (let ([pretty-print (lambda (v) (pretty-write v))]) pretty-print))

(provide-and-scribble
   procedures

   (begin
     (require scribble/manual scribble/eval "sl-eval.rkt")
     (define (asl)
       (define *bsl
         (asl-eval
	   [(define c1 (circle 10 "solid" "green"))

          (define zero 0)

          (define one (list 1))

          ;; b 69, c 42, e 61
          (define list-for-hash '((b 69) (c 42) (e 61) (r 999)))

          (define hsh (make-hash list-for-hash))
          (define heq (make-hasheq list-for-hash))
          (define heqv (make-hasheqv list-for-hash))
          (define ish (make-immutable-hash list-for-hash))
          (define ieq (make-immutable-hasheq list-for-hash))
          (define ieqv (make-immutable-hasheqv list-for-hash))

          (define q (make-posn "bye" 2))
          (define p (make-posn 2 -3))

          (define v (vector "a" "b" "c" "d" "e"))

          (define b (box 33))

          (define s "hello world")
          (define x (list 2 "hello" #true))]))
       (set! asl (lambda () *bsl))
       *bsl))

   ("数值：整数、有理数、实数、复数、精确数、非精确数"
    @defproc[(random [x natural]) natural]{
    生成随机数。如果传入一个参数@racket[random]返回小于给定自然数的自然数。在高级语言中，如果没有传入参数，@racket[random]会给出0.0到1.0之间的随机非精确数。
    @interaction[#:eval (asl) (random)]
    @interaction[#:eval (asl) (random)]
    @interaction[#:eval (asl) (random 42)]
    @interaction[#:eval (asl) (random 42)]
    }
    )

   ("输入输出"
    @defproc[(with-input-from-file [f string] [p (-> any)]) any]{
    打开名为@racket[f]的输入文件，允许@racket[p]从中读入输入。
    }
    @defproc[(with-output-to-file [f string] [p (-> any)]) any]{
    打开名为@racket[f]的输出文件，允许@racket[p]向其写输出。
    }
    @defproc[(with-input-from-string [s string] [p (-> any)]) any]{
    将@racket[s]转换为@racket[p]中@racket[read]运算的输入。
    @interaction[#:eval (asl)
      (with-input-from-string "hello" read)
      (string-length (symbol->string (with-input-from-string "hello" read)))]
    }
    @defproc[(with-output-to-string [p (-> any)]) any]{
    用@racket[p]中所有write/display/print运算生成字符串。
    @interaction[#:eval (asl)
      (with-output-to-string (lambda () (display 10)))]
    }

    @defproc[(print [x any]) void]{
    打印参数的值。
    @interaction[#:eval (asl)
      (print 10)
      (print "hello")
      (print 'hello)]
    }
    @defproc[(display [x any]) void]{
    将参数打印到stdout（对符号和字符串等不使用引号）。
    @interaction[#:eval (asl)
      (display 10)
      (display "hello")
      (display 'hello)]
    }
    @defproc[(write [x any]) void]{
    将参数打印到stdout（采用介于@racket[print]和@racket[display]之间的传统样式）。
    @interaction[#:eval (asl)
      (write 10)
      (write "hello")
      (write 'hello)]
    }
    @defproc[((pp pretty-print) [x any]) void]{
    用优美格式打印S表达式（类似于@racket[write]）。
    @interaction[
 #:eval (asl)
 (pretty-print '((1 2 3) ((a) ("hello world" #true) (((false "good bye"))))))
 (pretty-print (build-list 10 (lambda (i) (build-list 10 (lambda (j) (= i j))))))
 ]
    }

    @defproc[(printf [f string] [x any] ...) void]{
    根据第一个参数格式化其余参数并打印之。}

    @defproc[(newline) void]{
    打印换行符。}

    @defproc[(read) sexp]{
    读取用户的输入。})

   ("链表"
;    @defproc[((advanced-list? list?) [x any]) boolean]{
;    Determines whether some value is a list.
;    In ASL, @racket[list?] also deals with cyclic lists.
;    }
    @defproc[((advanced-list* list*) [x any] ... [l (listof any)]) (listof any)]{
    向表（前部）添加多个项，构造（新）表。
    在高级语言中，@racket[list*]也能处理带循环的链表。
    }
    @defproc[((advanced-cons cons) [x X] [l (listof X)]) (listof X)]{
    构造链表。
    在高级语言中，@racket[cons]创建可变的表。
    }
    @defproc[((advanced-append append) [l (listof any)] ...) (listof any)]{
    用多个表创建表。
    在高级语言中，@racket[list*]也能处理带循环的表。
    }
)

   ("杂项"
    @defproc[(gensym) symbol?]{
    生成与程序中所有符号都不同的新符号。
    @interaction[#:eval (asl) (gensym)]
    }
    @defproc[(sleep [sec positive-num]) void]{
    让程序休眠给定的秒数。
    }
    @defproc[(current-milliseconds) exact-integer]{
    返回当前“时间”，单位为固定长度数表示的毫秒（可能为负数）。
    @interaction[#:eval (asl) (current-milliseconds)]
    }
    @defproc[(force [v any]) any]{
    求出被延迟的值；另见delay。
    }
    @defproc[(promise? [x any]) boolean?]{
    判断值是否被延迟。
    }
    @defproc[(void) void?]{
    返回空值。
    @interaction[#:eval (asl) (void)]
    }
    @defproc[(void? [x any]) boolean?]{
    判断值是否为空值void。
    @interaction[#:eval (asl) (void? (void)) (void? 42)]
    })

   ("Posn"
    @defproc[(set-posn-x! [p posn] [x any]) void?]{
    更新posn的x字段。
    @interaction[#:eval (asl) p (set-posn-x! p 678) p]
    }
    @defproc[(set-posn-y! [p posn] [x any]) void]{
    更新posn的y字段。
    @interaction[#:eval (asl) q (set-posn-y! q 678) q]
    })

   ("向量"
    @defproc[(vector [x X] ...) (vector X ...)]{
    用输入值构造向量。
    @interaction[#:eval (asl) (vector 1 2 3 -1 -2 -3)]
    }
    @defproc[(make-vector [n number] [x X]) (vectorof X)]{
    构造包含@racket[n]个@racket[x]的向量。
    @interaction[#:eval (asl) (make-vector 5 0)]
    }
    @defproc[(build-vector [n nat] [f (nat -> X)]) (vectorof X)]{
    通过将@racket[f]应用于从@racket[0]到@racket[(- n 1)]的数来构造向量。
    @interaction[#:eval (asl) (build-vector 5 add1)]
    }
    @defproc[(vector-ref [v (vector X)] [n nat]) X]{
    提取@racket[v]的第@racket[n]个元素。
    @interaction[#:eval (asl) v (vector-ref v 3)]
    }
    @defproc[(vector-length [v (vector X)]) nat]{
    求@racket[v]的长度。
    @interaction[#:eval (asl) v (vector-length v)]
    }
    @defproc[(vector-set! [v (vectorof X)][n nat][x X]) void]{
    将@racket[v]的@racket[n]位置更新为@racket[x]。
    @interaction[#:eval (asl) v (vector-set! v 3 77) v]
    }
    @defproc[(vector->list [v (vectorof X)]) (listof X)]{
    将@racket[v]转换为链表。
    @interaction[#:eval (asl) (vector->list (vector 'a 'b 'c))]
    }
    @defproc[(list->vector [l (listof X)]) (vectorof X)]{
    将@racket[l]转换为向量。
    @interaction[#:eval (asl) (list->vector (list "hello" "world" "good" "bye"))]
    }
    @defproc[(vector? [x any]) boolean]{
    判断值是否为向量。
    @interaction[#:eval (asl) v (vector? v) (vector? 42)]
    })

   ("箱子"
    @defproc[(box [x any/c]) box?]{
    构造箱子。
    @interaction[#:eval (asl) (box 42)]
    }
    @defproc[(unbox [b box?]) any]{
    提取箱子中的值。
    @interaction[#:eval (asl) b (unbox b)]
    }
    @defproc[(set-box! [b box?][x any/c]) void]{
    更新箱子中的值。
    @interaction[#:eval (asl) b (set-box! b 31) b]
    }
    @defproc[(box? [x any/c]) boolean?]{
    判断值是否是箱子。
    @interaction[#:eval (asl) b (box? b) (box? 42)]
    })

   ("散列表"
    @defproc[((advanced-make-hash make-hash)) (hash X Y)]{
    用可选的输入——映射的表——创建可变散列表，其中使用equal?进行比较。
    @interaction[#:eval (asl)
      (make-hash)
      (make-hash '((b 69) (e 61) (i 999)))
      ]
    }
    @defproc[((advanced-make-hasheq make-hasheq)) (hash X Y)]{
    用可选的输入——映射的表——创建可变散列表，其中使用eq?进行比较。
    @interaction[#:eval (asl)
      (make-hasheq)
      (make-hasheq '((b 69) (e 61) (i 999)))
      ]
    }
    @defproc[((advanced-make-hasheqv make-hasheqv)) (hash X Y)]{
    用可选的输入——映射的表——创建可变散列表，其中使用eqv?进行比较。
    @interaction[#:eval (asl)
      (make-hasheqv)
      (make-hasheqv '((b 69) (e 61) (i 999)))
      ]
    }
    @defproc[((advanced-make-immutable-hash make-immutable-hash)) (hash X Y)]{
    用可选的输入——映射的表——创建不可变散列表，其中使用equal?进行比较。
    @interaction[#:eval (asl)
      (make-immutable-hash)
      (make-immutable-hash '((b 69) (e 61) (i 999)))
      ]
    }
    @defproc[((advanced-make-immutable-hasheq make-immutable-hasheq)) (hash X Y)]{
    用可选的输入——映射的表——创建不可变散列表，其中使用eq?进行比较。
    @interaction[#:eval (asl)
      (make-immutable-hasheq)
      (make-immutable-hasheq '((b 69) (e 61) (i 999)))
      ]
    }
    @defproc[((advanced-make-immutable-hasheqv make-immutable-hasheqv)) (hash X Y)]{
    用可选的输入——映射的表——创建不可变散列表，其中使用eqv?进行比较。
    @interaction[#:eval (asl)
      (make-immutable-hasheqv)
      (make-immutable-hasheqv '((b 69) (e 61) (i 999)))
      ]
    }
    @defproc[(hash-set! [h (hash X Y)] [k X] [v Y]) void?]{
    用新映射更新可变散列表。
    @interaction[#:eval (asl) hsh (hash-set! hsh 'a 23) hsh]
    }
    @defproc[(hash-set  [h (hash X Y)] [k X] [v Y]) (hash X Y)]{
    构造新的不可变散列表，在原有不可变散列表中加入新映射。
    @interaction[#:eval (asl) (hash-set ish 'a 23)]
    }
    @defproc[(hash-ref  [h (hash X Y)] [k X]) Y]{
    从散列表中提取键值所关联的值；第三个可选参数可以提供默认值，或者计算默认值。
    @interaction[#:eval (asl) hsh (hash-ref hsh 'b)]
    }
    @defproc[(hash-ref! [h (hash X Y)] [k X] [v Y]) Y]{
    从散列表中提取键值所关联的值；如果键值没有被关联，使用第三个参数的值（或其计算所得的值），并将此值插入散列表中（关联到给定的键值）。
    @interaction[#:eval (asl) hsh (hash-ref! hsh 'd 99) hsh]
    }
    @defproc[(hash-update! [h (hash X Y)] [k X] [f (Y -> Y)]) void?]{
    组合hash-ref和hash-set!更新现有的映射；第三个参数被用来计算新的映射值；第四个参数是提供给hash-ref的第三个参数。
    @interaction[#:eval (asl) hsh (hash-update! hsh 'b (lambda (old-b) (+ old-b 1))) hsh]
    }
    @defproc[(hash-update  [h (hash X Y)] [k X] [f (Y -> Y)]) (hash X Y)]{
    组合hash-ref和hash-set更新现有的映射；第三个参数被用来计算新的映射值；第四个参数是提供给hash-ref的第三个参数。
    @interaction[#:eval (asl) (hash-update ish 'b (lambda (old-b) (+ old-b 1)))]
    }
    @defproc[(hash-has-key? [h (hash X Y)] [x X]) boolean]{
    判断键值是否在散列表中关联于某个映射值。
    @interaction[#:eval (asl)
      ish
      (hash-has-key? ish 'b)
      hsh
      (hash-has-key? hsh 'd)]
    }
    @defproc[(hash-remove! [h (hash X Y)] [x X]) void]{
    从可变散列表中删除映射。
    @interaction[#:eval (asl)
      hsh
      (hash-remove! hsh 'r)
      hsh]
    }
    @defproc[(hash-remove [h (hash X Y)] [k X]) (hash X Y)]{
    构造新的不可变的散列表，在原有不可变散列表中减去一个映射。
    @interaction[#:eval (asl)
      ish
      (hash-remove ish 'b)]
    }
    @defproc[(hash-map [h (hash X Y)] [f (X Y -> Z)]) (listof Z)]{
    将函数应用于散列表中的每个映射对，构造新的链表。
    @interaction[#:eval (asl)
      ish
      (hash-map ish list)]
    }
    @defproc[(hash-for-each [h (hash X Y)] [f (X Y -> any)]) void?]{
    将函数应用于散列表中的每个映射对，仅取效果。
    @interaction[#:eval (asl)
      hsh
      (hash-for-each hsh (lambda (ky vl) (hash-set! hsh ky (+ vl 1))))
      hsh]
    }
    @defproc[(hash-count [h hash]) integer]{
    求散列表中映射键值的数量。
    @interaction[#:eval (asl)
      ish
      (hash-count ish)]
    }
    @defproc[(hash-copy [h hash]) hash]{
    复制散列表。
    }
    @defproc[(hash? [x any]) boolean]{
    判断值是否为散列表。
    @interaction[#:eval (asl)
      ish
      (hash? ish)
      (hash? 42)]
    }
    @defproc[(hash-equal? [h hash?]) boolean]{
    判断散列表是否使用equal?进行比较。
    @interaction[#:eval (asl)
      ish
      (hash-equal? ish)
      ieq
      (hash-equal? ieq)
      ]
    }
    @defproc[(hash-eq? [h hash]) boolean]{
    判断散列表是否使用eq?进行比较。
    @interaction[#:eval (asl)
      hsh
      (hash-eq? hsh)
      heq
      (hash-eq? heq)
      ]
    }
    @defproc[(hash-eqv? [h hash]) boolean]{
    判断散列表是否使用eqv?进行比较。
    @interaction[#:eval (asl)
      heq
      (hash-eqv? heq)
      heqv
      (hash-eqv? heqv)
      ]
    }))
