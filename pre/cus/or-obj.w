DEFINE BUFFER buf_ord-chain FOR ub.ord-chain.
DEFINE TEMP-TABLE loc-doc-rcv NO-UNDO LIKE ub.ord-doc-rcv.
DEFINE TEMP-TABLE loc-line-rcv NO-UNDO LIKE ub.ord-line-rcv.
DEFINE BUFFER Obj-clients FOR ub.clients.
DEFINE BUFFER Post-clients FOR ub.clients.
DEFINE BUFFER Post-goods FOR ub.goods.
DEFINE BUFFER post-ord-line-rcv FOR ub.ord-line-rcv.
DEFINE BUFFER rcv_goods FOR ub.goods.
define input  parameter parParentProc   as widget-handle no-undo.
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-ord-rec       as recid no-undo .
define input  parameter p-mode          as integer no-undo .
define input  parameter list-mode       as character no-undo .
define input  parameter line-mode       as character no-undo .
define input-output parameter  doc-mode          as character no-undo .
define SHARED variable x-make-avto as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма редактирования поставки".
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
procedure create-chain :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-doc-type as character no-undo .
define input  parameter p-rel-doc-code as character no-undo .
define input  parameter p-rel-doc-type as character no-undo .
define input  parameter p-type as character no-undo .
define input  parameter p-ps as character no-undo .
define variable v-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
  find first ub.sys-ctrl no-lock .
  v-db-num = ub.sys-ctrl.db-num .
  find first ub.ord-chain no-lock where
    ub.ord-chain.doc-code     = p-doc-code     and
    ub.ord-chain.doc-type     = p-doc-type     and
    ub.ord-chain.rel-type     = p-type         and
    ub.ord-chain.rel-doc-code = p-rel-doc-code and
    ub.ord-chain.rel-doc-type = p-rel-doc-type   no-error .
  if available ub.ord-chain then return .
  create ub.ord-chain.
  assign
    ub.ord-chain.doc-code     = p-doc-code
    ub.ord-chain.doc-type     = p-doc-type
    ub.ord-chain.ps           = p-ps
    ub.ord-chain.rel-doc-code = p-rel-doc-code
    ub.ord-chain.rel-doc-type = p-rel-doc-type
    ub.ord-chain.rel-id       = next-value( s-ord-ch, ub )
    ub.ord-chain.db-num       = v-db-num
    ub.ord-chain.rel-type     = p-type
    .
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
procedure ver-qnty-rcv-from-ord :
define input  parameter p-ord-doc as character no-undo .
define output parameter p-is-lim as logical    no-undo .
define buffer buf_ord-doc     for ub.ord-doc      .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define variable v-kol as integer   no-undo .
define variable v-ver as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-is-lim = false .
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = p-ord-doc no-error .
  if buf_ord-doc.doc-type <> 'ОП':U then return .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_ord-doc.obj-type
  ,input buf_ord-doc.obj-code
  ,input 'ord-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'ord-11':U then v-ver = thbjattr_thbj-attr.property-value-logical .
  end.
v-kol = 0.
  if v-ver then do:
     for each buf_ord-doc-rcv no-lock where
              buf_ord-doc-rcv.doc-code = p-ord-doc :
       v-kol = v-kol + 1.
       leave.
     end.
   if v-kol > 0 then p-is-lim = true .
  end.
end.
end procedure.
procedure ver-qnty-trn-from-rcv :
define input  parameter p-rcv-code as character no-undo .
define output parameter p-is-lim as logical   no-undo .
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-chain for ub.ord-chain .
define buffer buf_trn-doc for ub.trn-doc  .
define variable v-kol as integer   no-undo .
define variable v-ver as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-is-lim = false .
  find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.rcv-code = p-rcv-code no-error .
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
  if buf_ord-doc.doc-type <> 'ОП':U then return .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_ord-doc.obj-type
  ,input buf_ord-doc.obj-code
  ,input 'ord-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'ord-11':U then v-ver = thbjattr_thbj-attr.property-value-logical .
  end.
    if v-ver then do:
    v-kol = 0.
        for each buf_ord-chain no-lock where
                buf_ord-chain.doc-code = p-rcv-code and
                buf_ord-chain.doc-type = 'rcv' and
                buf_ord-chain.rel-doc-type = 'trn' ,
            first buf_trn-doc NO-LOCK where
                  buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
                  :
            v-kol = v-kol + 1.
            leave.
        end.
        if v-kol > 0 then p-is-lim = true .
    end.
  end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable  type-pr  as widget-handle.
define buffer b-ord-line for ub.ord-line-rcv  .
define buffer buf_trn-doc for ub.trn-doc  .
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
define variable loc-cli-base-rate as decimal no-undo.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output p-host-code
  ,output p-g#host-name
  )  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output base-code
  )  .
define variable v-deliv-type-code    as integer   no-undo .
define variable v-point-obj-code     as integer   no-undo .
define variable v-point-cli-code     as integer   no-undo .
define variable v-point-obj-db-num   as integer   no-undo .
define variable v-point-cli-db-num   as integer   no-undo .
define variable v-transport-host-code     as integer   no-undo .
define variable v-transport-cli-type     as character no-undo .
define variable v-transport-cli-code   as integer   no-undo .
define variable v-transport-contract   as integer   no-undo .
define variable v-transport-condition  as integer   no-undo .
define variable v-transport-value      as decimal   no-undo .
define variable v-transport-sum        as decimal   no-undo .
define variable v-transport-vat        as decimal   no-undo .
define variable loc-time as char no-undo   .
define variable loc-time-2 as char no-undo .
define variable sort-column-name as character no-undo .
define variable kk like ub.goods.cli-base-rate no-undo .
if p-mode = 1 or p-mode = 3  then do:
   find first ub.ord-doc-rcv no-lock  where recid(ub.ord-doc-rcv) = p-ord-rec .
end.
if p-mode = 2 then do:
if doc-mode = 'ПРОСМОТР':U and line-mode = 'ПРОСМОТР':U then do:
    find first ub.ord-line-rcv no-lock  where recid(ub.ord-line-rcv) = p-ord-rec no-error .
    find first ub.ord-doc-rcv  no-lock  where ub.ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code  no-error .
    find first b-ord-line   no-lock  where recid(b-ord-line) = p-ord-rec no-error .
  end.
  else do:
    find first ub.ord-line-rcv  exclusive-lock    where recid(ub.ord-line-rcv) = p-ord-rec no-error .
    find first ub.ord-doc-rcv   exclusive-lock    where ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code  no-error .
    find first b-ord-line    exclusive-lock    where recid(b-ord-line) = p-ord-rec no-error .
  end.
end.
if not available  ub.ord-doc-rcv  then do:
   return error.
end.
if not (available  ub.ord-doc-rcv and avail ub.ord-doc-rcv)  and p-mode = 2 then do:
   return error.
end.
create loc-doc-rcv.
buffer-copy ub.ord-doc-rcv to loc-doc-rcv  .
define buffer bufi_ord-doc for ub.ord-doc  .
find first bufi_ord-doc no-lock where
           bufi_ord-doc.doc-code = ub.ord-doc-rcv.doc-code no-error .
if available bufi_ord-doc then do:
   g#stat  = bufi_ord-doc.status_ .
   g#type  = bufi_ord-doc.doc-type.
end.
if p-mode = 2 then do:
  create loc-line-rcv.
  buffer-copy ub.ord-line-rcv to loc-line-rcv.
end.
DEFINE MENU m-export
       MENU-ITEM m___Excel      LABEL "Экспорт в Excel"
       MENU-ITEM m_mobilscn     LABEL "Экспорт в Моб.сканер".
DEFINE BUTTON B-create-trn  NO-CONVERT-3D-COLORS
     LABEL "Создать накл"
     SIZE 15.5 BY 1 TOOLTIP "Создать накладную по поставке".
DEFINE BUTTON B-delivery
     LABEL "&Доставка"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 11 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-stop AUTO-GO
     LABEL "Стоп&Цикл"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-trn
     LABEL "Просмотр накл"
     SIZE 15.5 BY 1 TOOLTIP "Просмотр накладной".
DEFINE BUTTON B-trn-2
     LABEL "Показать накл"
     SIZE 15.5 BY 1 TOOLTIP "Показать накладную рядом с поставкой".
DEFINE BUTTON B-trn-3
     LABEL "Привязать накл"
     SIZE 15.5 BY 1 TOOLTIP "Привязка накладной".
DEFINE BUTTON B-trn-4
     LABEL "Удал Привязку"
     SIZE 15.5 BY 1 TOOLTIP "Удалить связь с накладной".
DEFINE BUTTON r-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-obj"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
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
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-hour-2 AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Факт.время доставки"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.
DEFINE VARIABLE l-loc-min-2 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.
DEFINE VARIABLE loc-cli-out-code AS CHARACTER FORMAT "X(14)":U
     LABEL "№по пост"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "№ поставки по нумерации Поставщика"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc-type-doc AS CHARACTER FORMAT "X(4)":U
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 5.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE obj_obj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 28.75 BY .88.
DEFINE VARIABLE post_obj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 28.75 BY 1.
DEFINE VARIABLE tot-base AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE .88 BY .67
     BGCOLOR 3 FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE tot-cli AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE 1.13 BY .67
     BGCOLOR 3 FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE tot-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE .75 BY .67
     BGCOLOR 3 FGCOLOR 3  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.75 BY 13.42.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.5 BY 6.75.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить строку".
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить строку".
DEFINE BUTTON b-export-2
     LABEL "&Экспорт"
     SIZE 10 BY 1 TOOLTIP "Экспорт в Excel".
DEFINE BUTTON b-flt
     LABEL "&Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтр".
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр строки".
DEFINE BUTTON b-scl
     LABEL "&Шкала"
     SIZE 10 BY 1 TOOLTIP "Признаки товара".
DEFINE BUTTON b-chg-2
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить строку".
DEFINE BUTTON b-del-2
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить строку".
DEFINE BUTTON b-lkp-2
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр строки".
DEFINE BUTTON b-scl-2
     LABEL "&Шкала"
     SIZE 10 BY 1 TOOLTIP "Признаки товара".
DEFINE QUERY BROWSE-30 FOR
      post-ord-line-rcv,
      Post-goods SCROLLING.
DEFINE QUERY BROWSE-32 FOR
      post-ord-line-rcv,
      Post-goods,
      ub.doc-line SCROLLING.
DEFINE QUERY BROWSE-37 FOR
      buf_ord-chain SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      loc-doc-rcv,
      loc-line-rcv,
      post-clients,
      obj-clients,
      ub.goods SCROLLING.
DEFINE BROWSE BROWSE-30
  QUERY BROWSE-30 NO-LOCK DISPLAY
      post-ord-line-rcv.artic
      Post-goods.gds-name
      Post-goods.unit-base COLUMN-LABEL "Ед.изм!баз."
      post-ord-line-rcv.qnty COLUMN-LABEL "Кол-во!(баз.ед.изм.)" FORMAT ">>>>>>>9.<<<"
            COLUMN-FGCOLOR 1
      post-ord-line-rcv.unit-cli COLUMN-LABEL "Ед.изм!пост."
      post-ord-line-rcv.cli-qnty COLUMN-LABEL "Кол-во!(ед.изм.пост)" FORMAT ">>>>>>>9.<<<"
            COLUMN-FGCOLOR 1
      post-ord-line-rcv.price-rubl FORMAT "->>>>>>>>>>>>9.999"
      post-ord-line-rcv.price-base FORMAT "->>>>>>>>>>9.999"
      post-ord-line-rcv.price-cli FORMAT "->>>>>>>>>>9.999" COLUMN-FGCOLOR 1
      post-ord-line-rcv.sub-par    COLUMN-LABEL "Code39"               FORMAT "x(40)" COLUMN-FGCOLOR 1
      post-ord-line-rcv.line-num FORMAT ">>>>>>9" COLUMN-FGCOLOR 1
  ENABLE
      post-ord-line-rcv.cli-qnty
      post-ord-line-rcv.line-num
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.88 BY 12.
DEFINE BROWSE BROWSE-32
  QUERY BROWSE-32 NO-LOCK DISPLAY
      post-ord-line-rcv.artic
      Post-goods.gds-name
      Post-goods.unit-base COLUMN-LABEL "Ед.изм!баз."
      post-ord-line-rcv.qnty COLUMN-LABEL "Кол-во!(баз.ед.изм.)" FORMAT ">>>>>>>9.<<<"
            COLUMN-FGCOLOR 1
      ub.doc-line.doc-qnty LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      ub.doc-line.fact-qnty LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.unit-cli COLUMN-LABEL "Ед.изм!пост"
      post-ord-line-rcv.cli-qnty COLUMN-LABEL "Кол-во!(ед.изм.пост)" FORMAT ">>>>>>>9.<<<"
            COLUMN-FGCOLOR 1
      ub.doc-line.cli-qnty LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.price-rubl FORMAT "->>>>>>>>>>>>9.999"
      ub.doc-line.price-rubl LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.price-base FORMAT "->>>>>>>>>>9.999"
      ub.doc-line.price-base LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.price-cli FORMAT "->>>>>>>>>>9.999" COLUMN-FGCOLOR 1
      ub.doc-line.price-cli LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.line-num FORMAT ">>>>>>9" COLUMN-FGCOLOR 1
      ub.doc-line.cli-base-rate
  ENABLE
      post-ord-line-rcv.cli-qnty
      post-ord-line-rcv.line-num
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 12.
DEFINE BROWSE BROWSE-37
  QUERY BROWSE-37 NO-LOCK DISPLAY
      buf_ord-chain.rel-doc-code FORMAT "X(16)":U
    WITH NO-BOX NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 20.5 BY 5 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-exit AT ROW 1 COL 12
     B-stop AT ROW 1 COL 22
     B-delivery AT ROW 1 COL 79
     B-Help AT ROW 1 COL 89
     loc-cli-out-code AT ROW 2.25 COL 44 COLON-ALIGNED WIDGET-ID 2
     loc-doc-rcv.cli-code AT ROW 3 COL 11 COLON-ALIGNED
          LABEL "Поставщик"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     loc-doc-rcv.cli-type AT ROW 3 COL 21.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     r-clients AT ROW 3 COL 27.63
     BROWSE-37 AT ROW 3 COL 61 WIDGET-ID 100
     B-create-trn AT ROW 3 COL 82.25
     B-trn AT ROW 4 COL 82.25
     loc-doc-rcv.obj-code AT ROW 4.21 COL 11 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     loc-doc-rcv.obj-type AT ROW 4.21 COL 21.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     r-obj AT ROW 4.21 COL 27.63
     B-trn-3 AT ROW 5 COL 82.25
     loc-doc-rcv.ship-date AT ROW 5.42 COL 15.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11.25 BY 1 TOOLTIP "Планируемая дата доставки"
     l-loc-hour AT ROW 5.5 COL 34 COLON-ALIGNED
     l-loc-min AT ROW 5.5 COL 39 COLON-ALIGNED NO-LABEL
     B-trn-2 AT ROW 6 COL 82.25
     B-trn-4 AT ROW 7 COL 82.25 WIDGET-ID 4
     loc-doc-rcv.exch-code AT ROW 7.96 COL 18 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "код валюты поставщика"
     l-loc-hour-2 AT ROW 7.96 COL 87.88 COLON-ALIGNED
     l-loc-min-2 AT ROW 7.96 COL 92.88 COLON-ALIGNED NO-LABEL
     r-curr AT ROW 8.04 COL 24.25
     loc-line-rcv.price-cli AT ROW 11.17 COL 75.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21.25 BY 1
     loc-line-rcv.cli-qnty AT ROW 11.63 COL 17.88 COLON-ALIGNED
          LABEL "Кол-во в ед.пост"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     loc-line-rcv.cli-base-rate AT ROW 12.17 COL 40.88 COLON-ALIGNED
          LABEL "К/т"
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     loc-line-rcv.price-rubl AT ROW 12.21 COL 75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21.5 BY 1
     loc-line-rcv.qnty AT ROW 12.83 COL 17.88 COLON-ALIGNED
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     loc-line-rcv.price-base
          FORMAT ">>>>>>>>>>9.999<<<<"
          AT ROW 13.25 COL 75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     loc-line-rcv.SLT-pc AT ROW 14.25 COL 75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     loc-line-rcv.VAT-pc AT ROW 15.25 COL 75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     loc-doc-rcv.rcv-code AT ROW 1.25 COL 45.5 COLON-ALIGNED
          LABEL "№ Пост-ки"
           VIEW-AS TEXT
          SIZE 11.5 BY .67
          FGCOLOR 4
     loc-type-doc AT ROW 2.25 COL 4 COLON-ALIGNED
     loc-doc-rcv.doc-code AT ROW 2.25 COL 18.5 COLON-ALIGNED
          LABEL "Заказ №"
           VIEW-AS TEXT
          SIZE 15 BY .63
          FGCOLOR 4
     post_obj-name AT ROW 3 COL 29.25 COLON-ALIGNED NO-LABEL
     obj_obj-name AT ROW 4.17 COL 29.25 COLON-ALIGNED NO-LABEL
     abbr-base AT ROW 7 COL 10.5 COLON-ALIGNED
     loc-doc-rcv.base-rate AT ROW 7 COL 15 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY .67 TOOLTIP "курс"
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME Dialog-Frame
     loc-doc-rcv.base-scale AT ROW 7 COL 27.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5 BY .67 TOOLTIP "масштаб"
     abbr-cli AT ROW 8.17 COL 25.75 COLON-ALIGNED NO-LABEL
     loc-doc-rcv.exch-rate AT ROW 8.17 COL 30.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY .67 TOOLTIP "курс"
     loc-doc-rcv.exch-scale AT ROW 8.17 COL 43.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5 BY .67 TOOLTIP "масштаб"
     loc-line-rcv.artic AT ROW 10.13 COL 1 NO-LABEL
           VIEW-AS TEXT
          SIZE 14.75 BY 1
          BGCOLOR 3 FGCOLOR 15
     loc-line-rcv.prod-type AT ROW 10.13 COL 14 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4.63 BY 1
          BGCOLOR 3 FGCOLOR 15
     loc-line-rcv.prod-code AT ROW 10.13 COL 18.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY 1
          BGCOLOR 3 FGCOLOR 15
    ub.goods.gds-name AT ROW 10.13 COL 29.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 66.88 BY 1
          BGCOLOR 3 FGCOLOR 15
     tot-cli AT ROW 10.17 COL 95.13 COLON-ALIGNED NO-LABEL
     tot-rubl AT ROW 10.21 COL 94.75 COLON-ALIGNED NO-LABEL
     tot-base AT ROW 10.33 COL 95.13 COLON-ALIGNED NO-LABEL
     loc-line-rcv.unit-cli AT ROW 11.88 COL 31.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
    ub.goods.unit-base AT ROW 12.92 COL 31.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     " НАКЛАДНАЯ" VIEW-AS TEXT
          SIZE 11.5 BY .67 AT ROW 2.25 COL 73.5
          BGCOLOR 3 FGCOLOR 15
     ":" VIEW-AS TEXT
          SIZE 1.25 BY 1 AT ROW 5.5 COL 39.25
          FGCOLOR 1
     ":" VIEW-AS TEXT
          SIZE 1.25 BY 1 AT ROW 7.96 COL 93.13
          FGCOLOR 1
     RECT-1 AT ROW 10.04 COL 1.13
     RECT-3 AT ROW 2.25 COL 60.5
     SPACE(0.11) SKIP(14.46)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Поставка по заказу".
DEFINE FRAME FRAME-A
     b-chg AT ROW 1 COL 1
     b-lkp AT ROW 1 COL 11
     b-del AT ROW 1 COL 21
     b-scl AT ROW 1 COL 31
     b-export-2 AT ROW 1 COL 41
     b-flt AT ROW 1 COL 54.5
     BROWSE-30 AT ROW 2 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 9
         SIZE 98 BY 14.21
         TITLE "Строки поставки".
DEFINE FRAME FRAME-B
     b-chg-2 AT ROW 1 COL 1
     b-lkp-2 AT ROW 1 COL 11
     b-del-2 AT ROW 1 COL 21
     b-scl-2 AT ROW 1 COL 31
     BROWSE-32 AT ROW 2 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 9
         SIZE 98 BY 14.33
         TITLE "Строки поставки и накладной".
ASSIGN FRAME FRAME-A:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-B:FRAME = FRAME Dialog-Frame:HANDLE.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       r-clients:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tot-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tot-cli:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tot-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       FRAME FRAME-A:HIDDEN           = TRUE.
ASSIGN
       b-export-2:POPUP-MENU IN FRAME FRAME-A       = MENU m-export:HANDLE.
ASSIGN
       b-flt:HIDDEN IN FRAME FRAME-A           = TRUE.
ASSIGN
       BROWSE-30:NUM-LOCKED-COLUMNS IN FRAME FRAME-A     = 2.
ASSIGN
       FRAME FRAME-B:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME FRAME-A
DO:
define variable  L-RECID AS RECID NO-UNDO.
find current post-ord-line-rcv no-lock  no-error.
  if avail post-ord-line-rcv then do:
    L-RECID = RECID(post-ord-line-rcv) .
    run cus/or-obj.w
    ( parParentProc
    , p-host-code
    , recid(post-ord-line-rcv)
    , 2
    , 'ИЗМЕНЕНИЕ':U
    , 'ИЗМЕНЕНИЕ':U
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
    g#log =  BROWSE-30:refresh() .
  end.
END.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame frame-a anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to browse-30 in frame frame-a.
  return no-apply.
end.
assign
  loc-cli-base-rate = if available loc-line-rcv then loc-line-rcv.cli-base-rate else 1.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON LEAVE OF loc-line-rcv.cli-qnty IN FRAME dialog-frame
DO:
define variable varprt-obj_free-qnty like ub.prt-obj.free-qnty no-undo.
IF CAN-FIND(FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-cli
                    and LOOKUP('шту':U, ub.units.type) > 0 )  AND
   TRUNC(input frame dialog-frame loc-line-rcv.cli-qnty, 0)
   <>    input frame dialog-frame loc-line-rcv.cli-qnty
   THEN DO:
      MESSAGE "Единица изм поставщика " ub.goods.unit-cli " - штучная." skip
              "Кол-во должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN NO-APPLY.
  END.
if ub.goods.qnty-cart <> 0 then do:
  if input frame dialog-frame loc-line-rcv.cli-qnty / ub.goods.qnty-cart -
  truncate ( input frame dialog-frame loc-line-rcv.cli-qnty / ub.goods.qnty-cart , 0 ) <> 0 then do:
      g#log = yes.
      message "Товар рекомендуется выписывать упаковками." skip (2)
              "Округлить до целого числа упаковок ?"
               view-as alert-box question buttons yes-no update g#log .
      if g#log then do:
        if round (input frame dialog-frame loc-line-rcv.cli-qnty / ub.goods.qnty-cart, 0) = 0 then do:
          display
              ub.goods.qnty-cart @ loc-line-rcv.cli-qnty
              with frame dialog-frame.
        end.
        else do:
          display
            round ( input frame dialog-frame loc-line-rcv.cli-qnty / ub.goods.qnty-cart, 0) * ub.goods.qnty-cart @ loc-line-rcv.cli-qnty
            with frame dialog-frame.
        end.
      end.
  end.
end.
 if loc-line-rcv.cli-base-rate:sensitive in frame dialog-frame then do:
    assign
      KK = input frame dialog-frame loc-line-rcv.cli-base-rate
      loc-line-rcv.cli-base-rate = input frame dialog-frame loc-line-rcv.cli-base-rate.
    .
    end.
 else do:
    if b-ord-line.cli-base-rate = 0 or b-ord-line.cli-base-rate = ? then
    kk = ub.goods.cli-base-rate.
    else KK = b-ord-line.cli-base-rate.
  end.
  if lookup('cli-base-rate',parcli-qnty-calc) = 0 then do:
  assign
    tot-cli = input frame dialog-frame loc-line-rcv.price-cli * input frame dialog-frame loc-line-rcv.cli-qnty
    loc-line-rcv.qnty = ( input frame dialog-frame loc-line-rcv.cli-qnty ) * kk .
    DISPLAY  tot-cli loc-line-rcv.qnty   WITH FRAME dialog-frame.
  apply "leave" to loc-line-rcv.qnty .
  DISPLAY  tot-cli loc-line-rcv.qnty WITH FRAME dialog-frame.
  run ass-var in this-procedure .
  end.
END.
ON LEAVE OF loc-line-rcv.qnty IN FRAME dialog-frame
DO:
 IF CAN-FIND(FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-base
                    and LOOKUP('шту':U, ub.units.type) > 0)  AND
   TRUNC(input frame dialog-frame loc-line-rcv.qnty, 0)
   <>    input frame dialog-frame loc-line-rcv.qnty
   THEN DO:
      MESSAGE "Базовая единица товара " ub.goods.unit-base " - штучная." skip
              "Кол-во по факту должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN no-apply.
  END.
 if pardoc-qnty-input = true then do:
    if lookup('cli-base-rate',parcli-qnty-calc) > 0 then do:
     assign
        kk = (input frame dialog-frame loc-line-rcv.qnty) / (input frame dialog-frame loc-line-rcv.cli-qnty )
     .
     if kk  = ? then kk = 1.
     b-ord-line.cli-base-rate = kk  .
    end.
    else do:
        if b-ord-line.cli-base-rate = 0 or b-ord-line.cli-base-rate = ? then
          kk = ub.goods.cli-base-rate .
          else KK = b-ord-line.cli-base-rate .
        assign
            loc-line-rcv.cli-qnty = input frame dialog-frame loc-line-rcv.qnty / kk
            tot-cli = input frame dialog-frame loc-line-rcv.price-cli * input frame dialog-frame loc-line-rcv.cli-qnty
            .
            DISPLAY  tot-cli loc-line-rcv.cli-qnty   WITH FRAME dialog-frame.
       end.
  run ass-var in this-procedure .
  end.
END.
ON LEAVE OF loc-line-rcv.price-base IN FRAME dialog-frame
DO:
if input frame dialog-frame loc-line-rcv.price-base > 5000 and base-code = 1 then
  message "Внимание !!!" skip (2)
                  "ВАЛЮТНАЯ цена превышает 5,000 !" skip (2)
                  "Вы не ошиблись ?".
if loc-line-rcv.price-base <> input frame dialog-frame loc-line-rcv.price-base then
  assign
    loc-line-rcv.price-rubl = input frame dialog-frame loc-line-rcv.price-base * loc-base-rate / loc-base-scale
    loc-line-rcv.price-cli  = loc-line-rcv.price-rubl / loc-exch-rate * loc-exch-scale *
     loc-cli-base-rate
    .
    DISPLAY
    loc-line-rcv.price-RUBL
    loc-line-rcv.price-cli
    WITH FRAME dialog-frame .
 run ass-var in this-procedure  .
END.
ON LEAVE OF loc-line-rcv.price-rubl IN FRAME dialog-frame
DO:
if loc-line-rcv.price-rubl <> input frame dialog-frame loc-line-rcv.price-rubl then
  assign
    loc-line-rcv.price-base = input frame dialog-frame loc-line-rcv.price-rubl / loc-base-rate * loc-base-scale
    loc-line-rcv.price-cli  = input frame dialog-frame loc-line-rcv.price-rubl / loc-exch-rate * loc-exch-scale /
     loc-cli-base-rate
    .
    DISPLAY
    loc-line-rcv.price-base
    loc-line-rcv.price-cli
    WITH FRAME dialog-frame .
    run ass-var in this-procedure .
END.
ON LEAVE OF loc-line-rcv.price-cli IN FRAME dialog-frame
DO:
if loc-line-rcv.price-cli <> input frame dialog-frame loc-line-rcv.price-cli then
  assign
    tot-cli = input frame dialog-frame loc-line-rcv.price-cli *  input frame dialog-frame loc-line-rcv.cli-qnty
    .
 run ass-var in this-procedure .
END.
procedure ass-var :
 do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if loc-line-rcv.qnty:sensitive in frame dialog-frame         then loc-line-rcv.qnty           = input frame dialog-frame loc-line-rcv.qnty         .
if loc-line-rcv.cli-qnty:sensitive in frame dialog-frame     then loc-line-rcv.cli-qnty       = input frame dialog-frame loc-line-rcv.cli-qnty     .
if loc-line-rcv.price-base:sensitive  in frame dialog-frame  then loc-line-rcv.price-base     = input frame dialog-frame loc-line-rcv.price-base   .
if loc-line-rcv.price-rubl:sensitive in frame dialog-frame   then loc-line-rcv.price-rubl     = input frame dialog-frame loc-line-rcv.price-rubl   .
if loc-line-rcv.price-cli:sensitive  in frame dialog-frame   then loc-line-rcv.price-cli      = input frame dialog-frame loc-line-rcv.price-cli    .
if loc-line-rcv.cli-base-rate:sensitive in frame dialog-frame then loc-line-rcv.cli-base-rate = input frame dialog-frame loc-line-rcv.cli-base-rate.
 loc-store-type =  loc-doc-rcv.obj-type .
 loc-store-code =  loc-doc-rcv.obj-code .
 assign
    pargds-code =  ub.goods.gds-code
    parobj-type =  loc-store-type
    parobj-code =  loc-store-code
 .
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_kndinpin in g#lib-calc
  (
   input  pargds-code
  ,input  loc-cli-type
  ,input  loc-cli-code
  ,input  parobj-type
  ,input  parobj-code
  ,output parext-gds-type
  ,output parcli-qnty-input
  ,output pardensity-input
  ,output parcli-base-rate-input
  ,output pardoc-qnty-input
  ,output parfact-qnty-input
  ,output parprice-cli-input
  ,output parbase-price-input
  ,output partax-3-input
  ,output parcli-qnty-calc
  ,output pardensity-calc
  ,output parcli-base-rate-calc
  ,output pardoc-qnty-calc
  ,output parfact-qnty-calc
  ,output parprice-cli-calc
  ,output parbase-price-calc
  ,output partax-3-calc
  ,output parround
  ) no-error.
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "1"
  view-as alert-box error
.
if  parext-gds-type =  'sg':U then
  do:
   assign
    parcli-qnty-input   = true
    parprice-cli-input  = true
   .
  end.
if g#type =  'ОФ':U then
assign
parbase-price-my = false
parbase-price-input = false
parprice-cli-input  = false
.
else
assign
  parbase-price-my = true
.
if parbase-price-calc = 'cli-price' then do:
 assign  frame dialog-frame  loc-line-rcv.price-rubl loc-line-rcv.price-base .
 assign
    loc-line-rcv.sum-rubl = input frame dialog-frame loc-line-rcv.price-rubl  * input frame dialog-frame loc-line-rcv.qnty
    loc-line-rcv.sum-base = loc-line-rcv.price-base  * input frame dialog-frame loc-line-rcv.qnty
    loc-line-rcv.sum-cli  = loc-line-rcv.price-cli   * input frame dialog-frame loc-line-rcv.cli-qnty
    tot-rubl     = input frame dialog-frame loc-line-rcv.price-rubl * input frame dialog-frame loc-line-rcv.qnty
    tot-base     = loc-line-rcv.price-base * input frame dialog-frame loc-line-rcv.qnty
    tot-cli      = loc-line-rcv.price-cli  * input frame dialog-frame loc-line-rcv.cli-qnty
    .
end.
else do:
 assign
    loc-line-rcv.sum-rubl = loc-line-rcv.price-rubl  * input frame dialog-frame loc-line-rcv.qnty
    loc-line-rcv.sum-base = loc-line-rcv.price-base  * input frame dialog-frame loc-line-rcv.qnty
    loc-line-rcv.sum-cli  = input frame dialog-frame loc-line-rcv.price-cli   * input frame dialog-frame loc-line-rcv.cli-qnty
    tot-rubl     = loc-line-rcv.price-rubl * input frame dialog-frame loc-line-rcv.qnty
    tot-base     = loc-line-rcv.price-base * input frame dialog-frame loc-line-rcv.qnty
    tot-cli      = input frame dialog-frame loc-line-rcv.price-cli  * input frame dialog-frame loc-line-rcv.cli-qnty
    .
end.
  DISPLAY
    loc-line-rcv.price-rubl
    loc-line-rcv.price-base
    loc-line-rcv.price-cli
    tot-cli
    tot-rubl
    tot-base WITH FRAME dialog-frame.
  assign  frame dialog-frame
    loc-line-rcv.qnty
    loc-line-rcv.cli-qnty
    loc-line-rcv.price-base
    loc-line-rcv.price-rubl
    loc-line-rcv.price-cli
    loc-line-rcv.cli-base-rate
 .
  assign
 loc-line-rcv.price-base:screen-value = string(loc-line-rcv.price-base)
 loc-line-rcv.price-rubl:screen-value = string(loc-line-rcv.price-rubl)
 loc-line-rcv.price-cli:screen-value  = string(loc-line-rcv.price-cli )
  .
 run disp-total in this-procedure  no-error .
 if error-status :error then do:
    message error-status :error error-status :get-message(1) .
    return.
    end.
 enable
      loc-line-rcv.qnty when pardoc-qnty-input = true
      loc-line-rcv.cli-qnty when parcli-qnty-input = true
      loc-line-rcv.price-base     when parbase-price-input = true and     loc-doc-type = "out":u
      loc-line-rcv.price-rubl     when parbase-price-input = true and     loc-doc-type = "out":u
      loc-line-rcv.price-cli      when parprice-cli-input  = true and     loc-doc-type = "out":u
      loc-line-rcv.vat-pc         when parbase-price-input = true and     loc-doc-type = "out":u
      loc-line-rcv.slt-pc         when parbase-price-input = true and     loc-doc-type = "out":u
      loc-line-rcv.cli-base-rate  when parcli-base-rate-input = true
     with frame dialog-frame .
disable
      loc-line-rcv.qnty when pardoc-qnty-input = false
      loc-line-rcv.cli-qnty when parcli-qnty-input = false
      loc-line-rcv.price-base when parbase-price-input = false or          loc-doc-type = "in":u
      loc-line-rcv.price-rubl when parbase-price-input = false or          loc-doc-type = "in":u
      loc-line-rcv.vat-pc when parbase-price-input = false or          loc-doc-type = "in":u
      loc-line-rcv.slt-pc when parbase-price-input = false or          loc-doc-type = "in":u
      loc-line-rcv.price-cli  when parprice-cli-input  = false or          loc-doc-type = "in":u
      loc-line-rcv.cli-base-rate  when parcli-base-rate-input = false
     with frame dialog-frame .
      if loc-doc-type = 'ОФ':U  Then do:
      display
            loc-line-rcv.qnty
            loc-line-rcv.cli-qnty
            loc-line-rcv.cli-base-rate
            with frame dialog-frame .
            end.
      else do:
      display
            loc-line-rcv.qnty
            loc-line-rcv.cli-qnty
            loc-line-rcv.price-rubl
            loc-line-rcv.price-base
            loc-line-rcv.price-cli
            loc-line-rcv.cli-base-rate
            with frame dialog-frame .
      end.
      Hide tot-cli  tot-rubl tot-base in FRAME dialog-frame.
 end.
end procedure.
PROCEDURE apply-focus-next-entry :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  define input parameter p-widget-handle as handle no-undo .
  do with frame dialog-frame :
  end.
end.
END PROCEDURE.
procedure disp-total:
define variable varprice-cli-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-dt          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-dt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-dt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl-dt               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl-dt     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl-dt like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl-dt   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl-dt    like ub.doc-line.price-rubl no-undo.
define variable varprice-base-dt               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base-dt      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base-dt     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base-dt like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base-dt   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base-dt        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base-dt    like ub.doc-line.price-base no-undo.
if  loc-base-rate =  0  and
    loc-base-scale = 0  and
    loc-exch-rate  = 0  and
    loc-exch-scale = 0  then return.
if vat_type = "" or vat_type = ? then do:
assign
     vat_type   = 'в т. ч.':U
     slt_type   = 'без':U
.
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   'zakaz':u
  ,input   loc-base-rate
  ,input   loc-base-scale
  ,input   loc-exch-rate
  ,input   loc-exch-scale
  ,input   vat_type
  ,input   slt_type
  ,input   loc-line-rcv.artic
  ,input   loc-line-rcv.prod-type
  ,input   loc-line-rcv.prod-code
  ,input   loc-line-rcv.price-cli
  ,input   loc-line-rcv.cli-base-rate
  ,input   loc-line-rcv.price-rubl
  ,input   loc-line-rcv.vat-pc
  ,input   loc-line-rcv.slt-pc
  ,input   loc-line-rcv.road-tax
  ,input   loc-line-rcv.transport-rubl
  ,input   loc-line-rcv.other-rubl
  ,output  varprice-cli-dt
  ,output  varprice-cli-unit-base-dt
  ,output  varprice-road-tax-dt
  ,output  varprice-other-exp-dt
  ,output  varprice-transport-exp-dt
  ,output  varprice-without-abs-dt
  ,output  varprice-slt-dt
  ,output  varprice-no-slt-dt
  ,output  varprice-vat-dt
  ,output  varprice-no-vat-slt-dt
  ,output  varprice-rubl-dt
  ,output  varprice-road-tax-rubl-dt
  ,output  varprice-other-exp-rubl-dt
  ,output  varprice-transport-exp-rubl-dt
  ,output  varprice-without-abs-rubl-dt
  ,output  varprice-slt-rubl-dt
  ,output  varprice-no-slt-rubl-dt
  ,output  varprice-vat-rubl-dt
  ,output  varprice-no-vat-slt-rubl-dt
  ,output  varprice-base-dt
  ,output  varprice-road-tax-base-dt
  ,output  varprice-other-exp-base-dt
  ,output  varprice-transport-exp-base-dt
  ,output  varprice-without-abs-base-dt
  ,output  varprice-slt-base-dt
  ,output  varprice-no-slt-base-dt
  ,output  varprice-vat-base-dt
  ,output  varprice-no-vat-slt-base-dt
  ) no-error.
    if error-status:error then do:
      return error "Ошибка при пересчете линии ПОСТАВКИ".
    end.
  assign
    loc-line-rcv.sum-vat    = varprice-vat-dt  * input frame dialog-frame loc-line-rcv.cli-qnty
    loc-line-rcv.sum-slt    = varprice-slt-dt
    loc-line-rcv.road-tax   = if var-report-r-b = "rubl" then   varprice-road-tax-rubl-dt else varprice-road-tax-base-dt
    loc-line-rcv.other-base = varprice-other-exp-base-dt
    loc-line-rcv.other-rubl = varprice-other-exp-rubl-dt
    loc-line-rcv.price-rubl = varprice-rubl-dt
    loc-line-rcv.price-base = varprice-base-dt
    loc-line-rcv.price-cli  = varprice-cli-dt
     .
end procedure.
on F2 of frame dialog-frame anywhere do:
return no-apply.
end.
ON LEAVE OF loc-line-rcv.cli-base-rate IN FRAME dialog-frame  do:
   apply 'LEAVE' to loc-line-rcv.cli-qnty in frame dialog-frame .
end.
ON CHOOSE OF b-chg-2 IN FRAME FRAME-B
DO:
DEF VAR L-RECID AS RECID NO-UNDO.
find current post-ord-line-rcv no-error.
    if avail post-ord-line-rcv then do:
    L-RECID = RECID(post-ord-line-rcv) .
   run cus/or-obj.w
   (  parParentProc
    , p-host-code
    , recid(post-ord-line-rcv)
    , 2
    , 'ИЗМЕНЕНИЕ':U
    , 'ИЗМЕНЕНИЕ':U
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
    g#log =  BROWSE-32:refresh() .
    end.
END.
ON CHOOSE OF B-create-trn IN FRAME Dialog-Frame
DO:
 define variable g-log as logical   no-undo .
 define variable v-obj-db-num as integer   no-undo .
 define buffer b_ord-doc-rcv for  ub.ord-doc-rcv .
 define buffer buf_ord-doc   for  ub.ord-doc     .
 define buffer buf_doc-line  for  ub.doc-line    .
 define variable v-ord-type as character no-undo .
 define variable v-empty-trn as logical   no-undo .
 define variable v-current-trn as character no-undo .
 define variable varchip-code  as integer   no-undo .
 find first b_ord-doc-rcv no-lock  where b_ord-doc-rcv.rcv-code = loc-doc-rcv.rcv-code  no-error .
 if not available b_ord-doc-rcv then return .
 find first buf_ord-doc no-lock where buf_ord-doc.doc-code   = b_ord-doc-rcv.doc-code no-error .
 if available buf_ord-doc then  v-ord-type = buf_ord-doc.doc-type .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  b_ord-doc-rcv.obj-type
  ,input  b_ord-doc-rcv.obj-code
  ,output v-obj-db-num
  )  .
      if v-cntxt-db-num <> v-obj-db-num then do:
        message "Создание накладных по заказу ОП возможно на БД №" v-obj-db-num view-as alert-box information .
        return .
      end.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_h-wbill':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
     if avail b_ord-doc-rcv then do:
        if b_ord-doc-rcv.status_ <> 'поставка':U then do:
          message "Нельзя сделать накладную на поставку в статусе " caps(b_ord-doc-rcv.status_) view-as alert-box .
          return no-apply.
        end.
        define variable v-is-limit as logical   no-undo .
        run ver-qnty-trn-from-rcv ( input b_ord-doc-rcv.rcv-code , output v-is-limit ) .
        if v-is-limit then do:
            message "Нельзя делать Накладную на Поставку. Система настроена на работу 1:1."
                    view-as alert-box information .
            return no-apply.
        end.
        if b_ord-doc-rcv.doc-type = "in":U and
          ( b_ord-doc-rcv.obj-code = store-code and
            b_ord-doc-rcv.obj-type = store-type )
            then do:
                message "Нельзя сделать накладную на поставку " caps(b_ord-doc-rcv.rcv-code) skip
                "Здесь может быть только внутренний приход"
                view-as alert-box .
                return no-apply.
            end.
        run cus/ord-trn.p ( parParentProc ,  recid(b_ord-doc-rcv) , yes ) no-error .
        assign
          v-current-trn = string(current-value (s-trn-doc, ub)) + "-" +
          (if v-cntxt-db-num-obj = 0 then "" else (string(v-cntxt-obj-code) + substring(v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1))) .
          v-empty-trn   = yes.
        .
        find first buf_trn-doc
             where buf_trn-doc.doc-code = v-current-trn
             no-error .
        if available buf_trn-doc then do:
          for each buf_doc-line
             where buf_doc-line.doc-code = buf_trn-doc.doc-code
             no-lock :
                assign v-empty-trn = no .
             end.
           if v-empty-trn then do:
              message "Созданная накладная не содержит линий и будет удалена!"
              view-as alert-box information title "Внимание!" .
              run str/del-doc.p
                ( input  parParentProc,
                  input  buf_trn-doc.doc-code,
                  input  v-cntxt-db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  v-cntxt-userid,
                  input  buf_trn-doc.doc-code,
                  input  ?,
                  output varchip-code ) .
           end.
        end.
        OPEN QUERY BROWSE-37 FOR EACH buf_ord-chain NO-LOCK where                                  buf_ord-chain.doc-code = loc-doc-rcv.rcv-code and                                  buf_ord-chain.doc-type = 'rcv'                  and                                  buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION.
     end.
END.
ON CHOOSE OF b-del IN FRAME FRAME-A
DO:
 if avail post-ord-line-rcv then do:
                message "Удалить строку в поставке №" post-ord-line-rcv.rcv-code
                skip
                " По товару "
                post-ord-line-rcv.artic
                post-ord-line-rcv.prod-type
                post-ord-line-rcv.prod-code
                view-as alert-box
                        question buttons yes-no title "Вопрос" update g#log.
                    if g#log then do:
                            find current post-ord-line-rcv exclusive-lock .
                             delete post-ord-line-rcv .
                            OPEN QUERY BROWSE-30  FOR EACH post-ord-line-rcv       where post-ord-line-rcv.rcv-code = loc-doc-rcv.rcv-code and             post-ord-line-rcv.doc-code = loc-doc-rcv.doc-code no-lock,         each post-goods where                post-goods.artic  =  post-ord-line-rcv.artic  and                 post-goods.prod-code  =  post-ord-line-rcv.prod-code  and                 post-goods.prod-type  =  post-ord-line-rcv.prod-type   no-lock              by post-ord-line-rcv.line-num .
                     end.
  end.
END.
ON CHOOSE OF b-del-2 IN FRAME FRAME-B
DO:
 if avail post-ord-line-rcv then do:
                message "Удалить строку в поставке №" post-ord-line-rcv.rcv-code
                skip
                " По товару "
                post-ord-line-rcv.artic
                post-ord-line-rcv.prod-type
                post-ord-line-rcv.prod-code
                view-as alert-box
                        question buttons yes-no title "Вопрос" update g#log.
                    if g#log then do:
                            find current post-ord-line-rcv exclusive-lock.
                             delete post-ord-line-rcv .
                            OPEN QUERY BROWSE-30  FOR EACH post-ord-line-rcv       where post-ord-line-rcv.rcv-code = loc-doc-rcv.rcv-code and             post-ord-line-rcv.doc-code = loc-doc-rcv.doc-code no-lock,         each post-goods where                post-goods.artic  =  post-ord-line-rcv.artic  and                 post-goods.prod-code  =  post-ord-line-rcv.prod-code  and                 post-goods.prod-type  =  post-ord-line-rcv.prod-type   no-lock              by post-ord-line-rcv.line-num .
                     end.
  end.
END.
ON CHOOSE OF B-delivery IN FRAME Dialog-Frame
DO:
define buffer buf_ord-doc for ub.ord-doc  .
define variable type-mode as character no-undo .
if loc-doc-rcv.doc-type = "in" then type-mode = "rcv" + 'ОО':U .
else do:
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = loc-doc-rcv.doc-code no-error .
    if not available buf_ord-doc  then do:
       type-mode = "ord" + 'ОО':U .
    end.
    else do:
      type-mode = "ord" + buf_ord-doc.doc-type .
      if buf_ord-doc.doc-type = 'ФП':U then do:
         type-mode = "rcv" + buf_ord-doc.doc-type .
      end.
    end.
end.
    run cus/pardeliv.w
      (input        parParentproc
      ,input        doc-mode
      ,input        type-mode
      ,input        loc-doc-rcv.obj-type
      ,input        loc-doc-rcv.obj-code
      ,input        loc-doc-rcv.cli-type
      ,input        loc-doc-rcv.cli-code
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
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
 doc-mode = "cancel":U.
 x-make-avto = 2 .
END.
ON CHOOSE OF b-export-2 IN FRAME FRAME-A
DO:
   run cus/z-tot3.p ( parParentProc , input ub.ord-doc-rcv.rcv-code , input ub.ord-doc-rcv.doc-code ) .
end.
ON CHOOSE OF b-lkp IN FRAME FRAME-A
DO:
  find current post-ord-line-rcv no-error.
  if avail post-ord-line-rcv then do:
    run cus/or-obj.w
    ( parParentProc
    , p-host-code
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
ON CHOOSE OF b-lkp-2 IN FRAME FRAME-B
DO:
  find current post-ord-line-rcv no-error.
  if avail post-ord-line-rcv then do:
    run cus/or-obj.w
    ( parParentProc
    , p-host-code
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
ON CHOOSE OF B-OK IN FRAME Dialog-Frame
DO:
define variable  l-ok as logical no-undo .
  x-make-avto = 2 .
  if type-pr <> ? then do:
     case  type-pr:screen-value :
     when "1" then x-make-avto = 1 .
     when "4" then x-make-avto = 4 .
     when "2" then x-make-avto = 2  .
     when "3" then x-make-avto = 3 .
     end case.
  end .
  if loc-doc-rcv.obj-code = loc-doc-rcv.cli-code and
     loc-doc-rcv.obj-type = loc-doc-rcv.cli-type
     then do:
       message "Поставщик и Контрагент должны быть разные ! " view-as alert-box error .
       return no-apply.
     end.
if p-mode = 1 then do:
  assign frame  Dialog-Frame loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale.
      BUFFER-COPY loc-doc-rcv to ub.ord-doc-rcv.
      ub.ord-doc-rcv.ship-time = ( l-loc-hour * 60 * 60 )  + ( l-loc-min * 60 ) .
      ub.ord-doc-rcv.fact-ship-time = ( l-loc-hour-2 * 60 * 60 )  + ( l-loc-min-2 * 60 ) .
      ub.ord-doc-rcv.sub-par        = trim(loc-cli-out-code) + chr(4) + trim(vat_type) + chr(4) .
end.
if p-mode = 2 then  do:
    run ver-value in this-procedure no-error .
    if error-status :error then return no-apply.
    assign frame  Dialog-Frame loc-cli-out-code loc-line-rcv.price-cli loc-line-rcv.cli-qnty loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name.
    buffer-copy loc-line-rcv to ub.ord-line-rcv.
end.
if p-mode = 3 then do:
  assign frame  Dialog-Frame loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale.
      BUFFER-COPY loc-doc-rcv to ub.ord-doc-rcv.
      ub.ord-doc-rcv.ship-time = ( l-loc-hour * 60 * 60 )  + ( l-loc-min * 60 ) .
      ub.ord-doc-rcv.fact-ship-time = ( l-loc-hour-2 * 60 * 60 )  + ( l-loc-min-2 * 60 ) .
      ub.ord-doc-rcv.sub-par          = trim(loc-cli-out-code) + chr(4) + trim(vat_type) + chr(4)  .
      if can-find (first post-ord-line-rcv where
          post-ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
          post-ord-line-rcv.qnty = 0) then do:
          l-ok = false .
          message "Есть нулевые строки в поставке! Удалять их ?" view-as alert-box question buttons yes-no update
          l-ok  .
          if l-ok = true  then do:
             for each post-ord-line-rcv exclusive-lock where
                      post-ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
                      post-ord-line-rcv.qnty = 0 :
             delete post-ord-line-rcv.
             end.
          end.
          end.
      if not can-find (first post-ord-line-rcv where
          post-ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code ) then do:
          find current ub.ord-doc-rcv  exclusive-lock   no-error .
          if available ub.ord-doc-rcv then do:
             message "Нeт ни одной записи в поставке! Удаляем ее" view-as alert-box information .
             delete ub.ord-doc-rcv.
             end.
          end.
end.
if available ub.ord-doc-rcv then do:
ASSIGN
    ub.ord-doc-rcv.deliv-type-code    = v-deliv-type-code
    ub.ord-doc-rcv.obj-point-code     = v-point-obj-code
    ub.ord-doc-rcv.cli-point-code     = v-point-cli-code
    ub.ord-doc-rcv.obj-point-db-num   = v-point-obj-db-num
    ub.ord-doc-rcv.cli-point-db-num   = v-point-cli-db-num
    ub.ord-doc-rcv.transport-host-code= v-transport-host-code
    ub.ord-doc-rcv.transport-cli-type = v-transport-cli-type
    ub.ord-doc-rcv.transport-cli-code = v-transport-cli-code
    ub.ord-doc-rcv.transport-contract = v-transport-contract
    ub.ord-doc-rcv.transport-condition= v-transport-condition
    ub.ord-doc-rcv.transport-value    = v-transport-value
    ub.ord-doc-rcv.sum-ship           = v-transport-sum
    ub.ord-doc-rcv.transport-vat      = v-transport-vat
  .
end.
END.
ON CHOOSE OF b-scl IN FRAME FRAME-A
OR CHOOSE OF B-SCL-2 IN FRAME FRAME-B
DO:
  message "Режим недоступен" view-as alert-box information .
  return .
END.
ON CHOOSE OF B-stop IN FRAME Dialog-Frame
DO:
doc-mode = "stopcycle":U.
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
ON CHOOSE OF B-trn-2 IN FRAME Dialog-Frame
DO:
if not available buf_ord-chain then return .
find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code no-error .
      if available   buf_trn-doc   then DO:
            case buf_trn-doc.doc-type
            :
              when 'при':U
              then do:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
              end.
              when 'рас':U
              then do:
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
              end.
              when 'спи':U
              then do:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
              end.
              when 'инв':U
              then do:
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
              end.
              when 'возврат':U
              then do:
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return no-apply .
              end.
            end case .
            if not g#log then   return no-apply.
            run look-trn-all in this-procedure no-error.
      end.
END.
ON CHOOSE OF B-trn-3 IN FRAME Dialog-Frame
DO:
define buffer b_ord-doc-rcv for  ub.ord-doc-rcv .
define buffer buf_ord-doc   for  ub.ord-doc     .
define variable v-ord-type as character no-undo .
define variable v-obj-db-num as integer   no-undo .
 find first b_ord-doc-rcv no-lock  where b_ord-doc-rcv.rcv-code = loc-doc-rcv.rcv-code  no-error .
 if not available b_ord-doc-rcv then return .
 find first buf_ord-doc no-lock where buf_ord-doc.doc-code   = b_ord-doc-rcv.doc-code no-error .
 if available buf_ord-doc then  v-ord-type = buf_ord-doc.doc-type .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  b_ord-doc-rcv.obj-type
  ,input  b_ord-doc-rcv.obj-code
  ,output v-obj-db-num
  )  .
      if v-cntxt-db-num <> v-obj-db-num then do:
        message "Привязка накладных к заказу возможно на БД №" v-obj-db-num view-as alert-box information .
        return .
      end.
      define variable  v-is-limit as logical   no-undo .
      run ver-qnty-trn-from-rcv ( input b_ord-doc-rcv.rcv-code , output v-is-limit ) .
      if v-is-limit then do:
          message "Нельзя делать Накладную на Поставку. Система настроена на работу 1:1."
                  view-as alert-box information .
          return .
      end.
  run att-trn in this-procedure (recid(b_ord-doc-rcv)) no-error .
OPEN QUERY BROWSE-37 FOR EACH buf_ord-chain NO-LOCK where                                  buf_ord-chain.doc-code = loc-doc-rcv.rcv-code and                                  buf_ord-chain.doc-type = 'rcv'                  and                                  buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION.
END.
ON CHOOSE OF B-trn-4 IN FRAME Dialog-Frame
DO:
if not available buf_ord-chain then return .
define buffer b_ord-doc-rcv for  ub.ord-doc-rcv .
define buffer buf_ord-doc   for  ub.ord-doc     .
define variable v-ord-type as character no-undo .
define variable v-obj-db-num as integer   no-undo .
 find first b_ord-doc-rcv no-lock  where b_ord-doc-rcv.rcv-code = loc-doc-rcv.rcv-code  no-error .
 if not available b_ord-doc-rcv then return .
 find first buf_ord-doc no-lock where buf_ord-doc.doc-code   = b_ord-doc-rcv.doc-code no-error .
 if available buf_ord-doc then  v-ord-type = buf_ord-doc.doc-type .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  b_ord-doc-rcv.obj-type
  ,input  b_ord-doc-rcv.obj-code
  ,output v-obj-db-num
  )  .
      if v-cntxt-db-num <> v-obj-db-num then do:
        message "Удаление Привязки накладных к заказу ОП возможно да БД №" v-obj-db-num view-as alert-box information .
        return .
      end.
 if buf_ord-chain.rel-doc-type = 'trn' then do:
   find first buf_trn-doc no-lock where buf_trn-doc.doc-code   = buf_ord-chain.rel-doc-code no-error .
   if available buf_trn-doc and  buf_trn-doc.status_ = 'факт':U then do:
      message 'Накладная' buf_trn-doc.doc-code 'уже закрыта на ФАКТ ! Если удалите сейчас привязку, эту накладную уже нельзя будет привязать к поставке' skip
      'Удаляем привязку ?'
      view-as alert-box question
      buttons yes-no
      update v-ok as log
      .
      if v-ok = false then return .
   end.
 end.
  find current buf_ord-chain exclusive-lock .
  delete buf_ord-chain .
  OPEN QUERY BROWSE-37 FOR EACH buf_ord-chain NO-LOCK where                                  buf_ord-chain.doc-code = loc-doc-rcv.rcv-code and                                  buf_ord-chain.doc-type = 'rcv'                  and                                  buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION.
END.
on leave of post-ord-line-rcv.cli-qnty in browse BROWSE-30 do:
  if decimal( post-ord-line-rcv.cli-qnty :screen-value in browse BROWSE-30 ) <> post-ord-line-rcv.cli-qnty then do:
     assign post-ord-line-rcv.cli-qnty.
     post-ord-line-rcv.qnty     = post-ord-line-rcv.cli-qnty  * post-ord-line-rcv.cli-base-rate .
     post-ord-line-rcv.sum-base = post-ord-line-rcv.qnty      * post-ord-line-rcv.price-base .
     post-ord-line-rcv.sum-cli  = post-ord-line-rcv.cli-qnty  * post-ord-line-rcv.price-cli  .
     post-ord-line-rcv.sum-rubl = post-ord-line-rcv.qnty      * post-ord-line-rcv.price-rubl .
   display post-ord-line-rcv.cli-qnty
           post-ord-line-rcv.qnty
   with browse BROWSE-30.
   apply "LEAVE" to BROWSE-30 IN FRAME FRAME-A .
   end.
END.
ON ROW-LEAVE OF BROWSE-32 IN FRAME FRAME-B
DO:
  message 1.
END.
ON CURSOR-DOWN OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour .
  l-loc-hour = l-loc-hour -  1.
  if l-loc-hour < 0 then return no-apply.
  display l-loc-hour with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour .
  l-loc-hour = l-loc-hour +  1.
  if l-loc-hour > 24 then return no-apply.
  display l-loc-hour with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-hour IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame l-loc-hour .
   if l-loc-hour > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if l-loc-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-hour-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour-2 .
  l-loc-hour-2 = l-loc-hour-2 -  1.
  if l-loc-hour-2 < 0 then return no-apply.
  display l-loc-hour-2 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-hour-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour-2 .
  l-loc-hour-2 = l-loc-hour-2 +  1.
  if l-loc-hour-2 > 24 then return no-apply.
  display l-loc-hour-2 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-hour-2 IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame l-loc-hour-2 .
   if l-loc-hour-2 > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if l-loc-hour-2 < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-min IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-min .
  l-loc-min = l-loc-min -  1.
  if l-loc-min < 0 then return no-apply.
  display l-loc-min with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-min .
  l-loc-min = l-loc-min +  1.
  if l-loc-min > 59 then return no-apply.
  display l-loc-min with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-min .
   if l-loc-min > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-min-2 .
  l-loc-min-2 = l-loc-min-2 -  1.
  if l-loc-min-2 < 0 then return no-apply.
  display l-loc-min-2 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-min-2 .
  l-loc-min-2 = l-loc-min-2 +  1.
  if l-loc-min-2 > 59 then return no-apply.
  display l-loc-min-2 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-min-2 .
   if l-loc-min-2 > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
ON CHOOSE OF MENU-ITEM m_mobilscn
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/z-tot2.p (input parparentproc , input "rcv" , input "" ,input  ub.ord-doc-rcv.rcv-code ) .
END.
ON CHOOSE OF MENU-ITEM m___Excel
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/z-tot3.p ( input parParentProc , input ub.ord-doc-rcv.rcv-code , input ub.ord-doc-rcv.doc-code ) .
END.
ON LEAVE OF loc-doc-rcv.obj-code IN FRAME Dialog-Frame
DO:
  assign loc-doc-rcv.obj-code loc-doc-rcv.obj-type .
  if loc-doc-rcv.obj-code = loc-doc-rcv.cli-code and
     loc-doc-rcv.obj-type = loc-doc-rcv.cli-type
     then do:
     message "Поставщик и Контрагент должны быть разные ! " view-as alert-box error .
     return no-apply.
     end.
    find first obj-clients  no-lock where
               obj-clients.obj-code = loc-doc-rcv.obj-code and
               obj-clients.obj-type = loc-doc-rcv.obj-type
               no-error.
              obj_obj-name = obj-clients.obj-name.
              if avail obj-clients then  display obj_obj-name with frame Dialog-Frame.
END.
ON LEAVE OF loc-doc-rcv.obj-type IN FRAME Dialog-Frame
DO:
 apply "LEAVE":U to loc-doc-rcv.obj-code.
END.
ON CHOOSE OF r-clients IN FRAME Dialog-Frame
DO:
  run r-clients-ch in this-procedure  no-error .
END.
ON CHOOSE OF r-curr IN FRAME Dialog-Frame
DO:
  run r-cur in this-procedure no-error .
END.
ON CHOOSE OF r-obj IN FRAME Dialog-Frame
DO:
  run r-clients-ob in this-procedure no-error .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of loc-doc-rcv.ship-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of loc-doc-rcv.ship-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of loc-doc-rcv.ship-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of loc-doc-rcv.ship-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of loc-doc-rcv.ship-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of loc-doc-rcv.ship-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date31
    MENU-ITEM m-ed-date31-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date31-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date31-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date31-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if loc-doc-rcv.ship-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      loc-doc-rcv.ship-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date31 :HANDLE
      loc-doc-rcv.ship-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle31 as handle no-undo .
  assign
    v-label-handle31 = loc-doc-rcv.ship-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle31)
  then do:
    if v-label-handle31 :tooltip = ""
    or v-label-handle31 :tooltip = ?
    then do:
      assign
        v-label-handle31 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date31-1 in menu m-ed-date31 DO:
    apply "ctrl-b":U to loc-doc-rcv.ship-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date31-2 in menu m-ed-date31 DO:
    apply "ctrl-d":U to loc-doc-rcv.ship-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date31-3 in menu m-ed-date31 DO:
    apply "ctrl-e":U to loc-doc-rcv.ship-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date31-4 in menu m-ed-date31 DO:
    apply "ctrl-f":U to loc-doc-rcv.ship-date in frame Dialog-Frame .
  END.
def var sort-labelBROWSE-30   as character no-undo .
def var sort-clmnBROWSE-30    as handle    no-undo .
def var cur-clmnBROWSE-30     as handle    no-undo .
def var cur-clmn-locBROWSE-30 as integer   no-undo .
def var re-queryBROWSE-30     as logical   initial no no-undo .
on start-search, ctrl-o of BROWSE-30 in frame frame-A do:
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
       cur-clmnBROWSE-30 = BROWSE-30:current-column in frame frame-A
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
        when post-ord-line-rcv.artic:label in browse BROWSE-30 then DO:   assign     sort-column-name = "post-ord-line-rcv.artic"   .   run openbr.   . END.
        when Post-goods.gds-name:label in browse BROWSE-30 then DO:   assign     sort-column-name = "Post-goods.gds-name"   .   run openbr.   . END.
        when Post-goods.unit-base:label in browse BROWSE-30 then DO:   assign     sort-column-name = "Post-goods.unit-base"   .   run openbr.   . END.
        when post-ord-line-rcv.qnty:label in browse BROWSE-30 then DO:   assign     sort-column-name = "post-ord-line-rcv.qnty"   .   run openbr.   . END.
        when post-ord-line-rcv.unit-cli:label in browse BROWSE-30 then DO:   assign     sort-column-name = "post-ord-line-rcv.unit-cli"   .   run openbr.   . END.
        when post-ord-line-rcv.cli-qnty:label in browse BROWSE-30 then DO:   assign     sort-column-name = "post-ord-line-rcv.cli-qnty"   .   run openbr.   . END.
        when post-ord-line-rcv.price-rubl:label in browse BROWSE-30 then DO:   assign     sort-column-name = "post-ord-line-rcv.price-rubl"   .   run openbr.   . END.
        when post-ord-line-rcv.price-base:label in browse BROWSE-30 then DO:   assign     sort-column-name = "post-ord-line-rcv.price-base"   .   run openbr.   . END.
        when post-ord-line-rcv.price-cli:label in browse BROWSE-30 then DO:   assign     sort-column-name = "post-ord-line-rcv.price-cli"   .   run openbr.   . END.
        when post-ord-line-rcv.line-num:label in browse BROWSE-30 then DO:   assign     sort-column-name = "post-ord-line-rcv.line-num"   .   run openbr.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run openbr.
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
    apply "value-changed" to BROWSE-30 in frame frame-A.
  end.
  apply "entry" to BROWSE-30 in frame frame-A.
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
  b-export-2:POPUP-MENU IN FRAME Frame-A       = MENU m-export:HANDLE
  b-export-2:MENU-MOUSE = 1.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if p-mode = 1 or p-mode = 3  then do:
       find first ub.ord-doc-rcv  exclusive-lock   where recid(ub.ord-doc-rcv) = p-ord-rec  .
    end.
    if p-mode = 2 then do:
      find first ub.ord-line-rcv no-lock        where recid(ub.ord-line-rcv)  = p-ord-rec  no-error .
      find first ub.ord-doc-rcv  exclusive-lock where ub.ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code no-error .
      find first b-ord-line   no-lock        where recid(b-ord-line)    = p-ord-rec no-error .
    end.
 ASSIGN
  v-deliv-type-code     =  ub.ord-doc-rcv.deliv-type-code
  v-point-obj-code      =  ub.ord-doc-rcv.obj-point-code
  v-point-cli-code      =  ub.ord-doc-rcv.cli-point-code
  v-point-obj-db-num    =  ub.ord-doc-rcv.obj-point-db-num
  v-point-cli-db-num    =  ub.ord-doc-rcv.cli-point-db-num
  v-transport-host-code      =  ub.ord-doc-rcv.transport-host-code
  v-transport-cli-code  =  ub.ord-doc-rcv.transport-cli-code
  v-transport-cli-type  =  ub.ord-doc-rcv.transport-cli-type
  v-transport-contract  =  ub.ord-doc-rcv.transport-contract
  v-transport-condition =  ub.ord-doc-rcv.transport-condition
  v-transport-value     =  ub.ord-doc-rcv.transport-value
  v-transport-sum       =  ub.ord-doc-rcv.sum-ship
  v-transport-vat       =  ub.ord-doc-rcv.transport-vat
  loc-cli-out-code      =  entry(1,ord-doc-rcv.sub-par,chr(4))
  .
  vat_type = entry(2,ord-doc-rcv.sub-par,chr(4)) no-error
  .
  Post-goods.gds-name:resizable in browse browse-30 = true .
  Post-goods.gds-name:resizable in browse browse-32 = true .
  post-ord-line-rcv.artic:resizable in browse browse-30 = true .
  post-ord-line-rcv.artic:resizable in browse browse-32 = true .
  run enable_UI in this-procedure no-error .
  run input-p in this-procedure no-error .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if BROWSE-30:MOVE-COLUMN(source-column, target-column) IN FRAME frame-A then.
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
hide b-trn-2 in frame dialog-frame.
if p-mode = 1   then do:
 run create-ch-box in this-procedure .
 WAIT-FOR GO OF FRAME dialog-frame focus  loc-doc-rcv.cli-code .
end.
if p-mode = 3  then do:
  OPEN QUERY BROWSE-37 FOR EACH buf_ord-chain NO-LOCK where                                  buf_ord-chain.doc-code = loc-doc-rcv.rcv-code and                                  buf_ord-chain.doc-type = 'rcv'                  and                                  buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION.
  WAIT-FOR GO OF FRAME  dialog-frame  .
end.
if p-mode = 2 then do:
hide b-trn b-trn-3 B-trn-4 b-trn-2 b-create-trn in frame dialog-frame.
 if loc-line-rcv.cli-qnty:sensitive in frame dialog-frame then
     WAIT-FOR GO OF FRAME dialog-FRAME focus  loc-line-rcv.cli-qnty .
  else
     WAIT-FOR GO OF FRAME dialog-FRAME focus  loc-line-rcv.qnty .
end.
END.
run disable_UI  in this-procedure no-error .
PROCEDURE att-trn :
do
 on error undo, return error return-value
 :
define input parameter b-recid as recid no-undo .
define variable loc-ref-list as character no-undo .
define variable v-input-output as character no-undo .
define variable p-trn-code as character no-undo .
define buffer bub_ord-doc-rcv      for ub.ord-doc-rcv .
define buffer buf_ord-doc          for ub.ord-doc .
define buffer loc_buf_ord-line-rcv for ub.ord-line-rcv .
define buffer loc_buf_doc-line     for ub.doc-line .
define variable v-type-ord as character no-undo init "".
find first bub_ord-doc-rcv no-lock  where recid( bub_ord-doc-rcv)  = b-recid no-error .
if not avail bub_ord-doc-rcv then do:
  message  "Не выбрана поставка !!! " view-as alert-box .
  return .
end.
if bub_ord-doc-rcv.status_ <> 'поставка':U then do:
  message "Нельзя сделать накладную на поставку в статусе " caps(bub_ord-doc-rcv.status_) view-as alert-box .
  return.
end.
find first buf_ord-doc no-lock where buf_ord-doc.doc-code = bub_ord-doc-rcv.doc-code no-error .
if available buf_ord-doc then v-type-ord = buf_ord-doc.doc-type .
doc-rec = ?  .
if v-type-ord = 'ОП':U or v-type-ord = 'ФП':U then do:
    run str/all-docs.w
   ( input  parparentproc
    ,input   bub_ord-doc-rcv.host-code
    ,input   bub_ord-doc-rcv.obj-type
    ,input   bub_ord-doc-rcv.obj-code
    ,input  'status-all-hold'
    ,input  ?
    ,input  'при':U
    ,input  ?
    ,input  no
    ,input  "b-sel":U
    ,input  'ie':U
    ,input  ?
    ,input  ?
    ,output loc-ref-list
    ) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
    .
end.
else do:
    run str/all-docs.w
    ( input  parparentproc
    ,input   bub_ord-doc-rcv.host-code
    ,input   bub_ord-doc-rcv.obj-type
    ,input   bub_ord-doc-rcv.obj-code
    ,input   'объект':U
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  "b-sel":U
    ,input  ?
    ,input  ?
    ,input  ?
    ,output loc-ref-list
    ) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
    .
end.
if loc-ref-list = ? then return.
  find first   buf_trn-doc no-lock where recid(buf_trn-doc) = int(loc-ref-list) no-error .
  if available buf_trn-doc
     then
      assign
        p-trn-code    = buf_trn-doc.doc-code
      .
    else do:
      assign
        p-trn-code    = ?
      .
      return .
    end.
define variable  j-trn as integer no-undo .
define variable  j-rcv as integer no-undo .
 j-trn = 0.
 j-rcv = 0.
 for each loc_buf_ord-line-rcv no-lock where
          loc_buf_ord-line-rcv.doc-code =  bub_ord-doc-rcv.doc-code and
          loc_buf_ord-line-rcv.rcv-code =  bub_ord-doc-rcv.rcv-code
          :
    j-rcv = j-rcv + 1.
    if can-find (first loc_buf_doc-line where
                       loc_buf_doc-line.doc-code   = buf_trn-doc.doc-code and
                       loc_buf_ord-line-rcv.artic  = loc_buf_doc-line.artic and
                       loc_buf_ord-line-rcv.prod-type =  loc_buf_doc-line.prod-type and
                       loc_buf_ord-line-rcv.prod-code =  loc_buf_doc-line.prod-code no-lock  ) Then j-trn = j-trn + 1.
 end.
 if j-rcv > j-trn then do:
    message  "Совпадение списка товаров  в выбранной накладной " (J-trn / j-rcv ) * 100  " %  ! "
      skip "Делаем привязку ?"
      view-as alert-box  Question
      buttons yes-no update g#log .
      if not g#log  then return .
  end.
  if not ( bub_ord-doc-rcv.cli-code = buf_trn-doc.cli-code and
           bub_ord-doc-rcv.cli-type = buf_trn-doc.cli-type )
  then do:
    message  "Не совпадает Поставщик в Накладной и Поставке  ! "
      skip "Делаем привязку ?"
      view-as alert-box  Question
      buttons yes-no update g#log .
      if not g#log  then return .
  end.
  if not ( bub_ord-doc-rcv.obj-code = buf_trn-doc.obj-code and
           bub_ord-doc-rcv.obj-type = buf_trn-doc.obj-type )
  then do:
    message  "Не совпадает объект доставки  в Накладной и Поставке  ! "
      skip "Делаем привязку ?"
      view-as alert-box  Question
      buttons yes-no update g#log .
      if not g#log  then return .
  end.
  run create-chain in this-procedure (
      bub_ord-doc-rcv.rcv-code,
      'rcv'      ,
      p-trn-code ,
      'trn' ,
      ''    ,
      '' )  no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "create-chain"
        view-as alert-box error
      .
    if v-cntxt-db-num > 0 then do:
        find first buf_trn-doc no-lock where recid(buf_trn-doc) = int(loc-ref-list) no-error .
        for each  buf_ord-chain where
                  buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code and
                  buf_ord-chain.rel-doc-type = 'trn'
                  :
           run nws/cr-route.p ( input 'send-tbl':U, input 'ord-chain':U, input ( buffer buf_ord-chain:handle) , input "0" ) no-error.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE create-ch-box :
 do
 on error undo, return error return-value
 :
     define variable g-log as logical   no-undo .
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_h-wbill':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
   create RADIO-SET type-pr
   assign
    row    = 10.5
    column = 2
    RADIO-BUTTONS = "Формировать строки автоматически без подтверждения,1,Формировать строки автоматически c подтверждением,2,Импорт из файла мобильного сканера,3" +
( if g-log then ",Закрыть поставку и создать накладную,4" else "" )
    frame  = frame Dialog-Frame:handle
 .
if valid-handle(type-pr) = false then do:
    message "не могу создать radio-button !!!" skip
    view-as alert-box information .
    return error.
 end.
  type-pr:sensitive = yes  .
  type-pr:visible   = yes  .
  hide loc-cli-out-code loc-line-rcv.price-cli loc-line-rcv.cli-qnty loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name
 ub.goods.gds-name
 ub.goods.unit-base
  loc-line-rcv.artic
  loc-line-rcv.prod-type
  loc-line-rcv.prod-code
  in frame Dialog-Frame .
     frame Dialog-Frame:title  = "Формирование поставки по заказу" .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
  HIDE FRAME FRAME-A.
  HIDE FRAME FRAME-B.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH loc-doc-rcv ,              EACH loc-line-rcv where       loc-doc-rcv.rcv-code = loc-line-rcv.rcv-code and loc-doc-rcv.doc-code = loc-line-rcv.doc-code  OUTER-JOIN,              EACH post-clients WHERE       loc-doc-rcv.cli-code = post-clients.obj-code and loc-doc-rcv.cli-type = post-clients.obj-type  no-LOCK ,              EACH obj-clients WHERE        loc-doc-rcv.obj-code = obj-clients.obj-code and  loc-doc-rcv.obj-type = obj-clients.obj-type  no-LOCK,              each ub.goods where              loc-line-rcv.artic = ub.goods.artic and             loc-line-rcv.prod-code = ub.goods.prod-code and                       loc-line-rcv.prod-type  = ub.goods.prod-type no-lock.
  GET FIRST Dialog-Frame.
  DISPLAY loc-cli-out-code l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2
          loc-type-doc post_obj-name obj_obj-name abbr-base abbr-cli
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.goods THEN
    DISPLAY ub.goods.gds-name ub.goods.unit-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE loc-doc-rcv THEN
    DISPLAY loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code
          loc-doc-rcv.obj-type loc-doc-rcv.ship-date loc-doc-rcv.exch-code
          loc-doc-rcv.rcv-code loc-doc-rcv.doc-code loc-doc-rcv.base-rate
          loc-doc-rcv.base-scale loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale
      WITH FRAME Dialog-Frame.
  IF AVAILABLE loc-line-rcv THEN
    DISPLAY loc-line-rcv.price-cli loc-line-rcv.cli-qnty
          loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty
          loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc
          loc-line-rcv.artic loc-line-rcv.prod-type loc-line-rcv.prod-code
          loc-line-rcv.unit-cli
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-exit B-stop B-delivery B-Help RECT-1 RECT-3 loc-cli-out-code
         BROWSE-37 B-create-trn B-trn loc-doc-rcv.obj-code loc-doc-rcv.obj-type
         r-obj B-trn-3 loc-doc-rcv.ship-date l-loc-hour l-loc-min B-trn-2
         B-trn-4 r-curr loc-line-rcv.price-cli loc-line-rcv.cli-qnty
         loc-line-rcv.cli-base-rate loc-doc-rcv.rcv-code loc-type-doc
         loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base
         loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli
         loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale loc-line-rcv.artic
         loc-line-rcv.prod-type loc-line-rcv.prod-code ub.goods.gds-name
         loc-line-rcv.unit-cli ub.goods.unit-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-37 FOR EACH buf_ord-chain NO-LOCK where                                  buf_ord-chain.doc-code = loc-doc-rcv.rcv-code and                                  buf_ord-chain.doc-type = 'rcv'                  and                                  buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION.
  ENABLE b-chg b-lkp b-del b-scl b-export-2 BROWSE-30
      WITH FRAME FRAME-A.
  OPEN QUERY BROWSE-30  FOR EACH post-ord-line-rcv       where post-ord-line-rcv.rcv-code = loc-doc-rcv.rcv-code and             post-ord-line-rcv.doc-code = loc-doc-rcv.doc-code no-lock,         each post-goods where                post-goods.artic  =  post-ord-line-rcv.artic  and                 post-goods.prod-code  =  post-ord-line-rcv.prod-code  and                 post-goods.prod-type  =  post-ord-line-rcv.prod-type   no-lock              by post-ord-line-rcv.line-num .
  ENABLE b-chg-2 b-lkp-2 b-del-2 b-scl-2 BROWSE-32
      WITH FRAME FRAME-B.
  OPEN QUERY BROWSE-32 FOR EACH post-ord-line-rcv where loc-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and loc-doc-rcv.doc-code = post-ord-line-rcv.doc-code NO-LOCK,              EACH Post-goods where             Post-goods.artic  =  post-ord-line-rcv.artic  and             Post-goods.prod-code  =  post-ord-line-rcv.prod-code and             Post-goods.prod-type   =  post-ord-line-rcv.prod-type   NO-LOCK,              EACH ub.doc-line WHERE ub.doc-line.artic = post-ord-line-rcv.artic   AND ub.doc-line.prod-code = post-ord-line-rcv.prod-code   AND ub.doc-line.prod-type = post-ord-line-rcv.prod-type   AND ub.doc-line.doc-code = loc-doc-rcv.trn-code OUTER-JOIN NO-LOCK  .
END PROCEDURE.
PROCEDURE input-p :
do
 on error undo, return error return-value
 :
define buffer b_trn-doc for ub.trn-doc .
define variable s-doc-mode as character no-undo .
HIDE FRAME FRAME-B.
find first  loc-doc-rcv  exclusive-lock   .
find first post-clients no-lock where
           post-clients.obj-code = loc-doc-rcv.cli-code   and
           post-clients.obj-type = loc-doc-rcv.cli-type
           no-error .
           if error-status :error then return error return-value .
           post_obj-name = post-clients.obj-name.
find first obj-clients no-lock where
           loc-doc-rcv.obj-code = obj-clients.obj-code and
           loc-doc-rcv.obj-type = obj-clients.obj-type
           no-error .
           if error-status :error then return error return-value .
           obj_obj-name = obj-clients.obj-name.
find first ub.currency no-lock   where ub.currency.curr-code = loc-doc-rcv.EXCH-CODE no-error.
if available ub.currency then abbr-cli = ub.currency.curr-abbr .
define variable   p-exch-rate  as decimal   no-undo .
define variable   p-exch-scale as decimal   no-undo .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  base-code
  ,input  today
  ,output p-exch-rate
  ,output p-exch-scale
  ,output abbr-base
  )  .
s-doc-mode = line-mode .
display  abbr-base abbr-cli loc-doc-rcv.EXCH-CODE with frame Dialog-Frame .
loc-doc-type = loc-doc-rcv.doc-type.
if p-mode = 2 then do:
find first loc-line-rcv no-error .
find first ub.goods no-lock where
           ub.goods.artic      = loc-line-rcv.artic     and
           ub.goods.prod-code  = loc-line-rcv.prod-code and
           ub.goods.prod-type  = loc-line-rcv.prod-type
            no-error.
   if error-status :error then return error return-value .
   run ass-var  in this-procedure no-error .
end.
define buffer buf_ord-doc for ub.ord-doc  .
find first buf_ord-doc no-lock where
           buf_ord-doc.doc-code = loc-doc-rcv.doc-code no-error .
Assign
   loc-time       = string( loc-doc-rcv.ship-time ,"HH:MM")
   loc-time-2     = string( loc-doc-rcv.fact-ship-time ,"HH:MM")
   l-loc-hour     = integer (entry(1,loc-time,":"))
   l-loc-min      = integer (entry(2,loc-time,":"))
   l-loc-hour-2   = if integer (entry(1,loc-time-2,":")) = 0 then 10 else integer (entry(1,loc-time-2,":"))
   l-loc-min-2    = integer (entry(2,loc-time-2,":"))
   loc-type-doc    = IF (loc-doc-rcv.doc-type = "out":U) THEN ("внешн") ELSE ("внутр")
   loc-cli-out-code   = entry(1,loc-doc-rcv.sub-par,chr(4))
   vat_type           = entry(2,ub.ord-doc-rcv.sub-par,chr(4))
   loc-base-rate   = loc-doc-rcv.base-rate
   loc-base-scale  = loc-doc-rcv.base-scale
   loc-exch-code   = loc-doc-rcv.exch-code
   loc-exch-rate   = loc-doc-rcv.exch-rate
   loc-exch-scale  = loc-doc-rcv.exch-scale
   no-error .
if p-mode = 1  then do:
   if line-mode = 'ИЗМЕНЕНИЕ':U  then
      enable      loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale r-obj loc-doc-rcv.exch-code with frame  Dialog-Frame .
disable
    loc-doc-rcv.cli-code
    loc-doc-rcv.cli-type
    post_obj-name
    r-clients
    with frame  Dialog-Frame .
 if g#type = 'ОП':U then
 disable
    loc-doc-rcv.obj-type
    loc-doc-rcv.obj-code
    obj_obj-name
    r-obj
    with frame  Dialog-Frame .
  disable  loc-cli-out-code loc-line-rcv.price-cli loc-line-rcv.cli-qnty loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name with frame  Dialog-Frame .
  display  loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale  loc-doc-rcv.cli-code loc-doc-rcv.cli-type
    with frame  Dialog-Frame .
  hide frame frame-a  .
  hide b-stop in frame Dialog-Frame  .
  if doc-mode <> 'ДОБАВЛЕНИЕ':U then  hide b-exit in frame Dialog-Frame .
  if doc-mode = 'ДОБАВЛЕНИЕ':U  then  disable B-create-trn B-trn B-trn-3 B-trn-2 B-trn-4 l-loc-hour-2 l-loc-min-2  with frame Dialog-Frame .
  if loc-doc-rcv.doc-type = 'in':U then do:
    disable loc-doc-rcv.base-rate
            loc-doc-rcv.base-scale
            loc-doc-rcv.exch-code
            loc-doc-rcv.exch-rate
            loc-doc-rcv.exch-scale
            r-curr
            with frame Dialog-Frame .
  end.
end.
if p-mode = 2 then do:
 assign frame Dialog-Frame:title  = "Строка поставки " + loc-doc-rcv.rcv-code + " - " + line-mode  .
  hide frame frame-a  loc-cli-out-code .
  disable  loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale r-obj r-curr with frame  Dialog-Frame .
  if line-mode = 'ИЗМЕНЕНИЕ':U  then  do:
    enable   loc-cli-out-code loc-line-rcv.price-cli loc-line-rcv.cli-qnty loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name with frame  Dialog-Frame .
  end.
  display  loc-cli-out-code loc-line-rcv.price-cli loc-line-rcv.cli-qnty loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name l-loc-hour l-loc-min
           l-loc-hour-2 l-loc-min-2
           with frame  Dialog-Frame .
    if  line-mode = "ЦИКЛ":U then  do:
    end .
    else  hide b-stop in frame Dialog-Frame  .
  if  line-mode = 'ПРОСМОТР':U then  do  :
     disable  loc-cli-out-code loc-line-rcv.price-cli loc-line-rcv.cli-qnty loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale r-obj with frame  Dialog-Frame .
     disable   b-trn b-trn-3 b-trn-2 b-create-trn B-trn-4 with frame  Dialog-Frame .
     disable   b-chg  b-del  with frame  frame-a .
     disable   b-chg-2  b-del-2 with frame  frame-b .
     hide b-ok in frame Dialog-Frame.
     b-exit:label = "Вы&ход".
     b-exit:column = 1.
  end.
     loc-line-rcv.price-cli:label in frame Dialog-Frame = "Цена пост. (" + abbr-cli + ")" .
     loc-line-rcv.price-rubl:label in frame Dialog-Frame ="Цена (руб) " .
     loc-line-rcv.price-base:label in frame Dialog-Frame ="Цена (" + abbr-base + ")" .
  if  line-mode <> 'ПРОСМОТР':U then run ass-var  in this-procedure no-error .
end.
if p-mode = 3 then do:
  disable r-curr loc-doc-rcv.exch-code with frame  Dialog-Frame .
  assign frame Dialog-Frame:title  = "ПОСТАВКА " + loc-doc-rcv.rcv-code + " - " + line-mode  .
  if loc-doc-rcv.status_ <> 'новый':U  then dO:
     disable  b-chg    b-del   with frame  frame-a .
     disable  b-chg-2  b-del-2 with frame  frame-b .
end.
if doc-mode = 'ПРОСМОТР':U OR line-mode = 'ПРОСМОТР':U  then do:
     enable   b-trn b-trn-2 b-trn-3 with frame  Dialog-Frame .
     disable  loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale  r-obj with frame  Dialog-Frame .
     disable  b-chg  b-del  with frame  frame-a .
     disable  b-chg-2  b-del-2 with frame  frame-b .
     disable  b-create-trn with frame  Dialog-Frame .
     disable loc-cli-out-code loc-line-rcv.price-cli loc-line-rcv.cli-qnty loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name with frame  Dialog-Frame .
     display loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale B-create-trn B-trn B-trn-3 B-trn-2 B-trn-4 l-loc-hour-2 l-loc-min-2  loc-doc-rcv.cli-code loc-doc-rcv.cli-type with frame  Dialog-Frame .
      hide b-ok in frame Dialog-Frame
           b-stop in frame Dialog-Frame
           .
  assign
    post-ord-line-rcv.cli-qnty:read-only   in browse browse-30 = true
    post-ord-line-rcv.line-num:read-only   in browse browse-30 = true.
  if list-mode  = 'поставка':U   then do:
     view b-ok in frame Dialog-Frame.
     enable  l-loc-min-2  l-loc-hour-2 with frame  Dialog-Frame .
     enable b-trn b-trn-2 b-trn-3 B-trn-4 b-create-trn with frame  Dialog-Frame .
  end.
end.
else do:
  if line-mode = 'ИЗМЕНЕНИЕ':U  then
     enable  loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale  r-obj with frame  Dialog-Frame .
  if loc-doc-rcv.status_ = 'новый':U  then
     disable B-create-trn B-trn B-trn-3 B-trn-2 B-trn-4 l-loc-hour-2 l-loc-min-2  with frame Dialog-Frame .
  disable loc-cli-out-code loc-line-rcv.price-cli loc-line-rcv.cli-qnty loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name with frame  Dialog-Frame .
  display
     loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale
     loc-doc-rcv.cli-code
     loc-doc-rcv.cli-type
     r-clients
     with frame Dialog-Frame .
  enable r-clients with frame  Dialog-Frame .
  hide b-exit in frame Dialog-Frame
       b-stop in frame Dialog-Frame  .
end.
  if loc-doc-rcv.status_ <> 'новый':U  and
      s-doc-mode = 'ИЗМЕНЕНИЕ':U then do:
      enable B-create-trn B-trn B-trn-3 B-trn-2 B-trn-4 l-loc-hour-2 l-loc-min-2  with frame Dialog-Frame .
  end.
if p-mode = 3  then do:
disable
    loc-doc-rcv.cli-code
    loc-doc-rcv.cli-type
    post_obj-name
    r-clients
    with frame  Dialog-Frame .
 if g#type = 'ОП':U then
 disable
    loc-doc-rcv.obj-type
    loc-doc-rcv.obj-code
    obj_obj-name
    r-obj
    with frame  Dialog-Frame .
end.
  view frame frame-a  .
  display  BROWSE-30 with frame  frame-a.
  OPEN QUERY BROWSE-30  FOR EACH post-ord-line-rcv       where post-ord-line-rcv.rcv-code = loc-doc-rcv.rcv-code and             post-ord-line-rcv.doc-code = loc-doc-rcv.doc-code no-lock,         each post-goods where                post-goods.artic  =  post-ord-line-rcv.artic  and                 post-goods.prod-code  =  post-ord-line-rcv.prod-code  and                 post-goods.prod-type  =  post-ord-line-rcv.prod-type   no-lock              by post-ord-line-rcv.line-num .
  find first ub.goods no-lock where ub.goods.gds-code = Post-goods.gds-code no-error .
end.
end.
END PROCEDURE.
PROCEDURE look-trn-all :
do
 on error undo, return error return-value
 :
 if frame FRAME-a:visible then do:
 b-trn-2:LOAD-IMAGE-DOWN ("adeicon\save-d":U) in frame dialog-frame .
 b-trn-2:LOAD-IMAGE-UP ("adeicon\save-u":U) in frame dialog-frame .
 b-trn-2:LOAD-IMAGE-INSENSITIVE ("adeicon\save-i":U) in frame dialog-frame .
 b-trn-2:tooltip = "Свернуть данные накладной" .
 b-trn-2:LABEL = "Свернуть накл".
 DISPLAY b-trn-2 WITH frame dialog-frame .
 view frame frame-b  .
 hide frame frame-a  .
 display  browse-32 with frame  frame-b.
 OPEN QUERY BROWSE-32 FOR EACH post-ord-line-rcv where loc-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and loc-doc-rcv.doc-code = post-ord-line-rcv.doc-code NO-LOCK,              EACH Post-goods where             Post-goods.artic  =  post-ord-line-rcv.artic  and             Post-goods.prod-code  =  post-ord-line-rcv.prod-code and             Post-goods.prod-type   =  post-ord-line-rcv.prod-type   NO-LOCK,              EACH ub.doc-line WHERE ub.doc-line.artic = post-ord-line-rcv.artic   AND ub.doc-line.prod-code = post-ord-line-rcv.prod-code   AND ub.doc-line.prod-type = post-ord-line-rcv.prod-type   AND ub.doc-line.doc-code = loc-doc-rcv.trn-code OUTER-JOIN NO-LOCK  .
 end.
 else do:
  b-trn-2:LOAD-IMAGE-DOWN ("adeicon\open-d":U) in frame dialog-frame .
  b-trn-2:LOAD-IMAGE-UP ("adeicon\open-u":U) in frame dialog-frame .
  b-trn-2:LOAD-IMAGE-INSENSITIVE ("adeicon\open-i":U) in frame dialog-frame .
  b-trn-2:tooltip = "Развернуть с накладной" .
  b-trn-2:LABEL = "Показать накл".
 DISPLAY b-trn-2 WITH frame dialog-frame .
 view frame frame-a  .
 hide frame frame-b  .
 display  browse-30 with frame  frame-a.
 OPEN QUERY BROWSE-30  FOR EACH post-ord-line-rcv       where post-ord-line-rcv.rcv-code = loc-doc-rcv.rcv-code and             post-ord-line-rcv.doc-code = loc-doc-rcv.doc-code no-lock,         each post-goods where                post-goods.artic  =  post-ord-line-rcv.artic  and                 post-goods.prod-code  =  post-ord-line-rcv.prod-code  and                 post-goods.prod-type  =  post-ord-line-rcv.prod-type   no-lock              by post-ord-line-rcv.line-num .
end.
  find first ub.goods  no-lock where ub.goods.gds-code = Post-goods.gds-code no-error .
end.
END PROCEDURE.
PROCEDURE openbr :
 do
 on error undo, return error return-value
 :
OPEN QUERY BROWSE-30  FOR EACH post-ord-line-rcv       where post-ord-line-rcv.rcv-code = loc-doc-rcv.rcv-code and             post-ord-line-rcv.doc-code = loc-doc-rcv.doc-code no-lock,         each post-goods where                post-goods.artic  =  post-ord-line-rcv.artic  and                 post-goods.prod-code  =  post-ord-line-rcv.prod-code  and                 post-goods.prod-type  =  post-ord-line-rcv.prod-type   no-lock              by post-ord-line-rcv.line-num .
end.
END PROCEDURE.
PROCEDURE r-clients-ch :
do
 on error undo, return error return-value
 :
define variable rid-list    as  char no-undo .
  run ref/cli-all.w ( input parParentProc, input "b-sel",'объект':U , ?, ?, ?, ?, ?, output  rid-list ) no-error .
  if num-entries (rid-list) < 1 then return error return-value .
  find first Post-clients no-lock  WHERE recid (post-clients) = integer(rid-list)  No-ERROR.
  if avail Post-clients then
      Assign
          loc-doc-rcv.cli-code = Post-clients.obj-code
          loc-doc-rcv.cli-type = Post-clients.obj-type
          post_obj-name = post-clients.obj-name.
      .
  Display loc-doc-rcv.cli-code loc-doc-rcv.cli-type Post_obj-name with frame Dialog-Frame.
  if loc-doc-rcv.obj-code = loc-doc-rcv.cli-code and
     loc-doc-rcv.obj-type = loc-doc-rcv.cli-type
     then do:
     message "Поставщик и Контрагент должны быть разные ! " view-as alert-box error .
     return no-apply.
     end.
end.
END PROCEDURE.
PROCEDURE r-clients-ob :
do
 on error undo, return error return-value
 :
define variable rid-list    as  char no-undo .
  run ref/cli-all.w ( input parParentProc, input "b-sel", 'объект':U, ?, ?, ?, ?, ?,output  rid-list) no-error .
  find first OBJ-clients no-lock WHERE recid(OBJ-clients) = integer(rid-list) No-ERROR.
  if avail OBJ-clients then do:
      Assign
      loc-doc-rcv.obj-code = OBJ-clients.obj-code
      loc-doc-rcv.obj-type = OBJ-clients.obj-type
      obj_obj-name = obj-clients.obj-name.
      .
  end.
  Display loc-doc-rcv.obj-code loc-doc-rcv.obj-type OBJ_obj-name with frame Dialog-Frame.
  if loc-doc-rcv.obj-code = loc-doc-rcv.cli-code and
     loc-doc-rcv.obj-type = loc-doc-rcv.cli-type
     then do:
     message "Поставщик и Контрагент должны быть разные ! " view-as alert-box error .
     return no-apply.
     end.
end.
END PROCEDURE.
PROCEDURE r-cur :
do
 on error undo, return error return-value
 :
if p-mode <> 1 then return .
define variable ref-rec as recid no-undo .
assign
  ref-rec = ?
  .
run ref/currency.w ( input parParentProc, "b-sel", input-output ref-rec ).
if ref-rec = ? then return no-apply.
find ub.currency where recid ( ub.currency ) = ref-rec no-lock.
if ub.currency.curr-code <> loc-exch-code then do:
      find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code
           use-index pi no-lock no-error.
      if available ub.curr-accnt then assign
          loc-doc-rcv.exch-rate  = ub.curr-accnt.exch-rate
          loc-doc-rcv.exch-scale  = ub.curr-accnt.exch-scale
          .
   assign
   loc-exch-code         = ub.currency.curr-code
   loc-doc-rcv.exch-code = ub.currency.curr-code
   loc-exch-rate         = loc-doc-rcv.exch-rate
   loc-exch-scale        = loc-doc-rcv.exch-scale
   abbr-cli              = ub.currency.curr-abbr
   .
 display loc-cli-out-code loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale loc-doc-rcv.exch-code with frame Dialog-Frame .
 end.
 end.
END PROCEDURE.
PROCEDURE ver-value :
do
 on error undo, return error return-value
 :
define buffer bf-units-cli for ub.units.
define buffer bufff-units  for ub.units.
 if  loc-line-rcv.vat-pc:sensitive in frame dialog-frame and input frame dialog-frame loc-line-rcv.vat-pc  <> loc-line-rcv.vat-pc  then apply "leave" to loc-line-rcv.vat-pc  in frame dialog-frame.
 if  loc-line-rcv.slt-pc:sensitive in frame dialog-frame and input frame dialog-frame loc-line-rcv.slt-pc  <> loc-line-rcv.slt-pc  then apply "leave" to loc-line-rcv.slt-pc  in frame dialog-frame.
 if  loc-line-rcv.cli-base-rate:sensitive in frame dialog-frame and input frame dialog-frame loc-line-rcv.cli-base-rate  <> loc-line-rcv.cli-base-rate  then apply "leave" to loc-line-rcv.cli-base-rate  in frame dialog-frame.
 if  loc-line-rcv.qnty:sensitive in frame dialog-frame and input frame dialog-frame loc-line-rcv.qnty  <> loc-line-rcv.qnty  then apply "leave" to loc-line-rcv.qnty  in frame dialog-frame.
  if  loc-line-rcv.cli-qnty:sensitive in frame dialog-frame and input frame dialog-frame loc-line-rcv.cli-qnty  <> loc-line-rcv.cli-qnty  then apply "leave" to loc-line-rcv.cli-qnty  in frame dialog-frame.
 if  loc-line-rcv.price-cli:sensitive in frame dialog-frame and input frame dialog-frame loc-line-rcv.price-cli  <> loc-line-rcv.price-cli  then apply "leave" to loc-line-rcv.price-cli  in frame dialog-frame.
 if  loc-line-rcv.price-base:sensitive in frame dialog-frame and input frame dialog-frame loc-line-rcv.price-base  <> loc-line-rcv.price-base  then apply "leave" to loc-line-rcv.price-base  in frame dialog-frame.
 if  loc-line-rcv.price-rubl:sensitive in frame dialog-frame and input frame dialog-frame loc-line-rcv.price-rubl  <> loc-line-rcv.price-rubl  then apply "leave" to loc-line-rcv.price-rubl  in frame dialog-frame.
  if loc-line-rcv.cli-qnty:sensitive in frame dialog-frame and  (loc-line-rcv.cli-qnty = 0 or loc-line-rcv.cli-qnty = ?)  then do:
    message "Не указано количество в единицах поставщика." view-as alert-box error.
    if loc-line-rcv.cli-qnty:sensitive in frame dialog-frame then apply "entry" to loc-line-rcv.cli-qnty in frame dialog-frame.
                                                              else apply "entry" to b-ok              in frame dialog-frame.
    return error.
  end.
  if loc-line-rcv.qnty:sensitive in frame dialog-frame and  (loc-line-rcv.qnty = 0 or loc-line-rcv.qnty = ?)  then do:
    message "Не указано количество  в учетных единицах." view-as alert-box error.
    return error.
  end.
  find bufff-units no-lock  where bufff-units.unit-name = ub.goods.unit-base  no-error.
  if  loc-line-rcv.qnty:sensitive in frame dialog-frame and
      lookup('шту':U, bufff-units.type) > 0      and
      trunc(loc-line-rcv.qnty, 0) <> loc-line-rcv.qnty then do:
      message "Базовая единица товара " ub.goods.unit-base " - штучная." skip
              "Кол-во должно быть целым."
      view-as alert-box error buttons ok.
      return error.
  end.
  find bf-units-cli no-lock where bf-units-cli.unit-name = loc-line-rcv.unit-cli no-error.
  if not available bf-units-cli then do:
    message "Неправильная единица измерения." view-as alert-box error.
    return error.
  end.
  if  loc-line-rcv.cli-qnty:sensitive in frame dialog-frame and
      lookup('шту':U, bf-units-cli.type) > 0  and
      trunc(loc-line-rcv.cli-qnty, 0) <> loc-line-rcv.cli-qnty then do:
      message "Единица поставщика " loc-line-rcv.unit-cli " - штучная." skip
              "Должно быть указано целое количество в единицах поставщика."
      view-as alert-box error buttons ok.
      return error.
  end.
  release bf-units-cli.
  if loc-line-rcv.cli-base-rate:sensitive in frame dialog-frame and (loc-line-rcv.cli-base-rate = 0 or loc-line-rcv.cli-base-rate = ?) then do:
    message "Не указан коэффициент пересчета единиц измерения." view-as alert-box error.
    return error.
  end.
  if loc-line-rcv.unit-cli = ub.goods.unit-base and
     decimal(loc-line-rcv.cli-base-rate:screen-value)  <> 1 then do:
     message "Коэффициент пересчета единиц измерения должен быть 1, т.к. единицы совпадают." view-as alert-box error.
     return error.
  end.
    if loc-line-rcv.price-cli:sensitive in frame dialog-frame and ( loc-line-rcv.price-cli = 0 or loc-line-rcv.price-cli = ?) then do:
      message "Не указана цена в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if loc-line-rcv.price-cli < 0  then do:
      message "Нельзя указаывать отрицательные цены в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if loc-line-rcv.price-base:sensitive in frame dialog-frame and (loc-line-rcv.price-base = 0 or loc-line-rcv.price-base = ?) then do:
      message "Не указана цена в базовой валюте." view-as alert-box error.
      return error.
    end.
    if loc-line-rcv.price-base < 0  then do:
      message "Отрицательная цена в базовой валюте."  view-as alert-box error.
      return error.
    end.
    if loc-line-rcv.price-base > 5000 and base-code = 1 then
      message "Внимание !!!" skip (2)
              "ВАЛЮТНАЯ цена превышает 5,000 !" skip (2)
              "Вы не ошиблись ?"  view-as alert-box question.
    if loc-line-rcv.price-rubl:sensitive in frame dialog-frame and (loc-line-rcv.price-rubl = 0 or loc-line-rcv.price-rubl = ?) then do:
      message "Не указана цена в рублях." view-as alert-box error.
      return error.
    end.
    if loc-line-rcv.price-rubl < 0 then do:
      message "Отрицательная цена в рублях."  view-as alert-box error.
      return error.
    end.
end.
end procedure.
