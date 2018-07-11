#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/gui))

@teachpack["gui"]{简单的图形用户界面}

@;declare-exporting[teachpack/htdp/gui]
@defmodule[#:require-form beginner-require htdp/gui]

本教学包提供创建和操作图形用户界面的函数。我们建议改用@racketmodname[2htdp/universe]。

@deftech{Window} @tech{Window}是计算机屏幕上可见的窗口的数据表示。

@deftech{GUI-ITEM} @tech{GUI-Item}是计算机屏幕上窗口中活动组件的数据表示。

@defproc[(create-window [g (listof (listof (unsyntax @tech{GUI-ITEM})))])  Window]{
用GUI-ITEM的“矩阵”@racket[g]创建Window。}

@defproc[(window? [x any/c]) boolean?]{输入值是window吗？}

@defproc[(show-window [w Window]) true]{显示@racket[w]。}

@defproc[(hide-window [w window]) true]{隐藏@racket[w]。}

@defproc[(make-button [label string>][callback (-> event%  boolean)])  (unsyntax @tech{GUI-ITEM})]{
用@racket[label](标签)和@racket[callback]（回调）函数创建按钮。
回调函数读入一个值，可以安全地忽略之。}

@defproc[(make-message [msg string?]) (unsyntax @tech{GUI-ITEM})]{用@racket[msg]创建消息item。}

@defproc[(draw-message [g (unsyntax @tech{GUI-ITEM})][m string?])  true]{在消息item
@racket[g]中显示@racket[m]，同时删除当前消息。}

@defproc[(make-text [txt string?]) (unsyntax @tech{GUI-ITEM})]{
创建标签为@racket[txt]的文本编辑器，允许用户输入文本。}

@defproc[(text-contents [g (unsyntax @tech{GUI-ITEM})])  string?]{求text
@tech{GUI-ITEM}的当前内容。}

@defproc[(make-choice [choices (listof string?)]) (unsyntax @tech{GUI-ITEM})]{
用@racket[choices]创建选择菜单，允许用户从一些选项中进行选择。}

@defproc[(choice-index [g (unsyntax @tech{GUI-ITEM})]) natural-number/c]{求choice
@tech{GUI-ITEM}当前选中的选项；结果是选择菜单从0开始的索引。}

示例1：
@(begin
#reader scribble/comment-reader
(racketblock
> (define w
    (create-window
      (list (list (make-button "QUIT" (lambda (e) (hide-window w)))))))
;; 屏幕上出现一个按钮。
;; 单击按钮，它将消失。
> (show-window w)
;; 窗口消失。
))

示例2：
@(begin
#reader scribble/comment-reader
(racketblock
;; text1 : GUI-ITEM
(define text1
  (make-text "Please enter your name"))

;; msg1 : GUI-ITEM
(define msg1
  (make-message (string-append "Hello, World" (make-string 33 #\SPACE))))

;; Event -> true
;; 将text1的当前内容绘制到msg1中，前面加上“Hello, ”
(define (respond e)
  (draw-message msg1 (string-append "Hello, " (text-contents text1))))

;; 设置有三“行”的窗口：
;;    text field、message，以及两个按钮
;; 填写文本并单击“OKAY”
(define w
  (create-window
   (list
    (list text1)
    (list msg1)
    (list (make-button "OKAY" respond)
          (make-button "QUIT" (lambda (e) (hide-window w)))))))
))
