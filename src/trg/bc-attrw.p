block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись атрибута бар-кода

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/14/07
Author: Bakhtadze Natalya
Creation date: 03/14/07

*/

TRIGGER PROCEDURE FOR write OF ub.bar-code-attr .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись атрибута бар-кода".
{ cmp/vssrevis.i "substitute('&1|&2':u~
                              ,ub.bar-code-attr.b-code~
                              ,ub.bar-code-attr.attr-code)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/check-bc.i }
{ trg/bc-attrh.i trig ub.bar-code-attr ub.bar-code-attr }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    run check-use-bar-code in this-procedure ( input ub.bar-code-attr.b-code) no-error.
    if error-status:error then do:
      undo main-block, return error return-value .
    end.
  end.
  run str/callnews.p
    (input {&table_bar-code-attr}
    ,input (buffer ub.bar-code-attr:handle)
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно маршрутизировать bar-code-attr для отправки в новости" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box.
    undo main-block, return error return-value .
  end.
  run bc-attrh_write-bar-code-attr-trigger in this-procedure  (
                                        input new(ub.bar-code-attr)
                                      ,input integer({&hn-update})
                                      ,input (if g#news
                                              then {&hn-source-db}
                                              else (if g#esys
                                                    then {&hn-source-esys}
                                                    else "":U
                                                    )
                                              )
                                      ,input (if g#news
                                              then string(g#news-source-db)
                                              else (if g#esys
                                                    then string(g#esys-source-esys)
                                                    else  "":U)
                                              )
                                    ) .

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_bar-code-attr}
        , input ( buffer ub.bar-code-attr:handle )
    ) no-error.
    if error-status :error
    then do:
        undo main-block, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.