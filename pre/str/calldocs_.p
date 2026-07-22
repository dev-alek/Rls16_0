define input  parameter iDocCode like ub.trn-doc.doc-code no-undo.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer c-trn-doc for ub.c-trn-doc.
DEFINE BUFFER X_c-obj-hist FOR c-trn-doc.
DEFINE BUFFER find_c-obj-hist FOR c-trn-doc.
DEFINE BUFFER X_curr-sysconf FOR sysconf.
DEFINE BUFFER X_db FOR db.
DEFINE BUFFER X_sysconf FOR sysconf.
define input     parameter parParentProc  as widget-handle no-undo.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter bttns  as char   no-undo .
define input parameter p-mode  as char   no-undo .
define input parameter p-corr-user-db-num  like ub.c-cli-hist.corr-user-db-num no-undo .
define input parameter p-corr-user-name  like ub.c-cli-hist.corr-user-name no-undo .
define input parameter p-subject  like ub.c-cli-hist.subject no-undo .
define input parameter p-db-num  like ub.c-cli-hist.corr-user-db-num no-undo .
define input parameter p-chip-num  as int64 no-undo.
define input-output param p-rid-list    as  char no-undo .
if iDocCode <> ? then
do:
  find first c-trn-doc no-lock where
             c-trn-doc.doc-code = iDocCode no-error.
  if not avail c-trn-doc then
  do:
    message "Документ не найден." view-as alert-box.
    return.
  end.
end.
run str/calldocs.w ( input  parparentproc,
                     input  if p-mode = "one" then "doc" else 'объект':U,
                     input  "",
                     input  "",
                     input  ?,
                     input  no,
                     input  "":U,
                     input  if iDocCode <> ? then iDocCode else "":U,
                     input  ?,
                     input  if avail trn-doc then recid(trn-doc) else ?,
                     input  p-curr-obj-type,
                     input  p-curr-obj-code,
                     output p-rid-list ).
