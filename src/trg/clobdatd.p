block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление clob-data

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/07
Author: Bakhtadze Natalya
Creation date: 12/28/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.clob-data.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление clob-data".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/key-rec.i }
define variable v-key-rec as character no-undo .
define buffer buf_route for ub.route.
define buffer buf_route-dump for ub.route-dump.
define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_clob-bind for ub.clob-bind.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run gen-key-rec in this-procedure ( input {&table_clob-data}
                                     ,input (buffer ub.clob-data:handle)
                                     ,output v-key-rec).
  for each buf_clob-bind no-lock where
          buf_clob-bind.db-num = ub.clob-data.db-num
      and buf_clob-bind.int64-id = ub.clob-data.int64-id:
    if buf_clob-bind.resource-type = {&lob-res-gate} then do:
      for each buf_esys-route no-lock where
              buf_esys-route.uniq-gate-rec = v-key-rec :
        message
        substitute("&1 используется для маршрутизации во внешнюю систему&2Удаление невозможно"
                    ,v-key-rec
                    ,{&new-line})
        view-as alert-box error .
        undo main-block, return error .

      end.
      for each buf_esys-route-dump no-lock where
              buf_esys-route-dump.uniq-gate-rec = v-key-rec :
        message
        substitute("&1 используется для маршрутизации во внешнюю систему&2Удаление невозможно"
                    ,v-key-rec
                    ,{&new-line})
        view-as alert-box error .
        undo main-block, return error .

      end.
      for each buf_route no-lock where
              buf_route.uniq-gate-rec = v-key-rec :
        message
        substitute("&1 используется для маршрутизации СПН&2Удаление невозможно"
                    ,v-key-rec
                    ,{&new-line})
        view-as alert-box error .
        undo main-block, return error .

      end.
      for each buf_route-dump no-lock where
              buf_route-dump.uniq-gate-rec = v-key-rec :
        message
        substitute("&1 используется для маршрутизации СПН&2Удаление невозможно"
                    ,v-key-rec
                    ,{&new-line})
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end.
  run nws/cmd-del.p
    ( input {&table_clob-data}
     ,input (buffer ub.clob-data:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.


end.