#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/elevator))

@teachpack["elevator"]{控制电梯}

@;declare-exporting[teachpack/htdp/elevator]
@defmodule[#:require-form beginner-require htdp/elevator]

本教程包实现了一个电梯模拟器。

它显示一个八层楼的电梯，接受用户的鼠标点击，并将其转化为电梯的服务需求。

@defproc[(run [NextFloor number?]) any/c]{创建由@racket[NextFloor]控制的电梯模拟器。
该函数读入当前楼层、电梯移动的方向和当前需求。由此，它计算出电梯下一步的位置。} 

例如：定义函数，它读入电梯的当前状态（三个参数），返回1到8之间的数字。这是一个无意义的定义：

@racketblock[(define (controller x y z) 7)]

它将电梯一次移动到7楼。

接下来，将教程包设置为@filepath{elevator.rkt}，单击“运行”，然后计算
@racketblock[(run controller)]
