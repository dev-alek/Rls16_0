/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение диапазонов факт-ордеров смен для диапазонов дат и номеров смен

Автор: Белоусов Илья Александрович
Дата создания: 09/28/07
Author: Ilia Belousov
Creation date: 09/28/07

Required:

Требует заполнения temp_shiftfo_obj-list - списка объектов, по которым строятся диапазоны.

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define temp-table temp_shiftfo_fo-range no-undo
    field frn-key           as integer
    field obj-type          as character
    field obj-code          as integer
    field fact-order-from   as decimal
    field fact-order-to     as decimal
    field date-from         as date
    field date-to           as date
    field shift-from        as integer
    field shift-to          as integer

    index pi is primary unique
        frn-key
.
define temp-table temp_shiftfo_obj-list no-undo
    field obj-type  as character
    field obj-code  as integer

    index pi is primary unique
        obj-type
        obj-code
.
define variable v-shiftfo{&vssseq}-frn-key     as integer      no-undo.

/*==========================================================================*/
procedure fill-temp_shiftfo_fo-range :
define input parameter p-mode               as integer          no-undo.
define input parameter p-date-beg           as date             no-undo.
define input parameter p-date-end           as date             no-undo.
define input parameter p-shift-num-beg      as integer          no-undo.
define input parameter p-shift-num-end      as integer          no-undo.
define input parameter p-shift-num-alone    as integer          no-undo.
define output parameter p-date-string       as character        no-undo.
define output parameter p-date-from-string  as character        no-undo.
define output parameter p-date-to-string    as character        no-undo.

    define variable v-fact-order-beg    as decimal      no-undo.
    define variable v-fact-order-end    as decimal      no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-from        as integer      no-undo.
    define variable v-shift-to          as integer      no-undo.
    define variable v-docs-exists       as logical      no-undo.
    define variable v-max-fact-order    as decimal      no-undo.
    define variable v-shift-obj-on      as logical      no-undo.

    define buffer buf_temp_shiftfo_fo-range     for temp_shiftfo_fo-range.
    define buffer buf_obj-list                  for temp_shiftfo_obj-list.
    define buffer buf_shift-obj                 for ub.shift-obj.
    define buffer buf_prev_shift-obj            for ub.shift-obj.
do
for buf_temp_shiftfo_fo-range
  , buf_obj-list
  , buf_shift-obj
  , buf_prev_shift-obj
on error undo, return error
:
    empty temp-table buf_temp_shiftfo_fo-range.
    assign
        v-shiftfo{&vssseq}-frn-key = 0
    .
    case p-mode
    :
        when 1
        then do:        /* Интервал дат */
            run day-begin-fact-order in this-procedure (
                  input p-date-beg
                , output v-fact-order-beg
            ).
            run factord-end-day in this-procedure (
                  input p-date-end
                , output v-fact-order-end
            ).
            for each buf_obj-list
            :
/*                { gbl/objat.i*/
/*                    buf_obj-list.obj-type*/
/*                    buf_obj-list.obj-code*/
/*                    "'shift-on=request'"*/
/*                    v-shift-obj-on*/
/*                    no-error*/
/*                }*/
/*                if v-shift-obj-on = yes*/
/*                then do:*/
                    assign
                        v-shiftfo{&vssseq}-frn-key = v-shiftfo{&vssseq}-frn-key + 1
                    .
                    create buf_temp_shiftfo_fo-range.
                    assign
                        buf_temp_shiftfo_fo-range.frn-key           = v-shiftfo{&vssseq}-frn-key
                        buf_temp_shiftfo_fo-range.obj-type          = buf_obj-list.obj-type
                        buf_temp_shiftfo_fo-range.obj-code          = buf_obj-list.obj-code
                        buf_temp_shiftfo_fo-range.fact-order-from   = v-fact-order-beg
                        buf_temp_shiftfo_fo-range.fact-order-to     = v-fact-order-end
                        buf_temp_shiftfo_fo-range.date-from         = p-date-beg
                        buf_temp_shiftfo_fo-range.date-to           = p-date-end
                        buf_temp_shiftfo_fo-range.shift-from        = 0
                        buf_temp_shiftfo_fo-range.shift-to          = 0
                    .
                    assign
                        p-date-string       = substitute( "Диапазон дат: с &1 по &2", p-date-beg, p-date-end )
                        p-date-from-string  = substitute( "&1", p-date-beg )
                        p-date-to-string    = substitute( "&1", p-date-end   )
                    .
/*                end.        /* if v-shift-obj-on = yes */*/
/*                else do:*/

/*                end.*/
            end.
        end.        /* when 1 */
        when 2
        then do:        /* Сменные сутки. То есть, интервал смен, начало которых попадает в заданный интервал дат */
            define variable v-is-first    as logical      no-undo.
            for each buf_obj-list
            :
                { gbl/objat.i
                    buf_obj-list.obj-type
                    buf_obj-list.obj-code
                    "'shift-on=request'"
                    v-shift-obj-on
                    no-error
                }
                if v-shift-obj-on = yes
                then do:
                    assign
                        v-is-first          = yes
                        v-fact-order-beg    = 0
                        v-fact-order-end    = 0
                        v-shift-from        = 0
                        v-shift-to          = 0
                        v-date-from         = ?
                        v-date-to           = ?
                    .
                    for each buf_shift-obj no-lock
                    where buf_shift-obj.obj-type = buf_obj-list.obj-type
                        and buf_shift-obj.obj-code = buf_obj-list.obj-code
                        and buf_shift-obj.status_  = {&sht-closed}
                        and buf_shift-obj.shift-date >= p-date-beg
                        and buf_shift-obj.shift-date <= p-date-end
                    by buf_shift-obj.shift-date
                    by buf_shift-obj.shift-num
                    on error undo, return error
                    :
                        if v-is-first = yes
                        then do:
                            find last buf_prev_shift-obj
                                where buf_prev_shift-obj.obj-type = buf_obj-list.obj-type
                                and buf_prev_shift-obj.obj-code = buf_obj-list.obj-code
                                and buf_prev_shift-obj.fact-order < buf_shift-obj.fact-order
                            no-error.
                            if available buf_prev_shift-obj
                            then do:
                                assign
                                    v-fact-order-beg   = buf_prev_shift-obj.fact-order
                                    v-date-from        = buf_shift-obj.shift-date
                                    v-shift-from       = buf_shift-obj.shift-num
                                .
                            end.
                            assign
                                v-is-first          = no
                            .
                        end.
                        assign
                            v-fact-order-end = buf_shift-obj.fact-order
                            v-date-to        = buf_shift-obj.shift-date
                            v-shift-to       = buf_shift-obj.shift-num
                        .
                    end.        /* for each buf_shift-obj */
                    if v-fact-order-end <> 0
                    and v-fact-order-end >= v-fact-order-beg
                    then do:
                        assign
                            v-shiftfo{&vssseq}-frn-key = v-shiftfo{&vssseq}-frn-key + 1
                        .
                        create buf_temp_shiftfo_fo-range.
                        assign
                            buf_temp_shiftfo_fo-range.frn-key           = v-shiftfo{&vssseq}-frn-key
                            buf_temp_shiftfo_fo-range.obj-type          = buf_obj-list.obj-type
                            buf_temp_shiftfo_fo-range.obj-code          = buf_obj-list.obj-code
                            buf_temp_shiftfo_fo-range.fact-order-from   = v-fact-order-beg
                            buf_temp_shiftfo_fo-range.fact-order-to     = v-fact-order-end
                            buf_temp_shiftfo_fo-range.date-from         = p-date-beg
                            buf_temp_shiftfo_fo-range.date-to           = p-date-end
                            buf_temp_shiftfo_fo-range.shift-from        = 0
                            buf_temp_shiftfo_fo-range.shift-to          = 0
                        .
                    end.
                end.        /* if v-shift-obj-on = yes */
            end.
            assign
                p-date-string = substitute( "Сменные сутки: с &1 по &2", p-date-beg, p-date-end )
                p-date-from-string  = substitute( "&1 (сменные сутки)", p-date-beg )
                p-date-to-string    = substitute( "&1 (сменные сутки)", p-date-end   )
            .
        end.        /* when 2 */
        when 3
        then do:        /* Сменные сутки и порядок. То есть, кроме дат указаны номера смен с...по... */
            for each buf_obj-list
            :
                { gbl/objat.i
                    buf_obj-list.obj-type
                    buf_obj-list.obj-code
                    "'shift-on=request'"
                    v-shift-obj-on
                    no-error
                }
                if v-shift-obj-on = yes
                then do:
                    assign
                        v-fact-order-beg    = 0
                        v-shift-from        = 0
                        v-date-from         = ?
                        v-fact-order-end    = 0
                        v-shift-to          = 0
                        v-date-to           = ?
                    .
                    find first buf_shift-obj no-lock
                        where buf_shift-obj.obj-type = buf_obj-list.obj-type
                        and buf_shift-obj.obj-code = buf_obj-list.obj-code
                        and buf_shift-obj.status_  = {&sht-closed}
                        and buf_shift-obj.shift-date = p-date-beg
                        and buf_shift-obj.shift-num >= p-shift-num-beg
                    use-index stts
                    no-error.
                    if not available buf_shift-obj
                    then do:
                        find first buf_shift-obj no-lock
                            where buf_shift-obj.obj-type = buf_obj-list.obj-type
                            and buf_shift-obj.obj-code = buf_obj-list.obj-code
                            and buf_shift-obj.status_  = {&sht-closed}
                            and buf_shift-obj.shift-date > p-date-beg
                        use-index stts
                        no-error.
                    end.
                    if not available buf_shift-obj
                    then do:        /* Нет смен в заданном интервале */
                        assign
                            v-fact-order-beg    = 0
                            v-date-from         = {&beg-unlim-lcns}
                            v-shift-from        = {&min-shift-num}
                        .
                    end.
                    else do:
                        assign
                            v-fact-order-beg    = buf_shift-obj.fact-order
                            v-date-from         = buf_shift-obj.shift-date
                            v-shift-from        = buf_shift-obj.shift-num
                        .
                        find first buf_shift-obj no-lock
                            where buf_shift-obj.obj-type = buf_obj-list.obj-type
                            and buf_shift-obj.obj-code = buf_obj-list.obj-code
                            and buf_shift-obj.status_  = {&sht-closed}
                            and buf_shift-obj.shift-date = p-date-end
                            and buf_shift-obj.shift-num  > p-shift-num-end
                        use-index stts
                        no-error.
                        if not available buf_shift-obj
                        then do:
                            find first buf_shift-obj no-lock
                                where buf_shift-obj.obj-type = buf_obj-list.obj-type
                                and buf_shift-obj.obj-code = buf_obj-list.obj-code
                                and buf_shift-obj.status_  = {&sht-closed}
                                and buf_shift-obj.shift-date > p-date-end
                            use-index stts
                            no-error.
                        end.
                        if not available buf_shift-obj
                        then do:
                            assign
                                v-max-fact-order = integer( {&end-unlim-lcns} ) * 10.0
                            .
                            assign
                                v-fact-order-end    = v-max-fact-order
                                v-date-to           = {&end-unlim-lcns}
                                v-shift-to          = {&max-shift-num}
                            .
                        end.
                        else do:
                            assign
                                v-fact-order-end    = buf_shift-obj.fact-order
                                v-date-to           = buf_shift-obj.shift-date
                                v-shift-to          = buf_shift-obj.shift-num
                            .
                        end.
                        assign
                            v-shiftfo{&vssseq}-frn-key = v-shiftfo{&vssseq}-frn-key + 1
                        .
                        create buf_temp_shiftfo_fo-range.
                        assign
                            buf_temp_shiftfo_fo-range.frn-key           = v-shiftfo{&vssseq}-frn-key
                            buf_temp_shiftfo_fo-range.obj-type          = buf_obj-list.obj-type
                            buf_temp_shiftfo_fo-range.obj-code          = buf_obj-list.obj-code
                            buf_temp_shiftfo_fo-range.fact-order-from   = v-fact-order-beg
                            buf_temp_shiftfo_fo-range.fact-order-to     = v-fact-order-end
                            buf_temp_shiftfo_fo-range.date-from         = v-date-from
                            buf_temp_shiftfo_fo-range.date-to           = v-date-to
                            buf_temp_shiftfo_fo-range.shift-from        = v-shift-from
                            buf_temp_shiftfo_fo-range.shift-to          = v-shift-to
                        .
                    end.
                end.        /* if v-shift-obj-on = yes */
            end.
            assign
                p-date-string = substitute( "Сменные сутки и порядок: со смены &1 (&2) по смену &3 (&4)"
                    , p-shift-num-beg
                    , p-date-beg
                    , p-shift-num-end
                    , p-date-end )
                p-date-from-string  = substitute( "смена &1 (&2, сменные сутки и порядок)", p-shift-num-beg, p-date-beg )
                p-date-to-string    = substitute( "смена &1 (&2, сменные сутки и порядок)", p-shift-num-end  , p-date-end   )
            .
        end.        /* when 3 */
        when 4
        then do:        /* По сменам. Указана смена. В этом интервале дат надо собрать данные только этому номеру смены. */
            for each buf_obj-list
            :
                { gbl/objat.i
                    buf_obj-list.obj-type
                    buf_obj-list.obj-code
                    "'shift-on=request'"
                    v-shift-obj-on
                    no-error
                }
                if v-shift-obj-on = yes
                then do:
                    for each buf_shift-obj no-lock
                    where buf_shift-obj.obj-type     = buf_obj-list.obj-type
                        and buf_shift-obj.obj-code     = buf_obj-list.obj-code
                        and buf_shift-obj.status_      = {&sht-closed}
                        and buf_shift-obj.shift-date   >= p-date-beg
                        and buf_shift-obj.shift-date   <= p-date-end
                    use-index stts
                    on error undo, return error
                    :
                        if buf_shift-obj.shift-num = p-shift-num-alone
                        then do:
                            run rep/getfosht.p (
                                input buf_obj-list.obj-type
                                , input buf_obj-list.obj-code
                                , input buf_shift-obj.shift-date
                                , input buf_shift-obj.shift-num
                                , output v-fact-order-beg
                                , output v-fact-order-end
                                , output v-docs-exists
                            ).
                            assign
                                v-shiftfo{&vssseq}-frn-key = v-shiftfo{&vssseq}-frn-key + 1
                            .
                            create buf_temp_shiftfo_fo-range.
                            assign
                                buf_temp_shiftfo_fo-range.frn-key           = v-shiftfo{&vssseq}-frn-key
                                buf_temp_shiftfo_fo-range.obj-type          = buf_obj-list.obj-type
                                buf_temp_shiftfo_fo-range.obj-code          = buf_obj-list.obj-code
                                buf_temp_shiftfo_fo-range.fact-order-from   = v-fact-order-beg
                                buf_temp_shiftfo_fo-range.fact-order-to     = v-fact-order-end
                                buf_temp_shiftfo_fo-range.date-from         = buf_shift-obj.shift-date
                                buf_temp_shiftfo_fo-range.date-to           = buf_shift-obj.shift-date
                                buf_temp_shiftfo_fo-range.shift-from        = buf_shift-obj.shift-num
                                buf_temp_shiftfo_fo-range.shift-to          = buf_shift-obj.shift-num
                            .
                        end.

                    end.        /* for each buf_shift-obj */
                end.        /* if v-shift-obj-on = yes */
            end.
            assign
                p-date-string = substitute( "По смене: смена &1, с &2 по &3"
                                        , p-shift-num-alone
                                        , p-date-beg
                                        , p-date-end )
                p-date-from-string  = substitute( "смена &1 (&2, по смене)", p-shift-num-alone, p-date-beg )
                p-date-to-string    = substitute( "смена &1 (&2, по смене)", p-shift-num-alone, p-date-end   )
            .
        end.        /* when 4 */
    end case.       /* case p-mode */
end.
end procedure. /* fill-temp_shiftfo_fo-range */


/* $Workfile$ e n d */