block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: oxmlexts.p $
$Archive: bge/oxmlexts.p $

openXML. Выбор внешней системы

Автор: Хныкин Павел Андреевич
Дата создания: 09/05/07
Author: Pavel Khnykin
Creation date: 09/05/07

Input:

p-mode          - режим выбора:
                    1 - Множественный выбор,
                    2 - выбрать одну систему из списка
p-where-string  - дополнительное условие для выбора строк (в виде "поле = значение, поле > значение, ...")
                    Например, "esys-type = 1"

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-mode               as integer          no-undo.
define input parameter p-where-string       as character        no-undo.
define input parameter p-in-selected-list   as character        no-undo.
define output parameter p-out-selected-list as character        no-undo.
define output parameter p-accepted          as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlexts.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlexts.p $":U .
define variable vss-description as character no-undo init "openXML. Выбор внешней системы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/onewin.i   }
{ gbl/key-rec.i  }

    define variable v-esys-unique-key   as character    no-undo.
    define variable v-where-prefix      as character    no-undo.
    define variable bh                  as handle       no-undo .
    define variable qh                  as handle       no-undo .
    define variable v-query             as character    no-undo.
    define variable v-counter           as integer      no-undo.

    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:

    create buffer bh for table "ext-system":U buffer-name "buf_ext-system":U .
    create query qh .
    qh :set-buffers( bh ).
    assign
        v-query  = "for each buf_ext-system no-lock"
    .
    if p-where-string <> "":U
    then do:
        do v-counter = 1 to num-entries( p-where-string )
        :
            assign
                v-where-prefix = ( if v-counter = 1 then " where " else " and " )
            .
            assign
                v-query  = substitute( "&1&2&3", v-query, v-where-prefix, entry( v-counter, p-where-string ) )
            .
        end.
    end.
    qh :query-prepare( v-query ).
    qh :query-open.
    qh :get-first.
    run onewin_clear in this-procedure.
    do
    while qh :query-off-end = no
    :
        run gen-key-rec in this-procedure (
              input "ext-system":U
            , input bh
            , output v-esys-unique-key
        ).
        run onewin_add-item in this-procedure (
              input v-esys-unique-key
            , input bh :buffer-field( "esys-name" ) :buffer-value
            , input bh :buffer-field( "esys-des" ) :buffer-value
            , input ( lookup( v-esys-unique-key, p-in-selected-list ) > 0 )
        ).
        qh :get-next.
    end.
    delete object bh.
    delete object qh.
    run gbl/onewin.w (
          input p-mainmenu-handle
        , input p-mode
        , input "Выбор внешних систем":U
        , input "bge/oxmlextv.p":U
        , input "&Просмотр"
        , input table temp_onewin_items
        , output table temp_onewin_itemsSelected
        , output v-esys-unique-key
        , output p-accepted
    ).
    if p-accepted = yes
    then do:
        if p-mode = 2
        then do:
            assign
                p-out-selected-list = v-esys-unique-key
            .
        end.
        else do:
            assign
                p-out-selected-list = "":U
            .
            for each temp_onewin_itemsSelected
            :
                assign
                    p-out-selected-list = substitute( "&1&2&3"
                                    , p-out-selected-list
                                    , ( if p-out-selected-list = "":U then "":U else ",":U )
                                    , temp_onewin_itemsSelected.itmExtKey
                                    )
                .
            end.
        end.
    end.
end.