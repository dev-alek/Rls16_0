block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getfosht.p $
$Archive: rep/getfosht.p $

Определение диапазона fact-order для документов одной смены

Автор: Хныкин Павел Андреевич
Дата создания: 10/12/05
Author: Pavel Khnykin
Creation date: 10/12/05

Input:

Output:

*/

define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-shift-date         as date             no-undo.
define input parameter p-shift-num          as integer          no-undo.
define output parameter p-fact-order-from   as decimal          no-undo.
define output parameter p-fact-order-to     as decimal          no-undo.
define output parameter p-docs-exists       as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getfosht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/getfosht.p $":U .
define variable vss-description as character no-undo init "Определение диапазона fact-order по диапазону дат или смен".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

    define variable v-shift-on    as logical      no-undo.

    define buffer buf_stk-tot for ub.stk-tot.
do
for buf_stk-tot
on error undo, return error
:
    { gbl/objat.i
        p-obj-type
        p-obj-code
        "'shift-on=request'"
        v-shift-on
        no-error
    }
    if error-status :error
    then do:
        message
                    vss-workfile vss-revision vss-description
            skip(1)
            skip "Невозможно определить тип сменный/не сменный"
            skip "для заданного объекта."
            skip "Объект:" p-obj-type p-obj-code
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-shift-on = no
    then do:
        message
            "Неверно задан тип объекта" p-obj-type p-obj-code
            skip "Объект не сменный."
        view-as alert-box information.
    end.
    assign
        p-docs-exists = no
    .
    find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type   = p-obj-type
          and buf_stk-tot.obj-code   = p-obj-code
          and buf_stk-tot.shift-date = p-shift-date
          and buf_stk-tot.shift-num  = p-shift-num
    use-index shift-num
    no-error.
    if not available buf_stk-tot
    then do:
        assign
            p-docs-exists = no
        .
    end.        /* if not available buf_stk-tot */
    else do:
        assign
            p-fact-order-to = buf_stk-tot.fact-order
            p-docs-exists   = yes
        .
        find last buf_stk-tot no-lock
            where buf_stk-tot.obj-type   = p-obj-type
              and buf_stk-tot.obj-code   = p-obj-code
              and buf_stk-tot.shift-date = p-shift-date
              and buf_stk-tot.shift-num  < p-shift-num
        use-index shift-num
        no-error.
        if not available buf_stk-tot
        then do:
            find last buf_stk-tot no-lock
                where buf_stk-tot.obj-type   = p-obj-type
                  and buf_stk-tot.obj-code   = p-obj-code
                  and buf_stk-tot.shift-date < p-shift-date
            use-index shift-num
            no-error.
            if not available buf_stk-tot
            then do:
                assign
                    p-docs-exists       = yes
                    p-fact-order-from   = 0
                .
            end.
        end.
        if available buf_stk-tot
        then do:
            if buf_stk-tot.fact-order >= p-fact-order-to
            then do:
                assign
                    p-docs-exists = no
                .
            end.
            else do:
                assign
                    p-docs-exists       = yes
                    p-fact-order-from   = buf_stk-tot.fact-order
                .
            end.
        end.
    end.        /* if available buf_stk-tot */
end.