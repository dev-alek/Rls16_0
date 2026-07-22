block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getprepv.p $
$Archive: cmp/getprepv.p $

Распознавание препроцессинга на ходу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/28/05
Author: Bakhtadze Natalya
Creation date: 11/28/05

*/

define output parameter p-prep-value as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getprepv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/getprepv.p $":U .
define variable vss-description as character no-undo init "Распознавание препроцессинга на ходу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

P-PREP-VALUE = "{1}".
