block-level on error undo, throw.
define input parameter p-mainmenu-handle  as handle           no-undo.
define input parameter p-doc-code           as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-nn9.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/wth-nn9.p $":U .
define variable vss-description as character no-undo init "Форма НН-9-ДО.".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable g#report-num    as integer      no-undo.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_wthgds_price-group no-undo
    field gds-code      as integer
    field price-rubl    as decimal
    field vat-pc        as decimal
    field sum-rubl      as decimal
    field sum-base      as decimal
    field sum-vat-rubl  as decimal
    field sum-vat-base  as decimal
    field price-base    as decimal
    field qnty          as decimal
    field fact-qnty     as decimal
    index pi is primary unique
        gds-code
        price-rubl
        vat-pc
.
define temp-table temp_wthgds_price-goods   no-undo
    field gds-code      as integer
    field sum-rubl      as decimal
    field sum-base      as decimal
    field sum-vat-rubl  as decimal
    field sum-vat-base  as decimal
    field vat-pc        as decimal
    field qnty          as decimal
    field fact-qnty     as decimal
    field price-rubl    as decimal
    field price-base    as decimal
    index pi is primary unique
        gds-code
.
procedure wthgds-calc-price-group:
define input parameter p-doc-code as character no-undo.
    define variable v-gds-qnty          as decimal      no-undo.
    define variable v-gds-price-rubl    as decimal      no-undo.
    define buffer buf_wth-parts                 for ub.wth-parts.
    define buffer buf_wth-par                   for ub.wth-par.
    define buffer buf_temp_wthgds_price-group   for temp_wthgds_price-group.
do
for buf_wth-parts
  , buf_wth-par
  , buf_temp_wthgds_price-group
on error undo, return error
:
    empty temp-table temp_wthgds_price-group.
    for each buf_wth-parts no-lock
       where buf_wth-parts.out-code = p-doc-code
    :
        find first buf_wth-par no-lock
             where buf_wth-par.wth-code = buf_wth-parts.wth-code
               and buf_wth-par.par-code = buf_wth-parts.par-code
        .
        assign
            v-gds-qnty          = buf_wth-par.par-val * buf_wth-parts.fact-qnty
            v-gds-price-rubl    = round( ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl ) / v-gds-qnty, 2 )
        .
        find first buf_temp_wthgds_price-group no-lock
             where buf_temp_wthgds_price-group.gds-code     = buf_wth-parts.gds-code
               and buf_temp_wthgds_price-group.price-rubl   = v-gds-price-rubl
               and buf_temp_wthgds_price-group.vat-pc       = buf_wth-parts.vat-pc
        no-error.
        if not available buf_temp_wthgds_price-group
        then do:
            create buf_temp_wthgds_price-group.
            assign
                buf_temp_wthgds_price-group.gds-code        = buf_wth-parts.gds-code
                buf_temp_wthgds_price-group.price-rubl      = v-gds-price-rubl
                buf_temp_wthgds_price-group.vat-pc          = buf_wth-parts.vat-pc
                buf_temp_wthgds_price-group.price-base      = round( ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base ) / v-gds-qnty, 2 )
                buf_temp_wthgds_price-group.qnty            = 0.0
                buf_temp_wthgds_price-group.fact-qnty       = 0.0
                buf_temp_wthgds_price-group.sum-rubl        = 0.0
                buf_temp_wthgds_price-group.sum-base        = 0.0
                buf_temp_wthgds_price-group.sum-vat-rubl    = 0.0
                buf_temp_wthgds_price-group.sum-vat-base    = 0.0
            .
        end.
        assign
            buf_temp_wthgds_price-group.qnty            = buf_temp_wthgds_price-group.qnty          + v-gds-qnty
            buf_temp_wthgds_price-group.fact-qnty       = buf_temp_wthgds_price-group.fact-qnty     + buf_wth-parts.fact-qnty
            buf_temp_wthgds_price-group.sum-rubl        = buf_temp_wthgds_price-group.sum-rubl      + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl )
            buf_temp_wthgds_price-group.sum-base        = buf_temp_wthgds_price-group.sum-base      + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base )
            buf_temp_wthgds_price-group.sum-vat-rubl    = buf_temp_wthgds_price-group.sum-vat-rubl  + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl * buf_wth-parts.vat-pc / 100.0 )
            buf_temp_wthgds_price-group.sum-vat-base    = buf_temp_wthgds_price-group.sum-vat-base  + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base * buf_wth-parts.vat-pc / 100.0 )
        .
    end.
end.
end procedure.
procedure wthgds-calc-price-goods:
define input parameter p-doc-code as character no-undo.
    define variable v-gds-qnty          as decimal      no-undo.
    define buffer buf_wth-parts                 for ub.wth-parts.
    define buffer buf_wth-par                   for ub.wth-par.
    define buffer buf_temp_wthgds_price-goods   for temp_wthgds_price-goods.
do
for buf_wth-parts
  , buf_wth-par
  , buf_temp_wthgds_price-goods
on error undo, return error
:
    empty temp-table buf_temp_wthgds_price-goods.
    for each buf_wth-parts no-lock
       where buf_wth-parts.out-code = p-doc-code
    :
        find first buf_wth-par no-lock
             where buf_wth-par.wth-code = buf_wth-parts.wth-code
               and buf_wth-par.par-code = buf_wth-parts.par-code
        .
        find first buf_temp_wthgds_price-goods no-lock
             where buf_temp_wthgds_price-goods.gds-code     = buf_wth-parts.gds-code
        no-error.
        if not available buf_temp_wthgds_price-goods
        then do:
            create buf_temp_wthgds_price-goods.
            assign
                buf_temp_wthgds_price-goods.gds-code        = buf_wth-parts.gds-code
                buf_temp_wthgds_price-goods.qnty            = 0.0
                buf_temp_wthgds_price-goods.fact-qnty       = 0.0
                buf_temp_wthgds_price-goods.sum-rubl        = 0.0
                buf_temp_wthgds_price-goods.sum-base        = 0.0
                buf_temp_wthgds_price-goods.sum-vat-rubl    = 0.0
                buf_temp_wthgds_price-goods.sum-vat-base    = 0.0
            .
        end.
        assign
            v-gds-qnty                                  = buf_wth-par.par-val * buf_wth-parts.fact-qnty
            buf_temp_wthgds_price-goods.qnty            = buf_temp_wthgds_price-goods.qnty          + v-gds-qnty
            buf_temp_wthgds_price-goods.fact-qnty       = buf_temp_wthgds_price-goods.fact-qnty     + buf_wth-parts.fact-qnty
            buf_temp_wthgds_price-goods.sum-rubl        = buf_temp_wthgds_price-goods.sum-rubl      + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl )
            buf_temp_wthgds_price-goods.sum-base        = buf_temp_wthgds_price-goods.sum-base      + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base )
            buf_temp_wthgds_price-goods.sum-vat-rubl    = buf_temp_wthgds_price-goods.sum-vat-rubl  + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl * buf_wth-parts.vat-pc / 100.0 )
            buf_temp_wthgds_price-goods.sum-vat-base    = buf_temp_wthgds_price-goods.sum-vat-base  + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base * buf_wth-parts.vat-pc / 100.0 )
            buf_temp_wthgds_price-goods.vat-pc          = buf_wth-parts.vat-pc
            buf_temp_wthgds_price-goods.price-rubl      = ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl ) / v-gds-qnty
            buf_temp_wthgds_price-goods.price-base      = ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base ) / v-gds-qnty
        .
    end.
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
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
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
run get-report-num in p-mainmenu-handle ( output g#report-num ).
run get-quest-print in p-mainmenu-handle ( output g#quest-print ).
    define stream PrnLibStream .
    define variable v-line-counter  as integer      no-undo.
    define variable v-single-line   as character    no-undo.
    define variable v-obj-name      as character    no-undo.
    define variable v-host-name     as character    no-undo.
    define variable v-first-line    as logical      no-undo.
    define buffer buf_wth-doc   for wth-doc.
    define buffer buf_goods     for goods.
    define buffer buf_wth-parts for wth-parts.
    define buffer buf_clients   for clients.
    define buffer buf_wth-ser   for wth-ser.
    define buffer buf_wealth    for wealth.
    define variable talon-qnty as decimal   no-undo .
    define variable talon-sum as decimal   no-undo .
    define variable str-qnty  as character no-undo .
    define variable s1  as character no-undo .
    define variable s2  as character no-undo .
    define variable v-operator  as character no-undo .
    define variable v-receiver  as character no-undo .
    define variable v-deliver   as character no-undo .
    define variable v-attr-type as character no-undo .
    find first buf_wth-doc no-lock where buf_wth-doc.doc-code = p-doc-code .
    find first buf_clients no-lock where buf_clients.obj-type = buf_wth-doc.obj-type and buf_clients.obj-code = buf_wth-doc.obj-code .
    assign  v-obj-name = string( buf_clients.obj-name )  .
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = buf_wth-doc.host-code .
    assign  v-host-name = string( buf_clients.obj-name )  .
    find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = buf_wth-doc.receiver no-error .
    if available buf_clients then  assign  v-receiver = buf_clients.obj-name .
    else do:
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input buf_wth-doc.doc-code ,
                        input 'wthreceiver':U ,
                       output v-receiver ,
                       output v-attr-type )  .
    end.
    find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = buf_wth-doc.deliver no-error .
    if available buf_clients then  assign  v-deliver = buf_clients.obj-name .
    else assign  v-deliver =  "___________________________________________" .
    find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = buf_wth-doc.operator no-error .
    if available buf_clients then  assign  v-operator = buf_clients.obj-name .
    else assign  v-operator = "___________________________________________" .
    assign
        v-single-line       = fill( "-", 132 )
        v-line-counter      = 0
    .
output stream PrnLibStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
    form header
        v-single-line format "X(120)" skip    'Продолжение - на следующей странице' at 90 skip
        with frame BottomFrame width 136 page-bottom no-labels no-box .
    view stream PrnLibStream frame BottomFrame .
if session :set-wait-state( "compiler" ) then.
    run wthgds-calc-price-group ( input buf_wth-doc.doc-code ) .
    for each temp_wthgds_price-group :
      assign
        v-line-counter      = v-line-counter    + 1
        talon-sum  = talon-sum  + temp_wthgds_price-group.sum-rubl
        talon-qnty = talon-qnty + temp_wthgds_price-group.fact-qnty
      .
    end.
    run rep/wp-rub.p ( talon-sum, output s1, output s2 ) .
    run rep/wp-qnty.p ( input talon-qnty , output str-qnty).
    put stream PrnLibStream         "Форма НН-9-ДО"  at 100  skip (2)
       space(10)  v-host-name  format "X(60)"      "УТВЕРЖДАЮ" at 90 skip (2)
       space(10)  v-obj-name   format "X(60)"     "___________________________________" at 80 skip
                                                  "             должность"              at 80 skip  (2)
                                                  "___________  ______________________" at 80 skip
                                                  "  подпись     расшифровка подписи"   at 80 skip  (2)
                                                  "'____' ___________________ 20 ____г" at 80 skip  (3)
       space( 60 ) "АКТ № "   buf_wth-doc.doc-code   format "X(14)"  skip
       space( 40 ) "уничтожения талонов на нефтепродукты от "  string(buf_wth-doc.doc-date,"99/99/9999") skip (2)
       space(10)   "Составлен комиссией из: представителей предприятия, назначенных приказом № ___ от ___________ в составе:"  skip (3)
       space(10)   "Председатель: "  v-operator format "x(50)"                       "______________________________________"  skip
       space(10)   "                                                                            (инициалы, фамилия)"           skip
       space(10)   "Члены комиссии: "                                                                                          skip
       space(10)   "              "  v-deliver  format "x(50)"                       "______________________________________"  skip
       space(10)   "                                                                            (инициалы, фамилия)"           skip (2)
       space(10)   "              "  v-receiver format "x(50)"                       "______________________________________"  skip
       space(10)   "                                                                            (инициалы, фамилия)"           skip (2)
       space(10)   string("На погашение талонов на нефтепродукты в количестве " + string(talon-qnty) + " (" + str-qnty +  ") штук")  format "X(120)"  skip
       space(10)   string("на сумму " + string(talon-sum,">>,>>>,>>>,>>9.99") + s2 + " (" + s1 + ")" )   format "X(120)"                       skip
       space(10)   "Пакеты/мешки, в которых хранились талоны были вскрыты, наличие талонов в них проверено, после чего  талоны" skip
       space(10)   "пересчитаны и сожжены"   skip
       space(10)   "Подписи:"                                                                                                  skip (2)
       space(10)   "Председатель: " v-operator format "x(30)"   "        ___________        ________________________________"  skip
       space(10)   "                                                      (подпись)               (инициалы, фамилия)"         skip (2)
       space(10)   "Члены комиссии:"                                                                                     skip
       space(10)   "              " v-deliver  format "x(30)"   "        ___________        ________________________________"  skip
       space(10)   "                                                      (подпись)               (инициалы, фамилия)"         skip (2)
       space(10)   "              " v-receiver format "x(30)"   "        ___________        ________________________________"  skip
       space(10)   "                                                      (подпись)               (инициалы, фамилия)"         skip
    .
    hide stream PrnLibStream frame BottomFrame .
    output stream PrnLibStream close.
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
