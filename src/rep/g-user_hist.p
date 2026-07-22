block-level on error undo, throw.
/*

$Revision: bf04b0e5cfa2, 2256, rls $
$Author: druban $
$Date: Wed Dec 25 15:24:01 2019 +0300 $
$Workfile: g-user_hist.p $
$Archive: rep/g-user_hist.p $

Запуск отчета "История действий пользователей"

Автор: Хныкин Павел Андреевич
Дата создания: 07/06/09
Author: Pavel Khnykin
Creation date: 07/06/09

*/
define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: bf04b0e5cfa2, 2256, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:01 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-user_hist.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-user_hist.p $":U .
define variable vss-description as character no-undo init "История действий пользователей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i      }
{ cmp/r-page1.i new   }

/* run rep/d-report.w
    ( input parParentProc
    , input 'rep/e-user_hist.w'
    , input "История действий пользователей":U
    , input 2
    , input "":U /* {&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod} */
    , input "{&o-firm},{&o-currency},{&o-choice}"
    , input ""
    , input ""
    , input ""
    , input no
    ).  */


 run rep/dreport.p
    ( input parParentProc
    , input 'ibs.th.ref.sobj.userhist'
    , input "История действий пользователей"
    , input 2
    , input ""
    , input "{&o-firm},{&o-currency},{&o-choice}"
    , input ""
    , input ""
    , input ""
    , input no
    ).
  
