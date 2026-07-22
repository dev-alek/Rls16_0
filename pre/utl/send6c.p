block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define  shared stream vProtTest.
define  shared variable testId as rowid no-undo.
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
    then run str/lib-trn.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn2)
    then run str/lib-trn2.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
    then run str/lib-trn3.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn4)
    then run str/lib-trn4.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
    then run str/trdcalib.p persistent no-error .
define temp-table tt-fbr like ub.fbr-doc.
define var v-doc-code as char no-undo.
if testId <> ? then
do:
  find first ub.fbr-doc where rowid(ub.fbr-doc) = testId no-lock no-error.
end.
else
do:
DEFINE FRAME frame1
  v-doc-code format "x(15)"
  with view-as dialog-box
  title "Введите номер документа производства"
.
update v-doc-code with frame frame1.
find first ub.fbr-doc where ub.fbr-doc.doc-code = v-doc-code no-error.
if not available (ub.fbr-doc)
  then do:
    message "Документ производства не найден: номер " v-doc-code view-as alert-box.
    return.
  end.
end.
buffer-copy fbr-doc except fbr-doc.status_ to tt-fbr  assign tt-fbr.status_ = "накл".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_fbr-doc':U
  ,input  buffer tt-fbr:handle
  ,input  buffer ub.fbr-doc:handle
  ,input ''
  ,input ''
  ) no-error .
if error-status:error
then do:
  message return-value view-as alert-box.
end.
else do:
  if testId <> ? then
    put stream vProtTest unformatted "Документ производства " fbr-doc.doc-code " отправлен" skip.
  else
  message fbr-doc.doc-code " отправлен" view-as alert-box.
end.
