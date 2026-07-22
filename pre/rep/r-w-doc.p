block-level on error undo, throw.
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-doc-code       as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-w-doc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-w-doc.p $":U .
define variable vss-description as character no-undo init "Печатная форма движение материальных ценностей".
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
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def buffer buf_wth-doc  for ub.wth-doc.
def buffer buf_wth-line for ub.wth-line.
def buffer buf_wth-dtl  for ub.wth-dtl.
def buffer buf_clients  for ub.clients.
define buffer buf_host for ub.clients.
def var v-organization  like ub.clients.obj-name no-undo.
def var v-org-to        as char no-undo.
def var v-org-from      as char no-undo.
def var v-operator      like ub.clients.obj-name no-undo.
def var v-deliver       like ub.clients.obj-name no-undo.
def var v-receiver      like ub.clients.obj-name no-undo.
def var v-temp-string   as char no-undo.
def var v-temp-position as int  no-undo.
def var v-single-line   as char no-undo.
do
on error undo, return error
:
run get-report-num in parparentproc (
    output g#report-num
).
run get-quest-print in parparentproc (
    output g#quest-print
).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if session :set-wait-state( "compiler" ) then.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
assign v-single-line = fill("-", 124).
find first buf_wth-doc no-lock
     where buf_wth-doc.doc-code = p-doc-code
.
find first buf_clients no-lock
    where buf_clients.obj-type = buf_wth-doc.obj-type
      and buf_clients.obj-code = buf_wth-doc.obj-code
.
find first buf_host no-lock
    where buf_host.obj-type = 'орг':U
      and buf_host.obj-code = buf_wth-doc.host-code
.
assign
  v-organization = buf_clients.obj-name
.
for each buf_wth-line no-lock
     where buf_wth-line.doc-code = buf_wth-doc.doc-code
break by buf_wth-line.wth-code
:
    if not first(buf_wth-line.wth-code)
    then do:
      FORM HEADER
          v-single-line format "X(124)" AT 1 SKIP
          "Продолжение - на следующей странице" AT 30 SKIP
          with FRAME BottomFrame width 235 PAGE-BOTTOM NO-LABELS NO-BOX .
      VIEW STREAM out-stream FRAME BottomFrame .
      PAGE STREAM out-stream.
    end.
    find first ub.wth-place
         where ub.wth-place.host-code = buf_clients.host-code
           and ub.wth-place.obj-type  = buf_wth-doc.obj-type
           and ub.wth-place.obj-code  = buf_wth-doc.obj-code
           and ub.wth-place.w-p-code  = buf_wth-line.w-p-code
    no-error.
    find first buf_clients no-lock
        where buf_clients.obj-type = 'чел':U
          and buf_clients.obj-code = buf_wth-doc.operator
    no-error.
    assign
      v-operator = if available buf_clients then buf_clients.obj-name else '':U
    .
    find first buf_clients no-lock
        where buf_clients.obj-type = 'чел':U
          and buf_clients.obj-code = buf_wth-doc.deliver
    no-error.
    assign
      v-deliver = if available buf_clients then buf_clients.obj-name else '':U
    .
    find first buf_clients no-lock
        where buf_clients.obj-type = 'чел':U
          and buf_clients.obj-code = buf_wth-doc.receiver
    no-error.
    assign
      v-receiver = if available buf_clients then  buf_clients.obj-name else '':U
    .
    find first buf_clients no-lock
        where buf_clients.obj-type = buf_wth-doc.obj-type
          and buf_clients.obj-code = buf_wth-doc.obj-code
    .
    if buf_wth-doc.doc-type = 'при':U
    then assign
            v-org-from = buf_wth-doc.cli-name
            v-org-to   = buf_clients.obj-name + (if available wth-place
                                                    and wth-place.w-p-name <> ?
                                                 then ", " + wth-place.w-p-name else "")
    .
    else assign
            v-org-from = buf_clients.obj-name + (if available wth-place
                                                    and wth-place.w-p-name <> ?
                                                 then ", " + wth-place.w-p-name else "")
            v-org-to   = buf_wth-doc.cli-name
    .
    assign
        v-temp-string = "Д О К У М Е Н Т   №  " + string(buf_wth-doc.doc-code)
    .
    assign v-temp-position = center-field( 5, 130, length(v-temp-string) )         v-temp-string   = fill(" ", v-temp-position - 1) + v-temp-string.
    put stream out-stream
        skip
        buf_host.obj-name
        string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) )
                          format "X(12)"   at right-field(130 - 5, 12)
        skip
          buf_clients.obj-name
        skip(2)
            v-temp-string format "X(130)"
        skip
        "движения материальных ценностей"
                          format "X(31)"   at center-field( 5, 130, 31 )
        skip(2)
        space (5) "Смена: "
        buf_wth-doc.shift-name format "X(12)"
        " от "
        buf_wth-doc.shift-date format "99/99/9999"
    .
    find first ub.wealth no-lock
        where ub.wealth.wth-code = buf_wth-line.wth-code
    .
    put stream out-stream
        skip(1)
        space (5) "Наименование материальных ценностей: "
        space(44 - 37) ub.wealth.wth-name      format "X(65)"
        skip
        space (5) "Источник поступления: "
        space(44 - 22) v-org-from           format "X(65)"
        skip
        space (5) "Получатель: "
        space(44 - 12) v-org-to             format "X(65)"
        skip
        space (5) "Сумма движения материальных ценностей: "
        space(44 - 39) (if buf_wth-doc.status_ = 'факт':U
                                  then buf_wth-line.fact-sum
                                  else buf_wth-line.doc-sum)       format "z,zzz,zzz,zz9.99"
    .
        find first  buf_wth-dtl no-lock
            where buf_wth-dtl.doc-code = buf_wth-line.doc-code
              and buf_wth-dtl.wth-code = buf_wth-line.wth-code
        no-error.
        if available buf_wth-dtl
        then do:
            put stream out-stream
                skip(1)
                space (5) "Расшифровка суммы: "
            .
            for each ub.wth-par no-lock
               where ub.wth-par.wth-code = buf_wth-line.wth-code
            break by ub.wth-par.par-feat
            :
                find first buf_wth-dtl no-lock
                     where buf_wth-dtl.doc-code = buf_wth-line.doc-code
                       and buf_wth-dtl.wth-code = buf_wth-line.wth-code
                       and buf_wth-dtl.w-p-code = buf_wth-line.w-p-code
                       and buf_wth-dtl.par-code = ub.wth-par.par-code
                no-error.
                if first-of(ub.wth-par.par-feat)
                then do:
                    if not first(ub.wth-par.par-feat)
                    then do:
                        put stream out-stream
                          skip
                            v-single-line format "X(65)" at 40
                          skip(2)
                        .
                    end.
                    put stream out-stream
                        skip
                        v-single-line format "X(65)" at 40
                      skip
                        space (5 + 15)
                        ub.wth-par.par-feat format "X(15)"
                        "|" at 40
                        "Номинал" at center-field(40, 40 + 21, 7)
                        "|" at 40 + 21
                        "|" at 40 + 25
                        "Количество" at center-field(40 + 25, 40 + 38, 10)
                        "|" at 40 + 38
                        "|" at 40 + 42
                        "Сумма" at center-field(40 + 42, 40 + 64, 10)
                        "|" at 40 + 64
                    .
                end.
                put stream out-stream
                  skip
                    "|"  at 40
                    v-single-line format "X(63)"
                    "|"
                  skip
                    "|" at 40
                    string(ub.wth-par.par-val, "z,zzz,zz9") + " " + string(ub.wth-par.par-unit)
                                        format "X(19)"
                    "|" at 40 + 21
                    "x" at center-field(40 + 21, 40 + 25, 1)
                    "|" at 40 + 25
                .
                if available buf_wth-dtl
                then put stream out-stream
                    buf_wth-dtl.doc-sum / ub.wth-par.par-rate at center-field(40 + 25, 40 + 38, 10)
                .
                put stream out-stream
                    "|" at 40 + 38
                    "=" at center-field(40 + 38, 40 + 42, 1)
                    "|" at 40 + 42
                .
                if available buf_wth-dtl
                then put stream out-stream
                    buf_wth-dtl.doc-sum format "zzz,zzz,zz9.99" at center-field(40 + 42, 40 + 64, 15)
                .
                put stream out-stream
                    "|" at 40 + 64
                .
                if available buf_wth-dtl
                then accumulate
                  buf_wth-dtl.doc-sum (total)
                .
            end.
            put stream out-stream
              skip
                v-single-line format "X(65)" at 40
                "Итого: " at right-field(40 + 42, 7)
                space(5) (accum total buf_wth-dtl.doc-sum)
                              format "z,zzz,zzz,zz9.99"
            .
        end.
    if line-counter( out-stream ) + 8 > page-size( out-stream )
    then page stream out-stream.
    put stream out-stream
        skip(2)
        space (5) "Документ составил:    "
        v-operator format "X(60)"
        "подпись _______________________________"
        skip(2)
        space (5) "ПЕРЕДАЛ          "
        v-deliver format "X(65)"
        "подпись _______________________________"
        skip(1)
        space (5) "ПОЛУЧИЛ          "
        v-receiver format "X(65)"
        "подпись _______________________________"
    .
end.
output stream out-stream close.
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
