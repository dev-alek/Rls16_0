block-level on error undo, throw.
/*

$Revision: 41c4ffaaf087, 1404, rls $
$Author: DARuban $
$Date: Thu Jun 28 15:24:34 2018 +0300 $
$Workfile: printvsd.p $
$Archive: rep/printvsd.p $

Отчет ВСД

Автор: Рубан Дмитрий Андреевич
Дата создания: 31/05/2018
Author: Ruban Dmitriy
Creation date: 31/05/18

Ruban

*/
DEFINE VARIABLE vss-revision AS CHARACTER NO-UNDO INIT "$Revision: 41c4ffaaf087, 1404, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: DARuban $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Thu Jun 28 15:24:34 2018 +0300 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: printvsd.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/printvsd.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет ВСД".  

{rep/r-statusvsd.p &only_print = YES     }  
