block-level on error undo, throw.
define input  parameter p-cntxt-db-num          as integer   no-undo .
define input  parameter p-cntxt-user-id         as character no-undo .
define output parameter p-cntxt-valid           as logical   no-undo .
define output parameter p-cntxt-menu-code       as integer   no-undo .
define output parameter p-cntxt-menu-group-code as integer   no-undo .
define output parameter p-cntxt-level           as character no-undo .
define output parameter p-cntxt-host-code-obj   as integer   no-undo .
define output parameter p-cntxt-obj-type        as character no-undo .
define output parameter p-cntxt-obj-code        as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cntxtget.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/cntxtget.p $":U .
define variable vss-description as character no-undo init "Получить контекст по умолчанию при входе в систему".
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
define buffer buf_menu-group           for ub.menu-group .
define buffer buf_user-context-history for ubflt.user-context-history .
do
on error undo, return error return-value
:
  find last buf_user-context-history no-lock
    where buf_user-context-history.db-num  = p-cntxt-db-num
      and buf_user-context-history.user-id = p-cntxt-user-id
    no-error .
  if available buf_user-context-history
  then do:
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = buf_user-context-history.cntxt-menu-code
        and buf_menu-group.menu-group-id = buf_user-context-history.cntxt-menu-group-id
      no-error .
    if available buf_menu-group
    then do:
      assign
        p-cntxt-valid           = true
        p-cntxt-level           = buf_user-context-history.cntxt-level
        p-cntxt-host-code-obj   = buf_user-context-history.cntxt-host-code
        p-cntxt-obj-type        = buf_user-context-history.cntxt-obj-type
        p-cntxt-obj-code        = buf_user-context-history.cntxt-obj-code
        p-cntxt-menu-code       = buf_user-context-history.cntxt-menu-code
        p-cntxt-menu-group-code = buf_menu-group.menu-group-code
      .
    end.
    else do:
      assign
        p-cntxt-valid         = false
      .
    end.
  end.
  else do:
    assign
      p-cntxt-valid         = false
    .
  end.
end.
