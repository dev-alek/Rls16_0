block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-salest.p $
$Archive: rep/g-salest.p $

Отчет структура продаж по поставщикам (старт)

Автор: Белоусов Илья Александрович
Дата создания: 05/27/08
Author: Ilia Belousov
Creation date: 05/27/08

Input:

Output:

*/
define input  parameter parparentproc      as widget-handle no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-salest.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-salest.p $":U .
define variable vss-description as character no-undo init "Отчет структура продаж по поставщикам (старт)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i new }

do
on error undo, return error
:
   run rep/d-report.w
      ( input parparentproc                     /* 0 */
      , input 'rep/e-salest.w'                      /* 1 */
      , input "Cтруктура продаж по поставщикам" /* 2 */
      , input 5                                 /* 3 */
      , input "{&g-grp}"                        /* 4 */
      , input "{&o-currency},{&o-all},{&o-choice}"            /* 5 */
      , input ""                                /* 6 */
      , input ""                                /* 7 */
      , input "{&Excel-yes},{&Arc-stk-yes},{&Arc-supp-yes}"                    /* 8 */
      , input NO                                /* 9 */
      ).
end.