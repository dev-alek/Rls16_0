block-level on error undo, throw.
/*

$Revision: 30c64eb058c0, 144, rls $
$Author: AShutilov $
$Date: Mon Feb 16 20:49:06 2015 +0400 $
$Workfile: g-xldlnr.p $
$Archive: rep/g-xldlnr.p $

Детализированный отчет по бонусам и картам ЛНР

Автор: Соломко Дмитрий Владимирович
Дата создания: 10/02/2014 
Author: Solomko Dmitry
Creation date: 10/02/2014 
Переименован из отчёта: "Отчет по картам ЛНР" по ТН-3114 16.01.2015г Арн.
*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 30c64eb058c0, 144, rls $":U .
define variable vss-author      as character no-undo init "$Author: AShutilov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:49:06 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-xldlnr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-xldlnr.p $":U .
define variable vss-description as character no-undo init "Детализированный отчет по бонусам и картам ЛНР".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

do
on error undo, return error
:

assign
  my-handle = parparentproc
.

run rep/d-report.w
    ( input parparentproc
    , input "rep/e-xldlnr.w"
    , input vss-description
    , input 4
    , input "{&g-all},{&g-choice},{&g-one}":U
    , input "*"
    , input ""
    , input ""
    , input "all":U
    , input no ).

end.