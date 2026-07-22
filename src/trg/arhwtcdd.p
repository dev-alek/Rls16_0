block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на Удаление баланса покупатель-номинал в разрезе состовляющих

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/07/07
Author: Polina Gridchina
Creation date: 05/07/07

Input:

Output:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.arh-wth-cli-doc.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на Удаление баланса покупатель-номинал в разрезе состовляющих".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
/*  if not g#news
   then do:
    run nws/cmd-del.p
      ( input "arh-wth-cli-doc":U
       ,input (buffer ub.arh-wth-cli-doc:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.  */

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_arh-wth-cli-doc}
        , input ( buffer ub.arh-wth-cli-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.

end.