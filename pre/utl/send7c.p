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
define temp-table tt-utd like ub.utd.
define var v-doc-code as integer no-undo.
if testId <> ? then
do:
  find first ub.utd where rowid(ub.utd) = testId no-lock no-error.
end.
else
do:
DEFINE FRAME frame1
  v-doc-code format ">>>>>>>>>>>>>>9"
  with view-as dialog-box
  title "Введите внутр. номер документа"
.
update v-doc-code with frame frame1.
find first ub.utd no-lock where ub.utd.doc-id = v-doc-code no-error .
if not available (ub.utd)
  then do:
    message "Документ электронного документооборота не найден: номер " v-doc-code view-as alert-box.
    return.
  end.
end.
find last ub.c-utd no-lock where ub.c-utd.doc-code = ub.utd.doc-code
                             and ub.c-utd.db-num = ub.c-utd.db-num no-error .
buffer-copy ub.utd except ub.utd.sts ub.utd.sts-edi to tt-utd  .
if available (ub.c-utd) then do:
assign
        tt-utd.sts = ub.c-utd.sts
        tt-utd.sts-edi = ub.c-utd.sts-edi
.
end.
  run bge\send1cerp.p (?,
    this-procedure,
    this-procedure,
    "edi-doc",
    (buffer tt-utd:handle),
    (buffer ub.utd:handle),
    ?) no-error.
if error-status:error
then do:
  message return-value view-as alert-box.
end.
else do:
  if testId <> ? then
    put stream vProtTest unformatted "Документ ЭД " ub.utd.doc-id " отправлен" skip.
  else
  message ub.utd.doc-id " отправлен" view-as alert-box.
end.
