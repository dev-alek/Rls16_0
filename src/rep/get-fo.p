block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-fo.p $
$Archive: rep/get-fo.p $

Определение диапазона fact-order по диапазону дат

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

define input  parameter p-obj-type          like ub.clients.obj-type   no-undo.
define input  parameter p-obj-code          like ub.clients.obj-code   no-undo.
define input  parameter p-date-from         as date                 no-undo.
define input  parameter p-date-to           as date                 no-undo.
define output parameter p-fact-order-from   like ub.stk-tot.fact-order no-undo.
define output parameter p-fact-order-to     like ub.stk-tot.fact-order no-undo.
define output parameter p-docs-exists       as logical              no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: get-fo.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/get-fo.p $":U .
def var vss-description as character no-undo init "Определение диапазона fact-order по диапазону дат".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ trg/factord.i }

define buffer buf_stk-tot for ub.stk-tot.

do
on error undo, return error
:

    assign
        p-docs-exists = no
    .
    find last buf_stk-tot no-lock
       where buf_stk-tot.obj-type   = p-obj-type
         and buf_stk-tot.obj-code   = p-obj-code
         and buf_stk-tot.fact-date  < p-date-to + 1
    use-index fact-date
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
            p-docs-exists = yes
        .
        find last buf_stk-tot no-lock
            where buf_stk-tot.obj-type   = p-obj-type
              and buf_stk-tot.obj-code   = p-obj-code
              and buf_stk-tot.fact-date  < p-date-from
        use-index fact-date
        no-error.
        if not available buf_stk-tot
        then do:
            assign
                p-docs-exists = yes
            .
            run day-begin-fact-order ( input ?, output p-fact-order-from).
        end.
        else do:
            if buf_stk-tot.fact-order >= p-fact-order-to
            then do:
                assign
                    p-docs-exists = no.
                .
            end.
            else do:
                assign
                    p-docs-exists       = yes
                    p-fact-order-from   = buf_stk-tot.fact-order
                .
            end.
        end.        /* if available buf_stk-tot */
    end.        /* if available buf_stk-tot */
end.