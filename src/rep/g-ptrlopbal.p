block-level on error undo, throw.
/*

$Revision: 0500dccfad42, 789, rls $
$Author: PGridchina $
$Date: Wed Sep 14 14:42:19 2016 +0300 $
$Workfile: g-ptrlopbal.p $
$Archive: rep/g-ptrlopbal.p $

Контрольно-накопительная ведомость учета излишек и недостач НП. Главная программа запуска отчета r-ptrlopbal.p из меню

Автор: Гридчина Полина Дмитриевна
Дата создания: 20/12/2014
Author: Polina Gridchina
Creation date: 20/12/2014

*/
define input  parameter parParentProc  as widget-handle no-undo.

def var vss-revision    as character no-undo init "$Revision: 0500dccfad42, 789, rls $":U .
def var vss-author      as character no-undo init "$Author: PGridchina $":U .
def var vss-date        as character no-undo init "$Date: Wed Sep 14 14:42:19 2016 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-ptrlopbal.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-ptrlopbal.p $":U .
def var vss-description as character no-undo init "Главная программа запуска Контрольно-накопительная ведомость учета излишек и недостач НП".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
run rep/d-report.w (


                input parParentProc ,
                input 'rep/e-ptrlopbal.w',
                input "Контрольно-накопительная ведомость учета излишек и недостач НП",
                input 8,
                input "{&g-choice}",
                input "{&o-currency}",
                input "",
                input "",
                input "all,{&Excel-yes}",
                input no).