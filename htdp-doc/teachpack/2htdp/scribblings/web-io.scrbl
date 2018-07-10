#lang scribble/manual

@(require "shared.rkt" (for-label racket xml/xml))

@teachpack["web-io"]{网页IO}
@author["Matthias Felleisen" "Racket-zh项目组译"]

@defmodule[#:require-form beginner-require 2htdp/web-io]

本教学包只提供一个函数：

@defproc[(show-in-browser [x xexpr?]) string?]{
 将输入的X表达式转换为字符串。它还具有打开外部浏览器并将X表达式呈现为XHTML的@bold{作用}。

@bold{示例}

@racketblock[(show-in-browser '(html (body (b "hello world"))))]

}

@history[
 #:added "1.0" @;{list{Fri Nov  3 11:49:40 EDT 2017}}
]
