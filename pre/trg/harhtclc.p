block-level on error undo, throw.
define input  parameter p-cat-code       like ub.hold-time.cat-code no-undo .
define input  parameter p-lock-code      as character no-undo .
define input  parameter p-btpr-type-code as character no-undo .
define input  parameter p-doc-code       like ub.trn-doc.doc-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет межфирменного архива по одному документу".
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
      p-vss-parameters = substitute('&1|&2|&3|&4':u,p-cat-code,p-lock-code,p-btpr-type-code,p-doc-code)
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
PROCEDURE LastDate:
    def input parameter in-date as date no-undo.
    def output parameter LastDate as date no-undo.
    LastDate = ((DATE(MONTH(in-date),28,YEAR(in-date)) + 4) - DAY(DATE(MONTH(in-date),28,YEAR(in-date)) + 4)).
END PROCEDURE.
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure create-hold-time :
define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
define input parameter p-start-date like ub.hold-time.start-date no-undo .
DEFINE VARIABLE v-end-date like ub.hold-time.end-date no-undo .
define buffer buf_hold-time for ub.hold-time .
define buffer last_hold-time for ub.hold-time .
  do
  on error undo, return error
  :
    find last last_hold-time no-lock
      where last_hold-time.cat-code = p-cat-code
      use-index pi
      no-error .
    run gbl/lastdate.p
      (input p-start-date
      ,output v-end-date)
      no-error .
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка поиска последней даты периода" skip
      "Дата начала периода" p-start-date
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.
    create buf_hold-time.
    assign
      buf_hold-time.cat-code       = p-cat-code
      buf_hold-time.time-code      = (if available last_hold-time
                                      then (last_hold-time.time-code + 1)
                                      else 1)
      buf_hold-time.time-type      = 'мес':U
      buf_hold-time.start-date     = p-start-date
      buf_hold-time.end-date       = v-end-date
      buf_hold-time.create-date    = today
      buf_hold-time.update-date    = today
      buf_hold-time.grpupdate-date = today
    .
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure holdprts-create-parts-supp :
  define input  parameter p-orig-in-code   like ub.parts-supp.orig-in-code   no-undo .
  define input  parameter p-orig-part-code like ub.parts-supp.orig-part-code no-undo .
  define input  parameter p-in-code        like ub.parts-supp.in-code        no-undo .
  define input  parameter p-artic          like ub.parts-supp.artic          no-undo .
  define input  parameter p-prod-type      like ub.parts-supp.prod-type      no-undo .
  define input  parameter p-prod-code      like ub.parts-supp.prod-code      no-undo .
  define input  parameter p-part-code      like ub.parts-supp.part-code      no-undo .
  define variable vss-description as character no-undo init "holdprts-create-parts-supp-01: скопировать атрибут партии".
  define buffer buf_parent_trn-doc  for ub.trn-doc .
  define buffer buf_child_trn-doc   for ub.trn-doc .
  define buffer buf_parts           for ub.parts .
  define buffer buf_parts-supp      for ub.parts-supp .
  define buffer buf_orig_parts-supp for ub.parts-supp .
  define buffer buf_income_trn-doc  for ub.trn-doc .
  define buffer buf_income_doc-line for ub.doc-line .
  define buffer buf_goods           for ub.goods .
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
  do
  on error undo, return error return-value
  :
    find first buf_child_trn-doc no-lock
      where buf_child_trn-doc.doc-code = p-in-code
      no-error .
    if not available buf_child_trn-doc
    then do:
      return substitute("Не найден исходный документ &1", p-in-code) .
    end.
    find first buf_parent_trn-doc no-lock
      where buf_parent_trn-doc.doc-code = buf_child_trn-doc.hold-doc-code-parent
      no-error .
    if not available buf_parent_trn-doc
    then do:
      return substitute("Не найден приходный документ &1", buf_child_trn-doc.hold-doc-code-parent) .
    end.
    find first buf_parts-supp exclusive-lock
      where buf_parts-supp.in-code   = p-in-code
        and buf_parts-supp.artic     = p-artic
        and buf_parts-supp.prod-type = p-prod-type
        and buf_parts-supp.prod-code = p-prod-code
        and buf_parts-supp.part-code = p-part-code
      no-error .
    if available buf_parts-supp
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Попытка повторного создания партии атрибутов" skip
        "Документ прихода" p-in-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код партии" p-part-code skip
        "Исходный код партии" p-orig-in-code skip
        "Исходный код документа" p-orig-part-code skip
        view-as alert-box error .
      undo, return error .
    end.
    create buf_parts-supp .
    assign
      buf_parts-supp.in-code   = p-in-code
      buf_parts-supp.artic     = p-artic
      buf_parts-supp.prod-type = p-prod-type
      buf_parts-supp.prod-code = p-prod-code
      buf_parts-supp.part-code = p-part-code
    .
    assign
      buf_parts-supp.orig-in-code   = p-orig-in-code
      buf_parts-supp.orig-part-code = p-orig-part-code
    .
    find first buf_orig_parts-supp share-lock
      where buf_orig_parts-supp.in-code   = p-orig-in-code
        and buf_orig_parts-supp.artic     = p-artic
        and buf_orig_parts-supp.prod-type = p-prod-type
        and buf_orig_parts-supp.prod-code = p-prod-code
        and buf_orig_parts-supp.part-code = p-orig-part-code
      no-error .
    if available buf_orig_parts-supp
    then do:
      buffer-copy buf_orig_parts-supp
      except
        buf_orig_parts-supp.in-code
        buf_orig_parts-supp.artic
        buf_orig_parts-supp.prod-type
        buf_orig_parts-supp.prod-code
        buf_orig_parts-supp.part-code
        buf_orig_parts-supp.orig-in-code
        buf_orig_parts-supp.orig-part-code
      to buf_parts-supp.
    end.
    else do:
      find first buf_parts share-lock
        where buf_parts.obj-type  = buf_parent_trn-doc.obj-type
          and buf_parts.obj-code  = buf_parent_trn-doc.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.in-code   = p-orig-in-code
          and buf_parts.out-code  = buf_parent_trn-doc.doc-code
          and buf_parts.part-code = p-orig-part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info3 skip
          "Ошибка задания входных параметров" skip
          "Не найдена исходная партия" skip
          "Исходный документ" p-orig-in-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код партии" p-orig-part-code skip
          view-as alert-box error .
        undo, return error .
      end.
      define variable v-base-rate         as decimal   no-undo .
      define variable v-base-scale        as integer   no-undo .
      define variable v-exch-rate         as decimal   no-undo .
      define variable v-exch-scale        as integer   no-undo .
      define variable v-extended-doc-type as character no-undo .
      define variable v-unit-cli          as character no-undo .
      find first buf_income_trn-doc no-lock
        where buf_income_trn-doc.doc-code = p-orig-in-code
        no-error .
      if available buf_income_trn-doc
      then do:
        find first buf_income_doc-line no-lock
          where buf_income_doc-line.doc-code  = p-orig-in-code
            and buf_income_doc-line.artic     = p-artic
            and buf_income_doc-line.prod-type = p-prod-type
            and buf_income_doc-line.prod-code = p-prod-code
          no-error .
        if not available buf_income_doc-line
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info3 skip
            "Не найдена исходная строка документа прихода" skip
            "Исходный документ" p-orig-in-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код партии" p-orig-part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-base-rate         = buf_income_trn-doc.base-rate
          v-base-scale        = buf_income_trn-doc.base-scale
          v-exch-rate         = buf_income_trn-doc.exch-rate
          v-exch-scale        = buf_income_trn-doc.exch-scale
          v-extended-doc-type = buf_income_trn-doc.ext-doc-type
          v-unit-cli          = buf_income_doc-line.unit-cli
        .
      end.
      else do:
        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-type = buf_parts.prod-type
            and buf_goods.prod-code = buf_parts.prod-code
          .
        assign
          v-base-rate         = buf_parts.price-rubl / buf_parts.price-base
          v-base-scale        = 1
          v-exch-rate         = buf_parts.price-rubl / (buf_parts.price-cli * buf_parts.cli-base-rate)
          v-exch-scale        = 1
          v-extended-doc-type = 'ie':U
          v-unit-cli          = buf_goods.unit-cli
        .
      end.
       if v-base-rate = ? then v-base-rate = 1.
       if v-exch-rate = ? then v-exch-rate = 1.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
        buf_parts-supp.PS                = buf_parts.PS
        buf_parts-supp.SLT-type          = buf_parts.SLT-type
        buf_parts-supp.VAT-type          = buf_parts.VAT-type
        buf_parts-supp.base-rate         = v-base-rate
        buf_parts-supp.base-scale        = v-base-scale
        buf_parts-supp.cli-qnty          = buf_parts.cli-qnty
        buf_parts-supp.cst-code          = buf_parts.cst-code
        buf_parts-supp.doc-qnty          = buf_parts.qnty
        buf_parts-supp.exch-code         = buf_parts.exch-code
        buf_parts-supp.exch-rate         = v-exch-rate
        buf_parts-supp.exch-scale        = v-exch-scale
        buf_parts-supp.extended-doc-type = v-extended-doc-type
        buf_parts-supp.fact-date         = buf_parts.fact-date
        buf_parts-supp.fact-qnty         = buf_parts.fact-qnty
        buf_parts-supp.last-date         = buf_parts.last-date
        buf_parts-supp.pay-code          = buf_parts.pay-code
        buf_parts-supp.price-cli         = buf_parts.price-cli
        buf_parts-supp.purch-code        = buf_parts.purch-code
        buf_parts-supp.supp-code         = buf_parts.supp-code
        buf_parts-supp.supp-type         = buf_parts.supp-type
        buf_parts-supp.unit-cli          = v-unit-cli
      .
      assign
        buf_parts-supp.vat-pc         = vat-pc-loc
        buf_parts-supp.slt-pc         = slt-pc-loc
        buf_parts-supp.price-base     = price-base-with-tax-loc
        buf_parts-supp.price-rubl     = price-rubl-with-tax-loc
        buf_parts-supp.vat-base       = vat-base-loc
        buf_parts-supp.vat-rubl       = vat-rubl-loc
        buf_parts-supp.slt-base       = slt-base-loc
        buf_parts-supp.slt-rubl       = slt-rubl-loc
        buf_parts-supp.road-tax-base  = road-tax-base-loc
        buf_parts-supp.road-tax-rubl  = road-tax-rubl-loc
        buf_parts-supp.transport-base = transport-base-loc
        buf_parts-supp.transport-rubl = transport-rubl-loc
        buf_parts-supp.other-base     = other-base-loc
        buf_parts-supp.other-rubl     = other-rubl-loc
      .
    end.
  end.
end procedure.
procedure holdprts-get-part-code :
  define input  parameter p-doc-code       as character no-undo .
  define output parameter p-hold-part-code as integer   no-undo .
  define variable vss-description as character no-undo init "holdprts-get-part-code-01: создать уникальный код партии внутри документа".
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'hold-part-code':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    assign
      p-hold-part-code = integer(v-attr-value) + 1
    .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input 'hold-part-code':U ,
                       input string(p-hold-part-code) )  .
  end.
end procedure.
procedure holdprts-validate-document :
  define input  parameter p-doc-code as character no-undo .
  define variable vss-description as character no-undo init "holdprts-validate-document-01: проверить правильность документа".
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer parent_trn-doc for ub.trn-doc .
  define buffer buf_parts      for ub.parts .
  define buffer buf_parts-supp for ub.parts-supp .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first parent_trn-doc exclusive-lock
      where parent_trn-doc.doc-code = buf_trn-doc.hold-doc-code-parent
      no-error .
    if not available parent_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Не найден родительский документ" skip
        "Документ" buf_trn-doc.doc-code skip
        "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type <> 'ie':U
    then do:
      return .
    end.
    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts-supp share-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info3 skip
          "Не найдена информация о поставщике" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_parts-supp share-lock
      where buf_parts-supp.in-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts share-lock
        where buf_parts.out-code  = buf_parts-supp.in-code
          and buf_parts.obj-type  = buf_trn-doc.obj-type
          and buf_parts.obj-code  = buf_trn-doc.obj-code
          and buf_parts.artic     = buf_parts-supp.artic
          and buf_parts.prod-type = buf_parts-supp.prod-type
          and buf_parts.prod-code = buf_parts-supp.prod-code
          and buf_parts.part-code = buf_parts-supp.part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info3 skip
          "Задана информация о поставщике для неизвестной партии" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.hold-doc-code-parent
    on error undo, return error
    :
      if  buf_trn-doc.doc-type = 'при':U
      and buf_parts.qnty = buf_parts.fact-qnty
      then do:
        next.
      end.
      find first buf_parts-supp share-lock
        where buf_parts-supp.orig-in-code   = buf_parts.in-code
          and buf_parts-supp.artic          = buf_parts.artic
          and buf_parts-supp.prod-type      = buf_parts.prod-type
          and buf_parts-supp.prod-code      = buf_parts.prod-code
          and buf_parts-supp.orig-part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info3 skip
          "Не найдена информация о поставщике для исходной накладной" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure holdprts-doc-type :
  define input  parameter p-cat-code as integer   no-undo .
  define input  parameter p-doc-code as character no-undo .
  define output parameter p-is-sale  as logical   no-undo .
  define output parameter p-is-purch as logical   no-undo .
  define variable vss-description as character no-undo init "holdprts-doc-type-01: определение типа документа для межфирменного архива".
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Тип архива" p-cat-code skip
        view-as alert-box error .
      undo, return error .
    end.
    case p-cat-code :
      when 1
      then do:
        define variable v-is-hold as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
        if v-is-hold = true
        then do:
          assign
            p-is-sale  = false
            p-is-purch = false
          .
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when 'ie':U or
            when 'ep':U
            then do:
              assign
                p-is-sale  = false
                p-is-purch = true
              .
            end.
            when 'ee':U or
            when 'es':U or
            when 're':U or
            when 'rs':U
            then do:
              assign
                p-is-sale  = true
                p-is-purch = false
              .
            end.
            when 'we':U or
            when 'vt':U or
            when 'vp':U or
            when 'ap':U or
            when 'mp':U or
            when 'pc':U or
            when 'iv':U or
            when 'ev':U or
            when 'io':U or
            when 'eo':U or
            when 'rv':U or
            when 'em':U or
            when 'wm':U or
            when 'im':U
            then do:
              assign
                p-is-sale  = false
                p-is-purch = false
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info3 skip
                "Неизвестный тип документа" skip
                "Документ" buf_trn-doc.doc-code skip
                "Тип документа" buf_trn-doc.ext-doc-type skip
                "Тип архива" p-cat-code skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
      when 2
      then do:
        case buf_trn-doc.ext-doc-type :
          when 'vt':U or
          when 'vp':U
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      when 3
      then do:
        case buf_trn-doc.ext-doc-type :
          when 'we':U
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип архивов" skip
          "Документ" buf_trn-doc.doc-code skip
          "Тип документа" buf_trn-doc.ext-doc-type skip
          "Тип архива" p-cat-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure holdprts-purch-values :
  define input  parameter p-doc-code             like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic                like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type            like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code            like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty            as decimal   no-undo .
  define output parameter p-purch-sum-base       as decimal   no-undo .
  define output parameter p-purch-sum-rubl       as decimal   no-undo .
  define output parameter p-purch-VAT-base       as decimal   no-undo .
  define output parameter p-purch-VAT-rubl       as decimal   no-undo .
  define output parameter p-purch-SLT-base       as decimal   no-undo .
  define output parameter p-purch-SLT-rubl       as decimal   no-undo .
  define output parameter p-purch-road-tax-base  as decimal   no-undo .
  define output parameter p-purch-road-tax-rubl  as decimal   no-undo .
  define output parameter p-purch-excise-base    as decimal   no-undo .
  define output parameter p-purch-excise-rubl    as decimal   no-undo .
  define output parameter p-purch-transport-base as decimal   no-undo .
  define output parameter p-purch-transport-rubl as decimal   no-undo .
  define output parameter p-purch-other-base     as decimal   no-undo .
  define output parameter p-purch-other-rubl     as decimal   no-undo .
  define output parameter p-purch-discnt-base    as decimal   no-undo .
  define output parameter p-purch-discnt-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "holdprts-purch-values-01: параметры закупки товара".
  define variable v-price-base     as decimal   no-undo .
  define variable v-price-rubl     as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .
  define buffer buf_trn-doc        for ub.trn-doc .
  define buffer buf_parts          for ub.parts .
  define buffer buf_parts-supp     for ub.parts-supp .
  define buffer buf_doc-line       for ub.doc-line .
  define buffer buf_income_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-fact-qnty            = 0
      p-purch-sum-base       = 0
      p-purch-sum-rubl       = 0
      p-purch-VAT-base       = 0
      p-purch-VAT-rubl       = 0
      p-purch-SLT-base       = 0
      p-purch-SLT-rubl       = 0
      p-purch-road-tax-base  = 0
      p-purch-road-tax-rubl  = 0
      p-purch-excise-base    = 0
      p-purch-excise-rubl    = 0
      p-purch-transport-base = 0
      p-purch-transport-rubl = 0
      p-purch-other-base     = 0
      p-purch-other-rubl     = 0
      p-purch-discnt-base    = 0
      p-purch-discnt-rubl    = 0
    .
    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      define variable v-parts-qnty as decimal   no-undo .
      assign
        v-parts-qnty = buf_parts.fact-qnty
                     * ( if lookup(buf_trn-doc.doc-type, 'рас,спи':U ) > 0
                         then -1
                         else 1
                       )
      .
      find first buf_parts-supp no-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if available buf_parts-supp
      then do:
        assign
          v-price-base     = buf_parts-supp.price-base
          v-price-rubl     = buf_parts-supp.price-rubl
          v-VAT-base       = buf_parts-supp.VAT-base
          v-VAT-rubl       = buf_parts-supp.VAT-rubl
          v-SLT-base       = buf_parts-supp.SLT-base
          v-SLT-rubl       = buf_parts-supp.SLT-rubl
          v-road-tax-base  = buf_parts-supp.road-tax-base
          v-road-tax-rubl  = buf_parts-supp.road-tax-rubl
          v-transport-base = buf_parts-supp.transport-base
          v-transport-rubl = buf_parts-supp.transport-rubl
          v-other-base     = buf_parts-supp.other-base
          v-other-rubl     = buf_parts-supp.other-rubl
        .
      end.
      else do:
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
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
          v-price-base     = price-base-with-tax-loc
          v-price-rubl     = price-rubl-with-tax-loc
          v-VAT-base       = vat-base-loc
          v-VAT-rubl       = vat-rubl-loc
          v-SLT-base       = slt-base-loc
          v-SLT-rubl       = slt-rubl-loc
          v-road-tax-base  = road-tax-base-loc
          v-road-tax-rubl  = road-tax-rubl-loc
          v-transport-base = transport-base-loc
          v-transport-rubl = transport-rubl-loc
          v-other-base     = other-base-loc
          v-other-rubl     = other-rubl-loc
        .
      end.
      assign
        p-fact-qnty            = p-fact-qnty            + v-parts-qnty
        p-purch-sum-base       = p-purch-sum-base       + v-price-base     * v-parts-qnty
        p-purch-sum-rubl       = p-purch-sum-rubl       + v-price-rubl     * v-parts-qnty
        p-purch-VAT-base       = p-purch-VAT-base       + v-VAT-base       * v-parts-qnty
        p-purch-VAT-rubl       = p-purch-VAT-rubl       + v-VAT-rubl       * v-parts-qnty
        p-purch-SLT-base       = p-purch-SLT-base       + v-SLT-base       * v-parts-qnty
        p-purch-SLT-rubl       = p-purch-SLT-rubl       + v-SLT-rubl       * v-parts-qnty
        p-purch-road-tax-base  = p-purch-road-tax-base  + v-road-tax-base  * v-parts-qnty
        p-purch-road-tax-rubl  = p-purch-road-tax-rubl  + v-road-tax-rubl  * v-parts-qnty
        p-purch-excise-base    = p-purch-excise-base    + 0
        p-purch-excise-rubl    = p-purch-excise-rubl    + 0
        p-purch-transport-base = p-purch-transport-base + v-transport-base * v-parts-qnty
        p-purch-transport-rubl = p-purch-transport-rubl + v-transport-rubl * v-parts-qnty
        p-purch-other-base     = p-purch-other-base     + v-other-base     * v-parts-qnty
        p-purch-other-rubl     = p-purch-other-rubl     + v-other-rubl     * v-parts-qnty
        p-purch-discnt-base    = p-purch-discnt-base    + 0
        p-purch-discnt-rubl    = p-purch-discnt-rubl    + 0
      .
    end.
  end.
end procedure.
procedure holdprts-sale-values :
  define input  parameter p-doc-code            like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic               like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type           like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code           like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty           as decimal   no-undo .
  define output parameter p-sale-sum-base       as decimal   no-undo .
  define output parameter p-sale-sum-rubl       as decimal   no-undo .
  define output parameter p-sale-VAT-base       as decimal   no-undo .
  define output parameter p-sale-VAT-rubl       as decimal   no-undo .
  define output parameter p-sale-SLT-base       as decimal   no-undo .
  define output parameter p-sale-SLT-rubl       as decimal   no-undo .
  define output parameter p-sale-road-tax-base  as decimal   no-undo .
  define output parameter p-sale-road-tax-rubl  as decimal   no-undo .
  define output parameter p-sale-excise-base    as decimal   no-undo .
  define output parameter p-sale-excise-rubl    as decimal   no-undo .
  define output parameter p-sale-transport-base as decimal   no-undo .
  define output parameter p-sale-transport-rubl as decimal   no-undo .
  define output parameter p-sale-other-base     as decimal   no-undo .
  define output parameter p-sale-other-rubl     as decimal   no-undo .
  define output parameter p-sale-discnt-base    as decimal   no-undo .
  define output parameter p-sale-discnt-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "holdprts-sale-values-01: параметры продажи товара".
  define variable v-gds-dtl-fact-qnty as decimal   no-undo .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_gds-dtl  for ub.gds-dtl.
  define buffer buf_goods    for ub.goods.
  define buffer buf_trn-doc  for ub.trn-doc.
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
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
    no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      if buf_trn-doc.doc-type <> 'инв':U
      then do:
        if buf_trn-doc.doc-type = 'при':U
        or buf_trn-doc.doc-type = 'возврат':U
        then do:
          assign
            v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
          .
        end.
        else do:
          assign
            v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
          .
        end.
      end.
      else do:
        assign
          v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
        .
      end.
      if v-gds-dtl-fact-qnty <> 0
      then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
        assign
          p-fact-qnty           = p-fact-qnty          + v-gds-dtl-fact-qnty
          p-sale-sum-base       = p-sale-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-sum-rubl       = p-sale-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-vat-base       = p-sale-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
          p-sale-vat-rubl       = p-sale-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-base       = p-sale-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-rubl       = p-sale-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-road-tax-base  = p-sale-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
          p-sale-road-tax-rubl  = p-sale-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
          p-sale-excise-base    = p-sale-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
          p-sale-excise-rubl    = p-sale-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-base    = p-sale-discnt-base   + discnt-base-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-rubl    = p-sale-discnt-rubl   + discnt-rubl-sale          * v-gds-dtl-fact-qnty
        .
      end.
    end.
    assign
      p-sale-transport-base = 0
      p-sale-transport-rubl = 0
      p-sale-other-base     = 0
      p-sale-other-rubl     = 0
    .
  end.
end procedure.
define variable v-start-date as date      no-undo .
define variable v-end-date   as date      no-undo .
define variable v-is-purch   as logical   no-undo .
define variable v-is-sale    as logical   no-undo .
define buffer buf_trn-doc      for ub.trn-doc .
define buffer locked_hold-time for ub.hold-time .
define buffer last_hold-time   for ub.hold-time .
define buffer locked_hold-trn  for ub.hold-trn .
do
on error undo, return error
:
  find first buf_trn-doc share-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code
      view-as alert-box error .
    return error .
  end.
  if buf_trn-doc.status_ <> 'факт':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка расчета межфирменного архива" skip
      "Документ не в статусе" 'факт':U
      "Документ" p-doc-code
      view-as alert-box error .
    return error .
  end.
  run lastdate in this-procedure
    (input buf_trn-doc.fact-date
    ,output v-end-date)
    no-error .
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка поиска последней даты месяца закрытия документа на факт"
    "Документ" p-doc-code skip
    "Факт дата" buf_trn-doc.fact-date
    view-as alert-box error .
    return error.
  end.
  assign
    v-start-date = date(month(buf_trn-doc.fact-date), 1, year(buf_trn-doc.fact-date))
  .
  find first locked_hold-time exclusive-lock
    where locked_hold-time.cat-code = p-cat-code
      and locked_hold-time.time-type = 'мес':U
      and locked_hold-time.start-date = v-start-date
    no-error .
  if not available locked_hold-time
  then do:
    run create-hold-time in this-procedure
      (input p-cat-code
      ,input v-start-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании записи межфирменного архива" skip
        "Документ" buf_trn-doc.doc-code skip
        "cat-code" p-cat-code
        "time-type" 'мес':U
        "start-date" v-start-date
        view-as alert-box error .
      undo, return error .
    end.
    find first locked_hold-time exclusive-lock where
              locked_hold-time.cat-code = p-cat-code AND
              locked_hold-time.time-type = 'мес':U AND
              locked_hold-time.start-date = v-start-date .
  end.
  find first locked_hold-trn exclusive-lock
    where locked_hold-trn.cat-code = p-cat-code
      and locked_hold-trn.doc-code = p-doc-code
      and locked_hold-trn.time-code = locked_hold-time.time-code
    no-error .
  if not available locked_hold-trn
  then do:
    create locked_hold-trn .
    assign
      locked_hold-trn.cat-code = p-cat-code
      locked_hold-trn.doc-code = p-doc-code
      locked_hold-trn.time-code = locked_hold-time.time-code
      locked_hold-trn.is-purch = ?
      locked_hold-trn.is-sale = ?
    .
  end.
  else do:
    undo, return error vss-workfile + vss-revision + chr(10)
      + "Попытка повторного расчета документа" + chr(10)
      + substitute("Категория &1", p-cat-code) + chr(10)
      + substitute("Документ &1", p-doc-code) + chr(10)
      .
  end.
  run holdprts-doc-type in this-procedure
    (input  p-cat-code
    ,input  buf_trn-doc.doc-code
    ,output v-is-sale
    ,output v-is-purch
    ) .
  if v-is-purch
  then do:
    run harh-calc-trn-purch in this-procedure
      (input p-cat-code
      ,input locked_hold-time.time-code
      ,input buf_trn-doc.doc-code
      ,input buf_trn-doc.cli-type
      ,input buf_trn-doc.cli-code
      ) no-error .
    if error-status :error
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка расчета межфирменного архива"
      "Документ закупки" buf_trn-doc.doc-code
      view-as alert-box error .
      undo, return error .
    end.
  end.
  if v-is-sale
  then do:
    run harh-calc-trn-sale in this-procedure
      (input p-cat-code
      ,input locked_hold-time.time-code
      ,input buf_trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка расчета межфирменного архива"
      "Документ продажи" buf_trn-doc.doc-code
      view-as alert-box error .
      undo, return error .
    end.
  end.
  assign
    locked_hold-trn.is-purch = v-is-purch
    locked_hold-trn.is-sale = v-is-sale
  .
end.
procedure harh-calc-trn-purch :
define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
define input parameter p-time-code like ub.hold-time.time-code no-undo .
define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-cli-type like ub.trn-doc.cli-type no-undo .
define input parameter p-cli-code like ub.trn-doc.cli-code no-undo .
DEFINE VARIABLE   v-fact-qnty             like ub.hold-purch.fact-qnty            no-undo .
DEFINE VARIABLE   v-purch-sum-base        like ub.hold-purch.purch-sum-base       no-undo .
DEFINE VARIABLE   v-purch-sum-rubl        like ub.hold-purch.purch-sum-rubl       no-undo .
DEFINE VARIABLE   v-purch-VAT-base        like ub.hold-purch.purch-VAT-base       no-undo .
DEFINE VARIABLE   v-purch-VAT-rubl        like ub.hold-purch.purch-VAT-rubl       no-undo .
DEFINE VARIABLE   v-purch-SLT-base        like ub.hold-purch.purch-SLT-base       no-undo .
DEFINE VARIABLE   v-purch-SLT-rubl        like ub.hold-purch.purch-SLT-rubl       no-undo .
DEFINE VARIABLE   v-purch-road-tax-base   like ub.hold-purch.purch-road-tax-base  no-undo .
DEFINE VARIABLE   v-purch-road-tax-rubl   like ub.hold-purch.purch-road-tax-rubl  no-undo .
DEFINE VARIABLE   v-purch-excise-base     like ub.hold-purch.purch-excise-base    no-undo .
DEFINE VARIABLE   v-purch-excise-rubl     like ub.hold-purch.purch-excise-rubl    no-undo .
DEFINE VARIABLE   v-purch-transport-base  like ub.hold-purch.purch-transport-base no-undo .
DEFINE VARIABLE   v-purch-transport-rubl  like ub.hold-purch.purch-transport-rubl no-undo .
DEFINE VARIABLE   v-purch-other-base      like ub.hold-purch.purch-other-base     no-undo .
DEFINE VARIABLE   v-purch-other-rubl      like ub.hold-purch.purch-other-rubl     no-undo .
DEFINE VARIABLE   v-purch-discnt-base     like ub.hold-purch.purch-discnt-base    no-undo .
DEFINE VARIABLE   v-purch-discnt-rubl     like ub.hold-purch.purch-discnt-rubl    no-undo .
DEFINE VARIABLE   v-node-code like ub.hold-purch-grp.node-code no-undo .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_goods for ub.goods .
define buffer buf_hold-purch for ub.hold-purch.
define buffer buf_hold-purch-grp for ub.hold-purch-grp.
define buffer buf_hold-purch-supp for ub.hold-purch-supp.
define buffer buf_hold-purch-supp-gds for ub.hold-purch-supp-gds.
  do
  on error undo, return error
  :
    for each buf_doc-line no-lock
      where buf_doc-line.doc-code = p-doc-code
    on error undo, return error
    :
      run holdprts-purch-values in this-procedure
        (input  p-doc-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,output v-fact-qnty
        ,output v-purch-sum-base
        ,output v-purch-sum-rubl
        ,output v-purch-VAT-base
        ,output v-purch-VAT-rubl
        ,output v-purch-SLT-base
        ,output v-purch-SLT-rubl
        ,output v-purch-road-tax-base
        ,output v-purch-road-tax-rubl
        ,output v-purch-excise-base
        ,output v-purch-excise-rubl
        ,output v-purch-transport-base
        ,output v-purch-transport-rubl
        ,output v-purch-other-base
        ,output v-purch-other-rubl
        ,output v-purch-discnt-base
        ,output v-purch-discnt-rubl
        ) .
      find first buf_goods no-lock
        where buf_goods.artic = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при заполнении межфирменного архива по строке документа закупки" skip
          "Документ" p-doc-code skip
          "cat-code" p-cat-code skip
          "time-code" p-time-code skip
          "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code
          view-as alert-box error .
        return error .
      end.
      run harh-set-good in this-procedure
        (input p-cat-code
        ,input p-time-code
        ,input buf_goods.gds-code
        ,input buf_goods.grp-name
        ,output v-node-code
        ) no-error .
      if error-status :error
      then do:
        message
        vss-workfile vss-revision vss-description skip
        "Ошибка при регистрации товара в межфирменном архиве" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code SKIP
        "cat-code" p-cat-code SKIP
        "time-code" p-time-code
        view-as alert-box error .
        return error .
      end.
      find first buf_hold-purch exclusive-lock where
                 buf_hold-purch.cat-code = p-cat-code AND
                 buf_hold-purch.time-code = p-time-code AND
                 buf_hold-purch.gds-code = buf_goods.gds-code no-error.
      if not available buf_hold-purch
      then do:
        create buf_hold-purch .
        assign
          buf_hold-purch.cat-code = p-cat-code
          buf_hold-purch.time-code = p-time-code
          buf_hold-purch.gds-code = buf_goods.gds-code
        .
      end.
      assign
        buf_hold-purch.fact-qnty             =  buf_hold-purch.fact-qnty            +  v-fact-qnty
        buf_hold-purch.purch-sum-base        =  buf_hold-purch.purch-sum-base       +  v-purch-sum-base
        buf_hold-purch.purch-sum-rubl        =  buf_hold-purch.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-purch.purch-VAT-base        =  buf_hold-purch.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-purch.purch-VAT-rubl        =  buf_hold-purch.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-purch.purch-SLT-base        =  buf_hold-purch.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-purch.purch-SLT-rubl        =  buf_hold-purch.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-purch.purch-road-tax-base   =  buf_hold-purch.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-purch.purch-road-tax-rubl   =  buf_hold-purch.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-purch.purch-excise-base     =  buf_hold-purch.purch-excise-base    +  v-purch-excise-base
        buf_hold-purch.purch-excise-rubl     =  buf_hold-purch.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-purch.purch-transport-base  =  buf_hold-purch.purch-transport-base +  v-purch-transport-base
        buf_hold-purch.purch-transport-rubl  =  buf_hold-purch.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-purch.purch-other-base      =  buf_hold-purch.purch-other-base     +  v-purch-other-base
        buf_hold-purch.purch-other-rubl      =  buf_hold-purch.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-purch.purch-discnt-base     =  buf_hold-purch.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-purch.purch-discnt-rubl     =  buf_hold-purch.purch-discnt-rubl    +  v-purch-discnt-rubl
      .
      find first buf_hold-purch-grp exclusive-lock where
                 buf_hold-purch-grp.cat-code = p-cat-code AND
                 buf_hold-purch-grp.time-code = p-time-code AND
                 buf_hold-purch-grp.node-code = v-node-code no-error.
      if not available buf_hold-purch-grp
      then do:
        create buf_hold-purch-grp .
        assign
          buf_hold-purch-grp.cat-code = p-cat-code
          buf_hold-purch-grp.time-code = p-time-code
          buf_hold-purch-grp.node-code = v-node-code
        .
      end.
      assign
        buf_hold-purch-grp.fact-qnty             =  buf_hold-purch-grp.fact-qnty            +  v-fact-qnty
        buf_hold-purch-grp.purch-sum-base        =  buf_hold-purch-grp.purch-sum-base       +  v-purch-sum-base
        buf_hold-purch-grp.purch-sum-rubl        =  buf_hold-purch-grp.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-purch-grp.purch-VAT-base        =  buf_hold-purch-grp.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-purch-grp.purch-VAT-rubl        =  buf_hold-purch-grp.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-purch-grp.purch-SLT-base        =  buf_hold-purch-grp.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-purch-grp.purch-SLT-rubl        =  buf_hold-purch-grp.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-purch-grp.purch-road-tax-base   =  buf_hold-purch-grp.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-purch-grp.purch-road-tax-rubl   =  buf_hold-purch-grp.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-purch-grp.purch-excise-base     =  buf_hold-purch-grp.purch-excise-base    +  v-purch-excise-base
        buf_hold-purch-grp.purch-excise-rubl     =  buf_hold-purch-grp.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-purch-grp.purch-transport-base  =  buf_hold-purch-grp.purch-transport-base +  v-purch-transport-base
        buf_hold-purch-grp.purch-transport-rubl  =  buf_hold-purch-grp.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-purch-grp.purch-other-base      =  buf_hold-purch-grp.purch-other-base     +  v-purch-other-base
        buf_hold-purch-grp.purch-other-rubl      =  buf_hold-purch-grp.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-purch-grp.purch-discnt-base     =  buf_hold-purch-grp.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-purch-grp.purch-discnt-rubl     =  buf_hold-purch-grp.purch-discnt-rubl    +  v-purch-discnt-rubl
      .
      find first buf_hold-purch-supp exclusive-lock where
                 buf_hold-purch-supp.cat-code = p-cat-code AND
                 buf_hold-purch-supp.time-code = p-time-code AND
                 buf_hold-purch-supp.cli-type = p-cli-type AND
                 buf_hold-purch-supp.cli-code = p-cli-code
                 no-error.
      if not available buf_hold-purch-supp
      then do:
        create buf_hold-purch-supp .
        assign
          buf_hold-purch-supp.cat-code = p-cat-code
          buf_hold-purch-supp.time-code = p-time-code
          buf_hold-purch-supp.cli-type = p-cli-type
          buf_hold-purch-supp.cli-code = p-cli-code
        .
      end.
      assign
        buf_hold-purch-supp.fact-qnty             =  buf_hold-purch-supp.fact-qnty            +  v-fact-qnty
        buf_hold-purch-supp.purch-sum-base        =  buf_hold-purch-supp.purch-sum-base       +  v-purch-sum-base
        buf_hold-purch-supp.purch-sum-rubl        =  buf_hold-purch-supp.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-purch-supp.purch-VAT-base        =  buf_hold-purch-supp.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-purch-supp.purch-VAT-rubl        =  buf_hold-purch-supp.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-purch-supp.purch-SLT-base        =  buf_hold-purch-supp.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-purch-supp.purch-SLT-rubl        =  buf_hold-purch-supp.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-purch-supp.purch-road-tax-base   =  buf_hold-purch-supp.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-purch-supp.purch-road-tax-rubl   =  buf_hold-purch-supp.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-purch-supp.purch-excise-base     =  buf_hold-purch-supp.purch-excise-base    +  v-purch-excise-base
        buf_hold-purch-supp.purch-excise-rubl     =  buf_hold-purch-supp.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-purch-supp.purch-transport-base  =  buf_hold-purch-supp.purch-transport-base +  v-purch-transport-base
        buf_hold-purch-supp.purch-transport-rubl  =  buf_hold-purch-supp.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-purch-supp.purch-other-base      =  buf_hold-purch-supp.purch-other-base     +  v-purch-other-base
        buf_hold-purch-supp.purch-other-rubl      =  buf_hold-purch-supp.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-purch-supp.purch-discnt-base     =  buf_hold-purch-supp.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-purch-supp.purch-discnt-rubl     =  buf_hold-purch-supp.purch-discnt-rubl    +  v-purch-discnt-rubl
      .
      find first buf_hold-purch-supp-gds exclusive-lock where
                 buf_hold-purch-supp-gds.cat-code = p-cat-code AND
                 buf_hold-purch-supp-gds.time-code = p-time-code AND
                 buf_hold-purch-supp-gds.gds-code = buf_goods.gds-code AND
                 buf_hold-purch-supp-gds.cli-type = p-cli-type AND
                 buf_hold-purch-supp-gds.cli-code = p-cli-code
                 no-error.
      if not available buf_hold-purch-supp-gds
      then do:
        create buf_hold-purch-supp-gds .
        assign
          buf_hold-purch-supp-gds.cat-code = p-cat-code
          buf_hold-purch-supp-gds.time-code = p-time-code
          buf_hold-purch-supp-gds.cli-type = p-cli-type
          buf_hold-purch-supp-gds.cli-code = p-cli-code
          buf_hold-purch-supp-gds.gds-code = buf_goods.gds-code
        .
      end.
      assign
        buf_hold-purch-supp-gds.fact-qnty             =  buf_hold-purch-supp-gds.fact-qnty            +  v-fact-qnty
        buf_hold-purch-supp-gds.purch-sum-base        =  buf_hold-purch-supp-gds.purch-sum-base       +  v-purch-sum-base
        buf_hold-purch-supp-gds.purch-sum-rubl        =  buf_hold-purch-supp-gds.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-purch-supp-gds.purch-VAT-base        =  buf_hold-purch-supp-gds.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-purch-supp-gds.purch-VAT-rubl        =  buf_hold-purch-supp-gds.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-purch-supp-gds.purch-SLT-base        =  buf_hold-purch-supp-gds.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-purch-supp-gds.purch-SLT-rubl        =  buf_hold-purch-supp-gds.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-purch-supp-gds.purch-road-tax-base   =  buf_hold-purch-supp-gds.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-purch-supp-gds.purch-road-tax-rubl   =  buf_hold-purch-supp-gds.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-purch-supp-gds.purch-excise-base     =  buf_hold-purch-supp-gds.purch-excise-base    +  v-purch-excise-base
        buf_hold-purch-supp-gds.purch-excise-rubl     =  buf_hold-purch-supp-gds.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-purch-supp-gds.purch-transport-base  =  buf_hold-purch-supp-gds.purch-transport-base +  v-purch-transport-base
        buf_hold-purch-supp-gds.purch-transport-rubl  =  buf_hold-purch-supp-gds.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-purch-supp-gds.purch-other-base      =  buf_hold-purch-supp-gds.purch-other-base     +  v-purch-other-base
        buf_hold-purch-supp-gds.purch-other-rubl      =  buf_hold-purch-supp-gds.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-purch-supp-gds.purch-discnt-base     =  buf_hold-purch-supp-gds.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-purch-supp-gds.purch-discnt-rubl     =  buf_hold-purch-supp-gds.purch-discnt-rubl    +  v-purch-discnt-rubl
      .
    end.
  end.
end procedure.
procedure harh-calc-trn-sale :
  define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
  define input parameter p-time-code like ub.hold-time.time-code no-undo .
  define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .
  define variable   v-fact-qnty             like ub.hold-sale.fact-qnty            no-undo .
  define variable   v-sale-sum-base         like ub.hold-sale.purch-sum-base       no-undo .
  define variable   v-sale-sum-rubl         like ub.hold-sale.sale-sum-rubl        no-undo .
  define variable   v-sale-vat-base         like ub.hold-sale.sale-vat-base        no-undo .
  define variable   v-sale-vat-rubl         like ub.hold-sale.sale-vat-rubl        no-undo .
  define variable   v-sale-slt-base         like ub.hold-sale.sale-slt-base        no-undo .
  define variable   v-sale-slt-rubl         like ub.hold-sale.sale-slt-rubl        no-undo .
  define variable   v-sale-road-tax-base    like ub.hold-sale.sale-road-tax-base   no-undo .
  define variable   v-sale-road-tax-rubl    like ub.hold-sale.sale-road-tax-rubl   no-undo .
  define variable   v-sale-excise-base      like ub.hold-sale.sale-excise-base     no-undo .
  define variable   v-sale-excise-rubl      like ub.hold-sale.sale-excise-rubl     no-undo .
  define variable   v-sale-transport-base   like ub.hold-sale.sale-transport-base  no-undo .
  define variable   v-sale-transport-rubl   like ub.hold-sale.sale-transport-rubl  no-undo .
  define variable   v-sale-other-base       like ub.hold-sale.sale-other-base      no-undo .
  define variable   v-sale-other-rubl       like ub.hold-sale.sale-other-rubl      no-undo .
  define variable   v-sale-discnt-base      like ub.hold-sale.sale-discnt-base     no-undo .
  define variable   v-sale-discnt-rubl      like ub.hold-sale.sale-discnt-rubl     no-undo .
  define variable   v-purch-sum-base        like ub.hold-sale.purch-sum-base       no-undo .
  define variable   v-purch-sum-rubl        like ub.hold-sale.purch-sum-rubl       no-undo .
  define variable   v-purch-vat-base        like ub.hold-sale.purch-vat-base       no-undo .
  define variable   v-purch-vat-rubl        like ub.hold-sale.purch-vat-rubl       no-undo .
  define variable   v-purch-slt-base        like ub.hold-sale.purch-slt-base       no-undo .
  define variable   v-purch-slt-rubl        like ub.hold-sale.purch-slt-rubl       no-undo .
  define variable   v-purch-road-tax-base   like ub.hold-sale.purch-road-tax-base  no-undo .
  define variable   v-purch-road-tax-rubl   like ub.hold-sale.purch-road-tax-rubl  no-undo .
  define variable   v-purch-excise-base     like ub.hold-sale.purch-excise-base    no-undo .
  define variable   v-purch-excise-rubl     like ub.hold-sale.purch-excise-rubl    no-undo .
  define variable   v-purch-transport-base  like ub.hold-sale.purch-transport-base no-undo .
  define variable   v-purch-transport-rubl  like ub.hold-sale.purch-transport-rubl no-undo .
  define variable   v-purch-other-base      like ub.hold-sale.purch-other-base     no-undo .
  define variable   v-purch-other-rubl      like ub.hold-sale.purch-other-rubl     no-undo .
  define variable   v-purch-discnt-base     like ub.hold-sale.purch-discnt-base    no-undo .
  define variable   v-purch-discnt-rubl     like ub.hold-sale.purch-discnt-rubl    no-undo .
  define variable   v-profit-base           like ub.hold-sale.profit-base          no-undo .
  define variable   v-profit-rubl           like ub.hold-sale.profit-rubl          no-undo .
  define variable   v-node-code like ub.hold-purch-grp.node-code no-undo .
  define buffer buf_goods for ub.goods .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_hold-sale for ub.hold-sale .
  define buffer buf_hold-sale-grp for ub.hold-sale-grp .
  do
  on error undo, return error
  :
    for each buf_doc-line no-lock
      where buf_doc-line.doc-code = p-doc-code
    on error undo, return error
    :
      run holdprts-purch-values in this-procedure
        (input  p-doc-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,output v-fact-qnty
        ,output v-purch-sum-base
        ,output v-purch-sum-rubl
        ,output v-purch-VAT-base
        ,output v-purch-VAT-rubl
        ,output v-purch-SLT-base
        ,output v-purch-SLT-rubl
        ,output v-purch-road-tax-base
        ,output v-purch-road-tax-rubl
        ,output v-purch-excise-base
        ,output v-purch-excise-rubl
        ,output v-purch-transport-base
        ,output v-purch-transport-rubl
        ,output v-purch-other-base
        ,output v-purch-other-rubl
        ,output v-purch-discnt-base
        ,output v-purch-discnt-rubl
        ) .
      run holdprts-sale-values in this-procedure
        (input  p-doc-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,output v-fact-qnty
        ,output v-sale-sum-base
        ,output v-sale-sum-rubl
        ,output v-sale-VAT-base
        ,output v-sale-VAT-rubl
        ,output v-sale-SLT-base
        ,output v-sale-SLT-rubl
        ,output v-sale-road-tax-base
        ,output v-sale-road-tax-rubl
        ,output v-sale-excise-base
        ,output v-sale-excise-rubl
        ,output v-sale-transport-base
        ,output v-sale-transport-rubl
        ,output v-sale-other-base
        ,output v-sale-other-rubl
        ,output v-sale-discnt-base
        ,output v-sale-discnt-rubl
        ) .
      find first buf_goods no-lock
        where buf_goods.artic = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при заполнении межфирменного архива по строке документа продажи" skip
          "Документ" p-doc-code skip
          "cat-code" p-cat-code skip
          "time-code" p-time-code skip
          "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code
          view-as alert-box error .
        return error .
      end.
      run harh-set-good in this-procedure
        (input p-cat-code
        ,input p-time-code
        ,input buf_goods.gds-code
        ,input buf_goods.grp-name
        ,output v-node-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при регистрации товара в межфирменном архиве" skip
          "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code SKIP
          "cat-code" p-cat-code SKIP
          "time-code" p-time-code
          view-as alert-box error .
        return error .
      end.
      find first buf_hold-sale exclusive-lock
        where buf_hold-sale.cat-code  = p-cat-code
          and buf_hold-sale.time-code = p-time-code
          and buf_hold-sale.gds-code  = buf_goods.gds-code
        no-error .
      if not available buf_hold-sale
      then do:
        create buf_hold-sale .
        assign
          buf_hold-sale.cat-code  = p-cat-code
          buf_hold-sale.time-code = p-time-code
          buf_hold-sale.gds-code  = buf_goods.gds-code
        .
      end.
      assign
        buf_hold-sale.fact-qnty            = buf_hold-sale.fact-qnty            + v-fact-qnty
        buf_hold-sale.purch-sum-base       = buf_hold-sale.purch-sum-base       + v-purch-sum-base
        buf_hold-sale.purch-sum-rubl       = buf_hold-sale.purch-sum-rubl       + v-purch-sum-rubl
        buf_hold-sale.purch-VAT-base       = buf_hold-sale.purch-VAT-base       + v-purch-VAT-base
        buf_hold-sale.purch-VAT-rubl       = buf_hold-sale.purch-VAT-rubl       + v-purch-VAT-rubl
        buf_hold-sale.purch-SLT-base       = buf_hold-sale.purch-SLT-base       + v-purch-SLT-base
        buf_hold-sale.purch-SLT-rubl       = buf_hold-sale.purch-SLT-rubl       + v-purch-SLT-rubl
        buf_hold-sale.purch-road-tax-base  = buf_hold-sale.purch-road-tax-base  + v-purch-road-tax-base
        buf_hold-sale.purch-road-tax-rubl  = buf_hold-sale.purch-road-tax-rubl  + v-purch-road-tax-rubl
        buf_hold-sale.purch-excise-base    = buf_hold-sale.purch-excise-base    + v-purch-excise-base
        buf_hold-sale.purch-excise-rubl    = buf_hold-sale.purch-excise-rubl    + v-purch-excise-rubl
        buf_hold-sale.purch-transport-base = buf_hold-sale.purch-transport-base + v-purch-transport-base
        buf_hold-sale.purch-transport-rubl = buf_hold-sale.purch-transport-rubl + v-purch-transport-rubl
        buf_hold-sale.purch-other-base     = buf_hold-sale.purch-other-base     + v-purch-other-base
        buf_hold-sale.purch-other-rubl     = buf_hold-sale.purch-other-rubl     + v-purch-other-rubl
        buf_hold-sale.purch-discnt-base    = buf_hold-sale.purch-discnt-base    + v-purch-discnt-base
        buf_hold-sale.purch-discnt-rubl    = buf_hold-sale.purch-discnt-rubl    + v-purch-discnt-rubl
        buf_hold-sale.sale-sum-base        = buf_hold-sale.sale-sum-base        + v-sale-sum-base
        buf_hold-sale.sale-sum-rubl        = buf_hold-sale.sale-sum-rubl        + v-sale-sum-rubl
        buf_hold-sale.sale-VAT-base        = buf_hold-sale.sale-VAT-base        + v-sale-VAT-base
        buf_hold-sale.sale-VAT-rubl        = buf_hold-sale.sale-VAT-rubl        + v-sale-VAT-rubl
        buf_hold-sale.sale-SLT-base        = buf_hold-sale.sale-SLT-base        + v-sale-SLT-base
        buf_hold-sale.sale-SLT-rubl        = buf_hold-sale.sale-SLT-rubl        + v-sale-SLT-rubl
        buf_hold-sale.sale-road-tax-base   = buf_hold-sale.sale-road-tax-base   + v-sale-road-tax-base
        buf_hold-sale.sale-road-tax-rubl   = buf_hold-sale.sale-road-tax-rubl   + v-sale-road-tax-rubl
        buf_hold-sale.sale-excise-base     = buf_hold-sale.sale-excise-base     + v-sale-excise-base
        buf_hold-sale.sale-excise-rubl     = buf_hold-sale.sale-excise-rubl     + v-sale-excise-rubl
        buf_hold-sale.sale-transport-base  = buf_hold-sale.sale-transport-base  + v-sale-transport-base
        buf_hold-sale.sale-transport-rubl  = buf_hold-sale.sale-transport-rubl  + v-sale-transport-rubl
        buf_hold-sale.sale-other-base      = buf_hold-sale.sale-other-base      + v-sale-other-base
        buf_hold-sale.sale-other-rubl      = buf_hold-sale.sale-other-rubl      + v-sale-other-rubl
        buf_hold-sale.sale-discnt-base     = buf_hold-sale.sale-discnt-base     + v-sale-discnt-base
        buf_hold-sale.sale-discnt-rubl     = buf_hold-sale.sale-discnt-rubl     + v-sale-discnt-rubl
        buf_hold-sale.profit-base          = buf_hold-sale.profit-base          + v-profit-base
        buf_hold-sale.profit-rubl          = buf_hold-sale.profit-rubl          + v-profit-rubl
      .
      find first buf_hold-sale-grp exclusive-lock where
                 buf_hold-sale-grp.cat-code = p-cat-code AND
                 buf_hold-sale-grp.time-code = p-time-code AND
                 buf_hold-sale-grp.node-code = v-node-code no-error.
      if not available buf_hold-sale-grp
      then do:
        create buf_hold-sale-grp .
        assign
          buf_hold-sale-grp.cat-code = p-cat-code
          buf_hold-sale-grp.time-code = p-time-code
          buf_hold-sale-grp.node-code = v-node-code
        .
      end.
      assign
        buf_hold-sale-grp.fact-qnty             =  buf_hold-sale-grp.fact-qnty            +  v-fact-qnty
        buf_hold-sale-grp.purch-sum-base        =  buf_hold-sale-grp.purch-sum-base       +  v-purch-sum-base
        buf_hold-sale-grp.purch-sum-rubl        =  buf_hold-sale-grp.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-sale-grp.purch-VAT-base        =  buf_hold-sale-grp.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-sale-grp.purch-VAT-rubl        =  buf_hold-sale-grp.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-sale-grp.purch-SLT-base        =  buf_hold-sale-grp.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-sale-grp.purch-SLT-rubl        =  buf_hold-sale-grp.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-sale-grp.purch-road-tax-base   =  buf_hold-sale-grp.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-sale-grp.purch-road-tax-rubl   =  buf_hold-sale-grp.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-sale-grp.purch-excise-base     =  buf_hold-sale-grp.purch-excise-base    +  v-purch-excise-base
        buf_hold-sale-grp.purch-excise-rubl     =  buf_hold-sale-grp.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-sale-grp.purch-transport-base  =  buf_hold-sale-grp.purch-transport-base +  v-purch-transport-base
        buf_hold-sale-grp.purch-transport-rubl  =  buf_hold-sale-grp.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-sale-grp.purch-other-base      =  buf_hold-sale-grp.purch-other-base     +  v-purch-other-base
        buf_hold-sale-grp.purch-other-rubl      =  buf_hold-sale-grp.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-sale-grp.purch-discnt-base     =  buf_hold-sale-grp.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-sale-grp.purch-discnt-rubl     =  buf_hold-sale-grp.purch-discnt-rubl    +  v-purch-discnt-rubl
        buf_hold-sale-grp.sale-sum-base         =  buf_hold-sale-grp.sale-sum-base        +  v-sale-sum-base
        buf_hold-sale-grp.sale-sum-rubl         =  buf_hold-sale-grp.sale-sum-rubl        +  v-sale-sum-rubl
        buf_hold-sale-grp.sale-VAT-base         =  buf_hold-sale-grp.sale-VAT-base        +  v-sale-VAT-base
        buf_hold-sale-grp.sale-VAT-rubl         =  buf_hold-sale-grp.sale-VAT-rubl        +  v-sale-VAT-rubl
        buf_hold-sale-grp.sale-SLT-base         =  buf_hold-sale-grp.sale-SLT-base        +  v-sale-SLT-base
        buf_hold-sale-grp.sale-SLT-rubl         =  buf_hold-sale-grp.sale-SLT-rubl        +  v-sale-SLT-rubl
        buf_hold-sale-grp.sale-road-tax-base    =  buf_hold-sale-grp.sale-road-tax-base   +  v-sale-road-tax-base
        buf_hold-sale-grp.sale-road-tax-rubl    =  buf_hold-sale-grp.sale-road-tax-rubl   +  v-sale-road-tax-rubl
        buf_hold-sale-grp.sale-excise-base      =  buf_hold-sale-grp.sale-excise-base     +  v-sale-excise-base
        buf_hold-sale-grp.sale-excise-rubl      =  buf_hold-sale-grp.sale-excise-rubl     +  v-sale-excise-rubl
        buf_hold-sale-grp.sale-transport-base   =  buf_hold-sale-grp.sale-transport-base  +  v-sale-transport-base
        buf_hold-sale-grp.sale-transport-rubl   =  buf_hold-sale-grp.sale-transport-rubl  +  v-sale-transport-rubl
        buf_hold-sale-grp.sale-other-base       =  buf_hold-sale-grp.sale-other-base      +  v-sale-other-base
        buf_hold-sale-grp.sale-other-rubl       =  buf_hold-sale-grp.sale-other-rubl      +  v-sale-other-rubl
        buf_hold-sale-grp.sale-discnt-base      =  buf_hold-sale-grp.sale-discnt-base     +  v-sale-discnt-base
        buf_hold-sale-grp.sale-discnt-rubl      =  buf_hold-sale-grp.sale-discnt-rubl     +  v-sale-discnt-rubl
        buf_hold-sale-grp.profit-base           =  buf_hold-sale-grp.profit-base          +  v-profit-base
        buf_hold-sale-grp.profit-rubl           =  buf_hold-sale-grp.profit-rubl          +  v-profit-rubl
      .
    end.
  end.
end procedure.
procedure harh-set-good :
  define input  parameter p-cat-code  like ub.hold-time.cat-code no-undo .
  define input  parameter p-time-code like ub.hold-time.time-code no-undo .
  define input  parameter p-gds-code  like ub.goods.gds-code no-undo .
  define input  parameter p-grp-name  like ub.goods.grp-name no-undo .
  define output parameter p-node-code like ub.hold-gds-grp.node-code no-undo .
  define variable v-grp-name like ub.hold-gds-grp.grp-name no-undo .
  define variable v-node-name like ub.hold-gds-grp.node-name no-undo .
  define variable v-upper-code like ub.hold-gds-grp.upper-code no-undo .
  define variable v-node-code like ub.hold-gds-grp.node-code no-undo .
  define variable v-ii as integer no-undo .
  define variable v-is-term like ub.hold-gds-grp.is-term no-undo .
  define variable v-num-entries as integer no-undo .
  define buffer locked_hold-goods for ub.hold-goods .
  define buffer locked_hold-gds-grp for ub.hold-gds-grp .
  do
  on error undo, return error
  :
    find first locked_hold-goods exclusive-lock
      where locked_hold-goods.cat-code = p-cat-code
        and locked_hold-goods.time-code = p-time-code
        and locked_hold-goods.gds-code = p-gds-code
      no-error .
    if available locked_hold-goods
    then do:
    end.
    else do:
      create locked_hold-goods .
      assign
        locked_hold-goods.cat-code = p-cat-code
        locked_hold-goods.time-code = p-time-code
        locked_hold-goods.gds-code = p-gds-code
        locked_hold-goods.grp-name = p-grp-name
      .
    end.
    assign
      v-num-entries = num-entries(right-trim(p-grp-name, chr(47)), chr(47))
    .
    do v-ii = 1 to v-num-entries
    on error undo, return error
    :
      assign
        v-node-name = entry(v-ii, p-grp-name, chr(47))
        v-grp-name = v-grp-name + (if v-grp-name = "":U
                                  then "":U
                                  else chr(47)) +
                    entry(v-ii, p-grp-name, chr(47))
        v-is-term = (if v-ii = v-num-entries
                    then yes
                    else no)
      .
      run harh-create-grp-node in this-procedure
        (input p-cat-code
        ,input p-time-code
        ,input v-node-name
        ,input v-grp-name
        ,input v-upper-code
        ,input-output v-node-code
        ,input v-is-term
        ) no-error.
      if error-status :error
      then do:
        message
        vss-workfile vss-revision vss-description skip
        "Ошибка при заполнении межфирменных архивов" SKIP
        "Группа товаров" p-grp-name
        view-as alert-box error .
        return error .
      end.
      assign
        v-upper-code = v-node-code
      .
    end.
    assign
      locked_hold-goods.node-code = v-node-code
      p-node-code                 = v-node-code
    .
  end.
end procedure.
procedure harh-create-grp-node :
  define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
  define input parameter p-time-code like ub.hold-time.time-code no-undo .
  define input parameter p-node-name like ub.hold-gds-grp.node-name no-undo .
  define input parameter p-grp-name like ub.hold-gds-grp.grp-name no-undo .
  define input parameter p-upper-code like ub.hold-gds-grp.upper-code no-undo .
  define input-output parameter p-node-code like ub.hold-gds-grp.node-code no-undo .
  define input parameter p-is-term like ub.hold-gds-grp.is-term no-undo .
  define buffer locked_hold-gds-grp for ub.hold-gds-grp .
  define buffer last_hold-gds-grp for ub.hold-gds-grp.
  do
  on error undo, return error
  :
    find first locked_hold-gds-grp exclusive-lock
      where locked_hold-gds-grp.cat-code = p-cat-code
        and locked_hold-gds-grp.time-code = p-time-code
        and locked_hold-gds-grp.node-name = p-node-name
        and locked_hold-gds-grp.upper-code = p-upper-code
      no-error .
    if available locked_hold-gds-grp
    then do:
      assign
        p-node-code = locked_hold-gds-grp.node-code
      .
      return.
    end.
    else do:
      find last last_hold-gds-grp no-lock
        where last_hold-gds-grp.cat-code = p-cat-code
          and last_hold-gds-grp.time-code = p-time-code
        use-index pi
        no-error .
      create locked_hold-gds-grp .
      assign
        locked_hold-gds-grp.cat-code = p-cat-code
        locked_hold-gds-grp.time-code = p-time-code
        locked_hold-gds-grp.node-name = p-node-name
        locked_hold-gds-grp.grp-name = right-trim(p-grp-name, chr(47)) + chr(47)
        locked_hold-gds-grp.upper-code = p-upper-code
        locked_hold-gds-grp.node-code = (if available last_hold-gds-grp
                                          then (last_hold-gds-grp.node-code + 1)
                                          else 1
                                          )
        locked_hold-gds-grp.is-term = p-is-term
        p-node-code = locked_hold-gds-grp.node-code
      .
    end.
  end.
end procedure.
