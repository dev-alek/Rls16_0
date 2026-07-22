block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fnamegrp.p $
$Archive: str/fnamegrp.p $

Полное название группы

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fnamegrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fnamegrp.p $":U .
define variable vss-description as character no-undo init "Полное название группы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ ref/grplibfn.i }

define input  parameter v-node-code as integer      no-undo.
define output parameter v-full-name as character    no-undo.

do
on error undo, return error return-value
:
    run grplib-get-full-name in this-procedure (
          input  v-node-code
        , output v-full-name
    ).
end.