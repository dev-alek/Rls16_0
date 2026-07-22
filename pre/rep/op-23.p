block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.
define input parameter p-print-in-rubl      as logical          no-undo.
define input parameter p-print-details      as logical          no-undo.
define input parameter p-fat                as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: f557e6fb7653, 115, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 23 19:15:09 2014 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-23.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/op-23.p $":U .
define variable vss-description as character no-undo init "Печатная форма ОП-23. Производство, акт о разделке мяса-сырья.".
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
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
    define stream out-stream .
    define variable v-doc-code             like trn-doc.doc-code       no-undo.
    define variable v-doc-date             like trn-doc.doc-date       no-undo.
    define variable v-fact-date            like trn-doc.fact-date      no-undo.
    define variable v-root-node-code      as integer                  no-undo.
    define variable v-line-counter        as integer                  no-undo.
    define variable s1                    as char                     no-undo.
    define variable s2                    as char                     no-undo.
    define variable v-organization        as char                     no-undo.
    define variable v-org-name            as char                     no-undo.
    define variable v-bar-code            as integer                  no-undo.
    define variable v-in-goods-artic      as char                     no-undo.
    define variable v-in-goods-name       as char                     no-undo.
    define variable v-in-bar-code         as integer                  no-undo.
    define variable v-in-unit-name        as char                     no-undo.
    define variable v-in-unit-OKEI        as char                     no-undo.
    define variable v-in-price            as decimal                  no-undo.
    define variable v-in-mass           as decimal                  no-undo.
    define variable v-in-sum              as decimal                  no-undo.
    define variable v-out-goods-artic     as char                     no-undo.
    define variable v-out-goods-name      as char                     no-undo.
    define variable v-out-bar-code        as integer                  no-undo.
    define variable v-out-norm-prc        as decimal                  no-undo.
    define variable v-out-norm-mass       as decimal                  no-undo.
    define variable v-out-norm-prc-emp    as char    init "         " no-undo.
    define variable v-out-norm-mass-emp   as char    init "         " no-undo.
    define variable v-out-sum-norm-mass   as decimal                  no-undo.
    define variable v-out-price           as decimal                  no-undo.
    define variable v-out-fact-mass       as decimal                  no-undo.
    define variable v-out-sum             as decimal                  no-undo.
    define variable v-deviation           as char    init ""          no-undo.
    define variable v-pg-in-mass          as decimal                  no-undo.
    define variable v-pg-in-sum           as decimal                  no-undo.
    define variable v-pg-out-norm-mass    as decimal                  no-undo.
    define variable v-pg-out-fact-mass    as decimal                  no-undo.
    define variable v-pg-out-fact-sum     as decimal                  no-undo.
    define variable v-sum-in-mass          as decimal                  no-undo.
    define variable v-sum-in-sum           as decimal                  no-undo.
    define variable v-sum-out-norm-mass    as decimal                  no-undo.
    define variable v-sum-out-fact-mass    as decimal                  no-undo.
    define variable v-sum-out-fact-sum     as decimal                  no-undo.
    define variable sym1  as char init "|" no-undo.
    define variable sym2  as char init ":" no-undo.
    define variable sym3  as char init ":" no-undo.
    define variable sym4  as char init ":" no-undo.
    define variable sym5  as char init ":" no-undo.
    define variable sym6  as char init ":" no-undo.
    define variable sym7  as char init ":" no-undo.
    define variable sym8  as char init ":" no-undo.
    define variable sym9  as char init ":" no-undo.
    define variable sym10 as char init ":" no-undo.
    define variable sym11 as char init ":" no-undo.
    define variable sym12 as char init ":" no-undo.
    define variable sym13 as char init ":" no-undo.
    define variable sym14 as char init ":" no-undo.
    define variable sym15 as char init ":" no-undo.
    define variable sym16 as char init ":" no-undo.
    define variable sym17 as char init ":" no-undo.
    define variable sym18 as char init ":" no-undo.
    define variable sym19 as char init ":" no-undo.
    define variable sym20 as char init ":" no-undo.
    define variable sym21 as char init "|" no-undo.
    define variable v-single-line       as char          no-undo.
    define variable v-underline         as char          no-undo.
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
    define buffer  buf_fbr-doc       for fbr-doc.
    define buffer  buf_fbr-line      for fbr-line.
    define buffer  buf_recipe        for recipe.
    define buffer  buf_recipe-gds    for recipe-gds.
    define buffer  buf_goods         for goods.
    define buffer  buf_clients       for clients.
    define buffer  buf_units         for units.
do
for buf_fbr-doc
  , buf_fbr-line
  , buf_recipe
  , buf_recipe-gds
  , buf_goods
  , buf_clients
  , buf_units
on error undo, return error
:
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_fbr-doc no-lock
     where recid(buf_fbr-doc) = p-recid
.
DEFINE frame f-doc
        space(3)
        sym1  format "X(1)" space(0)   v-in-goods-artic    format "X(16)"     space(0)
        sym2  format "X(1)" space(0)   v-in-goods-name     format "X(21)"     space(0)
        sym3  format "X(1)" space(0)   v-in-bar-code       format ">>>>>>>>9" space(0)
        sym4  format "X(1)" space(0)   v-in-unit-name      format "X(3)"      space(0)
        sym5  format "X(1)" space(0)   v-in-unit-OKEI      format "X(3)"      space(0)
        sym6  format "X(1)" space(0)   v-in-price          format ">>>>9.99"  space(0)
        sym7  format "X(1)" space(0)   v-in-mass           format ">>>9.99"   space(0)
        sym8  format "X(1)" space(0)   v-in-sum            format ">>>>>9.99" space(0)
        sym9  format "X(1)" space(0)   v-out-goods-artic   format "X(16)"     space(0)
        sym10 format "X(1)" space(0)   v-out-goods-name    format "X(20)"     space(0)
        sym11 format "X(1)" space(0)   v-out-bar-code      format ">>>>>>>>9" space(0)
        sym12 format "X(1)" space(0)   v-out-norm-prc      format  ">9.9"     space(0)
        sym13 format "X(1)" space(0)   v-out-norm-mass     format ">>>9.99"   space(0)
        sym14 format "X(1)" space(0)   v-out-norm-prc-emp  format "X(4)"      space(0)
        sym15 format "X(1)" space(0)   v-out-norm-mass-emp format "X(6)"      space(0)
        sym16 format "X(1)" space(0)   v-out-sum-norm-mass format ">>>9.99"   space(0)
        sym17 format "X(1)" space(0)   v-out-price         format ">>>>9.99"  space(0)
        sym18 format "X(1)" space(0)   v-out-fact-mass     format ">>>9.99"   space(0)
        sym19 format "X(1)" space(0)   v-out-sum           format ">>>>>9.99" space(0)
        sym20 format "X(1)" space(0)   v-deviation         format "X(1)"      space(0)
        sym21 format "X(1)" space(0)
with width 235 down stream-io.
assign
    v-single-line  = fill("-", 230)
    v-underline    = fill("_", 230)
    v-line-counter = 1
.
assign
    v-doc-code  = buf_fbr-doc.doc-code
    v-doc-date  = buf_fbr-doc.doc-date
    v-fact-date = (if buf_fbr-doc.status_ <> 'факт':U then ? else buf_fbr-doc.fact-date )
.
find first buf_clients no-lock
     where buf_clients.obj-type = buf_fbr-doc.obj-type
       and buf_clients.obj-code = buf_fbr-doc.obj-code
no-error.
case buf_clients.obj-type :
    when 'маг':U then
        do:
            find first shop no-lock
                 where shop.obj-code = buf_clients.obj-code
            .
        end.
    when 'скл':U then
        do:
            find first store no-lock
                 where store.obj-code = buf_clients.obj-code
            .
        end.
end case.
assign
    v-org-name = buf_clients.obj-name
.
if session:set-wait-state("compiler") then.
output stream Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
form header
    v-single-line format "X(195)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame BottomFrame width 235 page-bottom no-labels no-box .
view stream Out-Stream frame BottomFrame .
find first clients no-lock
     where clients.obj-type = 'орг':U
       and clients.obj-code = buf_fbr-doc.host-code
.
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
assign
    v-organization = string( "ИНН " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                + t-addres + t-phone)
.
put stream Out-Stream
  skip
    string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( 3 + 195, 13)
  skip
    space(3) v-single-line format  "X(19)"             at 180
  skip
    space(3) "| "                                      at 180
                  'код':U                               at 188
                  "|"                                       at 3 + 195
  skip
    space(3) "Форма по ОКУД" format "X(14)"            at 166
                  "| "                                      at 180
                  "0330523"
                  "|"                                       at 3 + 195
  skip
    space(3) "Организация:                         "
             v-organization             format "X(100)"
             "по ОКПО"                  format "X(7)"       at 172
             "| "                                           at 180
             t-okpo                     format "X(16)" "|"  at 3 + 195
  skip
    space(3) "Струрное подразделение:              "
                  v-org-name            format "X(100)"
                  "| "                                      at 180
                  "|"                                       at 3 + 195
    space(3) "Вид деятельности по ОКДП" format "X(25)" at 155
                  "| "                                      at 180
                  "|"                                       at 3 + 195
  skip
    space(3) "Вид операции"        format "X(12)"      at 167
                  "| "                                      at 180
                   ( if buf_fbr-doc.doc-type = 'при':U
                   then " приход"
                   else ( if buf_fbr-doc.doc-type = 'возврат':U then " возврат " else " расход" ) )
                                        format "X(16)"
                   "|"                                      at 3 + 195
  skip
    space(3) v-single-line         format  "X(19)"     at 180
.
put stream Out-Stream
   skip
      "УТВЕРЖДАЮ" at center-field(137, 3 + 195, 9)
   skip space(64)
      v-single-line format "X(73)"
      "Руководитель" at center-field(137, 3 + 195, 12)
   skip
    space(64) "|"
      "|"  at 84
      "|"  at 97
      "Отчетный период"   at  center-field(97, 137, 15)
      "|"  at 137
   skip space(64)
      "|"
      "Номер"   at  center-field(64, 84, 5)
      "|"  at 84
      "Дата"   at  center-field(84, 97, 4)
      "|"  at 97
      v-single-line format "X(39)"
      "|"  at 137
      v-underline format "X(25)" at center-field(137, 3 + 195, 25)
   skip space(64)
      "|"
      "документа" format "X(9)" at  center-field(64, 84, 9)
      "|"  at 84
      "составления" format "X(11)" at  center-field(84, 97, 11)
      "|"  at 97
      "с"                          at  center-field(97, 117, 1)
      "|"  at 117
      "по"                         at  center-field(117, 137, 2)
      "|"  at 137
      "должность" format "X(9)" at center-field(137, 3 + 195, 9)
   skip space(64)
      "|"
      v-single-line format "X(71)"
      "|"  at 137
   skip
      space(58) "А К Т | "
      v-doc-code format "X(16)"
      " | "
      v-doc-date format "99/99/9999"
      "|" at 97
      v-doc-date format "99/99/9999" at  center-field(97, 117, 10)
      "|" at 117
      v-fact-date format "99/99/9999" at  center-field(117, 137, 10)
      "|"  at 137
      "______________  _____________________________" format "X(45)" at center-field(137, 3 + 195, 45)
   skip
      space(64) v-single-line format "X(73)"
      "    подпись          расшифровка подписи     " format "X(45)" at center-field(137, 3 + 195, 45)
   skip
      space(43) "О РАЗДЕЛКЕ МЯСА-СЫРЬЯ НА ПОЛУФАБРИКАТЫ" format "X(41)"
      "<    > ________________         г."            format "X(34)" at center-field(137, 3 + 195, 34)
.
form with frame f-doc .
down stream Out-Stream 1 with frame f-doc no-labels.
put stream Out-Stream
    skip space(3)
      string( "Цены и суммы указаны в рублях"  ) format "X(30)"
      ( if buf_fbr-doc.status_ <> 'факт':U
        then string( "Статус документа: " + buf_fbr-doc.status_ )
        else " " )
                                                  at 100 format "X(30)"
.
put stream Out-Stream
   skip space(3)
     v-single-line format "X(195)"
   skip space(3)
     "|"
     "Мясо-сырье, поступившее в разделку" at center-field( 3, 3 + 50, 34)
     ":"                                  at 3 + 50
     "Единица"                            at center-field( 3 + 50, 3 + 58, 7)
     ":"                                  at 3 + 58
     "Расход мяса-сырья"                  at center-field( 3 + 58, 3 + 85, 17)
     ":"                                  at 3 + 85
     "Полуфабрикаты"                      at center-field( 3 + 85, 3 + 133, 13)
     ":"                                  at 3 + 133
     "Выход полуфабрикатов"               at center-field( 3 + 133, 3 + 193, 20)
     ":"                                  at 3 + 193
     "О"
     "|"                                  at 3 + 195
   skip space(3)
     "|"
     v-single-line format "X(48)"
     ":"                                  at 3 + 50
     v-single-line format "X(7)"
     ":"                                  at 3 + 58
     v-single-line format "X(26)"
     ":"                                  at 3 + 85
     v-single-line format "X(47)"
     ":"                                  at 3 + 133
     v-single-line format "X(59)"
     ":"                                  at 3 + 193
     "т"
     "|"                                  at 3 + 195
   skip space(3)
     "|"
     ":"                                  at 3 + 18
     ":"                                  at 3 + 40
     ":"                                  at 3 + 50
     ":"                                  at 3 + 54
     ":"                                  at 3 + 58
     ":"                                  at 3 + 67
     ":"                                  at 3 + 75
     ":"                                  at 3 + 85
     ":"                                  at 3 + 102
     ":"                                  at 3 + 123
     ":"                                  at 3 + 133
     "по норме"                           at center-field( 3 + 133, 3 + 158, 8)
     ":"                                  at 3 + 158
     ":"                                  at 3 + 166
     "фактически"                         at center-field( 3 + 166, 3 + 193, 10)
     ":"                                  at 3 + 193
     "к"
     "|"                                  at 3 + 195
   skip space(3)
     "|"
     ":"                                  at 3 + 18
     ":"                                  at 3 + 40
     ":"                                  at 3 + 50
     "наи"
     ":"                                  at 3 + 54
     "код"
     ":"                                  at 3 + 58
     "цена"                               at center-field( 3 + 58, 3 + 67, 4)
     ":"                                  at 3 + 67
     "масса"
     ":"                                  at 3 + 75
     "сумма"                              at center-field( 3 + 75, 3 + 85, 5)
     ":"                                  at 3 + 85
     ":"                                  at 3 + 102
     ":"                                  at 3 + 123
     ":"                                  at 3 + 133
     v-single-line format "X(24)"    at 3 + 133 + 1
     ":"                                  at 3 + 158
     "итого"
     ":"                                  at 3 + 166
     v-single-line format "X(26)"    at 3 + 166 + 1
     ":"                                  at 3 + 193
     "л"
     "|"                                  at 3 + 195
   skip space(3)
     "|"
     "Артикул"                            at center-field( 3, 3 + 18, 7)
     ":"                                  at 3 + 18
     "Наименование"                       at center-field( 3 + 18, 3 + 40, 12)
     ":"                                  at 3 + 40
     "Код"                                at center-field( 3 + 40, 3 + 50, 3)
     ":"                                  at 3 + 50
     "мен"
     ":"                                  at 3 + 54
     "ОК"
     ":"                                  at 3 + 58
     "руб.коп"                            at center-field( 3 + 58, 3 + 67, 7)
     ":"                                  at 3 + 67
     "кг"                                 at center-field( 3 + 67, 3 + 75, 2)
     ":"                                  at 3 + 75
     "руб.коп"                            at center-field( 3 + 75, 3 + 85, 7)
     ":"                                  at 3 + 85
     "Артикул"                            at center-field( 3 + 85, 3 + 102, 7)
     ":"                                  at 3 + 102
     "Наименование"                       at center-field( 3 + 102, 3 + 123, 12)
     ":"                                  at 3 + 123
     "Код"                                at center-field( 3 + 123, 3 + 133, 3)
     ":"                                  at 3 + 133
     " в"
     ":"                                  at 3 + 138
     "масса"
     ":"                                  at 3 + 146
     " в"
     ":"                                  at 3 + 151
     "масса"
     ":"                                  at 3 + 158
     "масса"
     ":"                                  at 3 + 166
     "цена"                               at center-field( 3 + 166, 3 + 175, 4)
     ":"                                  at 3 + 175
     "масса"
     ":"                                  at 3 + 183
     "сумма"                              at center-field( 3 + 183, 3 + 193, 5)
     ":"                                  at 3 + 193
     "о"
     "|"                                  at 3 + 195
   skip space(3)
     "|"
     ":"                                  at 3 + 18
     ":"                                  at 3 + 40
     ":"                                  at 3 + 50
     ":"                                  at 3 + 54
     "ЕИ"
     ":"                                  at 3 + 58
     ":"                                  at 3 + 67
     ":"                                  at 3 + 75
     ":"                                  at 3 + 85
     ":"                                  at 3 + 102
     ":"                                  at 3 + 123
     ":"                                  at 3 + 133
     " %"
     ":"                                  at 3 + 138
     " кг"
     ":"                                  at 3 + 146
     " %"
     ":"                                  at 3 + 151
     " кг"
     ":"                                  at 3 + 158
     " кг"
     ":"                                  at 3 + 166
     "руб.коп"                            at center-field( 3 + 166, 3 + 175, 7)
     ":"                                  at 3 + 175
     "кг"                                 at center-field( 3 + 175, 3 + 183, 2)
     ":"                                  at 3 + 183
     "руб.коп"                            at center-field( 3 + 183, 3 + 193, 7)
     ":"                                  at 3 + 193
     "н"
     "|"                                  at 3 + 195
   skip space(3)
     "|"
     v-single-line format "X(193)"
     "|" at 3 + 195
.
run write-header ( input v-single-line
                  ,input no
                 ).
for each buf_fbr-line
   where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
   ,each buf_recipe
   where buf_recipe.recipe-code = buf_fbr-line.recipe-code
     and buf_recipe.recipe-type = 'разделка':U
   ,each buf_goods
   where buf_goods.artic      = buf_fbr-line.artic
     and buf_goods.prod-type  = buf_fbr-line.prod-type
     and buf_goods.prod-code  = buf_fbr-line.prod-code
break by buf_recipe.recipe-code
      by buf_fbr-line.is-comp descending
:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
 .
    if error-status:error then
    do:
    message
      vss-workfile + ". Не найден бар-код товара " + buf_goods.artic
    view-as alert-box error.
        undo, return error .
    end.
    if buf_fbr-line.is-comp = yes
    then do:
        find first buf_units no-lock
             where buf_units.unit-name = buf_goods.unit-base
        .
        assign
            v-in-price    = (if buf_fbr-line.price-rubl = ? then 0 else buf_fbr-line.price-rubl)
            v-in-sum      = (if buf_fbr-line.price-rubl * buf_fbr-line.rsrv-qnty = ?
                             then 0
                             else buf_fbr-line.price-rubl * buf_fbr-line.rsrv-qnty
                            )
            v-in-mass     = buf_fbr-line.rsrv-qnty
            v-pg-in-mass  = v-pg-in-mass + v-in-mass
            v-pg-in-sum   = v-pg-in-sum + v-in-sum
        .
        display stream out-stream
          sym1    buf_goods.artic         @ v-in-goods-artic
          sym2    buf_goods.gds-name      @ v-in-goods-name
          sym3    v-bar-code              @ v-in-bar-code
          sym4    buf_goods.unit-base     @ v-in-unit-name
          sym5    buf_units.OKEI          @ v-in-unit-OKEI
          sym6    v-in-price
          sym7    v-in-mass
          sym8    v-in-sum
        with frame f-doc.
    end.
    else do:
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
               and buf_recipe-gds.prod-type   = buf_goods.prod-type
               and buf_recipe-gds.prod-code   = buf_goods.prod-code
               and buf_recipe-gds.artic       = buf_goods.artic
        .
        assign
            v-out-norm-prc  = buf_recipe-gds.qnty / buf_recipe.qnty * 100
            v-out-norm-mass = buf_recipe-gds.qnty / buf_recipe.qnty * v-in-mass
            v-out-norm-mass = (if v-out-norm-mass = ? then 0 else v-out-norm-mass )
            v-out-price     = (if buf_fbr-line.price-rubl = ? then 0 else buf_fbr-line.price-rubl)
            v-out-sum       = (if buf_fbr-line.price-rubl * buf_fbr-line.rsrv-qnty = ?
                               then 0
                               else buf_fbr-line.price-rubl * buf_fbr-line.rsrv-qnty
                              )
            v-out-fact-mass     = buf_fbr-line.fact-qnty
            v-pg-out-norm-mass  = v-pg-out-norm-mass  + v-out-norm-mass
            v-pg-out-fact-mass  = v-pg-out-fact-mass  + v-out-fact-mass
            v-pg-out-fact-sum   = v-pg-out-fact-sum   + v-out-sum
            v-deviation = (if (v-out-fact-mass - v-out-norm-mass) < 0
                           then "-"
                           else (if (v-out-fact-mass - v-out-norm-mass) > 0 then "+" else "")
                          )
        .
        display stream out-stream
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8
          sym9    buf_goods.artic         @ v-out-goods-artic
          sym10   buf_goods.gds-name      @ v-out-goods-name
          sym11   v-bar-code              @ v-out-bar-code
          sym12   v-out-norm-prc
          sym13   v-out-norm-mass
          sym14
          sym15
          sym16   v-out-norm-mass         @ v-out-sum-norm-mass
          sym17   v-out-price
          sym18   v-out-fact-mass
          sym19   v-out-sum
          sym20   v-deviation
          sym21
        with frame f-doc.
        down stream out-stream 1 with frame f-doc.
    end.
    if line-counter( Out-Stream ) + 1 > page-size( Out-Stream )
    then do:
        run write-itog( input "Итого"
                       ,input v-pg-in-mass
                       ,input v-pg-in-sum
                       ,input v-pg-out-norm-mass
                       ,input v-pg-out-fact-mass
                       ,input v-pg-out-fact-sum
                      ).
        assign
            v-sum-in-mass       = v-sum-in-mass       + v-pg-in-mass
            v-sum-in-sum        = v-sum-in-sum        + v-pg-in-sum
            v-sum-out-norm-mass = v-sum-out-norm-mass + v-pg-out-norm-mass
            v-sum-out-fact-mass = v-sum-out-fact-mass + v-pg-out-fact-mass
            v-sum-out-fact-sum  = v-sum-out-fact-sum  + v-pg-out-fact-sum
            v-pg-in-mass        = 0
            v-pg-in-sum         = 0
            v-pg-out-norm-mass  = 0
            v-pg-out-fact-mass  = 0
            v-pg-out-fact-sum   = 0
        .
        down stream out-stream 1 with frame f-doc.
        run write-header(   input v-single-line
                          , input yes
                        ).
    end.
end.
hide stream Out-Stream frame BottomFrame .
if line-counter( Out-Stream ) + 9 > page-size( Out-Stream )
then do:
    run write-itog(   input "Итого"
                    , input v-pg-in-mass
                    , input v-pg-in-sum
                    , input v-pg-out-norm-mass
                    , input v-pg-out-fact-mass
                    , input v-pg-out-fact-sum
                  ).
    assign
        v-sum-in-mass       = v-sum-in-mass       + v-pg-in-mass
        v-sum-in-sum        = v-sum-in-sum        + v-pg-in-sum
        v-sum-out-norm-mass = v-sum-out-norm-mass + v-pg-out-norm-mass
        v-sum-out-fact-mass = v-sum-out-fact-mass + v-pg-out-fact-mass
        v-sum-out-fact-sum  = v-sum-out-fact-sum  + v-pg-out-fact-sum
    .
    page stream Out-Stream .
    run write-header(   input v-single-line
                      , input yes
                    ).
end.
else do:
    run write-itog(   input "Итого"
                            , input v-pg-in-mass
                            , input v-pg-in-sum
                            , input v-pg-out-norm-mass
                            , input v-pg-out-fact-mass
                            , input v-pg-out-fact-sum
                  ).
            assign
                v-sum-in-mass       = v-sum-in-mass       + v-pg-in-mass
                v-sum-in-sum        = v-sum-in-sum        + v-pg-in-sum
                v-sum-out-norm-mass = v-sum-out-norm-mass + v-pg-out-norm-mass
                v-sum-out-fact-mass = v-sum-out-fact-mass + v-pg-out-fact-mass
                v-sum-out-fact-sum  = v-sum-out-fact-sum  + v-pg-out-fact-sum
            .
end.
run write-itog( input "Всего"
                ,input v-sum-in-mass
                ,input v-sum-in-sum
                ,input v-sum-out-norm-mass
                ,input v-sum-out-fact-mass
                ,input v-sum-out-fact-sum
              ).
down stream Out-Stream 2 with frame f-doc .
put stream Out-Stream
    skip(1) space(10)
      "Переработано мяса-сырья"
      v-sum-in-mass format ">>>>>>9.99" at  10 + 37
      space(2) "кг"
      "Выработано полуфабрикатов"               at 10 + 97
      v-sum-out-fact-mass format ">>>>>>9.99"    at 10 + 147
      space(2) "кг"
    skip space(10)
      v-underline format "X(185)"
    skip(1) space(10)
      "Представитель администрации"
      v-underline format "X(10)"                at 10 + 17 + 13
      v-underline format "X(15)"                at 10 + 37 + 4
      v-underline format "X(30)"                at 10 + 57
      "Заведующий производством"                at 10 + 97
      v-underline format "X(19)"                at 10 + 127
      v-underline format "X(30)"                at 10 + 147
    skip space(10)
      "должность"                               at center-field( 10 + 17 + 13, 10 + 37 + 4, 9)
      "подпись"                                 at center-field( 10 + 37 + 4, 10 + 57, 6)
      "расшифровка подписи"                     at center-field( 10 + 57, 10 + 57 + 30, 19)
      "подпись"                                 at center-field( 10 + 127, 10 + 147, 6)
      "расшифровка подписи"                     at center-field( 10 + 147, 10 + 177, 19)
    skip space(10)
      "Мастер (бригадир)"
      v-underline format "X(19)"                at 10 + 37
      v-underline format "X(30)"                at 10 + 57
      v-underline format "X(19)"                at 10 + 107
      v-underline format "X(19)"                at 10 + 127
      v-underline format "X(30)"                at 10 + 147
    skip space(10)
      "подпись"                                 at center-field( 10 + 37, 10 + 57, 6)
      "расшифровка подписи"                     at center-field( 10 + 57, 10 + 57 + 30, 19)
      "должность"                               at center-field( 10 + 107, 10 + 127, 9)
      "подпись"                                 at center-field( 10 + 127, 10 + 147, 6)
      "расшифровка подписи"                     at center-field( 10 + 147, 10 + 177, 19)
    skip space(10)
      "Проверил бухгалтер"
      v-underline format "X(19)"                at 10 + 37
      v-underline format "X(30)"                at 10 + 57
      "Приложение ________________________________________ документов"       at 10 + 97
    skip space(10)
      "подпись"                                 at center-field( 10 + 37, 10 + 57, 6)
      "расшифровка подписи"                     at center-field( 10 + 57, 10 + 57 + 30, 19)
.
output stream Out-Stream close.
if session :set-wait-state( "" ) then.
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
procedure write-header :
do
on error undo, return error
:
def input parameter p-single-line as char    no-undo.
def input parameter p-need-line   as logical no-undo.
    if p-need-line = yes
    then put stream out-stream
        skip
          string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( 3 + 195, 13)
        skip space(3)
          p-single-line format "X(195)"
    .
    put stream out-stream
        skip space(3)
          "|"
          "1"                  at center-field( 3, 3 + 18, 1)
          ":"                  at 3 + 18
          "2"                  at center-field( 3 + 18, 3 + 40, 1)
          ":"                  at 3 + 40
          "3"                  at center-field( 3 + 40, 3 + 50, 1)
          ":"                  at 3 + 50
          "4"                  at center-field( 3 + 50, 3 + 54, 1)
          ":"                  at 3 + 54
          "5"                  at center-field( 3 + 54, 3 + 58, 1)
          ":"                  at 3 + 58
          "6"                  at center-field( 3 + 58, 3 + 67, 1)
          ":"                  at 3 + 67
          "7"                  at center-field( 3 + 67, 3 + 75, 1)
          ":"                  at 3 + 75
          "8"                  at center-field( 3 + 75, 3 + 85, 1)
          ":"                  at 3 + 85
          "9"                  at center-field( 3 + 85, 3 + 102, 1)
          ":"                  at 3 + 102
          "10"                 at center-field( 3 + 102, 3 + 123, 2)
          ":"                  at 3 + 123
          "11"                 at center-field( 3 + 123, 3 + 133, 2)
          ":"                  at 3 + 133
          "12"                 at center-field( 3 + 133, 3 + 138, 2)
          ":"                  at 3 + 138
          "13"                 at center-field( 3 + 138, 3 + 146, 2)
          ":"                  at 3 + 146
          "14"                 at center-field( 3 + 146, 3 + 151, 2)
          ":"                  at 3 + 151
          "15"                 at center-field( 3 + 151, 3 + 158, 2)
          ":"                  at 3 + 158
          "16"                 at center-field( 3 + 158, 3 + 166, 2)
          ":"                  at 3 + 166
          "17"                 at center-field( 3 + 166, 3 + 175, 2)
          ":"                  at 3 + 175
          "18"                 at center-field( 3 + 175, 3 + 183, 2)
          ":"                  at 3 + 183
          "19"                 at center-field( 3 + 183, 3 + 193, 2)
          ":"                  at 3 + 193
          "X"
          "|"                  at 3 + 195
        skip space(3)
          "|"
          p-single-line format "X(193)"
          "|"                  at 3 + 195
    .
end.
end procedure.
procedure write-itog :
do
on error undo, return error
:
    define input parameter p-type          as char no-undo.
    define input parameter p-in-mass       as decimal no-undo.
    define input parameter p-in-sum        as decimal no-undo.
    define input parameter p-out-norm-mass as decimal no-undo.
    define input parameter p-out-fact-mass as decimal no-undo.
    define input parameter p-out-fact-sum  as decimal no-undo.
    put stream Out-Stream
      skip space(3)
        v-single-line format "X(195)"
    .
    display stream out-stream
              p-type                              @ v-in-price
      sym7    p-in-mass       format ">>>9.99"    @ v-in-mass
      sym8    p-in-sum        format ">>>>>9.99"  @ v-in-sum
      sym13   p-out-norm-mass format ">>>9.99"    @ v-out-norm-mass
      sym14
      sym15   p-out-norm-mass format ">>>9.99"    @ v-out-sum-norm-mass
      sym16   p-out-norm-mass format ">>>9.99"    @ v-out-norm-mass
      sym17
      sym18   p-out-fact-mass format ">>>9.99"    @ v-out-fact-mass
      sym19   p-out-fact-sum  format ">>>>>9.99"  @ v-out-sum
      sym21
    with frame f-doc.
end.
end procedure.
