block-level on error undo, throw.
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-date-to                as date             no-undo.
define input parameter p-fact-order-to          as integer          no-undo.
define input parameter p-obj-list               as character        no-undo.
define input parameter p-parameter-list         as character        no-undo.
define input parameter p-xml-file-name          as character        no-undo.
define input parameter p-log-file-name          as character        no-undo.
define input parameter p-list-file-name         as character        no-undo.
define input parameter p-xml-file-number        as integer          no-undo.
define input parameter hedt                     as handle           no-undo.
define input parameter hcnt                     as handle           no-undo.
define output parameter p-last-xml-file-name    as character        no-undo.
define output parameter p-last-xml-file-number  as integer          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sttoper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/sttoper.p $":U .
define variable vss-description as character no-undo init "Экспорт товарных остатков по типам приобретения на дату.".
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
    define variable v-goods-counter     as integer      no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-base-code         as integer      no-undo.
    define variable v-base-code-okv     as integer      no-undo.
    define variable v-need-new-file     as logical      no-undo.
    define variable v-prev-filename     as character    no-undo.
    define variable v-void-string       as character    no-undo.
    define variable v-hcnt-is-active    as logical      no-undo.
    define variable v-is-goods          as logical      no-undo.
    define variable v-r-b-is-base       as logical      no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define buffer buf_gds-obj   for ub.gds-obj.
    define buffer buf_stk-line  for ub.stk-line.
do
for buf_gds-obj
  , buf_stk-line
on error undo, return error
:
    process events.
    assign
        p-last-xml-file-name    = p-xml-file-name
        p-last-xml-file-number  = p-xml-file-number
    .
    output stream stmxmlout to value( p-xml-file-name + "tmp" ) convert target "1251" append.
if session :set-wait-state( "compiler" ) then.
    run bgelib-write-cnt( input hCNT, input "" ).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
    run get-base-code-okv in this-procedure (
          input v-base-code
        , output v-base-code-okv
    ).
    run bgelib-tag-open( input 1, input "store", input "" ).
    run bgelib-tag-put( input 2, input "storeCode"      , input p-obj-type + string( p-obj-code )   , input 0 ).
    run bgelib-tag-put( input 2, input "hostcode"       , input string( v-host-code )               , input 0 ).
    run bgelib-tag-put( input 2, input "valutCode"      , input string( v-base-code )               , input 0 ).
    run bgelib-tag-put( input 2, input "valutCodeOKV"   , input string( v-base-code-okv )               , input 0 ).
    run bgelib-tag-close( input 1, input "store" ).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-r-b-is-base
  )  .
    goods-on-object:
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = p-obj-type
         and buf_gds-obj.obj-code = p-obj-code
    break by buf_gds-obj.artic
          by buf_gds-obj.prod-type
          by buf_gds-obj.prod-code
    :
        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        if first-of( buf_gds-obj.prod-code )
        then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_gds-obj.artic
  ,input  buf_gds-obj.prod-type
  ,input  buf_gds-obj.prod-code
  ,input  'gds-goods=request':u
  ,output v-is-goods
  )  .
            if v-is-goods = no
            then do:
                next goods-on-object.
            end.
            if v-need-new-file = yes
            then do:
                output stream stmxmlout close.
                assign
                    v-prev-filename = p-xml-file-name
                .
                run bgelib-filename in this-procedure (
                      input "std"
                    , output p-xml-file-name
                    , output v-void-string
                    , output v-void-string
                ).
                run bgelib-write-footer in this-procedure (
                      input no
                    , input v-prev-filename
                    , input p-list-file-name
                    , input yes
                    , input p-xml-file-name + "xml":U
                ).
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "Данные выгружены в файл &1"
                                            , replace( p-xml-file-name, "/", "\" ) + "xml"
                                    )
                ).
                assign
                    p-last-xml-file-number   = p-xml-file-number + 1
                    p-last-xml-file-name     = p-xml-file-name
                .
                run bgelib-write-header in this-procedure (
                      input no
                    , input p-last-xml-file-name
                    , input p-list-file-name
                    , input p-last-xml-file-number
                    , input yes
                    , input v-prev-filename + "xml":U
                    , input p-obj-list
                    , input ""
                    , input p-parameter-list
                ).
                output stream stmxmlout to value( p-xml-file-name + "tmp" ) convert target "1251" append.
                assign
                    v-need-new-file = no
                .
            end.
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input 'r':U
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "repayment":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input 'c':U
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "cons_acc":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input 's':U
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "resp_stor":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input 'o':U
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "old_cons":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input 'v':U
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "service":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            if v-hcnt-is-active = no
            then do:
                run bgelib-show-cnt in this-procedure (
                    input hcnt
                ).
                assign
                    v-hcnt-is-active = yes
                .
                run bgelib-write-cnt(
                      input hcnt
                    , input substitute( "Объект: &1&2 Товаров: &3", p-obj-type, p-obj-code, 1 )
                ).
                process events.
            end.
            assign
                v-goods-counter = v-goods-counter + 1
            .
            if v-goods-counter modulo 100 = 0
            then do:
                run bgelib-write-cnt(
                      input hcnt
                    , input substitute( "Объект: &1&2 Товаров: &3", p-obj-type, p-obj-code, v-goods-counter )
                ).
                process events.
            end.
            run bgelib-check-file-size in this-procedure (
                  input p-xml-file-name + "tmp"
                , output v-need-new-file
            ).
        end.
    end.
    run bgelib-write-cnt(
          input hcnt
        , input substitute( "Объект: &1&2 Товаров: &3", p-obj-type, p-obj-code, v-goods-counter )
    ).
    output stream stmxmlout close.
if session :set-wait-state( "" ) then.
end.
procedure write-result :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-free-qnty      as decimal          no-undo.
define input parameter p-sum-type       as character        no-undo.
define input parameter p-fact-order     as integer          no-undo.
define input parameter p-r-b-is-base    as logical          no-undo.
    define variable v-gds-code          as integer      no-undo.
    define variable v-gds-name          as character    no-undo.
    define variable v-not-output-result as logical      no-undo.
    define variable v-sum-types         as character    no-undo.
    define variable v-main-tags         as character    no-undo.
    define variable v-main-tag          as character    no-undo.
    define buffer buf_goods             for ub.goods.
    define buffer buf_aht-stk-line      for ub.aht-stk-line.
    define buffer buf_benf_aht-stk-line for ub.aht-stk-line.
do
for buf_goods
  , buf_aht-stk-line
on error undo, return error
:
    find last buf_aht-stk-line no-lock
        where buf_aht-stk-line.obj-type  = p-obj-type
          and buf_aht-stk-line.obj-code  = p-obj-code
          and buf_aht-stk-line.gds-code  = p-gds-code
          and buf_aht-stk-line.sum-type  = p-sum-type
          and buf_aht-stk-line.fact-order <= p-fact-order
    use-index category
    no-error.
    if p-sum-type = 'c':U
    then do:
        find last buf_benf_aht-stk-line no-lock
            where buf_benf_aht-stk-line.obj-type  = p-obj-type
              and buf_benf_aht-stk-line.obj-code  = p-obj-code
              and buf_benf_aht-stk-line.gds-code  = p-gds-code
              and buf_benf_aht-stk-line.sum-type  = 'b':U
              and buf_benf_aht-stk-line.fact-order <= p-fact-order
        use-index category
        no-error.
    end.
    assign
        v-not-output-result = no
    .
    if ( not available buf_aht-stk-line )
    or (    buf_aht-stk-line.fact-qnty              = 0
        and buf_aht-stk-line.cost-sum-rubl          = 0
        and buf_aht-stk-line.cost-VAT-rubl          = 0
        and buf_aht-stk-line.cost-SLT-rubl          = 0
        and buf_aht-stk-line.cost-road-tax-rubl     = 0
        and buf_aht-stk-line.cost-transport-rubl    = 0
        and buf_aht-stk-line.cost-other-rubl        = 0
        and buf_aht-stk-line.cost-excise-rubl       = 0
        and buf_aht-stk-line.cost-sum-base          = 0
        and buf_aht-stk-line.cost-VAT-base          = 0
        and buf_aht-stk-line.cost-SLT-base          = 0
        and buf_aht-stk-line.cost-road-tax-base     = 0
        and buf_aht-stk-line.cost-transport-base    = 0
        and buf_aht-stk-line.cost-other-base        = 0
        and buf_aht-stk-line.cost-excise-base       = 0 )
    then do:
        assign
            v-not-output-result = yes
        .
        if p-r-b-is-base = yes
        then do:
            if ( not available buf_aht-stk-line )
            or (    buf_aht-stk-line.crsa-sum-base       = 0
                and buf_aht-stk-line.crsa-VAT-base       = 0
                and buf_aht-stk-line.crsa-SLT-base       = 0
                and buf_aht-stk-line.crsa-road-tax-base  = 0
                and buf_aht-stk-line.crsa-transport-base = 0
                and buf_aht-stk-line.crsa-other-base     = 0
                and buf_aht-stk-line.crsa-excise-base    = 0 )
            then do:
                assign
                    v-not-output-result = yes
                .
            end.
            else do:
                assign
                    v-not-output-result = no
                .
            end.
        end.
        else do:
            if ( not available buf_aht-stk-line )
            or (    buf_aht-stk-line.crsa-sum-rubl       = 0
                and buf_aht-stk-line.crsa-VAT-rubl       = 0
                and buf_aht-stk-line.crsa-SLT-rubl       = 0
                and buf_aht-stk-line.crsa-road-tax-rubl  = 0
                and buf_aht-stk-line.crsa-transport-rubl = 0
                and buf_aht-stk-line.crsa-other-rubl     = 0
                and buf_aht-stk-line.crsa-excise-rubl    = 0 )
            then do:
                assign
                    v-not-output-result = yes
                .
            end.
            else do:
                assign
                    v-not-output-result = no
                .
            end.
        end.
    end.
    if p-sum-type = 'c':U
    then do:
        if available buf_benf_aht-stk-line
        and (
            buf_benf_aht-stk-line.crsa-sum-rubl          <> 0
            or buf_benf_aht-stk-line.crsa-VAT-rubl       <> 0
            or buf_benf_aht-stk-line.crsa-SLT-rubl       <> 0
            or buf_benf_aht-stk-line.crsa-road-tax-rubl  <> 0
            or buf_benf_aht-stk-line.crsa-transport-rubl <> 0
            or buf_benf_aht-stk-line.crsa-other-rubl     <> 0
            or buf_benf_aht-stk-line.crsa-excise-rubl    <> 0 )
        then do:
            assign
                v-not-output-result = no
            .
        end.
    end.
    if v-not-output-result = yes
    then do:
        undo, return .
    end.
    find first buf_goods no-lock
         where buf_goods.gds-code     = p-gds-code
    no-error.
    if available buf_goods
    then do:
        assign
            v-gds-name              = buf_goods.gds-name
        .
    end.
    else do:
        assign
            v-gds-name              = ""
        .
    end.
    assign
        v-sum-types = 'r':U
                        + ",":U + 'c':U
                        + ",":U + 'b':U
                        + ",":U + 's':U
                        + ",":U + 'o':U
                        + ",":U + 'v':U
    .
    assign
        v-main-tags = "storeGoodsRepayment"
                        + ",":U + "storeGoodsCons_acc":U
                        + ",":U + "storeGoodsCons_benf":U
                        + ",":U + "storeGoodsResp_stor":U
                        + ",":U + "storeGoodsOld_cons":U
                        + ",":U + "storeGoodsService":U
    .
    assign
        v-main-tag = entry( lookup( p-sum-type, v-sum-types ), v-main-tags )
    no-error.
    if error-status :error
    or v-main-tag = ?
    or v-main-tag = ""
    then do:
        undo, return error substitute( "Ошибка задания sum-type для архива по типам приобретения. Задано значение &1.", p-sum-type ).
    end.
    run bgelib-tag-open( input 1, input v-main-tag , input "" ).
    run bgelib-tag-put( input 2, input "storeCode"      , input p-obj-type + string( p-obj-code ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsCode"      , input string( p-gds-code              ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsArtic"     , input string( buf_goods.artic         ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsProdType"  , input string( buf_goods.prod-type     ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsProdCode"  , input string( buf_goods.prod-code     ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsName"      , input string( v-gds-name              ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsFreeQntyDate"  , input string( v-today, "99.99.9999"   ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsFreeQntyTime"  , input string( v-time , "hh:mm:ss"     ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsFreeQnty"      , input string( p-free-qnty             ) , input 0 ).
    if available buf_aht-stk-line
    then do:
        run bgelib-tag-put( input 2, input "goodsQnty"             , input string( buf_aht-stk-line.fact-qnty           ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSumr"         , input string( buf_aht-stk-line.cost-sum-rubl       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostVatr"         , input string( buf_aht-stk-line.cost-VAT-rubl       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSltr"         , input string( buf_aht-stk-line.cost-SLT-rubl       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostRoadtaxr"     , input string( buf_aht-stk-line.cost-road-tax-rubl  ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostTransportr"   , input string( buf_aht-stk-line.cost-transport-rubl ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostOtherr"       , input string( buf_aht-stk-line.cost-other-rubl     ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostExciser"      , input string( buf_aht-stk-line.cost-excise-rubl    ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSumb"         , input string( buf_aht-stk-line.cost-sum-base       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostVatb"         , input string( buf_aht-stk-line.cost-VAT-base       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSltb"         , input string( buf_aht-stk-line.cost-SLT-base       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostRoadtaxb"     , input string( buf_aht-stk-line.cost-road-tax-base  ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostTransportb"   , input string( buf_aht-stk-line.cost-transport-base ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostOtherb"       , input string( buf_aht-stk-line.cost-other-base     ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostExciseb"      , input string( buf_aht-stk-line.cost-excise-base    ), input 2 ).
    end.
    if available buf_aht-stk-line
    then do:
        if p-r-b-is-base = yes
        then do:
            if p-sum-type = 'c':U
            then do:
                run bgelib-tag-put( input 2, input "goodsConsSaleSumb"         , input string( buf_aht-stk-line.crsa-sum-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleVatb"         , input string( buf_aht-stk-line.crsa-VAT-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleSltb"         , input string( buf_aht-stk-line.crsa-SLT-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleRoadtaxb"     , input string( buf_aht-stk-line.crsa-road-tax-base   ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleTransportb"   , input string( buf_aht-stk-line.crsa-transport-base  ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleOtherb"       , input string( buf_aht-stk-line.crsa-other-base      ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleExciseb"      , input string( buf_aht-stk-line.crsa-excise-base     ) , input 2 ).
                if available buf_benf_aht-stk-line
                then do:
                    run bgelib-tag-put( input 2, input "goodsBenfSaleSumb"         , input string( buf_benf_aht-stk-line.crsa-sum-base        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleVatb"         , input string( buf_benf_aht-stk-line.crsa-VAT-base        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleSltb"         , input string( buf_benf_aht-stk-line.crsa-SLT-base        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleRoadtaxb"     , input string( buf_benf_aht-stk-line.crsa-road-tax-base   ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleTransportb"   , input string( buf_benf_aht-stk-line.crsa-transport-base  ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleOtherb"       , input string( buf_benf_aht-stk-line.crsa-other-base      ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleExciseb"      , input string( buf_benf_aht-stk-line.crsa-excise-base     ) , input 2 ).
                end.
                run bgelib-tag-put( input 2, input "goodsSaleSumb"         , input string( buf_aht-stk-line.crsa-sum-base        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-sum-base       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleVatb"         , input string( buf_aht-stk-line.crsa-VAT-base        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-VAT-base       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleSltb"         , input string( buf_aht-stk-line.crsa-SLT-base        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-SLT-base       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleRoadtaxb"     , input string( buf_aht-stk-line.crsa-road-tax-base   + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-road-tax-base  else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleTransportb"   , input string( buf_aht-stk-line.crsa-transport-base  + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-transport-base else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleOtherb"       , input string( buf_aht-stk-line.crsa-other-base      + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-other-base     else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleExciseb"      , input string( buf_aht-stk-line.crsa-excise-base     + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-excise-base    else 0 ) ) , input 2 ).
            end.
            else do:
                run bgelib-tag-put( input 2, input "goodsSaleSumb"         , input string( buf_aht-stk-line.crsa-sum-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleVatb"         , input string( buf_aht-stk-line.crsa-VAT-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleSltb"         , input string( buf_aht-stk-line.crsa-SLT-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleRoadtaxb"     , input string( buf_aht-stk-line.crsa-road-tax-base   ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleTransportb"   , input string( buf_aht-stk-line.crsa-transport-base  ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleOtherb"       , input string( buf_aht-stk-line.crsa-other-base      ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleExciseb"      , input string( buf_aht-stk-line.crsa-excise-base     ) , input 2 ).
            end.
        end.
        else do:
            if p-sum-type = 'c':U
            then do:
                run bgelib-tag-put( input 2, input "goodsConsSaleSumr"         , input string( buf_aht-stk-line.crsa-sum-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleVatr"         , input string( buf_aht-stk-line.crsa-VAT-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleSltr"         , input string( buf_aht-stk-line.crsa-SLT-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleRoadtaxr"     , input string( buf_aht-stk-line.crsa-road-tax-rubl   ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleTransportr"   , input string( buf_aht-stk-line.crsa-transport-rubl  ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleOtherr"       , input string( buf_aht-stk-line.crsa-other-rubl      ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleExciser"      , input string( buf_aht-stk-line.crsa-excise-rubl     ) , input 2 ).
                if available buf_benf_aht-stk-line
                then do:
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfSumr"         , input string( buf_benf_aht-stk-line.crsa-sum-rubl        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfVatr"         , input string( buf_benf_aht-stk-line.crsa-VAT-rubl        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfSltr"         , input string( buf_benf_aht-stk-line.crsa-SLT-rubl        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfRoadtaxr"     , input string( buf_benf_aht-stk-line.crsa-road-tax-rubl   ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfTransportr"   , input string( buf_benf_aht-stk-line.crsa-transport-rubl  ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfOtherr"       , input string( buf_benf_aht-stk-line.crsa-other-rubl      ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfExciser"      , input string( buf_benf_aht-stk-line.crsa-excise-rubl     ) , input 2 ).
                end.
                run bgelib-tag-put( input 2, input "goodsSaleSumr"         , input string( buf_aht-stk-line.crsa-sum-rubl        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-sum-rubl       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleVatr"         , input string( buf_aht-stk-line.crsa-VAT-rubl        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-VAT-rubl       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleSltr"         , input string( buf_aht-stk-line.crsa-SLT-rubl        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-SLT-rubl       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleRoadtaxr"     , input string( buf_aht-stk-line.crsa-road-tax-rubl   + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-road-tax-rubl  else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleTransportr"   , input string( buf_aht-stk-line.crsa-transport-rubl  + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-transport-rubl else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleOtherr"       , input string( buf_aht-stk-line.crsa-other-rubl      + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-other-rubl     else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleExciser"      , input string( buf_aht-stk-line.crsa-excise-rubl     + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-excise-rubl    else 0 ) ) , input 2 ).
            end.
            else do:
                run bgelib-tag-put( input 2, input "goodsSaleSumr"         , input string( buf_aht-stk-line.crsa-sum-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleVatr"         , input string( buf_aht-stk-line.crsa-VAT-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleSltr"         , input string( buf_aht-stk-line.crsa-SLT-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleRoadtaxr"     , input string( buf_aht-stk-line.crsa-road-tax-rubl   ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleTransportr"   , input string( buf_aht-stk-line.crsa-transport-rubl  ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleOtherr"       , input string( buf_aht-stk-line.crsa-other-rubl      ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleExciser"      , input string( buf_aht-stk-line.crsa-excise-rubl     ) , input 2 ).
            end.
        end.
    end.
    run bgelib-tag-close( input 1, input v-main-tag ).
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
