/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Шкляр Елена
Дата создания: 08/28/07
Author: Elena Shklyar
Creation date: 08/28/07

*/
define buffer buf_shift-param for ub.shift-param .
define buffer buf_rvs-doc       for ub.rvs-doc .
define buffer buf_rvs-line      for ub.rvs-line .
define buffer buf_chk-doc       for ub.chk-doc .
define buffer buf_chk-gds       for ub.chk-gds.
define buffer bf_chk-gds        for ub.chk-gds.
define buffer buf_bar-code      for ub.bar-code.
define buffer bf_place          for ub.place .
define buffer buf_goods         for ub.goods .
define buffer buf_rvs-line-pump for ub.rvs-line-pump .
define buffer buf_chk-doc-attr  for ub.chk-doc-attr .
define buffer bf_chk-doc-attr   for ub.chk-doc-attr .
define buffer buf_chk-pay       for ub.chk-pay .
define buffer buf_cash-pay      for ub.cash-pay .
define buffer buf_susp-chk      for ub.susp-chk .
define buffer bf_susp-chk       for ub.susp-chk .

define variable v-qnty          like ub.chk-gds.doc-qnty no-undo init 0.
define variable ShiftDate-Start as date      no-undo .
define variable ShiftNum-Start  as integer   no-undo .
define variable v-gds-name      as character no-undo .
define variable v-dop           as decimal   no-undo .
define variable errorTRK        as logical   no-undo init false .
define variable errorMass       as logical   no-undo init false .
define variable errorCheck      as logical   no-undo init false .
define variable v-num           as character no-undo .
define variable v-ok            as logical   no-undo init false.
define variable v-close         as logical   no-undo .
define variable close-date      as date      no-undo .
define variable close-time      as integer   no-undo .

define temp-table t-9 no-undo
    field gds-code           like ub.goods.gds-code
    field gds-name           like ub.goods.gds-name
    field pl-code            like ub.rvs-line-pump.pl-code
    field obj-code           as integer 
    field obj-type           as character
    field shift-date         as date
    field shift-name         as character
    field shift-num          as integer
    field pump-code          like ub.rvs-line-pump.pump-code
    field nozzle-code        like ub.rvs-line-pump.nozzle-code
    field start-mh-qnty      like ub.rvs-line-pump.meas-mh-cnt
    field end-mh-qnty        like ub.rvs-line-pump.meas-mh-cnt
    field meas-qnty          like ub.rvs-line-pump.meas-mh-cnt
    field prev-start-mh-qnty like ub.rvs-line-pump.meas-mh-cnt
    field itog-meas-qnty     like ub.rvs-line-pump.meas-mh-cnt
    field start-el-qnty      like ub.rvs-line-pump.meas-el-cnt
    field end-el-qnty        like ub.rvs-line-pump.meas-el-cnt
    field prev-start-el-qnty like ub.rvs-line-pump.meas-el-cnt
    field sale-kg            as decimal
    field itog-sale          as decimal
    field loc1               as character

    field doc-qnty           as decimal   INITIAL 0
    field delta              as decimal   INITIAL 0
    field itog-delta         as decimal   INITIAL 0
    field cancell-qnty       as decimal   INITIAL 0
    field cancell-qnty-notot as decimal   INITIAL 0
    field overflow-qnty      as decimal   INITIAL 0
    field trans-qnty         as decimal   INITIAL 0
    field tech-refuell-qnty  as decimal   INITIAL 0

    index pi is unique primary
    gds-code
    pump-code
    nozzle-code
    .

define temp-table tt-rvs-line no-undo
    field gds-code         as integer
    field pl-code          as integer
    field gds-name         as character
    field fact-stock-start as decimal
    field fact-stock-end   as decimal
    field rast-stock-end   as decimal 
    field sale-kg          as decimal
    field tech-refuell     as decimal
    field obj-code         as integer
    field obj-type         as character   
    field income           as decimal 
    field loc1             as character
    index pi as unique primary
    gds-code
    pl-code
    .

define temp-table tt-chk-doc like ub.susp-chk
    .
   
define buffer buf_t-9  for t-9 .
define buffer buf2_t-9 for t-9 .

/* Сбор данных по отклонениям и подозрительным чекам */

FIND LAST  buf_shift-obj
    WHERE buf_shift-obj.obj-type = p-curr-obj-type
    AND buf_shift-obj.obj-code = p-curr-obj-code
    and (
    (buf_shift-obj.shift-date = v-shift-date
    AND     buf_shift-obj.shift-num < v-shift-num)
    OR
    buf_shift-obj.shift-date < v-shift-date)
    use-index pi
    NO-LOCK
    NO-ERROR
    .

/* Счетчики на начало */
IF AVAILABLE buf_shift-obj THEN 
DO:
    ShiftDate-Start = buf_shift-obj.shift-date .                                                                                                                              
    ShiftNum-Start = buf_shift-obj.shift-num . 
    
    for each buf_rvs-doc
        where  buf_rvs-doc.obj-type  = p-curr-obj-type
        and   buf_rvs-doc.obj-code   = p-curr-obj-code
        and   buf_rvs-doc.status_    = {&fact}
        and   buf_rvs-doc.shift-date = buf_shift-obj.shift-date
        and   buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
        and   buf_rvs-doc.rvs-type   = {&rvs-shift}
        no-lock:
        for each prev_rvs-line no-lock where prev_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
            prev_rvs-line.obj-code = buf_rvs-doc.obj-code and
            prev_rvs-line.obj-type = buf_rvs-doc.obj-type:
            find first tt-rvs-line where tt-rvs-line.gds-code = prev_rvs-line.gds-code and
                tt-rvs-line.pl-code = prev_rvs-line.pl-code no-error .
            if not available (tt-rvs-line) then
            do:
                create tt-rvs-line .
                assign
                    tt-rvs-line.gds-code = prev_rvs-line.gds-code
                    tt-rvs-line.pl-code  = prev_rvs-line.pl-code
                    .
                find first ub.place no-lock
                    where ub.place.obj-code = prev_rvs-line.obj-code
                    and ub.place.obj-type = prev_rvs-line.obj-type
                    and ub.place.pl-code  = prev_rvs-line.pl-code
                    no-error.
                if available ub.place then 
                do:
                    tt-rvs-line.loc1 = ub.place.loc1              
                        .
                end.                    
            end.
            /* фактический остаток на начало смены */
            tt-rvs-line.fact-stock-start = prev_rvs-line.state-measure-qnty + prev_rvs-line.state-add-qnty * prev_rvs-line.state-density .
        end.


        FOR EACH    buf_rvs-line-pump
            WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
            NO-LOCK
            :
            find first buf_t-9
                WHERE  buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                AND buf_t-9.pump     = buf_rvs-line-pump.pump-code
                and buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                no-error
                .
            if not available buf_t-9 then 
            do:
                find first buf_goods
                    where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                    no-lock
                    no-error
                    .
                IF AVAILABLE buf_goods THEN 
                DO:
                    assign
                        v-gds-name = buf_goods.gds-name
                        .
                END.
                else 
                do:
                    assign
                        v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line-pump.gds-code)
                        .
                end.
                create buf_t-9.
                assign
                    buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                    buf_t-9.pl-code     = buf_rvs-line-pump.pl-code
                    buf_t-9.pump-code   = buf_rvs-line-pump.pump-code
                    buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                    buf_t-9.gds-name    = v-gds-name
                    .
                ASSIGN
                    buf_t-9.start-mh-qnty      = buf_rvs-line-pump.state-mh-cnt
                    buf_t-9.end-mh-qnty        = buf_rvs-line-pump.state-mh-cnt
                    /*это на каждой следующей итерации в meas-qnty будем добавлять*/
                    buf_t-9.prev-start-mh-qnty = buf_rvs-line-pump.state-mh-cnt
                    buf_t-9.start-el-qnty      = buf_rvs-line-pump.state-el-cnt
                    buf_t-9.end-el-qnty        = buf_rvs-line-pump.state-el-cnt
                    /*это на каждой следующей итерации в meas-qnty будем добавлять*/
                    buf_t-9.prev-start-el-qnty = buf_rvs-line-pump.state-el-cnt
                    /*пока до места где вычитаем по чекам delta = обороту по счетчикам*/
                    buf_t-9.delta              = - buf_t-9.meas-qnty
                    .
            end. /*if not available buf_t-9 then do:*/
        END. /*FOR EACH    buf_rvs-line-pump NO-LOCK*/

        RELEASE buf_rvs-doc.
    END. /*IF AVAILABLE buf_rvs-doc THEN DO:*/
END. /*IF AVAILABLE buf_shift-obj THEN DO:*/
for each buf_shift-obj no-lock where
    buf_shift-obj.obj-type = p-curr-obj-type
    and buf_shift-obj.obj-code = p-curr-obj-code
    and (buf_shift-obj.shift-date > v-shift-date
    or (buf_shift-obj.shift-date = v-shift-date
    and
    buf_shift-obj.shift-num >= v-shift-num))
    and
    (buf_shift-obj.shift-date < v-shift-date
    or (buf_shift-obj.shift-date = v-shift-date
    and
    buf_shift-obj.shift-num <= v-shift-num))
    by buf_shift-obj.shift-date
    by buf_shift-obj.shift-num:

    /* Счетчики на конец */
    for first buf_rvs-doc
        where  buf_rvs-doc.obj-type  = p-curr-obj-type
        and   buf_rvs-doc.obj-code   = p-curr-obj-code
        and   buf_rvs-doc.status_    = {&fact}
        and   buf_rvs-doc.shift-date = buf_shift-obj.shift-date
        and   buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
        and   buf_rvs-doc.rvs-type   = {&rvs-shift}
        no-lock:
            assign
            close-date = buf_rvs-doc.fact-date
            close-time = buf_rvs-doc.fact-order
            .
        FOR EACH    buf_rvs-line-pump
            WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
            NO-LOCK
            :
            find first buf_t-9
                WHERE /*buf_t-9.obj-type  = p-obj-type
                  AND buf_t-9.obj-code    = p-obj-code
                  AND*/ buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                AND buf_t-9.pump-code       = buf_rvs-line-pump.pump-code
                and buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                no-error
                .
            if not available buf_t-9 then 
            do:
                find first buf2_t-9
                    WHERE /*buf_t-9.obj-type  = p-obj-type
                AND buf_t-9.obj-code    = p-obj-code
                AND*/  buf2_t-9.pump-code        = buf_rvs-line-pump.pump-code
                    and buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                    no-error
                    .
                /*в конфигурации ДО первой смены НЕ БЫЛО ТАКОЙ ТРК!!!*/
                find first buf_goods
                    where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                    no-lock
                    no-error
                    .
                IF AVAILABLE buf_goods THEN 
                DO:
                    assign
                        v-gds-name = buf_goods.gds-name
                        .
                END.
                else 
                do:
                    assign
                        v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line-pump.gds-code)
                        .
                end.
                create buf_t-9.
                assign
                    /*
                    buf_t-9.obj-type    = p-obj-type
                    buf_t-9.obj-code    = p-obj-code
                    */
                    buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                    buf_t-9.pl-code     = buf_rvs-line-pump.pl-code
                    buf_t-9.pump-code   = buf_rvs-line-pump.pump-code
                    buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                    buf_t-9.gds-name    = v-gds-name
                    .
                if available buf2_t-9 then 
                do:
                    assign
                        buf_t-9.start-mh-qnty      = buf2_t-9.prev-start-mh-qnty
                        buf_t-9.end-mh-qnty        = buf2_t-9.prev-start-mh-qnty
                        buf_t-9.prev-start-mh-qnty = buf2_t-9.prev-start-mh-qnty
                        buf_t-9.start-el-qnty      = buf2_t-9.prev-start-el-qnty
                        buf_t-9.end-el-qnty        = buf2_t-9.prev-start-el-qnty
                        buf_t-9.prev-start-el-qnty = buf2_t-9.prev-start-el-qnty
                        .
                end.
                else 
                do:
                    /*можeт надо из инвентаризации счетчиков взять???*/
                    v-dop = ?.
                    run get-state-mh-cnt-from-icnt-doc in this-procedure (
                        input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input buf_shift-obj.shift-date
                        ,input buf_shift-obj.shift-num
                        ,input buf_rvs-doc.fact-order
                        ,input buf_t-9.gds-code
                        ,input buf_t-9.pl-code
                        ,input buf_t-9.pump-code
                        ,input buf_t-9.nozzle-code
                        ,input-output buf_t-9.prev-start-mh-qnty
                        ,input-output buf_t-9.prev-start-el-qnty
                        ).

                    ASSIGN
                        /*это на каждой следующей итерации в meas-qnty будем добавлять*/
                        buf_t-9.start-mh-qnty = buf_t-9.prev-start-mh-qnty
                        buf_t-9.end-mh-qnty   = buf_t-9.prev-start-mh-qnty
                        buf_t-9.start-el-qnty = buf_t-9.prev-start-el-qnty
                        buf_t-9.end-el-qnty   = buf_t-9.prev-start-el-qnty
                        .
                end.
            end. /*if not available buf_t-9 then do:*/
            if buf_rvs-line-pump.state-mh-cnt <  buf_t-9.end-mh-qnty then 
            do:
                /*был переход через 0*/
                v-dop = ?.
                run get-state-mh-cnt-from-icnt-doc in this-procedure (
                    input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input buf_shift-obj.shift-date
                    ,input buf_shift-obj.shift-num
                    ,input buf_rvs-doc.fact-order
                    ,input buf_t-9.gds-code
                    ,input buf_t-9.pl-code
                    ,input buf_t-9.pump-code
                    ,input buf_t-9.nozzle-code
                    ,input-output buf_t-9.prev-start-mh-qnty
                    ,input-output buf_t-9.prev-start-el-qnty
                    ).
            end.
            ASSIGN
                buf_t-9.end-mh-qnty        = buf_rvs-line-pump.state-mh-cnt
                buf_t-9.end-el-qnty        = buf_rvs-line-pump.state-el-cnt
                buf_t-9.meas-qnty          = buf_t-9.meas-qnty + buf_rvs-line-pump.state-el-cnt - buf_t-9.prev-start-el-qnty
                /*пока до места где вычитаем по чекам delta = обороту по счетчикам*/
                buf_t-9.delta              = - buf_t-9.meas-qnty
                buf_t-9.prev-start-mh-qnty = buf_rvs-line-pump.state-mh-cnt
                buf_t-9.prev-start-el-qnty = buf_rvs-line-pump.state-el-cnt
                .
        END. /*FOR EACH    buf_rvs-line-pump*/
        for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
            buf_rvs-line.obj-code = buf_rvs-doc.obj-code and
            buf_rvs-line.obj-type = buf_rvs-doc.obj-type:
            find first tt-rvs-line where tt-rvs-line.gds-code = buf_rvs-line.gds-code and
                tt-rvs-line.pl-code = buf_rvs-line.pl-code no-error .
            if not available (tt-rvs-line) then 
            do:
                find first buf_goods
                    where buf_goods.gds-code = buf_rvs-line.gds-code
                    no-lock
                    no-error
                    .
                IF AVAILABLE buf_goods THEN 
                DO:
                    assign
                        v-gds-name = buf_goods.gds-name
                        .
                END.
                else 
                do:
                    assign
                        v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line.gds-code)
                        .
                end.
                create tt-rvs-line .
                assign
                    tt-rvs-line.gds-code = buf_rvs-line.gds-code
                    tt-rvs-line.gds-name = v-gds-name
                    tt-rvs-line.pl-code  = buf_rvs-line.pl-code
                    tt-rvs-line.obj-code = buf_rvs-line.obj-code
                    tt-rvs-line.obj-type = buf_rvs-line.obj-type .
                
                find first ub.place no-lock
                    where ub.place.obj-code = buf_rvs-line.obj-code
                    and ub.place.obj-type = buf_rvs-line.obj-type
                    and ub.place.pl-code  = buf_rvs-line.pl-code
                    no-error.
                if available ub.place then 
                do:
                    tt-rvs-line.loc1 = ub.place.loc1              
                        .
                end.    
            end. 
            /* фактический остаток на конец смены */
            tt-rvs-line.fact-stock-end = buf_rvs-line.state-measure-qnty + buf_rvs-line.state-add-qnty * buf_rvs-line.state-density .

        end. /*for each buf_rvs-line */
        
    END. /*IF AVAILABLE buf_rvs-doc THEN DO:*/
end. /*  for each buf_shift-obj no-lock where*/


for each tt-rvs-line:
    /* Все приходы */
    for each ub.trn-doc no-lock
        where ub.trn-doc.obj-type   = p-curr-obj-type
        and ub.trn-doc.obj-code   = p-curr-obj-code
        and ub.trn-doc.shift-date = v-shift-date
        and ub.trn-doc.shift-num = v-shift-num
        and ub.trn-doc.status_    = {&fact}
        and ub.trn-doc.doc-type   = {&income}
        on error undo, return error return-value
        :
        for each ub.doc-pl no-lock
            where ub.doc-pl.gds-code = tt-rvs-line.gds-code
            and ub.doc-pl.obj-code = tt-rvs-line.obj-code
            and ub.doc-pl.obj-type = tt-rvs-line.obj-type
            and ub.doc-pl.out-code = ub.trn-doc.doc-code
            and ub.doc-pl.pl-code  = tt-rvs-line.pl-code
            on error undo, return error return-value
            :

            assign
                tt-rvs-line.income = tt-rvs-line.income + ub.doc-pl.cli-fact-qnty
                .
        end. /*  for each ub.doc-pl  */
    end. /* for each ub.trn-doc where  */
end.

_shift-chk:
FOR EACH buf_chk-doc
    WHERE buf_chk-doc.obj-type = p-curr-obj-type
    AND   buf_chk-doc.obj-code = p-curr-obj-code
    AND   buf_chk-doc.shift-date = v-shift-date
    and  buf_chk-doc.shift-num = v-shift-num 
    and buf_chk-doc.shift-name = v-shift-name
    NO-LOCK
    :

    for each buf_chk-gds
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code 
        no-lock,
        first buf_bar-code
        where buf_bar-code.b-code = buf_chk-gds.b-code
        no-lock,
        first buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock
        :
        find first tt-rvs-line no-lock where tt-rvs-line.gds-code = buf_goods.gds-code no-error .
                
        if available (tt-rvs-line) then 
        do:
            find first buf_t-9
                WHERE
                buf_t-9.gds-code    = buf_bar-code.gds-code and
                buf_t-9.pump-code   = buf_chk-gds.pump and
                buf_t-9.nozzle-code = buf_chk-gds.nozzle-code                
                no-error
                .
            if not available buf_t-9 then 
            do:
                create buf_t-9.
                assign
                    buf_t-9.gds-code    = buf_bar-code.gds-code
                    buf_t-9.gds-name    = buf_goods.gds-name
                    buf_t-9.pl-code     = buf_chk-gds.pl-code
                    buf_t-9.pump-code   = buf_chk-gds.pump 
                    buf_t-9.nozzle-code = buf_chk-gds.nozzle-code 
                    .
            end.
                   
        end.
        v-qnty        = buf_chk-gds.doc-qnty .
                


        case buf_chk-doc.chk-type:
            WHEN integer({&rcpt-sale}) or 
            WHEN integer({&rcpt-return})
            then 
                do:
                    if available (tt-rvs-line) then 
                    do:
                        assign
                            buf_t-9.doc-qnty    = buf_t-9.doc-qnty + v-qnty
                            buf_t-9.delta       = buf_t-9.delta + v-qnty
                            tt-rvs-line.sale-kg = buf_t-9.doc-qnty * buf_chk-gds.density
                            buf_t-9.sale-kg     = buf_t-9.doc-qnty
                            .
                    end.    
                end.
            WHEN integer({&rcpt-tech-refuell}) THEN 
                DO:
                    if available (tt-rvs-line) then 
                    do:
                        assign
                            buf_t-9.tech-refuell-qnty = buf_t-9.tech-refuell-qnty + v-qnty
                            tt-rvs-line.tech-refuell  = tt-rvs-line.tech-refuell + v-qnty
                            .
                    end.
                end.
            OTHERWISE 
            DO:
            end.
        END case.
    end. /*for each buf_chk-gds*/

    case buf_chk-doc.chk-type:
        WHEN integer({&rcpt-sale}) then 
            do:
                for each buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code and 
                    buf_chk-doc-attr.attr-code = "create-type" and 
                    buf_chk-doc-attr.attr-value = "manual":
                    if can-find (first buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                        and buf_chk-gds.pass-gds = 1) then 
                    do: 
                        if not can-find (ub.chk-doc-attr where chk-doc-attr.doc-code = buf_chk-doc.doc-code and
                            ub.chk-doc-attr.attr-code = "CHFiscalDocNumber") then 
                        do:
                            find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
                            if not available (tt-chk-doc) then
                            do:
                                create tt-chk-doc.
                                assign
                                    tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                                    tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                                    tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                                    tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                                    tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                                    tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                                    tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                                    tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                                    tt-chk-doc.shift-date = buf_chk-doc.shift-date
                                    tt-chk-doc.shift-name = buf_chk-doc.shift-name
                                    tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                                    .
                            end.
                            if tt-chk-doc.office = "" then tt-chk-doc.office = "сухой чек прихода в ТН" .
                            else tt-chk-doc.office = tt-chk-doc.office + ", " + "сухой чек прихода в ТН" .
                        end.    
                    end.
                end.
                if available (tt-rvs-line) then 
                do:
                    find first bar-code no-lock where bar-code.gds-code = tt-rvs-line.gds-code no-error .
                    /* Сухой чек по топливу */    
                    find first buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                        and buf_chk-gds.b-code = bar-code.b-code and buf_chk-gds.pass-gds = 1 no-lock no-error.
                    IF AVAILABLE buf_chk-gds THEN
                    DO:
                        if not can-find (ub.chk-doc-attr where chk-doc-attr.doc-code = buf_chk-doc.doc-code and
                            ub.chk-doc-attr.attr-code = "CHFiscalDocNumber") then next .
                        find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
                        if not available (tt-chk-doc) then
                        do:
                            create tt-chk-doc.
                            assign
                                tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                                tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                                tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                                tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                                tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                                tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                                tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                                tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                                tt-chk-doc.shift-date = buf_chk-doc.shift-date
                                tt-chk-doc.shift-name = buf_chk-doc.shift-name
                                tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                                .
                        end.
                        if tt-chk-doc.office = "" then tt-chk-doc.office = "сухой чек прихода топлива на кассе" .
                        else tt-chk-doc.office = tt-chk-doc.office + ", сухой чек прихода топлива на кассе" .
                    end.
                end.
          
            end.
        WHEN integer({&rcpt-return})
        then 
            do:
                if available (tt-rvs-line) then 
                do:
                    /* Полный возврат топлива */
                    find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
                        and buf_chk-doc-attr.attr-code = 'CHFlag1' and (buf_chk-doc-attr.attr-value = "4" or 
                        buf_chk-doc-attr.attr-value = "3" or buf_chk-doc-attr.attr-value = "2") no-lock no-error.
                    IF AVAILABLE buf_chk-doc-attr THEN
                    DO:
                        find first bf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
                            and bf_chk-doc-attr.attr-code = 'CHMgrKey' and bf_chk-doc-attr.attr-value = "1" no-lock no-error .
                        if available (bf_chk-doc-attr) then 
                        do:
                            find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
                            if not available (tt-chk-doc) then
                            do:
                                create tt-chk-doc.
                                assign
                                    tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                                    tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                                    tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                                    tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                                    tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                                    tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                                    tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                                    tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                                    tt-chk-doc.shift-date = buf_chk-doc.shift-date
                                    tt-chk-doc.shift-name = buf_chk-doc.shift-name
                                    tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                                    .
                            end.
                            if tt-chk-doc.office = "" then tt-chk-doc.office = "полный возврат" .
                            else tt-chk-doc.office = tt-chk-doc.office + ", полный возврат" .
                        end.
                    end. 
                end.
            end.
        WHEN integer({&rcpt-trans-cancell}) THEN 
            DO:
                find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
                if not available (tt-chk-doc) then
                do:
                    create tt-chk-doc.
                    assign
                        tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                        tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                        tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                        tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                        tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                        tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                        tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                        tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                        tt-chk-doc.shift-date = buf_chk-doc.shift-date
                        tt-chk-doc.shift-name = buf_chk-doc.shift-name
                        tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                        .
                end.
                if tt-chk-doc.office = "" then tt-chk-doc.office = "сброс топл.транзакции" .
                else tt-chk-doc.office = tt-chk-doc.office + ", сброс топл.транзакции" .
            end.
        OTHERWISE 
        DO:
        end.
    END case.
    if available (tt-rvs-line) then 
    do:
        define variable disp_ as character no-undo .
        for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code and (buf_chk-pay.pay-code = 0064 or buf_chk-pay.pay-code = 4006):
            if buf_chk-pay.pay-code = 0064 then disp_ = "постоплата" .
            else disp_ = "криминальный уезд" .
            
            find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
            if not available (tt-chk-doc) then
            do:
                create tt-chk-doc.
                assign
                    tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                    tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                    tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                    tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                    tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                    tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                    tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                    tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                    tt-chk-doc.shift-date = buf_chk-doc.shift-date
                    tt-chk-doc.shift-name = buf_chk-doc.shift-name
                    tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                    .
            end.          
            if tt-chk-doc.office = "" then tt-chk-doc.office = disp_ .
            else tt-chk-doc.office = tt-chk-doc.office + ", " + disp_ .
        end.

    end.
END. /*FOR EACH buf_chk-doc*/

/*Проверка и вывод на отклонения*/
define buffer buf_tt-rvs-line for tt-rvs-line .
define buffer bf_shift-param  for ub.shift-param .

find first ub.shift-param no-lock where ub.shift-param.obj-code = p-curr-obj-code and
    ub.shift-param.obj-type = p-curr-obj-type and
    ub.shift-param.shift-date = v-shift-date and
    ub.shift-param.shift-name = v-shift-name and
    ub.shift-param.shift-num = v-shift-num and
    ub.shift-param.gds-code = 0 and
    ub.shift-param.pl-code = 0 no-error .
if not available (ub.shift-param) then 
do:
    find first ub.shift-param no-lock where ub.shift-param.obj-code = 0 and
        ub.shift-param.obj-type = "" and
        ub.shift-param.shift-date = 01/01/1900 no-error .
    if not available (ub.shift-param) then 
    do:
        /* первый запуск */
        assign
            prc-dev-mass   = 0.65
            dev-paid-trans = 1
            .
    end.
    else 
    do:
        assign
            prc-dev-mass   = ub.shift-param.prc-dev-mass
            dev-paid-trans = ub.shift-param.dev-paid-trans
            .        
    end.
end.
else 
    assign
        prc-dev-mass   = ub.shift-param.prc-dev-mass
        dev-paid-trans = ub.shift-param.dev-paid-trans
        . 
        
/* Почистить предыдущие значения */           
for each ub.shift-param exclusive-lock where ub.shift-param.obj-code = p-curr-obj-code and
    ub.shift-param.obj-type = p-curr-obj-type and
    ub.shift-param.shift-date = v-shift-date and
    ub.shift-param.shift-name = v-shift-name and
    ub.shift-param.shift-num = v-shift-num and
    ub.shift-param.gds-code <> 0 and
    ub.shift-param.pl-code <> 0 :
    delete ub.shift-param .
end.
define variable v-com-tanks     as character no-undo .
define variable v-main-tanks    as character no-undo .
define variable v-num-com-tanks as integer   no-undo .
define buffer com_temp-rvs-line for tt-rvs-line .
define buffer com_t-9           for t-9 .
  
{ str/placelib.i }
{ rep/c-temp-place.i }
{ rep/c-place-attr.i }

for first ub.shift-obj no-lock where ub.shift-obj.obj-code = p-curr-obj-code and
    ub.shift-obj.obj-type = p-curr-obj-type and ub.shift-obj.shift-date = v-shift-date and
    ub.shift-obj.shift-num = v-shift-num:

    for each buf_tt-rvs-line break by buf_tt-rvs-line.gds-code by buf_tt-rvs-line.pl-code:
        v-main-tanks = "" .
        v-com-tanks = "" .      
        for each tt-rvs-line where tt-rvs-line.gds-code = buf_tt-rvs-line.gds-code:
            if get_com-vessel(p-curr-obj-code, p-curr-obj-type, {&place-com-vessel}, tt-rvs-line.pl-code, ub.shift-obj.open-date, 
                close-date, ub.shift-obj.open-time, close-time) then /*сообщающиеся резервуары*/
            do:
                v-com-tanks = get_com-tanks(p-curr-obj-code, p-curr-obj-type, {&place-com-tanks}, tt-rvs-line.pl-code, 
                    ub.shift-obj.open-date, close-date, ub.shift-obj.open-time, close-time) .  /*коды сообщающихся сосудов*/
                if v-com-tanks > "" then 
                do:
                    v-main-tanks = trim(v-main-tanks,",") .
                    if lookup(v-main-tanks, v-com-tanks, ",") <> 0 then next .
                    
                    if not get_com-vessel(p-curr-obj-code, p-curr-obj-type, {&place-is-main}, tt-rvs-line.pl-code, ub.shift-obj.open-date, 
                        close-date, ub.shift-obj.open-time, close-time) then next .
                    else
                    do : /* Главный */             
                        v-main-tanks = v-main-tanks + "," + tt-rvs-line.loc1 .
                        v-num-com-tanks = num-entries(v-com-tanks) + 1 .
                        /*Итоги по резервуару*/
                        do ii = 1 to num-entries(v-com-tanks) :     
                            find first buf_place no-lock where buf_place.obj-type = p-curr-obj-type
                                and buf_place.obj-code = p-curr-obj-code
                                and buf_place.loc1 = entry(ii, v-com-tanks)
                                and buf_place.status_ = ""
                                no-error .
                            if not available buf_place
                                then 
                            do :
                                undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                            end .
                 
                            find first com_temp-rvs-line where com_temp-rvs-line.gds-code = tt-rvs-line.gds-code
                                and com_temp-rvs-line.pl-code  = buf_place.pl-code
                                no-error .
                            if not available com_temp-rvs-line
                                then 
                            do :
                            end .
                            else 
                            do :
                                tt-rvs-line.tech-refuell = tt-rvs-line.tech-refuell + com_temp-rvs-line.tech-refuell .
                                tt-rvs-line.rast-stock-end = tt-rvs-line.rast-stock-end + com_temp-rvs-line.rast-stock-end .
                                tt-rvs-line.fact-stock-end = tt-rvs-line.fact-stock-end + com_temp-rvs-line.fact-stock-end .
                                tt-rvs-line.fact-stock-start = tt-rvs-line.fact-stock-start + com_temp-rvs-line.fact-stock-start .
                                tt-rvs-line.income = tt-rvs-line.income + com_temp-rvs-line.income .
                                tt-rvs-line.sale-kg = tt-rvs-line.sale-kg + com_temp-rvs-line.sale-kg .
                                tt-rvs-line.rast-stock-end = tt-rvs-line.fact-stock-start + tt-rvs-line.income - tt-rvs-line.sale-kg - tt-rvs-line.tech-refuell .
                                tt-rvs-line.loc1 = tt-rvs-line.loc1 + "," + v-com-tanks .
                                delete com_temp-rvs-line .
                            end .                  
               
                  
                        end.                           
                    end.
            
                end.           
            end.   
          
        end.
    end.

    for each buf_t-9 break by buf_t-9.gds-code by buf_t-9.pl-code:
        v-main-tanks = "" .
        v-com-tanks = "" .      
        for each t-9 where t-9.gds-code = buf_t-9.gds-code:
            if get_com-vessel(p-curr-obj-code, p-curr-obj-type, {&place-com-vessel}, t-9.pl-code, ub.shift-obj.open-date, 
                ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then /*сообщающиеся резервуары*/
            do:
                v-com-tanks = get_com-tanks(p-curr-obj-code, p-curr-obj-type, {&place-com-tanks}, t-9.pl-code, 
                    ub.shift-obj.open-date, ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) .  /*коды сообщающихся сосудов*/
                if v-com-tanks > "" then 
                do:
                    v-main-tanks = trim(v-main-tanks,",") .
                    if lookup(v-main-tanks, v-com-tanks, ",") <> 0 then next .
                    
                    if not get_com-vessel(p-curr-obj-code, p-curr-obj-type, {&place-is-main}, t-9.pl-code, ub.shift-obj.open-date, 
                        ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then next .
                    else
                    do : /* Главный */             
                        v-main-tanks = v-main-tanks + "," + t-9.loc1 .
                        v-num-com-tanks = num-entries(v-com-tanks) + 1 .
                        /*Итоги по резервуару*/
                        do ii = 1 to num-entries(v-com-tanks) :     
                            find first buf_place no-lock where buf_place.obj-type = p-curr-obj-type
                                and buf_place.obj-code = p-curr-obj-code
                                and buf_place.loc1 = entry(ii, v-com-tanks)
                                and buf_place.status_ = ""
                                no-error .
                            if not available buf_place
                                then 
                            do :
                                undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                            end .
                 
                            find first com_t-9 where com_t-9.gds-code = t-9.gds-code
                                and com_t-9.pl-code  = buf_place.pl-code
                                no-error .
                            if not available com_t-9
                                then 
                            do :
                            end .
                            else 
                            do :
                                t-9.delta = t-9.delta + com_t-9.delta .
                                t-9.meas-qnty = t-9.meas-qnty + com_t-9.meas-qnty .
                                t-9.sale-kg = t-9.sale-kg + com_t-9.sale-kg .
                                t-9.loc1 = t-9.loc1 + "," + v-com-tanks .
                                delete com_t-9 .
                            end .                  
               
                  
                        end.                           
                    end.
            
                end.           
            end.   
          
        end.
    end.

end.
for each buf_tt-rvs-line no-lock:
    find first buf_shift-param exclusive-lock where buf_shift-param.gds-code = buf_tt-rvs-line.gds-code and
        buf_shift-param.pl-code = buf_tt-rvs-line.pl-code and
        buf_shift-param.obj-code = p-curr-obj-code and
        buf_shift-param.obj-type = p-curr-obj-type and
        buf_shift-param.shift-date = v-shift-date and
        buf_shift-param.shift-name = v-shift-name and
        buf_shift-param.shift-num = v-shift-num no-error .
    if not available (buf_shift-param) then 
    do:
        create buf_shift-param .
        assign
            buf_shift-param.gds-code       = buf_tt-rvs-line.gds-code 
            buf_shift-param.pl-code        = buf_tt-rvs-line.pl-code 
            buf_shift-param.obj-code       = p-curr-obj-code
            buf_shift-param.obj-type       = p-curr-obj-type
            buf_shift-param.shift-date     = v-shift-date
            buf_shift-param.shift-name     = v-shift-name
            buf_shift-param.shift-num      = v-shift-num
            buf_shift-param.diff-cash-trk  = 0
            buf_shift-param.diff-stock-end = 0
            .
        buf_shift-param.loc1 = buf_tt-rvs-line.loc1 .
    end.
    buf_tt-rvs-line.rast-stock-end = buf_tt-rvs-line.fact-stock-start + buf_tt-rvs-line.income - buf_tt-rvs-line.sale-kg - buf_tt-rvs-line.tech-refuell .
    assign
        buf_shift-param.tech-refuell    = buf_tt-rvs-line.tech-refuell
        buf_shift-param.prc-dev-mass    = prc-dev-mass
        buf_shift-param.dev-paid-trans  = dev-paid-trans
        buf_shift-param.diff-stock-end  = absolut(buf_tt-rvs-line.rast-stock-end - buf_tt-rvs-line.fact-stock-end) 
        buf_shift-param.dev-mass        = buf_tt-rvs-line.fact-stock-end * buf_shift-param.prc-dev-mass / 100 
        buf_shift-param.system-cli-qnty = buf_tt-rvs-line.rast-stock-end
        buf_shift-param.fact-stock-end  = buf_tt-rvs-line.fact-stock-end
        buf_shift-param.disc-diffMass   = ""
        .
end.


for each buf_t-9:
    find first buf_shift-param exclusive-lock where buf_shift-param.gds-code = buf_t-9.gds-code and
        buf_shift-param.pl-code = buf_t-9.pl-code and
        buf_shift-param.obj-code = p-curr-obj-code and
        buf_shift-param.obj-type = p-curr-obj-type and
        buf_shift-param.shift-date = v-shift-date and
        buf_shift-param.shift-name = v-shift-name and
        buf_shift-param.shift-num = v-shift-num no-error .
    if not available (buf_shift-param) then 
    do:
        create buf_shift-param .
        assign
            buf_shift-param.gds-code       = buf_t-9.gds-code 
            buf_shift-param.pl-code        = buf_t-9.pl-code 
            buf_shift-param.obj-code       = p-curr-obj-code
            buf_shift-param.obj-type       = p-curr-obj-type
            buf_shift-param.shift-date     = v-shift-date
            buf_shift-param.shift-name     = v-shift-name
            buf_shift-param.shift-num      = v-shift-num
            buf_shift-param.diff-cash-trk  = 0
            buf_shift-param.diff-stock-end = 0
            .
        buf_shift-param.loc1 = buf_t-9.loc1 .          
    end.
    buf_shift-param.disc-diffTRK = "" .
    buf_shift-param.diff-cash-trk = buf_shift-param.diff-cash-trk + absolut(buf_t-9.delta - buf_t-9.tech-refuell-qnty) .
    buf_shift-param.meas-qnty = buf_shift-param.meas-qnty + buf_t-9.meas-qnty.
    buf_shift-param.cash-qnty = buf_shift-param.cash-qnty + buf_t-9.sale-kg.
end.


assign
    errorCheck = false 
    errorMass  = false
    errorTRK   = false 
    .

/*Отклонения и подозрительные чеки */

for each bf_susp-chk exclusive-lock where bf_susp-chk.shift-date = v-shift-date and
    bf_susp-chk.shift-num = v-shift-num and
    bf_susp-chk.shift-name = v-shift-name and
    bf_susp-chk.obj-code = p-curr-obj-code and
    bf_susp-chk.obj-type = p-curr-obj-type:
    find first tt-chk-doc where tt-chk-doc.doc-code = bf_susp-chk.doc-code no-lock no-error .
    if not available (tt-chk-doc) then delete bf_susp-chk .
end.
for each tt-chk-doc:
    errorCheck = true .
    find first bf_susp-chk exclusive-lock where bf_susp-chk.doc-code = tt-chk-doc.doc-code no-error .
    if not available (bf_susp-chk) then 
    do:
        create bf_susp-chk .
        buffer-copy tt-chk-doc to bf_susp-chk .        
    end.
    bf_susp-chk.chk-time = tt-chk-doc.chk-time .
end.

for each ub.shift-param no-lock where ub.shift-param.obj-code = p-curr-obj-code and
    ub.shift-param.obj-type = p-curr-obj-type and
    ub.shift-param.shift-date = v-shift-date and
    ub.shift-param.shift-num = v-shift-num and
    ub.shift-param.shift-name = v-shift-name and
    ub.shift-param.gds-code > 0:
    for first buf_shift-param exclusive-lock where buf_shift-param.obj-code = ub.shift-param.obj-code and
        buf_shift-param.obj-type = ub.shift-param.obj-type and
        buf_shift-param.shift-date = ub.shift-param.shift-date and
        buf_shift-param.shift-name = ub.shift-param.shift-name and
        buf_shift-param.shift-num = ub.shift-param.shift-num and
        buf_shift-param.gds-code = ub.shift-param.gds-code and
        buf_shift-param.pl-code = ub.shift-param.pl-code:
        if absolute(buf_shift-param.diff-stock-end) > buf_shift-param.dev-mass then 
            assign
                buf_shift-param.error-mass = true 
                errorMass                  = true .
            .
        if absolute(buf_shift-param.diff-cash-trk) > buf_shift-param.dev-paid-trans then
            assign
                buf_shift-param.error-paid-trans = true 
                errorTRK                         = true .
    end.
         
end.

if errorCheck or errorMass or errorTRK then 
do:
    define variable v-text-button as character no-undo .
    if errorMass then v-text-button = v-text-button + '|' + "errorMass" .
    if errorTRK then v-text-button = v-text-button + '|' + "errorTRK" .
    if errorCheck then v-text-button = v-text-button + '|' + "errorCheck" .
    v-text-button = trim(v-text-button,'|') .

    
    run gbl/d-askwShiftClose.w
        (input parparentproc
        ,input "Закрытие смены" /* Заголовок окна */
        ,input "При закрытии смены выявлены ошибки"
        ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
        ,input string(errorMass) + '|' + string(errorTRK) + '|' + string(errorCheck) /*Показ кнопок*/
        ,input "Просмотр|Просмотр|Просмотр" /* список названий кнопок  */
        ,input "Превышено допустимое отклонение по 1 части сменного отчета|" /* список описаний кнопок */
        + "Превышено допустимое отклонение по 9 части сменного отчета|"
        + 'Найдены «подозрительные» чеки'
        ,input 4 /* значение возвращаемое при нажатии enter */
        ,input 5 /* значение возвращаемое при нажатии escape */
        ,input v-text-button
        ,input  p-curr-obj-type
        ,input  p-curr-obj-code
        ,input  v-shift-date
        ,input  v-shift-num 
        ,input  v-shift-name
        ,output v-num /* выбор пользователя */
        ) no-error.
    if error-status:error then 
    do:
        message return-value
            view-as alert-box.
    end.
    case v-num:
        when "closeWith" then 
            do:
                if errorMass then 
                do:
                    run str/diffShiftClose.w (
                        input parparentproc,
                        input {&update},
                        input p-curr-obj-type,
                        input p-curr-obj-code,
                        input v-shift-date,
                        input v-shift-num,
                        input v-shift-name,
                        input "diff-mass",
                        output v-ok)  no-error .       
                    if not v-ok then 
                    do:
                        return error .
                    end.            
                end.    
                if errorTRK then 
                do:
                    run str/diffShiftClose.w (
                        input parparentproc,
                        input {&update},
                        input p-curr-obj-type,
                        input p-curr-obj-code,
                        input v-shift-date,
                        input v-shift-num,
                        input v-shift-name,
                        input "diff-TRK",
                        output v-ok)  no-error .       
                    if not v-ok then 
                    do:
                        return error .
                    end.            
                end.    
                run str/susp-chk.w (
                    input parparentproc,
                    input {&update},
                    input p-curr-obj-type,
                    input p-curr-obj-code,
                    input v-shift-date,
                    input v-shift-num,
                    input v-shift-name,
                    output table tt-susp-chk,
                    output v-ok) no-error .                 
                if not v-ok then 
                do:
                    return error.
                end.  
            end.
        when "cancel" then 
            do:
                for each buf_shift-param exclusive-lock where buf_shift-param.obj-code = p-curr-obj-code and
                    buf_shift-param.obj-type = p-curr-obj-type and
                    buf_shift-param.shift-date = v-shift-date and
                    buf_shift-param.shift-num = v-shift-num:
                    delete buf_shift-param .
                end.
                return error .
            end.
    end case .

end.

procedure get-state-mh-cnt-from-icnt-doc :
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-from-shift-date as date no-undo.
    define input parameter p-from-shift-num as integer no-undo.
    define input parameter p-fact-order as decimal no-undo.
    define input parameter p-gds-code as integer no-undo .
    define input parameter p-pl-code as integer no-undo .
    define input parameter p-pump-code as integer no-undo .
    define input parameter p-nozzle-code as integer no-undo .
    define input-output parameter p-state-mh-cnt as decimal no-undo .
    define input-output parameter p-state-el-cnt as decimal no-undo .
    
                                           
    define buffer buf_icnt-doc  for ub.icnt-doc.
    define buffer buf_icnt-line for ub.icnt-line.
    for each buf_icnt-doc no-lock
        where buf_icnt-doc.obj-type = p-obj-type
        and buf_icnt-doc.obj-code = p-obj-code
        and buf_icnt-doc.status_ = {&fact}
        and buf_icnt-doc.fact-order < p-fact-order
        by buf_icnt-doc.fact-order
        descending

        on error undo, return error return-value
        :
        for each buf_icnt-line no-lock where
            buf_icnt-line.doc-code = buf_icnt-doc.doc-code
            and buf_icnt-line.obj-code = buf_icnt-doc.obj-code
            and buf_icnt-line.obj-type = buf_icnt-doc.obj-type
            and buf_icnt-line.gds-code = p-gds-code 
            and buf_icnt-line.pl-code = p-pl-code
            and buf_icnt-line.pump-code = p-pump-code
            and buf_icnt-line.nozzle-code = p-nozzle-code:
            assign
                p-state-mh-cnt = p-state-mh-cnt + buf_icnt-line.state-mh-cnt.
            p-state-el-cnt = p-state-el-cnt + buf_icnt-line.state-el-cnt.
            leave.
        end.

    end.

end procedure. /* get-state-mh-cnt-from-icnt-doc */