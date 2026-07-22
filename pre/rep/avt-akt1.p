block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter prod-price           as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: avt-akt1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/avt-akt1.p $":U .
define variable vss-description as character no-undo init "Печать акта формирования продажной цены".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
def buffer t-doc for trn-doc.
def temp-table t-doc-line no-undo like doc-line.
define variable sum-no-NDS              as decimal     no-undo.
define variable doc-sum                 as decimal     no-undo.
define variable obj-sum                 as decimal     no-undo.
define variable v-tax-sum               as decimal     no-undo.
define variable SLT-sum                 as decimal     no-undo.
define variable VAT-sum                 as decimal     no-undo.
define variable VAT-gds                 as decimal     no-undo.
define variable VAT-gds-pc              as decimal     no-undo.
define variable VAT-prod                as decimal     no-undo.
define variable marg                    as decimal     no-undo.
define variable price-doc               as decimal     no-undo.
define variable price-lst               as decimal     no-undo.
define variable v-sum-sale              as decimal     no-undo.
define variable v-sum-cost-without-vat  as decimal     no-undo.
define variable v-nids                  as character   no-undo.
define variable v-parameter-type        as character   no-undo.
define variable v-vat-pc        like doc-line.vat-pc    no-undo.
define variable v-slt-pc        like doc-line.slt-pc    no-undo.
define variable v-host-code     like sysconf.host-code  no-undo.
define variable propis          as character        no-undo.
define variable abbr            as character        no-undo.
define variable UpFact          as character        no-undo.
define variable Delt            as character        no-undo.
define variable Lines_Counter   as integer          no-undo.
define variable Line            as character        no-undo.
define variable sym1       as character init ":"    no-undo.
define variable sym2       as character init ":"    no-undo.
define variable tb-code    as character             no-undo.
define variable tdoc-date  like    trn-doc.doc-date no-undo.
define variable tdoc-code  like trn-doc.doc-code    no-undo.
define variable v-curr-r-b as character         no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def buffer Our_Host for clients.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
DEFINE FRAME Akt
        sym1 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! " format "x(10)"
        gds-dtl.artic column-label "Артикул! " format "X(16)"
        goods.gds-name column-label "Название товара! " format "X(20)"
        gds-dtl.fact-qnty column-label "Количество ! " format ">>>>>>9.<<<"
        price-doc column-label "Цена без!НДС" format ">>>>>>9.99"
        sum-no-NDS column-label "Сумма без!НДС" format "->>>>>>>>9.99"
        VAT-prod column-label "НДС по!докум." format "->>>>>>>9.99"
        doc-sum column-label "Сумма по!докум." format "->>>>>>>>9.99"
        price-lst column-label "Цена по!объекту" format ">>>>>>9.99"
        obj-sum column-label "Сумма по!объекту" format "->>>>>>>>9.99"
        UpFact column-label "Торговая!наценка" format "X(8)"
        Delt column-label "Процент!разницы" format "X(8)"
        t-doc-line.vat-pc column-label "Ставка!НДС" format ">>9.<<%"
        VAT-sum column-label "Сумма НДС от!прод.цен" format "->>>>>>>>9.99" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
    HEADER
            cur-time-print() AT 5 format "X(35)"
            string( "Акт формирования прод. цены по документу N " + tdoc-code + " от " + string( tdoc-date,"99/99/9999" ) ) AT 40 format "X(80)"
            string( (if prod-price then "(Прод. цена на момент печати)" else "" ) ) AT 125 format "X(35)"
            string( "Страница " + string(PAGE-NUMBER) ) AT 164 format "X(15)" SKIP
        Line format "X(180)" AT 1
    with width 235 stream-io.
Line = fill("-", 200).
FIND t-doc WHERE recid(t-doc) = rec_id  NO-LOCK.
define variable FullGdsName as logical   no-undo .
define variable tmp-var  as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input t-doc.obj-type
  ,input t-doc.obj-code
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
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .
assign
    tdoc-date = IF t-doc.fact-date = ? THEN t-doc.doc-date ELSE t-doc.fact-date
    tdoc-code    = t-doc.doc-code
.
FIND Our_Host WHERE Our_Host.obj-type = 'орг':U AND
                                        Our_Host.obj-code = t-doc.host-code NO-LOCK.
output     to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
PUT SPACE(90) Our_Host.obj-name format "x(40)" SKIP(2)
        SPACE(20) "А К Т  формирования продажной цены по документу  N " format "x(80)"
        t-doc.doc-code format "X(10)"
        "  от  " t-doc.doc-date format "99.99.9999" SKIP(1).
if t-doc.doc-type = 'при':U
and not t-doc.internal
then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'nids':U ,
                       output v-nids ,
                       output v-parameter-type )  .
    if v-nids <> ""
    and v-nids <> ?
    then do:
        put
                    space(20)   "Основание: накладная поставщика N: "
                                v-nids format "x(110)"
            skip(1)
        .
    end.
end.
if t-doc.doc-type = 'при':U OR
   ( t-doc.ext-doc-type = 'ep':U ) OR
   ( t-doc.doc-type = 'рас':U AND ( NOT t-doc.internal ) ) then
    do:
        PUT SPACE(20) string( "ПОСТАВЩИК : " + t-doc.cli-name ) format "x(90)" SKIP(1) .
    end.
FORM HEADER
    Line format "X(180)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width 235 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW FRAME BottomFrame .
FOR EACH doc-line WHERE doc-line.doc-code = t-doc.doc-code NO-LOCK ,
        EACH gds-dtl WHERE gds-dtl.doc-code = t-doc.doc-code AND
                                            gds-dtl.prod-type = doc-line.prod-type AND
                                            gds-dtl.prod-code = doc-line.prod-code AND
                                            gds-dtl.artic = doc-line.artic NO-LOCK,
        EACH goods WHERE goods.prod-type = gds-dtl.prod-type AND
                                           goods.prod-code = gds-dtl.prod-code AND
                                           goods.artic = gds-dtl.artic NO-LOCK
            BREAK BY gds-dtl.artic BY gds-dtl.prt-code with FRAME Akt :
       FOR EACH t-doc-line :
          delete t-doc-line.
       END.
       CREATE t-doc-line.
       BUFFER-COPY doc-line TO t-doc-line.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  doc-line.obj-type
  ,input  doc-line.obj-code
  ,output v-host-code
  )  .
       FIND bar-code WHERE bar-code.gds-code = goods.gds-code
                       AND bar-code.unit-cli = goods.unit-base
                       AND bar-code.node-code = gds-dtl.prt-code
                       AND bar-code.part-code = ""
                       AND bar-code.in-code = ""
                           NO-LOCK no-error.
        if prod-price = yes
        then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
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
                assign price-lst = gp-price-sale.
            end.
        else do:
            assign price-lst = gds-dtl.cur-base.
        end.
        if t-doc.doc-type = 'при':U
        then do:
assign
  price-rubl-with-tax-loc = doc-line.price-rubl
  price-base-with-tax-loc = doc-line.price-base
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
            if road-tax-rubl-loc = ? then assign road-tax-rubl-loc = 0.
            if road-tax-base-loc = ? then assign road-tax-base-loc = 0.
            assign
                price-doc = ( if v-curr-r-b = 'base':U
                              then ( price-base-with-tax-loc - vat-base-loc )
                              else ( price-rubl-with-tax-loc - vat-rubl-loc ) )
                v-tax-sum = ( if v-curr-r-b = 'base':U
                              then road-tax-base-loc
                              else road-tax-rubl-loc )
            .
        end.
        else do:
            if v-curr-r-b = 'base':U
            then do:
                assign
                    price-doc = gds-dtl.price-base - (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - ub.doc-line.road-tax * 1 - (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - ub.doc-line.road-tax * 1)                           * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc))                           * ub.doc-line.VAT-pc / (100 + ub.doc-line.VAT-pc)
                .
            end.
            else do:
                assign
                    price-doc = gds-dtl.price-rubl - (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - ub.doc-line.road-tax * 1 - (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - ub.doc-line.road-tax * 1)                           * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc))                           * ub.doc-line.VAT-pc / (100 + ub.doc-line.VAT-pc)
                .
            end.
        end.
        if prod-price = yes
        then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  doc-line.obj-type
  ,input  doc-line.obj-code
  ,output Vat-gds-pc
  ) no-error .
        end.
        else do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '1':U
  ,input  t-doc.fact-date
  ,input  v-host-code
  ,input  doc-line.obj-type
  ,input  doc-line.obj-code
  ,output Vat-gds-pc
  ) no-error .
        end.
        assign
            Vat-gds     = ( price-lst - (price-lst - ub.doc-line.road-tax * 1) * t-doc-line.SLT-pc / (100 + t-doc-line.SLT-pc) - v-tax-sum) * Vat-gds-pc / ( 100 + Vat-gds-pc )
            Vat-prod    = ( gds-dtl.fact-qnty * ( if v-curr-r-b = 'base':U then gds-dtl.price-base else gds-dtl.price-rubl ) )
                            - ( gds-dtl.fact-qnty * price-doc )
            marg        = price-lst - price-doc - Vat-gds - (price-lst - ub.doc-line.road-tax * 1) * t-doc-line.SLT-pc / (100 + t-doc-line.SLT-pc)
        .
        ACCUMULATE
            bar-code.b-code ( COUNT )
            gds-dtl.fact-qnty ( TOTAL )
            marg * gds-dtl.fact-qnty ( TOTAL )
            gds-dtl.fact-qnty * (price-lst - ub.doc-line.road-tax * 1) * t-doc-line.SLT-pc / (100 + t-doc-line.SLT-pc) ( TOTAL )
            gds-dtl.fact-qnty * VAT-gds ( TOTAL )
            ( gds-dtl.fact-qnty * price-lst ) ( TOTAL )
            ( gds-dtl.fact-qnty * price-doc ) ( TOTAL )
        .
        if v-curr-r-b = 'base':U
        then do:
            ACCUMULATE
                ( gds-dtl.fact-qnty * gds-dtl.price-base ) ( TOTAL )
                ( ( price-lst - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ( TOTAL )
            .
        end.
        else do:
            ACCUMULATE
                ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ( TOTAL )
                ( ( price-lst - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ( TOTAL )
            .
        end.
        assign
             delt = ( if v-curr-r-b = 'base':U
                      then string( ( price-lst - gds-dtl.price-base ) / gds-dtl.price-base * 100, "->>>9.9" )
                      else string( ( price-lst - gds-dtl.price-rubl ) / gds-dtl.price-rubl * 100, "->>>9.9" )
                    ) + "%"
        .
        DISPLAY sym1
                trim( string( bar-code.b-code ) ) @ tb-code
                gds-dtl.artic
                goods.gds-name
                gds-dtl.fact-qnty
                price-doc
                ( gds-dtl.fact-qnty * price-doc ) @ sum-no-NDS
                VAT-prod
                ( gds-dtl.fact-qnty * ( if v-curr-r-b = 'base':U then gds-dtl.price-base else gds-dtl.price-rubl ) ) @ doc-sum
                price-lst
                ( gds-dtl.fact-qnty * price-lst ) @ obj-sum
                t-doc-line.vat-pc
                ( gds-dtl.fact-qnty * VAT-gds ) @ VAT-sum
                string( string( marg / price-doc * 100, "->>>9.9" ) + "%" ) @ UpFact
                Delt
                sym2
        .
        IF LENGTH(goods.gds-name, "CHARACTER") > 20 and FullGdsName THEN  do:
          assign propis = SUBSTRING(goods.gds-name,21) .
          DOWN 1 .
          DISPLAY sym1 propis @ goods.gds-name  sym2     .
        end.
        if LAST( gds-dtl.artic ) then
            do:
                DOWN 1 .
                PUT Line format "X(180)" SKIP .
                assign
                    v-sum-cost-without-vat = ACCUM TOTAL ( gds-dtl.fact-qnty * price-doc )
                    v-sum-sale             = ACCUM TOTAL ( gds-dtl.fact-qnty * price-lst )
                .
                assign
                    Delt = ( if v-curr-r-b = 'base':U
                            then string( ( ACCUM TOTAL ( ( price-lst - gds-dtl.price-base ) * gds-dtl.fact-qnty ) )
                                       / ( ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-base ) ) * 100, "->>>9.9" ) + "%"
                            else string( ( ACCUM TOTAL ( ( price-lst - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) )
                                       / ( ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ) * 100, "->>>9.9" ) + "%"
                           )
                .
                DISPLAY "  ИТОГО"    @ goods.gds-name
                    ACCUM TOTAL gds-dtl.fact-qnty @ gds-dtl.fact-qnty
                    ACCUM TOTAL ( gds-dtl.fact-qnty * price-doc )   @ sum-no-NDS
                    ( if v-curr-r-b = 'base':U
                      then ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-base )
                      else ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-rubl )
                    )                                               @ doc-sum
                    ACCUM TOTAL ( gds-dtl.fact-qnty * price-lst ) @ obj-sum
                    ACCUM TOTAL ( gds-dtl.fact-qnty * VAT-gds ) @ VAT-sum
                    string( string( ( ACCUM TOTAL ( marg * gds-dtl.fact-qnty ) ) /
                                           ( ACCUM TOTAL ( gds-dtl.fact-qnty * price-doc ) ) * 100, "->>>9.9" ) + "%" )
                                    @ UpFact
                    Delt .
                UNDERLINE goods.gds-name gds-dtl.fact-qnty sum-no-NDS obj-sum UpFact .
                DOWN 2 .
            end.
END.
HIDE FRAME BottomFrame .
if v-curr-r-b = 'base':U
then do:
    run rep/wp.p ( input p-mainmenu-handle, input absolute( ACCUM TOTAL ( marg * gds-dtl.fact-qnty ) ), output propis, output abbr ) .
end.
else do:
    run rep/wp-rub.p ( input absolute( ACCUM TOTAL ( marg * gds-dtl.fact-qnty ) ), output propis, output abbr ) .
end.
PUT SPACE(10) "Всего  " ( ACCUM COUNT bar-code.b-code ) format ">>>>9"
    " наименований." format "X(15)"
    SKIP(1)
    SPACE(10)
    string( "Сумма цен по объекту составила : "
               + trim( string( ACCUM TOTAL ( gds-dtl.fact-qnty * price-lst ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
               + ", в том числе налог с продаж : "
               + trim( string( ACCUM TOTAL ( gds-dtl.fact-qnty * (price-lst - ub.doc-line.road-tax * 1) * t-doc-line.SLT-pc / (100 + t-doc-line.SLT-pc) ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
               + ", НДС : "
               + trim( string( ACCUM TOTAL ( gds-dtl.fact-qnty * VAT-gds ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
              ) format "X(126)"
    skip(1)
    space(10) "Разница между суммой в продажных ценах по объекту и суммой в ценах документа без НДС составила: "
               + trim( string( v-sum-sale - v-sum-cost-without-vat, "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
                                                        format "X(126)"
    skip(1)
    space(10) string( "Торговая наценка составила : "
               + trim( string( ACCUM TOTAL ( marg * gds-dtl.fact-qnty ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
              ) format "X(126)"
    SKIP(1)
    .
if line-counter + 4 > page-size then
    PAGE .
PUT SPACE(10)
        ( if trim(propis) begins trim( abbr ) then string( "0 " + propis ) else propis )
        format "X(120)" SKIP(2).
PUT SPACE(20) "Зав. складом/Зав. секцией : " format "X(30)" SKIP.
output CLOSE.
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
