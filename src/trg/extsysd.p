block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Open XML. Триггер на удаление записи внешней подсистемы

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

*/

trigger procedure for delete of ub.ext-system .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Open XML. Триггер на удаление записи внешней подсистемы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

    define variable v-chip-num    as integer      no-undo.
    define buffer buf_ext-system-attr for ub.ext-system-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /* Удалить всё, что связано с внешней подсистемой */
  for each buf_ext-system-attr where
          buf_ext-system-attr.esys-id = ub.ext-system.esys-id
      and buf_ext-system-attr.db-num = ub.ext-system.db-num
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    delete buf_Ext-system-attr.
  end.
  run trg/extsysh.p (
        buffer ub.ext-system
      , output v-chip-num
  ) no-error .
  if error-status:error
  then do:
      message
          vss-workfile vss-revision vss-description
          skip "Ошибка при создании истории изменения внешней подсистемы"
          skip "Внешняя подсистема:"
          skip "  номер   " ub.ext-system.esys-id
          skip "  БД номер" ub.ext-system.db-num
          skip "  имя     " ub.ext-system.esys-name
          skip return-value
          skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
      view-as alert-box .
      undo main-block, return error.
  end.
  if ub.ext-system.esys-send-news-exp = yes
  then do:
      run nws/cmd-del.p (
            input {&table_ext-system}
          , input ( buffer ub.ext-system :handle )
          , input "":U
      ) no-error .
      if error-status :error
      then do:
          undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
      end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_ext-system}
        , input ( buffer ub.ext-system:handle )
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