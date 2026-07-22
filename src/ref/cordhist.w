/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр истории по Заказу

Автор: Ростовцев Александр
Дата создания: 16/04/2025
Author: Rostovtsev Aleksandr
Creation date: 16/04/2025
Изменен: 06/05/2026 доработана возможность просмотра истории по всем заказам и по 1-му

*/

&glob param_1 p-db-num-order
define input  parameter {&Param_1} as int64 no-undo.
&glob param_2 p-doc-code-order
define input  parameter {&Param_2} as int64 no-undo.
 
define variable orderStatus  as class ibs.th.str.order.sts.order no-undo .
orderStatus =  new ibs.th.str.order.sts.order().
 
{ gbl/objsrv.i }

define variable vLabel as character no-undo.

&glob proc_nextlevel ref/cordhistone.w 
&glob buf_obj-hist c-order-head
&Glob VisibleKeyField yes
{ref/brwhist.i &Paramonly = yes &objhead = yes}
if p-mode <> "one" then
do:
  vLabel = "История по Заказам".
  {ref/brwhist.i 
    &objhead = yes 
    &lable = vLabel
    &browse-fields="X_c-obj-hist.db-num   COLUMN-LABEL 'БД' WIDTH 4
                    X_c-obj-hist.doc-code COLUMN-LABEL 'Код заказа'"
  }
end.
else do:
  run ref/cordhistone.w(
    {&param_1},
    {&param_2},
    parParentProc,
    p-curr-host-code,
    p-curr-obj-type,
    p-curr-obj-code,
    bttns,
    p-mode,
    p-corr-user-db-num,
    p-corr-user-name,
    p-subject,
    p-db-num,
    p-chip-num,
    input-output p-rid-list
  ).
end.

{ ref/cordhist.i}


