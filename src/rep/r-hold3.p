block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-hold3.p $
$Archive: rep/r-hold3.p $

Отчет по межфирменным операциям - Рейтинг товаров в реализации

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define input parameter x-date   as integer   no-undo .
define input parameter x-mon    as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-hold3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-hold3.p $":U .
define variable vss-description as character no-undo init "Рейтинг товаров в реализации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/r-sym.i    }
{ cmp/r-pril.i   }
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i  }
{ rep/lkp-font.i }

do
on error undo, return error
:

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).

  { rep/mcrexcel.i }

  define Stream OutStream.

  define buffer buf_goods    for goods.
  define buffer buf_hold-time  for hold-time.
  define buffer buf_hold-sale  for hold-sale.

  DEFINE temp-table temp-hold3 no-undo
    field   artic            as char
    field   prod-code        as integer
    field   prod-type        as char
    field   gds-name         as char
    field   gds-unit         as char
    field   gds-code         as integer
    field   qnty             as decimal
    field   sum-prib         as decimal
    field   sum-zak          as decimal
    field   sum-prod         as decimal
    INDEX pi  IS PRIMARY     gds-code
    INDEX pi2                sum-prib
  .

  define variable  date-start  as date  no-undo .
  define variable  date-end    as date  no-undo .
  define variable  Counter1    as integer   no-undo .
  define variable  ii          as integer no-undo .
  define variable  Line        as character no-undo .
  define variable  Line1       as character no-undo .

  define variable   all-qnty             as decimal no-undo .
  define variable   all-sum-prib         as decimal no-undo .
  define variable   all-sum-prod         as decimal no-undo .

  define variable  v-num                 as integer                  no-undo.
  define variable  v-prod                as char                     no-undo.
  define variable  v-goods-name          as char                     no-undo.
  define variable  v-goods-unit          as char                     no-undo.
  define variable  v-value               as decimal                  no-undo.
  define variable  v-sum                 as decimal                  no-undo.
  define variable  v-prc-qnty            as decimal                  no-undo.
  define variable  v-prc-sum             as decimal                  no-undo.
  define variable  v-prib                as decimal                  no-undo.
  define variable  v-prc-prib            as decimal                  no-undo.
  define variable  v-nak-prib            as decimal                  no-undo.
  define variable  v-nak-qnty            as decimal                  no-undo.
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
    if x-mon < 12 then assign date-end = date( x-mon + 1, 1, x-date) - 1 .
    else               assign date-end = date( 12, 31, x-date ) .
  end.

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */


  for each temp-hold3 : delete temp-hold3 . end.

  for each buf_hold-time where buf_hold-time.cat-code = {&hold-main-cat-code} no-lock  :
    if buf_hold-time.start-date < date-start or buf_hold-time.end-date > date-end then next .
    for each buf_hold-sale no-lock
      where buf_hold-sale.time-code = buf_hold-time.time-code
        and buf_hold-sale.cat-code  = buf_hold-time.cat-code
      :
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }

      find first buf_goods no-lock where buf_goods.gds-code = buf_hold-sale.gds-code  no-error .

      case x-SelectGood :
        when {&g-all} then do:
        end.
        when {&g-prod} then do:    /* не все производители */
          find first  G#cli no-lock
            where G#cli.obj-type = buf_goods.prod-type
              and G#cli.obj-code = buf_goods.prod-code
            no-error .
          if not available G#cli then next.
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          define variable is-find     as logical   no-undo .
          assign is-find = no .
          for each tmp#grp :
            if buf_goods.grp-name begins tmp#grp.grp-name then do:  assign is-find = yes .   leave .   end.
          end.
          if not is-find then next.
        end.
       otherwise do:
          find first gds-list no-lock
            where gds-list.artic     = buf_goods.artic
              and gds-list.prod-type = buf_goods.prod-type
              and gds-list.prod-code = buf_goods.prod-code
            no-error .
          if not available gds-list then next.
        end.
      end case.

      find first temp-hold3 where temp-hold3.gds-code = buf_hold-sale.gds-code  no-error .

      if not available temp-hold3 then do:
        create temp-hold3 .

        if g#gds-engl then assign temp-hold3.gds-name = buf_goods.engl-name.
        else               assign temp-hold3.gds-name = buf_goods.gds-name.

        assign
          temp-hold3.artic     = buf_goods.artic
          temp-hold3.prod-type = buf_goods.prod-type
          temp-hold3.prod-code = buf_goods.prod-code
          temp-hold3.gds-unit = buf_goods.unit-base
          temp-hold3.gds-code = buf_goods.gds-code
          temp-hold3.qnty     = 0
          temp-hold3.sum-prib = 0
          temp-hold3.sum-zak  = 0
          temp-hold3.sum-prod = 0
        .
      end.
      if x-SET_val_TYPE = 1 then do:
        assign
          temp-hold3.qnty      = temp-hold3.qnty     - buf_hold-sale.fact-qnty
          temp-hold3.sum-prib  = temp-hold3.sum-prib - (buf_hold-sale.sale-sum-rubl - buf_hold-sale.purch-sum-rubl)
/*          temp-hold3.sum-prib  = temp-hold3.sum-prib + buf_hold-sale.profit-rubl*/
          temp-hold3.sum-zak   = temp-hold3.sum-zak  - buf_hold-sale.purch-sum-rubl
          temp-hold3.sum-prod  = temp-hold3.sum-prod - buf_hold-sale.sale-sum-rubl
        .
      end.
      else do:
        assign
          temp-hold3.qnty      = temp-hold3.qnty - buf_hold-sale.fact-qnty
/*          temp-hold3.sum-prib  = temp-hold3.sum-prib + buf_hold-sale.profit-base*/
          temp-hold3.sum-prib  = temp-hold3.sum-prib - (buf_hold-sale.sale-sum-base - buf_hold-sale.purch-sum-base)
          temp-hold3.sum-zak   = temp-hold3.sum-zak  - buf_hold-sale.purch-sum-base
          temp-hold3.sum-prod  = temp-hold3.sum-prod - buf_hold-sale.sale-sum-base
        .
      end.
    end.
  end.

  assign
    all-qnty     = 0
    all-sum-prib = 0
    all-sum-prod = 0
    v-num        = 0
  .
  for each temp-hold3 no-lock : /* считаем общие суммы */
    assign
      all-qnty     = all-qnty     + temp-hold3.qnty
      all-sum-prib = all-sum-prib + temp-hold3.sum-prib
      all-sum-prod = all-sum-prod + temp-hold3.sum-prod
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

  Line = fill("-", 200).

  DEFINE frame f-doc
        sym1  v-num        column-label "№ !рейт "               format ">>>9"           space(0)
        sym19  temp-hold3.artic  column-label " Артикул! " format "X(12)"         space(0)
        sym20  v-prod        column-label " Произ-! водитель" format "X(12)"         space(0)
        sym2  v-goods-name column-label " Наименование товара! " format "X(40)"          space(0)
        sym3  v-goods-unit column-label "Ед.!изм"                format "X(3)"           space(0)
        sym4  v-value      column-label " Кол-во ! "             format "->,>>>,>>9.999" space(0)
        sym5  v-sum        column-label "Сумма !прибыли"         format "->>,>>>,>>9.99" space(0)
        sym6  v-prc-qnty   column-label "% в кол-ве!реализации"  format "->>9.99"        space(0)
        sym7  v-prc-sum    column-label "% в сумме!реализации"   format "->>9.99"        space(0)
        sym8  v-prib       column-label "Прибыль  !на един."     format "->,>>>,>>9.99"  space(0)
        sym9  v-prc-prib   column-label "% в сумме!прибыли"      format "->>9.99"         space(0)
        sym10 v-nak-prib   column-label "%  !прибыли"            format "->>9.99"         space(0)
        sym11 v-nak-qnty   column-label "%  !товара "            format "->>9.99"         space(0)
        sym12 v-rent       column-label "%  !рентаб."            format "->>>9.99"       space(0)
        sym13
  HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(100)"
        string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 150 format "X(15)" SKIP
        Line format "X(193)" AT 1
  with width {&DOS_CW} down stream-io.

  { cmp/open-out.i stream OutStream " " ReportPageHeight }

  FORM HEADER
      Line format "X(193)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream OutStream  SPACE(30) ReportNAme format "X(100)"  SKIP .
  PUT stream OutStream  ReportHeader format "X(100)" SKIP .

  run PutColumnTitulExcel in this-procedure .

  for each temp-hold3 no-lock
    break by temp-hold3.sum-prib descending
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

  end. /* for each temp-hold3  */

  PUT STREAM OutStream Line format "X(193)".

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { gbl/stopwork.i }

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable v-orient-page as character no-undo .
  define variable DisabledOptions as integer   no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .


  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input  ReportFontNum
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
  run macr_excel_char("Артикул", 3, 2) .
  run macr_excel_char("Производитель", 3, 3) .
  run macr_excel_char("Наименование товара", 3, 4) .
  run macr_cell_size (40,?, 3, 4,?,?).
  run macr_excel_char("Ед. изм", 3, 5) .
  run macr_cell_size (4,?, 3, 5,?,?).
  run macr_excel_char("Кол-во", 3, 6) .
  run macr_excel_char("Сумма прибыли", 3, 7) .
  run macr_excel_char("% в кол-ве реализации", 3, 8) .
  run macr_excel_char("% в сумме реализации", 3, 9) .
  run macr_excel_char("Прибыль на един.", 3, 10) .
  run macr_excel_char("% в сумме прибыли", 3, 11) .
  run macr_excel_char("% прибыли", 3, 12) .
  run macr_excel_char("% товара", 3, 13) .
  run macr_excel_char("% рентаб.", 3, 14) .

  run macr_cell_bordur ( 3, 1, 3, 14) .
  run macr_cell_format ( 10, yes, no, 35, 3, 1, 3, 14) .
  run macr_cell_size (12,?, 3, 3, 3, 14) .

  end.
end procedure. /* PutColumnTitulExcel */



procedure PrintLine :
  do
  on error undo, return error return-value
  :
    assign
      v-num        = v-num + 1
      v-prod       = temp-hold3.prod-type + " " + string(temp-hold3.prod-code)
      v-goods-name = temp-hold3.gds-name
      v-goods-unit = temp-hold3.gds-unit
      v-value      = temp-hold3.qnty
      v-sum        = temp-hold3.sum-prib
      v-prc-qnty   = temp-hold3.qnty * 100 / all-qnty
      v-prc-sum    = temp-hold3.sum-prod * 100 / all-sum-prod
      v-prib       = temp-hold3.sum-prib / temp-hold3.qnty
      v-prc-prib   = temp-hold3.sum-prib * 100 / all-sum-prib
      v-nak-prib   = v-nak-prib + v-prc-prib
      v-nak-qnty   = v-nak-qnty + v-prc-qnty
      v-rent       = temp-hold3.sum-prib * 100 / temp-hold3.sum-zak
    .
    if v-prib = ? then assign v-prib = 0 .
    if v-rent = ? then assign v-rent = 0 .

    display stream outstream  sym1    v-num  temp-hold3.artic v-prod
                              sym2    v-goods-name
                              sym3    v-goods-unit
                              sym4    v-value
                              sym5    v-sum
                              sym6    v-prc-qnty
                              sym7    v-prc-sum
                              sym8    v-prib
                              sym9    v-prc-prib
                              sym10   v-nak-prib
                              sym11   v-nak-qnty
                              sym12   v-rent
                              sym13  sym19  sym20
    with frame f-doc.
    down stream outstream with frame f-doc .

    run macr_excel_char(temp-hold3.artic, v-row, 2) .
    run macr_excel_char(v-prod, v-row, 3) .
    run macr_excel_char(string(v-num), v-row, 1) .
    run macr_excel_char(v-goods-name , v-row, 4) .
    run macr_excel_char(v-goods-unit , v-row, 5) .
    run macr_excel_sum  ( v-value    , v-row, 6,  3) .
    run macr_excel_sum  ( v-sum      , v-row, 7,  2) .
    run macr_excel_sum  ( v-prc-qnty , v-row, 8,  2) .
    run macr_excel_sum  ( v-prc-sum  , v-row, 9,  2) .
    run macr_excel_sum  ( v-prib     , v-row, 10,  2) .
    run macr_excel_sum  ( v-prc-prib , v-row, 11,  2) .
    run macr_excel_sum  ( v-nak-prib , v-row, 12, 2) .
    run macr_excel_sum  ( v-nak-qnty , v-row, 13, 2) .
    run macr_excel_sum  ( v-rent     , v-row, 14, 2) .
    assign v-row = v-row + 1 .

  end.
end procedure. /* PrintLine */