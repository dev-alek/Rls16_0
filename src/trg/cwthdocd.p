block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории по доку МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


TRIGGER PROCEDURE FOR DELETE OF ub.c-wth-doc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории док-та МЦ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                        ,ub.c-wth-doc.doc-code
                        ,ub.c-wth-doc.ext-doc-type
                        ,ub.c-wth-doc.status_
                        ,ub.c-wth-doc.corr-user-db-num
                        ,ub.c-wth-doc.chip-num)" }
{ cmp/trg-def.i }


/*main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ДОКУМЕНТА МЦ "  skip
  "Номер документа "   c-wth-doc.doc-code
  view-as alert-box error .
  undo main-block, return error .
end.   */