block-level on error undo, throw.
define input  parameter p-db-num        as integer   no-undo .
define input  parameter p-user-id       as character no-undo .
define input  parameter p-param-code    as character no-undo .
define output parameter p-param-value   as logical   no-undo .
define output parameter p-default-value as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wndpar_r.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/wndpar_r.p $":U .
define variable vss-description as character no-undo init "Чтение пользовательских параметров настройки интерфейса".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3':U,p-db-num,p-user-id,p-param-code)
    .
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
on error undo, return error return-value
:
  define variable v-param-value           as character no-undo .
  define variable v-param-type            as character no-undo .
  define variable v-config-parameter-code as character no-undo .
  define buffer buf_user-login for ub.user-login .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_config     for ub.config .
  find first buf_sys-ctrl no-lock .
  if p-db-num = ? then do:
    assign
      p-db-num = buf_sys-ctrl.db-num
    .
  end.
  if p-user-id = "":U then do:
    assign
      p-user-id = userid( "DICTDB":U )
    .
  end.
  assign
    p-param-value   = ?
    p-default-value = false
  .
  find first buf_user-login no-lock
    where buf_user-login.db-num  = p-db-num
      and buf_user-login.user-id = p-user-id
    no-error .
  if available buf_user-login then do:
    case p-param-code :
      when 'wndmax':U
      then do:
        assign
          p-param-value = buf_user-login.user-window-maximize
        .
      end.
      when 'wndstore':U
      then do:
        assign
          p-param-value = buf_user-login.user-window-size-store
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Неизвестное значение параметра p-param-code" skip
          "p-param-code" p-param-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
  case p-param-code :
    when 'wndmax':U
    then do:
      assign
        v-config-parameter-code = 'max':U
      .
    end.
    when 'wndstore':U
    then do:
      assign
        v-config-parameter-code = 'store':U
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение параметра p-param-code" skip
        "p-param-code" p-param-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  if p-param-value = ? then do:
    assign
      p-default-value = FALSE
    .
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-tth             as handle     no-undo .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'wnd-size':U
                      , input  v-config-parameter-code
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output p-param-value
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        p-param-value   = NO
      .
    end.
    delete object v-tth.
  end.
end.
