using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
block-level on error undo, throw.
/*------------------------------------------------------------------------
    File        : r-activ.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : vkaboev
    Created     : Wed Sep 19 09:53:47 MSD 2012
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define input parameter parparentproc  as	handle 	no-undo.
define input parameter det-mode       as	integer no-undo.
define input parameter det-by-obj     as    logical no-undo.
define input parameter dcard-mode 	  as	integer no-undo.
define input parameter fill-days      as    integer no-undo.

define variable vss-revision    as character no-undo init "$Revision: 6a63bd75f17f, 234, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jul 28 13:39:50 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-activ.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-activ.p $":U .
define variable vss-description as character no-undo init "Отчет Итоги по дисконтным картам" .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/cur-time.i }
{ cmp/dc-list.i dc-list def "new shared" }

define variable flag-pokupki    as logical  no-undo init no.
define variable chk-find        as integer  no-undo init 0.
define variable flag-sleep      as integer  no-undo init 0.
define variable acc-count       as decimal  no-undo init 0.
define variable acc-totsum      as decimal  no-undo init 0.
define variable acc-discnt      as decimal  no-undo init 0.
define variable acc-averg       as decimal  no-undo init 0.
define variable Report          as class ReportXml no-undo. /* Переменная под класс */
define variable rep-out-unit    as class rep-out no-undo. /*экземпляр класса формирования документа отчёта */
define variable xml_tmp         as character no-undo. /*путь к временному файлу*/
define variable xslt-path       as character no-undo. /*путь к шаблону */
define variable tmp-kli         as integer  no-undo init 0.
define variable tmp-purch       as decimal  no-undo init 0.
define variable tmp-summ        as decimal  no-undo init 0.
define variable tmp-disc        as decimal  no-undo init 0.
define variable tmp-aver        as decimal  no-undo init 0.
define variable objcts          as character no-undo. /*список объектов*/
define variable rowcnt          as integer no-undo.    
define new shared temp-table   t-report-tmp no-undo
            field   cli-status  as integer      format ">9":u
            field   dcard-num   like ub.dis-card.d-card
            field   cli-name    like ub.clients.obj-name
            field   purch-count as integer      format ">>>>>9":u
            field   total-sum   as decimal      format ">>>>>>>>>9":u
            field   discount    as decimal      format ">>>>>>>>9":u
            field   averg       as decimal      format ">>>>>>>>9":u
            field   obj-code    like ub.clients.obj-code
            field   obj-type    like ub.clients.obj-type
            index   ind-prim  IS WORD-INDEX  dcard-num 
            index   ind-status  cli-status
            index   ind-obj-code obj-code
            index   ind-obj-type obj-type
            .

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
/* ************************  Function Implementations ***************** */
function get-status returns character (input p-snum as integer):
    case p-snum:
        when 1 then return "Новые".
        when 2 then return "Новые (активные)".
        when 3 then return "Постоянные (активные)".
        when 4 then return "Спящие".
        when 5 then return "Отток".
    end case.
    return "Остальные".
end.

procedure write-tmp :
    define input parameter p-type as integer no-undo. /* статус */
    define input parameter p-card as character no-undo. 
    define input parameter p-code like clients.obj-code no-undo. 
    define input parameter p-count as decimal  no-undo. 
    define input parameter p-tots  as decimal  no-undo. 
    define input parameter p-discnt as decimal no-undo. 
    define input parameter p-averg  as decimal no-undo. 
    define input parameter p-o-type like ub.clients.obj-type.
    define input parameter p-o-code like ub.clients.obj-code.
    define variable go-write as logical no-undo init yes.
    define variable v-pcnt as decimal no-undo init 0.
    define variable v-tsum as decimal no-undo init 0.
    define variable v-dsct as decimal no-undo init 0.
    define variable v-avrg as decimal no-undo init 0.
    for first clients where clients.obj-code = p-code and clients.obj-type = {&prs} no-lock: 
        if not det-by-obj then do:
            for first t-report-tmp where t-report-tmp.dcard-num = p-card and t-report-tmp.obj-code = p-o-code and t-report-tmp.obj-type = p-o-type:
                case p-type:
                    when 1 then go-write = no.
                    when 2 then if t-report-tmp.cli-status = 1 then delete t-report-tmp.
                    when 3 then do:
                        if t-report-tmp.cli-status > 3 then delete t-report-tmp.
                        else if t-report-tmp.cli-status = 3 then do:
                            v-pcnt = purch-count + p-count.
                            v-tsum = total-sum + p-tots.
                            v-dsct = discount + p-discnt.
                            v-avrg = v-tsum / v-pcnt.
                            assign
                                t-report-tmp.purch-count = v-pcnt
                                t-report-tmp.total-sum   = v-tsum
                                t-report-tmp.discount    = v-dsct
                                t-report-tmp.averg       = v-avrg
                            .
                            go-write = no.
                        end.
                    end.
                    when 4 then if t-report-tmp.cli-status = 5 then delete t-report-tmp.
                    when 5 then go-write = no.
                end case.
            end.
        end.
        if go-write then do:
            create t-report-tmp.
            assign
                t-report-tmp.cli-status  = p-type
                t-report-tmp.dcard-num   = replace(p-card,"|","/")
                t-report-tmp.cli-name    = replace(clients.obj-name,"|","/")
                t-report-tmp.purch-count = p-count
                t-report-tmp.total-sum   = p-tots 
                t-report-tmp.discount    = p-discnt
                t-report-tmp.averg       = p-averg
                t-report-tmp.obj-code    = p-o-code
                t-report-tmp.obj-type    = p-o-type
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
        
for each obj-list:
    objcts = objcts + obj-list.obj-type + string(obj-list.obj-code) + ", ".
    for each dc-list where dc-list.cli-type = {&prs}:
            acc-count  = 0.
            acc-totsum = 0.
            acc-discnt = 0.
            acc-averg  = 0. 
            flag-sleep = 0.
            for each chk-doc where chk-doc.obj-type = obj-list.obj-type 
            and chk-doc.obj-code = obj-list.obj-code 
            and chk-doc.d-card = dc-list.d-card 
            and chk-doc.tot-doc >= 0 
            no-lock:   
                 if chk-doc.chk-date >= date(integer(x-date-start) - fill-days) and chk-doc.chk-date <= x-date-end then do:  
                    if chk-doc.chk-date >= x-date-start then do:
                        if x-selectgood = 1 then do:
                            flag-sleep = 1.
                            acc-count  = acc-count  + 1.
                            acc-totsum = acc-totsum + chk-doc.tot-doc.
                            acc-discnt = acc-discnt + chk-doc.discnt.
                        end.
                        else do:
                            for each gds-list:
                                for each chk-gds where chk-gds.doc-code = chk-doc.doc-code 
                                no-lock:
                                    for first bar-code where  bar-code.b-code = chk-gds.b-code 
                                    no-lock:
                                        if bar-code.gds-code = gds-list.gds-code then do:
                                            acc-totsum = acc-totsum + chk-gds.price-base * chk-gds.doc-qnty.
                                            acc-discnt = acc-discnt + chk-gds.discnt.
                                            acc-count  = acc-count  + 1.
                                            flag-sleep = 1.
                                        end.
                                    end.
                                end.
                            end.
                        end.
                    end.
                    else do:
                        if x-selectgood = 1 then do:
                            flag-sleep = 2.
                        end.
                        else do:
                            for each gds-list:
                                for each chk-gds where chk-gds.doc-code = chk-doc.doc-code 
                                no-lock:
                                    for first bar-code where  bar-code.b-code = chk-gds.b-code 
                                    no-lock:
                                        if bar-code.gds-code = gds-list.gds-code then do:
                                            flag-sleep = 2.
                                        end.
                                    end.
                                end.
                            end.
                        end.
                    end.
                end.
            end.
            acc-averg  = acc-averg  + acc-totsum / acc-count.
            if dc-list.issue-date >= x-date-start and dc-list.issue-date <= x-date-end and flag-sleep = 1 then /*новые активные */
                run write-tmp (input 2, dc-list.d-card, dc-list.cli-code, acc-count, acc-totsum, acc-discnt, acc-averg, obj-list.obj-type, obj-list.obj-code).
            else do:
                if flag-sleep = 1 then /*действующие активные */
                    run write-tmp (input 3, dc-list.d-card, dc-list.cli-code, acc-count, acc-totsum, acc-discnt, acc-averg, obj-list.obj-type, obj-list.obj-code). 
                else if flag-sleep = 2 then /*спящие */
                    run write-tmp (input 4, dc-list.d-card, dc-list.cli-code, 0, 0, 0, 0, obj-list.obj-type, obj-list.obj-code).
            end.
            
            if flag-sleep = 0 then do:
                if dc-list.issue-date >= x-date-start and dc-list.issue-date <= x-date-end then do:
                    /*новы неактивные */
                    run write-tmp (input 1, dc-list.d-card, dc-list.cli-code, 0, 0, 0, 0, obj-list.obj-type, obj-list.obj-code).
                end.
                else if dc-list.issue-date <= x-date-start then do:
                    /*отток */
                    for first chk-doc where chk-doc.d-card = dc-list.d-card
                    and chk-doc.obj-type = obj-list.obj-type 
                    and chk-doc.obj-code = obj-list.obj-code  no-lock:
                        run write-tmp (input 5, dc-list.d-card, dc-list.cli-code, 0, 0, 0, 0, obj-list.obj-type, obj-list.obj-code).
                    end.
                end.
            end.
            
    end.
end.
objcts = right-trim(objcts,", ").
/*
for each obj-list where obj-list.obj-type = {&shop}:    
    for each dc-list where dc-list.cli-type = {&prs} and dc-list.issue-code = obj-list.obj-code:
            
    end.
end.
*/

for first t-report-tmp no-lock:
  chk-find = 1.
end.

if chk-find = 0 then do:
    message "По текущим дисконтным картам не найдено ни одной покупки." view-as alert-box.
    return.
end.


/*формируем xml */
/*общая часть для всех видов отчёта */
xml_tmp = string(session:temp-directory + "report-tmp.xml"). /* путь к временному xml файлу */
Report = new ReportXml(xml_tmp).
Report:add-element("detmode",string(det-mode)).
Report:worksheet("Лист 1").    

for first t-report-tmp:
    if not available t-report-tmp then return.
end.
if det-mode > 0 then do: /*детализация по картам*/
    Report:worksheet-header("start").   /* Начало шапки отчета */
    Report:worksheet-header("Активность клиентов (детализированная)").
    Report:worksheet-header("За период с " + string(x-date-start,"99/99/9999") + " по " + string(x-date-end,"99/99/9999")).
    Report:worksheet-header("Выбор объектов: " + objcts).
    Report:worksheet-header("Дата печати: " + string(cur-time-date())).
    Report:worksheet-header("end").     /*Конец шапки отчета*/
    Report:table-columns("150,100,140,110,110,110,110").    /* Начало таблицы, задаем размеры колонок */
    Report:table-types = "String,String,String,Number,Number,Number,Number".   /* Типы данных в таблице */
    Report:table-header("Статус клиента$|№ ДК$|ФИО$|Количество покупок$|Сумма покупок$|Скидка по ДК$|Средняя покупка","40","4").    /* Шапка таблицы */ 
    if not det-by-obj then do:
        report:start-element("obj-code").
        report:add-attr("value","").
        for each t-report-tmp break by t-report-tmp.cli-status:
            if first-of (t-report-tmp.cli-status) then do:
                report:start-element("status").
                report:add-attr("value",get-status(t-report-tmp.cli-status)).
                rowcnt = 0.
            end.
            report:table-row(""
              + "|" +        t-report-tmp.dcard-num
              + "|" +        t-report-tmp.cli-name
              + "|" +        string(t-report-tmp.purch-count)
              + "|" +        string(t-report-tmp.total-sum)
              + "|" +        string(t-report-tmp.discount)
              + "|" +        string(t-report-tmp.averg)
            ).  
            accumulate t-report-tmp.dcard-num (count).
            accumulate t-report-tmp.purch-count (total).
            accumulate t-report-tmp.total-sum (total).
            accumulate t-report-tmp.discount (total).
            accumulate t-report-tmp.averg (total).
            accumulate t-report-tmp.dcard-num (count by t-report-tmp.cli-status).
            accumulate t-report-tmp.purch-count (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.discount (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.averg (total by t-report-tmp.cli-status).
            rowcnt = rowcnt + 1.
            if last-of (t-report-tmp.cli-status) then do:
                report:start-element("subt").
                report:add-attr("merg",string(rowcnt)).
                report:table-subtotal(""  
                  + "|" +  string(accum count by t-report-tmp.cli-status t-report-tmp.dcard-num )
                  + "|" +  ""
                  + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.purch-count )
                  + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.total-sum )
                  + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.discount )
                  + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.averg )
                    ).
                    report:end-element("subt").
                report:end-element("status").
            end.
        end.
        report:end-element("obj-code").
        report:table-total("Итоги"  
                          + "|" +  string(accum count t-report-tmp.dcard-num )
                          + "|" +  ""
                          + "|" +  string(accum total t-report-tmp.purch-count )
                          + "|" +  string(accum total t-report-tmp.total-sum )
                          + "|" +  string(accum total t-report-tmp.discount )
                          + "|" +  string(accum total t-report-tmp.averg )
                            ).
    end.    /*if not detbyobj*/
    else do:
        for each t-report-tmp break by t-report-tmp.obj-type by t-report-tmp.obj-code by t-report-tmp.cli-status:
            if first-of (t-report-tmp.obj-code) then do:
                report:start-element("obj-code").
                Report:add-attr("value", "Выбор объекта: " + t-report-tmp.obj-type + string(t-report-tmp.obj-code)).
            end.
            if first-of (t-report-tmp.cli-status) then do:
                report:start-element("status").
                report:add-attr("value",get-status(t-report-tmp.cli-status)).
                rowcnt = 0.
            end.
            report:table-row(""
              + "|" +        t-report-tmp.dcard-num
              + "|" +        t-report-tmp.cli-name
              + "|" +        string(t-report-tmp.purch-count)
              + "|" +        string(t-report-tmp.total-sum)
              + "|" +        string(t-report-tmp.discount)
              + "|" +        string(t-report-tmp.averg)
            ).  
            accumulate t-report-tmp.dcard-num (count by t-report-tmp.obj-code ).
            accumulate t-report-tmp.purch-count (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.discount (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.averg (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.dcard-num (count).
            accumulate t-report-tmp.purch-count (total).
            accumulate t-report-tmp.total-sum (total).
            accumulate t-report-tmp.discount (total).
            accumulate t-report-tmp.averg (total).
            accumulate t-report-tmp.dcard-num (count by t-report-tmp.cli-status).
            accumulate t-report-tmp.purch-count (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.discount (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.averg (total by t-report-tmp.cli-status).
            rowcnt = rowcnt + 1.
            if last-of (t-report-tmp.cli-status) then do:
                report:start-element("subt").
                report:add-attr("merg",string(rowcnt)).
                report:table-subtotal(""  
                                      + "|" +  string(accum count by t-report-tmp.cli-status t-report-tmp.dcard-num )
                                      + "|" +  ""
                                      + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.purch-count )
                                      + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.total-sum )
                                      + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.discount )
                                      + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.averg )
                                        ).    
                report:end-element("subt").
                report:end-element("status").   
            end.
            if last-of (t-report-tmp.obj-code) then do:
                report:table-subtotal(""  
                                      + "|" +  string(accum count by t-report-tmp.obj-code t-report-tmp.dcard-num )
                                      + "|" +  ""
                                      + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.purch-count )
                                      + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.total-sum )
                                      + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.discount )
                                      + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.averg )
                                        ).       
                report:end-element("obj-code").         
                /*report:table-total("Итоги по объекту" 
                                   + "|" +  string(accum count by t-report-tmp.obj-code t-report-tmp.dcard-num )
                                   + "|" +  ""
                                   + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.purch-count )
                                   + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.total-sum )
                                   + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.discount )
                                   + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.averg )).*/
            end.
        end.
        report:table-total("Итоги" 
                           + "|" +  string(accum count t-report-tmp.dcard-num )
                           + "|" +  ""
                           + "|" +  string(accum total t-report-tmp.purch-count )
                           + "|" +  string(accum total t-report-tmp.total-sum )
                           + "|" +  string(accum total t-report-tmp.discount )
                           + "|" +  string(accum total t-report-tmp.averg )).
    end.
end. /*  if detmode > 0 */
else do:
    Report:worksheet-header("start").   /* Начало шапки отчета */
    Report:worksheet-header("Активность клиентов").
    Report:worksheet-header("За период с " + string(x-date-start,"99/99/9999") + " по " + string(x-date-end,"99/99/9999")).
    Report:worksheet-header("Выбор объектов: " + objcts).
    Report:worksheet-header("Дата печати: " + string(cur-time-date())).
    Report:worksheet-header("end").     /*Конец шапки отчета*/
    Report:table-columns("150,100,110,110,110,110").    /* Начало таблицы, задаем размеры колонок */
    Report:table-types = "String,String,Number,Number,Number,Number".   /* Типы данных в таблице */
    Report:table-header("Статус клиента|Количество клиентов|Количество покупок|Сумма покупок|Скидка по ДК|Средняя покупка","40","4").    /* Шапка таблицы */ 
    if not det-by-obj then do:
        report:start-element("obj-code").
        report:add-attr("value","").
        for each t-report-tmp break by t-report-tmp.cli-status:
            accumulate t-report-tmp.dcard-num (count).
            accumulate t-report-tmp.purch-count (total).
            accumulate t-report-tmp.total-sum (total).
            accumulate t-report-tmp.discount (total).
            accumulate t-report-tmp.averg (total).
            tmp-kli = tmp-kli + 1.
            tmp-purch = tmp-purch + t-report-tmp.purch-count.
            tmp-summ = tmp-summ + t-report-tmp.total-sum.
            tmp-disc = tmp-disc + t-report-tmp.discount.
            tmp-aver = tmp-aver + t-report-tmp.averg.
            if last-of (t-report-tmp.cli-status) then do:
                report:start-element("status").
                report:table-row(get-status(t-report-tmp.cli-status)
                + "|" +        string(tmp-kli)
                + "|" +        string(tmp-purch)
                + "|" +        string(tmp-summ)
                + "|" +        string(tmp-disc)
                + "|" +        string(tmp-aver)
                ).
                tmp-kli   = 0.
                tmp-purch = 0.
                tmp-summ  = 0.
                tmp-disc  = 0.
                tmp-aver  = 0.
                report:end-element("status").
            end.
        end.
        report:end-element("obj-code").
        report:table-total("Итоги|" + string(accum count t-report-tmp.dcard-num ) + "|" + string(accum total t-report-tmp.purch-count ) + "|" +  string(accum total t-report-tmp.total-sum )
 + "|" +  string(accum total t-report-tmp.discount )   
 + "|" +  string(accum total t-report-tmp.averg )      
                            ).
    end.    /*if not detbyobj*/
    else do:
        for each t-report-tmp break by t-report-tmp.obj-type by t-report-tmp.obj-code by t-report-tmp.cli-status:
            if first-of (t-report-tmp.obj-code) then do:
                report:start-element("obj-code").
                Report:add-attr("value", "Выбор объекта: " + t-report-tmp.obj-type + string(t-report-tmp.obj-code)).
            end.
            
            tmp-kli = tmp-kli + 1.
            tmp-purch = tmp-purch + t-report-tmp.purch-count.
            tmp-summ = tmp-summ + t-report-tmp.total-sum.
            tmp-disc = tmp-disc + t-report-tmp.discount.
            tmp-aver = tmp-aver + t-report-tmp.averg.
            accumulate t-report-tmp.dcard-num (count by t-report-tmp.obj-code ).
            accumulate t-report-tmp.purch-count (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.discount (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.averg (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.dcard-num (count).
            accumulate t-report-tmp.purch-count (total).
            accumulate t-report-tmp.total-sum (total).
            accumulate t-report-tmp.discount (total).
            accumulate t-report-tmp.averg (total).
            if last-of (t-report-tmp.cli-status) then do:
                report:start-element("status").
                report:table-row(get-status(t-report-tmp.cli-status)
                + "|" +        string(tmp-kli)
                + "|" +        string(tmp-purch)
                + "|" +        string(tmp-summ)
                + "|" +        string(tmp-disc)
                + "|" +        string(tmp-aver)
                ).
                tmp-kli   = 0.
                tmp-purch = 0.
                tmp-summ  = 0.
                tmp-disc  = 0.
                tmp-aver  = 0.
                report:end-element("status").
            end.
            if last-of (t-report-tmp.obj-code) then do:
                report:table-subtotal("Итоги по объекту" 
                                   + "|" +  string(accum count by t-report-tmp.obj-code  t-report-tmp.dcard-num )
                                   + "|" +  string(accum total by t-report-tmp.obj-code  t-report-tmp.purch-count )
                                   + "|" +  string(accum total by t-report-tmp.obj-code  t-report-tmp.total-sum )
                                   + "|" +  string(accum total by t-report-tmp.obj-code  t-report-tmp.discount )
                                   + "|" +  string(accum total by t-report-tmp.obj-code  t-report-tmp.averg )
                                  ).
                report:end-element("obj-code").                  
            end.
        end.
        report:table-total("Итоги" 
                   + "|" +  string(accum count t-report-tmp.dcard-num )
                   + "|" +  string(accum total t-report-tmp.purch-count )
                   + "|" +  string(accum total t-report-tmp.total-sum )
                   + "|" +  string(accum total t-report-tmp.discount )
                   + "|" +  string(accum total t-report-tmp.averg )).
    end.    /*else*/
end.
report:worksheet("end").
delete object Report. 
xslt-path = search("exe\activ.xsl").
rep-out-unit = new rep-out ().
rep-out-unit:office(xml_tmp, xslt-path). 
















