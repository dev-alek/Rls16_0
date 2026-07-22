block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmddltrg.p $
$Archive: cmp/cmddltrg.p $

Удаление записи с отключением триггеров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/02/06
Author: Bakhtadze Natalya
Creation date: 05/02/06

*/

define input parameter p-imp-handle as handle    no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-key-rec as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmddltrg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/cmddltrg.p $":U .
define variable vss-description as character no-undo init "Удаление записи с отключением триггеров".

{ cmp/vssrevis.i "substitute('&1':u,p-key-rec)" }
{ cmp/trg-def.i }
{ gbl/key-rec.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define temp-table temp-{1}    no-undo like ub.{1} .

  define buffer buf_{1} for ub.{1} .

  define variable v-tbl-row  as rowid     no-undo.
  define variable v-tbl-name as character no-undo.

  create temp-{1} .

  run nws-impl in p-imp-handle
    ( input "{1}":U
     ,input (buffer temp-{1}:handle)
    ) no-error.
  if error-status :error then do:
    return error return-value .
  end.


  if p-key-rec = '':U then do:
    run gen-key-rec in this-procedure
      ( input  "{1}"
        ,input  buffer temp-{1}:handle
        ,output p-key-rec
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при генерации опущенного уникального ключа для таблицы &2.&3&4&3&5"
                              ,vss-workfile
                              ,"{1}"
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

  if v-tbl-name <> "{1}":U then do:
    return error substitute( "&1. Уникальный ключ &2 не соответствует принимаемой записи &3"
                             ,vss-workfile
                             ,p-key-rec
                             ,"{1}":U
                           ).
  end.
  if v-tbl-row = ? then do:

  end.
  else do:
    find first buf_{1} exclusive-lock
      where rowid( buf_{1} ) = v-tbl-row
      no-error .

    on delete of ub.{1} override do: end.

    delete buf_{1} .
  end.

  delete temp-{1}.

end.