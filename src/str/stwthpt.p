block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stwthpt.p $
$Archive: str/stwthpt.p $

Процедура обработки партий по закрытию документов МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 06/18/07
Author: Polina Gridchina
Creation date: 06/18/07

Input:

Output:

*/

define input parameter parrec_wth-doc as recid   no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stwthpt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/stwthpt.p $":U .
define variable vss-description as character no-undo init "Процедура обработки партий по закрытию документов МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/wthparts.i }

define buffer buf_wth-doc      for wth-doc.
define buffer buf_wth-parts   for wth-parts.
def var v-rec as recid.


tr:
do transaction
on error undo tr,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop  undo tr,  return error substitute( "&1. stop", vss-workfile )
on quit  undo tr,  return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_wth-doc where recid(buf_wth-doc) = parrec_wth-doc no-error.
  if not available buf_wth-doc then do:
    return error
    "Неправильные входные параметры файла stwthpt.p. Указан record id документа материальных ценностей: " +
    string(parrec_wth-doc).
  end.

  for each buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code exclusive-lock
/*  on error undo tr, return error substitute( "&1. &2&3&4", 'Ошибка при обработке партий', return-value, {&new-line}, error-status :get-message (1))
  on stop  undo, return error substitute( "&1. stop", vss-workfile )
  on quit  undo, return error substitute( "&1. endkey", vss-workfile )   */
  :
    run wth-doc-close(input recid(buf_wth-parts) ) no-error.
    if error-status:error then undo tr, return error return-value + error-status:get-message(1).
  end.

end.