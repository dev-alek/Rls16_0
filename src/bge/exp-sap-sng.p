block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : exp-sap-eec.p
    Purpose     : Передача данных в SAP СНГ

    Syntax      :

    Description : Этой процедуре выдаётся объект и смена с датой

    Author(s)   : SKiryxin
    Created     : Mon Dec 10 12:01:39 MSK 2012
    Notes       :
        
    $Revision: aea5316774be, 0, rls $
    $Author: expertek $
    $Date: Mon Jan 27 18:27:46 2014 +0400 $
    $Workfile: exp-sap-sng.p $
    $Archive: bge/exp-sap-sng.p $
    
  ----------------------------------------------------------------------*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-sap-sng.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/exp-sap-sng.p $":U .
define variable vss-description as character no-undo init "Передача данных в SAP СНГ".

/* ********************  Preprocessor Definitions  ******************** */

/* Типы документов для п.5 */
&Scoped-define doc-types ie,iv

/* ***************************  Includes  ************************** */

{cmp/vssrevis.i}
{cmp/str-glbl.i}
{str/lib-trn.i}
{cmp/library.i}

/* ***************************  Definitions  ************************** */

/* Input parameters */

define input parameter p_xml as character no-undo. /* Путь к xml файлу */
define input parameter p_obj-type as character no-undo. /* Тип объекта */
define input parameter p_obj-code as integer no-undo. /* Вид объекта */
define input parameter p_shift-num as integer no-undo. /* Номер смены */
define input parameter p_shift-date as date no-undo. /* Дата смены */
define input parameter p_agregation_nds as logical no-undo. /* Тип агрегирование (no - по товару yes - по ндс) */
define input-output parameter p_operation-id as integer no-undo. /* p_operation-id */

/* Variables */

define variable hSAXWriter as handle no-undo. /* для создания XML */
define variable is-petrolium as logical no-undo. /* для типа товара */
define variable is-pieces as logical no-undo. /* для типа товара */
define variable v-host-code as integer no-undo. /* код фирмы */
 
/* Для run str/wthidnt.p */
define variable v-ser-code as integer no-undo.
define variable v-db-num like ub.wth-ser.db-num no-undo.
define variable v-stts as integer no-undo.
define variable v-wth-code like ub.wth-parts.wth-code no-undo.
define variable v-gds-code like ub.wth-parts.gds-code no-undo.
define variable v-par-code like ub.wth-parts.par-code no-undo.
define variable v-zone as character no-undo.
define variable v-FromDate as date no-undo.
define variable v-ToDate as date no-undo.
define variable v-priceRubl like ub.wth-parts.price-rubl  no-undo.
define variable v-priceBase like ub.wth-parts.price-base  no-undo.
define variable v-range like ub.wth-parts.fact-rangeFrom  no-undo.

/* Buffers */

define buffer buf_rvs-doc for ub.rvs-doc.
define buffer buf_prev_rvs-doc for ub.rvs-doc.
define buffer buf_rvs-line for ub.rvs-line.
define buffer buf_prev_rvs-line for ub.rvs-line.
define buffer buf_rvs-line-pump for ub.rvs-line-pump.
define buffer buf_prev_rvs-line-pump for ub.rvs-line-pump.
define buffer buf_previous-shift-obj for ub.shift-obj.
define buffer buf_place for ub.place.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_doc-line for doc-line.
define buffer buf_doc-pl for ub.doc-pl.
define buffer buf_goods for ub.goods.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_tax-rate-gds for ub.tax-rate-gds.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.

/* Temp-Tables */

/* Таблица для реализации сопутствующих товаров */
define temp-table tt_goods-rls no-undo
field bn-mode like ub.chk-gds-pay.pay-code
field sum like ub.chk-gds-pay.tot-r-b
field tax-code like ub.tax-rate-gds.rate-code
field barcode like ub.goods.gds-code
field num as decimal
field price like ub.chk-gds-pay.price-base.

/* Таблица для реализации услуг */
define temp-table tt_office-rls no-undo
field bn-mode like ub.chk-gds-pay.pay-code
field service-id like ub.goods.gds-code
field sum like ub.chk-gds-pay.tot-r-b.

/* Таблица для реализации топлива */
define temp-table tt_petrol-rls no-undo
field bn-mode like ub.chk-gds-pay.pay-code
field gas like ub.goods.gds-code
field preset as decimal
field litres as decimal
field weight as decimal
field price as decimal
field sum as decimal
field trk as integer
field tank as character
field density as decimal
field nozzle as integer.

/* Таблица для карт и талонов */
define temp-table tt_pay-types
field bn-mode like ub.chk-gds-pay.pay-code
field curr-code like ub.chk-gds-pay.curr-code
field card-type as character. /* 't' - талон, 's' - smart-card, 'o' - всё остальное*/

/* Таблица для номеров карт и талонов 
(т.к. данные агрегированы, то у одной строки tt_petrol-rls их может быть несколько) */
define temp-table tt_pay-cards
field row-id as rowid
field id as character
field card-type as character.

/* ************************  Function Implementations ***************** */

function record_time returns character():
/*------------------------------------------------------------------------------
        Purpose: Возвращает дату и время в необходимом формате
        Notes:                                                                        
------------------------------------------------------------------------------*/    
        return substitute("&1-&2-&3 &4", string(year(today),"9999"),
                                         string(month(today),"99"),
                                         string(day(today),"99"),
                                         string(time,"HH:MM:SS":U)).

end function. /* record_time */

/* ***************************  Main Block  *************************** */

/* Встанем на нужный документ сверки */
find first buf_rvs-doc where buf_rvs-doc.obj-type = p_obj-type
                         and buf_rvs-doc.obj-code = p_obj-code
                         and buf_rvs-doc.shift-num = p_shift-num
                         and buf_rvs-doc.shift-date = p_shift-date
                         and buf_rvs-doc.rvs-type = {&rvs-shift}
                         and buf_rvs-doc.status_ = {&fact} no-lock no-error.

/* Теперь найдём предыдущую сверку */

find last buf_previous-shift-obj where buf_previous-shift-obj.obj-type = p_obj-type
                                   and buf_previous-shift-obj.obj-code = p_obj-code
                                   and ((buf_previous-shift-obj.shift-date = p_shift-date 
                                        and buf_previous-shift-obj.shift-num < p_shift-num)
                                    or buf_previous-shift-obj.shift-date < p_shift-date) no-lock no-error.

/* Попадём на предыдущую сверку */
find first buf_prev_rvs-doc where buf_prev_rvs-doc.obj-type = p_obj-type
                              and buf_prev_rvs-doc.obj-code = p_obj-code
                              and buf_prev_rvs-doc.shift-num = buf_previous-shift-obj.shift-num
                              and buf_prev_rvs-doc.shift-date = buf_previous-shift-obj.shift-date
                              and buf_prev_rvs-doc.rvs-type = {&rvs-shift}
                              and buf_prev_rvs-doc.status_ = {&fact} no-lock no-error.

/* Если не было предыдущей сверки - берем контрольную (если смена, которую выгружают - первая на объекте) */
if not available buf_prev_rvs-doc then
find first buf_prev_rvs-doc where buf_prev_rvs-doc.obj-type = p_obj-type
                              and buf_prev_rvs-doc.obj-code = p_obj-code
                              and buf_prev_rvs-doc.shift-date = p_shift-date
                              and buf_prev_rvs-doc.shift-num = p_shift-num
                              and buf_prev_rvs-doc.status_ = {&fact}
                              and buf_prev_rvs-doc.rvs-type = {&rvs-control} no-lock.

/* Начнём запись в xml */
create sax-writer hSAXWriter.
hSAXWriter:set-output-destination("file":U, p_xml).
hSAXWriter:formatted = true.
hSAXWriter:encoding = "UTF-8":U.
hSAXWriter:standalone = no.

hSAXWriter:start-document().
hSAXWriter:write-external-dtd("oilix-log":U,"oilix-log.dtd":U).

hSAXWriter:start-element("oilix-log":U).
    
    /* 1. Общие данные */
    
    hSAXWriter:start-element("record":U).
        hSAXWriter:insert-attribute ("time":U, record_time()). /* Время операции */
        
        hSAXWriter:write-empty-element("log-start":U).
            hSAXWriter:insert-attribute("shift":U,string(p_shift-num)) no-error. /* Номер смены */
            hSAXWriter:insert-attribute("source":U,substitute("azk-&1",p_obj-code)) no-error. /* Код АЗС */
            hSAXWriter:insert-attribute("log-name":U,p_xml) no-error. /* Имя протокола */
            hSAXWriter:insert-attribute("prev-log-name":U,"") no-error. /* Имя предыдущего протокола */
            
    hSAXWriter:end-element("record":U).
    
    /* 2. Данные по резервуарам на начало смены */
    
    /* Сюда пойдут данные предыдущей сверки */
    
    for each buf_prev_rvs-line where buf_prev_rvs-line.rvs-code = buf_prev_rvs-doc.rvs-code no-lock:
        
        /* Определение резервуара */        
        find first buf_place where buf_place.obj-type = buf_prev_rvs-line.obj-type
                               and buf_place.obj-code = buf_prev_rvs-line.obj-code
                               and buf_place.pl-code = buf_prev_rvs-line.pl-code no-lock.
        
        hSAXWriter:start-element("record":U).
            hSAXWriter:insert-attribute ("time":U, record_time()).
            
            hSAXWriter:write-empty-element("tank-start":U).
                hSAXWriter:insert-attribute("tank":U,buf_place.loc1) no-error. /* Номер резервуара */
                hSAXWriter:insert-attribute("litres":U,string(buf_prev_rvs-line.state-measure-qnty)) no-error. /* Остаток на начало смены (литры) */
                hSAXWriter:insert-attribute("weight":U,string(buf_prev_rvs-line.state-measure-cli-qnty)) no-error. /* Остаток на начало смены (кг) */
                hSAXWriter:insert-attribute("gas":U,string(buf_prev_rvs-line.gds-code)) no-error. /* Код топлива */
        
        hSAXWriter:end-element("record":U).
    
    end. /* for each buf_rvs-line */
    
    /* 3. Данные по счетчикам на начало смены */
    
    /* Часть из текущей сверки, часть из предыдущей */
    
    /* В начале встали на текущий документ */
    for each buf_rvs-line where buf_rvs-line.rvs-code = buf_prev_rvs-doc.rvs-code no-lock:
        
        /* Определим резервуар */
        find first buf_place where buf_place.obj-type = buf_rvs-line.obj-type
                               and buf_place.obj-code = buf_rvs-line.obj-code
                               and buf_place.pl-code = buf_rvs-line.pl-code no-lock.    
        
        /* Информация с ТРК по баку в документе сверки */
        for each buf_rvs-line-pump where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                     and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                     and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type 
                                     and buf_rvs-line-pump.pl-code = buf_rvs-line.pl-code
                                     and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code no-lock:
            
            /* Информация с ТРК за предыдущую сверку */
            find first buf_prev_rvs-line-pump where buf_prev_rvs-line-pump.rvs-code = buf_prev_rvs-doc.rvs-code
                                                and buf_prev_rvs-line-pump.obj-type = buf_prev_rvs-doc.obj-type
                                                and buf_prev_rvs-line-pump.obj-code = buf_prev_rvs-doc.obj-code
                                                and buf_prev_rvs-line-pump.pl-code = buf_rvs-line-pump.pl-code
                                                and buf_prev_rvs-line-pump.gds-code = buf_rvs-line-pump.gds-code
                                                and buf_prev_rvs-line-pump.pump-code = buf_rvs-line-pump.pump-code
                                                and buf_prev_rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code no-lock.
            
            hSAXWriter:start-element("record":U).
                hSAXWriter:insert-attribute ("time":U, record_time()).
                
                hSAXWriter:write-empty-element("nozzle-info":U).
                    hSAXWriter:insert-attribute("nozzle":U,string(buf_rvs-line-pump.nozzle-code)) no-error. /* Номер счетчика */
                    hSAXWriter:insert-attribute("start-counter":U,string(buf_prev_rvs-line-pump.state-mh-cnt)) no-error. /* Начальное значение счетчика */
                    hSAXWriter:insert-attribute("end-counter":U,string(buf_rvs-line-pump.state-mh-cnt)) no-error. /* Конечное значение счетчика */
                    hSAXWriter:insert-attribute("litres":U,string(buf_rvs-line-pump.state-mh-qnty)) no-error. /* Количество отпущенных литров за смену */
                    hSAXWriter:insert-attribute("tank":U,buf_place.loc1) no-error. /* Номер резервуара */
                    hSAXWriter:insert-attribute("trk":U,string(buf_rvs-line-pump.pump-code)) no-error. /* Номер ТРК */
            
            hSAXWriter:end-element("record":U). 
        
        end. /* for each buf_rvs-line-pump  */
        
    end. /* for each buf_rvs-line */
    
    /* 4. Данные на конец смены */
    
    /* Пройдём по линиям текущей сверки */
    for each buf_rvs-line where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code no-lock: /* В начале встали на текущий документ */
        
        /* Определим резервуар */
        find first buf_place where buf_place.obj-type = buf_rvs-line.obj-type
                               and buf_place.obj-code = buf_rvs-line.obj-code
                               and buf_place.pl-code = buf_rvs-line.pl-code no-lock.            
        
        hSAXWriter:start-element("record":U).
            hSAXWriter:insert-attribute ("time":U, record_time()).
            
            hSAXWriter:write-empty-element("tank-end":U).
                hSAXWriter:insert-attribute("tank":U,buf_place.loc1) no-error. /* Номер резервуара */
                hSAXWriter:insert-attribute("level":U,left-trim(string(buf_rvs-line.state-level-petrol,">>>>>>> >>>>>9.999"))) no-error. /* Уровень на конец смены */
                hSAXWriter:insert-attribute("litres":U,left-trim(string(buf_rvs-line.state-measure-qnty,">>>>>>>>>>>>9.999"))) no-error. /* Остаток на конец смены (литры) */
                hSAXWriter:insert-attribute("weight":U,left-trim(string(buf_rvs-line.state-measure-cli-qnty,">>>>>>>>>>>>9.999"))) no-error. /* Остаток на конец смены (кг) */
                hSAXWriter:insert-attribute("lms-level":U,left-trim(string(buf_rvs-line.state-level-total,">>>>>>>>>>>>9.999"))) no-error. /* Уровень с уровнемера на конец смены */
                hSAXWriter:insert-attribute("lms-litres":U,left-trim(string(buf_rvs-line.measure-qnty,">>>>>>>>>>>>9.999"))) no-error. /* Остаток с уровнемера на конец смены (литры) */
                hSAXWriter:insert-attribute("lms-water":U,left-trim(string(buf_rvs-line.brutto-qnty - buf_rvs-line.measure-qnty,">>>>>>>>>>>>9.999"))) no-error. /* Вода в литрах с уровнемера на конец смены */
                hSAXWriter:insert-attribute("lms-density":U,left-trim(string(buf_rvs-line.density,">>>>>>>>>>>>9.999"))) no-error. /* Плотность с уровнемера на конец смены */
                hSAXWriter:insert-attribute("lms-temperature":U,string(buf_rvs-line.temperature)) no-error. /* Температура с уровнемера на конец смены */
                hSAXWriter:insert-attribute("log-name":U,p_xml) no-error.
                hSAXWriter:insert-attribute("next-log-name":U,"") no-error.
        
        hSAXWriter:end-element("record":U). 
        
    end. /* for each buf_rvs-line */
    
    /* 5. Приход топлива */
    
    /* Пройдём по линиям документа */
    for each buf_trn-doc where buf_trn-doc.obj-type = p_obj-type
                           and buf_trn-doc.obj-code = p_obj-code
                           and buf_trn-doc.shift-date = p_shift-date
                           and buf_trn-doc.shift-num = p_shift-num
                           and buf_trn-doc.status_ = {&fact}
                           and lookup(buf_trn-doc.ext-doc-type, "{&doc-types}":U,",") > 0 no-lock:

        for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
            
            /* Только по топливным */
            
            {str/is-petrl.i buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code is-petrolium is-pieces}
         
            if is-petrolium = true then do:
                
                /* Определим gds-code для doc-pl */
                find first buf_goods where buf_goods.prod-type = buf_doc-line.prod-type
                                       and buf_goods.prod-code = buf_doc-line.prod-code
                                       and buf_goods.artic = buf_doc-line.artic no-lock.
                
                /* По всем хранилищам с этим товаром */
                for each buf_doc-pl where buf_doc-pl.obj-type = p_obj-type
                                      and buf_doc-pl.obj-code = p_obj-code
                                      and buf_doc-pl.out-code = buf_doc-line.doc-code
                                      and buf_doc-pl.gds-code = buf_goods.gds-code no-lock:
                
                    /* Определим резервуар */
                    find first buf_place where buf_place.obj-type = buf_doc-pl.obj-type
                                           and buf_place.obj-code = buf_doc-pl.obj-code
                                           and buf_place.pl-code = buf_doc-pl.pl-code no-lock.    
                    
                    hSAXWriter:start-element("record":U).
                        hSAXWriter:insert-attribute ("time":U, record_time()).
                        
                        hSAXWriter:write-empty-element("tank-income":U).
                            hSAXWriter:insert-attribute("tank":U,buf_place.loc1) no-error. /* Номер резервуара */
                            hSAXWriter:insert-attribute("ttn-volume":U,left-trim(string(buf_doc-pl.doc-qnty,">>>>>>>>>>>>9.999"))) no-error. /* Количество по ТТН (литры) */
                            hSAXWriter:insert-attribute("ttn-weight":U,left-trim(string(buf_doc-pl.cli-qnty,">>>>>>>>>>>>9.999"))) no-error. /* Количество по ТТН (кг) */
                            hSAXWriter:insert-attribute("temperature":U,string(buf_doc-line.temperature)) no-error. /* Температура факт */
                            hSAXWriter:insert-attribute("density":U,left-trim(string(buf_doc-line.fact-density,">>>>>>>>>>>>9.999"))) no-error. /* Плотность факт */
                            hSAXWriter:insert-attribute("income-volume":U,string(buf_doc-pl.fact-qnty)) no-error. /* Количество факт (литры) */
                            hSAXWriter:insert-attribute("income-weight":U,string(buf_doc-pl.cli-fact-qnty)) no-error. /* Количество факт (кг) */
                            hSAXWriter:insert-attribute("ttn":U,buf_doc-line.doc-code) no-error. /* Номер документа */
                    
                    hSAXWriter:end-element("record":U). 
                    
                end. /* for each buf_doc-pl */
                
            end. /* if is-petrolium = true */
            
        end. /* for each buf_doc-line */
            
    end. /* for each buf_trn-doc */
    
    /* Заполнение таблицы для 6, 7 и 8 */
    
    /* Пройдём по оплатам за смену */  
    for each buf_chk-gds-pay where buf_chk-gds-pay.obj-code = p_obj-code
                               and buf_chk-gds-pay.obj-type = p_obj-type
                               and buf_chk-gds-pay.shift-date = p_shift-date
                               and buf_chk-gds-pay.shift-num = p_shift-num no-lock:
        
        /* Определим gds-code */
        find first buf_bar-code where buf_bar-code.b-code = buf_chk-gds-pay.b-code no-lock.
        
        /* По типу товара в линии создадим запись */

        case entry(1,buf_chk-gds-pay.line-type,{&delim-par}) :
            
            when {&gds-goods} then do:  /* Заполним таблицу реализации товаров суммируя по коду товару и виду оплаты */
                
                find first tt_goods-rls where tt_goods-rls.barcode = buf_bar-code.gds-code 
                                          and tt_goods-rls.bn-mode = buf_chk-gds-pay.pay-code no-error.
                
                if not available(tt_goods-rls) then do:
                    
                    {gbl/hostcode.i p_obj-type p_obj-code v-host-code}
                    
                    find last buf_tax-rate-gds where buf_tax-rate-gds.gds-code = buf_bar-code.gds-code
                                                 and buf_tax-rate-gds.tax-code = integer({&vat-tax-code})
                                                 and buf_tax-rate-gds.host-code = v-host-code
                                                 and buf_tax-rate-gds.obj-code = p_obj-code
                                                 and buf_tax-rate-gds.obj-type = p_obj-type
                                                 and buf_tax-rate-gds.fact-order <= integer(p_shift-date) no-lock no-error.
                    
                    if not available(buf_tax-rate-gds) then
                        find last buf_tax-rate-gds where buf_tax-rate-gds.gds-code  = buf_bar-code.gds-code
                                                     and buf_tax-rate-gds.tax-code  = integer({&vat-tax-code})
                                                     and buf_tax-rate-gds.host-code  = 0
                                                     and buf_tax-rate-gds.obj-type  = ''
                                                     and buf_tax-rate-gds.obj-code  = 0
                                                     and buf_tax-rate-gds.fact-order <= integer(p_shift-date) no-lock no-error.
                    
                    create tt_goods-rls.
                    assign
                    tt_goods-rls.bn-mode = buf_chk-gds-pay.pay-code
                    tt_goods-rls.tax-code = buf_tax-rate-gds.rate-code
                    tt_goods-rls.barcode = buf_bar-code.gds-code.
                    
                end. /* if not available(tt_goods-rls) */
                
                assign
                tt_goods-rls.sum = tt_goods-rls.sum + buf_chk-gds-pay.tot-r-b
                tt_goods-rls.num = tt_goods-rls.num + buf_chk-gds-pay.eff-doc-qnty
                tt_goods-rls.price = tt_goods-rls.price + buf_chk-gds-pay.price-base * buf_chk-gds-pay.eff-doc-qnty. /* Потом поделим на общее кол-во и получим среднюю цену*/
  
            end. /* when {&gds-goods} */
            
            when {&gds-office} then do:  /* Заполним таблицу реализации услуг суммируя по коду услуги и виду оплаты */
                
                find first tt_office-rls where tt_office-rls.service-id = buf_bar-code.gds-code 
                                          and tt_office-rls.bn-mode = buf_chk-gds-pay.pay-code no-error.
                                          
                if not available(tt_office-rls) then do:
                    
                    create tt_office-rls.
                    assign
                    tt_office-rls.bn-mode = buf_chk-gds-pay.pay-code
                    tt_office-rls.service-id = buf_bar-code.gds-code.
                    
                end. /* if not available(tt_goods-rls) */
                
                tt_office-rls.sum = tt_office-rls.sum + buf_chk-gds-pay.tot-r-b.
                
            end. /* when {&gds-office} */
            
            when {&petrolium} then do: /* Заполним таблицу для реализации топлива */
                
                /* Для ТРК и пистолета */
                find first buf_chk-gds where buf_chk-gds.doc-code = buf_chk-gds-pay.doc-code
                                         and buf_chk-gds.line-num = buf_chk-gds-pay.line-num no-lock no-error.
                
                /* Проверим, есть ли запись */
                find first tt_petrol-rls where tt_petrol-rls.bn-mode = buf_chk-gds-pay.pay-code
                                           and tt_petrol-rls.gas = buf_bar-code.gds-code
                                           and tt_petrol-rls.tank = buf_chk-gds.loc1
                                           and tt_petrol-rls.trk = buf_chk-gds.pump
                                           and tt_petrol-rls.nozzle = buf_chk-gds.nozzle-code no-error.


                /* Посмотрим, был ли уже такой тип платежа */
                find first tt_pay-types where tt_pay-types.bn-mode = tt_petrol-rls.bn-mode
                                          and tt_pay-types.curr-code = buf_chk-gds-pay.curr-code no-error.


                /* Создадим, если не нашли */
                if not available(tt_petrol-rls) then do:
                    
                    create tt_petrol-rls.
                    assign
                    tt_petrol-rls.bn-mode = buf_chk-gds-pay.pay-code
                    tt_petrol-rls.gas = buf_bar-code.gds-code 
                    tt_petrol-rls.tank = buf_chk-gds.loc1
                    tt_petrol-rls.trk = buf_chk-gds.pump
                    tt_petrol-rls.nozzle = buf_chk-gds.nozzle-code
                    tt_petrol-rls.density = buf_chk-gds.density no-error.
                    
                    /* Теперь разберемся с типом платежа */
                        
                    if not available(tt_pay-types) then do:
                        
                        create tt_pay-types.
                        assign
                        tt_pay-types.bn-mode = tt_petrol-rls.bn-mode
                        tt_pay-types.curr-code = buf_chk-gds-pay.curr-code.
                        
                        /* Определим тип платежа */
                        find first buf_cash-pay where buf_cash-pay.cdpay-code = tt_petrol-rls.bn-mode
                                                  and buf_cash-pay.curr-code = buf_chk-gds-pay.curr-code no-error.
                            
                            /* Если smart-card */
                            if buf_cash-pay.atr128 then tt_pay-types.card-type = 's':U.
                            
                            /* Проверим талоны */
                            else do:
                                
                                find first buf_wealth where buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
                                
                                /* Если талон */
                                if available(buf_wealth) and buf_wealth.is-ser = 1 then tt_pay-types.card-type = 't':U.
                                
                                /* Всё остальное (нам не важно, но чтобы заного не проверять тип платежа) */
                                else tt_pay-types.card-type = 'o':U.
                                
                            end. /* else do */
                            
                    end. /* if not available(tt_pay-types) */

                end. /* if not available(tt_petrol-rls) */
                
                /* Сейчас у нас есть тип платежа и мы можем сделать запись в tt_pay-cards по данному чеку */

                if tt_pay-types.card-type = 's':U or tt_pay-types.card-type = 't':U then do:
                    
                    create tt_pay-cards.
                    assign
                    tt_pay-cards.id = buf_chk-gds-pay.pay-card
                    tt_pay-cards.card-type = tt_pay-types.card-type
                    tt_pay-cards.row-id = rowid(tt_petrol-rls).
                    
                end. /* if tt_pay-types.card-type */
                
                /* Просуммируем количества и суммы */
                
                assign
                tt_petrol-rls.litres = tt_petrol-rls.litres + buf_chk-gds-pay.eff-doc-qnty
                tt_petrol-rls.preset = tt_petrol-rls.litres
                tt_petrol-rls.sum  = tt_petrol-rls.sum + buf_chk-gds-pay.tot-r-b
                tt_petrol-rls.weight = tt_petrol-rls.litres * tt_petrol-rls.density
                tt_petrol-rls.price = tt_petrol-rls.sum / tt_petrol-rls.litres no-error.
                
            end. /* when {&petrolium} */
            
        end case.
        
    end. /* for each buf_chk-gds-pay */
    
    /* 6. Реализация топлива */
        
    for each tt_petrol-rls no-lock:

                hSAXWriter:start-element("record":U).
                    hSAXWriter:insert-attribute ("time":U, record_time()).

                    hSAXWriter:start-element("filling":U).
                    
                        hSAXWriter:insert-attribute("operation-id":U,string(p_operation-id)) no-error. /* Идентификатор операции */
                        hSAXWriter:insert-attribute("bn-mode":U,string(tt_petrol-rls.bn-mode)) no-error. /* Код вида оплаты */
                        hSAXWriter:insert-attribute("gas":U,string(tt_petrol-rls.gas)) no-error. /* Код топлива */
                        hSAXWriter:insert-attribute("preset":U,left-trim(string(tt_petrol-rls.preset,">>>>>>>>>>>>9.999"))) no-error. /* Заказанное количество литров */
                        hSAXWriter:insert-attribute("litres":U,left-trim(string(tt_petrol-rls.litres,">>>>>>>>>>>>9.999"))) no-error. /* Полученное количество литров */
                        hSAXWriter:insert-attribute("weight":U,left-trim(string(tt_petrol-rls.weight,">>>>>>>>>>>>9.999"))) no-error. /* Полученное количество кг */
                        hSAXWriter:insert-attribute("price":U,left-trim(string(tt_petrol-rls.price,">>>>>>>>>>>>9.99"))) no-error. /* Цена за литр */
                        hSAXWriter:insert-attribute("sum":U,left-trim(string(tt_petrol-rls.sum,">>>>>>>>>>>>9.99"))) no-error. /* Сумма */
                        hSAXWriter:insert-attribute("trk":U,string(tt_petrol-rls.trk)) no-error. /* Номер ТРК */
                        hSAXWriter:insert-attribute("tank":U,tt_petrol-rls.tank) no-error. /* Номер резервуара */
                        hSAXWriter:insert-attribute("density":U,left-trim(string(tt_petrol-rls.density,">>>>>>>>>>>>9.999"))) no-error. /* Плотность */
                        hSAXWriter:insert-attribute("nozzle":U,string(tt_petrol-rls.nozzle)) no-error. /* Номер счетчика */
                        
                        p_operation-id = p_operation-id + 1.
                        
                        /* Посмотрим оплаты картами и талонами по данной строке */
                        for each tt_pay-cards where tt_pay-cards.row-id = rowid(tt_petrol-rls) break by tt_pay-cards.card-type:
                            
                            /* Если smart-card */
                            if tt_pay-cards.card-type = 's':U then do:
                                
                                hSAXWriter:write-empty-element("card-info":U).
                                    hSAXWriter:insert-attribute("card",tt_pay-cards.id) no-error.
/*                                  hSAXWriter:insert-attribute("type":U,"") no-error. /* Тип карты */                */
/*                                  hSAXWriter:insert-attribute("client-type":U,"") no-error. /* Тип клиента */       */
                            
                            end. /* if tt_pay-cards.card-type */
                            
                            /* Если талон */
                            if tt_pay-cards.card-type = 't':U then do:
                                
                                /* Определим номинал талона */
                                
                                run str/wthidnt.p (input tt_pay-cards.id
                                                  ,output v-ser-code
                                                  ,output v-db-num
                                                  ,output v-stts
                                                  ,output v-wth-code
                                                  ,output v-gds-code
                                                  ,output v-par-code
                                                  ,output v-zone
                                                  ,output v-FromDate
                                                  ,output v-ToDate
                                                  ,output v-range) no-error.
                                
                                find first buf_wth-par where buf_wth-par.wth-code = v-wth-code
                                                         and buf_wth-par.par-code = v-par-code no-lock no-error.
                                
                                hSAXWriter:start-element("ticket-info-list":U).
                                    
                                    hSAXWriter:write-empty-element("ticket-info":U).
                                        hSAXWriter:insert-attribute("id":U,tt_pay-cards.id) no-error. /* Номер талона */
                                        hSAXWriter:insert-attribute("litres":U,left-trim(string(buf_wth-par.par-val,">>>>>>>>>>>>9.999"))) no-error. /* Номинал талона */
                                
                                hSAXWriter:end-element("ticket-info-list":U).
                                
                            end. /* if tt_pay-cards.card-type */                           

                        end. /* for each tt_pay-cards */
                        
                    hSAXWriter:end-element("filling":U).
                    
                hSAXWriter:end-element("record":U).

    end. /* for each tt_petrol-rls */
    
    /* 7. Реализация услуг */
    
    for each tt_office-rls no-lock:

        hSAXWriter:start-element("record":U).
            hSAXWriter:insert-attribute ("time":U, record_time()).

            hSAXWriter:write-empty-element("service":U).
                hSAXWriter:insert-attribute("operation-id":U,string(p_operation-id)) no-error. /* Идентификатор операции */
                hSAXWriter:insert-attribute("bn-mode":U,string(tt_office-rls.bn-mode)) no-error. /* Код вида оплаты */
                hSAXWriter:insert-attribute("service-id":U,string(tt_office-rls.service-id)) no-error. /* Вид услуги */
                hSAXWriter:insert-attribute("sum":U,left-trim(string(tt_office-rls.sum,">>>>>>>>>>>>9.99"))) no-error. /* Сумма */
                
                p_operation-id = p_operation-id + 1.
                
        hSAXWriter:end-element("record":U).

    end. /* for each tt_office-rls */

    /* 8. Реализация сопутствующих товаров */

    if p_agregation_nds then do: /* Агрегация по НДС */
        
        for each tt_goods-rls break by tt_goods-rls.tax-code by tt_goods-rls.bn-mode:
            
            accumulate tt_goods-rls.sum (total by tt_goods-rls.bn-mode).
            accumulate tt_goods-rls.num (total by tt_goods-rls.bn-mode).
            
            if last-of(tt_goods-rls.bn-mode) then do:
                
                hSAXWriter:start-element("record":U).
                    hSAXWriter:insert-attribute ("time":U, record_time()).
    
                    hSAXWriter:write-empty-element("payment":U).
                        hSAXWriter:insert-attribute("operation-id":U,string(p_operation-id)) no-error. /* Идентификатор операции */
                        hSAXWriter:insert-attribute("bn-mode":U,string(tt_goods-rls.bn-mode)) no-error. /* Код вида оплаты */
                        hSAXWriter:insert-attribute("sum":U,left-trim(string(accum total by tt_goods-rls.bn-mode tt_goods-rls.sum,">>>>>>>>>>>>9.99"))) no-error. /* Сумма */
                        p_operation-id = p_operation-id + 1.
                        
                        hSAXWriter:start-element("sellings":U).
                        
                            hSAXWriter:write-empty-element("selling":U).
                                hSAXWriter:insert-attribute("tax-code":U,string(tt_goods-rls.tax-code)) no-error. /* Ставка НДС */
                                hSAXWriter:insert-attribute("barcode":U,"") no-error. /* Код товара */
                                hSAXWriter:insert-attribute("num":U,left-trim(string(accum total by tt_goods-rls.bn-mode tt_goods-rls.num,">>>>>>>>>>>>9.999"))) no-error. /* Количество */
                                hSAXWriter:insert-attribute("price":U,"") no-error. /* Цена */
                        
                        hSAXWriter:end-element("sellings":U).
                        
                hSAXWriter:end-element("record":U).              
                
            end. /* if last-of(tt_goods-rls.bn-mode) */
            
        end. /* for each tt_goods-rls */
        
    end. /* if p_agregation_nds */

    else do:  /* Агрегация по товару */
        
        for each tt_goods-rls no-lock:

            hSAXWriter:start-element("record":U).
                hSAXWriter:insert-attribute ("time":U, record_time()).

                hSAXWriter:write-empty-element("payment":U).
                    hSAXWriter:insert-attribute("operation-id":U,string(p_operation-id)) no-error. /* Идентификатор операции */
                    hSAXWriter:insert-attribute("bn-mode":U,string(tt_goods-rls.bn-mode)) no-error. /* Код вида оплаты */
                    hSAXWriter:insert-attribute("sum":U,left-trim(string(tt_goods-rls.sum,">>>>>>>>>>>>9.99"))) no-error. /* Сумма */
                    p_operation-id = p_operation-id + 1.
                    
                    hSAXWriter:start-element("sellings":U).
                    
                        hSAXWriter:write-empty-element("selling":U).
                            hSAXWriter:insert-attribute("tax-code":U,string(tt_goods-rls.tax-code)) no-error. /* Ставка НДС */
                            hSAXWriter:insert-attribute("barcode":U,string(tt_goods-rls.barcode)) no-error. /* Код товара */
                            hSAXWriter:insert-attribute("num":U,string(tt_goods-rls.num)) no-error. /* Количество */
                            hSAXWriter:insert-attribute("price":U,string(tt_goods-rls.price / tt_goods-rls.num)) no-error. /* Цена */
                    
                    hSAXWriter:end-element("sellings":U).
                    
            hSAXWriter:end-element("record":U).
            
        end. /* for each tt_goods-rls */
        
    end. /* else do */

hSAXWriter:end-element("oilix-log":U).

hSAXWriter:end-document().
delete object hSAXWriter no-error.    