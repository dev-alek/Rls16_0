using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
block-level on error undo, throw.
/*

$Revision: bbf1530230d5, 2753, rls $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: r-segm.p $
$Archive: rep/r-segm.p $

Процедура формирования отчета по сегментации клиентов

Автор: Кабоев Валерий Асланович
Дата создания: 19/09/12
Author: Kaboev Valeriy
Creation date: 19/09/12

*/
define variable vss-revision    as character no-undo init "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-segm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-segm.p $":U .
define variable vss-description as character no-undo init "Процедура формирования отчета по сегментации клиентов" .
{ gbl/cur-time.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ ref/grplib.i   }
{ cmp/dc-list.i dc-list def "shared" }
/* ***************************  Definitions  ************************** */
define input parameter  parparentproc    as handle. 
define input parameter  det-by-obj      as logical. /*Детализация по объектам */
define input parameter  det-by-dcard    as logical. /*Детализация по картам */
define input parameter  segm-sex        as logical. /*Сегментация по полу */
define input parameter  segm-age        as logical. /*Сегментация по возрасту */
define input parameter  plist           as character. /*Список возрастных периодов для сегментации */
define input parameter  x-start-date    as date. /*start-date отчёта */
define input parameter  x-end-date      as date. /*end-date отчёта */
define input parameter  dcard-mode      as integer. /*режим выборки по дисконтным картам (все/список) */
define variable head-objects    as character    no-undo. /*список объектов */
define variable Report          as class ReportXml no-undo. /* Переменная под класс */
define variable xml_tmp         as character    no-undo. /* Путь к временному xml файлу */
define variable xslt_path       as character    no-undo. /* Путь к xslt.exe */
define variable xslt            as character    no-undo. /* Путь к xsl файлу */
define variable xml_res         as character    no-undo. /* Путь к готовому отчету */
define variable temp-purch      as integer      no-undo.
define variable temp-total      as decimal      no-undo.
define variable temp-discount   as decimal      no-undo.
define variable temp-averg      as decimal      no-undo. /*Переменные-контейнеры, вместо accum, чтобы не запутаться */
define variable chk-find        as integer      no-undo init 0.  /*Флаг: найдены ли покупки по дк */
define variable grab-start      as decimal      no-undo.
define variable grab-end        as decimal      no-undo.
define variable chk-exists-in-tmp as logical    no-undo.
define variable tmp-val-total   as decimal      no-undo.
define variable tmp-val-quan    as decimal      no-undo.
define variable i-quantmp           as integer      no-undo.
define variable d-sumtmp            as decimal      no-undo.
define variable d-disctmp           as decimal      no-undo.
define variable list-counter        as integer      no-undo.
define variable xls-name            as character    no-undo.
define variable tmp-obj         as character no-undo.
define variable fnd-good-in-chk as logical      no-undo.
define variable tmp-sred        as decimal      no-undo format ">>>>9":u.
define variable tot-purch       as integer no-undo.
define variable tot-sum         as decimal no-undo.

        /*--TEMP-TABLE DEFINITIONS--*/
            define new shared temp-table   t-report-tmp no-undo
            field   period      as character    format "X(21)":u
            field   sex         like ub.person.gender
            field   dcard-num   like ub.dis-card.d-card
            field   purchases   as integer      
            field   total-sum   as decimal      format ">>>>>>>>9":u
            field   discount    as decimal      format ">>>>9":u
            field   averg       as decimal      format ">>>>9":u
            field   t-object    as character
            index   ind-prim    dcard-num
            index   ind-period  period
            index   ind-object  t-object
            index   ind-sex     sex.
            
            define temp-table t-cards no-undo
            field   dcard       like ub.dis-card.d-card
            index   ind-dc      dcard.
/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Prototypes ********************** */
FUNCTION get-sex RETURNS CHARACTER 
	( input sex as logical ) FORWARD.
	
/* ***************************  Main Block  *************************** */

/* ************************  Function Implementations ***************** */
FUNCTION get-sex RETURNS CHARACTER  /*Получить букву пола из Logical */
	    ( input sex as logical ):
if sex then return "Ж":u.
else if not sex then return "М":u.
else return "Не указано":u.
END FUNCTION.

function calc-age-in-years returns decimal  /*Расчёт возраста */
    ( input bday as date):
    define variable ret-age as integer no-undo.
    ret-age = integer(entry(3 , string(cur-time-date()) , "/")) - integer(entry(3,string(bday,"99/99/9999"),"/")).
    if integer(entry(2 , string(cur-time-date()) , "/")) < integer(entry(2,string(bday,"99/99/9999"),"/")) 
        then ret-age = ret-age - 1.
    else if integer(entry(2,string(cur-time-date()),"/")) = integer(entry(2,string(bday,"99/99/9999"),"/")) and integer(entry(1,string(cur-time-date()),"/")) < integer(entry(1,string(bday,"99/99/9999"),"/")) 
        then ret-age = ret-age - 1.
    define variable result as decimal no-undo.
    result = ret-age.
    return result.
end function.

function grab returns decimal 
    (input frst as logical, input period as character):
    define variable val as decimal no-undo.
    if period = "0" and frst then return 0.
    else if period = "0" and not frst then return 9999.
    if frst then 
    do:
        val = decimal(entry(1,period,"-":u)).
    end.
    else do:
        if entry(2,period,"-":u) = "...":u then
            val = 9999.
        else
            val = decimal(entry(2,period,"-":u)).
    end.
    return val.
end function.
  
procedure fill-table:
    define input parameter p-summ as decimal format ">>>>>>>>9":u.
    define input parameter p-dsct as decimal format ">>>>9":u.
    define input parameter p-quan as integer.
    define input parameter p-card like dis-card.d-card.
    define input parameter p-obj  as character.
    define input parameter p-psn  like person.psn-code.
    define variable var-card      as logical no-undo init no.
    for first person where person.psn-code = p-psn:
        create t-report-tmp.
            t-report-tmp.t-object = p-obj.
            t-report-tmp.averg = p-summ / p-quan.
            t-report-tmp.dcard-num = p-card.
            t-report-tmp.discount = p-dsct.
            if not segm-age then 
                t-report-tmp.period = "".
            else do:
                if person.date-birth = ? then
                    t-report-tmp.period = "остальные".
                else if grab-start > 0 and grab-end < 9999 then
                    t-report-tmp.period = " oт ":u + string(grab-start) + " до ":u + string(grab-end).
                else if grab-start = 0 and grab-end < 9999 then
                    t-report-tmp.period = " до ":u + string(grab-end).
                else if grab-start > 0 and grab-start < 9999 and grab-end = 9999 then
                    t-report-tmp.period = " oт ":u + string(grab-start).
            end.
            t-report-tmp.purchases = p-quan.
            if segm-sex then
                t-report-tmp.sex = person.gender.
            else
                t-report-tmp.sex = no.
            t-report-tmp.total-sum = p-summ.
            for first t-cards where t-cards.dcard = p-card:
                var-card = yes.
            end.
            if not var-card then do:
                create t-cards.
                t-cards.dcard = p-card.
            end.
    end.
end.
if x-selectgood = 2 then do:
    for each gds-list exclusive-lock:
        delete gds-list.
    end.
    for each ub.goods no-lock:
        for first tmp#grp where tmp#grp.is-term and tmp#grp.grp-name = goods.grp-name:
            create gds-list.
            assign
                gds-list.artic = ub.goods.artic
                gds-list.gds-code = ub.goods.gds-code
                gds-list.prod-type = ub.goods.prod-type
                gds-list.prod-code = ub.goods.prod-code
            .
        end.
    end.
end. 
                                                                                        
if dcard-mode = 0 then do:
    for each dc-list:
        delete dc-list.
    end.
    for each dis-card no-lock:
    /*заполняем dc-list, если он пуст, чтобы не множить запросы в коде.*/
    create dc-list.
    assign
        dc-list.d-card = dis-card.d-card.
        dc-list.card-num = dis-card.card-num.
        dc-list.cli-type = dis-card.cli-type.
        dc-list.cli-code = dis-card.cli-code.
        dc-list.issue-date = dis-card.issue-date.
    end.
end.
if not segm-age then
plist = "0".
for each dc-list where dc-list.cli-type = {&prs}:
    list-counter = 0.
    do while list-counter < num-entries(plist, ","):
        list-counter = list-counter + 1.
        grab-start = grab(yes, entry(list-counter, plist, ",")).
        grab-end = grab(no, entry(list-counter, plist, ",")).
        for first person where person.psn-code = dc-list.cli-code 
        no-lock:
            if not segm-age 
            or person.date-birth = ? and list-counter = 1
            or calc-age-in-years(person.date-birth) >= grab-start 
            and calc-age-in-years(person.date-birth) <= grab-end 
            then do:
                i-quantmp = 0.
                d-disctmp = 0.
                d-sumtmp = 0.
                if not det-by-obj then do:
                    i-quantmp = 0.
                    d-disctmp = 0.
                    d-sumtmp = 0.
                    for each obj-list:
                        for each chk-doc where chk-doc.tot-doc >= 0 
                        and chk-doc.d-card = dc-list.d-card 
                        and chk-doc.chk-date >= x-date-start 
                        and chk-doc.chk-date <= x-date-end 
                        and chk-doc.obj-type = obj-list.obj-type 
                        and chk-doc.obj-code = obj-list.obj-code 
                        no-lock:
                            fnd-good-in-chk = false.
                            if x-selectgood = 1 then do:
                                fnd-good-in-chk = true.
                                d-disctmp = d-disctmp  + chk-doc.discnt.
                                d-sumtmp = d-sumtmp + chk-doc.tot-doc.
                            end.
                            else do:
                                for each gds-list:
                                    for each chk-gds where chk-gds.doc-code = chk-doc.doc-code 
                                    no-lock:
                                        for first bar-code where bar-code.gds-code = gds-list.gds-code 
                                        and bar-code.b-code = chk-gds.b-code 
                                        no-lock:
                                            fnd-good-in-chk = true.
                                            d-disctmp = d-disctmp  + chk-gds.discnt.
                                            d-sumtmp = d-sumtmp + chk-gds.price-base * chk-gds.doc-qnty.
                                        end.
                                    end.
                                end.
                            end.
                            if fnd-good-in-chk then i-quantmp = i-quantmp + 1.
                        end.
                    end.
                    if d-sumtmp > 0 and i-quantmp > 0 then do:  /*если найдена хоть одна покупка, то пишем в темп-тэйбл*/
                        run fill-table(input d-sumtmp, input d-disctmp, input i-quantmp, input dc-list.d-card, input "", input person.psn-code).                    
                    end.
                end.  /* not det-by-obj */
                else do:
                    for each obj-list:
                        i-quantmp = 0.
                        d-disctmp = 0.
                        d-sumtmp = 0.
                        for each chk-doc where chk-doc.tot-doc >= 0 
                        and chk-doc.d-card = dc-list.d-card 
                        and chk-doc.chk-date >= x-date-start 
                        and chk-doc.chk-date <= x-date-end 
                        and chk-doc.obj-type = obj-list.obj-type 
                        and chk-doc.obj-code = obj-list.obj-code 
                        no-lock:
                            fnd-good-in-chk = false.
                            if x-selectgood = 1 then do:
                                fnd-good-in-chk = true.
                                d-disctmp = d-disctmp  + chk-doc.discnt.
                                d-sumtmp = d-sumtmp + chk-doc.tot-doc.
                            end.
                            else do:
                                for each gds-list:
                                    for each chk-gds where chk-gds.doc-code = chk-doc.doc-code 
                                    no-lock:
                                        for first bar-code where bar-code.gds-code = gds-list.gds-code 
                                        and bar-code.b-code = chk-gds.b-code 
                                        no-lock:
                                            fnd-good-in-chk = true.
                                            d-disctmp = d-disctmp  + chk-gds.discnt.
                                            d-sumtmp = d-sumtmp + chk-gds.price-base * chk-gds.doc-qnty.
                                        end.
                                    end.
                                end.
                            end.
                            if fnd-good-in-chk then i-quantmp = i-quantmp + 1.
                        end.
                        if d-sumtmp > 0 and i-quantmp > 0 then do:  /*если найдена хоть одна покупка, то пишем в темп-тэйбл*/
                            tmp-obj = obj-list.obj-type + string(obj-list.obj-code).
                            run fill-table(input d-sumtmp, input d-disctmp, input i-quantmp, input dc-list.d-card, input obj-list.obj-type + string(obj-list.obj-code), input person.psn-code).                    
                        end.
                    end.
                end.   /* else do */
            end.    /*if person */
        end.    /* person */
    end.    /* do while list-counter */
end.    /*dc-list */

for first t-report-tmp no-lock:
  chk-find = 1.
end.

if chk-find = 0 then do:
    message "По текущим дисконтным картам не найдено ни одной покупки." view-as alert-box.
    return.
end.
for each t-cards:
    accumulate t-cards.dcard (count).
end.
for each obj-list:
    head-objects = head-objects + obj-list.obj-type + string(obj-list.obj-code) + ", ".
end.
xml_tmp = string(session:temp-directory + "segment-tmp.xml"). /* путь к временному xml файлу */
Report = new ReportXml(xml_tmp).
if segm-sex and segm-age then 
    Report:add-element("mode","1").
if not segm-sex and segm-age then 
    Report:add-element("mode","2").
if segm-sex and not segm-age then 
    Report:add-element("mode","3").
if det-by-obj then
    Report:add-element("detmode","1").
else if not det-by-obj then 
    Report:add-element("detmode","0").
Report:worksheet("Лист 1"). /* Начало Excel листа */
Report:worksheet-header("start").   /* Начало шапки отчета */
if segm-sex and segm-age then 
    Report:worksheet-header("Сегментация клиентов по возрасту и полу.").
if not segm-sex and segm-age then 
    Report:worksheet-header("Сегментация клиентов по возрасту.").
if segm-sex and not segm-age then 
Report:worksheet-header("Сегментация клиентов по полу.").
Report:worksheet-header("За период с " + string(x-date-start,"99/99/9999") + " по " + string(x-date-end,"99/99/9999")).
Report:worksheet-header("Дата создания: " + string(cur-time-date())).
Report:worksheet-header("Выбор объектов: " + head-objects).
Report:worksheet-header("end").     /*Конец шапки отчета*/
if segm-sex and segm-age then do:
    Report:table-columns("70,70,100,100,120,100,100").    /* Начало таблицы, задаем размеры колонок */
    Report:table-types = "String,String,Number,Number,Number,Number,Number".   /* Типы данных в таблице */
    Report:table-header("Возраст|Пол|№ ДК|Количество покупок|Сумма покупки|Скидка по ДК|Средняя покупка","40","4").    /* Шапка таблицы */ 
end.
if not segm-sex and segm-age then do:
    Report:table-columns("70,70,100,100,120,100,100").    /* Начало таблицы, задаем размеры колонок */
    Report:table-types = "String,String,Number,Number,Number,Number,Number".   /* Типы данных в таблице */
    Report:table-header("|Пол|№ ДК|Количество покупок|Сумма покупки|Скидка по ДК|Средняя покупка","40","4").    /* Шапка таблицы */ 
end.
if segm-sex and not segm-age then do:
    Report:table-columns("70,70,100,100,120,100,100").    /* Начало таблицы, задаем размеры колонок */
    Report:table-types = "String,String,Number,Number,Number,Number,Number".   /* Типы данных в таблице */
    Report:table-header("Возраст||№ ДК|Количество покупок|Сумма покупки|Скидка по ДК|Средняя покупка","40","4").    /* Шапка таблицы */ 
end.
/*иерархия отчёта:
    объект
        период
            пол
                [ДК/]
*/

for each t-report-tmp break by t-report-tmp.t-object by t-report-tmp.period by t-report-tmp.sex by t-report-tmp.dcard-num:
    if first-of (t-report-tmp.t-object) then do:
        report:start-element("object").
        Report:add-attr("value","Объект: " + t-report-tmp.t-object).
        if not segm-age then
            report:start-element("period").
    end.
    if segm-age and first-of (t-report-tmp.period) then do:
        report:start-element("period").
        Report:add-attr("value",t-report-tmp.period).
        if not segm-sex then
            report:start-element("gender").
    end.
    if segm-sex and first-of (t-report-tmp.sex) then do:
        report:start-element("gender").
        report:add-attr("value", get-sex(t-report-tmp.sex)).
    end.
    if det-by-dcard then
        Report:table-row(""    /* Записываем строку */
                    + "|" +        ""
                    + "|" +        string(t-report-tmp.dcard-num)
                    + "|" +        string(t-report-tmp.purchases)
                    + "|" +        string(t-report-tmp.total-sum)
                    + "|" +        string(t-report-tmp.discount)
                    + "|" +        string(t-report-tmp.averg)
        ).
    if not det-by-dcard then do:
        if segm-sex then do:
            accumulate t-report-tmp.purchases (total by t-report-tmp.sex).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.sex).
            accumulate t-report-tmp.discount  (total by t-report-tmp.sex).
            if last-of (t-report-tmp.sex) then do:
                    Report:table-row(""    /* Записываем строку */
                                + "|" +        ""
                                + "|" +        ""
                                + "|" +        string(accum total by t-report-tmp.sex t-report-tmp.purchases)
                                + "|" +        string(accum total by t-report-tmp.sex t-report-tmp.total-sum)
                                + "|" +        string(accum total by t-report-tmp.sex t-report-tmp.discount)
                                + "|" +        string(decimal(string(accum total by t-report-tmp.sex t-report-tmp.total-sum)) / decimal(string(accum total by t-report-tmp.sex t-report-tmp.purchases)))
                    ).
            end.
        end.
        else if segm-age then do:
            accumulate t-report-tmp.purchases (total by t-report-tmp.period).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.period).
            accumulate t-report-tmp.discount  (total by t-report-tmp.period).
            if last-of (t-report-tmp.period) then do:
                Report:table-row(""    /* Записываем строку */
                            + "|" +        ""
                            + "|" +        ""
                            + "|" +        string(accum total by t-report-tmp.period t-report-tmp.purchases)
                            + "|" +        string(accum total by t-report-tmp.period t-report-tmp.total-sum)
                            + "|" +        string(accum total by t-report-tmp.period t-report-tmp.discount)
                            + "|" +        string(decimal(string(accum total by t-report-tmp.period t-report-tmp.total-sum)) / decimal(string(accum total by t-report-tmp.period t-report-tmp.purchases)))
                ).
            end.
        end.
    end.
        accumulate t-report-tmp.dcard-num (count by t-report-tmp.t-object).
        accumulate t-report-tmp.purchases (total by t-report-tmp.t-object).
        accumulate t-report-tmp.total-sum (total by t-report-tmp.t-object).
        accumulate t-report-tmp.discount  (total by t-report-tmp.t-object).
        tot-purch = tot-purch + t-report-tmp.purchases.
        tot-sum   = tot-sum   + t-report-tmp.total-sum.
    if segm-sex and last-of (t-report-tmp.sex) then do:
        report:end-element("gender").
    end.
    if segm-age and last-of (t-report-tmp.period) then do:
        if not segm-sex then
            report:end-element("gender").
        report:end-element("period").
    end.
    if last-of (t-report-tmp.t-object) then do:
    if not segm-age then
        report:end-element("period").
        if det-by-obj then do:
            tmp-sred = accum total by t-report-tmp.t-object t-report-tmp.total-sum.
            tmp-sred = tmp-sred / accum total by t-report-tmp.t-object t-report-tmp.purchases.
            if segm-sex and segm-age then
                Report:table-subtotal("Итоги по объекту"  +
                                "||" + string(accum count by t-report-tmp.t-object t-report-tmp.dcard-num ) +
                                "|" + string(accum total by t-report-tmp.t-object t-report-tmp.purchases) +
                                "|" + string(accum total by t-report-tmp.t-object t-report-tmp.total-sum) +
                                "|" + string(accum total by t-report-tmp.t-object t-report-tmp.discount) +
                                "|" + string(tmp-sred)
                ).
            else
                Report:table-subtotal("Итоги по объекту"+ 
                                "|" + string(accum count by t-report-tmp.t-object t-report-tmp.dcard-num) +
                                "|" + string(accum total by t-report-tmp.t-object t-report-tmp.purchases) +
                                "|" + string(accum total by t-report-tmp.t-object t-report-tmp.total-sum) +
                                "|" + string(accum total by t-report-tmp.t-object t-report-tmp.discount) +
                                "|" + string(tmp-sred)
                ).  
        end.
        report:end-element("object").
    end.
end.
tmp-sred = accum total t-report-tmp.total-sum.
tmp-sred = tmp-sred / accum total t-report-tmp.purchases.
if segm-sex and segm-age then
    Report:table-total("Итоги"  +
                    "||" + string(accum count t-cards.dcard ) +
                    "|" + string(tot-purch) +
                    "|" + string(tot-sum) +
                    "|" + string(accum total t-report-tmp.discount) +
                    "|" + string(tmp-sred)
    ).
else
    Report:table-total("Итоги"+ 
                    "|" + string(accum count t-cards.dcard ) +
                    "|" + string(tot-purch) +
                    "|" + string(tot-sum) +
                    "|" + string(accum total t-report-tmp.discount) +
                    "|" + string(tmp-sred)
    ).  
Report:worksheet("end").
delete object Report.    
/* Преобразование XML отчета в XLS */
xslt_path = search("exe\xslt.exe").
xslt      = search("exe\segmentation.xsl").
xml_res   = string(session:temp-directory + "segment-res.xml").
os-command silent value(xslt_path + " " + xslt + " " + xml_tmp + " " + xml_res).
/*os-delete VALUE(xml_tmp).*/
define variable chExcel as com-handle.
create "Excel.Application" chExcel no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
chExcel:Visible = false.
chExcel:DisplayAlerts = false. /* Иногда выдаёт ошибку формата, но всё корректно */
chExcel:Workbooks:open(xml_res).
xls-name = string(session:temp-directory + "rep_" + replace(replace(string(now,"99.99.99 HH:MM:SS"),":","-")," ","_") + ".xls").
chExcel:ActiveWorkBook:SaveAs(xls-name,56, , , , , true).
chExcel:Visible = true.
chExcel:DisplayAlerts = true.
release object chExcel no-error.
os-delete value(xml_res).