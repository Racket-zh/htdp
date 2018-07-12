#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label scheme teachpack/htdp/matrix htdp/matrix lang/posn))

@teachpack["matrix"]{矩阵函数}

@;declare-exporting[teachpack/htdp/matrix]
@defmodule[#:require-form beginner-require htdp/matrix]

本实验性教学包提供对矩阵和矩阵函数的支持。矩阵就是矩形的“对象”。它被显示为图像，
就和@secref["image"]中的图像一样。事实上，矩阵就是图像，
或者按@secref["world"]的说法，是场景。

@emph{目前不存在关于矩阵的教育材料。}

函数以通常（学校中数学）的方式访问矩阵：先访问行，再访问列。

这些函数没有针对效率进行优化，因此不要期望构建处理大量数据的程序。

@deftech{Rectangle} 
（X的）Rectangle（矩形）是包含X的、非空表的表，其中所有项的表都是等长的（且长度不为零）。

@defproc[(matrix? [o any/c]) boolean?]{
判断输入对象是否是矩阵}

@defproc[(matrix-rows [m matrix?]) natural-number/c]{
求矩阵@racket[m]的行数}

@defproc[(matrix-cols [m matrix?]) natural-number/c]{
求矩阵@racket[m]的列数}

@defproc[(rectangle->matrix [r (unsyntax @tech{Rectangle})]) matrix?]{
由@tech{Rectangle}创建矩阵}

@defproc[(matrix->rectangle [m matrix?]) (unsyntax @tech{Rectangle})]{
由矩阵@racket[m]创建rectangle}

@defproc[(make-matrix [n natural-number/c][m natural-number/c][l (Listof X)]) matrix?]{
由@racket[l]创建@racket[n]乘@racket[m]的矩阵

注意：如果像@racket[make-vector]那样处理的话，@racket[make-matrix]将读入可选的条目数量。}

@defproc[(build-matrix 
  [n natural-number/c][m natural-number/c]
  [f (-> (and/c natural-number/c (</c m)) 
	 (and/c natural-number/c (</c n))
	 any/c)])
 matrix?]{
通过将@racket[f]应用于@racket[(0,0)]、@racket[(0,1)]、……、(@racket[(sub1 m),(sub1 n)])来创建@racket[n]乘@racket[m]的矩阵}

@defproc[(matrix-ref [m matrix?][i (and/c natural-number/c (</c (matrix-rows m)))][j (and/c natural-number/c (</c (matrix-rows m)))]) any/c]{
取矩阵@racket[m]中的(@racket[i],@racket[j])项}

@defproc[(matrix-set [m matrix?][i (and/c natural-number/c (</c (matrix-rows m)))][j (and/c natural-number/c (</c (matrix-rows m)))] 
		     [x any/c]) 
         matrix?]{
创建新矩阵，其中(@racket[i],@racket[j])位置为@racket[x]，所有其他位置与@racket[m]相同}

@defproc[(matrix-where? [m matrix?] [pred? (-> any/c boolean?)]) (listof posn?)]{
@racket[(matrix-where? M P)]生成@racket[(make-posn i j)]的表，
其中@racket[(P (matrix-ref M i j))]都成立}

@defproc[(matrix-render [m matrix?]) (unsyntax @tech{Rectangle})]{
将此矩阵@racket[m]呈现为字符串的rectangle}

@defproc[(matrix-minor [m matrix?][i (and/c natural-number/c (</c (matrix-rows m)))][j (and/c natural-number/c (</c (matrix-rows m)))]) 
          matrix?]{ 
由@racket[m]创建位于(@racket[i],@racket[j])的子矩阵}

@;defproc[(matrix-set! [m matrix?][i (and/c natural-number/c (</c (matrix-rows m)))][j (and/c natural-number/c (</c (matrix-rows m)))] [x any/c]) matrix?]{like @racket[matrix-set] but uses a destructive update}

@; -----------------------------------------------------------------------------

@section{矩阵片断}

@(require (for-label (only-in mrlib/cache-image-snip cache-image-snip%)))

@;defmodule[htdp/matrix]

@racket[htdp/matrix]教学包export @racket[snip-class]对象，用于支持保存和读取矩阵片断。

@defthing[snip-class (instance/of matrix-snip-class%)]{支持2D矩阵呈现的对象。}
