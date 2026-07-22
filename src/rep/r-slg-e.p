block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-slg-e.p $
$Archive: rep/r-slg-e.p $

Отчет по закончившимся наименованиям

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/23/06
Author: Michael Kochetkov
Creation date: 03/23/06

*/

define input parameter NullStr  as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-slg-e.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-slg-e.p $":U .
define variable vss-description as character no-undo init "Отчет по закончившимся наименованиям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ ref/grplibfn.i }
{ rep/rep-bt.i   }
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i  }
{ rep/mcrexcel.i }

define Stream OutStream.

do
on error undo, return error
:

define buffer buf_goods    for goods.
define buffer buf_clients  for clients.
define buffer buf_gds-obj  for gds-obj.
define buffer buf_gds-grp  for gds-grp.
define buffer buf_stk-line for stk-line.

DEFINE temp-table temp-DiscSales no-undo
    field   sum-sale         as decimal
    field   sum-cost         as decimal
    field   prod-type        as  char
    field   prod-code        as  integer
    field   artic            as  char
    field   gds-name         as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   day              as  char
    field   last-post        as  date
/*    field   b-code           as  integer*/
    field   grp-code         as  integer
    INDEX pi  IS PRIMARY   artic  prod-type prod-code
/*    INDEX pi1              b-code*/
    INDEX pi2              grp-name
  .

  define variable  v-fact-order           as decimal   no-undo .

  define variable p-fact-qnty     as decimal   no-undo .
  define variable p-cost-rubl     as decimal   no-undo .
  define variable p-sale-rubl     as decimal   no-undo .
  define variable t-dec           as decimal   no-undo .

  define variable ind             as integer   no-undo .
  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable CurrGrpName            as character no-undo .
  define variable Line                   as character no-undo .
  define variable str-find               as character no-undo .

  define variable num as integer init 0  no-undo .

  define variable stat  as logical   no-undo .
  define variable fo    as decimal   no-undo .

  define variable v-prod as character no-undo .
  define variable v-prc        as decimal   no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  define variable v-sum-cost        as decimal   no-undo .
  define variable v-sum-sale        as decimal   no-undo .

  define variable v-NameString  as character no-undo .

  run day-begin-fact-order in this-procedure ( input x-date-alone,        output v-fact-order ).       /*Поиск нач fact-order*/

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 20 } /* Показать окно информации о текущем процессе */

  for each temp-DiscSales :
    delete temp-DiscSales .
  end.

  if x-SelectGood = {&g-all} then do: /* все товары */
    for each obj-list :
      for each  buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = obj-list.obj-type
          and buf_gds-obj.obj-code  = obj-list.obj-code
      :
        { rep/r-slg-e1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
      end.
    end.
  end.
  else do:
    for each obj-list :                /* встать на объект */
      case x-SelectGood :
       when {&g-all} then do:
       end.
        when {&g-prod} then do:    /* не все производители */
          for each G#cli , /* встать на производителя */
              each buf_gds-obj  no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.prod-type = G#cli.obj-type
              and buf_gds-obj.prod-code = G#cli.obj-code
             use-index pi  :
            { rep/r-slg-e1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            find first buf_gds-grp no-lock
              where buf_gds-grp.node-code = tmp#grp.node-code
            .
            run grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output CurrGrpName ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :
              { rep/r-slg-e1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.
        otherwise do:   /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            { rep/r-slg-e1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
          end.
        end.
      end case.
    end.                    /* for each ... по объектам */
  end.

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .

  { gbl/working.i }

  Line = fill("-", 250).

  DEFINE frame f-doc
      sym1  temp-DiscSales.artic      column-label " Артикул!       "            format "X(12)"                space(0)
      sym2  v-prod                    column-label " Произ-!водитель"            format "X(8)"                 space(0)
      sym3  temp-DiscSales.gds-name   column-label " Наименование товара! "      format "X(50)"                space(0)
      sym6  temp-DiscSales.day        column-label "Дни без!товара"              format "X(8)"                 space(0)
      sym7  temp-DiscSales.last-post  column-label "Послед.!постав"              format "99/99/99"             space(0)
      sym8
  HEADER
      string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(60)"
      string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 70 format "X(15)" SKIP
      Line format "X(97)" AT 1
  with width {&A4_CW} down stream-io.

  { cmp/open-out.i stream OutStream " " {&CS_PS} }

  FORM HEADER
      Line format "X(97)" AT 1 SKIP   "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream OutStream SPACE(30) "Оперативный отчет по закончившимся наименованиям на " x-date-alone format "99/99/9999" "г."  SKIP .

  assign  v-NameString = "Выбор объекта: " .
  for each obj-list no-lock:
    Assign  v-NameString = v-NameString + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), " .
    PUT stream OutStream v-NameString format "X(100)" SKIP .
  end.
  assign  v-NameString = "Выбор товара: " .
  case x-SelectGood : /* все товары */
    when {&g-all}        then assign v-NameString = v-NameString + "по всем товарам"  .
    when {&g-grp}        then assign v-NameString = v-NameString + "по группам"  .
    when {&g-prod}       then assign v-NameString = v-NameString + "по производителям"  .
    when {&g-choice}     then assign v-NameString = v-NameString + "выборочно"  .
    when {&g-one}        then assign v-NameString = v-NameString + "выборочно"  .
    when {&g-spis}       then assign v-NameString = v-NameString + "хранимый список"  .
    when {&g-grp-prod}   then assign v-NameString = v-NameString + "по группам и по производителям"  .
  end case .
  PUT stream OutStream v-NameString format "X(100)" SKIP .

  run PutColumnTitulExcel in this-procedure .

  if NullStr = no then do:
    for each temp-DiscSales : if temp-DiscSales.day = "#" and temp-DiscSales.last-post = ? then delete temp-DiscSales . end.
  end.

  for each temp-DiscSales break by temp-DiscSales.grp-name :
    assign  num = num + 1  .
/*    if temp-DiscSales.sum-sale = 0 and temp-DiscSales.sum-cost = 0 then next.*/
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      run PutColumnTitulExcel in this-procedure .
    end.

    if first-of(temp-DiscSales.grp-name) then do:
      display stream outstream  sym1  string("Группа " + temp-DiscSales.grp-name) @ temp-DiscSales.gds-name  sym2  sym8  with frame f-doc.
      down stream outstream with frame f-doc .
      run macr_excel_char("Группа " + temp-DiscSales.grp-name ,  v-row, 3) .       assign v-row = v-row + 1 .
      assign
        v-sum-cost = 0
        v-sum-sale = 0
      .
    end.
    assign
/*      v-prc = (temp-DiscSales.sum-sale - temp-DiscSales.sum-cost) * 100 / temp-DiscSales.sum-cost*/
/*      v-sum-cost = v-sum-cost + temp-DiscSales.sum-cost*/
/*      v-sum-sale = v-sum-sale + temp-DiscSales.sum-sale*/
      v-prod = string(temp-DiscSales.prod-type + " " + string(temp-DiscSales.prod-code))
    .
/*    if v-prc = ? then v-prc = 0 .*/
    display stream outstream
      sym1  temp-DiscSales.artic
      sym2  v-prod
      sym3  temp-DiscSales.gds-name
      sym6  temp-DiscSales.day
      sym7  temp-DiscSales.last-post
      sym8
    with frame f-doc.
    down stream outstream with frame f-doc .

    assign v-col = 1 .
    run macr_excel_char( temp-DiscSales.artic     ,  v-row, v-col) .       assign v-col = v-col + 1 .
/*    put  stream macr_excel unformatted   substitute('formula("&3","r&1c&2")', v-row , v-col ,temp-DiscSales.artic ) skip  . assign v-col = v-col + 1 .*/
    run macr_excel_char( v-prod                   ,  v-row, v-col) .       assign v-col = v-col + 1 .
    run macr_excel_char( temp-DiscSales.gds-name  ,  v-row, v-col) .       assign v-col = v-col + 1 .
    run macr_excel_char ( temp-DiscSales.day      ,  v-row, v-col) .       assign v-col = v-col + 1 .
    if /*temp-DiscSales.last-post <> 0 and*/ temp-DiscSales.last-post <> ? then do:
      run macr_excel_char( string(temp-DiscSales.last-post,"99.99.9999") ,  v-row, v-col) .       assign v-col = v-col + 1 .
    end.
    assign v-row = v-row + 1 .

/*    if last-of(temp-DiscSales.grp-name) then do:*/
/*      assign v-prc = (v-sum-sale - v-sum-cost) * 100 / v-sum-cost .*/
/*      if v-prc = ? then v-prc = 0 .*/
/*      display stream outstream*/
/*        sym1  string("Итого по " + temp-DiscSales.grp-name) @ temp-DiscSales.gds-name*/
/*        sym2  v-sum-sale @ temp-DiscSales.sum-sale*/
/*        sym3  v-prc*/
/*        sym6*/
/*        sym7*/
/*        sym8*/
/*      with frame f-doc.*/
/*      down stream outstream with frame f-doc .*/
/*      run macr_excel_char("Итого по " + temp-DiscSales.grp-name ,  v-row, 3) .*/
/*      run macr_excel_sum ( v-sum-sale ,  v-row, 4,  2) .*/
/*      run macr_excel_sum ( v-prc ,  v-row, 5,  2) .*/
/*      assign v-row = v-row + 1 .*/
/*    end.*/
  End.
  PUT STREAM OutStream Line format "X(97)" skip.


  PUT STREAM OutStream
    "Итого количество наименований: " format "X(32)"  string(num,">>>>>>>9")  " штук."  skip
    "Итого процент отсутствия: " format "X(27)"  string( num * 100 / Counter1 ,">9") format "X(2)"  " %"  skip
  .
  assign
    v-col = 1
    v-row = v-row + 1
  .
  run macr_excel_char( "Итого количество наименований: " + string(num,">>>>>>>9") + " штук."   ,  v-row, v-col) .
  assign v-row = v-row + 1 .
  run macr_excel_char( "Итого процент отсутствия: " + string( num * 100 / Counter1 ,">9") + " %" ,  v-row, v-col) .       assign v-col = v-col + 1 .




  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

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
    v-ind = v-ind + 1
    v-row = 2
    v-col = 1
  .
  run macr_excel_char ("Отчет по закончившимся наименованиям на "+ string(x-date-alone,"99/99/9999") + "г.", 1, 3) .
  run macr_cell_format( 11, yes, no, ?, 1, 3, 1, 3) .
  for each obj-list no-lock:
    run macr_excel_char ( string("Выбор объекта: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), ") , v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  assign
    v-col = 1
    v-row = v-row + 1
  .
  case x-SelectGood : /* все товары */
    when {&g-all}       then run macr_excel_char ("Выбор товара: по всем товарам" , v-row, v-col) .
    when {&g-grp}       then run macr_excel_char ("Выбор товара: по группам" , v-row, v-col) .
    when {&g-prod}      then run macr_excel_char ("Выбор товара: по производителям" , v-row, v-col) .
    when {&g-choice}    then run macr_excel_char ("Выбор товара: выборочно" , v-row, v-col) .
    when {&g-one}       then run macr_excel_char ("Выбор товара: выборочно" , v-row, v-col) .
    when {&g-spis}      then run macr_excel_char ("Выбор товара: хранимый список" , v-row, v-col) .
    when {&g-grp-prod}  then run macr_excel_char ("Выбор товара: по группам и по производителям" , v-row, v-col) .
  end case .
  assign  v-row = v-row + 1 .

  run macr_excel_char("Артикул", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("Производитель", v-row, v-col) .
  run macr_cell_size (15,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("Наименование товара", v-row, v-col) .
  run macr_cell_size (40,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Дни без товара.", v-row, v-col) .
  run macr_cell_size (14,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Послед. поставка", v-row, v-col) .
  run macr_cell_size (14,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .

  run macr_cell_bordur ( v-row , 1, v-row, 5) .
  run macr_cell_format ( 10, yes, no, 35, v-row , 1, v-row, 5) .
  assign
    v-row = v-row + 1
    v-col = 1
  .

  end.
end procedure. /* PutColumnTitulExcel */