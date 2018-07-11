#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label (except-in racket/base file-size 
	               make-date
		       date-year
		       date-month
		       date-day)
                     teachpack/htdp/dir
                     racket/contract))

@teachpack["dir"]{使用文件和目录}

@;declare-exporting[teachpack/htdp/dir]
@defmodule[#:require-form beginner-require htdp/dir]

本教学包提供处理文件和目录的结构体和函数：

@defstruct[dir ([name (or/c string? symbol?)][dirs (listof dir?)][files (listof file?)])]{
 表示教学语言中的目录（文件夹）。
}

@defstruct[file ([name (or/c string? symbol?)][size integer?] [date (or/c 0 date?)] [content any/c])]{	
 表示教学语言中的文件。结构体的@racket[date]（日期）字段(对于用户来说)是可选的。
 使用三个参数调用@racket[make-field]时，时间字段就填入@racket[0]。}

@defproc[(create-dir [path string?]) dir?]{
 将计算机@racket[path]路径上找到的目录转换为@racket[dir]实例。}

@defstruct[date ([year natural-number/c][month natural-number/c][day natural-number/c]
		 [hours natural-number/c][minutes natural-number/c][seconds natural-number/c])]{
 表示（用于文件的）日期。}

示例：将教学包设为@filepath{dir.rkt}，或将@racket[(require
htdp/dir)]添加到定义区。单击“运行”，然后查询当前目录的内容，可以得到这样的结果：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
> (create-dir ".")
(make-dir
  "."
  '()
  (cons (make-file "arrow.scrbl" 1897 (make-date 15 1 15 11 22 21) "")
    (cons (make-file "convert.scrbl" 2071 (make-date 15 1 15 11 22 21) "")
      (cons (make-file "dir.scrbl" 1587 (make-date 8 7 8 9 23 52) "")
	(cons (make-file "docs.scrbl" 1259 (make-date 15 1 15 11 22 21) "")
	  (cons (make-file "draw.scrbl" 5220 (make-date 15 1 15 11 22 21) "")
	    (cons (make-file "elevator.scrbl" 1110 (make-date 15 1 15 11 22 21) ""))))))))
))
@;%
@racket["."]通常表示程序所在的目录。在这个例子中，目录中包含六个文件、不包含子目录。

@bold{注意} 本库生成字符串形式的文件名，但为了向后兼容，构造函数也接受符号（形式的文件名）。 

@bold{注意} 软链接始终被视为空文件。

@history[
 #:changed "1.4" @list{Fri Jul  8 13:09:13 EDT 2016
 在文件表示中添加可选的date字段，增加字符串作为文件名的表示}

 #:changed "1.0" @list{建于1996年，用于HtDP/1e}
]
