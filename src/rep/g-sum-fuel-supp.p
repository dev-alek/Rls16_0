block-level on error undo, throw.
/*

$Revision: da45aef95689, 3499, rls $
$Author: ARostovtsev $
$Date: 2023/10/16 15:13:36 $
$Workfile: g-sum-fuel-supp.p $
$Archive: rep/g-sum-fuel-supp.p $

Сводный отчёт по поставкам топлива


*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions */
define input parameter parparentproc as widget-handle no-undo.

define variable vss-revision    as character no-undo initial "$revision: 9 $":u.
define variable vss-author      as character no-undo initial "$author: pervakov $":u.
define variable vss-date        as character no-undo initial "$date: 26.02.06 18:26 $":u.
define variable vss-workfile    as character no-undo initial "$workfile: g-ptrlot.p $":u.
define variable vss-archive     as character no-undo initial "$archive: /ver15_0/rep/g-sum-fuel-supp.p $":u.
define variable vss-description as character no-undo initial "Сводный отчёт по поставкам топлива":u.
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i  NEW }

  run rep/d-report.w
( input parparentproc ,
  input "rep/e-sum-fuel-supp.w":u ,
  input "Сводный отчёт по поставкам топлива":u ,
  input 10 ,
  input "":u,
  input "{&o-currency},{&o-choice},!{&o-all}":u,
  input "":u,
  input "":u,
  input "all,{&Excel-yes}":u,
  input no
  ) no-error .
  if error-status:error then
  message
    vss-workfile vss-revision vss-description skip
    error-status:get-message(1) skip
    return-value skip
    "Ошибка вызова"
    view-as alert-box error
  .
