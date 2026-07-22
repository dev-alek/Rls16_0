block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: plgdspmn.p $
$Archive: utl/plgdspmn.p $

Отправка в офис всей таблицы pl-gds-pump.

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

До версии 14_0 таблица pl-gds-pump в офис не отправлялась.
*/
define buffer bf_pl-gds-pump for ub.pl-gds-pump.
do on error undo, return error return-value :
for each bf_pl-gds-pump no-lock on error undo, return error return-value :
  run str/callnews.p
    (input "pl-gds-pump"
    ,input (buffer bf_pl-gds-pump:handle)
    ) .
end.
message "Вся таблица складское-место_товар_ТРК отправлена по новостям." view-as alert-box.
end.