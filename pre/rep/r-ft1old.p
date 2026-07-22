block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Invers               as logical          no-undo.
define input parameter p-mode               as character        no-undo.
define input parameter p-round              as character        no-undo.
define input parameter p-from-check         as logical          no-undo.
define input parameter p-reverse            as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ft1old.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ft1old.p $":U .
define variable vss-description as character no-undo init "Печатные формы. Типовая межотраслевая форма № 1-Т для внешнего расхода".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
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
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define variable vss-include-info5 as character format "X(65)" no-undo
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
define new global shared variable g#trdcalib as handle no-undo.
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    def var log-file-name as char no-undo.
    assign
        log-file-name = ''
    .
    if log-file-name <> "":U
    then do:
        if search( '' ) = ?
        then do:
            output to value( '' ).
            output close.
        end.
    end.
    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    if p-file-name <> ""
    then do:
    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED chr(10).
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", 80)
                ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                ELSE fill(" ", p-log-level * 2) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION LastMonthDate RETURNS DATE    ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE t_date AS DATE NO-UNDO.
  RUN get-last-month-date IN THIS-PROCEDURE ( INPUT i-date, OUTPUT t_date ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE t_date ).
END FUNCTION.
PROCEDURE get-last-month-date :
  DEFINE  INPUT PARAMETER p-curr-date AS DATE NO-UNDO.
  DEFINE OUTPUT PARAMETER p-last-date AS DATE NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-last-date = DATE( MONTH( p-curr-date ), 28,  YEAR( p-curr-date ) ).
    ASSIGN p-last-date = p-last-date - DAY( p-last-date + 4 ) + 4.
  END.
END PROCEDURE.
FUNCTION LastMonthDay  RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_day AS INTEGER NO-UNDO.
  RUN get-last-month-day IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_day ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_day ).
END FUNCTION.
PROCEDURE get-last-month-day :
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-day  AS INTEGER NO-UNDO.
  DEFINE VARIABLE t_date AS DATE NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN t_date = DATE( MONTH( p-date ), 28,  YEAR( p-date ) ).
    ASSIGN p-day  = DAY( t_date - DAY( t_date + 4 ) + 4 ).
  END.
END PROCEDURE.
FUNCTION LastDay-MY  RETURNS INTEGER ( INPUT i-month AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE j_day AS INTEGER NO-UNDO.
  RUN get-last-day-MY IN THIS-PROCEDURE ( INPUT i-month, INPUT i-year, OUTPUT j_day ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_day ).
END FUNCTION.
PROCEDURE get-last-day-MY :
  DEFINE  INPUT PARAMETER p-month AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year  AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-day   AS INTEGER NO-UNDO.
  DEFINE VARIABLE t_date AS DATE NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN t_date = DATE( p-month, 28, p-year ).
    ASSIGN p-day  = DAY( t_date - DAY( t_date + 4 ) + 4 ).
  END.
END PROCEDURE.
FUNCTION LastDate-MY RETURNS DATE    ( INPUT i-month AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE t_date AS DATE NO-UNDO.
  RUN get-last-date-MY IN THIS-PROCEDURE ( INPUT i-month, INPUT i-year, OUTPUT t_date ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE t_date ).
END FUNCTION.
PROCEDURE get-last-date-MY :
  DEFINE  INPUT PARAMETER p-month AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year  AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-date  AS DATE    NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-date = DATE( p-month, 28, p-year ).
    ASSIGN p-date = p-date - DAY( p-date + 4 ) + 4.
  END.
END PROCEDURE.
FUNCTION NextMonth RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_month AS INTEGER NO-UNDO.
  RUN get-next-month IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_month ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month ).
END FUNCTION.
PROCEDURE get-next-month :
  DEFINE  INPUT PARAMETER p-date  AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-month AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-month = ( MONTH( p-date ) MODULO 12 ) + 1.
  END.
END PROCEDURE.
FUNCTION NextYear  RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_year AS INTEGER NO-UNDO.
  RUN get-next-year IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_year ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_year ).
END FUNCTION.
PROCEDURE get-next-year :
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-year AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-year = YEAR( p-date ) + ( IF MONTH( p-date ) < 12 THEN 0 ELSE 1 ).
  END.
END PROCEDURE.
FUNCTION PrevMonth RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_month AS INTEGER NO-UNDO.
  RUN get-prev-month IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_month ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month ).
END FUNCTION.
PROCEDURE get-prev-month :
  DEFINE  INPUT PARAMETER p-date  AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-month AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-month = ( ( ( MONTH( p-date ) + 10 ) MODULO 12 ) MODULO 12 ) + 1.
  END.
END PROCEDURE.
FUNCTION PrevYear  RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_year AS INTEGER NO-UNDO.
  RUN get-prev-year IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_year ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_year ).
END FUNCTION.
PROCEDURE get-prev-year :
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-year AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-year = YEAR( p-date ) + ( IF MONTH( p-date ) = 1 THEN -1 ELSE 0 ).
  END.
END PROCEDURE.
FUNCTION NextMonth-MY RETURNS INTEGER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE j_month AS INTEGER NO-UNDO.
  RUN get-next-month-MY IN THIS-PROCEDURE ( INPUT i-month, OUTPUT j_month ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month ).
END FUNCTION.
PROCEDURE get-next-month-MY :
  DEFINE  INPUT PARAMETER p-curr-month AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-next-month AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-next-month = ( p-curr-month MODULO 12 ) + 1.
  END.
END PROCEDURE.
FUNCTION NextYear-MY  RETURNS INTEGER ( INPUT i-month AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE j_year AS INTEGER NO-UNDO.
  RUN get-next-year-MY IN THIS-PROCEDURE ( INPUT i-month, INPUT i-year, OUTPUT j_year ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_year ).
END FUNCTION.
PROCEDURE get-next-year-MY :
  DEFINE  INPUT PARAMETER p-curr-month AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr-year  AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-next-year  AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-next-year = p-curr-year + ( IF p-curr-month < 12 THEN 0 ELSE 1 ).
  END.
END PROCEDURE.
FUNCTION MonthNameRus RETURNS CHARACTER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
  RUN get-month-name-rus IN THIS-PROCEDURE ( INPUT i-month, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION.
PROCEDURE get-month-name-rus :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO INITIAL "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь".
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-name = ( IF p-month >= 1 AND p-month <= 12 THEN ENTRY( p-month, v-list ) ELSE ? ).
  END.
END PROCEDURE.
FUNCTION MonthNameRusGen RETURNS CHARACTER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
  RUN get-month-name-gen IN THIS-PROCEDURE ( INPUT i-month, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION.
PROCEDURE get-month-name-gen :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO INITIAL "Января,Февраля,Марта,Апреля,Мая,Июня,Июля,Августа,Сентября,Октября,Ноября,Декабря".
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-name = ( IF p-month >= 1 AND p-month <= 12 THEN ENTRY( p-month, v-list ) ELSE ? ).
  END.
END PROCEDURE.
FUNCTION CalcMonthes  RETURNS INTEGER ( INPUT i-date-from AS DATE, INPUT i-date-till AS DATE ) :
  DEFINE VARIABLE j_month-num AS INTEGER NO-UNDO.
  RUN get-month-number IN THIS-PROCEDURE ( INPUT i-date-from, INPUT i-date-till, OUTPUT j_month-num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month-num ).
END FUNCTION.
PROCEDURE get-month-number :
  DEFINE  INPUT PARAMETER p-date-from AS DATE    NO-UNDO.
  DEFINE  INPUT PARAMETER p-date-till AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-month-num AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-month-num = ( YEAR(  p-date-till ) - YEAR(  p-date-from ) ) * 12 +
                           MONTH( p-date-till ) - MONTH( p-date-from )   +  1 .
  END.
END PROCEDURE.
FUNCTION CalcMonth-MY RETURNS INTEGER ( INPUT i-year-from  AS INTEGER,
                                        INPUT i-month-from AS INTEGER,
                                        INPUT i-year-till  AS INTEGER,
                                        INPUT i-month-till AS INTEGER  ) :
  DEFINE VARIABLE j_month-num AS INTEGER NO-UNDO.
  RUN get-month-num-MY IN THIS-PROCEDURE (  INPUT i-year-from,
                                            INPUT i-month-from,
                                            INPUT i-year-till,
                                            INPUT i-month-till,
                                           OUTPUT j_month-num   ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month-num ).
END FUNCTION.
PROCEDURE get-month-num-MY :
  DEFINE  INPUT PARAMETER p-year-from  AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-month-from AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year-till  AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-month-till AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-month-num  AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-month-num = ( p-year-till - p-year-from ) * 12 + p-month-till - p-month-from + 1.
  END.
END PROCEDURE.
FUNCTION DateTimeHeader RETURNS CHARACTER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE v-header AS CHARACTER NO-UNDO.
  RUN get-date-time-header IN THIS-PROCEDURE ( INPUT i-date, OUTPUT v-header ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-header ).
END FUNCTION.
PROCEDURE get-date-time-header :
  DEFINE  INPUT PARAMETER p-date AS DATE      NO-UNDO.
  DEFINE OUTPUT PARAMETER p-head AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END.
    ASSIGN p-head = "Дата печати: " + STRING( p-date, "99.99.9999":U ) + ", ":U + STRING( TIME, "HH:MM":U ).
  END.
END PROCEDURE.
FUNCTION Leap-Year RETURNS LOGICAL ( INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE bissextile AS LOGICAL NO-UNDO.
  RUN get-leap-year-sign IN THIS-PROCEDURE ( INPUT i-year, OUTPUT bissextile ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE bissextile ).
END FUNCTION.
PROCEDURE get-leap-year-sign :
  DEFINE  INPUT PARAMETER p-year AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-sign AS LOGICAL NO-UNDO.
  DEFINE VARIABLE t_date AS DATE NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-year = ? OR p-year = 0 THEN DO:
      ASSIGN t_date = TODAY.
      IF t_date <> TODAY THEN DO: ASSIGN t_date = TODAY. END.
      ASSIGN p-year = YEAR( t_date ).
    END.
    ASSIGN p-sign = ( INTEGER( TRUNCATE( p-year * 0.25, 0 ) ) * 4 = p-year ).
  END.
END PROCEDURE.
FUNCTION Leap-Year-d RETURNS LOGICAL ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE bissextile AS LOGICAL NO-UNDO.
  RUN get-leap-year-sign-d IN THIS-PROCEDURE ( INPUT i-date, OUTPUT bissextile ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE bissextile ).
END FUNCTION.
PROCEDURE get-leap-year-sign-d :
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-sign AS LOGICAL NO-UNDO.
  DEFINE VARIABLE j-year AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO:
      ASSIGN p-date = TODAY.
      IF p-date <> TODAY THEN DO: ASSIGN p-date = TODAY. END.
    END.
    ASSIGN j-year = YEAR( p-date ).
    ASSIGN p-sign = ( INTEGER( TRUNCATE( j-year * 0.25, 0 ) ) * 4 = j-year ).
  END.
END PROCEDURE.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id   as integer
    field ID           as integer
    field Name         as character
    field art          as character
    field EI           as character
    field pack         as character
    field PlaceAmount  as character
    field Mass         as character
    field qnty         as character
    field price        as character
    field sum          as character
    index pi is primary unique xl-line-id
.
define variable v-r-f_t1xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-r-f_t1xl-sheet2-cur-data-row  as integer      no-undo.
define variable v-r-f_t1xl-cell-file-name       as character    no-undo.
define variable v-r-f_t1xl-data-file-name       as character    no-undo.
procedure r-f_t1xl-init :
do
on error undo, return error
:
    assign
        v-r-f_t1xl-sheet1-cur-data-row = 0
        v-r-f_t1xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-r-f_t1xl-data-file-name
    ).
    output stream excel-line to value( v-r-f_t1xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-r-f_t1xl-cell-file-name
    ).
    output stream excel-cell to value( v-r-f_t1xl-cell-file-name ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "T_1,Оборот.сторона":U
    ).
    if printrubl
    then do:
        run r-f_t1xl-write-cell-data in this-procedure (
              input "T_1_valutCode":U
            , input "0":U
        ).
        run r-f_t1xl-write-cell-data in this-procedure (
              input "Оборот.сторона_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run r-f_t1xl-write-cell-data in this-procedure (
              input "T_1_valutCode":U
            , input "1":U
        ).
        run r-f_t1xl-write-cell-data in this-procedure (
              input "Оборот.сторона_valutCode":U
            , input "1":U
        ).
    end.
    run r-f_t1xl-write-cell-data in this-procedure (
          input "T_1_columnList":U
        , input "ID,Name,art,EI,pack,PlaceAmount,Mass,qnty,price,sum":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "T_1_columnType":U
        , input "I,S,S,S,S,D,D,D,C,C":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "Оборот.сторона_columnList":U
        , input "":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "Оборот.сторона_columnType":U
        , input "":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "Оборот.сторона_subtotalList":U
        , input "":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "Оборот.сторона_subtotalType":U
        , input "":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "T_1_subtotalList":U
        , input "":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "T_1_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure r-f_t1xl-sheet1-write-line-data :
define input parameter p-ID             as integer          no-undo.
define input parameter p-Name           as character        no-undo.
define input parameter p-art            as character        no-undo.
define input parameter p-EI             as character        no-undo.
define input parameter p-pack           as character        no-undo.
define input parameter p-PlaceAmount    as character        no-undo.
define input parameter p-Mass           as character        no-undo.
define input parameter p-qnty           as character        no-undo.
define input parameter p-price          as character        no-undo.
define input parameter p-sum            as character        no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    :
        delete buf_temp_sheet1_line-data.
    end.
    create buf_temp_sheet1_line-data.
    assign
        v-r-f_t1xl-sheet1-cur-data-row         = v-r-f_t1xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = "T_1":U
        buf_temp_sheet1_line-data.xl-line-id    = v-r-f_t1xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.id           = p-id
        buf_temp_sheet1_line-data.Name         = p-Name
        buf_temp_sheet1_line-data.art          = p-art
        buf_temp_sheet1_line-data.EI           = p-EI
        buf_temp_sheet1_line-data.pack         = p-pack
        buf_temp_sheet1_line-data.PlaceAmount  = p-PlaceAmount
        buf_temp_sheet1_line-data.Mass         = p-Mass
        buf_temp_sheet1_line-data.qnty         = p-qnty
        buf_temp_sheet1_line-data.price        = p-price
        buf_temp_sheet1_line-data.sum          = p-sum
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        chr(9)   "DTA":U
        chr(9)   ( if buf_temp_sheet1_line-data.id = 0 then "":U else string( buf_temp_sheet1_line-data.id ) )
        chr(9)   buf_temp_sheet1_line-data.Name
        chr(9)   buf_temp_sheet1_line-data.art
        chr(9)   buf_temp_sheet1_line-data.EI
        chr(9)   buf_temp_sheet1_line-data.pack
        chr(9)   buf_temp_sheet1_line-data.PlaceAmount
        chr(9)   buf_temp_sheet1_line-data.Mass
        chr(9)   buf_temp_sheet1_line-data.qnty
        chr(9)   buf_temp_sheet1_line-data.price
        chr(9)   buf_temp_sheet1_line-data.sum
        chr(10)
    .
end.
end procedure.
procedure r-f_t1xl-write-cell-data :
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
procedure r-f_t1xl-run-excel :
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
        v-template-file-name    = search( "exe/T_1.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
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
procedure r-f_t1xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/T_1.xlt":U.
        export "exe/t_form.bas":U.
        export v-r-f_t1xl-cell-file-name.
        export v-r-f_t1xl-data-file-name.
    output close.
end.
end procedure.
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table sj-t12 no-undo
field b-code                          like ub.bar-code.b-code
field gds-code                        like ub.goods.gds-code
field prt-code                        like ub.gds-dtl.prt-code
field artic                           like ub.goods.artic
field prod-type                       like ub.goods.prod-type
field prod-code                       like ub.goods.prod-code
field doc-qnty                        like ub.gds-dtl.doc-qnty
field fact-qnty                       like ub.gds-dtl.fact-qnty
field gds-dtl-qnty                    like ub.gds-dtl.doc-qnty
field cur-base                        like ub.gds-dtl.cur-base
field discnt-base                     like ub.gds-dtl.discnt-base
field discnt-pc                       like ub.gds-dtl.discnt-pc
field discnt-rubl                     like ub.gds-dtl.discnt-rubl
field discnt-type                     like ub.gds-dtl.discnt-type
field doc-code                        like ub.gds-dtl.doc-code
field obj-code                        like ub.gds-dtl.obj-code
field obj-type                        like ub.gds-dtl.obj-type
field ov                              like ub.gds-dtl.ov
field price-base                      like ub.gds-dtl.price-base
field price-rubl                      like ub.gds-dtl.price-rubl
field vat-pc                           like ub.doc-line.vat-pc
field slt-pc                           like ub.doc-line.slt-pc
field price-rubl-with-tax-sale         like ub.gds-dtl.price-rubl
field price-base-with-tax-sale         like ub.gds-dtl.price-base
field price-rubl-without-tax-sale      like ub.gds-dtl.price-rubl
field price-base-without-tax-sale      like ub.gds-dtl.price-base
field vat-base-sale                    like ub.gds-dtl.price-base
field vat-rubl-sale                    like ub.gds-dtl.price-rubl
field vat-base-buyer                   like ub.gds-dtl.price-base
field vat-rubl-buyer                   like ub.gds-dtl.price-rubl
field slt-base-sale                    like ub.gds-dtl.price-base
field slt-rubl-sale                    like ub.gds-dtl.price-rubl
field road-tax-base-sale               like ub.gds-dtl.price-base
field road-tax-rubl-sale               like ub.gds-dtl.price-rubl
field excise-base-sale                 like ub.gds-dtl.price-base
field excise-rubl-sale                 like ub.gds-dtl.price-rubl
field discnt-base-sale                 like ub.gds-dtl.price-base
field discnt-rubl-sale                 like ub.gds-dtl.price-rubl
field is-ok                            as logical
field calced                           as logical
index pi is unique primary
b-code
index iok
is-ok
.
procedure fill-sjt12 :
  _main:
  do
  on error undo, return error
  :
    define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .
    define variable v-inkas-code like ub.inkas.inkas-code no-undo .
    define variable v-trn-doc-code like ub.trn-doc.doc-code no-undo .
    define variable v-ret-doc-code like ub.trn-doc.out-code no-undo .
    define variable v-doc-code     like ub.trn-doc.doc-code no-undo .
    define variable check-v-doc-code     like ub.trn-doc.doc-code no-undo .
    define buffer buf_trn-doc for ub.trn-doc.
    define buffer buf_ret-doc for ub.trn-doc.
    define buffer buf_inkas for ub.inkas.
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_goods for ub.goods.
    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_sj-t12 for sj-t12.
    define buffer buf_gds-dtl for ub.gds-dtl.
    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_sale-doc for ub.sale-doc.
      FOR EACH sj-t12 :
        delete sj-t12 .
      END .
      find first buf_trn-doc no-lock where
                buf_trn-doc.doc-code = p-doc-code no-error .
      if not available buf_trn-doc then do:
        undo _main, return error substitute("Не найден документ с номером &1", p-doc-code).
      end.
      if NOT (buf_trn-doc.ext-doc-type = 'es':U
              or
              buf_trn-doc.ext-doc-type = 'rs':U
              ) then do:
        undo _main, return error substitute("Неверный тип документа &1: &2", p-doc-code, buf_trn-doc.ext-doc-type).
      end.
      if buf_trn-doc.ext-doc-type = 'es':U then do:
        assign
        v-inkas-code = buf_trn-doc.doc-code
        v-trn-doc-code = buf_trn-doc.doc-code
        v-ret-doc-code = buf_trn-doc.out-code
        v-doc-code     = v-trn-doc-code
        .
      end.
      else do:
        assign
        v-inkas-code = buf_trn-doc.out-code
        v-trn-doc-code = buf_trn-doc.out-code
        v-ret-doc-code = buf_trn-doc.doc-code
        v-doc-code     = v-ret-doc-code
        .
      end.
      _chk-doc:
      FOR EACH buf_chk-doc No-LOCK WHERE
                buf_chk-doc.obj-type = buf_trn-doc.obj-type AND
                buf_chk-doc.obj-code = buf_trn-doc.obj-code AND
                buf_chk-doc.out-code = v-inkas-code,
          EACH buf_chk-gds WHERE
                buf_chk-gds.doc-code = buf_chk-doc.doc-code NO-LOCK,
          FIRST buf_bar-code WHERE
                buf_bar-code.b-code = buf_chk-gds.b-code NO-LOCK,
          FIRST buf_goods WHERE
                buf_goods.gds-code = buf_bar-code.gds-code
                :
        if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
        if num-entries(buf_chk-gds.line-type, chr(4)) > 1 then do:
          find first buf_sale-doc no-lock where
                    buf_sale-doc.inkas-code = v-inkas-code
                and buf_sale-doc.doc-kind = entry(1, entry(2, buf_chk-gds.line-type, chr(4))) no-error .
          if available buf_sale-doc then do:
            assign
            check-v-doc-code = buf_sale-doc.doc-code.
          end.
        end.
        if v-doc-code = '':U then do:
          if buf_chk-doc.netto >= 0 then
          check-v-doc-code = v-trn-doc-code.
          else
          check-v-doc-code = v-ret-doc-code.
        end.
        if check-v-doc-code <> v-doc-code then do:
         next _chk-doc.
       end.
        FIND FIRST buf_gds-dtl WHERE
                  buf_gds-dtl.doc-code  = v-doc-code AND
                  buf_gds-dtl.artic     = buf_goods.artic AND
                  buf_gds-dtl.prod-type = buf_goods.prod-type AND
                  buf_gds-dtl.prod-code = buf_goods.prod-code AND
                  buf_gds-dtl.prt-code  = buf_bar-code.node-code NO-LOCK NO-ERROR .
        if available buf_gds-dtl then do:
          FIND FIRST buf_doc-line WHERE
                    buf_doc-line.doc-code  = buf_gds-dtl.doc-code AND
                    buf_doc-line.prod-type = buf_gds-dtl.prod-type AND
                    buf_doc-line.prod-code = buf_gds-dtl.prod-code  AND
                    buf_doc-line.artic     = buf_gds-dtl.artic NO-LOCK NO-ERROR.
        end.
        find first buf_sj-t12 where
                  buf_sj-t12.b-code   = buf_chk-gds.b-code
              AND buf_sj-t12.gds-code = buf_goods.gds-code no-error .
        if not available buf_sj-t12
        and available buf_gds-dtl
        then do:
          create buf_sj-t12.
          buffer-copy buf_gds-dtl
          using
          artic
          prod-type
          prod-code
          cur-base
          discnt-base
          discnt-pc
          discnt-rubl
          discnt-type
          doc-code
          obj-code
          obj-type
          ov
          price-base
          price-rubl
          to  buf_sj-t12
          assign
          buf_sj-t12.b-code    = buf_Chk-gds.b-code
          buf_sj-t12.gds-code  = buf_goods.gds-code
          buf_sj-t12.prt-code  = buf_bar-code.node-code
          buf_sj-t12.gds-dtl-qnty = buf_gds-dtl.doc-qnty
          .
        end.
        if available buf_sj-t12 then do:
          assign
          buf_sj-t12.doc-qnty    = buf_sj-t12.doc-qnty + (if buf_chk-doc.netto >= 0 then 1 else - 1) * buf_chk-gds.doc-qnty
          buf_sj-t12.fact-qnty    = buf_sj-t12.fact-qnty + (if buf_chk-doc.netto >= 0 then 1 else - 1) * buf_chk-gds.doc-qnty
          buf_sj-t12.gds-dtl-qnty = buf_gds-dtl.doc-qnty
          buf_sj-t12.IS-OK        = (buf_sj-t12.gds-dtl-qnty = buf_sj-t12.fact-qnty)
          .
        end.
        if available buf_gds-dtl
        and available buf_doc-line
        and buf_doc-line.doc-qnty <> 0
        and available buf_sj-t12
        and not buf_sj-t12.calced
        then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
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
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
          assign
          buf_sj-t12.price-rubl-with-tax-sale     = price-rubl-with-tax-sale
          buf_sj-t12.price-base-with-tax-sale     = price-base-with-tax-sale
          buf_sj-t12.price-rubl-without-tax-sale  = price-rubl-without-tax-sale
          buf_sj-t12.price-base-without-tax-sale  = price-base-without-tax-sale
          buf_sj-t12.vat-base-sale                = vat-base-sale
          buf_sj-t12.vat-rubl-sale                = vat-rubl-sale
          buf_sj-t12.vat-base-buyer               = vat-base-buyer
          buf_sj-t12.vat-rubl-buyer               = vat-rubl-buyer
          buf_sj-t12.slt-base-sale                = slt-base-sale
          buf_sj-t12.slt-rubl-sale                = slt-rubl-sale
          buf_sj-t12.road-tax-base-sale           = road-tax-base-sale
          buf_sj-t12.road-tax-rubl-sale           = road-tax-rubl-sale
          buf_sj-t12.excise-base-sale             = excise-base-sale
          buf_sj-t12.excise-rubl-sale             = excise-rubl-sale
          buf_sj-t12.discnt-base-sale             = discnt-base-sale
          buf_sj-t12.discnt-rubl-sale             = discnt-rubl-sale
          buf_sj-t12.vat-pc                       = buf_doc-line.vat-pc
          buf_sj-t12.slt-pc                       = buf_doc-line.slt-pc
          buf_sj-t12.calced                       = yes
          .
        end.
        else do:
        end.
      end.
      for each buf_sj-t12 where
              buf_sj-t12.is-ok = no:
        if buf_sj-t12.gds-dtl-qnty > 0 then do:
        end.
        else do:
          find first buf_doc-line no-lock where
                    buf_doc-line.doc-code  = buf_sj-t12.doc-code
              AND  buf_doc-line.artic     = buf_sj-t12.artic
              AND  buf_doc-line.prod-type = buf_sj-t12.prod-type
              AND  buf_doc-line.prod-code = buf_sj-t12.prod-code .
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
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
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-base - buf_sj-t12.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-base - buf_sj-t12.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-base - buf_sj-t12.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_sj-t12.discnt-base
  price-base-with-tax-sale    = (buf_sj-t12.price-base - buf_sj-t12.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_sj-t12.discnt-rubl
  price-rubl-with-tax-sale    = (buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_sj-t12.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_sj-t12.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-base - buf_sj-t12.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-base - buf_sj-t12.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_sj-t12.price-base - buf_sj-t12.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-base - buf_sj-t12.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_sj-t12.doc-qnty * varcons-qnty / varfact-qnty + ((buf_sj-t12.price-base - buf_sj-t12.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-base - buf_sj-t12.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_sj-t12.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_sj-t12.doc-qnty * varcons-qnty / varfact-qnty + ((buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_sj-t12.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_sj-t12.price-base - buf_sj-t12.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-base - buf_sj-t12.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_sj-t12.fact-qnty * varcons-qnty / varfact-qnty + ((buf_sj-t12.price-base - buf_sj-t12.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-base - buf_sj-t12.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_sj-t12.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_sj-t12.fact-qnty * varcons-qnty / varfact-qnty + ((buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_sj-t12.price-rubl - buf_sj-t12.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_sj-t12.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
          assign
          buf_sj-t12.price-rubl-with-tax-sale     = price-rubl-with-tax-sale
          buf_sj-t12.price-base-with-tax-sale     = price-base-with-tax-sale
          buf_sj-t12.price-rubl-without-tax-sale  = price-rubl-without-tax-sale
          buf_sj-t12.price-base-without-tax-sale  = price-base-without-tax-sale
          buf_sj-t12.vat-base-sale                = vat-base-sale
          buf_sj-t12.vat-rubl-sale                = vat-rubl-sale
          buf_sj-t12.vat-base-buyer               = vat-base-buyer
          buf_sj-t12.vat-rubl-buyer               = vat-rubl-buyer
          buf_sj-t12.slt-base-sale                = slt-base-sale
          buf_sj-t12.slt-rubl-sale                = slt-rubl-sale
          buf_sj-t12.road-tax-base-sale           = road-tax-base-sale
          buf_sj-t12.road-tax-rubl-sale           = road-tax-rubl-sale
          buf_sj-t12.excise-base-sale             = excise-base-sale
          buf_sj-t12.excise-rubl-sale             = excise-rubl-sale
          buf_sj-t12.discnt-base-sale             = discnt-base-sale
          buf_sj-t12.discnt-rubl-sale             = discnt-rubl-sale
          buf_sj-t12.vat-pc                       = buf_doc-line.vat-pc
          buf_sj-t12.slt-pc                       = buf_doc-line.slt-pc
          buf_sj-t12.calced                       = yes
          .
        end.
      END.
  end.
end procedure.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character
    index pi is primary unique
        str-key
.
define variable v-p-fmt-27-str-key    as integer      no-undo.
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
        v-p-fmt-27-str-key   = 0
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
            v-p-fmt-27-str-key = v-p-fmt-27-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-27-str-key
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
procedure fact-order-mpl :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-date as date     no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-fact-order as decimal   no-undo .
define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable shift-date as date      no-undo .
define variable shift-num  as integer   no-undo .
define variable shift-name as character no-undo .
define variable max-fact-order as decimal   no-undo .
define buffer buf_global-state for ub.global-state  .
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
  run cur-time in this-procedure
  ( output v-fact-date ,
    output v-fact-time  ).
if p-doc-date = ? then do:
if buf_global-state.pl-use-sys-date-time  = true then do:
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  ?
        ,input  ?
        ,input  false
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
else do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      if p-doc-date <> ? then do:
      end.
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error substitute(" Ошибка из factdate.p: &1 &2"  , return-value , error-status :get-message(1)   ) .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
end.
else do:
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error "Ошибка factdate.p " + return-value .
      v-fact-date = p-doc-date .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
  end.
end procedure.
DEFINE TEMP-TABLE tt_price-all NO-UNDO LIKE ub.price-all
field sale-qnty as decimal
field sale-sum  as decimal
field sale-tnv  as decimal
field price-sale-base as decimal
field price-sale-rubl as decimal
field road-tax-base   as decimal
field road-tax-rubl   as decimal
field excise-base as decimal
field excise-rubl as decimal
field date-1 as date
field date-2 as date
field shift-1 as int
field shift-2 as int
field time-1 as int
field time-2 as int
field grp-name as char
field interv-name as char
field pay-name as char
field unit-cli as char
index pi
plt-priority DESCENDING
fact-order DESCENDING
qnty-from asc
sum-from asc
turnover-from asc
date-1 DESCENDING
time-1 DESCENDING
date-2 DESCENDING
time-2 DESCENDING
type-price DESCENDING
.
procedure mpl-autoprice :
define input  parameter p-only-b-code as logical   no-undo .
define input  parameter p-cli-type    as character no-undo .
define input  parameter p-cli-code    as integer   no-undo .
define input  parameter p-main-b-code as integer   no-undo .
define input  parameter p-b-code      as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-qnty-doc    as decimal   no-undo .
define input  parameter p-sum-doc     as decimal   no-undo .
define input  parameter p-vid-pay        as character no-undo .
define input  parameter p-cash-pay-type  as character no-undo .
define input  parameter p-fact-order  as decimal   no-undo .
define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .
define output parameter p-road-tax-base as decimal   no-undo .
define output parameter p-road-tax-rubl as decimal   no-undo .
define output parameter p-excise-base   as decimal   no-undo .
define output parameter p-excise-rubl   as decimal   no-undo .
define variable v-cli-oborot-ALL as decimal   no-undo .
define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group  .
define buffer buf_turnover-buyer-main    for ub.turnover-buyer-main  .
define buffer buf1_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf2_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf_price-all              for ub.price-all  .
define buffer buf_goods                  for ub.goods      .
define buffer buf_global-state           for ub.global-state  .
define buffer buf_buyer-group            for ub.buyer-group  .
define buffer buf_turnover-group         for ub.turnover-group  .
define buffer buf_main-code              for ub.bar-code  .
define buffer buf_bar-code               for ub.bar-code  .
define buffer buf_pay-type               for ub.pay-type  .
define buffer buf_cash-pay               for ub.cash-pay  .
define variable to-day          as date      no-undo .
define variable v-base-rate0    as decimal   no-undo .
define variable v-base-scale0   as decimal   no-undo .
define variable v-exch-rate0    as decimal   no-undo .
define variable v-exch-scale0   as decimal   no-undo .
define variable v-base-rate     as decimal   no-undo .
define variable v-base-scale    as decimal   no-undo .
define variable v-exch-rate     as decimal   no-undo .
define variable v-exch-scale    as decimal   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-curr-abbr     as character no-undo .
define variable v-grp-name      as character no-undo .
define variable v-date-1        as date      no-undo .
define variable v-date-2        as date      no-undo .
define variable v-interv        as character no-undo .
define variable v-pay-name      as character no-undo .
define variable v-cli-oborot    as decimal   no-undo .
define variable v-trn-pay-code  as integer   no-undo .
define variable v-cash-pay-curr as integer   no-undo .
define variable v-cash-pay-code as integer   no-undo .
do
on error undo, return error return-value
:
find first buf_main-code no-lock where buf_main-code.b-code = p-main-b-code .
find first buf_goods no-lock where buf_goods.gds-code = buf_main-code.gds-code.
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ).
end.
if p-vid-pay <> "" then do:
   find first buf_pay-type no-lock where  buf_pay-type.obj-code = integer(p-vid-pay) no-error .
   if available buf_pay-type
      then v-trn-pay-code = buf_pay-type.obj-code.
      else v-trn-pay-code =  0.
end.
else v-trn-pay-code = 0 .
if p-cash-pay-type <> "" then do:
   find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer(p-cash-pay-type) no-error .
   if available buf_pay-type
      then
        assign
          v-cash-pay-curr = buf_cash-pay.curr-code
          v-cash-pay-code = buf_cash-pay.cdpay-code
        .
      else
        assign
          v-cash-pay-curr = 0
          v-cash-pay-code = 0
          .
end.
else
  assign
    v-cash-pay-curr = 0
    v-cash-pay-code = 0
    .
for each tt_price-all  : delete tt_price-all . end.
assign
  p-plt-id             = ?
  p-plt-db-num         = ?
  p-pdf-id             = ?
  p-pdf-db-num         = ?
  p-sale-price-base    = ?
  p-sale-price-rubl    = ?
  v-cli-oborot         = 0
.
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  to-day
  ,output v-base-rate0
  ,output v-base-scale0
  )  .
  v-cli-oborot-ALL  = 0 .
  for each buf_turnover-buyer-main no-lock  where
           buf_turnover-buyer-main.cli-type = p-cli-type  and
           buf_turnover-buyer-main.cli-code = p-cli-code
           :
           v-cli-oborot-ALL = v-cli-oborot-ALL + buf_turnover-buyer-main.sum-doc-rubl-itog .
  end.
for each buf_price-all no-lock where
         buf_price-all.obj-type = p-obj-type and
         buf_price-all.obj-code = p-obj-code and
         buf_price-all.gds-code = buf_goods.gds-code and
         buf_price-all.status_  = 'акт':U  and
       ( p-only-b-code = false   or
       ( buf_price-all.b-code = p-main-b-code or
         buf_price-all.b-code = p-b-code))    and
        ( p-only-b-code = true  or
          buf_price-all.b-code = p-b-code)
          and
          buf_price-all.fact-order-sys-from  <= p-fact-order  and
        ( buf_price-all.fact-order-sys-to = ? or
          buf_price-all.fact-order-sys-to    >= p-fact-order)
        :
         v-interv   = "" .
         v-grp-name = "" .
         v-pay-name = "" .
         if buf_price-all.fact-order = 0  and buf_price-all.plt-priority = 0  then next.
         if buf_price-all.bgr-id > 0 then do:
            find first buf_buyer-group no-lock where
                       buf_buyer-group.bgr-id     = buf_price-all.bgr-id  and
                       buf_buyer-group.bgr-db-num = buf_price-all.bgr-db-num  no-error .
            if available buf_buyer-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
               find first buf_buyer-in-buyer-group no-lock where
                          buf_buyer-in-buyer-group.stts         = 0 and
                          buf_buyer-in-buyer-group.bgr-id       = buf_buyer-group.bgr-id     and
                          buf_buyer-in-buyer-group.bgr-db-num   = buf_buyer-group.bgr-db-num  and
                          buf_buyer-in-buyer-group.bbg-obj-type = p-cli-type and
                          buf_buyer-in-buyer-group.bbg-obj-code = p-cli-code
                          no-error .
                          if not available buf_buyer-in-buyer-group then do:
                             v-grp-name = "".
                             next.
                          end.
                          v-grp-name = buf_buyer-group.name .
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.tog-id > 0 then do:
            find first buf_turnover-group no-lock where
                       buf_turnover-group.tog-id     = buf_price-all.tog-id      and
                       buf_turnover-group.tog-db-num = buf_price-all.tog-db-num  no-error .
            if available buf_turnover-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
                  v-cli-oborot = v-cli-oborot-all  .
                  find first buf1_tnv-in-turnover-group no-lock where
                             buf1_tnv-in-turnover-group.stts       =  0     and
                             buf1_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf1_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf1_tnv-in-turnover-group.ttg-summa  <=  v-cli-oborot no-error .
                  find first buf2_tnv-in-turnover-group no-lock where
                             buf2_tnv-in-turnover-group.stts       =  0     and
                             buf2_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf2_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf2_tnv-in-turnover-group.ttg-summa  >=  v-cli-oborot no-error .
                  if not (available buf1_tnv-in-turnover-group and
                          available buf2_tnv-in-turnover-group ) then do:
                          v-grp-name = "".
                          next .
                  end.
                  v-grp-name = buf_turnover-group.name.
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.plt-fix-cource-crc-base = true then
            assign
              v-base-rate  = buf_price-all.pdf-base-rate
              v-base-scale = buf_price-all.pdf-base-scale
            .
            else
            assign
              v-base-rate  = v-base-rate0
              v-base-scale = v-base-scale0
            .
         if buf_price-all.plt-fix-cource-crc-doc = true then
            assign
              v-exch-rate  = buf_price-all.pdf-exch-rate
              v-exch-scale = buf_price-all.pdf-exch-scale
            .
            else do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_price-all.curr-code
  ,input  to-day
  ,output v-exch-rate0
  ,output v-exch-scale0
  ,output v-curr-abbr
  )  .
            assign
              v-exch-rate  = v-exch-rate0
              v-exch-scale = v-exch-scale0
              .
           end.
           v-date-1 = date ( "" )  .
           if buf_price-all.fact-order-sys-from > 0 then do:
              if buf_price-all.start-sys-date <> ?   then  v-date-1 = buf_price-all.start-sys-date.
              if buf_price-all.start-shift-date <> ? then  v-date-1 = buf_price-all.start-shift-date.
              if buf_price-all.start-date <> ?       then  v-date-1 = buf_price-all.start-date.
           end.
           v-date-2 =  date ( "" )  .
           if buf_price-all.fact-order-sys-to > 0 then do:
              if buf_price-all.end-sys-date <> ?     then  v-date-2 = buf_price-all.end-sys-date.
              if buf_price-all.end-shift-date <> ?   then  v-date-2 = buf_price-all.end-shift-date.
              if buf_price-all.end-date <> ?         then  v-date-2 = buf_price-all.end-date.
           end.
           if buf_price-all.qnty-from <> ? then do :
              if not (
              ( p-qnty-doc  >= buf_price-all.qnty-from and buf_price-all.qnty-to = ? ) or
              ( p-qnty-doc  >= buf_price-all.qnty-from and p-qnty-doc <= buf_price-all.qnty-to and buf_price-all.qnty-to <> ?)
              ) then do:
                     v-interv = "".
                     next.
              end.
              v-interv = "К: " + string(buf_price-all.qnty-from) + " - " + ( if buf_price-all.qnty-to = ? then "и более" else string(buf_price-all.qnty-to)) .
           end.
           if buf_price-all.sum-from <> ? then do :
              if not (
              ( p-sum-doc  >= buf_price-all.sum-from and buf_price-all.sum-to = ? ) or
              ( p-sum-doc  >= buf_price-all.sum-from and p-sum-doc <= buf_price-all.sum-to and buf_price-all.sum-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "C: " +  string(buf_price-all.sum-from) + " - " + ( if buf_price-all.sum-to = ? then "и более" else string(buf_price-all.sum-to)) .
           end.
           if buf_price-all.turnover-from <> ? then do :
              if not (
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and buf_price-all.turnover-to = ? ) or
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and v-cli-oborot-ALL <= buf_price-all.turnover-to and buf_price-all.turnover-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "O: " +  string(buf_price-all.turnover-from) + " - " + ( if buf_price-all.turnover-to = ? then "и более" else string(buf_price-all.turnover-to)) .
           end.
           if buf_price-all.use-pay-type = 1 then do :
              if buf_price-all.pay-code <> v-trn-pay-code then do:
                 v-pay-name = "" .
                 next.
               end.
               v-pay-name = 'Оплата':U +  ":" + string(buf_price-all.pay-code) .
           end.
           if buf_price-all.use-cash-pay = 1 then do :
              if v-cash-pay-code <> 0 and  not ( buf_price-all.curr-pay-code = v-cash-pay-curr and
                                                 buf_price-all.cdpay-code    = v-cash-pay-code ) then do:
                v-pay-name = "" .
                next.
              end.
              v-pay-name = 'Касс.платеж':U + ":" + string(buf_price-all.cdpay-code) + "_" + string(buf_price-all.curr-pay-code).
           end.
          find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
          create tt_price-all .
          buffer-copy buf_price-all to tt_price-all
          assign
            tt_price-all.price-sale-rubl = buf_price-all.price-sale  * v-exch-rate / v-exch-scale
            tt_price-all.road-tax-rubl   = buf_price-all.road-tax    * v-exch-rate / v-exch-scale
            tt_price-all.excise-rubl     = buf_price-all.excise      * v-exch-rate / v-exch-scale
            tt_price-all.price-sale-base = tt_price-all.price-sale-rubl  / v-base-rate * v-base-scale
            tt_price-all.road-tax-base   = tt_price-all.road-tax-rubl    / v-base-rate * v-base-scale
            tt_price-all.excise-base     = tt_price-all.excise-rubl      / v-base-rate * v-base-scale
            tt_price-all.price-sale     = buf_price-all.price-sale
            tt_price-all.road-tax       = buf_price-all.road-tax
            tt_price-all.excise         = buf_price-all.excise
            tt_price-all.pdf-exch-rate   = v-exch-rate
            tt_price-all.pdf-exch-scale  = v-exch-scale
            tt_price-all.pdf-base-rate   = v-base-rate
            tt_price-all.pdf-base-scale  = v-base-scale
            tt_price-all.grp-name        = v-grp-name
            tt_price-all.date-1          = v-date-1
            tt_price-all.shift-1         = buf_price-all.start-shift-num
            tt_price-all.time-1          = buf_price-all.start-sys-time
            tt_price-all.date-2          = v-date-2
            tt_price-all.shift-2         = buf_price-all.end-shift-num
            tt_price-all.time-2          = buf_price-all.end-sys-time
            tt_price-all.interv-name     = v-interv
            tt_price-all.pay-name        = v-pay-name
            tt_price-all.unit-cli        = buf_bar-code.unit-cli
          .
end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = p-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = neos_price-all.price-sale-base
            p-sale-price-rubl  = neos_price-all.price-sale-rubl
            p-road-tax-base    = neos_price-all.road-tax-base
            p-road-tax-rubl    = neos_price-all.road-tax-rubl
            p-excise-base      = neos_price-all.excise-base
            p-excise-rubl      = neos_price-all.excise-rubl
            .
         end.
         else do:
              find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
              if error-status :error    then do:
                message "Не найден бар-код" p-b-code view-as alert-box error .
                return error return-value .
              end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
end.
end procedure.
procedure mpl-tpl-auto :
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-sale-price as decimal   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ) .
end.
assign
  p-pdf-id      = ?
  p-pdf-db-num  = ?
  p-sale-price  = ?
.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
if error-status :error then return error return-value .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
if error-status :error then return error return-value .
define variable v-main-b-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
define buffer buf_price-all for ub.price-all  .
for each tt_price-all : delete tt_price-all. end.
    for each buf_price-all no-lock where
            buf_price-all.plt-id     = p-plt-id                 and
            buf_price-all.plt-db-num = p-plt-db-num             and
            buf_price-all.obj-type   = p-obj-type               and
            buf_price-all.obj-code   = p-obj-code               and
            buf_price-all.gds-code   = buf_goods.gds-code       and
          ( buf_price-all.b-code = v-main-b-code or
            buf_price-all.b-code = p-b-code)    and
            buf_price-all.status_    = 'акт':U         and
            buf_price-all.fact-order-sys-from  <= p-fact-order  and
          ( buf_price-all.fact-order-sys-to = ? or
            buf_price-all.fact-order-sys-to >=  p-fact-order)
            :
              create tt_price-all .
              buffer-copy buf_price-all to tt_price-all
              assign
                tt_price-all.price-sale  = buf_price-all.price-sale
              .
    end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = v-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = neos_price-all.price-sale
            .
         end.
         else do:
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        if error-status :error    then do:
           message "Не найден бар-код" p-b-code view-as alert-box error .
           return error return-value .
        end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
  end.
end procedure.
define temp-table temp_gds-name no-undo
    field gdn-key   as integer
    field gdnString as character
    index pi is primary unique
        gdn-key
.
define stream out-stream .
define shared variable PrintScale   as logical                          no-undo.
define shared variable CostPrice    as logical                          no-undo.
define shared variable sort-name    as logical                          no-undo.
define shared variable sort-gr      as logical                          no-undo.
define shared variable print-graft  as logical                          no-undo.
    define variable v-torg-12-gds-name-key    as integer      no-undo.
    define variable v-torg-12-gds-name-length as integer      no-undo.
define variable tdoc-prt            as logical                          no-undo.
define variable v-rootnode-code     as integer                          no-undo.
define variable v-line-counter      as integer                          no-undo.
define variable v-doc-line-counter  as integer                          no-undo.
define variable txt-LC              as char                             no-undo.
define variable s1                  as char                             no-undo.
define variable s2                  as char                             no-undo.
define variable v-node-code         like    gds-prt.upper-code          no-undo.
define variable price-noNDS         like doc-line.price-base            no-undo.
define variable price-withNDS       like doc-line.price-base            no-undo.
define variable tqnty               like doc-line.doc-qnty              no-undo.
define variable stoim-noNDS         like doc-line.price-base            no-undo.
define variable stoim               like doc-line.price-base            no-undo.
define variable prt-tqnty           like doc-line.doc-qnty              no-undo.
define variable prt-VAT-gds         like ot-line.VAT-base               no-undo.
define variable prt-SLT-gds         like ot-line.SLT-base               no-undo.
define variable prt-stoim-noNDS     like doc-line.price-base            no-undo.
define variable prt-stoim           like doc-line.price-base            no-undo.
define variable  v-sum-tot-qnty     as decimal                          no-undo.
define variable v-VAT-gds           like ot-line.VAT-base               no-undo.
define variable v-SLT-gds           like ot-line.SLT-base               no-undo.
define variable v-price-withNDS     like doc-line.price-base            no-undo.
define variable Pg-tqnty            like doc-line.doc-qnty      init 0  no-undo.
define variable Pg-VAT-gds          like ot-line.VAT-base       init 0  no-undo.
define variable Pg-SLT-gds          like ot-line.SLT-base       init 0  no-undo.
define variable Pg-stoim-noNDS      like doc-line.price-base    init 0  no-undo.
define variable Pg-stoim            like doc-line.price-base    init 0  no-undo.
    define variable PrevPage            as int     init 0   no-undo.
define variable VAT-gds             like ot-line.VAT-base               no-undo.
define variable SLT-gds             like ot-line.SLT-base               no-undo.
define variable v-prt-name          as char                             no-undo.
define variable v-okei                as char                             no-undo.
define variable tb-code             as char                             no-undo.
define variable pack-type           as char                             no-undo.
define variable qnty-opl            like doc-line.doc-qnty              no-undo.
define variable qnty-pl             like doc-line.doc-qnty              no-undo.
define variable mass                as decimal     decimals 10          no-undo.
define variable v-tax-name          as char                             no-undo.
define variable v-tax-price         like doc-line.road-tax      init 0  no-undo.
define variable v-tax               like doc-line.road-tax      init 0  no-undo.
define variable v-tax-sum           like doc-line.road-tax      init 0  no-undo.
define variable v-parts-tax-qnty    like doc-line.doc-qnty      init 0  no-undo.
define variable v-tax-parts-price   like doc-line.road-tax      init 0  no-undo.
define variable v-single-line       as char              no-undo.
define variable v-char-counter      as int               no-undo.
define variable gds-str             as char              no-undo.
define variable gds-str1            as char              no-undo.
define variable gds-str2            as char              no-undo.
define variable unit-str            as char              no-undo.
define variable val-str             as char              no-undo.
define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable varprice-base               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define variable v-ext-artic                 like ub.ext-artic.ext-artic no-undo.
define variable v-par-type                  as character                no-undo.
define variable p-torgconf-post-head        as character                no-undo.
define variable v-host-code                 as integer                  no-undo.
define variable p-sf-par                    as logical                  no-undo.
define variable v-curr-code                 as integer                  no-undo.
define variable tmp-var                     as character                no-undo.
define variable FullGdsName                 as logical                  no-undo.
define variable v-ext-doc-type              as character                no-undo.
define variable v-sort-artic                as logical                  no-undo.
define variable v-bcode                      as integer                  no-undo.
define variable  v-trdcattr-type            as character                 no-undo.
define variable  v-code-rec                 as integer                   no-undo.
define variable  v-type-rec                 as character                 no-undo.
define variable  v-recipient-code           as character                 no-undo.
define variable  v-codefirm-rec             as character                 no-undo.
define variable  v-curcode-rec              as integer                   no-undo.
define variable  p-torgconf-wrkr-name             as character    no-undo.
define variable  p-torgconf-post                  as character    no-undo.
define variable  month                            as integer      no-undo.
define variable  p-torgconf-date-char             as character    no-undo.
define variable  v-loadtplace                     as character    no-undo.
define variable  v-loadtname                      as character    no-undo.
define variable v-outhdobj      as logical  init no    no-undo .
define variable v-outhdobj-str  as character no-undo .
define variable v-cli-type      as character no-undo .
define variable v-cli-code      as integer   no-undo .
define variable v-is-hold-doc   as logical   no-undo .
define variable v-disc-mpl       as decimal   no-undo .
define variable v-price-all-mpl  as decimal   no-undo .
    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_temp_gds-name     for temp_gds-name.
do
for buf_trn-doc
  , buf_temp_gds-name
on error undo, return error
:
assign
    v-sort-artic = print-graft
.
assign
    p-mode = caps( p-mode )
.
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
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
find first buf_trn-doc no-lock
     where recid( buf_trn-doc ) = rec_id
.
assign
    v-ext-doc-type = buf_trn-doc.ext-doc-type
.
if v-ext-doc-type = 'ep':U
and ( lookup( "NG":U , p-mode ) <> 0
   or lookup( "IAB":U, p-mode ) <> 0 )
then do:
    assign
        v-ext-doc-type = 'ee':U
    .
end.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
if printRubl = yes
then do:
    assign
        v-curr-code = 0
    .
end.
else do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-curr-code
  )  .
end.
if lookup( "TOPAUKC":U, p-mode ) <> 0
then do:
  assign Costprice = false.
end.
assign
    v-torgconf-ext-doc-type = buf_trn-doc.ext-doc-type
.
run torgconf-read in this-procedure (
      input "torg12":U
    , input v-host-code
    , input buf_trn-doc.obj-type
    , input buf_trn-doc.obj-code
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
run torgconf-get-self-param in this-procedure (
      input buf_trn-doc.obj-type
    , input buf_trn-doc.obj-code
    , input v-curr-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
    return error.
end.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold-doc
  )  .
if  v-is-hold-doc then do:
  run gbl/conf-rd.p ("outhdobj" , v-host-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, "", "", "", no, output v-outhdobj-str , output v-par-type) no-error.
  if error-status :error
  then do:
    assign
      v-outhdobj-str = ""
    .
  end.
  if lookup( "torg12", v-outhdobj-str ) <> 0
  then do:
    assign
      v-outhdobj = yes
    .
  end.
end.
  assign
    v-cli-type = buf_trn-doc.cli-type
    v-cli-code = buf_trn-doc.cli-code
  .
run torgconf-get-recepient-param (
    input buf_trn-doc.doc-code
  , output v-code-rec
  , output v-type-rec
  , output v-codefirm-rec
  , output v-curcode-rec
    ).
if v-code-rec = 0 and
   v-outhdobj = yes and
   v-is-hold-doc = yes
then do:
  assign
    v-type-rec = buf_trn-doc.hold-obj-type
    v-code-rec = buf_trn-doc.hold-obj-code
  .
end.
else if v-code-rec = 0 then do:
    v-type-rec = buf_trn-doc.cli-type .
    v-code-rec = buf_trn-doc.cli-code .
end.
run torgconf-get-sup-param in this-procedure (
      input v-type-rec
    , input v-code-rec
    , input v-curcode-rec
   ) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
run torgconf-get-cli-param in this-procedure (
      input buf_trn-doc.host-code
    , input v-cli-type
    , input v-cli-code
    , input v-curr-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта клиента документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
run torgconf-get-ship-param in this-procedure (
      input buf_trn-doc.host-code
    , input v-type-rec
    , input v-code-rec
    , input v-curcode-rec
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта клиента документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
if p-from-check = yes
then do:
    if v-ext-doc-type <> 'es':U
    and v-ext-doc-type <> 'rs':U
    then do:
        message
            "Документ ТОРГ12 по чекам может быть напечатан"
            skip "только для документов расхода или возврата"
            skip "через кассу."
        view-as alert-box information.
        undo, return .
    end.
    run fill-sjt12 in this-procedure (
        input buf_trn-doc.doc-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка заполнения временной таблицы для продаж по чекам."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
run gbl/conf-rd.p ( "FGdsNinD", buf_trn-doc.host-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, "", "", "", no, output tmp-var, output v-par-type ) no-error.
IF error-status:error
then do:
    assign
        FullGdsName = no
    .
end.
else do:
    assign
        FullGdsName = ( tmp-var = "yes" )
    .
end.
run torgconf-get-post-head in this-procedure (
    input buf_trn-doc.obj-type
  , input buf_trn-doc.obj-code
  , output p-torgconf-post-head
).
run torgconf-get-storekeeper in this-procedure (
    input buf_trn-doc.wrkr
  , output p-torgconf-wrkr-name
  , output p-torgconf-post
).
run torgconf-get-warrant (
    input buf_trn-doc.doc-code
    ).
assign
    v-torg-12-gds-name-length       = ( if v-torgconf-outt12 = yes then 52 else 27 )
.
if session :set-wait-state( "compiler" ) then.
    os-delete log-file-name.
    run writelog in this-procedure (log-file-name, 0, "&Line").
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
    run r-f_t1xl-init in this-procedure .
    assign
        v-single-line = fill("-", 230)
        v-line-counter = 1
        v-doc-line-counter = 1
    .
    find first currency no-lock
        where currency.curr-code = buf_trn-doc.exch-code
    .
    run print-header in this-procedure (
        input buf_trn-doc.doc-code
    ).
    if v-ext-doc-type = 'ep':U
    then do:
        assign
            Invers = yes
        .
    end.
    if p-from-check = yes
    then do:
        if sort-name = yes
        then do:
            if sort-gr = yes
            then do:
                run writelog in this-procedure (log-file-name, 1, "По чекам: Сортировка по имени и группе").
                for each sj-t12
                  , each goods no-lock
                   where goods.gds-code  = sj-t12.gds-code
                break by goods.grp-name
                      by goods.gds-name
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line-sj in this-procedure (
                          input buf_trn-doc.doc-code
                        , input sj-t12.b-code
                    ).
                    accumulate
                        tqnty ( TOTAL )
                        VAT-gds ( TOTAL )
                        SLT-gds ( TOTAL )
                        stoim-noNDS ( TOTAL )
                        stoim ( TOTAL )
                    .
                end.
            end.
            else do:
                run writelog in this-procedure (log-file-name, 1, "По чекам: Сортировка по имени (по группе нет)").
                for each sj-t12
                  , each goods no-lock
                   where goods.gds-code  = sj-t12.gds-code
                break by goods.gds-name
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line-sj in this-procedure (
                          input buf_trn-doc.doc-code
                        , input sj-t12.b-code
                    ).
                    accumulate
                        tqnty ( TOTAL )
                        VAT-gds ( TOTAL )
                        SLT-gds ( TOTAL )
                        stoim-noNDS ( TOTAL )
                        stoim ( TOTAL )
                    .
                end.
            end.
        end.
        else do:
            if sort-gr = yes
            then do:
                run writelog in this-procedure (log-file-name, 1, "По чекам: Сортировка по группе (по имени нет)").
                for each sj-t12
                  , each goods no-lock
                   where goods.gds-code  = sj-t12.gds-code
                break by goods.grp-name
                      by sj-t12.artic
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line-sj in this-procedure (
                          input buf_trn-doc.doc-code
                        , input sj-t12.b-code
                    ).
                    accumulate
                        tqnty ( TOTAL )
                        VAT-gds ( TOTAL )
                        SLT-gds ( TOTAL )
                        stoim-noNDS ( TOTAL )
                        stoim ( TOTAL )
                    .
                end.
            end.
            else do:
                run writelog in this-procedure (log-file-name, 1, "По чекам: Сортировок по группе и по имени нет").
                for each sj-t12
                  , each goods no-lock
                   where goods.gds-code  = sj-t12.gds-code
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line-sj in this-procedure (
                          input buf_trn-doc.doc-code
                        , input sj-t12.b-code
                    ).
                    accumulate
                        tqnty ( TOTAL )
                        VAT-gds ( TOTAL )
                        SLT-gds ( TOTAL )
                        stoim-noNDS ( TOTAL )
                        stoim ( TOTAL )
                    .
                end.
            end.
        end.
    end.
    else do:
        if sort-name = yes
        then do:
            if sort-gr = yes
            then do:
                run writelog in this-procedure (log-file-name, 1, "Сортировка по имени и группе").
                for each doc-line no-lock
                where doc-line.doc-code = buf_trn-doc.doc-code,
                    each goods no-lock
                   where goods.artic     = doc-line.artic
                     and goods.prod-type = doc-line.prod-type
                     and goods.prod-code = doc-line.prod-code
                break by goods.grp-name
                    by goods.gds-name
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                    ).
                    accumulate
                        tqnty ( TOTAL )
                        VAT-gds ( TOTAL )
                        SLT-gds ( TOTAL )
                        stoim-noNDS ( TOTAL )
                        stoim ( TOTAL )
                    .
                end.
            end.
            else do:
                run writelog in this-procedure (log-file-name, 1, "Сортировка по имени (по группе нет)").
                for each doc-line no-lock
                where doc-line.doc-code = buf_trn-doc.doc-code,
                    each goods no-lock
                where goods.artic     = doc-line.artic
                    and goods.prod-type = doc-line.prod-type
                    and goods.prod-code = doc-line.prod-code
                break by goods.gds-name
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                    ).
                    accumulate
                        tqnty ( TOTAL )
                        VAT-gds ( TOTAL )
                        SLT-gds ( TOTAL )
                        stoim-noNDS ( TOTAL )
                        stoim ( TOTAL )
                    .
                end.
            end.
        end.
        else do:
            if sort-gr = yes
            then do:
                if v-sort-artic = yes then do:
                  run writelog in this-procedure (log-file-name, 1, "Сортировка по группе (по имени нет)").
                  for each doc-line no-lock
                  where doc-line.doc-code = buf_trn-doc.doc-code,
                      each goods no-lock
                  where goods.artic     = doc-line.artic
                      and goods.prod-type = doc-line.prod-type
                      and goods.prod-code = doc-line.prod-code
                  break by goods.grp-name
                        by doc-line.artic
                  :
                      run get-okei in this-procedure (
                          input goods.unit-base
                          , output v-okei
                      ).
                      run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                      ).
                      accumulate
                          tqnty ( TOTAL )
                          VAT-gds ( TOTAL )
                          SLT-gds ( TOTAL )
                          stoim-noNDS ( TOTAL )
                          stoim ( TOTAL )
                      .
                  end.
                end.
                else do:
                  run writelog in this-procedure (log-file-name, 1, "Сортировка по группе (по имени нет)").
                  for each doc-line no-lock
                  where doc-line.doc-code = buf_trn-doc.doc-code,
                      each goods no-lock
                  where goods.artic     = doc-line.artic
                      and goods.prod-type = doc-line.prod-type
                      and goods.prod-code = doc-line.prod-code
                  break by goods.grp-name
                        by doc-line.line-num
                  :
                      run get-okei in this-procedure (
                          input goods.unit-base
                          , output v-okei
                      ).
                      run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                      ).
                      accumulate
                          tqnty ( TOTAL )
                          VAT-gds ( TOTAL )
                          SLT-gds ( TOTAL )
                          stoim-noNDS ( TOTAL )
                          stoim ( TOTAL )
                      .
                  end.
                end.
            end.
            else do:
                if v-sort-artic = yes then do:
                  run writelog in this-procedure (log-file-name, 1, "Сортировок по группе и по имени нет").
                  for each doc-line no-lock
                  where doc-line.doc-code = buf_trn-doc.doc-code,
                      each goods no-lock
                  where goods.artic     = doc-line.artic
                      and goods.prod-type = doc-line.prod-type
                      and goods.prod-code = doc-line.prod-code
                  break by doc-line.artic
                  :
                      run get-okei in this-procedure (
                          input goods.unit-base
                          , output v-okei
                      ).
                      run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                      ).
                      accumulate
                          tqnty ( TOTAL )
                          VAT-gds ( TOTAL )
                          SLT-gds ( TOTAL )
                          stoim-noNDS ( TOTAL )
                          stoim ( TOTAL )
                      .
                  end.
                end.
                else do:
                  run writelog in this-procedure (log-file-name, 1, "Сортировок по группе и по имени нет").
                  for each doc-line no-lock
                  where doc-line.doc-code = buf_trn-doc.doc-code,
                      each goods no-lock
                  where goods.artic     = doc-line.artic
                      and goods.prod-type = doc-line.prod-type
                      and goods.prod-code = doc-line.prod-code
                  break by doc-line.line-num
                  :
                      run get-okei in this-procedure (
                          input goods.unit-base
                          , output v-okei
                      ).
                      run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                      ).
                      accumulate
                          tqnty ( TOTAL )
                          VAT-gds ( TOTAL )
                          SLT-gds ( TOTAL )
                          stoim-noNDS ( TOTAL )
                          stoim ( TOTAL )
                      .
                  end.
                end.
            end.
        end.
    end.
    assign
        v-sum-tot-qnty = ( if p-from-check = yes
                           then (accum total tqnty)
                           else buf_trn-doc.fact-qnty )
    .
    if PrintRubl then
        run rep/wp-rub.p ( ( (accum total stoim) + (accum total SLT-gds) ), output s1, output s2 ) .
    else
        run rep/wp.p ( input p-mainmenu-handle, ( (accum total stoim) + (accum total SLT-gds) ), output s1, output s2 ) .
    run rep/wp-qnty.p ( input ( v-doc-line-counter - 1 ), output txt-LC).
    if lookup( "TOPAUKC":U, p-mode ) <> 0 then do:
      run disc-mpl in this-procedure (input buf_trn-doc.doc-code, output v-price-all-mpl ) .
      if v-price-all-mpl > ( accum total stoim ) + (accum total SLT-gds) then do:
        assign v-disc-mpl = v-price-all-mpl - ( accum total stoim ) + (accum total SLT-gds) .
      end.
      else do:
        assign v-disc-mpl = 0.
      end.
    end.
    define variable v-input-value           as character    no-undo.
    define variable v-doc-places            as character    no-undo.
    define variable v-attr-type             as character    no-undo.
    define variable v-attr-value            as character    no-undo.
    define variable v-autonum               as character    no-undo.
    define variable v-automark              as character    no-undo.
    define variable v-driver                as character    no-undo.
    define variable v-cargo-name            as character    no-undo.
    define variable v-cargo-desc            as character    no-undo.
    define variable v-cargo-pack            as character    no-undo.
    define variable v-carry-type            as character    no-undo.
    define variable v-cargo-mass-netto      as decimal      no-undo.
    define variable v-cargo-mass-brutto     as decimal      no-undo.
    define variable v-exp-trans             as decimal      no-undo.
      run gbl/trdcat-v.p (
            input buf_trn-doc.doc-code
          , input 'QntyPlace':U
          , output v-doc-places
          , output v-attr-type
      ).
        run gbl/trdcat-v.p (
            input buf_trn-doc.doc-code
          , input 'Auto':U
          , output v-attr-value
          , output v-attr-type
      ).
      if v-attr-value <> "" then assign v-automark = entry (1 , v-attr-value)
                                  v-autonum = entry (2 , v-attr-value).
      v-attr-value = "".
      run gbl/trdcat-v.p (
            input buf_trn-doc.doc-code
          , input 'Driver':U
          , output v-driver
          , output v-attr-type
      ).
    run gbl/trdcat-v.p (
            input buf_trn-doc.doc-code
          , input 'cargo-desc':U
          , output v-attr-value
          , output v-attr-type
      ).
    if v-attr-value <> "" then assign v-cargo-name = entry (1 , v-attr-value)
                                      v-cargo-pack = entry (2 , v-attr-value).
    v-attr-value = "".
    run gbl/trdcat-v.p (
          input buf_trn-doc.doc-code
        , input 'carry-type':U
        , output v-carry-type
        , output v-attr-type
    ).
    run gbl/trdcat-v.p (
          input buf_trn-doc.doc-code
        , input 'cargo-mass':U
        , output v-attr-value
        , output v-attr-type
    ).
    if v-attr-value <> "" then assign v-cargo-mass-netto = decimal( entry (1 , v-attr-value))
                                      v-cargo-mass-brutto = decimal( entry (2 , v-attr-value)).
    v-attr-value = "".
    run gbl/trdcat-v.p (
          input buf_trn-doc.doc-code
        , input 'exp-trans':U
        , output v-attr-value
        , output v-attr-type
        ).
    v-exp-trans = decimal (v-attr-value).
    v-attr-value = "".
    if v-doc-places <> "" then
      run rep\wp-qnty.p (
            input v-doc-places
          , output v-input-value
      ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_placeAmount":U
        , input v-doc-places
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_placeAmount":U
        , input v-input-value
    ).
    v-input-value = "".
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_carrytype":U
        , input (v-carry-type)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_driver":U
        , input (v-driver)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_automark":U
        , input (v-automark)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_autonum":U
        , input (v-autonum)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_cargoname":U
        , input (v-cargo-name)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_cargopack":U
        , input (if lookup( "TopAukc":U, p-mode ) <> 0 and v-cargo-pack = "" then "палетт"  else v-cargo-pack)
    ).
    if v-cargo-mass-netto <> 0 and v-cargo-mass-brutto <> ? then do:
      run r-f_t1xl-write-cell-data in this-procedure (
            input "f_massNetto":U
          , input string (v-cargo-mass-netto)
      ).
      run rep\wp-qnty.p (
            input v-cargo-mass-netto
          , output v-input-value
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input "f_massNettoSTR":U
          , input (v-input-value)
      ).
      v-input-value = "".
    end.
    if v-cargo-mass-brutto <> 0 and v-cargo-mass-brutto <> ? then do:
      run r-f_t1xl-write-cell-data in this-procedure (
            input "f_massBrutto":U
          , input string (v-cargo-mass-brutto)
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input "h_massBrutto":U
          , input string (v-cargo-mass-brutto)
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input "h_massBrutto1":U
          , input string (v-cargo-mass-brutto)
      ).
      run rep\wp-qnty.p (
            input v-cargo-mass-brutto
          , output v-input-value
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input "f_massBruttoSTR":U
          , input (v-input-value)
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input "h_massBruttoSTR":U
          , input (v-input-value)
      ).
      v-input-value = "".
    end.
    if lookup( "TopAukc":U, p-mode ) <> 0 then do:
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_qntyname":U
        ,input "Одно"
    ).
    end.
    else do:
    if v-input-value = "Один" then v-input-value = "Одно".
    run r-f_t1xl-write-cell-data in this-procedure (
         input "f_qntyname":U
        ,input txt-LC
    ).
    end.
    run r-f_t1xl-write-cell-data in this-procedure (
      input "f_exptrans"
    , input (v-exp-trans)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "it_sum":U
        , input string( (accum total stoim) + (accum total SLT-gds) + v-exp-trans )
    ).
              if lookup( "TopAukc":U, p-mode ) <> 0 then do:
                  run r-f_t1xl-sheet1-write-line-data in this-procedure (
                        input "1"
                      , input v-cargo-name
                      , input ""
                      , input (if v-cargo-pack = ""  then "паллет" else v-cargo-pack)
                      , input (if v-cargo-pack = ""  then "паллет" else v-cargo-pack)
                      , input v-doc-places
                      , input (if v-cargo-mass-netto <> 0 and v-cargo-mass-netto <> ? then string(v-cargo-mass-netto) else "")
                      , input "1"
                      , input string(accum total stoim-noNDS)
                      , input string(accum total stoim-noNDS)
                  ).
                  run r-f_t1xl-write-cell-data in this-procedure (
                       input "margin":U
                      ,input string( round ( ((accum total VAT-gds) + (accum total SLT-gds)) / (accum total stoim), 4 ) )
                  ).
             end.
    run r-f_t1xl-write-cell-data in this-procedure (
          input "N_warrant_char"
        , input ( p-torgconf-N-warrant)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "N_ndovwho"
        , input(p-torgconf-ndovwho)
    ).
    if p-torgconf-date-warrant <> ?
    then do:
      run r-f_t1xl-write-cell-data in this-procedure (
          input "Day_warrant"
        , input (DAY(p-torgconf-date-warrant) )
    ).
            run r-f_t1xl-write-cell-data in this-procedure (
          input "Date_warrant"
        , input (substitute("&1&2&3",MonthNameRusGen(MONTH ( p-torgconf-date-warrant )),"  ", YEAR(p-torgconf-date-warrant) ))
    ).
    end.
    if p-torgconf-date-warrant <> ?
    then do:
        assign
           month =  MONTH ( p-torgconf-date-warrant )
           p-torgconf-date-char = substitute( "&1&2&3&4&5&6", DAY(p-torgconf-date-warrant), "  ", MonthNameRusGen(month), " ", YEAR(p-torgconf-date-warrant), " года")
        .
    end.
    if lookup( "TopAukc":U, p-mode ) <> 0 then
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_lineAmount":U
        , input "Один"
    ).
    else
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_lineAmount":U
        , input ( txt-LC )
    ).
    assign
        s1 = breakstr( s1, 500, input-output s1, input-output s2)
    .
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_sumLiteral1":U
        , input s1
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "f_sumLiteral2":U
        , input s2
    ).
    if v-ext-doc-type <> 'ie':U
    then do:
      run r-f_t1xl-write-cell-data in this-procedure (
           input "f_permitterStatus":U
         , input ( if v-torgconf-outsubs = no then v-torgconf-ogr-post else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
           input "f_permitterName":U
         , input ( if v-torgconf-outsubs = no  then v-torgconf-ogr-name else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
           input "f_buhName":U
         , input ( if v-torgconf-outsubs = no then v-torgconf-main-buh else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input "accept_position"
        , input ( if v-torgconf-outsubs = no  then p-torgconf-accept-position else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input "accept_fname"
        , input ( if v-torgconf-outsubs = no  then p-torgconf-accept-fname else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input "f_post"
        , input ( if v-torgconf-outsubs = no  then p-torgconf-post else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input "f_post1"
        , input ( if v-torgconf-outsubs = no  then p-torgconf-post else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input "f_wkr_name"
        , input ( if v-torgconf-outsubs = no  then p-torgconf-wrkr-name else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input "f_wkr_name1"
        , input ( if v-torgconf-outsubs = no  then p-torgconf-wrkr-name else "":U )
      ).
      end.
    else do:
      run r-f_t1xl-write-cell-data in this-procedure (
          input "loadtplace"
        , input (if v-torgconf-outsubs = no  then p-torgconf-post else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input "loadtname"
         , input (if v-torgconf-outsubs = no  then p-torgconf-wrkr-name else "":U )
      ).
    end.
    v-loadtplace = p-torgconf-post.
    v-loadtname = p-torgconf-wrkr-name.
    put stream out-stream unformatted
          chr(10)
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + chr(10)
    .
    run r-f_t1xl-close in this-procedure .
if session :set-wait-state( "" ) then.
    output stream out-stream close.
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
procedure print-line :
define input parameter p-trn-doc-code   as character        no-undo.
define input parameter p-sort-type      as character        no-undo.
define variable v-price-is-changed      as logical  no-undo.
define variable v-sum-prt-qnty                  as decimal      no-undo.
define variable v-avg-prt-price                 as decimal      no-undo.
define variable v-avg-prt-price-no-tax          as decimal      no-undo.
define variable v-sum-SLT                       as decimal      no-undo.
define variable v-sum-VAT                       as decimal      no-undo.
define variable v-avg-VAT                       as decimal      no-undo.
define variable v-sum-prt-sum-with-tax          as decimal      no-undo.
define variable v-avg-prt-sum-with-tax          as decimal      no-undo.
define variable v-sum-prt-sum-without-tax       as decimal      no-undo.
define variable v-avg-prt-sum-without-tax       as decimal      no-undo.
define variable v-gds-name-length               as integer      no-undo.
define variable v-gds-name                      as character    no-undo.
define variable v-void-decimal                  as decimal      no-undo.
define variable v-price-no-VAT                  as decimal      no-undo.
define variable v-VAT-pc                        as decimal      no-undo.
define variable v-SLT-pc                        as decimal      no-undo.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_tax_parts         for parts.
    define buffer buf_temp_gds-name for temp_gds-name.
do
for buf_trn-doc
  , buf_tax_parts
  , buf_temp_gds-name
on error undo, return error
:
    run writelog in this-procedure (log-file-name, 1, "Печать строки товара").
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-code
    .
    empty temp-table buf_temp_gds-name.
    assign
        v-torg-12-gds-name-key  = 0
        v-gds-name              = goods.gds-name
    .
    if FullGdsName
    and v-gds-name <> "":U
    then do:
        do
        while v-gds-name <> "":U
        :
            assign
                v-torg-12-gds-name-key = v-torg-12-gds-name-key + 1
            .
            create buf_temp_gds-name.
            assign
                buf_temp_gds-name.gdn-key = v-torg-12-gds-name-key
            .
            run p-fmt-split-string in this-procedure (
                  input v-gds-name
                , input v-torg-12-gds-name-length
                , output buf_temp_gds-name.gdnString
                , output v-gds-name
            ).
        end.
        find first buf_temp_gds-name
             where buf_temp_gds-name.gdn-key = 1
        no-error.
        if available buf_temp_gds-name
        then do:
        assign
                v-gds-name    = buf_temp_gds-name.gdnString
        .
    end.
    else do:
        assign
                v-gds-name    = goods.gds-name
        .
    end.
    end.
    else do:
        assign
            v-torg-12-gds-name-key = v-torg-12-gds-name-key + 1
        .
        create buf_temp_gds-name.
        assign
            buf_temp_gds-name.gdn-key   = v-torg-12-gds-name-key
            buf_temp_gds-name.gdnString = v-gds-name
        .
    end.
    run writelog in this-procedure (
        log-file-name,
        2,
        substitute( "Определили наименование товара ( &1 )", v-gds-name )
                                        ).
    find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
    assign
        v-rootnode-code = gds-prt.node-code
    .
    if ( ( gds-prt.node-name <> '_Пустая шкала':U )
        and v-cntxp-doc-prt = yes )
    and ( not Invers )
    then do:
        run writelog in this-procedure (log-file-name, 2, "Не пустая шкала, не отключена печать по шкалам и накладная не от имени поставщика").
        find first gds-dtl no-lock
            where gds-dtl.prod-type = doc-line.prod-type
              and gds-dtl.prod-code = doc-line.prod-code
              and gds-dtl.artic     = doc-line.artic
              and gds-dtl.doc-code  = doc-line.doc-code
        no-error.
        if not available (gds-dtl)
        then assign
            price-noNDS   = 0
            price-withNDS = 0
        .
        if PrintScale
        then do:
            if lookup( "TopAukc":U, p-mode ) = 0 then do:
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
            end.
            assign
                v-line-counter = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        end.
        for each gds-dtl no-lock
           where gds-dtl.prod-type  = doc-line.prod-type
             and gds-dtl.prod-code  = doc-line.prod-code
             and gds-dtl.artic      = doc-line.artic
             and gds-dtl.doc-code   = doc-line.doc-code
        :
            find first gds-prt no-lock
                    where gds-prt.node-code = gds-dtl.prt-code
            .
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = doc-line.artic
       and out-vatp_doc-line.prod-type  = doc-line.prod-type
       and out-vatp_doc-line.prod-code  = doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = doc-line.artic
                               and out-vatp_parts.prod-type  = doc-line.prod-type
                               and out-vatp_parts.prod-code  = doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
  discnt-base-sale            = gds-dtl.discnt-base
  price-base-with-tax-sale    = (gds-dtl.price-base - gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
  discnt-rubl-sale            = gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (gds-dtl.price-rubl - gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - varprice-base-cons) * doc-line.vat-pc / (100 + doc-line.vat-pc) * gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - varprice-rubl-cons) * doc-line.vat-pc / (100 + doc-line.vat-pc) * gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
            assign
                v-sum-prt-qnty  = v-sum-prt-qnty + gds-dtl.fact-qnty
                VAT-gds         = ( if PrintRubl then vat-rubl-buyer            else vat-base-buyer           )
                SLT-gds         = ( if PrintRubl then slt-rubl-sale             else slt-base-sale            )
                price-withNDS   = ( if PrintRubl then price-rubl-with-tax-sale  else price-base-with-tax-sale )
            .
            if VAT-gds = ?       then assign  VAT-gds       = 0.
            if SLT-gds = ?       then assign  SLT-gds       = 0.
            if price-withNDS = ? then assign  price-withNDS = 0.
            assign
                v-sum-VAT                 = v-sum-VAT                   + VAT-gds * gds-dtl.fact-qnty
                v-sum-prt-sum-with-tax    = v-sum-prt-sum-with-tax      + ( price-withNDS * gds-dtl.fact-qnty )
                v-sum-prt-sum-without-tax = v-sum-prt-sum-without-tax   + ( ( price-withNDS - VAT-gds - SLT-gds )
                                                                            * gds-dtl.fact-qnty )
            .
        end.
        assign
            v-avg-VAT                   = ( if v-sum-VAT = ? or v-sum-VAT = 0
                                          then 0
                                          else v-sum-VAT / v-sum-prt-qnty )
            v-avg-prt-price             = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                          then 0
                                          else v-sum-prt-sum-with-tax / v-sum-prt-qnty )
            v-avg-prt-price-no-tax      = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                          then 0
                                          else v-sum-prt-sum-without-tax / v-sum-prt-qnty )
            v-avg-prt-sum-with-tax      = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                          then 0
                                          else v-sum-prt-sum-with-tax / v-sum-prt-qnty )
            v-avg-prt-sum-without-tax   = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                          then 0
                                          else v-sum-prt-sum-without-tax / v-sum-prt-qnty )
        .
        run print-line-dtl in this-procedure (
              recid( doc-line )
            , input-output v-avg-VAT
            , input-output v-avg-prt-price
            , input-output v-avg-prt-price-no-tax
            , input-output v-avg-prt-sum-with-tax
            , input-output v-avg-prt-sum-without-tax
            , output prt-tqnty
            , output prt-VAT-gds
            , output prt-SLT-gds
            , output prt-stoim-noNDS
            , output prt-stoim
        ).
        accumulate
            prt-tqnty ( TOTAL )
            prt-VAT-gds ( TOTAL )
            prt-SLT-gds ( TOTAL )
            prt-stoim-noNDS ( TOTAL )
            prt-stoim ( TOTAL )
        .
        assign
            tqnty = ( ACCUM TOTAL prt-tqnty )
            VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
            SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
            stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
            stoim = ( ACCUM TOTAL prt-stoim )
        .
        if not PrintScale
        then do:
            find first bar-code no-lock
                 where bar-code.gds-code = goods.gds-code
                   and bar-code.unit-cli = goods.unit-base
                   and bar-code.node-code = v-rootnode-code
                   and bar-code.part-code = ""
                   and bar-code.in-code = ""
            .
            assign
              v-ext-artic = ""
            .
            find first ub.ext-artic no-lock
                 where ub.ext-artic.gds-code = bar-code.gds-code
                   and ub.ext-artic.cli-code = v-cli-code
                   and ub.ext-artic.cli-type = v-cli-type
                   and ub.ext-artic.status_  = 'тек':U no-error.
            if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
            if lookup( "TopAukc":U, p-mode ) = 0 then do:
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input goods.unit-base
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( stoim / tqnty )
                , input string( stoim + SLT-gds )
            ).
            end.
            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        end.
    end.
    else do:
        run writelog in this-procedure (log-file-name, 2, "Пустая шкала или отключена печать по шкалам или накладная от имени поставщика").
        find first bar-code no-lock
            where bar-code.gds-code = goods.gds-code
            and bar-code.unit-cli   = goods.unit-base
            and bar-code.node-code  = v-rootnode-code
            and bar-code.part-code  = ""
            and bar-code.in-code    = ""
        .
        assign
          v-ext-artic = ""
        .
        find first ub.ext-artic no-lock
             where ub.ext-artic.gds-code = bar-code.gds-code
               and ub.ext-artic.cli-code = v-cli-code
               and ub.ext-artic.cli-type = v-cli-type
               and ub.ext-artic.status_  = 'тек':U no-error.
        if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
        if v-ext-doc-type = 'ep':U
        then do:
            run writelog in this-procedure (log-file-name, 3, "Возврат поставщику при печати по партиям "
                                                ).
            assign
                v-price-is-changed  =  no
            .
            for each parts
               where parts.obj-type     = doc-line.obj-type
                 and parts.obj-code     = doc-line.obj-code
                 and parts.artic        = goods.artic
                 and parts.prod-type    = goods.prod-type
                 and parts.prod-code    = goods.prod-code
                 and parts.out-code     = doc-line.doc-code
            :
                run print-line-parts in this-procedure (
                      input buf_trn-doc.doc-code
                    , input v-price-is-changed
                    , input v-gds-name
                    , input-output v-VAT-gds
                    , input-output v-SLT-gds
                    , input-output v-price-withNDS
                    , input-output v-tax
                    , input-output v-tax-price
                    , input-output v-tax-sum
                ).
                accumulate
                    prt-tqnty ( TOTAL )
                    prt-VAT-gds ( TOTAL )
                    prt-SLT-gds ( TOTAL )
                    prt-stoim-noNDS ( TOTAL )
                    prt-stoim ( TOTAL )
                .
                assign
                    v-line-counter     = v-line-counter + 1
                    v-doc-line-counter = v-doc-line-counter + 1
                .
            end.
            assign
                tqnty = ( ACCUM TOTAL prt-tqnty )
                VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
                SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
                stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
                stoim = ( ACCUM TOTAL prt-stoim )
            .
            run writelog in this-procedure (log-file-name, 3,
                                                            "После цикла по партиям: Установили количество ( "
                                                            + dtm-char( string(tqnty) )
                                                            + " ) и сумму ( "
                                                            + dtm-char( string( stoim ) )
                                                            + " ) для общего итога "
                                                ).
        end.
        else do:
            if Invers
            then do:
                assign
                    tqnty    = doc-line.cli-qnty
                    unit-str = doc-line.unit-cli
                .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   buf_trn-doc.doc-code
  ,input   buf_trn-doc.base-rate
  ,input   buf_trn-doc.base-scale
  ,input   buf_trn-doc.exch-rate
  ,input   buf_trn-doc.exch-scale
  ,input   buf_trn-doc.vat-type
  ,input   buf_trn-doc.slt-type
  ,input   doc-line.artic
  ,input   doc-line.prod-type
  ,input   doc-line.prod-code
  ,input   doc-line.price-cli
  ,input   doc-line.cli-base-rate
  ,input   doc-line.price-rubl
  ,input   doc-line.vat-pc
  ,input   doc-line.slt-pc
  ,input   doc-line.road-tax
  ,input   doc-line.transport-rubl
  ,input   doc-line.other-rubl
  ,output  varprice-cli
  ,output  varprice-cli-unit-base
  ,output  varprice-road-tax
  ,output  varprice-other-exp
  ,output  varprice-transport-exp
  ,output  varprice-without-abs
  ,output  varprice-slt
  ,output  varprice-no-slt
  ,output  varprice-vat
  ,output  varprice-no-vat-slt
  ,output  varprice-rubl
  ,output  varprice-road-tax-rubl
  ,output  varprice-other-exp-rubl
  ,output  varprice-transport-exp-rubl
  ,output  varprice-without-abs-rubl
  ,output  varprice-slt-rubl
  ,output  varprice-no-slt-rubl
  ,output  varprice-vat-rubl
  ,output  varprice-no-vat-slt-rubl
  ,output  varprice-base
  ,output  varprice-road-tax-base
  ,output  varprice-other-exp-base
  ,output  varprice-transport-exp-base
  ,output  varprice-without-abs-base
  ,output  varprice-slt-base
  ,output  varprice-no-slt-base
  ,output  varprice-vat-base
  ,output  varprice-no-vat-slt-base
  ) no-error.
                if error-status:error then do:
                  return error "Ошибка при пересчете линии документа".
                end.
                assign
                    VAT-gds       = varprice-vat
                    SLT-gds       = varprice-slt
                    price-withNDS = varprice-no-vat-slt + VAT-gds + SLT-gds
                .
            end.
            else do:
                find first gds-dtl no-lock
                     where gds-dtl.doc-code      = doc-line.doc-code
                       and gds-dtl.prod-type   = doc-line.prod-type
                       and gds-dtl.prod-code   = doc-line.prod-code
                       and gds-dtl.artic       = doc-line.artic
                       and gds-dtl.prt-code    = v-rootnode-code
                no-error.
                if available gds-dtl
                then do:
                    assign
                        tqnty    = gds-dtl.fact-qnty
                    .
                end.
                else do:
                    assign
                        tqnty    = doc-line.fact-qnty
                    .
                end.
                assign
                    unit-str = goods.unit-base
                .
                if buf_trn-doc.doc-type = 'при':U
                or v-ext-doc-type = 'ep':U
                or CostPrice
                then do:
assign
  price-rubl-with-tax-loc = doc-line.price-rubl
  price-base-with-tax-loc = doc-line.price-base
.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
   find first in-vatp-goods where in-vatp-goods.artic     = doc-line.artic     and
                                     in-vatp-goods.prod-type = doc-line.prod-type and
                                     in-vatp-goods.prod-code = doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = doc-line.road-tax
          road-tax-rubl-loc = doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = doc-line.road-tax
          road-tax-base-loc = doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
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
                        VAT-gds         = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
                        SLT-gds         = ( if PrintRubl then slt-rubl-loc else slt-base-loc )
                        v-tax-price     = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
                        price-withNDS   = ( if PrintRubl
                                            then price-rubl-with-tax-loc - v-tax-price
                                            else price-base-with-tax-loc - v-tax-price
                                          )
                        v-tax           = v-tax-price * tqnty
                        v-tax-sum       = v-tax-sum + v-tax
                    .
                end.
                else do:
                    if available gds-dtl
                    then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = doc-line.artic
       and out-vatp_doc-line.prod-type  = doc-line.prod-type
       and out-vatp_doc-line.prod-code  = doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = doc-line.artic
                               and out-vatp_parts.prod-type  = doc-line.prod-type
                               and out-vatp_parts.prod-code  = doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
  discnt-base-sale            = gds-dtl.discnt-base
  price-base-with-tax-sale    = (gds-dtl.price-base - gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
  discnt-rubl-sale            = gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (gds-dtl.price-rubl - gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - varprice-base-cons) * doc-line.vat-pc / (100 + doc-line.vat-pc) * gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - varprice-rubl-cons) * doc-line.vat-pc / (100 + doc-line.vat-pc) * gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
                      assign
                          VAT-gds         = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
                          SLT-gds         = ( if PrintRubl then slt-rubl-sale  else slt-base-sale  )
                          v-tax-price     = ( if PrintRubl then road-tax-rubl-sale else road-tax-base-sale )
                          price-withNDS   = ( if PrintRubl
                                              then price-rubl-with-tax-sale - v-tax-price
                                              else price-base-with-tax-sale - v-tax-price
                                            )
                          v-tax           = v-tax-price * tqnty
                          v-tax-sum       = v-tax-sum + v-tax
                      .
                    end.
                end.
            end.
            if VAT-gds = ? then assign VAT-gds = 0.
            if SLT-gds = ? then assign SLT-gds = 0.
            assign
                price-noNDS = price-withNDS - VAT-gds - SLT-gds
            .
            if p-round = "round":U
            then do:
                run p-fmt-round in this-procedure (
                      input tqnty
                    , input price-noNDS
                    , input VAT-gds
                    , input SLT-gds
                    , input 0
                    , output price-noNDS
                    , output v-VAT-pc
                    , output v-SLT-pc
                    , output VAT-gds
                    , output SLT-gds
                    , output v-void-decimal
                    , output stoim-noNDS
                    , output stoim
                ).
                assign
                    stoim           = stoim - SLT-gds
                    price-withNDS   = stoim / tqnty
                .
            end.
            else do:
                assign
                    VAT-gds     = VAT-gds * tqnty
                    SLT-gds     = SLT-gds * tqnty
                    stoim-noNDS = price-noNDS * tqnty
                    stoim       = stoim-noNDS + VAT-gds
                .
            end.
            run writelog in this-procedure (log-file-name, 3, "Печать не по партиям. Стоимость с НДС ( "
                                                                        + dtm-char( string( stoim ) )
                                                                        + " ). Количество ( "
                                                                        + dtm-char( string( tqnty ) )
                                                                        + " ). Третий налог ( "
                                                                        + dtm-char( string( v-tax ) )
                                                                        + " )"
                                                ).
            if lookup( "TopAukc":U, p-mode ) = 0 then do:
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input unit-str
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( price-noNDS + VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            end.
            if hvrdtax (recid(goods))
            then do:
                run tax-name (  input 'rdt':U
                             , output v-tax-name
                             ).
                run writelog in this-procedure (log-file-name, 4, "Есть третий налог ( " + dtm-char( v-tax-name )
                                                        + " ) сумма ( " + dtm-char( string( v-tax ) ) + " )"
                                                    ).
                parts-for-tax:
                for each buf_tax_parts
                   where buf_tax_parts.obj-type     = doc-line.obj-type
                     and buf_tax_parts.obj-code     = doc-line.obj-code
                     and buf_tax_parts.artic        = goods.artic
                     and buf_tax_parts.prod-type    = goods.prod-type
                     and buf_tax_parts.prod-code    = goods.prod-code
                     and buf_tax_parts.out-code     = doc-line.doc-code
                break by buf_tax_parts.road-tax-base
                :
                    if first-of (buf_tax_parts.road-tax-base)
                    then do:
                        assign
                            v-parts-tax-qnty    = 0
                            v-tax               = 0
                            v-tax-parts-price   =  ( if PrintRubl
                                                    then buf_tax_parts.road-tax-rubl
                                                    else buf_tax_parts.road-tax-base )
                        .
                    end.
                    assign
                        v-parts-tax-qnty    = v-parts-tax-qnty + buf_tax_parts.fact-qnty
                        v-tax               = v-tax + ( v-tax-parts-price * buf_tax_parts.fact-qnty )
                    .
                    if not last-of (buf_tax_parts.road-tax-base)
                    then do:
                        next parts-for-tax.
                    end.
                    if p-round = "round":U
                    then do:
                        run p-fmt-round in this-procedure (
                              input v-parts-tax-qnty
                            , input v-tax-parts-price
                            , input 0
                            , input 0
                            , input 0
                            , output v-tax-parts-price
                            , output v-void-decimal
                            , output v-void-decimal
                            , output v-void-decimal
                            , output v-void-decimal
                            , output v-void-decimal
                            , output v-tax
                            , output v-void-decimal
                        ).
                    end.
                end.
                if lookup( "TopAukc":U, p-mode ) = 0 then do:
                run r-f_t1xl-sheet1-write-line-data in this-procedure (
                      input 0
                    , input v-tax-name
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input string( v-parts-tax-qnty )
                    , input string( v-tax-parts-price )
                    , input string( v-tax )
                ).
                end.
                assign
                    v-tax           = v-tax-price * tqnty
                    price-noNDS     = price-noNDS + v-tax-price
                    stoim-noNDS     = price-noNDS * tqnty
                    stoim           = stoim-noNDS + VAT-gds
                    v-line-counter  = v-line-counter + 1
                .
                run writelog in this-procedure (log-file-name, 4,
                                        "Снова вычислили суммы для строки. Сумма с НДС ( "
                                        + dtm-char( string( stoim ) )
                                        + " )"
                                                    ).
            end.
            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        end.
    end.
end.
end procedure.
procedure print-line-parts :
define input parameter p-trn-doc-code           as character        no-undo.
define input parameter p-price-is-changed       as logical          no-undo.
define input parameter p-gds-name               as character        no-undo.
define input-output parameter p-VAT-gds         as decimal          no-undo.
define input-output parameter p-SLT-gds         as decimal          no-undo.
define input-output parameter p-price-withNDS   as decimal          no-undo.
define input-output parameter p-tax             as decimal          no-undo.
define input-output parameter p-tax-price       as decimal          no-undo.
define input-output parameter p-tax-sum         as decimal          no-undo.
    define variable v-tax-name          as character    no-undo.
    define variable v-VAT-pc            as decimal      no-undo.
    define variable v-SLT-pc            as decimal      no-undo.
    define variable v-void-decimal      as decimal      no-undo.
    define buffer buf_trn-doc       for trn-doc.
do
for buf_trn-doc
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-code
    .
    if p-price-is-changed  =  no
    or CostPrice = yes
    then do:
assign
  price-rubl-with-tax-loc = parts.price-rubl
  price-base-with-tax-loc = parts.price-base
.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if parts.out-code = 'free-zone':U     or
     parts.out-code = 'out-zone':U   or
     parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = parts.out-code
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
   price-cli-with-tax-loc = parts.price-cli
   cli-base-rate          = parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if parts.road-tax-base  = ? then 0 else parts.road-tax-base)
           road-tax-rubl-loc  = (if parts.road-tax-rubl  = ? then 0 else parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if parts.transport-base = ? then 0 else parts.transport-base)
          transport-rubl-loc = (if parts.transport-rubl = ? then 0 else parts.transport-rubl)
          other-base-loc     = (if parts.other-base     = ? then 0 else parts.other-base)
          other-rubl-loc     = (if parts.other-rubl     = ? then 0 else parts.other-rubl)
          vat-pc-loc         = (if parts.vat-pc         = ? then 0 else parts.vat-pc)
          slt-pc-loc         = (if parts.slt-pc         = ? then 0 else parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / parts.price-cli .
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
            p-VAT-gds       = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
            p-SLT-gds       = ( if PrintRubl then slt-rubl-loc else slt-base-loc )
            p-tax-price     = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
            p-price-withNDS = ( if PrintRubl
                              then price-rubl-with-tax-loc - transport-rubl-loc - other-rubl-loc - p-tax-price
                              else price-base-with-tax-loc - transport-base-loc - other-base-loc - p-tax-price )
            p-tax           = p-tax-price * parts.qnty
            p-tax-sum       = p-tax-sum + p-tax
        .
    end.
    if VAT-gds = ? then VAT-gds = 0.
    if SLT-gds = ? then SLT-gds = 0.
    assign
        tqnty           = parts.fact-qnty
        unit-str        = goods.unit-base
        price-noNDS     = p-price-withNDS - p-VAT-gds - p-SLT-gds
        VAT-gds         = p-VAT-gds * tqnty
        SLT-gds         = p-SLT-gds * tqnty
        stoim-noNDS     = price-noNDS * tqnty
        stoim           = stoim-noNDS + VAT-gds
        price-withNDS   = p-price-withNDS
    .
    run writelog in this-procedure (
          input log-file-name
        , input 5
        , input substitute( "Партия: Кол-во ( &1 ) c НДС ( &2 )"
                            , dtm-char( string( tqnty ) )
                            , dtm-char( string( price-withNDS ) ) )
    ).
    if p-round = "round":U
    then do:
        run p-fmt-round in this-procedure (
              input tqnty
            , input price-noNDS
            , input VAT-gds     / tqnty
            , input SLT-gds     / tqnty
            , input 0
            , output price-noNDS
            , output v-VAT-pc
            , output v-SLT-pc
            , output VAT-gds
            , output SLT-gds
            , output v-void-decimal
            , output stoim-noNDS
            , output stoim
        ).
        assign
            stoim           = stoim - SLT-gds
        .
    end.
    assign
      v-ext-artic = ""
    .
    find first ub.ext-artic no-lock
          where ub.ext-artic.gds-code = bar-code.gds-code
            and ub.ext-artic.cli-code = v-cli-code
            and ub.ext-artic.cli-type = v-cli-type
            and ub.ext-artic.status_  = 'тек':U no-error.
    if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
    if lookup( "TopAukc":U, p-mode ) = 0 then do:
    run r-f_t1xl-sheet1-write-line-data in this-procedure (
          input v-doc-line-counter
        , input substitute( "&1 &2", goods.artic, goods.gds-name )
        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
        , input unit-str
        , input "":U
        , input "":U
        , input "":U
        , input string( tqnty )
        , input string( price-noNDS )
        , input string( stoim + SLT-gds )
    ).
    end.
    assign
        prt-tqnty =  tqnty
        prt-VAT-gds = VAT-gds
        prt-SLT-gds = SLT-gds
        prt-stoim-noNDS = price-noNDS * prt-tqnty
        prt-stoim = prt-stoim-noNDS + prt-VAT-gds
    .
    if hvrdtax (recid(goods))
    then do:
        run tax-name (  input 'rdt':U
                    , output v-tax-name
                    ).
        run writelog in this-procedure (
              input log-file-name
            , input 4
            , input substitute( "Есть третий налог ( &1 ) сумма ( &2 )"
                                , dtm-char( v-tax-name )
                                , dtm-char( string( p-tax ) ) )
        ).
        if p-round = "round":U
        then do:
            run p-fmt-round in this-procedure (
                  input tqnty
                , input p-tax-price
                , input 0
                , input 0
                , input 0
                , output p-tax-price
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-decimal
                , output p-tax
                , output v-void-decimal
            ).
        end.
        if lookup( "TopAukc":U, p-mode ) = 0 then do:
        run r-f_t1xl-sheet1-write-line-data in this-procedure (
              input 0
            , input v-tax-name
            , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
            , input unit-str
            , input "":U
            , input "":U
            , input "":U
            , input string( tqnty )
            , input string( p-tax-price )
            , input string( p-tax )
        ).
        end.
        assign
            price-withNDS   = p-price-withNDS + p-tax-price
            price-noNDS     = price-withNDS - p-VAT-gds - p-SLT-gds
            prt-stoim-noNDS = price-noNDS * tqnty
            prt-stoim       = prt-stoim-noNDS + VAT-gds
            v-line-counter  = v-line-counter + 1
        .
        run writelog in this-procedure (
              input log-file-name
            , input 4
            , input substitute( "Еще раз вычислили сумму с НДС ( &1 ) для общего итога"
                                , dtm-char( string(prt-stoim) ) )
        ).
    end.
end.
end procedure.
procedure print-line-dtl :
define input parameter p-doc-line-recid                     as recid            no-undo.
define input-output parameter p-avg-VAT                     as decimal          no-undo.
define input-output parameter p-avg-prt-price               as decimal          no-undo.
define input-output parameter p-avg-prt-price-no-tax        as decimal          no-undo.
define input-output parameter p-avg-prt-sum-with-tax        as decimal          no-undo.
define input-output parameter p-avg-prt-sum-without-tax     as decimal          no-undo.
define output parameter p-prt-tqnty                         as decimal          no-undo.
define output parameter p-prt-VAT-gds                       as decimal          no-undo.
define output parameter p-prt-SLT-gds                       as decimal          no-undo.
define output parameter p-prt-stoim-noNDS                   as decimal          no-undo.
define output parameter p-prt-stoim                         as decimal          no-undo.
    define variable v-avg-prt-sum-without-tax-out   as decimal      no-undo.
    define variable v-avg-prt-sum-with-tax-out      as decimal      no-undo.
    define variable v-avg-VAT-out                   as decimal      no-undo.
    define variable v-VAT-pc                        as decimal      no-undo.
    define variable v-SLT-pc                        as decimal      no-undo.
    define variable v-void-decimal                  as decimal      no-undo.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
do
for buf_trn-doc
  , buf_doc-line
on error undo, return error
:
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = buf_doc-line.doc-code
    .
    assign
        p-prt-tqnty       = 0.0
        p-prt-VAT-gds     = 0.0
        p-prt-SLT-gds     = 0.0
        p-prt-stoim-noNDS = 0.0
        p-prt-stoim       = 0.0
    .
        for each gds-dtl no-lock
           where gds-dtl.prod-type = buf_doc-line.prod-type
             and gds-dtl.prod-code = buf_doc-line.prod-code
             and gds-dtl.artic     = buf_doc-line.artic
             and gds-dtl.doc-code  = buf_doc-line.doc-code
        :
            find first gds-prt no-lock
                 where gds-prt.node-code = gds-dtl.prt-code
            .
            if CostPrice = yes
            then do:
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
                    VAT-gds = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
                    SLT-gds = ( if PrintRubl then slt-rubl-loc else slt-base-loc )
                    price-withNDS = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
                .
            end.
            else do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
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
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = gds-dtl.discnt-base
  price-base-with-tax-sale    = (gds-dtl.price-base - gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (gds-dtl.price-rubl - gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-base - gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-base - gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else gds-dtl.price-rubl - gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
                assign
                    VAT-gds = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
                    SLT-gds = ( if PrintRubl then slt-rubl-sale  else slt-base-sale  )
                    price-withNDS = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
                .
            end.
            if VAT-gds = ? then VAT-gds = 0.
            if SLT-gds = ? then SLT-gds = 0.
            assign
                price-noNDS     = price-withNDS - VAT-gds - SLT-gds
                prt-tqnty       = gds-dtl.fact-qnty
            .
            if p-round = "round":U
            then do:
                run p-fmt-round in this-procedure (
                      input prt-tqnty
                    , input price-noNDS
                    , input VAT-gds
                    , input SLT-gds
                    , input 0
                    , output price-noNDS
                    , output v-vat-pc
                    , output v-slt-pc
                    , output prt-VAT-gds
                    , output prt-SLT-gds
                    , output v-void-decimal
                    , output prt-stoim-noNDS
                    , output prt-stoim
                ).
                assign
                    prt-stoim       = prt-stoim - prt-SLT-gds
                .
            end.
            else do:
                assign
                    prt-VAT-gds     = VAT-gds * prt-tqnty
                    prt-SLT-gds     = SLT-gds * prt-tqnty
                    prt-stoim-noNDS = price-noNDS * prt-tqnty
                    prt-stoim       = prt-stoim-noNDS + prt-VAT-gds
                .
            end.
            assign
                p-prt-tqnty       = p-prt-tqnty       + prt-tqnty
                p-prt-VAT-gds     = p-prt-VAT-gds     + prt-VAT-gds
                p-prt-SLT-gds     = p-prt-SLT-gds     + prt-SLT-gds
                p-prt-stoim-noNDS = p-prt-stoim-noNDS + prt-stoim-noNDS
                p-prt-stoim       = p-prt-stoim       + prt-stoim
            .
            if PrintScale
            then do:
                find first bar-code no-lock
                     where bar-code.gds-code = goods.gds-code
                       and bar-code.unit-cli = goods.unit-base
                       and bar-code.node-code = gds-dtl.prt-code
                       and bar-code.part-code = ""
                       and bar-code.in-code = ""
                .
                assign
                 v-ext-artic = ""
                .
                find first ub.ext-artic no-lock
                     where ub.ext-artic.gds-code = bar-code.gds-code
                       and ub.ext-artic.cli-code = v-cli-code
                       and ub.ext-artic.cli-type = v-cli-type
                       and ub.ext-artic.status_  = 'тек':U no-error.
                if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
                v-prt-name = "".
                do while available gds-prt:
                    if available gds-prt
                    then assign
                        v-prt-name = "\" + string( gds-prt.node-name, "x(10)" ) + v-prt-name
                    .
                    assign
                        v-node-code = gds-prt.upper-code
                    .
                    find first gds-prt no-lock
                         where gds-prt.node-code = v-node-code
                           and gds-prt.root <> yes
                    no-error.
                end.
                if buf_trn-doc.doc-type = 'при':U
                then assign
                    p-avg-prt-price             = price-withNDS
                    p-avg-prt-price-no-tax      = price-noNDS
                    p-avg-VAT                   = prt-VAT-gds
                    p-avg-prt-sum-with-tax      = prt-stoim
                    p-avg-prt-sum-without-tax   = prt-stoim-noNDS
                .
                else assign
                    v-avg-VAT-out                 = p-avg-VAT                  * gds-dtl.fact-qnty
                    v-avg-prt-sum-with-tax-out    = p-avg-prt-sum-with-tax     * gds-dtl.fact-qnty
                    v-avg-prt-sum-without-tax-out = p-avg-prt-sum-without-tax  * gds-dtl.fact-qnty
                .
                if v-ext-doc-type = 'ep':U
                then do:
                    if p-round = "round":U
                    then do:
                        run p-fmt-round in this-procedure (
                              input prt-tqnty
                            , input p-avg-prt-price-no-tax
                            , input v-avg-VAT-out     / tqnty
                            , input prt-SLT-gds       / tqnty
                            , input 0
                            , output p-avg-prt-price-no-tax
                            , output v-vat-pc
                            , output v-slt-pc
                            , output v-avg-VAT-out
                            , output prt-SLT-gds
                            , output v-void-decimal
                            , output v-avg-prt-sum-without-tax-out
                            , output v-avg-prt-sum-with-tax-out
                        ).
                        assign
                            v-avg-prt-sum-with-tax-out  = v-avg-prt-sum-with-tax-out - prt-SLT-gds
                            p-avg-prt-price             = v-avg-prt-sum-with-tax-out / prt-tqnty
                        .
                    end.
                    if lookup( "TopAukc":U, p-mode ) = 0 then do:
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input substitute( "&1 &2", goods.artic, v-prt-name )
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty )
                        , input string( p-avg-prt-price-no-tax + v-avg-VAT-out )
                        , input string( v-avg-prt-sum-with-tax-out + prt-SLT-gds )
                    ).
                    end.
                end.
                else do:
                    if lookup( "TopAukc":U, p-mode ) = 0 then do:
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input substitute( "&1 &2", goods.artic, v-prt-name )
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty               )
                        , input string( price-noNDS + prt-VAT-gds )
                        , input string( prt-stoim + prt-SLT-gds )
                    ).
                    end.
                end.
            end.
        end.
end.
end procedure.
procedure print-header :
define input parameter p-trn-doc-code   as character        no-undo.
define variable v-print-doc                 as character                no-undo.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_clients           for clients .
    define buffer buf_temp_p-fmt_string-part    for temp_p-fmt_string-part.
do
for buf_trn-doc
  , buf_clients
  , buf_temp_p-fmt_string-part
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-code
    .
    run gbl/conf-rd.p ( "factur01", "", "", 0, "", "", "", no, output v-print-doc, output v-par-type ) no-error.
    if error-status :error
    then do:
        assign
            v-print-doc = "no"
        .
    end.
    assign
    p-sf-par = no
    .
    run torgconf-get-form-header in this-procedure (
          input Invers
        , input buf_trn-doc.doc-code
        , input ( v-print-doc = "yes" )
        , input buf_trn-doc.doc-date
        , input buf_trn-doc.fact-date
        , input buf_trn-doc.doc-type
        , input buf_trn-doc.status_
        , input p-reverse
        , input p-sf-par
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_docCode":U
        , input v-torgconf-doc-code
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_tbl_docCode":U
        , input v-torgconf-vdoc-code
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_docDate":U
        , input v-torgconf-doc-date
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_tbl_docDate":U
        , input v-torgconf-vdoc-date
    ).
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.obj-type
           and buf_clients.obj-code = buf_trn-doc.obj-code
    no-error.
    case buf_clients.obj-type :
        when 'маг':U
        then do:
            find first shop where shop.obj-code = buf_clients.obj-code no-lock .
            tdoc-prt = shop.doc-prt.
        end.
        when 'скл':U
        then do:
            find first store where store.obj-code = buf_clients.obj-code no-lock .
            tdoc-prt = store.doc-prt .
        end.
    end case.
    if not tdoc-prt or Invers = yes
    then do:
        assign
            PrintScale = no
        .
    end.
    find first pay-type no-lock
         where pay-type.obj-code = buf_trn-doc.pay-code
    no-error .
    run r-f_t1xl-write-cell-data in this-procedure (
        input "h_orgFrom":U
      , input v-torgconf-organization
    ).
    define var v-temp-phone as character.
    define var v-temp-addres as character.
    if  v-torgconf-organization matches "*" +   v-torgconf-self-host-phone   + "*"   and  v-torgconf-self-host-phone   <> ""  then  v-temp-phone =  v-torgconf-self-host-phone  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-host-phone  + "*"   and  v-torgconf-sup-host-phone  <> ""  then  v-temp-phone =  v-torgconf-sup-host-phone .
    else if  v-torgconf-organization matches "*" +   v-torgconf-self-obj-phone  + "*"   and  v-torgconf-self-obj-phone  <> ""  then  v-temp-phone =  v-torgconf-self-obj-phone .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-obj-phone   + "*"   and  v-torgconf-sup-obj-phone   <> ""  then  v-temp-phone =  v-torgconf-sup-obj-phone  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cli-phone   + "*"   and  v-torgconf-cli-phone   <> ""  then  v-temp-phone =  v-torgconf-cli-phone  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-ship-phone  + "*"   and  v-torgconf-ship-phone  <> ""  then  v-temp-phone =  v-torgconf-ship-phone .
    if  v-torgconf-organization matches "*" +   v-torgconf-self-host-addres  + "*"   and  v-torgconf-self-host-addres  <> ""  then  v-temp-addres =  v-torgconf-self-host-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-self-host-post-addres               + "*"   and  v-torgconf-self-host-post-addres               <> ""  then  v-temp-addres =  v-torgconf-self-host-post-addres              .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-host-addres   + "*"   and  v-torgconf-sup-host-addres   <> ""  then  v-temp-addres =  v-torgconf-sup-host-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-host-post-addres  + "*"   and  v-torgconf-sup-host-post-addres  <> ""  then  v-temp-addres =  v-torgconf-sup-host-post-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-temp-post-addres  + "*"   and  v-torgconf-temp-post-addres  <> ""  then  v-temp-addres =  v-torgconf-temp-post-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-self-obj-addres   + "*"   and  v-torgconf-self-obj-addres   <> ""  then  v-temp-addres =  v-torgconf-self-obj-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-obj-addres  + "*"   and  v-torgconf-sup-obj-addres  <> ""  then  v-temp-addres =  v-torgconf-sup-obj-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-self-bank-addres  + "*"   and  v-torgconf-self-bank-addres  <> ""  then  v-temp-addres =  v-torgconf-self-bank-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-bank-addres   + "*"   and  v-torgconf-sup-bank-addres   <> ""  then  v-temp-addres =  v-torgconf-sup-bank-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cli-addres  + "*"   and  v-torgconf-cli-addres  <> ""  then  v-temp-addres =  v-torgconf-cli-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cli-post-addres   + "*"   and  v-torgconf-cli-post-addres   <> ""  then  v-temp-addres =  v-torgconf-cli-post-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-ship-addres   + "*"   and  v-torgconf-ship-addres   <> ""  then  v-temp-addres =  v-torgconf-ship-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-ship-post-addres  + "*"   and  v-torgconf-ship-post-addres  <> ""  then  v-temp-addres =  v-torgconf-ship-post-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cli-bank-addres   + "*"   and  v-torgconf-cli-bank-addres   <> ""  then  v-temp-addres =  v-torgconf-cli-bank-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-ship-bank-addres  + "*"   and  v-torgconf-ship-bank-addres  <> ""  then  v-temp-addres =  v-torgconf-ship-bank-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cargo-to-addres   + "*"   and  v-torgconf-cargo-to-addres   <> ""  then  v-temp-addres =  v-torgconf-cargo-to-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cargo-from-addres   + "*"   and  v-torgconf-cargo-from-addres   <> ""  then  v-temp-addres =  v-torgconf-cargo-from-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-supplier-addr   + "*"   and  v-torgconf-supplier-addr   <> ""  then  v-temp-addres =  v-torgconf-supplier-addr  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-saler-addr  + "*"   and  v-torgconf-saler-addr  <> ""  then  v-temp-addres =  v-torgconf-saler-addr .
    else if  v-torgconf-organization matches "*" +   v-torgconf-consignee-addr  + "*"   and  v-torgconf-consignee-addr  <> ""  then  v-temp-addres =  v-torgconf-consignee-addr .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sf-buyer-addr   + "*"   and  v-torgconf-sf-buyer-addr   <> ""  then  v-temp-addres =  v-torgconf-sf-buyer-addr  .
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_addrFrom":U
        , input substitute( "&1&2&3",  v-temp-addres , ( if v-temp-phone   = "":U or v-temp-addres = "":U then "":U else ", " ), v-temp-phone)
    ).
     v-temp-addres = "".
     v-temp-phone  =  "".
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_OKPO_0":U
        , input v-torgconf-okpo
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input "h_cliFrom":U
        , input v-torgconf-client-from
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_cargoTo":U
        , input v-torgconf-torg12-cargo-label
    ).
    if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-host-phone   + "*"   and  v-torgconf-self-host-phone   <> ""  then  v-temp-phone =  v-torgconf-self-host-phone  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-host-phone  + "*"   and  v-torgconf-sup-host-phone  <> ""  then  v-temp-phone =  v-torgconf-sup-host-phone .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-obj-phone  + "*"   and  v-torgconf-self-obj-phone  <> ""  then  v-temp-phone =  v-torgconf-self-obj-phone .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-obj-phone   + "*"   and  v-torgconf-sup-obj-phone   <> ""  then  v-temp-phone =  v-torgconf-sup-obj-phone  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cli-phone   + "*"   and  v-torgconf-cli-phone   <> ""  then  v-temp-phone =  v-torgconf-cli-phone  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-ship-phone  + "*"   and  v-torgconf-ship-phone  <> ""  then  v-temp-phone =  v-torgconf-ship-phone .
    if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-host-addres  + "*"   and  v-torgconf-self-host-addres  <> ""  then  v-temp-addres =  v-torgconf-self-host-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-host-post-addres               + "*"   and  v-torgconf-self-host-post-addres               <> ""  then  v-temp-addres =  v-torgconf-self-host-post-addres              .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-host-addres   + "*"   and  v-torgconf-sup-host-addres   <> ""  then  v-temp-addres =  v-torgconf-sup-host-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-host-post-addres  + "*"   and  v-torgconf-sup-host-post-addres  <> ""  then  v-temp-addres =  v-torgconf-sup-host-post-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-temp-post-addres  + "*"   and  v-torgconf-temp-post-addres  <> ""  then  v-temp-addres =  v-torgconf-temp-post-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-obj-addres   + "*"   and  v-torgconf-self-obj-addres   <> ""  then  v-temp-addres =  v-torgconf-self-obj-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-obj-addres  + "*"   and  v-torgconf-sup-obj-addres  <> ""  then  v-temp-addres =  v-torgconf-sup-obj-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-bank-addres  + "*"   and  v-torgconf-self-bank-addres  <> ""  then  v-temp-addres =  v-torgconf-self-bank-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-bank-addres   + "*"   and  v-torgconf-sup-bank-addres   <> ""  then  v-temp-addres =  v-torgconf-sup-bank-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cli-addres  + "*"   and  v-torgconf-cli-addres  <> ""  then  v-temp-addres =  v-torgconf-cli-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cli-post-addres   + "*"   and  v-torgconf-cli-post-addres   <> ""  then  v-temp-addres =  v-torgconf-cli-post-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-ship-addres   + "*"   and  v-torgconf-ship-addres   <> ""  then  v-temp-addres =  v-torgconf-ship-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-ship-post-addres  + "*"   and  v-torgconf-ship-post-addres  <> ""  then  v-temp-addres =  v-torgconf-ship-post-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cli-bank-addres   + "*"   and  v-torgconf-cli-bank-addres   <> ""  then  v-temp-addres =  v-torgconf-cli-bank-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-ship-bank-addres  + "*"   and  v-torgconf-ship-bank-addres  <> ""  then  v-temp-addres =  v-torgconf-ship-bank-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cargo-to-addres   + "*"   and  v-torgconf-cargo-to-addres   <> ""  then  v-temp-addres =  v-torgconf-cargo-to-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cargo-from-addres   + "*"   and  v-torgconf-cargo-from-addres   <> ""  then  v-temp-addres =  v-torgconf-cargo-from-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-supplier-addr   + "*"   and  v-torgconf-supplier-addr   <> ""  then  v-temp-addres =  v-torgconf-supplier-addr  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-saler-addr  + "*"   and  v-torgconf-saler-addr  <> ""  then  v-temp-addres =  v-torgconf-saler-addr .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-consignee-addr  + "*"   and  v-torgconf-consignee-addr  <> ""  then  v-temp-addres =  v-torgconf-consignee-addr .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sf-buyer-addr   + "*"   and  v-torgconf-sf-buyer-addr   <> ""  then  v-temp-addres =  v-torgconf-sf-buyer-addr  .
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_addrTo":U
        , input substitute( "&1&2&3",  v-temp-addres , ( if v-temp-phone   = "":U or v-temp-addres = "":U then "":U else ", " ), v-temp-phone)
    ).
     v-temp-addres = "".
     v-temp-phone  =  "".
    if ( buf_trn-doc.doc-type = 'при':U
    or   buf_trn-doc.doc-type = 'возврат':U )
    and not invers
    and buf_trn-doc.ext-doc-type <> 're':U
    then do:
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_from_to_uderline"
        , input "(организация-грузополучатель, адрес, телефон, факс, банковские реквизиты)"
    ).
    end.
    ELSE DO:
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_from_to_uderline"
        , input "(организация-грузоотправитель, адрес, телефон, факс, банковские реквизиты)"
    ).
    end.
    if ( buf_trn-doc.doc-type = 'при':U
    or buf_trn-doc.doc-type = 'возврат':U )
    and buf_trn-doc.ext-doc-type <> 're':U
    and buf_trn-doc.ext-doc-type <> 'pz':U
    then do:
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_cargoToValue":U
        , input v-torgconf-torg12-cargo-value
    ).
    end.
    else do:
        run r-f_t1xl-write-cell-data in this-procedure (
          input "h_cargoToValue":U
        , input v-torgconf-torg12-cargo-value
        ).
    end.
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_OKPO":U
        , input v-torgconf-torg12-cargo-okpo
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_OKPO2":U
        , input v-torgconf-supplier-okpo
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_OKPO3":U
        , input v-torgconf-saler-okpo
    ).
    if v-torgconf-outrecv = yes
    then do:
        run p-fmt-split in this-procedure (
              input v-torgconf-suppi
            , input 150
        ).
        for each buf_temp_p-fmt_string-part
        :
        end.
    end.
    else do:
    end.
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_supplier":U
        , input v-torgconf-suppi
    ).
    define variable v-attr-value       as character            no-undo .
    define variable v-attr-type        as character            no-undo .
    define variable v-osnov            as character initial "" no-undo .
    define variable v-osnov-doc        as character initial "" no-undo .
    define variable v-osnov-1          as character initial "" no-undo .
    define variable v-osnov-attr       as character initial "" no-undo .
    define variable v-osnov-num        as character initial ?  no-undo .
    define variable v-osnov-num-doc    as character initial "" no-undo .
    define variable v-osnov-date       as character initial ?  no-undo .
    define variable v-osnov-date-doc   as character initial "" no-undo .
    define variable v-osnov-num-attr   as character initial "" no-undo .
    define variable v-osnov-date-attr  as character initial "" no-undo .
    define variable v-is-fin           as character            no-undo .
    define variable v-osnov-num-1      as character initial "" no-undo .
    define variable v-osnov-date-1     as character initial "" no-undo .
    define variable v-ind              as integer              no-undo .
    define variable v-ind2             as integer              no-undo .
    define buffer bf_doc-line     for ub.doc-line .
    define buffer bf_parts        for ub.parts .
    define buffer bf_trn-doc      for ub.trn-doc .
    define buffer bf_goods        for ub.goods .
    define buffer buf_contract    for ub.contract .
        define variable v-income-doc-code like parts.in-code no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'ndog':U ,
                       output v-osnov-num-attr ,
                       output v-attr-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'ddog':U ,
                       output v-osnov-date-attr ,
                       output v-attr-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'nosn':U ,
                       output v-osnov-attr ,
                       output v-attr-type ) no-error .
   if trim(v-osnov-num-attr)  = ""
   or trim(v-osnov-date-attr) = ""
   or trim(v-osnov-attr)      = ""
   then do:
    if buf_trn-doc.ext-doc-type = 'ie':U
    or buf_trn-doc.ext-doc-type = 'ee':U
    then do:
        FIND FIRST buf_contract
                  WHERE buf_contract.contract-code = buf_trn-doc.contract-code
                  NO-LOCK
                  NO-ERROR
                  .
            IF AVAILABLE  buf_contract
            THEN DO:
            ASSIGN
               v-osnov-num-doc   = buf_contract.contract-prn-code
               v-osnov-date-doc  = STRING(buf_contract.contract-date)
               v-osnov-doc       = buf_contract.contract-name
            .
            END.
    end.
    run gbl/conf-rd.p ( "is-fin"
                  , v-host-code
                  , buf_trn-doc.obj-type
                  , buf_trn-doc.obj-code
                  , ""
                  , ""
                  , ""
                  , no
                  , output v-is-fin
                  , output v-par-type
                  ) no-error .
    if error-status :error
    then  do:
       assign
             v-is-fin           = ""
       .
    end.
    IF v-is-fin = "yes"
    THEN DO:
      CASE buf_trn-doc.doc-type:
         WHEN 'при':U then  do:
            FIND FIRST buf_contract
                  WHERE buf_contract.contract-code = buf_trn-doc.contract-code
                  NO-LOCK
                  NO-ERROR
                  .
            IF AVAILABLE  buf_contract
            THEN DO:
            ASSIGN
               v-osnov-num   = buf_contract.contract-prn-code
               v-osnov-date  = STRING(buf_contract.contract-date)
               v-osnov       = buf_contract.contract-name
            .
            END.
         end.
         WHEN 'рас':U THEN DO:
         v-ind = 0.
            _single-reason:
            FOR EACH bf_doc-line
               WHERE bf_doc-line.doc-code = buf_trn-doc.doc-code
               NO-LOCK
               ,
               FIRST bf_goods
               WHERE bf_goods.artic      = bf_doc-line.artic
               and bf_goods.prod-type    = bf_doc-line.prod-type
               and bf_goods.prod-code    = bf_doc-line.prod-code
               NO-LOCK
               ,
               EACH bf_parts
               where bf_parts.obj-type   = bf_doc-line.obj-type
               and bf_parts.obj-code     = bf_doc-line.obj-code
               and bf_parts.artic        = bf_doc-line.artic
               and bf_parts.prod-type    = bf_doc-line.prod-type
               and bf_parts.prod-code    = bf_doc-line.prod-code
               and bf_parts.out-code     = bf_doc-line.doc-code
               NO-LOCK
               :
               assign
                  v-ind = v-ind + 1.
                  FIND FIRST buf_contract
                        WHERE buf_contract.contract-code = bf_parts.contract-code
                        NO-LOCK
                        NO-ERROR
                        .
                  IF AVAILABLE  buf_contract
                  THEN DO:
                  ASSIGN
                     v-osnov-num-1   = buf_contract.contract-prn-code
                     v-osnov-date    = STRING(buf_contract.contract-date)
                     v-osnov         = buf_contract.contract-name
                  .
                  END.
                  IF v-osnov-num = ?
                  and v-ind = 1
                  THEN DO:
                     ASSIGN
                        v-osnov-num = v-osnov-num-1
                     .
                  END.
                  IF v-osnov-num  <> v-osnov-num-1
                  THEN DO:
                     ASSIGN
                        v-osnov-num   = ?
                        v-osnov-date  = ?
                        v-osnov       = ""
                     .
                     LEAVE _single-reason.
                  END.
            END.
            IF v-osnov-num   = ?
            THEN
            _single-income-reason:
            FOR EACH bf_doc-line
               WHERE bf_doc-line.doc-code = buf_trn-doc.doc-code
               NO-LOCK
               ,
               FIRST bf_goods
               WHERE bf_goods.artic      = bf_doc-line.artic
               and bf_goods.prod-type    = bf_doc-line.prod-type
               and bf_goods.prod-code    = bf_doc-line.prod-code
               NO-LOCK
               ,
               EACH bf_parts
               where bf_parts.obj-type   = bf_doc-line.obj-type
               and bf_parts.obj-code     = bf_doc-line.obj-code
               and bf_parts.artic        = bf_doc-line.artic
               and bf_parts.prod-type    = bf_doc-line.prod-type
               and bf_parts.prod-code    = bf_doc-line.prod-code
               and bf_parts.out-code     = bf_doc-line.doc-code
               NO-LOCK
               :
                  FIND FIRST bf_trn-doc
                     WHERE bf_trn-doc.doc-code     = bf_parts.in-code
                     NO-LOCK
                     NO-ERROR
                     .
                  IF AVAILABLE bf_trn-doc THEN DO:
                     IF bf_trn-doc.ext-doc-type <> 'ie':U
                     THEN DO:
                        run find-income-doc-code ( input bf_parts.in-code
                                                   , input bf_goods.gds-code
                                                   , input bf_parts.part-code
                                                   , output v-income-doc-code
                                                   ) .
                        if v-income-doc-code <> ? then do:
                           find first bf_trn-doc
                                 no-lock
                                 where bf_trn-doc.doc-code = v-income-doc-code
                                 no-error
                                 .
                           IF NOT AVAILABLE bf_trn-doc
                           THEN DO:
                              ASSIGN
                                 v-osnov-num   = ?
                                 v-osnov-date  = ?
                                 v-osnov       = ""
                              .
                              LEAVE _single-income-reason.
                           END.
                        END.
                     END.
                  END.
                  ELSE DO:
                     ASSIGN
                        v-osnov-num   = ?
                        v-osnov-date  = ?
                        v-osnov       = ""
                     .
                     LEAVE _single-income-reason.
                  END.
                  run gbl/trdcat-v.p  ( input  bf_trn-doc.doc-code
                                    , input  'ndog':U
                                    , output v-osnov-num-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov-num = ?
                  THEN DO:
                     ASSIGN
                        v-osnov-num = v-osnov-num-1
                     .
                  END.
                  run gbl/trdcat-v.p  ( input bf_trn-doc.doc-code
                                    , input 'ddog':U
                                    , output v-osnov-date-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov-date = ?
                  THEN DO:
                     ASSIGN
                        v-osnov-date = v-osnov-date-1
                     .
                  END.
                  IF v-osnov-num  <> v-osnov-num-1
                  OR v-osnov-date <> v-osnov-date-1
                  THEN DO:
                     ASSIGN
                        v-osnov-num   = ?
                        v-osnov-date  = ?
                        v-osnov       = ""
                     .
                     LEAVE _single-income-reason.
                  END.
            END.
         END.
         OTHERWISE DO:
         END.
      END case.
    END.
    ELSE DO:
      CASE buf_trn-doc.doc-type:
         WHEN 'рас':U THEN DO:
         v-ind2 = 0.
            _single-reason:
            FOR EACH bf_doc-line
               WHERE bf_doc-line.doc-code = buf_trn-doc.doc-code
               NO-LOCK
               ,
               FIRST bf_goods
               WHERE bf_goods.artic      = bf_doc-line.artic
               and bf_goods.prod-type    = bf_doc-line.prod-type
               and bf_goods.prod-code    = bf_doc-line.prod-code
               NO-LOCK
               ,
               EACH bf_parts
               where bf_parts.obj-type   = bf_doc-line.obj-type
               and bf_parts.obj-code     = bf_doc-line.obj-code
               and bf_parts.artic        = bf_doc-line.artic
               and bf_parts.prod-type    = bf_doc-line.prod-type
               and bf_parts.prod-code    = bf_doc-line.prod-code
               and bf_parts.out-code     = bf_doc-line.doc-code
               NO-LOCK
               :
               assign
               v-ind2 = v-ind2 + 1.
                  FIND FIRST bf_trn-doc
                     WHERE bf_trn-doc.doc-code   = bf_parts.in-code
                     NO-LOCK
                     NO-ERROR
                     .
                  IF AVAILABLE bf_trn-doc THEN DO:
                     IF bf_trn-doc.ext-doc-type <> 'ie':U
                     THEN DO:
                        run find-income-doc-code ( input bf_parts.in-code
                                                   , input bf_goods.gds-code
                                                   , input bf_parts.part-code
                                                   , output v-income-doc-code
                                                   ) .
                        if v-income-doc-code <> ? then do:
                           find first bf_trn-doc
                                 no-lock
                                 where bf_trn-doc.doc-code = v-income-doc-code
                                 no-error
                                 .
                           IF NOT AVAILABLE bf_trn-doc
                           THEN DO:
                              ASSIGN
                                 v-osnov-num   = ?
                                 v-osnov-date  = ?
                                 v-osnov       = ""
                              .
                              LEAVE _single-reason.
                           END.
                        END.
                     END.
                  END.
                  ELSE DO:
                  ASSIGN
                     v-osnov-num   = ?
                     v-osnov-date  = ?
                     v-osnov       = ""
                  .
                  LEAVE _single-reason.
                  END.
                  run gbl/trdcat-v.p  ( input  bf_trn-doc.doc-code
                                    , input  'ndog':U
                                    , output v-osnov-num-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov-num = ?
                  and v-ind2 = 1
                  THEN DO:
                     ASSIGN
                        v-osnov-num = v-osnov-num-1
                     .
                  END.
                  run gbl/trdcat-v.p  ( input bf_trn-doc.doc-code
                                    , input 'ddog':U
                                    , output v-osnov-date-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov-date = "":U
                  and v-ind2 = 1
                  THEN DO:
                     ASSIGN
                        v-osnov-date = v-osnov-date-1
                     .
                  END.
                  run gbl/trdcat-v.p  ( input  bf_trn-doc.doc-code
                                    , input  'nosn':U
                                    , output v-osnov-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov = "":U
                  and v-ind2 = 1
                  THEN DO:
                     ASSIGN
                        v-osnov = v-osnov-1
                     .
                  END.
                  IF v-osnov-num  <> v-osnov-num-1
                  OR v-osnov-date <> v-osnov-date-1
                  or v-osnov      <> v-osnov-1
                  THEN DO:
                     ASSIGN
                        v-osnov-num   = ?
                        v-osnov-date  = ?
                        v-osnov       = ""
                     .
                     LEAVE _single-reason.
                  END.
            END.
         END.
         OTHERWISE DO:
         END.
      END CASE.
    END.
    end.
    if buf_trn-doc.ext-doc-type = 'ie':U
    or buf_trn-doc.ext-doc-type = 'ee':U
    then do:
        assign
         v-osnov-num  = v-osnov-num-doc
         v-osnov-date = v-osnov-date-doc
         v-osnov      = v-osnov-doc
        .
    end.
    if trim(v-osnov-num-attr)  <> ""
    then do:
        v-osnov-num = v-osnov-num-attr.
    end.
    if trim(v-osnov-date-attr)  <> ""
    then do:
        v-osnov-date = v-osnov-date-attr.
    end.
    if trim(v-osnov-attr)  <> ""
    then do:
        v-osnov = v-osnov-attr.
    end.
    IF v-osnov-date  = ?
    THEN DO:
      ASSIGN
         v-osnov-date  = ""
      .
    END.
    IF v-osnov-num   = ?
    THEN DO:
      ASSIGN
         v-osnov-num   = ""
         v-osnov-date  = ""
         v-osnov       = ""
      .
    END.
    run r-f_t1xl-write-cell-data in this-procedure (
        input "h_saler":U
        , input SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                          , v-torgconf-saler
                                                          , v-torgconf-saler-inn
                                                          , v-torgconf-saler-kpp
                                                          )
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input "h_saler1":U
        , input SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                          , v-torgconf-saler
                                                          , v-torgconf-saler-inn
                                                          , v-torgconf-saler-kpp
                                                          )
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_osn_doc_code"
        , input v-osnov-num
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_osn_doc_date"
        , input v-osnov-date
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input "h_reason":U
        , input v-osnov
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input "h_reason_num":U
        , input v-osnov-num
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input "h_reason_date":U
        , input v-osnov-date
    ).
    define variable v-operation-type    as character    no-undo.
    assign
        v-operation-type = ( if v-ext-doc-type = 'ep':U
                             then ( if lookup( "MARI":U, p-mode ) = 0
                                    then "возврат пост-ку"
                                    else "":U )
                             else ( if buf_trn-doc.doc-type = 'при':U and not Invers
                                    then " приход"
                                    else ( if buf_trn-doc.doc-type = 'возврат':U
                                           then ( if lookup( "MARI":U, p-mode ) = 0
                                                  then " возврат"
                                                  else "":U )
                                           else " расход" ) )
                           )
    .
    run r-f_t1xl-write-cell-data in this-procedure (
          input "h_operationType":U
        , input v-operation-type
    ).
end.
end procedure.
procedure print-line-sj :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-sj-b-code      as integer          no-undo.
    define variable v-price-is-changed      as logical  no-undo.
    define variable v-sum-prt-qnty                  as decimal      no-undo.
    define variable v-avg-prt-price                 as decimal      no-undo.
    define variable v-avg-prt-price-no-tax          as decimal      no-undo.
    define variable v-sum-SLT                       as decimal      no-undo.
    define variable v-sum-VAT                       as decimal      no-undo.
    define variable v-avg-VAT                       as decimal      no-undo.
    define variable v-avg-VAT-out                   as decimal      no-undo.
    define variable v-sum-prt-sum-with-tax          as decimal      no-undo.
    define variable v-avg-prt-sum-with-tax          as decimal      no-undo.
    define variable v-avg-prt-sum-with-tax-out      as decimal      no-undo.
    define variable v-sum-prt-sum-without-tax       as decimal      no-undo.
    define variable v-avg-prt-sum-without-tax       as decimal      no-undo.
    define variable v-avg-prt-sum-without-tax-out   as decimal      no-undo.
    define variable v-vat-pc                        as decimal      no-undo.
    define variable v-slt-pc                        as decimal      no-undo.
    define variable v-void-decimal                  as decimal      no-undo.
    define variable v-gds-name                      as character    no-undo.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_sj-t12        for sj-t12.
    define buffer buf_tax_parts     for parts.
    define buffer buf_temp_gds-name for temp_gds-name.
do
for buf_trn-doc
  , buf_sj-t12
  , buf_tax_parts
  , buf_temp_gds-name
on error undo, return error
:
    empty temp-table buf_temp_gds-name.
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    find first buf_sj-t12
         where buf_sj-t12.b-code = p-sj-b-code
    .
    run writelog in this-procedure (log-file-name, 1, "Печать строки товара по чекам").
    assign
        v-torg-12-gds-name-key  = 0
        v-gds-name              = goods.gds-name
    .
    if FullGdsName
    and v-gds-name <> "":U
    then do:
        do
        while v-gds-name <> "":U
        :
            assign
                v-torg-12-gds-name-key = v-torg-12-gds-name-key + 1
            .
            create buf_temp_gds-name.
            assign
                buf_temp_gds-name.gdn-key = v-torg-12-gds-name-key
            .
            run p-fmt-split-string in this-procedure (
                  input v-gds-name
                , input v-torg-12-gds-name-length
                , output buf_temp_gds-name.gdnString
                , output v-gds-name
            ).
        end.
        assign
            v-gds-name    = goods.gds-name
        .
    end.
    else do:
        assign
            v-torg-12-gds-name-key = v-torg-12-gds-name-key + 1
        .
        create buf_temp_gds-name.
        assign
            buf_temp_gds-name.gdn-key   = v-torg-12-gds-name-key
            buf_temp_gds-name.gdnString = v-gds-name
        .
    end.
    run writelog in this-procedure( log-file-name, 2, substitute( "Товар: &1 &2 ", goods.artic, goods.gds-name ) ).
    find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
    assign
        v-rootnode-code = gds-prt.node-code
    .
    if ( ( gds-prt.node-name <> '_Пустая шкала':U )
        and v-cntxp-doc-prt = yes )
    and ( not Invers )
    then do:
        run writelog in this-procedure (log-file-name, 2, "Не пустая шкала, не отключена печать по шкалам и накладная не от имени поставщика").
        find first gds-dtl no-lock
             where gds-dtl.prod-type = buf_sj-t12.prod-type
               and gds-dtl.prod-code = buf_sj-t12.prod-code
               and gds-dtl.artic     = buf_sj-t12.artic
               and gds-dtl.doc-code  = p-doc-code
        no-error.
        if not available gds-dtl
        then do:
            assign
                price-noNDS   = 0
                price-withNDS = 0
            .
        end.
        if PrintScale
        then do:
            if lookup( "TopAukc":U, p-mode ) = 0 then do:
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
            end.
            assign
                v-line-counter = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        end.
        for each gds-dtl no-lock
           where gds-dtl.prod-type  = buf_sj-t12.prod-type
             and gds-dtl.prod-code  = buf_sj-t12.prod-code
             and gds-dtl.artic      = buf_sj-t12.artic
             and gds-dtl.doc-code   = p-doc-code
        :
            find first gds-prt no-lock
                 where gds-prt.node-code = gds-dtl.prt-code
            .
            assign
                v-sum-prt-qnty  = v-sum-prt-qnty + buf_sj-t12.fact-qnty
                VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer            else buf_sj-t12.vat-base-buyer           )
                SLT-gds         = ( if PrintRubl then buf_sj-t12.slt-rubl-sale             else buf_sj-t12.slt-base-sale            )
                price-withNDS   = ( if PrintRubl then buf_sj-t12.price-rubl-with-tax-sale  else buf_sj-t12.price-base-with-tax-sale )
            .
            run writelog in this-procedure (log-file-name, 1, substitute( "Цена НДС: &1 ", v-sum-VAT ) ).
            if VAT-gds = ?       then assign  VAT-gds       = 0.
            if SLT-gds = ?       then assign  SLT-gds       = 0.
            if price-withNDS = ? then assign  price-withNDS = 0.
            assign
                v-sum-VAT                 = v-sum-VAT                   + VAT-gds * buf_sj-t12.fact-qnty
                v-sum-prt-sum-with-tax    = v-sum-prt-sum-with-tax      + ( price-withNDS * buf_sj-t12.fact-qnty )
                v-sum-prt-sum-without-tax = v-sum-prt-sum-without-tax   + ( ( price-withNDS - VAT-gds - SLT-gds )
                                                                            * buf_sj-t12.fact-qnty )
            .
            run writelog in this-procedure (log-file-name, 1, substitute( "Сумма НДС: &1 ", v-sum-VAT ) ).
        end.
        assign
            v-avg-VAT                   = ( if v-sum-VAT = ? or v-sum-VAT = 0
                                          then 0
                                          else v-sum-VAT / v-sum-prt-qnty )
            v-avg-prt-price             = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                          then 0
                                          else v-sum-prt-sum-with-tax / v-sum-prt-qnty )
            v-avg-prt-price-no-tax      = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                          then 0
                                          else v-sum-prt-sum-without-tax / v-sum-prt-qnty )
            v-avg-prt-sum-with-tax      = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                          then 0
                                          else v-sum-prt-sum-with-tax / v-sum-prt-qnty )
            v-avg-prt-sum-without-tax   = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                          then 0
                                          else v-sum-prt-sum-without-tax / v-sum-prt-qnty )
        .
        for each gds-dtl no-lock
           where gds-dtl.prod-type  = buf_sj-t12.prod-type
             and gds-dtl.prod-code  = buf_sj-t12.prod-code
             and gds-dtl.artic      = buf_sj-t12.artic
             and gds-dtl.doc-code   = p-doc-code
        :
            find first gds-prt no-lock
                 where gds-prt.node-code = gds-dtl.prt-code
            .
            if buf_trn-doc.doc-type = 'при':U
            or v-ext-doc-type = 'ep':U
            then do:
                assign
                    VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-sale              else buf_sj-t12.vat-base-sale               )
                .
            end.
            else do:
                assign
                    VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer             else buf_sj-t12.vat-base-buyer              )
                .
            end.
            assign
                VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer             else buf_sj-t12.vat-base-buyer              )
                SLT-gds         = ( if PrintRubl then buf_sj-t12.slt-rubl-sale              else buf_sj-t12.slt-base-sale               )
                price-withNDS   = ( if PrintRubl then buf_sj-t12.price-rubl-with-tax-sale   else buf_sj-t12.price-base-with-tax-sale    )
            .
            if VAT-gds = ? then VAT-gds = 0.
            if SLT-gds = ? then SLT-gds = 0.
            assign
                price-noNDS     = price-withNDS - VAT-gds - SLT-gds
                prt-tqnty       = buf_sj-t12.fact-qnty
                prt-VAT-gds     = VAT-gds           * prt-tqnty
                prt-SLT-gds     = SLT-gds           * prt-tqnty
                prt-stoim-noNDS = price-noNDS       * prt-tqnty
                prt-stoim       = prt-stoim-noNDS   + prt-VAT-gds
            .
            if p-round = "round":U
            then do:
                run p-fmt-round in this-procedure (
                      input prt-tqnty
                    , input price-noNDS
                    , input VAT-gds
                    , input SLT-gds
                    , input 0
                    , output price-noNDS
                    , output v-vat-pc
                    , output v-slt-pc
                    , output prt-VAT-gds
                    , output prt-SLT-gds
                    , output v-void-decimal
                    , output prt-stoim-noNDS
                    , output prt-stoim
                ).
                assign
                    prt-stoim  = prt-stoim - prt-SLT-gds
                .
            end.
            accumulate
                prt-tqnty ( TOTAL )
                prt-VAT-gds ( TOTAL )
                prt-SLT-gds ( TOTAL )
                prt-stoim-noNDS ( TOTAL )
                prt-stoim ( TOTAL )
            .
            if PrintScale
            then do:
                find first bar-code no-lock
                     where bar-code.gds-code = goods.gds-code
                       and bar-code.unit-cli = goods.unit-base
                       and bar-code.node-code = gds-dtl.prt-code
                       and bar-code.part-code = ""
                       and bar-code.in-code = ""
                .
                assign
                 v-ext-artic = ""
                .
                find first ub.ext-artic no-lock
                     where ub.ext-artic.gds-code = bar-code.gds-code
                       and ub.ext-artic.cli-code = v-cli-code
                       and ub.ext-artic.cli-type = v-cli-type
                       and ub.ext-artic.status_  = 'тек':U no-error.
                if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
                v-prt-name = "".
                do while available gds-prt:
                    if available gds-prt
                    then assign
                        v-prt-name = "\" + string( gds-prt.node-name, "x(10)" ) + v-prt-name
                    .
                    assign
                        v-node-code = gds-prt.upper-code
                    .
                    find first gds-prt no-lock
                         where gds-prt.node-code = v-node-code
                           and gds-prt.root <> yes
                    no-error.
                end.
                if buf_trn-doc.doc-type = 'при':U
                or v-ext-doc-type = 'ep':U
                then do:
                    assign
                        v-avg-prt-price             = price-withNDS
                        v-avg-prt-price-no-tax      = price-noNDS
                        v-avg-VAT                   = prt-VAT-gds
                        v-avg-prt-sum-with-tax      = prt-stoim
                        v-avg-prt-sum-without-tax   = prt-stoim-noNDS
                    .
                end.
                else do:
                    assign
                        v-avg-VAT-out                 = v-avg-VAT                  * buf_sj-t12.fact-qnty
                        v-avg-prt-sum-with-tax-out    = v-avg-prt-sum-with-tax     * buf_sj-t12.fact-qnty
                        v-avg-prt-sum-without-tax-out = v-avg-prt-sum-without-tax  * buf_sj-t12.fact-qnty
                    .
                end.
                if v-ext-doc-type = 'ep':U
                then do:
                    if lookup( "TopAukc":U, p-mode ) = 0 then do:
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input substitute( "&1 &2", goods.artic, v-prt-name )
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty )
                        , input string( v-avg-prt-price-no-tax + v-avg-VAT-out )
                        , input string( v-avg-prt-sum-with-tax-out + prt-SLT-gds )
                    ).
                    end.
                end.
                else do:
                    if lookup( "TopAukc":U, p-mode ) = 0 then do:
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input substitute( "&1 &2", goods.artic, v-prt-name )
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty               )
                        , input string( price-noNDS + prt-VAT-gds )
                        , input string( prt-stoim + prt-SLT-gds )
                    ).
                    end.
                end.
            end.
        end.
        assign
            tqnty = ( ACCUM TOTAL prt-tqnty )
            VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
            SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
            stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
            stoim = ( ACCUM TOTAL prt-stoim )
        .
        if not PrintScale
        then do:
            find first bar-code no-lock
                 where bar-code.gds-code = goods.gds-code
                   and bar-code.unit-cli = goods.unit-base
                   and bar-code.node-code = v-rootnode-code
                   and bar-code.part-code = ""
                   and bar-code.in-code = ""
            .
            assign
             v-ext-artic = ""
            .
            find first ub.ext-artic no-lock
                 where ub.ext-artic.gds-code = bar-code.gds-code
                   and ub.ext-artic.cli-code = v-cli-code
                   and ub.ext-artic.cli-type = v-cli-type
                   and ub.ext-artic.status_  = 'тек':U no-error.
            if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
            if lookup( "TopAukc":U, p-mode ) = 0 then do:
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input goods.unit-base
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( stoim-noNDS / tqnty + VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            end.
            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        end.
    end.
    else do:
        run writelog in this-procedure (log-file-name, 2, "Пустая шкала или отключена печать по шкалам или накладная от имени поставщика").
        find first bar-code no-lock
            where bar-code.gds-code = goods.gds-code
            and bar-code.unit-cli   = goods.unit-base
            and bar-code.node-code  = v-rootnode-code
            and bar-code.part-code  = ""
            and bar-code.in-code    = ""
        .
        assign
         v-ext-artic = ""
        .
        find first ub.ext-artic no-lock
             where ub.ext-artic.gds-code = bar-code.gds-code
               and ub.ext-artic.cli-code = v-cli-code
               and ub.ext-artic.cli-type = v-cli-type
               and ub.ext-artic.status_  = 'тек':U no-error.
        if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
        if v-ext-doc-type = 'ep':U
        and PrintScale = no
        then do:
            run writelog in this-procedure (log-file-name, 3, "Возврат поставщику при печати по партиям "
                                                ).
            find first gds-dtl no-lock
                 where gds-dtl.doc-code    = p-doc-code
                   and gds-dtl.artic       = buf_sj-t12.artic
                   and gds-dtl.prod-code   = buf_sj-t12.prod-code
                   and gds-dtl.prod-type   = buf_sj-t12.prod-type
                   and gds-dtl.prt-code    = v-rootnode-code
            no-error.
            if available gds-dtl
            and doc-line.price-rubl - doc-line.transport-rubl - doc-line.other-rubl <> gds-dtl.price-rubl
            then do:
                assign
                    v-price-is-changed  =  yes
                .
                assign
                    v-VAT-gds           = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer             else buf_sj-t12.vat-base-buyer              )
                    v-SLT-gds           = ( if PrintRubl then buf_sj-t12.slt-rubl-sale              else buf_sj-t12.slt-base-sale               )
                    v-price-withNDS     = ( if PrintRubl then buf_sj-t12.price-rubl-with-tax-sale   else buf_sj-t12.price-base-with-tax-sale    )
                .
                run writelog in this-procedure (log-file-name, 4, "В возврате поставщику изменяли цену ( с НДС -     "
                                                                         + dtm-char(string(v-price-withNDS)) + " )"
                                                    ).
            end.
            else do:
                assign
                    v-price-is-changed  =  no
                .
            end.
            if v-price-is-changed  =  no
            or CostPrice = yes
            then do:
                assign
                    v-VAT-gds       = ( if PrintRubl then buf_sj-t12.vat-rubl-sale       else buf_sj-t12.vat-base-sale        )
                    v-SLT-gds       = ( if PrintRubl then buf_sj-t12.slt-rubl-sale       else buf_sj-t12.slt-base-sale        )
                    v-tax-price     = ( if PrintRubl then buf_sj-t12.road-tax-rubl-sale  else buf_sj-t12.road-tax-base-sale   )
                    v-price-withNDS = ( if PrintRubl
                        then buf_sj-t12.price-rubl-with-tax-sale - v-tax-price
                        else buf_sj-t12.price-base-with-tax-sale - v-tax-price
                                        )
                    v-tax           = v-tax-price * buf_sj-t12.fact-qnty
                    v-tax-sum       = v-tax-sum + v-tax
                .
            end.
            if VAT-gds = ? then VAT-gds = 0.
            if SLT-gds = ? then SLT-gds = 0.
            assign
                tqnty           = buf_sj-t12.fact-qnty
                unit-str        = goods.unit-base
                price-noNDS     = v-price-withNDS - v-VAT-gds - v-SLT-gds
                VAT-gds         = v-VAT-gds * tqnty
                SLT-gds         = v-SLT-gds * tqnty
                stoim-noNDS     = price-noNDS * tqnty
                stoim           = stoim-noNDS + VAT-gds
                price-withNDS   = v-price-withNDS
            .
            run writelog in this-procedure (log-file-name, 5, "Партия: Кол-во ( " + dtm-char ( string(tqnty) )
                                                        + " ) c НДС ( " + dtm-char( string(price-withNDS)) + " )"
                                                ).
            if lookup( "TopAukc":U, p-mode ) = 0 then do:
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input unit-str
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( price-noNDS + VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            end.
            assign
                prt-tqnty =  tqnty
                prt-VAT-gds = VAT-gds
                prt-SLT-gds = SLT-gds
                prt-stoim-noNDS = price-noNDS * prt-tqnty
                prt-stoim = prt-stoim-noNDS + prt-VAT-gds
            .
            if hvrdtax (recid(goods))
            then do:
                run tax-name (  input 'rdt':U
                            , output v-tax-name
                            ).
                run writelog in this-procedure (log-file-name, 4, "Есть третий налог ( " + dtm-char( v-tax-name )
                                                        + " ) сумма ( " + dtm-char( string( v-tax ) ) + " )"
                                                    ).
                if lookup( "TopAukc":U, p-mode ) = 0 then do:
                run r-f_t1xl-sheet1-write-line-data in this-procedure (
                      input 0
                    , input v-tax-name
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input string( tqnty )
                    , input string( v-tax-price )
                    , input string( v-tax )
                ).
                end.
                assign
                    price-withNDS   = v-price-withNDS + v-tax-price
                    price-noNDS     = price-withNDS - v-VAT-gds - v-SLT-gds
                    prt-stoim-noNDS = price-noNDS * tqnty
                    prt-stoim       = prt-stoim-noNDS + VAT-gds
                    v-line-counter  = v-line-counter + 1
                .
                run writelog in this-procedure (log-file-name, 4, "Еще раз вычислили сумму с НДС ( "
                                                        + dtm-char( string(prt-stoim) )
                                                        + " ) для общего итога"
                                                    ).
            end.
            accumulate
                prt-tqnty ( TOTAL )
                prt-VAT-gds ( TOTAL )
                prt-SLT-gds ( TOTAL )
                prt-stoim-noNDS ( TOTAL )
                prt-stoim ( TOTAL )
            .
            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
            assign
                tqnty = ( ACCUM TOTAL prt-tqnty )
                VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
                SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
                stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
                stoim = ( ACCUM TOTAL prt-stoim )
            .
            run writelog in this-procedure (log-file-name, 3,
                                                            "После цикла по партиям: Установили количество ( "
                                                            + dtm-char( string(tqnty) )
                                                            + " ) и сумму ( "
                                                            + dtm-char( string( stoim ) )
                                                            + " ) для общего итога "
                                                ).
        end.
        else do:
            find first gds-dtl no-lock
                 where gds-dtl.doc-code    = p-doc-code
                   and gds-dtl.prod-type   = buf_sj-t12.prod-type
                   and gds-dtl.prod-code   = buf_sj-t12.prod-code
                   and gds-dtl.artic       = buf_sj-t12.artic
                   and gds-dtl.prt-code    = v-rootnode-code
            no-error.
            if available gds-dtl
            then do:
                assign
                    tqnty    = buf_sj-t12.fact-qnty
                .
            end.
            else do:
                assign
                    tqnty    = buf_sj-t12.fact-qnty
                .
            end.
            assign
                unit-str = goods.unit-base
            .
            if buf_trn-doc.doc-type = 'при':U
            or v-ext-doc-type = 'ep':U
            then do:
                assign
                    VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-sale       else buf_sj-t12.vat-base-sale        )
                    SLT-gds         = ( if PrintRubl then buf_sj-t12.slt-rubl-sale       else buf_sj-t12.slt-base-sale        )
                    v-tax-price     = ( if PrintRubl then buf_sj-t12.road-tax-rubl-sale  else buf_sj-t12.road-tax-base-sale   )
                    price-withNDS   = ( if PrintRubl
                                        then buf_sj-t12.price-rubl-with-tax-sale - v-tax-price
                                        else buf_sj-t12.price-base-with-tax-sale - v-tax-price
                                        )
                    v-tax           = v-tax-price * tqnty
                    v-tax-sum       = v-tax-sum + v-tax
                .
            end.
            else do:
                assign
                    VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer     else buf_sj-t12.vat-base-buyer      )
                    SLT-gds         = ( if PrintRubl then buf_sj-t12.slt-rubl-sale      else buf_sj-t12.slt-base-sale       )
                    v-tax-price     = ( if PrintRubl then buf_sj-t12.road-tax-rubl-sale else buf_sj-t12.road-tax-base-sale  )
                    price-withNDS   = ( if PrintRubl
                                        then buf_sj-t12.price-rubl-with-tax-sale - v-tax-price
                                        else buf_sj-t12.price-base-with-tax-sale - v-tax-price
                                        )
                    v-tax           = v-tax-price * tqnty
                    v-tax-sum       = v-tax-sum + v-tax
                .
            end.
            if VAT-gds = ? then assign VAT-gds = 0.
            if SLT-gds = ? then assign SLT-gds = 0.
            assign
                price-noNDS = price-withNDS - VAT-gds - SLT-gds
                VAT-gds     = VAT-gds * tqnty
                SLT-gds     = SLT-gds * tqnty
                stoim-noNDS = price-noNDS * tqnty
                stoim       = stoim-noNDS + VAT-gds
            .
            run writelog in this-procedure (log-file-name, 3, "Печать не по партиям. Стоимость с НДС ( "
                                                                        + dtm-char( string( stoim ) )
                                                                        + " ). Количество ( "
                                                                        + dtm-char( string( tqnty ) )
                                                                        + " ). Третий налог ( "
                                                                        + dtm-char( string( v-tax ) )
                                                                        + " )"
                                                ).
            if lookup( "TopAukc":U, p-mode ) = 0 then do:
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input unit-str
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( price-noNDS + VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            end.
            if hvrdtax (recid(goods))
            then do:
                run tax-name (  input 'rdt':U
                             , output v-tax-name
                             ).
                run writelog in this-procedure (log-file-name, 4, "Есть третий налог ( " + dtm-char( v-tax-name )
                                                        + " ) сумма ( " + dtm-char( string( v-tax ) ) + " )"
                                                    ).
                parts-for-tax:
                for each buf_tax_parts
                   where buf_tax_parts.obj-type     = doc-line.obj-type
                     and buf_tax_parts.obj-code     = doc-line.obj-code
                     and buf_tax_parts.artic        = goods.artic
                     and buf_tax_parts.prod-type    = goods.prod-type
                     and buf_tax_parts.prod-code    = goods.prod-code
                     and buf_tax_parts.out-code     = doc-line.doc-code
                break by buf_tax_parts.road-tax-base
                :
                    if first-of (buf_tax_parts.road-tax-base)
                    then do:
                        assign
                            v-parts-tax-qnty    = 0
                            v-tax               = 0
                            v-tax-parts-price   =  ( if PrintRubl
                                                    then buf_tax_parts.road-tax-rubl
                                                    else buf_tax_parts.road-tax-base )
                        .
                    end.
                    assign
                        v-parts-tax-qnty    = v-parts-tax-qnty + buf_tax_parts.fact-qnty
                        v-tax               = v-tax + ( v-tax-parts-price * buf_tax_parts.fact-qnty )
                    .
                    if not last-of (buf_tax_parts.road-tax-base)
                    then do:
                        next parts-for-tax.
                    end.
                    if lookup( "TopAukc":U, p-mode ) = 0 then do:
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input v-tax-name
                        , input "":U
                        , input "":U
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( v-parts-tax-qnty  )
                        , input string( v-tax-parts-price )
                        , input string( v-tax )
                    ).
                    end.
                end.
                assign
                    v-tax           = v-tax-price * tqnty
                    price-noNDS     = price-noNDS + v-tax-price
                    stoim-noNDS     = price-noNDS * tqnty
                    stoim           = stoim-noNDS + VAT-gds
                    v-line-counter  = v-line-counter + 1
                .
                run writelog in this-procedure (log-file-name, 4,
                                        "Снова вычислили суммы для строки. Сумма с НДС ( "
                                        + dtm-char( string( stoim ) )
                                        + " )"
                                                    ).
            end.
            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        end.
    end.
end.
end procedure.
procedure trdcattr-value :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-attr-code      as character        no-undo.
define output parameter p-attr-value    as character        no-undo.
define output parameter p-attr-type     as character        no-undo.
do
on error undo, return error
:
    run gbl/trdcat-v.p (
          input p-doc-code
        , input p-attr-code
        , output p-attr-value
        , output p-attr-type
    ).
end.
end procedure.
procedure disc-mpl :
define input  parameter p-doc-code        as character      no-undo .
define output parameter v-price-sale-all  as decimal        no-undo .
define variable p-main-b-code             as integer        no-undo .
define variable v-fact-order              as decimal        no-undo .
define variable v-doc-num     like ub.price-list.doc-num    no-undo .
define variable v-price-sale  like ub.price-list.price-sale no-undo .
define variable v-road-tax    like ub.price-list.road-tax   no-undo .
define variable v-excise      like ub.price-list.excise     no-undo .
define buffer buf_trn-doc     for ub.trn-doc.
define buffer buf_doc-line    for ub.doc-line.
define buffer buf_goods       for ub.goods.
define buffer buf_price-doc   for ub.price-doc.
do
on error undo, return error
:
find first buf_trn-doc
     where buf_trn-doc.doc-code = p-doc-code
  no-error.
  if available buf_trn-doc then do:
    for each buf_doc-line
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
       no-lock :
         find first buf_goods
              where buf_goods.artic     = buf_doc-line.artic
                and buf_goods.prod-type = buf_doc-line.prod-type
                and buf_goods.prod-code = buf_doc-line.prod-code
            no-error.
            if available buf_goods then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output p-main-b-code
  )  .
              assign v-fact-order = (if buf_trn-doc.fact-order <> ? then buf_trn-doc.fact-order else 0) .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  p-main-b-code
  ,input  0
  ,input  v-fact-order
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
              if v-doc-num <> ? then do:
                find first buf_price-doc
                where buf_price-doc.doc-num = v-doc-num no-error.
                if available buf_price-doc then do:
                  if not printRubl then do :
                      assign v-price-sale = v-price-sale / buf_price-doc.base-rate .
                  end.
                end.
                else do:
                    assign v-price-sale = 0.
                end.
              end.
              else do:
                  assign v-price-sale = 0.
              end.
              assign v-price-sale-all = v-price-sale-all + v-price-sale * buf_doc-line.fact-qnty.
           end.
    end.
  end.
end.
end procedure.
procedure get-okei :
define input parameter p-unit-base as character        no-undo.
define output parameter p-okei as character        no-undo.
    define buffer buf_units         for units.
do
for buf_units
on error undo, return error
:
    find first buf_units no-lock
         where buf_units.unit-name = p-unit-base
    no-error.
    if available buf_units
    and buf_units.OKEI <> 0
    then do:
        assign
            p-okei = string( buf_units.OKEI, ">999":U )
        .
    end.
    else do:
        assign
            p-okei = "":U
        .
    end.
end.
end procedure.
PROCEDURE find-income-doc-code :
define input  parameter p-in-code         like parts.in-code    no-undo .
define input  parameter p-gds-code        like goods.gds-code   no-undo .
define input  parameter p-part-code       like parts.part-code  no-undo .
define output parameter p-income-doc-code like parts.in-code    no-undo .
define buffer buf_parts-attr for ub.parts-attr .
define buffer buf_income_parts-attr for ub.parts-attr .
do on error undo, return error return-value :
  assign
    p-income-doc-code = ?
  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
  no-error .
  if available buf_parts-attr then do:
    find first buf_income_parts-attr no-lock
      where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
        and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
        and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
      no-error .
    if available buf_income_parts-attr then do:
      assign
        p-income-doc-code = buf_parts-attr.income-in-code
      .
    end.
    else do:
      assign
        p-income-doc-code = ?
      .
    end.
  end.
  else do:
    assign
      p-income-doc-code = ?
    .
  end.
end.
END PROCEDURE.
