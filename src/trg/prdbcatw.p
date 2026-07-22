block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись атрибута ДопБК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/14/07
Author: Bakhtadze Natalya
Creation date: 03/14/07

*/

TRIGGER PROCEDURE FOR write OF ub.prod-bc-attr .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись атрибута ДопБК".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u~
                              ,ub.prod-bc-attr.b-code~
                              ,ub.prod-bc-attr.b-str~
                              ,ub.prod-bc-attr.attr-code~
                              )" }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    if not g#news then do :
       run str/callnews.p
              (input {&table_prod-bc-attr}
              ,input (buffer ub.prod-bc-attr:handle)
      ) no-error.
      if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать prod-bc-attr для отправки в новости" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo , return error return-value .
    end.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_prod-bc-attr}
        , input ( buffer ub.prod-bc-attr:handle )
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