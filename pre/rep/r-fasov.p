block-level on error undo, throw.
define input parameter p-mainmenu-handle  as handle           no-undo.
define input parameter p-trn-doc-recid as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-fasov.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-fasov.p $":U .
define variable vss-description as character no-undo init "Лист журнала фасовочных работ.".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#report-num    as integer      no-undo.
define variable vss-include-info5 as character format "X(65)" no-undo
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
    field   num_ser          as character
    field   docdate             as character
    field   gds_name         as character
    field   seria            as character
    field   qnty             as decimal
    field   price            as decimal
    field   gds_name1        as character
    field   qnty1            as decimal
    field   price1           as decimal
    field   sum              as decimal
    field   last_date        as character
    index pi is primary unique xl-line-id
.
define variable v-r-fasxl-current-data-row     as integer      no-undo.
define variable v-r-fasxl-cell-file-name       as character    no-undo.
define variable v-r-fasxl-data-file-name       as character    no-undo.
procedure r-fasxl-init :
    define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data on error undo, return error :
    assign
        v-r-fasxl-current-data-row = 0
    .
    run gbl/_tmpfile.p ( input "xd", input ".txt", output v-r-fasxl-data-file-name ).
    output stream excel-line to value( v-r-fasxl-data-file-name ).
    run gbl/_tmpfile.p ( input "xc", input ".txt", output v-r-fasxl-cell-file-name ).
    output stream excel-cell to value( v-r-fasxl-cell-file-name ).
    if printrubl
    then do:
        run r-fasxl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run r-fasxl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "1":U
        ).
    end.
    run r-fasxl-write-cell-data in this-procedure (
          input "columnList":U
        , input "num_ser,docdate,gds_name,seria,qnty,price,gds_name1,qnty1,price1,sum,last_date":U
    ).
    run r-fasxl-write-cell-data in this-procedure (
          input "columnType":U
        , input "S,S,S,S,D,D,S,D,D,D,S":U
    ).
    run r-fasxl-write-cell-data in this-procedure (
          input "columnAmount":U
        , input "11":U
    ).
end.
end procedure.
procedure r-fasxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/fas_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-r-fasxl-cell-file-name.
        export v-r-fasxl-data-file-name.
    output close.
end.
end procedure.
procedure r-fasxl-write-cell-data :
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
procedure r-fasxl-write-line-data :
define input parameter p-num-ser          as character         no-undo.
define input parameter p-docdate             as character              no-undo.
define input parameter p-gds-name         as character              no-undo.
define input parameter p-seria            as character         no-undo.
define input parameter p-qnty             as decimal           no-undo.
define input parameter p-price            as decimal           no-undo.
define input parameter p-gds-name1        as character              no-undo.
define input parameter p-qnty1            as decimal           no-undo.
define input parameter p-price1           as decimal           no-undo.
define input parameter p-sum              as decimal           no-undo.
define input parameter p-last-date        as character              no-undo.
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
        v-r-fasxl-current-data-row = v-r-fasxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = "LD":U
        buf_temp_line-data.xl-line-id   = v-r-fasxl-current-data-row
        buf_temp_line-data.num_ser      = p-num-ser
        buf_temp_line-data.docdate         = p-docdate
        buf_temp_line-data.gds_name     = p-gds-name
        buf_temp_line-data.seria        = p-seria
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.gds_name1    = p-gds-name1
        buf_temp_line-data.qnty1        = p-qnty1
        buf_temp_line-data.price1       = p-price1
        buf_temp_line-data.sum          = p-sum
        buf_temp_line-data.last_date    = p-last-date
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        chr(9)   buf_temp_line-data.num_ser
        chr(9)   buf_temp_line-data.docdate
        chr(9)   buf_temp_line-data.gds_name
        chr(9)   buf_temp_line-data.seria
        chr(9)   buf_temp_line-data.qnty
        chr(9)   buf_temp_line-data.price
        chr(9)   buf_temp_line-data.gds_name1
        chr(9)   buf_temp_line-data.qnty1
        chr(9)   buf_temp_line-data.price1
        chr(9)   buf_temp_line-data.sum
        chr(9)   buf_temp_line-data.last_date
        chr(10)
    .
end.
end procedure.
procedure r-fasxl-run-excel :
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
        v-template-file-name    = search( "exe/fas_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?  or v-template-file-name = "":U  then do:
        message  "Ошибка имени файла шаблона." view-as alert-box error.
    end.
    if v-vb-file-name = ?  or v-vb-file-name = "":U then do:
        message  "Ошибка имени файла кода обработки."   view-as alert-box error.
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
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
    define shared variable sort-name    as logical          no-undo.
    define shared variable sort-gr      as logical          no-undo.
    define stream out-stream .
    define variable v-line-counter  as integer      no-undo.
    define variable v-single-line   as character    no-undo.
    define variable v-cli-name      as character    no-undo.
    define variable v-obj-name      as character    no-undo.
    define variable v-first-line    as logical      no-undo.
    define variable tot-sum as decimal   no-undo .
    define variable tot-qnty as decimal   no-undo .
    define variable b-code as integer   no-undo .
    define buffer buf_trn-doc   for trn-doc.
    define buffer buf_goods     for goods.
    define buffer buf_parts     for parts.
    define buffer buf_clients   for clients.
    define buffer buf_doc-line  for doc-line.
    define buffer buf_gds-dtl   for gds-dtl.
    define variable v-sort-prod         as character         no-undo.
    define variable v-par-type          as character         no-undo.
    run gbl/conf-rd.p ( input "sort-prd", input "", input "", input 0, input "", input "", input "", input no, output v-sort-prod, output v-par-type) no-error.
    if error-status :error then  assign  v-sort-prod = "no" .
DEFINE temp-table temp-gds no-undo
    field   artic            as char
    field   prod-type        as char
    field   prod-code        as integer
    field   part-code        like parts.part-code
    field   in-code          like parts.in-code
    field   gds-code         as integer
    field   gds-name         as char
    field   gds-name1        as char
    field   grp-name         as char
    field   upak             as decimal
    field   qnty             as decimal
    field   price            as decimal
    field   qnty1            as decimal
    field   price1           as decimal
    field   sum              as decimal
    field   num-ser          as character
    field   seria            as character
    field   line-num         like doc-line.line-num
    field   data             as date
    field   last-date        as date
    index pi  is primary   artic  prod-type prod-code
    index pi1              gds-name
    index pi2              grp-name
    index pi3              line-num
.
    find first buf_trn-doc no-lock where recid( buf_trn-doc ) = p-trn-doc-recid .
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.obj-type
           and buf_clients.obj-code = buf_trn-doc.obj-code
    .
    assign  v-obj-name = string( buf_clients.obj-name )  .
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.cli-type
           and buf_clients.obj-code = buf_trn-doc.cli-code
    .
    if available buf_clients then  assign  v-cli-name = string( buf_clients.obj-name ) .
    else                           assign  v-cli-name = "" .
    define variable v-attr-value  as character no-undo .
    define variable v-attr-type   as character no-undo .
    define variable v-osnov       as character initial "" no-undo .
    define variable v-ser_on_pack   as character.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'ser_on_pack':U ,
                       output v-ser_on_pack ,
                       output v-attr-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'nids':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    assign v-osnov = v-attr-value .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'dids':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    if v-attr-value <> ? and trim(v-attr-value) <> "" then assign v-osnov = v-osnov + " от " + v-attr-value .
    assign
        v-single-line       = fill( "-", 195 )
        v-line-counter      = 0
    .
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
    run r-fasxl-init in this-procedure .
    form header
        space(1) v-single-line format "X(195)" skip    'Продолжение - на следующей странице' at 90 skip
        with frame BottomFrame width 198 page-bottom no-labels no-box .
    view stream out-stream frame BottomFrame .
if session :set-wait-state( "compiler" ) then.
    put stream out-stream
        space(1 )  v-obj-name  format "X(60)"
        skip space( 60 ) "Лист журнала фасовочных работ № "   buf_trn-doc.doc-code   format "X(14)"
        " от " ( if buf_trn-doc.status_ <> 'факт':U then string(buf_trn-doc.doc-date) + "   Статус: " + caps(buf_trn-doc.status_) else string(buf_trn-doc.fact-date) )  format "X(50)"
        skip space( 1 ) string( "Поставщик (отправитель): " + v-cli-name + v-osnov )  format "X(160)"
        skip
    .
    run r-fasxl-write-cell-data in this-procedure ( input "h_docName":U, input string( buf_trn-doc.doc-code + " от " + ( if buf_trn-doc.status_ <> 'факт':U then string(buf_trn-doc.doc-date) + "   Статус: " + caps(buf_trn-doc.status_) else string(buf_trn-doc.fact-date) ))) .
    run r-fasxl-write-cell-data in this-procedure ( input "h_Obj":U, input v-obj-name) .
    run r-fasxl-write-cell-data in this-procedure ( input "h_cliFrom":U, input string( "Поставщик (отправитель): " + v-cli-name + v-osnov )) .
    run print-header in this-procedure .
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
      find first  buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-type = buf_doc-line.prod-type and buf_goods.prod-code = buf_doc-line.prod-code .
      run gds-attr-value in this-procedure (
           input  buf_goods.gds-code,
           input  'fasovka':U,
           output v-attr-value,
           output v-attr-type )
           .
      if lookup(v-attr-value, 'true,yes':u) = 0 then next .
      for each buf_parts no-lock
        where buf_parts.out-code   = buf_doc-line.doc-code
          and buf_parts.obj-type   = buf_doc-line.obj-type
          and buf_parts.obj-code   = buf_doc-line.obj-code
          and buf_parts.artic      = buf_doc-line.artic
          and buf_parts.prod-type  = buf_doc-line.prod-type
          and buf_parts.prod-code  = buf_doc-line.prod-code
        :
        create temp-gds .
        assign
          temp-gds.artic       = buf_doc-line.artic
          temp-gds.prod-type   = buf_doc-line.prod-type
          temp-gds.prod-code   = buf_doc-line.prod-code
          temp-gds.part-code   = buf_parts.part-code
          temp-gds.in-code     = buf_parts.in-code
          temp-gds.gds-code    = buf_goods.gds-code
          temp-gds.gds-name1   = buf_goods.gds-name
          temp-gds.gds-name    = buf_goods.engl-name
          temp-gds.grp-name    = buf_goods.grp-name
          temp-gds.upak        = if buf_goods.qnty-cart = 0 then 1 else buf_goods.qnty-cart
          temp-gds.qnty        = buf_parts.fact-qnty
          temp-gds.qnty1       = buf_parts.fact-qnty / temp-gds.upak
          temp-gds.line-num    = buf_doc-line.line-num
          temp-gds.data        = if buf_trn-doc.status_ <> 'факт':U then buf_trn-doc.doc-date else buf_trn-doc.fact-date
          temp-gds.last-date   = buf_parts.last-date
          temp-gds.num-ser     = entry(1,buf_parts.part-code,' ')
        .
        if num-entries(buf_parts.part-code,' ') > 1 then do:
          assign temp-gds.seria = entry(2,buf_parts.part-code,' ') .
          if num-entries(buf_parts.part-code,' ') > 2 then assign temp-gds.seria = temp-gds.seria + entry(3,buf_parts.part-code,' ') .
        end.
        if trim(temp-gds.gds-name) = "" then  assign temp-gds.gds-name = temp-gds.gds-name1 .
        if temp-gds.num-ser = ? then assign temp-gds.num-ser = ""  .
        if temp-gds.seria = ?   then assign temp-gds.seria = ""  .
        if buf_trn-doc.status_ = 'факт':U then do:
          assign
            tot-sum  = 0
            tot-qnty = 0
          .
          FOR EACH buf_gds-dtl NO-LOCK
            WHERE buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
              and buf_gds-dtl.artic     = buf_doc-line.artic
              and buf_gds-dtl.prod-type = buf_doc-line.prod-type
              and buf_gds-dtl.prod-code = buf_doc-line.prod-code
            :
            assign
              tot-sum  = tot-sum  + buf_gds-dtl.doc-qnty * buf_gds-dtl.cur-base
              tot-qnty = tot-qnty + buf_gds-dtl.doc-qnty
            .
          end.
          if tot-qnty <> 0 then assign temp-gds.price = tot-sum / tot-qnty  .
        END.
        else do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-gds.gds-code
  ,input  ?
  ,output b-code
  ) no-error .
          if not error-status :error then do:
            find last price-list no-lock
              where price-list.obj-type  = buf_doc-line.obj-type
                and price-list.obj-code  = buf_doc-line.obj-code
                and price-list.b-code    = b-code
            use-index fact-close no-error .
            if available price-list then assign temp-gds.price = price-list.price-sale .
          end .
        end .
        assign
          temp-gds.price1      = temp-gds.price * temp-gds.upak
          temp-gds.sum         = temp-gds.qnty * temp-gds.price
        .
      end.
    end.
    if v-sort-prod = "yes" then do:
      if sort-gr = yes then do:
        if sort-name = yes then do:
          for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by  temp-gds.grp-name by temp-gds.gds-name :
            if  first-of( temp-gds.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if first-of(temp-gds.grp-name) then do:
              run print-group-line in this-procedure ( input temp-gds.grp-name ).
            end.
            if last( temp-gds.gds-name ) and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.
        else do:
          for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by temp-gds.grp-name by temp-gds.line-num :
            if  first-of( temp-gds.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if first-of( temp-gds.grp-name ) then do:
              run print-group-line in this-procedure ( input temp-gds.grp-name ).
            end.
            if last( temp-gds.line-num ) and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.
      end.
      else do:
        if sort-name = yes then do:
          for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by temp-gds.gds-name :
            if  first-of( temp-gds.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if last( temp-gds.gds-name ) and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.
        else do:
          for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by temp-gds.line-num :
            if  first-of( temp-gds.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if last( temp-gds.line-num ) and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.
      end.
    end.
    else do:
      if sort-gr = yes then do:
        if sort-name = yes then do:
          for each temp-gds break by temp-gds.grp-name  by temp-gds.gds-name :
            if first-of(temp-gds.grp-name) then do:
              run print-group-line in this-procedure ( input temp-gds.grp-name ).
            end.
            if last( temp-gds.gds-name ) and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.
        else do:
          for each temp-gds break by temp-gds.grp-name by temp-gds.line-num :
            if first-of( temp-gds.grp-name ) then do:
              run print-group-line in this-procedure ( input temp-gds.grp-name ).
            end.
            if last( temp-gds.line-num ) and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.
      end.
      else do:
        if sort-name = yes then do:
          for each temp-gds break by temp-gds.gds-name  :
            if last( temp-gds.gds-name ) and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.
        else do:
          for each temp-gds break by temp-gds.line-num    :
            if last( temp-gds.line-num ) and line-counter( Out-Stream ) + 12 + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.
      end.
    end.
    run print-total-result in this-procedure .
       put stream out-stream
       skip
        space(20 )   "Сдал___________________                                                                                Принял__________________________ "   format "X(140)" skip.
    run r-fasxl-close in this-procedure .
    hide stream Out-Stream frame BottomFrame .
    output stream out-stream close.
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
procedure PrintTitul :
  do on error undo, return error return-value :
    if line-counter( Out-Stream ) + 2 < page-size( Out-Stream ) then do:
      put stream out-stream skip space(1) "|" v-single-line format "X(193)" "|" .
    end.
    page stream Out-Stream .
    run print-header in this-procedure .
  end.
end procedure.
procedure print-header :
  do on error undo, return error:
    assign  v-first-line = yes .
    put stream out-stream
    skip
    space(1)       v-single-line   format "X(195)"
    skip space(1)  "|"
        "Выдано в работу"       at center-field(1 + 1, 1 + 104, 15)
        "|"                     at 1 + 104
        "Расфасовано и сдано"   at center-field(1 + 104, 1 + 186, 19)
        "|"                     at 1 + 186
        "Срок"                  at center-field(1 + 186, 1 + 195, 4)
        "|"                     at 1 + 195
    skip
    space(1)   "|"     v-single-line   format "X(184)"   "|"
        "|"                     at 1 + 195
    skip space(1)  "|"
        "№ ф/с"                 at center-field(1 + 1, 1 + 11, 7)
        "|"                     at 1 + 11
        "дата"                  at center-field(1 + 11, 1 + 20, 4)
        "|"                     at 1 + 20
        "номенкл"               at center-field(1 + 20, 1 + 28, 7)
        "|"                     at 1 + 28
        "Наименование товара (сырья)"   at 1 + 28 + 2
        "|"                     at 1 + 63
        "Ед."                   at center-field(1 + 63, 1 + 67, 3)
        "|"                     at 1 + 67
        "Серия"                 at center-field(1 + 67, 1 + 78, 5)
        "|"                     at 1 + 78
        "Кол-во"                at center-field(1 + 78, 1 + 89, 6)
        "|"                     at 1 + 89
        "Цена розн."            at center-field(1 + 89, 1 + 104, 10)
        "|"                     at 1 + 104
        "Наименование готовой продукции"   at 1 + 104 + 2
        "|"                     at 1 + 139
        "Ед."                   at center-field(1 + 139, 1 + 143, 3)
        "|"                     at 1 + 143
        "Кол-во"                at center-field(1 + 143, 1 + 154, 6)
        "|"                     at 1 + 154
        "Цена розн."            at center-field(1 + 154, 1 + 169, 10)
        "|"                     at 1 + 169
        "Сумма розн."           at center-field(1 + 169, 1 + 186, 11)
        "|"                     at 1 + 186
        "годности"              at center-field(1 + 186, 1 + 195, 8)
        "|"                     at 1 + 195
    skip space(1)  "|"
        "|"                     at 1 + 11
        "|"                     at 1 + 20
        "номер"                 at center-field(1 + 20, 1 + 28, 5)
        "|"                     at 1 + 28
        "|"                     at 1 + 63
        "изм"                   at center-field(1 + 63, 1 + 67, 3)
        "|"                     at 1 + 67
        "|"                     at 1 + 78
        "|"                     at 1 + 89
        "|"                     at 1 + 104
        "|"                     at 1 + 139
        "изм"                   at center-field(1 + 139, 1 + 143, 3)
        "|"                     at 1 + 143
        "|"                     at 1 + 154
        "|"                     at 1 + 169
        "|"                     at 1 + 186
        "|"                     at 1 + 195
    skip space(1)
        "|" v-single-line format "X(193)" "|"
    .
  end.
end procedure.
procedure print-line :
    put stream out-stream
            skip space(1)  "|"
                v-ser_on_pack                format "X(9)"
                "|"   at 1 + 11
                temp-gds.data                format "99/99/99"
                "|"   at 1 + 20
                "|"   at 1 + 28
                temp-gds.gds-name            format "X(34)"
                "|"   at 1 + 63
                "|"   at 1 + 67
                temp-gds.num-ser             format "X(10)"
                "|"   at 1 + 78
                temp-gds.qnty1                format "->>>>>9.99"
                "|"   at 1 + 89
                temp-gds.price1              format "->>>>>>>>>9.99"
                "|"   at 1 + 104
                temp-gds.gds-name1           format "X(34)"
                "|"   at 1 + 139
                "|"   at 1 + 143
                temp-gds.qnty                format "->>>>>9.99"
                "|"   at 1 + 154
                temp-gds.price              format "->>>>>>>>>9.99"
                "|"   at 1 + 169
                temp-gds.sum                 format "->>>>>>>>>>>9.99"
                "|"   at 1 + 186
                temp-gds.last-date           format "99/99/99"
                "|"   at 1 + 195
        .
      run r-fasxl-write-line-data in this-procedure (
                  input v-ser_on_pack
                , input string(temp-gds.data, "99/99/99")
                , input temp-gds.gds-name
                , input temp-gds.num-ser
                , input temp-gds.qnty1
                , input temp-gds.price1
                , input temp-gds.gds-name1
                , input temp-gds.qnty
                , input temp-gds.price
                , input temp-gds.sum
                , input if string(temp-gds.last-date) = ? then "" else string(temp-gds.last-date, "99/99/9999" )
      ).
      assign v-line-counter      = v-line-counter    + 1  .
      if line-counter( Out-Stream ) + 2 + 2 > page-size( Out-Stream ) then do:
        page stream Out-Stream .
        run print-header in this-procedure .
      end.
end procedure.
procedure print-group-line :
  define input parameter p-grp-name   as character no-undo .
  if line-counter( Out-Stream ) + 2 + 2 + 1 > page-size( Out-Stream ) then do:
    page stream out-stream.
    run print-header in this-procedure .
  end.
  if v-first-line <> yes then do:
    put stream out-stream  skip space(1) "|" v-single-line format "X(193)" "|" .
  end.
  put stream out-stream  skip space(1) "|   ***  Группа:  "  + p-grp-name format "X(110)" "|" at 1 + 195 .
end procedure.
procedure print-prod :
  do on error undo, return error :
    if line-counter( Out-Stream ) + 2 + 2 + 1 > page-size( Out-Stream ) then do:
        page stream out-stream.
        run print-header in this-procedure .
    end.
    if v-first-line <> yes then do:
      put stream out-stream  skip space(1) "|" v-single-line format "X(193)" "|" .
    end.
    find first buf_clients no-lock where buf_clients.obj-type = temp-gds.prod-type and buf_clients.obj-code = temp-gds.prod-code  .
    put stream out-stream  skip space(1) "| *** Производитель: "  + buf_clients.obj-name format "X(110)" "|" at 1 + 195 .
  end.
end procedure.
procedure print-total-result :
  do on error undo, return error :
    put stream out-stream  skip space(1)  v-single-line format "X(195)" .
  end.
end procedure.
procedure print-note :
  do on error undo, return error :
    put stream out-stream  skip(1) space(22)  "Всего строк: "  v-line-counter  format ">>>>>9"  .
  end.
end procedure.
