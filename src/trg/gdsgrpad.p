block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление gds-grp-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.gds-grp-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление gds-grp-attr".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                                    ,ub.gds-grp-attr.node-code
                                    ,ub.gds-grp-attr.attr-code
                                    ,ub.gds-grp-attr.host-code
                                    ,ub.gds-grp-attr.obj-type
                                    ,ub.gds-grp-attr.obj-code
                                    )" }

{ cmp/trg-def.i  }
{ ref/grp-attr.i }
{ gbl/cur-time.i }
{ trg/gds-grph.i }

define variable p-news as logical no-undo.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  /*
  if ub.gds-grp-attr.host-code = 0
  and ub.gds-grp-attr.obj-type = "":U
  and ub.gds-grp-attr.obj-code = 0
  AND ub.gds-grp-attr.attr-code = {&attr-gds-grp-margins-h} then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалить корневой атрибут группы товара" skip
    "код атрибута" ub.gds-grp-attr.attr-code
    view-as alert-box error .
    undo, return error.
  end.
  */
  run grp-attr-news in this-procedure(input ub.gds-grp-attr.attr-code,
                                      output p-news) no-error.
  if not p-news then return.

  run nws/cmd-del.p
    ( input "gds-grp-attr":U
     ,input (buffer ub.gds-grp-attr:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if not g#news then do:
    run gds-grph_write-gds-grp-attr-proc   in this-procedure (
                                                      buffer ub.gds-grp-attr
                                                      ,integer({&hn-delete})
                                                      ,"":U /*p-source-type*/
                                                      ,"":U
                                                      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_gds-grp-attr}
        , input ( buffer ub.gds-grp-attr:handle )
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