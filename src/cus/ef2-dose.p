block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ef2-dose.p $
$Archive: cus/ef2-dose.p $

Определение допустимой дозы для EasyFuel2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/23/07
Author: Bakhtadze Natalya
Creation date: 12/23/07

*/

define input  parameter p-rid  as recid no-undo.
define output parameter p-dose as decimal no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ef2-dose.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ef2-dose.p $":U .
define variable vss-description as character no-undo init "Определение допустимой дозы для EasyFuel2".

define buffer buf_cd-doc for ub.cd-doc.

do:
  find first buf_cd-doc no-lock where recid(buf_cd-doc) = p-rid no-error.
  if available buf_cd-doc then p-dose = buf_cd-doc.DecKey_One - buf_cd-doc.DecKey_Two - buf_cd-doc.DecKey_Three.
  else p-dose = ?.
end.