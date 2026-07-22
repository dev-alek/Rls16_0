block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmd-itrg.p $
$Archive: nws/cmd-itrg.p $

Прием записи с отключением триггеров

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/22/06
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

define input parameter p-imp-handle as handle    no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-key-rec as character no-undo .
define input parameter p-table-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmd-itrg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmd-itrg.p $":U .
define variable vss-description as character no-undo init "Прием записи с отключением триггеров".

{ cmp/vssrevis.i "substitute('&1':u,p-key-rec)" }
{ cmp/trg-def.i }
{ gbl/key-rec.i }

define variable temp-h as handle no-undo .
define variable v-bh as handle no-undo  .
define variable v-temp-bh as handle no-undo .
define variable glog as logical no-undo .


do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:


  create temp-table temp-h.
  temp-h:create-like( substitute('ub.&1', p-table-name)) no-error.
  if error-status:error then do:
    undo, return  error substitute( "&1. Ошибка при создании temp-table &2 &3&4&5", vss-workfile, p-table-name, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
  end.
  v-temp-bh = temp-h:default-buffer-handle.


  create buffer v-bh for table substitute('ub.&1', p-table-name).


  define variable v-tbl-row  as rowid     no-undo.
  define variable v-tbl-name as character no-undo.


  glog = v-temp-bh:buffer-create() no-error.
  if error-status:error then do:
    undo, return  error substitute( "&1. Ошибка при создании записи в temp-table &2 &3&4&5", p-table-name, vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
  end.
  run nws-impl in p-imp-handle
    ( input p-table-name
     ,input v-temp-bh
    ) no-error.
  if error-status :error then do:
    return error return-value .
  end.

  if p-key-rec = '':U then do:
    run gen-key-rec in this-procedure
      ( input  p-table-name
        ,input  v-temp-bh
        ,output p-key-rec
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при генерации пропущенного уникального ключа для таблицы &2.&3&4&3&5"
                              ,vss-workfile
                              ,p-table-name
                              ,{&new-line}
                              ,return-value
                              ,error-status :get-message ( error-status :num-messages )
                            ).
    end.
  end.
  run gen-row-keyr in this-procedure
    ( input p-key-rec
     ,input ?
     ,input "ub"
     ,input ?
     ,input share-lock
     ,output v-tbl-row
     ,output v-tbl-name
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при поиске записи по уникальному ключу &2.&3&4&3&5"
                             ,vss-workfile
                             ,p-key-rec
                             ,{&new-line}
                             ,return-value
                             ,error-status :get-message ( error-status :num-messages )
                           ).
  end.

  if v-tbl-name <> p-table-name then do:
    return error substitute( "&1. Уникальный ключ &2 не соответствует принимаемой записи &3"
                             ,vss-workfile
                             ,p-key-rec
                             ,p-table-name
                           ).
  end.

  glog = v-bh:find-by-rowid( v-tbl-row, exclusive-lock ) no-error.

  if error-status:error then do:
    undo, return  error substitute( "&1. Ошибка при поиcке записи &2 в БД  &3&4&5", p-table-name, vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
  end.

  glog = v-bh:disable-load-triggers( yes ).

  if v-bh:available then do:
    glog = v-bh:buffer-create() .
  end.
  glog = v-bh:buffer-copy(v-temp-bh) no-error .

  if error-status:error then do:
    undo, return  error substitute( "&1. Ошибка при копировании записи &2 в БД  &3&4&5", p-table-name, vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
  end.

  glog = v-bh:buffer-release no-error .

  if error-status:error then do:
    undo, return  error substitute( "&1. Ошибка при сохранении записи &2 в БД  &3&4&5", p-table-name, vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
  end.


  glog = v-temp-bh:buffer-delete() no-error.

  delete object v-temp-bh.
  delete object v-bh.

end.