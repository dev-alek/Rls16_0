block-level on error undo, throw.
/*

$Revision: 6a63bd75f17f, 234, rls $
$Author: EShklyar $
$Date: Tue Jul 28 13:39:50 2015 +0400 $
$Workfile: g-activ.p $
$Archive: rep/g-activ.p $

Сегментация клиентов по возрасту и/или полу

Автор: Кабоев Валерий Асланович
Дата создания: 19/09/12
Author: Kaboev Valeriy
Creation date: 19/09/12

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision: 6a63bd75f17f, 234, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: EShklyar $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Tue Jul 28 13:39:50 2015 +0400 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: g-activ.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/g-activ.p $":U .
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
                            ,INPUT 'rep/e-activ.w'
                            ,INPUT ('Отчёт по активности клиентов')
                            ,INPUT 2
                            ,INPUT "{&g-all},{&g-grp},{&g-choice},{&g-one}"
                            ,INPUT "*"
                            ,INPUT ""
                            ,INPUT ""
                            ,INPUT "{&excel-yes}"
                            ,INPUT NO).