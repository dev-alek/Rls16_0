block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-wthrst.p $
$Archive: rep/g-wthrst.p $

Текущие остатки серийных МЦ (стартовая ступень)

Автор: Белоусов Илья Александрович
Дата создания: 05/12/09
Author: Ilia Belousov
Creation date: 05/12/09

Input:

Output:

*/
define input  parameter       parparentproc      as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-wthrst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-wthrst.p $":U .
define variable vss-description as character no-undo init "Текущие остатки серийных МЦ (стартовая ступень)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  NEW }

do
on error undo, return error
:
    run rep/d-report.w ( input parparentproc
                       , input "rep/e-wthrst.w":U
                       , input "Текущие остатки серийных МЦ":U
                       , input 0
                       , input "":U
                       , input "{&o-all},{&o-currency},{&o-choice}":U
                       , input "":U
                       , input "":U
                       , input "all,{&Excel-yes}":U
                       , input no
                       ) .
end.