block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-allp.p $
$Archive: ref/cli-allp.p $

Открытие запроса в справочнике клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/02/07
Author: Bakhtadze Natalya
Creation date: 02/02/07

*/

{ ref/cli-all.i B }

{ gbl/fltopend.i
    &where-cond = " X_clients.obj-type = ~{&shop~} and X_clients.db-num = g#db-num "
    &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1 and X_clients.db-num = &3 ', ~{&double-quote~}, ~{&shop~}, g#db-num)"
    &by         = "    " }
  end. /*doe*/

end procedure. /* proc-main */