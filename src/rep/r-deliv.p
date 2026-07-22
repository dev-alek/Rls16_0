using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
block-level on error undo, throw.
/*

$Revision: 121cc63762c0, 1070, rls $
$Author: EShklyar $
$Date: Fri Oct 06 18:35:02 2017 +0300 $
$Workfile: r-deliv.p $
$Archive: rep/r-deliv.p $

Процедура формирования отчёта по продажам

Автор: Кабоев Валерий Асланович
Дата создания: 19/09/12
Author: Kaboev Valeriy
Creation date: 19/09/12

*/
define variable vss-revision    as character no-undo init "$5183 $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 06 18:35:02 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-deliv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-deliv.p $":U .
define variable vss-description as character no-undo init "Процедура формирования отчёта по продажам":u .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/cur-time.i }
{ str/trdcalib.i }
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */



define input parameter parparentproc   as    handle  no-undo.
define input parameter p-start-hour    as    integer no-undo.
define input parameter p-start-min     as    integer no-undo.
define input parameter p-end-hour      as    integer no-undo.
define input parameter p-end-min       as    integer no-undo. 

define variable stat            as character no-undo. /*список статусов документов */
define variable ii as integer no-undo.
define variable customer-name   as character no-undo init "".
define variable Report          as class ReportXml no-undo. /* Переменная под класс */
define variable xml_tmp         as character no-undo. /*путь к временному файлу*/
define variable xslt-path       as character no-undo. /*путь к шаблону */
define variable rep-out-unit    as class rep-out no-undo. /*экземпляр класса формирования документа отчёта */
define variable objcts          as character no-undo. /*список объектов*/
define variable in-time-in      as character no-undo. /* для получения атрибута времени доставки */
define variable gdscode         as integer   no-undo. /* для получения gds-code */
define variable goods-flag      as integer   no-undo init 0.  /*флаг соответствия условиям выборки по товарам */
define variable chk-find        as integer   no-undo.   /*флаг заполненности t-report-tmp*/
define variable p-value         as character no-undo .   /*сюда заносим значение считанной переменной */
define variable p-type          as character no-undo .   /*за каким-то лесом используется с p-value (видимо, тип переменной) */
define variable tmp-date        as character no-undo.
define new shared temp-table   t-report-tmp no-undo
    field   deliv-date  as date         format "99.99.9999"
    field   deliv-time  as character    format "X(16)":u
    field   docum-num   like trn-doc.doc-code
    field   docum-stat  like trn-doc.status_
    field   deliv-addr  as character    format "X(255)":u
    field   client-name like trn-doc.cli-name
    field   cont-name   as character    format "X(100)":u
    field   cont-phone  as character    format "X(50)":u
    field   obj-deprtmt as character    format "x(20)":u    
    field   nakl-summ   as decimal      format "->>>,>>>,>>9.99"
    field   deliv-summ  as decimal      format "->>>,>>>,>>9.99"
    field   pos-quan    like trn-doc.cli-qnty
    field   cargo-dtrm  as character    format "X(255)":u
    field   prim        like trn-doc.ps
.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
/* ************************  Function Implementations ***************** */
function in-time-period returns logical  /*Сравнение временных отметок */
        ( input del-time as character ):
    define variable start-param  as integer no-undo.
    define variable end-param    as integer no-undo.
    define variable start-period as integer no-undo.
    define variable end-period   as integer no-undo.
    if del-time = ? or del-time = "" then return yes.
    
    start-param = p-start-hour * 60 + p-start-min.
    end-param = p-end-hour * 60 + p-end-min.
    start-period = int(entry(1, entry(1, del-time, "-"), ":")) * 60 + int(entry(2, entry(1, del-time, "-"), ":")).
    end-period = int(entry(1, entry(2, del-time, "-"), ":")) * 60 + int(entry(2, entry(2, del-time, "-"), ":")).
    
    
    if start-period >= start-param  and start-period <= end-param then return yes.
    if end-period >= start-param and end-period <= end-param then return yes.
    if start-period <= start-param and end-period >= end-param then return yes.
    return no.
end function.

procedure fill-table:
    define input parameter trn-doc-code as character no-undo.
    define variable dost as character no-undo.
    define variable nodate  as logical no-undo init no.
    define variable data-vyp as character no-undo.
    dost = "no".
    { str/tdat-val.i trn-doc.doc-code {&trdcattr-ord_dl}       dost p-type }
    if dost <> "yes" then return.
    for first trn-doc no-lock where trn-doc.doc-code = trn-doc-code:
        p-value = "".
        in-time-in = "".
        { str/tdat-val.i trn-doc.doc-code {&trdcattr-delivery-time}    in-time-in p-type }
        { str/tdat-val.i trn-doc.doc-code {&trdcattr-delivery-date}    p-value    p-type }
        { str/tdat-val.i trn-doc.doc-code {&trdcattr-frsrv-date}       data-vyp   p-type }
        
        if trn-doc.status_ = {&fact} then do:
            if p-value = ? or p-value = "" or p-value = "?" then return.
        end.
        
        if p-value = "" or p-value = "?" or p-value = ? then do:
            p-value = string(trn-doc.doc-date). /*если не задано время доставки, то за время доставки берётся время формирования документа */
            nodate = yes.
        end.    
        if  (not nodate and x-date-start <= date(p-value) 
        and x-date-end >= date(p-value)
        and in-time-period (in-time-in))
        
        or (not nodate and x-date-start <= date(p-value)
        and x-date-end >= date(p-value)
        and in-time-in = ? )
        
        or (not nodate and x-date-start <= date(p-value) 
        and x-date-end >= date(p-value)
        and in-time-in = "")
        
        or (not nodate and x-date-start <= date(p-value) 
        and x-date-end >= date(p-value)
        and in-time-in = "?")
        
/*        or (not nodate and x-date-start <= date(p-value)*/
/*        and x-date-end >= date(p-value)                 */
/*        and in-time-in = "00:00-00:00")                 */
        
        or (nodate and x-date-start <= date(data-vyp)
        and x-date-end >= date(data-vyp) and in-time-period (in-time-in))
        
        or (nodate and x-date-start <= date(data-vyp) 
        and x-date-end >= date(data-vyp) and in-time-in = ?)
        
        or (nodate and x-date-start <= date(data-vyp) 
        and x-date-end >= date(data-vyp) and in-time-in = "")
        
        or (nodate and x-date-start <= date(data-vyp) 
        and x-date-end >= date(data-vyp) and in-time-in = "?")
        
/*        or (nodate and x-date-start <= date(p-value)                    */
/*        and x-date-end >= date(p-value) and in-time-period (in-time-in))*/
/*                                                                        */
/*        or (nodate and x-date-start <= date(p-value)                    */
/*        and x-date-end >= date(p-value) and in-time-in = ?)             */
/*                                                                        */
/*        or (nodate and x-date-start <= date(p-value)                    */
/*        and x-date-end >= date(p-value) and in-time-in = "")            */
        then do:
            goods-flag = 0.
            if x-SelectGood <> 1 then do:
                for each doc-line where doc-line.doc-code = trn-doc.doc-code no-lock
                    :
                    { gbl/gds-code.i
                      doc-line.artic
                      doc-line.prod-type
                      doc-line.prod-code
                      gdscode
                      no-error
                    } /*получение gds-code из атрибутов товара */
                    for first gds-list where gds-list.gds-code = gdscode
                    :
                        goods-flag = 1.
                    end.
                end.        /*for each doc-line where doc-line.doc-code = trn-doc.doc-code*/
            end.
            else
                goods-flag = 1
            .
            if goods-flag = 1 /*если условия соблюдены */
            then do:
                create t-report-tmp.
                    p-value = "".
                    { str/tdat-val.i trn-doc.doc-code {&trdcattr-delivery-date}       p-value p-type }
                    t-report-tmp.deliv-date = date(p-value).
                    { str/tdat-val.i trn-doc.doc-code {&trdcattr-delivery-time}       p-value p-type }
                    if p-value = ? or p-value = "" then p-value = "Отсутствует".
                    t-report-tmp.deliv-time = p-value.
                    
                    p-value = trn-doc.doc-code.
                    if p-value = ? then p-value = "".
                    t-report-tmp.docum-num = p-value.
                    
                    p-value = trn-doc.status_.
                    if p-value = ? then p-value = "".
                    t-report-tmp.docum-stat = p-value.

                    { str/tdat-val.i trn-doc.doc-code {&trdcattr-ord_adr}       p-value p-type }
                    if p-value = ? then p-value = "".
                    t-report-tmp.deliv-addr = p-value.

                    p-value = trn-doc.cli-name.
                    if p-value = ? then p-value = "".
                    t-report-tmp.client-name = p-value.

                    { str/tdat-val.i trn-doc.doc-code {&trdcattr-ord_contact}       p-value p-type }
                    if p-value = ? then p-value = "".
                    t-report-tmp.cont-name = p-value.

                    { str/tdat-val.i trn-doc.doc-code {&trdcattr-ord_phone}       p-value p-type }
                    if p-value = ? then p-value = "".
                    t-report-tmp.cont-phone = p-value.
                    
                    p-value = trn-doc.obj-type + string(trn-doc.obj-code).
                    if p-value = ? then p-value = "".
                    t-report-tmp.obj-deprtmt = p-value.
                        
                    if trn-doc.tot-fact <> ? then t-report-tmp.nakl-summ = trn-doc.tot-fact - trn-doc.discnt-rubl.
                    else t-report-tmp.nakl-summ = 0.
                    
                    { str/tdat-val.i trn-doc.doc-code {&trdcattr-deliv}       p-value p-type }
                    if p-value = ? then p-value = "0".
                    t-report-tmp.deliv-summ = decimal(p-value).
                    
					{ str/tdat-val.i trn-doc.doc-code {&trdcattr-qntyplace}       p-value p-type }
                    if p-value = ? then p-value = "0".
					t-report-tmp.pos-quan = integer(p-value).
                    
                    { str/tdat-val.i trn-doc.doc-code {&trdcattr-cargo-desc}       p-value p-type }
                    if p-value = ? then p-value = "".
                    t-report-tmp.cargo-dtrm = p-value.
                    
                    if trn-doc.ps <> ? then t-report-tmp.prim = trn-doc.ps.
                    else t-report-tmp.prim = "".

            end.
        end.     /* if  x-date-start <= date(p-value)... */ 
    end.
end.

for first g#customer:
    customer-name = {&all}.
end.
stat = {&permitted} + "," + {&inquiry} + "," + {&wayb} + "," + {&fact} + "," + {&ord-close}.
if X-SelectObject <> {&all} then do:
    for each obj-list /*править*/
    :
        if customer-name = {&all} then do:
            for each g#customer
            :
                do ii = 1 to 5:
                    for each trn-doc where trn-doc.obj-type = obj-list.obj-type     /*проходим по всем заданным объектам */
                                       and trn-doc.obj-code = obj-list.obj-code
                                       and trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} /*тип накладной - внешняя расходная */
                                       and trn-doc.cli-type = g#customer.obj-type  /* проходим по контрагентам */
                                       and trn-doc.cli-code = g#customer.obj-code
                                       and trn-doc.status_ = entry(ii, stat, ",") /* не закрыта */
                                       no-lock
                    :
                        run fill-table (trn-doc.doc-code).
                    end.     /*for each trn-doc*/
                end.
            end.     /* for each g#customer */
        end.   /*if*/
        else do:
            do ii = 1 to 5:
                for each trn-doc where trn-doc.obj-type = obj-list.obj-type     /*проходим по всем заданным объектам */
                                   and trn-doc.obj-code = obj-list.obj-code
                                   and trn-doc.doc-type = {&expense} /*тип накладной - расходная */
                                   and trn-doc.status_ = entry(ii, stat, ",") /* не закрыта */
                                   no-lock 
                :
                    run fill-table (trn-doc.doc-code).
                end.     /*for each trn-doc*/
            end.
        end.   /*else*/
    end.     /*for each obj-list*/
end.
else do:
    if customer-name = {&all} then do:
        for each g#customer
        :
            do ii = 1 to 5:
                for each trn-doc where trn-doc.doc-type = {&expense} /*тип накладной - расходная */
                                   and trn-doc.cli-type = g#customer.obj-type  /* проходим по контрагентам */
                                   and trn-doc.cli-code = g#customer.obj-code
                                   and trn-doc.status_ = entry(ii, stat, ",") /* не закрыта */
                                   no-lock 
                :
                    run fill-table (trn-doc.doc-code).
                end.     /*for each trn-doc*/
            end.
        end.     /* for each g#customer */
    end.    /*if*/
    else do:
        do ii = 1 to 5:
            for each trn-doc where trn-doc.doc-type = {&expense} /*тип накладной - расходная */
                               and trn-doc.status_ = entry(ii, stat, ",") /* не закрыта */
                               no-lock 
            :
                run fill-table (trn-doc.doc-code).
            end.     /*for each trn-doc*/
        end.
    end.    /*else*/
end.
/* если нет записей */
for first t-report-tmp no-lock:
  chk-find = 1.
end.
if chk-find = 0 then do:
    message "На указанный период не найдено документов." view-as alert-box.
    return.
end.
/*сбор объектов для записи в шапку отчёта*/
for each t-report-tmp break by t-report-tmp.obj-deprtmt:
    if last-of (t-report-tmp.obj-deprtmt) then
    objcts = objcts + t-report-tmp.obj-deprtmt + ", ".
end.
objcts = right-trim(objcts,", ").
/*формируем xml */
xml_tmp = string(session:temp-directory + "report-tmp.xml"). /* путь к временному xml файлу */
Report = new ReportXml(xml_tmp).
Report:worksheet("Лист 1").
Report:worksheet-header("start").   /* Начало шапки отчета */
Report:worksheet-header("Отчёт по доставке товара.").
Report:worksheet-header("За период с " + string(x-date-start,"99/99/9999") + " по " + string(x-date-end,"99/99/9999")).
Report:worksheet-header("Время: c " + string(p-start-hour,"99") + ":" + string(p-start-min,"99") + " до " + string(p-end-hour,"99") + ":" + string(p-end-min,"99")).
Report:worksheet-header("Выбор объектов: " + objcts).
Report:worksheet-header("Дата печати: " + string(cur-time-date())).
Report:worksheet-header("end").     /*Конец шапки отчета*/ 
Report:table-columns("60,60,60,60,150,120,110,90,90,70,70,60,110,140").    /* Начало таблицы, задаем размеры колонок */
Report:table-types = "String,String,String,String,String,String,String,String,String,Number,Number,Number,String,String".   /* Типы данных в таблице */
Report:table-header("Дата доставки|Время доставки|Номер документа|Статус документа|Адрес доставки|Наименование клиента|Контактное лицо|Контактный телефон|Подразделение|Сумма по накладной с учетом скидок|Сумма доставки|Количество мест|Описание груза|Примечание","60","4").    /* Шапка таблицы */ 

for each t-report-tmp no-lock by t-report-tmp.deliv-date:
    tmp-date = "Отсутствует".
    if t-report-tmp.deliv-date <> ? then tmp-date = string(t-report-tmp.deliv-date).
    Report:table-row(   tmp-date
         + "|" +        t-report-tmp.deliv-time 
         + "|" +        t-report-tmp.docum-num  
         + "|" +        t-report-tmp.docum-stat 
         + "|" +        t-report-tmp.deliv-addr 
         + "|" +        t-report-tmp.client-name
         + "|" +        t-report-tmp.cont-name  
         + "|" +        t-report-tmp.cont-phone 
         + "|" +        t-report-tmp.obj-deprtmt
         + "|" +        left-trim(string(t-report-tmp.nakl-summ, "->>>>>>>>9.99"))
         + "|" +        left-trim(string(t-report-tmp.deliv-summ, "->>>>>>>>9.99"))
         + "|" +        string(t-report-tmp.pos-quan)
         + "|" +        t-report-tmp.cargo-dtrm
         + "|" +        t-report-tmp.prim
     ).

     accumulate t-report-tmp.nakl-summ  (total).
     accumulate t-report-tmp.deliv-summ (total).
     accumulate t-report-tmp.pos-quan   (total).
end.
 Report:table-total("Итоги"
     + "|" +        ""
     + "|" +        ""
     + "|" +        ""
     + "|" +        ""
     + "|" +        ""
     + "|" +        ""
     + "|" +        ""
     + "|" +        ""
     + "|" +        left-trim(string(accum total t-report-tmp.nakl-summ, "->>>,>>>,>>9.99"))
     + "|" +        left-trim(string(accum total t-report-tmp.deliv-summ, "->>>,>>>,>>9.99"))
     + "|" +        string(accum total t-report-tmp.pos-quan)
     + "|" +        ""
     + "|" +        ""
 ).
report:worksheet("end").
delete object Report. 
xslt-path = search("exe\template.xsl").
rep-out-unit = new rep-out ().
rep-out-unit:office(xml_tmp, xslt-path).
