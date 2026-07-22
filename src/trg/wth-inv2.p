block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка корректности данных в документе МЦ инвент

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/05
Author: Bakhtadze Natalya
Creation date: 09/21/05


*/

define input parameter p-silent                       as logical no-undo .


define input parameter pardoc-code like ub.wth-doc.doc-code no-undo .
define input parameter parhost-code like ub.wth-doc.host-code no-undo .
define input parameter parobj-type like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code like ub.wth-doc.obj-code no-undo .
define input parameter par-operator like ub.wth-doc.operator no-undo .
define input parameter par-deliver like ub.wth-doc.deliver no-undo .
define input parameter par-receiver like ub.wth-doc.receiver no-undo .
define input parameter par-inv-prs4 like ub.wth-doc.inv-prs4 no-undo .
define input parameter par-inv-prs5 like ub.wth-doc.inv-prs5 no-undo .
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input parameter parlines-exist as logical no-undo .
define input parameter parstaff-exist as logical no-undo .
define output parameter parcli-name like ub.clients.obj-name no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности данных в документе МЦ инвент".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/clntattr.i }

DEFINE VARIABLE varpsn-code-list as character no-undo .
define variable v-mes     as character no-undo .
define variable v-file    as logical no-undo .
DEFINE VARIABLE var-entry as character no-undo .
define variable v-type as character no-undo .

define buffer buf_wth-line for ub.wth-line .
define buffer buf_wth-line-exist for ub.wth-line .
define buffer buf_clients for ub.clients .
define buffer buf_person1 for ub.clients .
define buffer buf_person2 for ub.clients .
define buffer buf_person3 for ub.clients .
define buffer buf_person4 for ub.clients .
define buffer buf_person5 for ub.clients .

_main:
do
on error undo, return error return-value
:


if parauto-fill and parobj-type = {&stock} then do:
  v-mes = substitute("Для автоматического документа объект документа &1&2 должен быть магазином", parobj-type, parobj-code).
  run err-mess(input-output v-mes).
  var-entry = "obj-code":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.


FIND FIRST buf_wth-line No-LOCK WHERE
           buf_wth-line.doc-code = pardoc-code No-ERROR.
if not avail buf_wth-line and /*нет строк!!*/ parlines-exist then do:
  v-mes = substitute("Нет строк в документе!").
  run err-mess(input-output v-mes).
  var-entry = "b-add":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.

if parstaff-exist OR par-operator <> 0 then do:
  FIND FIRST buf_person1 NO-LOCK WHERE
    buf_person1.obj-type = {&prs}         AND
    buf_person1.obj-code = par-operator NO-ERROR.
  IF NOT AVAIL buf_person1 THEN DO:
    v-mes = substitute("Не найден оператор &1 в справочнике клиентов!", par-operator).
    run err-mess(input-output v-mes).
    var-entry = "operator":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
  varpsn-code-list = varpsn-code-list + string(buf_person1.obj-code) + {&comma-char}.
end.

if parstaff-exist OR par-deliver <> 0 then do:
  FIND FIRST buf_person2 NO-LOCK WHERE
    buf_person2.obj-type = {&prs}         AND
    buf_person2.obj-code = par-deliver NO-ERROR.
  IF NOT AVAIL buf_person2 THEN DO:
    v-mes = substitute("Не найден оператор &1 в справочнике клиентов!", par-deliver).
    run err-mess(input-output v-mes).
    var-entry = "deliver":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
  if not parauto-fill and lookup(string(buf_person2.obj-code), varpsn-code-list) > 0 then do:
    v-mes = substitute("Неверный состав членов инвентаризационной комиссии!").
    run err-mess(input-output v-mes).
    var-entry = "deliver":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  varpsn-code-list = varpsn-code-list + string(buf_person2.obj-code) + {&comma-char}.
end.

if parstaff-exist OR  par-receiver <> 0 then do:
  FIND FIRST buf_person3 NO-LOCK WHERE
    buf_person3.obj-type = {&prs}         AND
    buf_person3.obj-code = par-receiver NO-ERROR.
  IF NOT AVAIL buf_person3 THEN DO:
    v-mes = substitute("Не найден оператор &1 в справочнике клиентов!", par-receiver).
    run err-mess(input-output v-mes).
    var-entry = "receiver":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
  if not parauto-fill and lookup(string(buf_person3.obj-code), varpsn-code-list) > 0 then do:
    v-mes = substitute("Неверный состав членов инвентаризационной комиссии!").
    run err-mess(input-output v-mes).
    var-entry = "receiver":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  varpsn-code-list = varpsn-code-list + string(buf_person3.obj-code) + {&comma-char}.

end.

if parstaff-exist OR  par-inv-prs4 <> 0 then do:
  FIND FIRST buf_person4 NO-LOCK WHERE
    buf_person4.obj-type = {&prs}         AND
    buf_person4.obj-code = par-inv-prs4 NO-ERROR.
  IF NOT AVAIL buf_person4 THEN DO:
    v-mes = substitute("Не найден &1 в справочнике клиентов!", par-inv-prs4).
    run err-mess(input-output v-mes).
    var-entry = "inv-prs4":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
  if not parauto-fill and lookup(string(buf_person4.obj-code), varpsn-code-list) > 0 then do:
    v-mes = substitute("Неверный состав членов инвентаризационной комиссии!").
    run err-mess(input-output v-mes).
    var-entry = "inv-prs4":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  varpsn-code-list = varpsn-code-list + string(buf_person4.obj-code) + {&comma-char}.

end.

if parstaff-exist OR  par-inv-prs5 <> 0 then do:
  FIND FIRST buf_person5 NO-LOCK WHERE
    buf_person5.obj-type = {&prs}         AND
    buf_person5.obj-code = par-inv-prs5 NO-ERROR.
  IF NOT AVAIL buf_person5 THEN DO:
    v-mes = substitute("Не найден &1 в справочнике клиентов!", par-inv-prs5).
    run err-mess(input-output v-mes).
    var-entry = "inv-prs5":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
  if not parauto-fill and lookup(string(buf_person5.obj-code), varpsn-code-list) > 0 then do:
    v-mes = substitute("Неверный состав членов инвентаризационной комиссии!").
    run err-mess(input-output v-mes).
    var-entry = "inv-prs5":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  varpsn-code-list = varpsn-code-list + string(buf_person5.obj-code) + {&comma-char}.
end.

FIND FIRST buf_clients No-LOCK WHERE
           buf_clients.obj-type = {&cmp} AND
           buf_clients.obj-code = parhost-code No-ERROR.
if not avail buf_clients then do:
  v-mes = substitute("Не найдена фирма &1", parhost-code).
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
end.

parcli-name = buf_clients.obj-name.
end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mes as character No-UNDO.
  p-mes = substitute("Документ МЦ №&1: &2&3&4&5", pardoc-code, parobj-type, parobj-code, {&new-line}, p-mes).
  if not p-silent then
  message p-mes view-as alert-box .
END PROCEDURE.