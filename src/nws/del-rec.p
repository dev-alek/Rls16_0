block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: del-rec.p $
$Archive: nws/del-rec.p $

удаление записи в базе данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/23/05
Author: Dmitry Ukhanov
Creation date: 08/23/05

*/

define input parameter p-del-key-rec as character no-undo .
define input parameter p-find-msg    as logical   no-undo . /* обязательно ли должна существовать записть? */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-rec.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/del-rec.p $":U .
define variable vss-description as character no-undo init "удаление записи в базе данных".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/key-rec.i  }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-tbl-name  as character no-undo .
  define variable v-tbl-row   as row       no-undo .
  define variable bh_tbl-name as handle    no-undo .
  define variable v-deleted   as logical   no-undo .
  define variable v-rec-av    as logical   no-undo .
  define variable v-msg       as character no-undo .

  assign
    v-rec-av  = true
    v-deleted = false
    v-msg     = "":U
  .
  run gen-row-keyr in this-procedure
    ( input p-del-key-rec
     ,input ?
     ,input "ub":U
     ,input ?
     ,input share-lock
     ,output v-tbl-row
     ,output v-tbl-name
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при поиске записи по уникальному ключу &2.&3&4&3&5"
                             ,vss-workfile
                             ,p-del-key-rec
                             ,{&new-line}
                             ,return-value
                             ,error-status :get-message ( error-status :num-messages )
                           ).
  end.

  create buffer bh_tbl-name for table "ub.":U + v-tbl-name .

  bh_tbl-name:find-by-rowid( v-tbl-row, exclusive-lock ) no-error .

  if bh_tbl-name:available then do:
    assign
      v-deleted = bh_tbl-name:buffer-delete() no-error
    .
    if error-status :error
      or v-deleted = false
    then do:
      assign
        v-msg     = substitute( "&1&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  )
        v-deleted = false

      .
    end.
  end.
  else do:
    assign
      v-rec-av  = false
      v-msg     = substitute( "&1. Не найдена запись таблицы по ключу &2", vss-workfile, p-del-key-rec )
      v-deleted = false
    .
  end.

  delete object bh_tbl-name.

  if v-deleted = true then do:
    return .
  end.
  else do:
    if p-find-msg = true
      or v-rec-av = true
    then do:
      return error v-msg .
    end.
    else do:
      return .
    end.
  end.

end.

/* $Workfile: del-rec.p $ end */