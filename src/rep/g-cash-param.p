block-level on error undo, throw.
/*

$Revision: d3f7ea4aa09e, 3307, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:07 $
$Workfile: g-cash-param.p $
$Archive: rep/g-cash-param.p $

Отчет по анализу параметров АРМ Кассира

Автор: Шкляр Елена
Дата создания: 19/09/12
Author: Shklyar Elena
Creation date: 19/09/12

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision: d3f7ea4aa09e, 3307, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: DRuban $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: 2023/05/19 13:37:07 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: g-cash-param.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/g-cash-param.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет по анализу параметров АРМ Кассира".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page0.i new }
/*{ cmp/library.i }
{ cmp/r-page0.i new } */ /* определения для стандартной формы отчетов -часть независящая от БД*/

RUN rep/d-report.w (
                            INPUT parparentproc
                            ,INPUT 'rep/e-cash-param.w'
                            ,INPUT ('Отчет по анализу параметров АРМ Кассира')
                            ,INPUT 0
                            ,INPUT ""
                            ,INPUT "*"
                            ,INPUT ""
                            ,INPUT ""
                            ,INPUT ""
                            ,INPUT NO).