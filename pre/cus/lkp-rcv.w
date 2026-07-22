DEFINE SHARED BUFFER bufs_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf_ord-chain FOR ub.ord-chain.
DEFINE TEMP-TABLE loc-line-rcv NO-UNDO LIKE ub.ord-line-rcv.
DEFINE BUFFER Obj-clients FOR ub.clients.
DEFINE BUFFER Post-clients FOR ub.clients.
DEFINE BUFFER Post-goods FOR ub.goods.
DEFINE BUFFER post-ord-line-rcv FOR ub.ord-line-rcv.
DEFINE BUFFER rcv_goods FOR ub.goods.
define input  parameter parParentProc   as widget-handle no-undo.
define input-output  parameter p-ord-rec       as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр строки поставки".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable   custvalue     as character initial ? no-undo.
define variable   custtype      as character initial ? no-undo.
define variable   prtvalue      as character initial ? no-undo.
define variable   prttype       as character initial ? no-undo.
define variable   partsvalue    as character initial ? no-undo.
define variable   partstype     as character initial ? no-undo.
define variable   vat-sumvalue  as character initial ? no-undo.
define variable   vat-sumtype   as character initial ? no-undo.
define variable   rdtaxcdvalue  as character initial ? no-undo.
define variable   exctaxcdvalue as character initial ? no-undo.
define variable   vattaxcdvalue as character initial ? no-undo.
define variable   measfactvalue as character initial ? no-undo.
define variable   measfacttype  as character initial ? no-undo.
define variable   temp-mes      as character initial ? no-undo.
define variable   varroad-tax-label as character no-undo.
define variable   is-petrolium  as logical             no-undo.
define variable   is-pieces     as logical             no-undo.
define variable   dops          as character           no-undo format "X(250)".
define variable   dopst         as character           no-undo format "X(1)".
define variable   dop-slt       as character           no-undo format "X(250)".
define variable   dop-slt-st    as character           no-undo format "X(1)".
define variable   sum-vat       like ub.ord-line.sum-vat format "->>>,>>>,>>>,>>>,>>9.99" no-undo.
define variable   varrvs-place        as   logical       no-undo.
define variable   var-code-temp like ub.place.pl-code no-undo.
define variable   rvs-recid     as recid           no-undo.
define variable   road-tax-cli  like ub.doc-line.road-tax initial 0 no-undo.
define variable   parprice-sale like ub.price-list.price-sale no-undo.
define var  pargds-code            like ub.goods.gds-code        no-undo.
define var  parobj-type            like ub.clients.obj-type      no-undo.
define var  parobj-code            like ub.clients.obj-code      no-undo.
define var  parext-gds-type        as   character      initial ? no-undo.
define var  parcli-qnty-input      as   logical        initial ? no-undo.
define var  pardensity-input       as   logical        initial ? no-undo.
define var  parcli-base-rate-input as   logical        initial ? no-undo.
define var  pardoc-qnty-input      as   logical        initial ? no-undo.
define var  parfact-qnty-input     as   logical        initial ? no-undo.
define var  parprice-cli-input     as   logical        initial ? no-undo.
define var  parbase-price-input    as   logical        initial ? no-undo.
define var  parbase-price-my       as   logical        initial ? no-undo.
define var  partax-3-input         as   logical        initial ? no-undo.
define var  parcli-qnty-calc       as   character      initial ? no-undo.
define var  pardensity-calc        as   character      initial ? no-undo.
define var  parcli-base-rate-calc  as   character      initial ? no-undo.
define var  pardoc-qnty-calc       as   character      initial ? no-undo.
define var  parfact-qnty-calc      as   character      initial ? no-undo.
define var  parprice-cli-calc      as   character      initial ? no-undo.
define var  parbase-price-calc     as   character      initial ? no-undo.
define var  partax-3-calc          as   character      initial ? no-undo.
define var  parround               as   integer        initial ? no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define shared variable next-prev     as logical   no-undo .
define shared variable br-rcv-handle as handle no-undo   .
define variable p-host-code     as integer   no-undo .
define variable p-g#host-name  as character no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable prt-mode          as character no-undo .
define variable doc-rec           as recid no-undo .
define variable line-rec          as recid no-undo .
define variable gds-rec           as recid no-undo .
define variable prt-rec           as recid no-undo .
define variable g#log             as logical   no-undo .
define variable g#stat            as character no-undo .
define variable g#type            as character no-undo .
define variable g#internal        as logical   no-undo .
define variable g#mainmenu-handle as handle no-undo .
define variable base-code         as integer   no-undo .
define variable v-deliv-type-code    as integer   no-undo .
define variable v-point-obj-code     as integer   no-undo .
define variable v-point-cli-code     as integer   no-undo .
define variable v-point-obj-db-num   as integer   no-undo .
define variable v-point-cli-db-num   as integer   no-undo .
define variable v-transport-host-code     as integer   no-undo .
define variable v-transport-cli-type     as character no-undo .
define variable v-transport-cli-code     as integer   no-undo .
define variable v-transport-contract   as integer   no-undo .
define variable v-transport-condition  as integer   no-undo .
define variable v-transport-value      as decimal   no-undo .
define variable v-transport-sum        as decimal   no-undo .
define variable v-transport-vat        as decimal   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#mainmenu-handle = parParentProc
.
if store-type = ? or store-type = "" then do:
    p-host-code = v-cntxt-host-code-obj .
    define buffer buf_clients-name for ub.clients  .
    find first buf_clients-name no-lock where buf_clients-name.obj-code =  p-host-code and
                                              buf_clients-name.obj-type = 'орг':U no-error .
    p-g#host-name = buf_clients-name.obj-name.
end.
else do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output p-host-code
  ,output p-g#host-name
  )  .
    p-host-code   = v-cntxt-host-code-obj.
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output base-code
  )  .
define buffer b-ord-line for ub.ord-line-rcv  .
define variable loc-time as char no-undo   .
define variable loc-time-2 as char no-undo .
define variable sort-column-name as character no-undo .
define variable kk as integer no-undo .
define variable doc-mode as character no-undo .
DEFINE MENU m-export-2
       MENU-ITEM m___Excel-2    LABEL "Экспорт в Excel"
       MENU-ITEM m_mobilscn-2   LABEL "Экспорт в Моб.сканер".
DEFINE BUTTON B-delivery
     LABEL "&Доставка"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-diff
     LABEL "&Разница"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "Вы&ход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-export
     LABEL "&Экспорт"
     SIZE 10 BY 1 TOOLTIP "Экспорт".
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 3.13 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр строки".
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1 TOOLTIP "Предыдущая поставка"
     BGCOLOR 8 .
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1 TOOLTIP "Предыдущая поставка"
     BGCOLOR 8 .
DEFINE BUTTON b-scl
     LABEL "&Шкала"
     SIZE 10 BY 1 TOOLTIP "Признаки товара".
DEFINE BUTTON B-trn
     LABEL "Просмотр накл"
     SIZE 19 BY 1 TOOLTIP "Просмотр накладной".
DEFINE VARIABLE abbr-base AS CHARACTER FORMAT "X(256)":U
     LABEL "Баз.Вал."
      VIEW-AS TEXT
     SIZE 4 BY .67 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE abbr-cli AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4.25 BY .67 TOOLTIP "Валюта поставщика"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-hour-2 AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Факт.время доставки"
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.
DEFINE VARIABLE l-loc-min-2 AS INTEGER FORMAT "99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.
DEFINE VARIABLE loc-cli-out-code AS CHARACTER FORMAT "X(256)":U
     LABEL "№ по пост."
      VIEW-AS TEXT
     SIZE 28.63 BY .67 TOOLTIP "Номер по нумерации поставщика"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc-type-doc AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE obj_obj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 52.5 BY .88.
DEFINE VARIABLE post_obj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 52.5 BY 1.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 62.75 BY 3.04.
DEFINE QUERY BROWSE-30 FOR
      post-ord-line-rcv,
      Post-goods SCROLLING.
DEFINE QUERY BROWSE-35 FOR
      buf_ord-chain SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      bufs_ord-doc-rcv,
      ub.ord-doc-rcv,
      post-clients,
      obj-clients SCROLLING.
DEFINE BROWSE BROWSE-30
  QUERY BROWSE-30 NO-LOCK DISPLAY
      post-ord-line-rcv.artic      COLUMN-LABEL "Артикул"
      Post-goods.gds-name          COLUMN-LABEL "Наименование"
      Post-goods.unit-base         COLUMN-LABEL "Ед.изм!баз."
      post-ord-line-rcv.qnty       COLUMN-LABEL "Кол-во!(баз.ед.изм.)" FORMAT "->>>>>>>9.<<<"         COLUMN-FGCOLOR 1
      post-ord-line-rcv.unit-cli   COLUMN-LABEL "Ед.изм!пост"
      post-ord-line-rcv.cli-qnty   COLUMN-LABEL "Кол-во!(ед.изм.пост)" FORMAT "->>>>>>>9.<<<"      COLUMN-FGCOLOR 1
      post-ord-line-rcv.price-rubl COLUMN-LABEL "Цена!(нац.вал.)"      FORMAT "->>>>>>>>>>>>9.99"
      post-ord-line-rcv.price-base COLUMN-LABEL "Цена!(баз.вал.)"      FORMAT "->>>>>>>>>>9.99"
      post-ord-line-rcv.price-cli  COLUMN-LABEL "Цена!(пост-ка)"       FORMAT "->>>>>>>>>>9.99" COLUMN-FGCOLOR 1
      post-ord-line-rcv.sub-par    COLUMN-LABEL "Code39"               FORMAT "x(40)" COLUMN-FGCOLOR 1
      post-ord-line-rcv.line-num   COLUMN-LABEL "№"                    FORMAT ">>>>>>9" COLUMN-FGCOLOR 1
  ENABLE
      post-ord-line-rcv.qnty
      post-ord-line-rcv.cli-qnty
      post-ord-line-rcv.price-cli
      post-ord-line-rcv.line-num
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.88 BY 12.63.
DEFINE BROWSE BROWSE-35
  QUERY BROWSE-35 NO-LOCK DISPLAY
      buf_ord-chain.rel-doc-code FORMAT "X(16)":U
    WITH NO-BOX NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 30 BY 2.75 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 11
     b-next AT ROW 1 COL 16
     B-diff AT ROW 1 COL 76 WIDGET-ID 10
     B-delivery AT ROW 1 COL 86
     B-Help AT ROW 1 COL 96
     BROWSE-35 AT ROW 5.25 COL 36 WIDGET-ID 100
     B-trn AT ROW 5.25 COL 68.5
     b-lkp AT ROW 9.13 COL 1.5 WIDGET-ID 6
     b-scl AT ROW 9.13 COL 11.5 WIDGET-ID 8
     b-export AT ROW 9.13 COL 21.5 WIDGET-ID 4
     BROWSE-30 AT ROW 10.38 COL 1.13 WIDGET-ID 200
     ub.ord-doc-rcv.rcv-code AT ROW 1.25 COL 33 COLON-ALIGNED
          LABEL "Поставка"
           VIEW-AS TEXT
          SIZE 13.63 BY .67
          FGCOLOR 4
     loc-type-doc AT ROW 1.25 COL 53 COLON-ALIGNED
     ub.ord-doc-rcv.doc-code AT ROW 2.13 COL 15.25 COLON-ALIGNED
          LABEL "Заказ"
           VIEW-AS TEXT
          SIZE 15 BY .63 TOOLTIP "Номер заказа"
          FGCOLOR 4
     loc-cli-out-code AT ROW 2.13 COL 44.13 COLON-ALIGNED WIDGET-ID 2
     ub.ord-doc-rcv.cli-code AT ROW 3.08 COL 15.25 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 10 BY .67
     ub.ord-doc-rcv.cli-type AT ROW 3.08 COL 25.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     post_obj-name AT ROW 3.08 COL 33.5 COLON-ALIGNED NO-LABEL
     obj_obj-name AT ROW 4.25 COL 33.5 COLON-ALIGNED NO-LABEL
     ub.ord-doc-rcv.obj-code AT ROW 4.29 COL 18 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 10 BY .67
     ub.ord-doc-rcv.obj-type AT ROW 4.29 COL 25.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     ub.ord-doc-rcv.ship-date AT ROW 5.42 COL 15.13 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11.25 BY .67 TOOLTIP "Планируемая дата доставки"
     l-loc-hour AT ROW 6.54 COL 15.25 COLON-ALIGNED
     l-loc-min AT ROW 6.54 COL 20.25 COLON-ALIGNED NO-LABEL
     l-loc-hour-2 AT ROW 6.71 COL 87.38 COLON-ALIGNED
     l-loc-min-2 AT ROW 6.71 COL 92.38 COLON-ALIGNED NO-LABEL
     abbr-cli AT ROW 8.17 COL 25.75 COLON-ALIGNED NO-LABEL
     ub.ord-doc-rcv.exch-rate AT ROW 8.29 COL 30.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY .67 TOOLTIP "курс"
     ub.ord-doc-rcv.exch-scale AT ROW 8.29 COL 43.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5 BY .67 TOOLTIP "масштаб"
     ub.ord-doc-rcv.exch-code AT ROW 8.33 COL 18.13 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 4 BY .67 TOOLTIP "код валюты поставщика"
     abbr-base AT ROW 8.38 COL 73.25 COLON-ALIGNED
     ub.ord-doc-rcv.base-rate AT ROW 8.38 COL 78.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY .67 TOOLTIP "курс"
     ub.ord-doc-rcv.base-scale AT ROW 8.38 COL 91 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5 BY .67 TOOLTIP "масштаб"
     ":" VIEW-AS TEXT
          SIZE 1.25 BY .67 AT ROW 6.71 COL 92
          FGCOLOR 1
     ":" VIEW-AS TEXT
          SIZE 1.25 BY 1 AT ROW 6.33 COL 20.5
          FGCOLOR 1
     RECT-3 AT ROW 5.21 COL 35.5
     SPACE(1.36) SKIP(15.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Поставка по заказу".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-diff:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-export:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-export-2:HANDLE.
ASSIGN
       BROWSE-30:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  apply "CHOOSE":u to b-exit.
END.
ON CHOOSE OF B-delivery IN FRAME Dialog-Frame
DO:
define buffer buf_ord-doc for ub.ord-doc  .
define variable type-mode as character no-undo .
if bufs_ord-doc-rcv.doc-type = "in" then type-mode = "rcv" + 'ОО':U .
else do:
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code no-error .
    if not available buf_ord-doc  then do:
       type-mode = "ord" + 'ОО':U .
    end.
    else type-mode = "ord" + buf_ord-doc.doc-type .
end.
    run cus/pardeliv.w
      (input        parParentproc
      ,input        'ПРОСМОТР':U
      ,input        type-mode
      ,input        bufs_ord-doc-rcv.obj-type
      ,input        bufs_ord-doc-rcv.obj-code
      ,input        bufs_ord-doc-rcv.cli-type
      ,input        bufs_ord-doc-rcv.cli-code
      ,input-output v-deliv-type-code
      ,input-output v-point-obj-code
      ,input-output v-point-obj-db-num
      ,input-output v-point-cli-code
      ,input-output v-point-cli-db-num
      ,input-output v-transport-host-code
      ,input-output v-transport-cli-type
      ,input-output v-transport-cli-code
      ,input-output v-transport-contract
      ,input-output v-transport-condition
      ,input-output v-transport-value
      ,input-output v-transport-sum
      ,input-output v-transport-vat
      ) no-error  .
         if error-status :error then message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "Ошибка"
           view-as alert-box error
         .
END.
ON CHOOSE OF B-diff IN FRAME Dialog-Frame
DO:
define variable v-ps as character no-undo .
  if ub.ord-doc-rcv.ord-int2 = integer('2':U) then do:
    v-ps = ub.ord-doc-rcv.PS .
    run gbl/notes.w ( input 'ПРОСМОТР':U , input-output v-ps ).
  end.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
next-prev = ?.
apply "end-error":u to self.
return.
END.
ON CHOOSE OF b-export IN FRAME Dialog-Frame
DO:
  run cus/z-tot3.p (parParentProc , input ub.ord-doc-rcv.rcv-code , input ub.ord-doc-rcv.doc-code ) .
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  find current post-ord-line-rcv no-error.
  if avail post-ord-line-rcv then do:
  doc-mode  = 'ПРОСМОТР':U .
    run cus/or-obj.w (
      parParentProc
    , bufs_ord-doc-rcv.host-code
    , recid(post-ord-line-rcv)
    , 2
    , 'ПРОСМОТР':U
    , 'ПРОСМОТР':U
    , input-output doc-mode
    ) no-error  .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка при корректировке строки поставки"
      view-as alert-box error
    .
end.
END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
RUN STEP-NEXT IN THIS-PROCEDURE .
END.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
run step-prev in this-procedure .
END.
ON CHOOSE OF b-scl IN FRAME Dialog-Frame
DO:
  message "Режим недоступен" view-as alert-box information .
  return .
END.
ON CHOOSE OF B-trn IN FRAME Dialog-Frame
DO:
if not available buf_ord-chain then return .
    run str/showdoc.p
      (input parparentproc
      ,input buf_ord-chain.rel-doc-code
      ,input ""
      ,input ""
      ,input 0
      ,input true
      ) no-error  .
      if error-status :error then
       message
          "Вернулась из процедуры showdoc.p "
          error-status :get-message(1)
          view-as alert-box error .
END.
ON CHOOSE OF MENU-ITEM m_mobilscn-2
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/z-tot2.p (input parparentproc , input "rcv" , input "" ,input  ub.ord-doc-rcv.rcv-code ) .
END.
ON CHOOSE OF MENU-ITEM m___Excel-2
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/z-tot3.p ( input parParentProc , input ub.ord-doc-rcv.rcv-code , input ub.ord-doc-rcv.doc-code ) .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-30 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  run get_gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to browse-30 in frame Dialog-Frame.
  return no-apply.
end.
on F2 of frame dialog-frame  anywhere do:
 return no-apply.
end.
def var sort-labelBROWSE-30   as character no-undo .
def var sort-clmnBROWSE-30    as handle    no-undo .
def var cur-clmnBROWSE-30     as handle    no-undo .
def var cur-clmn-locBROWSE-30 as integer   no-undo .
def var re-queryBROWSE-30     as logical   initial no no-undo .
on start-search, ctrl-o of BROWSE-30 in frame dialog-frame do:
   run sort-brBROWSE-30
     (input (if available post-ord-line-rcv
             then recid(post-ord-line-rcv)
             else ?
            )
     ).
end.
PROCEDURE sort-brBROWSE-30 :
  define input parameter p-recid as recid no-undo .
  if re-queryBROWSE-30 = no then do:
    assign
       cur-clmnBROWSE-30 = BROWSE-30:current-column in frame dialog-frame
    .
    if sort-clmnBROWSE-30 <> ? then sort-clmnBROWSE-30:column-fgcolor = 0.
    if cur-clmnBROWSE-30 = sort-clmnBROWSE-30 then do:
      assign
         sort-labelBROWSE-30 = ""
         sort-clmnBROWSE-30 = ?
      .
     end.
     else do:
       assign
         sort-labelBROWSE-30 = cur-clmnBROWSE-30:label
         sort-clmnBROWSE-30  = cur-clmnBROWSE-30
         sort-clmnBROWSE-30:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBROWSE-30 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BROWSE-30:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBROWSE-30 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBROWSE-30 = cur-clmn-locBROWSE-30 + 1
    .
  end.
  case sort-labelBROWSE-30:
        when 'Артикул'  then DO:   assign     sort-column-name = "post-ord-line-rcv.artic"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY post-ord-line-rcv.artic .   . END.
        when 'Наименование'  then DO:   assign     sort-column-name = "Post-goods.gds-name"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY Post-goods.gds-name .   . END.
        when 'Ед.изм!баз.'  then DO:   assign     sort-column-name = "Post-goods.unit-base"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY Post-goods.unit-base .   . END.
        when 'Кол-во!(баз.ед.изм.)'  then DO:   assign     sort-column-name = "post-ord-line-rcv.qnty"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY post-ord-line-rcv.qnty .   . END.
        when 'Ед.изм!пост'  then DO:   assign     sort-column-name = "post-ord-line-rcv.unit-cli"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY post-ord-line-rcv.unit-cli .   . END.
        when 'Кол-во!(ед.изм.пост)'  then DO:   assign     sort-column-name = "post-ord-line-rcv.cli-qnty"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY post-ord-line-rcv.cli-qnty .   . END.
        when 'Цена!(нац.вал.)'  then DO:   assign     sort-column-name = "post-ord-line-rcv.price-rubl"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY post-ord-line-rcv.price-rubl .   . END.
        when 'Цена!(баз.вал.)'  then DO:   assign     sort-column-name = "post-ord-line-rcv.price-base"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY post-ord-line-rcv.price-base .   . END.
        when 'Цена!(пост-ка)'  then DO:   assign     sort-column-name = "post-ord-line-rcv.price-cli"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY post-ord-line-rcv.price-cli .   . END.
        when '№'  then DO:   assign     sort-column-name = "post-ord-line-rcv.line-num"   .   OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK,        EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK BY post-ord-line-rcv.line-num .   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run openbr.
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBROWSE-30') then do:
          run mv-brw-defaultBROWSE-30.
        end.
      if sort-labelBROWSE-30 <> "" then do:
        assign
          cur-clmnBROWSE-30:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBROWSE-30 = ?
      .
    end.
  end case.
    if cur-clmn-locBROWSE-30 <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBROWSE-30') then do:
        run ch-clmnBROWSE-30 in this-procedure (cur-clmn-locBROWSE-30).
      end.
    end.
  if p-recid <> ? then do:
    reposition BROWSE-30 to recid p-recid no-error.
    apply "value-changed" to BROWSE-30 in frame dialog-frame.
  end.
  apply "entry" to BROWSE-30 in frame dialog-frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBROWSE-30:
if cur-clmnBROWSE-30 = ? then do:
   run openbr.
end.
else do:
   assign re-queryBROWSE-30 = yes.
   run sort-brBROWSE-30
     (input (if available post-ord-line-rcv
             then recid(post-ord-line-rcv)
             else ?
            )
     ).
   assign re-queryBROWSE-30 = no.
end.
end.
ASSIGN
  b-export:POPUP-MENU IN FRAME dialog-frame  = MENU m-export-2:HANDLE
  b-export:MENU-MOUSE = 1.
next-prev = yes.
n-p: do while next-prev :
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   find first bufs_ord-doc-rcv no-lock  where recid(bufs_ord-doc-rcv) = p-ord-rec  no-error .
     if not available bufs_ord-doc-rcv then do:
        next-prev = ?.
        return error.
        end.
  Post-goods.gds-name:resizable in browse BROWSE-30  = true .
  run input-p in this-procedure no-error .
  run enable_ui in this-procedure no-error .
  if bufs_ord-doc-rcv.ord-int2 = integer('2':U)  then
     display B-diff with frame dialog-frame .
  else hide  B-diff in frame dialog-frame .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numBROWSE-30 as INT EXTENT 10 no-undo.
DEF VAR varmviBROWSE-30       as INT no-undo.
DEF VAR varmvjBROWSE-30       as INT no-undo.
DEF VAR varmvkBROWSE-30       as INT no-undo.
DEF VAR varmvlBROWSE-30       as INT no-undo.
DEF VAR move-elementBROWSE-30 as INT no-undo.
def var jjBROWSE-30           as int no-undo.
do varmviBROWSE-30 = 1 to EXTENT(cur-clmn-numBROWSE-30):
  ASSIGN cur-clmn-numBROWSE-30[varmviBROWSE-30] = varmviBROWSE-30.
END.
RUN start-mv-clmnBROWSE-30.
PROCEDURE start-mv-clmnBROWSE-30:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE BROWSE-30 do:
  RUN re-move-clmnBROWSE-30 ( 2, 10).
END.
ON ctrl-cursor-left OF BROWSE BROWSE-30 do:
  RUN re-move-clmnBROWSE-30 (10, 2).
END.
PROCEDURE re-move-clmnBROWSE-30:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviBROWSE-30 = 1 TO EXTENT(cur-clmn-numBROWSE-30):
    if cur-clmn-numBROWSE-30[varmviBROWSE-30] = source-column THEN cur-clmn-numBROWSE-30[varmviBROWSE-30] = -1.
  END.
  if BROWSE-30:MOVE-COLUMN(source-column, target-column) IN FRAME dialog-frame then.
  if source-column > target-column THEN
  DO varmvjBROWSE-30 = source-column - 1 to target-column BY -1:
    DO varmviBROWSE-30 = 1 TO EXTENT(cur-clmn-numBROWSE-30):
        if cur-clmn-numBROWSE-30[varmviBROWSE-30] = varmvjBROWSE-30 THEN DO:
          cur-clmn-numBROWSE-30[varmviBROWSE-30] = cur-clmn-numBROWSE-30[varmviBROWSE-30] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjBROWSE-30 = source-column + 1 to target-column:
    DO varmviBROWSE-30 = 1 TO EXTENT(cur-clmn-numBROWSE-30):
      if cur-clmn-numBROWSE-30[varmviBROWSE-30] = varmvjBROWSE-30 THEN DO:
        cur-clmn-numBROWSE-30[varmviBROWSE-30] = cur-clmn-numBROWSE-30[varmviBROWSE-30] - 1.
      END.
    END.
  END.
  DO varmviBROWSE-30 = 1 TO EXTENT(cur-clmn-numBROWSE-30):
    if cur-clmn-numBROWSE-30[varmviBROWSE-30] = -1 THEN cur-clmn-numBROWSE-30[varmviBROWSE-30] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnBROWSE-30:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 2 then do:
    return .
  end.
  DO varmviBROWSE-30 = 1 TO EXTENT(cur-clmn-numBROWSE-30):
    if cur-clmn-numBROWSE-30[varmviBROWSE-30] = cur-clmn-loc THEN move-elementBROWSE-30 = varmviBROWSE-30.
  END.
  RUN re-move-clmnBROWSE-30 (cur-clmn-loc, 2).
END PROCEDURE.
PROCEDURE mv-brw-defaultBROWSE-30:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlBROWSE-30 = 2 to EXTENT(cur-clmn-numBROWSE-30):
    RUN re-move-clmnBROWSE-30 (cur-clmn-numBROWSE-30[varmvlBROWSE-30], varmvlBROWSE-30).
  END.
  RUN start-mv-clmnBROWSE-30.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME  dialog-frame  .
END.
END.
run disable_ui  in this-procedure no-error .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH bufs_ord-doc-rcv where recid(bufs_ord-doc-rcv) = p-ord-rec no-LOCK,              first ub.ord-doc-rcv where  recid(ord-doc-rcv) = p-ord-rec no-lock ,              EACH post-clients WHERE                       bufs_ord-doc-rcv.cli-code = post-clients.obj-code and                       bufs_ord-doc-rcv.cli-type = post-clients.obj-type  no-LOCK ,              EACH obj-clients WHERE                       bufs_ord-doc-rcv.obj-code = obj-clients.obj-code and                       bufs_ord-doc-rcv.obj-type = obj-clients.obj-type  no-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY loc-type-doc loc-cli-out-code post_obj-name obj_obj-name l-loc-hour
          l-loc-min l-loc-hour-2 l-loc-min-2 abbr-cli abbr-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.ord-doc-rcv THEN
    DISPLAY ub.ord-doc-rcv.rcv-code ub.ord-doc-rcv.doc-code
          ub.ord-doc-rcv.cli-code ub.ord-doc-rcv.cli-type
          ub.ord-doc-rcv.obj-code ub.ord-doc-rcv.obj-type
          ub.ord-doc-rcv.ship-date ub.ord-doc-rcv.exch-rate
          ub.ord-doc-rcv.exch-scale ub.ord-doc-rcv.exch-code
          ub.ord-doc-rcv.base-rate ub.ord-doc-rcv.base-scale
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-prev b-next B-diff B-delivery B-Help RECT-3 BROWSE-35 B-trn
         b-lkp b-scl b-export BROWSE-30 ub.ord-doc-rcv.rcv-code loc-type-doc
         ub.ord-doc-rcv.doc-code loc-cli-out-code ub.ord-doc-rcv.cli-code
         ub.ord-doc-rcv.cli-type post_obj-name obj_obj-name
         ub.ord-doc-rcv.obj-code ub.ord-doc-rcv.obj-type
         ub.ord-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2
         abbr-cli ub.ord-doc-rcv.exch-rate ub.ord-doc-rcv.exch-scale
         ub.ord-doc-rcv.exch-code abbr-base ub.ord-doc-rcv.base-rate
         ub.ord-doc-rcv.base-scale
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY  BROWSE-30 FOR EACH post-ord-line-rcv  NO-LOCK     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and           bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code ,        EACH Post-goods  NO-LOCK where      Post-goods.artic      =  post-ord-line-rcv.artic  and      Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and      Post-goods.prod-type  =  post-ord-line-rcv.prod-type by post-ord-line-rcv.line-num.
  OPEN QUERY BROWSE-35 FOR EACH buf_ord-chain NO-LOCK  where           buf_ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and           buf_ord-chain.doc-type = 'rcv'                  and           buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE get_gds-rec :
if not available Post-goods then return .
gds-rec = recid(Post-goods) .
END PROCEDURE.
PROCEDURE input-p :
do
 on error undo, return error return-value
 :
 ASSIGN
  v-deliv-type-code     =  bufs_ord-doc-rcv.deliv-type-code
  v-point-obj-code      =  bufs_ord-doc-rcv.obj-point-code
  v-point-cli-code      =  bufs_ord-doc-rcv.cli-point-code
  v-point-obj-db-num    =  bufs_ord-doc-rcv.obj-point-db-num
  v-point-cli-db-num    =  bufs_ord-doc-rcv.cli-point-db-num
  v-transport-host-code      =  bufs_ord-doc-rcv.transport-host-code
  v-transport-cli-type      =  bufs_ord-doc-rcv.transport-cli-type
  v-transport-cli-code      =  bufs_ord-doc-rcv.transport-cli-code
  v-transport-contract  =  bufs_ord-doc-rcv.transport-contract
  v-transport-condition =  bufs_ord-doc-rcv.transport-condition
  v-transport-value     =  bufs_ord-doc-rcv.transport-value
  v-transport-sum       =  bufs_ord-doc-rcv.sum-ship
  v-transport-vat       =  bufs_ord-doc-rcv.transport-vat
  .
define buffer b_trn-doc for ub.trn-doc .
find first post-clients no-lock where
            post-clients.obj-code = bufs_ord-doc-rcv.cli-code   and
            post-clients.obj-type = bufs_ord-doc-rcv.cli-type
            no-error .
            post_obj-name = post-clients.obj-name.
find first obj-clients no-lock where
            bufs_ord-doc-rcv.obj-code = obj-clients.obj-code and
            bufs_ord-doc-rcv.obj-type = obj-clients.obj-type
            no-error .
            obj_obj-name = obj-clients.obj-name.
for each ub.ord-chain no-lock where
          ub.ord-chain.doc-code = bufs_ord-doc-rcv.rcv-code and
          ub.ord-chain.doc-type = 'rcv'                  and
          ub.ord-chain.rel-doc-type = 'trn'
          :
end.
find first ub.currency no-lock   where ub.currency.curr-code = bufs_ord-doc-rcv.EXCH-CODE no-error.
  if available ub.currency then abbr-cli = ub.currency.curr-abbr .
define variable   p-exch-rate  as decimal   no-undo .
define variable   p-exch-scale as decimal   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  base-code
  ,input  today
  ,output p-exch-rate
  ,output p-exch-scale
  ,output abbr-base
  )  .
loc-doc-type = bufs_ord-doc-rcv.doc-type.
Assign
   loc-time       = string( bufs_ord-doc-rcv.ship-time ,"HH:MM")
   loc-time-2     = string( bufs_ord-doc-rcv.fact-ship-time ,"HH:MM")
   l-loc-hour     = integer (entry(1,loc-time,":"))
   l-loc-min      = integer (entry(2,loc-time,":"))
   l-loc-hour-2   = integer (entry(1,loc-time-2,":"))
   l-loc-min-2    = integer (entry(2,loc-time-2,":"))
   loc-type-doc    = IF (bufs_ord-doc-rcv.doc-type = "out":U) THEN ("внешн") ELSE ("внутр")
   loc-base-rate   = bufs_ord-doc-rcv.base-rate
   loc-base-scale  = bufs_ord-doc-rcv.base-scale
   loc-exch-code   = bufs_ord-doc-rcv.exch-code
   loc-exch-rate   = bufs_ord-doc-rcv.exch-rate
   loc-exch-scale  = bufs_ord-doc-rcv.exch-scale
   loc-cli-out-code =  entry(1,bufs_ord-doc-rcv.sub-par,chr(4))
   no-error .
   assign frame dialog-frame:title  = "ПОСТАВКА " + bufs_ord-doc-rcv.rcv-code + " - " + 'ПРОСМОТР':U .
  assign
    post-ord-line-rcv.qnty :read-only      in browse BROWSE-30 = true
    post-ord-line-rcv.cli-qnty:read-only   in browse browse-30 = true
    post-ord-line-rcv.price-cli:read-only  in browse browse-30 = true
    post-ord-line-rcv.line-num:read-only   in browse browse-30 = true.
   enable b-trn  with frame  dialog-frame .
  view frame dialog-frame  .
  display  BROWSE-30 with frame  dialog-frame.
  OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv  NO-LOCK     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and           bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code ,        EACH Post-goods  NO-LOCK where      Post-goods.artic      =  post-ord-line-rcv.artic  and      Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and      Post-goods.prod-type  =  post-ord-line-rcv.prod-type.
  find first ub.goods no-lock where ub.goods.gds-code = Post-goods.gds-code no-error .
end.
END PROCEDURE.
PROCEDURE look-trn-all :
do
 on error undo, return error return-value
 :
  display  browse-30 with frame  dialog-frame.
  OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv  NO-LOCK     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and           bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code ,        EACH Post-goods  NO-LOCK where      Post-goods.artic      =  post-ord-line-rcv.artic  and      Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and      Post-goods.prod-type  =  post-ord-line-rcv.prod-type.
  find first ub.goods  no-lock where ub.goods.gds-code = Post-goods.gds-code no-error .
end.
END PROCEDURE.
PROCEDURE openbr :
 do
 on error undo, return error return-value
 :
OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv  NO-LOCK     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and           bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code ,        EACH Post-goods  NO-LOCK where      Post-goods.artic      =  post-ord-line-rcv.artic  and      Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and      Post-goods.prod-type  =  post-ord-line-rcv.prod-type.
end.
END PROCEDURE.
PROCEDURE step-next :
 do
 on error undo, return error return-value
 :
if valid-handle (br-rcv-handle) then do:
  g#log = br-rcv-handle:select-next-row().
  if not g#log then message "Это последний документ списка.".
end.
    doc-rec = recid ( bufs_ord-doc-rcv ).
    p-ord-rec = recid ( bufs_ord-doc-rcv ).
    next-prev = true .
    line-rec = ? .
    prt-rec  = ? .
  end.
END PROCEDURE.
PROCEDURE step-prev :
 do
 on error undo, return error return-value
 :
if valid-handle (br-rcv-handle) then do:
  g#log = br-rcv-handle:select-prev-row().
  if not g#log then message "Это первый документ списка.".
end.
doc-rec   = recid ( bufs_ord-doc-rcv ) .
p-ord-rec = recid ( bufs_ord-doc-rcv ) .
next-prev = true .
line-rec = ?.
prt-rec = ?.
  end.
END PROCEDURE.
