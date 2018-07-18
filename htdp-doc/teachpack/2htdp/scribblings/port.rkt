#lang scheme

(require scribble/core)

(define (port old new)
  (make-table 
   (make-style 'boxed '())
   (list           
    (list (make-paragraph plain "世界形式") (make-paragraph plain "宇宙形式"))
    (list old new))))

(provide port)
