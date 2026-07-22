block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rpm-grpr.p $
$Archive: utl/rpm-grpr.p $

Группы ORACLE RETAIL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/21/09
Author: Bakhtadze Natalya
Creation date: 02/21/09

*/

define input  parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rpm-grpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rpm-grpr.p $":U .
define variable vss-description as character no-undo init "Группы ORACLE RETAIL".
{ cmp/vssrevis.i }

define variable v-rid-list as character no-undo .
run utl/rpm-ggr.w ( input parparentproc
                   ,input '' /*bttns*/
                   ,input '' /*p-list-mode*/
                   ,input-output v-rid-list) no-error.
