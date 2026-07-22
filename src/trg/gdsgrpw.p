block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись группы товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.gds-grp OLD oldb.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись группы товаров".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.gds-grp.node-code,ub.gds-grp.upper-code,ub.gds-grp.node-name)" }
{ cmp/trg-def.i  }
{ ref/grplibfn.i }
{ trg/goodsh.i }
{ trg/gds-grph.i gds-grp-trig oldb ub.gds-grp }
{ gbl/cur-time.i }

define buffer b-gds-grp          for ub.gds-grp.
define buffer other_gds-grp      for ub.gds-grp.
define buffer buf_c-gds-grp      for ub.c-gds-grp.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define variable name                  as char      no-undo.
define variable uc                    as int       no-undo.
define variable skip-proc             as log       no-undo.                  /* неважное поле */
define variable conf-par              as char      no-undo.                  /* для чтения параметра конфигурации */
define variable par-type              as char      no-undo.                  /* тип параметра конфигурации */
define variable v-changed-node-code   like ub.gds-grp.node-code no-undo .
define variable v-changed-node-code-2 like ub.gds-grp.node-code no-undo .
define variable v-date                as date      no-undo .
define variable v-time                as integer   no-undo .
define variable v-only-is-term        as logical   no-undo .
define variable v-chr                 as character no-undo .
define buffer buf_scales-grp   for ub.scales-grp.
define buffer buf2_scales-grp  for ub.scales-grp.
define buffer buf_fbr-prn-grp  for ub.fbr-prn-grp.
define buffer buf2_fbr-prn-grp for ub.fbr-prn-grp.
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.

/* выходим из триггера в случае, если изменилось одно из вычисляемых полей, не требующих
   истории или СПН - пока такое поле только одно - gds-grp.unit-base */
buffer-compare ub.gds-grp except unit-base to oldb
    case-sensitive
    save result in skip-proc.
if skip-proc then 
do:
    return.
end.

/* отменяем триггер для ускорения - товары / клиенты в новости не идут, передается 1 команда */
on write of ub.goods override 
    do: 
    end.
on write of ub.c-goods override 
    do: 
    end.
on write of ub.c-gds-hist override 
    do: 
    end.

/* чтобы не было рекурсивного вызова этого триггера, отключаем его */
on write of ub.gds-grp override 
    do: 
    end.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
    if v-value = "no"  then 
    do:   
        if not g#news and g#db-num > 0 then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Нельзя изменять запись ГРУППЫ ТОВАРОВ в УБД" skip
                "Номер текущей БД" g#db-num
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    /* собираем полное имя, игнорируя корневой узел */
    run grplib-get-full-name in this-procedure
        (input ub.gds-grp.node-code
        ,output name
        ).

    /* добавление нового узла */
    if ub.gds-grp.node-code <> oldb.node-code then 
    do:
        /* !!! */
        /* новый узел, т.к. других причин для смены node-code не бывает */
        /* переносим все товары из вышестоящего узла */
        find b-gds-grp
            where b-gds-grp.node-code = ub.gds-grp.upper-code
            .
        assign
            gds-grp.lvl-num   = b-gds-grp.lvl-num + 1
            b-gds-grp.is-term = no
            .
        /*если это изменение терминальности спровоцированное рождением другой группы */
        /*то срабатывания триггера на b-gds-grp не будет потому что мы его отключили  */
        /*а теперь снова включили - УВЫ!*/

        assign
            v-changed-node-code = ub.gds-grp.node-code
            .

        for each ub.goods
            where ub.goods.grp-code = b-gds-grp.node-code
            ON ERROR UNDO main-block, RETURN ERROR
            :
            run goodsh_write-goods-proc   in this-procedure (
                buffer ub.goods
                ,integer({&hn-update})
                ,{&hn-source-grp-chg} /*p-source-type*/
                ,string(ub.gds-grp.node-code)
                ).
            assign
                ub.goods.grp-code = ub.gds-grp.node-code
                .
        end.

        /* переносим scales-grp - группы товаров на весах */
        for each buf_scales-grp
            where buf_scales-grp.node-code = b-gds-grp.node-code
            and buf_scales-grp.db-num = g#db-num
            ON ERROR UNDO main-block, RETURN ERROR
            :
            find first buf2_scales-grp no-lock where
                buf2_scales-grp.node-code = b-gds-grp.node-code
                and buf2_scales-grp.db-num = buf_scales-grp.db-num
                and buf2_scales-grp.scales-num = buf_scales-grp.scales-num no-error.
            if not available buf2_scales-grp then 
            do:
                create buf2_scales-grp.
                assign
                    buf2_scales-grp.node-code  = b-gds-grp.node-code
                    buf2_scales-grp.db-num     = buf_scales-grp.db-num
                    buf2_scales-grp.scales-num = buf_scales-grp.scales-num
                    .
            end.
            delete buf_scales-grp.
        end.
        /* переносим группы товаров на принтерах */
        for each buf_fbr-prn-grp where
            buf_fbr-prn-grp.node-code = ub.gds-grp.node-code
            and buf_fbr-prn-grp.db-num = g#db-num
            on error undo main-block, return error return-value  :
            find first buf2_fbr-prn-grp no-lock where
                buf2_fbr-prn-grp.node-code = ub.gds-grp.upper-code
                and buf2_fbr-prn-grp.db-num = buf_fbr-prn-grp.db-num
                and buf2_fbr-prn-grp.prn-num = buf_fbr-prn-grp.prn-num  no-error.
            if not available buf2_fbr-prn-grp then 
            do:
                create buf2_fbr-prn-grp.
                buffer-copy buf_fbr-prn-grp
                    except node-code to buf2_fbr-prn-grp
                    assign
                    buf2_fbr-prn-grp.node-code = ub.gds-grp.upper-code
                    .
            end.
            delete buf_fbr-prn-grp.
        end.
        /* перенесем метод расчета и наценку */
        if ub.gds-grp.calc-method = "" then 
        do:
            assign
                ub.gds-grp.calc-method = b-gds-grp.calc-method
                ub.gds-grp.increase-pc = b-gds-grp.increase-pc
                .
        end.
    end.
    else if ub.gds-grp.upper-code <> oldb.upper-code then 
        do:
            find b-gds-grp  where
                b-gds-grp.node-code = ub.gds-grp.upper-code no-wait no-error.
            if not available b-gds-grp then 
            do:
                undo main-block, return error substitute("gds-grp with node-code &1 is locked", ub.gds-grp.upper-code).
            end.
            assign
                gds-grp.lvl-num = b-gds-grp.lvl-num + 1
                .

            assign
                b-gds-grp.is-term  = no
                ub.gds-grp.lvl-num = b-gds-grp.lvl-num + 1
                .
            find first b-gds-grp where
                b-gds-grp.node-code = oldb.upper-code no-wait no-error.
            if locked(b-gds-grp) then 
            do:
                undo main-block, return error substitute("gds-grp with node-code &1 is locked", oldb.upper-code) .
            end.
            else 
            do:
                if available b-gds-grp then 
                do:
                    if not can-find(first other_gds-grp no-lock where
                        other_gds-grp.upper-code = oldb.upper-code
                        AND recid(other_gds-grp) <> recid(ub.gds-grp)) then 
                    do:

                        assign
                            b-gds-grp.is-term = yes
                            .
                    end.
                end. /*if available b-gds-grp then do*/
            end. /*not locked*/
        end. /*if ub.gds-grp.upper-code <> oldb.upper-code then do:*/

    buffer-compare oldb to ub.gds-grp
        case-sensitive
        save result in v-chr.
    if v-chr = "is-term":U then 
    do:
        assign
            v-only-is-term = yes
            .
    end.
    /* переписываем полный путь во всех клиентах или товарах + gds-obj поддерева */
    assign
        ub.gds-grp.is-term = yes
        .
    assign
        v-changed-node-code-2 = ub.gds-grp.node-code
        .

    run grp-tree in this-procedure
        (input ub.gds-grp.node-code
        ,input name
        ) no-error.
    if error-status :error then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры grp-tree" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        undo main-block, return error.
    end.

    /* признак изменения справочника */
    define variable v-synch-gds-grp as integer no-undo .
    assign
        v-synch-gds-grp = next-value(synch-gds-grp, {&db-name_schema})
        .

    /*сначала пишем историю, потом зовем callnews потому что если придет основная записи а истории нет то не взведетс
    флаг обновления справочника
    */
    if not g#news then 
    do:
        define variable v-l as logical no-undo .
        buffer-compare oldb to ub.gds-grp
            case-sensitive
            save result in v-l.
        if not v-l then
            run gds-grph_write-gds-grp-trigger in this-procedure (
                new(ub.gds-grp)
                ,"":U
                ,"":U
                , (if new(ub.gds-grp) then integer({&hn-create}) else integer({&hn-update}))
                ).
    end.


    run str/callnews.p
        (input {&table_gds-grp}
        ,input (buffer ub.gds-grp:handle)
        ) no-error .
    if error-status :error then 
    do:
        message
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box.
        undo main-block, return error.
    end.

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_gds-grp}
            , input ( buffer ub.gds-grp:handle )
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
    if new(ub.gds-grp) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_gds-grp}
            , input ( buffer ub.gds-grp :handle )
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
            , input {&table_gds-grp}
            , input ( buffer ub.gds-grp :handle )
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
end.


procedure grp-tree :

    define input  parameter nc       as integer   no-undo .
    define input  parameter cur-name as character no-undo .

    def buffer buf_gds-grp for ub.gds-grp .

    do
        on error undo, return error return-value
        :

        for each buf_gds-grp
            where buf_gds-grp.upper-code = nc
            on error undo, return error
            :
            if nc = ub.gds-grp.node-code then 
            do:
                assign
                    ub.gds-grp.is-term = no
                    .
            end.
            run grp-tree
                (input buf_gds-grp.node-code,
                trim(cur-name, {&delim-grp}) + (if cur-name = "":U then "":U else {&delim-grp}) + buf_gds-grp.node-name
                ).
        end.
        for each ub.goods
            where ub.goods.grp-code = nc
            on error undo, return error
            :
            if v-changed-node-code <> nc
                and not v-only-is-term
                then 
            do:
                run goodsh_write-goods-proc   in this-procedure (
                    buffer ub.goods
                    ,integer({&hn-update})
                    ,{&hn-source-grp-chg} /*p-source-type*/
                    ,string(v-changed-node-code-2)
                    ).
            end.

            assign
                ub.goods.grp-name = trim(cur-name , {&delim-grp}) + {&delim-grp}
                .
            for each ub.gds-obj
                where ub.gds-obj.artic     = ub.goods.artic
                and ub.gds-obj.prod-type = ub.goods.prod-type
                and ub.gds-obj.prod-code = ub.goods.prod-code
                on error undo, return error
                :
                assign
                    ub.gds-obj.grp-name = trim(cur-name , {&delim-grp}) + {&delim-grp}
                    .
            end.
        end.
    end.
end procedure.