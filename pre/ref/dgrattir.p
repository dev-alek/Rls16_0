block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode      as character no-undo .
define input parameter p-mode-obj  as character no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-obj-type  like ub.dis-gds-rule.obj-type  no-undo .
define input parameter p-obj-code  like ub.dis-gds-rule.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dgrattir.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dgrattir.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования скидок товара, действующих на объекте".
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
define temp-table tt0-dis-gds-rule no-undo like ub.dis-gds-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer locked_dis-gds-rule for ub.dis-gds-rule.
do
on stop undo, return error return-value
:
  for each tt0-dis-gds-rule:
    delete tt0-dis-gds-rule.
  end.
  CASE p-mode:
    when 'ИЗМЕНЕНИЕ':U then do:
      do on error undo, return error :
        Find first locked_dis-gds-rule exclusive-lock  where
                locked_dis-gds-rule.gds-code = p-gds-code
            AND locked_dis-gds-rule.obj-type = (if g#db-num = 0 then '':U else p-obj-type)
            AND locked_dis-gds-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
            AND locked_dis-gds-rule.pos-type = '':U
            and locked_dis-gds-rule.discnt-role = '':U
            and locked_dis-gds-rule.nonunique = '':U
            no-error no-wait.
        if not available locked_dis-gds-rule
        and not locked locked_dis-gds-rule then do:
          create locked_dis-gds-rule.
          assign
          locked_dis-gds-rule.obj-type =  (if g#db-num = 0 then '':U else p-obj-type)
          locked_dis-gds-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
          locked_dis-gds-rule.gds-code = p-gds-code
          locked_dis-gds-rule.pos-type = '':U
          locked_dis-gds-rule.discnt-role = '':U
          locked_dis-gds-rule.nonunique = '':U
          .
        end.
        if locked locked_dis-gds-rule then do:
          Find first locked_dis-gds-rule exclusive-lock  where
                locked_dis-gds-rule.gds-code = p-gds-code
            AND locked_dis-gds-rule.obj-type = (if g#db-num = 0 then '':U else p-obj-type)
            AND locked_dis-gds-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
            AND locked_dis-gds-rule.pos-type = '':U
            and locked_dis-gds-rule.discnt-role = '':U
            and locked_dis-gds-rule.nonunique = '':U
            no-error .
        end.
      end.
      FOR EACH buf_dis-gds-rule no-lock  where
              buf_dis-gds-rule.gds-code = p-gds-code
      on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo , return error substitute( "&1. stop", vss-workfile )
      on endkey undo , return error substitute( "&1. endkey", vss-workfile )
      :
        if buf_dis-gds-rule.pos-type = '':U
        and buf_dis-gds-rule.discnt-role = '':U
        and buf_dis-gds-rule.nonunique = '':U  then next.
        CREATE tt0-dis-gds-rule.
        BUFFER-COPY buf_dis-gds-rule TO tt0-dis-gds-rule.
      END.
      run ref/dis-gdsi.w (
                      input parparentproc
                    , input p-mode
                    , input p-mode-obj
                    , input p-gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input (if p-mode-obj = 'объект':U then dflt-cd else '':U)
                    , input p-update-on-exit
                    , output p-modified
                    , input-output table tt0-dis-gds-rule
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes
        .
      end.
      for each tt0-dis-gds-rule:
        delete tt0-dis-gds-rule.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end.
    when 'ПРОСМОТР':U then do:
      FOR EACH buf_dis-gds-rule no-lock where
              buf_dis-gds-rule.gds-code = p-gds-code:
        if buf_dis-gds-rule.pos-type = '':U
        and buf_dis-gds-rule.discnt-role = '':U
        and buf_dis-gds-rule.nonunique = '':U  then next.
        CREATE tt0-dis-gds-rule.
        BUFFER-COPY buf_dis-gds-rule TO tt0-dis-gds-rule.
      END.
      run ref/dis-gdsi.w (
                      input parparentproc
                    , input p-mode
                    , input p-mode-obj
                    , input p-gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input (if p-mode-obj = 'объект':U then dflt-cd else '':U)
                    , input p-update-on-exit
                    , output p-modified
                    , input-output table tt0-dis-gds-rule
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes.
      end.
      for each tt0-dis-gds-rule:
        delete tt0-dis-gds-rule.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end.
  end CASE.
end.
