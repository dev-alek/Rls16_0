block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-xml-file-name      as character        no-undo.
define input parameter p-date               as date             no-undo.
define input parameter p-range              as integer          no-undo.
define input parameter p-obj-list           as character        no-undo.
define input parameter hedt                 as handle           no-undo.
define input parameter hcnt                 as handle           no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcs-day.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcs-day.p $":U .
define variable vss-description as character no-undo init "Выгрузка свёртки по объектам по датам для внешней системы".
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
define  temp-table temp-host no-undo
  field host-code like ub.store.host-code
  index xpk host-code
.
define  temp-table temp-obj no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field host-code like ub.store.host-code
  field db-num    like ub.clients.db-num
  index xpk  obj-type obj-code
  index xie1 host-code
  index xie2 db-num host-code
.
procedure init-temphost:
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .
  define buffer buf_temp-host for temp-host .
  define buffer buf_temp-obj for temp-obj .
  do
  on error undo, return error return-value
  :
    for each buf_store
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_store.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_store.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'скл':U
          and buf_clients.obj-code = buf_store.obj-code
        no-error .
      if not available buf_clients
      then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'скл':U buf_store.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'скл':U
        buf_temp-obj.obj-code  = buf_store.obj-code
        buf_temp-obj.host-code = buf_store.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
    for each buf_shop
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_shop.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_shop.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'маг':U
          and buf_clients.obj-code = buf_shop.obj-code
        no-error .
      if not available buf_clients then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'маг':U buf_shop.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'маг':U
        buf_temp-obj.obj-code  = buf_shop.obj-code
        buf_temp-obj.host-code = buf_shop.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
  end.
end.
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DEF STREAM stmXMLHead.
DEF STREAM stmXMLBody.
DEF STREAM stmXMLLog.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "X(65)" no-undo
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
FUNCTION w-XMLPutParamInTag RETURNS CHAR (INPUT sParName AS CHAR, INPUT sToPlace AS CHAR,
                                          INPUT iFlagEmpty AS INTEGER).
  DEF VAR sOut AS CHAR FORMAT "X(255)" NO-UNDO.
  IF sToPlace = "" OR sToPlace = ? OR sToPlace = "0" THEN
    DO:
      IF iFlagEmpty = 0 THEN RETURN "".
      ELSE IF iFlagEmpty = 1                    THEN RETURN sParName + "=&#034;&#034;".
      ELSE IF iFlagEmpty = 2 AND sToPlace = "0" THEN RETURN sParName + "=&#034;0&#034;".
      ELSE IF iFlagEmpty = 3 AND sToPlace = ""  THEN RETURN sParName + "=&#034;&#034;".
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
PROCEDURE wp-XMLTagOpen:
  DEF INPUT PARAM iStmNum   AS INTEGER NO-UNDO.
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName  AS CHAR NO-UNDO.
  DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
    run xmlchar-encode in this-procedure (
          input sParValue
        , output sParValue
    ).
   if istmnum = 1
   then do:
        PUT STREAM stmXMLHead UNFORMATTED chr(10) + FILL(" ", 4 * iTagLevel) +
                        "<" + sTagName + (IF sParValue = "" OR sParValue = ? then "" ELSE " ") +
                        sParValue + ">".
   end.
   else do:
        PUT STREAM stmXMLBody UNFORMATTED chr(10) + FILL(" ", 4 * iTagLevel) +
                        "<" + sTagName + (IF sParValue = "" OR sParValue = ? then "" ELSE " ") +
                        sParValue + ">".
   end.
END PROCEDURE.
PROCEDURE wp-XMLTagPut:
  DEF INPUT PARAM iStmNum   AS INTEGER NO-UNDO.
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
  DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
  DEF INPUT PARAM iFlagEmpty AS INTEGER NO-UNDO.
   if istmnum = 1
   then do:
        IF  iFlagEmpty = 1
        OR (iFlagEmpty = 0 AND (sParValue <> "" AND sParValue <> ?) )
        OR (iFlagEmpty = 2 AND (sParValue <> "" AND sParValue <> ? AND sParValue <> "0"))
        OR (iFlagEmpty = 3 AND (sParValue <> "" AND sParValue <> ? AND CAPS(sParValue) <> "NO"))
        THEN DO:
            run xmlchar-encode in this-procedure (
                  input sParValue
                , output sParValue
            ).
            PUT STREAM stmXMLHead UNFORMATTED chr(10) + FILL(" ", 4 * iTagLevel) +
                                '<' + sTagName + '>' + sParValue + '</' + sTagName + '>'.
        END.
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
            PUT STREAM stmXMLBody UNFORMATTED chr(10) + FILL(" ", 4 * iTagLevel) +
                                '<' + sTagName + '>' + sParValue + '</' + sTagName + '>'.
        END.
   end.
END PROCEDURE.
PROCEDURE wp-XMLTagClose:
  DEF INPUT PARAM iStmNum   AS INTEGER NO-UNDO.
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
   if istmnum = 1
   then do:
        PUT STREAM stmXMLHead UNFORMATTED  chr(10) + FILL(" ", 4 * iTagLevel) + '</' + sTagName + '>'.
   end.
   else do:
        PUT STREAM stmXMLBody UNFORMATTED chr(10) + FILL(" ", 4 * iTagLevel) + '</' + sTagName + '>'.
   end.
END PROCEDURE.
PROCEDURE wp-XMLWriteLog:
  DEF INPUT PARAMETER sFileName AS CHAR     NO-UNDO.
  DEF INPUT PARAMETER iLogLevel AS INTEGER  NO-UNDO.
  DEF INPUT PARAMETER sToWrite  AS CHAR     NO-UNDO.
OUTPUT STREAM stmXMLLog TO VALUE(sFileName) APPEND.
    PUT STREAM stmXMLLog UNFORMATTED chr(10).
    PUT STREAM stmXMLLog UNFORMATTED (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                      OR sToWrite = "&Line") THEN "" ELSE
                                      cur-time-string-sec() + " ").
    PUT STREAM stmXMLLog UNFORMATTED
            (IF sToWrite = "&Line" THEN FILL("-", 80)
             ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
             ELSE sToWrite).
OUTPUT STREAM stmXMLLog CLOSE.
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
procedure rcs-xml-write-header:
do
on error undo, return error
:
define input parameter p-num-tables         as integer      no-undo.
define input parameter p-xml-file-name-head as character    no-undo.
define input parameter p-table-id-head      as character    no-undo.
define input parameter p-xml-file-name-body as character    no-undo.
define input parameter p-table-id-body      as character    no-undo.
    define variable v-reportnumber          as integer      no-undo.
    run get-next-reportnumber in this-procedure (
        output v-reportnumber
    ) no-error.
    if error-status :error
    then do:
        assign
            v-reportnumber = 0
        .
    end.
    output stream stmXMLHead to value( p-xml-file-name-head + ".xm1" ) convert target "1251".
        put stream stmXMLHead unformatted "<DESTINATION_ROID " + p-table-id-head + ">".
        run wp-xmltagopen( 1, 0, "mail Parameters","").
        run wp-xmltagput( 1, 1, "X-ReportType",    string( 1 ), 0).
        run wp-xmltagput( 1, 1, "X-IDChannel",     string( 3 ), 0).
        run wp-xmltagput( 1, 1, "X-ReportNumber",  string( v-reportnumber ), 0).
        run wp-xmltagclose( 1, 0, "mail Parameters").
        put stream stmXMLHead unformatted skip "<ROWSET>".
    output stream stmXMLHead close.
    if p-num-tables > 1
    then do:
        output stream stmXMLBody to value( p-xml-file-name-body + ".xm1" ) convert target "1251".
            put stream stmXMLBody unformatted "<DESTINATION_ROID " + p-table-id-body + ">".
            run wp-xmltagopen( 2, 0, "mail Parameters","").
            run wp-xmltagput( 2, 1, "X-ReportType",    string( 1 ), 0).
            run wp-xmltagput( 2, 1, "X-IDChannel",     string( 3 ), 0).
            run wp-xmltagput( 2, 1, "X-ReportNumber",  string( v-reportnumber ), 0).
            run wp-xmltagclose( 2, 0, "mail Parameters").
            put stream stmXMLBody unformatted skip "<ROWSET>".
        output stream stmXMLBody close.
    end.
end.
end procedure.
procedure rcs-xml-write-footer:
do
on error undo, return error
:
define input parameter p-num-tables         as integer      no-undo.
define input parameter p-xml-head-file-name as character    no-undo.
define input parameter p-xml-body-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
    output stream stmXMLHead to value( p-xml-head-file-name + ".xm1" ) convert target "1251" append.
       put stream stmXMLHead unformatted skip "</ROWSET>" chr(10).
    output stream stmXMLHead close.
    if p-num-tables > 1
    then do:
        output stream stmXMLBody to value( p-xml-body-file-name + ".xm1" ) convert target "1251" append.
            put stream stmXMLBody unformatted skip "</ROWSET>" chr(10).
        output stream stmXMLBody close.
    end.
end.
end procedure.
function format-decimal returns character ( input p-decimal as decimal ).
    if p-decimal = ?
    then do:
        return "?".
    end.
    else do:
        if abs( p-decimal ) < 1
        then do:
            return right-trim( string( p-decimal, "-9.9999999999" ), "0" ).
        end.
        else do:
            return string( p-decimal ).
        end.
    end.
end function.
procedure get-next-reportnumber :
do
on error undo, return error
:
define output parameter p-reportnumber as integer      no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = 'все':U
           and buf_usr-flt.call-point = 'тек':U
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = 'все':U
            buf_usr-flt.call-point   = 'тек':U
            buf_usr-flt.Naim = "1"
        .
    end.
    assign
        p-reportnumber   = integer( buf_usr-flt.Naim )
        buf_usr-flt.Naim = string( p-reportnumber + 1 )
    .
end.
end procedure.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure get-shops-type-and-code :
do
on error undo, return error
:
define input parameter p-shops-id           as character    no-undo.
define output parameter p-shops-obj-type    as character    no-undo.
define output parameter p-shops-obj-code    as integer      no-undo.
    define buffer buf_rcs-shops     for rcs-shops.
    find first buf_rcs-shops no-lock
         where buf_rcs-shops.id = p-shops-id
    no-error.
    if not available buf_rcs-shops
    then do:
        undo, return error "get-shops-id: Не найден объект."
                + chr(10) + "ID объекта: " + p-shops-id
        .
    end.
    else do:
        assign
            p-shops-obj-type    = buf_rcs-shops.obj-type
            p-shops-obj-code    = buf_rcs-shops.obj-code
        .
    end.
end.
end procedure.
procedure get-destination-id :
do
on error undo, return error
:
define input parameter p-destination-name   as character    no-undo.
define output parameter p-destination-id    as character    no-undo.
    define buffer buf_rcs-destn     for rcs-destn.
    find first buf_rcs-destn no-lock
         where buf_rcs-destn.name = p-destination-name
    no-error.
    if not available buf_rcs-destn
    then do:
        assign
            p-destination-id = ""
        .
    end.
    else do:
        assign
            p-destination-id = buf_rcs-destn.destination_rowid
        .
    end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define temp-table temp_good no-undo
        field id                    as character
        field gds-code              like goods.gds-code
        field artic                 like goods.artic
        field prod-type             like goods.prod-type
        field prod-code             like goods.prod-code
        field gds-name              like goods.gds-name
        field qnty-first            like stk-line.fact-qnty
        field qnty-last             like stk-line.fact-qnty
        index pi is primary unique gds-code
    .
    define temp-table temp_good-sum no-undo
        field tag-name              as character
        field first-rubl            like stk-line.sum-rubl
        field first-base            like stk-line.sum-base
        field last-rubl             like stk-line.sum-rubl
        field last-base             like stk-line.sum-base
        field write-result          as logical
        index pi is primary unique tag-name
    .
    define temp-table temp_turn-over no-undo
        field ext-doc-type          like ot-tot.ext-doc-type
        field qnty                  like ot-tot.fact-qnty
        field sum-rubl              like ot-tot.sum-rubl
        field sum-rubl-cost         like ot-tot.sum-rubl
        field sum-base              like ot-tot.sum-base
        field sum-base-cost         like ot-tot.sum-base
        field write-result          as logical
        index pi is primary unique ext-doc-type
    .
    define variable sHomeDir            as character            no-undo.
    define variable sOutFile            as character            no-undo.
    define variable sLogFile            as character            no-undo.
    define variable bLocked             as logical    init no   no-undo.
    define variable iRep                as integer    init 0    no-undo.
    define variable ErrorLevel          as integer              no-undo.
    define variable v-counter           as integer           no-undo.
    define variable v-obj-counter       as integer           no-undo.
    define variable v-log-file-name     as character         no-undo.
    define variable v-fact-order-from   like stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-object-state      as character            no-undo.
    define variable v-rcs-object-id     as character         no-undo.
    define variable v-log-string        as character         no-undo.
    define variable v-write-good        as logical           no-undo.
    define variable v-destination-rowid as character         no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.
    define buffer buf_rcs-shops     for rcs-shops.
do
for buf_rcs-shops
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    RUN init-temphost.
    assign
        v-log-string = ", по всем фирмам"
    .
    case p-range:
    when 2
    then do:
        for each temp-obj
        where temp-obj.host-code <> v-cntxt-host-code-obj
        :
            delete temp-obj.
        end.
        assign
            v-log-string = ", по фирме (код фирмы " + string( v-cntxt-host-code-obj ) + ")"
        .
    end.
    when 3
    then do:
        for each temp-obj
        :
            delete temp-obj.
        end.
        do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
        :
            create temp-obj.
            assign
                temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
                temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
            no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка чтения списка объектов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  temp-obj.obj-type
  ,input  temp-obj.obj-code
  ,output temp-obj.host-code
  ) no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Не найдена фирма для объекта" temp-obj.obj-type temp-obj.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        assign
            v-log-string = ", по объектам: " + p-obj-list
        .
    end.
    end case.
    ASSIGN v-log-file-name = p-xml-file-name + ".log".
    run get-destination-id in this-procedure (
          input "RETAIL1_CONVOLUTION"
        , output v-destination-rowid
    ) no-error.
    if error-status :error
    or v-destination-rowid = ""
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось получить DESTINATION-ROWID для RETAIL1_CONVOLUTION."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    run rcs-xml-write-header in this-procedure (
              input 1
            , input p-xml-file-name
            , input v-destination-rowid
            , input ""
            , input ""
    ) no-error .
    if error-status :error
    then do:
        undo, return error "rcs-docs: Ошибка записи заголовка файла." + chr(10) + return-value.
    end.
object-of-list:
for each temp-obj
:
    for each temp_good
    :
        delete temp_good.
    end.
    find first buf_rcs-shops no-lock
         where buf_rcs-shops.obj-type = temp-obj.obj-type
           and buf_rcs-shops.obj-code = temp-obj.obj-code
    no-error.
    if not available buf_rcs-shops
    then do:
        message
            "В настройках не определено соответствие объекта " temp-obj.obj-type temp-obj.obj-code
            skip "объекту RCS. Сведения о товарах по этому объекту не могут быть экспортированы."
        view-as alert-box information.
        next object-of-list.
    end.
    run wp-XMLWriteEDT( hEDT, 1, string(temp-obj.obj-type) + " " + string(temp-obj.obj-code) ).
    run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов").
    process events.
    run bge/bge-ahz.p (
          input p-mainmenu-handle
        , input temp-obj.obj-type
        , input temp-obj.obj-code
        , input yes
        , input no
        , input no
        , input v-today
        , input v-today
        , output v-archive-ok
        , output v-comment
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка проверки архивов на объекте."
        skip "Тип объекта:" temp-obj.obj-type
        skip "Код объекта:" temp-obj.obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов завершен. Идет выгрузка данных по объекту").
    process events.
    run rep/get-fo.p (
                  input  temp-obj.obj-type
                , input  temp-obj.obj-code
                , input  p-date
                , input  p-date
                , output v-fact-order-from
                , output v-fact-order-to
                , output v-docs-exists
                ).
    if v-docs-exists = no
    then do:
        run wp-XMLWriteEDT( hEDT, 4, "Нет закрытых документов за дату " + string( p-date ) ).
        process events.
        next object-of-list .
    end.
    run wp-XMLShowCNT(hCNT).
    run calc-conv in this-procedure (
                      input buf_rcs-shops.id
                    , input temp-obj.obj-type
                    , input temp-obj.obj-code
                    , input p-date
                    , input v-fact-order-from
                    , input v-fact-order-to
                    , input p-xml-file-name
                    , input v-log-file-name
                    , input hEDT
                    , input hCNT
                                    ) no-error.
    if error-status :error
    then do:
        message
            "Ошибка при выгрузке данных свертки."
        view-as alert-box.
        run wp-XMLWriteEDT( hEDT, 1, string( return-value ) ).
        process events.
    end.
    run wp-XMLHideCNT(hCNT).
    process events.
end.
    run rcs-xml-write-footer in this-procedure (
              input 1
            , input p-xml-file-name
            , input ""
    ) no-error .
    if error-status :error
    then do:
        undo, return error "rcs-docs: Ошибка окончания записи файла." + chr(10) + return-value.
    end.
end.
procedure calc-conv :
    define buffer buf_gds-obj       for gds-obj.
do
for buf_gds-obj
on error undo, return error
:
define input parameter p-object-id          as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-date               as date         no-undo.
define input parameter p-fact-order-from    as integer      no-undo.
define input parameter p-fact-order-to      as integer      no-undo.
define input parameter p-xml-file-name      as character    no-undo.
define input parameter p-log-file-name      as character    no-undo.
define input parameter p-ed                 as handle       no-undo.
define input parameter p-fi                 as handle       no-undo.
define variable v-good-counter  as integer        no-undo.
define variable v-qnty          as integer        no-undo.
define variable v-current-price as decimal        no-undo.
define buffer buf_goods                 for goods.
define buffer buf_rcs-retail1product    for rcs-retail1product.
output stream stmXMLHead to value( p-xml-file-name + ".xm1") convert target "1251" append.
create temp_good.
good-on-object:
for each buf_gds-obj no-lock
   where buf_gds-obj.obj-type   = p-obj-type
     and buf_gds-obj.obj-code   = p-obj-code
:
    if buf_gds-obj.first-doc > p-date
        or ( buf_gds-obj.last-doc < p-date
            and buf_gds-obj.fact-qnty = 0
            and buf_gds-obj.avrg-qnty = 0
           )
    then do:
        next good-on-object.
    end.
    find first buf_goods no-lock
         where buf_goods.artic      = buf_gds-obj.artic
           and buf_goods.prod-type  = buf_gds-obj.prod-type
           and buf_goods.prod-code  = buf_gds-obj.prod-code
    no-error .
    if not available buf_goods
    then do:
        undo, return error "calc-conv: Не найдена карточка товара. "
            + chr(10) + "Артикул:       " + buf_gds-obj.artic
            + chr(10) + "Производитель: " + buf_gds-obj.prod-type + " " + string( buf_gds-obj.prod-code )
        .
    end.
    else do:
        assign
            temp_good.gds-code              = buf_goods.gds-code
        .
        find first buf_rcs-retail1product no-lock
             where buf_rcs-retail1product.gds-code = buf_goods.gds-code
        no-error .
        if not available buf_rcs-retail1product
        then do:
            run wp-XMLWriteEDT( hEDT, 1, "Не найден PRODUCT для товара с кодом " + string( buf_goods.gds-code )  ).
            assign
                temp_good.id = "0"
            .
        end.
        else do:
            assign
                temp_good.id = buf_rcs-retail1product.id
            .
        end.
    end.
    assign
        temp_good.artic                 = buf_gds-obj.artic
        temp_good.prod-type             = buf_gds-obj.prod-type
        temp_good.prod-code             = buf_gds-obj.prod-code
        temp_good.gds-name              = ""
        temp_good.qnty-first            = 0
        temp_good.qnty-last             = 0
        v-write-good                    = no
    .
    run form-turn-over in this-procedure ( input rowid( buf_gds-obj ), input 'es':U ).
    run form-turn-over in this-procedure ( input rowid( buf_gds-obj ), input 'rs':U ).
    run form-stk in this-procedure ( input rowid( buf_gds-obj ), input 'cost':U, input "cost", output temp_good.qnty-first, output temp_good.qnty-last ).
    run form-stk in this-procedure ( input rowid( buf_gds-obj ), input 'crsa':U, input "sale", output v-qnty, output v-qnty ).
    if v-write-good = yes
    then do:
        run get-current-price in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input temp_good.artic
            , input temp_good.prod-type
            , input temp_good.prod-code
            , output v-current-price
        ) no-error .
        if error-status :error
        then do:
            undo, return error "calc-conv: Не удалось вычислить текущую продажную цену для товара на объекте."
                                + chr(10) + "Артикул товара:    " + temp_good.artic
                                + chr(10) + "Наименование товара: " + temp_good.gds-name
                                + return-value.
        end.
        run process-result in this-procedure (
              input p-object-id
            , input string( v-current-price )
            , input string( year( p-date ) ) + string( month( p-date ), "99" ) + string( day( p-date ), "99" ) + string( "000000" )
            , input buf_gds-obj.obj-type
            , input buf_gds-obj.obj-code
        ).
    end.
end.
output stream stmXMLHead close.
end.
end procedure.
procedure form-turn-over :
define input parameter p-gds-obj-rowid  as rowid            no-undo.
define input parameter p-ext-doc-type   like ot-tot.ext-doc-type    no-undo.
    define buffer buf_gds-obj       for gds-obj.
    define buffer buf_sale_stk-line      for stk-line.
    define buffer buf_cost_stk-line      for stk-line.
do
for buf_gds-obj
  , buf_sale_stk-line
  , buf_cost_stk-line
on error undo, return error
:
find first buf_gds-obj no-lock
     where rowid( buf_gds-obj ) = p-gds-obj-rowid
.
find first temp_turn-over
     where temp_turn-over.ext-doc-type  = p-ext-doc-type
no-error.
if not available temp_turn-over
then do:
    create temp_turn-over.
    assign
        temp_turn-over.ext-doc-type = p-ext-doc-type
    .
end.
assign
    temp_turn-over.qnty             = 0
    temp_turn-over.sum-rubl         = 0
    temp_turn-over.sum-rubl-cost    = 0
    temp_turn-over.sum-base         = 0
    temp_turn-over.sum-base-cost    = 0
.
run fill-turn-over in this-procedure (
        input buf_gds-obj.obj-type
      , input buf_gds-obj.obj-code
      , input buf_gds-obj.artic
      , input buf_gds-obj.prod-type
      , input buf_gds-obj.prod-code
      , input 'sadt':U + p-ext-doc-type
      , input v-fact-order-from
      , input v-fact-order-to
      , input yes
) no-error.
if error-status :error
then do:
    undo, return error "Ошибка вычисления оборотов по товару." + chr(10) + return-value.
end.
run fill-turn-over in this-procedure (
        input buf_gds-obj.obj-type
      , input buf_gds-obj.obj-code
      , input buf_gds-obj.artic
      , input buf_gds-obj.prod-type
      , input buf_gds-obj.prod-code
      , input 'csdt':U + p-ext-doc-type
      , input v-fact-order-from
      , input v-fact-order-to
      , input no
) no-error.
if error-status :error
then do:
    undo, return error "Ошибка вычисления оборотов по товару." + chr(10) + return-value.
end.
if   temp_turn-over.qnty     = 0
 and temp_turn-over.sum-rubl = 0
 and temp_turn-over.sum-base = 0
then do:
    assign
        temp_turn-over.write-result = no
    .
end.
else do:
    assign
        temp_turn-over.write-result = yes
        v-write-good                = yes
    .
end.
end.
end procedure.
procedure fill-turn-over :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-artic              as character    no-undo.
define input parameter p-prod-type          as character    no-undo.
define input parameter p-prod-code          as integer      no-undo.
define input parameter p-sum-type           as character    no-undo.
define input parameter p-fact-order-from    as integer      no-undo.
define input parameter p-fact-order-to      as integer      no-undo.
define input parameter p-calc-qnty          as logical      no-undo.
    define buffer buf_stk-line      for stk-line.
    find last buf_stk-line no-lock
        where buf_stk-line.obj-type   = p-obj-type
          and buf_stk-line.obj-code   = p-obj-code
          and buf_stk-line.artic      = p-artic
          and buf_stk-line.prod-type  = p-prod-type
          and buf_stk-line.prod-code  = p-prod-code
          and buf_stk-line.sum-type   = p-sum-type
          and buf_stk-line.cat-id     = '##,##':U
          and buf_stk-line.fact-order <= p-fact-order-to
    use-index category
    no-error.
    if available buf_stk-line
    then do:
        if p-calc-qnty = yes
        then do:
            assign
                temp_turn-over.qnty         = temp_turn-over.qnty     + buf_stk-line.fact-qnty
                temp_turn-over.sum-rubl     = temp_turn-over.sum-rubl + buf_stk-line.sum-rubl
                temp_turn-over.sum-base     = temp_turn-over.sum-base + buf_stk-line.sum-base
            .
        end.
        else do:
            assign
                temp_turn-over.sum-rubl-cost    = temp_turn-over.sum-rubl-cost + buf_stk-line.sum-rubl
                temp_turn-over.sum-base-cost    = temp_turn-over.sum-base-cost + buf_stk-line.sum-base
            .
        end.
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type     = p-obj-type
            and buf_stk-line.obj-code     = p-obj-code
            and buf_stk-line.artic        = p-artic
            and buf_stk-line.prod-type    = p-prod-type
            and buf_stk-line.prod-code    = p-prod-code
            and buf_stk-line.sum-type     = p-sum-type
            and buf_stk-line.cat-id       = '##,##':U
            and buf_stk-line.fact-order  <= p-fact-order-from
        use-index category
        no-error.
        if available buf_stk-line
        then do:
            if p-calc-qnty = yes
            then do:
                assign
                    temp_turn-over.qnty       = temp_turn-over.qnty     - buf_stk-line.fact-qnty
                    temp_turn-over.sum-rubl   = temp_turn-over.sum-rubl - buf_stk-line.sum-rubl
                    temp_turn-over.sum-base   = temp_turn-over.sum-base - buf_stk-line.sum-base
                .
            end.
            else do:
                assign
                    temp_turn-over.sum-rubl-cost  = temp_turn-over.sum-rubl-cost - buf_stk-line.sum-rubl
                    temp_turn-over.sum-base-cost  = temp_turn-over.sum-base-cost - buf_stk-line.sum-base
                .
            end.
        end.
    end.
end.
end procedure.
procedure form-stk :
define input parameter p-gds-obj-rowid  as rowid            no-undo.
define input parameter p-sum-type    like stk-tot.sum-type            no-undo.
define input parameter p-tag-name    as character                     no-undo.
define output parameter p-qnty-first like stk-tot.fact-qnty  init 0   no-undo.
define output parameter p-qnty-last  like stk-tot.fact-qnty  init 0   no-undo.
    define buffer buf_gds-obj       for gds-obj.
do
for buf_gds-obj
on error undo, return error
:
    find first buf_gds-obj no-lock
         where rowid( buf_gds-obj ) = p-gds-obj-rowid
    .
    find first temp_good-sum
         where temp_good-sum.tag-name = p-tag-name
    no-error.
    if not available temp_good-sum
    then do:
        create temp_good-sum.
        assign
            temp_good-sum.tag-name          = p-tag-name
        .
    end.
    assign
        temp_good-sum.first-rubl        = 0
        temp_good-sum.first-base        = 0
        temp_good-sum.last-rubl         = 0
        temp_good-sum.last-base         = 0
    .
    find last stk-line no-lock
        where stk-line.obj-type  = buf_gds-obj.obj-type
          and stk-line.obj-code  = buf_gds-obj.obj-code
          and stk-line.artic     = buf_gds-obj.artic
          and stk-line.prod-type = buf_gds-obj.prod-type
          and stk-line.prod-code = buf_gds-obj.prod-code
          and stk-line.sum-type  = p-sum-type
          and stk-line.cat-id    = '##,##':U
          and stk-line.fact-order <= v-fact-order-to
    use-index category
    no-error.
    if available stk-line
    then do:
        assign
            p-qnty-last             = stk-line.fact-qnty
            temp_good-sum.last-rubl = temp_good-sum.last-rubl + stk-line.sum-rubl
            temp_good-sum.last-base = temp_good-sum.last-base + stk-line.sum-base
        .
    end.
    if  buf_gds-obj.last-doc < p-date
    then do:
        assign
            p-qnty-first                = p-qnty-last
            temp_good-sum.first-rubl    = temp_good-sum.last-rubl
            temp_good-sum.first-base    = temp_good-sum.last-base
        .
    end.
    else do:
        find last stk-line no-lock
            where stk-line.obj-type  = buf_gds-obj.obj-type
              and stk-line.obj-code  = buf_gds-obj.obj-code
              and stk-line.artic     = buf_gds-obj.artic
              and stk-line.prod-type = buf_gds-obj.prod-type
              and stk-line.prod-code = buf_gds-obj.prod-code
              and stk-line.sum-type  = p-sum-type
              and stk-line.cat-id    = '##,##':U
              and stk-line.fact-order <= v-fact-order-from
        use-index category
        no-error.
        if available stk-line
        then do:
            assign
                p-qnty-first                = p-qnty-first             + stk-line.fact-qnty
                temp_good-sum.first-rubl    = temp_good-sum.first-rubl + stk-line.sum-rubl
                temp_good-sum.first-base    = temp_good-sum.first-base + stk-line.sum-base
            .
        end.
    end.
    if   p-qnty-first             = 0
     and temp_good-sum.first-rubl = 0
     and temp_good-sum.first-base = 0
    then do:
        assign
            temp_good-sum.write-result = no
        .
    end.
    else do:
        assign
            temp_good-sum.write-result = yes
            v-write-good               = yes
        .
    end.
end.
end procedure.
procedure process-result :
do
on error undo, return error
:
define input parameter p-object-id              as character        no-undo.
define input parameter p-current-price-string   as character        no-undo.
define input parameter p-date-string            as character        no-undo.
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
    define variable v-good-counter      as integer           no-undo.
    define variable v-sum-all           as decimal           no-undo.
    define variable v-sum-all-cost      as decimal           no-undo.
    define variable v-qnty-all          as decimal           no-undo.
    process events.
    assign
        v-good-counter = v-good-counter + 1
    .
    run wp-xmltagopen( 1, 1, "ROW","").
    run wp-xmltagput( 1, 2, "SITE_ID"    , string( p-object-id )         , 0 ).
    run wp-xmltagput( 1, 2, "DOCDATE"    , p-date-string                 , 0 ).
    run wp-xmltagput( 1, 2, "TOV"        , string( temp_good.id )        , 0 ).
    run wp-xmltagput( 1, 2, "gdsCode"    , string( temp_good.gds-code )  , 0 ).
    run wp-xmltagput( 1, 2, "PRICE_COST" , p-current-price-string               , 0 ).
    run wp-xmltagput( 1, 2, "COUNT_REST" , format-decimal( temp_good.qnty-last ), 0 ).
    for each temp_turn-over
       where temp_turn-over.write-result = yes
    break by temp_turn-over.ext-doc-type
    :
        assign
            v-sum-all       = v-sum-all      + temp_turn-over.sum-rubl
            v-qnty-all      = v-qnty-all + temp_turn-over.qnty
            v-sum-all-cost  = v-sum-all-cost + temp_turn-over.sum-rubl-cost
        .
    end.
    run wp-xmltagput( 1, 2, "COUNT_SALE", format-decimal(  ( -1 ) * v-qnty-all      ), 0 ).
    run wp-xmltagput( 1, 2, "SUM_SALE"  , format-decimal(  ( -1 ) * v-sum-all       ), 0 ).
    run wp-xmltagput( 1, 2, "SUM_COST"  , format-decimal(  ( -1 ) * v-sum-all-cost  ), 0 ).
    run wp-xmltagclose( 1, 1, "ROW").
    if v-good-counter modulo 25 = 0
    then do:
        run wp-XMLWriteCnt( hcnt, "Товар " + p-obj-type + string( p-obj-code ) + "  " + string( v-good-counter ) ).
        process events.
    end.
end.
end procedure.
procedure get-current-price :
do
on error undo, return error
:
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-artic     as character    no-undo.
define input parameter p-prod-type as character    no-undo.
define input parameter p-prod-code as integer      no-undo.
define output parameter p-current-price as decimal      no-undo.
    define buffer buf_price-list    for price-list.
    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    find first buf_goods no-lock
         where buf_goods.artic      = p-artic
           and buf_goods.prod-type  = p-prod-type
           and buf_goods.prod-code  = p-prod-code
    no-error .
    if not available buf_goods
    then do:
        undo, return error "get-current-price: Ошибка поиска товара в базе данных." + chr(10) + return-value.
    end.
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    if not available buf_gds-prt
    then do:
        undo, return error "get-current-price: Ошибка поиска корневого признака товара в базе данных." + chr(10) + return-value.
    end.
    find last buf_price-list no-lock
        where buf_price-list.obj-type   = p-obj-type
          and buf_price-list.obj-code   = p-obj-code
          and buf_price-list.b-code     = buf_goods.gds-code
          and buf_price-list.price-type = "":U
    use-index fact-close
    no-error.
    if not available buf_price-list
    then do:
        assign
            p-current-price = 0
        .
    end.
    else do:
        assign
            p-current-price = buf_price-list.price-sale
        .
    end.
end.
end procedure.
