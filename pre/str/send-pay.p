block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter i-obj-code like ub.shop.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
DEFINE INPUT PARAMETER selective as integer no-undo.
DEFINE INPUT PARAMETER rid-list as char no-undo.
define input parameter p-log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: 7b0cc5f31b3c, 1617, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:38 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-pay.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-pay.p $":U .
define variable vss-description as character no-undo init "Пересылка видов оплат на кассы".
define variable rdlist as int64 no-undo .
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
define variable v-bgelib-bgefmt        as character         no-undo.
define variable v-bgelib-bgeflold      as character         no-undo.
define stream stmXMLOut.
define stream stmXMLLog.
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
define variable v-bgelib-bgeclall           as logical      no-undo.
define variable v-bgelib-bgedict            as logical      no-undo.
define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character
    index pi is primary unique
        edt-key
.
define temp-table temp_bgelib_goods no-undo
    field gds-code as integer
    index pi is primary unique
        gds-code
.
define temp-table temp_bgelib_clients no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bgelib_dis-card no-undo
    field d-card as character
    index pi is primary unique
        d-card
.
define temp-table temp_bgelib_trn-doc no-undo
    field doc-code as integer
.
procedure bgelib-tag-open:
do
on error undo, return error
:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill(" ", 4 * v-tag-level)
        + "<" + v-tag-name
        + ( if v-tag-value = "" or v-tag-value = ? then "" else " " )
        + v-tag-value + ">"
    .
end.
end procedure.
procedure bgelib-tag-put:
do
on error undo, return error
:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
    v-tag-name = trim(v-tag-name).
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "" and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "" and v-tag-value <> ? and v-tag-value <> "0"))
    or (v-empty-mode = 3 and (v-tag-value <> "" and v-tag-value <> ? and caps(v-tag-value) <> "no"))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            chr(10) + fill(" ", 4 * v-tag-level)
                        + '<' + v-tag-name + '>'
                        + v-tag-value
                        + '</' + v-tag-name + '>'
        .
    end.
end.
end procedure.
procedure bgelib-tag-close:
do
on error undo, return error
:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill( " ", 4 * v-tag-level)
        + '</' + v-tag-name + '>'
    .
end.
end procedure.
procedure bgelib-write-log:
do
on error undo, return error
:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        chr(10)
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine"
          or v-out-string = "&Line"
          then ""
          else cur-time-string-sec() + " " )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line"
          then fill( "-", 80 )
          else if v-out-string = "&DLine"
               then fill( "=", 80 )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.
procedure bgelib-write-edt:
do
on error undo, return error
:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine"
                                          or v-out-string = "&Line"
                                          then ""
                                          else cur-time-string-sec() + " "
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line"
                                          then fill( "-", 80 )
                                          else if v-out-string = "&DLine" then fill("=", 80)
                                          else fill( " ", v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( chr(10) ).
    end.
    process events.
    output to 'bgescn.txt' append.
        put unformatted
            chr(10)
            string( ( if v-log-level = 0
                      or v-out-string = "&DLine"
                      or v-out-string = "&Line"
                      then ""
                      else string( today ) + " " + string( time, "hh:mm:ss" ) + " "
                  ) )
            string( ( if v-out-string = "&Line"
                      then fill( "-", 80 )
                      else if v-out-string = "&DLine"
                           then fill( "=", 80 )
                           else fill( " ", v-log-level ) + v-out-string
                  ) )
        .
    output close.
end.
end procedure.
procedure bgelib-show-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.
procedure bgelib-hide-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.
procedure bgelib-write-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.
procedure bgelib-write-header:
do
on error undo, return error
:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-obj-list       as character    no-undo.
define input parameter p-doc-type-list  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.
    define variable v-counter    as integer        no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run bgelib-tag-open( input 0, input "root"  , input "" ).
    run bgelib-tag-open( input 0, input "header", input "" ).
    run bgelib-tag-put( input 1, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 1, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 1, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 1, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 1, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 1, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run bgelib-tag-close( input 0, input "header" ).
    output stream stmXMLOut close.
    output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
    if p-first-file = yes
    then do:
        put stream stmXMLOut unformatted
            "<?xml version='1.0' encoding='windows-1251'?>"
        .
        run bgelib-tag-open( input 0, input "export", input "" ).
    end.
    run bgelib-tag-open( input 1, input "file", input "" ).
    run bgelib-tag-put( input 2, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 2, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 2, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 2, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 2, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 2, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 2
            , input trim(entry( 2 * v-counter, p-parameter-list ))
            , input trim(entry( 2 * v-counter + 1, p-parameter-list ))
            , input 0
        ).
    end.
    run bgelib-tag-close( input 1, input "file" ).
    output stream stmXMLOut close.
end.
end procedure.
procedure bgelib-write-footer:
do
on error undo, return error
:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run bgelib-tag-open( input 0, input "footer", "" ).
        run bgelib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run bgelib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run bgelib-tag-close( input 0, input "footer" ).
    end.
    run bgelib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + "tmp"
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
            run bgelib-tag-close( input 0, input "export" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + "tmp"
            , input p-list-file-name + "xml"
            , output v-error-num
        ).
    end.
end.
end procedure.
procedure bgelib-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.
    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.
    get-key-value section "BGE" key "outdir" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run bge/genfname.p (
          input v-home-dir
        , input p-prefix
        , input ""
        , input "xml"
        , input "tmp"
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + chr(92) + "actions.log"
        p-list-file-name    = v-home-dir + chr(92) + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure.
procedure bgelib-read-config :
do
on error undo, return error
:
define variable v-par-type as character     no-undo.
  define variable v-param-type      as character  no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .
    assign
        v-bgelib-bgeclall = no
        v-bgelib-bgedict  = no
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
        v-bgelib-bgeclall = no
      .
    end.
    else do:
      assign
        v-bgelib-bgeclall = v-value-logical
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
        v-bgelib-bgedict = no
      .
    end.
    else do:
      assign
        v-bgelib-bgedict = v-value-logical
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
        v-bgelib-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bgelib-bgefmt  = v-value-character
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
        v-bgelib-bgeflold  = "old":U
      .
    end.
    else do:
      assign
        v-bgelib-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
end.
end procedure.
procedure bgelib-check-file-size :
do
on error undo, return error
:
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.
    define variable v-current-position    as integer        no-undo.
    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= 100
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure.
procedure bgelib-init-ext-doc-type :
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-xml-file-name     as character            no-undo.
define variable v-xml-file-name-path as character            no-undo.
define variable v-log-file-name     as character            no-undo.
define variable v-locked            as logical              no-undo.
define variable v-log-string        as character            no-undo.
define variable v-oper-num          as integer              no-undo.
define variable v-obj-list          as character            no-undo.
DEF VAR strDummy    AS CHAR view-as editor size 50 by 4 NO-UNDO.
DEF VAR intRep      AS INT NO-UNDO.
define variable hEDT             AS HANDLE NO-UNDO.
define variable hCNT             AS HANDLE NO-UNDO.
procedure xml-cd-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name       as character    no-undo.
define input parameter p-xml-file-name-path  as character    no-undo.
define input parameter p-doc-name            as character    no-undo.
define input parameter p-version             as character    no-undo.
define input parameter p-obj-list            as character    no-undo.
define input parameter p-correspondent       as character    no-undo .
define input parameter p-write-header        as logical      no-undo .
define variable OS-time as character no-undo .
define variable id as character no-undo .
define buffer buf_db for ub.db.
output stream stmXMLOut to value( p-xml-file-name-path + "xm1":U ) convert target "1251" append.
put stream stmXMLOut unformatted "<?xml version='1.0' encoding='windows-1251'?>".
assign
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
.
run bgelib-tag-open in this-procedure (
                                     1
                                    ,p-doc-name
                                    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", p-xml-file-name, p-obj-list, p-correspondent, OS-time )
                                      ).
if p-write-header then do:
  run bgelib-tag-open(2, "Header","").
  run bgelib-tag-put( 3, "DocumentName", p-doc-name, 1).
  run bgelib-tag-put( 3, "DateFormat", "DD.MM.YYYY":U, 1).
  run bgelib-tag-put( 3, "DocumentVersion", "1.02":U, 1).
  run bgelib-tag-put( 3, "DocumentVersionDate", "09.09.2004":U, 1).
  run bgelib-tag-put( 3, "ExportDate", string(today, "99.99.9999":U), 1).
  run bgelib-tag-put( 3, "ExportTime", string(time, "hh:mm:ss":U), 1).
  run bgelib-tag-put( 3, "objList",             p-obj-list                    , 1).
  find first buf_db where buf_db.db-num = g#db-num no-lock.
  run bgelib-tag-put( 3, "dbEncKey",            buf_db.db-key-enc, 1).
  run bgelib-tag-close( 2, "Header" ).
end.
output stream stmXMLOut close.
end.
end procedure.
procedure xml-cd-write-footer:
do
on error undo, return error
:
define input parameter p-pos-type      like ub.cash-desk.pos-type no-undo .
define input parameter p-xml-file-name as character    no-undo.
define input parameter p-doc-name      as character    no-undo .
define variable v-error-num     as integer           no-undo.
define variable v-md5-signature as character no-undo .
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run bgelib-tag-close( 0, p-doc-name ).
put stream stmXMLOut unformatted skip.
output stream stmXMLOut close.
run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
if v-error-num > 0
then do:
   return error.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-xml-file-name-path   as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure.
FUNCTION Xml-CD-DatetoString returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
FUNCTION Xml-CD-DateTimetoString returns character (input  p-date as date, p-time as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U) + chr(32) +
             string(p-time, "HH:MM:SS").
return v-date-str.
END FUNCTION.
function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                ,integer(substring(p-string, 7, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION string-IS0-8601-to-sec returns integer (input p-string-iso-8601 as character ):
define variable v-time as integer no-undo init ?.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
assign
v-dop1 = entry(1, p-string-iso-8601, chr(32) )
v-dop2 = entry(2, p-string-iso-8601, chr(32) )
no-error .
if error-status:error then return ?.
assign
v-time =  integer(entry(1, v-dop2, ";":U)) * 3600 +
          integer(entry(2, v-dop2, ";":U)) * 60 +
          integer(entry(3, v-dop2, ";":U)) no-error .
return v-time.
END FUNCTION.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fname                        as character      no-undo .
define variable out                          as character      no-undo .
define variable out2                          as character      no-undo .
DEFINE VARIABLE in_                          as character      no-undo .
DEFINE VARIABLE spl                          as character      no-undo .
DEFINE VARIABLE sav                          as character      no-undo .
DEFINE VARIABLE v-remote                     as character      no-undo .
DEFINE VARIABLE start-paket                  as logical init yes no-undo .
define variable cr as integer no-undo.
define variable Cash-OS2                    as logical        no-undo .
define variable Cash-DOS                     as logical        no-undo .
define variable BadFlag                      as logical        no-undo .
define variable os-er                        as integer        no-undo .
DEFINE VARIABLE OS2-time                     as character      no-undo .
define variable glog as logical no-undo .
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-md5-signature              as character      no-undo .
define variable v-cd-list-update             as character no-undo .
define variable v-cd-list-delete             as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define stream   IBMStream .
define temp-table temp-cd no-undo like ub.cash-desk .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alienini-getkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.
define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.
assign
set-size(mem1)  = 4000
mem1size = 4000.
if i-key = "" then EntryPointer = 0.
else do:
  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.
run getprivateprofilestringA
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).
do ii = 1 to cbReturnSize:
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.
  set-size(mem1) = 0.
  set-size(mem2) = 0.
end procedure.
procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.
define variable cbReturnSize as integer.
run writeprivateprofilestringA
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).
end procedure.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.
define   temp-table temp-tekka-tsk no-undo
field filename      as character
field obj-num       as integer
field obj-name      as character
field num-records   as integer
field max-records   as integer
field min-plu       as integer
field max-plu       as integer
field num-fields    as integer
field task-num      as character
field by-record     as logical
field send-get      as character
field cash-num      as integer
field cash-num-char as character
field port-num      as character
field way           as character
field is-script     as logical
field pswd          as character
field waiting-sek   as integer
field other-info    as character
field order-num     as integer
field secondary     as integer
field shift-fields  as integer
field binary        as logical
field range         as integer
index pi is unique primary
filename
range
index lpi
filename
min-plu
index gpi
filename
max-plu
index iorder
order-num
.
define   temp-table temp-tekka-schema no-undo
field obj-num as integer
field obj-name as character
field field-num as integer
field field-name as character
field num-records as integer
field size_ as integer
field host as character
field progress-type as character
field custom-type as character
field start-pos as integer
field end-pos as integer
field bin-group as character
index pi is unique primary
host obj-num field-num
.
define temp-table temp-tekka-record no-undo
field obj-num as integer
field plu as integer
field body as character
field shift as integer
index pi is unique primary obj-num plu.
FUNCTION tekka-is-closed-shift-journal returns integer ( input p-journal-num as integer ):
define variable v-is-closed-shift-journal as integer no-undo .
assign
v-is-closed-shift-journal = (if lookup( string( p-journal-num), '30,31,32,33':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '43':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '17':U) > 0 then 1 else 0)
.
return v-is-closed-shift-journal.
END FUNCTION.
FUNCTION tekka-is-first-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-first-journal as logical no-undo .
assign
v-is-first-journal = (p-journal-num =  integer(entry(1, '30,31,32,33':U)))
                  or (p-journal-num = integer(entry(1, '26,27,28,29':U)))
                  or (p-journal-num =  integer(entry(1, '17':U)))
                  or (p-journal-num = integer(entry(1, '16':U)))
.
return v-is-first-journal.
END FUNCTION.
FUNCTION tekka-is-petrol-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-petrol-journal as logical no-undo .
assign
v-is-petrol-journal = lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0.
return v-is-petrol-journal.
END FUNCTION.
FUNCTION tekka-get-max-journal-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489
                    else 2340).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-get-max-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489 * num-entries('30,31,32,33':U)
                    else 2340 * num-entries('17':U)).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-num-recs returns integer( input p-journal-num as integer
                                        ,input p-rec-no as integer):
define variable v-num-recs as integer no-undo .
if tekka-is-petrol-journal (p-journal-num) then do:
  if tekka-is-closed-shift-journal(p-journal-num) = 1 then do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '30,31,32,33':U))) * 1489 + p-rec-no
    .
  end.
  else do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '26,27,28,29':U)) ) * 1489 + p-rec-no
    .
  end.
end.
else do:
  if lookup(string(p-journal-num), '16,17':U) > 0 then do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '17':U))) * 2340 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '16':U)) ) * 2340 + p-rec-no
      .
    end.
  end.
  else do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '43':U))) * 2978 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '42':U)) ) * 2978 + p-rec-no
      .
    end.
  end.
end.
return v-num-recs.
END FUNCTION.
FUNCTION tekka-get-obj-num returns integer( input p-num-recs as decimal
                                           ,input p-is-petrol as logical
                                           ,input p-is-current as logical
                                           ,output p-rec-no as decimal
                                           ):
define variable v-obj-num0 as integer no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-num2 as integer no-undo .
define variable p-num-recs2 as integer no-undo .
define variable p-rec-no2 as integer no-undo .
if p-is-petrol then do:
  assign
  v-obj-num0 = trunc(p-num-recs / 1489, 0)
  .
  if p-is-current and num-entries('26,27,28,29':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '26,27,28,29':U))
  p-rec-no = p-num-recs modulo 1489
  .
  if not p-is-current and num-entries('30,31,32,33':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '30,31,32,33':U))
  p-rec-no = p-num-recs modulo 1489
  .
end.
else do:
  assign
  p-num-recs2 = (p-num-recs - trunc(p-num-recs, 0)) * 10000
  p-num-recs = trunc(p-num-recs, 0)
  v-obj-num0 = trunc(p-num-recs / 2340, 0)
  v-obj-num2 = trunc(p-num-recs2 / 2978, 0)
  .
  if p-is-current and num-entries('16':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '16':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if not p-is-current and num-entries('17':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '17':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if p-is-current and num-entries('42':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '42':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  if not p-is-current and num-entries('43':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '43':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  assign
  p-rec-no = p-rec-no + p-rec-no2 / 10000
  .
end.
if v-obj-num = 0 then v-obj-num = 100.
return v-obj-num.
END FUNCTION.
FUNCTION tekka-get-next-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '17':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
   if p-is-ptrl then
   return integer(entry(1, '26,27,28,29':U)).
   if not p-is-ptrl then
   return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
FUNCTION tekka-get-next-current-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical ):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '26,27,28,29':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
  if p-is-ptrl then
  return integer(entry(1, '26,27,28,29':U)).
  if not p-is-ptrl then
  return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
PROCEDURE maria-put:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-shift-fields as integer no-undo .
define input parameter p-binary as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-plu as integer no-undo .
define input parameter p-value as character no-undo .
define variable v-file-name as character no-undo .
define variable v-create as logical no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
v-file-name =  p-out + p-fname + '.' + string(p-obj-num,  '999') .
output stream IBMSTREAM
to value(v-file-name) append .
Put  stream IBMSTREAM unformatted
p-plu
chr(3)
p-value
skip.
output stream IBMSTREAM
close.
if not p-by-record then do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name no-error .
  if not available buf_temp-tekka-tsk then do:
    v-create = yes.
  end.
end.
else do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name
        and buf_temp-tekka-tsk.max-plu = (p-plu - 1) use-index gpi no-error .
  if not available buf_temp-tekka-tsk
  then do:
    find first buf_temp-tekka-tsk where
              buf_temp-tekka-tsk.filename  = v-file-name
          and buf_temp-tekka-tsk.min-plu = (p-plu + 1) use-index lpi no-error .
    if not available buf_temp-tekka-tsk
    then do:
      v-create = yes.
    end.
  end.
end.
if v-create then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.range    = p-plu
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.num-records = 0
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = num-entries(p-value, chr(4) )
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.shift-fields = p-shift-fields
  buf_temp-tekka-tsk.binary = p-binary
  buf_temp-tekka-tsk.send-get = 'send'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                        then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                        else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                              then 'local'
                              else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-plu
  buf_temp-tekka-tsk.max-plu     = p-plu
  .
end.
assign
buf_temp-tekka-tsk.num-records = buf_temp-tekka-tsk.num-records + 1
buf_temp-tekka-tsk.min-plu     = minimum(buf_temp-tekka-tsk.min-plu, p-plu)
buf_temp-tekka-tsk.max-plu     = maximum(buf_temp-tekka-tsk.max-plu, p-plu)
.
END PROCEDURE.
PROCEDURE maria-get:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-num-fields as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-min-plu as integer no-undo .
define input parameter p-max-plu as integer no-undo .
define input parameter p-other as character no-undo .
define input parameter p-order-num as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-secondary-obj-num as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
if p-by-record then do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '.' + string(p-obj-num,  '999') .
end.
else do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '_html.' + string(p-obj-num,  '999').
end.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.filename  = v-file-name no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = p-num-fields
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.send-get = 'get'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-min-plu
  buf_temp-tekka-tsk.max-plu     = p-max-plu
  buf_temp-tekka-tsk.num-records = (if p-min-plu <> ?
                                    and p-max-plu <> ?
                                    then p-max-plu - p-min-plu + 1
                                    else 0)
  buf_temp-tekka-tsk.other-info = p-other
  buf_temp-tekka-tsk.order-num = p-order-num
  .
  if index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-') > 0 then do:
    assign
    v-secondary-obj-num =  substring('16-42,17-43,':U, index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-'))
    v-secondary-obj-num = entry(2, v-secondary-obj-num, '-':U)
    v-secondary-obj-num = entry(1, v-secondary-obj-num)
    no-error
    .
    buf_temp-tekka-tsk.secondary = integer(v-secondary-obj-num).
  end.
end.
END PROCEDURE.
PROCEDURE maria-task:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-fname as character no-undo .
define input parameter p-obj-num-list as character no-undo .
define input parameter p-parameters as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.task-num  = p-fname no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = ''
  buf_temp-tekka-tsk.range = 1
  buf_temp-tekka-tsk.obj-num = 0
  buf_temp-tekka-tsk.obj-name = p-obj-num-list
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = no
  buf_temp-tekka-tsk.send-get = 'task'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.other-info = p-parameters
  buf_temp-tekka-tsk.order-num = 0
  .
end.
END PROCEDURE.
procedure tekkatsk-verify-schema :
define input parameter p-obj-list as character no-undo .
define input parameter p-dir-path as character no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-size_ as integer no-undo .
define variable v-value as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable ii-ibs as integer no-undo .
define variable ii-tekka as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer buf2_temp-tekka-schema for temp-tekka-schema.
  do
  on error undo, return error
  :
     for each buf_temp-tekka-schema:
       delete buf_temp-tekka-schema.
     end.
     input from value('tekkasch.d').
     repeat :
       create buf_temp-tekka-schema.
       import buf_temp-tekka-schema.
       assign
       buf_temp-tekka-schema.host = 'IBS'
       ii = ii + 1.
       .
     end.
     input close.
     ii-ibs = ii.
      _ii:
      do ii = 1 to 256:
        if p-obj-list = "ALL"
        or lookup(string(ii), p-obj-list) > 0 then do:
          assign
          v-obj-num = 0
          v-obj-name = ''
          v-num-records = 0
          v-size_ = 0
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'oname'
                                                  ,output v-value) no-error .
          if v-value = ? then next _ii.
          assign
          v-obj-num = ii
          v-obj-name = v-value
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'size'
                                                  ,output v-value) no-error .
          assign
          v-num-records = integer(v-value) no-error  .
          if error-status:error
          or v-num-records = 0 then next _ii.
          run alienini-getkey in this-procedure (
                                                   input  (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input 'obj' + string(ii, '999')
                                                  ,input 'f000'
                                                  ,output v-value) no-error .
          assign
          v-size_ = integer(v-value) no-error  .
          if error-status:error
          or v-size_ = 0 then next _ii.
          _jj:
          do jj = 1 to 256:
            run alienini-getkey in this-procedure (
                                                     input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999')
                                                    ,input 'f' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value = ? then next _ii.
            create buf_temp-tekka-schema.
            assign
            buf_temp-tekka-schema.host = 'tekka'
            buf_temp-tekka-schema.obj-num = v-obj-num
            buf_temp-tekka-schema.obj-name = v-obj-name
            buf_temp-tekka-schema.num-records = v-num-records
            buf_temp-tekka-schema.size_ = v-size_
            buf_temp-tekka-schema.field-num = jj
            buf_temp-tekka-schema.custom-type = entry(1, entry(2, v-value, '#'), ':')
            buf_temp-tekka-schema.bin-group = (if num-entries(entry(2, v-value, '#'), ':') > 1
                                               then entry(2, entry(2, v-value, '#'), ':')
                                               else '':U)
            buf_temp-tekka-schema.start-pos = integer(entry(1, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.end-pos = integer(entry(2, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.progress-type = entry( LOOKUP(buf_temp-tekka-schema.custom-type, 'Sx,B,BF,BN,UI,UL,FL,SL,VL':U)
                                                        , 'C,I,I,I,D,D,D,D,D':U)
            no-error
            .
            if error-status:error then do:
              delete buf_temp-tekka-schema.
              next _jj.
            end.
            run alienini-getkey in this-procedure (
                                                    input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999') + 'name'
                                                    ,input 'n' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value <> ? then
            buf_temp-tekka-schema.field-name = v-value.
          end.
        end.
      end.
      ii-tekka = ii - 1.
     if p-obj-list <> 'ALL' then do:
      if ii-tekka <> ii-ibs then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS &1 объектов&1по даным OLE-сервера &2"
                                , ii-ibs
                                , ii-tekka).
      end.
     end.
     for each buf_temp-tekka-schema where
            buf_temp-tekka-schema.host = 'tekka':
       find first buf2_temp-tekka-schema where
                 buf2_temp-tekka-schema.obj-num = buf_temp-tekka-schema.obj-num
             AND buf2_temp-tekka-schema.host = 'ibs'
             AND buf2_temp-tekka-schema.field-num = buf_temp-tekka-schema.field-num no-error .
       if not available buf2_temp-tekka-schema then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS нет поля &1 для объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
       buffer-compare buf_temp-tekka-schema
       to buf2_temp-tekka-schema
       save result in v-result.
       if v-result <> '':U then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS для поля &1 объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
     end.
  end.
end procedure.
FUNCTION set-Sx returns character (input p-string as character):
return p-string.
END FUNCTION.
FUNCTION get-Sx returns character (input p-string  as character):
return p-string.
END FUNCTION.
FUNCTION set-B returns character (input p-string  as character):
return chr(integer(p-string)).
END FUNCTION.
FUNCTION get-B returns character (input p-string  as character):
return string(asc(p-string)).
END FUNCTION.
FUNCTION set-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
do ii = 1 to 8:
  put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable ii as integer no-undo .
v-dopi = asc(p-string).
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
return v-dops.
END FUNCTION.
FUNCTION set-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-grp-nums as integer no-undo .
define variable v-dopi2 as integer no-undo .
v-grp-nums = num-entries(p-bin-group).
do jj = 0 to v-grp-nums - 1:
  v-dopi2 = integer(substring(p-string, jj + 1, 3)).
  do ii = 1 to 8:
    put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
  end.
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable v-grp-nums as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
v-dopi = asc(p-string).
v-grp-nums = num-entries(p-bin-group).
do jj = 1 to v-grp-nums:
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
end.
return v-dops.
END FUNCTION.
procedure fill-temp-cd :
define input parameter p-db-num   like ub.cash-desk.db-num no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-clear-table as logical no-undo .
define buffer buf_temp-cd for temp-cd.
define buffer buf_cash-desk for ub.cash-desk.
  do
  on error undo, return error
  :
     if p-clear-table  then do:
       for each buf_temp-cd:
         delete buf_temp-cd.
       end.
     end.
     for each buf_cash-desk no-lock where
            buf_cash-desk.db-num = p-db-num
        AND buf_cash-desk.obj-code = p-obj-code
        and buf_cash-desk.cash-on  = yes
     BREAK by buf_cash-desk.pos-type:
       if first-of(buf_cash-desk.pos-type) then do:
         create buf_temp-cd.
         buffer-copy buf_cash-desk to buf_temp-cd.
       end.
     end.
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION cp-isuse returns logical ( input p-cdpay-code as integer
                                   ,input p-curr-code as integer
                                   ,input p-host-code as integer
                                   ,input p-obj-type as character
                                   ,input p-obj-code as integer
                                   ,input p-cp-is-use as logical
                                   ,input p-cash-num as integer
                                   ,input p-pos-type as character
                                   ):
define variable v-value as character no-undo .
define variable v-type as character no-undo .
if p-cp-is-use then do:
  run cp-attr-value  in this-procedure (
                                           input p-cdpay-code
                                          ,input p-curr-code
                                          ,input p-host-code
                                          ,input p-obj-type
                                          ,input p-obj-code
                                          ,input 'is-use':U
                                          ,output v-value
                                          ,output v-type) no-error .
  if error-status:error
  or v-value = '':u then do:
    run cp-attr-value  in this-procedure (
                                             input p-cdpay-code
                                            ,input p-curr-code
                                            ,input p-host-code
                                            ,input '':U
                                            ,input  0
                                            ,input 'is-use':U
                                            ,output v-value
                                            ,output v-type) no-error .
    if error-status:error
    or v-value = '':u then do:
      run cp-attr-value  in this-procedure (
                                              input  p-cdpay-code
                                              ,input p-curr-code
                                              ,input  0
                                              ,input  '':U
                                              ,input  0
                                              ,input  'is-use':U
                                              ,output v-value
                                              ,output v-type) no-error .
    end.
  end.
  if v-value <> '*':U
  and lookup(string(p-cash-num) + chr(44) + p-pos-type, v-value, chr(4)) = 0 then do:
    return no.
  end.
end.
return yes.
END FUNCTION.
DEFINE VARIABLE kassa-rub-code as integer.
DEFINE VARIABLE ibmnalc as integer no-undo .
define variable multicurr as logical no-undo .
define variable conf-attr as character no-undo .
DEFINE VARIABLE conf-par as character no-undo.
DEFINE VARIABLE par-type as character no-undo.
DEFINE VARIABLE dopi as decimal no-undo.
DEFINE VARIABLE ii as integer no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-cp-is-use as logical no-undo .
define variable mariapayg as character no-undo .
define variable mariapayp as character no-undo .
define variable dr-list as character no-undo .
define variable drcprank as character no-undo .
define variable v-record as character no-undo .
define variable v-found-maria-discnt as logical no-undo .
define temp-table tt-cash-pay no-undo like cash-pay
index cdpay-code cdpay-code.
procedure putc-5 :
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter par-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter par-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-pos-version like ub.cash-desk.version no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-index as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-plu as character no-undo .
define variable v-dop as character no-undo .
define variable v-dop2 as character no-undo .
define variable v-cp-attr-code as character no-undo .
define variable attr-value as character no-undo .
define variable attr-type as character no-undo .
define variable v-maria-rule-num as integer no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-skip-fields as integer no-undo .
define variable v-version-dec as decimal no-undo .
define variable v-paymentetc as character no-undo .
define buffer BUF_DIS-RULE for UB.DIS-RULE.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
  do
  on error undo, return error
  :
    if selective = 0 then do:
      _non-selective:
      FOR EACH ub.cash-pay where
              (par-pos-type <> 'IBM':U or ub.cash-pay.cdpay-code < 99):
        if not cp-isuse ( input  ub.cash-pay.cdpay-code                                  ,input  ub.cash-pay.curr-code                                          ,input  v-host-code                                                    ,input 'маг':U                                                         ,input i-obj-code                                                      ,input v-cp-is-use                                                     ,input par-cash-num                                                    ,input par-pos-type )                                                  then next _non-selective.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE par-pos-type:
  when 'IBM':U
  then do:
    IF cash-pay.is-cash = YES and
        ((cash-pay.cdpay-code = 1 and NOT cash-pay.curr-code = ibmnalc )  ) then NEXT.
    if cash-pay.status_ <> 'тек':U and action = 'U' and selective = 0 then NEXT.
    if cash-pay.cdpay-code > 99 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Тип кассового платежа &1 (код &2 код валюты &3)&4не может быть отправлен на кассу типа &5" +
                              "Для данного типа касс код платежа должен быть < 100"
                             ,cash-pay.obj-name
                             ,cash-pay.cdpay-code
                             ,cash-pay.curr-code
                             ,chr(10)
                             ,par-pos-type
                            )                 ).
      assign
      v-view-log = yes
      .
      NEXT.
    end.
    dopi = 15 - MIN(length(TRIM(cash-pay.obj-name)), 15).
    if dopi modulo 2 = 0 then
    dopi = dopi / 2.
    else
    assign dopi = TRUNCATE(dopi / 2, 0).
    assign
    v-version-dec = decimal(p-pos-version)
    no-error .
    release buf_dis-rule.
    if v-version-dec >= 4.55 then do:
      if action <> 'D':U  then do:
        find first buf_dis-cp-rule no-lock where
              buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
          and buf_dis-cp-rule.curr-code = cash-pay.curr-code
          and buf_dis-cp-rule.host-code = v-host-code
          and buf_dis-cp-rule.obj-type = 'маг':U
          and buf_dis-cp-rule.obj-code = i-obj-code
          and buf_dis-cp-rule.discnt-role =  'simple-pay':U
          and buf_dis-cp-rule.pos-type =  'IBM':U no-error.
        if available buf_dis-cp-rule then do:
          find first buf_dis-rule no-lock where
                    buf_dis-rule.obj-type = 'маг':U
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                AND buf_dis-rule.sts = integer('0':U) no-error .
          if available buf_dis-rule then do:
          end.
        end.
        else do:
          find first buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
            and buf_dis-cp-rule.curr-code = cash-pay.curr-code
            and buf_dis-cp-rule.host-code = 0
            and buf_dis-cp-rule.obj-type = '':U
            and buf_dis-cp-rule.obj-code = 0
            and buf_dis-cp-rule.discnt-role =  'simple-pay':U
            and buf_dis-cp-rule.pos-type =  'IBM':U no-error.
          if available buf_dis-cp-rule then do:
            find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                  AND buf_dis-rule.sts = integer('0':U) no-error .
            if available buf_dis-rule then do:
            end.
          end.
        end.
      end.
    end.
    PUT stream IBMStream unformatted
    '5 "' string( Action, "x(1)" ) '" '
    string( cash-pay.cdpay-code, ">9" )
    ' "'
    string(
            fill(" ", int(dopi)) +
            TRIM(replace(replace(cash-pay.obj-name, chr(34), '':U), chr(39), '':U)) +
            fill(" ", int(dopi)), "x(13)"
          )
    '" '
    string( if multicurr
            then 0
            else (if cash-pay.curr-code = 0
                  then kassa-rub-code
                  else cash-pay.curr-code ), ">9" )
    " " string( cash-pay.pay-limit, "->>>>>9.99" )
    " "
    string( int( cash-pay.atr1 ) + int( cash-pay.atr2 ) * 2 + int( cash-pay.atr4 ) * 4 +
            int( cash-pay.atr8 ) * 8 + int( cash-pay.atr16 ) * 16 + int( cash-pay.atr32 ) * 32 +
            int( cash-pay.atr64 ) * 64 + int(cash-pay.atr128) * 128 +
            (if v-version-dec >= 4.4
            then ( int( cash-pay.is-service-pay ) * 256 +
                    int( cash-pay.is-goods-pay ) * 512)
             else 0)
            , "999" )
    space(1)
    ( if Cash-OS2 then
    string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
    else "" )
    .
    if v-version-dec >= 4.55
      then do:
        put stream IBMStream unformatted
        chr(32)
        chr(34) string(cash-pay.slip-file-name, "X(15)")    chr(34)
        chr(32)
        string(if available buf_Dis-rule
                then (if buf_dis-rule.value-type = integer('1':U)
                      then 2
                      else 1)
                else 0)
        chr(32)
        (if available buf_Dis-rule
        then
        (if buf_dis-rule.value-type = integer('1':U)
          then string(- buf_dis-rule.discnt-value, "->>9.99")
          else string(- buf_dis-rule.discnt-value, ">>>>>>>>9.99")
          )
        else string(0)
        )
        .
    end.
    PUT stream IBMStream unformatted
    skip .
  end.
  when 'IBM-XML':U then do:
   assign
    v-version-dec = decimal(p-pos-version)
    no-error .
    release buf_dis-rule.
    IF cash-pay.is-cash = YES and
        ((cash-pay.cdpay-code = 1 and NOT cash-pay.curr-code = ibmnalc )  ) then NEXT.
    run bgelib-tag-open in this-procedure ( input 2, input "Payment"
                                          , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
                                                                                              then if cash-pay.status_ eq 'тек':U  then "ADD":U else "DEL":U
                                                                                              else "DEL":U),
                                                              OS2-time, cash-pay.cdpay-code
                                                                        )).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentLock":U
                                          , input string(if cash-pay.status_ = 'тек':U then 0 else 1), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentName":U
                                          , input substr(cash-pay.obj-name, 1, (if v-version-dec >= 1.08 then 35 else 15)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentCur":U
                                          , input string(if multicurr
                                                         then 0
                                                         else (if cash-pay.curr-code = 0
                                                                then kassa-rub-code
                                                                else cash-pay.curr-code)
                                                         )
                                          , input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentSlip":U
                                          , input string(cash-pay.slip-file-name), input 1 ).
    if v-version-dec >= 1.07 then do:
      if action <> 'D':U  then do:
        find first buf_dis-cp-rule no-lock where
              buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
          and buf_dis-cp-rule.curr-code = cash-pay.curr-code
          and buf_dis-cp-rule.host-code = v-host-code
          and buf_dis-cp-rule.obj-type = 'маг':U
          and buf_dis-cp-rule.obj-code = i-obj-code
          and buf_dis-cp-rule.discnt-role =  'simple-pay':U
          and buf_dis-cp-rule.pos-type =  'IBM-XML':U no-error.
        if available buf_dis-cp-rule then do:
          find first buf_dis-rule no-lock where
                    buf_dis-rule.obj-type = 'маг':U
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                AND buf_dis-rule.sts = integer('0':U) no-error .
          if available buf_dis-rule then do:
          end.
        end.
        else do:
          find first buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
            and buf_dis-cp-rule.curr-code = cash-pay.curr-code
            and buf_dis-cp-rule.host-code = 0
            and buf_dis-cp-rule.obj-type = '':U
            and buf_dis-cp-rule.obj-code = 0
            and buf_dis-cp-rule.discnt-role =  'simple-pay':U
            and buf_dis-cp-rule.pos-type =  'IBM-XML':U no-error.
          if available buf_dis-cp-rule then do:
            find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                  AND buf_dis-rule.sts = integer('0':U) no-error .
            if available buf_dis-rule then do:
            end.
          end.
        end.
      end.
    end.
    if v-version-dec >= 1.12 then do:
      if action <> 'D':U  then do:
         find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
                                 and buf_cash-pay-attr.curr-code = cash-pay.curr-code
                                 and buf_cash-pay-attr.attr-code = "cash-prop" no-error .
      end.
    end.
    if AVAILABLE buf_cash-pay-attr then do:
        run bgelib-tag-put in this-procedure ( input 3, input "PaymentType":U
                                             ,input (buf_cash-pay-attr.attr-value)
                                            ,input 1
                                                     ).
    end.
    if available buf_dis-rule
    then do:
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentDType":U
                                             ,input (if buf_dis-rule.value-type = integer('1':U)
                                                     then 2
                                                     else 1)
                                            ,input 1
                                                     ).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentDisc":U
                                            , input (- buf_dis-rule.discnt-value)
                                          , input 1 ).
    end.
    else do:
      run bgelib-tag-put in this-procedure ( input 3
                                            ,input "PaymentDType":U
                                            ,input 0
                                            ,input 1
                                           ).
      run bgelib-tag-put in this-procedure ( input 3
                                            ,input "PaymentDisc":U
                                            ,input string(0)
                                            ,input 1 ).
    end.
    v-paymentetc = "" .
        find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = 'max_proc_sum':U no-error .
    if AVAILABLE buf_cash-pay-attr then
    do:
        v-paymentetc = "MaxLimit" + ":" + string(decimal(buf_cash-pay-attr.attr-value) * 100).
    end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = 'mask_card_kup':U no-error .
    if AVAILABLE buf_cash-pay-attr then
    do:
        v-paymentetc = v-paymentetc + "," + "Mask" + ":" + buf_cash-pay-attr.attr-value .
    end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-card-type" no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "FuelCard" + ":" + buf_cash-pay-attr.attr-value .
        end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-card-type-bank" no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "BankCard" + ":" + buf_cash-pay-attr.attr-value .
        end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "qr-mir"
        and buf_cash-pay-attr.attr-value = string(yes) no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "Ext" + ":" + "peace-qr" .
        end.
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentEtc":U
                                             ,input (trim(v-paymentetc,","))
                                            ,input 1
                                                     ).
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-type-pay-fr" no-error .
    if AVAILABLE buf_cash-pay-attr then do:
       run bgelib-tag-put in this-procedure ( input 3, input "PaymentFRType":U
                                             ,input buf_cash-pay-attr.attr-value
                                            ,input 1
                                                     ).
    end.
    run bgelib-tag-open in this-procedure ( input 3, input "PaymentStatus"
                                          , input "":U).
    run bgelib-tag-put in this-procedure ( input 4, input "PSCash":U
                                          , input string(if cash-pay.is-cash then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSReturn":U
                                          , input string(if cash-pay.atr1 or cash-pay.has-return > 0 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSTransfer":U
                                          , input string(if cash-pay.atr2 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSPrintSlip":U
                                          , input string(if cash-pay.atr4 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSPrintFact":U
                                          , input string(if cash-pay.atr8 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSAuthorize":U
                                          , input string(if cash-pay.atr16
                                                        then 1
                                                        else 0), input 0 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSFuelPay":U
                                          , input string(if cash-pay.atr64 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSServicePay":U
                                          , input string(if cash-pay.is-service-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSUnitPay":U
                                          , input string(if cash-pay.is-goods-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSAllPay":U
                                          , input string(if cash-pay.is-all-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSChipCard":U
                                          , input string(if cash-pay.atr128 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSRequestPin":U
                                          , input string(if cash-pay.atr32 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSBarRead":U
                                          , input string(if cash-pay.is-bar-read then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSCardSwap":U
                                          , input string(if cash-pay.is-card-swap then 1 else 0), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PaymentStatus").
    run bgelib-tag-close in this-procedure ( input 2, input "Payment").
  end.
  when 'MARIA':U then do:
    v-found-maria-discnt = no.
    assign
    v-index = index((mariapayp + ";")
                    ,(chr(47) + string(cash-pay.cdpay-code) + chr(44) + string(cash-pay.curr-code) + ';')
                     ).
    if v-index > 0
    then do:
      do v-ii = 1 to num-entries(mariapayp, ';'):
        assign
        v-dop = entry(v-ii, mariapayp, ';')
        v-dop2 = entry(2, v-dop, chr(47))
        v-dop =  entry(1, v-dop, chr(47))
        v-plu = entry(2, v-dop)
        v-dop = entry(1, v-dop)
        .
        if entry(1,  v-dop2) = string(cash-pay.cdpay-code)
        and entry(2, v-dop2) = string(cash-pay.curr-code) then do:
          if  v-dop <> string(1)
          and v-plu <> string(0)
          then do:
            run maria-put in this-procedure (
                                            buffer buf_cash-desk
                                          , input out
                                          , input fname
                                          , input yes
                                          , input 0
                                          , input no
                                          , input integer(entry(1, entry(1, v-dop, chr(47))))
                                          , input 20
                                          , input v-plu
                                          , input (if action = 'D' then '':U else string(cash-pay.obj-name, "X(18)"))).
          end.
          v-maria-discnt-value = string(0, '999').
          if action <> 'D':U  then do:
             find first buf_dis-cp-rule no-lock where
                    buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
                and buf_dis-cp-rule.curr-code = cash-pay.curr-code
                and buf_dis-cp-rule.host-code = v-host-code
                and buf_dis-cp-rule.obj-type = 'маг':U
                and buf_dis-cp-rule.obj-code = i-obj-code
                and buf_dis-cp-rule.discnt-role =  'simple-pay':U
                and buf_dis-cp-rule.pos-type =  'MARIA':U no-error.
            if available buf_dis-cp-rule then do:
              find first buf_dis-rule no-lock where
                        buf_dis-rule.obj-type = 'маг':U
                    AND buf_dis-rule.obj-code = i-obj-code
                    AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                    AND buf_dis-rule.sts = integer('0':U) no-error .
             if available buf_dis-rule then do:
                if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
                  assign
                  v-dop2 = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
                  v-dop2 = substring(v-dop2, 1, index(v-dop2, chr(44)) - 1)
                  v-maria-rule-num = integer(entry(2, v-dop2, '-':U)) - 1
                  v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
                  .
                end.
              end.
            end.
          end.
          v-found-maria-discnt = yes.
          if v-dop = string(1) then do:
            entry(1 , v-record, chr(4) ) = v-maria-discnt-value.
          end.
          if v-dop <> string(1)
          and v-plu <> string(0) then do:
            entry( ((integer(v-dop) - 2) * 20 + integer(v-plu) + 414 - 9), v-record, chr(4)) =  v-maria-discnt-value.
          end.
        end.
      end.
    end.
    else do:
      if selective > 0 then
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Тип кассового платежа &1 (код &2 код валюты &3)&4не может быть отправлен на кассу типа &5&4" +
                              "Для данного типа касс типу кассового платежа должен быть задан КОД ОПЛАТЫ ТОПЛИВА НА кассе"
                             ,cash-pay.obj-name
                             ,cash-pay.cdpay-code
                             ,cash-pay.curr-code
                             ,chr(10)
                             ,par-pos-type
                            )                 ).
    end.
  end.
END CASE.
      END.
    end.
    else do:
      if rid-list eq "*"
      then  do:
        create tt-cash-pay.
        tt-cash-pay.cdpay-code = ?.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE par-pos-type:
  when 'IBM':U
  then do:
    IF tt-cash-pay.is-cash = YES and
        ((tt-cash-pay.cdpay-code = 1 and NOT tt-cash-pay.curr-code = ibmnalc )  ) then NEXT.
    if tt-cash-pay.status_ <> 'тек':U and action = 'U' and selective = 0 then NEXT.
    if tt-cash-pay.cdpay-code > 99 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Тип кассового платежа &1 (код &2 код валюты &3)&4не может быть отправлен на кассу типа &5" +
                              "Для данного типа касс код платежа должен быть < 100"
                             ,tt-cash-pay.obj-name
                             ,tt-cash-pay.cdpay-code
                             ,tt-cash-pay.curr-code
                             ,chr(10)
                             ,par-pos-type
                            )                 ).
      assign
      v-view-log = yes
      .
      NEXT.
    end.
    dopi = 15 - MIN(length(TRIM(tt-cash-pay.obj-name)), 15).
    if dopi modulo 2 = 0 then
    dopi = dopi / 2.
    else
    assign dopi = TRUNCATE(dopi / 2, 0).
    assign
    v-version-dec = decimal(p-pos-version)
    no-error .
    release buf_dis-rule.
    if v-version-dec >= 4.55 then do:
      if action <> 'D':U  then do:
        find first buf_dis-cp-rule no-lock where
              buf_dis-cp-rule.cdpay-code = tt-cash-pay.cdpay-code
          and buf_dis-cp-rule.curr-code = tt-cash-pay.curr-code
          and buf_dis-cp-rule.host-code = v-host-code
          and buf_dis-cp-rule.obj-type = 'маг':U
          and buf_dis-cp-rule.obj-code = i-obj-code
          and buf_dis-cp-rule.discnt-role =  'simple-pay':U
          and buf_dis-cp-rule.pos-type =  'IBM':U no-error.
        if available buf_dis-cp-rule then do:
          find first buf_dis-rule no-lock where
                    buf_dis-rule.obj-type = 'маг':U
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                AND buf_dis-rule.sts = integer('0':U) no-error .
          if available buf_dis-rule then do:
          end.
        end.
        else do:
          find first buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.cdpay-code = tt-cash-pay.cdpay-code
            and buf_dis-cp-rule.curr-code = tt-cash-pay.curr-code
            and buf_dis-cp-rule.host-code = 0
            and buf_dis-cp-rule.obj-type = '':U
            and buf_dis-cp-rule.obj-code = 0
            and buf_dis-cp-rule.discnt-role =  'simple-pay':U
            and buf_dis-cp-rule.pos-type =  'IBM':U no-error.
          if available buf_dis-cp-rule then do:
            find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                  AND buf_dis-rule.sts = integer('0':U) no-error .
            if available buf_dis-rule then do:
            end.
          end.
        end.
      end.
    end.
    PUT stream IBMStream unformatted
    '5 "' string( Action, "x(1)" ) '" '
    string( tt-cash-pay.cdpay-code, ">9" )
    ' "'
    string(
            fill(" ", int(dopi)) +
            TRIM(replace(replace(tt-cash-pay.obj-name, chr(34), '':U), chr(39), '':U)) +
            fill(" ", int(dopi)), "x(13)"
          )
    '" '
    string( if multicurr
            then 0
            else (if tt-cash-pay.curr-code = 0
                  then kassa-rub-code
                  else tt-cash-pay.curr-code ), ">9" )
    " " string( tt-cash-pay.pay-limit, "->>>>>9.99" )
    " "
    string( int( tt-cash-pay.atr1 ) + int( tt-cash-pay.atr2 ) * 2 + int( tt-cash-pay.atr4 ) * 4 +
            int( tt-cash-pay.atr8 ) * 8 + int( tt-cash-pay.atr16 ) * 16 + int( tt-cash-pay.atr32 ) * 32 +
            int( tt-cash-pay.atr64 ) * 64 + int(tt-cash-pay.atr128) * 128 +
            (if v-version-dec >= 4.4
            then ( int( tt-cash-pay.is-service-pay ) * 256 +
                    int( tt-cash-pay.is-goods-pay ) * 512)
             else 0)
            , "999" )
    space(1)
    ( if Cash-OS2 then
    string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
    else "" )
    .
    if v-version-dec >= 4.55
      then do:
        put stream IBMStream unformatted
        chr(32)
        chr(34) string(tt-cash-pay.slip-file-name, "X(15)")    chr(34)
        chr(32)
        string(if available buf_Dis-rule
                then (if buf_dis-rule.value-type = integer('1':U)
                      then 2
                      else 1)
                else 0)
        chr(32)
        (if available buf_Dis-rule
        then
        (if buf_dis-rule.value-type = integer('1':U)
          then string(- buf_dis-rule.discnt-value, "->>9.99")
          else string(- buf_dis-rule.discnt-value, ">>>>>>>>9.99")
          )
        else string(0)
        )
        .
    end.
    PUT stream IBMStream unformatted
    skip .
  end.
  when 'IBM-XML':U then do:
   assign
    v-version-dec = decimal(p-pos-version)
    no-error .
    release buf_dis-rule.
    IF tt-cash-pay.is-cash = YES and
        ((tt-cash-pay.cdpay-code = 1 and NOT tt-cash-pay.curr-code = ibmnalc )  ) then NEXT.
    run bgelib-tag-open in this-procedure ( input 2, input "Payment"
                                          , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
                                                                                              then if tt-cash-pay.status_ eq 'тек':U  then "ADD":U else "DEL":U
                                                                                              else "DEL":U),
                                                              OS2-time,
                                                                              if tt-cash-pay.cdpay-code eq ?
                                                                              then "*"
                                                                              else string(tt-cash-pay.cdpay-code)
                                                                        )).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentLock":U
                                          , input string(if tt-cash-pay.status_ = 'тек':U then 0 else 1), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentName":U
                                          , input substr(tt-cash-pay.obj-name, 1, (if v-version-dec >= 1.08 then 35 else 15)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentCur":U
                                          , input string(if multicurr
                                                         then 0
                                                         else (if tt-cash-pay.curr-code = 0
                                                                then kassa-rub-code
                                                                else cash-pay.curr-code)
                                                         )
                                          , input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentSlip":U
                                          , input string(tt-cash-pay.slip-file-name), input 1 ).
    if v-version-dec >= 1.07 then do:
      if action <> 'D':U  then do:
        find first buf_dis-cp-rule no-lock where
              buf_dis-cp-rule.cdpay-code = tt-cash-pay.cdpay-code
          and buf_dis-cp-rule.curr-code = tt-cash-pay.curr-code
          and buf_dis-cp-rule.host-code = v-host-code
          and buf_dis-cp-rule.obj-type = 'маг':U
          and buf_dis-cp-rule.obj-code = i-obj-code
          and buf_dis-cp-rule.discnt-role =  'simple-pay':U
          and buf_dis-cp-rule.pos-type =  'IBM-XML':U no-error.
        if available buf_dis-cp-rule then do:
          find first buf_dis-rule no-lock where
                    buf_dis-rule.obj-type = 'маг':U
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                AND buf_dis-rule.sts = integer('0':U) no-error .
          if available buf_dis-rule then do:
          end.
        end.
        else do:
          find first buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.cdpay-code = tt-cash-pay.cdpay-code
            and buf_dis-cp-rule.curr-code = tt-cash-pay.curr-code
            and buf_dis-cp-rule.host-code = 0
            and buf_dis-cp-rule.obj-type = '':U
            and buf_dis-cp-rule.obj-code = 0
            and buf_dis-cp-rule.discnt-role =  'simple-pay':U
            and buf_dis-cp-rule.pos-type =  'IBM-XML':U no-error.
          if available buf_dis-cp-rule then do:
            find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                  AND buf_dis-rule.sts = integer('0':U) no-error .
            if available buf_dis-rule then do:
            end.
          end.
        end.
      end.
    end.
    if v-version-dec >= 1.12 then do:
      if action <> 'D':U  then do:
         find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
                                 and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
                                 and buf_cash-pay-attr.attr-code = "cash-prop" no-error .
      end.
    end.
    if AVAILABLE buf_cash-pay-attr then do:
        run bgelib-tag-put in this-procedure ( input 3, input "PaymentType":U
                                             ,input (buf_cash-pay-attr.attr-value)
                                            ,input 1
                                                     ).
    end.
    if available buf_dis-rule
    then do:
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentDType":U
                                             ,input (if buf_dis-rule.value-type = integer('1':U)
                                                     then 2
                                                     else 1)
                                            ,input 1
                                                     ).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentDisc":U
                                            , input (- buf_dis-rule.discnt-value)
                                          , input 1 ).
    end.
    else do:
      run bgelib-tag-put in this-procedure ( input 3
                                            ,input "PaymentDType":U
                                            ,input 0
                                            ,input 1
                                           ).
      run bgelib-tag-put in this-procedure ( input 3
                                            ,input "PaymentDisc":U
                                            ,input string(0)
                                            ,input 1 ).
    end.
    v-paymentetc = "" .
        find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = 'max_proc_sum':U no-error .
    if AVAILABLE buf_cash-pay-attr then
    do:
        v-paymentetc = "MaxLimit" + ":" + string(decimal(buf_cash-pay-attr.attr-value) * 100).
    end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = 'mask_card_kup':U no-error .
    if AVAILABLE buf_cash-pay-attr then
    do:
        v-paymentetc = v-paymentetc + "," + "Mask" + ":" + buf_cash-pay-attr.attr-value .
    end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-card-type" no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "FuelCard" + ":" + buf_cash-pay-attr.attr-value .
        end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-card-type-bank" no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "BankCard" + ":" + buf_cash-pay-attr.attr-value .
        end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "qr-mir"
        and buf_cash-pay-attr.attr-value = string(yes) no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "Ext" + ":" + "peace-qr" .
        end.
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentEtc":U
                                             ,input (trim(v-paymentetc,","))
                                            ,input 1
                                                     ).
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-type-pay-fr" no-error .
    if AVAILABLE buf_cash-pay-attr then do:
       run bgelib-tag-put in this-procedure ( input 3, input "PaymentFRType":U
                                             ,input buf_cash-pay-attr.attr-value
                                            ,input 1
                                                     ).
    end.
    run bgelib-tag-open in this-procedure ( input 3, input "PaymentStatus"
                                          , input "":U).
    run bgelib-tag-put in this-procedure ( input 4, input "PSCash":U
                                          , input string(if tt-cash-pay.is-cash then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSReturn":U
                                          , input string(if tt-cash-pay.atr1 or tt-cash-pay.has-return > 0 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSTransfer":U
                                          , input string(if tt-cash-pay.atr2 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSPrintSlip":U
                                          , input string(if tt-cash-pay.atr4 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSPrintFact":U
                                          , input string(if tt-cash-pay.atr8 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSAuthorize":U
                                          , input string(if tt-cash-pay.atr16
                                                        then 1
                                                        else 0), input 0 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSFuelPay":U
                                          , input string(if tt-cash-pay.atr64 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSServicePay":U
                                          , input string(if tt-cash-pay.is-service-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSUnitPay":U
                                          , input string(if tt-cash-pay.is-goods-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSAllPay":U
                                          , input string(if tt-cash-pay.is-all-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSChipCard":U
                                          , input string(if tt-cash-pay.atr128 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSRequestPin":U
                                          , input string(if tt-cash-pay.atr32 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSBarRead":U
                                          , input string(if tt-cash-pay.is-bar-read then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSCardSwap":U
                                          , input string(if tt-cash-pay.is-card-swap then 1 else 0), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PaymentStatus").
    run bgelib-tag-close in this-procedure ( input 2, input "Payment").
  end.
  when 'MARIA':U then do:
    v-found-maria-discnt = no.
    assign
    v-index = index((mariapayp + ";")
                    ,(chr(47) + string(tt-cash-pay.cdpay-code) + chr(44) + string(tt-cash-pay.curr-code) + ';')
                     ).
    if v-index > 0
    then do:
      do v-ii = 1 to num-entries(mariapayp, ';'):
        assign
        v-dop = entry(v-ii, mariapayp, ';')
        v-dop2 = entry(2, v-dop, chr(47))
        v-dop =  entry(1, v-dop, chr(47))
        v-plu = entry(2, v-dop)
        v-dop = entry(1, v-dop)
        .
        if entry(1,  v-dop2) = string(tt-cash-pay.cdpay-code)
        and entry(2, v-dop2) = string(tt-cash-pay.curr-code) then do:
          if  v-dop <> string(1)
          and v-plu <> string(0)
          then do:
            run maria-put in this-procedure (
                                            buffer buf_cash-desk
                                          , input out
                                          , input fname
                                          , input yes
                                          , input 0
                                          , input no
                                          , input integer(entry(1, entry(1, v-dop, chr(47))))
                                          , input 20
                                          , input v-plu
                                          , input (if action = 'D' then '':U else string(tt-cash-pay.obj-name, "X(18)"))).
          end.
          v-maria-discnt-value = string(0, '999').
          if action <> 'D':U  then do:
             find first buf_dis-cp-rule no-lock where
                    buf_dis-cp-rule.cdpay-code = tt-cash-pay.cdpay-code
                and buf_dis-cp-rule.curr-code = tt-cash-pay.curr-code
                and buf_dis-cp-rule.host-code = v-host-code
                and buf_dis-cp-rule.obj-type = 'маг':U
                and buf_dis-cp-rule.obj-code = i-obj-code
                and buf_dis-cp-rule.discnt-role =  'simple-pay':U
                and buf_dis-cp-rule.pos-type =  'MARIA':U no-error.
            if available buf_dis-cp-rule then do:
              find first buf_dis-rule no-lock where
                        buf_dis-rule.obj-type = 'маг':U
                    AND buf_dis-rule.obj-code = i-obj-code
                    AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                    AND buf_dis-rule.sts = integer('0':U) no-error .
             if available buf_dis-rule then do:
                if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
                  assign
                  v-dop2 = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
                  v-dop2 = substring(v-dop2, 1, index(v-dop2, chr(44)) - 1)
                  v-maria-rule-num = integer(entry(2, v-dop2, '-':U)) - 1
                  v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
                  .
                end.
              end.
            end.
          end.
          v-found-maria-discnt = yes.
          if v-dop = string(1) then do:
            entry(1 , v-record, chr(4) ) = v-maria-discnt-value.
          end.
          if v-dop <> string(1)
          and v-plu <> string(0) then do:
            entry( ((integer(v-dop) - 2) * 20 + integer(v-plu) + 414 - 9), v-record, chr(4)) =  v-maria-discnt-value.
          end.
        end.
      end.
    end.
    else do:
      if selective > 0 then
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Тип кассового платежа &1 (код &2 код валюты &3)&4не может быть отправлен на кассу типа &5&4" +
                              "Для данного типа касс типу кассового платежа должен быть задан КОД ОПЛАТЫ ТОПЛИВА НА кассе"
                             ,tt-cash-pay.obj-name
                             ,tt-cash-pay.cdpay-code
                             ,tt-cash-pay.curr-code
                             ,chr(10)
                             ,par-pos-type
                            )                 ).
    end.
  end.
END CASE.
        delete tt-cash-pay.
      end.
       else
        _selective:
        DO ii = 1 to NUm-ENTRIES(rid-list):
        rdlist =  int64(entry(ii, rid-list)).
          FIND FIRST ub.cash-pay No-LOCK WHERE
                    recid(ub.cash-pay) = rdlist No-ERROR.
          IF avail ub.cash-pay then do:
                    if not cp-isuse ( input  ub.cash-pay.cdpay-code                                  ,input  ub.cash-pay.curr-code                                          ,input  v-host-code                                                    ,input 'маг':U                                                         ,input i-obj-code                                                      ,input v-cp-is-use                                                     ,input par-cash-num                                                    ,input par-pos-type )                                                  then next _selective.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE par-pos-type:
  when 'IBM':U
  then do:
    IF cash-pay.is-cash = YES and
        ((cash-pay.cdpay-code = 1 and NOT cash-pay.curr-code = ibmnalc )  ) then NEXT.
    if cash-pay.status_ <> 'тек':U and action = 'U' and selective = 0 then NEXT.
    if cash-pay.cdpay-code > 99 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Тип кассового платежа &1 (код &2 код валюты &3)&4не может быть отправлен на кассу типа &5" +
                              "Для данного типа касс код платежа должен быть < 100"
                             ,cash-pay.obj-name
                             ,cash-pay.cdpay-code
                             ,cash-pay.curr-code
                             ,chr(10)
                             ,par-pos-type
                            )                 ).
      assign
      v-view-log = yes
      .
      NEXT.
    end.
    dopi = 15 - MIN(length(TRIM(cash-pay.obj-name)), 15).
    if dopi modulo 2 = 0 then
    dopi = dopi / 2.
    else
    assign dopi = TRUNCATE(dopi / 2, 0).
    assign
    v-version-dec = decimal(p-pos-version)
    no-error .
    release buf_dis-rule.
    if v-version-dec >= 4.55 then do:
      if action <> 'D':U  then do:
        find first buf_dis-cp-rule no-lock where
              buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
          and buf_dis-cp-rule.curr-code = cash-pay.curr-code
          and buf_dis-cp-rule.host-code = v-host-code
          and buf_dis-cp-rule.obj-type = 'маг':U
          and buf_dis-cp-rule.obj-code = i-obj-code
          and buf_dis-cp-rule.discnt-role =  'simple-pay':U
          and buf_dis-cp-rule.pos-type =  'IBM':U no-error.
        if available buf_dis-cp-rule then do:
          find first buf_dis-rule no-lock where
                    buf_dis-rule.obj-type = 'маг':U
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                AND buf_dis-rule.sts = integer('0':U) no-error .
          if available buf_dis-rule then do:
          end.
        end.
        else do:
          find first buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
            and buf_dis-cp-rule.curr-code = cash-pay.curr-code
            and buf_dis-cp-rule.host-code = 0
            and buf_dis-cp-rule.obj-type = '':U
            and buf_dis-cp-rule.obj-code = 0
            and buf_dis-cp-rule.discnt-role =  'simple-pay':U
            and buf_dis-cp-rule.pos-type =  'IBM':U no-error.
          if available buf_dis-cp-rule then do:
            find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                  AND buf_dis-rule.sts = integer('0':U) no-error .
            if available buf_dis-rule then do:
            end.
          end.
        end.
      end.
    end.
    PUT stream IBMStream unformatted
    '5 "' string( Action, "x(1)" ) '" '
    string( cash-pay.cdpay-code, ">9" )
    ' "'
    string(
            fill(" ", int(dopi)) +
            TRIM(replace(replace(cash-pay.obj-name, chr(34), '':U), chr(39), '':U)) +
            fill(" ", int(dopi)), "x(13)"
          )
    '" '
    string( if multicurr
            then 0
            else (if cash-pay.curr-code = 0
                  then kassa-rub-code
                  else cash-pay.curr-code ), ">9" )
    " " string( cash-pay.pay-limit, "->>>>>9.99" )
    " "
    string( int( cash-pay.atr1 ) + int( cash-pay.atr2 ) * 2 + int( cash-pay.atr4 ) * 4 +
            int( cash-pay.atr8 ) * 8 + int( cash-pay.atr16 ) * 16 + int( cash-pay.atr32 ) * 32 +
            int( cash-pay.atr64 ) * 64 + int(cash-pay.atr128) * 128 +
            (if v-version-dec >= 4.4
            then ( int( cash-pay.is-service-pay ) * 256 +
                    int( cash-pay.is-goods-pay ) * 512)
             else 0)
            , "999" )
    space(1)
    ( if Cash-OS2 then
    string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
    else "" )
    .
    if v-version-dec >= 4.55
      then do:
        put stream IBMStream unformatted
        chr(32)
        chr(34) string(cash-pay.slip-file-name, "X(15)")    chr(34)
        chr(32)
        string(if available buf_Dis-rule
                then (if buf_dis-rule.value-type = integer('1':U)
                      then 2
                      else 1)
                else 0)
        chr(32)
        (if available buf_Dis-rule
        then
        (if buf_dis-rule.value-type = integer('1':U)
          then string(- buf_dis-rule.discnt-value, "->>9.99")
          else string(- buf_dis-rule.discnt-value, ">>>>>>>>9.99")
          )
        else string(0)
        )
        .
    end.
    PUT stream IBMStream unformatted
    skip .
  end.
  when 'IBM-XML':U then do:
   assign
    v-version-dec = decimal(p-pos-version)
    no-error .
    release buf_dis-rule.
    IF cash-pay.is-cash = YES and
        ((cash-pay.cdpay-code = 1 and NOT cash-pay.curr-code = ibmnalc )  ) then NEXT.
    run bgelib-tag-open in this-procedure ( input 2, input "Payment"
                                          , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
                                                                                              then if cash-pay.status_ eq 'тек':U  then "ADD":U else "DEL":U
                                                                                              else "DEL":U),
                                                              OS2-time, cash-pay.cdpay-code
                                                                        )).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentLock":U
                                          , input string(if cash-pay.status_ = 'тек':U then 0 else 1), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentName":U
                                          , input substr(cash-pay.obj-name, 1, (if v-version-dec >= 1.08 then 35 else 15)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentCur":U
                                          , input string(if multicurr
                                                         then 0
                                                         else (if cash-pay.curr-code = 0
                                                                then kassa-rub-code
                                                                else cash-pay.curr-code)
                                                         )
                                          , input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentSlip":U
                                          , input string(cash-pay.slip-file-name), input 1 ).
    if v-version-dec >= 1.07 then do:
      if action <> 'D':U  then do:
        find first buf_dis-cp-rule no-lock where
              buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
          and buf_dis-cp-rule.curr-code = cash-pay.curr-code
          and buf_dis-cp-rule.host-code = v-host-code
          and buf_dis-cp-rule.obj-type = 'маг':U
          and buf_dis-cp-rule.obj-code = i-obj-code
          and buf_dis-cp-rule.discnt-role =  'simple-pay':U
          and buf_dis-cp-rule.pos-type =  'IBM-XML':U no-error.
        if available buf_dis-cp-rule then do:
          find first buf_dis-rule no-lock where
                    buf_dis-rule.obj-type = 'маг':U
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                AND buf_dis-rule.sts = integer('0':U) no-error .
          if available buf_dis-rule then do:
          end.
        end.
        else do:
          find first buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
            and buf_dis-cp-rule.curr-code = cash-pay.curr-code
            and buf_dis-cp-rule.host-code = 0
            and buf_dis-cp-rule.obj-type = '':U
            and buf_dis-cp-rule.obj-code = 0
            and buf_dis-cp-rule.discnt-role =  'simple-pay':U
            and buf_dis-cp-rule.pos-type =  'IBM-XML':U no-error.
          if available buf_dis-cp-rule then do:
            find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                  AND buf_dis-rule.sts = integer('0':U) no-error .
            if available buf_dis-rule then do:
            end.
          end.
        end.
      end.
    end.
    if v-version-dec >= 1.12 then do:
      if action <> 'D':U  then do:
         find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
                                 and buf_cash-pay-attr.curr-code = cash-pay.curr-code
                                 and buf_cash-pay-attr.attr-code = "cash-prop" no-error .
      end.
    end.
    if AVAILABLE buf_cash-pay-attr then do:
        run bgelib-tag-put in this-procedure ( input 3, input "PaymentType":U
                                             ,input (buf_cash-pay-attr.attr-value)
                                            ,input 1
                                                     ).
    end.
    if available buf_dis-rule
    then do:
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentDType":U
                                             ,input (if buf_dis-rule.value-type = integer('1':U)
                                                     then 2
                                                     else 1)
                                            ,input 1
                                                     ).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentDisc":U
                                            , input (- buf_dis-rule.discnt-value)
                                          , input 1 ).
    end.
    else do:
      run bgelib-tag-put in this-procedure ( input 3
                                            ,input "PaymentDType":U
                                            ,input 0
                                            ,input 1
                                           ).
      run bgelib-tag-put in this-procedure ( input 3
                                            ,input "PaymentDisc":U
                                            ,input string(0)
                                            ,input 1 ).
    end.
    v-paymentetc = "" .
        find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = 'max_proc_sum':U no-error .
    if AVAILABLE buf_cash-pay-attr then
    do:
        v-paymentetc = "MaxLimit" + ":" + string(decimal(buf_cash-pay-attr.attr-value) * 100).
    end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = 'mask_card_kup':U no-error .
    if AVAILABLE buf_cash-pay-attr then
    do:
        v-paymentetc = v-paymentetc + "," + "Mask" + ":" + buf_cash-pay-attr.attr-value .
    end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-card-type" no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "FuelCard" + ":" + buf_cash-pay-attr.attr-value .
        end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-card-type-bank" no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "BankCard" + ":" + buf_cash-pay-attr.attr-value .
        end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "qr-mir"
        and buf_cash-pay-attr.attr-value = string(yes) no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "Ext" + ":" + "peace-qr" .
        end.
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentEtc":U
                                             ,input (trim(v-paymentetc,","))
                                            ,input 1
                                                     ).
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-type-pay-fr" no-error .
    if AVAILABLE buf_cash-pay-attr then do:
       run bgelib-tag-put in this-procedure ( input 3, input "PaymentFRType":U
                                             ,input buf_cash-pay-attr.attr-value
                                            ,input 1
                                                     ).
    end.
    run bgelib-tag-open in this-procedure ( input 3, input "PaymentStatus"
                                          , input "":U).
    run bgelib-tag-put in this-procedure ( input 4, input "PSCash":U
                                          , input string(if cash-pay.is-cash then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSReturn":U
                                          , input string(if cash-pay.atr1 or cash-pay.has-return > 0 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSTransfer":U
                                          , input string(if cash-pay.atr2 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSPrintSlip":U
                                          , input string(if cash-pay.atr4 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSPrintFact":U
                                          , input string(if cash-pay.atr8 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSAuthorize":U
                                          , input string(if cash-pay.atr16
                                                        then 1
                                                        else 0), input 0 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSFuelPay":U
                                          , input string(if cash-pay.atr64 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSServicePay":U
                                          , input string(if cash-pay.is-service-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSUnitPay":U
                                          , input string(if cash-pay.is-goods-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSAllPay":U
                                          , input string(if cash-pay.is-all-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSChipCard":U
                                          , input string(if cash-pay.atr128 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSRequestPin":U
                                          , input string(if cash-pay.atr32 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSBarRead":U
                                          , input string(if cash-pay.is-bar-read then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSCardSwap":U
                                          , input string(if cash-pay.is-card-swap then 1 else 0), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PaymentStatus").
    run bgelib-tag-close in this-procedure ( input 2, input "Payment").
  end.
  when 'MARIA':U then do:
    v-found-maria-discnt = no.
    assign
    v-index = index((mariapayp + ";")
                    ,(chr(47) + string(cash-pay.cdpay-code) + chr(44) + string(cash-pay.curr-code) + ';')
                     ).
    if v-index > 0
    then do:
      do v-ii = 1 to num-entries(mariapayp, ';'):
        assign
        v-dop = entry(v-ii, mariapayp, ';')
        v-dop2 = entry(2, v-dop, chr(47))
        v-dop =  entry(1, v-dop, chr(47))
        v-plu = entry(2, v-dop)
        v-dop = entry(1, v-dop)
        .
        if entry(1,  v-dop2) = string(cash-pay.cdpay-code)
        and entry(2, v-dop2) = string(cash-pay.curr-code) then do:
          if  v-dop <> string(1)
          and v-plu <> string(0)
          then do:
            run maria-put in this-procedure (
                                            buffer buf_cash-desk
                                          , input out
                                          , input fname
                                          , input yes
                                          , input 0
                                          , input no
                                          , input integer(entry(1, entry(1, v-dop, chr(47))))
                                          , input 20
                                          , input v-plu
                                          , input (if action = 'D' then '':U else string(cash-pay.obj-name, "X(18)"))).
          end.
          v-maria-discnt-value = string(0, '999').
          if action <> 'D':U  then do:
             find first buf_dis-cp-rule no-lock where
                    buf_dis-cp-rule.cdpay-code = cash-pay.cdpay-code
                and buf_dis-cp-rule.curr-code = cash-pay.curr-code
                and buf_dis-cp-rule.host-code = v-host-code
                and buf_dis-cp-rule.obj-type = 'маг':U
                and buf_dis-cp-rule.obj-code = i-obj-code
                and buf_dis-cp-rule.discnt-role =  'simple-pay':U
                and buf_dis-cp-rule.pos-type =  'MARIA':U no-error.
            if available buf_dis-cp-rule then do:
              find first buf_dis-rule no-lock where
                        buf_dis-rule.obj-type = 'маг':U
                    AND buf_dis-rule.obj-code = i-obj-code
                    AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                    AND buf_dis-rule.sts = integer('0':U) no-error .
             if available buf_dis-rule then do:
                if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
                  assign
                  v-dop2 = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
                  v-dop2 = substring(v-dop2, 1, index(v-dop2, chr(44)) - 1)
                  v-maria-rule-num = integer(entry(2, v-dop2, '-':U)) - 1
                  v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
                  .
                end.
              end.
            end.
          end.
          v-found-maria-discnt = yes.
          if v-dop = string(1) then do:
            entry(1 , v-record, chr(4) ) = v-maria-discnt-value.
          end.
          if v-dop <> string(1)
          and v-plu <> string(0) then do:
            entry( ((integer(v-dop) - 2) * 20 + integer(v-plu) + 414 - 9), v-record, chr(4)) =  v-maria-discnt-value.
          end.
        end.
      end.
    end.
    else do:
      if selective > 0 then
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Тип кассового платежа &1 (код &2 код валюты &3)&4не может быть отправлен на кассу типа &5&4" +
                              "Для данного типа касс типу кассового платежа должен быть задан КОД ОПЛАТЫ ТОПЛИВА НА кассе"
                             ,cash-pay.obj-name
                             ,cash-pay.cdpay-code
                             ,cash-pay.curr-code
                             ,chr(10)
                             ,par-pos-type
                            )                 ).
    end.
  end.
END CASE.
          end.
        END.
    end.
  end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE   for-cash-cycle:
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define buffer for-cash-desk for ub.cash-desk.
  FOR EACH for-cash-desk NO-LOCK WHERE
          for-cash-desk.db-num = g#db-num AND
          for-cash-desk.pos-type = ub.cash-desk.pos-type AND
          for-cash-desk.obj-code = i-obj-code AND
          for-cash-desk.cash-on  = yes:
     IF (LOOKUP(ub.cash-desk.pos-type,
              ('NCR-GM':U + chr(44) +
               'IBM-XML':U + chr(44) +
               'MAGIA-XML':U + chr(44) +
               'NCR-AS@R':U
               )) > 0
     and for-cash-desk.autonomy = integer('1':U)) then NEXT.
   if LOOKUP(ub.cash-desk.pos-type,
            'MARIA':U
               ) > 0
    and for-cash-desk.autonomy = integer('2':U) then next.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка - касса &1", for-cash-desk.cash-num)
                                                      ).
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( ("''" + " &1")
                            , replace( v-xml-file-name-path, "/", "\" ) + "xm1"
                      )
                                      ).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "................с параметрами: ... магазин: &1", i-obj-code )
                                      ).
assign
v-obj-list = 'маг':U + string(i-obj-code)
.
run xml-cd-write-header in this-procedure (
      input v-xml-file-name
    , input v-xml-file-name-path
    , input 'data'
    , input "14.0 " + replace( vss-revision + vss-date, "$", " " )
    , input v-obj-list
    , input (
              (IF for-cash-desk.pos-type = 'IBM-XML':U
                then (if for-cash-desk.autonomy = integer('0':U)
                      then  ("маг" + string(for-cash-desk.obj-code) + "_касса" + string(for-cash-desk.cash-num))
                      else ("КМ"   )
                      )
                else ("маг" + string(for-cash-desk.obj-code) +  "_касса" + string(for-cash-desk.cash-num))
                )
            )
    , input (if for-cash-desk.autonomy = integer('0':U) then no else yes)
).
output stream stmxmlout to value( v-xml-file-name-path + "xm1" ) convert target "1251" append.
OS2-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9").
  end.
  when 'IBM':U
  then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if for-cash-desk.cash-os = ""
AND for-cash-desk.pos-type <> 'Emulator-NKT-IBM':U
then NEXT.
assign
Cash-OS2 = (for-cash-desk.cash-os = "OS/2":U) OR (for-cash-desk.cash-os = "LINUX":U)
            AND for-cash-desk.pos-type <> 'Emulator-NKT-IBM':U
Cash-DOS = NOT CASH-OS2
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 )
v-dir-remote-tmp = v-remote + "tmp":U
v-dir-remote = v-remote + "out":U + string(for-cash-desk.obj-code, "99999") + "-" + string(for-cash-desk.cash-num, "999")
.
if for-cash-desk.remote = 1 then do:
  run gbl/dir-cre.p ( input v-dir-remote-tmp) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote-tmp
                            ,for-cash-desk.cash-num
                            ,chr(10)
                            )
                                            ).
      NEXT.
  end.
  run gbl/dir-cre.p ( input v-dir-remote ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote
                            ,for-cash-desk.cash-num
                            ,chr(10)
                            )
                                            ).
      NEXT.
    end.
end.
output stream IBMStream
to value( (if for-cash-desk.remote = 1
            then (v-dir-remote-tmp + chr(47) + "fl":U)
            else out) + fname + '.dat' ) convert target "ibm866".
OS2-time =       ( if Cash-OS2 then
                                    string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
                      else "" )
.
  end.
  when 'MARIA':U then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
    v-record = fill( chr(63) + chr(4), 465).
  end.
END CASE.
      RUN putc-5 in this-procedure (buffer for-cash-desk
                                   ,input for-cash-desk.cash-num
                                   ,input for-cash-desk.pos-type
                                   ,input for-cash-desk.version
                                   ).
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream stmxmlout close.
run xml-cd-write-footer in this-procedure ( input for-cash-desk.pos-type, input v-xml-file-name-path
    , input 'data'
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1"
                            , replace( v-xml-file-name-path, "/", "\" ) + "xml"
                      )
                                       ).
if (
not (g#news or g#auto or g#esys )
or
(
for-cash-desk.pos-type = 'MAGIA-XML':U
or
  (for-cash-desk.pos-type = 'IBM-XML':U
or (for-cash-desk.pos-type = 'Autotank':U
  and
  for-cash-desk.autonomy = integer('2':U))
  )))
then do:
  if for-cash-desk.pos-type = 'MAGIA-XML':U then do:
  end.
  if (for-cash-desk.pos-type = 'IBM-XML':U
  and for-cash-desk.autonomy = integer('0':U))
  or (for-cash-desk.pos-type = 'Autotank':U
  and for-cash-desk.autonomy = integer('2':U))
  then do:
    run str/post-xml.p
      (
       input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input g#news or g#esys
      ,input g#auto
      ,input 'send'
      ,input log-file-name
      ,input (entry(1, for-cash-desk.addr-path, chr(4)) + '://' + entry(2, for-cash-desk.addr-path, chr(4)))
      ,input (replace( v-xml-file-name-path, "/", "\" ) + "xml")
      ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
      ,input 30
      ,input   ( if action = 'U'
                  then ('Ждите - ' + 'добавление типов оплат')
                  else ('Ждите - ' + 'удаление типов оплат') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num)
      ) no-error .
    if error-status:error
    or return-value = "error" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных:&3&4 &5"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
  if not available ub.shop then do:
    find first ub.shop no-lock where
              ub.shop.obj-code = for-cash-desk.obj-code.
  end.
  if
  not (g#news or g#esys)
  then do:
    run str/getxibmf.p (
                    input parparentproc
                  ,input p-log-handle
                  ,input 'маг':U
                  ,input for-cash-desk.obj-code
                  ,input ub.shop.host-code
                  ,input in_
                  ,input spl
                  ,input (in_ + sav)
                  ,input for-cash-desk.pos-type
                  ,input (if (for-cash-desk.pos-type = 'IBM-XML':U
                          and for-cash-desk.autonomy = integer('0':U))
                          or (for-cash-desk.pos-type = 'Autotank':U
                          and for-cash-desk.autonomy = integer('2':U))
                          then "utf-8":U
                          else "windows-1251")
                  ,input log-file-name
                  ,input "data":U
                  ,input v-xml-file-name
                  ,input-output v-view-log
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
end.
if g#news
or g#auto
or g#esys
and for-cash-desk.pos-type = 'MAGIA-XML':U
then do:
end.
  end.
  when 'IBM':U
  then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream IBMStream close.
output stream IBMStream
to value( (if for-cash-desk.remote = 1
            then (v-dir-remote-tmp + chr(47) + "fl":U)
            else out) + fname + '.ad0' ) convert target "ibm866".
put stream IBMStream ' ' skip(1).
 put stream IBMStream unformatted '  ' for-cash-desk.addr-path ' plu' skip.
output stream IBMStream close.
OS-RENAME
VALUE((if for-cash-desk.remote = 1
        then (v-dir-remote-tmp + chr(47) + "fl":U)
        else out) + fname + '.ad0')
VALUE((if for-cash-desk.remote = 1
        then (v-dir-remote + chr(47) + "fl":U)
        else out) + fname + '.adr').
os-er = OS-ERROR.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1, файл адреса &2"
                        , ((if for-cash-desk.remote = 1
                            then (v-dir-remote + chr(47) + "fl":U)
                            else out) + fname + '.dat')
                        , ((if for-cash-desk.remote = 1
                            then (v-dir-remote + chr(47) + "fl":U)
                            else out) + fname + '.adr')
                        )
                                       ).
if os-er <> 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                            for-cash-desk.cash-num
                        )
                                        ).
      assign
      v-view-log = yes
      .
      return "error":U.
end.
if for-cash-desk.remote = 1 then do:
  OS-RENAME
  VALUE(v-dir-remote-tmp + chr(47) + "fl":U + fname + '.dat')
  VALUE(v-dir-remote  + chr(47) + "fl":U + fname + '.dat').
  os-er = OS-ERROR.
  if os-er <> 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Данные выгружены в файл &1",
                            (v-dir-remote  + chr(47) + "fl":U + fname + '.dat')
                        )
                                        ).
end.
else do:
  if not g#news
  and not g#auto
  and not g#esys
  then do:
      run str/waitp.w ( out + fname + '.dat',
                  ( if action = 'U'
                    then ('Ждите - ' + 'добавление типов оплат')
                    else ('Ждите - ' + 'удаление типов оплат') ) +
                    for-cash-desk.addr-path,
                    ' Подождите 15 сек ',
                    'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                    15 ) no-error.
    if error-status:error then do:
      os-delete value( out + fname + '.adr' ) .
      os-delete value( out + fname + '.ad0' ) .
      os-delete value( out + fname + '.dat' ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Прерван обмен информацией с кассой &1, на кассе осталась устаревшая информация",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
    end.
  end.
end.
  end.
  when 'MARIA':U then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found23 as logical no-undo .
define variable v-is-script23 as logical no-undo.
define variable v-fields-shift23 as integer no-undo .
   if can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = 2 )
   or can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = 3 )
   or can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = 4 )
   or v-found-maria-discnt
   then do:
    v-fields-shift23 = 9 - 1.
if v-record <> '':U then
    run maria-put in this-procedure (
                                    buffer for-cash-desk
                                  , input out
                                  , input fname
                                  , input yes
                                  , input v-fields-shift23
                                  , input yes
                                  , input 24
                                  , input 1
                                  , input string(1)
                                  , input v-record
                                    ).
   end.
find first temp-tekka-tsk no-error.
if available temp-tekka-tsk then do:
   v-found23 = yes.
end.
if v-found23 = yes then do:
output stream IBmSTREAM to VALUE(out + fname + '.tsk').
v-is-script23 = no.
for each temp-tekka-tsk:
  if (temp-tekka-tsk.num-rec > 0
  or temp-tekka-tsk.send-get = 'task')
  and temp-tekka-tsk.task-num = fname then do:
    export stream IBmSTREAM temp-tekka-tsk.
    v-found23 = yes.
  end.
  if temp-tekka-tsk.is-script then do:
    v-is-script23 = yes.
  end.
  delete temp-tekka-tsk.
end.
output stream IBMStream
close.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файлы &1(..),&2файл задания &3"
                        , (out + fname)
                        , chr(10)
                        , (out + fname + '.tsk')
                        )
                                       ).
run str/runtekka.p (
                     input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input out
                    ,input out
                    ,input fname
                    ,input v-remote
                    ,input v-is-script23
                    ) no-error .
if error-status:error then do:
  for each temp-tekka-tsk:
    os-delete value( temp-tekka-tsk.filename) .
    delete temp-tekka-tsk.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Прерван обмен информацией с кассой &1,&2&3&2на кассе осталась устаревшая информация"
                           ,for-cash-desk.cash-num
                           ,chr(10)
                           ,return-value
                        )
                                        ).
  assign
  v-view-log = yes
  .
  return "error":U.
end.
else do:
end.
end.
  end.
END CASE.
  END .
END PROCEDURE.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = g#db-num
     AND ub.cash-desk.obj-code = i-obj-code
     AND ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dflt-cd25 as character no-undo .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type26 as character no-undo .
define variable v-value-date26 as date no-undo .
define variable v-value-decimal26 as decimal no-undo .
define variable v-value-integer26 as INTEGER no-undo .
define variable v-value-logical26 AS LOGICAL no-undo .
define variable v-tth26 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.cash-desk.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd25
    ,output v-value-date26
    ,output v-value-decimal26
    ,output v-value-integer26
    ,output v-value-logical26
    ,output v-param-type26
    ,INPUT-OUTPUT table-handle v-tth26
    ) no-error .
delete object v-tth26 no-error.
case ub.cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
if ub.cash-desk.pos-type = 'IBM-XML':U
or ub.cash-desk.pos-type = 'Autotank':U
then do:
  file-info:file-name = (out  + "undelivered").
  if file-info:FULL-PATHNAME <> ? then do:
    run str/rsndxibm.p ( input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input out  + "undelivered" ) no-error.
  end.
end.
  if ub.cash-desk.pos-type = 'IBM-XML':U
  then do:
  run adm/shattri.p (
      input "get":U
      ,input  'маг':U
      ,input  ub.cash-desk.obj-code
      ,input  'cd-type-IBM-XML':U
      ,input  'ibmrubc':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
    IF not error-status:error then do:
      delete object v-tth.
      kassa-rub-code = v-value-integer.
    end.
    else do:
      delete object v-tth.
      return error return-value .
    end.
  end.
  else do:
    kassa-rub-code = 0.
  end.
  if ub.cash-desk.pos-type = 'IBM-XML':U then do:
    run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-IBM-XML':U
        ,input  'ibmnalc':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF not error-status:error then do:
      delete object v-tth.
      ibmnalc = v-value-integer.
    end.
    else do:
      delete object v-tth.
      return error return-value .
    end.
    multicurr = no.
    run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-IBM-XML':U
        ,input  'multicurr':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
      delete object v-tth.
      multicurr = v-value-logical.
  end.
  end.
  when 'IBM':U
  then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
 run adm/shattri.p (
      input "get":U
      ,input  'маг':U
      ,input  ub.cash-desk.obj-code
      ,input  'cd-type-ibm':U
      ,input  'ibmrubc':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
    IF not error-status:error
    then do:
      delete object v-tth.
      kassa-rub-code = v-value-integer.
    end.
    else do:
      delete object v-tth.
      return error return-value .
    end.
  run adm/shattri.p (
      input "get":U
      ,input  'маг':U
      ,input  ub.cash-desk.obj-code
      ,input  'cd-type-ibm':U
      ,input  'ibmnalc':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF not error-status:error then do:
    delete object v-tth.
    ibmnalc = v-value-integer.
  end.
  else do:
    delete object v-tth.
    return error return-value .
  end.
  multicurr = no.
  run adm/shattri.p (
      input "get":U
      ,input  'маг':U
      ,input  ub.cash-desk.obj-code
      ,input  'cd-type-ibm':U
      ,input  'multicurr':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
    delete object v-tth.
    multicurr = v-value-logical.
  end.
  when 'MARIA':U then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
  run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-maria':U
        ,input  'mariapayp':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
  IF not error-status:error then do:
    delete object v-tth.
    mariapayp = v-value-character.
  end.
  else do:
    delete object v-tth.
    return error return-value .
  end.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-maria':U
        ,input  'dr-list':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then do:
  delete object v-tth.
  dr-list = v-value-character.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
  end.
END CASE.
    RUN for-cash-cycle no-error.
  END.
  IF LAST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case ub.cash-desk.pos-type:
END CASE.
  END.
END.
END PROCEDURE.
assign
log-file-name = p-log-file-name
.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  i-obj-code
  ,output v-host-code
  )  .
if     action = "D"
   and rid-list ne "*"
then do:
  message
  "Вы действительно хотите удалить с кассы записи от типах кассовых платежей?"
  view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then return.
end.
if action = 'D':U then do:
  assign
  v-cp-is-use = no.
end.
if action <> 'D':U then do:
  run adm/shattri.p (
      input "get":U
      ,input  'маг':U
      ,input  i-obj-code
      ,input  'cd-inf-send':U
      ,input  'cp-is-use':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF not error-status:error
  then do:
    v-cp-is-use = v-value-logical.
    delete object v-tth.
  end.
  else do:
    delete object v-tth.
    return error return-value .
  end.
end.
RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке типов кассовых платежей на кассы  маг&1:&2&3 &4"
                         , i-obj-code
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                        )
                                        ).
  assign
  v-view-log = yes
  .
end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Сформированы файлы для касс объекта &1&2", 'маг':U, i-obj-code)
                                                  ).
