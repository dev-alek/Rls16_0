block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findlock.p $
$Archive: gbl/findlock.p $

Возвращает информацию пользователях, заблокировавших запись

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/10/03

*/

{ gbl/findlock.i }
define input  parameter p-recid  as recid     no-undo .
define output parameter table for temp-lock .


define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: findlock.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/findlock.p $":U .
define variable vss-description as character no-undo initial "Возвращает информацию и пользователе и транзакции, заблокировавшей запись".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-find-lock    as character no-undo .
define variable v-find-trans   as character no-undo .
define variable v-find-connect as character no-undo .

do
on error undo, return error return-value
:
  if p-recid = ?
  then do:
    return .
  end.

  run gbl/findlk.p
    (input  p-recid
    ,output table temp-lock
    ) .

  for each temp-lock
  :
    if temp-lock.lock-conn-id <> 0
    then do:
      run gbl/findtrns.p
        (input  temp-lock.lock-conn-id
        ,output temp-lock.trans-id
        ,output temp-lock.trans-txtime
        ,output temp-lock.trans-state
        ,output temp-lock.trans-dur
        ) .

      run gbl/findconn.p
        (input  temp-lock.lock-conn-id
        ,output temp-lock.connect-type
        ,output temp-lock.connect-time
        ,output temp-lock.connect-device
        ) .
    end.
  end.
end.