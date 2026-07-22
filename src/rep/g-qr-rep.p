block-level on error undo, throw.
/*

$Revision: 903a40602d08, 2659, rls $
$Author: SSlivenko $
$Date: Пн ноя 02 16:18:16 2020 +0300 $
$Workfile: g-QR-rep.p $
$Archive: rep/g-QR-rep.p $

Утилита проверки целостности свободной зоны марок

Автор: Шкляр Елена
Дата создания: 07/30/08
Author: Shklyar Elena
Creation date: 07/30/08

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 903a40602d08, 2659, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 02 16:18:16 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-QR-rep.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-QR-rep.p $":U .
define variable vss-description as character no-undo init "Сверка по оплатам QR-кодом".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

run rep/d-report.w
    ( input parparentproc
    , input 'rep/e-QR-rep.w'
    , input "Сверка по оплатам QR-кодом":U
    , input 4 
    , input "":U
    , input "*"
    , input ""
    , input ""
    , input ""
    , input no
    ).