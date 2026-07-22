block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-plcsht.p $
$Archive: rep/g-plcsht.p $

Показания уровнемера за смену

Автор: Белоусов Илья Александрович
Дата создания: 09/12/07
Author: Ilia Belousov
Creation date: 09/12/07

Input:

Output:

*/
define input parameter parparentproc as widget-handle no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-plcsht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-plcsht.p $":U .
define variable vss-description as character no-undo init "Показания уровнемера за смену".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

do
on error undo, return error
:
run rep/d-report.w
    ( input parparentproc                     /* 0 */
    , input 'rep/r-plcsht.p'                      /* 1 */
    , input "Показания уровнемера за смену"   /* 2 */
    , input 7                                 /* 3 date 7 - одна смена */
    , input ""                                /* 4 */
    , input "{&o-currency}"                      /* 5 */
    , input ""                                /* 6 */
    , input ""                                /* 7 */
    , input "{&Excel-yes}"                    /* 8 */
    , input yes                               /* 9 */
    ).
end.