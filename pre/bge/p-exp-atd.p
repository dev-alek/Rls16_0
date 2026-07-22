block-level on error undo, throw.
define input parameter parParentProc as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$ $":U.
define variable vss-author      as character no-undo init "$ $":U.
define variable vss-date        as character no-undo init "$ $":U.
define variable vss-workfile    as character no-undo init "$ $":U.
define variable vss-archive     as character no-undo init "$ $":U.
define variable vss-description as character no-undo init "".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
run bge/e-exp-ATD.w( parparentproc
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
