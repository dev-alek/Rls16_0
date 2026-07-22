block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории групп товаров на весах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/05
Author: Bakhtadze Natalya
Creation date: 04/22/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-scales-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории групп товаров на весах".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                                          , ub.c-scales-grp.db-num
                                          , ub.c-scales-grp.node-code
                                          , ub.c-scales-grp.scales-num
                                          , ub.c-scales-grp.corr-user-db-num
                                          , ub.c-scales-grp.chip-num) " }
{ cmp/trg-def.i }

define variable p-news as logical no-undo .
define buffer buf_scales for ub.scales.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-scales-grp.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
    run str/callnews.p
      (input {&table_c-scales-grp}
      ,input (buffer ub.c-scales-grp:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-scales-grp}
        , input ( buffer ub.c-scales-grp:handle )
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