block-level on error undo, throw.
/*

$Revision: db45e217bd31, 43, test $
$Author: SKiryxin $
$Date: Fri May 23 14:49:55 2014 +0400 $
$Workfile: fix-del-c-doc.p $
$Archive: utl/fix-del-c-doc.p $

Поправка поля corr-user-db-num на текущую базу.
Раньше всё время был 0 т.к. подцеплялось инитовое значение.
Триггеры не отключал, чтобы всё в новости ушло.

Автор: Кирюхин Сергей
Дата создания: 23/04/14
Author: SKiryxin
Creation date: 23/04/14

*/

define variable vss-revision    as character no-undo init "$Revision: db45e217bd31, 43, test $":U .
define variable vss-author      as character no-undo init "$Author: SKiryxin $":U .
define variable vss-date        as character no-undo init "$Date: Fri May 23 14:49:55 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fix-del-c-doc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fix-del-c-doc.p $":U .
define variable vss-description as character no-undo init "Поправка поля corr-user-db-num на текущую базу".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

for each c-trn-doc where c-trn-doc.is-del = yes:
    c-trn-doc.corr-user-db-num = g#db-num.
end.