block-level on error undo, throw.
/*

$Revision: 5d506dbcaae6, 2911, rls $
$Author: EShklyar $
$Date: Пн ноя 22 19:49:14 2021 +0300 $
$Workfile: g-chk_return.p $
$Archive: rep/g-chk_return.p $

Очет по возвратным операциям

Автор: Кабоев Валерий Асланович
Дата создания: 19/09/12
Author: Kaboev Valeriy
Creation date: 19/09/12

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision: 5d506dbcaae6, 2911, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: EShklyar $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Пн ноя 22 19:49:14 2021 +0300 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: g-chk_return.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/g-chk_return.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Очет по возвратным операциям".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page0.i new }
/*{ cmp/library.i }
{ cmp/r-page0.i new } */ /* определения для стандартной формы отчетов -часть независящая от БД*/

RUN rep/d-report.w (
  INPUT parparentproc
  ,INPUT 'rep/e-chk_return.w'
  ,INPUT ('Отчет по возвратным операциям')
  ,INPUT 4
  ,INPUT ""
  ,INPUT "*"
  ,INPUT ""
  ,INPUT ""
  ,INPUT ""
  ,INPUT no).