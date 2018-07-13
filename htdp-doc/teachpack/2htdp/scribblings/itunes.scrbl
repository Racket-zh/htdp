#lang scribble/doc

@(require scribble/manual "shared.rkt" scribble/eval racket/sandbox
          (for-label lang/htdp-beginner
	             (only-in lang/htdp-beginner check-expect)
                     teachpack/2htdp/itunes))
@;(require scribble/struct )

@(define my-eval
   (let ([e (make-base-eval)])
     (e '(require 2htdp/itunes))
     e))

@(define (track) @tech[#:tag-prefixes '("itunes-data")]{Track})
@(define (date)  @tech[#:tag-prefixes '("itunes-data")]{Date})
@(define (association) @tech[#:tag-prefixes '("itunes-data")]{Association})
@(define (ltracks) @tech[#:tag-prefixes '("itunes-data")]{LTracks})
@(define (llists) @tech[#:tag-prefixes '("itunes-data")]{LLists})
@(define (lassoc) @tech[#:tag-prefixes '("itunes-data")]{LAssoc})
@(define (bsl) @tech[#:tag-prefixes '("itunes-data")]{BSDN})

@; -----------------------------------------------------------------------------

@teachpack["itunes"]{iTunes}

@author["Matthias Felleisen" "Racket-zh项目组译"]

@defmodule[#:require-form beginner-require 2htdp/itunes #:use-sources (teachpack/2htdp/itunes)]

@;{FIXME: the following paragraph uses `defterm' instead of `deftech',
   because the words "world" and "universe" are used as datatypes, and
   datatypes are currently linked as technical terms --- which is a hack.
   Fix the paragraph when we have a better way to link datatype names.}

@tt{itunes.rkt}教学包实现并提供了读取从iTunes导出的曲目集合的功能。 

在iTunes中，从@tt{File}菜单中选择@tt{Library}，然后选择@tt{Export Library}。
这样做会将你的iTunes集合的描述导出为XML格式的文件。

@; ---------------------------------------------------------------------------------------------------
@section[#:tag-prefix "itunes-data"]{数据定义}

@defstruct[track ([name string?]
		  [artist string?]
		  [album string?]
		  [time natural-number/c]
		  [track# natural-number/c]
		  [added date?]
		  [play# natural-number/c]
		  [played date?])]{是iTunes集合中音乐曲目的表示。
 
实例记录该曲目的标题@racket[name]、制作艺术家@racket[artist]、属于专辑@racket[album]、
播放@racket[time]毫秒、位于音轨@racket[track#]、添加日期@racket[added]、
已经播放过@racket[play#]次，最后播放时间为@racket[played]。}

@defstruct[date  ([year natural-number/c]
		  [month natural-number/c]
		  [day natural-number/c]
		  [hour natural-number/c]
		  [minute natural-number/c]
		  [second natural-number/c])]{是iTunes集合中日期的表示。

实例记录六条信息：日期的@racket[year]、@racket[month]（@racket[1]到@racket[12]之间，
包含两者）、@racket[day]（@racket[1]到@racket[31]之间）、
@racket[hour]（@racket[0]到@racket[23]之间）、
@racket[minute]（@racket[0]到@racket[59]之间）和@racket[second]（@racket[0]到@racket[59]之间）。}

这里，我们引入以下数据定义：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
;; @deftech{Track}是@racket[track?]
;; @deftech{Date}是@racket[date?]

;; @deftech{LTracks}是以下之一：
;; -- @racket['()]
;; -- @racket[(cons #, @track[] #, @ltracks[])]
 
;; @deftech{LLists}是以下之一：
;; -- @racket['()]
;; -- @racket[(cons #, @lassoc[] #, @llists[])]

;; @deftech{LAssoc}是以下之一：
;; -- @racket['()]
;; -- @racket[(cons #, @association[] #, @lassoc[])]

;; @deftech{Association}是@racket[(cons string? (cons #, @bsl[] '()))]

;; @deftech{BSDN}满足@racket[string?]、@racket[integer?]、@racket[real?]、@date[]或@racket[boolean?]之一。
))
@;%

@; ---------------------------------------------------------------------------------------------------
@section[#:tag-prefix "itunes-api"]{Export的函数}

@defproc[(read-itunes-as-lists [file-name string?]) #, @llists[]]{
@;
为@racket[file-name]（从iTunes库中导出的XML）中所有的曲目创建表示（表的表）。
 
@bold{效果}：从@racket[file-name]中读取XML文档 

例如：
@racketblock[
(read-itunes-as-lists "Library.xml")
]
}

@defproc[(read-itunes-as-tracks [file-name string?]) #, @ltracks[]]{
@;
为@racket[file-name]（从iTunes库导出的XML）中的所有曲目创建表示（曲目的表）。

@bold{效果}：从@racket[file-name]中读取XML文档 

例如：
@racketblock[
(read-itunes-as-tracks "Library.xml")
]

}

@defproc[(create-track 
		       [name string?]
		       [artist string?]
		       [album string?]
		       [time natural-number/c]
		       [track# natural-number/c]
		       [added date?]
		       [play# natural-number/c]
		       [played date?]) 
         (or/c track? false?)]{
@;
如果输入符合对应的谓词，那么创建曲目的表示。否则返回@racket[#false]。

@bold{注意}：这是个@emph{带检查的}构造函数。

@interaction[#:eval my-eval
(create-track "one"
              "two"
	      "three"
	      4
	      5
	      (create-date 1 2 3 4 5 6)
	      7
	      (create-date 1 2 3 4 5 6))
(create-track "one" "two" "three" 4 5 "a date" 7 "another date")
]

}

@defproc[(create-date
		       [year natural-number/c]
		       [month natural-number/c]
		       [day natural-number/c]
		       [hour natural-number/c]
		       [minute natural-number/c]
		       [second natural-number/c])
         (or/c date? false?)]{
@;
如果输入符合对应的谓词，那么创建日期的表示。否则返回@racket[#false]。

@bold{注意}：这是个@emph{带检查的}构造函数。

@interaction[#:eval my-eval
(create-date 1 2 3 4 5 6)
(create-date 1 2 3 "four" 5 6)
]

}

除此之外，本教学包还export @track[]和@date[]的谓词和所有选择函数：
@;%
@(begin
#reader scribble/comment-reader
(racketblock
 track?
 track-name
 track-artist
 track-album
 track-time
 track-track#
 track-added
 track-play#
 track-played

 date?
 date-year
 date-month
 date-day
 date-hour
 date-minute
 date-second
))
@;%
