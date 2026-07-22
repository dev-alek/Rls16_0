block-level on error undo, throw.
define input parameter v-doc-code like ub.trn-doc.doc-code no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание документов межфирменного перемещения":U .
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
      p-vss-parameters = substitute('&1':u,v-doc-code)
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        vss-include-info1 skip
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
          vss-include-info1 skip
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
            vss-include-info1 skip
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
        vss-include-info1 skip
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
        vss-include-info1 skip
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
        vss-include-info1 skip
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
          vss-include-info1 skip
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
          vss-include-info1 skip
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
          vss-include-info1 skip
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
        vss-include-info1 skip
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                vss-include-info1 skip
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
        vss-include-info1 skip
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
        vss-include-info1 skip
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
        vss-include-info1 skip
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
        vss-include-info1 skip
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure hold-ret :
  define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
  define buffer bf_trn-doc    for ub.trn-doc.
  define buffer bf_doc-line   for ub.doc-line.
  define buffer bf_gds-dtl    for ub.gds-dtl.
  define buffer bf_parts      for ub.parts.
  define buffer bf_goods      for ub.goods.
  define buffer bf_sysconf    for ub.sysconf.
  define buffer bf_parts-supp for ub.parts-supp.
  define buffer bf-in_trn-doc for ub.trn-doc.
  define buffer bf-orig_parts for ub.parts.
  define variable vartotal-parts-qnty   like ub.parts.fact-qnty      no-undo.
  define variable vartotal-price-base   like ub.parts.price-base     no-undo.
  define variable vartotal-price-rubl   like ub.parts.price-rubl     no-undo.
  define variable vartotal-road-tax     like ub.parts.road-tax-base  no-undo.
  define variable cli_doc-prt           as   logical                 no-undo.
  define variable obj_doc-prt           as   logical                 no-undo.
  define variable varprt-create-n-c     like ub.gds-prt.node-code    no-undo.
  define variable vargds-dtl-chg-qnty   as   decimal                 no-undo.
  define variable vartotal-gds-dtl-qnty as   decimal                 no-undo.
  define variable varcreate-n-c         like ub.gds-prt.node-code    no-undo.
  define variable varcash-pay           like ub.sysconf.cash-pay     no-undo.
  define variable varr-b                as   character               no-undo.
do transaction on error undo, return error return-value :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
if not available bf_trn-doc then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
for each lib-trn_ret-line on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = lib-trn_ret-line.artic     and
                            bf_goods.prod-type = lib-trn_ret-line.prod-type and
                            bf_goods.prod-code = lib-trn_ret-line.prod-code no-lock.
  create bf_doc-line.
  assign
    bf_doc-line.doc-code       = bf_trn-doc.doc-code
    bf_doc-line.obj-type       = bf_trn-doc.obj-type
    bf_doc-line.obj-code       = bf_trn-doc.obj-code
    bf_doc-line.artic          = lib-trn_ret-line.artic
    bf_doc-line.prod-type      = lib-trn_ret-line.prod-type
    bf_doc-line.prod-code      = lib-trn_ret-line.prod-code
    bf_doc-line.cli-qnty       = lib-trn_ret-line.cli-qnty
    bf_doc-line.doc-qnty       = lib-trn_ret-line.doc-qnty
    bf_doc-line.fact-qnty      = lib-trn_ret-line.fact-qnty
    bf_doc-line.SLT-pc         = lib-trn_ret-line.slt-pc
    bf_doc-line.VAT-pc         = lib-trn_ret-line.vat-pc
    bf_doc-line.cons-vat-pc    = lib-trn_ret-line.cons-vat-pc
    bf_doc-line.cons-slt-pc    = lib-trn_ret-line.cons-slt-pc
    bf_doc-line.transport-base = 0
    bf_doc-line.transport-rubl = 0
    bf_doc-line.other-base     = 0
    bf_doc-line.other-rubl     = 0
    bf_doc-line.unit-cli       = lib-trn_ret-line.unit-cli
    bf_doc-line.prt-root       = lib-trn_ret-line.prt-root
    bf_doc-line.prt-OK         = yes
    bf_doc-line.fact-order     = 0
    bf_doc-line.cli-base-rate  = lib-trn_ret-line.cli-base-rate
    bf_doc-line.doc-density    = lib-trn_ret-line.fact-density
    bf_doc-line.fact-density   = lib-trn_ret-line.fact-density
    bf_doc-line.num-place      = lib-trn_ret-line.num-place
    bf_doc-line.wt-brutto      = lib-trn_ret-line.wt-brutto.
  for each lib-trn_ret-parts
    where lib-trn_ret-parts.obj-type  = lib-trn_ret-line.obj-type
      and lib-trn_ret-parts.obj-code  = lib-trn_ret-line.obj-code
      and lib-trn_ret-parts.artic     = lib-trn_ret-line.artic
      and lib-trn_ret-parts.prod-type = lib-trn_ret-line.prod-type
      and lib-trn_ret-parts.prod-code = lib-trn_ret-line.prod-code
      and lib-trn_ret-parts.out-code  = lib-trn_ret-line.doc-code
    on error undo, return error return-value
    :
    if lib-trn_ret-parts.fact-qnty < 0 then do:
       undo, return error "В документе межфирменного перемещения. Фактическое количество в партии не может быть отрицательным." .
    end.
    find first bf_parts-supp where bf_parts-supp.in-code   = lib-trn_ret-parts.in-code   and
                                   bf_parts-supp.artic     = lib-trn_ret-parts.artic     and
                                   bf_parts-supp.prod-type = lib-trn_ret-parts.prod-type and
                                   bf_parts-supp.prod-code = lib-trn_ret-parts.prod-code and
                                   bf_parts-supp.part-code = lib-trn_ret-parts.part-code no-error.
    if not available bf_parts-supp then do:
      undo, return error substitute ("Не найдена информация о поставщике по партии &1 &2 &3 &4 &5.",
                                     lib-trn_ret-parts.in-code  ,
                                     lib-trn_ret-parts.artic    ,
                                     lib-trn_ret-parts.prod-type,
                                     lib-trn_ret-parts.prod-code,
                                     lib-trn_ret-parts.part-code ).
    end.
    find first bf-in_trn-doc where bf-in_trn-doc.doc-code = lib-trn_ret-parts.in-code no-lock no-error.
    if not available bf-in_trn-doc then do:
      undo, return error substitute ("Не найден документ с номером &1 породивший партию документа &2.", lib-trn_ret-parts.in-code, bf_trn-doc.doc-code).
    end.
    find first bf-orig_parts  where bf-orig_parts.obj-type  = bf_trn-doc.obj-type                and
                                    bf-orig_parts.obj-code  = bf_trn-doc.obj-code                and
                                    bf-orig_parts.artic     = bf_parts-supp.artic                and
                                    bf-orig_parts.prod-type = bf_parts-supp.prod-type            and
                                    bf-orig_parts.prod-code = bf_parts-supp.prod-code            and
                                    bf-orig_parts.in-code   = bf_parts-supp.orig-in-code         and
                                    bf-orig_parts.out-code  = bf-in_trn-doc.hold-doc-code-parent and
                                    bf-orig_parts.part-code = bf_parts-supp.orig-part-code       no-error.
    if not available bf-orig_parts then do:
      undo, return error substitute ("Для формирования документа необходимо наличие партии документа межфирменного расхода на наш объект. Не найдена партия: объект &1 &2 товар &3 &4 &5 документ &6 партия &7 &8.",
                                     bf_trn-doc.obj-type,
                                     bf_trn-doc.obj-code,
                                     bf_parts-supp.artic,
                                     bf_parts-supp.prod-type,
                                     bf_parts-supp.prod-code,
                                     bf-in_trn-doc.hold-doc-code-parent,
                                     bf_parts-supp.orig-in-code,
                                     bf_parts-supp.orig-part-code).
    end.
    find first bf_parts where bf_parts.obj-type  = bf-orig_parts.obj-type
                          and bf_parts.obj-code  = bf-orig_parts.obj-code
                          and bf_parts.artic     = bf-orig_parts.artic
                          and bf_parts.prod-type = bf-orig_parts.prod-type
                          and bf_parts.prod-code = bf-orig_parts.prod-code
                          and bf_parts.in-code   = bf-orig_parts.in-code
                          and bf_parts.out-code  = bf_trn-doc.doc-code
                          and bf_parts.part-code = bf-orig_parts.part-code no-error.
    if not available bf_parts then do:
      create bf_parts .
      assign
        bf_parts.obj-type        = bf-orig_parts.obj-type
        bf_parts.obj-code        = bf-orig_parts.obj-code
        bf_parts.artic           = bf-orig_parts.artic
        bf_parts.prod-type       = bf-orig_parts.prod-type
        bf_parts.prod-code       = bf-orig_parts.prod-code
        bf_parts.in-code         = bf-orig_parts.in-code
        bf_parts.out-code        = bf_trn-doc.doc-code
        bf_parts.part-code       = bf-orig_parts.part-code
        bf_parts.price-base      = bf-orig_parts.price-base
        bf_parts.price-rubl      = bf-orig_parts.price-rubl
        bf_parts.vat-pc          = bf-orig_parts.vat-pc
        bf_parts.pay-code        = bf-orig_parts.pay-code
        bf_parts.status_         = no
        bf_parts.supp-type       = bf-orig_parts.supp-type
        bf_parts.supp-code       = bf-orig_parts.supp-code
        bf_parts.rsrv-free       = ?
        bf_parts.doc-type        = bf_trn-doc.doc-type
        bf_parts.pl-code         = bf-orig_parts.pl-code
        bf_parts.vat-type        = bf-orig_parts.vat-type
        bf_parts.exch-code       = bf-orig_parts.exch-code
        bf_parts.price-cli       = bf-orig_parts.price-cli
        bf_parts.cli-base-rate   = bf-orig_parts.cli-base-rate
        bf_parts.slt-pc          = bf-orig_parts.slt-pc
        bf_parts.host-code       = bf-orig_parts.host-code
        bf_parts.is-supp         = bf-orig_parts.is-supp
        bf_parts.slt-type        = bf-orig_parts.slt-type
        bf_parts.cst-code        = bf-orig_parts.cst-code
        bf_parts.last-date       = bf-orig_parts.last-date
        bf_parts.road-tax-base   = bf-orig_parts.road-tax-base
        bf_parts.road-tax-rubl   = bf-orig_parts.road-tax-rubl
        bf_parts.transport-base  = bf-orig_parts.transport-base
        bf_parts.transport-rubl  = bf-orig_parts.transport-rubl
        bf_parts.other-base      = bf-orig_parts.other-base
        bf_parts.other-rubl      = bf-orig_parts.other-rubl
        bf_parts.purch-code      = bf-orig_parts.purch-code
        bf_parts.cli-qnty        = lib-trn_ret-parts.cli-qnty
        bf_parts.real-qnty       = bf-orig_parts.real-qnty
        bf_parts.qnty            = lib-trn_ret-parts.qnty
        bf_parts.fact-qnty       = lib-trn_ret-parts.fact-qnty
        .
    end.
    else do:
      assign
        bf_parts.cli-qnty        = bf_parts.cli-qnty  + lib-trn_ret-parts.cli-qnty
        bf_parts.real-qnty       = bf_parts.real-qnty + bf-orig_parts.real-qnty
        bf_parts.qnty            = bf_parts.qnty      + lib-trn_ret-parts.qnty
        bf_parts.fact-qnty       = bf_parts.fact-qnty + lib-trn_ret-parts.fact-qnty
        .
    end.
  end.
  assign
    vartotal-parts-qnty = 0
    vartotal-price-base = 0
    vartotal-price-rubl = 0
    vartotal-road-tax   = 0
  .
  for each bf_parts
    where bf_parts.obj-type  = bf_doc-line.obj-type
      and bf_parts.obj-code  = bf_doc-line.obj-code
      and bf_parts.artic     = bf_doc-line.artic
      and bf_parts.prod-type = bf_doc-line.prod-type
      and bf_parts.prod-code = bf_doc-line.prod-code
      and bf_parts.out-code  = bf_doc-line.doc-code
  on error undo, return error return-value
  :
    assign
      vartotal-parts-qnty = vartotal-parts-qnty + bf_parts.fact-qnty
      vartotal-price-base = vartotal-price-base + bf_parts.fact-qnty * bf_parts.price-base
      vartotal-price-rubl = vartotal-price-rubl + bf_parts.fact-qnty * bf_parts.price-rubl
    .
    if varr-b = "rubl":u then do:
      assign
        vartotal-road-tax   = vartotal-road-tax   + bf_parts.fact-qnty * bf_parts.road-tax-rubl
      .
    end.
    else do:
      assign
        vartotal-road-tax   = vartotal-road-tax   + bf_parts.fact-qnty * bf_parts.road-tax-rubl
      .
    end.
  end.
  if bf_doc-line.fact-qnty <> vartotal-parts-qnty then do:
    undo, return error substitute ("Количество в партиях не совпадает с количеством в строке документа. Количество по документу = &1 Количество по партиям = &2 ", bf_doc-line.fact-qnty, vartotal-parts-qnty).
  end.
  if vartotal-parts-qnty <> 0 then do:
    assign
      bf_doc-line.price-rubl = vartotal-price-rubl / vartotal-parts-qnty
      bf_doc-line.price-base = vartotal-price-base / vartotal-parts-qnty
      bf_doc-line.price-cli  = vartotal-price-base / vartotal-parts-qnty
      bf_doc-line.road-tax   = vartotal-road-tax   / vartotal-parts-qnty
    .
  end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  bf_trn-doc.hold-obj-type
  ,input  bf_trn-doc.hold-obj-code
  ,input  'doc-prt=request':u
  ,output cli_doc-prt
  ) no-error .
  if error-status:error then do:
    undo, return error return-value.
  end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  'doc-prt=request':u
  ,output obj_doc-prt
  ) no-error .
  if error-status:error then do:
    undo, return error return-value.
  end.
  if cli_doc-prt <> obj_doc-prt then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  bf_goods.artic
  ,input  bf_goods.prod-type
  ,input  bf_goods.prod-code
  ,output varprt-create-n-c
  ) no-error .
    if error-status:error then do:
      return error return-value.
    end.
    if cli_doc-prt = true then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  varprt-create-n-c
  ,output varprt-create-n-c
  ) no-error .
      if error-status:error then do:
        return error return-value.
      end.
    end.
  end.
  assign
    vartotal-gds-dtl-qnty = 0
  .
  for each lib-trn_ret-dtl no-lock
    where lib-trn_ret-dtl.doc-code  = lib-trn_ret-line.doc-code
      and lib-trn_ret-dtl.prod-type = lib-trn_ret-line.prod-type
      and lib-trn_ret-dtl.prod-code = lib-trn_ret-line.prod-code
      and lib-trn_ret-dtl.artic     = lib-trn_ret-line.artic
  on error undo, return error
  :
    if lib-trn_ret-dtl.fact-qnty < 0 then do:
      undo, return error "В документе межфирменного перемещения в строке признака не может быть задано отрицательное количество".
    end.
    if lib-trn_ret-dtl.fact-qnty = 0 then do:
      next.
    end.
    if cli_doc-prt = obj_doc-prt then do:
      assign
        varcreate-n-c = lib-trn_ret-dtl.prt-code
      .
    end.
    else do:
      assign
        varcreate-n-c = varprt-create-n-c
      .
    end.
    create bf_gds-dtl.
    assign
      bf_gds-dtl.doc-code    = bf_trn-doc.doc-code
      bf_gds-dtl.artic       = lib-trn_ret-dtl.artic
      bf_gds-dtl.prod-type   = lib-trn_ret-dtl.prod-type
      bf_gds-dtl.prod-code   = lib-trn_ret-dtl.prod-code
      bf_gds-dtl.prt-code    = varcreate-n-c
      bf_gds-dtl.obj-type    = bf_trn-doc.obj-type
      bf_gds-dtl.obj-code    = bf_trn-doc.obj-code
      bf_gds-dtl.discnt-base = lib-trn_ret-dtl.discnt-base
      bf_gds-dtl.discnt-rubl = lib-trn_ret-dtl.discnt-rubl
      bf_gds-dtl.discnt-pc   = lib-trn_ret-dtl.discnt-pc
      bf_gds-dtl.discnt-type = lib-trn_ret-dtl.discnt-type
      bf_gds-dtl.price-base  = lib-trn_ret-dtl.price-base
      bf_gds-dtl.price-rubl  = lib-trn_ret-dtl.price-rubl
      bf_gds-dtl.fact-qnty   = lib-trn_ret-dtl.fact-qnty
      bf_gds-dtl.doc-qnty    = lib-trn_ret-dtl.doc-qnty
      bf_gds-dtl.ov          = yes
      vartotal-gds-dtl-qnty  = vartotal-gds-dtl-qnty + bf_gds-dtl.fact-qnty
    .
  end.
  if vartotal-gds-dtl-qnty <> bf_doc-line.fact-qnty then do:
    undo, return error substitute ("Количество в признаках не совпадает с количеством в строке документа. Количество по строкам документа = &1 Количество по признакам = &2", bf_doc-line.fact-qnty, vartotal-gds-dtl-qnty).
  end.
end.
find first bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-error.
if not available bf_doc-line then do:
  delete bf_trn-doc.
end.
end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-today         as date                      no-undo.
define variable varhave-ret     as logical                   no-undo.
define variable varchg-inv      as logical                   no-undo.
define buffer bf-src_trn-doc       for ub.trn-doc.
define buffer bf-src_doc-line      for ub.doc-line.
define buffer bf-src_doc-line-attr for ub.doc-line-attr.
define buffer bf-src_goods         for ub.goods.
define buffer bf-src_gds-dtl       for ub.gds-dtl.
define buffer bf-src_parts         for ub.parts.
define buffer bf-src_units         for ub.units.
define buffer bf_trn-doc           for ub.trn-doc.
define buffer buf_trn-doc          for ub.trn-doc.
define buffer bf-cur-obj_clients   for ub.clients.
define buffer bf-hold-obj_clients  for ub.clients.
define buffer bf-hold_sysconf      for ub.sysconf.
define buffer bf-hold_firm         for ub.firm   .
define buffer bf-cur-firm_clients  for ub.clients.
define buffer bf-cur_sysconf       for ub.sysconf.
define buffer bf_doc-line          for ub.doc-line.
define buffer bf_doc-line-attr     for ub.doc-line-attr.
define buffer bf_gds-dtl           for ub.gds-dtl.
define buffer bf_parts             for ub.parts.
define buffer bf_contract          for ub.contract.
define buffer bf_currency          for ub.currency.
define buffer bf_goods             for ub.goods.
define variable v-base-code-cur  like ub.currency.curr-code     no-undo.
define variable v-base-code-hold like ub.currency.curr-code     no-undo.
define variable vardoc-code      like ub.trn-doc.doc-code       no-undo.
define variable varexch-rate     like ub.trn-doc.exch-rate      no-undo.
define variable varexch-scale    like ub.trn-doc.exch-scale     no-undo.
define variable varcurr-abbr     as   character                 no-undo.
define variable v-base-code-from like ub.sysconf.base-code      no-undo.
define variable v-base-code-to   like ub.sysconf.base-code      no-undo.
define variable is-petrol as logical no-undo.
define variable is-pieces as logical no-undo.
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-event-code as character no-undo .
if retry then do:
  message "Несанкционированное завершение транзакции progress." skip
          "Отправьте, пожалуйста, экран с этим сообщением в отдел сопровождения компании IBS." skip
          "return-value"                 return-value                 skip
          "error-status :error"          error-status :error          skip
          "error-status :get-message(1)" error-status :get-message(1) skip
          "error-status :get-message(2)" error-status :get-message(2) skip
          "error-status :get-message(3)" error-status :get-message(3) skip
          "error-status :get-message(4)" error-status :get-message(4) skip
          "error-status :get-message(5)" error-status :get-message(5) skip
          "конец сообщения"
  view-as alert-box error.
  return error return-value.
end.
main-block:
do for bf-src_trn-doc       ,
       bf-src_doc-line      ,
       bf-src_doc-line-attr ,
       bf-src_goods         ,
       bf-src_gds-dtl       ,
       bf-src_parts         ,
       bf-src_units         ,
       bf_trn-doc           ,
       bf-cur-obj_clients   ,
       bf-hold-obj_clients  ,
       bf-hold_sysconf      ,
       bf-hold_firm         ,
       bf-cur-firm_clients  ,
       bf-cur_sysconf       ,
       bf_doc-line          ,
       bf_doc-line-attr     ,
       bf_gds-dtl           ,
       bf_parts             ,
       bf_contract          ,
       bf_currency
transaction
on error undo main-block, return error return-value
:
  find first bf-src_trn-doc
    where bf-src_trn-doc.doc-code = v-doc-code
    no-error .
  if not available bf-src_trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ " v-doc-code
      view-as alert-box .
    undo main-block, return error .
  end.
  if bf-src_trn-doc.office then do:
    return.
  end.
  find first bf-cur_sysconf no-lock
  where bf-cur_sysconf.host-code = bf-src_trn-doc.host-code
  no-error.
  find first bf-hold_sysconf no-lock
  where bf-hold_sysconf.host-code = bf-src_trn-doc.cli-code
  no-error .
  if  bf-src_trn-doc.status_  = 'факт':U
  and (bf-src_trn-doc.ext-doc-type = 'ee':U   or
       bf-src_trn-doc.ext-doc-type = 'ie':U   or
       bf-src_trn-doc.ext-doc-type = 'ep':U ) then do:
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "В качестве параметра можно передавать" skip
      "только документы внешнего расхода или внешнего прихода" skip
      "закрытые до статуса" 'факт':U skip
      "Документ" bf-src_trn-doc.doc-code skip
      "Тип документа" bf-src_trn-doc.doc-type skip
      "Внутренний" bf-src_trn-doc.internal skip
      "Тип скидки" bf-src_trn-doc.discnt-type skip
      "Статус" bf-src_trn-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-is-hold as logical   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  bf-src_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
  if error-status :error or v-is-hold = false then return .
  if not available bf-hold_sysconf or
     bf-src_trn-doc.cli-type <> 'орг':U or
     (bf-src_trn-doc.ext-doc-type = 'ee':U    and bf-src_trn-doc.hold-doc-code-child  = "no-hold") or
     (bf-src_trn-doc.ext-doc-type = 'ie':U    and bf-src_trn-doc.hold-doc-code-parent = "no-hold") or
     (bf-src_trn-doc.ext-doc-type = 'ep':U and bf-src_trn-doc.hold-doc-code-child  = "no-hold")
    then do:
    return .
  end.
  find first bf-hold_firm where bf-hold_firm.firm-code = bf-hold_sysconf.host-code no-lock.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  bf-src_trn-doc.host-code
  ,output v-base-code-cur
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода базовой валюты для фирмы" skip
      "Документ перемещения" bf-src_trn-doc.doc-code skip
      view-as alert-box error .
    undo, return error .
  end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  bf-src_trn-doc.cli-code
  ,output v-base-code-hold
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода базовой валюты для фирмы" skip
      "Документ перемещения" bf-src_trn-doc.doc-code skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-base-code-hold <> v-base-code-cur then do:
    message
      vss-workfile vss-revision vss-description skip
      "Коды базовой валюты для фирм источника и приемника разные" skip
      "Документ перемещения" bf-src_trn-doc.doc-code skip
      "Источник-фирма " bf-src_trn-doc.host-code skip
      "Приемник-фирма " bf-src_trn-doc.cli-code
      view-as alert-box error .
    undo, return error .
  end.
  case bf-src_trn-doc.ext-doc-type :
  when 'ee':U then do:
    find first bf-hold-obj_clients no-lock
      where bf-hold-obj_clients.obj-type = bf-src_trn-doc.hold-obj-type
        and bf-hold-obj_clients.obj-code = bf-src_trn-doc.hold-obj-code
      no-error .
    if not available bf-hold-obj_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет объекта-приемника, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект-приемник" bf-src_trn-doc.hold-obj-type bf-src_trn-doc.hold-obj-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first bf-cur-firm_clients no-lock
      where bf-cur-firm_clients.obj-type = 'орг':U and
            bf-cur-firm_clients.obj-code = bf-src_trn-doc.host-code
    no-error.
    if not available bf-cur-firm_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет фирмы для документа перемещения, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
        "Фирма" bf-src_trn-doc.host-code
        view-as alert-box error .
      undo, return error .
    end.
  end.
  when 'ep':U then do:
    find first bf-hold-obj_clients no-lock
      where bf-hold-obj_clients.obj-type = bf-src_trn-doc.hold-obj-type
        and bf-hold-obj_clients.obj-code = bf-src_trn-doc.hold-obj-code
      no-error .
    if not available bf-hold-obj_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет объекта-приемника, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект-приемник" bf-src_trn-doc.hold-obj-type bf-src_trn-doc.hold-obj-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first bf-cur-firm_clients no-lock
      where bf-cur-firm_clients.obj-type = 'орг':U and
            bf-cur-firm_clients.obj-code = bf-src_trn-doc.host-code
    no-error.
    if not available bf-cur-firm_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет фирмы для документа перемещения, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
        "Фирма" bf-src_trn-doc.host-code
        view-as alert-box error .
      undo, return error .
    end.
  end.
  when 'ie':U then do:
    find bf-hold-obj_clients where bf-hold-obj_clients.obj-type = bf-src_trn-doc.hold-obj-type and
                                   bf-hold-obj_clients.obj-code = bf-src_trn-doc.hold-obj-code no-lock no-error.
    if not available bf-hold-obj_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет объекта для создания документа межфирменного перемещения, нельзя копировать" skip
        "Документ прихода" bf-src_trn-doc.doc-code skip
        "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
        "Фирма" bf-src_trn-doc.host-code
        "Объект для генерации документа " bf-src_trn-doc.hold-obj-type " " bf-src_trn-doc.hold-obj-code
        view-as alert-box error .
      undo, return error .
    end.
    find first bf-cur-firm_clients no-lock
      where bf-cur-firm_clients.obj-type = 'орг':U and
            bf-cur-firm_clients.obj-code = bf-src_trn-doc.host-code
    no-error.
    if not available bf-cur-firm_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет фирмы для документа перемещения, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
        "Фирма" bf-src_trn-doc.host-code
        view-as alert-box error .
      undo, return error .
    end.
  end.
  otherwise do:
    message "Неверный расширенный тип документа для межфирменного перемещения: " bf-src_trn-doc.ext-doc-type " ."
    view-as alert-box error.
    undo, return error.
  end.
  end case.
  find first bf-cur-obj_clients no-lock
    where bf-cur-obj_clients.obj-type = bf-src_trn-doc.obj-type
      and bf-cur-obj_clients.obj-code = bf-src_trn-doc.obj-code
    no-error .
  if not available bf-cur-obj_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный клиент" skip
      "Документ " v-doc-code skip
      "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
      "Клиент" bf-src_trn-doc.cli-code bf-src_trn-doc.cli-type skip
      view-as alert-box .
    undo main-block, return error .
  end.
  if not (
     (bf-cur-obj_clients.db-num = bf-hold-obj_clients.db-num and
      g#db-num = bf-cur-obj_clients.db-num                ) or
     (bf-cur-obj_clients.db-num <> bf-hold-obj_clients.db-num and
      g#db-num         =  0                     )
     )
  then do:
    return .
  end.
  if bf-src_trn-doc.ext-doc-type = 'ie':U then do:
    assign varhave-ret = no.
    for each bf-src_doc-line where bf-src_doc-line.doc-code = bf-src_trn-doc.doc-code on error undo, return error return-value :
       if bf-src_doc-line.doc-qnty <> bf-src_doc-line.fact-qnty then do:
         assign varhave-ret = yes.
         leave.
       end.
    end.
    if varhave-ret = no then do :
      return.
    end.
  end.
  run doc-code in this-procedure
   (input  "main":u,
    input  bf-hold-obj_clients.obj-type,
    input  bf-hold-obj_clients.obj-code,
    input  ?,
    output vardoc-code) no-error.
  if error-status :error then do:
    message "Ошибка при генерации номера документа." skip
            return-value skip
            error-status :get-message(1)
    view-as alert-box error.
    undo, return error.
  end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  bf-hold-obj_clients.obj-type
  ,input  bf-hold-obj_clients.obj-code
  ,output v-today
  )  .
  case bf-src_trn-doc.ext-doc-type :
  when 'ee':U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input bf-src_trn-doc.base-rate
,input bf-src_trn-doc.base-scale
,input bf-src_trn-doc.host-code
,input 'орг':U
,input bf-cur-firm_clients.obj-name
,input g#db-num
,input bf-src_trn-doc.creid
,input ''
,input vardoc-code
,input v-today
,input 'при':U
,input false
,input bf-src_trn-doc.cli-code
,input no
,input bf-hold-obj_clients.obj-code
,input bf-hold-obj_clients.obj-type
,input bf-src_trn-doc.office
,input bf-src_trn-doc.pay-code
,input ''
,input no
,input ?
,input 'накл':U
,input ?
,input 'ie':U
,input '1':U
) no-error
.
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа межфирменного перемещения" skip
      "Исходный документ межфирменного перемещения" bf-src_trn-doc.doc-code skip
      "Объект" bf-src_trn-doc.cli-type bf-src_trn-doc.cli-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.
  end.
  when 'ep':U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input bf-src_trn-doc.base-rate
,input bf-src_trn-doc.base-scale
,input bf-src_trn-doc.host-code
,input 'орг':U
,input bf-cur-firm_clients.obj-name
,input g#db-num
,input bf-src_trn-doc.creid
,input 'процент':U
,input vardoc-code
,input v-today
,input 'возврат':U
,input false
,input bf-src_trn-doc.cli-code
,input no
,input bf-hold-obj_clients.obj-code
,input bf-hold-obj_clients.obj-type
,input bf-src_trn-doc.office
,input bf-src_trn-doc.pay-code
,input ''
,input no
,input ?
,input 'накл':U
,input ?
,input 're':U
,input '1':U
) no-error
.
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа межфирменного перемещения" skip
      "Исходный документ межфирменного перемещения" bf-src_trn-doc.doc-code skip
      "Объект" bf-src_trn-doc.cli-type bf-src_trn-doc.cli-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.
  end.
  when 'ie':U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input bf-src_trn-doc.base-rate
,input bf-src_trn-doc.base-scale
,input bf-src_trn-doc.host-code
,input 'орг':U
,input bf-cur-firm_clients.obj-name
,input g#db-num
,input bf-src_trn-doc.creid
,input 'процент':U
,input vardoc-code
,input v-today
,input 'возврат':U
,input false
,input bf-src_trn-doc.cli-code
,input no
,input bf-hold-obj_clients.obj-code
,input bf-hold-obj_clients.obj-type
,input bf-src_trn-doc.office
,input bf-src_trn-doc.pay-code
,input ''
,input no
,input ?
,input 'накл':U
,input ?
,input 're':U
,input '1':U
) no-error
.
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа межфирменного перемещения" skip
      "Исходный документ межфирменного перемещения" bf-src_trn-doc.doc-code skip
      "Объект" bf-src_trn-doc.cli-type bf-src_trn-doc.cli-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.
  end.
  otherwise do:
    message "Неверный расширенный тип документа для межфирменного перемещения: " bf-src_trn-doc.ext-doc-type " ."
    view-as alert-box error.
    undo, return error.
  end.
  end case.
  find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code .
  assign
    bf_trn-doc.PS          = "Документ межфирменного перемещения создан на основании документа: " + bf-src_trn-doc.doc-code
                             + chr(10) + "Комментарий родительского документа: " + bf-src_trn-doc.ps
    bf_trn-doc.out-code    = ?
    bf_trn-doc.fact-base   = ?
    bf_trn-doc.fact-rubl   = ?
  .
  assign
    bf-src_trn-doc.hold-doc-code-child = bf_trn-doc.doc-code
    bf_trn-doc.out-code                = bf-src_trn-doc.doc-code
    bf_trn-doc.hold-doc-code-parent    = bf-src_trn-doc.doc-code
    bf_trn-doc.hold-obj-type           = bf-src_trn-doc.obj-type
    bf_trn-doc.hold-obj-code           = bf-src_trn-doc.obj-code
    bf_trn-doc.reason-code             = bf-src_trn-doc.reason-code
  .
  if bf_trn-doc.ext-doc-type      =  'ie':U and
     bf-src_trn-doc.contract-code <> 0                  then do:
    find bf_contract where bf_contract.host-code     = bf_trn-doc.host-code and  bf_contract.cli-code = bf_trn-doc.cli-code and bf_contract.status_ <> 'зкр':U no-lock no-error.
      if available bf_contract then do:
      if ambiguous bf_contract then bf_trn-doc.contract-code = 0 . else bf_trn-doc.contract-code = bf_contract.contract-code .
      end.
    find first bf_contract where bf_contract.contract-code = bf-src_trn-doc.contract-code no-lock.
    find first bf_currency where bf_currency.curr-code = bf_contract.curr-code no-lock no-error.
    if not available bf_currency then do:
      return error substitute ("В договоре на приход указана валюта &1. Но этой валюты нет в справочнике валют.", bf_contract.curr-code).
    end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  bf_currency.curr-code
  ,input  bf_trn-doc.exch-date
  ,output varexch-rate
  ,output varexch-scale
  ,output varcurr-abbr
  ) no-error .
     if error-status :error then do:
       return error "Ошибка при поиске курса валюты поставки по договору.".
     end.
     assign
       bf_trn-doc.exch-code     = bf_contract.curr-code
       bf_trn-doc.exch-rate     = varexch-rate
       bf_trn-doc.exch-scale    = varexch-scale
     .
    if lookup (bf_contract.contract-type, 'Купли-продажи,Агентский договор,Давальческого сырья,Продажи через ТПСИ':U) > 0 then do:
      assign
        bf_trn-doc.purch-code = 1.
    end.
    else do:
      if lookup (bf_contract.contract-type, 'Консигнации':U) > 0 then do:
        assign
          bf_trn-doc.purch-code = 2.
      end.
      else do:
        if lookup (bf_contract.contract-type, 'Ответственного хранения':U) > 0 then do:
          assign
            bf_trn-doc.purch-code = 3.
        end.
        else do:
          return error substitute("Нельзя определить по договору  &1 с типом &2 тип приобретения для партий накладной.", bf_contract.contract-prn-code, bf_contract.contract-type ).
        end.
      end.
    end.
  end.
  else do:
find first buf_trn-doc where buf_trn-doc.doc-code = bf-src_trn-doc.out-code no-lock no-error .
if available buf_trn-doc then do:
  find first bf_contract where bf_contract.contract-code = buf_trn-doc.contract-code no-lock no-error.
  if available bf_contract then bf_trn-doc.contract-code = bf_contract.contract-code.
end.
else do:
  find first bf_contract where bf_contract.host-code = bf_trn-doc.host-code and bf_contract.cli-code = bf_trn-doc.cli-code  no-lock no-error.
  if available bf_contract then bf_trn-doc.contract-code = bf_contract.contract-code.
end.
    if bf-src_trn-doc.exch-code <> 0 then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  bf-src_trn-doc.host-code
  ,output v-base-code-from
  )  .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  bf_trn-doc.host-code
  ,output v-base-code-to
  )  .
      if v-base-code-from = v-base-code-to
      and v-base-code-from <> 0 then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code-from
  ,input  bf_trn-doc.exch-date
  ,output varexch-rate
  ,output varexch-scale
  ,output varcurr-abbr
  ) no-error .
        if error-status :error then do:
          return error substitute("Ошибка при поиске курса валюты &1:&2&3 &4."
                                 , v-base-code-from
                                 , chr(10)
                                 , error-status :get-message(1)
                                 , return-value
                                 ).
        end.
        assign
        bf_trn-doc.exch-code  = v-base-code-from
        bf_trn-doc.exch-rate  = varexch-rate
        bf_trn-doc.exch-scale = varexch-scale
        .
      end.
      else do:
        assign
        bf_trn-doc.exch-code  = 0
        bf_trn-doc.exch-rate  = 1
        bf_trn-doc.exch-scale = 1.
      end.
    end.
    else do:
      assign
      bf_trn-doc.exch-code  = 0
      bf_trn-doc.exch-rate  = 1
      bf_trn-doc.exch-scale = 1.
    end.
  end.
  assign
    bf_trn-doc.vat-type   = 'в т. ч.':U
    bf_trn-doc.slt-type   = 'без':U.
  for each lib-trn_ret-doc on error undo, return error return-value :
    delete lib-trn_ret-doc.
  end.
  create lib-trn_ret-doc.
  buffer-copy bf-src_trn-doc except bf-src_trn-doc.fact-date bf-src_trn-doc.shift-date bf-src_trn-doc.shift-num to lib-trn_ret-doc.
  for each lib-trn_ret-line on error undo, return error return-value :
    delete lib-trn_ret-line.
  end.
  for each lib-trn_ret-line-attr on error undo, return error return-value :
    delete lib-trn_ret-line-attr.
  end.
  for each lib-trn_ret-dtl on error undo, return error return-value :
    delete lib-trn_ret-dtl.
  end.
  for each lib-trn_ret-parts on error undo, return error return-value :
    delete lib-trn_ret-parts.
  end.
  doc-line-label:
  for each bf-src_doc-line where bf-src_doc-line.doc-code = bf-src_trn-doc.doc-code on error undo, return error return-value :
    find first bf-src_goods where bf-src_goods.artic     = bf-src_doc-line.artic     and
                              bf-src_goods.prod-type = bf-src_doc-line.prod-type and
                              bf-src_goods.prod-code = bf-src_doc-line.prod-code no-lock.
    if bf-src_trn-doc.ext-doc-type = 'ie':U    and
       bf-src_doc-line.doc-qnty    = bf-src_doc-line.fact-qnty then do:
       next doc-line-label.
    end.
    create lib-trn_ret-line.
    buffer-copy bf-src_doc-line except bf-src_doc-line.doc-qnty bf-src_doc-line.fact-qnty to lib-trn_ret-line.
    assign
    lib-trn_ret-line.doc-qnty  = (if bf-src_trn-doc.ext-doc-type = 'ie':U then bf-src_doc-line.doc-qnty - bf-src_doc-line.fact-qnty else bf-src_doc-line.fact-qnty)
    lib-trn_ret-line.fact-qnty = lib-trn_ret-line.doc-qnty
    lib-trn_ret-line.cst-code  = bf_trn-doc.cst-code.
    for each bf-src_doc-line-attr where bf-src_doc-line-attr.doc-code  = bf-src_trn-doc.doc-code and
                                        bf-src_doc-line-attr.gds-code  = bf-src_goods.gds-code   on error undo, return error return-value :
      create lib-trn_ret-line-attr.
      buffer-copy bf-src_doc-line-attr to lib-trn_ret-line-attr.
    end.
    gds-dtl-label:
    for each bf-src_gds-dtl where bf-src_gds-dtl.doc-code  = bf-src_trn-doc.doc-code   and
                                  bf-src_gds-dtl.artic     = bf-src_doc-line.artic     and
                                  bf-src_gds-dtl.prod-type = bf-src_doc-line.prod-type and
                                  bf-src_gds-dtl.prod-code = bf-src_doc-line.prod-code on error undo, return error return-value :
      if bf-src_trn-doc.ext-doc-type = 'ie':U   and
         bf-src_gds-dtl.doc-qnty     = bf-src_gds-dtl.fact-qnty then do:
         next gds-dtl-label.
      end.
      create lib-trn_ret-dtl.
      buffer-copy bf-src_gds-dtl except bf-src_gds-dtl.doc-qnty bf-src_gds-dtl.fact-qnty bf-src_gds-dtl.price-base bf-src_gds-dtl.discnt-base bf-src_gds-dtl.price-rubl bf-src_gds-dtl.discnt-rubl to lib-trn_ret-dtl.
      assign
        lib-trn_ret-dtl.price-base  = bf-src_gds-dtl.price-base - bf-src_gds-dtl.discnt-base
        lib-trn_ret-dtl.discnt-base = 0
        lib-trn_ret-dtl.price-rubl  = bf-src_gds-dtl.price-rubl - bf-src_gds-dtl.discnt-rubl
        lib-trn_ret-dtl.discnt-rubl = 0
        lib-trn_ret-dtl.doc-qnty    = (if bf-src_trn-doc.ext-doc-type = 'ie':U then bf-src_gds-dtl.doc-qnty - bf-src_gds-dtl.fact-qnty else bf-src_gds-dtl.fact-qnty)
        lib-trn_ret-dtl.fact-qnty   = lib-trn_ret-dtl.doc-qnty.
    end.
    parts-label:
    for each bf-src_parts where bf-src_parts.out-code  = bf-src_trn-doc.doc-code   and
                                bf-src_parts.obj-type  = bf-src_trn-doc.obj-type   and
                                bf-src_parts.obj-code  = bf-src_trn-doc.obj-code   and
                                bf-src_parts.artic     = bf-src_doc-line.artic     and
                                bf-src_parts.prod-type = bf-src_doc-line.prod-type and
                                bf-src_parts.prod-code = bf-src_doc-line.prod-code on error undo, return error return-value :
      if bf-src_trn-doc.ext-doc-type = 'ie':U   and
         bf-src_parts.qnty           = bf-src_parts.fact-qnty then do:
         next parts-label.
      end.
      bf-src_parts.hold-date = v-today .
      create lib-trn_ret-parts.
      buffer-copy bf-src_parts except bf-src_parts.qnty bf-src_parts.fact-qnty to lib-trn_ret-parts.
      assign
        lib-trn_ret-parts.qnty      = (if bf-src_trn-doc.ext-doc-type = 'ie':U then bf-src_parts.qnty - bf-src_parts.fact-qnty else bf-src_parts.fact-qnty)
        lib-trn_ret-parts.fact-qnty = lib-trn_ret-parts.qnty
        lib-trn_ret-parts.contract-code = bf_trn-doc.contract-code .
        if bf-src_trn-doc.ext-doc-type = 'ee':U  then do:
           lib-trn_ret-parts.hold-date = v-today .
        end.
    end.
  end.
  if bf_trn-doc.ext-doc-type = 'ie':U then do:
    assign
      lib-trn_ret-doc.doc-type     = 'при':U
      lib-trn_ret-doc.internal     = no
      lib-trn_ret-doc.ext-doc-type = 'ie':U
      lib-trn_ret-doc.exch-code    = bf_trn-doc.exch-code
      lib-trn_ret-doc.exch-rate    = bf_trn-doc.exch-rate
      lib-trn_ret-doc.exch-scale   = bf_trn-doc.exch-scale
      .
    for each lib-trn_ret-dtl break by lib-trn_ret-dtl.doc-code by lib-trn_ret-dtl.artic by lib-trn_ret-dtl.prod-type by lib-trn_ret-dtl.prod-code on error undo, return error return-value :
        find first lib-trn_ret-line where lib-trn_ret-line.doc-code  = lib-trn_ret-dtl.doc-code  and
                                          lib-trn_ret-line.artic     = lib-trn_ret-dtl.artic     and
                                          lib-trn_ret-line.prod-type = lib-trn_ret-dtl.prod-type and
                                          lib-trn_ret-line.prod-code = lib-trn_ret-dtl.prod-code .
        assign
          lib-trn_ret-line.price-rubl = lib-trn_ret-dtl.price-rubl
          lib-trn_ret-line.price-base = lib-trn_ret-dtl.price-base
        .
    end.
    for each lib-trn_ret-line on error undo, return error return-value :
      find first bf_goods no-lock where
                 bf_goods.artic     = lib-trn_ret-line.artic     and
                 bf_goods.prod-type = lib-trn_ret-line.prod-type and
                 bf_goods.prod-code = lib-trn_ret-line.prod-code .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
      if not error-status :error and is-petrol = yes and is-pieces = no then do:
        assign lib-trn_ret-line.price-cli     = lib-trn_ret-line.price-rubl / lib-trn_ret-doc.exch-rate
                                                                            * lib-trn_ret-doc.exch-scale
                                                                            * lib-trn_ret-line.cli-base-rate.
      end.
      else do:
        assign lib-trn_ret-line.cli-base-rate = 1
               lib-trn_ret-line.price-cli     = lib-trn_ret-line.price-rubl / lib-trn_ret-doc.exch-rate
               lib-trn_ret-line.unit-cli      = bf_goods.unit-base.
      end.
      assign
        lib-trn_ret-line.cli-base-rate = 1
        lib-trn_ret-line.price-cli     = lib-trn_ret-line.price-rubl / lib-trn_ret-doc.exch-rate * lib-trn_ret-doc.exch-scale
        lib-trn_ret-line.unit-cli      = bf_goods.unit-base.
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input ?
 ,input recid(bf_trn-doc)
 ,input table lib-trn_ret-doc
 ,input table lib-trn_ret-line
 ,input table lib-trn_ret-line-attr
 ,input table lib-trn_ret-dtl
 ,input table lib-trn_ret-parts
 ,input no
 ,input yes
 ,input yes
 ,input yes
 ,input this-procedure
  ) no-error .
    if error-status :error then do:
      return error return-value.
    end.
    assign
      bf_trn-doc.agnt       = bf-src_trn-doc.agnt
      bf_trn-doc.boss       = bf-src_trn-doc.boss
      bf_trn-doc.wrkr       = bf-src_trn-doc.wrkr.
  end.
  else do:
    run hold-ret in this-procedure (input bf_trn-doc.doc-code) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при заполнении документа возврата" skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error return-value.
    end.
  end.
  run holdprts-validate-document in this-procedure
    (input bf_trn-doc.doc-code
    ) no-error .
  if error-status :error then do:
    return error return-value .
  end.
  run gbl/calc-trn.p (input ?  , input recid(bf_trn-doc)) no-error.
  if error-status :error then do:
    undo, return error return-value.
  end.
  if bf_trn-doc.ext-doc-type = 'ie':U then do:
    assign
      bf_trn-doc.tot-cli = bf_trn-doc.tot-calc.
  end.
  run str/trn-stat.p (input this-procedure,
                  input ?,
                  input '<закрытие документа>':U,
                  input vardoc-code,
                  input no,
                  input g#db-num,
                  input ?,
                  input ?,
                  input ?,
                  input ?,
                  input (if g#news = yes then no else yes),
                  output varchg-inv,
                  output table gds-list) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при закрытии документа " vardoc-code skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
    view-as alert-box error.
    return error.
  end.
  define variable vv-gds-code as integer   no-undo .
  for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,output vv-gds-code
  )  .
    var-ok-assort-pol = true .
    if bf_trn-doc.ext-doc-type = 'ie':U then do:
         v-event-code = substitute("mf_&1" ,bf_trn-doc.ext-doc-type ) .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  vv-gds-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
    end.
    if var-ok-assort-pol = false then do:
        bf_trn-doc.PS = bf_trn-doc.PS + chr(10) + var-mess-assort-pol .
    end.
  end.
  run gbl/calc-trn.p (input ?  , input recid(bf_trn-doc)) no-error.
  if error-status :error then do:
    undo, return error return-value.
  end.
    run cus/oo-mkrcv.p (
        buffer bf-src_trn-doc ,
        buffer bf_trn-doc  )
        no-error .
  if error-status :error then do:
    undo, return error return-value.
  end.
end.
