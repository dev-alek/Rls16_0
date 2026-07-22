block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 27 окт. 2021 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 27 окт. 2021 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{cmp\str-glbl.i}
define output parameter oUser as character no-undo.
find first sys-ctrl no-lock no-error.
find first user-login no-lock
     where user-login.db-num     = sys-ctrl.db-num
       and user-login.status_    = {&uls-normal}
       and user-login.user-login = userid ("ub")
      no-error .
oUser = if avail user-login then user-login.user-id else userid ("ub").
