block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-pst.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-pst.p $":U .
define variable vss-description as character no-undo initial "Печать документов инвентаризации с группировкой по поставщикам    ":U .
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
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info7 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info7 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info7 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
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
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
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
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
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
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info7 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter rep-tipe             as character        no-undo.
define input parameter p-no-vat             as character        no-undo.
define input parameter p-grp                as character        no-undo.
define input parameter print-graft          as logical          no-undo.
define shared variable sort-name   as logical no-undo.
define shared variable sort-gr     as logical no-undo.
define shared variable CostPrice   as logical no-undo .
define shared variable PrintScale  as logical no-undo .
define variable l-b-stoim  as decimal no-undo .
define variable l-b-qnty   as decimal no-undo .
define variable l-a-stoim  as decimal no-undo .
define variable l-a-qnty   as decimal no-undo .
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .
define variable v-log as logical no-undo .
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable g#gds-engl      as logical      no-undo.
do
on error undo, return error
:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run get-gds-engl in p-mainmenu-handle (
      output g#gds-engl
  ).
  define variable skod as logical   no-undo .
  if sort-name = no then message "Сортировать по коду? (При ответе 'нет' сортировка по артикулу)."  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE skod.
  define variable sort-group as logical   no-undo .
  if sort-gr or p-grp = "yes" then assign sort-group = yes .
  else                             assign sort-group = no .
  DEFINE temp-table temp-str no-undo
    field   grp-name          as  char
    field   gds-name          as  char
    field   gds-code         as  integer
    field   artic             as  char
    field   prod-type         as  char
    field   prod-code         as  integer
    field   supp-type         as  char
    field   supp-code         as  integer
    field   supp-name          as  char
    field   b-code            as character
    field   tb-code           as  char
    field   OKEI              as  integer
    field   unit-base         as  char
    field   empty-scale       as logical
    field   Price-after       as decimal
    field   a-qnty            as decimal
    field   a-qnty1           as decimal
    field   a-stoim           as decimal
    field   price-befor       as decimal
    field   b-qnty            as decimal
    field   b-qnty1           as decimal
    field   b-stoim           as decimal
    field   ubl               as decimal
    INDEX pi  IS PRIMARY   supp-type supp-code artic prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-name
    INDEX pi3              tb-code
  .
  def stream Out-Stream.
  def buffer This_Object      for ub.clients .
  def buffer buf_doc-line     for ub.doc-line .
  def buffer buf_goods        for ub.goods .
  def buffer buf_doc-line-sum for ub.doc-line-sum .
  def buffer buf_gds-dtl      for ub.gds-dtl .
  def buffer buf_gds-prt      for ub.gds-prt .
  def buffer buf_parts        for ub.parts .
  define buffer bf_doc-attr   for ub.doc-attr .
  define buffer buf_clients   for ub.clients.
  define variable qnty as decimal   no-undo .
  define variable sum  as decimal   no-undo .
  define variable is-after      as logical initial yes no-undo .
  define variable is-after-cli  as logical initial yes no-undo .
  define variable is-wastage    as logical initial yes no-undo .
  define variable v-root-node   as integer   no-undo .
  define variable num-ln as integer   no-undo .
  define variable sum-a-qnty   as decimal initial 0  no-undo .
  define variable sum-b-qnty   as decimal initial 0  no-undo .
  define variable sum-a-qnty1  as decimal initial 0  no-undo .
  define variable sum-b-qnty1  as decimal initial 0  no-undo .
  define variable sum-a-stoim  as decimal initial 0  no-undo .
  define variable sum-b-stoim  as decimal initial 0  no-undo .
  define variable sum-ubl      as decimal initial 0  no-undo .
  define variable sum1-a-qnty  as decimal initial 0  no-undo .
  define variable sum1-b-qnty  as decimal initial 0  no-undo .
  define variable sum1-a-qnty1 as decimal initial 0  no-undo .
  define variable sum1-b-qnty1 as decimal initial 0  no-undo .
  define variable sum1-a-stoim as decimal initial 0  no-undo .
  define variable sum1-b-stoim as decimal initial 0  no-undo .
  define variable p-sum-a-qnty   as decimal initial 0  no-undo .
  define variable p-sum-b-qnty   as decimal initial 0  no-undo .
  define variable p-sum-a-qnty1  as decimal initial 0  no-undo .
  define variable p-sum-b-qnty1  as decimal initial 0  no-undo .
  define variable p-sum-a-stoim  as decimal initial 0  no-undo .
  define variable p-sum-b-stoim  as decimal initial 0  no-undo .
  define variable p-sum-ubl      as decimal initial 0  no-undo .
  def var FullNameGds as character no-undo .
  def var gds-str as char no-undo.
  def var gds-str1 as char no-undo.
  def var gds-str2 as char no-undo.
  def var i as int no-undo.
  def var j as int no-undo.
  define variable Counter1 as integer init 0  no-undo .
  def var LineBuf       as char    no-undo.
  def var Line       as char    no-undo.
  def var UndLine    as char    no-undo.
  def var     Lines_Counter as   int  init 0  no-undo.
  def var     Tmp_Counter   as   int  init 0  no-undo.
  def var     tdoc-date     like ub.trn-doc.doc-date no-undo.
  def var     tdoc-code     like ub.trn-doc.doc-code no-undo.
  def var  PgQnty            as  dec no-undo.
  def var  PgQnty-v          as  dec no-undo.
  def var  PgSum             as  dec no-undo.
  def var  PgQnty-b          as  dec no-undo.
  def var  PgQnty-b-v        as  dec no-undo.
  def var  PgSum-b           as  dec no-undo.
  def var  PgNPP             as  int no-undo.
  define variable UBL-v      as decimal   no-undo .
  define variable b-code     as integer   no-undo .
  def var  PropisQnty        as  char no-undo.
  def var  PropisSumall      as  char no-undo.
  def var  Propiscount       as  char no-undo.
  def var  abbr              as  char no-undo.
  def var  pp                as  char no-undo.
  def var sym1 as char  init ":"   no-undo.
  def var sym2 as char  init ":"   no-undo.
  def var sym3 as char  init ":"   no-undo.
  def var sym4 as char  init ":"   no-undo.
  def var sym5 as char  init ":"   no-undo.
  def var sym6 as char  init ":"   no-undo.
  def var sym7 as char  init ":"   no-undo.
  def var sym8 as char  init ":"   no-undo.
  def var sym9 as char  init ":"   no-undo.
  def var sym10 as char init ":"   no-undo.
  def var sym11 as char init ":"   no-undo.
  def var sym12 as char init ":"   no-undo.
  def var sym13 as char init ":"   no-undo.
  def var sym14 as char init ":"   no-undo.
  def var sym15 as char init ":"   no-undo.
  FUNCTION f-wp-qnty  char (INPUT p-dec as decimal ).
    def var  pr as char no-undo .
    run rep/wp-qnty.p ( p-dec, output Pr ).
    RETURN( Pr ) .
  END FUNCTION.
  FUNCTION f-wp-sum  char (INPUT p-dec as decimal ).
    def var  pr as char no-undo .
    if NOT PrintRubl then  run rep/wp.p ( input p-mainmenu-handle, p-dec, output Pr, output abbr).
    else                   run rep/wp-rub.p ( p-dec, output pr, output abbr).
    RETURN( Pr ) .
  END FUNCTION.
  DEFINE FRAME invent
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C5 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C17 format "X(17)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C40 format "X(40)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "Код товара! ! ! ! ":C10 format "X(9)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.OKEI COLUMN-LABEL "Ед.!----!Код !по!ОКЕИ":C4 format ">>>>" space(0)
        sym6 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.unit-base COLUMN-LABEL  "изм.!----!Наим!енов!ание" format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.Price-after COLUMN-LABEL " ! Цена ! ! ! ":C13 format "->>>>>9.99" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty COLUMN-LABEL "Фактическое!-------------!Количество! ! ":C13 format "->>>>>>>9.<<<" space(0)
        sym9 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.a-stoim COLUMN-LABEL " наличие !--------------!Сумма! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.Price-befor COLUMN-LABEL "По данным!----------------!Цена! ! ":C17 format "->>>>>9.99" space(0)
        sym11 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty COLUMN-LABEL "бухгалтерского!---------------!Количество! ! ":C17 format "->>>>>>>9.<<<" space(0)
        sym12 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.b-stoim COLUMN-LABEL " учета !----------------!Сумма! ! ":C17 format "->>>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Инвентаризационная опись N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp) AT 160 format "X(27)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 180 format "X(13)" SKIP
        UndLine format "X(185)" AT 1
        with width 232 down stream-io use-text NO-BOX.
DEFINE FRAME sl
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C5 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C17 format "X(17)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C40 format "X(40)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "Код товара! ! ! ! ":C13 format "X(13)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.OKEI COLUMN-LABEL "Ед.!----!Код ! по !ОКЕИ" format ">>>>" space(0)
        sym6 column-label         " !-!:!:!:" format "X(1)" space(0)
        temp-str.unit-base COLUMN-LABEL  "изм.!----!Наим!енов!ание" format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty COLUMN-LABEL "Излишек!Количество! ! ! ":C12 format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-stoim COLUMN-LABEL "Излишек!Сумма! ! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty COLUMN-LABEL "Недостача!Количество! ! ! ":C12 format "->>>>>>>9.<<<" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-stoim COLUMN-LABEL "Недостача!Сумма! ! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.UBL COLUMN-LABEL "Списано!в пределах!норм!естественной!убыли":C13 format "->>>>>>>>>.<<" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Сличительная ведомость N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 134 format "X(19)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 160 format "X(13)" SKIP
        UndLine format "X(162)" AT 1
        with width 232 down stream-io use-text NO-BOX.
  FIND ub.trn-doc WHERE recid(ub.trn-doc) = rec_id NO-LOCK .
  assign
    tdoc-date = (if ub.trn-doc.status_ <> 'факт':U then ub.trn-doc.doc-date else ub.trn-doc.fact-date)
    tdoc-code = ub.trn-doc.doc-code
  .
  run Check-Doc-Sum in this-procedure no-error  .
  if error-status :error then return error .
  if rep-tipe <> "sl" and PrintScale = true THEN DO:
    message "Инвентаризационная опись не проводится с разбиением по признакам !" view-as alert-box . PrintScale = false .
  End.
  if session :set-wait-state( "compiler":U ) then.
output STREAM Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  define variable v-prn0 as character no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      if thbjattr_thbj-attr.prop-code = 'invprn0'  then v-prn0      = string( thbjattr_thbj-attr.property-value-logical) .
  end.
  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .
  if  CostPrice then DO:
    if p-no-vat = "no" then do:
      IF PrintRubl THEN Assign PP = "Учетные цены ".
      Else Assign PP = "Учетные цены (б.в.)" .
    end.
    else do:
      IF PrintRubl THEN Assign PP = "Учетные цены без НДС ".
      Else Assign PP = "Учетные цены без НДС (б.в.)" .
    end.
  End.
  Else DO:
    IF PrintRubl THEN Assign PP = "Цены док-та".
    Else Assign PP = "Цены док-та (б.в.)" .
  End.
  run waitfram-show in this-procedure ( input 'Подождите ...' ).
  FIND This_Object  WHERE This_Object.obj-type = ub.trn-doc.obj-type AND This_Object.obj-code = ub.trn-doc.obj-code  NO-LOCK.
  FIND ub.clients      WHERE ub.clients.obj-type     = 'орг':U           AND ub.clients.obj-code     = ub.trn-doc.host-code NO-LOCK.
  run PrintTitul in this-procedure .
  if rep-tipe = "invent" THEN  DO:
    FORM with frame invent .
    FORM HEADER
      LineBuf format "X(185)" SKIP
      String(sym1 + String(PgQnty ,  "->>>>>>>>>9.<<<" ) + sym2 + String(PgSum , "->>>>>>>>>>9.99"   ) +  sym6 + "                 " +
             sym3 + String(PgQnty-b,  "->>>>>>>>>>>>9.<<<" ) + sym4 + String(PgSum-b , "->>>>>>>>>>>>>9.99"   ) + sym5)  at 100 Format "x(90)" skip
      "Итого по странице : " skip
      "а) количество порядковых номеров " + string(PgNPP) + " (" + f-wp-qnty (decimal(PgNPP)) + ")" format "X(185)" AT 18  skip
      "б) общее количество единиц фактически " + string(PgQnty) + " (" + f-wp-qnty (decimal(PgQnty)) + ")"  format "X(185)" AT 18  SKIP
      "в) на сумму фактически " + trim(string(PgSum, "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr + " (" + f-wp-sum (decimal(PgSum)) + ")"  format "X(185)" AT 18 SKIP(1)
      "Вкладной лист к форме № ИНВ-3 №  " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") format "x(170)" AT 30 SKIP
    with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW stream Out-Stream FRAME BottomFrame .
  End.
  if rep-tipe begins "invent" THEN DO:
    PUT stream Out-Stream SPACE(35) string ("Инвентаризационная опись N " + tdoc-code ) format "x(50)" SKIP
      SPACE(10) string (string (v-cntxt-obj-type , "X(3)") + ": " + trim(This_Object.obj-name) ) format "x(50)"
      string ("дата инвентаризации : " + string (tdoc-date, "99.99.9999") ) format "x(50)" SKIP.
  End.
  if rep-tipe = "sl" THEN  FORM with frame sl .
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 10 ) = 0 then 100 else integer( 10 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buf_doc-line no-lock where buf_doc-line.doc-code = trn-doc.doc-code :
    find first buf_goods no-lock
      where buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
        and buf_goods.artic     = buf_doc-line.artic
    no-error .
    find first ub.units no-lock  where ub.units.unit-name = buf_goods.unit-base  no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output b-code
  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip
        "Артикул товара" skip buf_goods.artic   view-as alert-box error .
    end.
    if CostPrice = false then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  b-code
  ,input  0
  ,input  trn-doc.fact-order
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
           if v-cur-pr = ? then v-cur-pr = 0.
    end.
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH('Документ инвентаризации ')) / 2
    RecordsString = fill(' ',v-kol-spice) + string('Документ инвентаризации ')
    .
 Assign
    v-kol-spice = (50 - LENGTH('(по поставщикам)')) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string('(по поставщикам)')
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    for each buf_parts no-lock  where
                buf_parts.obj-type    = buf_doc-line.obj-type and
                buf_parts.obj-code    = buf_doc-line.obj-code and
                buf_parts.artic       = buf_goods.artic       and
                buf_parts.prod-type   = buf_goods.prod-type   and
                buf_parts.prod-code   = buf_goods.prod-code   and
                buf_parts.out-code    = buf_doc-line.doc-code
    :
           find first temp-str where
                temp-str.supp-type   = buf_parts.supp-type and
                temp-str.supp-code   = buf_parts.supp-code and
                temp-str.artic       = buf_goods.artic     and
                temp-str.prod-type   = buf_goods.prod-type and
                temp-str.prod-code   = buf_goods.prod-code
                no-error .
           if not  available temp-str then do:
              create temp-str .
               find first buf_clients where buf_clients.obj-code = buf_parts.supp-code and
                                           buf_clients.obj-type = buf_parts.supp-type no-lock no-error .
                assign
                  temp-str.supp-type   = buf_parts.supp-type
                  temp-str.supp-code   = buf_parts.supp-code
                  temp-str.supp-name   = "(" + buf_parts.supp-type  + " " + string(buf_parts.supp-code) + ") "   +
                                         if available buf_clients then  buf_clients.obj-name
                                         else "***"
                  temp-str.b-code      = string(b-code)
                  temp-str.grp-name    = buf_goods.grp-name
                  temp-str.artic       = buf_goods.artic
                  temp-str.prod-type   = buf_goods.prod-type
                  temp-str.prod-code   = buf_goods.prod-code
                  temp-str.gds-code    = buf_goods.gds-code
                  temp-str.OKEI        = ub.units.OKEI
                  temp-str.unit-base   = buf_goods.unit-base
                  temp-str.tb-code     = buf_goods.sort
                .
                  if g#gds-engl then assign temp-str.gds-name = buf_goods.engl-name.
                                else assign temp-str.gds-name = buf_goods.gds-name.
              end.
    if rep-tipe = "sl" then do:
        if PrintRubl then assign sum =  buf_parts.price-rubl * buf_parts.fact-qnty .
                     else assign sum =  buf_parts.price-base * buf_parts.fact-qnty .
        assign
          qnty = buf_parts.fact-qnty
        .
        if sum >= 0 then do:
          assign
            temp-str.a-qnty      = temp-str.a-qnty  + qnty
            temp-str.a-stoim     = temp-str.a-stoim + sum
            temp-str.a-qnty1     = temp-str.a-qnty1 + buf_parts.cli-qnty
            temp-str.ubl         = 0
          .
        end.
        else do:
          assign
            temp-str.b-qnty      = temp-str.b-qnty  - qnty
            temp-str.b-stoim     = temp-str.b-stoim - sum
            temp-str.b-qnty1     = temp-str.b-qnty1 - buf_parts.cli-qnty
            temp-str.ubl         = 0
            sum = - sum
          .
          run ubl in this-procedure .
        end.
    end.
  end.
  if rep-tipe = "invent" then do:
    run partslib-init-temp-parts-by-factord in this-procedure
      (input  buf_doc-line.obj-type
      ,input  buf_doc-line.obj-code
      ,input  buf_doc-line.artic
      ,input  buf_doc-line.prod-type
      ,input  buf_doc-line.prod-code
      ,input  buf_doc-line.fact-order
      ,input  true
      ) .
     for each temp-parts :
       if not can-find (first   temp-str where
                temp-str.supp-type   = temp-parts.supp-type and
                temp-str.supp-code   = temp-parts.supp-code and
                temp-str.artic       = buf_goods.artic     and
                temp-str.prod-type   = buf_goods.prod-type and
                temp-str.prod-code   = buf_goods.prod-code ) then do:
              create temp-str .
               find first buf_clients where buf_clients.obj-code = temp-parts.supp-code and
                                           buf_clients.obj-type = temp-parts.supp-type no-lock no-error .
                assign
                  temp-str.supp-type   = temp-parts.supp-type
                  temp-str.supp-code   = temp-parts.supp-code
                  temp-str.supp-name   = "(" + temp-parts.supp-type  + " " + string(temp-parts.supp-code) + ") "   +
                                    ( if available buf_clients then  buf_clients.obj-name else "***")
                  temp-str.b-code      = string(b-code)
                  temp-str.grp-name    = buf_goods.grp-name
                  temp-str.artic       = buf_goods.artic
                  temp-str.prod-type   = buf_goods.prod-type
                  temp-str.prod-code   = buf_goods.prod-code
                  temp-str.gds-code    = buf_goods.gds-code
                  temp-str.OKEI        = ub.units.OKEI
                  temp-str.unit-base   = buf_goods.unit-base
                  temp-str.tb-code     = buf_goods.sort
                .
                  if g#gds-engl then assign temp-str.gds-name = buf_goods.engl-name.
                                else assign temp-str.gds-name = buf_goods.gds-name.
              end.
     end.
     for each temp-str where
          temp-str.gds-code    = buf_goods.gds-code :
          l-b-qnty = 0 .
          l-b-stoim = 0 .
          for each temp-parts where
              temp-parts.host-code = trn-doc.host-code      and
              temp-parts.supp-type = temp-str.supp-type     and
              temp-parts.supp-code = temp-str.supp-code     and
              temp-parts.obj-type  = buf_doc-line.obj-type  and
              temp-parts.obj-code  = buf_doc-line.obj-code  and
              temp-parts.artic     = buf_doc-line.artic     and
              temp-parts.prod-type = buf_doc-line.prod-type and
              temp-parts.prod-code = buf_doc-line.prod-code :
              assign
                l-b-stoim = l-b-stoim + ( temp-parts.fact-qnty * (IF PrintRubl THEN temp-parts.price-rubl else  temp-parts.price-base ))
                l-b-qnty  = l-b-qnty + temp-parts.fact-qnty
                .
          end.
          assign
             temp-str.b-stoim = l-b-stoim
             temp-str.b-qnty  = l-b-qnty
             temp-str.price-befor = temp-str.b-stoim / temp-str.b-qnty
          .
          if temp-str.price-befor = ? then assign temp-str.price-befor = 0 .
     end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input  buf_doc-line.obj-type
      ,input  buf_doc-line.obj-code
      ,input  buf_doc-line.artic
      ,input  buf_doc-line.prod-type
      ,input  buf_doc-line.prod-code
      ,input  buf_doc-line.fact-order
      ,input  false
      ) .
     for each temp-str where
          temp-str.gds-code    = buf_goods.gds-code:
          l-a-qnty = 0 .
          l-a-stoim = 0 .
          for each temp-parts where
              temp-parts.host-code = trn-doc.host-code      and
              temp-parts.supp-type = temp-str.supp-type     and
              temp-parts.supp-code = temp-str.supp-code     and
              temp-parts.obj-type  = buf_doc-line.obj-type  and
              temp-parts.obj-code  = buf_doc-line.obj-code  and
              temp-parts.artic     = buf_doc-line.artic     and
              temp-parts.prod-type = buf_doc-line.prod-type and
              temp-parts.prod-code = buf_doc-line.prod-code :
              assign
                l-a-stoim = l-a-stoim + ( temp-parts.fact-qnty * (IF PrintRubl THEN temp-parts.price-rubl else  temp-parts.price-base ))
                l-a-qnty  = l-a-qnty + temp-parts.fact-qnty
                .
          end.
          assign
             temp-str.a-stoim = l-a-stoim
             temp-str.a-qnty  = l-a-qnty
             temp-str.price-after = temp-str.a-stoim / temp-str.a-qnty
             .
          if temp-str.price-after = ? then assign temp-str.price-after = 0 .
          if   v-prn0 = "no" then do:
            if temp-str.a-qnty = 0 and
               temp-str.a-stoim = 0 and
               temp-str.b-qnty = 0 and
               temp-str.b-stoim = 0  then delete temp-str .
          end.
     end.
  end.
  else do:
  end.
  if CostPrice = false then do:
     for each temp-str where
          temp-str.gds-code    = buf_goods.gds-code:
                assign
                temp-str.a-stoim      =  temp-str.a-qnty * v-cur-pr
                temp-str.b-stoim      =  temp-str.b-qnty * v-cur-pr
                temp-str.Price-after  = v-cur-pr
                temp-str.Price-befor  = v-cur-pr
                .
     end.
  end.
 end.
  if sort-group = yes then do:
    for each temp-str no-lock break by temp-str.supp-name by temp-str.grp-name by if sort-name then  temp-str.gds-name Else ( if skod then  temp-str.b-code Else temp-str.artic ) :
      if first-of(temp-str.supp-name) then run print-supp in this-procedure .
          if p-grp = "no" and first-of( temp-str.grp-name) then run print-grp in this-procedure .
          run print-line in this-procedure .
          if last-of( temp-str.grp-name) then  run print-grp-itog in this-procedure .
      if last-of( temp-str.supp-name) then  run print-supp-itog in this-procedure .
    end.
  end.
  else do:
    for each temp-str no-lock break by temp-str.supp-name by if sort-name then  temp-str.gds-name Else ( if skod then  temp-str.b-code Else temp-str.artic ) :
      if first-of(temp-str.supp-name) then run print-supp in this-procedure .
        run print-line in this-procedure .
      if last-of( temp-str.supp-name) then  run print-supp-itog in this-procedure .
    end.
  end.
  run print-all-itog in this-procedure .
  run on-same-page in this-procedure (input 14) .
  run PrintPodval in this-procedure .
  output stream Out-Stream CLOSE .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  if session :set-wait-state( "":U ) then.
  run waitfram-hide in this-procedure.
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
procedure print-grp :
  do  on error undo, return error return-value  :
    case rep-tipe :
      when "invent" THEN DO:
        DOWN stream Out-Stream 1 with FRAME invent .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT "X(185)"  skip  .
      End.
      when  "sl"  THEN DO:
        DOWN stream Out-Stream 1 with FRAME sl .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT "X(162)"  skip  .
      End.
    End.
  end.
end procedure.
procedure print-supp :
  do  on error undo, return error return-value  :
    case rep-tipe :
      when "invent" THEN DO:
        DOWN stream Out-Stream 1 with FRAME invent .
        PUT stream Out-Stream UNFORMATTED String("______ПОСТАВЩИК : " + TRIM(CAPS(temp-str.supp-name)) + UndLine)  FORMAT "X(185)"  skip  .
      End.
      when  "sl"  THEN DO:
        DOWN stream Out-Stream 1 with FRAME sl .
        PUT stream Out-Stream UNFORMATTED String("______ПОСТАВЩИК : " + TRIM(CAPS(temp-str.supp-name)) + UndLine)  FORMAT "X(162)"  skip  .
      End.
    End.
  end.
end procedure.
procedure print-line :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent"      THEN DO:
def var vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  assign Lines_Counter = Lines_Counter + 1  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .
  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    p-sum-a-qnty    = p-sum-a-qnty    + temp-str.a-qnty
    p-sum-b-qnty    = p-sum-b-qnty    + temp-str.b-qnty
    p-sum-a-qnty1   = p-sum-a-qnty1   + temp-str.a-qnty1
    p-sum-b-qnty1   = p-sum-b-qnty1   + temp-str.b-qnty1
    p-sum-a-stoim   = p-sum-a-stoim   + temp-str.a-stoim
    p-sum-b-stoim   = p-sum-b-stoim   + temp-str.b-stoim
    p-sum-ubl       = p-sum-ubl       + temp-str.ubl
    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
  .
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END.
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym8 sym11   temp-str.price-befor temp-str.Price-after
    sym7     temp-str.a-qnty
    sym9     temp-str.a-stoim
    sym10    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym13
     with FRAME invent.
  DOWN stream Out-Stream 1 with FRAME invent .
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(185)" SKIP.
end.
   End.
      when  "sl"         THEN DO:
def var vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  assign Lines_Counter = Lines_Counter + 1  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .
  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    p-sum-a-qnty    = p-sum-a-qnty    + temp-str.a-qnty
    p-sum-b-qnty    = p-sum-b-qnty    + temp-str.b-qnty
    p-sum-a-qnty1   = p-sum-a-qnty1   + temp-str.a-qnty1
    p-sum-b-qnty1   = p-sum-b-qnty1   + temp-str.b-qnty1
    p-sum-a-stoim   = p-sum-a-stoim   + temp-str.a-stoim
    p-sum-b-stoim   = p-sum-b-stoim   + temp-str.b-stoim
    p-sum-ubl       = p-sum-ubl       + temp-str.ubl
    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
  .
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END.
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym14 temp-str.UBL
    sym7     temp-str.a-qnty
    sym9     temp-str.a-stoim
    sym10    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym13
     with FRAME sl.
  DOWN stream Out-Stream 1 with FRAME sl .
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(162)" SKIP.
end.
   End.
    End.
  end.
end procedure.
procedure print-grp-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          sum-a-qnty   @ temp-str.a-qnty
          sum-a-stoim  @ temp-str.a-stoim
          sum-b-qnty   @ temp-str.b-qnty
          sum-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = false THEN Put stream Out-Stream LineBuf format "X(185)" SKIP.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13
          sym14 sum-ubl @ temp-str.UBL
          sum-a-qnty   @ temp-str.a-qnty
          sum-a-stoim  @ temp-str.a-stoim
          sum-b-qnty   @ temp-str.b-qnty
          sum-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        if print-graft = false THEN Put stream Out-Stream LineBuf format "X(162)" SKIP.
      End.
    End.
    assign
      sum-a-qnty  = 0
      sum-b-qnty  = 0
      sum-a-qnty1 = 0
      sum-b-qnty1 = 0
      sum-a-stoim = 0
      sum-b-stoim = 0
      sum-ubl     = 0
    .
  end.
end procedure.
procedure print-supp-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.supp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          p-sum-a-qnty   @ temp-str.a-qnty
          p-sum-a-stoim  @ temp-str.a-stoim
          p-sum-b-qnty   @ temp-str.b-qnty
          p-sum-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = false THEN Put stream Out-Stream LineBuf format "X(185)" SKIP.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.supp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13
          sym14 sum-ubl @ temp-str.UBL
          p-sum-a-qnty   @ temp-str.a-qnty
          p-sum-a-stoim  @ temp-str.a-stoim
          p-sum-b-qnty   @ temp-str.b-qnty
          p-sum-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        if print-graft = false THEN Put stream Out-Stream LineBuf format "X(162)" SKIP.
      End.
    End.
    assign
      p-sum-a-qnty  = 0
      p-sum-b-qnty  = 0
      p-sum-a-qnty1 = 0
      p-sum-b-qnty1 = 0
      p-sum-a-stoim = 0
      p-sum-b-stoim = 0
      p-sum-ubl     = 0
    .
  end.
end procedure.
procedure print-all-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          sum1-a-qnty   @ temp-str.a-qnty
          sum1-a-stoim  @ temp-str.a-stoim
          sum1-b-qnty   @ temp-str.b-qnty
          sum1-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        Put stream Out-Stream LineBuf format "X(185)" SKIP.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym14
          sum1-a-qnty   @ temp-str.a-qnty
          sum1-a-stoim  @ temp-str.a-stoim
          sum1-b-qnty   @ temp-str.b-qnty
          sum1-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        Put stream Out-Stream LineBuf format "X(162)" SKIP.
      End.
    End.
  end.
end procedure.
procedure PrintTitul :
  do  on error undo, return error return-value  :
    case ub.clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = ub.clients.obj-code NO-LOCK .
            if available ub.firm
            then do:
                assign
                    t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
                    t-addres = t-addres
                        + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
                            then ""
                            else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) )
                          )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                        + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( ", " + trim( ub.firm.addres2 ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-phone = ub.firm.phone
                    t-inn   = ub.firm.inn
                    t-okpo  = ub.firm.okpo
                .
            end.
       end.
       when 'маг':U
       then do:
            FIND ub.shop WHERE ub.shop.obj-code = ub.clients.obj-code NO-LOCK .
            if available ub.shop
            then do:
                assign
                    t-addres = ( if trim( shop.addres1 ) <> "" then ( trim( shop.addres1 ) ) else "" )
                            + ( if trim( shop.addres2 ) <> "" then ( ", " + trim( shop.addres2 ) ) else "" )
                    t-phone = shop.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'скл':U
       then do:
            FIND ub.store WHERE ub.store.obj-code = ub.clients.obj-code NO-LOCK .
            if available ub.store
            then do:
                assign
                    t-addres = ( if trim( ub.store.addres1 ) <> "" then ( trim( ub.store.addres1 ) ) else "" )
                            + ( if trim( ub.store.addres2 ) <> "" then ( ", " + trim( ub.store.addres2 ) ) else "" )
                    t-phone = ub.store.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'чел':U
       then do:
            find ub.person where ub.person.psn-code = ub.clients.obj-code no-lock .
            if available ub.person
            then do:
                assign
                    t-addres = ( if ub.person.ind <> 0 and ub.person.ind <> ? then string( ub.person.ind ) else "" )
                                + ( if  ub.person.city <> ? and trim(ub.person.city) <> "" then ( ", " + trim( ub.person.city ) ) else "" )
                                + ( if  ub.person.address <> ? and trim(ub.person.address) <> "" then ( ", " + trim( ub.person.address ) ) else "" )
                    t-phone = ub.person.phone1
                    t-inn = ub.person.inn
                    t-okpo = ub.person.okpo
                .
            end.
       end.
    end case.
    if rep-tipe begins "invent"   THEN
      PUT STREAM Out-Stream
        space(5) Line format  "X(19)" AT 180 skip
        space(5) "| " AT 180 'код':U AT 188 "|" AT 198 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0317004" "|" AT 198 skip
        space(5) string( "ИНН " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
                              + t-addres + t-phone) format "X(160)"
                   "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "X(160)" "| " AT 180  "|" AT 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "X(160)"
                       "номер" format "X(5)" AT 174 "| " AT 180 "|" AT 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "X(20)" AT 67
                       "дата" format "X(4)" AT 175 "| " AT 180 "|" AT 198 skip
        space(5) "Дата начала инвентаризации" format "X(26)" AT 153 "| " AT 180 ub.trn-doc.doc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата окончания инвентаризации" format "X(29)" AT 150 "| " AT 180
                       (if ub.trn-doc.status_ <> 'факт':U then tdoc-date else ?) format "99/99/9999" "|" AT 198 skip
        space(5) "Вид операции" format "X(12)" AT 167 "| " AT 180 " инвентаризация" format "X(16)" "|" AT 198 skip
        space(5) Line format  "X(19)" AT 180 skip(2)
        space(79) Line format "X(33)" skip
        space(54) string( "ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if ub.trn-doc.status_ <> 'факт':U then string( "(" + CAPS(ub.trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip
        space(79) Line format "X(33)" skip
        space(54) "товарно-материальных ценностей" format "X(30)" skip(1)
        space(5) UndLine format "X(191)" " ," skip
        space(52) "вид товарно-материальных ценностей" format "X(34)" skip(1)
        space(5) string( "находящиеся " + UndLine ) format "X(193)" skip
        space(52) "в собственности организации, полученные для переработки" format "X(55)" skip(2)
        space(60) "РАСПИСКА" format "X(8)" skip(2)
        space(10) "К началу проведения инвентаризации все расходные и приходные документы на товарно-материальные ценности сданы" format "X(188)" skip
        space(5) "в бухгалтерию и все  товарно-материальные ценности,  поступившие  на  мою (нашу) ответственность,  оприходованы,  а выбывшие  списаны" format "X(193)" SKIP
        space(5) "в расход." format "X(193)" SKIP(1)
        space(5) "Материально ответственное (ые) лицо (а): " format "X(41)"
                       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
        "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
        UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
        "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
        space(5) "Произведено снятие фактических остатков ценностей по состоянию на <<       >> _________________        г." format "X(193)" SKIP(4)
      .
    Else
    PUT STREAM Out-Stream
        space(5) Line format  "X(19)" AT 180 skip
        space(5) "| " AT 180 'код':U AT 188 "|" AT 198 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0317017" "|" AT 198 skip
        space(5) string( "ИНН " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
                                  + t-addres + t-phone) format "X(160)"
                       "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "X(160)" "| " AT 180  "|" AT 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "X(160)"
                       "номер" format "X(5)" AT 174 "| " AT 180 "|" AT 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "X(20)" AT 67
                       "дата" format "X(4)" AT 175 "| " AT 180 "|" AT 198 skip
        space(5) "Дата начала инвентаризации" format "X(26)" AT 153 "| " AT 180 ub.trn-doc.doc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата окончания инвентаризации" format "X(29)" AT 150 "| " AT 180
                       (if ub.trn-doc.status_ <> 'факт':U then tdoc-date else ?) format "99/99/9999" "|" AT 198 skip
        space(5) "Вид операции" format "X(12)" AT 167 "| " AT 180 " инвентаризация" format "X(16)" "|" AT 198 skip
        space(5) Line format  "X(19)" AT 180 skip(2)
        space(79) Line format "X(33)" skip
        space(56) string( "СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if ub.trn-doc.status_ <> 'факт':U then string( "(" + CAPS(ub.trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip
        space(79) Line format "X(33)" skip
        space(40) "результатов инвентаризации товарно-материальных ценностей" format "X(130)" skip(2)
        space(52) "Проведена инвентаризация фактического наличия ценностей, находящихся на ответственном хранении" format "X(134)" skip(3)
         UndLine format "X(25)" AT 10 UndLine format "X(90)" at 50 SKIP
        "должность" format "X(25)" AT 10 "фамилия,имя,отчество" format "X(50)"   AT 50 SKIP(1)
        UndLine format "X(25)" AT 10 UndLine format "X(90)" at 50 SKIP
        "должность" format "X(25)" AT 10 "фамилия,имя,отчество" format "X(50)"  AT 50 SKIP(1)
        space(5) "По состоянию на <<       >> _________________        г." format "X(193)" SKIP(2)
        space(5) "При инвентаризации установлено следующее :" SKIP
      .
    PAGE stream Out-Stream.
  end.
end procedure.
procedure PrintPodval :
  do on error undo, return error return-value  :
    run rep/wp-qnty.p ( num-ln , output PropisCount).
    if PropisCount = '' Then PropisCount = 'Ноль'.
    if rep-tipe begins "invent"  THEN DO:
      PAGE stream Out-Stream.
      HIDE stream Out-Stream FRAME BottomFrame .
      HIDE stream Out-Stream FRAME BottomFrame2 .
      run rep/wp-qnty.p ( sum1-a-qnty , output PropisQnty).
      if PropisQnty = '' Then PropisQnty = 'Ноль'.
      if NOT PrintRubl then  run rep/wp.p ( input p-mainmenu-handle, sum1-a-stoim, output PropisSumall, output abbr).
      Else                   run rep/wp-rub.p ( sum1-a-stoim , output PropisSumall , output abbr).
      PUT  STREAM Out-Stream
              "Итого по описи :" Skip
                "а) количество порядковых номеров: " + string( num-ln ) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
                "б) общее количество единиц фактически: " + string( sum1-a-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
                "в) на сумму фактически : " + trim(string((sum1-a-stoim ), "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr +
                              " (" + PropisSumall + ")"  format "x(179)"                                                 at 18 SKIP(1)
              "   Все цены, подсчеты итогов по строкам, страницам и в целом по инвентаризационной описи товарно-материальных ценностей проверены." SKIP
              "Председатель комиссии: " format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              " " format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "Члены комиссии: " format "X(25)" AT 10 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "   Все товарно-материальные ценности, поименованные  в  настоящей  инвентаризационной  описи  с № ___________ по № _________" SKIP
              "комиссией проверены в натуре в моем (нашем) личном присутствии  и внесены в опись, в связи с чем претензий к инвентаризационной " SKIP
              "комиссии не имею (не имеем). Товарно-материальные ценности, перечисленные в описи, находятся на моем (нашем) ответственном хранении." SKIP(1)
              "   Лицо(а), ответственное(ые) за сохранность товарно-материальных ценностей : " SKIP(1)
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP(1)
              "<<       >> _________________        г. "   SKIP(1)
              "Указанные в настоящей описи данные и расчеты проверил"
                  LineBuf format "X(25)" AT 10 LineBuf format "X(25)"   AT 40 LineBuf format "X(50)"               AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "<<       >> _________________        г. "
      .
    End.
    ELSE DO:
      if NOT PrintRubl then run rep/wp.p ( input p-mainmenu-handle, (sum1-a-stoim - sum1-b-stoim), output PropisSumall, output abbr).
      else                  run rep/wp-rub.p ( ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr).
      run rep/wp-qnty.p ( (sum1-a-qnty - sum1-b-qnty), output PropisQnty).
      if PropisQnty  = '' Then PropisQnty = 'Ноль'.
      PUT  STREAM Out-Stream
           "Итого по ведомости :" Skip
           "а) количество порядковых номеров: " + string(num-ln) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
           "б) общее количество единиц (излишки - недостача): " + string( sum1-a-qnty - sum1-b-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
           "в) на сумму (излишки - недостача) : " + trim(string((sum1-a-stoim - sum1-b-stoim ), "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr + " (" + PropisSumall + ")"  format "x(179)"    at 18 SKIP(1)
           "С результатами сличения ознакомлен : "  Skip "        Бухгалтер" LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
           "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP(1) "Материально ответственное(ые)  лицо(а)"  Skip
           LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
           "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
           LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
           "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP(1)
      .
    End.
  end.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then  page stream Out-Stream .
end procedure.
procedure Check-Doc-Sum :
  do  on error undo, return error return-value  :
    define variable v-attr-value as character no-undo .
    define variable v-attr-type as character no-undo .
    define variable ask as logical   no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'addsum':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    if ub.trn-doc.status_ = 'факт':U then do:
      case rep-tipe:
        when "invent" then do:
          if lookup( 'bd':U, v-attr-value ) = 0 or
             lookup( 'ad':U, v-attr-value ) = 0  then run utl/uaddsum.p (ub.trn-doc.doc-code, no, ?, ?) no-error  .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        end.
        when  "sl"  or when  "sl-gold" THEN DO:
          if lookup( 'gen':U, v-attr-value ) = 0 or
             lookup( 'wst':U, v-attr-value ) = 0  then run utl/uaddsum.p (ub.trn-doc.doc-code, no, ?, ?) no-error .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        End.
      End.
    end.
    else
      case rep-tipe:
        when "invent" then do:
          if lookup( 'bd':U, v-attr-value ) = 0 then do:
            message "Не рассчитаны данные до начала инвентаризации!" view-as alert-box.
            undo, return error .
          end.
          if lookup( 'ad':U, v-attr-value ) = 0  then do:
            if p-no-vat = "yes" then do:
              message "Не рассчитаны данные после инвентаризации!" view-as alert-box.
              undo, return error .
            end.
            else assign is-after = no .
          end.
        End.
        when  "sl"  THEN DO:
          if lookup( 'wst':U, v-attr-value ) = 0  then do:
            message "Не рассчитаны нормы естественной убыли! Напечатать документ без их учета?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE ask.
            if ask then assign is-wastage = no .
            else undo, return error .
          end.
        End.
      End.
  end.
end procedure.
procedure ubl :
 do
 on error undo, return error return-value
 :
        if is-wastage then do:
          find first buf_doc-line-sum no-lock
            where buf_doc-line-sum.doc-code = buf_doc-line.doc-code
              and buf_doc-line-sum.gds-code = buf_goods.gds-code
              and buf_doc-line-sum.sum-type = 'wst':U
          no-error .
          if available  buf_doc-line-sum then do:
                          if PrintRubl then assign temp-str.ubl = buf_doc-line-sum.cost-sum-rubl .
                                       else assign temp-str.ubl = buf_doc-line-sum.cost-sum-base .
            if sum < temp-str.ubl then assign temp-str.ubl = sum .
          end.
        end.
 end.
end procedure.
