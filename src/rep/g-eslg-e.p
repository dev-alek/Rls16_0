block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-eslg-e.p $
$Archive: rep/g-eslg-e.p $

Запуск отчета 'Расширеный оперативный (ежедневный) отчет по закончив. наименованиям'

Автор: Хныкин Павел Андреевич
Дата создания: 02/12/10
Author: Pavel Khnykin
Creation date: 02/12/10

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-eslg-e.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-eslg-e.p $":U .
define variable vss-description as character no-undo init "Запуск отчета 'Расширеный оперативный (ежедневный) отчет по закончив. наименованиям'".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

do
on error undo, return error return-value
:
  run rep/d-report.w ( input parParentProc
                     , input 'rep/e-eslg-e.w'
                     , input 'Расширеный оперативный (ежедневный) отчет по закончившимся наименованиям'
                     , input 1
                     , input ""
                     , input "{&o-currency}"
                     , input ""
                     , input ""
                     , input "all,{&Arc-stk-yes},{&Arc-ot-yes}"
                     , input no
                     ).
end.