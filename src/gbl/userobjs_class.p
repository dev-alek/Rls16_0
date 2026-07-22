block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 27 окт. 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 27 окт. 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ gbl/userobjs.i }
define input  parameter parparentproc        as widget-handle no-undo .
define input  parameter iProcname as character no-undo.
define input-output  parameter table for userobjs_temp-user-obj   .
define input  parameter p-db-num             as integer   no-undo .
define input  parameter p-user-id            as character no-undo .
define input  parameter p-curr-host-code-obj as integer   no-undo .
define input  parameter p-curr-obj-type      as character no-undo .
define input  parameter p-curr-obj-code      as integer   no-undo .
define output parameter p-user-select        as logical   no-undo .
define output parameter p-select-obj-type    as character no-undo .
define output parameter p-select-obj-code    as integer   no-undo .

if iprocname eq "userobjs_select-one"
then do:
   
   {gbl/uobjsone.i
      parparentproc 
      p-db-num   
      p-user-id
      p-curr-host-code-obj
      p-curr-obj-type
      p-curr-obj-code
      p-user-select
      p-select-obj-type
      p-select-obj-code
   }
end.
else if iprocname eq "userobjs_select-many"
then do:
   {gbl/uobjsman.i
      parparentproc
      p-db-num
      p-user-id
      p-curr-host-code-obj
      p-curr-obj-type
      p-curr-obj-code
      p-user-select
  
   }
end.
/*else*/