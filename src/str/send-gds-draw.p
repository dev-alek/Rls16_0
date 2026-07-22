block-level on error undo, throw.
/*

$Revision: 7b0cc5f31b3c, 1617, rls $
$Author: SSlivenko $
$Date: Tue Nov 06 04:41:38 2018 +0300 $
$Workfile: send-gds-draw.p $
$Archive: str/send-gds-draw.p $

Простая пересылка товаров на кассу по списку товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 7b0cc5f31b3c, 1617, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:38 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-gds-draw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-gds-draw.p $":U .
define variable vss-description as character no-undo init "Простая пересылка товаров на кассу по списку товаров":U.
{ cmp/vssrevis.i }
{cmp/str-glbl.i} 
{ cmp/library.i  } 
{str/imp2cd.i &imp2cd_parparentproc = parparentproc}
for each ub.goods no-lock:
    run fill-gds-list(buffer ub.goods).
end.
run send-to-cash.   