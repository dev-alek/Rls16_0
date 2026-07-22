using ibs.th.str.*.
block-level on error undo, throw.
define input parameter p-mainmenu-handle as widget-handle no-undo.
define input parameter rec_id            as recid         no-undo.
define input parameter parprint-water    as logical       no-undo.
define variable vss-revision    as character no-undo initial "$Revision: 31d98d0f4d05, 3249, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/03/29 08:47:58 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: akt-topl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/akt-topl.p $":U .
define variable vss-description as character no-undo initial "Акт несоответствия по топливной накладной":U .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
do
on error undo, return error return-value
:
define buffer buf_trn-doc         for ub.trn-doc.
define buffer buf_doc-line        for ub.doc-line.
define buffer buf_goods           for ub.goods.
define buffer buf_clients         for ub.clients.
define buffer buf_clients_ship    for ub.clients.
define buffer buf_doc-line-attr   for ub.doc-line-attr.
define buffer buf_doc-attr        for ub.doc-attr.
define buffer buf_rvs-doc_before  for ub.rvs-doc.
define buffer buf_rvs-doc_after   for ub.rvs-doc.
define buffer buf_rvs-line_before for ub.rvs-line.
define buffer buf_rvs-line_after  for ub.rvs-line.
define stream out-stream .
define variable v-operator    as char             no-undo.
define variable temp-string   as char             no-undo.
define variable temp-position as int              no-undo.
define variable single-line   as char             no-undo.
define variable v-is-petrol   as logical init no  no-undo.
define variable v-is-pieces   as logical init no  no-undo.
define variable v-have-petrol as logical init no  no-undo.
define variable v-have-rvs-before as logical init no  no-undo.
define variable v-have-rvs-after  as logical init no  no-undo.
define variable before_real-time  as integer          no-undo.
define variable after_real-time   as integer          no-undo.
define variable doc-line_1st-run  as logical          no-undo .
define variable v-ship-org          like doc-line-attr.attr-value no-undo.
define variable v-autoent-obj-code  like doc-line-attr.attr-value no-undo.
define variable v-autoent-obj-type  like doc-line-attr.attr-value no-undo.
define variable v-dids              like doc-line-attr.attr-value no-undo.
define variable v-nids              like doc-line-attr.attr-value no-undo.
define variable v-attr-type         as character                  no-undo.
define variable v-car-num           like doc-line-attr.attr-value no-undo.
define variable v-car-vol           like doc-line-attr.attr-value no-undo.
define variable v-item-pour         like doc-line-attr.attr-value no-undo.
define variable v-tank-density      like doc-line-attr.attr-value no-undo.
define variable v-tank-temp         like doc-line-attr.attr-value no-undo.
define variable v-tank-vol          like doc-line-attr.attr-value no-undo.
define variable v-tank-water        like doc-line-attr.attr-value no-undo.
define variable v-tank-weight       like doc-line-attr.attr-value no-undo.
define variable v-time-pour         like doc-line-attr.attr-value no-undo.
define variable v-time-income       like doc-line-attr.attr-value no-undo.
define variable v-time-start        like doc-line-attr.attr-value no-undo.
define variable v-time-end          like doc-line-attr.attr-value no-undo.
define variable v-type-inp-vat      like doc-line-attr.attr-value no-undo.
define variable v-fio               like doc-line-attr.attr-value no-undo.
define variable v-delta-mass        as decimal                    no-undo.
define variable v-mass-pogresh      as decimal                    no-undo.
define variable v-delta-res as decimal                    no-undo.
define variable v-tank-vol-dec      like ub.rvs-line.state-measure-qnty     no-undo.
define variable v-tank-temp-dec     like ub.rvs-line.state-temperature      no-undo.
define variable v-tank-density-dec  like ub.rvs-line.state-density          no-undo.
define variable v-tank-weight-dec   like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable v-tank-water-dec    like ub.rvs-line.state-measure-qnty     no-undo.
define variable v-nedost            as   logical                         no-undo.
define variable before_qnty         like ub.rvs-line.state-measure-qnty     no-undo.
define variable before_temperature  like ub.rvs-line.state-temperature      no-undo.
define variable before_density      like ub.rvs-line.state-density          no-undo.
define variable before_cli-qnty     like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable after_qnty          like ub.rvs-line.state-measure-qnty     no-undo.
define variable after_temperature   like ub.rvs-line.state-temperature      no-undo.
define variable after_density       like ub.rvs-line.state-density          no-undo.
define variable after_cli-qnty      like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable v-water-qnty        as decimal no-undo .
define variable v-InfoSectionsTotal as class InfoSectionsTotal no-undo .
define variable varstfactpl     as character no-undo .
define variable varstfactpltype as character no-undo .
define variable pogresh         as decimal   no-undo initial 0 .
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
assign
    single-line = fill("-", 114)
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'stfactpl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varstfactpl
  ,output varstfactpltype
  ) no-error .
assign
  varstfactpl = replace( varstfactpl,  "read-only;", "":U )
  varstfactpl = replace( varstfactpl, ";read-only",  "":U )
  varstfactpl = replace( varstfactpl,  "read-only",  "":U )
  varstfactpl = replace( varstfactpl,  "inv-set;", "":U )
  varstfactpl = replace( varstfactpl, ";inv-set",  "":U )
  varstfactpl = replace( varstfactpl,  "inv-set",  "":U )
.
if num-entries( varstfactpl, ";" ) > 1
then do:
  assign
    varstfactpl = entry( 1, varstfactpl, ";" )
  .
end.
assign
  varstfactpl = replace( varstfactpl, ";",           "":U )
.
assign
  pogresh     = ( if num-entries( varstfactpl, '=' ) = 2 then decimal( entry( 2, varstfactpl, '=' ) ) * 0.01 else 0 )
  varstfactpl = entry( 1, varstfactpl, "=" )
.
if session :set-wait-state( "compiler" ) then.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
find first buf_trn-doc no-lock
     where recid( buf_trn-doc ) = rec_id
.
find first buf_clients no-lock
    where buf_clients.obj-type = 'чел':U
      and buf_clients.obj-code = buf_trn-doc.wrkr
no-error.
if available buf_clients
then do:
    assign
        v-operator = buf_clients.obj-name
    .
end.
else do:
    assign
        v-operator = ""
    .
end.
find first buf_clients no-lock
    where buf_clients.obj-type = buf_trn-doc.obj-type
      and buf_clients.obj-code = buf_trn-doc.obj-code
.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'dids':U ,
                       output v-dids ,
                       output v-attr-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'nids':U ,
                       output v-nids ,
                       output v-attr-type )  .
print-doc-line:
for each buf_doc-line no-lock
     where buf_doc-line.doc-code = buf_trn-doc.doc-code
:
    assign
      doc-line_1st-run = yes
    .
    assign
        v-autoent-obj-code = ""
        v-autoent-obj-type = ""
        v-car-num          = ""
        v-car-vol          = ""
        v-item-pour        = ""
        v-tank-density     = ""
        v-tank-temp        = ""
        v-tank-vol         = ""
        v-tank-water       = ""
        v-tank-weight      = ""
        v-time-pour        = ""
        v-time-income      = ""
        v-time-start       = ""
        v-time-end         = ""
        v-type-inp-vat     = ""
        v-fio              = ""
    .
    find first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
          and buf_goods.prod-type  = buf_doc-line.prod-type
          and buf_goods.prod-code  = buf_doc-line.prod-code
    .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
    if v-is-petrol <> yes
    then do:
        next print-doc-line.
    end.
    assign
        v-have-petrol = yes
    .
    v-InfoSectionsTotal = new InfoSectionsTotal().
    v-InfoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_goods.gds-code).
    v-InfoSectionsTotal:GetDBAllAttr().
    for each buf_doc-line-attr no-lock
       where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
         and buf_doc-line-attr.gds-code = buf_goods.gds-code
    :
        case buf_doc-line-attr.attr-code:
          when "car-vol"
          then do:
            assign
               v-car-vol = trim(buf_doc-line-attr.attr-value)
            .
          end.
          when "tank-density"
          then do:
            assign
               v-tank-density = trim(buf_doc-line-attr.attr-value)
            .
          end.
          when "tank-temp"
          then do:
            assign
               v-tank-temp = trim(buf_doc-line-attr.attr-value)
            .
          end.
          when "tank-vol"
          then do:
            assign
               v-tank-vol = trim(buf_doc-line-attr.attr-value)
            .
          end.
          when "tank-water"
          then do:
            assign
               v-tank-water = trim(buf_doc-line-attr.attr-value)
            .
          end.
          when "tank-weight"
          then do:
            assign
               v-tank-weight = trim(buf_doc-line-attr.attr-value)
            .
          end.
          when "time-start"
          then do:
            assign
               v-time-start = trim(buf_doc-line-attr.attr-value)
            .
          end.
          when "time-end"
          then do:
            assign
               v-time-end = trim(buf_doc-line-attr.attr-value)
            .
          end.
          when "time-pour"
          then do:
            assign
               v-time-pour = trim(buf_doc-line-attr.attr-value)
            .
          end.
          when "type-inp-vat"
          then do:
            assign
               v-type-inp-vat = trim(buf_doc-line-attr.attr-value)
            .
          end.
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
    when 'fio-driver':U then do: assign v-fio = trim( buf_doc-attr.attr-value ). end.
      end case.
    end.
  assign
    v-tank-vol-dec = decimal(v-tank-vol) no-error.
    if error-status :error
    then message
      vss-workfile + ". Ошибка преобразования параметра " + "tank-vol" + " в число"
      view-as alert-box error
    .
  .
  assign
    v-tank-temp-dec = decimal(v-tank-temp) no-error.
    if error-status :error
    then message
      vss-workfile + ". Ошибка преобразования параметра " + "tank-temp" + " в число"
      view-as alert-box error
    .
  .
  assign
    v-tank-density-dec = decimal(v-tank-density) no-error.
    if error-status :error
    then message
      vss-workfile + ". Ошибка преобразования параметра " + "tank-density" + " в число"
      view-as alert-box error
    .
  .
  assign
    v-tank-weight-dec = decimal(v-tank-weight) no-error.
    if error-status :error
    then message
      vss-workfile + ". Ошибка преобразования параметра " + "tank-weight" + " в число"
      view-as alert-box error
    .
  .
  assign
    v-tank-water-dec = decimal(v-tank-water) no-error.
    if error-status :error
    then message
      vss-workfile + ". Ошибка преобразования параметра " + "tank-water" + " в число"
      view-as alert-box error
    .
  .
    v-car-vol = string (v-InfoSectionsTotal:CarVolTotal).
    v-tank-vol-dec = v-InfoSectionsTotal:TankVolTotal.
    v-tank-density-dec = v-InfoSectionsTotal:TankWeightTotal / v-InfoSectionsTotal:TankVolTotal.
    v-tank-weight-dec = v-InfoSectionsTotal:TankWeightTotal.
    v-tank-water-dec = v-InfoSectionsTotal:TankWaterVolTotal.
    v-time-start =  string ( v-InfoSectionsTotal:StartRealTime ).
    v-time-end =  string ( v-InfoSectionsTotal:EndRealTime ).
    find first buf_clients_ship no-lock
        where buf_clients_ship.obj-type = v-autoent-obj-type
          and buf_clients_ship.obj-code = integer(v-autoent-obj-code)
    no-error.
    if available buf_clients_ship
    then assign
        v-ship-org = buf_clients_ship.obj-name
    .
    else assign
        v-ship-org = ""
    .
      assign
        before_real-time = ( if v-time-start <> "":U then integer( v-time-start ) else ? )
      .
    find first buf_rvs-doc_before no-lock
        where buf_rvs-doc_before.out-code = buf_trn-doc.doc-code
          and buf_rvs-doc_before.rvs-type = 'перед_док':U
    no-error.
    assign
        v-have-rvs-before = ( available buf_rvs-doc_before )
    .
    if before_real-time = ? then do:
      if v-have-rvs-before = yes
      then do:
          for each buf_rvs-line_before no-lock
            where buf_rvs-line_before.rvs-code = buf_rvs-doc_before.rvs-code
              and buf_rvs-line_before.obj-type = buf_trn-doc.obj-type
              and buf_rvs-line_before.obj-code = buf_trn-doc.obj-code
              and buf_rvs-line_before.gds-code = buf_goods.gds-code
          :
              if before_real-time = ? or
                before_real-time < buf_rvs-line_before.real-time
              then do:
                  assign
                    before_real-time = buf_rvs-line_before.real-time
                  .
              end.
          end.
      end.
    end.
      assign
        after_real-time = ( if v-time-end <> "":U then integer( v-time-end ) else ? )
      .
    find first buf_rvs-doc_after no-lock
        where buf_rvs-doc_after.out-code = buf_trn-doc.doc-code
          and buf_rvs-doc_after.rvs-type = 'после_док':U
    no-error.
    assign
        v-have-rvs-after = ( available buf_rvs-doc_after )
    .
    if after_real-time = ? then do:
      if v-have-rvs-after = yes
      then do:
          for each buf_rvs-line_after no-lock
            where buf_rvs-line_after.rvs-code = buf_rvs-doc_after.rvs-code
              and buf_rvs-line_after.obj-type = buf_trn-doc.obj-type
              and buf_rvs-line_after.obj-code = buf_trn-doc.obj-code
              and buf_rvs-line_after.gds-code = buf_goods.gds-code
          :
              if after_real-time = ? or
                after_real-time > buf_rvs-line_after.real-time
              then do:
                  assign
                    after_real-time = buf_rvs-line_after.real-time
                  .
              end.
          end.
      end.
    end.
    put stream out-stream
        skip
        space (15)  '"УТВЕРЖДАЮ"'           format "X(11)"
        '"УТВЕРЖДАЮ"'           format "X(11)"  at right-field( 130, 11 )
        skip
        space (15)  "____________________"  format "X(20)"
        "____________________"  format "X(20)"  at right-field( 130, 20 )
        skip
        space (15)  "____________________"  format "X(20)"
        "____________________"  format "X(20)"  at right-field( 130, 20 )
        skip
        "А К Т"            format "X(5)"    at center-field( 15, 130, 5 )
        skip
        "Об отличии количества нефтепродукта по ТТН"
                          format "X(42)"   at center-field( 15, 130, 42 )
    .
    assign
      temp-string   = "от количества по измерениям при приеме на " + trim(buf_clients.obj-name)
    .
    assign temp-position = center-field( 15, 130, length(temp-string) )         temp-string   = fill(" ", temp-position) + temp-string.
    put stream out-stream
        skip
        temp-string format "X(130)"
    .
      if buf_trn-doc.fact-date <> ?
      then do:
          assign
            temp-string = '" '  + string(day(buf_trn-doc.fact-date))
                          + ' " ' + entry(month(buf_trn-doc.fact-date), 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U)
                          + " " + string(year(buf_trn-doc.fact-date), "9999") + " г."
          .
          assign temp-position = center-field( 15, 130, length(temp-string) )         temp-string   = fill(" ", temp-position) + temp-string.
      end.
      else assign
          temp-string = ""
      .
    put stream out-stream
            skip
            temp-string format "X(130)"
            skip (2)
            space (15) "ТТН N "
            string(buf_trn-doc.doc-code) + " от " + string(buf_trn-doc.doc-date)
                                        format "X(76)"     at 54
    .
    put stream out-stream
        skip
        space (15) "Основание: накладная поставщика"
        string( "N " + v-nids + " от " + v-dids )
                                        format "X(76)"     at 54
        skip
        space (15) "Автопредприятие "
        v-ship-org                      format "X(76)"     at 54
        skip
        space (15) "Гос.N автоцистерны "
        v-car-num                       format "X(76)"     at 54
        skip
        space (15) "Объем по паспорту в литрах "
        v-car-vol                       format "X(76)"     at 54
        skip
        space (15) "Поставщик "
        buf_trn-doc.cli-name            format "X(76)"     at 54
        skip
        space (15) "Пункт налива "
        v-item-pour                     format "X(76)"     at 54
        skip
        space (15) "Время налива "
        v-time-pour                     format "X(76)"     at 54
        skip
        space (15) "Время прибытия на АЗС "
        v-time-income                   format "X(76)"     at 54
        skip
        space (15) "Время налива:"
                                "начало "
                                + (if before_real-time <> ?
                                 then string(before_real-time, "hh:mm")
                                 else "     "
                                   )
                                + " (чч:мм) окончание "
                                + (if after_real-time <> ?
                                 then string(after_real-time, "hh:mm")
                                 else "     "
                                   )
                                + "(чч:мм)"
                                        format "X(76)"     at 54
        skip
        space (15) "Ф.И.О. экспедитора "
        v-fio format "X(76)"     at 54
        skip
        space (15) "При приеме машина проверена на наличие пломб. Пломбы сорваны"
        skip
        space (15) fill("_", ( 130 - 15 ) )  format "X(114)"
        skip
        space (15) fill ("_", ( 130 - 15 ) ) format "X(114)"
        skip
        space (15) "Уровень н/продукта перед сливом автоцистерны _________________________ в сантиметрах"
        skip
        space (15) "калибровочной планки.                         (выше, ниже, по планку)"
        skip
        space (15) "Нефтепродукт "
        buf_goods.gds-name              format "X(76)"     at 54
    .
    if parprint-water = yes then do:
      put stream out-stream
        skip
          single-line        format "X(114)"        at 16
        skip
          ":"         format "X(1)"           at 16
          ":"         format "X(1)"           at 16 + 25
          "Нефтепродукт"  format "X(12)" at center-field( 16 + 25, 16 + 94, 12)
          ":"         format "X(1)"           at 16 + 94
          "Вода " format "X(5)" at center-field( 16 + 94, 16 + 113, 4)
          ":"         format "X(1)"           at 16 + 113
        skip
          ":"         format "X(1)"           at 16
          ":"         format "X(1)"           at 16 + 25
          single-line        format "X(68)"
          ":"         format "X(1)"           at 16 + 94
          single-line        format "X(18)"
          ":"         format "X(1)"           at 16 + 113
        skip
          ":"         format "X(1)"           at 16
          ":"         format "X(1)"           at 16 + 25
          "Объем,"    format "X(6)"           at center-field( 16 + 25, 16 + 40, 6)
          ":"         format "X(1)"           at 16 + 40
          "t,"        format "X(2)"          at center-field( 16 + 40, 16 + 50, 2)
          ":"         format "X(1)"           at 16 + 50
          "Плотность," format "X(10)"          at center-field( 16 + 50, 16 + 74, 10)
          ":"         format "X(1)"           at 16 + 74
          "Масса,"    format "X(6)"           at center-field( 16 + 74, 16 + 94, 6)
          ":"         format "X(1)"           at 16 + 94
          "Объем воды," format "X(11)"        at center-field( 16 + 94, 16 + 113, 11)
          ":"         format "X(1)"           at 16 + 113
        skip
          ":"         format "X(1)"           at 16
          ":"         format "X(1)"           at 16 + 25
          "л"         format "X(1)"           at center-field( 16 + 25, 16 + 40, 1)
          ":"         format "X(1)"           at 16 + 40
          "град.C"    format "X(6)"           at center-field( 16 + 40, 16 + 50, 6)
          ":"         format "X(1)"           at 16 + 50
          "г/см.куб"  format "X(8)"           at center-field( 16 + 50, 16 + 74, 8)
          ":"         format "X(1)"           at 16 + 74
          "кг"        format "X(2)"           at center-field( 16 + 74, 16 + 94, 2)
          ":"         format "X(1)"           at 16 + 94
          "л"         format "X(1)"           at center-field( 16 + 94, 16 + 113, 1)
          ":"         format "X(1)"           at 16 + 113
        skip
          ":"         format "X(1)"           at 16
          single-line format "X(112)"
          ":"         format "X(1)"
      .
      put stream out-stream
        skip
          ":"         format "X(1)"           at 16
          "По ТТН"    format "X(6)"           at 16 + 2
          ":"         format "X(1)"           at 16 + 25
          buf_doc-line.doc-qnty          format "zz,zz9.999"    at right-field( 16 + 40 - 2, 10)
          ":"         format "X(1)"           at 16 + 40 .
      if v-InfoSectionsTotal:GetInfoSectionProp(1):TTNTemp <> ? then do:
          put stream out-stream
          v-InfoSectionsTotal:GetInfoSectionProp(1):TTNTemp       format "->>9.99"           at right-field( 16 + 50 - 1, 7)
          ":"         format "X(1)"           at 16 + 50 .
      end.
      else do:
          put stream out-stream
          buf_doc-line.temperature       format "->>9.99"           at right-field( 16 + 50 - 1, 7)
          ":"         format "X(1)"           at 16 + 50 .
       end.
      put stream out-stream
          buf_doc-line.doc-density       format "9.9999999999"            at right-field( 16 + 74 - 2, 12)
          ":"         format "X(1)"           at 16 + 74
          buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                         format "zzz,zzz,zz9.999"  at right-field( 16 + 94 - 2, 15)
          ":"         format "X(1)"           at 16 + 94
          ":"         format "X(1)"           at 16 + 113
        skip
          ":"         format "X(1)"           at 16
          single-line format "X(112)"
          ":"         format "X(1)"
        skip
          ":"         format "X(1)"           at 16
          single-line format "X(112)"
          ":"         format "X(1)"
        skip
          ":"         format "X(1)"           at 16
          "По замеру в"    format "X(11)"     at 16 + 2
          ":"         format "X(1)"           at 16 + 25
          ":"         format "X(1)"           at 16 + 40
          ":"         format "X(1)"           at 16 + 50
          ":"         format "X(1)"           at 16 + 74
          ":"         format "X(1)"           at 16 + 94
          ":"         format "X(1)"           at 16 + 113
        skip
          ":"         format "X(1)"           at 16
          "автоцистерне"    format "X(12)"    at 16 + 2
          ":"         format "X(1)"           at 16 + 25
      .
      if v-InfoSectionsTotal:TankVolTotal <> ?
      then put stream out-stream
          v-InfoSectionsTotal:TankVolTotal
                                      format "zz,zz9.999"    at right-field( 16 + 40 - 2, 10)
      .
      put stream out-stream
          ":"         format "X(1)"           at 16 + 40
      .
      if v-InfoSectionsTotal:GetInfoSectionProp(1):TankTemp <> ?
      then put stream out-stream
          v-InfoSectionsTotal:GetInfoSectionProp(1):TankTemp
                                      format "->>9.99"           at right-field( 16 + 50 - 1, 7)
      .
      put stream out-stream
          ":"         format "X(1)"           at 16 + 50
      .
      if v-tank-density-dec <> ? then
      put stream out-stream
          v-tank-density-dec
                                      format "9.9999999999"            at right-field( 16 + 74 - 2, 12)
      .
      put stream out-stream
          ":"         format "X(1)"           at 16 + 74
      .
      if v-InfoSectionsTotal:TankWeightTotal <> ?
      then put stream out-stream
          v-InfoSectionsTotal:TankWeightTotal
                                      format "zzz,zzz,zz9.999"  at right-field( 16 + 94 - 2, 15)
      .
      put stream out-stream
          ":"         format "X(1)"           at 16 + 94
      .
      if v-InfoSectionsTotal:TankWaterVolTotal <> ? then do:
        put stream out-stream v-InfoSectionsTotal:TankWaterVolTotal format "zzz,zzz,zz9.999"  at right-field( 16 + 113 - 2, 15).
      end.
      put stream out-stream
          ":"         format "X(1)"           at 16 + 113
          skip
          ":"         format "X(1)"           at 16
          single-line format "X(112)"
          ":"         format "X(1)"
      skip.
    end.
    else do:
      put stream out-stream
        skip
          single-line        format "X(95)"        at 16
        skip
          ":"         format "X(1)"           at 16
          ":"         format "X(1)"           at 16 + 25
          "Нефтепродукт"  format "X(12)" at center-field( 16 + 25, 16 + 94, 12)
          ":"         format "X(1)"           at 16 + 94
        skip
          ":"         format "X(1)"           at 16
          ":"         format "X(1)"           at 16 + 25
          single-line        format "X(68)"
          ":"         format "X(1)"           at 16 + 94
        skip
          ":"         format "X(1)"           at 16
          ":"         format "X(1)"           at 16 + 25
          "Объем,"    format "X(6)"           at center-field( 16 + 25, 16 + 40, 6)
          ":"         format "X(1)"           at 16 + 40
          "t,"        format "X(2)"          at center-field( 16 + 40, 16 + 50, 2)
          ":"         format "X(1)"           at 16 + 50
          "Плотность," format "X(10)"          at center-field( 16 + 50, 16 + 74, 10)
          ":"         format "X(1)"           at 16 + 74
          "Масса,"    format "X(6)"           at center-field( 16 + 74, 16 + 94, 6)
          ":"         format "X(1)"           at 16 + 94
        skip
          ":"         format "X(1)"           at 16
          ":"         format "X(1)"           at 16 + 25
          "л"         format "X(1)"           at center-field( 16 + 25, 16 + 40, 1)
          ":"         format "X(1)"           at 16 + 40
          "град.C"    format "X(6)"           at center-field( 16 + 40, 16 + 50, 6)
          ":"         format "X(1)"           at 16 + 50
          "г/см.куб"  format "X(8)"           at center-field( 16 + 50, 16 + 74, 8)
          ":"         format "X(1)"           at 16 + 74
          "кг"        format "X(2)"           at center-field( 16 + 74, 16 + 94, 2)
          ":"         format "X(1)"           at 16 + 94
        skip
          ":"         format "X(1)"           at 16
          single-line format "X(93)"
          ":"         format "X(1)"
      .
      put stream out-stream
        skip
          ":"         format "X(1)"           at 16
          "По ТТН"    format "X(6)"           at 16 + 2
          ":"         format "X(1)"           at 16 + 25
          buf_doc-line.doc-qnty          format "zz,zz9.999"    at right-field( 16 + 40 - 2, 10)
          ":"         format "X(1)"           at 16 + 40
          buf_doc-line.temperature       format "->>9.99"           at right-field( 16 + 50 - 1, 7)
          ":"         format "X(1)"           at 16 + 50
          buf_doc-line.doc-density       format "9.9999999999"            at right-field( 16 + 74 - 2, 12)
          ":"         format "X(1)"           at 16 + 74
          buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                         format "zzz,zzz,zz9.999"  at right-field( 16 + 94 - 2, 15)
          ":"         format "X(1)"           at 16 + 94
        skip
          ":"         format "X(1)"           at 16
          single-line format "X(93)"
          ":"         format "X(1)"
        skip
          ":"         format "X(1)"           at 16
          single-line format "X(93)"
          ":"         format "X(1)"
        skip
          ":"         format "X(1)"           at 16
          "По замеру в"    format "X(11)"     at 16 + 2
          ":"         format "X(1)"           at 16 + 25
          ":"         format "X(1)"           at 16 + 40
          ":"         format "X(1)"           at 16 + 50
          ":"         format "X(1)"           at 16 + 74
          ":"         format "X(1)"           at 16 + 94
        skip
          ":"         format "X(1)"           at 16
          "автоцистерне"    format "X(12)"    at 16 + 2
          ":"         format "X(1)"           at 16 + 25
      .
      if v-InfoSectionsTotal:TankVolTotal <> ?
      then put stream out-stream
          v-InfoSectionsTotal:TankVolTotal
                                      format "zz,zz9.999"    at right-field( 16 + 40 - 2, 10)
      .
      put stream out-stream
          ":"         format "X(1)"           at 16 + 40
      .
      if v-InfoSectionsTotal:GetInfoSectionProp(1):TankTemp <> ?
      then put stream out-stream
          v-InfoSectionsTotal:GetInfoSectionProp(1):TankTemp
                                      format "->>9.99"           at right-field( 16 + 50 - 1, 7)
      .
      put stream out-stream
          ":"         format "X(1)"           at 16 + 50
      .
      if v-InfoSectionsTotal:DocDensityAvg <> ? then
      put stream out-stream
          v-InfoSectionsTotal:DocDensityAvg
                                      format "9.9999999999"            at right-field( 16 + 74 - 2, 12)
      .
      put stream out-stream
          ":"         format "X(1)"           at 16 + 74
      .
      if v-InfoSectionsTotal:TankWeightTotal <> ?
      then put stream out-stream
          v-InfoSectionsTotal:TankWeightTotal
                                      format "zzz,zzz,zz9.999"  at right-field( 16 + 94 - 2, 15)
      .
      put stream out-stream
          ":"         format "X(1)"           at 16 + 94
      .
      put stream out-stream
          skip
          ":"         format "X(1)"           at 16
          single-line format "X(93)"
          ":"         format "X(1)"
       skip.
    end.
      if parprint-water = yes then do:
    if doc-line_1st-run = yes
    then do:
      assign
        v-delta-mass = buf_doc-line.doc-qnty * buf_doc-line.doc-density
      .
      if lookup( varstfactpl, "auto-tank,inv" ) > 0 then do:
        assign
          v-delta-mass = v-delta-mass - v-tank-weight-dec.
          doc-line_1st-run = no
        .
      end.
    end.
    if v-have-rvs-before = yes
    then do:
        for each buf_rvs-line_before no-lock
           where buf_rvs-line_before.rvs-code = buf_rvs-doc_before.rvs-code
             and buf_rvs-line_before.obj-type = buf_trn-doc.obj-type
             and buf_rvs-line_before.obj-code = buf_trn-doc.obj-code
             and buf_rvs-line_before.gds-code = buf_goods.gds-code
        :
        assign
          before_qnty        = before_qnty        + buf_rvs-line_before.state-measure-qnty
          before_temperature = before_temperature + buf_rvs-line_before.state-temperature
                                            * buf_rvs-line_before.state-measure-qnty
          before_cli-qnty    = before_cli-qnty    + buf_rvs-line_before.state-measure-cli-qnty
        .
        if lookup( varstfactpl, "auto-tank,inv" ) = 0 then do:
            assign
              v-delta-mass = v-delta-mass
                +
                buf_rvs-line_before.state-measure-cli-qnty
              doc-line_1st-run = no
            .
        end.
        put stream out-stream
            ":"         format "X(1)"           at 16
            single-line format "X(112)"
            ":"         format "X(1)"
          skip
            ":"         format "X(1)"           at 16
            "По замеру в резервуаре"    format "X(22)"           at 16 + 2
            ":"         format "X(1)"           at 16 + 25
            ":"         format "X(1)"           at 16 + 40
            ":"         format "X(1)"           at 16 + 50
            ":"         format "X(1)"           at 16 + 74
            ":"         format "X(1)"           at 16 + 94
            ":"         format "X(1)"           at 16 + 113
          skip
            ":"         format "X(1)"           at 16
            "ДО слива"  format "X(8)"           at 16 + 2
            ":"         format "X(1)"           at 16 + 25
        .
    if v-have-rvs-before = yes
    then do:
        if buf_rvs-line_before.state-measure-qnty <> ?
            then put stream out-stream
                buf_rvs-line_before.state-measure-qnty
                                            format "zz,zz9.999"    at right-field( 16 + 40 - 2, 10)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 40 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 40
    .
    if v-have-rvs-before = yes
    then do:
        if buf_rvs-line_before.state-temperature <> ?
            then put stream out-stream
                buf_rvs-line_before.state-temperature
                                            format "->>9.99"    at right-field( 16 + 50 - 1, 7)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 50 - 1, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 50
    .
    if v-have-rvs-before = yes
    then do:
        if buf_rvs-line_before.state-density <> ?
            then put stream out-stream
                buf_rvs-line_before.state-density
                                            format "9.9999999999"    at right-field( 16 + 74 - 2, 12)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 74 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 74
    .
    if v-have-rvs-before = yes
    then do:
        if buf_rvs-line_before.state-measure-cli-qnty <> ?
            then put stream out-stream
                buf_rvs-line_before.state-measure-cli-qnty
                                            format "zzz,zzz,zz9.999"    at right-field( 16 + 94 - 2, 15)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 94 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 94
    .
        v-water-qnty = buf_rvs-line_before.state-brutto-qnty - buf_rvs-line_before.state-measure-qnty .
        for first rvs-line-attr no-lock
              where rvs-line-attr.obj-code  = buf_rvs-line_before.obj-code
                and rvs-line-attr.obj-type  = buf_rvs-line_before.obj-type
                and rvs-line-attr.gds-code  = buf_rvs-line_before.gds-code
                and rvs-line-attr.pl-code   = buf_rvs-line_before.pl-code
                and rvs-line-attr.rvs-code  = buf_rvs-line_before.rvs-code
                and rvs-line-attr.attr-code = "pokmi-water-qnty"
        :
          v-water-qnty = decimal(rvs-line-attr.attr-value) .
        end .
        if v-water-qnty = ? then v-water-qnty = 0 .
    if v-have-rvs-before = yes
    then do:
        if v-water-qnty <> ?
            then put stream out-stream
                v-water-qnty
                                            format "zzz,zzz,zz9.999"    at right-field( 16 + 113 - 2, 15)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 113 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 113
    .
        end.
        assign
          before_temperature = before_temperature / before_qnty
          before_density     = before_cli-qnty    / before_qnty
        .
    end.
    if doc-line_1st-run = yes
    then do:
      assign
        v-delta-mass = buf_doc-line.doc-qnty * buf_doc-line.doc-density
      .
      if lookup( varstfactpl, "auto-tank,inv" ) > 0 then do:
        assign
          v-delta-mass = v-delta-mass - v-tank-weight-dec.
          doc-line_1st-run = no
        .
      end.
    end.
    if v-have-rvs-after = yes
    then do:
        for each buf_rvs-line_after no-lock
           where buf_rvs-line_after.rvs-code = buf_rvs-doc_after.rvs-code
             and buf_rvs-line_after.obj-type = buf_trn-doc.obj-type
             and buf_rvs-line_after.obj-code = buf_trn-doc.obj-code
             and buf_rvs-line_after.gds-code = buf_goods.gds-code
        :
        assign
          after_qnty        = after_qnty        + buf_rvs-line_after.state-measure-qnty
          after_temperature = after_temperature + buf_rvs-line_after.state-temperature
                                            * buf_rvs-line_after.state-measure-qnty
          after_cli-qnty    = after_cli-qnty    + buf_rvs-line_after.state-measure-cli-qnty
        .
        if lookup( varstfactpl, "auto-tank,inv" ) = 0 then do:
            assign
              v-delta-mass = v-delta-mass
                -
                buf_rvs-line_after.state-measure-cli-qnty
              doc-line_1st-run = no
            .
        end.
        put stream out-stream
          skip
            ":"         format "X(1)"           at 16
            single-line format "X(112)"
            ":"         format "X(1)"
          skip
            ":"         format "X(1)"           at 16
            "По замеру в резервуаре"    format "X(22)"           at 16 + 2
            ":"         format "X(1)"           at 16 + 25
            ":"         format "X(1)"           at 16 + 40
            ":"         format "X(1)"           at 16 + 50
            ":"         format "X(1)"           at 16 + 74
            ":"         format "X(1)"           at 16 + 94
            ":"         format "X(1)"           at 16 + 113
          skip
            ":"         format "X(1)"           at 16
            "ПОСЛЕ слива"  format "X(11)"       at 16 + 2
            ":"         format "X(1)"           at 16 + 25
        .
    if v-have-rvs-after = yes
    then do:
        if buf_rvs-line_after.state-measure-qnty <> ?
            then put stream out-stream
                buf_rvs-line_after.state-measure-qnty
                                            format "zz,zz9.999"    at right-field( 16 + 40 - 2, 10)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 40 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 40
    .
    if v-have-rvs-after = yes
    then do:
        if buf_rvs-line_after.state-temperature <> ?
            then put stream out-stream
                buf_rvs-line_after.state-temperature
                                            format "->>9.99"    at right-field( 16 + 50 - 1, 7)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 50 - 1, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 50
    .
    if v-have-rvs-after = yes
    then do:
        if buf_rvs-line_after.state-density <> ?
            then put stream out-stream
                buf_rvs-line_after.state-density
                                            format "9.9999999999"    at right-field( 16 + 74 - 2, 12)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 74 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 74
    .
    if v-have-rvs-after = yes
    then do:
        if buf_rvs-line_after.state-measure-cli-qnty <> ?
            then put stream out-stream
                buf_rvs-line_after.state-measure-cli-qnty
                                            format "zzz,zzz,zz9.999"    at right-field( 16 + 94 - 2, 15)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 94 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 94
    .
        v-water-qnty = buf_rvs-line_after.state-brutto-qnty - buf_rvs-line_after.state-measure-qnty .
        for first rvs-line-attr no-lock
              where rvs-line-attr.obj-code  = buf_rvs-line_after.obj-code
                and rvs-line-attr.obj-type  = buf_rvs-line_after.obj-type
                and rvs-line-attr.gds-code  = buf_rvs-line_after.gds-code
                and rvs-line-attr.pl-code   = buf_rvs-line_after.pl-code
                and rvs-line-attr.rvs-code  = buf_rvs-line_after.rvs-code
                and rvs-line-attr.attr-code = "pokmi-water-qnty"
        :
          v-water-qnty = decimal(rvs-line-attr.attr-value) .
        end .
        if v-water-qnty = ? then v-water-qnty = 0 .
    if v-have-rvs-after = yes
    then do:
        if v-water-qnty <> ?
            then put stream out-stream
                v-water-qnty
                                            format "zzz,zzz,zz9.999"    at right-field( 16 + 113 - 2, 15)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 113 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 113
    .
        end.
        assign
          after_temperature = after_temperature / after_qnty
          after_density     = after_cli-qnty    / after_qnty
        .
    end.
        put stream out-stream
          skip
            single-line        format "X(114)"        at 16
        .
      end.
      else do:
    if doc-line_1st-run = yes
    then do:
      assign
        v-delta-mass = buf_doc-line.doc-qnty * buf_doc-line.doc-density
      .
      if lookup( varstfactpl, "auto-tank,inv" ) > 0 then do:
        assign
          v-delta-mass = v-delta-mass - v-tank-weight-dec.
          doc-line_1st-run = no
        .
      end.
    end.
    if v-have-rvs-before = yes
    then do:
        for each buf_rvs-line_before no-lock
           where buf_rvs-line_before.rvs-code = buf_rvs-doc_before.rvs-code
             and buf_rvs-line_before.obj-type = buf_trn-doc.obj-type
             and buf_rvs-line_before.obj-code = buf_trn-doc.obj-code
             and buf_rvs-line_before.gds-code = buf_goods.gds-code
        :
        assign
          before_qnty        = before_qnty        + buf_rvs-line_before.state-measure-qnty
          before_temperature = before_temperature + buf_rvs-line_before.state-temperature
                                            * buf_rvs-line_before.state-measure-qnty
          before_cli-qnty    = before_cli-qnty    + buf_rvs-line_before.state-measure-cli-qnty
        .
        if lookup( varstfactpl, "auto-tank,inv" ) = 0 then do:
            assign
              v-delta-mass = v-delta-mass
                +
                buf_rvs-line_before.state-measure-cli-qnty
              doc-line_1st-run = no
            .
        end.
        put stream out-stream
            ":"         format "X(1)"           at 16
            single-line format "X(93)"
            ":"         format "X(1)"
          skip
            ":"         format "X(1)"           at 16
            "По замеру в резервуаре"    format "X(22)"           at 16 + 2
            ":"         format "X(1)"           at 16 + 25
            ":"         format "X(1)"           at 16 + 40
            ":"         format "X(1)"           at 16 + 50
            ":"         format "X(1)"           at 16 + 74
            ":"         format "X(1)"           at 16 + 94
          skip
            ":"         format "X(1)"           at 16
            "ДО слива"  format "X(8)"           at 16 + 2
            ":"         format "X(1)"           at 16 + 25
        .
    if v-have-rvs-before = yes
    then do:
        if buf_rvs-line_before.state-measure-qnty <> ?
            then put stream out-stream
                buf_rvs-line_before.state-measure-qnty
                                            format "zz,zz9.999"    at right-field( 16 + 40 - 2, 10)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 40 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 40
    .
    if v-have-rvs-before = yes
    then do:
        if buf_rvs-line_before.state-temperature <> ?
            then put stream out-stream
                buf_rvs-line_before.state-temperature
                                            format "->>9.99"    at right-field( 16 + 50 - 1, 7)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 50 - 1, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 50
    .
    if v-have-rvs-before = yes
    then do:
        if buf_rvs-line_before.state-density <> ?
            then put stream out-stream
                buf_rvs-line_before.state-density
                                            format "9.9999999999"    at right-field( 16 + 74 - 2, 12)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 74 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 74
    .
    if v-have-rvs-before = yes
    then do:
        if buf_rvs-line_before.state-measure-cli-qnty <> ?
            then put stream out-stream
                buf_rvs-line_before.state-measure-cli-qnty
                                            format "zzz,zzz,zz9.999"    at right-field( 16 + 94 - 2, 15)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 94 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 94
    .
        end.
        assign
          before_temperature = before_temperature / before_qnty
          before_density     = before_cli-qnty    / before_qnty
        .
    end.
    if doc-line_1st-run = yes
    then do:
      assign
        v-delta-mass = buf_doc-line.doc-qnty * buf_doc-line.doc-density
      .
      if lookup( varstfactpl, "auto-tank,inv" ) > 0 then do:
        assign
          v-delta-mass = v-delta-mass - v-tank-weight-dec.
          doc-line_1st-run = no
        .
      end.
    end.
    if v-have-rvs-after = yes
    then do:
        for each buf_rvs-line_after no-lock
           where buf_rvs-line_after.rvs-code = buf_rvs-doc_after.rvs-code
             and buf_rvs-line_after.obj-type = buf_trn-doc.obj-type
             and buf_rvs-line_after.obj-code = buf_trn-doc.obj-code
             and buf_rvs-line_after.gds-code = buf_goods.gds-code
        :
        assign
          after_qnty        = after_qnty        + buf_rvs-line_after.state-measure-qnty
          after_temperature = after_temperature + buf_rvs-line_after.state-temperature
                                            * buf_rvs-line_after.state-measure-qnty
          after_cli-qnty    = after_cli-qnty    + buf_rvs-line_after.state-measure-cli-qnty
        .
        if lookup( varstfactpl, "auto-tank,inv" ) = 0 then do:
            assign
              v-delta-mass = v-delta-mass
                -
                buf_rvs-line_after.state-measure-cli-qnty
              doc-line_1st-run = no
            .
        end.
        put stream out-stream
          skip
            ":"         format "X(1)"           at 16
            single-line format "X(93)"
            ":"         format "X(1)"
          skip
            ":"         format "X(1)"           at 16
            "По замеру в резервуаре"    format "X(22)"           at 16 + 2
            ":"         format "X(1)"           at 16 + 25
            ":"         format "X(1)"           at 16 + 40
            ":"         format "X(1)"           at 16 + 50
            ":"         format "X(1)"           at 16 + 74
            ":"         format "X(1)"           at 16 + 94
          skip
            ":"         format "X(1)"           at 16
            "ПОСЛЕ слива"  format "X(11)"       at 16 + 2
            ":"         format "X(1)"           at 16 + 25
        .
    if v-have-rvs-after = yes
    then do:
        if buf_rvs-line_after.state-measure-qnty <> ?
            then put stream out-stream
                buf_rvs-line_after.state-measure-qnty
                                            format "zz,zz9.999"    at right-field( 16 + 40 - 2, 10)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 40 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 40
    .
    if v-have-rvs-after = yes
    then do:
        if buf_rvs-line_after.state-temperature <> ?
            then put stream out-stream
                buf_rvs-line_after.state-temperature
                                            format "->>9.99"    at right-field( 16 + 50 - 1, 7)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 50 - 1, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 50
    .
    if v-have-rvs-after = yes
    then do:
        if buf_rvs-line_after.state-density <> ?
            then put stream out-stream
                buf_rvs-line_after.state-density
                                            format "9.9999999999"    at right-field( 16 + 74 - 2, 12)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 74 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 74
    .
    if v-have-rvs-after = yes
    then do:
        if buf_rvs-line_after.state-measure-cli-qnty <> ?
            then put stream out-stream
                buf_rvs-line_after.state-measure-cli-qnty
                                            format "zzz,zzz,zz9.999"    at right-field( 16 + 94 - 2, 15)
            .
    end.
    else do:
        put stream out-stream
          "0"
                                      format "X(1)"    at right-field( 16 + 94 - 2, 1)
        .
    end.
    put stream out-stream
        ":"         format "X(1)"           at 16 + 94
    .
        end.
        assign
          after_temperature = after_temperature / after_qnty
          after_density     = after_cli-qnty    / after_qnty
        .
    end.
        put stream out-stream
          skip
            single-line        format "X(95)"        at 16
        .
      end.
    put stream out-stream
      skip (2)
      space (15) "Погрешность измерений "
    .
    assign v-mass-pogresh = v-InfoSectionsTotal:TankWeightTotal * pogresh.
    if v-mass-pogresh = ? then assign v-mass-pogresh = 0 .
    put stream out-stream
      v-mass-pogresh        format "zzz,zzz,zz9.999"  at right-field( 90, 15)   " кг"
      skip space (15) "Отличие составило "
    .
    if v-delta-mass = ? then assign v-delta-mass = 0 .
    if v-delta-mass > 0 then do:
      assign
        v-nedost    = yes
        v-delta-res = v-delta-mass - v-mass-pogresh  .
    end.
    else do:
      assign
        v-nedost    = no
        v-delta-res = - v-delta-mass - v-mass-pogresh .
    end.
    if v-delta-res  = ? then assign v-delta-res = 0 .
    if v-delta-mass < 0 then assign v-delta-mass = - v-delta-mass .
    put stream out-stream
      v-delta-mass          format "zzz,zzz,zz9.999"  at right-field( 90, 15)
      " кг"
    .
    if v-delta-mass > v-mass-pogresh then do:
        put stream out-stream
          skip space (15) "Количество, превышающее погрешность "  v-delta-res  format "zzz,zzz,zz9.999"  at right-field( 90, 15)   " кг"
        .
    end.
    put stream out-stream
      skip (2)
      space (15) "Оператор АЗС "
      v-operator   format "X(35)"   at (15 + 25)
      " ________________ (подпись)"
      skip(1)
      space (15) "Менеджер АЗС "
      "________________"   format "X(35)"   at (15 + 25)
      " ________________ (подпись)"
      skip(1)
      space (15) "Водитель автоцистерны _____________________________________ ________________ (фамилия, подпись)"
    .
    run print-footer in this-procedure (
        input buf_trn-doc.host-code
    ).
    page stream out-stream.
    delete object v-InfoSectionsTotal.
end.
output stream out-stream close.
if session :set-wait-state( "" ) then.
if v-have-petrol = yes
then do:
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
procedure print-footer :
do
on error undo, return error
:
define input parameter p-host-code  as integer      no-undo.
    define variable v-main-boss     as character     no-undo.
    define variable v-main-buh      as character     no-undo.
    define buffer buf_clients       for ub.clients .
    define buffer buf_firm          for ub.firm .
    define buffer buf_sysconf       for ub.sysconf .
    find first buf_clients no-lock
        where buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = p-host-code
    .
    find first buf_firm no-lock
        where buf_firm.firm-code = buf_clients.obj-code
    .
    assign
        v-main-boss = buf_firm.director
        v-main-buh  = buf_firm.gen-acct
    .
    find first buf_sysconf no-lock
        where buf_sysconf.host-code = p-host-code
    .
    assign
        v-main-buh  = buf_sysconf.snr-accnt
    .
    put stream Out-stream
      skip (1)
      space (15) "Руководитель предприятия "
      v-main-boss   format "X(25)"   at (15 + 35)
      " ________________ (подпись)"
      skip (1)
      space (15) "Гл. бухгалтер            "
      v-main-buh   format "X(25)"   at (15 + 35)
      " ________________ (подпись)"
    .
end.
end procedure.
