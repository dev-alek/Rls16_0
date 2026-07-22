block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 03b1296bf1bc, 3388, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/06/07 13:19:21 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: menuload.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/menuload.p $":U .
define variable vss-description as character no-undo init "Информация об объекте интерфейса".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr1 :
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
  assign p-call-point      = "version":u p-proc-name = 'Перенос данных из старой БД в 16.0 (РАСТЯНУТЫЙ UPGRADE)'  p-proc-file = 'utl/thth-all.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr3 :
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
  assign p-call-point      = "version":u p-proc-name = 'Приходы,расходы,возвраты по контрагентам(пересчет итогов)'  p-proc-file = 'utl/incligds.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr5 :
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
  assign p-call-point      = "version":u p-proc-name = 'Исправление названий групп товаров'  p-proc-file = 'utl/inigrpu.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr7 :
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
  assign p-call-point      = "version":u p-proc-name = 'Исправление названий групп клиентов'  p-proc-file = 'utl/inicliu.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr9 :
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
  assign p-call-point      = "version":u p-proc-name = 'Партии товаров'  p-proc-file = 'utl/ini-part.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr11 :
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
  assign p-call-point      = "version":u p-proc-name = 'Фирма в складских документах и товарах'  p-proc-file = 'utl/ini-host.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr13 :
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
  assign p-call-point      = "version":u p-proc-name = 'Нац.вал., основные единицы и пр.'  p-proc-file = 'utl/kick-db.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr15 :
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
  assign p-call-point      = "version":u p-proc-name = 'Установка метода расчета учетных цен FIFO для всех товаров'  p-proc-file = 'utl/ini-cost.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr17 :
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
  assign p-call-point      = "version":u p-proc-name = 'Проверка ссылок на товар для товаров на объекте'  p-proc-file = 'utl/chk-gdsd.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr19 :
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
  assign p-call-point      = "version":u p-proc-name = 'Инициализация остатков по поставщикам'  p-proc-file = 'utl/ini-supp.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr21 :
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
  assign p-call-point      = "version":u p-proc-name = 'Дата создания партий (в свободной и расходной зоне)'  p-proc-file = 'utl/ini-pfdt.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr23 :
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
  assign p-call-point      = "version":u p-proc-name = 'Название на этикетке по русскому названию товара'  p-proc-file = 'utl/ini-labl.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr25 :
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
  assign p-call-point      = "version":u p-proc-name = 'Составные товары / ингредиенты в производстве'  p-proc-file = 'utl/ini-comp.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr27 :
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
  assign p-call-point      = "version":u p-proc-name = 'Пересчет расходных накладных(НДС)'  p-proc-file = 'utl/recl-vat.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr29 :
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
  assign p-call-point      = "version":u p-proc-name = 'Поиск и удаление неправильных записей prt-obj'  p-proc-file = 'utl/chkprtob.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr31 :
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
  assign p-call-point      = "version":u p-proc-name = 'Инициализация атрибутов товара на объекте'  p-proc-file = 'utl/allgdsat.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr33 :
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
  assign p-call-point      = "version":u p-proc-name = 'Инициализация атрибута: резервирование товара по складским местам'  p-proc-file = 'utl/plcrsrv.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '10.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr35 :
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
  assign p-call-point      = "version":u p-proc-name = 'Проставить фактические номера документов'  p-proc-file = 'utl/factofil.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '10.3'  p-run-order = '4' .
end procedure .
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr37 :
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
  assign p-call-point      = "version":u p-proc-name = 'Создание бар-кодов партий для товаров, которые продаются по партиям'  p-proc-file = 'utl/allbccr.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '10.3'  p-run-order = '6' .
end procedure .
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr39 :
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
  assign p-call-point      = "version":u p-proc-name = 'Поиск и исправление приходов с автоматическими переоценками с неправильным fact-num'  p-proc-file = 'utl/chk-trn.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '10.4'  p-run-order = '2' .
end procedure .
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr41 :
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
  assign p-call-point      = "version":u p-proc-name = 'Установка признаков клиентов'  p-proc-file = 'utl/chng-cli.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.0'  p-run-order = '2' .
end procedure .
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr43 :
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
  assign p-call-point      = "version":u p-proc-name = 'Инициализация неопределенных учетных цен в партиях'  p-proc-file = 'utl/docpartn.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr45 :
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
  assign p-call-point      = "version":u p-proc-name = 'Создание атрибутов партий'  p-proc-file = 'utl/objprtat.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr47 :
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
  assign p-call-point      = "version":u p-proc-name = 'Выравнивание остатков по партиям свободной зоны'  p-proc-file = 'utl/vpargds.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.2'  p-run-order = '1' .
end procedure .
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr49 :
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
  assign p-call-point      = "version":u p-proc-name = 'Проталкивание параметров Накладных и Переоценок из ГБД в УБД'  p-proc-file = 'utl/movnwsgp.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '15.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr51 :
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
  assign p-call-point      = "version":u p-proc-name = 'Инициализация дат начала и конца движения товара на объекте'  p-proc-file = 'utl/gdsolasd.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.0'  p-run-order = '4' .
end procedure .
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr53 :
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
  assign p-call-point      = "version":u p-proc-name = 'Проверка налогов в переоценке'  p-proc-file = 'utl/g-pr-u8.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info54 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr55 :
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
  assign p-call-point      = "version":u p-proc-name = 'Создание ассортиментной матрицы на основе таблицы gds-obj за вычетом атрибута attr-no-income-goods'  p-proc-file = 'utl/crassmxa.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure version%cr57 :
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
  assign p-call-point      = "version":u p-proc-name = 'Отправить настройки пользователей - права, меню по новостям'  p-proc-file = 'utl/sndusrnw.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr59 :
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
  assign p-call-point      = "function":u p-proc-name = 'Корекция даты на объекте'  p-proc-file = 'utl/cor-date.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr61 :
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
  assign p-call-point      = "function":u p-proc-name = 'Изменение статуса сверки'  p-proc-file = 'utl/cor-rvs_status.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr63 :
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
  assign p-call-point      = "function":u p-proc-name = 'Единицы измерения по списку товаров'  p-proc-file = 'utl/ini-unit.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr65 :
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
  assign p-call-point      = "function":u p-proc-name = 'Восстановление статуса БД'  p-proc-file = 'utl/fix-db-stts.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr67 :
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
  assign p-call-point      = "function":u p-proc-name = 'Включение выключенных доп. БК'  p-proc-file = 'utl/bc-on.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr69 :
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
  assign p-call-point      = "function":u p-proc-name = 'Имена контрагентов в накладных'  p-proc-file = 'utl/ini-name.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '11.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr71 :
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
  assign p-call-point      = "function":u p-proc-name = 'Изменение артикула товара'  p-proc-file = 'utl/run-nart.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info72 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr73 :
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
  assign p-call-point      = "function":u p-proc-name = 'Изменение производителя товара по списку товаров'  p-proc-file = 'utl/pren-art.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info74 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr75 :
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
  assign p-call-point      = "function":u p-proc-name = 'Смена группы по списку товаров'  p-proc-file = 'utl/mov-grp.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info76 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr77 :
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
  assign p-call-point      = "function":u p-proc-name = 'Контекстная замена в названиях товаров'  p-proc-file = 'adm/rplc-gds.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info78 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr79 :
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
  assign p-call-point      = "function":u p-proc-name = 'Утилита проверки целостности свободной зоны марок'  p-proc-file = 'rep/g-alcmarks.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info80 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr81 :
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
  assign p-call-point      = "function":u p-proc-name = 'Утилита отката помарочного учета'  p-proc-file = 'utl/rollback-mark.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info82 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr83 :
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
  assign p-call-point      = "function":u p-proc-name = 'Выравнивание статусов марок в свободной зоне'  p-proc-file = 'utl/free-mark.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info84 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr85 :
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
  assign p-call-point      = "function":u p-proc-name = 'Создание статусов марок в серой зоне'  p-proc-file = 'utl/gray-zone.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info86 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr87 :
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
  assign p-call-point      = "function":u p-proc-name = 'Изменение товаров по списку'  p-proc-file = 'utl/gdsuform.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info88 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr89 :
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
  assign p-call-point      = "function":u p-proc-name = 'Изменение дисконтных карт по списку'  p-proc-file = 'utl/discarui.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info90 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr91 :
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
  assign p-call-point      = "function":u p-proc-name = 'Изменить propath'  p-proc-file = 'utl/ppath.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info92 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr93 :
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
  assign p-call-point      = "function":u p-proc-name = 'Архивация чеков'  p-proc-file = 'utl/chk-arh.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info94 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr95 :
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
  assign p-call-point      = "function":u p-proc-name = 'Разархивация чеков'  p-proc-file = 'utl/undo-chk.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info96 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr97 :
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
  assign p-call-point      = "function":u p-proc-name = 'Снятие отметки <Требует переоценки> с товаров'  p-proc-file = 'utl/in-ov1.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info98 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr99 :
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
  assign p-call-point      = "function":u p-proc-name = 'Снять отметки <Требует переоценки> для удаленных товаров'  p-proc-file = 'utl/inov-del.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info100 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr101 :
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
  assign p-call-point      = "function":u p-proc-name = 'Изменить названия контрагентов в документах матценностей'  p-proc-file = 'utl/w-chclin.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info102 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr103 :
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
  assign p-call-point      = "function":u p-proc-name = 'Сортировка одного уровня шкалы'  p-proc-file = 'utl/sort-grp.w'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info104 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr105 :
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
  assign p-call-point      = "function":u p-proc-name = 'Переименование признаков шкалы'  p-proc-file = 'utl/rengrpsl.w'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info106 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr107 :
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
  assign p-call-point      = "function":u p-proc-name = 'Установка атрибутов товара РЕСТОРАН'  p-proc-file = 'utl/fbrgdsag.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info108 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr109 :
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
  assign p-call-point      = "function":u p-proc-name = 'Выполнить процедуру'  p-proc-file = 'gbl/d-runpro.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info110 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr111 :
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
  assign p-call-point      = "function":u p-proc-name = 'Простановка налогов по группам товаров'  p-proc-file = 'utl/inigrptx.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info112 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr113 :
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
  assign p-call-point      = "function":u p-proc-name = 'Раскрутка системы'  p-proc-file = 'utl/s-deploy.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info114 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr115 :
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
  assign p-call-point      = "function":u p-proc-name = 'Утилита проверки фото товаров'  p-proc-file = 'utl/img-check.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info116 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr117 :
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
  assign p-call-point      = "function":u p-proc-name = 'Асинхронные процессы'  p-proc-file = 'ref/procbrow.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info118 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr119 :
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
  assign p-call-point      = "function":u p-proc-name = 'Утилита работы с УТМ'  p-proc-file = 'bge/egais-utm.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info120 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr121 :
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
  assign p-call-point      = "function":u p-proc-name = 'Загрузка данных из ТН v15.0'  p-proc-file = 'utl/load-from-15_0.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info122 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr123 :
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
  assign p-call-point      = "function":u p-proc-name = 'Тиражная утилита'  p-proc-file = 'utl/draw-util.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info124 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr125 :
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
  assign p-call-point      = "function":u p-proc-name = 'Просмотр и изменение диапазонов кодов'  p-proc-file = 'utl/fixbcode.w'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info126 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr127 :
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
  assign p-call-point      = "function":u p-proc-name = 'Процедура проверки, восстановления Sequences'  p-proc-file = 'utl/rest_seq.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info128 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr129 :
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
  assign p-call-point      = "function":u p-proc-name = 'Экспорт/импорт прав и пользователей'  p-proc-file = 'utl/exp-imp.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info130 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr131 :
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
  assign p-call-point      = "function":u p-proc-name = 'Выравнивание остатков по массе'  p-proc-file = 'utl/reclck_go.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info132 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr133 :
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
  assign p-call-point      = "function":u p-proc-name = 'Корректировка даты на объекте'  p-proc-file = 'utl/cor-date.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info134 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr135 :
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
  assign p-call-point      = "function":u p-proc-name = 'Корректировка закрытых сверок'  p-proc-file = 'utl/updclrvs.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info136 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure function%cr137 :
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
  assign p-call-point      = "function":u p-proc-name = 'Удаление неиспользуемых дополнительных бар-кодов'  p-proc-file = 'utl/deleted_pbc.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
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
  assign p-call-point      = "function":u p-proc-name = 'Повторная выгрузка данных для 1С ERP'  p-proc-file = 'utl/send-1C.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
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
  assign p-call-point      = "function":u p-proc-name = 'Перевыгрузка не подтвержденных сообщений 1С ERP'  p-proc-file = 'utl/reload-1C.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
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
  assign p-call-point      = "function":u p-proc-name = 'Выгрузка данных в Президентский Мониторинг  '  p-proc-file = 'utl/run-exp-is_PM.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
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
  assign p-call-point      = "function":u p-proc-name = 'Синхронизация счетчиков документов'  p-proc-file = 'utl/seq-sync.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
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
  assign p-call-point      = "function":u p-proc-name = 'Повторная инициализация расчета контрольных значений НП по периодам'  p-proc-file = 'utl/init-shift-period_utl.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
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
  assign p-call-point      = "function":u p-proc-name = 'Утилита применения новых градуировочных таблиц'  p-proc-file = 'utl/apply_place-imp_utl.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
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
  assign p-call-point      = "function":u p-proc-name = 'Загрузка перечня IP TH'  p-proc-file = 'utl/thipimp.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info152 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr153 :
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
  assign p-call-point      = "check":u p-proc-name = 'Поиск выключенных весовых доп. БК'  p-proc-file = 'utl/udvespbc.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info154 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr155 :
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
  assign p-call-point      = "check":u p-proc-name = 'Получить список неактивных индексов'  p-proc-file = 'utl/idxinact.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info156 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr157 :
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
  assign p-call-point      = "check":u p-proc-name = 'Проверка целостности товара'  p-proc-file = 'utl/allcheck.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info158 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr159 :
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
  assign p-call-point      = "check":u p-proc-name = 'Проверка названий групп товаров'  p-proc-file = 'utl/inigrps.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info160 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr161 :
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
  assign p-call-point      = "check":u p-proc-name = 'Проверка названий групп клиентов'  p-proc-file = 'utl/iniclis.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info162 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr163 :
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
  assign p-call-point      = "check":u p-proc-name = 'Проверка строк переоценок'  p-proc-file = 'utl/fixprcls.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '10.3'  p-run-order = '2' .
end procedure .
define variable vss-include-info164 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr165 :
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
  assign p-call-point      = "check":u p-proc-name = 'Уникальность в группах клиентов'  p-proc-file = 'utl/cli-grpu.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info166 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr167 :
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
  assign p-call-point      = "check":u p-proc-name = 'Уникальность в группах товаров'  p-proc-file = 'utl/gds-grpu.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info168 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr169 :
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
  assign p-call-point      = "check":u p-proc-name = 'Совпадения основных и доп. БК'  p-proc-file = 'utl/bc-str.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info170 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr171 :
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
  assign p-call-point      = "check":u p-proc-name = 'Совпадения весовых кодов без ведущих нулей и доп. БК'  p-proc-file = 'utl/bc-scals.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info172 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr173 :
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
  assign p-call-point      = "check":u p-proc-name = 'Cовпадения доп. БК с вес. префиксом (EAN13) и весовых кодов'  p-proc-file = 'utl/fo-scals.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info174 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check%cr175 :
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
  assign p-call-point      = "check":u p-proc-name = 'Проверка наличия переоценок у товаров с ценой в справочнике'  p-proc-file = 'utl/pr-u11.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info176 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr177 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Информация о складских архивах'  p-proc-file = 'utl/ah-infov.w'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info178 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr179 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Утилита пересчета финансовых архивов'  p-proc-file = 'utl/rclcfarh1.w'  p-install = lookup ( "''", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = ''  p-run-order = '' .
end procedure .
define variable vss-include-info180 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr181 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Выполнить отложенные задания (BatchProcess)'  p-proc-file = 'utl/run-btpr.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info182 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr183 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Запретить/разрешить расчет архивов'  p-proc-file = 'utl/ah-disab.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.0'  p-run-order = '1' .
end procedure .
define variable vss-include-info184 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr185 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Установить признак отсутствия складских архивов'  p-proc-file = 'utl/ah-clin.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.0'  p-run-order = '5' .
end procedure .
define variable vss-include-info186 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr187 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Переименование атрибутов складских архивов'  p-proc-file = 'utl/renattr.p'  p-install = lookup ( "false", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info188 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr189 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Расчёт складского архива по товарам'  p-proc-file = 'utl/objarh.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '10.3'  p-run-order = '5' .
end procedure .
define variable vss-include-info190 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr191 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Расчёт складского архива по поставщикам'  p-proc-file = 'utl/objahsp.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '11.0'  p-run-order = '3' .
end procedure .
define variable vss-include-info192 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr193 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Расчёт складского архива по типам приобретения'  p-proc-file = 'utl/objaht.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info194 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr195 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Расчёт межфирменного архива по приходам и расходам'  p-proc-file = 'utl/harhclst.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.2'  p-run-order = '1' .
end procedure .
define variable vss-include-info196 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr197 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Расчёт межфирменного архива по инвентаризациям'  p-proc-file = 'utl/harh-inv.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info198 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr199 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Расчёт межфирменного архива по документам списания'  p-proc-file = 'utl/harh-spi.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info200 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr201 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Частичный расчет межфирменного архива по приходам и продажам'  p-proc-file = 'utl/hoca-sta.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info202 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr203 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Частичный расчет межфирменного архива по документам инвентаризации'  p-proc-file = 'utl/hoca-inv.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info204 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr205 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Частичный расчет межфирменного архива по документам списания'  p-proc-file = 'utl/hoca-spi.p'  p-install = lookup ( "yes", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info206 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr207 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Инициализация складского архива по товарам'  p-proc-file = 'utl/arh-init.p'  p-install = lookup ( "false", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info208 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr209 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Инициализация складского архива по поставщикам'  p-proc-file = 'utl/ahspinit.p'  p-install = lookup ( "false", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info210 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr211 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Инициализация складского архива по типам приобретения'  p-proc-file = 'utl/aht-init.p'  p-install = lookup ( "false", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
end procedure .
define variable vss-include-info212 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr213 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Проверка целостности документов переоценок'  p-proc-file = 'utl/chkprdoc.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info214 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr215 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Сжатие/удаление складского архива по товарам'  p-proc-file = 'utl/del-arh.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info216 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr217 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Восстановление складского архива по товарам'  p-proc-file = 'utl/rst-arh.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info218 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr219 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Проверка целостности складского архива по товарам'  p-proc-file = 'utl/cas-arh.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info220 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr221 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Проверка оборота переоценки архива по товарам'  p-proc-file = 'utl/prover-prc.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "no", "true,yes") > 0 .
end procedure .
define variable vss-include-info222 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr223 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Сжатие/удаление складского архива по поставщикам'  p-proc-file = 'utl/del-ahsp.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info224 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr225 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Восстановление складского архива по поставщикам'  p-proc-file = 'utl/rst-ahsp.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info226 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr227 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Проверка целостности складского архива по поставщикам'  p-proc-file = 'utl/cas-ahsp.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info228 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr229 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Сжатие/удаление складского архива по типам приобретения'  p-proc-file = 'utl/del-aht.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info230 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr231 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Восстановление складского архива по типам приобретения'  p-proc-file = 'utl/rst-aht.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info232 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr233 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Проверка целостности складского архива по типам приобретения'  p-proc-file = 'utl/cas-aht.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info234 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure archive%cr235 :
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
  assign p-call-point      = "archive":u p-proc-name = 'Инициализация фин. архива arh-trn-doc-contract'  p-proc-file = 'utl/g-initcn.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info236 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr237 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт доп. бар-кодов, внеш. ПН, ДНЦ'  p-proc-file = 'utl/rinpall.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info238 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr239 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Экспорт в формате импорта приходной накладной(ПН)'  p-proc-file = 'utl/exp-doc.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info240 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr241 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Экспорт в формате импорта документа назначения цены(ДНЦ)'  p-proc-file = 'utl/exp-pric.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info242 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr243 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт групп товаров'  p-proc-file = 'utl/impggr.w'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info244 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr245 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт состава сырья'  p-proc-file = 'utl/struct.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info246 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr247 :
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
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт ТНВЕД в карточку товара'  p-proc-file = 'utl/imp-tnvd.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '12.3'  p-run-order = '1' .
    assign p-client = 'BDC,PortAl' .
end procedure .
define variable vss-include-info248 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure service_impexp%cr249 :
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
  assign p-call-point      = "service_impexp":u p-proc-name = 'Импорт страны происхождения в карточку товара'  p-proc-file = 'utl/impalpha.p'  p-install = lookup ( "no", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
    assign p-db-ver = '14.1'  p-run-order = '1' .
    assign p-client = 'BDC' .
end procedure .
define variable vss-include-info250 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr251 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт кассиров'  p-proc-file = 'utl/imp-cashier.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info252 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr253 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт (изменение) клиентов'  p-proc-file = 'utl/impclir.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info254 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr255 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт товаров'  p-proc-file = 'utl/impgdsr.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info256 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr257 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт рецептов'  p-proc-file = 'utl/imprecipe.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info258 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr259 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Экспорт справочника товаров'  p-proc-file = 'utl/exp-gds.p'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
define variable vss-include-info260 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr261 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Экспорт значений параметров'  p-proc-file = 'bge/cashparexp.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info262 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr263 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт значений параметров'  p-proc-file = 'bge/cashparimp.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info264 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr265 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Экспорт групп товаров'  p-proc-file = 'utl/expggr.w'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info266 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr267 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Экспорт справочника клиенты'  p-proc-file = 'utl/exp-cli.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info268 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr269 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Экспорт справочника валюты и курсы'  p-proc-file = 'utl/exp-curr.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info270 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr271 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Экспорт справочника виды оплат'  p-proc-file = 'utl/exp-payt.p'  p-install = lookup ( "", "true,yes") > 0  p-mainmenu-handle = lookup ( "", "true,yes") > 0 .
end procedure .
define variable vss-include-info272 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impexp%cr273 :
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
  assign p-call-point      = "impexp":u p-proc-name = 'Импорт/Экспорт артикулов поставщиков'  p-proc-file = 'utl/iecliart.w'  p-install = lookup ( " ", "true,yes") > 0  p-mainmenu-handle = lookup ( "yes", "true,yes") > 0 .
end procedure .
