block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pt-io-f1.p $
$Archive: ref/pt-io-f1.p $

Сохранение Пункта доставки/отгрузки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/09
Author: Bakhtadze Natalya
Creation date: 09/29/09

*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-point-code as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define input parameter p-point-name as character no-undo .
define input parameter p-point-type as character no-undo .
define input parameter p-deliv-subj-code as integer no-undo .
define input parameter p-is-default as logical no-undo .
define input parameter p-address as character no-undo .
define input parameter p-ps as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pt-io-f1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/pt-io-f1.p $":U .
define variable vss-description as character no-undo init "Сохранение Пункта доставки/отгрузки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-err-mess as character no-undo .
define variable glog as logical no-undo .
define buffer buf_point-io for ub.point-io.
define buffer b_point-io for ub.point-io.
define buffer buf_clients for ub.clients.
define buffer buf_delivery-subject for ub.delivery-subject.
define buffer buf_db for ub.db.

if p-mode <> {&add-def}
and p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  undo, return error '':u.
end.

if p-point-name = "" or p-point-name = ? then do:
  v-err-mess = "Название пункта должно быть заполнено." .
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "point-name":U).
end.
if p-cli-type = ""
or p-cli-type = ?
then do:
  v-err-mess = "Нет контрагента!".
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "cli-type":U).
end.
if p-cli-code = 0
or p-cli-code = ?
then do:
  v-err-mess = "Нет контрагента!" .
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "cli-code":U).
end.
find first buf_clients no-lock where
          buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code no-error.
if not available buf_clients then do:
  v-err-mess = substitute("Неверный контрагент &1&2", p-cli-type, p-cli-code).
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "cli-code":U).
end.
if p-point-type <> {&point-in}
and p-point-type <> {&point-out} then do:
  v-err-mess = substitute("Неверный тип пункта: &1", p-point-type).
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "point-type":U).
end.
if p-deliv-subj-code <> 0 then do:
  find first buf_delivery-subject no-lock where
            buf_delivery-subject.deliv-subj-code = p-deliv-subj-code no-error.
  if not available buf_delivery-subject then do:
    v-err-mess = substitute("Неверный тип субъекта доставки: &1", p-deliv-subj-code).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else "deliv-subj-code":U).
  end.
end.
if p-is-default then do:
  find first b_point-io
    where b_point-io.cli-code   = p-cli-code
      and b_point-io.cli-type   = p-cli-type
      and b_point-io.point-type = p-point-type
      and b_point-io.is-default = yes
  no-error .
  if available b_point-io
  and (p-mode = {&add-def}
  or recid(b_point-io) <> p-doc-rec)
  then do:
    if not p-silent then do:
      glog = no.
      message
      substitute("У контрагента &1&2 уже есть пункт по умолчанию для типа <&3>&4" +
                 "Продолжить? (При выборе ДА признак будет перенесен на изменяемый пункт)"
                  , p-cli-type
                  , p-cli-code
                  , p-point-type
                  , {&new-line}
                  )
      view-as alert-box QUESTION BUTTONS YES-NO UPDATE glog .
      if glog <> yes then return "quit".
    end.
  end. /*if available b_point-io then do:*/
end. /*if p-is-default then do:*/
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode = {&add-def} then do:
    create buf_point-io .
    assign
    buf_point-io.db-num     = p-db-num
    buf_point-io.cli-type   = p-cli-type
    buf_point-io.cli-code   = p-cli-code
    buf_point-io.point-code = next-value( s-point-io, {&db-name_schema} )
    buf_point-io.status_    = {&current-status}
    .
  end.
  else do:
    FIND FIRST buf_point-io where
              recid(buf_point-io) = p-doc-rec No-ERROR.
    if not available buf_point-io then do:
      v-err-mess = substitute("&1 &2 &3&4Не найдена запись СУБЪЕКТ ДОСТАВКИ - p-doc-rec=&5"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              , {&new-line}
                              ,p-doc-rec).
      run err-mess in this-procedure ( input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
    if buf_point-io.cli-type <> p-cli-type
    or buf_point-io.cli-code <> p-cli-code
    then do:
      v-err-mess = substitute("&1 &2 &3&4Для уже имеющейся записи нельзя изменить контрагента&4ранее был &5&6 - попытка изменить на &7&8"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              , {&new-line}
                              ,buf_point-io.cli-type
                              ,buf_point-io.cli-code
                              ,p-cli-type
                              ,p-cli-code
                               ).
      run err-mess in this-procedure ( input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
  end.
  assign
  buf_point-io.point-name = p-point-name
  buf_point-io.PS         = p-PS
  buf_point-io.cli-type   = p-cli-type
  buf_point-io.cli-code   = p-cli-code
  buf_point-io.address    = p-address
  buf_point-io.is-default = p-is-default
  buf_point-io.point-type = p-point-type
  buf_point-io.deliv-subj-code = p-deliv-subj-code
  p-doc-rec = recid (buf_point-io).
  .
  release buf_point-io no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при попытке сохранения записи:&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "":U).
  end.
end.

PROCEDURE err-mess:
DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
if p-silent then do:
  assign
  p-mess = substitute("Пункт доставки/отгрузки: код &1 БД &2&3:&4"
                      , (if p-mode = {&add-def} or not available buf_point-io then p-point-code else buf_point-io.point-code)
                      , (if p-mode = {&add-def} or not available buf_point-io then p-db-num else buf_point-io.db-num)
                      , {&new-line}
                      , p-mess)
  .

end.
else do:
  message
  p-mess
  view-as alert-box error .
end.
END PROCEDURE.