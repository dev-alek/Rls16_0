block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: icntdoc3.p $
$Archive: str/icntdoc3.p $

Удаление документа счетчиков ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/07
Author: Bakhtadze Natalya
Creation date: 07/16/07

*/

define input parameter p-rec as recid no-undo .
define input parameter p-silent as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: icntdoc3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/icntdoc3.p $":U .
define variable vss-description as character no-undo init "Удаление документа счетчиков ТРК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }

define variable v-mess as character no-undo .
define variable v-ptrlcheck as character no-undo .
define variable v-ii as integer no-undo .
define variable v-type as character no-undo .
define variable v-deleted as logical no-undo .
define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_icnt-line for ub.icnt-line.
define buffer buf_chk-doc for ub.chk-doc.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_icnt-doc exclusive-lock where
          recid(buf_icnt-doc) = p-rec .
  if buf_icnt-doc.status_ = {&fact} then do:
    v-mess = substitute("Невозможно удалить документ по счетчикам ТРК, закрытый до статуса &1"
               , buf_icnt-doc.status_
               ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo, return error (if p-silent = yes then v-mess else '':U).
  end.
  run waitfram-show in this-procedure ( input "Ждите.... " ).
  /*удалим записи словаря*/
  for each buf_icnt-line share-lock where
          buf_icnt-line.doc-code = buf_icnt-doc.doc-code
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
    delete buf_icnt-line.
  end.
  if buf_icnt-doc.doc-type = {&icnt-err} then do:
    for each buf_chk-doc exclusive-lock where
            buf_chk-doc.out-2-code = buf_icnt-doc.doc-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      assign
      buf_chk-doc.out-2-code = ?
      .
    end.
  end.

  delete buf_icnt-doc no-error.
  if error-status:error then do:
    run waitfram-hide in this-procedure .
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  run waitfram-hide in this-procedure .
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Документ по счетчикам ТРК &1 &2&3&4&5"
                         , buf_icnt-doc.doc-code
                         , buf_icnt-doc.obj-type
                         , buf_icnt-doc.obj-code
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