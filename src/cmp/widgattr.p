block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: widgattr.p $
$Archive: cmp/widgattr.p $

Записать или считать значение атрибута

Автор: Перваков Михаил Сергеевич
Дата создания: 03/02/06
Author: Mikhail Pervakov
Creation date: 03/02/06

{1} имя атрибута

*/


define input  parameter h-widget         as handle    no-undo .
define output parameter p-attr-value     as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: widgattr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/widgattr.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }


do
on error undo, return error return-value
:
  assign
    p-attr-value = string(h-widget :{1})
  .
end.