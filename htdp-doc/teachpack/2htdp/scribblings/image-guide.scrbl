#lang scribble/doc

@(require (for-label 2htdp/image
                     (except-in lang/htdp-beginner posn make-posn posn? posn-x posn-y image?)
                     lang/posn
                     (only-in racket/base foldl)
                     (except-in racket/gui/base make-color make-pen)
                     file/convertible
                     pict/convert
                     (only-in mrlib/image-core render-image))
          "shared.rkt"
          teachpack/2htdp/scribblings/img-eval
          scribble/decode
          scribble/manual
          scribble/eval
          scribble/core
          scribble/html-properties)

@(define guide-eval (make-img-eval))

@(define-syntax-rule 
   (image-examples exp ...)
   (examples #:eval guide-eval exp ...))

@(define-syntax-rule
   (image-interaction exp ...)
   (interaction #:eval guide-eval exp ...))

@(define-syntax-rule
   (image-interaction/bitmap exp)
   (interaction #:eval guide-eval 
                (eval:alts exp (make-object bitmap%
                                 (open-input-bytes (convert exp 'png-bytes))
                                 'png/alpha))))

@(define-syntax-rule
   (image-interaction/margin num exp)
   (begin
     (racketinput exp)
     (guide-eval '(extra-margin num))
     (interaction-eval-show #:eval guide-eval exp)
     (guide-eval '(extra-margin 0))))

@(interaction-eval #:eval guide-eval 
                   (require racket/list 
                            racket/local
                            file/convertible
                            (only-in racket/draw bitmap%)
                            racket/class))

@title[#:style 
       (style #f (list (render-convertible-as '(svg-bytes png-bytes))))
       #:tag "image-guide"]{图像指南}

本节通过一系列复杂性递增的图像构造介绍@racketmodname[2htdp/image]库，并讨论图像裁剪和边框的一些微妙细节。

@section{Overlay、Above和Beside：房子}

要建造简单的房子，只需在矩形上方放置三角形。

@image-interaction[(above (triangle 40 "solid" "red")
                          (rectangle 40 30 "solid" "black"))]

只要将两个三角形彼此相邻放置，就能得到两个屋顶的房子。

@image-interaction[(above (beside (triangle 40 "solid" "red")
                                  (triangle 40 "solid" "red"))
                          (rectangle 80 40 "solid" "black"))]

但如果希望新屋顶稍微小一点，那么它们就无法对齐了。

@image-interaction[(above (beside (triangle 40 "solid" "red")
                                  (triangle 30 "solid" "red"))
                          (rectangle 70 40 "solid" "black"))]

取而代之的做法，可以使用@racket[beside/align]将两个三角形底部（所而不是@racket[beside]所选择的中部）对其。

@image-interaction[
(define victorian 
  (above (beside/align "bottom"
                       (triangle 40 "solid" "red")
		       (triangle 30 "solid" "red"))
         (rectangle 70 40 "solid" "black")))
victorian
]
  
为了给房子增加一扇门，可以overlay（覆盖）一个棕色的@racket[rectangle]，将它与房子其他部分的中心底部对齐。

@image-interaction[
(define door (rectangle 15 25 "solid" "brown"))
(overlay/align "center" "bottom" door victorian)]

使用类似的技术，我们可以加上一个门把手。但不是将把手overlay到整个房子上，而是将它overlay在门上。

@image-interaction[
(define door-with-knob
  (overlay/align "right" "center" (circle 3 "solid" "yellow") door))
(overlay/align "center" "bottom" door-with-knob victorian)]

@section{Rotate和Overlay：旋转拨号电话}

旋转式电话拨号盘可以通过在黑色圆盘上放置10个白色小圆盘来构建，方法是一次在黑色圆盘顶部放置一个白色圆盘，然后旋转整个黑盘。首先，让我们定义函数来制作带有数字的小白盘：

@image-interaction[(define (a-number digit)
                     (overlay
                      (text (number->string digit) 12 "black")
                      (circle 10 "solid" "white")))]

使用@racket[place-and-turn]将数字放到圆盘上：

@image-interaction[(define (place-and-turn digit dial)
                     (rotate 30
                             (overlay/align "center" "top" 
                                            (a-number digit)
                                            dial)))]

例如：

@image-interaction[(place-and-turn
                    0
                    (circle 60 "solid" "black"))]

@image-interaction[(place-and-turn
                    8
                    (place-and-turn
                     9
                     (place-and-turn
                      0
                      (circle 60 "solid" "black"))))]

可以编写函数将所有数字放入表盘：

@image-interaction[(define (place-all-numbers dial)
                     (place-and-turn
                      1
                      (place-and-turn
                       2
                       (place-and-turn
                        3
                        (place-and-turn
                         4
                         (place-and-turn
                          5
                          (place-and-turn
                           6
                           (place-and-turn
                            7
                            (place-and-turn
                             8
                             (place-and-turn
                              9
                              (place-and-turn
                               0
                               dial)))))))))))
                                              
                   (place-all-numbers (circle 60 "solid" "black"))]

这个定义即长又乏味。我们可以@racket[foldl]缩短之：

@image-interaction[(define (place-all-numbers dial)
                     (foldl place-and-turn
                            dial
                            '(0 9 8 7 6 5 4 3 2 1)))
                                              
                   (place-all-numbers (circle 60 "solid" "black"))]

要完成表盘，我们需要将它旋转到自然的位置，并在它的中心放一个白色圆盘。内部的表盘是：

@image-interaction[(define inner-dial
                     (overlay
                      (text "555-1234" 9 "black")
                      (circle 30 "solid" "white")))]

这是创建完整旋转拨盘的函数，它有一个参数，用来缩放表盘：

@image-interaction[(define (rotary-dial f)
                     (scale
                      f
                      (overlay 
                       inner-dial
                       (rotate
                        -90
                        (place-all-numbers (circle 60 "solid" "black"))))))
                   (rotary-dial 2)]

从图像上看，感觉数字太靠近表盘的边缘了。我们可以调整@racket[place-and-turn]函数，在每个数字的顶部放置一个黑色小矩形。矩形是不可见的，因为它最终位于黑色表盘之上，但它确实可以将数字向下推一点。

@image-interaction[(define (place-and-turn digit dial)
                     (rotate 30
                             (overlay/align "center" "top" 
                                            (above 
                                             (rectangle 1 5 "solid" "black")
                                             (a-number digit))
                                            dial)))
                   
                   (rotary-dial 2)]

@section{Alpha混合}

对于具有不透明颜色（如@racket["red"]和@racket["blue"]）的形状，将一个overlay（覆盖）在另一个之上将完全遮住底下的那个。

例如，这里的绿色矩形完全盖住了蓝色矩形。

@image-interaction[(overlay
                    (rectangle 60 100 "solid" (color 127 255 127))
                    (rectangle 100 60 "solid" (color 127 127 255)))]

但@racketmodname[2htdp/image]也支持部分透明的颜色，通过@racket[color]（可选）的第四个参数。

@image-interaction[(overlay
                    (rectangle 60 100 "solid" (color 0 255 0 127))
                    (rectangle 100 60 "solid" (color 0 0 255 127)))]

在这个例子中，当背景为白色时，颜色@racket[(color 0 255 0 127)]看起来就和颜色@racket[(color 127 255 127)]一样。由于白色是@racket[(color 255 255 255)]，最终得到的红色和蓝色成分就是@racket[255]的@racket[1/2]，而绿色成分是@racket[255]。

我们也可以使用alpha混合来制作一些有趣的效果。例如，函数@racket[spin-alot]读入图像参数，重复将其置于自身之上，每次旋转@racket[1]度。

@image-interaction[(define (spin-alot t)
                     (local [(define (spin-more i θ)
                               (cond
                                 [(= θ 360) i]
                                 [else 
                                  (spin-more (overlay i (rotate θ t))
                                             (+ θ 1))]))]
                       (spin-more t 0)))]

以下是@racket[spin-alot]的一些用途，这里先给出原始形状再给出旋转后的形状。

@image-interaction[(rectangle 12 120 "solid" (color 0 0 255))
                   (spin-alot (rectangle 12 120 "solid" (color 0 0 255 1)))
                   (triangle 120 "solid" (color 0 0 255))
                   (spin-alot (triangle 120 "solid" (color 0 0 255 1)))
                   (isosceles-triangle 120 30 "solid" (color 0 0 255))
                   (spin-alot (isosceles-triangle 120 30 "solid" (color 0 0 255 1)))]

@section{递归的图像函数}

也可以使用简短的递归函数制作有趣的形状。例如，这个函数围绕给定形状的边缘均匀放置不断增大的的白色圆圈：

@image-interaction[(define (swoosh image s)
                     (cond
                       [(zero? s) image]
                       [else (swoosh 
                              (overlay/align "center" "top"
                                             (circle (* s 1/2) "solid" "white")
                                             (rotate 4 image))
                              (- s 1))]))]

@image-interaction[(swoosh (circle 100 "solid" "black") 
                           94)]

使用图像库也可以编写很多经典的分形形状，例如：

@image-interaction[(define (sierpinski-carpet n)
                     (cond
                       [(zero? n) (square 1 "solid" "black")]
                       [else
                        (local [(define c (sierpinski-carpet (- n 1)))
                                (define i (square (image-width c) "solid" "white"))]
                          (above (beside c c c)
                                 (beside c i c)
                                 (beside c c c)))]))]

@image-interaction/bitmap[(sierpinski-carpet 5)]

我们可以调整地毯添加一点颜色：

@image-interaction[(define (colored-carpet colors)
                     (cond
                       [(empty? (rest colors)) 
                        (square 1 "solid" (first colors))]
                       [else
                        (local [(define c (colored-carpet (rest colors)))
                                (define i (square (image-width c) "solid" (car colors)))]
                          (above (beside c c c)
                                 (beside c i c)
                                 (beside c c c)))]))]

@image-interaction/bitmap[(colored-carpet 
                           (list (color #x33 #x00 #xff)
                                 (color #x66 #x00 #xff)
                                 (color #x99 #x00 #xff)
                                 (color #xcc #x00 #xff)
                                 (color #xff #x00 #xff)
                                 (color 255 204 0)))]

通过简单地将四条曲线彼此相邻放置，再适当旋转就可以构建科赫曲线：

@image-interaction[(define (koch-curve n)
                     (cond
                       [(zero? n) (square 1 "solid" "black")]
                       [else
                        (local [(define smaller (koch-curve (- n 1)))]
                          (beside/align "bottom"
                                        smaller 
                                        (rotate 60 smaller)
                                        (rotate -60 smaller)
                                        smaller))]))
                   (koch-curve 5)]

接下来把它们中的三个组合在一起形成科赫雪花。

@image-interaction[(above 
                    (beside
                     (rotate 60 (koch-curve 5))
                     (rotate -60 (koch-curve 5)))
                    (flip-vertical (koch-curve 5)))]

@section[#:tag "rotate-center"]{旋转和图像中心}

旋转（rotate）图像时，有时围绕不是图像中心的点旋转时图像看起来最佳。然而，@racket[rotate]函数只是将图像作为一个整体旋转，相当于围绕其边界框的中心在旋转。

例如，想象一个游戏，其中将英雄（hero）表示为三角形：
@image-interaction[(define (hero α) 
                     (triangle 30 "solid" (color 255 0 0 α)))
                   (hero 255)]
在提示符处旋转英雄看起来合理：
@image-interaction[(rotate 10 (hero 255))
                   (rotate 20 (hero 255))
                   (rotate 30 (hero 255))]
但是如果英雄必须原地旋转，那么这看起来就不对了，如果使用α混合来表示英雄的旧位置：
@image-interaction[(overlay (rotate 0  (hero 255))
                            (rotate 10 (hero 125))
                            (rotate 20 (hero 100))
                            (rotate 30 (hero  75))
                            (rotate 40 (hero  50))
                            (rotate 50 (hero  25)))]
我们真正想要的是，让英雄围绕三角形的质心旋转。为了达到这个效果，可以将英雄放在透明的圆圈上，使整个图像的中心与三角形的质心对齐：
@image-interaction[(define (hero-on-blank α)
                     (define the-hero (hero α))
                     (define w (image-width the-hero))
                     (define h (image-height the-hero))
                     (define d (max w h))
                     (define dx (/ w 2))   (code:comment "centroid x offset")
                     (define dy (* 2/3 h)) (code:comment "centroid y offset")
                     (define blank  (circle d "solid" (color 255 255 255 0)))
                     (place-image/align the-hero (- d dx) (- d dy) "left" "top" blank))]
这样英雄的旋转看起来就很合理了：
@image-interaction[(overlay (rotate 0  (hero-on-blank 255))
                            (rotate 10 (hero-on-blank 125))
                            (rotate 20 (hero-on-blank 100))
                            (rotate 30 (hero-on-blank  75))
                            (rotate 40 (hero-on-blank  50))
                            (rotate 50 (hero-on-blank  25)))]

@section{图像的互操作性}

图像可以结合其他库使用。具体说来：
@itemlist[@item{图像是@racket[snip%]对象，所以可以被@method[text% insert]（插入）到@racket[text%]和@racket[pasteboard%]对象中}
          @item{它们实现了@racket[convert]协议的@racket['png-bytes]}
          @item{它们实现了@racket[pict-convert]协议}
          @item{通过低级接口直接绘制到@racket[dc<%>]对象中：@racket[render-image]。}]

@section[#:tag "nitty-gritty"]{像素、画笔和线的细节}

图像库认为坐标位于每个像素的左上角，并且是无限小的（与像素不同，它们是有面积的）。

因此，当绘制其边长为10的实心@racket[square]（正方形）时，图像库会对@racket[square]所包围的所有像素着色，由左上角的（0,0）开始到右下角的（10,10）结束，因此左上角为（9,9）的的像素被着色，而（10,10）的像素则没有。总共有100个像素被着色，正如符合边长为10的@racket[square]的预期。

然而，在绘制线条时，事情会变得复杂一些。具体来说，想象一下绘制该矩形的边框。由于边框位于像素之间，因此实际上不存在需要绘制的自然像素来表示边框。因此，当绘制边框@racket[square]（不使用@racket[pen]指定如何绘制，而是使用颜色作为最后一个参数）时，图像库使用宽度为1像素的画笔，绘制以点（0.5,0.5）为中心的线，其左下角位于（10.5,10.5）。这意味着边框稍稍超出形状的外围。具体来说，正方形的上边线和左边线都位于其外围只内，但是下边线和右边线都不在。

@margin-note{如果正在使用@seclink["top" #:doc '(lib "scribblings/drracket/drracket.scrbl")]{DrRacket}阅读本节，请注意当DrRacket在交互窗口中渲染图像时，会按其边界框切割图像；请继续阅读以了解跟多，但需要知道的是，此处例子的结果与交互窗口中看到的结果不完全相同。}
当矩形彼此相邻放置时，这种绘制方法很有用，能避免内部出现粗线。例如，考虑创建如下的网格：

@image-interaction[
(define s1 (square 20 'outline 'black))
(define r1 (beside s1 s1 s1 s1 s1 s1))
(above  r1 r1 r1 r1 r1 r1)
]

在这个网格中，内部线条与边缘线条的宽度相同，原因是矩形彼此重叠。也就是说，左侧矩形的右边缘于右侧矩形的左边缘重合。

在绘制图形时向每个坐标添加0.5，这种做法适用于所有仅传入颜色的多边形，但是如果最后一个参数传入@racket[pen]时就不适用。例如，如果使用厚度为2的pen（画笔）来绘制矩形，我们得到的边框在矩形内部和外部各占一个像素行。你可能认为，厚度为1的画笔会在形状周围画出一条1像素粗的线，但这需要每个像素的1/2被点亮，而这是不可能的。取而代之的做法，和宽为2像素的画笔一样的像素会被点亮，但颜色强度只有1/2。因此，1像素宽的黑色@racket[pen]对象绘制2像素宽的灰色边框。

@image-interaction[(define p1 (make-pen "black" 1 "solid" "round" "round"))]
@image-interaction/margin[2 (rectangle 20 20 "outline" p1)]

结合画笔和裁剪功能，我们可以绘制边框宽度为一个像素、且完全位于矩形内部的矩形。这个矩形使用两像素宽的黑色画笔，但之后裁剪掉画笔的外部。

@image-interaction[(define p2 (make-pen "black" 2 "solid" "round" "round"))
                   (define s2 (crop 0 0 20 20 (rectangle 20 20 "outline" p2)))
                   s2]

这样做我们也可以创建网格，在网格中内部线条是（边框的）两倍。

@image-interaction[
(define r2 (beside s2 s2 s2 s2 s2 s2))
(above  r2 r2 r2 r2 r2 r2)
]

虽然这种矩形对于创建网格来说没啥用，但另一方面，创建绘图不超过其边界框的矩形非常有用。具体来说，@racket[frame]和@racket[empty-scene]就使用这种方式绘图，以便如果之后将图像剪切到其边界框时不会丢失像素。

对边框图形使用@racket[image->color-list]时，出于同样的原因，结果可能会令人惊讶。例如，如上所述，2x2的黑色边框矩形由九个像素组成，但由于@racket[image->color-list]仅返回边界框内的像素，因此我们只看到三个黑色像素和一个白色像素。

@image-interaction[(image->color-list
                    (rectangle 2 2 "outline" "black"))]

黑色的像素是图形的（部分）上边缘和左边缘，而白色像素是图形中间的那个。

@section[#:tag "nitty-gritty-alpha"]{Alpha混合的细节}

Alpha混合会导致颜色的不精确，从而使图形看起来@racket[equal?]即使它们是用不同的颜色创建的。本节介绍这种情况的原因。

首先，考虑颜色@racket[(make-color 1 1 1 50)]。这几乎就是最暗的黑色，但又很透明，所以在白色背景上呈现时它呈浅灰色，例如：
@image-interaction[(rectangle 100 100 "solid" (make-color 1 1 1 50))]
如果背景是绿色，那么这个矩形看起来就是深绿色：
@image-interaction[(overlay
                    (rectangle 100 100 "solid" (make-color 1 1 1 50))
                    (rectangle 200 200 "solid" "green"))]

令人惊讶的是，这个形状于（显然）颜色不同的形状相等：
@image-interaction[(equal? 
                    (rectangle 100 100 'solid (make-color 1 1 1 50))
                    (rectangle 100 100 'solid (make-color 2 2 2 50)))]
为了理解原因，我们必须更仔细地研究alpha混合和图像相等。图像相等的定义很简单：如果两个图像画出来是相同的，那么它们是相等的。也就是说，图像相等性的定义是简单地在白色背景上绘制两个形状然后比较所有像素来（当然，在某些情况下，它有更有效地实现）。

所以，既然这两个形状相等，它们必然使用了相同的颜色绘制。要查看实际绘制的颜色，我们可以使用@racket[image->color-list]。由于这两个图像的所有像素都使用相同的颜色，我们只需检查其第一个像素：
@image-interaction[(first
                    (image->color-list
                     (rectangle 100 100 'solid (make-color 1 1 1 50))))
                   (first
                    (image->color-list
                     (rectangle 100 100 'solid (make-color 2 2 2 50))))]
正如@racket[equal?]测试所示，这两个颜色是一样的，但为什么呢？这正是alpha混合和绘图的微妙之处。通常alpha混合这样工作：获取需要绘制图像下方的颜色，将其与新颜色组合。组合的精确量由α值控制。所以，如果某个形状的alpha值为@racket[α]，那么绘图库会将新颜色乘以@racket[(/ α 255)]、原有颜色乘以@racket[(- 1 (/ α 255))]，然后将结果相加以获得最终的颜色。（会分别为红色、绿色和蓝色成分执行此操作。）

回过来看例子中的两个矩形，对于第一个形状，绘图库将@code{50/255}乘以@racket[1]，对于第二个形状，则将@code{50/255}乘以@racket[2]（因为它们都是在白色背景上绘制的）。接下来要将它们舍入为整数，因此两种情况下颜色的结果都是@racket[0]，所以两个图像相同。
