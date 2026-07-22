block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление строки итогов (весовой учет топлива)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/06/07
Author: Dmitry Ukhanov
Creation date: 09/06/07

Автор1: Булгаков Андрей Николаевич
Дата создания1: 10/04/05

*/

trigger procedure for delete of ub.inv-line.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление строки итогов (весовой учет топлива)":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

Main-Block:
do transaction
on error   undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on end-key undo Main-Block, return error substitute( "&1. stop", vss-workfile )
on stop    undo Main-Block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#oxml = yes
  then do:
    run str/calloxml.p
      ( input {&nwsdochs_action_delete}
       ,input {&table_inv-line}
       ,input ( buffer ub.inv-line:handle )
      ) no-error.
    if error-status :error then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                                      ,{&new-line}
                                      ,vss-workfile
                                      ,return-value
                                      ,error-status :get-message ( 1 )
                                     ).
    end.
  end.
end. /* Main-Block */