block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление групп товаров на весах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/05
Author: Bakhtadze Natalya
Creation date: 04/22/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.scales-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление групп товаров на весах".
{ cmp/vssrevis.i "substitute('&1|&2|&3',  ub.scales-grp.db-num
                                    , ub.scales-grp.node-code
                                    , ub.scales-grp.scales-num
                                          ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-scales for ub.c-scales.
define buffer buf_c-scales-grp for ub.c-scales-grp.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news and ub.scales-grp.db-num <> g#db-num then do:
    message
    "Нельзя удалять запись об группе товаров на весах," skip
    "принадлежащих другой БД"
    view-as alert-box .
    undo main-block, return error.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-scales-grp.
    buffer-copy ub.scales-grp to buf_c-scales-grp
    assign
    buf_c-scales-grp.chip-num           = next-value (s-scales-chip, {&db-name_schema})
    buf_c-scales-grp.corr-time          = v-time
    buf_c-scales-grp.corr-user-db-num   = g#db-num
    buf_c-scales-grp.corr-user-name     = g#userid
    buf_c-scales-grp.corr-date          = v-date
    .
    create buf_c-scales.
    buffer-copy buf_c-scales-grp to buf_c-scales
    assign
    buf_c-scales.is-del             = yes
    buf_c-scales.subject            = {&table_scales-grp}
    buf_c-scales.action             = integer({&hn-delete})
    .
  end.
  /* посылаем команду на удаление групп товаров на весах */
  if not g#news  then do:
    run nws/cmd-del.p
      ( input {&table_scales-grp}
      ,input (buffer ub.scales-grp:handle)
      ,input ''
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_scales-grp}
        , input ( buffer ub.scales-grp:handle )
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