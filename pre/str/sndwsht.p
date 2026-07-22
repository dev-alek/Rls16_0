block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-ser-list   as character no-undo .
define input parameter p-action as char no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndwsht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sndwsht.p $":U .
define variable vss-description as character no-undo init "Пересылка масок серийных МЦ на кассы всех магазинов фирмы".
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
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_cash-desk for ub.cash-desk.
for each buf_clients no-lock
    where buf_clients.obj-type = 'маг':U
      and buf_clients.db-num   = g#db-num,
    first buf_cash-desk no-lock where
          buf_cash-desk.db-num = G#db-num
      AND buf_cash-desk.obj-code = buf_clients.obj-code
      AND buf_cash-desk.cash-on = yes
      AND buf_cash-desk.pos-type = 'IBM-XML':U
on error undo, return error
:
  run set-title in p-log-handle (
        input "Отправка масок МЦ на кассу"
                                  ).
  run str/sndwssh.p (
                  input parparentproc
                ,input p-parent-handle
                ,input p-log-handle
                ,input  buf_clients.obj-type
                ,input buf_clients.obj-code
                ,input string(p-ser-list)
                ,p-action
                  ) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "ошибка при отправке масок серийных МЦ на кассу по магазину &1&2&3&2&4"
                          , buf_clients.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
  end.
end.
