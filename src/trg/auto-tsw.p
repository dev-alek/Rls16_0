block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись автоцистерны

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/11/06
Author: Dmitry Ukhanov
Creation date: 04/11/06

*/

trigger procedure for write of ub.auto-section old old-auto-section .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Триггер на запись секции автоцистерны".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date    no-undo .
define variable v-time as integer no-undo .

main-block:
do
    on error undo main-block, return error
    :
    if g#db-num <> 0 then return .  
    run cur-time in this-procedure
        (output v-date
        ,output v-time
        ).

    run str/callnews.p
        (input {&table_auto-section}
        ,input (buffer ub.auto-section:handle)
        ).

    if not g#news
        then
    do:
        if new (ub.auto-section)
            then
        do:
            create ub.c-auto-section .
            assign
                ub.c-auto-section.auto-num         = ub.auto-section.auto-num
                ub.c-auto-section.section-num      = ub.auto-section.section-num
                ub.c-auto-section.action           = integer({&hn-create})
                ub.c-auto-section.is-del           = false
                ub.c-auto-section.chip-num         = next-value (s-ref-corr-chip, {&db-name_schema})
                ub.c-auto-section.corr-date        = v-date
                ub.c-auto-section.corr-time        = v-time
                ub.c-auto-section.corr-user-db-num = g#db-num
                ub.c-auto-section.corr-user-name   = g#userid

                .
        end.
        else
        do:
            create ub.c-auto-section .
            buffer-copy old-auto-section to ub.c-auto-section
            assign
                ub.c-auto-section.auto-num         = ub.auto-section.auto-num
                ub.c-auto-section.section-num      = ub.auto-section.section-num
                ub.c-auto-section.action           = integer({&hn-create})
                ub.c-auto-section.is-del           = false
                ub.c-auto-section.chip-num         = next-value (s-ref-corr-chip, {&db-name_schema})
                ub.c-auto-section.corr-date        = v-date
                ub.c-auto-section.corr-time        = v-time
                ub.c-auto-section.corr-user-db-num = g#db-num
                ub.c-auto-section.corr-user-name   = g#userid
                .
        end.
    end.

end.
