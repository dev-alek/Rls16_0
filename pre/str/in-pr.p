block-level on error undo, throw.
define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-doc-rec      as recid no-undo .
define input parameter gen-mode       as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aa9f57929aa3, 2828, rls $":U .
define variable vss-author      as character no-undo init "$Author: VRukavishnikov $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 15 13:32:14 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: in-pr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/in-pr.p $":U .
define variable vss-description as character no-undo init "Генерация переоценки при фактическом закрытии приходной накладной".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,p-doc-rec,gen-mode)
    .
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
define new global shared variable g#lib-log as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-level-dis-attr no-undo
      field attr-code   like global-state-attr.attr-code
      field attr-value  like global-state-attr.attr-value
      index pi   attr-value descending
      index pi1 is unique attr-value
            attr-code .
procedure lvldsc-byattr :
define input  parameter p-attr-code  as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1       as decimal   no-undo .
define output parameter p-val2       as decimal   no-undo .
define output parameter p-prc        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
  define variable v-str1 as character no-undo .
  v-str1 = trim ( p-attr-code , 'level-discnt':U ) .
  v-str1 = trim ( v-str1 , chr(4) ) .
 run lvldsc-bytt (
      input   v-str1
    , input   p-attr-value
    , output  p-val1
    , output  p-val2
    , output  p-prc )
      no-error .
  end.
end procedure.
procedure lvldsc-bytt :
define input  parameter p-attr-code as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1 as decimal   no-undo .
define output parameter p-val2 as decimal   no-undo .
define output parameter p-prc  as decimal   no-undo .
define variable v-str1 as character no-undo .
  do
  on error undo, return error return-value
  :
  assign
     v-str1 = trim ( p-attr-code , "[]()" )
     p-val1 = decimal(entry(1,v-str1, ";"))
     p-val2 = decimal(entry(2,v-str1, ";"))
     p-prc  = decimal(p-attr-value)
     no-error
  .
  end.
end procedure.
procedure level-dis-value :
define input  parameter p-price-prod as decimal   no-undo .
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-prc as decimal   no-undo .
define variable v-level-dis-attr as character no-undo .
define variable v-type as character no-undo .
define variable v-val1 as decimal   no-undo .
define variable v-val2 as decimal   no-undo .
define variable v-prc  as decimal   no-undo .
define variable ix     as integer   no-undo .
do
 on error undo, return error return-value
 :
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
run ggoattr-value (
   input   buf_goods.grp-code
  ,input   v-cntxt-host-code-obj
  ,input   p-obj-type
  ,input   p-obj-code
  ,input   'level-dis':U
  ,output  v-level-dis-attr
  ,output  v-type ) no-error .
repeat ix = 1 to num-entries (v-level-dis-attr, chr(4)) - 1 :
  create
    tt-level-dis-attr
  .
  tt-level-dis-attr.attr-code = entry (1, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
  tt-level-dis-attr.attr-value = entry (2, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
end.
p-prc = 0 .
  if p-price-prod = 0 then do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if v-val1  = 0  then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
  else do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if p-price-prod   > v-val1 and
               p-price-prod  <= v-val2 then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
for each tt-level-dis-attr no-lock. delete tt-level-dis-attr. end.
 end.
end procedure.
procedure calc-price-levelprod :
define input  parameter p-mode     as integer   no-undo .
define input  parameter p-rb       as character no-undo .
define input  parameter p-b-code   as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-price-sale as decimal   no-undo .
define output parameter p-descript-calc as character no-undo .
define variable  v-PriceWithoutVat as decimal   no-undo init 0.
define variable  v-PriceWithVat    as decimal   no-undo init 0.
define variable  v-prod-vat        as decimal   no-undo init 0.
define variable  v-discnt          as decimal   no-undo init 0.
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_parts for ub.parts  .
define variable v-part-code as character no-undo .
define variable v-in-code   as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  p-obj-type
 , input  p-obj-code
 , output v-PriceWithoutVat
 , output v-PriceWithVat
 , output v-prod-vat
 , output v-part-code
 , output v-in-code
        ) no-error .
      if error-status :error then do:
        return error "Нет цены производителя!".
      end.
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
find first buf_parts no-lock where
           buf_parts.artic      = buf_goods.artic        and
           buf_parts.prod-type  = buf_goods.prod-type    and
           buf_parts.prod-code  = buf_goods.prod-code    and
           buf_parts.in-code    = buf_bar-code.in-code   and
           buf_parts.out-code   = buf_bar-code.in-code   and
           buf_parts.part-code  = buf_bar-code.part-code
           no-error .
            if error-status :error then do:
                find first buf_parts no-lock where
                          buf_parts.artic      = buf_goods.artic        and
                          buf_parts.prod-type  = buf_goods.prod-type    and
                          buf_parts.prod-code  = buf_goods.prod-code    and
                          buf_parts.in-code    = v-in-code              and
                          buf_parts.out-code   = v-in-code              and
                          buf_parts.part-code  = v-part-code
                          no-error .
                if error-status :error then do:
                   message
                    substitute("Нет цены производителя !  &1 &2&3&4&5"  ,
                                v-in-code,
                                v-part-code ,
                                buf_goods.artic   ,
                                buf_goods.prod-type,
                                buf_goods.prod-code ) .
                   return error "Нет цены производителя !!!".
                end.
            end.
run level-dis-value ( input (if p-mode = 2 then v-PriceWithoutVat else v-PriceWithVat) , input p-b-code, input p-obj-type, input p-obj-code, output v-discnt ) no-error .
define variable v-postWithoutVat-rubl as decimal   no-undo .
define variable v-postWithoutVat-base as decimal   no-undo .
   case p-mode :
    when 1 then do:
       if p-rb = "rubl" then do:
          p-price-sale = buf_parts.price-rubl + ( MINIMUM ( buf_parts.price-rubl , v-PriceWithVat ) * v-discnt / 100 ).
       end.
       else do:
          p-price-sale = buf_parts.price-base + ( MINIMUM ( v-PriceWithVat , buf_parts.price-base ) * v-discnt / 100 ).
       end.
    end.
    when 2 then do:
      if p-rb = "rubl" then do:
        v-postWithoutVat-rubl =  buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ).
        p-price-sale = v-postWithoutVat-rubl + ( MINIMUM ( v-PriceWithoutVat , v-postWithoutVat-rubl ) * v-discnt / 100 ) .
      end.
      else do:
        v-postWithoutVat-base = buf_parts.price-base - (buf_parts.price-base * buf_parts.vat-pc / ( 100 + buf_parts.vat-pc) ) .
        p-price-sale = v-postWithoutVat-base + ( MINIMUM ( v-PriceWithoutVat, v-postWithoutVat-base) * v-discnt / 100 ) .
      end.
    end.
   end case.
p-descript-calc =
  string(p-mode) + '_Элементы расчета: ' +  chr(10)  +
  buf_goods.gds-name                  +  chr(10) +
  buf_goods.artic +
  buf_goods.prod-type +
  string(buf_goods.prod-code)         + chr(10) +
  "бар-код " +  string(p-b-code)      + chr(10)  +
  'ПН    ' + v-in-code  +
  ' серия ' + v-part-code             +  chr(10)  + chr(10) +
  'Цена поставщика без ндс    '  + string((buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ) ))  + chr(10) +
  'Цена поставщика   c ндс    '  + string ( buf_parts.price-rubl )  + chr(10) +
  'Цена производителя без ндс ' +  string( v-PriceWithoutVat)       + chr(10) +
  'Цена производителя   c ндс ' +  string( v-PriceWithVat  )        + chr(10) +
  chr(10) +
  "% пороговой наценки        "  + string(v-discnt)                 + chr(10) +
  chr(10) +
  "сумма наценки от произв без ндс "  + string( v-PriceWithoutVat * v-discnt / 100 ) +  chr(10) +
  "сумма наценки от произв   с ндс "  + string( v-PriceWithVat * v-discnt / 100 )    +  chr(10)  +
  chr(10) +
  string(p-price-sale)                                                               +  chr(10) +
  (if p-mode = 1 then substitute("ПорогПр+НДС  &1 + ( min(&2или &1) * &3 / 100 )  = &4 " , buf_parts.price-rubl , v-PriceWithVat , v-discnt , p-price-sale)
  else                substitute("ПорогПр-НДС  &1 - ( &1 * &2 / 100 ) + ( min(&3 или &6 ) * &4 / 100 ) = &5 и еще накручивается НДС " , buf_parts.price-rubl , buf_parts.vat-pc , v-PriceWithoutVat , v-discnt , p-price-sale , v-postWithoutVat-rubl))
.
  end.
end procedure.
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable line-mode    as character no-undo .
define variable line-rec     as recid     no-undo .
define variable var-pr-r-b   as character no-undo .
define variable v-log-handle as handle    no-undo .
define variable v-str        as character no-undo .
if (valid-handle(g#lib-log) <> true) then do:   run gbl/lib-log.p persistent no-error .   if error-status :error or (valid-handle(g#lib-log) <> true) then do:     message       "Error starting gbl/lib-log.p" skip       g#lib-log skip       g#lib-log :type skip       g#lib-log :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-log_get-log-handle in g#lib-log
  (output  v-log-handle
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-obj-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-obj.node-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-min-increase like ub.gds-grp-obj.min-increase  no-undo.
define input parameter p-max-increase like ub.gds-grp-obj.max-increase  no-undo.
define input parameter p-increase-pc like ub.gds-grp-obj.increase-pc  no-undo.
define input parameter p-calc-method like ub.gds-grp-obj.calc-method no-undo .
define input parameter p-round-method like ub.gds-grp-obj.round-method no-undo .
define input parameter p-round-coef like ub.gds-grp-obj.round-coef no-undo .
define input parameter p-cli-type   like ub.clients.obj-type            no-undo.
define input parameter p-cli-code   like ub.clients.obj-code            no-undo.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
    find first buf_gds-grp-obj exclusive-lock
         where buf_gds-grp-obj.node-code  = p-node-code
           and buf_gds-grp-obj.host-code  = p-host-code
           and buf_gds-grp-obj.obj-type   = p-obj-type
           and buf_gds-grp-obj.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-obj
    then do:
        create buf_gds-grp-obj.
        assign
                buf_gds-grp-obj.node-code  = p-node-code
                buf_gds-grp-obj.host-code  = p-host-code
                buf_gds-grp-obj.obj-type   = p-obj-type
                buf_gds-grp-obj.obj-code   = p-obj-code
        .
    end.
    assign
    buf_gds-grp-obj.min-increase = p-min-increase
    buf_gds-grp-obj.max-increase = p-max-increase
    buf_gds-grp-obj.increase-pc = p-increase-pc
    buf_gds-grp-obj.calc-method = p-calc-method
    buf_gds-grp-obj.round-method = p-round-method
    buf_gds-grp-obj.round-coef = p-round-coef
    buf_gds-grp-obj.cli-type   = p-cli-type
    buf_gds-grp-obj.cli-code   = p-cli-code
    .
end.
end procedure.
procedure grp-obj-margin-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-min-value as decimal      no-undo init ?.
define output parameter p-max-value as decimal      no-undo init ?.
define output parameter p-increase-pc as decimal      no-undo init ?.
define output parameter p-round-method as character no-undo init "":U.
define output parameter p-base as decimal no-undo init ?.
define output parameter p-range-margin     as integer      no-undo.
define output parameter p-exists-margin    as logical      no-undo.
define output parameter p-range-increase     as integer      no-undo.
define output parameter p-exists-increase    as logical      no-undo.
define output parameter p-range-rmethod     as integer no-undo .
define output parameter p-exists-rmethod    as logical no-undo .
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-margin-found as logical no-undo .
DEFINE VARIABLE v-increase-found as logical no-undo .
DEFINE VARIABLE v-min-value as decimal      no-undo.
DEFINE VARIABLE v-max-value as decimal      no-undo.
DEFINE VARIABLE v-increase-pc as decimal      no-undo.
define variable v-round-method as character no-undo .
define variable v-base as decimal no-undo .
define variable v-print-code as character no-undo .
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
if p-obj-type <> '' then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description
        skip "Не удалось найти фирму объекта"
        skip p-obj-type p-obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
      view-as alert-box error.
      undo, return error .
  end.
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-min-value    = buf_gds-grp-obj.min-increase
    v-max-value    = buf_gds-grp-obj.max-increase
    v-increase-pc  = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    .
    assign
    p-exists-margin = (if v-min-value <> ? and v-max-value <> ? and p-min-value = ?
                        then yes
                        else p-exists-margin)
    p-range-margin = if p-exists-margin and p-min-value = ?
                      then v-range
                      else p-range-margin
    p-min-value   =  if p-exists-margin and  p-min-value = ?
                      then v-min-value
                      else p-min-value
    p-max-value   =  if p-exists-margin and  p-max-value = ?
                      then v-max-value
                      else p-max-value
    p-exists-increase = (if v-increase-pc <> ? and p-increase-pc = ?
                        then yes
                        else p-exists-increase)
    p-range-increase = if p-exists-increase and p-increase-pc = ?
                      then v-range
                      else p-range-increase
    p-increase-pc = (if p-exists-increase and p-increase-pc = ?
                      then v-increase-pc
                      else p-increase-pc)
    p-exists-rmethod = if v-round-method <> "":U and p-round-method = "":U
                        then yes
                        else p-exists-rmethod
    p-range-rmethod = (if p-exists-rmethod and p-round-method = "":U
                        then v-range
                        else p-range-rmethod)
    p-round-method  = (if p-exists-rmethod and p-round-method = "":U
                        then v-round-method
                        else p-round-method)
    p-base          = (if p-exists-rmethod and p-base = ?
                        then v-base
                        else p-base)
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
procedure grp-obj-income-cli-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-cli-type as character    no-undo init ?.
define output parameter p-cli-code as integer      no-undo init ?.
define output parameter p-range-income-cli     as integer      no-undo.
define output parameter p-exists-income-cli    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-income-cli-found as logical no-undo .
DEFINE VARIABLE v-cli-type-value as char      no-undo.
DEFINE VARIABLE v-cli-code-value as int      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-cli-type-value    = buf_gds-grp-obj.cli-type
    v-cli-code-value    = buf_gds-grp-obj.cli-code
    .
    assign
    p-exists-income-cli = (if v-cli-type-value <> ? and v-cli-code-value <> ? and p-cli-type = ?
                        then yes
                        else p-exists-income-cli)
    p-range-income-cli = if p-exists-income-cli and p-cli-type = ?
                      then v-range
                      else p-range-income-cli
    p-cli-type   =  if p-exists-income-cli and  p-cli-type = ?
                      then v-cli-type-value
                      else p-cli-type
    p-cli-code   =  if p-exists-income-cli and  p-cli-code = ?
                      then v-cli-code-value
                      else p-cli-code
    v-found =  (p-exists-income-cli ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-income-cli  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info10, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info10 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info10 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info10, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info10
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info10
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
procedure main-road-tax :
define input parameter p-obj-type  like ub.gds-obj.obj-type  no-undo .
define input parameter p-obj-code  like ub.gds-obj.obj-code  no-undo .
define input parameter p-artic     like ub.gds-obj.artic     no-undo .
define input parameter p-prod-type like ub.gds-obj.prod-type no-undo .
define input parameter p-prod-code like ub.gds-obj.prod-code no-undo .
define input-output parameter p-road-tax-base as decimal no-undo .
define input-output parameter p-road-tax-rubl as decimal no-undo .
define variable v-doc-code as character no-undo .
define buffer     buff-goods    for ub.goods      .
define buffer     buf_gds-obj   for ub.gds-obj .
define buffer     buf_parts     for ub.parts   .
define buffer b-td_trn-doc for ub.trn-doc  .
define buffer b-dl_doc-line for ub.doc-line .
define variable is-petrolium              as logical no-undo .
define variable is-pieces                 as logical no-undo .
define variable is-hold-td                as logical no-undo .
define variable v-rec                     as recid   no-undo .
define variable t-ret                     as logical no-undo .
define variable v-total-avrg-base         as decimal no-undo .
define variable v-total-avrg-rubl         as decimal no-undo .
define variable v-total-avrg-qnty         as decimal no-undo .
define variable v-total-road-tax-base     as decimal no-undo .
define variable v-total-road-tax-rubl     as decimal no-undo .
define variable v-all-total-road-tax-base as decimal no-undo .
define variable v-all-total-road-tax-rubl as decimal no-undo .
assign
  p-road-tax-base = ?
  p-road-tax-rubl = ?
  .
  Find first buff-goods no-lock where
        buff-goods.artic     = p-artic and
        buff-goods.prod-type = p-prod-type and
        buff-goods.prod-code = p-prod-code
        no-error .
      If avail buff-goods Then DO:
           v-rec = recid (buff-goods).
           t-ret =  session:SET-WAIT-STATE("GENERAL") .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrolium
  , output is-pieces
  ) .
           t-ret =  session:set-wait-state("") .
           if not ( hvrdtax( v-rec ) = true and  is-petrolium = false  )   then  do:
                assign
                  p-road-tax-base = ?
                  p-road-tax-rubl = ?
                  .
                return.
           end.
      end.
      assign
          v-total-avrg-qnty = 0
          v-total-road-tax-base =  0
          v-total-road-tax-rubl =  0
          v-all-total-road-tax-base =  0
          v-all-total-road-tax-rubl =  0
          .
      for each buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.qnty      > 0
      on error undo, return error
      :
         v-total-avrg-qnty = v-total-avrg-qnty + buf_parts.fact-qnty.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
          v-all-total-road-tax-base =  v-all-total-road-tax-base + (road-tax-base-loc * buf_parts.fact-qnty)
          v-all-total-road-tax-rubl =  v-all-total-road-tax-rubl + (road-tax-rubl-loc * buf_parts.fact-qnty)
         .
      end.
          if v-total-avrg-qnty > 0 then  do :
              assign
                  p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
                  p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
                  .
           end.
            if v-total-avrg-qnty <= 0 then do :
              find first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = p-obj-type
                  and buf_gds-obj.obj-code  = p-obj-code
                  and buf_gds-obj.artic     = p-artic
                  and buf_gds-obj.prod-type = p-prod-type
                  and buf_gds-obj.prod-code = p-prod-code
                no-error .
                    if available buf_gds-obj then do :
                      if buf_gds-obj.in-code <> "" then
                           v-doc-code = buf_gds-obj.in-code.
                      else do:
                        if available ub.price-doc then  v-doc-code = ub.price-doc.out-code.
                      end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  v-doc-code
  ,output is-hold-td
  )  .
                      if is-hold-td = true then do:
                        assign
                            p-road-tax-rubl = 0
                            p-road-tax-base = 0
                            .
                      end.
                      else do:
                          find b-td_trn-doc  where b-td_trn-doc.doc-code   = v-doc-code no-lock no-error .
                          find b-dl_doc-line where b-dl_doc-line.doc-code  = b-td_trn-doc.doc-code
                                          and b-dl_doc-line.artic     = p-artic
                                          and b-dl_doc-line.prod-type = p-prod-type
                                          and b-dl_doc-line.prod-code = p-prod-code no-lock no-error.
                                if available b-dl_doc-line then do :
assign
  price-rubl-with-tax-loc = b-dl_doc-line.price-rubl
  price-base-with-tax-loc = b-dl_doc-line.price-base
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b-td_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = b-dl_doc-line.artic     and
                                     in-vatp-goods.prod-type = b-dl_doc-line.prod-type and
                                     in-vatp-goods.prod-code = b-dl_doc-line.prod-code no-lock.
   if (not b-td_trn-doc.internal and
           b-td_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b-dl_doc-line.road-tax
          road-tax-rubl-loc = b-dl_doc-line.road-tax * b-td_trn-doc.base-rate / b-td_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b-dl_doc-line.road-tax
          road-tax-base-loc = b-dl_doc-line.road-tax / b-td_trn-doc.base-rate * b-td_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b-dl_doc-line.transport-base = ? then 0 else b-dl_doc-line.transport-base)
        transport-rubl-loc = (if b-dl_doc-line.transport-rubl = ? then 0 else b-dl_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b-dl_doc-line.other-base     = ? then 0 else b-dl_doc-line.other-base)
        other-rubl-loc     = (if b-dl_doc-line.other-rubl     = ? then 0 else b-dl_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b-dl_doc-line.vat-pc         = ? then 0 else b-dl_doc-line.vat-pc)
        slt-pc-loc         = (if b-dl_doc-line.slt-pc         = ? then 0 else b-dl_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b-dl_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b-dl_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b-dl_doc-line.obj-code  and
                                      in-vatp-parts.artic     = b-dl_doc-line.artic     and
                                      in-vatp-parts.prod-type = b-dl_doc-line.prod-type and
                                      in-vatp-parts.prod-code = b-dl_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        transport-base-loc  = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        other-base-loc      = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        other-rubl-loc      = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b-dl_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-dl_doc-line.fact-qnty   else 0
        slt-base-loc        = if b-dl_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-dl_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b-dl_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-dl_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b-dl_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-dl_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
                                    assign
                                        p-road-tax-rubl =  road-tax-rubl-loc
                                        p-road-tax-base =  road-tax-base-loc
                                        .
                                end.
                      end.
                     end.
            end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-modificator-price-is-null :
 do
 on error undo, return error return-value
 :
define input parameter p-artic     like ub.goods.artic no-undo.
define input parameter p-prod-type like ub.goods.prod-type no-undo.
define input parameter p-prod-code like ub.goods.prod-code no-undo.
define input parameter p-obj-type  like ub.clients.obj-type no-undo.
define input parameter p-obj-code  like ub.clients.obj-code no-undo.
define output parameter p-ret as logical no-undo .
define variable v-gds-code  like ub.goods.gds-code no-undo .
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
p-ret = true .
find first buf_fbr-gds-obj no-lock where
            buf_fbr-gds-obj.gds-code = v-gds-code and
            buf_fbr-gds-obj.obj-code = p-obj-code and
            buf_fbr-gds-obj.obj-type = p-obj-type use-index pi no-error .
 if available buf_fbr-gds-obj then
              if buf_fbr-gds-obj.is-modificator = true and
                 buf_fbr-gds-obj.is-null-price = true
                 then  p-ret = false .
 end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
procedure create-price-list-attr :
 do
 on error undo, return error return-value
 :
define input parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .
define input parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define buffer buf_price-list-attr for ub.price-list-attr.
find first buf_price-list-attr  exclusive-lock  where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if not available  buf_price-list-attr then do:
      create buf_price-list-attr.
      assign
        buf_price-list-attr.attr-code    = p-attr-code
        buf_price-list-attr.attr-value   = p-attr-value
        buf_price-list-attr.b-code       = p-b-code
        buf_price-list-attr.doc-num      = p-doc-num
        buf_price-list-attr.price-type   = p-price-type
      .
  end.
  else do:
        buf_price-list-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure view-price-list-attr :
 do
 on error undo, return error return-value
 :
define input  parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input  parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input  parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input  parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define output parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .
define buffer buf_price-list-attr for ub.price-list-attr.
find first buf_price-list-attr no-lock where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if available  buf_price-list-attr then do:
      assign
        p-attr-value = buf_price-list-attr.attr-value
      .
  end.
  else do:
        p-attr-value = ? .
  end.
 end.
end procedure.
procedure pdoc-forming-attr :
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db       as integer   no-undo .
define input  parameter p-attr-code    as character no-undo .
define input  parameter p-val          as character no-undo .
  do
  on error undo, return error return-value
  :
  find first  ub.price-doc-forming-attr exclusive-lock where
              ub.price-doc-forming-attr.plt-id       = p-plt-id       and
              ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num   and
              ub.price-doc-forming-attr.pdf-id       = p-pdf-id       and
              ub.price-doc-forming-attr.pdf-db       = p-pdf-db       and
              ub.price-doc-forming-attr.attr-code    = p-attr-code
              no-error .
    if not available  ub.price-doc-forming-attr then create ub.price-doc-forming-attr.
    assign
      ub.price-doc-forming-attr.plt-id       = p-plt-id
      ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num
      ub.price-doc-forming-attr.pdf-id       = p-pdf-id
      ub.price-doc-forming-attr.pdf-db       = p-pdf-db
      ub.price-doc-forming-attr.attr-code    = p-attr-code
      ub.price-doc-forming-attr.attr-value   = p-val
    .
  end.
end procedure.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE write-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
               ub.contract-specif-attr.contract-num = p-contract-num  and
               ub.contract-specif-attr.host-code    = p-host-code     and
               ub.contract-specif-attr.gds-code     = p-gds-code      and
               ub.contract-specif-attr.attr-code    = 'bonus':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'bonus':U
         .
      end.
      ub.contract-specif-attr.attr-value  = string (v-bonus) .
end.
END PROCEDURE.
PROCEDURE read-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'bonus':U
           no-error .
   if available ub.contract-specif-attr then  v-bonus = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-bonus = 0 .
end.
END PROCEDURE.
PROCEDURE write-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-prc-min        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              ub.contract-specif-attr.attr-value  = string (v-prc-min)
         .
      end.
      else do:
         ub.contract-specif-attr.attr-value  = string (v-prc-min) .
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-prc-min as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'prc-min':U
           no-error .
   if available ub.contract-specif-attr then  v-prc-min = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-prc-min = 0 .
end.
END PROCEDURE.
PROCEDURE write-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = "retro-bonus"
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = "retro-bonus"
         .
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
      else do:
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = "retro-bonus"
           no-error .
   if available ub.contract-specif-attr then  v-retro-bonus = ub.contract-specif-attr.attr-value  .
                                        else  v-retro-bonus = "" .
end.
END PROCEDURE.
define buffer buf1_parts for ub.parts  .
FUNCTION fnc-base-code RETURN integer (local-bc as integer).
define variable local-base-code like ub.bar-code.b-code no-undo.
run prc-base-code (input local-bc, output local-base-code).
return (local-base-code).
END FUNCTION.
define variable g#log as logical   no-undo .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION fnc-base-price RETURN decimal (local-bc      as integer,
                                        local-doc-num as char).
define buffer base-price        for ub.price-list.
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
  run prc-base-code (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.doc-num = local-doc-num and
       base-price.b-code  = local-base-code and
       base-price.price-type = "" no-error.
  if not available base-price then do:
    run prc-main-code (input local-bc, output local-main-code).
    find  base-price no-lock where
          base-price.doc-num = local-doc-num and
          base-price.b-code  = local-main-code and
          base-price.price-type = "" no-error.
  end.
  if available base-price then
    return (base-price.price-sale).
  else
    return (?).
END FUNCTION.
procedure prc-main-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-main-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code        for ub.bar-code.
define buffer local-goods           for ub.goods.
define buffer main-code             for ub.bar-code.
define buffer main-prt              for ub.gds-prt.
  local-main-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find first  main-prt no-lock where
              main-prt.upper-code = local-goods.prt-root.
  find  main-code no-lock where
        main-code.gds-code  = local-bar-code.gds-code and
        main-code.in-code   = "" and
        main-code.part-code = "" and
        main-code.unit-cli  = local-goods.unit-base and
        main-code.node-code = main-prt.node-code.
  local-main-code = main-code.b-code.
end procedure.
procedure prc-base-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-base-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code for ub.bar-code.
define buffer local-goods    for ub.goods.
define buffer base-code      for ub.bar-code.
  local-base-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find base-code no-lock where
       base-code.gds-code  = local-bar-code.gds-code and
       base-code.node-code = local-bar-code.node-code and
       base-code.in-code   = local-bar-code.in-code and
       base-code.part-code = local-bar-code.part-code and
       base-code.unit-cli  = local-goods.unit-base.
  local-base-code = base-code.b-code.
end procedure.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prcreate-new-price-doc :
do
on error undo, return error return-value
:
define input  parameter p-curr-db-num  as integer   no-undo .
define input  parameter p-obj-type     like ub.price-doc.obj-type no-undo.
define input  parameter p-obj-code     like ub.price-doc.obj-code no-undo.
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db-num   as integer   no-undo .
define output parameter p-price-doc-recid  as recid                no-undo.
define variable v-host-code         like ub.sysconf.host-code        no-undo.
define variable v-obj-current-date  like ub.price-doc.doc-date      no-undo.
define variable v-base-rate    like ub.price-doc-forming.base-rate   no-undo .
define variable v-base-scale   like ub.price-doc-forming.base-scale  no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming.
define buffer buf_price-doc         for ub.price-doc.
find first buf_price-doc-forming no-lock where
           buf_price-doc-forming.pdf-db     = p-pdf-db-num and
           buf_price-doc-forming.pdf-id     = p-pdf-id     and
           buf_price-doc-forming.plt-db-num = p-plt-db-num and
           buf_price-doc-forming.plt-id     = p-plt-id
           no-error .
if not available buf_price-doc-forming and p-plt-id = ? then do:
   run create_new_price-doc-forming
        ( input p-obj-type ,
          input p-obj-code ,
          output p-pdf-db-num ,
          output p-pdf-id ,
          output p-plt-db-num ,
          output p-plt-id
          ).
    find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.pdf-db     = p-pdf-db-num and
              buf_price-doc-forming.pdf-id     = p-pdf-id     and
              buf_price-doc-forming.plt-db-num = p-plt-db-num and
              buf_price-doc-forming.plt-id     = p-plt-id
              no-error .
end.
    create buf_price-doc .
    run doc-code in this-procedure
    (input  "main",
     input  p-obj-type  ,
     input  p-obj-code  ,
     input  ?,
     output buf_price-doc.doc-num) no-error.
    if error-status:error then do:
      message vss-workfile vss-revision vss-description skip
             error-status :get-message(1)
            "Ошибка при генерации номера документа." return-value view-as alert-box error.
      return error.
    end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    v-obj-current-date  = today .
    if not (buf_price-doc-forming.base-rate = 0 or buf_price-doc-forming.base-rate = ?) then do:
        v-base-rate   =  buf_price-doc-forming.base-rate  .
        v-base-scale  =  buf_price-doc-forming.base-scale .
    end.
    else do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  v-obj-current-date
  ,output v-base-rate
  ,output v-base-scale
  )  .
    end.
   assign
    buf_price-doc.base-rate      = v-base-rate
    buf_price-doc.base-scale     = v-base-scale
    buf_price-doc.cr-db-num      = p-curr-db-num
    buf_price-doc.doc-date       = v-obj-current-date
    buf_price-doc.fact-num       = 0
    buf_price-doc.host-code      = v-host-code
    buf_price-doc.is-corr        = false
    buf_price-doc.is-del         = false
    buf_price-doc.obj-code       = p-obj-code
    buf_price-doc.obj-type       = p-obj-type
    buf_price-doc.out-code       = ""
    buf_price-doc.pdf-db         = p-pdf-db-num
    buf_price-doc.pdf-id         = p-pdf-id
    buf_price-doc.plt-db-num     = p-plt-db-num
    buf_price-doc.plt-id         = p-plt-id
    buf_price-doc.PS             = "@ "
    buf_price-doc.rest-base      = 0
    buf_price-doc.rest-last      = 0
    buf_price-doc.rest-qnty      = 0
    buf_price-doc.rest-sale      = 0
    buf_price-doc.sale-base      = 0
    buf_price-doc.status_        = 'новый':U
    .
    buf_price-doc.doc-num-es     = entry(1, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.uid-es         = entry(2, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.doc-date       = date(entry(3, buf_price-doc-forming.des, chr(4))) no-error.
    if buf_price-doc.uid-es = "_" then buf_price-doc.uid-es = "" .
    assign
        p-price-doc-recid = recid ( buf_price-doc )
    .
end.
end procedure.
procedure prcreate-new-price-list :
do
on error undo, return error return-value
:
define input parameter p-price-doc-recid   as recid                    no-undo.
define input parameter p-gds-code          like ub.goods.gds-code         no-undo.
define input parameter p-price-sale        like ub.price-list.price-sale  no-undo.
define output parameter p-update           as logical                  no-undo.
define variable kk as integer no-undo .
define var v-b-code    like ub.bar-code.b-code     no-undo.
define variable p-hostcode as int no-undo .
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define buffer buf_price-doc        for ub.price-doc.
define buffer buf_price-list       for ub.price-list.
define buffer buf_bar-code         for ub.bar-code.
define buffer buf_goods            for ub.goods.
define buffer buf_root_gds-prt     for ub.gds-prt.
define buffer buf_gds-prt          for ub.gds-prt.
find first buf_price-doc no-lock
     where recid( buf_price-doc ) = p-price-doc-recid
.
find first buf_goods no-lock
     where buf_goods.gds-code = p-gds-code
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
if error-status :error
then do:
    message
        "Не найден основной бар-код"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_bar-code no-lock
     where buf_bar-code.b-code = v-b-code
no-error.
if error-status :error
then do:
    message
        "Не найдена запись bar-code"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
        skip "С основным бар-кодом"
        skip string(v-b-code)
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_root_gds-prt no-lock
     where buf_root_gds-prt.upper-code = buf_goods.prt-root
.
if buf_root_gds-prt.node-name <> '_Пустая шкала':U
  and buf_bar-code.in-code <> ""
then do:
    message
        "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
        "Артикул:" buf_goods.artic "Код:" buf_goods.gds-code buf_goods.gds-name
        view-as alert-box error.
    undo, return error.
end.
find first buf_gds-prt no-lock
     where buf_gds-prt.node-code = buf_bar-code.node-code
.
find first buf_price-list
     where buf_price-list.doc-num = buf_price-doc.doc-num
       and buf_price-list.b-code  = v-b-code
no-error.
if available buf_price-list
then do:
    message "Строка с товаром арт." buf_price-list.artic " уже есть в данной переоценке."
       skip "  Цена:   " buf_price-list.price-sale
       skip "Цена будет изменена"
    view-as alert-box warning.
    assign
        p-update = yes
    .
end.
else do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
    kk = kk + 1.
define variable v-main-bar-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-bar-code
  )  .
    create buf_price-list.
    assign
        buf_price-list.line-num    = kk
        buf_price-list.doc-num     = buf_price-doc.doc-num
        buf_price-list.b-code      = buf_bar-code.b-code
        buf_price-list.artic       = buf_goods.artic
        buf_price-list.prod-type   = buf_goods.prod-type
        buf_price-list.prod-code   = buf_goods.prod-code
        buf_price-list.main-price  = (buf_bar-code.b-code = v-main-bar-code )
        buf_price-list.calc-method = 'Отсутствует':U
        buf_price-list.obj-type    = buf_price-doc.obj-type
        buf_price-list.obj-code    = buf_price-doc.obj-code
        buf_price-list.price-sale  = p-price-sale
        buf_price-list.vat-pc      = local_vat-pc
        buf_price-list.slt-pc      = local_slt-pc
        p-update                   = no
    .
end.
end.
end procedure.
procedure create_new_price-doc-forming :
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define output parameter p-plt-id     as integer   no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  ?
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output p-plt-id
  ,output p-plt-db-num
  )  .
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = "автосоздание"
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
end procedure.
procedure prcreate-new-price-doc-forming-gds :
define input  parameter p-price-doc-forming-recid as recid  no-undo.
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter par-pr-notls as character no-undo .
define input  parameter par-pr-altex as character no-undo .
define input  parameter par-pr-sclex as character no-undo .
define input  parameter p-line-num    as integer   no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-price-sale  as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer main_bar-code for ub.bar-code  .
define variable main-b-code as integer   no-undo .
define variable v-sec as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
find first buf_price-doc-forming no-lock where
           recid(buf_price-doc-forming) = p-price-doc-forming-recid  no-error .
           if error-status :error then return error .
find first buf_goods no-lock where
           buf_goods.gds-code  = p-gds-code no-error .
           if error-status :error then return error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
run check-use-bar-code (main-b-code) no-error .
if error-status :error then return .
run create-line-pdf-mpl-lib (
     input buf_price-doc-forming.plt-db-num
    ,input buf_price-doc-forming.plt-id
    ,input buf_price-doc-forming.pdf-db
    ,input buf_price-doc-forming.pdf-id
    ,input p-line-num
    ,input main-b-code
    ,input buf_goods.artic
    ,input buf_goods.prod-type
    ,input buf_goods.prod-code
    ,input ""
    ,input 0
    ,input p-price-sale
    ,input ""
    ,input 0
   ,input-output v-sec ) no-error .
   if error-status :error  then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "2"
       view-as alert-box error
     .
   end.
define buffer old_price-list for ub.price-list  .
if par-pr-notls = "yes" then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  main-b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
end.
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.unit-cli <> buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                     ,input-output v-sec ) no-error .
        end.
    end.
end.
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num    = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.in-code  = "" and
                      buf_bar-code.unit-cli = buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                    ,input-output v-sec ) no-error .
        end.
    end.
end.
end.
end procedure.
procedure copy_new_price-doc-forming :
define input  parameter       p-recid      as recid no-undo .
define input-output parameter p-plt-db-num as integer   no-undo .
define input-output parameter p-plt-id     as integer   no-undo .
define output parameter       p-pdf-db-num as integer   no-undo .
define output parameter       p-pdf-id     as integer   no-undo .
define buffer buf_price-list-type        for ub.price-list-type  .
define buffer buf_price-doc-forming      for ub.price-doc-forming .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr .
define buffer buf_price-doc-forming-gds  for ub.price-doc-forming-gds .
define buffer buf_pd-forming-gds-attr    for ub.price-doc-forming-gdsattr .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
define variable v-name as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num = p-plt-db-num and
           buf_price-list-type.plt-id     = p-plt-id no-error .
if error-status :error then return error "Не найден ТПЛ".
if buf_price-list-type.stts <> 0 then return error "ТПЛ удален" .
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming )  = p-recid no-error .
    if available buf_price-doc-forming then do :
        assign
          v-base-rate  = buf_price-doc-forming.base-rate
          v-base-scale = buf_price-doc-forming.base-scale
          v-name       =  substitute("Скопировано с ДНЦ &1 &2",  buf_price-doc-forming.pdf-id , trim(buf_price-doc-forming.name)  )
        .
    end.
    else do:
        assign
          v-base-rate  = 1
          v-base-scale = 1
          v-name       = "Автосоздание"
        .
    end.
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = v-name
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
  if not available buf_price-doc-forming then return .
for each buf_price-doc-forming-attr no-lock where
         buf_price-doc-forming-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-attr.
    buffer-copy buf_price-doc-forming-attr to ub.price-doc-forming-attr
    assign
      ub.price-doc-forming-attr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-attr.plt-id      = p-plt-id
      ub.price-doc-forming-attr.pdf-db     = p-pdf-db-num
      ub.price-doc-forming-attr.pdf-id      = p-pdf-id
      .
end.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-gds.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-gds.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-gds.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gds.
    buffer-copy buf_price-doc-forming-gds to ub.price-doc-forming-gds
    assign
      ub.price-doc-forming-gds.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gds.plt-id      = p-plt-id
      ub.price-doc-forming-gds.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gds.pdf-id      = p-pdf-id
    .
end.
for each buf_pd-forming-gds-attr no-lock where
         buf_pd-forming-gds-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_pd-forming-gds-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_pd-forming-gds-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_pd-forming-gds-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gdsattr.
    buffer-copy buf_pd-forming-gds-attr to ub.price-doc-forming-gdsattr
    assign
      ub.price-doc-forming-gdsattr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gdsattr.plt-id      = p-plt-id
      ub.price-doc-forming-gdsattr.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gdsattr.pdf-id      = p-pdf-id
    .
end.
end procedure.
define variable par-pr-incpc as character no-undo.
define variable par-pr-rndmt as character no-undo.
define variable par-pr-rndbs as character no-undo.
define variable par-pr-clt-q as character no-undo.
define variable par-pr-dpl-q as character no-undo.
define variable par-pr-rdc-q as character no-undo.
define variable par-pr-abs-d as character no-undo.
define variable par-pr-altex as character no-undo.
define variable par-pr-parex as character no-undo.
define variable par-pr-sclex as character no-undo.
define variable par-pr-notls as character no-undo.
define variable par-pr-equ-dq as integer  no-undo.
define variable par-pr-discm as character no-undo .
define variable par-pr-dscnt as character no-undo .
define variable par-pr-print as character no-undo .
define variable par-pr-sigma as character no-undo .
define variable par-pr-goods as character no-undo.
define variable par-pr-nogds as character no-undo.
define variable par-alcohol  as character no-undo.
define variable par-gen-mrgn-ie as character no-undo .
define variable par-gen-mrgn-iv as character no-undo .
define variable par-gen-mrgn-im as character no-undo .
define variable par-pr-nakl-ie  as logical   no-undo .
define variable par-pr-nakl-iv  as logical   no-undo .
define variable par-pr-nakl-im  as logical   no-undo .
define variable par-pr-nogds-long as longchar no-undo .
define temp-table tmp-proof-price no-undo
  field node-code like ub.gds-grp.node-code
  field proof as decimal
  field price as decimal
index pi node-code proof descending .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info42 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure  chec-par :
define output parameter l-par as logical no-undo .
define input parameter l-host like ub.clients.obj-code no-undo .
define input parameter l-type like ub.clients.obj-type no-undo .
define input parameter l-code like ub.clients.obj-code no-undo .
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol'
  ,input  l-host
  ,input  l-type
  ,input  l-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-alcohol
  ,output par-type
  ) no-error .
 .
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input l-type
  ,input l-code
  ,input 'overval':U
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
    if thbjattr_thbj-attr.prop-code = 'pr-clt-q':U then par-pr-clt-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-dpl-q':U then par-pr-dpl-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-rdc-q':U then par-pr-rdc-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'pr-abs-d':U then par-pr-abs-d = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-altex':U then par-pr-altex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-parex':U then par-pr-parex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sclex':U then par-pr-sclex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-discm':U then par-pr-discm =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-dscnt':U then par-pr-dscnt  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-print':U then par-pr-print  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sigma':U then par-pr-sigma  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-incpc':U then par-pr-incpc  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-rndmt':U then par-pr-rndmt  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-rndbs':U then par-pr-rndbs  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-notls':U then par-pr-notls = string ( thbjattr_thbj-attr.property-value-logical) .
    if v-cntxt-db-num = 0 then do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds0':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods0':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
    else do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplmrgn in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-gen-mrgn-ie
  ,output par-gen-mrgn-iv
  ,output par-gen-mrgn-im
  ) no-error .
   IF error-status :error THEN message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "gbl/gtplmrgn.i"
     view-as alert-box error
   .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplpnakl in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-pr-nakl-ie
  ,output par-pr-nakl-iv
  ,output par-pr-nakl-im
  ) no-error .
   define variable ii as integer   no-undo .
   define variable nn as integer   no-undo .
   define variable v-fullname as character no-undo .
   nn = num-entries ( par-pr-nogds ).
   par-pr-nogds-long = "".
   if par-pr-nogds <> "0" and par-pr-nogds <> ""  then do:
      repeat ii = 1 to nn :
        run grplib-get-full-name  ( input integer(entry(ii,par-pr-nogds)) , output v-fullname ) .
        par-pr-nogds-long = par-pr-nogds-long + v-fullname + chr(4) .
      end.
      par-pr-nogds-long = trim (par-pr-nogds-long,chr(4)) .
   end.
l-par = true .
end procedure.
PROCEDURE cre-pr-list:
define input  parameter bc      like ub.price-list.b-code no-undo.
define input  parameter new-num like ub.price-doc.doc-num no-undo.
define output parameter new-rec as recid             no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer root-gds-prt   for ub.gds-prt.
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define variable cur-rt-base as decimal no-undo .
define variable cur-rt-rubl as decimal no-undo .
define variable p-hostcode as int no-undo .
define variable v-line-num as integer no-undo .
define variable v-skip-del-gds as logical no-undo initial no .
cre-pr:
do on error undo cre-pr, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  run check-use-bar-code ( buf-bar-code.b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo cre-pr, return.
  end.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find first root-gds-prt no-lock where
            root-gds-prt.upper-code = buf-goods.prt-root.
  if root-gds-prt.node-name <> '_Пустая шкала':U and
    buf-bar-code.in-code <> "" then do:
    message
      "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  if buf-goods.stts <> 0 and not v-skip-del-gds then do:
    message
      "Не допускается создавать цены на удаленные товары!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = new-num.
define variable v-ret as logical no-undo .
   run ver-modificator-price-is-null (
          input    buf-goods.artic        ,
          input    buf-goods.prod-type    ,
          input    buf-goods.prod-code    ,
          input    buf-price-doc.obj-type   ,
          input    buf-price-doc.obj-code   ,
          output   v-ret ).
      if v-ret = false then dO:
          message
            "Не допускается создавать цены на модификаторы с нулевой ценой !" skip (2)
            "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
            view-as alert-box error.
          undo cre-pr, return.
        end.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
  find first buf-price-list where
            buf-price-list.b-code  = buf-bar-code.b-code and
            buf-price-list.doc-num = new-num  and
            buf-price-list.price-type = ""    no-error .
  if not available buf-price-list then do:
    run calc-price-line-num (input  new-num , output v-line-num) .
    create buf-price-list.
    assign
      buf-price-list.line-num  = v-line-num
      buf-price-list.b-code    = buf-bar-code.b-code
      buf-price-list.doc-num   = buf-price-doc.doc-num
      buf-price-list.prod-type = buf-goods.prod-type
      buf-price-list.prod-code = buf-goods.prod-code
      buf-price-list.artic     = buf-goods.artic
      buf-price-list.obj-type  = buf-price-doc.obj-type
      buf-price-list.obj-code  = buf-price-doc.obj-code
      buf-price-list.vat-pc    = local_vat-pc
      buf-price-list.slt-pc    = local_slt-pc
      buf-price-list.price-prev = cur-pr
      .
    if  buf-gds-prt.upper-code = buf-goods.prt-root and
        buf-bar-code.in-code   = "" and
        buf-bar-code.part-code = "" and
        buf-bar-code.unit-cli  = buf-goods.unit-base then do:
      buf-price-list.main-price = yes.
      if cur-pr <> ? then do:
        run exp-prt (input buf-goods.gds-code,
                    input cur-dn,
                    input new-num,
                    output new-rec) no-error.
        if error-status :error then do:
          message
            "Ошибка вызова процедуры разворота специальных и неосновных цен."
            view-as alert-box error.
          undo cre-pr, return error.
        end.
      end.
    end.
    else do:
      if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
        buf-price-list.d-pcnt = ?.
      end.
      buf-price-list.main-price = no.
    end.
  end.
end.
new-rec = recid (buf-price-list).
END PROCEDURE.
procedure calc-price-line-num :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-num as character no-undo .
define output parameter p-num  as integer no-undo .
define variable v-fact as integer no-undo .
define buffer buf_1_price-list for ub.price-list .
p-num = 1 .
find last  buf_1_price-list no-lock where
           buf_1_price-list.doc-num = p-doc-num use-index line-num no-error .
           if available buf_1_price-list then
                assign
                  v-fact = buf_1_price-list.line-num
                .
v-fact = v-fact + 1.
if v-fact <> ? then if p-num < v-fact then p-num = v-fact .
 end.
end procedure.
PROCEDURE del-pr-list:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define variable l-ov-on as logical no-undo .
del-pr:
do on error undo del-pr, return error:
  find first  buf-price-list no-lock where
              buf-price-list.doc-num    = d-num and
              buf-price-list.b-code     = bc and
              buf-price-list.price-type = "" no-error.
  if not available buf-price-list then
    undo del-pr, return error.
  find  buf-goods no-lock where
        buf-goods.prod-type = buf-price-list.prod-type and
        buf-goods.prod-code = buf-price-list.prod-code and
        buf-goods.artic     = buf-price-list.artic.
  if buf-price-list.main-price then do:
    for each  buf-price-list exclusive-lock where
              buf-price-list.doc-num   = d-num and
              buf-price-list.artic     = buf-goods.artic and
              buf-price-list.prod-type = buf-goods.prod-type and
              buf-price-list.prod-code = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code = buf-price-list.b-code
    on error undo del-pr, return error:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=request:exclusive'
  ,output l-ov-on
  ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      if l-ov-on then do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=false'
  ,output l-ov-on
  ) no-error .
        if error-status :error then do:
        end.
       end.
      delete buf-price-list.
    end.
  end.
  else do:
    find  buf-bar-code no-lock where
          buf-bar-code.b-code = buf-price-list.b-code.
    if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
      message
        "Нельзя удалить неосновную цену." skip
        "Неосновная цена (скидка) не может быть неопределенной." skip
        "Код:" bc skip
        "Переоценка:" d-num
        view-as alert-box error.
      undo del-pr, return error.
    end.
    find current buf-price-list exclusive-lock no-error .
    delete buf-price-list.
    run calc-base-upd (input buf-bar-code.b-code,
                      input d-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo del-pr, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-base-upd:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer alt-bar-code   for ub.bar-code.
define buffer alt-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
calc-base:
do on error undo calc-base, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  for each  alt-bar-code no-lock where
            alt-bar-code.gds-code  = buf-bar-code.gds-code and
            alt-bar-code.node-code = buf-bar-code.node-code and
            alt-bar-code.part-code = buf-bar-code.part-code and
            alt-bar-code.in-code   = buf-bar-code.in-code and
            alt-bar-code.unit-cli <> buf-goods.unit-base,
      each  alt-price-list where
            alt-price-list.doc-num    = d-num and
            alt-price-list.b-code     = alt-bar-code.b-code and
            alt-price-list.price-type = ""
      on error undo calc-base, return error:
    run calc-pr-alt (input d-num,
                    input alt-bar-code.b-code,
                    input round-method,
                    input round-base) no-error.
    if error-status:error then
      undo calc-base, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-alt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter r-method as character             no-undo.
define input parameter r-base   as decimal              no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-alt:
do on error undo pr-alt, return error:
  if r-method = ? or
     r-base = ? then do:
    message
      "Нельзя удалить основную цену." skip
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      "Переоценка:" d-num
      view-as alert-box error.
    undo pr-alt, return error.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  if buf-price-list.d-pcnt = ? then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output pr-rec
  ,output pr-c-b-r
  )  .
    find old-price-list no-lock where
        recid (old-price-list) = pr-rec no-error.
    if available old-price-list and
      old-price-list.b-code = bc then
      buf-price-list.d-pcnt = old-price-list.d-pcnt.
    else
      buf-price-list.d-pcnt = 0.
  end.
   if buf-price-list.d-pcnt = ? then do:
      assign
        buf-price-list.price-sale =   if available old-price-list then old-price-list.price-sale else 0
        buf-price-list.calc-method =  'Не-считать':U + 'Основная':U
        .
  end.
  else do:
      assign
        buf-price-list.price-sale =   fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) *
                                      buf-bar-code.cli-base-rate *
                                      (1 - buf-price-list.d-pcnt / 100)
        buf-price-list.calc-method =  'Основная':U
        .
case r-method :
  when '9-окончание':U then do:
    if buf-price-list.price-sale < 29 then do:
      if (buf-price-list.price-sale - truncate (buf-price-list.price-sale, 0)) <> 0 then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 1
        .
      end.
    end.
    else do:
      if (buf-price-list.price-sale modulo 10) < 3 then do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if buf-price-list.price-sale < r-base then do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 0.99
      .
    end.
    else do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
    .
  end.
  when 'Произвольно':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale / r-base, 0) * r-base
      .
      if buf-price-list.price-sale = 0 then do:
        assign
          buf-price-list.price-sale = r-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if r-base <> 0 then do:
      if truncate ( buf-price-list.price-sale / r-base, 0 ) <> (buf-price-list.price-sale / r-base) then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale / r-base, 0) * r-base + r-base
        .
      end.
    end.
    if buf-price-list.price-sale = 0 then do:
      assign
        buf-price-list.price-sale = r-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = buf-price-list.price-sale * r-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" r-method skip
      "round-base"   r-base   skip
      "price"        buf-price-list.price-sale             skip
      view-as alert-box error .
  end.
end.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-discnt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  buf-price-list.d-pcnt = (1 -
                           buf-price-list.price-sale /
                           fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) /
                           buf-bar-code.cli-base-rate) *
                           100
                           .
end.
END PROCEDURE.
PROCEDURE calc-pr-sub :
define  input  parameter bc             like ub.price-list.b-code no-undo.
define  input  parameter d-num          like ub.price-doc.doc-num no-undo.
define  input  parameter calc-method  as character    no-undo.
define  input  parameter increase-pc  as decimal      no-undo.
define  input  parameter round-method as character    no-undo.
define  input  parameter round-base   as decimal      no-undo.
define  output parameter calc-rec     as recid        no-undo.
define  buffer buf-price-list for ub.price-list.
define  buffer buf-bar-code   for ub.bar-code.
define  buffer buf-goods      for ub.goods.
define  buffer buf-gds-prt    for ub.gds-prt.
define  buffer buf-gds-grp    for ub.gds-grp.
define  buffer buf-price-doc  for ub.price-doc.
calc-sub:
do on error undo calc-sub, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  calc-rec = recid (buf-price-list).
  if buf-price-list.main-price then do:
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-list.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-list (input  buf-bar-code.b-code,
                        input  buf-price-list.doc-num,
                        input  calc-method,
                        input  increase-pc,
                        input  round-method,
                        input  round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output calc-rec) no-error.
      if error-status :error then
        undo calc-sub, return error.
      calc-rec = recid (buf-price-list).
    end.
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-list.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-alt (input buf-price-doc.doc-num,
                      input buf-bar-code.b-code,
                      input round-method,
                      input round-base) no-error.
      if error-status :error then
        undo calc-sub, return error.
    end.
  end.
  else do:
    run calc-base-upd (input buf-bar-code.b-code,
                      input buf-price-doc.doc-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo calc-sub, return error.
  end.
end.
END PROCEDURE.
procedure ver-pr-nogds :
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-par-pr-nogds  as character no-undo .
define output parameter p-not           as logical   no-undo .
define output parameter p-str           as character no-undo .
define buffer buf_goods for ub.goods  .
define variable nn as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-namegrp as character no-undo .
  do
  on error undo, return error return-value
  :
  if p-par-pr-nogds = "1" then do:
     assign
      p-not = true
      p-str = ""
     .
     return .
  end.
  assign
    p-not = false
    p-str = ""
  .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  nn = num-entries(par-pr-nogds-long,chr(4)) .
  repeat ii = 1 to nn:
     v-namegrp = entry(ii , par-pr-nogds-long , chr(4) ) no-error .
     if buf_goods.grp-name  begins v-namegrp  then do:
        assign
          p-not = true
          p-str = substitute ( "Товар &1 &2 &3  может быть включен в ДНЦ из-за исключения запрета по группе : &4"  , buf_goods.artic, buf_goods.gds-name , buf_goods.grp-name , v-namegrp )
        .
        leave .
     end.
  end.
  end.
end procedure.
define buffer b1-doc-line    for ub.doc-line .
define variable doc-code      like ub.trn-doc.doc-code  no-undo .
define variable cost-base     as decimal no-undo .
define variable cost-rubl     as decimal no-undo .
define variable v-price-base  as decimal no-undo .
define variable v-price-rubl  as decimal no-undo.
define variable tt-price-sale as decimal no-undo.
define variable cur-rt-base   as decimal no-undo.
define variable cur-rt-rubl   as decimal no-undo.
define variable v-parts as logical   no-undo init false .
define variable tt-price-prodwihvat as decimal no-undo.
define variable tt-prod-vat         as decimal no-undo.
define variable v-root-b-code like ub.bar-code.b-code no-undo .
define variable pr-list-rec   as recid                no-undo .
define variable calc-rec      as recid                no-undo.
define variable par-type       as character          no-undo .
define variable v-round-method as character          no-undo .
define variable v-round-base   as decimal            no-undo .
define var p-new-road-tax as decimal no-undo .
define variable p-flag as logical init false no-undo .
define variable v-name-tax as character no-undo .
define variable par-disc-mar as logical no-undo .
define variable v-ret as logical no-undo .
define variable v-plt-id     as integer   no-undo .
define variable v-plt-db-num as integer   no-undo .
define variable v-pdf-id     as integer   no-undo .
define variable v-pdf-db-num as integer   no-undo .
define variable par-pr-nakl as logical   no-undo .
define variable v-rest-last as decimal   no-undo .
define variable v-rest-qnty as decimal   no-undo .
define variable v-rest-sale as decimal   no-undo .
define variable v-sale-base as decimal   no-undo .
define variable is-after-margin-parts as logical   no-undo .
define variable  par-gen-mrgn-ie-parts as character no-undo .
define variable  par-gen-mrgn-iv-parts as character no-undo .
define variable  par-gen-mrgn-im-parts as character no-undo .
define variable v-last-price-sale   as decimal   no-undo .
define variable v-last-calc-method  as character no-undo .
define variable attr-marg-pr-paraf   as character no-undo init "0".
define variable v-type               as character no-undo .
define variable loc-grp-increase-pc   as decimal   no-undo .
define variable loc-grp-round-method  as character no-undo .
define variable loc-grp-round-base    as decimal   no-undo .
define variable p-prc-min             as decimal   no-undo .
define variable p-prc-max             as decimal   no-undo .
define variable p-value-margin        as integer   no-undo .
define variable p-type-margin         as logical   no-undo .
define variable p-value-increase      as integer   no-undo .
define variable p-type-increase       as logical   no-undo .
define variable p-value-rmethod       as integer   no-undo .
define variable p-type-rmethod        as logical   no-undo .
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prl-vat:
  define input parameter parrecid as recid no-undo.
    define output parameter price-rubl-with-tax-saleprl    like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-with-tax-saleprl    like ub.doc-line.price-base no-undo.
    define output parameter price-rubl-without-tax-saleprl like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-without-tax-saleprl like ub.doc-line.price-base no-undo.
    define output parameter vat-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter vat-base-buyerprl              like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-buyerprl              like ub.doc-line.price-rubl no-undo.
    define output parameter slt-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter slt-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter road-tax-base-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter road-tax-rubl-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter excise-base-saleprl            like ub.doc-line.price-base no-undo.
    define output parameter excise-rubl-saleprl            like ub.doc-line.price-rubl no-undo.
    define output parameter discnt-base-saleprl            like ub.gds-dtl.discnt-base no-undo.
    define output parameter discnt-rubl-saleprl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlprl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlprl for ub.gds-dtl.
    define buffer out-vatp_partsprl       for ub.parts.
    define buffer out-vatp_sysconfprl     for ub.sysconf.
    define buffer out-vatp_doc-lineprl    for ub.doc-line.
    define buffer out-vatp_goodsprl       for ub.goods.
    define buffer out-vatp_trn-docprl     for ub.trn-doc.
    define buffer out-vatp_doc-attrprl    for ub.doc-attr.
    define variable varprice-base-consprl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-consprl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typeprl         as   character                           no-undo.
    define variable varfrm-cnsvprl              as   character                           no-undo.
    define variable varroot-nodeprl             as   integer                             no-undo.
    define variable varempty-scaleprl           as   logical                             no-undo.
    define variable varis-cons-parts-haveprl    as   logical                             no-undo.
    define variable varsum-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlprl        as   logical                             no-undo.
    define variable varcurprlprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprlprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurprldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbprl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltprl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-docoprl  for ub.trn-doc .
    define buffer   in-vatp-partsoprl    for ub.parts   .
    define buffer   in-vatp-docoprl      for ub.trn-doc .
    define buffer   in-vatp-goodsoprl    for ub.goods   .
    define buffer   in-vatp-sysconfoprl  for ub.sysconf .
    define buffer   in-vatp_doc-attroprl for ub.doc-attr.
    define variable in-vatp-have-vat-sltoprl       as   logical initial yes    no-undo.
    define variable vat-pc-locoprl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprboprl                  as   character              no-undo.
    define variable slt-pc-locoprl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateoprl              as   decimal                no-undo.
    define variable price-rubl-with-tax-locoprl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-locoprl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-locoprl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-locoprl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-locoprl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-locoprl  like ub.doc-line.price-base no-undo.
    define variable vat-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-locoprl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-locoprl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-locoprl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-locoprl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-locoprl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-locoprl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-locoprl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-locoprl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdoprl             as   character              no-undo.
    define variable varinvatp-typeoprl             as   character              no-undo.
  define buffer bf_price-list for ub.price-list.
  define buffer bf_goods      for ub.goods.
  define buffer bf_sysconf    for ub.sysconf.
  define buffer bf_parts      for ub.parts.
  define variable varbase-rate   like ub.trn-doc.base-rate     no-undo.
  define variable varbase-scale  like ub.trn-doc.base-scale    no-undo.
  define variable varroad-tax    like ub.price-list.road-tax   no-undo.
  define variable varexcise      like ub.price-list.excise     no-undo.
  define variable varvat-pc      like ub.doc-line.vat-pc       no-undo.
  define variable varslt-pc      like ub.doc-line.slt-pc       no-undo.
  define variable varprice-base  like ub.price-list.price-sale no-undo.
  define variable varprice-rubl  like ub.price-list.price-sale no-undo.
  define variable vardiscnt-base like ub.price-list.price-sale no-undo.
  define variable vardiscnt-rubl like ub.price-list.price-sale no-undo.
  define variable v-host-code    like ub.sysconf.host-code     no-undo.
  define variable vardoc-num     like ub.price-list.doc-num    no-undo.
  define variable vardoc-code    like ub.price-list.doc-num    no-undo.
  define variable varobj-type    like ub.price-list.obj-type   no-undo.
  define variable varobj-code    like ub.price-list.obj-code   no-undo.
  define variable varartic       like ub.price-list.artic      no-undo.
  define variable varprod-type   like ub.price-list.prod-type  no-undo.
  define variable varprod-code   like ub.price-list.prod-code  no-undo.
  define variable varfact-qnty   like ub.price-list.doc-qnty   no-undo.
  define variable varcons-vat-pc like ub.doc-line.vat-pc       no-undo.
  define variable varext-doc-type like ub.trn-doc.ext-doc-type no-undo.
  define variable vardoc-qnty     like ub.price-list.doc-qnty no-undo.
  define variable vardoc-type     as   character              no-undo.
  do
  on error undo, return error "Ошибка при вызове процедуры prl-vat."
  :
    find first bf_price-list no-lock
      where recid(bf_price-list) = parrecid
      no-error .
    if not available bf_price-list
    then do:
      return error "Ошибка во входящих параметрах prl-vat.i" .
    end.
    find first bf_goods no-lock
      where bf_goods.artic     = bf_price-list.artic
        and bf_goods.prod-type = bf_price-list.prod-type
        and bf_goods.prod-code = bf_price-list.prod-code
      no-error .
    if not available bf_goods
    then do:
      undo, return error substitute("Не найден товар &1 &2 &3 для переоценки с кодом &4",bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code,parrecid).
    end.
    assign
      varvat-pc = bf_price-list.vat-pc
      varslt-pc = bf_price-list.slt-pc
    .
    if varvat-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НДС",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    if varslt-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НП",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    assign
      varbase-rate   = 1
      varbase-scale  = 1
      varroad-tax    = bf_price-list.road-tax
      varexcise      = bf_price-list.excise
      varprice-base  = bf_price-list.price-sale
      varprice-rubl  = bf_price-list.price-sale
      vardiscnt-base = 0
      vardiscnt-rubl = 0
    .
    assign
      varfact-qnty = 0
    .
    for each bf_parts no-lock
      where bf_parts.out-code   = bf_price-list.doc-num
        and bf_parts.obj-type   = bf_price-list.obj-type
        and bf_parts.obj-code   = bf_price-list.obj-code
        and bf_parts.artic      = bf_price-list.artic
        and bf_parts.prod-type  = bf_price-list.prod-type
        and bf_parts.prod-code  = bf_price-list.prod-code
    :
      assign
        varfact-qnty = varfact-qnty + bf_parts.fact-qnty
      .
    end.
    assign
      vardoc-num   = bf_price-list.doc-num
      vardoc-code  = bf_price-list.doc-num
      varobj-type  = bf_price-list.obj-type
      varobj-code  = bf_price-list.obj-code
      varartic     = bf_price-list.artic
      varprod-type = bf_price-list.prod-type
      varprod-code = bf_price-list.prod-code
      vardoc-qnty  = varfact-qnty
      varext-doc-type = 'ot':U
    .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf_price-list.obj-type
  ,input  bf_price-list.obj-code
  ,output v-host-code
  )  .
    find first bf_sysconf no-lock
      where bf_sysconf.host-code = v-host-code
      .
    if bf_sysconf.cons-vat-pc = ?
    then do:
      return error "Не задан консигнационный НДС по фирме." .
    end.
    else do:
      assign
        varcons-vat-pc = bf_sysconf.cons-vat-pc
      .
    end.
if varext-doc-type = 'ot':U or
   varext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltprl = yes.
end.
else do:
  find first out-vatp_doc-attrprl no-lock
    where out-vatp_doc-attrprl.doc-code  = vardoc-code
      and out-vatp_doc-attrprl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrprl then do:
    assign
      out-vatp-have-vat-sltprl = yes.
  end.
  else do:
     out-vatp-have-vat-sltprl = no.
  end.
end.
find first out-vatp_goodsprl where out-vatp_goodsprl.artic     = varartic     and
                                   out-vatp_goodsprl.prod-type = varprod-type and
                                   out-vatp_goodsprl.prod-code = varprod-code no-lock.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  varartic
  ,input  varprod-type
  ,input  varprod-code
  ,output varroot-nodeprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" varartic varprod-type varprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodeprl
  ,input  'empty-scale=request'
  ,output varempty-scaleprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" varartic varprod-type varprod-code skip
    "Признак" varroot-nodeprl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbprl
  )  .
if varoutvprbprl = "base":u then do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax / varbase-rate * varbase-scale)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   / varbase-rate * varbase-scale)
  .
end.
if varoutvprbprl = "rubl":u then do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * varbase-rate / varbase-scale)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * varbase-rate / varbase-scale) .
end.
assign
  varis-cons-parts-haveprl =  no.
assign
  varfact-qntyprl       = 0
  varcons-qntyprl       = 0
  varprice-base-consprl = 0
  varprice-rubl-consprl = 0.
find first out-vatp_doc-lineprl where
           out-vatp_doc-lineprl.doc-code   = vardoc-num
       and out-vatp_doc-lineprl.artic      = varartic
       and out-vatp_doc-lineprl.prod-type  = varprod-type
       and out-vatp_doc-lineprl.prod-code  = varprod-code no-lock no-error.
if available out-vatp_doc-lineprl           and
  (out-vatp_doc-lineprl.status_ = 'запрос':U or out-vatp_goodsprl.gds-type = 'у':U) then do:
  assign
    varfact-qntyprl = out-vatp_doc-lineprl.fact-qnty.
end.
else do:
  for each out-vatp_partsprl where out-vatp_partsprl.out-code   = vardoc-num
                               and out-vatp_partsprl.obj-type   = varobj-type
                               and out-vatp_partsprl.obj-code   = varobj-code
                               and out-vatp_partsprl.artic      = varartic
                               and out-vatp_partsprl.prod-type  = varprod-type
                               and out-vatp_partsprl.prod-code  = varprod-code no-lock :
    if out-vatp_partsprl.purch-code = 2 then do:
assign
  price-rubl-with-tax-locoprl = out-vatp_partsprl.price-rubl
  price-base-with-tax-locoprl = out-vatp_partsprl.price-base
.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprboprl
  )  .
  if out-vatp_partsprl.out-code = 'free-zone':U     or
     out-vatp_partsprl.out-code = 'out-zone':U   or
     out-vatp_partsprl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltoprl = yes.
  end.
  else do:
    find first in-vatp_doc-attroprl no-lock
      where in-vatp_doc-attroprl.doc-code  = out-vatp_partsprl.out-code
        and in-vatp_doc-attroprl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attroprl then do:
      assign
        in-vatp-have-vat-sltoprl = yes.
    end.
    else do:
         in-vatp-have-vat-sltoprl = no.
    end.
  end.
  assign
   price-cli-with-tax-locoprl = out-vatp_partsprl.price-cli
   cli-base-rateoprl          = out-vatp_partsprl.cli-base-rate.
  ASSIGN   road-tax-base-locoprl  = (if out-vatp_partsprl.road-tax-base  = ? then 0 else out-vatp_partsprl.road-tax-base)
           road-tax-rubl-locoprl  = (if out-vatp_partsprl.road-tax-rubl  = ? then 0 else out-vatp_partsprl.road-tax-rubl).
  ASSIGN  transport-base-locoprl = (if out-vatp_partsprl.transport-base = ? then 0 else out-vatp_partsprl.transport-base)
          transport-rubl-locoprl = (if out-vatp_partsprl.transport-rubl = ? then 0 else out-vatp_partsprl.transport-rubl)
          other-base-locoprl     = (if out-vatp_partsprl.other-base     = ? then 0 else out-vatp_partsprl.other-base)
          other-rubl-locoprl     = (if out-vatp_partsprl.other-rubl     = ? then 0 else out-vatp_partsprl.other-rubl)
          vat-pc-locoprl         = (if out-vatp_partsprl.vat-pc         = ? then 0 else out-vatp_partsprl.vat-pc)
          slt-pc-locoprl         = (if out-vatp_partsprl.slt-pc         = ? then 0 else out-vatp_partsprl.slt-pc).
          ASSIGN   slt-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
    ASSIGN   slt-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
  assign
    exch-rate-cli-locoprl = (out-vatp_partsprl.price-rubl - transport-rubl-locoprl - other-rubl-locoprl - road-tax-rubl-locoprl - (if out-vatp_partsprl.vat-type <> 'в т. ч.':U then vat-rubl-locoprl else 0) - (if out-vatp_partsprl.slt-type <> 'в т. ч.':U then slt-rubl-locoprl else 0)) / out-vatp_partsprl.price-cli .
  assign
    slt-cli-locoprl        = slt-rubl-locoprl       / exch-rate-cli-locoprl
    vat-cli-locoprl        = vat-rubl-locoprl       / exch-rate-cli-locoprl
    road-tax-cli-locoprl   = road-tax-rubl-locoprl  / exch-rate-cli-locoprl
    transport-cli-locoprl  = 0
    other-cli-locoprl      = 0
  .
ASSIGN
          price-base-without-tax-locoprl = price-base-with-tax-locoprl - vat-base-locoprl - slt-base-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))
    price-rubl-without-tax-locoprl = price-rubl-with-tax-locoprl - vat-rubl-locoprl - slt-rubl-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))
.
      assign
        varprice-base-consprl = varprice-base-consprl + (price-base-with-tax-locoprl - (if road-tax-base-locoprl = ? then 0 else road-tax-base-locoprl))* out-vatp_partsprl.fact-qnty
        varprice-rubl-consprl = varprice-rubl-consprl + (price-rubl-with-tax-locoprl - (if road-tax-rubl-locoprl = ? then 0 else road-tax-rubl-locoprl))* out-vatp_partsprl.fact-qnty.
      assign
        varis-cons-parts-haveprl = yes
        varcons-qntyprl          = varcons-qntyprl + out-vatp_partsprl.fact-qnty.
    end.
    assign
      varfact-qntyprl = varfact-qntyprl + out-vatp_partsprl.fact-qnty.
  end.
end.
assign
  varprice-base-consprl = varprice-base-consprl / varcons-qntyprl
  varprice-rubl-consprl = varprice-rubl-consprl / varcons-qntyprl.
if varprice-base-consprl = ? then do:
  assign
    varprice-base-consprl = 0.
end.
if varprice-rubl-consprl = ? then do:
  assign
    varprice-rubl-consprl = 0.
end.
assign
    slt-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-base-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-base-saleprl            = vardiscnt-base
  price-base-with-tax-saleprl    = (varprice-base - vardiscnt-base)
    slt-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-rubl-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-rubl-saleprl            = vardiscnt-rubl
  price-rubl-with-tax-saleprl    = (varprice-rubl - vardiscnt-rubl)
  .
if vardoc-type = 'инв':U then do:
  assign
    varfact-qntyprl = vardoc-qnty.
end.
else do:
  assign
    varfact-qntyprl = varfact-qnty.
end.
if varis-cons-parts-haveprl = no then do:
  assign
        vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
        vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc).
end.
else do:
  if vardoc-type = 'инв':U then do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
  else do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-base-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-rubl-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
end.
assign
price-base-without-tax-saleprl = price-base-with-tax-saleprl - vat-base-saleprl - slt-base-saleprl - road-tax-base-saleprl
price-rubl-without-tax-saleprl = price-rubl-with-tax-saleprl - vat-rubl-saleprl - slt-rubl-saleprl - road-tax-rubl-saleprl.
  end.
end procedure.
def var vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
Procedure compare_road-tax :
  define input-output parameter new-road-tax as decimal no-undo .
  define input parameter p-b-code like ub.bar-code.b-code no-undo.
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-mess     as logical   no-undo .
  define variable v-log      as logical   no-undo .
  define variable p-cur-dn   as character no-undo .
  define variable p-cur-pr   as decimal   no-undo .
  define variable p-cur-rt   as decimal   no-undo .
  define variable p-cur-ex   as decimal   no-undo .
  define variable v-name-tax as character no-undo .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-b-code
  ,input  0
  ,input  0
  ,output p-cur-dn
  ,output p-cur-pr
  ,output p-cur-rt
  ,output p-cur-ex
  )  .
if p-cur-dn <> ? Then DO :
   new-road-tax = p-cur-rt .
End.
end procedure.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE calc-pr-list :
define input  parameter bc          like ub.price-list.b-code   no-undo .
define input  parameter d-num       like ub.price-doc.doc-num   no-undo .
define input  parameter calc-method             as character    no-undo .
define input  parameter increase-pc             as decimal      no-undo .
define input  parameter round-method            as character    no-undo .
define input  parameter round-base              as decimal      no-undo .
define input  parameter p-doc-price-rubl        as decimal      no-undo .
define input  parameter p-doc-price-base        as decimal      no-undo .
define input  parameter p-doc-price-rubl-novat  as decimal      no-undo .
define input  parameter p-doc-price-base-novat  as decimal      no-undo .
define output parameter calc-rec                as recid        no-undo .
define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer buf-gds-grp    for ub.gds-grp.
define buffer buf_contract   for ub.contract .
define buffer buf_contract-specif for ub.contract-specif .
define variable cur-pr like ub.price-list.price-sale no-undo .
define variable cur-rt like ub.price-list.road-tax   no-undo .
define variable cur-ex like ub.price-list.excise     no-undo .
define variable cur-dn like ub.price-list.doc-num    no-undo .
define variable loc-ret        as logical            no-undo .
define variable old-price-sale as decimal            no-undo .
define variable v-bonus        as decimal            no-undo .
assign
  loc-ret = true
.
calc-pr:
do on error undo calc-pr, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  g#log = yes.
  define variable loc-increase-pc      like  ub.goods.increase-pc no-undo .
  define variable loc-grp-increase-pc  like  ub.goods.increase-pc no-undo .
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-increase-pc in g#library
  (input  buf-goods.gds-code
  ,input  buf-price-list.obj-type
  ,input  buf-price-list.obj-code
  ,output  loc-increase-pc
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка метода поиска наценки товара на объекте" skip
     error-status :get-message(1) .
  end.
define variable p-prc-min        as decimal   no-undo .
define variable p-prc-max        as decimal   no-undo .
define variable p-round-method   as character no-undo .
define variable p-base           as decimal   no-undo .
define variable p-value-margin   as integer   no-undo .
define variable p-type-margin    as logical   no-undo .
define variable p-value-increase as integer   no-undo .
define variable p-type-increase  as logical   no-undo .
define variable p-value-rmethod  as integer   no-undo .
define variable p-type-rmethod   as logical   no-undo .
run gds-attr-margin-value
(
  input   buf-goods.gds-code ,
  input   buf-price-list.obj-type  ,
  input   buf-price-list.obj-code  ,
  output  p-prc-min  ,
  output  p-prc-max  ,
  output  loc-grp-increase-pc,
  output  p-round-method   ,
  output  p-base           ,
  output  p-value-margin    ,
  output  p-type-margin     ,
  output  p-value-increase    ,
  output  p-type-increase   ,
  output  p-value-rmethod    ,
  output  p-type-rmethod
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка процедуры поиска наценки по группе товара на объекте" skip
     error-status :get-message(1) skip
     return-value .
  end.
  define variable g-g as logical no-undo .
  g-g = false .
  case calc-method:
    when 'Товар':U then do:
      case buf-goods.calc-method:
        when 'Группа':U then do:
          find buf-gds-grp no-lock where
              buf-gds-grp.node-code = buf-goods.grp-code.
          case buf-gds-grp.calc-method:
   when 'Накл-безНДС':U  then do:
      if ub.trn-doc.doc-type = 'при':U and
         ( ub.trn-doc.ext-doc-type = 'ie':U  ) then do:
              run str/gdsnovat.p ('Накл-безНДС':U,
                      buf-price-list.obj-type,
                      buf-price-list.obj-code,
                      buf-price-doc.host-code,
                      buf-price-list.artic,
                      buf-price-list.prod-type,
                      buf-price-list.prod-code,
                      loc-grp-increase-pc,
                      doc-code,
                      input p-doc-price-rubl-novat   ,
                      input p-doc-price-base-novat   ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl )
                      .
                      if available ub.doc-line then do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                      else do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                End.
      else do:
          run str/gdsnovat.p ('Накл-безНДС':U + "Other":U ,
              buf-price-list.obj-type,
              buf-price-list.obj-code,
              buf-price-doc.host-code,
              buf-price-list.artic,
              buf-price-list.prod-type,
              buf-price-list.prod-code,
              loc-grp-increase-pc,
              doc-code,
              input p-doc-price-rubl-novat   ,
              input p-doc-price-base-novat   ,
              output cost-base   ,
              output cost-rubl   ,
              output v-price-base  ,
              output v-price-rubl  ,
              output cur-rt-base ,
              output cur-rt-rubl ).
              if available ub.doc-line then do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                  .
              end.
              else do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl             else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl           else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl            else v-price-base
                  .
              end.
          End.
    end.
    when 'НсП':U then do:
      run str/gdsnovat.p ( 'НсП':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-grp-increase-pc,
          "",
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'НсП':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет-безНДС':U then do:
      run str/gdsnovat.p ('Учет-безНДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-grp-increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет-безНДС':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет+накл':U then do:
      run str/gdsnovat.p
         (input 'Учет+накл':U,
          input buf-price-list.obj-type,
          input buf-price-list.obj-code,
          input buf-price-doc.host-code,
          input buf-price-list.artic,
          input buf-price-list.prod-type,
          input buf-price-list.prod-code,
          input loc-grp-increase-pc,
          input doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет+накл':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Уч+накл-НДС':U then do:
      run str/gdsnovat.p ('Уч+накл-НДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-grp-increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl )
          .
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method =  'Уч+накл-НДС':U  + " " + doc-code
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учетная':U then do:
      run trg/gdsavrg.p ('Учетная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
        assign
          buf-price-list.calc-method =  'Учетная':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
    end.
    when 'Учет-объект':U then do:
      run trg/gdsavrg.p ('Учет-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      assign
        buf-price-list.calc-method = 'Учет-объект':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Учет-резерв':U then do:
      run trg/gdsavrg.p
        ('Учет-резерв':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          output cost-base,
          output cost-rubl,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
      assign
        buf-price-list.calc-method = 'Учет-резерв':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Приходная':U then do:
      run trg/gdsavrg.p ('Приходная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))
      then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
        buf-price-list.calc-method = 'Приходная':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Прих-объект':U then do:
      run trg/gdsavrg.p ('Прих-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))   then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Прих-объект':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Производит':U then do:
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output tt-price-prodwihvat
 , output cost-rubl
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Производит':U
          buf-price-list.price-calc  =  cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + loc-grp-increase-pc / 100)
          tt-price-sale   =  cost-rubl * (1 + loc-grp-increase-pc / 100)
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'ПорогПр-НДС':U then do:
          run calc-price-levelprod (
            input 2            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl ,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр-НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
          tt-price-sale   =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
      end.
    end.
    when 'ПорогПр+НДС':U then do:
          run calc-price-levelprod (
            input 1            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр+НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl  .
          tt-price-sale   =  cost-rubl  .
      end.
    end.
    when 'Произв-НДС':U then do:
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output cost-rubl
 , output tt-price-prodwihvat
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Произв-НДС':U
          buf-price-list.price-calc  = cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + loc-grp-increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          tt-price-sale   =  cost-rubl * (1 + loc-grp-increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'Новая':U then
      if buf-price-list.price-sale = ? then
        message "Неизвестна новая цена для товара :"
                buf-price-list.artic buf-goods.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Новая':U
          buf-price-list.price-calc = buf-price-list.price-sale
          buf-price-list.price-sale = buf-price-list.price-sale * (1 + loc-grp-increase-pc / 100)
          tt-price-sale = buf-price-list.price-sale * (1 + loc-grp-increase-pc / 100)
          .
    when 'Накладная':U then do:
        run str/pr-wbil.p
        ( input "in-pr"              ,
          input 'Накладная':U   ,
          input recid(ub.trn-doc)     ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code           ,
          input buf-goods.gds-name       ,
          input buf-goods.gds-code       ,
          input buf-price-list.artic          ,
          input buf-price-list.prod-type      ,
          input buf-price-list.prod-code      ,
          input buf-bar-code.node-code      ,
          input loc-grp-increase-pc                ,
          input p-doc-price-rubl   ,
          input p-doc-price-base   ,
          output v-price-base      ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then do:
          assign
            buf-price-list.calc-method = 'Накладная':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
      end.
      else do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "444"
           view-as alert-box error
         .
      end.
    end.
    when 'НсП+накл':U then do:
        run str/pr-wbil.p
        ( input "in-pr"                ,
          input 'НсП+накл':U ,
          input recid(ub.trn-doc)       ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code             ,
          input buf-goods.gds-name         ,
          input buf-goods.gds-code         ,
          input buf-price-list.artic            ,
          input buf-price-list.prod-type        ,
          input buf-price-list.prod-code        ,
          input buf-bar-code.node-code        ,
          input 0                    ,
          input p-doc-price-rubl     ,
          input p-doc-price-base     ,
          output v-price-base        ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then
          assign
            buf-price-list.calc-method = 'НсП+накл':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
    end.
    when 'Отсутствует':U then do:
      if buf-price-list.price-sale = ? then do:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-list.obj-type
  ,input  buf-price-list.obj-code
  ,input  buf-price-list.b-code
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
        if cur-pr <> ? then
          assign
            buf-price-list.calc-method = 'Отсутствует':U
            buf-price-list.price-calc  = cur-pr
            buf-price-list.price-sale  = cur-pr
            tt-price-sale   = cur-pr
            buf-price-list.road-tax    = cur-rt
            buf-price-list.excise      = cur-ex
            .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Не-считать':U then do:
      if buf-price-list.price-sale = ? then do:
        assign
          buf-price-list.calc-method = 'Не-считать':U
          buf-price-list.price-calc = ?
          .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Спецификация':U then do:
      if available ub.trn-doc
      then do:
        if ub.trn-doc.contract-code <> 0 then do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.contract-code = ub.trn-doc.contract-code
          no-error.
          if available buf_contract then do:
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-grp-increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-grp-increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + loc-grp-increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + loc-grp-increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден договор с кодом :"
                    ub.trn-doc.contract-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
        else do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.cli-type      = ub.trn-doc.cli-type
            and buf_contract.cli-code      = ub.trn-doc.cli-code
            and buf_contract.status_       = 'тек':U
            and buf_contract.contract-date-beg   <= ub.trn-doc.doc-date
            and ( buf_contract.contract-date-end >= ub.trn-doc.doc-date
              or buf_contract.contract-date-end   = date('') )
          no-error.
          if available buf_contract then do:
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-grp-increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-grp-increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + loc-grp-increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + loc-grp-increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден ни один текущий договор для поставщика:"
                    ub.trn-doc.cli-type ub.trn-doc.cli-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
      end.
    end.
    otherwise do:
      message "Не задан способ вычисления цены : " skip
              "Артикул:" buf-price-list.artic buf-goods.gds-name skip
              "in-pr"
              view-as alert-box error.
      g#log = no.
      return error .
    end.
          end case.
           assign
            round-method = p-round-method
            round-base   = p-base
            g-g = true
           .
        end.
   when 'Накл-безНДС':U  then do:
      if ub.trn-doc.doc-type = 'при':U and
         ( ub.trn-doc.ext-doc-type = 'ie':U  ) then do:
              run str/gdsnovat.p ('Накл-безНДС':U,
                      buf-price-list.obj-type,
                      buf-price-list.obj-code,
                      buf-price-doc.host-code,
                      buf-price-list.artic,
                      buf-price-list.prod-type,
                      buf-price-list.prod-code,
                      loc-increase-pc,
                      doc-code,
                      input p-doc-price-rubl-novat   ,
                      input p-doc-price-base-novat   ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl )
                      .
                      if available ub.doc-line then do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                      else do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                End.
      else do:
          run str/gdsnovat.p ('Накл-безНДС':U + "Other":U ,
              buf-price-list.obj-type,
              buf-price-list.obj-code,
              buf-price-doc.host-code,
              buf-price-list.artic,
              buf-price-list.prod-type,
              buf-price-list.prod-code,
              loc-increase-pc,
              doc-code,
              input p-doc-price-rubl-novat   ,
              input p-doc-price-base-novat   ,
              output cost-base   ,
              output cost-rubl   ,
              output v-price-base  ,
              output v-price-rubl  ,
              output cur-rt-base ,
              output cur-rt-rubl ).
              if available ub.doc-line then do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                  .
              end.
              else do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl             else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl           else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl            else v-price-base
                  .
              end.
          End.
    end.
    when 'НсП':U then do:
      run str/gdsnovat.p ( 'НсП':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-increase-pc,
          "",
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'НсП':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет-безНДС':U then do:
      run str/gdsnovat.p ('Учет-безНДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет-безНДС':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет+накл':U then do:
      run str/gdsnovat.p
         (input 'Учет+накл':U,
          input buf-price-list.obj-type,
          input buf-price-list.obj-code,
          input buf-price-doc.host-code,
          input buf-price-list.artic,
          input buf-price-list.prod-type,
          input buf-price-list.prod-code,
          input loc-increase-pc,
          input doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет+накл':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Уч+накл-НДС':U then do:
      run str/gdsnovat.p ('Уч+накл-НДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl )
          .
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method =  'Уч+накл-НДС':U  + " " + doc-code
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учетная':U then do:
      run trg/gdsavrg.p ('Учетная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
        assign
          buf-price-list.calc-method =  'Учетная':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
    end.
    when 'Учет-объект':U then do:
      run trg/gdsavrg.p ('Учет-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      assign
        buf-price-list.calc-method = 'Учет-объект':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Учет-резерв':U then do:
      run trg/gdsavrg.p
        ('Учет-резерв':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          output cost-base,
          output cost-rubl,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
      assign
        buf-price-list.calc-method = 'Учет-резерв':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Приходная':U then do:
      run trg/gdsavrg.p ('Приходная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))
      then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
        buf-price-list.calc-method = 'Приходная':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Прих-объект':U then do:
      run trg/gdsavrg.p ('Прих-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))   then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Прих-объект':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Производит':U then do:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output tt-price-prodwihvat
 , output cost-rubl
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Производит':U
          buf-price-list.price-calc  =  cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + loc-increase-pc / 100)
          tt-price-sale   =  cost-rubl * (1 + loc-increase-pc / 100)
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'ПорогПр-НДС':U then do:
          run calc-price-levelprod (
            input 2            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl ,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр-НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
          tt-price-sale   =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
      end.
    end.
    when 'ПорогПр+НДС':U then do:
          run calc-price-levelprod (
            input 1            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр+НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl  .
          tt-price-sale   =  cost-rubl  .
      end.
    end.
    when 'Произв-НДС':U then do:
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output cost-rubl
 , output tt-price-prodwihvat
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Произв-НДС':U
          buf-price-list.price-calc  = cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + loc-increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          tt-price-sale   =  cost-rubl * (1 + loc-increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'Новая':U then
      if buf-price-list.price-sale = ? then
        message "Неизвестна новая цена для товара :"
                buf-price-list.artic buf-goods.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Новая':U
          buf-price-list.price-calc = buf-price-list.price-sale
          buf-price-list.price-sale = buf-price-list.price-sale * (1 + loc-increase-pc / 100)
          tt-price-sale = buf-price-list.price-sale * (1 + loc-increase-pc / 100)
          .
    when 'Накладная':U then do:
        run str/pr-wbil.p
        ( input "in-pr"              ,
          input 'Накладная':U   ,
          input recid(ub.trn-doc)     ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code           ,
          input buf-goods.gds-name       ,
          input buf-goods.gds-code       ,
          input buf-price-list.artic          ,
          input buf-price-list.prod-type      ,
          input buf-price-list.prod-code      ,
          input buf-bar-code.node-code      ,
          input loc-increase-pc                ,
          input p-doc-price-rubl   ,
          input p-doc-price-base   ,
          output v-price-base      ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then do:
          assign
            buf-price-list.calc-method = 'Накладная':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
      end.
      else do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "444"
           view-as alert-box error
         .
      end.
    end.
    when 'НсП+накл':U then do:
        run str/pr-wbil.p
        ( input "in-pr"                ,
          input 'НсП+накл':U ,
          input recid(ub.trn-doc)       ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code             ,
          input buf-goods.gds-name         ,
          input buf-goods.gds-code         ,
          input buf-price-list.artic            ,
          input buf-price-list.prod-type        ,
          input buf-price-list.prod-code        ,
          input buf-bar-code.node-code        ,
          input 0                    ,
          input p-doc-price-rubl     ,
          input p-doc-price-base     ,
          output v-price-base        ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then
          assign
            buf-price-list.calc-method = 'НсП+накл':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
    end.
    when 'Отсутствует':U then do:
      if buf-price-list.price-sale = ? then do:
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-list.obj-type
  ,input  buf-price-list.obj-code
  ,input  buf-price-list.b-code
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
        if cur-pr <> ? then
          assign
            buf-price-list.calc-method = 'Отсутствует':U
            buf-price-list.price-calc  = cur-pr
            buf-price-list.price-sale  = cur-pr
            tt-price-sale   = cur-pr
            buf-price-list.road-tax    = cur-rt
            buf-price-list.excise      = cur-ex
            .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Не-считать':U then do:
      if buf-price-list.price-sale = ? then do:
        assign
          buf-price-list.calc-method = 'Не-считать':U
          buf-price-list.price-calc = ?
          .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Спецификация':U then do:
      if available ub.trn-doc
      then do:
        if ub.trn-doc.contract-code <> 0 then do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.contract-code = ub.trn-doc.contract-code
          no-error.
          if available buf_contract then do:
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + loc-increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + loc-increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден договор с кодом :"
                    ub.trn-doc.contract-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
        else do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.cli-type      = ub.trn-doc.cli-type
            and buf_contract.cli-code      = ub.trn-doc.cli-code
            and buf_contract.status_       = 'тек':U
            and buf_contract.contract-date-beg   <= ub.trn-doc.doc-date
            and ( buf_contract.contract-date-end >= ub.trn-doc.doc-date
              or buf_contract.contract-date-end   = date('') )
          no-error.
          if available buf_contract then do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + loc-increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + loc-increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден ни один текущий договор для поставщика:"
                    ub.trn-doc.cli-type ub.trn-doc.cli-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
      end.
    end.
    otherwise do:
      message "Не задан способ вычисления цены : " skip
              "Артикул:" buf-price-list.artic buf-goods.gds-name skip
              "in-pr"
              view-as alert-box error.
      g#log = no.
      return error .
    end.
      end case.
         if g-g = false then do:
              define variable loc-rez as character no-undo .
              define variable t-type  as character no-undo .
              run gdsoattr-value (input 'round-method':U,
                                  input buf-goods.gds-code,
                                  input buf-price-list.obj-type,
                                  input buf-price-list.obj-code,
                                  output loc-rez ,
                                  output t-type)  no-error  .
              if error-status :error then message
                    vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    "gdsoattr-value"
                    view-as alert-box error .
              case NUM-ENTRIES (loc-rez," ") :
                  when 0 then do:
                  end.
                  when 1 then do:
                    round-method = loc-rez .
                    round-base   = 0 .
                  end.
                  when 2 then do:
                    round-method = entry(1 , loc-rez, " " ).
                    round-base   = decimal(entry(2 , loc-rez, " " )) .
                  end.
                  otherwise do:
                    round-method = entry(1 , loc-rez, " " ).
                    round-base   = decimal(entry(NUM-ENTRIES (loc-rez," ") , loc-rez, " " )) .
                  end.
              end case.
         end.
    end.
   when 'Накл-безНДС':U  then do:
      if ub.trn-doc.doc-type = 'при':U and
         ( ub.trn-doc.ext-doc-type = 'ie':U  ) then do:
              run str/gdsnovat.p ('Накл-безНДС':U,
                      buf-price-list.obj-type,
                      buf-price-list.obj-code,
                      buf-price-doc.host-code,
                      buf-price-list.artic,
                      buf-price-list.prod-type,
                      buf-price-list.prod-code,
                      increase-pc,
                      doc-code,
                      input p-doc-price-rubl-novat   ,
                      input p-doc-price-base-novat   ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl )
                      .
                      if available ub.doc-line then do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                      else do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                End.
      else do:
          run str/gdsnovat.p ('Накл-безНДС':U + "Other":U ,
              buf-price-list.obj-type,
              buf-price-list.obj-code,
              buf-price-doc.host-code,
              buf-price-list.artic,
              buf-price-list.prod-type,
              buf-price-list.prod-code,
              increase-pc,
              doc-code,
              input p-doc-price-rubl-novat   ,
              input p-doc-price-base-novat   ,
              output cost-base   ,
              output cost-rubl   ,
              output v-price-base  ,
              output v-price-rubl  ,
              output cur-rt-base ,
              output cur-rt-rubl ).
              if available ub.doc-line then do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                  .
              end.
              else do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl             else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl           else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl            else v-price-base
                  .
              end.
          End.
    end.
    when 'НсП':U then do:
      run str/gdsnovat.p ( 'НсП':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          increase-pc,
          "",
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'НсП':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет-безНДС':U then do:
      run str/gdsnovat.p ('Учет-безНДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет-безНДС':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет+накл':U then do:
      run str/gdsnovat.p
         (input 'Учет+накл':U,
          input buf-price-list.obj-type,
          input buf-price-list.obj-code,
          input buf-price-doc.host-code,
          input buf-price-list.artic,
          input buf-price-list.prod-type,
          input buf-price-list.prod-code,
          input increase-pc,
          input doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет+накл':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Уч+накл-НДС':U then do:
      run str/gdsnovat.p ('Уч+накл-НДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl )
          .
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method =  'Уч+накл-НДС':U  + " " + doc-code
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учетная':U then do:
      run trg/gdsavrg.p ('Учетная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
        assign
          buf-price-list.calc-method =  'Учетная':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
    end.
    when 'Учет-объект':U then do:
      run trg/gdsavrg.p ('Учет-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      assign
        buf-price-list.calc-method = 'Учет-объект':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Учет-резерв':U then do:
      run trg/gdsavrg.p
        ('Учет-резерв':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          output cost-base,
          output cost-rubl,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
      assign
        buf-price-list.calc-method = 'Учет-резерв':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Приходная':U then do:
      run trg/gdsavrg.p ('Приходная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))
      then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
        buf-price-list.calc-method = 'Приходная':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Прих-объект':U then do:
      run trg/gdsavrg.p ('Прих-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))   then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Прих-объект':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Производит':U then do:
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output tt-price-prodwihvat
 , output cost-rubl
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Производит':U
          buf-price-list.price-calc  =  cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + increase-pc / 100)
          tt-price-sale   =  cost-rubl * (1 + increase-pc / 100)
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'ПорогПр-НДС':U then do:
          run calc-price-levelprod (
            input 2            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl ,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр-НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
          tt-price-sale   =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
      end.
    end.
    when 'ПорогПр+НДС':U then do:
          run calc-price-levelprod (
            input 1            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр+НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl  .
          tt-price-sale   =  cost-rubl  .
      end.
    end.
    when 'Произв-НДС':U then do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output cost-rubl
 , output tt-price-prodwihvat
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Произв-НДС':U
          buf-price-list.price-calc  = cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          tt-price-sale   =  cost-rubl * (1 + increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'Новая':U then
      if buf-price-list.price-sale = ? then
        message "Неизвестна новая цена для товара :"
                buf-price-list.artic buf-goods.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Новая':U
          buf-price-list.price-calc = buf-price-list.price-sale
          buf-price-list.price-sale = buf-price-list.price-sale * (1 + increase-pc / 100)
          tt-price-sale = buf-price-list.price-sale * (1 + increase-pc / 100)
          .
    when 'Накладная':U then do:
        run str/pr-wbil.p
        ( input "in-pr"              ,
          input 'Накладная':U   ,
          input recid(ub.trn-doc)     ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code           ,
          input buf-goods.gds-name       ,
          input buf-goods.gds-code       ,
          input buf-price-list.artic          ,
          input buf-price-list.prod-type      ,
          input buf-price-list.prod-code      ,
          input buf-bar-code.node-code      ,
          input increase-pc                ,
          input p-doc-price-rubl   ,
          input p-doc-price-base   ,
          output v-price-base      ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then do:
          assign
            buf-price-list.calc-method = 'Накладная':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
      end.
      else do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "444"
           view-as alert-box error
         .
      end.
    end.
    when 'НсП+накл':U then do:
        run str/pr-wbil.p
        ( input "in-pr"                ,
          input 'НсП+накл':U ,
          input recid(ub.trn-doc)       ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code             ,
          input buf-goods.gds-name         ,
          input buf-goods.gds-code         ,
          input buf-price-list.artic            ,
          input buf-price-list.prod-type        ,
          input buf-price-list.prod-code        ,
          input buf-bar-code.node-code        ,
          input 0                    ,
          input p-doc-price-rubl     ,
          input p-doc-price-base     ,
          output v-price-base        ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then
          assign
            buf-price-list.calc-method = 'НсП+накл':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
    end.
    when 'Отсутствует':U then do:
      if buf-price-list.price-sale = ? then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-list.obj-type
  ,input  buf-price-list.obj-code
  ,input  buf-price-list.b-code
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
        if cur-pr <> ? then
          assign
            buf-price-list.calc-method = 'Отсутствует':U
            buf-price-list.price-calc  = cur-pr
            buf-price-list.price-sale  = cur-pr
            tt-price-sale   = cur-pr
            buf-price-list.road-tax    = cur-rt
            buf-price-list.excise      = cur-ex
            .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Не-считать':U then do:
      if buf-price-list.price-sale = ? then do:
        assign
          buf-price-list.calc-method = 'Не-считать':U
          buf-price-list.price-calc = ?
          .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Спецификация':U then do:
      if available ub.trn-doc
      then do:
        if ub.trn-doc.contract-code <> 0 then do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.contract-code = ub.trn-doc.contract-code
          no-error.
          if available buf_contract then do:
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден договор с кодом :"
                    ub.trn-doc.contract-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
        else do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.cli-type      = ub.trn-doc.cli-type
            and buf_contract.cli-code      = ub.trn-doc.cli-code
            and buf_contract.status_       = 'тек':U
            and buf_contract.contract-date-beg   <= ub.trn-doc.doc-date
            and ( buf_contract.contract-date-end >= ub.trn-doc.doc-date
              or buf_contract.contract-date-end   = date('') )
          no-error.
          if available buf_contract then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден ни один текущий договор для поставщика:"
                    ub.trn-doc.cli-type ub.trn-doc.cli-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
      end.
    end.
    otherwise do:
      message "Не задан способ вычисления цены : " skip
              "Артикул:" buf-price-list.artic buf-goods.gds-name skip
              "in-pr"
              view-as alert-box error.
      g#log = no.
      return error .
    end.
  end case.
  run create-price-list-attr
  ( 'full-price-sale':U ,
     tt-price-sale      ,
     buf-price-list.b-code ,
     buf-price-list.doc-num ,
     buf-price-list.price-type  ).
run main-road-tax
  ( input buf-price-list.obj-type ,
    input buf-price-list.obj-code ,
    input buf-price-list.artic    ,
    input buf-price-list.prod-type,
    input buf-price-list.prod-code,
    input-output cur-rt-base,
    input-output cur-rt-rubl )
    .
    if var-pr-r-b = "rubl" then do:
        if ( cur-rt-rubl <> ? )   then
          assign
            buf-price-list.road-tax  = cur-rt-rubl
            .
            else
                assign
                  buf-price-list.road-tax  = 0
                  .
   end.
   else do:
        if ( cur-rt-base <> ? )   then
          assign
            buf-price-list.road-tax  = cur-rt-base
            .
            else
                assign
                  buf-price-list.road-tax  = 0
                  .
   end.
case round-method :
  when '9-окончание':U then do:
    if buf-price-list.price-sale < 29 then do:
      if (buf-price-list.price-sale - truncate (buf-price-list.price-sale, 0)) <> 0 then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 1
        .
      end.
    end.
    else do:
      if (buf-price-list.price-sale modulo 10) < 3 then do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if buf-price-list.price-sale < round-base then do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 0.99
      .
    end.
    else do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
    .
  end.
  when 'Произвольно':U then do:
    if round-base <> 0 then do:
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale / round-base, 0) * round-base
      .
      if buf-price-list.price-sale = 0 then do:
        assign
          buf-price-list.price-sale = round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if round-base <> 0 then do:
      if truncate ( buf-price-list.price-sale / round-base, 0 ) <> (buf-price-list.price-sale / round-base) then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale / round-base, 0) * round-base + round-base
        .
      end.
    end.
    if buf-price-list.price-sale = 0 then do:
      assign
        buf-price-list.price-sale = round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if round-base <> 0 then do:
      assign
        buf-price-list.price-sale = buf-price-list.price-sale * round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" round-method skip
      "round-base"   round-base   skip
      "price"        buf-price-list.price-sale             skip
      view-as alert-box error .
  end.
end.
  calc-rec = recid (buf-price-list).
  run calc-pr-sub (input  buf-bar-code.b-code,
                   input  buf-price-list.doc-num,
                   input  calc-method,
                   input  increase-pc,
                   input  round-method,
                   input  round-base,
                   output calc-rec) no-error.
  if error-status :error then
    undo calc-pr, return error.
    old-price-sale = buf-price-list.price-sale .
   if line-mode = "calc":u then do:
        run calc-sigma (input buf-price-list.b-code,
                        input-output buf-price-list.price-sale,
                        input buf-price-doc.host-code,
                        input buf-price-doc.obj-code,
                        input buf-price-doc.obj-type,
                        output loc-ret).
        if loc-ret = false then
          message "Цена товара :" SKIP
          "артикул :" buf-price-list.artic buf-price-list.prod-type buf-price-list.prod-code skip
          "бар-код :" buf-price-list.b-code skip
            "не изменилась из-за заданного максимально допустимого отклонения! " skip
            " Рассчитанная цена "  old-price-sale skip
            " Действующая цена "   buf-price-list.price-sale
            view-as alert-box .
   end.
end.
END PROCEDURE.
procedure calc-sigma :
 do
 on error undo, return error return-value
 :
define input parameter l-bcode like ub.price-list.b-code no-undo .
define input-output parameter new-price as decimal no-undo .
define input parameter l-host as integer no-undo .
define input parameter l-code as integer no-undo .
define input parameter l-type as character no-undo .
define output parameter p-ret as logical no-undo .
define variable conf-par     as character no-undo.
define variable par-type     as character no-undo.
define variable i-sigma as decimal no-undo .
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable old-price as decimal no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
p-ret = true  .
if par-pr-sigma <> ? and par-pr-sigma <> "" and par-pr-sigma <> "0" then do:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  l-type
  ,input  l-code
  ,input  l-bcode
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
old-price = cur-pr .
if old-price =  new-price then do:
   p-ret = true .
   return.
end.
   i-sigma = decimal(par-pr-sigma) .
   if ( 100 * ABSOLUTE( old-price - new-price ) / old-price ) <= i-sigma then do:
       assign
         p-ret = false
         new-price = old-price
       .
       end.
   else p-ret = true .
  end.
 end.
end procedure.
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE VER-PR-EQU-DQ :
define input parameter  l-doc-num    like ub.price-list.doc-num    no-undo .
define input parameter  l-num       as integer no-undo .
define input parameter  l-b-code    as integer   no-undo .
define variable  l-doc-num2    like ub.price-list.doc-num    no-undo .
define buffer l-price-list  for ub.price-list .
define buffer pp_price-list for ub.price-list .
define buffer p2_price-list for ub.price-list .
define buffer main_price-list for ub.price-list .
define buffer alt_price-list  for ub.price-list .
define buffer buf1-bar-code for ub.bar-code .
define buffer buf2-bar-code for ub.bar-code .
define variable v-num as integer init 0 no-undo .
define variable bbb as logical no-undo .
define variable  l-price-sale like ub.price-list.price-sale no-undo .
define variable  l-road-tax   like ub.price-list.road-tax   no-undo .
define variable  l-excise     like ub.price-list.excise     no-undo .
define variable  l-ok         as logical no-undo .
define variable  check-par    as logical no-undo .
for each l-price-list where l-price-list.doc-num = l-doc-num     and
                            l-price-list.main-price = true
                            exclusive-lock  :
  find first ub.goods where ub.goods.artic    = l-price-list.artic and
                        ub.goods.prod-type = l-price-list.prod-type and
                        ub.goods.prod-code = l-price-list.prod-code no-lock   .
      check-par = false .
      if l-num = 2 then do:
        find first buf2-bar-code where buf2-bar-code.b-code = l-b-code no-lock no-error .
        if ub.goods.gds-code <> buf2-bar-code.gds-code then next.
      end.
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  l-price-list.obj-type
  ,input  l-price-list.obj-code
  ,input  l-price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
      if l-doc-num2 <> ? then do :
        if l-price-sale = l-price-list.price-sale
        then do:
          if par-pr-equ-dq >= 2 then do:
            check-par = false .
               for each pp_price-list no-lock where pp_price-list.doc-num = l-doc-num   and
                  pp_price-list.artic       =  l-price-list.artic      and
                  pp_price-list.prod-type   =  l-price-list.prod-type  and
                  pp_price-list.prod-code   =  l-price-list.prod-code  and
                  pp_price-list.main-price  =  no  :
                    check-par = true  .
                    leave.
                end.
            if  check-par = true then NEXT .
            if par-pr-equ-dq = 2 then do:
              if  ( v-num <= 2  and check-par = false ) then
              run gbl/d-askw.w
                (input "Удалить строку?"
                ,input      "Предыдущая цена РАВНА цене по закрываемому документу " + chr(10)
                            + " Объект "  + l-price-list.obj-type + " " + String(l-price-list.obj-code) + chr(10)
                            + " Артикул " + l-price-list.artic    + " " +  ub.goods.gds-name + chr(10)
                            + " Бар-код " + string(l-price-list.b-code)
                            + " Цена по предыдущему документу № " + l-doc-num + " "
                            + string(l-price-sale) + chr(10)
                            + string(l-price-list.price-sale)
                            + " Удалить строку? "
                ,input "|^"
                ,input "Да|Нет|Да для всех^confirm|Нет для всех^confirm"
                ,input "Удалить строку|"
                    + "Не удалять строку|"
                    + "Удалять у всех товаров, цена на которые не изменилась|"
                    + "Не удалять у всех товаров, цена на которые не изменилась"
                ,input 1
                ,input 2
                ,output v-num
                ).
              end.
              else do:
                v-num = 3 .
              end.
                if v-num = 1 then do:
                  run del-pr-list (input l-price-list.b-code,
                                  input l-price-list.doc-num,
                                  input ?,
                                  input ?) no-error.
                                  if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          "Ошибка при удаление строки переоценки "
                                          l-price-list.b-code skip
                                          error-status :get-message(1) .
                                          return error.
                                  end.
                end.
                if v-num = 3  then do:
                   run del-pr-list (input l-price-list.b-code,
                                    input l-price-list.doc-num,
                                    input ?,
                                    input ?)
                                    no-error.
                end.
          end.
        end.
       end.
end.
  if par-pr-equ-dq >= 2 then do:
     for each main_price-list no-lock where
              main_price-list.doc-num         = l-doc-num   and
              main_price-list.main-price      = true ,
        first ub.goods where ub.goods.artic   = main_price-list.artic and
                        ub.goods.prod-type = main_price-list.prod-type and
                        ub.goods.prod-code = main_price-list.prod-code no-lock   :
             if l-num = 2 then do:
                find first buf2-bar-code where buf2-bar-code.b-code = l-b-code no-lock no-error .
                if ub.goods.gds-code <> buf2-bar-code.gds-code then next.
             end.
                for each pp_price-list no-lock where
                  pp_price-list.doc-num         = main_price-list.doc-num    and
                  pp_price-list.artic           = main_price-list.artic      and
                  pp_price-list.prod-type       = main_price-list.prod-type  and
                  pp_price-list.prod-code       = main_price-list.prod-code  and
                  pp_price-list.main-price      = no and
                  pp_price-list.price-sale      = main_price-list.price-sale  ,
                    first buf1-bar-code no-lock where
                      buf1-bar-code.b-code    = pp_price-list.b-code and
                      buf1-bar-code.unit-cli  = ub.goods.unit-base break by buf1-bar-code.b-code :
                          if first-of( buf1-bar-code.b-code ) then do:
                          bbb = false.
                                   for each alt_price-list where
                                          pp_price-list.doc-num         = alt_price-list.doc-num    and
                                          pp_price-list.artic           = alt_price-list.artic      and
                                          pp_price-list.prod-type       = alt_price-list.prod-type  and
                                          pp_price-list.prod-code       = alt_price-list.prod-code  and
                                          pp_price-list.main-price      = no  no-lock :
                                        if pp_price-list.b-code   =  fnc-base-code (alt_price-list.b-code) and
                                          alt_price-list.b-code = pp_price-list.b-code then next.
                                          if fnc-base-code (alt_price-list.b-code) = pp_price-list.b-code
                                          then do:
                                                bbb = true .
                                                leave.
                                           end.
                                   end.
                                    if bbb = false then do:
                                        run del-pr-list ( input pp_price-list.b-code  ,
                                                          input pp_price-list.doc-num ,
                                                          input ? ,
                                                          input ? ) no-error.
                                        if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          " Нельзя удалить " pp_price-list.b-code skip
                                          error-status :get-message(1) .
                                          end.
                                    end.
                          end.
                end.
     end.
 end.
end procedure.
define variable v1-b-code as integer   no-undo .
define variable new-rec as recid no-undo .
define variable v-msg as character no-undo .
define buffer n1_price-list for ub.price-list  .
do
on error undo, return error return-value
:
  find ub.trn-doc where recid (ub.trn-doc) = p-doc-rec no-lock.
  if  ub.trn-doc.doc-type <> 'при':U   then do:
    return.
  end.
  run get-db-num in parparentproc ( output v-cntxt-db-num).
  run get-userid in parparentproc ( output v-cntxt-userid).
  assign
  v-cntxt-obj-type = ub.trn-doc.obj-type
  v-cntxt-obj-code = ub.trn-doc.obj-code
  v-cntxt-host-code-obj = ub.trn-doc.host-code
  v-cntxt-level = 'object':U
  .
  assign
  v-cntxp-db-num = v-cntxt-db-num
  v-cntxp-userid = v-cntxt-userid
  v-cntxp-curr-host-code = v-cntxt-host-code-obj
  v-cntxp-level = v-cntxt-level
  v-cntxp-obj-type = v-cntxt-obj-type
  v-cntxp-obj-code = v-cntxt-obj-code
  .
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
 define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  ub.trn-doc.host-code
        ,input  ub.trn-doc.obj-type
        ,input  ub.trn-doc.obj-code
      ) no-error .
          if error-status :error then do:
              v-msg = vss-workfile + " " + vss-revision  + " " + vss-description + "~n" +
                      error-status :get-message(1) + "~n" +
                      return-value + "~n" +
                      "chec-par"
                      .
              if not g#news and
                 not g#auto and
                 not g#esys
              then
                 message v-msg view-as alert-box error.
          end.
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partmrgn in g#library2
  (input  parparentproc
  ,input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output par-gen-mrgn-ie-parts
  ,output par-gen-mrgn-iv-parts
  ,output par-gen-mrgn-im-parts
  ) no-error .
   if error-status :error then do:
      run waitfram-hide in this-procedure no-error.
      return error substitute( 'На объекте &1 &2  не определен ГТПЛ для автопереоценок.'
                                ,ub.trn-doc.obj-type
                                ,ub.trn-doc.obj-code
                              ).
   end.
    is-after-margin-parts = false .
    if  par-gen-mrgn-ie-parts = 'after-margin':U or
        par-gen-mrgn-iv-parts = 'after-margin':U or
        par-gen-mrgn-im-parts = 'after-margin':U then do:
        is-after-margin-parts = true .
    end.
if ( gen-mode = "cost-price" or
     gen-mode = "before-margin"  ) and  ub.trn-doc.is-back-date = true  then do:
  return.
end.
if not ( par-pr-parex = "yes" and
         par-pr-notls = "yes" ) and
         gen-mode = "after-margin-parts" then do:
         return .
 end.
  run waitfram-show in this-procedure ( "Расчет продажной цены... " ) .
  if gen-mode = "before-internal" then gen-mode = "before-margin" .
  cre-pr:
  do on error undo cre-pr, return error:
    gds-dtl:
    for each ub.gds-dtl where
        ub.gds-dtl.doc-code = ub.trn-doc.doc-code ,
       first ub.doc-line no-lock where
                ub.doc-line.doc-code  = ub.gds-dtl.doc-code and
                ub.doc-line.artic     = ub.gds-dtl.artic and
                ub.doc-line.prod-type = ub.gds-dtl.prod-type and
                ub.doc-line.prod-code = ub.gds-dtl.prod-code ,
      first ub.goods no-lock where
                ub.goods.artic     = ub.gds-dtl.artic and
                ub.goods.prod-type = ub.gds-dtl.prod-type and
                ub.goods.prod-code = ub.gds-dtl.prod-code
        by ub.doc-line.line-num
        on error undo cre-pr, return error:
        run ver-modificator-price-is-null (
            input    ub.goods.artic        ,
            input    ub.goods.prod-type    ,
            input    ub.goods.prod-code    ,
            input    ub.trn-doc.obj-type   ,
            input    ub.trn-doc.obj-code   ,
            output   v-ret ).
        if v-ret = false then next.
      if ub.gds-dtl.fact-qnty = 0 then do:
        next gds-dtl.
      end.
      find ub.units where
          ub.units.unit-name = ub.goods.unit-base no-lock.
      if lookup ('топ':U, ub.units.type) <> 0 then do:
        next gds-dtl.
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output v-root-b-code
  )  .
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  gds-dtl.obj-type
  ,input  gds-dtl.obj-code
  ,input  v-root-b-code
  ,input  0
  ,input  0
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
      if gen-mode = "before-margin" or
         gen-mode = "after-margin"  then do:
          for each ub.price-list where
                   ub.price-list.doc-num    = gp-doc-num and
                   ub.price-list.artic      = ub.goods.artic and
                   ub.price-list.prod-type  = ub.goods.prod-type and
                   ub.price-list.prod-code  = ub.goods.prod-code and
                   ub.price-list.main-price = no ,
              first ub.bar-code no-lock where
                    ub.bar-code.b-code = ub.price-list.b-code and
                    ub.bar-code.unit-cli = ub.goods.unit-base
          :
              next gds-dtl   .
          end.
         if is-after-margin-parts = true and
            gen-mode = "after-margin"   then do:
            find first ub.gds-obj no-lock where
                  ub.gds-obj.gds-code = ub.goods.gds-code and
                  ub.gds-obj.obj-type = ub.trn-doc.obj-type and
                  ub.gds-obj.obj-code = ub.trn-doc.obj-code and
                  ub.gds-obj.cash-parts = true
            no-error .
            if available ub.gds-obj then
               next gds-dtl.
           end.
        end.
      if  gen-mode = "after-margin-parts"  then do:
         find first ub.gds-obj no-lock where
              ub.gds-obj.gds-code = ub.goods.gds-code and
              ub.gds-obj.obj-type = ub.trn-doc.obj-type and
              ub.gds-obj.obj-code = ub.trn-doc.obj-code and
              ub.gds-obj.cash-parts = false  no-error .
            if available ub.gds-obj then
               next gds-dtl.
          for each ub.price-list where
                   ub.price-list.doc-num    = gp-doc-num and
                   ub.price-list.artic      = ub.goods.artic and
                   ub.price-list.prod-type  = ub.goods.prod-type and
                   ub.price-list.prod-code  = ub.goods.prod-code and
                   ub.price-list.main-price = no ,
              first ub.bar-code no-lock where
                    ub.bar-code.b-code = ub.price-list.b-code and
                    ub.bar-code.in-code  = "" and
                    ub.bar-code.unit-cli = ub.goods.unit-base
          :
              next gds-dtl   .
          end.
      end.
      if gen-mode = "cost-price" then do:
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ub.gds-dtl.prt-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.gds-dtl.obj-type
  ,input  ub.gds-dtl.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  ub.gds-dtl.obj-type
  ,input  ub.gds-dtl.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
        if v-cntxp-no-eq  and
          gp-price-sale = ? then do:
          v-msg = "Артикул: " + ub.goods.artic + "~n" +
                  "Производитель: " + ub.goods.prod-type + " " + string(ub.goods.prod-code) + "~n" +
                  ub.goods.gds-name + "~n" +
                  "Продажная цена отсутствует." + "~n" + "~n" +
                  "Для " + v-cntxt-obj-type + " " + string(v-cntxt-obj-code) + " запрещено закрывать такой приход." + "~n" +
                  "Сделайте переоценку по этой накладной.".
          if not g#news and
             not g#auto and
             not g#esys
          then
             message v-msg view-as alert-box error.
          undo cre-pr, return error v-msg.
        end.
        find ub.prt-obj where
            ub.prt-obj.obj-type  = ub.gds-dtl.obj-type and
            ub.prt-obj.obj-code  = ub.gds-dtl.obj-code and
            ub.prt-obj.prod-type = ub.gds-dtl.prod-type and
            ub.prt-obj.prod-code = ub.gds-dtl.prod-code and
            ub.prt-obj.artic     = ub.gds-dtl.artic and
            ub.prt-obj.prt-code  = ub.gds-dtl.prt-code no-error.
        if
          ( var-pr-r-b = "rubl" and ub.gds-dtl.price-rubl = gp-price-sale ) or
          ( var-pr-r-b = "base" and ub.gds-dtl.price-base = gp-price-sale )
        then do:
          next .
        end.
        if available ub.prt-obj and
          ub.prt-obj.fact-qnty <> 0 or
          gp-price-sale <> ? then do:
          if v-cntxp-price-calc then do:
            if gp-price-sale <> ? then do:
              v-msg = "Артикул: " + ub.goods.artic + "~n" +
                      "Производитель: " + ub.goods.prod-type + " " + string(ub.goods.prod-code) + "~n" +
                      ub.goods.gds-name + "~n" +
                      "Приходная цена отличается от продажной." + "~n" + "~n" +
                      "Для " + v-cntxt-obj-type + " " + string(v-cntxt-obj-code) + " запрещено закрывать такой приход." + "~n" +
                      "Сделайте переоценку по этой накладной.".
              if not g#news and
                 not g#auto and
                 not g#esys
              then
                 message v-msg view-as alert-box error.
            end.
            else do:
              v-msg = "Артикул: " + ub.goods.artic + "~n" +
                      "Производитель: " + ub.goods.prod-type + " " + string(ub.goods.prod-code) + "~n" +
                      ub.goods.gds-name + "~n" +
                      "Продажная цена отсутствует, но остаток ненулевой." + "~n" + "~n" +
                      "Для " + v-cntxt-obj-type + " " + string(v-cntxt-obj-code) + " запрещено закрывать приход, " +
                      "если приходные цены отличаются от продажных." + "~n" +
                      "Сделайте переоценку по этой накладной.".
              if not g#news and
                 not g#auto and
                 not g#esys
              then
                 message v-msg view-as alert-box error.
            end.
            undo cre-pr, return error v-msg.
          end.
          next .
        end.
      end.
      if not available ub.price-doc then do:
        run find-main-plt in this-procedure
            (input v-cntxt-obj-type
            ,input v-cntxt-obj-code
            ,output v-plt-id
            ,output v-plt-db-num
            ,output v-round-method
            ,output v-round-base) no-error .
          if error-status :error then   do:
            undo cre-pr, return error "Ошибка поиска ГТПЛ".
          end.
          run create_new_price-doc-forming (
                input   v-cntxt-obj-type
              , input   v-cntxt-obj-code
              , output  v-pdf-db-num
              , output  v-pdf-id
              , output  v-plt-db-num
              , output  v-plt-id     ) no-error .
        find first  ub.price-doc-forming exclusive-lock where
                    ub.price-doc-forming.plt-id       = v-plt-id       and
                    ub.price-doc-forming.plt-db-num   = v-plt-db-num   and
                    ub.price-doc-forming.pdf-id       = v-pdf-id       and
                    ub.price-doc-forming.pdf-db       = v-pdf-db-num   no-error .
          if error-status :error then   do:
            undo cre-pr, return error "Ошибка создания ДНЦ " + error-status :get-message(1) .
          end.
        assign
            ub.price-doc-forming.out-code     = ub.trn-doc.doc-code
       .
        create ub.price-doc .
        define variable l-d-n   like ub.price-doc.doc-num no-undo .
        run doc-code in this-procedure
         ( input "main",
           input v-cntxt-obj-type,
           input v-cntxt-obj-code,
           input ?,
           output ub.price-doc.doc-num )
           no-error.
          l-d-n = ub.price-doc.doc-num.
        if error-status:error then do:
          v-msg = "Ошибка при генерации номера документа" + "~n" +
                  return-value.
          if not g#news and
             not g#auto and
             not g#esys
          then
             message v-msg view-as alert-box error.
          undo cre-pr, return error v-msg.
        end.
        assign
          ub.price-doc.plt-id     = v-plt-id
          ub.price-doc.plt-db-num = v-plt-db-num
          ub.price-doc.pdf-id     = v-pdf-id
          ub.price-doc.pdf-db     = v-pdf-db-num
          ub.price-doc.doc-date   = ub.trn-doc.doc-date
          ub.price-doc.fact-num   = 0
          ub.price-doc.host-code  = v-cntxt-host-code-obj
          ub.price-doc.cr-db-num  = v-cntxt-db-num
          ub.price-doc.obj-code   = ub.trn-doc.obj-code
          ub.price-doc.obj-type   = ub.trn-doc.obj-type
          ub.price-doc.rest-base  = 0
          ub.price-doc.rest-last  = 0
          ub.price-doc.rest-qnty  = ?
          ub.price-doc.rest-sale  = 0
          ub.price-doc.sale-base  = 0
          ub.price-doc.out-code   = ub.trn-doc.doc-code
          l-d-n                   = ub.price-doc.doc-num
          .
        case gen-mode :
          when "cost-price" then do:
            ub.price-doc.PS = "Цены продажи новых товаров по ПН № " + ub.trn-doc.doc-code + " устанавливаются = приходным.".
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input ub.price-doc.doc-num ,
                       input 'first-price':U ,
                       input 'yes' )  .
            run  pdoc-forming-attr (
                 ub.price-doc.plt-id     ,
                 ub.price-doc.plt-db-num ,
                 ub.price-doc.pdf-id     ,
                 ub.price-doc.pdf-db     ,
                 'first-price':U ,
                 'yes' ) .
          end.
          when "after-margin" then do:
            ub.price-doc.PS = "@  Стандартная торговая наценка подготовлена для ПН № " + ub.trn-doc.doc-code.
          end.
          when "after-margin-parts" then do:
            ub.price-doc.PS = "По партиям , подготовлена для ПН № " + ub.trn-doc.doc-code.
          end.
          when "before-margin" then do:
            ub.price-doc.PS = "Принудительная стандартная торговая наценка закрыта до ПН № " + ub.trn-doc.doc-code.
          end.
        end case .
      end.
      run cre-pr-list ( input  v-root-b-code,
                        input  ub.price-doc.doc-num,
                        output pr-list-rec)
                        no-error .
      if error-status :error then do:
        undo cre-pr, return error.
      end.
      find first ub.price-list where
                 ub.price-list.doc-num    = ub.price-doc.doc-num and
                 ub.price-list.price-type = "" and
                 ub.price-list.b-code     = v-root-b-code
                 no-error .
      if error-status :error then do:
        undo cre-pr, return error substitute(" Не найдена запись в переоценке № &1 по бар-коду &2" ,price-doc.doc-num ,v-root-b-code ).
        end.
      find first b1-doc-line where
                b1-doc-line.doc-code   = ub.trn-doc.doc-code   and
                b1-doc-line.artic      = ub.price-list.artic     and
                b1-doc-line.prod-type  = ub.price-list.prod-type and
                b1-doc-line.prod-code  = ub.price-list.prod-code no-lock no-error .
      ub.price-list.road-tax   = if avail b1-doc-line then  b1-doc-line.road-tax  else ? .
      Assign
        p-flag  = false
        p-new-road-tax = ub.price-list.road-tax
        .
      run compare_road-tax
                        ( input-output p-new-road-tax ,
                          input ub.price-list.b-code     ,
                          input ub.price-list.obj-type   ,
                          input ub.price-list.obj-code   ,
                          input no ) .
      if p-new-road-tax <> ub.price-list.road-tax Then do:
        p-flag = true .
      End.
      doc-code = ub.trn-doc.doc-code.
      case gen-mode :
        when "cost-price" then do:
          assign
            ub.price-list.doc-qnty   = 0
            ub.price-list.fact-order = 0
            ub.price-list.price-sale = if var-pr-r-b = "rubl" then gds-dtl.price-rubl else gds-dtl.price-base
            .
        end.
        when "after-margin-parts"  then do:
         find first ub.gds-obj no-lock where
                    ub.gds-obj.gds-code = ub.goods.gds-code and
                    ub.gds-obj.obj-type = ub.price-doc.obj-type and
                    ub.gds-obj.obj-code = ub.price-doc.obj-code and
                    ub.gds-obj.cash-parts = true no-error .
          if available ub.gds-obj then do:
          v-parts = true .
          line-mode = "calc":u.
          par-pr-nakl = false .
          if ub.trn-doc.ext-doc-type = 'ie':U then par-pr-nakl = par-pr-nakl-ie .
          if ub.trn-doc.ext-doc-type = 'iv':U then par-pr-nakl = par-pr-nakl-iv .
          if ub.trn-doc.ext-doc-type = 'im':U  then par-pr-nakl = par-pr-nakl-im .
              if par-pr-parex = "yes" and
                 par-pr-notls = "yes" then do:
                  run calc-pr-list
                    ( input v-root-b-code,
                      input ub.price-doc.doc-num,
                      input 'Отсутствует':U,
                      input ?,
                      input v-round-method,
                      input v-round-base,
                      input ?,
                      input ?,
                      input ?,
                      input ?,
                      output calc-rec
                    ) no-error.
              end.
              if var-pr-r-b = "rubl"
                  then  ub.price-list.price-sale = b1-doc-line.price-rubl.
                  else  ub.price-list.price-sale = b1-doc-line.price-base.
              for each ub.parts no-lock where
                       ub.parts.out-code  = b1-doc-line.doc-code and
                       ub.parts.artic     = b1-doc-line.artic and
                       ub.parts.prod-code = b1-doc-line.prod-code and
                       ub.parts.prod-type = b1-doc-line.prod-type :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer ub.parts
  ,output v1-b-code
  )  .
                  run cre-pr-list
                      ( input  v1-b-code,
                        input  ub.price-doc.doc-num ,
                        output new-rec) no-error.
                  if ub.trn-doc.ext-doc-type = 'iv':U  then do:
                  run gds-attr-margin-value
                  ( input   ub.gds-obj.gds-code ,
                    input   v-cntxt-obj-type   ,
                    input   v-cntxt-obj-code ,
                    output  p-prc-min            ,
                    output  p-prc-max            ,
                    output  loc-grp-increase-pc  ,
                    output  loc-grp-round-method ,
                    output  loc-grp-round-base   ,
                    output  p-value-margin       ,
                    output  p-type-margin        ,
                    output  p-value-increase     ,
                    output  p-type-increase      ,
                    output  p-value-rmethod      ,
                    output  p-type-rmethod
                    ) no-error .
                  find first n1_price-list exclusive-lock where
                             n1_price-list.doc-num    = ub.price-doc.doc-num and
                             n1_price-list.price-type = "" and
                             n1_price-list.b-code     = v1-b-code no-error .
                      if available n1_price-list then do:
                          run lineattr-value-parts (
                               input b1-doc-line.doc-code
                              ,input ub.gds-obj.gds-code
                              ,input ub.parts.part-code
                              ,input ub.parts.in-code
                              ,input 'parts_price-sale':U
                              ,output n1_price-list.price-sale ) no-error .
                          run ggoattr-value (
                             input   goods.grp-code
                            ,input   v-cntxt-host-code-obj
                            ,input   ub.price-list.obj-type
                            ,input   ub.price-list.obj-code
                            ,input   'marg-pr-paraf':U
                            ,output  attr-marg-pr-paraf
                            ,output  v-type ) no-error .
                          if n1_price-list.price-sale = 0 or n1_price-list.price-sale = ? then do:
                             n1_price-list.price-sale = ub.gds-obj.price-sale .
                          end.
                          if attr-marg-pr-paraf = ? or attr-marg-pr-paraf = "" then attr-marg-pr-paraf = "0" .
                          n1_price-list.price-sale = n1_price-list.price-sale * ( 1 + decimal (attr-marg-pr-paraf) / 100 ).
case loc-grp-round-method :
  when '9-окончание':U then do:
    if n1_price-list.price-sale < 29 then do:
      if (n1_price-list.price-sale - truncate (n1_price-list.price-sale, 0)) <> 0 then do:
        assign
          n1_price-list.price-sale = truncate (n1_price-list.price-sale, 0) + 1
        .
      end.
    end.
    else do:
      if (n1_price-list.price-sale modulo 10) < 3 then do:
        assign
          n1_price-list.price-sale = (n1_price-list.price-sale - (n1_price-list.price-sale modulo 100))
              + ( truncate (((n1_price-list.price-sale modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          n1_price-list.price-sale = (n1_price-list.price-sale - (n1_price-list.price-sale modulo 100))
              + ( truncate (((n1_price-list.price-sale modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        n1_price-list.price-sale = round (n1_price-list.price-sale, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if n1_price-list.price-sale < loc-grp-round-base then do:
      assign
        n1_price-list.price-sale = truncate (n1_price-list.price-sale, 0) + 0.99
      .
    end.
    else do:
      assign
        n1_price-list.price-sale = truncate (n1_price-list.price-sale / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      n1_price-list.price-sale = round (n1_price-list.price-sale, 0)
    .
  end.
  when 'Произвольно':U then do:
    if loc-grp-round-base <> 0 then do:
      assign
        n1_price-list.price-sale = round (n1_price-list.price-sale / loc-grp-round-base, 0) * loc-grp-round-base
      .
      if n1_price-list.price-sale = 0 then do:
        assign
          n1_price-list.price-sale = loc-grp-round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if loc-grp-round-base <> 0 then do:
      if truncate ( n1_price-list.price-sale / loc-grp-round-base, 0 ) <> (n1_price-list.price-sale / loc-grp-round-base) then do:
        assign
          n1_price-list.price-sale = truncate (n1_price-list.price-sale / loc-grp-round-base, 0) * loc-grp-round-base + loc-grp-round-base
        .
      end.
    end.
    if n1_price-list.price-sale = 0 then do:
      assign
        n1_price-list.price-sale = loc-grp-round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if loc-grp-round-base <> 0 then do:
      assign
        n1_price-list.price-sale = n1_price-list.price-sale * loc-grp-round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" loc-grp-round-method skip
      "round-base"   loc-grp-round-base   skip
      "price"        n1_price-list.price-sale             skip
      view-as alert-box error .
  end.
end.
                          ub.price-list.price-sale = n1_price-list.price-sale .
                      end.
                   end.
                   else do:
                        run calc-pr-list
                          ( input v1-b-code,
                            input ub.price-doc.doc-num,
                            input 'Товар':U,
                            input ?,
                            input v-round-method,
                            input v-round-base,
                            input ?,
                            input ?,
                            input ?,
                            input ?,
                            output calc-rec
                          )
                          no-error.
                          find first ub.price-list no-lock where recid( ub.price-list) =  calc-rec no-error .
                          if available ub.price-list then do:
                              assign
                               v-last-price-sale  = ub.price-list.price-sale
                               v-last-calc-method = ub.price-list.calc-method
                              .
                          end.
                   end.
              end.
             find first ub.price-list exclusive-lock where
                        ub.price-list.doc-num   = ub.price-doc.doc-num  and
                        ub.price-list.main-price = true   and
                        ub.price-list.artic     = b1-doc-line.artic     and
                        ub.price-list.prod-code = b1-doc-line.prod-code and
                        ub.price-list.prod-type = b1-doc-line.prod-type no-error .
             if available ub.price-list then do:
                assign
                  ub.price-list.price-sale  = v-last-price-sale
                  ub.price-list.calc-method = v-last-calc-method
                .
             end.
          end.
        end.
        when "after-margin"  or
        when "before-margin" then do:
          define variable p-line-mode as character no-undo .
          p-line-mode = line-mode .
          line-mode = "calc":u.
          par-pr-nakl = false .
          if ub.trn-doc.ext-doc-type = 'ie':U then par-pr-nakl = par-pr-nakl-ie .
          if ub.trn-doc.ext-doc-type = 'iv':U then par-pr-nakl = par-pr-nakl-iv .
          if ub.trn-doc.ext-doc-type = 'im':U  then par-pr-nakl = par-pr-nakl-im .
          if    b1-doc-line.new-price-sale > 0
            and b1-doc-line.new-price-sale <> ?
            and par-pr-nakl = yes
            and ub.trn-doc.ext-doc-type <> 'iv':U
          then do:
              run calc-npricesale-doc-line
                ( input v-root-b-code,
                  input ub.price-doc.doc-num,
                  input b1-doc-line.doc-code ,
                  input b1-doc-line.new-price-sale ,
                  output calc-rec
                )
                no-error.
          end.
          else if gds-dtl.new-price-sale > 0
              and gds-dtl.new-price-sale <> ?
              and par-pr-nakl = yes
              and ub.trn-doc.ext-doc-type = 'iv':U
          then do:
              run calc-npricesale-doc-line
                ( input v-root-b-code,
                  input ub.price-doc.doc-num,
                  input gds-dtl.doc-code ,
                  input gds-dtl.new-price-sale ,
                  output calc-rec
                )
                no-error.
          end.
          else do:
              run calc-pr-list
                ( input v-root-b-code,
                  input ub.price-doc.doc-num,
                  input 'Товар':U,
                  input ?,
                  input v-round-method,
                  input v-round-base,
                  input ?,
                  input ?,
                  input ?,
                  input ?,
                  output calc-rec
                )
                no-error.
          end.
          if error-status :error then do:
            line-mode = p-line-mode .
            undo cre-pr, return error.
          end.
          line-mode = p-line-mode .
        end.
      end case.
    end.
    find first ub.price-doc  exclusive-lock  where ub.price-doc.doc-num = l-d-n no-error .
    if available ub.price-doc then do:
       if v-parts = true then do:
          ub.price-doc.PS = "По ПН № " + ub.trn-doc.doc-code + " Создана переоценка цены = продажная цена партий".
       end.
      run ver-pr-equ-dq  ( input ub.price-doc.doc-num, input 1, input "" ) no-error .
      if error-status :error then do:
            v-msg = vss-workfile + " " + vss-revision  + " " + vss-description + "~n" +
                    "Ошибка при удалении строки переоценки " + "~n" +
                    ub.price-doc.doc-num  + "~n" +
                    error-status :get-message(1).
            if not g#news and
               not g#auto and
               not g#esys
            then
               message v-msg view-as alert-box information.
            undo cre-pr, return error v-msg.
      end.
      if p-flag = true then  do:
        run tax-name (input 'rdt':U ,output v-name-tax ).
        ub.price-doc.PS = ub.price-doc.PS + "  Компонент цены '" + string(v-name-tax) +  "' изменен с прошлой переоценки ." .
      end.
      case gen-mode :
        when "cost-price" then do:
          assign
            ub.price-doc.out-code   = ub.trn-doc.doc-code
            ub.price-doc.fact-date  = ub.trn-doc.fact-date
            ub.price-doc.fact-time  = ub.trn-doc.fact-time
            ub.price-doc.shift-date = ub.trn-doc.shift-date
            ub.price-doc.shift-num  = ub.trn-doc.shift-num
            ub.price-doc.shift-name = ub.trn-doc.shift-name
            ub.price-doc.status_    = 'акт':U
            .
        end.
        when "after-margin" then do:
          assign
            ub.price-doc.status_ = 'новый':U
            .
        end.
        when "after-margin-parts" or
        when "before-margin" then do:
          assign
            ub.price-doc.fact-date  = ub.trn-doc.fact-date
            ub.price-doc.fact-time  = ub.trn-doc.fact-time
            ub.price-doc.shift-date = ub.trn-doc.shift-date
            ub.price-doc.shift-num  = ub.trn-doc.shift-num
            ub.price-doc.shift-name = ub.trn-doc.shift-name
            ub.price-doc.status_    = 'новый':U
            .
          run str/pr-stat.p (  input parParentProc
                             , input v-log-handle
                             , input "close-act"
                             , input ub.price-doc.doc-num
                             , input ub.trn-doc.doc-code
                             , input true
                             , input false  ) no-error .
          if error-status :error then do:
              v-msg = vss-workfile + " " + vss-revision  + " " + vss-description + "~n" +
                      error-status :get-message(1) + "~n" +
                      return-value + "~n" +
                      "Расчет и закрытие переоценки до АКТ"
                      .
              if not g#news and
                 not g#auto and
                 not g#esys
              then
                 message v-msg view-as alert-box error.
              undo cre-pr, return error v-msg.
          end.
        end.
      end case .
      define variable tt as recid  no-undo .
      tt =  recid (price-doc) .
      if not can-find (first ub.price-list where ub.price-list.doc-num = l-d-n no-lock ) then do:
         v-msg = "Обратите ВНИМАНИЕ !!! В документе  переоценки " + l-d-n + " нет ни одной строки. " + "~n" +
                 "документ удаляется " + caps('новый':U).
         if not g#news and
            not g#auto and
            not g#esys
         then
            message v-msg view-as alert-box error.
          undo cre-pr, return.
      end.
      assign
        v-rest-last =  ub.price-doc.rest-last
        v-rest-sale =  ub.price-doc.rest-sale
        v-sale-base =  ub.price-doc.sale-base
        v-rest-qnty =  ub.price-doc.rest-qnty
      .
      release ub.price-doc no-error.
      if error-status :error then do:
        undo cre-pr, return error.
      end.
      run create-dfc in this-procedure (
          input v-plt-id
         ,input v-plt-db-num
         ,input v-pdf-id
         ,input v-pdf-db-num
         ,input l-d-n
         ,input ub.trn-doc.base-rate
         ,input ub.trn-doc.base-scale
         ) .
define buffer test_price-doc for ub.price-doc  .
      if  gen-mode =  "cost-price" or
          gen-mode = "before-margin" or
          gen-mode = "after-margin-parts"
        then  do:
            find first test_price-doc no-lock where test_price-doc.doc-num = l-d-n no-error .
            if available test_price-doc then do:
                run str/pr-stat.p
                  ( input parParentProc,
                    input v-log-handle ,
                    input "act",
                    input l-d-n,
                    input ub.trn-doc.doc-code ,
                    input true ,
                    input true ).
                  find first test_price-doc exclusive-lock where
                              test_price-doc.doc-num = l-d-n
                              no-error .
                  if available test_price-doc then do:
                      assign
                        test_price-doc.rest-last = v-rest-last
                        test_price-doc.rest-qnty = v-rest-qnty
                        test_price-doc.rest-sale = v-rest-sale
                        test_price-doc.sale-base = v-sale-base
                      .
                  end.
            end.
            run str/pr-pr.p ( parParentProc , tt ).
      end.
    end.
  end.
  run waitfram-hide in this-procedure.
end.
PROCEDURE exp-prt:
define input  parameter g-code  like ub.goods.gds-code    no-undo.
define input  parameter old-num like ub.price-doc.doc-num no-undo.
define input  parameter new-num like ub.price-doc.doc-num no-undo.
define output parameter new-rec as recid               no-undo.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-price-list for ub.price-list.
find buf-goods no-lock where
     buf-goods.gds-code = g-code.
exp-alt:
do on error undo exp-alt, return error:
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each  buf-price-list where
          buf-price-list.doc-num    = old-num and
          buf-price-list.artic      = buf-goods.artic and
          buf-price-list.prod-type  = buf-goods.prod-type and
          buf-price-list.prod-code  = buf-goods.prod-code and
          buf-price-list.main-price = no,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli <> buf-goods.unit-base:
  run cre-pr-list (input  buf-bar-code.b-code,
                   input  new-num,
                   output new-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" buf-bar-code.b-code
      view-as alert-box.
    next.
  end.
end.
  if par-pr-parex = "yes" and
     par-pr-notls = "yes" then do:
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_parts for ub.parts  .
    for each  buf_parts no-lock where
          buf_parts.out-code    = 'free-zone':U and
          buf_parts.obj-type   = v-cntxt-obj-type and
          buf_parts.obj-code   = v-cntxt-obj-code and
          buf_parts.rsrv-free   = true  and
          buf_parts.status_     = false and
          buf_parts.artic       = buf-goods.artic and
          buf_parts.prod-type   = buf-goods.prod-type and
          buf_parts.prod-code   = buf-goods.prod-code ,
        first buf-bar-code no-lock where
              buf-bar-code.gds-code  = buf-goods.gds-code and
              buf-bar-code.unit-cli  = buf-goods.unit-base and
              buf-bar-code.in-code   = buf_parts.in-code and
              buf-bar-code.part-code = buf_parts.part-code
          :
  run cre-pr-list (input  buf-bar-code.b-code,
                   input  new-num,
                   output new-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" buf-bar-code.b-code
      view-as alert-box.
    next.
  end.
end.
  end.
end.
END PROCEDURE.
procedure ver-par-disc-mar :
 do
 on error undo, return error return-value
 :
define input parameter   p-obj-type    like ub.clients.obj-type no-undo .
define input parameter   p-obj-code    like ub.clients.obj-type no-undo .
define input parameter   p-node-code   like ub.goods.grp-code no-undo .
define output parameter  par-disc-mar  as logical no-undo .
define variable p-host-code       as integer no-undo .
define variable p-prc-min         as decimal no-undo .
define variable p-prc-max         as decimal no-undo .
define variable p-increase-pc     as decimal no-undo .
define variable p-round-method    as character no-undo .
define variable p-base            as decimal no-undo .
define variable p-value-margin    as integer  no-undo.
define variable p-type-margin     as logical no-undo .
define variable p-value-increase  as integer  no-undo.
define variable p-type-increase   as logical no-undo .
define variable p-value-rmethod   as integer  no-undo.
define variable p-type-rmethod    as logical no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
 par-disc-mar = false .
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-host-code
  )  .
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input p-obj-type
  ,input p-obj-code
  ,input 'overval':U
  ,input  "pr-discm"
  ,output par-pr-discm
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
if trim(par-pr-discm) = "" then return .
run grp-obj-margin-value
( input   p-node-code ,
  input   p-obj-type  ,
  input   p-obj-code  ,
  output  p-prc-min  ,
  output  p-prc-max  ,
  output  p-increase-pc,
  output  p-round-method ,
  output  p-base         ,
  output  p-value-margin    ,
  output  p-type-margin,
  output  p-value-increase,
  output  p-type-increase  ,
  output  p-value-rmethod,
  output  p-type-rmethod
  ) .
if p-type-margin = false  then return.
par-disc-mar = true  .
 end.
end procedure.
procedure create-dfc :
define input  parameter v-plt-id      as integer   no-undo .
define input  parameter v-plt-db-num  as integer   no-undo .
define input  parameter v-pdf-id      as integer   no-undo .
define input  parameter v-pdf-db-num  as integer   no-undo .
define input  parameter v-doc-num     as character no-undo .
define input  parameter p-base-rate   as decimal   no-undo .
define input  parameter p-base-scale  as decimal   no-undo .
define buffer red_price-doc for ub.price-doc  .
define buffer red_price-list for ub.price-list  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_price-all for ub.price-all  .
define variable v-price-calc-base  as decimal   no-undo .
define variable v-price-calc-doc   as decimal   no-undo .
define variable v-price-calc-rubl  as decimal   no-undo .
define variable v-price-prev-base  as decimal   no-undo .
define variable v-price-prev-doc   as decimal   no-undo .
define variable v-price-prev-rubl  as decimal   no-undo .
define variable v-price-sale-base  as decimal   no-undo .
define variable v-price-sale-doc   as decimal   no-undo .
define variable v-price-sale-rubl  as decimal   no-undo .
define variable v-road-tax-base    as decimal   no-undo .
define variable v-road-tax-doc     as decimal   no-undo .
define variable v-road-tax-rubl    as decimal   no-undo .
define variable v-excise-base      as decimal   no-undo .
define variable v-excise-doc       as decimal   no-undo .
define variable v-excise-rubl      as decimal   no-undo .
define variable v-type as character no-undo .
define variable v-code as integer   no-undo .
define variable v-prev-doc-code as character no-undo .
define variable v-status as integer   no-undo .
  do
  on error undo, return error return-value
  :
run waitfram-show in this-procedure ( "Создание документа формирования цены... " ) .
find first red_price-doc no-lock where
           red_price-doc.doc-num = v-doc-num
           no-error .
find first buf_price-doc-forming exclusive-lock where
           buf_price-doc-forming.plt-id     = v-plt-id      and
           buf_price-doc-forming.plt-db-num = v-plt-db-num  and
           buf_price-doc-forming.pdf-id     = v-pdf-id      and
           buf_price-doc-forming.pdf-db     = v-pdf-db-num
           no-error .
assign
  v-type = red_price-doc.obj-type
  v-code = red_price-doc.obj-code
.
assign
   buf_price-doc-forming.name = trim ( trim (red_price-doc.ps, "@" ))
   buf_price-doc-forming.stts = integer('0':U)
   v-status = ( if red_price-doc.status_ = 'новый':U then integer('0':U) else integer('3':U) )
.
for each red_price-list no-lock  where red_price-list.doc-num = v-doc-num :
if var-pr-r-b = "rubl" then do:
 v-price-calc-rubl  = red_price-list.price-calc .
 v-price-calc-base  = v-price-calc-rubl / p-base-rate * p-base-scale .
 v-price-calc-doc   = red_price-list.price-calc .
 v-price-prev-rubl  = red_price-list.price-prev  .
 v-price-prev-base  = v-price-prev-rubl / p-base-rate * p-base-scale .
 v-price-prev-doc   = red_price-list.price-prev  .
 v-price-sale-rubl  = red_price-list.price-sale  .
 v-price-sale-base  = v-price-sale-rubl / p-base-rate * p-base-scale .
 v-price-sale-doc   = red_price-list.price-sale  .
 v-road-tax-rubl    = red_price-list.road-tax    .
 v-road-tax-base    = v-road-tax-rubl   / p-base-rate * p-base-scale .
 v-road-tax-doc     = red_price-list.road-tax    .
 v-excise-rubl      = red_price-list.excise      .
 v-excise-base      = v-excise-rubl     / p-base-rate * p-base-scale .
 v-excise-doc       = red_price-list.excise      .
 end.
else do:
 v-price-calc-base  = red_price-list.price-calc .
 v-price-calc-rubl  = v-price-calc-base * p-base-rate / p-base-scale .
 v-price-calc-doc   = red_price-list.price-calc .
 v-price-prev-base  = red_price-list.price-prev  .
 v-price-prev-rubl  = v-price-prev-base * p-base-rate / p-base-scale .
 v-price-prev-doc   = red_price-list.price-prev  .
 v-price-sale-base  = red_price-list.price-sale  .
 v-price-sale-rubl  = v-price-sale-base * p-base-rate / p-base-scale .
 v-price-sale-doc   = red_price-list.price-sale  .
 v-road-tax-base    = red_price-list.road-tax    .
 v-road-tax-rubl    = v-road-tax-base   * p-base-rate / p-base-scale .
 v-road-tax-doc     = red_price-list.road-tax    .
 v-excise-base      = red_price-list.excise      .
 v-excise-rubl      = v-excise-base     * p-base-rate / p-base-scale .
 v-excise-doc       = red_price-list.excise      .
end.
    create buf_price-doc-forming-gds.
    assign
       buf_price-doc-forming-gds.pdf-db            = v-pdf-db-num
       buf_price-doc-forming-gds.pdf-id            = v-pdf-id
       buf_price-doc-forming-gds.plt-db-num        = v-plt-db-num
       buf_price-doc-forming-gds.plt-id            = v-plt-id
       buf_price-doc-forming-gds.line-num          = red_price-list.line-num
       buf_price-doc-forming-gds.artic             = red_price-list.artic
       buf_price-doc-forming-gds.prod-code         = red_price-list.prod-code
       buf_price-doc-forming-gds.prod-type         = red_price-list.prod-type
       buf_price-doc-forming-gds.b-code            = red_price-list.b-code
       buf_price-doc-forming-gds.calc-method       = red_price-list.calc-method
       buf_price-doc-forming-gds.d-pcnt            = red_price-list.d-pcnt
       buf_price-doc-forming-gds.end-date          = ?
       buf_price-doc-forming-gds.end-shift-date    = ?
       buf_price-doc-forming-gds.end-shift-name    = ?
       buf_price-doc-forming-gds.end-shift-num     = ?
       buf_price-doc-forming-gds.end-sys-date      = ?
       buf_price-doc-forming-gds.end-sys-time      = ?
       buf_price-doc-forming-gds.have-end-period   = int(false)
       buf_price-doc-forming-gds.have-start-period = int(false)
       buf_price-doc-forming-gds.price-calc-base   =  v-price-calc-base
       buf_price-doc-forming-gds.price-calc-doc    =  v-price-calc-doc
       buf_price-doc-forming-gds.price-calc-rubl   =  v-price-calc-rubl
       buf_price-doc-forming-gds.price-prev-base   =  v-price-prev-base
       buf_price-doc-forming-gds.price-prev-doc    =  v-price-prev-doc
       buf_price-doc-forming-gds.price-prev-rubl   =  v-price-prev-rubl
       buf_price-doc-forming-gds.price-sale-base   =  v-price-sale-base
       buf_price-doc-forming-gds.price-sale-doc    =  v-price-sale-doc
       buf_price-doc-forming-gds.price-sale-rubl   =  v-price-sale-rubl
       buf_price-doc-forming-gds.road-tax-base     =  v-road-tax-base
       buf_price-doc-forming-gds.road-tax-doc      =  v-road-tax-doc
       buf_price-doc-forming-gds.road-tax-rubl     =  v-road-tax-rubl
       buf_price-doc-forming-gds.excise-base       =  v-excise-base
       buf_price-doc-forming-gds.excise-doc        =  v-excise-doc
       buf_price-doc-forming-gds.excise-rubl       =  v-excise-rubl
       buf_price-doc-forming-gds.vat-pc            = red_price-list.vat-pc
       buf_price-doc-forming-gds.slt-pc            = red_price-list.slt-pc
       buf_price-doc-forming-gds.start-date        = ?
       buf_price-doc-forming-gds.start-shift-date  = ?
       buf_price-doc-forming-gds.start-shift-name  = ?
       buf_price-doc-forming-gds.start-shift-num   = ?
       buf_price-doc-forming-gds.start-sys-date    = ?
       buf_price-doc-forming-gds.start-sys-time    = ?
       buf_price-doc-forming-gds.stts              = buf_price-doc-forming.stts
       .
end.
 if red_price-doc.status_ = 'новый':U  then do:
    find first red_price-doc exclusive-lock where
               red_price-doc.doc-num = v-doc-num
               no-error .
    delete red_price-doc.
 end.
    if v-status <> 0 then do:
        run str/diallog.w
            (parparentproc
            , this-procedure
            , 'str/pdf-clos.p':U
            , ( string(recid(buf_price-doc-forming)) + chr(4) +
              'yes' + chr(4) +
              'no' + chr(4) +
              v-type + chr(4) +
              string(v-code) + chr(4) +
              ( if gen-mode =  "cost-price" then   "cost-price-act"  else 'факт':U ) + chr(4) +
              ub.trn-doc.doc-code + chr(4) +
              'yes' )
            , yes
            , '':U
            , 'Закрытие ДНЦ') no-error .
        if error-status :error then do:
           if return-value  <> "pr-goods":U  then do:
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "Для закрытых ДНЦ сформировать денорм цены"
                view-as alert-box error
              .
              return error return-value .
           end.
        end.
    end.
run waitfram-hide in this-procedure.
  end.
end procedure.
procedure find-main-plt :
define input  parameter p-cntxt-obj-type as character no-undo .
define input  parameter p-cntxt-obj-code as integer   no-undo .
define output parameter p-plt-id         as integer   no-undo .
define output parameter p-plt-db-num     as integer   no-undo .
define output parameter p-round-method   as character no-undo .
define output parameter p-round-base     as decimal   no-undo .
define buffer buf_price-list-type    for ub.price-list-type  .
define buffer result_price-list-type for ub.price-list-type  .
  do
  on error undo, return error return-value
  :
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  parparentproc
  ,input  p-cntxt-obj-type
  ,input  p-cntxt-obj-code
  ,input  yes
  ,output p-plt-id
  ,output p-plt-db-num
  ) no-error .
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Поиск ГТПЛ для переоценок"
    view-as alert-box error
  .
  find first buf_price-list-type no-lock where
             buf_price-list-type.stts = integer('0':U) and
             buf_price-list-type.main = true  and
             buf_price-list-type.plt-id     = p-plt-id     and
             buf_price-list-type.plt-db-num = p-plt-db-num no-error .
  if not available buf_price-list-type then return error substitute("Не найден главный тип прайс-листа  &1 &2" ,p-plt-id ,p-plt-db-num ) .
  if buf_price-list-type.under-type-list  = 1 then do:
      find first result_price-list-type no-lock where
                result_price-list-type.stts = integer('0':U) and
                result_price-list-type.main = true  and
                result_price-list-type.plt-id     = buf_price-list-type.plt-main-id and
                result_price-list-type.plt-db-num = buf_price-list-type.plt-main-db-num no-error .
  if not available result_price-list-type then return error substitute("Не найден главный родительский тип прайс-листа  для подчиненного &1 &2" , p-plt-id ,p-plt-db-num ) .
  end.
  else do:
    find first result_price-list-type no-lock where  recid(result_price-list-type) = recid(buf_price-list-type) no-error .
  end.
  assign
    p-plt-id        = result_price-list-type.plt-id
    p-plt-db-num    = result_price-list-type.plt-db-num
    p-round-method  = result_price-list-type.calc-round-method
    p-round-base    = result_price-list-type.calc-round-base
  .
  end.
end procedure.
procedure calc-npricesale-doc-line :
define input  parameter bc    like ub.price-list.b-code no-undo.
define input  parameter d-num like ub.price-doc.doc-num no-undo.
define input  parameter p-doc-num  as character    no-undo.
define input  parameter p-new-sum  as decimal      no-undo .
define output parameter calc-rec   as recid        no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer buf-gds-grp    for ub.gds-grp.
define buffer buf-price-doc  for ub.price-doc.
  do
  on error undo, return error return-value
  :
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
        buf-price-list.price-sale = p-new-sum .
        buf-price-list.price-calc = p-new-sum .
        buf-price-list.calc-method = 'Накладная':U + " " + p-doc-num .
        calc-rec = recid (buf-price-list).
  run calc-pr-sub (input  buf-bar-code.b-code,
                   input  buf-price-list.doc-num,
                   input  'Отсутствует':U,
                   input  0,
                   input  ?  ,
                   input  ?,
                   output calc-rec) no-error.
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  end.
end procedure.
