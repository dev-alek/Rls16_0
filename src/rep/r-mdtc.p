block-level on error undo, throw.
/*

$Revision: 0ce804be5b42, 140, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:48:28 2015 +0400 $
$Workfile: r-mdtc.p $
$Archive: rep/r-mdtc.p $

Движение одноразовой посуды по кафе (Роснефть)

Автор: Харитонов Владимир Александрович
Дата создания: 03/25/2013
Author: Kharitonov Vladimir
Creation date: 03/25/2013

#2789

*/

define variable vss-revision    as character no-undo init "$Revision: 0ce804be5b42, 140, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:28 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-mdtc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-mdtc.p $":U .
define variable vss-description as character no-undo init "Движение одноразовой посуды по кафе (Роснефть)".

define variable g#gds-engl       as logical    no-undo .
define variable g#log            as logical    no-undo .
define variable g#quest-print    as logical    no-undo .
define variable g#report-num     as integer    no-undo .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ gbl/ggoattr.i      }
{ ref/grplibfn.i     }
{ rep/r-sym.i        }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ trg/factord.i      }
{ rep/ostatok.i      }

/* для вывода в excel */
{ gbl/paramls.i   }
{ rep/r-mdtc-xl.i }

define variable v-all-units as character no-undo.

define stream Out-Stream.

define temp-table tt-line no-undo
    field artic as character
    field prod-type as character
    field prod-code as integer
    field obj-type as character
    field obj-code as integer
        
    field gds-name as character
    field unit-base as character
    field start-qnty as decimal /* остаток на начальную дату */
    field end-qnty as decimal /* остаток на конечную дату */
    field all-rcv-qnty as decimal /* весь приход за интервал */
    field all-spent-qnty as decimal /* весь расход за интервал */
    
    index pi as unique artic prod-type prod-code obj-type obj-code
.

&GLOBAL-DEFINE FRM_WIDTH 150

define frame frm1
        sym1
        tt-line.gds-name        format "x(50)"
        sym2
        tt-line.start-qnty      format "      ->>>,>>>,>>9.99"
        sym3
        tt-line.all-rcv-qnty    format "      ->>>,>>>,>>9.99"
        sym4
        tt-line.all-spent-qnty  format "      ->>>,>>>,>>9.99"
        sym5
        tt-line.end-qnty        format "      ->>>,>>>,>>9.99"
        sym6
    header
        fill("-", {&FRM_WIDTH}) format "x({&FRM_WIDTH})" skip
        subst(
            ": НАИМЕНОВАНИЕ                                       : Остаток на &1 :              Получено :         Израсходовано : Остаток на &2 :",
            string(x-Date-Start, "99/99/9999"),
            string(x-Date-End, "99/99/9999")
        ) format "x({&FRM_WIDTH})"
with width {&FRM_WIDTH} down stream-io use-text NO-BOX NO-LABELS
.

/* подготовка потока */
run prepare-rep.

/* заполнение таблицы tt-line товарами на объектах */
run fill-goods.

/* заполняем название и ед. измерения товара */
run fill-info.

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

/* если товар входит в группу с атрибутом НЕ ВКЛЮЧАТЬ В АВТООТЧЕТНОСТЬ то вернет TRUE */
function gds-in-grp returns logical(
                                    p-artic as character,
                                    p-prod-type as character,
                                    p-prod-code as integer
                                ):
    define variable v-upper-code as integer no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    
    define buffer lc_goods for ub.goods.
    define buffer lc_gds-grp for ub.gds-grp.
    
    find first lc_goods
        where lc_goods.artic = p-artic
        and lc_goods.prod-type = p-prod-type
        and lc_goods.prod-code = p-prod-code
        no-lock.
    
    v-upper-code = lc_goods.grp-code.
    
    /* спускаемся к корневой группе, как бы наследование атрибутов проверяем */
    do while v-upper-code > 0 :
        
        find first lc_gds-grp
            where lc_gds-grp.node-code = v-upper-code
            no-lock.    
             
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input {&ggoattr-no-inc-auto-rep},
          output v-value,
          output v-type
        ).
        
        if v-value = "yes" then
            return true.
        else
            v-upper-code = lc_gds-grp.upper-code.
    end. /* do while v-upper-code > 0 */
    
    return false.
end.

procedure fill-info:
    define buffer lc_goods for ub.goods.    
    
    for each tt-line no-lock:
        
        find first lc_goods no-lock
            where lc_goods.artic = tt-line.artic
            and lc_goods.prod-type = tt-line.prod-type
            and lc_goods.prod-code = tt-line.prod-code.
            
        assign
            tt-line.gds-name = lc_goods.gds-name
            tt-line.unit-base = lc_goods.unit-base
        . 
        
        /* не должны повторяться единицы */
        if lookup(tt-line.unit-base, v-all-units) = 0 then do:
            v-all-units = v-all-units + (if v-all-units = "" then "" else ", ") + tt-line.unit-base.
        end.
        
    end. /* for each tt-line */
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

procedure calc:    
    define variable v-factord-start as decimal no-undo.
    define variable v-factord-end   as decimal no-undo.
    define variable tmp             as decimal no-undo.
    define variable v-has-ob        as logical no-undo. /* есть ли движения хоть какие нить по ot-line */
    
    define buffer lc_stk-line for ub.stk-line.
    define buffer lc_ot-line for ub.ot-line.
    
    /* если нет выбранны смены, то фактордеры считаем так */
    if not x-TOG-Shift then do:
        run day-begin-fact-order(x-Date-Start, output v-factord-start).
        run factord-end-day(x-Date-End, output v-factord-end).
    end.
    
    for each tt-line:
        /* если смены выбранны, то получает фактордеры через ostatok.i, немного не правильно конечно, но нет другого способа ( или писать самому ) */
        if x-TOG-Shift then do:
            run ostatok(
                tt-line.obj-code,
                tt-line.obj-type,
                x-TOG-Shift,
                x-Date-Start - 1,
                date(''),
                x-Shift-Start,
                x-Shift-End,
                {&arh-cost},
                {&root-cat-id},
                true,
                output tmp,
                output tmp,
                output tmp,
                output tmp,
                output tmp,
                output v-factord-start
            ).
            
            run ostatok(
                tt-line.obj-code,
                tt-line.obj-type,
                x-TOG-Shift,
                x-Date-Start,
                x-Date-End,
                x-Shift-Start,
                x-Shift-End,
                {&arh-cost},
                {&root-cat-id},
                true,
                output tmp,
                output tmp,
                output tmp,
                output tmp,
                output tmp,
                output v-factord-end
            ).
        end.

        /* находим остатки на начальную дату */
        find last lc_stk-line
            where lc_stk-line.obj-code = tt-line.obj-code
            and lc_stk-line.obj-type = tt-line.obj-type
            and lc_stk-line.fact-order <= v-factord-start
            and lc_stk-line.cat-id = {&root-cat-id}
            and lc_stk-line.sum-type = {&arh-cost}
            and lc_stk-line.artic = tt-line.artic
            and lc_stk-line.prod-type = tt-line.prod-type
            and lc_stk-line.prod-code = tt-line.prod-code
            no-lock no-error.
        
        /* предположительно на новом объекте небыло линий, на всякий случай */
        if not avail lc_stk-line then
            tt-line.start-qnty = 0.
        else
            tt-line.start-qnty = lc_stk-line.fact-qnty.
        
        /* находим остатки на конечную дату */
        find last lc_stk-line
            where lc_stk-line.obj-code = tt-line.obj-code
            and lc_stk-line.obj-type = tt-line.obj-type
            and lc_stk-line.fact-order <= v-factord-end
            and lc_stk-line.cat-id = {&root-cat-id}
            and lc_stk-line.sum-type = {&arh-cost}
            and lc_stk-line.artic = tt-line.artic
            and lc_stk-line.prod-type = tt-line.prod-type
            and lc_stk-line.prod-code = tt-line.prod-code
            no-lock no-error.
        
        /* нужно ли???? */
        if not avail lc_stk-line then
            tt-line.end-qnty = 0.
        else
            tt-line.end-qnty = lc_stk-line.fact-qnty.
        
        v-has-ob = false.
        
        /* идем по архиву */
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
                v-has-ob = true.
                
                case lc_ot-line.ext-doc-type:
                   when {&TDEDT_Pri_Vnesh}           or
                   when {&TDEDT_Pri_Perem}           or
                   when {&TDEDT_Vozvrat_Perem}       or
                   when {&TDEDT_Pri_Prvo} then do:
                       /* сумируем все приходы */
                       tt-line.all-rcv-qnty = tt-line.all-rcv-qnty + lc_ot-line.fact-qnty.
                   end.
                   when {&TDEDT_Ras_Vnesh}           or
                   when {&TDEDT_Ras_Vnesh_Kass}      or
                   when {&tdedt_ras_vnesh_vp}        or
                   when {&tdedt_spi_vnesh}           or
                   when {&TDEDT_Ras_Perem}           or
                   when {&TDEDT_Ras_Prvo}            or
                   when {&TDEDT_Spi_Prvo} then do:                   
                       /* сумируем все расходы */
                       tt-line.all-spent-qnty = tt-line.all-spent-qnty - lc_ot-line.fact-qnty.
                   end.
                   otherwise do:
                        if lc_ot-line.ext-doc-type = {&TDEDT_Inv} and  lc_ot-line.fact-qnty > 0 then
                        tt-line.all-rcv-qnty = tt-line.all-rcv-qnty + lc_ot-line.fact-qnty.
                        else if lc_ot-line.ext-doc-type = {&TDEDT_Inv} and lc_ot-line.fact-qnty <= 0 then
                        tt-line.all-spent-qnty = tt-line.all-spent-qnty - lc_ot-line.fact-qnty.
                   end. 
               end. /* case lc_ot-line.ext-doc-type: */
        end. /* for each lc_ot-line */
        
        /* нет движения, удаляем линию */
        if not v-has-ob then
            delete tt-line.
            
    end. /* for each tt-line */
end.

/* создание линии с товаром для объекта */
procedure create-line:
    define input parameter p-artic as character no-undo.
    define input parameter p-prod-type as character no-undo.
    define input parameter p-prod-code as integer no-undo.
    define input parameter p-obj-type as character no-undo.
    define input parameter p-obj-code as integer no-undo.
        
    if not gds-in-grp(p-artic, p-prod-type, p-prod-code) then
        return.
    
    find first tt-line
        where tt-line.artic = p-artic
        and tt-line.prod-type = p-prod-type
        and tt-line.prod-code = p-prod-code
        and tt-line.obj-type = p-obj-type
        and tt-line.obj-code = p-obj-code
        no-error.
    
    if not avail tt-line then do:
        create tt-line.
        assign
            tt-line.artic = p-artic
            tt-line.prod-type = p-prod-type
            tt-line.prod-code = p-prod-code
            tt-line.obj-type = p-obj-type
            tt-line.obj-code = p-obj-code
        .
    end.
end.

procedure format-rep:
    define variable v-sum-start-qnty as decimal no-undo.
    define variable v-sum-all-rcv-qnty as decimal no-undo.
    define variable v-sum-all-spent-qnty as decimal no-undo.
    define variable v-sum-end-qnty as decimal no-undo.
    
    for each obj-list:
        
        /* для нового эксель документа, 1 для каждого объекта */
        run mdtcxl-init.
        
        /* шапка в excel */
        run mdtcxl-write-cell-data(
            {&mdtcxl-obj_num_1},
            "движение одноразовой посуды по кафе АЗК № " + string(obj-list.obj-code)
        ).
        run mdtcxl-write-cell-data(
            {&mdtcxl-obj_num_2},
            "Количество одноразовой посуды, полученной в кафе на АЗК № " + string(obj-list.obj-code)
        ).
        run mdtcxl-write-cell-data(
            {&mdtcxl-date_interval},
            subst("период с &1 по &2г.", string(x-Date-Start, "99/99/9999"), string(x-Date-End, "99/99/9999"))
        ).
        run mdtcxl-write-cell-data(
            {&mdtcxl-start_date_header},
            "Остаток на " + string(x-Date-Start, "99/99/99")
        ).
        run mdtcxl-write-cell-data(
            {&mdtcxl-end_date_header},
            "Остаток на " + string(x-Date-End, "99/99/99")
        ).
        
        /* шапка */
        put stream Out-Stream unformatted
        skip
        fill(" ", 100) "ОАО 'РН-Москва' " skip(2)
        fill(" ", 74) "Отчет " skip
        fill(" ", 55) "Движение одноразовой посуды по кафе АЗК № " obj-list.obj-code skip
        fill(" ", 50) "Количество одноразовой посуды, полученной в кафе на АЗК № " obj-list.obj-code skip
        fill(" ", 60) "период с " string(x-Date-Start, "99/99/9999") " по " string(x-Date-End, "99/99/9999") "г." skip
        .
        
        assign
            v-sum-start-qnty = 0
            v-sum-all-rcv-qnty = 0
            v-sum-all-spent-qnty = 0
            v-sum-end-qnty = 0
        .
        
        /* таблица */
        for each tt-line no-lock
            where tt-line.obj-code = obj-list.obj-code
            and tt-line.obj-type = obj-list.obj-type
            :
                v-sum-start-qnty = v-sum-start-qnty + tt-line.start-qnty.
                v-sum-all-rcv-qnty = v-sum-all-rcv-qnty + tt-line.all-rcv-qnty.
                v-sum-all-spent-qnty = v-sum-all-spent-qnty + tt-line.all-spent-qnty.
                v-sum-end-qnty = v-sum-end-qnty + tt-line.end-qnty.
    
                run mdtcxl-sheet1-write-line-data(
                    tt-line.gds-name,
                    tt-line.unit-base,
                    tt-line.start-qnty,
                    tt-line.all-rcv-qnty,
                    tt-line.all-spent-qnty,
                    tt-line.end-qnty
                ).
                
                disp stream Out-Stream
                    sym1
                    subst("&1, &2", tt-line.gds-name, tt-line.unit-base) @ tt-line.gds-name
                    sym2
                    "" @ tt-line.start-qnty
                    sym3
                    "" @ tt-line.all-rcv-qnty
                    sym4
                    "" @ tt-line.all-spent-qnty
                    sym5
                    "" @ tt-line.end-qnty
                    sym6
                with frame frm1.
                down stream Out-Stream with frame frm1.
                
                disp stream Out-Stream
                    sym1
                    "Кол-во" @ tt-line.gds-name
                    sym2
                    tt-line.start-qnty
                    sym3
                    tt-line.all-rcv-qnty
                    sym4
                    tt-line.all-spent-qnty
                    sym5
                    tt-line.end-qnty
                    sym6
                with frame frm1.
                down stream Out-Stream with frame frm1.
        end. /* for each tt-line */
        
        /* итоги в excel */
        run mdtcxl-write-cell-data(
            {&mdtcxl-Sheet1_it_start_qnty},
            v-sum-start-qnty
        ).
        run mdtcxl-write-cell-data(
            {&mdtcxl-Sheet1_it_all_rcv_qnty},
            v-sum-all-rcv-qnty
        ).
        run mdtcxl-write-cell-data(
            {&mdtcxl-Sheet1_it_all_spent_qnty},
            v-sum-all-spent-qnty
        ).
        run mdtcxl-write-cell-data(
            {&mdtcxl-Sheet1_it_end_qnty},
            v-sum-end-qnty
        ).
        
        /* итог таблицы */
        put stream Out-Stream unformatted fill("-", {&FRM_WIDTH}) format "x(150)" skip.
        
        disp stream Out-Stream
            sym1
            "Итого" @ tt-line.gds-name
            sym2
            "" @ tt-line.start-qnty
            sym3
            "" @ tt-line.all-rcv-qnty
            sym4
            "" @ tt-line.all-spent-qnty
            sym5
            "" @ tt-line.end-qnty
            sym6
        with frame frm1.
        down stream Out-Stream with frame frm1.
        
        disp stream Out-Stream
            sym1
            "Количество" @ tt-line.gds-name
            sym2
            v-sum-start-qnty @ tt-line.start-qnty
            sym3
            v-sum-all-rcv-qnty @ tt-line.all-rcv-qnty
            sym4
            v-sum-all-spent-qnty @ tt-line.all-spent-qnty
            sym5
            v-sum-end-qnty @ tt-line.end-qnty
            sym6
        with frame frm1.
        down stream Out-Stream with frame frm1.
        
        put stream Out-Stream unformatted fill("-", {&FRM_WIDTH}) format "x(150)" skip.
        
        /* подвал в excel */
        run mdtcxl-write-cell-data(
            {&mdtcxl-obj_num_3},
            subst("Произвели снятие остатков одноразовой посуды в кафе на АЗК № &1  &2", string(obj-list.obj-code), string(today, "99/99/9999"))
        ).
        
        /* подвал отчета, всякие там подписи */
        put stream Out-Stream unformatted
        skip(2)
        "Комиссия в составе: " space(20) "Администратор т/з" space(20) fill("_", 30) skip
        space(40) "Старший оператор" space(21) fill("_", 30) skip
        space(40) "Оператор-продавец" space(20) fill("_", 30) skip(2)
        subst("Произвели снятие остатков одноразовой посуды в кафе на АЗК № &1    &2", obj-list.obj-code, string(today, "99/99/9999")) skip(2)
        "Подпись членов комиссии:" space(16) "Администратор т/з" space(20) fill("_", 30) skip
        space(40) "Старший оператор" space(21) fill("_", 30) skip
        space(40) "Оператор-продавец" space(20) fill("_", 30) skip(2)
        .
        
        /* быват проблемы при нескольких объектах, по этому переходим на новую страницу */
        page stream Out-Stream.
        
        run mdtcxl-close.
    end. /* for each obj-list */
end.
