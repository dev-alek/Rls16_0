block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stop-l3.p $
$Archive: ref/stop-l3.p $

Удаление стоплиста

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter p-rec as recid no-undo .
define input parameter p-silent as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stop-l3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/stop-l3.p $":U .
define variable vss-description as character no-undo init "Удаление стоплиста".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }

define variable v-mess as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_stop-list  for ub.stop-list.
define buffer buf_stop-list-line for ub.stop-list-line.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Данная процедура не может вызываться в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_stop-list exclusive-lock where
        recid(buf_stop-list) = p-rec .
  if buf_stop-list.status_ = {&fact} then do:
    v-mess = substitute("Стоплист &1 закрыт до статуса &2&3Удаление невозможно"
                        , buf_stop-list.stop-list-code
                        , buf_stop-list.status_
                        , {&new-line}
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  run waitfram-show in this-procedure ( input "Ждите... " ).
  for each buf_stop-list-line share-lock where
          buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
    v-ii = v-ii + 1.
    if v-ii modulo 10 = 0 then do:
      run waitfram-show in this-procedure ( input substitute("Ждите... удалено &1", v-ii) ).
    end.
    delete buf_stop-list-line.
  end.
  delete buf_stop-list.
  run waitfram-hide in this-procedure .
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Стоплист &1"
                         , buf_stop-list.stop-list-code
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
