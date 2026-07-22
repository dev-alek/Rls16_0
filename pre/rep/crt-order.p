block-level on error undo, throw.
define temp-table  tt-dateZakaz     no-undo
field id as integer
field dateStart as date
field dateEnd as date
index pi id
    .
DEFINE TEMP-TABLE tt-typeDocChoose NO-UNDO
  field type-code as character
  field typeName  as character.
define temp-table gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
 define temp-table choose-gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
  define temp-table tt-gds-list like ub.goods
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi gds-code.
define input parameter parparentproc as handle    no-undo .
define input parameter iDateOrder    as date      no-undo.
define input parameter iClientType   like ub.clients.obj-type no-undo.
define input parameter iClientCode   like ub.clients.obj-code no-undo.
define input parameter iParams       as character             no-undo.
define variable vss-revision    as character no-undo init "$Revision: 8f5f559ebdb3, 2359, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-rsrv-plan.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-rsrv-plan.p $":U .
define variable vss-description as character no-undo init "Отчет по планированию заказов".
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
define variable mySeqOrder as int64 no-undo init ?.
procedure MySeqForOrder:
   define input  parameter iTable      as character no-undo.
   define input  parameter iSeqNameHist as character no-undo.
   define input  parameter iDbName     as character no-undo.
   define output parameter oSeq        as int64 no-undo.
   if iTable begins "order-"
   then do:
      if mySeqOrder eq ?
      then
         mySeqOrder = dynamic-next-value(iSeqNameHist,iDbName).
      oSeq = mySeqOrder.
   end.
   else
      oSeq = ?.
   return.
end.
define  shared temp-table tt-zakaz like ub.order-line
    field gds-name          as character
    field minZapas          as decimal
    field volMinZapas       as integer
    field ostatokDay        as decimal
    field qntyDaySale       as integer
    field qntyDayGoods      as integer
    field ostatokGoods      as decimal
    field qntyDay           as integer
    field contract-prn-code as character
    field contract-code     as integer
    index pi    gds-code          contract-code
    index artic artic             prod-type         prod-code
    index contr contract-prn-code.
define  shared temp-table temp-gds-qnty no-undo
    field day      as date
    field ost      as decimal
    field gds-code as integer
    index pi is unique primary day gds-code
    index by-ost               ost .
define variable vDocCode as integer no-undo.
define variable vLine    as integer no-undo.
define buffer buf_order-doc       for ub.order-doc .
define buffer buf_order-line      for ub.order-line .
define buffer buf_clients         for ub.clients .
define buffer buf_goods           for ub.goods .
define buffer buf_contract-specif for ub.contract-specif .
define variable orderStatus  as class ibs.th.str.order.sts.order no-undo .
orderStatus =  new ibs.th.str.order.sts.order().
if not can-find (first tt-zakaz) then
  return.
MAIN:
do transaction on error undo MAIN, leave MAIN:
    find first buf_clients no-lock where
               buf_clients.obj-type = iClientType
           and buf_clients.obj-code = iClientCode.
    for each tt-zakaz no-lock
             break by tt-zakaz.contract-code by tt-zakaz.gds-code:
      if first-of(tt-zakaz.contract-code) then
      do:
        subscribe "getNextseq" anywhere run-procedure "MySeqForOrder".
        create buf_order-doc.
        assign
          vDocCode                        = next-value (s-order-code, ub)
          buf_order-doc.obj-type          = v-cntxt-obj-type
          buf_order-doc.obj-code          = v-cntxt-obj-code
          buf_order-doc.doc-code          = vDocCode
          buf_order-doc.doc-date          = now
          buf_order-doc.order-date        = today + 1
          buf_order-doc.cli-type          = iClientType
          buf_order-doc.cli-code          = iClientCode
          buf_order-doc.cli-name          = if avail buf_clients then buf_clients.obj-name else ""
          buf_order-doc.contract-code     = tt-zakaz.contract-code
          buf_order-doc.contract-prn-code = tt-zakaz.contract-prn-code
          buf_order-doc.user-id           = v-cntxt-userid
          buf_order-doc.sts               = orderStatus:NewStatus:KeyIntDB
          buf_order-doc.params            = iParams
        .
        validate buf_order-doc.
      end.
      else do:
        find first buf_order-doc exclusive-lock where
                   buf_order-doc.db-num   = g#db-num
               and buf_order-doc.doc-code = vDocCode no-error.
        if not avail  buf_order-doc then
        do:
          message "Ошибка при создании заказа. Заказы созданы не будут." view-as alert-box.
          undo MAIN, leave MAIN.
        end.
      end.
      find first buf_goods no-lock where
                 buf_goods.gds-code = tt-zakaz.gds-code.
      create buf_order-line.
      assign
         vLine = vLine + 1
         buf_order-line.doc-code      = buf_order-doc.doc-code
         buf_order-line.db-num        = buf_order-doc.db-num
         buf_order-line.line-num      = vLine
         buf_order-line.gds-code      = tt-zakaz.gds-code
         buf_order-line.artic         = tt-zakaz.artic
         buf_order-line.prod-type     = if avail buf_goods then buf_goods.prod-type else ""
         buf_order-line.prod-code     = if avail buf_goods then buf_goods.prod-code else 0
         buf_order-line.order-qnty    = tt-zakaz.order-qnty
         buf_order-line.fact-qnty     = tt-zakaz.order-qnty
         buf_order-line.rest          = tt-zakaz.rest
         buf_order-line.sales         = tt-zakaz.sales
         buf_order-line.average-sales = tt-zakaz.average-sales
         buf_order-line.stock-goods   = if tt-zakaz.average-sales = 0 and tt-zakaz.ostatokDay <> 0 then -1 else integer(tt-zakaz.ostatokGoods)
         buf_order-line.volume-goods  = tt-zakaz.volume-goods
         buf_order-line.volume-stock  = if tt-zakaz.minZapas > tt-zakaz.rest then tt-zakaz.minZapas else tt-zakaz.volMinZapas
         buf_order-line.min-stock     = tt-zakaz.min-stock
         buf_order-line.garant-stock  = tt-zakaz.garant-stock
         buf_order-line.promo         = tt-zakaz.promo
      .
      validate buf_order-line.
      validate buf_order-doc.
      if last-of(tt-zakaz.contract-code) then
      do:
        unsubscribe "getNextseq".
      end.
    end.
end.
