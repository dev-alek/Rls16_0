block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: m-kfreba.p $
$Archive: rep/m-kfreba.p $

Ручной толкатель отчета Реализация и остатки (Кедр)

Автор: Хныкин Павел Андреевич
Дата создания: 04/16/09
Author: Pavel Khnykin
Creation date: 04/16/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$date: $":u .
define variable vss-workfile    as character no-undo init "$Workfile: m-kfreba.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/m-kfreba.p $":U .
define variable vss-description as character no-undo init "Ручной толкатель отчета Реализация и остатки (Кедр)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }


do
on error undo, return error return-value
:
  run rep/r-kfreba.p ( input my-handle
                     , input no
                     , input ?
                     , input ?
                     ).
end.