block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode   as character no-undo .
define input parameter p-d-card like ub.dis-card.d-card no-undo .
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type  no-undo .
define input parameter p-obj-code  like ub.clients.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dc-propr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dc-propr.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования атрибутов ДК".
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
procedure lock-dcp :
define input parameter p-d-card as character no-undo .
define parameter buffer locked_dis-card-property for ub.dis-card-property.
  do
  on error undo, return error
  on stop undo, return error
  on end-key undo, return error
  :
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card = p-d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error no-wait.
      if not available locked_dis-card-property
      and not locked locked_dis-card-property then do:
        create locked_dis-card-property.
        assign
        locked_dis-card-property.host-code = 0
        locked_dis-card-property.obj-type =  '':U
        locked_dis-card-property.obj-code = 0
        locked_dis-card-property.d-card = p-d-card
        locked_dis-card-property.dtm-code = 0
        locked_dis-card-property.dt-code = 0
        locked_dis-card-property.node-code = 0
        .
      end.
      if locked locked_dis-card-property then do:
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card = p-d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error .
      end.
  end.
end procedure.
define variable v-update-attr as logical no-undo .
define temp-table tt0-dis-card-property no-undo like ub.dis-card-property.
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer locked_dis-card-property for ub.dis-card-property.
do
on stop undo, return error
:
  for each tt0-dis-card-property:
    delete tt0-dis-card-property.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    do on error undo, return error return-value :
      run lock-dcp in this-procedure ( input p-d-card, buffer locked_dis-card-property).
    end.
    FOR EACH buf_dis-card-property no-lock  where
    buf_dis-card-property.d-card = p-d-card
    on error undo, return error :
      if buf_dis-card-property.dtm-code = 0 then next.
      CREATE tt0-dis-card-property.
      BUFFER-COPY buf_dis-card-property TO tt0-dis-card-property.
    END.
    run ref/discprpi.w (
                    input parparentproc
                  , input p-mode
                  , input p-d-card
                  , input p-emitent-host-code
                  , input p-type
                  , input p-host-code
                  , input p-obj-type
                  , input p-obj-code
                  , input p-update-on-exit
                  , output p-modified
                  , input-output table tt0-dis-card-property
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-dis-card-property:
      delete tt0-dis-card-property.
    end.
  end.
  else do:
    FOR EACH buf_dis-card-property no-lock where
         buf_dis-card-property.d-card = p-d-card
    :
      if buf_dis-card-property.dtm-code = 0 then next.
      CREATE tt0-dis-card-property.
      BUFFER-COPY buf_dis-card-property TO tt0-dis-card-property.
    END.
    run ref/discprpi.w (
                    input parparentproc
                  , input p-mode
                  , input p-d-card
                  , input p-emitent-host-code
                  , input p-type
                  , input p-host-code
                  , input p-obj-type
                  , input p-obj-code
                  , input p-update-on-exit
                  , output p-modified
                  , input-output table tt0-dis-card-property
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-dis-card-property:
      delete tt0-dis-card-property.
    end.
  end.
end.
