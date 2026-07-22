block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: plgdpust.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/plgdpust.p $":U .
define variable vss-description as character no-undo init "Утилита по простановке статуса в записи pl-gds-pump".
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
define buffer bf_clients         for ub.clients.
define buffer bf_pl-gds-pump     for ub.pl-gds-pump.
define buffer bf-cur_pl-gds-pump for ub.pl-gds-pump.
for each bf_clients where bf_clients.db-num = g#db-num on error undo, return error return-value :
  for each bf_pl-gds-pump where bf_pl-gds-pump.obj-type = bf_clients.obj-type and
                                bf_pl-gds-pump.obj-code = bf_clients.obj-code on error undo, return error return-value :
    if bf_pl-gds-pump.status_ = "" or
       bf_pl-gds-pump.status_ = ?  then do:
      find first bf-cur_pl-gds-pump where bf-cur_pl-gds-pump.obj-type  = bf_pl-gds-pump.obj-type  and
                                          bf-cur_pl-gds-pump.obj-code  = bf_pl-gds-pump.obj-code  and
                                          bf-cur_pl-gds-pump.gds-code  = bf_pl-gds-pump.gds-code  and
                                          bf-cur_pl-gds-pump.pump-code = bf_pl-gds-pump.pump-code and
                                          bf-cur_pl-gds-pump.pl-code  <> bf_pl-gds-pump.pl-code   and
                                          bf-cur_pl-gds-pump.status_   = 'тек':U        no-lock no-error.
      if available bf-cur_pl-gds-pump then do:
        assign
          bf_pl-gds-pump.status_ = 'блок':U.
      end.
      else do:
        assign
          bf_pl-gds-pump.status_ = 'тек':U.
      end.
    end.
  end.
end.
message "Смена статусов записей Резервуар-ТРК-Товар успешно завершена." view-as alert-box information.
