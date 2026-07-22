block-level on error undo, throw.
define input parameter p-host-code          as character        no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-shift-date         as date             no-undo.
define input parameter p-shift-num          as integer          no-undo.
define input parameter p-xml-file-name      as character        no-undo.
define input parameter p-log-file-name      as character        no-undo.
define input parameter p-bge-editor-handle  as handle           no-undo.
define input parameter p-bge-fillin-handle  as handle           no-undo.
define variable vss-revision    as character no-undo init "$Revision: 5260d850f792, 2610, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2020/10/19 06:22:02 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shtoper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/shtoper.p $":U .
define variable vss-description as character no-undo init "Экспорт XML смены".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DEF STREAM stmXMLOut.
DEF STREAM stmXMLLog.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure strtdate :
  define input  parameter p-str         as character no-undo .
  define output parameter p-value       as date      no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
do
on error undo, return error return-value
:
  define variable v-value       as date      no-undo .
  define variable v-i           as integer   no-undo .
  define variable v-num         as integer   no-undo .
  define variable v-delim       as character no-undo .
  define variable v-delim-list  as character no-undo .
  define variable v-day         as integer   no-undo .
  define variable v-month       as integer   no-undo .
  define variable v-year        as integer   no-undo .
  define variable v-day-str     as character no-undo .
  define variable v-month-str   as character no-undo .
  define variable v-year-str    as character no-undo .
  assign
    p-value       = ?
    p-data-valid  = false
  .
  if p-str = ?
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Не задана строка для преобразования. " )
    .
    return .
  end.
  if p-str = ""
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Задана пустая строка для преобразования. " )
    .
    return .
  end.
  if length(p-str)  > 10
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверная длина строки. " )
    .
    return .
  end.
  assign
    v-delim-list = '/,-,.':U
  .
  _delim:
  do v-i = 1 to num-entries( v-delim-list )
  :
    assign
      v-delim = entry( v-i , v-delim-list )
      v-num   = num-entries( p-str , v-delim )
    .
    if v-num <> 3
    then do:
      assign
        v-delim = ''
      .
    end.
    else do:
      leave _delim.
    end.
  end.
  if v-delim = ''
  then do:
    assign
      p-message = substitute( "Ошибка при преобразовании к дате. Неправильный разделитель, либо ошибочное количество разделителей. " )
    .
    return .
  end.
  assign
    v-day-str   = entry( 1, p-str , v-delim)
    v-month-str = entry( 2, p-str , v-delim)
    v-year-str  = entry( 3, p-str , v-delim)
  .
  if  length(v-day-str) > 2   or
      length(v-day-str) < 1   or
      length(v-month-str) > 2 or
      length(v-month-str) < 1 or
      (
        length(v-year-str) <> 2 and
        length(v-year-str) <> 4
      )
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неправильное количество символов числа, месяца, либо года. " )
    .
    return .
  end.
  if length( v-year-str ) = 2
  then do:
    assign
      v-year-str = substring( string( year(today) ), 1 , 2 ) + v-year-str
    .
  end.
  assign
    v-day   = integer( v-day-str )
    v-month = integer( v-month-str)
    v-year  = integer( v-year-str)
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный формат символов числа, месяца, либо года. " )
    .
    return .
  end.
  if v-day < 1  or
     v-day > 31 or
     v-month < 1 or
     v-month > 12 or
     v-year < 0   or
     v-year > 5000
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный диапозон числа, месяца, года. " )
    .
    return .
  end.
  assign
    v-value = date( v-month, v-day, v-year )
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. &1. " , error-status :get-message(1))
    .
    return .
  end.
  assign
    p-value       = v-value
    p-data-valid  = true
  .
end.
end procedure.
define variable v-bge-xml-bgecliiv      as logical  init no  no-undo.
define variable v-bge-xml-bgeclall      as logical  init no  no-undo.
define variable v-bge-xml-bgedict       as logical  init no  no-undo.
define variable v-bge-xml-bgeflold      as character         no-undo.
define variable v-bge-xml-bgefmt        as character         no-undo.
define variable v-bge-xml-shift-mode    as logical           no-undo.
define variable v-bge-xml-bgeflnm-doc   as character         no-undo.
define variable v-bge-xml-bgeflnm-day   as character         no-undo.
define variable v-bge-xml-log-file-name as character    no-undo.
define variable v-bge-xml-dbf-file-name as character    no-undo.
define variable v-bge-xml-db-num-str    as character    no-undo .
define variable v-bge-xml-static-log-file-name as character    no-undo.
define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character
    index pi is primary unique
        edt-key
.
define temp-table temp_bge-xml_goods no-undo
    field gds-code as integer
    index pi is primary unique gds-code
.
define temp-table temp_bge-xml_clients no-undo
    field obj-type as character
    field obj-code as integer
    field shift-date    as date
    field shift-num     as integer
    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bge-xml_dis-card no-undo
    field d-card as character
    index pi is primary unique
        d-card
.
define temp-table temp_doc-code no-undo
    field doc-code as character
    index pi is primary unique
        doc-code
.
define temp-table temp_del-doc-code no-undo
    field doc-code as character
    index pi is primary unique
        doc-code
.
define temp-table temp_pr-doc-num no-undo
    field doc-num as character
    index pi is primary unique
        doc-num
.
define temp-table temp_fin-doc-code no-undo
    field host-code as integer
    field fin-doc-code as integer
    index pi is primary unique
        host-code
        fin-doc-code
.
define temp-table temp_del-fin-doc-code no-undo
    field host-code as integer
    field fin-doc-code as integer
    field corr-user-db-num as integer
    field chip-num as integer
    index pi is primary unique
        host-code
        fin-doc-code
        corr-user-db-num
        chip-num
.
define temp-table temp_fin-ob no-undo
    field host-code as integer
    field fin-doc-code as character
    index pi is primary unique
        host-code
        fin-doc-code
.
define temp-table temp_del-fin-ob no-undo
    field host-code as integer
    field fin-doc-code as character
    field corr-user-db-num as integer
    field chip-num as integer
    index pi is primary unique
        host-code
        fin-doc-code
        corr-user-db-num
        chip-num
.
define temp-table temp_ord-doc-code no-undo
  field doc-code as character
index pi is primary unique
  doc-code
.
define temp-table tt-bge-xml-bgecliiv no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
index pi is primary unique
  obj-type
  obj-code
.
FUNCTION w-XMLPutParamInTag RETURNS CHAR (INPUT sParName AS CHAR, INPUT sToPlace AS CHAR,
                                          INPUT iFlagEmpty AS INTEGER).
    DEF VAR sOut AS CHAR FORMAT "X(255)" NO-UNDO.
    IF sToPlace = "" OR sToPlace = ? OR sToPlace = "0" THEN
        DO:
            IF iFlagEmpty = 0                           THEN RETURN "".
            ELSE IF iFlagEmpty = 1                      THEN RETURN sParName + "=&#034;&#034;".
            ELSE IF iFlagEmpty = 2 AND sToPlace = "0"   THEN RETURN sParName + "=&#034;0&#034;".
            ELSE IF iFlagEmpty = 3 AND sToPlace = ""    THEN RETURN sParName + "=&#034;&#034;".
            ELSE RETURN "".
        END.
    ELSE DO:
        run xmlchar-encode in this-procedure (
              input sToPlace
            , output sToPlace
        ).
        ASSIGN
            sToPlace = sParName + '="' + sToPlace + '"'
        .
        RETURN sToPlace.
    END.
END FUNCTION.
function bge-xml-date returns character
( input p-date as date )
:
  define variable v-date-str as character no-undo .
  run bge-xml-date-to-str in this-procedure ( input   p-date
                                            , output  v-date-str
                                            ) .
  return v-date-str.
end function.
function bge-xml-str-date returns character
( input p-date-str as character )
:
  define variable v-date-str as character no-undo .
  run bge-xml-date-str-to-str in this-procedure ( input   p-date-str
                                                , output  v-date-str
                                                ) .
  return v-date-str.
end function.
function bge-xml-normalize-dec returns decimal
( input p-val as decimal )
:
  return (if p-val = ? then 0 else p-val) .
end function.
PROCEDURE wp-XMLTagOpen:
DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:
    end.
    else do:
        assign
            v-out-string = substitute( "&1&2<&3&4>"
                                    , chr(10)
                                    , fill( " ":U, 4 * iTagLevel)
                                    , sTagName
                                    , ( if sParValue = "":U or sParValue = ? then "":U else " " + sParValue )
                            )
        .
        put stream stmXMLOut unformatted
            v-out-string
        .
    end.
end.
END PROCEDURE.
PROCEDURE wp-XMLTagPut:
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
  DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
  DEF INPUT PARAM iFlagEmpty AS INTEGER NO-UNDO.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        if v-bge-xml-dbf-file-name <> "":U
        then do:
            output stream stmXMLOut to value( v-bge-xml-dbf-file-name ) append.
            export stream stmXMLOut
                sTagName
                sParValue
            .
            output stream stmXMLOut close.
        end.
    end.
    else do:
        IF  iFlagEmpty = 1
        OR (iFlagEmpty = 0 AND (sParValue <> "" AND sParValue <> ?) )
        OR (iFlagEmpty = 2 AND (sParValue <> "" AND sParValue <> ? AND sParValue <> "0"))
        OR (iFlagEmpty = 3 AND (sParValue <> "" AND sParValue <> ? AND CAPS(sParValue) <> "NO"))
        THEN DO:
            run xmlchar-encode in this-procedure (
                input sParValue
                , output sParValue
            ).
            assign
                v-out-string = substitute( "&1&2<&3>&4</&3>"
                                            , chr(10)
                                            , FILL(" ", 4 * iTagLevel)
                                            , sTagName
                                            , sParValue
                            )
            .
            PUT STREAM stmXMLOut UNFORMATTED
                v-out-string
            .
        END.
    end.
end.
END PROCEDURE.
PROCEDURE wp-XMLTagClose:
DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:
    end.
    else do:
        assign
            v-out-string = substitute( "&1&2</&3>"
                                , ( if iTagLevel=0 then "":U else chr(10) )
                                , fill( " ", 4 * iTagLevel )
                                , sTagName
                        )
        .
        PUT STREAM stmXMLOut UNFORMATTED
            v-out-string
        .
    end.
end.
END PROCEDURE.
PROCEDURE wp-XMLWriteLog:
  DEF INPUT PARAMETER sFileName AS CHAR     NO-UNDO.
  DEF INPUT PARAMETER iLogLevel AS INTEGER  NO-UNDO.
  DEF INPUT PARAMETER sToWrite  AS CHAR     NO-UNDO.
define variable v-str              as character no-undo .
define variable v-error-append     as logical   no-undo .
define variable v-error-append-msg as character no-undo .
assign
  v-str = chr(10)
          + (if (iLogLevel = 0 or sToWrite = "&DLine" or sToWrite = "&Line") then "" else cur-time-string-sec() + " ")
          + (if sToWrite = "&Line" then fill("-", 80) else if sToWrite = "&DLine" then fill("=", 80) else sToWrite)
  v-str = replace(v-str, (chr(10) + chr(13)), chr(10) )
  v-str = replace(v-str, (chr(13) + chr(10)), chr(10) )
  v-str = replace(v-str, chr(10), (chr(13) + chr(10)) )
.
run bge/bge-log.p (input v-str) no-error .
if error-status:error then do:
  assign
    v-error-append     = yes
    v-error-append-msg = return-value
  .
end.
run gbl/fileapnd.p
  ( input sFileName
  , input v-str
  , input 10
  ) no-error .
if error-status:error then do:
  assign
    v-error-append     = yes
    v-error-append-msg = substitute( "&1&2&3"
                                    , v-error-append-msg
                                    , chr(10)
                                    , return-value
                                    )
  .
end.
if v-error-append
then do:
  return error substitute( "&1" , v-error-append-msg ) .
end.
END PROCEDURE.
PROCEDURE wp-XMLWriteEDT:
  DEF INPUT PARAMETER hEDT AS HANDLE NO-UNDO.
  DEF INPUT PARAMETER iLogLevel AS INTEGER  NO-UNDO.
  DEF INPUT PARAMETER sToWrite  AS CHAR     NO-UNDO.
    if valid-handle ( hEDT )
    then do:
        hEDT :move-to-eof().
        hEDT :insert-string(IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                        OR sToWrite = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        hEDT :insert-string(IF sToWrite = "&Line" THEN FILL("-", 80)
                ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
                ELSE FILL(" ", iLogLevel) + sToWrite).
        hEDT :insert-string(chr(10)).
    end.
    process events.
    output to 'bgescn.txt' append.
        put unformatted
            chr(10) string( (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                        OR sToWrite = "&Line") THEN "" ELSE
                                        STRING(TODAY) + " " + STRING(TIME, "hh:mm:ss") + " ") )
            string( (IF sToWrite = "&Line" THEN FILL("-", 80)
                ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
                ELSE FILL(" ", iLogLevel) + sToWrite) )
        .
    output close.
END PROCEDURE.
PROCEDURE wp-XMLShowCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE   NO-UNDO.
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :VISIBLE = TRUE.
    end.
END PROCEDURE.
PROCEDURE wp-XMLHideCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE   NO-UNDO.
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :VISIBLE = FALSE.
    end.
END PROCEDURE.
PROCEDURE wp-XMLWriteCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE  NO-UNDO.
  DEF INPUT PARAMETER sCounter AS CHAR    NO-UNDO.
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :SCREEN-VALUE = sCounter.
    end.
END PROCEDURE.
procedure bge-xml-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name  as character        no-undo.
define input parameter p-doc-name       as character        no-undo.
define input parameter p-version        as character        no-undo.
define input parameter p-db-num         as integer          no-undo.
define input parameter p-date-from      as date             no-undo.
define input parameter p-shift-num-from as integer          no-undo.
define input parameter p-date-to        as date             no-undo.
define input parameter p-shift-num-to   as integer          no-undo.
define input parameter p-obj-list       as character        no-undo.
define input parameter p-doc-type-list  as character        no-undo.
define input parameter p-pay-code       as logical          no-undo.
define input parameter p-cst            as logical          no-undo.
define input parameter p-parts          as logical          no-undo.
define input parameter p-chk-pay-code   as logical          no-undo.
define input parameter p-pay-desk       as logical          no-undo.
define input parameter p-pay-desk-cards as logical          no-undo.
define input parameter p-deleted        as logical          no-undo.
define input parameter p-opened-docs    as logical          no-undo.
define variable v-out-string    as character    no-undo.
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251".
assign
    v-out-string = substitute( "&1&2&3"
                        , "<?xml version='1.0' encoding='windows-1251'?>":U
                        , chr(10)
                        , "<IBS_Trade_House>":U )
.
put stream stmXMLOut unformatted
    v-out-string
.
run wp-XMLTagOpen(1, "header","").
if v-bge-xml-bgeflold = "oracle":u
then do:
  run wp-XMLTagOpen in this-procedure  ( 2, "delivery", "").
  run wp-XMLTagput in this-procedure ( 3, "message","", 1).
  run wp-XMLTagput in this-procedure ( 3, "from","IBS Trade House", 1).
  run wp-XMLTagput in this-procedure ( 3, "to","Oracle Retail", 1).
  run wp-XMLTagClose in this-procedure ( 2, "delivery"    ).
end.
run wp-XMLTagOpen( 2, "manifest", "").
run wp-XMLTagOpen( 3, "document", "").
run wp-XMLTagput( 4, "name", p-doc-name, 0).
run wp-XMLTagput( 4, "description", "", 0).
run wp-XMLTagput( 4, "version", p-version, 0).
run wp-XMLTagclose( 3, "document" ).
run wp-XMLTagclose( 2, "manifest" ).
run wp-XMLTagclose( 1, "header" ).
run wp-XMLTagOpen(1, "options","").
run wp-XMLTagput( 2, "exportDate",      string( today,              "99/99/9999" ), 0).
run wp-XMLTagput( 2, "exportDateXml",   bge-xml-date( today )                     , 0).
run wp-XMLTagput( 2, "exportTime",      string( time,               "HH:MM:SS"   ), 0).
run wp-XMLTagput( 2, "baseNum",         string( p-db-num                         ), 0).
run wp-XMLTagput( 2, "dateFrom",        string( p-date-from,        "99/99/9999" ), 0).
run wp-XMLTagput( 2, "dateFromXml",     bge-xml-date( p-date-from )               , 0).
run wp-XMLTagput( 2, "shiftNumFrom",    string( p-shift-num-from                 ), 2).
run wp-XMLTagput( 2, "dateTo",          string( p-date-to,          "99/99/9999" ), 0).
run wp-XMLTagput( 2, "dateToXml",       bge-xml-date( p-date-to )                 , 0).
run wp-XMLTagput( 2, "shiftNumTo",      string( p-shift-num-to                   ), 2).
run wp-XMLTagput( 2, "objList",                 p-obj-list                        , 0).
run wp-XMLTagput( 2, "docTypeList",             p-doc-type-list                   , 0).
run wp-XMLTagput( 2, "payCode",         string( p-pay-code                       ), 0).
run wp-XMLTagput( 2, "cst",             string( p-cst                            ), 0).
run wp-XMLTagput( 2, "parts",           string( p-parts                          ), 0).
run wp-XMLTagput( 2, "chkPayCode",      string( p-chk-pay-code                   ), 0).
run wp-XMLTagput( 2, "chkPayDesk",      string( p-pay-desk                       ), 0).
run wp-XMLTagput( 2, "chkPayDeskCards", string( p-pay-desk-cards                 ), 0).
run wp-XMLTagput( 2, "deletedDocs",     string( p-deleted                        ), 0).
run wp-XMLTagput( 2, "openedDocs",      string( p-opened-docs                    ), 0).
run wp-XMLTagClose(1, "options").
run wp-XMLTagOpen( 1, "body", "" ).
output stream stmXMLOut close.
end.
end procedure.
procedure xml-bge-write-footer:
do
on error undo, return error return-value
:
define input parameter p-xml-file-name as character    no-undo.
define variable v-error-num     as integer           no-undo.
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run wp-XMLTagClose( 1, "body" ).
run wp-XMLTagClose( 0, "IBS_Trade_House" ).
output stream stmXMLOut close.
if v-bge-xml-bgeflold = "oracle":u
then do:
  define variable v-tmp-file-name         as character no-undo .
  define variable v-zip-file-name         as character no-undo .
  define variable v-exch-file-name        as character no-undo .
  define variable v-heap-file-name        as character no-undo .
  define variable v-i                     as integer   no-undo .
  define variable v-file-name             as character no-undo .
  define variable v-arc                   as character no-undo .
  define variable v-str                   as character no-undo .
  define variable v-exch-tmp-file-name    as character no-undo .
  define variable v-bge-xml-tmp-exch-dir  as character no-undo .
  define variable v-bge-xml-exch-dir      as character no-undo .
  define variable v-bge-xml-heap-dir      as character no-undo .
  define variable v-bge-xml-compress-heap as logical   no-undo .
  define variable v-home-dir              as character no-undo .
  define variable v-os-command            as character no-undo .
  get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
  if v-home-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта.":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  assign
    v-home-dir = v-home-dir
  .
  run gbl/dir-cre.p ( input v-home-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта.":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  get-key-value section "BGE" key "dir-exch" value v-bge-xml-exch-dir .
  if v-bge-xml-exch-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта (exch).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  run gbl/dir-cre.p ( input v-bge-xml-exch-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта (exch).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  get-key-value section "BGE" key "dir-heap" value v-bge-xml-heap-dir.
  if v-bge-xml-heap-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта (heap).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  run gbl/dir-cre.p ( input v-bge-xml-heap-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта (heap).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  get-key-value section "BGE" key "heap-compress" value v-str.
  assign
    v-i = int(v-str)
  no-error .
  if v-i = ? or v-i = 0
  then do:
    assign
      v-bge-xml-compress-heap = no
    .
  end.
  else do:
    assign
      v-bge-xml-compress-heap = yes
    .
  end.
  assign
    v-arc = search( "exe/7za.exe":u )
  .
  if v-arc = ? or v-arc = ""
  then do:
    undo, return error("Не найдена программа 7za.exe, невозможно упаковать файлы в архив.":u).
  end.
  assign
    v-file-name            = entry(num-entries( p-xml-file-name , chr(47) ) , p-xml-file-name , chr(47) )
    v-tmp-file-name        = session :temp-directory + v-file-name + "DAT":u
    v-zip-file-name        = session :temp-directory + v-file-name + "DAT.zip":u
    v-bge-xml-tmp-exch-dir = v-bge-xml-exch-dir + ".000"
    v-exch-tmp-file-name   = v-bge-xml-tmp-exch-dir + chr(47) + v-file-name + "tmp":u
    v-exch-file-name       = v-bge-xml-exch-dir + chr(47) + v-file-name + "DAT.zip":u
    v-heap-file-name       = v-bge-xml-heap-dir + chr(47) + v-file-name + "DAT":u
  .
  run gbl/del-file.p (input v-tmp-file-name) .
  run gbl/del-file.p (input v-zip-file-name) .
  run bge/os_copy.p ("M", p-xml-file-name + "xm1":u, v-tmp-file-name, output v-error-num ).
  if v-error-num > 0
  then do:
      undo, return error substitute( "Ошибка переноса из &1 в &2. Код ошибки: &3"
                                   , p-xml-file-name + "xm1":u
                                   , v-tmp-file-name
                                   , v-error-num
                                   ).
  end.
  assign
    v-os-command     = substitute( "&1 a -tzip &2 &3"
                                 , v-arc
                                 , v-zip-file-name
                                 , v-tmp-file-name
                                 )
  .
  os-command silent value ( v-os-command ) .
  run gbl/del-file.p (input v-heap-file-name) .
  if v-bge-xml-compress-heap = no
  then do:
    run bge/os_copy.p ("C", v-tmp-file-name, v-heap-file-name, output v-error-num ).
    if v-error-num > 0
    then do:
        undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                     , v-tmp-file-name
                                     , v-heap-file-name
                                     , v-error-num
                                     ) .
    end.
  end.
  else do:
    run bge/os_copy.p ("C", v-zip-file-name, v-heap-file-name + ".zip", output v-error-num ).
    if v-error-num > 0
    then do:
        undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                     , v-zip-file-name
                                     , v-heap-file-name
                                     , v-error-num
                                     ) .
    end.
  end.
  run gbl/del-file.p (input v-tmp-file-name) .
  run gbl/dir-cre.p ( input v-bge-xml-tmp-exch-dir ) no-error.
  if error-status :error then do:
    undo, return error substitute( "&1&2&3"
                                  , substitute( "Не удалось создать каталог &1.", v-bge-xml-tmp-exch-dir )
                                  , chr(10)
                                  , "Обратитесь к администратору."
                                  ).
  end.
  run gbl/del-file.p (input v-exch-file-name) .
  run gbl/del-file.p (input v-exch-tmp-file-name ) .
  run bge/os_copy.p ("M", v-zip-file-name, v-exch-tmp-file-name, output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , v-zip-file-name
                                  , v-exch-tmp-file-name
                                  , v-error-num
                                  ) .
  end.
  run bge/os_copy.p ("M", v-exch-tmp-file-name, v-exch-file-name , output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , v-exch-tmp-file-name
                                  , v-exch-file-name
                                  , v-error-num
                                  ) .
  end.
  run gbl/del-file.p (input v-bge-xml-tmp-exch-dir ) .
end.
else do:
  run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , p-xml-file-name + "xm1"
                                  , p-xml-file-name + "xml"
                                  , v-error-num
                                  ) .
  end.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-bge-filename0:
define input parameter p-prefix   as character no-undo .
define input parameter p-name     as character no-undo .
define input parameter p-shared-process as logical no-undo .
define input parameter p-home-dir as character no-undo . // из ini-параметра [BGE] Dirfrg-acc
define output parameter p-xml-file-name  as character no-undo .
// define output parameter p-fullfnamenoext as character no-undo .
define output parameter p-locked         as logical      no-undo.
define variable v-fullfnamenoext as character no-undo .
define variable v-fileext        as character no-undo .
define variable v-fullfname      as character no-undo .
define variable v-error-num      as integer   no-undo .
do
on error undo, return error
:
  case v-bge-xml-bgeflold :
    when "old" then do:
      v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, chr(47), p-name, v-bge-xml-db-num-str) .
      v-fileext       = ".xml":U .
      v-fullfname     = v-fullfnamenoext + v-fileext .
      p-xml-file-name = v-fullfname .
      run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
      if v-error-num > 0 then do:
        return error.
      end.
    end.
    when "var" then do:
      case p-prefix :
        when "doc" then do:
          v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, chr(47), p-name, v-bge-xml-bgeflnm-doc) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
        when "day" then do:
          v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, chr(47), p-name, v-bge-xml-bgeflnm-day) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
        otherwise do:
          v-fullfnamenoext = substitute ("&1&2&3", p-home-dir, chr(47), p-name) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
      end case.
      run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
      if v-error-num > 0 then do:
        return error.
      end.
    end.
    when "new" then do:
                run bge/genfname.p (
                    input p-home-dir
                    , input p-prefix
                    , input ""
                    , input "xml"
                    , input ""
                    , output p-xml-file-name
                ).
    end.
    when "no-parameter" then do:
      if p-shared-process then do:
                    run bge/genfname.p (
                        input p-home-dir
                        , input "d"
                        , input ""
                        , input "xml"
                        , input ""
                        , output p-xml-file-name
                    ).
      end.
      else do:
        v-fullfnamenoext = substitute ("&1&2&3", p-home-dir, chr(47), p-name) .
        v-fileext       = ".xml":U .
        v-fullfname     = v-fullfnamenoext + v-fileext .
        p-xml-file-name = v-fullfname .
        run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
        if v-error-num > 0 then do:
          return error.
        end.
      end.
    end.
  end case.
  assign
    p-xml-file-name = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
    p-locked = ( search ( p-xml-file-name + "lk" ) <> ? )
  .
end .
end procedure .
procedure xml-bge-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-shared-process     as logical      no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-home-dir          as character no-undo .
define variable v-error-num         as integer   no-undo .
define variable v-bge-xml-heap-dir  as character no-undo .
    get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle"
    then do:
      assign
          v-home-dir = v-home-dir + chr(47) + "exp-acc"
      .
    end.
    run gbl/dir-cre.p ( input v-home-dir ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        assign
            p-xml-file-name = v-home-dir
            p-locked        = no
        .
    end.
    else do:
        run xml-bge-filename0 in this-procedure (p-prefix, p-name, p-shared-process, v-home-dir,
          output p-xml-file-name, output p-locked) .
    end.
    if v-bge-xml-bgeflold = "oracle"
    then do:
      get-key-value section "BGE" key "dir-heap" value v-bge-xml-heap-dir.
      if v-bge-xml-heap-dir = ?
      then do:
        undo, return error substitute( "&1&2&3"
                                      , "Не найден параметр ini-файла, определяющий каталог экспорта (heap).":u
                                      , chr(10)
                                      , "Обратитесь к администратору.":u
                                      ).
      end.
      run gbl/dir-cre.p ( input v-bge-xml-heap-dir ) no-error.
      if error-status :error
      then do:
        undo, return error substitute( "&1&2&3"
                                      , "Неверно задан каталог экспорта (heap).":u
                                      , chr(10)
                                      , "Обратитесь к администратору.":u
                                      ).
      end.
      if r-index( v-bge-xml-heap-dir, chr(47) ) > r-index( v-bge-xml-heap-dir, chr(92) ) then do:
        assign
          p-log-file-name = substring( v-bge-xml-heap-dir, 1, r-index( v-bge-xml-heap-dir, chr(47) ) ) + chr(47) + "actions.log"
        .
      end.
      else do:
        assign
          p-log-file-name = substring( v-bge-xml-heap-dir, 1, r-index( v-bge-xml-heap-dir, chr(92) ) ) + chr(47) + "actions.log"
        .
      end.
    end.
    else do:
      assign
          p-log-file-name = v-home-dir + chr(47) + "actions.log"
      .
    end.
    assign
       v-bge-xml-static-log-file-name = p-log-file-name
    .
end.
end procedure.
procedure bge-xml-read-config :
do
on error undo, return error return-value
:
define input  parameter p-last-date as date      no-undo .
define input  parameter p-db-num    as integer   no-undo .
    define variable v-bgeclall      as character     no-undo.
    define variable v-bgedict       as character     no-undo.
    define variable v-bgeshift      as character     no-undo.
    define variable v-par-type      as character     no-undo.
    define variable v-bgeflnm       as character     no-undo.
    define variable v-bgecliiv      as character     no-undo .
    define variable v-date-chars    as character case-sensitive  init "DD"      no-undo.
    define variable v-month-chars   as character case-sensitive  init "MM"      no-undo.
    define variable v-year-chars    as character case-sensitive  init "YY"      no-undo.
    define variable v-db-num-chars  as character case-sensitive  init "BBBBB"   no-undo.
    define variable v-db-num-str    as character     no-undo .
    define variable v-param-type      as character  no-undo .
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle      no-undo .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-bgecliiv
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgecliiv = no
      .
    end.
    else do:
      run bge-xml-fill-tt-bgecliiv in this-procedure ( input v-bgecliiv ).
    end.
    delete object v-tth.
    assign
        v-bge-xml-bgeclall = no
        v-bge-xml-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgeclall = no
      .
    end.
    else do:
      assign
        v-bge-xml-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgedict':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgedict = no
      .
    end.
    else do:
      assign
        v-bge-xml-bgedict = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgefmt':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bge-xml-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeshift':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
          v-bge-xml-shift-mode = no
      .
    end.
    else do:
      assign
          v-bge-xml-shift-mode = ( v-value-character = "distinct":U )
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeflold':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgeflold = "no-parameter":U
      .
    end.
    else do:
      assign
        v-bge-xml-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
    assign
      v-db-num-str          = ( if p-db-num <> ? then string(p-db-num ,"99999") else "":u )
      v-bge-xml-db-num-str  = v-db-num-str
    .
    if p-last-date <> ?
    then do:
        run adm/shattri.p ( input "get":U
                          , input  '':u
                          , input  0
                          , input  'bge-export':U
                          , input  'bgeflnm':U
                          , output v-value-character
                          , output v-value-date
                          , output v-value-decimal
                          , output v-value-integer
                          , output v-value-logical
                          , output v-param-type
                          , input-output table-handle v-tth
                          ) no-error .
        if error-status :error
        then do:
          assign
            v-bgeflnm = '':U
          .
        end.
        else do:
          assign
            v-bgeflnm = v-value-character
          .
        end.
        delete object v-tth.
        if v-bge-xml-bgeflold = "var"
        then do:
            if v-bgeflnm = ?
            or num-entries( v-bgeflnm ) < 2
            then do:
                assign
                    v-bge-xml-bgeflold = "new"
                .
            end.
            else do:
                assign
                    v-bge-xml-bgeflnm-doc = entry( 1, v-bgeflnm )
                    v-bge-xml-bgeflnm-day = entry( 2, v-bgeflnm )
                .
                assign
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-date-chars , string( day( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-month-chars, string( month( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-year-chars , substring( string( year( p-last-date ), "9999" ), 3, 2 ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-db-num-chars, v-db-num-str )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-date-chars , string( day( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-month-chars, string( month( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-year-chars , substring( string( year( p-last-date ), "9999" ), 3, 2 ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-db-num-chars, v-db-num-str )
                .
            end.
        end.
    end.
end.
end procedure.
procedure bge-xml-get-ref-filename :
define input parameter p-in-file-name       as character        no-undo.
define output parameter p-home-dir          as character        no-undo.
define output parameter p-out-file-name     as character        no-undo.
define output parameter p-locked            as logical          no-undo.
    define variable v-counter       as integer      no-undo.
    define variable v-error-level   as integer      no-undo.
do
on error undo, return error
:
    run bge/bge-ini.p (
          input "bge"
        , output p-home-dir
    ).
    if return-value <> "OK"
    then do:
        undo, return error.
    end.
    assign
        p-home-dir = p-home-dir + "\dict":U
    .
    run bge/dir_cd.p (
        input p-home-dir
        , input "CA"
    ).
    if return-value = "ERROR"
    then do:
        undo, return error.
    end.
    assign
        p-out-file-name = substitute( "&1\&2.", p-home-dir, p-in-file-name )
    .
    assign
        p-locked = ( search( p-out-file-name + "xml" ) <> ? ).
    .
    wait-lock:
    do v-counter = 1 TO 3
    :
        p-locked = ( search( p-out-file-name + "lk" ) <> ? ).
        if p-locked = no
        then do:
            leave wait-lock.
        end.
        else do:
            readkey pause 1.
        end.
    END.
    if p-locked = yes
    then do:
        undo, return error.
    end.
    run bge/os_copy.p (
          input "D":U
        , input p-out-file-name + "xml":U
        , input "":U
        , output v-error-level
    ).
    if v-error-level > 0
    then do:
        undo, return error.
    end.
end.
end procedure.
procedure bge-xml-write-ref-header :
define input parameter p-bge-name as character        no-undo.
define input parameter p-file-name as character        no-undo.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-file-name + "xm1") convert target "1251".
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>":U
    .
    assign
        v-out-string = substitute( "&1&2"
                            , chr(10)
                            , "<IBS_Trade_House>":U )
    .
    put stream stmXMLOut unformatted
        v-out-string
    .
    run wp-XMLTagOpen( 1, "header", "" ).
    if v-bge-xml-bgeflold = "oracle":u
    then do:
      run wp-XMLTagOpen in this-procedure  ( 2, "delivery", "").
      run wp-XMLTagput in this-procedure ( 3, "message","", 1).
      run wp-XMLTagput in this-procedure ( 3, "from","IBS Trade House", 1).
      run wp-XMLTagput in this-procedure ( 3, "to","Oracle Retail", 1).
      run wp-XMLTagClose in this-procedure ( 2, "delivery"    ).
    end.
    else do:
      run wp-XMLTagOpen( 2, "delivery", "" ).
      run wp-XMLTagOpen( 3, "to", "" ).
      run wp-XMLTagClose( 3, "to" ).
      run wp-XMLTagOpen( 3, "from", "" ).
      run wp-XMLTagClose( 3, "from" ).
      run wp-XMLTagClose( 2, "delivery" ).
    end.
    run wp-XMLTagOpen( 2, "manifest", "" ).
    run wp-XMLTagOpen( 3, "document", "" ).
    run wp-XMLTagPut( 4, "name", p-bge-name, 0 ).
    run wp-XMLTagPut( 4, "description", "", 0 ).
    run wp-XMLTagClose( 3, "document" ).
    run wp-XMLTagClose( 2, "manifest" ).
    run wp-XMLTagClose( 1, "header" ).
    run wp-XMLTagOpen( 1, "body", "" ).
end.
end procedure.
procedure bge-xml-write-ref-footer :
define input parameter p-file-name as character        no-undo.
    define variable v-error-level   as integer      no-undo.
do
on error undo, return error
:
    run wp-XMLTagClose in this-procedure ( input 1, input "body":U ).
    run wp-XMLTagClose in this-procedure ( input 0, input "IBS_Trade_House":U ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M":U
        , input p-file-name + "xm1":U
        , input p-file-name + "xml":U
        , output v-error-level
    ).
    if v-error-level > 0
    then do:
        undo, return error.
    end.
end.
end procedure.
procedure bge-xml-out-dir :
define output parameter p-out-dir       as character    no-undo.
define output parameter p-log-file-name as character    no-undo.
do
on error undo, return error
:
    p-out-dir = ibs.th.gbl.gbl-inipar:dirfrgAcc .
    if p-out-dir = ?
    then do:
        message
          skip substitute("Не найден параметр ini-файла, определяющий каталог экспорта (&1)."
                        , ibs.th.gbl.gbl-inipar:dirfrgAccKeyName)
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle" then assign
      p-out-dir = substitute( "&1&2exp-acc":U, p-out-dir, chr(47) )
    .
    run gbl/dir-cre.p ( input p-out-dir ) no-error.
    if error-status :error  then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dir
                                , return-value
                                , trim( error-status :get-message( 1 ) )
                                )
        ).
        undo, return error.
    end.
    assign
        v-bge-xml-static-log-file-name = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
        p-log-file-name                = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
    .
end.
end procedure.
procedure bge-xml-out-dir2 :
define output parameter p-out-dir       as character    no-undo.
define output parameter p-out-dirR      as character    no-undo.
define output parameter p-log-file-name as character    no-undo.
do
on error undo, return error
:
    p-out-dir = ibs.th.gbl.gbl-inipar:dirfrgAcc .
    if p-out-dir = ?
    then do:
        message
          skip substitute("Не найден параметр ini-файла, определяющий каталог экспорта (&1)."
                        , ibs.th.gbl.gbl-inipar:dirfrgAccKeyName)
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle" then assign
          p-out-dirR = substitute( "&1&2exp-reestr":U, p-out-dir, chr(47) )
          p-out-dir  = substitute( "&1&2exp-acc":U,    p-out-dir, chr(47) )
      .
    else p-out-dirR = p-out-dir .
    run gbl/dir-cre.p ( input p-out-dir ) no-error.
    if error-status :error  then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dir
                                , return-value
                                , error-status :get-message( 1 )
                                )
        ).
        undo, return error.
    end.
    if p-out-dirR <> p-out-dir then do:
      run gbl/dir-cre.p ( input p-out-dirR ) no-error.
      if error-status :error then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dirR
                                , return-value
                                , error-status :get-message( 1 )
                                )
        ).
        p-out-dirR = p-out-dir .
      end.
    end .
    assign
      v-bge-xml-static-log-file-name = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
      p-log-file-name                = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
    .
end.
end procedure.
procedure bge-xml-out-file :
do
on error undo, return error
:
define input parameter p-out-dir            as character        no-undo.
define input parameter p-prefix             as character        no-undo.
define input parameter p-sheduled           as logical          no-undo.
define output parameter p-xml-file-name     as character        no-undo.
define output parameter p-locked            as logical          no-undo.
define variable v-home-dir      as character     no-undo.
define variable v-error-num     as integer       no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        assign
            p-xml-file-name = p-out-dir
            p-locked        = no
        .
    end.
    else do:
        if v-bge-xml-bgeflold = "firm":U
        then do:
            run bge/genfname.p (
                  input p-out-dir
                , input p-prefix
                , input "":U
                , input "arj":U
                , input "":U
                , output p-xml-file-name
            ).
        end.
        else do:
            run bge/genfname.p (
                  input p-out-dir
                , input p-prefix
                , input "":U
                , input "xml":U
                , input "":U
                , output p-xml-file-name
            ).
        end.
        assign
            p-xml-file-name = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
            p-locked = ( search ( p-xml-file-name + "lk":U ) <> ? )
        .
    end.
end.
end procedure.
procedure bge-xml-init-ext-doc-type :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
        .
    end.
end.
end procedure.
procedure bge-xml-get-decimal-shift-num :
define input parameter p-shift-date     as date             no-undo.
define input parameter p-shift-num      as integer          no-undo.
define output parameter p-shift-decimal as decimal          no-undo.
do
on error undo, return error
:
    assign
        p-shift-decimal = ( p-shift-date - 01/01/1990 ) + truncate( p-shift-num / 1000, 3 )
    .
end.
end procedure.
procedure bge-xml-ora-exp-filename :
  define input  parameter p-table-name  as character no-undo .
  define input  parameter p-doc-code    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-filename    as character no-undo .
  define output parameter p-seq-num     as integer   no-undo .
  define variable v-ora-exp-seq     as integer   no-undo .
  define variable v-ora-exp-seq-str as character no-undo .
  define variable v-home-dir        as character no-undo.
do
on error undo, return error return-value
:
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
    if v-home-dir = ?
    then do:
      undo, return error substitute( "&1&2&3":U
                                    , "Не найден параметр ini-файла, определяющий каталог экспорта.":U
                                    , chr(10)
                                    , "Обратитесь к администратору.":U
                                    ).
    end.
    assign
        v-home-dir = v-home-dir
    .
    run gbl/dir-cre.p ( input v-home-dir ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&1&2&3":U
                                    , "Неверно задан каталог экспорта.":U
                                    , chr(10)
                                    , "Обратитесь к администратору.":U
                                    ).
    end.
    assign
      v-ora-exp-seq = ?
    .
    if  p-table-name <> ? and
        p-doc-code <> ?
    then do:
      run bge/get-oesq.p ( input p-table-name
                         , input p-doc-code
                         , output v-ora-exp-seq
                         ) no-error .
      if error-status :error = yes
      then do:
        undo, return error return-value .
      end.
    end.
    if v-ora-exp-seq = ?
    then do:
      run bge/oesq-get.p ( output v-ora-exp-seq ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
    end.
    if p-table-name <> ? and
       p-doc-code   <> ?
    then do:
      run bge/oesqdoc.p ( input p-table-name
                        , input p-doc-code
                        , input v-ora-exp-seq
                        ) no-error .
      if error-status :error = yes
      then do:
        undo, return error return-value .
      end.
    end.
    assign
      p-seq-num  = v-ora-exp-seq
      p-filename = substitute("&1/&2-000_&3."
                             , v-home-dir
                             , ( if p-obj-code < 1000 then string( p-obj-code, "999") else string(p-obj-code))
                             , string(v-ora-exp-seq , "999999999")
                             )
    .
  end.
end.
end procedure.
procedure bge-xml-date-to-str :
  define input  parameter p-date  as date      no-undo .
  define output parameter p-str   as character no-undo .
do
on error undo, return error return-value
:
  if p-date <> ?
  then do:
    assign
      p-str = substitute( "&1-&2-&3"
                        , string( year(p-date)  , "9999")
                        , string( month(p-date) , "99"  )
                        , string( day(p-date)   , "99"  )
                        )
    .
  end.
  else do:
    assign
      p-str = ?
    .
  end.
end.
end procedure.
procedure bge-xml-date-str-to-str :
  define input  parameter p-date-str  as character no-undo .
  define output parameter p-str       as character no-undo .
  define variable v-date          as date      no-undo .
  define variable v-date-valid    as logical   no-undo .
  define variable v-error-message as character no-undo .
do
on error undo, return error return-value
:
  assign
    p-str = ?
  .
  if p-date-str = ? or p-date-str = ""
  then do:
    return .
  end.
  run strtdate in this-procedure ( input  p-date-str
                                 , output v-date
                                 , output v-date-valid
                                 , output v-error-message
                                 ).
  if v-date-valid <> true
  then do:
    return .
  end.
  assign
    p-str = substitute( "&1-&2-&3"
                      , string( year(v-date)  , "9999")
                      , string( month(v-date) , "99"  )
                      , string( day(v-date)   , "99"  )
                      )
  .
end.
end procedure.
procedure bge-xml-fill-tt-bgecliiv :
  define input  parameter p-str as character no-undo .
  define buffer buf_tt-bge-xml-bgecliiv for tt-bge-xml-bgecliiv.
  define buffer buf_clients             for ub.clients.
  define variable v-i         as integer   no-undo .
  define variable v-count     as integer   no-undo .
  define variable v-cli-count as integer   no-undo .
  define variable v-client    as character no-undo .
  define variable v-obj-type  as character no-undo .
  define variable v-obj-code  as integer   no-undo .
do
on error undo, return error return-value
:
  empty temp-table buf_tt-bge-xml-bgecliiv.
  assign
    v-bge-xml-bgecliiv = no
    v-cli-count        = num-entries(p-str,';')
  .
  if v-cli-count > 0
  then do:
    _cli-cycle:
    do v-i = 1 to v-cli-count
    :
      assign
        v-client = entry(v-i , p-str, ';')
      .
      if num-entries(v-client) <> 2
      then do:
        undo, return error substitute("Неправильный формат записи контрагента в параметре 'bgecliiv'. Позиция записи &1." , v-i).
      end.
      assign
        v-obj-type = entry(1, v-client)
      .
      assign
        v-obj-code = integer(entry(2, v-client))
      no-error .
      if error-status :error
      then do:
        undo, return error substitute("Неправильный формат записи кода контрагента в параметре 'bgecliiv'. Позиция записи &1." , v-i).
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = v-obj-type
          and buf_clients.obj-code = v-obj-code
      no-error.
      if not available buf_clients
      then do:
        next _cli-cycle.
      end.
      find first buf_tt-bge-xml-bgecliiv no-lock
        where buf_tt-bge-xml-bgecliiv.obj-type = buf_clients.obj-type
          and buf_tt-bge-xml-bgecliiv.obj-code = buf_clients.obj-code
      no-error .
      if available buf_tt-bge-xml-bgecliiv
      then do:
        next _cli-cycle.
      end.
      create buf_tt-bge-xml-bgecliiv.
      assign
        buf_tt-bge-xml-bgecliiv.obj-type = buf_clients.obj-type
        buf_tt-bge-xml-bgecliiv.obj-code = buf_clients.obj-code
      .
    end.
  end.
  else do:
    assign
      v-bge-xml-bgecliiv = no
    .
    return .
  end.
  find first buf_tt-bge-xml-bgecliiv no-lock no-error .
  if available buf_tt-bge-xml-bgecliiv
  then do:
    assign
      v-bge-xml-bgecliiv = yes
    .
  end.
end.
end procedure.
procedure bge-xml-resolve-ext-doc-type :
  define input  parameter p-ext-doc-type      as character no-undo .
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define output parameter p-out-ext-doc-type  as character no-undo .
  define buffer buf_tt-bge-xml-bgecliiv for tt-bge-xml-bgecliiv.
do
on error undo, return error return-value
:
  assign
    p-out-ext-doc-type = p-ext-doc-type
  .
  if p-ext-doc-type <> 'ie':U
  then do:
    return .
  end.
  if v-bge-xml-bgecliiv = yes
  then do:
    find first buf_tt-bge-xml-bgecliiv no-lock
      where buf_tt-bge-xml-bgecliiv.obj-type = p-obj-type
        and buf_tt-bge-xml-bgecliiv.obj-code = p-obj-code
    no-error .
    if available buf_tt-bge-xml-bgecliiv
    then do:
      assign
        p-out-ext-doc-type = 'iv':U
      .
    end.
  end.
end.
end procedure.
procedure safe-wp-xmltagput :
  define input  parameter pTagLevel   as integer   no-undo .
  define input  parameter pTagName    as character no-undo .
  define input  parameter pParValue   as character no-undo .
  define input  parameter pFlagEmpty  as integer   no-undo .
do
on error undo, return error return-value
:
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    return .
  end.
  run wp-xmltagput in this-procedure ( input pTagLevel
                                     , input pTagName
                                     , input pParValue
                                     , input pFlagEmpty
                                     ).
end.
end procedure.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE fostatok :
define input parameter p-host-code   as integer no-undo .
define input parameter x-store-code  like ub.clients.obj-code    no-undo.
define input parameter x-store-type  like ub.clients.obj-type    no-undo.
define input parameter x-tog-shift   as   logical             no-undo.
define input parameter x-date-start  as date        no-undo.
define input parameter x-date-end    as date        no-undo.
define input parameter x-shift-start as integer     no-undo.
define input parameter x-shift-end   as integer     no-undo.
define input parameter xTog-obj   as logical no-undo.
define input parameter p-curr-code as integer no-undo .
define input parameter p-cashbookid as integer  no-undo .
define output parameter sum       as decimal   no-undo.
define output parameter Fact-order  as decimal  no-undo.
define variable Fact-order#   as decimal  no-undo.
define variable Fact-orderS   as character  no-undo.
define variable x-date-start-t  as date   no-undo.
define variable x-sum-type as character no-undo .
    if x-tog-shift then do:
      assign
      x-sum-type = 'shift-obj':U.
    end.
    else do:
      x-sum-type = 'obj':U.
    end.
Assign
Fact-order   = 0
sum     = 0
x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
  Fact-order = 0 .
  For each obj-list no-lock
      WHERE  (NOT xTog-obj OR
              (x-store-type = obj-list.obj-type
              AND
              x-store-code = obj-list.obj-code))
  :
   fact-order# = 0.
   IF  x-TOG-Shift = False Then DO:
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
          arh-fin-doc-schet-nal-obj.Fact-date <=  x-date-start
          USE-INDEX fact-date  no-error .
     if Available arh-fin-doc-schet-nal-obj THEN  do:
       Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
     end.
   End.
   Else  DO :
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
           (arh-fin-doc-schet-nal-obj.shift-date  = x-date-start-t and
            arh-fin-doc-schet-nal-obj.shift-num  < x-shift-start or
            arh-fin-doc-schet-nal-obj.shift-date  < x-date-start-t  )
            and arh-fin-doc-schet-nal-obj.shift-num  > 0
            USE-INDEX Shift-num no-error .
      if Available arh-fin-doc-schet-nal-obj THEN  do:
        Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
      end.
    END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  no-lock WHERE
     (NOT xTog-obj
      OR
      (x-store-type = obj-list.obj-type
      AND
      x-store-code = obj-list.obj-code))
   :
   IF  x-TOG-Shift = False Then DO:
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
            arh-fin-doc-schet-nal-obj.Fact-date <= x-date-end
            and arh-fin-doc-schet-nal-obj.shift-num = 0
            USE-INDEX fact-date no-error.
     if Available arh-fin-doc-schet-nal-obj THEN  do:
       Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
     end.
   END.
   Else DO:
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
            (arh-fin-doc-schet-nal-obj.shift-date  = x-date-end and
            arh-fin-doc-schet-nal-obj.shift-num  <= x-shift-end or
            arh-fin-doc-schet-nal-obj.shift-date  < x-date-end       ) and
            arh-fin-doc-schet-nal-obj.shift-num   > 0      use-index shift-num no-error.
      if Available arh-fin-doc-schet-nal-obj THEN  do:
        Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
      end.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable is-wth   as logical   no-undo .
define temp-table temp_payDeskZOrder no-undo
  field pay-desk as integer
  field z-number as integer
  field sum      as decimal
  index pi is primary unique
  pay-desk
  z-number
.
define temp-table temp_sumWthInkasToBank no-undo
  field wth-code as integer
  field wth-name as character
  field fact-sum as decimal
  index pi is primary unique
  wth-code
.
define temp-table temp_sumWthInternal no-undo
  field wth-code as integer
  field wth-name as character
  field fact-sum as decimal
  index pi is primary unique
  wth-code
.
define temp-table temp_stkWthInPlace no-undo
  field w-p-code    as integer
  field wth-code    as integer
  field w-p-name    as character
  field wth-name    as character
  field stock-start as decimal
  field stock-end   as decimal
  index pi is primary unique
  w-p-code
  wth-code
.
define temp-table temp_techPro no-undo
  field artic         as character
  field prod-type     as character
  field prod-code     as integer
  field gds-code      as integer
  field gds-name      as character
  field envd          as logical
  field fact-qnty     as decimal
  field pl-code       as integer
  field qnty          as decimal
  field cli-qnty      as decimal
  field state-density as decimal
  index pi is primary unique
  artic
  prod-type
  prod-code
.
define temp-table temp_chk-doc no-undo
  field gds-code      as integer
  field b-code        as integer
  field fact-qnty     as decimal
  field pl-code       as integer
  field qnty          as decimal
  field cli-qnty      as decimal
  field state-density as decimal
  field chk-date      as date
  FIELD doc-code      as character
  FIELD doc-num2      as character
  FIELD doc-num       as character
  FIELD chk-num       as integer
  FIELD chk-time      as integer
  FIELD cashier       as integer
  field pay-desk      as integer
  field pump          as decimal
  field nozzle-code   as integer
  field sum-qnty      as decimal
  field sum-cli-qnty  as decimal
  field chk-type      as integer
  field netto         as decimal
  index pi is primary unique
  doc-code
.
define temp-table temp_chk-gds no-undo
  field gds-code    as integer
  field b-code      as integer
  field pl-code     as integer
  field qnty        as decimal
  FIELD doc-code    as character
  field pump        as decimal
  field nozzle-code as integer
  field line-num    as INTEGER
  field sbros-type  as character
  field src-sum     as decimal
  field OFDcode     as character
  field OFDvalue    as decimal
  index pi is primary unique
  b-code
  doc-code
  line-num
.
define temp-table temp_stkShiftOpen no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field gds-name  as character
  field envd      as logical
  field qnty      as decimal
  field cli-qnty  as decimal
  index pi is primary unique
  gds-code
.
define temp-table temp_stkPlShiftOpen no-undo
  field gds-code           as integer
  field pl-code            as integer
  field qnty               as decimal
  field cli-qnty           as decimal
  field state-density      as decimal
  field state-add-quantity as decimal
  field system-qnty        as decimal
  field systen-cli-qnty    as decimal
  field temperature        as decimal
  field level-petrol       as decimal
  field level-water        as decimal
  field level-total        as decimal
  index pi is primary unique
  gds-code
  pl-code
.
define temp-table temp_stkTrkShiftOpen no-undo
  field pl-code      as integer
  field pump-code    as integer
  field nozzle-code  as integer
  field gds-code     as integer
  field state-mh-cnt as decimal
  index pi is primary unique
  pl-code
  pump-code
  nozzle-code
  index igds
  gds-code
.
define temp-table temp_stkShiftEnd no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field gds-name  as character
  field envd      as logical
  field qnty      as decimal
  field cli-qnty  as decimal
  index pi is primary unique
  gds-code
.
define temp-table temp_stkPlShiftEnd no-undo
  field gds-code           as integer
  field pl-code            as integer
  field qnty               as decimal
  field cli-qnty           as decimal
  field state-density      as decimal
  field state-add-quantity as decimal
  field system-qnty        as decimal
  field systen-cli-qnty    as decimal
  field temperature        as decimal
  field level-petrol       as decimal
  field level-total        as decimal
  field level-water        as decimal
  index pi is primary unique
  gds-code
  pl-code
.
define temp-table temp_stkTrkShiftEnd no-undo
  field pl-code      as integer
  field pump-code    as integer
  field nozzle-code  as integer
  field gds-code     as integer
  field state-mh-cnt as decimal
  index pi is primary unique
  pl-code
  pump-code
  nozzle-code
  index igds
  gds-code
.
define temp-table temp_stkTNP no-undo
  field artic         as character
  field prod-type     as character
  field prod-code     as integer
  field gds-code      as integer
  field gds-name      as character
  field envd          as logical
  field end-sumSale   as decimal
  field end-qnty      as decimal
  field end-sumVat    as decimal
  field start-sumSale as decimal
  field start-sumVat  as decimal
  index pi is primary unique
  artic
  prod-type
  prod-code
.
define temp-table temp_sumPriceSale no-undo
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field gds-code  as integer
  field gds-name  as character
  field envd      as logical
  field sumSale   as decimal
  field sumVat    as decimal
  index pi is primary unique
  artic
  prod-type
  prod-code
.
do
on error undo, return error
:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-wth'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
  IF not error-status:error then is-wth = (conf-par = "yes":U).
  output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
  run export-shift in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "основных данных смены"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-shift-staff in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "списка операторов"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-pay-desk-z-order in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "сумм z-отчётов"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  if is-wth then
  do:
    run export-sum-wth in this-procedure (
        input p-host-code
      , input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
    ) no-error.
    if error-status :error then do:
      run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "инкассированных и взятых для внутренних нужд средств"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
      ).
    end.
    run export-stk-wth-in-place in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
    ) no-error.
    if error-status :error then do:
      run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "остатков в кассах"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
      ).
    end.
  end.
  run export-techPro in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "технологической прокачки"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-techChk in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "технологические чеки"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-CorrChk in this-procedure (
    input p-obj-type
    , input p-obj-code
    , input p-shift-date
    , input p-shift-num
    ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
      input p-log-file-name
      , input 1
      , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
      , vss-description
      , "чеков коррекции"
      , return-value
      , trim(error-status :get-message(1))
      , trim(error-status :get-message(2))
      )
      ).
  end.
  run export-stkShift in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "остатков топлива"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-stkTNP in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "товарных остатков ТНП"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-invTRK in this-procedure (
    input p-obj-type
    , input p-obj-code
    , input p-shift-date
    , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
      input p-log-file-name
      , input 1
      , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
      , vss-description
      , "товарных остатков ТНП"
      , return-value
      , trim(error-status :get-message(1))
      , trim(error-status :get-message(2))
      )
      ).
  end.
  run export-price-sum in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "сумм переоценок за смену"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-stk-den in this-procedure (
    input p-host-code
    , input p-obj-type
    , input p-obj-code
    , input p-shift-date
    , input p-shift-num
    ) no-error.
  if error-status :error
    then
  do:
    run wp-XMLWriteLog in this-procedure (
      input p-log-file-name
      , input 1
      , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
      , vss-description
      , "остатков денежных средств"
      , return-value
      , trim(error-status :get-message(1))
      , trim(error-status :get-message(2))
      )
      ).
  end.
  output stream stmxmlout close.
end.
procedure export-shift :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
  define buffer buf_shift-obj for ub.shift-obj.
  define buffer buf_clients   for ub.clients.
do
for buf_shift-obj
  , buf_clients
on error undo, return error
:
    find first buf_shift-obj no-lock
         where buf_shift-obj.obj-type   = p-obj-type
           and buf_shift-obj.obj-code   = p-obj-code
           and buf_shift-obj.shift-date = p-shift-date
           and buf_shift-obj.shift-num  = p-shift-num
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    run wp-xmltagopen( input 2, input "shift", input "" ).
    run wp-xmltagput( input 3, "objType"    , input string( buf_shift-obj.obj-type                  ), input 0 ).
    run wp-xmltagput( input 3, "objCode"    , input string( buf_shift-obj.obj-code                  ), input 0 ).
    run wp-xmltagput( input 3, "objName"    , input string( buf_clients.obj-name                    ), input 0 ).
    run wp-xmltagput( input 3, "shiftNum"   , input string( buf_shift-obj.shift-num                 ), input 0 ).
    run wp-xmltagput( input 3, "shiftName"  , input string( buf_shift-obj.shift-name                ), input 0 ).
    run wp-xmltagput( input 3, "shiftDate"  , input string( buf_shift-obj.shift-date, "99.99.9999"  ), input 0 ).
    run wp-xmltagput( input 3, "shiftTime"  , input string( buf_shift-obj.open-time, "HH:MM:SS"     ), input 0 ).
    run wp-xmltagput( input 3, "shiftEndDate"  , input string( buf_shift-obj.close-date, "99.99.9999"  ), input 0 ).
    run wp-xmltagput( input 3, "shiftEndTime"  , input string( buf_shift-obj.close-time, "HH:MM:SS"     ), input 0 ).
    run wp-xmltagclose( input 2, input "shift" ).
  end.
end procedure.
procedure export-shift-staff :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
  define buffer buf_shift-staff for ub.shift-staff.
do
for buf_shift-staff
on error undo, return error
:
    for each buf_shift-staff no-lock
       where buf_shift-staff.obj-type   = p-obj-type
         and buf_shift-staff.obj-code   = p-obj-code
         and buf_shift-staff.shift-date = p-shift-date
         and buf_shift-staff.shift-num  = p-shift-num
         and buf_shift-staff.next-shift = no
         and buf_shift-staff.psn-num   >= 0
    by buf_shift-staff.staff-role descending
    on error undo, return error
    :
      run wp-xmltagopen( input 2, input "shiftStaff", input "" ).
      run wp-xmltagput( input 3, "objType"    , input string( buf_shift-staff.obj-type                  ), input 0 ).
      run wp-xmltagput( input 3, "objCode"    , input string( buf_shift-staff.obj-code                  ), input 0 ).
      run wp-xmltagput( input 3, "shiftDate"  , input string( buf_shift-staff.shift-date, "99.99.9999"  ), input 0 ).
      run wp-xmltagput( input 3, "shiftNum"   , input string( buf_shift-staff.shift-num                 ), input 0 ).
      run wp-xmltagput( input 3, "stfPsnCode" , input string( buf_shift-staff.psn-code                  ), input 0 ).
      run wp-xmltagput( input 3, "stfName"    , input string( buf_shift-staff.name                      ), input 0 ).
      run wp-xmltagput( input 3, "stfCashier" , input string( ( buf_shift-staff.cashier <> 0 )          ), input 2 ).
      run wp-xmltagclose( input 2, input "shiftStaff" ).
    end.
  end.
end procedure.
procedure export-pay-desk-z-order :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
  define buffer buf_chk-doc for ub.chk-doc.
do
for buf_chk-doc
on error undo, return error
:
    empty temp-table temp_payDeskZOrder.
    for each buf_chk-doc no-lock
       where buf_chk-doc.obj-type   = p-obj-type
         and buf_chk-doc.obj-code   = p-obj-code
         and buf_chk-doc.shift-date = p-shift-date
         and buf_chk-doc.shift-num  = p-shift-num
    :
      if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next.
      find first temp_payDeskZOrder
           where temp_payDeskZOrder.pay-desk = buf_chk-doc.pay-desk
             and temp_payDeskZOrder.z-number = buf_chk-doc.z-number
      no-error.
      if not available temp_payDeskZOrder
      then do:
        create temp_payDeskZOrder.
        assign
          temp_payDeskZOrder.pay-desk = buf_chk-doc.pay-desk
          temp_payDeskZOrder.z-number = buf_chk-doc.z-number
        .
      end.
      assign
        temp_payDeskZOrder.sum = temp_payDeskZOrder.sum + buf_chk-doc.netto
      .
    end.
    for each temp_payDeskZOrder
    :
      if temp_payDeskZOrder.sum <> 0 then do:
        run wp-xmltagopen( input 2, input "shiftPayDeskZOrder", input "" ).
        run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                  ), input 0 ).
        run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                  ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"  ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                 ), input 0 ).
        run wp-xmltagput( input 3, "pdzPayDesk" , input string( temp_payDeskZOrder.pay-desk ), input 0 ).
        run wp-xmltagput( input 3, "pdzZOrder"  , input string( temp_payDeskZOrder.z-number ), input 0 ).
        run wp-xmltagput( input 3, "pdzSum"     , input string( temp_payDeskZOrder.sum      ), input 0 ).
        run wp-xmltagclose( input 3, input "shiftPayDeskZOrder").
      end.
    end.
  end.
end procedure.
procedure export-sum-wth :
define input parameter p-host-code  as integer          no-undo.
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
  define variable v-is-inkassator as character no-undo.
  define variable v-attr-type     as character no-undo.
  define variable v-sale-type     as character no-undo.
  define variable v-sale-code     as integer   no-undo.
  define buffer buf_clients                for ub.clients.
  define buffer buf_wth-doc                for ub.wth-doc.
  define buffer buf_wth-line               for ub.wth-line.
  define buffer buf_wealth                 for ub.wealth.
  define buffer buf_sysconf                for ub.sysconf.
  define buffer buf_temp_sumWthInkasToBank for temp_sumWthInkasToBank.
  define buffer buf_temp_sumWthInternal    for temp_sumWthInternal.
do
for buf_clients
  , buf_wth-doc
  , buf_wth-line
  , buf_wealth
  , buf_temp_sumWthInkasToBank
  , buf_temp_sumWthInternal
on error undo, return error
:
    empty temp-table buf_temp_sumWthInkasToBank.
    empty temp-table buf_temp_sumWthInternal.
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = p-host-code
    no-error.
    if available buf_sysconf then do:
      assign
        v-sale-type = buf_sysconf.sale-type
        v-sale-code = buf_sysconf.sale-code
      .
    end.
    else do:
      assign
        v-sale-type = "":U
        v-sale-code = 0
      .
    end.
    see-all-clients:
    for each buf_clients no-lock
    on error undo, return error
    :
      if buf_clients.obj-type  = v-sale-type
      and buf_clients.obj-code = v-sale-code
      then do:
        undo see-all-clients, next see-all-clients.
      end.
      run clntattr-value in this-procedure (
            input buf_clients.obj-type
          , input buf_clients.obj-code
          , input 'is-inkassator':U
          , output v-is-inkassator
          , output v-attr-type
      ).
      if v-is-inkassator = "yes":U
      then do:
        if buf_clients.obj-type = 'орг':U
        then do:
          for each buf_wth-doc no-lock
             where buf_wth-doc.obj-type   = p-obj-type
               and buf_wth-doc.obj-code   = p-obj-code
               and buf_wth-doc.shift-date = p-shift-date
               and buf_wth-doc.shift-num  = p-shift-num
               and buf_wth-doc.status_    = 'факт':U
               and buf_wth-doc.doc-type   = 'рас':U
          use-index sht-clos
          on error undo, return error
          :
            if  buf_wth-doc.cli-type   = buf_clients.obj-type
            and buf_wth-doc.cli-code   = buf_clients.obj-code
            then do:
              for each buf_wth-line no-lock
                 where buf_wth-line.doc-code = buf_wth-doc.doc-code
              on error undo, return error
              :
                if buf_wth-line.status_ = 'факт':U
                then do:
                  find first buf_temp_sumWthInkasToBank
                       where buf_temp_sumWthInkasToBank.wth-code = buf_wth-line.wth-code
                  no-error.
                  if not available buf_temp_sumWthInkasToBank
                  then do:
                    create buf_temp_sumWthInkasToBank.
                    assign
                      buf_temp_sumWthInkasToBank.wth-code = buf_wth-line.wth-code
                    .
                    find first buf_wealth no-lock
                         where buf_wealth.wth-code = buf_wth-line.wth-code
                    no-error.
                    if available buf_wealth
                    then do:
                      assign
                        buf_temp_sumWthInkasToBank.wth-name = buf_wealth.wth-name
                      .
                    end.
                  end.
                  assign
                    buf_temp_sumWthInkasToBank.fact-sum = buf_temp_sumWthInkasToBank.fact-sum + buf_wth-line.fact-sum
                  .
                end.
              end.
            end.
          end.
        end.
      end.
      else do:
        if buf_clients.host-code <> p-host-code
        and ( buf_clients.obj-type <> p-obj-type
           or buf_clients.obj-code <> p-obj-code )
        then do:
          for each buf_wth-doc no-lock
             where buf_wth-doc.obj-type   = p-obj-type
               and buf_wth-doc.obj-code   = p-obj-code
               and buf_wth-doc.shift-date = p-shift-date
               and buf_wth-doc.shift-num  = p-shift-num
               and buf_wth-doc.status_    = 'факт':U
               and buf_wth-doc.doc-type   = 'рас':U
          use-index sht-clos
          on error undo, return error
          :
            if  buf_wth-doc.cli-type   = buf_clients.obj-type
            and buf_wth-doc.cli-code   = buf_clients.obj-code
            then do:
              for each buf_wth-line no-lock
                 where buf_wth-line.doc-code = buf_wth-doc.doc-code
              on error undo, return error
              :
                if buf_wth-line.status_ = 'факт':U
                then do:
                  find first buf_temp_sumWthInternal
                       where buf_temp_sumWthInternal.wth-code = buf_wth-line.wth-code
                  no-error.
                  if not available buf_temp_sumWthInternal
                  then do:
                    create buf_temp_sumWthInternal.
                    assign
                      buf_temp_sumWthInternal.wth-code = buf_wth-line.wth-code
                    .
                    find first buf_wealth no-lock
                         where buf_wealth.wth-code = buf_wth-line.wth-code
                    no-error.
                    if available buf_wealth
                    then do:
                      assign
                        buf_temp_sumWthInternal.wth-name = buf_wealth.wth-name
                      .
                    end.
                  end.
                  assign
                    buf_temp_sumWthInternal.fact-sum = buf_temp_sumWthInternal.fact-sum + buf_wth-line.fact-sum
                  .
                end.
              end.
            end.
          end.
        end.
      end.
    end.
    for each buf_temp_sumWthInkasToBank
    :
      if buf_temp_sumWthInkasToBank.fact-sum <> 0
      then do:
        run wp-xmltagopen( input 2, input "sumWthInkasToBank", input "" ).
        run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                          ), input 0 ).
        run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                          ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"          ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                         ), input 0 ).
        run wp-xmltagput( input 3, "itbWthCode" , input string( buf_temp_sumWthInkasToBank.wth-code  ), input 0 ).
        run wp-xmltagput( input 3, "itbWthName" , input string( buf_temp_sumWthInkasToBank.wth-name  ), input 0 ).
        run wp-xmltagput( input 3, "itbWthSum"  , input string( buf_temp_sumWthInkasToBank.fact-sum  ), input 0 ).
        run wp-xmltagclose( input 3, input "sumWthInkasToBank").
      end.
    end.
    for each buf_temp_sumWthInternal
    :
      if buf_temp_sumWthInternal.fact-sum <> 0
      then do:
        run wp-xmltagopen( input 2, input "sumWthInternal", input "" ).
        run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                          ), input 0 ).
        run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                          ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"          ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                         ), input 0 ).
        run wp-xmltagput( input 3, "inWthCode"  , input string( buf_temp_sumWthInternal.wth-code       ), input 0 ).
        run wp-xmltagput( input 3, "inWthName"  , input string( buf_temp_sumWthInternal.wth-name       ), input 0 ).
        run wp-xmltagput( input 3, "inWthSum"   , input string( buf_temp_sumWthInternal.fact-sum      ), input 0 ).
        run wp-xmltagclose( input 3, input "sumWthInternal").
      end.
    end.
  end.
end procedure.
procedure export-stk-wth-in-place :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
  define variable v-stock-start  as decimal no-undo.
  define variable v-stock-end    as decimal no-undo.
  define variable v-income       as decimal no-undo.
  define variable v-income-cassa as decimal no-undo.
  define variable v-income-other as decimal no-undo.
  define variable v-incass       as decimal no-undo.
  define variable v-incass-bank  as decimal no-undo.
  define variable v-incass-other as decimal no-undo.
  define variable v-incass-cassa as decimal no-undo.
  define buffer buf_wth-place          for ub.wth-place.
  define buffer buf_wth-pobj           for ub.wth-pobj.
  define buffer buf_wealth             for ub.wealth.
  define buffer buf_temp_stkWthInPlace for temp_stkWthInPlace.
do
for buf_wth-place
  , buf_wth-pobj
  , buf_wealth
  , buf_temp_stkWthInPlace
on error undo, return error
:
    empty temp-table buf_temp_stkWthInPlace.
    for each buf_wth-place no-lock
       where buf_wth-place.obj-type     = p-obj-type
         and buf_wth-place.obj-code     = p-obj-code
         and buf_wth-place.cash-desk    <> ?
    :
      for each buf_wth-pobj no-lock
         where buf_wth-pobj.obj-type  = p-obj-type
           and buf_wth-pobj.obj-code  = p-obj-code
           and buf_wth-pobj.w-p-code  = buf_wth-place.w-p-code
      on error undo, return error
      :
        run wth-lib_full-inf-shift-place in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input buf_wth-pobj.wth-code
            , input buf_wth-pobj.w-p-code
            , input p-shift-date
            , input p-shift-num
            , output v-stock-start
            , output v-stock-end
            , output v-income
            , output v-income-cassa
            , output v-income-other
            , output v-incass
            , output v-incass-bank
            , output v-incass-other
            , output v-incass-cassa
        ).
        find first buf_temp_stkWthInPlace
             where buf_temp_stkWthInPlace.w-p-code = buf_wth-pobj.w-p-code
               and buf_temp_stkWthInPlace.wth-code = buf_wth-pobj.wth-code
        no-error.
        if not available buf_temp_stkWthInPlace
        then do:
          create buf_temp_stkWthInPlace.
          assign
            buf_temp_stkWthInPlace.w-p-code    = buf_wth-pobj.w-p-code
            buf_temp_stkWthInPlace.wth-code    = buf_wth-pobj.wth-code
            buf_temp_stkWthInPlace.w-p-name    = buf_wth-place.w-p-name
            buf_temp_stkWthInPlace.stock-start = v-stock-start
            buf_temp_stkWthInPlace.stock-end   = v-stock-end
          .
          find first buf_wealth no-lock
               where buf_wealth.wth-code = buf_wth-pobj.wth-code
          no-error.
          if available buf_wealth
          then do:
            assign
              buf_temp_stkWthInPlace.wth-name = buf_wealth.wth-name
            .
          end.
        end.
      end.
    end.
    for each buf_temp_stkWthInPlace
    :
      if buf_temp_stkWthInPlace.stock-start <> 0
      or buf_temp_stkWthInPlace.stock-end <> 0
      then do:
        run wp-xmltagopen( input 2, input "stkWthInPlace", input "" ).
        run wp-xmltagput( input 3, "objType"        , input string( p-obj-type                            ), input 0 ).
        run wp-xmltagput( input 3, "objCode"        , input string( p-obj-code                            ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"            ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                           ), input 0 ).
        run wp-xmltagput( input 3, "swpWPCode"      , input string( buf_temp_stkWthInPlace.w-p-code       ), input 0 ).
        run wp-xmltagput( input 3, "swpWthCode"     , input string( buf_temp_stkWthInPlace.wth-code       ), input 0 ).
        run wp-xmltagput( input 3, "swpWPName"      , input string( buf_temp_stkWthInPlace.w-p-name       ), input 0 ).
        run wp-xmltagput( input 3, "swpWthName"     , input string( buf_temp_stkWthInPlace.wth-name       ), input 0 ).
        run wp-xmltagput( input 3, "swpStockStart"  , input string( buf_temp_stkWthInPlace.stock-start    ), input 0 ).
        run wp-xmltagput( input 3, "swpStockEnd"    , input string( buf_temp_stkWthInPlace.stock-end      ), input 0 ).
        run wp-xmltagclose( input 3, input "stkWthInPlace").
      end.
    end.
  end.
end procedure.
procedure export-techPro :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
  define variable v-shftrep2   as character no-undo.
  define variable v-attr-value as character no-undo.
  define variable v-attr-type  as character no-undo.
  define buffer buf_clients        for ub.clients.
  define buffer buf_trn-doc        for ub.trn-doc.
  define buffer buf_doc-line       for ub.doc-line.
  define buffer buf_goods          for ub.goods.
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer buf_temp_techPro   for temp_techPro.
  define buffer buf_doc-pl         for ub.doc-pl.
  define buffer buf_chk-gds        for ub.chk-gds.
  define buffer buf_chk-gds-pay    for ub.chk-gds-pay.
  DEFINE buffer buf_chk-doc        for ub.chk-doc.
  define buffer buf_temp_chk-doc   for temp_chk-doc.
  define buffer buf_bar-code       for ub.bar-code.
do
for buf_clients
  , buf_trn-doc
  , buf_doc-line
  , buf_goods
  , buf_temp_techPro
  , buf_doc-pl
  , buf_chk-gds
  , buf_bar-code
on error undo, return error
:
    empty temp-table buf_temp_techPro.
    for each buf_clients no-lock
    on error undo, return error
    :
      run clntattr-value in this-procedure ( input buf_clients.obj-type
                                             , input buf_clients.obj-code
                                             , input 'shftrep2':U
                                             , output v-shftrep2
                                             , output v-attr-type
                                           ).
      if v-shftrep2 = "yes":U
      then do:
        sum-all-trn-doc-tech-pro:
        for each buf_trn-doc no-lock
           where buf_trn-doc.obj-type   = p-obj-type
             and buf_trn-doc.obj-code   = p-obj-code
             and buf_trn-doc.shift-date = p-shift-date
             and buf_trn-doc.shift-num  = p-shift-num
             and buf_trn-doc.status_    = 'факт':U
            on error undo, return error
            :
          def var v-value as character no-undo.
          def var v-type  as character no-undo.
          def var v-tech-pass as logical no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'techpass':U ,
                       output v-value ,
                       output v-type ) no-error .
          assign
            v-tech-pass = yes when v-value = "yes".
          if  buf_trn-doc.cli-type = buf_clients.obj-type   and
              buf_trn-doc.cli-code = buf_clients.obj-code   and
              buf_trn-doc.ext-doc-type = 'we':U
          then do:
            if not (v-tech-pass or can-find(first ub.sale-doc where ub.sale-doc.doc-code = buf_trn-doc.doc-code and ub.sale-doc.doc-kind = 'trf':U))
              then
            do:
              undo sum-all-trn-doc-tech-pro, next sum-all-trn-doc-tech-pro.
            end.
            for each buf_doc-line no-lock
               where buf_doc-line.doc-code = buf_trn-doc.doc-code
              on error undo, return error
              :
              find first buf_temp_techPro
                   where buf_temp_techPro.artic       = buf_doc-line.artic
                     and buf_temp_techPro.prod-type   = buf_doc-line.prod-type
                     and buf_temp_techPro.prod-code   = buf_doc-line.prod-code
                no-error.
              if not available buf_temp_techPro then do:
                create buf_temp_techPro.
                assign
                  buf_temp_techPro.artic     = buf_doc-line.artic
                  buf_temp_techPro.prod-type = buf_doc-line.prod-type
                  buf_temp_techPro.prod-code = buf_doc-line.prod-code
                .
                find first buf_goods no-lock
                     where buf_goods.artic     = buf_temp_techPro.artic
                       and buf_goods.prod-type = buf_temp_techPro.prod-type
                       and buf_goods.prod-code = buf_temp_techPro.prod-code
                  no-error.
                if available buf_goods then do:
                  assign
                    buf_temp_techPro.gds-code = buf_goods.gds-code
                    buf_temp_techPro.gds-name = buf_goods.gds-name
                  .
                    buf_temp_techPro.envd = no .
                  for each buf_doc-pl no-lock
                     where buf_doc-pl.gds-code = buf_goods.gds-code
                       and buf_doc-pl.obj-code = p-obj-code
                       and buf_doc-pl.obj-type = p-obj-type
                       and buf_doc-pl.out-code = buf_trn-doc.doc-code:
                    assign
                      buf_temp_techPro.pl-code       = buf_doc-pl.pl-code
                      buf_temp_techPro.qnty          = buf_doc-pl.fact-qnty
                      buf_temp_techPro.cli-qnty      = buf_doc-pl.cli-fact-qnty
                      buf_temp_techPro.state-density = buf_doc-pl.cli-fact-qnty / buf_doc-pl.fact-qnty
                    .
                  end.
                end.
              end.
              assign
                buf_temp_techPro.fact-qnty = buf_temp_techPro.fact-qnty + buf_doc-line.fact-qnty
              .
              for each buf_bar-code no-lock
                 where buf_bar-code.gds-code = buf_goods.gds-code :
                for each buf_chk-doc where buf_chk-doc.chk-type = integer('17':U)
                     and buf_chk-doc.out-code = buf_trn-doc.out-code:
                  find first buf_chk-gds no-lock where buf_chk-gds.b-code = buf_bar-code.b-code
                        and  buf_chk-gds.doc-code = buf_chk-doc.doc-code no-error .
                  if AVAILABLE buf_chk-gds then
                  do:
                    find first buf_temp_chk-doc where buf_temp_chk-doc.b-code = buf_chk-gds.b-code and
                              buf_temp_chk-doc.doc-code = buf_chk-gds.doc-code and
                              buf_temp_chk-doc.chk-type = integer('17':U)  no-error.
                    if not AVAILABLE buf_temp_chk-doc then
                    do:
                      create buf_temp_chk-doc .
                      ASSIGN
                        buf_temp_chk-doc.doc-code      = buf_chk-gds.doc-code
                        buf_temp_chk-doc.gds-code      = buf_goods.gds-code
                        buf_temp_chk-doc.b-code        = buf_chk-gds.b-code
                        buf_temp_chk-doc.chk-date      = buf_chk-doc.chk-date
                        buf_temp_chk-doc.qnty          = buf_chk-gds.doc-qnty
                        buf_temp_chk-doc.nozzle-code   = buf_chk-gds.nozzle-code
                        buf_temp_chk-doc.pump          = buf_chk-gds.pump
                        buf_temp_chk-doc.state-density = buf_chk-gds.density
                        buf_temp_chk-doc.pay-desk      = buf_chk-doc.pay-desk
                        buf_temp_chk-doc.pl-code       = integer(buf_chk-gds.loc1)
                        buf_temp_chk-doc.chk-type      = integer('17':U)
                        buf_temp_chk-doc.cashier       = buf_chk-doc.cashier
                        buf_temp_chk-doc.chk-num       = buf_chk-doc.chk-num
                        buf_temp_chk-doc.chk-time      = buf_chk-doc.chk-time
                      .
                    end.
                  end.
                end.
              end.
            end.
          end.
        end.
      end.
    end.
    for each buf_temp_techPro
    :
      if buf_temp_techPro.fact-qnty <> 0
      then do:
        run wp-xmltagopen( input 2, input "techPro", input "" ).
        run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                   ), input 0 ).
        run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                   ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"   ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                  ), input 0 ).
        run wp-xmltagput( input 3, "tprArtic"   , input string( buf_temp_techPro.artic       ), input 0 ).
        run wp-xmltagput( input 3, "tprProdType", input string( buf_temp_techPro.prod-type   ), input 0 ).
        run wp-xmltagput( input 3, "tprProdCode", input string( buf_temp_techPro.prod-code   ), input 0 ).
        run wp-xmltagput( input 3, "tprGdsCode" , input string( buf_temp_techPro.gds-code    ), input 0 ).
        run wp-xmltagput( input 3, "tprGdsName" , input string( buf_temp_techPro.gds-name    ), input 0 ).
        run wp-xmltagput( input 3, "tprGdsENVD" , input string( buf_temp_techPro.envd        ), input 3 ).
        run wp-xmltagput( input 3, "tprFactQnty", input string( buf_temp_techPro.fact-qnty   ), input 0 ).
        run wp-xmltagopen( input 3, input "tprProPL", input "" ).
        run wp-xmltagput( input 4, "tprProPLCode"  , input string( buf_temp_techPro.pl-code     ), input 0 ).
        run wp-xmltagput( input 4, "tprProQnty"    , input string( buf_temp_techPro.qnty        ), input 0 ).
        run wp-xmltagput( input 4, "tprProCliQnty" , input string( buf_temp_techPro.cli-qnty    ), input 0 ).
        run wp-xmltagput( input 4, "tprProDensity" , input string( buf_temp_techPro.state-density, ">>>>>>>>>9.99"), input 0 ).
        run wp-xmltagclose( input 3, input "tprProPL").
        for each buf_temp_chk-doc where buf_temp_chk-doc.gds-code = buf_temp_techPro.gds-code and buf_temp_chk-doc.chk-type = integer('17':U) :
          run wp-xmltagopen( input 3, input "techProChk", input "" ).
          run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
          run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
          run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
          run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
          run wp-xmltagput( input 4, "ChkQnty"    , input string( buf_temp_chk-doc.qnty       ), input 0 ).
          run wp-xmltagput( input 4, "ChkTRK"     , input string( buf_temp_chk-doc.pump       ), input 0 ).
          run wp-xmltagput( input 4, "ChkNozzle"  , input string( buf_temp_chk-doc.nozzle-code), input 0 ).
          run wp-xmltagput( input 4, "ChkPL"      , input string( buf_temp_chk-doc.pl-code    ), input 2 ).
          run wp-xmltagclose( input 3, input "techProChk").
        end.
      end.
      run wp-xmltagclose( input 2, input "techPro").
    end.
  end.
end procedure.
procedure export-CorrChk :
  define input parameter p-obj-type   as character        no-undo.
  define input parameter p-obj-code   as integer          no-undo.
  define input parameter p-shift-date as date             no-undo.
  define input parameter p-shift-num  as integer          no-undo.
  define buffer buf_goods        for ub.goods.
  define buffer buf_chk-gds      for ub.chk-gds.
  define buffer buf_chk-pay      for ub.chk-pay.
  define buffer buf_chk-pay-attr for ub.chk-pay-attr.
  DEFINE buffer buf_chk-doc      for ub.chk-doc.
  define buffer buf_temp_chk-doc for temp_chk-doc.
  define buffer buf_temp_chk-gds for temp_chk-gds.
  define buffer buf_bar-code     for ub.bar-code.
  define variable v-RRN               as character no-undo.
  do
    for  buf_chk-gds
    , buf_chk-pay
    , buf_chk-doc
    on error undo, return error
    :
    empty temp-table buf_temp_chk-doc.
    empty temp-table buf_temp_chk-gds.
    for each buf_chk-doc where (buf_chk-doc.chk-type = integer('44':U) or buf_chk-doc.chk-type = integer('43':U) )
      and buf_chk-doc.shift-date = p-shift-date and buf_chk-doc.shift-num = p-shift-num
      and buf_chk-doc.obj-code = p-obj-code and buf_chk-doc.obj-type = p-obj-type    :
      find first buf_temp_chk-doc where buf_temp_chk-doc.doc-code = buf_chk-doc.doc-code no-error.
      if not AVAILABLE buf_temp_chk-doc then
      do:
        create buf_temp_chk-doc .
        ASSIGN
          buf_temp_chk-doc.doc-code = buf_chk-doc.doc-code
          buf_temp_chk-doc.doc-num  = buf_chk-doc.doc-num
          buf_temp_chk-doc.doc-num2 = buf_chk-doc.doc-num2
          buf_temp_chk-doc.chk-date = buf_chk-doc.chk-date
          buf_temp_chk-doc.pay-desk = buf_chk-doc.pay-desk
          buf_temp_chk-doc.chk-type = buf_chk-doc.chk-type
          buf_temp_chk-doc.cashier  = buf_chk-doc.cashier
          buf_temp_chk-doc.chk-num  = buf_chk-doc.chk-num
          buf_temp_chk-doc.chk-time = buf_chk-doc.chk-time
          buf_temp_chk-doc.netto    = buf_chk-doc.netto
        .
        if num-entries(buf_chk-doc.doc-num2, ":") = 2
        then do :
          if entry(1, buf_chk-doc.doc-num2, ":") = "0"
          then buf_temp_chk-doc.doc-num2 = "самостоятельно" .
          else
          if entry(1, buf_chk-doc.doc-num2, ":") = "1"
          then buf_temp_chk-doc.doc-num2 = "по предписанию" .
          else
          buf_temp_chk-doc.doc-num2 = "неизвестн." .
        end.
        else
        buf_temp_chk-doc.doc-num2 = "неизвестн." .
      end.
      for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code :
        find first buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_chk-gds.doc-code and buf_temp_chk-gds.line-num = buf_chk-gds.line-num no-error .
        if not AVAILABLE buf_temp_chk-gds then
        do:
          create buf_temp_chk-gds .
          assign
            buf_temp_chk-gds.doc-code    = buf_chk-gds.doc-code
            buf_temp_chk-gds.b-code      = buf_chk-gds.b-code
            buf_temp_chk-gds.src-sum     = buf_chk-gds.src-sum
            buf_temp_chk-gds.OFDcode     = buf_chk-gds.depart-type
            buf_temp_chk-gds.OFDvalue    = buf_chk-gds.road-tax
            buf_temp_chk-gds.line-num    = buf_chk-gds.line-num
            .
        end.
      end.
    end.
    run wp-xmltagopen( input 2, input "CorrChk", input "" ).
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer('43':U):
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "ПриходКорр" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( '43':U   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTotal"   , input string( buf_temp_chk-doc.netto   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reason"     , input string( buf_temp_chk-doc.doc-num   ), input 0 ).
      run wp-xmltagput( input 4, "CorrType"   , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckLine", input "" ).
        run wp-xmltagput( input 5, "ChkTaxCode", input string( buf_temp_chk-gds.b-code ), input 0 ).
        run wp-xmltagput( input 5, "ChkSum"    , input string( buf_temp_chk-gds.src-sum ), input 0 ).
        run wp-xmltagput( input 5, "ChkCSTCode"  , input string( buf_temp_chk-gds.OFDcode ), input 0 ).
        run wp-xmltagput( input 5, "ChkCSTValue" , input string( buf_temp_chk-gds.OFDvalue ), input 0 ).
        run wp-xmltagclose( input 4, input "CheckLine").
      end .
      for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_temp_chk-doc.doc-code :
        run wp-xmltagopen( input 4, input "CheckPay", input "" ).
        run wp-xmltagput( input 5, "ChkPayCode", input string( buf_chk-pay.pay-code ), input 0 ).
        run wp-xmltagput( input 5, "ChkPaySum" , input string( buf_chk-pay.tot-sum ), input 0 ).
        v-RRN = '' .
        for first buf_chk-pay-attr no-lock
            where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
            and buf_chk-pay-attr.attr-code = "CPDOC"
            and buf_chk-pay-attr.line-num = buf_chk-pay.line-num  :
            v-RRN = buf_chk-pay-attr.attr-value .
        end.
        if v-RRN = ''
        then
        do:
            for first buf_chk-pay-attr no-lock
                where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                and buf_chk-pay-attr.attr-code = "RRN"
                and buf_chk-pay-attr.line-num = buf_chk-pay.line-num:
                v-RRN = buf_chk-pay-attr.attr-value .
            end.
        end.
        run wp-xmltagput( input 5, input "OperationCode", input v-RRN                              , input 0 ).
        run wp-xmltagclose( input 4, input "CheckPay").
      end .
      run wp-xmltagclose( input 3, input "Check").
    end.
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer('44':U):
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "РасходКорр" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( '44':U   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTotal"   , input string( buf_temp_chk-doc.netto   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reason"     , input string( buf_temp_chk-doc.doc-num   ), input 0 ).
      run wp-xmltagput( input 4, "CorrType"   , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckLine", input "" ).
        run wp-xmltagput( input 5, "ChkTaxCode", input string( buf_temp_chk-gds.b-code ), input 0 ).
        run wp-xmltagput( input 5, "ChkSum"    , input string( buf_temp_chk-gds.src-sum), input 0 ).
        run wp-xmltagput( input 5, "ChkCSTCode"  , input string( buf_temp_chk-gds.OFDcode ), input 0 ).
        run wp-xmltagput( input 5, "ChkCSTValue" , input string( buf_temp_chk-gds.OFDvalue ), input 0 ).
        run wp-xmltagclose( input 4, input "CheckLine").
      end .
      for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_temp_chk-doc.doc-code :
        run wp-xmltagopen( input 4, input "CheckPay", input "" ).
        run wp-xmltagput( input 5, "ChkPayCode", input string( buf_chk-pay.pay-code ), input 0 ).
        run wp-xmltagput( input 5, "ChkPaySum" , input string( buf_chk-pay.tot-sum ), input 0 ).
        run wp-xmltagclose( input 4, input "CheckPay").
      end .
      run wp-xmltagclose( input 3, input "Check").
    end.
        run wp-xmltagclose( input 2, input "CorrChk").
  end.
end procedure.
procedure export-techChk :
  define input parameter p-obj-type   as character        no-undo.
  define input parameter p-obj-code   as integer          no-undo.
  define input parameter p-shift-date as date             no-undo.
  define input parameter p-shift-num  as integer          no-undo.
  define buffer buf_goods        for ub.goods.
  define buffer buf_chk-gds      for ub.chk-gds.
  DEFINE buffer buf_chk-doc      for ub.chk-doc.
  define buffer buf_temp_chk-doc for temp_chk-doc.
  define buffer buf_temp_chk-gds for temp_chk-gds.
  define buffer buf_bar-code     for ub.bar-code.
  do
    for buf_goods
    , buf_chk-gds
    , buf_bar-code
    , buf_chk-doc
    on error undo, return error
    :
    empty temp-table buf_temp_chk-doc.
    empty temp-table buf_temp_chk-gds.
    for each buf_chk-doc no-lock
       where buf_chk-doc.obj-type = p-obj-type
         and buf_chk-doc.obj-code = p-obj-code
         and buf_chk-doc.shift-date = p-shift-date
         and buf_chk-doc.shift-num  = p-shift-num
         and (buf_chk-doc.chk-type = integer('16':U)
           or buf_chk-doc.chk-type = integer('14':U)
           or buf_chk-doc.chk-type = integer('36':U)
           or buf_chk-doc.chk-type = integer('15':U)
             ) :
        find first buf_temp_chk-doc where buf_temp_chk-doc.doc-code = buf_chk-doc.doc-code no-error.
      if not AVAILABLE buf_temp_chk-doc then do:
        create buf_temp_chk-doc .
        ASSIGN
          buf_temp_chk-doc.doc-code = buf_chk-doc.doc-code
          buf_temp_chk-doc.doc-num2 = buf_chk-doc.doc-num2
          buf_temp_chk-doc.chk-date = buf_chk-doc.chk-date
          buf_temp_chk-doc.pay-desk = buf_chk-doc.pay-desk
          buf_temp_chk-doc.chk-type = buf_chk-doc.chk-type
          buf_temp_chk-doc.cashier  = buf_chk-doc.cashier
          buf_temp_chk-doc.chk-num  = buf_chk-doc.chk-num
          buf_temp_chk-doc.chk-time = buf_chk-doc.chk-time
        .
      end.
      for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code :
        find first buf_bar-code where buf_bar-code.b-code = buf_chk-gds.b-code no-error .
        if AVAILABLE buf_bar-code then
        do:
            find first buf_temp_chk-gds
                 where buf_temp_chk-gds.doc-code = buf_chk-gds.doc-code
                   and buf_temp_chk-gds.line-num = buf_chk-gds.line-num no-error .
            if not AVAILABLE buf_temp_chk-gds then
            do:
              create buf_temp_chk-gds .
              assign
                buf_temp_chk-gds.doc-code    = buf_chk-gds.doc-code
                buf_temp_chk-gds.gds-code    = buf_bar-code.gds-code
                buf_temp_chk-gds.b-code      = buf_chk-gds.b-code
                buf_temp_chk-gds.qnty        = buf_chk-gds.doc-qnty
                buf_temp_chk-gds.nozzle-code = buf_chk-gds.nozzle-code
                buf_temp_chk-gds.pump        = buf_chk-gds.pump
                buf_temp_chk-gds.line-num    = buf_chk-gds.line-num
              .
              if buf_chk-doc.chk-type = integer('14':U) then
              do:
                if buf_chk-gds.write-off-code = 0 then buf_temp_chk-gds.sbros-type = "не пролито".
                if buf_chk-gds.write-off-code = 1 then buf_temp_chk-gds.sbros-type = "пролито".
              end.
            end.
        end.
      end.
    end.
    run wp-xmltagopen( input 2, input "TechChk", input "" ).
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer('16':U):
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "ПеревТрнзкц" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( '16':U   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reference-num"    , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckGds", input "" ).
        run wp-xmltagput( input 5, "ChkGds-code", input string( buf_temp_chk-gds.gds-code   ), input 0 ).
        run wp-xmltagput( input 5, "ChkQnty"    , input string( buf_temp_chk-gds.qnty,  "->>>>>>>>>9.99"       ), input 0 ).
        run wp-xmltagput( input 5, "ChkTRK"     , input string( buf_temp_chk-gds.pump       ), input 0 ).
        run wp-xmltagput( input 5, "ChkNozzle"  , input string( buf_temp_chk-gds.nozzle-code), input 0 ).
        run wp-xmltagput( input 5, "ChkPL"      , input string( buf_temp_chk-gds.pl-code    ), input 2 ).
        run wp-xmltagclose( input 4, input "CheckGds").
      end.
      run wp-xmltagclose( input 3, input "Check").
    end.
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer('14':U):
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "СбросТрнзкц" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( '14':U   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reference-num"    , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckGds", input "" ).
        run wp-xmltagput( input 5, "ChkGds-code", input string( buf_temp_chk-gds.gds-code   ), input 0 ).
        run wp-xmltagput( input 5, "ChkReason"  , input string( buf_temp_chk-gds.sbros-type   ), input 0 ).
        run wp-xmltagput( input 5, "ChkQnty"    , input string( buf_temp_chk-gds.qnty,  "->>>>>>>>>9.99"       ), input 0 ).
        run wp-xmltagput( input 5, "ChkTRK"     , input string( buf_temp_chk-gds.pump       ), input 0 ).
        run wp-xmltagput( input 5, "ChkNozzle"  , input string( buf_temp_chk-gds.nozzle-code), input 0 ).
        run wp-xmltagput( input 5, "ChkPL"      , input string( buf_temp_chk-gds.pl-code    ), input 2 ).
        run wp-xmltagclose( input 4, input "CheckGds").
      end.
      run wp-xmltagclose( input 3, input "Check").
    end.
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer('36':U):
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "РазблТрнзкц" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( '36':U   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reference-num"    , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckGds", input "" ).
        run wp-xmltagput( input 5, "ChkGds-code", input string( buf_temp_chk-gds.gds-code   ), input 0 ).
        run wp-xmltagput( input 5, "ChkQnty"    , input string( buf_temp_chk-gds.qnty,  "->>>>>>>>>9.99"       ), input 0 ).
        run wp-xmltagput( input 5, "ChkTRK"     , input string( buf_temp_chk-gds.pump       ), input 0 ).
        run wp-xmltagput( input 5, "ChkNozzle"  , input string( buf_temp_chk-gds.nozzle-code), input 0 ).
        run wp-xmltagput( input 5, "ChkPL"      , input string( buf_temp_chk-gds.pl-code    ), input 2 ).
        run wp-xmltagclose( input 4, input "CheckGds").
      end.
      run wp-xmltagclose( input 3, input "Check").
    end.
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer('15':U):
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "Перелив" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( '15':U   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reference-num"    , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckGds", input "" ).
        run wp-xmltagput( input 5, "ChkGds-code", input string( buf_temp_chk-gds.gds-code   ), input 0 ).
        run wp-xmltagput( input 5, "ChkQnty"    , input string( buf_temp_chk-gds.qnty,  "->>>>>>>>>9.99"       ), input 0 ).
        run wp-xmltagput( input 5, "ChkTRK"     , input string( buf_temp_chk-gds.pump       ), input 0 ).
        run wp-xmltagput( input 5, "ChkNozzle"  , input string( buf_temp_chk-gds.nozzle-code), input 0 ).
        run wp-xmltagput( input 5, "ChkPL"      , input string( buf_temp_chk-gds.pl-code    ), input 2 ).
        run wp-xmltagclose( input 4, input "CheckGds").
      end.
      run wp-xmltagclose( input 3, input "Check").
    end.
    run wp-xmltagclose( input 2, input "TechChk").
  end.
end procedure.
procedure export-stkShift :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
define VARIABLE v-shift-date as date             no-undo.
define VARIABLE v-shift-num  as integer          no-undo.
define buffer end_shift-obj      for ub.shift-obj .
define buffer previous-shift-obj for ub.shift-obj.
define variable fo      as decimal no-undo init 0.
define variable prev-fo as decimal no-undo init 0.
define variable moving  as logical no-undo init yes.
  define buffer buf_rvs-doc              for ub.rvs-doc.
  define buffer buf_rvs-line             for ub.rvs-line.
  define buffer buf_rvs-line-pump        for ub.rvs-line-pump.
  define buffer buf_goods                for ub.goods.
  define buffer buf_temp_stkShiftEnd     for temp_stkShiftEnd.
  define buffer buf_temp_stkPlShiftEnd   for temp_stkPlShiftEnd.
  define buffer buf_temp_stkTRKShiftEnd  for temp_stkTRKShiftEnd.
  define buffer buf_temp_stkShiftOpen    for temp_stkShiftOpen.
  define buffer buf_temp_stkPlShiftOpen  for temp_stkPlShiftOpen.
  define buffer buf_temp_stkTRKShiftOpen for temp_stkTRKShiftOpen.
  find first end_shift-obj share-lock
       where end_shift-obj.obj-type   = p-obj-type
         and end_shift-obj.obj-code   = p-obj-code
         and end_shift-obj.shift-date = p-shift-date
         and end_shift-obj.shift-num  = p-shift-num
    no-error.
  if not available end_shift-obj then do:
    run wp-XMLWriteLog in this-procedure (
         input p-log-file-name
       , input 1
       , input substitute( "&1. Не найдена смена с порядковым номером &2 от &3 для объекта &4 &5. &6. &7. &8."
                               , vss-description
                               , p-shift-num
                               , p-shift-date
                               , p-obj-type
                               , p-obj-code
                               , return-value
                               , trim(error-status :get-message(1))
                               , trim(error-status :get-message(2))
                       )
    ).
  end.
  else do:
    assign
      fo = end_shift-obj.fact-order
    .
  end.
  find last previous-shift-obj share-lock
      where previous-shift-obj.obj-type = p-obj-type
        and previous-shift-obj.obj-code = p-obj-code
        and (( previous-shift-obj.shift-date = p-shift-date
           and previous-shift-obj.shift-num < p-shift-num
             )
         or previous-shift-obj.shift-date < p-shift-date
            )
    use-index pi no-error.
  if available previous-shift-obj then do:
    assign
      prev-fo = previous-shift-obj.fact-order
    .
  end.
  do
    for buf_rvs-doc
    , buf_rvs-line
    , buf_goods
    , buf_temp_stkShiftEnd
    , buf_temp_stkPlShiftEnd
    , buf_temp_stkTRKShiftEnd
    on error undo, return error
    :
    empty temp-table buf_temp_stkShiftEnd.
    empty temp-table buf_temp_stkPlShiftEnd.
    empty temp-table buf_temp_stkTRKShiftEnd.
    if available previous-shift-obj then do:
      assign
        v-shift-date = previous-shift-obj.shift-date
        v-shift-num  = previous-shift-obj.shift-num
      .
    end.
    find first buf_rvs-doc no-lock
         where buf_rvs-doc.obj-type     = p-obj-type
           and buf_rvs-doc.obj-code     = p-obj-code
           and buf_rvs-doc.shift-date   = p-shift-date
           and buf_rvs-doc.shift-num    = p-shift-num
           and buf_rvs-doc.status_      = 'факт':U
           and buf_rvs-doc.rvs-type     = 'смена':U
    use-index shift
    no-error.
    if available buf_rvs-doc
    then do:
      for each buf_rvs-line no-lock
         where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
           and buf_rvs-line.obj-type = p-obj-type
           and buf_rvs-line.obj-code = p-obj-code
        on error undo, return error
        :
        find first buf_temp_stkShiftEnd
             where buf_temp_stkShiftEnd.gds-code = buf_rvs-line.gds-code
        no-error.
        if not available buf_temp_stkShiftEnd
        then do:
          create buf_temp_stkShiftEnd.
          assign
            buf_temp_stkShiftEnd.gds-code = buf_rvs-line.gds-code
          .
          find first buf_goods no-lock
               where buf_goods.gds-code = buf_rvs-line.gds-code
          no-error.
          if available buf_goods
          then do:
            assign
              buf_temp_stkShiftEnd.artic     = buf_goods.artic
              buf_temp_stkShiftEnd.prod-type = buf_goods.prod-type
              buf_temp_stkShiftEnd.prod-code = buf_goods.prod-code
              buf_temp_stkShiftEnd.gds-name  = buf_goods.gds-name
              buf_temp_stkShiftEnd.qnty      = 0.0
              buf_temp_stkShiftEnd.cli-qnty  = 0.0
            .
              buf_temp_stkShiftEnd.envd = no .
          end.
        end.
        assign
          buf_temp_stkShiftEnd.qnty     = buf_temp_stkShiftEnd.qnty + buf_rvs-line.state-measure-qnty
          buf_temp_stkShiftEnd.cli-qnty = buf_temp_stkShiftEnd.cli-qnty + buf_rvs-line.state-measure-cli-qnty
        .
        find first buf_temp_stkPlShiftEnd
             where buf_temp_stkPlShiftEnd.gds-code = buf_rvs-line.gds-code
               and buf_temp_stkPlShiftEnd.pl-code = buf_rvs-line.pl-code
        no-error.
        if not available buf_temp_stkPlShiftEnd
        then do:
          create buf_temp_stkPlShiftEnd.
          assign
            buf_temp_stkPlShiftEnd.gds-code = buf_rvs-line.gds-code
            buf_temp_stkPlShiftEnd.pl-code  = buf_rvs-line.pl-code
          .
          find first buf_goods no-lock
               where buf_goods.gds-code = buf_rvs-line.gds-code
          no-error.
          if available buf_goods
          then do:
            assign
              buf_temp_stkPlShiftEnd.qnty            = buf_rvs-line.state-measure-qnty
              buf_temp_stkPlShiftEnd.cli-qnty        = buf_rvs-line.state-measure-cli-qnty
              buf_temp_stkPlShiftEnd.state-density   = buf_rvs-line.state-density
              buf_temp_stkPlShiftEnd.system-qnty     = buf_rvs-line.system-qnty
              buf_temp_stkPlShiftEnd.systen-cli-qnty = buf_rvs-line.system-cli-qnty
              buf_temp_stkPlShiftEnd.temperature     = buf_rvs-line.state-temperature
              buf_temp_stkPlShiftEnd.level-petrol    = buf_rvs-line.state-level-petrol
              buf_temp_stkPlShiftEnd.level-total     = buf_rvs-line.state-level-total
              buf_temp_stkPlShiftEnd.level-water     = buf_rvs-line.state-level-water
              buf_temp_stkPlShiftEnd.state-add-quantity        = buf_rvs-line.state-add-qnty
            .
          end.
        end.
      end.
      for each buf_rvs-line-pump no-lock where
            buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
        and buf_rvs-line-pump.obj-type = p-obj-type
        and buf_rvs-line-pump.obj-code = p-obj-code
        break
        by buf_rvs-line-pump.pump-code
        by buf_rvs-line-pump.nozzle-code
        on error undo, return error:
        if first-of(buf_rvs-line-pump.nozzle-code) then do:
          find first buf_temp_stkTrkShiftEnd where
                     buf_temp_stkTrkShiftEnd.pump-code = buf_rvs-line-pump.pump-code
            and buf_temp_stkTrkShiftEnd.nozzle-code = buf_rvs-line-pump.nozzle-code
            and buf_temp_stkTRKShiftEnd.pl-code = buf_rvs-line-pump.pl-code no-error.
          if not available buf_temp_stkTrkShiftEnd then do:
            create buf_temp_stkTrkShiftEnd.
            assign
              buf_temp_stkTRKShiftEnd.pl-code      = buf_rvs-line-pump.pl-code
              buf_temp_stkTrkShiftEnd.pump-code    = buf_rvs-line-pump.pump-code
              buf_temp_stkTrkShiftEnd.nozzle-code  = buf_rvs-line-pump.nozzle-code
              buf_temp_stkTrkShiftEnd.gds-code     = buf_rvs-line-pump.gds-code
              buf_temp_stkTrkShiftEnd.state-mh-cnt = buf_rvs-line-pump.state-mh-cnt
            .
          end.
        end.
      end.
    end.
    find first buf_rvs-doc no-lock
         where buf_rvs-doc.obj-type     = p-obj-type
           and buf_rvs-doc.obj-code     = p-obj-code
           and buf_rvs-doc.shift-date   = v-shift-date
           and buf_rvs-doc.shift-num    = v-shift-num
           and buf_rvs-doc.status_      = 'факт':U
           and buf_rvs-doc.rvs-type     = 'смена':U
    use-index shift
    no-error.
    if available buf_rvs-doc
    then do:
      for each buf_rvs-line no-lock
         where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
           and buf_rvs-line.obj-type = p-obj-type
           and buf_rvs-line.obj-code = p-obj-code
        on error undo, return error
        :
        find first buf_temp_stkShiftOpen
             where buf_temp_stkShiftOpen.gds-code = buf_rvs-line.gds-code
        no-error.
        if not available buf_temp_stkShiftOpen
        then do:
          create buf_temp_stkShiftOpen.
          assign
            buf_temp_stkShiftOpen.gds-code = buf_rvs-line.gds-code
          .
          find first buf_goods no-lock
               where buf_goods.gds-code = buf_rvs-line.gds-code
          no-error.
          if available buf_goods
          then do:
            assign
              buf_temp_stkShiftOpen.artic     = buf_goods.artic
              buf_temp_stkShiftOpen.prod-type = buf_goods.prod-type
              buf_temp_stkShiftOpen.prod-code = buf_goods.prod-code
              buf_temp_stkShiftOpen.gds-name  = buf_goods.gds-name
              buf_temp_stkShiftOpen.qnty      = 0.0
              buf_temp_stkShiftOpen.cli-qnty  = 0.0
            .
              buf_temp_stkShiftOpen.envd = no .
          end.
        end.
        assign
          buf_temp_stkShiftOpen.qnty     = buf_temp_stkShiftOpen.qnty + buf_rvs-line.state-measure-qnty
          buf_temp_stkShiftOpen.cli-qnty = buf_temp_stkShiftOpen.cli-qnty + buf_rvs-line.state-measure-cli-qnty
        .
        find first buf_temp_stkPlShiftOpen
             where buf_temp_stkPlShiftOpen.gds-code = buf_rvs-line.gds-code
               and buf_temp_stkPlShiftOpen.pl-code = buf_rvs-line.pl-code
        no-error.
        if not available buf_temp_stkPlShiftOpen
        then do:
          create buf_temp_stkPlShiftOpen.
          assign
            buf_temp_stkPlShiftOpen.gds-code = buf_rvs-line.gds-code
            buf_temp_stkPlShiftOpen.pl-code  = buf_rvs-line.pl-code
          .
          find first buf_goods no-lock
               where buf_goods.gds-code = buf_rvs-line.gds-code
          no-error.
          if available buf_goods
          then do:
            assign
              buf_temp_stkPlShiftOpen.qnty            = buf_rvs-line.state-measure-qnty
              buf_temp_stkPlShiftOpen.cli-qnty        = buf_rvs-line.state-measure-cli-qnty
              buf_temp_stkPlShiftOpen.state-density   = buf_rvs-line.state-density
              buf_temp_stkPlShiftOpen.system-qnty     = buf_rvs-line.system-qnty
              buf_temp_stkPlShiftOpen.systen-cli-qnty = buf_rvs-line.system-cli-qnty
              buf_temp_stkPlShiftOpen.temperature     = buf_rvs-line.state-temperature
              buf_temp_stkPlShiftOpen.level-petrol    = buf_rvs-line.state-level-petrol
              buf_temp_stkPlShiftOpen.level-total     = buf_rvs-line.state-level-total
              buf_temp_stkPlShiftOpen.level-water     = buf_rvs-line.state-level-water
              buf_temp_stkPlShiftOpen.state-add-quantity  = buf_rvs-line.state-add-qnty
            .
          end.
        end.
      end.
      for each buf_rvs-line-pump no-lock where
            buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
        and buf_rvs-line-pump.obj-type = p-obj-type
        and buf_rvs-line-pump.obj-code = p-obj-code
        break
        by buf_rvs-line-pump.pump-code
        by buf_rvs-line-pump.nozzle-code
        on error undo, return error:
        if first-of(buf_rvs-line-pump.nozzle-code) then do:
          find first buf_temp_stkTrkShiftOpen where
                     buf_temp_stkTrkShiftOpen.pump-code = buf_rvs-line-pump.pump-code
            and buf_temp_stkTrkShiftOpen.nozzle-code = buf_rvs-line-pump.nozzle-code
            and buf_temp_stkTRKShiftOpen.pl-code = buf_rvs-line-pump.pl-code no-error.
          if not available buf_temp_stkTrkShiftOpen then do:
            create buf_temp_stkTrkShiftOpen.
            assign
              buf_temp_stkTRKShiftOpen.pl-code      = buf_rvs-line-pump.pl-code
              buf_temp_stkTrkShiftOpen.pump-code    = buf_rvs-line-pump.pump-code
              buf_temp_stkTrkShiftOpen.nozzle-code  = buf_rvs-line-pump.nozzle-code
              buf_temp_stkTrkShiftOpen.gds-code     = buf_rvs-line-pump.gds-code
              buf_temp_stkTrkShiftOpen.state-mh-cnt = buf_rvs-line-pump.state-mh-cnt
            .
          end.
        end.
      end.
    end.
    for each buf_temp_stkShiftEnd
    :
      run wp-xmltagopen( input 2, input "stkShiftEnd", input "" ).
      run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                      ), input 0 ).
      run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                      ), input 0 ).
      run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"      ), input 0 ).
      run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                     ), input 0 ).
      run wp-xmltagput( input 3, "sseArtic"   , input string( buf_temp_stkShiftEnd.artic      ), input 0 ).
      run wp-xmltagput( input 3, "sseProdType", input string( buf_temp_stkShiftEnd.prod-type  ), input 0 ).
      run wp-xmltagput( input 3, "sseProdCode", input string( buf_temp_stkShiftEnd.prod-code  ), input 0 ).
      run wp-xmltagput( input 3, "sseGdsCode" , input string( buf_temp_stkShiftEnd.gds-code   ), input 0 ).
      run wp-xmltagput( input 3, "sseGdsName" , input string( buf_temp_stkShiftEnd.gds-name   ), input 0 ).
      run wp-xmltagput( input 3, "sseGdsENVD" , input string( buf_temp_stkShiftEnd.envd       ), input 3 ).
      run wp-xmltagput( input 3, "sseFactQnty", input string( buf_temp_stkShiftEnd.qnty       ), input 0 ).
      run wp-xmltagput( input 3, "sseCliFactQnty", input string( buf_temp_stkShiftEnd.cli-qnty       ), input 0 ).
      for each buf_temp_stkPlShiftEnd where buf_temp_stkPlShiftEnd.gds-code = buf_temp_stkShiftEnd.gds-code:
        for first buf_temp_stkPlShiftOpen where buf_temp_stkPlShiftOpen.gds-code = buf_temp_stkPlShiftEnd.gds-code
          and buf_temp_stkPlShiftOpen.pl-code = buf_temp_stkPlShiftEnd.pl-code :
          run wp-xmltagopen( input 3, input "stkPlShiftOpen", input "" ).
          run wp-xmltagput( input 4, "ssePlCode", input string( buf_temp_stkPlShiftOpen.pl-code       ), input 0 ).
          run wp-xmltagput( input 4, "ssePlFactQnty", input string( buf_temp_stkPlShiftOpen.qnty       ), input 0 ).
          run wp-xmltagput( input 4, "ssePlCliFactQnty", input string( buf_temp_stkPlShiftOpen.cli-qnty       ), input 0 ).
          run wp-xmltagput( input 4, "ssePlDensity", input string( buf_temp_stkPlShiftOpen.state-density), input 0 ).
          run wp-xmltagput( input 4, "ssePlTemperature", input string( buf_temp_stkPlShiftOpen.temperature), input 0 ).
          run wp-xmltagput( input 4, "ssePlLevelPetrol", input string( buf_temp_stkPlShiftOpen.level-petrol), input 0 ).
          run wp-xmltagput( input 4, "ssePlLevelTotal", input string( buf_temp_stkPlShiftOpen.level-total), input 0 ).
          run wp-xmltagput( input 4, "ssePlLevelWater", input string( buf_temp_stkPlShiftOpen.level-water), input 0 ).
          run wp-xmltagput( input 4, "ssePlAddQuantity", input string( buf_temp_stkPlShiftOpen.state-add-quantity), input 0 ).
          run wp-xmltagput( input 4, "ssePlSysQnty", input string( buf_temp_stkPlShiftOpen.system-qnty), input 0 ).
          run wp-xmltagput( input 4, "ssePlSysWeight", input string( buf_temp_stkPlShiftOpen.systen-cli-qnty), input 0 ).
          run wp-xmltagclose( input 3, input "stkPlShiftOpen").
        end.
        run wp-xmltagopen( input 3, input "stkPlShiftEnd", input "" ).
        run wp-xmltagput( input 4, "ssePlCode", input string( buf_temp_stkPlShiftEnd.pl-code       ), input 0 ).
        run wp-xmltagput( input 4, "ssePlFactQnty", input string( buf_temp_stkPlShiftEnd.qnty       ), input 0 ).
        run wp-xmltagput( input 4, "ssePlCliFactQnty", input string( buf_temp_stkPlShiftEnd.cli-qnty       ), input 0 ).
        run wp-xmltagput( input 4, "ssePlDensity", input string( buf_temp_stkPlShiftEnd.state-density), input 0 ).
        run wp-xmltagput( input 4, "ssePlTemperature", input string(  buf_temp_stkPlShiftEnd.temperature), input 0 ).
        run wp-xmltagput( input 4, "ssePlLevelPetrol", input string(  buf_temp_stkPlShiftEnd.level-petrol), input 0 ).
        run wp-xmltagput( input 4, "ssePlLevelTotal", input string(  buf_temp_stkPlShiftEnd.level-total), input 0 ).
        run wp-xmltagput( input 4, "ssePlLevelWater", input string(  buf_temp_stkPlShiftEnd.level-water), input 0 ).
        run wp-xmltagput( input 4, "ssePlAddQuantity", input string( buf_temp_stkPlShiftEnd.state-add-quantity), input 0 ).
        run wp-xmltagput( input 4, "ssePlSysQnty", input string( buf_temp_stkPlShiftEnd.system-qnty), input 0 ).
        run wp-xmltagput( input 4, "ssePlSysWeight", input string( buf_temp_stkPlShiftEnd.systen-cli-qnty), input 0 ).
        run wp-xmltagclose( input 3, input "stkPlShiftEnd").
      end.
      for each buf_temp_stkTrkShiftEnd where buf_temp_stkTrkShiftEnd.gds-code = buf_temp_stkShiftEnd.gds-code:
        for first  buf_temp_stkTrkShiftOpen where buf_temp_stkTrkShiftOpen.gds-code = buf_temp_stkShiftEnd.gds-code
          and buf_temp_stkTRKShiftOpen.gds-code = buf_temp_stkTRKShiftEnd.gds-code
          and buf_temp_stkTRKShiftOpen.pl-code = buf_temp_stkTRKShiftEnd.pl-code
          and buf_temp_stkTRKShiftOpen.pump-code = buf_temp_stkTRKShiftEnd.pump-code
          and buf_temp_stkTRKShiftOpen.nozzle-code = buf_temp_stkTRKShiftEnd.nozzle-code :
          run wp-xmltagopen( input 3, input "stkTRKShiftOpen", input "" ).
          run wp-xmltagput( input 4, "sseTRKPlCode", input string( buf_temp_stkTRKShiftOpen.pl-code   ), input 0 ).
          run wp-xmltagput( input 4, "sseTRKPump", input string( buf_temp_stkTRKShiftOpen.pump-code   ), input 0 ).
          run wp-xmltagput( input 4, "sseTRKNozzle", input string( buf_temp_stkTRKShiftOpen.nozzle-code   ), input 0 ).
          run wp-xmltagput( input 4, "sseTRKCnt", input string( buf_temp_stkTRKShiftOpen.state-mh-cnt   ), input 0 ).
          run wp-xmltagclose( input 3, input "stkTRKShiftOpen").
        end.
        run wp-xmltagopen( input 3, input "stkTRKShiftEnd", input "" ).
        run wp-xmltagput( input 4, "sseTRKPlCode", input string( buf_temp_stkTRKShiftEnd.pl-code   ), input 0 ).
        run wp-xmltagput( input 4, "sseTRKPump", input string( buf_temp_stkTRKShiftEnd.pump-code   ), input 0 ).
        run wp-xmltagput( input 4, "sseTRKNozzle", input string( buf_temp_stkTRKShiftEnd.nozzle-code   ), input 0 ).
        run wp-xmltagput( input 4, "sseTRKCnt", input string( buf_temp_stkTRKShiftEnd.state-mh-cnt   ), input 0 ).
        run wp-xmltagclose( input 3, input "stkTRKShiftEnd").
      end.
      run wp-xmltagclose( input 2, input "stkShiftEnd").
    end.
  end.
end procedure.
procedure export-stkTNP :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
  define variable v-fact-order-from as decimal no-undo.
  define variable v-fact-order-to   as decimal no-undo.
  define variable v-docs-exists     as logical no-undo.
  define variable v-is-petrol       as logical no-undo.
  define variable v-is-pieces       as logical no-undo.
  define buffer buf_stk-line    for ub.stk-line.
  define buffer buf_ot-line     for ub.ot-line.
  define buffer buf_gds-obj     for ub.gds-obj.
  define buffer buf_goods       for ub.goods.
  define buffer buf_temp_stkTNP for temp_stkTNP.
  do
    for buf_stk-line
    , buf_ot-line
    , buf_gds-obj
    , buf_goods
    , buf_temp_stkTNP
    on error undo, return error
    :
    empty temp-table buf_temp_stkTNP.
    run rep/getfosht.p (
          input p-obj-type
        , input p-obj-code
        , input p-shift-date
        , input p-shift-num
        , output v-fact-order-from
        , output v-fact-order-to
        , output v-docs-exists
    ).
    goods-on-object:
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = p-obj-type
         and buf_gds-obj.obj-code = p-obj-code
      on error undo, return error
      :
      if buf_gds-obj.first-doc > p-shift-date
      then do:
        undo goods-on-object, next goods-on-object.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_gds-obj.artic
  ,  input buf_gds-obj.prod-type
  ,  input buf_gds-obj.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
      if v-is-petrol  = yes
      and v-is-pieces = no
      then do:
        undo goods-on-object, next goods-on-object.
      end.
      find last buf_stk-line no-lock
          where buf_stk-line.obj-type   = p-obj-type
            and buf_stk-line.obj-code   = p-obj-code
            and buf_stk-line.artic      = buf_gds-obj.artic
            and buf_stk-line.prod-type  = buf_gds-obj.prod-type
            and buf_stk-line.prod-code  = buf_gds-obj.prod-code
            and buf_stk-line.fact-order <= v-fact-order-to
            and buf_stk-line.sum-type   = 'crsa':U
      no-error.
      if available buf_stk-line
      then do:
        find first buf_temp_stkTNP
             where buf_temp_stkTNP.artic     = buf_gds-obj.artic
               and buf_temp_stkTNP.prod-type = buf_gds-obj.prod-type
               and buf_temp_stkTNP.prod-code = buf_gds-obj.prod-code
        no-error.
        if not available buf_temp_stkTNP
        then do:
          create buf_temp_stkTNP.
          assign
            buf_temp_stkTNP.artic     = buf_gds-obj.artic
            buf_temp_stkTNP.prod-type = buf_gds-obj.prod-type
            buf_temp_stkTNP.prod-code = buf_gds-obj.prod-code
          .
        end.
        find first buf_goods no-lock
             where buf_goods.artic     = buf_temp_stkTNP.artic
               and buf_goods.prod-type = buf_temp_stkTNP.prod-type
               and buf_goods.prod-code = buf_temp_stkTNP.prod-code
        no-error.
        if available buf_goods
        then do:
          assign
            buf_temp_stkTNP.gds-code = buf_goods.gds-code
            buf_temp_stkTNP.gds-name = buf_goods.gds-name
          .
            buf_temp_stkTNP.envd = no .
        end.
        assign
          buf_temp_stkTNP.end-sumSale = buf_stk-line.sum-rubl
          buf_temp_stkTNP.end-sumVat  = buf_stk-line.VAT-rubl
          buf_temp_stkTNP.end-qnty    = buf_stk-line.fact-qnty
        .
      end.
    end.
    for each buf_temp_stkTNP
    :
      assign
        buf_temp_stkTNP.start-sumSale = buf_temp_stkTNP.end-sumSale
        buf_temp_stkTNP.start-sumVat  = buf_temp_stkTNP.end-sumVat
      .
      for each buf_ot-line no-lock
         where buf_ot-line.obj-type  = p-obj-type
           and buf_ot-line.obj-code  = p-obj-code
           and buf_ot-line.artic     = buf_temp_stkTNP.artic
           and buf_ot-line.prod-type = buf_temp_stkTNP.prod-type
           and buf_ot-line.prod-code = buf_temp_stkTNP.prod-code
           and buf_ot-line.fact-order >= v-fact-order-from
           and buf_ot-line.fact-order <= v-fact-order-to
        on error undo, return error
        :
        if buf_ot-line.sum-type  = 'crsa':U
        or buf_ot-line.sum-type  = 'cgsr':U
        then do:
          assign
            buf_temp_stkTNP.start-sumSale = buf_temp_stkTNP.start-sumSale - buf_ot-line.sum-rubl
            buf_temp_stkTNP.start-sumVat  = buf_temp_stkTNP.start-sumVat  - buf_ot-line.VAT-rubl
          .
        end.
      end.
    end.
    for each buf_temp_stkTNP
    :
      if buf_temp_stkTNP.start-sumSale    <> 0
      or buf_temp_stkTNP.start-sumVat     <> 0
      or buf_temp_stkTNP.end-sumSale      <> 0
      or buf_temp_stkTNP.end-sumVat       <> 0
      then do:
        run wp-xmltagopen( input 2, input "stkTNP", input "" ).
        run wp-xmltagput( input 3, "objType"        , input string( p-obj-type                      ), input 0 ).
        run wp-xmltagput( input 3, "objCode"        , input string( p-obj-code                      ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"      ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                     ), input 0 ).
        run wp-xmltagput( input 3, "stnArtic"       , input string( buf_temp_stkTNP.artic           ), input 0 ).
        run wp-xmltagput( input 3, "stnProdType"    , input string( buf_temp_stkTNP.prod-type       ), input 0 ).
        run wp-xmltagput( input 3, "stnProdCode"    , input string( buf_temp_stkTNP.prod-code       ), input 0 ).
        run wp-xmltagput( input 3, "stnGdsCode"     , input string( buf_temp_stkTNP.gds-code        ), input 0 ).
        run wp-xmltagput( input 3, "stnGdsName"     , input string( buf_temp_stkTNP.gds-name        ), input 0 ).
        run wp-xmltagput( input 3, "stnGdsENVD"     , input string( buf_temp_stkTNP.envd            ), input 3 ).
        run wp-xmltagput( input 3, "stnStartSumSale", input string( buf_temp_stkTNP.start-sumSale   ), input 0 ).
        run wp-xmltagput( input 3, "stnStartSumVat" , input string( buf_temp_stkTNP.start-sumVat    ), input 0 ).
        run wp-xmltagput( input 3, "stnEndSumSale"  , input string( buf_temp_stkTNP.end-sumSale     ), input 0 ).
        run wp-xmltagput( input 3, "stnEndSumVat"   , input string( buf_temp_stkTNP.end-sumVat      ), input 0 ).
        run wp-xmltagput( input 3, "stnEndQnty"     , input string( buf_temp_stkTNP.end-qnty        ), input 0 ).
        run wp-xmltagclose( input 3, input "stkTNP").
      end.
    end.
  end.
end procedure.
procedure export-invTRK :
  define input parameter p-obj-type   as character        no-undo.
  define input parameter p-obj-code   as integer          no-undo.
  define input parameter p-shift-date as date             no-undo.
  define input parameter p-shift-num  as integer          no-undo.
  define buffer buf_icnt-doc  for ub.icnt-doc .
  define buffer buf_icnt-line for ub.icnt-line .
  for each buf_icnt-doc no-lock where buf_icnt-doc.obj-type = p-obj-type
    and buf_icnt-doc.obj-code = p-obj-code
    and buf_icnt-doc.shift-date = p-shift-date
    and buf_icnt-doc.shift-num = p-shift-num
    :
    run wp-xmltagopen( input 2, input "invTRK", input "" ).
    run wp-xmltagput( input 3, "DocCode"        , input string( buf_icnt-doc.doc-code                      ), input 0 ).
    run wp-xmltagput( input 3, "DocDate"        , input string( buf_icnt-doc.doc-date                      ), input 0 ).
    run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"      ), input 0 ).
    run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                     ), input 0 ).
    for each buf_icnt-line no-lock where buf_icnt-line.doc-code = buf_icnt-doc.doc-code:
      run wp-xmltagopen( input 3, input "indTRK", input "" ).
      run wp-xmltagput( input 4, "GdsCode"      , input string( buf_icnt-line.gds-code           ), input 0 ).
      run wp-xmltagput( input 4, "TrkNum"       , input string( buf_icnt-line.pump-code          ), input 0 ).
      run wp-xmltagput( input 4, "TrkNozzle"    , input string( buf_icnt-line.nozzle-code        ), input 0 ).
      run wp-xmltagput( input 4, "IndEl"        , input string( buf_icnt-line.state-el-cnt       ), input 0 ).
      run wp-xmltagput( input 4, "IndMeh"       , input string( buf_icnt-line.state-mh-cnt       ), input 0 ).
      run wp-xmltagput( input 4, "DIF"          , input string( buf_icnt-line.state-el-cnt - buf_icnt-line.state-mh-cnt   ), input 0 ).
      run wp-xmltagput( input 4, "IndAuto"      , input string( buf_icnt-line.meas-el-cnt    ), input 0 ).
      run wp-xmltagclose( input 3, input "indTRK").
    end.
    run wp-xmltagclose( input 2, input "invTRK").
  end.
end procedure.
procedure export-price-sum :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
  define variable v-fact-order-from as decimal no-undo.
  define variable v-fact-order-to   as decimal no-undo.
  define variable v-docs-exists     as logical no-undo.
  define variable v-is-petrol       as logical no-undo.
  define variable v-is-pieces       as logical no-undo.
  define buffer buf_ot-line           for ub.ot-line.
  define buffer buf_gds-obj           for ub.gds-obj.
  define buffer buf_goods             for ub.goods.
  define buffer buf_temp_sumPriceSale for temp_sumPriceSale.
  do
    for buf_ot-line
    , buf_gds-obj
    , buf_goods
    , buf_temp_sumPriceSale
    on error undo, return error
    :
    empty temp-table buf_temp_sumPriceSale.
    run rep/getfosht.p (
          input p-obj-type
        , input p-obj-code
        , input p-shift-date
        , input p-shift-num
        , output v-fact-order-from
        , output v-fact-order-to
        , output v-docs-exists
    ).
    goods-on-object:
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = p-obj-type
         and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error
    :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_gds-obj.artic
  ,  input buf_gds-obj.prod-type
  ,  input buf_gds-obj.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
      if v-is-petrol  = yes
      and v-is-pieces = no
      then do:
        undo goods-on-object, next goods-on-object.
      end.
      if buf_gds-obj.first-doc > p-shift-date
      then do:
        undo goods-on-object, next goods-on-object.
      end.
      for each buf_ot-line no-lock
         where buf_ot-line.obj-type  = p-obj-type
           and buf_ot-line.obj-code  = p-obj-code
           and buf_ot-line.artic     = buf_gds-obj.artic
           and buf_ot-line.prod-type = buf_gds-obj.prod-type
           and buf_ot-line.prod-code = buf_gds-obj.prod-code
           and buf_ot-line.fact-order >= v-fact-order-from
           and buf_ot-line.fact-order <= v-fact-order-to
        on error undo, return error
        :
        if buf_ot-line.ext-doc-type  = 'ot':U
        then do:
          find first buf_temp_sumPriceSale
               where buf_temp_sumPriceSale.artic     = buf_ot-line.artic
                 and buf_temp_sumPriceSale.prod-type = buf_ot-line.prod-type
                 and buf_temp_sumPriceSale.prod-code = buf_ot-line.prod-code
          no-error.
          if not available buf_temp_sumPriceSale
          then do:
            create buf_temp_sumPriceSale.
            assign
              buf_temp_sumPriceSale.artic     = buf_ot-line.artic
              buf_temp_sumPriceSale.prod-type = buf_ot-line.prod-type
              buf_temp_sumPriceSale.prod-code = buf_ot-line.prod-code
            .
            find first buf_goods no-lock
                 where buf_goods.artic     = buf_ot-line.artic
                   and buf_goods.prod-type = buf_ot-line.prod-type
                   and buf_goods.prod-code = buf_ot-line.prod-code
            no-error.
            if available buf_goods
            then do:
              assign
                buf_temp_sumPriceSale.gds-code = buf_goods.gds-code
                buf_temp_sumPriceSale.gds-name = buf_goods.gds-name
              .
                buf_temp_sumPriceSale.envd = no .
            end.
          end.
          assign
            buf_temp_sumPriceSale.sumSale = buf_temp_sumPriceSale.sumSale + buf_ot-line.sum-rubl
            buf_temp_sumPriceSale.sumVat  = buf_temp_sumPriceSale.sumSale + buf_ot-line.VAT-rubl
          .
        end.
      end.
    end.
    for each buf_temp_sumPriceSale
    :
      if buf_temp_sumPriceSale.sumSale    <> 0
      or buf_temp_sumPriceSale.sumVat     <> 0
      then do:
        run wp-xmltagopen( input 2, input "sumPriceSale", input "" ).
        run wp-xmltagput( input 3, "objType"        , input string( p-obj-type                      ), input 0 ).
        run wp-xmltagput( input 3, "objCode"        , input string( p-obj-code                      ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"      ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                     ), input 0 ).
        run wp-xmltagput( input 3, "spsArtic"       , input string( buf_temp_sumPriceSale.artic     ), input 0 ).
        run wp-xmltagput( input 3, "spsProdType"    , input string( buf_temp_sumPriceSale.prod-type ), input 0 ).
        run wp-xmltagput( input 3, "spsProdCode"    , input string( buf_temp_sumPriceSale.prod-code ), input 0 ).
        run wp-xmltagput( input 3, "spsGdsCode"     , input string( buf_temp_sumPriceSale.gds-code  ), input 0 ).
        run wp-xmltagput( input 3, "spsGdsName"     , input string( buf_temp_sumPriceSale.gds-name  ), input 0 ).
        run wp-xmltagput( input 3, "spsGdsENVD"     , input string( buf_temp_sumPriceSale.envd      ), input 3 ).
        run wp-xmltagput( input 3, "spsSumSale"     , input string( buf_temp_sumPriceSale.sumSale   ), input 0 ).
        run wp-xmltagput( input 3, "spsSumVat"      , input string( buf_temp_sumPriceSale.sumVat    ), input 0 ).
        run wp-xmltagclose( input 3, input "sumPriceSale").
      end.
    end.
  end.
end procedure.
procedure export-stk-den :
  define input parameter p-host-code  as character        no-undo .
  define input parameter p-obj-type   as character        no-undo .
  define input parameter p-obj-code   as integer          no-undo .
  define input parameter p-shift-date as date             no-undo .
  define input parameter p-shift-num  as integer          no-undo .
  define variable v-ost-begin  as decimal no-undo .
  define variable v-ost-end    as decimal no-undo .
  define variable Fact-order-1 like ub.stk-tot.Fact-order no-undo .
  define variable Fact-order-2 like ub.stk-tot.Fact-order no-undo .
  run create_obj-list in this-procedure (p-obj-type, p-obj-code).
  run fostatok in this-procedure (
    input   p-host-code
    ,input   p-obj-code
    ,input   p-obj-type
    ,input   true
    ,input   p-shift-date - 1
    ,input   date('')
    ,input   p-shift-num
    ,input   p-shift-num
    ,input   yes
    ,input   0
    ,input   0
    ,output  v-ost-begin
    ,output  Fact-order-1
    ) no-error .
  run fostatok in this-procedure (
    input   p-host-code
    ,input   p-obj-code
    ,input   p-obj-type
    ,input   true
    ,input   p-shift-date
    ,input   p-shift-date
    ,input   p-shift-num
    ,input   p-shift-num
    ,input   yes
    ,input   0
    ,input   0
    ,output  v-ost-end
    ,output  Fact-order-2
    ) no-error .
  run wp-xmltagopen ( input 2, input "stkDen", input "" ).
  run wp-xmltagput( input 3, "objType"        , input string( p-obj-type                            ), input 0 ).
  run wp-xmltagput( input 3, "objCode"        , input string( p-obj-code                            ), input 0 ).
  run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"            ), input 0 ).
  run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                           ), input 0 ).
  run wp-xmltagput( input 3, "ostBegin"       , input string( v-ost-begin                           ), input 0 ).
  run wp-xmltagput( input 3, "ostEnd"         , input string( v-ost-end                             ), input 0 ).
  run wp-xmltagclose( input 2, input "stkDen").
end procedure.
