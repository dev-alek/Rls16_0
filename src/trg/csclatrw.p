block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории атрибутов весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/05
Author: Bakhtadze Natalya
Creation date: 04/22/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-scales-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории атрибутов весов".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                                          , ub.c-scales-attr.db-num
                                          , ub.c-scales-attr.scales-num
                                          , ub.c-scales-attr.attr-code
                                          , ub.c-scales-attr.corr-user-db-num
                                          , ub.c-scales-attr.chip-num) " }
{ cmp/trg-def.i }
{ ref/scl-attr.i }

define variable p-news as logical no-undo .
define buffer buf_scales for ub.scales.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run scl-attr-news in this-procedure (
                                       input ub.c-scales-attr.attr-code
                                       ,output p-news) no-error.

  if p-news
  and (not g#news
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-scales-attr.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  )
  then do:
    run str/callnews.p
      (input {&table_c-scales-attr}
      ,input (buffer ub.c-scales-attr:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-scales-attr}
        , input ( buffer ub.c-scales-attr:handle )
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