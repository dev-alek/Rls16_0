block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Open XML. Триггер на изменение записи внешней подсистемы

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

trigger procedure for write of ub.ext-system old buffer old-ext-system .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Open XML. Триггер на изменение записи внешней подсистемы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

    define variable v-chip-num    as integer      no-undo.

main-block:
do transaction
on error undo main-block, return error
:
    if ub.ext-system.esys-creid = "":U
    then do:        /* записываем того, кто изменил внешнюю подсистему */
        assign
            ub.ext-system.esys-creid = g#userid
        .
    end.
    if not g#news
    then do:
        { gbl/curdburt.i
            ub.ext-system.esys-user-db-num
            ub.ext-system.esys-user-name
            ub.ext-system.esys-sys-date
            ub.ext-system.esys-sys-time
            ub.ext-system.esys-sys-time-int
        }
        run trg/extsysh.p (
              buffer old-ext-system
            , output v-chip-num
        ) no-error .
        if error-status:error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при создании истории изменения внешней подсистемы"
                skip "Внешняя подсистема:"
                skip "  номер   " old-ext-system.esys-id
                skip "  БД номер" old-ext-system.db-num
                skip "  имя     " old-ext-system.esys-name
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box .
            undo main-block, return error.
        end.
    end.
    if ub.ext-system.esys-send-news-exp = yes
    or ub.ext-system.esys-type > integer({&openxml-type-ordinal})
    then do:
        run str/callnews.p (
              input {&table_ext-system}
            , input ( buffer  ub.ext-system :handle )
        ) no-error .
        if error-status:error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при передаче изменения внешней подсистемы в новости"
                skip "Внешняя подсистема:"
                skip "  номер   " ub.ext-system.esys-id
                skip "  БД номер" ub.ext-system.db-num
                skip "  имя     " ub.ext-system.esys-name
            view-as alert-box .
            undo main-block, return error.
        end.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ext-system}
        , input ( buffer ub.ext-system:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
END.