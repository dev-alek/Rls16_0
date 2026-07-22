block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ap.p $
$Archive: rep/r-ap.p $

АКТ проработки

Автор: Чернова Светлана Александровна
Дата создания: 11/21/03
Author: Svetlana Chernova
Creation date: 11/21/03

*/

define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-recipe-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ap.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ap.p $":U .
define variable vss-description as character no-undo init "АКТ проработки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i new }
{ rep/r-cliprp.i def }
{ gbl/getcntxt.i def }


do
on error undo, return error return-value
:
define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).
{ gbl/getcntxt.i get }

define buffer buf_recipe for ub.recipe .
define buffer buf_recipe-develop for ub.recipe-develop.

define variable   sort-name   as logical no-undo.
define variable   sort-gr     as logical no-undo.
define variable   print-graft as logical no-undo.   /* "Отладочная печать" */
define variable   summ as decimal no-undo .
define variable   fact-order-1 as decimal no-undo .
define variable   fact-order-2 as decimal no-undo .

sort-gr     = true  .
sort-name   = false .
print-graft = true  .



define variable sort-group as logical   no-undo .
if sort-gr
    then assign sort-group = yes .
    else assign sort-group = no .


define variable name-raz as character no-undo .
define variable temp-doc-code  as character no-undo .
define variable temp-sum-fact  as decimal   no-undo .
define variable temp-fact-date as date      no-undo .
define variable temp-sum-cost  as decimal   no-undo .

define variable sum-crsa  as decimal   no-undo .
define variable sum-cost  as decimal   no-undo .


define temp-table temp-str no-undo
field n           as INT format ">>>>9"
field gds-name     as char format "X(25)"
field gds-code     as integer  format ">>>>>>>>9"
field artic         as character
field prod-type     as character
field prod-code     as int
field EDIZM         as character
field BRUTTO        as decimal  format ">>>>>9.<<<"
field NETTO         as decimal  format ">>>>>9.<<<"
field BRUTTO1        as decimal  format ">>>>>9.<<<"
field NETTO1         as decimal  format ">>>>>9.<<<"
field BRUTTO2        as decimal  format ">>>>>9.<<<"
field NETTO2         as decimal  format ">>>>>9.<<<"
field BRUTTO3        as decimal  format ">>>>>9.<<<"
field NETTO3         as decimal  format ">>>>>9.<<<"
index pi  gds-code  n
.


define stream  OutStream  .

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define variable n-recipe-code  as character no-undo .
define variable n-porc as integer no-undo .
define variable num-re as character no-undo .
define variable qnt-delta as decimal no-undo .

define buffer buf_clients for  ub.clients .
define buffer This_Object for  ub.clients .

define variable qnty as decimal   no-undo .
define variable sum  as decimal   no-undo .

define variable crsa-rubl-start    as decimal no-undo .
define variable crsa-base-start    as decimal no-undo .
define variable cost-rubl-start    as decimal no-undo .
define variable cost-base-start    as decimal no-undo .
define variable crsa-rubl-end      as decimal no-undo .
define variable crsa-base-end      as decimal no-undo .
define variable cost-rubl-end      as decimal no-undo .
define variable cost-base-end      as decimal no-undo .

define variable num-ln as integer   no-undo .

define variable FullNameGds as character no-undo .
define variable gds-str as char no-undo.
define variable gds-str1 as char no-undo.
define variable gds-str2 as char no-undo.
define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.

define variable     tdoc-date     like fbr-pln.doc-date no-undo.
define variable     tdoc-code     like fbr-pln.doc-code no-undo.

define variable  abbr              as  char no-undo.
define variable  pp-a              as  char no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .
define variable vv5 as character no-undo .
define variable vv6 as character no-undo .
define variable vv7 as character no-undo .
define variable vv8 as character no-undo .
define variable vv9 as character no-undo .
define variable vv10 as character no-undo .


{ rep/r-sym.i }


define variable t-1 as character no-undo .
define variable t-2 as character no-undo .
define variable t-3 as character no-undo .
define variable t-4 as character no-undo .
define variable t-5 as character no-undo .

DEFINE FRAME plan-menu
    sym1                format "X(1)"        space(0)
    temp-str.n          format ">>>>>>>9"        space(0)
    sym2                format "X(1)"        space(0)
    temp-str.gds-name   format "X(25)"       space(0)
    Sym3                format "X(1)"        space(0)
    temp-str.edizm      format "X(7)"        space(0)
    Sym4                format "X(1)"        space(0)
    temp-str.brutto1    format ">>>>>9.<<"    space(0)
    Sym5                format "X(1)"        space(0)
    temp-str.netto1     format ">>>>>9.<<"   space(0)
    Sym6                format "X(1)"        space(0)
    temp-str.brutto2    format ">>>>>9.<<"   space(0)
    Sym7                format "X(1)"        space(0)
    temp-str.netto2     format ">>>>>9.<<"    space(0)
    Sym8                format "X(1)"        space(0)
    temp-str.brutto3    format ">>>>>9.<<"   space(0)
    Sym9                format "X(1)"        space(0)
    temp-str.netto3     format ">>>>>9.<<"    space(0)
    Sym10               format "X(1)"        space(0)
    temp-str.brutto     format ">>>>>9.<<"   space(0)
    Sym11               format "X(1)"        space(0)
    temp-str.netto      format ">>>>>9.<<"    space(0)
    Sym12               format "X(1)"        space(0)
  HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    Line format "X(150)" AT 1
    with width 180 down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.

  if session:set-wait-state("compiler") then.

  { cmp/open-out.i STREAM OutStream " " {&LS_PS_A4} }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .

define variable v-is-base as logical no-undo .
{ gbl/rbisbase.i    v-is-base  }

if v-is-base = true then do:
    assign    PP-a = "баз.вал" .
end.
else do:
   assign     PP-a = "{&abbr_rub}".
end.

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .

FORM with frame plan-menu .


vv0 = "+--------+-------------------------+----------------------------------------------------------------------+-------------------+" .
vv1 = ":   №    :         Продукт         : Ед.изм. : Брутто1 : Нетто1  : Брутто2 : Нетто2  :  Брутто3 : Нетто3  : Брутто  : Нетто   :" .
vv2 = "+--------+-------------------------+---------+---------+---------+---------+---------+----------+---------+---------+---------+" .
vv3 = ":   1    :             2           :    3    :    4    :   5     :   6     :    7    :    8     :    9    :   10    :   11    :" .
vv4 = "+--------+-------------------------+---------+---------+---------+---------+---------+----------+---------+---------+---------+" .



 /* создаем временный файл */

define variable v-gds-name    as character no-undo .
define variable v-recipe-code as character no-undo .
define variable v-recipe-N    as character no-undo .
define variable v-obj-type    as character no-undo .
define variable v-obj-code    as integer   no-undo .

find first buf_recipe no-lock where recid(buf_recipe)  = p-recipe-recid.
  assign
    v-obj-type    = buf_recipe.obj-type
    v-obj-code    = buf_recipe.obj-code
    v-gds-name    = buf_recipe.recipe-name
    v-recipe-code = buf_recipe.recipe-code
    v-recipe-n    = buf_recipe.recipe-ref-num
    .

  if v-obj-code = 0 then
  assign
    v-obj-type =  v-cntxt-obj-type
    v-obj-code =  v-cntxt-obj-code
  .
  find this_object  where this_object.obj-type = v-obj-type  and
                          this_object.obj-code = v-obj-code  no-lock .

  find clients      where clients.obj-type     = {&cmp}      and
                          clients.obj-code     = v-cntxt-host-code-obj no-lock .
  run PrintTitul in this-procedure .
  /* по строкам документа-------------------------------------------------------------------------------------------- */
  /* сначала заполняем таблицу */
  for each temp-str
      on error undo, return error :
      delete temp-str .
  end. /* for each */

  run make-tt  in this-procedure .

    for each temp-str :
         run print-line .
    end. /* for each */

  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 4) .
  run PrintPodval in this-procedure .

HIDE STREAM OutStream FRAME plan-menu .
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */
/*  { rep/q-print.i 8 } */
 define variable v-user-action as character no-undo .
 define variable v-printed as logical   no-undo .
 define variable DisabledOptions as integer   no-undo .
 DisabledOptions = 8 .

 run gbl/prnfilen.w
   (input  ""
   ,input  DisabledOptions
   ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
   ,input  7
   ,output v-user-action
   ,output v-printed
   ) .
end.
/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :
  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter( OutStream ) + 2 > page-size( OutStream ) then page stream OutStream.

  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .

  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.

PUT STREAM OutStream UNFORMATTED
    sym1                format "X(1)"     space(0)
   num-ln            format ">>>>>>>9" space(0)
    sym2                format "X(1)"     space(0)
    temp-str.gds-name   format "X(25)"    space(0)
    Sym3                format "X(1)"     space(0)
    temp-str.edizm      format "X(9)"     space(0)
    Sym4                format "X(1)"     space(0)
    string(temp-str.brutto1)  format  "x(9)"  space(0)
    Sym5               format "X(1)" space(0)
    string(temp-str.netto1  )  format  "x(9)"  space(0)
    Sym6               format "X(1)" space(0)
    string(temp-str.brutto2)  format  "x(9)"  space(0)
    Sym7               format "X(1)" space(0)
    string(temp-str.netto2 )  format  "x(9)"  space(0)
    Sym8               format "X(1)" space(0)
    string(temp-str.brutto3)  format  "x(10)"  space(0)
    Sym9               format "X(1)" space(0)
    string(temp-str.netto3 )  format  "x(9)"  space(0)
    Sym10              format "X(1)" space(0)
    string(temp-str.brutto )  format  "x(9)"  space(0)
    Sym11              format "X(1)" space(0)
    string(temp-str.netto )  format  "x(9)"  space(0)
    Sym12              format "X(1)" space(0)
    skip
.
  end.
end procedure. /* print-line */



procedure print-all-itog :
  /* Итоговые суммы */
end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .

/* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
/* { rep/r-cliprp.i } */
PUT STREAM OutStream UNFORMATTED
                                                                                               skip
space(1) string( CAPS(     clients.obj-name ))                                                 skip
space(1) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )    skip
space(1)                                                                                       skip
.

PUT STREAM OutStream
skip "Название рецепта : " + CAPS( buf_recipe.recipe-name )                                    format "x(120)"
skip "Номер рецепта    : " +  string( buf_recipe.recipe-code)                                   format "x(60)"
skip "Номер блюда по сборнику рецептур : " + string ( buf_recipe.recipe-ref-num )             format "x(60)"
skip
.
 PUT STREAM OutStream UNFORMATTED
    space(50) string( " АКТ ПРОРАБОТКИ "   )           skip
                      "УТВЕРЖДАЮ"              format "X(9)"  AT 120  skip
                      "______________________" format "X(20)" AT 120  skip
                      "______________________" format "X(20)" AT 120 "/___________________/"
                      "подпись"                               AT 120 "            расшифровка подписи"
                      skip
      .

 PUT STREAM OutStream UNFORMATTED
     "Дата составления " + cur-time-date()   at 120 skip   .


/* шапка */
PUT STREAM OutStream
  vv0 format "x(180)" skip
  vv1 format "x(180)"  skip
  vv2 format "x(180)"  skip
  vv3 format "x(180)"  skip
  vv4 format "x(180)"  skip
  .

define variable v-red   as integer no-undo .
define variable v-green as integer no-undo .
define variable v-blue  as integer no-undo .
v-red   = 16.
v-green = 48.
v-blue  = 15.

    /* ... конец создания заголовка. --- */


  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .


  PUT  STREAM OutStream
        Line format "X(127)" AT 1 skip (2)
      " Заведующий производством _______________________ " skip
      " Калькуляцию составил     _______________________ " skip
      .

    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */


procedure make-tt :
  do
  on error undo, return error return-value
  :
  define buffer buf_goods for ub.goods .
  define buffer buf_units for ub.units .
define variable iii as integer no-undo .
define variable v-max-col as integer init 3 no-undo .
define variable v-i-col as integer init 0 no-undo .

for each buf_recipe-develop no-lock where
         buf_recipe-develop.recipe-code = buf_recipe.recipe-code break by buf_recipe-develop.doc-code
    on error undo, return error :
    iii = iii + 1.
     if first-of (buf_recipe-develop.doc-code) then do:
        v-i-col = v-i-col + 1 .
        if v-i-col >= 4 then return.
     end.
        find first temp-str where
              temp-str.gds-code  = buf_recipe-develop.gds-code  no-error .
         if not available temp-str then do:
            find first buf_goods no-lock where
                       buf_goods.gds-code  = buf_recipe-develop.gds-code .
             create temp-str.
             assign
                temp-str.n = iii
                temp-str.gds-code = buf_recipe-develop.gds-code
                temp-str.gds-name = buf_goods.gds-name
                temp-str.edizm    = buf_goods.unit-base
             .
         end.
         case v-i-col :
          when 1 then do:
              temp-str.brutto1 = buf_recipe-develop.brutto-qnty .
              temp-str.netto1  = buf_recipe-develop.qnty .
          end.
          when 2 then do:
              temp-str.brutto2 = buf_recipe-develop.brutto-qnty .
              temp-str.netto2  = buf_recipe-develop.qnty .
          end.
          when 3 then do:
              temp-str.brutto3 = buf_recipe-develop.brutto-qnty .
              temp-str.netto3  = buf_recipe-develop.qnty .
          end.
         end case.

        if v-i-col = 3 then do:
          temp-str.brutto = round ( (temp-str.brutto1 + temp-str.brutto2 + temp-str.brutto3) / 3 , 3 ).
          temp-str.netto  = round( (temp-str.netto1  + temp-str.netto2  + temp-str.netto3 ) / 3 , 3 ).
        end.
end. /* for each */
  if v-i-col < 3 then do:
    message "Для печати формы необходимо наличие трех Актов проработки !!! "
    view-as alert-box information .
    return error .
  end.
  end. /* do */
 end procedure. /* make-tt */