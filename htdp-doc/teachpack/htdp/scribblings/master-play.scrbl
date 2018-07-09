#lang scribble/doc

@(require scribble/manual "shared.rkt" (for-label racket teachpack/htdp/master))

@teachpack["master-play"]{玩猜颜色}

@defmodule[#:require-form beginner-require htdp/master-play]

本教学包实现了（完整的）猜颜色游戏，以便学生可以玩游戏、并了解我们对他们的期望。

@defproc[(go [name symbol?]) true]{
}
