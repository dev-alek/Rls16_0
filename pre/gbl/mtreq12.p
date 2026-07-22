block-level on error undo, throw.
define input  parameter p-parparentproc as handle    no-undo .
define input  parameter p-message       as longchar  no-undo .
define output parameter p-out-message   as longchar  no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mtreq12.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mtreq12.p $":U .
define variable vss-description as character no-undo init "Авторизация пользователя МТ".
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
on error undo, return error return-value
:
    define buffer buf_user-login for ub.user-login.
    define variable v-sendmemptr  as memptr   no-undo .
    define variable v-sendstr     as longchar no-undo .
    define variable hdocument as handle    no-undo .
    define variable hroot     as handle    no-undo .
    define variable hchild    as handle    no-undo .
    define variable htext     as handle    no-undo .
    define variable icounter        as integer   no-undo .
    define variable v-userlogin     as character no-undo .
    define variable v-userpassword  as character no-undo .
    create x-document hdocument.
    create x-noderef hroot.
    create x-noderef hchild.
    create x-noderef htext.
    hDocument:load( "LONGCHAR", p-message, no ) NO-ERROR.
    hDocument:get-document-element( hRoot ).
    assign
      v-userlogin     = ?
      v-userpassword  = ?
    .
    repeat iCounter = 1 to hRoot:num-children
    :
        hRoot:get-child(hChild,iCounter).
        if hChild:subtype <> 'ELEMENT' or hChild:num-children = 0 then next.
        if hChild:NAME = "user"
        then do:
          hChild:get-child( hText ,1 ).
          assign
            v-userlogin = trim(hText:NODE-VALUE)
          .
        end.
        if hChild:NAME = "password"
        then do:
          hChild:get-child( hText ,1 ).
          assign
            v-userpassword = trim(hText:NODE-VALUE)
          .
        end.
    end.
    delete object hdocument .
    delete object hroot     .
    delete object hchild    .
    delete object htext     .
    assign
      hdocument = ?
      hroot     = ?
      hchild    = ?
      htext     = ?
    .
    if v-userlogin <> ? and v-userpassword <> ?
    then do:
      define variable v-ok as integer no-undo.
      define variable v-err-message as character no-undo.
      find first buf_user-login no-lock
        where buf_user-login.user-login = v-userlogin
      no-error .
      if available buf_user-login
      then do:
        assign
          v-ok = 0
        .
      end.
      else do:
          assign
              v-ok = 1
              v-err-message = substitute( "Не найден пользователь &1", v-userlogin)
          .
      end.
    end.
    create x-document hdocument.
    create x-noderef hroot.
    create x-noderef hchild.
    create x-noderef htext.
    hdocument:CREATE-NODE(hRoot,"msg","ELEMENT").
    hdocument:APPEND-CHILD(hRoot).
    hdocument:create-node(hChild, "stts", "ELEMENT").
    hRoot:append-child(hChild).
    hdocument:create-node(hText, "", "TEXT").
    hChild:append-child(hText).
    hText:node-value = substitute( "&1" , v-ok).
    hdocument:create-node(hChild, "errmsg", "ELEMENT").
    hRoot:append-child(hChild).
    hdocument:create-node(hText, "", "TEXT").
    hChild:append-child(hText).
    hText:node-value = v-err-message .
    hdocument:save("LONGCHAR", p-out-message).
    delete object hdocument .
    delete object hroot     .
    delete object hchild    .
    delete object htext     .
    assign
      hdocument = ?
      hroot     = ?
      hchild    = ?
      htext     = ?
    .
end.
