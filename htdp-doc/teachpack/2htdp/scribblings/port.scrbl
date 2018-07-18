#lang scribble/doc

@(require "shared.rkt" "port.rkt" scribble/manual
          (for-label scheme
                     (only-in 2htdp/universe on-tick on-draw)
                     (prefix-in htdp: teachpack/htdp/world)
                     (prefix-in htdp: htdp/image)
                     (prefix-in 2htdp: teachpack/2htdp/universe)
                     (prefix-in 2htdp: 2htdp/image)
                     (only-in lang/htdp-beginner check-expect)))

@; -----------------------------------------------------------------------------

@title[#:tag "htdp-port"]{移植世界程序到宇宙}

@author["Matthias Felleisen" "Robby Findler" "Racket-zh项目组译"]

@; -----------------------------------------------------------------------------
@section{世界还不够}

随着2009年6月的发布，我们开始弃用world教学包；取代其功能，我们推荐universe教学包。
随着2010年1月的发布，我们还推出了新的image教学包，为了支持这第二个教学包，我们将图像功能与世界程序的功能区分开。

本文档解释如何将旧的世界教学包程序移植到此新设置中，一步一步进行。
最重要的是，程序现在必须import@emph{两个}教学包而不再是一个：
@port[
@(begin
#reader scribble/comment-reader
(racketblock
(require #,(racketmodname htdp/world))
))
@; ---------------------------------
@(begin
#reader scribble/comment-reader
(racketblock
(require #,(racketmodname 2htdp/universe))
(require #,(racketmodname 2htdp/image))
))
]
表的左侧显示的旧的形式，右侧显示新形式。如果你的程序通过drscheme中教学包菜单导入教学包，
我们建议从现在开始使用@racket[require]形式；或者，可以使用drscheme菜单@emph{两次}，导入两个教学包。

在下一节中，我们先解释如何移植世界程序，以便他们使用universe教学包和旧的image教学包。
在之后一节中，我们给出更改程序的建议，以便它们不再依赖@emph{旧的}图像函数，而是使用新图像函数。

为了区分不同的函数，我们在旧函数前统一添加前缀“htdp：”，在新函数前添加“2htdp：”。
当然，你的程序中不需要使用这些前缀。

@; -----------------------------------------------------------------------------
@section{世界程序的移植}

这是world教学包文档中的第一个程序：
@(begin
#reader scribble/comment-reader
(racketblock
(require #,(racketmodname htdp/world))

;; Number -> Scene 
(define (create-UFO-scene height)
  (htdp:place-image UFO 
                    50 height
		    (htdp:empty-scene 100 100)))

;; Scene 
(define UFO
  (htdp:overlay
    (htdp:circle 10 'solid 'red)
    (htdp:rectangle 40 4 'solid 'red)))

;; ——运行程序
(htdp:big-bang 100 100 (/1 28) 0)
(htdp:on-tick-event add1)
(htdp:on-redraw create-UFO-scene)
))
这个程序定义了函数将@racket[UFO]置于100乘100场景中，其中@racket[UFO]被定义为图像。
世界程序本身由三行组成：
@itemize[
@item{第一行创建100乘100的场景，指定每秒28幅图像的速率，以及@racket[0]为初始世界描述；}
@item{第二行说，对于每个时钟滴答，世界（数值）加1；}
@item{最后一行告诉drscheme，使用@racket[create-UFO-scene]函数将当前世界呈现为场景。}
]

现在让我们一步一步地将此程序转换为使用universe的，从前面说过的@racket[require]规范开始：
@port[
@racketblock[(require #,(racketmodname htdp/world))]
@; ---------------------------------
@(begin
#reader scribble/comment-reader
(racketblock
(require #,(racketmodname 2htdp/universe))
(require #,(racketmodname htdp/image))
))
]

将世界呈现为场景的函数保持不变：
@port[
@(begin
#reader scribble/comment-reader
(racketblock
;; Number -> Scene 
(define (create-UFO-scene height)
  (htdp:place-image
    UFO 
    50 height
    (htdp:empty-scene 100 100)))
))
@; ---------------------------------
@(begin
#reader scribble/comment-reader
(racketblock
;; Number -> Scene 
(define (create-UFO-scene height)
  (htdp:place-image
    UFO 
    50 height
    (htdp:empty-scene 100 100)))
))
]

图像常量从符号变为字符串：
@port[
@(begin
#reader scribble/comment-reader
(racketblock
;; Scene 
(define UFO
  (htdp:overlay
    (htdp:circle 
     10 'solid 'red)
    (htdp:rectangle
     40 4 'solid 'red)))
))
@; ---------------------------------
@(begin
#reader scribble/comment-reader
(racketblock
;; Scene 
(define UFO
  (htdp:overlay
    (htdp:circle
     10 "solid" "red")
    (htdp:rectangle
     40 4 "solid" "red")))
))
]
严格说来，这不是必需的，但我们打算尽可能将符号替换为字符串，因为字符串比符号更常见。

最重要的变化是启动世界程序的几行：
@port[
@racketblock[
(htdp:big-bang 100 100 (/1 28) 0)
(htdp:on-tick-event add1)
(htdp:on-redraw create-UFO-scene)
]
@; ---------------------------------
@racketblock[
(2htdp:big-bang
  0
  (on-tick add1)
  (on-draw create-UFO-scene))
]
]
它们被转换为单个表达式，其中包含与旧程序中的行数一样多的子句。正如你所看到的，
universe教学包中的@racket[big-bang]表达不再需要指定场景大小或时钟滴答的速率（当然如果对默认值不满意也可以提供时钟速率）。
此外，这些子句的名称与旧名称相似，但更短。


另一个重大变化涉及键盘和鼠标事件的处理。各个处理程序不再接受符号和字符，而只接受字符串。
world教学包的文档中的第一个键盘事件处理程序是：

@port[
@racketblock[
 (define (change w a-key-event)
   (cond
     [(key=? a-key-event 'left)
      (world-go w -DELTA)]
     [(key=? a-key-event 'right)
      (world-go w +DELTA)]
     [(char? a-key-event)
      w]
     [(key=? a-key-event 'up)
      (world-go w -DELTA)]
     [(key=? a-key-event 'down)
      (world-go w +DELTA)]
     [else
      w]))]
@; ---------------------------------
@racketblock[
 (define (change w a-key-event)
   (cond
     [(key=? a-key-event "left")
      (world-go w -DELTA)]
     [(key=? a-key-event "right")
      (world-go w +DELTA)]
     [(= (string-length a-key-event) 1)
      w]
     [(key=? a-key-event "up")
      (world-go w -DELTA)]
     [(key=? a-key-event "down")
      (world-go w +DELTA)]
     [else
      w]))
]]
注意@racket[char?]子句的改变。由于现在所有字符都表示为包含一个“字母”的字符串，
因此右侧的程序只需检查字符串的长度。除此之外，我们简单地将所有符号更改为字符串。

如果你用过动画gif录制程序的运行，现在仍可以这样做。
但做法不再是向@racket[big-bang]添加第五个参数，而是添加形如@racket[(record? x)]的子句。

最后，universe教学包实现了比world教学包更丰富的功能。

@; -----------------------------------------------------------------------------
@section{图像程序的移植}

universe库还带来了新的图像库，@racketmodname[2htdp/image]。旧的图像库仍然可以协同@racketmodname[2htdp/universe]正常使用，
但新图像库提供了许多改进，包括更快的图像比较（特别适用于@racket[check-expect]表达式）、图像旋转、图像缩放、曲线、新的多边形，
以及对线条绘制的更多控制。

要单独使用新图像库：

@port[
@(begin
#reader scribble/comment-reader
(racketblock
(require #,(racketmodname htdp/image))
))
@; ---------------------------------
@(begin
#reader scribble/comment-reader
(racketblock
(require #,(racketmodname 2htdp/image))
))
]

和universe教学包一起使用新图像库：

@port[
@(begin
#reader scribble/comment-reader
(racketblock
(require #,(racketmodname htdp/world))
))
@; ---------------------------------
@(begin
#reader scribble/comment-reader
(racketblock
(require #,(racketmodname 2htdp/universe))
(require #,(racketmodname 2htdp/image))
))]
  
@bold{Overlay与Underlay}

@racket[htdp:overlay]函数将其第一个参数放在第二个（及后续）参数之下，
所以在@racketmodname[2htdp/image]中我们决定将其称为@racket[2htdp:underlay]。

@port[(racketblock
       (htdp:overlay
        (htdp:rectangle 
         10 20 "solid" "red")
        (htdp:rectangle
         20 10 "solid" "blue")))
      (racketblock
       (2htdp:underlay
        (2htdp:rectangle
         10 20 "solid" "red")
        (2htdp:rectangle
         20 10 "solid" "blue")))]

@bold{没有pinhole了}

@racketmodname[htdp/image]中pinhole概念在@racketmodname[2htdp/image] 中没有对应物
（我们确实希望最终在@racketmodname[2htdp/image]中加入pinhole，但它们不会像在@racket[htdp/image]中那样普遍）。

@racketmodname[2htdp/image]包含了一系列overlay操作，
它们不是对图像中的特殊位置叠加，而是根据其中心或边缘叠加图像。

由于pinhole的默认位置在大多数图像的中心，同时@racket[2htdp/image]中overlay和underlay图像默认值基于大部分图像的中心，
因此简单的例子（如前所述）在两个库中表现相同。

但是，考虑这个表达式，它按左上角overlay两个图像，分别使用两个库编写。

@port[@racketblock[(htdp:overlay
                    (htdp:put-pinhole
                     (htdp:rectangle 10 20 "solid" "red")
                     0 0)
                    (htdp:put-pinhole
                     (htdp:rectangle 20 10 "solid" "blue")
                     0 0))]
      @racketblock[(2htdp:underlay/align
                    "left"
                    "top"
                    (2htdp:rectangle
                     10 20 "solid" "red")
                    (2htdp:rectangle
                     20 10 "solid" "blue"))]]

在@racketmodname[2htdp/image]的版本中，程序使用@racket[2htdp:underlay/align]指定对齐图像的位置，而不是使用pinhole。

@bold{边框位置的不同}

和@racketmodname[htdp/image]相比，@racketmodname[2htdp/image]中边框的图形移动了一个像素。
这意味着下面两个矩形绘制出相同的像素集合。

@port[@racketblock[(htdp:rectangle 
                    11 11 "outline" "black")]
      @racketblock[(2htdp:rectangle
                    10 10 "outline" "black")]]

参见@secref["nitty-gritty"]。

@bold{Star变了}

@racket[2htdp:star]函数和@racket[htdp:star]完全不同。两者都是以多边形为基础的星形，
但@racket[2htdp:star]总是五角星。另请参见@racket[2htdp:star-polygon]获得更一般的星形。
