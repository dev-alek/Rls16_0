block-level on error undo, throw.
define  input parameter parParentProc as widget-handle no-undo.
define  input parameter spr           as character     no-undo.
define  input parameter znak          as character     no-undo.
define  input parameter lab_user      as character     no-undo.
define  input parameter fld           as character     no-undo.
define  input parameter lab           as character     no-undo.
define  input parameter type          as character     no-undo.
define output parameter str           as character     no-undo.
define output parameter str_rus       as character     no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: f-user.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/f-user.p $":U .
define variable vss-description as character no-undo init "Выбор пользователя и создание выражения для фильтра".
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
define buffer buf_user-account for ub.user-account.
define variable v-cntxt-userid as character no-undo .
define variable v-user-id     as character no-undo .
define variable v-user-login  as character no-undo .
define variable v-user-nik    as character no-undo .
define variable v-user-db-num as integer   no-undo .
define variable v-selected-userid like ub.user-account.user-id        no-undo .
define variable v-old-userid      like ub.user-account.parent-user-id no-undo .
do on error undo, return error return-value
:
  run get-userid in parparentproc ( output v-cntxt-userid).
  run str/usersel.p ( input parparentproc
                    , input v-cntxt-userid
                    , output v-selected-userid
                    , output v-old-userid
                    ).
  find buf_user-account no-lock
    where buf_user-account.user-id = v-selected-userid
  no-error .
  if available buf_user-account then do:
    assign
      v-user-id     = buf_user-account.user-id
      v-user-login  = buf_user-account.parent-user-id
      v-user-nik    = buf_user-account.nik
      v-user-db-num = integer( entry( 1 , v-selected-userid , '-' ) )
    no-error .
    case znak :
      when "=" then do:
        assign
          str     = substitute( '( &1 = "&2" )' , fld , v-user-id )
          str_rus = substitute('&1 &2 "&3" ' , lab_user , znak , v-user-nik )
        .
        if v-user-login <> "" and v-user-login <> ? then do:
          assign
            str = substitute( '( &1 OR ( &2 = &3 ) )' , str , fld , v-user-login )
          .
        end.
      end.
      when "<>" then do:
        assign
          str     = substitute( '( &1 <> "&2" )' , fld , v-user-id )
          str_rus = substitute('&1 &2 "&3" ' , lab_user , znak , v-user-nik )
        .
        if v-user-login <> "" and v-user-login <> ? then do:
          assign
            str = substitute( '( &1 AND ( &2 <> &3 ) )' , str , fld , v-user-login )
          .
        end.
      end.
    end case.
  end.
  else do:
    return error "error".
  end.
end.
