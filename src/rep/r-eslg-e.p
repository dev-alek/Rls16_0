block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-eslg-e.p $
$Archive: rep/r-eslg-e.p $

Расширеный оперативный отчет по закончившимся наименованиям

Автор: Хныкин Павел Андреевич
Дата создания: 02/16/10
Author: Pavel Khnykin
Creation date: 02/16/10


*/
define input  parameter p-NullStr               as logical   no-undo .
define input  parameter p-days-absence          as integer   no-undo .
define input  parameter p-critical-balance      as integer   no-undo .
define input  parameter p-absence-period        as logical   no-undo .
define input  parameter p-absence-period-from   as date      no-undo .
define input  parameter p-absence-period-to     as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-eslg-e.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-eslg-e.p $":U .
define variable vss-description as character no-undo init "Расширеный оперативный отчет по закончившимся наименованиям".
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
{ gbl/waitfram.i }
{ rep/prg-bar.i run }

define stream sout.
define stream macr_excel .

define temp-table tt-goods no-undo like ub.goods
  field obj-type  as character
  field obj-code  as integer
index pi is primary unique
  obj-type
  obj-code
  gds-code
index obj
  obj-type
  obj-code
index art
  artic
  prod-type
  prod-code
.

define temp-table tt-report no-undo
  field   obj-type          as character
  field   obj-code          as integer
  field   artic             as character
  field   prod-type         as character
  field   prod-code         as integer
  field   prod-name          as character
  field   gds-name          as character
  field   grp-name          as character
  field   grp-code          as integer
  field   last-income-date  as date
  field   days-absence      as character
index pi is primary unique
  obj-type
  obj-code
  artic
  prod-type
  prod-code
index art
  artic
  prod-type
  prod-code
index grp
  grp-name
  .

define buffer buf_tt-report for tt-report.

define variable v-line      as character no-undo .
define variable v-tot-goods as integer   no-undo .
define variable v-ind       as integer   no-undo .
define variable v-row       as integer   no-undo .
define variable v-col       as integer   no-undo .

define frame f-doc
    sym1  buf_tt-report.artic             column-label " Артикул!       "            format "X(12)"                space(0)
    sym2  buf_tt-report.prod-name         column-label " Произ-!водитель"            format "X(8)"                 space(0)
    sym3  buf_tt-report.gds-name          column-label " Наименование товара! "      format "X(50)"                space(0)
    sym6  buf_tt-report.days-absence      column-label "Дни без!товара"              format "X(8)"                 space(0)
    sym7  buf_tt-report.last-income-date  column-label "Послед.!постав"              format "99/99/99"             space(0)
    sym8
header
    string( "Дата печати : " + string(today , "99.99.9999") + " , " + string(time, "HH:MM") ) at 5 format "X(60)"
    string( "Страница " + string( page-number( sout )  , ">>9") ) at 70 format "X(15)" skip
    v-line format "X(97)" AT 1
with width {&A4_CW} down stream-io.


do
on error undo, return error return-value
:
  if p-days-absence < 0
  then do:
    message
      "Количество дней отсутствия товара не может быть отрицательным!"
    view-as alert-box error.
    return. /* --->>>--- */
  end.
  if p-critical-balance < 0
  then do:
    message
      "Критический остаток товара не может быть отрицательным!"
    view-as alert-box error.
    return. /* --->>>--- */
  end.
  if  p-absence-period = yes and
      p-absence-period-from > p-absence-period-to
  then do:
    message
      "Период отсутствия продаж задан некорректно!"
    view-as alert-box error.
    return. /* --->>>--- */
  end.

  run proc-empty-tt in this-procedure .
  run fill-tt-gds in this-procedure no-error .
  if error-status :error = yes
  then do:
    return . /* --->>>--- */
  end.

  run fill-report in this-procedure no-error .
  if error-status :error = yes
  then do:
    return . /* --->>>--- */
  end.

  run print-report  in this-procedure no-error .
  if error-status :error = yes
  then do:
    return . /* --->>>--- */
  end.

  run proc-empty-tt in this-procedure .

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .

  run gbl/prnfilen.w ( input ""
                     , input 0
                     , input string(session :temp-directory) + {&DF_Name} + string( g#report-num )
                     , input 7
                     , output v-user-action
                     , output v-printed
                     ) .

end.


procedure proc-empty-tt :

do
on error undo, return error return-value
:
  empty temp-table tt-goods.
  empty temp-table tt-report.
end.

end procedure. /* proc-empty-tt */


procedure fill-tt-gds :

  define buffer buf_goods                   for ub.goods.
  define buffer buf_assortment-matrix       for ub.assortment-matrix.
  define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods.

  define buffer buf_tt-goods    for tt-goods.

  define variable v-curr-grp-name               as character no-undo .
  define variable v-return-AssMin               as logical   no-undo .
  define variable v-return-igt                  as character no-undo .
  define variable v-gdop-min-stock              as decimal   no-undo .
  define variable v-grop-max-stock              as decimal   no-undo .
  define variable v-grop-level-always-presence  as decimal   no-undo .
  define variable v-grop-min-order              as decimal   no-undo .
  define variable v-obj-type                    as character no-undo .
  define variable v-obj-code                    as integer   no-undo .

do
on error undo, return error return-value
:
  empty temp-table buf_tt-goods.

  assign
    v-tot-goods = 0
  .
  for each obj-list
  :
    run waitfram-show in this-procedure ( input substitute( "Построение списка товаров по объекту &1 &2"
                                                          , obj-list.obj-type
                                                          , obj-list.obj-code
                                                          )
                                        ) .
    find first buf_assortment-matrix no-lock
      where buf_assortment-matrix.obj-type    = obj-list.obj-type
        and buf_assortment-matrix.obj-code    = obj-list.obj-code
        and buf_assortment-matrix.asmt-status = integer ({&current-status-int})
    no-error .
    if available buf_assortment-matrix
    then do:
      for each buf_assortment-matrix-goods no-lock
        where buf_assortment-matrix-goods.asmt-id     = buf_assortment-matrix.asmt-id
          and buf_assortment-matrix-goods.db-num      = buf_assortment-matrix.db-num
          and buf_assortment-matrix-goods.asmg-status = integer ({&current-status-int})
      :
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_assortment-matrix-goods.gds-code
        no-error .
        if available buf_goods
        then do:
          find first buf_tt-goods
            where buf_tt-goods.obj-type = obj-list.obj-type
              and buf_tt-goods.obj-code = obj-list.obj-code
              and buf_tt-goods.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_tt-goods
          then do:
            create buf_tt-goods.
            buffer-copy buf_goods to buf_tt-goods
            assign
              buf_tt-goods.obj-type = obj-list.obj-type
              buf_tt-goods.obj-code = obj-list.obj-code
              v-tot-goods           = v-tot-goods + 1
            .

          end.
        end. /* if available buf_goods */
      end. /* for each buf_assortment-matrix-goods no-lock  */
    end. /* if available buf_assortment-matrix */
    else do:
      message
        substitute( "Для объекта &1 &2 не найдена ассортиментная матрица!&3Невозможно составить отчет."
                  , obj-list.obj-type
                  , obj-list.obj-code
                  , {&new-line}
                  )
      view-as alert-box error.
      return error . /* --->>>--- */
    end.
  end. /* for each obj-list  */

  run waitfram-hide in this-procedure .

  /* фильтруем по ИЖТ */
  for each buf_tt-goods
  :
    { gbl/gdsobjpr.i
    buf_tt-goods.obj-type
    buf_tt-goods.obj-code
    ?
    ?
    ?
    buf_tt-goods.gds-code
    v-return-AssMin
    v-return-igt
    v-gdop-min-stock
    v-grop-max-stock
    v-grop-level-always-presence
    v-grop-min-order
    }
    if  v-return-igt = {&ass-izd-spec} or
        v-return-igt = {&ass-izd-del}
    then do:
      delete buf_tt-goods.
    end.
  end. /* for each buf_tt-goods */

  run waitfram-hide in this-procedure .
end.

end procedure. /* fill-tt-gds */



procedure fill-report :

  define buffer buf_gds-obj   for ub.gds-obj.
  define buffer buf_stk-line  for ub.stk-line.
  define buffer buf_ot-line   for ub.ot-line.
  define buffer buf_doc-line  for ub.doc-line.
  define buffer buf_trn-doc   for ub.trn-doc.

  define buffer buf_tt-goods  for tt-goods.
  define buffer buf_tt-report for tt-report.

  define variable v-fact-order        as decimal   no-undo .
  define variable v-i                 as integer   no-undo .
  define variable v-ext-doc-type      as character no-undo .
  define variable v-last-income-date  as date      no-undo .
  define variable v-fo                as decimal   no-undo .
  define variable v-stat              as logical   no-undo .
  define variable v-days-absence-str  as character no-undo .
  define variable v-days-absence      as integer   no-undo .
  define variable v-absence-fo-from   as decimal   no-undo .
  define variable v-absence-fo-to     as decimal   no-undo .

do
on error undo, return error return-value
:
  /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input x-date-alone
                                             , output v-fact-order
                                             ).
  if p-absence-period = yes
  then do:
    run day-begin-fact-order in this-procedure ( input p-absence-period-from
                                               , output v-absence-fo-from
                                               ).
    run factord-end-day in this-procedure ( input p-absence-period-from
                                          , output v-absence-fo-to
                                          ).
  end.

  run prg-bar_init-cb-handle in this-procedure (v-d-report-handle) .
  run prg-bar_new in this-procedure (1 , v-tot-goods).
  run prg-bar_title in this-procedure ( input "Обработка товаров...":U ).
  run prg-bar_show in this-procedure .
  assign
    v-tot-goods = 0
  .
  _goods-cycle:
  for each buf_tt-goods
  :
    run prg-bar_increment in this-procedure .
    find first buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = buf_tt-goods.obj-type
        and buf_gds-obj.obj-code  = buf_tt-goods.obj-code
        and buf_gds-obj.artic     = buf_tt-goods.artic
        and buf_gds-obj.prod-type = buf_tt-goods.prod-type
        and buf_gds-obj.prod-code = buf_tt-goods.prod-code
    no-error .
    if not available buf_gds-obj
    then do:
      next _goods-cycle.
    end.
    if buf_gds-obj.last-doc = ?
    then do:
      next _goods-cycle.
    end.
    assign
      v-tot-goods = v-tot-goods + 1
    .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type    = buf_tt-goods.obj-type
        and buf_stk-line.obj-code    = buf_tt-goods.obj-code
        and buf_stk-line.artic       = buf_tt-goods.artic
        and buf_stk-line.prod-type   = buf_tt-goods.prod-type
        and buf_stk-line.prod-code   = buf_tt-goods.prod-code
        and buf_stk-line.sum-type    = {&arh-crsa}
        and buf_stk-line.cat-id      = {&root-cat-id}
        and buf_stk-line.fact-order <= v-fact-order
    use-index category no-error .

    /* фильтруем по количеству */
    if available buf_stk-line and buf_stk-line.fact-qnty <= p-critical-balance
    then do:
      /* ищем дни отсутствия товара */
      assign
        v-stat             = no
        v-fo               = v-fact-order
        v-days-absence-str = ""
      .
      do while v-stat = no
      :
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type   = buf_tt-goods.obj-type
            and buf_stk-line.obj-code   = buf_tt-goods.obj-code
            and buf_stk-line.artic      = buf_tt-goods.artic
            and buf_stk-line.prod-type  = buf_tt-goods.prod-type
            and buf_stk-line.prod-code  = buf_tt-goods.prod-code
            and buf_stk-line.sum-type   = {&arh-crsa}
            and buf_stk-line.cat-id     = {&root-cat-id}
            and buf_stk-line.fact-order < v-fo
        use-index category no-error .
        if not available buf_stk-line
        then do:
          assign
            v-stat = yes
          .
        end.
        else do:
          assign
            v-fo = buf_stk-line.fact-order
          .
          if buf_stk-line.fact-qnty > p-critical-balance
          then do:
            assign
              v-days-absence-str  = string(x-date-alone - buf_stk-line.fact-date)
              v-stat              = yes
            .
          end.
        end.
      end. /* do while v-stat = no */

      if v-days-absence-str <> ""
      then do:
        assign
          v-days-absence = integer(v-days-absence-str)
        no-error .
        /* количество дней отсутствия меньше заданного */
        if v-days-absence < p-days-absence
        then do:
          next _goods-cycle.
        end. /* if v-days-abscense < p-days-abscense */
      end.

      if p-absence-period = yes
      then do:
        /* ищем продажи за период */
        find last buf_ot-line no-lock
          where buf_ot-line.obj-type     = buf_tt-goods.obj-type
            and buf_ot-line.obj-code     = buf_tt-goods.obj-code
            and buf_ot-line.artic        = buf_tt-goods.artic
            and buf_ot-line.prod-type    = buf_tt-goods.prod-type
            and buf_ot-line.prod-code    = buf_tt-goods.prod-code
            and buf_ot-line.fact-order  >= v-absence-fo-from
            and buf_ot-line.fact-order  <= v-absence-fo-to
            and buf_ot-line.sum-type     = {&arh-crsa}
            and buf_ot-line.cat-id       = {&root-cat-id}
            and buf_ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
        no-error .
        if available buf_ot-line
        then do:
          next _goods-cycle.
        end.
      end. /* if p-absence-period = yes */

      /* последний приход */
      assign
        v-fo                = 0
        v-last-income-date  = ?
      .
      do v-i = 1 to 6
      :
        case v-i
        :
          when 1
          then do:
            assign
              v-ext-doc-type = {&TDEDT_Pri_Vnesh}
            .
          end.
          when 2
          then do:
            assign
              v-ext-doc-type = {&TDEDT_Pri_Perem}
            .
          end.
          when 3
          then do:
            assign
              v-ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
            .
          end.
          when 4
          then do:
            assign
              v-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
            .
          end.
          when 5
          then do:
            assign
              v-ext-doc-type = {&TDEDT_Pri_Prvo}
            .
          end.
          when 6
          then do:
            assign
              v-ext-doc-type = {&TDEDT_Vozvrat_Perem}
            .

          end.
        end.
        find last buf_doc-line no-lock
          where buf_doc-line.obj-type     = buf_tt-goods.obj-type
            and buf_doc-line.obj-code     = buf_tt-goods.obj-code
            and buf_doc-line.artic        = buf_tt-goods.artic
            and buf_doc-line.prod-type    = buf_tt-goods.prod-type
            and buf_doc-line.prod-code    = buf_tt-goods.prod-code
            and buf_doc-line.ext-doc-type = v-ext-doc-type
            and buf_doc-line.status_      = {&fact}
            and buf_doc-line.fact-order  <= v-fact-order
        no-error .
        if available buf_doc-line
        then do:
          if buf_doc-line.fact-order > v-fo
          then do:
            assign
              v-fo = buf_doc-line.fact-order
            .
            find first buf_trn-doc no-lock
              where buf_trn-doc.doc-code = buf_doc-line.doc-code
            no-error .
            if not available buf_trn-doc
            then do:
              run factord-to-date in this-procedure ( input v-fo
                                                    , output v-last-income-date
                                                    ) .
            end.
            else do:
              assign
                v-last-income-date = buf_trn-doc.fact-date
              .
            end.
          end.
        end. /* if available buf_doc-line  */
      end. /* do v-i = 1 to 6 : */

      find first buf_tt-report
        where buf_tt-report.obj-type  = buf_tt-goods.obj-type
          and buf_tt-report.obj-code  = buf_tt-goods.obj-code
          and buf_tt-report.artic     = buf_tt-goods.artic
          and buf_tt-report.prod-type = buf_tt-goods.prod-type
          and buf_tt-report.prod-code = buf_tt-goods.prod-code
      no-error .
      if not available buf_tt-report
      then do:
        create buf_tt-report.
        assign
          buf_tt-report.obj-type  = buf_tt-goods.obj-type
          buf_tt-report.obj-code  = buf_tt-goods.obj-code
          buf_tt-report.artic     = buf_tt-goods.artic
          buf_tt-report.prod-type = buf_tt-goods.prod-type
          buf_tt-report.prod-code = buf_tt-goods.prod-code
          buf_tt-report.prod-name = substitute("&1 &2" , buf_tt-goods.prod-type , buf_tt-goods.prod-code )
          buf_tt-report.grp-name  = trim(buf_tt-goods.grp-name)
          buf_tt-report.grp-code  = buf_tt-goods.grp-code
        .
        if g#gds-engl
        then do:
          assign
            buf_tt-report.gds-name = buf_tt-goods.engl-name
          .
        end.
        else do:
          assign
            buf_tt-report.gds-name = buf_tt-goods.gds-name
          .
        end.
      end. /* if not available buf_tt-report */
      assign
        buf_tt-report.last-income-date  = v-last-income-date
        buf_tt-report.days-absence      = if v-days-absence-str = "" or v-days-absence-str = ? then "#" else v-days-absence-str
      .
    end. /* if available buf_stk-line and buf_stk-line.fact-qnty = 0  */
  end. /* for each buf_tt-goods, */
  run prg-bar_delete in this-procedure .

  if p-NullStr = no
  then do:
    for each buf_tt-report
    :
      if buf_tt-report.day = "#" and buf_tt-report.last-income-date = ?
      then do:
        delete buf_tt-report .
      end.
    end.
  end. /* if p-NullStr = no  */

end.

end procedure. /* fill-report */


procedure print-report :

  define variable v-obj-str     as character no-undo .
  define variable v-goods-count as integer   no-undo .
  define variable v-file-name   as character no-undo .

do
on error undo, return error return-value
:
  assign
    make-excel  = yes
    v-line      = fill("-", 250)
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  { cmp/open-out.i stream sout " " {&CS_PS} }

  form header
      v-line format "X(97)" at 1 skip   "Продолжение - на следующей странице" at 30 skip
      with frame BottomFrame width {&A4_CW} page-bottom no-labels no-box .
  view stream sout frame BottomFrame .

  form with frame f-doc .

  put stream sout space(30) "Расширеный оперативный отчет по закончившимся наименованиям на " x-date-alone format "99/99/9999" "г."  skip .

  assign
    v-obj-str = "Выбор объекта: "
  .
  for each obj-list
  :
    assign
      v-obj-str = v-obj-str + substitute("&1 (&2#&3 ), "
                                        , obj-list.obj-name
                                        , obj-list.obj-type
                                        , obj-list.obj-code
                                        )
    .
  end.
  put stream sout v-obj-str format "X(160)" skip .

  if p-NullStr = yes
  then do:
    put stream sout "Показывать непроходившие товары" skip.
  end.
  else do:
    put stream sout "Не показывать непроходившие товары" skip.
  end.
  put stream sout "Количество дней отсутствия товара: " p-days-absence format ">>9" skip.
  put stream sout "Критический остаток товара: " p-critical-balance format ">>>>>>9" skip.
  if p-absence-period = yes
  then do:
    put stream sout "Отсутствуют продажи за период с " p-absence-period-from format "99/99/9999" " по " p-absence-period-to "99/99/9999" skip.
  end.
  put stream sout skip.

  run print-titul-excel in this-procedure .

  for each buf_tt-report
  break by buf_tt-report.grp-name
  :
    assign
      v-goods-count = v-goods-count + 1
    .
    if v-row  >= 63000
    then do:
      output stream macr_excel close .
      run paramls-write in this-procedure ( input "file" , input string(v-ind) , input v-file-name ) .
      run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name ) .
      output stream macr_excel to value(v-file-name) .
      run print-titul-excel in this-procedure .
    end.

    if first-of(buf_tt-report.grp-name)
    then do:
      display stream sout
        sym1
        string("Группа " + buf_tt-report.grp-name) @ buf_tt-report.gds-name
        sym2
        sym8
      with frame f-doc.
      down stream sout with frame f-doc .
      run macr_excel_char in this-procedure ( "Группа " + buf_tt-report.grp-name , v-row, 3) .
      assign
        v-row = v-row + 1
      .
    end.

    display stream sout
      sym1  buf_tt-report.artic
      sym2  buf_tt-report.prod-name
      sym3  buf_tt-report.gds-name
      sym6  buf_tt-report.days-absence
      sym7  buf_tt-report.last-income-date
      sym8
    with frame f-doc.
    down stream sout with frame f-doc .
    assign v-col = 1 .
    run macr_excel_char in this-procedure ( buf_tt-report.artic        , v-row, v-col) . assign v-col = v-col + 1 .
    run macr_excel_char in this-procedure ( buf_tt-report.prod-name    , v-row, v-col) . assign v-col = v-col + 1 .
    run macr_excel_char in this-procedure ( buf_tt-report.gds-name     , v-row, v-col) . assign v-col = v-col + 1 .
    run macr_excel_char in this-procedure ( buf_tt-report.days-absence , v-row, v-col) . assign v-col = v-col + 1 .
    if buf_tt-report.last-income-date <> ?
    then do:
      run macr_excel_char( string(buf_tt-report.last-income-date,"99.99.9999") , v-row, v-col) . assign v-col = v-col + 1 .
    end.
    assign v-row = v-row + 1 .
  end.
  put stream sout v-line format "X(97)" skip.
  put stream sout
    "Итого количество наименований: " format "X(32)"  string(v-goods-count,">>>>>>>9")  " штук."  skip
    "Итого процент отсутствия: " format "X(27)"  string( v-goods-count * 100 / v-tot-goods ,">>9") format "X(2)"  " %"  skip
  .
  assign v-row = v-row + 1 .
  if v-row + 3 >= 63000
  then do:
    output stream macr_excel close .
    run paramls-write in this-procedure ( input "file" , input string(v-ind) , input v-file-name ) .
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name ) .
    output stream macr_excel to value(v-file-name) .
    run print-titul-excel in this-procedure .
  end.

  assign
    v-col = 1
  .
  run macr_excel_char( "Итого количество наименований: " + string(v-goods-count,">>>>>>>9") + " штук."   ,  v-row, v-col) .
  assign v-row = v-row + 1 .
  run macr_excel_char( "Итого процент отсутствия: " + string( v-goods-count * 100 / v-tot-goods ,">>9") + " %" ,  v-row, v-col) .

  hide stream sout frame BottomFrame .
  output stream sout close.
  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

end.
end procedure. /* print-report */


/* заголовки для колонок экселя */
procedure print-titul-excel :
  define variable v-str as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-ind = v-ind + 1
    v-row = 2
    v-col = 1
  .
  run macr_excel_char ("Расширеный оперативный отчет по закончившимся наименованиям на "+ string(x-date-alone,"99/99/9999") + "г.", 1, 3) .
  run macr_cell_format( 11, yes, no, ?, 1, 3, 1, 3) .
  for each obj-list no-lock:
    run macr_excel_char ( string("Выбор объекта: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), ") , v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  assign
    v-col = 1
    v-row = v-row + 1
  .

  if p-NullStr = yes
  then do:
    assign
      v-str = "Показывать непроходившие товары"
    .
  end.
  else do:
    assign
      v-str = "Не показывать непроходившие товары"
    .
  end.
  run macr_excel_char ( v-str , v-row, v-col) .
  assign
    v-col = 1
    v-row = v-row + 1
  .
  run macr_excel_char ( substitute("Количество дней отсутствия товара: &1" , p-days-absence) , v-row, v-col) .
  assign
    v-col = 1
    v-row = v-row + 1
  .
  run macr_excel_char ( substitute("Критический остаток товара: &1" , p-critical-balance) , v-row, v-col) .
  assign
    v-col = 1
    v-row = v-row + 1
  .
  if p-absence-period = yes
  then do:
    assign
      v-str = substitute("Отсутствуют продажи за период с &1 по &2"
                        , p-absence-period-from
                        , p-absence-period-to
                        )
    .
    run macr_excel_char ( substitute("Критический остаток товара: &1" , p-critical-balance) , v-row, v-col) .
    assign
      v-col = 1
      v-row = v-row + 1
    .
  end.
  assign
    v-row = v-row + 1
  .

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
end procedure. /* print-titul-excel */