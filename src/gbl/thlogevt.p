block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: thlogevt.p $
$Archive: gbl/thlogevt.p $

Регистрация события Trade House

Автор: Перваков Михаил Сергеевич
Дата создания: 06/25/02
Author: Mikhail Pervakov
Creation date: 06/25/02

*/

define input  parameter p-server-name      as character no-undo .
define input  parameter p-vss-workfile     as character no-undo .
define input  parameter p-vss-revision     as character no-undo .
define input  parameter p-vss-parameters   as character no-undo .
define input  parameter p-extra-parameters as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: thlogevt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/thlogevt.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
do
on error undo, return error return-value
:
  define variable v-vss-event-suffix as character no-undo .
  if p-vss-workfile = ? then do:
    assign
      p-vss-workfile = '?'
    .
  end.
  if p-vss-revision = ? then do:
    assign
      p-vss-revision = '?'
    .
  end.
  if p-vss-parameters = ? then do:
    assign
      p-vss-parameters = '?'
    .
  end.
  if p-extra-parameters = ? then do:
    assign
      p-extra-parameters = '?'
    .
  end.


  if p-vss-parameters <> "" then do:
    assign
      v-vss-event-suffix = '_PARAM':U
    .
  end.
  if p-extra-parameters <> "" then do:
    assign
      v-vss-event-suffix = v-vss-event-suffix + '_EXTRA':U
    .
  end.
  if p-extra-parameters <> "" then do:
    assign
      p-vss-parameters = p-vss-parameters
                       + (if p-vss-parameters <> "" then "|" else "")
                       + p-extra-parameters
    .
  end.

  if num-entries(p-vss-workfile, " ") > 1 then do:
    assign
      p-vss-workfile = entry(2, p-vss-workfile, " ")
    .
  end.

  if num-entries(p-vss-revision, " ") > 1 then do:
    assign
      p-vss-revision = entry(2, p-vss-revision, " ")
    .
  end.


  run gbl/logevent.p
    (input p-server-name
    ,input 'TH15.0_':U + lc(p-vss-workfile) + '_':U + p-vss-revision + v-vss-event-suffix
    ,input p-vss-parameters
    ) .

end.