block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись ПЕРСОНАЛА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/22/06
Author: Bakhtadze Natalya
Creation date: 05/22/06

*/


TRIGGER PROCEDURE FOR WRITE OF ub.staff old oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ПЕРСОНАЛА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         ,  ub.staff.role
                         ,  ub.staff.role-level
                         ,  ub.staff.work-place
                         ,  ub.staff.staff-code
                         ,  ub.staff.date-start
                         ) " }
{ cmp/trg-def.i }
{ gbl/gbclcode.i }
{ gbl/cur-time.i }
{ gbl/key-rec.i }

DEFINE VARIABLE v-today      as date      no-undo .
DEFINE VARIABLE v-time       as integer   no-undo .
define variable v-obj-type   as character no-undo .
define variable v-obj-code   as integer   no-undo .
define variable v-host-code  as integer   no-undo .
define variable conf-par     as character no-undo .
define variable par-type     as character no-undo .
define variable v-obj-db-num as integer   no-undo .
define variable v-no-uniq    as logical   no-undo .
define variable v-mess       as character no-undo .
define variable v-key-rec    as character no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-staff    for ub.c-staff.
define buffer buf_staff      for ub.staff.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    /**/
    if ub.staff.date-start = ?
        or ub.staff.date-end = ? then 
    do:
        message
            substitute("&1 &2 &3&4" +
            "Не определены даты начала или окончания работы в данной роли&4&5"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            , {&new-line}
            ,gbclcode-get-position  ( input ub.staff.role
            ,input ub.staff.role-level
            ,input ub.staff.work-place
            ,input ub.staff.staff-code )
            )
            view-as alert-box error .
        undo main-block, return error  .

    end.

    if not g#news then 
    do:
        if (ub.staff.db-num = 0
            and g#db-num <> 0 )
            or (ub.staff.db-num > 0
            and g#db-num <> ub.staff.db-num
            and g#db-num <> 0)
            then 
        do:
            message
                substitute("&1 &2 &3&4" +
                "Невозможно измененить запись персонала в чужой БД&4" +
                "БД персонала: &5&4" +
                "Текущая БД: &6&4&7"
                ,vss-workfile
                ,vss-revision
                ,vss-description
                ,ub.staff.db-num
                ,g#db-num
                ,gbclcode-get-position  ( input ub.staff.role
                ,input ub.staff.role-level
                ,input ub.staff.work-place
                ,input ub.staff.staff-code )
                )
                view-as alert-box error .
            undo main-block, return error  .
        end.
        if not (ub.staff.obj-type = '':U
            and
            ub.staff.obj-code = 0) then 
        do:
            { gbl/objdbnum.i ub.staff.obj-type ub.staff.obj-code v-obj-db-num }
            if v-obj-db-num = 0
                and g#db-num <> 0
                or (v-obj-db-num > 0
                and g#db-num <> v-obj-db-num
                and g#db-num <> 0) then 
            do:
                message
                    substitute("&1 &2 &3&4" +
                    "Невозможно измененить запись персонала в чужой БД&4" +
                    "БД персонала: &5&4" +
                    "Текущая БД: &6&4&7"
                    ,vss-workfile
                    ,vss-revision
                    ,vss-description
                    ,v-obj-db-num
                    ,g#db-num
                    ,gbclcode-get-position  ( input ub.staff.role
                    ,input ub.staff.role-level
                    ,input ub.staff.work-place
                    ,input ub.staff.staff-code )
                    )
                    view-as alert-box error .
                undo main-block, return error .
            end.
        end.
        if not new(ub.staff)
            and
            (ub.staff.role <> oldb.role
            or
            ub.staff.role-level <> oldb.role-level
            or
            ub.staff.work-place <> oldb.work-place
            or
            ub.staff.date-start <> oldb.date-start
            or
            ub.staff.staff-code <> oldb.staff-code
            ) then 
        do:

            message
                vss-workfile vss-revision vss-description skip
                "Для уже имеющейся записи нельзя изменить"
                "код физ.лица и/или" skip
                "роль" skip
                "место работы и/или" skip
                "дату начала работы в данной роли" skip
                view-as alert-box ERROR.
            undo main-block, return error '':U.
        end.
    end. /*if not g#news*/

    { trg/staffunq.i ub.staff buf_staff new(ub.staff) v-no-uniq v-mess }
    if v-no-uniq then 
    do:
        if g#esys then 
        do:
          v-mess = substitute("Уже существует Кассир с кодом &1. Физ лицо - код &2. Сохранение кода кассира &3 для кода физ лица &4 невозможно.", buf_staff.staff-code, buf_staff.psn-code, ub.staff.staff-code, ub.staff.psn-code) .
          return error v-mess .
        end.
        else 
        do:  
            message
                vss-workfile vss-revision vss-description skip
                v-mess
                view-as alert-box .
            undo main-block, return error.
        end. 
    end.
    if not (g#db-num <> 0 and g#news) then 
    do:
        run str/callnews.p (
            input {&table_staff}
            ,input (buffer ub.staff:handle)
            ) no-error .
        if error-status:error then 
        do:
            undo main-block, return error return-value .
        end.
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    create buf_c-staff.
    assign
        buf_c-staff.role             = ub.staff.role
        buf_c-staff.role-level       = ub.staff.role-level
        buf_c-staff.work-place       = ub.staff.work-place
        buf_c-staff.date-start       = ub.staff.date-start
        buf_c-staff.staff-code       = ub.staff.staff-code
        buf_c-staff.psn-code         = (if new ub.staff then ub.staff.psn-code else oldb.psn-code)
        buf_c-staff.chip-num         = next-value (s-cli-chip, {&db-name_schema})
        buf_c-staff.corr-user-db-num = g#db-num
        buf_c-staff.corr-user-name   = (if g#news
                                    then {&nts-user}
                                    else (if g#esys
                                          then {&esys-user}
                                          else g#userid)
                                    )
        buf_c-staff.corr-date        = v-today
        buf_c-staff.corr-time        = v-time
        .
    if buf_c-staff.role-level = {&role-level-object} then 
    do:
        { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
    end.
    else 
    do:
        v-host-code = buf_c-staff.host-code.
    end.
    run gen-key-rec in this-procedure (
        input  {&table_staff}
        ,input  buffer ub.staff:handle
        ,output v-key-rec ).
    create buf_c-cli-hist.
    buffer-copy buf_c-staff to buf_c-cli-hist
        assign
        buf_c-cli-hist.obj-type = {&prs}
        buf_c-cli-hist.obj-code = (if new ub.staff then ub.staff.psn-code else oldb.psn-code)
        buf_c-cli-hist.action = (if new( ub.staff) then integer({&hn-create}) else integer({&hn-update}))
        buf_c-cli-hist.subject = {&table_staff}
        buf_c-cli-hist.host-code = buf_c-staff.host-code
        buf_c-cli-hist.is-news = g#news
        buf_c-cli-hist.source-type = (if g#news
                                then {&hn-source-db}
                                else (if g#esys
                                      then {&hn-source-esys}
                                      else "":U)
                                )
        buf_c-cli-hist.source-ref = (if g#news
                                then string(g#news-source-db)
                                else (if g#esys
                                      then string(g#esys-source-esys)
                                      else "":U)
                                )
        buf_c-cli-hist.attr-code = v-key-rec
        .
    if not g#news then 
    do:
        { ref/send-ref.i conf-par par-type }
        if send-ref then 
        do:
            if buf_c-staff.role = {&role-seller} then 
            do:
                run trg/nu_slr.p (
                    input ub.staff.staff-code
                    ,input ub.staff.psn-code
                    ,input 0
                    ,input  "":U
                    ,input 0
                    ,input 'U':U
                    ,input ub.staff.password
                    ).
            end.
            if ub.staff.role = {&role-cashier} then 
            do:
                run trg/nu_cshr.p (
                    input ub.staff.staff-code
                    ,input ub.staff.psn-code
                    ,input 0
                    ,input "":U
                    ,input 0
                    ,input 'U':U
                    ,input ub.staff.password
                    ).
                run trg/userlog.p (
                    input {&nwsdochs_action_update}
                    , input {&table_staff}
                    , input ( buffer ub.staff :handle )
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
        end. /*if send-ref*/
    end.

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_staff}
            , input ( buffer ub.staff:handle )
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
end.