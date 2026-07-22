/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Верификация на удаление и удаление записи резервуар-ТРК

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08


*/
procedure plpumpdv:
define input parameter parobj-type    like ub.clients.obj-type   no-undo.
define input parameter parobj-code    like ub.clients.obj-code   no-undo.
define input parameter parpl-code     like ub.place.pl-code      no-undo.
define input parameter parpump-code   like ub.pump.pump-code     no-undo.
define buffer bf_clients           for ub.clients.
define buffer bf_pl-pump           for ub.pl-pump.
define buffer bf_pl-pump-nozzle    for ub.pl-pump-nozzle.
define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
define variable varrec-id as recid no-undo.

{ str/ptrlv.i "def"}
{ str/ptrlv.i "ov+"}
tr:
do transaction on error undo tr, return error return-value :
  /*Проверим то, что вообще-то есть чего удалить*/
  find first bf_pl-pump where bf_pl-pump.obj-type  = parobj-type    and
                              bf_pl-pump.obj-code  = parobj-code    and
                              bf_pl-pump.pl-code   = parpl-code     and
                              bf_pl-pump.pump-code = parpump-code
                              no-lock no-error.
  if not available bf_pl-pump then do:
     return error substitute("Не найден запись резервуар-ТРК с номером резервуара &1 и номером ТРК &2", parpl-code, parpump-code) {&str-obj}.
  end.
  assign varrec-id = RECID(bf_pl-pump).
  { str/ptrlv.i "sch-cls"}

  /*Удаляем все дочерние, связанные таблицы*/
  for each bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type    = parobj-type  and
                                   bf_pl-pump-nozzle.obj-code    = parobj-code  and
                                   bf_pl-pump-nozzle.pl-code     = parpl-code   and
                                   bf_pl-pump-nozzle.pump-code   = parpump-code exclusive-lock
                                   on error undo tr, return error return-value :
      delete bf_pl-pump-nozzle.
  end.
  for each bf_pl-gds-pump where bf_pl-gds-pump.obj-type  = parobj-type  and
                                bf_pl-gds-pump.obj-code  = parobj-code  and
                                bf_pl-gds-pump.pl-code   = parpl-code   and
                                bf_pl-gds-pump.pump-code = parpump-code exclusive-lock
                                on error undo tr, return error return-value :
    delete bf_pl-gds-pump.
  end.
  /*Ну а теперь себя*/
  find first bf_pl-pump where RECID(bf_pl-pump) = varrec-id exclusive-lock.
  delete bf_pl-pump.
end. /*transaction*/
end procedure.
/* $Workfile$ e n d */