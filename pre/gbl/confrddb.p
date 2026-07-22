block-level on error undo, throw.
define input  parameter p-code   as character no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter h-code   as integer   no-undo .
define input  parameter o-type   as character no-undo .
define input  parameter o-code   as integer   no-undo .
define input  parameter msg-on   as logical   no-undo .
define output parameter p-value  as character no-undo .
define output parameter p-type   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: confrddb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/confrddb.p $":U .
define variable vss-description as character no-undo init "Чтение параметров конфигурации для заданной БД".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run confrddb in g#library
  (input  p-code
  ,input  p-db-num
  ,input  h-code
  ,input  o-type
  ,input  o-code
  ,input  msg-on
  ,output p-value
  ,output p-type
  ) no-error .
if error-status :error then do:
  if error-status :get-message(1) <> "" then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры confrddb" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  undo, return error return-value.
end.
