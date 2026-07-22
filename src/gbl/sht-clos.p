block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура закрытия смены

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/07/09
Author: Dmitry Ukhanov
Creation date: 09/07/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 09/19/05

*/
using ibs.th.str.*.
{ str/temp_suspChk.i }
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input  parameter p-check-cass    as   logical             no-undo.
define input  parameter p-silent        as   logical             no-undo .

define variable vss-revision    as char no-undo init "$Revision$":U .
define variable vss-author      as char no-undo init "$Author$":U .
define variable vss-date        as char no-undo init "$Date$":U .
define variable vss-workfile    as char no-undo init "$Workfile$":U .
define variable vss-archive     as char no-undo init "$Archive$":U .
define variable vss-description as char no-undo init "Закрытие смены".

{ cmp/trg-def.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ rul/ruleset_.i }
{ rul/tempcxml.i }

define variable s-date                as date      no-undo .    /* дата начала смены для документа */
define variable e-date                as date      no-undo .
define variable s-time                as integer   no-undo .    /* время начала смены для документа */
define variable e-time                as integer   no-undo .
define variable s-num                 as integer   no-undo .    /* порядок смены для документа */
define variable s-name                as character no-undo .    /* номер смены для документа */
define variable is-super              as logical   no-undo .    /* является ли пользователь менеджером */
define variable v-cancel              as logical   no-undo .
define variable glog                  as logical   no-undo .
define variable v-cur-date-error-code as integer   no-undo .
define variable v-err-msg             as character no-undo .
define variable v-rum-err             as logical   no-undo .
define variable v-shift-date          as date      no-undo .
define variable v-shift-num           as integer   no-undo .
define variable v-shift-name          as character no-undo .
define variable v-obj-date            as date      no-undo .
define variable ii                    as integer   no-undo .
define variable place-list            as character no-undo .

define buffer buf_pl-gds     for ub.pl-gds .
define buffer buf_shift-obj  for ub.shift-obj .
define buffer buf_place-attr for ub.place-attr .
define buffer buf_place-imp  for ub.place-imp .
define buffer cur_rvs-doc    for ub.rvs-doc .
define buffer cur_rvs-line   for ub.rvs-line .
define buffer prev_shift-obj for ub.shift-obj .
define buffer prev_rvs-doc   for ub.rvs-doc .
define buffer prev_rvs-line  for ub.rvs-line .
define buffer buf_place      for ub.place .

{ gbl/getcntxt.i get }
/* проверяем права на работу со сменами */
/* менеджер */
assign
    is-super = no
    .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_shift_super':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  false
  glog
}
if glog
    then 
do:
    assign
        is-super = yes
        .
end.
else 
do:
  /* обычный пользователь */
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_shift_regular':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    glog
  }
end.
if not glog then 
do:
    assign
        v-err-msg = substitute( "Вы не имеете прав для работы со сменами.&1Объект: &2&3&1", {&new-line}, p-curr-obj-type, p-curr-obj-code )
        .
    if p-silent <> true then 
    do:
        message
            v-err-msg
            view-as alert-box information.
    end.
    undo, return error v-err-msg .
end.

/* ищем текущую смену */
find first buf_shift-obj
    where buf_shift-obj.obj-type = p-curr-obj-type
    and buf_shift-obj.obj-code = p-curr-obj-code
    and buf_shift-obj.status_ = {&sht-current}
    use-index pi
    no-error.
if not available buf_shift-obj then 
do:
    assign
        v-err-msg = substitute( "Нет открытой смены на объекте: &2&3&1Невозможно закрыть текущую смену.", {&new-line}, p-curr-obj-type, p-curr-obj-code )
        .
    if p-silent <> true then 
    do:
        message
            v-err-msg
            view-as alert-box error.
    end.
    undo, return error v-err-msg .
end.
assign
    s-date       = buf_shift-obj.shift-date
    s-num        = buf_shift-obj.shift-num
    s-name       = buf_shift-obj.shift-name
    s-time       = buf_shift-obj.open-time
    v-shift-date = buf_shift-obj.shift-date
    v-shift-num  = buf_shift-obj.shift-num
    v-shift-name = buf_shift-obj.shift-name
    .


if p-silent <> true then 
do:
    glog = no.
    message
        "Закрыть текущую смену по" p-curr-obj-type p-curr-obj-code skip
        "Дата начала смены:" buf_shift-obj.open-date skip
        "Время начала смены:" string( buf_shift-obj.open-time, "HH:MM" ) skip
        "Номер смены:" s-name skip
        "Порядок смены:" s-num "?"
        view-as alert-box question buttons OK-Cancel update glog.
    if not glog then
        return error.
end.

/*{ gbl/curobjdt.i p-curr-obj-type p-curr-obj-code s-date }*/
/* проверяем, что смену открывал тот же пользователь */
if buf_shift-obj.open-id <> v-cntxt-userid
    and is-super = false
    then 
do:
    assign
        v-err-msg = substitute( "Смена должна быть закрыта тем же пользователем,&1"
                            + "который ее открывал или менеджером.&1"
                            + "Невозможно закрыть текущую смену.&1"
                            + "Открыл текущую смену: &2&1"
                            , {&new-line}
                            , buf_shift-obj.open-id
                          ) .
    if p-silent <> true then 
    do:
        message
            v-err-msg
            view-as alert-box.
    end.
    undo, return error v-err-msg .
end.
if p-check-cass = true then 
do:
    /* проверяем отсутствие чеков по смене и прочие кассовые запреты */
    run str/deskshft.p
        ( input parparentproc
        ,input p-silent
        ,input p-curr-obj-type
        ,input p-curr-obj-code
        ,input s-date
        ,input s-num
        ,input s-name
        ) no-error.
    if error-status :error then 
    do:
        assign
            v-err-msg = substitute( "&1.&2&3&2&4&2"
                                , vss-workfile
                                , {&new-line}
                                , return-value
                                , error-status :get-message (1)
                              ).
        if p-silent <> true then 
        do:
            message
                v-err-msg
                view-as alert-box error.
        end.
        undo, return error v-err-msg .
    end.
end.

if p-silent <> true then 
do:
    /* смена может быть закрыта произвольным временем */
    run gbl/shift.w
        ( input parparentproc
        ,input p-curr-obj-type
        ,input p-curr-obj-code
        ,input-output s-date  /* дата начала смены для документа */
        ,input-output e-date
        ,input-output s-time  /* время начала смены для документа */
        ,input-output e-time
        ,input-output s-num   /* порядок смены для документа */
        ,input-output s-name  /* номер смены для документа */
        ,input 'time-only':U
        ,output v-cancel
        ) no-error.
    if error-status:error then 
    do:
        message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка ввода времени для закрытия смены."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
            view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = true then 
    do:
        undo, return error.
    end.
end.

run str/checknakl.p
    ( input parparentproc
    ,input p-silent
    ,input p-curr-obj-type
    ,input p-curr-obj-code
    ,input s-date
    ,input s-num
    ,input s-name
    ,output v-cancel
    ) no-error.
if v-cancel = false then 
do:
    undo, return error.
end.     

stop-shift:
do transaction
    on error undo stop-shift, return error return-value
    :
/* Проверки отклонений */
define variable prc-dev-mass as decimal no-undo .
define variable dev-paid-trans as decimal no-undo .
{ str/shiftClosCheckDiff.i }

find first ub.shift-param exclusive-lock where ub.shift-param.obj-code = p-curr-obj-code and
    ub.shift-param.obj-type = p-curr-obj-type and
    ub.shift-param.shift-date = v-shift-date and
    ub.shift-param.shift-name = v-shift-name and
    ub.shift-param.shift-num = v-shift-num and
    ub.shift-param.gds-code = 0 and
    ub.shift-param.pl-code = 0 no-error .
if not available (ub.shift-param) then 
do:
    create ub.shift-param .
    assign
        ub.shift-param.obj-code   = p-curr-obj-code 
        ub.shift-param.obj-type   = p-curr-obj-type 
        ub.shift-param.shift-date = v-shift-date 
        ub.shift-param.shift-name = v-shift-name 
        ub.shift-param.shift-num  = v-shift-num .
end.
assign
    ub.shift-param.prc-dev-mass   = prc-dev-mass
    ub.shift-param.dev-paid-trans = dev-paid-trans
    .


find first buf_shift-obj
    where buf_shift-obj.obj-type = p-curr-obj-type
    and buf_shift-obj.obj-code = p-curr-obj-code
    and buf_shift-obj.status_ = {&sht-current}
    use-index pi
    no-error.
      

    if not g#news then 
    do:
        /* запуск rum */
        run str/diallog.w ( input parparentproc
            , input this-procedure
            , input ('local-rum':U + {&delim-par} +
            "1" + {&delim-par} +
            "1" + {&delim-par} +
            "1" + {&delim-par} +
            "1" + {&delim-par} +
            "yes")
            , input string(1) /*до закрытия*/
            , input p-silent
            , input ''
            , input 'Операции, выполняемые перед закрытием смены') no-error .
    end.
    if v-rum-err then 
    do:
        undo stop-shift, return error .
    end.
    /* блокируем все места хранения */
    for each buf_pl-gds
        where buf_pl-gds.obj-type = p-curr-obj-type
        and buf_pl-gds.obj-code = p-curr-obj-code
        on error undo stop-shift, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        :
        run trg/lockplgd.p
            ( input p-curr-obj-type
            ,input p-curr-obj-code
            ,input buf_pl-gds.pl-code
            ,input buf_pl-gds.gds-code
            ,input "assign-rvs-on=true":U
            ,input "":U
            ,input true
            ) no-error.
        if error-status:error then 
        do:
            assign
                v-err-msg = substitute( "&1.&2&3&2&4&2"
                                , vss-workfile
                                , {&new-line}
                                , return-value
                                , error-status :get-message (1)
                              ).
            if p-silent <> true then 
            do:
                message
                    v-err-msg
                    view-as alert-box error.
            end.
            undo, return error v-err-msg .
        end.
    end.

    { gbl/curobjdt.i buf_shift-obj.obj-type buf_shift-obj.obj-code v-obj-date }
    assign
        buf_shift-obj.status_    = {&sht-closed}
        buf_shift-obj.close-date = v-obj-date
        .
    if p-silent <> true then 
    do:
        if s-time > 86400 then 
        do:
            assign
                s-time = s-time - 86400.
        end.
        assign
            buf_shift-obj.close-time = s-time       /* для проверки времени в триггере */
            .
    end.
    else 
    do:
        if buf_shift-obj.close-time = 0 then 
        do:
            assign
                v-err-msg = substitute( "Не задано время закрытия смены.&1"
                                , {&new-line}
                              ) .
            if p-silent <> true then 
            do:
                message
                    v-err-msg
                    view-as alert-box.
            end.
            undo, return error v-err-msg .
        end.
    end.

    /* разблокируем все места хранения */
    for each buf_pl-gds
        where buf_pl-gds.obj-type = p-curr-obj-type
        and buf_pl-gds.obj-code = p-curr-obj-code
        on error undo stop-shift, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        :
        run trg/lockplgd.p
            ( input p-curr-obj-type
            ,input p-curr-obj-code
            ,input buf_pl-gds.pl-code
            ,input buf_pl-gds.gds-code
            ,input "assign-rvs-on=false":U
            ,input "":U
            ,input true
            ) no-error.
        if error-status:error then 
        do:
            assign
                v-err-msg = substitute( "&1.&2&3&2&4&2"
                                , vss-workfile
                                , {&new-line}
                                , return-value
                                , error-status :get-message (1)
                              ).
            if p-silent <> true then 
            do:
                message
                    v-err-msg
                    view-as alert-box error.
            end.
            undo, return error v-err-msg .
        end.
    end.
  
    release buf_shift-obj no-error.
    if error-status:error then 
    do:
        if not p-silent then 
        do:
            /*      message                               */
            /*      error-status:error skip               */
            /*      return-value view-as alert-box error .*/
            undo stop-shift, return error.
        end.
        else 
        do:
            undo stop-shift, return error substitute("Ошибка при закрытии смены: &1&2 От &3 П. &4&5&6&5&7"
                , p-curr-obj-type
                , p-curr-obj-code
                , s-date
                , s-num
                , {&new-line}
                , error-status:get-message(1)
                , return-value ).

        end.
    end.
end. /*do transaction*/

/* Контроль плотности НП при реализации на АЗС */
run str/calc-shift-period.p (input parparentproc,
    input p-curr-obj-type,
    input p-curr-obj-code,
    input v-shift-date,
    input v-shift-num)
    no-error .
if error-status:error then 
do:
    assign
        v-err-msg = substitute( "&1.&2&3&2&4&2"
                            , vss-workfile
                            , {&new-line}
                            , return-value
                            , error-status :get-message (1)
                          ).
    if p-silent <> true then 
    do:
        message
            v-err-msg
            view-as alert-box error.
    end.
/*  undo, return error v-err-msg .*/
end.

run str/prep1C-shift-period.p (input parparentproc,
    input p-curr-obj-type,
    input p-curr-obj-code,
    input v-shift-date,
    input v-shift-num)
    no-error .
if error-status:error then 
do:
    assign
        v-err-msg = substitute( "&1.&2&3&2&4&2"
                            , vss-workfile
                            , {&new-line}
                            , return-value
                            , error-status :get-message (1)
                          ).
    if p-silent <> true then 
    do:
        message
            v-err-msg
            view-as alert-box error.
    end.
/*  undo, return error v-err-msg .*/
end.

find first cur_rvs-doc no-lock
    where cur_rvs-doc.obj-type   = p-curr-obj-type
    and cur_rvs-doc.obj-code   = p-curr-obj-code
    and cur_rvs-doc.shift-date = v-shift-date
    and cur_rvs-doc.shift-num  = v-shift-num
    and cur_rvs-doc.status_    = {&fact}
    and cur_rvs-doc.rvs-type   = {&rvs-shift}
    no-error.

find last prev_shift-obj no-lock
    where prev_shift-obj.obj-type = p-curr-obj-type
    and prev_shift-obj.obj-code = p-curr-obj-code
    and prev_shift-obj.status_  = {&sht-closed}
    and ( prev_shift-obj.shift-date < v-shift-date
    or prev_shift-obj.shift-date = v-shift-date
    and prev_shift-obj.shift-num  < v-shift-num
    )
    use-index stts
    no-error.

if available prev_shift-obj
    then 
do :
    find first prev_rvs-doc no-lock
        where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
        and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
        and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
        and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
        and prev_rvs-doc.status_    = {&fact}
        and prev_rvs-doc.rvs-type   = {&rvs-shift}
        no-error.
end .

if available cur_rvs-doc
    and available prev_rvs-doc
    then 
do :
    for each cur_rvs-line no-lock where cur_rvs-line.rvs-code = cur_rvs-doc.rvs-code
        and cur_rvs-line.obj-type = cur_rvs-doc.obj-type
        and cur_rvs-line.obj-code = cur_rvs-doc.obj-code,
        first buf_place no-lock where buf_place.pl-code = cur_rvs-line.pl-code
        :
        find first prev_rvs-line no-lock where prev_rvs-line.rvs-code = prev_rvs-doc.rvs-code
            and prev_rvs-line.obj-type = prev_rvs-doc.obj-type
            and prev_rvs-line.obj-code = prev_rvs-doc.obj-code
            and prev_rvs-line.pl-code  = cur_rvs-line.pl-code
            no-error .
        if not available prev_rvs-line
            or (available prev_rvs-line and prev_rvs-line.gds-code <> cur_rvs-line.gds-code)
            then 
        do :
            place-list = place-list + string(recid(buf_place)) + "," .
        end .
    end .
    place-list = trim(place-list, ",") .
    if place-list > ""
        then 
    do :
        run utl/init-shift-period.p (input place-list) .
    end .
end .

/* Новые параметры резервуаров и ГТ, импортированные из 1С */
for each buf_place-attr exclusive-lock where buf_place-attr.obj-type = p-curr-obj-type
    and buf_place-attr.obj-code = p-curr-obj-code
    and buf_place-attr.attr-code = "pending-table-version"
    :
    do ii = 1 to num-entries(buf_place-attr.attr-value) :
        find first buf_place-imp no-lock where buf_place-imp.obj-type = buf_place-attr.obj-type
            and buf_place-imp.obj-code = buf_place-attr.obj-code
            and buf_place-imp.pl-code  = buf_place-attr.pl-code
            and buf_place-imp.table-version = integer(entry(ii, buf_place-attr.attr-value))
            no-error .
        if available buf_place-imp
            and buf_place-imp.status_ = 0
            then 
        do :
            run str/apply_place-imp.p (input buf_place-imp.obj-type,
                input buf_place-imp.obj-code,
                input buf_place-imp.pl-code,
                input buf_place-imp.table-version)
                no-error .
            if error-status:error
                then 
            do :
                assign
                    v-err-msg = substitute( "&1.&2&3&2&4&2"
                                  , vss-workfile
                                  , {&new-line}
                                  , return-value
                                  , "Ошибка при применении новых параметров резервуара "
                                ).
                if p-silent <> true then 
                do:
                    message
                        v-err-msg
                        view-as alert-box error.
                end.
            end .
        end .
    end .
    delete buf_place-attr .
end .

if p-silent <> true then 
do:
    run mainmenu-disp-mutable in parparentproc (
        output v-cur-date-error-code
        ).
    message
        "Текущая смена закрыта."
        view-as alert-box information.
end.

run str/diallog.w ( input parparentproc
    , input this-procedure
    , input ('local-rum':U + {&delim-par} +
    "1" + {&delim-par} +
    "0" + {&delim-par} +
    "1" + {&delim-par} +
    "1" + {&delim-par} +
    "yes")
    , input string(2) /*после закрытия*/
    , input p-silent
    , input ''
    , input 'Операции, выполняемые после закрытия смены') no-error .
         
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_currency for ub.currency.
define variable v_dataseth  as handle    no-undo .


{ gbl/basecode.i v-cntxt-host-code-obj v-base-code }
find first buf_currency no-lock
    where buf_currency.curr-code = v-base-code
    .
        
/* сменный отчет */
run str/reportSend.p (
    input parparentproc,
    input v-cntxt-userid,
    input v-shift-date,
    input v-shift-num,
    input v-shift-name,
    input p-curr-obj-code,
    input p-curr-obj-type) .

return .


procedure  local-rum:
    define input parameter parparentproc as widget-handle no-undo .
    define input parameter p-parent-handle  as widget-handle no-undo .
    define input parameter p-log-handle  as handle no-undo .
    define input parameter p-parameter   as character no-undo .

    define variable v-uniq-key-rec       as character no-undo .
    define variable v-shift-uniq-key-rec as character no-undo .
    define variable v-list               as character no-undo extent 2.
    define variable v-thobj-type-list    as character no-undo extent 2.
    define variable v-entry0             as character no-undo .
    define variable v-entry              as character no-undo .
    define variable v-thobj-type0        as character no-undo .
    define variable v-thobj-type         as character no-undo .
    define variable v-obj-type           as character no-undo .
    define variable v-obj-code           as integer   no-undo .
    define variable v-upper-code         as character no-undo .
    define variable v-ii                 as integer   no-undo .
    define variable v-jj                 as integer   no-undo .
    define variable v-step               as integer   no-undo .
    define buffer buf_thbj-attr for ub.thbj-attr.
    assign
        v-list[1]            = {&attr-rum_fdoc}
        v-list[2]            = {&attr-rum_obj_rep} + {&comma-char} + {&attr-rum_rep}
        v-thobj-type-list[1] = "global"
        v-thobj-type-list[2] = {&g___object} + {&comma-char} + "global"
        .
    main-block:
    do
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        v-step = integer(p-parameter).
        run gen-key-rec in this-procedure (
            input  {&table_shift-obj}
            ,input (buffer buf_shift-obj:handle)
            ,output v-shift-uniq-key-rec).

        _v-ii:
        do v-ii = 1 to num-entries(v-list[v-step], {&delim-par} ):
            v-entry0  = entry(v-ii, v-list[v-step], {&delim-par}).
            v-thobj-type0 = entry(v-ii, v-thobj-type-list[v-step], {&delim-par}).
            _v-jj:
            do v-jj = 1 to num-entries(v-entry0):
                assign
                    v-entry      = entry(v-jj, v-entry0)
                    v-thobj-type = entry(v-jj, v-thobj-type0).
                .
                case v-thobj-type:
                    when "global" then 
                        do:
                            v-obj-type = ''.
                            v-obj-code = 0.
                            v-upper-code = {&attr-rum}.
                        end.
                    when {&g___object} then 
                        do:
                            v-obj-type = buf_shift-obj.obj-type.
                            v-obj-code = buf_shift-obj.obj-code.
                            v-upper-code = {&attr-rum_obj}.
                        end.
                end case.
                find first buf_thbj-attr no-lock where
                    buf_thbj-attr.upper-prop-code = v-upper-code
                    and buf_thbj-attr.prop-code = v-entry
                    and buf_thbj-attr.obj-type = v-obj-type
                    and buf_thbj-attr.obj-code = v-obj-code
                    and buf_thbj-attr.property-value-logical = yes
                    no-error.
                if not available buf_thbj-attr then 
                do:
                    next _v-jj.
                end.
                else 
                do:
                    leave _v-jj.
                end.
            end. /*do v-jj = 1 to num-entries(v-entry0):*/
            if available buf_thbj-attr
                then 
            do:
                run gen-key-rec in this-procedure (
                    input  {&table_thbj-attr}
                    ,input (buffer buf_thbj-attr:handle)
                    ,output v-uniq-key-rec).
                case v-entry:
                    when {&attr-rum_fdoc} then 
                        do:
                            run str/fdocrum.p
                                (
                                input parparentproc
                                ,input p-parent-handle
                                ,input p-log-handle
                                ,input {&fdoc-proc_work_fin-doc}
                                ,input 0 /*p-profile-id*/
                                ,input {&fdoc-proc_24} /*p-codex-id*/
                                ,input {&fdoc-proc_24_work_fin-doc_1} /*p-ruleset-id*/
                                ,input g#db-num        /*current-db-num*/
                                ,input v-uniq-key-rec
                                ,input v-shift-uniq-key-rec
                                ,input yes /*p-save*/
                                ) no-error .
                        end.
                    when {&attr-rum_rep} then 
                        do:
                            run rep/reprum.p
                                (
                                input parparentproc
                                ,input p-parent-handle
                                ,input p-log-handle
                                ,input {&rep-proc_rep-close-shift}
                                ,input 0 /*p-profile-id*/
                                ,input {&rep-proc_22} /*p-codex-id*/
                                ,input {&rep-proc_22_close-shift_5} /*p-ruleset-id*/
                                ,input 0 /*p-once-more*/
                                ,input g#db-num        /*current-db-num*/
                                ,input v-uniq-key-rec
                                ,input v-shift-uniq-key-rec + {&delim-par} + "" /*директория определяется внутри*/
                                ,input yes /*p-save*/
                                ) no-error .
                        end.
                end case.
                if error-status:error then 
                do:
                    assign
                        v-rum-err = yes.
                    undo main-block, return error .
                end.
            end.   
        end.
    end.
end procedure. /* local */