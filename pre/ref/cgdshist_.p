define input  parameter iGdsCode like ub.goods.gds-code no-undo.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
DEFINE BUFFER X_c-obj-hist FOR c-gds-hist.
DEFINE BUFFER find_c-obj-hist FOR c-gds-hist.
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
run ref/cgdshist.w (
      input parParentProc
    , input p-curr-host-code
    , input p-curr-obj-type
    , input p-curr-obj-code
    , input bttns
    , input p-mode
    , input iGdsCode
    , input ?
    , input ?
    , input ?
    , input p-corr-user-db-num
    , input p-corr-user-name
    , input p-subject
    , input p-db-num
    , input-output p-rid-list  ) no-error .
