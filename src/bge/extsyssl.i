/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка доступности изменения или удаления специальной ВС

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/24/08
Author: Bakhtadze Natalya
Creation date: 02/24/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ ref/extclass.i }
{ gbl/key-rec.i }

procedure extsyssl :
define parameter buffer buf_ext-system for ub.ext-system.
define output parameter p-ok as logical   no-undo .

define variable v-resource-id as character no-undo .
define variable v-found as logical   no-undo .
define buffer buf_some-lk for ub.some-lk.
define buffer buf_ext-classif for ub.ext-classif.

do
on error undo, return error return-value
:
    /*проверим наличие объектов*/
  for each buf_ext-classif no-lock where
        buf_ext-classif.classif-subject = {&table_clients}
    and buf_ext-classif.classif-name = {&extclass_clients_esys}
    AND buf_ext-classif.db-num = 0
    AND buf_ext-classif.key#_one = buf_ext-system.esys-id
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    v-found = yes.
    leave.
  end.
  if v-found then do:
    undo, return error substitute("К данной внешней системе привязаны объекты&1" +
                        "изменение моды экспорта/импорта или БД для экспорта/импорта НЕВОЗМОЖНО", {&new-line}).
  end.

    /*проверим наличие свфзангных контрагентов*/
  for each buf_ext-classif no-lock where
        buf_ext-classif.classif-subject = {&table_clients}
    and buf_ext-classif.classif-name = {&extclass_clients_edoc-nn}
    AND buf_ext-classif.db-num = -1
    AND buf_ext-classif.key#_one = buf_ext-system.esys-id
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    v-found = yes.
    leave.
  end.
  if v-found then do:
    undo, return error substitute("К данной внешней системе привязаны контрагенты&1" +
                        "изменение моды экспорта/импорта или БД для экспорта/импорта НЕВОЗМОЖНО", {&new-line}).
  end.
  for each buf_ext-classif no-lock where
        buf_ext-classif.classif-subject = {&table_clients}
    and buf_ext-classif.classif-name = {&extclass_clients_exite-edi}
    AND buf_ext-classif.db-num = -1
    AND buf_ext-classif.key#_one = buf_ext-system.esys-id
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    v-found = yes.
    leave.
  end.
  if v-found then do:
    undo, return error substitute("К данной внешней системе привязаны контрагенты&1" +
                        "изменение моды экспорта/импорта или БД для экспорта/импорта НЕВОЗМОЖНО", {&new-line}).
  end.

  /*проверим наличие локов*/
  run gen-key-rec in this-procedure ( input {&table_ext-system}
                                    ,input (buffer buf_ext-system:handle)
                                    ,output v-resource-id).
  for each buf_some-lk no-lock where
          buf_some-lk.resource_id = v-resource-id :
    leave.
  end.
  if available buf_some-lk then do:
    undo, return error substitute("Внешняя система используется").
  end.
  p-ok = yes.
end.

end procedure. /* extsyssl */


/* $Workfile$ e n d */