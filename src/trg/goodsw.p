block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

триггер отменяется в g d s g r p w . p ( a n y - g r p w . i)
WRITE-триггере для g d s - g r p ,

*/

TRIGGER PROCEDURE FOR WRITE OF ub.goods OLD old-goods .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись товара".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,ub.goods.gds-code,ub.goods.artic,ub.goods.prod-type,ub.goods.prod-code)" }
{ cmp/trg-def.i  }
{ ref/grplibfn.i }
{ gbl/cur-time.i }
{ trg/goodsh.i trig old-goods ub.goods }


DEFINE VARIABLE conf-par    as character no-undo .
DEFINE VARIABLE par-type    as character no-undo .
DEFINE VARIABLE v-l         as logical   no-undo .
define variable v-date      as date      no-undo .
define variable v-time      as integer   no-undo .
define variable v-node-code as integer   no-undo .
define variable v-grp-code  as integer   no-undo .
define variable v-mes       as character no-undo .
define variable v-mes0      as character no-undo .
define buffer buf_c-goods    for ub.c-goods.
define buffer buf_c-gds-hist for ub.c-gds-hist.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    { ref/send-ref.i conf-par par-type }
    /* проверка заполнения обязательных полей */
    /* поля заполняются один единственный раз при создании товара */
    /* затем их изменение в течение жизни товара запрещено */
    if new(ub.goods) then 
    do:
        assign
            v-l = no.
    end.
    else 
    do:
        v-l = yes.
        buffer-compare ub.goods
            to old-goods
            case-sensitive
            save result in v-l.
    end.
    if v-l = yes then return.
    if new(ub.goods) then 
    do:
        if ub.goods.gds-code = 0
            or ub.goods.gds-code = ? then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не задан код товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        if  ub.goods.gds-type <> {&gds-goods}
            and ub.goods.gds-type <> {&gds-office} then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не задан тип товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "ub.goods.gds-type" ub.goods.gds-type skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        if  ub.goods.prod-type <> {&prs}
            and ub.goods.prod-type <> {&cmp} then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Недопустимый тип производителя товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "ub.goods.prod-type" ub.goods.prod-type skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        find ub.units no-lock
            where ub.units.unit-name = ub.goods.unit-base
            no-error .
        if not available ub.units then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не найдена базовая единица измерения" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "Базовая единица измерения" ub.goods.unit-base skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        find ub.gds-prt no-lock
            where ub.gds-prt.upper-code = ub.goods.prt-root
            no-error .
        if not available ub.gds-prt
            or ub.gds-prt.prt-root <> ub.goods.prt-root then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не найдена шкала" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "Код шкалы" ub.goods.prt-root skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    else 
    do:
        if ub.goods.gds-code <> old-goods.gds-code then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Нельзя изменить код товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "old-goods.gds-code" old-goods.gds-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        if ub.goods.gds-type <> old-goods.gds-type then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Нельзя изменить тип товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "ub.goods.gds-type" ub.goods.gds-type skip
                "old-goods.gds-type" old-goods.gds-type skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        if ub.goods.prod-type <> old-goods.prod-type then 
        do:
            if  ub.goods.prod-type <> {&prs}
                and ub.goods.prod-type <> {&cmp} then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Недопустимый тип производителя товара" skip
                    "Код товара" ub.goods.gds-code skip
                    "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                    "ub.goods.prod-type" ub.goods.prod-type skip
                    view-as alert-box error .
                undo main-block, return error .
            end.
        end.

        if ub.goods.unit-base <> old-goods.unit-base then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Нельзя изменить базовую единицу измерения товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "ub.goods.unit-base" ub.goods.unit-base skip
                "old-goods.unit-base" old-goods.unit-base skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        if ub.goods.prt-root <> old-goods.prt-root then 
        do:
            find ub.gds-prt no-lock
                where ub.gds-prt.upper-code = ub.goods.prt-root
                no-error .
            if not available ub.gds-prt
                or ub.gds-prt.prt-root <> ub.goods.prt-root then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Не найдена шкала" skip
                    "Код товара" ub.goods.gds-code skip
                    "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                    "Код шкалы" ub.goods.prt-root skip
                    view-as alert-box error .
                undo main-block, return error .
            end.
        end.
    end.


    /* если товар новый или изменилась группа товара, */
    /* то изменить полное название группы */
    if new (ub.goods)
        or ub.goods.grp-code <> old-goods.grp-code then 
    do:
        run grplib-get-full-name in this-procedure (input ub.goods.grp-code, output ub.goods.grp-name) no-error .
        IF error-status:error
            AND G#NEWS
            AND G#DB-NUM = 0 THEN 
        DO:
            v-mes0 = substitute("&1 &2 &3&4&5&4&5&4&6"
                ,vss-workfile
                ,vss-revision
                ,vss-description
                ,{&new-line}
                , error-status:get-message(1)
                ,return-value).
            v-grp-code = ub.goods.grp-code.
            if old-goods.grp-code = ? then 
            do:
                error-status:error = yes.
            end.
            else 
            do:
                ASSIGN
                    UB.GOODS.grp-code = old-goods.grp-code.
                run grplib-get-full-name in this-procedure (input ub.goods.grp-code, output ub.goods.grp-name) no-error .
                v-mes0 =  substitute("&7&4&1 &2 &3&4&5&4&5&4&6&4"
                    ,vss-workfile
                    ,vss-revision
                    ,vss-description
                    ,{&new-line}
                    , error-status:get-message(1)
                    ,return-value
                    ,v-mes0
                    ).
            end.
            if error-status:error then 
            do:
                /*пусть сделают такую группу - мы ее найдем */
                run grplib-get-node-from-full-name ( input ub.goods.grp-name, output v-node-code) no-error.
                if error-status:error then 
                do:
                    v-mes = substitute("&1 &2 &3&4&5&4&5&4&6&4&7&4&8&4&9"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,{&new-line}
                        , error-status:get-message(1)
                        ,return-value
                        ,v-mes0
                        ,substitute("Не удается поместить товар в группу с вн. кодом &1,&2" +
                        "и не удается поместить товар в группу с полным именем &3"
                        ,v-grp-code
                        ,{&new-line}
                        ,ub.goods.grp-name)
                        , substitute("Возможно Вам следует СОЗДАТЬ группу товара с полным именем &1"
                        ,ub.goods.grp-name)
                        ).
                    undo main-block, return error v-mes .
                end.
                assign
                    ub.goods.grp-code = v-node-code.
            end.
        END.
        else 
        do:
            if error-status:error then 
            do:
                v-mes = substitute("&1 &2 &3&4&5&4&6"
                    ,vss-workfile
                    ,vss-revision
                    ,vss-description
                    ,{&new-line}
                    ,error-status:get-message(1)
                    ,return-value ).
                if not g#news then 
                do:
                    message
                        v-mes view-as alert-box error .
                end.
                undo main-block, return error v-mes .
            end.
        end.
    end.
    if can-find(first ub.gds-grp where ub.gds-grp.upper-code = ub.goods.grp-code) then 
    do:
        v-mes = substitute("Нельзя привязать товар с кодом &1 к нетерминальной группе с вн. кодом &2"
            , ub.goods.gds-code
            , ub.goods.grp-code).
        if not g#news then 
        do:
            message
                v-mes
                view-as alert-box error .
        end.
        undo main-block, return error v-mes .
    end.

    /* если товар новый или изменилась единица измерения товара, */
    /* или изменилась группа товара, */
    /* изменить единицу измерения группы товаров */
    if new (ub.goods)
        or ub.goods.grp-code <> old-goods.grp-code
        or ub.goods.unit-base <> ub.goods.unit-base then 
    do:
        run trg/scan-grp.p (input ub.goods.grp-code, input ub.goods.unit-base).
    end.

    /* товар удалили / восстановили или изменили группу */
    if old-goods.stts     <> ub.goods.stts
        or old-goods.grp-code <> ub.goods.grp-code then 
    do:
        for each ub.gds-obj
            where ub.gds-obj.artic     = ub.goods.artic
            and ub.gds-obj.prod-type = ub.goods.prod-type
            and ub.gds-obj.prod-code = ub.goods.prod-code
            on error undo main-block, return error
            :
            assign
                ub.gds-obj.grp-name = ub.goods.grp-name
                ub.gds-obj.stts     = ub.goods.stts
                .
        end.
    end.
    if old-goods.gds-name     <> ub.goods.gds-name
        then 
    do:
        for each ub.contract-specif
            where ub.contract-specif.artic     = ub.goods.artic
            and ub.contract-specif.prod-type = ub.goods.prod-type
            and ub.contract-specif.prod-code = ub.goods.prod-code
            on error undo main-block, return error
            :
            assign
                ub.contract-specif.gds-name = ub.goods.gds-name
      
                .
        end.
    end.

    if not v-l then 
    do:
        if old-goods.stts = integer({&befor-artic-change-int})
            or old-goods.stts = integer({&artic-change-int})
            or ub.goods.stts = integer({&befor-artic-change-int})
            or ub.goods.stts = integer({&artic-change-int})
            then 
        do:
        /* блокируем товар для смены артикула, поэтому сам товар не отсылаем */
        end.
        else 
        do:
            run str/callnews.p
                (input {&table_goods}
                ,input (buffer ub.goods:handle)
                ) no-error .
            if error-status:error then 
            do:
                if error-status :get-message(1) <> ""
                    then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при вызове процедуры callnews.p" skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                end.
                undo main-block,  return error return-value .
            end.
            { gbl/rum-runa.i
        ?
        this-procedure:handle
        ?
        " ( if new(ub.goods) then {&goods-proc_gdsadd} else {&goods-proc_gdsupdate} )"
        " buffer old-goods:handle "
        " buffer ub.goods:handle "
        ''
        ''
        no-error
       }
            if error-status:error
                then 
            do:
                if not g#news then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при вызове процедуры rum-runa.i" skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                end.
                undo main-block,  return error return-value .
            end.
        end.
        if new (ub.goods) and ub.goods.gds-type = {&gds-office} then 
        do:
            for each ub.gds-obj No-LOCK WHERE
                ub.gds-obj.gds-code = ub.goods.gds-code
                ON error undo, return error return-value
                :
                run str/callnews.p
                    (input {&table_gds-obj}
                    ,input (buffer ub.gds-obj:handle)
                    ) no-error .
                if error-status:error then 
                do:
                    if error-status :get-message(1) <> ""
                        then 
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Ошибка при вызове процедуры callnews.p (gds-obj)" skip
                            error-status :get-message(1) skip
                            return-value skip
                            view-as alert-box error .
                    end.
                    undo main-block,  return error return-value .
                end.
            end.
        end.
        /* отметка, что изменения в товаре должны попасть на весы */
        if not new(ub.goods) then 
        do:
            find ub.units no-lock
                where ub.units.unit-name = ub.goods.unit-base
                no-error .
            if not available ub.units then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Не найдена базовая единица измерения" skip
                    "Код товара" ub.goods.gds-code skip
                    "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                    "Базовая единица измерения" ub.goods.unit-base skip
                    view-as alert-box error .
                undo main-block, return error .
            end.
            if (old-goods.gds-name  <> ub.goods.gds-name
                or old-goods.engl-name <> ub.goods.engl-name
                or old-goods.label-name <> ub.goods.label-name
                )
                and
                (LOOKUP({&weight}, ub.units.type) > 0
                or
                (LOOKUP({&pieces}, ub.units.type) > 0
                and
                can-find(first ub.code-range no-lock where ub.code-range.range-type = {&loc-pg-code})
                )
                )
                then 
            do:
        /* товар отмечается для отправки на весы */
                { ref/scgdsupd.i ub.goods " " " " ? }
            end.
            if old-goods.struct <> ub.goods.struct
                and (LOOKUP({&weight}, ub.units.type) > 0
                or
                (LOOKUP({&pieces}, ub.units.type) > 0
                and
                can-find(first ub.code-range no-lock where ub.code-range.range-type = {&loc-pg-code})
                )
                )
                then 
            do:
        /* товар отмечается для отправки на весы */
                { ref/scgdsupd.i ub.goods " " " " ? 'struct' }
            end.

        end.
        if not g#news and new(ub.goods) then 
        do:
            assign
                ub.goods.cr-db-num = g#db-num.
        end.

        /*создаем batchporcess для отсылки на кассы*/
        if not g#news and send-ref then 
        do:
            /*для новых товаров не имеет смысла т.к. они все равно вбез цен на кассу не должны попасть*/
            if not new(ub.goods) then 
            do:
                /*выясним что изменилось*/
                define variable v-l2 as logical no-undo .
                assign
                    v-l2 = yes
                    .
                buffer-compare ub.goods using
                    engl-name gds-name chk-name
                    to old-goods
                    case-sensitive
                    save result in v-l2 .
                if not v-l2 then 
                do:
                    run trg/nu_gds.p (
                        input  ub.goods.gds-code
                        ,input  0
                        ,input  "":U
                        ,input  0
                        ,input  "U":U
                        ).
                end.
            end.
        end.
        run goodsh_write-goods-trigger in this-procedure  (
            input new(ub.goods)
            ,input (if g#news
            then {&hn-source-db}
            else (if g#esys
            then {&hn-source-esys}
            else "":U)
            )
            ,input  (if g#news
            then string(g#news-source-db)
            else (if g#esys
            then string(g#esys-source-esys)
            else "":U)
            )
            ) no-error .
        if error-status:error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры goodsh_write-goods-trigger" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block,  return error return-value .
        end.
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_goods}
            , input ( buffer ub.goods:handle )
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.

    if new(ub.goods) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_goods}
            , input ( buffer ub.goods :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end. 
    else 
    do:
        run trg/userlog.p (
            input {&nwsdochs_action_update}
            , input {&table_goods}
            , input ( buffer ub.goods :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.

    end.  
end. /* main-block */