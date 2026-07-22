block-level on error undo, throw.
define input parameter p-host-code       as character               no-undo.
define input parameter p-obj-type        as character               no-undo.
define input parameter p-obj-code        as integer                 no-undo.
define input parameter p-ext-doc-type    as character               no-undo.
define input parameter p-oper-name       as character               no-undo.
define input parameter p-rcs-doc-type    as character               no-undo.
define input parameter p-fact-order-from like stk-tot.fact-order    no-undo.
define input parameter p-fact-order-to   like stk-tot.fact-order    no-undo.
define input parameter p-pay-code        as logical                 no-undo.
define input parameter p-cst             as logical                 no-undo.
define input parameter p-head-file       as character               no-undo.
define input parameter p-body-file       as character               no-undo.
define input parameter sLogFile          as character               no-undo.
define input parameter hEDT              as handle                  no-undo.
define input parameter hCNT              as handle                  no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcs-oper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcs-oper.p $":U .
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
    define variable l-exist-operation   as logical  no-undo.
    define variable v-qnty              like ot-tot.fact-qnty   no-undo.
    define variable v-doc-date          like trn-doc.doc-date   no-undo.
    define variable v-fact-date         like trn-doc.fact-date  no-undo.
    define variable v-pay-code          like trn-doc.fact-date  no-undo.
    define variable v-doc-PS            like trn-doc.PS         no-undo.
    define variable v-parts-cst-code    like parts.cst-code     no-undo.
    define variable v-rcs-doc-id        as character            no-undo.
    define temp-table temp_inkas-pay no-undo
        field pay-code  like inkas-pay.pay-code
        field tot-base  like inkas-pay.tot-base
        field tot-rubl  like inkas-pay.tot-rubl
        field tot-sum   like inkas-pay.tot-sum
    index pi is primary unique pay-code
    .
    define buffer buf_ot-tot-sale           for ot-tot.
    define buffer buf_ot-tot-cost           for ot-tot.
    define buffer buf_ot-tot-crsa           for ot-tot.
    define buffer buf_ot-line-sale          for ot-line.
    define buffer buf_ot-line-cost          for ot-line.
    define buffer buf_ot-line-crsa          for ot-line.
    define buffer buf_doc-line              for doc-line.
    define buffer buf_rcs-shops             for rcs-shops.
    define buffer buf_rcs-retail1subject    for rcs-retail1subject.
    define buffer buf_rcs-retail1product    for rcs-retail1product.
    define buffer buf_rcs-retail1bill       for rcs-retail1bill.
    define buffer buf_rcs-retail1price      for rcs-retail1price.
do
for buf_ot-tot-sale
  , buf_ot-tot-cost
  , buf_ot-tot-crsa
  , buf_ot-line-sale
  , buf_ot-line-cost
  , buf_ot-line-crsa
  , buf_doc-line
  , buf_rcs-shops
  , buf_rcs-retail1subject
  , buf_rcs-retail1product
  , buf_rcs-retail1bill
  , buf_rcs-retail1price
on error undo, return error
:
    assign
    l-exist-operation = no
    .
    output stream stmXMLHead to value( p-head-file + ".xm1") convert target "1251" append .
    output stream stmXMLBody to value( p-body-file + ".xm1") convert target "1251" append .
    run wp-XMLWriteCNT( input hCNT, input "":U ).
    if p-ext-doc-type = 'ot':U
    then do:
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
for each  buf_ot-tot-sale no-lock
    where buf_ot-tot-sale.obj-type     = p-obj-type
      and buf_ot-tot-sale.obj-code     = p-obj-code
      and buf_ot-tot-sale.ext-doc-type = p-ext-doc-type
      and buf_ot-tot-sale.fact-order   > p-fact-order-from
      and buf_ot-tot-sale.fact-order  <= p-fact-order-to
      and buf_ot-tot-sale.sum-type     = 'crsa':U
:
  if not l-exist-operation
  then do:
      run wp-XMLWriteEDT( hEDT, 4, "Операция " + string(p-oper-name) ).
      run wp-XMLWriteLog(sLogFile, 0, "&Line").
      run wp-XMLWriteLog(sLogFile, 1, "XML - Вывод операции " + string(p-oper-name) + " (" + p-ext-doc-type + ")").
      assign
            l-exist-operation = yes
      .
  end.
        find first price-doc no-lock
             where price-doc.doc-num = buf_ot-tot-sale.doc-code
        no-error.
        if not available price-doc
        then do:
            message
                "В архивах найден несуществующий документ переоценки N "
                + string(buf_ot-tot-sale.doc-code)
                view-as alert-box.
            run wp-XMLWriteLog(  sLogFile,
                                        1,
                                "*** ERR: *** Не удалось найти документ переоценки N "
                                + string(buf_ot-tot-sale.doc-code)
                            ).
            undo, leave.
        end.
        else do:
            assign
                v-doc-date  = price-doc.doc-date
                v-fact-date  = price-doc.fact-date
                v-doc-PS    = price-doc.ps
            .
        end.
        find first buf_rcs-retail1price no-lock
             where buf_rcs-retail1price.doc-num = buf_ot-tot-sale.doc-code
        no-error.
        if available buf_rcs-retail1price
        then do:
            assign
                v-rcs-doc-id = buf_rcs-retail1price.price_id
            .
        end.
        else do:
            assign
                v-rcs-doc-id = ""
            .
        end.
      run wp-XMLWriteCnt(
            hcnt,
            "   " + string(buf_ot-tot-sale.doc-code) + " от " + string(v-fact-date))
      .
      process events.
        find first buf_rcs-shops no-lock
             where buf_rcs-shops.obj-type = buf_ot-tot-sale.obj-type
               and buf_rcs-shops.obj-code = buf_ot-tot-sale.obj-code
        no-error.
        if not available buf_rcs-shops
        then do:
            undo, return error "rcs-oper: Не найден ID объекта."
                    + chr(10) + "Тип объекта: " + buf_ot-tot-sale.obj-type
                    + chr(10) + "Код объекта: " + string( buf_ot-tot-sale.obj-code )
            .
        end.
        run wp-xmltagopen( 1, 1, "ROW","").
        run wp-xmltagput( 1, 2, "ID",             buf_ot-tot-sale.doc-code, 0).
        run wp-xmltagput( 1, 2, "RCS_ID",         v-rcs-doc-id,             0).
        run wp-xmltagput( 1, 2, "DDAT",           string( year( v-doc-date ) ) + string( month( v-doc-date ), "99" ) + string( day( v-doc-date ), "99" ) + string( "000000" ), 0).
        run wp-xmltagput( 1, 2, "FDAT",           string( year( v-fact-date ) ) + string( month( v-fact-date ), "99" ) + string( day( v-fact-date ), "99" ) + string( "000000" ), 0).
        run wp-xmltagput( 1, 2, "DNOM",           buf_ot-tot-sale.doc-code, 0).
        run wp-xmltagput( 1, 2, "DTYPE",          string( p-rcs-doc-type ), 0).
        run wp-xmltagput( 1, 2, "STAD",           "1", 0).
        run wp-xmltagput( 1, 2, "DMODE",          ( if p-ext-doc-type = 'ie':U or p-ext-doc-type = 'ot':U then "-1" else "0" ), 0).
        run wp-xmltagput( 1, 2, "SITE",           string( buf_rcs-shops.id ), 0).
        run wp-xmltagput( 1, 2, "MESS",  v-doc-PS, 0).
      .
      for each buf_ot-line-sale no-lock
          where buf_ot-line-sale.doc-code = buf_ot-tot-sale.doc-code
            and buf_ot-line-sale.sum-type = buf_ot-tot-sale.sum-type
      :
          run wp-xmltagopen( 2, 1, "ROW","").
          run wp-xmltagput( 2, 2, "DOC_HEAD_ID",  buf_ot-tot-sale.doc-code, 0).
          find first goods no-lock
               where goods.artic      = buf_ot-line-sale.artic
                 and goods.prod-type  = buf_ot-line-sale.prod-type
                 and goods.prod-code  = buf_ot-line-sale.prod-code
          no-error.
          if available goods
          then do:
                find first buf_rcs-retail1product no-lock
                     where buf_rcs-retail1product.gds-code = goods.gds-code
                no-error.
                if not available buf_rcs-retail1product
                then do:
                    run wp-XMLWriteEDT( hEDT, 4, "Не удалось найти PRODUCT для товара с кодом " + string( goods.gds-code ) ).
                    run wp-xmltagput( 2, 2, "gdsCode",    string( goods.gds-code ),   0).
                end.
                else do:
                    run wp-xmltagput( 2, 2, "TOV",        string( buf_rcs-retail1product.id ),         0).
                    run wp-xmltagput( 2, 2, "gdsCode",    string( buf_rcs-retail1product.gds-code ),   0).
                end.
          end.
          else do:
                run wp-xmltagput( 2, 2, "TOV",       "",         0).
          end.
 assign
       v-qnty = buf_ot-line-sale.fact-qnty
 .
          .
                run wp-xmltagput( 2, 2, "CEN01", string( buf_ot-line-sale.sum-rubl ), 2).
          .
          run wp-xmltagclose( 2, 1, "ROW").
      end.
      run wp-xmltagclose( 1, 1, "ROW").
end.
    end.
    else do:
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
for each  buf_ot-tot-sale no-lock
    where buf_ot-tot-sale.obj-type     = p-obj-type
      and buf_ot-tot-sale.obj-code     = p-obj-code
      and buf_ot-tot-sale.ext-doc-type = p-ext-doc-type
      and buf_ot-tot-sale.fact-order   > p-fact-order-from
      and buf_ot-tot-sale.fact-order  <= p-fact-order-to
      and (     buf_ot-tot-sale.sum-type = 'sale':U
            or  buf_ot-tot-sale.sum-type = 'sasr':U
          )
:
  if not l-exist-operation
  then do:
      run wp-XMLWriteEDT( hEDT, 4, "Операция " + string(p-oper-name) ).
      run wp-XMLWriteLog(sLogFile, 0, "&Line").
      run wp-XMLWriteLog(sLogFile, 1, "XML - Вывод операции " + string(p-oper-name) + " (" + p-ext-doc-type + ")").
      assign
            l-exist-operation = yes
      .
  end.
        find first trn-doc no-lock
             where trn-doc.doc-code = buf_ot-tot-sale.doc-code
        no-error.
        if not available trn-doc
        then do:
            message
                "В архивах найден несуществующий документ N "
                + string(buf_ot-tot-sale.doc-code)
                view-as alert-box.
            run wp-XMLWriteLog(  sLogFile,
                                        1,
                                "*** ERR: *** Не удалось найти документ N "
                                + string(buf_ot-tot-sale.doc-code)
            ).
            undo, leave.
        end.
        else do:
            assign
                v-doc-date  = trn-doc.doc-date
                v-fact-date = trn-doc.fact-date
                v-doc-PS    = trn-doc.ps
            .
        end.
        find first buf_rcs-retail1bill no-lock
             where buf_rcs-retail1bill.doc-code = buf_ot-tot-sale.doc-code
        no-error.
        if available buf_rcs-retail1bill
        then do:
            assign
                v-rcs-doc-id = buf_rcs-retail1bill.id
            .
        end.
        else do:
            assign
                v-rcs-doc-id = ""
            .
        end.
      run wp-XMLWriteCnt(
            hcnt,
            "   " + string(buf_ot-tot-sale.doc-code) + " от " + string(v-fact-date))
      .
      process events.
        find first buf_rcs-shops no-lock
             where buf_rcs-shops.obj-type = buf_ot-tot-sale.obj-type
               and buf_rcs-shops.obj-code = buf_ot-tot-sale.obj-code
        no-error.
        if not available buf_rcs-shops
        then do:
            undo, return error "rcs-oper: Не найден ID объекта."
                    + chr(10) + "Тип объекта: " + buf_ot-tot-sale.obj-type
                    + chr(10) + "Код объекта: " + string( buf_ot-tot-sale.obj-code )
            .
        end.
        run wp-xmltagopen( 1, 1, "ROW","").
        run wp-xmltagput( 1, 2, "ID",             buf_ot-tot-sale.doc-code, 0).
        run wp-xmltagput( 1, 2, "RCS_ID",         v-rcs-doc-id,             0).
        run wp-xmltagput( 1, 2, "DDAT",           string( year( v-doc-date ) ) + string( month( v-doc-date ), "99" ) + string( day( v-doc-date ), "99" ) + string( "000000" ), 0).
        run wp-xmltagput( 1, 2, "FDAT",           string( year( v-fact-date ) ) + string( month( v-fact-date ), "99" ) + string( day( v-fact-date ), "99" ) + string( "000000" ), 0).
        run wp-xmltagput( 1, 2, "DNOM",           buf_ot-tot-sale.doc-code, 0).
        run wp-xmltagput( 1, 2, "DTYPE",          string( p-rcs-doc-type ), 0).
        run wp-xmltagput( 1, 2, "STAD",           "1", 0).
        run wp-xmltagput( 1, 2, "DMODE",          ( if p-ext-doc-type = 'ie':U or p-ext-doc-type = 'ot':U then "-1" else "0" ), 0).
        run wp-xmltagput( 1, 2, "SITE",           string( buf_rcs-shops.id ), 0).
        find first buf_rcs-retail1subject no-lock
             where buf_rcs-retail1subject.obj-type = trn-doc.cli-type
               and buf_rcs-retail1subject.obj-code = trn-doc.cli-code
        no-error.
        if not available buf_rcs-retail1subject
        then do:
            run wp-XMLWriteEDT( hEDT, 4, "Не удалось найти SUBJECT для документа " + string( trn-doc.doc-code ) ).
        end.
        else do:
            run wp-xmltagput( 1, 2, "CORR", string( buf_rcs-retail1subject.id ), 0).
        end.
        run wp-xmltagput( 1, 2, "cliType", string( trn-doc.cli-type  ), 0).
        run wp-xmltagput( 1, 2, "cliCode", string( trn-doc.cli-code  ), 0).
        run wp-xmltagput( 1, 2, "MESS",  v-doc-PS, 0).
          find first buf_ot-tot-cost no-lock
               where buf_ot-tot-cost.doc-code = buf_ot-tot-sale.doc-code
                 and (  buf_ot-tot-cost.sum-type     = 'cost':U
                     or buf_ot-tot-cost.sum-type     = 'cssr':U
                     )
                 and buf_ot-tot-cost.cat-id = '##,##':U
          no-error.
          if not available buf_ot-tot-cost
          then do:
          end.
          find first buf_ot-tot-crsa no-lock
               where buf_ot-tot-crsa.doc-code = buf_ot-tot-sale.doc-code
                 and (  buf_ot-tot-crsa.sum-type     = 'crsa':U
                     or buf_ot-tot-crsa.sum-type     = 'cgsr':U
                     )
          no-error.
          if not available buf_ot-tot-crsa
          then do:
          end.
      .
      for each buf_ot-line-sale no-lock
          where buf_ot-line-sale.doc-code = buf_ot-tot-sale.doc-code
            and buf_ot-line-sale.sum-type = buf_ot-tot-sale.sum-type
      :
          run wp-xmltagopen( 2, 1, "ROW","").
          run wp-xmltagput( 2, 2, "DOC_HEAD_ID",  buf_ot-tot-sale.doc-code, 0).
          find first goods no-lock
               where goods.artic      = buf_ot-line-sale.artic
                 and goods.prod-type  = buf_ot-line-sale.prod-type
                 and goods.prod-code  = buf_ot-line-sale.prod-code
          no-error.
          if available goods
          then do:
                find first buf_rcs-retail1product no-lock
                     where buf_rcs-retail1product.gds-code = goods.gds-code
                no-error.
                if not available buf_rcs-retail1product
                then do:
                    run wp-XMLWriteEDT( hEDT, 4, "Не удалось найти PRODUCT для товара с кодом " + string( goods.gds-code ) ).
                    run wp-xmltagput( 2, 2, "gdsCode",    string( goods.gds-code ),   0).
                end.
                else do:
                    run wp-xmltagput( 2, 2, "TOV",        string( buf_rcs-retail1product.id ),         0).
                    run wp-xmltagput( 2, 2, "gdsCode",    string( buf_rcs-retail1product.gds-code ),   0).
                end.
          end.
          else do:
                run wp-xmltagput( 2, 2, "TOV",       "",         0).
          end.
          find first buf_doc-line no-lock
               where buf_doc-line.doc-code   = buf_ot-line-sale.doc-code
                 and buf_doc-line.artic      = buf_ot-line-sale.artic
                 and buf_doc-line.prod-type  = buf_ot-line-sale.prod-type
                 and buf_doc-line.prod-code  = buf_ot-line-sale.prod-code
          no-error.
          if not available buf_doc-line
          then do:
          end.
 assign
       v-qnty = buf_ot-line-sale.fact-qnty
 .
            if p-ext-doc-type <> 'vt':U      and
               p-ext-doc-type <> 'vp':U
            then do:
                run wp-xmltagput( 2, 2, "KOL02",   string(v-qnty), 0).
            end.
          .
              find first buf_ot-line-cost no-lock
                  where buf_ot-line-cost.doc-code = buf_ot-tot-sale.doc-code
                    and  buf_ot-line-cost.artic      = buf_ot-line-sale.artic
                    and  buf_ot-line-cost.prod-type  = buf_ot-line-sale.prod-type
                    and  buf_ot-line-cost.prod-code  = buf_ot-line-sale.prod-code
                    and (buf_ot-line-cost.sum-type   = 'cost':U
                      or buf_ot-line-cost.sum-type   = 'cssr':U
                        )
              .
              if available buf_ot-line-cost
              then do:
                    if buf_ot-line-cost.fact-qnty <> 0
                    then do:
                        run wp-xmltagput( 2, 2, "CEN01", string(abs(buf_ot-line-cost.sum-rubl / buf_ot-line-cost.fact-qnty ) ), 2).
                    end.
              end.
              else do:
              end.
              find first buf_ot-line-crsa no-lock
                  where buf_ot-line-crsa.doc-code = buf_ot-tot-sale.doc-code
                    and  buf_ot-line-crsa.artic      = buf_ot-line-sale.artic
                    and  buf_ot-line-crsa.prod-type  = buf_ot-line-sale.prod-type
                    and  buf_ot-line-crsa.prod-code  = buf_ot-line-sale.prod-code
                    and (buf_ot-line-crsa.sum-type   = 'crsa':U
                      or buf_ot-line-crsa.sum-type   = 'cgsr':U
                        )
              .
              if available buf_ot-line-crsa
              then do:
                    if buf_ot-line-crsa.fact-qnty <> 0
                    then do:
                        run wp-xmltagput( 2, 2, "CEN02", string(abs(buf_ot-line-crsa.sum-rubl / buf_ot-line-crsa.fact-qnty )), 2).
                    end.
              end.
              else do:
              end.
          .
          run wp-xmltagclose( 2, 1, "ROW").
      end.
      run wp-xmltagclose( 1, 1, "ROW").
end.
    end.
    output stream stmxmlhead close.
    output stream stmxmlbody close.
end.
