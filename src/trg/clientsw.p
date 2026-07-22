block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

триггер отменяется в cligrpw.p (grpw.i) - WRITE-триггере для cli-grp,
когда меняется поле cli-grp.node-name, чтобы не перегружать новости,
поэтому изменения поля clients.grp-name в новости не пойдут

*/

TRIGGER PROCEDURE FOR WRITE OF ub.clients  OLD old-clients.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись клиента".
{ cmp/vssrevis.i "substitute('&1|&2', ub.clients.obj-type, ub.clients.obj-code) " }
{ cmp/trg-def.i  }
{ ref/cgrplbfn.i }
{ gbl/cur-time.i }
{ trg/clientsh.i trig old-clients ub.clients }
{ gbl/db-attr.i  }
{ gbl/gbclcode.i }

define variable g-name         as char      format "x(30)" no-undo .
DEFINE VARIABLE conf-par       as character no-undo .
DEFINE VARIABLE par-type       as character no-undo .
DEFINE VARIABLE v-l-chr        as character no-undo .
define variable v-date         as date      no-undo.
define variable v-time         as integer   no-undo.
define variable v-seller-code  as integer   no-undo .
define variable v-cashier-code as integer   no-undo .
define variable v-password     as character no-undo .
define variable v-trg-param    as character no-undo .
assign
    v-trg-param          = ub.clients.trg-param
    ub.clients.trg-param = '':U
    .


define buffer buf_dis-card for ub.dis-card.
define buffer buf_person   for ub.person.
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_shop     for ub.shop.
define buffer buf_store    for ub.store.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    /* проверки для объектов */
    if not new(ub.clients) then 
    do:
        /* код и тип клиента менять нельзя */
        if ub.clients.obj-type <> old-clients.obj-type
            or ub.clients.obj-code <> old-clients.obj-code then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Нельзя поменять тип или код клиента" skip
                "ub.clients.obj-type" ub.clients.obj-type skip
                "ub.clients.obj-code" ub.clients.obj-code skip
                "old-clients.obj-type" old-clients.obj-type skip
                "old-clients.obj-code" old-clients.obj-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    else 
    do:
        if  ub.clients.obj-type <> {&stock}
            and ub.clients.obj-type <> {&shop}
            and ub.clients.obj-type <> {&cmp}
            and ub.clients.obj-type <> {&prs}
            then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Неизвестный тип клиента" skip
                "ub.clients.obj-type" ub.clients.obj-type skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        if ub.clients.obj-code = ? then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не задан код клиента" skip
                "ub.clients.obj-code" ub.clients.obj-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        if ub.clients.obj-code = 0 then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не задан код клиента" skip
                "ub.clients.obj-code" ub.clients.obj-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.

    /* проверка привязки объекта к базе данных */
    if ub.clients.obj-type = {&stock}
        or ub.clients.obj-type = {&shop}
        then 
    do:
        /* проверяем ссылку на базу данных */
        find first ub.db no-lock
            where ub.db.db-num = ub.clients.db-num
            no-error .
        if not available ub.db then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Неправильная ссылка на базу данных" skip
                "Клиент" ub.clients.obj-type ub.clients.obj-code skip
                "База данных" ub.clients.db-num skip
                view-as alert-box error .
            undo, return error .
        end.

        if new(ub.clients)
            then 
        do:
            /* для нового объекта */
            /* необходимо установить статус архивов для БД по умолчанию */
            define variable v-attr-arh-disable-chr   as character no-undo .
            define variable v-attr-arh-disable-type  as character no-undo .
            define variable v-attr-arh-disable       as logical   no-undo .
            define variable v-attr-ahsp-disable-chr  as character no-undo .
            define variable v-attr-ahsp-disable-type as character no-undo .
            define variable v-attr-ahsp-disable      as logical   no-undo .
            define variable v-attr-aht-disable-chr   as character no-undo .
            define variable v-attr-aht-disable-type  as character no-undo .
            define variable v-attr-aht-disable       as logical   no-undo .

            run db-attr-value in this-procedure
                (input  ub.clients.db-num
                ,input  {&attr-db-arh-disable}
                ,output v-attr-arh-disable-chr
                ,output v-attr-arh-disable-type
                ) .
            assign
                v-attr-arh-disable = lookup(v-attr-arh-disable-chr, 'yes,true':u) > 0
                .
            if v-attr-arh-disable = true
                then 
            do:
                run trg/ahobjdis.p
                    (input  {&btpr-type-arh}
                    ,input  ub.clients.obj-type
                    ,input  ub.clients.obj-code
                    ,input  true
                    ) .
            end.

            run db-attr-value in this-procedure
                (input  ub.clients.db-num
                ,input  {&attr-db-ahsp-disable}
                ,output v-attr-ahsp-disable-chr
                ,output v-attr-ahsp-disable-type
                ) .
            assign
                v-attr-ahsp-disable = lookup(v-attr-arh-disable-chr, 'yes,true':u) > 0
                .
            if v-attr-ahsp-disable = true
                then 
            do:
                run trg/ahobjdis.p
                    (input  {&btpr-type-ahsp}
                    ,input  ub.clients.obj-type
                    ,input  ub.clients.obj-code
                    ,input  true
                    ) .
            end.

            run db-attr-value in this-procedure
                (input  ub.clients.db-num
                ,input  {&attr-db-ahsp-disable}
                ,output v-attr-aht-disable-chr
                ,output v-attr-aht-disable-type
                ) .
            assign
                v-attr-aht-disable = lookup(v-attr-arh-disable-chr, 'yes,true':u) > 0
                .
            if v-attr-aht-disable = true
                then 
            do:
                run trg/ahobjdis.p
                    (input  {&btpr-type-aht}
                    ,input  ub.clients.obj-type
                    ,input  ub.clients.obj-code
                    ,input  true
                    ) .
            end.

        end.

        if not new(ub.clients) then 
        do:
            if ub.clients.obj-type = {&shop} then 
            do:
                find first buf_shop no-lock where
                    buf_shop.obj-code = ub.clients.obj-code .
                find first buf_sysconf no-lock where
                    buf_sysconf.host-code = buf_shop.host-code.
            end.
            else 
            do:
                find first buf_store no-lock where
                    buf_store.obj-code = ub.clients.obj-code .
                find first buf_sysconf no-lock where
                    buf_sysconf.host-code = buf_store.host-code.
            end.
            if buf_sysconf.firm-db-num <> 0 AND
                ub.clients.db-num <> 0 then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Главная БД фирмы не совпадает с БД, к которой относится объект" skip
                    view-as alert-box error .
                undo main-block, return error.
            end.
        end.
        if not new(ub.clients) then 
        do:
            if ub.clients.db-num <> old-clients.db-num then 
            do:
                /* объект переносится из одной базы данных в другую */
                /* необходимо проверить, что объект можно переносить у удаленной БД в офис */
                /* и из офисной БД в удаленную */
                /*  в связи с новой утилитой mov-obj.w  проверка закоментарена */
                /*
                if  ub.clients.db-num  <> 0
                and old-clients.db-num <> 0 then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "Нельзя переносить объект из одной удаленной БД в другую удаленную" skip
                    "Клиент" ub.clients.obj-type ub.clients.obj-code skip
                    "Новая база данных" ub.clients.db-num skip
                    "Старая база данных" old-clients.db-num skip
                    view-as alert-box error .
                  undo, return error .
                end.
                */
                /* проверяем, что на объекте отсутствуют открытые документы */
                /* это связано с тем, что резервирование для офисной и удаленной БД */
                /* может выполняться по разному */
                run trg/objchk.p
                    (input ub.clients.obj-type
                    ,input ub.clients.obj-code
                    ,input "check-open":u
                    ) no-error .
                if error-status :error then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Нельзя переносить объект из одной удаленной БД в другую удаленную" skip
                        "Не прошла проверка отсутствия открытых документов" skip
                        "Клиент" ub.clients.obj-type ub.clients.obj-code skip
                        "Новая база данных" ub.clients.db-num skip
                        "Старая база данных" old-clients.db-num skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo, return error .
                end.

            /* move-obj.w - присвоить базе данных особый статус, который не позволит */
            /* обмениваться новостями до тех пор, пока не будет создана новая */
            /* удаленная база данных */

            /* move-obj.w  - необходимо что-то делать с sequence в офисной и удаленной БД */
            /* одно из решений - каким-то образом помечать БД, изменять статус */
            /* запрещать работу с ней и т.д. */
            /* затем разрешать работу только после запуска утилиты, обновляющей sequence */

            /* move-obj.w  - необходимо каки-либо образом гарантировать, что */
            /* в этот момент не закрываются, не создаются новые документы */

            end.
        end.
    end.
    else 
    do:
        /* проверяем ссылку на базу данных */
        if ub.clients.db-num <> ? then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Клиент не может принадлежать какой либо базе данных" skip
                "Поле база данных должно иметь неопределенное значение" skip
                "Клиент" ub.clients.obj-type ub.clients.obj-code skip
                "База данных" ub.clients.db-num skip
                view-as alert-box error .
            undo, return error .
        end.
    end.

    if ub.clients.grp-code = ? then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Должна быть задана группа клиентов" skip
            "Клиент" ub.clients.obj-type ub.clients.obj-code skip
            view-as alert-box error .
        undo, return error .
    end.

    find first ub.cli-grp no-lock
        where ub.cli-grp.node-code = clients.grp-code
        no-error .
    if not available ub.cli-grp then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неизвестная группа клиентов" skip
            "Клиент" ub.clients.obj-type ub.clients.obj-code skip
            "Группа клиентов" clients.grp-code skip
            view-as alert-box error .
        undo, return error .
    end.

    /* если клиент новый или изменилась группа клиента, */
    /* то изменить полное название группы -- */
    /* путь до группы клиента за исключением корневой группы */
    if new(ub.clients)
        or (old-clients.grp-code <> clients.grp-code) or clients.grp-name = "" then 
    do:
        assign
            g-name = ""
            .
        run cli-grplib-get-full-name in this-procedure
            (input        clients.grp-code
            ,output g-name
            ).
        assign
            clients.grp-name = g-name
            .
    end.
    buffer-compare ub.clients
        to old-clients
        case-sensitive
        save result in v-l-chr .
    if
        not g#news and
        not (ub.clients.obj-type = {&shop} or ub.clients.obj-type = {&stock}) then 
    do:
        { ref/send-ref.i conf-par par-type }
        /*создаем batchporcess для отсылки на кассы*/
        if send-ref then 
        do:
            if not new(ub.clients) then 
            do:
                /*выясним что изменилось*/
                if lookup("obj-name", v-l-chr) > 0 then 
                do:
                    for each buf_dis-card no-lock where
                        buf_dis-card.cli-type = ub.clients.obj-type
                        AND buf_dis-card.cli-code = ub.clients.obj-code :
                        run trg/nu_dcard.p (
                            input  buf_dis-card.d-card
                            ,input  buf_dis-card.emitent-host-code
                            ,input  "":U
                            ,input  0
                            ,input  "U":U
                            ).
                    end.
                end.
            end. /*if not new(ub.clients) then do:*/
        end. /*if send-ref then do:*/
        /*а нужно ли посылать как кассира или продавца*/
        /*проверим какой код клиента - относится ли к нашей БД?*/
        If ub.clients.obj-type = {&prs} then 
        do:
            if old-clients.obj-name <> ub.clients.obj-name then 
            do:
                assign
                    v-seller-code = gbclcode-get-db-role (
                                                  input {&role-seller}
                                                 ,input g#db-num
                                                 ,input ub.clients.obj-code
                                                 ,input ?
                                                 ,output v-password
                                                    ) no-error .
                if v-seller-code > 0 then 
                do:
                    run trg/nu_slr.p (
                        input  v-seller-code
                        ,input ub.clients.obj-code
                        ,input 0
                        ,input  "":U
                        ,input  0
                        ,input  "U":U
                        ,input v-password
                        ).
                end.
                assign
                    v-cashier-code = gbclcode-get-db-role (
                                                   input {&role-cashier}
                                                  ,input g#db-num
                                                  ,input ub.clients.obj-code
                                                  ,input ?
                                                  ,output v-password
                                                    ) no-error .
                if v-cashier-code > 0 then 
                do:
                    run trg/nu_cshr.p (
                        input  v-cashier-code
                        ,input ub.clients.obj-code
                        ,input 0
                        ,input  "":U
                        ,input  0
                        ,input  "U":U
                        ,input v-password
                        ).
                end.
            end. /*if old-clients.obj-name <> ub.clients.obj-name then do:*/
        end. /*If ub.clients.obj-type = {&prs} */
    end. /* if  not g#news and  */
    if lookup({&trg-param-no-hist}, v-trg-param) = 0 then 
    do:
        if
            g#news
            or  (v-l-chr <> "":U
            and lookup(v-l-chr, "sup-gds,sup-cons,sup-serv,buy-gds,buy-cons,buy-serv,is-prod":U) = 0
            ) then 
        do:
            run clientsh_write-clients-trigger in this-procedure  (
                input new(ub.clients)
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
            if error-status:error then undo main-block, return error return-value.
        end.
    end.


    if lookup({&trg-param-no-callnews}, v-trg-param) = 0 then 
    do:
        run str/callnews.p
            (input {&table_clients}
            ,input (buffer ub.clients:handle)
            ) no-error .
        if error-status:error then 
        do:
            undo main-block, return error return-value .
        end.
    end.
    { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    " ( if new(ub.clients) then {&clients-proc_cliadd} else {&clients-proc_cliupdate} )"
    " buffer old-clients:handle "
    " buffer ub.clients:handle "
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


    /* В Главной БД не в новостях надо рассчитать или удалить обороты по покупателю */
    if not g#news and g#db-num = 0 then 
    do:
        if ub.clients.turnover-buyer =  true  and  old-clients.turnover-buyer = false then 
        do:
            run ref/calcturn.p (ub.clients.obj-type, ub.clients.obj-code) no-error .
        end.
        if ub.clients.turnover-buyer =  false and  old-clients.turnover-buyer = true  then 
        do:
            run ref/delturn.p ( ub.clients.obj-type, ub.clients.obj-code ) no-error .
        end.
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_clients}
            , input ( buffer ub.clients:handle )
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
    if new(ub.clients) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_clients}
            , input ( buffer ub.clients :handle )
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
            , input {&table_clients}
            , input ( buffer ub.clients :handle )
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
end. /*doe*/