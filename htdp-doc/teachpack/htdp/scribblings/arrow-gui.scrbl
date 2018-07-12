#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label scheme teachpack/htdp/arrow-gui))

@teachpack["arrow-gui"]{箭头GUI}

@defmodule[#:require-form beginner-require htdp/arrow-gui]

本教学包提供用于创建和操纵箭头GUI（图形用户界面）的函数。
我们建议改用@racketmodname[2htdp/universe]。

@deftech{modelT} @racket[(-> button% event% true)]

@tech{modelT}是函数，它读入两个参数并忽略之。

@defproc[(control) symbol?]{读出message field的当前状态。} 

@defproc[(view [s (or/c string? symbol?)]) true]{在message
field中显示@racket[s]。} 

@defproc[(connect [l (unsyntax @tech{modelT})][r (unsyntax @tech{modelT})][u (unsyntax @tech{modelT})][d (unsyntax @tech{modelT})]) true]{
在箭头窗口中连接四个控制函数和四个方向。}

例子：
@(begin
#reader scribble/comment-reader
(racketblock
;; 高级
(define (make-model dir)
  (lambda (b e)
    (begin
      (view dir)
      (printf "~a ~n" (control)))))

(connect (make-model "left")
         (make-model "right")
         (make-model "up")
         (make-model "down"))
))
现在点击四个箭头。message field会显示当前方向。
