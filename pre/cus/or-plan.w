DEFINE BUFFER b-all_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER bb_ord-doc FOR ub.ord-doc.
DEFINE NEW SHARED BUFFER bufs_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_gds-obj FOR ub.gds-obj.
DEFINE BUFFER e_fp_ord-doc FOR ub.ord-doc.
DEFINE BUFFER e_fp_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER e_fp_ord-dtl FOR ub.ord-dtl.
DEFINE BUFFER e_fp_ord-dtl-rcv FOR ub.ord-dtl-rcv.
DEFINE BUFFER l_rcv_gds-dtl FOR ub.gds-dtl.
DEFINE BUFFER l_rcv_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER l_rcv_ord-dtl-rcv FOR ub.ord-dtl-rcv.
DEFINE BUFFER l_rcv_trn-doc FOR ub.trn-doc.
DEFINE TEMP-TABLE my-obj NO-UNDO LIKE ub.clients.
DEFINE BUFFER m_ord-line FOR ub.ord-line.
DEFINE BUFFER new-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER obj_gds-dtl FOR ub.gds-dtl.
DEFINE BUFFER obj_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER obj_ord-dtl-rcv FOR ub.ord-dtl-rcv.
DEFINE BUFFER obj_prt-obj FOR ub.prt-obj.
DEFINE BUFFER obj_trn-doc FOR ub.trn-doc.
DEFINE BUFFER of_ord-doc FOR ub.ord-doc.
DEFINE BUFFER of_ord-dtl FOR ub.ord-dtl.
DEFINE NEW SHARED BUFFER shar-buf_ord-doc FOR ub.ord-doc.
DEFINE TEMP-TABLE tt-goods NO-UNDO LIKE ub.goods
       field nn as int
       field use as log
       field gds-t as char
       field sum-qnty like ub.ord-line.qnty
       field sum-ord like ub.ord-line.qnty
       field sum-rcv like ub.ord-line.qnty
       field sum-rcv-in like ub.ord-line.qnty
       field sum-fact like ub.ord-line.qnty
       field prt-name like ub.gds-prt.f-name
       field all-name like ub.gds-prt.f-name
       field node-code like ub.goods.prt-root
       index i1 nn
       index i2 gds-code
       index i3 artic prod-type prod-code.
DEFINE BUFFER tt-new-doc-line FOR ub.doc-line.
DEFINE BUFFER tt-new-ord-line FOR ub.ord-line.
DEFINE TEMP-TABLE tt-ord-gds NO-UNDO LIKE ub.goods
       field use as log.
DEFINE BUFFER tt-rcv-ex FOR ub.ord-line-rcv.
DEFINE BUFFER tt-rcv-in FOR ub.ord-line-rcv.
define input  parameter parParentProc   as widget-handle no-undo.
define input  parameter p-cons-code like ub.ord-cons.cons-code no-undo .
define input  parameter doc-mode as character no-undo .
define input  parameter list-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Планирование СЗФП".
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure last-price :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter  p-host-code     as integer no-undo .
define input parameter  p-artic         like ub.doc-line.artic  no-undo .
define input parameter  p-prod-type     like ub.doc-line.prod-type  no-undo .
define input parameter  p-prod-code     like ub.doc-line.prod-code  no-undo .
define input parameter  p-cli-code      like ub.ord-doc.cli-code  no-undo .
define input parameter  p-cli-type      like ub.ord-doc.cli-type  no-undo .
define input parameter  p-cli-base-rate like ub.ord-line.cli-base-rate no-undo .
define input parameter  p-curr-code  as integer   no-undo .
define output parameter p-price-base like ub.doc-line.price-base no-undo .
define output parameter p-price-rubl like ub.doc-line.price-rubl no-undo .
define output parameter p-price-cli  like ub.doc-line.price-cli  no-undo .
define buffer buf-lib-doc-line for ub.doc-line.
define buffer buf_cli-gds for ub.cli-gds .
define buffer buf_trn-doc for ub.trn-doc  .
define variable vp-curr-code  like ub.trn-doc.exch-code.
define variable vp-exch-rate  like ub.trn-doc.exch-rate.
define variable vp-exch-scale like ub.trn-doc.exch-scale.
define variable v-last-in-code   like ub.doc-line.doc-code  no-undo .
define variable v-last-obj-type  like ub.clients.obj-type no-undo .
define variable v-last-obj-code  like ub.clients.obj-code no-undo .
define variable v-cli-base-rate as decimal   no-undo .
 find first buf_cli-gds no-lock where
            buf_cli-gds.cli-type   = p-cli-type    and
            buf_cli-gds.cli-code   = p-cli-code    and
            buf_cli-gds.host-code  = p-host-code   and
            buf_cli-gds.artic      = p-artic       and
            buf_cli-gds.prod-type  = p-prod-type   and
            buf_cli-gds.prod-code  = p-prod-code
            no-error .
if available buf_cli-gds then do:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = buf_cli-gds.in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = buf_cli-gds.in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
else do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lastindc in g#library
  (input  p-host-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-last-in-code
  ,output v-last-obj-type
  ,output v-last-obj-code
  )  .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = v-last-in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = v-last-in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
    if available buf-lib-doc-line then do:
      assign
        v-cli-base-rate = buf-lib-doc-line.cli-base-rate
        p-price-base = buf-lib-doc-line.price-base
        p-price-rubl = buf-lib-doc-line.price-rubl
        p-price-cli  = (if vp-curr-code = 0 then buf-lib-doc-line.price-rubl else buf-lib-doc-line.price-base) * p-cli-base-rate
      .
      if v-cli-base-rate <> p-cli-base-rate
      then do:
          p-price-cli  = p-price-cli / v-cli-base-rate  .
      end.
       if p-curr-code <> vp-curr-code then do:
          p-price-cli  = p-price-rubl  .
      end.
    end.
    Else do:
      assign
        p-price-base = 0
        p-price-rubl = 0
        p-price-cli  = 0
      .
    end.
  end.
end procedure.
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
define temp-table temp-ttt no-undo
field p-recid  as recid
index pi IS UNIQUE PRIMARY p-recid
.
define variable t-of as logical no-undo init false .
define variable t-prt as logical no-undo init false .
define variable dk   as integer no-undo .
define variable v-i-doc as character no-undo .
define variable x-artic like ub.goods.artic no-undo.
define variable x-prod-type like ub.goods.prod-type no-undo.
define variable x-prod-code like ub.goods.prod-code no-undo.
define variable x-node-code as character no-undo .
define variable br-handle as handle no-undo.
define variable bf-handle as handle no-undo.
define new shared  variable next-prev as logical   no-undo .
def new shared var br-rcv-handle as handle no-undo   .
define new shared variable x-make-avto as integer  no-undo .
define variable loc-make-avto as logical no-undo .
define variable obj-code-type as char no-undo.
define variable ttt as character no-undo .
define variable sort-column-name as character no-undo .
define variable user-color-status as integer no-undo init 7 .
define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#type as character no-undo .
define variable doc-rec as recid no-undo .
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable base-code as integer   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
run get-report-num in parParentProc ( output g#report-num ).
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  g#host-code
  ,output base-code
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
define variable handle-br-all as character EXTENT 100 no-undo .
define new shared variable x-mode as character  no-undo .
define variable mark     as char no-undo.
define variable str-status  as char no-undo.
define variable del-list as char no-undo.
define variable gg-recid as recid no-undo .
define variable loc-num-ord-FP as char no-undo .
FUNCTION mark-string RETURNS CHARACTER
  ( buffer loc-t-doc_ord-line for tt-new-ord-line )  FORWARD.
DEFINE MENU POPUP-MENU-B-make-post-ex-2
       MENU-ITEM m_J_1          LABEL "Сделать заказ ФП по тек.товару"
       MENU-ITEM m_J_4          LABEL "Сделать заказ ФП по товарам(*)"
       RULE
       MENU-ITEM m_J_2          LABEL "Сделать поставку внешнюю   по тек.товару"
       MENU-ITEM m_k_4          LABEL "Сделать поставку по товарам(+) из заказа".
DEFINE MENU POPUP-MENU-B-make-post-ex-3
       MENU-ITEM m_k_2          LABEL "Сделать заказ ФП по заявке  ОФ"
       RULE
       MENU-ITEM m_k_5          LABEL "Сделать поставку по заказу с учетом заявок"
       MENU-ITEM m_k_3          LABEL "Сделать поставку внешнюю по заказу".
DEFINE MENU POPUP-MENU-B-make-trn
       MENU-ITEM m_cr_post      LABEL "Сделать   ПН/РН по поставке"
       MENU-ITEM m_post_1       LABEL "Привязать ПН/РН к  поставке"
       MENU-ITEM m_d_post       LABEL "Отменить привязку  к  ПН/РН".
DEFINE MENU POPUP-MENU-B-make-trn-2
       MENU-ITEM m_H_0          LABEL "Сделать поставку по тек.товару"
       MENU-ITEM m_H_2          LABEL "Сделать поставку по товарам(*)"
       RULE
       MENU-ITEM m_H_3          LABEL "Сделать   РН по поставке товара".
DEFINE MENU POPUP-MENU-BUTTON-48
       MENU-ITEM m_I_4          LABEL "Сделать поставку по заявке ОФ"
       RULE
       MENU-ITEM m_I_3          LABEL "Сделать   РН по поставке"
       MENU-ITEM m_post_2       LABEL "Привязать РН  к поставке".
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 7 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-OK AUTO-GO
     LABEL "Выход"
     SIZE 7 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-2
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&1.Перемещ."
     SIZE 14 BY 1.13.
DEFINE BUTTON BUTTON-3
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&2.Заказы"
     SIZE 14 BY 1.13.
DEFINE BUTTON BUTTON-47
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&3.Поставки"
     SIZE 14 BY 1.13.
DEFINE VARIABLE F-obj AS CHARACTER FORMAT "X(12)" INITIAL "&1.Перемещ."
      VIEW-AS TEXT
     SIZE 10.63 BY .54 NO-UNDO.
DEFINE VARIABLE F-post AS CHARACTER FORMAT "X(12)":U INITIAL "&3.Поставки"
      VIEW-AS TEXT
     SIZE 11 BY .54 NO-UNDO.
DEFINE VARIABLE F-post-2 AS CHARACTER FORMAT "X(12)":U INITIAL "&2.Заказы"
      VIEW-AS TEXT
     SIZE 12.38 BY .54 NO-UNDO.
DEFINE VARIABLE loc-ord-cons-code AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "№ СЗФП"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE str-good AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 84.25 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE R-main AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "По документам", 1,
"По товарам", 2,
"По признакам", 3
     SIZE 44.63 BY .58 NO-UNDO.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99.88 BY 11.04
     FGCOLOR 15 .
DEFINE VARIABLE T-gds AS LOGICAL INITIAL no
     LABEL "развернуть"
     VIEW-AS TOGGLE-BOX
     SIZE 13.13 BY .58 TOOLTIP "Паказать все товары документа" NO-UNDO.
DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Отметить товары".
DEFINE BUTTON B-mark-3
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".
DEFINE BUTTON B-mark-4
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "отметить все товары".
DEFINE VARIABLE T-obj AS LOGICAL INITIAL no
     LABEL "все"
     VIEW-AS TOGGLE-BOX
     SIZE 6 BY .58 NO-UNDO.
DEFINE BUTTON B-mark-5
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Отметить товары".
DEFINE BUTTON B-mark-6
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".
DEFINE BUTTON B-mark-7
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "отметить все товары".
DEFINE VARIABLE T-cli AS LOGICAL INITIAL no
     LABEL "все"
     VIEW-AS TOGGLE-BOX
     SIZE 6.38 BY .58 TOOLTIP "Показать Все поставщики/поставщики товара" NO-UNDO.
DEFINE VARIABLE T-cli-fp AS LOGICAL INITIAL no
     LABEL "по поставщику"
     VIEW-AS TOGGLE-BOX
     SIZE 16.13 BY .58 TOOLTIP "Показать Заказы по поставщику \ все заказы" NO-UNDO.
DEFINE BUTTON B-ins-za
     LABEL "Доб."
     SIZE 8 BY 1 TOOLTIP "Добавить заявку ОФ в СЗФП".
DEFINE BUTTON B-isk
     LABEL "Исключить"
     SIZE 9.63 BY 1 TOOLTIP "Исключить заявку из СЗФП".
DEFINE BUTTON B-reject
     LABEL "Отказать"
     SIZE 8.63 BY 1 TOOLTIP "Отказать заявке ОФ".
DEFINE BUTTON B-za-3
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "просмотр заявки ОФ".
DEFINE BUTTON B-make-trn-2
     LABEL "Сделать"
     SIZE 8 BY 1 TOOLTIP "Сделать документы".
DEFINE BUTTON BUTTON-14
     LABEL "Удал."
     SIZE 7 BY 1 TOOLTIP "Удалить строку накладной".
DEFINE BUTTON BUTTON-15
     LABEL "Изм."
     SIZE 7 BY 1 TOOLTIP "Изменение".
DEFINE BUTTON BUTTON-58
     LABEL "Просм."
     SIZE 7 BY 1 TOOLTIP "Просмотр строки поставки внутренней".
DEFINE BUTTON BUTTON-59
     LABEL "Просм."
     SIZE 7 BY 1 TOOLTIP "Просмотр строки накладной".
DEFINE BUTTON BUTTON-7
     LABEL "Изм."
     SIZE 7 BY 1 TOOLTIP "Изменить строку поставки".
DEFINE BUTTON BUTTON-8
     LABEL "Удал."
     SIZE 7 BY 1 TOOLTIP "Удалить строку поставки".
DEFINE BUTTON BUTTON-17
     LABEL "Изм."
     SIZE 8 BY 1 TOOLTIP "Изменить накладную".
DEFINE BUTTON BUTTON-18
     LABEL "Удал."
     SIZE 8 BY 1 TOOLTIP "Удалить накладную".
DEFINE BUTTON BUTTON-20
     LABEL "Удал."
     SIZE 8 BY 1 TOOLTIP "Удалить поставку".
DEFINE BUTTON BUTTON-21
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "Просмотр".
DEFINE BUTTON BUTTON-48
     LABEL "Сделать"
     SIZE 9 BY 1 TOOLTIP "Сделать поставку".
DEFINE BUTTON BUTTON-57
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "Просмотр внутренней поставки".
DEFINE BUTTON B-make-post-ex-2
     LABEL "Сделать"
     SIZE 8 BY .92 TOOLTIP "Сделать заказ ФП".
DEFINE BUTTON B-mark-2
     LABEL "+"
     SIZE 3 BY .92 TOOLTIP "Отметить товары, которые надо включить в поставку".
DEFINE BUTTON BUTTON-10
     LABEL "Удал."
     SIZE 7 BY .92 TOOLTIP "Удалить строку заказа".
DEFINE BUTTON BUTTON-33
     LABEL "Изм."
     SIZE 7 BY .92 TOOLTIP "Изменить строку поставки".
DEFINE BUTTON BUTTON-34
     LABEL "Удал."
     SIZE 7 BY .92 TOOLTIP "Удалить строку поставки".
DEFINE BUTTON BUTTON-55
     LABEL "Просм."
     SIZE 7 BY .92 TOOLTIP "Просмотр строки заказа".
DEFINE BUTTON BUTTON-56
     LABEL "Просм."
     SIZE 7 BY .92 TOOLTIP "Просмотреть строку поставки".
DEFINE BUTTON BUTTON-9
     LABEL "Изм."
     SIZE 7 BY .92 TOOLTIP "Изменить строку".
DEFINE BUTTON B-make-post-ex-3
     LABEL "Сделать"
     SIZE 8 BY 1 TOOLTIP "Сделать заказ ФП".
DEFINE BUTTON BUTTON-27
     LABEL "Изм."
     SIZE 8 BY 1 TOOLTIP "Изменить заказ".
DEFINE BUTTON BUTTON-28
     LABEL "Удал."
     SIZE 8 BY 1 TOOLTIP "Удалить строку заказа".
DEFINE BUTTON BUTTON-30
     LABEL "Изм."
     SIZE 7 BY 1 TOOLTIP "Изменить строку поставки".
DEFINE BUTTON BUTTON-31
     LABEL "Удал."
     SIZE 7 BY 1 TOOLTIP "Удалить строку поставки".
DEFINE BUTTON BUTTON-53
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "Просмотр заказа".
DEFINE BUTTON BUTTON-54
     LABEL "Просм."
     SIZE 7 BY 1 TOOLTIP "Просмотреть поставку".
DEFINE BUTTON B-make-trn
     LABEL "Сделать"
     SIZE 9 BY 1 TOOLTIP "Сделать ПН по поставке".
DEFINE BUTTON BUTTON-49
     LABEL "Просм."
     SIZE 8 BY 1.
DEFINE BUTTON BUTTON-50
     LABEL "Изм."
     SIZE 8 BY 1.
DEFINE BUTTON BUTTON-51
     LABEL "Удал."
     SIZE 8 BY 1 TOOLTIP "Удалить накладную".
DEFINE BUTTON BUTTON-52
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "Просмотр поставки".
DEFINE QUERY BROWSE-12 FOR
      tt-goods,
      ub.ord-gds-cons SCROLLING.
DEFINE QUERY BROWSE-13 FOR
      ub.m_ord-line,
      ub.ord-doc SCROLLING.
DEFINE QUERY BROWSE-14 FOR
      my-obj,
      buf_gds-obj SCROLLING.
DEFINE QUERY BROWSE-15 FOR
      b-all_ord-doc-rcv,
      ub.ord-chain,
      ub.trn-doc,
      ub.doc-line SCROLLING.
DEFINE QUERY BROWSE-16 FOR
      ub.ord-doc SCROLLING.
DEFINE QUERY BROWSE-17 FOR
      ub.buf_clients,
      ub.cli-gds SCROLLING.
DEFINE QUERY BROWSE-18 FOR
      ub.ord-doc,
      tt-new-ord-line,
      ub.goods SCROLLING.
DEFINE QUERY BROWSE-20 FOR
      b-all_ord-doc-rcv,
      ub.ord-line-rcv SCROLLING.
DEFINE QUERY BROWSE-21 FOR
      new-rcv,
      bb_ord-doc SCROLLING.
DEFINE QUERY BROWSE-22 FOR
      ub.ord-chain,
      ub.trn-doc SCROLLING.
DEFINE QUERY BROWSE-23 FOR
      ub.ord-doc-rcv SCROLLING.
DEFINE QUERY BROWSE-24 FOR
      b-all_ord-doc-rcv,
      ub.ord-chain,
      ub.trn-doc SCROLLING.
DEFINE QUERY BROWSE-26 FOR
      ub.ord-doc,
      ub.shar-buf_ord-doc SCROLLING.
DEFINE QUERY BROWSE-27 FOR
      ub.ord-doc-rcv SCROLLING.
DEFINE QUERY BROWSE-28 FOR
      ub.ord-doc-rcv,
      ub.ord-line-rcv,
      ub.goods SCROLLING.
DEFINE QUERY BROWSE-29 FOR
      new-rcv,
      ub.ord-line-rcv,
      bb_ord-doc SCROLLING.
DEFINE QUERY BROWSE-30 FOR
      tt-goods,
      ub.ord-gds-cons SCROLLING.
DEFINE QUERY BROWSE-31 FOR
      ub.of_ord-dtl,
      ub.of_ord-doc,
      ub.gds-prt SCROLLING.
DEFINE QUERY BROWSE-32 FOR
      e_fp_ord-dtl,
      e_fp_ord-doc,
      ub.gds-prt SCROLLING.
DEFINE QUERY BROWSE-33 FOR
      e_fp_ord-dtl-rcv,
      e_fp_ord-doc-rcv,
      ub.gds-prt SCROLLING.
DEFINE QUERY BROWSE-34 FOR
      l_rcv_ord-dtl-rcv,
      l_rcv_ord-doc-rcv,
      ub.gds-prt SCROLLING.
DEFINE QUERY BROWSE-35 FOR
      l_rcv_gds-dtl,
      l_rcv_trn-doc,
      ub.gds-prt SCROLLING.
DEFINE QUERY BROWSE-36 FOR
      obj_ord-dtl-rcv,
      obj_ord-doc-rcv,
      ub.gds-prt SCROLLING.
DEFINE QUERY BROWSE-37 FOR
      obj_prt-obj,
      ub.gds-prt SCROLLING.
DEFINE BROWSE BROWSE-12
  QUERY BROWSE-12 NO-LOCK DISPLAY
      tt-goods.use COLUMN-LABEL "*" FORMAT "*/"
      tt-goods.artic
      tt-goods.gds-name FORMAT "X(20)"
       tt-goods.sum-qnty COLUMN-LABEL "Запрошено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-ord COLUMN-LABEL "Заказано" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-rcv COLUMN-LABEL "Поставлено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-rcv-in COLUMN-LABEL "Перемещено" FORMAT "->>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.unit-base COLUMN-LABEL "баз."
      tt-goods.unit-cli COLUMN-LABEL "Пост."
      tt-goods.sum-fact COLUMN-LABEL "По ПН" FORMAT ">>>>>>>9.<<<"
  ENABLE
      tt-goods.artic
    WITH NO-ROW-MARKERS SEPARATORS SIZE 61.5 BY 9
         TITLE "Совокупный заказ".
DEFINE BROWSE BROWSE-13
  QUERY BROWSE-13 NO-LOCK DISPLAY
      ub.ord-doc.obj-type + " " + STRING (ub.ord-doc.obj-code) COLUMN-LABEL "Объект" FORMAT "x(8)":U
      m_ord-line.qnty COLUMN-LABEL "Запрошено" FORMAT ">>>>>>>9.<<<":U
      ub.ord-doc.ship-date COLUMN-LABEL "Достав." FORMAT "99/99/99":U
      string(ub.ord-doc.ship-time,"HH:MM") COLUMN-LABEL "Время" FORMAT "x(5)":U
      IF (ub.ord-doc.status_ = 'факт':U or ub.ord-doc.status_ = 'закрыто':U)  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-"))  ELSE (ub.ord-doc.status_) COLUMN-LABEL "Статус" FORMAT "x(8)":U
      m_ord-line.doc-code FORMAT "X(14)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37.75 BY 9.13
         TITLE "Заявки ОФ по товару".
DEFINE BROWSE BROWSE-14
  QUERY BROWSE-14 NO-LOCK DISPLAY
      my-obj.obj-type + " " + STRING (my-obj.obj-code) COLUMN-LABEL "Объект" FORMAT "x(8)"
      buf_gds-obj.fact-qnty FORMAT "->>>>>>>9.<<<"
      my-obj.obj-name COLUMN-LABEL "Наименование" FORMAT "x(20)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 25.38 BY 9.13
         TITLE "Остатки товара по объектам".
DEFINE BROWSE BROWSE-15
  QUERY BROWSE-15 NO-LOCK DISPLAY
      ub.trn-doc.doc-code FORMAT "X(14)":U
      ub.trn-doc.doc-type FORMAT "X(3)":U
      ub.doc-line.doc-qnty FORMAT "->>,>>>,>>9.<<<":U
      ub.trn-doc.cli-type + " " + string(trn-doc.cli-code) COLUMN-LABEL "C Объекта" FORMAT "x(10)":U
      ub.trn-doc.status_ FORMAT "X(8)":U
      ub.trn-doc.obj-type + " " + string(trn-doc.obj-code) COLUMN-LABEL "На объект" FORMAT "x(10)":U
  ENABLE
      ub.trn-doc.doc-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         TITLE "Внутреннее перемещение товара".
DEFINE BROWSE BROWSE-16
  QUERY BROWSE-16 NO-LOCK DISPLAY
      ub.ord-doc.obj-type + " " + string(ub.ord-doc.obj-code) COLUMN-LABEL "Объект"
      ub.ord-doc.doc-code COLUMN-LABEL "Заявка" FORMAT "X(14)":U
      ub.ord-doc.ship-date COLUMN-LABEL "Постав." FORMAT "99/99/99":U
      string(ub.ord-doc.ship-time,"HH:MM") COLUMN-LABEL "Время"
      IF (ub.ord-doc.status_ = 'факт':U or ub.ord-doc.status_ = 'закрыто':U)  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-"))  ELSE (ub.ord-doc.status_) COLUMN-LABEL "Статус"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37.75 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Все Заявки ОФ".
DEFINE BROWSE BROWSE-17
  QUERY BROWSE-17 NO-LOCK DISPLAY
      buf_clients.obj-type + " " + string(buf_clients.obj-code) COLUMN-LABEL "Код"
      ub.cli-gds.price-cli FORMAT ">>>>>>>>>>9.99":U
      buf_clients.obj-name FORMAT "X(40)":U
      ub.cli-gds.cancel-date FORMAT "99/99/99":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 25.38 BY 9.13
         TITLE "Список поставщиков".
DEFINE BROWSE BROWSE-18
  QUERY BROWSE-18 NO-LOCK DISPLAY
      mark-string (buffer tt-new-ord-line) @ mark COLUMN-LABEL "+" FORMAT "x(1)"
tt-new-ord-line.doc-code COLUMN-LABEL "№ заказа" FORMAT "X(10)"
tt-new-ord-line.qnty COLUMN-LABEL "Кол-во " FORMAT ">>>>>>>9.<<<"
string(ub.ord-doc.cli-type + ' ' + string(ub.ord-doc.cli-code)) COLUMN-LABEL "Кому"  FORMAT "x(10)"
ub.ord-doc.cli-name COLUMN-LABEL "Поставщик" FORMAT "X(20)"
(IF (ub.ord-doc.status_ = 'факт':U or ub.ord-doc.status_ = 'закрыто':U) THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,'+/-')) ELSE (ub.ord-doc.status_) ) @ str-status   COLUMN-LABEL "Статус"  FORMAT "x(8)"
ub.goods.gds-name FORMAT "X(20)"
tt-new-ord-line.artic
enable tt-new-ord-line.qnty
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 37 BY 9.13
         TITLE "Заказы ФП по товару".
DEFINE BROWSE BROWSE-20
  QUERY BROWSE-20 NO-LOCK DISPLAY
      ub.ord-line-rcv.rcv-code COLUMN-LABEL     '№ пост-ки'
( b-all_ord-doc-rcv.obj-type + ' ' + string(b-all_ord-doc-rcv.obj-code) )    COLUMN-LABEL  'Куда'   FORMAT "x(8)"
ub.ord-line-rcv.qnty     COLUMN-LABEL  'Кол-во'  FORMAT ">>>>>>>9.<<<"
ub.ord-line-rcv.cli-qnty    COLUMN-LABEL   'Кол-во(пост.)'  FORMAT ">>>>>>>9.<<<"
( b-all_ord-doc-rcv.cli-type + ' ' + string(b-all_ord-doc-rcv.cli-code))     COLUMN-LABEL  'С объекта'  FORMAT "x(10)"
ub.ord-line-rcv.price-cli     COLUMN-LABEL   'Цена (пост.)' FORMAT ">>>>>>>>>>9.999"
ub.ord-line-rcv.price-rubl      COLUMN-LABEL 'Цена (руб)'  FORMAT ">>>>>>>>>>>>9.999"
ub.ord-line-rcv.artic       COLUMN-LABEL 'Артикул'
(IF (b-all_ord-doc-rcv.status_ = 'факт':U or b-all_ord-doc-rcv.status_ = 'закрыто':U)  THEN (b-all_ord-doc-rcv.status_ + string(b-all_ord-doc-rcv.flag_,"+/-"))  ELSE (b-all_ord-doc-rcv.status_) )       COLUMN-LABEL 'Статус'    FORMAT "x(8)"
  ENABLE
ub.ord-line-rcv.rcv-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         TITLE "Поставка товара внутренняя".
DEFINE BROWSE BROWSE-21
  QUERY BROWSE-21 NO-LOCK DISPLAY
      new-rcv.rcv-code COLUMN-LABEL "№ пост-ки" FORMAT "X(14)":U
      new-rcv.doc-code COLUMN-LABEL "№ заказа" FORMAT "X(14)":U
      new-rcv.obj-type + " " + string(new-rcv.obj-code) COLUMN-LABEL "Куда" FORMAT "x(10)":U
      new-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99":U
      new-rcv.fact-date FORMAT "99/99/99":U
      string(new-rcv.ship-time,"HH:MM") COLUMN-LABEL "Время"
      IF (new-rcv.status_ = 'факт':U or new-rcv.status_ = 'закрыто':U)  THEN (new-rcv.status_ + string(new-rcv.flag_,"+/-"))  ELSE (new-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)":U
      IF (new-rcv.doc-type = "in":U) THEN ("внут") ELSE ("внеш") COLUMN-LABEL "Тип" FORMAT "x(4)":U
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 25.38 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Все Поставки по СЗФП".
DEFINE BROWSE BROWSE-22
  QUERY BROWSE-22 NO-LOCK DISPLAY
      ub.trn-doc.doc-code FORMAT "X(14)":U
      ub.trn-doc.doc-date FORMAT "99/99/99":U
      ub.trn-doc.obj-type + " " + string(trn-doc.obj-code) COLUMN-LABEL "Объект" FORMAT "x(8)":U
      ub.trn-doc.cli-type + string( ub.trn-doc.cli-code) COLUMN-LABEL "Контрагент" FORMAT "x(8)":U
      string(trn-doc.fact-time,"HH:MM") COLUMN-LABEL "Время" FORMAT "X(5)":U
      ub.trn-doc.fact-date FORMAT "99/99/99":U
      ub.trn-doc.internal FORMAT "yes/no":U
      ub.trn-doc.out-code FORMAT "X(14)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Приходные накладные".
DEFINE BROWSE BROWSE-23
  QUERY BROWSE-23 NO-LOCK DISPLAY
      ub.ord-doc-rcv.rcv-code COLUMN-LABEL "№ пост-ки" FORMAT "X(14)":U
      ub.ord-doc-rcv.cli-type + " " + string(ub.ord-doc-rcv.cli-code) COLUMN-LABEL "С объекта" FORMAT "x(10)":U
      ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code) COLUMN-LABEL "На объект" FORMAT "x(10)":U
      ub.ord-doc-rcv.doc-date FORMAT "99/99/99":U
      ub.ord-doc-rcv.fact-date FORMAT "99/99/99":U
      ub.ord-doc-rcv.ship-date FORMAT "99/99/99":U
      STRING (ub.ord-doc-rcv.ship-time,"HH:MM") COLUMN-LABEL "Время доставки" FORMAT "x(8)":U
      IF (ub.ord-doc-rcv.status_ = 'факт':U or ub.ord-doc-rcv.status_ = 'закрыто':U)  THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,"+/-"))  ELSE (ub.ord-doc-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Документы поставки внутренние".
DEFINE BROWSE BROWSE-24
  QUERY BROWSE-24 NO-LOCK DISPLAY
      ub.trn-doc.doc-code COLUMN-LABEL "№РН" FORMAT "X(14)":U
      ub.trn-doc.doc-type FORMAT "X(3)":U
      ub.trn-doc.obj-type + " " + string(trn-doc.obj-code) COLUMN-LABEL "Объект" FORMAT "x(10)":U
      ub.trn-doc.cli-type + " " + string(trn-doc.cli-code) COLUMN-LABEL "Контрагент" FORMAT "x(10)":U
      ub.trn-doc.status_ FORMAT "X(8)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Документы на внутреннее перемещение".
DEFINE BROWSE BROWSE-26
  QUERY BROWSE-26 NO-LOCK DISPLAY
      ub.ord-doc.doc-code COLUMN-LABEL "Заказ №" FORMAT "X(14)":U
      ub.ord-doc.cli-type + " " + string(ub.ord-doc.cli-code) COLUMN-LABEL "Кому" FORMAT "x(10)":U
      ub.ord-doc.doc-date FORMAT "99/99/99":U
      ub.ord-doc.fact-date FORMAT "99/99/99":U
      ub.ord-doc.ship-date FORMAT "99/99/99":U
      STRING (ub.ord-doc.ship-time,"HH:MM") COLUMN-LABEL "Время"
      ub.ord-doc.cli-name COLUMN-LABEL "Поставщик" FORMAT "X(20)":U
      IF (ub.ord-doc.status_ = 'факт':U or ub.ord-doc.status_ = 'закрыто':U)  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-"))  ELSE (ub.ord-doc.status_) COLUMN-LABEL "Статус" FORMAT "x(8)":U
  ENABLE
      ub.ord-doc.doc-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Заказы ФП".
DEFINE BROWSE BROWSE-27
  QUERY BROWSE-27 DISPLAY
      ub.ord-doc-rcv.rcv-code COLUMN-LABEL "№ Поставки" FORMAT "X(14)":U
      ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code) COLUMN-LABEL "Куда" FORMAT "x(10)":U
      ub.ord-doc-rcv.doc-code COLUMN-LABEL "Заказ ФП" FORMAT "X(14)":U
      ub.ord-doc-rcv.doc-date FORMAT "99/99/99":U
      ub.ord-doc-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99":U
      string(ub.ord-doc-rcv.ship-time,"HH:MM") COLUMN-LABEL "Время" FORMAT "X(5)":U
      ub.ord-doc-rcv.status_ FORMAT "X(8)":U
  ENABLE
      ub.ord-doc-rcv.rcv-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Поставки по заказу".
DEFINE BROWSE BROWSE-28
  QUERY BROWSE-28 NO-LOCK DISPLAY
      ub.ord-doc-rcv.rcv-code COLUMN-LABEL 'Поставка'
   ub.ord-line-rcv.qnty  COLUMN-LABEL 'Кол-во'
   ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code)  FORMAT "x(10)"  COLUMN-LABEL 'Куда'
   ub.ord-line-rcv.price-rubl COLUMN-LABEL 'Цена(руб.)'
   ub.ord-line-rcv.cli-qnty COLUMN-LABEL 'Кол-во(е.и.п)'
   ub.ord-line-rcv.price-cli COLUMN-LABEL 'Цена (пост.)'
   ub.ord-doc-rcv.ship-date FORMAT "99/99/99" COLUMN-LABEL 'Доставка'
   ub.ord-line-rcv.artic COLUMN-LABEL 'Артикул'
   ub.ord-doc-rcv.doc-code  COLUMN-LABEL 'Заказ'
   IF (ub.ord-doc-rcv.status_ = 'факт':U or ub.ord-doc-rcv.status_ = 'закрыто':U)  THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,"+/-"))  ELSE (ub.ord-doc-rcv.status_)  FORMAT "x(8)"
        COLUMN-LABEL 'Статус'
   ub.goods.gds-name FORMAT "X(20)"  COLUMN-LABEL 'Название товара'
 enable ub.ord-line-rcv.cli-qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         TITLE "Поставки по строкам".
DEFINE BROWSE BROWSE-29
  QUERY BROWSE-29 NO-LOCK DISPLAY
      new-rcv.obj-type + " " + string(new-rcv.obj-code) COLUMN-LABEL "Куда" FORMAT "x(10)"
    ub.ord-line-rcv.qnty FORMAT ">>>>>>>9.<<<"
    ub.ord-line-rcv.artic
    new-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99"
    new-rcv.fact-date FORMAT "99/99/99"
    string(new-rcv.ship-time,"HH:MM") COLUMN-LABEL "Время"
    new-rcv.rcv-code COLUMN-LABEL "№ пост-ки"
    IF (new-rcv.status_ = 'факт':U or new-rcv.status_ = 'закрыто':U)  THEN (new-rcv.status_ + string(new-rcv.flag_,"+/-"))  ELSE (new-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)"
    new-rcv.doc-code COLUMN-LABEL "№ заказа"
    IF (new-rcv.doc-type = 'in':U) THEN ('внут') ELSE ('внеш') COLUMN-LABEL "Тип" FORMAT "x(4)"
    ub.ord-line-rcv.price-rubl
    ub.ord-line-rcv.cli-qnty
    ub.ord-line-rcv.price-cli
  ENABLE
    ub.ord-line-rcv.qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         TITLE "Все поставки по товару и заявке".
DEFINE BROWSE BROWSE-30
  QUERY BROWSE-30 NO-LOCK DISPLAY
      tt-goods.use COLUMN-LABEL "*" FORMAT "*/"
      tt-goods.artic
      tt-goods.all-name FORMAT "X(30)" COLUMN-LABEL "Товар - Признак"
      tt-goods.sum-qnty COLUMN-LABEL "Запрошено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-ord COLUMN-LABEL "Заказано" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-rcv COLUMN-LABEL "Поставлено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-rcv-in COLUMN-LABEL "Перемещено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.unit-base COLUMN-LABEL "баз."
      tt-goods.unit-cli COLUMN-LABEL "Пост."
      tt-goods.sum-fact COLUMN-LABEL "По ПН" FORMAT ">>>>>>>9.<<<"
      tt-goods.gds-t COLUMN-LABEL "ПРИ" FORMAT "x(3)" LABEL-FGCOLOR 1
  ENABLE
      tt-goods.artic
    WITH NO-ROW-MARKERS SEPARATORS SIZE 62 BY 9.13
         TITLE "Совокупный заказ".
DEFINE BROWSE BROWSE-31
  QUERY BROWSE-31 NO-LOCK DISPLAY
      of_ord-dtl.doc-code FORMAT "X(14)":U COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)":U
      of_ord-dtl.qnty FORMAT ">>>>>>>9.<<<":U COLUMN-FGCOLOR 9
      of_ord-doc.obj-type + " " + string(of_ord-doc.obj-code) COLUMN-LABEL "От кого"
            COLUMN-FGCOLOR 9
      IF (of_ord-doc.status_ = 'факт':U or of_ord-doc.status_ = 'закрыто':U)  THEN (of_ord-doc.status_ + string(of_ord-doc.flag_,"+/-"))  ELSE (of_ord-doc.status_)
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37.13 BY 9.13
         TITLE "Признаки по заявкам".
DEFINE BROWSE BROWSE-32
  QUERY BROWSE-32 NO-LOCK DISPLAY
      e_fp_ord-doc.doc-code COLUMN-LABEL "Заказ"   COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)"                            COLUMN-FGCOLOR 9
      e_fp_ord-dtl.qnty FORMAT ">>>>>>>9.<<<"        COLUMN-FGCOLOR 9
      e_fp_ord-doc.cli-type + " " +  string(e_fp_ord-doc.cli-code) COLUMN-LABEL "Контрагент" FORMAT "x(10)"
                                                                                             COLUMN-FGCOLOR 9
      e_fp_ord-doc.status_                                              COLUMN-FGCOLOR 9
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.63 BY 10.63
         TITLE "Заказы ФП по признаку".
DEFINE BROWSE BROWSE-33
  QUERY BROWSE-33 NO-LOCK DISPLAY
      e_fp_ord-dtl-rcv.rcv-code COLUMN-LABEL "Поставка" COLUMN-FGCOLOR 9
      ub.gds-prt.f-name                         COLUMN-FGCOLOR 9
      e_fp_ord-dtl-rcv.qnty          COLUMN-FGCOLOR 9
      e_fp_ord-dtl-rcv.doc-code COLUMN-FGCOLOR 9
      e_fp_ord-doc-rcv.cli-code COLUMN-FGCOLOR 9
      e_fp_ord-doc-rcv.cli-type COLUMN-FGCOLOR 9
      e_fp_ord-doc-rcv.obj-type + " " + string(e_fp_ord-doc-rcv.obj-code) COLUMN-LABEL "Объект" COLUMN-FGCOLOR 9
      e_fp_ord-doc-rcv.status_  COLUMN-FGCOLOR 9
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.5 BY 10.63
         TITLE "Поставки внешние по признаку".
DEFINE BROWSE BROWSE-34
  QUERY BROWSE-34 NO-LOCK DISPLAY
      l_rcv_ord-dtl-rcv.rcv-code COLUMN-LABEL "Поставка" COLUMN-FGCOLOR 9
      IF (l_rcv_ord-doc-rcv.doc-type = "in":U) THEN ("внут") ELSE ("внеш") COLUMN-LABEL "Тип" FORMAT "x(4)"  COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)"   COLUMN-FGCOLOR 9
      l_rcv_ord-dtl-rcv.qnty COLUMN-LABEL "Количество" FORMAT ">>>>>>>9.<<<"  COLUMN-FGCOLOR 9
      l_rcv_ord-doc-rcv.cli-type + " " + STRING (l_rcv_ord-doc-rcv.cli-code) COLUMN-LABEL "Контрагент"
          COLUMN-FGCOLOR 9
      l_rcv_ord-doc-rcv.obj-type + " " + STRING (l_rcv_ord-doc-rcv.obj-code) COLUMN-LABEL "Объект"
            COLUMN-FGCOLOR 9
      IF (l_rcv_ord-doc-rcv.status_ = 'факт':U or l_rcv_ord-doc-rcv.status_ = 'закрыто':U)  THEN (l_rcv_ord-doc-rcv.status_ + string(l_rcv_ord-doc-rcv.flag_,"+/-"))  ELSE (l_rcv_ord-doc-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)"
            COLUMN-FGCOLOR 9
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50 BY 10.46
         TITLE "Поставки по признаку".
DEFINE BROWSE BROWSE-35
  QUERY BROWSE-35 NO-LOCK DISPLAY
      l_rcv_gds-dtl.doc-code        COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)"  COLUMN-FGCOLOR 9
      l_rcv_gds-dtl.doc-qnty  COLUMN-FGCOLOR 9
      l_rcv_gds-dtl.fact-qnty  COLUMN-FGCOLOR 9
      l_rcv_trn-doc.obj-type + " " + STRING (l_rcv_trn-doc.obj-code)  COLUMN-LABEL "Объект"  COLUMN-FGCOLOR 9
      l_rcv_trn-doc.cli-type + " " + STRING (l_rcv_trn-doc.cli-code)  COLUMN-LABEL "Контрагент"  COLUMN-FGCOLOR 9
      l_rcv_trn-doc.doc-type  COLUMN-FGCOLOR 9
     IF (l_rcv_trn-doc.status_ = 'факт':U or l_rcv_trn-doc.status_ = 'закрыто':U)  THEN (l_rcv_trn-doc.status_ + string(l_rcv_trn-doc.flag_,"+/-"))  ELSE (l_rcv_trn-doc.status_) COLUMN-LABEL "Статус" FORMAT "x(8)"
       COLUMN-FGCOLOR 9
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.38 BY 10.46
         TITLE "ПН и РН по признакам".
DEFINE BROWSE BROWSE-36
  QUERY BROWSE-36 NO-LOCK DISPLAY
      obj_ord-dtl-rcv.rcv-code COLUMN-LABEL "Поставка" COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)" COLUMN-FGCOLOR 9
      obj_ord-dtl-rcv.qnty COLUMN-LABEL "Количество" FORMAT ">>>>>>>9.<<<" COLUMN-FGCOLOR 9
      obj_ord-doc-rcv.cli-type + " " + STRING (obj_ord-doc-rcv.cli-code) COLUMN-LABEL "Контрагент"
            COLUMN-FGCOLOR 9
      obj_ord-doc-rcv.obj-type + " " + STRING (obj_ord-doc-rcv.obj-code) COLUMN-LABEL "Объект"
            COLUMN-FGCOLOR 9
      IF (obj_ord-doc-rcv.status_ = 'факт':U or obj_ord-doc-rcv.status_ = 'закрыто':U)  THEN (obj_ord-doc-rcv.status_ + string(obj_ord-doc-rcv.flag_,"+/-"))  ELSE (obj_ord-doc-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)"
            COLUMN-FGCOLOR 9
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.75 BY 10.5
         TITLE "Поставки внутренние по признаку".
DEFINE BROWSE BROWSE-37
  QUERY BROWSE-37 NO-LOCK DISPLAY
      obj_prt-obj.obj-type + " " + STRING (obj_prt-obj.obj-code) COLUMN-LABEL "Объект"
      COLUMN-FGCOLOR 9
gds-prt.f-name FORMAT "X(10)" COLUMN-FGCOLOR 9
obj_prt-obj.fact-qnty FORMAT ">>>>>>>9.<<<" COLUMN-FGCOLOR 9
obj_prt-obj.free-qnty FORMAT ">>>>>>>9.<<<" COLUMN-FGCOLOR 9
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.5 BY 10.5
         TITLE "Наличие признака на объектах".
DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1.04 COL 1
     B-Help AT ROW 1.04 COL 93.88
     BUTTON-2 AT ROW 12.38 COL 1
     R-main AT ROW 12.58 COL 43.13 NO-LABEL
     T-gds AT ROW 12.58 COL 87.75
     BUTTON-3 AT ROW 12.38 COL 15
     BUTTON-47 AT ROW 12.38 COL 29
     str-good AT ROW 1 COL 7 COLON-ALIGNED NO-LABEL
     loc-ord-cons-code AT ROW 1.25 COL 8 COLON-ALIGNED NO-LABEL
     F-post-2 AT ROW 12.67 COL 15.75 NO-LABEL
     F-post AT ROW 12.67 COL 28.38 COLON-ALIGNED NO-LABEL
     F-obj AT ROW 12.75 COL 2.5 NO-LABEL
     RECT-3 AT ROW 13.25 COL 1
     SPACE(0.00) SKIP(0.03)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Планирование заказа"
         DEFAULT-BUTTON B-OK.
DEFINE FRAME FRAME-E
     BROWSE-17 AT ROW 1 COL 1
     T-cli AT ROW 10.25 COL 1
     T-cli-fp AT ROW 10.25 COL 9.13
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         NO-LABELS SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 13.5
         SIZE 99.75 BY 10.67.
DEFINE FRAME FRAME-K
     BROWSE-26 AT ROW 1 COL 1
     BROWSE-27 AT ROW 1 COL 38
     B-make-post-ex-3 AT ROW 10.25 COL 1
     BUTTON-27 AT ROW 10.25 COL 9
     BUTTON-53 AT ROW 10.25 COL 17
     BUTTON-28 AT ROW 10.25 COL 25
     BUTTON-30 AT ROW 10.25 COL 38
     BUTTON-54 AT ROW 10.25 COL 45.13
     BUTTON-31 AT ROW 10.25 COL 52.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS THREE-D
         AT COL 26.25 ROW 1
         SIZE 74.13 BY 10.46.
DEFINE FRAME FRAME-J
     BROWSE-18 AT ROW 1 COL 1
     BROWSE-28 AT ROW 1 COL 38
     B-mark-2 AT ROW 10.21 COL 1.13
     B-make-post-ex-2 AT ROW 10.21 COL 4.13
     BUTTON-9 AT ROW 10.21 COL 12.13
     BUTTON-55 AT ROW 10.21 COL 19.13
     BUTTON-10 AT ROW 10.21 COL 26.25
     BUTTON-33 AT ROW 10.21 COL 38.13
     BUTTON-56 AT ROW 10.21 COL 45.13
     BUTTON-34 AT ROW 10.21 COL 52.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 26.25 ROW 1
         SIZE 74.13 BY 10.21.
DEFINE FRAME FRAME-E-prt
     BROWSE-32 AT ROW 1 COL 1
     BROWSE-33 AT ROW 1 COL 50.88
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.63 BY 10.63.
DEFINE FRAME FRAME-D
     BROWSE-13 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 63 ROW 2
         SIZE 37.88 BY 9.25.
DEFINE FRAME FRAME-C
     BROWSE-30 AT ROW 1 COL 1.13
     B-mark-5 AT ROW 10 COL 1.13
     B-mark-6 AT ROW 10 COL 4.25
     B-mark-7 AT ROW 10 COL 7.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 2
         SIZE 62.13 BY 10.
DEFINE FRAME FRAME-Postavki
     BROWSE-21 AT ROW 1 COL 1
     BROWSE-29 AT ROW 1 COL 26.38
     BROWSE-22 AT ROW 1 COL 63.25
     B-make-trn AT ROW 10.21 COL 1.5
     BUTTON-50 AT ROW 10.21 COL 10.5
     BUTTON-52 AT ROW 10.21 COL 18.63
     BUTTON-49 AT ROW 10.21 COL 63.5
     BUTTON-51 AT ROW 10.21 COL 71.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 13.5
         SIZE 99.5 BY 10.6.
DEFINE FRAME FRAME-Post-prt
     BROWSE-34 AT ROW 1 COL 1
     BROWSE-35 AT ROW 1 COL 51
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.38 BY 10.58.
DEFINE FRAME FRAME-B
     BROWSE-14 AT ROW 1 COL 1
     T-obj AT ROW 10.25 COL 1.5
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1.13 ROW 13.54
         SIZE 99.75 BY 10.71.
DEFINE FRAME FRAME-I
     BROWSE-23 AT ROW 1 COL 1
     BROWSE-24 AT ROW 1 COL 38
     BUTTON-48 AT ROW 10.38 COL 1
     BUTTON-17 AT ROW 10.38 COL 10
     BUTTON-57 AT ROW 10.38 COL 18.25
     BUTTON-18 AT ROW 10.38 COL 26.25
     BUTTON-21 AT ROW 10.38 COL 53.75
     BUTTON-20 AT ROW 10.38 COL 61.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 26.25 ROW 1
         SIZE 74.13 BY 10.5.
DEFINE FRAME FRAME-H
     B-make-trn-2 AT ROW 10.5 COL 1.38
     BUTTON-58 AT ROW 10.5 COL 16.38
     BUTTON-59 AT ROW 10.5 COL 45.5
     BROWSE-15 AT ROW 1 COL 38
     BROWSE-20 AT ROW 1 COL 1
     BUTTON-7 AT ROW 10.5 COL 9.38
     BUTTON-8 AT ROW 10.5 COL 23.5
     BUTTON-15 AT ROW 10.5 COL 38.38
     BUTTON-14 AT ROW 10.5 COL 52.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 26.25 ROW 1
         SIZE 74.13 BY 10.5.
DEFINE FRAME FRAME-B-prt
     BROWSE-37 AT ROW 1 COL 1
     BROWSE-36 AT ROW 1 COL 50.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.5 BY 10.58.
DEFINE FRAME FRAME-A
     BROWSE-12 AT ROW 1 COL 1
     B-mark AT ROW 10.17 COL 1.13
     B-mark-3 AT ROW 10.17 COL 4.25
     B-mark-4 AT ROW 10.17 COL 7.5
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         PAGE-TOP SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 2 SCROLLABLE .
DEFINE FRAME FRAME-F
     BROWSE-16 AT ROW 1 COL 1
     B-ins-za AT ROW 10.25 COL 1
     B-za-3 AT ROW 10.25 COL 9
     B-reject AT ROW 10.25 COL 17
     B-isk AT ROW 10.25 COL 25.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         PAGE-BOTTOM SIDE-LABELS THREE-D
         AT COL 63 ROW 2 SCROLLABLE .
DEFINE FRAME FRAME-d-prt
     BROWSE-31 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 63 ROW 2
         SIZE 37.75 BY 9.5.
ASSIGN FRAME FRAME-A:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-B:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-B-prt:FRAME = FRAME FRAME-B:HANDLE
       FRAME FRAME-C:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-D:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-d-prt:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-E:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-E-prt:FRAME = FRAME FRAME-E:HANDLE
       FRAME FRAME-F:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-H:FRAME = FRAME FRAME-B:HANDLE
       FRAME FRAME-I:FRAME = FRAME FRAME-B:HANDLE
       FRAME FRAME-J:FRAME = FRAME FRAME-E:HANDLE
       FRAME FRAME-K:FRAME = FRAME FRAME-E:HANDLE
       FRAME FRAME-Post-prt:FRAME = FRAME FRAME-Postavki:HANDLE
       FRAME FRAME-Postavki:FRAME = FRAME Dialog-Frame:HANDLE.
DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.
ASSIGN XXTABVALXX = FRAME FRAME-A:MOVE-AFTER-TAB-ITEM (B-Help:HANDLE IN FRAME Dialog-Frame)
       XXTABVALXX = FRAME FRAME-A:MOVE-BEFORE-TAB-ITEM (R-main:HANDLE IN FRAME Dialog-Frame)
.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       loc-ord-cons-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-gds:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       FRAME FRAME-A:BOX-SELECTABLE   = TRUE
       FRAME FRAME-A:SCROLLABLE       = FALSE.
ASSIGN
       BROWSE-12:NUM-LOCKED-COLUMNS IN FRAME FRAME-A     = 2.
ASSIGN XXTABVALXX = FRAME FRAME-B-prt:MOVE-AFTER-TAB-ITEM (BROWSE-14:HANDLE IN FRAME FRAME-B)
       XXTABVALXX = FRAME FRAME-I:MOVE-BEFORE-TAB-ITEM (T-obj:HANDLE IN FRAME FRAME-B)
       XXTABVALXX = FRAME FRAME-H:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-I:HANDLE)
       XXTABVALXX = FRAME FRAME-B-prt:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-H:HANDLE)
.
ASSIGN
       FRAME FRAME-B:HIDDEN           = TRUE.
ASSIGN
       FRAME FRAME-B-prt:HIDDEN           = TRUE.
ASSIGN
       FRAME FRAME-C:HIDDEN           = TRUE.
ASSIGN
       B-mark-5:HIDDEN IN FRAME FRAME-C           = TRUE.
ASSIGN
       B-mark-6:HIDDEN IN FRAME FRAME-C           = TRUE.
ASSIGN
       B-mark-7:HIDDEN IN FRAME FRAME-C           = TRUE.
ASSIGN
       FRAME FRAME-D:HIDDEN           = TRUE.
ASSIGN
       FRAME FRAME-d-prt:BOX-SELECTABLE   = TRUE
       FRAME FRAME-d-prt:HIDDEN           = TRUE.
ASSIGN XXTABVALXX = FRAME FRAME-E-prt:MOVE-AFTER-TAB-ITEM (BROWSE-17:HANDLE IN FRAME FRAME-E)
       XXTABVALXX = FRAME FRAME-K:MOVE-BEFORE-TAB-ITEM (T-cli:HANDLE IN FRAME FRAME-E)
       XXTABVALXX = FRAME FRAME-J:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-K:HANDLE)
       XXTABVALXX = FRAME FRAME-E-prt:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-J:HANDLE)
.
ASSIGN
       FRAME FRAME-E:HIDDEN           = TRUE.
ASSIGN
       FRAME FRAME-E-prt:HIDDEN           = TRUE.
ASSIGN
       FRAME FRAME-F:SCROLLABLE       = FALSE
       FRAME FRAME-F:HIDDEN           = TRUE.
ASSIGN
       FRAME FRAME-H:HIDDEN           = TRUE.
ASSIGN
       B-make-trn-2:POPUP-MENU IN FRAME FRAME-H       = MENU POPUP-MENU-B-make-trn-2:HANDLE.
ASSIGN
       BUTTON-15:HIDDEN IN FRAME FRAME-H           = TRUE.
ASSIGN
       BUTTON-59:HIDDEN IN FRAME FRAME-H           = TRUE.
ASSIGN
       FRAME FRAME-I:HIDDEN           = TRUE.
ASSIGN
       BUTTON-48:POPUP-MENU IN FRAME FRAME-I       = MENU POPUP-MENU-BUTTON-48:HANDLE.
ASSIGN
       FRAME FRAME-J:HIDDEN           = TRUE.
ASSIGN
       B-make-post-ex-2:POPUP-MENU IN FRAME FRAME-J       = MENU POPUP-MENU-B-make-post-ex-2:HANDLE.
ASSIGN
       FRAME FRAME-K:HIDDEN           = TRUE.
ASSIGN
       B-make-post-ex-3:POPUP-MENU IN FRAME FRAME-K       = MENU POPUP-MENU-B-make-post-ex-3:HANDLE.
ASSIGN
       FRAME FRAME-Post-prt:HIDDEN           = TRUE.
ASSIGN XXTABVALXX = FRAME FRAME-Post-prt:MOVE-AFTER-TAB-ITEM (BROWSE-21:HANDLE IN FRAME FRAME-Postavki)
       XXTABVALXX = FRAME FRAME-Post-prt:MOVE-BEFORE-TAB-ITEM (BROWSE-29:HANDLE IN FRAME FRAME-Postavki)
.
ASSIGN
       FRAME FRAME-Postavki:HIDDEN           = TRUE.
ASSIGN
       B-make-trn:POPUP-MENU IN FRAME FRAME-Postavki       = MENU POPUP-MENU-B-make-trn:HANDLE.
ON ALT-1 OF FRAME Dialog-Frame
anywhere
DO:
    apply  "CHOOSE":U   to  button-2 in frame Dialog-frame.
END.
ON ALT-2 OF FRAME Dialog-Frame
anywhere
DO:
  apply  "CHOOSE":U   to  button-3 in frame Dialog-frame.
END.
ON ALT-3 OF FRAME Dialog-Frame
anywhere
DO:
  apply  "CHOOSE":U   to  button-47 in frame Dialog-frame.
END.
ON ALT-7 OF FRAME Dialog-Frame
DO:
frame  frame-d:selectable = false .
frame  frame-d:resizable = false .
frame  frame-d:movable = false .
frame  frame-d:bgcolor = ? .
browse-13:selectable = false .
browse-13:resizable = false .
browse-13:movable = false .
frame  frame-f:selectable = false .
frame  frame-f:resizable = false .
frame  frame-f:movable = false .
frame  frame-f:bgcolor = ? .
browse-16:selectable = false .
browse-16:resizable = false .
browse-16:movable = false .
frame  frame-a:selectable = false .
frame  frame-a:resizable = false .
frame  frame-a:movable = false .
frame  frame-a:bgcolor = ? .
browse-12:selectable = false .
browse-12:resizable = false .
browse-12:movable = false .
display  browse-16 with frame frame-f .
display  browse-12 with frame frame-a .
END.
ON ALT-8 OF FRAME Dialog-Frame
DO:
frame  frame-a:selectable = true .
frame  frame-a:resizable = true .
frame  frame-a:movable = true .
frame  frame-a:bgcolor = 5 .
browse-12:selectable = true .
browse-12:resizable = true .
browse-12:movable = true .
frame frame-d:MOVE-TO-BOTTOM ( )  .
frame frame-f:MOVE-TO-BOTTOM ( )  .
frame frame-a:MOVE-TO-TOP ( )  .
frame frame-a:TOP-ONLY  .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-ins-za IN FRAME FRAME-F
DO:
  run proc-b-ins-za in this-procedure .
END.
ON CHOOSE OF B-isk IN FRAME FRAME-F
DO:
   run status-isk in this-procedure .
END.
ON CHOOSE OF B-mark IN FRAME FRAME-A
OR MOUSE-SELECT-DBLCLICK OF BROWSE-12 IN FRAME frame-A
DO:
  run p-mark in this-procedure .
END.
ON CHOOSE OF B-mark-2 IN FRAME FRAME-J
OR MOUSE-SELECT-DBLCLICK OF BROWSE-18 IN FRAME frame-J
DO:
  run local-mark in this-procedure .
END.
ON CHOOSE OF B-mark-3 IN FRAME FRAME-A
DO:
  run del-mark in this-procedure .
END.
ON CHOOSE OF B-mark-4 IN FRAME FRAME-A
DO:
  run plus-mark in this-procedure .
END.
ON CHOOSE OF B-mark-5 IN FRAME FRAME-C
OR MOUSE-SELECT-DBLCLICK OF BROWSE-12 IN FRAME frame-A
DO:
  run p-mark in this-procedure .
END.
ON CHOOSE OF B-mark-6 IN FRAME FRAME-C
DO:
  run del-mark in this-procedure .
END.
ON CHOOSE OF B-mark-7 IN FRAME FRAME-C
DO:
  run plus-mark in this-procedure .
END.
ON CHOOSE OF B-OK IN FRAME Dialog-Frame
DO:
   run proc-b-ok in this-procedure .
END.
ON CHOOSE OF B-reject IN FRAME FRAME-F
DO:
   run status-rej in this-procedure .
END.
ON CHOOSE OF B-za-3 IN FRAME FRAME-F
DO:
g#type = 'ОФ':U.
br-handle = browse-13:handle in frame frame-d.
run zayvka in this-procedure ("lkp":U).
if br-handle = ? then reposition browse-13 to recid doc-rec no-error.
END.
ON ROW-DISPLAY OF BROWSE-12 IN FRAME FRAME-A
DO:
  run proc-row-br-12 in this-procedure .
END.
ON VALUE-CHANGED OF BROWSE-12 IN FRAME FRAME-A
DO:
 run br-12 in this-procedure .
END.
on F9 of frame dialog-frame anywhere do:
  run show-gds in this-procedure .
  return no-apply.
END.
ON VALUE-CHANGED OF BROWSE-13 IN FRAME FRAME-D
DO:
     if frame FRAME-postavki:visible and avail ub.ord-doc and not T-of  then do:
      BROWSE-29:title = "Арт."  + x-artic  + " заявка "
     + ub.ord-doc.doc-code + " " + ub.ord-doc.obj-type + string(ub.ord-doc.obj-code).
      OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
 end.
END.
ON VALUE-CHANGED OF BROWSE-14 IN FRAME FRAME-B
DO:
  run proc-browse-14 in this-procedure .
END.
ON VALUE-CHANGED OF BROWSE-16 IN FRAME FRAME-F
DO:
  run proc-br-16 in this-procedure .
END.
ON ROW-DISPLAY OF BROWSE-17 IN FRAME FRAME-E
DO:
  if ub.cli-gds.price-cli <> 0 then
  buf_clients.obj-name:fgcolor in browse browse-17 = blue_color.
END.
ON VALUE-CHANGED OF BROWSE-17 IN FRAME FRAME-E
DO:
if frame FRAME-J:visible then do:
   run init-ord-gds in this-procedure  .
  OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
  OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
  end.
END.
ON ROW-DISPLAY OF BROWSE-18 IN FRAME FRAME-J
DO:
  run proc-color-status in this-procedure ( 18 , (IF (ub.ord-doc.status_ = 'факт':U or ub.ord-doc.status_ = 'закрыто':U) THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,'+/-')) ELSE (ub.ord-doc.status_) ) ) .
END.
ON VALUE-CHANGED OF BROWSE-18 IN FRAME FRAME-J
DO:
   run proc-br-18 in this-procedure .
END.
ON VALUE-CHANGED OF BROWSE-21 IN FRAME FRAME-Postavki
DO:
    OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .
END.
ON ROW-DISPLAY OF BROWSE-26 IN FRAME FRAME-K
DO:
  run proc-color-status in this-procedure ( 26 , (IF (ub.ord-doc.status_ = 'факт':U or ub.ord-doc.status_ = 'закрыто':U) THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,'+/-')) ELSE (ub.ord-doc.status_) ) ) .
END.
ON VALUE-CHANGED OF BROWSE-26 IN FRAME FRAME-K
DO:
run proc-browse-26 in this-procedure .
END.
ON ROW-DISPLAY OF BROWSE-27 IN FRAME FRAME-K
DO:
    run proc-color-status in this-procedure  ( 27 , (IF (ub.ord-doc-rcv.status_ = 'факт':U or ub.ord-doc-rcv.status_ = 'закрыто':U) THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,'+/-')) ELSE (ub.ord-doc-rcv.status_) ) ) .
END.
ON ROW-DISPLAY OF BROWSE-28 IN FRAME FRAME-J
DO:
  run proc-color-status in this-procedure ( 28 ,  (IF (ub.ord-doc-rcv.status_ = 'факт':U or ub.ord-doc-rcv.status_ = 'закрыто':U) THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,'+/-')) ELSE (ub.ord-doc-rcv.status_) )  ) .
END.
ON VALUE-CHANGED OF BROWSE-29 IN FRAME FRAME-Postavki
DO:
  OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .
END.
ON ROW-DISPLAY OF BROWSE-30 IN FRAME FRAME-C
DO:
run proc-color-str in this-procedure .
END.
ON VALUE-CHANGED OF BROWSE-30 IN FRAME FRAME-C
DO:
 run br-12 in this-procedure .
END.
ON CHOOSE OF BUTTON-10 IN FRAME FRAME-J
DO:
  run proc-but-10 in this-procedure .
END.
ON CHOOSE OF BUTTON-14 IN FRAME FRAME-H
DO:
run proc-b-14 in this-procedure .
END.
ON CHOOSE OF BUTTON-15 IN FRAME FRAME-H
DO:
END.
ON CHOOSE OF BUTTON-17 IN FRAME FRAME-I
DO:
  run proc-but-17 in this-procedure .
END.
ON CHOOSE OF BUTTON-18 IN FRAME FRAME-I
DO:
run proc-but-18 in this-procedure .
END.
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame
DO:
   run proc-init-button-2 in this-procedure .
END.
ON CHOOSE OF BUTTON-20 IN FRAME FRAME-I
DO:
run proc-b-20 in this-procedure .
END.
ON CHOOSE OF BUTTON-21 IN FRAME FRAME-I
DO:
if available ub.trn-doc
then do:
  case ub.trn-doc.doc-type
  :
    when 'при':U
    then do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
        "Тип документа" ub.trn-doc.doc-type skip
        "Код документа" ub.trn-doc.doc-code skip
        view-as alert-box error .
      undo, return no-apply .
    end.
  end case .
  if not g#log then   return no-apply.
  run chg-trn in this-procedure .
end.
END.
ON CHOOSE OF BUTTON-27 IN FRAME FRAME-K
DO:
  g#type = 'ФП':U.
  run chg-ord-fp in this-procedure .
  g#log =  BROWSE-26:REFRESH() no-error .
END.
ON CHOOSE OF BUTTON-28 IN FRAME FRAME-K
DO:
  define variable d-rec as recid no-undo.
    g#log = no.
    find current ub.ord-doc no-lock no-error .
    if avail  ub.ord-doc then do:
          message "Удалить заказ №" ub.ord-doc.doc-code "?   Вы уверены ?"
                  view-as alert-box question buttons OK-Cancel update g#log.
            if g#log = false then return.
        if ub.ord-doc.status_ <> 'новый':U then do:
          message "Удалить можно только в статусе НОВЫЙ! "  view-as alert-box .
          return no-apply.
        end.
            if avail ub.ord-doc then do:
              d-rec = recid (ub.ord-doc).
              run del-zakaz-doc in this-procedure (d-rec) .
                  OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ФП':U and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code and ub.ord-doc.cli-type = buf_clients.obj-type))  NO-LOCK,       FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK.
            end.
    end.
END.
ON CHOOSE OF BUTTON-3 IN FRAME Dialog-Frame
DO:
run proc-init-button-3 in this-procedure .
END.
ON CHOOSE OF BUTTON-30 IN FRAME FRAME-K
DO:
define variable v-doc-mode as character no-undo .
    if avail  ub.ord-doc-rcv then do:
     if ub.ord-doc-rcv.status_ = 'новый':U then do:
        run cus/or-obj.w
             ( input  parParentProc
             , input  ub.ord-doc-rcv.host-code
             , input  recid(ub.ord-doc-rcv)
             , input  3
             , input  'ИЗМЕНЕНИЕ':U
             , input  'ИЗМЕНЕНИЕ':U
             , input-output  v-doc-mode
             ) .
        g#log = BROWSE-27:refresh() no-error .
        run calc-cons-ord in this-procedure .
     end.
     else do:
        if ub.ord-doc-rcv.status_ = 'согласование':U
            then
                message "Статус поставки " ub.ord-doc-rcv.status_ ". Корректировать нельзя ."
                "Для проставления времени фактической доставки используйте другие режимы ! "
                view-as alert-box .
            else  message "Статус поставки " ub.ord-doc-rcv.status_ ". Корректировать нельзя !  "
                  view-as alert-box .
     end.
    end.
END.
ON CHOOSE OF BUTTON-31 IN FRAME FRAME-K
DO:
run proc-b-31 in this-procedure .
END.
ON CHOOSE OF BUTTON-33 IN FRAME FRAME-J
DO:
define variable v-doc-mode as character no-undo .
  if avail  ub.ord-line-rcv then do:
     find first ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code and
                                          ub.ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code no-error .
     if available  ub.ord-doc-rcv and ub.ord-doc-rcv.status_ = 'новый':U then do:
        v-doc-mode  = 'ИЗМЕНЕНИЕ':U .
        run cus/or-obj.w
             ( input  parParentProc
             , input  ub.ord-doc-rcv.host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  'ИЗМЕНЕНИЕ':U
             , input  'ИЗМЕНЕНИЕ':U
             , input-output  v-doc-mode  ) .
        g#log = BROWSE-28:refresh() no-error .
        run calc-cons-ord in this-procedure .
     end.
     else do:
        if ub.ord-doc-rcv.status_ = 'согласование':U
            then
                message "Статус поставки " ub.ord-doc-rcv.status_ ". Корректировать нельзя ."
                "Для проставления времени фактической доставки используйте другие режимы ! "
                view-as alert-box .
            else  message "Статус поставки " ub.ord-doc-rcv.status_ ". Корректировать нельзя !  "
                  view-as alert-box .
     end.
  end.
END.
ON CHOOSE OF BUTTON-34 IN FRAME FRAME-J
DO:
  define variable d-rec as recid no-undo.
    g#log = no.
    if avail  ub.ord-line-rcv then do:
    message "Удалить строку в поставке №" ub.ord-line-rcv.rcv-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update g#log.
      if g#log = false then return.
  d-rec = recid (ord-line-rcv).
  run del-post in this-procedure (d-rec) .
     OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
  end.
END.
ON ALT-3 OF BUTTON-47 IN FRAME Dialog-Frame
DO:
    apply  "CHOOSE":U   to  BUTTON-47 in frame Dialog-Frame.
END.
ON CHOOSE OF BUTTON-47 IN FRAME Dialog-Frame
DO:
run proc-init-button-47 in this-procedure .
END.
ON CHOOSE OF BUTTON-49 IN FRAME FRAME-Postavki
DO:
find current  ub.trn-doc no-lock  no-error .
if avail  ub.trn-doc
then do:
  case ub.trn-doc.doc-type
  :
    when 'при':U
    then do:
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
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
        "Тип документа" ub.trn-doc.doc-type skip
        "Код документа" ub.trn-doc.doc-code skip
        view-as alert-box error .
      undo, return no-apply .
    end.
  end case .
  if not g#log then   return no-apply.
  run chg-trn in this-procedure .
End.
END.
ON CHOOSE OF BUTTON-50 IN FRAME FRAME-Postavki
DO:
  run proc-50 in this-procedure .
END.
ON CHOOSE OF BUTTON-51 IN FRAME FRAME-Postavki
DO:
run proc-b-51 in this-procedure .
END.
ON CHOOSE OF BUTTON-52 IN FRAME FRAME-Postavki
DO:
  run proc-522 in this-procedure .
END.
ON CHOOSE OF BUTTON-53 IN FRAME FRAME-K
DO:
  g#type = 'ФП':U.
line-mode = 'ПРОСМОТР':U.
br-handle = browse-26:handle in frame frame-k.
run zayvka in this-procedure ("lkp":U).
if br-handle = ? then reposition browse-26 to recid doc-rec no-error.
END.
ON CHOOSE OF BUTTON-54 IN FRAME FRAME-K
DO:
run proc-b-54 in this-procedure .
END.
ON CHOOSE OF BUTTON-55 IN FRAME FRAME-J
DO:
 line-mode = 'ПРОСМОТР':U.
 run chg-ord-line in this-procedure .
END.
ON CHOOSE OF BUTTON-56 IN FRAME FRAME-J
DO:
run proc-b-56 in this-procedure .
END.
ON CHOOSE OF BUTTON-57 IN FRAME FRAME-I
DO:
  run proc-52 in this-procedure .
END.
ON CHOOSE OF BUTTON-58 IN FRAME FRAME-H
DO:
run proc-b-58 in this-procedure .
END.
ON CHOOSE OF BUTTON-59 IN FRAME FRAME-H
DO:
END.
ON CHOOSE OF BUTTON-7 IN FRAME FRAME-H
DO:
run proc-b-7 In This-procedure .
END.
ON CHOOSE OF BUTTON-8 IN FRAME FRAME-H
DO:
 run proc-bt-8 in this-procedure  .
END.
ON CHOOSE OF BUTTON-9 IN FRAME FRAME-J
DO:
 line-mode = 'ИЗМЕНЕНИЕ':U.
 run chg-ord-line in this-procedure .
 g#log = BROWSE-18:refresh() in frame frame-j no-error .
END.
ON CHOOSE OF MENU-ITEM m_cr_post
DO:
  find current new-rcv no-lock no-error .
  if avail new-rcv  and recid(new-rcv) <> ? then do:
    run make-trn in this-procedure  (recid(new-rcv)).
    g#log = BROWSE-21:refresh() in frame frame-postavki no-error .
    OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .
    end.
END.
ON CHOOSE OF MENU-ITEM m_d_post
DO:
  run proc-m_d_post in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_H_0
DO:
   run post-4-gds in this-procedure  (input "m_H_0" ).
END.
ON CHOOSE OF MENU-ITEM m_H_2
DO:
   run post-4-gds in this-procedure  (input "m_H_2" ).
END.
ON CHOOSE OF MENU-ITEM m_H_3
DO:
find current b-all_ord-doc-rcv no-lock no-error .
  if avail b-all_ord-doc-rcv then do:
    run make-trn in this-procedure  (recid(b-all_ord-doc-rcv)).
    OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.
  end.
END.
ON CHOOSE OF MENU-ITEM m_I_3
DO:
find current ub.ord-doc-rcv no-lock no-error .
  if avail ub.ord-doc-rcv then do:
    run make-trn in this-procedure  (recid(ub.ord-doc-rcv)) .
    OPEN QUERY BROWSE-24 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK,              EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
  end.
END.
ON CHOOSE OF MENU-ITEM m_I_4
DO:
  run post-4 in this-procedure  .
END.
ON CHOOSE OF MENU-ITEM m_J_1
DO:
  run zakaz-2 in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_J_2
DO:
  run post-3 in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_J_4
DO:
   run zakaz-1 in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_k_2
DO:
  run zakaz-1-of in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_k_3
DO:
  run post-1 in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_k_4
DO:
  run post-2 in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_k_5
DO:
  run post-5 in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_post_1
DO:
  find current new-rcv no-lock no-error .
  if avail new-rcv then do:
      run att-rcv in this-procedure (recid(new-rcv)) no-error .
      g#log = BROWSE-21:refresh() in frame frame-postavki no-error .
      OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .
   end.
END.
ON CHOOSE OF MENU-ITEM m_post_2
DO:
find current ub.ord-doc-rcv no-lock no-error .
  if avail ub.ord-doc-rcv then do:
    run att-rcv in this-procedure (recid(ub.ord-doc-rcv)) no-error .
    OPEN QUERY BROWSE-24 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK,              EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
  end.
END.
ON VALUE-CHANGED OF R-main IN FRAME Dialog-Frame
DO:
  run pr-main in this-procedure .
END.
ON VALUE-CHANGED OF T-cli IN FRAME FRAME-E
DO:
assign frame frame-e t-cli .
if t-cli then do:
  OPEN QUERY BROWSE-17 FOR EACH buf_clients  WHERE ( buf_clients.sup-cons = true  OR buf_clients.sup-gds = true ) NO-LOCK,  FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code  AND ub.cli-gds.cli-type = buf_clients.obj-type and ub.cli-gds.host-code = g#host-code and    ub.cli-gds.artic = x-artic and   ub.cli-gds.prod-type = x-prod-type and   ub.cli-gds.prod-code = x-prod-code  OUTER-JOIN NO-LOCK.
  end.
  else do:
  OPEN QUERY BROWSE-17 FOR EACH ub.buf_clients       WHERE ( buf_clients.sup-cons = true  OR buf_clients.sup-gds = true ) NO-LOCK,       FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code   AND ub.cli-gds.cli-type = buf_clients.obj-type       AND ub.cli-gds.artic = x-artic and cli-gds.prod-type = x-prod-type and ub.cli-gds.host-code = g#host-code and cli-gds.prod-code = x-prod-code  NO-LOCK.
  end.
END.
ON VALUE-CHANGED OF T-cli-fp IN FRAME FRAME-E
DO:
assign frame frame-e t-cli-fp .
if frame FRAME-J:visible then do:
   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
end.
else do:
    OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ФП':U and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code and ub.ord-doc.cli-type = buf_clients.obj-type))  NO-LOCK,       FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK.
end.
END.
ON VALUE-CHANGED OF T-gds IN FRAME Dialog-Frame
DO:
run proc-t-gds in this-procedure .
END.
ON VALUE-CHANGED OF T-obj IN FRAME FRAME-B
DO:
  assign frame frame-B t-obj .
if t-obj then do:
  OPEN QUERY BROWSE-14 FOR EACH my-obj  ,     EACH buf_gds-obj         WHERE x-artic = buf_gds-obj.artic     and          x-prod-type  = buf_gds-obj.prod-type and          x-prod-code  = buf_gds-obj.prod-code and          buf_gds-obj.obj-code = my-obj.obj-code and          buf_gds-obj.obj-type = my-obj.obj-type  OUTER-JOIN NO-LOCK.
    BROWSE-14:title = "Все объекты" .
  end.
  else do:
  BROWSE-14:title = "Остатки товара по объектам" .
  OPEN QUERY BROWSE-14 FOR EACH my-obj NO-LOCK,              EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
  CURRENT-WINDOW :KEEP-FRAME-Z-ORDER  = true  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-12 :handle
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
def var sort-labelbrowse-18   as character no-undo .
def var sort-clmnbrowse-18    as handle    no-undo .
def var cur-clmnbrowse-18     as handle    no-undo .
def var cur-clmn-locbrowse-18 as integer   no-undo .
def var re-querybrowse-18     as logical   initial no no-undo .
on start-search, ctrl-o of browse-18 in frame frame-J do:
   run sort-brbrowse-18
     (input (if available ub.ord-doc
             then recid(ub.ord-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brbrowse-18 :
  define input parameter p-recid as recid no-undo .
  if re-querybrowse-18 = no then do:
    assign
       cur-clmnbrowse-18 = browse-18:current-column in frame frame-J
    .
    if sort-clmnbrowse-18 <> ? then sort-clmnbrowse-18:column-fgcolor = 0.
    if cur-clmnbrowse-18 = sort-clmnbrowse-18 then do:
      assign
         sort-labelbrowse-18 = ""
         sort-clmnbrowse-18 = ?
      .
     end.
     else do:
       assign
         sort-labelbrowse-18 = cur-clmnbrowse-18:label
         sort-clmnbrowse-18  = cur-clmnbrowse-18
         sort-clmnbrowse-18:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbrowse-18 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = browse-18:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbrowse-18 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbrowse-18 = cur-clmn-locbrowse-18 + 1
    .
  end.
  case sort-labelbrowse-18:
        when '+'  then DO:   assign     sort-column-name = "mark"   .   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .   . END.
        when '№ заказа'  then DO:   assign     sort-column-name = "tt-new-ord-line.doc-code"   .   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .   . END.
        when 'Заказать'  then DO:   assign     sort-column-name = "tt-new-ord-line.qnty"   .   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .   . END.
        when 'Кому'  then DO:   assign     sort-column-name = "string(ub.ord-doc.cli-type + ' ' + string(ub.ord-doc.cli-code))"   .   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .   . END.
        when 'Поставщик'  then DO:   assign     sort-column-name = "ub.ord-doc.cli-name"   .   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .   . END.
        when 'Статус'  then DO:   assign     sort-column-name = "(IF (ub.ord-doc.status_ = 'факт':U or ub.ord-doc.status_ = 'закрыто':U) THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,'+/-')) ELSE (ub.ord-doc.status_) )"   .   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .   . END.
        when 'Название'  then DO:   assign     sort-column-name = "ub.goods.gds-name"   .   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .   . END.
        when 'Артикул'  then DO:   assign     sort-column-name = "tt-new-ord-line.artic"   .   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
      if sort-labelbrowse-18 <> "" then do:
        assign
          cur-clmnbrowse-18:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbrowse-18 = ?
      .
    end.
  end case.
    if cur-clmn-locbrowse-18 <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbrowse-18') then do:
        run ch-clmnbrowse-18 in this-procedure (cur-clmn-locbrowse-18).
      end.
    end.
  if p-recid <> ? then do:
    reposition browse-18 to recid p-recid no-error.
    apply "value-changed" to browse-18 in frame frame-J.
  end.
  apply "entry" to browse-18 in frame frame-J.
END PROCEDURE.
procedure re-open-query-srt-clmnbrowse-18:
if cur-clmnbrowse-18 = ? then do:
   OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
end.
else do:
   assign re-querybrowse-18 = yes.
   run sort-brbrowse-18
     (input (if available ub.ord-doc
             then recid(ub.ord-doc)
             else ?
            )
     ).
   assign re-querybrowse-18 = no.
end.
end.
def var sort-labelbrowse-28   as character no-undo .
def var sort-clmnbrowse-28    as handle    no-undo .
def var cur-clmnbrowse-28     as handle    no-undo .
def var cur-clmn-locbrowse-28 as integer   no-undo .
def var re-querybrowse-28     as logical   initial no no-undo .
on start-search, ctrl-o of browse-28 in frame frame-J do:
   run sort-brbrowse-28
     (input (if available ub.ord-doc-rcv
             then recid(ub.ord-doc-rcv)
             else ?
            )
     ).
end.
PROCEDURE sort-brbrowse-28 :
  define input parameter p-recid as recid no-undo .
  if re-querybrowse-28 = no then do:
    assign
       cur-clmnbrowse-28 = browse-28:current-column in frame frame-J
    .
    if sort-clmnbrowse-28 <> ? then sort-clmnbrowse-28:column-fgcolor = 0.
    if cur-clmnbrowse-28 = sort-clmnbrowse-28 then do:
      assign
         sort-labelbrowse-28 = ""
         sort-clmnbrowse-28 = ?
      .
     end.
     else do:
       assign
         sort-labelbrowse-28 = cur-clmnbrowse-28:label
         sort-clmnbrowse-28  = cur-clmnbrowse-28
         sort-clmnbrowse-28:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbrowse-28 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = browse-28:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbrowse-28 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbrowse-28 = cur-clmn-locbrowse-28 + 1
    .
  end.
  case sort-labelbrowse-28:
        when 'Поставка'  then DO:   assign     sort-column-name = "ub.ord-doc-rcv.rcv-code"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Кол-во'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.qnty"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Куда'  then DO:   assign     sort-column-name = "(ub.ord-doc-rcv.obj-type + ' ' + string(ub.ord-doc-rcv.obj-code))"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Цена(руб.)'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.price-rubl"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Кол-во(е.и.п)'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.cli-qnty"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Цена (пост.)'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.price-cli"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Доставка'  then DO:   assign     sort-column-name = "ub.ord-doc-rcv.ship-date"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Артикул'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.artic"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Заказ'  then DO:   assign     sort-column-name = "ub.ord-doc-rcv.doc-code"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Статус'  then DO:   assign     sort-column-name = "(IF (ub.ord-doc-rcv.status_ = 'факт':U or ub.ord-doc-rcv.status_ = 'закрыто':U) THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,'+/-')) ELSE (ub.ord-doc-rcv.status_) )"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
        when 'Название товара'  then DO:   assign     sort-column-name = "ub.goods.gds-name"   .   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
      if sort-labelbrowse-28 <> "" then do:
        assign
          cur-clmnbrowse-28:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbrowse-28 = ?
      .
    end.
  end case.
    if cur-clmn-locbrowse-28 <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbrowse-28') then do:
        run ch-clmnbrowse-28 in this-procedure (cur-clmn-locbrowse-28).
      end.
    end.
  if p-recid <> ? then do:
    reposition browse-28 to recid p-recid no-error.
    apply "value-changed" to browse-28 in frame frame-J.
  end.
  apply "entry" to browse-28 in frame frame-J.
END PROCEDURE.
procedure re-open-query-srt-clmnbrowse-28:
if cur-clmnbrowse-28 = ? then do:
   OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
end.
else do:
   assign re-querybrowse-28 = yes.
   run sort-brbrowse-28
     (input (if available ub.ord-doc-rcv
             then recid(ub.ord-doc-rcv)
             else ?
            )
     ).
   assign re-querybrowse-28 = no.
end.
end.
def var sort-labelbrowse-29   as character no-undo .
def var sort-clmnbrowse-29    as handle    no-undo .
def var cur-clmnbrowse-29     as handle    no-undo .
def var cur-clmn-locbrowse-29 as integer   no-undo .
def var re-querybrowse-29     as logical   initial no no-undo .
on start-search, ctrl-o of browse-29 in frame FRAME-Postavki do:
   run sort-brbrowse-29
     (input (if available new-rcv
             then recid(new-rcv)
             else ?
            )
     ).
end.
PROCEDURE sort-brbrowse-29 :
  define input parameter p-recid as recid no-undo .
  if re-querybrowse-29 = no then do:
    assign
       cur-clmnbrowse-29 = browse-29:current-column in frame FRAME-Postavki
    .
    if sort-clmnbrowse-29 <> ? then sort-clmnbrowse-29:column-fgcolor = 0.
    if cur-clmnbrowse-29 = sort-clmnbrowse-29 then do:
      assign
         sort-labelbrowse-29 = ""
         sort-clmnbrowse-29 = ?
      .
     end.
     else do:
       assign
         sort-labelbrowse-29 = cur-clmnbrowse-29:label
         sort-clmnbrowse-29  = cur-clmnbrowse-29
         sort-clmnbrowse-29:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbrowse-29 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = browse-29:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbrowse-29 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbrowse-29 = cur-clmn-locbrowse-29 + 1
    .
  end.
  case sort-labelbrowse-29:
        when 'Куда'  then DO:   assign     sort-column-name = "(new-rcv.obj-type + ' ' + string(new-rcv.obj-code) )"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Кол-во'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.qnty"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Артикул'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.artic"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Доставка'  then DO:   assign     sort-column-name = "new-rcv.ship-date"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Факт'  then DO:   assign     sort-column-name = "new-rcv.fact-date"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Время'  then DO:   assign     sort-column-name = "string(new-rcv.ship-time,'HH:MM')"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when '№ пост-ки'  then DO:   assign     sort-column-name = "new-rcv.rcv-code"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Статус'  then DO:   assign     sort-column-name = "( IF (new-rcv.status_ = 'факт':U or new-rcv.status_ = 'закрыто':U)  THEN (new-rcv.status_ + string(new-rcv.flag_,+/-))  ELSE (new-rcv.status_) )"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when '№ заказа'  then DO:   assign     sort-column-name = "new-rcv.doc-code"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Тип'  then DO:   assign     sort-column-name = "( IF (new-rcv.doc-type = 'in':U) THEN ('внут') ELSE ('внеш') )"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Cсылка'  then DO:   assign     sort-column-name = "bb_ord-doc.cons-code"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Цена (руб.)'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.price-rubl"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Кол-во(пост)'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.cli-qnty"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
        when 'Цена (пост)'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.price-cli"   .   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
      if sort-labelbrowse-29 <> "" then do:
        assign
          cur-clmnbrowse-29:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbrowse-29 = ?
      .
    end.
  end case.
    if cur-clmn-locbrowse-29 <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbrowse-29') then do:
        run ch-clmnbrowse-29 in this-procedure (cur-clmn-locbrowse-29).
      end.
    end.
  if p-recid <> ? then do:
    reposition browse-29 to recid p-recid no-error.
    apply "value-changed" to browse-29 in frame FRAME-Postavki.
  end.
  apply "entry" to browse-29 in frame FRAME-Postavki.
END PROCEDURE.
procedure re-open-query-srt-clmnbrowse-29:
if cur-clmnbrowse-29 = ? then do:
   OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
end.
else do:
   assign re-querybrowse-29 = yes.
   run sort-brbrowse-29
     (input (if available new-rcv
             then recid(new-rcv)
             else ?
            )
     ).
   assign re-querybrowse-29 = no.
end.
end.
def var sort-labelbrowse-20   as character no-undo .
def var sort-clmnbrowse-20    as handle    no-undo .
def var cur-clmnbrowse-20     as handle    no-undo .
def var cur-clmn-locbrowse-20 as integer   no-undo .
def var re-querybrowse-20     as logical   initial no no-undo .
on start-search, ctrl-o of browse-20 in frame frame-h do:
   run sort-brbrowse-20
     (input (if available b-all_ord-doc-rcv
             then recid(b-all_ord-doc-rcv)
             else ?
            )
     ).
end.
PROCEDURE sort-brbrowse-20 :
  define input parameter p-recid as recid no-undo .
  if re-querybrowse-20 = no then do:
    assign
       cur-clmnbrowse-20 = browse-20:current-column in frame frame-h
    .
    if sort-clmnbrowse-20 <> ? then sort-clmnbrowse-20:column-fgcolor = 0.
    if cur-clmnbrowse-20 = sort-clmnbrowse-20 then do:
      assign
         sort-labelbrowse-20 = ""
         sort-clmnbrowse-20 = ?
      .
     end.
     else do:
       assign
         sort-labelbrowse-20 = cur-clmnbrowse-20:label
         sort-clmnbrowse-20  = cur-clmnbrowse-20
         sort-clmnbrowse-20:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbrowse-20 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = browse-20:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbrowse-20 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbrowse-20 = cur-clmn-locbrowse-20 + 1
    .
  end.
  case sort-labelbrowse-20:
        when '№ пост-ки'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.rcv-code"   .   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.   . END.
        when 'Куда'  then DO:   assign     sort-column-name = "( b-all_ord-doc-rcv.obj-type + ' ' + string(b-all_ord-doc-rcv.obj-code) )"   .   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.   . END.
        when 'Кол-во'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.qnty"   .   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.   . END.
        when 'Кол-во(пост.)'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.cli-qnty"   .   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.   . END.
        when 'С объекта'  then DO:   assign     sort-column-name = "( b-all_ord-doc-rcv.cli-type + ' ' + string(b-all_ord-doc-rcv.cli-code))"   .   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.   . END.
        when 'Цена (пост.)'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.price-cli"   .   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.   . END.
        when 'Цена (руб)'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.price-rubl"   .   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.   . END.
        when 'Артикул'  then DO:   assign     sort-column-name = "ub.ord-line-rcv.artic"   .   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.   . END.
        when 'Статус'  then DO:   assign     sort-column-name = "(IF (b-all_ord-doc-rcv.status_ = 'факт':U or b-all_ord-doc-rcv.status_ = 'закрыто':U)  THEN (b-all_ord-doc-rcv.status_ + string(b-all_ord-doc-rcv.flag_,+/-))  ELSE (b-all_ord-doc-rcv.status_) )"   .   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
      if sort-labelbrowse-20 <> "" then do:
        assign
          cur-clmnbrowse-20:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbrowse-20 = ?
      .
    end.
  end case.
    if cur-clmn-locbrowse-20 <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbrowse-20') then do:
        run ch-clmnbrowse-20 in this-procedure (cur-clmn-locbrowse-20).
      end.
    end.
  if p-recid <> ? then do:
    reposition browse-20 to recid p-recid no-error.
    apply "value-changed" to browse-20 in frame frame-h.
  end.
  apply "entry" to browse-20 in frame frame-h.
END PROCEDURE.
procedure re-open-query-srt-clmnbrowse-20:
if cur-clmnbrowse-20 = ? then do:
   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
end.
else do:
   assign re-querybrowse-20 = yes.
   run sort-brbrowse-20
     (input (if available b-all_ord-doc-rcv
             then recid(b-all_ord-doc-rcv)
             else ?
            )
     ).
   assign re-querybrowse-20 = no.
end.
end.
def var sort-labelbrowse-12   as character no-undo .
def var sort-clmnbrowse-12    as handle    no-undo .
def var cur-clmnbrowse-12     as handle    no-undo .
def var cur-clmn-locbrowse-12 as integer   no-undo .
def var re-querybrowse-12     as logical   initial no no-undo .
on start-search, ctrl-o of browse-12 in frame frame-a do:
   run sort-brbrowse-12
     (input (if available tt-goods
             then recid(tt-goods)
             else ?
            )
     ).
end.
PROCEDURE sort-brbrowse-12 :
  define input parameter p-recid as recid no-undo .
  if re-querybrowse-12 = no then do:
    assign
       cur-clmnbrowse-12 = browse-12:current-column in frame frame-a
    .
    if sort-clmnbrowse-12 <> ? then sort-clmnbrowse-12:column-fgcolor = 0.
    if cur-clmnbrowse-12 = sort-clmnbrowse-12 then do:
      assign
         sort-labelbrowse-12 = ""
         sort-clmnbrowse-12 = ?
      .
     end.
     else do:
       assign
         sort-labelbrowse-12 = cur-clmnbrowse-12:label
         sort-clmnbrowse-12  = cur-clmnbrowse-12
         sort-clmnbrowse-12:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbrowse-12 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = browse-12:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbrowse-12 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbrowse-12 = cur-clmn-locbrowse-12 + 1
    .
  end.
  case sort-labelbrowse-12:
        when tt-goods.use:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.use"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
        when tt-goods.artic:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.artic"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
        when tt-goods.gds-name:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.gds-name"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
        when tt-goods.sum-qnty:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.sum-qnty"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
        when tt-goods.sum-ord:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.sum-ord"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
        when tt-goods.sum-rcv:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.sum-rcv"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
        when tt-goods.sum-rcv-in:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.sum-rcv-in"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
        when tt-goods.unit-base:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.unit-base"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
        when tt-goods.unit-cli:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.unit-cli"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
        when tt-goods.sum-fact:label in browse browse-12 then DO:   assign     sort-column-name = "tt-goods.sum-fact"   .   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
      if sort-labelbrowse-12 <> "" then do:
        assign
          cur-clmnbrowse-12:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbrowse-12 = ?
      .
    end.
  end case.
    if cur-clmn-locbrowse-12 <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbrowse-12') then do:
        run ch-clmnbrowse-12 in this-procedure (cur-clmn-locbrowse-12).
      end.
    end.
  if p-recid <> ? then do:
    reposition browse-12 to recid p-recid no-error.
    apply "value-changed" to browse-12 in frame frame-a.
  end.
  apply "entry" to browse-12 in frame frame-a.
END PROCEDURE.
procedure re-open-query-srt-clmnbrowse-12:
if cur-clmnbrowse-12 = ? then do:
   OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
end.
else do:
   assign re-querybrowse-12 = yes.
   run sort-brbrowse-12
     (input (if available tt-goods
             then recid(tt-goods)
             else ?
            )
     ).
   assign re-querybrowse-12 = no.
end.
end.
  tt-goods.gds-name:resizable in browse BROWSE-12 = true .
  tt-goods.artic:resizable in browse BROWSE-12 = true .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find  ub.ord-cons exclusive-lock  where ub.ord-cons.cons-code = p-cons-code  .
  run init-proc in this-procedure .
  run enable_UI in this-procedure .
  run init-2 in this-procedure .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbrowse-18 as INT EXTENT 8 no-undo.
DEF VAR varmvibrowse-18       as INT no-undo.
DEF VAR varmvjbrowse-18       as INT no-undo.
DEF VAR varmvkbrowse-18       as INT no-undo.
DEF VAR varmvlbrowse-18       as INT no-undo.
DEF VAR move-elementbrowse-18 as INT no-undo.
def var jjbrowse-18           as int no-undo.
do varmvibrowse-18 = 1 to EXTENT(cur-clmn-numbrowse-18):
  ASSIGN cur-clmn-numbrowse-18[varmvibrowse-18] = varmvibrowse-18.
END.
RUN start-mv-clmnbrowse-18.
PROCEDURE start-mv-clmnbrowse-18:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE browse-18 do:
  RUN re-move-clmnbrowse-18 ( 1, 8).
END.
ON ctrl-cursor-left OF BROWSE browse-18 do:
  RUN re-move-clmnbrowse-18 (8, 1).
END.
PROCEDURE re-move-clmnbrowse-18:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibrowse-18 = 1 TO EXTENT(cur-clmn-numbrowse-18):
    if cur-clmn-numbrowse-18[varmvibrowse-18] = source-column THEN cur-clmn-numbrowse-18[varmvibrowse-18] = -1.
  END.
  if browse-18:MOVE-COLUMN(source-column, target-column) IN FRAME frame-j then.
  if source-column > target-column THEN
  DO varmvjbrowse-18 = source-column - 1 to target-column BY -1:
    DO varmvibrowse-18 = 1 TO EXTENT(cur-clmn-numbrowse-18):
        if cur-clmn-numbrowse-18[varmvibrowse-18] = varmvjbrowse-18 THEN DO:
          cur-clmn-numbrowse-18[varmvibrowse-18] = cur-clmn-numbrowse-18[varmvibrowse-18] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbrowse-18 = source-column + 1 to target-column:
    DO varmvibrowse-18 = 1 TO EXTENT(cur-clmn-numbrowse-18):
      if cur-clmn-numbrowse-18[varmvibrowse-18] = varmvjbrowse-18 THEN DO:
        cur-clmn-numbrowse-18[varmvibrowse-18] = cur-clmn-numbrowse-18[varmvibrowse-18] - 1.
      END.
    END.
  END.
  DO varmvibrowse-18 = 1 TO EXTENT(cur-clmn-numbrowse-18):
    if cur-clmn-numbrowse-18[varmvibrowse-18] = -1 THEN cur-clmn-numbrowse-18[varmvibrowse-18] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbrowse-18:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibrowse-18 = 1 TO EXTENT(cur-clmn-numbrowse-18):
    if cur-clmn-numbrowse-18[varmvibrowse-18] = cur-clmn-loc THEN move-elementbrowse-18 = varmvibrowse-18.
  END.
  RUN re-move-clmnbrowse-18 (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbrowse-18:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbrowse-18 = 1 to EXTENT(cur-clmn-numbrowse-18):
    RUN re-move-clmnbrowse-18 (cur-clmn-numbrowse-18[varmvlbrowse-18], varmvlbrowse-18).
  END.
  RUN start-mv-clmnbrowse-18.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbrowse-28 as INT EXTENT 11 no-undo.
DEF VAR varmvibrowse-28       as INT no-undo.
DEF VAR varmvjbrowse-28       as INT no-undo.
DEF VAR varmvkbrowse-28       as INT no-undo.
DEF VAR varmvlbrowse-28       as INT no-undo.
DEF VAR move-elementbrowse-28 as INT no-undo.
def var jjbrowse-28           as int no-undo.
do varmvibrowse-28 = 1 to EXTENT(cur-clmn-numbrowse-28):
  ASSIGN cur-clmn-numbrowse-28[varmvibrowse-28] = varmvibrowse-28.
END.
RUN start-mv-clmnbrowse-28.
PROCEDURE start-mv-clmnbrowse-28:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE browse-28 do:
  RUN re-move-clmnbrowse-28 ( 1, 11).
END.
ON ctrl-cursor-left OF BROWSE browse-28 do:
  RUN re-move-clmnbrowse-28 (11, 1).
END.
PROCEDURE re-move-clmnbrowse-28:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibrowse-28 = 1 TO EXTENT(cur-clmn-numbrowse-28):
    if cur-clmn-numbrowse-28[varmvibrowse-28] = source-column THEN cur-clmn-numbrowse-28[varmvibrowse-28] = -1.
  END.
  if browse-28:MOVE-COLUMN(source-column, target-column) IN FRAME frame-j then.
  if source-column > target-column THEN
  DO varmvjbrowse-28 = source-column - 1 to target-column BY -1:
    DO varmvibrowse-28 = 1 TO EXTENT(cur-clmn-numbrowse-28):
        if cur-clmn-numbrowse-28[varmvibrowse-28] = varmvjbrowse-28 THEN DO:
          cur-clmn-numbrowse-28[varmvibrowse-28] = cur-clmn-numbrowse-28[varmvibrowse-28] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbrowse-28 = source-column + 1 to target-column:
    DO varmvibrowse-28 = 1 TO EXTENT(cur-clmn-numbrowse-28):
      if cur-clmn-numbrowse-28[varmvibrowse-28] = varmvjbrowse-28 THEN DO:
        cur-clmn-numbrowse-28[varmvibrowse-28] = cur-clmn-numbrowse-28[varmvibrowse-28] - 1.
      END.
    END.
  END.
  DO varmvibrowse-28 = 1 TO EXTENT(cur-clmn-numbrowse-28):
    if cur-clmn-numbrowse-28[varmvibrowse-28] = -1 THEN cur-clmn-numbrowse-28[varmvibrowse-28] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbrowse-28:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibrowse-28 = 1 TO EXTENT(cur-clmn-numbrowse-28):
    if cur-clmn-numbrowse-28[varmvibrowse-28] = cur-clmn-loc THEN move-elementbrowse-28 = varmvibrowse-28.
  END.
  RUN re-move-clmnbrowse-28 (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbrowse-28:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbrowse-28 = 1 to EXTENT(cur-clmn-numbrowse-28):
    RUN re-move-clmnbrowse-28 (cur-clmn-numbrowse-28[varmvlbrowse-28], varmvlbrowse-28).
  END.
  RUN start-mv-clmnbrowse-28.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbrowse-12 as INT EXTENT 10 no-undo.
DEF VAR varmvibrowse-12       as INT no-undo.
DEF VAR varmvjbrowse-12       as INT no-undo.
DEF VAR varmvkbrowse-12       as INT no-undo.
DEF VAR varmvlbrowse-12       as INT no-undo.
DEF VAR move-elementbrowse-12 as INT no-undo.
def var jjbrowse-12           as int no-undo.
do varmvibrowse-12 = 1 to EXTENT(cur-clmn-numbrowse-12):
  ASSIGN cur-clmn-numbrowse-12[varmvibrowse-12] = varmvibrowse-12.
END.
RUN start-mv-clmnbrowse-12.
PROCEDURE start-mv-clmnbrowse-12:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE browse-12 do:
  RUN re-move-clmnbrowse-12 ( 2, 10).
END.
ON ctrl-cursor-left OF BROWSE browse-12 do:
  RUN re-move-clmnbrowse-12 (10, 2).
END.
PROCEDURE re-move-clmnbrowse-12:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibrowse-12 = 1 TO EXTENT(cur-clmn-numbrowse-12):
    if cur-clmn-numbrowse-12[varmvibrowse-12] = source-column THEN cur-clmn-numbrowse-12[varmvibrowse-12] = -1.
  END.
  if browse-12:MOVE-COLUMN(source-column, target-column) IN FRAME frame-a then.
  if source-column > target-column THEN
  DO varmvjbrowse-12 = source-column - 1 to target-column BY -1:
    DO varmvibrowse-12 = 1 TO EXTENT(cur-clmn-numbrowse-12):
        if cur-clmn-numbrowse-12[varmvibrowse-12] = varmvjbrowse-12 THEN DO:
          cur-clmn-numbrowse-12[varmvibrowse-12] = cur-clmn-numbrowse-12[varmvibrowse-12] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbrowse-12 = source-column + 1 to target-column:
    DO varmvibrowse-12 = 1 TO EXTENT(cur-clmn-numbrowse-12):
      if cur-clmn-numbrowse-12[varmvibrowse-12] = varmvjbrowse-12 THEN DO:
        cur-clmn-numbrowse-12[varmvibrowse-12] = cur-clmn-numbrowse-12[varmvibrowse-12] - 1.
      END.
    END.
  END.
  DO varmvibrowse-12 = 1 TO EXTENT(cur-clmn-numbrowse-12):
    if cur-clmn-numbrowse-12[varmvibrowse-12] = -1 THEN cur-clmn-numbrowse-12[varmvibrowse-12] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbrowse-12:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 2 then do:
    return .
  end.
  DO varmvibrowse-12 = 1 TO EXTENT(cur-clmn-numbrowse-12):
    if cur-clmn-numbrowse-12[varmvibrowse-12] = cur-clmn-loc THEN move-elementbrowse-12 = varmvibrowse-12.
  END.
  RUN re-move-clmnbrowse-12 (cur-clmn-loc, 2).
END PROCEDURE.
PROCEDURE mv-brw-defaultbrowse-12:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbrowse-12 = 2 to EXTENT(cur-clmn-numbrowse-12):
    RUN re-move-clmnbrowse-12 (cur-clmn-numbrowse-12[varmvlbrowse-12], varmvlbrowse-12).
  END.
  RUN start-mv-clmnbrowse-12.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbrowse-20 as INT EXTENT 10 no-undo.
DEF VAR varmvibrowse-20       as INT no-undo.
DEF VAR varmvjbrowse-20       as INT no-undo.
DEF VAR varmvkbrowse-20       as INT no-undo.
DEF VAR varmvlbrowse-20       as INT no-undo.
DEF VAR move-elementbrowse-20 as INT no-undo.
def var jjbrowse-20           as int no-undo.
do varmvibrowse-20 = 1 to EXTENT(cur-clmn-numbrowse-20):
  ASSIGN cur-clmn-numbrowse-20[varmvibrowse-20] = varmvibrowse-20.
END.
RUN start-mv-clmnbrowse-20.
PROCEDURE start-mv-clmnbrowse-20:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE browse-20 do:
  RUN re-move-clmnbrowse-20 ( 1, 10).
END.
ON ctrl-cursor-left OF BROWSE browse-20 do:
  RUN re-move-clmnbrowse-20 (10, 1).
END.
PROCEDURE re-move-clmnbrowse-20:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibrowse-20 = 1 TO EXTENT(cur-clmn-numbrowse-20):
    if cur-clmn-numbrowse-20[varmvibrowse-20] = source-column THEN cur-clmn-numbrowse-20[varmvibrowse-20] = -1.
  END.
  if browse-20:MOVE-COLUMN(source-column, target-column) IN FRAME frame-h then.
  if source-column > target-column THEN
  DO varmvjbrowse-20 = source-column - 1 to target-column BY -1:
    DO varmvibrowse-20 = 1 TO EXTENT(cur-clmn-numbrowse-20):
        if cur-clmn-numbrowse-20[varmvibrowse-20] = varmvjbrowse-20 THEN DO:
          cur-clmn-numbrowse-20[varmvibrowse-20] = cur-clmn-numbrowse-20[varmvibrowse-20] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbrowse-20 = source-column + 1 to target-column:
    DO varmvibrowse-20 = 1 TO EXTENT(cur-clmn-numbrowse-20):
      if cur-clmn-numbrowse-20[varmvibrowse-20] = varmvjbrowse-20 THEN DO:
        cur-clmn-numbrowse-20[varmvibrowse-20] = cur-clmn-numbrowse-20[varmvibrowse-20] - 1.
      END.
    END.
  END.
  DO varmvibrowse-20 = 1 TO EXTENT(cur-clmn-numbrowse-20):
    if cur-clmn-numbrowse-20[varmvibrowse-20] = -1 THEN cur-clmn-numbrowse-20[varmvibrowse-20] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbrowse-20:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibrowse-20 = 1 TO EXTENT(cur-clmn-numbrowse-20):
    if cur-clmn-numbrowse-20[varmvibrowse-20] = cur-clmn-loc THEN move-elementbrowse-20 = varmvibrowse-20.
  END.
  RUN re-move-clmnbrowse-20 (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbrowse-20:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbrowse-20 = 1 to EXTENT(cur-clmn-numbrowse-20):
    RUN re-move-clmnbrowse-20 (cur-clmn-numbrowse-20[varmvlbrowse-20], varmvlbrowse-20).
  END.
  RUN start-mv-clmnbrowse-20.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbrowse-29 as INT EXTENT 15 no-undo.
DEF VAR varmvibrowse-29       as INT no-undo.
DEF VAR varmvjbrowse-29       as INT no-undo.
DEF VAR varmvkbrowse-29       as INT no-undo.
DEF VAR varmvlbrowse-29       as INT no-undo.
DEF VAR move-elementbrowse-29 as INT no-undo.
def var jjbrowse-29           as int no-undo.
do varmvibrowse-29 = 1 to EXTENT(cur-clmn-numbrowse-29):
  ASSIGN cur-clmn-numbrowse-29[varmvibrowse-29] = varmvibrowse-29.
END.
RUN start-mv-clmnbrowse-29.
PROCEDURE start-mv-clmnbrowse-29:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE browse-29 do:
  RUN re-move-clmnbrowse-29 ( 1, 15).
END.
ON ctrl-cursor-left OF BROWSE browse-29 do:
  RUN re-move-clmnbrowse-29 (15, 1).
END.
PROCEDURE re-move-clmnbrowse-29:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibrowse-29 = 1 TO EXTENT(cur-clmn-numbrowse-29):
    if cur-clmn-numbrowse-29[varmvibrowse-29] = source-column THEN cur-clmn-numbrowse-29[varmvibrowse-29] = -1.
  END.
  if browse-29:MOVE-COLUMN(source-column, target-column) IN FRAME frame-postavki then.
  if source-column > target-column THEN
  DO varmvjbrowse-29 = source-column - 1 to target-column BY -1:
    DO varmvibrowse-29 = 1 TO EXTENT(cur-clmn-numbrowse-29):
        if cur-clmn-numbrowse-29[varmvibrowse-29] = varmvjbrowse-29 THEN DO:
          cur-clmn-numbrowse-29[varmvibrowse-29] = cur-clmn-numbrowse-29[varmvibrowse-29] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbrowse-29 = source-column + 1 to target-column:
    DO varmvibrowse-29 = 1 TO EXTENT(cur-clmn-numbrowse-29):
      if cur-clmn-numbrowse-29[varmvibrowse-29] = varmvjbrowse-29 THEN DO:
        cur-clmn-numbrowse-29[varmvibrowse-29] = cur-clmn-numbrowse-29[varmvibrowse-29] - 1.
      END.
    END.
  END.
  DO varmvibrowse-29 = 1 TO EXTENT(cur-clmn-numbrowse-29):
    if cur-clmn-numbrowse-29[varmvibrowse-29] = -1 THEN cur-clmn-numbrowse-29[varmvibrowse-29] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbrowse-29:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibrowse-29 = 1 TO EXTENT(cur-clmn-numbrowse-29):
    if cur-clmn-numbrowse-29[varmvibrowse-29] = cur-clmn-loc THEN move-elementbrowse-29 = varmvibrowse-29.
  END.
  RUN re-move-clmnbrowse-29 (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbrowse-29:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbrowse-29 = 1 to EXTENT(cur-clmn-numbrowse-29):
    RUN re-move-clmnbrowse-29 (cur-clmn-numbrowse-29[varmvlbrowse-29], varmvlbrowse-29).
  END.
  RUN start-mv-clmnbrowse-29.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI in this-procedure .
PROCEDURE att-rcv :
do
 on error undo, return error return-value
 :
define input parameter b-recid as recid no-undo .
define variable loc-ref-list as character no-undo .
define variable p-trn-code as character no-undo .
define buffer bub_ord-doc-rcv for ub.ord-doc-rcv .
define buffer loc_buf_ord-line-rcv for ub.ord-line-rcv .
define buffer loc_buf_doc-line for ub.doc-line .
find first bub_ord-doc-rcv  no-lock where recid( bub_ord-doc-rcv)  = b-recid no-error .
if not avail bub_ord-doc-rcv then do:
  message  "Не выбрана поставка !!! " view-as alert-box .
  return .
end.
if bub_ord-doc-rcv.status_ <> 'поставка':U then do:
  message "Нельзя сделать накладную на поставку в статусе " caps(bub_ord-doc-rcv.status_) view-as alert-box .
  return.
end.
define variable v-input-output as character no-undo .
run str/all-docs.w
 ( input  parparentproc
 ,input   bub_ord-doc-rcv.host-code
 ,input   bub_ord-doc-rcv.obj-type
 ,input   bub_ord-doc-rcv.obj-code
 ,input  'фирма':U
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  "b-sel":U
 ,input  ?
 ,input  false
 ,input  ?
 ,output loc-ref-list
 ).
if loc-ref-list = ? or loc-ref-list = ""  then return.
  find first ub.trn-doc no-lock where recid(trn-doc) = int(loc-ref-list) no-error .
  if available ub.trn-doc then  assign
                              p-trn-code = ub.trn-doc.doc-code
                              doc-rec = recid(trn-doc)
                              .
                       else  assign
                             p-trn-code = ?
                       .
define variable  j-trn as integer no-undo .
define variable  j-rcv as integer no-undo .
 j-trn = 0.
 j-rcv = 0.
 for each loc_buf_ord-line-rcv no-lock where loc_buf_ord-line-rcv.doc-code =  bub_ord-doc-rcv.doc-code and
                                             loc_buf_ord-line-rcv.rcv-code =  bub_ord-doc-rcv.rcv-code :
    j-rcv = j-rcv + 1.
    if can-find (first loc_buf_doc-line where loc_buf_doc-line.doc-code = ub.trn-doc.doc-code and
                       loc_buf_ord-line-rcv.artic =  loc_buf_doc-line.artic and
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
  run create-chain (
  bub_ord-doc-rcv.rcv-code
  ,'rcv'
  ,p-trn-code
  ,'trn'
  ,''
  ,''
  ).
  run calc-cons-ord In This-procedure .
end.
END PROCEDURE.
PROCEDURE br-12 :
do
 on error undo, return error return-value
 :
define variable p-recid as recid no-undo .
if avail tt-goods then do:
    assign
    x-artic       = tt-goods.artic
    x-prod-type   = tt-goods.prod-type
    x-prod-code   = tt-goods.prod-code
    x-node-code    = string(tt-goods.node-code)
    str-good = x-artic + " " + tt-goods.gds-name  + " (" + tt-goods.prt-name + ")"  .
    if tt-goods.gds-t = 'товар':U then assign
     x-node-code = "*"
     str-good = x-artic + " " + tt-goods.gds-name      .
     p-recid = recid(tt-goods).
 end.
else do:
  message "Совокупная Заявка пуста ! " view-as alert-box .
  return error.
end.
 display str-good with frame Dialog-Frame.
 IF frame FRAME-d:visible  Then do:
     OPEN QUERY BROWSE-13 FOR EACH ub.m_ord-line       WHERE x-artic      = m_ord-line.artic and x-prod-type  = m_ord-line.prod-type and x-prod-code  = m_ord-line.prod-code  NO-LOCK,       EACH ub.ord-doc WHERE ub.ord-doc.doc-code = m_ord-line.doc-code       AND ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK.
     apply "VALUE-CHANGED":U to BROWSE-13 in frame frame-D .
      OPEN QUERY BROWSE-14 FOR EACH my-obj NO-LOCK,              EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
      OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.    OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
end.
 IF frame FRAME-d-prt:visible  Then do:
     OPEN QUERY BROWSE-31 FOR EACH ub.of_ord-dtl       WHERE x-artic      = of_ord-dtl.artic and x-prod-type  = of_ord-dtl.prod-type and x-prod-code  = of_ord-dtl.prod-code and string(of_ord-dtl.node-code) MATCHES x-node-code NO-LOCK,       EACH ub.of_ord-doc OF ub.of_ord-dtl       WHERE of_ord-doc.cons-code = loc-ord-cons-code and of_ord-doc.doc-type = 'ОФ':U NO-LOCK,       EACH ub.gds-prt WHERE ub.gds-prt.node-code = of_ord-dtl.node-code NO-LOCK.
     apply "VALUE-CHANGED":U to BROWSE-31 in frame frame-D-prt .
end.
IF frame FRAME-E:visible  Then do:
  if t-prt = false then do:
      if not  t-cli then do:
        OPEN QUERY BROWSE-17 FOR EACH ub.buf_clients       WHERE ( buf_clients.sup-cons = true  OR buf_clients.sup-gds = true ) NO-LOCK,       FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code   AND ub.cli-gds.cli-type = buf_clients.obj-type       AND ub.cli-gds.artic = x-artic and cli-gds.prod-type = x-prod-type and ub.cli-gds.host-code = g#host-code and cli-gds.prod-code = x-prod-code  NO-LOCK.
        OPEN QUERY BROWSE-17 FOR EACH ub.buf_clients       WHERE ( buf_clients.sup-cons = true  OR buf_clients.sup-gds = true ) NO-LOCK,       FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code   AND ub.cli-gds.cli-type = buf_clients.obj-type       AND ub.cli-gds.artic = x-artic and cli-gds.prod-type = x-prod-type and ub.cli-gds.host-code = g#host-code and cli-gds.prod-code = x-prod-code  NO-LOCK.
        apply "VALUE-CHANGED":U to BROWSE-17 in frame frame-E .
      end.
  end.
  if t-prt = true  then do:
    OPEN QUERY BROWSE-32 FOR EACH e_fp_ord-dtl       WHERE x-artic      = e_fp_ord-dtl.artic and x-prod-type  = e_fp_ord-dtl.prod-type and x-prod-code  = e_fp_ord-dtl.prod-code and string(e_fp_ord-dtl.node-code) MATCHES x-node-code NO-LOCK,              EACH e_fp_ord-doc OF e_fp_ord-dtl where                        e_fp_ord-doc.cons-code = loc-ord-cons-code and                        e_fp_ord-doc.doc-type = 'ФП':U                       NO-LOCK,              first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl.node-code NO-LOCK.    OPEN QUERY BROWSE-33 FOR EACH e_fp_ord-dtl-rcv               WHERE x-artic      = e_fp_ord-dtl-rcv.artic and                     x-prod-type  = e_fp_ord-dtl-rcv.prod-type and                     x-prod-code  = e_fp_ord-dtl-rcv.prod-code and                     string(e_fp_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,              EACH e_fp_ord-doc-rcv                              where e_fp_ord-doc-rcv.rcv-code            = e_fp_ord-dtl-rcv.rcv-code and                                               e_fp_ord-doc-rcv.doc-code     = e_fp_ord-dtl-rcv.doc-code and                        e_fp_ord-doc-rcv.cons-code  = loc-ord-cons-code and                        e_fp_ord-doc-rcv.doc-type    = "out":U                       NO-LOCK,              first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl-rcv.node-code NO-LOCK.
    reposition browse-30 to recid p-recid no-error .
  end.
end.
IF frame FRAME-J:visible  Then do:
     BROWSE-18:title = "Заказы ФП по товару " + x-artic .
     OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
     apply "VALUE-CHANGED":U to BROWSE-18 in frame frame-J .
     BROWSE-28:title = "Поставки по товару " + x-artic .
     OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
end.
IF frame FRAME-B:visible  Then do:
  if t-prt = false then do:
      if not  t-obj then do:
        OPEN QUERY BROWSE-14 FOR EACH my-obj NO-LOCK,              EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
        OPEN QUERY BROWSE-14 FOR EACH my-obj NO-LOCK,              EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
        apply "VALUE-CHANGED":U to BROWSE-14 in frame frame-B .
      end.
      if  t-obj then do:
        OPEN QUERY BROWSE-14 FOR EACH my-obj  ,     EACH buf_gds-obj         WHERE x-artic = buf_gds-obj.artic     and          x-prod-type  = buf_gds-obj.prod-type and          x-prod-code  = buf_gds-obj.prod-code and          buf_gds-obj.obj-code = my-obj.obj-code and          buf_gds-obj.obj-type = my-obj.obj-type  OUTER-JOIN NO-LOCK.
        apply "VALUE-CHANGED":U to BROWSE-14 in frame frame-B .
      end.
  end.
  if t-prt = true then do:
      OPEN QUERY BROWSE-36 FOR EACH obj_ord-dtl-rcv     WHERE x-artic      = obj_ord-dtl-rcv.artic and           x-prod-type  = obj_ord-dtl-rcv.prod-type and           x-prod-code  = obj_ord-dtl-rcv.prod-code and           string(obj_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,            EACH obj_ord-doc-rcv           where obj_ord-doc-rcv.rcv-code     = obj_ord-dtl-rcv.rcv-code and                   obj_ord-doc-rcv.doc-code   = obj_ord-dtl-rcv.doc-code and                   obj_ord-doc-rcv.doc-type   = 'in' and                   obj_ord-doc-rcv.cons-code  = loc-ord-cons-code                  NO-LOCK,          first ub.gds-prt WHERE ub.gds-prt.node-code = obj_ord-dtl-rcv.node-code NO-LOCK.    OPEN QUERY BROWSE-37 FOR EACH obj_prt-obj               WHERE obj_prt-obj.is-term = true and                           x-artic      = obj_prt-obj.artic and                     x-prod-type  = obj_prt-obj.prod-type and                     x-prod-code  = obj_prt-obj.prod-code and                     string(obj_prt-obj.prt-code) MATCHES x-node-code NO-LOCK,              each ub.gds-prt WHERE ub.gds-prt.node-code = obj_prt-obj.prt-code NO-LOCK.
      reposition browse-30 to recid p-recid no-error .
  end.
end.
IF frame FRAME-H:visible  Then do:
     BROWSE-15:title = "Внутренние ПН по товару " + x-artic .
     OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.
     apply "VALUE-CHANGED":U to BROWSE-15 in frame frame-H .
     BROWSE-20:title = "Поставки по товару " + x-artic .
     OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
end.
IF frame FRAME-postavki:visible  Then do:
  if t-prt = true then do:
      OPEN QUERY BROWSE-34 FOR EACH l_rcv_ord-dtl-rcv               WHERE x-artic      = l_rcv_ord-dtl-rcv.artic and                     x-prod-type  = l_rcv_ord-dtl-rcv.prod-type and                     x-prod-code  = l_rcv_ord-dtl-rcv.prod-code and                     string(l_rcv_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,              EACH l_rcv_ord-doc-rcv             where l_rcv_ord-doc-rcv.rcv-code     = l_rcv_ord-dtl-rcv.rcv-code and                    l_rcv_ord-doc-rcv.doc-code   = l_rcv_ord-dtl-rcv.doc-code and                    l_rcv_ord-doc-rcv.cons-code  = loc-ord-cons-code                    NO-LOCK,              first ub.gds-prt WHERE ub.gds-prt.node-code = l_rcv_ord-dtl-rcv.node-code NO-LOCK.
      OPEN QUERY BROWSE-35 FOR EACH l_rcv_gds-dtl     WHERE x-artic      = l_rcv_gds-dtl.artic and           x-prod-type  = l_rcv_gds-dtl.prod-type and           x-prod-code  = l_rcv_gds-dtl.prod-code and           string(l_rcv_gds-dtl.prt-code) MATCHES x-node-code NO-LOCK,              EACH l_rcv_trn-doc where             l_rcv_trn-doc.doc-code   = l_rcv_gds-dtl.doc-code NO-LOCK,              each ub.gds-prt WHERE            ub.gds-prt.node-code = l_rcv_gds-dtl.prt-code NO-LOCK.
      reposition browse-30 to recid p-recid no-error .
  end.
end.
end.
END PROCEDURE.
PROCEDURE calc-cons-ord :
do
 on error undo, return error return-value
 :
define buffer locb-ord-doc  for ub.ord-doc .
define buffer locb-ord-line for ub.ord-line .
define buffer locb-ord-dtl  for ub.ord-dtl .
define buffer locb-rcv-doc  for ub.ord-doc-rcv .
define buffer locb-rcv-line for ub.ord-line-rcv .
define buffer locb-rcv-dtl  for ub.ord-dtl-rcv .
define buffer locb-z-doc    for ub.ord-doc .
define buffer locb-z-line   for ub.ord-line .
define buffer locb-z-dtl    for ub.ord-dtl .
define buffer locb-t-doc    for ub.trn-doc .
define buffer locb-t-line   for ub.doc-line .
define buffer locb-t-dtl    for ub.gds-dtl  .
find current tt-goods no-error .
if avail tt-goods then gg-recid =  recid(tt-goods) .
      for each tt-goods where tt-goods.gds-t = 'товар':U :
          tt-goods.sum-ord  = 0.
          for each  locb-ord-doc where locb-ord-doc.cons-code = loc-ord-cons-code   and
                                      locb-ord-doc.doc-type  = 'ФП':U
                                      no-lock  ,
              each locb-ord-line where locb-ord-doc.doc-code = locb-ord-line.doc-code  and
                                          tt-goods.artic     = locb-ord-line.artic     and
                                          tt-goods.prod-code = locb-ord-line.prod-code and
                                          tt-goods.prod-type = locb-ord-line.prod-type
                                          no-lock  :
            assign
              tt-goods.sum-ord  = tt-goods.sum-ord + locb-ord-line.qnty
            .
          end.
          tt-goods.sum-rcv  = 0 .
          for each  locb-rcv-doc where locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                      locb-rcv-doc.doc-type  = 'out':U
                                      no-lock  ,
              each locb-rcv-line where locb-rcv-doc.doc-code = locb-rcv-line.doc-code  and
                                        locb-rcv-doc.rcv-code = locb-rcv-line.rcv-code  and
                                        tt-goods.artic        = locb-rcv-line.artic     and
                                        tt-goods.prod-code    = locb-rcv-line.prod-code and
                                        tt-goods.prod-type    = locb-rcv-line.prod-type
                                        no-lock  :
            assign
              tt-goods.sum-rcv  = tt-goods.sum-rcv + locb-rcv-line.qnty
            .
          end.
          tt-goods.sum-rcv-in  = 0 .
          for each  locb-z-doc no-lock where
                                      locb-z-doc.cons-code = loc-ord-cons-code   and
                                      locb-z-doc.doc-type  = 'ОФ':U
                                      ,
              each locb-z-line no-lock where
                                        locb-z-doc.doc-code = locb-z-line.doc-code    and
                                        tt-goods.artic        = locb-z-line.artic     and
                                        tt-goods.prod-code    = locb-z-line.prod-code and
                                        tt-goods.prod-type    = locb-z-line.prod-type
                                        ,
              each  locb-rcv-doc no-lock where
                                      locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                      locb-rcv-doc.doc-type  = "in":U              and
                                      locb-rcv-doc.obj-code  = locb-z-doc.obj-code and
                                      locb-rcv-doc.obj-type  = locb-z-doc.obj-type
                                      ,
              each locb-rcv-line no-lock  where
                                        locb-rcv-doc.doc-code = locb-rcv-line.doc-code  and
                                        locb-rcv-doc.rcv-code = locb-rcv-line.rcv-code  and
                                        tt-goods.artic        = locb-rcv-line.artic     and
                                        tt-goods.prod-code    = locb-rcv-line.prod-code and
                                        tt-goods.prod-type    = locb-rcv-line.prod-type
                                        :
            assign
              tt-goods.sum-rcv-in  = tt-goods.sum-rcv-in + locb-rcv-line.qnty
            .
          end.
          for each  locb-z-doc no-lock where
                                      locb-z-doc.cons-code = loc-ord-cons-code   and
                                      locb-z-doc.doc-type  = 'ОФ':U
                                      ,
              each locb-z-line no-lock where
                                        locb-z-doc.doc-code = locb-z-line.doc-code    and
                                        tt-goods.artic        = locb-z-line.artic     and
                                        tt-goods.prod-code    = locb-z-line.prod-code and
                                        tt-goods.prod-type    = locb-z-line.prod-type
                                        ,
              each  locb-rcv-doc no-lock where
                                      locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                      locb-rcv-doc.doc-type  = "in":U              and
                                      locb-rcv-doc.cli-code  = locb-z-doc.obj-code and
                                      locb-rcv-doc.cli-type  = locb-z-doc.obj-type
                                      ,
              each locb-rcv-line no-lock  where
                                        locb-rcv-doc.doc-code = locb-rcv-line.doc-code  and
                                        locb-rcv-doc.rcv-code = locb-rcv-line.rcv-code  and
                                        tt-goods.artic        = locb-rcv-line.artic     and
                                        tt-goods.prod-code    = locb-rcv-line.prod-code and
                                        tt-goods.prod-type    = locb-rcv-line.prod-type
                                        :
            assign
              tt-goods.sum-rcv-in  = tt-goods.sum-rcv-in - locb-rcv-line.qnty
            .
          end.
          tt-goods.sum-fact    = 0 .
          for each  locb-rcv-doc no-lock where
                    locb-rcv-doc.cons-code = loc-ord-cons-code   and
                    locb-rcv-doc.doc-type  = 'out':U
                    ,
              each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = locb-rcv-doc.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                  and
                   ub.ord-chain.rel-doc-type = 'trn'
                   ,
              each locb-t-doc no-lock  where
                   locb-t-doc.doc-code = ub.ord-chain.rel-doc-code
                   ,
              each locb-t-line no-lock where
                    locb-t-line.doc-code     = locb-t-doc.doc-code and
                    locb-t-line.artic        = tt-goods.artic     and
                    locb-t-line.prod-code    = tt-goods.prod-code and
                    locb-t-line.prod-type    = tt-goods.prod-type :
            assign
              tt-goods.sum-fact  = tt-goods.sum-fact + locb-t-line.fact-qnty
            .
          end.
          for each  locb-rcv-doc no-lock where
                    locb-rcv-doc.cons-code = loc-ord-cons-code   and
                    locb-rcv-doc.doc-type  = "in":U   ,
              each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = locb-rcv-doc.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                  and
                   ub.ord-chain.rel-doc-type = 'trn'
                   ,
              each locb-t-doc no-lock  where
                    locb-t-doc.doc-code = ub.ord-chain.rel-doc-code  and
                    locb-t-doc.doc-type = 'при':U  ,
              each locb-t-line no-lock where
                    locb-t-doc.doc-code = locb-t-line.doc-code    and
                    locb-t-line.artic        = tt-goods.artic     and
                    locb-t-line.prod-code    = tt-goods.prod-code and
                    locb-t-line.prod-type    = tt-goods.prod-type :
            assign
              tt-goods.sum-fact  = tt-goods.sum-fact + locb-t-line.fact-qnty
            .
          end.
       end.
          for each tt-goods where tt-goods.gds-t <> 'товар':U :
              tt-goods.sum-ord  = 0.
              for each  locb-ord-doc where locb-ord-doc.cons-code = loc-ord-cons-code   and
                                          locb-ord-doc.doc-type  = 'ФП':U
                                          no-lock  ,
                  each locb-ord-dtl where locb-ord-doc.doc-code = locb-ord-dtl.doc-code   and
                                              tt-goods.node-code = locb-ord-dtl.node-code and
                                              tt-goods.artic     = locb-ord-dtl.artic     and
                                              tt-goods.prod-code = locb-ord-dtl.prod-code and
                                              tt-goods.prod-type = locb-ord-dtl.prod-type
                                              no-lock  :
                assign
                  tt-goods.sum-ord  = tt-goods.sum-ord + locb-ord-dtl.qnty
                .
              end.
              tt-goods.sum-rcv  = 0 .
              for each  locb-rcv-doc where locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                          locb-rcv-doc.doc-type  = 'out':U
                                          no-lock  ,
                  each locb-rcv-dtl where locb-rcv-doc.doc-code   = locb-rcv-dtl.doc-code  and
                                            locb-rcv-doc.rcv-code = locb-rcv-dtl.rcv-code  and
                                            tt-goods.node-code    = locb-rcv-dtl.node-code and
                                            tt-goods.artic        = locb-rcv-dtl.artic     and
                                            tt-goods.prod-code    = locb-rcv-dtl.prod-code and
                                            tt-goods.prod-type    = locb-rcv-dtl.prod-type
                                            no-lock  :
                assign
                  tt-goods.sum-rcv  = tt-goods.sum-rcv + locb-rcv-dtl.qnty
                .
              end.
              tt-goods.sum-rcv-in  = 0 .
              for each  locb-z-doc no-lock where
                                          locb-z-doc.cons-code = loc-ord-cons-code   and
                                          locb-z-doc.doc-type  = 'ОФ':U
                                          ,
                  each locb-z-dtl no-lock where
                                            locb-z-doc.doc-code   = locb-z-dtl.doc-code  and
                                            tt-goods.node-code    = locb-z-dtl.node-code and
                                            tt-goods.artic        = locb-z-dtl.artic     and
                                            tt-goods.prod-code    = locb-z-dtl.prod-code and
                                            tt-goods.prod-type    = locb-z-dtl.prod-type
                                            ,
                  each  locb-rcv-doc no-lock where
                                          locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                          locb-rcv-doc.doc-type  = "in":U              and
                                          locb-rcv-doc.obj-code  = locb-z-doc.obj-code and
                                          locb-rcv-doc.obj-type  = locb-z-doc.obj-type
                                          ,
                  each locb-rcv-dtl no-lock  where
                                            locb-rcv-dtl.doc-code  = locb-rcv-doc.doc-code and
                                            locb-rcv-dtl.rcv-code  = locb-rcv-doc.rcv-code and
                                            locb-rcv-dtl.node-code = tt-goods.node-code    and
                                            locb-rcv-dtl.artic     = tt-goods.artic        and
                                            locb-rcv-dtl.prod-code = tt-goods.prod-code    and
                                            locb-rcv-dtl.prod-type = tt-goods.prod-type
                                            :
                assign
                  tt-goods.sum-rcv-in  = tt-goods.sum-rcv-in + locb-rcv-dtl.qnty
                .
              end.
              for each  locb-z-doc no-lock where
                                          locb-z-doc.cons-code = loc-ord-cons-code   and
                                          locb-z-doc.doc-type  = 'ОФ':U
                                          ,
                  each locb-z-dtl no-lock where
                                            locb-z-doc.doc-code   = locb-z-dtl.doc-code  and
                                            tt-goods.node-code    = locb-z-dtl.node-code and
                                            tt-goods.artic        = locb-z-dtl.artic     and
                                            tt-goods.prod-code    = locb-z-dtl.prod-code and
                                            tt-goods.prod-type    = locb-z-dtl.prod-type
                                            ,
                  each  locb-rcv-doc no-lock where
                                          locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                          locb-rcv-doc.doc-type  = "in":U              and
                                          locb-rcv-doc.cli-code  = locb-z-doc.obj-code and
                                          locb-rcv-doc.cli-type  = locb-z-doc.obj-type
                                          ,
                  each locb-rcv-dtl no-lock  where
                                            locb-rcv-dtl.doc-code  = locb-rcv-doc.doc-code and
                                            locb-rcv-dtl.rcv-code  = locb-rcv-doc.rcv-code and
                                            locb-rcv-dtl.node-code = tt-goods.node-code    and
                                            locb-rcv-dtl.artic     = tt-goods.artic        and
                                            locb-rcv-dtl.prod-code = tt-goods.prod-code    and
                                            locb-rcv-dtl.prod-type = tt-goods.prod-type
                                            :
                assign
                  tt-goods.sum-rcv-in  = tt-goods.sum-rcv-in - locb-rcv-dtl.qnty
                .
              end.
              tt-goods.sum-fact    = 0 .
              for each  locb-rcv-doc no-lock where
                        locb-rcv-doc.cons-code = loc-ord-cons-code   and
                        locb-rcv-doc.doc-type  = 'out':U,
                  each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = locb-rcv-doc.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                 and
                        ub.ord-chain.rel-doc-type = 'trn' ,
                  each locb-t-doc no-lock  where
                       locb-t-doc.doc-code = ub.ord-chain.rel-doc-code  ,
                  each locb-t-dtl no-lock where
                        locb-t-dtl.doc-code     = locb-t-doc.doc-code and
                        locb-t-dtl.prt-code     = tt-goods.node-code  and
                        locb-t-dtl.artic        = tt-goods.artic      and
                        locb-t-dtl.prod-code    = tt-goods.prod-code  and
                        locb-t-dtl.prod-type    = tt-goods.prod-type  :
                assign
                  tt-goods.sum-fact  = tt-goods.sum-fact + locb-t-dtl.fact-qnty
                .
              end.
              for each  locb-rcv-doc no-lock where
                        locb-rcv-doc.cons-code = loc-ord-cons-code   and
                        locb-rcv-doc.doc-type  = "in":U   ,
                  each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = locb-rcv-doc.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                 and
                        ub.ord-chain.rel-doc-type = 'trn' ,
                  each locb-t-doc no-lock  where
                       locb-t-doc.doc-code = ub.ord-chain.rel-doc-code  and
                       locb-t-doc.doc-type = 'при':U ,
                  each locb-t-dtl no-lock where
                        locb-t-dtl.doc-code     = locb-t-doc.doc-code and
                        locb-t-dtl.prt-code     = tt-goods.node-code  and
                        locb-t-dtl.artic        = tt-goods.artic      and
                        locb-t-dtl.prod-code    = tt-goods.prod-code  and
                        locb-t-dtl.prod-type    = tt-goods.prod-type  :
                assign
                  tt-goods.sum-fact  = tt-goods.sum-fact + locb-t-dtl.fact-qnty
                .
              end.
          end.
   if not t-prt then
     g#log = BROWSE-12:refresh() in frame frame-a no-error .
   else
     g#log = BROWSE-30:refresh() in frame frame-c no-error .
end.
END PROCEDURE.
PROCEDURE chg-ord-fp :
do
 on error undo, return error return-value
 :
find current ub.ord-doc no-lock no-error .
if avail ub.ord-doc and ub.ord-doc.status_ <> 'новый':U then do:
    message  "Нельзя корректировать в статусе" caps(ub.ord-doc.status_) view-as alert-box information .
    return.
    end.
if avail ub.ord-doc and ub.ord-doc.status_ = 'новый':U then do:
    g#type = 'ФП':U .
    run zayvka in this-procedure  ("chg":U).
    end.
if not  avail ub.ord-doc then do :
    message "Заказ не выбран !!! " .
    return.
    End.
end.
END PROCEDURE.
PROCEDURE chg-ord-line :
 do
 on error undo, return error return-value
 :
 define variable  r-tmp as recid   no-undo .
 define variable r-stop as logical no-undo .
 define variable r-exit as logical no-undo .
 find current tt-new-ord-line no-lock no-error .
 find first ub.ord-doc no-lock where ub.ord-doc.doc-code = tt-new-ord-line.doc-code no-error .
 if avail ub.ord-doc  and ub.ord-doc.status_ <> 'новый':U and line-mode <> 'ПРОСМОТР':U then do:
      message "Заказ " ub.ord-doc.doc-code " уже закрыт до статуса " ub.ord-doc.status_ " Изменения невозможны ! " view-as alert-box .
      return.
 end.
 for each TMP#zakaz :
    delete TMP#zakaz .
 end.
   if avail tt-new-ord-line then do:
     find first  tmp#zakaz where
            TMP#zakaz.artic                 = tt-new-ord-line.artic and
            TMP#zakaz.prod-code             = tt-new-ord-line.prod-code and
            TMP#zakaz.prod-type             = tt-new-ord-line.prod-type no-error .
      if not available Tmp#zakaz then do:
          create TMP#zakaz.
          end.
      assign
            TMP#zakaz.SLT-pc                = tt-new-ord-line.SLT-pc
            TMP#zakaz.VAT-pc                = tt-new-ord-line.VAT-pc
            TMP#zakaz.add-cli-qnty          = tt-new-ord-line.add-cli-qnty
            TMP#zakaz.add-qnty              = tt-new-ord-line.add-qnty
            TMP#zakaz.artic                 = tt-new-ord-line.artic
            TMP#zakaz.prod-code             = tt-new-ord-line.prod-code
            TMP#zakaz.prod-type             = tt-new-ord-line.prod-type
            TMP#zakaz.cancel-cli-qnty       = tt-new-ord-line.cancel-cli-qnty
            TMP#zakaz.cancel-date           = tt-new-ord-line.cancel-date
            TMP#zakaz.cancel-qnty           = tt-new-ord-line.cancel-qnty
            TMP#zakaz.cli-art               = tt-new-ord-line.cli-art
            TMP#zakaz.cli-base-rate         = tt-new-ord-line.cli-base-rate
            TMP#zakaz.cli-qnty              = tt-new-ord-line.cli-qnty
            TMP#zakaz.doc-code              = tt-new-ord-line.doc-code
            TMP#zakaz.excise                = tt-new-ord-line.excise
            TMP#zakaz.fact-date             = tt-new-ord-line.fact-date
            TMP#zakaz.initial-cli-qnty      = tt-new-ord-line.initial-cli-qnty
            TMP#zakaz.initial-qnty          = tt-new-ord-line.initial-qnty
            TMP#zakaz.line-num              = tt-new-ord-line.line-num
            TMP#zakaz.order-cli-qnty        = tt-new-ord-line.order-cli-qnty
            TMP#zakaz.order-qnty            = tt-new-ord-line.order-qnty
            TMP#zakaz.other-base            = tt-new-ord-line.other-base
            TMP#zakaz.other-rubl            = tt-new-ord-line.other-rubl
            TMP#zakaz.price-base            = tt-new-ord-line.price-base
            TMP#zakaz.price-cli             = tt-new-ord-line.price-cli
            TMP#zakaz.price-rubl            = tt-new-ord-line.price-rubl
            TMP#zakaz.qnty                  = tt-new-ord-line.qnty
            TMP#zakaz.receive-cli-qnty      = tt-new-ord-line.receive-cli-qnty
            TMP#zakaz.receive-qnty          = tt-new-ord-line.receive-qnty
            TMP#zakaz.road-tax              = tt-new-ord-line.road-tax
            TMP#zakaz.sum-SLT               = tt-new-ord-line.sum-SLT
            TMP#zakaz.sum-VAT               = tt-new-ord-line.sum-VAT
            TMP#zakaz.sum-base              = tt-new-ord-line.sum-base
            TMP#zakaz.sum-cli               = tt-new-ord-line.sum-cli
            TMP#zakaz.sum-excise            = tt-new-ord-line.sum-excise
            TMP#zakaz.sum-other-base        = tt-new-ord-line.sum-other-base
            TMP#zakaz.sum-other-rubl        = tt-new-ord-line.sum-other-rubl
            TMP#zakaz.sum-road-tax          = tt-new-ord-line.sum-road-tax
            TMP#zakaz.sum-rubl              = tt-new-ord-line.sum-rubl
            TMP#zakaz.sum-transport-base    = tt-new-ord-line.sum-transport-base
            TMP#zakaz.sum-transport-rubl    = tt-new-ord-line.sum-transport-rubl
            TMP#zakaz.transport-base        = tt-new-ord-line.transport-base
            TMP#zakaz.transport-rubl        = tt-new-ord-line.transport-rubl
            TMP#zakaz.unit-cli              = tt-new-ord-line.unit-cli
            TMP#zakaz.v-vat                 = tt-new-ord-line.v-vat
        .
    find first TMP#zakaz no-error .
    IF not avail TMP#zakaz then return no-apply.
    assign
      r-tmp = recid ( TMP#zakaz   )
      loc-status     = ub.ord-doc.status_
      doc-date       = ub.ord-doc.doc-date
      loc-date-ship  = ub.ord-doc.ship-date
      date-sale-1    = ub.ord-doc.date-sale-1
      date-sale-2    = ub.ord-doc.date-sale-2
      loc-exch-code  = ub.ord-doc.exch-code
      loc-exch-rate  = ub.ord-doc.exch-rate
      loc-exch-scale = ub.ord-doc.exch-scale
      loc-base-rate  = ub.ord-doc.base-rate
      loc-base-scale = ub.ord-doc.base-scale
      vat_type       = ub.ord-doc.vat-type
      slt_type       = ub.ord-doc.slt-type
      loc-cli-code =   ub.ord-doc.cli-code
      loc-cli-type =   ub.ord-doc.cli-type
      loc-ord-num  =   ub.ord-doc.doc-code
      no-error.
      if error-status :error
      then do:
           message  error-status :get-message(1) skip
           "при присвоении" skip
           .
           end.
    find first shar_ord-doc no-lock  where shar_ord-doc.doc-code = ord-doc.doc-code no-error .
    if loc-make-avto = false then do:
       run cus/ord-frm.w (input Parparentproc,  input r-tmp ,input line-mode , output r-stop, output r-exit ) .
    end.
    if line-mode <> 'ПРОСМОТР':U  then do:
       if  r-stop = false and r-exit = false  then do:
       run dop-pr in this-procedure .
        run calc-cons-ord in this-procedure .
       end.
    end.
    find current TMP#zakaz no-error  .
    if avail TMP#zakaz then delete TMP#zakaz.
end.
else do:
  message  "Не выбрана строка заказа !" view-as alert-box .
end.
end.
END PROCEDURE.
PROCEDURE chg-trn :
do
 on error undo, return error return-value
 :
if available ub.trn-doc then do:
   run str/showdoc.p
      (input parparentproc
      ,input ub.trn-doc.doc-code
      ,input ""
      ,input ""
      ,input 0
      ,input true
      ) .
end.
end.
END PROCEDURE.
PROCEDURE color-cell :
 do
 on error undo, return error return-value
 :
  define input parameter h-cell   as handle    no-undo .
  define input parameter p-color  as integer   no-undo .
  define input parameter h-status as character no-undo .
  define input parameter p-status as character no-undo .
  if  h-cell <> ?   and valid-handle(h-cell)
       then do:
      if h-status = p-status then do:
         h-cell:fgcolor = p-color .
      end.
  end.
  end.
END PROCEDURE.
PROCEDURE create-dtl-fp :
do
 on error undo, return error return-value
 :
define input parameter p_new-doc-code like ub.ord-doc.doc-code no-undo .
define input parameter p_file         as character no-undo .
define input parameter p_old-doc-code like ub.ord-doc.doc-code no-undo .
define input parameter p_artic     like   ub.ord-line.artic       no-undo .
define input parameter p_prod-type like   ub.ord-line.prod-type  no-undo .
define input parameter p_prod-code like   ub.ord-line.prod-code  no-undo .
define input parameter p-cli-base-rate like   ub.ord-line.cli-base-rate  no-undo .
define buffer new_ord-dtl    for ub.ord-dtl .
define buffer j_ord-dtl      for ub.ord-dtl .
define buffer j_ord-dtl-cons for ub.ord-dtl-cons .
define buffer loc-tt-goods   for tt-goods .
define variable loc-fact-qnty like ub.ord-line.qnty no-undo .
case  p_file  :
when "ord-of"  then do:
    for each  j_ord-dtl no-lock where
              j_ord-dtl.doc-code   = p_old-doc-code and
              j_ord-dtl.artic      = p_artic        and
              j_ord-dtl.prod-type  = p_prod-type    and
              j_ord-dtl.prod-code  = p_prod-code
              :
       find first loc-tt-goods no-lock   where
                  loc-tt-goods.gds-t <> 'товар':U and
                  loc-tt-goods.artic      = j_ord-dtl.artic      and
                  loc-tt-goods.node-code  = j_ord-dtl.node-code  and
                  loc-tt-goods.prod-code  = j_ord-dtl.prod-code  and
                  loc-tt-goods.prod-type  = j_ord-dtl.prod-type  no-error .
       if not available loc-tt-goods then  do:  next. end.
          loc-fact-qnty = loc-tt-goods.sum-qnty - (loc-tt-goods.sum-ord + loc-tt-goods.sum-rcv-in) .
       find first new_ord-dtl where
         new_ord-dtl.doc-code             = p_new-doc-code       and
         new_ord-dtl.artic                = j_ord-dtl.artic      and
         new_ord-dtl.node-code            = j_ord-dtl.node-code  and
         new_ord-dtl.prod-code            = j_ord-dtl.prod-code  and
         new_ord-dtl.prod-type            = j_ord-dtl.prod-type   exclusive-lock  no-error .
       if not available new_ord-dtl then  do:  create new_ord-dtl. end.
       assign
         new_ord-dtl.doc-code             = p_new-doc-code
         new_ord-dtl.add-cli-qnty         = j_ord-dtl.add-cli-qnty
         new_ord-dtl.add-qnty             = j_ord-dtl.add-qnty
         new_ord-dtl.artic                = j_ord-dtl.artic
         new_ord-dtl.prod-code            = j_ord-dtl.prod-code
         new_ord-dtl.prod-type            = j_ord-dtl.prod-type
         new_ord-dtl.node-code            = j_ord-dtl.node-code
         new_ord-dtl.cancel-cli-qnty      = j_ord-dtl.cancel-cli-qnty
         new_ord-dtl.cancel-qnty          = j_ord-dtl.cancel-qnty
         new_ord-dtl.initial-cli-qnty     = j_ord-dtl.initial-cli-qnty
         new_ord-dtl.initial-qnty         = j_ord-dtl.initial-qnty
         new_ord-dtl.order-cli-qnty       = j_ord-dtl.order-cli-qnty
         new_ord-dtl.order-qnty           = j_ord-dtl.order-qnty
         new_ord-dtl.price-base           = j_ord-dtl.price-base
         new_ord-dtl.price-cli            = j_ord-dtl.price-cli
         new_ord-dtl.price-rubl           = j_ord-dtl.price-rubl
         new_ord-dtl.receive-cli-qnty     = j_ord-dtl.receive-cli-qnty
         new_ord-dtl.receive-qnty         = j_ord-dtl.receive-qnty
         new_ord-dtl.qnty                 = minimum( j_ord-dtl.qnty , loc-fact-qnty )
         new_ord-dtl.cli-qnty             = new_ord-dtl.qnty / p-cli-base-rate
         new_ord-dtl.sum-base             = new_ord-dtl.qnty * new_ord-dtl.price-base
         new_ord-dtl.sum-cli              = new_ord-dtl.cli-qnty * new_ord-dtl.price-cli
         new_ord-dtl.sum-rubl             = new_ord-dtl.qnty * new_ord-dtl.price-rubl
       .
    end.
end.
when "ord-cons"  then do:
    for each  j_ord-dtl-cons no-lock  where
              j_ord-dtl-cons.cons-code   = p_old-doc-code and
              j_ord-dtl-cons.artic      = p_artic        and
              j_ord-dtl-cons.prod-type  = p_prod-type    and
              j_ord-dtl-cons.prod-code  = p_prod-code
              :
       find first loc-tt-goods no-lock   where
                  loc-tt-goods.gds-t <> 'товар':U and
                  loc-tt-goods.artic      = j_ord-dtl.artic      and
                  loc-tt-goods.node-code  = j_ord-dtl.node-code  and
                  loc-tt-goods.prod-code  = j_ord-dtl.prod-code  and
                  loc-tt-goods.prod-type  = j_ord-dtl.prod-type  no-error .
       if not available loc-tt-goods then  do:  next. end.
          loc-fact-qnty = loc-tt-goods.sum-qnty - (loc-tt-goods.sum-ord + loc-tt-goods.sum-rcv-in) .
         find first  new_ord-dtl  exclusive-lock  where
         new_ord-dtl.doc-code             = p_new-doc-code            and
         new_ord-dtl.artic                = j_ord-dtl-cons.artic      and
         new_ord-dtl.node-code            = j_ord-dtl-cons.node-code  and
         new_ord-dtl.prod-code            = j_ord-dtl-cons.prod-code  and
         new_ord-dtl.prod-type            = j_ord-dtl-cons.prod-type no-error .
         if not available new_ord-dtl then do:  create new_ord-dtl. end.
       assign
         new_ord-dtl.doc-code             = p_new-doc-code
         new_ord-dtl.artic                = j_ord-dtl-cons.artic
         new_ord-dtl.node-code            = j_ord-dtl-cons.node-code
         new_ord-dtl.prod-code            = j_ord-dtl-cons.prod-code
         new_ord-dtl.prod-type            = j_ord-dtl-cons.prod-type
         new_ord-dtl.qnty                 = loc-fact-qnty
         new_ord-dtl.cli-qnty             = new_ord-dtl.qnty / p-cli-base-rate
       .
    end.
end.
end case.
end.
END PROCEDURE.
PROCEDURE create-dtl-rcv :
 do
 on error undo, return error return-value
 :
define input parameter p_new-rcv-code like ub.ord-doc-rcv.rcv-code no-undo .
define input parameter p_new-doc-code like ub.ord-doc-rcv.doc-code no-undo .
define input parameter p_file         as character no-undo .
define input parameter p_old-doc-code like  ub.ord-doc-rcv.doc-code    no-undo .
define input parameter p_old-rcv-code like  ub.ord-doc-rcv.rcv-code    no-undo .
define input parameter p_artic        like  ub.ord-line-rcv.artic      no-undo .
define input parameter p_prod-type    like  ub.ord-line-rcv.prod-type  no-undo .
define input parameter p_prod-code    like  ub.ord-line-rcv.prod-code  no-undo .
define buffer new_ord-dtl-rcv   for ub.ord-dtl-rcv  .
define buffer old_ord-dtl-cons  for ub.ord-dtl-cons .
define buffer old_ord-gds-cons  for ub.ord-gds-cons .
define buffer j_ord-dtl         for ub.ord-dtl      .
define buffer j_ord-line        for ub.ord-line     .
define buffer of_ord-dtl        for ub.ord-dtl      .
define buffer of_ord-line       for ub.ord-line     .
define buffer loc-tt-goods   for tt-goods .
define variable loc-fact-qnty    like ub.ord-line.qnty no-undo .
define variable loc-fact-qnty-in like ub.ord-line.qnty no-undo .
case  p_file  :
when "ord-fp"  then do:
    for each  j_ord-dtl no-lock  where
              j_ord-dtl.doc-code   = p_new-doc-code and
              j_ord-dtl.artic      = p_artic        and
              j_ord-dtl.prod-type  = p_prod-type    and
              j_ord-dtl.prod-code  = p_prod-code
              ,
            first j_ord-line no-lock  where
                j_ord-line.doc-code   = p_new-doc-code and
                j_ord-line.artic      = p_artic        and
                j_ord-line.prod-type  = p_prod-type    and
                j_ord-line.prod-code  = p_prod-code
                :
       find first loc-tt-goods no-lock   where
                  loc-tt-goods.gds-t <> 'товар':U and
                  loc-tt-goods.artic      = j_ord-dtl.artic      and
                  loc-tt-goods.node-code  = j_ord-dtl.node-code  and
                  loc-tt-goods.prod-code  = j_ord-dtl.prod-code  and
                  loc-tt-goods.prod-type  = j_ord-dtl.prod-type  no-error .
       if not available loc-tt-goods then  do:  next. end.
          loc-fact-qnty = loc-tt-goods.sum-rcv .
       find first  of_ord-dtl  no-lock    where
              of_ord-dtl.doc-code   = p_old-doc-code and
              of_ord-dtl.artic      = p_artic        and
              of_ord-dtl.prod-type  = p_prod-type    and
              of_ord-dtl.prod-code  = p_prod-code   no-error .
              if error-status :error then next.
       find first new_ord-dtl-rcv  exclusive-lock  where
         new_ord-dtl-rcv.rcv-code   = p_new-rcv-code       and
         new_ord-dtl-rcv.doc-code   = j_ord-dtl.doc-code   and
         new_ord-dtl-rcv.artic      = j_ord-dtl.artic      and
         new_ord-dtl-rcv.prod-code  = j_ord-dtl.prod-code  and
         new_ord-dtl-rcv.prod-type  = j_ord-dtl.prod-type  and
         new_ord-dtl-rcv.node-code  = j_ord-dtl.node-code  no-error .
       if not  available new_ord-dtl-rcv then do:
          create new_ord-dtl-rcv.
          end.
       assign
         new_ord-dtl-rcv.rcv-code   = p_new-rcv-code
         new_ord-dtl-rcv.doc-code   = j_ord-dtl.doc-code
         new_ord-dtl-rcv.artic      = j_ord-dtl.artic
         new_ord-dtl-rcv.prod-code  = j_ord-dtl.prod-code
         new_ord-dtl-rcv.prod-type  = j_ord-dtl.prod-type
         new_ord-dtl-rcv.node-code  = j_ord-dtl.node-code
         new_ord-dtl-rcv.price-base = j_ord-dtl.price-base
         new_ord-dtl-rcv.price-cli  = j_ord-dtl.price-cli
         new_ord-dtl-rcv.price-rubl = j_ord-dtl.price-rubl
         new_ord-dtl-rcv.qnty       = MINIMUM(j_ord-dtl.qnty , of_ord-dtl.qnty) - loc-fact-qnty
         new_ord-dtl-rcv.cli-qnty   = new_ord-dtl-rcv.qnty  / j_ord-line.cli-base-rate
         new_ord-dtl-rcv.sum-base   = new_ord-dtl-rcv.price-base * new_ord-dtl-rcv.qnty
         new_ord-dtl-rcv.sum-rubl   = new_ord-dtl-rcv.price-rubl * new_ord-dtl-rcv.qnty
         new_ord-dtl-rcv.sum-cli    = new_ord-dtl-rcv.price-cli  * new_ord-dtl-rcv.cli-qnty
       .
    end.
end.
when "rcv-in"  then do:
    loc-fact-qnty-in = 0 .
    for each  old_ord-dtl-cons  no-lock where
              old_ord-dtl-cons.cons-code   = loc-ord-cons-code and
              old_ord-dtl-cons.artic       = p_artic        and
              old_ord-dtl-cons.prod-type   = p_prod-type    and
              old_ord-dtl-cons.prod-code   = p_prod-code
              ,
        first old_ord-gds-cons no-lock where
              old_ord-gds-cons.cons-code   = loc-ord-cons-code and
              old_ord-gds-cons.artic       = p_artic        and
              old_ord-gds-cons.prod-type   = p_prod-type    and
              old_ord-gds-cons.prod-code   = p_prod-code
              :
       find first  of_ord-dtl no-lock     where
              of_ord-dtl.doc-code   = p_old-doc-code and
              of_ord-dtl.node-code  = old_ord-dtl-cons.node-code    and
              of_ord-dtl.artic      = p_artic        and
              of_ord-dtl.prod-type  = p_prod-type    and
              of_ord-dtl.prod-code  = p_prod-code   no-error .
              if not available of_ord-dtl then do: next. end.
       find first  of_ord-line  no-lock    where
              of_ord-line.doc-code   = p_old-doc-code and
              of_ord-line.artic      = p_artic        and
              of_ord-line.prod-type  = p_prod-type    and
              of_ord-line.prod-code  = p_prod-code   no-error .
              if not available of_ord-line then do: next. end.
              loc-fact-qnty = of_ord-line.qnty.
       find first new_ord-dtl-rcv  exclusive-lock  where
         new_ord-dtl-rcv.rcv-code             = p_new-rcv-code           and
         new_ord-dtl-rcv.doc-code             = ""                       and
         new_ord-dtl-rcv.node-code            = of_ord-dtl.node-code     and
         new_ord-dtl-rcv.artic                = of_ord-dtl.artic         and
         new_ord-dtl-rcv.prod-code            = of_ord-dtl.prod-code     and
         new_ord-dtl-rcv.prod-type            = of_ord-dtl.prod-type     no-error .
       if not available new_ord-dtl-rcv then do:
          create new_ord-dtl-rcv.
       end.
       assign
         new_ord-dtl-rcv.rcv-code             = p_new-rcv-code
         new_ord-dtl-rcv.doc-code             = ""
         new_ord-dtl-rcv.node-code            = of_ord-dtl.node-code
         new_ord-dtl-rcv.artic                = of_ord-dtl.artic
         new_ord-dtl-rcv.prod-code            = of_ord-dtl.prod-code
         new_ord-dtl-rcv.prod-type            = of_ord-dtl.prod-type
         new_ord-dtl-rcv.qnty                 = MINIMUM(old_ord-gds-cons.sum-qnty , of_ord-dtl.qnty)
         new_ord-dtl-rcv.cli-qnty             = new_ord-dtl-rcv.qnty  / of_ord-line.cli-base-rate
       .
       loc-fact-qnty-in  = loc-fact-qnty-in + new_ord-dtl-rcv.qnty .
       if loc-fact-qnty < loc-fact-qnty-in then do:
            assign
              new_ord-dtl-rcv.qnty                 = 0
              new_ord-dtl-rcv.cli-qnty             = 0
            .
       end.
    end.
end.
end case.
end.
END PROCEDURE.
PROCEDURE create-line-fp :
do
 on error undo, return error return-value
 :
define input parameter n-code as character no-undo .
define output parameter r-tmp as recid no-undo .
define buffer b-ord-cons-gds for tt-goods.
define buffer bq_ord-doc  for ub.ord-doc  .
define buffer bq_ord-line for ub.ord-line .
if not avail tt-goods then do:
   message
   "Не найден товар " skip
   "Ошибка "  error-status :get-message(1) .
   return error.
   end.
find first  b-ord-cons-gds no-lock  where b-ord-cons-gds.artic      = tt-goods.artic and
                                 b-ord-cons-gds.prod-code  = tt-goods.prod-code and
                                 b-ord-cons-gds.prod-type  = tt-goods.prod-type
                                no-error .
if not can-find  (first ub.ord-line where ub.ord-line.doc-code   = n-code and
                                     ub.ord-line.artic      = tt-goods.artic and
                                     ub.ord-line.prod-code  = tt-goods.prod-code and
                                     ub.ord-line.prod-type  = tt-goods.prod-type no-lock ) then do:
define variable local-fact-ord like ub.ord-line.qnty no-undo .
define variable local-rcv-in   like ub.ord-line.qnty no-undo .
define variable sum-fact-ord like ub.ord-line.qnty no-undo .
    sum-fact-ord = 0.
    assign
          local-fact-ord = tt-goods.sum-ord
          local-rcv-in  = tt-goods.sum-rcv-in
    .
    sum-fact-ord = b-ord-cons-gds.sum-qnty - ( local-fact-ord + local-rcv-in ).
    if sum-fact-ord <= 0 then dO:
       message "По товару    :" tt-goods.gds-name skip
               "артикул      :" tt-goods.artic    skip
               "Уже заказано :" local-fact-ord    skip
               "Уже перемещено :" local-rcv-in    skip
               "Запрошено    :" b-ord-cons-gds.sum-qnty    skip
               "Заказывать еще ?"
               view-as alert-box question buttons OK-Cancel update g#log.
               if g#log = false then return.
    end.
    create  ub.ord-line.
      assign
        ub.ord-line.gds-code       = tt-goods.gds-code
        ub.ord-line.artic          = b-ord-cons-gds.artic
        ub.ord-line.cli-base-rate  = b-ord-cons-gds.cli-base-rate
        ub.ord-line.prod-code      = b-ord-cons-gds.prod-code
        ub.ord-line.prod-type      = b-ord-cons-gds.prod-type
        ub.ord-line.doc-code  = n-code
        ub.ord-line.line-num  = 1
        ub.ord-line.qnty      = (if sum-fact-ord < 0 then 0 else sum-fact-ord )
        ub.ord-line.unit-cli      = tt-goods.unit-cli
        ub.ord-line.cli-base-rate = tt-goods.cli-base-rate
        ub.ord-line.cli-qnty      = ub.ord-line.qnty / ub.ord-line.cli-base-rate
    .
 run last-price  in this-procedure
 (    input  g#host-code        ,
      input  ub.ord-line.artic     ,
      input  ub.ord-line.prod-type ,
      input  ub.ord-line.prod-code ,
      input  ub.ord-doc.cli-code   ,
      input  ub.ord-doc.cli-type   ,
      input  ub.ord-line.cli-base-rate  ,
      input  ub.ord-doc.exch-code  ,
      output ub.ord-line.price-base,
      output ub.ord-line.price-rubl,
      output ub.ord-line.price-cli )
      no-error  .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
    assign
      ub.ord-line.sum-base = ub.ord-line.price-base * ub.ord-line.qnty
      ub.ord-line.sum-rubl = ub.ord-line.price-rubl * ub.ord-line.qnty
      ub.ord-line.sum-cli  = ub.ord-line.price-cli  * ub.ord-line.cli-qnty
    .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  tt-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  g#host-code
  ,input  store-type
  ,input  store-code
  ,output ub.ord-line.vat-pc
  ) no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  ""
  view-as alert-box error
.
end.
line-rec = recid(ord-line) .
find first  tmp#zakaz where
            TMP#zakaz.artic                 = ub.ord-line.artic and
            TMP#zakaz.prod-code             = ub.ord-line.prod-code and
            TMP#zakaz.prod-type             = ub.ord-line.prod-type no-error .
      if not available Tmp#zakaz then do:
          create TMP#zakaz.
          end.
      assign
            TMP#zakaz.SLT-pc                = ub.ord-line.SLT-pc
            TMP#zakaz.VAT-pc                = ub.ord-line.VAT-pc
            TMP#zakaz.add-cli-qnty          = ub.ord-line.add-cli-qnty
            TMP#zakaz.add-qnty              = ub.ord-line.add-qnty
            TMP#zakaz.artic                 = ub.ord-line.artic
            TMP#zakaz.prod-code             = ub.ord-line.prod-code
            TMP#zakaz.prod-type             = ub.ord-line.prod-type
            TMP#zakaz.cancel-cli-qnty       = ub.ord-line.cancel-cli-qnty
            TMP#zakaz.cancel-date           = ub.ord-line.cancel-date
            TMP#zakaz.cancel-qnty           = ub.ord-line.cancel-qnty
            TMP#zakaz.cli-art               = ub.ord-line.cli-art
            TMP#zakaz.cli-base-rate         = ub.ord-line.cli-base-rate
            TMP#zakaz.cli-qnty              = ub.ord-line.cli-qnty
            TMP#zakaz.doc-code              = ub.ord-line.doc-code
            TMP#zakaz.excise                = ub.ord-line.excise
            TMP#zakaz.fact-date             = ub.ord-line.fact-date
            TMP#zakaz.initial-cli-qnty      = ub.ord-line.initial-cli-qnty
            TMP#zakaz.initial-qnty          = ub.ord-line.initial-qnty
            TMP#zakaz.line-num              = ub.ord-line.line-num
            TMP#zakaz.order-cli-qnty        = ub.ord-line.order-cli-qnty
            TMP#zakaz.order-qnty            = ub.ord-line.order-qnty
            TMP#zakaz.other-base            = ub.ord-line.other-base
            TMP#zakaz.other-rubl            = ub.ord-line.other-rubl
            TMP#zakaz.price-base            = ub.ord-line.price-base
            TMP#zakaz.price-cli             = ub.ord-line.price-cli
            TMP#zakaz.price-rubl            = ub.ord-line.price-rubl
            TMP#zakaz.qnty                  = ub.ord-line.qnty
            TMP#zakaz.receive-cli-qnty      = ub.ord-line.receive-cli-qnty
            TMP#zakaz.receive-qnty          = ub.ord-line.receive-qnty
            TMP#zakaz.road-tax              = ub.ord-line.road-tax
            TMP#zakaz.sum-SLT               = ub.ord-line.sum-SLT
            TMP#zakaz.sum-VAT               = ub.ord-line.sum-VAT
            TMP#zakaz.sum-base              = ub.ord-line.sum-base
            TMP#zakaz.sum-cli               = ub.ord-line.sum-cli
            TMP#zakaz.sum-excise            = ub.ord-line.sum-excise
            TMP#zakaz.sum-other-base        = ub.ord-line.sum-other-base
            TMP#zakaz.sum-other-rubl        = ub.ord-line.sum-other-rubl
            TMP#zakaz.sum-road-tax          = ub.ord-line.sum-road-tax
            TMP#zakaz.sum-rubl              = ub.ord-line.sum-rubl
            TMP#zakaz.sum-transport-base    = ub.ord-line.sum-transport-base
            TMP#zakaz.sum-transport-rubl    = ub.ord-line.sum-transport-rubl
            TMP#zakaz.transport-base        = ub.ord-line.transport-base
            TMP#zakaz.transport-rubl        = ub.ord-line.transport-rubl
            TMP#zakaz.unit-cli              = ub.ord-line.unit-cli
            TMP#zakaz.v-vat                 = ub.ord-line.v-vat
        .
    find first TMP#zakaz no-error .
    IF not avail TMP#zakaz then return no-apply.
    assign
      r-tmp = recid ( TMP#zakaz   )  .
run ord-detale in this-procedure no-error .
   if error-status :error then return error .
end.
END PROCEDURE.
PROCEDURE create-line-rcv :
do
 on error undo, return error return-value
 :
define input parameter n-code as character no-undo .
define input parameter z-recid as recid no-undo .
define input parameter fp-recid as recid no-undo .
define input parameter p-ks as int  no-undo .
define output parameter l-rec as recid no-undo .
define buffer buf-fp_ord-line for ub.ord-line .
define buffer b-of_ord-line   for ub.ord-line .
define buffer b-of_ord-doc    for ub.ord-doc  .
define buffer b-rcv_ord-doc-rcv   for ub.ord-doc-rcv  .
define buffer buf-tt-goods     for tt-goods.
define buffer p_ord-line-rcv-i for ub.ord-line-rcv .
define buffer p_ord-doc-rcv-i  for ub.ord-doc-rcv  .
define variable  loc-var-qnty  like ub.ord-line-rcv.qnty no-undo.
define variable  loc-all-rcv   as decimal no-undo .
define variable  loc-new as recid no-undo .
define variable v-doc-mode as character no-undo .
find first  buf-fp_ord-line    no-lock where recid(buf-fp_ord-line) = z-recid    no-error .
find first  b-rcv_ord-doc-rcv  no-lock where b-rcv_ord-doc-rcv.rcv-code = n-code no-error .
if avail buf-fp_ord-line then do:
  if not can-find  (first ub.ord-line-rcv where
                ub.ord-line-rcv.doc-code  = buf-fp_ord-line.doc-code and
                ub.ord-line-rcv.rcv-code  = n-code and
                ub.ord-line-rcv.artic     = buf-fp_ord-line.artic and
                ub.ord-line-rcv.prod-code = buf-fp_ord-line.prod-code and
                ub.ord-line-rcv.prod-type = buf-fp_ord-line.prod-type no-lock ) then do:
    run proc-create-rcv-line in this-procedure
    (  input buf-fp_ord-line.SLT-pc
      ,input buf-fp_ord-line.VAT-pc
      ,input buf-fp_ord-line.artic
      ,input buf-fp_ord-line.cli-base-rate
      ,input buf-fp_ord-line.cli-qnty
      ,input buf-fp_ord-line.doc-code
      ,input buf-fp_ord-line.excise
      ,input buf-fp_ord-line.gds-code
      ,input p-ks
      ,input buf-fp_ord-line.other-base
      ,input buf-fp_ord-line.other-rubl
      ,input buf-fp_ord-line.price-base
      ,input buf-fp_ord-line.price-cli
      ,input buf-fp_ord-line.price-rubl
      ,input buf-fp_ord-line.prod-code
      ,input buf-fp_ord-line.prod-type
      ,input buf-fp_ord-line.qnty
      ,input n-code
      ,input buf-fp_ord-line.road-tax
      ,input buf-fp_ord-line.sum-SLT
      ,input buf-fp_ord-line.sum-VAT
      ,input buf-fp_ord-line.sum-base
      ,input buf-fp_ord-line.sum-cli
      ,input buf-fp_ord-line.sum-excise
      ,input buf-fp_ord-line.sum-other-base
      ,input buf-fp_ord-line.sum-other-rubl
      ,input buf-fp_ord-line.sum-road-tax
      ,input buf-fp_ord-line.sum-rubl
      ,input buf-fp_ord-line.sum-transport-base
      ,input buf-fp_ord-line.sum-transport-rubl
      ,input buf-fp_ord-line.transport-base
      ,input buf-fp_ord-line.transport-rubl
      ,input buf-fp_ord-line.unit-cli
      ,input buf-fp_ord-line.v-vat
      ).
    if fp-recid <> ? then do:
          for each  b-of_ord-doc no-lock  where  recid(b-of_ord-doc) = fp-recid  ,
              first  b-of_ord-line no-lock where
                    b-of_ord-line.doc-code  = b-of_ord-doc.doc-code and
                    b-of_ord-line.artic     = buf-fp_ord-line.artic and
                    b-of_ord-line.prod-code = buf-fp_ord-line.prod-code and
                    b-of_ord-line.prod-type = buf-fp_ord-line.prod-type
                    :
              assign
                loc-var-qnty           = b-of_ord-line.qnty
              .
              leave.
          end.
       find first buf-tt-goods  where
               buf-tt-goods.gds-t     = 'товар':U           and
               buf-tt-goods.artic     = buf-fp_ord-line.artic and
               buf-tt-goods.prod-code = buf-fp_ord-line.prod-code and
               buf-tt-goods.prod-type = buf-fp_ord-line.prod-type no-lock no-error .
       define variable l-all-rcv-fp as decimal no-undo .
       l-all-rcv-fp = 0 .
       for each p_ord-line-rcv-i no-lock where
                p_ord-line-rcv-i.doc-code  = buf-fp_ord-line.doc-code and
                p_ord-line-rcv-i.artic     = buf-fp_ord-line.artic and
                p_ord-line-rcv-i.prod-code = buf-fp_ord-line.prod-code and
                p_ord-line-rcv-i.prod-type = buf-fp_ord-line.prod-type ,
             first p_ord-doc-rcv-i no-lock where
                  p_ord-doc-rcv-i.doc-code  = p_ord-line-rcv-i.doc-code and
                  p_ord-doc-rcv-i.rcv-code  = p_ord-line-rcv-i.rcv-code and
                  p_ord-doc-rcv-i.obj-type  = b-of_ord-doc.obj-type  and
                  p_ord-doc-rcv-i.obj-code  = b-of_ord-doc.obj-code  and
                  p_ord-line-rcv-i.rcv-code  <> ub.ord-line-rcv.rcv-code  and
                  p_ord-doc-rcv-i.cons-code = loc-ord-cons-code
        :
        l-all-rcv-fp = l-all-rcv-fp + p_ord-line-rcv-i.qnty .
       end.
        loc-all-rcv =  buf-fp_ord-line.qnty -  l-all-rcv-fp .
        loc-all-rcv = if  loc-all-rcv < 0 then 0 else loc-all-rcv.
       define variable loc-var-qnty-rcv as decimal no-undo .
       define buffer loc_zz_ord-line for ub.ord-line .
       define buffer loc_zz_ord-doc for  ub.ord-doc .
       loc-var-qnty-rcv = 0 .
       for each loc_zz_ord-line no-lock where
                loc_zz_ord-line.artic     = buf-fp_ord-line.artic and
                loc_zz_ord-line.prod-code = buf-fp_ord-line.prod-code and
                loc_zz_ord-line.prod-type = buf-fp_ord-line.prod-type ,
             first loc_zz_ord-doc no-lock where
                  loc_zz_ord-doc.doc-code  = loc_zz_ord-line.doc-code and
                  loc_zz_ord-doc.obj-type  = b-of_ord-doc.obj-type  and
                  loc_zz_ord-doc.obj-code  = b-of_ord-doc.obj-code  and
                  loc_zz_ord-doc.cons-code = loc-ord-cons-code
        :
       loc-var-qnty-rcv = loc-var-qnty-rcv + loc_zz_ord-line.qnty .
       end.
       define variable p_fp0 as decimal no-undo .
       p_fp0 = 0 .
       for each p_ord-line-rcv-i no-lock where
                p_ord-line-rcv-i.artic     = buf-fp_ord-line.artic and
                p_ord-line-rcv-i.prod-code = buf-fp_ord-line.prod-code and
                p_ord-line-rcv-i.prod-type = buf-fp_ord-line.prod-type ,
             first p_ord-doc-rcv-i no-lock where
                  p_ord-doc-rcv-i.doc-code  = p_ord-line-rcv-i.doc-code and
                  p_ord-doc-rcv-i.rcv-code  = p_ord-line-rcv-i.rcv-code and
                  p_ord-doc-rcv-i.obj-type  = b-of_ord-doc.obj-type  and
                  p_ord-doc-rcv-i.obj-code  = b-of_ord-doc.obj-code  and
                  p_ord-line-rcv-i.rcv-code  <> ub.ord-line-rcv.rcv-code  and
                  p_ord-doc-rcv-i.cons-code = loc-ord-cons-code
        :
       p_fp0 = p_fp0 + p_ord-line-rcv-i.qnty .
       end.
      loc-var-qnty-rcv = loc-var-qnty-rcv - p_fp0 .
      loc-var-qnty-rcv = if  loc-var-qnty-rcv < 0 then 0 else loc-var-qnty-rcv.
        assign
          ub.ord-line-rcv.qnty      = min (loc-var-qnty , loc-all-rcv , loc-var-qnty-rcv)
          ub.ord-line-rcv.qnty      = if ub.ord-line-rcv.qnty < 0 then 0 else ub.ord-line-rcv.qnty
          ub.ord-line-rcv.cli-qnty  = ub.ord-line-rcv.qnty / ub.ord-line-rcv.cli-base-rate
          .
    end.
    else do:
       find first buf-tt-goods  where
               buf-tt-goods.gds-t     = 'товар':U           and
               buf-tt-goods.artic     = buf-fp_ord-line.artic and
               buf-tt-goods.prod-code = buf-fp_ord-line.prod-code and
               buf-tt-goods.prod-type = buf-fp_ord-line.prod-type no-lock no-error .
               loc-all-rcv = if  buf-tt-goods.sum-ord - buf-tt-goods.sum-rcv < 0 then 0 else (buf-tt-goods.sum-ord - buf-tt-goods.sum-rcv ) .
       define buffer p_ord-line-rcv for ub.ord-line-rcv .
       define buffer p_ord-doc-rcv  for ub.ord-doc-rcv  .
       define variable p_fp as decimal no-undo .
       p_fp = 0.
       for each p_ord-line-rcv no-lock where
                p_ord-line-rcv.doc-code  = buf-fp_ord-line.doc-code and
                p_ord-line-rcv.artic     = buf-fp_ord-line.artic and
                p_ord-line-rcv.prod-code = buf-fp_ord-line.prod-code and
                p_ord-line-rcv.prod-type = buf-fp_ord-line.prod-type,
             first p_ord-doc-rcv no-lock where
                                         p_ord-line-rcv.doc-code  = p_ord-doc-rcv.doc-code  and
                                         p_ord-line-rcv.rcv-code  = p_ord-doc-rcv.rcv-code  and
                                         p_ord-line-rcv.rcv-code  <> ub.ord-line-rcv.rcv-code  and
                                         p_ord-doc-rcv.cons-code = loc-ord-cons-code
       :
       p_fp = p_fp + p_ord-line-rcv.qnty .
       end.
        assign
          ub.ord-line-rcv.qnty      = minimum ( (buf-fp_ord-line.qnty  - p_fp) , loc-all-rcv)
          ub.ord-line-rcv.qnty      = if ub.ord-line-rcv.qnty < 0 then 0 else ub.ord-line-rcv.qnty
          ub.ord-line-rcv.cli-qnty  = ub.ord-line-rcv.qnty / ub.ord-line-rcv.cli-base-rate
          .
    end.
    loc-new = recid(ord-line-rcv) .
    if avail b-of_ord-doc then do:
    run create-dtl-rcv  in this-procedure
    (     input  ub.ord-line-rcv.rcv-code ,
          input  ub.ord-line-rcv.doc-code ,
          input  "ord-fp"              ,
          input  b-of_ord-doc.doc-code ,
          input  ?                     ,
          input  ub.ord-line-rcv.artic    ,
          input  ub.ord-line-rcv.prod-type,
          input  ub.ord-line-rcv.prod-code
          ).
    end.
if loc-make-avto = false then do:
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  'ИЗМЕНЕНИЕ':U
             , input  "ЦИКЛ":U
             , input-output  v-doc-mode  ) .
    if v-doc-mode = "stopcycle":U  then do:
        find first ub.ord-line-rcv  exclusive-lock  where
                  ub.ord-line-rcv.doc-code  = buf-fp_ord-line.doc-code and
                  ub.ord-line-rcv.rcv-code  = n-code and
                  ub.ord-line-rcv.artic     = buf-fp_ord-line.artic and
                  ub.ord-line-rcv.prod-code = buf-fp_ord-line.prod-code and
                  ub.ord-line-rcv.prod-type = buf-fp_ord-line.prod-type no-error .
       delete ub.ord-line-rcv.
       return error  .
    end.
    if v-doc-mode = "cancel":U  then do:
        find first ub.ord-line-rcv  exclusive-lock  where
                    ub.ord-line-rcv.doc-code  = buf-fp_ord-line.doc-code and
                    ub.ord-line-rcv.rcv-code  = n-code and
                    ub.ord-line-rcv.artic     = buf-fp_ord-line.artic and
                    ub.ord-line-rcv.prod-code = buf-fp_ord-line.prod-code and
                    ub.ord-line-rcv.prod-type = buf-fp_ord-line.prod-type no-error .
       delete ub.ord-line-rcv.
    end.
    l-rec = recid(ord-line-rcv).
    end.
 end.
end.
run calc-cons-ord in this-procedure .
end.
END PROCEDURE.
PROCEDURE create-line-rcv-in :
 do
 on error undo, return error return-value
 :
define input parameter n-code  as   character no-undo .
define input parameter z-recid as   recid no-undo .
define input parameter p-ks    as   int  no-undo .
define input parameter p-qnty  like ub.ord-line-rcv.qnty   no-undo .
define output parameter l-rec  as   recid no-undo .
define buffer b-gds_ord-line for ub.ord-line .
define buffer b-of_ord-line  for ub.ord-line .
define buffer b-of_ord-doc   for ub.ord-doc  .
define buffer b-rcv_ord-doc-rcv   for ub.ord-doc-rcv  .
define buffer b-tt-goods          for tt-goods .
define variable loc-fact-qnty as decimal no-undo .
define variable v-doc-mode as character no-undo .
find first  b-gds_ord-line    no-lock  where recid(b-gds_ord-line) = z-recid       no-error .
find first  b-rcv_ord-doc-rcv no-lock  where b-rcv_ord-doc-rcv.rcv-code = n-code   no-error .
if avail b-gds_ord-line then do:
  if not can-find  (first ub.ord-line-rcv where
                ub.ord-line-rcv.rcv-code  = n-code and
                ub.ord-line-rcv.artic     = b-gds_ord-line.artic and
                ub.ord-line-rcv.prod-code = b-gds_ord-line.prod-code and
                ub.ord-line-rcv.prod-type = b-gds_ord-line.prod-type no-lock ) then do:
    find first b-tt-goods where
               b-tt-goods.gds-t     = 'товар':U and
               b-tt-goods.artic     = b-gds_ord-line.artic and
               b-tt-goods.prod-code = b-gds_ord-line.prod-code and
               b-tt-goods.prod-type = b-gds_ord-line.prod-type no-lock  .
     loc-fact-qnty = b-tt-goods.sum-qnty - ( b-tt-goods.sum-ord + b-tt-goods.sum-rcv-in) .
    define variable pp-qnty as decimal no-undo .
    define variable pp-cli-qnty as decimal no-undo .
    assign
      pp-qnty      = if p-qnty > 0 then   minimum ( p-qnty , b-gds_ord-line.qnty , loc-fact-qnty ) else minimum ( b-gds_ord-line.qnty , loc-fact-qnty )
      pp-qnty      = if pp-qnty < 0 then   0 else pp-qnty
      pp-cli-qnty  = pp-qnty / b-gds_ord-line.cli-base-rate
    .
    run proc-create-rcv-line  in this-procedure
    (  input b-gds_ord-line.SLT-pc
      ,input b-gds_ord-line.VAT-pc
      ,input b-gds_ord-line.artic
      ,input b-gds_ord-line.cli-base-rate
      ,input pp-cli-qnty
      ,input ""
      ,input b-gds_ord-line.excise
      ,input b-gds_ord-line.gds-code
      ,input p-ks
      ,input b-gds_ord-line.other-base
      ,input b-gds_ord-line.other-rubl
      ,input b-gds_ord-line.price-base
      ,input b-gds_ord-line.price-cli
      ,input b-gds_ord-line.price-rubl
      ,input b-gds_ord-line.prod-code
      ,input b-gds_ord-line.prod-type
      ,input pp-qnty
      ,input n-code
      ,input b-gds_ord-line.road-tax
      ,input b-gds_ord-line.sum-SLT
      ,input b-gds_ord-line.sum-VAT
      ,input b-gds_ord-line.sum-base
      ,input b-gds_ord-line.sum-cli
      ,input b-gds_ord-line.sum-excise
      ,input b-gds_ord-line.sum-other-base
      ,input b-gds_ord-line.sum-other-rubl
      ,input b-gds_ord-line.sum-road-tax
      ,input b-gds_ord-line.sum-rubl
      ,input b-gds_ord-line.sum-transport-base
      ,input b-gds_ord-line.sum-transport-rubl
      ,input b-gds_ord-line.transport-base
      ,input b-gds_ord-line.transport-rubl
      ,input b-gds_ord-line.unit-cli
      ,input b-gds_ord-line.v-vat
      ) no-error .
    if not error-status :error then do:
    run create-dtl-rcv in this-procedure
    (     input  ub.ord-line-rcv.rcv-code ,
          input  ub.ord-line-rcv.doc-code ,
          input  "rcv-in"              ,
          input  b-gds_ord-line.doc-code ,
          input  ?                     ,
          input  ub.ord-line-rcv.artic    ,
          input  ub.ord-line-rcv.prod-type,
          input  ub.ord-line-rcv.prod-code ).
     end.
if loc-make-avto = false then do:
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  'ИЗМЕНЕНИЕ':U
             , input  "ЦИКЛ":U
             , input-output  v-doc-mode  ) .
    if v-doc-mode = "stopcycle":U  then do:
        find first ub.ord-line-rcv  exclusive-lock  where
                    ub.ord-line-rcv.rcv-code  = n-code and
                    ub.ord-line-rcv.artic     = b-gds_ord-line.artic and
                    ub.ord-line-rcv.prod-code = b-gds_ord-line.prod-code and
                    ub.ord-line-rcv.prod-type = b-gds_ord-line.prod-type no-error .
      delete ub.ord-line-rcv.
      return error.
      end.
    if v-doc-mode = "cancel":U  then do:
        find first ub.ord-line-rcv  exclusive-lock  where
                    ub.ord-line-rcv.rcv-code  = n-code and
                    ub.ord-line-rcv.artic     = b-gds_ord-line.artic and
                    ub.ord-line-rcv.prod-code = b-gds_ord-line.prod-code and
                    ub.ord-line-rcv.prod-type = b-gds_ord-line.prod-type no-error .
      delete ub.ord-line-rcv.
      end.
    l-rec = recid(ord-line-rcv).
    end.
 end.
end.
run calc-cons-ord in this-procedure .
end.
END PROCEDURE.
procedure del-zakaz-doc:
 do
 on error undo, return error return-value
 :
def input param d-recid as recid no-undo.
find first  ub.ord-doc no-lock  where recid(ub.ord-doc) = d-recid no-error .
if ub.ord-doc.status_ <> 'новый':U then do:
  message "Нельзя удалить документ в статусе " ub.ord-doc.status_ "! Можно только в статусе НОВЫЙ " view-as alert-box error .
  return.
end.
for each ub.ord-doc  exclusive-lock  where recid(ub.ord-doc) = d-recid  :
    delete ub.ord-doc.
end.
run calc-cons-ord in this-procedure  .
end.
END PROCEDURE.
procedure del-zakaz:
 do
 on error undo, return error return-value
 :
def input param d-recid as recid no-undo.
find first  ub.ord-line no-lock  where recid(ord-line) = d-recid no-error .
find first  ub.ord-doc   exclusive-lock   where ub.ord-doc.doc-code = ub.ord-line.doc-code no-error .
if ub.ord-doc.status_ <> 'новый':U then do:
  message "Нельзя удалить документ в статусе " ub.ord-doc.status_ "! Можно только в статусе НОВЫЙ " view-as alert-box error .
  return.
end.
for each ub.ord-line  exclusive-lock  where recid(ord-line) = d-recid  :
   delete ub.ord-line.
end.
find first  ub.ord-line no-lock  where ub.ord-doc.doc-code = ub.ord-line.doc-code  no-error .
if not available  ub.ord-line then do:
    message "Теперь в заказе " ub.ord-doc.doc-code "нет ни одной строки ! Удаляем его ."
            view-as alert-box information .
    delete  ub.ord-doc no-error .
end.
run calc-cons-ord in this-procedure  .
end .
END PROCEDURE.
procedure del-post:
 do
 on error undo, return error return-value
 :
def input param d-recid as recid no-undo.
find first  ub.ord-line-rcv no-lock  where recid(ord-line-rcv) = d-recid no-error .
find first  ub.ord-doc-rcv   exclusive-lock    where ub.ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code
                                    and ub.ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code   no-error .
    if available ub.ord-doc-rcv then do:
      if ub.ord-doc-rcv.status_ <> 'новый':U then do:
        message "Нельзя удалить поставку в статусе " ub.ord-doc-rcv.status_ "! Можно только в статусе НОВЫЙ " view-as alert-box error .
        return.
      end.
      for each ub.ord-line-rcv exclusive-lock where recid(ord-line-rcv) = d-recid  :
        delete ub.ord-line-rcv.
      end.
      find first  ub.ord-line-rcv no-lock  where ub.ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code
                                        and ub.ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code   no-error .
      if not available  ub.ord-line-rcv then do:
         message "Теперь в поставке " ub.ord-doc-rcv.rcv-code "нет ни одной строки ! Удаляем ее ." view-as alert-box information .
         delete  ub.ord-doc-rcv   no-error .
      end.
      run calc-cons-ord in this-procedure  .
    end.
end.
END PROCEDURE.
procedure del-post-doc:
 do
 on error undo, return error return-value
 :
def input param d-recid as recid no-undo.
find first  ub.ord-doc-rcv no-lock where recid(ub.ord-doc-rcv) = d-recid no-error .
if ub.ord-doc-rcv.status_ <> 'новый':U then do:
  message "Нельзя удалить поставку в статусе " ub.ord-doc-rcv.status_ "! Можно только в статусе НОВЫЙ " view-as alert-box error .
  return.
end.
for each ub.ord-doc-rcv  exclusive-lock   where recid(ub.ord-doc-rcv) = d-recid  :
   delete ub.ord-doc-rcv.
end.
run calc-cons-ord in this-procedure  .
end.
END PROCEDURE.
procedure del-nacl:
 do
 on error undo, return error return-value
 :
define variable dd as character no-undo .
def input param d-recid as recid no-undo.
for each ub.doc-line  exclusive-lock  where recid(doc-line) = d-recid :
    dd = ub.doc-line.doc-code.
   if ub.doc-line.status_ <> 'накл':U then leave.
   delete ub.doc-line.
end.
find first  ub.doc-line no-lock  where ub.doc-line.doc-code = dd  no-error .
if not available  ub.doc-line then do:
    message "Теперь в накладной " dd " нет ни одной строки ! Удаляем ее ."
            view-as alert-box information .
    find first ub.trn-doc  exclusive-lock  where ub.trn-doc.doc-code = dd no-error .
      if available ub.trn-doc then   delete  ub.trn-doc no-error .
end.
run calc-cons-ord in this-procedure  .
end.
END PROCEDURE.
procedure del-nacl-doc:
 do
 on error undo, return error return-value
 :
def input param d-recid as recid no-undo.
for each ub.trn-doc  exclusive-lock   where recid(trn-doc) = d-recid :
   if ub.trn-doc.status_ <> 'накл':U then leave.
   delete ub.trn-doc.
end.
run calc-cons-ord in this-procedure  .
end.
END PROCEDURE.
PROCEDURE del-mark :
do
 on error undo, return error return-value
 :
define variable  pp-rec as recid no-undo .
pp-rec = recid (tt-goods) .
for each tt-goods  exclusive-lock  :
   tt-goods.use = false.
end.
OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
reposition BROWSE-12 to recid pp-rec no-error .
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
  HIDE FRAME FRAME-A.
  HIDE FRAME FRAME-B.
  HIDE FRAME FRAME-B-prt.
  HIDE FRAME FRAME-C.
  HIDE FRAME FRAME-D.
  HIDE FRAME FRAME-d-prt.
  HIDE FRAME FRAME-E.
  HIDE FRAME FRAME-E-prt.
  HIDE FRAME FRAME-F.
  HIDE FRAME FRAME-H.
  HIDE FRAME FRAME-I.
  HIDE FRAME FRAME-J.
  HIDE FRAME FRAME-K.
  HIDE FRAME FRAME-Post-prt.
  HIDE FRAME FRAME-Postavki.
END PROCEDURE.
PROCEDURE dop-pr :
do
 on error undo, return error return-value
 :
define buffer tt-new-ord-line-2  for  ub.ord-line.
    find first tt-new-ord-line-2  exclusive-lock   where recid(tt-new-ord-line-2) = recid(tt-new-ord-line) no-error .
assign
tt-new-ord-line-2.SLT-pc               = TMP#zakaz.SLT-pc
tt-new-ord-line-2.VAT-pc               = TMP#zakaz.VAT-pc
tt-new-ord-line-2.add-cli-qnty         = TMP#zakaz.add-cli-qnty
tt-new-ord-line-2.add-qnty             = TMP#zakaz.add-qnty
tt-new-ord-line-2.artic                = TMP#zakaz.artic
tt-new-ord-line-2.cancel-cli-qnty      = TMP#zakaz.cancel-cli-qnty
tt-new-ord-line-2.cancel-date          = TMP#zakaz.cancel-date
tt-new-ord-line-2.cancel-qnty          = TMP#zakaz.cancel-qnty
tt-new-ord-line-2.cli-art              = TMP#zakaz.cli-art
tt-new-ord-line-2.cli-base-rate        = TMP#zakaz.cli-base-rate
tt-new-ord-line-2.cli-qnty             = TMP#zakaz.cli-qnty
tt-new-ord-line-2.doc-code             = TMP#zakaz.doc-code
tt-new-ord-line-2.excise               = TMP#zakaz.excise
tt-new-ord-line-2.fact-date            = TMP#zakaz.fact-date
tt-new-ord-line-2.initial-cli-qnty     = TMP#zakaz.initial-cli-qnty
tt-new-ord-line-2.initial-qnty         = TMP#zakaz.initial-qnty
tt-new-ord-line-2.line-num             = TMP#zakaz.line-num
tt-new-ord-line-2.order-cli-qnty       = TMP#zakaz.order-cli-qnty
tt-new-ord-line-2.order-qnty           = TMP#zakaz.order-qnty
tt-new-ord-line-2.other-base           = TMP#zakaz.other-base
tt-new-ord-line-2.other-rubl           = TMP#zakaz.other-rubl
tt-new-ord-line-2.price-base           = TMP#zakaz.price-base
tt-new-ord-line-2.price-cli            = TMP#zakaz.price-cli
tt-new-ord-line-2.price-rubl           = TMP#zakaz.price-rubl
tt-new-ord-line-2.prod-code            = TMP#zakaz.prod-code
tt-new-ord-line-2.prod-type            = TMP#zakaz.prod-type
tt-new-ord-line-2.qnty                 = TMP#zakaz.qnty
tt-new-ord-line-2.receive-cli-qnty     = TMP#zakaz.receive-cli-qnty
tt-new-ord-line-2.receive-qnty         = TMP#zakaz.receive-qnty
tt-new-ord-line-2.road-tax             = TMP#zakaz.road-tax
tt-new-ord-line-2.sum-SLT              = TMP#zakaz.sum-SLT
tt-new-ord-line-2.sum-VAT              = TMP#zakaz.sum-VAT
tt-new-ord-line-2.sum-base             = TMP#zakaz.sum-base
tt-new-ord-line-2.sum-cli              = TMP#zakaz.sum-cli
tt-new-ord-line-2.sum-excise           = TMP#zakaz.sum-excise
tt-new-ord-line-2.sum-other-base       = TMP#zakaz.sum-other-base
tt-new-ord-line-2.sum-other-rubl       = TMP#zakaz.sum-other-rubl
tt-new-ord-line-2.sum-road-tax         = TMP#zakaz.sum-road-tax
tt-new-ord-line-2.sum-rubl             = TMP#zakaz.sum-rubl
tt-new-ord-line-2.sum-transport-base   = TMP#zakaz.sum-transport-base
tt-new-ord-line-2.sum-transport-rubl   = TMP#zakaz.sum-transport-rubl
tt-new-ord-line-2.transport-base       = TMP#zakaz.transport-base
tt-new-ord-line-2.transport-rubl       = TMP#zakaz.transport-rubl
tt-new-ord-line-2.unit-cli             = TMP#zakaz.unit-cli
tt-new-ord-line-2.v-vat                = TMP#zakaz.v-vat
.
end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY R-main str-good F-post-2 F-post F-obj
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Help BUTTON-2 R-main BUTTON-3 BUTTON-47 str-good F-post-2
         F-post F-obj RECT-3
      WITH FRAME Dialog-Frame.
  ENABLE BROWSE-37 BROWSE-36
      WITH FRAME FRAME-B-prt.
  OPEN QUERY BROWSE-36 FOR EACH obj_ord-dtl-rcv     WHERE x-artic      = obj_ord-dtl-rcv.artic and           x-prod-type  = obj_ord-dtl-rcv.prod-type and           x-prod-code  = obj_ord-dtl-rcv.prod-code and           string(obj_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,            EACH obj_ord-doc-rcv           where obj_ord-doc-rcv.rcv-code     = obj_ord-dtl-rcv.rcv-code and                   obj_ord-doc-rcv.doc-code   = obj_ord-dtl-rcv.doc-code and                   obj_ord-doc-rcv.doc-type   = 'in' and                   obj_ord-doc-rcv.cons-code  = loc-ord-cons-code                  NO-LOCK,          first ub.gds-prt WHERE ub.gds-prt.node-code = obj_ord-dtl-rcv.node-code NO-LOCK.    OPEN QUERY BROWSE-37 FOR EACH obj_prt-obj               WHERE obj_prt-obj.is-term = true and                           x-artic      = obj_prt-obj.artic and                     x-prod-type  = obj_prt-obj.prod-type and                     x-prod-code  = obj_prt-obj.prod-code and                     string(obj_prt-obj.prt-code) MATCHES x-node-code NO-LOCK,              each ub.gds-prt WHERE ub.gds-prt.node-code = obj_prt-obj.prt-code NO-LOCK.
  ENABLE BROWSE-32 BROWSE-33
      WITH FRAME FRAME-E-prt.
  OPEN QUERY BROWSE-32 FOR EACH e_fp_ord-dtl       WHERE x-artic      = e_fp_ord-dtl.artic and x-prod-type  = e_fp_ord-dtl.prod-type and x-prod-code  = e_fp_ord-dtl.prod-code and string(e_fp_ord-dtl.node-code) MATCHES x-node-code NO-LOCK,              EACH e_fp_ord-doc OF e_fp_ord-dtl where                        e_fp_ord-doc.cons-code = loc-ord-cons-code and                        e_fp_ord-doc.doc-type = 'ФП':U                       NO-LOCK,              first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl.node-code NO-LOCK.    OPEN QUERY BROWSE-33 FOR EACH e_fp_ord-dtl-rcv               WHERE x-artic      = e_fp_ord-dtl-rcv.artic and                     x-prod-type  = e_fp_ord-dtl-rcv.prod-type and                     x-prod-code  = e_fp_ord-dtl-rcv.prod-code and                     string(e_fp_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,              EACH e_fp_ord-doc-rcv                              where e_fp_ord-doc-rcv.rcv-code            = e_fp_ord-dtl-rcv.rcv-code and                                               e_fp_ord-doc-rcv.doc-code     = e_fp_ord-dtl-rcv.doc-code and                        e_fp_ord-doc-rcv.cons-code  = loc-ord-cons-code and                        e_fp_ord-doc-rcv.doc-type    = "out":U                       NO-LOCK,              first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl-rcv.node-code NO-LOCK.
  ENABLE BROWSE-26 BROWSE-27 B-make-post-ex-3 BUTTON-27 BUTTON-53 BUTTON-28
         BUTTON-30 BUTTON-54 BUTTON-31
      WITH FRAME FRAME-K.
  OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ФП':U and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code and ub.ord-doc.cli-type = buf_clients.obj-type))  NO-LOCK,       FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK.    OPEN QUERY BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = 'out':U       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
  ENABLE BROWSE-18 BROWSE-28 B-make-post-ex-2 BUTTON-9 BUTTON-55 BUTTON-10
         BUTTON-33 BUTTON-56 BUTTON-34
      WITH FRAME FRAME-J.
  OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .    OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
  ENABLE BROWSE-23 BROWSE-24 BUTTON-48 BUTTON-17 BUTTON-57 BUTTON-18 BUTTON-21
         BUTTON-20
      WITH FRAME FRAME-I.
  OPEN QUERY BROWSE-23 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-type = 'in'  AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK.    OPEN QUERY BROWSE-24 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK,              EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
  ENABLE B-make-trn-2 BUTTON-58 BROWSE-15 BROWSE-20 BUTTON-7 BUTTON-8 BUTTON-14
      WITH FRAME FRAME-H.
  OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.    OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
  ENABLE BROWSE-30
      WITH FRAME FRAME-C.
  OPEN QUERY BROWSE-30 FOR EACH tt-goods  NO-LOCK,              EACH ub.ord-gds-cons where             ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code   OUTER-JOIN   NO-LOCK     by tt-goods.nn .
  ENABLE BROWSE-12 B-mark B-mark-3 B-mark-4
      WITH FRAME FRAME-A.
  OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
  ENABLE BROWSE-16 B-ins-za B-za-3 B-reject B-isk
      WITH FRAME FRAME-F.
  OPEN QUERY BROWSE-16 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK     BY ub.ord-doc.obj-type        BY ub.ord-doc.obj-code         BY ub.ord-doc.ship-date          BY ub.ord-doc.ship-time           BY ub.ord-doc.doc-code DESCENDING.
  ENABLE BROWSE-31
      WITH FRAME FRAME-d-prt.
  OPEN QUERY BROWSE-31 FOR EACH ub.of_ord-dtl       WHERE x-artic      = of_ord-dtl.artic and x-prod-type  = of_ord-dtl.prod-type and x-prod-code  = of_ord-dtl.prod-code and string(of_ord-dtl.node-code) MATCHES x-node-code NO-LOCK,       EACH ub.of_ord-doc OF ub.of_ord-dtl       WHERE of_ord-doc.cons-code = loc-ord-cons-code and of_ord-doc.doc-type = 'ОФ':U NO-LOCK,       EACH ub.gds-prt WHERE ub.gds-prt.node-code = of_ord-dtl.node-code NO-LOCK.
  ENABLE BROWSE-13
      WITH FRAME FRAME-D.
  VIEW FRAME FRAME-D.
  OPEN QUERY BROWSE-13 FOR EACH ub.m_ord-line       WHERE x-artic      = m_ord-line.artic and x-prod-type  = m_ord-line.prod-type and x-prod-code  = m_ord-line.prod-code  NO-LOCK,       EACH ub.ord-doc WHERE ub.ord-doc.doc-code = m_ord-line.doc-code       AND ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK.
  DISPLAY T-cli T-cli-fp
      WITH FRAME FRAME-E.
  ENABLE BROWSE-17 T-cli T-cli-fp
      WITH FRAME FRAME-E.
  OPEN QUERY BROWSE-17 FOR EACH ub.buf_clients       WHERE ( buf_clients.sup-cons = true  OR buf_clients.sup-gds = true ) NO-LOCK,       FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code   AND ub.cli-gds.cli-type = buf_clients.obj-type       AND ub.cli-gds.artic = x-artic and cli-gds.prod-type = x-prod-type and ub.cli-gds.host-code = g#host-code and cli-gds.prod-code = x-prod-code  NO-LOCK.
  ENABLE BROWSE-21 BROWSE-29 BROWSE-22 B-make-trn BUTTON-50 BUTTON-52 BUTTON-49
         BUTTON-51
      WITH FRAME FRAME-Postavki.
  OPEN QUERY BROWSE-21 FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK.    OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .    OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
  DISPLAY T-obj
      WITH FRAME FRAME-B.
  ENABLE BROWSE-14 T-obj
      WITH FRAME FRAME-B.
  OPEN QUERY BROWSE-14 FOR EACH my-obj NO-LOCK,              EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
END PROCEDURE.
PROCEDURE hide-all-button :
do
 on error undo, return error return-value
 :
Hide b-mark  in frame frame-A
     b-mark-3 in frame frame-A
     b-mark-4 in frame frame-A .
  hide  b-ins-za  in frame frame-F
        b-reject in frame frame-F
        b-isk    in frame frame-F
        .
  hide
    button-7 in frame frame-H
    button-8 in frame frame-H
    button-15 in frame frame-H
    button-14 in frame frame-H
    b-make-trn-2 in frame frame-h .
     .
   hide
    button-17 in frame frame-I
    button-18 in frame frame-I
    button-20 in frame frame-I
    button-48 in frame frame-I
    .
  hide
    button-51 in frame frame-postavki
    button-50 in frame frame-postavki
    b-make-trn in frame frame-postavki .
  hide
    button-27  in frame frame-k
    button-28 in frame frame-k
    button-30 in frame frame-k
    button-31 in frame frame-k
    b-make-post-ex-3 in frame frame-k .
  hide
    button-9  in frame frame-J
    button-10 in frame frame-J
    button-33 in frame frame-J
    button-34 in frame frame-J
    B-mark-2  in frame frame-J
    b-make-post-ex-2 in frame frame-J.
end.
END PROCEDURE.
PROCEDURE hide-create-button :
do
 on error undo, return error return-value
 :
hide
  b-make-trn-2 in frame frame-h .
    .
  hide
  button-48 in frame frame-I
  .
hide
  b-make-trn in frame frame-postavki .
hide
  b-make-post-ex-3 in frame frame-k .
hide
  b-make-post-ex-2 in frame frame-J.
end.
END PROCEDURE.
PROCEDURE init-2 :
do
 on error undo, return error return-value
 :
define buffer bf_ord-cons for ub.ord-cons .
   apply "CHOOSE":U to BUTTON-2 in frame Dialog-Frame.
 if list-mode = "obj":U then do:
   apply "CHOOSE":U to BUTTON-47 in frame Dialog-Frame.
   end.
VIEW FRAME FRAME-A.
apply "VALUE-CHANGED":U to BROWSE-12 IN FRAME FRAME-A.
VIEW FRAME FRAME-D.
  OPEN QUERY BROWSE-13 FOR EACH ub.m_ord-line       WHERE x-artic      = m_ord-line.artic and x-prod-type  = m_ord-line.prod-type and x-prod-code  = m_ord-line.prod-code  NO-LOCK,       EACH ub.ord-doc WHERE ub.ord-doc.doc-code = m_ord-line.doc-code       AND ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK.
if doc-mode = 'ПРОСМОТР':U then do:
   run hide-all-button in this-procedure .
end.
find first bf_ord-cons no-lock  where bf_ord-cons.cons-code = loc-ord-cons-code no-error .
if not avail bf_ord-cons then return error.
if doc-mode = 'ИЗМЕНЕНИЕ':U and bf_ord-cons.status_ <>  'новый':U  and list-mode <> "obj":U  then do:
   disable b-ins-za B-reject b-isk with frame FRAME-F.
end.
if doc-mode = 'ИЗМЕНЕНИЕ':U and bf_ord-cons.status_ =  'закрыто':U  and list-mode <> "obj":U  then do:
   run hide-all-button in this-procedure .
end.
if doc-mode = 'ИЗМЕНЕНИЕ':U and bf_ord-cons.status_ =  'новый':U  and list-mode <> "obj":U then do:
   run hide-create-button in this-procedure .
end.
if doc-mode = 'ИЗМЕНЕНИЕ':U and ( bf_ord-cons.status_ =  'новый':U  )
                        and list-mode = "obj":U  then do:
   run hide-all-button in this-procedure .
end.
if doc-mode = 'ИЗМЕНЕНИЕ':U and ( bf_ord-cons.status_ =  'закрыто':U  OR bf_ord-cons.status_ =  'распределение':U  )
                        and list-mode = "obj":U  then do:
   run hide-all-button in this-procedure .
   view b-make-trn in frame frame-postavki .
end.
end.
END PROCEDURE.
PROCEDURE init-ord-gds :
do
 on error undo, return error return-value
 :
define variable t-ret as logical no-undo .
 t-ret =  session:SET-WAIT-STATE("GENERAL") .
  for each tt-ord-gds  exclusive-lock  :
    delete tt-ord-gds.
  end.
t-ret =  session:SET-WAIT-STATE("") .
end.
END PROCEDURE.
PROCEDURE init-proc :
do
 on error undo, return error return-value
 :
define variable t-ret as logical no-undo .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output to-day
  )  .
 t-ret =  session:SET-WAIT-STATE("GENERAL") .
assign
  loc-ord-cons-code = p-cons-code
  x-mode = "constype":U
  .
  tt-goods.artic :read-only in browse browse-12 = true .
  ub.trn-doc.doc-code :read-only in browse browse-15 = true .
  tt-new-ord-line.qnty :read-only in browse browse-18 = true .
  ub.ord-line-rcv.rcv-code :read-only in browse browse-20 = true .
  ub.ord-doc.doc-code :read-only in browse browse-26 = true .
  ub.ord-doc-rcv.rcv-code :read-only in browse browse-27 = true .
  tt-goods.artic :read-only in browse browse-30 = true .
  ub.ord-line-rcv.qnty :read-only in browse browse-29 = true .
  for each  ub.ord-gds-cons no-lock  where
            ub.ord-gds-cons.cons-code = loc-ord-cons-code
            ,
    first ub.goods no-lock where
          ub.goods.artic     = ub.ord-gds-cons.artic and
          ub.goods.prod-code = ub.ord-gds-cons.prod-code and
          ub.goods.prod-type = ub.ord-gds-cons.prod-type
          :
      dk = dk + 1.
      create tt-goods.
      buffer-copy ub.goods to tt-goods
      assign
        tt-goods.nn        = dk
        tt-goods.gds-t     = 'товар':U
        tt-goods.sum-qnty  = ub.ord-gds-cons.sum-qnty
        tt-goods.prt-name  = ""
        tt-goods.all-name  = tt-goods.gds-name
        tt-goods.node-code = 0
      .
      for each ub.ord-dtl-cons no-lock where
               ub.ord-dtl-cons.cons-code = loc-ord-cons-code and
               ub.ord-dtl-cons.artic     = ub.ord-gds-cons.artic and
               ub.ord-dtl-cons.prod-code = ub.ord-gds-cons.prod-code and
               ub.ord-dtl-cons.prod-type = ub.ord-gds-cons.prod-type  :
               find first ub.gds-prt no-lock  where ub.gds-prt.node-code =  ub.ord-dtl-cons.node-code no-error .
               if error-status :error then next.
               dk = dk + 1.
              create tt-goods.
              buffer-copy ub.goods to tt-goods
              assign
                tt-goods.nn = dk
                tt-goods.gds-t = 'признак':U
                tt-goods.sum-qnty = ub.ord-dtl-cons.sum-qnty
                tt-goods.prt-name = ub.gds-prt.f-name
                tt-goods.all-name = "- "  +  ub.gds-prt.f-name
                tt-goods.node-code =  ub.ord-dtl-cons.node-code
              .
      end.
  end.
for each ub.shop  no-lock where ub.shop.host-code = g#host-code  :
    find first ub.clients no-lock where
               ub.clients.obj-code = ub.shop.obj-code and
               ub.clients.obj-type = 'маг':U
               no-error .
    if available  ub.shop and available ub.clients then do :
        create my-obj .
        assign
          my-obj.obj-code = ub.shop.obj-code
          my-obj.obj-type = 'маг':U
          my-obj.obj-name = ub.clients.obj-name
          .
     end.
end.
for each ub.store no-lock where ub.store.host-code = g#host-code :
    find first ub.clients no-lock  where
               ub.clients.obj-code = ub.store.obj-code and
               ub.clients.obj-type = 'скл':U
               no-error .
    if available  ub.store and available ub.clients then do:
        create  my-obj .
        assign  my-obj.obj-code = ub.store.obj-code
                my-obj.obj-type = 'скл':U
                my-obj.obj-name = ub.clients.obj-name
        .
     end.
end.
ttt = "Планирование СОВОКУПНОЙ ЗАЯВКИ "  + p-cons-code  + " - " + doc-mode.
frame Dialog-Frame:title = ttt.
ASSIGN B-make-post-ex-3:POPUP-MENU IN FRAME frame-k = MENU POPUP-MENU-B-make-post-ex-3:HANDLE.
ASSIGN B-make-post-ex-3:MENU-MOUSE = 1.
ASSIGN B-make-post-ex-2:POPUP-MENU IN FRAME frame-j = MENU POPUP-MENU-B-make-post-ex-2:HANDLE.
ASSIGN B-make-post-ex-2:MENU-MOUSE = 1.
ASSIGN B-make-trn-2:POPUP-MENU IN FRAME frame-H = MENU POPUP-MENU-B-make-trn-2:HANDLE.
ASSIGN B-make-trn-2:MENU-MOUSE = 1.
ASSIGN B-make-trn:POPUP-MENU IN FRAME frame-Postavki = MENU POPUP-MENU-B-make-trn:HANDLE.
ASSIGN B-make-trn:MENU-MOUSE = 1.
ASSIGN BUTTON-48:POPUP-MENU IN FRAME frame-I = MENU POPUP-MENU-BUTTON-48:HANDLE.
ASSIGN BUTTON-48:MENU-MOUSE = 1.
define variable t-h as character no-undo .
 run read-handle in this-procedure (input browse-18:handle ,                        output t-h ) .                        handle-br-all[18] = t-h .
run read-handle in this-procedure (input browse-28:handle ,                        output t-h ) .                        handle-br-all[28] = t-h .
run read-handle in this-procedure (input browse-26:handle ,                        output t-h ) .                        handle-br-all[26] = t-h .
run read-handle in this-procedure (input browse-27:handle ,                        output t-h ) .                        handle-br-all[27] = t-h .
run read-handle in this-procedure (input browse-20:handle ,                        output t-h ) .                        handle-br-all[20] = t-h .
run read-handle in this-procedure (input browse-15:handle ,                        output t-h ) .                        handle-br-all[15] = t-h .
run read-handle in this-procedure (input browse-23:handle ,                        output t-h ) .                        handle-br-all[23] = t-h .
run read-handle in this-procedure (input browse-24:handle ,                        output t-h ) .                        handle-br-all[24] = t-h .
run calc-cons-ord in this-procedure .
t-ret =  session:SET-WAIT-STATE("") .
end.
END PROCEDURE.
PROCEDURE local-mark :
do
 on error undo, return error return-value
 :
if not available tt-new-ord-line then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid33 as character no-undo .
define variable v-num-entry33 as integer   no-undo .
assign
  v-str-recid33 = trim( string( recid( tt-new-ord-line ) , "->>>>>>>>>>>9":U ) )
  v-num-entry33 = lookup( v-str-recid33 , del-list )
.
if v-num-entry33 > 0 then do:
  assign
    entry( v-num-entry33, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid33
  .
end.
  if lookup(string( recid(tt-new-ord-line) ), del-list ) > 0
      then disp "" @ mark with browse browse-18.
      else disp "+" @ mark with browse browse-18.
  apply "VALUE-CHANGED" to browse-18 in frame frame-J.
  g#log = browse-18:select-next-row ().
end.
END PROCEDURE.
PROCEDURE make-fp :
do
 on error undo, return error return-value
 :
define input  parameter l-mod as character no-undo .
define output parameter o-rec as recid no-undo.
define variable ks as integer no-undo .
define variable v-num-OF as character no-undo .
define variable g-recid as recid no-undo .
define buffer nbn_ord-line for ub.ord-line .
ks = 0.
find current buf_clients no-lock no-error .
if not available  buf_clients then do:
   message "Не выбран Поставщик !!! " .
   return.
end.
if l-mod = "1" then do:
    find current tt-goods no-lock no-error .
    if not available  tt-goods then do:
      message "Не выбран Товар !!! " .
      return.
    end.
end.
if l-mod = "2" then do:
    find current tt-goods no-lock no-error .
    if not available  tt-goods then do:
      message "Не выбран Товар !!! " .
      return.
    end.
    g-recid = recid(tt-goods) .
end.
if l-mod = "3" then do:
define variable doc-code-z as character no-undo .
  doc-code-z  = ub.ord-doc.doc-code:screen-value in browse browse-16  .
  if doc-code-z = ? then return.
end.
  v-num-OF = doc-code-z  .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
define variable vvv as logical no-undo .
define buffer b-ord-doc for ub.ord-doc .
  vvv = false  .
find first  ub.ord-doc  exclusive-lock   where
     ub.ord-doc.cli-code  = buf_clients.obj-code and
     ub.ord-doc.cli-type  = buf_clients.obj-type and
     ub.ord-doc.cons-code = p-cons-code and
     ub.ord-doc.host-code = g#host-code and
     ub.ord-doc.doc-type  = 'ФП':U
     no-error .
if not available ub.ord-doc then do:
   vvv = true .
   create ub.ord-doc.
   assign
      ub.ord-doc.doc-code  = loc-ord-num
      ub.ord-doc.cli-code  = buf_clients.obj-code
      ub.ord-doc.cli-type  = buf_clients.obj-type
      ub.ord-doc.cli-name  = buf_clients.obj-name
      ub.ord-doc.cons-code = p-cons-code
      ub.ord-doc.host-code = g#host-code
      ub.ord-doc.obj-code  = store-code
      ub.ord-doc.obj-type  = store-type
      ub.ord-doc.doc-type  = 'ФП':U
      ub.ord-doc.status_   = 'новый':U
      ub.ord-doc.start-date = to-day - 7
      ub.ord-doc.end-date   = to-day
      ub.ord-doc.doc-date  = to-day
      ub.ord-doc.ship-date = to-day + 1
      ub.ord-doc.date-sale-1 = to-day + 1
      ub.ord-doc.date-sale-2 = to-day + 2
      ub.ord-doc.ship-time = 0
       .
      ub.ord-doc.exch-code = 0 .
      find ub.currency no-lock  where ub.currency.curr-code = ub.ord-doc.exch-code no-error.
        if available ub.currency then do:
            find last ub.curr-accnt no-lock   where ub.curr-accnt.curr-code = ub.currency.curr-code  use-index pi no-error.
              if available ub.curr-accnt then assign
                ub.ord-doc.exch-rate = ub.curr-accnt.exch-rate
                ub.ord-doc.exch-scale = ub.curr-accnt.exch-scale.
            find last ub.curr-accnt no-lock  where ub.curr-accnt.curr-code = base-code  use-index pi no-error .
            assign
              ub.ord-doc.base-rate  = ub.curr-accnt.exch-rate
              ub.ord-doc.base-scale = ub.curr-accnt.exch-scale
              .
       end.
       ub.ord-doc.vat-type = 'в т. ч.':U .
       ub.ord-doc.slt-type = 'без':U .
 x-make-avto = 2 .
 run cus/or-head.w ( parParentProc, input loc-ord-num , input vvv , output doc-mode ) .
 if available ord-doc then do:
    loc-ord-num = ord-doc.doc-code.
 end.
  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case.
end.
else do:
   message "Уже существует заказ ФП " ub.ord-doc.doc-code  skip
            "Контрагент -код: " ub.ord-doc.cli-code        skip
            "Контрагент -тип: " ub.ord-doc.cli-type        skip
            "Контрагент -имя: " ub.ord-doc.cli-name        skip
            "Будем делать новый заказ ?"  view-as alert-box question buttons yes-no update g#lok as logical.
   if g#lok = false  then do:
        assign loc-ord-num = ub.ord-doc.doc-code .
      end.
      else do:
        BUFFER-COPY ub.ord-doc to b-ord-doc
        assign b-ord-doc.doc-code = loc-ord-num
               b-ord-doc.status_   = 'новый':U
        .
        x-make-avto = 2 .
        run cus/or-head.w (parParentProc,input loc-ord-num , true , output doc-mode ) .
  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case .
      end.
end.
 define variable ll-d as character no-undo .
 ll-d = loc-ord-num .
 if doc-mode = "cancel":U then return.
 ks = 0 .
line-mode = 'ИЗМЕНЕНИЕ':U .
doc-rec = recid(ub.ord-doc) .
case l-mod :
when "1" then do:
define variable r-tmp as recid no-undo.
define variable r-stop as log no-undo.
define variable r-exit  as log no-undo.
define variable ii as integer no-undo .
  for each tt-goods no-lock  where
           tt-goods.use = true :
      run create-line-fp  in this-procedure ( input loc-ord-num , output r-tmp) no-error .
          if error-status :error then leave.
          r-tmp = line-rec.
      run create-dtl-fp in this-procedure
                        ( input loc-ord-num,
                          input "ord-cons",
                          input loc-ord-cons-code,
                          input tt-goods.artic,
                          input tt-goods.prod-type,
                          input tt-goods.prod-code ,
                          input tt-goods.cli-base-rate ).
       ks = ks + 1 .
       end.
  end.
when "2" then do:
  for each tt-goods no-lock  where recid(tt-goods)  = g-recid :
      run create-line-fp in this-procedure ( input loc-ord-num , output r-tmp ) no-error .
      if error-status :error then leave.
      run create-dtl-fp in this-procedure
                        ( input loc-ord-num,
                          input "ord-cons",
                          input loc-ord-cons-code,
                          input tt-goods.artic,
                          input tt-goods.prod-type,
                          input tt-goods.prod-code ,
                          input tt-goods.cli-base-rate ).
       ks = ks + 1 .
  end.
end.
when "3" then do:
    for each m_ord-line no-lock  where
             m_ord-line.doc-code = v-num-OF :
        ks = ks + 1 .
        find first nbn_ord-line no-lock where
              nbn_ord-line.doc-code   = loc-ord-num and
              nbn_ord-line.artic      = m_ord-line.artic and
              nbn_ord-line.prod-code  = m_ord-line.prod-code and
              nbn_ord-line.prod-type  = m_ord-line.prod-type
              no-error .
        if not available nbn_ord-line then do:
            create  nbn_ord-line.
            BUFFER-COPY m_ord-line to nbn_ord-line
            assign
              nbn_ord-line.doc-code           = loc-ord-num
              nbn_ord-line.line-num           = ks
            .
          run last-price  in this-procedure
          (     input  g#host-code        ,
                input  nbn_ord-line.artic     ,
                input  nbn_ord-line.prod-type ,
                input  nbn_ord-line.prod-code ,
                input  ub.ord-doc.cli-code   ,
                input  ub.ord-doc.cli-type   ,
                input  nbn_ord-line.cli-base-rate  ,
                input  ub.ord-doc.exch-code  ,
                output nbn_ord-line.price-base,
                output nbn_ord-line.price-rubl,
                output nbn_ord-line.price-cli  )
                no-error  .
                if error-status :error then message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  "Ошибка last-price"
                  view-as alert-box error
                .
                assign
                  nbn_ord-line.sum-base = nbn_ord-line.price-base * nbn_ord-line.qnty
                  nbn_ord-line.sum-rubl = nbn_ord-line.price-rubl * nbn_ord-line.qnty
                  nbn_ord-line.sum-cli  = nbn_ord-line.price-cli  * nbn_ord-line.cli-qnty
                .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  nbn_ord-line.gds-code
  ,input  '1':U
  ,input  ?
  ,input  g#host-code
  ,input  store-type
  ,input  store-code
  ,output nbn_ord-line.vat-pc
  ) no-error .
                if error-status :error then message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  "Ошибка определения НДС"
                  view-as alert-box error
                .
          find first  tmp#zakaz where
                      TMP#zakaz.artic     = nbn_ord-line.artic and
                      TMP#zakaz.prod-code = nbn_ord-line.prod-code and
                      TMP#zakaz.prod-type = nbn_ord-line.prod-type  no-error .
          if not available Tmp#zakaz then do:
              create TMP#zakaz.
          end.
              assign
                    TMP#zakaz.SLT-pc                = nbn_ord-line.SLT-pc
                    TMP#zakaz.VAT-pc                = nbn_ord-line.VAT-pc
                    TMP#zakaz.add-cli-qnty          = nbn_ord-line.add-cli-qnty
                    TMP#zakaz.add-qnty              = nbn_ord-line.add-qnty
                    TMP#zakaz.artic                 = nbn_ord-line.artic
                    TMP#zakaz.prod-code             = nbn_ord-line.prod-code
                    TMP#zakaz.prod-type             = nbn_ord-line.prod-type
                    TMP#zakaz.gds-code              = nbn_ord-line.gds-code
                    TMP#zakaz.cancel-cli-qnty       = nbn_ord-line.cancel-cli-qnty
                    TMP#zakaz.cancel-date           = nbn_ord-line.cancel-date
                    TMP#zakaz.cancel-qnty           = nbn_ord-line.cancel-qnty
                    TMP#zakaz.cli-art               = nbn_ord-line.cli-art
                    TMP#zakaz.cli-base-rate         = nbn_ord-line.cli-base-rate
                    TMP#zakaz.cli-qnty              = nbn_ord-line.cli-qnty
                    TMP#zakaz.doc-code              = nbn_ord-line.doc-code
                    TMP#zakaz.excise                = nbn_ord-line.excise
                    TMP#zakaz.fact-date             = nbn_ord-line.fact-date
                    TMP#zakaz.initial-cli-qnty      = nbn_ord-line.initial-cli-qnty
                    TMP#zakaz.initial-qnty          = nbn_ord-line.initial-qnty
                    TMP#zakaz.line-num              = nbn_ord-line.line-num
                    TMP#zakaz.order-cli-qnty        = nbn_ord-line.order-cli-qnty
                    TMP#zakaz.order-qnty            = nbn_ord-line.order-qnty
                    TMP#zakaz.other-base            = nbn_ord-line.other-base
                    TMP#zakaz.other-rubl            = nbn_ord-line.other-rubl
                    TMP#zakaz.price-base            = nbn_ord-line.price-base
                    TMP#zakaz.price-cli             = nbn_ord-line.price-cli
                    TMP#zakaz.price-rubl            = nbn_ord-line.price-rubl
                    TMP#zakaz.qnty                  = nbn_ord-line.qnty
                    TMP#zakaz.receive-cli-qnty      = nbn_ord-line.receive-cli-qnty
                    TMP#zakaz.receive-qnty          = nbn_ord-line.receive-qnty
                    TMP#zakaz.road-tax              = nbn_ord-line.road-tax
                    TMP#zakaz.sum-SLT               = nbn_ord-line.sum-SLT
                    TMP#zakaz.sum-VAT               = nbn_ord-line.sum-VAT
                    TMP#zakaz.sum-base              = nbn_ord-line.sum-base
                    TMP#zakaz.sum-cli               = nbn_ord-line.sum-cli
                    TMP#zakaz.sum-excise            = nbn_ord-line.sum-excise
                    TMP#zakaz.sum-other-base        = nbn_ord-line.sum-other-base
                    TMP#zakaz.sum-other-rubl        = nbn_ord-line.sum-other-rubl
                    TMP#zakaz.sum-road-tax          = nbn_ord-line.sum-road-tax
                    TMP#zakaz.sum-rubl              = nbn_ord-line.sum-rubl
                    TMP#zakaz.sum-transport-base    = nbn_ord-line.sum-transport-base
                    TMP#zakaz.sum-transport-rubl    = nbn_ord-line.sum-transport-rubl
                    TMP#zakaz.transport-base        = nbn_ord-line.transport-base
                    TMP#zakaz.transport-rubl        = nbn_ord-line.transport-rubl
                    TMP#zakaz.unit-cli              = nbn_ord-line.unit-cli
                    TMP#zakaz.v-vat                 = nbn_ord-line.v-vat
                .
            run create-dtl-fp in this-procedure
                              ( input loc-ord-num,
                                input "ord-of",
                                input m_ord-line.doc-code,
                                input m_ord-line.artic,
                                input m_ord-line.prod-type,
                                input m_ord-line.prod-code ,
                                input m_ord-line.cli-base-rate ) no-error .
            if error-status :error then do:
               message
                 vss-workfile vss-revision vss-description skip
                 error-status :get-message(1) skip
                 return-value skip
                 "Ошибка create-dtl-fp"
                 view-as alert-box error
               .
            end.
            run ord-detale in this-procedure  no-error .
            if error-status :error then do:
               message
                 vss-workfile vss-revision vss-description skip
                 error-status :get-message(1) skip
                 return-value skip
                 "Ошибка ord-detale"
                 view-as alert-box error
               .
                leave.
            end.
            line-mode = 'ИЗМЕНЕНИЕ':U .
       if loc-make-avto = false then do:
            assign
              doc-rec = recid (ub.ord-doc)
              r-tmp = recid ( TMP#zakaz   )
              loc-status     = ub.ord-doc.status_
              doc-date       = ub.ord-doc.doc-date
              loc-date-ship  = ub.ord-doc.ship-date
              date-sale-1    = ub.ord-doc.date-sale-1
              date-sale-2    = ub.ord-doc.date-sale-2
              loc-exch-code  = ub.ord-doc.exch-code
              loc-exch-rate  = ub.ord-doc.exch-rate
              loc-exch-scale = ub.ord-doc.exch-scale
              loc-base-rate  = ub.ord-doc.base-rate
              loc-base-scale = ub.ord-doc.base-scale
              vat_type       = ub.ord-doc.vat-type
              slt_type       = ub.ord-doc.slt-type
              loc-cli-code =   ub.ord-doc.cli-code
              loc-cli-type =   ub.ord-doc.cli-type
              loc-ord-num  = ll-d
              .
          find first shar_ord-doc no-lock  where shar_ord-doc.doc-code = ord-doc.doc-code no-error .
          run cus/ord-frm.w
              (input Parparentproc,
               input recid (TMP#zakaz) ,
               input line-mode    ,
               output r-stop      ,
               output r-exit      )
               no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  "cus/ord-frm.w"
                  view-as alert-box error
                .
                  return.
              end.
          end.
        end.
    end.
end.
end case.
if ks > 0 then do :
    find first ub.ord-doc  exclusive-lock   where ub.ord-doc.doc-code  = loc-ord-num  .
    ub.ord-doc.sys-time-int = time.
    o-rec = recid(ub.ord-doc) .
    message "Сделан заказ № " loc-ord-num .
    run calc-cons-ord in this-procedure  .
end.
else do:
   find first ub.ord-doc  exclusive-lock   where ub.ord-doc.doc-code  = loc-ord-num  .
   delete ub.ord-doc .
   o-rec = ?.
end.
end.
END PROCEDURE.
PROCEDURE make-fp-rcv :
do
 on error undo, return error return-value
 :
def input  param l-mod as character no-undo .
def output param o-rec as recid no-undo .
def output param l-rec as recid no-undo .
define variable ks as integer no-undo .
define variable loc-ord-num as character no-undo .
define variable ii as integer no-undo .
define buffer b-goods for ub.goods .
define buffer bfp-ord-doc for ub.ord-doc .
define buffer z-ord-doc   for ub.ord-doc .
define buffer z-ord-line  for ub.ord-line .
define variable doc-code-fp as character no-undo .
define variable doc-code-z as character no-undo .
define variable v-doc-mode as character no-undo .
ks = 0.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
if caps(l-mod) = "1"  or caps(l-mod) = "4"  then do:
  doc-code-z  = ub.ord-doc.doc-code:screen-value in browse browse-16  .
  doc-code-fp = ub.ord-doc.doc-code:screen-value in browse browse-26  .
  find first ub.ord-doc  where ub.ord-doc.doc-code = doc-code-fp no-lock  no-error .
  if avail ub.ord-doc and  ub.ord-doc.doc-type <> 'ФП':U  then do:
     message "Подтвердите по какому заказу ФП будет сформирована поставка " view-as alert-box .
     return.
  end.
  find first bfp-ord-doc no-lock  where bfp-ord-doc.doc-code = ub.ord-doc.doc-code no-error.
  if error-status :error  then return.
  find first z-ord-doc no-lock  where z-ord-doc.doc-code = doc-code-z no-error.
  if error-status :error  then do:
     message "Не выбрана заявка! " view-as alert-box .
     return.
     end.
end.
if caps(l-mod) = "2"  then do:
      if num-entries(del-list) < 1  then do:
        message "Товар в заказе не отмечен '+' !!! " .
        return.
      end.
      find first tt-new-ord-line no-lock  where recid(tt-new-ord-line) = integer(entry(1,del-list))  no-error .
          if error-status :error  then return.
      find first bfp-ord-doc no-lock where bfp-ord-doc.doc-code = tt-new-ord-line.doc-code no-error.
end.
if caps(l-mod) = "3"  then do:
  doc-code-z  = m_ord-line.doc-code:screen-value in browse browse-13  .
  find first z-ord-doc no-lock  where z-ord-doc.doc-code = doc-code-z no-error.
  if error-status :error  then do:
     message "Не выбрана заявка! " view-as alert-box .
     return.
     end.
    find current  tt-new-ord-line  no-lock no-error .
          if not avail tt-new-ord-line or  error-status :error  then do:
          message "Нет заказа по текущему товару !!! "  view-as alert-box information .
          return.
          end.
      find first bfp-ord-doc no-lock  where bfp-ord-doc.doc-code = tt-new-ord-line.doc-code no-error.
end.
if bfp-ord-doc.status_ <> 'поставка':U  then do:
     message "Нельзя создать поставку на заказ в статусе " bfp-ord-doc.status_ view-as alert-box .
     return.
   end.
run proc-create-rcv-doc in this-procedure
( input bfp-ord-doc.PS
 ,input bfp-ord-doc.base-rate
 ,input bfp-ord-doc.base-scale
 ,input bfp-ord-doc.cli-code
 ,input bfp-ord-doc.cli-type
 ,input bfp-ord-doc.cons-code
 ,input v-cntxt-userid
 ,input bfp-ord-doc.cycle-day
 ,input bfp-ord-doc.date-pay
 ,input bfp-ord-doc.doc-code
 ,input to-day
 ,input 'out':U
 ,input bfp-ord-doc.exch-code
 ,input bfp-ord-doc.exch-date
 ,input bfp-ord-doc.exch-rate
 ,input bfp-ord-doc.exch-scale
 ,input bfp-ord-doc.fact-date
 ,input bfp-ord-doc.fact-num
 ,input bfp-ord-doc.fact-order
 ,input 0
 ,input bfp-ord-doc.fact-time
 ,input bfp-ord-doc.flag_
 ,input bfp-ord-doc.host-code
 ,input ( if avail z-ord-doc then z-ord-doc.obj-code else 0   )
 ,input ( if avail z-ord-doc then  z-ord-doc.obj-type else "" )
 ,input bfp-ord-doc.order-type
 ,input loc-ord-num
 ,input bfp-ord-doc.shift-date
 ,input bfp-ord-doc.shift-num
 ,input bfp-ord-doc.shift-name
 ,input bfp-ord-doc.ship-date
 ,input bfp-ord-doc.ship-time
 ,input 'новый':U
 ,input bfp-ord-doc.sum-service
 ,input bfp-ord-doc.sum-ship
 ,input bfp-ord-doc.sys-date
 ,input bfp-ord-doc.sys-time-int
 ,input bfp-ord-doc.sys-time
 ,input bfp-ord-doc.tot-lines
 ,input ""
 ,input bfp-ord-doc.user-db-num
 ,input bfp-ord-doc.user-name
 ).
v-doc-mode = 'ДОБАВЛЕНИЕ':U.
x-make-avto = 2 .
  run cus/or-obj.w
  (       input  parParentProc
        , input  ub.ord-doc-rcv.host-code
        , input  recid(ub.ord-doc-rcv)
        , input  1
        , input  'ИЗМЕНЕНИЕ':U
        , input  'ИЗМЕНЕНИЕ':U
        , input-output  v-doc-mode  ) .
  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case .
if v-doc-mode = "cancel":U then do:
    find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num  no-error .
    delete ub.ord-doc-rcv.
   return.
 end.
if caps(l-mod) = "1"  then do:
   for each tt-new-ord-line no-lock where tt-new-ord-line.doc-code = bfp-ord-doc.doc-code :
        find first b-goods no-lock   where
                  tt-new-ord-line.artic    = b-goods.artic     and
                  tt-new-ord-line.prod-type = b-goods.prod-type and
                  tt-new-ord-line.prod-code = b-goods.prod-code no-error .
        if available b-goods  and
          not can-find ( first  tt-ord-gds where tt-ord-gds.gds-code = b-goods.gds-code no-lock )
          then do:
            create tt-ord-gds .
            buffer-copy b-goods to tt-ord-gds .
            end.
        ks = ks + 1 .
        run create-line-rcv in this-procedure
           ( input loc-ord-num ,
             input recid (tt-new-ord-line),
             input ? ,
             input  ks ,
             output l-rec) no-error .
        if error-status :error then leave.
    end.
end.
if caps(l-mod) = "2"  then do:
define variable v-nn as integer   no-undo .
v-nn = num-entries(del-list) .
    do ii = 1 to v-nn :
        find first tt-new-ord-line no-lock  where recid(tt-new-ord-line) = integer(entry(ii,del-list)) no-error .
        if available tt-new-ord-line then
        find first b-goods no-lock where tt-new-ord-line.artic     = b-goods.artic and
                                tt-new-ord-line.prod-type = b-goods.prod-type and
                                tt-new-ord-line.prod-code = b-goods.prod-code no-error .
        if available b-goods  and
          not can-find ( first  tt-ord-gds where tt-ord-gds.gds-code = b-goods.gds-code no-lock )
          then do:
            create tt-ord-gds .
            buffer-copy b-goods to tt-ord-gds .
            end.
        ks = ks + 1 .
        run create-line-rcv in this-procedure ( input loc-ord-num , recid(tt-new-ord-line),  ? ,input  ks , output l-rec) no-error .
        if error-status :error then leave.
    end.
end.
if caps(l-mod) = "3"  then do:
        if available tt-new-ord-line then
        find first b-goods no-lock  where tt-new-ord-line.artic     = b-goods.artic and
                                tt-new-ord-line.prod-type = b-goods.prod-type and
                                tt-new-ord-line.prod-code = b-goods.prod-code no-error .
        if available b-goods  and
          not can-find ( first  tt-ord-gds where tt-ord-gds.gds-code = b-goods.gds-code no-lock )
          then do:
            create tt-ord-gds .
            buffer-copy b-goods to tt-ord-gds .
            end.
        ks = ks + 1 .
        run create-line-rcv in this-procedure ( input loc-ord-num , recid(tt-new-ord-line),  ? ,input  ks , output l-rec) no-error .
end.
if caps(l-mod) = "4"  then do:
   for each tt-new-ord-line no-lock where tt-new-ord-line.doc-code = bfp-ord-doc.doc-code :
        find first z-ord-line no-lock where
                              z-ord-line.doc-code  = doc-code-z  and
                              z-ord-line.artic     = tt-new-ord-line.artic  and
                              z-ord-line.prod-type = tt-new-ord-line.prod-type  and
                              z-ord-line.prod-code = tt-new-ord-line.prod-code
                              no-error .
          if available z-ord-line then do :
              if not  can-find ( first  tt-ord-gds where
                                        tt-ord-gds.artic     = z-ord-line.artic      and
                                        tt-ord-gds.prod-type = z-ord-line.prod-type  and
                                        tt-ord-gds.prod-code = z-ord-line.prod-code  no-lock )
              then do:
                  find first b-goods no-lock where z-ord-line.artic     = b-goods.artic and
                                          z-ord-line.prod-type = b-goods.prod-type and
                                          z-ord-line.prod-code = b-goods.prod-code no-error .
                  create tt-ord-gds .
                  buffer-copy b-goods to tt-ord-gds .
                  end.
              ks = ks + 1 .
              run create-line-rcv in this-procedure ( input loc-ord-num , recid(tt-new-ord-line), recid(z-ord-doc) , input  ks , output l-rec) no-error .
              if error-status :error then leave .
          end.
   end.
end.
ks = 0  .
for each ub.ord-line-rcv where  ub.ord-line-rcv.rcv-code =   loc-ord-num no-lock :
  ks = ks + 1.
  leave.
end.
if ks > 0 then do:
    o-rec = recid(ub.ord-doc-rcv).
    message "Сделана поставка № " loc-ord-num.
    run calc-cons-ord in this-procedure .
   end.
 else do:
   find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num .
   delete ub.ord-doc-rcv .
   o-rec = ?.
   l-rec = ?.
end.
for each tt-ord-gds :
 delete tt-ord-gds.
end.
del-list = '' .
end.
END PROCEDURE.
PROCEDURE make-post-in :
def output param o-rec  as recid no-undo.
def output param l-rec  as recid no-undo.
do
 on error undo, return error return-value
 :
define variable ks as integer no-undo .
define variable loc-ord-num as character no-undo .
define variable ii as integer no-undo .
define buffer b-goods for ub.goods .
define buffer bfp-ord-doc for ub.ord-doc .
find current ub.ord-doc no-lock no-error .
if not available  ub.ord-doc then do:
   message "Не выбрана заявка !!! " .
   return.
end.
if  ub.ord-doc.doc-type <> 'ОФ':U then do:
   message "Не выбрана ЗАЯВКА !!! " .
   return.
end.
find current my-obj no-lock no-error .
if not available my-obj then do:
   message "Не выбран объект !!! " .
   return.
end.
find first bfp-ord-doc no-lock  where bfp-ord-doc.doc-code = ub.ord-doc.doc-code no-error.
     if error-status :error  then return.
ks = 0.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
   create ub.ord-doc-rcv.
   BUFFER-COPY bfp-ord-doc to ub.ord-doc-rcv
   assign
      ub.ord-doc-rcv.rcv-code  = loc-ord-num
      ub.ord-doc-rcv.doc-code  = ""
      ub.ord-doc-rcv.cli-code  = my-obj.obj-code
      ub.ord-doc-rcv.cli-type  = my-obj.obj-type
      ub.ord-doc-rcv.obj-code  = bfp-ord-doc.obj-code
      ub.ord-doc-rcv.obj-type  = bfp-ord-doc.obj-type
      ub.ord-doc-rcv.host-code = bfp-ord-doc.host-code
      ub.ord-doc-rcv.cons-code = loc-ord-cons-code
      ub.ord-doc-rcv.doc-type  = "in":U
      ub.ord-doc-rcv.doc-date  = to-day
      ub.ord-doc-rcv.status_   = 'новый':U
   .
define variable v-doc-mode as character no-undo .
v-doc-mode = 'ДОБАВЛЕНИЕ':U.
   o-rec = recid(ord-doc-rcv).
   x-make-avto = 2 .
  run cus/or-obj.w
      (   input  parParentProc
        , input  ub.ord-doc-rcv.host-code
        , input  recid(ub.ord-doc-rcv)
        , input  1
        , input  'ИЗМЕНЕНИЕ':U
        , input  'ИЗМЕНЕНИЕ':U
        , input-output  v-doc-mode  ) .
  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case .
if v-doc-mode = "cancel":U then do:
    find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num  no-error .
    delete ub.ord-doc-rcv.
   return.
 end.
 for each m_ord-line no-lock  where
          m_ord-line.doc-code   = bfp-ord-doc.doc-code
          :
    find first b-goods no-lock  where
                m_ord-line.artic     = b-goods.artic     and
                m_ord-line.prod-type = b-goods.prod-type and
                m_ord-line.prod-code = b-goods.prod-code
                no-error .
     find first ub.gds-obj no-lock  where
                ub.gds-obj.obj-code    = my-obj.obj-code and
                ub.gds-obj.obj-type    = my-obj.obj-type and
                ub.gds-obj.artic       = b-goods.artic   and
                ub.gds-obj.prod-code   = b-goods.prod-code and
                ub.gds-obj.prod-code   = b-goods.prod-code
                no-error .
       if avail ub.gds-obj then do:
          ks = ks + 1 .
          run create-line-rcv-in in this-procedure
          ( input loc-ord-num ,
            recid(m_ord-line),
            input  ks ,
            input ub.gds-obj.fact-qnty ,
            output l-rec
            ) no-error .
          if error-status :error then leave.
       end.
       if not avail ub.gds-obj then do:
          message "Товара "skip
          b-goods.artic      skip
          b-goods.prod-type  skip
          b-goods.prod-code  skip
          "нет на объекте " skip
          my-obj.obj-code    skip
          my-obj.obj-type skip
          skip
          "Делать поставку ? " update g#log view-as alert-box question buttons yes-no.
          if g#log = true then do:
              ks = ks + 1 .
              run create-line-rcv-in  in this-procedure ( input loc-ord-num , recid(m_ord-line), input  ks , input 0 , output l-rec ) no-error .
              if error-status :error then leave.
          end.
       end.
 end.
ks = 0 .
for each ub.ord-line-rcv where  ub.ord-line-rcv.rcv-code =   loc-ord-num no-lock :
  ks = ks + 1.
  leave.
end.
if ks > 0 then do:
    l-rec = recid(m_ord-line).
    message "Поставка № " loc-ord-num " сделана"  .
    run calc-cons-ord in this-procedure .
   end.
 else do:
   find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num .
   delete ub.ord-doc-rcv .
   o-rec = ?.
   l-rec = ?.
end.
end.
END PROCEDURE.
PROCEDURE make-post-gds-in :
 do
 on error undo, return error return-value
 :
define input parameter l-mod as integer no-undo .
def output param o-rec  as recid no-undo.
def output param l-rec  as recid no-undo.
define variable ks as integer no-undo .
define variable loc-ord-num as character no-undo .
define variable m-obj-code like ub.clients.obj-code no-undo .
define variable m-obj-type like ub.clients.obj-type no-undo .
define buffer mm_ord-doc  for ub.ord-doc  .
define buffer mm_ord-line for ub.ord-line  .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
for each temp-ttt :
   delete temp-ttt.
end.
ks = 0.
if l-mod = 1 then do:
    find current tt-goods  no-error.
      if  avail tt-goods then  do:
          ks = ks + 1.
          create temp-ttt.
          assign temp-ttt.p-recid = recid(tt-goods) .
        end.
        else do:
              message "Товар не выбран !!! "  view-as alert-box  .
              return.
              end.
 end.
if l-mod = 2 then do:
    for each tt-goods no-lock  where tt-goods.use = true :
        ks = ks + 1.
          create temp-ttt.
          assign temp-ttt.p-recid = recid(tt-goods) .
    end.
end.
if ks <= 0 then do:
  message "Товар не выбран !!! "  view-as alert-box  .
  return.
end.
if frame FRAME-D:visible then do:
   apply "VALUE-CHANGED":U to browse-13 in frame frame-d.
end.
    find current m_ord-line no-lock no-error .
    if not available  m_ord-line  then do:
      message "Не выбрана заявка !!! " .
      return.
    end.
 find first mm_ord-doc where mm_ord-doc.doc-code = m_ord-line.doc-code no-lock no-error .
    assign
        m-obj-code = mm_ord-doc.obj-code
        m-obj-type = mm_ord-doc.obj-type
        .
find current my-obj no-lock no-error .
if not available  my-obj then do:
   message "Не выбран объект !!! " .
   return.
end.
   create ub.ord-doc-rcv.
   BUFFER-COPY mm_ord-doc to ub.ord-doc-rcv
   assign
      ub.ord-doc-rcv.rcv-code  = loc-ord-num
      ub.ord-doc-rcv.doc-code  = ""
      ub.ord-doc-rcv.cli-code  = my-obj.obj-code
      ub.ord-doc-rcv.cli-type  = my-obj.obj-type
      ub.ord-doc-rcv.obj-code  = m-obj-code
      ub.ord-doc-rcv.obj-type  = m-obj-type
      ub.ord-doc-rcv.host-code = g#host-code
      ub.ord-doc-rcv.cons-code = loc-ord-cons-code
      ub.ord-doc-rcv.doc-type  = "in":U
      ub.ord-doc-rcv.doc-date  = to-day
      ub.ord-doc-rcv.status_   = 'новый':U
   .
define variable v-doc-mode as character no-undo .
v-doc-mode = 'ДОБАВЛЕНИЕ':U.
x-make-avto = 2 .
  run cus/or-obj.w
        ( input  parParentProc
        , input  ub.ord-doc-rcv.host-code
        , input  recid(ub.ord-doc-rcv)
        , input  1
        , input  'ИЗМЕНЕНИЕ':U
        , input  'ИЗМЕНЕНИЕ':U
        , input-output  v-doc-mode  ) .
  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case .
ks = 0.
if v-doc-mode = "cancel":U then do:
    find first ub.ord-doc-rcv  exclusive-lock    where ub.ord-doc-rcv.rcv-code  = loc-ord-num no-error .
    delete ub.ord-doc-rcv.
   return.
end.
 for each temp-ttt   :
    find first  tt-goods no-lock  where recid(tt-goods) = temp-ttt.p-recid no-error .
    find first  ub.gds-obj  no-lock  where
                ub.gds-obj.obj-code  = my-obj.obj-code and
                ub.gds-obj.obj-type  = my-obj.obj-type and
                ub.gds-obj.artic     = tt-goods.artic   and
                ub.gds-obj.prod-code = tt-goods.prod-code and
                ub.gds-obj.prod-code = tt-goods.prod-code
                no-error .
   find first mm_ord-line no-lock where
                  mm_ord-line.doc-code  = mm_ord-doc.doc-code and
                  mm_ord-line.artic     = tt-goods.artic      and
                  mm_ord-line.prod-code = tt-goods.prod-code  and
                  mm_ord-line.prod-code = tt-goods.prod-code
                  no-error .
       if not avail  mm_ord-line then do :
          message "Товара "skip
              tt-goods.artic      skip
              tt-goods.prod-type  skip
              tt-goods.prod-code  skip
              "не требуется по заявке "  mm_ord-doc.doc-code skip
              "Пропускаем его " view-as alert-box .
              next.
       end.
       if available ub.gds-obj then do:
          ks = ks + 1 .
          run create-line-rcv-in in this-procedure ( input loc-ord-num , recid(mm_ord-line), input  ks , input ub.gds-obj.fact-qnty , output l-rec ).
       end.
       if not avail ub.gds-obj then do:
          message "Товара "skip
          tt-goods.artic      skip
          tt-goods.prod-type  skip
          tt-goods.prod-code  skip
          "нет на объекте " skip
          my-obj.obj-code    skip
          my-obj.obj-type skip
          skip
          "Делать поставку ? " update g#log view-as alert-box question buttons yes-no.
          if g#log = true then do:
              ks = ks + 1 .
              run create-line-rcv-in in this-procedure (input loc-ord-num , recid(mm_ord-line), input  ks , input 0 , output l-rec ).
          end.
       end.
 end.
if ks > 0 then do:
    l-rec = recid(m_ord-line).
    message "Поставка № " loc-ord-num " сделана"  .
    run calc-cons-ord in this-procedure .
   end.
 else do:
   find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num  .
   delete ub.ord-doc-rcv .
   o-rec = ?.
   l-rec = ?.
end.
end.
END PROCEDURE.
PROCEDURE make-trn :
do
 on error undo, return error return-value
 :
define input parameter tp-rec as recid no-undo .
    run cus/ord-trn.p
    ( parParentProc ,
      input tp-rec ,
      input no
      ).
end.
END PROCEDURE.
PROCEDURE new-zayvka :
do
 on error undo, return error return-value
 :
define buffer bb_ord-doc for ub.ord-doc.
define buffer bb_ord-line for ub.ord-line.
define buffer bb_ord-gds-cons for ub.ord-gds-cons.
define variable ii as integer no-undo .
define variable s-del-list as char no-undo.
define variable t-ret as logical no-undo .
define variable t-rec as recid no-undo .
define variable loc-gds-code like ub.goods.gds-code no-undo .
run ref/all-zakz.w
   ( input   parParentProc
    ,input   'ОФ':U
    ,input   ?
    ,input   "firm"
    ,input   p-cons-code
    ,input   "b-sel,b-mark,b-lkp,nob-exec,nob-copy"
    ,input   ""
    ,output  s-del-list ) .
t-ret =  session:SET-WAIT-STATE("GENERAL") .
ii = 0 .
define variable v-nn as integer   no-undo .
v-nn = num-entries(s-del-list).
 DO ii = 1  to v-nn :
    find first bb_ord-doc  exclusive-lock   where recid(bb_ord-doc) = integer(entry(ii,s-del-list))  no-error .
    if available bb_ord-doc then do:
    if bb_ord-doc.status_ <> 'согласование':U then do:          message "Документ " bb_ord-doc.doc-code "имеет статус" caps(bb_ord-doc.status_) "пропускаем." view-as alert-box .         next.    end. assign bb_ord-doc.cons-code = loc-ord-cons-code .   for each bb_ord-line where bb_ord-line.doc-code = bb_ord-doc.doc-code no-lock :    if can-find (first bb_ord-gds-cons where bb_ord-gds-cons.cons-code = loc-ord-cons-code       and                                   bb_ord-gds-cons.artic     = bb_ord-line.artic     and                                   bb_ord-gds-cons.prod-code = bb_ord-line.prod-code and                                   bb_ord-gds-cons.prod-type = bb_ord-line.prod-type  no-lock ) then do:             for each bb_ord-gds-cons where bb_ord-gds-cons.cons-code = loc-ord-cons-code       and                                   bb_ord-gds-cons.artic     = bb_ord-line.artic     and                                   bb_ord-gds-cons.prod-code = bb_ord-line.prod-code and                                   bb_ord-gds-cons.prod-type = bb_ord-line.prod-type  exclusive-lock :                 bb_ord-gds-cons.sum-qnty = bb_ord-gds-cons.sum-qnty + bb_ord-line.qnty .           end.     end.     else do:         create bb_ord-gds-cons.         Assign bb_ord-gds-cons.cons-code = loc-ord-cons-code                      bb_ord-gds-cons.artic     = bb_ord-line.artic                      bb_ord-gds-cons.prod-code = bb_ord-line.prod-code                  bb_ord-gds-cons.prod-type = bb_ord-line.prod-type                  bb_ord-gds-cons.sum-qnty  = bb_ord-line.qnty .     end.     t-rec = recid(bb_ord-gds-cons). end.
    end.
 end.
 if ii = 0 or v-nn = 0  then do:
     DO ii = 1  to 1 :
     ii = 1 .
     find first bb_ord-doc  exclusive-lock   where recid(bb_ord-doc) = doc-rec no-error .
     if available bb_ord-doc then do:
    if bb_ord-doc.status_ <> 'согласование':U then do:          message "Документ " bb_ord-doc.doc-code "имеет статус" caps(bb_ord-doc.status_) "пропускаем." view-as alert-box .         next.    end. assign bb_ord-doc.cons-code = loc-ord-cons-code .   for each bb_ord-line where bb_ord-line.doc-code = bb_ord-doc.doc-code no-lock :    if can-find (first bb_ord-gds-cons where bb_ord-gds-cons.cons-code = loc-ord-cons-code       and                                   bb_ord-gds-cons.artic     = bb_ord-line.artic     and                                   bb_ord-gds-cons.prod-code = bb_ord-line.prod-code and                                   bb_ord-gds-cons.prod-type = bb_ord-line.prod-type  no-lock ) then do:             for each bb_ord-gds-cons where bb_ord-gds-cons.cons-code = loc-ord-cons-code       and                                   bb_ord-gds-cons.artic     = bb_ord-line.artic     and                                   bb_ord-gds-cons.prod-code = bb_ord-line.prod-code and                                   bb_ord-gds-cons.prod-type = bb_ord-line.prod-type  exclusive-lock :                 bb_ord-gds-cons.sum-qnty = bb_ord-gds-cons.sum-qnty + bb_ord-line.qnty .           end.     end.     else do:         create bb_ord-gds-cons.         Assign bb_ord-gds-cons.cons-code = loc-ord-cons-code                      bb_ord-gds-cons.artic     = bb_ord-line.artic                      bb_ord-gds-cons.prod-code = bb_ord-line.prod-code                  bb_ord-gds-cons.prod-type = bb_ord-line.prod-type                  bb_ord-gds-cons.sum-qnty  = bb_ord-line.qnty .     end.     t-rec = recid(bb_ord-gds-cons). end.
     end.
    end.
 end.
 run init-proc in this-procedure .
OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
OPEN QUERY BROWSE-16 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK     BY ub.ord-doc.obj-type        BY ub.ord-doc.obj-code         BY ub.ord-doc.ship-date          BY ub.ord-doc.ship-time           BY ub.ord-doc.doc-code DESCENDING.
 run calc-cons-ord in this-procedure .
 t-ret =  session:SET-WAIT-STATE("") .
end.
END PROCEDURE.
PROCEDURE ord-detale :
do
 on error undo, return error return-value
 :
 define variable  r-tmp as recid   no-undo .
 define variable r-stop as logical no-undo .
 define variable r-exit as logical no-undo .
 define variable ii as integer no-undo .
 find current ub.ord-line no-lock no-error .
  if avail ub.ord-line then do:
     find first  tmp#zakaz where
            TMP#zakaz.artic                 = ub.ord-line.artic and
            TMP#zakaz.prod-code             = ub.ord-line.prod-code and
            TMP#zakaz.prod-type             = ub.ord-line.prod-type no-error .
      if not available Tmp#zakaz then do:
          create TMP#zakaz.
          end.
      assign
        TMP#zakaz.SLT-pc                = ub.ord-line.SLT-pc
        TMP#zakaz.VAT-pc                = ub.ord-line.VAT-pc
        TMP#zakaz.add-cli-qnty          = ub.ord-line.add-cli-qnty
        TMP#zakaz.add-qnty              = ub.ord-line.add-qnty
        TMP#zakaz.artic                 = ub.ord-line.artic
        TMP#zakaz.cancel-cli-qnty       = ub.ord-line.cancel-cli-qnty
        TMP#zakaz.cancel-date           = ub.ord-line.cancel-date
        TMP#zakaz.cancel-qnty           = ub.ord-line.cancel-qnty
        TMP#zakaz.cli-art               = ub.ord-line.cli-art
        TMP#zakaz.cli-base-rate         = ub.ord-line.cli-base-rate
        TMP#zakaz.cli-qnty              = ub.ord-line.cli-qnty
        TMP#zakaz.doc-code              = ub.ord-line.doc-code
        TMP#zakaz.excise                = ub.ord-line.excise
        TMP#zakaz.fact-date             = ub.ord-line.fact-date
        TMP#zakaz.initial-cli-qnty      = ub.ord-line.initial-cli-qnty
        TMP#zakaz.initial-qnty          = ub.ord-line.initial-qnty
        TMP#zakaz.line-num              = ub.ord-line.line-num
        TMP#zakaz.order-cli-qnty        = ub.ord-line.order-cli-qnty
        TMP#zakaz.order-qnty            = ub.ord-line.order-qnty
        TMP#zakaz.other-base            = ub.ord-line.other-base
        TMP#zakaz.other-rubl            = ub.ord-line.other-rubl
        TMP#zakaz.price-base            = ub.ord-line.price-base
        TMP#zakaz.price-cli             = ub.ord-line.price-cli
        TMP#zakaz.price-rubl            = ub.ord-line.price-rubl
        TMP#zakaz.prod-code             = ub.ord-line.prod-code
        TMP#zakaz.prod-type             = ub.ord-line.prod-type
        TMP#zakaz.qnty                  = ub.ord-line.qnty
        TMP#zakaz.receive-cli-qnty      = ub.ord-line.receive-cli-qnty
        TMP#zakaz.receive-qnty          = ub.ord-line.receive-qnty
        TMP#zakaz.road-tax              = ub.ord-line.road-tax
        TMP#zakaz.sum-SLT               = ub.ord-line.sum-SLT
        TMP#zakaz.sum-VAT               = ub.ord-line.sum-VAT
        TMP#zakaz.sum-base              = ub.ord-line.sum-base
        TMP#zakaz.sum-cli               = ub.ord-line.sum-cli
        TMP#zakaz.sum-excise            = ub.ord-line.sum-excise
        TMP#zakaz.sum-other-base        = ub.ord-line.sum-other-base
        TMP#zakaz.sum-other-rubl        = ub.ord-line.sum-other-rubl
        TMP#zakaz.sum-road-tax          = ub.ord-line.sum-road-tax
        TMP#zakaz.sum-rubl              = ub.ord-line.sum-rubl
        TMP#zakaz.sum-transport-base    = ub.ord-line.sum-transport-base
        TMP#zakaz.sum-transport-rubl    = ub.ord-line.sum-transport-rubl
        TMP#zakaz.transport-base        = ub.ord-line.transport-base
        TMP#zakaz.transport-rubl        = ub.ord-line.transport-rubl
        TMP#zakaz.unit-cli              = ub.ord-line.unit-cli
        TMP#zakaz.v-vat                 = ub.ord-line.v-vat
    .
    find current TMP#zakaz no-error .
    find first ub.ord-doc no-lock  where ub.ord-doc.doc-code = ub.ord-line.doc-code no-error .
    find first shar_ord-doc no-lock  where shar_ord-doc.doc-code = ord-line.doc-code no-error .
    assign
      line-mode = "ЦИКЛ":U
      r-tmp = recid ( TMP#zakaz   )
      loc-status     = ub.ord-doc.status_
      doc-date       = ub.ord-doc.doc-date
      loc-date-ship  = ub.ord-doc.ship-date
      date-sale-1    = ub.ord-doc.date-sale-1
      date-sale-2    = ub.ord-doc.date-sale-2
      loc-exch-code  = ub.ord-doc.exch-code
      loc-exch-rate  = ub.ord-doc.exch-rate
      loc-exch-scale = ub.ord-doc.exch-scale
      loc-base-rate  = ub.ord-doc.base-rate
      loc-base-scale = ub.ord-doc.base-scale
      vat_type       = ub.ord-doc.vat-type
      slt_type       = ub.ord-doc.slt-type
      loc-cli-code   = ub.ord-doc.cli-code
      loc-cli-type   = ub.ord-doc.cli-type
      loc-ord-num    = ub.ord-doc.doc-code
      .
    find first shar_ord-doc no-lock  where shar_ord-doc.doc-code = ord-doc.doc-code no-error .
    if loc-make-avto = false then do:
       run cus/ord-frm.w (input Parparentproc  , input r-tmp , input line-mode , output r-stop, output r-exit ) .
    end.
    if r-stop = true  then do:
        run p-delete in this-procedure ( r-tmp ,input-output ii ) .
        return error.
    end.
    if r-exit = true  then do:
        run p-delete in this-procedure ( r-tmp ,input-output ii ) .
    end.
    if r-stop = false and r-exit = false  then do:
        find current ub.ord-line  exclusive-lock  no-error .
        BUFFER-COPY   TMP#zakaz to ub.ord-line.
    end.
end.
else do:
end.
end.
END PROCEDURE.
PROCEDURE ord-header :
do
 on error undo, return error return-value
 :
find first shar-buf_ord-doc no-lock   where shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code no-error  .
    run cus/ord-zakz.p
    (     INPUT   PARPARENTPROC ,
          INPUT   'ИЗМЕНЕНИЕ':U      ,
          input   shar-buf_ord-doc.doc-type,
          OUTPUT  DOC-REC ,
          input-output  br-handle ,
          input-output  bf-handle ,
          input-output  next-prev
          ) .
end.
END PROCEDURE.
PROCEDURE p-delete :
 do
 on error undo, return error return-value
 :
    define input parameter tmp-recid as recid no-undo .
    define input-output parameter ii as integer no-undo . .
    define buffer buf_doc-line for ub.ord-line .
    find first tmp#zakaz where recid(tmp#zakaz) = tmp-recid no-error .
    if not avail tmp#zakaz then return error.
    find first buf_doc-line  exclusive-lock    where
        buf_doc-line.doc-code        = loc-ord-num    and
        buf_doc-line.prod-type       = tmp#zakaz.prod-type and
        buf_doc-line.prod-code       = tmp#zakaz.prod-code and
        buf_doc-line.artic           = tmp#zakaz.artic     no-error.
    if not available buf_doc-line  then  return error .
    delete buf_doc-line .
    delete tmp#zakaz .
    ii = ii - 1 .
 end.
END PROCEDURE.
PROCEDURE p-mark :
do
 on error undo, return error return-value
 :
find current tt-goods no-error .
find current ub.ord-gds-cons no-error .
if not available tt-goods then do:
     message "Неправильный выбор строки.".
     return no-apply.
     end.
    IF    tt-goods.use = true THEN DO:
          tt-goods.use = false.
          disp "" @ tt-goods.use with browse browse-12.
      End.
      Else DO:
           tt-goods.use = true.
           disp "+" @ tt-goods.use with browse browse-12.
      End.
     apply "VALUE-CHANGED" to browse-12 in frame frame-A.
     gg-recid = recid(tt-goods) .
     g#log = browse-12:select-next-row ().
end.
END PROCEDURE.
PROCEDURE plus-mark :
do
 on error undo, return error return-value
 :
define variable  pp-rec as recid no-undo .
pp-rec = recid (tt-goods) .
for each tt-goods  exclusive-lock  :
   tt-goods.use = true.
end.
OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
reposition BROWSE-12 to recid pp-rec no-error .
end.
END PROCEDURE.
PROCEDURE post-1 :
do
 on error undo, return error return-value
 :
  define variable  o-rec as recid no-undo.
  define variable  l-rec as recid no-undo.
  run make-fp-rcv in this-procedure ( input "1" ,output o-rec, output l-rec) .
  OPEN QUERY BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = 'out':U       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
  reposition BROWSE-27 to recid o-rec  no-error .
end.
END PROCEDURE.
PROCEDURE post-2 :
do
 on error undo, return error return-value
 :
  if not t-gds then do:
      message "Создание по (+) возможно только в режиме 'развернуть'. "
              "Воидете в режим ПО ДОКУМЕНТАМ и включите переключатель РАЗВЕРНУТЬ ." view-as alert-box .
      return .
  end.
  define variable  o-rec as recid no-undo.
  define variable  l-rec as recid no-undo.
  run make-fp-rcv in this-procedure ( input "2", output o-rec, output l-rec) .
  OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
  reposition BROWSE-18 to recid l-rec no-error.
  OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
end.
END PROCEDURE.
PROCEDURE post-3 :
 do
 on error undo, return error return-value
 :
 if t-gds then do:
    message "Нельзя внутри развернутого заказа делать поставку по текущему товару ."
            "Перейдите в режим ПО ТОВАРАМ ."
            view-as alert-box information .
    return.
 end.
  define variable  o-rec as recid no-undo.
  define variable  l-rec as recid no-undo.
  run make-fp-rcv in this-procedure ( input "3", output o-rec, output l-rec) .
  OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
  reposition BROWSE-18 to recid l-rec no-error.
  OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
end.
END PROCEDURE.
PROCEDURE post-4 :
do
 on error undo, return error return-value
 :
define variable  o-rec as recid no-undo.
define variable  l-rec as recid no-undo.
run make-post-in in this-procedure ( output o-rec , output l-rec) .
    OPEN QUERY BROWSE-23 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-type = 'in'  AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK.
    .
    reposition BROWSE-23 to recid o-rec no-error.
end.
END PROCEDURE.
PROCEDURE post-4-gds :
 do
 on error undo, return error return-value
 :
define input parameter l-mod as character no-undo .
define variable  o-rec as recid no-undo.
define variable  l-rec as recid no-undo.
if caps(l-mod) = "M_H_0" then
   run make-post-gds-in in this-procedure ( 1, output o-rec , output l-rec ) .
 else
   run make-post-gds-in in this-procedure ( 2, output o-rec , output l-rec ) .
   OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
   reposition BROWSE-20 to recid l-rec no-error.
end.
END PROCEDURE.
PROCEDURE post-5 :
do
 on error undo, return error return-value
 :
  define variable  o-rec as recid no-undo.
  define variable  l-rec as recid no-undo.
  run make-fp-rcv in this-procedure ( input "4" ,output o-rec, output l-rec).
  OPEN QUERY BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = 'out':U       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
  reposition BROWSE-27 to recid o-rec no-error.
end.
END PROCEDURE.
PROCEDURE pr-main :
do
 on error undo, return error return-value
 :
define variable p-recid as recid no-undo .
define buffer l_tt-goods for tt-goods .
p-recid =  ? .
assign frame dialog-frame  r-main .
find first l_tt-goods where
  l_tt-goods.artic = x-artic and
  l_tt-goods.prod-type = x-prod-type and
  l_tt-goods.prod-code = x-prod-code and
  l_tt-goods.gds-t     = 'товар':U no-error .
  if avail   l_tt-goods then   p-recid = recid(l_tt-goods).
case r-main :
when 1 then
 do:
   t-prt = false.
   T-of = true.
   run proc-prt in this-procedure .
   run proc-t-of in this-procedure .
   reposition browse-12 to recid p-recid no-error .
   run br-12 in this-procedure .
 end.
when 2 then
   do:
     T-of = false.
     t-prt = false.
     run proc-prt in this-procedure .
     run proc-t-of in this-procedure .
     reposition browse-12 to recid p-recid no-error  .
     run br-12 in this-procedure .
   end.
when 3 then
   do:
      t-prt = true.
      T-of  = false.
      run proc-t-of in this-procedure .
      run proc-prt in this-procedure .
      reposition browse-30 to recid p-recid no-error  .
      run br-12 in this-procedure .
   end.
end case.
frame frame-d:MOVE-TO-BOTTOM ( )  .
frame frame-f:MOVE-TO-BOTTOM ( )  .
frame frame-a:MOVE-TO-TOP ( )  .
frame frame-a:TOP-ONLY  .
end.
END PROCEDURE.
PROCEDURE proc-50 :
do
 on error undo, return error return-value
 :
define variable ll-rec as recid no-undo .
define variable v-doc-mode as character no-undo .
  find current ub.ord-line-rcv no-lock  no-error .
  find current new-rcv no-lock  no-error .
  if avail  new-rcv then do:
     ll-rec = recid ( new-rcv ) .
     if  new-rcv.status_ = 'новый':U then do:
          run cus/or-obj.w
                ( input  parParentProc
                , input  g#host-code
                , input  recid(new-rcv)
                , input  3
                , input  'ИЗМЕНЕНИЕ':U
                , input  'ИЗМЕНЕНИЕ':U
                , input-output  v-doc-mode  ) .
          g#log = BROWSE-21:refresh() in frame frame-postavki  no-error .
          run calc-cons-ord in this-procedure .
     end.
     else do:
        if new-rcv.status_ = 'согласование':U
            then
                message "Статус поставки " new-rcv.status_ ". Корректировать нельзя ."
                "Для проставления времени фактической доставки используйте другие режимы ! "
                view-as alert-box .
            else  message "Статус поставки " new-rcv.status_ ". Корректировать нельзя !  "
                  view-as alert-box .
     end.
  end.
end.
END PROCEDURE.
PROCEDURE proc-52 :
do
 on error undo, return error return-value
 :
 define variable v-recid as recid no-undo .
  find current ub.ord-line-rcv no-lock  no-error .
  if avail ub.ord-doc-rcv  then do:
     v-recid = recid(ub.ord-doc-rcv) .
     run cus/lkp-rcv.w ( parParentProc, input-output v-recid) .
  end.
  end.
END PROCEDURE.
PROCEDURE proc-522 :
do
 on error undo, return error return-value
 :
  define variable v-recid as recid no-undo .
  find current new-rcv no-lock  no-error .
  if avail new-rcv then do :
     v-recid = recid(new-rcv) .
     run cus/lkp-rcv.w ( parParentProc, input-output v-recid ) .
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-14 :
do
 on error undo, return error return-value
 :
define variable d-rec as recid no-undo.
if avail  ub.doc-line then do:
  g#log = no.
  message "Удалить строку в накладной №" ub.doc-line.doc-code "?   Вы уверены ?"
          view-as alert-box question buttons OK-Cancel update g#log.
    if g#log = false then return.
    d-rec = recid (doc-line).
    run del-nacl in this-procedure (d-rec).
    OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.
end.
end.
END PROCEDURE.
PROCEDURE proc-b-20 :
do
 on error undo, return error return-value
 :
define variable d-rec as recid no-undo.
if avail  ub.trn-doc then do:
  g#log = no.
  message "Удалить накладную №" ub.trn-doc.doc-code "?   Вы уверены ?"
  view-as alert-box question buttons OK-Cancel update g#log.
  if g#log = false then return.
  if avail  ub.trn-doc then do:
  d-rec = recid (trn-doc).
  run del-nacl-doc in this-procedure (d-rec).
  OPEN QUERY BROWSE-24 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK,              EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
end.
end.
end.
END PROCEDURE.
PROCEDURE proc-b-31 :
do
 on error undo, return error return-value
 :
define variable d-rec as recid no-undo.
g#log = no.
find current ub.ord-doc-rcv no-lock no-error .
if avail  ub.ord-doc-rcv then do:
  message "Удалить поставку №" ub.ord-doc-rcv.rcv-code "?   Вы уверены ?"
  view-as alert-box question buttons OK-Cancel update g#log.
  if g#log = false then return.
  d-rec = recid (ub.ord-doc-rcv).
  run del-post-doc in this-procedure (d-rec).
  OPEN QUERY BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = 'out':U       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
  end.
  end.
END PROCEDURE.
PROCEDURE proc-b-51 :
do
 on error undo, return error return-value
 :
if not available ub.trn-doc then return .
  g#log = no.
  message "Удалить накладную №" ub.trn-doc.doc-code "?   Вы уверены ?"
        view-as alert-box question buttons OK-Cancel update g#log.
        if g#log = false then return.
  find first  ub.ord-chain exclusive-lock where
        ub.ord-chain.rel-doc-code = ub.trn-doc.doc-code and
        ub.ord-chain.doc-type = 'rcv'                and
        ub.ord-chain.rel-doc-type = 'trn'
  no-error .
  if available ub.ord-chain then delete ub.ord-chain .
  run del-nacl-doc in this-procedure ( recid (trn-doc) ).
  OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .
  OPEN QUERY BROWSE-21 FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK.
end.
END PROCEDURE.
PROCEDURE proc-b-54 :
do
 on error undo, return error return-value
 :
 define variable v-recid as recid no-undo .
 if avail  ub.ord-doc-rcv then do:
     v-recid =  recid(ub.ord-doc-rcv) .
     run cus/lkp-rcv.w ( parParentProc, input-output v-recid ) .
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-56 :
do
 on error undo, return error return-value
 :
 define variable v-doc-mode as character no-undo .
  if avail  ub.ord-line-rcv then do:
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  'ИЗМЕНЕНИЕ':U
             , input  'ПРОСМОТР':U
             , input-output  v-doc-mode  ) .
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-58 :
do
 on error undo, return error return-value
 :
define variable v-doc-mode as character no-undo .
define variable ll-rec as recid no-undo .
find current ub.ord-line-rcv no-lock  no-error .
    if available ub.ord-line-rcv  then do:
     ll-rec = recid(ord-line-rcv) .
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  'ИЗМЕНЕНИЕ':U
             , input  'ПРОСМОТР':U
             , input-output  v-doc-mode  ) .
     end.
end.
END PROCEDURE.
PROCEDURE proc-b-7 :
do
 on error undo, return error return-value
 :
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .
define variable ll-rec as recid no-undo .
define variable v-doc-mode as character no-undo .
  find current ub.ord-line-rcv no-lock  no-error .
    if avail  ub.ord-line-rcv then do:
     find first buf_ord-doc-rcv no-lock where
                buf_ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code and
                buf_ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code no-error .
     if buf_ord-doc-rcv.status_ <> 'новый':U   then do:
        message "Нельзя корректировать поставку в статусе " caps(buf_ord-doc-rcv.status_) view-as alert-box information .
        return.
     end.
     ll-rec = recid(b-all_ord-doc-rcv) .
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  'ИЗМЕНЕНИЕ':U
             , input  'ИЗМЕНЕНИЕ':U
             , input-output  v-doc-mode  ) .
     g#log = BROWSE-20:refresh() in frame frame-h  no-error .
     run calc-cons-ord in this-procedure .
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-ins-za :
 do
 on error undo, return error return-value
 :
for each tt-goods :
  delete tt-goods.
end.
for each my-obj :
  delete my-obj.
end.
run new-zayvka in this-procedure .
  end.
END PROCEDURE.
PROCEDURE proc-b-ok :
do
 on error undo, return error return-value
 :
    if not can-find( first tt-goods no-lock  ) then do:
      message "В совокупной заявке нет ни одного товара ! Удаляем заявку ?"
        view-as alert-box question
        buttons yes-no
        update g#log
      .
      if g#log then  do:
          find first ub.ord-cons  exclusive-lock  where ub.ord-cons.cons-code = loc-ord-cons-code no-error .
          if error-status :error then do:
              message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)  .
              return.
              end.
          delete ub.ord-cons.
          end.
    end.
end.
END PROCEDURE.
PROCEDURE proc-br-16 :
do
 on error undo, return error return-value
 :
if frame FRAME-postavki:visible and avail ub.ord-doc and T-of then do:
  OPEN QUERY BROWSE-21 FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK.
  BROWSE-29:title = "По заявке № "  + ub.ord-doc.doc-code. .
  OPEN QUERY BROWSE-29 FOR EACH ub.new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,      EACH ub.ord-line-rcv WHERE                       ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND                           ub.ord-line-rcv.doc-code = new-rcv.doc-code NO-LOCK,      FIRST ub.bb_ord-doc WHERE bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK .
end.
end.
END PROCEDURE.
PROCEDURE proc-br-18 :
do
 on error undo, return error return-value
 :
find current tt-new-ord-line no-lock no-error.
if avail tt-new-ord-line then do:
      loc-num-ord-FP = tt-new-ord-line.doc-code .
      if not t-gds then do:
          OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
          end.
      else do:
          OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE           ub.ord-doc-rcv.cons-code = loc-ord-cons-code and           ub.ord-doc-rcv.doc-code = loc-num-ord-FP and           ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,        EACH ub.ord-line-rcv WHERE                   ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and            ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and                  ( T-gds = true or (                         ub.ord-line-rcv.artic = tt-goods.artic                         and ub.ord-line-rcv.prod-code = tt-goods.prod-code                         and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,   EACH ub.goods where             ub.goods.artic = ub.ord-line-rcv.artic and             ub.goods.prod-code = ub.ord-line-rcv.prod-code and             ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
          browse-28:Title in frame frame-j = "Поставки по Заказу "  + loc-num-ord-FP.
      end.
end.
end.
END PROCEDURE.
PROCEDURE proc-browse-14 :
do
 on error undo, return error return-value
 :
  if frame FRAME-H:visible then do:
  OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.
  OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
  end.
end.
END PROCEDURE.
PROCEDURE proc-browse-26 :
do
 on error undo, return error return-value
 :
find current ub.ord-doc no-lock no-error.
if avail ub.ord-doc then do:
  loc-num-ord-FP = ub.ord-doc.doc-code .
  BROWSE-27:title in frame frame-k = "Поставки по заказу ФП № " + ub.ord-doc.doc-code .
  OPEN QUERY BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = 'out':U       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
  end.
end.
END PROCEDURE.
PROCEDURE proc-bt-8 :
 do
 on error undo, return error return-value
 :
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define variable d-rec as recid no-undo.
  find current ub.ord-line-rcv no-lock no-error .
  if avail  ub.ord-line-rcv then do:
    g#log = no.
    message "Удалить строку в поставке №" ub.ord-line-rcv.rcv-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update g#log.
      if g#log = false then return.
     find first buf_ord-doc-rcv no-lock where
                buf_ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code and
                buf_ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code no-error .
     if avail  buf_ord-doc-rcv then do:
        if buf_ord-doc-rcv.status_ <> 'новый':U   then do:
            message "Нельзя Удалять поставку в статусе " caps(buf_ord-doc-rcv.status_) view-as alert-box information .
            return.
            end.
     end.
  d-rec = recid (ord-line-rcv).
  run del-post in this-procedure ( d-rec ).
  OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
end.
  end.
END PROCEDURE.
PROCEDURE proc-but-10 :
do
 on error undo, return error return-value
 :
 define variable d-rec as recid no-undo.
  if avail  tt-new-ord-line then do:
    g#log = no.
    message "Удалить строку в  заказе №" tt-new-ord-line.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update g#log.
      if g#log = false then return.
  d-rec = recid (tt-new-ord-line).
  run del-zakaz in this-procedure (d-rec).
    OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
  end.
end.
END PROCEDURE.
PROCEDURE proc-but-17 :
do
 on error undo, return error return-value
 :
define variable v-doc-mode as character no-undo .
v-doc-mode  = 'ИЗМЕНЕНИЕ':U .
 if avail  ub.ord-doc-rcv  and ub.ord-doc-rcv.doc-type = "in":u  then do:
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ub.ord-doc-rcv)
             , input  3
             , input  'ИЗМЕНЕНИЕ':U
             , input  'ИЗМЕНЕНИЕ':U
             , input-output  v-doc-mode  ) .
     g#log = BROWSE-23:refresh() in frame frame-i no-error .
     run calc-cons-ord in this-procedure .
  end.
end.
END PROCEDURE.
PROCEDURE proc-but-18 :
do
 on error undo, return error return-value
 :
define variable d-rec as recid no-undo.
g#log = no.
find current ub.ord-doc-rcv no-lock no-error .
if avail  ub.ord-doc-rcv then do:
message "Удалить поставку №" ub.ord-doc-rcv.doc-code "?   Вы уверены ?"
                 view-as alert-box question buttons OK-Cancel update g#log.
if g#log = false then return.
  d-rec = recid (ub.ord-doc-rcv).
  run del-post-doc in this-procedure (d-rec).
  OPEN QUERY BROWSE-23 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-type = 'in'  AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK.
end.
end.
END PROCEDURE.
PROCEDURE proc-color-status :
do
 on error undo, return error return-value
 :
define input parameter num-m    as integer no-undo .
define input parameter p-status as character no-undo .
define variable h-cell    as handle no-undo .
define variable kk as integer no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries( handle-br-all [num-m] ).
 do kk =  1 to v-nn :
     h-cell =  WIDGET-HANDLE(entry(kk, handle-br-all [num-m] )) .
     run color-cell in this-procedure ( h-cell, user-color-status , p-status , 'новый':U) .
 end.
end.
END PROCEDURE.
PROCEDURE proc-color-str :
do
 on error undo, return error return-value
 :
  if tt-goods.gds-t = 'признак':U then
     assign
       tt-goods.artic      :fgcolor in browse browse-30 = blue_color
       tt-goods.all-name   :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-qnty   :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-ord    :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-rcv    :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-rcv-in :fgcolor in browse browse-30 = blue_color
       tt-goods.unit-base  :fgcolor in browse browse-30 = blue_color
       tt-goods.unit-cli   :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-fact   :fgcolor in browse browse-30 = blue_color
       tt-goods.gds-t      :fgcolor in browse browse-30 = blue_color
        .
     else
      assign
       tt-goods.artic      :fgcolor in browse browse-30 = ?
       tt-goods.all-name   :fgcolor in browse browse-30 = ?
       tt-goods.sum-qnty   :fgcolor in browse browse-30 = ?
       tt-goods.sum-ord    :fgcolor in browse browse-30 = ?
       tt-goods.sum-rcv    :fgcolor in browse browse-30 = ?
       tt-goods.sum-rcv-in :fgcolor in browse browse-30 = ?
       tt-goods.unit-base  :fgcolor in browse browse-30 = ?
       tt-goods.unit-cli   :fgcolor in browse browse-30 = ?
       tt-goods.sum-fact   :fgcolor in browse browse-30 = ?
       tt-goods.gds-t      :fgcolor in browse browse-30 = ?
     .
  if tt-goods.sum-qnty - (tt-goods.sum-ord + tt-goods.sum-rcv-in) < 0 then do:
     tt-goods.sum-ord       :fgcolor in browse browse-30 = 12 .
     tt-goods.sum-rcv-in    :fgcolor in browse browse-30 = 12 .
  end.
  if tt-goods.sum-ord < tt-goods.sum-rcv then do:
     tt-goods.sum-rcv       :fgcolor in browse browse-30 = 12 .
  end.
end.
END PROCEDURE.
PROCEDURE proc-create-rcv-doc :
 do
 on error undo, return error return-value
 :
define input parameter p-PS               like ub.ord-doc-rcv.PS            no-undo .
define input parameter p-base-rate        like ub.ord-doc-rcv.base-rate     no-undo .
define input parameter p-base-scale       like ub.ord-doc-rcv.base-scale    no-undo .
define input parameter p-cli-code         like ub.ord-doc-rcv.cli-code      no-undo .
define input parameter p-cli-type         like ub.ord-doc-rcv.cli-type      no-undo .
define input parameter p-cons-code        like ub.ord-doc-rcv.cons-code     no-undo .
define input parameter p-creid            like ub.ord-doc-rcv.creid         no-undo .
define input parameter p-cycle-day        like ub.ord-doc-rcv.cycle-day     no-undo .
define input parameter p-date-pay         like ub.ord-doc-rcv.date-pay      no-undo .
define input parameter p-doc-code         like ub.ord-doc-rcv.doc-code      no-undo .
define input parameter p-doc-date         like ub.ord-doc-rcv.doc-date      no-undo .
define input parameter p-doc-type         like ub.ord-doc-rcv.doc-type      no-undo .
define input parameter p-exch-code        like ub.ord-doc-rcv.exch-code     no-undo .
define input parameter p-exch-date        like ub.ord-doc-rcv.exch-date     no-undo .
define input parameter p-exch-rate        like ub.ord-doc-rcv.exch-rate     no-undo .
define input parameter p-exch-scale       like ub.ord-doc-rcv.exch-scale    no-undo .
define input parameter p-fact-date        like ub.ord-doc-rcv.fact-date     no-undo .
define input parameter p-fact-num         like ub.ord-doc-rcv.fact-num      no-undo .
define input parameter p-fact-order       like ub.ord-doc-rcv.fact-order    no-undo .
define input parameter p-fact-ship-time   like ub.ord-doc-rcv.fact-ship-time  no-undo .
define input parameter p-fact-time        like ub.ord-doc-rcv.fact-time       no-undo .
define input parameter p-flag_            like ub.ord-doc-rcv.flag_           no-undo .
define input parameter p-host-code        like ub.ord-doc-rcv.host-code       no-undo .
define input parameter p-obj-code         like ub.ord-doc-rcv.obj-code        no-undo .
define input parameter p-obj-type         like ub.ord-doc-rcv.obj-type        no-undo .
define input parameter p-order-type       like ub.ord-doc-rcv.order-type      no-undo .
define input parameter p-rcv-code         like ub.ord-doc-rcv.rcv-code        no-undo .
define input parameter p-shift-date       like ub.ord-doc-rcv.shift-date      no-undo .
define input parameter p-shift-num        like ub.ord-doc-rcv.shift-num       no-undo .
define input parameter p-shift-name       like ub.ord-doc-rcv.shift-name      no-undo .
define input parameter p-ship-date        like ub.ord-doc-rcv.ship-date       no-undo .
define input parameter p-ship-time        like ub.ord-doc-rcv.ship-time       no-undo .
define input parameter p-status_          like ub.ord-doc-rcv.status_         no-undo .
define input parameter p-sum-service      like ub.ord-doc-rcv.sum-service     no-undo .
define input parameter p-sum-ship         like ub.ord-doc-rcv.sum-ship        no-undo .
define input parameter p-sys-date         like ub.ord-doc-rcv.sys-date        no-undo .
define input parameter p-sys-time-int     like ub.ord-doc-rcv.sys-time-int    no-undo .
define input parameter p-sys-time         like ub.ord-doc-rcv.sys-time        no-undo .
define input parameter p-tot-lines        like ub.ord-doc-rcv.tot-lines       no-undo .
define input parameter p-trn-code         like ub.ord-doc-rcv.trn-code        no-undo .
define input parameter p-user-db-num      like ub.ord-doc-rcv.user-db-num     no-undo .
define input parameter p-user-name        like ub.ord-doc-rcv.user-name       no-undo .
create ub.ord-doc-rcv.
assign
 ub.ord-doc-rcv.PS                =  p-PS
 ub.ord-doc-rcv.base-rate         =  p-base-rate
 ub.ord-doc-rcv.base-scale        =  p-base-scale
 ub.ord-doc-rcv.cli-code          =  p-cli-code
 ub.ord-doc-rcv.cli-type          =  p-cli-type
 ub.ord-doc-rcv.cons-code         =  p-cons-code
 ub.ord-doc-rcv.creid             =  p-creid
 ub.ord-doc-rcv.cycle-day         =  p-cycle-day
 ub.ord-doc-rcv.date-pay          =  p-date-pay
 ub.ord-doc-rcv.doc-code          =  p-doc-code
 ub.ord-doc-rcv.doc-date          =  p-doc-date
 ub.ord-doc-rcv.doc-type          =  p-doc-type
 ub.ord-doc-rcv.exch-code         =  p-exch-code
 ub.ord-doc-rcv.exch-date         =  p-exch-date
 ub.ord-doc-rcv.exch-rate         =  p-exch-rate
 ub.ord-doc-rcv.exch-scale        =  p-exch-scale
 ub.ord-doc-rcv.fact-date         =  p-fact-date
 ub.ord-doc-rcv.fact-num          =  p-fact-num
 ub.ord-doc-rcv.fact-order        =  p-fact-order
 ub.ord-doc-rcv.fact-ship-time    =  p-fact-ship-time
 ub.ord-doc-rcv.fact-time         =  p-fact-time
 ub.ord-doc-rcv.flag_             =  p-flag_
 ub.ord-doc-rcv.host-code         =  p-host-code
 ub.ord-doc-rcv.obj-code          =  p-obj-code
 ub.ord-doc-rcv.obj-type          =  p-obj-type
 ub.ord-doc-rcv.order-type        =  p-order-type
 ub.ord-doc-rcv.rcv-code          =  p-rcv-code
 ub.ord-doc-rcv.shift-date        =  p-shift-date
 ub.ord-doc-rcv.shift-num         =  p-shift-num
 ub.ord-doc-rcv.shift-name        =  p-shift-name
 ub.ord-doc-rcv.ship-date         =  p-ship-date
 ub.ord-doc-rcv.ship-time         =  p-ship-time
 ub.ord-doc-rcv.status_           =  p-status_
 ub.ord-doc-rcv.sum-service       =  p-sum-service
 ub.ord-doc-rcv.sum-ship          =  p-sum-ship
 ub.ord-doc-rcv.sys-date          =  p-sys-date
 ub.ord-doc-rcv.sys-time-int      =  p-sys-time-int
 ub.ord-doc-rcv.sys-time          =  p-sys-time
 ub.ord-doc-rcv.tot-lines         =  p-tot-lines
 ub.ord-doc-rcv.user-db-num       =  p-user-db-num
 ub.ord-doc-rcv.user-name         =  p-user-name
.
  end.
END PROCEDURE.
PROCEDURE proc-create-rcv-line :
 do
 on error undo, return error return-value
 :
define input parameter p-SLT-pc            like ub.ord-line-rcv.SLT-pc                 no-undo .
define input parameter p-VAT-pc            like ub.ord-line-rcv.VAT-pc                 no-undo .
define input parameter p-artic             like ub.ord-line-rcv.artic                  no-undo .
define input parameter p-cli-base-rate     like ub.ord-line-rcv.cli-base-rate          no-undo .
define input parameter p-cli-qnty          like ub.ord-line-rcv.cli-qnty               no-undo .
define input parameter p-doc-code          like ub.ord-line-rcv.doc-code               no-undo .
define input parameter p-excise            like ub.ord-line-rcv.excise                 no-undo .
define input parameter p-gds-code          like ub.ord-line-rcv.gds-code               no-undo .
define input parameter p-line-num          like ub.ord-line-rcv.line-num               no-undo .
define input parameter p-other-base        like ub.ord-line-rcv.other-base             no-undo .
define input parameter p-other-rubl        like ub.ord-line-rcv.other-rubl             no-undo .
define input parameter p-price-base        like ub.ord-line-rcv.price-base             no-undo .
define input parameter p-price-cli         like ub.ord-line-rcv.price-cli              no-undo .
define input parameter p-price-rubl        like ub.ord-line-rcv.price-rubl             no-undo .
define input parameter p-prod-code         like ub.ord-line-rcv.prod-code              no-undo .
define input parameter p-prod-type         like ub.ord-line-rcv.prod-type              no-undo .
define input parameter p-qnty              like ub.ord-line-rcv.qnty                   no-undo .
define input parameter p-rcv-code          like ub.ord-line-rcv.rcv-code               no-undo .
define input parameter p-road-tax          like ub.ord-line-rcv.road-tax               no-undo .
define input parameter p-sum-SLT           like ub.ord-line-rcv.sum-SLT                no-undo .
define input parameter p-sum-VAT           like ub.ord-line-rcv.sum-VAT                no-undo .
define input parameter p-sum-base          like ub.ord-line-rcv.sum-base               no-undo .
define input parameter p-sum-cli           like ub.ord-line-rcv.sum-cli                no-undo .
define input parameter p-sum-excise        like ub.ord-line-rcv.sum-excise             no-undo .
define input parameter p-sum-other-base    like ub.ord-line-rcv.sum-other-base         no-undo .
define input parameter p-sum-other-rubl    like ub.ord-line-rcv.sum-other-rubl         no-undo .
define input parameter p-sum-road-tax      like ub.ord-line-rcv.sum-road-tax           no-undo .
define input parameter p-sum-rubl          like ub.ord-line-rcv.sum-rubl               no-undo .
define input parameter p-sum-transport-base like ub.ord-line-rcv.sum-transport-base    no-undo .
define input parameter p-sum-transport-rubl like ub.ord-line-rcv.sum-transport-rubl    no-undo .
define input parameter p-transport-base    like ub.ord-line-rcv.transport-base         no-undo .
define input parameter p-transport-rubl    like ub.ord-line-rcv.transport-rubl         no-undo .
define input parameter p-unit-cli          like ub.ord-line-rcv.unit-cli               no-undo .
define input parameter p-v-vat             like ub.ord-line-rcv.v-vat                  no-undo .
    create  ub.ord-line-rcv.
    assign
      ub.ord-line-rcv.doc-code            = p-doc-code
      ub.ord-line-rcv.rcv-code            = p-rcv-code
      ub.ord-line-rcv.SLT-pc              = p-SLT-pc
      ub.ord-line-rcv.VAT-pc              = p-VAT-pc
      ub.ord-line-rcv.artic               = p-artic
      ub.ord-line-rcv.cli-base-rate       = p-cli-base-rate
      ub.ord-line-rcv.cli-qnty            = p-cli-qnty
      ub.ord-line-rcv.excise              = p-excise
      ub.ord-line-rcv.gds-code            = p-gds-code
      ub.ord-line-rcv.line-num            = p-line-num
      ub.ord-line-rcv.other-base          = p-other-base
      ub.ord-line-rcv.other-rubl          = p-other-rubl
      ub.ord-line-rcv.price-base          = p-price-base
      ub.ord-line-rcv.price-cli           = p-price-cli
      ub.ord-line-rcv.price-rubl          = p-price-rubl
      ub.ord-line-rcv.prod-code           = p-prod-code
      ub.ord-line-rcv.prod-type           = p-prod-type
      ub.ord-line-rcv.qnty                = p-qnty
      ub.ord-line-rcv.road-tax            = p-road-tax
      ub.ord-line-rcv.sum-SLT             = p-sum-SLT
      ub.ord-line-rcv.sum-VAT             = p-sum-VAT
      ub.ord-line-rcv.sum-base            = p-sum-base
      ub.ord-line-rcv.sum-cli             = p-sum-cli
      ub.ord-line-rcv.sum-excise          = p-sum-excise
      ub.ord-line-rcv.sum-other-base      = p-sum-other-base
      ub.ord-line-rcv.sum-other-rubl      = p-sum-other-rubl
      ub.ord-line-rcv.sum-road-tax        = p-sum-road-tax
      ub.ord-line-rcv.sum-rubl            = p-sum-rubl
      ub.ord-line-rcv.sum-transport-base  = p-sum-transport-base
      ub.ord-line-rcv.sum-transport-rubl  = p-sum-transport-rubl
      ub.ord-line-rcv.transport-base      = p-transport-base
      ub.ord-line-rcv.transport-rubl      = p-transport-rubl
      ub.ord-line-rcv.unit-cli            = p-unit-cli
      ub.ord-line-rcv.v-vat               = p-v-vat
   .
  end.
END PROCEDURE.
PROCEDURE proc-init-button-2 :
do
 on error undo, return error return-value
 :
 button-2:LOAD-IMAGE-UP("adeicon\ts-up":U)           in frame Dialog-Frame .
 F-obj:fgcolor = 1   .
 button-3:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
 button-47:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame.
 f-post:fgcolor = ? .
 f-post-2:fgcolor = ?.
  if t-prt then do:
            VIEW FRAME FRAME-b.
            OPEN QUERY BROWSE-36 FOR EACH obj_ord-dtl-rcv     WHERE x-artic      = obj_ord-dtl-rcv.artic and           x-prod-type  = obj_ord-dtl-rcv.prod-type and           x-prod-code  = obj_ord-dtl-rcv.prod-code and           string(obj_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,            EACH obj_ord-doc-rcv           where obj_ord-doc-rcv.rcv-code     = obj_ord-dtl-rcv.rcv-code and                   obj_ord-doc-rcv.doc-code   = obj_ord-dtl-rcv.doc-code and                   obj_ord-doc-rcv.doc-type   = 'in' and                   obj_ord-doc-rcv.cons-code  = loc-ord-cons-code                  NO-LOCK,          first ub.gds-prt WHERE ub.gds-prt.node-code = obj_ord-dtl-rcv.node-code NO-LOCK.    OPEN QUERY BROWSE-37 FOR EACH obj_prt-obj               WHERE obj_prt-obj.is-term = true and                           x-artic      = obj_prt-obj.artic and                     x-prod-type  = obj_prt-obj.prod-type and                     x-prod-code  = obj_prt-obj.prod-code and                     string(obj_prt-obj.prt-code) MATCHES x-node-code NO-LOCK,              each ub.gds-prt WHERE ub.gds-prt.node-code = obj_prt-obj.prt-code NO-LOCK.
            hide FRAME FRAME-e-prt.
            hide FRAME FRAME-postavki-prt.
            hide FRAME FRAME-e.
            hide FRAME FRAME-postavki.
            run proc-prt in this-procedure   .
     end.
     else  do:
            hide FRAME FRAME-b-prt.
            VIEW FRAME FRAME-b.
            VIEW FRAME FRAME-H.
            OPEN QUERY BROWSE-14 FOR EACH my-obj NO-LOCK,              EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
            OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.    OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
            OPEN QUERY BROWSE-14 FOR EACH my-obj NO-LOCK,              EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
            hide FRAME FRAME-e.
            hide FRAME FRAME-e-prt.
            hide FRAME FRAME-pos-prt.
           run proc-t-of in this-procedure  .
     end.
end.
END PROCEDURE.
PROCEDURE proc-init-button-3 :
do
 on error undo, return error return-value
 :
 button-3:LOAD-IMAGE-UP("adeicon\ts-up":U)      in frame Dialog-Frame .
 F-post-2:fgcolor = 1 .
 button-2:LOAD-IMAGE-Up ("adeicon\ts-down":U)   in frame Dialog-Frame .
 button-47:LOAD-IMAGE-Up("adeicon\ts-down":U)   in frame Dialog-Frame .
 f-obj:fgcolor  = ? .
 f-post:fgcolor = ? .
  if t-prt then do:
            VIEW FRAME FRAME-e.
            OPEN QUERY BROWSE-32 FOR EACH e_fp_ord-dtl       WHERE x-artic      = e_fp_ord-dtl.artic and x-prod-type  = e_fp_ord-dtl.prod-type and x-prod-code  = e_fp_ord-dtl.prod-code and string(e_fp_ord-dtl.node-code) MATCHES x-node-code NO-LOCK,              EACH e_fp_ord-doc OF e_fp_ord-dtl where                        e_fp_ord-doc.cons-code = loc-ord-cons-code and                        e_fp_ord-doc.doc-type = 'ФП':U                       NO-LOCK,              first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl.node-code NO-LOCK.    OPEN QUERY BROWSE-33 FOR EACH e_fp_ord-dtl-rcv               WHERE x-artic      = e_fp_ord-dtl-rcv.artic and                     x-prod-type  = e_fp_ord-dtl-rcv.prod-type and                     x-prod-code  = e_fp_ord-dtl-rcv.prod-code and                     string(e_fp_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,              EACH e_fp_ord-doc-rcv                              where e_fp_ord-doc-rcv.rcv-code            = e_fp_ord-dtl-rcv.rcv-code and                                               e_fp_ord-doc-rcv.doc-code     = e_fp_ord-dtl-rcv.doc-code and                        e_fp_ord-doc-rcv.cons-code  = loc-ord-cons-code and                        e_fp_ord-doc-rcv.doc-type    = "out":U                       NO-LOCK,              first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl-rcv.node-code NO-LOCK.
            run br-12 in this-procedure .
            hide FRAME FRAME-b.
            hide FRAME FRAME-b-prt.
            hide FRAME FRAME-postavki.
            hide FRAME FRAME-pos-prt.
            run proc-prt in this-procedure   .
           end.
     else  do:
            VIEW FRAME FRAME-e.
            OPEN QUERY BROWSE-17 FOR EACH ub.buf_clients       WHERE ( buf_clients.sup-cons = true  OR buf_clients.sup-gds = true ) NO-LOCK,       FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code   AND ub.cli-gds.cli-type = buf_clients.obj-type       AND ub.cli-gds.artic = x-artic and cli-gds.prod-type = x-prod-type and ub.cli-gds.host-code = g#host-code and cli-gds.prod-code = x-prod-code  NO-LOCK.
            apply "VALUE-CHANGED":U to BROWSE-12 in frame frame-a.
            hide FRAME FRAME-e-prt.
            hide FRAME FRAME-b.
            OPEN QUERY BROWSE-14 FOR EACH my-obj NO-LOCK,              EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
            hide FRAME FRAME-postavki.
            OPEN QUERY BROWSE-21 FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK.    OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .    OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
           run proc-t-of in this-procedure  .
    end.
end.
END PROCEDURE.
PROCEDURE proc-init-button-47 :
do
 on error undo, return error return-value
 :
 button-47:LOAD-IMAGE-UP("adeicon\ts-up":U)           in frame Dialog-Frame .
 F-post:fgcolor = 1   .
 button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
 button-3:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame.
 f-obj:fgcolor    = ? .
 f-post-2:fgcolor = ?.
  if t-prt then do:
          VIEW FRAME FRAME-postavki.
          OPEN QUERY BROWSE-21 FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK.    OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .    OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
          hide FRAME FRAME-b .
          hide FRAME FRAME-e .
          hide FRAME FRAME-b-prt .
          hide FRAME FRAME-e-prt .
          run proc-prt in this-procedure   .
     end.
     else  do:
          VIEW FRAME FRAME-postavki.
          OPEN QUERY BROWSE-21 FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK.    OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .    OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
          hide FRAME FRAME-b.
          hide FRAME FRAME-post-prt.
          OPEN QUERY BROWSE-14 FOR EACH my-obj NO-LOCK,              EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
          hide FRAME FRAME-e.
          OPEN QUERY BROWSE-17 FOR EACH ub.buf_clients       WHERE ( buf_clients.sup-cons = true  OR buf_clients.sup-gds = true ) NO-LOCK,       FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code   AND ub.cli-gds.cli-type = buf_clients.obj-type       AND ub.cli-gds.artic = x-artic and cli-gds.prod-type = x-prod-type and ub.cli-gds.host-code = g#host-code and cli-gds.prod-code = x-prod-code  NO-LOCK.
          run proc-t-of in this-procedure  .
     end.
end.
END PROCEDURE.
PROCEDURE proc-m_d_post :
do
 on error undo, return error return-value
 :
message 'TODO' .
find current new-rcv no-lock   no-error .
if avail new-rcv and new-rcv.trn-code <> "" then do:
  message  "Отменить ссылку на накладную " new-rcv.trn-code " у  поставки № " new-rcv.rcv-code  " ? "
    view-as alert-box  Question
    buttons yes-no update g#log .
  if not g#log  then return .
find current new-rcv  exclusive-lock  no-error .
  new-rcv.trn-code = "" .
  g#log = BROWSE-21:refresh() in frame frame-postavki no-error .
  OPEN QUERY BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn',        EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .
end.
end.
END PROCEDURE.
PROCEDURE proc-prt :
do
 on error undo, return error return-value
 :
define variable p-recid as recid no-undo .
   if t-prt then do:
   frame Dialog-Frame:title = ttt + "(по признакам)" .
      view FRAME FRAME-C.
      view FRAME FRAME-D-prt.
      hide FRAME FRAME-A.
      hide FRAME FRAME-D.
      if avail tt-goods then p-recid = recid(tt-goods) .
      OPEN QUERY BROWSE-30 FOR EACH tt-goods  NO-LOCK,              EACH ub.ord-gds-cons where             ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code   OUTER-JOIN   NO-LOCK     by tt-goods.nn .
      reposition browse-30 to recid p-recid no-error .
      run br-12 in this-procedure .
      if frame  frame-b:visible  then do:
        view FRAME FRAME-b-prt.
      end.
      if frame  frame-e:visible  then do:
        view FRAME FRAME-e-prt.
      end.
      if frame frame-postavki:visible  then do:
        view FRAME FRAME-post-prt.
      end.
   end.
   if not t-prt then do:
      view FRAME FRAME-A.
      view FRAME FRAME-D.
      hide FRAME FRAME-C.
      hide FRAME FRAME-D-prt.
      hide FRAME FRAME-post-prt.
      hide FRAME FRAME-e-prt.
      hide FRAME FRAME-b-prt.
      OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
   end.
end.
END PROCEDURE.
PROCEDURE proc-row-br-12 :
 do
 on error undo, return error return-value
 :
  if tt-goods.sum-qnty - (tt-goods.sum-ord + tt-goods.sum-rcv-in) < 0 then do:
     tt-goods.sum-ord       :fgcolor in browse browse-12 = 12 .
     tt-goods.sum-rcv-in    :fgcolor in browse browse-12 = 12 .
  end.
  if tt-goods.sum-ord < tt-goods.sum-rcv then do:
     tt-goods.sum-rcv    :fgcolor in browse browse-12 = 12 .
  end.
  end.
END PROCEDURE.
PROCEDURE proc-t-gds :
do
 on error undo, return error return-value
 :
assign frame  Dialog-Frame t-gds.
if t-gds then do :
 message "Развернуть Заказ ФП № " + loc-num-ord-FP "?"
  view-as alert-box question BUTTONS yes-no
  update g#log
  .
  if g#log <> true then do:
  t-gds = false.
  return no-apply.
  end.
      if frame FRAME-E:visible then do:
            view FRAME FRAME-j.
            enable   B-mark-2 with frame frame-J .
            OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
            OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE           ub.ord-doc-rcv.cons-code = loc-ord-cons-code and           ub.ord-doc-rcv.doc-code = loc-num-ord-FP and           ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,        EACH ub.ord-line-rcv WHERE                   ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and            ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and                  ( T-gds = true or (                         ub.ord-line-rcv.artic = tt-goods.artic                         and ub.ord-line-rcv.prod-code = tt-goods.prod-code                         and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,   EACH ub.goods where             ub.goods.artic = ub.ord-line-rcv.artic and             ub.goods.prod-code = ub.ord-line-rcv.prod-code and             ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
            browse-18:Title = "Заказ ФП № "  + loc-num-ord-FP.
            apply "VALUE-CHANGED":U to BROWSE-18 in frame frame-J .
            browse-28:Title = "Поставки по Заказу "  + loc-num-ord-FP.
            hide FRAME FRAME-k.
            OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ФП':U and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code and ub.ord-doc.cli-type = buf_clients.obj-type))  NO-LOCK,       FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK.    OPEN QUERY BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = 'out':U       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
        end.
  end.
else do:
  if frame FRAME-B:visible then do:
           disable  B-mark-2 with frame frame-J .
           hide FRAME FRAME-H.
           OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.    OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
           view FRAME FRAME-i.
           OPEN QUERY BROWSE-23 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-type = 'in'  AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK.    OPEN QUERY BROWSE-24 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK,              EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
 end.
  if frame FRAME-E:visible then do:
           hide FRAME FRAME-j.
           OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .    OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
           view FRAME FRAME-k.
           OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ФП':U and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code and ub.ord-doc.cli-type = buf_clients.obj-type))  NO-LOCK,       FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK.    OPEN QUERY BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = 'out':U       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
  end.
end.
end.
END PROCEDURE.
PROCEDURE proc-t-of :
do
 on error undo, return error return-value
 :
if t-of then do :
    hide t-gds in frame Dialog-Frame.
    disable t-gds with frame Dialog-Frame.
    t-gds = false.
frame Dialog-Frame:title = ttt + "(по документам)" .
 str-good = "" .
 str-good:Bgcolor = ?.
 str-good:fgcolor = ?.
 display str-good with frame Dialog-Frame.
           view FRAME FRAME-F.
           OPEN QUERY BROWSE-16 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK     BY ub.ord-doc.obj-type        BY ub.ord-doc.obj-code         BY ub.ord-doc.ship-date          BY ub.ord-doc.ship-time           BY ub.ord-doc.doc-code DESCENDING.
           hide FRAME FRAME-D.
           OPEN QUERY BROWSE-13 FOR EACH ub.m_ord-line       WHERE x-artic      = m_ord-line.artic and x-prod-type  = m_ord-line.prod-type and x-prod-code  = m_ord-line.prod-code  NO-LOCK,       EACH ub.ord-doc WHERE ub.ord-doc.doc-code = m_ord-line.doc-code       AND ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK.
  if frame FRAME-B:visible then do:
           hide FRAME FRAME-H.
           OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.    OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
           view FRAME FRAME-i.
           OPEN QUERY BROWSE-23 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-type = 'in'  AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK.    OPEN QUERY BROWSE-24 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK,              EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
 end.
  if frame FRAME-E:visible then do:
     view t-gds in frame Dialog-Frame.
     enable t-gds with frame Dialog-Frame.
     display t-gds with frame Dialog-Frame.
           hide FRAME FRAME-j.
           view FRAME FRAME-k.
           OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ФП':U and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code and ub.ord-doc.cli-type = buf_clients.obj-type))  NO-LOCK,       FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK.    OPEN QUERY BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = 'out':U       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
           apply "VALUE-CHANGED":U to BROWSE-26 in frame frame-K .
  end.
  if frame FRAME-b:visible then do:
           hide FRAME FRAME-h.
           OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.    OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
           view FRAME FRAME-i.
           OPEN QUERY BROWSE-23 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-type = 'in'  AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK.    OPEN QUERY BROWSE-24 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK,              EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
  end.
  if frame FRAME-postavki:visible and avail ub.ord-doc then do:
     OPEN QUERY BROWSE-21 FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK.
     OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
     apply "VALUE-CHANGED":U to BROWSE-12 in frame frame-a.
     apply "VALUE-CHANGED":U to BROWSE-16 in frame frame-f.
  end.
end.
else do:
 find current tt-goods no-lock no-error .
 if avail tt-goods then
    str-good = x-artic + " " + tt-goods.gds-name .
else DO:
find first tt-goods no-lock no-error .
if not avail tt-goods then return error.
    str-good = x-artic + " " + tt-goods.gds-name .
end.
 str-good:fgcolor = 15.
 str-good:bgcolor = 3.
 display str-good with frame Dialog-Frame.
frame Dialog-Frame:title = ttt + " (по товарам)" .
    hide t-gds in frame Dialog-Frame.
    disable t-gds with frame Dialog-Frame.
    t-gds = false.
        view FRAME FRAME-D.
         OPEN QUERY BROWSE-13 FOR EACH ub.m_ord-line       WHERE x-artic      = m_ord-line.artic and x-prod-type  = m_ord-line.prod-type and x-prod-code  = m_ord-line.prod-code  NO-LOCK,       EACH ub.ord-doc WHERE ub.ord-doc.doc-code = m_ord-line.doc-code       AND ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK.
        if frame FRAME-B:visible then do:
                view FRAME FRAME-H.
               OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.    OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
        end.
        if frame FRAME-E:visible then do:
                view FRAME FRAME-j.
                disable b-mark-2 with frame FRAME-j.
               OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .    OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = 'out':U NO-LOCK,            EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,             EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
                hide FRAME FRAME-k.
               OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ФП':U and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code and ub.ord-doc.cli-type = buf_clients.obj-type))  NO-LOCK,       FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK.    OPEN QUERY BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = 'out':U       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
               apply "VALUE-CHANGED":U to BROWSE-12 in frame frame-a.
                end.
        if frame FRAME-b:visible then do:
                view FRAME FRAME-h.
               OPEN QUERY BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,              EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,              EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.    OPEN QUERY BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,        EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
                hide FRAME FRAME-i.
               OPEN QUERY BROWSE-23 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-type = 'in'  AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK.    OPEN QUERY BROWSE-24 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK,              EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
        end.
        if frame FRAME-postavki:visible then do:
                 BROWSE-21:title = "Все Поставки по СЗФП" .
                  OPEN QUERY BROWSE-21 FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK.
                  OPEN QUERY BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK,              EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,              FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
              apply "VALUE-CHANGED":U to BROWSE-12 in frame frame-a.
              apply "VALUE-CHANGED":U to BROWSE-13 in frame frame-d.
        end.
end.
end.
END PROCEDURE.
PROCEDURE read-handle :
 do
 on error undo, return error return-value
 :
define input parameter  h-browse as handle no-undo .
define output parameter str-summh as character no-undo .
define variable   h-temp as handle no-undo .
define variable h-l as handle no-undo .
define variable kk as integer no-undo .
 h-temp  =  h-browse:first-column no-error .
  if  h-browse <> ?   and valid-handle(h-browse) and
      h-temp   <> ?   and valid-handle(h-temp)
     then do:
    str-summh =  string( h-temp  )  + "," .
    do kk = 2 to ( h-browse:NUM-COLUMNS  )   :
        str-summh = str-summh + string( h-temp:next-column  )  + ","  no-error .
        if error-status :error then message "Ошибка 1 " error-status :get-message(1) .
        if h-temp:next-column <> ? then do:
            h-temp = h-temp:next-column no-error .
            if error-status :error then message  "Ошибка 2 " error-status :get-message(1) .
        end.
    end.
 end.
end.
END PROCEDURE.
PROCEDURE show-gds :
do
 on error undo, return error return-value
 :
  define buffer buf_goods for ub.goods.
  if not available tt-goods then  return no-apply.
  find first buf_goods where buf_goods.gds-code = tt-goods.gds-code no-lock no-error .
  if not available buf_goods then  return no-apply.
  run str/showgds.p ( input parparentproc
                     ,input ?
                     ,input  buf_goods.gds-code
                     ,input  'ПРОСМОТР':U ).
  apply "entry" to browse-12 in frame frame-a.
end.
END PROCEDURE.
PROCEDURE status-isk :
do
 on error undo, return error return-value
 :
define variable t-rec as recid no-undo.
define buffer b_ord-line for ub.ord-line.
define buffer b_tt-goods for tt-goods.
define buffer b_ord-gds-cons for ub.ord-gds-cons.
define variable tt-qnty like tt-goods.sum-qnty  no-undo.
define variable t-ret as logical no-undo .
find current  ub.ord-doc no-lock no-error .
  if NOT available  ub.ord-doc Then do:
      message "Не выбрана заявка !!!" .
      return.
      end.
  g#log = no.
  message "Исключить заявку №" ub.ord-doc.doc-code "?   Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update g#log.
  if g#log = false then return.
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
  find current ub.ord-doc exclusive-lock.
      assign
      ub.ord-doc.cons-code = ""
      ub.ord-doc.status_= 'согласование':U
      ub.ord-doc.fact-date = ?
    .
  find current ub.ord-doc no-lock .
      for each b_ord-line no-lock  where
               b_ord-line.doc-code = ub.ord-doc.doc-code
               :
          for each b_tt-goods  exclusive-lock  where
                  b_tt-goods.artic     = b_ord-line.artic     and
                  b_tt-goods.prod-code = b_ord-line.prod-code and
                  b_tt-goods.prod-type = b_ord-line.prod-type
                  :
              find first b_ord-gds-cons  exclusive-lock  where
                        b_ord-gds-cons.cons-code = loc-ord-cons-code    and
                        b_ord-gds-cons.artic     = b_ord-line.artic     and
                        b_ord-gds-cons.prod-code = b_ord-line.prod-code and
                        b_ord-gds-cons.prod-type = b_ord-line.prod-type
                        no-error .
              tt-qnty = b_tt-goods.sum-qnty - b_ord-line.qnty.
              if tt-qnty <= 0 then do:
                                   delete b_tt-goods.
                                   delete b_ord-gds-cons.
                                   end.
                              else do:
                               assign
                                  b_ord-gds-cons.sum-qnty = tt-qnty
                                  b_tt-goods.sum-qnty = tt-qnty
                                  t-rec = recid(b_tt-goods)
                                .
                                end.
          end.
      end.
    OPEN QUERY BROWSE-16 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK     BY ub.ord-doc.obj-type        BY ub.ord-doc.obj-code         BY ub.ord-doc.ship-date          BY ub.ord-doc.ship-time           BY ub.ord-doc.doc-code DESCENDING.
    OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
    reposition BROWSE-12 to recid t-rec no-error.
    t-ret =  session:SET-WAIT-STATE("") .
end.
END PROCEDURE.
PROCEDURE status-rej :
do
 on error undo, return error return-value
 :
define variable t-rec as recid no-undo.
define buffer b_ord-line for ub.ord-line.
define buffer b_tt-goods for tt-goods.
define buffer b_ord-gds-cons for ub.ord-gds-cons.
define variable tt-qnty like tt-goods.sum-qnty  no-undo.
define variable t-ret as logical no-undo .
find current  ub.ord-doc no-lock no-error .
  if NOT available  ub.ord-doc Then do:
      message "Не выбрана заявка !!!" .
      return.
      end.
  g#log = no.
  message "Отказать заявке №" ub.ord-doc.doc-code "?   Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update g#log.
  if g#log = false then return.
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
  find current ub.ord-doc exclusive-lock.
      assign
      ub.ord-doc.cons-code = ub.ord-doc.cons-code + 'отказ':U
      ub.ord-doc.status_= 'отказ':U
      ub.ord-doc.fact-date = to-day
    .
  find current ub.ord-doc no-lock .
      for each b_ord-line no-lock  where
               b_ord-line.doc-code = ub.ord-doc.doc-code
               :
          for each b_tt-goods  exclusive-lock  where
                  b_tt-goods.artic     = b_ord-line.artic     and
                  b_tt-goods.prod-code = b_ord-line.prod-code and
                  b_tt-goods.prod-type = b_ord-line.prod-type
                  :
              find first b_ord-gds-cons  exclusive-lock  where
                        b_ord-gds-cons.cons-code = loc-ord-cons-code    and
                        b_ord-gds-cons.artic     = b_ord-line.artic     and
                        b_ord-gds-cons.prod-code = b_ord-line.prod-code and
                        b_ord-gds-cons.prod-type = b_ord-line.prod-type
                        no-error .
              tt-qnty = b_tt-goods.sum-qnty - b_ord-line.qnty.
              if tt-qnty <= 0 then do:
                                   delete b_tt-goods.
                                   delete b_ord-gds-cons.
                                   end.
                              else do:
                               assign
                                  b_ord-gds-cons.sum-qnty = tt-qnty
                                  b_tt-goods.sum-qnty = tt-qnty
                                  t-rec = recid(b_tt-goods)
                                .
                                end.
          end.
      end.
    OPEN QUERY BROWSE-16 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ОФ':U NO-LOCK     BY ub.ord-doc.obj-type        BY ub.ord-doc.obj-code         BY ub.ord-doc.ship-date          BY ub.ord-doc.ship-time           BY ub.ord-doc.doc-code DESCENDING.
    OPEN QUERY BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = 'товар':U NO-LOCK,              EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
    reposition BROWSE-12 to recid t-rec no-error.
    t-ret =  session:SET-WAIT-STATE("") .
end.
END PROCEDURE.
PROCEDURE zakaz-1 :
do
 on error undo, return error return-value
 :
  define variable  o-rec as recid no-undo.
   run make-fp in this-procedure ( input "1" , output o-rec ) no-error .
     if BROWSE-18:visible   in frame frame-j then do: OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             . end.
     if BROWSE-26:visible   in frame frame-k then do: OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ФП':U and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code and ub.ord-doc.cli-type = buf_clients.obj-type))  NO-LOCK,       FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK. end.
     If o-rec <> ? then dO:
       if BROWSE-26:visible   in frame frame-k then do: reposition BROWSE-26 to recid o-rec no-error . end.
       if BROWSE-18:visible   in frame frame-j then do: reposition BROWSE-18 to recid o-rec no-error . end.
   end.
 end.
END PROCEDURE.
PROCEDURE zakaz-1-of :
 do
 on error undo, return error return-value
 :
define buffer bbb_ord-line for ub.ord-line .
define buffer bbb_ord-doc  for ub.ord-doc .
  define variable  o-rec as recid no-undo.
  run make-fp in this-procedure ( input "3" , output o-rec).
  OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = 'ФП':U and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code and ub.ord-doc.cli-type = buf_clients.obj-type))  NO-LOCK,       FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK.
  reposition BROWSE-26 to recid o-rec no-error .
end.
END PROCEDURE.
PROCEDURE zakaz-2 :
do
 on error undo, return error return-value
 :
define variable  o-rec as recid no-undo.
  run make-fp in this-procedure ( input "2", output o-rec ).
  OPEN QUERY BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = 'ФП':U         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK,          EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK,          EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
  reposition BROWSE-18 to recid o-rec no-error .
  end.
END PROCEDURE.
PROCEDURE zayvka :
define input parameter  t-type as character no-undo .
do
 on error undo, return error return-value
 :
define variable v-par-prt as logical no-undo .
define variable P-ACTION as character no-undo .
find current ub.ord-doc exclusive-lock no-error .
if available  ub.ord-doc and ub.ord-doc.doc-type = g#type Then do:
    find first shar-buf_ord-doc no-lock   where shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code no-error  .
      bf-handle = buffer shar-buf_ord-doc:handle .
      if t-type <> "lkp" then do:
         if t-type = "add" then P-ACTION = 'ДОБАВЛЕНИЕ':U .
                           else P-ACTION = 'ИЗМЕНЕНИЕ':U .
          run cus/ord-zakz.p
          (     input   parparentproc ,
                input   p-action      ,
                input   g#type ,
                output  doc-rec      ,
                input-output  br-handle ,
                input-output  bf-handle ,
                input-output  next-prev
                    ) .
          run calc-cons-ord in this-procedure .
      end.
      else do:
          next-prev = no.
          do while next-prev <> ?:
            if not available ub.ord-doc then do:
              message "Неправильный выбор документа.".
              return no-apply.
            end.
            run cus/ord-zakz.p
            (   input   parparentproc ,
                input   'ПРОСМОТР':U     ,
                input   g#type        ,
                output  doc-rec       ,
                input-output  br-handle ,
                input-output  bf-handle ,
                input-output  next-prev
                ) .
          end.
      end.
end.
end.
END PROCEDURE.
FUNCTION mark-string RETURNS CHARACTER
  ( buffer loc-t-doc_ord-line for tt-new-ord-line ) :
  if can-do (del-list, string (recid (loc-t-doc_ord-line))) then RETURN "+".
  RETURN "".
END FUNCTION.
