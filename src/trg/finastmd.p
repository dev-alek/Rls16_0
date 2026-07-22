block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление  атрибутов банковской выписки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/01/05
Author: Bakhtadze Natalya
Creation date: 08/01/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.fin-statement-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление атрибутов банковской выписки".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.fin-statement-attr.host-code
                         , ub.fin-statement-attr.sttm-code
                         , ub.fin-statement-attr.attr-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ ref/fs-attr.i }
{ trg/f-stmath.i trig  ub.fin-statement-attr ub.fin-statement-attr }

define variable p-news as logical no-undo.
define buffer buf_sysconf  for ub.sysconf.



main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run fs-attr-news  in this-procedure (
                                        input ub.fin-statement-attr.attr-code
                                       ,output p-news) no-error.

  if  p-news then do:
    find first buf_sysconf no-lock where buf_sysconf.host-code = ub.fin-statement-attr.host-code.
    if buf_sysconf.firm-db-num <> 0
    then do:
      run nws/cmd-del.p
        ( input "fin-statement-attr":U
        ,input (buffer ub.fin-statement-attr:handle)
        ,input "":U
        ) no-error .
      if error-status :error then do:
        undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
      end.
    end.
  end.
  run write-fin-statement-attr-trigger in this-procedure (
                             input no).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fin-statement-attr}
        , input ( buffer ub.fin-statement-attr:handle )
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