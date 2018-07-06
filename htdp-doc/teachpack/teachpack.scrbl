#lang scribble/doc

@(require scribble/manual
          (for-label scheme/base))

@title[#:style '(toc) #:tag "top"]{@italic{程序设计方法}教学包}

教学语言是完整编程语言的小子集。虽然这种限制简化了错误的诊断和工具的构建，但这也使得编写某些有趣的程序变得不可能（或者至少很难）。为了规避这种限制，我们允许在教学语言编写的程序中导入教学包。

原则上，教学包只是用完整语言（而不是教学子集）编写的库。和任何其他的库一样，它可以导出值和函数等。然而，与普通库相比，教学包必须为它所支持的“最低”教学语言强制执行契约，并给出此语言级别中学生可以理解的错误信号。

本章介绍@italic{《程序设计方法》（又译《如何设计程序》）}的教学包。

@table-of-contents[]

@include-section["htdp/scribblings/htdp.scrbl"]

@; removed: @include-section["htdc/scribblings/htdc.scrbl"]

@include-section["2htdp/scribblings/2htdp.scrbl"]
