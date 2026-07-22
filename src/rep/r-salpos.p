block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-salpos.p $
$Archive: rep/r-salpos.p $

Отчет Сальдо по поставщикам

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/

define Stream OutStream.

do
on error undo, return error
:
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-salpos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-salpos.p $":U .
define variable vss-description as character no-undo init "Сальдо по поставщикам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ cmp/r-page1.i  }
/*{ gbl/paramls.i }*/
/*{ rep/mcrexcel.i }*/

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/prn-lib.i }

/*define variable make-excel as logical   no-undo .*/

  &scop FL    "X(149)"

  define variable v-ind             as integer   no-undo .
  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .

  define variable v-all-sum1        as decimal   no-undo .
  define variable v-all-sum2        as decimal   no-undo .
  define variable v-all-sum3        as decimal   no-undo .
  define variable v-all-sum4        as decimal   no-undo .
  define variable v-NameString  as character no-undo .

  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 50 } /* Показать окно информации о текущем процессе */

  define buffer buf_currency  for currency .
  define buffer buf_parts     for parts .
  define buffer buf_contract  for contract .
  define buffer buf_clients   for clients .
  define buffer buf_fin-ob    for fin-ob .
  define buffer buf_fin-doc   for fin-doc .

  { gbl/working.i }

  DEFINE temp-table temp-obj no-undo
    field   obj-name     as character
    field   obj-type     as character
    field   obj-code     as integer
    INDEX pi  IS PRIMARY   obj-type obj-code
/*    INDEX pi1              obj-name*/
  .
  for each store no-lock where store.host-code = v-cntxt-host-code-obj :
    find first clients no-lock where clients.obj-type = {&stock} and clients.obj-code = store.obj-code no-error .
    if available clients then do:
      create temp-obj .
      assign  temp-obj.obj-name = clients.obj-name    temp-obj.obj-type = clients.obj-type    temp-obj.obj-code = clients.obj-code   .
    end.
  end.
  for each shop no-lock where shop.host-code = v-cntxt-host-code-obj :
    find first clients no-lock where clients.obj-type = {&shop} and clients.obj-code = shop.obj-code no-error .
    if available clients then do:
      create temp-obj .
      assign  temp-obj.obj-name = clients.obj-name    temp-obj.obj-type = clients.obj-type    temp-obj.obj-code = clients.obj-code   .
    end.
  end.


  DEFINE temp-table temp-doc no-undo
    field   sum1          as decimal
    field   sum2          as decimal
    field   sum3          as decimal
    field   sum4          as decimal
    field   cli-name     as character
    field   cli-type     as character
    field   cli-code     as integer
    INDEX pi  IS PRIMARY   cli-type cli-code
  .

  find first G#CUSTOMER no-error .
  if not available G#CUSTOMER then do: /* все поставщики  */
    for each buf_contract no-lock
      where buf_contract.host-code = v-cntxt-host-code-obj
        break by buf_contract.cli-type by buf_contract.cli-code
      :
      if first-of(buf_contract.cli-code) then do:
        find first buf_clients no-lock where buf_clients.obj-type = buf_contract.cli-type and buf_clients.obj-code = buf_contract.cli-code no-error .
        if not available buf_clients then next .
        { rep/r-salps1.i } /* смотрим и кладем в темп-тейбл  */
      end.
      { rep/r-salps2.i } /* смотрим и кладем в темп-тейбл  */
    end.
  end.
  else do:  /* список поставщиков */
    for each G#CUSTOMER :
      find first buf_clients no-lock where buf_clients.obj-type = G#CUSTOMER.obj-type and buf_clients.obj-code = G#CUSTOMER.obj-code .
      { rep/r-salps1.i } /* смотрим и кладем в темп-тейбл  */
      for each buf_contract no-lock
        where buf_contract.host-code = v-cntxt-host-code-obj
          and buf_contract.cli-type  = G#CUSTOMER.obj-type
          and buf_contract.cli-code  = G#CUSTOMER.obj-code
        :
        { rep/r-salps2.i } /* смотрим и кладем в темп-тейбл  */
      end.
    end.
  end.

  Line = fill("-", 250).

/*  assign*/
/*    make-excel = yes*/
/*    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"*/
/*  .*/
/*  output stream macr_excel to value(v-file-name) .*/
/*  assign v-ind = v-ind + 1 .*/


  DEFINE frame f-doc
      sym1  v-NameString    column-label "Поставщик! "                   format "X(50)"                    space(0)
      sym2  temp-doc.sum1   column-label "Сумма остатков!(выкуп)"        format "->>,>>>,>>>,>>>,>>9.99"   space(0)
      sym3  temp-doc.sum2   column-label "Сумма остатков!(отв.хранение)" format "->>,>>>,>>>,>>>,>>9.99"   space(0)
      sym4  temp-doc.sum3   column-label "Сумма остатков!(консигнация)"  format "->>,>>>,>>>,>>>,>>9.99"   space(0)
      sym5  temp-doc.sum4   column-label "Сальдо по!поставщику"          format "->>,>>>,>>>,>>>,>>9.99"   space(0)
      sym6
  HEADER
      string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(50)"
      string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 100 format "X(15)" SKIP Line format {&FL} AT 1
  with width {&DOS_CW} down stream-io.

  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&LS_PS_A4},input yes,input no).

  FORM HEADER
      Line format {&FL} AT 1 SKIP   "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream PrnLibStream SPACE(30) "Сальдо по поставщикам" SKIP .

  find first buf_currency  no-lock where buf_currency.curr-code = (x-SET_val_TYPE - 1) .
  find first clients no-lock where clients.obj-type = {&cmp} and clients.obj-code = v-cntxt-host-code-obj .
  PUT stream PrnLibStream string("Фирма: " + clients.obj-name + " (" + string(v-cntxt-host-code-obj) + ") ,валюта: " + buf_currency.curr-abbr) format "X(100)"   skip .

  for each temp-doc no-lock :
    run prn-line in this-procedure .
  end.

  PUT STREAM PrnLibStream Line format {&FL}.
  display stream PrnLibStream
    sym1 "Итого" @ v-NameString
    sym2 v-all-sum1 @ temp-doc.sum1
    sym3 v-all-sum2 @ temp-doc.sum2
    sym4 v-all-sum3 @ temp-doc.sum3
    sym5 v-all-sum4 @ temp-doc.sum4
    sym6
  with frame f-doc.
  down stream PrnLibStream with frame f-doc .
  PUT STREAM PrnLibStream Line format {&FL}.

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

/*  output stream macr_excel close .*/
/*  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .*/
/*  run end-proc .*/

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input parParentProc,input 8).
end.


procedure prn-line :
  do on error undo, return error return-value :
    assign
      v-NameString = temp-doc.cli-type + " " + string(temp-doc.cli-code) + " " + temp-doc.cli-name
      v-all-sum1 = v-all-sum1 + temp-doc.sum1
      v-all-sum2 = v-all-sum2 + temp-doc.sum2
      v-all-sum3 = v-all-sum3 + temp-doc.sum3
      v-all-sum4 = v-all-sum4 + temp-doc.sum4
    .
    display stream PrnLibStream
      sym1  v-NameString
      sym2  temp-doc.sum1
      sym3  temp-doc.sum2
      sym4  temp-doc.sum3
      sym5  temp-doc.sum4
      sym6
    with frame f-doc.
    down stream PrnLibStream with frame f-doc .

/*    run macr_excel_char(temp-DiscSales.name    , v-row, 1) .*/
/*    run macr_excel_char(temp-DiscSales.curr    , v-row, 2) .*/
/*    run macr_excel_sum (temp-DiscSales.sum-doc , v-row, 3, 2) .*/
/*    run macr_excel_sum (temp-DiscSales.sum-rubl, v-row, 3, 2) .*/
/*    run macr_excel_sum (temp-DiscSales.sum-base, v-row, 3, 2) .*/
/*    assign v-row = v-row + 1 .*/
  end.
end procedure. /* prn-line */


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
/*    assign  v-row = 4 .*/
/*    run macr_excel_char ("Cостояние финансов на " + string(x-date,"99/99/9999") + "г.", 1, 2) .*/
/*    run macr_cell_format ( 11, yes, no, ?, 1, 2, 1, 2) .*/
/*    run macr_excel_char (v-NameString, 2, 1) .*/
/*    run macr_excel_char("Наименование счета", 3, 1) .*/
/*    run macr_cell_size (40,?, 3, 1,?,?).*/
/*    run macr_excel_char("Вал", 3, 2) .*/
/*    run macr_cell_size (4,?, 3, 2,?,?).*/
/*    run macr_excel_char("в валюте счета", 3, 3) .*/
/*    run macr_excel_char("в {&abbr_rublyah}", 3, 4) .*/
/*    run macr_excel_char("в Б.валюте", 3, 5) .*/

/*    run macr_cell_bordur ( 3, 1, 3, 5) .*/
/*    run macr_cell_format ( 10, yes, no, 35, 3, 1, 3, 5) .*/
/*    run macr_cell_size (12,?, 3, 3, 3, 5) .*/
   end.
end procedure. /* PutColumnTitulExcel */