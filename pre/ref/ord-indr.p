block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-type      as character no-undo .
define input parameter p-mode      as character no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo.
define input parameter p-obj-type  like ub.gds-obj-prop.obj-type  no-undo .
define input parameter p-obj-code  like ub.gds-obj-prop.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-indr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ord-indr.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования атрибутов товара на объекте".
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
define variable v-update-attr as logical no-undo .
define temp-table tt0-gds-obj-prop no-undo like ub.gds-obj-prop.
define buffer buf_gds-obj-prop for ub.gds-obj-prop.
define temp-table tt0-gds-obj-prop-attr no-undo like ub.gds-obj-prop-attr.
define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr.
do
on error undo, return error return-value
on stop undo, return error return-value
:
  for each tt0-gds-obj-prop:
    delete tt0-gds-obj-prop.
  end.
  CASE p-mode:
    when 'ИЗМЕНЕНИЕ':U then do:
      do transaction on error undo, return error :
        FOR EACH buf_gds-obj-prop exclusive-lock  where
                buf_gds-obj-prop.gds-code = p-gds-code
            AND buf_gds-obj-prop.obj-type = p-obj-type
            AND buf_gds-obj-prop.obj-code = p-obj-code
        on error undo, return error:
          CREATE tt0-gds-obj-prop.
          BUFFER-COPY buf_gds-obj-prop TO tt0-gds-obj-prop.
        END.
        if p-type = "orders":U
        then do:
          FOR EACH buf_gds-obj-prop-attr exclusive-lock  where
                  buf_gds-obj-prop-attr.gds-code = p-gds-code
              AND buf_gds-obj-prop-attr.obj-type = p-obj-type
              AND buf_gds-obj-prop-attr.obj-code = p-obj-code
          on error undo, return error:
            if lookup(buf_gds-obj-prop-attr.attr-code, 'CorrIztDel':u) > 0 then next.
            CREATE tt0-gds-obj-prop-attr.
            BUFFER-COPY buf_gds-obj-prop-attr TO tt0-gds-obj-prop-attr.
          END.
      end.
      end.
      if p-type = "orders":U
      or p-type = "ordersf":U then do:
          run ref/ord-ind.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit
                    , output p-modified
                    , input-output table tt0-gds-obj-prop
                    , input-output table tt0-gds-obj-prop-attr
                          ) no-error.
      end.
      else do:
         run ref/gds-ind.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit
                    , output p-modified
                    , input-output table tt0-gds-obj-prop
                          ) no-error.
      end.
      if error-status:error then do:
        assign
        p-is-error = yes
        .
      end.
      for each tt0-gds-obj-prop:
        delete tt0-gds-obj-prop.
      end.
      for each tt0-gds-obj-prop-attr:
        delete tt0-gds-obj-prop-attr.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end.
    when 'ПРОСМОТР':U then do:
      FOR EACH buf_gds-obj-prop no-lock where
              buf_gds-obj-prop.gds-code = p-gds-code
          AND buf_gds-obj-prop.obj-type = p-obj-type
          AND buf_gds-obj-prop.obj-code = p-obj-code :
          CREATE tt0-gds-obj-prop.
          BUFFER-COPY buf_gds-obj-prop TO tt0-gds-obj-prop.
      END.
      if p-type = "orders":U
      then do:
        FOR EACH buf_gds-obj-prop-attr no-lock where
                buf_gds-obj-prop-attr.gds-code = p-gds-code
            AND buf_gds-obj-prop-attr.obj-type = p-obj-type
            AND buf_gds-obj-prop-attr.obj-code = p-obj-code :
          if lookup(buf_gds-obj-prop-attr.attr-code, 'CorrIztDel':u) > 0 then next.
            CREATE tt0-gds-obj-prop-attr.
            BUFFER-COPY buf_gds-obj-prop-attr TO tt0-gds-obj-prop-attr.
        END.
      end.
      if p-type = "orders":U
      or p-type = "ordersf":U then do:
         run ref/ord-ind.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit
                    , output p-modified
                    , input-output table tt0-gds-obj-prop
                    , input-output table tt0-gds-obj-prop-attr
                          ) no-error.
      end.
      else do:
        run ref/gds-ind.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit
                    , output p-modified
                    , input-output table tt0-gds-obj-prop
                          ) no-error.
      end.
      if error-status:error then do:
        assign
        p-is-error = yes.
      end.
      for each tt0-gds-obj-prop:
        delete tt0-gds-obj-prop.
      end.
      for each tt0-gds-obj-prop-attr:
        delete tt0-gds-obj-prop-attr.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end.
  end CASE.
end.
