/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для формы выбора параметров

Автор: Белоусов Илья Александрович
Дата создания: 10/17/06
Author: Ilia Belousov
Creation date: 10/17/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


define temp-table temp_twowin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical

    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_twowin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character

    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-twowin{&vssseq}-itm-key    as integer      no-undo.

/*==========================================================================*/
procedure twowin_clear :

    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    empty temp-table buf_temp_twowin_items.
end.
end procedure. /* twowin_clear */

/*==========================================================================*/
procedure twowin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.

    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    assign
        v-twowin{&vssseq}-itm-key = v-twowin{&vssseq}-itm-key + 1
    .
    create temp_twowin_items.
    assign
        temp_twowin_items.itm-key      = v-twowin{&vssseq}-itm-key
        temp_twowin_items.itmExtKey    = p-ext-key
        temp_twowin_items.itmName      = p-item-name
        temp_twowin_items.itmDesc      = p-item-desc
        temp_twowin_items.itmSelected  = p-selected
        temp_twowin_items.selLeft      = no
        temp_twowin_items.selRight     = no
    .
end.
end procedure. /* twowin_add-item */

/* $Workfile$ e n d */