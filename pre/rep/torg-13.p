block-level on error undo, throw.
do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter p-print-gold         as logical          no-undo.
define input parameter p-print-prod         as logical          no-undo.
define input parameter p-break-name         as logical          no-undo init false .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Печать формы ТОРГ-13".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character
    index pi is primary unique
        str-key
.
define variable v-p-fmt-2-str-key    as integer      no-undo.
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
        v-p-fmt-2-str-key   = 0
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
            v-p-fmt-2-str-key = v-p-fmt-2-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-2-str-key
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
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
define variable vss-include-info4 as character format "X(65)" no-undo
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
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field Name         as character
    field gdscode      as character
    field EI           as character
    field OKEI         as character
    field AmountInPl   as character
    field PlaceAmount  as character
    field qnty         as character
    field price        as character
    field sum          as character
    index pi is primary unique xl-line-id
.
define variable v-torg13xl-current-data-row     as integer      no-undo.
define variable v-torg13xl-cell-file-name       as character    no-undo.
define variable v-torg13xl-data-file-name       as character    no-undo.
procedure torg13xl-init :
    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-torg13xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-torg13xl-data-file-name
    ).
    output stream excel-line to value( v-torg13xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-torg13xl-cell-file-name
    ).
    output stream excel-cell to value( v-torg13xl-cell-file-name ).
    if printrubl
    then do:
        run torg13xl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run torg13xl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "1":U
        ).
    end.
    run torg13xl-write-cell-data in this-procedure (
          input "columnList":U
        , input "Name,gdscode,EI,OKEI,AmountInPl,PlaceAmount,qnty,price,sum":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input "columnType":U
        , input "S,I,S,S,D,D,D,C,C":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input "columnAmount":U
        , input "9":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input "subtotalList":U
        , input "AmountInPl,PlaceAmount,qnty,sum":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input "subtotalType":U
        , input "S,S,S,S":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input "subtotalAmount":U
        , input "4":U
    ).
end.
end procedure.
procedure torg13xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/t13_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-torg13xl-cell-file-name.
        export v-torg13xl-data-file-name.
    output close.
end.
end procedure.
procedure torg13xl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        chr(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure torg13xl-write-line-data :
define input parameter p-Name           as character        no-undo.
define input parameter p-gdscode        as character        no-undo.
define input parameter p-EI             as character        no-undo.
define input parameter p-OKEI           as character        no-undo.
define input parameter p-AmountInPl     as character        no-undo.
define input parameter p-PlaceAmount    as character        no-undo.
define input parameter p-qnty           as character        no-undo.
define input parameter p-price          as character        no-undo.
define input parameter p-sum            as character        no-undo.
    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:
    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-torg13xl-current-data-row = v-torg13xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = "LD":U
        buf_temp_line-data.xl-line-id   = v-torg13xl-current-data-row
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.gdscode      = p-gdscode
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.OKEI         = p-OKEI
        buf_temp_line-data.AmountInPl   = p-AmountInPl
        buf_temp_line-data.PlaceAmount  = p-PlaceAmount
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.sum          = p-sum
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        chr(9)   buf_temp_line-data.Name
        chr(9)   buf_temp_line-data.gdscode
        chr(9)   buf_temp_line-data.EI
        chr(9)   buf_temp_line-data.OKEI
        chr(9)   buf_temp_line-data.AmountInPl
        chr(9)   buf_temp_line-data.PlaceAmount
        chr(9)   buf_temp_line-data.qnty
        chr(9)   buf_temp_line-data.price
        chr(9)   buf_temp_line-data.sum
        chr(10)
    .
end.
end procedure.
procedure torg13xl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/t13_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
define buffer t-doc        for trn-doc.
define buffer OurObject    for clients.
define buffer buf_clients  for clients.
define buffer buf_units    for units.
define stream Out-stream .
define shared variable PrintParts   as logical              no-undo.
define shared variable PrintScale   as logical              no-undo.
define shared variable costprice    as logical              no-undo.
define shared variable sort-name    as logical              no-undo.
define shared variable sort-gr      as logical              no-undo.
define shared variable no-vat       as logical              no-undo.
define temp-table temp_gds-name no-undo
    field gds-name like goods.gds-name
    field string-num as integer
    index sn is primary unique string-num
.
define variable v-gds-name          like goods.gds-name     no-undo.
define variable v-gds-name-counter  as integer              no-undo.
define variable v-parameter-value   as character    no-undo.
define variable v-parameter-type    as character    no-undo.
define variable v-otpposition       as character    no-undo.
define variable v-otpname           as character    no-undo.
define variable v-polposition       as character    no-undo.
define variable v-polname           as character    no-undo.
define variable  p-torgconf-wrkr-name as character                 no-undo.
define variable  p-torgconf-post    as character                 no-undo.
define variable tdoc-prt            as    logical           no-undo.
define variable tdoc-code           like trn-doc.doc-code   no-undo.
define variable v-doc-date-string   as character            no-undo.
define variable rootnode_code       as integer              no-undo.
define variable LineCounter         as integer              no-undo.
define variable txt-LC              as char                 no-undo.
define variable s1                  as char                 no-undo.
define variable s2                  as char                 no-undo.
define variable Node_Code           like gds-prt.upper-code no-undo.
define variable PriceNoNDS          as decimal              no-undo.
define variable PricendS            as decimal              no-undo.
define variable PricewithNDS        as decimal              no-undo.
define variable tqnty               as decimal              no-undo.
define variable SumNoNDS            as decimal              no-undo.
define variable SumNDS              as decimal              no-undo.
define variable SumwithNDS          as decimal              no-undo.
define variable sum-tqnty           as decimal              no-undo.
define variable sum-SumNoNDS        as decimal              no-undo.
define variable sum-SumNDS          as decimal              no-undo.
define variable sum-SumwithNDS      as decimal              no-undo.
define variable prt-tqnty           as decimal              no-undo.
define variable prt-SumNoNDS        as decimal              no-undo.
define variable prt-SumNDS          as decimal              no-undo.
define variable prt-SumwithNDS      as decimal              no-undo.
define variable sum-prt-tqnty       as decimal              no-undo.
define variable sum-prt-SumNoNDS    as decimal              no-undo.
define variable sum-prt-SumNDS      as decimal              no-undo.
define variable sum-prt-SumwithNDS  as decimal              no-undo.
define variable Pg-tqnty            as decimal init 0       no-undo.
define variable Pg-SumNoNDS         as decimal              no-undo.
define variable Pg-SumNDS           as decimal              no-undo.
define variable Pg-SumwithNDS       as decimal              no-undo.
define variable PrevPage            as integer init 0       no-undo.
define variable tot-SumNoNDS        as decimal              no-undo.
define variable tot-SumNDS          as decimal              no-undo.
define variable tot-SumwithNDS      as decimal              no-undo.
define variable PrtName             as char                 no-undo.
define variable OKEI                as char                 no-undo.
define variable tb-code             as char                 no-undo.
define variable qnty-opl            as decimal              no-undo.
define variable qnty-pl             as decimal              no-undo.
define variable mass-b              as decimal              no-undo.
define variable mass-n              as decimal              no-undo.
define variable v-line-counter      as integer              no-undo.
define variable v-not-gold          as logical              no-undo.
define variable v-new-prod          as logical  no-undo.
define variable v-prod-type         like doc-line.prod-type no-undo.
define variable v-prod-code         like doc-line.prod-code no-undo.
define variable v-prod-name         like clients.obj-name   no-undo.
define variable sym1    as char init ":" no-undo.
define variable sym2    as char init ":" no-undo.
define variable sym3    as char init ":" no-undo.
define variable sym4    as char init ":" no-undo.
define variable sym5    as char init ":" no-undo.
define variable sym6    as char init ":" no-undo.
define variable sym7    as char init ":" no-undo.
define variable sym8    as char init ":" no-undo.
define variable sym9    as char init ":" no-undo.
define variable sym10   as char init ":" no-undo.
define variable sym11   as char init ":" no-undo.
define variable sym12   as char init ":" no-undo.
define variable sym13   as char init ":" no-undo.
define variable sym14   as char init ":" no-undo.
define variable sym15   as char init ":" no-undo.
define variable sym16   as char init ":" no-undo.
define variable sym17   as char init ":" no-undo.
define variable sym18   as char init ":" no-undo.
define variable Line                as char          no-undo.
define variable UndLine             as char          no-undo.
define variable unit-str            as char          no-undo.
define variable val-str             as char          no-undo.
define variable v-host-code         as integer       no-undo.
if session :set-wait-state( "compiler" ) then.
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first t-doc no-lock
     where recid( t-doc ) = rec_id
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
run torgconf-read in this-procedure (
      input "torg13"
    , input v-host-code
    , input t-doc.obj-type
    , input t-doc.obj-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров печати формы."
    skip "Форма будет напечатана с параметрами по умолчанию."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box error.
end.
run torgconf-get-storekeeper in this-procedure (
      input  t-doc.wrkr
    , output p-torgconf-wrkr-name
    , output p-torgconf-post
).
run torgconf-get-warrant in this-procedure (
      input t-doc.doc-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения атрибутов накладной."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box error.
end.
run gbl/conf-rd.p (
    input "fgdsnind"
    , input t-doc.host-code
    , t-doc.obj-type
    , t-doc.obj-code
    , ""
    , ""
    , ""
    , no
    , output v-parameter-value
    , output v-parameter-type
) no-error.
if not error-status:error
then do:
    assign
        p-break-name = ( v-parameter-value = "yes" )
    .
end.
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME f-doc-cost
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp_gds-name.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format  "X(32)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass-b COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass-n COLUMN-LABEL "Масса!нетто! ! ! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format ">>>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceNoNDS COLUMN-LABEL "Учетная цена!без НДС! ! ! " format "->,>>>,>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceNDS COLUMN-LABEL "НДС от!учетной цены! ! ! " format "->>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceWithNDS COLUMN-LABEL "Учетная цена!с НДС! ! ! " format "->,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNoNDS COLUMN-LABEL "Сумма в!учет. ценах!без НДС! ! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNDS COLUMN-LABEL "Сумма НДС! ! ! ! " format "->>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumWithNDS COLUMN-LABEL "Сумма в!учет. ценах!с НДС! ! " format "->>,>>>,>>9.99" space(0)
        sym17 column-label ":!:!:!:!:" format "X(1)" space(0)
    HEADER
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + string(tdoc-code) + " от " + v-doc-date-string )
                                                        at 40 format "X(50)"
        ( if t-doc.status_ <> 'факт':U then
             string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
          else
              " "   )                                   at 100 format "X(30)"
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) )
                                                        at 180 format "X(13)" SKIP
        Line format "X(197)" AT 1
    with width 235 down stream-io.
DEFINE FRAME f-doc-doc
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp_gds-name.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format  "X(32)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass-b COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass-n COLUMN-LABEL "Масса!нетто! ! ! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format ">>>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceNoNDS COLUMN-LABEL "Цена по доку!менту!без НДС! ! " format "->,>>>,>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceNDS COLUMN-LABEL "НДС от!цены по доку!  менту! ! " format "->,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceWithNDS COLUMN-LABEL "Цена по доку!менту!с НДС! ! " format "->,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNoNDS COLUMN-LABEL "Сумма!цен по доку!менту!без НДС! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNDS COLUMN-LABEL "Сумма НДС! ! ! ! " format "->>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumWithNDS COLUMN-LABEL "Сумма!цен по доку!менту!с НДС! " format "->>,>>>,>>9.99" space(0)
        sym17 column-label ":!:!:!:!:" format "X(1)" space(0)
    HEADER
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + tdoc-code + " от " + v-doc-date-string ) AT 40 format "X(50)"
        ( if t-doc.status_ <> 'факт':U then
              string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
          else
              " " ) AT 100 format "X(30)"
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) AT 180 format "X(13)" SKIP
        Line format "X(197)" AT 1
    with width 235 down stream-io.
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME f-doc-cost-gold
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp_gds-name.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X(28)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.sort column-label "Про!ба! ! ! " format "X(3)" space(0)
        sym18 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass-b COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass-n COLUMN-LABEL "Масса!нетто! ! ! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format ">>>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceNoNDS COLUMN-LABEL "Учетная цена!без НДС! ! ! " format "->,>>>,>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceNDS COLUMN-LABEL "НДС от!учетной цены! ! ! " format "->>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceWithNDS COLUMN-LABEL "Учетная цена!с НДС! ! ! " format "->,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNoNDS COLUMN-LABEL "Сумма в!учет. ценах!без НДС! ! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNDS COLUMN-LABEL "Сумма НДС! ! ! ! " format "->>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumWithNDS COLUMN-LABEL "Сумма в!учет. ценах!с НДС! ! " format "->>,>>>,>>9.99" space(0)
        sym17 column-label ":!:!:!:!:" format "X(1)" space(0)
    HEADER
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + string(tdoc-code) + " от " + v-doc-date-string )
                                                        at 40 format "X(50)"
        ( if t-doc.status_ <> 'факт':U then
             string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
          else
              " "   )                                   at 100 format "X(30)"
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) )
                                                        at 180 format "X(13)" SKIP
        Line format "X(197)" AT 1
    with width 235 down stream-io.
DEFINE FRAME f-doc-doc-gold
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp_gds-name.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X(28)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.sort column-label "Про!ба! ! ! " format "X(3)" space(0)
        sym18 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass-b COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass-n COLUMN-LABEL "Масса!нетто! ! ! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format ">>>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceNoNDS COLUMN-LABEL "Цена по доку!менту!без НДС! ! " format "->,>>>,>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceNDS COLUMN-LABEL "НДС от!цены по доку!  менту! ! " format "->,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceWithNDS COLUMN-LABEL "Цена по доку!менту!с НДС! ! " format "->,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNoNDS COLUMN-LABEL "Сумма!цен по доку!менту!без НДС! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNDS COLUMN-LABEL "Сумма НДС! ! ! ! " format "->>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumWithNDS COLUMN-LABEL "Сумма!цен по доку!менту!с НДС! " format "->>,>>>,>>9.99" space(0)
        sym17 column-label ":!:!:!:!:" format "X(1)" space(0)
    HEADER
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + tdoc-code + " от " + v-doc-date-string ) AT 40 format "X(50)"
        ( if t-doc.status_ <> 'факт':U then
              string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
          else
              " " ) AT 100 format "X(30)"
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) AT 180 format "X(13)" SKIP
        Line format "X(197)" AT 1
    with width 235 down stream-io.
run torg13xl-init in this-procedure .
assign val-str = ( if PrintRubl then "рублях" else "баз.вал" ) .
assign
    Line = fill("-", 230)
    UndLine = fill("_", 230)
    LineCounter = 1
.
if v-torgconf-outnum = yes
then do:
    assign
        tdoc-code = fill( " ", 10 )
    .
end.
else do:
    assign
        tdoc-code = t-doc.doc-code
    .
end.
if v-torgconf-outdate = yes
then do:
    assign
        v-doc-date-string = fill( " ", 10 )
    .
end.
else do:
    assign
        v-doc-date-string = ( if t-doc.status_ <> 'факт':U
                              then string( t-doc.doc-date, "99/99/9999" )
                              else string( t-doc.fact-date, "99/99/9999" )
                            )
    .
end.
find OurObject where OurObject.obj-type = t-doc.obj-type and
                                          OurObject.obj-code = t-doc.obj-code no-lock no-error.
case OurObject.obj-type :
    when 'маг':U
    then do:
        find shop where shop.obj-code = OurObject.obj-code no-lock .
        tdoc-prt = shop.doc-prt.
    end.
    when 'скл':U
    then do:
        find store where store.obj-code = OurObject.obj-code no-lock .
        tdoc-prt = store.doc-prt .
    end.
end case.
if not tdoc-prt then
    PrintScale = no .
output stream Out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
form header
    Line format "X(197)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame bottomframe width 235 page-bottom no-labels no-box .
view stream out-stream frame bottomframe .
find clients where clients.obj-type = 'орг':U and
                                   clients.obj-code = t-doc.host-code no-lock .
    case clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = clients.obj-code NO-LOCK .
            if available ub.firm
            then do:
                assign
                    t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
                    t-addres = t-addres
                        + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
                            then ""
                            else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) )
                          )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                        + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( ", " + trim( ub.firm.addres2 ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-phone = ub.firm.phone
                    t-inn   = ub.firm.inn
                    t-okpo  = ub.firm.okpo
                .
            end.
       end.
       when 'маг':U
       then do:
            FIND ub.shop WHERE ub.shop.obj-code = clients.obj-code NO-LOCK .
            if available ub.shop
            then do:
                assign
                    t-addres = ( if trim( shop.addres1 ) <> "" then ( trim( shop.addres1 ) ) else "" )
                            + ( if trim( shop.addres2 ) <> "" then ( ", " + trim( shop.addres2 ) ) else "" )
                    t-phone = shop.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'скл':U
       then do:
            FIND ub.store WHERE ub.store.obj-code = clients.obj-code NO-LOCK .
            if available ub.store
            then do:
                assign
                    t-addres = ( if trim( ub.store.addres1 ) <> "" then ( trim( ub.store.addres1 ) ) else "" )
                            + ( if trim( ub.store.addres2 ) <> "" then ( ", " + trim( ub.store.addres2 ) ) else "" )
                    t-phone = ub.store.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'чел':U
       then do:
            find ub.person where ub.person.psn-code = clients.obj-code no-lock .
            if available ub.person
            then do:
                assign
                    t-addres = ( if ub.person.ind <> 0 and ub.person.ind <> ? then string( ub.person.ind ) else "" )
                                + ( if  ub.person.city <> ? and trim(ub.person.city) <> "" then ( ", " + trim( ub.person.city ) ) else "" )
                                + ( if  ub.person.address <> ? and trim(ub.person.address) <> "" then ( ", " + trim( ub.person.address ) ) else "" )
                    t-phone = ub.person.phone1
                    t-inn = ub.person.inn
                    t-okpo = ub.person.okpo
                .
            end.
       end.
    end case.
if v-torgconf-outappr = yes
then do:
    put stream out-stream
        "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 197 - 61
    .
end.
define variable v-operation-type    as character    no-undo.
define variable v-organization      as character    no-undo.
assign
    v-organization = substitute( "ИНН &1 &2 (&3) &4 &5"
                            , t-inn
                            , caps( clients.obj-name )
                            , clients.obj-code
                            , t-addres
                            , t-phone
                     )
.
put stream out-stream
    space(5) Line format  "X(19)" at 179 skip
    space(5) "|"            at 179
             'код':U  format "X(3)"     at center-field( 179, 197, 3 )
             "|" at 197
    skip space(5)
             "Форма по ОКУД" format "X(13)" at right-field ( 179, 13 )
             "| "                           at 179
             "0330213"                      at center-field( 179, 197, 7 )
             "|"                            at 197
    skip space(5)
                   v-organization
                                    format "X(160)"
                   "по ОКПО"        format "X(7)"       at right-field ( 179, 7 )
                   "| "                                 at 179
                   t-okpo           format "X(10)"      at center-field( 179, 197, 10 )
                   "|"                                  at 197
    skip space(5)
             "Вид деятельности по ОКДП" format "X(24)"  at right-field ( 179, 24 )
             "| "                                       at 179
             "|"                                        at 197
.
run torg13xl-write-cell-data in this-procedure (
      input "h_organization":U
    , input trim( v-organization )
).
assign
    v-operation-type =
              ( if t-doc.doc-type = 'при':U
                then " приход"
                else ( if t-doc.doc-type = 'возврат':U
                       then "возврат"
                       else " расход" ) )
.
put stream out-stream
    skip space(5)
             "Вид операции" format "X(12)"  at right-field ( 179, 12 )
             "| "                           at 179
              v-operation-type
                            format "X(7)"   at center-field( 179, 197, 7 )
             "|"                            at 197
    skip space(5)
             Line format  "X(19)"      at 179
.
run torg13xl-write-cell-data in this-procedure (
      input "h_operationType":U
    , input trim( v-operation-type )
).
run torg13xl-write-cell-data in this-procedure (
    input "h_OKPO":U
    , input trim( t-okpo )
).
put stream out-stream
    skip
        Line                format "X(32)" at 65
    skip
        "НАКЛАДНАЯ"                             at right-field ( 65, 9 )
        "|"                                     at 65
        string( tdoc-code ) format "X(14)"      at center-field( 65, 83, 14 )
        "|"                                     at 83
        v-doc-date-string
                            format "X(10)"      at center-field( 83, 96, 10 )
        "|"                                     at 96
        (if t-doc.status_ <> 'факт':U
         then string( "(" + caps(t-doc.status_) + ")" )
         else ""
        )                   format "X(100)"
    skip
        Line                format "X(32)" at 65
    skip
        "НА ВНУТРЕННЕЕ ПЕРЕМЕЩЕНИЕ, ПЕРЕДАЧУ ТОВАРОВ, ТАРЫ"
                            format "X(49)"      at center-field( 65 - 7, 96, 49 )
    skip
.
run torg13xl-write-cell-data in this-procedure (
      input "h_docCode":U
    , input trim( tdoc-code )
).
run torg13xl-write-cell-data in this-procedure (
      input "h_docDate":U
    , input trim( v-doc-date-string )
).
put stream out-stream
        Line format "X(197)"
    skip
        "| "
        "Отправитель"             format "X(11)"
        "| "                                        at 60
        "Получатель"              format "X(10)"
        "| "                                        at 120
        "Корреспондирующий счет"  format "X(22)"
        "|"                                         at 180
        "|"                                         at 197
    skip
        "|"
        Line                        format "X(195)"
        "|"
    skip
        "| "
        "структурное"               format "X(11)"
        "| "                                        at 40
        "вид деятельности"          format "X(16)"
        "| "                                        at 60
        "структурное"               format "X(11)"
        "| "                                        at 100
        "вид деятельности"          format "X(16)"
        "| "                                        at 120
        "счет, субсчет"             format "X(13)"
        "| "                                        at 160
        "код аналитического"        format "X(18)"
        "|"                                         at 180
        "|"                                         at 197
    skip
        "| "
        "подразделение"             format "X(13)"
        "|"                                         at 40
        "| "                                        at 60
        "подразделение"             format "X(13)"
        "|"                                         at 100
        "|"                                         at 120
        "|"                                         at 160
        "учета"                     format "X(5)"
        "|"                                         at 180
        "|"                                         at 197
    skip
        "|"
        Line format "X(195)"
        "|"
    skip
.
if t-doc.doc-type = 'при':U or t-doc.doc-type = 'возврат':U
then do:
    find first clients no-lock
         where clients.obj-type = t-doc.cli-type
           and clients.obj-code = t-doc.cli-code
    .
end.
else do:
    find first clients no-lock
         where clients.obj-type = t-doc.obj-type
           and clients.obj-code = t-doc.obj-code
    .
end.
put stream out-stream
    "| "
    string( clients.obj-name ) format "X(36)"
    "|"                                                 at 40
.
run torg13xl-write-cell-data in this-procedure (
      input "h_objFrom":U
    , input trim( clients.obj-name )
).
if t-doc.doc-type = 'при':U or t-doc.doc-type = 'возврат':U
then do:
    find first clients no-lock
         where clients.obj-type = t-doc.obj-type
           and clients.obj-code = t-doc.obj-code
    .
end.
else do:
    find first clients no-lock
         where clients.obj-type = t-doc.cli-type
           and clients.obj-code = t-doc.cli-code
    .
end.
put stream out-stream
    "|"                                                 at 60
    string( clients.obj-name ) format "X(36)"
    "|"                                                 at 100
    "|"                                                 at 120
    "|"                                                 at 160
    "|"                                                 at 180
    "|"                                                 at 197
    skip
    Line format "X(197)" skip
.
run torg13xl-write-cell-data in this-procedure (
      input "h_objTo":U
    , input trim( clients.obj-name )
).
if costprice
then do:
    if p-print-gold = yes
    then do:
        form with frame f-doc-cost-gold .
        if sort-gr = yes or p-print-prod = yes
        then do:
            down stream out-stream 1 with frame f-doc-cost-gold .
        end.
    end.
    else do:
        form with frame f-doc-cost.
        if sort-gr = yes or p-print-prod = yes
        then do:
            down stream out-stream 1 with frame f-doc-cost .
        end.
    end.
end.
else do:
    if p-print-gold = yes
    then do:
        form with frame f-doc-doc-gold .
        if sort-gr = yes or p-print-prod = yes
        then do:
            down stream out-stream 1 with frame f-doc-doc-gold .
        end.
    end.
    else do:
        form with frame f-doc-doc.
        if sort-gr = yes or p-print-prod = yes
        then do:
            down stream out-stream 1 with frame f-doc-doc .
        end.
    end.
end.
assign
    v-line-counter  = 0
    v-new-prod      = yes
    sum-tqnty       = 0
    sum-SumNoNDS    = 0
    sum-SumNDS      = 0
    sum-SumwithNDS  = 0
.
if sort-name = yes
then do:
    if p-print-prod = yes
    then do:
        if sort-gr = yes
        then do:
            for each doc-line no-lock
               where doc-line.doc-code = t-doc.doc-code
              ,first goods no-lock
               where goods.prod-type    = doc-line.prod-type
                 and goods.prod-code    = doc-line.prod-code
                 and goods.artic        = doc-line.artic
              ,first clients no-lock
               where clients.obj-type   = goods.prod-type
                 and clients.obj-code   = goods.prod-code
            break   by clients.obj-name
                    by goods.grp-name
                    by goods.gds-name
            :
                if first-of (clients.obj-name)
                then do:
                    run print-prod-line in this-procedure.
                end.
                if first-of (goods.grp-name)
                then do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
        else do:
            for each doc-line no-lock
               where doc-line.doc-code = t-doc.doc-code
             , first goods no-lock
               where goods.prod-type    = doc-line.prod-type
                 and goods.prod-code    = doc-line.prod-code
                 and goods.artic        = doc-line.artic
              ,first clients no-lock
               where clients.obj-type   = goods.prod-type
                 and clients.obj-code   = goods.prod-code
            break   by clients.obj-name
                    by goods.gds-name
            :
                if first-of (clients.obj-name)
                then do:
                    run print-prod-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
    end.
    else do:
        if sort-gr = yes
        then do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            break by goods.grp-name
                by goods.gds-name
            :
                if first-of (goods.grp-name)
                then do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
        else do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            break by goods.gds-name
            :
                run print-doc-line in this-procedure.
            end.
        end.
    end.
end.
else do:
    if p-print-prod = yes
    then do:
        if sort-gr = yes
        then do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
              ,first clients no-lock
               where clients.obj-type   = goods.prod-type
                 and clients.obj-code   = goods.prod-code
            break   by clients.obj-name
                    by goods.grp-name
                    by doc-line.line-num
            :
                if first-of (clients.obj-name)
                then do:
                    run print-prod-line in this-procedure.
                end.
                if first-of (goods.grp-name)
                then do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
        else do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
              where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            , first clients no-lock
              where clients.obj-type   = goods.prod-type
                and clients.obj-code   = goods.prod-code
            break   by clients.obj-name
                    by doc-line.line-num
            :
                if first-of (clients.obj-name)
                then do:
                    run print-prod-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
    end.
    else do:
        if sort-gr = yes
        then do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            break by goods.grp-name
                by doc-line.line-num
            :
                if first-of (goods.grp-name)
                then do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
        else do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            break by doc-line.line-num
            :
                run print-doc-line in this-procedure.
            end.
        end.
    end.
end.
if line-counter( Out-stream ) + 11 > page-size( Out-stream )
then do:
    if p-print-gold = yes
    then do:
        if costprice =yes
        then do:
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
        end.
        else do:
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
        end.
        page stream Out-stream .
    end.
    else do:
        if costprice =yes
        then do:
define variable vss-include-info23 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
        end.
        else do:
define variable vss-include-info24 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
        end.
        page stream Out-stream .
    end.
end.
hide stream Out-stream frame Bottomframe .
if p-print-gold = yes
then do:
    if costprice = yes
    then do:
define variable vss-include-info25 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
        display stream Out-stream
            "Всего по накладной"    @ temp_gds-name.gds-name
            t-doc.fact-qnty         @ tqnty
            sum-SumNoNDS            @ SumNoNDS
            sum-SumNDS              @ SumNDS
            sum-SumwithNDS          @ SumwithNDS
            with frame f-doc-cost-gold .
        down stream Out-stream 2 with frame f-doc-cost-gold .
    end.
    else do:
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
        display stream Out-stream
            "Всего по накладной"    @ temp_gds-name.gds-name
            t-doc.fact-qnty         @ tqnty
            sum-SumNoNDS            @ SumNoNDS
            sum-SumNDS              @ SumNDS
            sum-SumwithNDS          @ SumwithNDS
            with frame f-doc-doc-gold .
        down stream Out-stream 2 with frame f-doc-doc-gold .
    end.
end.
else do:
    if costprice = yes
    then do:
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
        display stream Out-stream
            "Всего по накладной"    @ temp_gds-name.gds-name
            t-doc.fact-qnty         @ tqnty
            sum-SumNoNDS            @ SumNoNDS
            sum-SumNDS              @ SumNDS
            sum-SumwithNDS          @ SumwithNDS
            with frame f-doc-cost .
        down stream Out-stream 2 with frame f-doc-cost .
    end.
    else do:
define variable vss-include-info28 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
        display stream Out-stream
            "Всего по накладной"    @ temp_gds-name.gds-name
            t-doc.fact-qnty         @ tqnty
            sum-SumNoNDS            @ SumNoNDS
            sum-SumNDS              @ SumNDS
            sum-SumwithNDS          @ SumwithNDS
            with frame f-doc-doc .
        down stream Out-stream 2 with frame f-doc-doc .
    end.
end.
run torg13xl-write-cell-data in this-procedure (
      input "it_qnty":U
    , input string( t-doc.fact-qnty )
).
if costprice
then do:
    run torg13xl-write-cell-data in this-procedure (
          input "it_sum":U
        , input if no-vat then string(sum-SumNoNDS) else string(sum-SumwithNDS)
    ).
end .
else do :
run torg13xl-write-cell-data in this-procedure (
      input "it_sum":U
    , input string( sum-SumwithNDS )
).
end .
if costprice
then do :
if PrintRubl
then do:
    run rep/wp-rub.p (
          input if no-vat then sum-SumNoNDS else sum-SumwithNDS
        , output s1
        , output s2
    ).
end.
else do:
    run rep/wp.p (
          input p-mainmenu-handle
        , input if no-vat then sum-SumNoNDS else sum-SumwithNDS
        , output s1
        , output s2
    ).
end.
    run torg13xl-write-cell-data in this-procedure (
          input "f_itSumStr":U
        , input s1
    ).
end .
else do :
    if PrintRubl
    then do:
        run rep/wp-rub.p (
              input sum-SumwithNDS
            , output s1
            , output s2
        ).
    end.
    else do:
        run rep/wp.p (
              input p-mainmenu-handle
            , input sum-SumwithNDS
            , output s1
            , output s2
        ).
    end.
    run torg13xl-write-cell-data in this-procedure (
          input "f_itSumStr":U
        , input s1
    ).
end .
if t-doc.ext-doc-type = 'iv':U
then do:
  assign
     v-otpposition = p-torgconf-t_pass-position
     v-otpname     = p-torgconf-t_pass-fname
     v-polposition = p-torgconf-post
     v-polname     = p-torgconf-wrkr-name
  .
end.
else do:
  assign
     v-otpposition = p-torgconf-post
     v-otpname     = p-torgconf-wrkr-name
     v-polposition = p-torgconf-accept-position
     v-polname     = p-torgconf-accept-fname
  .
end.
run torg13xl-write-cell-data in this-procedure (
      input "f_pass_fname":U
    , input (if trim(v-otpname) = "" then "" else v-otpname)
).
run torg13xl-write-cell-data in this-procedure (
      input "f_pass_position":U
    , input (if trim(v-otpposition) = "" then "" else v-otpposition)
).
run torg13xl-write-cell-data in this-procedure (
      input "f_accept_position":U
    , input (if trim(v-polposition) = "" then "" else v-polposition)
).
run torg13xl-write-cell-data in this-procedure (
      input "f_accept_fname":U
    , input (if trim(v-polname) = "" then "" else v-polname)
).
if trim(v-otpname) = ""
then do:
   v-otpname = string(UndLine, "X(29)").
end.
if trim(v-otpposition) = ""
then do:
   v-otpposition = string(UndLine, "X(23)").
end.
if trim(v-polposition) = ""
then do:
   v-polposition = string(UndLine, "X(23)").
end.
if trim(v-polname) = ""
then do:
   v-polname = string(UndLine, "X(29)").
end.
put stream Out-stream
    skip space(10)
        string( "Отпустил " ) format "X(9)"
        v-otpposition format "X(23)" string( " " ) format "X(1)"
        UndLine format "X(19)" string( " " ) format "X(1)"
           v-otpname  format "X(29)" string( " товар и тару по количеству и надлежащему качеству" ) format "X(50)"
    skip space(23)
        string( "должность" )           format "X(19)" string( " " ) format "X(1)" space(2)
        string( "подпись" )             format "X(19)" string( " " ) format "X(1)"
        string( "расшифровка подписи" ) format "X(29)"
    skip(1) space(10)
        string( "на сумму " ) format "X(9)"
        caps(s1) format "X(175)"
    skip(1) space(10)
        string( "Получил " ) format "X(9)"
        v-polposition format "X(23)" string( " " ) format "X(1)"
        UndLine format "X(19)" string( " " ) format "X(1)"
        v-polname     format "X(29)"
    skip space(23)
        string( "должность" )           format "X(19)" string( " " ) format "X(1)"  space(2)
        string( "подпись" )             format "X(19)" string( " " ) format "X(1)"
        string( "расшифровка подписи" ) format "X(29)" skip
    .
    if v-torgconf-outprim = yes
    then do:
    end.
    else do:
        define variable v-comment    as character    no-undo.
        assign
            v-comment = trim( ( if not( t-doc.PS begins "@":U )
                                   then replace( t-doc.PS, chr(10), " ":U )
                                   else "":U ) )
        .
        if v-comment <> "":U
        and v-comment <> ?
        then do:
            put stream out-stream
                skip(1) space(5)
                    substitute( "Примечание: &1", v-comment )  format "X(163)"
            .
        end.
    end.
run torg13xl-close in this-procedure .
if session :set-wait-state( "" ) then.
output stream Out-stream close.
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
procedure print-doc-line :
do
on error undo, return error
:
assign
PricendS = 0
PricewithNDS = 0
PriceNoNDS = 0
SumNDS = 0
SumNoNDS = 0
SumwithNDS = 0
tqnty = 0
.
    if p-print-gold = yes
    then do:
        find first buf_units no-lock
            where buf_units.unit-name = goods.unit-base
        .
        assign
            v-not-gold  = ?
        .
        if lookup('2ед':U, buf_units.type) <> 0
        then do:
            run get-cli-qnty in this-procedure
                             (    input recid( doc-line )
                                , output qnty-pl
                             ).
            assign
                v-not-gold  = no
            .
        end.
        if lookup('доп':U, buf_units.type) <> 0
        then do:
            assign
                qnty-pl     = doc-line.doc-qnty
                v-not-gold  = no
            .
        end.
        if  v-not-gold  = ?
        then do:
            assign
                v-not-gold  = yes
            .
        end.
    end.
    assign
        v-gds-name  = goods.gds-name
    .
    for each temp_gds-name
    :
        delete temp_gds-name.
    end.
    create temp_gds-name.
    assign
        s1 = breakstr( v-gds-name,  28, input-output temp_gds-name.gds-name, input-output s2)
        v-gds-name-counter          = 1
        temp_gds-name.string-num    = 1
    .
    do
    while s2 <> "":U
    :
        create temp_gds-name.
        assign
            temp_gds-name.gds-name      = breakstr( input s2
                                                  , input 28
                                                  , input-output temp_gds-name.gds-name
                                                  , input-output s2
                                                  )
            v-gds-name-counter          = v-gds-name-counter + 1
            temp_gds-name.string-num    = v-gds-name-counter
        .
    end.
    find first temp_gds-name .
    find first gds-prt no-lock
            where gds-prt.upper-code = goods.prt-root
    .
    assign
        rootnode_code = gds-prt.node-code.
    .
    if costprice
    then do:
assign
  price-rubl-with-tax-loc = doc-line.price-rubl
  price-base-with-tax-loc = doc-line.price-base
.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = t-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = doc-line.artic     and
                                     in-vatp-goods.prod-type = doc-line.prod-type and
                                     in-vatp-goods.prod-code = doc-line.prod-code no-lock.
   if (not t-doc.internal and
           t-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = doc-line.road-tax
          road-tax-rubl-loc = doc-line.road-tax * t-doc.base-rate / t-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = doc-line.road-tax
          road-tax-base-loc = doc-line.road-tax / t-doc.base-rate * t-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if doc-line.transport-base = ? then 0 else doc-line.transport-base)
        transport-rubl-loc = (if doc-line.transport-rubl = ? then 0 else doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if doc-line.other-base     = ? then 0 else doc-line.other-base)
        other-rubl-loc     = (if doc-line.other-rubl     = ? then 0 else doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if doc-line.vat-pc         = ? then 0 else doc-line.vat-pc)
        slt-pc-loc         = (if doc-line.slt-pc         = ? then 0 else doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = doc-line.obj-code  and
                                      in-vatp-parts.artic     = doc-line.artic     and
                                      in-vatp-parts.prod-type = doc-line.prod-type and
                                      in-vatp-parts.prod-code = doc-line.prod-code
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
        road-tax-base-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-base-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-rubl-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-base-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-rubl-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
                                        vat-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
                vat-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
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
        assign PricendS = ( if PrintRubl then vat-rubl-loc else vat-base-loc ).
        if PricendS = ? then assign PricendS = 0.
        assign
            PricewithNDS = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
            PriceNoNDS = PricewithNDS - PricendS
        .
    end.
    else do:
if t-doc.ext-doc-type = 'ot':U or
   t-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = t-doc.doc-code
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
find first out-vatp_goods where out-vatp_goods.artic     = doc-line.artic     and
                                   out-vatp_goods.prod-type = doc-line.prod-type and
                                   out-vatp_goods.prod-code = doc-line.prod-code no-lock.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  doc-line.artic
  ,input  doc-line.prod-type
  ,input  doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
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
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax / t-doc.base-rate * t-doc.base-scale)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   / t-doc.base-rate * t-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * t-doc.base-rate / t-doc.base-scale)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * t-doc.base-rate / t-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = t-doc.doc-code
       and out-vatp_doc-line.artic      = doc-line.artic
       and out-vatp_doc-line.prod-type  = doc-line.prod-type
       and out-vatp_doc-line.prod-code  = doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = t-doc.doc-code
                               and out-vatp_parts.obj-type   = t-doc.obj-type
                               and out-vatp_parts.obj-code   = t-doc.obj-code
                               and out-vatp_parts.artic      = doc-line.artic
                               and out-vatp_parts.prod-type  = doc-line.prod-type
                               and out-vatp_parts.prod-code  = doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
find first out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = t-doc.doc-code  and
                                     out-vatp_gds-dtl.artic     = doc-line.artic     and
                                     out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                     out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock no-error.
if available out-vatp_gds-dtl then do:
  find first buf_out-vatp_gds-dtl where buf_out-vatp_gds-dtl.doc-code  =  t-doc.doc-code                and
                                           buf_out-vatp_gds-dtl.artic     =  doc-line.artic                   and
                                           buf_out-vatp_gds-dtl.prod-type =  doc-line.prod-type               and
                                           buf_out-vatp_gds-dtl.prod-code =  doc-line.prod-code               and
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
        slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-base-sale            = out-vatp_gds-dtl.discnt-base
                price-rubl-with-tax-sale    = (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)
        slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-rubl-sale            = out-vatp_gds-dtl.discnt-rubl
        .
    if t-doc.doc-type = 'инв':U then do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
    else do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale ) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = t-doc.doc-code  and
                                       out-vatp_gds-dtl.artic     = doc-line.artic     and
                                       out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                       out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock :
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
       varslt-base-factovp = varslt-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-base-factovp = varvat-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-base-factovp = varvatcons-base-factovp + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-factovp = vardsc-base-factovp + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.fact-qnty
       varsum-base-docovp  = varsum-base-docovp  + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.doc-qnty
       varslt-base-docovp  = varslt-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-base-docovp  = varvat-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-base-docovp  = varvatcons-base-docovp  + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-docovp  = vardsc-base-docovp  + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.doc-qnty
      .
      assign
             varsum-rubl-factovp = varsum-rubl-factovp + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.fact-qnty
       varslt-rubl-factovp = varslt-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-rubl-factovp = varvat-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-rubl-factovp = varvatcons-rubl-factovp + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-factovp = vardsc-rubl-factovp + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.fact-qnty
       varsum-rubl-docovp  = varsum-rubl-docovp  + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.doc-qnty
       varslt-rubl-docovp  = varslt-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-rubl-docovp  = varvat-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-rubl-docovp  = varvatcons-rubl-docovp  + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-docovp  = vardsc-rubl-docovp  + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.doc-qnty   .
    end.
    if t-doc.doc-type = 'инв':U then do:
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
        assign PricendS = ( if PrintRubl then vat-rubl-sale else vat-base-sale ).
        if PricendS = ? then assign PricendS = 0.
        assign
            PricewithNDS = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
            PriceNoNDS = PricewithNDS - PricendS
        .
    end.
    if not can-do( '_Пустая шкала':U, gds-prt.node-name )
    then do:
            if PrintScale = yes
            then do:
                if p-print-gold = yes
                then do:
                    if costprice = yes
                    then do:
                        display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-cost-gold .
                        down stream Out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info33 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                    end.
                    else do:
                        display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-doc-gold .
                        down stream Out-stream 1 with frame f-doc-doc-gold .
define variable vss-include-info34 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
                    end.
                end.
                else do:
                    if costprice = yes
                    then do:
                        display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-cost .
                        down stream Out-stream 1 with frame f-doc-cost .
define variable vss-include-info35 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
                    end.
                    else do:
                        display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-doc .
                        down stream Out-stream 1 with frame f-doc-doc .
define variable vss-include-info36 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
                    end.
                end.
                assign
                    v-line-counter = v-line-counter + 1
                .
                run torg13xl-write-line-data in this-procedure (
                      input goods.artic + " ":U + goods.gds-name
                    , input string( goods.gds-code )
                    , input goods.unit-base
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                ).
                assign
                    LineCounter = LineCounter + 1
                .
                if p-break-name = yes
                then do:
                    run display-gds-name in this-procedure .
                end.
            end.
            assign
                sum-prt-tqnty       = 0
                sum-prt-SumNoNDS    = 0
                sum-prt-SumNDS      = 0
                sum-prt-SumwithNDS  = 0
            .
            if t-doc.ext-doc-type = 'iv':U
            or t-doc.ext-doc-type = 'ev':U
            or t-doc.ext-doc-type = 'rv':U
            then do:
              for each gds-dtl no-lock
                 where gds-dtl.prod-type = doc-line.prod-type
                   and gds-dtl.prod-code = doc-line.prod-code
                   and gds-dtl.artic = doc-line.artic
                   and gds-dtl.doc-code = doc-line.doc-code
              :
                  find first gds-prt no-lock
                       where gds-prt.node-code = gds-dtl.prt-code
                  .
                  assign
                      prt-tqnty =  gds-dtl.fact-qnty
                      prt-SumNoNDS = PriceNoNDS * prt-tqnty
                      prt-SumNDS = PricendS * prt-tqnty
                      prt-SumwithNDS = PricewithNDS * prt-tqnty
                  .
                  assign
                      sum-prt-tqnty       = sum-prt-tqnty      +  prt-tqnty
                      sum-prt-SumNoNDS    = sum-prt-SumNoNDS   +  prt-SumNoNDS
                      sum-prt-SumNDS      = sum-prt-SumNDS     +  prt-SumNDS
                      sum-prt-SumwithNDS  = sum-prt-SumwithNDS +  prt-SumwithNDS
                  .
                  if PrintScale = yes
                  then do:
                      find first bar-code no-lock
                              where bar-code.gds-code  = goods.gds-code
                              and bar-code.unit-cli  = goods.unit-base
                              and bar-code.node-code = gds-dtl.prt-code
                              and bar-code.part-code = ""
                              and bar-code.in-code   = ""
                      .
                      assign
                          PrtName = goods.gds-name + "//" + gds-prt.f-name
                      .
                      if p-print-gold = yes
                      then do:
                          if costprice = yes
                          then do:
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                      with frame f-doc-cost-gold .
                              down stream Out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info37 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                              run torg13xl-write-line-data in this-procedure (
                                    input PrtName
                                  , input string( goods.gds-code )
                                  , input goods.unit-base
                                  , input "":U
                                  , input "":U
                                  , input "":U
                                  , input string( prt-tqnty )
                                  , input if no-vat then string(PriceNoNDS)
                                                    else string(PriceWithNDS)
                                  , input if no-vat then string(prt-SumNoNDS)
                                                    else string(prt-SumwithNDS)
                              ).
                          end.
                          else do:
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                      with frame f-doc-doc-gold .
                              down stream Out-stream 1 with frame f-doc-doc-gold .
define variable vss-include-info38 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
                              run torg13xl-write-line-data in this-procedure (
                                    input PrtName
                                  , input string( goods.gds-code )
                                  , input goods.unit-base
                                  , input "":U
                                  , input "":U
                                  , input "":U
                                  , input string( prt-tqnty )
                                  , input string( PricewithNDS )
                                  , input string( prt-SumwithNDS )
                              ).
                          end.
                      end.
                      else do:
                          if costprice = yes
                          then do:
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                      with frame f-doc-cost .
                              down stream Out-stream 1 with frame f-doc-cost .
define variable vss-include-info39 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
                              run torg13xl-write-line-data in this-procedure (
                                    input PrtName
                                  , input string( goods.gds-code )
                                  , input goods.unit-base
                                  , input "":U
                                  , input "":U
                                  , input "":U
                                  , input string( prt-tqnty )
                                  , input if no-vat then string(PriceNoNDS)
                                                    else string(PriceWithNDS)
                                  , input if no-vat then string(prt-SumNoNDS)
                                                    else string(prt-SumwithNDS)
                              ).
                          end.
                          else do:
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                      with frame f-doc-doc .
                              down stream Out-stream 1 with frame f-doc-doc .
define variable vss-include-info40 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
                      run torg13xl-write-line-data in this-procedure (
                            input PrtName
                          , input string( goods.gds-code )
                          , input goods.unit-base
                          , input "":U
                          , input "":U
                          , input "":U
                          , input string( prt-tqnty )
                          , input string( PricewithNDS )
                          , input string( prt-SumwithNDS )
                      ).
                          end.
                      end.
                  end.
                  if PrintParts then do:
                    for each parts no-lock
                       where parts.prod-type = doc-line.prod-type
                         and parts.prod-code = doc-line.prod-code
                         and parts.artic = doc-line.artic
                         and parts.out-code = doc-line.doc-code
                    :
                        assign
                            prt-tqnty =  parts.fact-qnty
                            prt-SumNoNDS = PriceNoNDS * prt-tqnty
                            prt-SumNDS = PricendS * prt-tqnty
                            prt-SumwithNDS = PricewithNDS * prt-tqnty
                        .
                        assign
                            sum-prt-tqnty       = sum-prt-tqnty      +  prt-tqnty
                            sum-prt-SumNoNDS    = sum-prt-SumNoNDS   +  prt-SumNoNDS
                            sum-prt-SumNDS      = sum-prt-SumNDS     +  prt-SumNDS
                            sum-prt-SumwithNDS  = sum-prt-SumwithNDS +  prt-SumwithNDS
                        .
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                      with frame f-doc-cost-gold .
                              down stream Out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info41 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                              run torg13xl-write-line-data in this-procedure (
                                    input PrtName
                                  , input string( goods.gds-code )
                                  , input goods.unit-base
                                  , input "":U
                                  , input "":U
                                  , input "":U
                                  , input string( prt-tqnty )
                                  , input if no-vat then string(PriceNoNDS)
                                                    else string(PriceWithNDS)
                                  , input if no-vat then string(prt-SumNoNDS)
                                                    else string(prt-SumwithNDS)
                              ).
                    end .
                  end.
              end.
            end.
            else do:
            for each gds-dtl no-lock
               where gds-dtl.prod-type = doc-line.prod-type
                 and gds-dtl.prod-code = doc-line.prod-code
                 and gds-dtl.artic = doc-line.artic
                 and gds-dtl.doc-code = doc-line.doc-code
            :
                find first gds-prt no-lock
                     where gds-prt.node-code = gds-dtl.prt-code
                .
                assign
                    prt-tqnty =  gds-dtl.fact-qnty
                    prt-SumNoNDS = PriceNoNDS * prt-tqnty
                    prt-SumNDS = PricendS * prt-tqnty
                    prt-SumwithNDS = PricewithNDS * prt-tqnty
                .
                assign
                    sum-prt-tqnty       = sum-prt-tqnty      +  prt-tqnty
                    sum-prt-SumNoNDS    = sum-prt-SumNoNDS   +  prt-SumNoNDS
                    sum-prt-SumNDS      = sum-prt-SumNDS     +  prt-SumNDS
                    sum-prt-SumwithNDS  = sum-prt-SumwithNDS +  prt-SumwithNDS
                .
                if PrintScale = yes
                then do:
                    find first bar-code no-lock
                            where bar-code.gds-code  = goods.gds-code
                            and bar-code.unit-cli  = goods.unit-base
                            and bar-code.node-code = gds-dtl.prt-code
                            and bar-code.part-code = ""
                            and bar-code.in-code   = ""
                    .
                    assign
                        PrtName = goods.gds-name + "//" + gds-prt.f-name
                    .
                    if p-print-gold = yes
                    then do:
                        if costprice = yes
                        then do:
                            display stream Out-stream
                                    PrtName @     temp_gds-name.gds-name
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    prt-tqnty @ tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    prt-SumNoNDS @ SumNoNDS
                                    prt-SumNDS @ SumNDS
                                    prt-SumwithNDS @ SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                    with frame f-doc-cost-gold .
                            down stream Out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info42 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                            run torg13xl-write-line-data in this-procedure (
                                  input PrtName
                                , input string( goods.gds-code )
                                , input goods.unit-base
                                , input "":U
                                , input "":U
                                , input "":U
                                , input string( prt-tqnty )
                                , input if no-vat then string(PriceNoNDS)
                                                  else string(PriceWithNDS)
                                , input if no-vat then string(prt-SumNoNDS)
                                                  else string(prt-SumwithNDS)
                            ).
                        end.
                        else do:
                            display stream Out-stream
                                    PrtName @     temp_gds-name.gds-name
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    prt-tqnty @ tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    prt-SumNoNDS @ SumNoNDS
                                    prt-SumNDS @ SumNDS
                                    prt-SumwithNDS @ SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                    with frame f-doc-doc-gold .
                            down stream Out-stream 1 with frame f-doc-doc-gold .
define variable vss-include-info43 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
                            run torg13xl-write-line-data in this-procedure (
                                  input PrtName
                                , input string( goods.gds-code )
                                , input goods.unit-base
                                , input "":U
                                , input "":U
                                , input "":U
                                , input string( prt-tqnty )
                                , input string( PricewithNDS )
                                , input string( prt-SumwithNDS )
                            ).
                        end.
                    end.
                    else do:
                        if costprice = yes
                        then do:
                            display stream Out-stream
                                    PrtName @     temp_gds-name.gds-name
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    prt-tqnty @ tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    prt-SumNoNDS @ SumNoNDS
                                    prt-SumNDS @ SumNDS
                                    prt-SumwithNDS @ SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                    with frame f-doc-cost .
                            down stream Out-stream 1 with frame f-doc-cost .
define variable vss-include-info44 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
                            run torg13xl-write-line-data in this-procedure (
                                  input PrtName
                                , input string( goods.gds-code )
                                , input goods.unit-base
                                , input "":U
                                , input "":U
                                , input "":U
                                , input string( prt-tqnty )
                                , input if no-vat then string(PriceNoNDS)
                                                  else string(PriceWithNDS)
                                , input if no-vat then string(prt-SumNoNDS)
                                                  else string(prt-SumwithNDS)
                            ).
                        end.
                        else do:
                            display stream Out-stream
                                    PrtName @     temp_gds-name.gds-name
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    prt-tqnty @ tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    prt-SumNoNDS @ SumNoNDS
                                    prt-SumNDS @ SumNDS
                                    prt-SumwithNDS @ SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                    with frame f-doc-doc .
                            down stream Out-stream 1 with frame f-doc-doc .
define variable vss-include-info45 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
                    run torg13xl-write-line-data in this-procedure (
                          input PrtName
                        , input string( goods.gds-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty )
                        , input string( PricewithNDS )
                        , input string( prt-SumwithNDS )
                    ).
                        end.
                    end.
                end.
            end.
            end.
            assign
                tqnty       = sum-prt-tqnty
                SumNoNDS    = sum-prt-SumNoNDS
                SumNDS      = sum-prt-SumNDS
                SumwithNDS  = sum-prt-SumwithNDS
            .
            if not PrintScale
            then do:
                    find bar-code where bar-code.gds-code  = goods.gds-code
                                    and bar-code.unit-cli  = goods.unit-base
                                    and bar-code.node-code = rootnode_code
                                    and bar-code.part-code = ""
                                    and bar-code.in-code   = ""
                    no-lock .
                    if p-print-gold = yes
                    then do:
                        if costprice = yes
                        then do:
                            display stream Out-stream
                                    goods.artic
                                    temp_gds-name.gds-name
                                    goods.sort
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    tqnty
                                    qnty-pl when v-not-gold = no
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    SumNoNDS
                                    SumNDS
                                    SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                    with frame f-doc-cost-gold .
                            down stream Out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info46 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                            run torg13xl-write-line-data in this-procedure (
                                input goods.artic + " ":U + goods.gds-name
                              , input string( goods.gds-code )
                              , input goods.unit-base
                              , input "":U
                              , input "":U
                              , input "":U
                              , input string( tqnty )
                              , input if no-vat then string( PriceNoNDS )
                                                else string( PriceWithNDS )
                              , input if no-vat then string( SumNoNDS )
                                                else string( SumWithNDS )
                              ).
                        end.
                        else do:
                            display stream Out-stream
                                    temp_gds-name.gds-name
                                    goods.artic
                                    goods.sort
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    tqnty
                                    qnty-pl when v-not-gold = no
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    SumNoNDS
                                    SumNDS
                                    SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                    with frame f-doc-doc-gold .
                            down stream Out-stream 1 with frame f-doc-doc-gold .
define variable vss-include-info47 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
                            run torg13xl-write-line-data in this-procedure (
                                input goods.artic + " ":U + goods.gds-name
                              , input string( goods.gds-code )
                              , input goods.unit-base
                              , input "":U
                              , input "":U
                              , input "":U
                              , input string( tqnty )
                              , input string( PriceWithNDS )
                              , input string( SumWithNDS )
                    ).
                        end.
                    end.
                    else do:
                        if costprice = yes
                        then do:
                            display stream Out-stream
                                    temp_gds-name.gds-name
                                    goods.artic
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    SumNoNDS
                                    SumNDS
                                    SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                    with frame f-doc-cost .
                            down stream Out-stream 1 with frame f-doc-cost .
define variable vss-include-info48 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
                            run torg13xl-write-line-data in this-procedure (
                                input goods.artic + " ":U + goods.gds-name
                              , input string( goods.gds-code )
                              , input goods.unit-base
                              , input "":U
                              , input "":U
                              , input "":U
                              , input string( tqnty )
                              , input if no-vat then string( PriceNoNDS )
                                                else string( PriceWithNDS )
                              , input if no-vat then string( SumNoNDS )
                                                else string( SumWithNDS )
                              ).
                        end.
                        else do:
                            display stream Out-stream
                                    temp_gds-name.gds-name
                                    goods.artic
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    SumNoNDS
                                    SumNDS
                                    SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                    with frame f-doc-doc .
                            down stream Out-stream 1 with frame f-doc-doc .
define variable vss-include-info49 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
                    run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name
                        , input string( goods.gds-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( tqnty )
                        , input string( PricewithNDS )
                        , input string( SumwithNDS )
                    ).
                        end.
                    end.
                    assign
                        v-line-counter = v-line-counter + 1
                    .
                    LineCounter = LineCounter + 1 .
                    if p-break-name = yes
                    then do:
                        run display-gds-name in this-procedure .
                    end.
                end.
    end.
    else do:
            if t-doc.ext-doc-type = 'iv':U
            or t-doc.ext-doc-type = 'ev':U
            or t-doc.ext-doc-type = 'rv':U
            then do:
              find first bar-code no-lock
                   where bar-code.gds-code = goods.gds-code
                     and bar-code.unit-cli = goods.unit-base
                     and bar-code.node-code = rootnode_code
                     and bar-code.part-code = ""
                     and bar-code.in-code = ""
              .
              find first gds-dtl no-lock
                 where gds-dtl.doc-code = doc-line.doc-code
                   and gds-dtl.prod-type = doc-line.prod-type
                   and gds-dtl.prod-code = doc-line.prod-code
                   and gds-dtl.artic = doc-line.artic
                   and gds-dtl.prt-code = rootnode_code
              .
              assign
                  tqnty = gds-dtl.fact-qnty
                  unit-str = goods.unit-base
                  SumNoNDS = PriceNoNDS * tqnty
                  SumNDS = PricendS * tqnty
                  SumwithNDS = PricewithNDS * tqnty
              .
              if PrintScale = yes
              then do:
                  find first bar-code no-lock
                          where bar-code.gds-code  = goods.gds-code
                          and bar-code.unit-cli  = goods.unit-base
                          and bar-code.node-code = gds-dtl.prt-code
                          and bar-code.part-code = ""
                          and bar-code.in-code   = ""
                  .
                  assign
                      PrtName = goods.gds-name + "//" + gds-prt.f-name
                  .
                  if p-print-gold = yes
                  then do:
                      if costprice = yes
                      then do:
                          display stream Out-stream
                                  PrtName @     temp_gds-name.gds-name
                                  string( bar-code.b-code ) @ tb-code
                                  goods.unit-base
                                  prt-tqnty @ tqnty
                                  PriceNoNDS
                                  PricendS
                                  PricewithNDS
                                  prt-SumNoNDS @ SumNoNDS
                                  prt-SumNDS @ SumNDS
                                  prt-SumwithNDS @ SumwithNDS
                                  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                  sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                  with frame f-doc-cost-gold .
                          down stream Out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info50 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                          run torg13xl-write-line-data in this-procedure (
                                input PrtName
                              , input string( goods.gds-code )
                              , input goods.unit-base
                              , input "":U
                              , input "":U
                              , input "":U
                              , input string( prt-tqnty )
                              , input if no-vat then string(PriceNoNDS)
                                                else string(PriceWithNDS)
                              , input if no-vat then string(prt-SumNoNDS)
                                                else string(prt-SumwithNDS)
                          ).
                      end.
                      else do:
                          display stream Out-stream
                                  PrtName @     temp_gds-name.gds-name
                                  string( bar-code.b-code ) @ tb-code
                                  goods.unit-base
                                  prt-tqnty @ tqnty
                                  PriceNoNDS
                                  PricendS
                                  PricewithNDS
                                  prt-SumNoNDS @ SumNoNDS
                                  prt-SumNDS @ SumNDS
                                  prt-SumwithNDS @ SumwithNDS
                                  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                  sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                  with frame f-doc-doc-gold .
                          down stream Out-stream 1 with frame f-doc-doc-gold .
define variable vss-include-info51 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
                          run torg13xl-write-line-data in this-procedure (
                                input PrtName
                              , input string( goods.gds-code )
                              , input goods.unit-base
                              , input "":U
                              , input "":U
                              , input "":U
                              , input string( prt-tqnty )
                              , input string( PricewithNDS )
                              , input string( prt-SumwithNDS )
                          ).
                      end.
                  end.
                  else do:
                      if costprice = yes
                      then do:
                          display stream Out-stream
                                  PrtName @     temp_gds-name.gds-name
                                  string( bar-code.b-code ) @ tb-code
                                  goods.unit-base
                                  prt-tqnty @ tqnty
                                  PriceNoNDS
                                  PricendS
                                  PricewithNDS
                                  prt-SumNoNDS @ SumNoNDS
                                  prt-SumNDS @ SumNDS
                                  prt-SumwithNDS @ SumwithNDS
                                  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                  sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                  with frame f-doc-cost .
                          down stream Out-stream 1 with frame f-doc-cost .
define variable vss-include-info52 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
                          run torg13xl-write-line-data in this-procedure (
                                input PrtName
                              , input string( goods.gds-code )
                              , input goods.unit-base
                              , input "":U
                              , input "":U
                              , input "":U
                              , input string( prt-tqnty )
                              , input if no-vat then string(PriceNoNDS)
                                                else string(PriceWithNDS)
                              , input if no-vat then string(prt-SumNoNDS)
                                                else string(prt-SumwithNDS)
                          ).
                      end.
                      else do:
                          display stream Out-stream
                                  PrtName @     temp_gds-name.gds-name
                                  string( bar-code.b-code ) @ tb-code
                                  goods.unit-base
                                  prt-tqnty @ tqnty
                                  PriceNoNDS
                                  PricendS
                                  PricewithNDS
                                  prt-SumNoNDS @ SumNoNDS
                                  prt-SumNDS @ SumNDS
                                  prt-SumwithNDS @ SumwithNDS
                                  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                  sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                  with frame f-doc-doc .
                          down stream Out-stream 1 with frame f-doc-doc .
define variable vss-include-info53 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
                  run torg13xl-write-line-data in this-procedure (
                        input PrtName
                      , input string( goods.gds-code )
                      , input goods.unit-base
                      , input "":U
                      , input "":U
                      , input "":U
                      , input string( prt-tqnty )
                      , input string( PricewithNDS )
                      , input string( prt-SumwithNDS )
                  ).
                      end.
                  end.
              end.
              if PrintParts then do:
                for each parts no-lock
                   where parts.prod-type = doc-line.prod-type
                     and parts.prod-code = doc-line.prod-code
                     and parts.artic = doc-line.artic
                     and parts.out-code = doc-line.doc-code
                     break by parts.price-rubl
                :
                  if first-of(parts.price-rubl)
                  then do :
                    prt-tqnty = 0 .
                    PriceNoNDS = (parts.price-rubl / (1 + (parts.vat-pc / 100))) .
                    PricendS = (parts.price-rubl * parts.vat-pc / (100 + parts.vat-pc)) .
                    PricewithNDS = parts.price-rubl .
                  end .
                  assign
                      prt-tqnty = prt-tqnty + parts.fact-qnty
                      prt-SumNoNDS = PriceNoNDS * prt-tqnty
                      prt-SumNDS = PricendS * prt-tqnty
                      prt-SumwithNDS = PricewithNDS * prt-tqnty
                  .
                  assign
                      sum-prt-tqnty       = sum-prt-tqnty      +  prt-tqnty
                      sum-prt-SumNoNDS    = sum-prt-SumNoNDS   +  prt-SumNoNDS
                      sum-prt-SumNDS      = sum-prt-SumNDS     +  prt-SumNDS
                      sum-prt-SumwithNDS  = sum-prt-SumwithNDS +  prt-SumwithNDS
                  .
                  if last-of(parts.price-rubl)
                  then do :
                    display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            string( bar-code.b-code ) @ tb-code
                            goods.unit-base
                            prt-tqnty @ tqnty
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            prt-SumNoNDS @ SumNoNDS
                            prt-SumNDS @ SumNDS
                            prt-SumwithNDS @ SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-cost-gold .
                    down stream Out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info54 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + prt-tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + prt-SumNoNDS
                Pg-SumNDS = Pg-SumNDS + prt-SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + prt-SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                    run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name
                        , input string( goods.gds-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty )
                        , input if no-vat then string(PriceNoNDS)
                                          else string(PriceWithNDS)
                        , input if no-vat then string(prt-SumNoNDS)
                                          else string(prt-SumwithNDS)
                    ).
                  end .
                end .
              end.
              else do :
                find first bar-code no-lock
                     where bar-code.gds-code = goods.gds-code
                       and bar-code.unit-cli = goods.unit-base
                       and bar-code.node-code = rootnode_code
                       and bar-code.part-code = ""
                       and bar-code.in-code = ""
                .
                find first gds-dtl no-lock
                   where gds-dtl.doc-code = doc-line.doc-code
                     and gds-dtl.prod-type = doc-line.prod-type
                     and gds-dtl.prod-code = doc-line.prod-code
                     and gds-dtl.artic = doc-line.artic
                     and gds-dtl.prt-code = rootnode_code
                .
                assign
                    tqnty = gds-dtl.fact-qnty
                    unit-str = goods.unit-base
                    SumNoNDS = PriceNoNDS * tqnty
                    SumNDS = PricendS * tqnty
                    SumwithNDS = PricewithNDS * tqnty
                .
                if p-print-gold = yes
                then do:
                    if costprice = yes
                    then do:
                        display stream Out-stream
                            goods.artic
                            temp_gds-name.gds-name
                            goods.sort
                            string( bar-code.b-code ) @ tb-code
                            unit-str @ goods.unit-base
                            tqnty
                            qnty-pl when v-not-gold = no
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            SumNoNDS
                            SumNDS
                            SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-cost-gold .
                        down stream Out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info55 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                        run torg13xl-write-line-data in this-procedure (
                            input goods.artic + " ":U + goods.gds-name
                          , input string( goods.gds-code )
                          , input goods.unit-base
                          , input "":U
                          , input "":U
                          , input "":U
                          , input string( tqnty )
                          , input if no-vat then string( PriceNoNDS )
                                            else string( PriceWithNDS )
                          , input if no-vat then string(SumNoNDS)
                                            else string(SumwithNDS)
                        ).
                    end.
                    else do:
                        display stream Out-stream
                            goods.artic
                            temp_gds-name.gds-name
                            goods.sort
                            string( bar-code.b-code ) @ tb-code
                            unit-str @ goods.unit-base
                            tqnty
                            qnty-pl when v-not-gold = no
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            SumNoNDS
                            SumNDS
                            SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-doc-gold .
                        down stream Out-stream 1 with frame f-doc-doc-gold .
define variable vss-include-info56 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
                        run torg13xl-write-line-data in this-procedure (
                            input goods.artic + " ":U + goods.gds-name
                          , input string( goods.gds-code )
                          , input goods.unit-base
                          , input "":U
                          , input "":U
                          , input "":U
                          , input string( tqnty )
                          , input string( PriceWithNDS )
                          , input string(SumwithNDS)
                        ).
                    end.
                end.
                else do:
                    if costprice = yes
                    then do:
                        display stream Out-stream
                            goods.artic
                            temp_gds-name.gds-name
                            string( bar-code.b-code ) @ tb-code
                            unit-str @ goods.unit-base
                            tqnty
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            SumNoNDS
                            SumNDS
                            SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-cost .
                        down stream Out-stream 1 with frame f-doc-cost .
define variable vss-include-info57 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
                        run torg13xl-write-line-data in this-procedure (
                            input goods.artic + " ":U + goods.gds-name
                          , input string( goods.gds-code )
                          , input goods.unit-base
                          , input "":U
                          , input "":U
                          , input "":U
                          , input string( tqnty )
                          , input if no-vat then string( PriceNoNDS )
                                            else string( PriceWithNDS )
                          , input if no-vat then string(SumNoNDS)
                                            else string(SumwithNDS)
                        ).
                    end.
                    else do:
                        display stream Out-stream
                            goods.artic
                            temp_gds-name.gds-name
                            string( bar-code.b-code ) @ tb-code
                            unit-str @ goods.unit-base
                            tqnty
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            SumNoNDS
                            SumNDS
                            SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-doc .
                        down stream Out-stream 1 with frame f-doc-doc .
define variable vss-include-info58 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
                run torg13xl-write-line-data in this-procedure (
                      input goods.artic + " ":U + goods.gds-name
                    , input string( goods.gds-code )
                    , input goods.unit-base
                    , input "":U
                    , input "":U
                    , input "":U
                    , input string( tqnty )
                          , input string( PriceWithNDS )
                    , input string( SumwithNDS )
                ).
                    end.
                end.
              end .
            end.
            else do:
              find first bar-code no-lock
                   where bar-code.gds-code = goods.gds-code
                     and bar-code.unit-cli = goods.unit-base
                     and bar-code.node-code = rootnode_code
                     and bar-code.part-code = ""
                     and bar-code.in-code = ""
              .
              find first gds-dtl no-lock
                 where gds-dtl.doc-code = doc-line.doc-code
                   and gds-dtl.prod-type = doc-line.prod-type
                   and gds-dtl.prod-code = doc-line.prod-code
                   and gds-dtl.artic = doc-line.artic
                   and gds-dtl.prt-code = rootnode_code
              .
              assign
                  tqnty = gds-dtl.fact-qnty
                  unit-str = goods.unit-base
                  SumNoNDS = PriceNoNDS * tqnty
                  SumNDS = PricendS * tqnty
                  SumwithNDS = PricewithNDS * tqnty
              .
              if p-print-gold = yes
              then do:
                  if costprice = yes
                  then do:
                      display stream Out-stream
                          goods.artic
                          temp_gds-name.gds-name
                          goods.sort
                          string( bar-code.b-code ) @ tb-code
                          unit-str @ goods.unit-base
                          tqnty
                          qnty-pl when v-not-gold = no
                          PriceNoNDS
                          PricendS
                          PricewithNDS
                          SumNoNDS
                          SumNDS
                          SumwithNDS
                          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                          sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                          with frame f-doc-cost-gold .
                      down stream Out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info59 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                      run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name
                        , input string( goods.gds-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( tqnty )
                        , input if no-vat then string( PriceNoNDS )
                                          else string( PriceWithNDS )
                        , input if no-vat then string(SumNoNDS)
                                          else string(SumwithNDS)
                      ).
                  end.
                  else do:
                      display stream Out-stream
                          goods.artic
                          temp_gds-name.gds-name
                          goods.sort
                          string( bar-code.b-code ) @ tb-code
                          unit-str @ goods.unit-base
                          tqnty
                          qnty-pl when v-not-gold = no
                          PriceNoNDS
                          PricendS
                          PricewithNDS
                          SumNoNDS
                          SumNDS
                          SumwithNDS
                          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                          sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                          with frame f-doc-doc-gold .
                      down stream Out-stream 1 with frame f-doc-doc-gold .
define variable vss-include-info60 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
                      run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name
                        , input string( goods.gds-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( tqnty )
                        , input string( PriceWithNDS )
                        , input string(SumwithNDS)
                      ).
                  end.
              end.
              else do:
                  if costprice = yes
                  then do:
                      display stream Out-stream
                          goods.artic
                          temp_gds-name.gds-name
                          string( bar-code.b-code ) @ tb-code
                          unit-str @ goods.unit-base
                          tqnty
                          PriceNoNDS
                          PricendS
                          PricewithNDS
                          SumNoNDS
                          SumNDS
                          SumwithNDS
                          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                          sym11 sym12 sym13 sym14 sym15 sym16 sym17
                          with frame f-doc-cost .
                      down stream Out-stream 1 with frame f-doc-cost .
define variable vss-include-info61 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
                      run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name
                        , input string( goods.gds-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( tqnty )
                        , input if no-vat then string( PriceNoNDS )
                                          else string( PriceWithNDS )
                        , input if no-vat then string(SumNoNDS)
                                          else string(SumwithNDS)
                      ).
                  end.
                  else do:
                      display stream Out-stream
                          goods.artic
                          temp_gds-name.gds-name
                          string( bar-code.b-code ) @ tb-code
                          unit-str @ goods.unit-base
                          tqnty
                          PriceNoNDS
                          PricendS
                          PricewithNDS
                          SumNoNDS
                          SumNDS
                          SumwithNDS
                          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                          sym11 sym12 sym13 sym14 sym15 sym16 sym17
                          with frame f-doc-doc .
                      down stream Out-stream 1 with frame f-doc-doc .
define variable vss-include-info62 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty +  tqnty
                Pg-SumNoNDS = Pg-SumNoNDS +  SumNoNDS
                Pg-SumNDS = Pg-SumNDS +  SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS +  SumWithNDS
            .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
              run torg13xl-write-line-data in this-procedure (
                    input goods.artic + " ":U + goods.gds-name
                  , input string( goods.gds-code )
                  , input goods.unit-base
                  , input "":U
                  , input "":U
                  , input "":U
                  , input string( tqnty )
                        , input string( PriceWithNDS )
                  , input string( SumwithNDS )
              ).
                  end.
              end.
            end .
            assign
                v-line-counter = v-line-counter + 1
            .
            LineCounter = LineCounter + 1 .
            if p-break-name = yes
            then do:
                run display-gds-name in this-procedure .
            end.
    end.
    assign
        sum-tqnty       =   sum-tqnty       + tqnty
        sum-SumNoNDS    =   sum-SumNoNDS    + SumNoNDS
        sum-SumNDS      =   sum-SumNDS      + SumNDS
        sum-SumwithNDS  =   sum-SumwithNDS  + SumwithNDS
    .
end.
end procedure.
procedure print-group-line :
do
on error undo, return error
:
  put stream out-stream
      skip
      ":" space(5)
      "Группа  " space(2)
      goods.grp-name format "X(100)"
  .
end.
end procedure.
procedure print-prod-line :
do
on error undo, return error
:
  put stream out-stream
      skip
      ":" space(5)
      "Производитель  " space(2)
      string(clients.obj-code) + chr(32) + clients.obj-name format "X(100)"
  .
end.
end procedure.
procedure display-gds-name :
do
on error undo, return error
:
    for each temp_gds-name
    break by temp_gds-name.string-num
    :
        if not first(temp_gds-name.string-num)
        then do:
            if p-print-gold = yes
            then do:
                if costprice = yes
                then do:
                    display stream out-stream
                            temp_gds-name.gds-name
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-cost-gold .
                    down stream out-stream 1 with frame f-doc-cost-gold .
define variable vss-include-info63 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost-gold .
                down stream out-stream 1
                with frame  f-doc-cost-gold .
        end.
                end.
                else do:
                    display stream out-stream
                            temp_gds-name.gds-name
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-doc-gold .
                    down stream out-stream 1 with frame f-doc-doc-gold .
define variable vss-include-info64 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc-gold .
                down stream out-stream 1
                with frame f-doc-doc-gold .
        end.
                end.
            end.
            else do:
                if costprice = yes
                then do:
                    display stream out-stream
                            temp_gds-name.gds-name
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-cost .
                    down stream out-stream 1 with frame f-doc-cost .
define variable vss-include-info65 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame  f-doc-cost .
                down stream out-stream 1
                with frame  f-doc-cost .
        end.
                end.
                else do:
                    display stream out-stream
                            temp_gds-name.gds-name
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-doc .
                    down stream out-stream 1 with frame f-doc-doc .
define variable vss-include-info66 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
        do:
            put stream out-stream
                Line format "X(197)"
                skip
            .
                display stream out-stream
                    "Итого" @ temp_gds-name.gds-name
                    Pg-tqnty @ tqnty
                    Pg-SumNoNDS @ SumNoNDS
                    Pg-SumNDS @ SumNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame f-doc-doc .
                down stream out-stream 1
                with frame f-doc-doc .
        end.
                end.
            end.
            assign
                LineCounter = LineCounter + 1
            .
        end.
    end.
end.
end procedure.
procedure get-cli-qnty :
do
on error undo, return error
:
define input parameter p-doc-line-recid    as recid                no-undo.
define output parameter p-cli-qnty         like doc-line.cli-qnty  no-undo.
    define buffer buf_gold_parts       for parts.
    define buffer buf_gold_doc-line    for doc-line.
    find first buf_gold_doc-line no-lock
         where recid(buf_gold_doc-line) = p-doc-line-recid
    .
    assign
        p-cli-qnty = 0
    .
    for each buf_gold_parts no-lock
       where buf_gold_parts.obj-type     = buf_gold_doc-line.obj-type
         and buf_gold_parts.obj-code     = buf_gold_doc-line.obj-code
         and buf_gold_parts.artic        = buf_gold_doc-line.artic
         and buf_gold_parts.prod-type    = buf_gold_doc-line.prod-type
         and buf_gold_parts.prod-code    = buf_gold_doc-line.prod-code
         and buf_gold_parts.out-code     = buf_gold_doc-line.doc-code
    :
        if buf_gold_parts.fact-qnty <> 0
        then do:
            assign
                p-cli-qnty = p-cli-qnty + buf_gold_parts.cli-qnty
            .
        end.
    end.
end.
end procedure.
