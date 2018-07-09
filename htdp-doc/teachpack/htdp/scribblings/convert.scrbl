#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/convert))

@teachpack["convert"]{温度转换}

@;declare-exporting[teachpack/htdp/convert]
@defmodule[#:require-form beginner-require htdp/convert]

教学包@racket[convert.rkt]提供三个函数，将华氏温度转换为摄氏温度。HtDP中的一个习题需要用到这些。本教学包的目的是，表明“形式”（用户界面）和“功能”（也称为“模型”）相互独立。

@defproc[(convert-gui [convert (-> number? number?)]) true]{
 读入从华氏温度到摄氏温度的转换函数，创建包含两个标尺的图形用户界面，用户可以使用界面和输入的转换函数进行温度转换。
}

@defproc[(convert-repl [convert (-> number? number?)]) true]{
 读入从华氏温度到摄氏温度的转换函数，然后启动读取—计算—打印循环（repl）。循环提示用户输入一个数，然后使用输入的温度转换函数转换该数。用户可以通过输入“x”退出循环。
}

@defproc[(convert-file [in string?][convert (-> number? number?)][out string?]) true]{
 读入文件名@racket[in]、从华氏温度到摄氏温度的转换函数，以及字符串@racket[out]。程序读入@racket[in]中所有的数，使用@racket[convert]转换，再向新创建的文件@racket[out]打印所有结果。

@bold{警告}：如果@racket[out]已存在，它将被删除。}

示例：使用计算机上的文本编辑器创建名为@racket["in.dat"]的文件，其中包含一些数字。在定义窗口中定义函数@racket[f2c]，将教学包设置为@filepath{convert.rkt}后单击运行。接下来运行
@(begin
#reader scribble/comment-reader
(racketblock
 (convert-gui f2c)
 ;; 和 
 (convert-file "in.dat" f2c "out.dat")
 ;; 和 
 (convert-repl f2c)
))
最后检查文件@racket["out.dat"]并使用repl检查答案。
