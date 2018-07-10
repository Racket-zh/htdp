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
保证至少提供这六种颜色。如果需要其他颜色，请猜测！例如，@racket['orange]有效，但是@racket['mauve]无效。如果使用不认识的颜色调用（绘图）函数，会抛出错误。

@defproc[(start [width number?][height number?]) true]{
 打开@racket[width]乘@racket[height]的画布。} 

@defproc[(start/cartesian-plane [width number?][height number?])
         true]{
Opens a @racket[width] x @racket[height] canvas and draws a Cartesian
plane.}

@defproc[(stop) true]{Closes the canvas.}

@defproc[(draw-circle [p posn?] [r number?] [c (unsyntax @tech{DrawColor})])
         true]{
Draws a @racket[c] circle at @racket[p] with radius @racket[r].}

@defproc[(draw-solid-disk [p posn?] [r number?] [c (unsyntax @tech{DrawColor})])
         true]{
Draws a @racket[c] disk at @racket[p] with radius @racket[r].}

@defproc[(draw-solid-rect [ul posn?] [width number?] [height number?]
                          [c (unsyntax @tech{DrawColor})])
         true]{
Draws a @racket[width] x @racket[height], @racket[c] rectangle with the
upper-left corner at @racket[ul].}

@defproc[(draw-solid-line [strt posn?] [end posn?]
                          [c (unsyntax @tech{DrawColor})])
         true]{
Draws a @racket[c] line from @racket[strt] to @racket[end].}

@defproc[(draw-solid-string [p posn?] [s string?]) true]{
Draws @racket[s] at @racket[p].}

@defproc[(sleep-for-a-while [s number?]) true]{
Suspends evaluation for @racket[s] seconds.}

The teachpack also provides @racket[clear-] functions for each
@racket[draw-] function:

@defproc[(clear-circle [p posn?] [r number?] [c (unsyntax @tech{DrawColor})])
         true]{
clears a @racket[c] circle at @racket[p] with radius @racket[r].}

@defproc[(clear-solid-disk [p posn?] [r number?] [c (unsyntax @tech{DrawColor})])
         true]{
clears a @racket[c] disk at @racket[p] with radius @racket[r].}

@defproc[(clear-solid-rect [ul posn?] [width number?] [height number?]
                          [c (unsyntax @tech{DrawColor})])
         true]{
clears a @racket[width] x @racket[height], @racket[c] rectangle with the
upper-left corner at @racket[ul].}

@defproc[(clear-solid-line [strt posn?] [end posn?]
                          [c (unsyntax @tech{DrawColor})])
         true]{
clears a @racket[c] line from @racket[strt] to @racket[end].}

@defproc[(clear-solid-string [p posn?] [s string?]) true]{
 clears @racket[s] at @racket[p].}

@defproc[(clear-all) true]{
 clears the entire screen.}

@;-----------------------------------------------------------------------------
@section[#:tag "interaction"]{Interactions with Canvas}

@defproc[(wait-for-mouse-click) posn?]{
Waits for the user to click on the mouse, within the canvas.}

@deftech{DrawKeyEvent}: @racket[(or/c char? symbol?)] A
@tech{DrawKeyEvent} represents keyboard events: 
@itemize[
 @item{@racket[char?], if the user pressed an alphanumeric key;}
 @item{@racket[symbol?], if the user pressed, for example, an arror key:
 @racket['up] @racket['down]  @racket['left] @racket['right]}
]

@defproc[(get-key-event) (or/c false (unsyntax @tech{DrawKeyEvent}))]{Checks whether the
user has pressed a key within the window; @racket[false] if not.}

@deftech{DrawWorld}: For proper interactions, using the teachpack
 requires that you provide a data definition for @tech{DrawWorld} . In
 principle, there are no constraints on this data definition. You can even
 keep it implicit, even if this violates the Design Recipe.

The following functions allow programs to react to events from the canvas.

@defproc[(big-bang [n number?] [w (unsyntax @tech{DrawWorld})]) true]{Starts the clock, one tick every
@racket[n] (fractal) seconds; @racket[w] becomes the first ``current'' world.}

@defproc[(on-key-event [change (-> (unsyntax @tech{DrawKeyEvent}) (unsyntax @tech{DrawWorld}) (unsyntax @tech{DrawWorld}))])
true]{Adds @racket[change] to the world. The function reacts to keyboard
events and creates a new @racket[@#,tech{DrawWorld}].}

@defproc[(on-tick-event [tock (-> (unsyntax @tech{DrawWorld}) (unsyntax @tech{DrawWorld}))]) true]{Adds @racket[tock]
to the world. The function reacts to clock tick events, creating a new
current world.}

@defproc[(end-of-time) (unsyntax @tech{DrawWorld})]{Stops the world; returns the current world.} 
