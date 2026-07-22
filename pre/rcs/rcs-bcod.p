block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-xml-file-name      as character        no-undo.
define input parameter p-date               as date             no-undo.
define input parameter p-range              as integer          no-undo.
define input parameter p-obj-list           as character        no-undo.
define input parameter p-ed                 as handle           no-undo.
define input parameter p-fi                 as handle           no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcs-bcod.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcs-bcod.p $":U .
define variable vss-description as character no-undo init "Экспорт бар-кодов во внешнюю систему".
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
DEF STREAM stmXMLHead.
DEF STREAM stmXMLBody.
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
define variable vss-include-info3 as character format "X(65)" no-undo
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
    define variable v-counter           as integer           no-undo.
    define variable v-log-file-name     as character         no-undo.
    define variable v-destination-rowid as character         no-undo.
    define variable v-good-counter      as integer           no-undo.
    define variable v-product-id        as character         no-undo.
    define variable v-have-prod-bc      as logical  init no  no-undo.
    define buffer buf_rcs-shops             for rcs-shops.
    define buffer buf_gds-obj               for gds-obj.
    define buffer buf_goods                 for goods.
    define buffer buf_units                 for units.
    define buffer buf_rcs-retail1product    for rcs-retail1product.
    define buffer buf_prod-bc               for prod-bc.
    define buffer buf_bar-code              for bar-code.
do
for buf_rcs-shops
  , buf_gds-obj
  , buf_goods
  , buf_units
  , buf_rcs-retail1product
  , buf_prod-bc
  , buf_bar-code
on error undo, return error
:
    ASSIGN v-log-file-name = p-xml-file-name + ".log".
    run get-destination-id in this-procedure (
          input "RETAIL1_TH_PRODUCT"
        , output v-destination-rowid
    ) no-error.
    if error-status :error
    or v-destination-rowid = ""
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось получить DESTINATION-ROWID для RETAIL1_BARCODE."
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
    output stream stmXMLHead to value( p-xml-file-name + ".xm1") convert target "1251" append.
    for each buf_units no-lock
    :
        for each buf_goods no-lock
           where buf_goods.unit-base = buf_units.unit-name
        :
            assign
                v-good-counter = v-good-counter + 1
                v-have-prod-bc = no
            .
            find first buf_rcs-retail1product no-lock
                 where buf_rcs-retail1product.gds-code = buf_goods.gds-code
            no-error.
            if not available buf_rcs-retail1product
            then do:
                run write-to-log-editor in this-procedure ( p-ed, v-log-file-name, 1, "Товар с кодом " + string( buf_goods.gds-code ) + " не был импортирован." ).
                assign
                    v-product-id = "0"
                .
            end.
            else do:
                assign
                    v-product-id = buf_rcs-retail1product.id
                .
            end.
            for each buf_prod-bc no-lock
               where buf_prod-bc.b-code   = buf_goods.gds-code
            :
                assign
                    v-have-prod-bc = yes
                .
                run process-result in this-procedure (
                      input v-product-id
                    , input buf_goods.gds-code
                    , input buf_prod-bc.b-str
                    , input buf_goods.prod-code
                    , input buf_goods.prod-type
                    , input buf_goods.artic
                    , input buf_goods.gds-name
                ) no-error.
                if error-status :error
                then do:
                    message
                      vss-workfile vss-revision vss-description
                      skip "Ошибка при выводе бар-кодов для товара с ID " + v-product-id +  ", кодом " + string( buf_goods.gds-code )
                      skip return-value
                      skip trim(error-status :get-message(1))
                           trim(error-status :get-message(2))
                           trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
                if v-good-counter modulo 25 = 0
                then do:
                    run wp-XMLWriteCnt( p-fi, "Единица измерения: " + buf_units.unit-name + ". Бар-код для товара с ID " + v-product-id +  "  " + string( v-good-counter ) ).
                    process events.
                end.
            end.
            if v-have-prod-bc = no
            then do:
                for each buf_bar-code no-lock
                   where buf_bar-code.gds-code  = buf_goods.gds-code
                :
                    run process-result in this-procedure (
                          input v-product-id
                        , input buf_goods.gds-code
                        , input string( buf_bar-code.b-code )
                        , input buf_goods.prod-code
                        , input buf_goods.prod-type
                        , input buf_goods.artic
                        , input buf_goods.gds-name
                    ) no-error.
                    if error-status :error
                    then do:
                        message
                        vss-workfile vss-revision vss-description
                        skip "Ошибка при выводе основного бар-кода для товара с ID " + v-product-id +  ", кодом " + string( buf_goods.gds-code )
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                        view-as alert-box error.
                        undo, return error .
                    end.
                    if v-good-counter modulo 25 = 0
                    then do:
                        run wp-XMLWriteCnt( p-fi, "Единица измерения: " + buf_units.unit-name + ". Бар-код для товара с ID " + v-product-id +  "  " + string( v-good-counter ) ).
                        process events.
                    end.
                end.
            end.
        end.
    end.
    output stream stmXMLHead close.
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
procedure process-result :
do
on error undo, return error
:
define input parameter p-product-id as character    no-undo.
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-barcode    as character    no-undo.
define input parameter p-prod-code  as integer      no-undo.
define input parameter p-prod-type  as character    no-undo.
define input parameter p-artic      as character    no-undo.
define input parameter p-gds-name   as character    no-undo.
    run wp-xmltagopen( 1, 1, "ROW","").
        run wp-xmltagput( 1, 2, "PRODUCT_ID"    , string( p-product-id ), 0 ).
        run wp-xmltagput( 1, 2, "WEIGHT_CODE"   , string( p-barcode    ), 0 ).
        run wp-xmltagput( 1, 2, "gdsCode"       , string( p-gds-code   ), 0 ).
        run wp-xmltagput( 1, 2, "PRODUCER_CODE" , string( p-prod-code  ), 0 ).
        run wp-xmltagput( 1, 2, "PRODUCER_TYPE" , string( p-prod-type  ), 0 ).
        run wp-xmltagput( 1, 2, "ARTICUL"       , string( p-artic      ), 0 ).
        run wp-xmltagput( 1, 2, "NAME"          , string( p-gds-name   ), 0 ).
    run wp-xmltagclose( 1, 1, "ROW").
end.
end procedure.
PROCEDURE write-to-log-editor :
do
on error undo, return error
:
  define input parameter hedt               as handle       no-undo.
  define input parameter p-log-file-name    as character    no-undo.
  define input parameter iloglevel          as integer      no-undo.
  define input parameter stowrite           as character    no-undo.
    if valid-handle ( hedt )
    then do:
        hedt :move-to-eof().
        hedt :insert-string( if ( iloglevel = 0
                             or stowrite = "&dline"
                             or stowrite = "&line" )
                             then ""
                             else cur-time-string-sec() + " "
                           ).
        hedt :insert-string( if stowrite = "&line"
                             then fill("-", 80 )
                             else if stowrite = "&dline"
                             then fill("=", 80)
                             else fill(" ", iloglevel) + stowrite).
        hedt :insert-string(chr(10)).
    end.
    output to p-log-file-name append.
    put unformatted
        skip chr(10) cur-time-string-sec() fill(" ", iloglevel) stowrite
    .
    output close.
end.
END PROCEDURE.
