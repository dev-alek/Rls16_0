block-level on error undo, throw.
/*

$Revision: 2a79bf27b012, 291, rls $
$Author: ASMorozov $
$Date: Tue Dec 01 19:11:26 2015 +0300 $
$Workfile: convsea.p $
$Archive: utl/convsea.p $

Конвертация сезонов в новый формат.

Автор: Морозов Александр Сергеевич
Дата создания: 10/08/13
Author: Svetlana Chernova
Creation date: 10/08/13

*/



define variable vss-revision    as character no-undo init "$Revision: 2a79bf27b012, 291, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:26 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: convsea.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/convsea.p $":U .
define variable vss-description as character no-undo init "Конвертация сезонов в новый формат.".

define variable v-year  as integer no-undo.
define variable v-ok    as logical no-undo.
define variable ii      as integer no-undo.

message
  "Конвертировать сезоны в новый формат?"
  view-as alert-box question buttons yes-no update v-ok .

if not v-ok then return.

for each ub.season exclusive-lock where ub.season.sea-month-1 > 0 and ub.season.sea-month-2 <= 12 :
  
  assign
    v-year = year (today)
    ub.season.sea-month-1 = integer (date (ub.season.sea-month-1, 01, v-year))
    ub.season.sea-month-2 = integer (date (if ub.season.sea-month-2 <> 12 then ub.season.sea-month-2 + 1 else 01, 01, if ub.season.sea-month-2 = 12 then v-year + 1 else v-year)) - 1
    ii = ii + 1
    .
end.


message substitute ("Готово. Удачно конвертировано сезон(а/ов) &1", ii) view-as alert-box information .
