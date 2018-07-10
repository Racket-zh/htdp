#lang scribble/doc

@(require (for-label (only-in racket/contract and/c or/c any/c not/c listof
                                              >=/c <=/c)
                     2htdp/image
                     (except-in lang/htdp-beginner posn make-posn posn? posn-x posn-y image?)
                     lang/posn
                     (except-in racket/gui/base make-color make-pen)
                     (only-in racket/base path-string?))
          lang/posn
          "shared.rkt"
          teachpack/2htdp/scribblings/img-eval
          scribble/decode
          scribble/manual)

@(require scribble/eval)

@(define img-eval (make-img-eval))

@(define-syntax-rule 
   (image-examples exp ...)
   (examples #:eval img-eval exp ...))

@(define-syntax-rule 
   (image-interaction exp ...)
   (interaction #:eval img-eval exp ...))

@(define-syntax-rule
   (image-interaction/margin num exp)
   (begin
     (racketinput exp)
     (img-eval '(extra-margin num))
     (interaction-eval-show #:eval img-eval exp)
     (img-eval '(extra-margin 0))))
     

@teachpack[#:svg? #t "image"]{图像}

@(define mode/color-and-nitty-text
   (make-splice
    @list{
     请注意，当@racket[mode]是@racket['outline]或@racket["outline"]时，
     图形可能会画到其边界框之外，因此在裁剪时图像的某些部分可能会消失。
     关于此点的详细解释，请参阅（@seclink["image-guide"]中）@secref["nitty-gritty"]。

     如果@racket[_mode]参数是@racket['outline]或@racket["outline"]，
     那么最后一个参数可以是@racket[pen]结构体，或是@racket[image-color?]，
     但如果@racket[_mode]是@racket['solid]或@racket["solid"]，
     那么最后一个参数必须是@racket[image-color?]。
    }))

@(define crop-warning
   (make-splice
    @list{某些图形（特别是@racket[_mode]参数为@racket['outline]或@racket["outline"]的）会在其边界框之外绘制，
          因此裁剪可能导致其中的一部分（通常是左下角和右下角）被切除。
          关于此点的详细讨论，请参阅（@seclink["image-guide"]中）@secref["nitty-gritty"]。}))

@defmodule[#:require-form beginner-require 2htdp/image]

图像教学包提供了许多基本的图像构造函数，外加使用现有图像构建更复杂图像的组合函数。
基本图像包括各种多边形、椭圆和圆、文本以及位图。@margin-note*{在本文中，
@defterm{bitmap}（位图）表示一种特殊格式的@racket[image?]，
即与图像相关联的像素集合。它不指@racket[bitmap%]类。
通常这种位图图像是通过DrRacket中的@onscreen{插入图片…}菜单项得到的}
现有图像可以被旋转、缩放、翻转，或者互相叠加。

在某些情况下，图像以位图形式呈现（例如，当在DrRacket的交互窗口中显示时）。
为了避免性能问题，最大能呈现的图像的面积大约为25,000,000像素（这需要大约100
MB的存储空间）。

@section{基本图像}

@defproc*[([(circle [radius (and/c real? (not/c negative?))]
                    [mode mode?]
                    [color image-color?])
            image?]
           [(circle [radius (and/c real? (not/c negative?))]
                    [outline-mode (or/c 'outline "outline")]
                    [pen-or-color (or/c pen? image-color?)])
            image?])]{
  构造具有给定半径、mode和颜色的圆。
  
  @mode/color-and-nitty-text
  
   @image-examples[(circle 30 "outline" "red")
                   (circle 20 "solid" "blue")
                   (circle 20 100 "blue")]

}

@defproc*[([(ellipse [width (and/c real? (not/c negative?))]
                     [height (and/c real? (not/c negative?))]
                     [mode mode?] 
                     [color image-color?])
            image?]
           [(ellipse [width (and/c real? (not/c negative?))]
                     [height (and/c real? (not/c negative?))]
                     [mode (or/c 'outline "outline")] 
                     [pen-or-color (or/c image-color? pen?)])
            image?])]{
  构造具有给定宽度、高度、mode和颜色的椭圆。

  @mode/color-and-nitty-text
  
  @image-examples[(ellipse 60 30 "outline" "black")
                  (ellipse 30 60 "solid" "blue")
                  (ellipse 30 60 100 "blue")] 
}

@defproc[(line [x1 real?] [y1 real?] [pen-or-color (or/c pen? image-color?)]) image?]{
  构造连接（0,0）和（x1,y1）线段的图像。
  
  @image-examples[(line 30 30 "black")
                  (line -30 20 "red")
                  (line 30 -20 "red")]
}

@defproc[(add-line [image image?]
                   [x1 real?] [y1 real?]
                   [x2 real?] [y2 real?]
                   [pen-or-color (or/c pen? image-color?)])
         image?]{

  向图像@racket[image]添加从点（@racket[x1],@racket[y1]）到点（@racket[x2],@racket[y2]）的线。
  与@racket[scene+line]不同，如果线穿过@racket[image]之外，图像会变大以适应之。
  
  @image-examples[(add-line (ellipse 40 40 "outline" "maroon")
                            0 40 40 0 "maroon")
                  (add-line (rectangle 40 40 "solid" "gray")
                            -10 50 50 -10 "maroon")
                 (add-line
                   (rectangle 100 100 "solid" "darkolivegreen")
                   25 25 75 75 
                   (make-pen "goldenrod" 30 "solid" "round" "round"))]
}

@defproc[(add-curve [image image?] 
                    [x1 real?] [y1 real?] [angle1 angle?] [pull1 real?]
                    [x2 real?] [y2 real?] [angle2 angle?] [pull2 real?]
                    [pen-or-color (or/c pen? image-color?)])
         image?]{

向图像@racket[image]添加从点（@racket[x1],@racket[y1]）到点（@racket[x2],@racket[y2]）的曲线。

参数@racket[angle1]和@racket[angle2]分别指定曲线离开初始点和到达最终点时的角度。

参数@racket[pull1]和@racket[pull2]控制曲线尝试保持该角度的范围。
较大的数字意味着曲线在更大范围内保持角度。

与@racket[scene+line]不同，如果线穿过@racket[image]之外，图像会变大以适应之。


  @image-examples[(add-curve (rectangle 100 100 "solid" "black")
                             20 20 0 1/3
                             80 80 0 1/3
                             "white")
                  (add-curve (rectangle 100 100 "solid" "black")
                             20 20 0 1 
                             80 80 0 1
                             "white")
                  (add-curve 
                   (add-curve 
                    (rectangle 40 100 "solid" "black")
                    20 10 180 1/2
                    20 90 180 1/2
                    (make-pen "white" 4 "solid" "round" "round"))
                   20 10 0 1/2
                   20 90 0 1/2
                   (make-pen "white" 4 "solid" "round" "round"))
                  
                  (add-curve (rectangle 100 100 "solid" "black")
                             -20 -20 0 1 
                             120 120 0 1
                             "red")]
}

@defproc[(add-solid-curve [image image?] 
                          [x1 real?] [y1 real?] [angle1 angle?] [pull1 real?]
                          [x2 real?] [y2 real?] [angle2 angle?] [pull2 real?]
                          [color image-color?])
         image?]{

和@racket[add-curve]一样，向@racket[image]中添加曲线，同时填充曲线内的区域。

@image-examples[(add-solid-curve (rectangle 100 100 "solid" "black")
                                 20 20 0 1 
                                 80 80 0 1
                                 "white")
                
                (add-solid-curve
                 (add-solid-curve
                  (rectangle 100 100 "solid" "black")
                  50 20 180 1/10
                  50 80 0 1
                  "white")
                 50 20 0 1/10
                 50 80 180 1
                 "white")
                
                (add-solid-curve
                 (add-solid-curve
                  (rectangle 100 100 "solid" "black")
                  51 20 180 1/10
                  50 80 0 1
                  "white")
                 49 20 0 1/10
                 50 80 180 1
                 "white")
                
                (add-solid-curve (rectangle 100 100 "solid" "black")
                                 -20 -20 0 1 
                                 120 120 0 1
                                 "red")]
@history[#:added "1.2"]
}

@defproc[(text [string string?] [font-size (and/c integer? (<=/c 1 255))] [color image-color?])
         image?]{
                
  使用字体大小和颜色，构造输入字符串的图像。
                 
  @image-examples[(text "Hello" 24 "olive")
                  (text "Goodbye" 36 "indigo")]

  如果字符串包含换行符，那么结果图片将包含多行。

  @image-examples[(text "Hello and\nGoodbye" 24 "orange")]
  
  文本大小以像素而不是（印刷中的）点来度量，
  因此给@racket[text]传入@racket[24]会产生高度为@racket[24]的图像（可能和以点或磅为单位的大小不同）。
  @image-examples[(image-height (text "Hello" 24 "olive"))]

  @history[#:changed "1.7" @elem{如果输入字符串包含换行符，
             @racket[text]返回多个行的图像。}]
  
}

@defproc[(text/font [string string?] [font-size (and/c integer? (<=/c 1 255))] [color image-color?]
                    [face (or/c string? #f)]
                    [family (or/c "default" "decorative" "roman" "script"
                                  "swiss" "modern" "symbol" "system"
                                  'default 'decorative 'roman 'script 
                                  'swiss 'modern 'symbol 'system)]
                    [style (or/c "normal" "italic" "slant"
                                 'normal 'italic 'slant)]
                    [weight (or/c "normal" "bold" "light"
                                  'normal 'bold 'light)]
                    [underline? any/c])
         image?]{
                
  使用完整的字体规范，构造输入字符串的图像。
  
  @racket[face]和@racket[family]的组合指定字体。如果系统中有@racket[face]，就使用之，
  但如果没有，会选择基于该@racket[family]的默认字体。
  @racket[style]控制是否使用斜体（在Windows和Mac OS下，@racket['slant]等价于@racket['italic]），
  @racket[weight]控制是否使用粗体（或浅色），而@racket[underline?]控制是否使用下划线。
  有关这些参数的更多详细信息，请参阅@racket[font%]，它最终负责决定字体。
                 
  @image-examples[(text/font "Hello" 24 "olive"
                             "Gill Sans" 'swiss 'normal 'bold #f)
                  (text/font "Goodbye" 18 "indigo"
                             #f 'modern 'italic 'normal #f)
                  (text/font "not really a link" 18 "blue"
                             #f 'roman 'normal 'normal #t)]
}

@defthing[empty-image image?]{
  空图像。它的宽度和高度均为零，根本不会被绘制。
  
  @image-examples[(image-width empty-image)
                  (equal? (above empty-image
                                 (rectangle 10 10 "solid" "red"))
                          (beside empty-image
                                  (rectangle 10 10 "solid" "red")))]
  
  
  将图像与@racket[empty-image]组合会产生原始图像（如上例所示）。
}

@section{多边形}

@defproc*[([(triangle [side-length (and/c real? (not/c negative?))] 
                      [mode mode?]
                      [color image-color?])
            image?]
           [(triangle [side-length (and/c real? (not/c negative?))] 
                      [outline-mode (or/c 'outline "outline")]
                      [pen-or-color (or/c pen? image-color?)])
            image?])]{

    构造指向上方的等边三角形。@racket[side-length]参数确定三角形的边长。
   
    @mode/color-and-nitty-text
  
    @image-examples[(triangle 40 "solid" "tan")]

}

@defproc*[([(right-triangle [side-length1 (and/c real? (not/c negative?))]
                            [side-length2 (and/c real? (not/c negative?))]
                            [mode mode?]
                            [color image-color?])
            image?]
           [(right-triangle [side-length1 (and/c real? (not/c negative?))]
                            [side-length2 (and/c real? (not/c negative?))]
                            [outline-mode (or/c 'outline "outline")]
                            [pen-or-color (or/c pen? image-color?)])
            image?])]{
                 
  构造直角三角形，其中两个直角边的长度分别为@racket[side-length1]和@racket[side-length2]。

  @mode/color-and-nitty-text
  
  @image-examples[(right-triangle 36 48 "solid" "black")]
}

@defproc*[([(isosceles-triangle [side-length (and/c real? (not/c negative?))] 
                                [angle angle?]
                                [mode mode?]
                                [color image-color?])
            image?]
           [(isosceles-triangle [side-length (and/c real? (not/c negative?))] 
                                [angle angle?]
                                [outline-mode (or/c 'outline "outline")]
                                [pen-or-color (or/c pen? image-color?)])
            image?])]{

 构造等腰三角形，其腰长为@racket[side-length]，顶角角度为@racket[angle]。
 底边会被水平摆放。如果angle小于@racket[180]，那么三角形将指向上方，
 如果@racket[angle]更大的话，三角形将指向下方。 
 
 @mode/color-and-nitty-text
 
 @image-examples[(isosceles-triangle 200 170 "solid" "seagreen")
                 (isosceles-triangle 60 30 "solid" "aquamarine")
                 (isosceles-triangle 60 330 "solid" "lightseagreen")]
}

                     
要根据边长（side）和角度（angle）创建三角形，以下的函数非常有用：
@itemlist[@item{@racket[triangle/sss]，如果已知的是三个边长；}
          @item{@racket[triangle/ass]、
                @racket[triangle/sas]或
                @racket[triangle/ssa]， 
                如果已知的是两个边长和一个角度；}
          @item{@racket[triangle/aas]、 
                @racket[triangle/asa]或
                @racket[triangle/saa]， 
                如果已知的是两个角度和一个边长。}]
                     

它们都构建方向如下所示的三角形：

@image["triangle-xxx.png"]

@defproc*[([(triangle/sss [side-length-a (and/c real? (not/c negative?))] 
                          [side-length-b (and/c real? (not/c negative?))] 
                          [side-length-c (and/c real? (not/c negative?))] 
                          [mode mode?]
                          [color image-color?])
            image?]
           [(triangle/sss [side-length-a (and/c real? (not/c negative?))]
                          [side-length-b (and/c real? (not/c negative?))]
                          [side-length-c (and/c real? (not/c negative?))]
                          [outline-mode (or/c 'outline "outline")]
                          [pen-or-color (or/c pen? image-color?)])
            image?])]{
 创建三角形，其中边长a、b、c分别由@racket[side-length-a]、
 @racket[side-length-b]和@racket[side-length-c]给定。
 
 @mode/color-and-nitty-text
 
 @image-examples[(triangle/sss 40 60 80 "solid" "seagreen")
                 (triangle/sss 80 40 60 "solid" "aquamarine")
                 (triangle/sss 80 80 40 "solid" "lightseagreen")]
}

@defproc*[([(triangle/ass [angle-a angle?] 
                          [side-length-b (and/c real? (not/c negative?))] 
                          [side-length-c (and/c real? (not/c negative?))] 
                          [mode mode?]
                          [color image-color?])
            image?]
           [(triangle/ass [angle-a angle?]
                          [side-length-b (and/c real? (not/c negative?))]
                          [side-length-c (and/c real? (not/c negative?))]
                          [outline-mode (or/c 'outline "outline")]
                          [pen-or-color (or/c pen? image-color?)])
            image?])]{
 创建三角形，其中角A、边长a和b分别由@racket[angle-a]、
 @racket[side-length-b]和@racket[side-length-c]给定。
 见上图了解哪个边是哪个，哪个角是哪个。
 
 @mode/color-and-nitty-text
 
 @image-examples[(triangle/ass 10  60 100 "solid" "seagreen")
                 (triangle/ass 90  60 100 "solid" "aquamarine")
                 (triangle/ass 130 60 100 "solid" "lightseagreen")]
}

@defproc*[([(triangle/sas [side-length-a (and/c real? (not/c negative?))] 
                          [angle-b angle?] 
                          [side-length-c (and/c real? (not/c negative?))] 
                          [mode mode?]
                          [color image-color?])
            image?]
           [(triangle/sas [side-length-a (and/c real? (not/c negative?))]
                          [angle-b angle?]
                          [side-length-c (and/c real? (not/c negative?))]
                          [outline-mode (or/c 'outline "outline")]
                          [pen-or-color (or/c pen? image-color?)])
            image?])]{
 创建三角形，其中边长a、角B和边长c分别由@racket[side-length-a]、
 @racket[angle-b]和@racket[side-length-c]给定。
 见上图了解哪个边是哪个，哪个角是哪个。
 
 @mode/color-and-nitty-text
 
 @image-examples[(triangle/sas 60  10 100 "solid" "seagreen")
                 (triangle/sas 60  90 100 "solid" "aquamarine")
                 (triangle/sas 60 130 100 "solid" "lightseagreen")]
}

@defproc*[([(triangle/ssa [side-length-a (and/c real? (not/c negative?))] 
                          [side-length-b (and/c real? (not/c negative?))] 
                          [angle-c angle?] 
                          [mode mode?]
                          [color image-color?])
            image?]
           [(triangle/ssa [side-length-a (and/c real? (not/c negative?))]
                          [side-length-b (and/c real? (not/c negative?))]
                          [angle-c angle?]
                          [outline-mode (or/c 'outline "outline")]
                          [pen-or-color (or/c pen? image-color?)])
            image?])]{
 创建三角形，其中边长a、边长b和角C分别由@racket[side-length-a]、
 @racket[side-length-b]和@racket[angle-c]给定。
 见上图了解哪个边是哪个，哪个角是哪个。
 
 @mode/color-and-nitty-text
 
 @image-examples[(triangle/ssa 60 100  10 "solid" "seagreen")
                 (triangle/ssa 60 100  90 "solid" "aquamarine")
                 (triangle/ssa 60 100 130 "solid" "lightseagreen")]
}
@defproc*[([(triangle/aas [angle-a angle?] 
                          [angle-b angle?] 
                          [side-length-c (and/c real? (not/c negative?))] 
                          [mode mode?]
                          [color image-color?])
            image?]
           [(triangle/aas [angle-a angle?]
                          [angle-b angle?]
                          [side-length-c (and/c real? (not/c negative?))]
                          [outline-mode (or/c 'outline "outline")]
                          [pen-or-color (or/c pen? image-color?)])
            image?])]{
 创建三角形，其中角A、角B和边长c分别由@racket[angle-a]、
 @racket[angle-b]和@racket[side-length-c]给定。
 见上图了解哪个边是哪个，哪个角是哪个。
 
 @mode/color-and-nitty-text
 
 @image-examples[(triangle/aas  10 40 200 "solid" "seagreen")
                 (triangle/aas  90 40 200 "solid" "aquamarine")
                 (triangle/aas 130 40 40  "solid" "lightseagreen")]
}

@defproc*[([(triangle/asa [angle-a angle?] 
                          [side-length-b (and/c real? (not/c negative?))] 
                          [angle-c angle?] 
                          [mode mode?]
                          [color image-color?])
            image?]
           [(triangle/asa [angle-a angle?]
                          [side-length-b (and/c real? (not/c negative?))]
                          [angle-c angle?]
                          [outline-mode (or/c 'outline "outline")]
                          [pen-or-color (or/c pen? image-color?)])
            image?])]{
 创建三角形，其中角A、边长b和角C分别由@racket[angle-a]、
 @racket[side-length-b]和@racket[angle-c]给定。
 见上图了解哪个边是哪个，哪个角是哪个。
 
 @mode/color-and-nitty-text
 
 @image-examples[(triangle/asa  10 200 40 "solid" "seagreen")
                 (triangle/asa  90 200 40 "solid" "aquamarine")
                 (triangle/asa 130 40  40 "solid" "lightseagreen")]
}

@defproc*[([(triangle/saa [side-length-a (and/c real? (not/c negative?))] 
                          [angle-b angle?] 
                          [angle-c angle?] 
                          [mode mode?]
                          [color image-color?])
            image?]
           [(triangle/saa [side-length-a (and/c real? (not/c negative?))]
                          [angle-b angle?]
                          [angle-c angle?]
                          [outline-mode (or/c 'outline "outline")]
                          [pen-or-color (or/c pen? image-color?)])
            image?])]{
 创建三角形，其中边长a、角B和角C分别由@racket[side-length-a]、
 @racket[angle-b]和@racket[angle-c]给定。
 见上图了解哪个边是哪个，哪个角是哪个。
 
 @mode/color-and-nitty-text
 
 @image-examples[(triangle/saa 200  10 40 "solid" "seagreen")
                 (triangle/saa 200  90 40 "solid" "aquamarine")
                 (triangle/saa 40  130 40 "solid" "lightseagreen")]
}


@defproc*[([(square [side-len (and/c real? (not/c negative?))]
                    [mode mode?]
                    [color image-color?])
            image?]
           [(square [side-len (and/c real? (not/c negative?))]
                    [outline-mode (or/c 'outline "outline")]
                    [pen-or-color (or/c pen? image-color?)])
            image?])]{

 构造正方形。
 
 @mode/color-and-nitty-text
 
 @image-examples[(square 40 "solid" "slateblue")
                 (square 50 "outline" "darkmagenta")]

}

@defproc*[([(rectangle [width (and/c real? (not/c negative?))]
                       [height (and/c real? (not/c negative?))]
                       [mode mode?]
                       [color image-color?])
            image?]
           [(rectangle [width (and/c real? (not/c negative?))]
                       [height (and/c real? (not/c negative?))]
                       [outline-mode (or/c 'outline "outline")] 
                       [pen-or-color (or/c pen? image-color?)])
            image?])]{
  构造具有给定宽度、高度、mode和颜色的矩形。
  
  @mode/color-and-nitty-text
  
  @image-examples[(rectangle 40 20 "outline" "black")
                  (rectangle 20 40 "solid" "blue")]
}

@defproc*[([(rhombus [side-length (and/c real? (not/c negative?))]
                     [angle angle?]
                     [mode mode?]
                     [color image-color?])
            image?]
           [(rhombus [side-length (and/c real? (not/c negative?))]
                     [angle angle?]
                     [outline-mode (or/c 'outline "outline")]
                     [pen-or-color (or/c pen? image-color?)])
            image?])]{
                 
构造菱形，其四边长相等，对角也相等。它的顶角和底角为@racket[angle]，
左右两个角则为@racket[(- 180 angle)]。

@mode/color-and-nitty-text

@image-examples[(rhombus 40 45 "solid" "magenta")
                (rhombus 80 150 "solid" "mediumpurple")]
}

@defproc*[([(star [side-length (and/c real? (not/c negative?))] 
                  [mode mode?]
                  [color image-color?])
            image?]
           [(star [side-length (and/c real? (not/c negative?))] 
                  [outline-mode (or/c 'outline "outline")]
                  [color (or/c pen? image-color?)])
            image?])]{
  构造五角星。@racket[side-length]参数其确定外接五边形的边长。

  @mode/color-and-nitty-text

  @image-examples[(star 40 "solid" "gray")]
  
}

@defproc*[([(star-polygon [side-length (and/c real? (not/c negative?))]
                          [side-count side-count?]
                          [step-count step-count?]
                          [mode mode?]
                          [color image-color?])
            image?]
           [(star-polygon [side-length (and/c real? (not/c negative?))]
                          [side-count side-count?]
                          [step-count step-count?]
                          [outline-mode (or/c 'outline "outline")]
                          [pen-or-color (or/c pen? image-color?)])
            image?])]{
 
  构造任意的正星形（一种特殊的多边形）。星形由正多边形外接，其边数为@racket[side-count]，
  边长为@racket[side-length]。星形实际上是由连接外接多边形的顶点获得的，
  每次连接第@racket[step-count]个顶点（即跳过@racket[(- step-count 1)]个顶点）。
  
  例如，如果@racket[side-count]为@racket[5]且@racket[step-count]为@racket[2]，
  那么函数就生成和@racket[star]一样的形状。
  
  @mode/color-and-nitty-text

  @image-examples[(star-polygon 40 5 2 "solid" "seagreen")
                  (star-polygon 40 7 3 "outline" "darkred")
                  (star-polygon 20 10 3 "solid" "cornflowerblue")]
 
}
                
@defproc*[([(radial-star [point-count (and/c integer? (>=/c 2))]
                         [inner-radius (and/c real? (not/c negative?))]
                         [outer-radius (and/c real? (not/c negative?))]
                         [mode mode?]
                         [color image-color?])
            image?]
           [(radial-star [point-count (and/c integer? (>=/c 2))]
                         [inner-radius (and/c real? (not/c negative?))]
                         [outer-radius (and/c real? (not/c negative?))]
                         [outline-mode (or/c 'outline "outline")]
                         [pen-or-color (or/c pen? image-color?)])
            image?])]{

构造类似于星形的多边形，其形状由星数和两个半径指定。第一个半径确定星角的开始位置，
第二个半径确定它们的结束位置，@racket[point-count]参数确定星角的总数。

@image-examples[(radial-star 8 8 64 "solid" "darkslategray")
                (radial-star 32 30 40 "outline" "black")]

}

@defproc*[([(regular-polygon [side-length (and/c real? (not/c negative?))] 
                             [side-count side-count?]
                             [mode mode?]
                             [color image-color?])
            image?]
           [(regular-polygon [side-length (and/c real? (not/c negative?))] 
                             [side-count side-count?]
                             [outline-mode (or/c 'outline "outline")]
                             [pen-or-color (or/c pen? image-color?)])
            image?])]{
  构造正多边形，其边数为@racket[side-count]。

  @mode/color-and-nitty-text

  @image-examples[(regular-polygon 50 3 "outline" "red")
                  (regular-polygon 40 4 "outline" "blue")
                  (regular-polygon 20 8 "solid" "red")]
}

@defproc*[([(pulled-regular-polygon [side-length (and/c real? (not/c negative?))]
                                    [side-count side-count?]
                                    [pull (and/c real? (not/c negative?))]
                                    [angle angle?]
                                    [mode mode?]
                                    [color image-color?])
            image?]
           [(pulled-regular-polygon [side-length (and/c real? (not/c negative?))]
                                    [side-count side-count?]
                                    [pull (and/c real? (not/c negative?))]
                                    [angle angle?]
                                    [outline-mode (or/c 'outline "outline")]
                                    [pen-or-color (or/c pen? image-color?)])
            image?])]{
  构造正@racket[side-count]边形，其中每条边都根据@racket[pull]和@racket[angle]参数弯曲。
  @racket[angle]参数控制弯曲的边与多边形原始边之间的角度。
  @racket[pull]参数越大，意味着这个角度在顶点附近被更多地保留。
  
  @mode/color-and-nitty-text

  @image-examples[(pulled-regular-polygon 60 4 1/3 30 "solid" "blue")
                  (pulled-regular-polygon 50 5 1/2 -10 "solid" "red")
                  (pulled-regular-polygon 50 5 1 140 "solid" "purple")
                  (pulled-regular-polygon 50 5 1.1 140 "solid" "purple")
                  (pulled-regular-polygon 100 3 1.8 30 "solid" "blue")]

  @history[#:added "1.3"]
}


@defproc*[([(polygon [vertices (listof (or/c real-valued-posn? pulled-point?))]
                     [mode mode?]
                     [color image-color?])
            image?]
           [(polygon [vertices (listof (or/c real-valued-posn? pulled-point?))]
                     [outline-mode (or/c 'outline "outline")]
                     [pen-or-color (or/c pen? image-color?)])
            image?])]{
  构造连接输入顶点（vertices）的多边形。
  
  @mode/color-and-nitty-text
  
  @image-examples[(polygon (list (make-posn 0 0)
                                 (make-posn -10 20)
                                 (make-posn 60 0)
                                 (make-posn -10 -20))
                           "solid" 
                           "burlywood")
                  (polygon (list (make-pulled-point 1/2 20 0 0 1/2 -20)
                                 (make-posn -10 20)
                                 (make-pulled-point 1/2 -20 60 0 1/2 20)
                                 (make-posn -10 -20))
                           "solid" 
                           "burlywood")
                  (polygon (list (make-posn 0 0)
                                 (make-posn 0 40)
                                 (make-posn 20 40)
                                 (make-posn 20 60)
                                 (make-posn 40 60)
                                 (make-posn 40 20)
                                 (make-posn 20 20)
                                 (make-posn 20 0))
                           "solid" 
                           "plum")
                  (underlay
                   (rectangle 80 80 "solid" "mediumseagreen")
                   (polygon
                    (list (make-posn 0 0)
                          (make-posn 50 0)
                          (make-posn 0 50)
                          (make-posn 50 50))
                    "outline"
                    (make-pen "darkslategray" 10 "solid" "round" "round")))
                  
                  (underlay
                   (rectangle 90 80 "solid" "mediumseagreen")
                   (polygon 
                    (list (make-posn 0 0)
                          (make-posn 50 0)
                          (make-posn 0 50)
                          (make-posn 50 50))
                    "outline"
                    (make-pen "darkslategray" 10 "solid" "projecting" "miter")))]
  
  @history[#:changed "1.3" @list{支持@racket[pulled-point]。}]
}

@defproc[(add-polygon [image image?]
                      [posns (listof posn?)]
                      [mode mode?]
                      [color image-color?])
         image?]{
                 
  向图像@racket[image]添加闭合多边形，其顶点由@racket[posns]（相对于@racket[image]图像左上角）指定。
  与@racket[scene+polygon]不同，如果多边形超出@racket[image]边界，结果会增大以适应之。

@mode/color-and-nitty-text

@image-examples[(add-polygon (square 65 "solid" "light blue")
                             (list (make-posn 30 -20)
                                   (make-posn 50 50)
                                   (make-posn -20 30))
                             "solid" "forest green")
                (add-polygon (square 65 "solid" "light blue")
                             (list (make-posn 30 -20)
                                   (make-pulled-point 1/2 30 50 50 1/2 -30)
                                   (make-posn -20 30))
                             "solid" "forest green")
                (add-polygon (square 180 "solid" "yellow")
                             (list (make-posn 109 160)
                                   (make-posn 26 148)
                                   (make-posn 46 36)
                                   (make-posn 93 44)
                                   (make-posn 89 68)
                                   (make-posn 122 72))
                             "outline" "dark blue")
                (add-polygon (square 50 "solid" "light blue")
                             (list (make-posn 25 -10)
                                   (make-posn 60 25)
                                   (make-posn 25 60)
                                   (make-posn -10 25))
                             "solid" "pink")]
  @history[#:changed "1.3" @list{支持@racket[pulled-point]。}]

}

@defproc[(scene+polygon [image image?]
                        [posns (listof posn?)]
                        [mode mode?]
                        [color image-color?])
         image?]{
  向图像@racket[image]添加闭合多边形，其顶点由@racket[posns]（相对于@racket[image]图像左上角）指定。
  与@racket[add-polygon]不同，如果多边形超出@racket[image]边界，结果将会被剪切。
                                     
@crop-warning

@image-examples[(scene+polygon (square 65 "solid" "light blue")
                               (list (make-posn 30 -20)
                                     (make-posn 50 50)
                                     (make-posn -20 30))
                               "solid" "forest green")
                (scene+polygon (square 65 "solid" "light blue")
                               (list (make-posn 30 -20)
                                     (make-pulled-point 1/2 -30 50 50 1/2 30)
                                     (make-posn -20 30))
                               "solid" "forest green")
                (scene+polygon (square 180 "solid" "yellow")
                               (list (make-posn 109 160)
                                     (make-posn 26 148)
                                     (make-posn 46 36)
                                     (make-posn 93 44)
                                     (make-posn 89 68)
                                     (make-posn 122 72))
                               "outline" "dark blue")
                (scene+polygon (square 50 "solid" "light blue")
                               (list (make-posn 25 -10)
                                     (make-posn 60 25)
                                     (make-posn 25 60)
                                     (make-posn -10 25))
                               "solid" "pink")]

@history[#:changed "1.3" @list{支持@racket[pulled-point]。}]
}


@section{图像的Overlay}

@defproc[(overlay [i1 image?] [i2 image?] [is image?] ...) image?]{
  将所有参数堆叠以得到单个图像。第一个参数被放置于第二个参数之上，
  它又被放置于第三个参数之上，以此类推。所有图像都按各自的中心对齐。

  @image-examples[(overlay (rectangle 30 60 "solid" "orange")
                           (ellipse 60 30 "solid" "purple"))
                  (overlay (ellipse 10 10 "solid" "red")
                           (ellipse 20 20 "solid" "black")
                           (ellipse 30 30 "solid" "red")
                           (ellipse 40 40 "solid" "black")
                           (ellipse 50 50 "solid" "red")
                           (ellipse 60 60 "solid" "black"))
                  (overlay (regular-polygon 20 5 "solid" (make-color  50  50 255))
                           (regular-polygon 26 5 "solid" (make-color 100 100 255))
                           (regular-polygon 32 5 "solid" (make-color 150 150 255))
                           (regular-polygon 38 5 "solid" (make-color 200 200 255))
                           (regular-polygon 44 5 "solid" (make-color 250 250 255)))]
  
  }

@defproc[(overlay/align [x-place x-place?] [y-place y-place?] [i1 image?] [i2 image?] [is image?] ...)
         image?]{
  将所有参数堆叠，类似于@racket[overlay]函数，但使用@racket[x-place]和@racket[y-place]来确定对齐方式。
  例如，如果@racket[x-place]和@racket[y-place]都是@racket["middle"]，那么图像将按其中心点对齐。

  @image-examples[(overlay/align "left" "middle"
                                 (rectangle 30 60 "solid" "orange")
                                 (ellipse 60 30 "solid" "purple"))
                  (overlay/align "right" "bottom"
                                 (rectangle 20 20 "solid" "silver")
                                 (rectangle 30 30 "solid" "seagreen")
                                 (rectangle 40 40 "solid" "silver")
                                 (rectangle 50 50 "solid" "seagreen"))]

  }

@defproc[(overlay/offset [i1 image?] [x real?] [y real?] [i2 image?]) image?]{
  该函数类似于@racket[overlay]，将所有图像参数堆叠。和@racket[overlay]不同的是，
  在overlay图像之前，它会将@racket[i2]向下移@racket[x]像素、向右移@racket[y]像素。
  
  @image-examples[(overlay/offset (circle 40 "solid" "red")
                                  10 10
                                  (circle 40 "solid" "blue"))
                  
                  (overlay/offset (overlay/offset (rectangle 60 20 "solid" "black")
                                                  -50 0
                                                  (circle 20 "solid" "darkorange"))
                                  70 0
                                  (circle 20 "solid" "darkorange"))
                  (overlay/offset
                   (overlay/offset (circle 30 'solid (color 0 150 0 127))
                                   26 0
                                   (circle 30 'solid (color 0 0 255 127)))
                   0 26
                   (circle 30 'solid (color 200 0 0 127)))]
}

@defproc[(overlay/align/offset [x-place x-place?] [y-place y-place?] 
                               [i1 image?] [x real?] [y real?] [i2 image?])
         image?]{
  将图像@racket[i1]叠加在@racket[i2]之上，使用@racket[x-place]和@racket[y-place]作为叠加的起点，
  并将@racket[i2]向下移@racket[x]像素、向右移@racket[y]像素。 
  
  此函数结合了@racket[overlay/align]和@racket[overlay/offset]的功能。
  
  @image-examples[(overlay/align/offset
                   "right" "bottom"
                   (star-polygon 20 20 3 "solid" "navy")
                   10 10
                   (circle 30 "solid" "cornflowerblue"))
                  (overlay/align/offset
                   "left" "bottom"
                   (star-polygon 20 20 3 "solid" "navy")
                   -10 10
                   (circle 30 "solid" "cornflowerblue"))]
  
}

@defproc[(overlay/xy [i1 image?] [x real?] [y real?] [i2 image?]) image?]{
  通过在@racket[i2]上叠加@racket[i1]构造图像。图像先按左上角对齐，
  然后将@racket[i2]向右移@racket[x]像素、向下移y个像素。
  
  等价于@racket[(underlay/xy i2 (- x) (- y) i1)]。

  参见@racket[overlay/offset]及@racket[underlay/offset]。

  @image-examples[(overlay/xy (rectangle 20 20 "outline" "black")
                              20 0
                              (rectangle 20 20 "outline" "black"))
                  (overlay/xy (rectangle 20 20 "solid" "red")
                              10 10
                              (rectangle 20 20 "solid" "black"))
                  (overlay/xy (rectangle 20 20 "solid" "red")
                              -10 -10
                              (rectangle 20 20 "solid" "black"))
                  (overlay/xy 
                   (overlay/xy (ellipse 40 40 "outline" "black")
                               10
                               15
                               (ellipse 10 10 "solid" "forestgreen"))
                   20
                   15
                   (ellipse 10 10 "solid" "forestgreen"))]
}

@defproc[(underlay [i1 image?] [i2 image?] [is image?] ...) image?]{
  将所有参数堆叠以得到单个图像。
  
  本函数类似@racket[overlay]，但以相反的顺序使用参数。也就是说，
  第一个参数被放置于第二个参数之下，第二个参数被放置于第三个参数之下，以此类推。
  所有图像都按各自的中心对齐。

  @image-examples[(underlay (rectangle 30 60 "solid" "orange")
                            (ellipse 60 30 "solid" "purple"))
                  (underlay (ellipse 10 60 "solid" "red")
                            (ellipse 20 50 "solid" "black")
                            (ellipse 30 40 "solid" "red")
                            (ellipse 40 30 "solid" "black")
                            (ellipse 50 20 "solid" "red")
                            (ellipse 60 10 "solid" "black"))
                  (underlay (ellipse 10 60 40 "red")
                            (ellipse 20 50 40 "red")
                            (ellipse 30 40 40 "red")
                            (ellipse 40 30 40 "red")
                            (ellipse 50 20 40 "red")
                            (ellipse 60 10 40 "red"))]
  
  }

@defproc[(underlay/align [x-place x-place?] [y-place y-place?] [i1 image?] [i2 image?]
                         [is image?] ...)
         image?]{
  将所有参数堆叠，类似于@racket[underlay]函数，但使用@racket[x-place]和@racket[y-place]来确定对齐方式。
  例如，如果@racket[x-place]和@racket[y-place]都是@racket["middle"]，那么图像将按其中心点对齐。

  @image-examples[(underlay/align "left" "middle"
                                  (rectangle 30 60 "solid" "orange")
                                  (ellipse 60 30 "solid" "purple"))
                  (underlay/align "right" "top"
                                  (rectangle 50 50 "solid" "seagreen")
                                  (rectangle 40 40 "solid" "silver")
                                  (rectangle 30 30 "solid" "seagreen")
                                  (rectangle 20 20 "solid" "silver"))
                  (underlay/align "left" "middle"
                                  (rectangle 50 50 50 "seagreen")
                                  (rectangle 40 40 50 "seagreen")
                                  (rectangle 30 30 50 "seagreen")
                                  (rectangle 20 20 50 "seagreen"))]

  }


@defproc[(underlay/offset [i1 image?] [x real?] [y real?] [i2 image?]) image?]{
  该函数类似于@racket[underlay]，将所有图像参数堆叠。和@racket[underlay]不同的是，
  在underlay图像之前，它会将@racket[i2]向下移@racket[x]像素、向右移@racket[y]像素。
  
  @image-examples[(underlay/offset (circle 40 "solid" "red")
                                  10 10
                                  (circle 40 "solid" "blue"))
                  
                  (underlay/offset (circle 40 "solid" "gray")
                                   0 -10
                                   (underlay/offset (circle 10 "solid" "navy")
                                                   -30 0
                                                   (circle 10 "solid" "navy")))]
}

@defproc[(underlay/align/offset [x-place x-place?] [y-place y-place?] 
                                [i1 image?]
                                [x real?] [y real?]
                                [i2 image?])
         image?]{
  将图像@racket[i1]放置在@racket[i2]之下，使用@racket[x-place]和@racket[y-place]作为叠加的起点，
  并将@racket[i2]向下移@racket[x]像素、向右移@racket[y]像素。 
  
  此函数结合了@racket[underlay/align]和@racket[underlay/offset]的功能。
  
  @image-examples[(underlay/align/offset
                   "right" "bottom"
                   (star-polygon 20 20 3 "solid" "navy")
                   10 10
                   (circle 30 "solid" "cornflowerblue"))
                  (underlay/align/offset
                   "right" "bottom"
                   (underlay/align/offset
                    "left" "bottom"
                    (underlay/align/offset
                     "right" "top"
                     (underlay/align/offset
                      "left" "top"
                      (rhombus 120 90 "solid" "navy")
                      16 16
                      (star-polygon 20 11 3 "solid" "cornflowerblue"))
                     -16 16
                     (star-polygon 20 11 3 "solid" "cornflowerblue"))
                    16 -16
                    (star-polygon 20 11 3 "solid" "cornflowerblue"))
                   -16 -16
                   (star-polygon 20 11 3 "solid" "cornflowerblue"))]
  
}

@defproc[(underlay/xy [i1 image?] [x real?] [y real?] [i2 image?]) image?]{
  通过在@racket[i1]上叠加@racket[i2]构造图像。图像先按左上角对齐，
  然后将@racket[i2]向右移@racket[x]像素、向下移y个像素。
  
  等价于@racket[(overlay/xy i2 (- x) (- y) i1)]。

  参见@racket[underlay/offset]及@racket[overlay/offset]。

  @image-examples[(underlay/xy (rectangle 20 20 "outline" "black")
                               20 0
                               (rectangle 20 20 "outline" "black"))
                  (underlay/xy (rectangle 20 20 "solid" "red")
                               10 10
                               (rectangle 20 20 "solid" "black"))
                  (underlay/xy (rectangle 20 20 "solid" "red")
                               -10 -10
                               (rectangle 20 20 "solid" "black"))
                  (underlay/xy 
                   (underlay/xy (ellipse 40 40 "solid" "gray")
                                10
                                15
                                (ellipse 10 10 "solid" "forestgreen"))
                   20
                   15
                   (ellipse 10 10 "solid" "forestgreen"))]
}


@defproc[(beside [i1 image?] [i2 image?] [is image?] ...) image?]{
  通过将所有参数图像放在水平行中，沿着它们的中心对齐来构造图像。

  @image-examples[(beside (ellipse 20 70 "solid" "gray")
                          (ellipse 20 50 "solid" "darkgray")
                          (ellipse 20 30 "solid" "dimgray")
                          (ellipse 20 10 "solid" "black"))]

  }

@defproc[(beside/align [y-place y-place?] [i1 image?] [i2 image?] [is image?] ...) image?]{
  通过将所有参数图像放在水平行中构造图像，按@racket[y-place]参数所示对齐。
  例如，如果@racket[y-place]是@racket["middle"]，那么图像中心彼此对齐并排放置。

  @image-examples[(beside/align "bottom"
                                (ellipse 20 70 "solid" "lightsteelblue")
                                (ellipse 20 50 "solid" "mediumslateblue")
                                (ellipse 20 30 "solid" "slateblue")
                                (ellipse 20 10 "solid" "navy"))

                  (beside/align "top"
                                (ellipse 20 70 "solid" "mediumorchid")
                                (ellipse 20 50 "solid" "darkorchid")
                                (ellipse 20 30 "solid" "purple")
                                (ellipse 20 10 "solid" "indigo"))

                  (beside/align "baseline"
                                (text "ijy" 18 "black")
                                (text "ijy" 24 "black"))]

  }


@defproc[(above [i1 image?] [i2 image?] [is image?] ...) image?]{
  通过将所有参数图像放在垂直行中，沿其中心对齐来构造图像。

  @image-examples[(above (ellipse 70 20 "solid" "gray")
                         (ellipse 50 20 "solid" "darkgray")
                         (ellipse 30 20 "solid" "dimgray")
                         (ellipse 10 20 "solid" "black"))]

  }

@defproc[(above/align [x-place x-place?] [i1 image?] [i2 image?] [is image?] ...) image?]{
  通过将所有参数图像放在垂直行中构造图像，按@racket[x-place]参数所示对齐。
  例如，如果@racket[x-place]是@racket["middle"]，那么图像中心彼此对齐垂直放置。

  @image-examples[(above/align "right"
                               (ellipse 70 20 "solid" "gold")
                               (ellipse 50 20 "solid" "goldenrod")
                               (ellipse 30 20 "solid" "darkgoldenrod")
                               (ellipse 10 20 "solid" "sienna"))

                  (above/align "left"
                               (ellipse 70 20 "solid" "yellowgreen")
                               (ellipse 50 20 "solid" "olivedrab")
                               (ellipse 30 20 "solid" "darkolivegreen")
                               (ellipse 10 20 "solid" "darkgreen"))]

  }

@section{图像和场景的放置}

在使用@racket[2htdp/universe]构建world和universe时，将图像放置到场景中特别有用。

@defproc*[([(empty-scene [width (and/c real? (not/c negative?))]
                         [height (and/c real? (not/c negative?))])
            image?]
            [(empty-scene [width (and/c real? (not/c negative?))]
                          [height (and/c real? (not/c negative?))]
                          [color image-color?])
            image?])]{

创建空白场景，即带有黑色边框的白色矩形。

@image-examples[(empty-scene 160 90)]

三参数版本创建具有黑色边框和指定颜色的矩形。
}

@defproc[(place-image [image image?] [x real?] [y real?] [scene image?]) image?]{

 将@racket[image]放入@racket[scene]中，其中心位于坐标（@racket[x],@racket[y]）处，
 然后裁剪生成的图像，使其与@racket[scene]大小相同。坐标相对于@racket[scene]的左上角给出。
  
 @crop-warning
 
 @image-examples[(place-image 
                  (triangle 32 "solid" "red")
                  24 24
                  (rectangle 48 48 "solid" "gray"))
                 
                 (place-image 
                  (triangle 64 "solid" "red")
                  24 24
                  (rectangle 48 48 "solid" "gray"))
                 
                 (place-image
                  (circle 4 "solid" "white")
                  18 20
                  (place-image
                   (circle 4 "solid" "white")
                   0 6
                   (place-image
                    (circle 4 "solid" "white")
                    14 2
                    (place-image
                     (circle 4 "solid" "white")
                     8 14
                     (rectangle 24 24 "solid" "goldenrod")))))]
}
@defproc[(place-image/align [image image?]
                            [x real?]
                            [y real?]
                            [x-place x-place?]
                            [y-place y-place?]
                            [scene image?])
         image?]{

 类似于@racket[place-image]，但使用@racket[image]@racket[x-place]和@racket[y-place]来定位图像。
 此外，与@racket[place-image]一样，@racket[place-image/align]裁剪生成的图像，使其与@racket[scene]大小相同。
  
 @crop-warning
 
 @image-examples[(place-image/align (triangle 48 "solid" "yellowgreen")
                                    64 64 "right" "bottom"
                                    (rectangle 64 64 "solid" "mediumgoldenrod"))
                 (beside 
                  (place-image/align (circle 8 "solid" "tomato")
                                     0 0 "center" "center"
                                     (rectangle 32 32 "outline" "black"))
                  (place-image/align (circle 8 "solid" "tomato")
                                     8 8 "center" "center"
                                     (rectangle 32 32 "outline" "black"))
                  (place-image/align (circle 8 "solid" "tomato")
                                     16 16 "center" "center"
                                     (rectangle 32 32 "outline" "black"))
                  (place-image/align (circle 8 "solid" "tomato")
                                     24 24 "center" "center"
                                     (rectangle 32 32 "outline" "black"))
                  (place-image/align (circle 8 "solid" "tomato")
                                     32 32 "center" "center"
                                     (rectangle 32 32 "outline" "black")))]
}

@defproc[(place-images [images (listof image?)]
                       [posns (listof posn?)]
                       [scene image?])
         image?]{
 
 Places each of @racket[images] into @racket[scene] like 
                @racket[place-image] would, using the coordinates
                in @racket[posns] as the @racket[_x]
                and @racket[_y] arguments to @racket[place-image].
                  
 @crop-warning
                
 @image-examples[(place-images
                  (list (circle 4 "solid" "white")
                        (circle 4 "solid" "white")
                        (circle 4 "solid" "white")
                        (circle 4 "solid" "white"))
                  (list (make-posn 18 20)
                        (make-posn 0 6)
                        (make-posn 14 2)
                        (make-posn 8 14))
                  (rectangle 24 24 "solid" "goldenrod"))]
}


@defproc[(place-images/align [images (listof image?)]
                             [posns (listof posn?)]
                             [x-place x-place?]
                             [y-place y-place?]
                             [scene image?])
         image?]{
 
 类似于@racket[place-images]，不过按照@racket[x-place]和@racket[y-place]放置图像。
                         
 @crop-warning

 @image-examples[(place-images/align
                  (list (triangle 48 "solid" "yellowgreen")
                        (triangle 48 "solid" "yellowgreen")
                        (triangle 48 "solid" "yellowgreen")
                        (triangle 48 "solid" "yellowgreen"))
                  (list (make-posn 64 64) 
                        (make-posn 64 48)
                        (make-posn 64 32)
                        (make-posn 64 16))
                  "right" "bottom"
                  (rectangle 64 64 "solid" "mediumgoldenrod"))]
}
@defproc[(scene+line [scene image?]
                     [x1 real?] [y1 real?]
                     [x2 real?] [y2 real?]
                     [pen-or-color (or/c pen? image-color?)])
         image?]{

  在@racket[scene]中添加从点（@racket[x1],@racket[y1]）到点（@racket[x2],@racket[y2]）的线；
  和@racket[add-line]不同，本函数会将生成的图像裁剪为@racket[scene]大小。
  
  @crop-warning
  
  @image-examples[(scene+line (ellipse 40 40 "outline" "maroon")
                              0 40 40 0 "maroon")
                  (scene+line (rectangle 40 40 "solid" "gray")
                              -10 50 50 -10 "maroon")
                  (scene+line
                   (rectangle 100 100 "solid" "darkolivegreen")
                   25 25 100 100 
                   (make-pen "goldenrod" 30 "solid" "round" "round"))]
}


@defproc[(scene+curve [scene image?] 
                      [x1 real?] [y1 real?] [angle1 angle?] [pull1 real?]
                      [x2 real?] [y2 real?] [angle2 angle?] [pull2 real?]
                      [color (or/c pen? image-color?)])
         image?]{

在@racket[scene]中添加起点为点（@racket[x1],@racket[y1]）、
终点为（@racket[x2],@racket[y2]）的曲线。

参数@racket[angle1]和@racket[angle2]分别指定曲线离开初始点和到达最终点时的角度。

参数@racket[pull1]和@racket[pull2]控制曲线尝试保持该角度的范围。
较大的数字意味着曲线在更大范围内保持角度。

和@racket[add-curve]不同，本函数会裁剪生成的图像，限制于@racket[scene]的大小。

@crop-warning

@image-examples[(scene+curve (rectangle 100 100 "solid" "black")
                             20 20 0 1/3
                             80 80 0 1/3
                             "white")
                (scene+curve (rectangle 100 100 "solid" "black")
                             20 20 0 1 
                             80 80 0 1
                             "white")
                (scene+curve 
                 (add-curve 
                  (rectangle 40 100 "solid" "black")
                  20 10 180 1/2
                  20 90 180 1/2
                  "white")
                 20 10 0 1/2
                 20 90 0 1/2
                 "white")

                (scene+curve (rectangle 100 100 "solid" "black")
                             -20 -20 0 1 
                             120 120 0 1
                             "red")]
}


@section{图像的旋转、缩放、翻转、裁剪和加框}

@defproc[(rotate [angle angle?] [image image?]) image?]{
  逆时针方向旋转@racket[image] @racket[angle]度。
          
          @image-examples[(rotate 45 (ellipse 60 20 "solid" "olivedrab"))
                          (rotate 5 (rectangle 50 50 "outline" "black"))
                          (rotate 45
                                  (beside/align
                                   "center"
                                   (rectangle 40 20 "solid" "darkseagreen")
                                   (rectangle 20 100 "solid" "darkseagreen")))]
          
          参见@seclink["rotate-center"]。
          
}

@defproc[(scale [factor (and/c real? positive?)] [image image?]) image?]{

  缩放@racket[image] @racket[factor]倍。
  
  画笔的尺寸也会缩放，因此得到比原始图像更粗（或更细）的线，除非画笔的大小为@racket[0]。
  该画笔尺寸被特别处理为“可用的最小线”，因此它总是绘制一个像素宽的线；
  这一点对使用@racket[image-color?]而不是@racket[pen]绘制的@racket['outline]和@racket["outline"]图形也成立。
  
         
  @image-examples[(scale 2 (ellipse 20 30 "solid" "blue"))
                   (ellipse 40 60 "solid" "blue")]
  
  
  
}

@defproc[(scale/xy [x-factor (and/c real? positive?)] 
                   [y-factor (and/c real? positive?)]
                   [image image?])
         image?]{
  缩放@racket[image]，水平方向@racket[x-factor]倍，垂直方向@racket[y-factor]倍。 
  
  @image-examples[(scale/xy 3 
                            2 
                            (ellipse 20 30 "solid" "blue")) 
                  (ellipse 60 60 "solid" "blue")]
}

@defproc[(flip-horizontal [image image?]) image?]{
   左右翻转@racket[image]。
         
         不支持翻转文本图像（因此，传给@racket[flip-horizontal]包含@racket[text]或@racket[text/font]的图像会导致错误）。
         
         @image-examples[(beside
                          (rotate 30 (square 50 "solid" "red"))
                          (flip-horizontal
                           (rotate 30 (square 50 "solid" "blue"))))]
}

@defproc[(flip-vertical [image image?]) image?]{
   垂直翻转@racket[image]。
         
         不支持翻转文本图像（因此，传给@racket[flip-vertical]包含@racket[text]或@racket[text/font]的图像会导致错误）。

         @image-examples[(above 
                          (star 40 "solid" "firebrick")
                          (scale/xy 1 1/2 (flip-vertical (star 40 "solid" "gray"))))]
}

@defproc[(crop [x real?]
               [y real?] 
               [width (and/c real? (not/c negative?))]
               [height (and/c real? (not/c negative?))]
               [image image?])
         image?]{

 裁剪@racket[image]到左上角位于（@racket[x],@racket[y]）、宽@racket[width]高@racket[height]的矩形。 
 
 @crop-warning
 
 @image-examples[(crop 0 0 40 40 (circle 40 "solid" "chocolate"))
                 (crop 40 60 40 60 (ellipse 80 120 "solid" "dodgerblue"))
                 (above
                  (beside (crop 40 40 40 40 (circle 40 "solid" "palevioletred"))
                          (crop 0 40 40 40 (circle 40 "solid" "lightcoral")))
                  (beside (crop 40 0 40 40 (circle 40 "solid" "lightcoral"))
                          (crop 0 0 40 40 (circle 40 "solid" "palevioletred"))))]
                 
}

@defproc[(crop/align [x-place x-place?]
                     [y-place y-place?]
                     [width (and/c real? (not/c negative?))]
                     [height (and/c real? (not/c negative?))]
                     [image image?])
         image?]{

 裁剪@racket[image]到宽@racket[width]高@racket[height]并位于@racket[x-place]和@racket[y-place]的矩形。

 @crop-warning

 @image-examples[(crop/align "left" "top" 40 40 (circle 40 "solid" "chocolate"))
                 (crop/align "right" "bottom" 40 60 (ellipse 80 120 "solid" "dodgerblue"))
                 (crop/align "center" "center" 50 30 (circle 25 "solid" "mediumslateblue"))
                 (above
                  (beside (crop/align "right" "bottom" 40 40 (circle 40 "solid" "palevioletred"))
                          (crop/align "left" "bottom" 40 40 (circle 40 "solid" "lightcoral")))
                  (beside (crop/align "right" "top" 40 40 (circle 40 "solid" "lightcoral"))
                          (crop/align "left" "top" 40 40 (circle 40 "solid" "palevioletred"))))]

 @history[#:added "1.1"]
}


@defproc[(frame [image image?]) image?]{
  返回与@racket[image]一样的图像，但在图像的边界绘制黑色、单像素的边框。
  
  @image-examples[(frame (ellipse 40 40 "solid" "gray"))]
  
  一般而言，该函数可以用于调试图像构造函数，
  比如查看某子图像在某较大图像中出现的位置。
  
  @image-examples[(beside
                   (ellipse 20 70 "solid" "lightsteelblue")
                   (frame (ellipse 20 50 "solid" "mediumslateblue"))
                   (ellipse 20 30 "solid" "slateblue")
                   (ellipse 20 10 "solid" "navy"))]
}

@defproc[(color-frame [color (or/c pen? image-color?)] [image image?]) image?]{
  类似于@racket[frame]，但是用给定的@racket[color]。
       
  @history[#:added "1.1"]
}


@section{位图}

DrRacket的@seclink["images" #:doc '(lib "scribblings/drracket/drracket.scrbl")]{插入图片…}菜单项允许将图像插入到程序文本中，
这种图像被视为本库中的图像。

与本库中所有其他图像不同，这种图像（以及由本节所描述的函数创建的图像）被表示为位图，
即，颜色的数组（在某些情况下可能非常大的数组）。这意味着，对它们进行缩放和旋转会导致失真，
并且这类操作和操作其他图形相比昂贵得多。

参见@racketmodname[2htdp/planetcute]库。

@defform/subs[(bitmap bitmap-spec)
              ([bitmap-spec rel-string
                            id])]{

  加载@racket[bitmap-spec]所指定的位图。如果@racket[bitmap-spec]是字符串，它将被视为相对路径。
  如果是标识符，它将被视为require spec，并用于引用collection中的文件。

  @image-examples[(bitmap icons/stop-16x16.png)
                  (bitmap icons/b-run.png)]
}

@defproc[(bitmap/url [url string?]) image?]{
  上网并下载位于@racket[url]的图像。

  每次调用此函数时都会去下载图像，因此更简单的做法可能是使用浏览器下载图像一次，
  然后将其粘贴到程序中，或下载之后使用@racket[bitmap]载入。
}

@defproc[(bitmap/file [ps path-string?]) image?]{
  从@racket[ps]加载图像。

  如果@racket[ps]是相对路径，那么该文件相对于当前目录。（在DrRacket中运行时，
  当前目录就是保存定义窗口的位置，但通常这可以是任意目录。）
}


@defproc[(image->color-list [image image?]) (listof color?)]{
  返回与图像中颜色对应的颜色的链表，从左到右、从上到下读取。
  
  通过在白色背景上绘制图像，然后读取所绘制像素的颜色来获得颜色的表。
  
  @image-examples[(image->color-list (rectangle 2 2 "solid" "black"))
                  (image->color-list
                   (above (beside (rectangle 1 1 "solid" (make-color 1 1 1))
                                  (rectangle 1 1 "solid" (make-color 2 2 2)))
                          (beside (rectangle 1 1 "solid" (make-color 3 3 3))
                                  (rectangle 1 1 "solid" (make-color 4 4 4)))))]
  
}

@defproc[(color-list->bitmap [colors (listof image-color?)] 
                             [width (and/c real? (not/c negative?))]
                             [height (and/c real? (not/c negative?))])
         image?]{
  用@racket[colors]构造位图，其宽度和高度为@racket[width]和@racket[height]。

  @image-examples[(scale
                   40
                   (color-list->bitmap
                    (list "red" "green" "blue")
                    3 1))]
  
  }

@defproc*[([(freeze [image image?]) image?]
           [(freeze [width (and/c real? (not/c negative?))]
                    [height (and/c real? (not/c negative?))]
                    [image image?]) image?]
           [(freeze [x real?]
                    [y real?]
                    [width (and/c real? (not/c negative?))]
                    [height (and/c real? (not/c negative?))]
                    [image image?]) image?])]{
  在内部冻结图像以构建位图：裁剪图像、将裁剪后的图像绘制到位图中，以后使用该图像时都进行位图绘制。
  通常，这是起性能提示用的。当某图像包含许多子图像、并且将被多次绘制（但不会进行缩放或旋转）时，
  使用freeze可以在不改变图像绘制方式的情况下显着提高性能（假设它仅在其边界内绘制；参见@secref["nitty-gritty"]）。
  
  如果@racket[freeze]仅被传入图像参数，它会将图像裁剪到其边界。如果传入三个参数，后两个被当作宽度和高度。
  五个参数则完全指定裁剪图像的位置。
}

@section{图像的属性}

@defproc[(image-width [i image?]) (and/c integer? (not/c negative?) exact?)]{
  返回@racket[i]的宽度。

  @image-examples[(image-width (ellipse 30 40 "solid" "orange"))
                  (image-width (circle 30 "solid" "orange"))
                  (image-width (beside (circle 20 "solid" "orange")
                                       (circle 20 "solid" "purple")))
                  (image-width (rectangle 0 10 "solid" "purple"))]
}

@defproc[(image-height [i image?]) (and/c integer? (not/c negative?) exact?)]{
  返回@racket[i]的高度。
  
  @image-examples[(image-height (ellipse 30 40 "solid" "orange"))
                  (image-height (circle 30 "solid" "orange"))
                  (image-height (overlay (circle 20 "solid" "orange")
                                         (circle 30 "solid" "purple")))
                  (image-height (rectangle 10 0 "solid" "purple"))]
  }

@defproc[(image-baseline [i image?]) (and/c integer? (not/c negative?) exact?)]{
  返回从图像顶部到其基线的距离。图像的基线是任何字母底部的位置，但不计算字母的下降部分，例如“y”、“g”或“j”的尾部。
  
  除非图像是用@racket[text]、@racket[text/font]，或在某些情况下@racket[crop]构造的，
  否则@racket[image-baseline]将与height相同。
  
  @image-examples[(image-baseline (text "Hello" 24 "black"))
                  (image-height (text "Hello" 24 "black"))
                  (image-baseline (rectangle 100 100 "solid" "black"))
                  (image-height (rectangle 100 100 "solid" "black"))]

  @racket[crop]所得的图像的baseline就是新图像的baseline，如果裁剪停留在原图像的边界内。
  但是，如果裁剪实际上放大了图像，那么baseline会变小。
  
  @image-examples[(image-height (rectangle 20 20 "solid" "black"))
                  (image-baseline (rectangle 20 20 "solid" "black"))
                  
                  (image-height (crop 10 10 5 5 (rectangle 20 20 "solid" "black")))
                  (image-baseline (crop 10 10 5 5 (rectangle 20 20 "solid" "black")))
                  
                  (image-height (crop 10 10 30 30 (rectangle 20 20 "solid" "black")))
                  (image-baseline (crop 10 10 30 30 (rectangle 20 20 "solid" "black")))]
                  
}

@section{图像的谓词}

本节列出图像库提供的基本结构体的谓词。

@defproc[(image? [x any/c]) boolean?]{
 判断@racket[x]是否为图像。@racket[ellipse]和@racket[rectangle]等函数返回图像，
 而@racket[overlay]和@racket[beside]等函数读入图像。

 此外，插入DrRacket窗口的图像被视为位图图像，
 @racket[image-snip%]和@racket[bitmap%]的实例也被视为位图图像。
 }

@defproc[(mode? [x any/c]) boolean?]{
 判断@racket[x]是否是可以用来构建图像的mode。
 
 它可以是@racket['solid]、@racket["solid"]、@racket['outline]或@racket["outline"]之一，
 表示形状是否填充。
 
 它也可以是@racket[0]到@racket[255]（包含）之间的整数，表示图像的透明度。
 整数@racket[255]表示完全不透明，等价于@racket["solid"]（或@racket['solid]）。
 整数@racket[0]表示完全透明。
}

@defproc[(image-color? [x any/c]) boolean?]{

  判断@racket[x]是否代表颜色。字符串、符号和@racket[color]结构体被允许用作颜色。

  例如，@racket["magenta"]、@racket["black"]、@racket['orange]和@racket['purple]都是颜色。
  颜色不区分大小写，
  所以@racket["Magenta"]、@racket["Black"]、@racket['Orange]和@racket['Purple]也都是颜色，
  并且和前一个句子中的颜色相同。如果无法识别颜色字符串或符号的名称，就在其位置使用黑色。
  
  完整的颜色列表请见@racket[color-database<%>]，外加透明颜色@racket["transparent"]。

}

@defstruct[color ([red (and/c natural-number/c (<=/c 255))]
                  [green (and/c natural-number/c (<=/c 255))]
                  [blue (and/c natural-number/c (<=/c 255))]
                  [alpha (and/c natural-number/c (<=/c 255))])]{
  @racket[color]结构体通过@racket[red]、@racket[green]、@racket[blue]和@racket[alpha]分量定义颜色，
      每个分量的值在@racket[0]到@racket[255]之间。
      
    @racket[red]、@racket[green]和@racket[blue]字段组合形成一种颜色，其中较高的值意味着更多的色彩。
      例如，@racket[(make-color 255 0 0)]就是鲜红色，而@racket[(make-color 255 0 255)]是亮紫色。
    
      @racket[alpha]alpha字段控制颜色的透明度。
      值@racket[255]表示颜色不透明，@racket[0]表示完全透明。
      
  构造函数@racket[make-color]也可以只读入三个参数，
  分别用于@racket[red]、@racket[green]和@racket[blue]字段，@racket[alpha]字段默认为@racket[255]。
}

@defstruct[pulled-point ([lpull real?]
                         [langle angle?]
                         [x real?]
                         [y real?]
                         [rpull real?]
                         [rangle angle?])]{
  @racket[pulled-point]结构体定义了包含@racket[x]和@racket[y]坐标的点，
      同时也包含两个角度（@racket[langle]和@racket[rangle]）以及两个拉力（@racket[lpull]和@racket[rpull]）。

      这种点可以与@racket[polygon]函数一起使用，控制边线如何弯曲。
      
      前两个（拉力和角度）参数表示进入此点的边线应该如何弯曲。
      angle参数表示边线到达（@racket[x],@racket[y]）时的角度，
      较大的pull参数表示边线应该在更长范围保持角度。
      最后两个参数是相同的，但它们适用于离开此点的边线。
      
  @history[#:added "1.3"]
}

@defproc[(y-place? [x any/c]) boolean?]{
  判断@racket[x]是否是垂直方向的放置选项。它可以是
@racket["top"]、
@racket['top]、
@racket["bottom"]、
@racket['bottom]、
@racket["middle"]、
@racket['middle]、
@racket["center"]、
@racket['center]、
@racket["baseline"]、
@racket['baseline]、
@racket["pinhole"]或
@racket['pinhole]之一。

只有当所有图像参数都有@seclink["pinholes"]{pinhole}时，
才允许使用@racket["pinhole"]或@racket['pinhole]。

有关基线的更多讨论，另请参见@racket[image-baseline]。

}

@defproc[(x-place? [x any/c]) boolean?]{
  判断@racket[x]是否是水平方向的放置选项。它可以是@racket["left"]、
  @racket['left]、
  @racket["right"]、
  @racket['right]、
  @racket["middle"]、
  @racket['middle]、
  @racket["center"]、
  @racket['center]、
  @racket["pinhole"]或
  @racket['pinhole]之一。

  只有当所有图像参数都有@seclink["pinholes"]{pinhole}时，
  才允许使用@racket["pinhole"]或@racket['pinhole]。

}

@defproc[(angle? [x any/c]) boolean?]{
  判断@racket[x]是否是角度，
  即实数（除了@racket[+inf.0]、@racket[-inf.0]和@racket[+nan.0]之外）。 
  
  角度以度为单位，因此0与360相同，90表示圆的四分之一，180表示圆的一半。
}

@defproc[(side-count? [x any/c]) boolean?]{
  判断@racket[x]是否是大于或等于@racket[3]的整数。
}

@defproc[(step-count? [x any/c]) boolean?]{
  判断@racket[x]是否是大于或等于@racket[1]的整数。
}

@defproc[(real-valued-posn? [x any/c]) boolean?]{
  判断@racket[x]是否是@racket[_x]和@racket[_y]字段都是@racket[real?]（实数）的@racket[posn]。
}

@defstruct[pen ([color image-color?]
                [width (and/c real? (<=/c 0 255))]
                [style pen-style?]
                [cap pen-cap?]
                [join pen-join?])]{
  @racket[pen]结构体指定绘图库如何画线。
      
      
      @racket[style]可以使用默认值@racket["solid"]，
      @racket[cap]和@racket[join]字段可以使用默认值@racket["round"]。
      
      width用@racket[0]是特殊的；它表示画出尽可能小但可见的线。
      这意味着无论图像如何缩放，笔的大小始终都是一个像素。
      
      @racket[cap]确定如何绘制曲线的末端。
      
      @racket[join]确定两条线的连接方式。
      
        @image-examples[(line 400 100 (pen "red" 10 "long-dash" "round" "bevel"))
                        (line 400 100 (pen "red" 10 "short-dash" "round" "bevel"))
                        (line 400 100 (pen "red" 10 "long-dash" "butt" "bevel"))
                        (line 400 100 (pen "red" 10 "dot-dash" "butt" "bevel"))
                        (line 400 100 (pen "red" 30 "dot-dash" "butt" "bevel"))]
}

@defproc[(pen-style? [x any/c]) boolean?]{
  判断@racket[x]是否是有效的画笔style。它可以是
  @racket["solid"]、@racket['solid]、
  @racket["dot"]、@racket['dot]、
  @racket["long-dash"]、@racket['long-dash]、
  @racket["short-dash"]、@racket['short-dash]、
  @racket["dot-dash"]或@racket['dot-dash]之一。
}

@defproc[(pen-cap? [x any/c]) boolean?]{
  判断@racket[x]是否是有效的画笔cap。它可以是
  @racket["round"]、@racket['round]、
  @racket["projecting"]、@racket['projecting]、
  @racket["butt"]或@racket['butt]之一。
}

@defproc[(pen-join? [x any/c]) boolean?]{
  判断@racket[x]是否是有效的画笔join。它可以是
  @racket["round"]、@racket['round]、
  @racket["bevel"]、@racket['bevel]、 
  @racket["miter"]或@racket['miter]之一。
}

@section{图像相等}

如果两个图像以其当前大小（并非是所有大小）绘制完全相同，那么它们@racket[equal?]，
此外，如果存在pinhole，pinhole必须位于相同的位置。

这可能会导致一些反直觉的结果。
例如，两个完全不同的形状，只要大小相同，且都用透明颜色绘制，就是相等的：
@image-examples[(equal? (circle 30 "solid" "transparent")
                        (square 60 "solid" "transparent"))]
参见@secref["nitty-gritty-alpha"]。

@section[#:tag "pinholes"]{Pinhole}

pinhole是图像的可选属性，用于标识图像中的某个点。
使用pinhole可以方便地叠加图像，按pinhole对齐。

当图像有pinhole时，pinhole在图像上以十字线形式绘制。
十字线使用两条各一像素宽的黑色线（一条水平线、一条垂直线）和两条各一条像素宽的白色线绘制，
黑色线位于pinhole左侧和上方.5个像素，白色线位于pinhole右侧和下方.5像素。
因此，当像素坐标为整数时，黑线和白线都占据单个像素，并且实际的pinhole位于它们交叉点的中心。
有关像素的更多详细信息，请参阅@secref["nitty-gritty"]。

当使用@racket[overlay]、@racket[underlay]（以及它们的变体），
@racket[beside]或@racket[above]放置图像时，所得图像的pinhole是第一个图像参数的pinhole。
当使用@racket[place-image]（或其变体）组合图像时，场景参数的pinhole将被保留。

@defproc[(center-pinhole [image image?]) image?]{
  在@racket[image]中心创建pinhole。
  @image-examples[(center-pinhole (rectangle 40 20 "solid" "red"))
                  (rotate 30 (center-pinhole (rectangle 40 20 "solid" "orange")))]
}
@defproc[(put-pinhole [x integer?] [y integer?] [image image?]) image?]{
  在@racket[image]的点（@racket[x],@racket[y]）处创建pinhole。
  @image-examples[(put-pinhole 2 18 (rectangle 40 20 "solid" "forestgreen"))]
}
@defproc[(pinhole-x [image image?]) (or/c integer? #f)]{
  返回@racket[image] pinhole的x坐标。
  @image-examples[(pinhole-x (center-pinhole (rectangle 10 10 "solid" "red")))]
}
@defproc[(pinhole-y [image image?]) (or/c integer? #f)]{
  返回@racket[image] pinhole的y坐标。
  @image-examples[(pinhole-y (center-pinhole (rectangle 10 10 "solid" "red")))]
}
@defproc[(clear-pinhole [image image?]) image?]{
  从@racket[image]中移除pinhole（如果图像有pinhole的话）。
}

@defproc[(overlay/pinhole [i1 image?] [i2 image?] [is image?] ...) image?]{
  
  对齐pinhole，overlay所有图像参数。如果任何参数没有pinhole，就使用图像的中心。
  
  @image-examples[(overlay/pinhole
                   (put-pinhole 25 10 (ellipse 100 50 "solid" "red"))
                   (put-pinhole 75 40 (ellipse 100 50 "solid" "blue")))
                  (let ([petal (put-pinhole 
                                20 20
                                (ellipse 100 40 "solid" "purple"))])
                    (clear-pinhole
                     (overlay/pinhole
                      (circle 30 "solid" "yellow")
                      (rotate (* 60 0) petal)
                      (rotate (* 60 1) petal)
                      (rotate (* 60 2) petal)
                      (rotate (* 60 3) petal)
                      (rotate (* 60 4) petal)
                      (rotate (* 60 5) petal))))]
}

@defproc[(underlay/pinhole [i1 image?] [i2 image?] [is image?] ...) image?]{
  
  对齐pinhole，underlay所有图像参数。如果任何参数没有pinhole，就使用图像的中心。
  
  @image-examples[(underlay/pinhole
                   (put-pinhole 25 10 (ellipse 100 50 "solid" "red"))
                   (put-pinhole 75 40 (ellipse 100 50 "solid" "blue")))
                  (let* ([t (triangle 40 "solid" "orange")]
                         [w (image-width t)]
                         [h (image-height t)])
                    (clear-pinhole
                     (overlay/pinhole
                      (put-pinhole (/ w 2) 0 t)
                      (put-pinhole w h t)
                      (put-pinhole 0 h t))))]
}

@;-----------------------------------------------------------------------------
@section{将图像导出到磁盘}

要将图像用作另一程序（例如Photoshop或网页浏览器）的输入，就有必要以这些程序可以理解的格式表示它。

@racket[save-image]函数提供此功能，使用@tt{PNG}格式将图像写入磁盘。
由于此格式使用像素值表示图像，因此写入磁盘的图像通常会丢失信息，
而且无法干净地缩放或操作（使用任何图像程序都不行）。

@racket[save-svg-image]函数将文件以@tt{SVG}格式写入磁盘，与@racket[save-image]不同，
保存的图像仍然可以任意缩放，看起来就和使用@racket[scale]缩放图像一样好。

@defproc[(save-image [image image?]
                     [filename path-string?]
                     [width 
                      (and/c real? (not/c negative?))
                      (image-width image)]
                     [height 
                      (and/c real? (not/c negative?))
                      (image-height image)])
         boolean?]{
 使用@tt{PNG}格式将图像写入@racket[filename]所指定的路径。
 
 最后两个参数是可选的。如果有的话，它们确定被保存图像文件的宽度和高度。
 如果没有，就使用图像的宽度和高度。
 
 }

@defproc[(save-svg-image [image image?]
                         [filename path-string?]
                         [width 
                          (and/c real? (not/c negative?))
                          (image-width image)]
                         [height 
                          (and/c real? (not/c negative?))
                          (image-height image)])
         void?]{
 使用@tt{SVG}格式将图像写入@racket[filename]所指定的路径。
 
 最后两个参数是可选的。如果有的话，它们确定被保存图像文件的宽度和高度。
 如果没有，就使用图像的宽度和高度。
 }

@(close-eval img-eval)