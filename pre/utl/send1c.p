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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
define temp-table tt-trn like ub.trn-doc.
define var      v-doc-code as char      no-undo.
define variable varvalue   as character no-undo .
define variable vartype    as character no-undo .
if testId ne ? then
do:
  find first ub.trn-doc where rowid(ub.trn-doc) = testId no-lock no-error.
  v-doc-code = ub.trn-doc.doc-code.
end.
else
do:
DEFINE FRAME frame1
  v-doc-code format "x(15)"
  with view-as dialog-box
  title "Введите номер документа (накл., инв., перес."
  .
update v-doc-code with frame frame1.
end.
find first ub.trn-doc where ub.trn-doc.doc-code = v-doc-code no-error.
if not available (ub.trn-doc)
  then
do:
  message "Документ инвентаризации не найден: номер " v-doc-code view-as alert-box.
  return.
end.
buffer-copy trn-doc except trn-doc.status_ to tt-trn  assign
  tt-trn.status_ = "накл".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_trn-doc':U
  ,input  buffer tt-trn:handle
  ,input  buffer ub.trn-doc:handle
  ,input ''
  ,input ''
  ) no-error .
if error-status:error
  then
do:
  message return-value view-as alert-box.
end.
else
do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input trn-doc.doc-code ,
                        input 'is-lgas':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if varvalue = "yes" then
  do:
    run bge\send1cerp.p (?,
      this-procedure,
      this-procedure,
      "techlosses",
      (buffer trn-doc:handle),
      ?,
      ?) no-error.
    if error-status:error
      then
    do:
      message return-value view-as alert-box.
    end.
  end.
if testId ne ? then
  put stream vProtTest unformatted "Документ " v-doc-code " отправлен" skip.
else
  message trn-doc.doc-code " отправлен" view-as alert-box.
end.
