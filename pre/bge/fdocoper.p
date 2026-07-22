block-level on error undo, throw.
define input parameter p-host-code              as integer                 no-undo.
define input parameter p-ext-doc-type           as character               no-undo.
define input parameter p-oper-name              as character               no-undo.
define input parameter p-fact-order-from        like ub.stk-tot.fact-order    no-undo.
define input parameter p-fact-order-to          like ub.stk-tot.fact-order    no-undo.
define input parameter p-doc-type-list          as character               no-undo.
define input parameter p-obj-list               as character               no-undo.
define input parameter p-db-num                 as integer                 no-undo.
define input parameter p-range                  as integer                 no-undo.
define input parameter p-mode                   as character               no-undo.
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
def var vss-workfile    as character no-undo init "$Workfile: fdocoper.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/fdocoper.p $":U .
def var vss-description as character no-undo init "Экспорт финансовых документов".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do
on error undo, return error
:
  define variable v-exists-operation          as logical      no-undo.
  define variable v-doc-date        like ub.trn-doc.doc-date   no-undo.
  define variable v-fact-date       like ub.trn-doc.fact-date  no-undo.
  define variable v-doc-PS          like ub.trn-doc.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-base-name       like ub.currency.curr-name no-undo .
  define variable v-obj-counter     as integer                 no-undo .
  define variable v-last-file-position        as integer       no-undo.
  define buffer buf_currency for ub.currency.
    ASSIGN
    v-exists-operation = NO.
    .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if p-obj-list <> "":U and p-mode <> "":U then do:
      do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
      :
          create temp-obj.
          assign
          temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
          temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
          no-error .
      end.
    end.
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
  define buffer buf_sysconf for ub.sysconf.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-doc-code      as character    no-undo.
  define variable v-exch-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-exch-name       like ub.currency.curr-name no-undo .
  define variable v-contr-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-contr-name       like ub.currency.curr-name no-undo .
  define variable v-contract-prn-code like ub.contract.contract-prn-code no-undo .
  define variable v-contract-date     like ub.contract.contract-date no-undo .
  define buffer buf_fin-doc-tax          for ub.fin-doc-tax.
  define buffer buf_fin-doc              for ub.fin-doc.
  define buffer buf_contract for ub.contract.
  assign
      p-last-xml-file-name    = p-xml-file-name
      p-last-xml-file-number  = p-xml-file-number
  .
  output stream stmxmlout to value( p-xml-file-name + "tmp" ) convert target "1251" append.
  export-documents:
  for each buf_fin-doc no-lock where
          buf_fin-doc.host-code = p-host-code
      AND buf_fin-doc.fact-order >= p-fact-order-from
      AND buf_fin-doc.fact-order <= p-fact-order-to
      AND buf_fin-doc.status_ = 'факт':U
  on error undo, return error
  :
    if buf_fin-doc.obj-type = "":U and buf_fin-doc.obj-code = 0
    and p-mode = "shd":U
    then do:
      find first buf_sysconf no-lock where buf_fin-doc.host-code = buf_sysconf.host-code .
      if buf_sysconf.firm-db-num <> p-db-num then next export-documents.
    end.
    if buf_fin-doc.fin-ext-doc-type <> p-ext-doc-type then next export-documents.
    if buf_fin-doc.obj-type = "":U and buf_fin-doc.obj-code = 0 and not (p-range = 1 or p-range = 2) then next export-documents.
    if buf_fin-doc.obj-code <> 0
    and trim(p-obj-list) <> "":U
    and p-mode <> "":U
    and not can-find(first temp-obj no-lock where
                           temp-obj.obj-type = buf_fin-doc.obj-type
                       and temp-obj.obj-code = buf_fin-doc.obj-code) then  next export-documents.
    if v-need-new-file = yes
    then do:
        output stream stmxmlout close.
        assign
            v-prev-filename = p-xml-file-name
        .
        run bgelib-filename in this-procedure (
              input "findoc"
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
        v-doc-code = string(buf_fin-doc.fin-doc-code)
    .
    if not v-exists-operation
    then do:
        run bgelib-write-edt in this-procedure ( hEDT, 4, "Операция " + string( p-oper-name ) ).
        run bgelib-write-log in this-procedure ( p-log-file-name, 0, "&Line" ).
        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "XML - Вывод операции " + string( p-oper-name ) + " (" + p-ext-doc-type + ")" ).
        assign
            v-exists-operation = yes
        .
    end.
    assign
    v-doc-code  = string(buf_fin-doc.fin-doc-code)
    v-doc-date  = buf_fin-doc.doc-date
    v-fact-date = buf_fin-doc.fact-date
    v-doc-PS    = buf_fin-doc.ps
    .
    run bgelib-write-cnt( hcnt, "   " + string( v-doc-code ) + " от " + string( v-fact-date ) ) .
    process events.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run bgelib-tag-open in this-procedure ( input 0, substitute("&1", 'findoc'),  "" ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentDocID'),  input string(buf_fin-doc.fin-doc-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cashbookid'),  input string(buf_fin-doc.cashbookid), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentCodeOperation'),  input string(buf_fin-doc.fin-ext-doc-type), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentStatus'),  input string(buf_fin-doc.status_), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'host'),  input string(buf_fin-doc.host-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentDocCode'),  input string(buf_fin-doc.prn-doc-code), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'object'),  input string(buf_fin-doc.obj-type + string(buf_fin-doc.obj-code)), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentDateDoc'),  input string(buf_fin-doc.doc-date, '99.99.9999'), input 1 ).
if buf_fin-doc.fact-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentDateFact'),  input string(buf_fin-doc.fact-date, '99.99.9999'), input 1 ).
end.
if buf_fin-doc.pay-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentDatePay'),  input string(buf_fin-doc.pay-date, '99.99.9999'), input 1 ).
end.
if buf_fin-doc.perm-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentDatePermission'),  input string(buf_fin-doc.perm-date, '99.99.9999'), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentDocDBNum'),  input string(buf_fin-doc.user-db-num-doc), input 1 ).
if buf_fin-doc.fact-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentFactDBNum'),  input string(buf_fin-doc.user-db-num-fact), input 1 ).
end.
if buf_fin-doc.pay-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentPayDBNum'),  input string(buf_fin-doc.user-db-num-pl), input 1 ).
end.
if buf_fin-doc.perm-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentPermissionDBNum'),  input string(buf_fin-doc.user-db-num-perm), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentDocUserName'),  input string(buf_fin-doc.user-name-doc), input 1 ).
if buf_fin-doc.fact-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentFactUserName'),  input string(buf_fin-doc.user-name-fact), input 1 ).
end.
if buf_fin-doc.pay-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentPayUserName'),  input string(buf_fin-doc.user-name-pl), input 1 ).
end.
if buf_fin-doc.perm-date <> ? then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentPermissionUserName'),  input string(buf_fin-doc.user-name-perm), input 1 ).
end.
find first buf_currency no-lock where
          buf_currency.curr-code = buf_fin-doc.curr-code no-error .
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
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sumDoc'),  input string(buf_fin-doc.sum-doc), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentCrcCode'),  input string(buf_fin-doc.curr-code), input 1 ).
if v-exch-abbr <> "":U then do:
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentCrcAbbr'),  input string(v-exch-abbr), input 1 ).
end.
if v-exch-name <> "":U then do:
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentCrcname'),  input string(v-exch-name), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentCrcRate'),  input string(buf_fin-doc.exch-rate), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentCrcScale'),  input string(buf_fin-doc.exch-scale), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualPaymentCrcRate'),  input string(buf_fin-doc.actual-exch-rate), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualPaymentCrcScale'),  input string(buf_fin-doc.actual-exch-scale), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sumRubl'),  input string(buf_fin-doc.sum-rubl), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sumBase'),  input string(buf_fin-doc.sum-base), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcCode'),  input string(v-base-code), input 1 ).
if v-base-abbr <> "":U then do:
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcAbbr'),  input string(v-base-abbr), input 1 ).
end.
if v-base-name <> "":U then do:
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcname'),  input string(v-base-name), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcRate'),  input string(buf_fin-doc.base-rate), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'baseCrcScale'),  input string(buf_fin-doc.base-scale), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualBaseCrcRate'),  input string(buf_fin-doc.actual-base-rate), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualBaseCrcScale'),  input string(buf_fin-doc.actual-base-scale), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'conStat'),  input string(buf_fin-doc.con-stat), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'conSumBase'),  input string(buf_fin-doc.con-sum-base), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'conSumRubl'),  input string(buf_fin-doc.con-sum-rubl), input 1 ).
if buf_fin-doc.contract-code <> 0 then do:
  find first buf_contract no-lock where
            buf_contract.contract-code = buf_fin-doc.contract-code no-error .
  if available buf_contract then
  assign
  v-contract-prn-code = buf_contract.contract-prn-code
  v-contract-date     = buf_contract.contract-date
  .
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCode'),  input string(buf_fin-doc.contract-code), input 1 ).
  if v-contract-prn-code <> "":U then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractNo'),  input string(v-contract-prn-code), input 1 ).
  end.
  if v-contract-date <> ? then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractDate'),  input string(v-contract-date, '99.99.9999'), input 1 ).
  end.
  find first buf_currency no-lock where
            buf_currency.curr-code = buf_fin-doc.contract-curr no-error .
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
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'sumcontract'),  input string(buf_fin-doc.sum-contr), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcCode'),  input string(buf_fin-doc.contract-curr), input 1 ).
  if v-exch-abbr <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcAbbr'),  input string(v-contr-abbr), input 1 ).
  end.
  if v-exch-name <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcname'),  input string(v-contr-name), input 1 ).
  end.
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcRate'),  input string(buf_fin-doc.contract-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'contractCrcScale'),  input string(buf_fin-doc.contract-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualContractCrcRate'),  input string(buf_fin-doc.actual-contract-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'actualContractCrcScale'),  input string(buf_fin-doc.actual-contract-scale), input 1 ).
end.
if buf_fin-doc.an-uchet-code <> 0 then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'analiticCode'),  input string(buf_fin-doc.an-uchet-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'analiticCodeValue'),  input string(buf_fin-doc.an-uchet-value), input 1 ).
end.
if buf_fin-doc.cel-nazn-code <> 0 then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'destinationCode'),  input string(buf_fin-doc.cel-nazn-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'destinationCodeValue'),  input string(buf_fin-doc.cel-nazn-value), input 1 ).
end.
if buf_fin-doc.cor-acc <> 0 then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'corAccCode'),  input string(buf_fin-doc.cor-acc), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'corAccCodeValue'),  input string(buf_fin-doc.cor-acc-value), input 1 ).
end.
if buf_fin-doc.cor-acc1 <> 0 then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'corAcc1Code'),  input string(buf_fin-doc.cor-acc1), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'corAcc1CodeValue'),  input string(buf_fin-doc.cor-acc1-value), input 1 ).
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentPurpose'),  input string(replace(buf_fin-doc.naznach-plat, "@", "":U)), input 1 ).
if buf_fin-doc.fin-doc-type = 'пко':U
or buf_fin-doc.fin-doc-type = 'рко':U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'enclosure'),  input string(buf_fin-doc.enclosure), input 1 ).
end.
if buf_fin-doc.fin-doc-type = 'пко':U
or buf_fin-doc.fin-doc-type = 'рко':U
or buf_fin-doc.fin-doc-type = 'апп':U
or buf_fin-doc.fin-doc-type = 'апр':U
then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'strDepart'),  input string(buf_fin-doc.str-podr-type + string(buf_fin-doc.str-podr-code)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'strDepartName'),  input string(buf_fin-doc.str-podr-name), input 1 ).
end.
if buf_fin-doc.fin-doc-type = 'апп':U
or buf_fin-doc.fin-doc-type = 'апр':U then do:
  if num-entries(buf_fin-doc.payer-sign1, chr(4)) > 1 then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fromPayerHeadPosition'),  input string(entry(1, buf_fin-doc.payer-sign1, chr(4))), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fromPayer'),  input string(entry(2, buf_fin-doc.payer-sign1, chr(4))), input 1 ).
  end.
  else do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fromPayer'),  input string(buf_fin-doc.payer-sign1), input 1 ).
  end.
  if num-entries(buf_fin-doc.receiver-sign1, chr(4)) > 1 then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fromReceiverHeadPosition'),  input string(entry(1, buf_fin-doc.receiver-sign1, chr(4))), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fromReceiver'),  input string(entry(2, buf_fin-doc.receiver-sign1, chr(4))), input 1 ).
  end.
  else do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'fromReceiver'),  input string(buf_fin-doc.receiver-sign1), input 1 ).
  end.
end.
if buf_fin-doc.fin-doc-type = 'пко':U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'seniorAccounter'),  input string(buf_fin-doc.receiver-sign2), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cashier'),  input string(buf_fin-doc.receiver-sign3), input 1 ).
end.
if buf_fin-doc.fin-doc-type = 'рко':U then do:
  if num-entries(buf_fin-doc.payer-sign1, chr(4)) > 1 then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerHeadPosition'),  input string(entry(1, buf_fin-doc.payer-sign1, chr(4))), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerDirector'),  input string(entry(2, buf_fin-doc.payer-sign1, chr(4))), input 1 ).
  end.
  else do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerDirector'),  input string(buf_fin-doc.payer-sign1), input 1 ).
  end.
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'seniorAccounter'),  input string(buf_fin-doc.payer-sign2), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cashier'),  input string(buf_fin-doc.payer-sign3), input 1 ).
end.
if buf_fin-doc.fin-doc-type = 'ппп':U
or buf_fin-doc.fin-doc-type = 'рпп':U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerDirector'),  input string(buf_fin-doc.payer-sign1), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'seniorAccounter'),  input string(buf_fin-doc.payer-sign2), input 1 ).
end.
if buf_fin-doc.fin-doc-type = 'пко':U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'including'),  input string(replace(buf_fin-doc.including, "@":U, "":U)), input 1 ).
end.
if buf_fin-doc.fin-doc-type = 'ппп':U
or buf_fin-doc.fin-doc-type = 'рпп':U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentQueue'),  input string(buf_fin-doc.ocher-pl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentPurposeCode'),  input string(buf_fin-doc.nazn-pl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'f22'),  input string(buf_fin-doc.f23), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'f23ReservField'),  input string(buf_fin-doc.f23), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'operationType'),  input string(buf_fin-doc.vid-opl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentType'),  input string(buf_fin-doc.vid-plat), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentTerm'),  input string(buf_fin-doc.srok-pl), input 1 ).
  if buf_fin-doc.stat-pl <> "":U then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'taxPayerStatus'),  input string(buf_fin-doc.stat-pl), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'KBK'),  input string(buf_fin-doc.f104), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'OKATO'),  input string(buf_fin-doc.f105), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'taxPaymentBase'),  input string(buf_fin-doc.f106), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'taxPeriod'),  input string(buf_fin-doc.f107), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'taxDocumentNo'),  input string(buf_fin-doc.f108), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'taxDocumentDAte'),  input string(buf_fin-doc.f109), input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'taxPaymentType'),  input string(buf_fin-doc.f110), input 1 ).
  end.
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payer'),  input string(buf_fin-doc.payer-type + string(buf_fin-doc.payer-code)), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerName'),  input string(buf_fin-doc.payer-name), input 1 ).
if buf_fin-doc.fin-doc-type = 'ппп':U
or buf_fin-doc.fin-doc-type = 'рпп':U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerINN'),  input string(buf_fin-doc.payer-INN), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerKPP'),  input string(buf_fin-doc.payer-KPP), input 1 ).
  if false then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerOKPO'),  input string(buf_fin-doc.payer-OKPO), input 1 ).
  end.
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerBankName'),  input string((buf_fin-doc.payer-bank-name + chr(44) + chr(32) + buf_fin-doc.payer-bank-city)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerBIK'),  input string(buf_fin-doc.payer-bIK), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerAccountCode'),  input string(buf_fin-doc.payer-code-schet), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerAccount'),  input string(buf_fin-doc.payer-r-schet), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerCorrAccount'),  input string(buf_fin-doc.payer-c-schet), input 1 ).
end.
if buf_fin-doc.payer-dop1 <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerAddInfo1'),  input string(buf_fin-doc.payer-dop1), input 1 ).
end.
if buf_fin-doc.payer-dop2 <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerAddInfo2'),  input string(buf_fin-doc.payer-dop2), input 1 ).
end.
if buf_fin-doc.payer-dop3 <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerAddInfo3'),  input string(buf_fin-doc.payer-dop3), input 1 ).
end.
if buf_fin-doc.payer-dop4 <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerAddInfo4'),  input string(buf_fin-doc.payer-dop4), input 1 ).
end.
if buf_fin-doc.fin-doc-type = 'пко':U
or buf_fin-doc.fin-doc-type = 'рко':U then do:
  if buf_fin-doc.payer-passport <> "":U then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'payerPassport'),  input string(buf_fin-doc.payer-passport), input 1 ).
  end.
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiver'),  input string(buf_fin-doc.receiver-type + string(buf_fin-doc.receiver-code)), input 1 ).
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverName'),  input string(buf_fin-doc.receiver-name), input 1 ).
if buf_fin-doc.fin-doc-type = 'ппп':U
or buf_fin-doc.fin-doc-type = 'рпп':U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverINN'),  input string(buf_fin-doc.receiver-INN), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverKPP'),  input string(buf_fin-doc.receiver-KPP), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverBankName'),  input string((buf_fin-doc.receiver-bank-name + chr(44) + chr(32) + buf_fin-doc.receiver-bank-city)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverBIK'),  input string(buf_fin-doc.receiver-bIK), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverAccountCode'),  input string(buf_fin-doc.receiver-code-schet), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverAccount'),  input string(buf_fin-doc.receiver-r-schet), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverCorrAccount'),  input string(buf_fin-doc.receiver-c-schet), input 1 ).
end.
if buf_fin-doc.fin-doc-type = 'пко':U or buf_fin-doc.fin-doc-type = 'апп':U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverOKPO'),  input string(buf_fin-doc.receiver-OKPO), input 1 ).
end.
if buf_fin-doc.receiver-dop1 <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverAddInfo1'),  input string(buf_fin-doc.receiver-dop1), input 1 ).
end.
if buf_fin-doc.receiver-dop2 <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverAddInfo2'),  input string(buf_fin-doc.receiver-dop2), input 1 ).
end.
if buf_fin-doc.receiver-dop3 <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverAddInfo3'),  input string(buf_fin-doc.receiver-dop3), input 1 ).
end.
if buf_fin-doc.receiver-dop4 <> "":U then do:
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverAddInfo4'),  input string(buf_fin-doc.receiver-dop4), input 1 ).
end.
if buf_fin-doc.fin-doc-type = 'пко':U
or buf_fin-doc.fin-doc-type = 'рко':U then do:
  if buf_fin-doc.receiver-passport <> "":U then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'receiverPassport'),  input string(buf_fin-doc.receiver-passport), input 1 ).
  end.
end.
run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'comment'),  input string(buf_fin-doc.PS), input 1 ).
run bgelib-tag-close in this-procedure ( input 0, substitute("&1", 'findoc')).
for each buf_fin-doc-tax no-lock
    where buf_fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code
    AND   buf_fin-doc-tax.host-code = buf_fin-doc.host-code
on error undo, return error
:
      run bgelib-tag-open in this-procedure ( input 0, substitute("&1", 'taxLine'),  "" ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'paymentDocID'),  input string(buf_fin-doc.fin-doc-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'cashbookid'),  input string(buf_fin-doc.cashbookid), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'taxLineNum'),  input string(buf_fin-doc-tax.line-num), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSumDoc'),  input string(buf_fin-doc-tax.sum-line-doc), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSumRubl'),  input string(buf_fin-doc-tax.sum-line-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSumBase'),  input string(buf_fin-doc-tax.sum-line-base), input 1 ).
  if buf_fin-doc.contract-code <> 0 then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineSumContr'),  input string(buf_fin-doc-tax.sum-line-contr), input 1 ).
  end.
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVatSumDoc'),  input string(buf_fin-doc-tax.sum-vat-line-doc), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVatSumRubl'),  input string(buf_fin-doc-tax.sum-vat-line-rubl), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVatSumBase'),  input string(buf_fin-doc-tax.sum-vat-line-base), input 1 ).
  if buf_fin-doc.contract-code <> 0 then do:
            run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVatSumContr'),  input string(buf_fin-doc-tax.sum-vat-line-contr), input 1 ).
  end.
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineVat'),  input string(buf_fin-doc-tax.vat-pc), input 1 ).
      run bgelib-tag-put in this-procedure ( input 1, input substitute('&1', 'lineWithVat'),  input string((if buf_fin-doc-tax.with-vat then "yes" else "no")), input 1 ).
      run bgelib-tag-close in this-procedure ( input 0, substitute("&1", 'taxLine')).
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
