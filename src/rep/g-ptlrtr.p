block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-ptlrtr.p $
$Archive: rep/g-ptlrtr.p $

Главная программа запуска отчета r-ptlrtr.p из меню

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

*/

define input parameter parParentProc as widget-handle no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: g-ptlrtr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/g-ptlrtr.p $":U .
define variable vss-description as character no-undo initial "Главная программа запуска отчета r-ptlrtr.p из меню":U .

{ cmp/str-glbl.i     }
{ cmp/vssrevis.i     }
{ cmp/r-page1.i  new }

&scop ttl "                           Р Е Е С Т Р  Н А  Н Е Ф Т Е П Р О Д У К Т Ы  З А  П Е Р И О Д "
run rep/d-report.w ( input parParentProc ,
                 input 'rep/e-ptlrtr.p',
                 input {&ttl},
                 input 5,
                 input "{&g-one}",
                 input "{&o-currency},{&o-choice}",
                 input "",
                 input "",
                 input "all",
                 input yes ).