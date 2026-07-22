block-level on error undo, throw.
define input parameter p-doc-code   like ub.doc-line.doc-code  no-undo .
define input parameter p-artic      like ub.doc-line.artic     no-undo .
define input parameter p-prod-type  like ub.doc-line.prod-type no-undo .
define input parameter p-prod-code  like ub.doc-line.prod-code no-undo .
define input parameter p-new-SLT-pc as decimal no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение НП поставщика в строке документа".
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
procedure partrqst :
  define input  parameter p-doc-code                   like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type                   like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code                   like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                      like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type                  like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code                  like ub.doc-line.prod-code no-undo .
  define output parameter p-total-parts-qnty           like ub.parts.qnty         no-undo .
  define output parameter p-total-parts-fact-qnty      like ub.parts.fact-qnty    no-undo .
  define output parameter p-total-parts-cli-qnty       like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-fact-cli-qnty  like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-price-cli      as decimal                 no-undo .
  define output parameter p-total-parts-price-base     as decimal                 no-undo .
  define output parameter p-total-parts-price-rubl     as decimal                 no-undo .
  define output parameter p-total-parts-transport-base as decimal                 no-undo .
  define output parameter p-total-parts-transport-rubl as decimal                 no-undo .
  define output parameter p-total-parts-other-base     as decimal                 no-undo .
  define output parameter p-total-parts-other-rubl     as decimal                 no-undo .
  define variable vss-description as character no-undo init "partrqst: Суммарная информация по всем зарезервированным партиям строки документа".
  do
  on error undo, return error return-value
  :
    assign
      p-total-parts-qnty           = 0
      p-total-parts-fact-qnty      = 0
      p-total-parts-cli-qnty       = 0
      p-total-parts-fact-cli-qnty  = 0
      p-total-parts-price-cli      = 0
      p-total-parts-price-base     = 0
      p-total-parts-price-rubl     = 0
      p-total-parts-transport-base = 0
      p-total-parts-transport-rubl = 0
      p-total-parts-other-base     = 0
      p-total-parts-other-rubl     = 0
    .
    define buffer buf_parts for ub.parts .
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      define variable v-parts-fact-multiplier as decimal   no-undo .
      assign
        v-parts-fact-multiplier = 1
      .
      if buf_parts.qnty <> 0 then do:
        assign
          v-parts-fact-multiplier = buf_parts.fact-qnty / buf_parts.qnty
        .
      end.
      assign
        p-total-parts-qnty            = p-total-parts-qnty       + buf_parts.qnty
        p-total-parts-fact-qnty       = p-total-parts-fact-qnty  + buf_parts.fact-qnty
        p-total-parts-cli-qnty        = p-total-parts-cli-qnty   + buf_parts.cli-qnty
        p-total-parts-fact-cli-qnty   = p-total-parts-fact-cli-qnty
                                      + buf_parts.cli-qnty * v-parts-fact-multiplier
        p-total-parts-price-cli       = p-total-parts-price-cli  + buf_parts.cli-qnty  * buf_parts.price-cli
        p-total-parts-price-base      = p-total-parts-price-base + buf_parts.fact-qnty * buf_parts.price-base
        p-total-parts-price-rubl      = p-total-parts-price-rubl + buf_parts.fact-qnty * buf_parts.price-rubl
        p-total-parts-transport-base  = p-total-parts-transport-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-base <> ?
                                          then buf_parts.transport-base
                                          else 0
                                          )
        p-total-parts-transport-rubl  = p-total-parts-transport-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-rubl <> ?
                                          then buf_parts.transport-rubl
                                          else 0
                                          )
        p-total-parts-other-base      = p-total-parts-other-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-base <> ?
                                          then buf_parts.other-base
                                          else 0
                                          )
        p-total-parts-other-rubl      = p-total-parts-other-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-rubl <> ?
                                          then buf_parts.other-rubl
                                          else 0
                                          )
      .
    end.
  end.
end procedure.
  def var price-cli-loc like ub.doc-line.price-cli no-undo .
  def var varr-b        as   character             no-undo.
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
define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
find first ub.doc-line no-lock
  where ub.doc-line.doc-code   = p-doc-code
    and ub.doc-line.artic      = p-artic
    and ub.doc-line.prod-type  = p-prod-type
    and ub.doc-line.prod-code  = p-prod-code
  no-error .
if not available ub.doc-line then do:
  message
    vss-workfile vss-revision vss-description skip
    "Не найдена запись doc-line" skip
    "p-doc-code"  p-doc-code  skip
    "p-artic"     p-artic     skip
    "p-prod-type" p-prod-type skip
    "p-prod-code" p-prod-code skip
    view-as alert-box error .
end.
if p-new-SLT-pc = ub.doc-line.SLT-pc then do:
  return .
end.
trans-block:
do transaction
on error undo trans-block, return error
:
  find first ub.trn-doc exclusive-lock
    where ub.trn-doc.doc-code = p-doc-code
    .
  if ub.trn-doc.doc-type <> 'при':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "У данного документа нельзя менять процент НП" skip
      "Указанный документ не является документом внешнего прихода" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Тип документа" ub.trn-doc.doc-type skip
      view-as alert-box .
    undo, return error return-value .
  end.
  if ub.trn-doc.status_ <> 'факт':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "У данного документа нельзя менять процент НП" skip
      "Статус документа отличен от статуса" 'факт':U skip
      "Статус документа" ub.trn-doc.status_ skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Статус документа" ub.trn-doc.status_ skip
      view-as alert-box .
    undo, return error return-value .
  end.
  if  ub.trn-doc.SLT-type = 'без':U
  and p-new-SLT-pc <> 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "У документа с типом заведения НП" 'без':U skip
      "можно задать только нулевой процент НП" skip
      "Статус документа" ub.trn-doc.status_ skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Статус документа" ub.trn-doc.status_ skip
      "Процент НДС" p-new-SLT-pc skip
      view-as alert-box .
    undo, return error return-value .
  end.
  find current ub.doc-line exclusive-lock .
  assign
    ub.doc-line.SLT-pc = p-new-SLT-pc
  .
  for each parts exclusive-lock
    where parts.in-code   = p-doc-code
      and parts.artic     = p-artic
      and parts.prod-type = p-prod-type
      and parts.prod-code = p-prod-code
  on error undo trans-block, return error
  :
if varr-b = "rubl":u then do:
  assign
  price-cli-loc =
    ( ( ub.parts.price-rubl
      - ub.parts.transport-rubl
      - ub.parts.other-rubl
      - ub.parts.road-tax-rubl
      )
      *
      ( if ub.trn-doc.slt-type = 'нет':U
        then 100 / (100 + ub.parts.slt-pc)
        else 1
      )
      *
      ( if ub.trn-doc.vat-type = 'нет':U
        then 100 / (100 + ub.parts.vat-pc)
        else 1
      )
      + ub.parts.road-tax-rubl
    )
    / ub.trn-doc.exch-rate *  ub.trn-doc.exch-scale * ub.parts.cli-base-rate
    .
end.
else do:
  assign
  price-cli-loc =
    ( ( ub.parts.price-base
      - ub.parts.transport-base
      - ub.parts.other-base
      - ub.parts.road-tax-base
      )
      *
      ( if ub.trn-doc.slt-type = 'нет':U
        then 100 / (100 + ub.parts.slt-pc)
        else 1
      )
      *
      ( if ub.trn-doc.vat-type = 'нет':U
        then 100 / (100 + ub.parts.vat-pc)
        else 1
      )
      + ub.parts.road-tax-base
    )
      * ub.trn-doc.base-rate / ub.trn-doc.base-scale
    / ub.trn-doc.exch-rate *  ub.trn-doc.exch-scale * ub.parts.cli-base-rate
    .
end.
    assign
      parts.SLT-pc    = p-new-SLT-pc
      parts.price-cli = price-cli-loc
    .
    define variable v-gds-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pargocod in g#library
  (input  recid(parts)
  ,output v-gds-code
  )  .
    for each parts-attr exclusive-lock
      where parts-attr.in-code   = parts.in-code
        and parts-attr.gds-code  = v-gds-code
        and parts-attr.part-code = parts.part-code
    on error undo trans-block, return error
    :
      assign
        parts-attr.SLT-pc    = parts.SLT-pc
        parts-attr.price-cli = parts.price-cli
      .
assign
  price-rubl-with-tax-loc = parts.price-rubl
  price-base-with-tax-loc = parts.price-base
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if parts.out-code = 'free-zone':U     or
     parts.out-code = 'out-zone':U   or
     parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = parts.out-code
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
   price-cli-with-tax-loc = parts.price-cli
   cli-base-rate          = parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if parts.road-tax-base  = ? then 0 else parts.road-tax-base)
           road-tax-rubl-loc  = (if parts.road-tax-rubl  = ? then 0 else parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if parts.transport-base = ? then 0 else parts.transport-base)
          transport-rubl-loc = (if parts.transport-rubl = ? then 0 else parts.transport-rubl)
          other-base-loc     = (if parts.other-base     = ? then 0 else parts.other-base)
          other-rubl-loc     = (if parts.other-rubl     = ? then 0 else parts.other-rubl)
          vat-pc-loc         = (if parts.vat-pc         = ? then 0 else parts.vat-pc)
          slt-pc-loc         = (if parts.slt-pc         = ? then 0 else parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / parts.price-cli .
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
        parts-attr.vat-base         = vat-base-loc
        parts-attr.vat-rubl         = vat-rubl-loc
        parts-attr.slt-base         = slt-base-loc
        parts-attr.slt-rubl         = slt-rubl-loc
        parts-attr.discnt-base      = 0
        parts-attr.discnt-rubl      = 0
      .
    end.
    define buffer buf_trn-doc for ub.trn-doc .
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = parts.out-code
      no-error .
    if available buf_trn-doc
    and buf_trn-doc.status_ = 'факт':U
    then do:
      run trg/markdoc.p
        (input buf_trn-doc.doc-code
        ,input 'doc-change':u
        ) no-error .
      if error-status :error
      then do:
        message
          "Не удалось зарегистрировать изменение документа" skip
          "Документ" parts.out-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
  run partrqst in this-procedure
    (input  ub.doc-line.doc-code
    ,input  ub.doc-line.obj-type
    ,input  ub.doc-line.obj-code
    ,input  ub.doc-line.artic
    ,input  ub.doc-line.prod-type
    ,input  ub.doc-line.prod-code
        ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
    ).
  if  trn-doc.doc-type = 'при':U
  and trn-doc.internal = no
  then do:
    if v-total-parts-cli-qnty <> 0 then do:
      assign
        ub.doc-line.price-cli = v-total-parts-price-cli / v-total-parts-cli-qnty
      .
    end.
  end.
  run trg/markdoc.p
    (input ub.trn-doc.doc-code
    ,input 'doc-change':u
    ) no-error .
  if error-status :error
  then do:
    message
      "Не удалось зарегистрировать изменение документа" skip
      "Документ" ub.trn-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
end.
