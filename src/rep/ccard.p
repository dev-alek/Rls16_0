block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ccard.p $
$Archive: rep/ccard.p $

Документ Калькуляционная карта

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 03/29/04 4:26

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: ccard.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/ccard.p $":U .
def var vss-description as character no-undo init " Документ Калькуляционная карта    ".

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

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid     no-undo.
define input parameter p-rubl as logical no-undo .
define input parameter p-detail   as logical no-undo .
define input parameter p-fat      as logical no-undo .

define buffer main-buf_fbr-doc for fbr-doc.

find first main-buf_fbr-doc no-lock
     where recid(main-buf_fbr-doc) = p-recid
no-error.

if not available main-buf_fbr-doc
then do:
    message
      "Форму OP-1 напечатать невозможно"
    view-as alert-box.
    return.
end.
if main-buf_fbr-doc.status_ <> {&fact}
then do:
    message
      "Печать калькуляционной карточки возможно только после закрытия документа до статуса ФАКТ"
    view-as alert-box error.
    undo, return error .
end.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

 do
 on error undo, return error return-value
 :

define variable   sort-name   as logical no-undo.
define variable   sort-gr     as logical no-undo.
define variable   print-graft as logical no-undo.   /* "Отладочная печать" */
define variable   summ as decimal no-undo .
define variable p-doc-code  as character no-undo .
for each  obj-list : delete obj-list . end.
for each  gds-list : delete gds-list . end.

{ gbl/getcntxt.i get " " p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
p-doc-code = main-buf_fbr-doc.doc-code.
{ cmp/cr-objls.i main-buf_fbr-doc.obj-type main-buf_fbr-doc.obj-code no-error }


for each fbr-recipe no-lock where
          fbr-recipe.doc-code    =  main-buf_fbr-doc.doc-code   /* and
          fbr-recipe.recipe-type = {&manufacturing} */:
  for each fbr-recipe-gds no-lock where
            fbr-recipe-gds.recipe-code = fbr-recipe.recipe-code  and
            fbr-recipe-gds.doc-code    = fbr-recipe.doc-code  :
      for each fbr-line no-lock  where
                fbr-line.doc-code   =  p-doc-code                and
              /*  fbr-line.is-comp    =  true                      and */
                fbr-line.recipe-code =  fbr-recipe-gds.recipe-code   and
                fbr-line.artic      =  fbr-recipe-gds.artic      and
                fbr-line.prod-type  =  fbr-recipe-gds.prod-type  and
                fbr-line.prod-code  =  fbr-recipe-gds.prod-code  :
      find first goods no-lock where
                  goods.artic      =  fbr-recipe.artic      and
                  goods.prod-type  =  fbr-recipe.prod-type  and
                  goods.prod-code  =  fbr-recipe.prod-code no-error .
                  if available goods then do:
                  find first gds-list no-lock where  gds-list.gds-code   =  goods.gds-code no-error .
                    if not available gds-list then do:
                        create gds-list.
                        buffer-copy goods to gds-list.
/*                        message "выбрали " gds-list.gds-name skip
                                "fbr-line.is-comp= " fbr-line.is-comp skip
                                "fbr-recipe.recipe-type" fbr-recipe.recipe-type
                                .
                                */
                     end.

                  end.
      end.
  end.
end.

reportname = "КАЛЬКУЛЯЦИОННАЯ КАРТОЧКА" .
sort-gr     = true  .
sort-name   = false .
print-graft = true .


&Scop Sort-pole if sort-name then  temp-str.gds-name Else string(temp-str.np,"999999999")

define variable sort-group as logical   no-undo .
if sort-gr                  then assign sort-group = yes .
else                             assign sort-group = no .


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
  index pi artic
           prod-type
           prod-code
.

DEFINE temp-table temp-doc no-undo
  field doc-code    as char
  field fact-date   as date
  field fact-order  as decimal
  field recipe-code as char
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
.

DEFINE temp-table temp-delta no-undo
  field artic       as  char
  field prod-type   as  char
  field prod-code   as integer
  field doc-code    as char

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

def buffer buf_clients for  clients .
def buffer This_Object for  clients .

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

def var     tdoc-date     like fbr-pln.doc-date no-undo.
def var     tdoc-code     like fbr-pln.doc-code no-undo.

def var  abbr              as  char no-undo.
def var  pp-r                as  char no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .

def var sym1 as char  init ":"   no-undo.
def var sym2 as char  init ":"   no-undo.
def var sym3 as char  init ":"   no-undo.
def var sym4 as char  init ":"   no-undo.

DEFINE FRAME plan-menu
    sym1               format "X(1)" space(0)
    temp-str.np        format ">>>>9" space(0)
    sym2               format "X(1)" space(0)
    temp-str.gds-name   format "X(40)" space(0)
    Sym3                format "X(1)" space(0)
    temp-str.b-code     format "X(9)" space(0)
    Sym4                format "X(1)" space(0)
    HEADER
    UndLine format "X(190)" AT 1
    with width {&DOS_CW_2} down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.



  if session:set-wait-state("compiler") then.

  { cmp/open-out.i STREAM OutStream " " {&CP_PS}  }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .

  IF var-report-r-b = "rubl" THEN Assign pp-r = "{&abbr_rub}".
                       Else Assign pp-r = "баз.вал" .
define variable varobj-date as date no-undo .
   { gbl/curobjdt.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      varobj-date
      no-error
    }

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .

FORM with frame plan-menu .
define variable v-type-goods as character no-undo .
define variable v-ves        as logical no-undo .

for each obj-list no-lock :
for each gds-list no-lock :

define buffer buf_units for ub.units .
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

if not can-find (first  fbr-recipe where
                 fbr-recipe.recipe-type = {&manufacturing}
            and  fbr-recipe.prod-type = gds-list.prod-type
            and  fbr-recipe.prod-code = gds-list.prod-code
            and  fbr-recipe.artic =     gds-list.artic no-lock ) then next .
if not can-find ( first fbr-gds-obj  where
                 fbr-gds-obj.obj-type = obj-list.obj-type
            and  fbr-gds-obj.obj-code = obj-list.obj-code
            and  fbr-gds-obj.gds-code = gds-list.gds-code
            and (fbr-gds-obj.is-menu = true
            or   fbr-gds-obj.is-semi-finished = true )
                no-lock ) then next .

vv0 = "+--------------------------------------------------------+".
vv1 = ": n/n :         Наименование продукта          :   Код   :".
vv2 = ":     :                                        :         :".


 define variable col-doc as integer no-undo .
 col-doc =  0.
 /* очистим временные таблички */

 for each temp-doc   : delete temp-doc .   end.
 for each temp-str   : delete temp-str .   end.
 for each temp-delta : delete temp-delta . end.

 for each fbr-line no-lock  where fbr-line.doc-code   = p-doc-code and
                                  fbr-line.artic     = gds-list.artic and
                                  fbr-line.prod-code = gds-list.prod-code and
                                  fbr-line.prod-type = gds-list.prod-type  and
                                  fbr-line.is-comp = true   ,
        first fbr-recipe no-lock where fbr-recipe.recipe-code =  fbr-line.recipe-code  and
                                       fbr-recipe.doc-code    =  fbr-line.doc-code  and
                                       fbr-recipe.recipe-type = {&manufacturing} ,
         first fbr-doc no-lock   where
                                fbr-doc.doc-code   = fbr-line.doc-code :

/*  количество докуменов с этим блюдом */
col-doc = col-doc + 1.

assign
    n-recipe-code        = fbr-line.recipe-code
    num-re = fbr-recipe.recipe-ref-num
    n-porc = if fbr-recipe.portion-qnty <> 0 and fbr-recipe.portion-qnty <> ?  then fbr-recipe.portion-qnty else 1
  .
create temp-doc.

 if v-ves then
          assign
              temp-doc.ves  =  fbr-recipe.qnty  / n-porc    /*  количество в одной порции по рецепту */
          .
       else
          assign
              temp-doc.ves  =  1                            /*  количество в одной порции по рецепту */
            .
 define buffer glob_recipe for recipe.
 define variable var-vvv as decimal no-undo .
 var-vvv = 0 .
 find first glob_recipe no-lock where  glob_recipe.recipe-code = fbr-line.recipe-code no-error .
 if available glob_recipe then var-vvv =  glob_recipe.portion-weight * 1000 .


assign
  temp-doc.porcii      = n-porc
  temp-doc.qnty-bl     = fbr-line.fact-qnty / fbr-recipe.qnty   /* во сколько сделали  блюда больше чем надо */
  temp-doc.doc-code    = fbr-doc.doc-code
  temp-doc.fact-date   = fbr-doc.fact-date
  temp-doc.recipe-code = fbr-line.recipe-code
  temp-doc.netto       = if fbr-recipe.qnty <> 0 and fbr-recipe.qnty <> ?  then fbr-recipe.qnty else 1  /* количество по рецепту    блюда */
  temp-doc.qnty-line   = fbr-line.fact-qnty                                                             /* количество по документу  блюда */

  temp-doc.all-stoim     = round( fbr-line.price-rubl  * 100 * temp-doc.ves  , 2 )     /* учетная цена на 100 блюд */
  temp-doc.price-sale    = round( fbr-line.price-sale  * 100 * temp-doc.ves  , 2 )
  temp-doc.price-sale-1  = round( fbr-line.price-sale  * temp-doc.ves  , 2 )

  temp-doc.Vat         = round( fbr-line.price-sum-vat-rubl *  100  / ( temp-doc.porcii * temp-doc.qnty-bl ), 2 ) /* Должна быть сумма учетных НДС */
  temp-doc.SLT         = 0
  temp-doc.discn       = round( temp-doc.price-sale -  temp-doc.all-stoim - temp-doc.Vat  - temp-doc.SLT  , 2 )
  temp-doc.qnty-inp    =  if v-ves then round ( 1000 * fbr-recipe.qnty  / n-porc , 3)
                                   else var-vvv        /* в граммах   количество в одной порции */
  temp-doc.fact-order  = fbr-line.price-doc-fact-order
.


end.
  if col-doc = 0 then next. /* не нашлось документов по товару */
  for each temp-doc :
      vv1 = vv1 + string(temp-doc.doc-code + " от " + string(temp-doc.fact-date, "99/99/9999"),"x(32)") + ":"  .
      vv2 = vv2 + " Норма,кг: Цена," + string(pp-r,"x(4)") + ": Сумма," + string(pp-r,"x(4)") +  ":" .
      vv0 = vv0 + "--------------------------------+" .
  end.

  find this_object  where this_object.obj-type = obj-list.obj-type and this_object.obj-code = obj-list.obj-code  no-lock .
  find clients      where clients.obj-type     = {&cmp}            and clients.obj-code      = v-cntxt-host-code-obj no-lock .
  run PrintTitul in this-procedure .
  /* по строкам документа-------------------------------------------------------------------------------------------- */
  /* сначала заполняем таблицу */
  run make-tt in this-procedure .
  /* теперь печать */
  for each temp-str no-lock break by {&Sort-pole} :
      run print-line in this-procedure .
  end.

  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 11) .
  run PrintPodval in this-procedure .
  /* page stream OutStream . */
     page stream OutStream .
end.
end. /* obj-list */

HIDE STREAM OutStream FRAME plan-menu.
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */
{ rep/q-print.i 8 }
end.

/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :
  define buffer buf_fbr-line       for fbr-line .
  define buffer buf_fbr-recipe-gds for fbr-recipe-gds .
  define buffer buf_recipe-gds     for recipe-gds .
  define buffer buf_fbr-recipe     for fbr-recipe .
  define variable p-norma as decimal format "->>>>>>>>>9.999"  no-undo .
  define variable p-price as decimal format ">>>>>>>>>>9.99" no-undo .
  define variable p-sum   as decimal format "->>>>>>>>>9.99"  no-undo .
  define variable s-plus  as logical init false  no-undo .
  define variable s-minus as logical init false no-undo .
  define variable var-season-qnty1 as decimal no-undo .

  assign
     Lines_Counter = Lines_Counter + 1
     summ = summ  + temp-str.stoim
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
    temp-str.np         format ">>>>9" space(0)
    sym2                format "X(1)" space(0)
    temp-str.gds-name   format "X(40)" space(0)
    sym3                format "X(1)" space(0)
    temp-str.b-code     format "X(9)" space(0)
    sym4                format "X(1)" space(0)
.

s-plus  = false .
s-minus = false .

 for each temp-doc break by temp-doc.fact-date :
     find first temp-delta where
                temp-delta.doc-code  = temp-doc.doc-code  and
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
                      "fbr-recipe" skip
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
              message vss-workfile vss-revision vss-description skip
                    error-status :get-message(1)
                    "fbr-recipe-gds" skip
                    "для " temp-doc.doc-code skip
                    temp-doc.recipe-code     skip
                    temp-str.artic           skip
                    temp-str.prod-type       skip
                    temp-str.prod-code       skip
                    .
          end.


     find first buf_recipe-gds no-lock where buf_recipe-gds.recipe-code = temp-doc.recipe-code and
                                             buf_recipe-gds.artic       = temp-str.artic       and
                                             buf_recipe-gds.prod-type   = temp-str.prod-type   and
                                             buf_recipe-gds.prod-code   = temp-str.prod-code
                                             no-error .
     if error-status :error then do:
        message vss-workfile vss-revision vss-description skip
               error-status :get-message(1)
               "recipe-gds" skip
               "для "
               temp-doc.recipe-code     skip
               temp-str.artic           skip
               temp-str.prod-type       skip
               temp-str.prod-code       skip
               .
     end.


     if available buf_fbr-recipe-gds
        then do:
          run get-brutto-seson in this-procedure ( output var-season-qnty1 ,
                                input temp-str.artic    ,
                                input temp-str.prod-type,
                                input temp-str.prod-code ,
                                input temp-doc.recipe-code)
                                 no-error .
                                 if error-status :error then message error-status :get-message(1) 1.
          assign
           p-norma = 100 * var-season-qnty1 * temp-doc.ves / temp-doc.netto
          .
         end.
     find first buf_fbr-line       no-lock where buf_fbr-line.doc-code  = temp-doc.doc-code and
                                                 buf_fbr-line.recipe-code   = temp-doc.recipe-code and
                                                 buf_fbr-line.artic     = temp-str.artic     and
                                                 buf_fbr-line.prod-type = temp-str.prod-type and
                                                 buf_fbr-line.prod-code = temp-str.prod-code no-error .
     if available buf_fbr-line then
        assign
          p-price  = buf_fbr-line.price-rubl
     .


     p-sum = p-price * p-norma .


      PUT STREAM OutStream UNFORMATTED string( p-norma ,"->>>>>>9.<<<" )
                                       + ":"
                                       string(round(p-price,2),">>>>>>9.99" )
                                       + ":"
                                       string(round(p-sum,2)  ,"->>>>>>9.99" )
                                       + ":"
                                      .

 end.
  PUT STREAM OutStream UNFORMATTED skip.
  if s-plus then run print-dop-str in this-procedure ("Накидка", true  ).
  if s-minus then run print-dop-str in this-procedure ("Скидка", false ).

  /* DOWN stream OutStream 1 with FRAME plan-menu. */
  if print-graft = false THEN do:
  underline stream OutStream
    sym1     temp-str.np
    sym2     temp-str.gds-name
    sym3     temp-str.b-code
    sym4
    with FRAME plan-menu.
  DOWN stream OutStream 1 with FRAME plan-menu.

   end.
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
    { rep/r-cliprp.i }
PUT STREAM OutStream UNFORMATTED
space(1) string( "Унифицированная форма № ОП-1" )                                             "+--------------------------+" at 100  skip
                                                                                              "|                  | Коды  |" at 100  skip
space(5) string( CAPS(     clients.obj-name ))                                                "|    Форма по ОКУД |0330501|" at 100  skip
space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )   "|          по ОКПО |       |" at 100  skip
                                                                                              "| Вид деятельности |       |" at 100  skip
space(5) CAPS( gds-list.gds-name ) + " " + gds-list.artic + " " + v-type-goods                "|          по ОКДП |       |" at 100  skip
                                                                                              "| Номер блюда по   |" + string (num-re)   at 100   skip
                                                                                              "|сборнику рецептур,|       |" at 100  skip
                                                                                              "|         ТТК, СТП |       |" at 100  skip
                                                                                              "|     Вид операции |       |" at 100  skip
                                                                                              "+--------------------------+" at 100  skip.

 PUT STREAM OutStream UNFORMATTED
        space(5) string( "        КАЛЬКУЛЯЦИОННАЯ КАРТОЧКА "   )
                  skip
                 "Дата составления " + cur-time-date() at 100 skip
      .


  PUT STREAM OutStream UNFORMATTED
        vv0  skip
        vv1  skip
        vv2 skip
        vv0  skip
      .
    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .
   /*
   "Общая стоимость сырьевого набора на 100 блюд"
   "Наценка"
   "НДС"
   "Цена продажи блюжа"
   "Выход одного блюда в готовом виде"

   */

PUT STREAM OutStream UNFORMATTED  vv0 skip.
&scop v-val    PUT STREAM OutStream UNFORMATTED string(~{&v-pole-name})  format "x(57)" .~
   for each temp-doc : ~
       PUT STREAM OutStream UNFORMATTED ":" string(~{&v-pole}) format "x(32)" .~
   end. ~
   PUT STREAM OutStream skip.


&scop v-pole-name     'Общая стоимость сырьевого набора на 100 блюд'
&scop v-pole      temp-doc.all-stoim
{&v-val}

&scop v-pole-name     'Наценка,' + string(pp-r)
&scop v-pole      temp-doc.discn
{&v-val}

&scop v-pole-name     'НДС,' + string(pp-r)
&scop v-pole      temp-doc.Vat
{&v-val}


&scop v-pole-name     'Цена продажи 1 блюда,' + string(pp-r)
&scop v-pole      temp-doc.price-sale-1
{&v-val}

&scop v-pole-name     'Цена продажи ,' + string(pp-r)
&scop v-pole      temp-doc.price-sale
{&v-val}


&scop v-pole-name     'Выход одного блюда в готовом виде,грамм'
&scop v-pole      temp-doc.qnty-inp
{&v-val}
PUT STREAM OutStream UNFORMATTED  vv0 skip.


  PUT  STREAM OutStream " "
        skip
      " Заведующий производством _______________________ " skip
      " Калькуляцию составил     _______________________ " skip
      " УТВЕРЖДАЮ "                                        skip
      " Руководитель организации _______________________ " skip
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

define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .
define variable v-bar-code like bar-code.b-code no-undo .
define variable t-i as integer no-undo .

define variable var-norma as decimal no-undo .
define variable var-fact as decimal no-undo .
define variable var-delta as decimal no-undo .


define buffer buf_fbr-doc-line   for fbr-line .
define buffer bb_recipe          for recipe-gds.
define buffer buf_fbr-recipe-gds for fbr-recipe-gds.
define buffer buf_goods          for goods .

define variable var-season-qnty as decimal no-undo .

t-i = 0 .

      for each temp-doc break by temp-doc.fact-order by temp-doc.fact-date :
          for each bb_recipe no-lock where  bb_recipe.recipe-code = temp-doc.recipe-code :
            for each  buf_fbr-doc-line no-lock where buf_fbr-doc-line.doc-code  = temp-doc.doc-code and
                                                     buf_fbr-doc-line.recipe-code = temp-doc.recipe-code and
                                                     buf_fbr-doc-line.artic     = bb_recipe.artic and
                                                     buf_fbr-doc-line.prod-type = bb_recipe.prod-type and
                                                     buf_fbr-doc-line.prod-code = bb_recipe.prod-code
                                                     :
            for each  buf_fbr-recipe-gds no-lock where buf_fbr-recipe-gds.doc-code   = temp-doc.doc-code and
                                                      buf_fbr-recipe-gds.recipe-code = temp-doc.recipe-code and
                                                      buf_fbr-recipe-gds.artic       = bb_recipe.artic and
                                                      buf_fbr-recipe-gds.prod-type   = bb_recipe.prod-type and
                                                      buf_fbr-recipe-gds.prod-code   = bb_recipe.prod-code
                                                      :

                      if not can-find ( first temp-str where
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
                          temp-str.artic      =  buf_fbr-doc-line.artic
                          temp-str.prod-type  =  buf_fbr-doc-line.prod-type
                          temp-str.prod-code  =  buf_fbr-doc-line.prod-code

                        .
                      end.
                      /* заполним дельту */
                      find first temp-delta where
                            temp-delta.doc-code  = buf_fbr-doc-line.doc-code and
                            temp-delta.artic     = buf_fbr-doc-line.artic    and
                            temp-delta.prod-type = buf_fbr-doc-line.prod-type and
                            temp-delta.prod-code = buf_fbr-doc-line.prod-code no-error .
                            if not available temp-delta then create temp-delta.
                            run get-brutto-seson in this-procedure (output var-season-qnty ,
                                                  input buf_fbr-doc-line.artic     ,
                                                  input buf_fbr-doc-line.prod-type ,
                                                  input buf_fbr-doc-line.prod-code,
                                                  input temp-doc.recipe-code
                                                  )
                                 no-error .
                                 if error-status :error then message error-status :get-message(1) 2.



                            var-norma = var-season-qnty * temp-doc.ves * 100 / temp-doc.netto .
                            var-fact  =  buf_fbr-doc-line.fact-qnty  * temp-doc.ves * 100 / temp-doc.qnty-line .
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
                                  "это * 100 * вес1 / " temp-doc.qnty-line  " = " var-fact  skip

                                  "В fbr-рецепте брутто            : " buf_fbr-recipe-gds.brutto-qnty  skip
                                  "В гл.рецепте сезонный брутто    : " var-season-qnty         skip
                                  "это * 100 * вес1 / " temp-doc.netto  " = " var-norma skip
                                  "Разницу в отд строку " var-delta               skip
                                  "ее уч цена            " buf_fbr-doc-line.price-rubl
                                .
                              */
                                assign
                                  temp-delta.qnty-delta = round( var-delta , 3 )
                                  temp-delta.price-cost = buf_fbr-doc-line.price-rubl
                                  temp-delta.sum-cost   = buf_fbr-doc-line.price-rubl * 100 * temp-delta.qnty-delta  / temp-doc.porcii
                                  temp-delta.doc-code   = buf_fbr-doc-line.doc-code
                                  temp-delta.artic      = buf_fbr-doc-line.artic
                                  temp-delta.prod-type  = buf_fbr-doc-line.prod-type
                                  temp-delta.prod-code  = buf_fbr-doc-line.prod-code
                                .
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
define variable p-norma as decimal  no-undo .
define variable p-price as decimal  format ">>>>>>>>>>9.99" no-undo .
define variable p-sum   as decimal format "->>>>>>>>>9.99"  no-undo .
define buffer buf_fbr-line       for fbr-line .
define buffer buf_fbr-recipe for fbr-recipe .

PUT STREAM OutStream UNFORMATTED
    sym1                format "X(1)" space(0)
    0                   format ">>>>>" space(0)
    sym2                format "X(1)" space(0)
    p-name              format "X(40)" space(0)
    sym3                format "X(1)" space(0)
    ""                  format "X(9)" space(0)
    sym4                format "X(1)" space(0)
.


 for each temp-doc break by temp-doc.fact-date :
     find first temp-delta where
                temp-delta.doc-code  = temp-doc.doc-code  and
                temp-delta.artic     = temp-str.artic     and
                temp-delta.prod-type = temp-str.prod-type and
                temp-delta.prod-code = temp-str.prod-code no-error .

     if available temp-delta then do:
        p-norma = temp-delta.qnty-delta .

        find first buf_fbr-line       no-lock where
                                                    buf_fbr-line.doc-code     = temp-doc.doc-code and
                                                    buf_fbr-line.recipe-code  = temp-doc.recipe-code and
                                                    buf_fbr-line.artic        = temp-str.artic and
                                                    buf_fbr-line.prod-type    = temp-str.prod-type and
                                                    buf_fbr-line.prod-code    = temp-str.prod-code no-error .
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
      if p-price = 0 and p-norma = 0 then
         PUT STREAM OutStream UNFORMATTED "         :          :           :" .
      else
          PUT STREAM OutStream UNFORMATTED string( p-norma ,"->>>>>>9.<<<" )
                                          + ":"
                                          string(round(p-price,2),">>>>>>9.99" )
                                          + ":"
                                          string(round(p-sum,2)  ,"->>>>>>9.99" )
                                          + ":"
                                          .
 end.
  PUT STREAM OutStream UNFORMATTED skip.


 end. /* do */
end procedure. /* print-dop-str */

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
    )
    no-error .
    if error-status :error then message error-status :get-message(1) 3.

define variable v-void-decimal as decimal no-undo .
define variable v-brutto like recipe-gds.brutto-qnty  no-undo .
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
    )
    no-error .
    if error-status :error then message error-status :get-message(1) 4.



 p-se-qnty = v-brutto  .


 end. /* do */
end procedure. /* get-brutto-seson */