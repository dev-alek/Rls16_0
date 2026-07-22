block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: init-chk.p $
$Archive: adm/init-chk.p $

Процедура проверки того, что БД пуста

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: init-chk.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/init-chk.p $":U .
def var vss-description as character no-undo init "Процедура проверки того, что БД пустая".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define variable bh_tbl-name as handle  no-undo .
  define variable v-ok        as logical no-undo .

  for each dictdb._file no-lock
    where dictdb._file._hidden = false
  on error undo, return error
  :
    create buffer bh_tbl-name for table "dictdb.":U + dictdb._file._file-name .

    assign
      v-ok = bh_tbl-name:find-first( "":U, share-lock ) no-error
    .

    if bh_tbl-name:available
      and v-ok = true
    then do:
      return error substitute( "&1. Таблица &2 не пустая!!!", vss-workfile, dictdb._file._file-name ).
    end.

    delete object bh_tbl-name.

  end.
end.

return.

/* $Workfile: init-chk.p $ end */