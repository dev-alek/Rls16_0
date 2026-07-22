block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inidebug.p $
$Archive: gbl/inidebug.p $

Программа запуска отладчика из сессии PROGRESS

Автор: Перваков Михаил Сергеевич
Дата создания: 07/16/07
Author: Mikhail Pervakov
Creation date: 07/16/07

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inidebug.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/inidebug.p $":U .
define variable vss-description as character no-undo init "".
/* { cmp/vssrevis.i } */

define variable v-test as integer no-undo .

DEBUGGER:INITIATE().
DEBUGGER:VISIBLE = TRUE.

DEBUGGER:SET-BREAK().
/* please continue execution */
assign
  v-test = v-test + 1
.