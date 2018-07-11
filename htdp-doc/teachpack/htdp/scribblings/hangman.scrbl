#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/hangman))

@teachpack["hangman"]{刽子手}

@defmodule[#:require-form beginner-require htdp/hangman]

本教学包实现玩@emph{刽子手}游戏所需的回调函数，基于学生设计的（游戏）函数。
玩家猜一个字母，程序会给出答案，表明该字母在被猜单词中出现的次数（如果出现的话）。

@defproc[(hangman [make-word (-> symbol? symbol? symbol? word?)][reveal (-> word? word? word?)][draw-next-part (-> symbol? true)]) true]{
选择一个“秘密的”三字母（被猜）单词，然后使用输入的函数来管理@emph{刽子手}游戏。}

@defproc[(hangman-list
	   [reveal-for-list (-> symbol? (list-of symbol?) (list-of symbol?)
			        (list-of symbol?))]
	   [draw-next-part (-> symbol? true)]) true]{
选择一个“秘密的”（被猜）单词——符号字母的表——然后使用输入的函数来管理@emph{刽子手}游戏：
@racket[reveal-for-list]确定所猜字母在单词中出现的次数；
@racket[draw-next-part]读入身体部分的符号名称，并将其绘制在一个单独管理的画布上。
}

此外，本教学包还export绘图库的全部函数；其文档请见@secref{draw}。
