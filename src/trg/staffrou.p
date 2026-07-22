block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Маршрутизация  ПЕРСОНАЛА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/02/06
Author: Bakhtadze Natalya
Creation date: 07/02/06

*/

define input parameter p-db-num as integer no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-work-place as character no-undo .
define output parameter p-db-num-list as character no-undo .
define output parameter p-option as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Маршрутизация  ПЕРСОНАЛА".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-obj-db-num as integer no-undo .

do
on error undo, return error return-value
:
  if p-db-num = 0 then do:
    return.
  end.
  if p-db-num = - 1
  or p-host-code > 0
  then do:
    p-option = 'wsd':U.
  end.
  if p-db-num > 0 then do:
    if g#db-num = 0 then do:
      assign
      p-db-num-list = string(p-db-num).
    end.
    else do:
      p-db-num-list = string(0).
    end.
  end.
  if not (p-obj-type = '':U and p-obj-code = 0) then do:
    { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
    if v-obj-db-num  = 0 then do:
      return.
    end.
    else do:
      if g#db-num = v-obj-db-num then do:
        assign
        p-db-num-list = string(0).
      end.
      if g#db-num = 0 then do:
        assign
        p-db-num-list = string(v-obj-db-num).
      end.
    end.
  end.
end. /*doe*/


