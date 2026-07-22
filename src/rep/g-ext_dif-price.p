block-level on error undo, throw.
/*

$Revision: 495edabb7f9c, 2163, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:23:56 2019 +0300 $
$Workfile: g-ext_dif-price.p $
$Archive: rep/g-ext_dif-price.p $

Отчет по изменению учетных цен

Автор: Шкляр Елена
Дата создания: 19/09/12
Author: Kaboev Valeriy
Creation date: 19/09/12

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision: 495edabb7f9c, 2163, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: EShklyar $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Wed Dec 25 15:23:56 2019 +0300 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: g-ext_dif-price.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/g-ext_dif-price.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет по изменению учетных цен".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/trg-def.i  }
{ cmp/r-page0.i new }
  
RUN rep/d-report.w (
  INPUT parparentproc
  ,INPUT 'rep/r-ext_dif-price.p'
  ,INPUT ('Отчет по изменению учетных цен')
  ,INPUT 4
  ,INPUT ""
  ,INPUT "*"
  ,INPUT ""
  ,INPUT ""
  ,INPUT ""
  ,INPUT yes).
