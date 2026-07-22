block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-alcpri.p $
$Archive: rep/g-alcpri.p $

Поставки алкогольной продукции

Автор: Хныкин Павел Андреевич
Дата создания: 12/29/05
Author: Pavel Khnykin
Creation date: 12/29/05

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-alcpri.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-alcpri.p $":U .
define variable vss-description as character no-undo init "Поставки алкогольной продукции".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new  }
run rep/d-report.w
    (
      input parParentProc ,
      input 'rep/e-alcpri.w',
      input "Поставки алкогольной продукции",
      input 2,
      input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U,
      input "*", /* {&o-currency} */
      input "",
      input "{&v-rubl},{&v-base}",
      input "all,{&Excel-yes},{&format-folder}",
      input no
    ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка вызова"
    view-as alert-box error
  .
end.