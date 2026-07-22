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


define temp-table temp_actntw_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmType       as character
    field itmName       as character
    field itmDesc       as character

    field itmGdsList    as character /* список gds-code */
    field itmGds        as logical   /* разрешено прикрепление товаров или нет */
    field itmGrpList    as character /* список gds-grp-code */
    field itmGrp        as logical   /* разрешено прикрепление групп товаров или нет */

    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical

    index pi is primary unique
        itm-key
    index ie
        itmExtKey
    index tp
        itmType
        itmName
    index sel
        itmSelected
.
define temp-table temp_actntw_itemsSelected no-undo
    field its-key       as integer
    field itm-key       as integer
    field itmExtKey     as character

    field itmGdsList    as character /* список gds-code */
    field itmGds        as logical   /* разрешено прикрепление товаров или нет */
    field itmGrpList    as character /* список gds-grp-code */
    field itmGrp        as logical   /* разрешено прикрепление групп товаров или нет */

    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-actntw{&vssseq}-itm-key    as integer      no-undo.

/*==========================================================================*/
procedure actntw_clear :

    define buffer buf_temp_actntw_items        for temp_actntw_items.
do
for buf_temp_actntw_items
on error undo, return error
:
    empty temp-table buf_temp_actntw_items.
end.
end procedure. /* actntw_clear */

/*==========================================================================*/
procedure actntw_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-type as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
define input parameter p-gds       as logical          no-undo.
define input parameter p-grp       as logical          no-undo.
define input parameter p-list      as character        no-undo.

    define buffer buf_temp_actntw_items        for temp_actntw_items.
do
for buf_temp_actntw_items
on error undo, return error
:
    assign
        v-actntw{&vssseq}-itm-key = v-actntw{&vssseq}-itm-key + 1
    .
    create temp_actntw_items.
    assign
        temp_actntw_items.itm-key      = v-actntw{&vssseq}-itm-key
        temp_actntw_items.itmExtKey    = p-ext-key
        temp_actntw_items.itmType      = p-item-type
        temp_actntw_items.itmName      = p-item-name
        temp_actntw_items.itmDesc      = p-item-desc
        temp_actntw_items.itmSelected  = p-selected
        temp_actntw_items.selLeft      = no
        temp_actntw_items.selRight     = no
        temp_actntw_items.itmGds       = p-gds
        temp_actntw_items.itmGrp       = p-grp
        temp_actntw_items.itmGdsList   = IF p-gds THEN p-list ELSE "":U
        temp_actntw_items.itmGrpList   = IF p-grp THEN p-list ELSE "":U
    .
end.
end procedure. /* actntw_add-item */

/* $Workfile$ e n d */