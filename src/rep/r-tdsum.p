block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-tdsum.p $
$Archive: rep/r-tdsum.p $

—уточные сводки (“амбовЌѕ)

јвтор: ’аритонов ¬ладимир јлександрович
ƒата создани€: 04/22/2013
Author: Kharitonov Vladimir
Creation date: 04/22/2013

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-tdsum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-tdsum.p $":U .
define variable vss-description as character no-undo init "—уточные сводки (“амбовЌѕ)".

define variable g#gds-engl       as logical    no-undo .
define variable g#log            as logical    no-undo .
define variable g#quest-print    as logical    no-undo .
define variable g#report-num     as integer    no-undo .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ str/lib-trn.i      }
{ gbl/ggoattr.i      }
{ ref/grplibfn.i     }
{ rep/r-sym.i        }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ trg/factord.i      }
{ rep/ostatok.i      }

/* дл€ вывода в excel */
{ gbl/paramls.i   }
{ rep/r-tdsum-xl.i }

define variable v-all-units as character no-undo.

define stream Out-Stream.

define temp-table tt-line no-undo
    field artic as character
    field prod-type as character
    field prod-code as integer
    field obj-type as character
    field obj-code as integer
    field gds-code as integer    
    
    field gds-name as character /* название товара */
    field is-petrol as logical /* топливный? */
    field qnty-start-month as decimal /* реализаци€ за мес€ц ( пока литры ) дл€ топливных */
    field qnty-start-day as decimal /* реализаци€ за сутки ( пока литры ) дл€ топливных */
    field price-end-shift as decimal /* цена на конец сменных суток */
    field price-shift-change as decimal /* изменени€ цены за сутки */
    field sum-day as decimal /* выручка за сутки */
    field sum-month as decimal /* выручка за мес€ц */
    
    index pi as unique artic prod-type prod-code obj-type obj-code
    index pi2 as unique primary gds-code obj-type obj-code
.

/* дл€ сумм по объектам по не топливным товарам */
define temp-table tt-sum no-undo
    field obj-type as character
    field obj-code as integer
    
    field sum-day as decimal
    field sum-month as decimal
    
    index pi as unique obj-type obj-code
.

/* подготовка потока */
run prepare-rep.

/* заполнение таблицы tt-line товарами на объектах */
run fill-goods.

/* расчет количеств */
run calc.

/* формируем отчет */
run format-rep.

/* остальное */
run close-rep.

procedure prepare-rep:
    run get-gds-engl    in my-handle ( output g#gds-engl ).
    run get-quest-print in my-handle ( output g#quest-print ).
    run get-report-num  in my-handle ( output g#report-num ).
    
    { cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4}  }
    
    put stream Out-Stream UNFORMATTED "ќтчет доступен только в формате Excel.".
end.

procedure close-rep:
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable ReportFontNum   as integer   no-undo .
    
    output stream Out-Stream close.
            
    run gbl/prnfilen.w
        ( input  ""
        , input  8
        , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
        , input  ReportFontNum
        , output v-user-action
        , output v-printed
        ) .
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
end.

procedure fill-goods:
    define variable v-grp-fullname as character no-undo.
    
    define buffer lc_goods for ub.goods.
    define buffer lc_gds-obj for ub.gds-obj.

    /* список всех выбранных объектов */
    for each obj-list no-lock:
        
        /* все по объекту */
        case x-SelectGood:
            when {&g-all} then do: /* все товары на объекте */
                             
                 for each lc_gds-obj no-lock
                    where lc_gds-obj.obj-type = obj-list.obj-type
                    and lc_gds-obj.obj-code = obj-list.obj-code
                    :   
                        run create-line(
                            lc_gds-obj.artic,
                            lc_gds-obj.prod-type,
                            lc_gds-obj.prod-code,
                            lc_gds-obj.obj-type,
                            lc_gds-obj.obj-code
                        ).                    
                 end. /* for each lc_gds-obj */
            end. /* when {&g-all} */
            /* все по производителю и на объекте */
            when {&g-prod} then do:
                
                for each g#cli no-lock:
                    
                    for each lc_gds-obj no-lock
                        where lc_gds-obj.obj-type = obj-list.obj-type
                        and lc_gds-obj.obj-code = obj-list.obj-code
                        and lc_gds-obj.prod-type = g#cli.obj-type
                        and lc_gds-obj.prod-code = g#cli.obj-code
                        :
                            run create-line(
                                lc_gds-obj.artic,
                                lc_gds-obj.prod-type,
                                lc_gds-obj.prod-code,
                                lc_gds-obj.obj-type,
                                lc_gds-obj.obj-code
                            ).
                    end. /* for each lc_gds-obj */
                        
                end. /* for each g#cli */
                
            end. /* when {&g-prod} */
            /* все по группе и по объекту */
            when {&g-grp} then do:
                
                for each tmp#grp no-lock:
                    
                    run grplib-get-full-name(tmp#grp.node-code, output v-grp-fullname).
                    
                    for each lc_gds-obj no-lock
                        where lc_gds-obj.obj-type = obj-list.obj-type
                        and lc_gds-obj.obj-code = obj-list.obj-code
                        and lc_gds-obj.grp-name begins v-grp-fullname
                        :
                            run create-line(
                                lc_gds-obj.artic,
                                lc_gds-obj.prod-type,
                                lc_gds-obj.prod-code,
                                lc_gds-obj.obj-type,
                                lc_gds-obj.obj-code
                            ).
                    end. /* for each lc_gds-obj */
                    
                end. /* for each tmp#grp */
                
            end. /* when {&g-grp} */
            /* остальные берем по объекту и по списку */
            otherwise do:
                
                for each gds-list no-lock:
                    
                    for each lc_gds-obj no-lock
                        where lc_gds-obj.obj-type = obj-list.obj-type
                        and lc_gds-obj.obj-code = obj-list.obj-code
                        and lc_gds-obj.artic = gds-list.artic
                        and lc_gds-obj.prod-type = gds-list.prod-type
                        and lc_gds-obj.prod-code = gds-list.prod-code
                        :
                            run create-line(
                                lc_gds-obj.artic,
                                lc_gds-obj.prod-type,
                                lc_gds-obj.prod-code,
                                lc_gds-obj.obj-type,
                                lc_gds-obj.obj-code
                            ).                         
                    end. /* for each lc_gds-obj */
                    
                end. /* for each gds-list */
                
            end. /* otherwise do */
        end.
        
    end.
end.

/* ищем фактордера ( от и до ) вне зависимости - смена или дата */
procedure get-factord:
    define input parameter p-obj-type       as character no-undo.
    define input parameter p-obj-code       as integer   no-undo.
    define input parameter p-shift-date     as date      no-undo.
    define input parameter p-shift-num      as integer   no-undo.
    define input parameter p-type           as integer   no-undo.
    define output parameter p-factord        as decimal   no-undo.
    
    define variable tmp as decimal no-undo.
    
    /* 
         p-type:
    1 - начало смены
    2 - конец смены
    
    */
    
    if p-type = 1 and p-shift-num > 0 then
        run ostatok(
            p-obj-code,
            p-obj-type,
            true,
            p-shift-date - 1,
            date(''),
            p-shift-num,
            p-shift-num,
            {&arh-cost},
            {&root-cat-id},
            true,
            output tmp,
            output tmp,
            output tmp,
            output tmp,
            output tmp,
            output p-factord
        ).
    else if p-type = 2 and p-shift-num > 0 then
        run ostatok(
            p-obj-code,
            p-obj-type,
            true,
            p-shift-date,
            p-shift-date,
            p-shift-num,
            p-shift-num,
            {&arh-cost},
            {&root-cat-id},
            true,
            output tmp,
            output tmp,
            output tmp,
            output tmp,
            output tmp,
            output p-factord
        ).
    else if p-type = 1 then
        run day-begin-fact-order(p-shift-date, output p-factord).
    else if p-type = 2 then
        run factord-end-day(p-shift-date, output p-factord).
end.

procedure calc:
    for each tt-line:
        run calc-day.
        run calc-month.
        
        if tt-line.is-petrol then
            run calc-price.
    end. /* for each tt-line */
    
    run calc-sum-etc.
end.

procedure calc-sum-etc:
    for each obj-list,
        each tt-line
        where tt-line.obj-type = obj-list.obj-type
        and tt-line.obj-code = obj-list.obj-code
        break by obj-list.obj-code:
            
            if first-of(obj-list.obj-code) then do:
                create tt-sum.
                assign
                    tt-sum.obj-type = obj-list.obj-type
                    tt-sum.obj-code = obj-list.obj-code
                    tt-sum.sum-day = tt-line.sum-day
                    tt-sum.sum-month = tt-line.sum-month
                .
            end.
            else do:
                assign
                    tt-sum.sum-day = tt-sum.sum-day + tt-line.sum-day.
                    tt-sum.sum-month = tt-line.sum-month + tt-line.sum-month.
                .
            end.
    end.
end.

/* получение цены на конец сменных суток и изменение за сутки */
procedure calc-price:
    define variable v-b-code as integer no-undo.
    define variable v-doc-num as integer no-undo.
    define variable v-price-sale as integer no-undo.
    define variable v-road-tax as integer no-undo.
    define variable v-excise as integer no-undo.
    define variable v-factord-end as decimal no-undo.
    define variable v-factorder-last as decimal no-undo.
    define variable v-prev-date as date no-undo.
    
    run get-factord(
        tt-line.obj-type,
        tt-line.obj-code,
        x-Date-Start,
        x-Shift-Start,
        2,
        output v-factord-end
    ).

    /* ищем баркод по гдс коду */
    { gbl/gdsbcode.i
      tt-line.gds-code
      ?
      v-b-code
      no-error
    }
    
    /* получаем цену на нужную дату */
    { gbl/bcodeprc.i
      tt-line.obj-type
      tt-line.obj-code
      v-b-code
      0
      v-factord-end
      v-doc-num
      v-price-sale
      v-road-tax
      v-excise
    }
    
    if v-price-sale = ? then
        v-price-sale = 0.
        
    tt-line.price-end-shift = v-price-sale.
    
    /* теперь получим цену за предыдущие сутки */
    
    v-prev-date = add-interval(today, -1, "days").    
    run factord-end-day(v-prev-date, output v-factorder-last).
    
    { gbl/bcodeprc.i
      tt-line.obj-type
      tt-line.obj-code
      v-b-code
      0
      v-factorder-last
      v-doc-num
      v-price-sale
      v-road-tax
      v-excise
    }
    
    if v-price-sale = ? then
        v-price-sale = 0.
        
    tt-line.price-shift-change = tt-line.price-end-shift - v-price-sale.
end.

procedure calc-month:
    define variable v-factord-start as decimal no-undo.
    define variable v-factord-end   as decimal no-undo.
    define variable v-date          as date    no-undo.
    
    define buffer lc_ot-line for ub.ot-line.
    
    v-date = add-interval(x-Date-Start, -1, "months").
    
    /* ищем фактордера за мес€ц */
    run get-factord(
        tt-line.obj-type,
        tt-line.obj-code,
        v-date,
        0,
        1,
        output v-factord-start
    ).
    run get-factord(
        tt-line.obj-type,
        tt-line.obj-code,
        x-Date-Start,
        0,
        2,
        output v-factord-end
    ).

    /* считаем кол-во за мес€ц */
    for each lc_ot-line no-lock
        where lc_ot-line.artic = tt-line.artic
        and lc_ot-line.prod-type = tt-line.prod-type
        and lc_ot-line.prod-code = tt-line.prod-code
        and lc_ot-line.obj-type = tt-line.obj-type
        and lc_ot-line.obj-code = tt-line.obj-code
        and lc_ot-line.cat-id = {&root-cat-id}
        and lc_ot-line.sum-type = {&arh-cost}
        and lc_ot-line.fact-order >= v-factord-start
        and lc_ot-line.fact-order <= v-factord-end
        :
            /* если возврат через кассу, то вычитаем */
            if lc_ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} then do:
                
                /* дл€ топлива кол-во */
                if tt-line.is-petrol then
                    tt-line.qnty-start-month = tt-line.qnty-start-month + lc_ot-line.fact-qnty.
                else
                    tt-line.sum-month = tt-line.sum-month + lc_ot-line.sum-rubl.
            end.            
            /* если расход внеш через кассу, суммируем */
            else if lc_ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} then do:

                /* если не топливо, то сумма */
                if tt-line.is-petrol then
                    tt-line.qnty-start-month = tt-line.qnty-start-month - lc_ot-line.fact-qnty.
                else
                    tt-line.sum-month = tt-line.sum-month - lc_ot-line.sum-rubl.
            end.
    end. /* for each lc_ot-line */
end.

procedure calc-day:
    define variable v-factord-start as decimal no-undo.
    define variable v-factord-end   as decimal no-undo.
    
    define buffer lc_ot-line for ub.ot-line.
    
    /* ищем фактордера за мес€ц */
    run get-factord(
        tt-line.obj-type,
        tt-line.obj-code,
        x-Date-Start,
        x-Shift-Start,
        1,
        output v-factord-start
    ).
    run get-factord(
        tt-line.obj-type,
        tt-line.obj-code,
        x-Date-Start,
        x-Shift-Start,
        2,
        output v-factord-end
    ).

    /* считаем кол-во за сутки */
    for each lc_ot-line no-lock
        where lc_ot-line.artic = tt-line.artic
        and lc_ot-line.prod-type = tt-line.prod-type
        and lc_ot-line.prod-code = tt-line.prod-code
        and lc_ot-line.obj-type = tt-line.obj-type
        and lc_ot-line.obj-code = tt-line.obj-code
        and lc_ot-line.cat-id = {&root-cat-id}
        and lc_ot-line.sum-type = {&arh-cost}
        and lc_ot-line.fact-order >= v-factord-start
        and lc_ot-line.fact-order <= v-factord-end
        :
            /* если возврат через кассу, то вычитаем */
            if lc_ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} then do:
                
                /* дл€ топлива кол-во */
                if tt-line.is-petrol then
                    tt-line.qnty-start-day = tt-line.qnty-start-day + lc_ot-line.fact-qnty.
                else
                    tt-line.sum-day = tt-line.sum-day + lc_ot-line.sum-rubl.
            end.
            /* если расход внеш через кассу, суммируем */
            else if lc_ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} then do:
                
                /* если не топливо, то сумма */
                if tt-line.is-petrol then
                    tt-line.qnty-start-day = tt-line.qnty-start-day - lc_ot-line.fact-qnty.
                else
                    tt-line.sum-day = tt-line.sum-day - lc_ot-line.sum-rubl.
            end.
    end. /* for each lc_ot-line */
end.

/* создание линии с товаром дл€ объекта */
procedure create-line:
    define input parameter p-artic as character no-undo.
    define input parameter p-prod-type as character no-undo.
    define input parameter p-prod-code as integer no-undo.
    define input parameter p-obj-type as character no-undo.
    define input parameter p-obj-code as integer no-undo.
    
    define variable v-is-pieces as logical no-undo.
    
    define buffer lc_goods for ub.goods.
    
    find first tt-line
        where tt-line.artic = p-artic
        and tt-line.prod-type = p-prod-type
        and tt-line.prod-code = p-prod-code
        and tt-line.obj-type = p-obj-type
        and tt-line.obj-code = p-obj-code
        no-error.
    
    if not avail tt-line then do:
        
        find first lc_goods no-lock
            where lc_goods.artic = p-artic
            and lc_goods.prod-type = p-prod-type
            and lc_goods.prod-code = p-prod-code.
        
        create tt-line.
        assign
            tt-line.gds-code = lc_goods.gds-code
            tt-line.artic = p-artic
            tt-line.prod-type = p-prod-type
            tt-line.prod-code = p-prod-code
            tt-line.obj-type = p-obj-type
            tt-line.obj-code = p-obj-code
            tt-line.gds-name = lc_goods.gds-name
        .
        
        { str/is-petrl.i
          tt-line.artic
          tt-line.prod-type
          tt-line.prod-code
          tt-line.is-petrol
          v-is-pieces
        }
        
    end.
end.

procedure format-rep:
    define variable v-org-name as character no-undo.
    define variable v-org-code as integer no-undo.
    define variable v-shop-num as character no-undo.
    define variable v-sum-day as character no-undo.
    define variable v-sum-month as character no-undo.
    
    run tdsxl-init.
    
    /* пишем название фирмы */
    find first obj-list.    
    { gbl/hostname.i
      obj-list.obj-type
      obj-list.obj-code
      v-org-code
      v-org-name
    }    
    run tdsxl-write-cell-data({&tdsxl-org_name}, v-org-name).
    
    /* пишем дату */
    run tdsxl-write-cell-data({&tdsxl-date_day}, day(today)).
    run tdsxl-write-cell-data({&tdsxl-date_month}, month(today)).
    run tdsxl-write-cell-data({&tdsxl-date_year}, year(today)).

    for each obj-list,
        each tt-line
            where tt-line.obj-type = obj-list.obj-type
            and tt-line.obj-code = obj-list.obj-code
            and tt-line.is-petrol,
        first tt-sum
            where obj-list.obj-type = tt-sum.obj-type
            and obj-list.obj-code = tt-sum.obj-code
        break by obj-list.obj-code
        by tt-line.gds-name:
            
            if first-of(obj-list.obj-code) then do:
                assign
                    v-shop-num = string(obj-list.obj-code)
                    v-sum-day = string(tt-sum.sum-day)
                    v-sum-month = string(tt-sum.sum-month)
                .
            end.
            else do:
                assign
                    v-shop-num = ""
                    v-sum-day = ""
                    v-sum-month = ""
                .
            end.
            
            run tdsxl-sheet1-write-line-data(
                v-shop-num,
                tt-line.gds-name,
                tt-line.qnty-start-day,
                tt-line.qnty-start-month,
                tt-line.price-end-shift,
                tt-line.price-shift-change,
                v-sum-day,
                v-sum-month
            ).
    end.
    
    run tdsxl-close.
end.
