block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 9 марта 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 9 марта 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
define input  parameter SystemUser as ibs.th.file.asyncparam no-undo.
define input  parameter SystemPass as ibs.th.file.asyncparam no-undo.

find first user-login where user-login.user-id = g#userid no-lock no-error .
      
SystemUser:valueParam = if available user-login then user-login.user-login else g#userid.
release user-login.
SystemPass:valueParam = g#passwd.
if g#userid eq ""
then
   return error.
else
   return.

