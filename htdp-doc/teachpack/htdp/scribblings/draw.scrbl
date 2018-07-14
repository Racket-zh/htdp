#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/draw))

@teachpack["draw"]{简单的绘图}

@;declare-exporting[teachpack/htdp/draw]
@defmodule[#:require-form beginner-require htdp/draw #:use-sources (htdp/big-draw htdp/draw)]

本教学包提供两类函数：一类用于绘制画布，另一类用于对画布事件做出反应。

@deprecated[(list @racketmodname[2htdp/image] "（可能与" @racketmodname[2htdp/universe] "结合）")]{
  你可以继续配合@emph{《程序设计方法》第一版}使用本库，但请考虑换用@link["http://www.ccs.neu.edu/home/matthias/HtDP2e/"]{《程序设计方法》第二版}。}

@section[#:tag "drawing"]{在画布上绘图}

@deftech{DrawColor}: @racket[(and/c symbol? (one-of/c 'white 'yellow 'red 'blue 'green 'black))]
保证至少提供这六种颜色。如果需要其他颜色，请猜测！例如，@racket['orange]有效，
但是@racket['mauve]无效。如果使用不认识的颜色调用（绘图）函数，会抛出错误。

@defproc[(start [width number?][height number?]) true]{
 打开@racket[width]乘@racket[height]的画布。} 

@defproc[(start/cartesian-plane [width number?][height number?])
         true]{
打开@racket[width]乘@racket[height]的画布并绘制笛卡尔平面。}

@defproc[(stop) true]{关闭画布。}

@defproc[(draw-circle [p posn?] [r number?] [c (unsyntax @tech{DrawColor})])
         true]{
在@racket[p]处绘制半径为@racket[r]的@racket[c]颜色圆。}

@defproc[(draw-solid-disk [p posn?] [r number?] [c (unsyntax @tech{DrawColor})])
         true]{
在@racket[p]处绘制半径为@racket[r]的@racket[c]颜色圆盘。}

@defproc[(draw-solid-rect [ul posn?] [width number?] [height number?]
                          [c (unsyntax @tech{DrawColor})])
         true]{
绘制左上角位于@racket[ul]、@racket[width]乘@racket[height]、@racket[c]颜色矩形。}

@defproc[(draw-solid-line [strt posn?] [end posn?]
                          [c (unsyntax @tech{DrawColor})])
         true]{
绘制从@racket[strt]到@racket[end]的@racket[c]颜色线。}

@defproc[(draw-solid-string [p posn?] [s string?]) true]{
在@racket[p]位置绘制@racket[s]。}

@defproc[(sleep-for-a-while [s number?]) true]{
暂停求值@racket[s]秒。}

对于每个@racket[draw-]（绘制）函数，教学包也提供对应的@racket[clear-]（清除）函数：

@defproc[(clear-circle [p posn?] [r number?] [c (unsyntax @tech{DrawColor})])
         true]{
清除@racket[p]处、半径为@racket[r]的@racket[c]颜色圆。}

@defproc[(clear-solid-disk [p posn?] [r number?] [c (unsyntax @tech{DrawColor})])
         true]{
清除@racket[p]处、半径为@racket[r]的@racket[c]颜色圆盘。}

@defproc[(clear-solid-rect [ul posn?] [width number?] [height number?]
                          [c (unsyntax @tech{DrawColor})])
         true]{
清除左上角位于@racket[ul]、@racket[width]乘@racket[height]、@racket[c]颜色矩形。}

@defproc[(clear-solid-line [strt posn?] [end posn?]
                          [c (unsyntax @tech{DrawColor})])
         true]{
清除从@racket[strt]到@racket[end]的@racket[c]颜色线。}

@defproc[(clear-solid-string [p posn?] [s string?]) true]{
 清除@racket[p]位置的@racket[s]。}

@defproc[(clear-all) true]{
 清除整个屏幕。}

@;-----------------------------------------------------------------------------
@section[#:tag "interaction"]{与画布的交互}

@defproc[(wait-for-mouse-click) posn?]{
等待用户在画布中单击鼠标。}

@deftech{DrawKeyEvent}: @racket[(or/c char? symbol?)] A
@tech{DrawKeyEvent}表示键盘事件：
@itemize[
 @item{@racket[char?]，如果用户按下字母或数字键；}
 @item{@racket[symbol?]，如果用户按下，比如说方向键：
 @racket['up] @racket['down]  @racket['left] @racket['right]}
]

@defproc[(get-key-event) (or/c false (unsyntax @tech{DrawKeyEvent}))]{
检查用户是否在窗口中按了键；如果没有则返回@racket[false]。}

@deftech{DrawWorld}：为了能正确的进行交互，使用本教学包需要你提供@tech{DrawWorld}的数据定义。
原则上，此数据定义没有任何限制。你甚至可以隐式地定义，即使这违反了设计诀窍。

以下函数允许程序对画布中的事件做出反应。

@defproc[(big-bang [n number?] [w (unsyntax @tech{DrawWorld})]) true]{开始计时，
每@racket[n]（可以是分数）秒钟一次；@racket[w]是第一个“当前”世界。}

@defproc[(on-key-event [change (-> (unsyntax @tech{DrawKeyEvent}) (unsyntax @tech{DrawWorld}) (unsyntax @tech{DrawWorld}))])
true]{将@racket[change]加到世界中。该函数对键盘事件做出反应并创建新的@racket[@#,tech{DrawWorld}]。}

@defproc[(on-tick-event [tock (-> (unsyntax @tech{DrawWorld}) (unsyntax @tech{DrawWorld}))]) true]{
将@racket[tock]加到世界中。该函数对时钟滴答事件做出反应，创建新的当前世界。}

@defproc[(end-of-time) (unsyntax @tech{DrawWorld})]{停止世界；返回当前世界。} 
