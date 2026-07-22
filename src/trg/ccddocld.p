block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории строки док-та на кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/07
Author: Bakhtadze Natalya
Creation date: 01/22/07

*/


TRIGGER PROCEDURE FOR DELETE OF ub.c-cd-doc-line.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории строки док-та на кассе".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                                    ,ub.c-cd-doc-line.obj-type
                                    ,ub.c-cd-doc-line.obj-code
                                    ,ub.c-cd-doc-line.pos-type
                                    ,ub.c-cd-doc-line.doc-type
                                    ,ub.c-cd-doc-line.doc-code
                                    ,ub.c-cd-doc-line.line-num
                                    ,ub.c-cd-doc-line.corr-user-db-num
                                    ,ub.c-cd-doc-line.chip-num
                                          ) " }

{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ строки документа на кассе"
  view-as alert-box error .
  undo main-block, return error .

end.