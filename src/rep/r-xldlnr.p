/*
$Revision: $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: r-xldlnr.p $
$Archive: rep/r-xldlnr.p $

r-Отчет по картам ЛНР.

Автор: Шутилов Арнольд Валерьевич
Дата создания: 02/12/14
Author: Shutilov Arnold
Creation date: 02/12/14
v16.0 */

/* ***************************  Definitions  ************************** */
using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
block-level on error undo, throw.
define input parameter p-cb-disType as character no-undo.
define input parameter p-rs-klass as character no-undo.
define input parameter p-rs-det as character no-undo.

def var vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
def var vss-author      as character no-undo init "$Author: ASMorozov $":U .
def var vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-xldlnr.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-xldlnr.p $":U .
def var vss-description as character no-undo init "e-Отчет по картам ЛНР.Печать отчёта в процедуре my-report.".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }

define variable xml_tmp as character no-undo. /*путь к временному файлу*/
define variable Report as class ReportXml no-undo. /* Переменная под класс */
define variable gds-str as character no-undo init "".
define variable xslt-path as character no-undo. /*путь к шаблону */
define variable rep-out-unit as class rep-out no-undo. /*экземпляр класса формирования документа отчёта */
define variable v-total-qnty as decimal no-undo.
define variable v-total-sum1 as decimal no-undo.
define variable v-total-sum2 as decimal no-undo.

define temp-table tt-line no-undo
    field chk-date as date          /*Дата чека*/
    field chk-time as integer       /*Время*/
    field d-card as character       /*Номер карты*/
    field pay-desk as integer       /*№ кассы*/

    field obj-name as character     /*Объект. Имя*/
    field obj-type as character     /*Объект. Тип*/
    field obj-code as integer       /*Объект. Код*/

    field gds-name as character     /*Товар*/
    field eff-doc-qnty as decimal   /*Количество*/
    field object-sum as decimal     /*Сумма без скидки*/
    field discount as decimal       /*Скидка*/
    field tot-r-b as decimal        /*Сумма со скидкой*/
    field line-type as character
    field doc-code as character
    field type-line as character

    index pi as primary doc-code
.
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
    run my-report.


/* **********************  Internal Procedures  *********************** */

procedure my-report:
/*******************/

    define variable v-type as integer no-undo.
    v-type = if p-cb-disType = '1' then integer({&discnt-t-cashLoyal}) else integer({&discnt-t-bonusCard}).

    for each tt-line no-lock:
        delete tt-line.
    end.

    for each obj-list no-lock:
        /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
         run rep/rpychk0.p (input "r-shftc2"
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ?                    /*p-date-from*/
                        ,input ?                    /*p-date-to*/
                        ,input X-date-start         /*p-shift-date-from*/
                        ,input X-date-end           /*p-shift-date-to*/
                        ,input 1                    /*p-shift-num-start*/
                        ,input 99                   /*p-shift-num-end*/
                        ,input ?                    /*p-inkas-code*/
                        ) no-error.

         if error-status:error then
         do:
             message error-status:get-message(1) view-as alert-box.
         end.

         if x-TOG-Shift = yes then
         do:
             /* Выбрана галка СМЕНЫ в интерфейсе */
            for each ub.chk-doc no-lock
                where ub.chk-doc.obj-type = obj-list.obj-type
                and ub.chk-doc.obj-code = obj-list.obj-code
                and (ub.chk-doc.shift-date > x-Date-Start or
                    (ub.chk-doc.shift-date = x-Date-Start and ub.chk-doc.shift-num >= x-Shift-Start))
                and (ub.chk-doc.shift-date < x-Date-End or
                    (ub.chk-doc.shift-date = x-Date-End and ub.chk-doc.shift-num <= x-Shift-End))
                and  ub.chk-doc.out-code > "",
            first ub.chk-discnt  no-lock
                where ub.chk-discnt.doc-code = ub.chk-doc.doc-code
                and ub.chk-discnt.discnt-type = v-type
            :
                for each chk-gds no-lock
                where ub.chk-gds.doc-code = ub.chk-doc.doc-code
                :
                    for each ub.chk-gds-pay no-lock
                    where ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code
                    and ub.chk-gds-pay.b-code = chk-gds.b-code
                    and ub.chk-gds-pay.line-num = chk-gds.line-num
                    :
                        run proc-tt. /* Процедура для заполнения временной таблицы tt-line */
                    end.
                end.
             end.
         end.
         else
         do:
            /* Не выбрана галка СМЕНЫ в интерфейсе */
            for each ub.chk-doc no-lock
                where ub.chk-doc.obj-type = obj-list.obj-type
                and ub.chk-doc.obj-code = obj-list.obj-code
                and ub.chk-doc.chk-date >= x-Date-Start
                and ub.chk-doc.chk-date <= x-Date-End
                and  ub.chk-doc.out-code > "",
            first ub.chk-discnt no-lock
                where ub.chk-discnt.doc-code = ub.chk-doc.doc-code
                and ub.chk-discnt.discnt-type = v-type
            :
                for each chk-gds no-lock
                where ub.chk-gds.doc-code = ub.chk-doc.doc-code
                :
                    for each ub.chk-gds-pay no-lock
                    where ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code
                    and ub.chk-gds-pay.b-code = chk-gds.b-code
                    and ub.chk-gds-pay.line-num = chk-gds.line-num
                    :
                        run proc-tt.  /* Процедура для заполнения временной таблицы tt-line */
                    end.
                end.
             end.
         end.
    end.


    /*формируем xml */
    xml_tmp = string(session:temp-directory + "report-tmp2.xml"). /* путь к временному xml файлу */
    Report = new ReportXml(xml_tmp).

    Report:worksheet("Лист 1").
    Report:worksheet-header("start"). /* Начало шапки отчета */
    Report:worksheet-header("Детализированный отчёт по бонусам и картам ЛНР").

    str1 = (if X-TOG-Shift then "С " + string(X-Date-Start,"99/99/9999") + ", смена № "  + string(X-Shift-Start) +
                                " по " + string(X-Date-End,"99/99/9999") + ", смена № " + string(X-Shift-End)
                           else
                                "За период с " + string(X-Date-Start,"99/99/9999") + " по " + string(X-Date-End,"99/99/9999")
    ).

    if length(str1) > 115 then
    do:
        Report:worksheet-header(substring(str1, 1, 115) + "..." ).
    end.
    else
    do:
        Report:worksheet-header(str1).
    end.

    if X-selectGood = {&g-choice} then
    do:
        Report:worksheet-header("По списку товаров: ").

        for each gds-list no-lock:
            gds-str = gds-str + substitute("&1"
                                            , gds-list.gds-name
                                          ) + ", "
            .
        end.

        gds-str = right-trim( gds-str, " " ).
        gds-str = right-trim( gds-str, "," ).
        if length(gds-str) > 115 then
        do:
            Report:worksheet-header(substring(gds-str, 1, 115)+ "..." ).
        end.
        else
        do:
            Report:worksheet-header(gds-str).
        end.

        gds-str = "".
    end.
    else

        if length(str2) > 115 then
        do:
            Report:worksheet-header(substring(str2, 1, 115)+ "..." ).
        end.
        else
        do:
            Report:worksheet-header(str2).
        end.

        if length(str4) > 115 then
        do:
            Report:worksheet-header(substring(str4, 1, 115)+ "..." ).
        end.
        else
        do:
            Report:worksheet-header(str4).
        end.

        if p-cb-disType = "1" then
        do:
            Report:worksheet-header("Тип скидки: ЛНР.").
        end.
        else
        do:
            Report:worksheet-header("Тип скидки: бонусы.").
        end.

    Report:worksheet-header("end"). /*Конец шапки отчета*/
    Report:table-columns("60,60,120,60,60,60,110,60,60,60"). /* Начало таблицы, задаем размеры колонок */
    Report:table-types = "String,String,String,String,String,String,Number,Number,String,Number". /* Типы данных в таблице */
    Report:table-header("Дата чека|Время|Номер карты|№ кассы|Объект|Товар|Количество|Сумма без скидки|Скидка|Сумма со скидкой","40","4"). /* Шапка таблицы */ 

    /* Печать отчёта в случае, если классификация - ОБЪЕКТ и детализация - ТОВАР */
    if  p-rs-klass = "object":U and
    p-rs-det = "good":U then
    do:
        for each tt-line no-lock break by tt-line.obj-type by tt-line.obj-code
                                       by tt-line.chk-date by tt-line.chk-time
                                       by tt-line.doc-code by tt-line.type-line
        :

        if first-of (tt-line.obj-code) then
            Report:table-group("Объект " + tt-line.obj-name).
            Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                    + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                    + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                    + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                    + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                    + "|" + (if tt-line.gds-name = ? then "" else tt-line.gds-name)
                    + "|" + (if tt-line.eff-doc-qnty = ? then "" else string(tt-line.eff-doc-qnty))
                    + "|" + (if tt-line.object-sum = ? then "" else string(tt-line.object-sum))
                    + "|" + (if tt-line.discount = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                    + "|" + (if tt-line.tot-r-b = ? then "" else string(tt-line.tot-r-b))
            ).

        accumulate tt-line.eff-doc-qnty (total by tt-line.obj-code).
        accumulate tt-line.object-sum (total by tt-line.obj-code).
        accumulate tt-line.tot-r-b (total by tt-line.obj-code).
        accumulate tt-line.eff-doc-qnty (total).
        accumulate tt-line.object-sum (total).
        accumulate tt-line.tot-r-b (total).
        if last-of (tt-line.obj-code) then
            Report:table-subtotal(""
                        + "|" + ""
                        + "|" + "Итого по объекту"
                        + "|" + ""
                        + "|" + ""
                        + "|" + ""
                        + "|" + (if (accum total by tt-line.obj-code tt-line.eff-doc-qnty) = ? then ""
                                 else left-trim(string(accum total by tt-line.obj-code tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99")))
                        + "|" + (if (accum total by tt-line.obj-code tt-line.object-sum) = ? then ""
                                 else left-trim(string(accum total by tt-line.obj-code tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99")))
                        + "|" + ""
                        + "|" + (if (accum total by tt-line.obj-code tt-line.tot-r-b) = ? then ""
                                 else left-trim(string(accum total by tt-line.obj-code tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99")))
             ).
        end.
    end.

    /* Печать отчёта в случае, если классификация - ДАТА и детализация - ТОВАР */
    if p-rs-klass = "date":U and
    p-rs-det = "good":U then
    do:
        for each tt-line no-lock break by tt-line.chk-date by tt-line.chk-time by tt-line.doc-code by tt-line.type-line
        :
            if first-of (tt-line.chk-date) then Report:table-group("Дата " + (if tt-line.chk-date = ? then "" else string(tt-line.chk-date))).
            Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                    + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                    + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                    + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                    + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                    + "|" + (if tt-line.gds-name = ? then "" else tt-line.gds-name)
                    + "|" + (if tt-line.eff-doc-qnty  = ? then "" else string(tt-line.eff-doc-qnty))
                    + "|" + (if tt-line.object-sum  = ? then "" else string(tt-line.object-sum))
                    + "|" + (if tt-line.discount  = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                    + "|" + (if tt-line.tot-r-b  = ? then "" else string(tt-line.tot-r-b))
            ).

            accumulate tt-line.eff-doc-qnty  (total by tt-line.chk-date).
            accumulate tt-line.object-sum  (total by tt-line.chk-date).
            accumulate tt-line.tot-r-b  (total by tt-line.chk-date).
            accumulate tt-line.eff-doc-qnty  (total).
            accumulate tt-line.object-sum  (total).
            accumulate tt-line.tot-r-b  (total).
            if last-of (tt-line.chk-date) then
                Report:table-subtotal(""
                        + "|" + ""
                        + "|" + "Итого по дате"
                        + "|" + ""
                        + "|" + ""
                        + "|" + ""
                        + "|" + (if (accum total by tt-line.chk-date tt-line.eff-doc-qnty) = ? then ""
                                 else left-trim(string(accum total by tt-line.chk-date tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99")))
                        + "|" + (if (accum total by tt-line.chk-date tt-line.object-sum) = ? then ""
                                 else left-trim(string(accum total by tt-line.chk-date tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99")))
                        + "|" + ""
                        + "|" + (if (accum total by tt-line.chk-date tt-line.tot-r-b) = ? then ""
                                 else left-trim(string(accum total by tt-line.chk-date tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99")))
                 ).
        end.
    end.

    /* Печать отчёта в случае, если классификация - НОМЕР КАРТЫ и детализация - ТОВАР*/
    if p-rs-klass = "card":U and
    p-rs-det = "good":U then
    do:
        for each tt-line no-lock break by tt-line.d-card by tt-line.chk-date by tt-line.chk-time by tt-line.doc-code by tt-line.type-line
        :
            if first-of (tt-line.d-card) then Report:table-group("Номер карты " + (if tt-line.d-card = ? then "" else tt-line.d-card)).
            Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                    + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                    + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                    + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                    + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                    + "|" + (if tt-line.gds-name = ? then "" else tt-line.gds-name)
                    + "|" + (if tt-line.eff-doc-qnty  = ? then "" else string(tt-line.eff-doc-qnty))
                    + "|" + (if tt-line.object-sum  = ? then "" else string(tt-line.object-sum))
                    + "|" + (if tt-line.discount  = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                    + "|" + (if tt-line.tot-r-b  = ? then "" else string(tt-line.tot-r-b))
            ).

            accumulate tt-line.eff-doc-qnty (total by tt-line.d-card).
            accumulate tt-line.object-sum (total by tt-line.d-card).
            accumulate tt-line.tot-r-b (total by tt-line.d-card).
            accumulate tt-line.eff-doc-qnty (total).
            accumulate tt-line.object-sum (total).
            accumulate tt-line.tot-r-b (total).
            if last-of (tt-line.d-card) then
                Report:table-subtotal(""
                            + "|" + ""
                            + "|" + "Итого по номеру карты"
                            + "|" + ""
                            + "|" + ""
                            + "|" + ""
                            + "|" + (if (accum total by tt-line.d-card tt-line.eff-doc-qnty) = ? then ""
                                     else left-trim(string(accum total by tt-line.d-card tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99")))
                            + "|" + (if (accum total by tt-line.d-card tt-line.object-sum) = ? then ""
                                     else left-trim(string(accum total by tt-line.d-card tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99")))
                            + "|" + ""
                            + "|" + (if (accum total by tt-line.d-card tt-line.tot-r-b) = ? then ""
                                     else left-trim(string(accum total by tt-line.d-card tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99")))
                ).
        end.
    end.


    /* Печать отчёта в случае, если классификация - ОБЪЕКТ и детализация - ПО ТИПАМ ТОВАРА */
    if p-rs-klass = "object":U and
    p-rs-det = "goodtype":U then
    do:
        for each tt-line no-lock break by tt-line.obj-type by tt-line.obj-code by tt-line.chk-date
                                       by tt-line.chk-time by tt-line.doc-code by tt-line.type-line
        :
            if first-of (tt-line.obj-code) then Report:table-group("Объект " + tt-line.obj-name).
            if (tt-line.type-line = "1топливо") then
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + (if tt-line.gds-name = ? then "" else tt-line.gds-name)
                        + "|" + (if tt-line.eff-doc-qnty = ? then "" else string(tt-line.eff-doc-qnty))
                        + "|" + (if tt-line.object-sum = ? then "" else string(tt-line.object-sum))
                        + "|" + (if tt-line.discount = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + (if tt-line.tot-r-b = ? then "" else string(tt-line.tot-r-b))
                ).

            accumulate tt-line.eff-doc-qnty (total by tt-line.type-line).
            accumulate tt-line.object-sum (total by tt-line.type-line).
            accumulate tt-line.tot-r-b (total by tt-line.type-line).
            accumulate tt-line.eff-doc-qnty (total by tt-line.obj-code).
            accumulate tt-line.object-sum (total by tt-line.obj-code).
            accumulate tt-line.tot-r-b (total by tt-line.obj-code).
            accumulate tt-line.eff-doc-qnty (total).
            accumulate tt-line.object-sum (total).
            accumulate tt-line.tot-r-b (total).
            if last-of (tt-line.type-line) and (tt-line.type-line = "2услуги") then
            do:
                tt-line.discount = ((accum total by tt-line.type-line tt-line.object-sum) -
                                    (accum total by tt-line.type-line tt-line.tot-r-b)) * 100 /
                                    (accum total by tt-line.type-line tt-line.object-sum) no-error.
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + "Услуги"
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + (if tt-line.discount = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99"))
                ).
            end.
            if last-of (tt-line.type-line) and (tt-line.type-line = "3соп.тов.") then
            do:
                tt-line.discount = ((accum total by tt-line.type-line tt-line.object-sum) -
                                    (accum total by tt-line.type-line tt-line.tot-r-b)) * 100 /
                                    (accum total by tt-line.type-line  tt-line.object-sum) no-error.
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + "Соп.товары"
                        + "|" + left-trim(string(accum total by tt-line.type-line  tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + left-trim(string(accum total by tt-line.type-line  tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + (if tt-line.discount = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99"))
                ).
            end.
            if last-of (tt-line.type-line) and (tt-line.type-line = "4неуказ.") then
            do:
                tt-line.discount = ((accum total by tt-line.type-line tt-line.object-sum) -
                                    (accum total by tt-line.type-line tt-line.tot-r-b)) * 100 /
                                    (accum total by tt-line.type-line  tt-line.object-sum) no-error.
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + "Не указ."
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + left-trim(string(accum total by tt-line.type-line  tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + (if tt-line.discount = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99"))
                ).
            end.
            if last-of (tt-line.obj-code) then
                Report:table-subtotal(""
                                + "|" + ""
                                + "|" + "Итого по объекту"
                                + "|" + ""
                                + "|" + ""
                                + "|" + ""
                                + "|" + (if (accum total by tt-line.obj-code tt-line.eff-doc-qnty) = ? then ""
                                         else left-trim(string(accum total by tt-line.obj-code tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99")))
                                + "|" + (if (accum total by tt-line.obj-code tt-line.object-sum) = ? then ""
                                         else left-trim(string(accum total by tt-line.obj-code tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99")))
                                + "|" + ""
                                + "|" + (if (accum total by tt-line.obj-code tt-line.tot-r-b) = ? then ""
                                         else left-trim(string(accum total by tt-line.obj-code tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99")))
                 ).
        end.
    end.

    /* Печать отчёта в случае, если классификация - ДАТА и детализация - ПО ТИПАМ ТОВАРА */
    if p-rs-klass = "date":U and
    p-rs-det = "goodtype":U then
    do:
        for each tt-line no-lock break by tt-line.chk-date by tt-line.chk-time by tt-line.doc-code by tt-line.type-line
        :
            if first-of (tt-line.chk-date) then Report:table-group("Дата " + (if tt-line.chk-date = ? then "" else string(tt-line.chk-date))).
            if (tt-line.type-line = "1топливо") then
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + (if tt-line.gds-name = ? then "" else tt-line.gds-name)
                        + "|" + (if tt-line.eff-doc-qnty = ? then "" else string(tt-line.eff-doc-qnty))
                        + "|" + (if tt-line.object-sum = ? then "" else string(tt-line.object-sum))
                        + "|" + (if tt-line.discount = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + (if tt-line.tot-r-b = ? then "" else string(tt-line.tot-r-b))
                ).
            accumulate tt-line.eff-doc-qnty (total by tt-line.type-line).
            accumulate tt-line.object-sum (total by tt-line.type-line).
            accumulate tt-line.tot-r-b (total by tt-line.type-line).
            accumulate tt-line.eff-doc-qnty (total by tt-line.chk-date).
            accumulate tt-line.object-sum (total by tt-line.chk-date).
            accumulate tt-line.tot-r-b (total by tt-line.chk-date).
            accumulate tt-line.eff-doc-qnty (total).
            accumulate tt-line.object-sum (total).
            accumulate tt-line.tot-r-b (total).
            if last-of (tt-line.type-line) and (tt-line.type-line = "2услуги") then
            do:
                tt-line.discount = ((accum total by tt-line.type-line tt-line.object-sum) -
                                    (accum total by tt-line.type-line tt-line.tot-r-b)) * 100 /
                                    (accum total by tt-line.type-line tt-line.object-sum) no-error.
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + "Услуги"
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + left-trim(string(accum total by tt-line.type-line  tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + (if tt-line.discount  = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99"))
                ).
            end.

            if last-of (tt-line.type-line) and (tt-line.type-line = "3соп.тов.") then
            do:
                tt-line.discount = ((accum total by tt-line.type-line tt-line.object-sum) -
                                    (accum total by tt-line.type-line tt-line.tot-r-b)) * 100 /
                                    (accum total by tt-line.type-line tt-line.object-sum) no-error.
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + "Соп.товары"
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + (if tt-line.discount = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99"))
                ).
            end.
            if last-of (tt-line.type-line) and (tt-line.type-line = "4неуказ.") then
            do:
                tt-line.discount = ((accum total by tt-line.type-line tt-line.object-sum) -
                                    (accum total by tt-line.type-line tt-line.tot-r-b)) * 100 /
                                    (accum total by tt-line.type-line tt-line.object-sum) no-error.
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + "Не указ."
                        + "|" + left-trim(string(accum total by  tt-line.type-line  tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + left-trim(string(accum total by tt-line.type-line  tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + (if tt-line.discount  = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99"))
                ).
            end.

            if last-of (tt-line.chk-date) then
                Report:table-subtotal(""
                        + "|" + ""
                        + "|" + "Итого по дате"
                        + "|" + ""
                        + "|" + ""
                        + "|" + ""
                        + "|" + (if (accum total by tt-line.chk-date tt-line.eff-doc-qnty) = ? then ""
                                 else left-trim(string(accum total by tt-line.chk-date tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99")))
                        + "|" + (if (accum total by tt-line.chk-date tt-line.object-sum) = ? then ""
                                 else left-trim(string(accum total by tt-line.chk-date tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99")))
                        + "|" + ""
                        + "|" + (if (accum total by tt-line.chk-date tt-line.tot-r-b) = ? then ""
                                 else left-trim(string(accum total by tt-line.chk-date tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99")))
                ).
        end.
    end.

    /* Печать отчёта в случае, если классификация - НОМЕР КАРТЫ и детализация - ПО ТИПАМ ТОВАРА */
    if p-rs-klass = "card":U and
    p-rs-det = "goodtype":U then
    do:
        for each tt-line no-lock break by tt-line.d-card by tt-line.chk-date by tt-line.chk-time by tt-line.doc-code by tt-line.type-line
        :
            if first-of (tt-line.d-card) then Report:table-group("Номер карты " + (if tt-line.d-card = ? then "" else tt-line.d-card)).
            if (tt-line.type-line = "1топливо") then
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + (if tt-line.gds-name = ? then "" else tt-line.gds-name)
                        + "|" + (if tt-line.eff-doc-qnty  = ? then "" else string(tt-line.eff-doc-qnty))
                        + "|" + (if tt-line.object-sum  = ? then "" else string(tt-line.object-sum))
                        + "|" + (if tt-line.discount  = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + (if tt-line.tot-r-b  = ? then "" else string(tt-line.tot-r-b))
                ).
            accumulate tt-line.eff-doc-qnty (total by tt-line.type-line).
            accumulate tt-line.object-sum (total by tt-line.type-line).
            accumulate tt-line.tot-r-b (total by tt-line.type-line).
            accumulate tt-line.eff-doc-qnty (total by tt-line.d-card).
            accumulate tt-line.object-sum (total by tt-line.d-card).
            accumulate tt-line.tot-r-b (total by tt-line.d-card).
            accumulate tt-line.eff-doc-qnty (total).
            accumulate tt-line.object-sum (total).
            accumulate tt-line.tot-r-b (total).
            if last-of (tt-line.type-line) and (tt-line.type-line = "2услуги") then
            do:
                tt-line.discount = ((accum total by tt-line.type-line tt-line.object-sum) -
                                    (accum total by tt-line.type-line tt-line.tot-r-b)) * 100 /
                                    (accum total by tt-line.type-line tt-line.object-sum) no-error.
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + "Услуги"
                        + "|" + left-trim(string(accum total by  tt-line.type-line  tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + left-trim(string(accum total by tt-line.type-line  tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + (if tt-line.discount  = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99"))
                ).
            end.

            if last-of (tt-line.type-line) and (tt-line.type-line = "3соп.тов.") then
            do:
                tt-line.discount = ((accum total by tt-line.type-line tt-line.object-sum) -
                                    (accum total by tt-line.type-line tt-line.tot-r-b)) * 100 /
                                    (accum total by tt-line.type-line tt-line.object-sum) no-error.
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + "Соп.товары"
                        + "|" + left-trim(string(accum total by  tt-line.type-line  tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + left-trim(string(accum total by tt-line.type-line  tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + (if tt-line.discount  = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99"))
                ).
            end.

            if last-of (tt-line.type-line) and (tt-line.type-line = "4неуказ.") then
            do:
                tt-line.discount = ((accum total by tt-line.type-line tt-line.object-sum) -
                                    (accum total by tt-line.type-line tt-line.tot-r-b)) * 100 /
                                    (accum total by tt-line.type-line tt-line.object-sum) no-error.
                Report:table-row((if tt-line.chk-date = ? then "" else string(tt-line.chk-date))
                        + "|" + (if tt-line.chk-time = ? then "" else string(tt-line.chk-time,"hh:mm"))
                        + "|" + (if tt-line.d-card = ? then "" else tt-line.d-card)
                        + "|" + (if tt-line.pay-desk = ? then "" else string(tt-line.pay-desk))
                        + "|" + (if tt-line.obj-name = ? then "" else tt-line.obj-name)
                        + "|" + "Не указ."
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                        + "|" + (if tt-line.discount = ? then "" else string(tt-line.discount,"->>>,>>9.99") + "%")
                        + "|" + left-trim(string(accum total by tt-line.type-line tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99"))
                ).
            end.

            if last-of (tt-line.d-card) then
                Report:table-subtotal(""
                                + "|" + ""
                                + "|" + "Итого по номеру карты"
                                + "|" + ""
                                + "|" + ""
                                + "|" + ""
                                + "|" + (if (accum total by tt-line.d-card tt-line.eff-doc-qnty) = ? then ""
                                         else left-trim(string(accum total by tt-line.d-card tt-line.eff-doc-qnty, "->>>,>>>,>>>,>>>,>>9.99")))
                                + "|" + (if (accum total by tt-line.d-card tt-line.object-sum) = ? then ""
                                         else left-trim(string(accum total by tt-line.d-card tt-line.object-sum, "->>>,>>>,>>>,>>>,>>9.99")))
                                + "|" + ""
                                + "|" + (if (accum total by tt-line.d-card tt-line.tot-r-b) = ? then ""
                                         else left-trim(string(accum total by tt-line.d-card tt-line.tot-r-b, "->>>,>>>,>>>,>>>,>>9.99")))
                ).
        end.
    end.


    v-total-qnty = accum total tt-line.eff-doc-qnty.
    v-total-sum1 = accum total tt-line.object-sum.
    v-total-sum2 = accum total tt-line.tot-r-b.

    Report:table-total("Итого"
                + "|" + ""
                + "|" + ""
                + "|" + ""
                + "|" + ""
                + "|" + ""
                + "|" + (if (v-total-qnty) = ? then ""
                         else left-trim(string(v-total-qnty, "->>>,>>>,>>>,>>>,>>9.99")))
                + "|" + (if (v-total-sum1) = ? then ""
                         else left-trim(string(v-total-sum1, "->>>,>>>,>>>,>>>,>>9.99")))
                + "|" + ""
                + "|" + (if (v-total-sum2) = ? then ""
                         else left-trim(string(v-total-sum2, "->>>,>>>,>>>,>>>,>>9.99")))
    ).


    report:worksheet("end").
    delete object Report.

    xslt-path = search("exe\template.xsl").
    rep-out-unit = new rep-out ().
    rep-out-unit:office(xml_tmp, xslt-path).

end procedure.


procedure proc-tt:
/*****************/

    for first ub.bar-code no-lock where ub.bar-code.b-code = chk-gds-pay.b-code
    :
        if (x-SelectGood = {&g-all}) or (can-find(first gds-list no-lock where gds-list.gds-code = ub.bar-code.gds-code)) then
        do:
            create tt-line.

            tt-line.chk-date = ub.chk-doc.chk-date. /*Дата чека*/
            tt-line.chk-time = ub.chk-doc.chk-time. /*Время*/
            tt-line.d-card = ub.chk-discnt.d-card. /*Номер карты*/

            if tt-line.d-card = ? or tt-line.d-card = "" then
            do:
                for first chk-pay no-lock
                where chk-pay.doc-code = chk-doc.doc-code
                and chk-pay.line-num = chk-gds-pay.cpline-num
                :
                    tt-line.d-card = chk-pay.pay-card.
                end.
            end.

            tt-line.pay-desk = ub.chk-doc.pay-desk. /*№ кассы*/
            tt-line.obj-name = obj-list.obj-name. /*Объект*/
            tt-line.obj-code = obj-list.obj-code. /*Объект*/
            tt-line.obj-type = obj-list.obj-type. /*Объект*/

            for first ub.goods no-lock
            where ub.goods.gds-code = ub.bar-code.gds-code
            :
                tt-line.gds-name = ub.goods.gds-name. /*Товар*/
            end.

            tt-line.eff-doc-qnty = ub.chk-gds-pay.eff-doc-qnty. /*Количество*/
            tt-line.object-sum = chk-gds.src-sum * (chk-gds-pay.eff-doc-qnty / chk-gds.doc-qnty) no-error. /*Сумма без скидки*/
            tt-line.tot-r-b = ub.chk-gds-pay.tot-r-b. /*Сумма со скидкой*/
            tt-line.discount = ((tt-line.object-sum - tt-line.tot-r-b) * 100) / tt-line.object-sum no-error. /*Скидка*/
            tt-line.line-type = entry(1,chk-gds-pay.line-type,{&delim-par}).
            tt-line.doc-code = chk-doc.doc-code.

            case tt-line.line-type:
                when {&petrolium} then do: tt-line.type-line = "1топливо". end.
                when {&gds-office} then do: tt-line.type-line = "2услуги". end.
                when {&gds-goods} then do: tt-line.type-line = "3соп.тов.". end.
                otherwise do: tt-line.type-line = "4неуказ.". end.
            end case.
        end.
    end.

end procedure.

