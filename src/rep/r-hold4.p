block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-hold4.p $
$Archive: rep/r-hold4.p $

Отчет по межфирменным операциям - Рейтинг направлений в реализации

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define input parameter x-date   as integer   no-undo .
define input parameter x-mon    as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-hold4.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-hold4.p $":U .
define variable vss-description as character no-undo init "Рейтинг направлений в реализации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/r-sym.i    }
/*  { ref/grplib.i }*/
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

  define buffer buf_hold-time     for hold-time .
  define buffer buf_hold-sale-grp for hold-sale-grp .
  define buffer buf_hold-gds-grp  for hold-gds-grp .

  DEFINE temp-table temp-hold4 no-undo
    field   node-code        as integer
    field   grp-name         as char
    field   qnty             as decimal
    field   sum-prib         as decimal
    field   sum-zak          as decimal
    field   sum-prod         as decimal
    INDEX pi  IS PRIMARY     grp-name
    INDEX pi2                sum-prib
  .

  define variable  date-start  as date  no-undo .
  define variable  date-end    as date  no-undo .
  define variable  Counter1    as integer   no-undo .
  define variable  ii          as integer no-undo .
  define variable  Line        as character no-undo .
  define variable  Line1       as character no-undo .

  define variable   all-sum-prib         as decimal no-undo .
  define variable   all-sum-prod         as decimal no-undo .

  define variable  v-num                 as integer                  no-undo.
  define variable  v-goods-name          as char                     no-undo.
  define variable  v-value               as decimal                  no-undo.
  define variable  v-sum                 as decimal                  no-undo.
  define variable  v-prc-sum             as decimal                  no-undo.
  define variable  v-prc-prib            as decimal                  no-undo.
  define variable  v-rent                as decimal                  no-undo.

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  if x-mon = 0 then do: /* это год */
    assign
      date-start = date(1,1,x-date)
      date-end   = date(12,31,x-date)
    .
  end.
  else do: /* месяц  */
    assign  date-start = date(x-mon,1,x-date) .
    if ii < 12 then assign date-end = date( x-mon + 1, 1, x-date) - 1 .
    else            assign date-end = date( 12, 31, x-date ) .
  end.

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */


  for each temp-hold4 : delete temp-hold4 . end.

  for each buf_hold-time where buf_hold-time.cat-code = {&hold-main-cat-code} no-lock  :
    if buf_hold-time.start-date < date-start or buf_hold-time.end-date > date-end then next .
    for each buf_hold-sale-grp no-lock
      where buf_hold-sale-grp.time-code = buf_hold-time.time-code
        and buf_hold-sale-grp.cat-code  = buf_hold-time.cat-code
      :
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }

      find first temp-hold4 where temp-hold4.node-code = buf_hold-sale-grp.node-code  no-error .

      if not available temp-hold4 then do:
        create temp-hold4 .

/*        run grplib-get-full-name in this-procedure ( input buf_hold-sale-grp.node-code,output temp-hold4.grp-name) .*/
        find first buf_hold-gds-grp no-lock
          where buf_hold-gds-grp.node-code = buf_hold-sale-grp.node-code
        no-error .
        assign
          temp-hold4.grp-name  = buf_hold-gds-grp.grp-name
          temp-hold4.node-code = buf_hold-sale-grp.node-code
          temp-hold4.qnty      = 0
          temp-hold4.sum-prib  = 0
          temp-hold4.sum-zak   = 0
          temp-hold4.sum-prod  = 0
        .
      end.
      if x-SET_val_TYPE = 1 then do:
        assign
          temp-hold4.qnty      = temp-hold4.qnty     - buf_hold-sale-grp.fact-qnty
          temp-hold4.sum-prib  = temp-hold4.sum-prib - (buf_hold-sale-grp.sale-sum-rubl - buf_hold-sale-grp.purch-sum-rubl)
/*          temp-hold4.sum-prib  = temp-hold4.sum-prib + buf_hold-sale-grp.profit-rubl*/
          temp-hold4.sum-zak   = temp-hold4.sum-zak  - buf_hold-sale-grp.purch-sum-rubl
          temp-hold4.sum-prod  = temp-hold4.sum-prod - buf_hold-sale-grp.sale-sum-rubl
        .
      end.
      else do:
        assign
          temp-hold4.qnty      = temp-hold4.qnty     - buf_hold-sale-grp.fact-qnty
          temp-hold4.sum-prib  = temp-hold4.sum-prib - (buf_hold-sale-grp.sale-sum-base - buf_hold-sale-grp.purch-sum-base)
/*          temp-hold4.sum-prib  = temp-hold4.sum-prib + buf_hold-sale-grp.profit-base*/
          temp-hold4.sum-zak   = temp-hold4.sum-zak  - buf_hold-sale-grp.purch-sum-base
          temp-hold4.sum-prod  = temp-hold4.sum-prod - buf_hold-sale-grp.sale-sum-base
        .
      end.
    end.
  end.

  assign
    all-sum-prib = 0
    all-sum-prod = 0
    v-num        = 0
  .
  for each temp-hold4 no-lock : /* считаем общие суммы */
    assign
      all-sum-prib = all-sum-prib + temp-hold4.sum-prib
      all-sum-prod = all-sum-prod + temp-hold4.sum-prod
    .
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
        sym1  v-num        column-label "№ !рейт "               format ">>>9"           space(0)
        sym2  v-goods-name column-label " Наименование группы товаров! " format "X(80)"  space(0)
        sym3  v-value      column-label " Кол-во ! "             format "->,>>>,>>9.999" space(0)
        sym4  v-sum        column-label "Сумма !прибыли"         format "->>,>>>,>>9.99" space(0)
        sym5  v-prc-sum    column-label "% в сумме!реализации"   format "->>9.99"        space(0)
        sym6  v-prc-prib   column-label "% в сумме!прибыли"      format ">>9.99"         space(0)
        sym7 v-rent        column-label "%  !рентаб."            format "->>>9.99"        space(0)
        sym8
  HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(100)"
        string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 100 format "X(15)" SKIP
        Line format "X(155)" AT 1
  with width {&A4_CW} down stream-io.

  { cmp/open-out.i stream OutStream " " {&CS_PS} }

  FORM HEADER
      Line format "X(155)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream OutStream  SPACE(30) ReportNAme format "X(100)"  SKIP .
  PUT stream OutStream  ReportHeader format "X(100)" SKIP .

  run PutColumnTitulExcel in this-procedure .

  for each temp-hold4 no-lock
    break by temp-hold4.sum-prib descending
    :

    if ( v-row ) >= 63000 then do:
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

  end. /* for each temp-hold4  */

  PUT STREAM OutStream Line format "X(155)".

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
  run macr_excel_char (ReportNAme, 1, 4) .
  run macr_cell_format ( 11, yes, no, ?, 1, 4, 1, 4) .
  run macr_excel_char (ReportHeader, 2, 1) .

  run macr_excel_char("№ рейт.", 3, 1) .
  run macr_cell_size (4,?, 3, 1,?,?).
  run macr_excel_char("Наименование группы товаров", 3, 2) .
  run macr_cell_size (40,?, 3, 2,?,?).
  run macr_excel_char("Кол-во", 3, 3) .
  run macr_excel_char("Сумма прибыли", 3, 4) .
  run macr_excel_char("% в сумме реализации", 3, 5) .
  run macr_excel_char("% в сумме прибыли", 3, 6) .
  run macr_excel_char("% рентаб.", 3, 7) .

  run macr_cell_bordur ( 3, 1, 3, 7) .
  run macr_cell_format ( 10, yes, no, 35, 3, 1, 3, 7) .
  run macr_cell_size   (12,?, 3, 3, 3, 7) .

  end.
end procedure. /* PutColumnTitulExcel */



procedure PrintLine :
  do
  on error undo, return error return-value
  :
    assign
      v-num        = v-num + 1
      v-goods-name = temp-hold4.grp-name
      v-value      = temp-hold4.qnty
      v-sum        = temp-hold4.sum-prib
      v-prc-sum    = temp-hold4.sum-prod * 100 / all-sum-prod
      v-prc-prib   = temp-hold4.sum-prib * 100 / all-sum-prib
      v-rent       = temp-hold4.sum-prib * 100 / temp-hold4.sum-zak
    .
    if v-rent = ? then assign v-rent = 0 .

    display stream outstream  sym1    v-num
                              sym2    v-goods-name
                              sym3    v-value
                              sym4    v-sum
                              sym5    v-prc-sum
                              sym6    v-prc-prib
                              sym7    v-rent
                              sym8
    with frame f-doc.
    down stream outstream with frame f-doc .

    run macr_excel_char(string(v-num), v-row, 1) .
    run macr_excel_char(v-goods-name , v-row, 2) .
    run macr_excel_sum  ( v-value    , v-row, 3,  3) .
    run macr_excel_sum  ( v-sum      , v-row, 4,  2) .
    run macr_excel_sum  ( v-prc-sum  , v-row, 5,  2) .
    run macr_excel_sum  ( v-prc-prib , v-row, 6,  2) .
    run macr_excel_sum  ( v-rent     , v-row, 7,  2) .
    assign v-row = v-row + 1 .

  end.
end procedure. /* PrintLine */