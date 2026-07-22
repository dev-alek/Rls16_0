block-level on error undo, throw.
define input parameter p-host-code              as integer                 no-undo.
define input parameter p-oper-name              as character               no-undo.
define input parameter p-fact-order-from        like ub.stk-tot.fact-order no-undo.
define input parameter p-fact-order-to          like ub.stk-tot.fact-order no-undo.
define input parameter p-obj-list               as character               no-undo.
define input parameter p-parameter-list         as character               no-undo.
define input parameter p-xml-file-name          as character               no-undo.
define input parameter p-log-file-name          as character               no-undo.
define input parameter p-list-file-name         as character               no-undo.
define input parameter p-xml-file-number        as integer                 no-undo.
define input parameter hEDT                     as handle                  no-undo.
define input parameter hCNT                     as handle                  no-undo.
define output parameter p-last-xml-file-name    as character               no-undo.
define output parameter p-last-xml-file-number  as integer                 no-undo.
define variable p-doc-type-list as character no-undo  init "" .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fodocop.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: bge/fodocop.p $":U .
define variable vss-description as character no-undo initial "Экспорт финансовых обязательств":U .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do
on error undo, return error
:
  define variable v-exists-operation          as logical       no-undo.
  define variable v-doc-date        like ub.trn-doc.doc-date   no-undo.
  define variable v-fact-date       like ub.trn-doc.fact-date  no-undo.
  define variable v-doc-PS          like ub.trn-doc.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo.
  define variable v-base-name       like ub.currency.curr-name no-undo.
  define variable v-last-file-position        as integer       no-undo.
  define buffer buf_currency for ub.currency.
  define variable v-firm-only as logical   no-undo .
  define buffer buf_sysconf for ub.sysconf.
  find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code no-error .
  if buf_sysconf.fin-calc = 0 then v-firm-only = true.
  else v-firm-only = false .
  define variable v-i as integer   no-undo .
  define variable v-obj-list as character no-undo .
  if v-firm-only = false  then do:
  repeat v-i = 1 to num-entries ( p-obj-list )  by 2 :
   v-obj-list = v-obj-list +  entry (v-i,p-obj-list ) + entry (v-i + 1 , p-obj-list ) + "," .
  end.
  end.
    ASSIGN
    v-exists-operation = NO.
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
    find first buf_currency no-lock where
              buf_currency.curr-code = v-base-code no-error .
    if available buf_currency then
    assign
    v-base-abbr = buf_currency.curr-abbr
    v-base-name = buf_currency.curr-name
    .
    RUN bgelib-write-cnt( hCNT, "" ).
    assign
        p-last-xml-file-name = p-xml-file-name
    .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-doc-code      as character    no-undo.
  define variable v-exch-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-exch-name       like ub.currency.curr-name no-undo .
  define variable v-contr-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-contr-name       like ub.currency.curr-name no-undo .
  define variable v-contract-prn-code like ub.contract.contract-prn-code no-undo .
  define variable v-contract-date     like ub.contract.contract-date no-undo .
  define buffer buf_fin-ob-tax-before          for ub.fin-ob-tax-before.
  define buffer buf_fin-ob-tax          for ub.fin-ob-tax.
  define buffer buf_fin-ob              for ub.fin-ob.
  define buffer buf_fin-ob-before       for ub.fin-ob-before.
  define buffer buf_fin-ob-trn          for ub.fin-ob-trn.
  define buffer buf_fin-gds-part        for ub.fin-gds-part.
  define buffer buf_fin-connect         for ub.fin-connect.
  define buffer buf_contract for ub.contract.
  assign
      p-last-xml-file-name    = p-xml-file-name
      p-last-xml-file-number  = p-xml-file-number
  .
  output stream stmxmlout to value( p-xml-file-name + "tmp" ) convert target "1251" append.
  export-documents:
  for each buf_fin-ob no-lock where
          buf_fin-ob.host-code = p-host-code
      AND buf_fin-ob.fact-order >= p-fact-order-from
      AND buf_fin-ob.fact-order <= p-fact-order-to
      AND buf_fin-ob.status_ = 'факт':U
  on error undo, return error
  :
    if not v-firm-only then do:
        if lookup (buf_fin-ob.obj-type + string(buf_fin-ob.obj-code) , v-obj-list) = 0 then next.
    end.
    if v-need-new-file = yes
    then do:
        output stream stmxmlout close.
        assign
            v-prev-filename = p-xml-file-name
        .
        run bgelib-filename in this-procedure (
              input "fin-ob"
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
            , input p-doc-type-list
            , input p-parameter-list
        ).
        output stream stmxmlout to value( p-xml-file-name + "tmp" ) convert target "1251" append.
        assign
            v-need-new-file = no
        .
    end.
    assign
        v-doc-code = buf_fin-ob.doc-code
    .
    if not v-exists-operation
    then do:
        run bgelib-write-edt in this-procedure ( hEDT, 4, "Операция " + string( p-oper-name ) ).
        run bgelib-write-log in this-procedure ( p-log-file-name, 0, "&Line" ).
        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "XML - Вывод операции " + string( p-oper-name )  ).
        assign
            v-exists-operation = yes
        .
    end.
    assign
    v-doc-code  = buf_fin-ob.doc-code
    v-doc-date  = buf_fin-ob.doc-date
    v-fact-date = buf_fin-ob.fact-date
    v-doc-PS    = buf_fin-ob.ps
    .
    run bgelib-write-cnt ( hcnt, "   " + string( v-doc-code ) + " от " + string( v-fact-date ) ) .
    process events.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run bgelib-tag-open in this-procedure ( input 0, substitute("&1", 'fin-ob'),  "" ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DocID'),  input string(buf_fin-ob.doc-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'Status_'),  input string(buf_fin-ob.status_), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'host'),  input string(buf_fin-ob.host-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DocCode'),  input string(buf_fin-ob.prn-doc-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'object'),  input string(buf_fin-ob.obj-type + string(buf_fin-ob.obj-code)), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DateDoc'),  input string(buf_fin-ob.doc-date, '99.99.9999'), input 1 ).
if buf_fin-ob.fact-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DateFact'),  input string(buf_fin-ob.fact-date, '99.99.9999'), input 1 ).
end.
if buf_fin-ob.pay-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DatePay'),  input string(buf_fin-ob.pay-date, '99.99.9999'), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DocDBNum'),  input string(buf_fin-ob.user-db-num-doc), input 1 ).
if buf_fin-ob.fact-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'FactDBNum'),  input string(buf_fin-ob.user-db-num-fact), input 1 ).
end.
if buf_fin-ob.pay-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'PayDBNum'),  input string(buf_fin-ob.user-db-num-pay), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DocUserName'),  input string(buf_fin-ob.user-name-doc), input 1 ).
if buf_fin-ob.fact-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'FactUserName'),  input string(buf_fin-ob.user-name-fact), input 1 ).
end.
if buf_fin-ob.pay-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'PayUserName'),  input string(buf_fin-ob.user-name-pay), input 1 ).
end.
find first buf_currency no-lock where
          buf_currency.curr-code = buf_fin-ob.curr-code no-error .
if available buf_currency then
assign
v-exch-abbr = buf_currency.curr-abbr
v-exch-name = buf_currency.curr-name
.
else
assign
v-exch-abbr = "":U
v-exch-name = "":U
.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sumDoc'),  input string(buf_fin-ob.sum-doc), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'CrcCode'),  input string(buf_fin-ob.curr-code), input 1 ).
if v-exch-abbr <> "":U then do:
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'CrcAbbr'),  input string(v-exch-abbr), input 1 ).
end.
if v-exch-name <> "":U then do:
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'Crcname'),  input string(v-exch-name), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'CrcRate'),  input string(buf_fin-ob.exch-rate), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'CrcScale'),  input string(buf_fin-ob.exch-scale), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualCrcRate'),  input string(buf_fin-ob.actual-exch-rate), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualCrcScale'),  input string(buf_fin-ob.actual-exch-scale), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sumRubl'),  input string(buf_fin-ob.sum-rubl), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sumBase'),  input string(buf_fin-ob.sum-base), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcCode'),  input string(v-base-code), input 1 ).
if v-base-abbr <> "":U then do:
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcAbbr'),  input string(v-base-abbr), input 1 ).
end.
if v-base-name <> "":U then do:
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcname'),  input string(v-base-name), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcRate'),  input string(buf_fin-ob.base-rate), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcScale'),  input string(buf_fin-ob.base-scale), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualBaseCrcRate'),  input string(buf_fin-ob.actual-base-rate), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualBaseCrcScale'),  input string(buf_fin-ob.actual-base-scale), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'conStat'),  input string(buf_fin-ob.con-stat), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'conSumBase'),  input string(buf_fin-ob.con-sum-base), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'conSumRubl'),  input string(buf_fin-ob.con-sum-rubl), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-tax-doc'),  input string(buf_fin-ob.sum-tax-doc), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-tax-rubl'),  input string(buf_fin-ob.sum-tax-rubl), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-tax-base'),  input string(buf_fin-ob.sum-tax-base), input 1 ).
               run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'conSumDoc'),  input string(buf_fin-ob.con-sum-doc), input 1 ).
if buf_fin-ob.contract-code <> 0 then do:
  find first buf_contract no-lock where
            buf_contract.host-code     = buf_fin-ob.host-code and
            buf_contract.contract-code = buf_fin-ob.contract-code no-error .
  if available buf_contract then
  assign
  v-contract-prn-code = buf_contract.contract-prn-code
  v-contract-date     = buf_contract.contract-date
  .
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCode'),  input string(buf_fin-ob.contract-code), input 1 ).
  if v-contract-prn-code <> "":U then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractNo'),  input string(v-contract-prn-code), input 1 ).
  end.
  if v-contract-date <> ? then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractDate'),  input string(v-contract-date, '99.99.9999'), input 1 ).
  end.
  find first buf_currency no-lock where
            buf_currency.curr-code = buf_fin-ob.contract-curr no-error .
  if available buf_currency then
  assign
  v-contr-abbr = buf_currency.curr-abbr
  v-contr-name = buf_currency.curr-name
  .
  else
  assign
  v-contr-abbr = "":U
  v-contr-name = "":U
  .
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sumcontract'),  input string(buf_fin-ob.sum-contr), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcCode'),  input string(buf_fin-ob.contract-curr), input 1 ).
  if v-exch-abbr <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcAbbr'),  input string(v-contr-abbr), input 1 ).
  end.
  if v-exch-name <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcname'),  input string(v-contr-name), input 1 ).
  end.
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcRate'),  input string(buf_fin-ob.contract-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcScale'),  input string(buf_fin-ob.contract-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualContractCrcRate'),  input string(buf_fin-ob.actual-contract-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualContractCrcScale'),  input string(buf_fin-ob.actual-contract-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'conSumcontract'),  input string(buf_fin-ob.con-sum-contr), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sumTaxContract'),  input string(buf_fin-ob.sum-tax-contract), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payer'),  input string(buf_fin-ob.payer-type + string(buf_fin-ob.payer-code)), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerName'),  input string(buf_fin-ob.payer-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiver'),  input string(buf_fin-ob.receiver-type + string(buf_fin-ob.receiver-code)), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverName'),  input string(buf_fin-ob.receiver-name), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'comment'),  input string(buf_fin-ob.PS), input 1 ).
run bgelib-tag-close in this-procedure ( input 0, substitute("&1", 'fin-ob')).
for each buf_fin-ob-tax no-lock
    where buf_fin-ob-tax.doc-code  = buf_fin-ob.doc-code
    AND   buf_fin-ob-tax.host-code = buf_fin-ob.host-code
on error undo, return error
:
      run bgelib-tag-open in this-procedure ( input 0, substitute("&1", 'taxLine'),  "" ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DocID'),  input string(buf_fin-ob.doc-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'taxLineNum'),  input string(buf_fin-ob-tax.line-num), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSumDoc'),  input string(buf_fin-ob-tax.sum-line-doc), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSumRubl'),  input string(buf_fin-ob-tax.sum-line-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSumBase'),  input string(buf_fin-ob-tax.sum-line-base), input 1 ).
  if buf_fin-ob.contract-code <> 0 then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSumContr'),  input string(buf_fin-ob-tax.sum-line-contr), input 1 ).
  end.
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVatSumDoc'),  input string(buf_fin-ob-tax.sum-vat-line-doc), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVatSumRubl'),  input string(buf_fin-ob-tax.sum-vat-line-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVatSumBase'),  input string(buf_fin-ob-tax.sum-vat-line-base), input 1 ).
  if buf_fin-ob.contract-code <> 0 then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVatSumContr'),  input string(buf_fin-ob-tax.sum-vat-line-contr), input 1 ).
  end.
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVat'),  input string(buf_fin-ob-tax.vat-pc), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineWithVat'),  input string((if buf_fin-ob-tax.with-vat then "yes" else "no")), input 1 ).
  if buf_fin-ob-tax.SLT-pc <> 0 then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSLTSumDoc'),  input string(buf_fin-ob-tax.sum-SLT-line-doc), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSLTSumRubl'),  input string(buf_fin-ob-tax.sum-SLT-line-rubl), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSLTSumBase'),  input string(buf_fin-ob-tax.sum-SLT-line-base), input 1 ).
    if buf_fin-ob.contract-code <> 0 then do:
                  run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSLTSumContr'),  input string(buf_fin-ob-tax.sum-SLT-line-contr), input 1 ).
    end.
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSLT'),  input string(buf_fin-ob-tax.SLT-pc), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineWithSLT'),  input string((if buf_fin-ob-tax.with-SLT then "yes" else "no")), input 1 ).
  end.
      run bgelib-tag-close in this-procedure ( input 0, substitute("&1", 'taxLine')).
end.
for each buf_fin-ob-trn no-lock
    where buf_fin-ob-trn.doc-code  = buf_fin-ob.doc-code
    AND   buf_fin-ob-trn.host-code = buf_fin-ob.host-code
on error undo, return error
:
      run bgelib-tag-open in this-procedure ( input 0, substitute("&1", 'finObTrn'),  "" ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DocID'),  input string(buf_fin-ob.doc-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'TrnDocId'),  input string(buf_fin-ob-trn.trn-doc-code), input 1 ).
  if buf_fin-ob-trn.ps <> "" then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'Comment'),  input string(buf_fin-ob-trn.ps), input 1 ).
  end.
      run bgelib-tag-close in this-procedure ( input 0, substitute("&1", 'finObTrn')).
end.
for each buf_fin-gds-part no-lock
    where buf_fin-gds-part.fin-ob-code  = buf_fin-ob.doc-code
    AND   buf_fin-gds-part.host-code = buf_fin-ob.host-code
on error undo, return error
:
      run bgelib-tag-open in this-procedure ( input 0, substitute("&1", 'finParts'),  "" ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DocID'),  input string(buf_fin-gds-part.fin-ob-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'gds-code'),  input string(buf_fin-gds-part.gds-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'doc-qnty'),  input string(buf_fin-gds-part.doc-qnty), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'exch-rate'),  input string(buf_fin-gds-part.exch-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'exch-scale'),  input string(buf_fin-gds-part.exch-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'base-rate'),  input string(buf_fin-gds-part.base-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'base-scale'),  input string(buf_fin-gds-part.base-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fact-date'),  input string(buf_fin-gds-part.fact-date, '99.99.9999'), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fact-qnty'),  input string(buf_fin-gds-part.fact-qnty), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fact-time'),  input string(buf_fin-gds-part.fact-time), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'part-code'),  input string(buf_fin-gds-part.part-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'in-code'),  input string(buf_fin-gds-part.in-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'out-code'),  input string(buf_fin-gds-part.out-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'object'),  input string(buf_fin-gds-part.obj-type + string(buf_fin-gds-part.obj-code)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'other-base'),  input string(buf_fin-gds-part.other-base), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'other-contract'),  input string(buf_fin-gds-part.other-contract), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'other-rubl'),  input string(buf_fin-gds-part.other-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'road-tax-base'),  input string(buf_fin-gds-part.road-tax-base), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'road-tax-contract'),  input string(buf_fin-gds-part.road-tax-contract), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'road-tax-rubl'),  input string(buf_fin-gds-part.road-tax-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'status_dop'),  input string(buf_fin-gds-part.status_dop), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-base'),  input string(buf_fin-gds-part.sum-base), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-contract'),  input string(buf_fin-gds-part.sum-contract), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-rubl'),  input string(buf_fin-gds-part.sum-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'transport-base'),  input string(buf_fin-gds-part.transport-base), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'transport-contract'),  input string(buf_fin-gds-part.transport-contract), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'transport-rubl'),  input string(buf_fin-gds-part.transport-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'user-db-num'),  input string(buf_fin-gds-part.user-db-num), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'user-name'),  input string(buf_fin-gds-part.user-name), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'vat-pc'),  input string(buf_fin-gds-part.vat-pc), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'vat-type'),  input string(buf_fin-gds-part.vat-type), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'vat-rubl'),  input string(buf_fin-gds-part.vat-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'vat-base'),  input string(buf_fin-gds-part.vat-base), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'vat-contract'),  input string(buf_fin-gds-part.vat-contract), input 1 ).
  if buf_fin-gds-part.SLT-pc <> 0 then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'SLT-pc'),  input string(buf_fin-gds-part.SLT-pc), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'SLT-type'),  input string(buf_fin-gds-part.SLT-type), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'slt-rubl'),  input string(buf_fin-gds-part.slt-rubl), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'slt-base'),  input string(buf_fin-gds-part.slt-base), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'slt-contract'),  input string(buf_fin-gds-part.slt-contract), input 1 ).
  end.
      run bgelib-tag-close in this-procedure ( input 0, substitute("&1", 'finParts')).
end.
for each buf_fin-connect no-lock
    where buf_fin-connect.fin-ob-code  = buf_fin-ob.doc-code
    AND   buf_fin-connect.host-code = buf_fin-ob.host-code
on error undo, return error
:
      run bgelib-tag-open in this-procedure ( input 0, substitute("&1", 'finConnect'),  "" ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'DocID'),  input string(buf_fin-connect.fin-ob-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'PS'),  input string(buf_fin-connect.PS), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'base-rate'),  input string(buf_fin-connect.base-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'base-scale'),  input string(buf_fin-connect.base-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'connect-code'),  input string(buf_fin-connect.connect-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-code'),  input string(buf_fin-connect.contract-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-curr'),  input string(buf_fin-connect.contract-curr), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-rate'),  input string(buf_fin-connect.contract-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contract-scale'),  input string(buf_fin-connect.contract-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'curr-code'),  input string(buf_fin-connect.curr-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'exch-rate'),  input string(buf_fin-connect.exch-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'exch-scale'),  input string(buf_fin-connect.exch-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fact-date'),  input string(buf_fin-connect.fact-date, '99.99.9999'), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fact-time'),  input string(buf_fin-connect.fact-time), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fin-doc-code'),  input string(buf_fin-connect.fin-doc-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'host'),  input string(buf_fin-connect.host-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'status_'),  input string(buf_fin-connect.status_), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-base-ob'),  input string(buf_fin-connect.sum-base-ob), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-base'),  input string(buf_fin-connect.sum-base), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-contr-ob'),  input string(buf_fin-connect.sum-contr-ob), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-contr'),  input string(buf_fin-connect.sum-contr), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-doc'),  input string(buf_fin-connect.sum-doc), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-rubl-ob'),  input string(buf_fin-connect.sum-rubl-ob), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sum-rubl'),  input string(buf_fin-connect.sum-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'user-db-num'),  input string(buf_fin-connect.user-db-num), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'user-name'),  input string(buf_fin-connect.user-name), input 1 ).
      run bgelib-tag-close in this-procedure ( input 0, substitute("&1", 'finConnect')).
end.
    if v-last-file-position = 0
    or seek( stmxmlout ) - v-last-file-position > 1048576
    then do:
      run gbl/chkfree.p (
          input substring( p-xml-file-name, 1, 1 )
          , input 200
          , output v-need-disk-spc
      ) .
      if v-need-disk-spc = yes
      then do:
          run gbl/waitfrsp.w (
              input substring( p-xml-file-name, 1, 1 )
              , input 200
              , output v-cancel
          ) .
          if v-cancel = yes
          then do:
              undo, return error.
          end.
      end.
      assign
          v-last-file-position = seek( stmxmlout )
      .
    end.
    run bgelib-check-file-size in this-procedure (
          input p-xml-file-name + "tmp"
        , output v-need-new-file
    ).
  end.
  output stream stmxmlout close.
end.
end procedure.
