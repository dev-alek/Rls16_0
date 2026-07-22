block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории товара на кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/18/07
Author: Bakhtadze Natalya
Creation date: 01/18/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-cd-plu OLD old_c-cd-plu .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории товара на кассе".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                                    ,ub.c-cd-plu.obj-type
                                    ,ub.c-cd-plu.obj-code
                                    ,ub.c-cd-plu.pos-type
                                    ,ub.c-cd-plu.plu-type
                                    ,ub.c-cd-plu.plu-code
                                    ,ub.c-cd-plu.corr-user-db-num
                                    ,ub.c-cd-plu.chip-num
                                          ) " }

{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-cd-plu.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
    if ub.c-cd-plu.gds-code > 0 then
    run str/callnews.p
      (input {&table_c-cd-plu}
      ,input (buffer ub.c-cd-plu:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-cd-plu}
        , input ( buffer ub.c-cd-plu:handle )
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