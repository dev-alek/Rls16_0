block-level on error undo, throw.
define input parameter p-host-code              as integer                 no-undo.
define input parameter p-ext-doc-type           as character               no-undo.
define input parameter p-oper-name              as character               no-undo.
define input parameter p-date1                  as date                    no-undo.
define input parameter p-date2                  as date                    no-undo.
define input parameter p-obj-list               as character               no-undo.
define input parameter p-doc-type-list          as character               no-undo.
define input parameter p-parameter-list         as character               no-undo.
define input parameter p-xml-file-name          as character               no-undo.
define input parameter p-log-file-name          as character               no-undo.
define input parameter p-list-file-name         as character               no-undo.
define input parameter p-xml-file-number        as integer                 no-undo.
define input parameter hEDT                     as handle                  no-undo.
define input parameter hCNT                     as handle                  no-undo.
define output parameter p-last-xml-file-name    as character               no-undo.
define output parameter p-last-xml-file-number  as integer                 no-undo.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: contoper.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/contoper.p $":U .
def var vss-description as character no-undo init "Экспорт договоров".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
do
on error undo, return error
:
  define variable v-exists-operation          as logical      no-undo.
  define variable v-last-file-position        as integer       no-undo.
    ASSIGN  v-exists-operation = NO .
    RUN bgelib-write-cnt( hCNT, "" ).
    assign p-last-xml-file-name = p-xml-file-name .
    run export-documents in this-procedure (
          input p-obj-list
        , input p-doc-type-list
        , input p-parameter-list
        , input p-xml-file-name
        , input p-log-file-name
        , input p-list-file-name
        , input p-xml-file-number
        , output p-last-xml-file-name
        , output p-last-xml-file-number
    ).
end.
procedure export-documents :
do
on error undo, return error
:
  define input parameter p-obj-list               as character    no-undo.
  define input parameter p-doc-type-list          as character    no-undo.
  define input parameter p-parameter-list         as character    no-undo.
  define input parameter p-xml-file-name          as character    no-undo.
  define input parameter p-log-file-name          as character    no-undo.
  define input parameter p-list-file-name         as character    no-undo.
  define input parameter p-xml-file-number        as integer      no-undo.
  define output parameter p-last-xml-file-name    as character    no-undo.
  define output parameter p-last-xml-file-number  as integer      no-undo.
  define variable v-exists-before as logical      no-undo.
  define variable v-exists-after  as logical      no-undo.
  define variable v-need-new-file  as logical     no-undo.
  define variable v-need-disk-spc  as logical     no-undo.
  define variable v-cancel         as logical     no-undo.
  define variable v-prev-filename  as character   no-undo.
  define variable v-void-string    as character   no-undo.
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  define buffer buf_contract for ub.contract.
  define buffer buf_contract-attr for ub.contract-attr .
  define buffer buf_contract-specif for ub.contract-specif.
  assign
      p-last-xml-file-name    = p-xml-file-name
      p-last-xml-file-number  = p-xml-file-number
  .
  output stream stmxmlout to value( p-xml-file-name + "tmp" ) convert target "1251" append.
export-documents:
  for each buf_contract no-lock where
          buf_contract.host-code = p-host-code
      AND buf_contract.contract-date >= p-date1
      AND buf_contract.contract-date <= p-date2
      AND buf_contract.status_ = 'тек':U
  on error undo, return error
  :
    if buf_contract.doc-type <> p-ext-doc-type then next export-documents.
    if v-need-new-file = yes  then do:
      output stream stmxmlout close.
      assign v-prev-filename = p-xml-file-name .
      run bgelib-filename in this-procedure (
              input "contract"
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
            , input substitute( "Данные выгружены в файл &1", replace( p-xml-file-name, "/", "\" ) + "xml")
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
            , input p-doc-type-list
            , input p-parameter-list
        ).
       output stream stmxmlout to value( p-xml-file-name + "tmp" ) convert target "1251" append.
       assign v-need-new-file = no .
    end.
    if not v-exists-operation then do:
      run bgelib-write-edt in this-procedure ( hEDT, 4, "Операция " + string( p-oper-name ) ).
      run bgelib-write-log in this-procedure ( p-log-file-name, 0, "&Line" ).
      run bgelib-write-log in this-procedure ( p-log-file-name, 1, "XML - Вывод операции " + string( p-oper-name ) + " (" + p-ext-doc-type + ")" ).
      assign v-exists-operation = yes .
    end.
    run bgelib-write-cnt( hcnt, "   " + string(buf_contract.contract-code ) + " от " + string( buf_contract.contract-date ) ) .
    process events.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
run bgelib-tag-open in this-procedure ( input 0, substitute("&1", 'contract'),  "" ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-code'),  input string(buf_contract.contract-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'host-code'),  input string(buf_contract.host-code), input 1 ).
if buf_contract.contract-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-date'),  input string(buf_contract.contract-date, '99.99.9999'), input 1 ).
end.
if buf_contract.contract-date-beg <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-date-beg'),  input string(buf_contract.contract-date-beg, '99.99.9999'), input 1 ).
end.
if buf_contract.contract-date-end <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-date-end'),  input string(buf_contract.contract-date-end, '99.99.9999'), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-type'),  input string(buf_contract.contract-type), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'status_'),  input string(buf_contract.status_), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-prn-code'),  input string(buf_contract.contract-prn-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-name'),  input string(buf_contract.contract-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-city'),  input string(buf_contract.contract-city), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'curr-code'),  input string(buf_contract.curr-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'usl-opl'),  input string(buf_contract.usl-opl), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'srok-opl'),  input string(buf_contract.srok-opl), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'doc-type'),  input string(buf_contract.doc-type), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'str-uslov-oplat'),  input string(buf_contract.str-uslov-oplat), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fin-VAT-pc'),  input string(buf_contract.fin-VAT-pc), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'pay-nal'),  input string(buf_contract.pay-nal), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'user-db-num'),  input string(buf_contract.user-db-num), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'user-name'),  input string(buf_contract.user-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'auto-pay'),  input string(buf_contract.auto-pay), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'client'),  input string(buf_contract.cli-type + string(buf_contract.cli-code)), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-name'),  input string(buf_contract.cli-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-addres'),  input string(buf_contract.cli-addres), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-inn'),  input string(buf_contract.cli-inn), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-kpp'),  input string(buf_contract.cli-kpp), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-bank-name'),  input string(buf_contract.cli-bank-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-bik'),  input string(buf_contract.cli-bik), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-r-schet'),  input string(buf_contract.cli-r-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-c-schet'),  input string(buf_contract.cli-c-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-sign-post'),  input string(buf_contract.cli-sign-post), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-sign'),  input string(buf_contract.cli-sign), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-code-schet'),  input string(buf_contract.cli-code-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cli-code-schet-start'),  input string(buf_contract.cli-code-schet-start), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-name'),  input string(buf_contract.own-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-addres'),  input string(buf_contract.own-addres), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-inn'),  input string(buf_contract.own-inn), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-kpp'),  input string(buf_contract.own-kpp), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-bank-name'),  input string(buf_contract.own-bank-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-bik'),  input string(buf_contract.own-bik), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-r-schet'),  input string(buf_contract.own-r-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-c-schet'),  input string(buf_contract.own-c-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-sign-post'),  input string(buf_contract.own-sign-post), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-sign'),  input string(buf_contract.own-sign), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-code-schet'),  input string(buf_contract.own-code-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'own-code-schet-start'),  input string(buf_contract.own-code-schet-start), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posrednik'),  input string(buf_contract.posr-type + string(buf_contract.posr-code)), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-name'),  input string(buf_contract.posr-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-addres'),  input string(buf_contract.posr-addres), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-inn'),  input string(buf_contract.posr-inn), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-kpp'),  input string(buf_contract.posr-kpp), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-bank-name'),  input string(buf_contract.posr-bank-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-bik'),  input string(buf_contract.posr-bik), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-r-schet'),  input string(buf_contract.posr-r-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-c-schet'),  input string(buf_contract.posr-c-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-sign-post'),  input string(buf_contract.posr-sign-post), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-sign'),  input string(buf_contract.posr-sign), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-code-schet'),  input string(buf_contract.posr-code-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'posr-code-schet-start'),  input string(buf_contract.posr-code-schet-start), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agent'),  input string(buf_contract.agnt-type + string(buf_contract.agnt-code)), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-name'),  input string(buf_contract.agnt-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-addres'),  input string(buf_contract.agnt-addres), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-inn'),  input string(buf_contract.agnt-inn), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-kpp'),  input string(buf_contract.agnt-kpp), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-bank-name'),  input string(buf_contract.agnt-bank-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-bik'),  input string(buf_contract.agnt-bik), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-r-schet'),  input string(buf_contract.agnt-r-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-c-schet'),  input string(buf_contract.agnt-c-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-sign-post'),  input string(buf_contract.agnt-sign-post), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-sign'),  input string(buf_contract.agnt-sign), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-code-schet'),  input string(buf_contract.agnt-code-schet), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'agnt-code-schet-start'),  input string(buf_contract.agnt-code-schet-start), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'mngr-code'),  input string(buf_contract.mngr-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc-in'),  input string(buf_contract.cor-acc-in), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'an-uchet-code-in'),  input string(buf_contract.an-uchet-code-in), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cel-nazn-code-in'),  input string(buf_contract.cel-nazn-code-in), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc1-in'),  input string(buf_contract.cor-acc1-in), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc-out'),  input string(buf_contract.cor-acc-out), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'an-uchet-code-out'),  input string(buf_contract.an-uchet-code-out), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cel-nazn-code-out'),  input string(buf_contract.cel-nazn-code-out), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc1-out'),  input string(buf_contract.cor-acc1-out), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc-in-cash'),  input string(buf_contract.cor-acc-in-cash), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'an-uchet-code-in-cash'),  input string(buf_contract.an-uchet-code-in-cash), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cel-nazn-code-in-cash'),  input string(buf_contract.cel-nazn-code-in-cash), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc1-in-cash'),  input string(buf_contract.cor-acc1-in-cash), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc-out-cash'),  input string(buf_contract.cor-acc-out-cash), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'an-uchet-code-out-cash'),  input string(buf_contract.an-uchet-code-out-cash), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cel-nazn-code-out-cash'),  input string(buf_contract.cel-nazn-code-out-cash), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc1-out-cash'),  input string(buf_contract.cor-acc1-out-cash), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc-in-payoff'),  input string(buf_contract.cor-acc-in-payoff), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'an-uchet-code-in-payoff'),  input string(buf_contract.an-uchet-code-in-payoff), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cel-nazn-code-in-payoff'),  input string(buf_contract.cel-nazn-code-in-payoff), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc1-in-payoff'),  input string(buf_contract.cor-acc1-in-payoff), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc-out-payoff'),  input string(buf_contract.cor-acc-out-payoff), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'an-uchet-code-out-payoff'),  input string(buf_contract.an-uchet-code-out-payoff), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cel-nazn-code-out-payoff'),  input string(buf_contract.cel-nazn-code-out-payoff), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cor-acc1-out-payoff'),  input string(buf_contract.cor-acc1-out-payoff), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'spec-prc'),  input string(buf_contract.spec-prc), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'spec-check'),  input string(buf_contract.spec-check), input 1 ).
for first buf_contract-attr no-lock where buf_contract-attr.host-code = buf_contract.host-code and buf_contract-attr.contract-code = buf_contract.contract-code and
buf_contract-attr.attr-code = "contract-edi":
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'edi'),  input string(if buf_contract-attr.attr-value = "yes" then "1" else "0"), input 1 ).
end.
run bgelib-tag-close in this-procedure ( input 0, substitute("&1", 'contract')).
for each buf_contract-specif no-lock
    where buf_contract-specif.contract-num = buf_contract.contract-code
    AND   buf_contract-specif.host-code = buf_contract.host-code
on error undo, return error
:
      run bgelib-tag-open in this-procedure ( input 0, substitute("&1", 'contract-specif'),  "" ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-num'),  input string(buf_contract-specif.contract-num), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'host-code'),  input string(buf_contract-specif.host-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'gds-code'),  input string(buf_contract-specif.gds-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'price-cli'),  input string(buf_contract-specif.price-cli), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'prc'),  input string(buf_contract-specif.prc), input 1 ).
      run bgelib-tag-close in this-procedure ( input 0, substitute("&1", 'contract-specif')).
end.
    if v-last-file-position = 0 or seek( stmxmlout ) - v-last-file-position > 1048576 then do:
      run gbl/chkfree.p (
          input substring( p-xml-file-name, 1, 1 )
          , input 200
          , output v-need-disk-spc
      ) .
      if v-need-disk-spc = yes then do:
          run gbl/waitfrsp.w (
              input substring( p-xml-file-name, 1, 1 )
              , input 200
              , output v-cancel
          ) .
          if v-cancel = yes then undo, return error.
      end.
      assign v-last-file-position = seek( stmxmlout )  .
    end.
    run bgelib-check-file-size in this-procedure ( input p-xml-file-name + "tmp", output v-need-new-file ).
  end.
  output stream stmxmlout close.
end.
end procedure.
