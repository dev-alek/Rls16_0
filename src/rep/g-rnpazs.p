block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-rnpazs.p $
$Archive: rep/g-rnpazs.p $

Данные о реализации НП на АЗС за период (ТамбовНП)

Автор: Демин Алексей Сергеевич
Дата создания: 12/02/08
Author: Alexey Demin
Creation date: 12/02/08

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-rnpazs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-rnpazs.p $":U .
define variable vss-description as character no-undo init "Данные о реализации НП на АЗС за период (ТамбовНП)".
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
    , input "rep/r-rnpazs.p"
    , input "Данные о реализации НП на АЗС за период (ТамбовНП)":U
    , input 4
    , input "":U
    , input "*"
    , input ""
    , input ""
    , input "all":U
    , input yes ).

end.