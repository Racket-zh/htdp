#lang scribble/doc

@(require scheme/sandbox scribble/manual scribble/eval scribble/core
          scribble/html-properties scribble/latex-properties
          2htdp/batch-io
          "shared.rkt"
          (for-syntax racket)
          (for-label scheme teachpack/2htdp/batch-io))

@(require scheme/runtime-path)
@(define-runtime-path here ".")
@(define io-style-extras
   (list (make-css-addition (build-path here "io.css"))
         (make-tex-addition (build-path here "io.tex"))))
@(define (file-is f)
  (define x (parameterize ([current-directory here]) (read-file f)))
  (nested
    (tabular #:style (make-style "FileBox" io-style-extras)
      (list (list (verbatim x))))))

@(define-syntax examples-batch-io
  (syntax-rules ()
    [(_ d ...)
     (let ()
       (define me (make-base-eval))
       (begin
         (interaction-eval #:eval me (require 2htdp/batch-io))
         (interaction-eval #:eval me d)
         ...)
       (me `(,current-directory ,here))
       (interaction-eval #:eval me (require lang/htdp-intermediate-lambda))
       me)]))

@; -----------------------------------------------------------------------------

@(define-syntax (reading stx)
   (syntax-case stx ()
     [(reading name ctc s)
     #`@defproc[(@name [f (or/c 'standard-in 'stdin (and/c string? file-exists?))]) @ctc ]{
      读取标准输入设备（直到其被关闭）或文件@racket[f]的内容，返回@list[s]。}]
     [(reading name ctc [x ctc2] s ...)
      #`@defproc[(@name [f (or/c 'standard-in 'stdin (and/c string? file-exists?))] [@x @ctc2]) @ctc ]{
      读取标准输入设备（直到其被关闭）或文件@racket[f]的内容，返回@list[s ...]。}]))

@teachpack["batch-io"]{批量输入/输出}

@author["Matthias Felleisen" "Racket-zh项目组译"]

@defmodule[#:require-form beginner-require 2htdp/batch-io]

batch-io教学包引入了用于从文件中读取内容的几个函数和一个语法形式，以及一个用于写文件的函数。

@; -----------------------------------------------------------------------------
@section{IO函数}

所有读取文件的函数都读入文件名以及其他可选参数。它们假设指定的文件与程序存在于同一文件夹中；如果不然，则抛出错误：
@itemlist[

@item{@reading[read-file string?]{包含换行符的字符串}

@examples[#:eval (examples-batch-io)
(read-file "data.txt")
]
其中文件@racket["data.txt"]的内容是：
@(file-is "data.txt")
注意第二行中的前导空格转换为结果中换行符和@racket["good"]之间的空格。}

@item{@reading[read-1strings (listof 1string?)]{单字符字符串的表，每个字符一个字符串}

@examples[#:eval (examples-batch-io)
(read-1strings "data.txt")
]
注意此函数忠实地再现文件的所有部分，包括空格和换行符。}

@item{@reading[read-lines (listof string?)]{字符串的表，每行一个字符串}
@examples[#:eval (examples-batch-io)
(read-lines "data.txt")
]
其中@racket["data.txt"]是和前一个例子相同的文件。同样，第二行中的前导空格出现在表中第二个字符串中。

即使最后一行不以换行结束，函数也假设如此。
}

@item{@reading[read-words (listof string?)]{字符串的表，文件中空格每个空格区分的词一个字符串。}

@examples[#:eval (examples-batch-io)
(read-words "data.txt")
]
然而，这一次@racket["data.txt"]第二行的额外前导空格不在结果中。此空格被认为是围绕@racket["good"]一词的分隔符的一部分。
}

@item{@reading[read-words/line (listof (listof string?))]{表的表，每行一个表；行表示为字符串的表}

@examples[#:eval (examples-batch-io)
(read-words/line "data.txt")
]
结果和@racket[read-words]返回的类似，区别是文件中的分行信息得以保留。特别地，空白行由空表表示。

即使最后一行不以换行结束，函数也假设如此。
}

@item{@reading[read-words-and-numbers/line (listof (or number? string?))]{表的表，每行一个表；行表示为字符串或数值的表}

@examples[#:eval (examples-batch-io)
(read-words-and-numbers/line "data.txt")
]
结果和@racket[read-words/line]返回的类似，区别是可以的话将字符串解析为数值表示。

即使最后一行不以换行结束，函数也假设如此。}

@item{@reading[read-csv-file (listof (listof any/c))]{逗号分隔值表的表}

@examples[#:eval (examples-batch-io)
(read-csv-file "data.csv")
]
其中文件@racket["data.csv"]的内容是：
@(file-is "data.csv")
需要理解的是，行不必具有相同的长度。这个例子中，第三行包含三个元素。
}

@item{@reading[read-csv-file/rows (listof X?) [s (-> (listof any/c) X?)]]{行的表；读取文件@racket[f]的内容，将每行通过@racket[s]构造为数据}

@examples[#:eval (examples-batch-io)
(read-csv-file/rows "data.csv" (lambda (x) x))
(read-csv-file/rows "data.csv" length)
]
 第一个例子显示@racket[read-csv-file]就是@racket[read-csv-file/rows]的缩写形式；第二个例子计算每一行词的数量，结果就是数值的表。在许多场景下，函数参数可以从行中构造结构体。}

@; -----------------------------------------------------------------------------
@item{@reading[read-xexpr xexpr?]{包含诸如制表符、换行符等空格的X表达式}

假设：文件@racket[f]或者所选的输入设备包含XML元素。假定文件包含类似HTML的文本并将其读入为XML。

@examples[#:eval (examples-batch-io)
(read-xexpr "data.xml")
]
其中文件@racket["data.xml"]的内容是：
@(file-is "data.xml")
注意结果包含换行符@racket["\\n"]。}

@item{@reading[read-plain-xexpr xexpr?]{不包含空格的X表达式}

假设：文件@racket[f]或者所选的输入设备包含XML元素，该元素的内容是其他XML元素和空格。特别地，XML元素不包含任何除空格之外的字符串元素。

@examples[#:eval (examples-batch-io)
(read-plain-xexpr "data-plain.xml")
]
其中文件@racket["data-plain.xml"]的内容是：
@(file-is "data-plain.xml")
将此与@racket[read-xexpr]的结果比较。}
]

目前只有一个写函数：
@itemlist[

@item{@defproc[(write-file [f (or/c 'standard-out 'stdout string?)] [cntnt string?]) string?]{
 将@racket[cntnt]送往标准输出设备，或将@racket[cntnt]转化为文件@racket[f]的内容，该文件与程序位于同一文件夹（目录）中。如果写入成功，函数返回文件名（@racket[f]）；否则它会抛出错误。}

@examples[#:eval (examples-batch-io)
(if (string=? (write-file "output.txt" "good bye") "output.txt")
    (write-file "output.txt" "cruel world")
    (write-file "output.txt" "cruel world"))
]
 对这个例子求值后，文件@racket["output.txt"]的内容就是：

cruel world

 解释为什么。
}
]

@defproc[(file-exists? [f string?]) boolean?]{判断当前目录中是否存在给定文件名的文件。}

@(parameterize ([current-directory here])
   (with-handlers ([exn:fail:filesystem? void])
     (delete-file "output.txt")))

@bold{警告}：此教学包中的文件IO函数和操作系统相关。这就是说，只要程序和文件位于同一平台上，读取程序写入的文件就不会有任何问题，反之亦然。但是，如果某个程序在Windows操作系统上写入文件，然后将此输出文件复制到Mac，那么读取复制后的文本文件可能会产生多余的“return”字符。请注意，这仅描述了一种可能出现的故障；很多在其他情况下，跨平台操作都可能会导致本教学包失效。

@; -----------------------------------------------------------------------------
@(define-syntax (reading/web stx)
   (syntax-case stx ()
     [(reading name ctc s)
     #`@defproc[(@name [u string?]) @ctc]{
      读取URL @racket[u]的内容，以@list[s]@racket[xexpr?]形式返回其中第一个XML元素。如果可能，将URL处的HTML解释为XML。如果网页不存在（404），则函数返#@racket[f]。}]
     [(reading name ctc [x ctc2] s ...)
      #`@defproc[(@name [f (or/c 'standard-in 'stdin (and/c string? file-exists?))] [@x @ctc2]) @ctc ]{
      reads the content of URL @racket[u] and produces the first XML
      element as an @racket[xexpr?] @list[s ...] If possible, the function interprets the HTML at
      the specified URL as XML. The function returns #@racket[f] if the web page
      does not exist (404)}]))

@section{网页函数}

所有读取基于网页的XML的函数都读入URL以及其他可选参数。它们假设计算机可以接到指定的网页，但也容忍网页不存在（404错误）。

@itemlist[
@; -----------------------------------------------------------------------------
@item{
@reading/web[read-xexpr/web xexpr?]{包含诸如制表符、换行符等空格的}}

@item{
@reading/web[read-plain-xexpr/web xexpr?]{不包含空格的}}

@item{
@defproc[(url-exists? [u string?]) boolean?]{确保指定的URL
@racket[u]不会给出404错误。}}

@item{
@defproc[(xexpr? [u any?]) boolean?]{判读输入值在以下意义上是否是X表达式：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
 ;   @deftech{Xexpr}是以下之一：
 ;   -- @racket[symbol?]
 ;   -- @racket[string?]
 ;   -- @racket[number?]
 ;   -- @racket[(cons symbol? (cons [List-of #, @tech{Attribute}] [List-of #, @tech{Xexpr}]))]
 ;   -- @racket[(cons symbol? [List-of #, @tech{Xexpr}])]
 ;
 ;   @deftech{Attribute}是：
 ;      @racket[(list symbol? string?)]
 ;   @racket[(list 'a "some text")]被称为a-Attribute，
 ;   其中"some text"是a的值。
))
@;%
 请注意，完整的Racket使用更广泛的X表达式概念。
 }}

@item{
@defproc[(xexpr-as-string [x xexpr?]) string?]{将输入的X表达式呈现为字符串。}}

@item{
@defproc[(url-html-neighbors [u string?]) (listof string?)]{检索URL
@racket[u]的内容，生成其中所有通过@tt{<a>}标签引用的.html页面的表。}}

]




@; -----------------------------------------------------------------------------
@section{测试}

@defform[(simulate-file process str ...)]{
 为函数@racket[process]模拟文件系统，该函数从文件系统读取文件，并可以写文件。
 注意：此语法形式还在开发中，将在最终确定其有用形式后再精确描述。}
