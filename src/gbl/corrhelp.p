block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: corrhelp.p $
$Archive: gbl/corrhelp.p $

Корректировка html для help

Автор: Чернова Светлана Александровна
Дата создания: 10/09/06
Author: Svetlana Chernova
Creation date: 10/09/06

*/

define input  parameter h_current-procedure as handle    no-undo .

define variable v-start-level as integer   no-undo .

assign
  v-start-level = 2
.

define variable lok   as logical no-undo initial yes .

define variable vss-revision    as character no-undo .
define variable vss-author      as character no-undo .
define variable vss-date        as character no-undo .
define variable vss-workfile    as character no-undo .
define variable vss-archive     as character no-undo .
define variable vss-description as character no-undo .

if valid-handle(h_current-procedure)
and h_current-procedure :get-signature( 'vss-get-info':u ) <> ""
then do:
  run vss-get-info in h_current-procedure
    (output vss-revision
    ,output vss-author
    ,output vss-date
    ,output vss-workfile
    ,output vss-archive
    ,output vss-description
    ).

define variable v-workfile as character no-undo .
v-workfile = entry ( 2 , vss-workfile ,":" ) .
v-workfile = trim ( v-workfile , "$" ) .
v-workfile = trim ( v-workfile  ) .
v-workfile = trim ( v-workfile , ".w" ) .

os-command no-wait VALUE( substitute('start winword.exe C:\HELP_15ver\&1.htm' , v-workfile )) .
return .
end.


define variable level as integer no-undo .

assign
  level = v-start-level
.
repeat while program-name(level) <> ?:
  message
    level program-name(level) skip
    view-as alert-box buttons ok-cancel update lok .
  if not lok then do:
    return no-apply .
  end.
  assign
    level = level + 1
  .
end.