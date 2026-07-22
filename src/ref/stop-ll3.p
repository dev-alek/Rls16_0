block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stop-ll3.p $
$Archive: ref/stop-ll3.p $

Удаление строки стоплиста ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/08
Author: Bakhtadze Natalya
Creation date: 01/22/08

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stop-ll3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/stop-ll3.p $":U .
define variable vss-description as character no-undo init "Удаление строки стоплиста ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .
define buffer buf_stop-list for ub.stop-list.
define buffer buf_stop-list-line for ub.stop-list-line.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_stop-list-line exclusive-lock where
          recid(buf_stop-list-line) = p-rec.

  find first buf_stop-list exclusive-lock where
          buf_stop-list.stop-list-code = buf_stop-list-line.stop-list-code
      and buf_stop-list.classif-type = buf_stop-list-line.classif-type  no-error.
  if not available buf_stop-list then do:
    assign
    v-mess = substitute("Не найден стоплист"
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).

  end.
  if buf_stop-list.status_ <> {&g___new}
  then do:
    assign
    v-mess = substitute("Стоплист &1 находится в статусе &2, удаление невозможно"
                         , buf_stop-list-line.stop-list-code
                        ,  buf_stop-list.status_
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  delete buf_stop-list-line no-error.
  if error-status:error then do:
    assign
    v-mess = substitute("Ошибка при удалении  строки стоплиста&1&2&1&3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Строка стоплиста: стоплист ДК &1, карта &2&3"
                         , buf_stop-list-line.stop-list-code
                         , buf_stop-list-line.charkey_one
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