block-level on error undo, throw.
/*

$Revision: 8af0ca92507d, 852, rls $
$Author: EShklyar $
$Date: Wed Oct 19 12:26:26 2016 +0300 $
$Workfile: r-balcnt.p $
$Archive: rep/r-balcnt.p $

Баланс фин.обязательств и выплат по контрагенту за период

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/

define input parameter itog-comp   as logical   no-undo .
define input parameter itog-contract   as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 8af0ca92507d, 852, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Oct 19 12:26:26 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-balcnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-balcnt.p $":U .
define variable vss-description as character no-undo init "Баланс фин.обязательств и выплат по контрагенту за период".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
/*{ gbl/paramls.i }*/
/*{ rep/mcrexcel.i }*/
{ gbl/cur-time.i }

define Stream OutStream.

do
on error undo, return error
:

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/prn-lib.i }

/*define variable make-excel as logical   no-undo .*/

  &scop L1    1
  &scop L2    13
  &scop L3    17
  &scop L4    47
  &scop L5    70
  &scop L6    95
  &scop L7    120
  &scop F1    "99/99/9999"
  &scop F2    "X(3)"
  &scop F3    "X(20)"
  &scop F4    "X(20)"
  &scop F5    "->>>,>>>,>>>,>>>,>>9.99"
  &scop FL    "X(113)"


DEFINE temp-table temp-cli no-undo
    field   sum          as decimal
    field   cli-name     as character
    field   cli-type     as character
    field   cli-code     as integer
    INDEX pi  IS PRIMARY   cli-type cli-code
  .

DEFINE temp-table temp-contr no-undo
    field   sum          as decimal
    field   contr        as integer
    field   contr-name   as character
    INDEX pi  IS PRIMARY   contr
  .

DEFINE temp-table temp-doc no-undo
    field   sum          as decimal
    field   f-o          as decimal
    field   dat          as date
    field   num          as character
    field   nakl         as character
    field   contr        as integer
    field   contr-type   as character
/*    field   contr-name   as character*/
/*    field   cli-name     as character*/
    field   cli-type     as character
    field   cli-code     as integer
    field   typ          as integer
    field   styp         as character
    INDEX pi  IS PRIMARY   cli-type cli-code contr f-o
    INDEX pi1              cli-type cli-code f-o
    INDEX pi2              contr-type
  .

  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ). /*Поиск посл fact-order*/

  define variable v-ind             as integer   no-undo .
  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .
  define variable s-val as character no-undo .
  if x-SET_val_TYPE = 1 then assign s-val = "{&abbr_rubl}." .
  else                       assign s-val = "б.вал." .

  define variable v-sm         as decimal   no-undo .
  define variable v-sum        as decimal   no-undo .
  define variable v-sum1       as decimal   no-undo .
  define variable nn           as integer   no-undo .
  define variable v-nakl       as character no-undo .
  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  define buffer buf_contract for contract .
  define buffer buf_clients  for clients .
  define buffer buf_fin-ob   for fin-ob .
  define buffer buf_fin-doc  for fin-doc .
  define buffer buf_fin-ob-trn for fin-ob-trn .
  define buffer buf_fin-connect for fin-connect .
  find first G#CUSTOMER no-error .
  if not available G#CUSTOMER then do: /* все поставщики  */
    for each buf_contract no-lock
      where buf_contract.host-code = v-cntxt-host-code-obj
        break by buf_contract.cli-type by buf_contract.cli-code
      :
      if first-of(buf_contract.cli-code) then do:
        find first buf_clients no-lock where buf_clients.obj-type = buf_contract.cli-type and buf_clients.obj-code = buf_contract.cli-code .
        create temp-cli .
        assign
          temp-cli.sum       = 0
          temp-cli.cli-name  = buf_clients.obj-name
          temp-cli.cli-type  = buf_clients.obj-type
          temp-cli.cli-code  = buf_clients.obj-code
        .
      end.
      { rep/r-balcn1.i } /* смотрим и кладем в темп-тейбл  */
    end.
  end.
  else do:  /* список поставщиков */
    for each G#CUSTOMER :
      find first buf_clients no-lock where buf_clients.obj-type = G#CUSTOMER.obj-type and buf_clients.obj-code = G#CUSTOMER.obj-code .
      create temp-cli .
      assign
        temp-cli.sum       = 0
        temp-cli.cli-name  = buf_clients.obj-name
        temp-cli.cli-type  = buf_clients.obj-type
        temp-cli.cli-code  = buf_clients.obj-code
      .
      for each buf_contract no-lock
        where buf_contract.host-code = v-cntxt-host-code-obj
          and buf_contract.cli-type  = G#CUSTOMER.obj-type
          and buf_contract.cli-code  = G#CUSTOMER.obj-code
        :
        { rep/r-balcn1.i } /* смотрим и кладем в темп-тейбл  */
      end.
    end.
  end.

  { gbl/working.i }

  Line = fill("-", 250).

/*  assign*/
/*    make-excel = yes*/
/*    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"*/
/*  .*/
/*  output stream macr_excel to value(v-file-name) .*/
/*  assign v-ind = v-ind + 1 .*/

  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&CS_PS},input yes,input no).

  FORM with FRAME f-doc .

  run PrintTitul in this-procedure .
/*  run PutColumnTitulExcel in this-procedure .*/

  if itog-contract then do:
    for each temp-doc break by temp-doc.cli-type by temp-doc.cli-code by temp-doc.contr :
      if first-of(temp-doc.cli-code) and itog-comp = no then do:
        find first temp-cli where temp-cli.cli-code = temp-doc.cli-code and temp-cli.cli-type = temp-doc.cli-type .
        PUT STREAM PrnLibStream string("| Контрагент: " + temp-cli.cli-name) format "X(89)" "|" at {&L7} skip .
        PUT STREAM PrnLibStream "| Начальный остаток по контрагенту: " format "X(64)"  "|" at {&L6} temp-cli.sum format {&F5} "|" at {&L7} skip .
        assign v-sum = temp-cli.sum .
      end.
      if first-of(temp-doc.contr) and itog-comp = no  then do:
        find first temp-contr where temp-contr.contr = temp-doc.contr .
        PUT STREAM PrnLibStream string("| Договор: " + temp-contr.contr-name) format "X(89)" "|" at {&L7}  skip .
        PUT STREAM PrnLibStream "| Начальный остаток по договору: " format "X(64)"  "|" at {&L6} temp-contr.sum format {&F5} "|" at {&L7} skip .
        assign v-sum1 = temp-contr.sum .
      end.
      run prn-line in this-procedure .
      if last-of(temp-doc.contr)  then do:
        PUT STREAM PrnLibStream string("| Всего по договору: " + temp-contr.contr-name) format "X(64)" "|" at {&L6} v-sum1 format {&F5} "|" at {&L7} skip .
      end.
      if last-of(temp-doc.cli-code)  then do:
        PUT STREAM PrnLibStream Line format {&FL} skip .
        PUT STREAM PrnLibStream string("| Всего по контрагенту: " + temp-cli.cli-name) format "X(64)" "|" at {&L6} v-sum format {&F5}  "|" at {&L7} skip  .
        PUT STREAM PrnLibStream Line format {&FL} skip .
      end.
    end.
  end.
  else do:
    for each temp-doc break by temp-doc.cli-type by temp-doc.cli-code :
      if first-of(temp-doc.cli-code) /*and itog-comp = no*/ then do:
        find first temp-cli where temp-cli.cli-code = temp-doc.cli-code and temp-cli.cli-type = temp-doc.cli-type .
        PUT STREAM PrnLibStream string("| Контрагент: " + temp-cli.cli-name) format "X(89)" "|" at {&L7} skip .
        PUT STREAM PrnLibStream "| Начальный остаток по контрагенту: " format "X(64)"  "|" at {&L6} temp-cli.sum format {&F5} "|" at {&L7} skip .
        assign v-sum = temp-cli.sum .
      end.
      run prn-line in this-procedure .
      if last-of(temp-doc.cli-code)  then do:
        PUT STREAM PrnLibStream Line format {&FL} skip .
        PUT STREAM PrnLibStream string("| Всего по контрагенту: " + temp-cli.cli-name) format "X(64)" "|" at {&L6} v-sum format {&F5}  "|" at {&L7} skip .
        PUT STREAM PrnLibStream Line format {&FL} skip .
      end.
    end.
  end.

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

/*  output stream macr_excel close .*/
/*  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .*/
/*  run end-proc .*/

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input parParentProc,input 0).
end.


procedure prn-line :
  do on error undo, return error return-value :
    run is-page in this-procedure .

    if temp-doc.contr-type = {&expense} then do:   
        assign   v-sum  = v-sum + temp-doc.sum
          v-sum1 = v-sum1 + temp-doc.sum   .
          /*
      if temp-doc.typ = 0 then
        assign
          v-sum  = v-sum + temp-doc.sum
          v-sum1 = v-sum1 + temp-doc.sum
        .
      else
        if temp-doc.styp = {&income-cashless} or temp-doc.styp = {&income-cash} or temp-doc.styp = {&income-payoff}  then
          assign  v-sum  = v-sum + temp-doc.sum    v-sum1 = v-sum1 + temp-doc.sum  .
        else
          assign  v-sum  = v-sum - temp-doc.sum    v-sum1 = v-sum1 - temp-doc.sum  .
          */
    end.
    else do:
      if temp-doc.typ = 0 then
        assign
          v-sum  = v-sum + temp-doc.sum
          v-sum1 = v-sum1 + temp-doc.sum
        .
      else
        if temp-doc.styp = {&income-cashless} or temp-doc.styp = {&income-cash} or temp-doc.styp = {&income-payoff}  then
          assign  v-sum  = v-sum + temp-doc.sum    v-sum1 = v-sum1 + temp-doc.sum  .
        else
          assign  v-sum  = v-sum - temp-doc.sum    v-sum1 = v-sum1 - temp-doc.sum  .
    end.

    if itog-comp = no then do:
      if itog-contract then assign v-sm = v-sum1 .
      else                  assign v-sm = v-sum .

      put stream PrnLibStream
        "|"  At {&L1}   temp-doc.dat     Format {&f1}
        "|"  At {&L2}   temp-doc.styp    Format {&f2}
        "|"  At {&L3}   temp-doc.num     Format {&f3}
        "|"  At {&L4}   temp-doc.nakl    Format {&f4}
        "|"  At {&L5}   temp-doc.sum     Format {&f5}
        "|"  At {&L6}   v-sm             Format {&f5}
        "|"  At {&L7}
      skip .

/*    run macr_excel_char(temp-doc.dat  , v-row, 1) .*/
/*    run macr_excel_char(temp-doc.styp , v-row, 2) .*/
/*    run macr_excel_char(temp-doc.num  , v-row, 2) .*/
/*    run macr_excel_sum (temp-doc.sum  , v-row, 3, 2) .*/
/*    run macr_excel_sum (v-sm          , v-row, 3, 2) .*/
/*    assign v-row = v-row + 1 .*/
    end.
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


procedure is-page :
  do
  on error undo, return error return-value
  :
    if line-counter( PrnLibStream ) + 2 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream  skip Line format {&FL} skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream PrnLibStream .
      run PrintTitul .
    end.
/*    if  ( v-row ) >= 63000 then do:*/
/*      Output stream Macr_Excel  close .*/
/*      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .*/
/*      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .*/
/*      output stream  Macr_Excel to value(v-file-name) .*/
/*      assign*/
/*        v-ind = v-ind + 1*/
/*        v-row = 2*/
/*      .*/
/*      run PutColumnTitulExcel in this-procedure .*/
/*    end.*/
  end.
end procedure. /* is-page */


procedure PrintTitul :
  do
  on error undo, return error return-value
  :
    PUT stream PrnLibStream SPACE(10) ReportNAme format "X(100)" SKIP .
    PUT stream PrnLibStream str1 format "X(100)" SKIP .

    put stream PrnLibStream  skip cur-time-print() format "x(35)" string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP .

    put stream PrnLibStream
      skip  Line format {&FL}  skip
      "|"           " Дата"     format "X(5)"
      "|" at {&L2}  "Тип"       format "X(3)"
      "|" at {&L3}  " № док-та" format "X(10)"
      "|" at {&L4}  " № наклад" format "X(10)"
      "|" at {&L5}  string(" Сумма (" + s-val + ")")  format "X(15)"
      "|" at {&L6}  string(" Сальдо (" + s-val + ")") format "X(17)"
      "|" at {&L7}
      skip  Line format {&FL}  skip
    .
  end.
end procedure. /* PrintTitul */