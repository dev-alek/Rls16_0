block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 28 окт. 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 28 окт. 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ gbl/userobjs.i }
define input        parameter parparentproc     as widget-handle no-undo .
define input-output  parameter table for userobjs_temp-user-obj   .
define input        parameter i-bttns             as character     no-undo . /* список включенных кнопок */
define input        parameter i-list-mode       as character     no-undo.
/*{&all} {&db} {&company} "cli-type"*/
define input        parameter i-obj-type        as character     no-undo.
define input        parameter i-db-num          as integer       no-undo.
define input        parameter i-host-code       as integer       no-undo.
define input-output parameter p-rid-list        as character     no-undo .
run thobjs in this-procedure 
(parparentproc,i-bttns,i-list-mode,i-obj-type,i-db-num,i-host-code, input-output p-rid-list).
