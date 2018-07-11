#lang scribble/doc

@(require scribble/manual "shared.rkt"
          (for-label scheme teachpack/htdp/arrow))

@teachpack["arrow"]{管理控制箭头}

@;declare-exporting[teachpack/htdp/arrow]
@defmodule[#:require-form beginner-require htdp/arrow]

本教学包实现了用于在画布上移动图形的控制函数。

@defproc[(control-left-right
	   [shape Shape]
	   [n number?]
	   [move (-> number? Shape Shape)]
	   [draw (-> Shape true)]) true]{
向左（负数）或向右（正数）移动shape @racket[n]像素。} 

@defproc[(control-up-down
	   [shape Shape]
	   [n number?]
	   [move (-> number? Shape Shape)]
	   [draw (-> Shape true)]) true]{
向上（负数）或向下（正数）移动shape @racket[n]像素。} 

@defproc[(control
	   [shape Shape]
	   [n number?]
	   [move-lr (-> number? Shape Shape)]
	   [move-ud (-> number? Shape Shape)]
	   [draw (-> Shape true)]) true]{
向任意方向移动shape @racket[N]像素。} 

示例：
@(begin
#reader scribble/comment-reader
(racketblock 
;; shape是结构体：
;;   (make-posn num num)

;; RAD ：（在画布上移动的简单）圆盘的半径
(define RAD 10)

;; move : number shape -> shape or false
;; 将shape平移delta像素：重新绘制
(define (move delta sh)
  (cond
    [(and (clear-solid-disk sh RAD)
          (draw-solid-disk (translate sh delta) RAD))
     (translate sh delta)]
    [else false]))

;; translate : shape number -> shape
;; 在x方向平移shape delta（像素）
(define (translate sh delta)
  (make-posn (+ (posn-x sh) delta) (posn-y sh)))

;; draw-it : shape -> true
;; 在画布上绘制shape：半径为RAD的圆盘
(define (draw-it sh)
  (draw-solid-disk sh RAD))

;; 运行：

;; 创建画布
(start 100 50)

;; 创建控制GUI
(control-left-right (make-posn 10 20) 10 move draw-it)
))
