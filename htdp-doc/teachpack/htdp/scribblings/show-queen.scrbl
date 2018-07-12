#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/show-queen))

@teachpack["show-queen"]{皇后问题}

@;declare-exporting[teachpack/htdp/show-queen]
@defmodule[#:require-form beginner-require htdp/show-queen]

本教学包提供@racket[show-queen]功能，实现了探索n皇后问题的GUI。

@defproc[(show-queen [board (list-of (list-of boolean?))]) true]{
函数@racket[show-queen]读入@racket[board]的描述：布尔值表的表。
每个内层的表必须与外层的表长度相同。@racket[true]对应于皇后所在的位置，
而@racket[false]对应于空方格。该函数什么都不返回。

在@racket[show-queen]打开的GUI窗口中，红色和橙色点显示皇后所在的位置。
绿点显示鼠标光标所在的位置。
威胁绿点的皇后以红色显示，而没有威胁绿点的皇后则以橙色显示。}
