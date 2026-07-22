block-level on error undo, throw.
define input  parameter p-artic     like ub.goods.artic     no-undo.
define input  parameter p-prod-type like ub.goods.prod-type no-undo.
define input  parameter p-prod-code like ub.goods.prod-code no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: initnwas.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/initnwas.p $":U .
define variable vss-description as character no-undo init "Процедура инициализации атрибута insalepr".
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
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-ind as integer   no-undo .
  define buffer buf_goods        for ub.goods .
  define buffer buf_clients      for ub.clients .
  define buffer buf_gds-obj-attr for ub.gds-obj-attr .
  define variable v-db-num          as integer   no-undo .
  define variable v-object          as character no-undo .
  define variable v-gds-name        as character no-undo .
  define variable v-artic           as character no-undo .
  define variable w-initnwast       as widget-handle no-undo.
  define variable v-err-message     as character no-undo .
  create widget-pool "wind-info" .
  create window w-initnwast assign
         title              = "Перенос атрибута Нормы естественной убыли для топлива"
         column             = 31.5
         row                = 9
         height             = 4.0
         width              = 50
         resize             = false
         scroll-bars        = false
         status-area        = false
         three-d            = true
         message-area       = false
         sensitive          = true
         visible            = true
         .
  define frame info-init
    v-gds-name   label "Наим.товара" format "x(30)" skip
    v-artic      label "Артикул"     format "x(30)" skip
    v-db-num     label "БД"                         skip
    v-object     label "Объект"      format "x(30)" skip
    with view-as dialog-box side-labels 1 columns three-d title "Перенос атрибута Нормы естественной убыли для топлива"
  .
  assign
    current-window = w-initnwast
  .
  view frame info-init .
  assign
    v-err-message = "":U
  .
  main_block:
  do transaction
  on error  undo main_block, retry main_block
  on stop   undo main_block, retry main_block
  on endkey undo main_block, retry main_block
  :
    if retry then do:
      assign
        v-err-message = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      .
    end.
    find first ub.goods
         where ub.goods.artic     = p-artic
         and   ub.goods.prod-type = p-prod-type
         and   ub.goods.prod-code = p-prod-code
         exclusive-lock no-error
         .
         if available ub.goods then do:
            do with frame info-init
            :
              assign
                v-gds-name  :screen-value = string( ub.goods.gds-name, v-gds-name :format)
                v-artic     :screen-value = string( ub.goods.artic, v-artic  :format)
                v-db-num    :screen-value = string( ?,    v-db-num :format)
                v-object    :screen-value = string( "":U, v-object :format)
              .
            end.
            for each buf_clients
                where buf_clients.db-num <> ?
                on error undo main_block, retry main_block
                 :
                  if NOT can-find (first buf_gds-obj-attr
                    where buf_gds-obj-attr.obj-type  = buf_clients.obj-type
                      and buf_gds-obj-attr.obj-code  = buf_clients.obj-code
                      and buf_gds-obj-attr.gds-code  = ub.goods.gds-code
                      and buf_gds-obj-attr.attr-code = 'normal-wastage-o':U)
                  then do:
                    do with frame info-init
                    :
                      assign
                        v-gds-name  :screen-value = string( ub.goods.gds-name,    v-gds-name :format)
                        v-artic     :screen-value = string( ub.goods.artic,       v-artic    :format)
                        v-db-num    :screen-value = string( buf_clients.db-num,   v-db-num   :format)
                        v-object    :screen-value = string( substitute( "&1 &2", buf_clients.obj-type, buf_clients.obj-code), v-object :format)
                    .
                    end.
                    create buf_gds-obj-attr .
                    assign
                      buf_gds-obj-attr.obj-type   = buf_clients.obj-type
                      buf_gds-obj-attr.obj-code   = buf_clients.obj-code
                      buf_gds-obj-attr.gds-code   = ub.goods.gds-code
                      buf_gds-obj-attr.attr-code  = 'normal-wastage-o':U
                      buf_gds-obj-attr.attr-value = string(ub.goods.normal-wastage)
                    .
                    release buf_gds-obj-attr.
                  end.
            end.
            assign
             ub.goods.normal-wastage = 0
            .
         end.
  end.
  hide frame info-init .
  delete object w-initnwast .
  delete widget-pool "wind-info" .
  if v-err-message <> "":U then do:
    return error v-err-message .
  end.
  else do:
    return .
  end.
end.
