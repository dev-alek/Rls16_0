block-level on error undo, throw.
define input parameter parparentproc        as widget-handle no-undo .
define input parameter p-format-type        as character no-undo.
define input parameter p-export-type        as character no-undo.
define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$date: 14.08.03 11:06 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge.p $":U .
define variable vss-description as character no-undo init "Экспорт XML".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-bge-isbgeold          as logical      no-undo.
define variable v-bge-host-code         as integer      no-undo.
define variable v-bge-editor-handle     as handle       no-undo.
define variable v-bge-fillin-handle     as handle       no-undo.
define variable v-bge-shift-mode        as logical      no-undo.
define variable v-bge-format-dbf        as logical      no-undo.
define variable v-host-code             as integer      no-undo.
define variable v-pay-type-list         as character    no-undo.
def var go-ahead as logical no-undo.
define BUTton Btn_OK AUto-end-KEY
     LABEL "OK"
     SIZE 10 BY 1.13
     BGCOLor 8 .
define variable EDT-LOG as character
     view-as EDItor SCROLLBAR-VERTICAL no-WorD-WRAP LARGE
     SIZE 82.88 BY 15.67 no-undo.
define variable DLG-COUNTER as character format "X(65)":U
     view-as text
     SIZE 65.00 BY 1.17
     FGCOLor 9  no-undo.
define frame DLG-LOG
     DLG-COUNTER at ROW 1.04 COL 11.00 colon-aligned no-label
     Btn_OK at ROW 1.08 COL 1.75
     EDT-LOG at ROW 2.38 COL 1.5 no-label
     space(0.36) skip(0.15)
    with view-as DIALOG-BOX KEEP-TAB-orDER
         SIDE-LABELS no-UNDERLinE THREE-D  SCROLLABLE
         TITLE "Экспорт XML"
         defAULT-BUTton Btn_OK.
assign
       frame DLG-LOG:SCROLLABLE       = false
       frame DLG-LOG:HIDDEN           = true.
assign
       EDT-LOG:READ-onLY in frame DLG-LOG        = true
.
on WindoW-close OF frame DLG-LOG
do:
  APPLY "end-error":U to SELF.
end.
if VALID-handle(ACTIVE-WindoW) and frame DLG-LOG:PARENT eq ?
then frame DLG-LOG:PARENT = ACTIVE-WindoW.
MAin-BLOCK:
do on error   undo MAin-BLOCK, leave MAin-BLOCK
   on end-key undo MAin-BLOCK, leave MAin-BLOCK:
define variable v-par-value     as character      no-undo.
define variable v-par-type      as character      no-undo.
define variable v-param-type      as character  no-undo .
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-tth             as handle     no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
    v-bge-isbgeold  = ( p-format-type = "tree":U )
    v-bge-host-code = v-cntxt-host-code-obj
.
run bgelib-read-config in this-procedure .
assign
    v-bge-editor-handle = EDT-LOG :handle
in frame DLG-LOG.
assign
    v-bge-fillin-handle = DLG-COUNTER :handle
in frame DLG-LOG.
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
      v-bge-shift-mode = no
  .
end.
else do:
  assign
      v-bge-shift-mode = ( v-value-character = "distinct":U )
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
      v-bge-format-dbf = no
  .
end.
else do:
  assign
      v-bge-format-dbf = ( v-value-character = "dbf":U )
  .
end.
delete object v-tth.
case p-export-type:
    when 'ALL-DOC-REF'
    then do:
    end.
    when 'ALL-DAY-WAY'
    then do:
    end.
    when 'DOC'
    then do:
    end.
    when 'SHIFT'
    then do:
    end.
    when 'FINDOC'
    then do:
    end.
    when 'FIN-OB'
    then do:
    end.
    when 'CONTRACT'
    then do:
    end.
    when 'SCHET-FACTUR'
    then do:
    end.
    when 'STK'
    then do:
    end.
    when 'STD'
    then do:
    end.
    when 'STT'
    then do:
    end.
    when 'PRC'
    then do:
    end.
    when 'DAY'
    then do:
    end.
    when 'WAY'
    then do:
                message       "Экспортировать данные по товарам в пути? Операция может занять много времени"     view-as alert-box question     buttons yes-no     title "Экспорт XML"     update go-ahead.
        if go-ahead = no
        then do:
            undo, return no-apply.
        end.
    end.
    when 'KASS'
    then do:
    end.
    when 'REF'
    then do:
                message       "Экспортировать справочники? Операция может занять много времени"     view-as alert-box question     buttons yes-no     title "Экспорт XML"     update go-ahead.
        if go-ahead = no
        then do:
            undo, return no-apply.
        end.
    end.
    when 'CARD'
    then do:
            message       "Экспортировать данные продаж по дисконтным картам? Операция может занять много времени"     view-as alert-box question     buttons yes-no     title "Экспорт XML"     update go-ahead.
      if go-ahead = no
      then do:
        return.
      end.
    end.
    otherwise do:
        if entry( 1, p-export-type ) <> "util"
        then do:
            message
                "Неверный параметр вызова программы экспорта bge.p"
            view-as alert-box.
            return.
        end.
    end.
end case.
  run enable_UI.
  run start-bge.
  WAIT-for GO OF frame DLG-LOG.
end.
run disable_UI.
procedure disable_UI :
  hide frame DLG-LOG.
end procedure.
procedure enable_UI :
  display DLG-COUNTER EDT-LOG
      with frame DLG-LOG.
  enable DLG-COUNTER Btn_OK EDT-LOG
      with frame DLG-LOG.
  view frame DLG-LOG.
  assign DLG-COUNTER :visible = false.
end procedure.
procedure start-bge:
do
on error undo, return error
:
define variable v-date-from         as date             no-undo.
define variable v-shift-num-from    as integer          no-undo.
define variable v-date-to           as date             no-undo.
define variable v-shift-num-to      as integer          no-undo.
define variable v-range             as integer          no-undo.
define variable v-obj-list          as character        no-undo.
define variable v-pay-code          as logical          no-undo.
define variable v-doc-type-list     as character        no-undo.
define variable v-cst               as logical          no-undo.
define variable v-parts             as logical          no-undo.
define variable v-chk-pay-code      as logical          no-undo.
define variable v-pay-desk          as logical          no-undo.
define variable v-pay-desk-cards    as logical          no-undo.
define variable v-deleted           as logical          no-undo.
define variable v-count             as integer          no-undo.
define variable v-list-item         as character        no-undo.
define variable v-cancel            as logical          no-undo.
case p-export-type:
    when "ALL-DOC-REF":U
    then do:
        run bgelib-write-edt in this-procedure (
              input v-bge-editor-handle
            , input 1
            , input "Экспорт документов и справочников..."
        ).
        if v-bge-shift-mode = yes
        and v-bgelib-bgefmt = "xml":U
        then do:
            run export-docs-shifts in this-procedure (
                input no
            ).
        end.
        else do:
            run export-docs-no-shifts in this-procedure (
                  input no
            ).
        end.
        run export-refs in this-procedure.
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт документов и справочников завершён." ).
    end.
    when "ALL-DAY-WAY":U
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по товарам по дням и по товарам в пути..." ).
        run export-day in this-procedure.
        run export-way in this-procedure.
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по товарам по дням и по товарам в пути завершён.").
    end.
    when "SHIFT":U
    then do:
        run export-shift in this-procedure.
    end.
    when "DOC":U
    then do:
        if v-bge-shift-mode = yes
        and v-bgelib-bgefmt = "xml":U
        then do:
            run export-docs-shifts in this-procedure (
                input no
            ).
        end.
        else do:
            run export-docs-no-shifts in this-procedure (
                input no
            ).
        end.
    end.
    when "STK":U
    then do:
        run export-stk in this-procedure (
              input 2
            , input yes
        ).
    end.
    when "STD":U
    then do:
        run export-std in this-procedure.
    end.
    when "STT":U
    then do:
        run export-stt in this-procedure.
    end.
    when "PRC":U
    then do:
        run export-prc in this-procedure.
    end.
  when "DAY":U
  then do:
        run export-day in this-procedure.
  end.
  when "WAY":U
  then do:
    run export-way in this-procedure.
  end.
  when "KASS":U
  then do:
    run export-kass in this-procedure (
        input 0
    ).
  end.
  when "REF":U
  then do:
    run export-refs in this-procedure.
  end.
  when "CARD":U
  then do:
    run export-card in this-procedure .
  end.
  when "FINDOC":U
  then do:
    run export-findoc in this-procedure.
  END.
  when "FIN-OB":U
  then do:
    run export-fin-ob in this-procedure.
  END.
  when "CONTRACT":U
  then do:
    run export-contract in this-procedure.
  END.
  when "SCHET-FACTUR":U
  then do:
    run export-schet-factur in this-procedure.
  end.
  OTHERWISE do:
    if entry( 1, p-export-type ) <> "util":U
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Неверный параметр " + p-export-type + " в вызове процедуры" + vss-description).
    end.
    else do:
        if entry( 2, p-export-type ) = "g-expie":U
        then do:
            if v-bge-shift-mode = yes
            and v-bgelib-bgefmt = "xml":U
            then do:
                run export-docs-shifts in this-procedure (
                    input yes
                ).
            end.
            else do:
                run export-docs-no-shifts in this-procedure (
                    input yes
                ).
            end.
        end.
        else do:
            do v-count = 2 to num-entries( p-export-type )
            :
                case entry( v-count, p-export-type )
                :
                    when "1"
                    then do:
                        run export-refs in this-procedure.
                    end.
                    when "2"
                    then do:
                        if v-bge-shift-mode = yes
                        and v-bgelib-bgefmt = "xml":U
                        then do:
                            run export-docs-shifts in this-procedure (
                                input no
                            ).
                        end.
                        else do:
                            run export-docs-no-shifts in this-procedure (
                                input no
                            ).
                        end.
                    end.
                    when "3"
                    then do:
                        run export-kass in this-procedure (
                            input 1
                        ).
                    end.
                    when "4"
                    then do:
                        run export-stk in this-procedure (
                              input 1
                            , input no
                        ).
                    end.
                    when "5"
                    then do:
                        run export-day in this-procedure .
                    end.
                    when "6"
                    then do:
                        run export-way in this-procedure.
                    end.
                    otherwise do:
                        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Ошибка выбора типа экспорта ..." ).
                    end.
                end case.
            end.
        end.
    end.
  end.
end case.
enable
    Btn_Ok
    EDT-LOG
with frame DLG-LOG.
end.
end procedure.
PROCEDURE export-docs-no-shifts :
define input parameter p-need-opened-docs   as logical          no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cst               as logical      no-undo.
    define variable v-parts             as logical      no-undo.
    define variable v-chk-pay-code      as logical      no-undo.
    define variable v-pay-desk          as logical      no-undo.
    define variable v-pay-desk-cards    as logical      no-undo.
    define variable v-deleted           as logical      no-undo.
    define variable v-chk               as logical      no-undo.
    define variable v-doc-rvs           as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dper.w (
          input parparentproc
        , input 1
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ?
    then do:
        return error.
    end.
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input substitute( "Экспорт документов, диапазон дат &1 - &2"
                                , string( v-date-from, "99.99.99" )
                                , string( v-date-to, "99.99.99" ) )
    ).
    run bgelib-write-edt in this-procedure (
        input v-bge-editor-handle
        , input 1
        , input substitute( "Диапазон: &1"
                                , ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) ) )
    ).
    if v-pay-code = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По видам оплат" ).
    end.
    if v-cst = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Со строкой ГТД в документах" ).
    end.
    if v-parts = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По партиям" ).
    end.
    if v-chk-pay-code = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По типам кассовых платежей" ).
    end.
    if v-pay-desk = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По кассам" ).
    end.
    if v-pay-desk-cards = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По префиксам карт" ).
    end.
    if v-deleted = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Удаленные документы" ).
    end.
    if v-chk = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Чеки" ).
    end.
    if v-bge-format-dbf = yes
    then do:
        run bge/bge-docd.p (
              input parparentproc
            , input v-date-from
            , input v-date-to
            , input v-range
            , input v-obj-list
            , input v-doc-type-list
            , input v-pay-code
            , input v-cst
            , input v-parts
            , input v-chk-pay-code
            , input v-pay-desk
            , input v-pay-desk-cards
            , input v-deleted
            , input v-chk
            , input v-doc-rvs
            , input p-need-opened-docs
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка экспорта документов"
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
    else do:
        if v-bge-isbgeold = yes
        then do:
            if v-bgelib-bgeflold = "firm":U
            then do:
                run bge/bge-docf.p (
                      input parparentproc
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input v-doc-type-list
                    , input v-pay-code
                    , input v-cst
                    , input v-parts
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input v-pay-desk-cards
                    , input v-deleted
                    , input v-chk
                    , input v-doc-rvs
                    , input p-need-opened-docs
                    , input v-bge-editor-handle
                    , input v-bge-fillin-handle
                ) no-error.
                if error-status :error
                then do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка экспорта документов"
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
            else do:
                run bge/bge-docs.p (
                      input parparentproc
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input v-doc-type-list
                    , input v-pay-code
                    , input v-cst
                    , input v-parts
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input v-pay-desk-cards
                    , input v-deleted
                    , input v-chk
                    , input v-doc-rvs
                    , input p-need-opened-docs
                    , input v-bge-editor-handle
                    , input v-bge-fillin-handle
                ) no-error.
                if error-status :error
                then do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка экспорта документов"
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.
        else do:
            run bge/bgedocs.p (
                  input parparentproc
                , input v-date-from
                , input v-date-to
                , input v-range
                , input v-obj-list
                , input v-doc-type-list
                , input v-pay-code
                , input v-cst
                , input v-parts
                , input v-chk-pay-code
                , input v-pay-desk
                , input v-pay-desk-cards
                , input v-deleted
                , input p-need-opened-docs
                , input v-bge-editor-handle
                , input v-bge-fillin-handle
            ) no-error.
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка экспорта документов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт документов завершён.").
end.
END PROCEDURE.
PROCEDURE export-docs-shifts :
define input parameter p-need-opened-docs   as logical          no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cst               as logical      no-undo.
    define variable v-parts             as logical      no-undo.
    define variable v-chk-pay-code      as logical      no-undo.
    define variable v-pay-desk          as logical      no-undo.
    define variable v-pay-desk-cards    as logical      no-undo.
    define variable v-deleted           as logical      no-undo.
    define variable v-chk               as logical      no-undo.
    define variable v-doc-rvs           as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dpeh.w (
          input parparentproc
        , input 1
        , input v-doc-type-list
        , output v-date-from
        , output v-shift-num-from
        , output v-date-to
        , output v-shift-num-to
        , output v-shift-on
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ?
    then do:
        return error.
    end.
    if v-shift-on = yes
    then do:
        run bgelib-write-edt in this-procedure (
            input v-bge-editor-handle
            , input 1
            , input substitute( "Экспорт документов, &1 (смена &2) - &3 (смена &4)"
                                    , string( v-date-from, "99.99.99" )
                                    , v-shift-num-from
                                    , string( v-date-to, "99.99.99" )
                                    , v-shift-num-to    )
        ).
    end.
    else do:
        run bgelib-write-edt in this-procedure (
              input v-bge-editor-handle
            , input 1
            , input substitute( "Экспорт документов, диапазон дат &1 - &2"
                                    , string( v-date-from, "99.99.99" )
                                    , string( v-date-to, "99.99.99" ) )
        ).
    end.
    run bgelib-write-edt in this-procedure (
        input v-bge-editor-handle
        , input 1
        , input substitute( "Диапазон: &1"
                                , ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) ) )
    ).
    if v-pay-code = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По видам оплат" ).
    end.
    if v-cst = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Со строкой ГТД в документах" ).
    end.
    if v-parts = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По партиям" ).
    end.
    if v-chk-pay-code = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По типам кассовых платежей" ).
    end.
    if v-pay-desk = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По кассам" ).
    end.
    if v-pay-desk-cards = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "По префиксам карт" ).
    end.
    if v-deleted = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Удаленные документы" ).
    end.
    if v-chk = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Чеки" ).
    end.
    if v-doc-rvs = yes
    then do:
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Сверки до/после слива" ).
    end.
    if v-shift-on = yes
    then do:
        run bge/bge-doch.p (
              input parparentproc
            , input v-date-from
            , input v-shift-num-from
            , input v-date-to
            , input v-shift-num-to
            , input v-shift-on
            , input v-range
            , input v-obj-list
            , input v-doc-type-list
            , input v-pay-code
            , input v-cst
            , input v-parts
            , input v-chk-pay-code
            , input v-pay-desk
            , input v-pay-desk-cards
            , input v-deleted
            , input v-chk
            , input v-doc-rvs
            , input p-need-opened-docs
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка экспорта документов"
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
    else do:
        if v-bge-format-dbf = yes
        then do:
            run bge/bge-docd.p (
                  input parparentproc
                , input v-date-from
                , input v-date-to
                , input v-range
                , input v-obj-list
                , input v-doc-type-list
                , input v-pay-code
                , input v-cst
                , input v-parts
                , input v-chk-pay-code
                , input v-pay-desk
                , input v-pay-desk-cards
                , input v-deleted
                , input v-chk
                , input v-doc-rvs
                , input p-need-opened-docs
                , input v-bge-editor-handle
                , input v-bge-fillin-handle
            ) no-error.
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка экспорта документов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        else do:
            if v-bge-isbgeold = yes
            then do:
                run bge/bge-docs.p (
                      input parparentproc
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input v-doc-type-list
                    , input v-pay-code
                    , input v-cst
                    , input v-parts
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input v-pay-desk-cards
                    , input v-deleted
                    , input v-chk
                    , input v-doc-rvs
                    , input p-need-opened-docs
                    , input v-bge-editor-handle
                    , input v-bge-fillin-handle
                ) no-error.
                if error-status :error
                then do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка экспорта документов"
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
            else do:
                run bge/bgedocs.p (
                      input parparentproc
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input v-doc-type-list
                    , input v-pay-code
                    , input v-cst
                    , input v-parts
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input v-pay-desk-cards
                    , input v-deleted
                    , input p-need-opened-docs
                    , input v-bge-editor-handle
                    , input v-bge-fillin-handle
                ) no-error.
                if error-status :error
                then do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка экспорта документов"
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт документов завершён.").
end.
END PROCEDURE.
PROCEDURE export-refs :
do
on error undo, return error
:
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт справочников..." ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-ref.p (
              input parparentproc
            , input "good-ext":U
            , input no
            , input v-bge-host-code
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.
    else do:
        run bge/bgeref.p (
              input parparentproc
            , input "good-ext":U
            , input no
            , input v-bge-host-code
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт справочников завершён." ).
end.
END PROCEDURE.
PROCEDURE export-day :
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cst               as logical      no-undo.
    define variable v-parts             as logical      no-undo.
    define variable v-chk-pay-code      as logical      no-undo.
    define variable v-pay-desk          as logical      no-undo.
    define variable v-pay-desk-cards    as logical      no-undo.
    define variable v-deleted           as logical      no-undo.
    define variable v-chk               as logical      no-undo.
    define variable v-doc-rvs           as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по товарам по дням..." ).
    run bge/bge-dper.w (
          input parparentproc
        , input 3
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт товаров по дням, диапазон дат "
                                + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                                + " ..."
                    ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-day.p (
              input parparentproc
            , input v-date-from
            , input v-date-to
            , input v-range
            , input v-obj-list
            , input v-bge-host-code
            , input no
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.
    else do:
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт товаров по дням завершён.").
end.
END PROCEDURE.
PROCEDURE export-way :
do
on error undo, return error
:
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт товаров в пути...").
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-way.p (
              input v-bge-host-code
            , input no
            , input 0
            , input ""
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.
    else do:
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт товаров в пути завершён.").
end.
END PROCEDURE.
PROCEDURE export-shift :
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-void-logical      as logical      no-undo.
    define variable v-void-character    as character    no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dpeh.w (
          input parparentproc
        , input 5
        , input "":U
        , output v-date-from
        , output v-shift-num-from
        , output v-date-to
        , output v-shift-num-to
        , output v-void-logical
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , output v-void-character
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ?
    then do:
        return error.
    end.
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input substitute( "Экспорт смен, &1 (смена &2) - &3 (смена &4)"
                            , string( v-date-from, "99.99.99" )
                            , v-shift-num-from
                            , string( v-date-to, "99.99.99" )
                            , v-shift-num-to    )
    ).
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input substitute( "Диапазон: &1"
                                , ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) ) )
    ).
    run bge/bge-shft.p (
          input parparentproc
        , input v-date-from
        , input v-shift-num-from
        , input v-date-to
        , input v-shift-num-to
        , input v-range
        , input v-obj-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта документов"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт документов завершён.").
end.
END PROCEDURE.
PROCEDURE export-stk :
define input parameter p-dialog-mode    as integer          no-undo.
define input parameter p-cst            as logical          no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cst               as logical      no-undo.
    define variable v-parts             as logical      no-undo.
    define variable v-chk-pay-code      as logical      no-undo.
    define variable v-pay-desk          as logical      no-undo.
    define variable v-pay-desk-cards    as logical      no-undo.
    define variable v-deleted           as logical      no-undo.
    define variable v-chk               as logical      no-undo.
    define variable v-doc-rvs           as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dper.w (
          input parparentproc
        , input p-dialog-mode
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки документов."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Остатки по товарам"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                                + " ..."
                    ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-stk.p (
              input parparentproc
            , input v-bge-host-code
            , input v-date-from
            , input v-date-to
            , input ( if p-cst = no then no else v-cst )
            , input no
            , input 0
            , input ""
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.
    else do:
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Остатки по товарам выгружены.").
end.
END PROCEDURE.
PROCEDURE export-std :
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cst               as logical      no-undo.
    define variable v-parts             as logical      no-undo.
    define variable v-chk-pay-code      as logical      no-undo.
    define variable v-pay-desk          as logical      no-undo.
    define variable v-pay-desk-cards    as logical      no-undo.
    define variable v-deleted           as logical      no-undo.
    define variable v-chk               as logical      no-undo.
    define variable v-doc-rvs           as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dper.w (
          input parparentproc
        , input 4
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка ввода параметров выгрузки остатков по складам."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-to = ? then return error.
    run bgelib-write-edt in this-procedure (
        input v-bge-editor-handle
        , input 1
        , input "Остатки по товарам на дату "
                + string(v-date-to, "99.99.99")
                + " ..."
    ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bgestd.p (
              input parparentproc
            , input v-bge-host-code
            , input v-range
            , input v-obj-list
            , input v-date-to
            , input v-cst
            , input v-parts
            , input no
            , input 0
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.
    else do:
        run bge/bgestd.p (
              input parparentproc
            , input v-bge-host-code
            , input v-range
            , input v-obj-list
            , input v-date-to
            , input v-cst
            , input v-parts
            , input no
            , input 0
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Остатки по товарам выгружены.").
end.
END PROCEDURE.
PROCEDURE export-stt :
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cst               as logical      no-undo.
    define variable v-parts             as logical      no-undo.
    define variable v-chk-pay-code      as logical      no-undo.
    define variable v-pay-desk          as logical      no-undo.
    define variable v-pay-desk-cards    as logical      no-undo.
    define variable v-deleted           as logical      no-undo.
    define variable v-chk               as logical      no-undo.
    define variable v-doc-rvs           as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
        run bge/bge-dper.w (
              input parparentproc
            , input 4
            , input v-doc-type-list
            , output v-date-from
            , output v-date-to
            , output v-range
            , output v-bge-host-code
            , output v-obj-list
            , OUTPUT v-pay-type-list
            , output v-doc-type-list
            , output v-pay-code
            , output v-cst
            , output v-parts
            , output v-chk-pay-code
            , output v-pay-desk
            , output v-pay-desk-cards
            , output v-deleted
            , output v-chk
            , output v-doc-rvs
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка ввода параметров выгрузки остатков по складам по типам приобретения."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        if v-cancel = yes
        then do:
            undo, return error .
        end.
        if v-date-to = ? then return error.
        run bgelib-write-edt in this-procedure (
            input v-bge-editor-handle
            , input 1
            , input "Остатки по товарам по типам приобретения на дату "
                    + string(v-date-to, "99.99.99")
                    + " ..."
        ).
        if v-bge-isbgeold = yes
        then do:
            run bge/bgestt.p (
                  input parparentproc
                , input v-bge-host-code
                , input v-range
                , input v-obj-list
                , input v-date-to
                , input v-cst
                , input no
                , input 0
                , input v-bge-editor-handle
                , input v-bge-fillin-handle
            ).
        end.
        else do:
            run bge/bgestt.p (
                  input parparentproc
                , input v-bge-host-code
                , input v-range
                , input v-obj-list
                , input v-date-to
                , input v-cst
                , input no
                , input 0
                , input v-bge-editor-handle
                , input v-bge-fillin-handle
            ).
        end.
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Остатки по товарам по типам приобретения выгружены.").
end.
END PROCEDURE.
PROCEDURE export-prc :
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cst               as logical      no-undo.
    define variable v-parts             as logical      no-undo.
    define variable v-chk-pay-code      as logical      no-undo.
    define variable v-pay-desk          as logical      no-undo.
    define variable v-pay-desk-cards    as logical      no-undo.
    define variable v-deleted           as logical      no-undo.
    define variable v-chk               as logical      no-undo.
    define variable v-doc-rvs           as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
        run bge/bge-dper.w (
              input parparentproc
            , input 5
            , input v-doc-type-list
            , output v-date-from
            , output v-date-to
            , output v-range
            , output v-bge-host-code
            , output v-obj-list
            , OUTPUT v-pay-type-list
            , output v-doc-type-list
            , output v-pay-code
            , output v-cst
            , output v-parts
            , output v-chk-pay-code
            , output v-pay-desk
            , output v-pay-desk-cards
            , output v-deleted
            , output v-chk
            , output v-doc-rvs
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка ввода параметров выгрузки документов."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        if v-cancel = yes
        then do:
            undo, return error .
        end.
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт цен товаров...").
        run bge/bgeprc.p (
              input parparentproc
            , input no
            , input "all":U
            , input table temp_bgelib_goods
            , input v-bge-host-code
            , input v-range
            , input v-obj-list
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
        run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт цен товаров завершён.").
end.
END PROCEDURE.
PROCEDURE export-kass :
define input parameter p-dialog-mode    as integer          no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cst               as logical      no-undo.
    define variable v-parts             as logical      no-undo.
    define variable v-chk-pay-code      as logical      no-undo.
    define variable v-pay-desk          as logical      no-undo.
    define variable v-pay-desk-cards    as logical      no-undo.
    define variable v-deleted           as logical      no-undo.
    define variable v-chk               as logical      no-undo.
    define variable v-doc-rvs           as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-dper.w (
          input parparentproc
        , input p-dialog-mode
        , input v-doc-type-list
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки документов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт продаж через кассы..."
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                                + " ..."
                      ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-kass.p (
              input parparentproc
            , input v-date-from
            , input v-date-to
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ).
    end.
    else do:
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт продаж через кассы завершён.").
end.
END PROCEDURE.
PROCEDURE export-card :
    define variable v-date-from         as date         no-undo.
    define variable v-shift-num-from    as integer      no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-num-to      as integer      no-undo.
    define variable v-shift-on          as logical      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-code          as logical      no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cst               as logical      no-undo.
    define variable v-parts             as logical      no-undo.
    define variable v-chk-pay-code      as logical      no-undo.
    define variable v-pay-desk          as logical      no-undo.
    define variable v-pay-desk-cards    as logical      no-undo.
    define variable v-deleted           as logical      no-undo.
    define variable v-chk               as logical      no-undo.
    define variable v-doc-rvs           as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных продаж по дисконтным картам...").
    run bge/bge-dper.w (
          input parparentproc
        , input 0
        , input ""
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-bge-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-parts
        , output v-chk-pay-code
        , output v-pay-desk
        , output v-pay-desk-cards
        , output v-deleted
        , output v-chk
        , output v-doc-rvs
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки данных продаж по дисконтным картам."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных продаж по дисконтным картам"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) )
                      ).
    if v-bge-isbgeold = yes
    then do:
        run bge/bge-card.p (
              input parparentproc
            , input v-date-from
            , input v-date-to
            , input v-range
            , input v-obj-list
            , input v-bge-editor-handle
            , input v-bge-fillin-handle
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка экспорта данных продаж по дисконтным картам"
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
    else do:
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных продаж по дисконтным картам завершён.").
end.
END PROCEDURE.
PROCEDURE export-findoc :
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bgefdper.w (
          input parparentproc
        , input '':U
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-obj-list
        , output v-doc-type-list
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки документов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт платежей"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else (" по фирмам: "  + v-obj-list))
                      ).
    run bge/bgefdoc.p (
          input v-date-from
        , input v-date-to
        , input v-range
        , input "":U
        , input v-bge-host-code
        , input v-obj-list
        , input 0
        , input v-doc-type-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта данных по документам платежей"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по документам платежей завершён.").
end.
END PROCEDURE.
PROCEDURE export-fin-ob :
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bgefinob.w (
          input parparentproc
        , input '':U
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-obj-list
        , output v-doc-type-list
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки документов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт финансовых обязательств"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else (" по фирмам: "  + v-obj-list))
                      ).
    run bge/bgefo.p (
          input v-date-from
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта данных по ФО"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по ФО завершён.").
end.
END PROCEDURE.
PROCEDURE export-contract :
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-doc-type-list     as character    no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bgectper.w (
          input parparentproc
        , input '':U
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-obj-list
        , output v-doc-type-list
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки договоров."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ? or v-date-to = ? then return error.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт договоров"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else (" по фирмам: "  + v-obj-list))
                      ).
    run bge/bgecont.p (
          input v-date-from
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input v-doc-type-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта данных по договорам"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bgelib-write-edt in this-procedure ( v-bge-editor-handle, 1, "Экспорт данных по договорам завершён.").
end.
END PROCEDURE.
PROCEDURE export-schet-factur :
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-cancel            as logical      no-undo.
do
on error undo, return error
:
    run bge/bge-s-f.w (
          input parparentproc
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-obj-list
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description skip "Ошибка ввода параметров выгрузки счетов-фактур." skip return-value
          skip trim(error-status :get-message(1))  trim(error-status :get-message(2)) trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    if v-date-from = ?
    or v-date-to = ?
    then do:
        return error.
    end.
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input substitute( "Экспорт счетов-фактур, диапазон дат &1 - &2"
                            , string(v-date-from, "99.99.99")
                            , string(v-date-to, "99.99.99")    )
    ).
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input "Диапазон:" + ( if v-range = 1 then " по всем фирмам" else (" по фирмам: "  + v-obj-list) )
    ).
    process events.
    run bge/bge-sf.p (
          input parparentproc
        , input v-date-from
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input v-bge-editor-handle
        , input v-bge-fillin-handle
    ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip "Ошибка экспорта счетов-фактур" skip return-value
        skip trim(error-status :get-message(1))  trim(error-status :get-message(2)) trim(error-status :get-message(3))
      view-as alert-box error.
      undo, return error .
    end.
    run bgelib-write-edt in this-procedure (
          input v-bge-editor-handle
        , input 1
        , input "Экспорт счетов-фактур завершен."
    ).
end.
END PROCEDURE.
