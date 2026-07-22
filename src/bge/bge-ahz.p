block-level on error undo, throw.
/*

$Revision: 56408f49832e, 136, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:48:25 2015 +0400 $
$Workfile: bge-ahz.p $
$Archive: bge/bge-ahz.p $

Проверка архивов для диапазона дат для выгрузки

Автор: Хныкин Павел Андреевич
Дата создания: 10/25/05
Author: Pavel Khnykin
Creation date: 10/25/05

Input:

Output:

*/
define input parameter parparentproc    as handle           no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-verify-arh     as logical          no-undo.
define input parameter p-verify-ahsp    as logical          no-undo.
define input parameter p-verify-aht     as logical          no-undo.
define input parameter p-date-from      as date             no-undo.
define input parameter p-date-to        as date             no-undo.
define output parameter p-archive-ok    as logical          no-undo.
define output parameter p-comment       as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: 56408f49832e, 136, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:25 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-ahz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-ahz.p $":U .
define variable vss-description as character no-undo init "Проверка архивов для диапазона дат для выгрузки".
{ cmp/vssrevis.i        }
{ cmp/trg-def.i        }
{ gbl/getcntxt.i def    }

define buffer buf_sys-ctrl    for ub.sys-ctrl.
define buffer buf_user-login  for ub.user-login.

define variable v-date-from    as date          no-undo .
define variable v-date-to      as date          no-undo .
define variable v-can-print    as logical       no-undo .
define variable v-login        as character     no-undo .

do
on error undo, return error
:
    find first buf_sys-ctrl no-lock .

    assign
      v-login = userid("{&db-name_schema}")
      v-cntxt-db-num = buf_sys-ctrl.db-num
    .
    find first buf_user-login no-lock
      where buf_user-login.db-num     = v-cntxt-db-num
        and buf_user-login.user-login = v-login
    no-error .
    if not available buf_user-login
    then do:
      undo, return error substitute( "Не найдена запись пользователя. БД:&1 Логин: &2"
                                   , v-cntxt-db-num
                                   , v-login
                                   ) .
    end.
    assign
      v-cntxt-userid  = buf_user-login.user-id
      v-date-from     = p-date-from
      v-date-to       = p-date-to
    .
    run rep/chk-ahz.p (
          input        p-obj-type
        , input        p-obj-code
        , input        yes                     /*p-verify-detail */
        , input        p-verify-arh
        , input        p-verify-ahsp
        , input        p-verify-aht
        , input        if g#auto then no else yes                     /* p-check-act         */
        , input        v-cntxt-db-num          /* p-check-act-db-num  */
        , input        v-cntxt-userid          /* p-check-act-user-id */
        , input-output v-date-from
        , input-output v-date-to
        , output       p-archive-ok
        , output       p-comment
        , output       v-can-print
    ) no-error .
    if error-status :error
    then do:
        undo, return error substitute( "Ошибка при вызове программы chk-ahz.p. &1. &2. &3"
            , return-value
            , trim(error-status :get-message(1))
            , trim(error-status :get-message(2))
        ) .
    end. /*if error-status:error then do:*/
    if v-date-from <> p-date-from
    or v-date-to   <> p-date-to
    then do:
        assign
            p-archive-ok = no
            p-comment    = substitute( "Выгрузка не может быть произведена. &1", p-comment )
        .
    end.
end.