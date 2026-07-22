block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-allr.p $
$Archive: ref/cli-allr.p $

Открытие запроса в справочнике клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/02/07
Author: Bakhtadze Natalya
Creation date: 02/02/07

*/

&if "{&db-name_schema}" = "ub" &then
&glob contains-oper contains
&else
&glob contains-oper  begins
&endif



{ ref/cli-all.i B }

{ gbl/fltopend.i
    &where-cond = " X_clients.obj-type = ~{&shop~} ~
                    and X_clients.db-num = g#db-num ~
                    and X_clients.obj-name {&contains-oper} NameOrCode "
    &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1 ~
                    and X_clients.db-num = &3 ~
                    and X_clients.obj-name {&contains-oper} &1&4&1 ', ~{&double-quote~}, ~{&shop~}, g#db-num, NameOrCode)"

    &by         = "    " }
  end. /*doe*/

end procedure. /* proc-main */