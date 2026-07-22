block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление из справочника норм технологических потерь

Автор: Хныкин Павел Андреевич
Дата создания: 01/15/07
Author: Pavel Khnykin
Creation date: 01/15/07
*/

trigger procedure for delete of ub.norm-loss.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление из справочника норм технологических потерь".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

main-block:
 do on error  undo main-block , return error return-value
    on endkey undo main-block , return error return-value
    on stop   undo main-block , return error return-value
    :
      message
      vss-workfile vss-revision vss-description skip
      "Физическое удаление записи из справочника норм технологических потерь запрещен"
      view-as alert-box error .
      undo main-block, return error .
end.
