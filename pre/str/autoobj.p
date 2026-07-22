block-level on error undo, throw.
define input  parameter p-user-login  as character no-undo .
define output parameter p-obj-type as character no-undo .
define output parameter p-obj-code as integer   no-undo .
define output parameter p-state    as logical   no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: autoobj.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/autoobj.p $":U .
define variable vss-description as character no-undo initial "Возвращает имя объекта по умолчанию для экрана покупателя".
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
define variable v-dflt-cntxt-valid           as logical   no-undo .
define variable v-dflt-cntxt-menu-code       as integer   no-undo .
define variable v-dflt-cntxt-menu-group-code as integer   no-undo .
define variable v-dflt-cntxt-level           as character no-undo .
define variable v-dflt-cntxt-host-code-obj   as integer   no-undo .
define variable v-dflt-cntxt-obj-type        as character no-undo .
define variable v-dflt-cntxt-obj-code        as integer   no-undo .
define buffer buf_sys-ctrl     for ub.sys-ctrl .
define buffer buf_user-login     for ub.user-login .
do
on error undo, return error return-value
:
  assign
    p-state = no
  .
  find first buf_sys-ctrl no-lock.
  find first buf_user-login
       where buf_user-login.db-num =  buf_sys-ctrl.db-num
       and   buf_user-login.user-login = p-user-login
       no-lock
       no-error
       .
  IF NOT AVAILABLE buf_user-login
  THEN RETURN ERROR.
  run gbl/cntxtget.p
    (input  buf_user-login.db-num
    ,input  buf_user-login.user-id
    ,output v-dflt-cntxt-valid
    ,output v-dflt-cntxt-menu-code
    ,output v-dflt-cntxt-menu-group-code
    ,output v-dflt-cntxt-level
    ,output v-dflt-cntxt-host-code-obj
    ,output v-dflt-cntxt-obj-type
    ,output v-dflt-cntxt-obj-code
    ) .
  find first ub.clients no-lock
    where ub.clients.obj-type = v-dflt-cntxt-obj-type
      and ub.clients.obj-code = v-dflt-cntxt-obj-code
    no-error .
  if available ub.clients
  and (ub.clients.obj-type = 'скл':U or ub.clients.obj-type = 'маг':U)
  then do:
    assign
      p-state    = yes
      p-obj-type = ub.clients.obj-type
      p-obj-code = ub.clients.obj-code
    .
  end.
  else do:
    run str/chs-obj.w
      (input  buf_user-login.user-id
      ,input  'скл':U + "," + 'маг':U
      ,output p-obj-type
      ,output p-obj-code
      ) no-error.
    if error-status :error
    or p-obj-code = ?
    then do:
    end.
    else do:
      assign
        p-state = yes
      .
    end.
  end.
end.
