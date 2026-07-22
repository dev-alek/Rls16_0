/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование данных по остаткам для товара на объекте.

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

Данные формируется в виде временной таблицы.
Перед первым вызовом следует обратиться как def

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" = "def" &then
  define temp-table tt-stk-line{2} no-undo like ub.stk-line.
&else
procedure stk-lnst:
define input  parameter parobj-type   like ub.clients.obj-type    no-undo.
define input  parameter parobj-code   like ub.clients.obj-code    no-undo.
define input  parameter parartic      like ub.goods.artic         no-undo.
define input  parameter parprod-type  like ub.goods.prod-type     no-undo.
define input  parameter parprod-code  like ub.goods.prod-code     no-undo.
define input  parameter parfact-order like ub.stk-line.fact-order no-undo.
define input  parameter parsum-type   like ub.stk-line.sum-type   no-undo.
define input  parameter parcat-id     like ub.stk-line.cat-id     no-undo.
define input  parameter paris-shift   as   logical             no-undo.
define output parameter table for tt-stk-line{2}.
if paris-shift then do:
  find last ub.stk-line where ub.stk-line.obj-type    = parobj-type   and
                           ub.stk-line.obj-code    = parobj-code   and
                           ub.stk-line.artic       = parartic      and
                           ub.stk-line.prod-type   = parprod-type  and
                           ub.stk-line.prod-code   = parprod-code  and
                           ub.stk-line.fact-order <= parfact-order and
                           ub.stk-line.sum-type    = parsum-type   and
                           ub.stk-line.cat-id      = parcat-id     and
                           ub.stk-line.shift-date <> ?             use-index category no-lock no-error.
end.
else do:
  find last ub.stk-line where ub.stk-line.obj-type    = parobj-type   and
                           ub.stk-line.obj-code    = parobj-code   and
                           ub.stk-line.artic       = parartic      and
                           ub.stk-line.prod-type   = parprod-type  and
                           ub.stk-line.prod-code   = parprod-code  and
                           ub.stk-line.fact-order <= parfact-order and
                           ub.stk-line.sum-type    = parsum-type   and
                           ub.stk-line.cat-id      = parcat-id     and
                           ub.stk-line.shift-date  = ?             use-index category no-lock no-error.
end.
if available ub.stk-line then do:
   create tt-stk-line{2}.
   buffer-copy ub.stk-line to tt-stk-line{2}.
end.
end procedure.
&endif
/* $Workfile$ e n d */