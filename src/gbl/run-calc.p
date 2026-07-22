block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: run-calc.p $
$Archive: gbl/run-calc.p $

Запуск калькулятора windows

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: run-calc.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/run-calc.p $":U .
def var vss-description as character no-undo init "Запуск калькулятора windows".
{ cmp/vssrevis.i }

do
on error undo, return error return-value
:
  run gbl/open_url.p ( "calc.exe" ).
end.