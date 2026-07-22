using Progress.Lang.*.
using ibs.th.skt.Commands.*.
block-level on error undo, throw.
class ibs.th.skt.Commands.DeferredCommand inherits ICommand:
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
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "премер отложеных запросов в сокет" get.
   define temp-table tt-filetime
       field ffile as character
       field ftime as decimal
       field fsec  as int
       index ffile ffile
       index ftime ftime
       .
   method override public void ContinueExecution(input req as IRequest, input resp as IResponse ):
      createfile().
      define variable vParam as longchar no-undo.
      define variable vFile as character no-undo.
      vFile = resp:ParamWait:getParamValue("file").
      if search(vFile) ne ?
      then do:
         resp:condition = resp:STSlist:WriteResponse:NameProp.
         resp:setContent(vFile).
         os-delete value(vFile).
      end.
   end method.
   method override public void Execute_( input req as IRequest, input resp as IResponse ):
      resp:condition = resp:STSlist:WaitResult:NameProp.
      define variable sss as integer no-undo.
      sss = random(100000,999999).
      define variable vfile as character no-undo.
      vfile = "d:\11\test_soc\" + string(sss) + ".txt".
      os-delete value(vfile).
      find first tt-filetime where tt-filetime.ffile eq vfile no-error.
      if not available tt-filetime
      then do:
        create tt-filetime.
        assign
           tt-filetime.ffile = vfile
           tt-filetime.fsec  = random(1,50)
        .
        tt-filetime.ftime = cur-time-mjd() + tt-filetime.fsec / 86400 .
      end.
      resp:ParamWait:setParam("file",vfile).
   end method.
   method private void createfile():
      define variable vtime as decimal no-undo.
      vtime = cur-time-mjd().
      for each tt-filetime where tt-filetime.ftime <= vtime:
         output to value(tt-filetime.ffile).
         put unformatted string(tt-filetime.fsec)skip.
         output close.
         delete tt-filetime.
      end.
   end.
end class.
