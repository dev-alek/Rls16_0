block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: shtwaidl.p $
$Archive: gbl/shtwaidl.p $

Удаление ожидаемой смены

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/21/07
Author: Bakhtadze Natalya
Creation date: 11/21/07

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shtwaidl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/shtwaidl.p $":U .
define variable vss-description as character no-undo init "Удаление ожидаемой смены".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-err-mess as character no-undo .
define variable v-host-code as integer no-undo .
define variable obj-db-num as integer no-undo .
define buffer buf_shift-obj for ub.shift-obj.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_shift-obj exclusive-lock where
        recid(buf_shift-obj) = p-rec .
  { gbl/objdbnum.i buf_shift-obj.obj-type buf_shift-obj.obj-code obj-db-num }
  if g#db-num <> obj-db-num then do:
    v-err-mess = substitute("Ожидаемую смену можно удалить только в БД объекта").
    run err-mess in this-procedure ( input-output v-err-mess) .
    undo main-block, return error (if p-silent then v-err-mess else '').
  end.
  if buf_shift-obj.status_ <> {&sht-expected} then do:
    v-err-mess = substitute("Удалить можно только Ожидаемую смену").
    run err-mess in this-procedure ( input-output v-err-mess) .
    undo main-block, return error (if p-silent then v-err-mess else '').
  end.
  delete buf_shift-obj no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при удалении :&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess) .
    undo main-block, return error (if p-silent then v-err-mess else '').
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("(Ожидамемая) Смена на объекте: &1&2 от &3 номер &4 порядок &5:&6&7"
                         , buf_shift-obj.obj-type
                         , buf_shift-obj.obj-code
                         , string(buf_shift-obj.shift-date, "99/99/9999")
                         , buf_shift-obj.shift-name
                         , buf_shift-obj.shift-num
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.