#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/graphing))

@teachpack["graphing"]{函数的图像}

@;declare-exporting[teachpack/htdp/graphing]
@defmodule[#:require-form beginner-require htdp/graphing #:use-sources (htdp/draw)]

本教学包提供两个函数，用于在笛卡尔平面的常规（右上）象限中（两个方向轴的0到10之间）绘制函数：

@defproc[(graph-fun [f (-> number?  number?)][color symbol?]) true]{
用给定的@racket[color]绘制@racket[f]的图像。}

@defproc[(graph-line [line (-> number? number?)][color symbol?]) true]{
用给定的@racket[color]绘制表示直线的函数@racket[line]。} 

有关颜色符号，参见@secref{draw}。 

此外，本教学包还export绘图库的全部函数；其文档请见@secref{draw}。

