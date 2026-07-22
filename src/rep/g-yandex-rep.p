block-level on error undo, throw.
/*

$Revision: 5335a0221b71, 2526, test $
$Author: SSlivenko $
$Date: Вт авг 04 12:57:17 2020 +0300 $
$Workfile: g-yandex-rep.p $
$Archive: rep/g-yandex-rep.p $

Утилита проверки целостности свободной зоны марок

Автор: Шкляр Елена
Дата создания: 07/30/08
Author: Shklyar Elena
Creation date: 07/30/08

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 5335a0221b71, 2526, test $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 04 12:57:17 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-yandex-rep.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-yandex-rep.p $":U .
define variable vss-description as character no-undo init "Сверка по транзакциям Яндекс".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

run rep/d-report.w
    ( input parparentproc
    , input 'rep/e-yandex-rep.w'
    , input "Сверка по транзакциям Яндекс":U
    , input 4 
    , input "":U
    , input "*"
    , input ""
    , input ""
    , input ""
    , input no
    ).