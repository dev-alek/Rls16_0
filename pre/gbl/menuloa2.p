block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 89045e861607, 3582, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/14 13:36:13 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: menuloa2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/menuloa2.p $":U .
define variable vss-description as character no-undo init "".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr1 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт доп. бар-кодов, внеш. ПН, ДНЦ'  p-proc-file = 'utl/rinpall.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr3 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт групп товаров'  p-proc-file = 'utl/imp-ggr.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr5 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт (изменение) клиентов'  p-proc-file = 'utl/impcli.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr7 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт договоров с поставщиками'  p-proc-file = 'bge/impcontract.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr9 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт товаров'  p-proc-file = 'utl/rnpimpgds.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr11 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт в формате импорта приходной накладной (ПН)'  p-proc-file = 'utl/exp-doc.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr13 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Выгрузка остатков в формате импорта ПН'  p-proc-file = 'utl/exp-doc2.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr15 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Выгрузка текущих остатков в формате импорта ПН'  p-proc-file = 'utl/exp-doc3.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr17 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт остатков по партиям'  p-proc-file = 'utl/exp-doc4.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr19 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Загрузка GTIN и штрих-коды маркированной продукции '  p-proc-file = 'bge/loadGTINMark.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr21 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Сбор данных по GTIN и штрих-кодам'  p-proc-file = 'bge/impGTINbarcode.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr23 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт накладных по партиям'  p-proc-file = 'utl/impdoc4run.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr25 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт топливных накладных по партиям'  p-proc-file = 'utl/impdoc4run-ptrl.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr27 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт для Фэшн групп'  p-proc-file = 'cus/imp-fg1.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'NG' .
end procedure .
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr29 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт в формате импорта документа назначения цены(ДНЦ)'  p-proc-file = 'utl/exp-pric.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr31 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Выгрузка информации в систему Малина'  p-proc-file = 'bge/exp-malina-man.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr33 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Выгрузка товарного классификатора (ВБРР\Скантек) '  p-proc-file =  'bge/exp-VBRR-man.p'   p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr35 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Выгрузка в систему АТД'  p-proc-file =  'bge/p-exp-ATD.p'   p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr37 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Выгрузка ВБРР'  p-proc-file =  'bge/e-help-road.p'   p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr39 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт данных по пополнениям и активации для сверки с ВБРР'  p-proc-file =  'bge/bge-active-vbrr-p.p'   p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr41 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Выгрузка товарного классификатора (Лояльность\Скантек) '  p-proc-file =  'bge/exp-loyal-man.p'   p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr43 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Выгрузка информации в систему Carbon'  p-proc-file = 'bge/exp-carbon-man.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr45 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт документов в формате импорта'  p-proc-file = 'utl/exp-doc.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr47 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт состава сырья'  p-proc-file = 'utl/struct.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr49 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт диск.карт из файла'  p-proc-file = 'utl/impdcrdr.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr51 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт данных для Луи Вуиттон'  p-proc-file = 'cus/imp-lui.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
    assign p-client = 'Vitton' .
end procedure .
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr53 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт классификатора ЕГАИС'  p-proc-file = 'utl/i-egais.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info54 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_fin_impexp%cr55 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_fin_impexp":u p-proc-name = 'Импорт Платежных Поручений (Бизнес-Букет)'  p-proc-file = 'bge/cbnkrunie.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
      run gbl/conf-rd.p ( 'clntbank', "", "", 0, "", "", "", yes, output conf-par, output par-type) no-error.
      if error-status:error or par-type <> "l" or conf-par <> "yes" then do:  return error. end.
end procedure .
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_fin_impexp%cr57 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_fin_impexp":u p-proc-name = 'ЭКСПОРТ в систему КЛИЕНТ-БАНК'  p-proc-file = 'bge/cbnkrune.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
      run gbl/conf-rd.p ( 'clntbank', "", "", 0, "", "", "", yes, output conf-par, output par-type) no-error.
      if error-status:error or par-type <> "l" or conf-par <> "yes" then do:  return error. end.
end procedure .
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_fin_impexp%cr59 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_fin_impexp":u p-proc-name = 'ИМПОРТ из системы КЛИЕНТ-БАНК'  p-proc-file = 'bge/cbnkruni.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
      run gbl/conf-rd.p ( 'clntbank', "", "", 0, "", "", "", yes, output conf-par, output par-type) no-error.
      if error-status:error or par-type <> "l" or conf-par <> "yes" then do:  return error. end.
end procedure .
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_fin_impexp%cr61 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_fin_impexp":u p-proc-name = 'Импорт Платежных Поручений (Бизнес-Букет)'  p-proc-file = 'bge/cbnkrunie.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
      run gbl/conf-rd.p ( 'clntbank', "", "", 0, "", "", "", yes, output conf-par, output par-type) no-error.
      if error-status:error or par-type <> "l" or conf-par <> "yes" then do:  return error. end.
end procedure .
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_fin_impexp%cr63 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_fin_impexp":u p-proc-name = 'Импорт договоров с поставщиками'  p-proc-file = 'bge/impcontract.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr65 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Сменный отчет (Старый формат)'  p-proc-file = 'rep/g-shift.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr67 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Общая сличительная ведомость '  p-proc-file = 'rep/g-sl-ved.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr69 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Сверка транзакций перевода средств ОСС (Кубаньнефтепродукт)'  p-proc-file = 'rep/g-rnk-oss.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr71 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Понедельный отчет по товарам (реализация в магазине)'  p-proc-file = 'rep/g-weekm.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info72 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr73 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Остатки на текущий момент по товарам, оприходованным до ...'  p-proc-file = 'rep/g-oldrst.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info74 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr75 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по платежным системам '  p-proc-file = 'rep/g-paysys.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info76 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr77 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Сверка по оплатам QR-кодом'  p-proc-file = 'rep/g-QR-rep.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info78 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr79 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Сверка по транзакциям Яндекс'  p-proc-file = 'rep/g-yandex-rep.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info80 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr81 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет для контроля возвратных операций'  p-proc-file = 'rep/g-vbbr_return.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info82 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr83 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Остатки на опр. дату товаров, оприход. за данный период'  p-proc-file = 'rep/r-parts.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info84 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr85 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Реестр документов (Товарный отчет) по секциям'  p-proc-file = 'cus/r-reestr.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info86 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr87 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет для сверки ВБРР-Виза'  p-proc-file = 'rep/g-vbbr_viza.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info88 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr89 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Продажи топлива и сервисного элемента'  p-proc-file = 'rep/g-topsrv.p'  p-install = lookup ( "  ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info90 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr91 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Расход нефтепродуктов через ТРК'  p-proc-file = 'rep/g-petsal.p'  p-install = lookup ( "  ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info92 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr93 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Расход нефтепродуктов по документам'  p-proc-file = 'rep/g-petnak.p'  p-install = lookup ( "  ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info94 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr95 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Помесячный оборот по магазинам в ценах продаж (Excel)'  p-proc-file = 'rep/g-xlben.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info96 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr97 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Помесячный оборот по производителям в ценах продаж (Excel)'  p-proc-file = 'rep/g-xlprod.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info98 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr99 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Помесячный оборот по произв-лю и классификатору (Excel)'  p-proc-file = 'rep/g-xlseas.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info100 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr101 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Помесячная реализация в магазине (Excel)'  p-proc-file = 'rep/g-xlreal.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info102 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr103 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Товары чеков с ценой, отличной от цены прайса (Excel)'  p-proc-file = 'cus/g-retprc.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info104 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr105 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Партии товаров по документам (Excel)'  p-proc-file = 'rep/g-slprts.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info106 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr107 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Движение товара по месту хранения (Excel) BENETTON'  p-proc-file = 'cus/g-benet1.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '10.3'  p-run-order = '1' .
    assign p-client = 'BENETTON' .
end procedure .
define variable vss-include-info108 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr109 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Движение товара - сводный отчет (Excel) BENETTON'  p-proc-file = 'cus/g-benet2.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '10.3'  p-run-order = '1' .
    assign p-client = 'BENETTON' .
end procedure .
define variable vss-include-info110 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr111 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по процентам скидки реализ. товара (Excel) BENETTON'  p-proc-file = 'cus/g-benet3.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '10.3'  p-run-order = '1' .
    assign p-client = 'BENETTON,ODIS,Vavilon' .
end procedure .
define variable vss-include-info112 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr113 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет о реализации товара (Excel) BENETTON'  p-proc-file = 'cus/g-benet4.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '10.3'  p-run-order = '1' .
    assign p-client = 'BENETTON' .
end procedure .
define variable vss-include-info114 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr115 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Остатки по объектам (Excel) BENETTON'  p-proc-file = 'cus/g-benet5.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'BENETTON' .
end procedure .
define variable vss-include-info116 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr117 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Редактирование списка количества товара на объекте'  p-proc-file = 'utl/gdsobjls.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.0'  p-run-order = '1' .
    assign p-client = 'ZUM' .
end procedure .
define variable vss-include-info118 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr119 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по продажам через кассы'  p-proc-file = 'rep/g-venit.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info120 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr121 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Оборот в валюте поставщика'  p-proc-file = 'cus/g-obval.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.0'  p-run-order = '1' .
    assign p-client = 'KREST' .
end procedure .
define variable vss-include-info122 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr123 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Остатки и оборот товаров по фирме'  p-proc-file = 'utl/ut-stk.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'TATI' .
end procedure .
define variable vss-include-info124 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr125 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Начисление и списание бонусов по программе БОНУС-КЛУБ'  p-proc-file = 'cus/g-bonus1.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
    assign p-client = 'Irk-Oil' .
end procedure .
define variable vss-include-info126 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr127 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Утилита для привязывания единицы измерения к товарам'  p-proc-file = 'utl/unit-goods.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info128 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr129 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Выгрузка данных по реализации в учетных ценах (.dbf)'  p-proc-file = 'rep/g-seb1c.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info130 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr131 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "impexp":u p-proc-name = 'Выгрузка всех цен по всем объектам'  p-proc-file = 'utl/put-pr.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info132 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr133 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт карточек товаров из Trade'  p-proc-file = 'utl/impgds.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info134 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr135 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт товаров'  p-proc-file = 'utl/rnp-imp-gds.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info136 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr137 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "impexp":u p-proc-name = 'Экспорт справочных данных для АТД клиента'  p-proc-file = 'utl/dict-atd-exp-run.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info138 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr139 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "function":u p-proc-name = 'Пересчет учетной цены в переоценке на момент закрытия по всем объектам'  p-proc-file = 'utl/pr-csac.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info140 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr141 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "function":u p-proc-name = 'Заполнение параметров ГРУПП товаров по ОБЪЕКТАМ'  p-proc-file = 'utl/inigrpcm.w'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info142 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr143 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "function":u p-proc-name = 'Пересчет архивных партий по закрытой переоценке'  p-proc-file = 'utl/pr-ut10.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info144 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr145 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "function":u p-proc-name = 'Инициализация цены в открытом документе по справочнику товаров (если нет переоценки)'  p-proc-file = 'utl/invprice.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info146 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr147 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "function":u p-proc-name = 'Изменение даты инкрементальной выгрузки'  p-proc-file = 'bge/setincrd.w'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info148 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr149 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "function":u p-proc-name = 'Изменение даты выгрузки данных в SAP (СургутНефтегаз)'  p-proc-file = 'bge/setsapsngd.w'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info150 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr151 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "function":u p-proc-name = 'Изменение даты выгрузки данных'  p-proc-file = 'bge/setmalinad.w'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info152 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr153 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "function":u p-proc-name = 'Просмотр правил работы ИЖТ'  p-proc-file = 'gbl/iztrul.w'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info154 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr155 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "function":u p-proc-name = 'Пересчет документов по продажным ценам по партиям'  p-proc-file = 'utl/prpar-1.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info156 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr157 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет о состоянии запаса и продажах (Excel)'  p-proc-file = 'rep/g-zap-pr.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info158 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr159 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по поставщикам'  p-proc-file = 'rep/g-sup-ia.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'Trg' .
end procedure .
define variable vss-include-info160 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr161 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Все чеки по выбранным объектам'  p-proc-file = 'cus/g-zum1.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'ZUM' .
end procedure .
define variable vss-include-info162 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr163 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Все строки чеков по выбранным объектам'  p-proc-file = 'cus/g-zum2.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'ZUM' .
end procedure .
define variable vss-include-info164 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr165 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Все строки чеков (товар и оплата) по выбранным объектам'  p-proc-file = 'cus/g-zum3.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'ZUM' .
end procedure .
define variable vss-include-info166 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr167 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Все строки чеков (с указанием состава сырья) по выбранным объектам'  p-proc-file = 'cus/g-zum4.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'ZUM,UKOS,raimbek' .
end procedure .
define variable vss-include-info168 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr169 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'ОТЧЕТ ПО ДОКУМЕНТАМ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ)'  p-proc-file = 'cus/g-zum5.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'ZUM' .
end procedure .
define variable vss-include-info170 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr171 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет объединенная счет-фактура по ответственному хранению'  p-proc-file = 'cus/g-otv-xr.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'ZUM' .
end procedure .
define variable vss-include-info172 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr173 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Оперативная сводная оборотная ведомость (для небольшого периода)'  p-proc-file = 'cus/gzobor-s.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info174 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr175 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Печать прайс-листа (по переоценкам) с сортировкой по наименованию'  p-proc-file = 'rep/g-glprcl.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'GreenL' .
end procedure .
define variable vss-include-info176 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr177 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по движению товара - сводный (Excel) BENETTON'  p-proc-file = 'rep/g-ben-dt.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'BENETTON' .
end procedure .
define variable vss-include-info178 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr179 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт РКС'  p-proc-file = 'rcs/rcsimp.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.2'  p-run-order = '1' .
    assign p-client = 'rcs' .
end procedure .
define variable vss-include-info180 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr181 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Расчет необходимого товарного запаса (Excel)'  p-proc-file = 'rep/g-spd-p.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.2'  p-run-order = '1' .
end procedure .
define variable vss-include-info182 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr183 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Остатки по УБД (Excel)'  p-proc-file = 'cus/g-ost-bd.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info184 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr185 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Накладная по реализации в магазине'  p-proc-file = 'cus/g-taxtrh.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'hill' .
end procedure .
define variable vss-include-info186 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr187 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Аналитические отчеты ACTUATE'  p-proc-file = 'rep/p-actua.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info188 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr189 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт результатов продаж по признакам (старая версия)'  p-proc-file = 'cus/exp-kan1.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'Can_Ru' .
end procedure .
define variable vss-include-info190 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr191 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт текущих товарных остатков'  p-proc-file = 'cus/exp-kan3.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'Can_Ru' .
end procedure .
define variable vss-include-info192 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr193 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт результатов продаж по признакам'  p-proc-file = 'cus/exp-kan0.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'Can_Ru' .
end procedure .
define variable vss-include-info194 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr195 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт текущих товарных остатков по признакам'  p-proc-file = 'cus/exp-kan2.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'Can_Ru' .
end procedure .
define variable vss-include-info196 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr197 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Конвертор данных (Can_Ru) - импорт'  p-proc-file = 'cus/imp-kan1.w'  p-install = lookup ( "false ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'Can_Ru' .
end procedure .
define variable vss-include-info198 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr199 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Удаление ВСЕХ записей маршрутизации по ПОДТВЕРЖДЕННЫМ пакетам'  p-proc-file = 'utl/delroute.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'SportC' .
end procedure .
define variable vss-include-info200 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr201 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт дополнительных бар-кодов по товарам'  p-proc-file = 'utl/upload1.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'Moroz' .
end procedure .
define variable vss-include-info202 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr203 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт результатов продаж  по поставщику'  p-proc-file = 'cus/exp-meri.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
    assign p-client = 'Mari' .
end procedure .
define variable vss-include-info204 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr205 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по сумме кассовых услуг, оказанных агентом'  p-proc-file = 'cus/g-princp.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'PeacHom' .
end procedure .
define variable vss-include-info206 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr207 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Сравнительный отчет по ценам товара на объектах (Excel)'  p-proc-file = 'cus/g-z-posr.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info208 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr209 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Количественный отчет по 2х-уровневой шкале (Excel)'  p-proc-file = 'rep/g-2-qnty.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
    assign p-client = 'ZUM' .
end procedure .
define variable vss-include-info210 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr211 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Объединенные документы для смены типа приобретения'  p-proc-file = 'rep/g-corpr.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info212 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr213 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Запрос на получение архива чеков с касс NCR'  p-proc-file = 'str/getncryr.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'Spar,ProdS' .
end procedure .
define variable vss-include-info214 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr215 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Продажи постоянным клиентам (Excel) LuiVuitton'  p-proc-file = 'cus/g-vuidc.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
    assign p-client = 'Vitton' .
end procedure .
define variable vss-include-info216 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr217 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Проставить признак блюда для товаров с рецептом производства'  p-proc-file = 'utl/fbrsetim.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info218 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr219 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Дни продажи товара '  p-proc-file = 'cus/g-mar1.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
    assign p-client = 'Mari' .
end procedure .
define variable vss-include-info220 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr221 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по контрагентам списания'  p-proc-file = 'cus/g-ospis.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
    assign p-client = 'Suzdal,ODIS,Vavilon' .
end procedure .
define variable vss-include-info222 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr223 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по приходу товара в текстовый файл'  p-proc-file = 'cus/xl-in.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info224 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr225 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по расходу товара в текстовый файл'  p-proc-file = 'cus/xl-out.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info226 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr227 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по движению товаров в текстовый файл'  p-proc-file = 'cus/xl-move.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info228 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr229 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт документов прихода и расхода (в т.ч. незакрытых)'  p-proc-file = 'utl/g-expie.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'BDC,Suzdal,Moroz' .
end procedure .
define variable vss-include-info230 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr231 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт чеков (расширенный формат)'  p-proc-file = 'bge/exp-bgecheck.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.2'  p-run-order = '1' .
end procedure .
define variable vss-include-info232 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr233 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт чеков'  p-proc-file = 'bge/bgecheck.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.2'  p-run-order = '1' .
end procedure .
define variable vss-include-info234 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr235 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт данных для АС <Движение н/п в ТПС>'  p-proc-file = 'bge/bge-ais.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.2'  p-run-order = '1' .
    assign p-client = 'yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info236 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr237 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Экспорт справочников товаров (расширенный)'  p-proc-file = 'bge/bgeextgi.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.2'  p-run-order = '1' .
    assign p-client = 'Suzdal' .
end procedure .
define variable vss-include-info238 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr239 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет о движении товаров через кассу'  p-proc-file = 'cus/g-bb.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.0'  p-run-order = '1' .
    assign p-client = 'TopAukc' .
end procedure .
define variable vss-include-info240 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr241 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Реестр документов по объектам'  p-proc-file = 'rep/g-reesto.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info242 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr243 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Выгрузка в файл данных по продажам по СКМ'  p-proc-file = 'cus/g-skm.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info244 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr245 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт запроса на внешний расход'  p-proc-file = 'utl/im-zapvr.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info246 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr247 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет - Аннуляция чеков'  p-proc-file = 'cus/g-a-chkv.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info248 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr249 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет - Возврат товаров'  p-proc-file = 'cus/g-v-chkv.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info250 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr251 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет - Общая (Кассовый фонд,инкассация,перевод оплаты)'  p-proc-file = 'cus/g-o-chkv.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info252 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr253 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Почасовая реализация на АЗС'  p-proc-file = 'rep/g-hazkrt.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info254 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr255 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Сводная ведомость по клиентам'  p-proc-file = 'cus/g-elved1.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info256 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr257 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Ведомость клиента за период времени'  p-proc-file = 'cus/g-elved2.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info258 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr259 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Представленность матрицы товаров на объекте'  p-proc-file = 'rep/g-mattov.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info260 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr261 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Реализация по сменам (по группам товаров)'  p-proc-file = 'rep/g-shftrl.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info262 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr263 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Журнал продаж (Excel)'  p-proc-file = 'rep/g-jor-ru.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'IAB' .
end procedure .
define variable vss-include-info264 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr265 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Состояние запаса (Excel)'  p-proc-file = 'rep/g-zap-ru.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
    assign p-client = 'IAB' .
end procedure .
define variable vss-include-info266 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr267 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Реестр документов (Кедр-М)'  p-proc-file = 'rep/g-reestd.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info268 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr269 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Реализация с печатью накладной поставщика и ГТД (Excel)'  p-proc-file = 'rep/g-gpcst.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
    assign p-client = 'Sporty' .
end procedure .
define variable vss-include-info270 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr271 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Документы возврата в разрезе накладных поставщика и ГТД (Excel)'  p-proc-file = 'rep/g-cstvz.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'Sporty' .
end procedure .
define variable vss-include-info272 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr273 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Продажи за неделю для Nielsen'  p-proc-file = 'rep/g-exp-sl.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info274 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr275 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Реализация (Кедр-М)'  p-proc-file = 'rep/g-kfsale.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info276 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr277 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Реализация и остатки (Кедр-М)'  p-proc-file = 'rep/g-kfreba.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info278 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr279 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Акт переоценки ТАП-1 за период'  p-proc-file = 'rep/g-tap.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info280 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr281 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет о продажах топлива по лотерейным билетам АВТОКУШ'  p-proc-file = 'cus/g-autocu.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info282 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr283 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Оборотная ведомость по партиям с ценами производителя (Аптека)'  p-proc-file = 'rep/g-obprt3.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info284 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr285 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по движению СТ. НТФ-8.9'  p-proc-file = 'rep/g-torg89.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info286 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr287 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Сводный отчет по движению СТ. НТФ-8.10 (Кедр-М)'  p-proc-file = 'rep/g-trg810.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info288 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr289 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по продажам в разрезе платежных карт'  p-proc-file = 'cus/g-cpych.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info290 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr291 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Прайс-лист с фото товаров'  p-proc-file = 'rep/g-prphot.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'TopAukc' .
end procedure .
define variable vss-include-info292 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr293 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Движение денежных средств (Кедр-М)'  p-proc-file = 'rep/g-ddinrn.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info294 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr295 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по бонусам'  p-proc-file = 'rep/g-bonus.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info296 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr297 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Расчет естественной убыли'  p-proc-file = 'rep/g-calcwast.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'ODIS' .
end procedure .
define variable vss-include-info298 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr299 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет по списаниям'  p-proc-file = 'rep/g-wr-off.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info300 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr301 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Импорт глобальных атрибутов товара (Йошкар-Ола)'  p-proc-file = 'rep/g-attr-imp.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'ODIS,Gurman' .
end procedure .
define variable vss-include-info302 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr303 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Сличительная ведомость по результатам инвентаризации (Роснефть)'  p-proc-file = 'rep/g-inv-RN.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info304 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr305 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Данные о реализации НП на АЗС за период (ТамбовНП)'  p-proc-file = 'rep/g-rnpazs.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info306 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr307 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Движение одноразовой посуды по кафе (Роснефть)'  p-proc-file = 'rep/g-mdtc.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'Yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info308 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr309 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Суточные сводки (ТамбовНП)'  p-proc-file = 'rep/g-tdsum.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info310 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_customs%cr311 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_customs":u p-proc-name = 'Отчет об отчислениях в ЛПВ'  p-proc-file = 'rep/g-asLPV.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
    assign p-client = 'yukos,ibs,Rosneft-*' .
end procedure .
define variable vss-include-info312 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr313 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Начальное формирование справочника критериев анализа'  p-proc-file = 'utl/abc-utl.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info314 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr315 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Изменение ставки НДС на 20% в спецификациях'  p-proc-file = 'utl/specifNDS.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info316 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr317 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Информация о складских архивах'  p-proc-file = 'utl/ah-infov.w'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info318 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr319 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Редактирование сроков годности партий товара'  p-proc-file = 'rep/g-parlas.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info320 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr321 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Утилита копирования состава товара'  p-proc-file = 'utl/coppy_tov.p'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info322 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr323 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Коррекция партий внешнего прихода закрытого на факт'  p-proc-file = 'utl/trn-vatt.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info324 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr325 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Коррекция партий внешнего прихода МФ закрытого на факт'  p-proc-file = 'utl/trn-vath.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info326 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr327 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Привязка партий и складских документов к договору поставщика'  p-proc-file = 'utl/fillcont.w'  p-install = lookup ( "false", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info328 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr329 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Переименование артикула и(или) производителя'  p-proc-file = 'utl/run-nar1.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info330 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr331 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Досылка сформированных файлов на кассу IBM-XML'  p-proc-file = 'str/rsndxibr.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info332 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr333 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Обновление реквизитов клиентов в незакрытых платежах из договора'  p-proc-file = 'utl/updfind.w'  p-install = lookup ( "false", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info334 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr335 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Простановка ГТД во все партии по списку ПН (тек.БД)'  p-proc-file = 'utl/trncstsl.p'  p-install = lookup ( "false", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info336 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr337 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Пересчет баланса ФО и платежей к договору'  p-proc-file = 'utl/cont-bal.p'  p-install = lookup ( "false", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info338 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr339 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Экспорт настроек объектов TH'  p-proc-file = 'utl/thbjexp.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info340 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr341 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Конфигурация машины правил - RuM'  p-proc-file = 'rul/rulconfig.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info342 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr343 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Конфигурация правил скидок'  p-proc-file = 'utl/drconfig.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info344 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr345 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Конфигурация настраиваемых полей'  p-proc-file = 'utl/cus-lblr.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = '' .
end procedure .
define variable vss-include-info346 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr347 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Конфигурация атрибутов'  p-proc-file = 'utl/attrpcfg.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info348 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr349 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Конфигурация гейтов'  p-proc-file = 'utl/gates.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info350 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr351 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Конфигурация раскладок'  p-proc-file = 'adm/lay-conf.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info352 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr353 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Удаление фильтров и пользовательских настроек'  p-proc-file = 'utl/clearflt.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info354 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr355 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Конфигурация логирования кассы IBS TH POS'  p-proc-file = 'adm/cdevconf.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'IBS' .
end procedure .
define variable vss-include-info356 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr357 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Закрытие договоров, срок действия которых истёк'  p-proc-file = 'utl/contrcls.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info358 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr359 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Генерация ПН по РН'  p-proc-file = 'utl/g-florma.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
    assign p-client = 'TopAukc' .
end procedure .
define variable vss-include-info360 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr361 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Мониторинг инкрементальной выгрузки в XML'  p-proc-file = 'rep/inc-upl-mon.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info362 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr363 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Загрузка фото товаров'  p-proc-file = 'utl/imgsearch.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info364 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr365 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Перенос изображений в новую структуру'  p-proc-file = 'utl/image2lst.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info366 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr367 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Генерация пароля для технологического пролива'  p-proc-file = 'utl/gen-pwd.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info368 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_utility%cr369 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_utility":u p-proc-name = 'Импорт GTIN из файла'  p-proc-file = 'utl/imp-gtin.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info370 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_check%cr371 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_check":u p-proc-name = 'Tест корректности отчета о продаже'  p-proc-file = 'utl/test000i.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info372 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_check%cr373 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_check":u p-proc-name = 'Tест корректности чеков'  p-proc-file = 'utl/test000.w'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.1'  p-run-order = '1' .
end procedure .
define variable vss-include-info374 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_check%cr375 :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .
  define variable par-type  as character no-undo .
  assign p-call-point      = "service_check":u p-proc-name = 'Проверка партий и складских документов на соответствие договора поставщика'  p-proc-file = 'utl/chk-cont.p'  p-install = lookup ( "false", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.0'  p-run-order = '1' .
end procedure .
