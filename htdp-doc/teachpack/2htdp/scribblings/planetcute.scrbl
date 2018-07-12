#lang scribble/doc

@(require "shared.rkt" 
          "port.rkt"
          scribble/manual
          scribble/eval
          2htdp/image
          racket/runtime-path
          (except-in racket/draw make-color make-pen)
          racket/class
          (for-syntax racket/base)
          (for-label 2htdp/image
                     2htdp/planetcute
                     (only-in lang/htdp-beginner first list rest empty? define cond)))

@; -----------------------------------------------------------------------------

@title{Planet Cute图像}

@defmodule[2htdp/planetcute]

@(define pc-eval (make-base-eval))
@(interaction-eval #:eval pc-eval (require 2htdp/image 2htdp/planetcute racket/list))

@racketmodname[2htdp/planetcute]库包含了Daniel Cook
(Lostgarden.com)的@link["http://www.lostgarden.com/2007/05/dancs-miraculously-flexible-game.html"]{Planet Cute}艺术。

这些图像被设计成能彼此重叠的，可以用于构建游戏的场景。
下面是Planet Cute网站上的示例图片。

@racketblock+eval[#:eval 
                  pc-eval
                  (code:comment "stack : non-empty-list-of-images -> image")
                  (code:comment "将'imgs'堆叠起来，彼此相隔40个像素")
                  (define (stack imgs)
                    (cond
                      [(empty? (rest imgs)) (first imgs)]
                      [else (overlay/xy (first imgs)
                                        0 40
                                        (stack (rest imgs)))]))]
@interaction[#:eval 
             pc-eval
             (beside/align
              "bottom"
              (stack (list wall-block-tall stone-block))
              (stack (list character-cat-girl
                           stone-block stone-block
                           stone-block stone-block))
              water-block
              (stack (list grass-block dirt-block))
              (stack (list grass-block dirt-block dirt-block)))]

@(close-eval pc-eval)

Planet Cute图像还包含一些阴影，可以用来改善游戏的外观；
关于如何使用它们的概述，请参阅@secref["pc:Shadows"]部分。

@(require (for-syntax 2htdp/private/planetcute-image-list))
@(define-for-syntax (translate str)
   (case str
     ((Characters) "人物")
     ((Blocks) "方块")
     ((Items) "物品")
     ((Ramps) "斜坡")
     ((Buildings) "房屋")
     ((Shadows) "阴影")))
@(define-syntax (defthings stx)
   (syntax-case stx ()
     [(_ what whatever ...)
      (identifier? #'what)
      (let* ([sym (syntax-e #'what)]
             [sec-title (symbol->string sym)]
             [title-chinese (translate sym)]
             [these-images (cdr (assoc sym images))])
        #`(begin
            @section[#:tag #,(format "pc:~a" sec-title) #,title-chinese]
            whatever ...
            #,@(for/list ([img (in-list these-images)])
                 (define req (string->symbol (format "2htdp/planetcute/~a" (name->filename img))))
                 #`@defthing[#,img image?]{  @(bitmap #,req) })))]))

@(begin
   (define-runtime-path PlanetCuteShadow1.png "PlanetCuteShadow1.png")
   (define-runtime-path PlanetCuteShadow2.png "PlanetCuteShadow2.png")
   (define-runtime-path PlanetCuteShadow2b.png "PlanetCuteShadow2b.png")
   (define-runtime-path PlanetCuteShadow3.png "PlanetCuteShadow3.png"))

@defthings[Characters]{}
@defthings[Blocks]{}
@defthings[Items]{}
@defthings[Ramps]{}
@defthings[Buildings]{}
@defthings[Shadows]{阴影图像的目的是，当其他方块按这里所描述的排列时，叠加到它们之上。
                    
                    @(read-bitmap PlanetCuteShadow1.png) 
                    @(read-bitmap PlanetCuteShadow2.png)
                    @(read-bitmap PlanetCuteShadow2b.png)
                    @(read-bitmap PlanetCuteShadow3.png) }
