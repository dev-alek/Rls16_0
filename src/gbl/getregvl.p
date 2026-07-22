block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getregvl.p $
$Archive: gbl/getregvl.p $

Получение значения записи в registry

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/04
Author: Bakhtadze Natalya
Creation date: 05/27/04

*/

define input parameter p-section0 as character no-undo .
define input parameter p-section1 as character no-undo .
define input parameter p-section2 as character no-undo .
define input parameter p-variable as character no-undo .
define output parameter p-found  as logical no-undo .
define output parameter p-value as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getregvl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getregvl.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

/*например для*/
/*HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Excel\Security переменная Level*/
/*p-section0 = "HKEY_CURRENT_USER"*/
/*p-section1 = "SOFTWARE"*/
/*p-section2 = "Microsoft\Office\9.0\Excel\Security"*/
/*p-variable = "Level"*/

define variable regValueNames as char format "x(25)" no-undo.
define variable regValue as char format "x(50)" extent 100 no-undo.
define variable i as int no-undo.
define variable k as int no-undo.

do
on error undo, return error
:

  load p-section1 base-key p-section0.
  use p-section1 .
  get-key-value section p-section2
  key ""
  value regValueNames.
  if regValueNames = ""
  or regValueNames = ?
  then do:
    unload p-section1.
    return . /*substitute("Unable to Retrieve Registry Entries  &1 &2 &3 &4", p-section0, p-section1, p-section2, p-variable)*/
  end.
  assign
  p-found = yes
  .
  do i = 1 to num-entries(regValueNames):
    get-key-value section p-section2
    key entry(i,regValueNames)
    value regValue[i].
    if entry(i,regValueNames) = p-variable then do:
      assign
      p-value = regValue[i]
      .
    end.
  end.
  unload p-section1 no-error.

end. /*doe*/