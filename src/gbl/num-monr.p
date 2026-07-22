block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: num-monr.p $
$Archive: gbl/num-monr.p $

¬озвращает им€ мес€ца

јвтор: —услов јлексей ёрьевич
ƒата создани€: 10/19/05
Author: Alexey Suslov
Creation date: 10/19/05

*/

def     input   parameter   MonthNumber     as  integer.    /* номер мес€ца */
def     output parameter   MonthName        as  char.    /* назв. мес€ца */

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: num-monr.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/num-monr.p $":U .
def var vss-description as character no-undo init "¬озвращает им€ мес€ца".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


case MonthNumber :
  when 1 then MonthName = "яЌ¬ј–я".
  when 2 then MonthName = "‘≈¬–јЋя".
  when 3 then MonthName = "ћј–“ј".
  when 4 then MonthName = "јѕ–≈Ћя".
  when 5 then MonthName = "ћјя".
  when 6 then MonthName = "»ёЌя".
  when 7 then MonthName = "»ёЋя".
  when 8 then MonthName = "ј¬√”—“ј".
  when 9 then MonthName = "—≈Ќ“яЅ–я".
  when 10 then MonthName = "ќ “яЅ–я".
  when 11 then MonthName = "ЌќяЅ–я".
  when 12 then MonthName = "ƒ≈ јЅ–я".
end.