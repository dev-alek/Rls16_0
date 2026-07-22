block-level on error undo, throw.
define input parameter objType as character no-undo.
define input parameter objCode as integer no-undo.
define input parameter barCode as integer no-undo.
define output parameter varprice-sale as decimal no-undo.
define output parameter varcur-vat-pc as decimal no-undo.
define variable vardoc-num    as character no-undo.
define variable varroad-tax   as decimal   no-undo.
define variable varexcise     as decimal   no-undo.
define variable varcur-slt-pc as decimal   no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  objType
  ,input  objCode
  ,input  barCode
  ,input  0
  ,input  0
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
