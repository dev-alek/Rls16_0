block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись  атрибутов фин док-та

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fin-doc-attr OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись атрибутов фин док-та".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.fin-doc-attr.host-code, ub.fin-doc-attr.fin-doc-code, ub.fin-doc-attr.attr-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ ref/fd-attr.i }
{ trg/f-docath.i trig  oldb ub.fin-doc-attr }

define variable p-news as logical no-undo.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run fd-attr-news  in this-procedure (
                                        input ub.fin-doc-attr.attr-code
                                       ,output p-news) no-error.

  if  p-news then do:
    run str/callnews.p
      ( input "fin-doc-attr"
       ,input (buffer ub.fin-doc-attr:handle)
      ) .
  end.
  run write-fin-doc-attr-trigger in this-procedure (
                             input (if new(ub.fin-doc-attr) then yes else no)).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fin-doc-attr}
        , input ( buffer ub.fin-doc-attr:handle )
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