block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-res2.p $
$Archive: rep/r-res2.p $

Калькуляционные карточки по ПЛАНУ-МЕНЮ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 03/31/04 12:18

*/
 def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
 def var vss-author      as character no-undo init "$Author: expertek $":U .
 def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
 def var vss-workfile    as character no-undo init "$Workfile: r-res2.p $":U .
 def var vss-archive     as character no-undo init "$Archive: rep/r-res2.p $":U .
 def var vss-description as character no-undo init "Калькуляционные карточки по ПЛАНУ-МЕНЮ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  new }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ trg/partslib.i   }
{ str/fbrlib.i     }
{ gbl/getcntxt.i def }

&scop col-col-page 2

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid     no-undo.


define buffer buf_fbr-pln      for ub.fbr-pln.
define buffer main-buf_fbr-doc for ub.fbr-doc.

define temp-table temp-list-doc no-undo
  field doc-code as character
  field fact-date as date
  index pi doc-code
.

DEFINE temp-table temp-str no-undo
  field   np                as integer
  field   artic             as  char
  field   prod-type         as  char
  field   prod-code         as integer
  field   gds-name          as  char
  field   b-code            as character
  field   norma             as decimal
  field   num-rcp           as char
  field   p-inp             as decimal
  field   qnty              as decimal
  field   price             as decimal
  field   stoim             as decimal
  field   gds-code-bl      as int
  index pi
           gds-code-bl
           artic
           prod-type
           prod-code
.

DEFINE temp-table temp-doc no-undo
  field gds-code    as int
  field doc-code    as char
  field sec         as int
  field artic       as char
  field prod-type   as char
  field prod-code   as int
  field gds-name    as char
  field fact-date   as date
  field fact-order  as decimal
  field recipe-code as char
  field recipe-n     as character
  field all-stoim   as decimal
  field discn       as decimal
  field Vat         as decimal
  field SLT         as decimal
  field price-sale  as decimal
  field price-sale-1 as decimal
  field qnty-inp    as decimal
  field qnty-bl     as decimal
  field qnty-line   as decimal
  field porcii      as decimal
  field netto       as decimal
  field ves         as decimal

index pi doc-code
         gds-code
index pi2 sec
         doc-code
         gds-code
.

DEFINE temp-table temp-delta no-undo
  field artic       as  char
  field prod-type   as  char
  field prod-code   as integer
  field doc-code    as char
  field   gds-code-bl      as int
  field price-cost  as decimal
  field qnty-delta  as decimal
  field sum-cost    as decimal

  index pi artic
           prod-type
           prod-code
           doc-code
.


/* таблицы для сравнения */
define temp-table old-t no-undo
field gds-code   as integer
field norma      as decimal
field cost-price as decimal
field crsa-price as decimal
index pi
gds-code
norma
cost-price
crsa-price
.

define temp-table new-t no-undo
field gds-code   as integer
field norma      as decimal
field cost-price as decimal
field crsa-price as decimal
index pi
gds-code
norma
cost-price
crsa-price
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

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

def buffer buf_clients for  ub.clients .
def buffer This_Object for  ub.clients .

define variable qnty as decimal   no-undo .
define variable sum  as decimal   no-undo .

define variable num-ln as integer   no-undo .

def var FullNameGds as character no-undo .
def var gds-str as char no-undo.
def var gds-str1 as char no-undo.
def var gds-str2 as char no-undo.
def var i as int no-undo.
def var j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

def var LineBuf       as char    no-undo.
def var Line       as char    no-undo.
def var UndLine    as char    no-undo.

def var     Lines_Counter as   int  init 0  no-undo.
def var     Tmp_Counter   as   int  init 0  no-undo.

def var     tdoc-date     like ub.fbr-pln.doc-date no-undo.
def var     tdoc-code     like ub.fbr-pln.doc-code no-undo.

def var  abbr              as  char no-undo.
def var  pp-r                as  char no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .


def var sym1 as char  init ":"   no-undo.
def var sym2 as char  init ":"   no-undo.
def var sym3 as char  init ":"   no-undo.
def var sym4 as char  init ":"   no-undo.

define variable v-sec as integer no-undo .
define variable v-sec-max as integer no-undo .
define variable v-sec-i as integer no-undo .
define variable nnn as integer no-undo .
nnn = 0 .

DEFINE FRAME plan-menu
    sym1                format "X(1)"  space(0)
    nnn         format ">>>>9" space(0)
    sym2                format "X(1)"  space(0)
    temp-str.gds-name   format "X(40)" space(0)
    Sym3                format "X(1)"  space(0)
    temp-str.b-code     format "X(9)"  space(0)
    Sym4                format "X(1)"  space(0)

    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 110 format "X(13)" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.


{ gbl/getcntxt.i get " " p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_fbr-pln no-lock
     where recid(buf_fbr-pln) = p-recid
     no-error.

if not available buf_fbr-pln
then do:
    message
      "Напечатать невозможно"
    view-as alert-box.
    return.
end.

if buf_fbr-pln.status_ <> {&fact}
then do:
    message
      "Печать калькуляционной карточки возможно только после закрытия документа до статуса ФАКТ"
    view-as alert-box error.
    undo, return error .
end.
{ cmp/cr-objls.i buf_fbr-pln.obj-type buf_fbr-pln.obj-code no-error }

 do
 on error undo, return error return-value
 :

define variable   sort-name   as logical no-undo.
define variable   sort-gr     as logical no-undo.
define variable   print-graft as logical no-undo.   /* "Отладочная печать" */
define variable   summ as decimal no-undo .
define variable p-doc-code as character no-undo .
define variable varobj-date as date no-undo .
define variable v-type-goods as character no-undo .
define variable v-ves        as logical no-undo .
define buffer buf_units for ub.units .
define variable col-doc as integer no-undo .


/* список документов пр-ва по план-меню */

for each main-buf_fbr-doc no-lock where main-buf_fbr-doc.out-code = buf_fbr-pln.doc-code
    on error undo, return error :
    create temp-list-doc .
    assign
        temp-list-doc.doc-code     = main-buf_fbr-doc.doc-code
        temp-list-doc.fact-date    = main-buf_fbr-doc.fact-date
    .
    /* message temp-list-doc.doc-code " выбрали документ "  . */
        /* Список блюд */
        for each ub.fbr-recipe no-lock where
                ub.fbr-recipe.doc-code    =  main-buf_fbr-doc.doc-code    and
                ub.fbr-recipe.recipe-type = {&manufacturing}
                :
          for each ub.fbr-recipe-gds no-lock where
                  ub.fbr-recipe-gds.recipe-code = ub.fbr-recipe.recipe-code  and
                  ub.fbr-recipe-gds.doc-code    = main-buf_fbr-doc.doc-code
                  :
              for each ub.fbr-line no-lock  where
                      ub.fbr-line.doc-code   =  main-buf_fbr-doc.doc-code and
                      ub.fbr-line.artic      =  ub.fbr-recipe-gds.artic      and
                      ub.fbr-line.prod-type  =  ub.fbr-recipe-gds.prod-type  and
                      ub.fbr-line.prod-code  =  ub.fbr-recipe-gds.prod-code
                      :
                        find first ub.goods no-lock where
                                  ub.goods.artic      =  ub.fbr-recipe.artic      and
                                  ub.goods.prod-type  =  ub.fbr-recipe.prod-type  and
                                  ub.goods.prod-code  =  ub.fbr-recipe.prod-code no-error .
                                    if available ub.goods then do:
                                    find first gds-list no-lock where  gds-list.gds-code   =  ub.goods.gds-code no-error .
                                      if not available gds-list then do:
                                          create gds-list.
                                          buffer-copy ub.goods to gds-list.
                                          /* message "выбрали блюдо " gds-list.gds-name skip  .*/

                                      end.
                                    end.
              end.
          end.
        end. /* Список блюд*/
end. /* for each */


  if session:set-wait-state("compiler") then.
  { cmp/open-out.i STREAM OutStream " " {&CP_PS}  }   /* PORTRET */
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", {&A4_CW0})
    UndLine = fill("_", {&A4_CW0})
    LineBuf = fill("_", {&A4_CW0})
  .

  IF var-report-r-b = "rubl" THEN Assign pp-r = "{&abbr_rub}".
                       Else Assign pp-r = "баз.вал" .


{ gbl/curobjdt.i
  v-cntxt-obj-type
  v-cntxt-obj-code
  varobj-date
  no-error
}

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-sec = 1 .
for each obj-list  :
  for each gds-list  :
      find buf_units no-lock
            where buf_units.unit-name = gds-list.unit-base
            no-error .

        if lookup({&weight}, buf_units.type) > 0  then
            assign
                v-ves = true
                v-type-goods = " (весовой)"
            .
          else
              assign
                  v-ves         = false
                  v-type-goods  = ""
              .

            if not can-find (first  ub.fbr-recipe where
                             ub.fbr-recipe.recipe-type = {&manufacturing}
                        and  ub.fbr-recipe.prod-type = gds-list.prod-type
                        and  ub.fbr-recipe.prod-code = gds-list.prod-code
                        and  ub.fbr-recipe.artic     = gds-list.artic no-lock ) then do:
                            message gds-list.gds-name "не подходит - не производство" .
                            next .
                            end.
            if not can-find ( first ub.fbr-gds-obj  where
                             ub.fbr-gds-obj.obj-type = obj-list.obj-type
                        and  ub.fbr-gds-obj.obj-code = obj-list.obj-code
                        and  ub.fbr-gds-obj.gds-code = gds-list.gds-code
                        and
                        (ub.fbr-gds-obj.is-menu = true or
                         ub.fbr-gds-obj.is-semi-finished = true )
                          no-lock ) then do:
                            /*message gds-list.gds-name "не подходит menu  пФ "  .*/
                            next .
                          end.
  for each temp-list-doc :
    for each ub.fbr-line no-lock  where ub.fbr-line.doc-code  = temp-list-doc.doc-code  and
                                      ub.fbr-line.artic     = gds-list.artic and
                                      ub.fbr-line.prod-code = gds-list.prod-code and
                                      ub.fbr-line.prod-type = gds-list.prod-type
                                      and
                                      ub.fbr-line.is-comp = true    ,
        first ub.fbr-recipe no-lock where ub.fbr-recipe.recipe-code =  ub.fbr-line.recipe-code  and
                                       ub.fbr-recipe.doc-code    =  ub.fbr-line.doc-code  and
                                       ub.fbr-recipe.recipe-type = {&manufacturing} :
                                       .

v-sec-i = v-sec-i + 1 .

find  first ub.fbr-doc no-lock   where   ub.fbr-doc.doc-code   = temp-list-doc.doc-code no-error .
assign
    n-recipe-code        = ub.fbr-line.recipe-code
    num-re = ub.fbr-recipe.recipe-ref-num
    n-porc = if ub.fbr-recipe.portion-qnty <> 0 and ub.fbr-recipe.portion-qnty <> ?  then ub.fbr-recipe.portion-qnty else 1
  .
create temp-doc.
 if v-ves then
          assign
              temp-doc.ves  =  ub.fbr-recipe.qnty  / n-porc    /*  количество в одной порции по рецепту */
          .
       else
          assign
              temp-doc.ves  =  1                            /*  количество в одной порции по рецепту */
          .

 define buffer glob_recipe for ub.recipe.
 define variable var-vvv as decimal no-undo .
 var-vvv = 0 .
 find first glob_recipe no-lock where  glob_recipe.recipe-code = ub.fbr-line.recipe-code no-error .
 if available glob_recipe then var-vvv =  glob_recipe.portion-weight.

assign
  temp-doc.sec         = v-sec
  v-sec-max            = v-sec
  temp-doc.doc-code    = ub.fbr-doc.doc-code
  temp-doc.fact-date   = ub.fbr-doc.fact-date
  temp-doc.recipe-code = ub.fbr-line.recipe-code
  temp-doc.recipe-n    = num-re
  temp-doc.gds-code    = gds-list.gds-code
  temp-doc.gds-name    = gds-list.gds-name    +  " " + v-type-goods
  temp-doc.artic       = gds-list.artic
  temp-doc.prod-type   = gds-list.prod-type
  temp-doc.prod-code   = gds-list.prod-code
  temp-doc.porcii      = n-porc
  temp-doc.qnty-bl     = ub.fbr-line.fact-qnty / ub.fbr-recipe.qnty   /* во сколько сделали  блюда больше чем надо */
  temp-doc.netto       = if ub.fbr-recipe.qnty <> 0 and ub.fbr-recipe.qnty <> ?  then ub.fbr-recipe.qnty else 1  /* количество по рецепту    блюда */
  temp-doc.qnty-line   = ub.fbr-line.fact-qnty                                                             /* количество по документу  блюда */

  temp-doc.all-stoim     = round( ub.fbr-line.price-rubl  * temp-doc.ves  , 2 )     /* учетная цена на 1 блюд */
  temp-doc.price-sale-1  = round( ub.fbr-line.price-sale  * temp-doc.ves  , 2 )
  temp-doc.Vat         = round( ub.fbr-line.price-sum-vat-rubl / ( temp-doc.porcii * temp-doc.qnty-bl ), 2 ) /* Должна быть сумма учетных НДС */
  temp-doc.discn       = round( temp-doc.price-sale-1 -  temp-doc.all-stoim - temp-doc.Vat  , 2 )
  temp-doc.qnty-inp    =  if v-ves then round ( 1000 * ub.fbr-recipe.qnty  / n-porc , 3)
                                   else var-vvv        /* в граммах   количество в одной порции */
  temp-doc.fact-order  = ub.fbr-line.price-doc-fact-order
.

  if v-sec-i modulo  {&col-col-page} = 0 then v-sec = v-sec + 1 .

end. /* for each */
end.
  /* сначала заполняем таблицу */
  run make-tt (input gds-list.gds-code ).
end. /* gds-list */

find this_object  where this_object.obj-type = obj-list.obj-type and this_object.obj-code = obj-list.obj-code  no-lock no-error .
if error-status :error then message error-status :get-message(1) 234.
find ub.clients      where ub.clients.obj-type     = {&cmp}            and ub.clients.obj-code      = v-cntxt-host-code-obj no-lock no-error .
if error-status :error then message error-status :get-message(1) 123.



FORM with frame plan-menu .
run  PrintTitul in this-procedure .

end. /* obj-list */

/* PRINT */
define variable ll-sec as integer no-undo .
define variable pp-str as integer no-undo .

 repeat ll-sec = 1 to  v-sec-max :
  vv0 = "+--------------------------------------------------------+".
  vv1 = ": n/n :         Наименование продукта          :   Код   :".
  vv2 = ":     :                                        :         :".
  vv3 = ":     :                                        :         :".
  vv4 = ":     :                                        :         :".

  for each temp-doc where temp-doc.sec = ll-sec :
      vv1 = vv1 + string(temp-doc.doc-code + " от " + string(temp-doc.fact-date, "99/99/9999"),"x(32)") + ":"  .
      vv2 = vv2 + string("№ Рецептуры " + temp-doc.recipe-n  ,"x(32)") + ":".
      vv3 = vv3 +  string(temp-doc.gds-name  ,"x(32)")  + ":" .
      vv4 = vv4 + " Норма,кг: Цена," + string(pp-r,"x(4)") + ": Сумма," + string(pp-r,"x(4)") +  ":" .
      vv0 = vv0 + "--------------------------------+" .
  end.

  PUT STREAM OutStream UNFORMATTED
      vv0 skip
      vv1 skip
      vv2 skip
      vv3 skip
      vv4 skip
      vv0 skip
    .
  pp-str = 0.
  for each temp-doc where temp-doc.sec = ll-sec :
    pp-str = pp-str + 1.
    for each temp-str where temp-str.gds-code-bl = temp-doc.gds-code  :
        run print-line ( pp-str ).
    end.
  end. /* for each */
  /* ... Подвал. --- */
  run PrintPodval in this-procedure .
end.
  run on-same-page in this-procedure (input 11) .
  PUT  STREAM OutStream " "
        skip
      " Заведующий производством _______________________ " skip
      " Калькуляцию составил     _______________________ " skip
      " УТВЕРЖДАЮ "                                        skip
      " Руководитель организации _______________________ " skip
      .

page stream outstream .
hide stream outstream frame plan-menu.
hide stream outstream frame bottomframe .
hide stream outstream frame bottomframe2 .
output stream outstream close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */
{ rep/q-print.i 4 }
end.

/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :
define input parameter p-shift as integer no-undo .

define buffer buf_fbr-line       for ub.fbr-line .
define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds .
define buffer buf_recipe-gds     for ub.recipe-gds .
define buffer buf_fbr-recipe     for ub.fbr-recipe .
define variable p-norma as decimal format "->>>>>>>>>9.999"  no-undo .
define variable p-price as decimal format ">>>>>>>>>>9.99" no-undo .
define variable p-sum   as decimal format "->>>>>>>>>9.99"  no-undo .
define variable s-plus  as logical init false  no-undo .
define variable s-minus as logical init false no-undo .
define variable var-season-qnty1 as decimal no-undo .

  assign
     Lines_Counter = Lines_Counter + 1
     summ = summ  + temp-str.stoim
     nnn = nnn + 1
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
    sym1                format "X(1)" space(0)
    nnn                 format ">>>>9" space(0)
    sym2                format "X(1)" space(0)
    temp-str.gds-name   format "X(40)" space(0)
    sym3                format "X(1)" space(0)
    temp-str.b-code     format "X(9)" space(0)
    sym4                format "X(1)" space(0)
.

s-plus  = false .
s-minus = false .

     find first temp-delta where
                temp-delta.doc-code  = temp-doc.doc-code  and
                temp-delta.gds-code-bl  = temp-str.gds-code-bl  and
                temp-delta.artic     = temp-str.artic     and
                temp-delta.prod-type = temp-str.prod-type and
                temp-delta.prod-code = temp-str.prod-code no-error .

     if available temp-delta then do:
        if temp-delta.qnty-delta > 0 then s-plus = true .
        if temp-delta.qnty-delta < 0 then s-minus = true .
     end.

     p-norma = 0.
     p-price = 0.
     find first buf_fbr-recipe no-lock where buf_fbr-recipe.doc-code    = temp-doc.doc-code and
                                             buf_fbr-recipe.recipe-code = temp-doc.recipe-code
                                             no-error.
            if error-status :error then do:
                message vss-workfile vss-revision vss-description skip
                      error-status :get-message(1)
                      "fbr-recipe123" skip
                      "для " temp-doc.doc-code skip
                      temp-doc.recipe-code
                      .

          end.
     find first buf_fbr-recipe-gds no-lock where buf_fbr-recipe-gds.doc-code    = temp-doc.doc-code    and
                                                 buf_fbr-recipe-gds.recipe-code = temp-doc.recipe-code and
                                                 buf_fbr-recipe-gds.artic       = temp-str.artic       and
                                                 buf_fbr-recipe-gds.prod-type   = temp-str.prod-type   and
                                                 buf_fbr-recipe-gds.prod-code   = temp-str.prod-code
                                                 no-error .
          if error-status :error then do:
         /*     message vss-workfile vss-revision vss-description skip 222
                    error-status :get-message(1)  skip
                    "fbr-recipe-gds"         skip
                    "doc-code    " temp-doc.doc-code        skip
                    "recipe-code " temp-doc.recipe-code     skip
                    "artic       " temp-str.artic           skip
                    "prod-type   " temp-str.prod-type       skip
                    "prod-code   " temp-str.prod-code       skip
                    temp-str.gds-name
                    .
                    */
          end.

     if available buf_fbr-recipe-gds
        then do:
          run get-brutto-seson (output var-season-qnty1  ,
                                input temp-str.artic     ,
                                input temp-str.prod-type ,
                                input temp-str.prod-code ,
                                input temp-doc.recipe-code )
                                 .
          assign
           p-norma = var-season-qnty1 * temp-doc.ves / temp-doc.netto
          .
         end.
     find first buf_fbr-line       no-lock where buf_fbr-line.doc-code  = temp-doc.doc-code and
                                                 buf_fbr-line.artic     = temp-str.artic     and
                                                 buf_fbr-line.prod-type = temp-str.prod-type and
                                                 buf_fbr-line.prod-code = temp-str.prod-code no-error .
     if available buf_fbr-line then
        assign
          p-price  = buf_fbr-line.price-rubl
     .


     p-sum = p-price * p-norma .

  define variable var-shift as character no-undo .
  define variable v1-s as character no-undo .
  v1-s = fill (" ", 32 ) + ":" .
  if p-shift = 1 then var-shift = "" .
  if p-shift = 2 then var-shift = v1-s.
  if p-shift = 3 then var-shift = v1-s + v1-s .

      PUT STREAM OutStream UNFORMATTED string(var-shift) +
                                       string( p-norma ,"->>>>>>9.<<<" )
                                       + ":"
                                       string(round(p-price,2),">>>>>>9.99" )
                                       + ":"
                                       string(round(p-sum,2)  ,"->>>>>>9.99" )
                                       + ":"
                                      .

   PUT STREAM OutStream UNFORMATTED skip.
  if s-plus then  run print-dop-str("Накидка", true , p-shift ).
  if s-minus then run print-dop-str("Скидка", false , p-shift ).

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
{ rep/r-cliprp.i "ub."}
PUT STREAM OutStream UNFORMATTED
space(5) string( CAPS(  ub.clients.obj-name ))                                               skip
space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )  skip
                                                                                             skip.

PUT STREAM OutStream UNFORMATTED
  space(5) string( "КАЛЬКУЛЯЦИОННЫЕ КАРТОЧКИ ПО ПЛАНУ МЕНЮ № " + buf_fbr-pln.doc-code + " от " + string(buf_fbr-pln.fact-date, "99/99/9999") )
  + "                " + "Дата составления " + cur-time-date()
  format "X(120)"  skip

.
    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .
   /*
   "Общая стоимость сырьевого набора на 1 блюд"
   "Наценка"
   "НДС"
   "Цена продажи блюжа"
   "Выход одного блюда в готовом виде"

   */

PUT STREAM OutStream UNFORMATTED  vv0 skip.
&scop v-val    PUT STREAM OutStream UNFORMATTED string(~{&v-pole-name})  format "x(57)" .~
   for each temp-doc where temp-doc.sec = ll-sec : ~
       PUT STREAM OutStream UNFORMATTED ":" string(~{&v-pole}) format "x(32)" .~
   end. ~
   PUT STREAM OutStream skip.


&scop v-pole-name     'Общая стоимость сырьевого набора на 1 блюдо'
&scop v-pole      temp-doc.all-stoim
{&v-val}

&scop v-pole-name     'НДС,' + string(pp-r)
&scop v-pole      temp-doc.vat
{&v-val}


&scop v-pole-name     'Наценка,' + string(pp-r)
&scop v-pole      temp-doc.discn
{&v-val}

&scop v-pole-name     'Цена продажи 1 блюда,' + string(pp-r)
&scop v-pole      temp-doc.price-sale-1
{&v-val}


&scop v-pole-name     'Выход одного блюда в готовом виде,грамм'
&scop v-pole      temp-doc.qnty-inp
{&v-val}
PUT STREAM OutStream UNFORMATTED  vv0 skip.


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
define input parameter par-gds-code as integer no-undo .
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .
define variable v-bar-code like ub.bar-code.b-code no-undo .
define variable t-i as integer no-undo .

define variable var-norma as decimal no-undo .
define variable var-fact as decimal no-undo .
define variable var-delta as decimal no-undo .


define buffer buf_fbr-doc-line   for ub.fbr-line .
define buffer bb_recipe          for ub.recipe-gds.
define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
define buffer buf_goods          for ub.goods .

define variable var-season-qnty as decimal no-undo .

t-i = 0 .

      for each temp-doc where temp-doc.gds-code = par-gds-code :
          for each bb_recipe no-lock where  bb_recipe.recipe-code = temp-doc.recipe-code :
            for each  buf_fbr-doc-line no-lock where
                      buf_fbr-doc-line.doc-code  = temp-doc.doc-code and
                      buf_fbr-doc-line.artic     = bb_recipe.artic and
                      buf_fbr-doc-line.prod-type = bb_recipe.prod-type and
                      buf_fbr-doc-line.prod-code = bb_recipe.prod-code :
                for each  buf_fbr-recipe-gds no-lock where
                          buf_fbr-recipe-gds.doc-code   = temp-doc.doc-code and
                          buf_fbr-recipe-gds.recipe-code = temp-doc.recipe-code and
                          buf_fbr-recipe-gds.artic       = bb_recipe.artic and
                          buf_fbr-recipe-gds.prod-type   = bb_recipe.prod-type and
                          buf_fbr-recipe-gds.prod-code   = bb_recipe.prod-code :

                 if not can-find ( first temp-str where
                            temp-str.gds-code-bl  =  par-gds-code  and
                            temp-str.artic     = buf_fbr-doc-line.artic and
                            temp-str.prod-type = buf_fbr-doc-line.prod-type and
                            temp-str.prod-code = buf_fbr-doc-line.prod-code  )  then do
                            :

                        find first buf_goods where
                                   buf_fbr-doc-line.artic     = buf_goods.artic      and
                                   buf_fbr-doc-line.prod-code = buf_goods.prod-code  and
                                   buf_fbr-doc-line.prod-type = buf_goods.prod-type  no-lock no-error .
                        { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code  }

                        t-i = t-i + 1 .
                        create temp-str .
                        assign
                          temp-str.np         =  t-i
                          temp-str.gds-name   =  buf_goods.gds-name
                          temp-str.b-code     =  string(v-bar-code)
                          temp-str.gds-code-bl  =  par-gds-code
                          temp-str.artic      =  buf_fbr-doc-line.artic
                          temp-str.prod-type  =  buf_fbr-doc-line.prod-type
                          temp-str.prod-code  =  buf_fbr-doc-line.prod-code
                        .

                       /* end. */
                      /* заполним дельту */
                      find first temp-delta where
                            temp-delta.doc-code  = buf_fbr-doc-line.doc-code and
                            temp-delta.gds-code-bl  =  par-gds-code and
                            temp-delta.artic     = buf_fbr-doc-line.artic    and
                            temp-delta.prod-type = buf_fbr-doc-line.prod-type and
                            temp-delta.prod-code = buf_fbr-doc-line.prod-code no-error .
                            if not available temp-delta then create temp-delta.
                            run get-brutto-seson (output var-season-qnty ,
                                                  input buf_fbr-doc-line.artic     ,
                                                  input buf_fbr-doc-line.prod-type ,
                                                  input buf_fbr-doc-line.prod-code,
                                                  input temp-doc.recipe-code
                                                  ) .

                            var-norma = var-season-qnty * temp-doc.ves  / temp-doc.netto .
                            var-fact  = buf_fbr-doc-line.fact-qnty * temp-doc.ves  / temp-doc.qnty-line .
                            var-delta = var-fact -  var-norma .
                              /*
                                 message
                                  "Документ                  : " temp-doc.doc-code    skip
                                  "рецепт                    : " temp-doc.recipe-code skip
                                  "порций в рецепте          : " temp-doc.porcii      skip
                                  "количество блюда в рецеп  : " temp-doc.netto       skip
                                  "количество блюда в док    : " temp-doc.qnty-line   skip
                                  "вес 1 порции для весового : " temp-doc.ves        skip
                                                                                    skip
                                  "Артикл                    : " buf_fbr-doc-line.artic skip
                                  "В документе производства  : " buf_fbr-doc-line.fact-qnty skip
                                  "это * вес1 / " temp-doc.qnty-line  " = " var-fact  skip

                                  "В fbr-рецепте брутто            : " buf_fbr-recipe-gds.brutto-qnty  skip
                                  "В гл.рецепте сезонный брутто    : " var-season-qnty         skip
                                  "это * вес1 / " temp-doc.netto  " = " var-norma skip
                                  "Разницу в отд строку " var-delta               skip
                                  "ее уч цена            " buf_fbr-doc-line.price-rubl
                                .
                                */
                                assign
                                  temp-delta.qnty-delta = round( var-delta , 3 )
                                  temp-delta.price-cost = buf_fbr-doc-line.price-rubl
                                  temp-delta.sum-cost   = buf_fbr-doc-line.price-rubl * temp-delta.qnty-delta  / temp-doc.porcii
                                  temp-delta.doc-code   = buf_fbr-doc-line.doc-code
                                  temp-delta.artic      = buf_fbr-doc-line.artic
                                  temp-delta.prod-type  = buf_fbr-doc-line.prod-type
                                  temp-delta.prod-code  = buf_fbr-doc-line.prod-code
                                .
                 end.
              end.
            end.
          end.
      end.
  end. /* do */
 end procedure. /* make-tt */



procedure print-dop-str :
 do
 on error undo, return error return-value
 :
define input parameter p-name as character no-undo .
define input parameter p-p   as logical no-undo .
define input parameter p-shift  as integer no-undo .

define variable p-norma as decimal  no-undo .
define variable p-price as decimal  format ">>>>>>>>>>9.99" no-undo .
define variable p-sum   as decimal format "->>>>>>>>>9.99"  no-undo .
define buffer buf_fbr-line       for ub.fbr-line .
define buffer buf_fbr-recipe for ub.fbr-recipe .


PUT STREAM OutStream UNFORMATTED
    sym1                format "X(1)" space(0)
    0                   format ">>>>>" space(0)
    sym2                format "X(1)" space(0)
    p-name              format "X(40)" space(0)
    sym3                format "X(1)" space(0)
    ""                  format "X(9)" space(0)
    sym4                format "X(1)" space(0)
.


     find first temp-delta where
                temp-delta.doc-code  = temp-doc.doc-code  and
                temp-delta.artic     = temp-str.artic     and
                temp-delta.prod-type = temp-str.prod-type and
                temp-delta.prod-code = temp-str.prod-code no-error .

     if available temp-delta then do:
        p-norma = temp-delta.qnty-delta .

        find first buf_fbr-line       no-lock where buf_fbr-line.doc-code  = temp-doc.doc-code and
                                                    buf_fbr-line.artic     = temp-str.artic and
                                                    buf_fbr-line.prod-type = temp-str.prod-type and
                                                    buf_fbr-line.prod-code = temp-str.prod-code no-error .
        if available buf_fbr-line then
        assign
          p-price  = buf_fbr-line.price-rubl
        .
          if not(( p-p =  true  and temp-delta.qnty-delta > 0 ) OR
                ( p-p =  false and temp-delta.qnty-delta < 0 ) )
             then  do:
                    assign
                      p-price = 0
                      p-norma = 0
                    .
 .

             end.
      end.
      p-sum = p-price * p-norma .
  define variable var-shift as character no-undo .
  define variable v1-s as character no-undo .
  v1-s = fill (" ", 32 ) + ":" .
  if p-shift = 1 then var-shift = "" .
  if p-shift = 2 then var-shift = v1-s.
  if p-shift = 3 then var-shift = v1-s + v1-s .


      if p-price = 0 and p-norma = 0 then
         PUT STREAM OutStream UNFORMATTED  string(var-shift) +  "         :          :           :" .
      else
          PUT STREAM OutStream UNFORMATTED string(var-shift) +
                                          string( p-norma ,"->>>>>>9.<<<" )
                                          + ":"
                                          string(round(p-price,2),">>>>>>9.99" )
                                          + ":"
                                          string(round(p-sum,2)  ,"->>>>>>9.99" )
                                          + ":"
                                          .
  PUT STREAM OutStream UNFORMATTED skip.


 end. /* do */
end procedure. /* print-dop-str */


procedure chg-record-temp-doc :
 do
 on error undo, return error return-value
 :
 define variable p-res as logical no-undo .
    for each old-t : delete old-t. end.
    for each new-t : delete new-t. end.

    for each temp-doc break by  temp-doc.fact-date by temp-doc.fact-order:
       run make-t ("new":u ).
       run compare-new-old ( output p-res ) .
       if p-res = false  then do :
          /* таблицы одинаковые */
          delete temp-doc.
          col-doc = col-doc - 1 .
          end.
        else do:
          /* таблицы разные */
             for each old-t : delete old-t. end.
             run make-t ("old":u ).
        end.
        for each new-t : delete new-t. end.
    end.

 end. /* do */
end procedure. /* chg-record-temp-doc */


procedure make-t :
 do
 on error undo, return error return-value
 :
define input parameter pp as character no-undo .

define buffer buf_recipe       for ub.fbr-recipe .
define buffer bb_recipe-gds    for ub.fbr-recipe-gds .
define buffer buf_fbr-doc-line for ub.fbr-line .

define buffer buf_goods for ub.goods.

  for each bb_recipe-gds no-lock where  bb_recipe-gds.recipe-code = temp-doc.recipe-code and
                                        bb_recipe-gds.doc-code    = temp-doc.doc-code
                                        :
      for each  buf_fbr-doc-line no-lock where buf_fbr-doc-line.doc-code = temp-doc.doc-code and
                                              buf_fbr-doc-line.artic     = bb_recipe-gds.artic and
                                              buf_fbr-doc-line.prod-type = bb_recipe-gds.prod-type and
                                              buf_fbr-doc-line.prod-code = bb_recipe-gds.prod-code
                                              :

          find first buf_goods no-lock where buf_fbr-doc-line.artic   = buf_goods.artic      and
                      buf_fbr-doc-line.prod-code = buf_goods.prod-code  and
                      buf_fbr-doc-line.prod-type = buf_goods.prod-type  no-error .
                      if error-status :error then next.
        if pp = "old":U then do:
        create old-t.
        assign
          old-t.gds-code   = buf_goods.gds-code
          old-t.crsa-price = temp-doc.price-sale-1
          old-t.norma      = round( bb_recipe-gds.qnty / temp-doc.porcii , 3 )
          old-t.cost-price = buf_fbr-doc-line.price-rubl
        .
        end.
        else do:
        create new-t.
        assign
          new-t.gds-code   = buf_goods.gds-code
          new-t.crsa-price = temp-doc.price-sale-1
          new-t.norma      = round( bb_recipe-gds.qnty / temp-doc.porcii , 3 )
          new-t.cost-price = buf_fbr-doc-line.price-rubl
        .

        end.
      end.
  end.


 end. /* do */
end procedure. /* make-t */



procedure compare-new-old :
 do
 on error undo, return error return-value
 :
define output parameter v-res as logical no-undo .

v-res = false .
for each new-t :
    find first old-t where  old-t.gds-code   = new-t.gds-code  and
                      old-t.norma      = new-t.norma     and
                      old-t.cost-price = new-t.cost-price and
                      old-t.crsa-price = new-t.crsa-price  no-error .
    if error-status :error then do:
       v-res = true .
       return .
    end.
end.

for each old-t :
    find first new-t where  new-t.gds-code   = old-t.gds-code  and
                      new-t.norma      = old-t.norma     and
                      new-t.cost-price = old-t.cost-price and
                      new-t.crsa-price = old-t.crsa-price  no-error .
    if error-status :error then do:
       v-res = true .
       return  .
    end.
end.

end. /* do */
end procedure. /* compare-new-old */



procedure get-brutto-seson :
 do
 on error undo, return error return-value
 :
define output parameter p-se-qnty as decimal no-undo .
define input parameter p-artic     like  ub.goods.artic      no-undo.
define input parameter p-prod-type like  ub.goods.prod-type  no-undo.
define input parameter p-prod-code like  ub.goods.prod-code  no-undo.
define input parameter p-recipe-code like ub.recipe-gds.recipe-code no-undo.

define buffer local-recipe-gds for  ub.recipe-gds  .
define buffer bf_goods for ub.goods.

define variable varcoeff as decimal no-undo.
find first bf_goods no-lock where
          bf_goods.artic     = p-artic and
          bf_goods.prod-type = p-prod-type and
          bf_goods.prod-code = p-prod-code no-error .
if error-status :error then return error .

find first local-recipe-gds no-lock where
          local-recipe-gds.recipe-code = p-recipe-code and
          local-recipe-gds.artic       = p-artic and
          local-recipe-gds.prod-type   = p-prod-type and
          local-recipe-gds.prod-code   = p-prod-code no-error .
if error-status :error then return error .


 run fbrlib-s-coeff-value in this-procedure
   (input bf_goods.gds-code,
    input varobj-date,
    input v-cntxt-obj-type,
    input v-cntxt-obj-code,
    output varcoeff
    ).

define variable v-void-decimal as decimal no-undo .
define variable v-brutto  like ub.recipe-gds.brutto-qnty  no-undo .
define variable v-void-integer as integer no-undo .

    run fbrlib-calc-brutto in this-procedure (
          input {&manufacturing}
        , input local-recipe-gds.qnty
        , input varcoeff
        , input local-recipe-gds.coeff-waste
        , input 0.0
        , input 3
        , output v-void-decimal
        , output v-void-decimal
        , output v-brutto
        , output v-void-integer
    ).

 p-se-qnty = v-brutto .

 end. /* do */
end procedure. /* get-brutto-seson */