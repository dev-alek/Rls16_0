block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: oxmlextv.p $
$Archive: bge/oxmlextv.p $

openXML. Выбор внешней системы

Автор: Хныкин Павел Андреевич
Дата создания: 09/05/07
Author: Pavel Khnykin
Creation date: 09/05/07

Input:

p-mode - режим выбора: 0 - Множественный выбор, 1 - выбрать одну систему из списка

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-unique-key         as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlextv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlextv.p $":U .
define variable vss-description as character no-undo init "openXML. Выбор внешней системы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i  }

    define variable v-esys-unique-key   as character    no-undo.
    define variable v-field-list        as character    no-undo.
    define variable v-value-list        as character    no-undo.
    define variable v-have-rights       as logical      no-undo.
    define variable v-current-db-num    as integer      no-undo.
    define variable v-success           as logical      no-undo.
    define variable v-esys-id           as integer      no-undo.
    define variable v-db-num            as integer      no-undo.

    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    { gbl/getcntxt.i get " " p-mainmenu-handle }
    { gbl/curdbnum.i
        v-current-db-num
    }
    run gen-key-fv in this-procedure (
          input p-unique-key
        , output v-field-list
        , output v-value-list
    ).
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_openxml-subsystem_lookup':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        yes
        v-have-rights
    }
    assign
        v-esys-id = integer( entry( 1, v-value-list, {&delim-key} ) )
        v-db-num  = integer( entry( 2, v-value-list, {&delim-key} ) )
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка преобразования первичного ключа, полученного при выборе"
            skip "Первичный ключ (поля):" v-field-list
            skip "Первичный ключ (значения):" v-value-list
        view-as alert-box error.
        undo, return error.
    end.
    find first buf_ext-system no-lock
         where buf_ext-system.esys-id = v-esys-id
           and buf_ext-system.db-num  = v-db-num
    no-error.
    if v-have-rights = yes
    and available buf_ext-system
    then do:
        run bge/oxmlextd.w (
              input p-mainmenu-handle
            , input this-procedure
            , input {&lookup}
            , input v-esys-id /* esys-id */
            , input v-db-num  /* db-num */
            , input v-current-db-num
            , output v-success
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка просмотра записи внешней подсистемы."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.        /* if available buf_init_ext-system */

end.