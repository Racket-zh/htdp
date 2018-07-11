#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/hangman))

@teachpack["hangman-play"]{玩刽子手}

@defmodule[#:require-form beginner-require htdp/hangman-play]

本教学包实现了刽子手游戏，以便学生可以玩游戏并了解我们对他们的期望。

@defproc[(go [name symbol?]) true]{
选择“秘密的”三字母单词，打开画布和菜单，然后要求玩家猜出这个单词。}
