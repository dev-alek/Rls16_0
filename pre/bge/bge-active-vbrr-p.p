block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
DEFINE VARIABLE p-curr-host-code like ub.sysconf.host-code NO-UNDO.
DEFINE VARIABLE p-curr-obj-type  like ub.clients.obj-type NO-UNDO.
DEFINE VARIABLE p-curr-obj-code  like ub.clients.obj-code NO-UNDO.
DEFINE VARIABLE p-mode           AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-db-num-char    AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-task-type      AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-task-num       AS INTEGER NO-UNDO.
DEFINE VARIABLE p-action         AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-cancel         AS LOGICAL NO-UNDO.
DEFINE VARIABLE p-params         AS CHARACTER NO-UNDO.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    assign
        p-curr-host-code  = v-cntxt-host-code-obj
        p-curr-obj-type = v-cntxt-obj-type
        p-curr-obj-code = v-cntxt-obj-code
    .
run bge/bge-active-vbrr.w ( parparentproc
              , p-curr-host-code
              , p-curr-obj-type
              , p-curr-obj-code
              , 'run'
              , p-db-num-char
              , p-task-type
              , p-task-num
              , p-action
              , OUTPUT p-cancel
              , OUTPUT p-params ) .
