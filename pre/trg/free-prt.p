block-level on error undo, throw.
define input parameter  p-obj-type  like ub.prt-obj.obj-type  no-undo .
define input parameter  p-obj-code  like ub.prt-obj.obj-code  no-undo .
define input parameter  p-artic     like ub.prt-obj.artic     no-undo .
define input parameter  p-prod-type like ub.prt-obj.prod-type no-undo .
define input parameter  p-prod-code like ub.prt-obj.prod-code no-undo .
define input parameter  p-node-code like ub.prt-obj.prt-code  no-undo .
define output parameter p-free-qnty like ub.prt-obj.free-qnty no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Возвращает текущее свободное количество признака на объекте".
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
define buffer buf_prt-obj for prt-obj .
find first buf_prt-obj
  where buf_prt-obj.obj-type  = p-obj-type
    and buf_prt-obj.obj-code  = p-obj-code
    and buf_prt-obj.artic     = p-artic
    and buf_prt-obj.prod-type = p-prod-type
    and buf_prt-obj.prod-code = p-prod-code
    and buf_prt-obj.prt-code  = p-node-code
  no-error .
if available buf_prt-obj then do:
  assign
    p-free-qnty = buf_prt-obj.free-qnty
  .
end.
else do:
  assign
    p-free-qnty = 0
  .
end.
