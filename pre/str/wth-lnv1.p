block-level on error undo, throw.
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
FIELD q-ty-bef     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во план"
FIELD q-ty-aft     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во факт"
FIELD sum-bef  like ub.wth-line.bef-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма план"
FIELD sum-aft  like ub.wth-line.aft-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма факт"
FIELD sum-fact  like ub.wth-line.fact-sum FORM "->,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Расхождение"
INDEX tt-pi    IS   PRIMARY UNIQUE par-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        sum-bef  q-ty-bef
.
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode    as character no-undo .
define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .
define input parameter parbef-sum  like ub.wth-line.BEF-sum no-undo .
define input parameter paraft-sum  like ub.wth-line.AFT-sum no-undo .
define input parameter table for tt-par-dtl.
define input parameter parline-exist as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-lnv1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-lnv1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в строке документа МЦ инвентаризации".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure wth-lib_cur-stock-place:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parw-p-code like ub.wth-pobj.w-p-code  no-undo.
define input  parameter parwth-code like ub.wth-pobj.wth-code  no-undo.
define output parameter parstock    like ub.wth-pobj.income-pl no-undo.
define buffer bf_wth-pobj for ub.wth-pobj.
find first bf_wth-pobj where bf_wth-pobj.obj-type = parobj-type and
                             bf_wth-pobj.obj-code = parobj-code and
                             bf_wth-pobj.w-p-code = parw-p-code and
                             bf_wth-pobj.wth-code = parwth-code no-lock no-error.
if available bf_wth-pobj then assign parstock = bf_wth-pobj.income-pl - bf_wth-pobj.incass-pl.
                         else assign parstock = 0.
end procedure.
procedure wth-lib_cur-stock-obj:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parwth-code like ub.wth-obj.wth-code   no-undo.
define output parameter parstock    like ub.wth-obj.income     no-undo.
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then assign parstock = bf_wth-obj.income - bf_wth-obj.incass.
                        else assign parstock = 0.
end.
FUNCTION wth-lib_cur-stock-obj-func RETURNS DECIMAL (INPUT parobj-type AS CHARACTER,
                                                     INPUT parobj-code AS INTEGER,
                                                     INPUT parwth-code AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then return (bf_wth-obj.income - bf_wth-obj.incass).
                        else return 0.00.
end function.
FUNCTION wth-lib_cur-stock-host-func RETURNS DECIMAL (INPUT parhost-code AS INTEGER,
                                                      INPUT parwth-code  AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
define variable v-stock like ub.wth-obj.income no-undo.
for each bf_wth-obj no-lock where bf_wth-obj.host-code = parhost-code and
                                  bf_wth-obj.wth-code = parwth-code :
  v-stock = v-stock +  bf_wth-obj.income - bf_wth-obj.incass.
end.
return v-stock.
end function.
procedure wth-lib_full-inf-shift:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-inter:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-period-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parw-p-code     like ub.wth-pobj.w-p-code  no-undo.                        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                        define input parameter parshift-num  like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parfact-date    like ub.wth-line.fact-date    no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code  like ub.wth-line.w-p-code  no-undo.                        define input parameter parfact-date like ub.wth-line.fact-date no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
FUNCTION get-curr RETURNS CHARACTER
  (buffer loc-wealth for ub.wealth ) :
define buffer buf_currency for ub.currency.
if loc-wealth.curr-code = ? or loc-wealth.is-money = no then
return loc-wealth.unit-base.
FIND FIRST buf_currency no-lock where
          buf_currency.curr-code = loc-wealth.curr-code No-ERROR.
if avail buf_currency then
  RETURN buf_currency.curr-abbr.
else return "".
END FUNCTION.
define variable var-entry         as character no-undo .
define variable loc#log           as logical   no-undo .
define variable vardtl-rec        as recid     no-undo .
define variable varis-dtl         as logical   no-undo .
define variable vardtl-bef-sum    as decimal   no-undo .
define variable vardtl-aft-sum    as decimal   no-undo .
define variable varline-bef-sum   as decimal   no-undo .
define variable varline-aft-sum   as decimal   no-undo .
define variable v-today           as date      no-undo .
define variable v-time            as integer   no-undo .
define variable varbef-sum        as decimal   no-undo .
define variable vdoc-bef-sum      as decimal   no-undo .
define variable v-added           as logical   no-undo .
define variable calc-line-bef-sum as decimal   no-undo .
define buffer buf_wth-doc  for ub.wth-doc .
define buffer buf_wth-line for ub.wth-line .
define buffer inv_wth-doc  for ub.wth-doc.
if not (par-mode = 'ДОБАВЛЕНИЕ':U
        or par-mode = 'ИЗМЕНЕНИЕ':U
        or par-mode = 'удаление':U
       )
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова par-mode" par-mode
    view-as alert-box ERROR.
  return error '':U.
end.
find first buf_wth-doc exclusive-lock
  where buf_wth-doc.doc-code = pardoc-code
  no-error
  no-wait.
if locked buf_wth-doc
then do:
  message vss-workfile vss-revision vss-description skip
          "Запись документа МЦ" pardoc-code "занята"
          "добавление/изменение строки невозможно"
  view-as alert-box error .
  return error substitute("Запись документа МЦ &1 занята", pardoc-code ).
end.
if not available buf_wth-doc
then do:
  message vss-workfile vss-revision vss-description skip
          "Не найден документ МЦ" pardoc-code
  view-as alert-box error .
  return error substitute("Не найден документ МЦ &1", pardoc-code ).
end.
if buf_wth-doc.status_ = 'факт':U
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Документ МЦ имеет статус" buf_wth-doc.status_
  "добавление/изменение строки невозможно"
  view-as alert-box ERROR.
  return error '':U.
end.
if  buf_wth-doc.status_ = 'разрешен':U
and par-mode = 'ДОБАВЛЕНИЕ':U
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Документ МЦ имеет статус" buf_wth-doc.status_
  "добавление строки невозможно"
  view-as alert-box ERROR.
  return error '':U.
end.
assign
varbef-sum = parbef-sum.
if buf_wth-doc.auto-fill
or parbef-sum = ?
then do:
  run wth-lib_cur-stock-place in this-procedure (
                                                    input  buf_wth-doc.obj-type
                                                  ,input  buf_wth-doc.obj-code
                                                  ,input  parw-p-code
                                                  ,input parwth-code
                                                  ,output calc-line-bef-sum
                                                  ) no-error.
  if error-status:error
  then do:
    return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
end.
if par-mode = 'ДОБАВЛЕНИЕ':U
then do:
  par-rid = ?.
  if  parline-exist = yes
  then do:
    FIND FIRST ub.wth-line No-LOCK WHERE
              ub.wth-line.doc-code = pardoc-code AND
              ub.wth-line.wth-code = parwth-code AND
              ub.wth-line.w-p-code = parw-p-code No-ERROR.
    if available ub.wth-line
    then do:
      par-rid = recid(ub.wth-line).
      assign
      v-added = yes
      varbef-sum = (if parbef-sum = ?
                    then calc-line-bef-sum
                    else (varbef-sum + ub.wth-line.bef-sum))
      paraft-sum = paraft-sum + ub.wth-line.aft-sum
      .
    end.
    else do:
      if parbef-sum = ?
      then do:
        assign
        varbef-sum = calc-line-bef-sum.
      end.
    end.
  end.
end.
run trg/wth-lnv2.p (
                input pardoc-code,
                input buf_wth-doc.host-code,
                input buf_wth-doc.obj-type,
                input buf_wth-doc.obj-code,
                input buf_wth-doc.cli-type,
                input buf_wth-doc.cli-code,
                input buf_wth-doc.auto-fill,
                input buf_wth-doc.borned,
                input par-rid,
                input parwth-code,
                input parw-p-code ) no-error.
if error-status:error then return error return-value.
find first buf_wth-line no-lock
  where buf_wth-line.obj-type    = buf_wth-doc.obj-type
    and buf_wth-line.obj-code    = buf_wth-doc.obj-code
    and buf_wth-line.w-p-code    = parw-p-code
    and buf_wth-line.shift-date  = buf_wth-doc.shift-date
    and buf_wth-line.shift-num   = buf_wth-doc.shift-num
    and buf_wth-line.wth-code    = parwth-code
    and buf_wth-line.status_    <> 'факт':U
    and recid( buf_wth-line )   <>  par-rid
  no-error .
if available buf_wth-line
then do:
  find first inv_wth-doc no-lock
    where inv_wth-doc.doc-code = buf_wth-line.doc-code
    no-error .
  if inv_wth-doc.doc-type = 'инв':U
  then do:
    message
      "Материальная ценность" parwth-code "есть в незакрытой инвентаризации"
      buf_wth-line.doc-code "по м/х" parw-p-code "!" Skip
      "Невозможно добавить в документ!"
      view-as alert-box error.
      assign
        var-entry = "wth-code":u
      .
      return error var-entry.
  end.
  else do:
    message
      "Материальная ценность" parwth-code "есть в незакрытом документе"
      buf_wth-line.doc-code "по м/х" parw-p-code "!" Skip
      "Невозможно добавить в документ!"
      view-as alert-box error.
      assign
        var-entry = "wth-code":U
      .
      return error var-entry.
  End.
END.
do
on error undo, return '':u
on stop undo, return '':u
:
  if par-mode = 'ДОБАВЛЕНИЕ':U and par-rid = ?
  then do:
    run cur-time in this-procedure(output v-today, output v-time).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CREATE wth-line.
ASSIGN
  wth-line.doc-code     = buf_wth-doc.doc-code
  wth-line.w-p-code     = parw-p-code
  wth-line.obj-type     = buf_wth-doc.obj-type
  wth-line.obj-code     = buf_wth-doc.obj-code
  wth-line.shift-date   = buf_wth-doc.shift-date
  wth-line.shift-num    = buf_wth-doc.shift-num
  wth-line.shift-name   = buf_wth-doc.shift-name
  wth-line.creid        = g#userid
  wth-line.credate      = v-today
.
    assign par-rid = recid(ub.wth-line).
  end.
  else do:
    FIND FIRST ub.wth-line EXCLUSIVE-LOCK WHERE
              recid(ub.wth-line) = par-rid No-WAIT No-ERROR.
    if locked ub.wth-line
    then do:
      message "Строка документа МЦ занят"
      view-as alert-box error .
      return error '':U.
    end.
    if not avail ub.wth-line
    then do:
      message "Не найдена строка документа МЦ"
      view-as alert-box error .
      return error '':U.
    end.
    if  buf_wth-doc.status_ = 'разрешен':U
    and (ub.wth-line.doc-code <> pardoc-code
         or ub.wth-line.wth-code <> parwth-code
         or ub.wth-line.w-p-code <> parw-p-code
         or ub.wth-line.bef-sum <> parbef-sum
        )
    then dO:
      message
      vss-workfile vss-revision vss-description skip
      "Документ МЦ имеет статус" buf_wth-doc.status_
      "возможно изменить только сумму факт"
      view-as alert-box ERROR.
      return error '':U.
    end.
  end.
  if buf_wth-doc.auto-fill
  or parbef-sum = ?
  then do:
  end.
  else do:
    calc-line-bef-sum = if par-mode = 'удаление':U
                        then 0
                        else varbef-sum.
  end.
  assign
    ub.wth-line.doc-code = pardoc-code
    ub.wth-line.wth-code = parwth-code
    ub.wth-line.w-p-code = parw-p-code
  .
  if parbef-sum = ?
  then do:
    for each buf_wth-line no-lock where
            buf_wth-line.doc-code = buf_wth-doc.doc-code:
      if recid(buf_wth-line) = recid(ub.wth-line) then next.
      assign
      vdoc-bef-sum = vdoc-bef-sum + buf_wth-line.bef-sum.
    end.
    assign
    vdoc-bef-sum = vdoc-bef-sum + varbef-sum
    buf_wth-doc.bef-sum = vdoc-bef-sum
    .
  end.
  else do:
    assign
    buf_wth-doc.bef-sum = buf_wth-doc.bef-sum - ub.wth-line.bef-sum + calc-line-bef-sum
    .
  end.
  assign
  ub.wth-line.bef-sum = parbef-sum
  buf_wth-doc.aft-sum = buf_wth-doc.aft-sum - ub.wth-line.aft-sum + paraft-sum
  ub.wth-line.aft-sum = paraft-sum
  .
  assign
  varline-bef-sum = ub.wth-line.bef-sum
  varline-aft-sum = ub.wth-line.aft-sum
  .
  if par-mode = 'ДОБАВЛЕНИЕ':U
  then do:
    release ub.wth-line no-error.
    if error-status:error
    then do:
      return error '':U.
    end.
  end.
  for each tt-par-dtl:
    varis-dtl = yes.
    run str/wth-dtl1.p (output vardtl-rec,
                  input par-mode,
                  input pardoc-code,
                  input parwth-code,
                  input parw-p-code,
                  input tt-par-dtl.par-code,
                  input tt-par-dtl.sum-BEF,
                  input tt-par-dtl.sum-aft,
                  input 0,
                  input 0,
                  input parline-exist
                  ) no-error.
    if error-status:error or vardtl-rec = ?
    then do:
      assign
        var-entry = "b-par":U
      .
      return error var-entry.
    end.
    assign
    vardtl-bef-sum = vardtl-bef-sum + tt-par-dtl.sum-bef
    vardtl-aft-sum = vardtl-aft-sum + tt-par-dtl.sum-aft
    .
  END.
  if varis-dtl
  then do:
    case buf_wth-doc.status_ :
      when 'накл':U
      then do:
        if varline-bef-sum <> vardtl-bef-sum
        and NOT (vardtl-bef-sum  = 0 and
                 not can-find(first ub.wth-dtl No-LOCK WHERE
                                    ub.wth-dtl.doc-code = pardoc-code AND
                                    ub.wth-dtl.wth-code = parwth-code AND
                                    ub.wth-dtl.w-p-code = parw-p-code)
                )
        then do:
          message "Сумма по номиналам не совпадает с суммой движения материального средства!"
          view-as alert-box error .
          var-entry = "wth-dtl":U.
          return error var-entry.
        end.
      end.
      when 'разрешен':U
      then do:
        if varline-aft-sum <> vardtl-aft-sum and
          NOT (vardtl-aft-sum  = 0 and
                not can-find(first ub.wth-dtl No-LOCK WHERE
                                    ub.wth-dtl.doc-code = pardoc-code AND
                                    ub.wth-dtl.wth-code = parwth-code AND
                                    ub.wth-dtl.w-p-code = parw-p-code)
                )
        then dO:
          message "Сумма по номиналам не совпадает с суммой движения материального средства!"
          view-as alert-box error .
          var-entry = "wth-dtl":U.
          return error var-entry.
        end.
      end.
    END CASE.
  end.
  else do:
    if can-find(first ub.wth-dtl No-LOCK WHERE
                      ub.wth-dtl.doc-code = pardoc-code AND
                      ub.wth-dtl.wth-code = parwth-code AND
                      ub.wth-dtl.w-p-code = parw-p-code)
    then do:
      FOR EACH ub.wth-dtl No-LOCK WHERE
                ub.wth-dtl.doc-code = ub.wth-line.doc-code AND
                ub.wth-dtl.wth-code = ub.wth-line.wth-code AND
                ub.wth-dtl.w-p-code = ub.wth-line.w-p-code:
        assign
        vardtl-bef-sum = vardtl-bef-sum + ub.wth-dtl.bef-sum
        vardtl-aft-sum = vardtl-aft-sum + ub.wth-dtl.aft-sum
        .
      END.
      if varline-bef-sum <> vardtl-bef-sum or
         varline-aft-sum <> vardtl-aft-sum
      then dO:
        message "Сумма по номиналам не совпадает с суммой движения материального средства!"
        view-as alert-box error .
        var-entry = "wth-dtl":U.
        return error var-entry.
      end.
    end.
  end.
END.
return '':U.
