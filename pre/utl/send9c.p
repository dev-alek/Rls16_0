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
define buffer buf_place for ub.place .
define buffer buf_pl-gds for ub.pl-gds .
for each buf_place no-lock where buf_place.status_ <> 'удал':U
                             and if testId <> ? then rowid(buf_place) = testId else true:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer buf_place:handle
  ,input  buffer buf_place:handle
  ,input ''
  ,input ''
  ) no-error .
    if error-status :error
      then
    do:
      return error substitute( "Ошибка маршрутизации записи в машину правил&1&2&1&3"
        , chr(10)
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  if testId <> ? then
    put stream vProtTest unformatted "Текущая топология по " buf_place.pl-code " отправлена" skip.
end.
if testId = ? then
  message "Текущая топология отправлена" view-as alert-box.
