#lang scribble/doc

@(require scribble/manual "shared.rkt" scribble/eval
          (for-label scheme
                     (only-in lang/htdp-beginner check-expect)
                     teachpack/2htdp/universe
                     2htdp/image))
@(require scribble/struct)

@(define note-scene @margin-note*{关于@racket[scene?]请参见@secref{scene}。})

@(define (table* . stuff)
  ;; (list paragraph paragraph) *-> Table
   (define (flow* x) (make-flow (list x)))
   (make-blockquote #f
     (list
       (make-table (make-with-attributes 'boxed
                     '((cellspacing . "6")))
         ;list
         (map (lambda (x) (map flow* x)) stuff)
         #;(map flow* (map car stuff))
         #;(map flow* (map cadr stuff))))))

@(define WorldState @tech[#:tag-prefixes '("world")]{WorldState})
@(define S-expression @tech[#:tag-prefixes '("universe")]{S-expression})

@; -----------------------------------------------------------------------------

@teachpack["universe"]{世界和宇宙}

@author["Matthias Felleisen" "Racket-zh项目组译"]

@defmodule[#:require-form beginner-require 2htdp/universe #:use-sources (teachpack/2htdp/image)]

@;{FIXME: the following paragraph uses `defterm' instead of `deftech',
   because the words "world" and "universe" are used as datatypes, and
   datatypes are currently linked as technical terms --- which is a hack.
   Fix the paragraph when we have a better way to link datatype names.}

@tt{universe.rkt}教学包实现并提供用于创建（由简单数学函数组成的）交互式图形程序的功能。
我们将此类程序称为@deftech{世界}（world）程序。 此外，
世界程序也可以成为@deftech{宇宙}（universe）的一部分，宇宙是可以交换信息的世界的集合。

本文档的目的，是为经验丰富的Racketeer和HtDP教师提供使用该库的简明概述。
文档的第一部分侧重于@tech{世界}程序。@secref["world-example"]展示了如何为简单领域设计此类程序；
它适用于知道如何为枚举、区间和联合设计条件函数的新程序员。本文档的后半部分侧重于“宇宙”程序：
如何通过服务器管理宇宙、@tech{世界}程序如何向服务器注册，等等。
最后两节展示了如何设计由两个相互通信的世界构成的简单宇宙。

@emph{注意}：要快速从教育角度理解世界，
请参阅@link["http://www.htdp.org/2018-01-06/Book/part_prologue.html"]{《程序设计方法（第二版）》的序言}。
2008年8月，我们还编写了一本小册子@link["http://world.cs.brown.edu/"]{How to Design Worlds}，其中包含一系列项目。

@; -----------------------------------------------------------------------------
@section[#:tag "scene"]{背景}

universe教学包宇宙教程包假定你了解基本的图像处理运算，
@racketmodname[htdp/image]或@racketmodname[2htdp/image]都可以。
就这个本扩展手册而言，这两个图像教学包之间的主要区别是
@nested[#:style 'inset]{
  @racketmodname[htdp/image]程序将它们的状态呈现为@emph{场景}，即满足@racket[scene?]谓词的图像。
}
回忆一下，@racketmodname[htdp/image]将场景定义为pinhole位于@math{(0,0)}的图像。
如果程序使用@racketmodname[2htdp/image]中的运算，那么所有图像都是场景。

虽然两个图像教学包都适用于本教学包中的运算，但我们希望在不久的将来去除@racketmodname[htdp/image]。
所有示例程序都已使用@racketmodname[2htdp/image]运算编写。
我们敦促程序员在设计新的“世界”和“宇宙”程序时使用@racketmodname[2htdp/image]，
并将现有的@racketmodname[htdp/image]程序重写以使用@racketmodname[2htdp/image]。

@; -----------------------------------------------------------------------------
@section[#:tag "simulations"]{简单的模拟}

最简单的动画@tech{世界}程序是基于时间的模拟，也就是一系列的图像。
程序员的任务是提供函数，为每个自然数创建图像。将此函数传给教学包，就会显示该模拟。

@defproc[(animate [create-image (-> natural-number/c scene?)])
         natural-number/c]{
@note-scene
打开一个画布，并启动一个每秒钟滴答28次的时钟。每次时钟滴答时，
DrRacket都会将@racket[create-image]应用于自@racket[animate]函数调用以来经过的滴答数。
@racket[create-image]函数调用的结果将被显示到画布中。模拟将一直运行，
直到单击DrRacket中的@tt{中断}按钮或关闭窗口。此时，@racket[animate]返回已经过的滴答数。
}

例子：
@racketblock[
(define (create-UFO-scene height)
  (underlay/xy (rectangle 100 100 "solid" "white") 50 height UFO))

(define UFO
  (underlay/align "center"
                  "center"
                  (circle 10 "solid" "green")
                  (rectangle 40 4 "solid" "green")))

(animate create-UFO-scene)
]

@defproc[(run-simulation [create-image (-> natural-number/c scene?)])
         natural-number/c]{
@note-scene
 @racket[animate]最初被称为@racket[run-simulation]，为了向后兼容性改名字也被保留。}

@defproc[(run-movie [r (and/c real? positive?)] [m [Listof image?]])
         [Listof image?]]{

@racket[run-movie]显示图像的表@racket[m]，每个图像花费@racket[r]秒。
动画停止时，它返回剩余未显示的图像表。}


@;-----------------------------------------------------------------------------
@section[#:tag "interactive" #:tag-prefix "world"]{交互}

从模拟程序到交互式程序的变化相对较小。粗略地说，模拟指定一个函数@racket[_create-image]，
作为一种事件的处理程序：时钟滴答。除了时钟滴答，@tech{世界}程序还可以处理其他两种事件：
键盘事件和鼠标事件。当计算机用户按下键盘上的键时，将触发键盘事件。类似地，
鼠标事件是鼠标的移动、鼠标按钮的单击、鼠标移动过边界交叉，等等。

程序可以通过@emph{指定}@emph{处理程序}函数来处理此类事件。具体来说，
本教学包提供了四种事件处理程序的安装：@racket[on-tick]、@racket[on-key]、
@racket[on-mouse]和@racket[on-pad]。此外，@tech{世界}程序必须指定一个@racket[render]函数，
每当程序可视化当前世界时调用该函数，以及一个@racket[done]谓词，用于确定@tech{世界}程序何时应该关闭。

每个处理函数都读入@tech{世界}的当前状态，以及（可选的）事件的数据表示。它返回新的@tech{世界}状态。

@image["nuworld.png"]

@racket[big-bang]形式将@racket[World_0]安装为初始的@tech{WorldState}（世界状态）。
处理程序@racket[tock]、@racket[react]和@racket[click]将一个世界转换为另一个；
每次处理某个事件时，都会使用@racket[done]来检查世界是否是最终的，如果是的话程序会被关闭；
最后，@racket[render]将每个世界呈现为图像，并在外部画布上显示。

@deftech{WorldState} : @racket[any/c]

世界程序的设计要求程序员提供所有可能状态的数据定义。我们将这个数据集合称为@tech{WorldState}，
使用大写字母W将其与程序区分开。原则上，对此数据定义没有约束，
不过它不能是@tech[#:tag-prefixes '("universe")]{Package}结构体的实例（见下文）。
你甚至可以隐式的定义它，尽管这违反了@emph{设计诀窍}。

@defform/subs[#:id big-bang
              #:literals
              (on-tick to-draw on-draw on-key on-pad on-release on-mouse on-receive stop-when
              check-with register record? close-on-stop display-mode state name port)
              (big-bang state-expr clause ...)
              ([clause
                 (on-tick tick-expr)
                 (on-tick tick-expr rate-expr)
                 (on-tick tick-expr rate-expr limit-expr)
                 (on-key key-expr)
                 (on-pad pad-expr)
                 (on-release release-expr)
                 (on-mouse mouse-expr)
                 (to-draw draw-expr)
                 (to-draw draw-expr width-expr height-expr)
                 (stop-when stop-expr) (stop-when stop-expr last-scene-expr)
                 (check-with world?-expr)
                 (record? r-expr)
                 (close-on-stop cos-expr)
                 (display-mode d-expr)
                 (state expr)
                 (on-receive rec-expr)
                 (register IP-expr)
                 (port Port-expr)
                 (name name-expr)
                 ])]{

以@racket[state-expr]指定的初始状态启动@tech{世界}程序，当然@racket[state-expr]必须求值@tech{WorldState}的元素。
它的行为由可选子句中给出的处理函数指定，特别是@tech{世界}程序如何处理时钟滴答、键盘事件、鼠标事件，以及最后来自宇宙的消息；
它如何将自己呈现为图像；何时必须关闭程序；在哪里将世界注册到宇宙中；以及是否记录事件流。
世界规范不能包含多个@racket[on-tick]、@racket[to-draw]或@racket[register]子句。
当满足停止条件（见下文）、或者程序员单击@tt{中断}按钮或关闭画布时，@racket[big-bang]表达式返回最后一个世界。
}

@racket[big-bang]描述的唯一强制性子句是@racket[to-draw]（或@racket[on-draw]以实现向后兼容）：
@itemize[

@item{

@defform[(to-draw render-expr)
         #:contracts
         ([render-expr (-> (unsyntax @tech{WorldState}) scene?)])]{
@note-scene
告诉DrRacket，每当必须绘制画布时调用函数@racket[render-expr]。
在DrRacket处理完任一事件之后，通常会重新绘制外部画布。画布的大小由第一个生成图像的大小决定。}

@defform/none[#:literals (to-draw)
              (to-draw render-expr width-expr height-expr)
              #:contracts
              ([render-expr (-> (unsyntax @tech{WorldState}) scene?)]
               [width-expr natural-number/c]
               [height-expr natural-number/c])]{
@note-scene
 告诉DrRacket使用@racket[width-expr]乘@racket[height-expr]的画布，而不是由第一个生成的图像确定。
}

出于兼容性原因，teachpack还支持关键字@defidform/inline[on-draw]代替@racket[to-draw]，但现在应该使用后者。
}

]
所有其他子句都是可选的。为了介绍它们，我们还需要一个数据定义（处理函数的结果）：

@deftech{HandlerResult} ：是@tech{WorldState}的同义词，直到@secref[#:tag-prefixes '("universe")]{world2}

@itemize[

@item{
@defform[(on-tick tick-expr)
         #:contracts
         ([tick-expr (-> (unsyntax @tech{WorldState}) (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{

告诉DrRacket每次时钟滴答时对当前世界调用@racket[tick-expr]函数。
调用的结果将成为新的当前世界。时钟以每秒28次的速率滴答。}}

@item{
@defform/none[#:literals(on-tick)
              (on-tick tick-expr rate-expr)
              #:contracts
              ([tick-expr (-> (unsyntax @tech{WorldState}) (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))]
               [rate-expr (and/c real? positive?)])]{
告诉DrRacket每次时钟滴答时对当前世界调用@racket[tick-expr]函数。
调用的结果将成为新的当前世界。时钟每@racket[rate-expr]秒滴答一次。}}

@item{
@defform/none[#:literals(on-tick)
              (on-tick tick-expr rate-expr limit-expr)
              #:contracts
              ([tick-expr (-> (unsyntax @tech{WorldState}) (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))]
               [rate-expr (and/c real? positive?)]
               [limit-expr (and/c integer? positive?)])]{
告诉DrRacket每次时钟滴答时对当前世界调用@racket[tick-expr]函数。调用的结果将成为新的当前世界。
时钟每@racket[rate-expr]秒滴答一次。当时钟滴答次数超过@scheme[limit-expr]时，世界结束。}}

@item{@tech{KeyEvent}表示键盘事件。

@deftech{KeyEvent} : @racket[string?]

为简单起见，我们用字符串表示键盘事件，但并非所有字符串都是键盘事件。键盘事件的表示自成一类。
首先，单字符的字符串表示用户点击了“常规”键，例如
@itemize[

@item{@racket["q"]代表q键；}
@item{@racket["w"]代表w键；}
@item{@racket["e"]代表e键；}
@item{@racket["r"]代表r键；诸如此类。}
]
 有些单字符的字符串不那么一般：
@itemize[

@item{@racket[" "]代表空格键（@racket[#\space]）；}
@item{@racket["\r"]代表回车键（@racket[#\return]）；}
@item{@racket["\t"]代表制表键（@racket[#\tab])）；}
@item{@racket["\b"]代表退格键（@racket[#\backspace]）。}
]
 “证明”这些字符串长度确实为1：
@interaction[
(string-length "\t")
]
 在极少数情况下，程序可能会遇到@racket["\u007F"]，这是表示删除键（delete）的字符串。

其次，某些键的字符串表示具有多个字符。多字符字符串表示箭头键或其他特殊事件，先来看四个最重要的：
@itemize[
@item{@racket["left"]是左箭头；}
@item{@racket["right"]是右箭头；}
@item{@racket["up"]是上箭头；}
@item{@racket["down"]是下箭头；}
]
你还可能遇到其他的：
@itemize[
@item{@racket["start"]}
@item{@racket["cancel"]}
@item{@racket["clear"]}
@item{@racket["shift"]}
@item{@racket["rshift"]}
@item{@racket["control"]}
@item{@racket["rcontrol"]}
@item{@racket["menu"]}
@item{@racket["pause"]}
@item{@racket["capital"]}
@item{@racket["prior"]}
@item{@racket["next"]}
@item{@racket["end"]}
@item{@racket["home"]}
@item{@racket["escape"]}
@item{@racket["select"]}
@item{@racket["print"]}
@item{@racket["execute"]}
@item{@racket["snapshot"]}
@item{@racket["insert"]}
@item{@racket["help"]}
 @;item{@racket["numpad0"],
 @;racket["numpad1"],
 @;racket["numpad2"],
 @;racket["numpad3"],
 @;racket["numpad4"],
 @;racket["numpad5"],
 @;racket["numpad6"],
 @;racket["numpad7"],
 @;racket["numpad8"],
 @;racket["numpad9"],
 @;racket["numpad-enter"],
 @;racket["multiply"],
 @;racket["add"],
 @;racket["separator"],
 @;racket["subtract"],
 @;racket["decimal"],
 @;racket["divide"]}
@item{功能键：
 @racket["f1"]、
 @racket["f2"]、
 @racket["f3"]、
 @racket["f4"]、
 @racket["f5"]、
 @racket["f6"]、
 @racket["f7"]、
 @racket["f8"]、
 @racket["f9"]、
 @racket["f10"]、
 @racket["f11"]、
 @racket["f12"]、
 @racket["f13"]、
 @racket["f14"]、
 @racket["f15"]、
 @racket["f16"]、
 @racket["f17"]、
 @racket["f18"]、
 @racket["f19"]、
 @racket["f20"]、
 @racket["f21"]、
 @racket["f22"]、
 @racket["f23"]、
 @racket["f24"]}
@item{@racket["numlock"]}
@item{@racket["scroll"]}]

以下四个也被算作是键盘事件，尽管它们是由某种对鼠标的物理事件触发的：
@itemize[
@item{@racket["wheel-up"]}
@item{@racket["wheel-down"]}
@item{@racket["wheel-left"]}
@item{@racket["wheel-right"]}
]
前面的枚举既不完整覆盖本库处理的所有事件，也没有说明本库忽略哪些事件。
如果需要设计依赖于键盘上特定键的程序，你应首先编写一个小型测试程序，
以确定本库是否捕获所选的键，以及如果是的话，使用哪些字符串表示来表示这些事件。

@defproc[(key-event? [x any]) boolean?]{
 判断@racket[x]是否是@tech{KeyEvent}}

@defproc[(key=? [x key-event?][y key-event?]) boolean?]{
 比较两个@tech{KeyEvent}是否相等}

@defform[(on-key key-expr)
         #:contracts
          ([key-expr (-> (unsyntax @tech{WorldState}) key-event? (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
告诉DrRacket计算机用户每次按键时，对当前世界和对应的@tech{KeyEvent}调用@racket[key-expr]。调用的结果成为新的当前世界。

典型的键盘事件处理程序是：
@racketblock[
(define (change w a-key)
  (cond
    [(key=? a-key "left")  (world-go w -DELTA)]
    [(key=? a-key "right") (world-go w +DELTA)]
    [(= (string-length a-key) 1) w] (code:comment "order-free checking")
    [(key=? a-key "up")    (world-go w -DELTA)]
    [(key=? a-key "down")  (world-go w +DELTA)]
    [else w]))
]
 }
 省略的辅助函数@emph{world-go}应该读入世界和数值，返回新的世界。

@defform[(on-release release-expr)
         #:contracts
          ([release-expr (-> (unsyntax @tech{WorldState}) key-event? (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
告诉DrRacket每当键盘中按键释放时，对当前世界和对应的@tech{KeyEvent}中调用@racket[release-expr]函数。
当用户按下某个键，然后将其释放时，就会发生释放事件。第二个参数表示被释放的键。函数调用的结果会成为当前世界。
}
}

@item{@tech{PadEvent}是@racket[big-bang]模拟的@index["game-pad"]{game-pad}中的@tech{KeyEvent}。
@racket[on-pad]子句的存在将会使game-pad图像在合理的缩放后被叠加到当前图像之上：

@image["gamepad.png"]

@deftech{PadEvent} ：@racket[key-event?]

它是以下之一：
@itemize[
@item{@racket["left"]是左箭头；}
@item{@racket["right"]是右箭头；}
@item{@racket["up"]是上箭头；}
@item{@racket["down"]是下箭头；}
@item{@racket["w"]解释为上箭头；}
@item{@racket["s"]解释为下箭头；}
@item{@racket["a"]解释为左箭头；}
@item{@racket["d"]解释为右箭头}
@item{@racket[" "]是空格键；}
@item{@racket["shift"]是左shift键；}
@item{@racket["rshift"]是右shift键；}
]

@defproc[(pad-event? [x any]) boolean?]{
 判断@racket[x]是否是@tech{PadEvent}}

@defproc[(pad=? [x pad-event?][y pad-event?]) boolean?]{
 比较两个@tech{PadEvent}是否相等}

@defform[(on-pad pad-expr)
         #:contracts
          ([pad-expr (-> (unsyntax @tech{WorldState}) pad-event? (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
告诉DrRacket每当@tech{KeyEvent}也是@tech{PadEvent}时，对（当前世界和）其调用@racket[pad-expr]。函数调用的结果会成为当前世界。

典型的@tech{PadEvent}处理程序是：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
;; ComplexNumber PadEvent -> ComplexNumber
(define (handle-pad-events x k)
  (case (string->symbol k)
    [(up    w)      (- x 0+10i)]
    [(down  s)      (+ x 0+10i)]
    [(left  a)      (- x 10)]
    [(right d)      (+ x 10)]
    [(| |)          x0]
    [(shift)        (conjugate x)]
    [(rshift)       (stop-with (conjugate x))]))

))
@;%

 }

当@racket[big-bang]表达式指定了@racket[on-pad]子句时，所有的@tech{PadEvent}都被送给@racket[on-pad]处理程序。
除非指定了@racket[on-key]和/或@racket[on-release]子句，否则其他所有键盘事件将会被丢弃；
也指定了的情况下，所有其他的@tech{KeyEvent}都将送给对应处理程序。

为了方便@racket[on-pad]处理程序的定义，本库还提供了@racket[pad-handler]形式。

@defform/subs[#:id pad-handler
              #:literals
              (up down left right space shift)
              (pad-handler clause ...)
              ([clause
                 (up up-expr)
                 (down down-expr)
                 (left left-expr)
                 (right right-expr)
                 (space space-expr)
                 (shift shift-expr)])]{
创建处理@tech{PadEvent}的函数。每个（可选）子句贡献一个读入并返回世界的函数。
该子句的名称确定调用该函数的@tech{PadEvent}类型。

这种形式完全是可选的，并非@racket[on-pad]所必须使用。实际上，
@racket[pad-handler]可用于定义普通的@tech{KeyEvent}处理程序——如果我们可以保证玩家永远不会击中除@tech{PadEvent}键之外的其他键。
}

@racket[pad-handler]形式中所有的子句都是可选的：
@itemize[

@item{
@defform[(up up-expr)
         #:contracts
         ([tick-expr (-> (unsyntax @tech{WorldState}) (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
 为@racket["up"]和@racket["w"]事件创建处理程序。}
}

@item{
@defform[(down down-expr)
         #:contracts
         ([tick-expr (-> (unsyntax @tech{WorldState}) (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
 为@racket["down"]和@racket["s"]事件创建处理程序。}
}

@item{
@defform[(left left-expr)
         #:contracts
         ([tick-expr (-> (unsyntax @tech{WorldState}) (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
 为@racket["left"]和@racket["a"]事件创建处理程序。}
}

@item{
@defform[(right right-expr)
         #:contracts
         ([tick-expr (-> (unsyntax @tech{WorldState}) (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
 为@racket["right"]和@racket["d"]事件创建处理程序。}
}

@item{
@defform[(space space-expr)
         #:contracts
         ([tick-expr (-> (unsyntax @tech{WorldState}) (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
 为空格事件（@racket[" "]）创建处理程序。}
}

@item{
@defform[(shift shift-expr)
         #:contracts
         ([tick-expr (-> (unsyntax @tech{WorldState}) (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
 为@racket["shift"]和@racket["rshift"]事件创建处理程序。}
}

]
 如果省略了某个子句，@racket[pad-handler]会安装一个默认函数，将当前世界映射到自身。

 这是使用@racket[pad-handler]定义的@tech{PadEvent}处理程序：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
;; ComplexNumber -> ComplexNumber
(define (i-sub1 x) (- x 0+1i))

;; ComplexNumber -> ComplexNumber
(define (i-add1 x) (+ x 0+1i))

;; ComplexNumber -> ComplexNumber
;; 处理所有的@tech{PadEvent}
(define handler
  (pad-handler (left sub1) (right add1)
               (up i-sub1) (down i-add1)
               (shift (lambda (w) 0))
               (space stop-with)))

;; 一些测试：
(check-expect (handler 9 "left") 8)
(check-expect (handler 8 "up")   8-i)
))
@;%
}

@item{@tech{MouseEvent}表示鼠标事件，例如计算机用户的移动或点击鼠标。

@deftech{MouseEvent} ：@racket[(one-of/c "button-down" "button-up" "drag" "move" "enter" "leave")]

所有@tech{MouseEvent}都由字符串表示：
@itemize[

@item{@racket["button-down"]表示计算机用户按下鼠标按钮；}
@item{@racket["button-up"]表示计算机用户释放鼠标按钮；}
@item{@racket["drag"]表示计算机用户正在拖动鼠标。
按下鼠标按钮时移动鼠标，就会发生拖动事件。}
@item{@racket["move"]表示计算机用户在动鼠标；}
@item{@racket["enter"]表示计算机用户将鼠标移入画布区域；}
@item{@racket["leave"]表示计算机用户将鼠标移出画布区域。}
]

@defproc[(mouse-event? [x any]) boolean?]{
 判断@racket[x]是否是@tech{MouseEvent}}

@defproc[(mouse=? [x mouse-event?][y mouse-event?]) boolean?]{
 比较两个@tech{MouseEvent}是否相等}

@defform[(on-mouse mouse-expr)
         #:contracts
         ([mouse-expr
           (-> (unsyntax @tech{WorldState})
               integer? integer? (unsyntax @tech{MouseEvent})
               (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult}))])]{
告诉DrRacket每当计算机用户触发鼠标动作时，对当前世界、当前鼠标的@racket[x]和@racket[y]坐标，
以及对应的@tech{MouseEvent}调用@racket[mouse-expr]。调用的结果会成为当前世界。

对于@racket["leave"]和@racket["enter"]事件，鼠标的坐标可能在（隐式的）矩形之外。
也就是说，坐标可以是负的、或大于（隐式）指定的宽度和高度。

 @bold{注1}：操作系统不会注意到鼠标的每一次移动。相反，它会对动作进行采样并给出大部分的移动信号。}

@bold{注2}：虽然鼠标事件通常以预期的方式报告，但操作系统不一定按预期的顺序报告它们。
例如，Windows操作系统坚持在发现@racket["button-up"]事件后立即发出一个@racket["move"]事件的信号。
程序员必须设计@racket[on-mouse]处理程序以随时处理任何可能的鼠标事件。}

@item{

@defform[(stop-when last-world?)
         #:contracts
         ([last-world? (-> (unsyntax @tech{WorldState}) boolean?)])]{
告诉DrRacket在世界程序开始时、以及任何其他返回世界的回调之后调用@racket[last-world?]函数。
如果此调用返回@racket[#true]，就关闭世界程序。具体来说，时钟停止；
不再转发滴答事件、@tech{KeyEvent}或@tech{MouseEvent}到相应的处理程序。
@racket[big-bang]表达式返回最后的世界。
}

@defform/none[#:literals (stop-when)
         (stop-when last-world? last-picture)
         #:contracts
         ([last-world? (-> (unsyntax @tech{WorldState}) boolean?)]
          [last-picture (-> (unsyntax @tech{WorldState}) scene?)])]{
@note-scene
告诉DrRacket在世界程序开始时、以及任何其他返回世界的回调之后调用@racket[last-world?]函数。
如果此调用返回@racket[#true]，世界程序必须在最后一次显示@racket[last-picture]（所呈现的图像）之后关闭。
具体来说，时钟停止；不再转发滴答事件、@tech{KeyEvent}或@tech{MouseEvent}到相应的处理程序。
@racket[big-bang]表达式返回最后的世界。
}
}

@item{

@defstruct*[stop-with ([w (unsyntax @tech[#:tag-prefixes '("world")]{HandlerResult})])]{
向DrRacket发出信号，表示世界程序应该关闭。也就是说，如果@racket[w]是@tech[#:tag-prefixes '("world")]{HandlerResult}，
任何处理程序都可以返回@racket[(stop-with w)]。如果返回了这个，那么世界的状态就变成@racket[w]，
同时@racket[big-bang]会关闭所有的事件处理。类似地，如果世界的初始状态是@racket[(stop-with w)]，就立即关闭事件处理。}

}

@item{

@defform[#:literals (check-with)
         (check-with world-expr?)
         #:contracts
         ([world-expr? (-> Any boolean?)])]{
告诉DrRacket在每次世界处理程序调用之后对其结果调用@racket[world-expr?]。
如果这个调用返回@racket[#true]，则结果被视为世界；否则世界程序抛出错误。
}}

@item{

@defform[#:literals (record?)
         (record? r-expr)
         #:contracts
         ([r-expr any/c])]{
除非是@racket[#f]，否则告诉DrRacket启用交互的图像重放。重放动作为每个图像生成一个png图像，
并为整个序列生成动画gif，存入用户所指定的目录中。
如果@racket[r-expr]计算得到已有目录/文件夹的名称（在本地目录/文件夹中），则图像存入该目录中。
}}

@item{

@defform[#:literals (close-on-stop)
         (close-on-stop cos-expr)
         #:contracts
         ([cos-expr (or/c boolean? natural-number/c)])]{
告诉DrRacket在计算表达式@emph{之后}是否关闭@racket[big-bang]窗口。
如果@racket[cos-expr]是@racket[#false]（默认值），则窗口保持打开状态。
如果@racket[cos-expr]是@racket[#true]，则窗口立即关闭。最后，
如果@racket[cos-expr]是自然数，则窗口将在计算结束@racket[cos-expr]秒后关闭。
}}

@item{

@defform[#:literals (display-mode)
         (display-mode d-expr)
         #:contracts
         ([d-expr (or/c 'fullscreen 'normal)])]{
通知DrRacket选择以下两种显示模式之一：@racket['normal]或@racket['fullscreen]。
@racket['normal]模式是默认模式，使用@racket[to-draw]子句中指定的大小。
如果指定了@racket['fullscreen]模式，那么@racket[big-bang]将占据整个屏幕。}

@defform/none[#:literals (display-mode)
        (display-mode d-expr resize-expr)
         #:contracts
         ([d-expr (or/c 'fullscreen 'normal)]
	  [resize-expr (-> #, @tech{WorldState} number? number? #, @tech{WorldState})])]{
通知DrRacket选择以下两种显示模式之一：@racket['normal]或@racket['fullscreen]。
@racket['normal]模式是默认模式，使用@racket[to-draw]子句中指定的大小。
如果指定了@racket['fullscreen]模式，那么@racket[big-bang]将占据整个屏幕。

在初始化世界时，应用@bold{一次}可选的@racket[resize-expr]于当前世界以及显示的大小（宽度和高度）。
这使程序有机会以可移植的方式绘制适合显示尺寸的大小。}
}

@item{

@defform[#:literals (state) (state expr)]{
如果不是@racket[#f]，DrRacket会打开一个单独的窗口，每次更新时都会在其中显示当前状态（state）。
这对于希望了解世界如何演变的初学者、或者对世界程序的一般调试来说非常有用——无需设计呈现函数。
}}

@item{
@defform[(name name-expr)
         #:contracts
         ([name-expr (or/c symbol? string?)])]{
 为这个世界提供名称（@racket[namer-expr]），用作画布的标题。}
}

]

下面的例子表明，@racket[(run-simulation create-UFO-scene)]是三行代码的简写：

@(begin
#reader scribble/comment-reader
@racketblock[
(define (create-UFO-scene height)
  (underlay/xy (rectangle 100 100 "solid" "white") 50 height UFO))

(define UFO
  (underlay/align "center"
                  "center"
                  (circle 10 "solid" "green")
                  (rectangle 40 4 "solid" "green")))

;; (run-simulation create-UFO-scene)是简写形式的：
(big-bang 0
          (on-tick add1)
          (to-draw create-UFO-scene))
])

@bold{习题}：添加一个条件，当UFO到达底部时停止飞行。


@; -----------------------------------------------------------------------------
@section[#:tag "world-example"]{第一个世界的例子}

本节使用一个简单的例子来解释世界的设计。第一小节介绍了例子的领域，自动关闭的门。
第二小节是关于@tech{世界}程序的一般设计，后续小节实现门的模拟。

@subsection{对门的理解}

假设我们希望设计@tech{世界}程序，模拟一扇会自动关闭的门。当门锁着时，它可以被解锁。
虽然这么做本身并没有打开门，但现在可以这样做了。也就是说，未锁定的门还是关着的，
此时推门就能打开。一旦放开开着的门，自动闭门器就会接管并将其关上。当然，关着的门可以被锁住。

将这个描述翻译成图片表示就是：

@image["door-real.png"]

和@tech{世界}程序的一般运作图片一样，这个图表显示了一个所谓的“状态机”。
三个带圆圈的词是对门非正式描述所确定的状态：锁定、关闭（且解锁）和打开。
箭头指定门如何从一个状态进入另一个状态。例如，当门打开时，随着时间的推移，自动闭门器会将门关上。
这个转换用标记为“时间流逝”的箭头表示。其他箭头以类似的方式表示转换：

@itemize[

@item{“推”是指推开门（然后放开）；}

@item{“上锁”是指将钥匙插入锁中，转动到锁定位置的行为；}

@item{“解锁”和“上锁”相反。}

]

@; -----------------------------------------------------------------------------
@subsection{关于设计世界的提示}

用@tech{世界}程序模拟任何动态行为都需要完成两件不同的事。首先，
我们必须梳理出领域中随时间变化或对行动做出反应的那些部分，并为这些信息开发数据表示。
这就是我们所说的@|WorldState|。请记住，良好的数据定义可以使阅读者轻松地将数据映射到现实世界中的信息，
或者将现实世界中的信息映射为数据。对于世界的所有其他方面， 我们使用全局常量，包括渲染函数中需要用到的图形或图像常量。

其次，我们必须将领域中的操作——上图中的箭头——转换universe教学包可以处理的计算机的交互。
一旦决定用时间表示一个方面、用按键表示另一个方面、用鼠标移动表示第三个方面，
我们必须开发函数将世界的当前状态（表示为@|WorldState|数据）映射到下一个世界状态。
换种说法，我们刚刚创建了包含三个处理函数的愿望清单，这些函数一般具有以下的契约和目的声明：

@(begin
#reader scribble/comment-reader
(racketblock
;; tick : WorldState -> @tech[#:tag-prefixes '("world")]{HandlerResult}
;; 处理时间的流逝
(define (tick w) ...)

;; click : WorldState @emph{Number} @emph{Number} @tech{MouseEvent} -> @tech[#:tag-prefixes '("world")]{HandlerResult}
;; 处理当前世界@emph{w}中、位于(x,y)的、
;; @emph{me}类型的鼠标点击
(define (click w x y me) ...)

;; control : WorldState @tech{KeyEvent} -> @tech[#:tag-prefixes '("world")]{HandlerResult}
;; 处理当前世界@emph{w}中的键盘事件@emph{ke}
(define (control w ke) ...)
))

也就是说，一旦定义了如何用所选语言来表示领域，各种处理函数的契约也就决定了（要编写的）函数和契约。

典型的程序并不使用所有这三个函数。此外，这些函数的设计仅提供了顶层、初始设计目标。
经常会需要设计许多辅助函数。所有这些函数的集合便是@tech{世界}程序。

@centerline{@link["http://www.htdp.org/2018-01-06/Book/"]{程序设计方法（第二版）}
中提供了一个扩展示例。}

@; -----------------------------------------------------------------------------
@section[#:tag "world2" #:tag-prefix "universe"]{世界还不够}

我们已经说明了如何使用本库设计单个交互式图形用户界面（模拟、动画、游戏等）程序。
本节，我们将介绍如何设计分布式程序，也就是一批以某种方式协调其动作的程序。
单个的程序可以运行在现实中任何的计算机上（例如在地球上，以及在航天器上），
只要它连在互联网上并且允许程序（通过TCP）发送和接收消息。我们将这种安排称为@tech{宇宙}，
并将协调这些的程序称为@emph{宇宙服务器}，简称为或@emph{服务器}。

本节介绍了消息是什麽、@tech{世界}程序如何发送消息、如何接收消息，以及如何将@tech{世界}程序连接到@tech{宇宙}。

@; -----------------------------------------------------------------------------

@subsection{消息}

在世界程序成为宇宙的一部分之后，它可以发送消息并接收消息。就数据而言，消息就是@tech{S-expression}。

@deftech{S-expression} S表达式大致是基本数据的嵌套列表；确切地说，S表达式是以下之一：

@itemize[
 @item{字符串、}
 @item{符号、}
 @item{数值、}
 @item{布尔值、}
 @item{字符、}
 @item{S表达式的表、}
 @item{S表达式的预制struct、}
 @item{字节串。}
]
注意这里@racket[list]子句当然也包括@racket[empty]。

@defproc[(sexp? [x any/c]) boolean?]{
 判断@racket[x]是否是@tech{S-expression}。}

@subsection{发送消息}

世界程序中每个返回世界的（用于处理时钟滴答事件、键盘事件和鼠标事件的）回调，
除了返回@|WorldState|之外还可以返回@tech{Package}：

@deftech{HandlerResult}是下列之一：
@itemize[
@item{@|WorldState|}
@item{@tech{Package}}
]
其中@deftech{Package}表示序对，由@|WorldState|和从@tech{世界}程序到@tech{服务器}的消息组成。
因为程序只通过@tech{Package}发送消息，所以本教学包只提该供结构体的构造函数和谓词，不提供选择函数。

@defproc[(package? [x any/c]) boolean?]{
 判断@racket[x]是否是@tech{Package}。}

@defproc[(make-package [w any/c][m sexp?]) package?]{
 用@|WorldState|和@tech{S-expression}创建@tech{Package}。}

回想一下，事件处理程序返回@tech[#:tag-prefixes'("universe")]{HandlerResult}，而我们刚刚改进了这个数据定义。
因此，处理程序即可以返回@|WorldState|，也可以返回@tech{Package}。如果事件处理程序返回@tech{Package}，
那么其中world字段的内容将成为下一个世界，而message字段将指定世界向宇宙所发送的内容。
这个区别也解释了为什么@|WorldState|的数据定义不包含@tech{Package}。

@subsection{连接到宇宙}

消息被发送往宇宙程序，它运行于现实中的某台计算机之上。下一节会介绍创建此类宇宙服务器的构造。
现在，我们只需要知道它存在并且是消息的接收者。

@deftech{IP} @racket[string?]

在世界程序可以发送消息之前，它必须先注册到服务器。注册必须指定运行服务器的计算机的Internet地址，
也称为@tech{IP}地址或网址。这里@tech{IP}地址是格式正确的字符串，
例如@racket["192.168.1.1"]或@racket["www.google.com"]。

@defthing[LOCALHOST string?]{
本机的@tech{IP}。在开发分布式程序时，尤其是在调查参与的世界程序是否以正确的方式进行协作时，
可以使用它。这被称为@emph{集成测试}，与单元测试有很大不同。}

如果世界程序需要与其他程序通信，那么@racket[big-bang]描述必须包含以下形式之一的@racket[register]子句：

@itemize[

@item{
@defform[(register ip-expr) #:contracts ([ip-expr string?])]{
将此世界连接到指定@racket[ip-expr]地址的宇宙服务器，并设置发送和接收消息的功能。
如果世界描述包括形如@racket[(name SomeString)]或@racket[(name SomeSymbol)]的名称规范，
那么一并将世界的名称发送给服务器。
}}

@item{
@defform[(port port-expr) #:contracts ([port-expr natural-number/c])]{
指定世界接收和发送消息所用的端口。端口号是@racket[0]到@racket[65536]之间的整数。
}}
]

当世界程序注册到宇宙程序，之后宇宙程序停止工作时，世界程序也会停止工作。

@subsection{接收消息}

最后，从服务器接收消息是个事件，就和滴答事件、键盘事件及鼠标事件一样。
处理收到的消息与处理任何其他事件完全相同。DrRacket会调用世界程序指定的事件处理程序；
如果没有这样的子句，那么丢弃该消息。

@racket[big-bang]的@racket[on-receive]子句指定消息接收事件的处理程序。

@defform[(on-receive receive-expr)
         #:contracts
         ([receive-expr (-> (unsyntax @|WorldState|) sexp? (unsyntax @tech[#:tag-prefixes '("universe")]{HandlerResult}))])]{
告诉DrRacket每当收到消息时，对当前@|WorldState|和收到的消息调用@racket[receive-expr]。
调用的结果成为当前@|WorldState|。

因为@racket[receive-expr]是（或计算为）返回世界的函数，它不仅可以返回@|WorldState|，
也可以返回@tech{Package}。如果结果是@tech{Package}，其中的消息内容会被发送往@tech{server}。}

下图以图形形式总结了本节中的扩展。

@image["universe.png"]

只要事件处理程序返回@tech{Package}，注册过的世界程序随时可以向宇宙服务器发送消息。
该消息被发送往服务器，服务器可以将其原样转发给另一个世界程序，或以修改后发送。
消息的到来只是世界程序必须处理的另一种事件。与所有其他事件处理程序一样，
@emph{receive}读入@|WorldState|和一些辅助参数（在这里就是消息），
返回@|WorldState|或@tech{Package}。

当消息从任何世界发送到宇宙、或宇宙发送到世界时，发送者和接收者都无需同步。
实际上，发送方可以根据需要发送尽可能多的消息，而不管接收方是否已经处理过它们。
消息只是在队列中等待，直到接收@tech{服务器}或@tech{世界}程序处理它们。

@; -----------------------------------------------------------------------------
@section[#:tag "universe-server"]{宇宙服务器}

@deftech{服务器}是@tech{宇宙}的中央控制程序，用于在参与@tech{宇宙}的世界程序之间接收和发送消息。
和@tech{世界}程序一样，服务器是对事件做出反应的程序，区别在于事件不同于@tech{世界}程序。
主要的两种事件是@tech{宇宙}中新出现的@tech{世界}程序、以及收到的来自@tech{世界}程序的消息。

本教学包提供了为服务器指定事件处理程序的机制，与描述@tech{世界}程序的机制非常相似。
根据指定的事件处理程序，服务器可以执行不同的角色：

@itemize[

@item{服务器可以是两个世界之间的“通信”通道，在这种情况下，
除了将从一个世界接收的任何消息传送到另一个世界之外，它没有任何其他功能，也不进行任何干扰。}

@item{服务器可以强制执行“一来一往”协议，即它可以迫使两个（或多个）世界参与文明的、针锋相对的交换。
每个世界都有机会发送消息，然后再次发送任何内容之前必须等待回复。}

@item{服务器可以扮演专用仲裁者的角色，例如游戏的裁判或管理员。
它可以检查每个世界是否按规则“进行”，并且管理游戏的资源。}

]

事实上，通信@tech{服务器}基本上是不可见的，
看起来好像所有通信都是从@tech{宇宙}中对等@tech{世界}到@tech{世界}。

本节首先介绍@tech{服务器}用于表示@tech{世界}和其他事项的一些基本数据形式。
接下来解释了如何描述服务器程序。

@; -----------------------------------------------------------------------------
@subsection{世界与消息}

要理解服务器的事件处理函数，需要用到几种数据表示：@tech{世界}程序（的连接），以及事件处理程序的响应。

@itemize[

@item{@tech{服务器}及其事件处理程序必须就参与宇宙的@tech{世界}的数据表示达成一致。

@defproc[(iworld? [x any/c]) boolean?]{
判断@racket[x]是否是@emph{iworld}。由于宇宙服务器使用收集关于连接基本信息的结构体来表示世界，
因此本教学包不export任何世界的构造函数或选择函数。}

@defproc[(iworld=? [u iworld?][v iworld?]) boolean?]{
 比较两个@emph{iworld}是否相等。}

@defproc[(iworld-name [w iworld?]) (or/c symbol? string?)]{
 从@emph{iworld}结构体中提取名称。}

@defthing[iworld1 iworld?]{用于测试程序的@emph{iworld}}
@defthing[iworld2 iworld?]{另一个用于测试程序的iworld}
@defthing[iworld3 iworld?]{第三个}

提供这三个示例iworld的目的是方便你测试宇宙程序中的函数。例如：

@racketblock[
(check-expect (iworld=? iworld1 iworld2) #false)
(check-expect (iworld=? iworld2 iworld2) #true)
]
}

@item{每个事件处理程序要么返回宇宙的状态，要么返回@emph{bundle}结构体，
其中包含@tech{服务器}的状态、送往其他世界的邮件的表，以及要断开连接的@emph{iworld}的表。

@defproc[(bundle? [x any/c]) boolean?]{
 判断@racket[x]是否是@emph{bundle}。}

@defproc[(make-bundle [state any/c] [mails (listof mail?)] [low-to-remove (listof iworld?)]) bundle?]{
用表示服务器状态的数据、邮件的表、和iworld的表创建@emph{bundle}。
 
bundle第三个字段中的iworld表将从等待消息的参与者表中删除。}

如果断开与这些世界的连接导致参与者的表为空，那么宇宙服务器将以初始状态重新启动。

@emph{邮件}表示从事件处理程序到世界的消息。本教学包只为这些结构体提供谓词和构造函数：

@defproc[(mail? [x any/c]) boolean?]{
 判断@racket[x]是否是@emph{邮件}。}

@defproc[(make-mail [to iworld?] [content sexp?]) mail?]{
 用@emph{iworld}和@|S-expression|创建@emph{邮件}。}
}
]

@; -----------------------------------------------------------------------------
@subsection{宇宙的描述}

@tech{服务器}会记录它管理的@tech{宇宙}的信息。一种需要记录的信息显然是参与世界程序的集合，
但一般来说，和@tech{世界}程序一样，服务器记录的信息类型以及信息的表示方式取决于场合和程序员。

@deftech{UniverseState} ：@racket[any/c] 

宇宙服务器的设计要求为所有可能的服务器状态提供数据定义。要运行@tech{宇宙}，
本教学包要求提供@tech{服务器}（状态）的数据定义。任何数据都可以代表状态。
我们假设已经为可能的状态引入了数据定义，并且事件处理程序是按照此数据定义的设计诀窍设计的。

@tech{服务器}本身是使用描述创建的，该描述包含初始状态以及多个子句，子句指定处理@tech{宇宙}事件的函数。

@defform/subs[#:id universe
              #:literals
              (on-new on-msg on-tick on-disconnect to-string check-with port state)
              (universe state-expr clause ...)
              ([clause
                 (on-new new-expr)
                 (on-msg msg-expr)
                 (on-tick tick-expr)
                 (on-tick tick-expr rate-expr)
                 (on-tick tick-expr rate-expr limit-expr)
                 (on-disconnect dis-expr)
                 (state expr)
                 (to-string render-expr)
		 (port port-expr)
                 (check-with universe?-expr)
                 ])]{

用给定的状态@racket[state-expr]创建服务器。其行为由必要和可选@emph{子句}通过处理函数指定。
这些函数控制服务器如何处理新世界的注册、如何断开世界、如何将消息从一个世界发送到其他注册的世界，
以及如何将其当前状态呈现为字符串。}

对@racket[universe]表达式求值会启动服务器。在视觉上它会打开一个控制台窗口，
可以在其中看到世界的加入、从哪个世界接收哪些消息、以及哪些消息被发送到哪个世界。
过长的邮件在显示之前会被截断。

为方便起见，控制台还有两个按钮：一个用于关闭宇宙，另一个用于重新启动它。
后者在集成分布式程序的各个部分期间特别有用。

@racket[universe]服务器描述的必要子句是@racket[on-new]和@racket[on-msg]：

@itemize[

@item{
 @defform[(on-new new-expr)
          #:contracts
          ([new-expr (-> (unsyntax @tech{UniverseState}) iworld? (or/c (unsyntax @tech{UniverseState}) bundle?))])]{
告诉DrRacket每当另一个世界加入宇宙时，调用@racket[new-expr]函数。用当前状态和加入的iworld来调用事件处理程序，该iworld还不表中。
特别地，处理程序可以拒绝某个@tech{世界}程序参与@tech{宇宙}，方式是简单地返回输入状态、或将新世界放入返回的@racket[bundle]结构体的第三字段中。

@history[
 #:changed 
 "1.1" 
 "允许宇宙处理程序返回宇宙状态"]

}}

@item{
 @defform[(on-msg msg-expr)
          #:contracts
          ([msg-expr (-> (unsyntax @tech{UniverseState}) iworld? sexp? (or/c (unsyntax @tech{UniverseState}) bundle?))])]{
告诉DrRacket将@racket[msg-expr]应用于宇宙的当前状态、发送消息的世界@racket[w]以及消息本身。

@history[
 #:changed 
 "1.1" 
 "允许宇宙处理程序返回宇宙状态"]

}

}]
合法的事件处理程序要么返回宇宙状态，要么返回一个@emph{bundle}。服务器对宇宙的状态进行安全保护，直到下一个事件，
并且会按指定的方式发送邮件。bundle第三个字段中的iworld表将从等待消息的参与者表中删除。

下图提供了服务器工作的图形概述。

@; -----------------------------------------------------------------------------
@;; THE PICTURE IS WRONG
@; -----------------------------------------------------------------------------

@image["server.png"]

除了必要处理程序之外，程序还能使用一些可选的处理程序：

@itemize[

@item{
@defform/none[#:literals (on-tick)
              (on-tick tick-expr)
              #:contracts
              ([tick-expr (-> (unsyntax @tech{UniverseState}) (or/c (unsyntax @tech{UniverseState}) bundle?))])]{
 告诉DrRacket将@racket[tick-expr]应用于宇宙的当前状态。

@history[
 #:changed 
 "1.1" 
 "允许宇宙处理程序返回宇宙状态"]
}

@defform/none[#:literals (on-tick)
              (on-tick tick-expr rate-expr)
              #:contracts
              ([tick-expr (-> (unsyntax @tech{UniverseState}) (or/c (unsyntax @tech{UniverseState}) bundle?))]
               [rate-expr (and/c real? positive?)])]{
 告诉DrRacket如前所述调用@racket[tick-expr]；时钟每@racket[rate-expr]秒滴答一次。

@history[
 #:changed 
 "1.1" 
 "允许宇宙处理程序返回宇宙状态"]

}

@defform/none[#:literals (on-tick)
              (on-tick tick-expr rate-expr)
              #:contracts
              ([tick-expr (-> (unsyntax @tech{UniverseState}) (or/c (unsyntax @tech{UniverseState}) bundle?))]
               [rate-expr (and/c real? positive?)]
               [limit-expr (and/c integer? positive?)])]{
告诉DrRacket如前所述调用@racket[tick-expr]；时钟每@racket[rate-expr]秒滴答一次。
当时钟滴答次数超过@scheme[limit-expr]时，宇宙停止。

@history[
 #:changed 
 "1.1" 
 "允许宇宙处理程序返回宇宙状态"]
}
}

@item{
 @defform[#:literals (on-disconnect)
	  (on-disconnect dis-expr)
          #:contracts
          ([dis-expr (-> (unsyntax @tech{UniverseState}) iworld? (or/c (unsyntax @tech{UniverseState}) bundle?))])]{
告诉DrRacket每当参与的@tech{世界}都断开与服务器的连接时，调用@racket[dis-expr]。
第一个参数是宇宙服务器的当前状态，而第二个参数是断开连接的世界（的表示）。
返回的bundle通常在第三个字段中包含第二个参数，告诉DrRacket不再等待来自这个世界的消息。

@history[
 #:changed 
 "1.1" 
 "允许宇宙处理程序返回宇宙状态"]
}
}

@item{
@defform/none[#:literals (port)
              (port port-expr) 
	      #:contracts 
	      ([port-expr natural-number/c])]{
 指定宇宙接收和发送消息的端口。端口号是@racket[0]到@racket[65536]之间的整数。
}}

@item{
 @defform[(to-string render-expr)
          #:contracts
          ([render-expr (-> (unsyntax @tech{UniverseState}) string?)])]{
 告诉DrRacket在每个事件之后呈现宇宙的状态，并在宇宙控制台中显示该字符串。
 }
}

@item{
 @defform/none[#:literals (check-with)
               (check-with universe?-expr)
          #:contracts
          ([universe?-expr (-> Any boolean?)])]{
 确保事件处理程序返回的确实是@tech{UniverseState}的元素。}
}

@item{
@defform/none[#:literals (state) (state expr)]{
 如果不是#f，DrRacket会打开一个单独的窗口，每次更新时都会呈现当前状态。这对于调试服务器程序非常有用。
}}

]

@subsection{探索宇宙}

为了探索宇宙的运作，有必要在同一台计算机上启动服务器和几个世界程序。
我们推荐从DrRacket的一个标签中启动服务器，然后从第二个标签中根据需要启动多个世界。
对于后者的操作，本教学包提供了一种特殊的（语法）形式。

@defform[(launch-many-worlds expression ...)]{
并行地计算所有子表达式。通常，每个子表达式都是计算@racket[big-bang]表达式的函数调用。
当所有世界都停止时，该表达式将按顺序返回所有的最终世界。}

设计完世界程序后，在标签的末尾添加一个关于@racket[big-bang]的函数定义：
@(begin
#reader scribble/comment-reader
(racketblock
;; String -> World
(define (main n)
  (big-bang ... (name n) ...))
))
然后在DrRacket的交互区中，使用@racket[launch-many-worlds]创建几个不同命名的世界：
@(begin
#reader scribble/comment-reader
(racketblock
> (launch-many-worlds (main "matthew")
                      (main "kathi")
                      (main "h3"))
10
25
33
))
接下来这三个世界可以通过服务器进行交互。
当所有这些都停止时，它们会返回最终状态，例如@racket[10]、@racket[25]和@racket[33]。

对于高级程序员，本库还提供了一个用于并行启动多个世界的编程接口。

@defproc[(launch-many-worlds/proc [thunk-that-runs-a-world (-> any/c)] ...)
          (values any @#,racketfont{...})]{
并行调用所有给定的@racket[thunk-that-runs-a-world]。通常，每个参数都是无参数的函数，
计算一个@racket[big-bang]表达式。当所有世界都停止时，本函数表达式按顺序返回所有的最终世界。}

因此，可以在运行时决定并行运行哪些世界，运行多少个：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
> (apply launch-many-worlds/proc
         (build-list (random 10)
                     (lambda (i)
                       (lambda ()
                         (main (number->string i))))))
0
9
1
2
3
6
5
4
8
7
))
@;%



@; -----------------------------------------------------------------------------
@section[#:tag "universe-sample"]{第一个宇宙的例子} 

本节使用一个简单的例子来解释宇宙的设计，@margin-note*{这里的代码使用“中级+lambda”语言。}
尤其是其服务器和参与的世界的设计。第一小节解释这个例子，第二小节介绍这些宇宙的总体设计方案。
后续小节介绍完整的解决方案。

@subsection{两个扔球的世界}

假设我们想要表示一个由多个世界组成的宇宙，以循环的方式为每个世界提供一个“轮次”。如果轮到一个世界，
它会显示从画布底部上升到顶部的球。然后它交出自己的轮次，由服务器转交给下一个世界。

这是一个图像，说明如果有两个世界参与，这个宇宙将如何运作：

@image["balls" #:suffixes '(".gif" ".png")]

两个@tech{世界}程序可以位于两台不同的计算机上，也可以只位于一台计算机上。
@tech{服务器}负责协调两个世界，包括最初的启动。

@; -----------------------------------------------------------------------------
@subsection{关于设计宇宙的提示}

设计@tech{宇宙}的第一步是从全局视角理解@tech{世界}的协调。在某种程度上，
这关心的是知识和在整个系统中知识的分配。我们知道，在服务器启动并且@tech{世界}加入之前，
@tech{宇宙}不存在。然而，由于计算机和网络的性质，这里不存在别的假设。
我们的网络连接能确保，如果某个@tech{世界}或@tech{服务器}以某种顺序将两条消息发送到同一个地方，
它们会以相同的顺序到达（如果都到达的话）。反之，如果两个不同的@tech{世界}程序各自发送一个消息，
网络不保证到达服务器的顺序；类似地，如果要求@tech{服务器}向几个不同的@tech{世界}程序发送消息，
则它们可以按发送的顺序、或以某种其他顺序到达那些世界。同样，也不可能确保一个世界在另一个世界之前加入。
最糟糕的是，当有人断开运行@tech{世界}程序的计算机与网络其余部分之间的（有线或无线）连接，
或者当网络电缆被切断时，消息不会被送达。出于这种不可预测性，设计者的任务是建立一个协议，
强制宇宙按某个顺序执行，这种活动称为@emph{协议设计}。

从@tech{宇宙}的角度来看，协议设计需要设计跟踪服务器中宇宙及参与世界信息的数据表示，
以及设计消息的数据表示。关于后者，我们知道它们必须是@|S-expression|，
但通常@tech{世界}程序并不会发送所有的@|S-expression|。因此，消息的数据定义必须选择合适的@|S-expression|的子集。
至于服务器和世界的状态，它们必须反映它们目前与宇宙的关系。之后，在设计他们的“本地”行为时，
我们可能会向其状态空间中添加更多组件。

总之，协议设计的第一步是引入：

@itemize[

@item{服务器所记录的关于宇宙信息的数据定义，称之为@tech{UniverseState}；}

@item{关于世界与宇宙当前关系的数据定义；}

@item{从服务器发送到世界的消息的数据定义，以及从世界发送到服务器的消息的数据定义。
我们将前者称为@deftech{S2W}，将后者称为@deftech{W2S}；在最一般的情况下，每个世界可能都需要一对数据定义。}
]

如果所有世界随着时间的推移表现出相同的行为，那么单个数据定义就足以满足步骤2。
如果它们扮演不同的角色，我们可能每个世界需要一个数据定义。

当然，在定义这些数据集合时，请始终牢记数据的含义，以及它们从宇宙角度所代表的含义。

协议设计的第二步是要处理的重大事件——向宇宙添加世界、在服务器或世界中消息的到达——以及它们所导致的消息交换。
反过来说，当服务器向世界发送消息时，这可能对服务器的状态和世界的状态都有影响。可以使用交互图写出这些协议。


@verbatim{

     Server              World1                  World2
       |                   |                       |
       |   'go             |                       |
       |<------------------|                       |
       |    'go            |                       |
       |------------------------------------------>|
       |                   |                       |
       |                   |                       |
}

垂直线是@tech{世界}程序或@tech{服务器}的生命线。水平箭头表示从一个参与@tech{宇宙}者发送到另一个的消息。

协议的设计，尤其是数据定义，对事件处理函数的设计有直接的影响。例如，在服务器中，
我们可能需要处理两种事件：新世界的加入和接收来自世界之一的消息。这会转换为设计两个头部如下的函数，

@(begin
#reader scribble/comment-reader
(racketblock
;; Bundle是
;;   (make-bundle UniverseState [Listof mail?] [Listof iworld?])

;; UniverseState iworld? -> Bundle
;; 当世界@racket[iw]加入状态为@racket[s]的宇宙时，
;; 宇宙的下一个状态表
(define (add-world s iw) ...)

;; UniverseState iworld? W2U -> Bundle
;; 当世界@racket[iw]发送消息@racket[m]给状态为@racket[s]的宇宙时，
;; 宇宙的下一个状态表
(define (process s iw m) ...)
))

最后，我们还必须决定这些消息如何影响各个世界的状态；他们中的哪个回调可以发送消息、何时发送；
以及如何处理世界收到的消息。因为这个步骤很难抽象地解释，所以我们继续讨论球世界宇宙的协议设计。

@; -----------------------------------------------------------------------------
@subsection{球宇宙的设计}

球@tech{宇宙}的运行有一个简单的总体目标：确保在任何时间点，只有一个@tech{世界}是活动的，而所有其他世界都在等待。
活动的@tech{世界}显示一个移动中的球，等待中的@tech{世界}也应该显示一些东西，任何表明不是它的轮次的东西。

至于服务器的状态，它显然必须记录加入@tech{宇宙}的所有@tech{世界}，并且它必须知道哪个@tech{世界}是活动的，
哪些在等待。当然，最初@tech{宇宙}是空的，也就是没有@tech{世界}，那时，服务器没有任何东西可以记录。

虽然有许多不同的方式可以表示这样的@tech{宇宙}，这里我们使用传入每个处理程序的@emph{iworlds}表，
并且处理程序返回它们的bundle。对于这个简单的例子来说，@tech{UniverseState}本身毫无用处。
我们这样解释非空列，第一个@emph{iworld}是活动的，其余的@emph{iworld}在等待。至于两种可能的事件，

@itemize[

@item{将新的@emph{iworld}添加到表的末尾很自然；}

@item{将活动（过）的@emph{iworld}移动到表的末尾也很自然。}
]

既然服务器认为只有其表中的第一个@emph{iworld}是活动的，应向它发送消息。同理，
它应该只会从这个活动的@emph{iworld}接收消息，而非其他@emph{iworld}。
这两种消息的内容几乎无关紧要，因为从服务器到@emph{iworld}的消息意味着该@emph{iworld}的轮次到了，
而从@emph{iworld}到服务器的消息意味着轮次已经结束。为了不要迷惑自己，我们为这两条消息使用两个不同的符号：
@itemize[
@item{@defterm{GoMessage}是@racket['it-is-your-turn]。}
@item{@defterm{StopMessage}是@racket['done]。}
]

从@tech{宇宙}的角度来看，每个@tech{世界}都处于以下两种状态之一：
@itemize[
@item{等待中的@tech{世界}正在@emph{休息}。我们用@racket['resting]表示这个状态。}
@item{活动中的@tech{世界}不再休息。我们先不为这种@tech{世界}选定表示，到设计其“本地”行为时再进行。}
]
 同样显然的是，活动的@tech{世界}可能会收到其他消息，可以将之忽略。当完成自己的轮次时，它会发送一条消息。

@verbatim{
     Server
       |                 World1
       |<==================|
       |  'it-is-your-turn |
       |------------------>|
       |                   |                    World2
       |<==========================================|
       |  'done            |                       |
       |<------------------|                       |
       |  'it-is-your-turn |                       |
       |------------------------------------------>|
       |                   |                       |
       |                   |                       |
       |  'done            |                       |
       |<------------------------------------------|
       |  'it-is-your-turn |                       |
       |------------------>|                       |
       |                   |                       |
       |                   |                       |
}

这里（水平的）双线表示注册步骤，其他水平线则是消息交换。因此，
该图显示了@tech{服务器}决定让第一个注册的世界成为活动的，并在其他世界加入时登记。


@; -----------------------------------------------------------------------------
@subsection{球服务器的设计}

前面一小节说明，我们的服务器程序这样开始：

@(begin
#reader scribble/comment-reader
[racketblock
 (require 2htdp/universe)

;; UniverseState是[Listof iworld?]
;; StopMessage是'done。
;; GoMessage是'it-is-your-turn。
])

协议的设计直接影响服务器事件处理函数的设计。这里我们需要处理两种事件：新世界的出现和消息的接收。
根据我们的数据定义，还有本文档中详述的事件处理函数的一般契约，愿望列表中是这两个函数：

@(begin
#reader scribble/comment-reader
[racketblock
;; Result是
;;   (make-bundle [Listof iworld?]
;;                (list (make-mail iworld? GoMessage))
;;                '())

;; [Listof iworld?] iworld? -> Result
;; 当服务器处于状态@racket[u]时，将世界@racket[iw]添加到宇宙中
(define (add-world u iw) ...)

;; [Listof iworld?] iworld? StopMessage -> Result
;; 当服务器处于状态@racket[u]时，世界@racket[iw]发送消息@racket[m]
(define (switch u iw m) ...)
])

虽然可以重复使用本文档中的通用契约，但我们也从协议中知道，服务器只向一个世界发送消息。
请注意这些契约只是对通用契约的改进。（面向类型的程序员会说，这里的契约是通用契约的子类型。）

设计诀窍的第二步是函数示例：

@(begin
#reader scribble/comment-reader
[racketblock
;; 添加世界的一个明显例子：
(check-expect
  (add-world '() iworld1)
  (make-bundle (list iworld1)
               (list (make-mail iworld1 'it-is-your-turn))
               '()))

;; 从活动世界接收消息的例子：
(check-expect
 (switch (list iworld1 iworld2) iworld1 'done)
 (make-bundle (list iworld2 iworld1)
              (list (make-mail iworld2 'it-is-your-turn))
              '()))
])

请注意，我们的协议分析规定了这两个函数的行为。还请注意，
这里我们使用了@racket[world1]、@racket[world2]和@racket[world3]，
因为教学包会将这些事件处理程序应用于真实的世界。

@bold{习题}：根据我们的协议为这两个函数创建其他示例。

协议告诉我们，@emph{add-world}只是将输入的@emph{世界}结构体——真实@tech{世界}程序的数据表示——添加到输入的世界的表中。
然后它会向此表中的第一个世界发送消息，以使事情开始：

@(begin
#reader scribble/comment-reader
[racketblock
(define (add-world univ wrld)
  (local ((define univ* (append univ (list wrld))))
    (make-bundle univ*
                 (list (make-mail (first univ*) 'it-is-your-turn))
                 '())))
])

因为@emph{univ*}至少包含@emph{wrld}，所以可以创建给@racket[(first univ*)]的邮件。
当然，同样的推理也意味着，如果@emph{univ}不是空的，它的第一个元素就是活动的世界，
并将会收到第二个@racket['it-is-your-turn]消息。

同样地，协议表明由于@tech{世界}程序发送消息而调用@emph{switch}时，
相应世界的数据表示会被移动到表的末尾，并且（结果）表中的下一个世界会被发送消息：

@(begin
#reader scribble/comment-reader
[racketblock
(define (switch univ wrld m)
  (local ((define univ* (append (rest univ) (list (first univ)))))
    (make-bundle univ*
                 (list (make-mail (first univ*) 'it-is-your-turn))
                 '())))
])

和以前一样，将第一个世界附加到表的末尾可以保证此表中至少存在这一个世界。因此，为这个世界创建邮件是可以接受的。

现在启动服务器。

 @racketblock[(universe '() (on-new add-world) (on-msg switch))]

@bold{习题}：函数定义假设了@emph{wrld} @racket[iworld=?]于@racket[(first univ)]，
并且收到的消息@emph{m}是@racket['done]。修改函数定义，检查这些假设，并在其中任何一个错误时抛出错误。
从函数示例开始。如果遇到困难，请重新阅读HtDP关于带检查函数的部分。（注意：在@tech{宇宙}中，
某个程序很可能向@tech{服务器}注册但未能遵守商定的协议。如何正确处理这些情况取决于上下文。这里，
遇到这种情况时停止宇宙，返回空的世界表。也请考虑替代解决方案。）

@bold{习题}：另一种状态表示是将@tech{UniverseState}等同于@emph{世界}结构体，记录活动的世界。
服务器中的世界表仅记录等待中的世界。设计对应的的@racket[add-world]和@racket[switch]函数。

@; -----------------------------------------------------------------------------
@subsection{球世界的设计}

最后一步是设计球@tech{世界}。回想一下，每个@tech{世界}都处于两种可能的状态之一：活动或等待。
前者向上移动小球，减少球的@emph{y}坐标；后者显示说是别人的轮次。
假设球总是沿垂直线移动并且垂直线是固定的，那么世界状态是两种情况的枚举：

@(begin #reader scribble/comment-reader
(racketblock
(require 2htdp/universe)

;; WorldState是以下之一：
;; -- Number             %% 表示@emph{y}坐标
;; -- @racket['resting]

(define WORLD0 'resting)

;; WorldResult是以下之一：
;; -- WorldState
;; -- (make-package WorldState StopMessage)
))
 这个定义表明最初的世界是在等待。

通信协议和改进后的@|WorldState|数据定义决定了契约和目的声明：

@(begin
#reader scribble/comment-reader
(racketblock

;; WorldState GoMessage -> WorldResult
;; 确保球在动
(define (receive w n) ...)

;; WorldState -> WorldResult
;; 每个时钟滴答都向上移动小球
;; 或者返回@racket['resting]
(define (move w) ...)

;; WorldState -> Image
;; 将世界呈现为图像
(define (render w) ...)
))

我们来一次设计一个函数，从@emph{receive}开始。由于协议没有说明@emph{receive}计算的内容，
让我们利用@|WorldState|的数据组织结构来创建一组合理的函数示例：

@(begin
#reader scribble/comment-reader
(racketblock
(check-expect (receive 'resting 'it-is-your-turn) HEIGHT)
(check-expect (receive (- HEIGHT 1) 'it-is-your-turn) ...)
))

由于存在两种状态，我们至少需要编写两种例子：一种用于@racket['resting]状态，另一种用于数值状态。
第二单元测试的结果部分中的点揭示了第一个模糊性；具体而言，当活动@tech{世界}收到另一条激活自身的消息时，
不清楚结果应该是什么。当我们研究其他例子，设计处理数值区间的函数时（HtDP，第4章）会出现第二个模糊性。
也就是，我们应该考虑@emph{receive}的以下三种输入：

@itemize[
@item{@racket[HEIGHT]，当小球位于图像的底部时；}
@item{@racket[(- HEIGHT 1)]，当小球严格位于图像之内时；}
@item{@racket[0]，当小球碰到图像顶部时。}
]

在第三种情况下，该函数可以返回三个不同的结果：@racket[0]、@racket['resting]或@racket[(make-package 'resting
'done)]。第一个做法保持一切不变；第二个将活动的@tech{世界}变为静止的；第三个也会这样做，同时告知宇宙这一变化。

我们这样设计@emph{receive}，它忽略消息并返回活动@tech{世界}的当前状态。这确保了球以连续的方式移动，并且@tech{世界}保持活跃。

@bold{习题}：另一种设计是，每次收到@racket['it-is-your-turn]时将球移回图像的底部。请设计这个函数。

@(begin
#reader scribble/comment-reader
(racketblock

(define (receive w m)
  (cond
    [(symbol? w) HEIGHT] ;; 含义：@racket[(symbol=? w 'resting)]
    [else w]))
))

来设计第二个函数@emph{move}，它计算小球的移动。我们已经有契约了，设计诀窍的第二步要求例子：

@(begin
#reader scribble/comment-reader
(racketblock
; WorldState -> WorldState or @racket[(make-package 'resting 'done)]
; 移动小球，如果它在飞的话

(check-expect (move 'resting) 'resting)
(check-expect (move HEIGHT) (- HEIGHT 1))
(check-expect (move (- HEIGHT 1)) (- HEIGHT 2))
(check-expect (move 0) (make-package 'resting 'done))

(define (move x) ...)
))

还是遵从HtDP进行，这些例子涵盖了四种典型情况：@racket['resting]、指定数字区间的两个终点和一个内点。
它们表明，@emph{move}保留等待中的@tech{世界}不变，否则它会移动小球直到@emph{y}坐标变为@racket[0]。
对于后一种情况，返回是使@tech{世界}停止并告知服务器的package。

将这些想法转化为完整的定义现在很简单：

@(begin
#reader scribble/comment-reader
(racketblock
(define (move x)
  (cond
    [(symbol? x) x]
    [(number? x) (if (<= x 0)
                     (make-package 'resting 'done)
                     (sub1 x))]))
))

@bold{习题}：如果我们这样设计@emph{receive}——当世界的状态是@racket[0]时它返回@racket['resting]——会发生什么？
使用这里的答案解释，为什么你认为将此类状态更改留给滴答事件处理程序、而不是消息接收处理程序更合适？

最后是第三个函数，它将状态呈现为图像：

@(begin
#reader scribble/comment-reader
(racketblock
; String -> (WorldState -> Image)
; 将世界的状态呈现为图像

(check-expect
 ((draw "Carl") 100)
 (underlay/xy (underlay/xy MT 50 100 BALL)
              5 85
              (text "Carl" 11 "black")))

(define (draw name)
  (lambda (w)
    (overlay/xy
     (cond
       [(symbol? w) (underlay/xy MT 10 10 (text "resting" 11 "red"))]
       [(number? w) (underlay/xy MT 50 w BALL)])
     5 85
     (text name 11 'black))))

))

这样做的话，我们就可以使用相同的程序创建许多不同的@tech{世界}，都注册于本地计算机的@tech{服务器}：
@(begin
#reader scribble/comment-reader
(racketblock

; String -> WorldState
; 创建世界，并连接到@racket[LOCALHOST]服务器
(define (create-world name)
  (big-bang WORLD0
   (on-receive receive)
   (to-draw    (draw n))
   (on-tick    move)
   (name       name)
   (register   LOCALHOST)))
))

现在先启动@tech{服务器}，然后可以分别使用@racket[(create-world 'carl)]和@racket[(create-world 'sam)]来运行两个不同的世界。
您可能希望在这里使用@racket[launch-many-worlds]。

@bold{习题}：设计函数，能够处理宇宙和世界失去联系的情况。@emph{Result}是否是此函数正确的契约？
