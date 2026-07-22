/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение признака объекта - участвует в TPSI

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/25/04
Author: Bakhtadze Natalya
Creation date: 11/25/04

ТРЕБУЕТ CLNTATTR.i!!!!!!!!!!!!!!!!!

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure is-tpsi-object :
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define output parameter p-is-tpsi-object as logical no-undo .
define variable vss-description as character no-undo init "is-tpsi-object-01: получение признака объекта - участвует в TPSI".
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type as character no-undo .

define variable v-is-tpsi-object as logical no-undo .

define buffer buf_clients for ub.clients.

  do
  on error undo, return error
  :
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          AND buf_clients.obj-code = p-obj-code no-error .
    if not available buf_clients then do:
      return error substitute("&1 &2&3 не найден объект", vss-description, p-obj-type, p-obj-code).
    end.
    if not (buf_clients.db-num = g#db-num  or g#db-num = 0) then do:
      return error substitute("&1 &2&3 нельзя определить значение свойства УЧАСТВУЕТ В ТСПИ не в ГБД и не в свое УБД", vss-description, p-obj-type, p-obj-code).
    end.
    run clntattr-value  in this-procedure (
          input  {&cmp}
        ,input   buf_clients.host-code
        ,input   {&attr-als-gds}
        ,output v-attr-value
        ,output v-attr-type
                                            ) no-error .
    if not error-status:error
    and logical (v-attr-value) = yes then do:
      assign
      v-is-tpsi-object = yes
      .
      { gbl/conf-rd.i
      "'tpsi'"
      0
      "''"
      0
      "''"
      "''"
      "''"
      no
      conf-par
      par-type
      no-error
      }
      if not error-status:error
      and v-is-tpsi-object
      and (conf-par = "yes") then do:
        assign
        p-is-tpsi-object = yes
        .
      end.
    end.
  end.

end procedure. /* is-tpsi-object */







/* $Workfile$ e n d */