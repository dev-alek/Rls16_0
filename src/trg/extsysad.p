block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление атрибутов внешней системы

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/18/05
Author: Dmitry Ukhanov
Creation date: 11/18/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.ext-system-attr .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление атрибутов внешней системы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/esysattr.i }

define variable v-news as logical   no-undo .

main-block:
do
on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey")
on stop   undo main-block, return error substitute("&1. stop")
:


  run ext-system-attr-news in this-procedure ( input ub.Ext-system-attr.esya-attr-code
                                              ,output v-news).

  if v-news then do:

    run nws/cmd-del.p
    ( input {&table_ext-system-attr}
     ,input (buffer ub.ext-system-attr:handle)
     ,input ''
    ) no-error .

    if error-status:error then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры cmd-del.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo main-block,  return error return-value .
    end.
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_ext-system-attr}
        , input ( buffer ub.ext-system-attr:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.