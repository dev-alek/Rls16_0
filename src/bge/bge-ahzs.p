block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bge-ahzs.p $
$Archive: bge/bge-ahzs.p $

Проверка архивов для диапазона дат для выгрузки

Автор: Хныкин Павел Андреевич
Дата создания: 10/25/05
Author: Pavel Khnykin
Creation date: 10/25/05

Input:

Output:

*/
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-verify-arh     as logical          no-undo.
define input parameter p-verify-ahsp    as logical          no-undo.
define input parameter p-verify-aht     as logical          no-undo.
define input parameter p-date-from      as date             no-undo.
define input parameter p-date-to        as date             no-undo.
define output parameter p-archive-ok    as logical          no-undo.
define output parameter p-comment       as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-ahzs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-ahzs.p $":U .
define variable vss-description as character no-undo init "Проверка архивов для диапазона дат для выгрузки".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }

    define variable v-date-from    as date         no-undo.
    define variable v-date-to      as date         no-undo.
    define variable v-can-print    as logical      no-undo.

do
on error undo, return error
:
    assign
        v-date-from = p-date-from
        v-date-to   = p-date-to
    .
    run rep/chk-ahz.p (
          input        p-obj-type
        , input        p-obj-code
        , input        yes                     /*p-verify-detail */
        , input        p-verify-arh
        , input        p-verify-ahsp
        , input        p-verify-aht
        , input        no                      /* p-check-act         */
        , input        0                       /* p-check-act-db-num  */
        , input        "":U                    /* p-check-act-user-id */
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