block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prepemul.p $
$Archive: cmp/prepemul.p $

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/04/07
Author: Bakhtadze Natalya
Creation date: 04/04/07

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prepemul.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/prepemul.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
define output parameter p-string as character no-undo .
define variable v-date as date no-undo .
define variable v-decimal as decimal no-undo .
define variable v-integer as integer no-undo .
define variable v-logical as logical no-undo .
assign
v-date = date({1}) no-error .
if not error-status:error then do:
  p-string = {1}.
  return.
end.
assign
v-decimal = decimal({1}) no-error .
if not error-status:error then do:
  p-string = {1}.
  return.
end.
assign
v-integer = integer({1}) no-error .
if not error-status:error then do:
  p-string = {1}.
  return.
end.
p-string = substitute("'&1'", {1}).
