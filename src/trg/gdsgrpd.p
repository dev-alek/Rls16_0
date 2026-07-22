block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление группы товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.gds-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление группы товара".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.gds-grp.node-code,ub.gds-grp.upper-code,ub.gds-grp.node-name)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/goodsh.i }
{ ref/grplibfn.i }
{ trg/gds-grph.i gds-grp-trig ub.gds-grp ub.gds-grp }

define buffer b-gds-grp          for ub.gds-grp.
define buffer other_gds-grp      for ub.gds-grp.
define buffer buf_c-gds-grp      for ub.c-gds-grp.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.

define variable name   as char    no-undo.
define variable uc     as int     no-undo.
define variable v-date as date    no-undo .
define variable v-time as integer no-undo .
define buffer buf_scales-grp   for ub.scales-grp.
define buffer buf2_scales-grp  for ub.scales-grp.
define buffer buf_fbr-prn-grp  for ub.fbr-prn-grp.
define buffer buf2_fbr-prn-grp for ub.fbr-prn-grp.



main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :


    /*удаление происходит  в удаленке через этот же триггер*/
    on delete of ub.tax-rate-gds-grp override 
        do: 
        end.
    on delete of ub.gds-grp-attr override 
        do: 
        end.
    on delete of ub.gds-grp-obj override 
        do: 
        end.

    on write of ub.tax-rate-gds-grp override 
        do: 
        end.
    on write of ub.gds-grp-attr override 
        do: 
        end.
    on write of ub.gds-grp-obj override 
        do: 
        end.
    /* отменяем триггер для ускорения - товары в новости не идут, передается 1 команда */
    on write of ub.goods override 
        do: 
        end.


    if not g#news and g#db-num > 0 then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя удалять запись ГРУППЫ ТОВАРОВ в УБД" skip
            "Номер текущей БД" g#db-num
            view-as alert-box error .
        undo main-block, return error .
    end.

    /* в отличие от удаления документов, маршрутизацию чистить не надо,
      т.к. должны дойти все команды на изменение */

    /*чистим атрибуты*/
    for each ub.gds-grp-attr where
        ub.gds-grp-attr.node-code = ub.gds-grp.node-code:

        run gds-grph_write-gds-grp-attr-proc   in this-procedure (
            buffer ub.gds-grp-attr
            ,integer({&hn-delete})
            ,{&hn-source-grp-chg} /*p-source-type*/
            ,string(ub.gds-grp.node-code)
            ).
        delete ub.gds-grp-attr.
    end.

    /*чистим параметры на объекте*/
    for each ub.gds-grp-obj where
        ub.gds-grp-obj.node-code = ub.gds-grp.node-code:

        run gds-grph_write-gds-grp-obj-proc   in this-procedure (
            buffer ub.gds-grp-obj
            ,integer({&hn-delete})
            ,{&hn-source-grp-chg} /*p-source-type*/
            ,string(ub.gds-grp.node-code)
            ).
        delete ub.gds-grp-obj.
    end.

    /* считаем путь к ВЫШЕСТОЯЩЕМУ узлу */
    run grplib-get-full-name in this-procedure
        (input ub.gds-grp.upper-code
        ,output name
        ).

    /* переносим клиентов или товары + gds-obj в вышестоящий узел и переписываем в них полный путь */
    for each ub.goods
        where ub.goods.grp-code = ub.gds-grp.node-code
        on error undo main-block, return error
        :
        run goodsh_write-goods-proc   in this-procedure (
            buffer ub.goods
            ,integer({&hn-update})
            ,{&hn-source-grp-chg} /*p-source-type*/
            ,string(ub.gds-grp.node-code)
            ).

        assign
            ub.goods.grp-code = ub.gds-grp.upper-code
            ub.goods.grp-name = name
            .
        for each ub.gds-obj
            where ub.gds-obj.artic     = ub.goods.artic
            and ub.gds-obj.prod-type = ub.goods.prod-type
            and ub.gds-obj.prod-code = ub.goods.prod-code
            :
            assign
                ub.gds-obj.grp-name = name
                .
        end.
    end.

    /* переносим группы товаров на весах */
    for each buf_scales-grp where
        buf_scales-grp.node-code = ub.gds-grp.node-code
        and buf_scales-grp.db-num = g#db-num
        on error undo main-block, return error return-value  :
        find first buf2_scales-grp no-lock where
            buf2_scales-grp.node-code = ub.gds-grp.upper-code
            and buf2_scales-grp.scales-num = buf_scales-grp.scales-num
            and buf2_scales-grp.db-num     = g#db-num  no-error.
        if available buf2_scales-grp then 
        do:
        end.
        else 
        do:
            create buf2_scales-grp.
            assign
                buf2_scales-grp.node-code  = ub.gds-grp.upper-code
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
        if available buf2_fbr-prn-grp then 
        do:
        end.
        else 
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
    for each ub.tax-rate-gds-grp where
        ub.tax-rate-gds-grp.node-code = ub.gds-grp.node-code:
        run gds-grph_write-tax-rate-gds-grp-proc   in this-procedure (
            buffer ub.tax-rate-gds-grp
            ,integer({&hn-delete})
            ,{&hn-source-grp-chg} /*p-source-type*/
            ,string(ub.gds-grp.node-code)
            ).
        delete ub.tax-rate-gds-grp.
    end.

    /* нижестоящие узлы переносим наверх,
      при этом триггеры gdsgrpw.p обрабатывают все остальные узлы и товары.
      История будет записана не только на удаление данного узла, но и на изменение всех узлов из этого цикла */
    for each b-gds-grp
        where b-gds-grp.upper-code = ub.gds-grp.node-code
        :
        assign
            b-gds-grp.upper-code = ub.gds-grp.upper-code
            .
    end.

    find first b-gds-grp where
        b-gds-grp.node-code = ub.gds-grp.upper-code.

    if not can-find(first other_gds-grp no-lock where
        other_gds-grp.upper-code = b-gds-grp.node-code
        AND recid(other_gds-grp) <> recid(ub.gds-grp)) then 
    do:
        assign
            b-gds-grp.is-term = yes
            .
    end.


    /* признак изменения справочника */
    define variable v-synch-gds-grp as integer no-undo .
    assign
        v-synch-gds-grp = next-value(synch-gds-grp, {&db-name_schema})
        .

    run nws/cmd-del.p
        ( input {&table_gds-grp}
        ,input (buffer ub.gds-grp:handle)
        ,input "":U
        ) no-error .
    if error-status :error then 
    do:
        undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.

    if not g#news then 
    do:
        run gds-grph_write-gds-grp-trigger in this-procedure (
            no
            ,"":U
            ,"":U
            , integer({&hn-delete})
            ).
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_gds-grp}
            , input ( buffer ub.gds-grp:handle )
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
    run trg/userlog.p (
        input {&nwsdochs_action_delete}
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