block-level on error undo, throw.
define input parameter p-obj-type as character no-undo.
define input parameter p-obj-code as integer no-undo.
define parameter buffer buf_clients-attr for ub.clients-attr.
define variable vss-revision    as character no-undo init "$Revision: c89b59c2f62e, 135, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:25 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lock-bge-incr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/lock-bge-incr.p $":U .
define variable vss-description as character no-undo init "Блокировка объекта для экспорта во Внешнюю Бухгалтерию".
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
do
on error  undo, return error substitute("&1. &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message(1))
on stop   undo, return error substitute("&1. stop", vss-workfile)
on endkey undo, return error substitute("&1. endkey", vss-workfile):
    find first buf_clients-attr exclusive-lock
        where buf_clients-attr.obj-type = p-obj-type
          and buf_clients-attr.obj-code = p-obj-code
          and buf_clients-attr.attr-code = 'bge-incr-cur':U no-wait no-error.
    if not available buf_clients-attr then
    do:
        if locked buf_clients-attr then
        do:
            return error "Объект уже выгружается.".
        end.
        else do:
            create buf_clients-attr.
            assign
            buf_clients-attr.obj-type = p-obj-type
            buf_clients-attr.obj-code = p-obj-code
            buf_clients-attr.attr-code = 'bge-incr-cur':U.
        end.
    end.
    find current buf_clients-attr share-lock.
    return.
end.
