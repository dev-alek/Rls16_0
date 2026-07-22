block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории атрибутов кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/04/04
Author: Bakhtadze Natalya
Creation date: 06/04/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-cash-desk-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории атрибутов кассы".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                                          , ub.c-cash-desk-attr.db-num
                                          , ub.c-cash-desk-attr.obj-code
                                          , ub.c-cash-desk-attr.pos-type
                                          , ub.c-cash-desk-attr.cash-num
                                          , ub.c-cash-desk-attr.upper-attr-code
                                          , ub.c-cash-desk-attr.attr-code
                                          , ub.c-cash-desk-attr.corr-user-db-num
                                          , ub.c-cash-desk-attr.chip-num) " }
{ cmp/trg-def.i }
{ gbl/cd-attr.i }

define variable p-news as logical no-undo .
define variable p-from-gbd as logical no-undo .
define variable p-from-ubd as logical no-undo .
define buffer buf_cash-desk for ub.cash-desk.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run cd-attr-news in this-procedure (
                                        input ub.c-cash-desk-attr.upper-attr-code
                                       ,input ub.c-cash-desk-attr.attr-code
                                       ,output p-news
                                       ,output p-from-gbd
                                       ,output p-from-ubd
                                       ) no-error.

  if p-news
  and (
  not g#news
  or (g#news
      and g#db-num > 0
      and ub.c-cash-desk-attr.corr-user-name = {&nts-user}
      )
      )   /*из УБД - записи рожденные СПН*/
  then do:
    run str/callnews.p
      (input {&table_c-cash-desk-attr}
      ,input (buffer ub.c-cash-desk-attr:handle)
      ) no-error .
    if error-status:error then undo main-block, return error return-value .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-cash-desk-attr}
        , input ( buffer ub.c-cash-desk-attr:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.                                                                    end.
end.