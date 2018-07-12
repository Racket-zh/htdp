#lang scribble/doc

@(require scribble/manual "shared.rkt" (for-label racket teachpack/htdp/lkup-gui))

@teachpack["lkup-gui"]{查找GUI}

@defmodule[#:require-form beginner-require htdp/lkup-gui]

本教学包提供三个函数：

@defproc[(control [index natural-number?]) symbol?]{
 读出第@racket[index]个猜测选项，从0开始计数}

@defproc[(view [msg (or/c string? symbol?)]) true/c]{
 在消息面板（message panel）中显示@racket[msg]参数}

@defproc[(connect [event-handler (-> button% event% true/c)]) true/c]{
 连接控制函数（@racket[handler]）和Check按钮}

例如：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
(connect
 (lambda (e b)
   (view (control))))
))
@;%
这个例子简单地显示用户键入消息字段（message field）的内容。
