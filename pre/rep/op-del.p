block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.
define input parameter p-print-in-rubl      as logical          no-undo.
define input parameter p-print-details      as logical          no-undo.
define input parameter p-fat                as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-del.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/op-del.p $":U .
define variable vss-description as character no-undo init "Акт отклонения.".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrcode-doc-code no-undo
    field rec-type      as character
    field doc-code      as character
    field obj-type      as character
    field obj-code      as integer
    field cli-type      as character
    field cli-code      as integer
    field ext-doc-type  as character
    field doc-type      as character
    field order         as integer
    index pi is primary unique rec-type doc-code
    index od order
.
procedure fbrcode-gen-recipe-code :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-recipe-code       as character    no-undo.
    assign
        p-recipe-code   = string( next-value( s-recipe, ub ) )
                            + "-"
                            + trim( string( p-obj-code, ">>>>9" ) )
                            + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    .
end.
end procedure.
procedure fbrcode-is-from-object :
do
on error undo, return error
:
define input parameter p-doc-code           as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-is-from-object    as logical      no-undo.
    if num-entries( p-doc-code, "-" ) < 2
    or entry( 2, p-doc-code, "-" ) <> trim (string (p-obj-code, ">>>>9"))
                                    + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    then do:
        assign
            p-is-from-object = no
        .
    end.
    else do:
        assign
            p-is-from-object = yes
        .
    end.
end.
end procedure.
procedure fbrcode-trn-doc :
do
on error undo, return error
:
    define input parameter p-out-doc-type       as character    no-undo.
    define input parameter p-out-code           as character    no-undo.
    define input parameter p-trn-doc-out-type   as character    no-undo.
    define output parameter p-trn-doc-doc-code  as character   no-undo.
    case p-out-doc-type:
        when 'производство':U
        then do:
            case p-trn-doc-out-type :
                when 'рас':U
                then do:
                    assign
                        p-trn-doc-doc-code = p-out-code
                    .
                end.
                when 'при':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "=" )
                    .
                end.
                when 'спи':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "*" )
                    .
                end.
                otherwise do:
                    assign
                        p-trn-doc-doc-code = ""
                    .
                    undo, return error "Не может быть обработан тип складского документа '"
                                        + p-trn-doc-out-type + "' во входных параметрах".
                end.
            end case.
        end.
        otherwise do:
            assign
                p-trn-doc-doc-code = ""
            .
            undo, return error "Не может быть обработан тип внешнего документа '"
                                + p-out-doc-type + "' во входных параметрах".
        end.
    end case.
end.
end procedure.
procedure fbrcode-fill-fbr-by-sale-or-pln :
define input parameter p-main-doc-code      as character        no-undo.
    define variable v-order    as integer      no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_fbr-doc
  , buf_trn-doc
  , buf_temp_fbrcode-doc-code
on error undo, return error
:
    for each buf_temp_fbrcode-doc-code
    on error undo, return error
    :
        delete buf_temp_fbrcode-doc-code.
    end.
    assign
        v-order = 0
    .
    for each buf_fbr-doc no-lock
       where buf_fbr-doc.out-code = p-main-doc-code
    on error undo, return error
    :
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.rec-type      = 'производство':U
            buf_temp_fbrcode-doc-code.doc-code      = buf_fbr-doc.doc-code
            buf_temp_fbrcode-doc-code.ext-doc-type  = "":U
            buf_temp_fbrcode-doc-code.obj-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_fbr-doc.doc-type
        .
        for each buf_trn-doc no-lock
           where buf_trn-doc.out-code = buf_fbr-doc.doc-code
        by buf_trn-doc.fact-order
        on error undo, return error
        :
            if buf_trn-doc.ext-doc-type = 'em':U
            or buf_trn-doc.ext-doc-type = 'im':U
            or buf_trn-doc.ext-doc-type = 'wm':U
            or buf_trn-doc.ext-doc-type = 'ev':U
            then do:
                assign
                    v-order = v-order + 1
                .
                create buf_temp_fbrcode-doc-code.
                assign
                    buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
                    buf_temp_fbrcode-doc-code.rec-type      = 'скл':U
                    buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
                    buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
                    buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
                    buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
                    buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
                    buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
                    buf_temp_fbrcode-doc-code.order         = v-order
                .
            end.
        end.
        assign
            v-order  = v-order + 1
        .
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.rec-type = 'производство':U
               and buf_temp_fbrcode-doc-code.doc-code = buf_fbr-doc.doc-code
        .
        assign
            buf_temp_fbrcode-doc-code.order = v-order
        .
    end.
    for each buf_trn-doc no-lock
       where buf_trn-doc.out-code = p-main-doc-code
    by buf_trn-doc.fact-order
    on error undo, return error
    :
        assign
            v-order = v-order + 1
        .
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
            buf_temp_fbrcode-doc-code.rec-type      = 'маг':U
            buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
            buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
            buf_temp_fbrcode-doc-code.order         = v-order
        .
    end.
end.
end procedure.
procedure fbrcode-get-final-doc :
define input parameter p-main-doc-code      as character        no-undo.
define output parameter p-income-doc-code   as character        no-undo.
    define variable v-main-obj-type    as character    no-undo.
    define variable v-main-obj-code    as integer      no-undo.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_trn-doc
on error undo, return error
:
    run fbrcode-fill-fbr-by-sale-or-pln in this-procedure (
        input p-main-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-main-doc-code
    .
    assign
        v-main-obj-type = buf_trn-doc.obj-type
        v-main-obj-code = buf_trn-doc.obj-code
    .
    find first buf_temp_fbrcode-doc-code
         where buf_temp_fbrcode-doc-code.ext-doc-type = 'ev':U
           and buf_temp_fbrcode-doc-code.cli-type     = v-main-obj-type
           and buf_temp_fbrcode-doc-code.cli-code     = v-main-obj-code
    no-error.
    if available buf_temp_fbrcode-doc-code
    then do:
        find first buf_trn-doc no-lock
             where buf_trn-doc.out-code     = buf_temp_fbrcode-doc-code.doc-code
               and buf_trn-doc.ext-doc-type = 'iv':U
        .
        assign
            p-income-doc-code = buf_trn-doc.doc-code
        .
    end.
    else do:
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.ext-doc-type = 'im':U
               and buf_temp_fbrcode-doc-code.obj-type     = v-main-obj-type
               and buf_temp_fbrcode-doc-code.obj-code     = v-main-obj-code
        no-error.
        if available buf_temp_fbrcode-doc-code
        then do:
            assign
                p-income-doc-code = buf_temp_fbrcode-doc-code.doc-code
            .
        end.
        else do:
            assign
                p-income-doc-code = "":U
            .
        end.
    end.
end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character
    index pi is primary unique
        str-key
.
define variable v-p-fmt-3-str-key    as integer      no-undo.
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
        v-p-fmt-3-str-key   = 0
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
            v-p-fmt-3-str-key = v-p-fmt-3-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-3-str-key
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info5 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
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
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
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
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
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
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
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
        vss-include-info5 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrrep-goods no-undo
    field gds-code                      as integer
    field artic                         as character
    field prod-type                     as character
    field prod-code                     as integer
    field gds-name                      as character
    field is-not-office                 as logical
    field is-waste                      as logical
    field unit-base                     as character
    field fact-qnty                     as decimal
    field write-off-qnty                as decimal
    field write-off-rsrv-qnty           as decimal
    field sum-write-off-rsrv-rubl       as decimal
    field sum-write-off-rsrv-base       as decimal
    field sum-write-off-rsrv-vat-rubl   as decimal
    field sum-write-off-rsrv-vat-base   as decimal
    field cost-rubl                     as decimal
    field cost-base                     as decimal
    field sum-cost-rubl                 as decimal
    field sum-cost-base                 as decimal
    field sum-vat-cost-rubl             as decimal
    field sum-vat-cost-base             as decimal
    field vat-cost-rubl                 as decimal
    field vat-cost-base                 as decimal
    field income-qnty                   as decimal
    field income-rsrv-qnty              as decimal
    field cost-income-rubl              as decimal
    field cost-income-base              as decimal
    field sum-cost-income-rubl          as decimal
    field sum-cost-income-base          as decimal
    field sum-vat-cost-income-rubl      as decimal
    field sum-vat-cost-income-base      as decimal
    field vat-cost-income-rubl          as decimal
    field vat-cost-income-base          as decimal
    field price-sale                    as decimal
    field deleted                       as logical
    index pi is primary unique gds-code
    index ar is unique artic prod-type prod-code
    index dd deleted
    index ws is-waste
.
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        vss-include-info14 skip
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
        vss-include-info14 skip
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
        vss-include-info14 skip
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
procedure fbrrep-fill-qnty-and-prices :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code  as character    no-undo.
    define variable v-gds-code  as integer       no-undo.
    define variable v-gds-name  as character     no-undo.
    define variable v-sign      as decimal       no-undo.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-doc-code
    on error undo, return error
    :
        find first buf_temp_fbrrep-goods
             where buf_temp_fbrrep-goods.artic     = buf_fbr-line.artic
               and buf_temp_fbrrep-goods.prod-type = buf_fbr-line.prod-type
               and buf_temp_fbrrep-goods.prod-code = buf_fbr-line.prod-code
        use-index ar
        no-error.
        if not available buf_temp_fbrrep-goods
        then do:
            create buf_temp_fbrrep-goods.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-code
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-name
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,input  'gds-goods=request':u
  ,output buf_temp_fbrrep-goods.is-not-office
  )  .
            assign
                buf_temp_fbrrep-goods.gds-code             = v-gds-code
                buf_temp_fbrrep-goods.artic                = buf_fbr-line.artic
                buf_temp_fbrrep-goods.prod-type            = buf_fbr-line.prod-type
                buf_temp_fbrrep-goods.prod-code            = buf_fbr-line.prod-code
                buf_temp_fbrrep-goods.gds-name             = v-gds-name
                buf_temp_fbrrep-goods.is-waste             = buf_fbr-line.is-waste
                buf_temp_fbrrep-goods.fact-qnty            = 0
                buf_temp_fbrrep-goods.write-off-rsrv-qnty  = 0
                buf_temp_fbrrep-goods.write-off-qnty       = 0
                buf_temp_fbrrep-goods.income-qnty          = 0
                buf_temp_fbrrep-goods.income-rsrv-qnty     = 0
                buf_temp_fbrrep-goods.cost-rubl            = 0
                buf_temp_fbrrep-goods.cost-base            = 0
                buf_temp_fbrrep-goods.sum-cost-rubl        = 0
                buf_temp_fbrrep-goods.sum-cost-base        = 0
                buf_temp_fbrrep-goods.vat-cost-rubl        = 0
                buf_temp_fbrrep-goods.vat-cost-base        = 0
                buf_temp_fbrrep-goods.sum-vat-cost-rubl    = 0
                buf_temp_fbrrep-goods.sum-vat-cost-base    = 0
                buf_temp_fbrrep-goods.price-sale           = buf_fbr-line.price-sale
                buf_temp_fbrrep-goods.deleted              = no
            .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  v-gds-code
  ,output buf_temp_fbrrep-goods.unit-base
  )  .
        end.
        case buf_fbr-line.trn-type
        :
            when 'при':U
            then do:
                assign
                    v-sign                                  = 1
                    buf_temp_fbrrep-goods.income-qnty       = buf_temp_fbrrep-goods.income-qnty     + buf_fbr-line.fact-qnty
                .
                if buf_fbr-line.rsrv-qnty <> ?
                then do:
                    assign
                        buf_temp_fbrrep-goods.income-rsrv-qnty = buf_temp_fbrrep-goods.income-rsrv-qnty   + buf_fbr-line.rsrv-qnty
                    .
                end.
            end.
            when 'спи':U
            then do:
                assign
                    v-sign                                  = -1
                    buf_temp_fbrrep-goods.write-off-qnty    = buf_temp_fbrrep-goods.write-off-qnty  + buf_fbr-line.fact-qnty
                .
                if buf_fbr-line.rsrv-qnty <> ?
                then do:
                    assign
                        buf_temp_fbrrep-goods.write-off-rsrv-qnty = buf_temp_fbrrep-goods.write-off-rsrv-qnty   + buf_fbr-line.rsrv-qnty
                    .
                end.
            end.
        end case.
        assign
            buf_temp_fbrrep-goods.sum-cost-rubl        = buf_temp_fbrrep-goods.sum-cost-rubl     + v-sign * buf_fbr-line.price-sum-rubl
            buf_temp_fbrrep-goods.sum-cost-base        = buf_temp_fbrrep-goods.sum-cost-base     + v-sign * buf_fbr-line.price-sum-base
            buf_temp_fbrrep-goods.sum-vat-cost-rubl    = buf_temp_fbrrep-goods.sum-vat-cost-rubl + v-sign * buf_fbr-line.price-sum-vat-rubl
            buf_temp_fbrrep-goods.sum-vat-cost-base    = buf_temp_fbrrep-goods.sum-vat-cost-base + v-sign * buf_fbr-line.price-sum-vat-base
        .
    end.
    run test-temp-tables in this-procedure .
end.
end procedure.
procedure fbrrep-fill-for-fbr-actp :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code  as character    no-undo.
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods.
    define buffer buf_fbr-line          for ub.fbr-line.
    run fbrrep-fill-qnty-and-prices in this-procedure (
        input p-fbr-doc-doc-code
    ).
    for each buf_temp_fbrrep-goods
    :
        assign
            buf_temp_fbrrep-goods.sum-cost-rubl     = 0
            buf_temp_fbrrep-goods.sum-cost-base     = 0
            buf_temp_fbrrep-goods.sum-vat-cost-rubl = 0
            buf_temp_fbrrep-goods.sum-vat-cost-base = 0
            buf_temp_fbrrep-goods.cost-rubl     = 0
            buf_temp_fbrrep-goods.cost-base     = 0
            buf_temp_fbrrep-goods.vat-cost-rubl = 0
            buf_temp_fbrrep-goods.vat-cost-base = 0
        .
        if buf_temp_fbrrep-goods.income-qnty = 0
        or buf_temp_fbrrep-goods.write-off-qnty = 0
        then do:
            assign
                buf_temp_fbrrep-goods.deleted   = yes
                buf_temp_fbrrep-goods.fact-qnty = 0
            .
        end.
        else do:
            if buf_temp_fbrrep-goods.income-qnty <= buf_temp_fbrrep-goods.write-off-qnty
            then do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.income-qnty
                .
                for each buf_fbr-line no-lock
                   where buf_fbr-line.doc-code  = p-fbr-doc-doc-code
                     and buf_fbr-line.artic     = buf_temp_fbrrep-goods.artic
                     and buf_fbr-line.prod-type = buf_temp_fbrrep-goods.prod-type
                     and buf_fbr-line.prod-code = buf_temp_fbrrep-goods.prod-code
                     and buf_fbr-line.trn-type  = 'при':U
                :
                    assign
                        buf_temp_fbrrep-goods.sum-cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     + buf_fbr-line.price-sum-rubl
                        buf_temp_fbrrep-goods.sum-cost-base     = buf_temp_fbrrep-goods.sum-cost-base     + buf_fbr-line.price-sum-base
                        buf_temp_fbrrep-goods.sum-vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl + buf_fbr-line.price-sum-vat-rubl
                        buf_temp_fbrrep-goods.sum-vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base + buf_fbr-line.price-sum-vat-base
                    .
                end.
                assign
                    buf_temp_fbrrep-goods.cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.cost-base     = buf_temp_fbrrep-goods.sum-cost-base     / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base / buf_temp_fbrrep-goods.fact-qnty
                .
            end.
            else do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.write-off-qnty
                .
                for each buf_fbr-line no-lock
                   where buf_fbr-line.doc-code  = p-fbr-doc-doc-code
                     and buf_fbr-line.artic     = buf_temp_fbrrep-goods.artic
                     and buf_fbr-line.prod-type = buf_temp_fbrrep-goods.prod-type
                     and buf_fbr-line.prod-code = buf_temp_fbrrep-goods.prod-code
                     and buf_fbr-line.trn-type  = 'спи':U
                :
                    assign
                        buf_temp_fbrrep-goods.sum-cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     + buf_fbr-line.price-sum-rubl
                        buf_temp_fbrrep-goods.sum-cost-base     = buf_temp_fbrrep-goods.sum-cost-base     + buf_fbr-line.price-sum-base
                        buf_temp_fbrrep-goods.sum-vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl + buf_fbr-line.price-sum-vat-rubl
                        buf_temp_fbrrep-goods.sum-vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base + buf_fbr-line.price-sum-vat-base
                    .
                end.
                assign
                    buf_temp_fbrrep-goods.cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.cost-base     = buf_temp_fbrrep-goods.sum-cost-base     / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base / buf_temp_fbrrep-goods.fact-qnty
                .
            end.
        end.
    end.
    for each buf_temp_fbrrep-goods
       where buf_temp_fbrrep-goods.deleted = yes
    on error undo, return error
    :
        delete buf_temp_fbrrep-goods.
    end.
    run test-temp-tables in this-procedure .
end.
end procedure.
procedure fbrrep-fill-for-op-del :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-db-remote          as logical          no-undo.
    define variable v-serv-code as character    no-undo.
    define variable v-in-code   as character    no-undo.
    define variable v-out-code  as character    no-undo.
    define variable v-trn-qnty  as decimal       no-undo.
    define variable v-sign      as decimal       no-undo.
    define variable v-qnty      as decimal       no-undo.
    define buffer buf_fbr-doc           for ub.fbr-doc.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_goods             for ub.goods .
    define buffer buf_doc-line          for ub.doc-line .
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods .
    run fbrrep-fill-qnty-and-prices in this-procedure (
        input p-fbr-doc-doc-code
    ).
    for each buf_temp_fbrrep-goods
    on error undo, return error
    :
        if buf_temp_fbrrep-goods.income-qnty <> 0
        or buf_temp_fbrrep-goods.write-off-qnty <> 0
        then do:
            assign
                v-qnty  = ( buf_temp_fbrrep-goods.write-off-qnty - buf_temp_fbrrep-goods.income-qnty )
            .
            if v-qnty = 0
            then do:
                find first buf_fbr-line no-lock
                     where buf_fbr-line.doc-code    = p-fbr-doc-doc-code
                       and buf_fbr-line.artic       = buf_temp_fbrrep-goods.artic
                       and buf_fbr-line.prod-type   = buf_temp_fbrrep-goods.prod-type
                       and buf_fbr-line.prod-code   = buf_temp_fbrrep-goods.prod-code
                       and buf_fbr-line.fact-qnty   <> 0
                no-error.
                if available buf_fbr-line
                then do:
                    assign
                        buf_temp_fbrrep-goods.cost-rubl     = buf_fbr-line.price-rubl
                        buf_temp_fbrrep-goods.cost-base     = buf_fbr-line.price-base
                        buf_temp_fbrrep-goods.vat-cost-rubl = buf_fbr-line.price-sum-vat-rubl / buf_fbr-line.fact-qnty
                        buf_temp_fbrrep-goods.vat-cost-base = buf_fbr-line.price-sum-vat-base / buf_fbr-line.fact-qnty
                    .
                end.
                else do:
                    assign
                        buf_temp_fbrrep-goods.cost-rubl     = 0
                        buf_temp_fbrrep-goods.cost-base     = 0
                        buf_temp_fbrrep-goods.vat-cost-rubl = 0
                        buf_temp_fbrrep-goods.vat-cost-base = 0
                    .
                end.
            end.
            else do:
                assign
                    buf_temp_fbrrep-goods.cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     / v-qnty
                    buf_temp_fbrrep-goods.cost-base     = buf_temp_fbrrep-goods.sum-cost-base     / v-qnty
                    buf_temp_fbrrep-goods.vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl / v-qnty
                    buf_temp_fbrrep-goods.vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base / v-qnty
                .
            end.
        end.
        else do:
            assign
                buf_temp_fbrrep-goods.cost-rubl     = 0
                buf_temp_fbrrep-goods.cost-base     = 0
                buf_temp_fbrrep-goods.vat-cost-rubl = 0
                buf_temp_fbrrep-goods.vat-cost-base = 0
            .
        end.
    end.
    for each buf_temp_fbrrep-goods
    :
        if buf_temp_fbrrep-goods.is-waste = yes
        then do:
            assign
                buf_temp_fbrrep-goods.deleted = yes
            .
        end.
        else do:
            if buf_temp_fbrrep-goods.write-off-qnty <> 0
            and buf_temp_fbrrep-goods.income-qnty <> 0
            then do:
                if buf_temp_fbrrep-goods.write-off-qnty = buf_temp_fbrrep-goods.income-qnty
                then do:
                    assign
                        buf_temp_fbrrep-goods.deleted = yes
                    .
                end.
                else do:
                    if buf_temp_fbrrep-goods.write-off-qnty > buf_temp_fbrrep-goods.income-qnty
                    then do:
                        assign
                            buf_temp_fbrrep-goods.write-off-qnty    = buf_temp_fbrrep-goods.write-off-qnty - buf_temp_fbrrep-goods.income-qnty
                            buf_temp_fbrrep-goods.income-qnty       = 0
                        .
                    end.
                    else do:
                        assign
                            buf_temp_fbrrep-goods.income-qnty       = buf_temp_fbrrep-goods.income-qnty - buf_temp_fbrrep-goods.write-off-qnty
                            buf_temp_fbrrep-goods.write-off-qnty    = 0
                        .
                    end.
                end.
            end.
        end.
    end.
    for each buf_temp_fbrrep-goods
       where buf_temp_fbrrep-goods.deleted = yes
    on error undo, return error
    :
        delete buf_temp_fbrrep-goods.
    end.
    run test-temp-tables in this-procedure .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-doc-code
    .
    assign
        v-out-code = p-fbr-doc-doc-code
    .
    run doc-code in this-procedure (
          input  "pair"
        , input  buf_fbr-doc.obj-type
        , input  buf_fbr-doc.obj-code
        , input  v-out-code
        , output v-in-code
    ) no-error.
    if error-status:error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка вычисления номера приходной накладной."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run doc-code in this-procedure (
          input  "trio"
        , input  buf_fbr-doc.obj-type
        , input  buf_fbr-doc.obj-code
        , input  v-in-code
        , output v-serv-code
    ) no-error.
    if error-status:error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка вычисления номера накладной расхода."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    for each buf_temp_fbrrep-goods
    on error undo, return error
    :
        if buf_temp_fbrrep-goods.income-qnty > buf_temp_fbrrep-goods.write-off-qnty
        then do:
            find first buf_doc-line no-lock
                 where buf_doc-line.doc-code  = v-in-code
                   and buf_doc-line.artic     = buf_temp_fbrrep-goods.artic
                   and buf_doc-line.prod-type = buf_temp_fbrrep-goods.prod-type
                   and buf_doc-line.prod-code = buf_temp_fbrrep-goods.prod-code
            no-error.
            if available buf_doc-line
            then do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.income-qnty - buf_doc-line.doc-qnty
                .
            end.
            else do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.income-qnty
                .
            end.
        end.
        else do:
            if buf_temp_fbrrep-goods.is-not-office = no
            then do:
                find first buf_doc-line no-lock
                     where buf_doc-line.doc-code  = v-serv-code
                       and buf_doc-line.artic     = buf_temp_fbrrep-goods.artic
                       and buf_doc-line.prod-type = buf_temp_fbrrep-goods.prod-type
                       and buf_doc-line.prod-code = buf_temp_fbrrep-goods.prod-code
                no-error.
            end.
            else do:
                find first buf_doc-line no-lock
                     where buf_doc-line.doc-code  = v-out-code
                       and buf_doc-line.artic     = buf_temp_fbrrep-goods.artic
                       and buf_doc-line.prod-type = buf_temp_fbrrep-goods.prod-type
                       and buf_doc-line.prod-code = buf_temp_fbrrep-goods.prod-code
                no-error.
            end.
            if available buf_doc-line
            then do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.write-off-qnty - buf_doc-line.doc-qnty
                .
            end.
            else do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.write-off-qnty
                .
            end.
        end.
        if available buf_doc-line
        then do:
            define variable v-void              as decimal       no-undo.
            define variable v-fact-qnty         as decimal       no-undo.
            define variable v-sum-base          as decimal       no-undo.
            define variable v-sum-rubl          as decimal       no-undo.
            define variable v-vat-base          as decimal       no-undo.
            define variable v-vat-rubl          as decimal       no-undo.
            define variable v-slt-base          as decimal       no-undo.
            define variable v-slt-rubl          as decimal       no-undo.
            define variable v-road-tax-base     as decimal       no-undo.
            define variable v-road-tax-rubl     as decimal       no-undo.
            define variable v-transport-base    as decimal       no-undo.
            define variable v-transport-rubl    as decimal       no-undo.
            define variable v-other-base        as decimal       no-undo.
            define variable v-other-rubl        as decimal       no-undo.
            define variable v-excise-base       as decimal       no-undo.
            define variable v-excise-rubl       as decimal       no-undo.
            run r-cost in this-procedure (
                  input buf_doc-line.doc-code
                , input buf_doc-line.artic
                , input buf_doc-line.prod-type
                , input buf_doc-line.prod-code
                , output v-fact-qnty
                , output v-void
                , output v-void
                , output v-sum-base
                , output v-sum-rubl
                , output v-vat-base
                , output v-vat-rubl
                , output v-slt-base
                , output v-slt-rubl
                , output v-road-tax-base
                , output v-road-tax-rubl
                , output v-transport-base
                , output v-transport-rubl
                , output v-other-base
                , output v-other-rubl
                , output v-excise-base
                , output v-excise-rubl
            ).
            assign
                v-sign = ( if v-fact-qnty >= 0 then 1 else -1 )
            .
            assign
                v-sum-rubl = v-sum-rubl - v-vat-rubl - v-slt-rubl - v-road-tax-rubl - v-transport-rubl - v-other-rubl - v-excise-rubl
                v-sum-base = v-sum-base - v-vat-base - v-slt-base - v-road-tax-base - v-transport-base - v-other-base - v-excise-base
                v-sum-rubl = v-sum-rubl   * v-sign
                v-sum-base = v-sum-base   * v-sign
                v-vat-rubl = v-vat-rubl   * v-sign
                v-vat-base = v-vat-base   * v-sign
                v-fact-qnty = v-fact-qnty * v-sign
            .
            output to "fbrrep.txt" append .
            put unformatted skip(1) v-fact-qnty "   " v-sum-rubl "    " v-vat-rubl.
            output close.
            assign
                buf_temp_fbrrep-goods.sum-cost-rubl     = absolute( buf_temp_fbrrep-goods.cost-rubl     * v-fact-qnty ) - absolute( v-sum-rubl )
                buf_temp_fbrrep-goods.sum-cost-base     = absolute( buf_temp_fbrrep-goods.cost-base     * v-fact-qnty ) - absolute( v-sum-base )
                buf_temp_fbrrep-goods.sum-vat-cost-rubl = absolute( buf_temp_fbrrep-goods.vat-cost-rubl * v-fact-qnty ) - absolute( v-vat-rubl )
                buf_temp_fbrrep-goods.sum-vat-cost-base = absolute( buf_temp_fbrrep-goods.vat-cost-base * v-fact-qnty ) - absolute( v-vat-base )
            .
            if buf_temp_fbrrep-goods.fact-qnty          = 0
            and buf_temp_fbrrep-goods.sum-cost-rubl     = 0
            and buf_temp_fbrrep-goods.sum-cost-base     = 0
            and buf_temp_fbrrep-goods.sum-vat-cost-rubl = 0
            and buf_temp_fbrrep-goods.sum-vat-cost-base = 0
            then do:
                assign
                    buf_temp_fbrrep-goods.deleted = yes
                .
            end.
        end.
    end.
    for each buf_temp_fbrrep-goods
       where buf_temp_fbrrep-goods.deleted = yes
    on error undo, return error
    :
        delete buf_temp_fbrrep-goods.
    end.
    run test-temp-tables in this-procedure .
end.
end procedure.
procedure test-temp-tables :
do
on error undo, return error
:
    define variable v-str   as character     no-undo.
    assign
        v-str = ""
    .
    for each temp_fbrrep-goods
    :
        assign
            v-str = v-str
                + chr(10) + temp_fbrrep-goods.artic
                + chr(9) + string( temp_fbrrep-goods.income-qnty )
                + chr(9) + string( temp_fbrrep-goods.write-off-qnty )
                + chr(9) + string( temp_fbrrep-goods.cost-rubl )
                + chr(9) + string( temp_fbrrep-goods.vat-cost-rubl )
                + chr(9) + string( temp_fbrrep-goods.sum-cost-rubl )
                + chr(9) + string( temp_fbrrep-goods.sum-vat-cost-rubl )
                + chr(9) + string( temp_fbrrep-goods.gds-name )
        .
    end.
    output to "fbrrep.txt" append .
    put unformatted skip(2) v-str.
    output close.
end.
end procedure.
procedure fbrrep-test-fbrdoc-for-fact :
do
on error undo, return error
:
define output parameter p-have-error        as logical      no-undo.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods.
    for each buf_temp_fbrrep-goods
    on error undo, return error
    :
    end.
end.
end procedure.
procedure fbrrep-fill-qnty-and-prices-gds :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
    define variable v-sign      as decimal       no-undo.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_goods             for ub.goods.
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_temp_fbrrep-goods
         where buf_temp_fbrrep-goods.artic     = buf_goods.artic
           and buf_temp_fbrrep-goods.prod-type = buf_goods.prod-type
           and buf_temp_fbrrep-goods.prod-code = buf_goods.prod-code
    use-index ar
    no-error.
    if available buf_temp_fbrrep-goods
    then do:
        delete buf_temp_fbrrep-goods.
    end.
    create buf_temp_fbrrep-goods.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'gds-goods=request':u
  ,output buf_temp_fbrrep-goods.is-not-office
  )  .
    assign
        buf_temp_fbrrep-goods.gds-code             = p-gds-code
        buf_temp_fbrrep-goods.artic                = buf_goods.artic
        buf_temp_fbrrep-goods.prod-type            = buf_goods.prod-type
        buf_temp_fbrrep-goods.prod-code            = buf_goods.prod-code
        buf_temp_fbrrep-goods.gds-name             = buf_goods.gds-name
        buf_temp_fbrrep-goods.is-waste             = no
        buf_temp_fbrrep-goods.fact-qnty            = 0
        buf_temp_fbrrep-goods.write-off-rsrv-qnty  = 0
        buf_temp_fbrrep-goods.write-off-qnty       = 0
        buf_temp_fbrrep-goods.income-qnty          = 0
        buf_temp_fbrrep-goods.income-rsrv-qnty     = 0
        buf_temp_fbrrep-goods.cost-rubl            = 0
        buf_temp_fbrrep-goods.cost-base            = 0
        buf_temp_fbrrep-goods.sum-cost-rubl        = 0
        buf_temp_fbrrep-goods.sum-cost-base        = 0
        buf_temp_fbrrep-goods.vat-cost-rubl        = 0
        buf_temp_fbrrep-goods.vat-cost-base        = 0
        buf_temp_fbrrep-goods.sum-vat-cost-rubl    = 0
        buf_temp_fbrrep-goods.sum-vat-cost-base    = 0
        buf_temp_fbrrep-goods.price-sale           = 0
        buf_temp_fbrrep-goods.deleted              = no
    .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  p-gds-code
  ,output buf_temp_fbrrep-goods.unit-base
  )  .
    for each buf_fbr-line no-lock
       where buf_fbr-line.prod-type = buf_goods.prod-type
         and buf_fbr-line.prod-code = buf_goods.prod-code
         and buf_fbr-line.artic     = buf_goods.artic
         and buf_fbr-line.doc-code  = p-fbr-doc-doc-code
    on error undo, return error
    :
        case buf_fbr-line.trn-type
        :
            when 'при':U
            then do:
                assign
                    v-sign                                          = 1
                    buf_temp_fbrrep-goods.income-qnty               = buf_temp_fbrrep-goods.income-qnty                 + buf_fbr-line.fact-qnty
                    buf_temp_fbrrep-goods.sum-cost-income-rubl      = buf_temp_fbrrep-goods.sum-cost-income-rubl        + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-rubl        else 0 )
                    buf_temp_fbrrep-goods.sum-cost-income-base      = buf_temp_fbrrep-goods.sum-cost-income-base        + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-base        else 0 )
                    buf_temp_fbrrep-goods.sum-vat-cost-income-rubl  = buf_temp_fbrrep-goods.sum-vat-cost-income-rubl    + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-rubl    else 0 )
                    buf_temp_fbrrep-goods.sum-vat-cost-income-base  = buf_temp_fbrrep-goods.sum-vat-cost-income-base    + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-base    else 0 )
                .
                if buf_fbr-line.rsrv-qnty <> ?
                then do:
                    assign
                        buf_temp_fbrrep-goods.income-rsrv-qnty = buf_temp_fbrrep-goods.income-rsrv-qnty   + buf_fbr-line.rsrv-qnty
                    .
                end.
            end.
            when 'спи':U
            then do:
                assign
                    v-sign                                  = -1
                    buf_temp_fbrrep-goods.write-off-qnty    = buf_temp_fbrrep-goods.write-off-qnty      + buf_fbr-line.fact-qnty
                    buf_temp_fbrrep-goods.sum-cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl       + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-rubl        else 0 )
                    buf_temp_fbrrep-goods.sum-cost-base     = buf_temp_fbrrep-goods.sum-cost-base       + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-base        else 0 )
                    buf_temp_fbrrep-goods.sum-vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl   + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-rubl    else 0 )
                    buf_temp_fbrrep-goods.sum-vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base   + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-base    else 0 )
                .
                if buf_fbr-line.rsrv-qnty <> ?
                then do:
                    assign
                        buf_temp_fbrrep-goods.write-off-rsrv-qnty           = buf_temp_fbrrep-goods.write-off-rsrv-qnty           + buf_fbr-line.rsrv-qnty
                        buf_temp_fbrrep-goods.sum-write-off-rsrv-rubl       = buf_temp_fbrrep-goods.sum-write-off-rsrv-rubl       + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-rubl        else 0 )
                        buf_temp_fbrrep-goods.sum-write-off-rsrv-base       = buf_temp_fbrrep-goods.sum-write-off-rsrv-base       + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-base        else 0 )
                        buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-rubl   = buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-rubl   + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-rubl    else 0 )
                        buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-base   = buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-base   + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-base    else 0 )
                    .
                end.
            end.
        end case.
        assign
            buf_temp_fbrrep-goods.is-waste             = buf_fbr-line.is-waste
            buf_temp_fbrrep-goods.price-sale           = buf_fbr-line.price-sale
            buf_temp_fbrrep-goods.cost-income-rubl     = ( if buf_temp_fbrrep-goods.income-qnty     = 0 then 0 else buf_temp_fbrrep-goods.sum-cost-income-rubl      / buf_temp_fbrrep-goods.income-qnty    )
            buf_temp_fbrrep-goods.cost-income-base     = ( if buf_temp_fbrrep-goods.income-qnty     = 0 then 0 else buf_temp_fbrrep-goods.sum-cost-income-base      / buf_temp_fbrrep-goods.income-qnty    )
            buf_temp_fbrrep-goods.vat-cost-income-rubl = ( if buf_temp_fbrrep-goods.income-qnty     = 0 then 0 else buf_temp_fbrrep-goods.sum-vat-cost-income-rubl  / buf_temp_fbrrep-goods.income-qnty    )
            buf_temp_fbrrep-goods.vat-cost-income-base = ( if buf_temp_fbrrep-goods.income-qnty     = 0 then 0 else buf_temp_fbrrep-goods.sum-vat-cost-income-base  / buf_temp_fbrrep-goods.income-qnty    )
            buf_temp_fbrrep-goods.cost-rubl            = ( if buf_temp_fbrrep-goods.write-off-qnty  = 0 then 0 else buf_temp_fbrrep-goods.sum-cost-rubl             / buf_temp_fbrrep-goods.write-off-qnty )
            buf_temp_fbrrep-goods.cost-base            = ( if buf_temp_fbrrep-goods.write-off-qnty  = 0 then 0 else buf_temp_fbrrep-goods.sum-cost-base             / buf_temp_fbrrep-goods.write-off-qnty )
            buf_temp_fbrrep-goods.vat-cost-rubl        = ( if buf_temp_fbrrep-goods.write-off-qnty  = 0 then 0 else buf_temp_fbrrep-goods.sum-vat-cost-rubl         / buf_temp_fbrrep-goods.write-off-qnty )
            buf_temp_fbrrep-goods.vat-cost-base        = ( if buf_temp_fbrrep-goods.write-off-qnty  = 0 then 0 else buf_temp_fbrrep-goods.sum-vat-cost-base         / buf_temp_fbrrep-goods.write-off-qnty )
        .
    end.
    run test-temp-tables in this-procedure .
end.
end procedure.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
do
on error undo, return error
:
    define variable v-doc-code like fbr-doc.doc-code no-undo.
    def stream out-stream .
    def buffer  buf_fbr-doc       for fbr-doc.
    def buffer  buf_goods         for goods.
    def buffer  buf_clients       for clients.
    define variable v-line-counter      as integer                  no-undo.
    define variable v-organization      as character                    no-undo.
    define variable v-org-name          as character                    no-undo.
    define variable v-recipe-name       as character                    no-undo.
    define variable v-doc-code1         as character                    no-undo.
    define variable v-goods-unit        as character                    no-undo.
    define variable v-goods-artic       as character                    no-undo.
    define variable v-goods-name        as character                    no-undo.
    define variable v-bar-code          as integer                  no-undo.
    define variable out-code            as character                    no-undo.
    define variable in-code             as character                    no-undo.
    define variable v-fbr-qnty          as decimal                  no-undo.
    define variable v-trn-qnty          as decimal                  no-undo.
    define variable delta_value         as decimal                  no-undo.
    define variable v-delta             as decimal                  no-undo.
    define variable v-delta-vat         as decimal                  no-undo.
    define variable v-sum-fbr-qnty      as decimal                  no-undo.
    define variable v-sum-trn-qnty      as decimal                  no-undo.
    define variable v-sum-delta         as decimal                  no-undo.
    define variable v-sum-delta-vat     as decimal                  no-undo.
    define variable sym1  as character init "|" no-undo.
    define variable sym2  as character init ":" no-undo.
    define variable sym3  as character init ":" no-undo.
    define variable sym4  as character init ":" no-undo.
    define variable sym5  as character init ":" no-undo.
    define variable sym6  as character init ":" no-undo.
    define variable sym7  as character init ":" no-undo.
    define variable sym8  as character init ":" no-undo.
    define variable sym9  as character init ":" no-undo.
    define variable sym10  as character init ":" no-undo.
    define variable sym11 as character init "|" no-undo.
    define variable v-single-line         as character               no-undo.
    define variable v-underline           as character               no-undo.
    define variable v-need-page-break     as logical init no    no-undo.
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
    DEFINE frame f-doc
            space(10)
            sym1  format "X(1)" space(0)   v-line-counter      format ">>9"                     space(0)
            sym2  format "X(1)" space(0)   v-goods-artic       format "X(16)"                   space(0)
            sym3  format "X(1)" space(0)   v-goods-name        format "X(47)"                   space(0)
            sym4  format "X(1)" space(0)   v-bar-code          format ">>>>>>>>9"               space(0)
            sym5  format "X(1)" space(0)   v-goods-unit        format "X(3)"                    space(0)
            sym6  format "X(1)" space(0)   v-fbr-qnty          format "->>>>,>>>,>>9.99999"     space(0)
            sym7  format "X(1)" space(0)   v-trn-qnty          format "->>>>,>>>,>>9.99999"     space(0)
            sym8  format "X(1)" space(0)   delta_value         format "->>>>,>>>,>>9.99999"     space(0)
            sym9  format "X(1)" space(0)   v-delta             format "->>>>,>>>,>>9.999"     space(0)
            sym10 format "X(1)" space(0)   v-delta-vat         format "->>>>,>>>,>>9.999"     space(0)
            sym11 format "X(1)" space(0)
    with width 235 down stream-io.
if session :set-wait-state( "compiler" ) then.
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    assign
        v-single-line  = fill("-", 230)
        v-underline    = fill("_", 230)
    .
    find first buf_fbr-doc no-lock
         where recid( buf_fbr-doc ) = p-recid
    .
    assign
        v-doc-code = buf_fbr-doc.doc-code
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
output stream Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
    form header
        v-single-line format "X(178)" at 1 skip
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
    run fbrrep-fill-for-op-del in this-procedure (
          input buf_fbr-doc.doc-code
        , input ( v-cntxt-db-num <> 0 )
    ) .
    define variable v-need-print    as logical       no-undo.
    assign
        v-sum-fbr-qnty  = 0
        v-sum-trn-qnty  = 0
        v-sum-delta     = 0
        v-sum-delta-vat = 0
    .
    for each temp_fbrrep-goods
       where temp_fbrrep-goods.income-qnty < temp_fbrrep-goods.write-off-qnty
    on error undo, return error
    :
        run print-table-line in this-procedure (
              input temp_fbrrep-goods.gds-code
            , input no
            , input yes
            , output v-fbr-qnty
            , output v-trn-qnty
            , output v-delta
            , output v-delta-vat
        ).
        assign
            v-sum-fbr-qnty  = v-sum-fbr-qnty  + v-fbr-qnty
            v-sum-trn-qnty  = v-sum-trn-qnty  + v-trn-qnty
            v-sum-delta     = v-sum-delta     + v-delta
            v-sum-delta-vat = v-sum-delta-vat + v-delta-vat
        .
    end.
    if round( v-sum-fbr-qnty - v-sum-trn-qnty , 5 ) <> 0
    or round( v-sum-delta    , 3 ) <> 0
    or round( v-sum-delta-vat, 3 ) <> 0
    then do:
        assign
            v-need-print = yes
        .
    end.
    if v-need-print = no
    then do:
        assign
            v-sum-fbr-qnty  = 0
            v-sum-trn-qnty  = 0
            v-sum-delta     = 0
            v-sum-delta-vat = 0
        .
        for each temp_fbrrep-goods
           where temp_fbrrep-goods.income-qnty >= temp_fbrrep-goods.write-off-qnty
        on error undo, return error
        :
            run print-table-line in this-procedure (
                  input temp_fbrrep-goods.gds-code
                , input no
                , input yes
                , output v-fbr-qnty
                , output v-trn-qnty
                , output v-delta
                , output v-delta-vat
            ).
            assign
                v-sum-fbr-qnty  = v-sum-fbr-qnty  + v-fbr-qnty
                v-sum-trn-qnty  = v-sum-trn-qnty  + v-trn-qnty
                v-sum-delta     = v-sum-delta     + v-delta
                v-sum-delta-vat = v-sum-delta-vat + v-delta-vat
            .
        end.
        if round( v-sum-fbr-qnty - v-sum-trn-qnty , 5 ) <> 0
        or round( v-sum-delta    , 3 ) <> 0
        or round( v-sum-delta-vat, 3 ) <> 0
        then do:
            assign
                v-need-print = yes
            .
        end.
    end.
    if v-need-print = no
    then do:
        return.
    end.
    put stream Out-Stream
      skip
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( 10 + 180, 13)
      skip
        space(10) "Организация:               "
                 v-organization                format "X(60)"
      skip
        space(10) "Структурное подразделение: "
                 v-org-name              format "X(60)"
      skip(2)
        space(10) "                                АКТ ОТКЛОНЕНИЯ по документу производства №: " + v-doc-code format "X(100)"
    .
    form with frame f-doc .
    view stream Out-Stream frame BottomFrame .
    down stream Out-Stream 1 with frame f-doc no-labels.
    run fbrcode-trn-doc in this-procedure (
          input 'производство':U
        , input v-doc-code
        , input 'рас':U
        , output v-doc-code1
    ).
    run print-title in this-procedure(
        input "Товары списанные по накладной N " + v-doc-code1
    ).
    run print-header (
          input v-single-line
        , input no
    ).
    assign
        v-sum-fbr-qnty  = 0
        v-sum-trn-qnty  = 0
        v-sum-delta     = 0
        v-sum-delta-vat = 0
    .
    for each temp_fbrrep-goods
    where temp_fbrrep-goods.income-qnty < temp_fbrrep-goods.write-off-qnty
    on error undo, return error
    :
        run print-table-line in this-procedure (
              input temp_fbrrep-goods.gds-code
            , input no
            , input no
            , output v-fbr-qnty
            , output v-trn-qnty
            , output v-delta
            , output v-delta-vat
        ).
        assign
            v-sum-fbr-qnty  = v-sum-fbr-qnty  + v-fbr-qnty
            v-sum-trn-qnty  = v-sum-trn-qnty  + v-trn-qnty
            v-sum-delta     = v-sum-delta     + v-delta
            v-sum-delta-vat = v-sum-delta-vat + v-delta-vat
        .
    end.
    run print-itog in this-procedure (
          input v-sum-fbr-qnty
        , input v-sum-trn-qnty
        , input v-sum-delta
        , input v-sum-delta-vat
    ).
    form with frame f-doc .
    view stream Out-Stream frame BottomFrame .
    down stream Out-Stream 1 with frame f-doc no-labels.
    run fbrcode-trn-doc in this-procedure (
        input 'производство':U
        , input v-doc-code
        , input 'при':U
        , output v-doc-code1
    ).
    run print-title in this-procedure(
        input "Товары произведенные по накладной N " + v-doc-code1
    ).
    run print-header (
        input v-single-line
        , input no
    ).
    assign
        v-sum-fbr-qnty  = 0
        v-sum-trn-qnty  = 0
        v-sum-delta     = 0
        v-sum-delta-vat = 0
    .
    for each temp_fbrrep-goods
    where temp_fbrrep-goods.income-qnty >= temp_fbrrep-goods.write-off-qnty
    on error undo, return error
    :
        run print-table-line in this-procedure (
              input temp_fbrrep-goods.gds-code
            , input yes
            , input no
            , output v-fbr-qnty
            , output v-trn-qnty
            , output v-delta
            , output v-delta-vat
        ).
        assign
            v-sum-fbr-qnty  = v-sum-fbr-qnty  + v-fbr-qnty
            v-sum-trn-qnty  = v-sum-trn-qnty  + v-trn-qnty
            v-sum-delta     = v-sum-delta     + v-delta
            v-sum-delta-vat = v-sum-delta-vat + v-delta-vat
        .
    end.
    run print-itog in this-procedure (
          input v-sum-fbr-qnty
        , input v-sum-trn-qnty
        , input v-sum-delta
        , input v-sum-delta-vat
    ).
    hide stream out-stream frame BottomFrame .
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
procedure print-header :
do
on error undo, return error
:
def input parameter p-single-line as character    no-undo.
def input parameter p-need-line   as logical no-undo.
    if p-need-line = yes
    then put stream out-stream
        skip
          string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( 10 + 180, 13)
        skip space(10)
          p-single-line format "X(178)"
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
          "5"                  at center-field( 10 + 80, 10 + 84, 1)
          ":"                  at 10 + 84
          "6"                  at center-field( 10 + 84, 10 + 104, 1)
          ":"                  at 10 + 104
          "7"                  at center-field( 10 + 104, 10 + 124, 1)
          ":"                  at 10 + 124
          "8"                  at center-field( 10 + 124, 10 + 144, 1)
          ":"                  at 10 + 144
          "9"                  at center-field( 10 + 144, 10 + 162, 1)
          ":"                  at 10 + 162
          "10"                 at center-field( 10 + 162, 10 + 180, 2)
          "|"                  at 10 + 180
        skip space(10)
          "|"
          p-single-line format "X(178)"
          "|"                  at 10 + 180
    .
end.
end procedure.
procedure print-table-line :
do
on error undo, return error
:
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-is-income      as logical      no-undo.
define input parameter p-calc-only      as logical      no-undo.
define output parameter p-fbr-qnty      as decimal      no-undo.
define output parameter p-trn-qnty      as decimal      no-undo.
define output parameter p-delta         as decimal      no-undo.
define output parameter p-delta-vat     as decimal      no-undo.
    define variable v-unit-base as character     no-undo.
    define variable v-gds-name  as character     no-undo.
    define buffer buf_temp_fbrrep-goods     for temp_fbrrep-goods.
    find first buf_temp_fbrrep-goods
         where buf_temp_fbrrep-goods.gds-code = p-gds-code
    .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  p-gds-code
  ,output v-goods-unit
  )  .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-cdnm in g#library
  (input  p-gds-code
  ,output v-goods-name
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output v-bar-code
  )  .
 .
    assign
        v-line-counter  = v-line-counter    + 1
        v-goods-artic   = string( buf_temp_fbrrep-goods.artic )
        delta_value     = buf_temp_fbrrep-goods.fact-qnty
        v-delta       = ( if p-print-in-rubl
                            then buf_temp_fbrrep-goods.sum-cost-rubl
                            else buf_temp_fbrrep-goods.sum-cost-base )
        v-delta-vat   = ( if p-print-in-rubl
                            then buf_temp_fbrrep-goods.sum-vat-cost-rubl
                            else buf_temp_fbrrep-goods.sum-vat-cost-base )
        v-fbr-qnty      = ( if p-is-income = yes
                            then buf_temp_fbrrep-goods.income-qnty
                            else buf_temp_fbrrep-goods.write-off-qnty )
        v-trn-qnty      = v-fbr-qnty - buf_temp_fbrrep-goods.fact-qnty
    .
    if buf_temp_fbrrep-goods.fact-qnty = 0
    and v-delta     = 0
    and v-delta-vat = 0
    then do:
        assign
            buf_temp_fbrrep-goods.deleted = yes
        .
    end.
    else do:
        if v-need-page-break = yes
        and p-calc-only = no
        then do:
            page stream out-stream.
        end.
        if p-calc-only = no
        then do:
            display stream out-stream
                sym1  v-line-counter
                sym2  v-goods-artic
                sym3  v-goods-name
                sym4  v-bar-code
                sym5  v-goods-unit
                sym6  v-fbr-qnty
                sym7  v-trn-qnty
                sym8  v-fbr-qnty - v-trn-qnty   @ delta_value
                sym9  v-delta
                sym10 v-delta-vat
                sym11
            with frame f-doc.
            down stream out-stream with frame f-doc .
        end.
        assign
            p-fbr-qnty  = v-fbr-qnty
            p-trn-qnty  = v-trn-qnty
            p-delta     = v-delta
            p-delta-vat = v-delta-vat
        .
    end.
end.
end procedure.
procedure print-itog :
do
on error undo, return error
:
define input parameter p-sum-fbr-qnty   as decimal      no-undo.
define input parameter p-sum-trn-qnty   as decimal      no-undo.
define input parameter p-delta-sum      as decimal      no-undo.
define input parameter p-delta-vat-sum  as decimal      no-undo.
    put stream Out-Stream
        skip space(10)
            "|"
            v-single-line format "X(178)"
            "|" at 10 + 180
        skip space(10)
            "|"
            "ИТОГО"                         at right-field( 10 + 84, 6)
            ":"                             at 10 + 84
            p-sum-fbr-qnty                  format "->>>,>>9.99999"  at right-field( 10 + 104, 13)
            ":"                             at 10 + 104
            p-sum-trn-qnty                  format "->>>,>>9.99999"  at right-field( 10 + 124, 13)
            ":"                             at 10 + 124
            p-sum-fbr-qnty - p-sum-trn-qnty format "->>>,>>9.99999"  at right-field( 10 + 144, 13)
            ":"                             at 10 + 144
            p-delta-sum                     format "->>>,>>9.999"    at right-field( 10 + 162, 11)
            ":"                             at 10 + 162
            p-delta-vat-sum                 format "->>>,>>9.999"    at right-field( 10 + 180, 11)
            "|"                             at 10 + 180
        skip space(10)
            "|"
            v-single-line format "X(178)"
            "|" at 10 + 180
    .
end.
end procedure.
procedure print-title :
do
on error undo, return error
:
define input parameter p-header-string as character    no-undo.
    put stream Out-Stream
        skip
            space(10) p-header-string format "X(80)"
        skip space(10)
            v-single-line format "X(180)"
        skip space(10)
            "|"
            "Но-"
            ":"                                  at 10 + 5
            "Артикул"                            at center-field( 10 + 5, 10 + 22, 7)
            ":"                                  at 10 + 22
            "Наименование"                       at center-field( 10 + 22, 10 + 70, 12)
            ":"                                  at 10 + 70
            "Код"                                at center-field( 10 + 70, 10 + 80, 3)
            ":"                                  at 10 + 80
            "Ед."                                at center-field( 10 + 80, 10 + 84, 3)
            ":"                                  at 10 + 84
            "Количество"                         at center-field( 10 + 84, 10 + 104, 10)
            ":"                                  at 10 + 104
            "Количество"                         at center-field( 10 + 104, 10 + 124, 10)
            ":"                                  at 10 + 124
            "Разность"                           at center-field( 10 + 124, 10 + 144, 8)
            ":"                                  at 10 + 144
            "Разность сумм"                      at center-field( 10 + 144, 10 + 162, 13)
            ":"                                  at 10 + 162
            "Разность сумм"                      at center-field( 10 + 162, 10 + 180, 15)
            "|"                                  at 10 + 180
        skip space(10)
            "|"
            "мер"
            ":"                                  at 10 + 5
            ":"                                  at 10 + 22
            ":"                                  at 10 + 70
            ":"                                  at 10 + 80
            "изм"                                at center-field( 10 + 80, 10 + 84, 3)
            ":"                                  at 10 + 84
            "в производстве"                     at center-field( 10 + 84, 10 + 104, 14)
            ":"                                  at 10 + 104
            "по накладной"                       at center-field( 10 + 104, 10 + 124, 12)
            ":"                                  at 10 + 124
            "количеств"                          at center-field( 10 + 124, 10 + 144, 9)
            ":"                                  at 10 + 144
            "учет. цен"                          at center-field( 10 + 144, 10 + 162, 9)
            ":"                                  at 10 + 162
            "НДС уч.цен"                         at center-field( 10 + 162, 10 + 180, 10)
            "|"                                  at 10 + 180
        skip space(10)
            "|"
            v-single-line format "X(178)"
            "|" at 10 + 180
    .
end.
end procedure.
