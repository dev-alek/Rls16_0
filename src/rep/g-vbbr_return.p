block-level on error undo, throw.
/*

$Revision: a1ed8c2d04de, 2149, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:23:55 2019 +0300 $
$Workfile: g-vbbr_return.p $
$Archive: rep/g-vbbr_return.p $

Отчет для контроля возвратных операций

Автор: Кабоев Валерий Асланович
Дата создания: 19/09/12
Author: Kaboev Valeriy
Creation date: 19/09/12

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision: a1ed8c2d04de, 2149, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: EShklyar $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Wed Dec 25 15:23:55 2019 +0300 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: g-vbbr_return.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/g-vbbr_return.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет для контроля возвратных операций".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page0.i new }
/*{ cmp/library.i }
{ cmp/r-page0.i new } */ /* определения для стандартной формы отчетов -часть независящая от БД*/

RUN rep/d-report.w (
  INPUT parparentproc
  ,INPUT 'rep/e-vbbr-return.w'
  ,INPUT ('Отчет для контроля возвратных операций')
  ,INPUT 4
  ,INPUT ""
  ,INPUT "*"
  ,INPUT ""
  ,INPUT ""
  ,INPUT ""
  ,INPUT no).