block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: staffr.p $
$Archive: ref/staffr.p $

Толкач для вызова справочника персонала из m_e_n_u.txt и лдругих мест

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/06
Author: Bakhtadze Natalya
Creation date: 06/30/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-option as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: staffr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/staffr.p $":U .
define variable vss-description as character no-undo init "Толкач для вызова справочника персонала из m_e_n_u.txt и других мест".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

define variable v-role as character no-undo .
define variable v-db-num as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-ri-list as character no-undo .
define variable v-bttns as character no-undo .
define buffer buf_db for ub.db.
define buffer buf2_db for ub.db.

if p-option = 'allcashiers':U
or p-option = 'curdbcashiers':u then do:
  v-role = {&role-cashier}.
end.
if p-option = 'allsellers':U
or p-option = 'curdbsellers':u then do:
  v-role = {&role-seller}.
end.
{ gbl/curdbnum.i
  v-current-db-num
}

find buf_db no-lock
  where buf_db.db-num = v-current-db-num
   .
if p-option = 'allcashiers':U
or p-option = 'allsellers':U then do:
  v-db-num = ?.
end.
if p-option = 'curdbcashiers':U
or p-option = 'curdbsellers':U then do:
  v-db-num = v-current-db-num.
end.
if buf_db.add-clients
or not (can-find(first ub.db no-lock where ub.db.db-num > 0)) then do:
  v-bttns = 'b-add'.
end.
else do:
  if buf_db.db-num = 0
  and buf_db.add-clients = no then do:
    /*для ora - режим синхро*/
    for each buf2_db no-lock:
      if buf2_db.add-clients then do:
        leave.
      end.
    end.
    if not available buf2_db then do:
      v-bttns = 'b-add'.
    end.
  end.
end.

    run ref/staffs.w (
                      input parparentproc
                , input v-bttns
                    , input v-role
                    , input v-db-num
                    , input 0
                , output v-ri-list) no-error .