block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: initnwas.p $
$Archive: adm/initnwas.p $

Процедура инициализации атрибута mormal-wastage-o

Автор: Комаров Иван Сергеевич
Дата создания: 03/10/11
Author: Ivan Komarov
Creation date: 03/10/11

*/

define input  parameter p-artic     like ub.goods.artic     no-undo.
define input  parameter p-prod-type like ub.goods.prod-type no-undo.
define input  parameter p-prod-code like ub.goods.prod-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: initnwas.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/initnwas.p $":U .
define variable vss-description as character no-undo init "Процедура инициализации атрибута insalepr".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
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
        v-err-message = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
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
                      and buf_gds-obj-attr.attr-code = {&attr-normal-wastage-o})
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
                      buf_gds-obj-attr.attr-code  = {&attr-normal-wastage-o}
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