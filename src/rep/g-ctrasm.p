block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-ctrasm.p $
$Archive: rep/g-ctrasm.p $

Запуск отчета "Контроль АМ"

Автор: Хныкин Павел Андреевич
Дата создания: 07/06/09
Author: Pavel Khnykin
Creation date: 07/06/09

*/
define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-ctrasm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-ctrasm.p $":U .
define variable vss-description as character no-undo init "Запуск отчета Контроль АМ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i      }
{ cmp/r-page1.i new   }

run rep/d-report.w
    ( input parParentProc
    , input 'rep/e-ctrasm.w'
    , input "Контроль ассортиментной матрицы":U
    , input 2
    , input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U /* {&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod} */
    , input "{&o-firm},{&o-currency},{&o-choice}"
    , input ""
    , input ""
    , input "all,all-object,{&Excel-yes},{&Arc-stk-yes},{&Arc-ot-yes},{&Arc-supp-yes}"
    , input no
    ).