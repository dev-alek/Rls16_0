block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-12.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/op-12.p $":U .
define variable vss-description as character no-undo init "Печатная форма ОП-12. АКТ О РЕАЛИЗАЦИИ ГОТОВЫХ ИЗДЕЛИЙ КУХНИ".
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
do
on error undo, return error
:
def shared var PrintScale as logical     no-undo.
def stream Out-Stream .
def buffer  t-doc       for trn-doc.
def buffer  buf_clients   for clients.
def var tdoc-prt              as logical                  no-undo.
def var tdoc-code             like trn-doc.doc-code       no-undo.
def var tdoc-date             like trn-doc.doc-date       no-undo.
def var rootnode_code         as integer                  no-undo.
def var v-line-counter        as integer                  no-undo.
def var txt-LC                as char                     no-undo.
def var s1                    as char                     no-undo.
def var s2                    as char                     no-undo.
def var Node_Code             like gds-prt.upper-code     no-undo.
def var CostNoNDS             as decimal                  no-undo.
def var CostNDS               as decimal                  no-undo.
def var CostWithNDS           as decimal                  no-undo.
def var tqnty                 as decimal                  no-undo.
def var SumCostNoNDS          as decimal                  no-undo.
def var SumCostNDS            as decimal                  no-undo.
def var SumCostWithNDS        as decimal                  no-undo.
def var prt-tqnty             as decimal                  no-undo.
def var prt-SumCostNoNDS      as decimal                  no-undo.
def var prt-SumCostNDS        as decimal                  no-undo.
def var prt-SumCostWithNDS    as decimal                  no-undo.
def var Pg-tqnty              as decimal   init 0 no-undo.
def var Pg-SumCostNoNDS       as decimal                  no-undo.
def var Pg-SumCostNDS         as decimal                  no-undo.
def var Pg-SumCostWithNDS     as decimal                  no-undo.
def var PrevPage              as int       init 0         no-undo.
def var tot-SumCostNoNDS      as decimal                  no-undo.
def var tot-SumCostNDS        as decimal                  no-undo.
def var tot-SumCostWithNDS    as decimal                  no-undo.
def var PrtName               as char                     no-undo.
def var v-organization        as char                     no-undo.
def var v-org-from            as char                     no-undo.
def var v-org-to              as char                     no-undo.
def var v-doc-line-counter    as integer   init 0         no-undo.
def var v-goods-artic         as char                     no-undo.
def var v-goods-name          as char                     no-undo.
def var v-bar-code            as integer                  no-undo.
def var v-unit-name           as char                     no-undo.
def var v-unit-OKEI           as char                     no-undo.
def var v-need-qnty           as decimal                  no-undo.
def var v-places-amount       as decimal                  no-undo.
def var v-qnty-in-one-place   as decimal                  no-undo.
def var v-qnty-all            as decimal                  no-undo.
def var v-cost-price          as decimal                  no-undo.
def var v-cost-sum            as decimal                  no-undo.
def var v-sale-price          as decimal                  no-undo.
def var v-sale-sum            as decimal                  no-undo.
def var v-comment             as char                     no-undo.
def var v-doc-num             as char                     no-undo.
def var v-road-tax            as decimal                  no-undo.
def var v-excise              as decimal                  no-undo.
def var v-pg-need-qnty       as decimal                  no-undo.
def var v-pg-places-amount   as decimal                  no-undo.
def var v-pg-qnty-all        as decimal                  no-undo.
def var v-pg-cost-sum        as decimal                  no-undo.
def var v-pg-sale-sum        as decimal                  no-undo.
def var v-prt-need-qnty       as decimal                  no-undo.
def var v-prt-places-amount   as decimal                  no-undo.
def var v-prt-qnty-all        as decimal                  no-undo.
def var v-prt-cost-sum        as decimal                  no-undo.
def var v-prt-sale-sum        as decimal                  no-undo.
def var sym1 as char init "|" no-undo.
def var sym2 as char init ":" no-undo.
def var sym3 as char init ":" no-undo.
def var sym4 as char init ":" no-undo.
def var sym5 as char init ":" no-undo.
def var sym6 as char init ":" no-undo.
def var sym7 as char init ":" no-undo.
def var sym8 as char init ":" no-undo.
def var sym9 as char init ":" no-undo.
def var sym10 as char init ":" no-undo.
def var sym11 as char init "|" no-undo.
def var v-single-line       as char          no-undo.
def var v-underline         as char          no-undo.
def var v-valut-name             as char          no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
run get-report-num in p-mainmenu-handle  ( output g#report-num  ) .
run get-quest-print in p-mainmenu-handle ( output g#quest-print ) .
find first t-doc where recid( t-doc ) = rec_id  no-lock .
DEFINE frame f-doc
        space(5)
        sym1 column-label "|" format "X(1)" space(0)
        v-doc-line-counter column-label " 1" format ">>>9" space(1)
        sym2 column-label ":" format "X(1)" space(0)
        v-goods-artic column-label "        2       " format "X(6)" space(0)
        sym3 column-label ":" format "X(1)" space(0)
        v-goods-name column-label "                     3                      " format "X(48)" space(0)
        sym4 column-label ":" format "X(1)" space(0)
        v-bar-code column-label "    4    " format ">>>>>>>>>>>9" space(0)
        sym5 column-label ":" format "X(1)" space(0)
        v-qnty-all column-label "  5 " format ">>>>>>>>>>9.999" space(0)
        sym6 column-label ":" format "X(1)" space(0)
        v-sale-price column-label "     6      " format  "->>,>>>,>>>,>>9.99" space(0)
        sym7 column-label ":" format "X(1)" space(0)
        v-sale-sum column-label   "     7       " format "->>,>>>,>>>,>>9.99" space(0)
        sym8 column-label ":" format "X(1)" space(0)
        v-cost-price column-label "     8      " format  "->>,>>>,>>>,>>9.99" space(0)
        sym9 column-label ":" format "X(1)" space(0)
        v-cost-sum column-label   "      9      " format "->>,>>>,>>>,>>9.99" space(0)
        sym10 column-label ":" format "X(1)" space(0)
        v-comment column-label "        10         " format "X(24)" space(0)
        sym11 column-label "|" format "X(1)" space(0)
    with width 235 down stream-io.
assign
    v-valut-name   = ( if PrintRubl then "рублях" else "баз.вал" )
    v-single-line  = fill("-", 230)
    v-underline    = fill("_", 230)
    v-line-counter = 1
.
assign
    tdoc-code = t-doc.doc-code
    tdoc-date = (if t-doc.status_ <> 'факт':U then t-doc.doc-date else t-doc.fact-date )
.
find first buf_clients no-lock
     where buf_clients.obj-type = t-doc.obj-type
       and buf_clients.obj-code = t-doc.obj-code
no-error.
  case buf_clients.obj-type :
    when 'маг':U then do:
      find first shop no-lock where shop.obj-code = buf_clients.obj-code .
      assign tdoc-prt = shop.doc-prt .
    end.
    when 'скл':U then do:
      find first store no-lock where store.obj-code = buf_clients.obj-code .
      assign tdoc-prt = store.doc-prt .
    end.
  end case.
  assign v-org-from = buf_clients.obj-name .
  if not tdoc-prt then PrintScale = no .
find first buf_clients no-lock where buf_clients.obj-type = t-doc.cli-type and buf_clients.obj-code = t-doc.cli-code no-error.
assign
    v-org-to = buf_clients.obj-name
.
if session :set-wait-state( "compiler" ) then.
output stream Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
form header
    v-single-line format "X(193)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame BottomFrame width 235 page-bottom no-labels no-box .
view stream Out-Stream frame BottomFr&DOS_CWame .
find first clients no-lock where clients.obj-type = 'орг':U and clients.obj-code = t-doc.host-code .
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
    v-organization = string( "ИНН " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")" + t-addres + t-phone)
.
put stream Out-Stream  skip string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( 5 + 193, 13) .
put stream Out-Stream
  skip    space(5) v-single-line format  "X(19)"             at 180
  skip    space(5) "| "                                      at 180
                  'код':U                               at 188
                  "|"                                       at 5 + 193
  skip    space(5) "Форма по ОКУД" format "X(14)"            at 166
                  "| "                                      at 180
                  "0330512"
                  "|"                                       at 5 + 193
  skip    space(5) "Организация:                         "
             v-organization             format "X(100)"
             "по ОКПО"                  format "X(7)"       at 172
             "| "                                           at 180
             t-okpo                     format "X(16)" "|"  at 5 + 193
  skip    space(5) "Струрное подразделение:              "
                  (if t-doc.doc-type = 'при':U then v-org-to else v-org-from) format "X(80)"
                  "| "                                      at 180
                  "|"                                       at 5 + 193
  skip
    space(5) "Вид деятельности по ОКДП" format "X(25)" at 155
                  "| "                                      at 180
                  "|"                                       at 5 + 193
  skip
    space(5) "Вид операции"        format "X(12)"      at 167
                  "| "                                      at 180
                   " "                    format "X(16)"
                   "|"                                      at 5 + 193
  skip
    space(5) v-single-line         format  "X(19)"     at 180
.
put stream Out-Stream
   skip    space(74) v-single-line format "X(33)"                               "УТВЕРЖДАЮ" at 176
   skip    space(74) "|"
      "Номер"   at  center-field(75, 93, 5)    "|"  at 94   "Дата"   at  center-field(95, 106, 4)   "|"  at 107  format "X(33)"   "Руководитель"     at 175
   skip    space(74) "|"
      "документа" format "X(9)" at  center-field(75, 93, 9)        "|"  at 94
       "составления" format "X(11)" at  center-field(95, 106, 11)  "|"  at 107     "_______________________"    at 171
   skip    space(74) "|"   v-single-line format "X(31)"   "|"  at 107              "должность"                  at 178
   skip    space(70) string( "АКТ | "
                                + string( tdoc-code , "X(16)") + " | " + string( tdoc-date, "99/99/9999") + " | "
                                + (if t-doc.status_ <> 'факт':U then string( "(" + CAPS(t-doc.status_) + ")" ) else "")
                                ) format "X(80)"                                  "_____________  __________________"    at 165
   skip    space(74) v-single-line format "X(33)"                                  "подпись     расшифровка подписи"    at 168
   skip    space(45) "О РЕАЛИЗАЦИИ ГОТОВЫХ ИЗДЕЛИЙ КУХНИ ЗА НАЛИЧНЫЙ РАСЧЕТ" format "X(70)"         "<_____> ___________________ г."  at 168
.
form with frame f-doc .
down stream Out-Stream 1 with frame f-doc no-labels.
put stream Out-Stream
    skip space(5)
      "Комиссия установила:"
      string( "Цены и суммы указаны в " + trim( v-valut-name ) ) format "X(30)"    at 100
      ( if t-doc.status_ <> 'факт':U  then string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) ) else " " )   at 150 format "X(30)"
.
put stream Out-Stream
   skip space(5)
     v-single-line format "X(193)"
   skip space(5)
     "|Номер"
     ":" at 5 + 7
     "Номер"
     ":" at 5 + 14
     "Готовое изделие " at center-field( 5 + 14, 5 + 76, 17)
     ":" at 5 + 76
     "Реализовано" at center-field( 5 + 76, 5 + 168, 15)
     ":" at 5 + 168
     "|" at 5 + 193
   skip space(5)
     "| по "
     ":" at 5 + 7
     "каль-"
     ":" at 5 + 14
     v-single-line format "X(153)" at (5 + 14 + 1)
     ":" at 5 + 168
     "|" at 5 + 193
   skip
     space(5)
     "| по- "
     ":" at 5 + 7
     "куля-"
     ":" at 5 + 14
     "наименование"   at center-field( 5 + 14, 5 + 63, 12)
     ":" at 5 + 63
     "код"   at center-field( 5 + 63, 5 + 76, 3)
     ":" at 5 + 76
     "Количество" at center-field( 5 + 76, 5 + 92, 10)
     ":" at 5 + 92
     "По ценам продажи" at center-field( 5 + 92, 5 + 130, 17)
     ":" at 5 + 130
     "По учетным ценам" at center-field( 5 + 130, 5 + 168, 17)
     ":" at 5 + 168
     "Примечание" at center-field( 5 + 168, 5 + 193, 10)
     "|" at 5 + 193
   skip space(5)
     "|рядку"
     ":"                  at 5 + 7
     "цион. "
     ":"                  at 5 + 14
     ":"                  at 5 + 63
     ":"                  at 5 + 76
     ":"                  at 5 + 92
     v-single-line format "X(75)" at (5 + 92 + 1)
     ":"                  at 5 + 168
     "|"                  at 5 + 193
   skip space(5)
     "|"
     ":"                  at 5 + 7
     "карт."
     ":"                  at 5 + 14
     ":"                  at 5 + 63
     ":"                  at 5 + 76
     ":"                  at 5 + 92
     "Цена, руб.коп" at center-field( 5 + 92, 5 + 111, 17)
     ":"                  at 5 + 111
     "Сумма, руб.коп" at center-field( 5 + 111, 5 + 130, 17)
     ":"                  at 5 + 130
     "Цена, руб.коп" at center-field( 5 + 130, 5 + 149, 17)
     ":"                  at 5 + 149
     "Сумма, руб.коп" at center-field( 5 + 149, 5 + 168, 17)
     ":"                  at 5 + 168
     "|"                  at 5 + 193
   skip space(5)
     "|"
     v-single-line format "X(191)"
     "|" at 5 + 193
.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        PUT stream Out-Stream
            skip space(5)
              "|  1"
              ":"                  at 5 + 7
              "2"                  at center-field( 5 + 7, 5 + 14, 1)
              ":"                  at 5 + 14
              "3"                  at center-field( 5 + 14, 5 + 63, 1)
              ":"                  at 5 + 63
              "4"                  at center-field( 5 + 63, 5 + 76, 1)
              ":"                  at 5 + 76
              "5"                  at center-field( 5 + 76, 5 + 92, 1)
              ":"                  at 5 + 92
              "6"                  at center-field( 5 + 92, 5 + 111, 1)
              ":"                  at 5 + 111
              "7"                  at center-field( 5 + 111, 5 + 130, 1)
              ":"                  at 5 + 130
              "8"                  at center-field( 5 + 130, 5 + 149, 1)
              ":"                  at 5 + 149
              "9"                  at center-field( 5 + 149, 5 + 168, 1)
              ":"                  at 5 + 168
              "10"                 at center-field( 5 + 168, 5 + 193, 2)
              "|"                  at 5 + 193
            skip space(5)
              "|"
              v-single-line format "X(191)"
              "|"                  at 5 + 193
        .
for each doc-line no-lock where doc-line.doc-code = t-doc.doc-code
   break BY doc-line.artic
:
    find first goods no-lock
         where goods.prod-type = doc-line.prod-type
           and goods.prod-code = doc-line.prod-code
           and goods.artic = doc-line.artic
    .
    find first gds-prt no-lock where gds-prt.upper-code = goods.prt-root .
    rootnode_code = gds-prt.node-code.
assign
  price-rubl-with-tax-loc = doc-line.price-rubl
  price-base-with-tax-loc = doc-line.price-base
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    assign
        v-goods-name = goods.gds-name
        v-cost-price = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
    .
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
        v-doc-line-counter = v-doc-line-counter + 1
        v-bar-code      = goods.gds-code
        v-need-qnty     = gds-dtl.doc-qnty
        v-qnty-all      = gds-dtl.fact-qnty
        v-unit-name     = goods.unit-base
        v-cost-sum      = v-cost-price * v-qnty-all
        v-sale-price    = ( if PrintRubl then gds-dtl.price-rubl else gds-dtl.price-base )
        v-sale-sum      = v-sale-price * v-qnty-all
    .
    display stream Out-Stream
        v-doc-line-counter
        v-goods-artic
        v-goods-name
        v-bar-code
        v-qnty-all
        v-cost-price
        v-cost-sum
        v-sale-price
        v-sale-sum
        v-comment
        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10  sym11
    with frame f-doc.
    down stream Out-Stream 1 with frame f-doc.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
            v-pg-need-qnty     = 0
            v-pg-places-amount = 0
            v-pg-qnty-all      = 0
            v-pg-cost-sum      = 0
            v-pg-sale-sum      = 0
        .
            assign
                PrevPage           = page-number( Out-Stream )
                v-pg-need-qnty     = v-pg-need-qnty + v-need-qnty
                v-pg-places-amount = 0
                v-pg-qnty-all      = v-pg-qnty-all + v-qnty-all
                v-pg-cost-sum      = v-pg-cost-sum + v-cost-sum
                v-pg-sale-sum      = v-pg-sale-sum + v-sale-sum
            .
        if line-counter( Out-Stream ) + 2 > page-size( Out-Stream ) then
            do:
                PUT stream Out-Stream  skip space(5) v-single-line format "X(193)"  .
                display stream Out-Stream
                  skip space(5)
                    "Итого"             @ v-goods-name
                    v-pg-qnty-all       @ v-qnty-all
                    v-pg-cost-sum       @ v-cost-sum
                    v-pg-sale-sum       @ v-sale-sum
                with frame f-doc.
                page stream Out-Stream.
                put stream Out-Stream
                    skip space(5)
                    v-single-line format "X(191)"
                    skip space(5)
                    "|  1"
                    ":"                  at 5 + 7
                    "2"                  at center-field( 5 + 7, 5 + 14, 1)
                    ":"                  at 5 + 14
                    "3"                  at center-field( 5 + 14, 5 + 63, 1)
                    ":"                  at 5 + 63
                    "4"                  at center-field( 5 + 63, 5 + 76, 1)
                    ":"                  at 5 + 76
                    "5"                  at center-field( 5 + 76, 5 + 92, 1)
                    ":"                  at 5 + 92
                    "6"                  at center-field( 5 + 92, 5 + 111, 1)
                    ":"                  at 5 + 111
                    "7"                  at center-field( 5 + 111, 5 + 130, 1)
                    ":"                  at 5 + 130
                    "8"                  at center-field( 5 + 130, 5 + 149, 1)
                    ":"                  at 5 + 149
                    "9"                  at center-field( 5 + 149, 5 + 168, 1)
                    ":"                  at 5 + 168
                    "10"                 at center-field( 5 + 168, 5 + 193, 2)
                    "|"                  at 5 + 193
                    skip space(5)
                    "|"
                    v-single-line format "X(191)"
                    "|"                  at 5 + 193
                .
            end.
    v-line-counter = v-line-counter + 1.
    accumulate
        v-cost-sum ( TOTAL )
        v-sale-sum ( TOTAL )
    .
end.
  if line-counter( Out-Stream ) + 9 > page-size( Out-Stream ) then do:
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
            v-pg-need-qnty     = 0
            v-pg-places-amount = 0
            v-pg-qnty-all      = 0
            v-pg-cost-sum      = 0
            v-pg-sale-sum      = 0
        .
            do:
                PUT stream Out-Stream  skip space(5) v-single-line format "X(193)"  .
                display stream Out-Stream
                  skip space(5)
                    "Итого"             @ v-goods-name
                    v-pg-qnty-all       @ v-qnty-all
                    v-pg-cost-sum       @ v-cost-sum
                    v-pg-sale-sum       @ v-sale-sum
                with frame f-doc.
            end.
    page stream Out-Stream .
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
            if page-number( Out-Stream ) <> 1 then do:
                PUT stream Out-Stream  skip space(5)
                        "Документ " + string( tdoc-code ) + " от " + string( tdoc-date, "99/99/9999" ) format "X(60)"
                        "Страница " + string( page-number( Out-Stream ) ) format "X(13)" at right-field( 5 + 193, 13 )
                .
            end.
            PUT stream Out-Stream skip space(5) v-single-line format "X(193)" .
        PUT stream Out-Stream
            skip space(5)
              "|  1"
              ":"                  at 5 + 7
              "2"                  at center-field( 5 + 7, 5 + 14, 1)
              ":"                  at 5 + 14
              "3"                  at center-field( 5 + 14, 5 + 63, 1)
              ":"                  at 5 + 63
              "4"                  at center-field( 5 + 63, 5 + 76, 1)
              ":"                  at 5 + 76
              "5"                  at center-field( 5 + 76, 5 + 92, 1)
              ":"                  at 5 + 92
              "6"                  at center-field( 5 + 92, 5 + 111, 1)
              ":"                  at 5 + 111
              "7"                  at center-field( 5 + 111, 5 + 130, 1)
              ":"                  at 5 + 130
              "8"                  at center-field( 5 + 130, 5 + 149, 1)
              ":"                  at 5 + 149
              "9"                  at center-field( 5 + 149, 5 + 168, 1)
              ":"                  at 5 + 168
              "10"                 at center-field( 5 + 168, 5 + 193, 2)
              "|"                  at 5 + 193
            skip space(5)
              "|"
              v-single-line format "X(191)"
              "|"                  at 5 + 193
        .
  end.
  hide stream Out-Stream frame BottomFrame .
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if page-number( Out-Stream ) > PrevPage
    then assign
            v-pg-need-qnty     = 0
            v-pg-places-amount = 0
            v-pg-qnty-all      = 0
            v-pg-cost-sum      = 0
            v-pg-sale-sum      = 0
        .
            do:
                PUT stream Out-Stream  skip space(5) v-single-line format "X(193)"  .
                display stream Out-Stream
                  skip space(5)
                    "Итого"             @ v-goods-name
                    v-pg-qnty-all       @ v-qnty-all
                    v-pg-cost-sum       @ v-cost-sum
                    v-pg-sale-sum       @ v-sale-sum
                with frame f-doc.
            end.
  display stream Out-Stream
    "Всего по накладной" @ v-goods-name
    t-doc.fact-qnty @ v-qnty-all
    ( accum total v-cost-sum ) @ v-cost-sum
    ( accum total v-sale-sum ) @ v-sale-sum
  with frame f-doc .
  down stream Out-Stream 2 with frame f-doc .
  if PrintRubl then    run rep/wp-rub.p ( (accum total v-cost-sum), output s1, output s2 ) .
  else                 run rep/wp.p ( input p-mainmenu-handle, (accum total v-cost-sum), output s1, output s2 ) .
  put stream Out-Stream
    skip
     space(10) "СПРАВКА: Израсходовано на приготовление блюд" skip
     space(10) "   специй                % к обороту на сумму ______________________  руб ____ коп"  skip
     space(10) "   соли                  % к обороту на сумму ______________________  руб ____ коп"  skip
     space(10) "                                       Итого  ______________________  руб ____ коп"  skip
     space(10) "Члены комиссии:"  skip
     space(10) "Заведующий производством (бригадир)"
      v-underline format "X(19)"                at 10 + 61
      v-underline format "X(30)"                at 10 + 81
    skip
      space(10)
      "подпись"                                 at center-field( 10 + 61, 10 + 81, 6)
      "расшифровка подписи"                     at center-field( 10 + 81, 10 + 101, 19)
    skip
      space(10)
      v-underline format "X(19)"                at 10 + 40
      v-underline format "X(19)"                at 10 + 61
      v-underline format "X(30)"                at 10 + 81
    skip
      space(10)
      "должность"                               at center-field( 10 + 40, 10 + 61, 9)
      "подпись"                                 at center-field( 10 + 61, 10 + 81, 6)
      "расшифровка подписи"                     at center-field( 10 + 81, 10 + 101, 19)
    skip
      space(10)
      v-underline format "X(19)"                at 10 + 40
      v-underline format "X(19)"                at 10 + 61
      v-underline format "X(30)"                at 10 + 81
    skip
      space(10)
      "должность"                               at center-field( 10 + 40, 10 + 61, 9)
      "подпись"                                 at center-field( 10 + 61, 10 + 81, 6)
      "расшифровка подписи"                     at center-field( 10 + 81, 10 + 101, 19)
    skip (2)
          space(10)   "Выручка кассы  " caps(substring(s1, 1, 178)) format "X(178)"
    skip  space(10)   "Стоимость реализованных изделий, указанная в настоящем акте, соответствует кассовым чекам."
    skip
     space(10) "Кассир "
      v-underline format "X(19)"                at 10 + 61
      v-underline format "X(30)"                at 10 + 81
    skip
      space(10)
      "подпись"                                 at center-field( 10 + 61, 10 + 81, 6)
      "расшифровка подписи"                     at center-field( 10 + 81, 10 + 101, 19)
    skip
     space(10) "Проверил бухгалтер "
      v-underline format "X(19)"                at 10 + 61
      v-underline format "X(30)"                at 10 + 81
    skip
      space(10)
      "подпись"                                 at center-field( 10 + 61, 10 + 81, 6)
      "расшифровка подписи"                     at center-field( 10 + 81, 10 + 101, 19)
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
