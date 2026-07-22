/*

$Revision: 8f5f559ebdb3, 2359, rls $
$Author: ARostovtsev $
$Date: Ср мар  21:13:34 2020 +0300 $
$Workfile: r-rsrv-plan.p $
$Archive: rep/r-rsrv-plan.p $

Создание линии в заказе

Автор: Шкляр Елена Львовна
Дата создания: 05/03/25
Author: Shklyar Elena
Creation date: 03/05/25

*/

/*{ str/order.i }*/
{ trg/factord.i    }
function round-maxInt returns decimal
    (input p-dec as decimal) forward.

function round-maxDec returns decimal
    (input p-dec as decimal) forward.

function round-minInt returns decimal
    (input p-dec as decimal) forward.

define variable rPeriodZakaz       as integer   no-undo .
define variable vDaySale           as integer   no-undo .
define variable pGarantDay         as integer   no-undo .
define variable pDelDayGoods       as logical   no-undo .
define variable typeDocChoose      as character no-undo .
define variable dateZakaz          as character no-undo .
define variable zakazPeriod        as character no-undo .
define variable qntyPeriod         as integer   no-undo .
define variable pDateOrder         as date      no-undo .
define variable vLine              as integer   no-undo .
define variable vDateStart         as date      no-undo .
define variable vDateEnd           as date      no-undo .
define variable periodDate         as date      no-undo .
                
define variable v-fact-orderStart  as decimal   no-undo .
define variable v-fact-orderEnd    as decimal   no-undo .
define variable v-fact-order-start as decimal   no-undo .
define variable v-fact-order-end   as decimal   no-undo .

define buffer buf_PromoGoogs      for ub.PromoGoods .
define buffer buf_PromoAction     for ub.PromoAction .
define buffer buf_stk-line        for ub.stk-line .
define buffer buf_trn-doc         for ub.trn-doc .
define buffer buf_goods-attr      for ub.goods-attr .
define buffer buf_cli-gds         for ub.cli-gds .
define buffer buf_temp-gds-qnty   for temp-gds-qnty .
define buffer buf_doc-line        for ub.doc-line .
define buffer buf_order-line      for ub.order-line .
define buffer buf_order-doc       for ub.order-doc .
define buffer buf_contract-specif for ub.contract-specif .
procedure crt-orderLine:
    define input parameter par-params      as character no-undo .
    define input parameter pDocCode as integer no-undo .
    define input parameter pDbNum as integer no-undo .
    define input parameter table for tt-gds-list .

    define variable kk as integer no-undo .
    define variable ii as integer no-undo .
    
    pDateOrder = date(entry(1,par-params,{&delim-par})) .
    rPeriodZakaz = integer(entry(2,par-params,{&delim-par})) .
    vDaySale = integer (entry(3,par-params,{&delim-par})) .
    pGarantDay = integer(entry(4,par-params,{&delim-par})) .
    pDelDayGoods = logical(entry(5,par-params,{&delim-par})) .
    typeDocChoose = entry(6,par-params,{&delim-par}) .
    dateZakaz = entry(7,par-params,{&delim-par}) .
    
    find first buf_order-doc no-lock where buf_order-doc.doc-code = pDocCode and
        buf_order-doc.db-num = pDbNum no-error .
    
    find last buf_order-line no-lock where buf_order-line.doc-code = pDocCode and
        buf_order-line.db-num = pDbNum no-error .
    if available (buf_order-line) then vLine = buf_order-line.line-num .
    do kk = 1 to num-entries (dateZakaz,{&delim-nps}):
        zakazPeriod = entry(kk,dateZakaz,{&delim-nps}) .
        create tt-dateZakaz .
        assign 
            tt-dateZakaz.id        = kk
            tt-dateZakaz.dateStart = date(entry(1,zakazPeriod,{&delim-flf}))
            tt-dateZakaz.dateEnd   = date(entry(2,zakazPeriod,{&delim-flf}))
            .
    end.
    for each tt-dateZakaz:
        qntyPeriod = qntyPeriod + 1 . /* Посчитать кол-во дней всего */ 
        if tt-dateZakaz.dateStart < vDateStart or vDateStart = ? then vDateStart = tt-dateZakaz.dateStart .
        if tt-dateZakaz.dateEnd > vDateEnd or vDateEnd = ? then vDateEnd = tt-dateZakaz.dateEnd .
    end.
    for each gds-list:
        for first buf_goods-attr no-lock where buf_goods-attr.gds-code = gds-list.gds-code and
            buf_goods-attr.attr-code = {&attr-min-zapas-o}:
            gds-list.minZapas = decimal (buf_goods-attr.attr-value) .
        end.
    end.

    for each gds-list:
        find first tt-zakaz no-lock where tt-zakaz.gds-code = gds-list.gds-code no-error .
        if available (tt-zakaz) then next .
        create tt-zakaz .
        assign
            tt-zakaz.gds-code          = gds-list.gds-code
            tt-zakaz.artic             = gds-list.artic
            tt-zakaz.gds-name          = gds-list.gds-name
            tt-zakaz.prod-code         = gds-list.prod-code
            tt-zakaz.prod-type         = gds-list.prod-type
            tt-zakaz.garant-stock      = 0
            tt-zakaz.minZapas          = gds-list.minZapas
            tt-zakaz.ostatokDay        = 0
            tt-zakaz.ostatokGoods      = 0
            tt-zakaz.rest              = 0
            tt-zakaz.qntyDay           = kk - 1
            tt-zakaz.qntyDaySale       = 0
            tt-zakaz.average-sales     = 0
            tt-zakaz.order-qnty        = 0
            tt-zakaz.volMinZapas       = 0
            tt-zakaz.sales             = 0
            tt-zakaz.volume-goods      = 0
            tt-zakaz.contract-prn-code = gds-list.contract
            tt-zakaz.contract-code     = gds-list.contract-code
            .
  
        /*Остаток на текущий день*/
        for each buf_cli-gds no-lock where buf_cli-gds.artic = gds-list.artic and
            buf_cli-gds.prod-code = gds-list.prod-code and
            buf_cli-gds.prod-type = gds-list.prod-type:
            tt-zakaz.rest = tt-zakaz.rest + buf_cli-gds.supp-qnty .
        end.
  
        /* Собираем таблицу с остатками по периодам */
        empty temp-table temp-gds-qnty .
        if pDelDayGoods then run ost-gds-day(vDateStart, vDateEnd, gds-list.gds-code, v-cntxt-obj-type, v-cntxt-obj-code, tt-zakaz.rest) .  
  
        /* Документы по датам */
        for each tt-dateZakaz:
            /*    do zakazDate = tt-dateZakaz.dateStart to tt-dateZakaz.dateEnd:*/
      
            /*Поиск нач fact-order*/
            run day-begin-fact-order in this-procedure ( input tt-dateZakaz.dateStart
                , output v-fact-order-start
                ).
            /*Поиск посл fact-order*/
            run factord-end-day in this-procedure ( input tt-dateZakaz.dateEnd
                , output v-fact-order-end
                ).     
            /* Посчитать кол-во дней если с Исключить дни без товара */    
            if pDelDayGoods then 
            do:
                for each buf_temp-gds-qnty where buf_temp-gds-qnty.gds-code = gds-list.gds-code and
                    buf_temp-gds-qnty.ost > 0 and
                    buf_temp-gds-qnty.day >= tt-dateZakaz.dateStart and
                    buf_temp-gds-qnty.day <= tt-dateZakaz.dateEnd:
                    tt-zakaz.qntyDayGoods = tt-zakaz.qntyDayGoods + 1 .
                end.
            end.
            else tt-zakaz.qntyDayGoods = tt-dateZakaz.dateEnd - tt-dateZakaz.dateStart + 1.

            do ii = 0 to num-entries (typeDocChoose,{&delim-nps}):
                for each buf_doc-line no-lock 
                    where 
                    buf_doc-line.ext-doc-type = entry(ii,typeDocChoose,{&delim-nps}) and
                    buf_doc-line.obj-code = v-cntxt-obj-code and
                    buf_doc-line.obj-type = v-cntxt-obj-type and
                    buf_doc-line.artic = gds-list.artic and
                    buf_doc-line.prod-code = gds-list.prod-code and
                    buf_doc-line.prod-type = gds-list.prod-type and
                    buf_doc-line.fact-order >= v-fact-order-start and
                    buf_doc-line.fact-order <= v-fact-order-end :
                    tt-zakaz.qntyDaySale = tt-zakaz.qntyDaySale + 1 .
                    case entry(ii,typeDocChoose,{&delim-nps}):
                        /* разбивка по типам документов */
                        /* приход */
                        when   {&tdedt_pri_vnesh}  or
                        when   {&tdedt_pri_prvo  }     then
                            do:
                                tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                            end.

                        /* расход */
                        when  {&tdedt_spi_vnesh}      then 
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  {&tdedt_spi_prvo}       then 
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  {&tdedt_ras_prvo}       then 
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  {&tdedt_ras_perem}      then 
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  {&tdedt_vozvrat_perem}  then 
                            tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                        when  {&tdedt_ras_vnesh}      then 
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  {&tdedt_vozvrat_vnesh}  then 
                            tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                        when  {&tdedt_ras_vnesh_kass}     then 
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  {&tdedt_vozvrat_vnesh_kass} then 
                            tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                        when  {&TDEDT_Spi_Vnesh} then 
                            tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                    end case.            

                end.
            end.

        /*    end.*/
        end.

        if tt-zakaz.qntyDayGoods <> 0 then tt-zakaz.average-sales = round-maxDec(tt-zakaz.sales / tt-zakaz.qntyDayGoods) . /* Тпр */
        if tt-zakaz.qntyDayGoods <> 0 then
        do:
            if tt-zakaz.rest > -1 then 
            do:
                tt-zakaz.ostatokDay = tt-zakaz.rest - ((integer(pDateOrder - date(today)) * tt-zakaz.average-sales)) . /* Ост */
                if tt-zakaz.ostatokDay < 0 then tt-zakaz.volume-goods = round-maxInt(tt-zakaz.average-sales * vDaySale). /* Vз */
                else tt-zakaz.volume-goods = round-maxInt(tt-zakaz.average-sales * vDaySale - tt-zakaz.ostatokDay) .
            end.
            else tt-zakaz.volume-goods = round-maxInt(tt-zakaz.average-sales * vDaySale - tt-zakaz.rest). /* Vз */
            if tt-zakaz.qntyDaySale <> 0 then 
            do:   
                tt-zakaz.volMinZapas = round-maxInt(tt-zakaz.volume-goods + tt-zakaz.minZapas) . /* Vзм */
                tt-zakaz.garant-stock = pGarantDay * tt-zakaz.average-sales . /* G */
                tt-zakaz.order-qnty = round-maxInt(tt-zakaz.volume-goods + tt-zakaz.minZapas + tt-zakaz.garant-stock) . /* Vзг */

                if tt-zakaz.average-sales <> 0 then tt-zakaz.ostatokGoods = round-minInt(tt-zakaz.rest / tt-zakaz.average-sales) . /* Од */
            end.
            else tt-zakaz.volume-goods = 0 .
        end.
        for each buf_PromoGoogs no-lock where buf_PromoGoogs.gds-code = gds-list.gds-code,
            first buf_PromoAction no-lock where buf_PromoAction.id = buf_PromoGoogs.idAction and
            buf_PromoAction.end-date >= today and buf_PromoAction.beg-date <= today and buf_PromoAction.Status_ = 1:
            tt-zakaz.promo = true .
        end.
  
        find first buf_goods no-lock where
            buf_goods.gds-code = tt-zakaz.gds-code.
       
                 
        create buf_order-line.
        assign
            vLine                        = vLine + 1
            buf_order-line.doc-code      = pDocCode
            buf_order-line.db-num        = pDbNum
            buf_order-line.line-num      = vLine
            buf_order-line.gds-code      = tt-zakaz.gds-code
            buf_order-line.artic         = tt-zakaz.artic  
            buf_order-line.prod-type     = if avail buf_goods then buf_goods.prod-type else ""
            buf_order-line.prod-code     = if avail buf_goods then buf_goods.prod-code else 0
            buf_order-line.order-qnty    = tt-zakaz.order-qnty
            buf_order-line.fact-qnty     = tt-zakaz.order-qnty
            buf_order-line.rest          = tt-zakaz.rest
            buf_order-line.sales         = tt-zakaz.sales
            buf_order-line.average-sales = tt-zakaz.average-sales
            buf_order-line.stock-goods   = if tt-zakaz.average-sales = 0 and tt-zakaz.ostatokDay <> 0 then -1 else integer(tt-zakaz.ostatokGoods)
            buf_order-line.volume-goods  = tt-zakaz.volume-goods
            buf_order-line.volume-stock  = if tt-zakaz.minZapas > tt-zakaz.rest then tt-zakaz.minZapas else tt-zakaz.volMinZapas
            buf_order-line.min-stock     = tt-zakaz.minZapas
            buf_order-line.garant-stock  = tt-zakaz.garant-stock
            buf_order-line.promo         = tt-zakaz.promo
            .
        validate buf_order-line.
    end .
end procedure .

procedure ost-gds-day :
    do
        on error undo, return error return-value
        :
        define input parameter p-dateStart as decimal no-undo . /*начало периода*/
        define input parameter p-dateEnd as decimal no-undo . /*конец периода*/
        define input parameter p-gds-code like ub.goods.gds-code no-undo .
        define input parameter p-obj-type as character no-undo .
        define input parameter p-obj-code as integer no-undo .
        define input parameter p-ost-today as decimal no-undo .
    
        define variable vOst as decimal no-undo .
        define buffer p_goods     for ub.goods .
        define buffer p-doc-line  for ub.doc-line .
        define buffer pc-gds-obj  for ub.c-gds-obj .
        define buffer pc-gds-obj2 for ub.c-gds-obj .
    
        find first p_goods no-lock where p_goods.gds-code = p-gds-code no-error .
        if error-status :error then return error .

        do periodDate = vDateStart to vDateEnd:   
            create temp-gds-qnty .                                                        
            assign
                temp-gds-qnty.day      = periodDate
                temp-gds-qnty.gds-code = p_goods.gds-code  
                .
            find first pc-gds-obj no-lock where pc-gds-obj.gds-code = p_goods.gds-code and
                pc-gds-obj.obj-code = p-obj-code and
                pc-gds-obj.obj-type = p-obj-type and
                pc-gds-obj.corr-date = periodDate no-error .
            if not available (pc-gds-obj) then 
            do:
                find last pc-gds-obj2 no-lock where pc-gds-obj2.gds-code = p_goods.gds-code and
                    pc-gds-obj2.obj-code = p-obj-code and
                    pc-gds-obj2.obj-type = p-obj-type and
                    pc-gds-obj2.corr-date < periodDate no-error .
                if available (pc-gds-obj2) then temp-gds-qnty.ost = pc-gds-obj2.fact-qnty .
            end.
            else temp-gds-qnty.ost = pc-gds-obj.fact-qnty .
        end.  
    end.  

end procedure. /* ost-gds-day */

function round-maxInt returns decimal  /* Округление число до целого в большую сторону*/
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .  
    if absolute(p-dec - TRUNCATE (p-dec, 0)) < 0.5
        then 
    do:
        if p-dec > 0 then p-int = integer (p-dec + 0.4) .
        else p-int = integer(p-dec) .
    end .
    else 
    do:
        if p-dec < 0 then p-int = integer (p-dec + 0.4) .
        else p-int = integer(p-dec) .    
    end.

    return p-int .
end function. /* round */

function round-minInt returns decimal  /* Округление число до целого в меньшую сторону*/
    (input p-dec as decimal):
    define variable p-int as decimal no-undo . 
  
    if absolute(p-dec - TRUNCATE (p-dec, 0)) > 0.5
        then 
    do:
        if p-dec > 0 then p-int = integer (p-dec - 0.4) .
        else p-int = integer(p-dec) .
    end .
    else 
    do:
        if p-dec < 0 then p-int = integer (p-dec - 0.4) .
        else p-int = integer(p-dec) .    
    end.
    return p-int .
end function. /* round */

function round-maxDec returns decimal  /* Округление число до целого в большую сторону*/
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .  
    if p-dec - TRUNCATE (p-dec, 1) > 0
        then 
    do:
        if TRUNCATE (p-dec, 1) = 0 then p-int = TRUNCATE (p-dec, 1) .
        else p-int = TRUNCATE (p-dec, 1) + 0.1 .
    end.
    else 
    do:

        if p-dec - TRUNCATE (p-dec, 1) > 0
            then 
        do:
            p-int = TRUNCATE (p-dec, 1) - 0.1.
        end.
        else 
        do:
            assign
                p-int = TRUNCATE (p-dec, 1) .
            .
        end.
    end.

    return p-int .
end function. /* round */

function round-minDec returns decimal  /* Округление число до целого в меньшую сторону*/
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .  
    if p-dec - TRUNCATE (p-dec, 1) < 0
        then 
    do:
        if TRUNCATE (p-dec, 1) = 0 then p-int = TRUNCATE (p-dec, 1) .
        else p-int = TRUNCATE (p-dec, 1) - 0.1 .
    end.
    else 
    do:
        if p-dec - TRUNCATE (p-dec, 1) > 0
            then 
        do:
            p-int = TRUNCATE (p-dec, 1) - 0.1.
        end.
        else 
        do:
            assign
                p-int = p-dec
                .
        end.
    end.
    return p-int .
end function. /* round */