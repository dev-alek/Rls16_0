block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись fbr-prn-grp

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/03
Author: Bakhtadze Natalya
Creation date: 08/21/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fbr-prn-grp OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись fbr-prn-grp".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         ,ub.fbr-prn-grp.db-num
                         ,ub.fbr-prn-grp.prn-num
                         ,ub.fbr-prn-grp.obj-type
                         ,ub.fbr-prn-grp.obj-code
                         ,ub.fbr-prn-grp.node-code
                         )"}
{ cmp/trg-def.i  }

define buffer buf_clients for ub.clients.
define buffer buf_fbr-prn-grp for ub.fbr-prn-grp.

{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-fbr-prn for ub.c-fbr-prn.
define buffer buf_c-fbr-prn-grp for ub.c-fbr-prn-grp.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    find first buf_clients no-lock where
               buf_clients.obj-type = ub.fbr-prn-grp.obj-type
           AND buf_clients.obj-code = ub.fbr-prn-grp.obj-code.
    if buf_clients.db-num <> g#db-num then do:
      message
      "Нельзя изменять запись о группе товаров на принтере," skip
      "принадлежащем другой БД"
      view-as alert-box .
      undo main-block, return error.
    end.
  end.

  find first buf_fbr-prn-grp no-lock where
             buf_fbr-prn-grp.node-code = ub.fbr-prn-grp.node-code
         AND buf_fbr-prn-grp.obj-type = ub.fbr-prn-grp.obj-type
         AND buf_fbr-prn-grp.obj-code = ub.fbr-prn-grp.obj-code
         AND recid(buf_fbr-prn-grp) <> recid(ub.fbr-prn-grp)
         no-error .
  if available buf_fbr-prn-grp then do:
    message
    "Группа товаров" ub.fbr-prn-grp.node-code
    "уже привязана к принтеру"  skip
    "принтер" buf_fbr-prn-grp.prn-num
    view-as alert-box error .
    undo main-block, return error .
  end.
  run str/callnews.p
    ( input {&table_fbr-prn-grp}
     ,input (buffer ub.fbr-prn-grp:handle )
    ) .
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fbr-prn-grp.
    assign
    buf_c-fbr-prn-grp.prn-num            = ub.fbr-prn-grp.prn-num
    buf_c-fbr-prn-grp.db-num             = ub.fbr-prn-grp.db-num
    buf_c-fbr-prn-grp.node-code          = ub.fbr-prn-grp.node-code
    buf_c-fbr-prn-grp.obj-type           = ub.fbr-prn-grp.obj-type
    buf_c-fbr-prn-grp.obj-code           = ub.fbr-prn-grp.obj-code
    buf_c-fbr-prn-grp.corr-user-db-num   = g#db-num
    buf_c-fbr-prn-grp.chip-num           = next-value (s-scales-chip, {&db-name_schema})
    .
    create buf_c-fbr-prn.
    buffer-copy
    buf_c-fbr-prn-grp
    to buf_c-fbr-prn
    assign
    buf_c-fbr-prn.corr-time          = v-time
    buf_c-fbr-prn.corr-user-name     = g#userid
    buf_c-fbr-prn.corr-date          = v-date
    buf_c-fbr-prn.subject            = {&table_fbr-prn-grp}
    buf_c-fbr-prn.action             = integer(if new(ub.fbr-prn-grp) then {&hn-create} else {&hn-update})
    .
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fbr-prn-grp}
        , input ( buffer ub.fbr-prn-grp:handle )
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