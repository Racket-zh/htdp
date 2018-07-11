#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket teachpack/htdp/docs))

@teachpack["docs"]{操作简单的HTML文档}

@;declare-exporting[teachpack/htdp/docs]
@defmodule[#:require-form beginner-require htdp/docs]

本教学包提供三个函数，用于创建简单的“HTML”文档：

@deftech{Annotation} @tech{Annotation}是以“<”开头并以“>”结尾的符号。
结束annotation是以“</”开头的annotation。

@defproc[(atom? [x any/c]) boolean?]{判断某个值是否是数字、符号或字符串。} 

@defproc[(annotation? [x any/c]) boolean?]{确定符号是否是文档annotation。} 

@defproc[(end-annotation [x (unsyntax @tech{Annotation})]) (unsyntax @tech{Annotation})]{
读入annotation，生成对应的结束annotation。} 

@defproc[(write-file [l (list-of atom)]) true]{
读入符号和annotation的表，将其打印为“文件”。}

示例会话：将教学包设为“docs.rkt”并单击“运行”：
@(begin
#reader scribble/comment-reader
(racketblock
> (annotation? 0)
false
> (annotation? '<bold>)
true
> (end-annotation 0)
end-annotation: not an annotation: 0
> (write-file (list 'a 'b))
a b 
))
