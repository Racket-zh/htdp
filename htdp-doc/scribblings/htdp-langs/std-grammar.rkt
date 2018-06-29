#reader scribble/reader
#lang racket/base
(require "common.rkt"
         scribble/decode)

(provide prim-nonterms
         racketgrammar*+library
         racketgrammar*+qq)

(define ex-str "This is a string with \" inside")

(define-syntax-rule (racketgrammar*+library
                     #:literals lits
                     (rhs-satisfied check-satisfied check-expect check-random check-within check-member-of check-range check-error require)
                     form ...)
  (racketgrammar*
   #:literals lits
   form ...
   [test-case @#,racket[(check-expect expr expr)]
              @#,racket[(check-random expr expr)]
              @#,racket[(check-within expr expr expr)]
              @#,racket[(check-member-of expr expr (... ...))]
              @#,racket[(check-range expr expr expr)]
              @#,racket[(check-satisfied expr rhs-satisfied)]
              @#,racket[(check-error expr expr)]
              @#,racket[(check-error expr)]]
   (...
    [library-require @#,racket[(require string)]
                     @#,racket[(require (lib string string ...))]
                     @#,racket[(require (planet string package))]])
   (...
    [package @#,racket[(string string number number)]])))

(define-syntax-rule (racketgrammar*+qq 
                     #:literals lits
                     (rhs-satisfied check-satisfied check-expect check-random check-within check-member-of check-range check-error require)
                     form ...)
  (racketgrammar*+library
   #:literals lits
   (rhs-satisfied check-satisfied check-expect check-random check-within check-member-of check-range check-error require)
   form ...
   (...
    [quoted name
            number
            string
            character
            @#,racket[(quoted ...)]
            @#,elem{@racketvalfont{'}@racket[quoted]}
            @#,elem{@racketvalfont{`}@racket[quoted]}
            @#,elem{@racketfont{,}@racket[quoted]}
            @#,elem{@racketfont[",@"]@racket[quoted]}])
   (...
    [quasiquoted name
                 number
                 string
                 character
                 @#,racket[(quasiquoted ...)]
                 @#,elem{@racketvalfont{'}@racket[quasiquoted]}
                 @#,elem{@racketvalfont{`}@racket[quasiquoted]}
                 @#,elem{@racketfont{,}@racket[expr]}
                 @#,elem{@racketfont[",@"]@racket[expr]}])))

(define-syntax-rule (prim-nonterms (section-prefix) define define-struct)
  
  (make-splice
   (list

@t{@racket[_name]或@racket[_variable]是不包含空格或下列字符的字符串：}

@t{@hspace[2] @litchar{"} @litchar{,} @litchar{'} @litchar{`}
@litchar{(} @litchar{)} @litchar{[} @litchar{]}
@litchar["{"] @litchar["}"] @litchar{|} @litchar{;}
@litchar{#}}

@t{@racket[_number]是类似@racket[123]，@racket[3/2]或@racket[5.5]的数。}

@t{@racket[_boolean]是@code{#true}或@code{#false}之一。常量@code{#true}的其他拼写方式是：@racket[#t]、@racket[true]和@code{#T}。同理，@code{#f}、@racket[false]或@code{#F}都被认为是@code{#false}。}

@t{@racket[_symbol]是引号字符后跟name。符号是一种值，就和@code{42}、@code{'()}或@code{#false}一样。}

@t{@racket[_string]是由一对@litchar{"}包围的字符序列。与符号不同，字符串可以被分割成字符，或者用各种函数操作。例如，@racket["abcdef"]、@racket["This is a string"]和@racket[#,ex-str]都是字符串。}

@t{@racket[_character]由@litchar{#\}开始，并包含该字符的名称。例如，@racket[#\a]、@racket[#\b]和@racket[#\space]都是字符。}

@t{在@seclink[(string-append section-prefix "-syntax")]{函数调用}中，紧跟开括号出现的函数可以是由@racket[define]或@racket[define-struct]定义的任意函数，或者是任何的@seclink[(string-append section-prefix "-pre-defined")]{预定义函数}。}

)))

