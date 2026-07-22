block-level on error undo, throw.
define input  parameter parparentproc  as widget-handle no-undo .
define input  parameter h-call-prog    as handle    no-undo .
define input  parameter p-client-types as character no-undo .
define input  parameter p-lock-cli-type as logical no-undo .
define output parameter p-select-ok    as logical   no-undo .
define output parameter p-cli-type     as character no-undo .
define output parameter p-cli-code     as integer   no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: selcli.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: ref/selcli.p $":U .
define variable vss-description as character no-undo initial "Выбрать клиента из справочника".
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
define variable v-ref-list      as character no-undo .
define variable v-clients-recid as recid     no-undo .
do
on error undo, return error return-value
:
  run ref/cli-all.w
    (input  parparentproc
    ,input  'b-sel':U
    ,input  p-client-types
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  (if p-lock-cli-type then "lock-cli-type" else ?)
    ,output v-ref-list
    ) .
  if v-ref-list <> ""
  then do:
    assign
      v-clients-recid = integer (v-ref-list)
    .
    find ub.clients no-lock
      where recid(ub.clients) = v-clients-recid
      .
    assign
      p-select-ok = true
      p-cli-type  = ub.clients.obj-type
      p-cli-code  = ub.clients.obj-code
    .
    return .
  end.
  else do:
    assign
      p-select-ok = false
      p-cli-type  = '':u
      p-cli-code  = 0
    .
  end.
end.
