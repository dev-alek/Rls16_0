block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter p-mode               as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$date: 12.09.03 15:57 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: avt-akt0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/avt-akt0.p $":U .
define variable vss-description as character no-undo init "Печать акта автоматической переоценки".
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
def buffer t-doc for trn-doc.
define variable price-doc           as decimal      no-undo.
define variable doc-sum             as decimal      no-undo.
define variable obj-sum             as decimal      no-undo.
define variable propis              as character    no-undo.
define variable abbr                as character    no-undo.
define variable Delt                as character    no-undo.
define variable v-single-line       as character    no-undo.
define variable sym1                as character init ":"    no-undo.
define variable sym2                as character init ":"    no-undo.
define variable tb-code             as character             no-undo.
define variable tdoc-date           as date         no-undo.
define variable tdoc-code           as character    no-undo.
define variable v-nids              as character    no-undo.
define variable v-parameter-type    as character    no-undo.
define variable v-rb-is-base        as logical      no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
def buffer Our_Host for clients.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
define frame Akt-base
        sym1 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! " format "x(10)"
        gds-dtl.artic column-label "Артикул! " format "X(16)"
        goods.gds-name column-label "Название товара! " format "X(30)"
        gds-dtl.fact-qnty column-label "Количество  ! " format "->>>>>>9.<<<"
        price-doc column-label "Цена по!докум.(Вал)" format ">>>>>>9.99"
        doc-sum column-label "Сумма по!докум.(Вал)" format "->>>>>>>>9.99"
        gds-dtl.cur-base column-label "Цена по!объекту(Вал)" format ">>>>>>9.99"
        obj-sum column-label "Сумма цен по!объекту(Вал)" format "->>>>>>>>9.99"
        Delt column-label "Процент!разницы" format "X(8)"
        sym2 column-label ":!:" format "X(1)" space(0)
    header
            cur-time-print() at 5 format "X(35)"
            string( "Акт автоматической переоценки по документу N " + tdoc-code + " от " + string( tdoc-date,"99/99/9999" ) ) at 40 format "X(80)"
            string( "Страница " + string(PAGE-NUMBER) ) at 120 format "X(15)" skip
        v-single-line format "X(136)" at 1
with width 235 down stream-io .
define frame Akt-rubl
        sym1 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! " format "x(10)"
        gds-dtl.artic column-label "Артикул! " format "X(16)"
        goods.gds-name column-label "Название товара! " format "X(30)"
        gds-dtl.fact-qnty column-label "Количество  ! " format "->>>>>>9.<<<"
        price-doc column-label "Цена по!докум.(Руб)" format ">>>>>>9.99"
        doc-sum column-label "Сумма по!докум.(Руб)" format "->>>>>>>>9.99"
        gds-dtl.cur-base column-label "Цена по!объекту(Руб)" format ">>>>>>9.99"
        obj-sum column-label "Сумма цен по!объекту(Руб)" format "->>>>>>>>9.99"
        Delt column-label "Процент!разницы" format "X(8)"
        sym2 column-label ":!:" format "X(1)" space(0)
    header
            cur-time-print() at 5 format "X(35)"
            string( "Акт автоматической переоценки по документу N " + tdoc-code + " от " + string( tdoc-date,"99/99/9999" ) ) at 40 format "X(80)"
            string( "Страница " + string(PAGE-NUMBER) ) at 120 format "X(15)" skip
        v-single-line format "X(136)" at 1
with width 235 down stream-io .
output     to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
v-single-line = fill("-", 200).
find first t-doc no-lock
     where recid(t-doc) = rec_id
.
define variable FullGdsName as logical   no-undo .
define variable tmp-var  as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    tdoc-date   = t-doc.doc-date
    tdoc-code   = t-doc.doc-code
.
find first Our_Host no-lock
     where Our_Host.obj-type = 'орг':U
       and Our_Host.obj-code = t-doc.host-code
.
put
    space(90) Our_Host.obj-name format "x(40)"
    skip(2) space(20) "А К Т   П Е Р Е О Ц Е Н К И   ( автоматической ) по документу  N " format "x(80)"
        t-doc.doc-code format "X(10)"
        "  от  " t-doc.doc-date format "99.99.9999" skip(1)
.
if lookup( "ParCom":U, p-mode ) <> 0
then do:
    if t-doc.doc-type = 'при':U
    and not t-doc.internal
    then do:
        put
            substitute( "Основание: накладная поставщика N &1 от &2"
                        , t-doc.ord-num
                        , string( t-doc.ship-date, "99.99.9999" )
            )   format "x(110)"
            skip(1)
        .
    end.
end.
else do:
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
end.
if t-doc.doc-type = 'при':U
or ( t-doc.ext-doc-type = 'ep':U )
then do:
        put space(20) string( "ПОСТАВЩИК : " + t-doc.cli-name ) format "x(90)" skip(1) .
end.
form header
    v-single-line format "X(136)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width 235 page-bottom no-labels no-box .
view frame Bottomframe .
if v-rb-is-base = yes
then do:
    form with frame Akt-base .
end.
else do:
    form with frame Akt-rubl .
end.
for each doc-line no-lock
   where doc-line.doc-code = t-doc.doc-code
  , each gds-dtl no-lock
   where gds-dtl.doc-code = t-doc.doc-code
     and gds-dtl.prod-type = doc-line.prod-type
     and gds-dtl.prod-code = doc-line.prod-code
     and gds-dtl.artic = doc-line.artic
     and gds-dtl.ov = yes
  , each goods no-lock
   where goods.prod-type = gds-dtl.prod-type
     and goods.prod-code = gds-dtl.prod-code
     and goods.artic = gds-dtl.artic
break by gds-dtl.artic
      by gds-dtl.prt-code
:
        find first bar-code no-lock
             where bar-code.gds-code = goods.gds-code
               and goods.unit-base = bar-code.unit-cli
               and gds-dtl.prt-code = bar-code.node-code
               and bar-code.part-code = ""
               and bar-code.in-code = ""
        no-error.
        accumulate
            bar-code.b-code ( COUNT )
            gds-dtl.fact-qnty ( total )
            ( gds-dtl.fact-qnty * gds-dtl.cur-base ) ( total )
            ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ( total )
            ( gds-dtl.fact-qnty * gds-dtl.price-base ) ( total )
            ( ( gds-dtl.cur-base - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ( total )
            ( ( gds-dtl.cur-base - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ( total )
        .
        if v-rb-is-base = yes
        then do:
            display
                sym1
                trim( string( bar-code.b-code ) ) @ tb-code
                gds-dtl.artic
                goods.gds-name
                gds-dtl.fact-qnty
                gds-dtl.price-base @ price-doc
                ( gds-dtl.fact-qnty * gds-dtl.price-base ) @ doc-sum
                gds-dtl.cur-base
                ( gds-dtl.fact-qnty * gds-dtl.cur-base ) @ obj-sum
                string( string( ( gds-dtl.cur-base - gds-dtl.price-base ) / gds-dtl.price-base * 100, "->>>9.9" ) + "%" ) @ Delt
                sym2
            with frame Akt-base .
            down 1 with frame Akt-base .
            IF LENGTH(goods.gds-name, "CHARACTER") > 30 and FullGdsName THEN  do:
              assign propis = SUBSTRING(goods.gds-name,31) .
              DISPLAY sym1 propis @ goods.gds-name  sym2   with frame Akt-base .
              down 1 with frame Akt-base .
            end.
        end.
        else do:
            display
                sym1
                trim( string( bar-code.b-code ) ) @ tb-code
                gds-dtl.artic
                goods.gds-name
                gds-dtl.fact-qnty
                gds-dtl.price-rubl @ price-doc
                ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) @ doc-sum
                gds-dtl.cur-base
                ( gds-dtl.fact-qnty * gds-dtl.cur-base ) @ obj-sum
                string( string( ( gds-dtl.cur-base - gds-dtl.price-rubl ) / gds-dtl.price-rubl * 100, "->>>9.9" ) + "%" ) @ Delt
                sym2
            with frame Akt-rubl .
            down 1 with frame Akt-rubl .
            IF LENGTH(goods.gds-name, "CHARACTER") > 30 and FullGdsName THEN  do:
              assign propis = SUBSTRING(goods.gds-name,31) .
              DISPLAY sym1 propis @ goods.gds-name  sym2   with frame Akt-rubl .
              down 1 with frame Akt-rubl .
            end.
        end.
        if last( gds-dtl.artic )
        then do:
            if v-rb-is-base = yes
            then do:
                put
                    v-single-line format "X(136)" skip
                .
                display "  ИТОГО"    @ goods.gds-name
                    accum total gds-dtl.fact-qnty @ gds-dtl.fact-qnty
                    accum total ( gds-dtl.fact-qnty * gds-dtl.price-base ) @ doc-sum
                    accum total ( gds-dtl.fact-qnty * gds-dtl.cur-base ) @ obj-sum
                    string( string( ( accum total ( ( gds-dtl.cur-base - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ) /
                                            ( accum total ( gds-dtl.fact-qnty * gds-dtl.price-base ) ) * 100, "->>>9.9" ) + "%" )
                                    @ Delt
                with frame Akt-base.
                underline
                    goods.gds-name
                    gds-dtl.fact-qnty
                    doc-sum
                    obj-sum
                    Delt
                with frame Akt-base.
                down 2
                with frame Akt-base.
            end.
            else do:
                put
                    v-single-line format "X(136)" skip
                .
                display "  ИТОГО"    @ goods.gds-name
                    accum total gds-dtl.fact-qnty @ gds-dtl.fact-qnty
                    accum total ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) @ doc-sum
                    accum total ( gds-dtl.fact-qnty * gds-dtl.cur-base ) @ obj-sum
                    string( string( ( accum total ( ( gds-dtl.cur-base - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ) /
                                            ( accum total ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ) * 100, "->>>9.9" ) + "%" )
                                    @ Delt
                with frame Akt-rubl.
                underline
                    goods.gds-name
                    gds-dtl.fact-qnty
                    doc-sum
                    obj-sum
                    Delt
                with frame Akt-rubl.
                down 2
                with frame Akt-rubl.
            end.
        end.
end.
hide frame Bottomframe .
if v-rb-is-base = yes
then do:
    run rep/wp.p ( input p-mainmenu-handle, input absolute( accum total ( ( gds-dtl.cur-base - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ), output propis, output abbr ) .
    put space(10) "Всего  " ( accum COUNT bar-code.b-code ) format ">>>>9"
        " наименований." format "X(15)"
        skip(1) space(10)
        "Разница в суммах составила :  " format "X(35)"
            ( accum total ( ( gds-dtl.cur-base - gds-dtl.price-base ) * gds-dtl.fact-qnty ) )
            format "->,>>>,>>>,>>9.99" space(2) trim( abbr ) format "X(3)"
        skip(1)
    .
end.
else do:
    run rep/wp-rub.p ( input absolute( accum total ( ( gds-dtl.cur-base - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ), output propis, output abbr ) .
    put space(10) "Всего  " ( accum COUNT bar-code.b-code ) format ">>>>9"
        " наименований." format "X(15)"
        skip(1) space(10)
        "Разница в суммах составила :  " format "X(35)"
            ( accum total ( ( gds-dtl.cur-base - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) )
            format "->,>>>,>>>,>>9.99" space(2) trim( abbr ) format "X(3)"
        skip(1)
    .
end.
if line-counter + 4 > page-size then
    page .
put space(10) ( if trim(propis) begins trim( abbr ) then string( "0 " + propis ) else propis ) format "X(120)" skip(2).
put space(20) "Зав. складом/Зав. секцией : " format "X(30)" skip.
output close.
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
