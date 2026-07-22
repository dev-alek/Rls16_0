block-level on error undo, throw.
define input parameter parparentproc    as handle           no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-verify-arh     as logical          no-undo.
define input parameter p-verify-ahsp    as logical          no-undo.
define input parameter p-verify-aht     as logical          no-undo.
define input parameter p-date-from      as date             no-undo.
define input parameter p-date-to        as date             no-undo.
define output parameter p-archive-ok    as logical          no-undo.
define output parameter p-comment       as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: 56408f49832e, 136, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:25 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-ahz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-ahz.p $":U .
define variable vss-description as character no-undo init "Проверка архивов для диапазона дат для выгрузки".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer buf_sys-ctrl    for ub.sys-ctrl.
define buffer buf_user-login  for ub.user-login.
define variable v-date-from    as date          no-undo .
define variable v-date-to      as date          no-undo .
define variable v-can-print    as logical       no-undo .
define variable v-login        as character     no-undo .
do
on error undo, return error
:
    find first buf_sys-ctrl no-lock .
    assign
      v-login = userid("ub")
      v-cntxt-db-num = buf_sys-ctrl.db-num
    .
    find first buf_user-login no-lock
      where buf_user-login.db-num     = v-cntxt-db-num
        and buf_user-login.user-login = v-login
    no-error .
    if not available buf_user-login
    then do:
      undo, return error substitute( "Не найдена запись пользователя. БД:&1 Логин: &2"
                                   , v-cntxt-db-num
                                   , v-login
                                   ) .
    end.
    assign
      v-cntxt-userid  = buf_user-login.user-id
      v-date-from     = p-date-from
      v-date-to       = p-date-to
    .
    run rep/chk-ahz.p (
          input        p-obj-type
        , input        p-obj-code
        , input        yes
        , input        p-verify-arh
        , input        p-verify-ahsp
        , input        p-verify-aht
        , input        if g#auto then no else yes
        , input        v-cntxt-db-num
        , input        v-cntxt-userid
        , input-output v-date-from
        , input-output v-date-to
        , output       p-archive-ok
        , output       p-comment
        , output       v-can-print
    ) no-error .
    if error-status :error
    then do:
        undo, return error substitute( "Ошибка при вызове программы chk-ahz.p. &1. &2. &3"
            , return-value
            , trim(error-status :get-message(1))
            , trim(error-status :get-message(2))
        ) .
    end.
    if v-date-from <> p-date-from
    or v-date-to   <> p-date-to
    then do:
        assign
            p-archive-ok = no
            p-comment    = substitute( "Выгрузка не может быть произведена. &1", p-comment )
        .
    end.
end.
