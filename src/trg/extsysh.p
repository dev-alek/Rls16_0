block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись истории внешней подсистемы.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

*/

define parameter buffer buf_old_ext-system  for ub.ext-system.
define output parameter p-chip-num          as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись истории внешней подсистемы.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.

    define buffer buf_c-ext-system        for ub.c-ext-system.
do
for buf_c-ext-system
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    create buf_c-ext-system.
    buffer-copy buf_old_ext-system to buf_c-ext-system.
    assign
        p-chip-num                     = next-value( s-ref-corr-chip, {&db-name_schema})
    .
    assign
        buf_c-ext-system.corr-user-db-num = g#db-num
        buf_c-ext-system.corr-user-name   = g#userid
        buf_c-ext-system.chip-num         = p-chip-num
        buf_c-ext-system.corr-date        = v-today
        buf_c-ext-system.corr-time        = v-time
    .
end.