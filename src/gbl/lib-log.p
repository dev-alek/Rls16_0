block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lib-log.p $
$Archive: gbl/lib-log.p $

Библиотека процедур для работы log

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/16/09
Author: Bakhtadze Natalya
Creation date: 10/16/09

*/

using Ibs.Th.Rul.Route-data_.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lib-log.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/lib-log.p $":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы log":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/lib-log.i }

if valid-handle (g#lib-log)
and g#lib-log <> this-procedure :handle
and g#lib-log :get-signature('lib-log_clear-fill-option':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с GATE" skip
    g#lib-log skip
    g#lib-log :type skip
    g#lib-log :file-name skip
    valid-handle(g#lib-log) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-log = this-procedure :handle
  .
end.

define variable v-log-handle as handle no-undo .
v-log-handle = this-procedure:handle.

procedure lib-log_set-log-handle :
define input parameter p-log-handle as handle no-undo .
if valid-handle(p-log-handle)
and lookup("write-to-log", p-log-handle:internal-entries) > 0
then do:
 v-log-handle = p-log-handle.
end.
else do:
  v-log-handle = this-procedure:handle.
end.
end procedure. /* lib-log_set-log-handle */

procedure lib-log_get-log-handle :
define output parameter p-log-handle as handle no-undo .
if valid-handle(v-log-handle)
and lookup("write-to-log", v-log-handle:internal-entries) > 0
then do:
  p-log-handle = v-log-handle.
end.
else do:
  v-log-handle = this-procedure:handle.
  p-log-handle = v-log-handle.
end.
end procedure. /* lib-log_set-log-handle */



procedure write-to-log :
define input parameter p-mess as character no-undo .

end procedure. /* write-to-log */

procedure write-log-and-file :
define input parameter p-tabs as integer no-undo .
define input parameter p-log-file as character no-undo .
define input parameter p-int2 as integer no-undo .
define input parameter p-mess as character no-undo .

end procedure. /* write-log-and-file */

PROCEDURE get-title :
define output parameter p-title     as character    no-undo.

END PROCEDURE.


PROCEDURE set-title :
define input parameter p-title     as character    no-undo.
END PROCEDURE.

PROCEDURE get-counter-value :
define output parameter p-counter     as integer    no-undo.

END PROCEDURE.


PROCEDURE set-counter-value :
define input parameter p-counter     as integer    no-undo.

END PROCEDURE.

PROCEDURE show-counter :

END PROCEDURE. /* show-counter */

PROCEDURE hide-counter :

END PROCEDURE. /* hide-counter */

PROCEDURE write-counter :
define input parameter p-counter-string     as character    no-undo.


END PROCEDURE. /* write-counter */


PROCEDURE get-stop-state :
define output parameter p-stop-state    as logical      no-undo.

END PROCEDURE. /* get-stop-state */

PROCEDURE set-view-log :
define input parameter p-view-log     as logical    no-undo.

END PROCEDURE.


PROCEDURE get-view-log :
define output parameter p-view-log     as logical    no-undo.

END PROCEDURE.

PROCEDURE write-log :
define input parameter p-tab-position   as integer      no-undo.
define input parameter p-log-string     as character    no-undo.

END PROCEDURE. /* write-log */


procedure writelog :
define input parameter p-file-name AS CHAR     NO-UNDO.
define input parameter p-log-level AS INTEGER  NO-UNDO.
define input parameter p-log-string  AS CHAR     NO-UNDO.

end procedure. /* writelog */

PROCEDURE auto2dia-writefile:
define input parameter sFileName AS CHAR     NO-UNDO.
define input parameter iLogLevel AS INTEGER  NO-UNDO.
define input parameter sToWrite  AS CHAR     NO-UNDO.


END PROCEDURE.
