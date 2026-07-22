using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.str.placelib from propath .
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imptank-imp implements ibs.th.bge.1crn.import.iimpsubject:
  define variable placelib as class placelib no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method private logical cur-time (output p-today as date,
                                 output p-time  as integer ):
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
method private character  cur-time-date ()
:
  return string(today, '99/99/9999':U) .
end.
method private decimal cur-time-mjd ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
method private integer cur-time-get-ending-index
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
method private character cur-time-mjd-to-date(
  input  i-mjd-diff as decimal
,output  o-Date     as date
,output  o-Time     as integer):
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
method private character cur-time-mjd-to-string
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
method private character cur-time-string ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
method private character cur-time-string-sec ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
method private character cur-time-custom
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
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
method private character cur-time-print ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
method private datetime cur-time-datetime ()
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
method private character cur-time-string-msec ()
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-tank         as class tank-imp         no-undo.
    define variable v-cal-tbl-line as class tank-imp_cal-tbl no-undo.
    define variable v-belt-tbl-line as class tank-imp_belt-tbl no-undo.
    define variable v_cal-tbl      as class subjects         no-undo.
    define variable v_belt-tbl      as class subjects         no-undo.
    define buffer buf_place-imp      for ub.place-imp .
    define buffer bf_place-imp       for ub.place-imp .
    define buffer buf_place-imp-attr for ub.place-imp-attr .
    define buffer buf_pl-level-imp   for ub.pl-level-imp .
    define buffer bf_pl-level-imp    for ub.pl-level-imp .
    define buffer buf_clients        for ub.clients .
    define buffer buf_pl-level-attr  for ub.pl-level-attr .
    define buffer buf_pl-level-mm-imp   for ub.pl-level-mm-imp .
    define buffer buf_shift-obj      for ub.shift-obj .
    define buffer buf_place-attr     for ub.place-attr .
    define variable v-mode  as character no-undo .
    define variable v-rec   as recid     no-undo .
    define variable ii      as integer   no-undo .
    define variable v-code  as character no-undo .
    define variable v-value as character no-undo .
    define variable v-ok    as logical   no-undo .
    define variable v-today as date      no-undo .
    define variable v-time  as integer   no-undo .
    v-tank = cast (subjectObj, tank-imp).
    v_cal-tbl = v-tank:cal-tbl .
    v_belt-tbl = v-tank:belt-tbl .
    find first buf_clients no-lock  where buf_clients.obj-type = 'маг':U
      and buf_clients.obj-code = integer(v-tank:gs-code) no-error .
    if not AVAILABLE (buf_clients) then
    do:
      Msg = "Нет объекта с кодом: " + v-tank:gs-code .
      return error .
    end.
    find first buf_place-imp no-lock where buf_place-imp.obj-type = buf_clients.obj-type
                                       and buf_place-imp.obj-code = buf_clients.obj-code
                                       and buf_place-imp.pl-code  = integer(v-tank:tank-code)
                                       and buf_place-imp.table-version >= v-tank:table-version
                                       no-error .
    if NOT AVAILABLE (buf_place-imp) then
    do:
      create buf_place-imp .
      assign
        buf_place-imp.obj-type      = buf_clients.obj-type
        buf_place-imp.obj-code      = buf_clients.obj-code
        buf_place-imp.pl-code       = integer(v-tank:tank-code)
        buf_place-imp.table-version = v-tank:table-version
        buf_place-imp.status_       = 0
        buf_place-imp.max-qnty      = v-tank:max-qnty
        buf_place-imp.d-qnty        = v-tank:d-qnty
        buf_place-imp.tank-d        = v-tank:tank-d
        buf_place-imp.dc-height     = v-tank:dc-height
        buf_place-imp.dnsty         = v-tank:dnsty
        buf_place-imp.main-mi-code  = if v-tank:main-mi-code <> ? then integer(v-tank:main-mi-code) else ?
        buf_place-imp.position      = v-tank:position_ + 1
        buf_place-imp.tank-tk       = v-tank:tank-tk
        buf_place-imp.pontoon       = v-tank:pontoon
        buf_place-imp.wght-pntn     = v-tank:wght-pntn
        buf_place-imp.srfcng-pntn   = v-tank:srfcng-pntn
      .
      for each bf_pl-level-imp where bf_pl-level-imp.obj-code = buf_place-imp.obj-code
        and bf_pl-level-imp.obj-type = buf_place-imp.obj-type
        and bf_pl-level-imp.pl-code = buf_place-imp.pl-code
        and bf_pl-level-imp.table-version = buf_place-imp.table-version:
        delete bf_pl-level-imp .
      end.
      for each buf_pl-level-mm-imp where buf_pl-level-mm-imp.obj-code = buf_place-imp.obj-code
        and buf_pl-level-mm-imp.obj-type = buf_place-imp.obj-type
        and buf_pl-level-mm-imp.pl-code = buf_place-imp.pl-code
        and buf_pl-level-mm-imp.table-version = buf_place-imp.table-version:
        delete buf_pl-level-mm-imp .
      end.
      if VALID-OBJECT (v_cal-tbl) then
      do:
        do ii = 1 to v_cal-tbl:Get(ii):
          v-cal-tbl-line = cast(v_cal-tbl:SubjectObjCurr, tank-imp_cal-tbl) .
          find first buf_pl-level-imp EXCLUSIVE-LOCK where buf_pl-level-imp.obj-code = buf_place-imp.obj-code
            and buf_pl-level-imp.obj-type = buf_place-imp.obj-type
            and buf_pl-level-imp.pl-code = buf_place-imp.pl-code
            and buf_pl-level-imp.table-version = buf_place-imp.table-version
            and buf_pl-level-imp.pl-level = v-cal-tbl-line:lvl_ no-error .
          if not AVAILABLE (buf_pl-level-imp) then
          do:
            create buf_pl-level-imp.
            assign
              buf_pl-level-imp.obj-type = buf_place-imp.obj-type
              buf_pl-level-imp.obj-code = buf_place-imp.obj-code
              buf_pl-level-imp.pl-code  = buf_place-imp.pl-code
              buf_pl-level-imp.table-version = buf_place-imp.table-version
              buf_pl-level-imp.pl-level = v-cal-tbl-line:lvl_
              buf_pl-level-imp.pl-qnty  = v-cal-tbl-line:amnt
              buf_pl-level-imp.tarir-delta = v-cal-tbl-line:comp-err
              buf_pl-level-imp.deltaV   = v-cal-tbl-line:deltaV
            .
          end.
        end.
      end.
      if VALID-OBJECT (v_belt-tbl) then
      do:
        do ii = 1 to v_belt-tbl:Get(ii):
          v-belt-tbl-line = cast(v_belt-tbl:SubjectObjCurr, tank-imp_belt-tbl) .
          find first buf_pl-level-mm-imp EXCLUSIVE-LOCK where buf_pl-level-mm-imp.obj-code = buf_place-imp.obj-code
            and buf_pl-level-mm-imp.obj-type = buf_place-imp.obj-type
            and buf_pl-level-mm-imp.pl-code = buf_place-imp.pl-code
            and buf_pl-level-mm-imp.table-version = buf_place-imp.table-version
            and buf_pl-level-mm-imp.zone = v-belt-tbl-line:num-belt
            and buf_pl-level-mm-imp.level = v-belt-tbl-line:tbl-lvl no-error .
          if not AVAILABLE (buf_pl-level-mm-imp) then
          do:
            create buf_pl-level-mm-imp.
            assign
              buf_pl-level-mm-imp.obj-type  = buf_place-imp.obj-type
              buf_pl-level-mm-imp.obj-code  = buf_place-imp.obj-code
              buf_pl-level-mm-imp.pl-code   = buf_place-imp.pl-code
              buf_pl-level-mm-imp.table-version = buf_place-imp.table-version
              buf_pl-level-mm-imp.zone      = v-belt-tbl-line:num-belt
              buf_pl-level-mm-imp.min-level = v-belt-tbl-line:low-lvl
              buf_pl-level-mm-imp.max-level = v-belt-tbl-line:up-lvl
              buf_pl-level-mm-imp.level     = v-belt-tbl-line:tbl-lvl
              buf_pl-level-mm-imp.capacity  = v-belt-tbl-line:belt-capacity * 1000
            .
          end.
        end.
      end.
      cur-time (output v-today
               ,output v-time
               ).
      assign
        buf_place-imp.corr-date     = v-today
        buf_place-imp.corr-time     = v-time
      .
      run str/prep1C-status-cal-tbl.p (input buf_place-imp.table-version,
                                       input buf_place-imp.pl-code,
                                       input buf_place-imp.corr-date,
                                       input buf_place-imp.corr-time,
                                       input buf_place-imp.status_)
                                       no-error .
      find first buf_shift-obj
        where buf_shift-obj.obj-type = buf_clients.obj-type
          and buf_shift-obj.obj-code = buf_clients.obj-code
          and buf_shift-obj.status_ = 'тек':U
      use-index pi
      no-error.
      if not available buf_shift-obj
      then do :
        run str/apply_place-imp.p (input buf_place-imp.obj-type,
                                   input buf_place-imp.obj-code,
                                   input buf_place-imp.pl-code,
                                   input buf_place-imp.table-version)
                                   no-error .
        if error-status:error
        then do :
          Msg = "Ошибка при применении новых параметров резервуара " + v-tank:tank-code + " и градуировочных таблиц" .
          return error .
        end .
      end .
      else do :
        find first buf_place-attr exclusive-lock where buf_place-attr.obj-type = buf_place-imp.obj-type
                                                   and buf_place-attr.obj-code = buf_place-imp.obj-code
                                                   and buf_place-attr.pl-code  = buf_place-imp.pl-code
                                                   and buf_place-attr.attr-code = "pending-table-version"
                                                   no-error .
        if not available buf_place-attr
        then do :
          create buf_place-attr .
          assign
            buf_place-attr.obj-type = buf_place-imp.obj-type
            buf_place-attr.obj-code = buf_place-imp.obj-code
            buf_place-attr.pl-code  = buf_place-imp.pl-code
            buf_place-attr.attr-code = "pending-table-version"
          .
        end .
        assign
          buf_place-attr.attr-value = buf_place-attr.attr-value + "," + string(buf_place-imp.table-version)
          buf_place-attr.attr-value = trim(buf_place-attr.attr-value, ",")
        .
        find first buf_place-attr exclusive-lock where buf_place-attr.obj-type = buf_place-imp.obj-type
                                                   and buf_place-attr.obj-code = buf_place-imp.obj-code
                                                   and buf_place-attr.pl-code  = buf_place-imp.pl-code
                                                   and buf_place-attr.attr-code = "message-table-version"
                                                   no-error .
        if not available buf_place-attr
        then do :
          create buf_place-attr .
          assign
            buf_place-attr.obj-type = buf_place-imp.obj-type
            buf_place-attr.obj-code = buf_place-imp.obj-code
            buf_place-attr.pl-code  = buf_place-imp.pl-code
            buf_place-attr.attr-code = "message-table-version"
          .
        end .
        assign buf_place-attr.attr-value = "pending" .
      end .
    end.
    else do:
      Msg = "Уже есть данные для резервуара " + v-tank:tank-code + " с номером версии " + string(v-tank:table-version) .
      return true .
    end.
  end method.
end class.
