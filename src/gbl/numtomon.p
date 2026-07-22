block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: numtomon.p $
$Archive: gbl/numtomon.p $

Возвращает имя месяца

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

define  input   parameter   MonthNumber     as  integer.    /* номер месяца */
define  output parameter   MonthName        as  char.    /* назв. месяца */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: numtomon.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/numtomon.p $":U .
define variable vss-description as character no-undo init "Возвращает имя месяца".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

case MonthNumber :
  when 1 then MonthName = "ЯНВАРЬ".
  when 2 then MonthName = "ФЕВРАЛЬ".
  when 3 then MonthName = "МАРТ".
  when 4 then MonthName = "АПРЕЛЬ".
  when 5 then MonthName = "МАЙ".
  when 6 then MonthName = "ИЮНЬ".
  when 7 then MonthName = "ИЮЛЬ".
  when 8 then MonthName = "АВГУСТ".
  when 9 then MonthName = "СЕНТЯБРЬ".
  when 10 then MonthName = "ОКТЯБРЬ".
  when 11 then MonthName = "НОЯБРЬ".
  when 12 then MonthName = "ДЕКАБРЬ".
end.