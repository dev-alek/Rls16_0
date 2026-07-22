block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode   as character no-undo .
define input parameter p-d-card like ub.dis-card.d-card no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type  no-undo .
define input parameter p-obj-code  like ub.clients.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ddcrattr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ddcrattr.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования скидок ДК".
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
define variable v-update-attr as logical no-undo .
define variable dflt-cd as character no-undo .
define temp-table tt0-dis-dc-rule no-undo like ub.dis-dc-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer locked_dis-dc-rule for ub.dis-dc-rule.
do
on stop undo, return error
:
  for each tt0-dis-dc-rule:
    delete tt0-dis-dc-rule.
  end.
  if g#db-num > 0 then do:
    if p-obj-type = 'маг':U then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type0 as character no-undo .
define variable v-value-date0 as date no-undo .
define variable v-value-decimal0 as decimal no-undo .
define variable v-value-integer0 as INTEGER no-undo .
define variable v-value-logical0 AS LOGICAL no-undo .
define variable v-tth0 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date0
    ,output v-value-decimal0
    ,output v-value-integer0
    ,output v-value-logical0
    ,output v-param-type0
    ,INPUT-OUTPUT table-handle v-tth0
    )  .
delete object v-tth0 no-error.
    end.
    else do:
       dflt-cd = '-':U.
    end.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    do on error undo, return error return-value :
      Find first locked_dis-dc-rule exclusive-lock  where
              locked_dis-dc-rule.d-card = p-d-card
          AND locked_dis-dc-rule.host-code = (if g#db-num = 0 then 0 else p-host-code)
          AND locked_dis-dc-rule.obj-type = (if g#db-num = 0 then '':U else p-obj-type)
          AND locked_dis-dc-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
          and locked_dis-dc-rule.discnt-role = '':U
          and locked_dis-dc-rule.pos-type = '':U
          and locked_dis-dc-rule.nonunique = '':U
          no-error no-wait.
      if not available locked_dis-dc-rule
      and not locked locked_dis-dc-rule then do:
        create locked_dis-dc-rule.
        assign
        locked_dis-dc-rule.host-code = (if g#db-num = 0 then 0 else p-host-code)
        locked_dis-dc-rule.obj-type =  (if g#db-num = 0 then '':U else p-obj-type)
        locked_dis-dc-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
        locked_dis-dc-rule.d-card = p-d-card
        locked_dis-dc-rule.discnt-role = '':U
        locked_dis-dc-rule.nonunique = '':U
        locked_dis-dc-rule.pos-type = '':U
        .
      end.
      if locked locked_dis-dc-rule then do:
      Find first locked_dis-dc-rule exclusive-lock  where
              locked_dis-dc-rule.d-card = p-d-card
          AND locked_dis-dc-rule.host-code = (if g#db-num = 0 then 0 else p-host-code)
          AND locked_dis-dc-rule.obj-type =  (if g#db-num = 0 then '':U else p-obj-type)
          AND locked_dis-dc-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
          and locked_dis-dc-rule.discnt-role = '':U
          and locked_dis-dc-rule.nonunique = '':U
          and locked_dis-dc-rule.pos-type = '':U
          no-error .
      end.
    end.
    FOR EACH buf_dis-dc-rule no-lock  where
    buf_dis-dc-rule.d-card = p-d-card
    on error undo, return error :
      if buf_dis-dc-rule.nonunique = '':U
      and buf_dis-dc-rule.pos-type = '':U
      and buf_dis-dc-rule.discnt-role = '':U
      then next.
      CREATE tt0-dis-dc-rule.
      BUFFER-COPY buf_dis-dc-rule TO tt0-dis-dc-rule.
    END.
    run ref/dis-dcri.w (
                    input parparentproc
                  , input p-mode
                  , input p-d-card
                  , input p-host-code
                  , input p-obj-type
                  , input p-obj-code
                  , input dflt-cd
                  , input p-update-on-exit
                  , output p-modified
                  , input-output table tt0-dis-dc-rule
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-dis-dc-rule:
      delete tt0-dis-dc-rule.
    end.
  end.
  else do:
    FOR EACH buf_dis-dc-rule no-lock where
         buf_dis-dc-rule.d-card = p-d-card
    on error undo, return error :
      if buf_dis-dc-rule.pos-type = '':U
      and buf_dis-dc-rule.discnt-role = '':U
      and buf_dis-dc-rule.nonunique = '':U
      then next.
      CREATE tt0-dis-dc-rule.
      BUFFER-COPY buf_dis-dc-rule TO tt0-dis-dc-rule.
    END.
    run ref/dis-dcri.w (
                    input parparentproc
                  , input p-mode
                  , input p-d-card
                  , input p-host-code
                  , input p-obj-type
                  , input p-obj-code
                  , input dflt-cd
                  , input p-update-on-exit
                  , output p-modified
                  , input-output table tt0-dis-dc-rule
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-dis-dc-rule:
      delete tt0-dis-dc-rule.
    end.
  end.
end.
