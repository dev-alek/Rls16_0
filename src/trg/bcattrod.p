block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление атрибутов бар-кода по обьъектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/02/09
Author: Bakhtadze Natalya
Creation date: 06/02/09

*/

TRIGGER PROCEDURE FOR DELETE OF ub.bar-code-obj-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление атрибутов бар-кода по обьъектам".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u~
                              ,ub.bar-code-obj-attr.obj-type~
                              ,ub.bar-code-obj-attr.obj-code~
                              ,ub.bar-code-obj-attr.b-code~
                              ,ub.bar-code-obj-attr.attr-code~
                              )" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/bcattroh.i trig ub.bar-code-obj-attr ub.bar-code-obj-attr }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run bc-attrh_write-bar-code-obj-attr-trigger in this-procedure  (
                                        input no
                                        ,input integer({&hn-delete})
                                        ,input (if g#news
                                                then {&hn-source-db}
                                                else (if g#esys
                                                      then {&hn-source-esys}
                                                      else "":U)
                                                )
                                        ,input (if g#news
                                                then string(g#news-source-db)
                                                else (if g#esys
                                                      then string(g#esys-source-esys)
                                                      else "")
                                                )
                                      ) .
  run nws/cmd-del.p
    ( input {&table_bar-code-obj-attr}
      ,input (buffer ub.bar-code-attr:handle)
      ,input "":U
    ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_bar-code-obj-attr}
        , input ( buffer ub.bar-code-obj-attr:handle )
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