define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список автозаказов ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table tmp#zakaz1 no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field local-mark    as character field max-stock     as decimal   field season-coef   as decimal   field min-stock-old as decimal   field gds-way       as decimal   index pi is unique primary artic prod-type prod-code  ascending index idx-ln line-num.
define new shared temp-table tmp#zakaz-prn1 no-undo field artic         like ub.goods.artic      field prod-type     like ub.goods.prod-type  field prod-code     like ub.goods.prod-code  field obj-type      like ub.clients.obj-type field obj-code      like ub.clients.obj-code field prt-code      as   integer    field qnty-sale     as   decimal    field qnty-ord      as   decimal    index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.
define new shared temp-table tmp#zakaz-dtl1 no-undo like ub.ord-dtl field prt-name as character index bi is unique primary artic prod-type prod-code node-code  ascending.
define new shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define new shared buffer buf-goods   for ub.goods     .
define new shared buffer sb-cli-gds  for ub.cli-gds   .
define new shared buffer sb-gds-obj  for ub.gds-obj   .
define new shared buffer tmp#zakaz     for tmp#zakaz1.
define new shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define new shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define new shared  buffer shar_ord-doc  for ub.ord-doc .
define new shared  buffer shar_ord-line for ub.ord-line.
define new shared  buffer shar_ord-dtl  for ub.ord-dtl .
define new shared variable chexcelapplication      as com-handle no-undo .
define new shared variable chworkbook              as com-handle no-undo .
define new shared variable chworksheet             as com-handle no-undo .
define new shared variable chrange                 as com-handle no-undo .
define new shared variable chworksheet2            as com-handle no-undo .
define new shared variable chworksheet3            as com-handle no-undo .
define new shared variable accum-zakaz             as decimal no-undo .
define new shared variable accum-sum-zakaz         as decimal no-undo .
define new shared variable accum-count             as integer no-undo .
define new shared buffer buf-cli for ub.clients.
define new shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.
define new shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.
define new shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.
define  new  shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define  new  shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define  new  shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define  new  shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define  new  shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.
define  new  shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.
define  new  shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.
define  new  shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.
define  new  shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.
define  new  shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
define  new  shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.
define new  shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.
define new  shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define new  shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define new  shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.
define new shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.
define  new  shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.
define new shared variable loc-status  as character  no-undo.
define new shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.
define new shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.
define new shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.
define new shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.
define new shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.
define new shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.
define new shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.
define new shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.
define new shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.
define new shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.
define new shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.
define new shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(руб.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(руб)"
     fgcolor 4
     no-undo.
define new shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.
define new shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.
define new shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.
define new shared var loc-print-rubl as logical no-undo .
define new shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define new shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define new shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define  new  shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.
define new shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define new shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define new shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define new shared  variable temp-e-method  as character no-undo .
define new shared  variable x-tog-artic as logical   no-undo .
define new shared  variable x-tog-grp    as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable v-select-obj-name  as character no-undo .
define variable v-select-obj-type  as character no-undo .
define variable v-select-obj-code  as integer   no-undo .
define variable v-select-contract  as integer   no-undo .
define variable v-select-host-code as integer   no-undo .
define variable v-select-node-code as character no-undo .
define variable v-flt-obj-name     as character no-undo .
define variable v-flt-obj-type     as character no-undo .
define variable v-flt-obj-code     as integer   no-undo .
define variable p-method           as character no-undo init ''.
define variable v-save-mode        as logical   no-undo .
define variable v-region           as integer   no-undo .
define variable v-ord-type         as character no-undo .
DEFINE TEMP-TABLE tt-dis-some-rule LIKE ub.dis-some-rule .
DEFINE BUFFER buf_dis-some-rule FOR ub.dis-some-rule .
define buffer buf_clients       for ub.clients .
function get-wdays returns character (input p-wdays as character) :
    define variable v-i     as integer   no-undo .
    define variable v-rez   as character no-undo init "".
    define variable v-wdays as character no-undo extent 7 init ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"].
    do v-i = 1 to num-entries(p-wdays):
        if entry(v-i, p-wdays) = "no" then next .
        if v-rez = "" then v-rez = v-wdays [v-i] .
        else v-rez = v-rez + "," + v-wdays [v-i] .
    end.
    return v-rez .
end function.
function get-node returns character (input p-node as integer) :
    define buffer buf_gds-grp for ub.gds-grp .
    find first buf_gds-grp no-lock
    where buf_gds-grp.node-code = p-node no-error .
    if avail buf_gds-grp then return buf_gds-grp.node-name .
    else return "Группа не найдена" .
end function.
function get-gds-grp-lst returns character (input p-recid as character) :
    define buffer buf_gds-grp for ub.gds-grp .
    define buffer src_gds-grp for ub.gds-grp .
    define variable v-rez as character no-undo init "" .
    find first buf_gds-grp where string(recid(buf_gds-grp)) = p-recid no-lock no-error.
    if avail buf_gds-grp then do:
        if buf_gds-grp.is-term = yes then do:
            v-rez = string(buf_gds-grp.node-code) .
        end.
        else do:
            for each src_gds-grp no-lock
            where src_gds-grp.upper-code = buf_gds-grp.node-code
            :
                v-rez = ( if v-rez = "" then get-gds-grp-lst( string(recid(src_gds-grp)) ) else v-rez + "," + get-gds-grp-lst( string(recid(src_gds-grp)) ) ).
            end.
        end.
    end.
    return v-rez .
end function.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить автозаказ".
DEFINE BUTTON b-cancel
     LABEL "&Отменить"
     SIZE 10 BY 1 TOOLTIP "Отменить".
DEFINE BUTTON b-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-contract
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-method
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить автозаказ".
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить автозаказ".
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр автозаказа".
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход из режима".
DEFINE BUTTON b-save
     LABEL "&Сохранить"
     SIZE 10 BY 1 TOOLTIP "Сохранить автозаказ".
DEFINE QUERY br-dis-some FOR
      tt-dis-some-rule SCROLLING.
DEFINE BROWSE br-dis-some
  QUERY br-dis-some DISPLAY
      tt-dis-some-rule.templ-rl-root         COLUMN-LABEL ""           FORMAT ">>>>>9"
      tt-dis-some-rule.resource_id          COLUMN-LABEL "Контрагент" FORMAT "x(25)"
      get-wdays(entry(4, tt-dis-some-rule.charkey_two, chr(3)))  COLUMN-LABEL "Дни недели" FORMAT "x(18)"
      tt-dis-some-rule.rl-root              COLUMN-LABEL "Повтор"     FORMAT ">>9"
      tt-dis-some-rule.key#_one             COLUMN-LABEL "Дней до"    FORMAT ">>>>9"
      tt-dis-some-rule.key#_two             COLUMN-LABEL "Продажа"    FORMAT ">>>>9"
      tt-dis-some-rule.charkey_three        COLUMN-LABEL "Период"     FORMAT "99/99/9999999/99/9999"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.75 BY 17.79.
DEFINE VARIABLE r-region AS INTEGER INITIAL 3
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Глобально", 1,
          "По фирме", 2,
          "По объекту", 3
     SIZE 13 BY 3.25 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.5 BY 3.75.
DEFINE VARIABLE cb-zakaz AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Тип заказа"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Объект-Поставщик", 1,
                     "Объект-Фирма", 2,
                     "Объект-РЦ", 3,
                     "Фирма-Поставщик", 4
     DROP-DOWN-LIST
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE v-days-do AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Кол-во дней до поставки"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE v-days-fale AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Кол-во дней продажи"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE v-from AS CHARACTER FORMAT "99/99/9999":U INITIAL "01/01/1990"
     LABEL "Период с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE v-repeat AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "каждую"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE v-to AS CHARACTER FORMAT "99/99/9999":U INITIAL "01/01/1990"
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.5 BY 9.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.5 BY 2.5.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 49.5 BY 1.5.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 49.5 BY 11.25.
DEFINE VARIABLE v-flag AS LOGICAL INITIAL no
     LABEL "флаг автоматической отправки в"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY 1 NO-UNDO.
DEFINE VARIABLE v-l-delnull AS LOGICAL INITIAL no
     LABEL "удалять нулевые позиции"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY 1 NO-UNDO.
DEFINE VARIABLE v-l-addextart AS LOGICAL INITIAL no
     LABEL "добавлять товары только с артикулом"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY 1 NO-UNDO.
DEFINE VARIABLE v-wday-1 AS LOGICAL INITIAL no
     LABEL "Понедельник"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-wday-2 AS LOGICAL INITIAL no
     LABEL "Вторник"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-wday-3 AS LOGICAL INITIAL no
     LABEL "Среда"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-wday-4 AS LOGICAL INITIAL no
     LABEL "Четверг"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-wday-5 AS LOGICAL INITIAL no
     LABEL "Пятница"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-wday-6 AS LOGICAL INITIAL no
     LABEL "Суббота"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-wday-7 AS LOGICAL INITIAL no
     LABEL "Воскресенье"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-txt1 AS CHARACTER NO-UNDO INIT "неделю" .
DEFINE VARIABLE v-txt2 AS CHARACTER NO-UNDO INIT "Повторять" .
DEFINE VARIABLE v-txt3 AS CHARACTER NO-UNDO INIT "Метод расчета:" .
DEFINE VARIABLE v-txt4 AS CHARACTER NO-UNDO INIT "Группа товаров:" .
DEFINE VARIABLE v-txt5 AS CHARACTER NO-UNDO INIT "Контрагент:" .
DEFINE VARIABLE v-txt6 AS CHARACTER NO-UNDO INIT "системы электронного документооборота" .
DEFINE VARIABLE v-txt7 AS CHARACTER NO-UNDO INIT "Контрагент:" .
DEFINE VARIABLE v-txt8 AS CHARACTER NO-UNDO INIT "Договор:" .
DEFINE VARIABLE v-txt9 AS CHARACTER NO-UNDO INIT "поставщика" .
DEFINE VARIABLE v-contr     AS CHARACTER NO-UNDO INIT "" .
DEFINE VARIABLE v-contract  AS CHARACTER NO-UNDO INIT "" .
DEFINE VARIABLE v-grp       AS CHARACTER NO-UNDO INIT "" .
DEFINE VARIABLE v-method    AS CHARACTER NO-UNDO INIT "" .
DEFINE VARIABLE v-flt-contr AS CHARACTER NO-UNDO INIT "" .
DEFINE VARIABLE c-flt-reg AS INTEGER INITIAL 0
     LABEL "Тип заказа"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Все", 0,
                     "Глобально", 1,
                     "По фирме", 2,
                     "По объекту", 3
     DROP-DOWN-LIST
     SIZE 15 BY 1 NO-UNDO.
DEFINE BUTTON b-flt-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" TOOLTIP "Выбрать контрагента"
     SIZE 3 BY 1.
DEFINE BUTTON b-flt-clear
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" TOOLTIP "Очистить"
     SIZE 3 BY 1.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 2
     b-save AT ROW 1 COL 2 WIDGET-ID 6
     b-cancel AT ROW 1 COL 14 WIDGET-ID 4
     b-add AT ROW 1 COL 23 WIDGET-ID 2
     B-lookup AT ROW 1 COL 33
     b-chg AT ROW 1 COL 43
     b-del AT ROW 1 COL 53
     c-flt-reg AT ROW 1 COL 65
     b-flt-contr  AT ROW 2.13 COL 90
     b-flt-clear  AT ROW 2.13 COL 93
     br-dis-some AT ROW 3.21 COL 1
     r-region AT ROW 5.5 COL 3 NO-LABEL WIDGET-ID 10
     v-from AT ROW 9.5 COL 11.5 COLON-ALIGNED WIDGET-ID 16
     v-to AT ROW 9.5 COL 29 COLON-ALIGNED WIDGET-ID 18
     v-repeat AT ROW 11.75 COL 28 COLON-ALIGNED WIDGET-ID 36
     v-wday-1 AT ROW 11 COL 3 WIDGET-ID 20
     v-wday-2 AT ROW 12 COL 3 WIDGET-ID 22
     v-wday-3 AT ROW 13 COL 3 WIDGET-ID 24
     v-wday-4 AT ROW 14 COL 3 WIDGET-ID 26
     v-wday-5 AT ROW 15 COL 3 WIDGET-ID 28
     v-wday-6 AT ROW 16 COL 3 WIDGET-ID 30
     v-wday-7 AT ROW 17 COL 3 WIDGET-ID 32
     v-flag AT ROW 10 COL 51 WIDGET-ID 42
     v-l-delnull AT ROW 12 COL 51 WIDGET-ID 42
     v-l-addextart AT ROW 13 COL 51 WIDGET-ID 42
     cb-zakaz AT ROW 2.5 COL 55.5 COLON-ALIGNED WIDGET-ID 48
     b-contr  AT ROW 2.5 COL 35 WIDGET-ID 60
     b-contract  AT ROW 3.5 COL 35 WIDGET-ID 60
     b-grp    AT ROW 4.5 COL 87.5 WIDGET-ID 68
     b-method AT ROW 5.75 COL 87.5 WIDGET-ID 70
     v-days-do AT ROW 7.25 COL 69 COLON-ALIGNED WIDGET-ID 56
     v-days-fale AT ROW 8.5 COL 69 COLON-ALIGNED WIDGET-ID 58
     v-txt2 VIEW-AS TEXT SIZE 9    BY 1   AT ROW 11     COL 19.5 NO-LABEL FORMAT "X(9)" WIDGET-ID 34
     v-txt1 VIEW-AS TEXT SIZE 8    BY 1   AT ROW 11.8   COL 34.5 NO-LABEL FORMAT "X(8)" WIDGET-ID 38
     v-txt3 VIEW-AS TEXT SIZE 14.5 BY 1   AT ROW 5.75  COL 56   NO-LABEL FORMAT "X(15)" WIDGET-ID 66
     v-txt4 VIEW-AS TEXT SIZE 15.5 BY 1   AT ROW 4.5     COL 55   NO-LABEL FORMAT "X(16)" WIDGET-ID 64
     v-txt5 VIEW-AS TEXT SIZE 11.5 BY 1   AT ROW 2.5  COL 3   NO-LABEL FORMAT "X(12)" WIDGET-ID 62
     v-txt8 VIEW-AS TEXT SIZE 11.5 BY 1   AT ROW 3.5  COL 3   NO-LABEL FORMAT "X(12)"
     v-txt6 VIEW-AS TEXT SIZE 39.5 BY .75 AT ROW 11 COL 53    NO-LABEL FORMAT "X(40)" WIDGET-ID 44
     v-txt7 VIEW-AS TEXT SIZE 11.5 BY 1 AT ROW 2.13  COL 65 NO-LABEL FORMAT "X(12)"
     v-txt9 VIEW-AS TEXT SIZE 39.5 BY .75 AT ROW 14 COL 53    NO-LABEL FORMAT "X(12)" WIDGET-ID 44
     v-flt-contr VIEW-AS TEXT SIZE 12   BY 1 AT ROW 2.13  COL 77 NO-LABEL FORMAT "X(12)"
     v-contr  VIEW-AS TEXT SIZE 16 BY 1   AT ROW 2.5  COL 15   NO-LABEL FORMAT "X(20)"
     v-contract  VIEW-AS TEXT SIZE 16 BY 1   AT ROW 3.5  COL 15   NO-LABEL FORMAT "X(20)"
     v-grp    VIEW-AS TEXT SIZE 16 BY 1   AT ROW 4.5     COL 71   NO-LABEL FORMAT "X(16)"
     v-method VIEW-AS TEXT SIZE 16 BY 1   AT ROW 5.75  COL 71   NO-LABEL FORMAT "X(16)"
     RECT-1 AT ROW 5.25 COL 2 WIDGET-ID 8
     RECT-3 AT ROW 9.25 COL 2 WIDGET-ID 14
     RECT-4 AT ROW 2.25 COL 2 WIDGET-ID 40
     RECT-5 AT ROW 2.25 COL 44 WIDGET-ID 46
     RECT-6 AT ROW 4 COL 44 WIDGET-ID 50
     SPACE(0.05) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Автозаказы".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
run show_main_page in this-procedure .
ASSIGN
       v-txt1  :SCREEN-VALUE = "неделю"
       v-txt2  :SCREEN-VALUE = "Повторять"
       v-txt3  :SCREEN-VALUE = "Метод расчета:"
       v-txt4  :SCREEN-VALUE = "Группа товаров:"
       v-txt5  :SCREEN-VALUE = "Контрагент:"
       v-txt6  :SCREEN-VALUE = "системы электронного документооборота"
       v-txt7  :SCREEN-VALUE = "Контрагент:"
       v-txt8  :SCREEN-VALUE = "Договор:"
       v-txt9  :SCREEN-VALUE = "поставщика"
.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  run proc-add-chg in this-procedure ( input "add" ) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not avail tt-dis-some-rule then return no-apply.
  run proc-add-chg in this-procedure ( input "chg" ) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo.
  if not avail tt-dis-some-rule then return no-apply.
  message
  "Вы уверены, что хотите удалить?"
          view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
  find current tt-dis-some-rule exclusive-lock no-error.
  if avail tt-dis-some-rule then do:
      DO TRANSACTION
      on error undo, return no-apply
      :
          find first buf_dis-some-rule exclusive-lock
          where buf_dis-some-rule.templ-rl-root = tt-dis-some-rule.templ-rl-root no-error .
          if avail buf_dis-some-rule then delete buf_dis-some-rule .
      END.
      delete tt-dis-some-rule .
      br-dis-some:refresh() in frame Dialog-Frame no-error .
  end.
  OPEN QUERY br-dis-some FOR EACH tt-dis-some-rule NO-LOCK.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
  if not avail tt-dis-some-rule then return no-apply.
  run proc-add-chg in this-procedure ( input "view" ) no-error .
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF c-flt-reg IN FRAME Dialog-Frame
DO:
  assign
    c-flt-reg
  .
  run open-br in this-procedure ( c-flt-reg ) .
  br-dis-some:refresh() in frame Dialog-Frame no-error .
  OPEN QUERY br-dis-some FOR EACH tt-dis-some-rule NO-LOCK.
END.
ON VALUE-CHANGED OF v-contract IN FRAME Dialog-Frame
DO:
  enable b-contract.
END.
ON VALUE-CHANGED OF cb-zakaz IN FRAME Dialog-Frame
DO:
    if cb-zakaz:screen-value = "2" then do:
        find first buf_clients no-lock
        where buf_clients.obj-type = 'орг':U and
              buf_clients.obj-code = v-cntxt-host-code-obj
        no-error.
        if avail buf_clients then do:
            assign
              v-select-host-code = buf_clients.host-code
              v-select-obj-type  = buf_clients.obj-type
              v-select-obj-code  = buf_clients.obj-code
              v-select-obj-name  = buf_clients.obj-name
              v-contr :SCREEN-VALUE IN FRAME Dialog-Frame = v-select-obj-name
            .
            disable b-contr with frame Dialog-Frame .
        end.
    end.
    else do:
      enable b-contr with frame Dialog-Frame .
    end.
    if cb-zakaz:screen-value <> "1" or v-select-obj-code = 0  then do:
      assign
        v-contract :SCREEN-VALUE IN FRAME Dialog-Frame = ""
        v-select-contract = 0
      .
      disable b-contract with frame Dialog-Frame .
    end.
    else do:
      enable b-contract with frame Dialog-Frame .
    end.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo.
  define variable v-recid as recid   no-undo.
  message "Сохранить изменения?" view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if not loc#log then return no-apply.
  assign
    r-region cb-zakaz v-from v-to v-repeat v-flag v-l-addextart v-l-delnull
    v-wday-1 v-wday-2 v-wday-3 v-wday-4 v-wday-5 v-wday-6 v-wday-7
    v-days-do v-days-fale
  .
  assign
    v-region = r-region
  .
  run proc-save in this-procedure no-error.
  if not error-status:error then do:
      v-recid = recid(tt-dis-some-rule) .
      run show_main_page in this-procedure .
      br-dis-some:refresh() in frame Dialog-Frame no-error .
     OPEN QUERY br-dis-some FOR EACH tt-dis-some-rule NO-LOCK.
     reposition br-dis-some to recid v-recid no-error.
  end.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
    run show_main_page in this-procedure .
END.
ON CHOOSE OF b-method IN FRAME Dialog-Frame
DO:
  case cb-zakaz:screen-value:
    when "2" then v-ord-type = 'ОФ':U .
    when "3" then v-ord-type = 'ОР':U .
    when "4" then v-ord-type = 'ФП':U .
    otherwise v-ord-type = 'ОП':U .
  end.
  run cus/ord-m-a.w ( input parparentproc , input "auto-ord":u , input v-ord-type, input-output p-method ) no-error.
  if error-status:error then return no-apply.
  if not p-method = '' then v-method:SCREEN-VALUE = "Установлен" .
  else v-method:SCREEN-VALUE = "" .
END.
ON CHOOSE OF b-grp IN FRAME Dialog-Frame
DO:
  run proc-sel-grp IN THIS-PROCEDURE NO-ERROR .
  if error-status:error then return no-apply.
  if not v-grp = '' then v-grp:SCREEN-VALUE = v-grp .
  else v-grp:SCREEN-VALUE = '' .
END.
ON CHOOSE OF b-contr IN FRAME Dialog-Frame
DO:
  run proc-sel-obj IN THIS-PROCEDURE ("contr") NO-ERROR .
  if error-status:error then return no-apply.
  v-contr:SCREEN-VALUE = v-select-obj-name .
  if v-select-obj-name <> "" and cb-zakaz:screen-value = "1" then do:
    enable b-contract with frame Dialog-Frame .
  end.
END.
ON CHOOSE OF b-contract IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
  find first buf_contract where buf_contract.contract-code = v-select-contract and buf_contract.host-code = v-cntxt-host-code-obj no-error.
  if available buf_contract
    then assign v-rid-list = string (recid (buf_contract)).
  run str/cont-all.w (
    input   parparentproc  ,
    input   v-cntxt-host-code-obj,
    input   "b-sel"         ,
    input   "firm-curr"     ,
    input   v-select-obj-type,
    input   v-select-obj-code,
    input   ?               ,
    input   ?               ,
    input   "current"       ,
    input   'при':U       ,
    input-output v-rid-list )
  .
  find first buf_contract where recid(buf_contract) = integer(v-rid-list) no-error.
  if not available buf_contract then do:
    assign
      v-select-contract = 0
      v-contract:SCREEN-VALUE = ""
    .
  end.
  else do:
    assign
      v-select-contract = buf_contract.contract-code
      v-contract:SCREEN-VALUE =  buf_contract.contract-prn-code
    .
  end.
END.
ON CHOOSE OF b-flt-contr IN FRAME Dialog-Frame
DO:
  run proc-sel-obj IN THIS-PROCEDURE ("flt") NO-ERROR .
  if error-status:error then return no-apply.
  v-flt-contr:SCREEN-VALUE = v-flt-obj-name .
  run open-br in this-procedure ( c-flt-reg ) .
  br-dis-some:refresh() in frame Dialog-Frame no-error .
  OPEN QUERY br-dis-some FOR EACH tt-dis-some-rule NO-LOCK.
END.
ON CHOOSE OF b-flt-clear IN FRAME Dialog-Frame
DO:
  assign
    v-flt-contr:SCREEN-VALUE = ""
    v-flt-obj-type           = ""
    v-flt-obj-code           = 0
    v-flt-obj-name           = ""
  .
  run open-br in this-procedure ( c-flt-reg ) .
  br-dis-some:refresh() in frame Dialog-Frame no-error .
  OPEN QUERY br-dis-some FOR EACH tt-dis-some-rule NO-LOCK.
END.
ON MOUSE-SELECT-DBLCLICK OF br-dis-some IN FRAME Dialog-Frame
DO:
  if not avail tt-dis-some-rule then return no-apply.
  run proc-add-chg in this-procedure ( input "view" ) no-error .
  if error-status:error then return no-apply.
END.
ON RETURN OF br-dis-some IN FRAME Dialog-Frame
DO:
  if not avail tt-dis-some-rule then return no-apply.
  run proc-add-chg in this-procedure ( input "view" ) no-error .
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  RUN enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  assign
    c-flt-reg:SCREEN-VALUE IN FRAME Dialog-Frame = "0"
  .
  assign
    c-flt-reg
  .
  ENABLE b-quit b-add B-lookup b-chg b-del c-flt-reg
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run open-br in this-procedure ( c-flt-reg ) .
  OPEN QUERY br-dis-some FOR EACH tt-dis-some-rule NO-LOCK.
END PROCEDURE.
PROCEDURE proc-add-chg :
    define input parameter p-add as character no-undo.
    if p-add = "add" then do:
        assign v-save-mode = yes .
        run show_add_page in this-procedure ( v-save-mode ) .
    end.
    else do:
        assign v-save-mode = no .
        run show_add_page in this-procedure ( v-save-mode ) .
    end.
    if p-add = "view" or
       ( v-cntxt-db-num > 0 and r-region < 3 )
    then do:
        DISABLE b-save
        WITH FRAME Dialog-Frame.
    end.
END PROCEDURE.
PROCEDURE proc-save :
  define variable v-i       as integer   no-undo .
  define variable v-mth     as character no-undo init "".
  define variable v-cmp     as logical   no-undo .
  define variable v-lastrec as integer   no-undo .
  if v-select-obj-type = '' and v-select-obj-code = 0 then do:
       message color input "Не указан поставщик!" view-as alert-box error .
       return error .
  end.
  if v-select-node-code = "" then do:
       message color input "Не указана группа товара!" view-as alert-box error .
       return error .
  end.
  if p-method = '' then do:
       message color input "Не указан метод расчета!" view-as alert-box error .
       return error .
  end.
  DO TRANSACTION
  on error undo, return error
  :
      if v-save-mode then do:
          find last buf_dis-some-rule use-index itempl no-lock no-error .
          if avail buf_dis-some-rule then assign v-lastrec = buf_dis-some-rule.templ-rl-root .
          else assign v-lastrec = 0 .
          create tt-dis-some-rule .
          assign
            tt-dis-some-rule.templ-rl-root = v-lastrec + 1
            tt-dis-some-rule.resource#_id = tt-dis-some-rule.templ-rl-root
          .
      end .
      else do:
          find current tt-dis-some-rule exclusive-lock .
      end.
      case v-region :
        when 1 then do:
           assign
           tt-dis-some-rule.host-code = 0
           tt-dis-some-rule.obj-code  = 0
           tt-dis-some-rule.obj-type  = ""
           .
        end.
        when 2 then do:
           assign
           tt-dis-some-rule.host-code = v-cntxt-host-code-obj
           tt-dis-some-rule.obj-code  = 0
           tt-dis-some-rule.obj-type  = ""
           .
        end.
        when 3 then do:
           assign
           tt-dis-some-rule.host-code = v-cntxt-host-code-obj
           tt-dis-some-rule.obj-code  = v-cntxt-obj-code
           tt-dis-some-rule.obj-type  = v-cntxt-obj-type
           .
        end.
      end.
      assign
        tt-dis-some-rule.charkey_one = p-method
        tt-dis-some-rule.charkey_two = string(v-flag) + chr(3) +
                                       v-select-node-code + chr(3) +
                                       v-select-obj-type + string(v-select-obj-code) + chr(3) +
                                       string(v-wday-1) + "," + string(v-wday-2) + "," + string(v-wday-3) + "," +
                                       string(v-wday-4) + "," + string(v-wday-5) + "," + string(v-wday-6) + "," + string(v-wday-7) +
                                       chr(3) + string(v-select-contract) + chr(3) + string (v-l-addextart) + chr(3) + string (v-l-delnull)
        tt-dis-some-rule.charkey_three = v-from + "-" + v-to
        tt-dis-some-rule.key#_one = v-days-do
        tt-dis-some-rule.key#_two = v-days-fale
        tt-dis-some-rule.classif-type = "auto-ord-" + string(cb-zakaz)
        tt-dis-some-rule.rl-root = v-repeat
        tt-dis-some-rule.resource_id = v-select-obj-name
        tt-dis-some-rule.resource#_id = tt-dis-some-rule.templ-rl-root
      .
      find first buf_dis-some-rule exclusive-lock
      where buf_dis-some-rule.templ-rl-root = tt-dis-some-rule.templ-rl-root no-error .
      if not avail buf_dis-some-rule then create buf_dis-some-rule .
      buffer-compare tt-dis-some-rule to buf_dis-some-rule save result in v-cmp .
      if not v-cmp then buffer-copy tt-dis-some-rule to buf_dis-some-rule .
  END.
END PROCEDURE.
PROCEDURE proc-sel-obj :
  define input parameter p-sel as character no-undo.
  define variable v-rid-list as character no-undo .
  do
  on error undo, return error return-value
  :
   run ref/cli-all.w ( parparentproc
                      ,"b-sel"
                      ,'все':U
                      , ?
                      , ?
                      , ?
                      , ?
                      , ?
                      ,output v-rid-list ) no-error .
    if v-rid-list = "" then return error.
    find first buf_clients where string(recid(buf_clients)) = v-rid-list no-lock no-error.
    if avail buf_clients then do:
        if p-sel = "contr" then do:
          if cb-zakaz:screen-value in frame Dialog-frame = "3" and
             not ( buf_clients.obj-type = 'маг':U or buf_clients.obj-type = 'скл':U )
          then do:
             message "Тип заказа не соответствует типу поставщика." view-as alert-box error .
             return error .
          end.
          assign
            v-select-host-code = buf_clients.host-code
            v-select-obj-type  = buf_clients.obj-type
            v-select-obj-code  = buf_clients.obj-code
            v-select-obj-name  = buf_clients.obj-name
          .
        end.
        else do:
          assign
            v-flt-obj-type  = buf_clients.obj-type
            v-flt-obj-code  = buf_clients.obj-code
            v-flt-obj-name  = buf_clients.obj-name
          .
        end.
    end.
    else return error.
  end.
END PROCEDURE.
PROCEDURE proc-sel-grp :
  define variable v-rid-list as character no-undo .
  define variable v-i        as integer   no-undo .
  define buffer buf_gds-grp for ub.gds-grp .
  do
  on error undo, return error return-value
  :
  if not v-select-node-code = "" then do:
     do v-i = 1 to num-entries(v-select-node-code):
        find first buf_gds-grp where buf_gds-grp.node-code = int(entry(v-i, v-select-node-code)) no-lock no-error.
        if avail buf_gds-grp then do:
            assign
              v-rid-list = ( if v-rid-list = "" then string(recid(buf_gds-grp)) else v-rid-list + "," + string(recid(buf_gds-grp)) )
            .
        end.
    end.
  end.
  else assign v-rid-list = "" .
  run ref/gds-grp.w (input parparentproc
                    ,input "b-sel,b-mark"
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,input-output v-rid-list) no-error .
    if v-rid-list = "" then return error.
    assign v-select-node-code = "" .
    do v-i = 1 to num-entries(v-rid-list):
        v-select-node-code = ( if v-select-node-code = "" then get-gds-grp-lst(entry(v-i, v-rid-list)) else v-select-node-code + "," + get-gds-grp-lst(entry(v-i, v-rid-list)) ) .
    end.
    if not v-select-node-code = "" then assign v-grp = "Установлена" .
  end.
END PROCEDURE.
PROCEDURE show_main_page :
    ASSIGN
       b-save  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-cancel:HIDDEN IN FRAME Dialog-Frame  = TRUE
       r-region:HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-1  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-3  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-4  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-5  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-6  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-from  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-to    :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-1:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-repeat:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-2:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-3:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-4:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-5:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-6:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-7:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt1  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt2  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt3  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt4  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt5  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt8  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt9  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt6  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       cb-zakaz:HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-contr :HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-contract :HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-grp   :HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-method:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-contr :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-contract :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-grp   :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-method:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-flag  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-l-addextart :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-l-delnull :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-days-do  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-days-fale:HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-quit  :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-add   :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-lookup:HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-chg   :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-del   :HIDDEN IN FRAME Dialog-Frame  = FALSE
       br-dis-some :HIDDEN IN FRAME Dialog-Frame  = FALSE
       c-flt-reg:HIDDEN IN FRAME Dialog-Frame  = FALSE
       v-txt7  :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-flt-contr :HIDDEN IN FRAME Dialog-Frame  = FALSE
       v-flt-contr :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-flt-clear :HIDDEN IN FRAME Dialog-Frame  = FALSE
    .
    DISABLE b-save b-cancel r-region RECT-1 RECT-3 RECT-4 RECT-5 RECT-6
    WITH FRAME Dialog-Frame.
    ENABLE b-quit b-add B-lookup b-chg b-del br-dis-some c-flt-reg v-txt7 b-flt-contr v-flt-contr b-flt-clear
    WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE show_add_page :
define input parameter p-add as logical no-undo.
define variable v-time as integer no-undo .
define variable v-curdt as date no-undo .
assign
   b-save  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-cancel:HIDDEN IN FRAME Dialog-Frame  = FALSE
   r-region:HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-1  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-3  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-4  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-5  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-6  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-from  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-to    :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-1:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-repeat:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-2:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-3:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-4:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-5:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-6:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-7:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt1  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt2  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt3  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt4  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt5  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt8  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt8  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt8  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt9  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt6  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   cb-zakaz:HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-contract :HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-grp   :HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-method:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-contr :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-contract :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-grp   :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-method:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-flag  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-l-addextart :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-l-delnull :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-days-do  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-days-fale:HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-quit  :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-add   :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-lookup:HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-chg   :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-del   :HIDDEN IN FRAME Dialog-Frame  = TRUE
   br-dis-some :HIDDEN IN FRAME Dialog-Frame  = TRUE
   c-flt-reg:HIDDEN IN FRAME Dialog-Frame  = TRUE
   v-txt7  :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-flt-contr :HIDDEN IN FRAME Dialog-Frame  = TRUE
   v-flt-contr :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-flt-clear :HIDDEN IN FRAME Dialog-Frame  = TRUE
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-curdt
  ) no-error .
if p-add then do:
  ASSIGN
   r-region:SCREEN-VALUE IN FRAME Dialog-Frame = "3"
   v-repeat:SCREEN-VALUE IN FRAME Dialog-Frame = "1"
   cb-zakaz:SCREEN-VALUE IN FRAME Dialog-Frame = "1"
   v-contr :SCREEN-VALUE IN FRAME Dialog-Frame = ""
   v-contract :SCREEN-VALUE IN FRAME Dialog-Frame = ""
   v-grp   :SCREEN-VALUE IN FRAME Dialog-Frame = ""
   v-method:SCREEN-VALUE IN FRAME Dialog-Frame = ""
   v-from  :SCREEN-VALUE IN FRAME Dialog-Frame = string(v-curdt, "99999999")
   v-to    :SCREEN-VALUE IN FRAME Dialog-Frame = string(v-curdt, "99999999")
   v-select-node-code = ""
   v-select-obj-type = ""
   v-select-obj-name = ""
   v-select-obj-code = 0
   p-method = ""
  .
end.
else do:
  find first buf_contract where buf_contract.contract-code = integer(entry(5, tt-dis-some-rule.charkey_two, chr(3) )) and buf_contract.host-code = v-cntxt-host-code-obj no-error.
  assign
    p-method = tt-dis-some-rule.charkey_one
    v-method:SCREEN-VALUE IN FRAME Dialog-Frame = "Установлен"
    v-flag  :SCREEN-VALUE IN FRAME Dialog-Frame = entry(1, tt-dis-some-rule.charkey_two, chr(3) )
    v-l-addextart :SCREEN-VALUE IN FRAME Dialog-Frame = if num-entries (tt-dis-some-rule.charkey_two, chr(3)) < 6 then "no" else entry(6, tt-dis-some-rule.charkey_two, chr(3) )
    v-l-delnull :SCREEN-VALUE IN FRAME Dialog-Frame = if num-entries (tt-dis-some-rule.charkey_two, chr(3)) < 7 then "no" else entry(7, tt-dis-some-rule.charkey_two, chr(3) )
    v-from  :SCREEN-VALUE IN FRAME Dialog-Frame = entry(1, tt-dis-some-rule.charkey_three, "-" )
    v-to    :SCREEN-VALUE IN FRAME Dialog-Frame = entry(2, tt-dis-some-rule.charkey_three, "-" )
    v-days-do  :SCREEN-VALUE IN FRAME Dialog-Frame = string(tt-dis-some-rule.key#_one)
    v-days-fale:SCREEN-VALUE IN FRAME Dialog-Frame = string(tt-dis-some-rule.key#_two)
    v-select-node-code = entry(2, tt-dis-some-rule.charkey_two, chr(3) )
    v-select-contract = if num-entries (tt-dis-some-rule.charkey_two, chr(3)) < 5 then 0 else integer(entry(5, tt-dis-some-rule.charkey_two, chr(3) ))
    v-grp :SCREEN-VALUE IN FRAME Dialog-Frame = ( if v-select-node-code = "" then "" else "Установлена"  )
    cb-zakaz:SCREEN-VALUE IN FRAME Dialog-Frame = entry(3, tt-dis-some-rule.classif-type, "-" )
    v-select-obj-type = substring( entry(3, tt-dis-some-rule.charkey_two, chr(3) ), 1, 3 )
    v-select-obj-code = int(substring( entry(3, tt-dis-some-rule.charkey_two, chr(3) ), 4 ))
    v-select-obj-name = tt-dis-some-rule.resource_id
    v-contr :SCREEN-VALUE IN FRAME Dialog-Frame = v-select-obj-name
    v-contract :SCREEN-VALUE IN FRAME Dialog-Frame = if available buf_contract then buf_contract.contract-prn-code else ""
    v-repeat:SCREEN-VALUE IN FRAME Dialog-Frame = string(tt-dis-some-rule.rl-root)
    v-wday-1:SCREEN-VALUE IN FRAME Dialog-Frame = entry(1, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-2:SCREEN-VALUE IN FRAME Dialog-Frame = entry(2, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-3:SCREEN-VALUE IN FRAME Dialog-Frame = entry(3, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-4:SCREEN-VALUE IN FRAME Dialog-Frame = entry(4, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-5:SCREEN-VALUE IN FRAME Dialog-Frame = entry(5, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-6:SCREEN-VALUE IN FRAME Dialog-Frame = entry(6, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-7:SCREEN-VALUE IN FRAME Dialog-Frame = entry(7, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
  .
  if tt-dis-some-rule.host-code = 0 then     assign r-region = 1 r-region:SCREEN-VALUE IN FRAME Dialog-Frame = "1" .
  else if tt-dis-some-rule.obj-code = 0 then assign r-region = 2 r-region:SCREEN-VALUE IN FRAME Dialog-Frame = "2" .
       else                                  assign r-region = 3 r-region:SCREEN-VALUE IN FRAME Dialog-Frame = "3" .
end.
if cb-zakaz:screen-value IN FRAME Dialog-Frame = "1" then enable b-contract with frame Dialog-Frame . else disable b-contract with frame Dialog-Frame.
DISABLE b-quit b-add B-lookup b-chg b-del c-flt-reg v-txt7 b-flt-contr v-flt-contr b-flt-clear
WITH FRAME Dialog-Frame.
ENABLE b-save b-cancel r-region RECT-1 RECT-3 RECT-4 RECT-5 RECT-6 v-from v-to v-wday-1 v-repeat v-wday-2 v-wday-3 v-wday-4
       v-wday-5 v-wday-6 v-wday-7 v-txt1 v-txt2 v-txt3 v-txt4 v-txt5 v-txt8 v-txt6 v-txt9 cb-zakaz b-contr b-grp b-method v-flag v-l-addextart v-l-delnull
       v-days-do v-days-fale v-contr v-contract v-grp v-method
WITH FRAME Dialog-Frame.
if cb-zakaz:SCREEN-VALUE IN FRAME Dialog-Frame = "2" then disable b-contr with frame Dialog-Frame .
if not p-add then disable r-region with frame Dialog-Frame .
else disable b-contract with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE open-br :
  define input parameter p-flt-reg as character no-undo.
  define variable v-reg  as character no-undo.
  for each tt-dis-some-rule exclusive-lock:
      delete tt-dis-some-rule.
  end.
  _buf_dis-some-rule:
  for each buf_dis-some-rule no-lock:
      if buf_dis-some-rule.host-code = 0 then assign v-reg = "1" .
      else if buf_dis-some-rule.obj-code = 0 then assign v-reg = "2" .
           else assign v-reg = "3" .
      if v-reg = "2" and not buf_dis-some-rule.host-code = v-cntxt-host-code-obj then next _buf_dis-some-rule .
      if v-reg = "3" and not (buf_dis-some-rule.obj-code = v-cntxt-obj-code and buf_dis-some-rule.obj-code = v-cntxt-obj-code) then next _buf_dis-some-rule .
      if int(p-flt-reg) > 0 and not v-reg = p-flt-reg then next _buf_dis-some-rule .
      if not v-flt-obj-type = "" and not entry(3, buf_dis-some-rule.charkey_two, chr(3) ) = v-flt-obj-type + string(v-flt-obj-code) then next _buf_dis-some-rule .
      create tt-dis-some-rule .
      buffer-copy buf_dis-some-rule to tt-dis-some-rule .
  end.
END PROCEDURE.
