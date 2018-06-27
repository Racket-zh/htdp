#lang scribble/doc
@(require "common.rkt" (for-label lang/htdp-beginner))

@title[#:style 'toc #:tag "top"]{@italic{程序设计方法}语言}

本手册中记录的语言由DrRacket提供，可与
@italic{@link["http://www.htdp.org/"]{《程序设计方法》（又译《如何设计程序》）}}
一起使用。

当这些语言的程序在DrRacket中运行时，程序中任何未运行的部分将以橙色和黑色突出显示。这些颜色旨在告知程序员哪些部分的程序未经测试。要避免看到这些颜色，使用
@racket[check-expect]
测试程序即可。当然，如果没有看到任何颜色，这并不意味着程序已经完全测试；它只是表明程序的每个部分都已经运行（至少一次）。

@table-of-contents[]

@;------------------------------------------------------------------------

@include-section["beginner.scrbl"]
@include-section["beginner-abbr.scrbl"]
@include-section["intermediate.scrbl"]
@include-section["intermediate-lambda.scrbl"]
@include-section["advanced.scrbl"]

@;------------------------------------------------------------------------

@;index-section[]
