block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-mar1.p $
$Archive: cus/r-mar1.p $

Дни продажи товара - отчет для Марии:сбор данных и печать

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/14/04
Author: Bakhtadze Natalya
Creation date: 04/14/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-start-date as date no-undo .
define input parameter p-end-date as date no-undo .
define input parameter p-select-good as integer no-undo .
define input parameter p-zero     as logical no-undo .
define input parameter p-sort-method as character no-undo .
define input parameter p-report-header as character no-undo .
/*code artic name*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-mar1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-mar1.p $":U .
define variable vss-description as character no-undo init "Дни продажи товара - отчет для Марии:сбор данных и печать".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  }
{ cmp/operlist.i }
{ rep/f-fdec.i   }
{ cmp/isengfrm.i }
{ gbl/waitfram.i }
{ trg/factord.i }
{ trg/prdoclib.i }


define variable date_string     as      char    no-undo.
define stream PrnLibStream .
define buffer buf_clients for ub.clients.

def temp-table sj-bar-code no-undo
field b-code like ub.bar-code.b-code
field gds-code like ub.bar-code.b-code
field node-code like ub.bar-code.node-code
field in-sale-date-from as date
field in-sale-date-to as date
field is-qnty as logical
INDEX pi IS PRIMARY
      gds-code
      node-code
      in-sale-date-to

INDEX ishow
      gds-code
      b-code
      in-sale-date-to
.

def temp-table sj-goods no-undo
field b-code like ub.bar-code.b-code
field gds-code like ub.bar-code.b-code
field gds-name like ub.goods.gds-name
field node-code like ub.bar-code.node-code
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field in-sale-days as integer
INDEX pi IS PRIMARY
      gds-code
      b-code
index iartic
      artic
      prod-type
      prod-code
      b-code
index igds-name
      gds-name
      gds-code
      b-code
.

def temp-table temp-prt-in-sale no-undo
field obj as character
field gds-code like ub.goods.gds-code
field prt-code like ub.prt-obj.prt-code
field evening as logical
field fact-qnty as decimal /*если в момент переноса в sj-bar-code fact-qnty > 0 значит morning = yes*/
field cr as integer
index pi is primary
gds-code
prt-code
obj
index icreate
cr
.

assign
date_string = cur-time-print() .
/*
&scop exppp ~
/*message obj-list.obj-code view-as alert-box . */   ~
output to value(string(obj-list.obj-code) + "hh.txt") . ~
put unformatted mesto skip. ~
for each sj-bar-code: ~
export sj-bar-code. ~
end. ~
output close. ~
*/

do
on error undo, return error
:
  /*проверим что все объекты принадлежат одной БД или текущая БД - главная*/
  if g#db-num <> 0 then do:

    for each obj-list no-lock,
        first buf_clients no-lock where
              buf_clients.obj-type = obj-list.obj-type
          AND buf_clients.obj-code = obj-list.obj-code:
      if buf_clients.db-num <> g#db-num then do:
        message
        "Отчет может быть запущен только для объектов БД" g#db-num skip
        "или же в ГБД"
        view-as alert-box error .
        return .
      end.
    end.

  end.


  /* определяем fact-ordera для периода */
  define variable v-start-date-order      as decimal   no-undo .
  define variable v-end-date-order        as decimal   no-undo .

  run day-begin-fact-order  in this-procedure (
                                                  input p-start-date
                                                  ,output v-start-date-order) no-error .

  run factord-end-day  in this-procedure (
                                           input p-end-date
                                          ,output v-end-date-order) no-error .

  run cr-sj-bar-code in this-procedure .

  if can-find(first sj-bar-code) then do:
    if p-sort-method = "artic":U
    or p-sort-method = "name":U then do:
      run cr-sj-goods in this-procedure .
    end.
    run printproc in this-procedure .
  end.
  else do:
    message
    "Нет данных для отчета - " skip
    "ни один из выбранных товаров не был в продаже за запрошенный период времени" skip
    string(if p-zero then "а опция <Выводить товары с нулевым значением> не включена" else "":U)
    view-as alert-box warning.
  end.

end. /*doe*/


procedure cr-sj-bar-code :
define buffer buf_temp-prt-in-sale for temp-prt-in-sale.
define buffer buf_goods for ub.goods.
  do
  on error undo, return error
  :
    CASE p-select-good:
      when {&g-all} then do:
        for each buf_goods no-lock:
          run process-one-good in this-procedure(
                                                   input buf_goods.gds-code
                                                  ,input buf_goods.artic
                                                  ,input buf_goods.prod-type
                                                  ,input buf_goods.prod-code
                                                  ,input buf_goods.unit-base
                                                  ,input v-start-date-order
                                                  ,input v-end-date-order
                                                ).
        end.
      end.
      when {&g-grp} then do:
        for each tmp#grp  no-lock where
                tmp#grp.is-term = yes,
            each buf_goods no-lock where
                  buf_goods.grp-code = tmp#grp.node-code:
          run process-one-good in this-procedure(
                                                      input buf_goods.gds-code
                                                    ,  input buf_goods.artic
                                                    ,  input buf_goods.prod-type
                                                    ,  input buf_goods.prod-code
                                                    ,  input buf_goods.unit-base
                                                    ,  input v-start-date-order
                                                    ,  input v-end-date-order
                                                  ).
        end.
      end.
      when {&g-prod} then do:
        for each g#cli no-lock,
            each buf_goods no-lock where
                buf_goods.prod-type = g#cli.obj-type
            AND  buf_goods.prod-code = g#cli.obj-code:
              run process-one-good in this-procedure(
                                                      input buf_goods.gds-code
                                                    ,  input buf_goods.artic
                                                    ,  input buf_goods.prod-type
                                                    ,  input buf_goods.prod-code
                                                    ,  input buf_goods.unit-base
                                                    ,  input v-start-date-order
                                                    ,  input v-end-date-order
                                                  ).

          end.
        end.
        when {&g-one}
        or
        when {&g-choice}
        or
        when {&g-grp-prod}
        then do:
          for each gds-list no-lock:
            run process-one-good in this-procedure(
                                                      input gds-list.gds-code
                                                    ,  input gds-list.artic
                                                    ,  input gds-list.prod-type
                                                    ,  input gds-list.prod-code
                                                    ,  input gds-list.unit-base
                                                    ,  input v-start-date-order
                                                    ,  input v-end-date-order
                                                  ).

          end.
        end.
    END CASE.
    run waitfram-hide in this-procedure .
  end.

end procedure. /* cr-sj-bar-code */

procedure process-one-good :
define input parameter p-gds-code    like ub.goods.gds-code  no-undo .
define input parameter p-artic       like ub.goods.artic     no-undo .
define input parameter p-prod-type   like ub.goods.prod-type no-undo .
define input parameter p-prod-code   like ub.goods.prod-code no-undo .
define input parameter p-unit-base   like ub.goods.unit-base no-undo .
define input parameter p-start-date-order as decimal no-undo .
define input parameter p-end-date-order as decimal no-undo .

define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_goods for ub.goods.

  do
  on error undo, return error
  :

     run waitfram-show in this-procedure ("Обрабатывается товар" + {&space-char} + p-artic + {&space-char} + p-prod-type + string(p-prod-code) ).
     find first buf_goods no-lock where
               buf_goods.gds-code = p-gds-code no-error .
     if error-status:error then do:
       undo, return error substitute("Не найден товар с кодом &1", P-GDS-CODE).
     end.

     _OBJ-LIST:
     for each obj-list no-lock:
        find first buf_gds-obj no-lock where
                  buf_gds-obj.gds-code = p-gds-code
              AND buf_gds-obj.obj-type = obj-list.obj-type
              AND buf_gds-obj.obj-code = obj-list.obj-code no-error .
        if not available buf_gds-obj then do:
          Next _OBJ-LIST.
        END.
        /*найдем остатки по признакам на конец дня p-end-date то бишь на начало дня p-end-date + 1*/
        run prdoclib-init-prt-obj-by-factord
                                          in this-procedure (
                                                             input obj-list.obj-type
                                                            ,input obj-list.obj-code
                                                            ,input buf_goods.artic
                                                            ,input buf_goods.prod-type
                                                            ,input buf_goods.prod-code
                                                            ,input p-end-date-order
                                                            ,input no /*p-include-fact-order*/
                                                            ) .
        /*перепишем массив по признакам на конец дня p-end-date -1 в таблицу sj-bar-code со значением in-sale-date p-end-date */
        run write-temp-prt-to-sj in this-procedure (
                                                     input p-end-date
                                                    ,input p-end-date
                                                    ,input p-gds-code
                                                    ,input p-unit-base
                                                    ) no-error .
{&exppp}
        /*на эти дни вычислим остаток по произнаку накатывая а вернее скатывая на temp-obj*/
        /*если он > 0 то сделаем запись во временную таблицу*/
        run decrement-prt-obj in this-procedure (
                                                 input obj-list.obj-type
                                                ,input obj-list.obj-code
                                                ,input p-gds-code
                                                ,input buf_goods.artic
                                                ,input buf_goods.prod-type
                                                ,input buf_goods.prod-code
                                                ,input p-unit-base
                                                ,input p-start-date-order
                                                ,input p-end-date-order) .
{&exppp}
    end. /*for each obj-list*/
  end.

end procedure. /* process-one-good */


procedure cr-sj-goods :
define buffer buf_goods for ub.goods.
define variable f-gds-name as character no-undo .
define variable f-in-sale-days as integer no-undo .
define variable f-artic like ub.goods.artic no-undo .
define variable f-prod-type like ub.goods.prod-type no-undo .
define variable f-prod-code like ub.goods.prod-code no-undo .

  do
  on error undo, return error
  :
     run waitfram-show in this-procedure ("Ждите..." ).
     for each sj-bar-code no-lock
     break
     by sj-bar-code.gds-code
     by sj-bar-code.b-code
     by sj-bar-code.in-sale-date-to :
        if first-of(sj-bar-code.gds-code) then do:
            find first buf_goods no-lock where
                     buf_goods.gds-code = sj-bar-code.gds-code.
          assign
          f-gds-name = buf_goods.gds-name
          f-artic    = buf_goods.artic
          f-prod-type = buf_goods.prod-type
          f-prod-code = buf_goods.prod-code
          .
        end.
        if first-of (sj-bar-code.b-code) then do:
          assign
          f-in-sale-days = 0
          .
        end.
        if sj-bar-code.is-qnty then
        assign
        f-in-sale-days = f-in-sale-days +
                         if sj-bar-code.is-qnty
                         then (sj-bar-code.in-sale-date-to - sj-bar-code.in-sale-date-from + 1)
                         else 0
        .
        if last-of(sj-bar-code.b-code) then do:
          find first sj-goods where
                    sj-goods.gds-code = sj-bar-code.gds-code
               AND  sj-goods.b-code = sj-bar-code.b-code no-error .
          if not available sj-goods then do:
            create sj-goods.
            buffer-copy sj-bar-code to sj-goods
            assign
            sj-goods.gds-name = f-gds-name
            sj-goods.artic     = f-artic
            sj-goods.prod-type = f-prod-type
            sj-goods.prod-code = f-prod-code

            sj-goods.in-sale-days = f-in-sale-days
            .
          end.
        end.
     end.
     run waitfram-hide in this-procedure .
  end.

end procedure. /* cr-sj-goods */

procedure printproc :
define variable f-prod-name as character no-undo .
define variable f-grp-name as character no-undo .
define variable f-prt-name as character no-undo .
define variable f-gds-name as character no-undo .
define variable f-artic as character no-undo .
define variable f-in-sale-days as integer no-undo .
define variable line as character no-undo .
define variable ii-excel as integer no-undo .
define variable ii-page as integer no-undo init 1.
define buffer buf1_sheetf for sheetf.
define buffer buf_sheetf for sheetf.


define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer buf_gds-prt for ub.gds-prt.
/*
output to hh.txt.
for each sj-bar-code:
export sj-bar-code.
end.
output close.
*/

&scop   page-excel-block  if ii-excel > 32000 then do:                                    ~
                           {&pageExcel}                                               ~
                           find first buf_sheetf where                                ~
                                     buf_sheetf.sheet-num = ii-page + 1 no-error.     ~
                           if not available buf_sheetf then do:                       ~
                             create buf_sheetf.                                       ~
                           end.                                                       ~
                           buffer-copy buf1_sheetf except sheet-num                   ~
                           to buf_sheetf                                              ~
                           assign                                                     ~
                           buf_sheetf.sheet-num = ii-page + 1                         ~
                           .                                                          ~
                           run rep/extitle.p (ii-page) .                                   ~
                           assign                                                     ~
                           ii-page = ii-page + 1                                      ~
                           ii-excel = 0                                               ~
                           .                                                          ~
                         end



  do
  on error undo, return error
  :

    DEFINE FRAME OutFrame
    sj-goods.b-code COLUMN-LABEL "Код"
    sj-goods.artic  COLUMN-LABEL "Артикул"
    f-gds-name COLUMn-LABEL "Название товара"  format "X(40)"
    f-prt-name COLUMn-LABEL "Шкальный признак" format "X(20)"
    f-prod-name COLUMn-LABEL "Производитель" format "X(30)"
    f-grp-name  COLUMn-LABEL "Группа" format "X(50)"
    f-in-sale-days COLUMN-LABEL "Дней в продаже" format ">>>9"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>>>>9" ) ) AT 170 format "X(13)" SKIP
        Line format "X(195)" AT 1
    with width {&DOS_CW_2} down stream-io.

    FORM HEADER
    Line format "X(195)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width {&DOS_CW_2}
    PAGE-BOTTOM no-labels no-box.
    run waitfram-show in this-procedure ("Ждите..." ).

    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&LS_PS_A4}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
    run rep/extitle.p (1).
    find first buf1_sheetf no-lock where buf1_sheetf.sheet-num = 1 or buf1_sheetf.sheet-num = 0.

    PUT stream PrnLibStream UNFORMATTED
    ("Дни продажи товара" +
    string( p-start-date, "99/99/9999" ) + " по " + string(p-end-date, "99/99/9999") + ".")
    format "x(110)" SKIP(1).
    PUT stream PrnLibStream UNFORMATTED
    str1 skip
    str2 skip
    str4 skip.
    PUT stream PrnLibStream UNFORMATTED
    p-report-header SKIP(0).

    VIEW STREAM PrnLibStream FRAME BottomFrame .
    FORM with FRAME OutFrame.

    CASE P-sort-method:
      when "code":U then do:
        /*для простой сортировки не будем делать второй таблицы sj-goods*/
        for each sj-bar-code no-lock
        break
        by sj-bar-code.gds-code
        by sj-bar-code.b-code
        by sj-bar-code.in-sale-date-to
        :
          {&page-excel-block} .
          if first-of(sj-bar-code.gds-code) then do:
            assign
            f-in-sale-days = 0
            .
            find first buf_goods no-lock where
                      buf_goods.gds-code = sj-bar-code.gds-code.
            find first buf_clients no-lock where
                      buf_Clients.obj-type = buf_goods.prod-type
                  AND buf_Clients.obj-code = buf_goods.prod-code no-error .
            assign
            f-prod-name = buf_clients.obj-name
            f-gds-name = buf_goods.gds-name
            f-grp-name = buf_goods.grp-name
            f-artic = buf_goods.artic
            .
          end.
          if first-of (sj-bar-code.b-code) then do:
            find first buf_gds-prt no-lock where
                      buf_gds-prt.node-code = sj-bar-code.node-code.
            assign
            f-prt-name = buf_gds-prt.f-name
            .
            assign
            f-in-sale-days = 0
            .
          end.
          assign
          f-in-sale-days = f-in-sale-days +
                           if sj-bar-code.is-qnty
                           then (sj-bar-code.in-sale-date-to - sj-bar-code.in-sale-date-from + 1)
                           else 0
          .
          if last-of(sj-bar-code.b-code) then do:
            if f-in-sale-days > 0 or p-zero then
            display stream PrnLibStream
            sj-bar-code.b-code @ sj-goods.b-code
            f-artic  @ sj-goods.artic
            f-gds-name
            f-prt-name
            f-prod-name
            f-grp-name
            f-in-sale-days
            with frame OutFrame.
            DOWN STREAM PrnLibStream
            1 with FRAME OutFrame .
            {&PutExcel}
            sj-bar-code.b-code {&tabulation}
            ({&delim-nws} + f-artic)            {&tabulation}
            f-gds-name         {&tabulation}
            f-prt-name         {&tabulation}
            f-prod-name        {&tabulation}
            f-grp-name         {&tabulation}
            f-in-sale-days
            skip.
            assign
            ii-excel = ii-excel + 1
            .
          end.
        end.
      end.
      when "Artic":U then do:
        for each sj-goods no-lock
        break
        by sj-goods.artic
        by sj-goods.prod-type
        by sj-goods.prod-code
        by sj-goods.b-code
        :
          {&page-excel-block}  .
          if first-of(sj-goods.prod-code) then do:
            find first buf_goods no-lock where
                      buf_goods.gds-code = sj-goods.gds-code.
            find first buf_clients no-lock where
                      buf_Clients.obj-type = buf_goods.prod-type
                  AND buf_Clients.obj-code = buf_goods.prod-code no-error .
            assign
            f-prod-name = buf_clients.obj-name
            f-gds-name = buf_goods.gds-name
            f-grp-name = buf_goods.grp-name
            .
          end.
          find first buf_gds-prt no-lock where
                    buf_gds-prt.node-code = sj-goods.node-code.
          assign
          f-prt-name = buf_gds-prt.f-name
          .
          if sj-goods.in-sale-days > 0 or p-zero then
          display stream PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          f-gds-name
          f-prt-name
          f-prod-name
          f-grp-name
          sj-goods.in-sale-days @ f-in-sale-days
          with frame OutFrame.
          DOWN STREAM PrnLibStream
          1 with FRAME OutFrame .
          {&PutExcel}
          sj-goods.b-code         {&tabulation}
          ({&delim-nws} + sj-goods.artic)          {&tabulation}
          f-gds-name              {&tabulation}
          f-prt-name              {&tabulation}
          f-prod-name             {&tabulation}
          f-grp-name              {&tabulation}
          sj-goods.in-sale-days
          skip.
            assign
            ii-excel = ii-excel + 1
            .



        end.
      end.
      when "name":U then do:
        for each sj-goods no-lock
        break
        by sj-goods.gds-name
        by sj-goods.gds-code
        by sj-goods.b-code
        :
          {&page-excel-block}   .
          if first-of(sj-goods.gds-code) then do:
            find first buf_goods no-lock where
                      buf_goods.gds-code = sj-goods.gds-code.
            find first buf_clients no-lock where
                      buf_Clients.obj-type = buf_goods.prod-type
                  AND buf_Clients.obj-code = buf_goods.prod-code no-error .
            assign
            f-prod-name = buf_clients.obj-name
            f-gds-name = buf_goods.gds-name
            f-grp-name = buf_goods.grp-name
            .
          end.
          find first buf_gds-prt no-lock where
                    buf_gds-prt.node-code = sj-goods.node-code.
          assign
          f-prt-name = buf_gds-prt.f-name
          .
          if sj-goods.in-sale-days > 0 or p-zero then
          display  stream PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          f-gds-name
          f-prt-name
          f-prod-name
          f-grp-name
          sj-goods.in-sale-days @ f-in-sale-days
          with frame OutFrame.
          DOWN STREAM PrnLibStream
          1 with FRAME OutFrame .
          {&PutExcel}
          sj-goods.b-code         {&tabulation}
          ({&delim-nws} + sj-goods.artic)          {&tabulation}
          f-gds-name              {&tabulation}
          f-prt-name              {&tabulation}
          f-prod-name             {&tabulation}
          f-grp-name              {&tabulation}
          sj-goods.in-sale-days
          skip.
          assign
          ii-excel = ii-excel + 1
          .
        end.
      end.
    END CASE.

    HIDE STREAM PrnLibStream FRAME BottomFrame .
    OUTPUT STREAM PrnLibStream CLOSE.
    {&CloseExcel}
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 8
                                              ).

  end.

end procedure. /* printproc */

procedure write-temp-prt-to-sj :
define input parameter p-in-sale-date-to as date no-undo .
define input parameter p-in-sale-date-from as date no-undo .
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-unit-cli like ub.goods.unit-base no-undo .

define variable v-was-sj as logical no-undo .

define buffer buf_temp-prt-obj for temp-prt-obj.
define buffer buf_sj-bar-code for sj-bar-code.
define buffer buf_bar-code for ub.bar-code.

  do
  on error undo, return error
  :
    for each buf_temp-prt-obj:
      if buf_temp-prt-obj.fact-qnty > 0 or p-zero then do:
        find first buf_sj-bar-code where
                  buf_sj-bar-code.gds-code = p-gds-code
              AND  buf_sj-bar-code.node-code = buf_temp-prt-obj.prt-code
              AND  buf_sj-bar-code.in-sale-date-to <= p-in-sale-date-to
              no-error .
        if not available buf_sj-bar-code then do:
          find first buf_bar-code no-lock
            where buf_bar-code.gds-code  = p-gds-code
              and buf_bar-code.node-code = buf_temp-prt-obj.prt-code
              and buf_bar-code.part-code = "":U
              and buf_bar-code.in-code   = "":U
              and buf_bar-code.unit-cli  = p-unit-cli
            .
          create buf_sj-bar-code.
          assign
          buf_sj-bar-code.gds-code = p-gds-code
          buf_sj-bar-code.node-code = buf_temp-prt-obj.prt-code
          buf_sj-bar-code.b-code   = (if avail buf_bar-code then buf_bar-code.b-code else buf_sj-bar-code.gds-code)
          buf_sj-bar-code.in-sale-date-to   = p-in-sale-date-to
          buf_sj-bar-code.in-sale-date-from = p-in-sale-date-to
          .
        end.
        else do:
          assign
          v-was-sj = yes
          .
        end.
        assign
        buf_sj-bar-code.is-qnty =  if avail buf_bar-code or v-was-sj
                                  then buf_sj-bar-code.is-qnty OR (if buf_temp-prt-obj.fact-qnty > 0
                                                                  then yes
                                                                  else no)
                                  else ?
        buf_sj-bar-code.in-sale-date-from = (if buf_temp-prt-obj.fact-qnty > 0 and buf_sj-bar-code.in-sale-date-from >= p-in-sale-date-from
                                             then p-in-sale-date-from
                                             else buf_sj-bar-code.in-sale-date-from)
        .
      end.
      /*берем только полож часть - потому что в итоге нам надо получить ответь был ли товар хоть на каком нибудь объекте*/
    end.
  end.

end procedure. /* write-temp-prt-to-sj */


procedure write-temp-prt-in-sale-to-sj :
define input parameter p-in-sale-date as date no-undo .
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-cr       as integer no-undo .
define input parameter p-unit-cli like ub.goods.unit-base no-undo .

define variable v-was-sj as logical no-undo .

define buffer buf_temp-prt-in-sale for temp-prt-in-sale.
define buffer buf_sj-bar-code for sj-bar-code.
define buffer buf_bar-code for ub.bar-code.

  do
  on error undo, return error
  :
    for each buf_temp-prt-in-sale where
           buf_temp-prt-in-sale.gds-code = p-gds-code
       AND buf_temp-prt-in-sale.cr < (p-cr + 1)
           :
      if buf_temp-prt-in-sale.evening and p-in-sale-date < p-end-date then do:
        /*остатки на вечер положительны*/
        find first buf_sj-bar-code where
                  buf_sj-bar-code.gds-code = p-gds-code
              AND  buf_sj-bar-code.node-code = buf_temp-prt-in-sale.prt-code
              AND  buf_sj-bar-code.in-sale-date-to > p-in-sale-date
              no-error .
      end.
      else do:
        /*остатки на вечер отрицательны или нулевые*/
        find first buf_sj-bar-code where
                  buf_sj-bar-code.gds-code = p-gds-code
              AND  buf_sj-bar-code.node-code = buf_temp-prt-in-sale.prt-code
              AND  buf_sj-bar-code.in-sale-date-to = p-in-sale-date
              no-error .
      end.
      assign
      v-was-sj = no.
      if not available buf_sj-bar-code then do:
        find first buf_bar-code no-lock
          where buf_bar-code.gds-code  = p-gds-code
            and buf_bar-code.node-code = buf_temp-prt-in-sale.prt-code
            and buf_bar-code.part-code = "":U
            and buf_bar-code.in-code   = "":U
            and buf_bar-code.unit-cli  = p-unit-cli
          .
        create buf_sj-bar-code.
        assign
        buf_sj-bar-code.gds-code = p-gds-code
        buf_sj-bar-code.node-code = buf_temp-prt-in-sale.prt-code
        buf_sj-bar-code.b-code   = (if avail buf_bar-code then buf_bar-code.b-code else buf_sj-bar-code.gds-code)
        buf_sj-bar-code.in-sale-date-to = if buf_temp-prt-in-sale.evening
                                          then (p-in-sale-date + 1)
                                          else  p-in-sale-date
        .
      end.
      else do:
        assign
        v-was-sj = yes
        .
      end.
      assign
      buf_sj-bar-code.in-sale-date-from = if buf_sj-bar-code.in-sale-date-from = ?
                                          then p-in-sale-date
                                          else minimum(p-in-sale-date, buf_sj-bar-code.in-sale-date-from)
      buf_sj-bar-code.is-qnty =  if avail buf_bar-code or v-was-sj then
                                  buf_sj-bar-code.is-qnty OR TRUE
                                  else ?
      .
    end.
  end.

end procedure. /* write-temp-prt-in-sale-to-sj */



procedure decrement-prt-obj :
define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
define input parameter p-gds-code           like ub.goods.gds-code    no-undo .
define input parameter p-artic              like ub.gds-obj.artic     no-undo .
define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
define input parameter p-unit-cli           like ub.goods.unit-base   no-undo .
define input parameter p-start-date-order   as decimal no-undo .
define input parameter p-end-date-order   as decimal no-undo .

define variable cr0 as integer no-undo .
define variable v-fact-date as date no-undo .
define variable v-evening as logical no-undo .
define variable v-before as logical no-undo .
define variable v-first-processing as logical no-undo .
define variable v-obj as character no-undo .
define variable v-not-found-trn-doc as logical no-undo init yes.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_temp-prt-obj for temp-prt-obj.
define buffer buf_temp-prt-in-sale for temp-prt-in-sale.
define buffer buf_sj-bar-code for sj-bar-code.

&scop create-temp-prt-in-sale-if-positive-qnty   if buf_temp-prt-obj.fact-qnty > 0 then do: ~
  find first buf_temp-prt-in-sale where ~
            buf_temp-prt-in-sale.gds-code = p-gds-code ~
        AND  buf_temp-prt-in-sale.prt-code = buf_temp-prt-obj.prt-code ~
        AND buf_temp-prt-in-sale.obj    = v-obj ~
        AND buf_temp-prt-in-sale.cr < (cr0  + 1) no-error. ~
  if not available buf_temp-prt-in-sale then do: ~
    assign ~
    v-evening = V-BEFORE /*значит это самое вечернее движение за день вернее уже конец дня*/   ~
    v-first-processing = yes ~
    . ~
    find first buf_temp-prt-in-sale where ~
              buf_temp-prt-in-sale.cr = (cr0 + 1) use-index icreate no-error. ~
    if not available buf_temp-prt-in-sale then do: ~
        create buf_temp-prt-in-sale. ~
        assign ~
        buf_temp-prt-in-sale.cr = cr0 + 1 ~
        cr0 = cr0 + 1 ~
        . ~
    end. ~
    else do: ~
      assign ~
      cr0 = cr0 + 1 ~
      . ~
    end. ~
  end. ~
  else do: ~
    assign  ~
    v-evening = no ~
    v-first-processing = no ~
    . ~
  end.  ~
  assign  ~
  buf_temp-prt-in-sale.evening  = if v-evening ~
                                  then (buf_temp-prt-obj.fact-qnty > 0) ~
                                  else (if v-first-processing then no else buf_temp-prt-in-sale.evening ) ~
  buf_temp-prt-in-sale.gds-code = p-gds-code ~
  buf_temp-prt-in-sale.prt-code = buf_temp-prt-obj.prt-code ~
  buf_temp-prt-in-sale.obj      = v-obj ~
  buf_temp-prt-in-sale.fact-qnty = buf_temp-prt-obj.fact-qnty ~
  . ~
/*output to hh1.txt append. ~
put unformatted recid(buf_temp-prt-in-sale) " " (IF V-BEFORE THEN "posle " ELSE "pered ") ~
buf_trn-doc.fact-date  " " buf_trn-doc.doc-type " " . ~
export buf_temp-prt-in-sale . ~
output close.  */   ~
end

/*специально не ставлю точку в конце чтобы проверять компилиться ли такой длинный препроцессинг!!*/


  do
  on error undo, return error
  :

     assign
     v-obj = p-obj-type + string(p-obj-code)
     .
    /* просматриваем все операции, прошедшие с товаром вниз в прошлое */
    /* от p-end-date-order */
    _buf_doc-line:
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = {&fact}
        and buf_doc-line.fact-order >= p-start-date-order
        and buf_doc-line.fact-order <= p-end-date-order
    by buf_doc-line.fact-order descending
    on error undo, return error
    :
      assign
      v-not-found-trn-doc = no
      .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
        no-error .
      if not available buf_trn-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при поиске документа" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-fact-order" buf_doc-line.fact-order skip
          view-as alert-box error .
        undo, return error .
      end.

      if v-fact-date <> buf_trn-doc.fact-date
      and v-fact-date <> ? /*только не в первом проходе цикла*/
      and cr0 > 0 /*были положительные остатки по признаку*/
      then do:
         /*перешли на предыдущий день*/
        run write-temp-prt-in-sale-to-sj in this-procedure (
                                                               input v-fact-date
                                                              ,input p-gds-code
                                                              ,input cr0
                                                              ,input p-unit-cli
                                                                ).
        {&exppp}
        assign
        cr0 = 0
        . /*начинаем писать в buf_temp-prt-in-sale c начала*/

      end.

      _buf_gds-dtl:
      for each buf_gds-dtl no-lock
        where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          and buf_gds-dtl.artic     = p-artic
          and buf_gds-dtl.prod-type = p-prod-type
          and buf_gds-dtl.prod-code = p-prod-code
      on error undo, return error
      :
        if buf_trn-doc.fact-date < p-end-date then do:
          find first buf_sj-bar-code no-lock where
                    buf_sj-bar-code.gds-code = p-gds-code
                and buf_sj-bar-code.node-code = buf_gds-dtl.prt-code
                AND buf_sj-bar-code.in-sale-date-to >= buf_trn-doc.fact-date no-error .
          if available buf_sj-bar-code and
          buf_sj-bar-code.in-sale-date-from <= buf_trn-doc.fact-date then next _buf_gds-dtl.
        end.

        define variable v-term-node as integer   no-undo .

        { gbl/termnode.i
          buf_gds-dtl.prt-code
          v-term-node
        }

        run prdoclib-temp-prt-obj-by-prt-root in this-procedure
          (input v-term-node
          ,buffer buf_temp-prt-obj
          ) .

        if buf_temp-prt-obj.is-term <> true then do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка при обработке документа" skip
            "Документ ссылается на нетерминальный признак" skip
            "Документ" buf_gds-dtl.doc-code skip
            "Артикул" buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
            "Признак" buf_gds-dtl.prt-code skip
            view-as alert-box error .
          undo, return error .
        end.
        /*смотрим на количество после документа - во времени после*/
        assign
        v-before = yes
        .
        {&create-temp-prt-in-sale-if-positive-qnty} .
        /* все действия производим с обратным знаком */
        case buf_trn-doc.doc-type :
          when {&income} or
          when {&return}
          then do:
            assign
              buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.fact-qnty
                                         - buf_gds-dtl.fact-qnty
            .
          end.
          when {&expense} or
          when {&write-off}
          then do:
            assign
              buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.fact-qnty
                                         + buf_gds-dtl.fact-qnty
            .
          end.
          when {&inventory}
          then do:
            assign
              buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.fact-qnty
                                         - buf_gds-dtl.doc-qnty
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Неизвестный тип документа" skip
              "Документ" buf_trn-doc.doc-code skip
              "Тип документа" buf_trn-doc.doc-type skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "fact-order" buf_doc-line.fact-order skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
        assign
        v-before = no
        v-evening = no
        .
        {&create-temp-prt-in-sale-if-positive-qnty} .
      end. /*for each gds-dtl*/
      assign
      v-fact-date = buf_trn-doc.fact-date.


    end.  /*for each doc-line*/
    if cr0 > 0 /*были положительные остатки по признаку*/
    then do:
        /*перешли на предыдущий день*/
      run write-temp-prt-in-sale-to-sj in this-procedure (
                                                             input v-fact-date
                                                            ,input p-gds-code
                                                            ,input cr0
                                                            ,input p-unit-cli
                                                              ).
    end.
    run write-temp-prt-to-sj  in this-procedure (
                                                    input p-end-date
                                                    ,input p-start-date
                                                    ,input p-gds-code
                                                    ,input p-unit-cli).

  end.

end procedure. /* decrement-prt-obj */
