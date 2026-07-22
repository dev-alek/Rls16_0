block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-hold5.p $
$Archive: rep/r-hold5.p $

Отчет по межфирменным операциям - Рейтинг поставщиков

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define input parameter x-date   as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-hold5.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-hold5.p $":U .
define variable vss-description as character no-undo init "Рейтинг поставщиков".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/r-sym.i    }
{ ref/grplib.i   }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */

do
on error undo, return error
:

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  { rep/mcrexcel.i } /* Функции для форматирования полей для передачи в EXcel         */

  define Stream OutStream.

  define buffer buf_clients    for clients .
  define buffer buf_hold-time  for hold-time .
  define buffer buf_hold-purch-supp for hold-purch-supp .

  DEFINE temp-table temp-hold5 no-undo
    field   cli-code         as integer
    field   cli-type         as char
    field   cli-name         as char
    field   sum-zak          as decimal
    INDEX pi  IS PRIMARY  cli-type   cli-code
  .

  define variable  date-start  as date  no-undo .
  define variable  date-end    as date  no-undo .
  define variable  Counter1    as integer   no-undo .
  define variable  ii          as integer no-undo .
  define variable  Line        as character no-undo .
  define variable  Line1       as character no-undo .

  define variable   all-sum         as decimal no-undo .

  define variable  v-num                 as integer                  no-undo.
  define variable  v-goods-name          as char                     no-undo.
  define variable  v-sum                 as decimal                  no-undo.
  define variable  v-prc-sum             as decimal                  no-undo.

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  assign
    date-start = date(1,1,x-date)
    date-end   = date(12,31,x-date)
  .

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */


  for each temp-hold5 : delete temp-hold5 . end.

  for each buf_hold-time where buf_hold-time.cat-code = {&hold-main-cat-code} no-lock  :
    if buf_hold-time.start-date < date-start or buf_hold-time.end-date > date-end then next .
    for each buf_hold-purch-supp no-lock
      where buf_hold-purch-supp.time-code = buf_hold-time.time-code
        and buf_hold-purch-supp.cat-code  = buf_hold-time.cat-code
      :
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }

      find first temp-hold5
        where temp-hold5.cli-code = buf_hold-purch-supp.cli-code
          and temp-hold5.cli-type = buf_hold-purch-supp.cli-type
      no-error .

      if not available temp-hold5 then do:
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_hold-purch-supp.cli-type
            and buf_clients.obj-code = buf_hold-purch-supp.cli-code
        no-error .

        create temp-hold5 .

        assign
          temp-hold5.cli-code = buf_hold-purch-supp.cli-code
          temp-hold5.cli-type = buf_hold-purch-supp.cli-type
          temp-hold5.cli-name = buf_clients.obj-name
          temp-hold5.sum-zak  = 0
        .
      end.
      if x-SET_val_TYPE = 1 then do:
        assign  temp-hold5.sum-zak   = temp-hold5.sum-zak  + buf_hold-purch-supp.purch-sum-rubl .
      end.
      else do:
        assign  temp-hold5.sum-zak   = temp-hold5.sum-zak  + buf_hold-purch-supp.purch-sum-base .
      end.
    end.
  end.

  assign
    all-sum = 0
    v-num   = 0
  .
  for each temp-hold5 no-lock : /* считаем общие суммы */
    assign  all-sum = all-sum + temp-hold5.sum-zak  .
  end.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .


  { gbl/working.i }

  Line = fill("-", 160).

  DEFINE frame f-doc
        sym1  v-num        column-label "№ !рейт"                    format ">>>9"           space(0)
        sym2  v-goods-name column-label " Наименование поставщика! " format "X(42)"          space(0)
        sym3  v-sum        column-label "Сумма !закупки"             format "->>,>>>,>>9.99" space(0)
        sym4  v-prc-sum    column-label "% в сумме!закупки"          format "->>9.99"        space(0)
        sym5
  HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 60 format "X(15)" SKIP
        Line format "X(78)" AT 1
  with width {&A4_CW} down stream-io.

  { cmp/open-out.i stream OutStream " " {&CS_PS} }

  FORM HEADER
      Line format "X(78)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream OutStream  SPACE(20) ReportNAme format "X(100)"  SKIP .
  PUT stream OutStream  ReportHeader format "X(100)" SKIP .

  run PutColumnTitulExcel in this-procedure .

  for each temp-hold5 no-lock
    break by temp-hold5.sum-zak descending
    :

    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      /*Запишем в файл параметров */
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      /* создаем временный файл */
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      v-ind = v-ind + 1 .
      run PutColumnTitulExcel in this-procedure .
    end.

    run PrintLine in this-procedure .

  end. /* for each temp-hold5  */

  PUT STREAM OutStream Line format "X(78)".

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

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


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-row = 4
  .
  run macr_excel_char (ReportNAme, 1, 2) .
  run macr_cell_format ( 11, yes, no, ?, 1, 4, 1, 4) .
  run macr_excel_char (ReportHeader, 2, 1) .

  run macr_excel_char("№ рейт.", 3, 1) .
  run macr_cell_size (4,?, 3, 1,?,?).
  run macr_excel_char("Наименование поставщика", 3, 2) .
  run macr_cell_size (40,?, 3, 2,?,?).
  run macr_excel_char("Сумма закупки", 3, 3) .
  run macr_excel_char("% в сумме закупки", 3, 4) .

  run macr_cell_bordur ( 3, 1, 3, 4) .
  run macr_cell_format ( 10, yes, no, 35, 3, 1, 3, 4) .
  run macr_cell_size   (12,?, 3, 3, 3, 4) .

  end.
end procedure. /* PutColumnTitulExcel */



procedure PrintLine :
  do
  on error undo, return error return-value
  :
    assign
      v-num        = v-num + 1
      v-goods-name = temp-hold5.cli-name
      v-sum        = temp-hold5.sum-zak
      v-prc-sum    = temp-hold5.sum-zak * 100  / all-sum
    .

    display stream outstream  sym1    v-num
                              sym2    v-goods-name
                              sym3    v-sum
                              sym4    v-prc-sum
                              sym5
    with frame f-doc.
    down stream outstream with frame f-doc .

    run macr_excel_char(string(v-num), v-row, 1) .
    run macr_excel_char(v-goods-name , v-row, 2) .
    run macr_excel_sum  ( v-sum      , v-row, 3,  2) .
    run macr_excel_sum  ( v-prc-sum  , v-row, 4,  2) .
    assign v-row = v-row + 1 .

  end.
end procedure. /* PrintLine */