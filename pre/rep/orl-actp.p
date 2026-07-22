block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-rec_id      as recid         no-undo.
define variable vss-revision    as character no-undo initial "$Revision: 099a383cf864, 290, rls $":U.
define variable vss-author      as character no-undo initial "$Author: PGridchina $":U.
define variable vss-date        as character no-undo initial "$Date: Tue Dec 01 19:11:24 2015 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: orl-actp.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/orl-actp.p $":U.
define variable vss-description as character no-undo initial "Акт приемки-передачи нефтепродуктов":U.
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
initial "@(#)$Workfile$".
procedure r-c-sale :
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
define input parameter p-doc-code           like doc-line.doc-code          no-undo .
define input parameter p-artic              like doc-line.artic             no-undo .
define input parameter p-prod-type          like doc-line.prod-type         no-undo .
define input parameter p-prod-code          like doc-line.prod-code         no-undo .
define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
define output parameter p-sum-r-b           like ub.ot-line.sum-base        no-undo .
def var v-gds-dtl-fact-qnty                 as decimal                      no-undo .
define buffer buf_gds-dtl  for ub.gds-dtl.
define buffer buf_goods    for ub.goods.
define buffer buf_trn-doc  for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
find first buf_doc-line no-lock
     where buf_doc-line.doc-code  = p-doc-code
       and buf_doc-line.artic     = p-artic
       and buf_doc-line.prod-type = p-prod-type
       and buf_doc-line.prod-code = p-prod-code
no-error .
if not available buf_doc-line then do:
    message "r-c-sale: Ошибка передачи параметров строки документа"
    view-as alert-box.
    undo, return error .
end.
find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
no-error .
if not available buf_trn-doc then do:
    message "r-c-sale: Нет trn-doc для строки документа " string(buf_doc-line.doc-code)
    view-as alert-box.
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
        ASSIGN
            p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
            p-sum-r-b             = p-sum-r-b       + buf_gds-dtl.cur-base  * v-gds-dtl-fact-qnty
        .
    end.
end.
assign
    p-vat-pc              = buf_doc-line.vat-pc
    p-slt-pc              = buf_doc-line.slt-pc
.
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
    if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
      function invlnsum_cli-qnty returns decimal ( input p-doc-code  as character,
                                                       input p-artic     as character,
                                                       input p-prod-type as character,
                                                       input p-prod-code as integer     ) :
        define variable d_out-qnty-kg as decimal no-undo initial ?.
                if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnqty in g#lib-trn3 (
                                                 input p-doc-code
                                              ,  input p-artic
                                              ,  input p-prod-type
                                              ,  input p-prod-code
                                              ,  input no
                                              , output d_out-qnty-kg
        ) .
          return ( if error-status :error then ? else d_out-qnty-kg ).
        end.
      end function.
FUNCTION RedLine RETURNS CHARACTER ( INPUT i-str AS CHARACTER ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.
  RUN get-red-line IN THIS-PROCEDURE ( INPUT i-str, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-str ELSE v-str ).
END FUNCTION.
PROCEDURE get-red-line :
  DEFINE  INPUT PARAMETER p-str AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-res = CAPS( SUBSTRING( p-str, 1, 1 ) ) + LC( SUBSTRING( p-str, 2 ) ).
  END.
END PROCEDURE.
FUNCTION Roubles RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Rouble AS CHARACTER NO-UNDO.
  RUN get-roubles IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Rouble ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Rouble ).
END FUNCTION.
PROCEDURE get-roubles :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rub AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
           jj     = LENGTH( Word )
           j_last = INTEGER( SUBSTRING( Word, jj - 3, 1 ) )
           l_prev =        ( SUBSTRING( Word, jj - 4, 1 ) = "1" ).
    IF      j_last = 1                THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубль" ).  END.
    ELSE IF j_last > 1 AND j_last < 5 THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубля" ). END.
                                      ELSE DO: ASSIGN p-rub = "рублей". END.
  END.
END PROCEDURE.
FUNCTION Copecks RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Copeck AS CHARACTER NO-UNDO.
  RUN get-copecks IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Copeck ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Copeck ).
END FUNCTION.
PROCEDURE get-copecks :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-kop AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN  Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
            jj     = LENGTH( Word )
            j_last = INTEGER( SUBSTRING( Word, jj,     1 ) )
            l_prev =        ( SUBSTRING( Word, jj - 1, 1 ) = "1" ).
    IF           j_last = 1                THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейка" ).
    END. ELSE IF j_last > 1 AND j_last < 5 THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейки" ).
    END.                                   ELSE DO:
      ASSIGN p-kop = "копеек".
    END.
  END.
END PROCEDURE.
FUNCTION get-decade-word RETURNS CHARACTER ( INPUT i-dec AS INTEGER, INPUT i-num AS INTEGER ) :
  DEFINE VARIABLE v-grade AS CHARACTER NO-UNDO.
  RUN get-number-grade IN THIS-PROCEDURE ( INPUT i-dec, INPUT i-num, OUTPUT v-grade ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-grade ).
END FUNCTION.
FUNCTION Word-Sum RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE OutSum AS CHARACTER NO-UNDO.
  RUN conv-sum-to-word IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT OutSum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE OutSum ).
END FUNCTION.
PROCEDURE get-number-grade :
  DEFINE  INPUT PARAMETER p-dec AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF      p-dec = 1 THEN DO: ASSIGN v-list = ",один,два,три,четыре,пять,шесть,семь,восемь,девять".    END.
    ELSE IF p-dec = 2 THEN DO: ASSIGN v-list = "десять,одиннадцать,двенадцать,тринадцать,четырнадцать,пятнадцать,шестнадцать,семнадцать,восемнадцать,девятнадцать".    END.
    ELSE IF p-dec = 3 THEN DO: ASSIGN v-list = ",,двадцать,тридцать,сорок,пятьдесят,шестьдесят,семьдесят,восемьдесят,девяносто".   END.
    ELSE IF p-dec = 4 THEN DO: ASSIGN v-list = ",сто,двести,триста,четыреста,пятьсот,шестьсот,семьсот,восемьсот,девятьсот".  END.
                      ELSE DO: ASSIGN v-list = ",,,,,,,,,". END.
    ASSIGN p-res = ENTRY( p-num + 1, v-list ).
  END.
END PROCEDURE.
PROCEDURE conv-sum-to-word :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Formatted  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE OutSum     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Formatted = STRING( ABS( p-sum ), "999999999999999.99":U ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
      ASSIGN p-res = ?.
      UNDO, RETURN ERROR.
    END.
    DO jj = ( LENGTH( Formatted ) - 3 ) TO 3 BY -3 :
      IF SUBSTRING( Formatted, jj - 2, 3 ) = "000" THEN DO: NEXT. END.
      IF jj < 15 THEN DO:
        ASSIGN Word = ENTRY( jj, ",,триллион,,,миллиард,,,миллион,,,тысяч" ).
        IF SUBSTRING( Formatted, jj,     1 )  = "1" AND
           SUBSTRING( Formatted, jj - 1, 1 ) <> "1" AND jj = 12 THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
        IF SUBSTRING( Formatted, jj, 1 ) = "2" OR
           SUBSTRING( Formatted, jj, 1 ) = "3" OR
           SUBSTRING( Formatted, jj, 1 ) = "4" THEN DO:
          IF jj = 12 THEN DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "и". END.
          END.       ELSE DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
          END.
        END.
        IF ( SUBSTRING( Formatted, jj,     1 ) <> "1" AND
             SUBSTRING( Formatted, jj,     1 ) <> "2" AND
             SUBSTRING( Formatted, jj,     1 ) <> "3" AND
             SUBSTRING( Formatted, jj,     1 ) <> "4" AND jj <> 12 ) OR
           ( SUBSTRING( Formatted, jj - 1, 1 )  = "1" AND jj <  12 ) THEN DO: ASSIGN Word = TRIM( Word ) + "ов". END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      END.
      IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO:
        IF      jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "1" THEN DO: ASSIGN Word = "одна". END.
        ELSE IF jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "2" THEN DO: ASSIGN Word = "две".  END.
        ELSE DO: ASSIGN Word = get-decade-word( 1, INTEGER( SUBSTRING( Formatted, jj, 1 ) ) ). END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
        ASSIGN Word = get-decade-word( 3, INTEGER( SUBSTRING( Formatted, jj - 1, 1 ) ) ).
      END.                                        ELSE DO:
        ASSIGN Word = get-decade-word( 2, INTEGER( SUBSTRING( Formatted, jj,     1 ) ) ).
      END.
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      ASSIGN Word = get-decade-word( 4, INTEGER( SUBSTRING( Formatted, jj - 2, 1 ) ) ).
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
    END.
    ASSIGN OutSum = CAPS( SUBSTRING( OutSum, 1, 1 ) ) + SUBSTRING( OutSum, 2 ).
    IF OutSum = "":U AND TRUNCATE( p-sum, 0 ) = 0 THEN DO: ASSIGN OutSum = "Ноль". END.
    ASSIGN p-res = TRIM( OutSum ).
  END.
END PROCEDURE.
FUNCTION Total-Word RETURNS CHARACTER ( INPUT i-sum AS DECIMAL, INPUT i-curr AS CHARACTER, INPUT i-part AS CHARACTER ) :
  DEFINE VARIABLE word_sum AS CHARACTER NO-UNDO.
  RUN get-total-word IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-curr, INPUT i-part, OUTPUT word_sum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE word_sum ).
END FUNCTION.
PROCEDURE get-total-word :
  DEFINE  INPUT PARAMETER p-sum  AS DECIMAL   NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-part AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-word AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-word = Word-Sum( p-sum ).
               ASSIGN p-word = ( IF p-sum < 0 THEN "- " ELSE "":U ) + TRIM(
                      RedLine( p-word )
               ) +
                      " ":U + p-curr + " ":U +
                      SUBSTRING( STRING( ABS( p-sum ), "999999999999999999999999999999.99" ), 32, 2 ) +
                      " ":U + p-part + ".".
                        END.
END PROCEDURE.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
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
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define variable g#quest-print as logical   no-undo.
define variable g#log         as logical   no-undo.
define variable base-part     as character no-undo.
define buffer buf_rep_currency for ub.currency.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
find first buf_rep_currency no-lock where
           buf_rep_currency.curr-code = base-code
           no-error .
  if available buf_rep_currency
    then do:
      assign
        base-type = buf_rep_currency.curr-abbr
        base-part = buf_rep_currency.part-abbr
      .
    end.
    else do:
      assign
        base-type = "б.в."
        base-part = ""
      .
    end.
run get-report-num  in parparentproc ( output g#report-num ).
run get-quest-print in parparentproc ( output g#quest-print ) .
define variable v-operator          as   character                          no-undo.
define variable v-expl-name         as   character                          no-undo.
define variable v-store-man         as   character                          no-undo.
define variable v-main-boss         as   character                          no-undo.
define variable v-main-buh          as   character                          no-undo.
define variable temp-string         as   character                          no-undo.
define variable v-sum-string        as   character                          no-undo.
define variable temp-position       as   integer                            no-undo.
define variable single-line         as   character                          no-undo.
define variable v-is-petrol         as   logical                            no-undo initial no.
define variable v-is-pieces         as   logical                            no-undo initial no.
define variable v-have-petrol       as   logical                            no-undo initial no.
define variable v-have-rvs-before   as   logical                            no-undo initial no.
define variable v-have-rvs-after    as   logical                            no-undo initial no.
define variable v-ship-org          like ub.doc-line-attr.attr-value        no-undo.
define variable v-autoent-obj-code  like ub.doc-line-attr.attr-value        no-undo.
define variable v-autoent-obj-type  like ub.doc-line-attr.attr-value        no-undo.
define variable v-dids              like ub.doc-line-attr.attr-value        no-undo.
define variable v-nids              like ub.doc-line-attr.attr-value        no-undo.
define variable v-attr-type         as   character                          no-undo.
define variable v-car-num           like ub.doc-line-attr.attr-value        no-undo.
define variable v-car-vol           like ub.doc-line-attr.attr-value        no-undo.
define variable v-item-pour         like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-density      like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-temp         like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-vol          like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-water        like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-weight       like ub.doc-line-attr.attr-value        no-undo.
define variable v-time-pour         like ub.doc-line-attr.attr-value        no-undo.
define variable v-time-income       like ub.doc-line-attr.attr-value        no-undo.
define variable v-type-inp-vat      like ub.doc-line-attr.attr-value        no-undo.
define variable v-delta-mass        as   decimal                            no-undo.
define variable v-delta-volume      as   decimal                            no-undo.
define variable v-tank-vol-dec      like ub.rvs-line.state-measure-qnty     no-undo.
define variable v-tank-temp-dec     like ub.rvs-line.state-temperature      no-undo.
define variable v-tank-density-dec  like ub.rvs-line.state-density          no-undo.
define variable v-tank-weight-dec   like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable v-tank-water-dec    like ub.rvs-line.state-measure-qnty     no-undo.
define variable v-fact-qnty         as   decimal                            no-undo.
define variable v-fact-qnty-kg      as   decimal                            no-undo.
define variable v-price             as   decimal                            no-undo.
define variable v-price-kg          as   decimal                            no-undo.
define variable v-sum-price         as   decimal                            no-undo.
define variable v-VAT-pc            as   decimal                            no-undo.
define variable v-SLT-pc            as   decimal                            no-undo.
define variable v-host-code         as   integer                            no-undo.
define variable v-fio               like ub.doc-line-attr.attr-value        no-undo.
define variable before_qnty         like ub.rvs-line.state-measure-qnty     no-undo.
define variable before_temperature  like ub.rvs-line.state-temperature      no-undo.
define variable before_density      like ub.rvs-line.state-density          no-undo.
define variable before_cli-qnty     like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable after_qnty          like ub.rvs-line.state-measure-qnty     no-undo.
define variable after_temperature   like ub.rvs-line.state-temperature      no-undo.
define variable after_density       like ub.rvs-line.state-density          no-undo.
define variable after_cli-qnty      like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable doc-line_1st-run    as   logical                            no-undo .
define buffer buf_trn-doc         for ub.trn-doc.
define buffer buf_doc-line        for ub.doc-line.
define buffer bf_inv-line         for ub.inv-line.
define buffer buf_goods           for ub.goods.
define buffer buf_clients         for ub.clients.
define buffer buf_clients_ship    for ub.clients.
define buffer buf_doc-line-attr   for ub.doc-line-attr.
define buffer buf_doc-attr        for ub.doc-attr.
define buffer buf_rvs-doc_before  for ub.rvs-doc.
define buffer buf_rvs-doc_after   for ub.rvs-doc.
define buffer buf_rvs-line_before for ub.rvs-line.
define buffer buf_rvs-line_after  for ub.rvs-line.
define buffer buf_host_clients    for ub.clients.
define buffer buf_obj_clients     for ub.clients.
define buffer buf_shop            for ub.shop.
define buffer buf_store           for ub.store.
define buffer buf_firm            for ub.firm.
define buffer buf_sysconf         for ub.sysconf.
define stream out-stream.
do on error undo, return error :
  if session :set-wait-state( "COMPILER":U ) then do: end.
  assign single-line = fill( "-", 119 ).
  find first buf_trn-doc      no-lock where recid( buf_trn-doc ) = p-rec_id.
  find first buf_host_clients no-lock where
             buf_host_clients.obj-type = 'орг':U and
             buf_host_clients.obj-code = buf_trn-doc.host-code.
  find first buf_firm         no-lock where buf_firm.firm-code = buf_host_clients.obj-code.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
  find first buf_sysconf      no-lock where buf_sysconf.host-code = v-host-code.
  assign v-main-boss = buf_firm.director
         v-main-buh  = buf_sysconf.snr-accnt.
  find first buf_obj_clients  no-lock where
             buf_obj_clients.obj-type = buf_trn-doc.obj-type and
             buf_obj_clients.obj-code = buf_trn-doc.obj-code no-error.
  case buf_obj_clients.obj-type :
    when 'маг':U  then do:
      find first buf_shop     no-lock where buf_shop.obj-code  = buf_obj_clients.obj-code.
      assign v-expl-name = buf_shop.director
             v-store-man = buf_shop.store-man.
    end.
    when 'скл':U then do:
      find first buf_store    no-lock where buf_store.obj-code = buf_obj_clients.obj-code.
        assign v-expl-name = buf_store.store-boss
               v-store-man = buf_store.store-man.
    end.
  end case.
  find first buf_clients      no-lock where
             buf_clients.obj-type = 'чел':U           and
             buf_clients.obj-code = buf_trn-doc.wrkr no-error.
  assign v-operator = ( if available buf_clients then buf_clients.obj-name else "":U ).
  find first buf_clients      no-lock where
             buf_clients.obj-type = buf_trn-doc.obj-type and
             buf_clients.obj-code = buf_trn-doc.obj-code.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'dids':U ,
                       output v-dids ,
                       output v-attr-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'nids':U ,
                       output v-nids ,
                       output v-attr-type )  .
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
  for each buf_doc-line no-lock where
           buf_doc-line.doc-code = buf_trn-doc.doc-code :
    find first bf_inv-line no-lock where
               bf_inv-line.doc-code  = buf_doc-line.doc-code  and
               bf_inv-line.artic     = buf_doc-line.artic     and
               bf_inv-line.prod-type = buf_doc-line.prod-type and
               bf_inv-line.prod-code = buf_doc-line.prod-code no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) no-error.
    if v-is-petrol <> yes then do: next. end.
    assign v-have-petrol = yes.
  assign v-autoent-obj-code = "":U
         v-autoent-obj-type = "":U
         v-car-num          = "":U
         v-car-vol          = "":U
         v-item-pour        = "":U
         v-tank-density     = "":U
         v-tank-temp        = "":U
         v-tank-vol         = "":U
         v-tank-water       = "":U
         v-tank-weight      = "":U
         v-time-pour        = "":U
         v-time-income      = "":U
         v-type-inp-vat     = "":U
         v-fio              = "":U.
    find first buf_goods no-lock where
               buf_goods.artic     = buf_doc-line.artic     and
               buf_goods.prod-type = buf_doc-line.prod-type and
               buf_goods.prod-code = buf_doc-line.prod-code.
    for each buf_doc-line-attr no-lock where
             buf_doc-line-attr.doc-code = buf_trn-doc.doc-code and
             buf_doc-line-attr.gds-code = buf_goods.gds-code   :
      case buf_doc-line-attr.attr-code :
  when "car-vol" then do: assign v-car-vol = trim( buf_doc-line-attr.attr-value ). end.
  when "tank-density" then do: assign v-tank-density = trim( buf_doc-line-attr.attr-value ). end.
  when "tank-temp" then do: assign v-tank-temp = trim( buf_doc-line-attr.attr-value ). end.
  when "tank-vol" then do: assign v-tank-vol = trim( buf_doc-line-attr.attr-value ). end.
  when "tank-water" then do: assign v-tank-water = trim( buf_doc-line-attr.attr-value ). end.
  when "tank-weight" then do: assign v-tank-weight = trim( buf_doc-line-attr.attr-value ). end.
  when "time-pour" then do: assign v-time-pour = trim( buf_doc-line-attr.attr-value ). end.
  when "type-inp-vat" then do: assign v-type-inp-vat = trim( buf_doc-line-attr.attr-value ). end.
      end case.
    end.
    for each buf_doc-attr no-lock where
             buf_doc-attr.doc-code = buf_trn-doc.doc-code:
      case buf_doc-attr.attr-code :
            when 'autoent':U then do:
              assign
                v-autoent-obj-type = entry (1, buf_doc-attr.attr-value, ";")
                v-autoent-obj-code = entry (2, buf_doc-attr.attr-value, ";")
              no-error.
            end.
            when 'car-num':U then do: assign v-car-num = trim( buf_doc-attr.attr-value ). end.
            when 'time-income':U then do: assign v-time-income = trim( buf_doc-attr.attr-value ). end.
            when 'ptb-item-pour':U then do: assign v-item-pour = trim( buf_doc-attr.attr-value ). end.
      end case.
    end.
  assign v-tank-vol-dec = decimal( v-tank-vol ) no-error.
  if error-status :error then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            'Ошибка преобразования параметра "tank-vol" в число.'
    view-as alert-box error.
  end.
  assign v-tank-temp-dec = decimal( v-tank-temp ) no-error.
  if error-status :error then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            'Ошибка преобразования параметра "tank-temp" в число.'
    view-as alert-box error.
  end.
  assign v-tank-density-dec = decimal( v-tank-density ) no-error.
  if error-status :error then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            'Ошибка преобразования параметра "tank-density" в число.'
    view-as alert-box error.
  end.
  assign v-tank-weight-dec = decimal( v-tank-weight ) no-error.
  if error-status :error then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            'Ошибка преобразования параметра "tank-weight" в число.'
    view-as alert-box error.
  end.
  assign v-tank-water-dec = decimal( v-tank-water ) no-error.
  if error-status :error then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            'Ошибка преобразования параметра "tank-water" в число.'
    view-as alert-box error.
  end.
    find first buf_clients_ship no-lock where
               buf_clients_ship.obj-type =          v-autoent-obj-type   and
               buf_clients_ship.obj-code = integer( v-autoent-obj-code ) no-error.
    assign v-ship-org = ( if available buf_clients then buf_clients.obj-name else "":U ).
    run r-c-sale in this-procedure (  input buf_doc-line.doc-code
                                   ,  input buf_doc-line.artic
                                   ,  input buf_doc-line.prod-type
                                   ,  input buf_doc-line.prod-code
                                   , output v-fact-qnty
                                   , output v-VAT-pc
                                   , output v-SLT-pc
                                   , output v-sum-price            ).
    assign v-price        = ( if v-fact-qnty = 0 then 0 else v-sum-price / v-fact-qnty    )
           v-fact-qnty-kg =
    invlnsum_cli-qnty (
                   buf_doc-line.doc-code
                 , buf_doc-line.artic
                 , buf_doc-line.prod-type
                 , buf_doc-line.prod-code
                 )
           v-price-kg     = ( if v-fact-qnty = 0 then 0 else v-sum-price / v-fact-qnty-kg ).
    put stream out-stream unformatted
        skip( 1 ) "А К Т"                     at center-field( 14, 130, 5 ) format "x(5)":U skip
        "приемки-передачи нефтепродуктов " + caps( trim( buf_host_clients.obj-name ) )
                                              at center-field( 14, 130, 32 + length( trim( buf_host_clients.obj-name ) ) )
        skip "предпринимателю " + v-expl-name at center-field( 14, 130, 16 + length( v-expl-name ) ).
    if buf_trn-doc.fact-date <> ? then do:
      assign temp-string = '" '  + string( day(   buf_trn-doc.fact-date ) )
                         + ' " ' + entry(  month( buf_trn-doc.fact-date ), 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U )
                         + " "   + string( year(  buf_trn-doc.fact-date ), "9999" ) + " г.".
      assign temp-position = center-field( 14, 130, length( temp-string ) )
             temp-string   = fill( " ":U, temp-position ) + temp-string.
    end.
    else do:
      assign temp-string = "":U.
    end.
    put stream out-stream
        skip
        temp-string                             format "x(130)":U
        skip( 2 ) space( 14 )
        "ТТН N " string( buf_trn-doc.doc-code ) + " от " + string( buf_trn-doc.doc-date )
                                                format "x(76)":U at 54
        skip      space( 14 )
        "Основание: накладная поставщика" string( "N " + v-nids + " от " + v-dids )
                                                format "x(76)":U at 54
        skip      space( 14 )
        "Гос.N автоцистерны "         v-car-num format "x(76)":U at 54
        skip      space( 14 )
        "Объем по паспорту в литрах " v-car-vol format "x(76)":U at 54
        skip      space( 14 )
        "Поставщик " buf_trn-doc.cli-name       format "x(76)":U at 54
        skip      space( 14 )
        ( if not ( buf_trn-doc.PS begins "@" ) then buf_trn-doc.PS else "":U )
                                                format "x(76)":U
        skip      space( 14 )
        "Нефтепродукт " buf_goods.gds-name      format "x(76)":U at 54.
    put stream out-stream
      skip( 2 ) single-line       format "x(119)":U at 15
      skip      ":"               format "x(1)":U            at 15
                ":"               format "x(1)":U            at 15 + 25
                "Нефтепродукт"    format "x(12)":U           at center-field( 15 + 25, 15 + 84, 12 )
                ":"               format "x(1)":U            at 15 + 84
                ":"               format "x(1)":U            at 15 + 99
                ":"               format "x(1)":U            at 15 + 118
      skip      ":"               format "x(1)":U            at 15
                ":"               format "x(1)":U            at 15 + 25
                single-line       format "x(58)":U
                ":"               format "x(1)":U            at 15 + 84
                "Цена"                                       at center-field( 15 + 84, 15 + 99, 4 )
                ":"               format "x(1)":U            at 15 + 99
                "Сумма"                                      at center-field( 15 + 99, 15 + 118, 5 )
                ":"               format "x(1)":U            at 15 + 118
      skip      ":"               format "x(1)":U            at 15
                ":"               format "x(1)":U            at 15 + 25
                "Объем,"          format "x(6)":U            at center-field( 15 + 25, 15 + 41,  6 )
                ":"               format "x(1)":U            at 15 + 41
                "t,"              format "x(2)":U            at center-field( 15 + 41, 15 + 52,  2 )
                ":"               format "x(1)":U            at 15 + 52
                "Плотность,"      format "x(10)":U           at center-field( 15 + 52, 15 + 68, 10 )
                ":"               format "x(1)":U            at 15 + 68
                "Масса,"          format "x(6)":U            at center-field( 15 + 68, 15 + 84,  6 )
                ":"               format "x(1)":U            at 15 + 84
                "по объекту"      format "x(10)":U           at center-field( 15 + 84, 15 + 99, 10 )
                ":"               format "x(1)":U            at 15 + 99
                "по объекту"      format "x(10)":U           at center-field( 15 + 99, 15 + 118, 10 )
                ":"               format "x(1)":U            at 15 + 118
      skip      ":"               format "x(1)":U            at 15
                ":"               format "x(1)":U            at 15 + 25
                "л"               format "x(1)":U            at center-field( 15 + 25, 15 + 41, 1 )
                ":"               format "x(1)":U            at 15 + 41
                "град.C"          format "x(6)":U            at center-field( 15 + 41, 15 + 52, 6 )
                ":"               format "x(1)":U            at 15 + 52
                "г/см.куб"        format "x(8)":U            at center-field( 15 + 52, 15 + 68, 8 )
                ":"               format "x(1)":U            at 15 + 68
                "кг"              format "x(2)":U            at center-field( 15 + 68, 15 + 84, 2 )
                ":"               format "x(1)":U            at 15 + 84
                "за л"            format "x(4)":U            at center-field( 15 + 84, 15 + 99, 4 )
                ":"               format "x(1)":U            at 15 + 99
                "(руб)":U format "x(5)":U            at center-field( 15 + 99, 15 + 118, 5 )
                ":"               format "x(1)":U            at 15 + 118
      skip      ":"               format "x(1)":U            at 15
                single-line       format "x(117)":U
                ":"               format "x(1)":U.
    put stream out-stream
      skip ":"                                       format "x(1)":U             at 15
           "По ТТН"                                  format "x(6)":U             at 15 + 2
           ":"                                       format "x(1)":U             at 15 + 25
        buf_doc-line.doc-qnty                        format "zz,zz9.999":U       at right-field( 15 + 41 - 1, 10 )
           ":"                                       format "x(1)":U             at 15 + 41
        buf_doc-line.temperature                     format "->>9.99":U          at right-field( 15 + 52 - 1,  7 )
           ":"                                       format "x(1)":U             at 15 + 52
        buf_doc-line.doc-density                     format "9.9999999999":U     at right-field( 15 + 68 - 1, 12 )
           ":"                                       format "x(1)":U             at 15 + 68
        buf_doc-line.cli-qnty                        format "zz,zzz,zz9.999":U   at right-field( 15 + 84, 14 )
           ":"                                       format "x(1)":U             at 15 + 84
           v-price                                   format "z,zzz,zz9.99":U     at right-field( 15 + 99, 12 )
           ":"                                       format "x(1)":U             at 15 + 99
           v-sum-price                               format "z,zzz,zzz,zz9.99":U at right-field( 15 + 118, 16 )
           ":"                                       format "x(1)":U             at 15 + 118
      skip ":"                                       format "x(1)":U             at 15
           single-line                               format "x(117)":U
           ":"                                       format "x(1)":U
      skip ":"                                       format "x(1)":U             at 15
           single-line                               format "x(117)":U
           ":"                                       format "x(1)":U
      skip ":"                                       format "x(1)":U             at 15
           "По замеру в"                             format "x(11)":U            at 15 + 2
           ":"                                       format "x(1)":U             at 15 + 25
           ":"                                       format "x(1)":U             at 15 + 41
           ":"                                       format "x(1)":U             at 15 + 52
           ":"                                       format "x(1)":U             at 15 + 68
           ":"                                       format "x(1)":U             at 15 + 84
           ":"                                       format "x(1)":U             at 15 + 99
           ":"                                       format "x(1)":U             at 15 + 118
      skip ":"                                       format "x(1)":U             at 15
           "автоцистерне"                            format "x(12)":U            at 15 + 2
           ":"                                       format "x(1)":U             at 15 + 25.
    if v-tank-vol-dec     <> ? then do:
      put stream out-stream v-tank-vol-dec     format "zz,zz9.999":U     at right-field( 15 + 41 - 1, 10 ).
    end.
    put stream out-stream ":" format "x(1)":U at 15 + 41.
    if v-tank-temp-dec    <> ? then do:
      put stream out-stream v-tank-temp-dec    format "->>9.99":U        at right-field( 15 + 52 - 1,  7 ).
    end.
    put stream out-stream ":" format "x(1)":U at 15 + 52.
    if v-tank-density-dec <> ? then do:
      put stream out-stream v-tank-density-dec format "9.9999999999":U   at right-field( 15 + 68 - 1, 12 ).
    end.
    put stream out-stream ":" format "x(1)":U at 15 + 68.
    if v-tank-weight-dec  <> ? then do:
      put stream out-stream v-tank-weight-dec  format "zz,zzz,zz9.999":U at right-field( 15 + 84, 14 ).
    end.
    put stream out-stream
           ":"                      format "x(1)":U       at 15 + 84
           ":"                      format "x(1)":U       at 15 + 99
           ":"                      format "x(1)":U       at 15 + 118
      skip ":"                      format "x(1)":U       at 15
           single-line              format "x(117)":U
           ":"                      format "x(1)":U.
  find first buf_rvs-doc_before no-lock where
             buf_rvs-doc_before.out-code = buf_trn-doc.doc-code and
             buf_rvs-doc_before.rvs-type = 'перед_док':U       no-error.
  assign v-have-rvs-before = ( available buf_rvs-doc_before ).
  if available buf_rvs-doc_before then do:
    for each buf_rvs-line_before no-lock where
             buf_rvs-line_before.rvs-code = buf_rvs-doc_before.rvs-code and
             buf_rvs-line_before.obj-type = buf_trn-doc.obj-type     and
             buf_rvs-line_before.obj-code = buf_trn-doc.obj-code     and
             buf_rvs-line_before.gds-code = buf_goods.gds-code       :
      assign
        before_qnty        = before_qnty        + buf_rvs-line_before.state-measure-qnty
        before_temperature = before_temperature + buf_rvs-line_before.state-temperature
                                          * buf_rvs-line_before.state-measure-qnty
        before_cli-qnty    = before_cli-qnty    + buf_rvs-line_before.state-measure-cli-qnty
      .
    put stream out-stream
      skip ":"                      format "x(1)":U       at 15
           single-line              format "x(117)":U
           ":"                      format "x(1)":U
      skip ":"                      format "x(1)":U       at 15
           "По замеру в резервуаре" format "x(22)":U      at 15 + 2
           ":"                      format "x(1)":U       at 15 + 25
           ":"                      format "x(1)":U       at 15 + 41
           ":"                      format "x(1)":U       at 15 + 52
           ":"                      format "x(1)":U       at 15 + 68
           ":"                      format "x(1)":U       at 15 + 84
           ":"                      format "x(1)":U       at 15 + 99
           ":"                      format "x(1)":U       at 15 + 118
      skip ":"                      format "x(1)":U       at 15
           "ДО слива"               format "x(8)":U       at 15 + 2
           ":"                      format "x(1)":U       at 15 + 25.
  if v-have-rvs-before = yes then do:
      if buf_rvs-line_before.state-measure-qnty <> ? then do:
    put stream out-stream buf_rvs-line_before.state-measure-qnty format "zz,zz9.999":U at right-field( 15 + 41 - 1, 10 ).
      end.
  end.
  else do:
    put stream out-stream "0" format "x(1)":U at right-field( 15 + 41 - 1, 1 ).
  end.
  put stream out-stream ":" format "x(1)":U at 15 + 41.
  if v-have-rvs-before = yes then do:
      if buf_rvs-line_before.state-temperature <> ? then do:
    put stream out-stream buf_rvs-line_before.state-temperature format "->>9.99":U at right-field( 15 + 52 - 1, 7 ).
      end.
  end.
  else do:
    put stream out-stream "0" format "x(1)":U at right-field( 15 + 52 - 1, 1 ).
  end.
  put stream out-stream ":" format "x(1)":U at 15 + 52.
  if v-have-rvs-before = yes then do:
      if buf_rvs-line_before.state-density <> ? then do:
    put stream out-stream buf_rvs-line_before.state-density format "9.9999999999":U at right-field( 15 + 68 - 1, 12 ).
      end.
  end.
  else do:
    put stream out-stream "0" format "x(1)":U at right-field( 15 + 68 - 1, 1 ).
  end.
  put stream out-stream ":" format "x(1)":U at 15 + 68.
  if v-have-rvs-before = yes then do:
      if buf_rvs-line_before.state-measure-cli-qnty <> ? then do:
    put stream out-stream buf_rvs-line_before.state-measure-cli-qnty format "zz,zzz,zz9.999":U at right-field( 15 + 84 - 0, 14 ).
      end.
  end.
  else do:
    put stream out-stream "0" format "x(1)":U at right-field( 15 + 84 - 0, 1 ).
  end.
  put stream out-stream ":" format "x(1)":U at 15 + 84.
    put stream out-stream
           ":"                   format "x(1)":U       at 15 + 99
           ":"                   format "x(1)":U       at 15 + 118
      skip ":"                   format "x(1)":U       at 15
           single-line           format "x(117)":U
           ":"                   format "x(1)":U.
    end.
  end.
  assign
    before_temperature = before_temperature / before_qnty
    before_density     = before_cli-qnty    / before_qnty
  .
  find first buf_rvs-doc_after no-lock where
             buf_rvs-doc_after.out-code = buf_trn-doc.doc-code and
             buf_rvs-doc_after.rvs-type = 'после_док':U       no-error.
  assign v-have-rvs-after = ( available buf_rvs-doc_after ).
  if available buf_rvs-doc_after then do:
    for each buf_rvs-line_after no-lock where
             buf_rvs-line_after.rvs-code = buf_rvs-doc_after.rvs-code and
             buf_rvs-line_after.obj-type = buf_trn-doc.obj-type     and
             buf_rvs-line_after.obj-code = buf_trn-doc.obj-code     and
             buf_rvs-line_after.gds-code = buf_goods.gds-code       :
      assign
        after_qnty        = after_qnty        + buf_rvs-line_after.state-measure-qnty
        after_temperature = after_temperature + buf_rvs-line_after.state-temperature
                                          * buf_rvs-line_after.state-measure-qnty
        after_cli-qnty    = after_cli-qnty    + buf_rvs-line_after.state-measure-cli-qnty
      .
    put stream out-stream
      skip ":"                   format "x(1)":U       at 15
        "По замеру в резервуаре" format "x(22)":U      at 15 + 2
           ":"                   format "x(1)":U       at 15 + 25
           ":"                   format "x(1)":U       at 15 + 41
           ":"                   format "x(1)":U       at 15 + 52
           ":"                   format "x(1)":U       at 15 + 68
           ":"                   format "x(1)":U       at 15 + 84
           ":"                   format "x(1)":U       at 15 + 99
           ":"                   format "x(1)":U       at 15 + 118
      skip ":"                   format "x(1)":U       at 15
           "ПОСЛЕ слива"         format "x(11)":U      at 15 + 2
           ":"                   format "x(1)":U       at 15 + 25.
  if v-have-rvs-after = yes then do:
      if buf_rvs-line_after.state-measure-qnty <> ? then do:
    put stream out-stream buf_rvs-line_after.state-measure-qnty format "zz,zz9.999":U at right-field( 15 + 41 - 1, 10 ).
      end.
  end.
  else do:
    put stream out-stream "0" format "x(1)":U at right-field( 15 + 41 - 1, 1 ).
  end.
  put stream out-stream ":" format "x(1)":U at 15 + 41.
  if v-have-rvs-after = yes then do:
      if buf_rvs-line_after.state-temperature <> ? then do:
    put stream out-stream buf_rvs-line_after.state-temperature format "->>9.99":U at right-field( 15 + 52 - 1, 7 ).
      end.
  end.
  else do:
    put stream out-stream "0" format "x(1)":U at right-field( 15 + 52 - 1, 1 ).
  end.
  put stream out-stream ":" format "x(1)":U at 15 + 52.
  if v-have-rvs-after = yes then do:
      if buf_rvs-line_after.state-density <> ? then do:
    put stream out-stream buf_rvs-line_after.state-density format "9.9999999999":U at right-field( 15 + 68 - 1, 12 ).
      end.
  end.
  else do:
    put stream out-stream "0" format "x(1)":U at right-field( 15 + 68 - 1, 1 ).
  end.
  put stream out-stream ":" format "x(1)":U at 15 + 68.
  if v-have-rvs-after = yes then do:
      if buf_rvs-line_after.state-measure-cli-qnty <> ? then do:
    put stream out-stream buf_rvs-line_after.state-measure-cli-qnty format "zz,zzz,zz9.999":U at right-field( 15 + 84 - 0, 14 ).
      end.
  end.
  else do:
    put stream out-stream "0" format "x(1)":U at right-field( 15 + 84 - 0, 1 ).
  end.
  put stream out-stream ":" format "x(1)":U at 15 + 84.
    put stream out-stream
           ":"         format "x(1)":U            at 15 + 99
           ":"         format "x(1)":U            at 15 + 118
      skip single-line format "x(119)":U at 15.
    end.
  end.
  assign
    after_temperature = after_temperature / after_qnty
    after_density     = after_cli-qnty    / after_qnty
  .
    put stream out-stream
      skip( 2 ) space( 14 ) "Объем принятого нефтепродукта "
      buf_doc-line.fact-qnty format "zzz,zzz,zz9.999":U at right-field( 90, 15 ) " литров"
      skip      space( 14 ) "Масса принятого нефтепродукта "
      ( if available bf_inv-line then bf_inv-line.wast-cli-qnty else ? )
                             format "zzz,zzz,zz9.999":U at right-field( 90, 15 ) " кг".
    assign v-sum-string = Total-Word( v-sum-price, Roubles( v-sum-price ), Copecks( v-sum-price ) )
           temp-string  = " руб.".
    put stream out-stream
      skip( 1 ) space( 14 ) "ИТОГО по акту передано на сумму     " +
      caps( ( if trim( v-sum-string ) begins trim( temp-string ) then string( "0 " + v-sum-string ) else v-sum-string ) )
                                                        format "x(126)":U.
    put stream out-stream
      skip( 1 ) space( 14 ) "От владельца : "
                                        "От агента : "    at 80
      v-store-man                     format "x(20)":U
      skip( 1 ) space( 14 ) "Руководитель предприятия:                                             / "
      string( v-main-boss  + " /" )   format "x(40)":U
      skip( 1 ) space( 14 ) "Главный бухгалтер:                                                    / "
      string( v-main-buh  + " /" )    format "x(40)":U.
    page stream out-stream.
  end.
  output stream out-stream close.
  if v-have-petrol = yes then do:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 4 >= 8 then 2 else 0), 0, 0,
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
end.
