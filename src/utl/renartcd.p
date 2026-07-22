block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: renartcd.p $
$Archive: utl/renartcd.p $

Генерация списка БД где неодходимо выполнить ren-art

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/05
Author: Dmitry Ukhanov
Creation date: 09/08/05

*/

define input  parameter p-action       as character no-undo .
define input  parameter p-uniq-key-rec as character no-undo .
define output parameter p-list-db      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: renartcd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/renartcd.p $":U .
define variable vss-description as character no-undo init "Генерация списка БД где неодходимо выполнить ren-art".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error undo, return error
:
  define buffer buf_db for ub.db .

  assign
    p-list-db = "":U .
  .
  for each buf_db no-lock
    where buf_db.db-num >= 0
  on error undo, return error
  :
    if p-list-db = "":U then do:
      assign
        p-list-db = string( buf_db.db-num ).
      .
    end.
    else do:
      assign
        p-list-db = p-list-db + {&comma-char} + string( buf_db.db-num ).
      .
    end.
  end.

end.

return.

/* $Workfile: renartcd.p $ end */