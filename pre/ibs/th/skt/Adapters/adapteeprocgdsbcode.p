block-level on error undo, throw.
define input parameter p-gds-code as integer no-undo.
define input parameter p-node-code as integer no-undo.
define output parameter p-main-b-code as integer no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output p-main-b-code
  ) NO-ERROR .
  if error-status:error then return "":U.
