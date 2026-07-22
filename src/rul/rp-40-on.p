block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка при включении профайла 40 - импорт документов из Oracle Retail

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/23/09
Author: Bakhtadze Natalya
Creation date: 02/23/09

*/

define input  parameter parparentproc as widget-handle no-undo .
define output parameter p-ok as logical   no-undo .
define output parameter p-mess as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка при включении профайла 40 - импорт документов из Oracle Retail".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_code-range for ub.code-range.

