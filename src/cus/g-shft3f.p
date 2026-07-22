block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-shft3f.p $
$Archive: cus/g-shft3f.p $

Расшифровка реализации к сменному отчету

Автор: Кочетков Михаил Юрьевич
Дата создания: 10/10/07
Author: Michael Kochetkov
Creation date: 10/10/07

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-shft3f.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-shft3f.p $":U .
define variable vss-description as character no-undo init "Расшифровка реализации к сменному отчету".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i   new   }

run rep/d-report.w (
                 input parparentproc
                ,input 'cus/r-shft3f.p'
                ,input "Расшифровка реализации к сменному отчету"
                ,input 8
                ,input ""
                ,input "{&o-currency}"
                ,input ""
                ,input ""
                ,input ""
                ,input yes).