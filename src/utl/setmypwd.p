block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 29 апр. 2019 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 29 апр. 2019 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "смена своего пароля".


find first _user exclusive-lock
           where _user._userid    = userid ("ub")
           no-error
           .
_User._Password = encode(session:parameter).