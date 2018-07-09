#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label racket lang/posn teachpack/htdp/image))

@teachpack["image"]{操作图像}

@defmodule[#:require-form beginner-require htdp/image]

@deprecated[@racketmodname[2htdp/image]]{在可预见的将来，我们将继续支持现有程序中的教学包。}

本教学包提供创建和操作图像的函数。创建的基本彩色图像为空心或实心形状。其他函数允许组合图像。


@;-----------------------------------------------------------------------------
@section{图像}

@defproc[(image? [x any/c]) boolean?]{@racket[x]是图像吗？}

@defproc[(image=? [x image?] [y image?]) boolean?]{@racket[x]和@racket[y]是相同的图像吗？}

@;-----------------------------------------------------------------------------
@section[#:tag "modes-colors"]{模式和颜色}

@deftech{Mode} @racket[(one-of/c 'solid 'outline "solid" "outline")]

@tech{Mode}（模式）用来指定绘制图形时是将其填充满颜色还是只绘制边框。

@defstruct[color [(red (and/c natural-number/c (<=/c 255)))
                  (green (and/c natural-number/c (<=/c 255)))
                  (blue (and/c natural-number/c (<=/c 255)))]]

@deftech{RGB} @racket[color?]

@tech{RGB}通过红色、绿色和蓝色的色调描述颜色（例如，@racket[(make-color 100 200 30)]）。

@deftech{Color} @racket[(or/c symbol? string? color?)] 

@tech{Color}是颜色符号（例如@racket['blue]）、颜色字符串（例如@racket["blue"]）或@tech{RGB}结构体。

@defproc[(image-color? [x any]) boolean?]{判断输入是否是有效的图像@tech{Color}。}

@;-----------------------------------------------------------------------------
@section[#:tag "creational"]{创建基本图形}

DrRacket可以插入来自文件系统的图像。请尽可能使用PNG格式。也可以使用以下函数创建基本图形。

@defproc[(rectangle [w (and/c number? (or/c zero? positive?))] [h (and/c number? (or/c zero? positive?))] [m (unsyntax @tech{Mode})] [c (unsyntax @tech{Color})]) image?]{
 创建@racket[w]乘@racket[h]的矩形，按@racket[m]填充，并使用颜色@racket[c]绘制。}

@defproc[(circle [r (and/c number? (or/c zero? positive?))] [m (unsyntax @tech{Mode})] [c (unsyntax @tech{Color})]) image?]{
 创建半径为@racket[r]的圆盘，按@racket[m]填充，并使用颜色@racket[c]绘制。}

@defproc[(ellipse [w (and/c number? (or/c zero? positive?))] [h (and/c number? (or/c zero? positive?))] [m (unsyntax @tech{Mode})] [c (unsyntax @tech{Color})]) image?]{
 创建@racket[w]乘@racket[h]的椭圆，按@racket[m]填充，并使用颜色@racket[c]绘制。}

@defproc[(triangle [s number?] [m (unsyntax @tech{Mode})] [c (unsyntax @tech{Color})]) image?]{ 
 创建指向向上、边长为@racket[s]像素的等边三角形，按@racket[m]填充，并使用颜色@racket[c]绘制。}

@defproc[(star [n (and/c number? (>=/c 2))]
               [outer (and/c number? (>=/c 1))]
               [inner (and/c number? (>=/c 1))]
               [m (unsyntax @tech{Mode})]
               [c (unsyntax @tech{Color})]) image?]{
 创建@racket[n]角星，其中点到中心的最大距离为@racket[outer]半径，点到中心的最小距离为@racket[inner]半径。}

@defproc[(regular-polygon [s side] [r number?] [m (unsyntax @tech{Mode})] [c (unsyntax @tech{Color})] [angle real? 0]) image?]{
 使用模式@racket[m]和颜色@racket[c]创建多边形，其边数为@racket[s]，内接于半径为@racket[r]的圆。如果指定了angle（角度），则将多边形旋转这个角度。
}

@defproc[(line [x number?][y number?] [c (unsyntax @tech{Color})]) image?]{
 创建颜色为@racket[c]、从（0,0）到@racket[(x,y)]的线。参见下面的@racket[add-line]。
}

@defproc[(text [s string?] [f (and/c number? positive?)] [c (unsyntax @tech{Color})]) Image]{
 创建字体大小@racket[f]、颜色@racket[c]、文本@racket[s]的图像。}

@;-----------------------------------------------------------------------------
@section[#:tag "properties"]{基本图像属性}

要了解如何操作图像，先需要了解图像的基本属性。

@defproc[(image-width [i image?]) integer?]{
 获取@racket[i]的宽度（单位为像素）}

@defproc[(image-height [i image?]) integer?]{
 获取@racket[i]的高度（单位为像素）}

对于图像的组合，必须了解@emph{pinhole}（针孔）的概念。每张图片都带有pinhole。对于使用前述函数创建的图像，除了@racket[line]和@racket[text]之外，pinhole都位于形状的中心。@racket[text]函数将pinhole放在图像的左上角，而@racket[line]将pinhole放在线的开头（也就是说，如果@racket[line]的前两个参数线为正数，那么pinhole位于左上角）。当然，pinhole可以移动，并且图像组合物根据自己的规则定位pinhole。不确定的话，可以随时找到pinhole的位置，或者根据需要放置pinhole。

@defproc[(pinhole-x [i image?]) integer?]{求pinhole的@racket[x]坐标，从图像左侧开始计算。}

@defproc[(pinhole-y [i image?]) integer?]{求pinhole的@racket[y]坐标，从图像顶部（向下）计算。}

@defproc[(put-pinhole [i image?] [x number?] [y number?]) image?]{
 创建pinhole位于@racket[x]和@racket[y]的新图像，分别从图像左侧和顶部（向下）开始计算。}

@defproc[(move-pinhole [i image?] [delta-x number?] [delta-y number?]) image?]{
 创建新图像，将pinhole从当前位置向右和向下移动@racket[delta-x]和@racket[delta-y]像素。要向左或向上移动的话，使用负数。}

@;-----------------------------------------------------------------------------
@section[#:tag "composition"]{图像的组合}

可以组合图像，也可以在组合中寻找图像。

@defproc[(add-line [i image?] 
                   [x1 number?]
                   [y1 number?]
                   [x2 number?]
                   [y2 number?]
                   [c (unsyntax @tech{Color})]) image?]{
创建新图像，将从（@racket[x1],@racket[y1]）到（@racket[x2],@racket[y2]）的线加入图像@racket[i]。}

@defproc[(overlay [img image?] [img2 image?] [img* image?] ...) image?]{
将所有图像按pinhole位置叠加，创建新图像。新图像的pinhole与第一个图像的pinhole相同。
}

@defproc[(overlay/xy [img image?] [delta-x number?] [delta-y number?] [other image?]) image?]{
将@racket[other]的像素加到@racket[img]中，创建新图像。 

不将两个图像按pinhole叠加，而是将@racket[other]的pinhole放置于点：
@racketblock[
(make-posn (+ (pinhole-x img) delta-x)
           (+ (pinhole-y img) delta-y))
]

新图像的pinhole与第一个图像的pinhole相同。

组合@racket[move-pinhole]和@racket[overlay]也可以产生相同的效果，
@racketblock[
(overlay img 
         (move-pinhole other
                       (- delta-x)
                       (- delta-y)))]

}

@defproc[(image-inside? [img image?] [other image?]) boolean?]{
 判断第二个图像的像素是否出现在第一个图像中。

将此函数与jpeg图像一起使用时要小心。如果使用图像编辑程序裁剪jpeg图像然后保存之，由于JPEG图像的压缩，因此@racket[image-inside?]无法识别裁剪后的图像。}

@defproc[(find-image [img image?] [other image?]) posn?]{
 求第二个图像的像素出现在第一个图像中的（相对于第一个图像的pinhole的）位置。如果@racket[(image-inside?
 img other)]不成立，@racket[find-image]抛出错误。}

@;-----------------------------------------------------------------------------
@section[#:tag "manipulation"]{图像的操作}

图像也可以被缩小。这些“缩小”函数消除不再需要的像素，从而减小图像。

@defproc[(shrink-tl [img image?][width number?][height number?]) image?]{
从@emph{左上角}开始，将图像缩小到@racket[width]乘@racket[height]大。所得图像的pinhole位于其中心。}

@defproc[(shrink-tr [img image?][width number?][height number?]) image?]{
从@emph{右上角}开始，将图像缩小到@racket[width]乘@racket[height]大。所得图像的pinhole位于其中心。}

@defproc[(shrink-bl [img image?][width number?][height number?]) image?]{
从@emph{左下角}开始，将图像缩小到@racket[width]乘@racket[height]大。所得图像的pinhole位于其中心。}

@defproc[(shrink-br [img image?][width number?][height number?]) image?]{
从@emph{右下角}开始，将图像缩小到@racket[width]乘@racket[height]大。所得图像的pinhole位于其中心。}

@defproc[(shrink [img image?][left number?][above number?][right number?][below number?]) image?]{
围绕pinhole收缩图像。数值参数分别是保存位于针孔左侧、上方、右侧和下方的像素数。pinhole所对应的像素总会被保存。}

@;-----------------------------------------------------------------------------
@section[#:tag "scenes"]{场景}

@deftech{scene}（场景）是pinhole位于其左上角的图像，即@racket[pinhole-x]和@racket[pinhole-y]都返回@racket[0]。

对@racketmodname[2htdp/universe]和@racketmodname[htdp/world]教学包来说，场景特别有用，因为它们在画布中只能显示@tech{scene}。

@defproc[(scene? [x any/c]) boolean?]{@racket[x]是场景吗？}

@defproc[(empty-scene [width natural-number/c]
                      [height natural-number/c])
         scene?]{
 创建纯白色、@racket[width]乘@racket[height]的@tech{scene}。}

@defproc[(place-image [img image?] [x number?] [y number?]
                      [s scene?])
         scene?]{
 将@racket[img]放置到@racket[s]的@math{(@racket[x], @racket[y])}位置，创建场景；@math{(@racket[x], @racket[y])}是计算机图形坐标，也就是说它们从左上角向右和向下计数。}


@defproc[(nw:rectangle [width natural-number/c] [height natural-number/c] [solid-or-outline Mode] [c Color]) image?]{
   创建@racket[width]乘@racket[height]的矩形，由@racket[solid-or-outline]决定实心还是边框，由@racket[c]决定颜色，其中pinhole位于左上角。}
   
@defproc[(scene+line [s scene?][x0 number?][y0 number?][x1 number?][y1 number?][c Color]) scene?]{
   绘制颜色为@racket[c]、从计算机图形坐标@math{(@racket[x0], @racket[y0])}到@math{(@racket[x1],
   @racket[y1])}的线，从而创建场景。和@racket[add-line]函数不同，@racket[scene+line]会切除线超出@racket[s]边界的部分。}

@;-----------------------------------------------------------------------------
@section[#:tag "pixel-lists"]{其他图像处理和创建函数}
 
最后这组函数从图像中提取成分颜色，并将颜色表转换为图像。

@defthing[List-of-color list?]{是以下之一：}
@(begin
#reader scribble/comment-reader
(racketblock
;; -- @racket[empty]
;; -- @racket[(cons @#,tech{Color} List-of-color)]
;; 解释：表示颜色的表。
))

@defproc[(image->color-list [img image?]) List-of-color]{
 将图像转换为颜色的表。}

@defproc[(color-list->image [l List-of-color]
           [width natural-number/c]
           [height natural-number/c]
           [x natural-number/c]
           [y natural-number/c]) image?]{
 将颜色表@racket[l]转换为图像，其宽度为@racket[width]，高度为@racket[height]，pinhole坐标相对图像左上角为（@racket[x],@racket[y]）。}

后续的函数也提供alpha通道信息。Alpha通道是衡量透明度的标准；0表示完全不透明，255表示完全透明。


@defstruct[alpha-color [(alpha (and/c natural-number/c (<=/c 255)))
                        (red (and/c natural-number/c (<=/c 255)))
                        (green (and/c natural-number/c (<=/c 255)))
                        (blue (and/c natural-number/c (<=/c 255)))]]{
  表示alpha颜色的结构体。}

@defproc[(image->alpha-color-list [img image?]) (list-of alpha-color?)]{
 将图像转换为alpha颜色的表}

 @defproc[(alpha-color-list->image
            [l (list-of alpha-color?)]
            [width integer?]
            [height integer?]
            [x integer?]
            [y integer?]) image?]{
 将@racket[alpha-color]表@racket[l]转换为图像，其宽度为@racket[width]，高度为@racket[height]，pinhole坐标相对图像左上角为（@racket[x],@racket[y]）。
}
