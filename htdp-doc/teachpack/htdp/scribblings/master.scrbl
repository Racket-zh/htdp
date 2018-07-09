#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/master))

@teachpack["master"]{猜颜色}

@;declare-exporting[teachpack/htdp/master]
@defmodule[#:require-form beginner-require htdp/master]

本教学包实现简单猜颜色游戏的GUI（图形用户界面），基于学生设计的（游戏）函数。玩家点击两种颜色，程序反馈告知猜对了几种颜色，以及它们的位置。

@defproc[(master [check-guess (-> symbol? symbol? symbol? symbol? boolean?)]) symbol?]{
选择两种“秘密的”颜色，然后打开@emph{猜颜色}游戏的图形用户界面。提示用户通过选择面板点击鼠标选择两种颜色。用户选择之后，@racket[master]使用@racket[check-guess]来比较它们。

如果猜测和两个秘密颜色完全匹配，@racket[check-guess]必须返回@racket['PerfectGuess]；不然的话，它必须返回某个符号告知对应信息。}
