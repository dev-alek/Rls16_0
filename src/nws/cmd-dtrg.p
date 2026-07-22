block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmd-dtrg.p $
$Archive: nws/cmd-dtrg.p $

Удаление записи с отключением триггеров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/02/06
Author: Bakhtadze Natalya
Creation date: 05/02/06

*/

define input parameter p-imp-handle as handle    no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-key-rec as character no-undo .
define input parameter p-table-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmd-dtrg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmd-dtrg.p $":U .
define variable vss-description as character no-undo init "Удаление записи с отключением триггеров".

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

  /*define buffer buf_{1} for ub.{1} .*/

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
     ,input SHARE-LOCK
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
  if v-tbl-row = ? then do:

  end.
  else do:
    glog = v-bh:find-by-rowid( v-tbl-row, exclusive-lock ) no-error.

    if error-status:error then do:
      undo, return  error substitute( "&1. Ошибка при поиcке записи &2 в БД  &3&4&5", p-table-name, vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
    end.

    glog = v-bh:disable-load-triggers( yes ).

    glog = v-bh:buffer-delete() no-error.
    if error-status:error then do:
      undo, return  error substitute( "&1. Ошибка при удалении записи &2 в БД  &3&4&5", p-table-name, vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.

  glog = v-temp-bh:buffer-delete() no-error.

  delete object v-temp-bh.
  delete object v-bh.

end.