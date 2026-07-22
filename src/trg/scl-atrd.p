block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление атрибутов весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/19/05
Author: Bakhtadze Natalya
Creation date: 04/19/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.scales-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление атрибутов весов".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5',  ub.scales-attr.db-num
                                          , ub.scales-attr.scales-num
                                          , ub.scales-attr.attr-code
                                          ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-scales for ub.c-scales.
define buffer buf_c-scales-attr for ub.c-scales-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news and ub.scales-attr.db-num <> g#db-num then do:
    message
    "Нельзя удалять запись об атрибуте весов," skip
    "принадлежащих другой БД"
    view-as alert-box .
    undo main-block, return error.
  end.


  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-scales-attr.
    buffer-copy ub.scales-attr to buf_c-scales-attr
    assign
    buf_c-scales-attr.chip-num           = next-value (s-scales-chip, {&db-name_schema})
    buf_c-scales-attr.corr-time          = v-time
    buf_c-scales-attr.corr-user-db-num   = g#db-num
    buf_c-scales-attr.corr-user-name     = g#userid
    buf_c-scales-attr.corr-date          = v-date
    .
    create buf_c-scales.
    buffer-copy buf_c-scales-attr to buf_c-scales
    assign
    buf_c-scales.is-del             = yes
    buf_c-scales.subject            = {&table_scales-attr}
    buf_c-scales.action             = integer({&hn-delete})
    .
  end.

  /* посылаем команду на удаление атрибута весов */
  if not g#news then do:
    run nws/cmd-del.p
      ( input "scales-attr":U
      ,input (buffer ub.scales-attr:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_scales-attr}
        , input ( buffer ub.scales-attr:handle )
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