block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg-0.p $":U .
define variable vss-description as character no-undo init "Приложение к документу по перемещению товара".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character
    index pi is primary unique
        str-key
.
define variable v-p-fmt-1-str-key    as integer      no-undo.
FUNCTION center-field RETURNS INTEGER (INPUT iStartPix AS INTEGER, iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  if (iStartPix < 0) or (iEndPix < iStartPix) then return 0.
  assign
    v-start-print = INTEGER(iStartPix + ((iEndPix - iStartPix) / 2) - (iInput / 2))
  .
  RETURN v-start-print .
END FUNCTION.
FUNCTION right-field RETURNS INTEGER ( iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  assign
    v-start-print = INTEGER(iEndPix - 1 - iInput)
  .
  if v-start-print < 0 then return 0.
  RETURN v-start-print .
END FUNCTION.
function p-fmt-align-string returns character (
      p-in-string      as character
    , p-page-width     as integer
    , p-align-type     as character
).
    define variable v-string-length     as integer      no-undo.
    define variable v-out-string        as character    no-undo.
    assign
        v-string-length = length( trim( p-in-string ) )
    .
    if v-string-length >= p-page-width
    then do:
        assign
            v-out-string = trim( p-in-string )
        .
    end.
    else do:
        case p-align-type
        :
            when 'left':U
            then do:
                assign
                    v-out-string = trim( p-in-string )
                .
            end.
            when 'right':U
            then do:
                assign
                    v-out-string = fill( " ":U, p-page-width - v-string-length ) + trim( p-in-string )
                .
            end.
            when 'center':U
            then do:
                assign
                    v-out-string = fill( " ":U, integer( ( p-page-width - v-string-length ) / 2 ) ) + trim( p-in-string )
                .
            end.
        end case.
    end.
    return v-out-string .
end function.
procedure p-fmt-split-string :
define input parameter p-source-string  as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define output parameter p-string-1      as character        no-undo.
define output parameter p-string-2      as character        no-undo.
do
on error undo, return error
:
    define variable v-space-pos    as integer      no-undo.
    if length( p-source-string ) <= p-split-length
    then do:
        assign
            p-string-1 = p-source-string
        .
    end.
    else do:
        assign
            v-space-pos = r-index( p-source-string, " ":U, p-split-length )
        .
        if v-space-pos = 0
        then do:
            assign
                v-space-pos = index( p-source-string, " ":U )
            .
        end.
        if v-space-pos = 0
        then do:
            assign
                p-string-1 = substring( p-source-string, 1, p-split-length )
                p-string-2 = trim( substring( p-source-string, p-split-length, p-split-length ) )
            .
        end.
        else do:
            assign
                p-string-1 = substring( p-source-string, 1, v-space-pos )
                p-string-2 = trim( substring( p-source-string, v-space-pos ) )
            .
        end.
    end.
end.
end procedure.
procedure p-fmt-round :
define input parameter p-qnty               as decimal          no-undo.
define input parameter p-price-no-VAT       as decimal          no-undo.
define input parameter p-VAT                as decimal          no-undo.
define input parameter p-SLT                as decimal          no-undo.
define input parameter p-road-tax           as decimal          no-undo.
define output parameter p-new-price-no-VAT  as decimal          no-undo.
define output parameter p-new-VAT           as decimal          no-undo.
define output parameter p-new-SLT           as decimal          no-undo.
define output parameter p-new-sum-VAT       as decimal          no-undo.
define output parameter p-new-sum-SLT       as decimal          no-undo.
define output parameter p-new-sum-road-tax  as decimal          no-undo.
define output parameter p-new-sum-no-VAT    as decimal          no-undo.
define output parameter p-new-sum-full      as decimal          no-undo.
    define variable v-vat-pc    as decimal      no-undo.
    define variable v-slt-pc    as decimal      no-undo.
do
on error undo, return error
:
    if p-price-no-VAT = 0
    then do:
        assign
            p-new-price-no-VAT = 0.0
            p-new-VAT          = ?
            p-new-SLT          = ?
            p-new-sum-VAT      = 0.0
            p-new-sum-SLT      = 0.0
            p-new-sum-no-VAT   = 0.0
            p-new-sum-road-tax = 0.0
            p-new-sum-full     = 0.0
        .
    end.
    else do:
        assign
            v-vat-pc            = p-VAT / p-price-no-VAT
            v-slt-pc            = p-SLT / ( p-price-no-VAT + p-VAT )
            p-new-price-no-VAT  = round( p-price-no-VAT, 2 )
            p-new-VAT           = round( p-new-price-no-VAT * v-vat-pc, 2 )
            p-new-SLT           = round( ( p-new-price-no-VAT + p-new-VAT ) * v-slt-pc, 2 )
            p-new-sum-VAT       = round( p-new-VAT          * p-qnty, 2 )
            p-new-sum-SLT       = round( ( p-new-price-no-VAT + p-new-VAT ) * p-qnty * v-slt-pc, 2 )
            p-new-sum-no-VAT    = round( p-new-price-no-VAT * p-qnty, 2 )
            p-new-sum-road-tax  = round( p-road-tax * p-qnty, 2 )
            p-new-sum-full      = round( ( p-new-price-no-VAT + p-new-VAT + p-new-SLT + p-road-tax ) * p-qnty, 2 )
        .
    end.
end.
end procedure.
procedure p-fmt-split :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
    define variable v-start-pos     as integer      no-undo.
    define variable v-end-pos       as integer      no-undo.
    define buffer buf_temp_p-fmt_string-part        for temp_p-fmt_string-part.
do
for buf_temp_p-fmt_string-part
on error undo, return error
:
    empty temp-table buf_temp_p-fmt_string-part.
    if p-split-length < 1
    then do:
        undo, return error substitute( "p-fmt-split: Строка не может быть разбита на &1 частей", p-split-length ).
    end.
    assign
        p-in-string                 = trim( p-in-string )
        v-p-fmt-1-str-key   = 0
        v-start-pos                 = 1
        v-end-pos                   = length( p-in-string )
    .
    run p-fmt-get-string-range in this-procedure (
          input p-in-string
        , input p-split-length
        , input v-start-pos
        , output v-start-pos
        , output v-end-pos
    ).
    do while v-end-pos <> 0
    :
        create buf_temp_p-fmt_string-part.
        assign
            v-p-fmt-1-str-key = v-p-fmt-1-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-1-str-key
            buf_temp_p-fmt_string-part.string-part  = substring( p-in-string, v-start-pos, v-end-pos - v-start-pos )
        .
        assign
            v-start-pos = v-end-pos + 1
        .
        run p-fmt-get-string-range in this-procedure (
              input p-in-string
            , input p-split-length
            , input v-start-pos
            , output v-start-pos
            , output v-end-pos
        ).
    end.
end.
end procedure.
procedure p-fmt-get-string-range :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define input parameter p-old-start-pos  as integer          no-undo.
define output parameter p-start-pos     as integer          no-undo.
define output parameter p-end-pos       as integer          no-undo.
    define variable v-init-string    as character    no-undo.
    define variable v-temp-char      as character    no-undo.
    define variable v-temp-pos       as integer      no-undo.
    define variable v-counter        as integer      no-undo.
do
on error undo, return error
:
    assign
        p-start-pos   = p-old-start-pos
        v-init-string = substring( p-in-string, p-start-pos )
    no-error.
    if error-status :error
    or trim( v-init-string ) = "":U
    then do:
        assign
            p-end-pos = 0
        .
        undo, return .
    end.
    assign
        v-temp-char   = substring( v-init-string, 1, 1 )
    .
    do
    while trim( v-temp-char ) = "":U
    :
        assign
            p-start-pos     = p-start-pos + 1
            v-init-string   = substring( p-in-string, p-start-pos )
            v-temp-char     = substring( v-init-string, 1, 1 )
        .
    end.
    assign
        v-temp-pos  = p-split-length
        v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        v-counter   = 0
    .
    search-word-end:
    do
    while trim( v-temp-char ) <> "":U
    :
        assign
            v-counter   = v-counter + 1
        .
        if v-counter > 20
        then do:
            assign
                v-temp-pos  = p-split-length
            .
            leave search-word-end.
        end.
        assign
            v-temp-pos  = v-temp-pos - 1
            v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        .
    end.
    assign
        p-end-pos = p-start-pos + v-temp-pos - 1
    .
end.
end procedure.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def temp-table temp_r-getsum no-undo
    field row-number        as integer
    field qnty              like ub.doc-line.fact-qnty
    field vat-pc            like ub.doc-line.vat-pc
    field slt-pc            like ub.doc-line.slt-pc
    field sum-with-taxes    like ub.ot-line.sum-base
    field sum-vat           like ub.ot-line.vat-base
    field sum-slt           like ub.ot-line.slt-base
    field sum-road-tax      like ub.ot-line.road-tax-base
    field sum-transport     like ub.ot-line.transport-base
    field sum-other         like ub.ot-line.other-base
    field sum-excise        like ub.ot-line.excise-base
    field sum-no-taxes      like ub.ot-line.sum-base
    field sum-no-vat        like ub.ot-line.sum-base
    field sum-no-slt        like ub.ot-line.sum-base
    field price-no-taxes    like ub.doc-line.price-base
    field price-no-vat      like ub.doc-line.price-base
    field price-no-slt      like ub.doc-line.price-base
    index rn is primary unique row-number
.
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-cost :
  define input  parameter v-doc-code       like ub.doc-line.doc-code          no-undo .
  define input  parameter v-artic          like ub.doc-line.artic             no-undo .
  define input  parameter v-prod-type      like ub.doc-line.prod-type         no-undo .
  define input  parameter v-prod-code      like ub.doc-line.prod-code         no-undo .
  define output parameter v-fact-qnty      like ub.ot-line.fact-qnty       no-undo .
  define output parameter v-vat-pc         like ub.doc-line.vat-pc         no-undo .
  define output parameter v-slt-pc         like ub.doc-line.slt-pc         no-undo .
  define output parameter v-sum-base       like ub.ot-line.sum-base        no-undo .
  define output parameter v-sum-rubl       like ub.ot-line.sum-rubl        no-undo .
  define output parameter v-vat-base       like ub.ot-line.vat-base        no-undo .
  define output parameter v-vat-rubl       like ub.ot-line.vat-rubl        no-undo .
  define output parameter v-slt-base       like ub.ot-line.slt-base        no-undo .
  define output parameter v-slt-rubl       like ub.ot-line.slt-rubl        no-undo .
  define output parameter v-road-tax-base  like ub.ot-line.road-tax-base   no-undo .
  define output parameter v-road-tax-rubl  like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter v-transport-base like ub.ot-line.transport-base  no-undo .
  define output parameter v-transport-rubl like ub.ot-line.transport-rubl  no-undo .
  define output parameter v-other-base     like ub.ot-line.other-base      no-undo .
  define output parameter v-other-rubl     like ub.ot-line.other-rubl      no-undo .
  define output parameter v-excise-base    like ub.ot-line.excise-base     no-undo .
  define output parameter v-excise-rubl    like ub.ot-line.excise-rubl     no-undo .
  do
  on error undo, return error
  :
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
    def var v-parts-fact-qnty as decimal   no-undo .
    define buffer buf_parts    for ub.parts    .
    define buffer buf_goods    for ub.goods    .
    define buffer buf_trn-doc  for ub.trn-doc  .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = v-doc-code
        and buf_doc-line.artic     = v-artic
        and buf_doc-line.prod-type = v-prod-type
        and buf_doc-line.prod-code = v-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа"  skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = v-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_goods.gds-type = 'т':U then do:
          for each buf_parts no-lock
            where buf_parts.out-code  = buf_trn-doc.doc-code
              and buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
          on error undo, return error
          :
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
              v-parts-fact-qnty  = (if buf_trn-doc.doc-type = 'при':U
                                    or buf_trn-doc.doc-type = 'возврат':U
                                    or buf_trn-doc.doc-type = 'инв':U
                                    then buf_parts.fact-qnty
                                    else - buf_parts.fact-qnty
                                   )
            .
            assign
              v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
              v-sum-base            = v-sum-base       +  ( price-base-with-tax-loc * v-parts-fact-qnty )
              v-sum-rubl            = v-sum-rubl       +  ( price-rubl-with-tax-loc * v-parts-fact-qnty )
              v-vat-base            = v-vat-base       +  ( vat-base-loc            * v-parts-fact-qnty )
              v-vat-rubl            = v-vat-rubl       +  ( vat-rubl-loc            * v-parts-fact-qnty )
              v-slt-base            = v-slt-base       +  ( slt-base-loc            * v-parts-fact-qnty )
              v-slt-rubl            = v-slt-rubl       +  ( slt-rubl-loc            * v-parts-fact-qnty )
              v-road-tax-base       = v-road-tax-base  +  ( road-tax-base-loc       * v-parts-fact-qnty )
              v-road-tax-rubl       = v-road-tax-rubl  +  ( road-tax-rubl-loc       * v-parts-fact-qnty )
              v-excise-base         =   0
              v-excise-rubl         =   0
              v-transport-base      = v-transport-base +   (transport-base-loc      * v-parts-fact-qnty )
              v-transport-rubl      = v-transport-rubl +   (transport-rubl-loc      * v-parts-fact-qnty )
              v-other-base          = v-other-base     +   (other-base-loc          * v-parts-fact-qnty )
              v-other-rubl          = v-other-rubl     +   (other-rubl-loc          * v-parts-fact-qnty )
            .
        end.
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
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
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
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
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
        .
    end.
    else do:
          assign
            v-parts-fact-qnty           = (if buf_trn-doc.doc-type = 'при':U
                                      or buf_trn-doc.doc-type = 'возврат':U
                                      or buf_trn-doc.doc-type = 'инв':U
                                      then buf_doc-line.fact-qnty
                                      else - buf_doc-line.fact-qnty
                                    )
          .
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
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
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
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
            v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
            v-sum-base            = v-sum-base       + (price-base-with-tax-loc * v-parts-fact-qnty)
            v-sum-rubl            = v-sum-rubl       + (price-rubl-with-tax-loc * v-parts-fact-qnty)
            v-vat-base            = v-vat-base       + (vat-base-loc            * v-parts-fact-qnty)
            v-vat-rubl            = v-vat-rubl       + (vat-rubl-loc            * v-parts-fact-qnty)
            v-slt-base            = v-slt-base       + (slt-base-loc            * v-parts-fact-qnty)
            v-slt-rubl            = v-slt-rubl       + (slt-rubl-loc            * v-parts-fact-qnty)
            v-road-tax-base       =  0
            v-road-tax-rubl       =  0
            v-excise-base         =  0
            v-excise-rubl         =  0
            v-transport-base      =  0
            v-transport-rubl      =  0
            v-other-base          =  0
            v-other-rubl          =  0
          .
    end.
  end.
end procedure.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-sale :
  define input parameter  p-doc-code          like ub.doc-line.doc-code          no-undo .
  define input parameter  p-artic             like ub.doc-line.artic             no-undo .
  define input parameter  p-prod-type         like ub.doc-line.prod-type         no-undo .
  define input parameter  p-prod-code         like ub.doc-line.prod-code         no-undo .
  define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define output parameter p-sum-base          like ub.ot-line.sum-base        no-undo .
  define output parameter p-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define output parameter p-vat-base          like ub.ot-line.vat-base        no-undo .
  define output parameter p-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define output parameter p-slt-base          like ub.ot-line.slt-base        no-undo .
  define output parameter p-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define output parameter p-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define output parameter p-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter p-transport-base    like ub.ot-line.transport-base  no-undo .
  define output parameter p-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define output parameter p-other-base        like ub.ot-line.other-base      no-undo .
  define output parameter p-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define output parameter p-excise-base       like ub.ot-line.excise-base     no-undo .
  define output parameter p-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable vss-description as character no-undo initial "r-sale-01: обработка продажных цен товара".
  do
  on error undo, return error
  :
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
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define buffer buf_gds-dtl  for ub.gds-dtl .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Не найден документ" skip
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
            ASSIGN
                p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
                p-sum-base            = p-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
                p-sum-rubl            = p-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
                p-vat-base            = p-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
                p-vat-rubl            = p-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
                p-slt-base            = p-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
                p-slt-rubl            = p-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
                p-road-tax-base       = p-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
                p-road-tax-rubl       = p-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
                p-excise-base         = p-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
                p-excise-rubl         = p-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
                p-other-base          = p-other-base    + discnt-base-sale          * v-gds-dtl-fact-qnty
                p-other-rubl          = p-other-rubl    + discnt-rubl-sale          * v-gds-dtl-fact-qnty
            .
        end.
    end.
    assign
        p-transport-base      = 0
        p-transport-rubl      = 0
        p-vat-pc              = buf_doc-line.vat-pc
        p-slt-pc              = buf_doc-line.slt-pc
    .
  end.
  if p-fact-qnty      = ?
  or p-vat-pc         = ?
  or p-slt-pc         = ?
  or p-sum-base       = ?
  or p-sum-rubl       = ?
  or p-vat-base       = ?
  or p-vat-rubl       = ?
  or p-slt-base       = ?
  or p-slt-rubl       = ?
  or p-road-tax-base  = ?
  or p-road-tax-rubl  = ?
  or p-transport-base = ?
  or p-transport-rubl = ?
  or p-other-base     = ?
  or p-other-rubl     = ?
  or p-excise-base    = ?
  or p-excise-rubl    = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info9 skip
      "Получены неопределенные значения" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "fact-qnty     " p-fact-qnty      skip
      "vat-pc        " p-vat-pc         skip
      "slt-pc        " p-slt-pc         skip
      "sum-base      " p-sum-base       skip
      "sum-rubl      " p-sum-rubl       skip
      "vat-base      " p-vat-base       skip
      "vat-rubl      " p-vat-rubl       skip
      "slt-base      " p-slt-base       skip
      "slt-rubl      " p-slt-rubl       skip
      "road-tax-base " p-road-tax-base  skip
      "road-tax-rubl " p-road-tax-rubl  skip
      "transport-base" p-transport-base skip
      "transport-rubl" p-transport-rubl skip
      "other-base    " p-other-base     skip
      "other-rubl    " p-other-rubl     skip
      "excise-base   " p-excise-base    skip
      "excise-rubl   " p-excise-rubl    skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
procedure r-getsum :
do
on error undo, return error
:
def input parameter p-doc-line-recid    as recid    no-undo.
def input parameter p-cost-prices       as logical  no-undo.
def input parameter p-rubl-prices       as logical  no-undo.
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
def buffer buf_doc-line     for ub.doc-line.
def buffer buf_trn-doc      for ub.trn-doc.
def var v-void-output-parameter         as decimal  no-undo.
find first buf_doc-line    where recid( buf_doc-line ) = p-doc-line-recid.
find first buf_trn-doc     where buf_trn-doc.doc-code  = buf_doc-line.doc-code.
find first temp_r-getsum
     where temp_r-getsum.row-number = 1
no-error.
if not available temp_r-getsum
then do:
    for each temp_r-getsum
    :
        delete temp_r-getsum.
    end.
    create temp_r-getsum.
    assign
        temp_r-getsum.row-number = 1
    .
end.
if p-cost-prices = yes
then do:
    if buf_doc-line.status_ = 'факт':U
    then do:
        if p-rubl-prices = no
        then do:
            run r-cost in this-procedure ( input buf_doc-line.doc-code
                                         , input buf_doc-line.artic
                                         , input buf_doc-line.prod-type
                                         , input buf_doc-line.prod-code
                                         , output temp_r-getsum.qnty
                                         , output temp_r-getsum.vat-pc
                                         , output temp_r-getsum.slt-pc
                                         , output temp_r-getsum.sum-with-taxes
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-vat
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-slt
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-road-tax
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-transport
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-other
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-excise
                                         , output v-void-output-parameter
                                         ).
        end.
        else do:
            run r-cost in this-procedure ( input buf_doc-line.doc-code
                                        , input buf_doc-line.artic
                                        , input buf_doc-line.prod-type
                                        , input buf_doc-line.prod-code
                                        , output temp_r-getsum.qnty
                                        , output temp_r-getsum.vat-pc
                                        , output temp_r-getsum.slt-pc
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-with-taxes
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-vat
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-slt
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-road-tax
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-transport
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-other
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-excise
                                        ).
        end.
    end.
    else do:
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
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
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
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
            temp_r-getsum.qnty              = buf_doc-line.fact-qnty
            temp_r-getsum.vat-pc            = vat-pc-loc
            temp_r-getsum.slt-pc            = slt-pc-loc
            temp_r-getsum.sum-with-taxes    = (if p-rubl-prices = no
                                                    then price-base-with-tax-loc
                                                    else price-rubl-with-tax-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-vat           = (if p-rubl-prices = no
                                                    then vat-base-loc
                                                    else vat-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-slt           = (if p-rubl-prices = no
                                                    then slt-base-loc
                                                    else slt-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-road-tax      = (if p-rubl-prices = no
                                                    then road-tax-base-loc
                                                    else road-tax-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-transport     = (if p-rubl-prices = no
                                                    then transport-base-loc
                                                    else transport-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-other         = (if p-rubl-prices = no
                                                    then other-base-loc
                                                    else other-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-excise        = 0
        .
    end.
end.
else do:
    if buf_doc-line.status_ = 'факт':U
    then do:
        if p-rubl-prices = no
        then do:
            run r-sale in this-procedure ( input buf_doc-line.doc-code
                                         , input buf_doc-line.artic
                                         , input buf_doc-line.prod-type
                                         , input buf_doc-line.prod-code
                                         , output temp_r-getsum.qnty
                                         , output temp_r-getsum.vat-pc
                                         , output temp_r-getsum.slt-pc
                                         , output temp_r-getsum.sum-with-taxes
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-vat
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-slt
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-road-tax
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-transport
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-other
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-excise
                                         , output v-void-output-parameter
                                         ).
        end.
        else do:
            run r-sale in this-procedure ( input buf_doc-line.doc-code
                                        , input buf_doc-line.artic
                                        , input buf_doc-line.prod-type
                                        , input buf_doc-line.prod-code
                                        , output temp_r-getsum.qnty
                                        , output temp_r-getsum.vat-pc
                                        , output temp_r-getsum.slt-pc
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-with-taxes
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-vat
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-slt
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-road-tax
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-transport
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-other
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-excise
                                        ).
        end.
    end.
    else do:
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
  varsum-base-factovp     = 0
  varslt-base-factovp     = 0
  varvat-base-factovp     = 0
  varvatcons-base-factovp = 0
  vardsc-base-factovp     = 0
  varsum-base-docovp      = 0
  varslt-base-docovp      = 0
  varvat-base-docovp      = 0
  varvatcons-base-docovp  = 0
  vardsc-base-docovp      = 0
  varsum-rubl-factovp     = 0
  varslt-rubl-factovp     = 0
  varvat-rubl-factovp     = 0
  varvatcons-rubl-factovp = 0
  vardsc-rubl-factovp     = 0
  varsum-rubl-docovp      = 0
  varslt-rubl-docovp      = 0
  varvat-rubl-docovp      = 0
  varvatcons-rubl-docovp  = 0
  vardsc-rubl-docovp      = 0.
assign
  varis-one-gds-dtl = no.
find first out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = buf_trn-doc.doc-code  and
                                     out-vatp_gds-dtl.artic     = buf_doc-line.artic     and
                                     out-vatp_gds-dtl.prod-type = buf_doc-line.prod-type and
                                     out-vatp_gds-dtl.prod-code = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_gds-dtl then do:
  find first buf_out-vatp_gds-dtl where buf_out-vatp_gds-dtl.doc-code  =  buf_trn-doc.doc-code                and
                                           buf_out-vatp_gds-dtl.artic     =  buf_doc-line.artic                   and
                                           buf_out-vatp_gds-dtl.prod-type =  buf_doc-line.prod-type               and
                                           buf_out-vatp_gds-dtl.prod-code =  buf_doc-line.prod-code               and
                                           recid(buf_out-vatp_gds-dtl)    <> recid(out-vatp_gds-dtl) no-lock no-error.
  if not available buf_out-vatp_gds-dtl then do:
    assign
      varis-one-gds-dtl = yes.
  end.
  if varoutvprb = "base":u then do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base
      varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
  end.
  else do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
      varcurprice-rubl = out-vatp_gds-dtl.cur-base.
  end.
  if varempty-scale    = yes or
     varis-one-gds-dtl = yes   then do:
    assign
                price-base-with-tax-sale    = (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)
        slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
        vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        discnt-base-sale            = out-vatp_gds-dtl.discnt-base
                price-rubl-with-tax-sale    = (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)
        slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
        vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        discnt-rubl-sale            = out-vatp_gds-dtl.discnt-rubl
        .
    if buf_trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
    else do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale ) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = buf_trn-doc.doc-code  and
                                       out-vatp_gds-dtl.artic     = buf_doc-line.artic     and
                                       out-vatp_gds-dtl.prod-type = buf_doc-line.prod-type and
                                       out-vatp_gds-dtl.prod-code = buf_doc-line.prod-code no-lock :
      if varoutvprb = "base":u then do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base
          varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
      end.
      else do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
          varcurprice-rubl = out-vatp_gds-dtl.cur-base.
      end.
      assign
             varsum-base-factovp = varsum-base-factovp + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.fact-qnty
       varslt-base-factovp = varslt-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-base-factovp = varvat-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-base-factovp = varvatcons-base-factovp + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-factovp = vardsc-base-factovp + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.fact-qnty
       varsum-base-docovp  = varsum-base-docovp  + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.doc-qnty
       varslt-base-docovp  = varslt-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-base-docovp  = varvat-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-base-docovp  = varvatcons-base-docovp  + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-docovp  = vardsc-base-docovp  + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.doc-qnty
      .
      assign
             varsum-rubl-factovp = varsum-rubl-factovp + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.fact-qnty
       varslt-rubl-factovp = varslt-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-rubl-factovp = varvat-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-rubl-factovp = varvatcons-rubl-factovp + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-factovp = vardsc-rubl-factovp + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.fact-qnty
       varsum-rubl-docovp  = varsum-rubl-docovp  + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.doc-qnty
       varslt-rubl-docovp  = varslt-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-rubl-docovp  = varvat-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-rubl-docovp  = varvatcons-rubl-docovp  + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-docovp  = vardsc-rubl-docovp  + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.doc-qnty   .
    end.
    if buf_trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-docovp / varfact-qnty
        slt-base-sale               = varslt-base-docovp / varfact-qnty
        vat-base-buyer              = varvat-base-docovp / varfact-qnty
        discnt-base-sale            = vardsc-base-docovp / varfact-qnty
        vat-base-sale               = varvatcons-base-docovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-docovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-docovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-docovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-docovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-docovp / varfact-qnty.
    end.
    else do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-factovp / varfact-qnty
        slt-base-sale               = varslt-base-factovp / varfact-qnty
        vat-base-buyer              = varvat-base-factovp / varfact-qnty
        discnt-base-sale            = vardsc-base-factovp / varfact-qnty
        vat-base-sale               = varvatcons-base-factovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-factovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-factovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-factovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-factovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-factovp / varfact-qnty.
    end.
  end.
end.
assign
  price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
  price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
        assign
            temp_r-getsum.qnty              = buf_doc-line.fact-qnty
            temp_r-getsum.vat-pc            = buf_doc-line.vat-pc
            temp_r-getsum.slt-pc            = buf_doc-line.slt-pc
            temp_r-getsum.sum-with-taxes    = (if p-rubl-prices = no
                                                    then price-base-with-tax-sale
                                                    else price-rubl-with-tax-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-vat           = (if p-rubl-prices = no
                                                    then vat-base-sale
                                                    else vat-rubl-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-slt           = (if p-rubl-prices = no
                                                    then slt-base-sale
                                                    else slt-rubl-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-road-tax      = (if p-rubl-prices = no
                                                    then road-tax-base-sale
                                                    else road-tax-rubl-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-transport     = 0
            temp_r-getsum.sum-other         = (if p-rubl-prices = no
                                                    then discnt-base-sale
                                                    else discnt-rubl-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-excise        = (if p-rubl-prices = no
                                                    then excise-base-sale
                                                    else excise-rubl-sale) * buf_doc-line.fact-qnty
        .
    end.
end.
assign
    temp_r-getsum.sum-no-taxes      = temp_r-getsum.sum-with-taxes
                                      - temp_r-getsum.sum-vat
                                      - temp_r-getsum.sum-slt
    temp_r-getsum.sum-no-vat        = temp_r-getsum.sum-with-taxes - temp_r-getsum.sum-vat
    temp_r-getsum.sum-no-slt        = temp_r-getsum.sum-with-taxes - temp_r-getsum.sum-slt
.
if temp_r-getsum.qnty = 0 or temp_r-getsum.qnty = ?
then do:
    assign
        temp_r-getsum.price-no-taxes    = 0
        temp_r-getsum.price-no-vat      = 0
        temp_r-getsum.price-no-slt      = 0
    .
end.
else do:
    assign
        temp_r-getsum.price-no-taxes    = temp_r-getsum.sum-no-taxes / temp_r-getsum.qnty
        temp_r-getsum.price-no-vat      = temp_r-getsum.sum-no-vat   / temp_r-getsum.qnty
        temp_r-getsum.price-no-slt      = temp_r-getsum.sum-no-vat   / temp_r-getsum.qnty
    .
end.
end.
end procedure.
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-fmtcli-name          as character    no-undo.
define variable v-fmtcli-engl-name     as character    no-undo.
define variable v-fmtcli-addres        as character    no-undo.
define variable v-fmtcli-post-addres   as character    no-undo.
define variable v-fmtcli-full-addres   as character    no-undo.
define variable v-fmtcli-phone         as character    no-undo.
define variable v-fmtcli-inn           as character    no-undo.
define variable v-fmtcli-kpp           as character    no-undo.
define variable v-fmtcli-okpo          as character    no-undo.
define variable v-fmtcli-country       as character    no-undo.
define variable v-fmtcli-city          as character    no-undo.
define variable v-fmtcli-index         as character    no-undo.
define variable v-fmtcli-schet-exists  as logical      no-undo.
define variable v-fmtcli-bank-exists   as logical      no-undo.
define variable v-fmtcli-bank-r-schet  as character    no-undo.
define variable v-fmtcli-bank-c-schet  as character    no-undo.
define variable v-fmtcli-bank-bik      as character    no-undo.
define variable v-fmtcli-bank-name     as character    no-undo.
define variable v-fmtcli-bank-addres   as character    no-undo.
define variable v-fmtcli-bank-city     as character    no-undo.
procedure fmtcli-get-bank :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-curr-code      as integer          no-undo.
    define buffer buf_fin-schet     for ub.fin-schet.
    define buffer buf_fin-bank      for ub.fin-bank.
do
for buf_fin-schet
  , buf_fin-bank
on error undo, return error
:
    assign
        v-fmtcli-schet-exists       = no
        v-fmtcli-bank-exists        = no
        v-fmtcli-bank-r-schet       = "":U
        v-fmtcli-bank-c-schet       = "":U
        v-fmtcli-bank-bik           = "":U
        v-fmtcli-bank-name          = "":U
        v-fmtcli-bank-addres        = "":U
        v-fmtcli-bank-city          = "":U
    .
    search-for-schet:
    for each buf_fin-schet no-lock
       where buf_fin-schet.host-code = p-host-code
         and buf_fin-schet.cli-type  = p-obj-type
         and buf_fin-schet.cli-code  = p-obj-code
         and buf_fin-schet.curr-code = p-curr-code
    on error undo, return error
    :
        if buf_fin-schet.status_   = 'удал':U
        then do:
        end.
        else do:
            assign
                v-fmtcli-schet-exists   = yes
                v-fmtcli-bank-r-schet   = trim( buf_fin-schet.r-schet )
                v-fmtcli-bank-c-schet   = trim( buf_fin-schet.c-schet )
            .
            find first buf_fin-bank no-lock
                 where buf_fin-bank.host-code = p-host-code
                   and buf_fin-bank.code-bank = buf_fin-schet.code-bank
            no-error.
            if available buf_fin-bank
            then do:
                assign
                    v-fmtcli-bank-exists      = yes
                    v-fmtcli-bank-bik         = trim( buf_fin-bank.bik )
                    v-fmtcli-bank-name        = trim( buf_fin-bank.bank-name )
                    v-fmtcli-bank-addres      = trim(buf_fin-bank.addres)
                    v-fmtcli-bank-city      = trim(buf_fin-bank.bank-city)
                .
            end.
            else do:
                assign
                    v-fmtcli-bank-exists    = no
                    v-fmtcli-bank-bik       = "":U
                    v-fmtcli-bank-name      = "":U
                    v-fmtcli-bank-addres    = "":U
                    v-fmtcli-bank-city      = "":U
                .
            end.
            leave search-for-schet.
        end.
    end.
end.
end procedure.
procedure fmtcli-get-client :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
    define variable v-temp-fmtcli-address      as character     no-undo.
    define variable v-num-country-city    as integer      no-undo.
    define buffer buf_clients   for ub.clients.
    define buffer buf_firm      for ub.firm.
    define buffer buf_store     for ub.store.
    define buffer buf_shop      for ub.shop.
    define buffer buf_person    for ub.person.
do
for buf_clients
  , buf_firm
  , buf_store
  , buf_shop
  , buf_person
on error undo, return error
:
    assign
        v-fmtcli-name           = "":U
        v-fmtcli-addres         = "":U
        v-fmtcli-post-addres    = "":U
        v-fmtcli-full-addres    = "":U
        v-fmtcli-phone          = "":U
        v-fmtcli-inn            = "":U
        v-fmtcli-kpp            = "":U
        v-fmtcli-okpo           = "":U
        v-fmtcli-city           = "":U
        v-fmtcli-index          = "":U
        v-fmtcli-country        = "":U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    assign
        v-fmtcli-name = buf_clients.obj-name
    .
    case buf_clients.obj-type:
       when 'орг':U
       then do:
            find first buf_firm no-lock
                 where buf_firm.firm-code = buf_clients.obj-code
                 no-error
            .
            if available buf_firm
            then do:
                assign
                    v-num-country-city = num-entries( buf_firm.city )
                    v-fmtcli-engl-name = buf_firm.engl-name
                .
                if v-num-country-city > 0
                then do:
                    assign
                        v-fmtcli-country    = trim( entry( 1, buf_firm.city ) )
                    .
                end.
                if v-num-country-city > 1
                then do:
                    assign
                        v-fmtcli-city       = trim( entry( 2, buf_firm.city ) )
                    .
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input IF buf_firm.ind = 0 THEN "" ELSE string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.addres1, 1, 50 )
                    , input buf_firm.addres2
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                assign
                    v-fmtcli-addres = v-temp-fmtcli-address
                .
                if buf_firm.addres1 <> ?
                then do:
                    run fmtcli-concatenate-strings in this-procedure (
                          input v-fmtcli-full-addres
                        , input v-fmtcli-addres
                        , input ", ":U
                        , input 0
                        , output v-fmtcli-full-addres
                    ).
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.post-addr1, 1, 50 )
                    , input buf_firm.post-addr2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                assign
                    v-fmtcli-phone         = buf_firm.phone
                    v-fmtcli-inn           = buf_firm.inn
                    v-fmtcli-kpp           = buf_firm.kpp
                    v-fmtcli-okpo          = buf_firm.okpo
                    v-fmtcli-index         = string( buf_firm.ind )
                .
            end.
       end.
       when 'маг':U
       then do:
            find first buf_shop no-lock
                 where buf_shop.obj-code = buf_clients.obj-code
            .
            if available buf_shop
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_shop.addres1
                    , input buf_shop.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-post-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_shop.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'скл':U
       then do:
            find first buf_store no-lock
                 where buf_store.obj-code = buf_clients.obj-code
            .
            if available buf_store
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_store.addres1
                    , input buf_store.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_store.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'чел':U
       then do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            .
            if available buf_person
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input ( if buf_person.ind = 0 or buf_person.ind = ?
                              then "":U
                              else string( buf_person.ind, "999999")
                              )
                    , input buf_person.city
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-addres = buf_person.address
                .
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-addres
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-phone     = buf_person.phone1
                    v-fmtcli-inn       = buf_person.inn
                    v-fmtcli-kpp       = buf_person.kpp
                    v-fmtcli-okpo      = buf_person.okpo
                    v-fmtcli-city      = buf_person.city
                    v-fmtcli-index     = string( buf_person.ind )
                .
            end.
       end.
    end case.
end.
end procedure.
procedure fmtcli-concatenate-strings :
define input parameter p-string-1       as character        no-undo.
define input parameter p-string-2       as character        no-undo.
define input parameter p-delimiter      as character        no-undo.
define input parameter p-length         as integer          no-undo.
define output parameter p-out-string    as character        no-undo.
do
on error undo, return error
:
    assign
        p-out-string = ( if p-string-1 = ?
                         then "":U
                         else trim( p-string-1 ) )
    .
    assign
        p-out-string = p-out-string
                     + ( if p-out-string = "":U
                         or length( p-out-string ) = p-length
                         or p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else p-delimiter )
                     + ( if p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else trim( p-string-2 ) )
    .
end.
end procedure.
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-torgconf-ext-doc-type as character    no-undo.
define variable v-torgconf-outdate   as logical  init no    no-undo.
define variable v-torgconf-outnum    as logical  init no    no-undo.
define variable v-torgconf-outprim   as logical  init no    no-undo.
define variable v-torgconf-outdisc   as logical  init no    no-undo.
define variable v-torgconf-outsubs   as logical  init no    no-undo.
define variable v-torgconf-outrecv   as logical  init no    no-undo.
define variable v-torgconf-outegrp   as logical  init no    no-undo.
define variable v-torgconf-outt12    as logical  init no    no-undo.
define variable v-torgconf-outappr   as logical  init no    no-undo.
define variable v-torgconf-outrubl   as logical  init no    no-undo.
define variable v-torgconf-outhold   as logical  init no    no-undo.
define variable v-torgconf-outobj    as logical  init no    no-undo.
define variable v-torgconf-outexlst  as logical  init no    no-undo.
define variable v-torgconf-outexpas  as character  init no    no-undo.
define variable v-torgconf-outprncd  as logical  init no    no-undo.
define variable v-torgconf-outares   as logical  init no    no-undo.
define variable v-torgconf-outsend   as logical  init no    no-undo.
define variable v-torgconf-outasend  as logical  init no    no-undo.
define variable v-torgconf-outprops  as logical  init no    no-undo.
define variable v-torgconf-outogr    as character no-undo.
define variable v-torgconf-outR      as character no-undo.
define variable v-torgconf-outB      as character no-undo.
define variable v-torgconf-outC      as character no-undo.
define variable v-torgconf-outssdoc  as character init "":U no-undo.
define variable v-torgconf-self-host-code           as integer      no-undo.
define variable v-torgconf-self-host-type           as character    INITIAL 'орг':U  no-undo.
define variable v-torgconf-self-host-name           as character    no-undo.
define variable v-torgconf-self-host-engl-name           as character    no-undo.
define variable v-torgconf-self-host-addres         as character    no-undo.
define variable v-torgconf-self-host-post-addres    as character    no-undo.
define variable v-torgconf-self-host-phone          as character    no-undo.
define variable v-torgconf-self-host-inn            as character    no-undo.
define variable v-torgconf-self-host-kpp            as character    no-undo.
define variable v-torgconf-self-host-okpo           as character    no-undo.
define variable v-torgconf-self-host-egrip-date     as character    no-undo.
define variable v-torgconf-self-host-egrip-num      as character    no-undo.
define variable v-torgconf-sup-host-code            as integer      no-undo.
define variable v-torgconf-sup-host-type            as character  INITIAL 'орг':U  no-undo.
define variable v-torgconf-sup-host-name            as character    no-undo.
define variable v-torgconf-sup-host-engl-name            as character    no-undo.
define variable v-torgconf-sup-host-addres          as character    no-undo.
define variable v-torgconf-sup-host-post-addres     as character    no-undo.
define variable v-torgconf-sup-host-phone           as character    no-undo.
define variable v-torgconf-sup-host-inn             as character    no-undo.
define variable v-torgconf-sup-host-kpp             as character    no-undo.
define variable v-torgconf-sup-host-okpo            as character    no-undo.
define variable v-torgconf-sup-host-egrip-date      as character    no-undo.
define variable v-torgconf-sup-host-egrip-num       as character    no-undo.
define variable v-torgconf-temp-post-addres         as character    no-undo.
define variable v-torgconf-self-obj-type            as character    no-undo.
define variable v-torgconf-self-obj-code            as integer      no-undo.
define variable v-torgconf-self-obj-name            as character    no-undo.
define variable v-torgconf-self-obj-engl-name            as character    no-undo.
define variable v-torgconf-self-obj-addres          as character    no-undo.
define variable v-torgconf-self-obj-phone           as character    no-undo.
define variable v-torgconf-self-obj-inn             as character    no-undo.
define variable v-torgconf-self-obj-okpo            as character    no-undo.
define variable v-torgconf-sup-obj-type             as character    no-undo.
define variable v-torgconf-sup-obj-code             as integer      no-undo.
define variable v-torgconf-sup-obj-name             as character    no-undo.
define variable v-torgconf-sup-obj-engl-name             as character    no-undo.
define variable v-torgconf-sup-obj-addres           as character    no-undo.
define variable v-torgconf-sup-obj-phone            as character    no-undo.
define variable v-torgconf-sup-obj-inn              as character    no-undo.
define variable v-torgconf-sup-obj-okpo             as character    no-undo.
define variable v-torgconf-self-schet-exists        as logical      no-undo.
define variable v-torgconf-self-bank-exists         as logical      no-undo.
define variable v-torgconf-self-bank-r-schet        as character    no-undo.
define variable v-torgconf-self-bank-c-schet        as character    no-undo.
define variable v-torgconf-self-bank-bik            as character    no-undo.
define variable v-torgconf-self-bank-name           as character    no-undo.
define variable v-torgconf-self-bank-addres         as character    no-undo.
define variable v-torgconf-self-bank-city           as character    no-undo.
define variable v-torgconf-sup-schet-exists         as logical      no-undo.
define variable v-torgconf-sup-bank-exists          as logical      no-undo.
define variable v-torgconf-sup-bank-r-schet         as character    no-undo.
define variable v-torgconf-sup-bank-c-schet         as character    no-undo.
define variable v-torgconf-sup-bank-bik             as character    no-undo.
define variable v-torgconf-sup-bank-name            as character    no-undo.
define variable v-torgconf-sup-bank-addres          as character    no-undo.
define variable v-torgconf-sup-bank-city            as character    no-undo.
define variable v-torgconf-cli-type             as character    no-undo.
define variable v-torgconf-cli-code             as integer      no-undo.
define variable v-torgconf-cli-name             as character    no-undo.
define variable v-torgconf-cli-engl-name        as character    no-undo.
define variable v-torgconf-cli-addres           as character    no-undo.
define variable v-torgconf-cli-post-addres      as character    no-undo.
define variable v-torgconf-cli-phone            as character    no-undo.
define variable v-torgconf-cli-inn              as character    no-undo.
define variable v-torgconf-cli-kpp              as character    no-undo.
define variable v-torgconf-cli-okpo             as character    no-undo.
define variable v-torgconf-ship-type             as character    no-undo.
define variable v-torgconf-ship-code             as integer      no-undo.
define variable v-torgconf-ship-name             as character    no-undo.
define variable v-torgconf-ship-engl-name        as character    no-undo.
define variable v-torgconf-ship-addres           as character    no-undo.
define variable v-torgconf-ship-post-addres      as character    no-undo.
define variable v-torgconf-ship-phone            as character    no-undo.
define variable v-torgconf-ship-inn              as character    no-undo.
define variable v-torgconf-ship-kpp              as character    no-undo.
define variable v-torgconf-ship-okpo             as character    no-undo.
define variable v-torgconf-cli-schet-exists     as logical      no-undo.
define variable v-torgconf-cli-bank-exists      as logical      no-undo.
define variable v-torgconf-cli-bank-r-schet     as character    no-undo.
define variable v-torgconf-cli-bank-c-schet     as character    no-undo.
define variable v-torgconf-cli-bank-bik         as character    no-undo.
define variable v-torgconf-cli-bank-name        as character    no-undo.
define variable v-torgconf-cli-bank-addres      as character    no-undo.
define variable v-torgconf-cli-bank-city        as character    no-undo.
define variable v-torgconf-ship-schet-exists     as logical      no-undo.
define variable v-torgconf-ship-bank-exists      as logical      no-undo.
define variable v-torgconf-ship-bank-r-schet     as character    no-undo.
define variable v-torgconf-ship-bank-c-schet     as character    no-undo.
define variable v-torgconf-ship-bank-bik         as character    no-undo.
define variable v-torgconf-ship-bank-name        as character    no-undo.
define variable v-torgconf-ship-bank-addres      as character    no-undo.
define variable v-torgconf-ship-bank-city        as character    no-undo.
define variable v-torgconf-doc-code             as character    no-undo.
define variable v-torgconf-doc-date             as character    no-undo.
define variable v-torgconf-client-from          as character    no-undo.
define variable v-torgconf-organization         as character    no-undo.
define variable v-torgconf-organization-code    as character    no-undo.
define variable v-torgconf-organization-type    as character    no-undo.
define variable v-torgconf-okpo                 as character    no-undo.
define variable v-torgconf-cargo-to-name        as character    no-undo.
define variable v-torgconf-cargo-to-okpo        as character    no-undo.
define variable v-torgconf-cargo-to-addres      as character    no-undo.
define variable v-torgconf-cargo-to-value       as character    no-undo.
define variable v-torgconf-torg12-cargo-label   as character    no-undo.
define variable v-torgconf-torg12-cargo-string  as character    no-undo.
define variable v-torgconf-torg12-cargo-value   as character    no-undo.
define variable v-torgconf-torg12-cargo-okpo    as character    no-undo.
define variable v-torgconf-torg12-cargo-code    as character    no-undo.
define variable v-torgconf-torg12-cargo-type    as character    no-undo.
define variable v-torgconf-cargo-from-name      as character    no-undo.
define variable v-torgconf-cargo-from-okpo      as character    no-undo.
define variable v-torgconf-cargo-from-addres    as character    no-undo.
define variable v-torgconf-cargo-from-label     as character    no-undo.
define variable v-torgconf-cargo-from-value     as character    no-undo.
define variable v-torgconf-cargo-from-sf-value  as character    no-undo.
define variable v-torgconf-cargo-from-string    as character    no-undo.
define variable v-torgconf-supplier             as character    no-undo.
define variable v-torgconf-suppi                as character    no-undo.
define variable v-torgconf-saler                as character    no-undo.
define variable v-torgconf-sal                  as character    no-undo.
define variable v-torgconf-consignee            as character    no-undo.
define variable v-torgconf-cons                 as character    no-undo.
define variable v-torgconf-supplier-okpo        as character    no-undo.
define variable v-torgconf-saler-okpo           as character    no-undo.
define variable v-torgconf-consignee-okpo       as character    no-undo.
define variable v-torgconf-supplier-code        as character    no-undo.
define variable v-torgconf-saler-code           as character    no-undo.
define variable v-torgconf-consignee-code       as character    no-undo.
define variable v-torgconf-supplier-type        as character    no-undo.
define variable v-torgconf-saler-type           as character    no-undo.
define variable v-torgconf-consignee-type       as character    no-undo.
define variable v-torgconf-supplier-name        as character    no-undo.
define variable v-torgconf-supplier-engl-name   as character    no-undo.
define variable v-torgconf-saler-name           as character    no-undo.
define variable v-torgconf-consignee-name       as character    no-undo.
define variable v-torgconf-supplier-addr        as character    no-undo.
define variable v-torgconf-saler-addr           as character    no-undo.
define variable v-torgconf-consignee-addr       as character    no-undo.
define variable v-torgconf-supplier-inn         as character    no-undo.
define variable v-torgconf-saler-inn            as character    no-undo.
define variable v-torgconf-consignee-inn        as character    no-undo.
define variable v-torgconf-supplier-kpp         as character    no-undo.
define variable v-torgconf-saler-kpp            as character    no-undo.
define variable v-torgconf-consignee-kpp        as character    no-undo.
define variable v-torgconf-plat-rasch-doc       as character    no-undo.
define variable v-torgconf-main-boss            as character    no-undo.
define variable v-torgconf-main-buh             as character    no-undo.
define variable v-torgconf-reason               as character    no-undo.
define variable v-torgconf-sf-buyer-name        as character    no-undo.
define variable v-torgconf-sf-buyer-code        as character    no-undo.
define variable v-torgconf-sf-buyer-type        as character    no-undo.
define variable v-torgconf-sf-buyer-addr        as character    no-undo.
define variable v-torgconf-wth-cargo-to         as character    no-undo.
define variable p-torgconf-date-warrant         as date      no-undo.
define variable p-torgconf-N-warrant            as character no-undo.
define variable p-torgconf-accept-fname         as character no-undo.
define variable p-torgconf-accept-position      as character no-undo.
define variable p-torgconf-t_pass-fname         as character no-undo.
define variable p-torgconf-t_pass-position      as character no-undo.
define variable p-torgconf-nfindoc              as character no-undo.
define variable p-torgconf-ndovwho              as character no-undo.
define variable p-torgconf-ddog                 as date      no-undo.
define variable p-torgconf-ndog                 as character no-undo.
define variable v-torgconf-vdoc-code            as character no-undo.
define variable v-doc-code-attr                 as character no-undo.
define variable v-torgconf-doc-date-attr        as character no-undo.
define variable v-torgconf-vdoc-date            as character no-undo.
define variable v-torgconf-main-boss-post       as character no-undo.
define variable v-torgconf-ogr-name             as character no-undo.
define variable v-torgconf-ogr-post             as character no-undo.
define variable v-name                          as character    no-undo.
define variable v-form-name    as character    no-undo.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
procedure wthcattr-sprcli :
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode  as character no-undo.
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  DEFINE VARIABLE v-value as character no-undo .
  define variable v-cli-type as character no-undo .
  define variable v-cli-code as integer no-undo .
  define buffer buf_clients   for ub.clients.
  define variable v_rid as character no-undo.
  define variable ref-rec as recid no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
   if p-value <> '':U then do:
    assign
    v-cli-type = substring(p-value, 1, 3)
    v-cli-code = integer(substring(p-value, 4))
    no-error.
    if error-status:error then do:
      assign
      v-cli-type = '':U
      v-cli-code = 0
      .
    end.
   end.
   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = v-cli-type AND
            buf_clients.obj-code = v-cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                input parparentproc
               ,input if p-mode = 'ИЗМЕНЕНИЕ':U then "b-sel":U else "":U
               ,input v-cli-type
               ,input 'все':U
               ,input 'все':U
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  ELSE if p-mode = 'ИЗМЕНЕНИЕ':U then DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-cli-type
               ,input 'все':U
               ,input 'текущие':U
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  else do:
    message
    if p-value = "":U then 'Атрибут не задан!'
    else substitute('Не найден клиент &1',p-value)
    view-as alert-box warning.
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      v-value = buf_clients.obj-type + string(buf_clients.obj-code, ">>>>>>>>9").
    end.
  end.
  if v-value <> p-value then do:
    p-value = v-value.
    p-setted = yes.
  end.
  end.
end procedure.
  define new global shared variable g#wthcalib as handle no-undo.
procedure torgconf-read :
do
on error undo, return error
:
    define input parameter p-form-name  as character    no-undo.
    define input parameter p-host-code  as integer      no-undo.
    define input parameter p-obj-type   as character    no-undo.
    define input parameter p-obj-code   as integer      no-undo.
    define variable v-outdate   as character     no-undo.
    define variable v-outares   as character     no-undo.
    define variable v-outsend   as character     no-undo.
    define variable v-outasend  as character     no-undo.
    define variable v-outprops  as character     no-undo.
    define variable v-outnum    as character     no-undo.
    define variable v-outprim   as character     no-undo.
    define variable v-outdisc   as character     no-undo.
    define variable v-outsubs   as character     no-undo.
    define variable v-outrecv   as character     no-undo.
    define variable v-outegrp   as character     no-undo.
    define variable v-outt12    as character     no-undo.
    define variable v-outappr   as character     no-undo.
    define variable v-outrubl   as character     no-undo.
    define variable v-outhold   as character     no-undo.
    define variable v-outobj    as character     no-undo.
    define variable v-outexlst  as character     no-undo.
    define variable v-outprncd  as character     no-undo.
    define variable v-par-type  as character     no-undo.
    define variable v-outogr    as character     no-undo.
    define variable v-outR      as character     no-undo.
    define variable v-outB      as character     no-undo.
    define variable v-outC      as character     no-undo.
    assign
        v-torgconf-outdate  = no
        v-torgconf-outnum   = no
        v-torgconf-outprim  = no
        v-torgconf-outdisc  = no
        v-torgconf-outsubs  = no
        v-torgconf-outrecv  = no
        v-torgconf-outegrp  = no
        v-torgconf-outt12   = no
        v-torgconf-outappr  = no
        v-torgconf-outrubl  = no
        v-torgconf-outhold  = no
        v-torgconf-outobj   = no
        v-torgconf-outexlst = no
        v-torgconf-outexpas = "":U
        v-torgconf-outprncd = yes
        v-torgconf-outares  = no
        v-torgconf-outsend  = no
        v-torgconf-outasend  = no
        v-torgconf-outprops  = no
        v-form-name          = p-form-name
    .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'prt-glob':U
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
    if thbjattr_thbj-attr.prop-code = 'outprncd':U then v-outprncd =  string(thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'outrecv':U  then v-outrecv  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outprops':U then v-outprops =  thbjattr_thbj-attr.property-value-character .
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input p-obj-type
  ,input p-obj-code
  ,input 'prt-obj':U
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
    if thbjattr_thbj-attr.prop-code = 'outdate':U  then v-outdate  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outares':U  then v-outares  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outnum':U   then v-outnum   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outprim':U  then v-outprim  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outdisc':U  then v-outdisc  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outsubs':U  then v-outsubs  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outegrp':U  then v-outegrp  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outt12':U   then v-outt12   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outappr':U  then v-outappr  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outrubl':U  then v-outrubl  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outhold':U  then v-outhold  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outobj':U   then v-outobj   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outsend':U  then v-outsend  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outasend':U then v-outasend =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outogr':U   then v-torgconf-outogr   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outR':U     then v-torgconf-outR     =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outB':U     then v-torgconf-outB     =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outssdoc':U then v-torgconf-outssdoc =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outC':U     then v-torgconf-outC     =  thbjattr_thbj-attr.property-value-character .
end.
    run gbl/conf-rd.p ("outexpas", "":U, "":U, 0, "":U, "":U, "":U, no, output v-torgconf-outexpas, output v-par-type) no-error.
    if error-status :error
    then do:
        assign
            v-torgconf-outexpas = "":U
        .
    end.
    assign
        v-torgconf-outprncd = ( v-outprncd = "yes":U )
    .
    if p-form-name <> ""
    and p-form-name <> ?
    then do:
        run gbl/conf-rd.p ("outexlst" , p-host-code, p-obj-type, p-obj-code, "", "", "", no, output v-outexlst , output v-par-type) no-error.
        if error-status :error
        then do:
            assign
                v-outexlst           = ""
            .
        end.
        if lookup( p-form-name, v-outdate ) <> 0
        then do:
            assign
                v-torgconf-outdate  = yes
            .
        end.
        if lookup( p-form-name, v-outares ) <> 0
        then do:
            assign
                v-torgconf-outares  = yes
            .
        end.
        if lookup( p-form-name, v-outnum  ) <> 0
        then do:
            assign
                v-torgconf-outnum   = yes
            .
        end.
        if lookup( p-form-name, v-outprim ) <> 0
        then do:
            assign
                v-torgconf-outprim  = yes
            .
        end.
        if lookup( p-form-name, v-outdisc ) <> 0
        then do:
            assign
                v-torgconf-outdisc  = yes
            .
        end.
        if lookup( p-form-name, v-outsubs ) <> 0
        then do:
            assign
                v-torgconf-outsubs  = yes
            .
        end.
        if lookup( p-form-name, v-outrecv ) <> 0
        then do:
            assign
                v-torgconf-outrecv  = yes
            .
        end.
        if lookup( p-form-name, v-outegrp ) <> 0
        then do:
            assign
                v-torgconf-outegrp  = yes
            .
        end.
        if lookup( p-form-name, v-outt12  ) <> 0
        then do:
            assign
                v-torgconf-outt12   = yes
            .
        end.
        if lookup( p-form-name, v-outappr  ) <> 0
        then do:
            assign
                v-torgconf-outappr   = yes
            .
        end.
        if lookup( p-form-name, v-outrubl  ) <> 0
        then do:
            assign
                v-torgconf-outrubl   = yes
            .
        end.
        if lookup( p-form-name, v-outhold  ) <> 0
        then do:
            assign
                v-torgconf-outhold   = yes
            .
        end.
        if lookup( p-form-name, v-outobj   ) <> 0
        then do:
            assign
                v-torgconf-outobj    = yes
            .
        end.
        if lookup( p-form-name, v-outsend   ) <> 0
        then do:
            assign
                v-torgconf-outsend    = yes
            .
        end.
        if lookup( p-form-name, v-outasend   ) <> 0
        then do:
            assign
                v-torgconf-outasend    = yes
            .
        end.
        if lookup( p-form-name, v-outprops   ) <> 0
        then do:
            assign
                v-torgconf-outprops    = yes
            .
        end.
        if lookup( p-form-name, v-outexlst ) <> 0
        then do:
            assign
                v-torgconf-outexlst  = yes
            .
        end.
     assign
      v-name = p-form-name.
end.
end.
end procedure.
procedure torgconf-get-self-param :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
    define variable v-par-type     as character    no-undo.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message(1))
:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    if v-torgconf-outhold = yes
    then do:
        run torgconf-get-holdfirm-code in this-procedure (
              input p-obj-type
            , input p-obj-code
            , output v-torgconf-self-host-code
        ).
        if v-torgconf-self-host-code = 0
        then do:
            return error.
        end.
    end.
    else do:
        assign
            v-torgconf-self-host-code = v-host-code
        .
    end.
    if v-torgconf-self-host-code = 0
    then do:
        assign
            v-torgconf-self-host-name           = "":U
            v-torgconf-self-host-addres         = "":U
            v-torgconf-self-host-post-addres    = "":U
            v-torgconf-self-host-phone          = "":U
            v-torgconf-self-host-inn            = "":U
            v-torgconf-self-host-kpp            = "":U
            v-torgconf-self-host-okpo           = "":U
            v-torgconf-self-host-egrip-date     = "":U
            v-torgconf-self-host-egrip-num      = "":U
        .
    end.
    else do:
        run fmtcli-get-client in this-procedure (
              input 'орг':U
            , input v-torgconf-self-host-code
        ).
        assign
            v-torgconf-self-host-name        = v-fmtcli-name
            v-torgconf-self-host-engl-name   = v-fmtcli-engl-name
            v-torgconf-self-host-addres      = v-fmtcli-full-addres
            v-torgconf-self-host-post-addres = v-fmtcli-post-addres
            v-torgconf-self-host-phone       = v-fmtcli-phone
            v-torgconf-self-host-inn         = v-fmtcli-inn
            v-torgconf-self-host-kpp         = v-fmtcli-kpp
            v-torgconf-self-host-okpo        = v-fmtcli-okpo
        .
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'egrip-date':U
            , output v-torgconf-self-host-egrip-date
            , output v-par-type
        ).
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'egrip-num':U
            , output v-torgconf-self-host-egrip-num
            , output v-par-type
        ).
        run fmtcli-get-bank in this-procedure (
              input v-host-code
            , input 'орг':U
            , input v-torgconf-self-host-code
            , input p-curr-code
        ).
    end.
    assign
        v-torgconf-self-schet-exists = v-fmtcli-schet-exists
        v-torgconf-self-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-self-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-self-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-self-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-self-bank-name    = v-fmtcli-bank-name
        v-torgconf-self-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-self-bank-city    = v-fmtcli-bank-city
    .
    assign
        v-torgconf-self-obj-type = p-obj-type
        v-torgconf-self-obj-code = p-obj-code
    .
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-self-obj-name       = v-fmtcli-name
        v-torgconf-self-obj-engl-name  = v-fmtcli-engl-name
        v-torgconf-self-obj-addres     = v-fmtcli-full-addres
        v-torgconf-temp-post-addres    = v-fmtcli-post-addres
        v-torgconf-self-obj-phone      = v-fmtcli-phone
        v-torgconf-self-obj-inn        = v-fmtcli-inn
        v-torgconf-self-obj-okpo       = v-fmtcli-okpo
    .
end.
end procedure.
procedure torgconf-get-recepient-param :
define input parameter torgconfdoc-code   as character                  no-undo.
define output parameter v-code-rec        as integer                    no-undo .
define output parameter v-type-rec        as character                  no-undo initial 'C':U.
define output parameter v-codefirm-rec    as integer                    no-undo .
define output parameter v-curcode-rec     as integer                    no-undo .
     define variable  v-recipient-code  as character                  no-undo .
     define variable  v-recipient       like ub.doc-attr.attr-value   no-undo.
     define variable  v-trdcattr-type   as character                  no-undo initial 'C':U.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input torgconfdoc-code ,
                        input 'Recipient':U ,
                       output v-recipient-code ,
                       output v-trdcattr-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " torgconfdoc-code skip
      "Атрибут: " 'Recipient':U skip
      "Значение: " v-recipient skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
  assign
    v-recipient  = v-recipient-code
    v-type-rec = substring(v-recipient-code,1,3)
    v-code-rec  = int(substring(v-recipient-code,4,15))
    no-error
  .
  if v-type-rec = ? then v-type-rec = "" .
  if v-code-rec  = ? then v-code-rec  =  0 .
  end procedure.
procedure torgconf-get-wthrecepient-param :
define input parameter torgconfdoc-code   as character                  no-undo.
define output parameter v-code-rec        as integer                    no-undo .
define output parameter v-type-rec        as character                  no-undo initial 'C':U.
define output parameter v-codefirm-rec    as integer                    no-undo .
define output parameter v-curcode-rec     as integer                    no-undo .
     define variable  v-recipient-code  as character                  no-undo .
     define variable  v-recipient       like ub.doc-attr.attr-value   no-undo.
     define variable  v-trdcattr-type   as character                  no-undo initial 'C':U.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input torgconfdoc-code ,
                        input 'wthconsignee':U ,
                       output v-recipient-code ,
                       output v-trdcattr-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " torgconfdoc-code skip
      "Атрибут: " 'wthconsignee':U skip
      "Значение: " v-recipient skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
  assign
    v-recipient  = v-recipient-code
    v-type-rec = substring(v-recipient-code,1,3)
    v-code-rec  = int(substring(v-recipient-code,4,15))
    no-error
  .
  if v-type-rec = ? then v-type-rec = "" .
  if v-code-rec  = ? then v-code-rec  =  0 .
  end procedure.
procedure torgconf-get-warrant:
define input parameter p-torgconfdoc-code           as character                  no-undo.
    define variable p-torgconf-date-type            as character no-undo.
    define variable p-torgconf-N-type               as character no-undo.
    define variable p-torgconf-accept-n-type        as character no-undo.
    define variable p-torgconf-accept-p-type        as character no-undo.
    define variable p-torgconf-nfindoc-type         as character no-undo.
    define variable p-torgconf-ndovwho-type         as character no-undo.
    define variable p-torgconf-ndog-type            as character no-undo.
    define variable p-torgconf-dfindoc-type         as date      no-undo.
    define variable p-torgconf-ddog-type            as date      no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 'ddov':U ,
                       output p-torgconf-date-warrant ,
                       output p-torgconf-date-type ) no-error .
     if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 'ddov':U skip
      "Значение: " p-torgconf-date-warrant skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 'ndov':U ,
                       output p-torgconf-N-warrant ,
                       output p-torgconf-N-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 'ndov':U skip
      "Значение: " p-torgconf-N-warrant skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_accept-fname':U ,
                       output p-torgconf-accept-fname ,
                       output p-torgconf-accept-n-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_accept-fname':U skip
      "Значение: " p-torgconf-accept-fname skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_accept-position':U ,
                       output p-torgconf-accept-position ,
                       output p-torgconf-accept-p-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_accept-position':U skip
      "Значение: " p-torgconf-accept-position skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_pass-fname':U ,
                       output p-torgconf-t_pass-fname ,
                       output p-torgconf-accept-n-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_pass-fname':U skip
      "Значение: " p-torgconf-t_pass-fname skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_pass-position':U ,
                       output p-torgconf-t_pass-position ,
                       output p-torgconf-accept-p-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_pass-position':U skip
      "Значение: " p-torgconf-t_pass-position skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 'ndovwho':U ,
                       output p-torgconf-ndovwho ,
                       output p-torgconf-ndovwho-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 'ndovwho':U skip
      "Значение: " p-torgconf-ndovwho skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
  end procedure.
procedure torgconf-get-warrant-wth:
define input parameter p-torgconfdoc-code           as character                  no-undo.
    define variable p-torgconf-ndovwho-type         as character no-undo.
    define variable p-torgconf-accept-n-type        as character no-undo.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-torgconfdoc-code ,
                        input 'wthproxy':U ,
                       output p-torgconf-ndovwho ,
                       output p-torgconf-ndovwho-type ) no-error .
      if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры tdat-val":U skip
         "Документ: " p-torgconfdoc-code skip
         "Атрибут: " 'wthproxy':U skip
         "Значение: " p-torgconf-ndovwho skip
         trim( error-status :get-message (1) ) skip
         return-value skip
         view-as alert-box error.
      undo, return error return-value.
      end.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-torgconfdoc-code ,
                        input 'wthreceiver':U ,
                       output p-torgconf-accept-fname ,
                       output p-torgconf-accept-n-type ) no-error .
      if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры tdat-val":U skip
         "Документ: " p-torgconfdoc-code skip
         "Атрибут: " 't_accept-fname':U skip
         "Значение: " p-torgconf-accept-fname skip
         trim( error-status :get-message (1) ) skip
         return-value skip
         view-as alert-box error.
      undo, return error return-value.
      end.
  end procedure.
procedure torgconf-get-sup-param :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
    define variable v-par-type     as character    no-undo.
do
on error undo, return error
:
    assign
       v-torgconf-sup-host-code = v-host-code
    .
    if v-torgconf-sup-host-code = 0
    then do:
        assign
            v-torgconf-sup-host-name           = "":U
            v-torgconf-sup-host-addres         = "":U
            v-torgconf-sup-host-post-addres    = "":U
            v-torgconf-sup-host-phone          = "":U
            v-torgconf-sup-host-inn            = "":U
            v-torgconf-sup-host-kpp            = "":U
            v-torgconf-sup-host-okpo           = "":U
            v-torgconf-sup-host-egrip-date     = "":U
            v-torgconf-sup-host-egrip-num      = "":U
        .
    end.
    else do:
        run fmtcli-get-client in this-procedure (
              input 'орг':U
            , input v-torgconf-sup-host-code
        ).
        assign
            v-torgconf-sup-host-name        = v-fmtcli-name
            v-torgconf-sup-host-engl-name   = v-fmtcli-engl-name
            v-torgconf-sup-host-addres      = v-fmtcli-full-addres
            v-torgconf-sup-host-post-addres = v-fmtcli-post-addres
            v-torgconf-sup-host-phone       = v-fmtcli-phone
            v-torgconf-sup-host-inn         = v-fmtcli-inn
            v-torgconf-sup-host-kpp         = v-fmtcli-kpp
            v-torgconf-sup-host-okpo        = v-fmtcli-okpo
        .
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-sup-host-code
            , input 'egrip-date':U
            , output v-torgconf-sup-host-egrip-date
            , output v-par-type
        ).
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-sup-host-code
            , input 'egrip-num':U
            , output v-torgconf-sup-host-egrip-num
            , output v-par-type
        ).
        run fmtcli-get-bank in this-procedure (
              input v-host-code
            , input 'орг':U
            , input v-torgconf-sup-host-code
            , input p-curr-code
        ).
    end.
    assign
        v-torgconf-sup-schet-exists = v-fmtcli-schet-exists
        v-torgconf-sup-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-sup-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-sup-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-sup-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-sup-bank-name    = v-fmtcli-bank-name
        v-torgconf-sup-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-sup-bank-city    = v-fmtcli-bank-city
    .
    assign
        v-torgconf-sup-obj-type = p-obj-type
        v-torgconf-sup-obj-code = p-obj-code
    .
    if trim(p-obj-type) <> ""
    and p-obj-code <> 0
    then do:
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-sup-obj-name        = v-fmtcli-name
        v-torgconf-sup-obj-engl-name   = v-fmtcli-engl-name
        v-torgconf-sup-obj-addres      = v-fmtcli-full-addres
        v-torgconf-temp-post-addres    = v-fmtcli-post-addres
        v-torgconf-sup-obj-phone       = v-fmtcli-phone
        v-torgconf-sup-obj-inn         = v-fmtcli-inn
        v-torgconf-sup-obj-okpo        = v-fmtcli-okpo
    .
   end.
   end.
end procedure.
procedure torgconf-get-cli-param :
define input parameter p-host-obj-code      as integer          no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-torgconf-cli-type = p-obj-type
        v-torgconf-cli-code = p-obj-code
    .
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-cli-name         = trim( v-fmtcli-name          )
        v-torgconf-cli-engl-name    = trim( v-fmtcli-engl-name          )
        v-torgconf-cli-addres       = trim( v-fmtcli-full-addres   )
        v-torgconf-cli-post-addres  = trim( v-fmtcli-post-addres   )
        v-torgconf-cli-phone        = trim( v-fmtcli-phone         )
        v-torgconf-cli-inn          = trim( v-fmtcli-inn           )
        v-torgconf-cli-kpp          = trim( v-fmtcli-kpp           )
        v-torgconf-cli-okpo         = trim( v-fmtcli-okpo          )
    .
   run fmtcli-get-bank in this-procedure (
          input p-host-obj-code
        , input p-obj-type
        , input p-obj-code
        , input p-curr-code
    ).
    assign
        v-torgconf-cli-schet-exists = v-fmtcli-schet-exists
        v-torgconf-cli-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-cli-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-cli-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-cli-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-cli-bank-name    = v-fmtcli-bank-name
        v-torgconf-cli-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-cli-bank-city    = v-fmtcli-bank-city
    .
end.
end procedure.
procedure torgconf-get-ship-param :
define input parameter p-host-obj-code      as integer          no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-torgconf-ship-type = p-obj-type
        v-torgconf-ship-code = p-obj-code
    .
    if trim(p-obj-type) = ""
    and p-obj-code = 0
    then do:
    assign
        v-torgconf-ship-name         = "":U
        v-torgconf-ship-addres       = "":U
        v-torgconf-ship-post-addres  = "":U
        v-torgconf-ship-phone        = "":U
        v-torgconf-ship-inn          = "":U
        v-torgconf-ship-kpp          = "":U
        v-torgconf-ship-okpo         = "":U
    .
    end.
    else do:
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-ship-name         = trim( v-fmtcli-name          )
        v-torgconf-ship-engl-name    = trim( v-fmtcli-engl-name          )
        v-torgconf-ship-addres       = trim( v-fmtcli-full-addres   )
        v-torgconf-ship-post-addres  = trim( v-fmtcli-post-addres   )
        v-torgconf-ship-phone        = trim( v-fmtcli-phone         )
        v-torgconf-ship-inn          = trim( v-fmtcli-inn           )
        v-torgconf-ship-kpp          = trim( v-fmtcli-kpp           )
        v-torgconf-ship-okpo         = trim( v-fmtcli-okpo          )
    .
    end.
        run fmtcli-get-bank in this-procedure (
          input p-host-obj-code
        , input p-obj-type
        , input p-obj-code
        , input p-curr-code
    ).
    assign
        v-torgconf-ship-schet-exists = v-fmtcli-schet-exists
        v-torgconf-ship-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-ship-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-ship-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-ship-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-ship-bank-name    = v-fmtcli-bank-name
        v-torgconf-ship-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-ship-bank-city    = v-fmtcli-bank-city
    .
end.
end procedure.
procedure torgconf-get-holdfirm-code :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define output parameter p-firm-code as integer          no-undo.
    define variable v-firm-code-str     as character    no-undo.
    define variable v-par-type          as character    no-undo.
    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
    run gbl/clntat-v.p (
          input p-obj-type
        , input p-obj-code
        , input 'holdfirm-code':U
        , output v-firm-code-str
        , output v-par-type
    ).
    assign
        p-firm-code = integer( v-firm-code-str )
    no-error.
    if error-status :error
    then do:
        message
            "Неверно задан код фирмы для печати накладных."
        view-as alert-box warning.
        assign
            p-firm-code = 0
        .
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = p-firm-code
        no-error.
        if not available buf_clients
        then do:
            message
                "Включен параметр 'Список печатных форм, для которых должна быть задана фирма для печати накладных' (outhold)" skip
                "Не найдена фирма по заданному коду фирмы для печати накладных."
            view-as alert-box warning.
            assign
                p-firm-code = 0
            .
        end.
    end.
end.
end procedure.
procedure torgconf-get-post-head:
define input  parameter p-obj-type             as character        no-undo.
define input  parameter p-obj-code             as integer          no-undo.
define output parameter p-torgconf-post-head   as character        no-undo.
   define variable v-host-code         as integer      no-undo.
   define buffer buf_sysconf     for ub.sysconf.
     assign
      p-torgconf-post-head  = ""
     .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
   find first buf_sysconf no-lock
   where buf_sysconf.host-code = v-host-code
   no-error.
   if available buf_sysconf
   then do:
      assign
         p-torgconf-post-head = buf_sysconf.head-position
      .
   end.
end procedure.
procedure torgconf-get-storekeeper:
define input  parameter p-wrkr                   as integer          no-undo.
define output parameter p-torgconf-wrkr-name     as character        no-undo.
define output parameter p-torgconf-post          as character        no-undo.
   define buffer buf_sysconf     for ub.sysconf.
   define buffer buf_person      for ub.person.
   define buffer buf_shop        for ub.shop .
   define buffer buf_store       for ub.store .
   if v-torgconf-outC = "no_print"
   then do:
      assign p-torgconf-post = ""
             p-torgconf-wrkr-name = ""
             .
   end.
   if v-torgconf-outC = "clad_doc"
   then do:
      run rep/get-psn.p
            (input  p-wrkr
            ,output p-torgconf-wrkr-name
            ) .
      find first buf_person no-lock
      where buf_person.psn-code = p-wrkr
      no-error.
      if available buf_person
      then do:
        p-torgconf-post = buf_person.position.
      end.
      if p-torgconf-post = "?":U then p-torgconf-post = "".
      if p-torgconf-wrkr-name = "?":U then p-torgconf-wrkr-name = "".
   end.
   if v-torgconf-outC = "clad_obj"
   then do:
      CASE v-torgconf-self-obj-type:
      WHEN 'маг':U
      THEN DO:
         find first buf_shop no-lock
         where buf_shop.obj-code = v-torgconf-self-obj-code
         .
         assign
            p-torgconf-wrkr-name = buf_shop.store-man
            p-torgconf-post = ""
         .
         if p-torgconf-wrkr-name = "?":U then p-torgconf-wrkr-name = "".
      END.
      WHEN 'скл':U
      THEN DO:
         find first buf_store no-lock
         where buf_store.obj-code = v-torgconf-self-obj-code
         .
         assign
            p-torgconf-wrkr-name = buf_store.store-man
            p-torgconf-post = ""
         .
         if p-torgconf-wrkr-name = "?":U then p-torgconf-wrkr-name = "".
      END.
      OTHERWISE DO:
         assign
            p-torgconf-post = "":U
            p-torgconf-wrkr-name = "":U
         .
      END.
      END CASE.
   end.
 end procedure.
procedure torgconf-get-form-header :
define input parameter p-for-inverse    as logical          no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-print-doc      as logical          no-undo.
define input parameter p-doc-date       as date             no-undo.
define input parameter p-fact-date      as date             no-undo.
define input parameter p-doc-type       as character        no-undo.
define input parameter p-status_        as character        no-undo.
define input parameter p-reverse        as logical          no-undo.
define input parameter p-sf-par         as logical          no-undo.
    define variable v-attr-type         as character    no-undo.
    define variable v-doc-code-standard as logical      no-undo.
    define variable v-doc-date-standard as logical      no-undo.
    define variable v-par-consignee-addres  as character    no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-dcode-attr        as character    no-undo.
    define variable v-ddate-attr        as character    no-undo.
    define variable v-doc-date          as character    no-undo.
    define variable v-doc-code          as character    no-undo.
    define variable v-par-type          as character    no-undo.
    define variable v-attr              as character    no-undo.
    define buffer buf_firm          for ub.firm .
    define buffer buf_clients       for ub.clients .
    define buffer buf_sysconf       for ub.sysconf .
    define buffer buf_shop          for ub.shop .
    define buffer buf_store         for ub.store .
    define buffer buf_person        for ub.person .
    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer buf_wth-doc       for ub.wth-doc .
    do
for buf_firm
  , buf_clients
  , buf_sysconf
  , buf_shop
  , buf_trn-doc
  , buf_person
  , buf_wth-doc
on error undo, return error
:
    if p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    then do:
        assign
            v-torgconf-supplier         = substitute( "&1&2&3&4&5", v-torgconf-cli-name, ( if v-torgconf-cli-addres = "":U then "":U else ", " ),
                                          v-torgconf-cli-addres, ( if v-torgconf-cli-phone = "":U then "":U else ", " ), v-torgconf-cli-phone )
            v-torgconf-suppi            = substitute( "&1&2&3&4&5", v-torgconf-cli-name, ( if v-torgconf-cli-addres = "":U then "":U else ", " ),
                                          v-torgconf-cli-addres, ( if v-torgconf-cli-phone = "":U then "":U else ", " ), v-torgconf-cli-phone )
            v-torgconf-saler            = substitute( "&1&2&3&4&5", v-torgconf-self-host-name, ( if v-torgconf-self-host-addres = "":U then "":U else ", " ),
                                          v-torgconf-self-host-addres, ( if v-torgconf-self-host-phone = "":U then "":U else ", " ),v-torgconf-self-host-phone )
            v-torgconf-consignee        = substitute( "&1&2&3&4&5", v-torgconf-sup-host-name, ( if v-torgconf-sup-host-addres = "":U then "":U else ", " ),
                                          v-torgconf-sup-host-addres, ( if v-torgconf-sup-host-phone = "":U then "":U else ", " ), v-torgconf-sup-host-phone  )
            v-torgconf-supplier-okpo    = v-torgconf-cli-okpo
            v-torgconf-saler-okpo       = v-torgconf-self-host-okpo
            v-torgconf-consignee-okpo   = v-torgconf-sup-host-okpo
            v-torgconf-supplier-code    = substitute( "&1", v-torgconf-cli-code         )
            v-torgconf-supplier-type    = v-torgconf-cli-type
            v-torgconf-saler-code       = substitute( "&1", v-torgconf-self-host-code   )
            v-torgconf-saler-type       = v-torgconf-self-host-type
            v-torgconf-consignee-code   = substitute( "&1", v-torgconf-sup-host-code   )
            v-torgconf-consignee-type   = v-torgconf-sup-host-type
            v-torgconf-supplier-name    = substitute( "&1", v-torgconf-cli-name         )
            v-torgconf-saler-name       = substitute( "&1", v-torgconf-self-host-name   )
            v-torgconf-consignee-name   = substitute( "&1", v-torgconf-sup-host-name   )
            v-torgconf-supplier-addr    = substitute( "&1", v-torgconf-cli-addres       )
            v-torgconf-saler-addr       = substitute( "&1", v-torgconf-self-host-addres )
            v-torgconf-consignee-addr   = substitute( "&1", v-torgconf-sup-host-addres )
            v-torgconf-supplier-inn     = substitute( "&1", v-torgconf-cli-inn          )
            v-torgconf-supplier-engl-name     = substitute( "&1", v-torgconf-cli-engl-name          )
            v-torgconf-saler-inn        = substitute( "&1", v-torgconf-self-host-inn    )
            v-torgconf-consignee-inn    = substitute( "&1", v-torgconf-sup-host-inn    )
            v-torgconf-supplier-kpp     = substitute( "&1", v-torgconf-cli-kpp          )
            v-torgconf-saler-kpp        = substitute( "&1", v-torgconf-self-host-kpp    )
            v-torgconf-consignee-kpp    = substitute( "&1", v-torgconf-sup-host-kpp    )
        .
        if v-torgconf-cli-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-supplier = v-torgconf-supplier
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-cli-bank-r-schet
                                , v-torgconf-cli-bank-c-schet
                                )
                v-torgconf-suppi = v-torgconf-supplier
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-cli-bank-r-schet
                                , v-torgconf-cli-bank-c-schet
                                )
            .
            if v-torgconf-cli-bank-exists = yes
            then do:
                assign
                    v-torgconf-supplier = v-torgconf-supplier
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-cli-bank-bik
                                    , v-torgconf-cli-bank-name
                                    ,(if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                    )
                   v-torgconf-suppi = v-torgconf-supplier
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-cli-bank-bik
                                    , v-torgconf-cli-bank-name
                                    ,(if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                    )
                .
            end.
        end.
        if v-torgconf-self-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-saler = v-torgconf-saler
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-self-bank-r-schet
                                , v-torgconf-self-bank-c-schet
                                )
            .
            if v-torgconf-self-bank-exists = yes
            then do:
                assign
                    v-torgconf-saler = v-torgconf-saler
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-self-bank-bik
                                    , v-torgconf-self-bank-name
                                    , v-torgconf-self-bank-addres
                                    )
                .
            end.
        end.
        if v-torgconf-sup-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-consignee = v-torgconf-consignee
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-sup-bank-r-schet
                                , v-torgconf-sup-bank-c-schet
                                )
            .
          if v-torgconf-sup-bank-exists = yes
           then do:
             assign
                v-torgconf-consignee = v-torgconf-consignee
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-sup-bank-bik
                                    , v-torgconf-sup-bank-name
                                    , v-torgconf-sup-bank-addres
                                    )
                .
            end.
        end.
   if v-torgconf-outares = yes  AND v-form-name  = "torg12":U
   then do:
       assign
         v-torgconf-supplier = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-cli-inn, v-torgconf-cli-kpp) ELSE "":U
                                                , v-torgconf-cli-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-cli-code )
                                                      else "":U )
                                                , v-torgconf-cli-post-addres
                                                , v-torgconf-cli-phone
                                                , ( if v-torgconf-cli-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-cli-bank-r-schet
                                                            , v-torgconf-cli-bank-c-schet
                                                            , v-torgconf-cli-bank-bik
                                                            , v-torgconf-cli-bank-name
                                                            , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )     )
                                                      else "":U )
                                             )
      .
   end.
    v-torgconf-suppi = substitute(  "&1&2&3 &4 &5&6"
                                     , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-cli-inn, v-torgconf-cli-kpp) ELSE "":U
                                     , v-torgconf-cli-name
                                     , ( if v-torgconf-outprncd = yes
                                         then substitute( " (&1)", v-torgconf-cli-code )
                                         else "":U )
                                     , v-torgconf-cli-addres
                                     , v-torgconf-cli-phone
                                     , ( if v-torgconf-cli-bank-r-schet <> "":U
                                         AND v-form-name                  = "torg12":U
                                         then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-cli-bank-r-schet
                                                        , v-torgconf-cli-bank-c-schet
                                                        , v-torgconf-cli-bank-bik
                                                        , v-torgconf-cli-bank-name
                                                        , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) ))
                                                else "":U )
                                     ).
    end.
    else do:
    v-torgconf-suppi = substitute(  "&1&2&3 &4 &5&6"
                                     , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                     , v-torgconf-self-host-name
                                     , ( if v-torgconf-outprncd = yes
                                         then substitute( " (&1)", v-torgconf-self-host-code )
                                         else "":U )
                                     , v-torgconf-self-host-addres
                                     , v-torgconf-self-host-phone
                                     , ( if v-torgconf-self-bank-r-schet <> "":U
                                         AND v-form-name                  = "torg12":U
                                         then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        ).
      if v-torgconf-outares = yes
      and p-reverse = no
      then do:
         assign
            v-par-consignee-addres = v-torgconf-ship-post-addres
         .
      end.
      if v-torgconf-outares = no
      and p-reverse = no
      then do:
         assign
            v-par-consignee-addres = v-torgconf-ship-addres
         .
      end.
      if p-reverse = yes
      then do:
          assign
            v-par-consignee-addres = v-torgconf-ship-addres
          .
      end.
        assign
            v-torgconf-supplier         = substitute( "&1&2&3&4&5", v-torgconf-self-host-name, ( if v-torgconf-self-host-addres = "":U then "":U else ", " ), v-torgconf-self-host-addres,
                                          ( if v-torgconf-self-host-phone = "":U then "":U else ", " ), v-torgconf-self-host-phone )
            v-torgconf-saler            = substitute( "&1&2&3&4&5", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres,
                                          ( if v-torgconf-cli-phone       = "":U then "":U else ", " ), v-torgconf-cli-phone )
            v-torgconf-consignee        = substitute( "&1&2&3&4&5", v-torgconf-ship-name      , ( if v-par-consignee-addres   = "":U then "":U else ", " ), v-par-consignee-addres,
                                           ( if v-torgconf-ship-phone   = "":U then "":U else ", " ), v-torgconf-ship-phone)
            v-torgconf-supplier-okpo    = v-torgconf-self-host-okpo
            v-torgconf-saler-okpo       = v-torgconf-cli-okpo
            v-torgconf-consignee-okpo   = v-torgconf-ship-okpo
            v-torgconf-supplier-code    = substitute( "&1", v-torgconf-self-host-code   )
            v-torgconf-supplier-code    = v-torgconf-self-host-type
            v-torgconf-saler-code       = substitute( "&1", v-torgconf-cli-code         )
            v-torgconf-saler-type       = v-torgconf-cli-type
            v-torgconf-consignee-code   = substitute( "&1", v-torgconf-ship-code         )
            v-torgconf-consignee-type   = v-torgconf-ship-type
            v-torgconf-supplier-name    = substitute( "&1", v-torgconf-self-host-name   )
            v-torgconf-saler-name       = substitute( "&1", v-torgconf-cli-name         )
            v-torgconf-consignee-name   = substitute( "&1", v-torgconf-ship-name         )
            v-torgconf-supplier-addr    = substitute( "&1", v-torgconf-self-host-addres )
            v-torgconf-saler-addr       = substitute( "&1", v-torgconf-cli-addres       )
            v-torgconf-consignee-addr   = substitute( "&1", v-par-consignee-addres                )
            v-torgconf-supplier-inn     = substitute( "&1", v-torgconf-self-host-inn    )
            v-torgconf-supplier-engl-name     = substitute( "&1", v-torgconf-self-host-engl-name    )
            v-torgconf-saler-inn        = substitute( "&1", v-torgconf-cli-inn          )
            v-torgconf-consignee-inn    = substitute( "&1", v-torgconf-ship-inn          )
            v-torgconf-supplier-kpp     = substitute( "&1", v-torgconf-self-host-kpp    )
            v-torgconf-saler-kpp        = substitute( "&1", v-torgconf-cli-kpp          )
            v-torgconf-consignee-kpp    = substitute( "&1", v-torgconf-ship-kpp          )
            v-torgconf-sf-buyer-name    = v-torgconf-consignee-name
            v-torgconf-sf-buyer-code    = v-torgconf-consignee-code
            v-torgconf-sf-buyer-type    = v-torgconf-consignee-type
            v-torgconf-sf-buyer-addr    = v-torgconf-consignee-addr
        .
        if v-torgconf-self-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-supplier = v-torgconf-supplier
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-self-bank-r-schet
                                , v-torgconf-self-bank-c-schet
                                )
            .
            if v-torgconf-self-bank-exists = yes
            then do:
                assign
                    v-torgconf-supplier = v-torgconf-supplier
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-self-bank-bik
                                    , v-torgconf-self-bank-name
                                    , v-torgconf-self-bank-addres
                                    )
                .
            end.
        end.
        if v-torgconf-cli-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-saler = v-torgconf-saler
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-cli-bank-r-schet
                                , v-torgconf-cli-bank-c-schet
                                )
            .
            if v-torgconf-cli-bank-exists = yes
            then do:
                assign
                    v-torgconf-saler = v-torgconf-saler
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-cli-bank-bik
                                    , v-torgconf-cli-bank-name
                                    , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                    )
                .
            end.
        end.
        if v-torgconf-ship-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-consignee = v-torgconf-consignee
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-ship-bank-r-schet
                                , v-torgconf-ship-bank-c-schet
                                )
            .
            if v-torgconf-ship-bank-exists = yes
            then do:
                assign
                    v-torgconf-consignee = v-torgconf-consignee
                        + substitute( " БИК &1 в &2  &3"
                                    , v-torgconf-ship-bank-bik
                                    , v-torgconf-ship-bank-name
                                    , (if v-torgconf-ship-bank-city = "":U then "":U else ( "г. " + v-torgconf-ship-bank-city) )
                                    )
                .
            end.
        end.
   if p-reverse = yes
      then do:
       if  v-torgconf-outares = yes then v-torgconf-saler = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-post-addres       = "":U then "":U else ", " ), v-torgconf-cli-post-addres       )
         .
       else v-torgconf-saler = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres       ) .
              if v-torgconf-cli-schet-exists = yes
              AND v-form-name                  = "torg12":U
                  then do:
                        assign
                           v-torgconf-saler = v-torgconf-saler
                              + substitute( ", р/с &1 к/с &2"
                                          , v-torgconf-cli-bank-r-schet
                                          , v-torgconf-cli-bank-c-schet
                                          )
            .
            if v-torgconf-cli-bank-exists = yes
            AND v-form-name                  = "torg12":U
               then do:
                  assign
                     v-torgconf-saler = v-torgconf-saler
                           + substitute( " БИК &1 в &2  &3"
                                       , v-torgconf-cli-bank-bik
                                       , v-torgconf-cli-bank-name
                                       , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                       )
                  .
            end.
        end.
        v-torgconf-saler-name = v-torgconf-cli-name .
        v-torgconf-saler-okpo = v-torgconf-cli-okpo.
   end.
    if trim(v-torgconf-consignee) = ""
    and v-torgconf-outares = yes
    and p-reverse = no
    then do:
      assign
      v-torgconf-consignee = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-post-addres       = "":U then "":U else ", " ), v-torgconf-cli-post-addres)
      .
         if v-torgconf-cli-schet-exists = yes
         AND v-form-name                  = "torg12":U
            then do:
                  assign
                     v-torgconf-consignee = v-torgconf-consignee
                        + substitute( ", р/с &1 к/с &2"
                                    , v-torgconf-cli-bank-r-schet
                                    , v-torgconf-cli-bank-c-schet
                                    )
                  .
                  if v-torgconf-cli-bank-exists = yes
                  then do:
                     assign
                        v-torgconf-consignee = v-torgconf-consignee
                              + substitute( " БИК &1 в &2 &3"
                                          , v-torgconf-cli-bank-bik
                                          , v-torgconf-cli-bank-name
                                          , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                          )
                     .
                  end.
            end.
    end.
    if trim(v-torgconf-consignee) = ""
    and v-torgconf-outares = no
    and p-reverse = no
    then do:
    assign
      v-torgconf-consignee = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres)
      .
         if v-torgconf-cli-schet-exists = yes
         AND v-form-name                  = "torg12":U
            then do:
                  assign
                     v-torgconf-consignee = v-torgconf-consignee
                        + substitute( ", р/с &1 к/с &2"
                                    , v-torgconf-cli-bank-r-schet
                                    , v-torgconf-cli-bank-c-schet
                                    )
                  .
                  if v-torgconf-cli-bank-exists = yes
                  then do:
                     assign
                        v-torgconf-consignee = v-torgconf-consignee
                              + substitute( " БИК &1 в &2 &3"
                                          , v-torgconf-cli-bank-bik
                                          , v-torgconf-cli-bank-name
                                          , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                          )
                     .
                  end.
            end.
    end.
    if trim(v-torgconf-consignee) = ""
    and    p-reverse = yes
    then do:
      assign
      v-torgconf-consignee = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres)
      v-torgconf-sf-buyer-name    = v-torgconf-cli-name
      v-torgconf-sf-buyer-code    = string(v-torgconf-cli-code)
      v-torgconf-sf-buyer-type    = v-torgconf-cli-type
      v-torgconf-sf-buyer-addr    = v-torgconf-cli-addres
      .
         if v-torgconf-cli-schet-exists = yes
         AND v-form-name                  = "torg12":U
            then do:
                  assign
                     v-torgconf-consignee = v-torgconf-consignee
                        + substitute( ", р/с &1 к/с &2"
                                    , v-torgconf-cli-bank-r-schet
                                    , v-torgconf-cli-bank-c-schet
                                    )
                  .
                  if v-torgconf-cli-bank-exists = yes
                  then do:
                     assign
                        v-torgconf-consignee = v-torgconf-consignee
                              + substitute( " БИК &1 в &2 &3"
                                          , v-torgconf-cli-bank-bik
                                          , v-torgconf-cli-bank-name
                                          , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                          )
                     .
                  end.
            end.
    end.
   end.
    if p-for-inverse = yes
    or p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    then do:
        assign
            v-torgconf-cargo-from-name      = v-torgconf-cli-name
            v-torgconf-cargo-from-okpo      = v-torgconf-cli-okpo
            v-torgconf-cargo-from-addres    = v-torgconf-cli-addres
            v-torgconf-cargo-to-name        = v-torgconf-self-host-name
            v-torgconf-cargo-to-okpo        = v-torgconf-self-host-okpo
            v-torgconf-cargo-to-addres      = v-torgconf-self-host-post-addres
        .
        if v-torgconf-outares then v-torgconf-cargo-from-addres    = v-torgconf-cli-post-addres  .
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'cargo-to':U
            , output v-torgconf-cargo-to-value
            , output v-attr-type
        ).
        run gbl/clntat-v.p (
              input v-torgconf-cli-type
            , input v-torgconf-cli-code
            , input 'cargo-from':U
            , output v-torgconf-cargo-from-value
            , output v-attr-type
        ).
        assign
            v-torgconf-cargo-from-sf-value = v-torgconf-cargo-from-value
        .
        if v-torgconf-cargo-to-value = "":U
        then do:
            if v-torgconf-ext-doc-type = 'pz':U
            OR v-torgconf-outobj = TRUE
            then do:
                assign
                    v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1)", v-torgconf-self-host-code )
                                                    else "":U )
                                                    , v-torgconf-self-obj-addres
                                                    , v-torgconf-self-obj-phone
                                                    )
                .
            end.
            else if v-torgconf-outasend = yes then do:
                assign
                    v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1)", v-torgconf-self-host-code )
                                                    else "":U )
                                                    , v-torgconf-self-host-post-addres
                                                    , v-torgconf-self-host-phone
                                                    )
                .
            end.
            else do:
                assign
                    v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1)", v-torgconf-self-host-code )
                                                    else "":U )
                                                    , v-torgconf-self-host-addres
                                                    , v-torgconf-self-host-phone
                                                    )
                .
            end.
        end.
        if v-torgconf-cargo-from-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-value = substitute( "&1&2 &3 &4"
                                                , v-torgconf-cli-name
                                                , ( if v-torgconf-outprncd = yes
                                                  then substitute( " (&1)", v-torgconf-cli-code )
                                                  else "":U )
                                                , v-torgconf-cargo-from-addres
                                                , v-torgconf-cli-phone
                                                )
            .
        end.
        if v-torgconf-cargo-from-sf-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-sf-value  = v-torgconf-cargo-from-name
                                                    + "  ":U
                                                    + v-torgconf-cargo-from-addres
            .
        end.
    end.
    else do:
        if v-torgconf-outsend then do:
        assign
            v-torgconf-cargo-from-name      = v-torgconf-self-obj-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-obj-addres
        .
        end.
        else if v-torgconf-outobj then assign
            v-torgconf-cargo-from-name      = v-torgconf-self-host-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-obj-addres
        .
        else if v-torgconf-outasend then assign
            v-torgconf-cargo-from-name      = v-torgconf-self-host-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-host-post-addres
        .
        else  assign
            v-torgconf-cargo-from-name      = v-torgconf-self-host-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-host-addres
        .
        assign
            v-torgconf-cargo-from-okpo      = v-torgconf-self-host-okpo
            v-torgconf-cargo-to-name        = v-torgconf-cli-name
            v-torgconf-cargo-to-okpo        = v-torgconf-cli-okpo
            v-torgconf-cargo-to-addres      = v-torgconf-cli-post-addres
        .
        run gbl/clntat-v.p (
              input v-torgconf-cli-type
            , input v-torgconf-cli-code
            , input 'cargo-to':U
            , output v-torgconf-cargo-to-value
            , output v-attr-type
        ).
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'cargo-from':U
            , output v-torgconf-cargo-from-value
            , output v-attr-type
        ).
        assign
            v-torgconf-cargo-from-sf-value = v-torgconf-cargo-from-value
        .
        if v-torgconf-cargo-to-value = "":U
        then do:
            assign
                v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-cli-name
                                                    , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-cli-code )
                                                      else "":U )
                                                    , v-torgconf-cli-post-addres
                                                    , v-torgconf-cli-phone
                                                    )
            .
        end.
        if v-torgconf-cargo-from-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-value = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                    , v-torgconf-self-host-post-addres
                                                    , v-torgconf-self-host-phone
                                                    )
            .
        end.
        if v-torgconf-cargo-from-sf-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-sf-value  = v-torgconf-cargo-from-name
                                                    + "  ":U
                                                    +  v-torgconf-cargo-from-addres
            .
        end.
    end.
    if lookup( v-torgconf-ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u ) <> 0
    then do:
        assign
            v-torgconf-wth-cargo-to = "":U
        .
        run gbl/wthat-v.p (
              input p-doc-code
            , input 'wthconsignee':U
            , output v-torgconf-wth-cargo-to
            , output v-attr-type
        ).
        assign
            v-torgconf-wth-cargo-to = trim( v-torgconf-wth-cargo-to )
        .
        if v-torgconf-wth-cargo-to <> "":U
        then do:
            run fmtcli-get-client in this-procedure (
                  input substring( v-torgconf-wth-cargo-to, 1, 3  )
                , input integer( trim( substring( v-torgconf-wth-cargo-to, 4 ) ) )
            ).
            assign
                v-torgconf-cargo-to-value = substitute( "&1&2 &3 &4"
                                                    , v-fmtcli-name
                                                    , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", trim( substring( v-torgconf-wth-cargo-to, 4 ) ) )
                                                      else "":U )
                                                    , v-fmtcli-full-addres
                                                    , v-fmtcli-phone
                                                    )
            .
        end.
    end.
    if ( p-doc-type = 'при':U
    or p-doc-type = 'возврат':U )
    then do:
      if v-torgconf-outares = yes
      THEN DO:
         assign
            v-torgconf-torg12-cargo-value   = v-torgconf-supplier
            v-torgconf-torg12-cargo-code    = v-torgconf-supplier-code
            v-torgconf-torg12-cargo-type    = v-torgconf-supplier-type
            v-torgconf-torg12-cargo-type    = v-torgconf-supplier-okpo
         .
      END.
      ELSE DO:
         case v-form-name:
         WHEN "torg12":U
         THEN DO:
            assign
               v-torgconf-torg12-cargo-value   = SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                            , v-torgconf-supplier
                                                            , v-torgconf-supplier-inn
                                                            , v-torgconf-supplier-kpp
                                                            )
               v-torgconf-torg12-cargo-code    = v-torgconf-supplier-code
               v-torgconf-torg12-cargo-type    = v-torgconf-supplier-type
            .
         END.
         END CASE.
      END.
    end.
    else do:
      IF v-form-name = "torg12":U
      THEN DO:
         assign
            v-torgconf-torg12-cargo-value   = SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                         , v-torgconf-consignee
                                                         , v-torgconf-consignee-inn
                                                         , v-torgconf-consignee-kpp
                                                         )
            v-torgconf-torg12-cargo-code    = v-torgconf-consignee-code
            v-torgconf-torg12-cargo-type    = v-torgconf-consignee-type
            v-torgconf-torg12-cargo-okpo    = v-torgconf-consignee-okpo
         .
      END.
      ELSE DO:
         assign
            v-torgconf-torg12-cargo-value   = v-torgconf-consignee
            v-torgconf-torg12-cargo-code    = v-torgconf-consignee-code
            v-torgconf-torg12-cargo-type    = v-torgconf-consignee-type
         .
      END.
    end.
   assign
         v-torgconf-cons = v-torgconf-consignee
         v-torgconf-sal  = v-torgconf-saler
   .
   if p-reverse = yes
      then do:
              assign                v-torgconf-torg12-cargo-value   = SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                         , v-torgconf-saler
                                                         , v-torgconf-saler-inn
                                                         , v-torgconf-saler-kpp
                                                         )
            v-torgconf-torg12-cargo-code    = v-torgconf-saler-code
            v-torgconf-torg12-cargo-type    = v-torgconf-saler-type
            v-torgconf-torg12-cargo-okpo    = v-torgconf-saler-okpo
            v-torgconf-saler      = v-torgconf-cons
            v-torgconf-consignee  = v-torgconf-sal
            v-torgconf-saler-name = v-torgconf-sf-buyer-name
            v-torgconf-saler-code = v-torgconf-sf-buyer-code
            v-torgconf-saler-type = v-torgconf-sf-buyer-type
            v-torgconf-saler-addr = v-torgconf-sf-buyer-addr
            v-torgconf-saler-okpo = v-torgconf-consignee-okpo
            v-torgconf-saler-inn = v-torgconf-consignee-inn
            v-torgconf-saler-kpp = v-torgconf-consignee-kpp
      .
      end.
   if ( p-doc-type = 'при':U
   or p-doc-type = 'возврат':U )
   and not p-for-inverse
   and v-torgconf-ext-doc-type <> 're':U
   and v-torgconf-ext-doc-type <> 'pz':U
      then do:
         assign
            v-torgconf-torg12-cargo-label   = "Грузоотправитель"
            v-torgconf-torg12-cargo-okpo    = v-torgconf-cargo-from-okpo
            v-torgconf-torg12-cargo-string  = v-torgconf-torg12-cargo-label + ": ":U + v-torgconf-torg12-cargo-value
         .
      end.
      else do:
         assign
            v-torgconf-torg12-cargo-label   = "Грузополучатель"
            v-torgconf-torg12-cargo-string  = v-torgconf-torg12-cargo-label + ": ":U + v-torgconf-torg12-cargo-value
         .
      end.
    if v-torgconf-ext-doc-type = 're':U
    or v-torgconf-ext-doc-type = 'pz':U
    then do:
      assign
         v-torgconf-organization = v-torgconf-supplier
         v-torgconf-organization-code = v-torgconf-supplier-code
         v-torgconf-organization-type = v-torgconf-supplier-type
      .
    end.
    else do:
        if p-for-inverse = yes
        then do:
            assign
                v-torgconf-organization-code = substitute( "&1", v-torgconf-cli-code)
                v-torgconf-organization-type = v-torgconf-cli-type
                v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-cli-inn, v-torgconf-cli-kpp) ELSE "":U
                                            , v-torgconf-cli-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-cli-code )
                                                else "":U )
                                            , v-torgconf-cli-addres
                                            , v-torgconf-cli-phone
                                            , ( if v-torgconf-cli-bank-r-schet <> "":U
                                              AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-cli-bank-r-schet
                                                        , v-torgconf-cli-bank-c-schet
                                                        , v-torgconf-cli-bank-bik
                                                        , v-torgconf-cli-bank-name
                                                        , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )     )
                                                else "":U )
                                        )
                v-torgconf-okpo         = v-torgconf-cli-okpo
            .
        end.
        else do:
            assign
                v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
                v-torgconf-organization-type = v-torgconf-self-host-type
                v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                            , v-torgconf-self-host-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-host-code )
                                                else "":U )
                                            , v-torgconf-self-host-addres
                                            , v-torgconf-self-host-phone
                                            , ( if v-torgconf-self-bank-r-schet <> "":U
                                                AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        )
                v-torgconf-okpo         = v-torgconf-self-host-okpo
            .
        end.
    end.
    assign
        v-torgconf-client-from = ( if p-doc-type = 'при':U
                                   or v-torgconf-ext-doc-type = 're':U
                                   or v-torgconf-ext-doc-type = 'pz':U
                                   then " ":U
                                   else substitute( "&1&2"
                                            , v-torgconf-self-obj-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-obj-code  )
                                                else "":U ) ) )
    .
if   v-torgconf-outsend = no
and (  p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    )
and (  v-torgconf-ext-doc-type <> 're':U
    or v-torgconf-ext-doc-type <> 'pz':U
    )
then do:
   if v-torgconf-outobj = yes
   then do:
       assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-obj-addres
                                                , v-torgconf-self-obj-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                  AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
   end.
   else do:
      if v-torgconf-outasend = no
      then do:
      assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-host-addres
                                                , v-torgconf-self-host-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
      end.
      else do:
      assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-host-post-addres
                                                , v-torgconf-self-host-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
      end.
   end.
end.
if  v-torgconf-outsend = yes
and (  p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    )
and ( v-torgconf-ext-doc-type <> 're':U
    or v-torgconf-ext-doc-type <> 'pz':U
    )
then do:
      assign
      v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
      v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                             , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                             , v-torgconf-self-obj-name
                                             , ( if v-torgconf-outprncd = yes
                                                   then substitute( " (&1)", v-torgconf-self-obj-code )
                                                   else "":U )
                                             , v-torgconf-self-obj-addres
                                             , v-torgconf-self-obj-phone
                                             , ( if v-torgconf-self-bank-r-schet <> "":U
                                                   AND v-form-name                  = "torg12":U
                                                   then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                         , v-torgconf-self-bank-r-schet
                                                         , v-torgconf-self-bank-c-schet
                                                         , v-torgconf-self-bank-bik
                                                         , v-torgconf-self-bank-name
                                                         , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                   else "":U )
                                          )
      .
end.
   if( p-doc-type <> 'при':U
   or  p-doc-type <> 'возврат':U )
   and v-torgconf-outsend  = no
   and v-torgconf-outasend = yes
   and v-torgconf-outobj   = no
   then do:
       assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-host-post-addres
                                                , v-torgconf-self-host-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
   end.
   if ( not ( ( p-doc-type = 'при':U
             or p-doc-type = 'возврат':U )
               ))
    and v-torgconf-outsend = yes
    then do:
      assign
          v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
          v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                            , v-torgconf-self-obj-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-host-code )
                                                else "":U )
                                            , v-torgconf-self-obj-addres
                                            , v-torgconf-self-obj-phone
                                            , ( if v-torgconf-self-bank-r-schet <> "":U
                                                AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        )
          v-torgconf-client-from = ""
      .
    end.
    if ( not ( ( p-doc-type = 'при':U
             or p-doc-type = 'возврат':U )
     ))
    and v-torgconf-outsend = no
    and v-torgconf-outobj  = yes
    then do:
        assign
          v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
          v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                            , v-torgconf-self-host-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-host-code )
                                                else "":U )
                                            , v-torgconf-self-obj-addres
                                            , v-torgconf-self-obj-phone
                                            , ( if v-torgconf-self-bank-r-schet <> "":U
                                                AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        )
        .
    end.
    if v-torgconf-outnum = yes
    then do:
        assign
            v-torgconf-doc-code = "          "
        .
    end.
    else do:
        if lookup( v-torgconf-ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u ) <> 0
        then do:
            run gbl/wthat-v.p (
                  input p-doc-code
                , input 'wthnsf':U
                , output v-torgconf-doc-code
                , output v-attr-type
            ).
            assign
                v-doc-code-standard = ( trim( v-torgconf-doc-code ) = "":U )
            .
        end.
        else do:
            assign
                v-doc-code-standard = yes
            .
        end.
        if v-doc-code-standard = yes
        then do:
            run gbl/trdcat-v.p (
                input p-doc-code
                , input 'print-num':U
                , output v-torgconf-doc-code
                , output v-attr-type
            ).
            if v-torgconf-doc-code = "":U
            then do:
                if p-for-inverse = yes
                then do:
                    if p-doc-type = 'при':U
                    then do:
                        assign
                            v-torgconf-doc-code = entry( 1, p-doc-code, "=":U )
                        no-error.
                    end.
                    else do:
                        assign
                            v-torgconf-doc-code = entry( 1, p-doc-code, "-":U )
                        no-error.
                    end.
                    define variable v-doc-code-integer    as integer      no-undo.
                    assign
                        v-doc-code-integer = integer( v-torgconf-doc-code )
                    no-error.
                    if error-status :error
                    then do:
                        assign
                            v-doc-code-integer = 0
                        .
                    end.
                    if v-torgconf-doc-code = ""
                    then do:
                        assign v-torgconf-doc-code = substr( p-doc-code, 1, 2 )
                                            + string( month( p-doc-date ),  "99" )
                                            + string( day( p-doc-date ),    "99" )
                        .
                    end.
                    else do:
                        assign v-torgconf-doc-code = string( month( p-doc-date ), ">9" )
                                            + trim( string( day( p-doc-date ), ">9" ) )
                                            + string( v-doc-code-integer )
                        .
                    end.
                end.
                else do:
                    assign
                        v-torgconf-doc-code = p-doc-code
                    .
                end.
            end.
        end.
    end.
    if v-torgconf-outnum = yes
    then do:
        assign
            v-torgconf-vdoc-code = " "
        .
    end.
    else do:
      assign
         v-torgconf-vdoc-code = p-doc-code
      .
      if p-doc-type = 'при':U
      then do:
         run gbl/trdcat-v.p (
                    input p-doc-code
                  , input 'nids':U
                  , output v-doc-code-attr
                  , output v-attr-type
               ).
      end.
      if  p-doc-type =  'рас':U
      or  p-doc-type =  'возврат':U
      then do:
         run gbl/trdcat-v.p (
                    input p-doc-code
                  , input 'print-num':U
                  , output v-doc-code-attr
                  , output v-attr-type
               ).
      end.
      if trim(v-doc-code-attr) <> ""
      then do:
         assign
            v-torgconf-vdoc-code = v-doc-code-attr
         .
      end.
    end.
    if v-torgconf-outdate = yes
    then do:
        assign
         v-torgconf-doc-date =  "          "
         v-torgconf-vdoc-date = "          "
        .
    end.
    else do:
        if lookup( v-torgconf-ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u ) <> 0
        then do:
            run gbl/wthat-v.p (
                  input p-doc-code
                , input 'wthdsf':U
                , output v-torgconf-doc-date
                , output v-attr-type
            ).
            assign
                v-doc-date-standard = ( trim( v-torgconf-doc-date ) = "":U )
            .
        end.
        else do:
            assign
                v-doc-date-standard = yes
            .
        end.
        if v-doc-date-standard = yes
        then do:
            assign v-torgconf-doc-date =  ( if p-status_ <> 'факт':U
                                            or p-print-doc = yes
                                            then string( p-doc-date, "99/99/9999" )
                                            else string( p-fact-date, "99/99/9999" )
                                        )
            .
        end.
        assign v-torgconf-vdoc-date = ( if p-status_ <> 'факт':U
                                          then string( p-doc-date, "99/99/9999" )
                                          else string( p-fact-date, "99/99/9999" )
                                      )
        .
        if p-doc-type = 'при':U
           then do:
              run gbl/trdcat-v.p (
                  input p-doc-code
                , input 'dids':U
                , output v-torgconf-doc-date-attr
                , output v-attr-type
             ).
           end.
        if trim(v-torgconf-doc-date-attr) <> ""
        then do:
            assign v-torgconf-vdoc-date = v-torgconf-doc-date-attr
            .
        end.
    end.
   if  v-name <> 'wthtrg12'
   and v-name <> 'wthfct'
   and v-name <> 'wthm11'
   then do:
    run gbl/trdcat-v.p (
                  input p-doc-code
                , input 'NFinDoc':U
                , output v-dcode-attr
                , output v-par-type
            ) no-error.
    if error-status :error
    then do:
        assign v-dcode-attr = "".
    end.
    run gbl/trdcat-v.p (
                  input p-doc-code
                , input 'DFinDoc':U
                , output v-ddate-attr
                , output v-par-type
            ) no-error.
    if error-status :error
    then do:
        assign v-ddate-attr = "".
    end.
   end.
   else do:
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-doc-code ,
                        input 'wthpaydoc':U ,
                       output v-attr ,
                       output v-attr-type )  .
   end.
    case v-torgconf-outssdoc
    :
     when "nacl":U
     then do:
         if  v-name <> 'wthtrg12'
         and v-name <> 'wthfct'
         and v-name <> 'wthm11'
         then do:
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1 от &2 &3"
                                                , if trim(v-dcode-attr) = "" then v-torgconf-doc-code else v-dcode-attr
                                                , if trim(v-ddate-attr) = "" then v-torgconf-doc-date else v-ddate-attr
                                                , ( if p-status_ <> 'факт':U
                                                   then string( "(" + caps( p-status_ ) + ")" )
                                                   else "":U )
                                             )
            .
         end.
         else do:
         if trim(v-attr) = ""
         then do:
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1 от &2 &3",
                                                        v-torgconf-doc-code,
                                                        v-torgconf-doc-date,
                                                         ( if p-status_ <> 'факт':U then string( "(" + caps( p-status_ ) + ")" ) else "":U )
                                                        )
            .
         end.
         else do:
            assign
               v-torgconf-plat-rasch-doc = v-attr.
         end.
         end.
     end.
     otherwise do:
         if  v-name <> 'wthtrg12'
         and v-name <> 'wthfct'
         and v-name <> 'wthm11'
         then do:
            IF v-dcode-attr <> "":U
            OR v-ddate-attr <> "":U
            THEN
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1 от &2"
                                                   , if trim(v-dcode-attr) = "" then "" else v-dcode-attr
                                                   , if trim(v-ddate-attr) = "" then "" else v-ddate-attr
                                                )
            .
         end.
         else do:
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1", if trim(v-attr) = "" then "" else v-attr)
            .
         end.
     end.
    end case.
   if v-torgconf-outB = "no_print"
   then do:
      assign v-torgconf-main-buh = "".
   end.
   if v-torgconf-outB = "glbuh_firm"
   then do:
         if v-torgconf-self-host-code = 0
         then do:
         end.
         else do:
            find first buf_sysconf no-lock
               where buf_sysconf.host-code = v-torgconf-self-host-code
            .
            assign
               v-torgconf-main-buh  = buf_sysconf.snr-accnt
            .
         end.
   end.
   if v-torgconf-outB = "buh_obj"
   then do:
      CASE v-torgconf-self-obj-type:
      WHEN 'маг':U
      THEN DO:
         find first buf_shop no-lock
         where buf_shop.obj-code = v-torgconf-self-obj-code
         .
         assign
            v-torgconf-main-buh  = entry(1,buf_shop.acct,"|")
         .
      END.
      WHEN 'скл':U
      THEN DO:
         find first buf_store no-lock
         where buf_store.obj-code = v-torgconf-self-obj-code
         .
         assign
            v-torgconf-main-buh  = buf_store.store-man
         .
      END.
      OTHERWISE DO:
         assign
            v-torgconf-main-buh  = "":U
         .
      END.
      END CASE.
   end.
   if v-torgconf-outR = "no_print"
      then do:
         assign
            v-torgconf-main-boss = ""
            v-torgconf-main-boss-post = ""
         .
      end.
   if v-torgconf-outR = "ruk_firm"
      then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = v-torgconf-self-host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-main-boss-post = buf_sysconf.head-position
            .
         end.
         find first buf_clients no-lock
         where buf_clients.obj-type = 'орг':U
         and buf_clients.obj-code = v-torgconf-self-host-code
         .
         find first buf_firm no-lock
         where buf_firm.firm-code = buf_clients.obj-code
         no-error.
         if available buf_firm
         then do:
            assign
               v-torgconf-main-boss = buf_firm.director
            .
         end.
      end.
   if v-torgconf-outR = "dir_obj"
      then do:
         CASE v-torgconf-self-obj-type:
         WHEN 'маг':U
         THEN DO:
            find first buf_shop no-lock
            where buf_shop.obj-code = v-torgconf-self-obj-code
            .
            assign
               v-torgconf-main-boss = buf_shop.director
               v-torgconf-main-boss-post = "Директор"
            .
         END.
         WHEN 'скл':U
         THEN DO:
            find first buf_store no-lock
            where buf_store.obj-code = v-torgconf-self-obj-code
            .
            assign
               v-torgconf-main-boss = buf_store.store-boss
               v-torgconf-main-boss-post = "Директор"
            .
         END.
         OTHERWISE DO:
            assign
               v-torgconf-main-boss       = "":U
               v-torgconf-main-boss-post  = "":U
            .
         END.
         END CASE.
      end.
   if  v-name <> 'wthtrg12':U
   and v-name <> 'wthfct':U
   and v-name <> 'wthm11':U
   then do:
    find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error.
    if available buf_trn-doc
      then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
      end.
    if v-torgconf-outogr = "no_print"
      then do:
         assign
            v-torgconf-ogr-name = ""
            v-torgconf-ogr-post = ""
         .
      end.
   if v-torgconf-outogr  = "ruk_firm"
         then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = v-host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-ogr-post = buf_sysconf.head-position
            .
         end.
         find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
             and buf_clients.obj-code = v-host-code
         .
         find first buf_firm no-lock
             where buf_firm.firm-code = buf_clients.obj-code
         .
         assign
             v-torgconf-ogr-name = buf_firm.director
         .
      end.
      if v-torgconf-outogr = "dir_obj"
         then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
            CASE buf_trn-doc.obj-type:
            WHEN 'маг':U
            THEN DO:
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            WHEN 'скл':U
            THEN DO:
               find first buf_store no-lock
               where buf_store.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_store.store-boss
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            OTHERWISE DO:
               assign
                  v-torgconf-ogr-name = "":U
                  v-torgconf-ogr-post = "":U
               .
            END.
            END CASE.
         end.
   if v-torgconf-outogr = "manag_doc"
      then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
         if available buf_trn-doc
         then do:
            run rep/get-psn.p
            (input buf_trn-doc.boss
            ,output v-torgconf-ogr-name
            ) .
         end.
         find first buf_person no-lock
         where buf_person.psn-code = buf_trn-doc.boss
         no-error.
         if available buf_person
         then do:
            v-torgconf-ogr-post = buf_person.position.
         end.
         if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
         if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
      end.
   end.
   else do:
   find first buf_wth-doc no-lock
      where buf_wth-doc.doc-code = p-doc-code
      no-error.
      if available buf_wth-doc
         then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,output v-host-code
  )  .
         end.
      if v-torgconf-outogr = "no_print"
         then do:
            assign
               v-torgconf-ogr-name = ""
               v-torgconf-ogr-post = ""
            .
         end.
      if v-torgconf-outogr  = "ruk_firm"
            then do:
            find first buf_sysconf no-lock
            where buf_sysconf.host-code = v-host-code
            no-error.
            if available buf_sysconf
            then do:
               assign
                  v-torgconf-ogr-post = buf_sysconf.head-position
               .
            end.
            find first buf_clients no-lock
               where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = v-host-code
            .
            find first buf_firm no-lock
               where buf_firm.firm-code = buf_clients.obj-code
            .
            assign
               v-torgconf-ogr-name = buf_firm.director
            .
         end.
         if v-torgconf-outogr = "dir_obj"
            then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_wth-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            end.
      if v-torgconf-outogr = "manag_doc"
         then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
            if available buf_wth-doc
            then do:
               run rep/get-psn.p
               (input buf_wth-doc.deliver
               ,output v-torgconf-ogr-name
               ) .
            end.
            find first buf_person no-lock
            where buf_person.psn-code = buf_wth-doc.deliver
            no-error.
            if available buf_person
            then do:
               v-torgconf-ogr-post = buf_person.position.
            end.
            if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
            if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
         end.
   end.
end.
end procedure.
procedure torgconf-get-outogr-param:
    define input parameter p-form-name  as character    no-undo.
    define input parameter p-host-code  as integer      no-undo.
    define input parameter p-obj-type   as character    no-undo.
    define input parameter p-obj-code   as integer      no-undo.
    define input parameter p-doc-code   as character      no-undo.
    define buffer buf_firm          for ub.firm .
    define buffer buf_clients       for ub.clients .
    define buffer buf_sysconf       for ub.sysconf .
    define buffer buf_shop          for ub.shop .
    define buffer buf_store         for ub.store .
    define buffer buf_person        for ub.person .
    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer buf_wth-doc       for ub.wth-doc .
   if  p-form-name <> 'wthtrg12':U
   and p-form-name <> 'wthfct':U
   and p-form-name <> 'wthm11':U
   then do:
    find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error.
    if v-torgconf-outogr = "no_print"
      then do:
         assign
            v-torgconf-ogr-name = ""
            v-torgconf-ogr-post = ""
         .
      end.
   if v-torgconf-outogr  = "ruk_firm"
         then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = p-host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-ogr-post = buf_sysconf.head-position
            .
         end.
         find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
             and buf_clients.obj-code = p-host-code
         .
         find first buf_firm no-lock
             where buf_firm.firm-code = buf_clients.obj-code
         .
         assign
             v-torgconf-ogr-name = buf_firm.director
         .
      end.
      if v-torgconf-outogr = "dir_obj"
         then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
            CASE buf_trn-doc.obj-type:
            WHEN 'маг':U
            THEN DO:
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            WHEN 'скл':U
            THEN DO:
               find first buf_store no-lock
               where buf_store.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_store.store-boss
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            OTHERWISE DO:
               assign
                  v-torgconf-ogr-name = "":U
                  v-torgconf-ogr-post = "":U
               .
            END.
            END CASE.
         end.
   if v-torgconf-outogr = "manag_doc"
      then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
         if available buf_trn-doc
         then do:
            run rep/get-psn.p
            (input buf_trn-doc.boss
            ,output v-torgconf-ogr-name
            ) .
         end.
         find first buf_person no-lock
         where buf_person.psn-code = buf_trn-doc.boss
         no-error.
         if available buf_person
         then do:
            v-torgconf-ogr-post = buf_person.position.
         end.
         if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
         if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
      end.
   end.
   else do:
   find first buf_wth-doc no-lock
      where buf_wth-doc.doc-code = p-doc-code
      no-error.
      if v-torgconf-outogr = "no_print"
         then do:
            assign
               v-torgconf-ogr-name = ""
               v-torgconf-ogr-post = ""
            .
         end.
      if v-torgconf-outogr  = "ruk_firm"
            then do:
            find first buf_sysconf no-lock
            where buf_sysconf.host-code = p-host-code
            no-error.
            if available buf_sysconf
            then do:
               assign
                  v-torgconf-ogr-post = buf_sysconf.head-position
               .
            end.
            find first buf_clients no-lock
               where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = p-host-code
            .
            find first buf_firm no-lock
               where buf_firm.firm-code = buf_clients.obj-code
            .
            assign
               v-torgconf-ogr-name = buf_firm.director
            .
         end.
         if v-torgconf-outogr = "dir_obj"
            then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_wth-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            end.
      if v-torgconf-outogr = "manag_doc"
         then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
            if available buf_wth-doc
            then do:
               run rep/get-psn.p
               (input buf_wth-doc.deliver
               ,output v-torgconf-ogr-name
               ) .
            end.
            find first buf_person no-lock
            where buf_person.psn-code = buf_wth-doc.deliver
            no-error.
            if available buf_person
            then do:
               v-torgconf-ogr-post = buf_person.position.
            end.
            if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
            if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
         end.
   end.
end.
procedure torgconf-get-reason  :
define input parameter  p-doc-code       as character        no-undo.
define input parameter  p-reason-code    as integer          no-undo .
define input parameter  p-doc-type       as character        no-undo.
    if p-reason-code > 0
    then do:
        define buffer buf_trn-reason for ub.trn-reason.
        find first buf_trn-reason no-lock where buf_trn-reason.reason-code = p-reason-code no-error .
        if available buf_trn-reason then assign v-torgconf-reason =  buf_trn-reason.reason-name .
    end.
    else do:
        if p-doc-type = 'при':U
        then  do:
            define variable v-attr-type     as character    no-undo.
            define variable v-attr-value    as character    no-undo.
            run gbl/trdcat-v.p (input p-doc-code,input 'nids':U,output v-attr-value,output v-attr-type) .
            assign v-torgconf-reason = v-attr-value .
            run gbl/trdcat-v.p (input p-doc-code,input 'dids':U,output v-attr-value,output v-attr-type) .
            assign v-torgconf-reason = v-torgconf-reason + " от " + v-attr-value .
        end.
    end.
end procedure.
do
on error undo, return error
:
def shared var CostPrice    as logical          no-undo.
def shared var sort-name    as logical          no-undo.
def shared var sort-gr      as logical               no-undo.
def stream out-stream .
def buffer buf_trn-doc          for ub.trn-doc.
def buffer buf_goods            for ub.goods.
def buffer buf_clients          for ub.clients.
def buffer buf_doc-line         for ub.doc-line.
def buffer buf_person           for ub.person.
def var v-line-counter      as integer                  no-undo.
def var v-single-line       as char                     no-undo.
def var v-full-type          as char                     no-undo.
def var v-cli-name          as char                     no-undo.
def var v-obj-name          as char                     no-undo.
def var v-income            as logical                  no-undo.
def var v-valut-abbr        as char                     no-undo.
def var v-vat-pc            like ub.doc-line.vat-pc        no-undo.
def var v-slt-pc            like ub.doc-line.slt-pc        no-undo.
def var v-host-code         like ub.sysconf.host-code      no-undo.
def var v-doc-sum           like ub.ot-tot.sum-base        no-undo.
def var v-doc-price         like ub.doc-line.price-base    no-undo.
def var v-pg-sum-qnty       like ub.doc-line.fact-qnty     no-undo.
def var v-pg-sum-no-taxes   like ub.ot-line.sum-base       no-undo.
def var v-pg-sum-no-vat     like ub.ot-line.sum-base       no-undo.
def var v-pg-sum-slt        like ub.ot-line.sum-base       no-undo.
def var v-pg-sum-vat        like ub.ot-line.sum-base       no-undo.
def var v-pg-sum-doc        like ub.ot-line.sum-base       no-undo.
def var v-tot-sum-qnty      like ub.doc-line.fact-qnty     no-undo.
def var v-tot-sum-no-taxes  like ub.ot-line.sum-base       no-undo.
def var v-tot-sum-no-vat    like ub.ot-line.sum-base       no-undo.
def var v-tot-sum-slt       like ub.ot-line.sum-base       no-undo.
def var v-tot-sum-vat       like ub.ot-line.sum-base       no-undo.
def var v-tot-sum-doc       like ub.ot-line.sum-base       no-undo.
define variable boss-name    like ub.clients.obj-name  no-undo.
def var v-par-menedger          as char                     no-undo.
define variable p-torgconf-wrkr-name    as character    no-undo.
define variable p-torgconf-post         as character    no-undo.
def var v-first-line        as logical                  no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_trn-doc no-lock where recid(buf_trn-doc) = p-trn-doc-recid.
assign
    v-valut-abbr = ( if PrintRubl = yes then "( РУБ )" else "(Б.Вал)" )
.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
find first buf_clients no-lock
     where buf_clients.obj-type = buf_trn-doc.obj-type
       and buf_clients.obj-code = buf_trn-doc.obj-code
.
assign
        v-obj-name = string(buf_clients.obj-name)
.
find first buf_clients no-lock
     where buf_clients.obj-type = buf_trn-doc.cli-type
       and buf_clients.obj-code = buf_trn-doc.cli-code
.
if available buf_clients
then do:
    assign
        v-cli-name = string(buf_clients.obj-name)
    .
end.
else do:
    assign
        v-cli-name = ""
    .
end.
assign
    v-income = ( if buf_trn-doc.doc-type = 'при':U or buf_trn-doc.doc-type = 'возврат':U then yes else no )
    v-single-line       = fill("-", 230)
    v-line-counter      = 0
.
run rep/get-psn.p
      (input buf_trn-doc.boss
      ,output boss-name
      ) .
find first buf_person no-lock
where buf_person.psn-code = buf_trn-doc.boss
no-error.
if available buf_person
then do:
   v-par-menedger = buf_person.position.
end.
if boss-name = "?":U then boss-name = "".
if v-par-menedger = ? then  v-par-menedger = "".
run torgconf-get-warrant in this-procedure(
    input buf_trn-doc.doc-code
)
.
run torgconf-get-storekeeper in this-procedure (
    input buf_trn-doc.wrkr
  , output p-torgconf-wrkr-name
  , output p-torgconf-post
).
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
form header
    space(5) v-single-line format "X(191)" skip
    'Продолжение - на следующей странице' at 90 skip
    with frame BottomFrame width 235 page-bottom no-labels no-box .
view stream out-stream frame BottomFrame .
find first buf_clients no-lock
     where buf_clients.obj-type = 'орг':U
       and buf_clients.obj-code = v-host-code
.
if session :set-wait-state( "compiler" ) then.
put stream out-stream
    buf_clients.obj-name format "X(60)" at 5 + ( ( 5 + 191 - 5) / 2 ) - ( length( buf_clients.obj-name ) / 2 )
.
put stream out-stream
    skip (1) space( 44 )
    "Приложение к документу. Тип: "
.
v-full-type = ENTRY(lookup(buf_trn-doc.ext-doc-type,'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U),'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U).
put stream out-stream
       v-full-type                                                format "X(20)"
       "   Номер: "
       buf_trn-doc.doc-code                                     format "X(14)"
       "   Дата: "
       string(buf_trn-doc.doc-date)                             format "X(10)"
       ( if buf_trn-doc.status_ <> 'факт':U then "   Статус: " + caps(buf_trn-doc.status_) else " " )
                                                                format "X(25)"
    skip space( 44 ) "Поставщик (отправитель): "
        (if v-income = yes then v-cli-name else v-obj-name )    format "X(60)"
    skip space( 44 ) "Покупатель (получатель): "
        (if v-income = yes then v-obj-name else v-cli-name )    format "X(60)"
    skip
.
put stream out-stream
        ( if CostPrice = yes then 'Учетные цены' else 'Цены продажи' )
                                                                format "X(12)"  at right-field( 5 + 191, 12 )
.
run print-header in this-procedure .
assign
    v-pg-sum-qnty       = 0
    v-pg-sum-no-taxes   = 0
    v-pg-sum-no-vat     = 0
    v-pg-sum-slt        = 0
    v-pg-sum-vat        = 0
    v-pg-sum-doc        = 0
    v-tot-sum-qnty      = 0
    v-tot-sum-no-taxes  = 0
    v-tot-sum-no-vat    = 0
    v-tot-sum-slt       = 0
    v-tot-sum-vat       = 0
    v-tot-sum-doc       = 0
.
if sort-gr = yes
then do:
    if sort-name = yes
    then do:
        for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_goods.grp-name
              by buf_goods.gds-name
        :
            if first-of(buf_goods.grp-name)
            then do:
                run print-group-line in this-procedure.
            end.
            if last(buf_goods.gds-name)
                and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure ( input "" ).
                if line-counter( Out-Stream ) + 2 < page-size( Out-Stream )
                then do:
                    put stream out-stream
                        skip space(5)
                            "|" v-single-line format "X(189)" "|"
                    .
                end.
                page stream Out-Stream .
                run print-header in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.
    else do:
        for each buf_doc-line
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_goods.grp-name
              by buf_doc-line.num-place
        :
            if first-of(buf_goods.grp-name)
            then do:
                run print-group-line in this-procedure.
            end.
            if last(buf_doc-line.num-place)
                and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure ( input "" ).
                if line-counter( Out-Stream ) + 2 < page-size( Out-Stream )
                then do:
                    put stream out-stream
                        skip space(5)
                            "|" v-single-line format "X(189)" "|"
                    .
                end.
                page stream Out-Stream .
                run print-header in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.
end.
else do:
    if sort-name = yes
    then do:
        for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_goods.gds-name
        :
            if last(buf_goods.gds-name)
                and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure ( input "" ).
                if line-counter( Out-Stream ) + 2 < page-size( Out-Stream )
                then do:
                    put stream out-stream
                        skip space(5)
                            "|" v-single-line format "X(189)" "|"
                    .
                end.
                page stream Out-Stream .
                run print-header in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.
    else do:
        for each buf_doc-line
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_doc-line.num-place
        :
            if last(buf_doc-line.num-place)
                and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure ( input "" ).
                if line-counter( Out-Stream ) + 2 < page-size( Out-Stream )
                then do:
                    put stream out-stream
                        skip space(5)
                            "|" v-single-line format "X(189)" "|"
                    .
                end.
                page stream Out-Stream .
                run print-header in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.
end.
if page-number ( Out-Stream ) > 1
then do:
    run print-page-result in this-procedure  ( input "" ) .
end.
else do:
    run print-page-result in this-procedure  ( input "no-line" ) .
end.
run print-total-result in this-procedure .
hide stream Out-Stream frame BottomFrame .
run print-note in this-procedure .
if session :set-wait-state( "" ) then.
output stream out-stream close.
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
procedure print-header :
do
on error undo, return error
:
assign
    v-first-line = yes
.
put stream out-stream
    skip
    space(5)       v-single-line   format "X(191)"
    skip space(5)  "|"
        "|"                     at 5 + 11
        "|"                     at 5 + 28
        "|"                     at 5 + 79
        "|"                     at 5 + 91
        "Цена без"              at center-field(5 + 91, 5 + 104, 8)
        "|"                     at 5 + 104
        "Сумма без"             at center-field(5 + 104, 5 + 119, 9)
        "|"                     at 5 + 119
        "Цена без"              at center-field(5 + 119, 5 + 132, 8)
        "|"                     at 5 + 132
        "Сумма без"             at center-field(5 + 132, 5 + 147, 9)
        "|"                     at 5 + 147
        "Став-"                 at center-field(5 + 147, 5 + 153, 5)
        "|"                     at 5 + 153
        "Сумма"                 at center-field(5 + 153, 5 + 163, 5)
        "|"                     at 5 + 163
        "|"                     at 5 + 176
        "|"                     at 5 + 191
    skip space(5)  "|"
        "Код"                   at center-field(5 + 1, 5 + 11, 3)
        "|"                     at 5 + 11
        "Артикул"               at center-field(5 + 11, 5 + 28, 7)
        "|"                     at 5 + 28
        "Наименование товара"   at center-field(5 + 28, 5 + 79, 19)
        "|"                     at 5 + 79
        "Количество"            at center-field(5 + 79, 5 + 91, 10)
        "|"                     at 5 + 91
        "налогов"               at center-field(5 + 91, 5 + 104, 7)
        "|"                     at 5 + 104
        "налогов"               at center-field(5 + 104, 5 + 119, 7)
        "|"                     at 5 + 119
        "НДС"                   at center-field(5 + 119, 5 + 132, 3)
        "|"                     at 5 + 132
        "НДС"                   at center-field(5 + 132, 5 + 147, 3)
        "|"                     at 5 + 147
        "ка"                    at center-field(5 + 147, 5 + 153, 2)
        "|"                     at 5 + 153
        "НДС"                   at center-field(5 + 153, 5 + 163, 3)
        "|"                     at 5 + 163
        "Цена"                  at center-field(5 + 163, 5 + 176, 4)
        "|"                     at 5 + 176
        "Сумма"                 at center-field(5 + 176, 5 + 191, 5)
        "|"                     at 5 + 191
    skip space(5)  "|"
        "|"                     at 5 + 11
        "|"                     at 5 + 28
        "|"                     at 5 + 79
        "|"                     at 5 + 91
        v-valut-abbr            at center-field(5 + 91, 5 + 104, 7)
        "|"                     at 5 + 104
        v-valut-abbr            at center-field(5 + 104, 5 + 119, 7)
        "|"                     at 5 + 119
        v-valut-abbr            at center-field(5 + 119, 5 + 132, 7)
        "|"                     at 5 + 132
        v-valut-abbr            at center-field(5 + 132, 5 + 147, 7)
        "|"                     at 5 + 147
        "НДС"                   at center-field(5 + 147, 5 + 153, 3)
        "|"                     at 5 + 153
        v-valut-abbr            at center-field(5 + 153, 5 + 163, 7)
        "|"                     at 5 + 163
        v-valut-abbr            at center-field(5 + 163, 5 + 176, 7)
        "|"                     at 5 + 176
        v-valut-abbr            at center-field(5 + 176, 5 + 191, 7)
        "|"                     at 5 + 191
    skip space(5)
        "|" v-single-line format "X(189)" "|"
.
end.
end procedure.
procedure print-line :
do
on error undo, return error
:
    define variable v-sign      as integer       no-undo.
    assign
        v-sign =  ( if buf_trn-doc.status_ = 'факт':U
                    and ( buf_trn-doc.ext-doc-type = 'ee':U
                        or buf_trn-doc.ext-doc-type = 'ep':U
                        or buf_trn-doc.ext-doc-type = 'es':U
                        or buf_trn-doc.ext-doc-type = 'we':U
                        or buf_trn-doc.ext-doc-type = 'ev':U
                        or buf_trn-doc.ext-doc-type = 'em':U
                        or buf_trn-doc.ext-doc-type = 'wm':U  )
                    then -1
                    else 1 )
    .
    run r-getsum in this-procedure ( input recid ( buf_doc-line )
                                   ,  input CostPrice
                                   ,  input PrintRubl
                                   ).
    assign
        v-doc-sum   = v-sign * temp_r-getsum.sum-with-taxes
        v-doc-price = (if temp_r-getsum.qnty <> 0 then temp_r-getsum.sum-with-taxes / temp_r-getsum.qnty else ?)
    .
    put stream out-stream
        skip space(5)  "|"
            string(buf_goods.gds-code, "999999999") format "X(9)"
            "|"   at 5 + 11
            string(buf_doc-line.artic)              format "X(16)"
            "|"   at 5 + 28
            buf_goods.gds-name                      format "X(35)"
            "|"   at 5 + 79
            v-sign * temp_r-getsum.qnty             format "->>>>>9.<<<"
            "|"   at 5 + 91
            temp_r-getsum.price-no-taxes            format "->>>>>9.99"
            "|"   at 5 + 104
            v-sign * temp_r-getsum.sum-no-taxes     format "->>,>>>,>>9.99"
            "|"   at 5 + 119
            temp_r-getsum.price-no-vat              format "->>>>>9.99"
            "|"   at 5 + 132
            v-sign * temp_r-getsum.sum-no-vat       format "->>,>>>,>>9.99"
            "|"   at 5 + 147
            ( if temp_r-getsum.vat-pc <> ? then string(temp_r-getsum.vat-pc, ">9.9<") else " " )
                                                    format "X(5)"
            "|"   at 5 + 153
            v-sign * temp_r-getsum.sum-vat          format "->>>>9.99"
            "|"   at 5 + 163
    .
    if v-doc-price <> ?
    then do:
        put stream out-stream
            v-doc-price      format "->>>>>9.99"
        .
    end.
    put stream out-stream
        "|"   at 5 + 176
            v-doc-sum            format "->>,>>>,>>9.99"
        "|"   at 5 + 191
    .
    assign
        v-line-counter      = v-line-counter    + 1
        v-pg-sum-qnty       = v-pg-sum-qnty     + ( v-sign * temp_r-getsum.qnty         )
        v-pg-sum-no-taxes   = v-pg-sum-no-taxes + ( v-sign * temp_r-getsum.sum-no-taxes )
        v-pg-sum-no-vat     = v-pg-sum-no-vat   + ( v-sign * temp_r-getsum.sum-no-vat   )
        v-pg-sum-slt        = v-pg-sum-slt      + ( v-sign * temp_r-getsum.sum-slt      )
        v-pg-sum-vat        = v-pg-sum-vat      + ( v-sign * temp_r-getsum.sum-vat      )
        v-pg-sum-doc        = v-pg-sum-doc      + ( v-doc-sum                           )
    .
    if line-counter( Out-Stream ) + 2 + 2 > page-size( Out-Stream )
    then do:
        run print-page-result in this-procedure ( input "" ) .
        page stream Out-Stream .
        run print-header in this-procedure .
    end.
    assign
        v-first-line = no
    .
end.
end procedure.
procedure print-group-line :
do
on error undo, return error
:
    if line-counter( Out-Stream ) + 2 + 2 + 1 > page-size( Out-Stream )
    then do:
        run print-page-result in this-procedure ( input "" ) .
        page stream out-stream.
        run print-header in this-procedure .
    end.
    if v-first-line <> yes
    then do:
        put stream out-stream
            skip space(5)
                "|" v-single-line format "X(189)" "|"
        .
    end.
    put stream out-stream
        skip space(5)
            "|   ***  Группа:  "  + buf_goods.grp-name format "X(150)"
            "|" at 5 + 191
    .
end.
end procedure.
procedure print-page-result :
do
on error undo, return error
:
def input parameter p-print-type as char no-undo.
if p-print-type <> "no-line"
then do:
    put stream out-stream
        skip space(5)
            "|" v-single-line format "X(189)" "|"
        skip space(5)  "|        Итого по странице "
            "|"                 at 5 + 79
            v-pg-sum-qnty                       format "->>>>>9.<<<"
            "|"                 at 5 + 91
            "|"                 at 5 + 104
            v-pg-sum-no-taxes                   format "->>,>>>,>>9.99"
            "|"                 at 5 + 119
            "|"                 at 5 + 132
            v-pg-sum-no-vat                     format "->>,>>>,>>9.99"
            "|"                 at 5 + 147
            "|"                 at 5 + 153
            v-pg-sum-vat                        format "->>>>9.99"
            "|"                 at 5 + 163
            "|"                 at 5 + 176
            v-pg-sum-doc                        format "->>,>>>,>>9.99"
            "|"                 at 5 + 191
    .
end.
assign
    v-tot-sum-qnty      = v-tot-sum-qnty        + v-pg-sum-qnty
    v-tot-sum-no-taxes  = v-tot-sum-no-taxes    + v-pg-sum-no-taxes
    v-tot-sum-no-vat    = v-tot-sum-no-vat      + v-pg-sum-no-vat
    v-tot-sum-slt       = v-tot-sum-slt         + v-pg-sum-slt
    v-tot-sum-vat       = v-tot-sum-vat         + v-pg-sum-vat
    v-tot-sum-doc       = v-tot-sum-doc         + v-pg-sum-doc
    v-pg-sum-qnty       = 0
    v-pg-sum-no-taxes   = 0
    v-pg-sum-no-vat     = 0
    v-pg-sum-slt        = 0
    v-pg-sum-vat        = 0
    v-pg-sum-doc        = 0
.
end.
end procedure.
procedure print-total-result :
do
on error undo, return error
:
    put stream out-stream
        skip space(5)
            "|" v-single-line format "X(189)" "|"
        skip space(5)  "|        В С Е Г О "
            "|"                 at 5 + 79
            v-tot-sum-qnty                       format "->>>>>9.<<<"
            "|"                 at 5 + 91
            "|"                 at 5 + 104
            v-tot-sum-no-taxes                   format "->>,>>>,>>9.99"
            "|"                 at 5 + 119
            "|"                 at 5 + 132
            v-tot-sum-no-vat                     format "->>,>>>,>>9.99"
            "|"                 at 5 + 147
            "|"                 at 5 + 153
            v-tot-sum-vat                        format "->>>>9.99"
            "|"                 at 5 + 163
            "|"                 at 5 + 176
            v-tot-sum-doc                        format "->>,>>>,>>9.99"
            "|"                 at 5 + 191
        skip space(5)
            v-single-line format "X(191)"
    .
end.
end procedure.
procedure print-note :
do
on error undo, return error
:
if trim(p-torgconf-post) = ""
then do:
    p-torgconf-post = Fill("_", 20).
end.
if trim(p-torgconf-wrkr-name ) = ""
then do:
    p-torgconf-wrkr-name  = Fill("_", 30).
end.
if trim(p-torgconf-accept-position) = ""
then do:
    p-torgconf-accept-position = Fill ("_", 20).
end.
if trim(p-torgconf-accept-fname) = ""
then do:
    p-torgconf-accept-fname = Fill ("_", 30).
end.
    put stream out-stream
        skip(1) space(44)
            "Всего наименований: "
            v-line-counter  format ">>>>>9"
        skip space(44)
            "Сумма цен по документу составила: "
            v-tot-sum-doc                        format "->>,>>>,>>9.99"
            ", в том числе налог с продаж: "
            v-tot-sum-slt                        format "->>>9.99"
            ", НДС: "
            v-tot-sum-vat                        format "->>>>9.99"
        skip(1) space(44)
            "Сдал:"
        space(25)  p-torgconf-post               format "X(20)" "     __________           "p-torgconf-wrkr-name format "X(40)"
        skip space(78)  "/должность/          /подпись/               /расшифровка подписи/"
            skip(1) space(44)
                "Принял:"
        space(23)    p-torgconf-accept-position format "X(20)" "     __________           "p-torgconf-accept-fname format "X(40)"
        skip space(78) "/должность/          /подпись/               /расшифровка подписи/"
        skip
        .
    end.
end procedure.
