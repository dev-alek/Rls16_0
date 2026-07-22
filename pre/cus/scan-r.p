block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rcv-code   like ub.ord-doc-rcv.rcv-code no-undo.
define input parameter p-doc-code   like ub.ord-doc-rcv.doc-code no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scan-r.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/scan-r.p $":U .
define variable vss-description as character no-undo init "Единая процедура работы с мобильным сканером".
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
procedure last-price :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter  p-host-code     as integer no-undo .
define input parameter  p-artic         like ub.doc-line.artic  no-undo .
define input parameter  p-prod-type     like ub.doc-line.prod-type  no-undo .
define input parameter  p-prod-code     like ub.doc-line.prod-code  no-undo .
define input parameter  p-cli-code      like ub.ord-doc.cli-code  no-undo .
define input parameter  p-cli-type      like ub.ord-doc.cli-type  no-undo .
define input parameter  p-cli-base-rate like ub.ord-line.cli-base-rate no-undo .
define input parameter  p-curr-code  as integer   no-undo .
define output parameter p-price-base like ub.doc-line.price-base no-undo .
define output parameter p-price-rubl like ub.doc-line.price-rubl no-undo .
define output parameter p-price-cli  like ub.doc-line.price-cli  no-undo .
define buffer buf-lib-doc-line for ub.doc-line.
define buffer buf_cli-gds for ub.cli-gds .
define buffer buf_trn-doc for ub.trn-doc  .
define variable vp-curr-code  like ub.trn-doc.exch-code.
define variable vp-exch-rate  like ub.trn-doc.exch-rate.
define variable vp-exch-scale like ub.trn-doc.exch-scale.
define variable v-last-in-code   like ub.doc-line.doc-code  no-undo .
define variable v-last-obj-type  like ub.clients.obj-type no-undo .
define variable v-last-obj-code  like ub.clients.obj-code no-undo .
define variable v-cli-base-rate as decimal   no-undo .
 find first buf_cli-gds no-lock where
            buf_cli-gds.cli-type   = p-cli-type    and
            buf_cli-gds.cli-code   = p-cli-code    and
            buf_cli-gds.host-code  = p-host-code   and
            buf_cli-gds.artic      = p-artic       and
            buf_cli-gds.prod-type  = p-prod-type   and
            buf_cli-gds.prod-code  = p-prod-code
            no-error .
if available buf_cli-gds then do:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = buf_cli-gds.in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = buf_cli-gds.in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
else do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lastindc in g#library
  (input  p-host-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-last-in-code
  ,output v-last-obj-type
  ,output v-last-obj-code
  )  .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = v-last-in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = v-last-in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
    if available buf-lib-doc-line then do:
      assign
        v-cli-base-rate = buf-lib-doc-line.cli-base-rate
        p-price-base = buf-lib-doc-line.price-base
        p-price-rubl = buf-lib-doc-line.price-rubl
        p-price-cli  = (if vp-curr-code = 0 then buf-lib-doc-line.price-rubl else buf-lib-doc-line.price-base) * p-cli-base-rate
      .
      if v-cli-base-rate <> p-cli-base-rate
      then do:
          p-price-cli  = p-price-cli / v-cli-base-rate  .
      end.
       if p-curr-code <> vp-curr-code then do:
          p-price-cli  = p-price-rubl  .
      end.
    end.
    Else do:
      assign
        p-price-base = 0
        p-price-rubl = 0
        p-price-cli  = 0
      .
    end.
  end.
end procedure.
define variable add-sens as logical init true  no-undo.
define variable bar-str as char no-undo.
define variable pl-str as char no-undo.
define variable qnty-str as char no-undo.
define variable p-price as decimal   no-undo .
define variable part-list as char no-undo init "".
define variable b-c as int no-undo.
define variable rate as dec no-undo.
define variable conf-par as char no-undo.
define variable par-type as char no-undo.
define variable varplace as logical no-undo.
define variable is-err as log initial no no-undo.
define buffer buf1_ord-line for ub.ord-line  .
define buffer buf_zakz_ord-line for  ub.ord-line  .
define variable v-cli-base-rate like ub.goods.cli-base-rate   no-undo .
define variable v-unit-cli      like ub.goods.unit-cli        no-undo .
define variable v-ord  as integer   no-undo .
define variable v-qnty as integer   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE in-bc NO-UNDO
     FIELD nm        as INTEGER
     FIELD bar-str   AS CHARACTER
     FIELD bar-code  as CHARACTER
     FIELD rez       as CHARACTER
     FIELD err-msg   as CHARACTER
     FIELD des       as CHARACTER
     INDEX pi IS PRIMARY nm.
DEFINE new SHARED TEMP-TABLE un-bc NO-UNDO
     FIELD nm             as INTEGER
     FIELD bar-code       as CHARACTER
     FIELD entity         as character
     FIELD b-c            as INTEGER
     FIELD rate           as DECIMAL
     FIELD TYPE-bc        as CHARACTER
     FIELD wt             as DECIMAL
     FIELD file-qnty      as decimal
     FIELD scn-qnty       as DECIMAL
     FIELD scn-pl         as CHARACTER
     FIELD artic          LIKE ub.goods.artic
     FIELD prod-type      LIKE ub.goods.prod-type
     FIELD prod-code      LIKE ub.goods.prod-code
     FIELD gds-name       LIKE ub.goods.gds-name
     FIELD prod-name      LIKE ub.clients.obj-name
     FIELD unit-base      LIKE ub.goods.unit-base
     FIELD units-type     LIKE ub.units.type
     FIELD f-name         LIKE ub.gds-prt.f-name
     FIELD in-code        LIKE ub.parts.in-code
     FIELD fact-date      LIKE ub.parts.fact-date
     FIELD part-code      LIKE ub.parts.part-code
     FIELD rez            as CHARACTER
     FIELD err-msg        as CHARACTER
     FIELD des            as CHARACTER
     FIELD pl-name        AS CHARACTER
     FIELD loc1           AS CHARACTER
     FIELD loc2           AS CHARACTER
     FIELD loc3           AS CHARACTER
     FIELD loc4           AS CHARACTER
     FIELD unit-name      LIKE ub.units.unit-name
     FIELD long-name      LIKE ub.units.long-name
     FIELD b-c-base       LIKE ub.bar-code.b-code
     FIELD unit-name-base LIKE ub.units.unit-name
     FIELD long-name-base LIKE ub.units.long-name
     INDEX pi IS PRIMARY  nm
     INDEX bar-code bar-code
     INDEX b-c b-c
     INDEX file-qnty file-qnty.
DEFINE new SHARED TEMP-TABLE anlz-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD err-msg  as CHARACTER
     FIELD des      as CHARACTER
     FIELD upd-line as logical initial no
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
DEFINE new SHARED TEMP-TABLE main-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD des      as CHARACTER
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
define stream cur.
define stream log.
define stream err.
define variable scan-txt as char no-undo.
define variable scan-name as char no-undo.
define variable g-type as char no-undo init ?.
define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv.
define buffer buf_ord-line-rcv for ub.ord-line-rcv.
define variable is-all as log no-undo.
define variable i as int no-undo.
define variable j as int no-undo.
define variable varerr as logical no-undo.
define variable mess as char no-undo.
define variable glog as logical no-undo .
define frame a
    i format ">>>>9"  label "Просмотрено" space (20) skip
    j format ">>>>9" label "Обработано"
    with view-as dialog-box side-labels three-d title "".
system-dialog get-file scan-txt
  title "Выберите файл со сканера"
       filters "workabout ms15" "*.dbs",
                 "workabout" "*.imp",
                 "Инвентаризация с кассы" "*.inv",
                 "Текстовые файлы" "*.txt",
                 "Все файлы" "*.*"
       update glog.
if not glog then return.
if entry (2, scan-txt, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его.".
  return.
end.
message "yes - переписать количество со сканера для всех товаров" skip
        "no - прибавить количество со сканера для всех товаров"   skip
        "cancel - спрашивать для каждого товара"
        view-as alert-box question buttons yes-no-cancel update is-all.
scan-name = entry (1, scan-txt, ".").
frame a:title = "Разбор файла : " + scan-txt.
output stream log to value (scan-name + ".log") append.
output stream err to value (scan-name + ".err") append.
put stream log unformatted "  " skip.
put stream log unformatted cur-time-string-sec() skip.
find first buf_ord-doc-rcv no-lock where
           buf_ord-doc-rcv.rcv-code = p-rcv-code and
           buf_ord-doc-rcv.doc-code = p-doc-code
           no-error.
if error-status :error then return error.
put stream log unformatted " " skip skip
        "Документ "     buf_ord-doc-rcv.rcv-code
                        buf_ord-doc-rcv.doc-code
        " Тип: "        buf_ord-doc-rcv.doc-type
        " Статус: "     buf_ord-doc-rcv.status_
        " ОК: " string (buf_ord-doc-rcv.flag_, "+/-")
                skip skip.
    g-type =  'т':U .
view frame a.
input stream cur from value (scan-txt).
  input stream cur from value (scan-txt).
  run str/bc-anlz.p
     (input parparentproc,
      input "file",
      input scan-txt,
      input yes,
      output varerr,
      output table in-bc
      ) no-error.
  if error-status:error then do:
     message "Ошибка при обработке файла сканера." skip
             error-status:get-message(1)
        view-as alert-box error buttons ok.
     return error.
  end.
  if varerr = yes then is-err = yes.
  for each in-bc:
      if in-bc.rez = "err" then do:
         put stream log unformatted in-bc.err-msg skip.
         put stream err unformatted in-bc.bar-str skip.
         assign is-err = yes.
      end.
      if in-bc.des <> "" and in-bc.des <> ? then put stream log unformatted in-bc.des.
  end.
  for each un-bc:
      if un-bc.rez = "err" then do:
         put stream log unformatted un-bc.err-msg skip.
         put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
         assign is-err = yes.
      end.
  end.
  i = 0 .
  j = 0 .
  for each main-bc:
    i = i + 1.
    disp i with frame a.
    find ub.bar-code where ub.bar-code.b-code = main-bc.b-c no-lock.
    find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code no-lock.
      assign bar-str  = string(main-bc.b-c)
             qnty-str = string(main-bc.scn-qnty)
             rate     = 1
             pl-str   = main-bc.scn-pl
             mess     = main-bc.des
             p-price  = decimal(main-bc.scn-pl)
             .
      run proc-code in this-procedure  ( input main-bc.nm
                                        ,input ""
                                        ) no-error.
      if error-status:error then do:
         assign is-err = yes.
      end.
  end.
message 'Просмотрено :' i skip
        'Обработано  :' j skip
        'Несовпадений по ассортименту:' v-ord  skip
        'Несовпадений по количеству:  ' v-qnty
        if v-ord > 0 or v-qnty  > 0 then "Подробнее см в СОСТОЯНИЕ ЗАКАЗА" else ""
        .
if is-err then
    message "Во время загрузки файла:" scan-txt "обнаружены ошибки." skip
            "Смотрите log файл."
    view-as alert-box error buttons ok.
procedure proc-code :
define input  parameter n-pp   as integer no-undo .
define input  parameter mode-proc as CHAR NO-UNDO.
define buffer b-bar-code for ub.bar-code.
define buffer pc-goods   for ub.goods.
define variable mode-create      as logical no-undo.
define variable rec-old          as recid no-undo.
define variable varres           as logical         no-undo.
define variable var-code-temp    like ub.place.pl-code no-undo.
define variable g-log-char       as character no-undo.
define variable varprice-cli-old        like ub.ord-line-rcv.price-cli no-undo.
define variable varprice-rubl-old       like ub.ord-line-rcv.price-cli no-undo.
define variable varprice-base-old       like ub.ord-line-rcv.price-cli no-undo.
define variable varcli-qnty-old         like ub.ord-line-rcv.cli-qnty  no-undo.
define variable varcli-base-rate-old    like ub.ord-line-rcv.cli-qnty  no-undo.
define variable varfact-qnty-old        like ub.ord-line-rcv.cli-qnty  no-undo.
define variable p-qnty                  like ub.ord-line-rcv.cli-qnty  no-undo.
define variable vardoc-qnty-old         like ub.ord-line-rcv.cli-qnty  no-undo.
define variable varvat-pc-old           like ub.ord-line-rcv.vat-pc    no-undo.
define variable varslt-pc-old           like ub.ord-line-rcv.vat-pc    no-undo.
define variable varroad-tax-old         like ub.ord-line-rcv.price-cli no-undo.
define variable varexcise-old           like ub.ord-line-rcv.price-cli no-undo.
define variable vartransport-rubl-old   like ub.ord-line-rcv.price-cli no-undo.
define variable varother-rubl-old       like ub.ord-line-rcv.price-cli no-undo.
define variable is-1 as logical no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    assign g-log-char = "yes".
    do transaction on error undo , leave:
       define variable tempmess as character no-undo.
       find first buf_ord-line-rcv no-lock where
                  buf_ord-line-rcv.artic = ub.goods.artic         and
                  buf_ord-line-rcv.prod-type = ub.goods.prod-type and
                  buf_ord-line-rcv.prod-code = ub.goods.prod-code and
                  buf_ord-line-rcv.rcv-code  = p-rcv-code    and
                  buf_ord-line-rcv.doc-code  = p-doc-code
                  no-error.
       if available buf_ord-line-rcv then do:
          assign
          mode-create = no
          varprice-cli-old       = buf_ord-line-rcv.price-cli
          varprice-rubl-old      = buf_ord-line-rcv.price-rubl
          varprice-base-old      = buf_ord-line-rcv.price-base
          varcli-qnty-old        = buf_ord-line-rcv.cli-qnty
          varcli-base-rate-old   = buf_ord-line-rcv.cli-base-rate
          varfact-qnty-old       = buf_ord-line-rcv.qnty
          varvat-pc-old          = buf_ord-line-rcv.vat-pc
          varslt-pc-old          = buf_ord-line-rcv.slt-pc
          varroad-tax-old        = buf_ord-line-rcv.road-tax
          varexcise-old          = buf_ord-line-rcv.excise
          vartransport-rubl-old  = buf_ord-line-rcv.transport-rubl
          varother-rubl-old      = buf_ord-line-rcv.other-rubl.
       end.
       else mode-create = yes.
  if is-all = true  then p-qnty =  decimal(qnty-str) .
  if is-all = false then p-qnty =  decimal(qnty-str)  + varfact-qnty-old .
  if is-all = ? then do:
      message "ТОВАР "
              ub.goods.artic
              ub.goods.prod-type
              ub.goods.prod-code  skip
              ub.goods.gds-name   skip  " "
              skip
              "YES - переписать количество со сканера товара = " decimal(qnty-str) skip
              "NO - прибавить количество со сканера для товара = " decimal(qnty-str)  + varfact-qnty-old  skip
              view-as alert-box question buttons yes-no update is-1.
          if is-1 = true then p-qnty  =  decimal(qnty-str) .
          if is-1 = false then p-qnty =   decimal(qnty-str)  + varfact-qnty-old .
  end.
  find first buf1_ord-line no-lock where
             buf1_ord-line.doc-code   = p-doc-code and
             buf1_ord-line.artic      = ub.goods.artic    and
             buf1_ord-line.prod-type  = ub.goods.prod-type  and
             buf1_ord-line.prod-code  = ub.goods.prod-code no-error .
  if available buf1_ord-line then do:
     if buf1_ord-line.qnty  <> p-qnty then do:
          v-qnty = v-qnty + 1.
          put stream err unformatted bar-str "," ub.goods.gds-name
        " по заказу " buf1_ord-line.qnty " по поставке " p-qnty skip.
     end.
  end.
  else do:
    v-ord = v-ord + 1.
    put stream err unformatted bar-str "," ub.goods.gds-name " нет в заказе " skip.
  end.
  find first buf_zakz_ord-line no-lock where
             buf_zakz_ord-line.doc-code  = p-doc-code and
             buf_zakz_ord-line.artic     = ub.goods.artic and
             buf_zakz_ord-line.prod-code = ub.goods.prod-code and
             buf_zakz_ord-line.prod-type = ub.goods.prod-type
             no-error .
    if available buf_zakz_ord-line then do:
       assign
         v-cli-base-rate = buf_zakz_ord-line.cli-base-rate
         v-unit-cli      = buf_zakz_ord-line.unit-cli
         .
    end.
    else do:
      assign
        v-cli-base-rate = ub.goods.cli-base-rate
        v-unit-cli      = ub.goods.unit-cli
        .
    end.
   run create-ord-line-rcv (
        p-rcv-code       ,
        p-doc-code       ,
        n-pp             ,
        ub.goods.artic      ,
        ub.goods.prod-code  ,
        ub.goods.prod-type  ,
        v-cli-base-rate  ,
        p-qnty           ,
        v-unit-cli       ,
        p-price )
        .
       assign
       mess = mess + tempmess.
       if error-status:error then do:
         assign
         mess = mess + return-value.
         put stream err unformatted bar-str "," qnty-str skip.
         put stream log unformatted "***" mess " - ошибка" skip.
         return error.
       end.
       else do:
         put stream log unformatted mess " - успешно" skip.
         j = j + 1.
         disp j with frame a.
       end.
    if substring(g-log-char, 1, 4) = "qnty" then do:
          put stream err unformatted bar-str "," ENTRY(2, g-log-char, "=") skip.
          put stream log unformatted "***" mess " - не все количество зарезервировано" skip.
    end.
  end.
end procedure.
procedure create-ord-line-rcv :
define input parameter  p-rcv-code       like ub.ord-doc-rcv.rcv-code         no-undo .
define input parameter  p-doc-code       like ub.ord-doc-rcv.doc-code         no-undo .
define input parameter  p-line-num       like ub.ord-line-rcv.line-num        no-undo .
define input parameter  p-artic          like ub.ord-line-rcv.artic           no-undo .
define input parameter  p-prod-code      like ub.ord-line-rcv.prod-code       no-undo .
define input parameter  p-prod-type      like ub.ord-line-rcv.prod-type       no-undo .
define input parameter  p-cli-base-rate  like ub.ord-line-rcv.cli-base-rate   no-undo .
define input parameter  p-qnty           as decimal   no-undo .
define input parameter  p-unit-cli       like ub.ord-line-rcv.unit-cli        no-undo .
define input parameter  p-price          as decimal   no-undo .
define variable p-cli-qnty               as decimal   no-undo .
define buffer bbb_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer tt-goods for ub.goods .
define buffer buf_ord-doc for ub.ord-doc  .
 do
 on error undo, return error return-value
 :
 find first buf_ord-doc no-lock where
            buf_ord-doc.doc-code = ub.ord-line-rcv.doc-code no-error .
 find first bbb_ord-doc-rcv no-lock where
            bbb_ord-doc-rcv.rcv-code = p-rcv-code and
            bbb_ord-doc-rcv.doc-code = p-doc-code
            no-error .
 if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              view-as alert-box error .
              undo, return error.
 end.
 find first tt-goods where
      tt-goods.artic             =   p-artic          and
      tt-goods.prod-code         =   p-prod-code      and
      tt-goods.prod-type         =   p-prod-type      no-lock no-error .
 if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              view-as alert-box error .
              undo, return error.
 end.
find first ub.ord-line-rcv where
           ub.ord-line-rcv.artic     = tt-goods.artic     and
           ub.ord-line-rcv.prod-type = tt-goods.prod-type and
           ub.ord-line-rcv.prod-code = tt-goods.prod-code and
           ub.ord-line-rcv.rcv-code  = p-rcv-code   and
           ub.ord-line-rcv.doc-code  = p-doc-code
           exclusive-lock    no-error.
      if not available ub.ord-line-rcv then do:
        create  ub.ord-line-rcv.
      end.
      assign
        ub.ord-line-rcv.gds-code       = tt-goods.gds-code
        ub.ord-line-rcv.doc-code       = p-doc-code
        ub.ord-line-rcv.rcv-code       = p-rcv-code
        ub.ord-line-rcv.line-num       = p-line-num
        ub.ord-line-rcv.artic          = p-artic
        ub.ord-line-rcv.prod-code      = p-prod-code
        ub.ord-line-rcv.prod-type      = p-prod-type
        ub.ord-line-rcv.cli-base-rate  = p-cli-base-rate
        ub.ord-line-rcv.qnty           = p-qnty
        ub.ord-line-rcv.cli-qnty       = ub.ord-line-rcv.qnty  / ub.ord-line-rcv.cli-base-rate
        ub.ord-line-rcv.unit-cli       = p-unit-cli
    .
     if p-price <> 0 then do:
        assign
          ub.ord-line-rcv.price-rubl =  p-price
          ub.ord-line-rcv.price-base =  ub.ord-line-rcv.price-rubl / bbb_ord-doc-rcv.base-rate * bbb_ord-doc-rcv.base-scale
          ub.ord-line-rcv.price-cli  =  ( p-price * ub.ord-line-rcv.cli-base-rate) / (bbb_ord-doc-rcv.exch-rate * bbb_ord-doc-rcv.exch-scale)
        .
     end.
     else do:
      find first buf_ord-doc no-lock where
                  buf_ord-doc.doc-code = ub.ord-line-rcv.doc-code no-error .
       if available buf_ord-doc then do:
       find first ub.ord-line no-lock where
                  ub.ord-line.doc-code   = ub.ord-line-rcv.doc-code and
                  ub.ord-line.artic      = tt-goods.artic    and
                  ub.ord-line.prod-type  = tt-goods.prod-type  and
                  ub.ord-line.prod-code  = tt-goods.prod-code no-error .
                  if available ub.ord-line then do:
                     assign
                      ub.ord-line-rcv.price-rubl = ub.ord-line.price-rubl
                      ub.ord-line-rcv.price-base = ub.ord-line.price-base
                      ub.ord-line-rcv.price-cli  = ub.ord-line.price-cli
                     .
                  end.
                  else do:
                    run last-price (
                          input  buf_ord-doc.host-code ,
                          input  tt-goods.artic ,
                          input  tt-goods.prod-type ,
                          input  tt-goods.prod-code ,
                          input  buf_ord-doc.cli-code  ,
                          input  buf_ord-doc.cli-type  ,
                          input  ub.ord-line-rcv.cli-base-rate ,
                          input  buf_ord-doc.exch-code ,
                          output ub.ord-line-rcv.price-base ,
                          output ub.ord-line-rcv.price-rubl ,
                          output ub.ord-line-rcv.price-cli  )
                    no-error  .
                    if error-status :error then message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "Ошибка поиска последней цены"
                      view-as alert-box error
                    .
                  end.
       end.
     end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  tt-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  bbb_ord-doc-rcv.host-code
  ,input  bbb_ord-doc-rcv.obj-type
  ,input  bbb_ord-doc-rcv.obj-code
  ,output ub.ord-line-rcv.vat-pc
  ) no-error .
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  assign
     ub.ord-line-rcv.sum-rubl = ub.ord-line-rcv.qnty * ub.ord-line-rcv.price-rubl
     ub.ord-line-rcv.sum-base = ub.ord-line-rcv.qnty * ub.ord-line-rcv.price-base
     ub.ord-line-rcv.sum-cli  = ub.ord-line-rcv.cli-qnty * ub.ord-line-rcv.price-cli
     .
 end.
end procedure.
