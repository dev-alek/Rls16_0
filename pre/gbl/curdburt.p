BLOCK-LEVEL ON ERROR UNDO, THROW.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define output parameter this-proc-hndl as handle no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Возвращает текущий номер базы данных, пользователя, дату, время и количество секунд".
do:
  this-proc-hndl = this-procedure.
end.
procedure curd_burt:
define output parameter p-user-db-num   like ub.contract.user-db-num   no-undo .
define output parameter p-user-name     like ub.contract.user-name     no-undo .
define output parameter p-sys-date      as  date      no-undo .
define output parameter p-sys-time      as  character no-undo .
define output parameter p-sys-time-int  as  integer   no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output p-user-db-num
  ,output p-user-name
  ,output p-sys-date
  ,output p-sys-time
  ,output p-sys-time-int
  )  .
end procedure .
