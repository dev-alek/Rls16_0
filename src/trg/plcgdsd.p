block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории товара на складском месте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-pl-gds.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление истории товара на складском месте":U.

/* Global, Shared, Preprocessor Definitions ---                         */
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.c-pl-gds.obj-type
                         , ub.c-pl-gds.obj-code
                         , ub.c-pl-gds.pl-code
                         , ub.c-pl-gds.gds-code
                         , ub.c-pl-gds.chip-num
                         ) " }
{ cmp/str-glbl.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись истории товара на складском месте"
  view-as alert-box error .
  undo main-block, return error .



end. /* Main-Block */