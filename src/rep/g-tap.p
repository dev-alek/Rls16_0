block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-tap.p $
$Archive: rep/g-tap.p $

ОТЧЕТ в виде формы ТАР1-ДО (разгонная ступень)

Автор: Белоусов Илья Александрович
Дата создания: 05/25/09
Author: Ilia Belousov
Creation date: 05/25/09

*/
define input parameter parparentproc     as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-tap.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-tap.p $":U .
define variable vss-description as character no-undo init "ОТЧЕТ в виде формы ТАР1-ДО".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page0.i "new" }
do
on error undo, return error
:
    run rep/d-report.w ( input parparentproc
                       , input "rep/e-tap.w":U
                       , input "Акт переоценки за период ТАП1-ДО":U
                       , input 4
                       , input "{&g-all},{&g-grp},{&g-choice},{&g-one}":U
                       , input "{&o-currency}":U
                       , input "":U
                       , input "":U
                       , input "all,{&Excel-yes},{&format-folder}":U
                       , input no
                       ) .
end.