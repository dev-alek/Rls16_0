/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с примечанием к продаже  - извлечение данных и наоборот

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i }
FUNCTION set-inkas-PS returns character(    input p-ps as character,
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer,
                                            input p-ps-where-rus as character
                                            ):
define variable v-ps as character no-undo .
define variable v-other as character no-undo .
v-other = p-ps.
entry(1, v-other, "@") = ''.
v-other = trim(v-other, "@").
v-PS = substitute('Кол-во_чеков &2&1строк_чеков &3&1товаров_расход &4&1признаков_расход &5&1товаров_возврат &6&1признаков_возврат &7&1'
                    , {&delim-par}
                    , p-chk-amount
                    , p-gds-amount
                    , p-line-out
                    , p-dtl-out
                    , p-line-ret
                    , p-dtl-ret).
v-ps = v-ps +  substitute("без_докум_чеков &1&2без_докум_строк_чеков &3&2&4@&5"
                            , p-nf-chk-amount
                            , {&delim-par}
                            , p-nf-gds-amount
                            , p-ps-where-rus
                            , v-other)
                    .
return v-ps.
END FUNCTION.

FUNCTION set-inkas-PS-simple returns character(
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer
                                            ):
define variable v-ps as character no-undo .
define variable v-str1 as character no-undo .

assign
  v-ps = fill( {&space-char} +  {&delim-par}, 9).
  
  v-str1 = ENTRY(1, v-PS, {&delim-par}).
  entry(2, v-str1, {&space-char})  = string(p-chk-amount).
  ENTRY(1, v-PS, {&delim-par}) = v-str1.

  v-str1 = ENTRY(2, v-PS, {&delim-par}).
  entry(2, v-str1, {&space-char})  = string(p-gds-amount).
  ENTRY(2, v-PS, {&delim-par}) = v-str1.
  
  v-str1 = ENTRY(3, v-PS, {&delim-par}).
  entry(2, v-str1, {&space-char})  = string(p-line-out).
  ENTRY(3, v-PS, {&delim-par}) = v-str1.
  
  v-str1 = ENTRY(4, v-PS, {&delim-par}).
  entry(2, v-str1, {&space-char})  = string(p-dtl-out).
  ENTRY(4, v-PS, {&delim-par}) = v-str1.
  
  v-str1 = ENTRY(5, v-PS, {&delim-par}).
  entry(2, v-str1, {&space-char})  = string(p-line-ret).
  ENTRY(5, v-PS, {&delim-par}) = v-str1.
  
  v-str1 = ENTRY(6, v-PS, {&delim-par}).
  entry(2, v-str1, {&space-char})  = string(p-dtl-ret).
  ENTRY(5, v-PS, {&delim-par}) = v-str1.
  
  v-str1 = ENTRY(7, v-PS, {&delim-par}).
  entry(2, v-str1, {&space-char})  = string(p-nf-chk-amount).
  ENTRY(5, v-PS, {&delim-par}) = v-str1.
  
  v-str1 = ENTRY(8, v-PS, {&delim-par}).
  entry(2, v-str1, {&space-char})  = string(p-nf-gds-amount).
  ENTRY(5, v-PS, {&delim-par}) = v-str1.


/*  entry(2, ENTRY(1, v-PS, {&delim-par}), {&space-char})  = string(p-chk-amount).
  entry(2, ENTRY(2, v-PS, {&delim-par}), {&space-char})  = string(p-gds-amount).
  entry(2, ENTRY(3, v-PS, {&delim-par}), {&space-char}) = string(p-line-out).
  entry(2, ENTRY(4, v-PS, {&delim-par}), {&space-char}) = string(p-dtl-out).
  entry(2, ENTRY(5, v-PS, {&delim-par}), {&space-char}) = string(p-line-ret).
  entry(2, ENTRY(6, v-PS, {&delim-par}), {&space-char}) = string(p-dtl-ret).
  entry(2, ENTRY(7, v-PS, {&delim-par}), {&space-char})  = string(p-nf-chk-amount).
  entry(2, ENTRY(8, v-PS, {&delim-par}), {&space-char})  = string(p-nf-gds-amount).*/

return v-ps.
END FUNCTION.

FUNCTION get-inkas-nf-PS-simple returns logical (
                                             input p-ps as character
                                            ,output p-gds-amount as integer
                                            ,output p-nf-gds-amount as integer
                                            ):
if num-entries(p-ps, {&delim-par}) >= 8 then do:
  assign
  p-gds-amount = integer(entry(2, ENTRY(2, p-PS, {&delim-par}), {&space-char}))
  p-nf-gds-amount = integer(entry(2, ENTRY(8, p-PS, {&delim-par}), {&space-char}))
  no-error .
end.
return not error-status:error .
END FUNCTION.


PROCEDURE get-inkas-PS:
define parameter buffer buf_inkas for ub.inkas.
define output parameter p-chk-amount as integer no-undo .
define output parameter p-gds-amount as integer no-undo .
define output parameter p-line-out as integer no-undo .
define output parameter p-dtl-out as integer no-undo .
define output parameter p-line-ret as integer no-undo .
define output parameter p-dtl-ret as integer no-undo .
define output parameter p-nf-chk-amount as integer no-undo .
define output parameter p-nf-gds-amount as integer no-undo .
define output parameter p-ps-where-rus as character no-undo .

define variable v-gds-amount as integer no-undo .
define variable v-nf-gds-amount as integer no-undo .

define buffer buf_sale-doc for ub.sale-doc.
for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = buf_inkas.inkas-code
    and buf_sale-doc.order > 0:
  assign
  p-gds-amount = p-gds-amount + (if buf_sale-doc.in-inkas = yes
                                 or buf_sale-doc.doc-kind = {&sale-add-tech-refuell}
                                 then buf_sale-doc.gds-amount
                                 else 0)
  p-line-out = p-line-out  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = 1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-out = p-dtl-out + (if buf_sale-doc.in-inkas = yes
                          and buf_sale-doc.dir = 1
                          then buf_sale-doc.tot-dtl
                          else 0)
  p-line-ret = p-line-ret  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = -1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-ret = p-dtl-ret + (if buf_sale-doc.in-inkas = yes
                           and buf_sale-doc.dir = -1
                          then buf_sale-doc.tot-dtl
                          else 0)
  .
end.
if get-inkas-nf-PS-simple( input buf_inkas.ps
                          ,output v-gds-amount
                          ,output v-nf-gds-amount) then do:
  assign
  p-gds-amount = v-gds-amount
  p-nf-gds-amount = v-nf-gds-amount
  .
end.
assign
p-ps-where-rus = buf_inkas.sale-filter-rus
p-nf-chk-amount = buf_inkas.num-chk-nf
p-chk-amount = buf_inkas.num-chk
.
END PROCEDURE.

/* $Workfile$ e n d */