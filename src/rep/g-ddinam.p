block-level on error undo, throw.
/*

$Revision: 997f9ca4e096, 2689, rls $
$Author: DRuban $
$Date: Пт дек 18 18:16:05 2020 +0300 $
$Workfile: g-ddinam.p $
$Archive: rep/g-ddinam.p $

Движение денежных средств

Автор: Комаров Иван Сергеевич
Дата создания: 04/29/10
Author: Ivan Komarov
Creation date: 04/29/10

*/

define variable vss-revision    as character no-undo init "$Revision: 997f9ca4e096, 2689, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт дек 18 18:16:05 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-ddinam.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-ddinam.p $":U .
define variable vss-description as character no-undo init "Движение денежных средств".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.

{ cmp/str-glbl.i }

run rep/dreport.p (
                input parParentProc ,
                input 'ibs.th.rep.eddinam',"Движение денежных средств",
                input 4,
                input "",
                input "*",
                input "",
                input "",
                input "all,{&Excel-yes}",
                input no).
