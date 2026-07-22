block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-hold2.p $
$Archive: rep/r-hold2.p $

Отчет по межфирменным операциям - динамика закупки

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define input parameter x-date      as integer   no-undo .
define input parameter p_provid    as integer   no-undo .
define input parameter p_cli-list  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-hold2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-hold2.p $":U .
define variable vss-description as character no-undo init "Отчет по межфирменным операциям - динамика закупки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/r-sym.i    }
{ ref/grplib.i   }
{ cmp/r-pril.i   }
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i  }

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

  define buffer buf_goods                for goods.
  define buffer buf_hold-time            for hold-time.
  define buffer buf_hold-purch           for hold-purch.
  define buffer buf_clients              for clients.
  define buffer buf_hold-purch-supp-gds  for hold-purch-supp-gds.

  DEFINE temp-table temp-hold2 no-undo
    field   artic            as char
    field   prod-code        as integer
    field   prod-type        as char
    field   gds-name         as char
    field   gds-unit         as char
    field   gds-code         as integer
    field   grp-name         as char
    field   qnty             as decimal EXTENT 12
    field   sum-prod         as decimal
    INDEX pi  IS PRIMARY     gds-code
    INDEX pi2                grp-name
  .

  define variable  date-start  as date  EXTENT 12   no-undo .
  define variable  date-end    as date  EXTENT 12   no-undo .
  define variable  Counter1    as integer   no-undo .
  define variable  ii          as integer no-undo .
  define variable  jj          as integer no-undo .
  define variable  Line        as character no-undo .
  define variable  Line1       as character no-undo .
  define variable  grp-value   as decimal  EXTENT 14       no-undo.
  define variable  all-value   as decimal  EXTENT 14       no-undo.

  define variable  v-prod                as char                     no-undo.
  define variable  v-goods-name          as char                     no-undo.
  define variable  v-goods-unit          as char                     no-undo.
  define variable  v-value               as decimal  EXTENT 12       no-undo.
  define variable  v-sum-value           as decimal                  no-undo.
  define variable  v-sum                 as decimal                  no-undo.

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  /* заполняем табл. с месяцами или неделями */
  assign  ii = 1 .
  do ii = 1 to 12 :
    assign  date-start [ii] = date(ii,1,x-date) .
    if ii < 12 then assign date-end [ii] = date( ii + 1, 1, x-date) - 1 .
    else            assign date-end [ii] = date( 1, 1, x-date + 1) - 1 .
  end.

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */


  for each temp-hold2 : delete temp-hold2 . end.

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .
  define variable is-find     as logical   no-undo .

  for each buf_hold-time where buf_hold-time.cat-code = {&hold-main-cat-code}  no-lock  :
    if buf_hold-time.start-date < date-start[1] or buf_hold-time.end-date > date-end[12] then next .
    if p_provid = 1 then do: /* все поставщики */
      for each buf_hold-purch no-lock
        where buf_hold-purch.time-code = buf_hold-time.time-code
          and buf_hold-purch.cat-code  = buf_hold-time.cat-code
        :
        assign Counter1 = Counter1 + 1.

        { rep/repfrm.i disp Counter1 }

        find first buf_goods no-lock where buf_goods.gds-code = buf_hold-purch.gds-code  no-error .

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

        find first temp-hold2 where temp-hold2.gds-code = buf_hold-purch.gds-code no-error .

        if not available temp-hold2 then do:
          create temp-hold2 .

          run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-hold2.grp-name) .
          if g#gds-engl then assign temp-hold2.gds-name = buf_goods.engl-name.
          else               assign temp-hold2.gds-name = buf_goods.gds-name.

          assign
            temp-hold2.artic     = buf_goods.artic
            temp-hold2.prod-type = buf_goods.prod-type
            temp-hold2.prod-code = buf_goods.prod-code
            temp-hold2.gds-unit = buf_goods.unit-base
            temp-hold2.gds-code = buf_goods.gds-code
            temp-hold2.sum-prod = 0
          .
          do ii = 1 to 12 : assign temp-hold2.qnty [ii] = 0 . end.
        end.
        do ii = 1 to 12 :
          if buf_hold-time.start-date >= date-start [ii] and buf_hold-time.end-date <= date-end [ii] then do:
            assign temp-hold2.qnty [ii] = temp-hold2.qnty [ii] + buf_hold-purch.fact-qnty .
            leave.
          end.
        end.
        if x-SET_val_TYPE = 1 then do:
          assign
            temp-hold2.sum-prod  = temp-hold2.sum-prod + buf_hold-purch.purch-sum-rubl
          .
        end.
        else do:
          assign
            temp-hold2.sum-prod  = temp-hold2.sum-prod + buf_hold-purch.purch-sum-base
          .
        end.
      end.
    end.
    else do: /* выбран список поставщиков */
      DO jj = 1 TO num-entries( p_cli-list ) :
        find first buf_clients where recid(buf_clients) = integer(entry(jj, p_cli-list)) no-error.
        if not avail buf_clients then next .
        for each buf_hold-purch-supp-gds no-lock
          where buf_hold-purch-supp-gds.time-code = buf_hold-time.time-code
            and buf_hold-purch-supp-gds.cat-code  = buf_hold-time.cat-code
            and buf_hold-purch-supp-gds.cli-code  = buf_clients.obj-code
            and buf_hold-purch-supp-gds.cli-type  = buf_clients.obj-type
          :
          assign Counter1 = Counter1 + 1.
          { rep/repfrm.i disp Counter1 }

          find first buf_goods no-lock where buf_goods.gds-code = buf_hold-purch-supp-gds.gds-code no-error .

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

          find first temp-hold2 where temp-hold2.gds-code = buf_hold-purch-supp-gds.gds-code  no-error .

          if not available temp-hold2 then do:
            create temp-hold2 .

            run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-hold2.grp-name) .
            if g#gds-engl then assign temp-hold2.gds-name = buf_goods.engl-name.
            else               assign temp-hold2.gds-name = buf_goods.gds-name.

            assign
              temp-hold2.artic     = buf_goods.artic
              temp-hold2.prod-type = buf_goods.prod-type
              temp-hold2.prod-code = buf_goods.prod-code
              temp-hold2.gds-unit = buf_goods.unit-base
              temp-hold2.gds-code = buf_goods.gds-code
              temp-hold2.sum-prod = 0
            .
            do ii = 1 to 12 : assign temp-hold2.qnty [ii] = 0 . end.
          end.
          do ii = 1 to 12 :
            if buf_hold-time.start-date >= date-start [ii] and buf_hold-time.end-date <= date-end [ii] then do:
              assign temp-hold2.qnty [ii] = temp-hold2.qnty [ii] + buf_hold-purch-supp-gds.fact-qnty .
              leave.
            end.
          end.
          if x-SET_val_TYPE = 1 then do:
            assign
              temp-hold2.sum-prod  = temp-hold2.sum-prod + buf_hold-purch-supp-gds.purch-sum-rubl
            .
          end.
          else do:
            assign
              temp-hold2.sum-prod  = temp-hold2.sum-prod + buf_hold-purch-supp-gds.purch-sum-base
            .
          end.
        end.
      end.
    end.
  end.

  { gbl/working.i }

  Line = fill("-", 280).

  DEFINE frame f-doc
        sym19  temp-hold2.artic  column-label " Артикул! " format "X(12)"         space(0)
        sym20  v-prod        column-label " Произ-! водитель" format "X(12)"         space(0)
        sym1  v-goods-name   column-label " Наименование товара! " format "X(40)"          space(0)
        sym2  v-goods-unit   column-label "Ед.!изм"                format "X(3)"           space(0)
        sym3  v-value[1]     column-label "Январь  ! "             format "->>>>>9.999"    space(0)
        sym4  v-value[2]     column-label "Февраль ! "             format "->>>>>9.999"    space(0)
        sym5  v-value[3]     column-label "Март    ! "             format "->>>>>9.999"    space(0)
        sym6  v-value[4]     column-label "Апрель  ! "             format "->>>>>9.999"    space(0)
        sym7  v-value[5]     column-label "Май     ! "             format "->>>>>9.999"    space(0)
        sym8  v-value[6]     column-label "Июнь    ! "             format "->>>>>9.999"    space(0)
        sym9  v-value[7]     column-label "Июль    ! "             format "->>>>>9.999"    space(0)
        sym10 v-value[8]     column-label "Август  ! "             format "->>>>>9.999"    space(0)
        sym11 v-value[9]     column-label "Сентябрь! "             format "->>>>>9.999"    space(0)
        sym12 v-value[10]    column-label "Октябрь ! "             format "->>>>>9.999"    space(0)
        sym13 v-value[11]    column-label "Ноябрь  ! "             format "->>>>>9.999"    space(0)
        sym14 v-value[12]    column-label "Декабрь ! "             format "->>>>>9.999"    space(0)
        sym15 v-sum-value    column-label "ИТОГО   ! "             format "->>>>>9.999"    space(0)
        sym16 v-sum          column-label "Сумма   ! "             format "->>>>>>>>>9.99"  space(0)
        sym17
  HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(100)"
        string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 170 format "X(15)" SKIP
        Line format "X(261)" AT 1
  with width 270 down stream-io.

  { cmp/open-out.i stream OutStream " " {&LS_PS_A4} }

  FORM HEADER
      Line format "X(261)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width 270 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream OutStream  SPACE(30) ReportNAme format "X(100)"  SKIP .
  PUT stream OutStream  ReportHeader format "X(200)" SKIP .

  run PutColumnTitulExcel in this-procedure .

  do ii = 1 to 14:
    assign all-value [ii] = 0 .
  end.

  for each temp-hold2 no-lock
    break by temp-hold2.grp-name
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

    if first-of(temp-hold2.grp-name) then do:
      run StartGroup in this-procedure .
    end.

    run PrintLine in this-procedure .

    if last-of(temp-hold2.grp-name) then do:
      run EndGroup in this-procedure .
    end.
  end. /* for each temp-hold2  */

  run PrintItog in this-procedure .

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  { gbl/stopwork.i }

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  run gbl/prnfilen.w
    (input  ""
    ,input  1
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

  run macr_excel_char("Артикул", 3, 1) .
  run macr_excel_char("Производитель", 3, 2) .
  run macr_excel_char("Наименование товара", 3, 3) .
  run macr_cell_size (40,?, 3, 3,?,?).
  run macr_excel_char("Ед. изм", 3, 4) .
  run macr_cell_size (4,?, 3, 4,?,?).
  run macr_excel_char("Январь", 3, 5) .
  run macr_excel_char("Февраль", 3, 6) .
  run macr_excel_char("Март   ", 3, 7) .
  run macr_excel_char("Апрель ", 3, 8) .
  run macr_excel_char("Май    ", 3, 9) .
  run macr_excel_char("Июнь   ", 3,10) .
  run macr_excel_char("Июль   ", 3,11) .
  run macr_excel_char("Август ", 3, 12) .
  run macr_excel_char("Сентябр", 3, 13) .
  run macr_excel_char("Октябрь", 3, 14) .
  run macr_excel_char("Ноябрь ", 3, 15) .
  run macr_excel_char("Декабрь", 3, 16) .
  run macr_excel_char("ИТОГО  ", 3, 17) .
  run macr_excel_char("Сумма  ", 3, 18) .

  run macr_cell_bordur ( 3, 1, 3, 18) .
  run macr_cell_format ( 10, yes, no, 35, 3, 1, 3, 18) .
  run macr_cell_size (12,?, 3, 3, 3, 18) .

  end.
end procedure. /* PutColumnTitulExcel */



procedure StartGroup :
  do
  on error undo, return error return-value
  :
      do ii = 1 to 14:
        assign  grp-value [ii] = 0  .
      end.
      assign v-goods-name = temp-hold2.grp-name .
      display stream outstream  sym1 v-goods-name sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17  sym19  sym20 with frame f-doc.
      down stream outstream with frame f-doc .

      run macr_excel_char(temp-hold2.grp-name, v-row, 3) .
      assign v-row = v-row + 1 .

  end.
end procedure. /* StartGroup */



procedure EndGroup :
  do
  on error undo, return error return-value
  :
      do ii = 1 to 14:
        assign all-value [ii] = all-value [ii] + grp-value [ii] .
      end.
      assign
        v-goods-name = "Итого по группе: " + temp-hold2.grp-name
        v-sum-value  = grp-value[13]
        v-sum        = grp-value[14]
      .
      do ii = 1 to 12:
        assign v-value[ii]   = grp-value[ii] .
      end.
      display stream outstream  sym1    v-goods-name
                                sym2
                                sym3    v-value[1]
                                sym4    v-value[2]
                                sym5    v-value[3]
                                sym6    v-value[4]
                                sym7    v-value[5]
                                sym8    v-value[6]
                                sym9    v-value[7]
                                sym10   v-value[8]
                                sym11   v-value[9]
                                sym12   v-value[10]
                                sym13   v-value[11]
                                sym14   v-value[12]
                                sym15   v-sum-value
                                sym16   v-sum
                                sym17  sym19  sym20
      with frame f-doc.
      down stream outstream with frame f-doc .

      run macr_excel_char(v-goods-name, v-row, 3) .
      do ii = 1 to 13:
        run macr_excel_sum  ( grp-value[ii] , v-row, 4 + ii, 3) .
      end.
      run macr_excel_sum  ( v-sum  , v-row, 18, 2) .
      assign v-row = v-row + 1 .
  end.
end procedure. /* EndGroup */



procedure PrintLine :
  do
  on error undo, return error return-value
  :
    assign v-sum-value  = 0 .
    do ii = 1 to 12:
      assign
        grp-value[ii] = grp-value[ii] + temp-hold2.qnty[ii]
        v-value[ii]   = temp-hold2.qnty[ii]
        v-sum-value   = v-sum-value + temp-hold2.qnty[ii]
      .
    end.
    assign
      v-prod = temp-hold2.prod-type + " " + string(temp-hold2.prod-code)
      v-goods-name = temp-hold2.gds-name
      v-goods-unit = temp-hold2.gds-unit
      v-sum        = temp-hold2.sum-prod
      grp-value[13] = grp-value[13] + v-sum-value
      grp-value[14] = grp-value[14] + v-sum
    .

    display stream outstream  sym1    v-goods-name  temp-hold2.artic   v-prod
                              sym2    v-goods-unit
                              sym3    v-value[1]
                              sym4    v-value[2]
                              sym5    v-value[3]
                              sym6    v-value[4]
                              sym7    v-value[5]
                              sym8    v-value[6]
                              sym9    v-value[7]
                              sym10   v-value[8]
                              sym11   v-value[9]
                              sym12   v-value[10]
                              sym13   v-value[11]
                              sym14   v-value[12]
                              sym15   v-sum-value
                              sym16   v-sum
                              sym17  sym19  sym20
       with frame f-doc.
    down stream outstream with frame f-doc .

      run macr_excel_char(temp-hold2.artic, v-row, 1) .
      run macr_excel_char(v-prod, v-row, 2) .
      run macr_excel_char(v-goods-name, v-row, 3) .
      run macr_excel_char(v-goods-unit, v-row, 4) .
      do ii = 1 to 12:
        run macr_excel_sum  ( v-value[ii] , v-row, 4 + ii, 3) .
      end.
      run macr_excel_sum  ( v-sum-value  , v-row, 17, 3) .
      run macr_excel_sum  ( v-sum  , v-row, 18, 2) .
      assign v-row = v-row + 1 .

  end.
end procedure. /* PrintLine */



procedure PrintItog :
  do
  on error undo, return error return-value
  :
  assign
    v-goods-name = "ИТОГО:"
    v-sum-value  = all-value[13]
    v-sum        = all-value[14]
  .
  do ii = 1 to 12:
    assign v-value[ii]   = all-value[ii] .
  end.
  display stream outstream  sym1    v-goods-name
                            sym2
                            sym3    v-value[1]
                            sym4    v-value[2]
                            sym5    v-value[3]
                            sym6    v-value[4]
                            sym7    v-value[5]
                            sym8    v-value[6]
                            sym9    v-value[7]
                            sym10   v-value[8]
                            sym11   v-value[9]
                            sym12   v-value[10]
                            sym13   v-value[11]
                            sym14   v-value[12]
                            sym15   v-sum-value
                            sym16   v-sum
                            sym17   sym19  sym20
  with frame f-doc.
  down stream outstream with frame f-doc .

  PUT STREAM OutStream Line format "X(261)".

      run macr_excel_char(v-goods-name, v-row, 3) .
      do ii = 1 to 13:
        run macr_excel_sum  ( all-value[ii] , v-row, 4 + ii, 3) .
      end.
      run macr_excel_sum  ( v-sum  , v-row, 18, 2) .
      assign v-row = v-row + 1 .

  end.
end procedure. /* PrintLine */