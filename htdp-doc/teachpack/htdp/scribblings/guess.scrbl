#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/guess))

@teachpack["guess"]{猜数字}

@;declare-exporting[teachpack/htdp/guess]
@defmodule[#:require-form beginner-require htdp/guess]

本教学包提供和猜数字游戏相关的函数。每个函数都会显示GUI，玩家可以在其中财产某个数字或数位，然后检查自己的猜测。更高级的函数要求学生实现游戏的更多部分。

@defproc[(guess-with-gui [check-guess (-> number? number? symbol?)]) true]{
 @racket[check-guess]函数读入两个数：玩家的猜测@racket[guess]和随机生成的被猜测数@racket[target]。返回值是表示玩家猜测成功与否的符号。
}

@defproc[(guess-with-gui-3 [check-guess (-> digit? digit? digit? number? symbol?)]) true]{
 @racket[check-guess]函数读入三个数位（@racket[digit0]，@racket[digit1]和@racket[digit2]），以及数@racket[target]。后者是随机生成的被猜测数；三个数位就是当前的猜测。返回值是表示玩家猜测（将数位转换为数后）成功与否的符号。

 注意：@racket[digit0]是@emph{最低}位，而@racket[digit2]是@emph{最高}位。
}

@defproc[(guess-with-gui-list [check-guess (-> (list-of digit?) number? symbol?)]) true]{
 @racket[check-guess]函数读入数位的表（@racket[digits]）以及数（@racket[target]）。前者是构成玩家猜测的表，而后者是随机生成的被猜测数。返回值是表示玩家猜测（将数位转换为数后）成功与否的符号。

 注意：@racket[digits]表中的第一项是@emph{最低}位，而最后一项是@emph{最高}位。
}
