block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Срабатывание промо-акции

Автор: Шкляр Елена
Дата создания: 19/09/12
Author: Shklyar Elena
Creation date: 19/09/12

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision$":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author$":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date$":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile$":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive$":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет по примененным скидкам на НП".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page0.i new }

RUN rep/d-report.w (
                            INPUT parparentproc
                            ,INPUT 'rep/e-refpromo.w'
                            ,INPUT ('Отчет по примененным скидкам на НП')
                            ,INPUT 4
                            ,INPUT ""
                            ,INPUT "*"
                            ,INPUT ""
                            ,INPUT ""
                            ,INPUT ""
                            ,INPUT NO).