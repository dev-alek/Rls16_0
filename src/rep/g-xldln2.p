block-level on error undo, throw.
/*

$Revision: 7a8b1f3857b8, 139, rls $
$Author: AShutilov $
$Date: Mon Feb 16 20:48:28 2015 +0400 $
$Workfile: g-xldln2.p $
$Archive: rep/g-xldln2.p $

Отчет по картам ЛНР

Автор: Соломко Дмитрий Владимирович
Дата создания: 17/01/14
Author: Bakhtadze Natalya
Creation date: 17/01/14

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 7a8b1f3857b8, 139, rls $":U .
define variable vss-author      as character no-undo init "$Author: AShutilov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:28 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-xldln2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-xldln2.p $":U .
define variable vss-description as character no-undo init "Отчет по типам скидки".

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
    , input "rep/e-xldln2.w"
    , input vss-description
    , input 4
    , input "{&g-all},{&g-choice},{&g-one}":U
    , input "*"
    , input ""
    , input ""
    , input "all":U
    , input no ).

end.