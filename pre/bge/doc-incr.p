block-level on error undo, throw.
define input parameter p-host-code       as character               no-undo.
define input parameter p-cur-date        as date                    no-undo.
define input parameter p-start-date      as date                    no-undo.
define input parameter p-obj-type        as character               no-undo.
define input parameter p-obj-code        as integer                 no-undo.
define input parameter p-pay-code        as logical                 no-undo.
define input parameter p-cst             as logical                 no-undo.
define input parameter p-parts           as logical                 no-undo.
define input parameter p-chk-pay-code    as logical                 no-undo.
define input parameter p-pay-desk        as logical                 no-undo.
define input parameter p-pay-desk-cards  as logical                 no-undo.
define input parameter p-need-chk        as logical                 no-undo.
define input parameter p-need-doc-rvs    as logical                 no-undo.
define input parameter sOutFile          as character               no-undo.
define input parameter sLogFile          as character               no-undo.
define input parameter p-parent-proc     as handle                  no-undo.
define input parameter hEDT              as handle                  no-undo.
define input parameter hCNT              as handle                  no-undo.
define input parameter p-doc-type        as character               no-undo.
define input parameter p-doc-code        as character               no-undo.
define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2021/11/22 16:49:10 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-incr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/doc-incr.p $":U .
define variable vss-description as character no-undo init "Экспорт документов по архивам".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-parts-cst-code  like ub.parts.cst-code     no-undo.
define variable v-exists-sale_ot-supp-tot   as logical      no-undo.
define variable v-is-petrol                 as logical      no-undo.
define variable v-is-pieces                 as logical      no-undo.
define variable v-petrol-weight             as decimal      no-undo.
define variable v-petrol-density            as decimal      no-undo.
define variable v-weight-not-specified      as logical      no-undo.
define variable v-host-code                 as integer       no-undo.
define variable v-base-code                 as integer       no-undo.
define variable v-base-code-okv             as integer       no-undo.
define variable v-is-out                    as integer       no-undo.
define variable v-inkas-pay-desk-type like ub.inkas-pay-desk.doc-type no-undo.
define variable v-found-paycode     as logical      no-undo.
define variable v-found-paycard     as logical      no-undo.
define variable v-supp-type     as character      no-undo.
define variable v-supp-code     as integer        no-undo.
define variable v-in-code       as character      no-undo.
define variable v-cst-code      as character      no-undo.
define temp-table temp_inkas-pay no-undo
    field pay-code  like ub.inkas-pay.pay-code
    field tot-base  like ub.inkas-pay.tot-base
    field tot-rubl  like ub.inkas-pay.tot-rubl
    field tot-sum   like ub.inkas-pay.tot-sum
index pi is primary unique pay-code
.
define temp-table temp_cost_cat-id_ot-supp-tot  no-undo
    field cat-id as character
    index pi is primary unique cat-id
.
define temp-table temp_cost_cli_ot-supp-tot     no-undo
    field cat-id            as character
    field cli-type          as character
    field cli-code          as integer
    field sum-rubl          as decimal
    field vat-rubl          as decimal
    field slt-rubl          as decimal
    field road-tax-rubl     as decimal
    field transport-rubl    as decimal
    field other-rubl        as decimal
    field excise-rubl       as decimal
    field sum-base          as decimal
    field vat-base          as decimal
    field slt-base          as decimal
    field road-tax-base     as decimal
    field transport-base    as decimal
    field other-base        as decimal
    field excise-base       as decimal
    field fact-qnty         as decimal
    index pi is primary unique cat-id cli-type cli-code
.
define temp-table temp_cost_cat-id_ot-supp-line no-undo
    field artic     as character
    field prod-type as character
    field prod-code as integer
    field cat-id    as character
    index pi is primary unique artic prod-type prod-code cat-id
.
define temp-table temp_cost_cli_ot-supp-line    no-undo
    field artic             as character
    field prod-type         as character
    field prod-code         as integer
    field cat-id            as character
    field cli-type          as character
    field cli-code          as integer
    field sum-rubl          as decimal
    field vat-rubl          as decimal
    field slt-rubl          as decimal
    field road-tax-rubl     as decimal
    field transport-rubl    as decimal
    field other-rubl        as decimal
    field excise-rubl       as decimal
    field sum-base          as decimal
    field vat-base          as decimal
    field slt-base          as decimal
    field road-tax-base     as decimal
    field transport-base    as decimal
    field other-base        as decimal
    field excise-base       as decimal
    field fact-qnty         as decimal
    index pi is primary unique artic prod-type prod-code cat-id cli-type cli-code
.
define temp-table tt-docs no-undo
  field fact-order  as decimal
  field doc-code    as character
  field doc-type    as character
index pi is primary unique
  fact-order
  doc-code
  doc-type
index doc
  doc-code
  doc-type
.
define buffer buf_goods for ub.goods.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cp-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-range          as integer   no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'grp-code':U then do:     assign     p-label = "Группа платежа"     p-type = 'C':U      p-format = "X(45)"     p-label = "Группа платежа"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=grp-code':u      .   end.
            when 'is-use':U then do:     assign     p-label = "Используется"     p-type = 'C':U      p-format = "X(255)"     p-label = "Используется"     p-range = 4     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=is-use':u      .   end.
            when 'dop-doc':U then do:     assign     p-label = "Дополнительный документ"     p-type = 'C':U      p-format = "X(255)"     p-label = "Дополнительный документ"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=dop-doc':u      .   end.
            when 'paycard-all-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'form_km3':U then do:     assign     p-label = "Формировать КМ-3 по чекам возврата"     p-type = 'L':U      p-format = "+/-"     p-label = "Формировать КМ-3 по чекам возврата"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'bal_malina':U then do:     assign     p-label = "Оплата баллами Малина"     p-type = 'L':U      p-format = "+/-"     p-label = "Оплата баллами Малина"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'max_proc_sum':U then do:     assign     p-label = "Максимальный % порог от суммы"     p-type = 'D':U      p-format = ">>9.99"     p-label = "Максимальный % порог от суммы"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'mask_card_kup':U then do:     assign     p-label = "Маска карты\купона"     p-type = 'C':U      p-format = "x(129)"     p-label = "Маска карты\купона"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure cp-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для выгрузки в XML)"     p-label = "Префиксы платежных карт (для выгрузки в XML)" .   end.
            when 'grp-code':U then do:     assign     p-tooltip = "Группа платежа"     p-label = "Группа платежа" .   end.
            when 'is-use':U then do:     assign     p-tooltip = "Используется"     p-label = "Используется" .   end.
            when 'dop-doc':U then do:     assign     p-tooltip = "Дополнительный документ"     p-label = "Дополнительный документ" .   end.
            when 'paycard-all-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)" .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт, разрешенных для редактировани"     p-label = "Префиксы платежных карт, разрешенных для редактирования" .   end.
            when 'form_km3':U then do:     assign     p-tooltip = "Формировать КМ-3 по чекам возврата"     p-label = "Формировать КМ-3 по чекам возврата" .   end.
            when 'bal_malina':U then do:     assign     p-tooltip = "Оплата баллами Малина"     p-label = "Оплата баллами Малина" .   end.
            when 'max_proc_sum':U then do:     assign     p-tooltip = "Максимальный % порог от суммы"     p-label = "Максимальный % порог от суммы" .   end.
            when 'mask_card_kup':U then do:     assign     p-tooltip = "Маска карты\купона"     p-label = "Маска карты\купона" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure cp-attr-value :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input  parameter p-code        like ub.cash-pay-attr.attr-code      no-undo .
    define output parameter p-value       like ub.cash-pay-attr.attr-value    no-undo .
    define output parameter p-type        as character no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr no-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code  = p-code
      no-error .
    if avail buf_cash-pay-attr then do:
      assign
        p-value =  buf_cash-pay-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure cp-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define input parameter p-value    like ub.cash-pay-attr.attr-value no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define buffer last_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if not available buf_cash-pay-attr then do:
      create buf_cash-pay-attr .
      assign
      buf_cash-pay-attr.cdpay-code = p-cdpay-code
      buf_cash-pay-attr.curr-code  = p-curr-code
      buf_cash-pay-attr.host-code  = p-host-code
      buf_cash-pay-attr.obj-type   = p-obj-type
      buf_cash-pay-attr.obj-code   = p-obj-code
      buf_cash-pay-attr.attr-code = p-code
      .
    end.
    assign
      buf_cash-pay-attr.attr-value = p-value
    .
    release buf_cash-pay-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cp-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if  available buf_cash-pay-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure cp-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_cash-pay-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-pay-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure cp-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-news = true.   end.
            when 'grp-code':U then do:     assign     p-news = true.   end.
            when 'is-use':U then do:     assign     p-news = true.   end.
            when 'dop-doc':U then do:     assign     p-news = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-news = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-news = true.   end.
            when 'form_km3':U then do:     assign     p-news = false.   end.
            when 'bal_malina':U then do:     assign     p-news = false.   end.
            when 'max_proc_sum':U then do:     assign     p-news = true.   end.
            when 'mask_card_kup':U then do:     assign     p-news = true.   end.
      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.
procedure cp-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-hist = true.   end.
            when 'form_km3':U then do:     assign     p-hist = true.   end.
            when 'bal_malina':U then do:     assign     p-hist = true.   end.
            when 'max_proc_sum':U then do:     assign     p-hist = true.   end.
            when 'mask_card_kup':U then do:     assign     p-hist = true.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-cpa-pcep no-undo
field cdpay-code like ub.cash-pay.cdpay-code
field curr-code like ub.cash-pay.cdpay-code
field prefix as character
index pi is primary
cdpay-code
curr-code
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cpapcep:
define variable ii as integer no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_temp-cpa-pcep for temp-cpa-pcep.
  do
  on error undo, return error
  :
     for each buf_cash-pay-attr no-lock where
            buf_Cash-pay-attr.attr-code = 'paycard-export-prefix':U:
       do ii = 1 to num-entries(buf_Cash-pay-attr.attr-value):
        create buf_temp-cpa-pcep.
        assign
        buf_temp-cpa-pcep.cdpay-code = buf_cash-pay-attr.cdpay-code
        buf_temp-cpa-pcep.curr-code = buf_cash-pay-attr.curr-code
        buf_temp-cpa-pcep.prefix = entry(ii, buf_Cash-pay-attr.attr-value)
        .
      end.
    end.
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS
  unique
  primary
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
        gds-code
        pay-desk
        cpay-code
        curr-code
        prefix
        is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-4 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do
on error undo, return error return-value
:
if not valid-handle( p-parent-proc )
then do:
    return.
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
run get-base-code-okv in this-procedure (
      input v-base-code
    , output v-base-code-okv
).
run cpapcep in this-procedure .
run bge-xml-read-config in this-procedure ( input ?
                                          , input ?
                                          ).
if v-bge-xml-bgeflold <> "oracle":u
then do:
  OUTPUT STREAM stmXMLOut TO VALUE( sOutFile + "xm1" ) CONVERT TARGET "1251" APPEND.
end.
RUN wp-XMLWriteCNT( hCNT, "" ).
run export-documents in this-procedure .
if v-bge-xml-bgeflold <> "oracle":u
then do:
  output stream stmxmlout close.
end.
end.
procedure export-documents :
do
on error undo, return error return-value
:
    define variable v-ext-doc-type      as character    no-undo.
    define variable v-doc-code          as character    no-undo.
    define variable v-doc-date          as date         no-undo.
    define variable v-fact-date         as date         no-undo.
    define variable v-reason-code       as integer      no-undo.
    define variable v-doc-PS            as character    no-undo.
    define variable v-firm-code         as character    no-undo.
    define variable v-ord-num           as character    no-undo.
    define variable v-ship-num          as character    no-undo.
    define variable v-ship-date         as date         no-undo.
    define variable v-pay-code          as integer      no-undo.
    define variable v-out-code          as character    no-undo.
    define variable v-fact-order        as decimal      no-undo.
    define variable v-sys-date          as date         no-undo.
    define variable v-sys-time          as character    no-undo.
    define variable v-supp-dog-code     as character    no-undo.
    define variable v-supp-ndog         as character    no-undo.
    define variable v-supp-ddog         as character    no-undo.
    define variable v-exp-ora-filename  as character    no-undo.
    define variable v-ora-exp-seq-num   as integer      no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-error-message     as character    no-undo.
    define variable v-stop-fo           as decimal      no-undo.
    define variable v-is-envd_              as logical      no-undo.
    define variable vartype                 as character    no-undo.
    define variable varenvd                 as character    no-undo.
    define variable v-pr-doc-type           as logical      no-undo.
    define variable v-sum-all-parts         as decimal      no-undo.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_c-trn-doc     for ub.c-trn-doc.
    define buffer buf_price-doc     for ub.price-doc.
    define buffer buf_contract      for ub.contract.
    define buffer buf_ord-doc       for ub.ord-doc.
    define buffer buf_tt-docs       for tt-docs.
    define buffer buf_ot-tot        for ub.ot-tot.
    define buffer buf_doc-pl        for ub.doc-pl.
    if v-bge-xml-bgeflold = "oracle":u
    then do:
      assign
        v-obj-list = substitute( "&1,&2" , p-obj-type , p-obj-code )
      .
    end.
    for each temp_cost_cat-id_ot-supp-tot no-lock
    on error undo, return error
    :
        delete temp_cost_cat-id_ot-supp-tot.
    end.
    for each temp_cost_cli_ot-supp-tot no-lock
    on error undo, return error
    :
        delete temp_cost_cli_ot-supp-tot.
    end.
    for each temp_cost_cat-id_ot-supp-line no-lock
    on error undo, return error
    :
        delete temp_cost_cat-id_ot-supp-line.
    end.
    for each temp_cost_cli_ot-supp-line no-lock
    on error undo, return error
    :
        delete temp_cost_cli_ot-supp-line.
    end.
    if v-bge-xml-bgeflold = "oracle":u and
       p-doc-type <> ?                 and
       p-doc-code <> ?
    then do:
      case p-doc-type :
        when 'price-doc':U
        then do:
          find first buf_price-doc no-lock
            where buf_price-doc.doc-num = p-doc-code
          no-error .
          if available buf_price-doc
          then do:
            output stream stmxmlout close.
            run bge-xml-ora-exp-filename in this-procedure ( input 'price-doc':U
                                                           , input buf_price-doc.doc-num
                                                           , input p-obj-code
                                                           , output v-exp-ora-filename
                                                           , output v-ora-exp-seq-num
                                                           ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка экспорта документа переоценки. Номер документа: &1. &2. &3 &4 "
                                                                        , buf_price-doc.doc-num
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              undo, return error return-value .
            end.
            run bge-xml-write-header in this-procedure (
                  input v-exp-ora-filename
                , input v-exp-ora-filename + "xml"
                , input "15.0 " + replace( vss-revision + vss-date, "$", " " )
                , input 0
                , input v-date-from
                , input 0
                , input v-date-to
                , input 0
                , input v-obj-list
                , input ""
                , input p-pay-code
                , input p-cst
                , input p-parts
                , input p-chk-pay-code
                , input p-pay-desk
                , input p-pay-desk-cards
                , input no
                , input no
            ).
            OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка документа &1 в пакет &2."
                                                                    , buf_price-doc.doc-num
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
            assign
                v-doc-code     = buf_price-doc.doc-num
                v-doc-date     = buf_price-doc.doc-date
                v-fact-date    = buf_price-doc.fact-date
                v-reason-code  = 0
                v-doc-ps       = buf_price-doc.ps
                v-fact-order   = buf_price-doc.fact-order
                v-sys-date     = buf_price-doc.sys-date
                v-sys-time     = buf_price-doc.sys-time
            .
            run export-from-archive (
                  input 'ot':U
                , input v-doc-code
                , input v-doc-date
                , input v-fact-date
                , input v-reason-code
                , input v-doc-ps
                , input v-fact-order
                , input v-sys-date
                , input v-sys-time
                , input ""
                , input ""
                , input ""
                , input ?
                , input 0
                , input ""
                , input ""
                , input ""
                , input 0
                , input ""
                , input ""
                , input ""
                , input ""
                , input ?
                , input ?
                , input ?
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                      input sLogFile
                    , input 1
                    , input substitute( "Ошибка экспорта документа переоценки. Номер документа: &1. &2. &3 &4 "
                                        , v-doc-code
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                      )
                ).
                undo, return error return-value .
            end.
            output stream stmxmlout close.
            run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
            run bge/setbgedt.p ( input 'price-doc':U
                               , input v-doc-code
                               , input p-cur-date
                               ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                        , v-doc-code
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                return error .
              end.
            end.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                                    , buf_price-doc.doc-num
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
          end.
        end.
        when 'c-trn-doc':U
        then do:
          export-deleted-documents:
          for each buf_c-trn-doc no-lock
            where buf_c-trn-doc.obj-type = p-obj-type
              and buf_c-trn-doc.obj-code = p-obj-code
              and buf_c-trn-doc.is-del   = yes
              and buf_c-trn-doc.doc-code = p-doc-code
          on error undo, return error return-value
          :
              if buf_c-trn-doc.bge-date = ?
              then do:
                output stream stmxmlout close.
                run bge-xml-ora-exp-filename in this-procedure ( input 'c-trn-doc':U
                                                              , input buf_c-trn-doc.doc-code
                                                              , input p-obj-code
                                                              , output v-exp-ora-filename
                                                              , output v-ora-exp-seq-num
                                                              ) no-error .
                if error-status :error = yes
                then do:
                    run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                        , input 1
                                                        , input substitute( "Ошибка экспорта удаленного документа. Номер документа: &1. &2. &3 &4 "
                                                                          , buf_c-trn-doc.doc-code
                                                                          , return-value
                                                                          , trim(error-status :get-message(1))
                                                                          , trim(error-status :get-message(2))
                                                                          )
                                                        ).
                    undo export-deleted-documents, next export-deleted-documents.
                end.
                run bge-xml-write-header in this-procedure (
                      input v-exp-ora-filename
                    , input v-exp-ora-filename + "xml"
                    , input "15.0 " + replace( vss-revision + vss-date, "$", " " )
                    , input 0
                    , input v-date-from
                    , input 0
                    , input v-date-to
                    , input 0
                    , input v-obj-list
                    , input buf_c-trn-doc.ext-doc-type
                    , input p-pay-code
                    , input p-cst
                    , input p-parts
                    , input p-chk-pay-code
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input no
                    , input no
                ).
                OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                      , input 1
                                                      , input substitute( "Выгрузка удаленного документа &1 в пакет &2."
                                                                        , buf_c-trn-doc.doc-code
                                                                        , v-exp-ora-filename + "xml"
                                                                        )
                                                      ).
                assign
                    v-doc-code     = buf_c-trn-doc.doc-code
                .
                run export-deleted-docs in this-procedure (
                      input v-doc-code
                    , input buf_c-trn-doc.corr-user-db-num
                    , input buf_c-trn-doc.chip-num
                ) no-error.
                if error-status :error
                then do:
                    run wp-XMLWriteLog in this-procedure (
                          input sLogFile
                        , input 1
                        , input substitute( "Ошибка экспорта удаленного документа. Номер документа: &1. &2. &3 &4 "
                                            , v-doc-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                            , trim(error-status :get-message(2))
                                        )
                    ).
                    undo export-deleted-documents, next export-deleted-documents.
                end.
                output stream stmxmlout close.
                run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
                run bge/setbgedt.p ( input 'c-trn-doc':U
                                   , input buf_c-trn-doc.doc-code
                                   , input p-cur-date
                                   ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                       , input 1
                                                       , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                           , buf_c-trn-doc.doc-code
                                                                           , return-value
                                                                           , trim(error-status :get-message(1))
                                                                           , trim(error-status :get-message(2))
                                                                         )
                                                       ).
                  if v-bge-xml-bgeflold = "oracle":u
                  then do:
                    return error .
                  end.
                end.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                      , input 1
                                                      , input substitute( "Выгрузка удаленного документа &1 в пакет &2 завершена."
                                                                        , buf_c-trn-doc.doc-code
                                                                        , v-exp-ora-filename + "xml"
                                                                        )
                                                      ).
              end.
          end.
        end.
        when 'trn-doc':U
        then do:
          find first buf_trn-doc no-lock
            where buf_trn-doc.doc-code = p-doc-code
          no-error .
          if available buf_trn-doc
          then do:
            output stream stmxmlout close.
            run bge-xml-ora-exp-filename in this-procedure ( input 'trn-doc':U
                                                            , input buf_trn-doc.doc-code
                                                            , input p-obj-code
                                                            , output v-exp-ora-filename
                                                            , output v-ora-exp-seq-num
                                                            ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка экспорта документа. Номер документа: &1. &2. &3 &4 "
                                                                        , buf_trn-doc.doc-code
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              undo, return error return-value .
            end.
            run bge-xml-write-header in this-procedure (
                  input v-exp-ora-filename
                , input v-exp-ora-filename + "xml"
                , input "15.0 " + replace( vss-revision + vss-date, "$", " " )
                , input 0
                , input v-date-from
                , input 0
                , input v-date-to
                , input 0
                , input v-obj-list
                , input buf_trn-doc.ext-doc-type
                , input p-pay-code
                , input p-cst
                , input p-parts
                , input p-chk-pay-code
                , input p-pay-desk
                , input p-pay-desk-cards
                , input no
                , input no
            ).
            OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка документа &1 в пакет &2."
                                                                    , buf_trn-doc.doc-code
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
            assign
                v-supp-dog-code = "":U
                v-supp-ndog     = "":U
                v-supp-ddog     = "":U
            .
            run fill_bge-xml_clients in this-procedure (
                  input p-parent-proc
                , input buf_trn-doc.cli-type
                , input buf_trn-doc.cli-code
            ).
            assign
                v-ext-doc-type = buf_trn-doc.ext-doc-type
                v-doc-code     = buf_trn-doc.doc-code
                v-doc-date     = buf_trn-doc.doc-date
                v-fact-date    = buf_trn-doc.fact-date
                v-reason-code  = buf_trn-doc.reason-code
                v-doc-ps       = buf_trn-doc.ps
                v-fact-order   = buf_trn-doc.fact-order
                v-sys-date     = buf_trn-doc.sys-date
                v-sys-time     = buf_trn-doc.sys-time
                v-firm-code    = buf_trn-doc.cli-type + string( buf_trn-doc.cli-code )
                v-ord-num      = buf_trn-doc.ord-num
                v-ship-num     = buf_trn-doc.ship-num
                v-ship-date    = buf_trn-doc.ship-date
                v-pay-code     = buf_trn-doc.pay-code
                v-out-code     = buf_trn-doc.out-code
            .
            if v-ext-doc-type = 'ie':U
            or v-ext-doc-type = 'ap':U
            then  do:
                if buf_trn-doc.contract-code <> 0
                then do:
                    assign
                        v-supp-dog-code = string( buf_trn-doc.contract-code )
                    .
                    find first buf_contract no-lock
                        where buf_contract.host-code       = buf_trn-doc.host-code
                          and buf_contract.contract-code   = buf_trn-doc.contract-code
                    no-error.
                    if available buf_contract
                    then do:
                        assign
                            v-supp-ndog          = string( buf_contract.contract-prn-code )
                            v-supp-ddog          = string( buf_contract.contract-date, "99.99.9999" )
                        .
                    end.
                end.
            end.
            run export-from-archive (
                  input v-ext-doc-type
                , input v-doc-code
                , input v-doc-date
                , input v-fact-date
                , input v-reason-code
                , input v-doc-ps
                , input v-fact-order
                , input v-sys-date
                , input v-sys-time
                , input v-firm-code
                , input v-ord-num
                , input v-ship-num
                , input v-ship-date
                , input v-pay-code
                , input buf_trn-doc.hold-doc-code-child
                , input buf_trn-doc.hold-doc-code-parent
                , input buf_trn-doc.hold-obj-type
                , input buf_trn-doc.hold-obj-code
                , input v-out-code
                , input v-supp-dog-code
                , input v-supp-ndog
                , input v-supp-ddog
                , input buf_trn-doc.d-card
                , input buf_trn-doc.cli-type
                , input buf_trn-doc.cli-code
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                      input sLogFile
                    , input 1
                    , input substitute( "Ошибка экспорта складского документа. Номер документа: &1. &2. &3 &4 "
                                        , v-doc-code
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                      )
                ).
                undo, return error return-value.
            end.
            output stream stmxmlout close.
            run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
            run bge/setbgedt.p ( input 'trn-doc':U
                               , input buf_trn-doc.doc-code
                               , input p-cur-date
                               ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                        , buf_trn-doc.doc-code
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                return error .
              end.
            end.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                                    , buf_trn-doc.doc-code
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
          end.
        end.
        when 'ord-doc':U
        then do:
          find first buf_ord-doc no-lock
            where buf_ord-doc.doc-code = p-doc-code
          no-error .
          if available buf_ord-doc
          then do:
            run bge/doc-ord.p ( input yes
                              , input p-host-code
                              , input p-obj-type
                              , input p-obj-code
                              , input p-start-date
                              , input ?
                              , input 'ОП':U
                              , input 'поставка':U
                              , input sOutFile
                              , input sLogFile
                              , input p-parent-proc
                              , input hEDT
                              , input hCNT
                              , input buf_ord-doc.doc-code
                              ) no-error .
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка экспорта заказа: &5. &1&2.&1&3&1&4 "
                                                                      , chr(10)
                                                                      , return-value
                                                                      , trim(error-status :get-message(1))
                                                                      , trim(error-status :get-message(2))
                                                                      , p-doc-code
                                                                      )
                                                    ).
            end.
          end.
        end.
        otherwise do:
          undo, return error substitute( "Недопустимый тип документа: &1 ":U , p-doc-type ) .
        end.
      end case.
      return .
    end.
    find last buf_ot-tot no-lock
      where buf_ot-tot.obj-type = p-obj-type
        and buf_ot-tot.obj-code = p-obj-code
    use-index obj-ot
    no-error .
    if not available buf_ot-tot
    then do:
      run wp-XMLWriteLog in this-procedure ( input sLogFile
                                           , input 1
                                           , input "Не найдены архивы...":U
                                           ).
      undo, return error.
    end.
    assign
      v-stop-fo = buf_ot-tot.fact-order
    .
    run wp-XMLWriteLog in this-procedure ( input sLogFile
                                         , input 1
                                         , input 'Сбор документов для выгрузки'
                                         ).
    empty temp-table buf_tt-docs.
    _price-doc-cycle:
    for each buf_price-doc no-lock
       where buf_price-doc.obj-type = p-obj-type
         and buf_price-doc.obj-code = p-obj-code
         and buf_price-doc.bge-date = ?
         and buf_price-doc.status_  = 'акт':U
         and buf_price-doc.fact-date >= p-start-date
         and buf_price-doc.fact-order > 0
    use-index bge-obj
    on error undo, return error
    :
      if buf_price-doc.fact-order > v-stop-fo
      then do:
        next _price-doc-cycle.
      end.
      find first buf_tt-docs no-lock
        where buf_tt-docs.fact-order  = buf_price-doc.fact-order
          and buf_tt-docs.doc-code    = buf_price-doc.doc-num
          and buf_tt-docs.doc-type    = 'price-doc':U
      no-error .
      if not available buf_tt-docs
      then do:
        create buf_tt-docs.
        assign
          buf_tt-docs.fact-order = buf_price-doc.fact-order
          buf_tt-docs.doc-code   = buf_price-doc.doc-num
          buf_tt-docs.doc-type   = 'price-doc':U
        .
      end.
    end.
    _trn-doc-cycle:
    for each buf_trn-doc no-lock
       where buf_trn-doc.obj-type = p-obj-type
         and buf_trn-doc.obj-code = p-obj-code
         and buf_trn-doc.bge-date = ?
         and buf_trn-doc.status_  = 'факт':U
         and buf_trn-doc.fact-date >= p-start-date
         and buf_trn-doc.fact-order > 0
    on error undo, return error
    :
      if buf_trn-doc.fact-order > v-stop-fo
      then do:
        next _trn-doc-cycle.
      end.
      find first buf_tt-docs no-lock
        where buf_tt-docs.fact-order  = buf_trn-doc.fact-order
          and buf_tt-docs.doc-code    = buf_trn-doc.doc-code
          and buf_tt-docs.doc-type    = 'trn-doc':U
      no-error .
      if not available buf_tt-docs
      then do:
        create buf_tt-docs.
        assign
          buf_tt-docs.fact-order = buf_trn-doc.fact-order
          buf_tt-docs.doc-code   = buf_trn-doc.doc-code
          buf_tt-docs.doc-type   = 'trn-doc':U
        .
      end.
    end.
    run wp-XMLWriteLog in this-procedure ( input sLogFile
                                         , input 1
                                         , input 'Выгрузка документов по fact-order...'
                                         ).
    _docs-cycle:
    for each buf_tt-docs no-lock
    :
      find first buf_trn-doc share-lock
        where buf_trn-doc.doc-code = buf_tt-docs.doc-code
        no-error .
      if avail buf_trn-doc
        then assign v-ext-doc-type = buf_trn-doc.ext-doc-type .
      else v-ext-doc-type = " " .
      if  v-ext-doc-type = 'ie':U
          then assign v-pr-doc-type = YES .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_tt-docs.doc-code ,
                        input 'envd':U ,
                       output varenvd ,
                       output vartype )  .
      if    varenvd eq "YES"
          and v-pr-doc-type eq YES
          then
          v-is-envd_ = YES .
      else  v-is-envd_ = NO .
      if v-is-envd_ = YES
        then
        run calc-lines in this-procedure (
        input  buf_tt-docs.doc-code ,
        output v-sum-all-parts
        ) no-error.
      else
        v-sum-all-parts = 0 .
      _export-block:
      do transaction
      on error undo _export-block , return error return-value
      :
        case buf_tt-docs.doc-type
        :
          when 'price-doc':U
          then do:
            find first buf_price-doc share-lock
              where buf_price-doc.doc-num = buf_tt-docs.doc-code
            no-wait
            no-error .
            if not available buf_price-doc
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                   , input 1
                                                   , input substitute( "Документ &1 обрабатывается. Выгрузка приостановлена."
                                                                       , buf_tt-docs.doc-code
                                                                       , return-value
                                                                       , trim(error-status :get-message(1))
                                                                       , trim(error-status :get-message(2))
                                                                     )
                                                   ).
              undo _export-block, return .
            end.
            if available buf_price-doc
            then do:
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                output stream stmxmlout close.
                run bge-xml-ora-exp-filename in this-procedure ( input 'price-doc':U
                                                              , input buf_tt-docs.doc-code
                                                              , input p-obj-code
                                                              , output v-exp-ora-filename
                                                              , output v-ora-exp-seq-num
                                                              ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                      , input 1
                                                      , input substitute( "Ошибка экспорта документа переоценки. Номер документа: &1. &2. &3 &4 "
                                                                          , buf_tt-docs.doc-code
                                                                          , return-value
                                                                          , trim(error-status :get-message(1))
                                                                          , trim(error-status :get-message(2))
                                                                        )
                                                      ).
                  undo _export-block, return .
                end.
                run bge-xml-write-header in this-procedure (
                      input v-exp-ora-filename
                    , input v-exp-ora-filename + "xml"
                    , input "15.0 " + replace( vss-revision + vss-date, "$", " " )
                    , input 0
                    , input v-date-from
                    , input 0
                    , input v-date-to
                    , input 0
                    , input v-obj-list
                    , input ""
                    , input p-pay-code
                    , input p-cst
                    , input p-parts
                    , input p-chk-pay-code
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input no
                    , input no
                ).
                OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Выгрузка документа &1 в пакет &2."
                                                                      , buf_tt-docs.doc-code
                                                                      , v-exp-ora-filename + "xml"
                                                                      )
                                                    ).
              end.
              assign
                  v-doc-code     = buf_price-doc.doc-num
                  v-doc-date     = buf_price-doc.doc-date
                  v-fact-date    = buf_price-doc.fact-date
                  v-reason-code  = 0
                  v-doc-ps       = buf_price-doc.ps
                  v-fact-order   = buf_price-doc.fact-order
                  v-sys-date     = buf_price-doc.sys-date
                  v-sys-time     = buf_price-doc.sys-time
              .
              run export-from-archive (
                    input 'ot':U
                  , input v-doc-code
                  , input v-doc-date
                  , input v-fact-date
                  , input v-reason-code
                  , input v-doc-ps
                  , input v-fact-order
                  , input v-sys-date
                  , input v-sys-time
                  , input ""
                  , input ""
                  , input ""
                  , input ?
                  , input 0
                  , input ""
                  , input ""
                  , input ""
                  , input 0
                  , input ""
                  , input ""
                  , input ""
                  , input ""
                  , input ?
                  , input ?
                  , input ?
                  , input v-is-envd_
                  , input v-sum-all-parts
              ) no-error.
              if error-status :error
              then do:
                  run wp-XMLWriteLog in this-procedure (
                        input sLogFile
                      , input 1
                      , input substitute( "Ошибка экспорта документа переоценки. Номер документа: &1. &2. &3 &4 "
                                          , v-doc-code
                                          , return-value
                                          , trim(error-status :get-message(1))
                                          , trim(error-status :get-message(2))
                                        )
                  ).
                  if v-bge-xml-bgeflold = "oracle":u
                  then do:
                    undo _export-block, return .
                  end.
                  else do:
                    undo _export-block, next _docs-cycle.
                  end.
              end.
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                output stream stmxmlout close.
                run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
                run bge/setbgedt.p ( input 'price-doc':U
                                   , input v-doc-code
                                   , input p-cur-date
                                   ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                       , input 1
                                                       , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                           , v-doc-code
                                                                           , return-value
                                                                           , trim(error-status :get-message(1))
                                                                           , trim(error-status :get-message(2))
                                                                         )
                                                       ).
                  undo _export-block, return error .
                end.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                                      , buf_tt-docs.doc-code
                                                                      , v-exp-ora-filename + "xml"
                                                                      )
                                                    ).
              end.
              else do:
                run run-callback-write-doc-code in this-procedure ( input p-parent-proc
                                                                  , input 'price-doc':U
                                                                  , input v-doc-code
                                                                  , input sLogFile
                                                                  ).
              end.
            end.
          end.
          when 'trn-doc':U
          then do:
            find first buf_trn-doc share-lock
              where buf_trn-doc.doc-code = buf_tt-docs.doc-code
            no-error .
            if not available buf_trn-doc
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                   , input 1
                                                   , input substitute( "Документ &1 обрабатывается. Выгрузка приостановлена."
                                                                       , buf_tt-docs.doc-code
                                                                       , return-value
                                                                       , trim(error-status :get-message(1))
                                                                       , trim(error-status :get-message(2))
                                                                     )
                                                   ).
              undo _export-block, return .
            end.
            if available buf_trn-doc
            then do:
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                output stream stmxmlout close.
                run bge-xml-ora-exp-filename in this-procedure ( input 'trn-doc':U
                                                              , input buf_tt-docs.doc-code
                                                              , input p-obj-code
                                                              , output v-exp-ora-filename
                                                              , output v-ora-exp-seq-num
                                                              ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                      , input 1
                                                      , input substitute( "Ошибка экспорта документа. Номер документа: &1. &2. &3 &4 "
                                                                          , buf_tt-docs.doc-code
                                                                          , return-value
                                                                          , trim(error-status :get-message(1))
                                                                          , trim(error-status :get-message(2))
                                                                        )
                                                      ).
                  if v-bge-xml-bgeflold = "oracle":u
                  then do:
                    undo _export-block, return .
                  end.
                  else do:
                    undo _export-block, next _docs-cycle.
                  end.
                end.
                run bge-xml-write-header in this-procedure (
                      input v-exp-ora-filename
                    , input v-exp-ora-filename + "xml"
                    , input "15.0 " + replace( vss-revision + vss-date, "$", " " )
                    , input 0
                    , input v-date-from
                    , input 0
                    , input v-date-to
                    , input 0
                    , input v-obj-list
                    , input buf_trn-doc.ext-doc-type
                    , input p-pay-code
                    , input p-cst
                    , input p-parts
                    , input p-chk-pay-code
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input no
                    , input no
                ).
                OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Выгрузка документа &1 в пакет &2."
                                                                      , buf_tt-docs.doc-code
                                                                      , v-exp-ora-filename + "xml"
                                                                      )
                                                    ).
              end.
              assign
                  v-supp-dog-code = "":U
                  v-supp-ndog     = "":U
                  v-supp-ddog     = "":U
              .
              run fill_bge-xml_clients in this-procedure (
                    input p-parent-proc
                  , input buf_trn-doc.cli-type
                  , input buf_trn-doc.cli-code
              ).
              assign
                  v-ext-doc-type = buf_trn-doc.ext-doc-type
                  v-doc-code     = buf_trn-doc.doc-code
                  v-doc-date     = buf_trn-doc.doc-date
                  v-fact-date    = buf_trn-doc.fact-date
                  v-reason-code  = buf_trn-doc.reason-code
                  v-doc-ps       = buf_trn-doc.ps
                  v-fact-order   = buf_trn-doc.fact-order
                  v-sys-date     = buf_trn-doc.sys-date
                  v-sys-time     = buf_trn-doc.sys-time
                  v-firm-code    = buf_trn-doc.cli-type + string( buf_trn-doc.cli-code )
                  v-ord-num      = buf_trn-doc.ord-num
                  v-ship-num     = buf_trn-doc.ship-num
                  v-ship-date    = buf_trn-doc.ship-date
                  v-pay-code     = buf_trn-doc.pay-code
                  v-out-code     = buf_trn-doc.out-code
              .
              if v-ext-doc-type = 'ie':U
              or v-ext-doc-type = 'ap':U
              then  do:
                  if buf_trn-doc.contract-code <> 0
                  then do:
                      assign
                          v-supp-dog-code = string( buf_trn-doc.contract-code )
                      .
                      find first buf_contract no-lock
                          where buf_contract.host-code       = buf_trn-doc.host-code
                            and buf_contract.contract-code   = buf_trn-doc.contract-code
                      no-error.
                      if available buf_contract
                      then do:
                          assign
                              v-supp-ndog          = string( buf_contract.contract-prn-code )
                              v-supp-ddog          = string( buf_contract.contract-date, "99.99.9999" )
                          .
                      end.
                  end.
              end.
              run export-from-archive (
                    input v-ext-doc-type
                  , input v-doc-code
                  , input v-doc-date
                  , input v-fact-date
                  , input v-reason-code
                  , input v-doc-ps
                  , input v-fact-order
                  , input v-sys-date
                  , input v-sys-time
                  , input v-firm-code
                  , input v-ord-num
                  , input v-ship-num
                  , input v-ship-date
                  , input v-pay-code
                  , input buf_trn-doc.hold-doc-code-child
                  , input buf_trn-doc.hold-doc-code-parent
                  , input buf_trn-doc.hold-obj-type
                  , input buf_trn-doc.hold-obj-code
                  , input v-out-code
                  , input v-supp-dog-code
                  , input v-supp-ndog
                  , input v-supp-ddog
                  , input buf_trn-doc.d-card
                  , input buf_trn-doc.cli-type
                  , input buf_trn-doc.cli-code
                  , input v-is-envd_
                  , input v-sum-all-parts
              ) no-error.
              if error-status :error
              then do:
                  run wp-XMLWriteLog in this-procedure (
                        input sLogFile
                      , input 1
                      , input substitute( "Ошибка экспорта складского документа. Номер документа: &1. &2. &3 &4 "
                                          , v-doc-code
                                          , return-value
                                          , trim(error-status :get-message(1))
                                          , trim(error-status :get-message(2))
                                        )
                  ).
                  if v-bge-xml-bgeflold = "oracle":u
                  then do:
                    undo _export-block, return .
                  end.
                  else do:
                    undo _export-block, next _docs-cycle.
                  end.
              end.
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                output stream stmxmlout close.
                run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
                run bge/setbgedt.p ( input 'trn-doc':U
                                   , input buf_trn-doc.doc-code
                                   , input p-cur-date
                                   ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                       , input 1
                                                       , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                           , buf_trn-doc.doc-code
                                                                           , return-value
                                                                           , trim(error-status :get-message(1))
                                                                           , trim(error-status :get-message(2))
                                                                         )
                                                       ).
                  undo _export-block, return error .
                end.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                                      , buf_tt-docs.doc-code
                                                                      , v-exp-ora-filename + "xml"
                                                                      )
                                                    ).
              end.
              else do:
                run run-callback-write-doc-code in this-procedure ( input p-parent-proc
                                                                  , input 'trn-doc':U
                                                                  , input buf_trn-doc.doc-code
                                                                  , input sLogFile
                                                                  ).
              end.
            end.
          end.
        end case.
      end.
    end.
    run wp-XMLWriteLog in this-procedure ( input sLogFile
                                         , input 1
                                         , input 'Выгрузка удаленных документов...'
                                         ).
    export-deleted-documents:
    for each buf_c-trn-doc no-lock
       where buf_c-trn-doc.obj-type = p-obj-type
         and buf_c-trn-doc.obj-code = p-obj-code
         and buf_c-trn-doc.is-del   = yes
    on error undo, return error
    :
      _export-block:
      do transaction
      on error undo _export-block , return error return-value
      :
        if buf_c-trn-doc.bge-date = ?
        then do:
          if v-bge-xml-bgeflold = "oracle":u
          then do:
            output stream stmxmlout close.
            run bge-xml-ora-exp-filename in this-procedure ( input 'c-trn-doc':U
                                                           , input buf_c-trn-doc.doc-code
                                                           , input p-obj-code
                                                           , output v-exp-ora-filename
                                                           , output v-ora-exp-seq-num
                                                           ) no-error .
            if error-status :error = yes
            then do:
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                     , input 1
                                                     , input substitute( "Ошибка экспорта удаленного документа. Номер документа: &1. &2. &3 &4 "
                                                                       , buf_c-trn-doc.doc-code
                                                                       , return-value
                                                                       , trim(error-status :get-message(1))
                                                                       , trim(error-status :get-message(2))
                                                                       )
                                                     ).
                if v-bge-xml-bgeflold = "oracle":u
                then do:
                  undo export-deleted-documents, return .
                end.
                else do:
                  undo export-deleted-documents, next export-deleted-documents.
                end.
            end.
            run bge-xml-write-header in this-procedure (
                  input v-exp-ora-filename
                , input v-exp-ora-filename + "xml"
                , input "15.0 " + replace( vss-revision + vss-date, "$", " " )
                , input 0
                , input v-date-from
                , input 0
                , input v-date-to
                , input 0
                , input v-obj-list
                , input buf_c-trn-doc.ext-doc-type
                , input p-pay-code
                , input p-cst
                , input p-parts
                , input p-chk-pay-code
                , input p-pay-desk
                , input p-pay-desk-cards
                , input no
                , input no
            ).
            OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка удаленного документа &1 в пакет &2."
                                                                    , buf_c-trn-doc.doc-code
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
          end.
          assign
                    v-doc-code     = buf_c-trn-doc.doc-code
          .
          run export-deleted-docs in this-procedure (
                input v-doc-code
              , input buf_c-trn-doc.corr-user-db-num
              , input buf_c-trn-doc.chip-num
          ) no-error.
          if error-status :error
          then do:
              run wp-XMLWriteLog in this-procedure (
                    input sLogFile
                  , input 1
                  , input substitute( "Ошибка экспорта удаленного документа. Номер документа: &1. &2. &3 &4 "
                                      , v-doc-code
                                      , return-value
                                      , trim(error-status :get-message(1))
                                      , trim(error-status :get-message(2))
                                  )
              ).
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                undo export-deleted-documents, return .
              end.
              else do:
                undo export-deleted-documents, next export-deleted-documents.
              end.
          end.
          if v-bge-xml-bgeflold = "oracle":u
          then do:
            output stream stmxmlout close.
            run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
            run bge/setbgedt.p ( input 'c-trn-doc':U
                               , input buf_c-trn-doc.doc-code
                               , input p-cur-date
                               ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                        , buf_c-trn-doc.doc-code
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              undo _export-block, return error .
            end.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка удаленного документа &1 в пакет &2 завершена."
                                                                    , buf_c-trn-doc.doc-code
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
          end.
          else do:
            run run-callback-write-doc-code in this-procedure ( input p-parent-proc
                                                              , input 'c-trn-doc':U
                                                              , input buf_c-trn-doc.doc-code
                                                              , input sLogFile
                                                              ).
          end.
        end.
      end.
    end.
    if v-bge-xml-bgeflold = "oracle":u
    then do:
      run bge/doc-ord.p ( input yes
                        , input p-host-code
                        , input p-obj-type
                        , input p-obj-code
                        , input p-start-date
                        , input ?
                        , input 'ОП':U
                        , input 'поставка':U
                        , input sOutFile
                        , input sLogFile
                        , input p-parent-proc
                        , input hEDT
                        , input hCNT
                        , input ?
                        ) no-error .
      if error-status :error
      then do:
          run wp-XMLWriteLog in this-procedure ( input sLogFile
                                              , input 1
                                              , input substitute( "Ошибка экспорта заказов. &1&2.&1&3&1&4 "
                                                                , chr(10)
                                                                , return-value
                                                                , trim(error-status :get-message(1))
                                                                , trim(error-status :get-message(2))
                                                                )
                                              ).
      end.
    end.
    empty temp-table buf_tt-docs.
end.
end procedure.
procedure export-from-archive :
define input parameter p-ext-doc-type           as character        no-undo.
define input parameter p-doc-code               as character        no-undo.
define input parameter p-doc-date               as date             no-undo.
define input parameter p-fact-date              as date             no-undo.
define input parameter p-reason-code            as integer          no-undo.
define input parameter p-doc-PS                 as character        no-undo.
define input parameter p-fact-order             as decimal          no-undo.
define input parameter p-sys-date               as date             no-undo.
define input parameter p-sys-time               as character        no-undo.
define input parameter p-firm-code              as character        no-undo.
define input parameter p-ord-num                as character        no-undo.
define input parameter p-ship-num               as character        no-undo.
define input parameter p-ship-date              as date             no-undo.
define input parameter p-payment-code           as integer          no-undo.
define input parameter p-hold-doc-code-child    as character        no-undo.
define input parameter p-hold-doc-code-parent   as character        no-undo.
define input parameter p-hold-obj-type          as character        no-undo.
define input parameter p-hold-obj-code          as integer          no-undo.
define input parameter p-out-code               as character        no-undo.
define input parameter p-supp-dog-code          as character        no-undo.
define input parameter p-supp-ndog              as character        no-undo.
define input parameter p-supp-ddog              as character        no-undo.
define input parameter p-d-card                 as character        no-undo.
define input parameter p-cli-type               as character        no-undo.
define input parameter p-cli-code               as integer          no-undo.
define input parameter p-is-envd_               as logical          no-undo.
define input parameter p-sum-all-parts          as decimal          no-undo.
    define variable v-exists-before     as logical      no-undo.
    define variable v-exists-after      as logical      no-undo.
    define variable v-obj-type          as character    no-undo.
    define variable v-obj-code          as integer      no-undo.
    define variable v-qnty              as decimal      no-undo.
    define variable v-excise-base       as decimal      no-undo.
    define variable v-country-code      as character    no-undo.
    define variable v-excise-rubl       as decimal      no-undo.
    define variable v-transport-base    as decimal      no-undo.
    define variable v-transport-rubl    as decimal      no-undo.
    define variable v-other-base        as decimal      no-undo.
    define variable v-other-rubl        as decimal      no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-scale-is-empty    as logical      no-undo.
           define variable ii                      as integer   no-undo.
        define variable v-attrcode              as char no-undo.
        define variable v-SectionName           as char no-undo.
        define variable v-DocQnty               as decimal no-undo.
        define variable v-CliQnty               as decimal no-undo.
        define variable v-FactQnty              as decimal no-undo.
        define variable v-FactDensity           as decimal no-undo.
        define variable v-DocDensity            as decimal no-undo.
        define variable v-TankVol               as decimal no-undo.
        define variable v-TankDensity           as decimal no-undo.
        define variable v-TankDensityPomi       as decimal no-undo.
        define variable v-TankVolPomi           as decimal no-undo.
        define variable v-tank-vol              as decimal   no-undo .
        define variable v-tank-density          as decimal   no-undo .
        define variable v-SectionNum            as integer   no-undo.
        define variable v-total-tank-density    as decimal   no-undo.
        define variable v-tankweight            as decimal   no-undo.
        define variable v-sum-parts             as decimal   no-undo.
    define buffer buf_ot-tot-sale           for ub.ot-tot.
    define buffer buf_ot-tot-cost           for ub.ot-tot.
    define buffer buf_ot-tot-crsa           for ub.ot-tot.
    define buffer buf_ot-tot-crsa-loop      for ub.ot-tot.
    define buffer buf_ot-line-sale          for ub.ot-line.
    define buffer buf_ot-line-cost          for ub.ot-line.
    define buffer buf_ot-line-crsa          for ub.ot-line.
    define buffer buf_ot-line-crsa-loop     for ub.ot-line.
    define buffer buf_cost_ot-supp-line     for ub.ot-supp-line.
    define buffer buf_sale_ot-supp-line     for ub.ot-supp-line.
    define buffer buf_cost_ot-supp-tot      for ub.ot-supp-tot.
    define buffer buf_sale_ot-supp-tot      for ub.ot-supp-tot.
    define buffer buf_doc-line              for ub.doc-line.
    define buffer buf_parts                 for ub.parts.
    define buffer buf_parts-attr            for ub.parts-attr.
    define buffer buf_parts-root            for parts-root.
    define buffer buf_doc-line-sum          for ub.doc-line-sum.
    define buffer buf_inkas                 for ub.inkas.
    define buffer buf_units                 for ub.units.
    define buffer buf_price-list            for ub.price-list.
    define buffer buf_doc-line-attr         for ub.doc-line-attr.
    define buffer buf_doc-pl                for ub.doc-pl.
do
for buf_ot-tot-sale
  , buf_ot-tot-cost
  , buf_ot-tot-crsa
  , buf_ot-tot-crsa-loop
  , buf_ot-line-sale
  , buf_ot-line-cost
  , buf_ot-line-crsa
  , buf_ot-line-crsa-loop
  , buf_cost_ot-supp-line
  , buf_sale_ot-supp-line
  , buf_cost_ot-supp-tot
  , buf_sale_ot-supp-tot
  , buf_doc-line
  , buf_parts
  , buf_parts-attr
  , buf_parts-root
  , buf_doc-line-sum
  , buf_inkas
  , buf_units
  , buf_price-list
on error undo, return error return-value
on endkey undo, return error return-value
:
    find first buf_ot-tot-crsa-loop no-lock
         where buf_ot-tot-crsa-loop.doc-code    = p-doc-code
           and buf_ot-tot-crsa-loop.sum-type    = 'crsa':U
           and buf_ot-tot-crsa-loop.cat-id      = '##,##':U
    no-error.
    if not available buf_ot-tot-crsa-loop
    then do:
        run wp-XMLWriteLog( sLogFile, 1, substitute("Для документа &1 не найдена запись в архиве." , p-doc-code )).
        undo, return error .
    end.
    assign
        v-obj-type = buf_ot-tot-crsa-loop.obj-type
        v-obj-code = buf_ot-tot-crsa-loop.obj-code
    .
    case p-ext-doc-type
    :
        when 'ot':U
        then do:
            find first buf_ot-tot-sale no-lock
                 where buf_ot-tot-sale.doc-code = p-doc-code
                   and buf_ot-tot-sale.sum-type = 'crsa':U
                   and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
            no-error.
            if not available buf_ot-tot-sale
            then do:
                run wp-XMLWriteLog( sLogFile, 1, "Не найден документ переоценки " + string( p-doc-code ) ).
                undo, return error.
            end.
        end.
        otherwise do:
            find first buf_ot-tot-sale no-lock
                 where buf_ot-tot-sale.doc-code = p-doc-code
                   and buf_ot-tot-sale.sum-type = 'sale':U
                   and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
            no-error.
            if not available buf_ot-tot-sale
            then do:
                find first buf_ot-tot-sale no-lock
                     where buf_ot-tot-sale.doc-code = p-doc-code
                       and buf_ot-tot-sale.sum-type = 'sasr':U
                       and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
                no-error.
            end.
            if not available buf_ot-tot-sale
            then do:
                if buf_ot-tot-crsa-loop.fact-qnty <> 0
                then do:
                    run wp-XMLWriteLog( sLogFile, 1, "В архивах нет записей sum-type = 'sale':U или 'sasr':U для документа номер " + string( p-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" ).
                end.
            end.
            else do:
                if buf_ot-tot-crsa-loop.fact-qnty <> buf_ot-tot-sale.fact-qnty
                then do:
                    run wp-XMLWriteLog( sLogFile, 1, "Не совпадает фактическое количество для записей архивов sum-type = 'sale':U и 'crsa':U для документа номер " + string( p-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" ).
                end.
            end.
        end.
    end case.
    run wp-XMLWriteCnt( hcnt, "   " + string( p-doc-code ) + " от " + string( p-fact-date ) ) .
    process events.
    run write-doc-header in this-procedure (
          input v-obj-type
        , input v-obj-code
        , input p-ext-doc-type
        , input p-doc-code
        , input p-doc-date
        , input p-fact-date
        , input p-reason-code
        , input p-doc-PS
        , input p-fact-order
        , input p-sys-date
        , input p-sys-time
        , input p-firm-code
        , input p-ord-num
        , input p-ship-num
        , input p-ship-date
        , input p-payment-code
        , input p-hold-doc-code-child
        , input p-hold-doc-code-parent
        , input p-hold-obj-type
        , input p-hold-obj-code
        , input p-out-code
        , input p-supp-dog-code
        , input p-supp-ndog
        , input p-supp-ddog
        , input p-d-card
        , input p-cli-type
        , input p-cli-code
    ) no-error.
    if p-ext-doc-type <> 'ot':U
    and p-pay-code = yes
    or ( p-chk-pay-code = yes
    and ( p-ext-doc-type = 'es':U or p-ext-doc-type = 'rs':U ) )
    then do:
            case p-ext-doc-type :
                when 'es':U
                then do:
                    assign
                        v-is-out                = 1
                        v-inkas-pay-desk-type   = 'при':U
                    .
                    find first buf_inkas no-lock
                            where buf_inkas.inkas-code = p-doc-code
                    no-error.
                end.
                when 'rs':U
                then do:
                    assign
                        v-is-out                = -1
                        v-inkas-pay-desk-type   = 'рас':U
                    .
                    find first buf_inkas no-lock
                            where buf_inkas.inkas-code = p-out-code
                    no-error.
                end.
            end case.
            if available buf_inkas
            then do:
                run bge/bgepych2.p (
                      input buf_inkas.inkas-code
                    , input p-ext-doc-type
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input yes
                    , input yes
                    , input yes
                ) no-error.
                if ERROR-STATUS:error then do:
                    run wp-XMLWriteLog(  sLogFile, 1, error-status:get-message(1) + string( p-doc-code ) ).
                end.
                if p-pay-code = yes
                then do:
                    run get-inkas-pay-desk in this-procedure (
                          input buf_inkas.inkas-code
                        , input buf_inkas.obj-type
                        , input buf_inkas.obj-code
                        , input v-inkas-pay-desk-type
                    ) no-error .
                    if error-status:error
                    then do:
                        run wp-XMLWriteLog(  sLogFile, 1, "*** ERR: *** Не удалось рассчитать разбивку по кодам оплат по документу N "+ string( p-doc-code ) ).
                    end.
                    run wp-xmltagopen( 3, "cassSum","" ).
                    for each temp_inkas-pay
                    on error undo, return error
                    :
                        run wp-xmltagopen( 4, "payCode", "" ).
                        run wp-xmltagput( 5, "code", string( temp_inkas-pay.pay-code ), 0 ).
                        run wp-xmltagput( 5, "sum",  string( v-is-out * temp_inkas-pay.tot-sum ),  1 ).
                        run wp-xmltagput( 5, "sumb", string( v-is-out * temp_inkas-pay.tot-base ), 1 ).
                        run wp-xmltagput( 5, "sumr", string( v-is-out * temp_inkas-pay.tot-rubl ), 1 ).
                        run wp-xmltagclose( 4, "payCode" ).
                    end.
                    run wp-xmltagclose( 3, "cassSum" ).
                end.
            end.
            else do:
                if p-ext-doc-type = 'es':U
                or p-ext-doc-type = 'rs':U
                then do:
                    run wp-XMLWriteLog(  sLogFile, 1, "*** ERR: *** Не найден inkas для документа расхода или возврата по кассе N " + string( p-doc-code ) ).
                end.
            end.
    end.
    if available buf_ot-tot-sale
    then do:
        run wp-xmltagopen( 3, "docSum","" ).
        run wp-xmltagput( 4, "sumr"      , string( abs( buf_ot-tot-sale.sum-rubl       ) ), 1 ).
        if p-is-envd_ eq NO then
          run wp-xmltagput( 4, "VATr"      , string( abs( buf_ot-tot-sale.vat-rubl     ) ), 1 ).
        else
          run wp-xmltagput( 4, "VATr"      , string( abs( p-sum-all-parts              ) ), 1 ).
        run wp-xmltagput( 4, "SLTr"      , string( abs( buf_ot-tot-sale.slt-rubl       ) ), 1 ).
        run wp-xmltagput( 4, "roadTaxr"  , string( abs( buf_ot-tot-sale.road-tax-rubl  ) ), 1 ).
        run wp-xmltagput( 4, "transportr", string( abs( buf_ot-tot-sale.transport-rubl ) ), 1 ).
        run wp-xmltagput( 4, "otherr"    , string( abs( buf_ot-tot-sale.other-rubl     ) ), 1 ).
        run wp-xmltagput( 4, "exciser"   , string( abs( buf_ot-tot-sale.excise-rubl    ) ), 1 ).
        run wp-xmltagput( 4, "sumb"      , string( abs( buf_ot-tot-sale.sum-base       ) ), 1 ).
        run wp-xmltagput( 4, "VATb"      , string( abs( buf_ot-tot-sale.vat-base       ) ), 1 ).
        run wp-xmltagput( 4, "SLTb"      , string( abs( buf_ot-tot-sale.slt-base       ) ), 1 ).
        run wp-xmltagput( 4, "roadTaxb"  , string( abs( buf_ot-tot-sale.road-tax-base  ) ), 1 ).
        run wp-xmltagput( 4, "transportb", string( abs( buf_ot-tot-sale.transport-base ) ), 1 ).
        run wp-xmltagput( 4, "otherb"    , string( abs( buf_ot-tot-sale.other-base     ) ), 1 ).
        run wp-xmltagput( 4, "exciseb"   , string( abs( buf_ot-tot-sale.excise-base    ) ), 1 ).
        run wp-xmltagclose( 3, "docSum" ).
    end.
    if p-ext-doc-type <> 'ot':U
    then do:
        find first buf_ot-tot-cost no-lock
             where buf_ot-tot-cost.doc-code    = p-doc-code
               and buf_ot-tot-cost.sum-type    = 'cost':U
               and buf_ot-tot-cost.cat-id      = '##,##':U
        no-error.
        if not available buf_ot-tot-cost
        then do:
            find first buf_ot-tot-cost no-lock
                 where buf_ot-tot-cost.doc-code    = p-doc-code
                   and buf_ot-tot-cost.sum-type    = 'cssr':U
                   and buf_ot-tot-cost.cat-id      = '##,##':U
            no-error.
        end.
        if available buf_ot-tot-cost
        then do:
            run wp-xmltagopen( 3, "costSum", "" ).
            run wp-xmltagput( 4, "sumr",        string( abs( buf_ot-tot-cost.sum-rubl       ) ), 1 ).
            if p-is-envd_ eq NO then
              run wp-xmltagput( 4, "VATr",        string( abs( buf_ot-tot-cost.vat-rubl     ) ), 1 ).
            else
              run wp-xmltagput( 4, "VATr",        string( abs( p-sum-all-parts              ) ), 1 ).
            run wp-xmltagput( 4, "SLTr",        string( abs( buf_ot-tot-cost.slt-rubl       ) ), 1 ).
            run wp-xmltagput( 4, "roadTaxr",    string( abs( buf_ot-tot-cost.road-tax-rubl  ) ), 1 ).
            run wp-xmltagput( 4, "transportr",  string( abs( buf_ot-tot-cost.transport-rubl ) ), 1 ).
            run wp-xmltagput( 4, "otherr",      string( abs( buf_ot-tot-cost.other-rubl     ) ), 1 ).
            run wp-xmltagput( 4, "exciser",     string( abs( buf_ot-tot-cost.excise-rubl    ) ), 1 ).
            run wp-xmltagput( 4, "sumb",        string( abs( buf_ot-tot-cost.sum-base       ) ), 1 ).
            run wp-xmltagput( 4, "VATb",        string( abs( buf_ot-tot-cost.vat-base       ) ), 1 ).
            run wp-xmltagput( 4, "SLTb",        string( abs( buf_ot-tot-cost.slt-base       ) ), 1 ).
            run wp-xmltagput( 4, "roadTaxb",    string( abs( buf_ot-tot-cost.road-tax-base  ) ), 1 ).
            run wp-xmltagput( 4, "transportb",  string( abs( buf_ot-tot-cost.transport-base ) ), 1 ).
            run wp-xmltagput( 4, "otherb",      string( abs( buf_ot-tot-cost.other-base     ) ), 1 ).
            run wp-xmltagput( 4, "exciseb",     string( abs( buf_ot-tot-cost.excise-base    ) ), 1 ).
            run wp-xmltagclose( 3, "costSum" ).
        end.
        else do:
            if available buf_ot-tot-sale
            then do:
                run wp-XMLWriteLog( sLogFile, 1, "*** ERR: *** В архиве не найдена запись с sum-type = 'cost':U или 'cssr':U для документа " + string( p-doc-code ) ).
            end.
        end.
        for each temp_cost_cat-id_ot-supp-tot no-lock
        on error undo, return error
        :
            delete temp_cost_cat-id_ot-supp-tot.
        end.
        for each temp_cost_cli_ot-supp-tot no-lock
        on error undo, return error
        :
            delete temp_cost_cli_ot-supp-tot.
        end.
        for each buf_cost_ot-supp-tot no-lock
            where buf_cost_ot-supp-tot.doc-code = p-doc-code
        on error undo, return error
        :
            if buf_cost_ot-supp-tot.sum-type = 'cost':U + 'p':U
            then do:
                find first temp_cost_cat-id_ot-supp-tot
                        where temp_cost_cat-id_ot-supp-tot.cat-id   = buf_cost_ot-supp-tot.cat-id
                no-error.
                if not available temp_cost_cat-id_ot-supp-tot
                then do:
                    create temp_cost_cat-id_ot-supp-tot.
                    assign
                        temp_cost_cat-id_ot-supp-tot.cat-id   = buf_cost_ot-supp-tot.cat-id
                    .
                end.
                find first temp_cost_cli_ot-supp-tot
                     where temp_cost_cli_ot-supp-tot.cat-id   = buf_cost_ot-supp-tot.cat-id
                       and temp_cost_cli_ot-supp-tot.cli-type = buf_cost_ot-supp-tot.cli-type
                       and temp_cost_cli_ot-supp-tot.cli-code = buf_cost_ot-supp-tot.cli-code
                no-error.
                if not available temp_cost_cli_ot-supp-tot
                then do:
                    create temp_cost_cli_ot-supp-tot.
                    assign
                        temp_cost_cli_ot-supp-tot.cat-id            = buf_cost_ot-supp-tot.cat-id
                        temp_cost_cli_ot-supp-tot.cli-type          = buf_cost_ot-supp-tot.cli-type
                        temp_cost_cli_ot-supp-tot.cli-code          = buf_cost_ot-supp-tot.cli-code
                        temp_cost_cli_ot-supp-tot.sum-rubl          = buf_cost_ot-supp-tot.sum-rubl
                        temp_cost_cli_ot-supp-tot.vat-rubl          = buf_cost_ot-supp-tot.vat-rubl
                        temp_cost_cli_ot-supp-tot.slt-rubl          = buf_cost_ot-supp-tot.slt-rubl
                        temp_cost_cli_ot-supp-tot.road-tax-rubl     = buf_cost_ot-supp-tot.road-tax-rubl
                        temp_cost_cli_ot-supp-tot.transport-rubl    = buf_cost_ot-supp-tot.transport-rubl
                        temp_cost_cli_ot-supp-tot.other-rubl        = buf_cost_ot-supp-tot.other-rubl
                        temp_cost_cli_ot-supp-tot.excise-rubl       = buf_cost_ot-supp-tot.excise-rubl
                        temp_cost_cli_ot-supp-tot.sum-base          = buf_cost_ot-supp-tot.sum-base
                        temp_cost_cli_ot-supp-tot.vat-base          = buf_cost_ot-supp-tot.vat-base
                        temp_cost_cli_ot-supp-tot.slt-base          = buf_cost_ot-supp-tot.slt-base
                        temp_cost_cli_ot-supp-tot.road-tax-base     = buf_cost_ot-supp-tot.road-tax-base
                        temp_cost_cli_ot-supp-tot.transport-base    = buf_cost_ot-supp-tot.transport-base
                        temp_cost_cli_ot-supp-tot.other-base        = buf_cost_ot-supp-tot.other-base
                        temp_cost_cli_ot-supp-tot.excise-base       = buf_cost_ot-supp-tot.excise-base
                        temp_cost_cli_ot-supp-tot.fact-qnty         = buf_cost_ot-supp-tot.fact-qnty
                    .
                end.
            end.
        end.
        for each temp_cost_cat-id_ot-supp-line no-lock
        on error undo, return error
        :
            delete temp_cost_cat-id_ot-supp-line.
        end.
        for each temp_cost_cli_ot-supp-line no-lock
        on error undo, return error
        :
            delete temp_cost_cli_ot-supp-line.
        end.
        for each buf_cost_ot-supp-line no-lock
            where buf_cost_ot-supp-line.doc-code = p-doc-code
        on error undo, return error
        :
            if buf_cost_ot-supp-line.sum-type = 'cost':U + 'p':U
            then do:
                find first temp_cost_cat-id_ot-supp-line
                        where temp_cost_cat-id_ot-supp-line.artic      = buf_cost_ot-supp-line.artic
                        and temp_cost_cat-id_ot-supp-line.prod-type  = buf_cost_ot-supp-line.prod-type
                        and temp_cost_cat-id_ot-supp-line.prod-code  = buf_cost_ot-supp-line.prod-code
                        and temp_cost_cat-id_ot-supp-line.cat-id     = buf_cost_ot-supp-line.cat-id
                no-error.
                if not available temp_cost_cat-id_ot-supp-line
                then do:
                    create temp_cost_cat-id_ot-supp-line.
                    assign
                        temp_cost_cat-id_ot-supp-line.artic     = buf_cost_ot-supp-line.artic
                        temp_cost_cat-id_ot-supp-line.prod-type = buf_cost_ot-supp-line.prod-type
                        temp_cost_cat-id_ot-supp-line.prod-code = buf_cost_ot-supp-line.prod-code
                        temp_cost_cat-id_ot-supp-line.cat-id    = buf_cost_ot-supp-line.cat-id
                    .
                end.
                find first temp_cost_cli_ot-supp-line
                        where temp_cost_cli_ot-supp-line.artic      = buf_cost_ot-supp-line.artic
                        and temp_cost_cli_ot-supp-line.prod-type  = buf_cost_ot-supp-line.prod-type
                        and temp_cost_cli_ot-supp-line.prod-code  = buf_cost_ot-supp-line.prod-code
                        and temp_cost_cli_ot-supp-line.cat-id     = buf_cost_ot-supp-line.cat-id
                        and temp_cost_cli_ot-supp-line.cli-type   = buf_cost_ot-supp-line.cli-type
                        and temp_cost_cli_ot-supp-line.cli-code   = buf_cost_ot-supp-line.cli-code
                no-error.
                if not available temp_cost_cli_ot-supp-line
                then do:
                    create temp_cost_cli_ot-supp-line.
                    assign
                        temp_cost_cli_ot-supp-line.artic             = buf_cost_ot-supp-line.artic
                        temp_cost_cli_ot-supp-line.prod-type         = buf_cost_ot-supp-line.prod-type
                        temp_cost_cli_ot-supp-line.prod-code         = buf_cost_ot-supp-line.prod-code
                        temp_cost_cli_ot-supp-line.cat-id            = buf_cost_ot-supp-line.cat-id
                        temp_cost_cli_ot-supp-line.cli-type          = buf_cost_ot-supp-line.cli-type
                        temp_cost_cli_ot-supp-line.cli-code          = buf_cost_ot-supp-line.cli-code
                        temp_cost_cli_ot-supp-line.sum-rubl          = buf_cost_ot-supp-line.sum-rubl
                        temp_cost_cli_ot-supp-line.vat-rubl          = buf_cost_ot-supp-line.vat-rubl
                        temp_cost_cli_ot-supp-line.slt-rubl          = buf_cost_ot-supp-line.slt-rubl
                        temp_cost_cli_ot-supp-line.road-tax-rubl     = buf_cost_ot-supp-line.road-tax-rubl
                        temp_cost_cli_ot-supp-line.transport-rubl    = buf_cost_ot-supp-line.transport-rubl
                        temp_cost_cli_ot-supp-line.other-rubl        = buf_cost_ot-supp-line.other-rubl
                        temp_cost_cli_ot-supp-line.excise-rubl       = buf_cost_ot-supp-line.excise-rubl
                        temp_cost_cli_ot-supp-line.sum-base          = buf_cost_ot-supp-line.sum-base
                        temp_cost_cli_ot-supp-line.vat-base          = buf_cost_ot-supp-line.vat-base
                        temp_cost_cli_ot-supp-line.slt-base          = buf_cost_ot-supp-line.slt-base
                        temp_cost_cli_ot-supp-line.road-tax-base     = buf_cost_ot-supp-line.road-tax-base
                        temp_cost_cli_ot-supp-line.transport-base    = buf_cost_ot-supp-line.transport-base
                        temp_cost_cli_ot-supp-line.other-base        = buf_cost_ot-supp-line.other-base
                        temp_cost_cli_ot-supp-line.excise-base       = buf_cost_ot-supp-line.excise-base
                        temp_cost_cli_ot-supp-line.fact-qnty         = buf_cost_ot-supp-line.fact-qnty
                    .
                end.
                else do:
                    run wp-XMLWriteLog(  sLogFile,
                                                1,
                                        "*** WARN: *** Найдено больше одной записи ot-supp-line для документа "
                                        + string( p-doc-code )
                    ).
                end.
            end.
        end.
    end.
    else do:
    end.
    run wp-xmltagopen( 3, "saleSum", "" ).
    run wp-xmltagput( 4, "sumr",         string( abs( buf_ot-tot-crsa-loop.sum-rubl        ) ), 1 ).
    run wp-xmltagput( 4, "VATr",         string( abs( buf_ot-tot-crsa-loop.vat-rubl        ) ), 2 ).
    run wp-xmltagput( 4, "SLTr",         string( abs( buf_ot-tot-crsa-loop.slt-rubl        ) ), 2 ).
    run wp-xmltagput( 4, "roadTaxr",     string( abs( buf_ot-tot-crsa-loop.road-tax-rubl   ) ), 2 ).
    run wp-xmltagput( 4, "transportr",   string( abs( buf_ot-tot-crsa-loop.transport-rubl  ) ), 2 ).
    run wp-xmltagput( 4, "otherr",       string( abs( buf_ot-tot-crsa-loop.other-rubl      ) ), 2 ).
    run wp-xmltagput( 4, "exciser",      string( abs( buf_ot-tot-crsa-loop.excise-rubl     ) ), 2 ).
    run wp-xmltagput( 4, "sumb",         string( abs( buf_ot-tot-crsa-loop.sum-base        ) ), 2 ).
    run wp-xmltagput( 4, "VATb",         string( abs( buf_ot-tot-crsa-loop.vat-base        ) ), 2 ).
    run wp-xmltagput( 4, "SLTb",         string( abs( buf_ot-tot-crsa-loop.slt-base        ) ), 2 ).
    run wp-xmltagput( 4, "roadTaxb",     string( abs( buf_ot-tot-crsa-loop.road-tax-base   ) ), 2 ).
    run wp-xmltagput( 4, "transportb",   string( abs( buf_ot-tot-crsa-loop.transport-base  ) ), 2 ).
    run wp-xmltagput( 4, "otherb",       string( abs( buf_ot-tot-crsa-loop.other-base      ) ), 2 ).
    run wp-xmltagput( 4, "exciseb",      string( abs( buf_ot-tot-crsa-loop.excise-base     ) ), 2 ).
    run wp-xmltagclose( 3, "saleSum" ).
    if p-ext-doc-type = 'vt':U
    or p-ext-doc-type = 'vp':U
    or p-ext-doc-type = 'ap':U
    or p-ext-doc-type = 'mp':U
    then do:
        run utl/cuaddsum.p (
            input p-doc-code
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog(
                    input sLogFile
                , input 1
                , input substitute( "*** WARN: *** Не удалось проверить документ инвентаризации N: &1. &2. &3. &4"
                                    , p-doc-code
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                )
            ).
        end.
        run export-before-and-after-inv-trn in this-procedure (
                input p-doc-code
            , output v-exists-before
            , output v-exists-after
        ).
    end.
    if p-pay-code = yes
    then do:
        run wp-xmltagopen( 3, "paySum", "" ).
        for each temp_cost_cat-id_ot-supp-tot
        on error undo, return error
        :
            run wp-xmltagopen( 4,  string( temp_cost_cat-id_ot-supp-tot.cat-id ), "" ).
            for each temp_cost_cli_ot-supp-tot
            where temp_cost_cli_ot-supp-tot.cat-id = temp_cost_cat-id_ot-supp-tot.cat-id
            on error undo, return error
            :
                run wp-xmltagopen( 5, "firm", "" ).
                run wp-xmltagput( 6, "type", string( temp_cost_cli_ot-supp-tot.cli-type ), 2 ).
                run wp-xmltagput( 6, "code", string( temp_cost_cli_ot-supp-tot.cli-code ), 2 ).
                run wp-xmltagopen( 6, "cost", "" ).
                if temp_cost_cli_ot-supp-tot.sum-rubl < 0
                then do:
                    run wp-xmltagput( 8, "sign", "-1", 0 ).
                end.
                run wp-xmltagput( 7, "qnty",         string( abs( temp_cost_cli_ot-supp-tot.fact-qnty        ) ), 2 ).
                run wp-xmltagput( 7, "sumr",         string( bge-xml-normalize-dec( abs( temp_cost_cli_ot-supp-tot.sum-rubl ) ) ), 1 ).
                run wp-xmltagput( 7, "VATr",         string( abs( temp_cost_cli_ot-supp-tot.vat-rubl         ) ), 2 ).
                run wp-xmltagput( 7, "SLTr",         string( abs( temp_cost_cli_ot-supp-tot.slt-rubl         ) ), 2 ).
                run wp-xmltagput( 7, "roadTaxr",     string( abs( temp_cost_cli_ot-supp-tot.road-tax-rubl    ) ), 2 ).
                run wp-xmltagput( 7, "transportr",   string( abs( temp_cost_cli_ot-supp-tot.transport-rubl   ) ), 2 ).
                run wp-xmltagput( 7, "otherr",       string( abs( temp_cost_cli_ot-supp-tot.other-rubl       ) ), 2 ).
                run wp-xmltagput( 7, "exciser",      string( abs( temp_cost_cli_ot-supp-tot.excise-rubl      ) ), 2 ).
                run wp-xmltagput( 7, "sumb",         string( abs( temp_cost_cli_ot-supp-tot.sum-base         ) ), 2 ).
                run wp-xmltagput( 7, "VATb",         string( abs( temp_cost_cli_ot-supp-tot.vat-base         ) ), 2 ).
                run wp-xmltagput( 7, "SLTb",         string( abs( temp_cost_cli_ot-supp-tot.slt-base         ) ), 2 ).
                run wp-xmltagput( 7, "roadTaxb",     string( abs( temp_cost_cli_ot-supp-tot.road-tax-base    ) ), 2 ).
                run wp-xmltagput( 7, "transportb",   string( abs( temp_cost_cli_ot-supp-tot.transport-base   ) ), 2 ).
                run wp-xmltagput( 7, "otherb",       string( abs( temp_cost_cli_ot-supp-tot.other-base       ) ), 2 ).
                run wp-xmltagput( 7, "exciseb",      string( abs( temp_cost_cli_ot-supp-tot.excise-base      ) ), 2 ).
                run wp-xmltagclose( 6, "cost" ).
                find first buf_sale_ot-supp-tot no-lock
                    where buf_sale_ot-supp-tot.doc-code = p-doc-code
                    and buf_sale_ot-supp-tot.cli-type = temp_cost_cli_ot-supp-tot.cli-type
                    and buf_sale_ot-supp-tot.cli-code = temp_cost_cli_ot-supp-tot.cli-code
                    and buf_sale_ot-supp-tot.sum-type = 'sale':U
                    and buf_sale_ot-supp-tot.cat-id   = '##':U
                no-error.
                if available buf_sale_ot-supp-tot
                then do:
                    run wp-xmltagopen( 6, "sale" , "" ).
                    if buf_sale_ot-supp-tot.sum-rubl < 0
                    then do:
                        run wp-xmltagput( 8, "sign", "-1", 0 ).
                    end.
                    run wp-xmltagput( 7, "qnty",       string( abs( buf_sale_ot-supp-tot.fact-qnty      )                                                                         ), 2 ).
                    run wp-xmltagput( 7, "sumr",       string( bge-xml-normalize-dec( abs( buf_sale_ot-supp-tot.sum-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ) ), 1 ).
                    run wp-xmltagput( 7, "VATr",       string( abs( buf_sale_ot-supp-tot.vat-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "SLTr",       string( abs( buf_sale_ot-supp-tot.slt-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "roadTaxr",   string( abs( buf_sale_ot-supp-tot.road-tax-rubl  ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "transportr", string( abs( buf_sale_ot-supp-tot.transport-rubl ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "otherr",     string( abs( buf_sale_ot-supp-tot.other-rubl     ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "exciser",    string( abs( buf_sale_ot-supp-tot.excise-rubl    ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "sumb",       string( abs( buf_sale_ot-supp-tot.sum-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "VATb",       string( abs( buf_sale_ot-supp-tot.vat-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "SLTb",       string( abs( buf_sale_ot-supp-tot.slt-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "roadTaxb",   string( abs( buf_sale_ot-supp-tot.road-tax-base  ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "transportb", string( abs( buf_sale_ot-supp-tot.transport-base ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "otherb",     string( abs( buf_sale_ot-supp-tot.other-base     ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "exciseb",    string( abs( buf_sale_ot-supp-tot.excise-base    ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagclose( 6,  "sale" ).
                end.
                run wp-xmltagclose( 5, "firm" ).
            end.
            run wp-xmltagclose( 4,  string( temp_cost_cat-id_ot-supp-tot.cat-id ) ).
        end.
        run wp-xmltagclose( 3,  "paySum" ).
    end.
    for each buf_ot-line-crsa-loop no-lock
        where buf_ot-line-crsa-loop.doc-code = p-doc-code
            and ( buf_ot-line-crsa-loop.sum-type = 'crsa':U
            or buf_ot-line-crsa-loop.sum-type = 'cgsr':U )
    on error undo, return error
    :
        run wp-xmltagopen( 3, "linedoc", "" ).
        find first buf_goods no-lock
          where     buf_goods.artic      = buf_ot-line-crsa-loop.artic
                and buf_goods.prod-type  = buf_ot-line-crsa-loop.prod-type
                and buf_goods.prod-code  = buf_ot-line-crsa-loop.prod-code
        no-error.
        if available buf_goods
        then do:
            run fill_bge-xml_goods in this-procedure (
                  input p-parent-proc
                , input buf_goods.gds-code
            ).
            run wp-xmltagput( 4, "good",      string( buf_goods.gds-code )    , 0 ).
            if p-ext-doc-type = 'vp':U
            then do :
              find first buf_parts-root no-lock where buf_parts-root.doc-code = p-doc-code
                                                  and buf_parts-root.gds-code = buf_goods.gds-code
                                                  no-error .
              if available buf_parts-root
              and buf_parts-root.orig-gds-code > 0
              then
              run wp-xmltagput( 4, "orig-gds-code",      string( buf_parts-root.orig-gds-code ), 0 ).
            end.
            run wp-xmltagput( 4, "artic",     string( buf_goods.artic    )    , 0 ).
            run wp-xmltagput( 4, "prodtype",  string( buf_goods.prod-type)    , 0 ).
            run wp-xmltagput( 4, "prodcode",  string( buf_goods.prod-code)    , 0 ).
            run wp-xmltagput( 4, "type",      string( buf_goods.gds-type )    , 0 ).
        end.
        else do:
            run wp-xmltagput( 4, "good",    "", 0 ).
            run wp-xmltagput( 4, "artic"   , "" , 0 ).
            run wp-xmltagput( 4, "prodtype", "" , 0 ).
            run wp-xmltagput( 4, "prodcode", "" , 0 ).
            run wp-xmltagput( 4, "type",    "", 0 ).
        end.
        find first buf_units no-lock
                where buf_units.unit-name  = buf_goods.unit-base
        no-error.
        if available buf_units
        then do:
            run wp-xmltagput( 4, "unitType",    string( buf_units.type ), 0 ).
        end.
        else do:
                run wp-xmltagput( 4, "unitType",   "",   0 ).
        end.
        if p-ext-doc-type <> 'ot':U
        then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_ot-line-crsa-loop.artic
  ,  input buf_ot-line-crsa-loop.prod-type
  ,  input buf_ot-line-crsa-loop.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
            if v-bge-xml-bgeflold <> "oracle":u then do:
              if p-ext-doc-type = 'ie':U
              or p-ext-doc-type = 'ep':U
              or p-ext-doc-type = 'ee':U
              or p-ext-doc-type = 'pz':U
              then do:
                if available buf_goods then do:
                  run wp-xmltagput( 4, "deadline",  string( buf_goods.deadline ), 0 ).
                end.
                else do:
                  run wp-xmltagput( 4, "deadline",  "", 0 ).
                end.
              end.
            end.
            find first buf_doc-line no-lock
                where buf_doc-line.doc-code = p-doc-code
                    and buf_doc-line.artic      = buf_ot-line-crsa-loop.artic
                    and buf_doc-line.prod-type  = buf_ot-line-crsa-loop.prod-type
                    and buf_doc-line.prod-code  = buf_ot-line-crsa-loop.prod-code
            no-error.
            if available buf_doc-line
            then do:
                run wp-xmltagput( 4, "wait"         , string( buf_doc-line.wt-brutto        ), 0 ).
                run wp-xmltagput( 4, "place"        , string( buf_doc-line.num-place        ), 0 ).
                run wp-xmltagput( 4, "priceCli"     , string( buf_doc-line.price-cli        ), 0 ).
                run wp-xmltagput( 4, "cliBaseRate"  , string( buf_doc-line.cli-base-rate    ), 0 ).
                if v-is-petrol  = yes
                and v-is-pieces = no
                then do:
                    run get-petrol-weight in this-procedure
                    (     input p-ext-doc-type
                        , input recid( buf_doc-line )
                        , input p-out-code
                        , output v-petrol-weight
                        , output v-weight-not-specified
                    ).
                    if v-weight-not-specified = no
                    then do:
                        assign
                            v-petrol-density = abs ( if buf_ot-line-crsa-loop.fact-qnty = 0
                                                    then 0
                                                    else v-petrol-weight / buf_ot-line-crsa-loop.fact-qnty )
                        .
                        run wp-xmltagput( 4, "petrolWeight",   string( v-petrol-weight            ), 0 ).
                        run wp-xmltagput( 4, "petrolDensity",  trim(string( v-petrol-density , ">>9.9999999999")), 0 ).
                        run wp-xmltagput( 4, "quantityDoc",   string( buf_doc-line.doc-qnty            ), 0 ).
                        run wp-xmltagput( 4, "petrolDensityDoc",    trim(string( buf_doc-line.doc-density , ">>>>>>>>>9.9999999999")), 0 ).
                        find first buf_goods no-lock
                        where buf_goods.artic      = buf_doc-line.artic
                          and buf_goods.prod-type  = buf_doc-line.prod-type
                          and buf_goods.prod-code  = buf_doc-line.prod-code.
                  find first   doc-line-attr where doc-line-attr.doc-code = p-doc-code
                            and doc-line-attr.gds-code = buf_goods.gds-code
                            and doc-line-attr.attr-code = "n" no-lock no-error.
                        if available doc-line-attr then
                            assign
                                v-SectionNum = integer ( doc-line-attr.attr-value) .
                        else   v-SectionNum = 1 .
                        v-tank-vol = 0 .
                        v-tank-density  = 0.
                        v-tankweight = 0 .
                         do ii = 1 to v-SectionNum :
                            for each doc-line-attr where doc-line-attr.doc-code = p-doc-code
                                and doc-line-attr.gds-code = buf_goods.gds-code
                                and    (entry (1, doc-line-attr.attr-code, chr(4))) =  'tank-vol'
                                and (v-SectionNum = 1 or (num-entries (doc-line-attr.attr-code, chr(4)) > 1 and (entry (2, doc-line-attr.attr-code, chr(4))) = string (ii) and v-SectionNum > 1)):
                                assign
                                    v-tank-vol = v-tank-vol + decimal ( doc-line-attr.attr-value)  .
                            end.
                            for each doc-line-attr where doc-line-attr.doc-code = p-doc-code
                                and doc-line-attr.gds-code = buf_goods.gds-code
                                and    (entry (1, doc-line-attr.attr-code, chr(4))) =  'tank-vol'
                                and (v-SectionNum = 1 or (num-entries (doc-line-attr.attr-code, chr(4)) > 1 and (entry (2, doc-line-attr.attr-code, chr(4))) = string (ii) and v-SectionNum > 1)):
                                assign
                                    v-tank-density =    v-tank-density + decimal(doc-line-attr.attr-value) .
                            end.
                            for each doc-line-attr where doc-line-attr.doc-code = p-doc-code
                                and doc-line-attr.gds-code = buf_goods.gds-code
                                and    (entry (1, doc-line-attr.attr-code, chr(4))) =  'tank-weight'
                                and (v-SectionNum = 1 or (num-entries (doc-line-attr.attr-code, chr(4)) > 1 and (entry (2, doc-line-attr.attr-code, chr(4))) = string (ii) and v-SectionNum > 1)):
                                v-tankweight =  v-tankweight + decimal (doc-line-attr.attr-value).
                            end.
                        end.
                        if v-tank-vol <> 0 then
                            run wp-xmltagput( 4, "petrolTankVol",   trim(string(v-tank-vol , ">>>>>>>>>9.9999999999")), 0 ).
                        if v-tank-density <> 0 and v-tankweight  <> 0  then
                        do :
                            v-total-tank-density = v-tankweight / v-tank-density .
                            run wp-xmltagput( 4, "petrolTankDensity",    trim(string(v-total-tank-density , "->>>>>>>>>9.9999999999")), 0 ).
                        end.
                    end.
                define buffer buf_rvs-line      for ub.rvs-line .
                define buffer buf_rvs-doc       for ub.rvs-doc .
                for each buf_doc-pl where buf_doc-pl.obj-type = buf_doc-line.obj-type
                                      and buf_doc-pl.obj-code = buf_doc-line.obj-code
                                      and buf_doc-pl.out-code = buf_doc-line.doc-code
                                      and buf_doc-pl.gds-code = buf_goods.gds-code  :
                run wp-xmltagopen in this-procedure ( input 4, input "PLDoc", input "" ).
                run wp-xmltagput( 5, "PLCode",   string(buf_doc-pl.pl-code) , 0 ).
                run wp-xmltagput( 5, "PLQnty",  string(buf_doc-pl.fact-qnty) , 0 ).
                run wp-xmltagput( 5, "PLWeigth",  string(buf_doc-pl.cli-fact-qnty) , 0 ).
                run wp-xmltagput( 5, "PLDensity",  string( (buf_doc-pl.cli-fact-qnty / buf_doc-pl.fact-qnty), "->>>>>>>>>9.99") , 0 ).
                if p-need-doc-rvs
                and (p-ext-doc-type = 'ie':U or p-ext-doc-type = 'iv':U)
                then do :
                  for first buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_doc-line.doc-code
                                                  and buf_rvs-doc.rvs-type = 'перед_док':U,
                  first buf_rvs-line where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                       and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                       and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                       and buf_rvs-line.pl-code = buf_doc-pl.pl-code
                                       and buf_rvs-line.gds-code = buf_doc-pl.gds-code :
                    run wp-xmltagput( 5, "PLQntyBeforeDoc",  string(buf_rvs-line.state-measure-qnty) , 0 ).
                    run wp-xmltagput( 5, "PLWeigthBeforeDoc",  string(buf_rvs-line.state-measure-cli-qnty) , 0 ).
                  end .
                  for first buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_doc-line.doc-code
                                                  and buf_rvs-doc.rvs-type = 'после_док':U,
                  first buf_rvs-line where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                       and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                       and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                       and buf_rvs-line.pl-code = buf_doc-pl.pl-code
                                       and buf_rvs-line.gds-code = buf_doc-pl.gds-code :
                    run wp-xmltagput( 5, "PLQntyAfterDoc",  string(buf_rvs-line.state-measure-qnty) , 0 ).
                    run wp-xmltagput( 5, "PLWeigthAfterDoc",  string(buf_rvs-line.state-measure-cli-qnty) , 0 ).
                  end .
                end .
                run wp-xmltagclose in this-procedure ( input 4, input "PLDoc"  ).
                end.
                    end.
                end.
            else do:
                run wp-XMLWriteLog(  sLogFile, 1, "*** ERR: *** Не найдено строк документа " + string( p-doc-code ) ).
            end.
        end.
        else do:
          define variable v-price-prev as decimal   no-undo .
          assign
              v-price-prev = 0.0
          .
          find first buf_price-list no-lock
            where buf_price-list.doc-num    = p-doc-code
              and buf_price-list.main-price = yes
              and buf_price-list.artic      = buf_ot-line-crsa-loop.artic
              and buf_price-list.prod-type  = buf_ot-line-crsa-loop.prod-type
              and buf_price-list.prod-code  = buf_ot-line-crsa-loop.prod-code
          no-error.
          if available buf_price-list
          then do:
              define variable v-void-char     as character    no-undo.
              define variable v-void-dec      as decimal      no-undo.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_price-list.obj-type
  ,input  buf_price-list.obj-code
  ,input  buf_price-list.b-code
  ,input  0
  ,input  buf_price-list.fact-order
  ,output v-void-char
  ,output v-price-prev
  ,output v-void-dec
  ,output v-void-dec
  )  .
              run wp-xmltagput( 4, "priceListQnty", string( buf_price-list.doc-qnty   ), 0 ).
              run wp-xmltagput( 4, "priceSale"    , string( buf_price-list.price-sale ), 0 ).
          end.
          run wp-xmltagput( 4, "pricePrev"        , string( v-price-prev        ), 0 ).
          run export-bc-price in this-procedure ( input buf_price-list.obj-type
                                                , input buf_price-list.obj-code
                                                , input p-doc-code
                                                , input buf_price-list.b-code
                                                ) .
        end.
        if p-ext-doc-type = 'vt':U
        or p-ext-doc-type = 'vp':U
        or p-ext-doc-type = 'ap':U
        or p-ext-doc-type = 'mp':U
        then do:
            assign
                v-qnty = buf_ot-line-crsa-loop.fact-qnty
            .
        end.
        else do:
            assign
                v-qnty = abs( buf_ot-line-crsa-loop.fact-qnty )
            .
        end.
        run wp-xmltagput( 4, "quantity",   string( v-qnty ), 0 ).
        run wp-xmltagput( 4, "comment",    string( buf_goods.ps ), 0 ).
    if v-is-petrol  = yes
            and v-is-pieces = no
            then
        do:
            do ii = 1 to v-SectionNum :
                for each doc-line-attr where doc-line-attr.doc-code = p-doc-code
                    and doc-line-attr.gds-code = buf_goods.gds-code
                    and  not  doc-line-attr.attr-code = "n"
                    and (v-SectionNum = 1 or (num-entries (doc-line-attr.attr-code, chr(4)) > 1 and (entry (2, doc-line-attr.attr-code, chr(4))) = string (ii) and v-SectionNum > 1)):
                    case (entry (1, doc-line-attr.attr-code, chr(4))):
                        when 'section-name' then
                            do:
                                assign
                                    v-SectionName = doc-line-attr.attr-value no-error.
                            end.
                        when 'doc-qnty' then
                            do:
                                assign
                                    v-DocQnty = decimal (doc-line-attr.attr-value) no-error.
                            end.
                        when 'fact-qnty' then
                            do:
                                assign
                                    v-FactQnty = decimal (doc-line-attr.attr-value)
                                    v-CliQnty  = v-DocDensity * v-FactQnty no-error.
                            end.
                        when 'fact-dens' then
                            do:
                                assign
                                    v-FactDensity = decimal (doc-line-attr.attr-value) .
                            end.
                        when 'doc-dens' then
                            do:
                                assign
                                    v-DocDensity = decimal (doc-line-attr.attr-value)
                                    v-CliQnty    = v-DocDensity * v-FactQnty no-error.
                            end.
                        when 'tank-vol' then
                            do:
                                assign
                                    v-TankVol = decimal (doc-line-attr.attr-value) no-error.
                            end.
                        when 'tank-density' then
                            do:
                                assign
                                    v-TankDensity = decimal (doc-line-attr.attr-value) no-error.
                            end.
                        when 'tank-density-pomi' then
                            do:
                                assign
                                    v-TankDensityPomi = decimal (doc-line-attr.attr-value) no-error.
                            end.
                        when 'tank-vol-pomi' then
                            do:
                                assign
                                    v-TankVolPomi = decimal (doc-line-attr.attr-value) no-error.
                            end.
                    end  case.
                end.
                run wp-xmltagopen in this-procedure ( input 3, input "Tank", input "" ).
                run wp-xmltagput( 4, "TankNum",   v-SectionName , 0 ).
                run wp-xmltagput( 4, "TankDocVol",  string(v-DocQnty  ) , 0 ).
                run wp-xmltagput( 4, "TankDocDensity",  trim(string(v-DocDensity , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 4, "TankVol",  string(v-TankVol   ) , 0 ).
                run wp-xmltagput( 4, "TankDensity",  trim(string(v-TankDensity , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 5, "TankFactVol",  string(v-FactQnty ) , 0 ).
                run wp-xmltagput( 5, "TankFactDensity",  trim(string(v-FactDensity , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 4, "RdcDensity",  trim(string(v-TankDensityPomi , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 4, "RdcVol",  string( v-TankVolPomi) , 0 ).
                run wp-xmltagclose in this-procedure ( input 3, input "Tank"  ).
            end.
        end.
        if p-ext-doc-type <> 'ot':U
        then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'empty-scale=request':u
  ,output v-scale-is-empty
  )  .
            if v-scale-is-empty = no
            then do:
                run wp-xmltagopen in this-procedure ( input 4, input "dtlSum", input "" ).
                run export-gds-dtl in this-procedure (
                      input p-doc-code
                    , input buf_goods.artic
                    , input buf_goods.prod-type
                    , input buf_goods.prod-code
                ).
                run wp-xmltagclose in this-procedure ( input 4, input "dtlSum" ).
            end.
            if p-cst = yes
            or p-parts = yes
            then do:
                if p-parts = yes
                then do:
                    run wp-xmltagopen in this-procedure ( input 4, input "partsSum", input "" ).
                end.
                assign
                    v-parts-cst-code = ""
                .
                assign v-sum-parts = 0 .
                for each buf_parts no-lock
                    where buf_parts.out-code   = p-doc-code
                        and buf_parts.obj-type   = buf_ot-line-crsa-loop.obj-type
                        and buf_parts.obj-code   = buf_ot-line-crsa-loop.obj-code
                        and buf_parts.prod-type  = buf_ot-line-crsa-loop.prod-type
                        and buf_parts.prod-code  = buf_ot-line-crsa-loop.prod-code
                        and buf_parts.artic      = buf_ot-line-crsa-loop.artic
                        and buf_parts.status_    = true
                on error undo, return error return-value
                :
                    if p-parts = yes
                    then do:
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
                        v-sum-parts = v-sum-parts + ((price-rubl-with-tax-loc / (100 + buf_parts.VAT-pc )) * buf_parts.VAT-pc)  * buf_parts.fact-qnty .
                        run export-part in this-procedure (
                              input ( if available buf_goods then buf_goods.gds-code else 0 )
                            , input rowid( buf_parts )
                            , input p-is-envd_
                        ).
                    end.
                    if p-cst = yes
                    then do:
                        assign
                            v-parts-cst-code = v-parts-cst-code
                                                + ( if ( v-cst-code <> ?
                                                    and trim( v-cst-code )   <> ""
                                                    and trim( v-parts-cst-code ) <> "" )
                                                    then "; "
                                                    else ""  )
                                                + v-cst-code
                        .
                    end.
                end.
                if p-parts = yes
                then do:
                    run wp-xmltagclose in this-procedure ( input 4, input "partsSum" ).
                end.
                if p-cst = yes
                then do:
                    run wp-xmltagput in this-procedure ( 4, "CSTCode",    string( v-parts-cst-code ), 0 ).
                end.
            end.
            if p-chk-pay-code = yes
            and available buf_doc-line
            and available buf_goods
            then do:
                run export-chk-pay-code in this-procedure (
                      input p-ext-doc-type
                    , input recid( buf_doc-line )
                    , input p-out-code
                    , input p-pay-desk
                    , input v-is-petrol
                    , input v-is-pieces
                ).
            end.
        end.
        else do:
        end.
        if available buf_ot-tot-sale
        then do:
            find first buf_ot-line-sale no-lock
                    where buf_ot-line-sale.doc-code    = p-doc-code
                    and buf_ot-line-sale.artic       = buf_ot-line-crsa-loop.artic
                    and buf_ot-line-sale.prod-type   = buf_ot-line-crsa-loop.prod-type
                    and buf_ot-line-sale.prod-code   = buf_ot-line-crsa-loop.prod-code
                    and buf_ot-line-sale.sum-type    = buf_ot-tot-sale.sum-type
            no-error.
            if available buf_ot-line-sale
            then do:
                run wp-xmltagopen( 4, "docSum", "" ).
                run wp-xmltagput( 5, "rateVAT",    string( entry( 1, buf_ot-line-sale.cat-id ) ), 2 ).
                run wp-xmltagput( 5, "rateSLT",    string( entry( 2, buf_ot-line-sale.cat-id ) ), 2 ).
                if p-ext-doc-type = 'ot':U
                then do:
                        run wp-xmltagput( 5, "sumr",       string( buf_ot-line-sale.sum-rubl         ), 1 ).
                        if p-is-envd_ eq NO then
                          run wp-xmltagput( 5, "VATr",       string( buf_ot-line-sale.vat-rubl       ), 2 ).
                        else
                          run wp-xmltagput( 5, "VATr",       string( v-sum-parts                     ), 2 ).
                        run wp-xmltagput( 5, "SLTr",       string( buf_ot-line-sale.slt-rubl         ), 2 ).
                        run wp-xmltagput( 5, "roadTaxr",   string( buf_ot-line-sale.road-tax-rubl    ), 2 ).
                        run wp-xmltagput( 5, "transportr", string( buf_ot-line-sale.transport-rubl   ), 2 ).
                        run wp-xmltagput( 5, "otherr",     string( buf_ot-line-sale.other-rubl       ), 2 ).
                        run wp-xmltagput( 5, "exciser",    string( buf_ot-line-sale.excise-rubl      ), 2 ).
                        run wp-xmltagput( 5, "sumb",       string( buf_ot-line-sale.sum-base         ), 2 ).
                        run wp-xmltagput( 5, "VATb",       string( buf_ot-line-sale.vat-base         ), 2 ).
                        run wp-xmltagput( 5, "SLTb",       string( buf_ot-line-sale.slt-base         ), 2 ).
                        run wp-xmltagput( 5, "roadTaxb",   string( buf_ot-line-sale.road-tax-base    ), 2 ).
                        run wp-xmltagput( 5, "transportb", string( buf_ot-line-sale.transport-base   ), 2 ).
                        run wp-xmltagput( 5, "otherb",     string( buf_ot-line-sale.other-base       ), 2 ).
                        run wp-xmltagput( 5, "exciseb",    string( buf_ot-line-sale.excise-base      ), 2 ).
                end.
                else do:
                        run wp-xmltagput( 5, "sumr",       string( abs( buf_ot-line-sale.sum-rubl       ) ), 1 ).
                        if p-is-envd_ eq NO then
                          run wp-xmltagput( 5, "VATr",       string( abs( buf_ot-line-sale.vat-rubl     ) ), 2 ).
                        else
                          run wp-xmltagput( 5, "VATr",       string( v-sum-parts                        ), 2 ).
                        run wp-xmltagput( 5, "SLTr",       string( abs( buf_ot-line-sale.slt-rubl       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxr",   string( abs( buf_ot-line-sale.road-tax-rubl  ) ), 2 ).
                        run wp-xmltagput( 5, "transportr", string( abs( buf_ot-line-sale.transport-rubl ) ), 2 ).
                        run wp-xmltagput( 5, "otherr",     string( abs( buf_ot-line-sale.other-rubl     ) ), 2 ).
                        run wp-xmltagput( 5, "exciser",    string( abs( buf_ot-line-sale.excise-rubl    ) ), 2 ).
                        run wp-xmltagput( 5, "sumb",       string( abs( buf_ot-line-sale.sum-base       ) ), 2 ).
                        run wp-xmltagput( 5, "VATb",       string( abs( buf_ot-line-sale.vat-base       ) ), 2 ).
                        run wp-xmltagput( 5, "SLTb",       string( abs( buf_ot-line-sale.slt-base       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxb",   string( abs( buf_ot-line-sale.road-tax-base  ) ), 2 ).
                        run wp-xmltagput( 5, "transportb", string( abs( buf_ot-line-sale.transport-base ) ), 2 ).
                        run wp-xmltagput( 5, "otherb",     string( abs( buf_ot-line-sale.other-base     ) ), 2 ).
                        run wp-xmltagput( 5, "exciseb",    string( abs( buf_ot-line-sale.excise-base    ) ), 2 ).
                end.
                run wp-xmltagclose( 4, "docSum" ).
            end.
            else do:
            end.
        end.
        if p-ext-doc-type <> 'ot':U
        then do:
            if available buf_ot-tot-cost
            then do:
                find first buf_ot-line-cost no-lock
                        where buf_ot-line-cost.doc-code   = p-doc-code
                        and buf_ot-line-cost.artic      = buf_ot-line-crsa-loop.artic
                        and buf_ot-line-cost.prod-type  = buf_ot-line-crsa-loop.prod-type
                        and buf_ot-line-cost.prod-code  = buf_ot-line-crsa-loop.prod-code
                        and buf_ot-line-cost.sum-type   = buf_ot-tot-cost.sum-type
                no-error.
                if available buf_ot-line-cost
                then do:
                        run wp-xmltagopen( 4, "costSum", "" ).
                        run wp-xmltagput( 5, "sumr",       string( abs( buf_ot-line-cost.sum-rubl       ) ), 1 ).
                        if p-is-envd_ eq NO then
                          run wp-xmltagput( 5, "VATr",       string( abs( buf_ot-line-cost.vat-rubl     ) ), 2 ).
                        else
                          run wp-xmltagput( 5, "VATr",       string( v-sum-parts                        ), 2 ).
                        run wp-xmltagput( 5, "SLTr",       string( abs( buf_ot-line-cost.slt-rubl       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxr",   string( abs( buf_ot-line-cost.road-tax-rubl  ) ), 2 ).
                        run wp-xmltagput( 5, "transportr", string( abs( buf_ot-line-cost.transport-rubl ) ), 2 ).
                        run wp-xmltagput( 5, "otherr",     string( abs( buf_ot-line-cost.other-rubl     ) ), 2 ).
                        run wp-xmltagput( 5, "exciser",    string( abs( buf_ot-line-cost.excise-rubl    ) ), 2 ).
                        run wp-xmltagput( 5, "sumb",       string( abs( buf_ot-line-cost.sum-base       ) ), 2 ).
                        run wp-xmltagput( 5, "VATb",       string( abs( buf_ot-line-cost.vat-base       ) ), 2 ).
                        run wp-xmltagput( 5, "SLTb",       string( abs( buf_ot-line-cost.slt-base       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxb",   string( abs( buf_ot-line-cost.road-tax-base  ) ), 2 ).
                        run wp-xmltagput( 5, "transportb", string( abs( buf_ot-line-cost.transport-base ) ), 2 ).
                        run wp-xmltagput( 5, "otherb",     string( abs( buf_ot-line-cost.other-base     ) ), 2 ).
                        run wp-xmltagput( 5, "exciseb",    string( abs( buf_ot-line-cost.excise-base    ) ), 2 ).
                        run wp-xmltagclose( 4, "costSum" ).
                end.
                else do:
                    if ( buf_ot-line-crsa-loop.ext-doc-type = 'vt':U
                        or buf_ot-line-crsa-loop.ext-doc-type = 'vp':U
                        or buf_ot-line-crsa-loop.ext-doc-type = 'ap':U
                        or buf_ot-line-crsa-loop.ext-doc-type = 'mp':U )
                    and buf_ot-line-crsa-loop.fact-qnty = 0
                    then do:
                    end.
                    else do:
                    end.
                end.
            end.
            else do:
            end.
        end.
        else do:
        end.
        run wp-xmltagopen( 4, "saleSum", "" ).
        run wp-xmltagput( 5, "sumr",       string( abs( buf_ot-line-crsa-loop.sum-rubl       ) ), 1 ).
        run wp-xmltagput( 5, "VATr",       string( abs( buf_ot-line-crsa-loop.vat-rubl       ) ), 2 ).
        run wp-xmltagput( 5, "SLTr",       string( abs( buf_ot-line-crsa-loop.slt-rubl       ) ), 2 ).
        run wp-xmltagput( 5, "roadTaxr",   string( abs( buf_ot-line-crsa-loop.road-tax-rubl  ) ), 2 ).
        run wp-xmltagput( 5, "transportr", string( abs( buf_ot-line-crsa-loop.transport-rubl ) ), 2 ).
        run wp-xmltagput( 5, "otherr",     string( abs( buf_ot-line-crsa-loop.other-rubl     ) ), 2 ).
        run wp-xmltagput( 5, "exciser",    string( abs( buf_ot-line-crsa-loop.excise-rubl    ) ), 2 ).
        run wp-xmltagput( 5, "sumb",       string( abs( buf_ot-line-crsa-loop.sum-base       ) ), 2 ).
        run wp-xmltagput( 5, "VATb",       string( abs( buf_ot-line-crsa-loop.vat-base       ) ), 2 ).
        run wp-xmltagput( 5, "SLTb",       string( abs( buf_ot-line-crsa-loop.slt-base       ) ), 2 ).
        run wp-xmltagput( 5, "roadTaxb",   string( abs( buf_ot-line-crsa-loop.road-tax-base  ) ), 2 ).
        run wp-xmltagput( 5, "transportb", string( abs( buf_ot-line-crsa-loop.transport-base ) ), 2 ).
        run wp-xmltagput( 5, "otherb",     string( abs( buf_ot-line-crsa-loop.other-base     ) ), 2 ).
        run wp-xmltagput( 5, "exciseb",    string( abs( buf_ot-line-crsa-loop.excise-base    ) ), 2 ).
        run wp-xmltagclose( 4, "saleSum" ).
        if p-ext-doc-type = 'vt':U
        or p-ext-doc-type = 'vp':U
        or p-ext-doc-type = 'ap':U
        or p-ext-doc-type = 'mp':U
        then do:
            run export-before-and-after-inv-line in this-procedure (
                    input p-doc-code
                , input buf_goods.gds-code
                , input v-exists-before
                , input v-exists-after
                , input ( v-is-petrol = yes and v-is-pieces = no and v-weight-not-specified  = no )
                , input v-petrol-density
            ).
        end.
        if p-ext-doc-type <> 'ot':U
        then do:
            if p-pay-code = yes
            then do:
                run wp-xmltagopen( 4, "paySum", "" ).
                for each temp_cost_cat-id_ot-supp-line
                    where temp_cost_cat-id_ot-supp-line.artic        = buf_ot-line-crsa-loop.artic
                        and temp_cost_cat-id_ot-supp-line.prod-type    = buf_ot-line-crsa-loop.prod-type
                        and temp_cost_cat-id_ot-supp-line.prod-code    = buf_ot-line-crsa-loop.prod-code
                on error undo, return error
                :
                    run wp-xmltagopen( 5, string( temp_cost_cat-id_ot-supp-line.cat-id ), "" ).
                    for each temp_cost_cli_ot-supp-line
                    where temp_cost_cli_ot-supp-line.artic        = temp_cost_cat-id_ot-supp-line.artic
                        and temp_cost_cli_ot-supp-line.prod-type  = temp_cost_cat-id_ot-supp-line.prod-type
                        and temp_cost_cli_ot-supp-line.prod-code  = temp_cost_cat-id_ot-supp-line.prod-code
                        and temp_cost_cli_ot-supp-line.cat-id     = temp_cost_cat-id_ot-supp-line.cat-id
                    on error undo, return error
                    :
                        run wp-xmltagopen( 6,  "firm", "" ).
                        run wp-xmltagput( 7, "type", string( temp_cost_cli_ot-supp-line.cli-type ), 2 ).
                        run wp-xmltagput( 7, "code", string( temp_cost_cli_ot-supp-line.cli-code ), 2 ).
                        run wp-xmltagopen( 7, "cost" ,"" ).
                        if temp_cost_cli_ot-supp-line.sum-rubl < 0
                        then do:
                            run wp-xmltagput( 8, "sign", "-1", 0 ).
                        end.
                        run wp-xmltagput( 8, "qnty",        string( abs( temp_cost_cli_ot-supp-line.fact-qnty        ) ), 2 ).
                        run wp-xmltagput( 8, "sumr",        string( abs( temp_cost_cli_ot-supp-line.sum-rubl         ) ), 1 ).
                        run wp-xmltagput( 8, "VATr",        string( abs( temp_cost_cli_ot-supp-line.vat-rubl         ) ), 2 ).
                        run wp-xmltagput( 8, "SLTr",        string( abs( temp_cost_cli_ot-supp-line.slt-rubl         ) ), 2 ).
                        run wp-xmltagput( 8, "roadTaxr",    string( abs( temp_cost_cli_ot-supp-line.road-tax-rubl    ) ), 2 ).
                        run wp-xmltagput( 8, "transportr",  string( abs( temp_cost_cli_ot-supp-line.transport-rubl   ) ), 2 ).
                        run wp-xmltagput( 8, "otherr",      string( abs( temp_cost_cli_ot-supp-line.other-rubl       ) ), 2 ).
                        run wp-xmltagput( 8, "exciser",     string( abs( temp_cost_cli_ot-supp-line.excise-rubl      ) ), 2 ).
                        run wp-xmltagput( 8, "sumb",        string( abs( temp_cost_cli_ot-supp-line.sum-base         ) ), 2 ).
                        run wp-xmltagput( 8, "VATb",        string( abs( temp_cost_cli_ot-supp-line.vat-base         ) ), 2 ).
                        run wp-xmltagput( 8, "SLTb",        string( abs( temp_cost_cli_ot-supp-line.slt-base         ) ), 2 ).
                        run wp-xmltagput( 8, "roadTaxb",    string( abs( temp_cost_cli_ot-supp-line.road-tax-base    ) ), 2 ).
                        run wp-xmltagput( 8, "transportb",  string( abs( temp_cost_cli_ot-supp-line.transport-base   ) ), 2 ).
                        run wp-xmltagput( 8, "otherb",      string( abs( temp_cost_cli_ot-supp-line.other-base       ) ), 2 ).
                        run wp-xmltagput( 8, "exciseb",     string( abs( temp_cost_cli_ot-supp-line.excise-base      ) ), 2 ).
                        run wp-xmltagclose( 7,  "cost" ).
                        find first buf_sale_ot-supp-line no-lock
                                where buf_sale_ot-supp-line.doc-code    = p-doc-code
                                and buf_sale_ot-supp-line.cli-type    = temp_cost_cli_ot-supp-line.cli-type
                                and buf_sale_ot-supp-line.cli-code    = temp_cost_cli_ot-supp-line.cli-code
                                and buf_sale_ot-supp-line.artic       = temp_cost_cli_ot-supp-line.artic
                                and buf_sale_ot-supp-line.prod-type   = temp_cost_cli_ot-supp-line.prod-type
                                and buf_sale_ot-supp-line.prod-code   = temp_cost_cli_ot-supp-line.prod-code
                                and buf_sale_ot-supp-line.sum-type    = 'sale':U
                                and buf_sale_ot-supp-line.cat-id      = '##':U
                        no-error.
                        if available buf_sale_ot-supp-line
                        then do:
                            run wp-xmltagopen( 7, "sale", "" ).
                            if buf_sale_ot-supp-line.sum-rubl < 0
                            then do:
                                run wp-xmltagput( 8, "sign", "-1", 0 ).
                            end.
                            run wp-xmltagput( 8, "qnty",       string( abs( buf_sale_ot-supp-line.fact-qnty        )                                                                           ), 2 ).
                            run wp-xmltagput( 8, "sumr",       string( bge-xml-normalize-dec( abs( buf_sale_ot-supp-line.sum-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ) ), 1 ).
                            run wp-xmltagput( 8, "VATr",       string( abs( buf_sale_ot-supp-line.vat-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "SLTr",       string( abs( buf_sale_ot-supp-line.slt-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "roadTaxr",   string( abs( buf_sale_ot-supp-line.road-tax-rubl    ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "transportr", string( abs( buf_sale_ot-supp-line.transport-rubl   ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "otherr",     string( abs( buf_sale_ot-supp-line.other-rubl       ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "exciser",    string( abs( buf_sale_ot-supp-line.excise-rubl      ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "sumb",       string( abs( buf_sale_ot-supp-line.sum-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "VATb",       string( abs( buf_sale_ot-supp-line.vat-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "SLTb",       string( abs( buf_sale_ot-supp-line.slt-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "roadTaxb",   string( abs( buf_sale_ot-supp-line.road-tax-base    ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "transportb", string( abs( buf_sale_ot-supp-line.transport-base   ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "otherb",     string( abs( buf_sale_ot-supp-line.other-base       ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "exciseb",    string( abs( buf_sale_ot-supp-line.excise-base      ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagclose( 7, "sale" ).
                        end.
                        run wp-xmltagclose( 6,  "firm" ).
                    end.
                    run wp-xmltagclose( 5, string( temp_cost_cat-id_ot-supp-line.cat-id ) ).
                end.
                run wp-xmltagclose( 4, "paySum" ).
            end.
        end.
        else do:
        end.
        run wp-xmltagclose( 3, "linedoc" ).
    end.
    if p-need-chk = yes
    then do:
        if p-ext-doc-type = 'es':U
        or p-ext-doc-type = 'rs':U
        then do:
            run export-checks in this-procedure (
                    input p-ext-doc-type
                , input p-doc-code
                , input v-obj-type
                , input v-obj-code
            ).
        end.
    end.
    run wp-xmltagclose( 2, "operation" ).
end.
end procedure.
procedure export-before-and-after-inv-trn :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define output parameter p-exists-before as logical      no-undo.
define output parameter p-exists-after  as logical      no-undo.
    define variable v-attr-value    as character     no-undo.
    define variable v-attr-type     as character     no-undo.
    define buffer buf_trn-doc-sum       for ub.trn-doc-sum.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'addsum':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    if lookup( 'bd':U, v-attr-value ) <> 0
    then do:
        assign
            p-exists-before = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = 'bd':U
        no-error.
        if available buf_trn-doc-sum
        then do:
            run wp-xmltagopen( input 3, input "beforeSum", input "" ).
            run wp-xmltagput( input 4, input "qnty", input string( buf_trn-doc-sum.fact-qnty ) , 2 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_trn-doc-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_trn-doc-sum.crsa-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_trn-doc-sum.crsa-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_trn-doc-sum.crsa-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_trn-doc-sum.crsa-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_trn-doc-sum.crsa-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_trn-doc-sum.crsa-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_trn-doc-sum.crsa-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_trn-doc-sum.crsa-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_trn-doc-sum.crsa-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_trn-doc-sum.crsa-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_trn-doc-sum.crsa-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_trn-doc-sum.crsa-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_trn-doc-sum.crsa-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_trn-doc-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_trn-doc-sum.cost-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_trn-doc-sum.cost-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_trn-doc-sum.cost-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_trn-doc-sum.cost-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_trn-doc-sum.cost-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_trn-doc-sum.cost-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_trn-doc-sum.cost-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_trn-doc-sum.cost-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_trn-doc-sum.cost-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_trn-doc-sum.cost-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_trn-doc-sum.cost-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_trn-doc-sum.cost-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_trn-doc-sum.cost-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "beforeSum" ).
        end.
        else do:
            run wp-XMLWriteLog( input sLogFile, input 1, input "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = 'bd':U для документа " + string( p-doc-code ) ).
        end.
    end.
    if lookup( 'ad':U, v-attr-value ) <> 0
    then do:
        assign
            p-exists-after  = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = 'ad':U
        no-error.
        if available buf_trn-doc-sum
        then do:
            run wp-xmltagopen( input 3, input "afterSum", input "" ).
            run wp-xmltagput( input 4, input "qnty", input string( buf_trn-doc-sum.fact-qnty ), input 2 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_trn-doc-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_trn-doc-sum.crsa-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_trn-doc-sum.crsa-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_trn-doc-sum.crsa-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_trn-doc-sum.crsa-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_trn-doc-sum.crsa-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_trn-doc-sum.crsa-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_trn-doc-sum.crsa-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_trn-doc-sum.crsa-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_trn-doc-sum.crsa-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_trn-doc-sum.crsa-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_trn-doc-sum.crsa-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_trn-doc-sum.crsa-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_trn-doc-sum.crsa-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_trn-doc-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_trn-doc-sum.cost-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_trn-doc-sum.cost-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_trn-doc-sum.cost-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_trn-doc-sum.cost-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_trn-doc-sum.cost-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_trn-doc-sum.cost-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_trn-doc-sum.cost-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_trn-doc-sum.cost-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_trn-doc-sum.cost-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_trn-doc-sum.cost-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_trn-doc-sum.cost-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_trn-doc-sum.cost-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_trn-doc-sum.cost-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "afterSum" ).
        end.
        else do:
            run wp-XMLWriteLog( input sLogFile, input 1, input "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = 'ad':U для документа " + string( p-doc-code ) ).
        end.
    end.
end.
end procedure.
procedure export-before-and-after-inv-line :
do
on error undo, return error
:
define input parameter p-doc-code           as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-exists-before      as logical      no-undo.
define input parameter p-exists-after       as logical      no-undo.
define input parameter p-need-petrol-weight as logical      no-undo.
define input parameter p-petrol-density     as decimal      no-undo.
    define buffer buf_doc-line-sum      for ub.doc-line-sum.
    if p-exists-before = yes
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = 'bd':U
        no-error.
        if available buf_doc-line-sum
        then do:
            run wp-xmltagput( input 3, input "quantityBefore", input string( buf_doc-line-sum.fact-qnty ), input 1 ).
            if p-need-petrol-weight = yes
            then do:
                run wp-xmltagput( input 3, input "petrolWeightBefore", input string( buf_doc-line-sum.fact-qnty * p-petrol-density ), input 0 ).
            end.
            run wp-xmltagopen( input 3, input "beforeSum", input "" ).
                run wp-xmltagput( input 4, input "qnty", input string( buf_doc-line-sum.fact-qnty ), input 1 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.crsa-vat-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.crsa-slt-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.crsa-transport-rubl ), input 1 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.crsa-other-rubl     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.crsa-excise-rubl    ), input 1 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.crsa-sum-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.crsa-vat-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.crsa-slt-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.crsa-road-tax-base  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.crsa-transport-base ), input 1 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.crsa-other-base     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.crsa-excise-base    ), input 1 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.cost-vat-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.cost-slt-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.cost-transport-rubl ), input 1 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.cost-other-rubl     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.cost-excise-rubl    ), input 1 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.cost-sum-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.cost-vat-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.cost-slt-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.cost-road-tax-base  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.cost-transport-base ), input 1 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.cost-other-base     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.cost-excise-base    ), input 1 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "beforeSum" ).
        end.
        else do:
            run wp-XMLWriteLog( input sLogFile, input 1, input "*** ERR: *** Не найдена запись doc-line-sum с sum-type = 'bd':U для документа " + string( p-doc-code ) ).
        end.
    end.
    if p-exists-after = yes
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = 'ad':U
        no-error.
        if available buf_doc-line-sum
        then do:
            run wp-xmltagput( input 3, input "quantityAfter", input string( buf_doc-line-sum.fact-qnty ), input 1 ).
            if p-need-petrol-weight = yes
            then do:
                run wp-xmltagput( input 3, input "petrolWeightAfter",  input string( buf_doc-line-sum.fact-qnty * p-petrol-density ), input 0 ).
            end.
            run wp-xmltagopen( input 3, input "afterSum", input "" ).
              run wp-xmltagput( input 4, input "qnty", input string( buf_doc-line-sum.fact-qnty ), input 1 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.crsa-vat-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.crsa-slt-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.crsa-transport-rubl ), input 1 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.crsa-other-rubl     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.crsa-excise-rubl    ), input 1 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.crsa-sum-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.crsa-vat-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.crsa-slt-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.crsa-road-tax-base  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.crsa-transport-base ), input 1 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.crsa-other-base     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.crsa-excise-base    ), input 1 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.cost-vat-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.cost-slt-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.cost-transport-rubl ), input 1 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.cost-other-rubl     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.cost-excise-rubl    ), input 1 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.cost-sum-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.cost-vat-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.cost-slt-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.cost-road-tax-base  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.cost-transport-base ), input 1 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.cost-other-base     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.cost-excise-base    ), input 1 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "afterSum" ).
        end.
        else do:
            run wp-XMLWriteLog( input sLogFile, input 1, input "*** ERR: *** Не найдена запись doc-line-sum с sum-type = 'ad':U для документа " + string( p-doc-code ) ).
        end.
    end.
end.
end procedure.
procedure get-petrol-weight :
define input parameter p-ext-doc-type           as character    no-undo.
define input parameter p-doc-line-recid         as recid        no-undo.
define input parameter p-trn-doc-out-code       as character    no-undo.
define output parameter p-petrol-weight         as decimal      no-undo.
define output parameter p-weight-not-specified  as logical      no-undo.
    define variable v-rvs-code              as character     no-undo.
    define variable v-found-last-rvs-doc    as logical       no-undo.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_rvs-doc       for ub.rvs-doc.
    define buffer buf_rvs-line      for ub.rvs-line.
    define buffer buf_goods         for ub.goods.
    define buffer buf_doc-pl        for ub.doc-pl.
    define buffer buf_inv-line      for ub.inv-line.
do
for buf_doc-line
  , buf_rvs-doc
  , buf_rvs-line
  , buf_goods
  , buf_doc-pl
  , buf_inv-line
on error undo, return error
:
    find first buf_doc-line no-lock
        where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_doc-line.artic
           and buf_goods.prod-type  = buf_doc-line.prod-type
           and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    assign
        p-weight-not-specified = yes
    .
    find first buf_inv-line no-lock
         where buf_inv-line.doc-code    = buf_doc-line.doc-code
           and buf_inv-line.artic       = buf_doc-line.artic
           and buf_inv-line.prod-type   = buf_doc-line.prod-type
           and buf_inv-line.prod-code   = buf_doc-line.prod-code
    no-error.
    if available buf_inv-line
    then do:
        case p-ext-doc-type:
            when 'ie':U
            or when 're':U
            or when 'we':U
            or when 'ie':U
            or when 'rs':U
            or when 'ep':U
            or when 'es':U
            then do:
                assign
                    p-petrol-weight        = buf_inv-line.wast-cli-qnty
                    p-weight-not-specified = no
                .
            end.
            when 'vt':U
            or when 'vp':U
            or when 'ap':U
            or when 'mp':U
            then do:
                assign
                    p-petrol-weight        = buf_doc-line.cli-qnty
                    p-weight-not-specified = no
                .
            end.
            otherwise do:
                assign
                    p-weight-not-specified = yes
                .
            end.
        end case.
    end.
end.
end procedure.
procedure get-cash-pay :
  do
  on error undo, return error
  :
  define input parameter p-ext-doc-type           as character    no-undo.
  define input parameter p-doc-line-recid         as recid        no-undo.
  define input parameter p-trn-doc-out-code       as character    no-undo.
  define output parameter p-cash-pay-not-specified  as logical      no-undo.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_goods         for ub.goods.
    find first buf_doc-line no-lock
        where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_doc-line.artic
           and buf_goods.prod-type  = buf_doc-line.prod-type
           and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    assign
        p-cash-pay-not-specified = yes
    .
    case p-ext-doc-type:
        when 'es':U
        then do:
            assign
                p-cash-pay-not-specified = no
            .
        end.
        when 'rs':U
        then do:
            assign
                p-cash-pay-not-specified = no
            .
        end.
        otherwise do:
            assign
                p-cash-pay-not-specified = yes
            .
        end.
      END CASE.
  end.
end procedure.
procedure get-inkas-pay-desk :
  define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
  do for buf_inkas-pay-desk
  on error undo, return error
  :
  define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
  define input parameter p-obj-type   like ub.inkas.obj-type no-undo .
  define input parameter p-obj-code   like ub.inkas.obj-code no-undo .
  define input parameter p-inkas-pay-desk-type like ub.inkas-pay-desk.doc-type no-undo .
    if can-find( first buf_inkas-pay-desk  NO-LOCK WHERE
                       buf_inkas-pay-desk.inkas-code = p-inkas-code ) then.
    else do:
      run trg/inkpdcr.p (
                     p-inkas-code
                    ,p-obj-type
                    ,p-obj-code
      ) no-error .
      if error-status:error then do:
        return error.
      end.
    end.
    for each temp_inkas-pay
    :
        delete temp_inkas-pay.
    end.
    for each buf_inkas-pay-desk no-lock
       where buf_inkas-pay-desk.inkas-code = p-inkas-code
         and buf_inkas-pay-desk.doc-type = p-inkas-pay-desk-type
    break by buf_inkas-pay-desk.pay-code
    on error undo, return error
    :
        if first-of( buf_inkas-pay-desk.pay-code )
        then do:
            create temp_inkas-pay.
            assign
                temp_inkas-pay.pay-code  = buf_inkas-pay-desk.pay-code
                temp_inkas-pay.tot-base  = 0
                temp_inkas-pay.tot-rubl  = 0
                temp_inkas-pay.tot-sum   = 0
            .
        end.
        assign
            temp_inkas-pay.tot-base  = temp_inkas-pay.tot-base + buf_inkas-pay-desk.tot-base
            temp_inkas-pay.tot-rubl  = temp_inkas-pay.tot-rubl + buf_inkas-pay-desk.tot-rubl
            temp_inkas-pay.tot-sum   = temp_inkas-pay.tot-sum  + buf_inkas-pay-desk.tot-sum
        .
    end.
  end.
end procedure.
procedure export-checks :
define input parameter p-ext-doc-type   as character    no-undo.
define input parameter p-doc-code       as character    no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
    define variable v-write-off as logical no-undo .
    define buffer buf_chk-doc       for ub.chk-doc.
    define buffer buf_chk-doc-attr  for ub.chk-doc-attr.
    define buffer buf_chk-gds       for ub.chk-gds.
    define buffer buf_chk-pay       for ub.chk-pay.
    define buffer buf_chk-pay-attr  for ub.chk-pay-attr.
    define buffer buf_bar-code      for ub.bar-code.
    define buffer buf_goods         for ub.goods.
    define buffer buf_c-chk-doc     for ub.c-chk-doc.
    define buffer buf_chk-discnt    for ub.chk-discnt.
    define buffer buf_dis-card      for ub.dis-card.
    define buffer buf_chk-gds-pay   for ub.chk-gds-pay.
    define variable v-RRN               as character no-undo.
do
for buf_chk-doc
  , buf_chk-gds
  , buf_chk-pay
  , buf_bar-code
  , buf_goods
  , buf_c-chk-doc
  , buf_chk-discnt
  , buf_dis-card
on error undo, return error
:
    for each buf_chk-doc no-lock
       where buf_chk-doc.out-code = p-doc-code
    :
        if buf_chk-doc.correct = no then next.
        if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next.
        find first buf_dis-card no-lock
              where buf_dis-card.d-card = buf_chk-doc.d-card
        no-error.
        run wp-xmltagopen( input 3, input "check"   , input "" ).
        run wp-xmltagput( input 4, input "type"     , input string( buf_chk-doc.office   )                               , input 2 ).
        run wp-xmltagput( input 4, input "num"      , input string( buf_chk-doc.chk-num  )                               , input 2 ).
        run wp-xmltagput( input 4, input "doccode"  , input string( buf_chk-doc.doc-code )                               , input 2 ).
        run wp-xmltagput( input 4, input "desk"     , input string( buf_chk-doc.pay-desk )                               , input 2 ).
        run wp-xmltagput( input 4, input "date"     , input string( buf_chk-doc.chk-date, "99.99.9999" )                 , input 2 ).
        run wp-xmltagput( input 4, input "dateXml"  , input bge-xml-date( buf_chk-doc.chk-date )                         , input 2 ).
        run wp-xmltagput( input 4, input "time"     , input string( buf_chk-doc.chk-time, "HH:MM:SS" )                   , input 2 ).
        run wp-xmltagput( input 4, input "shiftDate", input string( buf_chk-doc.shift-date, "99.99.9999" )               , input 2 ).
        run wp-xmltagput( input 4, input "shiftDateXml", input bge-xml-date( buf_chk-doc.shift-date )                    , input 2 ).
        run wp-xmltagput( input 4, input "shiftNum" , input string( buf_chk-doc.shift-num )                              , input 2 ).
        run wp-xmltagput( input 4, input "dCard"    , input string( buf_chk-doc.d-card   )                               , input 2 ).
        if available buf_dis-card
        then do:
          run wp-xmltagput( input 4, input "dCardCliType" , input string( buf_dis-card.cli-type )                        , input 2 ).
          run wp-xmltagput( input 4, input "dCardCliCode" , input string( buf_dis-card.cli-code )                        , input 2 ).
        end.
        run wp-xmltagput( input 4, input "discnt"   , input string( buf_chk-doc.discnt   )                               , input 2 ).
        run wp-xmltagput( input 4, input "cashier"  , input string( buf_chk-doc.cashier  )                               , input 1 ).
        run wp-xmltagput( input 4, input "cashierPsnCode"  , input string( buf_chk-doc.cashier-psn-code  )               , input 1 ).
        run wp-xmltagput( input 4, input "salesMan" , input string( buf_chk-doc.sales-man )                              , input 2 ).
        run wp-xmltagput( input 4, input "zNumber"  , input string( buf_chk-doc.z-number )                               , input 2 ).
        find first buf_c-chk-doc
             where buf_c-chk-doc.doc-code   = buf_chk-doc.doc-code
               and buf_c-chk-doc.obj-type   = buf_chk-doc.obj-type
               and buf_c-chk-doc.obj-code   = buf_chk-doc.obj-code
               and buf_c-chk-doc.is-add     = yes
        use-index pi
        no-error.
        if available buf_c-chk-doc
        then do:
            run wp-xmltagput( input 4, input "manualMaked"  , input "yes":U                                , input 2 ).
        end.
        find first buf_c-chk-doc
             where buf_c-chk-doc.doc-code   = buf_chk-doc.doc-code
               and buf_c-chk-doc.obj-type   = buf_chk-doc.obj-type
               and buf_c-chk-doc.obj-code   = buf_chk-doc.obj-code
               and buf_c-chk-doc.is-add     = no
               and buf_c-chk-doc.is-del     = no
        use-index pi
        no-error.
        if available buf_c-chk-doc
        then do:
            run wp-xmltagput( input 4, input "manualChanged"  , input "yes":U                               , input 2 ).
        end.
        find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq buf_chk-doc.doc-code
                                      and buf_chk-doc-attr.attr-code eq "CHNumberKKT"
             no-lock no-error.
        if avail buf_chk-doc-attr
        then
           run wp-xmltagput( input 4, input "CHNumberKKT", input buf_chk-doc-attr.attr-value, input 2 ).
        find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq buf_chk-doc.doc-code
                                      and buf_chk-doc-attr.attr-code eq "CHNumberFN"
             no-lock no-error.
        if avail buf_chk-doc-attr
        then
           run wp-xmltagput( input 4, input "CHNumberFN", input buf_chk-doc-attr.attr-value, input 2 ).
        if buf_chk-doc.d-card <> "":U
        then do:
            if available buf_dis-card
            then do:
                run fill_bge-xml_dis-card in this-procedure (
                      input p-parent-proc
                    , input buf_chk-doc.d-card
                ).
                run fill_bge-xml_clients in this-procedure (
                      input p-parent-proc
                    , input buf_dis-card.cli-type
                    , input buf_dis-card.cli-code
                ).
            end.
        end.
        assign
            v-write-off = no
        .
        if buf_chk-doc.sub-discnt <> 0
        then do:
          if buf_chk-doc.chk-type = integer('96':U)
          then do:
            assign
                v-write-off = yes
            .
          end.
          else do:
            _for:
            for each buf_chk-gds no-lock where
                    buf_chk-gds.doc-code = buf_chk-doc.doc-code :
              if buf_Chk-gds.write-off-code <> ?
              and buf_Chk-gds.write-off-code <> 0 then do:
                assign
                v-write-off = yes.
                leave _for.
              end.
            end.
          end.
        end.
        if v-write-off then
        run wp-xmltagput( input 4, input "subDiscnt", input string( 0 )                                                  , input 2 ).
        else
        run wp-xmltagput( input 4, input "subDiscnt", input string( buf_chk-doc.sub-discnt )                             , input 2 ).
        run wp-xmltagput( input 4, input "totDoc"   , input string( buf_chk-doc.tot-doc )                                , input 2 ).
        for each buf_chk-gds no-lock
           where buf_chk-gds.doc-code = buf_chk-doc.doc-code
        :
            find first buf_bar-code no-lock
                 where buf_bar-code.b-code = buf_chk-gds.b-code
            .
            run wp-xmltagopen( input 4, input "checkGds", input "" ).
            run wp-xmltagput( input 5, input "gdsCode"      , input string( buf_bar-code.gds-code )     , input 2 ).
            run wp-xmltagput( input 5, input "qnty"         , input string( buf_chk-gds.doc-qnty )      , input 2 ).
            run wp-xmltagput( input 5, input "priceBase"    , input string( buf_chk-gds.price-base )    , input 2 ).
            run wp-xmltagput( input 5, input "priceService" , input string( buf_chk-gds.price-service ) , input 2 ).
            run wp-xmltagput( input 5, input "priceDiscnt"  , input string( buf_chk-gds.discnt )        , input 2 ).
            run wp-xmltagput( input 5, input "lineNum"      , input string( buf_chk-gds.line-num )      , input 2 ).
            run wp-xmltagput( input 5, input "pump"         , input string( buf_chk-gds.pump )          , input 2 ).
            run wp-xmltagput( input 5, input "pl"           , input string( buf_chk-gds.loc1)           , input 2 ).
            run wp-xmltagput( input 5, input "nozzle"       , input string( buf_chk-gds.nozzle-code)    , input 2 ).
            run wp-xmltagput( input 5, input "density"      , input string( buf_chk-gds.density)        , input 2 ).
            run wp-xmltagput( input 5, input "roadTax"      , input string( buf_chk-gds.road-tax )      , input 2 ).
            run wp-xmltagput( input 5, input "crcCode"      , input string( entry(1, buf_chk-gds.src-code, chr(4)) )      , input 2 ).
            run wp-xmltagput( input 5, input "srcQnty"      , input string( buf_chk-gds.src-qnty )      , input 2 ).
            run wp-xmltagput( input 5, input "srcPrice"     , input string( buf_chk-gds.src-price )     , input 2 ).
            run wp-xmltagput( input 5, input "VATRate"      , input string( buf_chk-gds.vat-pc      )   , input 2 ).
            run wp-xmltagput( input 5, input "VAT"          , input string( buf_chk-gds.vat-sum-rubl)   , input 2 ).
            run wp-xmltagclose( input 4, input "checkGds" ).
        end.
        for each buf_chk-pay no-lock
           where buf_chk-pay.doc-code = buf_chk-doc.doc-code
        :
            run wp-xmltagopen( input 4, input "checkPay", input "" ).
            run wp-xmltagput( input 5, input "payCode"      , input string( buf_chk-pay.pay-code )     , input 2 ).
            run wp-xmltagput( input 5, input "payCard"      , input string( buf_chk-pay.pay-card )     , input 2 ).
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
            run wp-xmltagput( input 5, input "OperationCode", input v-RRN                              , input 2 ).
            run wp-xmltagput( input 5, input "currCode"     , input string( buf_chk-pay.curr-code )    , input 0 ).
            run wp-xmltagput( input 5, input "sumBase"      , input string( buf_chk-pay.tot-base )     , input 2 ).
            run wp-xmltagput( input 5, input "sumRubl"      , input string( buf_chk-pay.tot-rubl )     , input 2 ).
            run wp-xmltagput( input 5, input "sumTot"       , input string( buf_chk-pay.tot-sum  )     , input 2 ).
            run wp-xmltagput( input 5, input "lineNum"      , input string( buf_chk-pay.line-num  )    , input 2 ).
            run wp-xmltagclose( input 4, input "checkPay" ).
        end.
        for each buf_chk-gds-pay no-lock
           where buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code
        :
            run wp-xmltagopen( input 4, input "checkGdsPay", input "" ).
            run wp-xmltagput( input 5, input "line-num"      , input string( buf_chk-gds-pay.line-num )     , input 2 ).
            run wp-xmltagput( input 5, input "cpline-num"    , input string( buf_chk-gds-pay.cpline-num )   , input 2 ).
            run wp-xmltagput( input 5, input "sum-rubl"      , input string( buf_chk-gds-pay.tot-r-b )      , input 2 ).
            run wp-xmltagput( input 5, input "CGPqnty"       , input string( buf_chk-gds-pay.eff-doc-qnty ) , input 2 ).
            run wp-xmltagput( input 5, input "pay-code"      , input string( buf_chk-gds-pay.pay-code )     , input 2 ).
            run wp-xmltagclose( input 4, input "checkGdsPay" ).
        end.
        for each buf_chk-discnt no-lock
          where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            and buf_chk-discnt.record-type = 0
        :
          run wp-xmltagopen in this-procedure ( input 4, input "checkDiscount"   , input "" ).
          run wp-xmltagput in this-procedure ( input 5, input "lineNum"          , input string( buf_chk-discnt.line-num )         , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntVName"      , input entry (lookup (string(buf_chk-discnt.value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U)                          , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "objectLineNum"    , input string( buf_chk-discnt.object-line-num )  , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntTargetName" , input entry (lookup (string(buf_chk-discnt.line-type), '0,1,2,3,4,5,7,8':U), 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U)                     , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntTypeName"   , input entry (lookup (string(buf_chk-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U)                       , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntValueAbs"   , input string( buf_chk-discnt.discnt-value-abs ) , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntValuePcnt"  , input string( buf_chk-discnt.discnt-value-pcnt ), input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "srcDCard"         , input string( buf_chk-discnt.src-d-card )       , input 2 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntKategory"   , input string( if buf_chk-discnt.src-d-card <> ''
                                                                                                 and buf_chk-discnt.src-d-card <> ?
                                                                                                 and available buf_dis-card
                                                                                                 and buf_dis-card.d-card = buf_chk-discnt.src-d-card
                                                                                                 and buf_chk-discnt.kateg = ?
                                                                                                 then buf_dis-card.category
                                                                                                 else buf_chk-discnt.kateg )        , input 2 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntType"        , input string(buf_chk-discnt.discnt-type)  , input 1 ).
          run wp-xmltagclose in this-procedure ( input 4, input "checkDiscount" ).
        end.
        for each buf_chk-discnt no-lock
          where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            and buf_chk-discnt.record-type = 2
        :
          run wp-xmltagopen in this-procedure ( input 4, input "checkDiscount"   , input "" ).
          run wp-xmltagput in this-procedure ( input 5, input "lineNum"          , input string( buf_chk-discnt.line-num )         , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntVName"      , input entry (lookup (string(buf_chk-discnt.value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U)                          , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "objectLineNum"    , input string( buf_chk-discnt.object-line-num )  , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntTargetName" , input entry (lookup (string(buf_chk-discnt.line-type), '0,1,2,3,4,5,7,8':U), 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U)                     , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntTypeName"   , input entry (lookup (string(buf_chk-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U)                       , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntValueAbs"   , input string( buf_chk-discnt.discnt-value-abs ) , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntValuePcnt"  , input string( buf_chk-discnt.discnt-value-pcnt ), input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "srcDCard"         , input string( buf_chk-discnt.src-d-card )       , input 2 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntKategory"   , input string( if buf_chk-discnt.src-d-card <> ''
                                                                                                 and buf_chk-discnt.src-d-card <> ?
                                                                                                 and available buf_dis-card
                                                                                                 and buf_dis-card.d-card = buf_chk-discnt.src-d-card
                                                                                                 and buf_chk-discnt.kateg = ?
                                                                                                 then buf_dis-card.category
                                                                                                 else buf_chk-discnt.kateg )        , input 2 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntType"        , input string(buf_chk-discnt.discnt-type)  , input 1 ).
          run wp-xmltagclose in this-procedure ( input 4, input "checkDiscount" ).
        end.
        run wp-xmltagclose( input 3, input "check" ).
    end.
end.
end procedure.
procedure run-callback-write-doc-code :
do
on error undo, return error
:
define input parameter p-handle         as handle       no-undo.
define input parameter p-type           as character    no-undo.
define input parameter p-doc-code       as character    no-undo.
define input parameter p-log-file       as character    no-undo.
define variable v-procedure-name    as char no-undo.
case p-type
:
    when 'price-doc':U
    then do:
      assign
        v-procedure-name = "fill-temp-pr-doc-num":U
      .
    end.
    when 'trn-doc':U
    then do:
      assign
        v-procedure-name = "fill-temp-doc-code":U
      .
    end.
    when 'c-trn-doc':U
    then do:
      assign
        v-procedure-name = "fill-temp-del-doc-code":U
      .
    end.
    when 'ord-doc':U
    then do:
      assign
        v-procedure-name = "fill-temp-ord-doc-code":U
      .
    end.
end case.
if lookup( v-procedure-name, p-handle :internal-entries ) > 0
then do:
    run value( v-procedure-name ) in p-handle ( input p-doc-code ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file
            , input 1
            , input substitute( "Ошибка при вызове callback - процедуры &1.", v-procedure-name )
        ).
    end.
end.
else do:
    run wp-XMLWriteLog in this-procedure (
          input p-log-file
        , input 1
        , input substitute( "Не найдена callback - процедура &1.", v-procedure-name )
    ).
end.
end.
end procedure.
procedure export-deleted-docs :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-corr-user-db-num   as integer          no-undo.
define input parameter p-chip-num           as integer          no-undo.
    define buffer buf_c-trn-doc     for ub.c-trn-doc.
    define variable v-firm-code as character no-undo .
do
for buf_c-trn-doc
on error undo, return error
:
    find first buf_c-trn-doc no-lock
         where buf_c-trn-doc.doc-code           = p-doc-code
           and buf_c-trn-doc.corr-user-db-num   = p-corr-user-db-num
           and buf_c-trn-doc.chip-num           = p-chip-num
    .
    assign
      v-firm-code = buf_c-trn-doc.cli-type + string( buf_c-trn-doc.cli-code )
    .
    run wp-XMLWriteCnt( input hcnt, input substitute( "Удаленный: &1 от &2", p-doc-code, buf_c-trn-doc.fact-date ) ).
    process events.
    run wp-xmltagopen( input 2, input "operation", input "" ).
    run wp-xmltagput( input 3, input "referenceNo"  , input buf_c-trn-doc.doc-code                                   , input 0 ).
    run wp-xmltagput( input 3, input "isDel"        , input "yes"                                                    , input 0 ).
    run wp-xmltagput( input 3, input "flagDel"      , input buf_c-trn-doc.is-del                                     , input 0 ).
    run wp-xmltagput( input 3, input "codeOperation", input string( buf_c-trn-doc.ext-doc-type                      ), input 0 ).
    run wp-xmltagput( input 3, input "host"         , input string( buf_c-trn-doc.host-code                         ), input 0 ).
    run wp-xmltagput( input 3, input "store"        , input buf_c-trn-doc.obj-type + string( buf_c-trn-doc.obj-code ), input 0 ).
    run wp-xmltagput( input 3, input "dateDel"      , input string( buf_c-trn-doc.corr-date ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateDelXml"   , input bge-xml-date( buf_c-trn-doc.corr-date )                  , input 0 ).
    run wp-xmltagput( input 3, input "dateDoc"      , input string( buf_c-trn-doc.doc-date  ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateDocXml"   , input bge-xml-date( buf_c-trn-doc.doc-date )                   , input 0 ).
    run wp-xmltagput( input 3, input "dateFact"     , input string( buf_c-trn-doc.fact-date ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateFactXml"  , input bge-xml-date( buf_c-trn-doc.fact-date )                  , input 0 ).
    if buf_c-trn-doc.ext-doc-type <> 'ot':U
    then do:
      run wp-xmltagput( input 3, input "firm"         , input v-firm-code                                              , input 0 ).
    end.
    run wp-xmltagput( input 3, input "outCode"      , input string( buf_c-trn-doc.out-code                          ), input 0 ).
    run wp-xmltagput( input 3, input "comment"      , input buf_c-trn-doc.PS                                         , input 0).
    run wp-xmltagclose( input 2, input "operation" ).
end.
end procedure.
procedure export-gds-dtl :
define input parameter p-doc-code   as character        no-undo.
define input parameter p-artic      as character        no-undo.
define input parameter p-prod-type  as character        no-undo.
define input parameter p-prod-code  as integer          no-undo.
    define variable v-fact-qnty      as decimal       no-undo.
    define variable v-sum-base       as decimal       no-undo.
    define variable v-sum-rubl       as decimal       no-undo.
    define variable v-vat-base       as decimal       no-undo.
    define variable v-vat-rubl       as decimal       no-undo.
    define variable v-slt-base       as decimal       no-undo.
    define variable v-slt-rubl       as decimal       no-undo.
    define variable v-road-tax-base  as decimal       no-undo.
    define variable v-road-tax-rubl  as decimal       no-undo.
    define buffer buf_gds-dtl       for ub.gds-dtl.
    define buffer buf_gds-prt       for ub.gds-prt.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
do
for buf_gds-dtl
  , buf_gds-prt
  , buf_trn-doc
  , buf_doc-line
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    find first buf_doc-line no-lock
         where buf_doc-line.doc-code    = p-doc-code
           and buf_doc-line.artic       = p-artic
           and buf_doc-line.prod-type   = p-prod-type
           and buf_doc-line.prod-code   = p-prod-code
    .
    for each buf_gds-dtl no-lock
       where buf_gds-dtl.prod-type  = p-prod-type
         and buf_gds-dtl.prod-code  = p-prod-code
         and buf_gds-dtl.artic      = p-artic
         and buf_gds-dtl.doc-code   = p-doc-code
    :
        find first buf_gds-prt no-lock
             where buf_gds-prt.node-code = buf_gds-dtl.prt-code
        no-error .
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
            v-fact-qnty           = buf_gds-dtl.fact-qnty
            v-sum-rubl            = price-rubl-with-tax-sale    * v-fact-qnty
            v-vat-rubl            = vat-rubl-buyer              * v-fact-qnty
            v-slt-rubl            = slt-rubl-sale               * v-fact-qnty
            v-road-tax-rubl       = road-tax-rubl-sale          * v-fact-qnty
            v-sum-base            = price-base-with-tax-sale    * v-fact-qnty
            v-vat-base            = vat-base-buyer              * v-fact-qnty
            v-slt-base            = slt-base-sale               * v-fact-qnty
            v-road-tax-base       = road-tax-base-sale          * v-fact-qnty
        .
        run wp-xmltagopen in this-procedure ( input 5, input "dtl", input "" ).
        run wp-xmltagput in this-procedure ( input 6
                                           , input "dtlName"
                                           , input if available buf_gds-prt then string( buf_gds-prt.f-name ) else ""
                                           , input 2
                                           ).
        run wp-xmltagput in this-procedure ( input 6, input "qnty"      , input string( v-fact-qnty        ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "sumr"      , input string( v-sum-rubl         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "VATr"      , input string( v-vat-rubl         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "SLTr"      , input string( v-slt-rubl         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "roadTaxr"  , input string( v-road-tax-rubl    ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "sumb"      , input string( v-sum-base         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "VATb"      , input string( v-vat-base         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "SLTb"      , input string( v-slt-base         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "roadTaxb"  , input string( v-road-tax-base    ), input 2 ).
        run wp-xmltagclose in this-procedure ( input 5, input "dtl" ).
    end.
end.
end procedure.
procedure write-doc-header :
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-ext-doc-type           as character        no-undo.
define input parameter p-doc-code               as character        no-undo.
define input parameter p-doc-date               as date             no-undo.
define input parameter p-fact-date              as date             no-undo.
define input parameter p-reason-code            as integer          no-undo.
define input parameter p-doc-PS                 as character        no-undo.
define input parameter p-fact-order             as decimal          no-undo.
define input parameter p-sys-date               as date             no-undo.
define input parameter p-sys-time               as character        no-undo.
define input parameter p-firm-code              as character        no-undo.
define input parameter p-ord-num                as character        no-undo.
define input parameter p-ship-num               as character        no-undo.
define input parameter p-ship-date              as date             no-undo.
define input parameter p-payment-code           as integer          no-undo.
define input parameter p-hold-doc-code-child    as character        no-undo.
define input parameter p-hold-doc-code-parent   as character        no-undo.
define input parameter p-hold-obj-type          as character        no-undo.
define input parameter p-hold-obj-code          as integer          no-undo.
define input parameter p-out-code               as character        no-undo.
define input parameter p-supp-dog-code          as character        no-undo.
define input parameter p-supp-ndog              as character        no-undo.
define input parameter p-supp-ddog              as character        no-undo.
define input parameter p-d-card                 as character        no-undo.
define input parameter p-cli-type               as character        no-undo.
define input parameter p-cli-code               as integer          no-undo.
  define variable v-attr-value        as character    no-undo.
  define variable v-attr-type         as character    no-undo.
  define variable v-ext-doc-type      as character    no-undo.
  define variable v-doc-exch-code     as integer      no-undo.
  define variable v-doc-exch-rate     as decimal      no-undo.
  define variable v-doc-exch-scale    as integer      no-undo.
  define variable v-fact-time         as integer      no-undo.
  define variable v-idContr           as character    no-undo.
  define buffer buf_ord-chain   for ub.ord-chain.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_trn-doc     for ub.trn-doc.
do
for buf_ord-chain
  , buf_ord-doc-rcv
  , buf_trn-doc
on error undo, return error
:
    assign
      v-ext-doc-type    = p-ext-doc-type
      v-doc-exch-code   = ?
      v-doc-exch-rate   = ?
      v-doc-exch-scale  = ?
      v-fact-time = ?
    .
    if p-ext-doc-type = 'ie':U
    then do:
      run bge-xml-resolve-ext-doc-type in this-procedure ( input  p-ext-doc-type
                                                         , input  p-cli-type
                                                         , input  p-cli-code
                                                         , output v-ext-doc-type
                                                         ).
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
    no-error .
    if available buf_trn-doc
    then do:
      assign
        v-doc-exch-code   = buf_trn-doc.exch-code
        v-doc-exch-rate   = buf_trn-doc.exch-rate
        v-doc-exch-scale  = buf_trn-doc.exch-scale
        v-fact-time       = buf_trn-doc.fact-time
      .
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'idCountryContr':U ,
                       output v-idContr ,
                       output v-attr-type ) no-error .
    run wp-xmltagopen( 2, "operation","" ).
    run wp-xmltagput( input 3, input "referenceNo"  , input string( p-doc-code                          ), input 0 ).
    run wp-xmltagput( input 3, input "codeOperation", input string( v-ext-doc-type                      ), input 0 ).
    run wp-xmltagput( input 3, input "host"         , input string( p-host-code                         ), input 0 ).
    run wp-xmltagput( input 3, input "store"        , input p-obj-type + string( p-obj-code )            , input 0 ).
    run wp-xmltagput( input 3, input "factOrder"    , input string( p-fact-order                        ), input 0 ).
    run wp-xmltagput( input 3, input "sysDate"      , input string( p-sys-date ,"99.99.9999"            ), input 0 ).
    run wp-xmltagput( input 3, input "sysDateXml"   , input bge-xml-date( p-sys-date )                   , input 0 ).
    run wp-xmltagput( input 3, input "sysTime"      , input string( p-sys-time                          ), input 0 ).
    run wp-xmltagput( input 3, input "dateDoc"      , input string( p-doc-date,"99.99.9999"             ), input 0 ).
    run wp-xmltagput( input 3, input "dateDocXml"   , input bge-xml-date( p-doc-date )                   , input 0 ).
    run wp-xmltagput( input 3, input "dateFact"     , input string( p-fact-date,"99.99.9999"            ), input 0 ).
    run wp-xmltagput( input 3, input "dateFactXml"  , input bge-xml-date( p-fact-date )                  , input 0 ).
    run wp-xmltagput( input 3, input "timeFact"     , input string( v-fact-time,"hh:mm:ss"              ), input 1 ).
    run wp-xmltagput( input 3, input "valutCode"    , input string( v-base-code                         ), input 0 ).
    run wp-xmltagput( input 3, input "valutCodeOKV" , input string( v-base-code-okv                     ), input 0 ).
    run wp-xmltagput( input 3, input "GosContract"  , input string( v-idContr                           ), input 0 ).
    run wp-xmltagput( input 3, input "exchCode"     , input string( v-doc-exch-code                     ), input 0 ).
    run wp-xmltagput( input 3, input "exchRate" , input string( v-doc-exch-rate                     ), input 0 ).
    run wp-xmltagput( input 3, input "exchScale", input string( v-doc-exch-scale                    ), input 0 ).
    if p-ext-doc-type <> 'ot':U
    then do:
        run wp-xmltagput( 3, "firm",                 p-firm-code                             , 0 ).
        run wp-xmltagput( 3, "extNumber",            string( p-ord-num                      ), 0 ).
        run wp-xmltagput( 3, "outNumber",            string( p-ship-num                     ), 0 ).
        run wp-xmltagput( 3, "outDate",              string( p-ship-date,  "99.99.9999"     ), 0 ).
        run wp-xmltagput( 3, "outDateXml",           bge-xml-date( p-ship-date )             , 0 ).
        run wp-xmltagput( 3, "paymentCode",          string( p-payment-code                 ), 0 ).
        run wp-xmltagput( 3, "InterFirmDocChild",    string( p-hold-doc-code-child          ), 0 ).
        run wp-xmltagput( 3, "InterFirmDocParent",   string( p-hold-doc-code-parent         ), 0 ).
        run wp-xmltagput( 3, "InterFirmObjType",     string( p-hold-obj-type                ), 0 ).
        run wp-xmltagput( 3, "InterFirmObjCode",     string( p-hold-obj-code                ), 0 ).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'dov':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
        run wp-xmltagput( 3, "authority",     v-attr-value, 0 ).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'dids':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
        run wp-xmltagput( 3, "suppInDocDate"   , v-attr-value                    , 0 ).
        run wp-xmltagput( 3, "suppInDocDateXml", bge-xml-str-date( v-attr-value ), 0 ).
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'nids':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    run wp-xmltagput( 3, "suppInDocNo"         , v-attr-value                    , 0 ).
    if p-ext-doc-type <> 'ot':U
    then do:
        run wp-xmltagput( 3, "contractSuppCode"    , p-supp-dog-code                 , 0 ).
        run wp-xmltagput( 3, "contractSuppNo"      , p-supp-ndog                     , 0 ).
        run wp-xmltagput( 3, "contractSuppDate"    , p-supp-ddog                     , 0 ).
        run wp-xmltagput( 3, "contractSuppDateXml" , bge-xml-str-date( p-supp-ddog ) , 0 ).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'ddog':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input sLogFile
                , input 1
                , substitute( "*** ERR: *** Ошибка чтения атрибута даты договора для приходной накладной N &1 ", p-doc-code )
            ).
        end.
        run wp-xmltagput( 3, "contractDate"   , v-attr-value                    , 0 ).
        run wp-xmltagput( 3, "contractDateXml", bge-xml-str-date( v-attr-value ), 0 ).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'ndog':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input sLogFile
                , input 1
                , substitute( "*** ERR: *** Ошибка чтения атрибута номера договора для приходной накладной N &1 ", p-doc-code )
            ).
        end.
        run wp-xmltagput( 3, "contractNo",     v-attr-value, 0 ).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'nsf':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
        run wp-xmltagput( 3, "sfNo",     v-attr-value, 0 ).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'dsf':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
        run wp-xmltagput( 3, "sfDate"   , v-attr-value                    , 0 ).
        run wp-xmltagput( 3, "sfDateXml", bge-xml-str-date( v-attr-value ), 0 ).
    end.
    run wp-xmltagput( input 3, input "reasonCode"   , input string( p-reason-code )                      , input 1 ).
    run wp-xmltagput( input 3, input "outCode"      , input p-out-code                                   , input 0 ).
    run wp-xmltagput( input 3, input "comment"      , input p-doc-PS                                     , input 0 ).
    find first buf_ord-chain no-lock
      where buf_ord-chain.rel-doc-code =  p-doc-code
        and buf_ord-chain.rel-doc-type = 'trn':u
    no-error .
    if available buf_ord-chain
    then do:
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code
      no-error .
      if available buf_ord-doc-rcv
      then do:
        run wp-xmltagput( input 3, input "ordDocCode"     ,  input string( buf_ord-doc-rcv.doc-code  ), input 1 ).
        run wp-xmltagput( input 3, input "ordOutDocCode"  ,  input string( buf_ord-doc-rcv.cons-code ), input 0 ).
      end.
    end.
    run wp-xmltagput( input 3, input "dCard"   ,  input p-d-card , input 0 ).
    def var v-value as character no-undo.
    def var v-type  as character no-undo.
    def var v-tech-pass as logical no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'techpass':U ,
                       output v-value ,
                       output v-type ) no-error .
    assign
      v-tech-pass = yes when v-value = "yes".
    if p-ext-doc-type = 'we':U and
        (can-find(first ub.sale-doc where ub.sale-doc.doc-code = p-doc-code and ub.sale-doc.doc-kind = 'trf':U) or v-tech-pass)
    then do:
      run safe-wp-xmltagput in this-procedure ( input 3, input "techfuel":U  , input "yes":u, input 1 ).
    end.
    if p-ext-doc-type = 'ie':U and
        (can-find(first ub.sale-doc where ub.sale-doc.doc-code = p-doc-code and ub.sale-doc.doc-kind = 'itr':U) or v-tech-pass)
    then do:
      run safe-wp-xmltagput in this-procedure ( input 3, input "techfuel":U  , input "yes":u, input 1 ).
    end.
    if p-ext-doc-type = 'ie':U
    then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'is-lgas-corr':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
      if not error-status:error and v-attr-value = "yes" then do:
        run wp-xmltagput( input 3, input "lgascorr"  ,  input "yes", input 0 ).
      end.
    end.
end.
end procedure.
procedure export-part :
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-parts-rowid        as rowid            no-undo.
define input parameter  p-is-envd           as logical          no-undo.
define variable v-PartsAlcAttrBottingDate like parts.alc-bottling-date no-undo.
define variable v-PartsAlcAttrAlcType like ub.alc-type.alc-type-code no-undo.
define variable v-PartsAlcAttrAlcCode as char no-undo.
define variable v-PartsAlcAttrRefA like parts.alc-ref-ab-path no-undo.
define variable v-PartsAlcAttrRefB like parts.alc-ref-ab-path no-undo.
define variable v-PartsAlcAttrProd as char no-undo.
define variable v-PartsAlcAttrQu like parts.alc-quality-certif-path no-undo.
define variable v-PartsAlcAttrCertifPath like parts.alc-certif-path no-undo.
define variable v-PartsAlcAttrImpCode like parts.alc-imp-code no-undo.
define variable v-PartsAlcAttrImpType like parts.alc-imp-type no-undo.
DEFINE VARIABLE v-par-val             AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-par-type            AS CHARACTER NO-UNDO.
define variable v-prod as character no-undo.
define variable v-value-character     as character     no-undo .
define variable v-value-decimal       as decimal       no-undo .
define variable v-value-integer       as integer       no-undo .
define variable v-value-logical       as logical       no-undo .
define variable v-value-type          as character     no-undo .
define variable v-value-date          as date          no-undo .
define variable v-ext-sys             as integer       no-undo .
define variable v-inn as character no-undo.
define variable v-kpp as character no-undo.
define variable v-naim as character no-undo.
    define variable v-fact-qnty             as decimal      no-undo.
    define variable v-sum-base              as decimal      no-undo.
    define variable v-sum-rubl              as decimal      no-undo.
    define variable v-vat-base              as decimal      no-undo.
    define variable v-vat-rubl              as decimal      no-undo.
    define variable v-slt-base              as decimal      no-undo.
    define variable v-slt-rubl              as decimal      no-undo.
    define variable v-road-tax-base         as decimal      no-undo.
    define variable v-road-tax-rubl         as decimal      no-undo.
    define variable v-excise-base           as decimal      no-undo.
    define variable v-excise-rubl           as decimal      no-undo.
    define variable v-transport-base        as decimal      no-undo.
    define variable v-transport-rubl        as decimal      no-undo.
    define variable v-other-base            as decimal      no-undo.
    define variable v-other-rubl            as decimal      no-undo.
    define variable v-supp-dog-code         as character    no-undo.
    define variable v-supp-ndog             as character    no-undo.
    define variable v-supp-ddog             as character    no-undo.
    define variable v-parts-host-code       as integer      no-undo.
    define variable v-parts-contract-code   as integer      no-undo.
    define variable v-country-code          as character    no-undo.
    define variable v-parts-price-cli       as decimal       no-undo.
    define variable v-parts-cli-base-rate   as decimal       no-undo.
    define variable v-parts-vat-type        as character     no-undo.
    define variable v-parts-exch-code       as integer       no-undo.
    define variable v-parts-attr-exch-rate  as decimal       no-undo.
    define variable v-parts-attr-exch-scale as integer       no-undo.
    define variable v-parts-attr-unit-cli   as character     no-undo.
define buffer  X_ext-classif-attr for ext-classif-attr.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_alc-type-gds    for ub.alc-type-gds .
define buffer buf_alc-type        for ub.alc-type .
    define buffer buf_contract      for ub.contract.
    define buffer buf_parts         for ub.parts.
    define buffer buf_goods         for ub.goods.
    define buffer buf_parts-attr    for ub.parts-attr.
do
for buf_contract
  , buf_parts
  , buf_parts-attr
on error undo, return error
:
        find first buf_parts no-lock
             where rowid( buf_parts ) = p-parts-rowid
        .
        assign
            v-supp-dog-code  = "":U
            v-supp-ndog      = "":U
            v-supp-ddog      = "":U
        .
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
        ASSIGN
            v-fact-qnty           = buf_parts.fact-qnty
            v-sum-rubl            = price-rubl-with-tax-loc * v-fact-qnty
            v-vat-rubl            = vat-rubl-loc            * v-fact-qnty
            v-slt-rubl            = slt-rubl-loc            * v-fact-qnty
            v-road-tax-rubl       = road-tax-rubl-loc       * v-fact-qnty
            v-transport-rubl      = transport-rubl-loc      * v-fact-qnty
            v-other-rubl          = other-rubl-loc          * v-fact-qnty
            v-excise-rubl         = 0
            v-sum-base            = price-base-with-tax-loc * v-fact-qnty
            v-vat-base            = vat-base-loc            * v-fact-qnty
            v-slt-base            = slt-base-loc            * v-fact-qnty
            v-road-tax-base       = road-tax-base-loc       * v-fact-qnty
            v-transport-base      = transport-base-loc      * v-fact-qnty
            v-other-base          = other-base-loc          * v-fact-qnty
            v-excise-base         = 0
            v-parts-host-code     = buf_parts.host-code
            v-parts-contract-code = buf_parts.contract-code
            v-parts-price-cli     = buf_parts.price-cli
            v-parts-cli-base-rate = buf_parts.cli-base-rate
            v-parts-vat-type      = buf_parts.vat-type
            v-parts-exch-code     = buf_parts.exch-code
        .
        if buf_parts.contract-code <> 0
        then do:
            assign
                v-supp-dog-code = string( buf_parts.contract-code )
            .
            find first buf_contract no-lock
                    where buf_contract.host-code       = v-host-code
                    and buf_contract.contract-code   = buf_parts.contract-code
            no-error.
            if available buf_contract
            then do:
                assign
                    v-supp-ndog          = string( buf_contract.contract-prn-code )
                    v-supp-ddog          = string( buf_contract.contract-date, "99.99.9999" )
                .
            end.
        end.
        find first buf_goods no-lock
                where buf_goods.gds-code = p-gds-code
        no-error.
        if available buf_goods
        then do:
            RUN gds-attr-value(
                ub.buf_goods.gds-code,
                'alcohol-prod':U,
                OUTPUT v-par-val,
                OUTPUT v-par-type
                ).
            IF v-par-val <> "" AND
                v-par-val <> "no" THEN
            DO:
            assign
                            v-PartsAlcAttrRefA        = "":U
                            v-PartsAlcAttrRefB        = "":U
                            v-PartsAlcAttrAlcCode     = "":U
                            v-PartsAlcAttrAlcType     = "":U
                            v-PartsAlcAttrQu          = "":U
                            v-PartsAlcAttrCertifPath  = "":U
                            v-PartsAlcAttrImpCode     = 0
                            v-PartsAlcAttrImpType     = "":U
                            v-prod = "":U
                            v-inn = "":U
                            v-kpp = "":U
                            v-naim = "":U
                            v-PartsAlcAttrProd =  "":U
                            .
                          run adm/shattri.p (
                            input "get":U
                            ,input '':U
                            ,input 0
                            ,input 'egais':U
                            ,input 'egais-exsys':U
                            ,output v-value-character
                            ,output v-value-date
                            ,output v-value-decimal
                            ,output v-value-integer
                            ,output v-value-logical
                            ,output v-value-type
                            ,input-output TABLE thbjattr_thbj-attr
                            ) no-error .
                        assign
                            v-ext-sys = v-value-integer .
               assign
                            v-PartsAlcAttrBottingDate = buf_parts.alc-bottling-date
                            v-PartsAlcAttrRefA        = entry(1,buf_parts.alc-ref-ab-path, ",")
                            v-PartsAlcAttrRefB        = entry(2,buf_parts.alc-ref-ab-path,",")
                            when num-entries (buf_parts.alc-ref-ab-path) > 1
                            v-PartsAlcAttrAlcCode     = entry(3,buf_parts.alc-ref-ab-path,",")
                            when num-entries (buf_parts.alc-ref-ab-path) > 2
                            v-PartsAlcAttrAlcType     = entry(4,buf_parts.alc-ref-ab-path,",")
                            when num-entries (buf_parts.alc-ref-ab-path) > 3
                            v-PartsAlcAttrQu          = buf_parts.alc-quality-certif-path
                            v-PartsAlcAttrCertifPath  = buf_parts.alc-certif-path
                            v-PartsAlcAttrImpCode     = buf_parts.alc-imp-code
                            v-PartsAlcAttrImpType     = buf_parts.alc-imp-type
                            .
                             if not v-PartsAlcAttrAlcType > '' then  for first buf_alc-type-gds where buf_alc-type-gds.gds-code = ub.buf_goods.gds-code no-lock,
                                      first buf_alc-type where buf_alc-type.alc-type-inner-code = buf_alc-type-gds.alc-type-inner-code no-lock:
                                       v-PartsAlcAttrAlcType =  buf_alc-type.alc-type-code.
                                   end.
                      find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'goods':U
                            and buf_ext-classif.classif-name = 'exp-esys-gds-code':U
                            and buf_ext-classif.db-num = 0
                            and buf_ext-classif.key#_one = buf_goods.gds-code
                            and buf_ext-classif.key#_two = v-ext-sys
                            no-error.
                        if available buf_ext-classif then
                        do:
                            v-prod = entry (1, buf_ext-classif.CharKey_Two, chr(4)).
                            v-inn = entry(4, v-prod, chr(5)) + "/" no-error.
                            v-kpp = entry(2, v-prod, chr(5)) + "/" no-error.
                            v-naim =   entry(3, v-prod, chr(5)) no-error.
                            v-PartsAlcAttrProd =    v-naim   + v-inn    + v-kpp .
                        end.
                    end.
            find first buf_parts-attr no-lock
                    where buf_parts-attr.in-code   = buf_parts.in-code
                    and buf_parts-attr.gds-code  = p-gds-code
                    and buf_parts-attr.part-code = buf_parts.part-code
            no-error .
            if available buf_parts-attr
            then do:
                assign
                    v-supp-type                 = buf_parts-attr.supp-type
                    v-supp-code                 = buf_parts-attr.supp-code
                    v-in-code                   = buf_parts-attr.income-in-code
                    v-cst-code                  = buf_parts-attr.cst-code
                    v-country-code              = string( buf_parts-attr.country-code )
                    v-parts-attr-exch-rate      = buf_parts-attr.exch-rate
                    v-parts-attr-exch-scale     = buf_parts-attr.exch-scale
                    v-parts-attr-unit-cli       = buf_parts-attr.unit-cli
                .
            end.
            else do:
                assign
                    v-supp-type                 = buf_parts.supp-type
                    v-supp-code                 = buf_parts.supp-code
                    v-in-code                   = buf_parts.in-code
                    v-cst-code                  = buf_parts.cst-code
                    v-country-code              = "":U
                    v-parts-attr-exch-rate      = 0.0
                    v-parts-attr-exch-scale     = 0
                    v-parts-attr-unit-cli       = "":U
                .
            end.
        end.
        else do:
            assign
                v-supp-type                 = buf_parts.supp-type
                v-supp-code                 = buf_parts.supp-code
                v-in-code                   = buf_parts.in-code
                v-cst-code                  = buf_parts.cst-code
                v-country-code              = "":U
                v-parts-attr-exch-rate      = 0.0
                v-parts-attr-exch-scale     = 0
                v-parts-attr-unit-cli       = "":U
            .
        end.
        run wp-xmltagopen in this-procedure ( input 5, input "part", input "" ).
        run wp-xmltagput in this-procedure ( input 6, input "doc_ID"            , input string( v-in-code               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "qnty"              , input string( v-fact-qnty             ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "cst"               , input string( v-cst-code              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "supp"              , input string( v-supp-type + string( v-supp-code ) ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "hostCode"          , input string( v-parts-host-code       ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractCode"      , input string( v-parts-contract-code   ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "sumr"                , input string( v-sum-rubl              ), input 1 ).
        if p-is-envd eq NO then
          run wp-xmltagput in this-procedure ( input 6, input "VATr"                , input string( v-vat-rubl         ), input 2 ).
        else
          run wp-xmltagput in this-procedure ( input 6, input "VATr"                , input string(((price-rubl-with-tax-loc / (100 + buf_parts.VAT-pc )) * buf_parts.VAT-pc)  * buf_parts.fact-qnty ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "SLTr"              , input string( v-slt-rubl              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "roadTaxr"          , input string( v-road-tax-rubl         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "transportr"        , input string( v-transport-rubl        ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "otherr"            , input string( v-other-rubl            ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "exciser"           , input string( v-excise-rubl           ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "sumb"              , input string( v-sum-base              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "VATb"              , input string( v-vat-base              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "SLTb"              , input string( v-slt-base              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "roadTaxb"          , input string( v-road-tax-base         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "transportb"        , input string( v-transport-base        ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "otherb"            , input string( v-other-base            ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "exciseb"           , input string( v-excise-base           ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractSuppCode"  , input v-supp-dog-code                  , input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractSuppNo"    , input v-supp-ndog                      , input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractSuppDate"  , input v-supp-ddog                      , input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractSuppDateXml" , input bge-xml-str-date(v-supp-ddog)    , input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "countryCode"       , input string( v-country-code          ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "priceCli":U        , input string( v-parts-price-cli       ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "cliBaseRate":U     , input string( v-parts-cli-base-rate   ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "vatType":U         , input string( v-parts-vat-type        ), input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "exchCode":U        , input string( v-parts-exch-code       ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "attrExchRate":U    , input string( v-parts-attr-exch-rate  ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "attrExchScale":U   , input string( v-parts-attr-exch-scale ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "attrUnitCli":U     , input string( v-parts-attr-unit-cli   ), input 0 ).
    IF v-par-val <> "" AND
        v-par-val <> "no" THEN
    DO:
        run wp-xmltagopen in this-procedure ( input 6, input "PartsAlcAttr":U, input "" ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrBottingDate":U              , input string( v-PartsAlcAttrBottingDate               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrAlcType":U              , input string( v-PartsAlcAttrAlcType               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrAlcCode":U              , input string( v-PartsAlcAttrAlcCode               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrRefA":U              , input string( v-PartsAlcAttrRefA             ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrRefB":U              , input string( v-PartsAlcAttrRefB              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrProd":U              , input string( v-PartsAlcAttrProd              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrQualityCertify":U              , input string( v-PartsAlcAttrQu               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrCertifPath":U              , input string( v-PartsAlcAttrCertifPath               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrImpCode":U              , input string( v-PartsAlcAttrImpCode               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrImpType":U              , input string( v-PartsAlcAttrImpType               ), input 2 ).
        run wp-xmltagclose in this-procedure ( input 6, input "PartsAlcAttr":U ).
    end.
    run wp-xmltagclose in this-procedure ( input 5, input "part":U ).
end.
end procedure.
procedure fill_bge-xml_goods :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-gds-code       as integer          no-undo.
do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bge-xml_goods" ) <> "":U
    then do:
        run cb-fill_bge-xml_goods in p-parent-handle (
            input p-gds-code
        ).
    end.
end.
end procedure.
procedure fill_bge-xml_clients :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bge-xml_clients" ) <> "":U
    then do:
        run cb-fill_bge-xml_clients in p-parent-handle (
              input p-obj-type
            , input p-obj-code
        ).
    end.
end.
end procedure.
procedure fill_bge-xml_dis-card :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-d-card         as character        no-undo.
do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bge-xml_dis-card" ) <> "":U
    then do:
        run cb-fill_bge-xml_dis-card in p-parent-handle (
            input p-d-card
        ).
    end.
end.
end procedure.
procedure export-chk-pay-code :
define input parameter p-ext-doc-type       as character        no-undo.
define input parameter p-doc-line-recid     as recid            no-undo.
define input parameter p-out-code           as character        no-undo.
define input parameter p-pay-desk           as logical          no-undo.
define input parameter p-is-petrol          as logical          no-undo.
define input parameter p-is-pieces          as logical          no-undo.
    define variable v-cash-pay-not-specified      as logical      no-undo.
do
on error undo, return error
:
    run get-cash-pay in this-procedure (
          input p-ext-doc-type
        , input p-doc-line-recid
        , input p-out-code
        , output v-cash-pay-not-specified
    ).
    if v-cash-pay-not-specified = no
    then do:
        if p-pay-desk = yes
        then do:
            run wp-xmltagopen( 4, "goodPayDesk", "" ).
            if p-is-petrol = yes
            and p-is-pieces = no
            then do:
                for each treal-2
                    where treal-2.gds-code = buf_goods.gds-code
                break by treal-2.pay-desk
                        by treal-2.cpay-code
                        by treal-2.curr-code
                        by treal-2.prefix
                on error undo, return error
                :
                    if first-of( treal-2.pay-desk )
                    then do:
                        run wp-xmltagopen( 5, "payDesk", "" ).
                        run wp-xmltagput( 6, "code", string( treal-2.pay-desk ), 0 ).
                    end.
                    if first-of(treal-2.curr-code) then do:
                        assign
                        v-found-paycode = no
                        v-found-paycard = no
                        .
                    end.
                    if treal-2.is-pay = no then do:
                    end.
                    else do:
                      if treal-2.prefix = '':U then do:
                          v-found-paycode = yes.
                          run wp-xmltagopen( 6, "payCode", "" ).
                          run wp-xmltagput( 7, "code", string( treal-2.cpay-code ), 0 ).
                          run wp-xmltagput( 7, "quantity", string( v-is-out * treal-2.qnty1 ), 3 ).
                          run wp-xmltagput( 7, "sumr", string( v-is-out * treal-2.netto ), 2 ).
                      end.
                      if treal-2.prefix <> '':U then do:
                          if not v-found-paycard then do:
                          run wp-xmltagopen( 7, "payCards", "" ).
                          v-found-paycard = yes.
                          end.
                          run wp-xmltagopen( 8, "payCard", "" ).
                          run wp-xmltagput( 9, "num", string( treal-2.prefix ), 0 ).
                          run wp-xmltagput( 9, "quantity", string( v-is-out * treal-2.qnty1 ), 3 ).
                          run wp-xmltagput( 9, "sumr", string( v-is-out * treal-2.netto ), 2 ).
                          run wp-xmltagclose( 8, "payCard").
                      end.
                      if last-of(treal-2.curr-code) then do:
                          if v-found-paycard then do:
                          run wp-xmltagclose( 7, "payCards" ).
                          end.
                          if v-found-paycode then do:
                          run wp-xmltagclose( 6, "payCode" ).
                          end.
                      end.
                    end.
                    if last-of( treal-2.pay-desk )
                    then do:
                        run wp-xmltagclose( 5, "payDesk" ).
                    end.
                end.
            end.
            else do:
                case buf_goods.gds-type:
                    when 'т':U
                    then do:
                        for each treal-3 no-lock
                            where treal-3.gds-code = buf_goods.gds-code
                        break by treal-3.pay-desk
                                by treal-3.cpay-code
                                by treal-3.curr-code
                                by treal-3.prefix
                        on error undo, return error
                        :
                            if first-of( treal-3.pay-desk )
                            then do:
                                run wp-xmltagopen( 5, "payDesk", "" ).
                                run wp-xmltagput( 6, "code", string( treal-3.pay-desk ), 0 ).
                            end.
                            if first-of( treal-3.curr-code) then do:
                                assign
                                v-found-paycode = no
                                v-found-paycard = no
                                .
                            end.
                            if treal-3.is-pay = no then do:
                            end.
                            else do:
                              if treal-3.prefix = '':U then do:
                                  v-found-paycode = yes.
                                  run wp-xmltagopen( 6, "payCode", "" ).
                                  run wp-xmltagput( 7, "code", string( treal-3.cpay-code ), 0 ).
                                  run wp-xmltagput( 7, "quantity", string( v-is-out * treal-3.qnty1 ), 3 ).
                                  run wp-xmltagput( 7, "sumr", string( v-is-out * treal-3.netto ), 2 ).
                              end.
                              if treal-3.prefix <> '':U then do:
                                  if not v-found-paycard then do:
                                  run wp-xmltagopen( 7, "payCards", "" ).
                                  v-found-paycard = yes.
                                  end.
                                  run wp-xmltagopen( 8, "payCard", "" ).
                                  run wp-xmltagput( 9, "num", string( treal-3.prefix ), 0 ).
                                  run wp-xmltagput( 9, "quantity", string( v-is-out * treal-3.qnty1 ), 3 ).
                                  run wp-xmltagput( 9, "sumr", string( v-is-out * treal-3.netto ), 2 ).
                                  run wp-xmltagclose( 8, "payCard").
                              end.
                              if last-of( treal-3.curr-code ) then do:
                                  if v-found-paycard then do:
                                  run wp-xmltagclose( 7, "payCards" ).
                                  end.
                                  if v-found-paycode then do:
                                  run wp-xmltagclose( 6, "payCode" ).
                                  end.
                              end.
                            end.
                            if last-of( treal-3.pay-desk )
                            then do:
                                run wp-xmltagclose( 5, "payDesk" ).
                            end.
                        end.
                    end.
                    when 'у':U
                    then do:
                        for each treal-4 no-lock
                            where treal-4.gds-code = buf_goods.gds-code
                        break by treal-4.pay-desk
                                by treal-4.cpay-code
                                by treal-4.curr-code
                                by treal-4.prefix
                        on error undo, return error
                        :
                            if first-of( treal-4.pay-desk )
                            then do:
                                run wp-xmltagopen( 5, "payDesk", "" ).
                                run wp-xmltagput( 6, "code", string( treal-4.pay-desk ), 0 ).
                            end.
                            if first-of( treal-4.curr-code )
                            then do:
                                assign
                                v-found-paycode = no
                                v-found-paycard = no
                                .
                            end.
                            if treal-4.is-pay = no then do:
                            end.
                            else do:
                              if treal-4.prefix = '':U then do:
                                  v-found-paycode = yes.
                                  run wp-xmltagopen( 6, "payCode","" ).
                                  run wp-xmltagput( 7, "code", string( treal-4.cpay-code ), 0 ).
                                  run wp-xmltagput( 7, "quantity", string( v-is-out * treal-4.qnty1 ), 3 ).
                                  run wp-xmltagput( 7, "sumr", string( v-is-out * treal-4.netto ), 2 ).
                              end.
                              if treal-4.prefix <> '':U then do:
                                  if not v-found-paycard then do:
                                  run wp-xmltagopen( 7, "payCards", "" ).
                                  v-found-paycard = yes.
                                  end.
                                  run wp-xmltagopen( 8, "payCard", "" ).
                                  run wp-xmltagput( 9, "num", string( treal-4.prefix ), 0 ).
                                  run wp-xmltagput( 9, "quantity", string( v-is-out * treal-4.qnty1 ), 3 ).
                                  run wp-xmltagput( 9, "sumr", string( v-is-out * treal-4.netto ), 2 ).
                                  run wp-xmltagclose( 8, "payCard" ).
                              end.
                              if last-of( treal-4.curr-code ) then do:
                                  if v-found-paycard then do:
                                  run wp-xmltagclose( 7, "payCards" ).
                                  end.
                                  if v-found-paycode then do:
                                  run wp-xmltagclose( 6, "payCode" ).
                                  end.
                              end.
                            end.
                            if last-of( treal-4.pay-desk )
                            then do:
                                run wp-xmltagclose( 5, "payDesk" ).
                            end.
                        end.
                    end.
                end case.
            end.
            run wp-xmltagclose( 4, "goodPayDesk" ).
        end.
        else do:
            run wp-xmltagopen( 4, "goodPayCode", "" ).
            if p-is-petrol = yes
            and p-is-pieces = no
            then do:
                for each treal-2 No-LOCK
                where treal-2.gds-code = buf_goods.gds-code
                break by treal-2.pay-desk
                        by treal-2.cpay-code
                        by treal-2.curr-code
                        by treal-2.prefix
                on error undo, return error
                :
                    if first-of( treal-2.curr-code ) then do:
                        assign
                        v-found-paycode = no
                        v-found-paycard = no
                        .
                    end.
                    if treal-2.is-pay = no then do:
                    end.
                    else do:
                      if treal-2.prefix = '':U then do:
                          v-found-paycode = yes.
                          run wp-xmltagopen( 5, "payCode", "" ).
                          run wp-xmltagput( 6, "code", string( treal-2.cpay-code ), 0 ).
                          run wp-xmltagput( 6, "quantity", string( v-is-out * treal-2.qnty1 ), 3 ).
                          run wp-xmltagput( 6, "sumr", string( v-is-out * treal-2.netto ), 2 ).
                      end.
                      if treal-2.prefix <> '':U then do:
                          if not v-found-paycard then do:
                          run wp-xmltagopen( 6, "payCards", "" ).
                          v-found-paycard = yes.
                          end.
                          run wp-xmltagopen( 7, "payCard", "" ).
                          run wp-xmltagput( 8, "num", string( treal-2.prefix ), 0 ).
                          run wp-xmltagput( 8, "quantity", string( v-is-out * treal-2.qnty1 ), 3 ).
                          run wp-xmltagput( 8, "sumr", string( v-is-out * treal-2.netto ), 2 ).
                          run wp-xmltagclose( 7, "payCard" ).
                      end.
                      if last-of( treal-2.curr-code) then do:
                          if v-found-paycard then do:
                          run wp-xmltagclose( 6, "payCards" ).
                          end.
                          if v-found-paycode then do:
                          run wp-xmltagclose( 5, "payCode" ).
                          end.
                      end.
                   end.
                end.
            end.
            else do:
                case buf_goods.gds-type:
                    when 'т':U
                    then do:
                        for each treal-3 no-lock
                        where treal-3.gds-code = buf_goods.gds-code
                        break by treal-3.pay-desk
                                by treal-3.cpay-code
                                by treal-3.curr-code
                                by treal-3.prefix
                        on error undo, return error
                        :
                            if first-of( treal-3.curr-code ) then do:
                                assign
                                v-found-paycode = no
                                v-found-paycard = no
                                .
                            end.
                            if treal-3.is-pay = no then do:
                            end.
                            else do:
                              if treal-3.prefix = '':U then do:
                                  v-found-paycode = yes.
                                  run wp-xmltagopen( 5, "payCode", "" ).
                                  run wp-xmltagput( 6, "code", string( treal-3.cpay-code ), 0 ).
                                  run wp-xmltagput( 6, "quantity", string( v-is-out * treal-3.qnty1 ), 3 ).
                                  run wp-xmltagput( 6, "sumr", string( v-is-out * treal-3.netto ), 2 ).
                              end.
                              if treal-3.prefix <> '':U then do:
                                  if not v-found-paycard then do:
                                  run wp-xmltagopen( 6, "payCards", "" ).
                                  v-found-paycard = yes.
                                  end.
                                  run wp-xmltagopen( 7, "payCard", "" ).
                                  run wp-xmltagput( 8, "code", string( treal-3.prefix ), 0 ).
                                  run wp-xmltagput( 8, "quantity", string( v-is-out * treal-3.qnty1 ), 3 ).
                                  run wp-xmltagput( 8, "sumr", string( v-is-out * treal-3.netto ), 2 ).
                                  run wp-xmltagclose( 7, "payCard" ).
                              end.
                              if last-of(treal-3.curr-code) then do:
                                  if v-found-paycard then do:
                                  run wp-xmltagclose( 6, "payCards" ).
                                  end.
                                  if v-found-paycode then do:
                                  run wp-xmltagclose( 5, "payCode" ).
                                  end.
                              end.
                            end.
                        end.
                    end.
                    when 'у':U
                    then do:
                        for each treal-4 no-lock
                        where treal-4.gds-code = buf_goods.gds-code
                        break by treal-4.pay-desk
                                by treal-4.cpay-code
                                by treal-4.curr-code
                                by treal-4.prefix
                        on error undo, return error
                        :
                            if first-of (treal-4.curr-code) then do:
                                assign
                                v-found-paycode = no
                                v-found-paycard = no
                                .
                            end.
                            if treal-4.is-pay = no then do:
                            end.
                            else do:
                              if treal-4.prefix = '':U then do:
                                  v-found-paycode = yes.
                                  run wp-xmltagopen( 5, "payCode","" ).
                                  run wp-xmltagput( 6, "code", string( treal-4.cpay-code ), 0 ).
                                  run wp-xmltagput( 6, "quantity", string( v-is-out * treal-4.qnty1 ), 3 ).
                                  run wp-xmltagput( 6, "sumr", string( v-is-out * treal-4.netto ), 2 ).
                              end.
                              if treal-4.prefix <> '':U then do:
                                  if not v-found-paycard then do:
                                  run wp-xmltagopen( 6, "payCards", "" ).
                                  v-found-paycard = yes.
                                  end.
                                  run wp-xmltagopen( 7, "payCard","" ).
                                  run wp-xmltagput( 8, "num", string( treal-4.prefix ), 0 ).
                                  run wp-xmltagput( 8, "quantity", string( v-is-out * treal-4.qnty1 ), 3 ).
                                  run wp-xmltagput( 8, "sumr", string( v-is-out * treal-4.netto ), 2 ).
                                  run wp-xmltagclose( 7, "payCard" ).
                              end.
                              if last-of( treal-4.curr-code ) then do:
                                  if v-found-paycard then do:
                                  run wp-xmltagclose( 6, "payCards" ).
                                  end.
                                  if v-found-paycode then do:
                                  run wp-xmltagclose( 5, "payCode" ).
                                  end.
                              end.
                           end.
                        end.
                    end.
                end case.
            end.
            run wp-xmltagclose( 4, "goodPayCode" ).
        end.
    end.
end.
end procedure.
procedure get-base-code-okv :
define input parameter p-base-code          as integer          no-undo.
define output parameter p-base-code-okv     as integer          no-undo.
    define buffer buf_currency      for ub.currency.
do
for buf_currency
on error undo, return error
:
    find first buf_currency no-lock
         where buf_currency.curr-code = p-base-code
    .
    assign
        p-base-code-okv = buf_currency.okv-code
    .
end.
end procedure.
procedure export-bc-price :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-doc-code  as character no-undo .
  define input  parameter p-b-code    as integer   no-undo .
  define buffer base-bar-code             for ub.bar-code.
  define buffer buf_bar-code              for ub.bar-code.
  define buffer buf_units                 for ub.units.
  define buffer buf_price-list            for ub.price-list.
  define variable v-doc-num     as character          no-undo .
  define variable v-price-sale  as decimal            no-undo .
  define variable v-road-tax    as decimal            no-undo .
  define variable v-excise      as decimal            no-undo .
do for base-bar-code
     , buf_bar-code
     , buf_units
     , buf_price-list
on error undo, return error return-value
:
  find base-bar-code no-lock
    where base-bar-code.b-code = p-b-code
  no-error .
  if not available base-bar-code
  then do:
    return .
  end.
  bc-cycle:
  for each buf_price-list no-lock
    where  buf_price-list.doc-num     = p-doc-code
      and  buf_price-list.price-type  = ''
    , each buf_bar-code no-lock
    where buf_bar-code.b-code    = buf_price-list.b-code
      and buf_bar-code.gds-code  = base-bar-code.gds-code
      and buf_bar-code.node-code = base-bar-code.node-code
      and buf_bar-code.part-code = base-bar-code.part-code
      and buf_bar-code.in-code   = base-bar-code.in-code
  :
    assign
      v-price-sale = buf_price-list.price-sale
    .
    run wp-xmltagopen in this-procedure ( input 4, input "bcPrice", input "" ).
    run wp-xmltagput( 5, "bCode"      , string( buf_bar-code.b-code         ), 0 ).
    run wp-xmltagput( 5, "unitCli"    , string( buf_bar-code.unit-cli       ), 0 ).
    run wp-xmltagput( 5, "cliBaseRate", string( buf_bar-code.cli-base-rate  ), 0 ).
    run wp-xmltagput( 5, "priceSale"  , string( v-price-sale                ), 0 ).
    run wp-xmltagclose in this-procedure ( input 4, input "bcPrice" ).
  end.
end.
end procedure.
procedure calc-lines :
do
on error undo, return error
:
  define input parameter  p-doc-code      as character        no-undo.
  define output parameter p-sum-all-parts as decimal          no-undo.
  DEFINE BUFFER t-doc FOR trn-doc.
  define variable p-fact-qnty             as decimal          no-undo.
  find first t-doc no-lock
       where t-doc.doc-code   = p-doc-code
       no-error.
  if avail t-doc then
       ASSIGN
       p-sum-all-parts = vat-rubl .
end .
end procedure.
