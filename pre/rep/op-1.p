using Ibs.Th.Gbl.*.
block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle    no-undo.
define input parameter p-recid              as recid     no-undo.
define input parameter p-print-in-rubl      as logical   no-undo.
define input parameter p-print-details      as logical   no-undo.
define input parameter p-price-celection    as integer   no-undo.
define input parameter p-print-null-qnty    as logical   no-undo.
define input parameter p-sort-by-group      as logical   no-undo.
define input parameter p-price-from-doc     as logical   no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/op-1.p $":U .
define variable vss-description as character no-undo init "Печатная форма ОП-1. Производство, калькуляционная карточка.".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
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
    define stream out-stream .
    define temp-table temp_recipe no-undo
        field recipe-code       as character
        field artic             as character
        field prod-type         as character
        field prod-code         as integer
        field gds-code          as integer
        field goods-unit        as character
        field recipe-type       as character
        field recipe-name       as character
        field qnty              as decimal
        field portion-weight    as decimal
        field portion-qnty      as decimal
        field sum-cost          as decimal
        field sum-sale          as decimal
        field sum-prc           as decimal
        index pi is primary unique
            recipe-code
    .
    define variable v-table-line-counter        as integer                  no-undo.
    define variable v-line-counter        as integer                  no-undo.
    define variable v-organization        as char                     no-undo.
    define variable v-org-name            as char                     no-undo.
    define variable v-recipe-name         as char                     no-undo.
    define variable v-doc-code            as char                     no-undo.
    define variable v-fact-date           as date                     no-undo.
    define variable v-goods-unit          as char                     no-undo.
    define variable v-goods-artic         as char                     no-undo.
    define variable v-goods-name          as char                     no-undo.
    define variable v-bar-code            as integer                  no-undo.
    define variable v-mass                as decimal                  no-undo.
    define variable v-cost                as decimal                  no-undo.
    define variable v-sum                 as decimal                  no-undo.
    define variable v-sum-cost            as decimal                  no-undo.
    define variable v-sum-prc             as decimal                  no-undo.
    define variable v-sum-sale            as decimal                  no-undo.
    define variable sym1  as char init "|" no-undo.
    define variable sym2  as char init ":" no-undo.
    define variable sym3  as char init ":" no-undo.
    define variable sym4  as char init ":" no-undo.
    define variable sym5  as char init ":" no-undo.
    define variable sym6  as char init ":" no-undo.
    define variable sym7  as char init ":" no-undo.
    define variable sym8  as char init "|" no-undo.
    define variable v-single-line         as char               no-undo.
    define variable v-underline           as char               no-undo.
    define variable v-no-printable-recipe as logical init no    no-undo.
    define variable v-need-page-break     as logical init no    no-undo.
    define variable v-first-recipe        as logical      no-undo.
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_goods         for ub.goods.
    define buffer buf_clients       for ub.clients.
    define buffer buf_units         for ub.units.
    define buffer buf_temp_recipe   for temp_recipe.
def var v-rep-gen as class ReportXml no-undo.
def shared var v-rep-util as class ReportXsltUtil no-undo.
v-rep-gen = v-rep-util:get-data-generator().
do
for buf_fbr-doc
  , buf_fbr-line
  , buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_goods
  , buf_clients
  , buf_units
  , buf_temp_recipe
on error undo, return error
:
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
define shared variable CostPrice    as logical                          no-undo.
    find first buf_fbr-doc no-lock
        where recid(buf_fbr-doc) = p-recid
    no-error.
    if not available buf_fbr-doc
    then do:
        message
            "Не найден документ производства."
            skip (1) "Форму ОП-1 напечатать невозможно."
        view-as alert-box.
        undo, return.
    end.
    if buf_fbr-doc.is-free = yes
    then do:
        message
            "Калькуляционная карточка не может быть напечатана"
            skip "для документа производства без рецептов."
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-single-line  = fill("-", 230)
        v-underline    = fill("_", 230)
    .
    assign
        v-doc-code     = buf_fbr-doc.doc-code
        v-fact-date    = buf_fbr-doc.fact-date
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
if session :set-wait-state( "compiler" ) then.
output stream Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
    form header
        v-single-line format "X(119)" at 1 skip
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
    fill-temp-recipe:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.is-comp  = yes
    :
        find first buf_fbr-recipe no-lock
             where buf_fbr-recipe.doc-code     = buf_fbr-line.doc-code
               and buf_fbr-recipe.recipe-code  = buf_fbr-line.recipe-code
        no-error.
        if available buf_fbr-recipe
        and buf_fbr-recipe.recipe-type = 'производство':U
        then do:
            find first buf_temp_recipe no-lock
                 where buf_temp_recipe.recipe-code = buf_fbr-line.recipe-code
            no-error.
                if not available buf_temp_recipe
                then do:
                create buf_temp_recipe.
                assign
                    buf_temp_recipe.recipe-code     = buf_fbr-line.recipe-code
                    buf_temp_recipe.artic           = buf_fbr-line.artic
                    buf_temp_recipe.prod-type       = buf_fbr-line.prod-type
                    buf_temp_recipe.prod-code       = buf_fbr-line.prod-code
                    buf_temp_recipe.portion-weight  = buf_fbr-recipe.portion-weight
                    buf_temp_recipe.portion-qnty    = buf_fbr-recipe.portion-qnty
                    buf_temp_recipe.recipe-type     = buf_fbr-recipe.recipe-type
                    buf_temp_recipe.qnty            = buf_fbr-recipe.qnty
                .
                find first buf_goods no-lock
                     where buf_goods.artic      = buf_temp_recipe.artic
                       and buf_goods.prod-type  = buf_temp_recipe.prod-type
                       and buf_goods.prod-code  = buf_temp_recipe.prod-code
                no-error.
                if available buf_goods
                then do:
                    assign
                        buf_temp_recipe.gds-code = buf_goods.gds-code
                    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
 .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
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
                    assign
                        buf_temp_recipe.recipe-name     = substitute( "&1  &2", buf_goods.artic, buf_goods.gds-name )
                        buf_temp_recipe.goods-unit      = buf_goods.unit-base
                        buf_temp_recipe.sum-cost        = 0
                        buf_temp_recipe.sum-sale        = ( if not p-price-from-doc then gp-price-sale else buf_fbr-line.price-sale ) * buf_temp_recipe.qnty
                    .
                end.
            end.
        end.
    end.
    assign
        v-first-recipe = yes
    .
    for each buf_temp_recipe
    :
        v-rep-util:begin-report().
        v-rep-util:set-current-template("exe\op-1.xml").
        if v-first-recipe = no
        then do:
            page stream out-stream.
        end.
        assign
            v-first-recipe = no
        .
        run print-title in this-procedure (
              input buf_temp_recipe.recipe-code
            , input buf_fbr-doc.status_
        ).
        run print-header in this-procedure.
        run print-header-numbers (
              input v-single-line
            , input no
        ).
        view stream Out-Stream frame BottomFrame .
        assign
            v-line-counter    = 0
        .
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code      = buf_fbr-doc.doc-code
             and buf_fbr-line.is-comp       = no
             and buf_fbr-line.recipe-code   = buf_temp_recipe.recipe-code
        :
            assign
                v-line-counter  = v-line-counter + 1
                v-goods-artic   = string( buf_fbr-line.artic )
            .
            find first buf_goods no-lock
                 where buf_goods.artic      = buf_fbr-line.artic
                   and buf_goods.prod-type  = buf_fbr-line.prod-type
                   and buf_goods.prod-code  = buf_fbr-line.prod-code
            no-error.
            if available buf_goods
            then do:
                assign
                    v-goods-name    = buf_goods.gds-name
                .
            end.
            find first buf_fbr-recipe-gds no-lock
                 where buf_fbr-recipe-gds.doc-code    = buf_fbr-doc.doc-code
                   and buf_fbr-recipe-gds.recipe-code = buf_fbr-line.recipe-code
                   and buf_fbr-recipe-gds.prod-type   = buf_fbr-line.prod-type
                   and buf_fbr-recipe-gds.prod-code   = buf_fbr-line.prod-code
                   and buf_fbr-recipe-gds.artic       = buf_fbr-line.artic
            no-error.
            if available buf_fbr-recipe-gds
            then do:
                assign
                    v-mass  = ( if not available buf_goods
                                or buf_goods.gds-type = 'у':U
                                then 0
                                else buf_fbr-recipe-gds.brutto-qnty
                              )
                .
                if buf_fbr-recipe-gds.is-waste <> yes
                then do:
                    if not costprice then
                        do:
                            if p-price-from-doc then
                                v-cost = buf_fbr-line.price-sale.
                            else
                                do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
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
                                    v-cost = gp-price-sale.
                                end.
                        end.
                     else
                        v-cost = buf_fbr-line.price-rubl.
                    assign
                    v-sum                       = round(v-cost * v-mass , 2)
                    buf_temp_recipe.sum-cost    = buf_temp_recipe.sum-cost + v-sum
                    .
                end.
                else do:
                  assign
                    v-cost          = 0
                    v-sum           = 0
                  .
                end.
            end.
            run print-line in this-procedure (
                  input v-line-counter
                , input v-goods-artic
                , input v-goods-name
                , input buf_goods.gds-code
                , input v-mass
                , input v-cost
                , input v-sum
            ).
        end.
        assign
            buf_temp_recipe.sum-prc       = ( if costprice
                                              then ( buf_temp_recipe.sum-sale - buf_temp_recipe.sum-cost ) / buf_temp_recipe.sum-cost * 100
                                              else 0.0 )
        .
        v-rep-gen:add-element("buf_temp_recipe.sum-cost", string(buf_temp_recipe.sum-cost, ">>>,>>>,>>9.99")).
        v-rep-gen:add-element("buf_temp_recipe.sum-sale", string(buf_temp_recipe.sum-sale, ">>>,>>>,>>9.99")).
        v-rep-gen:add-element("buf_temp_recipe.portion-weight", string( buf_temp_recipe.portion-weight * 1000, ">>>,>>>,>>9.99" )).
        def var mark-on-1 as char no-undo.
        mark-on-1 = substitute( "Наценка &1%, руб. коп", string( buf_temp_recipe.sum-prc, "->>9.99") ).
        def var mark-on-2 as char no-undo.
        mark-on-2 = (if costprice then
                        string( buf_temp_recipe.sum-sale - buf_temp_recipe.sum-cost, "->>,>>>,>>9.99")
                    else
                        "0.00").
        v-rep-gen:add-element("mark-on-1", mark-on-1).
        v-rep-gen:add-element("mark-on-2", mark-on-2).
        put stream out-stream
        skip space(10)
            "|"
            v-single-line             format "X(117)"
            "|"
        skip space(10)
            "|" space (1)
             "Общая стоимость сырьевого набора  "
            ":"                                               at 10 + 80
            buf_temp_recipe.sum-cost                format ">>>,>>>,>>9.99" at right-field(10 + 119, 14)
            "|"                                               at 10 + 119
        skip space(10)
            "|"
            v-single-line             format "X(117)"
            "|"
        skip space(10)
            "|" space (1)
            mark-on-1
                                      format "X(74)"
            integer ( mark-on-2 ) format "->>,>>>,>>9.99" at right-field(10 + 119, 14)
            "|"                                               at 10 + 119
        skip space(10)
            "|"
            v-single-line   format "X(117)"
            "|"
        skip space(10)
            "|" space (1)
            "Цена продажи блюда, руб. коп"
            ":"                                               at 10 + 80
            buf_temp_recipe.sum-sale   format ">>>,>>>,>>9.99" at right-field(10 + 119, 14)
            "|"                                               at 10 + 119
        skip space(10)
            "|"
            v-single-line             format "X(117)"
            "|"
        skip space(10)
            "|" space (1)
            "Выход одного блюда в готовом виде, грамм"
            ":"                                               at 10 + 80
            string( buf_temp_recipe.portion-weight * 1000, ">>>,>>>,>>9.99" )
                                    format "X(14)"          at right-field(10 + 119, 14)
            "|"                                               at 10 + 119
        skip space(10)
            "|"
            v-single-line   format "X(117)"
            "|"
        skip space(10)
            "|" space(1)
            "Заведующий производством"
            ":"                                               at 10 + 70
            space(1) "подпись"
            ":"                                               at 10 + 80
            "|"                                               at 10 + 119
        skip space(10)
            "|"
            v-single-line   format "X(117)"
            "|"
        skip space(10)
            "|" space(1)
            "Калькуляцию составил"
            ":"                                               at 10 + 70
            space(1) "подпись"
            ":"                                               at 10 + 80
            "|"                                               at 10 + 119
        skip space(10)
            "|"
            v-single-line   format "X(117)"
            "|"
        skip space(10)
            "|" space (1)
            "УТВЕРЖДАЮ. Руководитель организации"
            ":"                                               at 10 + 70
            space(1) "подпись"
            ":"                                               at 10 + 80
            "|"                                               at 10 + 119
        skip space(10)
            v-single-line   format "X(119)"
        .
        hide stream out-stream frame BottomFrame .
        v-rep-util:end-report().
    end.
    output stream Out-Stream close.
if session :set-wait-state( "" ) then.
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
procedure print-header-numbers :
do
on error undo, return error
:
def input parameter p-single-line as char    no-undo.
def input parameter p-need-line   as logical no-undo.
    if p-need-line = yes
    then put stream out-stream
        skip
          string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( 10 + 119, 13)
        skip space(10)
          p-single-line format "X(119)"
    .
    put stream out-stream
        skip space(10)
          "|"
          "1"                  at center-field( 10 + 1, 10 + 5, 1)
          ":"                  at 10 + 5
          "2"                  at center-field( 10 + 5, 10 + 22, 1)
          ":"                  at 10 + 22
          "3"                  at center-field( 10 + 22, 10 + 70, 1)
          ":"                  at 10 + 70
          "4"                  at center-field( 10 + 70, 10 + 80, 1)
          ":"                  at 10 + 80
          "5"                  at center-field( 10 + 80, 10 + 90, 1)
          ":"                  at 10 + 90
          "6"                  at center-field( 10 + 90, 10 + 104, 1)
          ":"                  at 10 + 104
          "7"                  at center-field( 10 + 104, 10 + 119, 1)
          "|"                  at 10 + 119
        skip space(10)
          "|"
          p-single-line format "X(117)"
          "|"                  at 10 + 119
    .
end.
end procedure.
procedure write-itog :
do
on error undo, return error
:
    def input parameter p-type          as char no-undo.
    def input parameter p-in-mass       as decimal no-undo.
    def input parameter p-in-sum        as decimal no-undo.
    def input parameter p-out-norm-mass as decimal no-undo.
    def input parameter p-out-fact-mass as decimal no-undo.
    def input parameter p-out-fact-sum  as decimal no-undo.
    put stream Out-Stream
      skip space(10)
        v-single-line format "X(119)"
    .
end.
end procedure.
procedure check-all-weight-kg :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code       as character    no-undo.
define input parameter p-recipe-code            as character    no-undo.
define output parameter p-no-printable-recipe   as logical      no-undo.
    define variable v-is-weight     as logical init no    no-undo.
    define buffer  buf_fbr-line for ub.fbr-line.
    define buffer  buf_goods    for ub.goods.
    define buffer  buf_units    for ub.units.
        assign
            p-no-printable-recipe = no
        .
        for each buf_fbr-line
           where buf_fbr-line.doc-code     = p-fbr-doc-doc-code
             and buf_fbr-line.is-comp      = no
             and buf_fbr-line.recipe-code  = p-recipe-code
        :
            find first buf_goods
                 where buf_goods.artic      = buf_fbr-line.artic
                   and buf_goods.prod-type  = buf_fbr-line.prod-type
                   and buf_goods.prod-code  = buf_fbr-line.prod-code
            .
            if buf_goods.gds-type <> 'у':U
            then do:
                assign
                    v-is-weight = no
                .
                for each buf_units no-lock
                   where buf_units.type = 'вес':U
                :
                    if buf_goods.unit-base = buf_units.unit-name
                    then do:
                        assign
                            v-is-weight = yes
                        .
                    end.
                end.
                if v-is-weight = no
                then do:
                    assign
                        p-no-printable-recipe = yes
                    .
                    leave.
                end.
            end.
        end.
end.
end procedure.
procedure print-title :
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-fbr-doc-status as character        no-undo.
    define buffer buf_temp_recipe       for temp_recipe.
do
for buf_temp_recipe
on error undo, return error
:
    find first buf_temp_recipe
         where buf_temp_recipe.recipe-code = p-recipe-code
    .
    v-rep-gen:add-element("v-organization", v-organization).
    v-rep-gen:add-element("t-okpo", t-okpo).
    v-rep-gen:add-element("v-org-name", v-org-name).
    v-rep-gen:add-element("buf_temp_recipe.recipe-name", buf_temp_recipe.recipe-name).
    v-rep-gen:add-element("buf_temp_recipe.recipe-code", buf_temp_recipe.recipe-code).
    v-rep-gen:add-element("buf_temp_recipe.recipe-type", buf_temp_recipe.recipe-type).
    v-rep-gen:add-element("v-doc-code", v-doc-code).
    v-rep-gen:add-element("p-recipe-code", p-recipe-code).
    v-rep-gen:add-element("v-fact-date", if v-fact-date = ? then "" else string(v-fact-date)).
    v-rep-gen:add-element("p-fbr-doc-status", p-fbr-doc-status).
    def var tmp1 as char no-undo.
    tmp1 = ( if p-fbr-doc-status <> 'факт':U then substitute( " Статус: &1", p-fbr-doc-status ) else "":U ).
    def var tmp2 as char no-undo.
    tmp2 = (if CostPrice        =  no      then substitute( " Цены реализации" )              else "":U).
    v-rep-gen:add-element("status1", tmp1 + " " + tmp2).
    put stream Out-Stream
        skip
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( 10 + 119, 13)
        skip
        space(10) v-single-line format  "X(16)"             at 114
        skip
        space(10) "| "                                      at 114
                        'код':U                               at center-field(114, 10 + 119, length('код':U))
                        "|"                                       at 10 + 119
        skip
        space(10) "Форма по ОКУД" format "X(14)"            at right-field(114, 13)
                        "| "                                      at 114
                        "0330501"                                 at center-field(114, 10 + 119, 7)
                        "|"                                       at 10 + 119
        skip
        space(10) "Организация:               "
                v-organization                format "X(60)"
                "по ОКПО"                                      at right-field(114, 7)
                "|"                                            at 114
                trim(t-okpo)                  format "X(10)"   at right-field( 10 + 119, 10)
                "|"                                            at 10 + 119
        skip
        space(10) "Структурное подразделение: "
                        v-org-name              format "X(60)"
                        "|"                                       at 114
                        "|"                                       at 10 + 119
        skip
        space(10) "Вид деятельности по ОКДП"
                                                format "X(25)"    at right-field(114, 25)
                        "|"                                       at 114
                        "|"                                       at 10 + 119
        skip
        space(10) "Наименование блюда:        "
                        buf_temp_recipe.recipe-name           format "X(60)"
                        "|"                                       at 114
                        "|"                                       at 10 + 119
        skip
        space(10) "Номер блюда по сборнику рецептур"
                                                format "X(32)"    at right-field(114, 32)
                        "|"                                       at 114
                        buf_temp_recipe.recipe-code           format "X(8)"     at center-field(114, 10 + 119, 8)
                        "|"                                       at 10 + 119
        skip
        space(10) "Вид операции"          format "X(12)"    at right-field(114, 12)
                        "|"                                       at 114
                        buf_temp_recipe.recipe-type           format "X(12)"    at center-field(114, 10 + 119, 12)
                        "|"                                       at 10 + 119
        skip
        space(10) v-single-line           format  "X(16)"   at 114
    .
    put stream Out-Stream
        skip space(10)
            v-single-line   format  "X(46)"   at 50 + 1
        skip space(50)
            "|"
            "Номер"                           at  center-field(50, 50 + 20, 5)
            "|"                               at 50 + 20
            "Номер"                           at  center-field(50 + 20, 50 + 33, 5)
            "|"                               at 50 + 33
            "Дата"                            at  center-field(50 + 33, 50 + 46, 4)
            "|"                               at 50 + 46
        skip space(50)
            "|"
            "документа"     format "X(9)"     at  center-field(50, 50 + 20, 9)
            "|"                               at 50 + 20
            "рецепта"       format "X(7)"     at  center-field(50 + 20, 50 + 33, 7)
            "|"                               at 50 + 33
            "составления"   format "X(11)"    at  center-field(50 + 33, 50 + 46, 11)
            "|"                               at 50 + 46
        skip space(50)
            "|"
            v-single-line   format "X(44)"
            "|"  at 50 + 46
        skip
            space(25) "КАЛЬКУЛЯЦИОННАЯ КАРТОЧКА | "
            v-doc-code format "X(16)"
            " | "
            fill( " ", 10 - length( p-recipe-code ) ) + p-recipe-code
                            format "X(10)"            at  right-field( 50 + 33, 10)
            "| "                                      at 50 + 33
            v-fact-date     format "99/99/9999"
            "|"                                       at 50 + 46
            ( tmp1 ) format "X(15)"
            ( tmp2 ) format "X(16)"
        skip space(10)
            v-single-line   format  "X(46)"      at 50 + 1
    .
end.
end procedure.
procedure print-header :
do
on error undo, return error
:
        put stream Out-Stream
          skip space(10)
            v-single-line format "X(119)"
          skip space(10)
              "|"
              ":"                                  at 10 + 5
              "Продукты"                           at center-field( 10 + 5, 10 + 80, 8)
              ":"                                  at 10 + 80
              ":"                                  at 10 + 90
              ":"                                  at 10 + 104
            "|"                                    at 10 + 119
          skip space(10)
              "|"
              "Но-"
              ":"                                  at 10 + 5
              v-single-line format "X(74)"
              ":"                                  at 10 + 80
              "норма"                              at center-field( 10 + 80, 10 + 90, 5)
              ":"                                  at 10 + 90
              "цена,"                              at center-field( 10 + 90, 10 + 104, 5)
              ":"                                  at 10 + 104
              "сумма,"                             at center-field( 10 + 104, 10 + 119, 6)
              "|"                                  at 10 + 119
          skip space(10)
              "|"
              "мер"
              ":"                                  at 10 + 5
              "Артикул"                            at center-field( 10 + 5, 10 + 22, 7)
              ":"                                  at 10 + 22
              "Наименование"                       at center-field( 10 + 22, 10 + 70, 12)
              ":"                                  at 10 + 70
              "Код"                                at center-field( 10 + 70, 10 + 80, 3)
              ":"                                  at 10 + 80
              ":"                                  at 10 + 90
              "руб.коп"            at center-field( 10 + 90, 10 + 104, 7)
              ":"                                  at 10 + 104
              "руб.коп"            at center-field( 10 + 104, 10 + 119, 7)
              "|"                                  at 10 + 119
          skip space(10)
            "|"
            v-single-line format "X(117)"
            "|" at 10 + 119
        .
end.
end procedure.
procedure print-line :
define input parameter p-line-counter as integer          no-undo.
define input parameter p-goods-artic  as character        no-undo.
define input parameter p-goods-name   as character        no-undo.
define input parameter p-bar-code     as character        no-undo.
define input parameter p-mass         as decimal          no-undo.
define input parameter p-cost         as decimal          no-undo.
define input parameter p-sum          as decimal          no-undo.
do
on error undo, return error
:
    v-rep-gen:start-element("table").
    v-rep-gen:add-element("p-line-counter", string(p-line-counter, ">>9")).
    v-rep-gen:add-element("p-goods-artic", p-goods-artic).
    v-rep-gen:add-element("p-goods-name", p-goods-name).
    v-rep-gen:add-element("p-bar-code", string(p-bar-code, "X(9)")).
    v-rep-gen:add-element("p-mass", string(p-mass, ">,>>9.999")).
    v-rep-gen:add-element("p-cost", string(p-cost, ">>,>>>,>>9.99")).
    v-rep-gen:add-element("p-sum", string(p-sum, ">>>,>>>,>>9.99")).
    v-rep-gen:end-element("table").
    put stream out-stream
        skip space(10)
            "|"
            p-line-counter    format ">>9"
            ":"                                  at 10 + 5
            p-goods-artic     format "X(16)"
            ":"                                  at 10 + 22
            p-goods-name      format "X(47)"
            ":"                                  at 10 + 70
            p-bar-code        format "X(9)"
            ":"                                  at 10 + 80
            p-mass            format ">,>>9.999"
            ":"                                  at 10 + 90
            p-cost            format ">>,>>>,>>9.99"
            ":"                                  at 10 + 104
            p-sum             format ">>>,>>>,>>9.99"
            "|"                                  at 10 + 119
    .
end.
end procedure.
