block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись fbr-prn

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/03
Author: Bakhtadze Natalya
Creation date: 08/21/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fbr-prn OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись fbr-prn".
{ cmp/vssrevis.i "substitute('&1|&2',ub.fbr-prn.db-num,ub.fbr-prn.prn-num)"}
{ cmp/trg-def.i  }

{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-fbr-prn for ub.c-fbr-prn.


define buffer buf_fbr-prn for ub.fbr-prn.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    if ub.fbr-prn.db-num <> g#db-num then do:
      message
      "Нельзя изменять запись о принтере," skip
      "принадлежащем другой БД"
      view-as alert-box .
      undo main-block, return error.
    end.

    For each ub.fbr-prn-grp NO-LOCK where
            ub.fbr-prn-grp.prn-num = ub.fbr-prn.prn-num:
      message
      "К данному принтеру привязаны группы товаров!" skip
      "Изменение невозможно!" view-as alert-box ERROR.
      undo  main-block, return error.
    end.
    For each ub.fbr-prn-gds NO-LOCK where
            ub.fbr-prn-gds.prn-num = ub.fbr-prn.prn-num:
      message
      "К данному принтеру привязаны товары!" skip
      "Изменение невозможно!" view-as alert-box ERROR.
      undo main-block, return error.
    end.
  end.
  find first buf_fbr-prn no-lock where
             buf_fbr-prn.prn-num = ub.fbr-prn.prn-num
         AND buf_fbr-prn.db-num = ub.fbr-prn.db-num
         AND recid(buf_fbr-prn) <> recid(ub.fbr-prn)
         no-error .
  if available buf_fbr-prn then do:
    message
    "Уже есть принтер с номером"  buf_fbr-prn.prn-num
    view-as alert-box error .
    undo main-block , return error .
  end.

  run str/callnews.p
    ( input "fbr-prn"
     ,input (buffer ub.fbr-prn:handle )
    ) .
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fbr-prn.
    buffer-copy oldb to buf_c-fbr-prn
    assign
    buf_c-fbr-prn.prn-num            = ub.fbr-prn.prn-num
    buf_c-fbr-prn.db-num             = ub.fbr-prn.db-num
    buf_c-fbr-prn.chip-num           = next-value (s-scales-chip, {&db-name_schema})
    buf_c-fbr-prn.corr-time          = v-time
    buf_c-fbr-prn.corr-user-db-num   = g#db-num
    buf_c-fbr-prn.corr-user-name     = g#userid
    buf_c-fbr-prn.corr-date          = v-date
    buf_c-fbr-prn.subject            = {&table_fbr-prn}
    buf_c-fbr-prn.action             = integer(if new(ub.fbr-prn) then {&hn-create} else {&hn-update})
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fbr-prn}
        , input ( buffer ub.fbr-prn:handle )
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
end. /*doe*/