block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-alli.p $
$Archive: ref/cli-alli.p $

Открытие запроса в справочнике клиентов

Автор: Чернова Светлана Александровна
Дата создания: 12/08/05
Author: Svetlana Chernova
Creation date: 12/08/05

*/

{ ref/cli-all.i B }

{ gbl/fltopend.i
    &where-cond = " X_clients.obj-type = ~{&shop~} "
    &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1', ~{&double-quote~}, ~{&shop~}) "
    &by         = "    " }
  end. /*doe*/

end procedure. /* proc-main */