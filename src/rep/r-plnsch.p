block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-plnsch.p $
$Archive: rep/r-plnsch.p $

Отчет Планируемые платежи

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/

define input parameter itog-comp   as logical   no-undo .
define input parameter itog-contract   as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-plnsch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-plnsch.p $":U .
define variable vss-description as character no-undo init "Отчет Планируемые платежи".
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
  &scop L2    12
  &scop L3    29
  &scop L4    35
  &scop L5    60
  &scop L6    85
  &scop L7    110
  &scop F1    "99/99/9999"
  &scop F2    "X(15)"
  &scop F3    ">>>9"
  &scop F4    "->>>,>>>,>>>,>>>,>>9.99"
  &scop FL    "X(110)"


DEFINE temp-table temp-doc no-undo
    field   sum-fo       as decimal
    field   sum-pl       as decimal
    field   contr        as integer
    field   contr-name   as character
    field   cli-name     as character
    field   cli-type     as character
    field   cli-code     as integer
    INDEX pi  IS PRIMARY   cli-type cli-code contr
  .

DEFINE temp-table temp-contr no-undo
    field   dat          as date
    field   day          as integer
    field   num          as character
    field   sum          as decimal
    field   contr        as integer
    INDEX pi  IS PRIMARY   contr dat
  .

  define variable  v-fact-order  as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-Date-Alone + 1 , output v-fact-order ). /*Поиск нач fact-order*/

  define variable v-ind             as integer   no-undo .
  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .
  define variable s-val as character no-undo .
  if x-SET_val_TYPE = 1 then assign s-val = "{&abbr_rubl}." .
  else                       assign s-val = "б.вал." .

  define variable v-sum        as decimal   no-undo .
  define variable v-sum1       as decimal   no-undo .
  define variable no-fo        as logical   no-undo .

  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

  define buffer buf_contract for contract .
  define buffer buf_clients  for clients .
  define buffer buf_fin-ob   for fin-ob .
  define buffer buf_fin-doc  for fin-doc .
  find first G#CUSTOMER no-error .
  if not available G#CUSTOMER then do: /* все поставщики  */
    for each buf_contract no-lock
      where buf_contract.host-code = v-cntxt-host-code-obj
        break by buf_contract.cli-type by buf_contract.cli-code
      :
      if first-of(buf_contract.cli-code) then do:
        find first buf_clients no-lock where buf_clients.obj-type = buf_contract.cli-type and buf_clients.obj-code = buf_contract.cli-code .
      end.
      { rep/r-plnsc1.i } /* смотрим и кладем в темп-тейбл  */
    end.
  end.
  else do:  /* список поставщиков */
    for each G#CUSTOMER :
      find first buf_clients no-lock where buf_clients.obj-type = G#CUSTOMER.obj-type and buf_clients.obj-code = G#CUSTOMER.obj-code .
      for each buf_contract no-lock
        where buf_contract.host-code = v-cntxt-host-code-obj
          and buf_contract.cli-type  = G#CUSTOMER.obj-type
          and buf_contract.cli-code  = G#CUSTOMER.obj-code
        :
        { rep/r-plnsc1.i } /* смотрим и кладем в темп-тейбл  */
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
    for each temp-doc break by temp-doc.cli-type by temp-doc.cli-code :
      if first-of(temp-doc.cli-code) then do:
        if itog-comp = no then do:
          PUT STREAM PrnLibStream string("|Контрагент: " + temp-doc.cli-name) format "X(89)" "|" at {&L7} skip .
          run is-page in this-procedure .
        end.
        assign
          v-sum = 0
          v-sum1 = 0
        .
      end.
      PUT STREAM PrnLibStream string("|Договор: " + temp-doc.contr-name) format "X(89)" "|" at {&L7}  skip .
      run is-page in this-procedure .
      if itog-comp = no then do:
        for each temp-contr where temp-contr.contr = temp-doc.contr :      run prn-line in this-procedure .    end.
      end.
      PUT STREAM PrnLibStream string("|Всего по " + temp-doc.contr-name) format "X(29)" "|" at {&L4} temp-doc.sum-fo format {&F4}  "|" at {&L5} temp-doc.sum-pl format {&F4} "|" at {&L6} (temp-doc.sum-fo - temp-doc.sum-pl)  format {&F4}   "|" at {&L7} skip  .
      run is-page in this-procedure .
/*      PUT STREAM PrnLibStream string("| Всего по договору: " + temp-doc.contr-name) format "X(29)" "|" at {&L4} temp-doc.sum-fo format {&F4}  "|" at {&L5} temp-doc.sum-pl format {&F4} "|" at {&L6} (temp-doc.sum-fo - temp-doc.sum-pl)  format {&F4}   "|" at {&L7} skip  .*/
      assign
        v-sum  = v-sum  + temp-doc.sum-fo
        v-sum1 = v-sum1 + temp-doc.sum-pl
      .
      if last-of(temp-doc.cli-code)  then do:
        PUT STREAM PrnLibStream Line format {&FL} skip .
        run is-page in this-procedure .
        PUT STREAM PrnLibStream string("|Всего по " + temp-doc.cli-name) format "X(29)" "|" at {&L4} v-sum format {&F4}  "|" at {&L5} v-sum1 format {&F4} "|" at {&L6} (v-sum - v-sum1)  format {&F4}   "|" at {&L7} skip  .
/*        PUT STREAM PrnLibStream string("| Всего по контрагенту: " + temp-doc.cli-name) format "X(29)" "|" at {&L4} v-sum format {&F4}  "|" at {&L5} v-sum1 format {&F4} "|" at {&L6} (v-sum - v-sum1)  format {&F4}   "|" at {&L7} skip  .*/
        run is-page in this-procedure .
        PUT STREAM PrnLibStream Line format {&FL} skip .
        run is-page in this-procedure .
      end.
    end.
  end.
  else do:
    for each temp-doc break by temp-doc.cli-type by temp-doc.cli-code :
      if first-of(temp-doc.cli-code) /*and itog-comp = no*/ then do:
        PUT STREAM PrnLibStream string("|Контрагент: " + temp-doc.cli-name) format "X(89)" "|" at {&L7} skip .
        assign
          v-sum  = 0
          v-sum1 = 0
        .
        run is-page in this-procedure .
      end.
      if itog-comp = no then do:
        for each temp-contr where temp-contr.contr = temp-doc.contr :      run prn-line in this-procedure .    end.
      end.
      assign
        v-sum  = v-sum  + temp-doc.sum-fo
        v-sum1 = v-sum1 + temp-doc.sum-pl
      .
      if last-of(temp-doc.cli-code)  then do:
        PUT STREAM PrnLibStream Line format {&FL} skip .
        run is-page in this-procedure .
        PUT STREAM PrnLibStream string("|Всего по " + temp-doc.cli-name) format "X(29)" "|" at {&L4} v-sum format {&F4}  "|" at {&L5} v-sum1 format {&F4} "|" at {&L6} (v-sum - v-sum1)  format {&F4}   "|" at {&L7} skip  .
/*        PUT STREAM PrnLibStream string("| Всего по контрагенту: " + temp-doc.cli-name) format "X(29)" "|" at {&L4} v-sum format {&F4}  "|" at {&L5} v-sum1 format {&F4} "|" at {&L6} (v-sum - v-sum1)  format {&F4}   "|" at {&L7} skip  .*/
        run is-page in this-procedure .
        PUT STREAM PrnLibStream Line format {&FL} skip .
        run is-page in this-procedure .
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
    if temp-contr.day > 0 then
      put stream PrnLibStream
        "|"  At {&L1}   temp-contr.dat  Format {&f1}
        "|"  At {&L2}   temp-contr.num  Format {&f2}
        "|"  At {&L3}   temp-contr.day  Format {&f3}
        "|"  At {&L4}   temp-contr.sum  Format {&f4}
        "|"  At {&L5}   "|"  At {&L6}   "|"  At {&L7}
      skip .
    else
      put stream PrnLibStream
        "|"  At {&L1}   temp-contr.dat  Format {&f1}
        "|"  At {&L2}   temp-contr.num  Format {&f2}
        "|"  At {&L3}
        "|"  At {&L4}   temp-contr.sum  Format {&f4}
        "|"  At {&L5}   "|"  At {&L6}   "|"  At {&L7}
      skip .

/*    run macr_excel_char(temp-doc.dat  , v-row, 1) .*/
/*    run macr_excel_char(temp-doc.styp , v-row, 2) .*/
/*    run macr_excel_char(temp-doc.num  , v-row, 2) .*/
/*    run macr_excel_sum (temp-doc.sum  , v-row, 3, 2) .*/
/*    run macr_excel_sum (v-sm          , v-row, 3, 2) .*/
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

    put stream PrnLibStream  skip cur-time-print() format "x(35)" string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>>>9" SKIP .

    put stream PrnLibStream
      skip  Line format {&FL}  skip
      "|"           "План. дата"     format "X(10)"
      "|" at {&L2}  " № фин.об."      format "X(10)"
      "|" at {&L3}  "Про-" format "X(4)"
      "|" at {&L4}  " Непогашенная"  format "X(15)"
      "|" at {&L5}  " Сумма "  format "X(15)"
      "|" at {&L6}  " Итого "  format "X(15)"
      "|" at {&L7}
      skip
      "|"           "платежа"     format "X(10)"
      "|" at {&L2}
      "|" at {&L3}  "сроч"        format "X(4)"
      "|" at {&L4}  string(" сумма (" + s-val + ")")    format "X(17)"
      "|" at {&L5}  "несвязанных"                       format "X(15)"
      "|" at {&L6}  string(" к оплате (" + s-val + ")") format "X(17)"
      "|" at {&L7}
      skip
      "|"
      "|" at {&L2}
      "|" at {&L3}  "дней " format "X(4)"
      "|" at {&L4}
      "|" at {&L5}  string("платежей (" + s-val + ")") format "X(17)"
      "|" at {&L6}
      "|" at {&L7}
      skip  Line format {&FL}  skip
    .
  end.
end procedure. /* PrintTitul */