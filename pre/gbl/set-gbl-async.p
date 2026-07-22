block-level on error undo, throw.
define input  parameter p-auto-value  as logical   no-undo .
define input  parameter p-user-id     as character no-undo .
define input  parameter p-user-passwd as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: b30922a289ff, 3175, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:24 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: set-gbl-async.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/set-gbl-async.p $":U .
define variable vss-description as character no-undo init "Инициализация глобальных переменных".
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
do
on error undo, return error return-value
:
  define variable v-msg as character no-undo .
  define variable conf-par as character no-undo .
  define variable par-type as character no-undo .
  define buffer buf_sys-ctrl       for ub.sys-ctrl .
  define buffer buf_other-sys-ctrl for ub.sys-ctrl .
  assign
    session :time-source = "ub"
  .
  find first buf_sys-ctrl no-lock
    no-error .
  assign
    g#auto           = p-auto-value
    g#news           = false
    g#news-source-db = -1
    g#userid         = p-user-id
    g#passwd         = p-user-passwd
    g#db-num         = buf_sys-ctrl.db-num
    no-error
 .
  define new global shared var g#language as character no-undo .
  assign
    g#language = entry(1, buf_sys-ctrl.language, chr(4) ) no-error
  .
  release buf_sys-ctrl.
  if not p-user-passwd begins "nocrypt:"
  then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'oxmlthon':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
    if error-status :error
    then do:
        assign
            g#oxml = no
        .
    end.
    else do:
        if par-type = 'L':U
        and conf-par = 'yes':u
        then do:
            assign
                g#oxml = yes
            .
        end.
        else do:
            assign
                g#oxml = no
            .
        end.
    end.
end.
end.
