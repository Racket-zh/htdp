#lang at-exp racket/base

(provide
  grammar
  i1-2-expl
  i2-3-expl
  dots
  i1-2
  i2-3
  (all-from-out scribble/manual))

;; -----------------------------------------------------------------------------
(require scribble/manual)

@; -----------------------------------------------------------------------------
(define dots (bold "..."))

(define htdp "http://www.htdp.org/2018-01-06/Book/")
(define i1-2 (string-append htdp "i1-2.html"))
(define i2-3 (string-append htdp "i2-3.html"))

(define grammar
  @list{语法符号使用符号@racket[X #, @dots]（粗体的点）表示@racket[X]可能出现任意多次（零次，一次或多次）。此外，语法还将@racket[...]定义为可以在模板中使用的标识符。})

(define i1-2-expl
  @list{关于初级语言的解释，请参阅@link[i1-2]{《程序设计方法（第二版）》的独立章节1}。})

(define i2-3-expl
  @list{关于引用表的解释，请参阅@link[i2-3]{《程序设计方法（第二版）》的独立章节2}。})
