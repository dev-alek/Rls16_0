block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-sertif.p $
$Archive: rep/g-sertif.p $

Отчет по сертификатам (скидкам)

Автор: Шальнев Иван Сергеевич
Дата создания: 31/05/11
Author: Shalnev ivan
Creation date: 31/05/11

*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-sertif.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-sertif.p $":U .
define variable vss-description as character no-undo init "Отчет по сертификатам (скидкам)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW}
run rep/d-report.w (
input parParentProc ,
input                   "rep/e-sertif.w",
input                   "Отчет по сертификатам (скидкам)",
input                   2,
input                   "":U,
input                   "{&o-currency},{&o-choice}":U,
input                   "",
input                   "{&v-rubl},{&v-base}",
input                   "{&Excel-yes}",
input                   no).