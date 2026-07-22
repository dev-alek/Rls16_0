block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-segm.p $
$Archive: rep/g-segm.p $

Сегментация клиентов по возрасту и/или полу

Автор: Кабоев Валерий Асланович
Дата создания: 19/09/12
Author: Kaboev Valeriy
Creation date: 19/09/12

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: expertek $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: g-segm.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/g-segm.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Сегментация клиентов по возрасту и/или полу".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page0.i new }
/*{ cmp/library.i }
{ cmp/r-page0.i new } */ /* определения для стандартной формы отчетов -часть независящая от БД*/

RUN rep/d-report.w (
                            INPUT parparentproc
                            ,INPUT 'rep/e-segm.w'
                            ,INPUT ('Продажи  по ДК с сегментацией клиентов')
                            ,INPUT 2
                            ,INPUT "{&g-all},{&g-grp},{&g-choice},{&g-one}"
                            ,INPUT "*"
                            ,INPUT ""
                            ,INPUT ""
                            ,INPUT "{&excel-yes}"
                            ,INPUT NO).