block-level on error undo, throw.
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пересылка скидки на итог на кассу".
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
define variable i-obj-code like ub.clients.obj-code no-undo .
define variable action as char no-undo.
define variable p-what-send as character no-undo .
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
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-rule.des               no-undo .
    define output parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
    define output parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
    define output parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
    define output parameter  p-level-1           as character no-undo .
    define output parameter  p-level-2           as character no-undo .
    define output parameter  p-global             as integer no-undo .
    define output parameter  p-host               as integer no-undo .
    define output parameter  p-object             as integer no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-other as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-templ-rl-root no-error.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный шаблон скидки &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-rule.des
    p-discnt-type = buf_dis-rule.discnt-type
    p-subject-type = buf_dis-rule.subject-type
    p-value-type = buf_dis-rule.value-type
    p-global = (if available buf_dis-cfg-rule
                then buf_dis-cfg-rule.has-global
                else 0)
    p-host = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-host
              else 0)
    p-object = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-obj
              else 0)
    p-output-display = (buf_dis-rule.sts = integer('0':U))
    p-tree = buf_Dis-rule.uniq-field
    p-other = buf_dis-rule.other-inf
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    .
  end.
end procedure.
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table cash-ncr-dis-kat no-undo
field cd-subject-code as character
field cd-subject-name as character
field dis-kat    like ub.dis-rule.dis-kat
field rule-num   like ub.dis-rule.rule-num
field time-rule-num like ub.dis-rule.time-rule-num
field crf as integer
field subject-code   as character
FIELD cd-disc-string    as character
field cd-other  as character
index pi is unique primary crf
index isubject cd-subject-code dis-kat
index idiskat dis-kat cd-subject-code cd-disc-string
.
define temp-table temp-dis-kat-file no-undo
field temp-file as character
field send-file as character
field to-send as logical
field dis-kat as integer
index pi is unique primary dis-kat
index isend to-send
.
define temp-table cash-ncr-save-param no-undo
field cd-line as character
field cd-other as character
field dis-kat as integer
index pi is unique primary dis-kat cd-line
.
 define variable v-found-good as log no-undo .
 define variable i-host-code as int no-undo .
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table cash-dis-rule no-undo like ub.dis-rule.
define temp-table cash-dis-time-rule no-undo like ub.dis-time-rule.
procedure create-dis-rule :
define input parameter p-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-tree as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer term_dis-time-rule for ub.dis-time-rule.
define buffer root_cash-dis-rule for cash-dis-rule.
define buffer root_cash-dis-time-rule for cash-dis-time-rule.
define buffer term_cash-dis-rule for cash-dis-rule.
define buffer term_cash-dis-time-rule for cash-dis-time-rule.
  do
  on error undo, return error
  :
    find first root_cash-dis-rule no-lock where                                                         ~
              root_cash-dis-rule.rule-num = p-rule-num no-error.
    if not available root_cash-dis-rule then do:
      find first buf_dis-rule no-lock where
                buf_dis-rule.rule-num = p-rule-num no-error.
      if available buf_dis-rule then do:
        if buf_dis-rule.time-rule-num <> 0 then do:
          find first buf_dis-time-rule no-lock where
                    buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
        end.
        create root_cash-dis-rule.
        buffer-copy buf_dis-rule to root_cash-dis-rule.
        if available buf_dis-time-rule then do:
          find first root_cash-dis-time-rule no-lock where
                    root_cash-dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
          if not available root_cash-dis-time-rule then do:
            create root_cash-dis-time-rule.
            buffer-copy buf_dis-time-rule to root_cash-dis-time-rule.
          end.
        end.
        else do:
          assign
          root_cash-dis-rule.time-rule-num = 0.
        end.
        if buf_dis-rule.uniq-field <> "":U then do:
          for each term_dis-rule no-lock where
                  term_dis-rule.upper-rule-num =  buf_dis-rule.rule-num:
            if term_dis-rule.time-rule-num <> 0 then do:
              find first term_dis-time-rule no-lock where
                        term_dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
            end.
            create term_cash-dis-rule.
            buffer-copy term_dis-rule to term_cash-dis-rule.
            if term_dis-rule.time-rule-num = 0
            or available term_dis-time-rule
            or root_cash-dis-rule.time-rule-num = 0
            then do:
              if available term_dis-time-rule then do:
                find first term_cash-dis-time-rule no-lock where
                          term_cash-dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
                if not available term_cash-dis-time-rule then do:
                  create term_cash-dis-time-rule.
                  buffer-copy term_dis-time-rule to term_cash-dis-time-rule.
                end.
              end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable dflt-cd as character no-undo .
define variable cr-ncr-dis-kat               as integer       no-undo .
define variable ncr-save-param               as character         no-undo init 'no'.
define variable v-upper-rule-num-tot-discnt like ub.dis-rule.upper-rule-num no-undo .
define variable v-upper-rule-num-tot-discnt-kat like ub.dis-rule.upper-rule-num no-undo .
define variable v-template-list-tot-discnt as character no-undo .
define variable v-template-list-gds as character no-undo .
define variable v-template-list-group as character no-undo .
define variable v-template-list-payment as character no-undo .
define variable v-template-list-client as character no-undo .
define variable v-record as character no-undo .
define variable dr-list as character no-undo .
define stream plucash.
define stream bar.
define buffer lock-batchprocess for ub.batchprocess .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE putc-9.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter p-pos-type as char no-undo.
define variable ii  as  integer     no-undo.
define variable v-version as decimal no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-maria-rule-num as integer no-undo .
define variable v-dop as character no-undo .
define variable v-date-from as date no-undo .
define variable v-date-to as date no-undo .
define variable v-time-rule-num as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_cash-dis-rule for cash-dis-rule.
CASE p-pos-type:
  when 'IBM':U
  then do:
    if v-upper-rule-num-tot-discnt > 0 then do:
      find first cash-dis-rule no-lock where
           cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt no-error.
      if cash-dis-rule.templ-rl-root = 20 then do:
        PUT stream IBMstream unformatted
        '9 "'
        string( "D", "x(1)" )
        '" '.
        PUT stream IBMstream unformatted
        chr(10).
      PUT stream IBMstream unformatted
      '9 "'
      string( action, "x(1)" )
      '" '.
      if action = 'U':U then do:
        for each cash-dis-rule no-lock where
                cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt
                  :
            PUT stream IBMstream unformatted
            cash-dis-rule.tot-sum chr(32) (- cash-dis-rule.discnt-value) chr(32)
            .
        end.
      end.
      PUT stream IBMstream unformatted
      chr(10).
    end.
    end.
    if p-pos-type = 'IBM':U
    and v-upper-rule-num-tot-discnt-kat > 0 then do:
      find first cash-dis-rule no-lock where
           cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt-kat  no-error.
      assign
      v-version = 0
      v-version = decimal(buf_cash-desk.version)
      no-error.
      if v-version < 4.53 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Невозможно передать на кассу &1 &2&3&4" +
                                "Данный функционал доступен только для POS &5 с версии ПО кассы 4.53"
                              ,  buf_cash-desk.cash-num
                              , 'маг':U
                              , buf_cash-desk.obj-code
                              , chr(10)
                              , 'IBM':U
                              )
                                              ).
      end.
      if v-version >= 4.53
      and cash-dis-rule.templ-rl-root = 53 then do:
        PUT stream IBMstream unformatted
        '24 "'
        string( "D", "x(1)" )
        '" '.
        PUT stream IBMstream unformatted
        chr(10).
      PUT stream IBMstream unformatted
      '24 "'
      string( action, "x(1)" )
      '" '.
      if action = 'U':U then do:
        for each cash-dis-rule no-lock where
                cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt-kat
                  :
            PUT stream IBMstream unformatted
            cash-dis-rule.tot-sum chr(32) (- cash-dis-rule.discnt-value) chr(32)
            (if cash-dis-rule.dis-kat >= 0
            then (string(cash-dis-rule.dis-kat) + chr(32))
            else '':U)
            .
        end.
      end.
      PUT stream IBMstream unformatted
      chr(10).
    end.
  end.
  end.
  when 'IBM-XML':U then do:
    if (v-upper-rule-num-tot-discnt > 0
        or
        v-upper-rule-num-tot-discnt-kat > 0)
    and action = 'U':U
    then do:
      run bgelib-tag-open in this-procedure ( input 2, input "TotalDisc"
                                            , input substitute("code='*' ctrl='&1' tms='&2' "
                                                            , "DEL":U
                                                            , integer(OS2-time) - 1)).
      run bgelib-tag-close in this-procedure ( input 2, input "TotalDisc").
      _ii:
      do ii = 1 to 2:
        if ii = 1 and v-upper-rule-num-tot-discnt = 0 then next _ii.
        if ii = 2 and v-upper-rule-num-tot-discnt-kat = 0 then next _ii.
        for each buf_cash-dis-rule no-lock where
                (ii = 1
                 and v-upper-rule-num-tot-discnt <= 99999
                 and buf_cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt
                )
                or
                (ii = 1
                 and v-upper-rule-num-tot-discnt > 99999
                 and buf_cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt
                )
                or
                (ii = 2
                 and v-upper-rule-num-tot-discnt-kat <= 99999
                 and buf_cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt-kat)
                 or
                (ii = 2
                 and v-upper-rule-num-tot-discnt-kat > 99999
                 and buf_cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt-kat
                )
                ,
          each cash-dis-rule no-lock where
              (buf_cash-dis-rule.is-term and cash-dis-rule.rule-num = buf_cash-dis-rule.rule-num)
               or
               (not buf_cash-dis-rule.is-term and cash-dis-rule.upper-rule-num = buf_cash-dis-rule.rule-num):
          if buf_cash-dis-rule.time-rule-num > 0 then do:
            v-time-rule-num = buf_cash-dis-rule.time-rule-num.
          end.
          if cash-dis-rule.time-rule-num > 0  then do:
            v-time-rule-num = cash-dis-rule.time-rule-num.
          end.
          if v-time-rule-num > 0  then do:
            find first cash-dis-time-rule where
                    cash-dis-time-rule.time-rule-num = v-time-rule-num no-error.
            if available cash-dis-time-rule then do:
              assign
              v-date-from = cash-dis-time-rule.date-from
              v-date-to = cash-dis-time-rule.date-to
              .
            end.
            else do:
              assign
              v-date-from = today
              v-date-to = 12/31/9999
              .
            end.
          end.
          else do:
            assign
            v-date-from = today
            v-date-to = 12/31/9999
            .
          end.
          run bgelib-tag-open in this-procedure ( input 2, input "TotalDisc"
                                                , input substitute("code='&1' ctrl='&2' tms='&3' "
                                                                , cash-dis-rule.rule-num
                                                                , (if action = "U"
                                                                    then "ADD":U
                                                                    else "DEL":U)
                                                                  , OS2-time)).
          run bgelib-tag-put in this-procedure ( input 3, input "TotalSum":U
                                                , input string(cash-dis-rule.tot-sum), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TotalPercent":U
                                                , input string(- cash-dis-rule.discnt-value), input 1 ).
          define variable v-dis-kat as integer no-undo .
          if cash-dis-rule.is-term = yes
          and cash-dis-rule.dis-kat <= 0
          and buf_cash-dis-rule.rule-num >  99999
          and buf_cash-dis-rule.dis-kat > 0  then do:
            v-dis-kat = buf_cash-dis-rule.dis-kat.
          end.
          else do:
            v-dis-kat = cash-dis-rule.dis-kat.
          end.
          run bgelib-tag-put in this-procedure ( input 3, input "TotalCat":U
                                                , input string(if v-dis-kat < 0 then 0 else v-dis-kat), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TotalDateBegin":U
                                                , input Xml-CD-DatetoString(v-date-from), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TotalDateEnd":U
                                                , input Xml-CD-DatetoString (v-date-to), input 1 ).
          run bgelib-tag-close in this-procedure ( input 2, input "TotalDisc").
        end.
      end.
    end.
    else do:
        run bgelib-tag-open in this-procedure ( input 2, input "TotalDisc"
                                              , input substitute("code='*' ctrl='&1' tms='&2' "
                                                                ,"DEL":U
                                                                , OS2-time)).
        run bgelib-tag-close in this-procedure ( input 2, input "TotalDisc").
    end.
  end.
  when 'NCR-AS@R':U then do:
   if action = 'U':U then do:
     if v-upper-rule-num-tot-discnt > 0 then do:
        find first cash-dis-rule where
                  cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt.
        run create-ncr-kat-discnt in this-procedure (
                                                    input string(0)
                                                    ,input ('SD' + fill( chr(32) , 10) + "****")
                                                    ,input cash-dis-rule.des
                                                    ,input cash-dis-rule.rule-num
                                                    ,input 20
                                                    ,input 'tot-sum':U
                                                    ,input ?
                                                    ) no-error .
     end.
     if v-upper-rule-num-tot-discnt-kat > 0 then do:
     for each cash-dis-rule no-lock where
              cash-dis-rule.templ-rl-root = 35
          and cash-dis-rule.dis-kat < 0
          :
        run create-ncr-kat-discnt in this-procedure (
                                                    input string(0)
                                                    ,input ('SD' + fill( chr(32) , 10) + "****")
                                                    ,input cash-dis-rule.des
                                                    ,input cash-dis-rule.rule-num
                                                    ,input 35
                                                    ,input 'tot-sum':U
                                                    ,input ?
                                                    ) no-error .
        if error-status:error then do:
        end.
      end.
     end.
   end.
    if action = "D":U then do:
      run create-ncr-kat-discnt in this-procedure (
                                                  input string(0)
                                                  ,input ('SD' + fill( chr(32) , 10) + "****")
                                                  ,input '':U
                                                  ,input 0
                                                  ,input 0
                                                  ,input 'tot-sum':U
                                                  ,input ?
                                                  ) no-error .
    end.
  end.
  when 'MARIA':U then do:
    v-maria-discnt-value = string(0, '999').
    if action <> 'D':U  then do:
      find first cash-dis-rule no-lock where
        cash-dis-rule.obj-type = 'маг':U
            AND cash-dis-rule.obj-code = i-obj-code
            AND cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt
            AND cash-dis-rule.sts = integer('0':U) no-error .
      if  available cash-dis-rule then do:
        if index(dr-list, string(cash-dis-rule.rule-num) + '-') > 0 then do:
          assign
          v-dop = substring(dr-list, index(dr-list, string(cash-dis-rule.rule-num) + '-':U))
          v-dop = substring(v-dop, 1, index(v-dop, chr(44)) - 1)
          v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
          v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
          .
        end.
      end.
    end.
    entry(1, v-record, chr(4)) = v-maria-discnt-value.
  end.
END CASE .
END PROCEDURE .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE putctodr.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter p-pos-type as char no-undo.
CASE p-pos-type:
  when 'MARIA':U then do:
    run putc-dr-maria in this-procedure ( buffer buf_cash-desk
                                        ,input v-template-list-tot-discnt ).
  end.
END CASE .
END PROCEDURE .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE putcgddr.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter p-pos-type as char no-undo.
CASE p-pos-type:
  when 'MARIA':U then do:
    run putc-dr-maria in this-procedure ( buffer buf_cash-desk
                                        ,input v-template-list-gds ).
  end.
END CASE .
END PROCEDURE .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE putcgrdr.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter p-pos-type as char no-undo.
CASE p-pos-type:
  when 'MARIA':U then do:
    run putc-dr-maria in this-procedure ( buffer buf_cash-desk
                                        ,input v-template-list-group ).
  end.
END CASE .
END PROCEDURE .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE putcpmdr.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter p-pos-type as char no-undo.
CASE p-pos-type:
  when 'MARIA':U then do:
    run putc-dr-maria in this-procedure ( buffer buf_cash-desk
                                        ,input v-template-list-payment ).
  end.
END CASE .
END PROCEDURE .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE putccldr.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter p-pos-type as char no-undo.
CASE p-pos-type:
  when 'MARIA':U then do:
    run putc-dr-maria in this-procedure ( buffer buf_cash-desk
                                        ,input v-template-list-client ).
  end.
END CASE .
END PROCEDURE .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE   for-cash-cycle:
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-plu as character no-undo .
define variable ss  as character no-undo .
define variable ss0  as character no-undo .
define variable v-temp-kat-file as character no-undo .
define variable v-kat-file as character no-undo .
define variable v-updated-subject-dis-kat as logical no-undo .
define variable v-kat-file-save as character no-undo .
define variable v-next as logical no-undo .
define variable v-cd-subject-code as character no-undo .
define variable v-cd-disc-string as character no-undo .
define buffer for-cash-desk for ub.cash-desk.
define buffer buf_cash-ncr-dis-kat for cash-ncr-dis-kat.
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  when 'NCR-AS@R':U then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  end.
  when 'MARIA':U then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
    v-record = fill( chr(63) + chr(4), 1).
  end.
END CASE.
    if p-what-send = 'all':U
    or p-what-send = 'tot-discnt':U then do:
      RUN putc-9 in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
      RUN putctodr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.
    if p-what-send = 'all':U
    or p-what-send = 'gds':U then do:
      RUN putcgddr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.
    if p-what-send = 'all':U
    or p-what-send = 'group':U then do:
      RUN putcgrdr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.
    if p-what-send = 'all':U
    or p-what-send = 'payment':U then do:
      RUN putcpmdr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.
    if p-what-send = 'all':U
    or p-what-send = 'client':U then do:
      RUN putccldr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                  then ('Ждите - ' + 'добавление скидки на итог и/или правил скидок')
                  else ('Ждите - ' + 'удаление скидки на итог и/или правил скидок') ) +
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                    then ('Ждите - ' + 'добавление скидки на итог и/или правил скидок')
                    else ('Ждите - ' + 'удаление скидки на итог и/или правил скидок') ) +
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
  when 'NCR-AS@R':U
  then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-kat-file-number as integer no-undo .
if action = 'D':U then do:
  do v-kat-file-number = 0 to 99:
    if v-kat-file-number > 0
    and v-kat-file-number < 10 then NEXt.
    assign                                                                                 v-temp-kat-file = out + fname + '.' + string(v-kat-file-number)                     v-kat-file = (if v-kat-file-number  > 0                                                          then (entry(1, out2, chr(4))   + 'group_':U  + string(v-kat-file-number))                   else (entry(2, out2, chr(4))   + 's_plurbt':U ))                               + '.dat':u                                                                v-updated-subject-dis-kat = no.                                                        if ncr-save-param <> 'no' then do:                                                       v-kat-file-save = if ncr-save-param = 'NCR'                                                              then replace(v-kat-file, '.dat', '.sav')                                                else search((if v-kat-file-number  > 0                                                          then ('group_':U  + string(v-kat-file-number))                                      else 's_plurbt':U) + '.sav':U).                         end.
    V-NEXT = NO.
    if search(v-kat-file) = ? then do:
      next .
    end.
    if ncr-save-param <> 'no':U then do:                                                     if search(v-kat-file-save) <> ? then do:                                               input stream bar from value(v-kat-file-save) convert source "ibm866" .                 repeat:                                                                                  import stream bar unformatted ss.                                                      find first cash-ncr-save-param where                                                            cash-ncr-save-param.dis-kat = v-kat-file-number                                 AND cash-ncr-save-param.cd-line = substring(ss, 1, 24) no-error.                  if not available cash-ncr-save-param then do:                                            create cash-ncr-save-param.                                                            assign                                                                                 cash-ncr-save-param.dis-kat = v-kat-file-number                                     cash-ncr-save-param.cd-line = substring(ss, 1, 24)                                     cash-ncr-save-param.cd-other = substring(ss, 25)                                       .                                                                                    end.                                                                                 end.                                                                                   input stream bar close .                                                               end.                                                                                   else do:                                                                               end.                                                                                 end.
    input stream bar from value(v-kat-file) convert source "ibm866" .
    output stream plucash to value(v-temp-kat-file) convert target "ibm866".
    _rr:
    repeat:
      import stream bar unformatted ss.
      if not ss begins 'SD'
      or can-find(first cash-ncr-save-param no-lock where
                       cash-ncr-save-param.dis-kat = v-kat-file-number
                   AND cash-ncr-save-param.cd-line = substring(ss, 1, 24))
      then do:
        put stream plucash unformatted
        ss skip.
        next _rr.
      end.
      find first buf_cash-ncr-dis-kat no-lock where
                buf_cash-ncr-dis-kat.dis-kat = - 1
            AND buf_cash-ncr-dis-kat.cd-subject-code = substring(ss, 1, 16) no-error.
      if not available buf_cash-ncr-dis-kat then do:
        put stream plucash unformatted
        ss skip.
      end.
      ELSE DO:
        ASSIGN
        V-NEXT = YES.
      END.
    end.
    input stream bar close.
    output stream plucash close.
    find first temp-dis-kat-file no-lock where                                                       temp-dis-kat-file.dis-kat = v-kat-file-number no-error.                   if not available temp-dis-kat-file then                                                create temp-dis-kat-file.                                                              assign                                                                                 temp-dis-kat-file.dis-kat   = v-kat-file-number                                     .                                                                                      assign                                                                                 temp-dis-kat-file.temp-file = v-temp-kat-file                                          temp-dis-kat-file.send-file = v-kat-file                                               temp-dis-kat-file.to-send   = yes.
  end.
end.
if action = 'U':U then do:
  FOR EACH cash-ncr-dis-kat No-LOCK WHERE
          cash-ncr-dis-kat.crf <= cr-ncr-dis-kat
  break
  by cash-ncr-dis-kat.dis-kat
  :
      if first-of(cash-ncr-dis-kat.dis-kat) then do:
      assign                                                                                 v-temp-kat-file = out + fname + '.' + string(cash-ncr-dis-kat.dis-kat)                     v-kat-file = (if cash-ncr-dis-kat.dis-kat  > 0                                                          then (entry(1, out2, chr(4))   + 'group_':U  + string(cash-ncr-dis-kat.dis-kat))                   else (entry(2, out2, chr(4))   + 's_plurbt':U ))                               + '.dat':u                                                                v-updated-subject-dis-kat = no.                                                        if ncr-save-param <> 'no' then do:                                                       v-kat-file-save = if ncr-save-param = 'NCR'                                                              then replace(v-kat-file, '.dat', '.sav')                                                else search((if cash-ncr-dis-kat.dis-kat  > 0                                                          then ('group_':U  + string(cash-ncr-dis-kat.dis-kat))                                      else 's_plurbt':U) + '.sav':U).                         end.
      if search(v-kat-file) = ? then do:
        output stream bar to value(v-kat-file) convert target "ibm866" .
        put stream bar unformatted skip.
        output stream bar close.
      end.
      else do:
       if ncr-save-param <> 'no':U then do:                                                     if search(v-kat-file-save) <> ? then do:                                               input stream bar from value(v-kat-file-save) convert source "ibm866" .                 repeat:                                                                                  import stream bar unformatted ss.                                                      find first cash-ncr-save-param where                                                            cash-ncr-save-param.dis-kat = cash-ncr-dis-kat.dis-kat                                 AND cash-ncr-save-param.cd-line = substring(ss, 1, 24) no-error.                  if not available cash-ncr-save-param then do:                                            create cash-ncr-save-param.                                                            assign                                                                                 cash-ncr-save-param.dis-kat = cash-ncr-dis-kat.dis-kat                                     cash-ncr-save-param.cd-line = substring(ss, 1, 24)                                     cash-ncr-save-param.cd-other = substring(ss, 25)                                       .                                                                                    end.                                                                                 end.                                                                                   input stream bar close .                                                               end.                                                                                   else do:                                                                               end.                                                                                 end.
      end.
      input stream bar from value(v-kat-file) convert source "ibm866" .
      assign
      ss0 = ''
      ss = '':U
      v-cd-subject-code = '':U
      v-cd-disc-string  = '':U
      v-next = no
      v-updated-subject-dis-kat = no
      .
      output stream plucash to value(v-temp-kat-file) convert target "ibm866".
      _rr2:
      repeat:
        import stream bar unformatted ss.
        assign
        v-next = no
        v-updated-subject-dis-kat = no
        v-cd-subject-code = substring(ss, 1, 16)
        v-cd-disc-string =  substring(ss, 17, 7)
        .
        if not ss begins 'SD'
        then do:
          if substring(ss0, 1, 3) = substring(v-cd-subject-code, 1, 3) then do:
            put stream plucash unformatted
            ss skip.
            ss0 = v-cd-subject-code.
            NEXT _rr2.
          end.
          v-next = yes.
        end.
        _for_rr2:
        for each  buf_cash-ncr-dis-kat no-lock where
                  buf_cash-ncr-dis-kat.dis-kat = cash-ncr-dis-kat.dis-kat
              AND buf_cash-ncr-dis-kat.cd-subject-code <= v-cd-subject-code
              AND buf_cash-ncr-dis-kat.cd-subject-code > ss0
              and crf <= cr-ncr-dis-kat
        by buf_cash-ncr-dis-kat.cd-subject-code
        by buf_cash-ncr-dis-kat.cd-disc-string
        descending
        :
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
          and SUBSTRING(buf_cash-ncr-dis-kat.cd-disc-string, 1,  7) < v-cd-disc-string then do:
            leave  _for_rr2.
          end.
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code then do:
            v-updated-subject-dis-kat = yes.
          end.
          find first  cash-ncr-save-param no-lock where
                          cash-ncr-save-param.dis-kat = cash-ncr-dis-kat.dis-kat
                      AND cash-ncr-save-param.cd-line = (buf_cash-ncr-dis-kat.cd-subject-code +
                                                        substring(buf_cash-ncr-dis-kat.cd-disc-string , 1, 2)) no-error.
          if available cash-ncr-save-param then do:
            put stream plucash unformatted
            cash-ncr-save-param.cd-line
            cash-ncr-save-param.cd-other
            skip.
            v-cd-disc-string = substring(cash-ncr-save-param.cd-line , 17, 7)
                               .
            NEXT _for_rr2.
          end.
          put stream plucash unformatted                                                                               buf_cash-ncr-dis-kat.cd-subject-code                                                                         buf_cash-ncr-dis-kat.cd-disc-string                                                                          buf_cash-ncr-dis-kat.cd-subject-name                                                                         buf_cash-ncr-dis-kat.cd-other                                                                                skip.
        end.
        if v-next then do:
          ss0 = v-cd-subject-code.
          put stream plucash unformatted
          ss skip.
          NEXT _rr2.
        end.
        if not v-updated-subject-dis-kat then do:
          find first buf_cash-ncr-dis-kat no-lock where
                    buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
                AND buf_cash-ncr-dis-kat.crf <= cr-ncr-dis-kat no-error.
          if not available buf_cash-ncr-dis-kat then do:
            put stream plucash unformatted
            ss skip.
          end.
        end.
        ss0 = v-cd-subject-code.
      end.
      input stream bar close.
      _for_rr3:
      for each  buf_cash-ncr-dis-kat no-lock where
                buf_cash-ncr-dis-kat.dis-kat = cash-ncr-dis-kat.dis-kat
            AND buf_cash-ncr-dis-kat.cd-subject-code >= v-cd-subject-code
            and crf <= cr-ncr-dis-kat
      by buf_cash-ncr-dis-kat.cd-subject-code
      by buf_cash-ncr-dis-kat.cd-disc-string
      descending
      :
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
          and SUBSTRING(buf_cash-ncr-dis-kat.cd-disc-string, 1, 7) >= v-cd-disc-string then do:
            next  _for_rr3.
          end.
        find first  cash-ncr-save-param no-lock where
                      cash-ncr-save-param.dis-kat = cash-ncr-dis-kat.dis-kat
                  AND cash-ncr-save-param.cd-line = (buf_cash-ncr-dis-kat.cd-subject-code +
                                                    substring(buf_cash-ncr-dis-kat.cd-disc-string , 1, 2)) no-error.
        if available cash-ncr-save-param then do:
          put stream plucash unformatted
          cash-ncr-save-param.cd-line
          cash-ncr-save-param.cd-other
          skip.
          v-cd-disc-string = substring(cash-ncr-save-param.cd-line , 17, 7) .
        end.
        else do:
          put stream plucash unformatted                                                                               buf_cash-ncr-dis-kat.cd-subject-code                                                                         buf_cash-ncr-dis-kat.cd-disc-string                                                                          buf_cash-ncr-dis-kat.cd-subject-name                                                                         buf_cash-ncr-dis-kat.cd-other                                                                                skip.
        end.
      end.
      output stream plucash close.
      find first temp-dis-kat-file no-lock where                                                       temp-dis-kat-file.dis-kat = cash-ncr-dis-kat.dis-kat no-error.                   if not available temp-dis-kat-file then                                                create temp-dis-kat-file.                                                              assign                                                                                 temp-dis-kat-file.dis-kat   = cash-ncr-dis-kat.dis-kat                                     .                                                                                      assign                                                                                 temp-dis-kat-file.temp-file = v-temp-kat-file                                          temp-dis-kat-file.send-file = v-kat-file                                               temp-dis-kat-file.to-send   = yes.
    end.
  END.
end.
  end.
  when 'MARIA':U then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found29 as logical no-undo .
define variable v-is-script29 as logical no-undo.
define variable v-fields-shift29 as integer no-undo .
   if true then do:
    v-fields-shift29 = 473.
if v-record <> '':U then
    run maria-put in this-procedure (
                                    buffer for-cash-desk
                                  , input out
                                  , input fname
                                  , input yes
                                  , input v-fields-shift29
                                  , input yes
                                  , input 24
                                  , input 1
                                  , input string(1)
                                  , input v-record
                                    ).
   end.
find first temp-tekka-tsk no-error.
if available temp-tekka-tsk then do:
   v-found29 = yes.
end.
if v-found29 = yes then do:
output stream IBmSTREAM to VALUE(out + fname + '.tsk').
v-is-script29 = no.
for each temp-tekka-tsk:
  if (temp-tekka-tsk.num-rec > 0
  or temp-tekka-tsk.send-get = 'task')
  and temp-tekka-tsk.task-num = fname then do:
    export stream IBmSTREAM temp-tekka-tsk.
    v-found29 = yes.
  end.
  if temp-tekka-tsk.is-script then do:
    v-is-script29 = yes.
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
                    ,input v-is-script29
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .
FOR EACH ub.cash-desk NO-LOCK WHERE
        ub.cash-desk.db-num = g#db-num AND
        ub.cash-desk.obj-code = i-obj-code AND
        ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dflt-cd31 as character no-undo .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type32 as character no-undo .
define variable v-value-date32 as date no-undo .
define variable v-value-decimal32 as decimal no-undo .
define variable v-value-integer32 as INTEGER no-undo .
define variable v-value-logical32 AS LOGICAL no-undo .
define variable v-tth32 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.cash-desk.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd31
    ,output v-value-date32
    ,output v-value-decimal32
    ,output v-value-integer32
    ,output v-value-logical32
    ,output v-param-type32
    ,INPUT-OUTPUT table-handle v-tth32
    ) no-error .
delete object v-tth32 no-error.
case ub.cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  end.
  when 'IBM':U
  then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  end.
  when 'NCR-AS@R':U then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if ub.cash-desk.pos-type = 'NCR-AS@R':U then do:
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U then 'cd-type-NCR-GM':U else 'cd-type-NCR-AS-R':U)
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U
                then 'save-param':U
                else 'save-param':U)
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
  IF not error-status:error then
  ncr-save-param = v-value-character.
  delete object v-tth.
end.
  end.
  when 'MARIA':U then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case ub.cash-desk.pos-type:
  when 'NCR-AS@R':U
  then do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  for each temp-dis-kat-file where
            temp-dis-kat-file.to-send = yes:
    OS-copy
    value(temp-dis-kat-file.temp-file)
    value(temp-dis-kat-file.send-file).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value(temp-dis-kat-file.temp-file).
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Данные по скидкам выгружены в файл &1"
                            , temp-dis-kat-file.send-file
                          )
                                          ).
  end.
def var v_found as log no-undo .
   assign
     v_found = no
     .
   for each ub.dis-gds-rule no-lock where ub.dis-gds-rule.pos-type = 'NCR-AS@R':U
                                      and  ub.dis-gds-rule.templ-rl-root = 91 :
     if ub.dis-gds-rule.obj-type = "" and ub.dis-gds-rule.obj-code = 0 then
     do:
        v_found = yes.
        leave.
     end.
     if ub.dis-gds-rule.obj-type = 'орг':U and ub.dis-gds-rule.obj-code = v-host-code then
     do:
        v_found = yes.
        leave.
     end.
     if ub.dis-gds-rule.obj-type = 'маг':U and ub.dis-gds-rule.obj-code = i-obj-code then
     do:
        v_found = yes.
        leave.
     end.
   end.
   if v_found = no then
   do:
    for each ub.dis-thbj-rule no-lock where ub.dis-thbj-rule.pos-type = 'NCR-AS@R':U :
     if (ub.dis-thbj-rule.templ-rl-root = 90 or
        ub.dis-thbj-rule.templ-rl-root = 92 ) and
        ub.dis-thbj-rule.obj-type = "" and
        ub.dis-thbj-rule.obj-code = 0 then
     do:
        v_found = yes.
        leave.
     end.
     if (ub.dis-thbj-rule.templ-rl-root = 90 or
        ub.dis-thbj-rule.templ-rl-root = 92 ) and
        ub.dis-thbj-rule.obj-type = 'орг':U and
        ub.dis-thbj-rule.obj-code = v-host-code then
     do:
        v_found = yes.
        leave.
     end.
     if (ub.dis-thbj-rule.templ-rl-root = 90 or
        ub.dis-thbj-rule.templ-rl-root = 92 ) and
        ub.dis-thbj-rule.obj-type = 'маг':U and
        ub.dis-thbj-rule.obj-code = i-obj-code then
     do:
        v_found = yes.
        leave.
     end.
    end.
   end.
   if v_found then
   do:
     def var ind as int no-undo .
     run output-ncr-bonus in this-procedure ( input v-host-code,
                                              input i-obj-code,
                                              input out,
                                              output fname) .
     _lock-bonus :
     DO while ind < 100 :
       run gbl/lock-prc.p (
         input 'pncr':U
        ,input i-obj-code
        ,input 0
        ,input 0
        ,input 'маг':U
        ,input "":U
        ,input "":U
        ,input ("Код объекта" + ",,,":U +
                "Тип объекта" +  ",,,":U + 'Передача скидки на итог и/или правил скидок')
        ,input no
        ,buffer lock-batchprocess
        ) no-error .
       if not error-status:error then do:
         leave _lock-bonus.
       end.
       run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Объект &1: Файл для выгрузки бонусов ЗАНЯТ - Ждите", i-obj-code
                        )
                                        ).
       pause 1.
     end.
    OS-append
    value( out + fname + '.dat':U )
    value( out + fname + ".pmt":U).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value( out + fname + '.dat':U ).
    end.
    if ub.cash-desk.pos-type = 'NCR-AS@R':U then do:
      output stream ibmstream to value( out +  "pmt.ctl":U).
      put unformatted skip.
      output stream ibmstream close.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Бонусы выгружены в файл &1"
                            ,( out + fname + ".pmt":U)
                          )
                                         ).
    if g#news
    or g#auto
    or g#esys
    then do:
      run str/waitpn.w (
                   input (out + fname + ".pmt":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление скидки на итог и/или правил скидок')
                            else ('Ждите - ' + 'удаление скидки на итог и/или правил скидок') )
                  ,input ' Подождите 15 сек '
                  ,input 15
                  ) no-error.
    end.
    else do:
      run str/waitp.w (
                   input (out + fname + ".pmt":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление скидки на итог и/или правил скидок')
                            else ('Ждите - ' + 'удаление скидки на итог и/или правил скидок') )
                  ,input ' Подождите 15 сек '
                  ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                  ,input 15
                  )
                  no-error.
    end.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Прерван обмен информацией с кассой, на кассе осталась устаревшая информация"
                              )
                                              ).
        os-delete value( out + fname + ".pmt":U).
        assign
        v-view-log = yes
        .
        return "error":U.
    end.
   end.
  end.
END CASE.
  END.
END.
END PROCEDURE.
do on error undo, throw:
assign
i-obj-code = integer(entry(1, p-parameter, chr(4)))
action = entry(2, p-parameter, chr(4))
p-what-send = entry(3, p-parameter, chr(4))
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         )).
  v-view-log = yes.
  undo, return error .
end .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  i-obj-code
  ,output v-host-code
  )  .
if not g#news
and not g#auto
then do:
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-discnt-total_add-def':U
    ,input  'object':U
    ,input  v-host-code
    ,input  'маг':U
    ,input  i-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if NOT glog then return .
end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type41 as character no-undo .
define variable v-value-date41 as date no-undo .
define variable v-value-decimal41 as decimal no-undo .
define variable v-value-integer41 as INTEGER no-undo .
define variable v-value-logical41 AS LOGICAL no-undo .
define variable v-tth41 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  i-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date41
    ,output v-value-decimal41
    ,output v-value-integer41
    ,output v-value-logical41
    ,output v-param-type41
    ,INPUT-OUTPUT table-handle v-tth41
    )  .
delete object v-tth41 no-error.
if p-what-send = 'ALL'
or p-what-send = 'tot-discnt' then do:
  run prepare-tot-discnt in this-procedure (
                                            output v-template-list-tot-discnt ) .
  if dflt-cd = 'IBM':U then do:
    if v-upper-rule-num-tot-discnt <> 0 then do:
      find first cash-dis-rule where
        cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt no-error.
      if available cash-dis-rule
      and cash-dis-rule.templ-rl-root = 53 then do:
        v-upper-rule-num-tot-discnt-kat = v-upper-rule-num-tot-discnt.
        v-upper-rule-num-tot-discnt = 0.
      end.
    end.
  end.
end.
if p-what-send = 'ALL'
or p-what-send = 'gds-discnt' then do:
  run prepare-gds-discnt in this-procedure ( output v-template-list-gds ) .
end.
if p-what-send = 'ALL'
or p-what-send = 'group-discnt' then do:
  run prepare-group-discnt in this-procedure ( output v-template-list-group ) .
end.
if p-what-send = 'ALL'
or p-what-send = 'payment-discnt' then do:
  run prepare-payment-discnt in this-procedure ( output v-template-list-payment) .
end.
if p-what-send = 'ALL'
or p-what-send = 'client-discnt' then do:
  run prepare-client-discnt in this-procedure ( output v-template-list-client ).
end.
if action = "D":U
or (v-upper-rule-num-tot-discnt <> 0
   and
   (p-what-send = 'all'
    or
    p-what-send = 'tot-discnt')
  )
or can-find(first cash-dis-rule)
then do:
  RUN SENDING in this-procedure no-error.
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибки при отсылке правил скидок на кассы  маг&1"
                          , i-obj-code
                          )
                                          ).
    assign
    v-view-log = yes
    .
    if g#news then return error .
  end.
end.
  finally :
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action43   as character no-undo .
  define variable v-printed43       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action43
    ,output v-printed43
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", chr(10))
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end finally .
end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure create-ncr-kat-discnt :
define input parameter p-subject-code as character no-undo .
define input parameter p-cd-subject-code as character no-undo .
define input parameter p-subject-name as character no-undo .
define input parameter p-dis-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define input parameter p-tree as character no-undo .
define input parameter p-discnt as decimal no-undo .
define variable v-dis-rule-num as integer no-undo .
define variable v-tree as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-dis-kat as integer   no-undo .
define buffer buf_cash-dis-rule for cash-dis-rule.
define buffer buf_cash-dis-time-rule for cash-dis-time-rule.
define buffer slave_cash-dis-rule for cash-dis-rule.
  do
  on error undo, return error
  :
    v-discnt = p-discnt.
    if p-dis-rule-num > 0 then do:
      find first buf_cash-dis-rule no-lock where
                buf_cash-dis-rule.rule-num = p-dis-rule-num no-error.
      if not available buf_cash-dis-rule
      or (buf_cash-dis-rule.templ-rl-root <> p-templ-rl-root
         and
         p-templ-rl-root <> ?)
      then do:
        return error .
      end.
      if p-templ-rl-root = ? then do:
        p-templ-rl-root = buf_cash-dis-rule.templ-rl-root.
      end.
      if buf_cash-dis-rule.uniq-field = ''
      or buf_cash-dis-rule.is-term
      then do:
        v-tree = no.
        v-dis-rule-num = buf_cash-dis-rule.upper-rule-num.
      end.
      if buf_cash-dis-rule.time-rule-num > 0 then do:
        find first buf_cash-dis-time-rule no-lock where
                buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.
        if not available buf_cash-dis-time-rule then do:
          return error .
        end.
        release buf_cash-dis-time-rule.
      end.
        _buf-cash-dis-rule:
        for each buf_cash-dis-rule no-lock where
                buf_cash-dis-rule.upper-rule-num = (if v-tree then p-dis-rule-num else v-dis-rule-num):
          if not v-tree then do:
            find first slave_cash-dis-rule no-lock where
                slave_cash-dis-rule.rule-num = v-dis-rule-num .
            assign v-dis-kat = slave_cash-dis-rule.dis-kat .
            if buf_cash-dis-rule.rule-num <> p-dis-rule-num then next _buf-cash-dis-rule.
          end.
          else
           do:
             assign v-dis-kat = buf_cash-dis-rule.dis-kat .
           end .
          if buf_cash-dis-rule.time-rule-num > 0 then do:
            find first buf_cash-dis-time-rule no-lock where
                      buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.
            if not available buf_cash-dis-time-rule then next _buf-cash-dis-rule.
          end.
          FIND FIRST cash-ncr-dis-kat where
                  cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
          if not avail cash-ncr-dis-kat then do:
            create cash-ncr-dis-kat.
            error-status:error = false.
          end.
          cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
          cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
          assign
          cash-ncr-dis-kat.subject-code  =  p-subject-code
          cash-ncr-dis-kat.cd-subject-code  =  p-cd-subject-code
          cash-ncr-dis-kat.cd-subject-name  =  SUBSTRING(p-subject-name, 1, 20)
          cash-ncr-dis-kat.cd-subject-name  =  SUBSTRING(p-subject-name, 1, 20) +
                                             ( if length(p-subject-name) < 20 then fill( chr(32) , 20 - length(p-subject-name) ) else '' )
          cash-ncr-dis-kat.dis-kat =  (if v-dis-kat < 0 then 0 else v-dis-kat)
          cash-ncr-dis-kat.rule-num = buf_cash-dis-rule.rule-num
          cash-ncr-dis-kat.time-rule-num = buf_cash-dis-rule.time-rule-num
          cash-ncr-dis-kat.cd-disc-string   = "****":U  +
                                          (if buf_cash-dis-rule.templ-rl-root = 89
                                           then '80'
                                           else (if buf_cash-dis-rule.discnt-value > 0
                                                 then '80':U
                                                 else '00':U)
                                           )
          .
          if p-tree = 'time-rule-num':U then do:
            if available buf_cash-dis-time-rule
            and buf_cash-dis-time-rule.value-type <> '0':U
            then do:
              assign
              cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string +
                                            (if buf_cash-dis-time-rule.value-type = '2':U
                                              then
                                              ("D":U + substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 9, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 4, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 1, 2) +
                                                      "-":U +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 9, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 4, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 1, 2)
                                              )
                                              else
                                              ("T00":U +
                                                        (if buf_cash-dis-time-rule.week-day-0  then "0" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-1  then "2" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-2  then "3" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-3  then "4" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-4  then "5" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-5  then "6" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-6  then "7" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-7  then "1" else "":U) +
                                                      chr(47) +
                                                      replace(string(buf_cash-dis-time-rule.time-from, "HH:MM"), ':':U, '':U) + "-":U +
                                                      replace(string(buf_cash-dis-time-rule.time-to, "HH:MM"), ':':U, '':U)
                                              )
                                            )
              .
            end.
            else do:
              assign
              cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string + "D000101-991231":U
              .
            end.
          end.
          if p-tree = 'tot-sum':U then do:
            assign
            cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string +
            '>' + replace(string(round(buf_cash-dis-rule.tot-sum, 2), '99999999999.99'), '.':u , '':U)
            .
          end.
          assign
          cash-ncr-dis-kat.cd-other =   fill(chr(32), 10) +  "xx ":U +
                                        (if buf_cash-dis-rule.value-type = integer('12':U)
                                         or buf_cash-dis-rule.value-type = integer('3':U)
                                        then "=":U
                                        else "%":U) +
                                        replace(string(abs(if v-discnt <> ? then v-discnt else buf_cash-dis-rule.discnt-value),"9999999.9"), '.':U, '':U)
          .
        end.
    end.
    else do:
      FIND FIRST cash-ncr-dis-kat where
              cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
      if not avail cash-ncr-dis-kat then do:
      create cash-ncr-dis-kat.
      error-status:error = false.
      end.
      cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
      cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
      assign
      cash-ncr-dis-kat.subject-code  = p-subject-code
      cash-ncr-dis-kat.cd-subject-code  = p-cd-subject-code
      cash-ncr-dis-kat.cd-subject-name  = p-subject-name
      cash-ncr-dis-kat.dis-kat =  - 1
      cash-ncr-dis-kat.rule-num = 0
      cash-ncr-dis-kat.time-rule-num = 0
      .
    end.
  end.
end procedure.
procedure output-ncr-bonus:
define input parameter i-host-code as integer no-undo .
define input parameter i-obj-code  as integer no-undo .
define input parameter out         as character no-undo .
define output parameter fname      as character no-undo .
def var v-found as log no-undo .
def var v-upd   as char no-undo .
def var v-ver   as char no-undo .
def var v-char-delim-1  as char initial ',' no-undo .
def var v-char-delim-2  as char initial ';' no-undo .
def var v-char-1        as char no-undo .
def var v-char-2        as char no-undo .
def var v-char-21       as char no-undo .
def var v-char-3        as char no-undo .
def var v-char-4        as char no-undo .
def var v-char-41       as char no-undo .
def var v-char-42       as char no-undo .
def var v-char-5        as char no-undo .
def var v-char-6        as char no-undo .
def var v-char-61       as char no-undo .
def var v-char-62       as char no-undo .
def var v-char-8        as char no-undo .
def var v-char-9        as char no-undo .
def var v-char-7        as char no-undo .
def var v-char-71       as char no-undo .
def var v-char-72       as char no-undo .
def var v-cassa         as char no-undo .
def var v-is-weight     as log  no-undo init false .
def var v-ean13         as char no-undo .
def var v-tmpchar       as char no-undo .
def var v-today         as date no-undo .
def buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr.
def buffer buf_dis-gds-rule      for ub.dis-gds-rule .
def buffer chk_dis-gds-rule      for ub.dis-gds-rule .
def buffer buf_dis-thbj-rule     for ub.dis-thbj-rule .
def buffer buf_dis-rule          for ub.dis-rule .
def buffer buf_dis-time-rule     for ub.dis-time-rule .
def buffer buf_prod-bc           for ub.prod-bc .
def buffer buf_bar-code          for ub.bar-code .
def buffer buf_units             for ub.units .
def buffer buf_goods             for ub.goods .
def buffer buf_gds-obj           for ub.gds-obj .
assign
    fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
assign
 v-ver = "2.02.00"
 v-char-1 = "0,0,0,,,,,0,1,0,0,1,;,0,0,1,0,0,"
 v-char-2 = "0,0,0,0,0,0,"
 v-char-21 = "0,0,0,"
 v-char-3 = "0,0,0,"
 v-char-4 =
 ",;,,;,;,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
 v-char-41 =
 ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
 v-char-42 =
 ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,1,0,21,0,0,"
 v-char-5 =
 "0,0,1,1,0,4,1,"
 v-char-6 =
 ",;,;,;,;,;,0;+                                       ;"
 v-char-61 =
 ",;,;,;,;,;,1;+                                       ;"
 v-char-62 =
 ",;,;,;,;,;,1;Message                                 ;"
 v-char-7 =
 "006;00;000;               ;          ;,0,0"
 v-char-71 =
 "006;04;000;               ;          ;,0,0"
 v-char-72 =
 "021;00;000;               ;          ;Выдать марок$FinalPointsBalance$ шт.,0,0,4,0,1,0,1,0,22,0,0,0,0,0,1,1,0,4,1,"
 v-char-8 =
 ";,;,;,;,;,;,1;" + fill(" ",40) + ";022;06;000;"
 v-char-9 =
 "               ;          ;________________________MAPOK=$FinalPointsBalance$,0,0"
.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  'маг':U
  ,input  i-obj-code
  ,output v-today
  )  .
 output stream IBMStream to value(out + fname + ".dat") convert target "utf-8"  .
 _buf_dis-gds-rule:
 for each buf_dis-gds-rule no-lock
 where buf_dis-gds-rule.templ-rl-root = 91
   and buf_dis-gds-rule.pos-type = 'NCR-AS@R':U
   ,
   first buf_dis-rule no-lock
   where buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num
     and buf_dis-rule.sts = integer('0':U),
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
    and buf_dis-time-rule.date-to >= v-today
      :
       if buf_dis-gds-rule.obj-type = "" and buf_dis-gds-rule.obj-code = 0 then do:
           find first chk_dis-gds-rule no-lock
           where chk_dis-gds-rule.gds-code = buf_dis-gds-rule.gds-code and
                 chk_dis-gds-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root and
                 chk_dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type and
              (( chk_dis-gds-rule.obj-type = 'орг':U  and chk_dis-gds-rule.obj-code = i-host-code ) or
               ( chk_dis-gds-rule.obj-type = 'маг':U and chk_dis-gds-rule.obj-code = i-obj-code  )) no-error .
           if avail chk_dis-gds-rule then next _buf_dis-gds-rule .
       end.
       if buf_dis-gds-rule.obj-type = 'орг':U and buf_dis-gds-rule.obj-code = i-host-code then do:
           find first chk_dis-gds-rule no-lock
           where chk_dis-gds-rule.gds-code = buf_dis-gds-rule.gds-code and
                 chk_dis-gds-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root and
                 chk_dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type and
                 chk_dis-gds-rule.obj-type = 'маг':U and
                 chk_dis-gds-rule.obj-code = i-obj-code no-error .
           if avail chk_dis-gds-rule then next _buf_dis-gds-rule .
       end.
       find first buf_gds-obj no-lock
       where buf_gds-obj.gds-code = buf_dis-gds-rule.gds-code
         and buf_gds-obj.obj-type = 'маг':U
         and buf_gds-obj.obj-code = i-obj-code
       no-error.
       if avail buf_gds-obj and
         (( buf_dis-gds-rule.obj-type = ""      and buf_dis-gds-rule.obj-code = 0) or
          ( buf_dis-gds-rule.obj-type = 'орг':U  and buf_dis-gds-rule.obj-code = i-host-code) or
          ( buf_dis-gds-rule.obj-type = 'маг':U and buf_dis-gds-rule.obj-code = i-obj-code))
       then do:
          assign
            v-char-2 = "0,0,0,0,0,0,"
            v-is-weight = false
          .
          find buf_goods where buf_goods.gds-code = buf_dis-gds-rule.gds-code no-lock no-error.
          if avail buf_goods then do:
              find buf_units where buf_units.unit-name = buf_goods.unit-base no-lock no-error.
              if avail buf_units then do:
                  if lookup ('вес':U, buf_units.type) > 0 then do:
                      assign
                        v-char-2    = "0,0,0,2,0,0,"
                        v-is-weight = true
                      .
                  end.
              end.
          end.
          _bdr-attr:
    for each  buf_dis-gds-rule-attr WHERE
             buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
         AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
         AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
         AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
         AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
         and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                  :
           assign
     v-upd = entry(2,buf_dis-gds-rule-attr.attr-value,",")
             v-ean13 = entry(1,buf_dis-gds-rule-attr.attr-value,",")
     .
           if v-is-weight and length(v-ean13) = 5 then do:
               def var ncrsc-pfx as char no-undo init "23":U .
               def var ncrsc-frmt as char no-undo init "EAN13" .
               assign v-tmpchar = "" .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str46  as character no-undo.
  define variable tmp-num46  as character no-undo.
  define variable i46        as integer   no-undo.
  define variable sum46      as integer   no-undo.
  define variable len-code46 as integer   no-undo.
  define variable varcont46  as logical   initial yes no-undo.
  CASE ncrsc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str46 = string( decimal(string(integer( v-ean13 ), '99999':U) + '00000':U), "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str46 = string( decimal(string(integer( v-ean13 ), '99999':U) + '00000':U), "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " ncrsc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont46 = yes then do:
    if integer( substring( tmp-str46, 1, length( ncrsc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U)
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        v-tmpchar = ncrsc-pfx + substring( tmp-str46, length( ncrsc-pfx ) + 1, length( tmp-str46 ) - length( ncrsc-pfx ) )
        len-code46    = length( v-tmpchar )
      .
      define variable v-sum-char46 as character no-undo .
      assign
        sum46 = 0
      .
      do i46 = 1 to len-code46 by 2
      :
        assign
          v-sum-char46 = substr(v-tmpchar, len-code46 - i46 + 1, 1)
        .
        if v-sum-char46 < "0"
        or v-sum-char46 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U) skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum46 = sum46 + integer(v-sum-char46)
        .
      end.
      if varcont46 = yes then do:
        assign
          sum46 = sum46 * 3
        .
        do i46 = 2 to len-code46 by 2
        :
          assign
            v-sum-char46 = substr(v-tmpchar, len-code46 - i46 + 1, 1)
          .
          if v-sum-char46 < "0"
          or v-sum-char46 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U) skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum46 = sum46 + integer(v-sum-char46)
          .
        end.
        if varcont46 = yes then do:
           if sum46 mod 10 = 0 then do:
             assign
               v-tmpchar = v-tmpchar + '0'
             .
           end.
           else do:
             assign
               v-tmpchar = v-tmpchar + string(10 - sum46 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
               if not v-tmpchar = "":U then assign v-ean13 = v-tmpchar .
           end.
           if v-ean13 begins "20" and length(v-ean13) = 13 then next _bdr-attr .
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-gds-rule-attr.attr-code v-char-delim-1
      "3,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-2
      trim(string(buf_dis-rule.doc-qnty,'>>>>9')) v-char-delim-1
      v-char-3
            v-ean13 v-char-delim-2
      v-char-4
      trim(string(buf_dis-rule.discnt-value,">>>9")) v-char-delim-1
      v-char-5
            v-ean13 v-char-delim-2
      v-char-6 v-char-7 skip.
    end.
   end.
 end.
 for each buf_dis-thbj-rule no-lock where buf_dis-thbj-rule.templ-rl-root = 90
                   and buf_dis-thbj-rule.pos-type = 'NCR-AS@R':U,
    first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
    and buf_dis-rule.sts = integer('0':U),
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
        and buf_dis-time-rule.date-to >= v-today
      :
   if (buf_dis-thbj-rule.obj-type = "" and
       buf_dis-thbj-rule.obj-code = 0) or
      (buf_dis-thbj-rule.obj-type = 'орг':U and
       buf_dis-thbj-rule.obj-code = i-host-code) or
      (buf_dis-thbj-rule.obj-type = 'маг':U and
       buf_dis-thbj-rule.obj-code = i-obj-code)
   then
   do:
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-rule.key#_one v-char-delim-1
      "3,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-21
      "9,0,0,"
      trim(string(buf_dis-rule.tot-sum * 100,">>>>>>>>>9")) v-char-delim-1
      v-char-3
      v-char-41
      trim(string(buf_dis-rule.discnt-value,">>>9")) v-char-delim-1
      v-char-5
       v-char-delim-2
      v-char-61 v-char-71 skip.
   end.
 end.
 for each buf_dis-thbj-rule no-lock where buf_dis-thbj-rule.templ-rl-root = 92
                   and buf_dis-thbj-rule.pos-type = 'NCR-AS@R':U,
    first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
    and buf_dis-rule.sts = integer('0':U),
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
        and buf_dis-time-rule.date-to >= v-today
      :
   if (buf_dis-thbj-rule.obj-type = "" and
       buf_dis-thbj-rule.obj-code = 0) or
      (buf_dis-thbj-rule.obj-type = 'орг':U and
       buf_dis-thbj-rule.obj-code = i-host-code) or
      (buf_dis-thbj-rule.obj-type = 'маг':U and
       buf_dis-thbj-rule.obj-code = i-obj-code)
   then
   do:
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-rule.key#_one v-char-delim-1
      "4,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-21
      "4,1,0,"
      "1" v-char-delim-1
      v-char-3
      v-char-42
      "0" v-char-delim-1
      v-char-5
       v-char-delim-2
      v-char-62 v-char-72 v-char-8 v-char-9 skip.
   end.
 end.
 output stream IBMStream close .
end procedure .
procedure prepare-tot-discnt :
define output parameter p-template-list-tot-discnt as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error
  :
    for each buf_dis-cfg-rule no-lock where
            buf_Dis-cfg-rule.table-name = 'dis-thbj-rule':U
       and buf_Dis-cfg-rule.pos-type = dflt-cd
       and buf_dis-cfg-rule.discnt-role = 'pcnt-tot-kateg':U:
      if buf_dis-cfg-rule.link-prop  = integer('0':U)
      and lookup(string(buf_Dis-cfg-rule.templ-rl-root), p-template-list-tot-discnt) = 0
      then do:
        assign
        p-template-list-tot-discnt = p-template-list-tot-discnt +
                                    (if p-template-list-tot-discnt = '':U
                                    then '':U
                                    else chr(44)) +
                                    string(buf_Dis-cfg-rule.templ-rl-root).
      end.
    end.
    if p-template-list-tot-discnt = '':U then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Для маг&1 тип кассы по умолчанию &2 - скидки на итог чека не отправляются"
                            , i-obj-code
                            , dflt-cd
                            )
                                          ).
      return.
    end.
    run create-dis-rule-by-template in this-procedure ( input 'pcnt-tot-kateg':U
                                                       ,input p-template-list-tot-discnt
                                                       ,input "на итог чека" ) .
  end.
end procedure.
procedure prepare-gds-discnt :
define output parameter p-template-list-gds as character no-undo .
  do
  on error undo, return error
  :
    CASE dflt-cd:
      when 'MARIA':U then do:
        assign
        p-template-list-gds = string(1) + chr(44) +
                          string(2) + chr(44) +
                          string(38) + chr(44) +
                          string(39).
      end.
      when 'NCR-GM':U
      or
      when 'NCR-AS@R':U
      then do:
        assign
        p-template-list-gds = string(26) + chr(44) +
                          string(33)
        .
      end.
      otherwise do:
        if p-what-send <> 'ALL' then
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Для маг&1 тип кассы по умолчанию &2 - правила скидок на товар не отправляются"
                                , i-obj-code
                                , dflt-cd
                                )
                                              ).
        return.
      end.
    END CASE.
    run create-dis-rule-by-template in this-procedure ( input 'dis-gds-rule':U
                                                       ,input p-template-list-gds
                                                       ,input "на товар" ) .
  end.
end procedure.
procedure prepare-group-discnt :
define output parameter p-template-list-group as character no-undo .
  do
  on error undo, return error
  :
    CASE dflt-cd:
      when 'MARIA':U then do:
        assign
        p-template-list-group = string(46) + chr(44) +
                          string(47) + chr(44) +
                          string(48) + chr(44) +
                          string(49).
      end.
      otherwise do:
        if p-what-send <> 'ALL' then
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Для маг&1 тип кассы по умолчанию &2 - правила скидок на группы товара не отправляются"
                                , i-obj-code
                                , dflt-cd
                                )
                                              ).
        return.
      end.
    END CASE.
    run create-dis-rule-by-template in this-procedure ( input 'group':U
                                                       ,input p-template-list-group
                                                       ,input "на группу товара" ) .
  end.
end procedure.
procedure prepare-payment-discnt :
define output parameter p-template-list-payment as character no-undo .
  do
  on error undo, return error
  :
    CASE dflt-cd:
      when 'MARIA':U then do:
        assign
        p-template-list-payment = string(42) + chr(44) +
                          string(43) + chr(44) +
                          string(44) + chr(44) +
                          string(45).
      end.
      otherwise do:
        if p-what-send <> 'ALL' then
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Для маг&1 тип кассы по умолчанию &2 - правила скидок на платеж не отправляются"
                                , i-obj-code
                                , dflt-cd
                                )
                                              ).
        return.
      end.
    END CASE.
    run create-dis-rule-by-template in this-procedure ( input 'payment':U
                                                       ,input p-template-list-payment
                                                       ,input "на платеж") .
  end.
end procedure.
procedure prepare-client-discnt :
define output parameter p-template-list-client as character no-undo .
  do
  on error undo, return error
  :
    CASE dflt-cd:
      when 'MARIA':U then do:
        assign
        p-template-list-client = string(11) + chr(44) +
                          string(12) + chr(44) +
                          string(40) + chr(44) +
                          string(41)
                          .
      end.
      otherwise do:
        if p-what-send <> 'ALL' then
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Для маг&1 тип кассы по умолчанию &2 - правила скидок для пост. клиентов не отправляются"
                                , i-obj-code
                                , dflt-cd
                                )
                                              ).
      end.
    END CASE.
    run create-dis-rule-by-template in this-procedure ( input 'client'
                                                      , input p-template-list-client
                                                      , input "для пост. клиентов" ) .
  end.
end procedure.
procedure create-dis-rule-by-template :
define input parameter p-what-create as character no-undo .
define input parameter p-template-list as character no-undo .
define input parameter p-discnt-des as character no-undo .
define variable v-ii as integer no-undo .
define variable ll as integer no-undo .
define variable vc-obj-type like ub.clients.obj-type no-undo .
define variable vc-obj-code like ub.clients.obj-code no-undo .
define variable vc-host-code like ub.sysconf.host-code no-undo .
define variable vc-region as character no-undo .
define variable v-des     as character no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display    as logical   no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other             as character no-undo .
define variable  v-not-found         as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
define buffer buf_cash-dis-rule for cash-dis-rule.
  do
  on error undo, return error return-value
  :
    if p-template-list = '':U then return.
    _v-ii:
    do v-ii = 1 to num-entries(p-template-list):
      run dr-code  in this-procedure (
                                          input  integer(entry(v-ii, p-template-list))
                                          ,output v-des
                                          ,output v-discnt-type
                                          ,output v-subject-type
                                          ,output v-value-type
                                          ,output v-level-1
                                          ,output v-level-2
                                          ,output v-global
                                          ,output v-host
                                          ,output v-object
                                          ,output v-output-display
                                          ,output v-tree
                                          ,output v-other).
      _ll:
      do ll = 1 to 3:
        CASE ll:
          when 1 then do:
            if v-object = 0 then next _ll.
            assign
            vc-obj-code = i-obj-code
            vc-obj-type = 'маг':U
            vc-host-code = v-host-code
            vc-region    = substitute("&1&2", vc-obj-type, vc-obj-code)
            .
          end.
          when 2 then do:
            if v-host = 0 then next _ll.
            assign
            vc-obj-code = 0
            vc-obj-type = '':U
            vc-host-code = v-host-code
            vc-region    = substitute("Фирма &1&2", vc-host-code)
            .
          end.
          when 3 then do:
            if v-global = 0 then next _ll.
            assign
            vc-obj-code = 0
            vc-obj-type = '':U
            vc-host-code = 0
            vc-region    = "Глобально"
            .
          end.
        END CASE.
        if p-what-create = 'pcnt-tot-kateg':U
        then do:
          _buf_dis-rule:
          for each buf_dis-rule no-lock where
                        buf_dis-rule.upper-rule-num = integer(entry(v-ii, p-template-list))
                    and buf_dis-rule.host-code = vc-host-code
                    AND buf_dis-rule.obj-type = vc-obj-type
                    AND buf_dis-rule.obj-code = vc-obj-code
                    AND buf_dis-rule.sts = integer('0':U),
          first buf_dis-thbj-rule no-lock where
                buf_dis-thbj-rule.host-code = vc-host-code
            and buf_dis-thbj-rule.obj-type = vc-obj-type
            and buf_dis-thbj-rule.obj-code = vc-obj-code
            and buf_dis-thbj-rule.pos-type = dflt-cd
            and buf_dis-thbj-rule.discnt-role = 'pcnt-tot-kateg':U
            and buf_dis-thbj-rule.rule-num = buf_dis-rule.rule-num
          :
            find first buf_cash-dis-rule no-lock where ll > 1
              and buf_cash-dis-rule.dis-kat            = buf_dis-rule.dis-kat
              and buf_cash-dis-rule.templ-rl-root      = buf_dis-rule.templ-rl-root
              and buf_cash-dis-rule.time-templ-rl-root = buf_dis-rule.time-templ-rl-root no-error .
            if avail buf_cash-dis-rule then next _buf_dis-rule .
            run create-dis-rule in this-procedure ( buf_dis-rule.rule-num, yes) no-error .
            if p-what-create = 'pcnt-tot-kateg':U then do:
              if lookup("dis-kat", v-level-1) = 0 then do:
                if v-upper-rule-num-tot-discnt = 0 then
                assign
                v-upper-rule-num-tot-discnt = buf_dis-rule.rule-num
                .
              end.
              else do:
                if v-upper-rule-num-tot-discnt-kat = 0 then
                assign
                v-upper-rule-num-tot-discnt-kat = (if buf_Dis-rule.is-term = yes
                                                   then buf_dis-rule.upper-rule-num
                                                   else buf_dis-rule.rule-num)
                .
              end.
            end.
          end.
          if action = "U" then do:
            if (ll = 1 and v-host = 0 and v-global = 0)
            or (ll = 2 and v-object = 0 and v-global = 0)
            or (ll = 3 and v-object = 0 and v-host = 0) then do:
              assign
              v-not-found = v-not-found + 1.
            end.
          end.
        end.
        else do:
          for each buf_dis-rule no-lock where
                  buf_dis-rule.templ-rl-root = integer(entry(v-ii, p-template-list))
            and  buf_dis-rule.host-code = vc-host-code
            and  buf_dis-rule.obj-type = vc-obj-type
            and  buf_dis-rule.obj-code = vc-obj-code:
            if action = 'U':U and buf_dis-rule.sts <> integer('0':U) then next.
            run create-dis-rule in this-procedure ( buf_dis-rule.rule-num, yes) no-error .
            if p-what-create = 'tot-discnt' then do:
              if lookup("dis-kat", v-level-1) = 0 then do:
                if v-upper-rule-num-tot-discnt = 0 then
                assign
                v-upper-rule-num-tot-discnt = buf_dis-rule.rule-num
                .
              end.
              else do:
                if v-upper-rule-num-tot-discnt-kat = 0 then
                assign
                v-upper-rule-num-tot-discnt-kat = buf_dis-rule.upper-rule-num
                .
              end.
            end.
          end.
          if not can-find(first cash-dis-rule where cash-dis-rule.upper-rule-num = integer(entry(v-ii, p-template-list)) ) then do:
            if (ll = 1 and v-host = 0 and v-global = 0)
            or (ll = 2 and v-object = 0 and v-global = 0)
            or (ll = 3 and v-object = 0 and v-host = 0) then do:
              assign
              v-not-found = v-not-found + 1.
            end.
          end.
          else do:
            LEAVE _ll.
          end.
        end.
      end.
    end.
    if v-not-found = num-entries(p-template-list) then do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute("Для маг&1 не определены скидки &2"
                                    , i-obj-code
                                    , p-discnt-des
                                    )
                                                  ).
    end.
  end.
end procedure.
procedure putc-dr-maria :
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-template-list as character no-undo .
define variable v-ii  as  integer     no-undo.
define variable v-maria-rule-num as integer no-undo .
define variable v-dop as character no-undo .
define variable v-string as character no-undo .
define variable v-maria-rule-type as integer no-undo .
define variable v-bush as integer no-undo .
define buffer down_cash-dis-rule for cash-dis-rule.
  do
  on error undo, return error:
    do v-ii = 1 to num-entries(p-template-list):
      for each cash-dis-rule where
              cash-dis-rule.templ-rl-root = integer(entry( v-ii, p-template-list))
        and  cash-dis-rule.upper-rule-num = integer(entry( v-ii, p-template-list)):
        v-bush = 0.
        if index(dr-list, string(cash-dis-rule.rule-num) + '-') = 0 then do:
          next.
        end.
        assign
        v-dop = substring(dr-list, index(dr-list, string(cash-dis-rule.rule-num) + '-':U))
        v-dop = substring(v-dop, 1, index(v-dop, chr(44)) - 1)
        v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
        .
        if action = 'D':U  then do:
          assign
          v-string  = fill( chr(32) , 12) + chr(4) +
                      '0' + chr(4) +
                      '000' + chr(4) +
                      '00000' + chr(4) +
                      fill(fill('0', 9) + chr(4) + fill('0', 5) + chr(4) , 5) +
                      fill(fill('0', 9) + chr(4) + fill('0', 5) + chr(4) , 5)
         .
        end.
        else do:
          if cash-dis-rule.value-type = integer('1':U) then do:
            if index(cash-dis-rule.uniq-field, 'tot-sum') = 0
            and index(cash-dis-rule.uniq-field, 'doc-qnty') = 0 then do:
              assign
              v-maria-rule-type = 0.
            end.
            if index(cash-dis-rule.uniq-field, 'tot-sum') > 0
            then do:
              assign
              v-maria-rule-type = 1.
            end.
            if index(cash-dis-rule.uniq-field, 'doc-qnty') > 0
            then do:
              assign
              v-maria-rule-type = 2.
            end.
          end.
          if cash-dis-rule.value-type = integer('2':U) then do:
            assign
            v-maria-rule-type = 3.
          end.
          assign
          v-string =  string(cash-dis-rule.des, "X(12)") + chr(4) +
                      string(v-maria-rule-type, '999') + chr(4) +
                      (if v-maria-rule-type = 3
                      then string( cash-dis-rule.discnt-value * 100, '999')
                      else '000') + chr(4) +
                      (if v-maria-rule-type = 0
                      then string( cash-dis-rule.discnt-value * 100, '99999')
                      else '00000') + chr(4).
          if v-maria-rule-type = 0
          or v-maria-rule-type = 3 then do:
            assign
            v-string = v-string +
                        fill(fill('0', 9) + chr(4) + fill('0', 5) + chr(4) , 5) +
                        fill(fill('0', 9) + chr(4) + fill('0', 5) + chr(4) , 5)
            .
          end.
          else do:
            if v-maria-rule-type = 2 then do:
              v-string = v-string + fill(fill('0', 9) + chr(4) + fill('0', 5) + chr(4) , 5).
            end.
            for each down_cash-dis-rule where
                  down_cash-dis-rule.upper-rule-num = cash-dis-rule.rule-num:
              assign
              v-bush = v-bush + 1.
              if v-maria-rule-type = 1 then do:
                assign
                v-string = v-string + string(down_cash-dis-rule.tot-sum * 100, '999999999') + chr(4) +
                                      string(down_cash-dis-rule.discnt-value * 100, '99999') + chr(4).
              end.
              if v-maria-rule-type = 2 then do:
                assign
                v-string = v-string + string(down_cash-dis-rule.doc-qnty * 100, '999999999') + chr(4) +
                                      string(down_cash-dis-rule.discnt-value * 100, '99999') + chr(4).
              end.
            end.
            if v-bush  < 5 then do:
               v-string = v-string + fill(fill('0', 9) + chr(4) + fill('0', 5) + chr(4) , 5 - v-bush).
            end.
            if v-maria-rule-type = 1 then do:
              v-string = v-string + fill(fill('0', 9) + chr(4) + fill('0', 5) + chr(4) , 5).
            end.
          end.
        end.
        assign
        v-string = right-trim(v-string, chr(4)).
        run maria-put in this-procedure (
                                        buffer buf_cash-desk
                                      , input out
                                      , input fname
                                      , input yes
                                      , input 0
                                      , input no
                                      , input 25
                                      , input 20
                                      , input v-maria-rule-num + 1
                                      , input v-string ).
      end.
    end.
  end.
end procedure.
