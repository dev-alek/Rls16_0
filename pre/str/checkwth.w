DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_wealth FOR ub.wealth.
DEFINE BUFFER cashier FOR ub.person.
DEFINE BUFFER locked_chk-doc FOR ub.chk-doc.
DEFINE BUFFER locked_chk-doc-attr FOR ub.chk-doc-attr.
DEFINE BUFFER locked_chk-pay FOR ub.chk-pay.
DEFINE BUFFER sales-man FOR ub.person.
DEFINE NEW SHARED TEMP-TABLE tt-chk-doc NO-UNDO LIKE ub.chk-doc.
DEFINE TEMP-TABLE tt-chk-doc-attr NO-UNDO LIKE ub.chk-doc-attr.
DEFINE NEW SHARED TEMP-TABLE tt-chk-pay NO-UNDO LIKE ub.chk-pay.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input-output parameter p-doc-rec as recid no-undo .
define INPUT parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "чек МЦ: добавление, изменение, просмотр":U.
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE vardb-num like ub.db.db-num no-undo.
DEFINE VARIABLE varbase-curs like ub.curr-shop.exch-rate no-undo.
DEFINE VARIABLE varbase-code like ub.currency.curr-code no-undo.
DEFINE VARIABLE varwth-code like ub.wealth.wth-code no-undo.
DEFINE VARIABLE varwth-name like ub.wealth.wth-name no-undo.
define variable hnum as logical no-undo init no.
DEFINE VARIABLE conf-attr as char no-undo.
DEFINE VARIABLE conf-par as char no-undo.
DEFINE VARIABLE par-type as char no-undo.
define variable r-b as character no-undo.
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
define variable locked-title as logical no-undo.
DEFINE VARIABLE var-doc-rid as recid no-undo .
define variable p-view-log as logical no-undo.
define variable v-chip-num like ub.c-chk-doc.chip-num no-undo .
define variable v-is-update as logical no-undo .
define variable v-first-mode as character no-undo .
define variable for-wth-code as integer no-undo .
define variable exch-date_ like ub.curr-shop.exch-date no-undo .
define variable exch-time_ like ub.curr-shop.exch-time no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#libchkvl as handle no-undo .
function libchkvl_right-netto-sign returns integer ( input p-chk-type as integer) in G#libchkvl.
define variable log-file-name as character no-undo init "get-chkf.log".
define stream ChkStream .
define stream InvStream.
DEFINE VARIABLE ss                         as   character             no-undo .
DEFINE VARIABLE var-file-line-num          as   integer               no-undo .
DEFINE VARIABLE ii                         as   integer               no-undo .
DEFINE VARIABLE bc-buf                     as   character             no-undo .
DEFINE VARIABLE b-c                        like ub.bar-code.b-code       no-undo .
DEFINE VARIABLE v-base-code                like ub.sysconf.base-code  no-undo .
DEFINE VARIABLE shop-type                  as   character             no-undo .
DEFINE VARIABLE shop-code                  as   integer               no-undo .
DEFINE VARIABLE chk-type_                  like ub.chk-doc.chk-type   no-undo .
DEFINE VARIABLE chk-date_                  like ub.chk-doc.chk-date   no-undo .
DEFINE VARIABLE chk-time_                  like ub.chk-doc.chk-time   no-undo .
DEFINE VARIABLE shift-date_                like ub.chk-doc.shift-date no-undo .
DEFINE VARIABLE shift-num_                 like ub.chk-doc.shift-num  no-undo .
DEFINE VARIABLE shift-name_                like ub.chk-doc.shift-name  no-undo .
define variable shift-open-time_           as integer no-undo .
DEFINE VARIABLE z-num_                     like ub.chk-doc.z-number   no-undo.
DEFINE VARIABLE cash-rate_                 as decimal                 no-undo .
DEFINE VARIABLE cash-scale_                like ub.chk-doc.cash-scale no-undo .
DEFINE VARIABLE chk-num_                   like ub.chk-doc.chk-num    no-undo .
DEFINE VARIABLE AuthType_                  as integer  no-undo .
DEFINE VARIABLE qr-alchol_                 like ub.chk-doc-attr.attr-value  no-undo .
DEFINE VARIABLE CBCType_                   as integer  no-undo .
DEFINE VARIABLE CBCString_                 like ub.chk-gds-attr.line-num  no-undo .
DEFINE VARIABLE CBCBarcode_                like ub.chk-doc-attr.attr-value  no-undo .
DEFINE VARIABLE pay-desk_                  like ub.chk-doc.pay-desk   no-undo .
DEFINE VARIABLE cashier_                   like ub.chk-doc.cashier    no-undo .
DEFINE VARIABLE sales-man_                 like ub.chk-doc.sales-man  no-undo .
DEFINE VARIABLE d-card_                    like ub.chk-doc.d-card     no-undo .
DEFINE VARIABLE cli-type_                  like ub.chk-doc.cli-type   no-undo .
DEFINE VARIABLE cli-code_                  like ub.chk-doc.cli-code   no-undo .
DEFINE VARIABLE d-mask_                    like ub.chk-doc.d-card     no-undo .
DEFINE VARIABLE tot-d-pcnt                 like ub.chk-doc.src-d-pcnt no-undo .
DEFINE VARIABLE doc-num_                   like ub.chk-doc.doc-num    no-undo .
DEFINE VARIABLE doc-num2_                   like ub.chk-doc.doc-num2  no-undo .
DEFINE VARIABLE num-str_                   as   integer               no-undo .
DEFINE VARIABLE gbl-type                   as   character             no-undo .
DEFINE VARIABLE prev-gbl-type              as   character             no-undo .
define variable dflt-cd                    as   character             no-undo .
DEFINE VARIABLE split-check                as   logical               no-undo init no .
DEFINE VARIABLE current-pay-desk           as   integer               no-undo .
DEFINE VARIABLE current-cas-shift-name     as   character             no-undo .
DEFINE VARIABLE current-cas-shift-date     as   date                  no-undo .
DEFINE VARIABLE time-oper_                 like ub.chk-gds.time-oper  no-undo .
DEFINE VARIABLE t-c-d                      as   decimal               no-undo .
DEFINE VARIABLE pass-gds_                  like ub.chk-gds.pass-gds   no-undo .
DEFINE VARIABLE pump_                      like ub.chk-gds.pump       no-undo .
DEFINE VARIABLE nozzle_                    as   integer               no-undo .
DEFINE VARIABLE place_                     as   integer               no-undo .
DEFINE VARIABLE pl-code_                   as   integer               no-undo .
DEFINE VARIABLE road-tax_                  as   decimal               no-undo .
DEFINE VARIABLE curr-string-qnty           as   decimal               no-undo .
DEFINE VARIABLE sum-from-check             as   decimal               no-undo .
DEFINE VARIABLE discnt-from-check          as   decimal               no-undo .
DEFINE VARIABLE units-rate                 as   decimal               no-undo .
DEFINE VARIABLE units-dpcnt                as   decimal               no-undo .
DEFINE VARIABLE cass-rate                  as   decimal               no-undo .
DEFINE VARIABLE rate-por                   as   integer               no-undo .
DEFINE VARIABLE bank-rate_                 as   decimal               no-undo .
DEFINE VARIABLE bank-scale_                as   integer               no-undo .
DEFINE VARIABLE pass-pay_                  like ub.chk-pay.pass-pay   no-undo .
DEFINE VARIABLE pay-card_                  like ub.chk-pay.pay-card   no-undo .
DEFINE VARIABLE exist                      as   logical init TRUE     no-undo .
DEFINE VARIABLE mc-exist                   as   logical init TRUE     no-undo .
DEFINE VARIABLE price-from-check           like ub.chk-gds.price-base    no-undo .
DEFINE VARIABLE sub-d                      like ub.chk-doc.sub-discnt    no-undo .
DEFINE VARIABLE for-chk-type               as   character             no-undo init "".
DEFINE VARIABLE mc-for-chk-type            as   character             no-undo init "".
DEFINE VARIABLE prev-code                  like ub.chk-doc.doc-code      no-undo init "".
DEFINE VARIABLE mc-prev-code               like ub.chk-doc.doc-code    no-undo init "".
DEFINE VARIABLE pay_code                   like ub.cash-pay.cdpay-code     no-undo .
DEFINE VARIABLE curr_code                  like ub.cash-pay.curr-code    no-undo .
DEFINE VARIABLE pay-type                   as   character             no-undo .
DEFINE VARIABLE cstCode                    as   character             no-undo .
DEFINE VARIABLE cstValue                   as   decimal               no-undo .
DEFINE VARIABLE tot_sum                    as   decimal               no-undo .
DEFINE VARIABLE curr-chk-type              as   character             no-undo .
DEFINE VARIABLE mc-curr-chk-type           like ub.chk-doc.chk-type no-undo .
DEFINE VARIABLE r-bar-code                 like ub.bar-code.b-code       no-undo .
define variable v-curr-r-b                as character               no-undo .
DEFINE VARIABLE lng                        as   integer               no-undo .
DEFINE VARIABLE lnp                        as   integer               no-undo .
DEFINE VARIABLE lnc                        as   integer               no-undo .
DEFINE VARIABLE netto-for-sub-d           as    decimal               no-undo .
DEFINE VARIABLE accum-src-for-sub-d       as    decimal               no-undo .
define variable netto-sum_                as    decimal               no-undo .
define variable brutto-sum_               as    decimal               no-undo .
DEFINE VARIABLE lng-sub-d                 as   integer               no-undo .
DEFINE VARIABLE var-discnt-id             as   integer               no-undo .
define variable v-src-tot-doc             as decimal                 no-undo .
define variable chk-id_                   as character               no-undo .
DEFINE VARIABLE v-path                    as character               no-undo .
DEFINE VARIABLE v-full-path               as character               no-undo .
DEFINE VARIABLE v-file-name               as character               no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character               no-undo .
DEFINE VARIABLE v-file-name-ext           as character               no-undo .
DEFINE VARIABLE v-error-message           as longchar                no-undo .
define buffer buf_shift-cash for ub.shift-cash .
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2dr-flddf: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define temp-table tt-wd no-undo
field doc-code like ub.chk-doc.doc-code
field record-type like ub.chk-discnt.record-type
field line-type like ub.chk-discnt.line-type
field discnt-id like ub.chk-discnt.discnt-id
field line-num like ub.chk-gds.line-num
field wd-sum   like ub.chk-doc.netto
index pi is primary
line-num
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table get-chkc_context  no-undo
field parparentproc       as widget-handle
field p-log-handle        as handle
field p-log-file-name     as character
field view-log            as logical
field ll                  as integer
field tt-wd-bh            as handle
field pos-type            as character
field cash-num            as integer
field obj-type            as character init 'маг':U
field obj-code            as integer
field db-num              as integer
field r-b                 as character
field host-code           as integer
field base-code           as integer
field cre-pay             as integer
field is-catering         as logical
field is-cdinv            as logical
field is-ptrl             as logical
field is-wth              as logical
field process-sale        as logical
field dc-mask             as logical
field card-by-mask        as logical
field sclspref            as character
field scpgpref            as character
field scpgpref-pre        as character
field doc-prt             as logical
field shift-on            as logical
field cas-shft            as logical
field t-shft              as integer
field v-shft              as integer
field ptrl-check          as logical
field annu-check          as logical
field z-check             as logical
field hnum                as logical
field is-100-discnt       as logical
field zero-cashier        as integer
field rnd-znak            as integer
field cas-curs            as logical
field nam-2str            as logical
field nam-artc            as logical
field cod-pcod            as logical
field name-2cd            as character
field how-temp-disc       as character
field nalc                as integer
field rmethod-type        as character
field rmethod-coeff       as decimal
field serial-code         as character
field salesman-mandatory  as integer
field sales-man           as integer
field salesman-psn-code   as integer
field pos-type-for-discnt as character
field manual-discnt       as integer
field is-grp-totals       as logical
field is-gds-totals       as logical
field cash-counter        as decimal
field pre-cash-counter    as decimal
field qnty-change         as logical
field log-level           as integer
field chk-discnt-table    as handle
help 'cntxt_chk-discnt-table':U
field chk-gds-table       as handle
help 'cntxt_chk-gds-table':U
field chk-pay-table       as handle
help  'cntxt_chk-pay-table':U
field z-number            as integer
field shift-num           as integer
field shift-date          as date
field shift-name          as character
field emulator-mode       as integer
field ibmgroup            as logical
index pi is unique primary
db-num
obj-code
pos-type
cash-num
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-chk-doc for ub.chk-doc
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-chk-doc.shift-name.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-chk-doc.obj-type,
                       input  loc-chk-doc.obj-code,
                       input  loc-chk-doc.shift-date,
                       input  loc-chk-doc.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
FUNCTION get-cash-pay RETURNS CHARACTER
  ( input parpay-code as integer, parcurr-code as integer, OUTPUT p-wth-code AS INTEGER )  FORWARD.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-cd
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "&История"
     SIZE 3 BY 1.
DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE fhour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.9 BY 1 NO-UNDO.
DEFINE VARIABLE fmin AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.9 BY 1 NO-UNDO.
DEFINE VARIABLE fsec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.9 BY 1 NO-UNDO.
DEFINE QUERY BR-lines FOR
      locked_chk-pay,
      tt-chk-pay SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-chk-doc SCROLLING.
DEFINE BROWSE BR-lines
  QUERY BR-lines DISPLAY
      tt-chk-pay.line-num FORMAT "999":U
tt-chk-pay.pay-code FORMAT "-99999":U
tt-chk-pay.curr-code COLUMN-LABEL "Код!валюты" FORMAT ">>9":U
get-cash-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, OUTPUT for-wth-code) COLUMN-LABEL "Тип касс. платежа" FORMAT "X(20)":U
varwth-code COLUMN-LABEL "Код МЦ"
tt-chk-pay.tot-sum FORMAT "->>>>>>>>>9.99":U
varwth-name COLUMN-LABEL "Название МЦ" FORMAT "X(20)":U
tt-chk-pay.cash-rate COLUMN-LABEL "Курс валюты!платежа" FORMAT ">>,>>9.9999":U
tt-chk-pay.bank-rate FORMAT ">>,>>9.9999":U
tt-chk-pay.bank-scale FORMAT ">>>9":U
tt-chk-pay.doc-qnty FORMAT "->>,>>>,>>9.<<<":U column-label "Кол-во!в БД"
tt-chk-pay.src-qnty FORMAT "->>,>>>,>>9.<<<":U column-label "Кол-во!в чеке"
tt-chk-pay.par-val FORMAT ">>>>>9":U column-label "Номинал!в БД"
tt-chk-pay.src-val FORMAT ">>>>>9":U column-label "Номинал!в чеке"
tt-chk-pay.par-code column-label "Код!номинала" format ">>9"
ENABLE
tt-chk-pay.pay-code
tt-chk-pay.curr-code
tt-chk-pay.src-qnty
tt-chk-pay.src-val
tt-chk-pay.tot-sum
tt-chk-pay.cash-rate
tt-chk-pay.bank-rate
tt-chk-pay.bank-scale
    WITH SEPARATORS SIZE 98 BY 11.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-prev AT ROW 1 COL 41
     B-next AT ROW 1 COL 45
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-chk-doc.chk-date AT ROW 2.33 COL 11.3 COLON-ALIGNED
          LABEL "Дата чека"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-chk-doc.obj-code AT ROW 2.33 COL 55 COLON-ALIGNED
          LABEL "N магазина"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-chk-doc.chk-type AT ROW 2.43 COL 72.4 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", 1,
"Item 2", 2
          SIZE 20.8 BY 3.27
     fhour AT ROW 3.63 COL 11.4 COLON-ALIGNED NO-LABEL
     fmin AT ROW 3.63 COL 15.5 COLON-ALIGNED NO-LABEL
     fsec AT ROW 3.63 COL 19.6 COLON-ALIGNED NO-LABEL
     tt-chk-doc.pay-desk AT ROW 3.63 COL 55 COLON-ALIGNED
          LABEL "N кассы"
          VIEW-AS FILL-IN
          SIZE 5.3 BY 1
     b-cd AT ROW 3.67 COL 63 WIDGET-ID 2
     tt-chk-doc.src-shift-date AT ROW 4.83 COL 11 COLON-ALIGNED
          LABEL "Дата смены" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11.5 BY 1
     tt-chk-doc.shift-date AT ROW 4.83 COL 35 COLON-ALIGNED
          LABEL "Дата учета"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 12
     tt-chk-doc.cashier AT ROW 4.83 COL 55 COLON-ALIGNED
          LABEL "Кассир"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-chk-doc.shift-name AT ROW 6 COL 11 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     tt-chk-doc.shift-num AT ROW 6 COL 20.5 COLON-ALIGNED
          LABEL "П."
          VIEW-AS FILL-IN
          SIZE 4.1 BY 1
     tt-chk-doc.chk-num AT ROW 6 COL 55 COLON-ALIGNED format "99999999999"
          LABEL "N по кассе"
          VIEW-AS FILL-IN
          SIZE 10.9 BY 1
     tt-chk-doc.cash-rate AT ROW 6 COL 85 COLON-ALIGNED
          LABEL "Курс нац. вал."
          VIEW-AS FILL-IN
          SIZE 11.4 BY 1
     tt-chk-doc.z-number AT ROW 7.2 COL 55 COLON-ALIGNED
          LABEL "z-отчет"
          VIEW-AS FILL-IN
          SIZE 10.8 BY 1
     B-add AT ROW 7.43 COL 79.5
     B-del AT ROW 7.43 COL 89.5
     BR-lines AT ROW 8.5 COL 1.6
     tt-chk-doc.PS AT ROW 19.77 COL 1.3 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98.6 BY 2.27
     ":" VIEW-AS TEXT
          SIZE .8 BY 1.07 AT ROW 3.7 COL 20.4
     "Время:" VIEW-AS TEXT
          SIZE 10.3 BY 1 AT ROW 3.63 COL 2
     ":" VIEW-AS TEXT
          SIZE .8 BY 1.07 AT ROW 3.7 COL 16.4
     "Тип чека" VIEW-AS TEXT
          SIZE 11.8 BY .83 AT ROW 1.47 COL 72.3
     SPACE(16.27) SKIP(19.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Чек МЦ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON ANY-KEY OF FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON END-ERROR OF FRAME Dialog-Frame
DO:
   apply "choose" to B-quit in frame Dialog-Frame.
  return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
   p-next-prev = "QUIT".
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  run proc-b-add in this-procedure no-error.
  if error-status:error THEN return no-apply.
END.
ON CHOOSE OF b-cd IN FRAME Dialog-Frame
DO:
  run sel-cd in this-procedure no-error.
  if error-status:error then return no-apply.
  else do:
    assign
    tt-chk-doc.pay-desk = buf_cash-desk.cash-num
    .
    display
    tt-chk-doc.pay-desk
    with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  APPLY "DELETE-CHARACTER" to br-lines.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if par-mode = 'ПРОСМОТР':U then.
  else do:
    run check-this-check in this-procedure no-error.
    if error-status:error then do:
      return no-apply.
    end.
  end.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
    if available locked_chk-doc THEN
    run str/cchkdocs.w (
                        input parparentproc
                       ,input "":U
                       ,input "one":U
                       ,input locked_chk-doc.doc-code
                       ,input p-obj-type
                       ,input p-obj-code
                       ,input-output v-rid-list
                    ).
END.
ON CHOOSE OF B-next IN FRAME Dialog-Frame
DO:
   run reposition-chk-doc in this-procedure
  (input 'next':U
  ).
END.
ON CHOOSE OF B-prev IN FRAME Dialog-Frame
DO:
   run reposition-chk-doc in this-procedure
  (input 'prev':U
  ).
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable glog as logical no-undo .
   IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    IF CAN-FIND( FIRST ub.chk-pay NO-LOCK WHERE
                       ub.chk-pay.doc-code = tt-chk-doc.doc-code ) THEN DO:
      MESSAGE
        "Чек не будет сохранен, а вся введенная Вами информация будет потеряна!" SKIP
        "Для того, чтобы сохранить документ, нужно нажать кнопку ~"" +
        B-exit:LABEL IN FRAME Dialog-Frame + "~"." SKIP( 1 )
        "Вы уверены, что хотите выйти БЕЗ СОХРАНЕНИЯ?" SKIP
        "YES[ДА] - Выйти БЕЗ СОХРАНЕНИЯ;" SKIP
        "NO[НЕТ] - Остаться в документе."
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE "Выход из чека без сохранения" UPDATE glog.
      IF glog = NO THEN DO:
        RETURN NO-APPLY.
      END.
    END.
    DO TRANSACTION ON ERROR UNDO, LEAVE :
      case par-mode:
        when 'ДОБАВЛЕНИЕ':U then do:
          if available locked_chk-doc then
          delete locked_chk-doc.
          p-doc-rec = ?.
        end.
      END CASE.
      p-doc-rec = ?.
      p-next-prev = ?.
    END.
  END.
  p-next-prev = ?.
END.
ON DELETE-CHARACTER OF BR-lines IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
if par-mode <> 'ДОБАВЛЕНИЕ':U then return no-apply.
glog = yes.
message
"Удалить строчку из чека ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.
FIND FIRST locked_chk-pay where
      locked_chk-pay.doc-code = tt-chk-pay.doc-code
  AND locked_chk-pay.line-num = tt-chk-pay.line-num.
DELETE tt-chk-pay.
delete locked_chk-pay.
OPEN QUERY BR-lines FOR EACH locked_chk-pay NO-LOCK WHERE        locked_chk-pay.doc-code = tt-chk-doc.doc-code,            FIRST tt-chk-pay WHERE         tt-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-chk-pay.line-num = locked_chk-pay.line-num.
run control-line in this-procedure ( output locked-title).
run lock-proc in this-procedure ( input locked-title).
APPLY "entry" TO br-lines.
END.
ON VALUE-CHANGED OF tt-chk-doc.chk-type IN FRAME Dialog-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  IF CAN-FIND(FIRST tt-chk-pay WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code)
      THEN DO:
      MESSAGE
      "Установить тип чека можно только в самом начале процесса создания чека" SKIP
      "когда еще не созданы строки"
      VIEW-AS ALERT-BOX ERROR.
      display tt-chk-doc.chk-type
      with frame Dialog-Frame .
      RETURN NO-APPLY.
  END.
  ASSIGN
  tt-chk-doc.chk-type.
  locked_chk-doc.chk-type = tt-chk-doc.chk-type.
END.
ON LEAVE OF fhour IN FRAME Dialog-Frame
DO:
  run check-time in this-procedure ( input fhour:screen-value, input "hour":U) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF fmin IN FRAME Dialog-Frame
DO:
  run check-time in this-procedure ( input fmin:screen-value, input "min":U) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF fsec IN FRAME Dialog-Frame
DO:
    run check-time in this-procedure ( input fsec:screen-value, input "sec":U)  no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF tt-chk-doc.shift-name IN FRAME Dialog-Frame
DO:
    define variable v-dopi as integer no-undo .
  define variable v-old-shift-name as character no-undo .
    assign
    v-old-shift-name = tt-chk-doc.shift-name
    tt-chk-doc.shift-name
    .
    assign
    v-dopi = integer(tt-chk-doc.shift-name) no-error .
    if error-status:error
    or v-dopi < 0
    or v-dopi > 99 then do:
      message
      "Неверное значение № смены"
      view-as alert-box error .
      tt-chk-doc.shift-name = v-old-shift-name .
      display
      tt-chk-doc.shift-name
      with frame Dialog-Frame .
      return no-apply.
    end.
    display
    v-dopi @ tt-chk-doc.shift-num
    with frame Dialog-Frame .
END.
ON LEAVE OF tt-chk-doc.src-shift-date IN FRAME Dialog-Frame
DO:
   assign
  tt-chk-doc.src-shift-date.
  run find-uchet-date in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF tt-chk-pay.tot-sum IN BROWSE br-lines,
            tt-chk-pay.pay-code IN BROWSE br-lines,
            tt-chk-pay.curr-code IN BROWSE br-lines DO:
define variable old-sum      like tt-chk-pay.tot-sum no-undo .
define variable old-pay-code like tt-chk-pay.pay-code no-undo .
define variable old-curr-code like tt-chk-pay.curr-code no-undo .
define variable old-src-qnty like tt-chk-pay.src-qnty no-undo .
define variable old-src-val like tt-chk-pay.src-val no-undo .
DEFINE VARIABLE varopl-curs as decimal no-undo .
DEFINE VARIABLE varbase-curs as decimal no-undo .
define buffer buf_wth-par for ub.wth-par.
if avail tt-chk-pay then DO:
assign
old-sum      = tt-chk-pay.tot-sum
old-pay-code = tt-chk-pay.pay-code
old-curr-code = tt-chk-pay.curr-code
old-src-qnty = tt-chk-pay.src-qnty
old-src-val = tt-chk-pay.src-val
.
assign
tt-chk-pay.tot-sum = decimal(tt-chk-pay.tot-sum:screen-value in browse br-lines)
tt-chk-pay.pay-code = integer(tt-chk-pay.pay-code:screen-value in browse br-lines)
tt-chk-pay.curr-code = decimal(tt-chk-pay.curr-code:screen-value in browse br-lines    )
tt-chk-pay.src-qnty = decimal(tt-chk-pay.src-qnty:screen-value in browse br-lines    )
tt-chk-pay.src-val = integer(tt-chk-pay.src-val:screen-value in browse br-lines    )
.
FIND FIRST LOCKED_chk-pay NO-LOCK WHERE
          LOCKED_chk-pay.doc-code = tt-chk-doc.doc-code
     AND  LOCKED_chk-pay.line-num = tt-chk-pay.line-num.
run trg/chkins02.p (
              input  tt-chk-doc.doc-code
             ,input  1
             ,input  tt-chk-doc.chk-type
             ,input  tt-chk-doc.obj-type
             ,input  tt-chk-doc.obj-code
             ,input  tt-chk-doc.chk-date
             ,input  tt-chk-doc.chk-time
             ,input  tt-chk-pay.pay-code
             ,input  tt-chk-pay.curr-code
             ,input  varbase-code
             ,input  get-chkc_context.r-b
             ,input  get-chkc_context.cas-curs
             ,input-output  tt-chk-pay.cash-rate
             ,input-output  tt-chk-pay.bank-rate
             ,input-output  tt-chk-pay.bank-scale
             ,input  recid(locked_chk-pay)
             ,output varbase-curs
             ,output varopl-curs
             ,output tt-chk-pay.par-code
           ) no-error.
  if error-status:error then do:
    assign
    tt-chk-pay.tot-sum        =   old-sum
    tt-chk-pay.pay-code   =   old-pay-code
    tt-chk-pay.curr-code  =   old-curr-code
    tt-chk-pay.src-qnty = old-src-qnty
    tt-chk-pay.src-val = old-src-val
    .
    display
    tt-chk-pay.tot-sum
    tt-chk-pay.pay-code
    tt-chk-pay.curr-code
    tt-chk-pay.src-qnty
    tt-chk-pay.src-val
    with browse br-lines.
  end.
 END.
end.
ON RETURN OF tt-chk-pay.tot-sum IN BROWSE br-lines,
            tt-chk-pay.pay-code IN BROWSE br-lines,
            tt-chk-pay.curr-code IN BROWSE br-lines,
            tt-chk-pay.src-qnty IN BROWSE br-lines,
            tt-chk-pay.src-val IN BROWSE br-lines
            DO:
  APPLY "LEAVE" TO SELF.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-lines :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
p-next-prev = ''.
n-p:
do while p-next-prev = '':U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if par-mode <> 'ИЗМЕНЕНИЕ':U and par-mode <> 'ДОБАВЛЕНИЕ':U and par-mode <> 'ПРОСМОТР':U then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  assign
  v-first-mode = par-mode
  .
  if par-mode <> 'ПРОСМОТР':U then do:
    p-next-prev = 'quit'.
  end.
  assign
  shop-type =   p-obj-type
  shop-code = p-obj-code
  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION convert-discount returns integer
                                          ( input p-disc-reason as integer
                                          , input p-disc-type  as integer
                                          , input p-line-type as integer) :
define variable v-disc-type as integer no-undo .
if p-line-type = integer('1':U)
or p-line-type = integer('0':U)
then do:
  if p-disc-type = 0
  or p-disc-type = 1
  or p-disc-type = 2
  then do:
    if p-disc-reason <> 0 then
    p-disc-type = p-disc-reason
    .
  end.
end.
if p-line-type = integer('3':U)
or p-line-type = integer('2':U) then do:
  if p-disc-type = 101
  or p-disc-type = 102
  then do:
    if p-disc-reason <> 0 then
    p-disc-type = p-disc-reason
    .
  end.
end.
if p-disc-reason <> 0 then do:
  CASE p-disc-reason:
    when 0 then do:
      return integer('0':U).
    end.
    when 1 then do:
      return integer('11':U).
    end.
    when 2 then do:
      return integer('1':U).
    end.
    when 3 or when 15 then do:
      return integer('7':U).
    end.
    when 4 then do:
      return integer('4':U).
    end.
    when 5 then do:
      return integer('12':U).
    end.
    when 6 then do:
      return integer('3':U).
    end.
    when 7 then do:
      return integer('13':U).
    end.
    when 8
    or
    when 9
    or
    when 10
    then do:
      return integer('20':U).
    end.
    when 11
    then do:
      return integer('21':U).
    end.
    when 13
    then do:
      return integer('22':U).
    end.
    when 16 then do:
      return integer('23':U).
    end.
  END CASE.
end.
CASE p-disc-type:
  when 0 then do:
    return integer('0':U).
  end.
  when 1 then do:
    return integer('13':U).
  end.
  when 2 then do:
    return integer('2':U).
  end.
  when 3 then do:
    return integer('4':U).
  end.
  when 4 then do:
    return integer('12':U).
  end.
  when 5 then do:
    return integer('1':U).
  end.
  when 6 then do:
    return integer('3':U).
  end.
  when 7 then do:
    return integer('14':U).
  end.
  when 8 then do:
    return integer('15':U).
  end.
  when 9 then do:
    return integer('16':U).
  end.
  when 101 then do:
    return integer('13':U).
  end.
  when 102 then do:
    return integer('5':U).
  end.
  when 103 then do:
    return integer('1':U).
  end.
  when 104 then do:
    return integer('5':U).
  end.
  when 105 then do:
    return integer('1':U).
  end.
  when 106 then do:
    return integer('1':U).
  end.
END CASE.
END FUNCTION.
run get-general-parameters in this-procedure .
procedure get-general-parameters :
define buffer buf_get-chkc_context for get-chkc_context.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  for each buf_get-chkc_context:
    delete buf_get-chkc_context.
  end.
  create buf_get-chkc_context.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_create-context in g#libchkvl
  (input  shop-type
  ,input  shop-code
  ,input  buffer buf_get-chkc_context:handle
  ) no-error .
  if error-status:error then do:
    undo, return error substitute("Ошибка при создании контекста&1&2&1&3"
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  find first buf_get-chkc_context.
  assign
  buf_get-chkc_context.parparentproc = parparentproc
  buf_get-chkc_context.p-log-handle = p-log-handle
  buf_get-chkc_context.tt-wd-bh     = buffer tt-wd:handle
  .
  release buf_get-chkc_context.
  find first get-chkc_context.
end.
end procedure.
  run get-params in this-procedure ( input shop-type, input shop-code) no-error.
  if error-status:error then return error.
  Run fill-tables in this-procedure no-error.
  if error-status:error then return error.
  RUN MyEnable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
end.
RUN disable_UI in this-procedure .
PROCEDURE check-dublicate :
define buffer dub_chk-doc for ub.chk-doc.
      FIND  dub_chk-doc where
            dub_chk-doc.obj-type = tt-chk-doc.obj-type and
            dub_chk-doc.obj-code = tt-chk-doc.obj-code and
            dub_chk-doc.chk-date = tt-chk-doc.chk-date and
            dub_chk-doc.pay-desk = tt-chk-doc.pay-desk and
            dub_chk-doc.chk-time = tt-chk-doc.chk-time and
            dub_chk-doc.chk-num = tt-chk-doc.chk-num and
            dub_chk-doc.sales-man = tt-chk-doc.sales-man NO-ERROR .
if available dub_chk-doc  and
recid(dub_chk-doc) <> recid(locked_chk-doc) then do:
    message
    "Уже есть чек" dub_chk-doc.doc-code      "по магазину" tt-chk-doc.obj-code "в котором"
    "дата" tt-chk-doc.chk-date SKIP
    "время" string(tt-chk-doc.chk-time, "HH:MM:SS":U)  SKIP
    "касса" tt-chk-doc.pay-desk SKIP
    "номер чека на кассе" tt-chk-doc.chk-num SKIP
    "продавец" tt-chk-doc.sales-man
    view-as alert-box ERROR.
    return error.
end.
END PROCEDURE.
PROCEDURE check-manual :
if not can-find(first locked_chk-pay where locked_chk-pay.doc-code = tt-chk-doc.doc-code) then do:
  message
  "В чеке нет строк товаров и/или строк оплат" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.
end.
if tt-chk-doc.pay-desk = 0 then do:
  message
  "Нельзя создать чек для кассы с номером 0"
  view-as alert-box error .
  return error .
end.
END PROCEDURE.
PROCEDURE check-this-check :
define variable v-num as integer no-undo.
define buffer loc_chk-pay for ub.chk-pay.
assign
mc-prev-code = tt-chk-doc.doc-code.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
    run proc-save-doc in this-procedure ( input yes, input yes) no-error.
    if error-status:error then return error.
    run check-dublicate in this-procedure no-error.
    if error-status:error then return error.
    run check-manual in this-procedure no-error .
    if error-status:error then return error.
end.
run proc-save-doc in this-procedure  ( input yes, input yes) no-error.
if error-status:error then return error.
assign
locked_chk-doc.discnt = 0
locked_chk-doc.correct = yes
for-chk-type = "":U
.
for each loc_chk-pay where
            loc_chk-pay.doc-code = tt-chk-doc.doc-code:
    assign
    loc_chk-pay.obj-code =   tt-chk-doc.obj-code
    loc_chk-pay.line-sign = (if tt-chk-doc.chk-type = integer('2':U)
                                    or tt-chk-doc.chk-type =  integer('5':U
                                   )
                                  then (loc_chk-pay.tot-sum <= 0)
                                  else (loc_chk-pay.tot-sum >= 0)
                                  )
    loc_chk-pay.time-oper = (if par-mode = 'ДОБАВЛЕНИЕ':U
                                          then tt-chk-doc.chk-time
                                          else loc_chk-pay.time-oper)
    .
End.
for each loc_chk-pay where
            loc_chk-pay.doc-code = tt-chk-doc.doc-code:
    assign
    loc_chk-pay.obj-code =   tt-chk-doc.obj-code
    loc_chk-pay.line-sign = (if tt-chk-doc.chk-type = integer('2':U)
                                    or tt-chk-doc.chk-type =  integer('5':U
                                   )
                                  then (loc_chk-pay.tot-sum <= 0)
                                  else (loc_chk-pay.tot-sum >= 0)
                                  )
    loc_chk-pay.time-oper = (if par-mode = 'ДОБАВЛЕНИЕ':U
                                          then tt-chk-doc.chk-time
                                          else loc_chk-pay.time-oper)
    .
End.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getwcheck in g#libchkvl
  (input  buffer get-chkc_context:handle
  ,input  'ИЗМЕНЕНИЕ':U
  ,input  par-mode
  ,input  yes
  ,input  yes
  ,input  ?
  ,input-output mc-prev-code
    ) no-error .
assign
p-view-log = (p-view-log or get-chkc_context.view-log)
.
if locked_chk-doc.correct = no then do:
  if par-mode = 'ДОБАВЛЕНИЕ':U then do:
        run gbl/d-askw.w (
           input "Выход из режима создания чека МЦ"
          ,input "Созданный Вами чек является ошибочным" + chr(10)
            + "Вы действительно хотите сделать это?" + chr(10)
          ,input "|^"
          ,input "Сохранить|Редактировать|Не сохранять"
          ,input "Чек будет сохранен как ошибочный и к нему можно будет вернуться для последующего редактирования|"
               + "Продолжить редактирование и постараться исправить все ошибки в чеке|"
               + "Чек не будет сохранен"
          ,input 2
          ,input 3
          ,output v-num
          ).
        CASE v-num:
            when 2 then do:
                return error.
            end.
             when 3 then do:
                p-doc-rec = ?.
                delete locked_chk-doc .
                return.
             end.
        END CASE.
  end.
  else do:
    run gbl/d-askw.w (
       input "Выход из режима редактирования чека МЦ"
      ,input "Редактируемый Вами чек МЦ является ошибочным" + chr(10)
      ,input "|^"
      ,input "Сохр ошибочный|Редактировать"
      ,input "Чек будет сохранен как ошибочный и к нему можно будет вернуться для последующего редактирования|"
            + "Постараться исправить все ошибки в чеке"
      ,input 1
      ,input 2
      ,output v-num
      ).
      if v-num = 2 then return error.
  end.
end.
if par-mode = 'ИЗМЕНЕНИЕ':U then
run trg/chk-doch.p (
                buffer locked_chk-doc
              , input yes
              , input no
              , input no
              , input-output v-chip-num
              , output v-is-update).
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  run trg/chk-doch.p (
                  buffer locked_chk-doc
                , input no
                , input yes
                , input no
                , input-output v-chip-num
                , output v-is-update).
end.
if v-is-update or par-mode = 'ДОБАВЛЕНИЕ':U then do:
  assign
  locked_chk-doc.PS = "!":U + (if index(locked_chk-doc.ps, "shift!") > 0 then "shift!" else '':U) +
                              (if index(locked_chk-doc.ps, "shift!") > 0
                              then substring(left-trim(locked_chk-doc.ps, "!"), 7)
                              else left-trim(locked_chk-doc.PS, "!":U))
  tt-chk-doc.PS = locked_chk-doc.pS
  .
  display
  tt-chk-doc.ps
  with frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE check-time :
define input parameter parscreen-value as integer no-undo.
define input parameter par-mode as character no-undo.
define variable var-limit as integer no-undo.
CASE par-mode:
    when "hour":U then do:
         var-limit = 23.
    end.
    when "min":U then do:
          var-limit = 59.
    end.
    when "sec" then do:
          var-limit = 59.
    end.
END.
  if int(parscreen-value) > var-limit then do:
    bell.
    Message "Неверное время!" view-as alert-box ERROR.
    return error.
  end.
  run find-curs in this-procedure (
                                    input date(tt-chk-doc.chk-date:screen-value in frame Dialog-Frame)
                                    ,input (integer(fhour:screen-value) * 3600 + integer(fmin:screen-value) * 60) + integer(fsec:screen-value)
                                    ,output varbase-curs) no-error.
 if error-status:error then return error.
END PROCEDURE.
PROCEDURE control-line :
DEFINE OUTPUT PARAMETER locked-title as logical no-undo.
IF CAN-FIND(FIRST ub.chk-pay No-LOCK WHERE
                  ub.chk-pay.doc-code = tt-chk-doc.doc-code) then
locked-title = yes.
else locked-title = no.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-chk-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY fhour fmin fsec
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-chk-doc THEN
    DISPLAY tt-chk-doc.chk-date tt-chk-doc.obj-code tt-chk-doc.chk-type
          tt-chk-doc.pay-desk tt-chk-doc.src-shift-date tt-chk-doc.shift-date
          tt-chk-doc.cashier tt-chk-doc.shift-name tt-chk-doc.shift-num
          tt-chk-doc.chk-num tt-chk-doc.cash-rate tt-chk-doc.z-number
          tt-chk-doc.PS
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-prev B-next B-hist B-Help tt-chk-doc.chk-date
         tt-chk-doc.obj-code tt-chk-doc.chk-type fhour fmin fsec
         tt-chk-doc.pay-desk b-cd tt-chk-doc.src-shift-date
         tt-chk-doc.shift-date tt-chk-doc.cashier tt-chk-doc.shift-name
         tt-chk-doc.shift-num tt-chk-doc.chk-num tt-chk-doc.cash-rate
         tt-chk-doc.z-number B-add B-del BR-lines tt-chk-doc.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-lines FOR EACH locked_chk-pay NO-LOCK WHERE        locked_chk-pay.doc-code = tt-chk-doc.doc-code,            FIRST tt-chk-pay WHERE         tt-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-chk-pay.line-num = locked_chk-pay.line-num.
END PROCEDURE.
PROCEDURE fill-tables :
define variable v-first-cashier as integer no-undo .
define variable v-first-seller as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
for each tt-chk-doc:
    delete tt-chk-doc.
end.
for each tt-chk-pay:
    delete tt-chk-pay.
end.
IF par-mode = 'ДОБАВЛЕНИЕ':U then do:
   p-doc-rec = ?.
   run get-environment in this-Procedure no-error.
   if error-status:error then return error.
    message
    "Выберите из списка кассу, для которой Вы хотите создать чек!"
    view-as alert-box.
    run sel-cd in this-procedure no-error.
    if error-status:error then do:
      undo, return error .
    end.
   run gbl/factdate.p (
                     INPUT        p-obj-type
                    ,INPUT        p-obj-code
                    ,INPUT-OUTPUT chk-date_
                    ,INPUT-OUTPUT chk-time_
                    ,INPUT-OUTPUT shift-date_
                    ,INPUT-OUTPUT shift-num_
                    ,input-output shift-name_
                    ,INPUT        YES
               ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      return error.
    END.
    if shift-name_ = ? then do:
      shift-name_ = "":U.
    end.
    cash-scale_ = 1.
    run find-curs in this-procedure
                        (
                         input chk-date_
                        ,input chk-time_
                        ,output cash-rate_
                         )  no-error.
    if error-status:error then undo, return error .
    assign
    v-first-cashier = gbclcode-get-this-db-first-role ( input 'C':U, input vardb-num, input ?) no-error .
    if v-first-cashier = 0 then do:
      message
      "В справочнике нет ни одного кассира для текущей БД" skip
      "невозможно создать чек"
      view-as alert-box error.
      return error.
    end.
    run cur-time in THIS-PROCEDURE ( output v-today, output v-time).
    DO TRANSACTION ON ERROR UNDO, RETURN ERROR:
      create tt-chk-doc.
      ASSIGN
      tt-chk-doc.chk-date = chk-date_
      tt-chk-doc.src-shift-date = (if shift-date_ = ? then chk-date_ else shift-date_)
      tt-chk-doc.shift-num  = shift-num_
      tt-chk-doc.shift-name = shift-name_
      tt-chk-doc.cashier   = v-first-cashier
      tt-chk-doc.sales-man   = v-first-seller
      tt-chk-doc.doc-code =   (if get-chkc_context.db-num = 0
                                then string(next-value(s-chk, ub ))
                                else string( p-obj-code ) + chr(47) + string( next-value( s-chk, ub ) ))
      tt-chk-doc.obj-type = p-obj-type
      tt-chk-doc.obj-code = p-obj-code
      tt-chk-doc.chk-num  = 1
      tt-chk-doc.chk-time  = v-time
      tt-chk-doc.chk-type  = integer('2':U)
      tt-chk-doc.correct  = yes
      tt-chk-doc.pay-desk = buf_cash-desk.cash-num
      tt-chk-doc.cash-rate = if get-chkc_context.r-b = 'base':U
                                  then cash-rate_
                                  else 1
      tt-chk-doc.cash-scale = if get-chkc_context.r-b = 'base':U
                                        then cash-scale_
                                        else 1
      .
      create locked_chk-doc.
      buffer-copy tt-chk-doc to locked_chk-doc.
      assign
      .
  END.
  FIND FIRST buf_obj No-LOCK WHERe
            buf_obj.obj-type = shop-type
        AND buf_obj.obj-code = shop-code No-ERROR.
end.
else do:
  if par-mode = 'ПРОСМОТР':U then do:
    FIND FIRST locked_chk-doc NO-LOCK WHERE
                recid(locked_chk-doc) = p-doc-rec.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
    FIND FIRST locked_chk-doc EXCLUSIVE-LOCK WHERE
                recid(locked_chk-doc) = p-doc-rec.
    END.
  END.
  IF NOT AVAIL locked_chk-doc then
  return error.
  if locked_chk-doc.out-code <> ?
  and par-mode <> 'ПРОСМОТР':U then do:
    message
    "Чек МЦ с N" locked_chk-doc.doc-code  "включен в документ МЦ" SKIP
    "Изменения не допускаются"
    view-as alert-box error.
    return error.
  end.
  assign
  p-obj-type = locked_chk-doc.obj-type
  p-obj-code = locked_chk-doc.obj-code
  .
  run get-environment in this-Procedure no-error.
  if error-status:error then return error.
  create tt-chk-doc.
  buffer-copy locked_chk-doc to tt-chk-doc.
  if gbclcode-is-this-db-role ( input 'C':U, input vardb-num, input tt-chk-doc.cashier, input tt-chk-doc.chk-date) = 0 then do:
    message
    "В справочнике нет кассира" tt-chk-doc.cashier
    view-as alert-box WARNING.
  end.
  FIND FIRST buf_cash-desk no-lock where
            buf_cash-desk.db-num = vardb-num and
            buf_cash-desk.obj-code = p-obj-code AND
            buf_cash-desk.cash-num = tt-chk-doc.pay-desk no-error.
  if not available buf_cash-desk then dO:
    message
    "В справочнике нет кассы" tt-chk-doc.pay-desk
    view-as alert-box error.
  end.
  for each locked_chk-pay where
           locked_chk-pay.doc-code = tt-chk-doc.doc-code no-lock:
        create tt-chk-pay.
        buffer-copy locked_chk-pay to tt-chk-pay.
    end.
    for each locked_chk-doc-attr no-lock where
           locked_chk-doc-attr.doc-code = tt-chk-doc.doc-code:
        create tt-chk-doc-attr.
        buffer-copy locked_chk-doc-attr to tt-chk-doc-attr.
    end.
end.
if not par-mode = 'ПРОСМОТР':U then do:
  if par-mode = 'ДОБАВЛЕНИЕ':U
  and (not get-chkc_context.shift-on
  and get-chkc_context.cas-shft) then do:
    assign
    tt-chk-doc.src-shift-date = tt-chk-doc.chk-date
    tt-chk-doc.shift-date = tt-chk-doc.chk-date
    .
  end.
end.
END PROCEDURE.
PROCEDURE find-curs :
DEFINE INPUT PARAMETER par-date as date no-undo.
DEFINE INPUT PARAMETER par-time as integer no-undo.
DEFINE output PARAMETER parbase-curs as decimal no-undo.
DEFINE BUFFER buf_curr-shop FOR ub.curr-shop .
IF varbase-code <> 0 then do:
    FIND LAST buf_curr-shop NO-LOCK Where
                         buf_curr-shop.obj-type = p-obj-type AND
                buf_curr-shop.obj-code  = p-obj-code AND
                buf_curr-shop.curr-code = varbase-code AND
               ( ( buf_curr-shop.exch-date = par-date AND
               buf_curr-shop.exch-time <= par-time ) OR
               buf_curr-shop.exch-date < par-date ) NO-ERROR .
    IF NOT AVAIL buf_curr-shop then do:
        message
        "Нет магазинного курса базовой валюты на дату и время чека!" skip
         " - дата " string(par-date, "99/99/9999")
        " время - " string(par-time, "hh:mm") view-as alert-box ERROR.
       return error.
    end.
    parbase-curs = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale.
END.
else parbase-curs = 1.
END PROCEDURE.
PROCEDURE find-uchet-date :
assign
tt-chk-doc.src-shift-date = if (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
                              then tt-chk-doc.src-shift-date
                              else tt-chk-doc.chk-date
tt-chk-doc.shift-date = if get-chkc_context.t-shft < 0 AND tt-chk-doc.chk-time < abs(t-shft)
                          then (tt-chk-doc.chk-date - 1)
                          else tt-chk-doc.src-shift-date
.
display
tt-chk-doc.shift-date
with frame Dialog-Frame.
run find-curs in this-procedure (
                                      input tt-chk-doc.chk-date
                                     ,input tt-chk-doc.chk-time
                                     ,output cash-rate_
                                     ) no-error.
 if error-status:error then return error.
END PROCEDURE.
PROCEDURE get-environment :
  FIND FIRST buf_obj No-LOCK WHERE
                buf_obj.obj-type = p-obj-type and
                buf_obj.obj-code = p-obj-code No-ERROR.
if not avail buf_obj or p-obj-type <> 'маг':U then do:
    message vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-obj-type и/или p-obj-code" p-obj-type p-obj-code
    view-as alert-box ERROR.
    return.
end.
vardb-num = buf_obj.db-num.
FIND FIRST ub.shop No-LOCK WHERE
                         ub.shop.obj-code = p-obj-code No-ERROR.
        if not available shop then do:
            message "Не найден магазин с кодом" p-obj-code
            view-as alert-box ERROR.
            return error.
        end.
FIND FIRSt ub.sysconf No-LOCK WHERE
                        ub.sysconf.host-code = ub.shop.host-code No-ERROR.
        if not available ub.sysconf then do:
            message "Не найдена фирма с кодом" ub.shop.host-code
            view-as alert-box ERROR.
            return error.
        end.
        assign
        varbase-code = ub.sysconf.base-code.
END PROCEDURE.
PROCEDURE get-params :
DEFINE INPUT PARAMETER p-obj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code like ub.clients.obj-code no-undo.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type22 as character no-undo .
define variable v-value-date22 as date no-undo .
define variable v-value-decimal22 as decimal no-undo .
define variable v-value-integer22 as INTEGER no-undo .
define variable v-value-logical22 AS LOGICAL no-undo .
define variable v-tth22 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date22
    ,output v-value-decimal22
    ,output v-value-integer22
    ,output v-value-logical22
    ,output v-param-type22
    ,INPUT-OUTPUT table-handle v-tth22
    )  .
delete object v-tth22 no-error.
get-chkc_context.pos-type = dflt-cd.
get-chkc_context.p-log-handle = this-procedure:handle.
if get-chkc_context.shift-on and not get-chkc_context.cas-shft then do:
  message
  "Внимание! На текущем объекте требуется использование смен" skip
  "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
  view-as alert-box ERROR.
  return ERROR.
end.
END PROCEDURE.
PROCEDURE lock-proc :
DEFINE INPUT PARAMETER locked-title as logical no-undo.
if locked-title then do:
    DISABLE
    fhour fmin fsec
    tt-chk-doc.cash-rate
    tt-chk-doc.chk-date
    tt-chk-doc.chk-type
    with frame Dialog-Frame
    .
end.
else do:
    if par-mode <> 'ПРОСМОТР':U then
    ENABLE
    fhour when par-mode = 'ДОБАВЛЕНИЕ':U
    fmin when par-mode = 'ДОБАВЛЕНИЕ':U
    fsec when par-mode = 'ДОБАВЛЕНИЕ':U
    tt-chk-doc.cash-rate when par-mode = 'ДОБАВЛЕНИЕ':U
    tt-chk-doc.chk-date when par-mode = 'ДОБАВЛЕНИЕ':U
    tt-chk-doc.chk-type when par-mode = 'ДОБАВЛЕНИЕ':U
    tt-chk-doc.src-shift-date  when (get-chkc_context.cas-shft and not  get-chkc_context.SHiFT-on)
    tt-chk-doc.shift-name when (get-chkc_context.cas-shft and not  get-chkc_context.SHiFT-on)
    with frame Dialog-Frame
    .
end.
END PROCEDURE.
PROCEDURE MyEnable :
define variable var-dopi as integer no-undo.
 tt-chk-doc.chk-type:Radio-buttons in frame Dialog-Frame =
 "Инкассация" + chr(44) + string('2':U) + chr(44) +
 "Касс_фонд" + chr(44) + string('3':U) + chr(44) +
 "Перевод_опл" + chr(44) + string('4':U) + chr(44) +
 "Расход_кассы" + chr(44) + string('5':U) + chr(44) +
 "Декл_ден_ящ" + chr(44) + string('7':U)
 .
if get-chkc_context.cas-curs then
assign
tt-chk-pay.cash-rate:READ-ONLY IN BROWSE BR-lines = no
tt-chk-pay.bank-rate:READ-ONLY IN BROWSE BR-lines = no
tt-chk-pay.bank-scale:READ-ONLY IN BROWSE BR-lines = no
.
else
assign
tt-chk-pay.cash-rate:READ-ONLY IN BROWSE BR-lines = yes
tt-chk-pay.bank-rate:READ-ONLY IN BROWSE BR-lines = yes
tt-chk-pay.bank-scale:READ-ONLY IN BROWSE BR-lines = yes
.
assign
fhour = (tt-chk-doc.chk-time - tt-chk-doc.chk-time MODULO 3600) / 3600
var-dopi = tt-chk-doc.chk-time MODULO 3600
fmin =  (var-dopi - var-dopi modulo 60) / 60
var-dopi = var-dopi modulo 60
fsec = (var-dopi - var-dopi modulo 60) / 60
.
IF AVAILABLE tt-chk-doc THEN
DISPLAY
fhour
fmin
fsec
tt-chk-doc.cash-rate
tt-chk-doc.cash-scale
tt-chk-doc.chk-date
tt-chk-doc.obj-code
tt-chk-doc.chk-type
tt-chk-doc.src-shift-date
tt-chk-doc.shift-date
tt-chk-doc.pay-desk
tt-chk-doc.shift-num
tt-chk-doc.shift-name
tt-chk-doc.cashier
tt-chk-doc.z-number
tt-chk-doc.chk-num
tt-chk-doc.ps
WITH FRAME Dialog-Frame .
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  ASSIGN
  tt-chk-pay.cash-rate:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.bank-rate:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.bank-scale:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.pay-code:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.curr-code:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.doc-qnty:visible IN BROWSE BR-lines = no
  tt-chk-pay.par-val:visible IN BROWSE BR-lines = no
  tt-chk-pay.par-code:visible IN BROWSE BR-lines = no
  .
  ENABLE
  B-exit
  b-quit
  B-Help
  B-add
  B-del
  fhour
  fmin
  fsec
  tt-chk-doc.cash-rate when cas-curs
  tt-chk-doc.chk-date
  tt-chk-doc.chk-type
  tt-chk-doc.src-shift-date  when (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
  b-cd
  tt-chk-doc.shift-name  when (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
  tt-chk-doc.cashier
  tt-chk-doc.z-number
  tt-chk-doc.chk-num
  BR-lines
  tt-chk-doc.ps
  WITH FRAME Dialog-Frame.
  hide b-hist
  in frame Dialog-Frame.
  end.
  if par-mode = 'ИЗМЕНЕНИЕ':U then do:
    assign
    tt-chk-pay.src-qnty:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.src-val:READ-ONLY IN BROWSE BR-lines = yes
    .
    ENABLE
    b-quit
    B-exit
    B-Help
    b-hist
    BR-lines
    tt-chk-doc.src-shift-date  when (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
    tt-chk-doc.shift-name when (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
    tt-chk-doc.ps
    tt-chk-doc.z-number
    WITH FRAME Dialog-Frame .
  end.
  if par-mode = 'ПРОСМОТР':U then do:
    ASSIGN
    tt-chk-pay.tot-sum:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.cash-rate:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.bank-rate:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.bank-scale:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.pay-code:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.curr-code:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.src-qnty:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.src-val:READ-ONLY IN BROWSE BR-lines = yes
    .
    b-quit:label = "&Выход".
    ENABLE
    b-quit
    B-Help
    b-next
    b-prev
    b-hist
    BR-lines
    WITH FRAME Dialog-Frame .
    HIDE
    b-exit
    in frame Dialog-Frame.
  end.
VIEW FRAME Dialog-Frame .
run control-line in this-procedure ( output locked-title).
run lock-proc in this-procedure ( locked-title).
if not cas-shft then do:
  hide
  tt-chk-doc.src-shift-date
  tt-chk-doc.shift-num
  tt-chk-doc.shift-name
  in frame Dialog-Frame.
end.
OPEN QUERY BR-lines FOR EACH locked_chk-pay NO-LOCK WHERE        locked_chk-pay.doc-code = tt-chk-doc.doc-code,            FIRST tt-chk-pay WHERE         tt-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-chk-pay.line-num = locked_chk-pay.line-num.
IF ERROR-STATUS:ERROR THEN DO:
  REPOSITION br-lines TO ROW 1 NO-ERROR.
END.
APPLY "ENTRY":U TO br-lines IN FRAME Dialog-Frame.
APPLY "VALUE-CHANGED" to br-lines in frame Dialog-Frame .
ASSIGN
frame Dialog-Frame:title = if par-mode = 'ДОБАВЛЕНИЕ':U
                            then substitute("ЧЕК № &1"
                                      ,tt-chk-doc.doc-code)
                          else (
                          substitute("ЧЕК № &1 Дата: &2 Время: &3"
                                      ,tt-chk-doc.doc-code
                                      ,tt-chk-doc.chk-date
                                      ,string (tt-chk-doc.chk-time, "HH:MM")) +
                          if (cas-shft OR T-SHFT <> 0)
                          then substitute(" Смена от &1 N смены &2&3"
                                          ,string(tt-chk-doc.src-shift-date, "99/99/9999")
                                          ,tt-chk-doc.shift-name
                                          , (if integer(tt-chk-doc.shift-name) = tt-chk-doc.shift-num
                                              then '':U
                                              else string(tt-chk-doc.shift-num, "(>9)"))
                                          )
                          else substitute("Дата учета &1", string(tt-chk-doc.shift-date)))
.
END PROCEDURE.
PROCEDURE proc-b-add :
define variable ii as integer no-undo.
DEFINE VARIABLE var-rid as recid no-undo.
DEFINE VARIABLE rid-list as character no-undo.
define variable par-rid-list as character no-undo .
DEFINE VARIABLE varopl-curs as decimal no-undo .
DEFINE VARIABLE varbase-curs as decimal no-undo .
define buffer count_chk-pay for ub.chk-pay.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_wealth FOR ub.wealth.
DEFINE BUFFER loc_tt-chk-pay FOR tt-chk-pay.
define buffer buf_wth-par for ub.wth-par.
if not par-mode = 'ДОБАВЛЕНИЕ':U then return.
rid-list = "" .
run proc-save-doc ( INPUT CAN-FIND (FIRST tt-chk-pay WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code)
                   ,INPUT NO) No-ERROR.
if error-status:error then return error.
run ref/cashpays.w (
             input parparentproc
            ,input "b-mark,b-sel":U
            ,input 'все':U
            ,input get-chkc_context.host-code
            ,input locked_chk-doc.obj-type
            ,input locked_chk-doc.obj-code
            ,output rid-list ) .
IF rid-list = '':U THEN UNDO, RETURN ERROR.
ii = 1.
find last count_chk-pay No-LOCK WHERE
                count_chk-pay.doc-code = tt-chk-doc.doc-code  use-index ln No-ERROR.
if available count_chk-pay then lnp = count_chk-pay.line-num.
ELSE lnp = 0.
 _ii:
 DO WHILE (ii <= num-entries(rid-list) )
 on error undo _ii, next _ii
 :
  FIND FIRST buf_cash-pay WHERE recid( buf_cash-pay ) = integer( entry(ii, rid-list ) ) NO-LOCK .
  if buf_cash-pay.wth-code = 0 then do:
    message
    substitute("Выбранному типу кассового платежа с кодом &1 и кодом валюты &2 не соответствует ни одна МЦ!"
               , buf_cash-pay.cdpay-code
               , buf_cash-pay.curr-code)
    view-as alert-box ERROR.
    ii = ii + 1.
    UNDO _ii, NEXT _ii.
  end.
  FIND FIRST buf_wealth No-LOCK WHERE
                   buf_wealth.wth-code = buf_cash-pay.wth-code No-ERROR.
  if not avail buf_wealth then do:
    message
    substitute("Не найдена МЦ с кодом &1",buf_cash-pay.wth-code)
    view-as alert-box ERROR.
    ii = ii + 1.
    UNDO _ii, NEXT _ii.
  end.
  if buf_wealth.get-qnty-method = '=val-qnty':U then do:
    par-rid-list = ''.
    if available buf_wth-par then release buf_wth-par.
    run ref/wthp-ref.w (
                        input parparentproc
                       ,input "b-sel,b-mark"
                       ,input get-chkc_context.host-code
                       ,input tt-chk-doc.obj-type
                       ,input tt-chk-doc.obj-code
                       ,input 'МЦ':U
                       ,input buf_wealth.wth-code
                       ,input-output par-rid-list ) no-error.
    if par-rid-list = '' then do:
      ii = ii + 1.
      undo _ii, next _ii.
    end.
    find first buf_wth-par no-lock where
              recid(buf_wth-par) = integer(par-rid-list) no-error.
    if not available buf_wth-par then do:
      message
      substitute("Не найдена номинал для МЦ с кодом &1", buf_cash-pay.wth-code)
      view-as alert-box ERROR.
      ii = ii + 1.
      undo _ii, next _ii.
    end.
  end.
  assign
  lnp = lnp + 1
  .
  CREATE tt-chk-pay.
  ASSIGN
  tt-chk-pay.doc-code = tt-chk-doc.doc-CODE
  tt-chk-pay.line-num = lnp
  tt-chk-pay.pay-code = buf_cash-pay.cdpay-code
  tt-chk-pay.curr-code = buf_cash-pay.curr-code
  tt-chk-pay.wth-code = buf_cash-pay.wth-code
  tt-chk-pay.obj-code = tt-chk-doc.obj-code
  tt-chk-pay.obj-type = tt-chk-doc.obj-type
  tt-chk-pay.time-oper = tt-chk-doc.chk-time
  tt-chk-pay.tot-sum = 0
  tt-chk-pay.cash-rate = 0
  tt-chk-pay.bank-rate = 0
  tt-chk-pay.bank-scale = 0
  tt-chk-pay.src-qnty = 0
  tt-chk-pay.doc-qnty = 0
  tt-chk-pay.src-val = (if available buf_wth-par then buf_wth-par.par-val else 0)
  tt-chk-pay.par-val = 0
  tt-chk-pay.par-code = 0
  var-rid = (IF var-rid = ? THEN RECID(tt-chk-pay) ELSE var-rid)
  .
  create locked_chk-pay.
  buffer-copy tt-chk-pay to locked_chk-pay
  .
  run trg/chkins02.p (
                  input  tt-chk-doc.doc-code
                 ,input  1
                 ,input  tt-chk-doc.chk-type
                 ,input  tt-chk-doc.obj-type
                 ,input  tt-chk-doc.obj-code
                 ,input  tt-chk-doc.chk-date
                 ,input  tt-chk-doc.chk-time
                 ,input  buf_cash-pay.cdpay-code
                 ,input  buf_cash-pay.curr-code
                 ,input  get-chkc_context.base-code
                 ,input  get-chkc_context.r-b
                 ,input  get-chkc_context.cas-curs
                 ,input-output  tt-chk-pay.cash-rate
                 ,input-output  tt-chk-pay.bank-rate
                 ,input-output  tt-chk-pay.bank-scale
                 ,input  recid(locked_chk-pay)
                 ,output varbase-curs
                 ,output varopl-curs
                 ,output tt-chk-pay.par-code
               ) no-error.
    if error-status:error then do:
      var-rid = ?.
      delete tt-chk-pay.
      run control-line in THIS-PROCEDURE ( output locked-title).
      run lock-proc in THIS-PROCEDURE ( INPUT locked-title).
      ii = ii + 1.
      UNDO _ii, NEXT _ii.
    end.
    run control-line in THIS-PROCEDURE ( output locked-title).
    run lock-proc in THIS-PROCEDURE ( INPUT locked-title).
  ii = ii + 1.
END.
OPEN QUERY BR-lines FOR EACH locked_chk-pay NO-LOCK WHERE        locked_chk-pay.doc-code = tt-chk-doc.doc-code,            FIRST tt-chk-pay WHERE         tt-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-chk-pay.line-num = locked_chk-pay.line-num.
find first loc_tt-chk-pay WHERE
           loc_tt-chk-pay.doc-code = tt-chk-doc.doc-code AND
           loc_tt-chk-pay.tot-sum = 0 NO-LOCK NO-ERROR.
IF avail loc_tt-chk-pay then do:
  reposition br-lines to recid var-rid NO-ERROR.
end.
apply "entry" to br-lines in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-save-doc :
DEFINE INPUT PARAMETER parlines-exist as logical no-undo.
define input parameter par-check-lines as logical no-undo .
DEFINE VARIABLE var-rid as recid no-undo.
define variable var-chk-type as character no-undo.
DEFINE VARIABLE varline-rid as recid no-undo .
define buffer check_chk-pay for ub.chk-pay .
DEFINE BUFFER buf-tt-chk-pay FOR tt-chk-pay.
do
on error undo, return ERROR return-value
:
assign
frame Dialog-Frame fhour
frame Dialog-Frame fmin
frame Dialog-Frame fsec
.
if par-mode = 'ИЗМЕНЕНИЕ':U then
run trg/chk-doch.p (
                 buffer locked_chk-doc
              , input no
              , input no
              , input no
              , input-output v-chip-num
              , output v-is-update).
assign
tt-chk-doc.cash-rate
tt-chk-doc.cashier
tt-chk-doc.chk-date
tt-chk-doc.chk-num
tt-chk-doc.chk-time = fhour * 3600 + fmin * 60 + fsec * 60
tt-chk-doc.chk-type
tt-chk-doc.obj-code
tt-chk-doc.pay-desk
tt-chk-doc.ps
tt-chk-doc.src-shift-date
tt-chk-doc.shift-num
tt-chk-doc.shift-name
tt-chk-doc.z-number
.
buffer-copy tt-chk-doc
except
discnt
correct
cashier-psn-code
out-code
to locked_chk-doc
assign
locked_chk-doc.correct = yes
.
display tt-chk-doc.ps
with frame Dialog-Frame .
assign
locked_chk-doc.correct = yes
.
display tt-chk-doc.ps
with frame Dialog-Frame .
for each buf-tt-chk-pay no-lock where
         buf-tt-chk-pay.doc-code = tt-chk-doc.doc-code,
    first locked_chk-pay where
          locked_chk-pay.doc-code = buf-tt-chk-pay.doc-code
     AND  locked_chk-pay.line-num = buf-tt-chk-pay.line-num:
  assign
  locked_chk-pay.pay-code = buf-tt-chk-pay.pay-code
  locked_chk-pay.curr-code = buf-tt-chk-pay.curr-code
  locked_chk-pay.tot-sum       = buf-tt-chk-pay.tot-sum
  locked_chk-pay.wth-code  = buf-tt-chk-pay.wth-code
  locked_chk-pay.cash-rate  = buf-tt-chk-pay.cash-rate
  locked_chk-pay.bank-rate  = buf-tt-chk-pay.bank-rate
  locked_chk-pay.bank-scale  = buf-tt-chk-pay.bank-scale
  locked_chk-pay.src-qnty = buf-tt-chk-pay.src-qnty
  locked_chk-pay.src-val = buf-tt-chk-pay.src-val
  .
END.
end.
END PROCEDURE.
PROCEDURE reposition-chk-doc :
define input parameter p-direction as character no-undo .
define variable v-new-chk-doc-recid as recid no-undo .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-chk-doc in p-call-prog
      (input  p-direction
      ,output v-new-chk-doc-recid
      ).
    if v-new-chk-doc-recid <> ?
    then do:
      define buffer buf_chk-doc for ub.chk-doc .
      find first buf_chk-doc no-lock
        where recid(buf_chk-doc) = v-new-chk-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-chk-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список чеков не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.
PROCEDURE sel-cd :
define variable ri-list as character no-undo .
define variable glog as logical no-undo .
define buffer loc_cash-desk  for ub.cash-desk.
run ref/cashlist.w
    (input  parparentproc
    ,input  'b-sel':U
    ,input  'объект':U
    ,input  get-chkc_context.db-num
    ,input  get-chkc_context.host-code
    ,input  'маг':U
    ,input  shop-code
    ,input  ?
    ,output ri-list
    ) no-error.
if ri-list = '' then do:
  undo, return error .
end.
FIND FIRST loc_cash-desk No-LOCK WHERE
          recid(loc_cash-desk) = integer(ri-list) no-error.
if not available loc_cash-desk then do:
  undo, return error .
end.
if loc_cash-desk.autonomy = integer('2':U) then do:
  message
  "Нельзя создать чек для КАССОВОГО МЕНЕДЖЕРА!"
  view-as alert-box error.
  undo, return error .
end.
if loc_cash-desk.pos-type <> dflt-cd then do:
  message
  substitute("На &1&2 установлен тип кассы по умолчанию - &3&4" +
            "Вы уверены, что хотите создать чек для кассы с типом &5?"
            , 'маг':U
            , shop-code
            , dflt-cd
            , chr(10)
            , loc_cash-desk.pos-type)
  view-as alert-box question buttons yes-no update glog.
  if not glog then undo, return error .
end.
find first buf_cash-desk no-lock where
          recid(buf_cash-desk) = recid(loc_cash-desk).
END PROCEDURE.
PROCEDURE write-log-and-file :
define input parameter p-tab-position   as integer   no-undo.
define input parameter p-file-name      as character no-undo .
define input parameter p-log-level      as integer no-undo .
define input parameter p-log-string     as character no-undo .
message
p-log-string
view-as alert-box error .
END PROCEDURE.
FUNCTION get-cash-pay RETURNS CHARACTER
  ( input parpay-code as integer, parcurr-code as integer, OUTPUT p-wth-code AS INTEGER ) :
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_wealth FOR ub.wealth.
FIND FIRST buf_cash-pay No-LOCK WHERE
         buf_cash-pay.cdpay-code = parpay-code
    AND buf_cash-pay.curr-code = parcurr-code No-ERROR.
if available buf_cash-pay then do:
  varwth-code = buf_cash-pay.wth-code.
  p-wth-code = varwth-code.
  if varwth-code > 0 then do:
      FIND FIRST buf_wealth No-LOCK WHERE
                      buf_wealth.wth-code = varwth-code No-error.
      if available buf_wealth then do:
        assign
        varwth-code = buf_wealth.wth-code
        varwth-name = buf_wealth.wth-name
        p-wth-code = varwth-code
        .
        return buf_cash-pay.obj-name.
      end.
      else do:
        assign
        varwth-code = 0
        varwth-name = "Неопознанная МЦ"
        p-wth-code = varwth-code
        .
        RETURN buf_cash-pay.obj-name.
      end.
  end.
  else do:
    assign
    varwth-code = 0
    varwth-name = "Неопознанная МЦ"
    p-wth-code = varwth-code
    .
    RETURN buf_cash-pay.obj-name .
  end.
end.
assign
varwth-code = 0
varwth-name = '':U
p-wth-code = varwth-code
.
RETURN "Неопознанная оплата".
END FUNCTION.
