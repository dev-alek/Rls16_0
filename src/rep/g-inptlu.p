block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-inptlu.p $
$Archive: rep/g-inptlu.p $

Запуск отчета по приходу нефтепродуктов на АЗК (Украина)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 05/05/06
Author: Dmitry Ukhanov
Creation date: 05/05/06

*/

define input parameter p-parent-proc as widget-handle no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: g-inptlu.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/g-inptlu.p $":U .
define variable vss-description as character no-undo initial "Запуск отчета по приходу нефтепродуктов на АЗК (Украина)":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i  new }

run rep/d-report.w
  ( input p-parent-proc
  , input 'rep/r-inptlu.p'
  , input "Отчет по приходу нефтепродуктов на АЗК"
  , input 4
  , input "":U
  , input "{&o-choice}"
  , input "":U
  , input "":U
  , input "{&Excel-yes}"
  , input yes
  ) .
