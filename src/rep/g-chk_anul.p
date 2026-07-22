block-level on error undo, throw.
/*

$Revision: dbdad9a0f884, 2613, rls $
$Author: EShklyar $
$Date: Пн окт 19 09:22:02 2020 +0300 $
$Workfile: g-chk_anul.p $
$Archive: rep/g-chk_anul.p $

Отчет по аннуляции строки/отмене товара

Автор: Шкляр Елена
Дата создания: 19/09/12
Author: Shklyar Elena
Creation date: 19/09/12

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision: dbdad9a0f884, 2613, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: EShklyar $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Пн окт 19 09:22:02 2020 +0300 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: g-chk_anul.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/g-chk_anul.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет по аннуляции строки/отмене товара".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page0.i new }
/*{ cmp/library.i }
{ cmp/r-page0.i new } */ /* определения для стандартной формы отчетов -часть независящая от БД*/

RUN rep/d-report.w (
  INPUT parparentproc
  ,INPUT 'rep/e-chk_anul.w'
  ,INPUT ('Отчет по аннуляции строки/отмене товара')
  ,INPUT 4
  ,INPUT ""
  ,INPUT "*"
  ,INPUT ""
  ,INPUT ""
  ,INPUT ""
  ,INPUT no).