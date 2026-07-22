block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.scales.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление весов".
{ cmp/vssrevis.i "substitute('&1|&2',ub.scales.db-num,ub.scales.scales-num)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-scales for ub.c-scales.
define buffer buf_scales-attr for ub.scales-attr.
define buffer buf_scales-grp for ub.scales-grp.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  define buffer copy_scales for ub.scales.
  if not g#news
  and g#db-num <> scales.db-num then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись ВЕСОВ в чужой БД" skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  /* проверяется, что на весах отсутствуют товары */
  if can-find (first ub.scales-gds
    where ub.scales-gds.scales-num = ub.scales.scales-num
      and ub.scales-gds.db-num = ub.scales.db-num)
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка удаления весов" skip
      "На весах существуют товары" skip
      "Весы" ub.scales.scales-num skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* удаляются все подчиненные весы */
  for each copy_scales exclusive-lock
    where copy_scales.master = ub.scales.scales-num
     and   copy_scales.db-num = ub.scales.db-num
  on error undo, return error
  :
    delete copy_scales .
  end.

  for each buf_scales-attr exclusive-lock where
          buf_scales-attr.db-num = ub.scales.db-num
     AND  buf_scales-attr.scales-num = ub.scales.scales-num
  on error undo, return error
  :
    delete buf_scales-attr .
  end.
  for each buf_scales-grp exclusive-lock where
          buf_scales-grp.db-num = ub.scales.db-num
     AND  buf_scales-grp.scales-num = ub.scales.scales-num
  on error undo, return error
  :
    delete buf_scales-grp .
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-scales.
    buffer-copy scales to buf_c-scales
    assign
    buf_c-scales.chip-num           = next-value (s-scales-chip, {&db-name_schema})
    buf_c-scales.corr-time          = v-time
    buf_c-scales.corr-user-db-num   = g#db-num
    buf_c-scales.corr-user-name     = g#userid
    buf_c-scales.corr-date          = v-date
    buf_c-scales.is-del             = yes
    buf_c-scales.subject            = {&table_scales}
    buf_c-scales.action             = integer({&hn-delete})
    buf_c-scales.attr-code          = "":U
    .
  end.

  /* посылаем команду на удаление весов */
  if not g#news then do:
    run nws/cmd-del.p
      ( input {&table_scales}
      ,input (buffer ub.scales:handle)
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
        , input {&table_scales}
        , input ( buffer ub.scales:handle )
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