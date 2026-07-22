block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: about-db.p $
$Archive: gbl/about-db.p $

показ информации о текущей БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: about-db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/about-db.p $":U .
define variable vss-description as character no-undo init "показ информации о текущей БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_sys-ctrl for ub.sys-ctrl .

  find first buf_sys-ctrl .

  message
    "Текущая БД"                buf_sys-ctrl.db-num   skip
    "Системный ключ (sys-key)"  buf_sys-ctrl.sys-key  skip
    "Валюта БД (r-b)"           buf_sys-ctrl.r-b      skip
    "Язык БД (language)"        buf_sys-ctrl.language skip
    "Дата обрезания (cut-date)" buf_sys-ctrl.cut-date skip
    "Дата начала работы"        buf_sys-ctrl.sys-date skip
    view-as alert-box information .


end.