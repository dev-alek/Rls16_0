define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter doc-rec       as recid no-undo .
define input  parameter line-rec       as recid no-undo .
define input  parameter gds-rec        as recid no-undo .
define input  parameter prt-mode       as character no-undo .
define input  parameter cur-rec  as recid no-undo.
define input  parameter node-type as char no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " Задание факт. количества и цены по признаку в поставках".
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
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable base-code as integer   no-undo .
define variable g#type as character no-undo .
define variable prt-rec as recid no-undo .
define variable loc-cli-base-rate as decimal no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
run get-report-num in parParentProc ( output g#report-num ).
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  g#host-code
  ,output base-code
  )  .
 define variable g#ret-sup-pay as integer   no-undo .
 define buffer buf_sysconf for ub.sysconf.
 find first buf_sysconf no-lock where buf_sysconf.host-code = g#host-code no-error .
 g#ret-sup-pay = buf_sysconf.ret-sup-pay .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table tmp#zakaz1 no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field local-mark    as character field max-stock     as decimal   field season-coef   as decimal   field min-stock-old as decimal   field gds-way       as decimal   index pi is unique primary artic prod-type prod-code  ascending index idx-ln line-num.
define shared temp-table tmp#zakaz-prn1 no-undo field artic         like ub.goods.artic      field prod-type     like ub.goods.prod-type  field prod-code     like ub.goods.prod-code  field obj-type      like ub.clients.obj-type field obj-code      like ub.clients.obj-code field prt-code      as   integer    field qnty-sale     as   decimal    field qnty-ord      as   decimal    index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.
define shared temp-table tmp#zakaz-dtl1 no-undo like ub.ord-dtl field prt-name as character index bi is unique primary artic prod-type prod-code node-code  ascending.
define  shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define  shared buffer buf-goods   for ub.goods     .
define  shared buffer sb-cli-gds  for ub.cli-gds   .
define  shared buffer sb-gds-obj  for ub.gds-obj   .
define  shared buffer tmp#zakaz     for tmp#zakaz1.
define  shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define  shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define  shared  buffer shar_ord-doc  for ub.ord-doc .
define  shared  buffer shar_ord-line for ub.ord-line.
define  shared  buffer shar_ord-dtl  for ub.ord-dtl .
define  shared variable chexcelapplication      as com-handle no-undo .
define  shared variable chworkbook              as com-handle no-undo .
define  shared variable chworksheet             as com-handle no-undo .
define  shared variable chrange                 as com-handle no-undo .
define  shared variable chworksheet2            as com-handle no-undo .
define  shared variable chworksheet3            as com-handle no-undo .
define  shared variable accum-zakaz             as decimal no-undo .
define  shared variable accum-sum-zakaz         as decimal no-undo .
define  shared variable accum-count             as integer no-undo .
define  shared buffer buf-cli for ub.clients.
define  shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.
define  shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.
define  shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.
define    shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.
define    shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.
define    shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.
define    shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.
define    shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.
define    shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
define    shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.
define   shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.
define   shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.
define  shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.
define    shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.
define  shared variable loc-status  as character  no-undo.
define  shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.
define  shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.
define  shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.
define  shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.
define  shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.
define  shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.
define  shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.
define  shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.
define  shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(руб.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(руб)"
     fgcolor 4
     no-undo.
define  shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.
define  shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.
define  shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.
define  shared var loc-print-rubl as logical no-undo .
define  shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define    shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.
define  shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define  shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define  shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define  shared  variable temp-e-method  as character no-undo .
define  shared  variable x-tog-artic as logical   no-undo .
define  shared  variable x-tog-grp    as logical   no-undo .
def buffer g-d-b-ord-dtl for ub.ord-dtl-rcv .
define variable chg-qnty         like ub.gds-dtl.doc-qnty init ? no-undo.
define variable kk as decimal no-undo .
DEF buffer b-c-b        for ub.bar-code.
def buffer out-dtl      for ub.ord-dtl-rcv .
define buffer b-ord-line     for  ub.ord-line-rcv .
define buffer b-ord-gds-dtl  for  ub.ord-dtl-rcv .
DEFINE QUERY br-dtl FOR b-ord-gds-dtl, ub.gds-prt, ub.goods, ub.bar-code SCROLLING.
define variable varis-new     as logical             no-undo.
define buffer bf_goods          for ub.goods.
define buffer bf_units          for ub.units.
define buffer rt_tax            for ub.tax.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 7.5 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 7.5 BY 1.
DEFINE VARIABLE base-curr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE cli-curr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-cli AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 18.13 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 23.25 BY .6
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.88 BY 4.17.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 19.75 BY 4.04
     BGCOLOR 3 FGCOLOR 15 .
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 27 BY 1.25
     BGCOLOR 3 FGCOLOR 15 .
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 89.13 BY 3.08.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.75 BY 4.33.
DEFINE FRAME d-out-prt
     b-exit AT ROW 1.29 COL 2
     b-help AT ROW 2.29 COL 2
     b-ord-gds-dtl.qnty AT ROW 9.21 COL 82.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 13 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.price-rubl AT ROW 9.29 COL 6.63 COLON-ALIGNED
          LABEL "Цена"
          VIEW-AS FILL-IN NATIVE
          SIZE 17 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.price-base AT ROW 9.29 COL 30.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN  NATIVE
          SIZE 17 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.price-cli AT ROW 9.29 COL 50.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN  NATIVE
          SIZE 18.13 BY 1
          BGCOLOR 15 FGCOLOR 4
     b-ord-gds-dtl.cli-qnty AT ROW 10.38 COL 82.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN  NATIVE
          SIZE 13 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.artic AT ROW 1.67 COL 9.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 16.5 BY 1
     ub.goods.gds-name AT ROW 1.67 COL 26.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 68.88 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.prod-code AT ROW 3 COL 9.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12.63 BY 1
     b-ord-gds-dtl.prod-type AT ROW 3 COL 22.13 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 16.63 BY 1
     ub.clients.obj-name AT ROW 3 COL 39 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 56.25 BY 1
          FGCOLOR 4
     ub.bar-code.b-code AT ROW 4.79 COL 17 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 10 BY .58
          FGCOLOR 4
     ub.gds-prt.f-name AT ROW 4.79 COL 27.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 39.75 BY .58
          FGCOLOR 4
     ub.prt-obj.free-qnty AT ROW 4.79 COL 78.88 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 16.25 BY .58
          FGCOLOR 4
     ub.price-list.doc-num AT ROW 5.63 COL 16.88 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 16 BY .58
     ub.goods.unit-base AT ROW 9.29 COL 77.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY 1
          FGCOLOR 4
     ub.goods.unit-cli AT ROW 10.38 COL 77.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY 1
          BGCOLOR 3 FGCOLOR 15
     tot-base AT ROW 10.46 COL 30.5 COLON-ALIGNED NO-LABEL
     tot-cli AT ROW 10.46 COL 50.5 COLON-ALIGNED NO-LABEL
     tot-rubl AT ROW 10.71 COL 6.38 COLON-ALIGNED
     ub.goods.qnty-cart AT ROW 11.58 COL 96.88 RIGHT-ALIGNED
          LABEL "Кол.в упак."
           VIEW-AS TEXT
          SIZE 13 BY .6
          FGCOLOR 4
     cli-curr AT ROW 11.75 COL 50.75 COLON-ALIGNED NO-LABEL
     base-curr AT ROW 11.83 COL 30.5 COLON-ALIGNED NO-LABEL
     RECT-5 AT ROW 4.42 COL 1.13
     RECT-4 AT ROW 1.25 COL 9.75
     RECT-3 AT ROW 10.29 COL 71.88
     RECT-1 AT ROW 8.79 COL 1
     "РУБ" VIEW-AS TEXT
          SIZE 4 BY 1 AT ROW 11.83 COL 8.63
          FGCOLOR 4
     RECT-2 AT ROW 8.92 COL 51.75
     SPACE(27.49) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME d-out-prt:SCROLLABLE       = FALSE.
find b-ord-line where
                          b-ord-line.doc-code   = b-ord-gds-dtl.doc-code
                      and b-ord-line.rcv-code   = b-ord-gds-dtl.rcv-code
                      and b-ord-line.prod-code  = b-ord-gds-dtl.prod-code
                      and b-ord-line.prod-type  = b-ord-gds-dtl.prod-type
                      and b-ord-line.artic      = b-ord-gds-dtl.artic
                      no-lock.
assign
  loc-cli-base-rate = b-ord-line.cli-base-rate.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON LEAVE OF b-ord-gds-dtl.cli-qnty IN FRAME d-out-prt
DO:
define variable varprt-obj_free-qnty like ub.prt-obj.free-qnty no-undo.
IF CAN-FIND(FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-cli
                    and LOOKUP('шту':U, ub.units.type) > 0 )  AND
   TRUNC(input frame d-out-prt b-ord-gds-dtl.cli-qnty, 0)
   <>    input frame d-out-prt b-ord-gds-dtl.cli-qnty
   THEN DO:
      MESSAGE "Единица изм поставщика " ub.goods.unit-cli " - штучная." skip
              "Кол-во должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN NO-APPLY.
  END.
if ub.goods.qnty-cart <> 0 then do:
  if input frame d-out-prt b-ord-gds-dtl.cli-qnty / ub.goods.qnty-cart -
  truncate ( input frame d-out-prt b-ord-gds-dtl.cli-qnty / ub.goods.qnty-cart , 0 ) <> 0 then do:
      g#log = yes.
      message "Товар рекомендуется выписывать упаковками." skip (2)
              "Округлить до целого числа упаковок ?"
               view-as alert-box question buttons yes-no update g#log .
      if g#log then do:
        if round (input frame d-out-prt b-ord-gds-dtl.cli-qnty / ub.goods.qnty-cart, 0) = 0 then do:
          display
              ub.goods.qnty-cart @ b-ord-gds-dtl.cli-qnty
              with frame d-out-prt.
        end.
        else do:
          display
            round ( input frame d-out-prt b-ord-gds-dtl.cli-qnty / ub.goods.qnty-cart, 0) * ub.goods.qnty-cart @ b-ord-gds-dtl.cli-qnty
            with frame d-out-prt.
        end.
      end.
  end.
end.
   KK = b-ord-line.cli-base-rate.
  if lookup('cli-base-rate',parcli-qnty-calc) = 0 then do:
  assign
    tot-cli = input frame d-out-prt b-ord-gds-dtl.price-cli * input frame d-out-prt b-ord-gds-dtl.cli-qnty
    b-ord-gds-dtl.qnty = ( input frame d-out-prt b-ord-gds-dtl.cli-qnty ) * kk .
    DISPLAY  tot-cli b-ord-gds-dtl.qnty   WITH FRAME d-out-prt.
  apply "leave" to b-ord-gds-dtl.qnty .
  DISPLAY  tot-cli b-ord-gds-dtl.qnty WITH FRAME d-out-prt.
  run ass-var in this-procedure .
  end.
END.
ON LEAVE OF b-ord-gds-dtl.qnty IN FRAME d-out-prt
DO:
 IF CAN-FIND(FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-base
                    and LOOKUP('шту':U, ub.units.type) > 0)  AND
   TRUNC(input frame d-out-prt b-ord-gds-dtl.qnty, 0)
   <>    input frame d-out-prt b-ord-gds-dtl.qnty
   THEN DO:
      MESSAGE "Базовая единица товара " ub.goods.unit-base " - штучная." skip
              "Кол-во по факту должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN no-apply.
  END.
 if pardoc-qnty-input = true then do:
    if lookup('cli-base-rate',parcli-qnty-calc) > 0 then do:
     assign
        kk = (input frame d-out-prt b-ord-gds-dtl.qnty) / (input frame d-out-prt b-ord-gds-dtl.cli-qnty )
     .
     if kk  = ? then kk = 1.
     b-ord-line.cli-base-rate = kk  .
    end.
    else do:
        if b-ord-line.cli-base-rate = 0 or b-ord-line.cli-base-rate = ? then
          kk = ub.goods.cli-base-rate .
          else KK = b-ord-line.cli-base-rate .
        assign
            b-ord-gds-dtl.cli-qnty = input frame d-out-prt b-ord-gds-dtl.qnty / kk
            tot-cli = input frame d-out-prt b-ord-gds-dtl.price-cli * input frame d-out-prt b-ord-gds-dtl.cli-qnty
            .
            DISPLAY  tot-cli b-ord-gds-dtl.cli-qnty   WITH FRAME d-out-prt.
       end.
  run ass-var in this-procedure .
  end.
END.
ON LEAVE OF b-ord-gds-dtl.price-base IN FRAME d-out-prt
DO:
if input frame d-out-prt b-ord-gds-dtl.price-base > 5000 and base-code = 1 then
  message "Внимание !!!" skip (2)
                  "ВАЛЮТНАЯ цена превышает 5,000 !" skip (2)
                  "Вы не ошиблись ?".
if b-ord-gds-dtl.price-base <> input frame d-out-prt b-ord-gds-dtl.price-base then
  assign
    b-ord-gds-dtl.price-rubl = input frame d-out-prt b-ord-gds-dtl.price-base * loc-base-rate / loc-base-scale
    b-ord-gds-dtl.price-cli  = b-ord-gds-dtl.price-rubl / loc-exch-rate * loc-exch-scale *
     loc-cli-base-rate
    .
    DISPLAY
    b-ord-gds-dtl.price-RUBL
    b-ord-gds-dtl.price-cli
    WITH FRAME d-out-prt .
 run ass-var in this-procedure  .
END.
ON LEAVE OF b-ord-gds-dtl.price-rubl IN FRAME d-out-prt
DO:
if b-ord-gds-dtl.price-rubl <> input frame d-out-prt b-ord-gds-dtl.price-rubl then
  assign
    b-ord-gds-dtl.price-base = input frame d-out-prt b-ord-gds-dtl.price-rubl / loc-base-rate * loc-base-scale
    b-ord-gds-dtl.price-cli  = input frame d-out-prt b-ord-gds-dtl.price-rubl / loc-exch-rate * loc-exch-scale /
     loc-cli-base-rate
    .
    DISPLAY
    b-ord-gds-dtl.price-base
    b-ord-gds-dtl.price-cli
    WITH FRAME d-out-prt .
    run ass-var in this-procedure .
END.
ON LEAVE OF b-ord-gds-dtl.price-cli IN FRAME d-out-prt
DO:
if b-ord-gds-dtl.price-cli <> input frame d-out-prt b-ord-gds-dtl.price-cli then
  assign
    tot-cli = input frame d-out-prt b-ord-gds-dtl.price-cli *  input frame d-out-prt b-ord-gds-dtl.cli-qnty
    .
 run ass-var in this-procedure .
END.
procedure ass-var :
 do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
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
 assign  frame d-out-prt  b-ord-gds-dtl.price-rubl b-ord-gds-dtl.price-base .
 assign
    b-ord-gds-dtl.sum-rubl = input frame d-out-prt b-ord-gds-dtl.price-rubl  * input frame d-out-prt b-ord-gds-dtl.qnty
    b-ord-gds-dtl.sum-base = b-ord-gds-dtl.price-base  * input frame d-out-prt b-ord-gds-dtl.qnty
    b-ord-gds-dtl.sum-cli  = b-ord-gds-dtl.price-cli   * input frame d-out-prt b-ord-gds-dtl.cli-qnty
    tot-rubl     = input frame d-out-prt b-ord-gds-dtl.price-rubl * input frame d-out-prt b-ord-gds-dtl.qnty
    tot-base     = b-ord-gds-dtl.price-base * input frame d-out-prt b-ord-gds-dtl.qnty
    tot-cli      = b-ord-gds-dtl.price-cli  * input frame d-out-prt b-ord-gds-dtl.cli-qnty
    .
end.
else do:
 assign
    b-ord-gds-dtl.sum-rubl = b-ord-gds-dtl.price-rubl  * input frame d-out-prt b-ord-gds-dtl.qnty
    b-ord-gds-dtl.sum-base = b-ord-gds-dtl.price-base  * input frame d-out-prt b-ord-gds-dtl.qnty
    b-ord-gds-dtl.sum-cli  = input frame d-out-prt b-ord-gds-dtl.price-cli   * input frame d-out-prt b-ord-gds-dtl.cli-qnty
    tot-rubl     = b-ord-gds-dtl.price-rubl * input frame d-out-prt b-ord-gds-dtl.qnty
    tot-base     = b-ord-gds-dtl.price-base * input frame d-out-prt b-ord-gds-dtl.qnty
    tot-cli      = input frame d-out-prt b-ord-gds-dtl.price-cli  * input frame d-out-prt b-ord-gds-dtl.cli-qnty
    .
end.
  DISPLAY
    b-ord-gds-dtl.price-rubl
    b-ord-gds-dtl.price-base
    b-ord-gds-dtl.price-cli
    tot-cli
    tot-rubl
    tot-base WITH FRAME d-out-prt.
 end.
end procedure.
PROCEDURE apply-focus-next-entry :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  define input parameter p-widget-handle as handle no-undo .
  do with frame d-out-prt :
      if b-ord-gds-dtl.cli-qnty :handle = p-widget-handle then apply "entry":u to b-ord-gds-dtl.price-cli .
  end.
end.
END PROCEDURE.
ON CHOOSE OF b-exit IN FRAME d-out-prt
DO:
assign
  prt-rec = recid (b-ord-gds-dtl)
  cur-rec = recid (ub.gds-prt)
  gds-rec = recid (ub.goods).
find b-ord-line where
                          b-ord-line.doc-code   = b-ord-gds-dtl.doc-code
                      and b-ord-line.rcv-code   = b-ord-gds-dtl.rcv-code
                      and b-ord-line.prod-code  = b-ord-gds-dtl.prod-code
                      and b-ord-line.prod-type  = b-ord-gds-dtl.prod-type
                      and b-ord-line.artic      = b-ord-gds-dtl.artic
                      no-lock.
line-rec = recid (b-ord-line).
assign
  b-ord-gds-dtl.sum-cli = b-ord-gds-dtl.cli-qnty * b-ord-gds-dtl.price-cli
  b-ord-gds-dtl.sum-base = b-ord-gds-dtl.qnty * b-ord-gds-dtl.price-base
  b-ord-gds-dtl.sum-rubl = b-ord-gds-dtl.qnty * b-ord-gds-dtl.price-rubl
  .
END.
on end-error, stop of frame d-out-prt do:
  apply "choose" to b-exit in frame d-out-prt.
  return no-apply.
end.
ON RETURN OF b-ord-gds-dtl.cli-qnty IN FRAME d-out-prt
DO:
 run apply-focus-next-entry in this-procedure  (input  b-ord-gds-dtl.cli-qnty:handle ) .
 return no-apply .
END.
ON RETURN OF b-ord-gds-dtl.qnty IN FRAME d-out-prt
DO:
apply "choose" to b-exit in frame d-out-prt.
END.
ON RETURN OF b-ord-gds-dtl.price-rubl IN FRAME d-out-prt
DO:
apply "choose" to b-exit in frame d-out-prt.
END.
ON RETURN OF b-ord-gds-dtl.price-base IN FRAME d-out-prt
DO:
apply "choose" to b-exit in frame d-out-prt.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-out-prt:PARENT eq ?
THEN FRAME d-out-prt:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-out-prt APPLY "END-ERROR":U TO SELF.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-out-prt
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
on choose of b-help in frame d-out-prt
do:
  apply "help":u to frame d-out-prt .
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-out-prt:width - 0.3
                fh            = frame d-out-prt:first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
g#type = loc-doc-type.
find ub.gds-prt where recid (ub.gds-prt) = cur-rec no-lock.
if prt-mode = 'ШКАЛА':U and node-type <> 'терм':U then do:
  message "В режиме ШКАЛА можно указывать количества только по самым подробным признакам.".
  undo, return error.
end.
find ub.goods where recid (ub.goods) = gds-rec no-lock.
find ub.clients where ub.clients.obj-code = ub.goods.prod-code
               and ub.clients.obj-type = ub.goods.prod-type no-lock.
find ub.prt-obj where ub.prt-obj.prt-code = ub.gds-prt.node-code
                    and ub.prt-obj.prod-code = ub.goods.prod-code
                    and ub.prt-obj.prod-type = ub.goods.prod-type
                    and ub.prt-obj.artic     = ub.goods.artic
                    and ub.prt-obj.obj-code  = store-code
                    and ub.prt-obj.obj-type  = store-type
                    no-lock no-error.
  find b-ord-line where recid (b-ord-line) = line-rec.
  find b-ord-gds-dtl where b-ord-gds-dtl.node-code = ub.gds-prt.node-code
                      and b-ord-gds-dtl.prod-code = b-ord-line.prod-code
                      and b-ord-gds-dtl.prod-type = b-ord-line.prod-type
                      and b-ord-gds-dtl.artic     = b-ord-line.artic
                      and b-ord-gds-dtl.doc-code  = b-ord-line.doc-code
                      and b-ord-gds-dtl.rcv-code  = b-ord-line.rcv-code
                       exclusive-lock   no-error.
if not available b-ord-gds-dtl then do:
  if ub.gds-prt.upper-code = ub.goods.prt-root
     or prt-mode = 'ПРОСМОТР':U then do:
    message "Товара с таким признаком нет в данном заказе.".
    undo, return error.
  end.
  run create_gds-dtl in this-procedure (b-ord-line.rcv-code,
                      b-ord-line.doc-code,
                      ub.gds-prt.f-name,
                      b-ord-line.artic,
                      b-ord-line.prod-code,
                      b-ord-line.prod-type,
                      ub.gds-prt.node-code
                     ) no-error.
  if error-status:error then do:
     message "Ошибка при создании признака." skip
             return-value error-status:error
     view-as alert-box error.
      undo , return error.
  end.
 find first b-ord-gds-dtl where
                          b-ord-gds-dtl.doc-code  = b-ord-line.doc-code     and
                          b-ord-gds-dtl.rcv-code  = b-ord-line.rcv-code     and
                          b-ord-gds-dtl.artic     = b-ord-line.artic     and
                          b-ord-gds-dtl.prod-code = b-ord-line.prod-code and
                          b-ord-gds-dtl.prod-type = b-ord-line.prod-type and
                          b-ord-gds-dtl.node-code = ub.gds-prt.node-code  exclusive-lock  .
 run last-price in this-procedure  (
      input  g#host-code ,
      input  b-ord-gds-dtl.artic ,
      input  b-ord-gds-dtl.prod-type ,
      input  b-ord-gds-dtl.prod-code ,
      input  loc-cli-code  ,
      input  loc-cli-type  ,
      input  b-ord-line.cli-base-rate ,
      input  LOC-EXCH-CODE ,
      output b-ord-gds-dtl.price-base ,
      output b-ord-gds-dtl.price-rubl ,
      output b-ord-gds-dtl.price-cli )
      no-error  .
      if error-status :error then message  error-status :get-message(1) .
  if prt-mode = 'ШКАЛА':U then do:
    find first g-d-b-ord-dtl where g-d-b-ord-dtl.prod-type = b-ord-line.prod-type
                       and g-d-b-ord-dtl.prod-code = b-ord-line.prod-code
                       and g-d-b-ord-dtl.artic     = b-ord-line.artic
                       and g-d-b-ord-dtl.doc-code  = b-ord-line.doc-code
                       and g-d-b-ord-dtl.rcv-code  = b-ord-line.rcv-code
                       and g-d-b-ord-dtl.node-code  <> ub.gds-prt.node-code no-lock no-error.
    if AVAILABLE g-d-b-ord-dtl then
    assign
      b-ord-gds-dtl.cli-qnty   = g-d-b-ord-dtl.cli-qnty
      b-ord-gds-dtl.qnty       = g-d-b-ord-dtl.qnty
      .
  end.
end.
frame d-out-prt:title = "Заказ №  " + loc-ord-num + "    " +  'строка':U + "     " + prt-mode.
cli-curr  = "" .
base-curr = "".
find first ub.currency where ub.currency.curr-code = base-code no-lock no-error.
  if available ub.currency then base-curr = ub.currency.curr-abbr .
find first ub.currency where ub.currency.curr-code = LOC-EXCH-CODE no-lock no-error.
  if available ub.currency then cli-curr = ub.currency.curr-abbr .
  disp cli-curr base-curr with frame d-out-prt .
run UI-on in this-procedure .
if prt-mode = 'ПРОСМОТР':U then WAIT-FOR GO OF FRAME d-out-prt focus b-exit.
else  DO:
    WAIT-FOR GO OF FRAME d-out-prt focus b-ord-gds-dtl.cli-qnty.
      chg-qnty = input frame d-out-prt b-ord-gds-dtl.qnty - b-ord-gds-dtl.qnty.
      b-ord-line.qnty   = b-ord-line.qnty + chg-qnty  .
      b-ord-gds-dtl.qnty  = b-ord-gds-dtl.qnty + chg-qnty .
      chg-qnty = input frame d-out-prt b-ord-gds-dtl.cli-qnty - b-ord-gds-dtl.cli-qnty.
      b-ord-line.cli-qnty   = b-ord-line.cli-qnty + chg-qnty  .
      b-ord-gds-dtl.cli-qnty  = b-ord-gds-dtl.cli-qnty + chg-qnty .
      b-ord-gds-dtl.price-rubl  = input frame d-out-prt b-ord-gds-dtl.price-rubl .
      b-ord-gds-dtl.price-base  = input frame d-out-prt b-ord-gds-dtl.price-base .
End.
prt-rec = recid (b-ord-gds-dtl).
if prt-mode <> 'ПРОСМОТР':U then do:
  if b-ord-gds-dtl.cli-qnty = 0 and b-ord-gds-dtl.qnty = 0 then do:
    message "Удаляем строку, т.к. количество = 0.".
    delete b-ord-gds-dtl.
    prt-rec = ?.
  end.
end.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME d-out-prt.
END PROCEDURE.
PROCEDURE UI-on :
disable all with frame d-out-prt.
enable
      b-exit
      b-help
      b-ord-gds-dtl.price-cli
      b-ord-gds-dtl.cli-qnty
      with frame d-out-prt.
 run tax-name in this-procedure ( input 'rdt':U, output varroad-tax-label) no-error.
IF AVAILABLE ub.prt-obj    THEN DISPLAY ub.prt-obj.free-qnty   WITH FRAME d-out-prt.
IF AVAILABLE ub.price-list THEN DISPLAY ub.price-list.doc-num  WITH FRAME d-out-prt.
g#log = true .
if g#log and paytype <> g#ret-sup-pay or
    (paytype = g#ret-sup-pay) then
    if prt-mode = 'ПРОСМОТР':U then hide ub.prt-obj.free-qnty ub.price-list.doc-num in frame d-out-prt.
assign
  tot-rubl = b-ord-gds-dtl.qnty     * b-ord-gds-dtl.price-rubl
  tot-base = b-ord-gds-dtl.qnty     * b-ord-gds-dtl.price-base
  tot-cli  = b-ord-gds-dtl.cli-qnty * b-ord-gds-dtl.price-cli
  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  ub.goods.gds-code
  ,input  b-ord-gds-dtl.node-code
  ,input  ''
  ,input  ''
  ,input  ub.goods.unit-base
  ,input  1
  ,output varis-new
  ,buffer b-c-b
  )  .
display b-c-b.b-code @ ub.bar-code.b-code with frame d-out-prt.
disp tot-rubl
     tot-base
     tot-cli
     base-curr
     cli-curr
     ub.clients.obj-name
     ub.gds-prt.f-name
     b-ord-gds-dtl.artic
     b-ord-gds-dtl.prod-code
     b-ord-gds-dtl.prod-type
     b-ord-gds-dtl.price-rubl
     b-ord-gds-dtl.price-base
     b-ord-gds-dtl.price-cli
     b-ord-gds-dtl.cli-qnty
     b-ord-gds-dtl.qnty
     ub.goods.gds-name
     ub.goods.unit-base
     ub.goods.qnty-cart
     ub.goods.unit-cli
     with frame d-out-prt.
if ub.gds-prt.upper-code = ub.goods.prt-root then hide ub.gds-prt.f-name in frame d-out-prt.
END PROCEDURE.
procedure create_gds-dtl :
define input parameter p-rcv-code  like ub.ord-doc-rcv.rcv-code  no-undo.
define input parameter p-doc-code  like ub.ord-doc-rcv.doc-code  no-undo.
define input parameter parname    as character no-undo .
define input parameter parartic     like ub.goods.artic       no-undo.
define input parameter parprod-code like ub.goods.prod-code   no-undo.
define input parameter parprod-type like ub.goods.prod-type   no-undo.
define input parameter parprt-code  like ub.gds-dtl.prt-code  no-undo.
define buffer bf_gds-dtl for ub.ord-dtl-rcv.
define buffer bf_clients for ub.clients.
define buffer bf_goods   for ub.goods.
error-status:error = false .
find first bf_gds-dtl where bf_gds-dtl.artic      = parartic
                        and bf_gds-dtl.prod-code  = parprod-code
                        and bf_gds-dtl.prod-type  = parprod-type
                        and bf_gds-dtl.rcv-code   = p-rcv-code
                        and bf_gds-dtl.doc-code   = p-doc-code
                        and bf_gds-dtl.node-code  = parprt-code   no-error.
if not available bf_gds-dtl then do:
   find first bf_goods where bf_goods.artic     = parartic     and
                             bf_goods.prod-type = parprod-type and
                             bf_goods.prod-code = parprod-code no-lock no-error.
   if not available bf_goods then do:
      return error subst("Создание признака невозможно. Не найден товар &1 &2 &3.", parartic, parprod-code, parprod-code).
   end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  bf_goods.gds-code
  ,input  parprt-code
  ,input  ''
  ,input  ''
  ,input  bf_goods.unit-base
  ,input  ?
  ,output varis-new
  ,buffer ub.bar-code
  ) no-error .
  create bf_gds-dtl.
    assign
      bf_gds-dtl.rcv-code       = p-rcv-code
      bf_gds-dtl.doc-code       = p-doc-code
      bf_gds-dtl.artic          = parartic
      bf_gds-dtl.prod-code      = parprod-code
      bf_gds-dtl.prod-type      = parprod-type
      bf_gds-dtl.node-code      = parprt-code
    .
end.
else do:
    assign
      bf_gds-dtl.rcv-code      = p-rcv-code
      bf_gds-dtl.doc-code      = p-doc-code
      bf_gds-dtl.artic         = parartic
      bf_gds-dtl.prod-code     = parprod-code
      bf_gds-dtl.prod-type     = parprod-type
      bf_gds-dtl.node-code     = parprt-code
   .
end.
end procedure.
