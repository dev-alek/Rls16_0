block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: m-kfsale.p $
$Archive: rep/m-kfsale.p $

ручной толкач Отчет Реализация топлива (Кедр)

Автор: Хныкин Павел Андреевич
Дата создания: 04/22/09
Author: Pavel Khnykin
Creation date: 04/22/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: m-kfsale.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/m-kfsale.p $":U .
define variable vss-description as character no-undo init "ручной толкач Отчет Реализация топлива (Кедр)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }


do
on error undo, return error return-value
:
  run rep/r-kfsale.p ( input my-handle
                     , input no
                     , input x-date-Start
                     , input x-Shift-Start
                     , input x-date-End
                     , input x-Shift-End
                     , input ?
                     , input ?
                     ) no-error.
                     
  if return-value <> "" and return-value <> ? then do:
    message return-value + ". Продолжение не возможно!".
    return error return-value.
  end.
end.