block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cuslabl3.p $
$Archive: utl/cuslabl3.p $

Удаление настраиваемого пол

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/07/07
Author: Bakhtadze Natalya
Creation date: 07/07/07

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cuslabl3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cuslabl3.p $":U .
define variable vss-description as character no-undo init "Удаление настраиваемого поля".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-mess as character no-undo .
define buffer buf_custom-labels  for dictdb.custom-labels.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /*удалим записи словаря*/
  find first buf_custom-labels exclusive-lock where
          recid(buf_custom-labels) = p-rec .
  delete buf_custom-labels no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("custom-label&1tbl-name=&2&1" +
                          "fld-name=&3&1" +
                          "call-type=&4&1" +
                          "call-point=&5&1" +
                          "language=&6&1&7"
                         , {&new-line}
                         , buf_custom-labels.tbl-name
                         , buf_custom-labels.fld-name
                         , buf_custom-labels.call-type
                         , buf_custom-labels.call-point
                         , buf_custom-labels.language
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


