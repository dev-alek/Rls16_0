block-level on error undo, throw.
/*

$Revision: cb37b650f92a, 1185, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:20:27 2017 +0300 $
$Workfile: typl-ad.p $
$Archive: ref/typl-ad.p $

Обёртка для использования процедур из ref/typl-ad.i в классах 

Автор: Молотков Сергей Михайлович
Дата создания: 01/11/17
Author: Molotkov Sergey
Creation date: 01/11/17

*/
define variable vss-revision    as character no-undo init "$Revision: cb37b650f92a, 1185, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:20:27 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: typl-ad.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/typl-ad.p $":U .
define variable vss-description as character no-undo init "Процедуры довавления и удаления типов прайс-листов".

{ cmp/str-glbl.i } /* {&pdf-new} */
{ ref/typl-ad.i }
{ ref/obji-ad.i }