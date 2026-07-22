block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-bld.p $
$Archive: rep/r-bld.p $

Отчет о реализации блюд и товаров в рознице

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/



do
on error undo, return error
:
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bld.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-bld.p $":U .
define variable vss-description as character no-undo init "Отчет о реализации блюд и товаров в рознице".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ rep/r-sym.i    }
{ ref/grplibfn.i }

define buffer buf_goods    for goods.
define buffer buf_clients  for clients.
define buffer buf_gds-obj  for gds-obj.
define buffer buf_gds-grp  for gds-grp.
define buffer buf_stk-line for stk-line.

DEFINE temp-table temp-DiscSales no-undo
field   fact-qnty        as decimal
field   sum-sale         as decimal
field   prod-type        as  char
field   prod-code        as  integer
field   artic            as  char
field   gds-name         as  char
field   grp-name         as  char
field   price            as  decimal
field   unit-base        as  char
field   grp-code         as  integer
INDEX pi  IS PRIMARY   artic  prod-type prod-code
INDEX pi2              grp-name
.

define variable  v-fact-order           as decimal   no-undo .
define variable  v-fact-order-start     as decimal   no-undo .
define variable  v-fact-order-end       as decimal   no-undo .

define variable p-fact-qnty     as decimal   no-undo .
define variable p-cost-rubl     as decimal   no-undo .
define variable p-sale-rubl     as decimal   no-undo .
define variable t-dec           as decimal   no-undo .

define variable ind                    as integer   no-undo .
define variable ii                     as integer initial 0  no-undo .
define variable Counter1               as integer   no-undo .
define variable CurrGrpName            as character no-undo .
define variable Line                   as character no-undo .
define variable str-find               as character no-undo .


define variable v-NameString  as character no-undo .
define variable v-unit-base  as character no-undo .
define variable g#gds-engl as logical   no-undo .
run get-gds-engl   in my-handle ( output g#gds-engl ) .

run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ). /*Поиск нач fact-order*/
run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ).   /*Поиск посл fact-order*/

assign
  Counter1 = 0 .
.
{ rep/repfrm.i def } /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 5 } /* Показать окно информации о текущем процессе */

for each temp-DiscSales :
  delete temp-DiscSales .
end.



for each obj-list no-lock :
  for each buf_gds-obj
      where buf_gds-obj.obj-type  = obj-list.obj-type
        and buf_gds-obj.obj-code  = obj-list.obj-code :
    find first buf_goods no-lock
      where buf_goods.gds-code = buf_gds-obj.gds-code
    no-error.

    { rep/r-bld.i }
  end.
end.



def var sum-all as dec init 0.
for each temp-DiscSales :
  if temp-DiscSales.fact-qnty = 0 then do:
  delete temp-DiscSales.
  end.
  else do:
  assign  temp-discSales.price = temp-DiscSales.sum-sale / temp-DiscSales.fact-qnty
  sum-all = sum-all + temp-DiscSales.sum-sale.
  end.
end.


  { gbl/working.i }

  Line = fill("-", 250).

  DEFINE frame f-doc
  sym1  temp-DiscSales.gds-name  column-label "                  Наименование ! "        format "X(50)"               space(0)
  sym2  temp-DiscSales.price     column-label "Цена   ! ({&abbr_rub}.)"            format ">>>,>>>,>>9.99"          space(0)
  sym3  temp-DiscSales.unit-base column-label "   Единица! "               format "X(15)"               space(0)
  sym4  temp-DiscSales.fact-qnty column-label "  Количество  ! "           format "->>>,>>>,>>9.999"    space(0)
  sym5  temp-DiscSales.sum-sale  column-label "Сумма        !({&abbr_rub}.)"           format "->>>,>>>,>>>,>>9.99" space(0)
  sym6
  HEADER
  Line format "X(125)" AT 1
  with width {&A4_CW0} down stream-io.
   reportpageheight = {&LS_PS_A4}  .
  run prn-lib-open-stream  in this-procedure (
                                              input my-handle
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
  FORM HEADER
  Line format "X(125)" AT 1 SKIP
  with FRAME BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream PrnLibStream SPACE(45) "Отчет о реализации блюд и товаров в рознице" SKIP .
  PUT stream PrnLibStream str1 at 50 format "X(100)" SKIP .

  assign  v-NameString = "Выбор объекта: " .
  PUT stream PrnLibStream v-NameString format "X(100)" SKIP .
  for each obj-list no-lock:
    Assign  v-NameString = obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), " .
    PUT stream PrnLibStream SPACE(5) v-NameString format "X(100)" SKIP .
  end.


  for each temp-DiscSales :

    display stream PrnLibStream
    sym1  temp-DiscSales.gds-name
    sym2  temp-DiscSales.price
    sym3  temp-DiscSales.unit-base
    sym4  temp-DiscSales.fact-qnty
    sym5  temp-DiscSales.sum-sale
    sym6
    with frame f-doc.
    down stream PrnLibStream with frame f-doc .

  End.

  PUT STREAM PrnLibStream Line format "X(125)".


  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (
                                            input my-handle
                                            ,input 8
                                            ).
end.