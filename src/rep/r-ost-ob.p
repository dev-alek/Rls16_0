block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ost-ob.p $
$Archive: rep/r-ost-ob.p $

Отчет о суммарных остатках на объектах

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define Stream OutStream.

do
on error undo, return error
:
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ost-ob.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ost-ob.p $":U .
define variable vss-description as character no-undo init "Отчет о суммарных остатках на объектах".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/rep-bt.i   }

  define buffer buf_clients  for clients.
  define buffer buf_stk-tot for stk-tot.

  define variable  v-fact-order           as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-Date-Alone + 1 ,              output v-fact-order ).       /*Поиск нач fact-order*/

  define variable Counter1 as integer initial 0   no-undo .
  define variable Line     as character no-undo .
  define variable name     as character no-undo .
  define variable summ     as decimal   no-undo .
  define variable NDS      as decimal   no-undo .
  define variable NP       as decimal   no-undo .
  define variable sum-qnty     as decimal   no-undo .
  define variable sum-summ     as decimal   no-undo .
  define variable sum-NDS      as decimal   no-undo .
  define variable sum-NP       as decimal   no-undo .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  { gbl/working.i }

  Line = fill("-", 250).

  DEFINE frame f-doc
      sym1  name                   column-label " Объект "   format "X(49)"                 space(0)
      sym2  buf_stk-tot.fact-qnty  column-label " Кол-во "   format "->>,>>>,>>>,>>9.999"   space(0)
      sym3  summ                   column-label " Сумма  "   format "->>>,>>>,>>>,>>9.99"   space(0)
      sym4  NDS                    column-label " НДС  "     format "->>>,>>>,>>>,>>9.99"   space(0)
      sym5  NP                     column-label " НП  "      format "->,>>>,>>>,>>9.99"     space(0)
      sym6
    HEADER
      string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(60)"
      string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 100 format "X(15)" SKIP
      Line format "X(134)" AT 1
  with width {&A4_CW} down stream-io.

  { cmp/open-out.i stream OutStream " " {&PT_PS_A4} }

  FORM HEADER
      Line format "X(134)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream OutStream SPACE(20) "Отчет о суммарных остатках на объектах на " format "X(45)"  x-Date-Alone format "99/99/9999" SKIP .
  if x-SET_PAY_TYPE = 1 then do: /* Продажные цены */
    PUT stream OutStream "Суммы в продажных ценах." format "X(100)" SKIP .
  end.
  else do:
    if x-SET_val_TYPE = 1 then PUT stream OutStream "Суммы в учетных ценах в {&abbr_rublyah}." format "X(100)" SKIP .
    else                       PUT stream OutStream "Суммы в учетных ценах в валюте."          format "X(100)" SKIP .
  end.

  for each obj-list :
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    find first buf_clients no-lock
      where buf_clients.obj-type  = obj-list.obj-type
        and buf_clients.obj-code  = obj-list.obj-code
    no-error .
    assign name = buf_clients.obj-name + " (" + buf_clients.obj-type + '#' + string(buf_clients.obj-code) + ")"  .

    if x-SET_PAY_TYPE = 1 then do: /* Продажные цены */
      find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type   = obj-list.obj-type
          and buf_stk-tot.obj-code   = obj-list.obj-code
          and buf_stk-tot.fact-order < v-fact-order
          and buf_stk-tot.sum-type   = {&arh-crsa}
          and buf_stk-tot.cat-id     = {&root-cat-id}
      no-error .
      if not available buf_stk-tot then next .
      if var-report-r-b = "rubl" then
        assign
          summ = buf_stk-tot.sum-rubl
          NDS  = buf_stk-tot.VAT-rubl
          NP   = buf_stk-tot.SLT-rubl
        .
      else
        assign
          summ = buf_stk-tot.sum-base
          NDS  = buf_stk-tot.VAT-base
          NP   = buf_stk-tot.SLT-base
        .
    end.
    else do:
      find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type   = obj-list.obj-type
          and buf_stk-tot.obj-code   = obj-list.obj-code
          and buf_stk-tot.fact-order < v-fact-order
          and buf_stk-tot.sum-type   = {&arh-cost}
          and buf_stk-tot.cat-id     = {&root-cat-id}
      no-error .
      if not available buf_stk-tot then next .
      if x-SET_val_TYPE = 1 then
        assign
          summ = buf_stk-tot.sum-rubl
          NDS  = buf_stk-tot.VAT-rubl
          NP   = buf_stk-tot.SLT-rubl
        .
      else
        assign
          summ = buf_stk-tot.sum-base
          NDS  = buf_stk-tot.VAT-base
          NP   = buf_stk-tot.SLT-base
        .
    end.
    display stream outstream sym1 name sym2  buf_stk-tot.fact-qnty  sym3 summ sym4  NDS sym5  NP sym6 with frame f-doc.
    down stream outstream with frame f-doc .

    assign
      sum-qnty = sum-qnty + buf_stk-tot.fact-qnty
      sum-summ = sum-summ + summ
      sum-NDS  = sum-NDS  + NDS
      sum-NP   = sum-NP   + NP
    .
  end.

  PUT STREAM OutStream Line format "X(134)" skip .

  display stream outstream
    sym1 "Итого: " @  name
    sym2 sum-qnty  @  buf_stk-tot.fact-qnty
    sym3 sum-summ  @  summ
    sym4 sum-NDS   @  NDS
    sym5 sum-NP    @  NP
    sym6
  with frame f-doc.
  down stream outstream with frame f-doc .

  PUT STREAM OutStream Line format "X(134)"  .

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  run gbl/prnfilen.w
    (input  ""
    ,input  0
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input 7
    ,output v-user-action
    ,output v-printed
    ) .
end.