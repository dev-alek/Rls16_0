block-level on error undo, throw.
define input parameter p-host-code              as character               no-undo.
define input parameter p-obj-type               as character               no-undo.
define input parameter p-obj-code               as integer                 no-undo.
define input parameter p-ext-doc-type           as character               no-undo.
define input parameter p-oper-name              as character               no-undo.
define input parameter p-fact-order-from        like ub.stk-tot.fact-order    no-undo.
define input parameter p-fact-order-to          like ub.stk-tot.fact-order    no-undo.
define input parameter p-pay-code               as logical                 no-undo.
define input parameter p-cst                    as logical                 no-undo.
define input parameter p-parts                  as logical                 no-undo.
define input parameter p-chk-pay-code           as logical                 no-undo.
define input parameter p-pay-desk               as logical                 no-undo.
define input parameter p-pay-desk-cards         as logical                 no-undo.
define input parameter p-obj-list               as character               no-undo.
define input parameter p-doc-type-list          as character               no-undo.
define input parameter p-parameter-list         as character               no-undo.
define input parameter p-xml-file-name          as character               no-undo.
define input parameter p-log-file-name          as character               no-undo.
define input parameter p-list-file-name         as character               no-undo.
define input parameter p-xml-file-number        as integer                 no-undo.
define input parameter p-parent-handle          as handle                  no-undo.
define input parameter hEDT                     as handle                  no-undo.
define input parameter hCNT                     as handle                  no-undo.
define output parameter p-last-xml-file-name    as character               no-undo.
define output parameter p-last-xml-file-number  as integer                 no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: docoper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/docoper.p $":U .
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
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
    define variable v-qnty                      like ub.ot-tot.fact-qnty   no-undo.
    define variable v-doc-date                  like ub.trn-doc.doc-date   no-undo.
    define variable v-fact-date                 like ub.trn-doc.fact-date  no-undo.
    define variable v-pay-code                  like ub.trn-doc.fact-date  no-undo.
    define variable v-reason-code               as integer              no-undo.
    define variable v-doc-PS                    like ub.trn-doc.PS         no-undo.
    define variable v-exists-operation          as logical      no-undo.
    define variable v-exists-sale_ot-supp-tot   as logical      no-undo.
    define variable v-is-petrol                 as logical      no-undo.
    define variable v-is-pieces                 as logical      no-undo.
    define variable v-petrol-weight             as decimal      no-undo.
    define variable v-petrol-density            as decimal      no-undo.
    define variable v-weight-not-specified      as logical      no-undo.
    define variable v-host-code                 as integer       no-undo.
    define variable v-base-code                 as integer       no-undo.
    define variable v-is-out                    as integer       no-undo.
    define variable v-inkas-pay-desk-type       like ub.inkas-pay-desk.doc-type no-undo.
    define variable v-last-file-position        as integer       no-undo.
    define variable v-curr-r-b                  as character      no-undo.
    define temp-table temp_inkas-pay no-undo
        field pay-code  like ub.inkas-pay.pay-code
        field tot-base  like ub.inkas-pay.tot-base
        field tot-rubl  like ub.inkas-pay.tot-rubl
        field tot-sum   like ub.inkas-pay.tot-sum
    index pi is primary unique pay-code
    .
    define temp-table temp_cost_cat-id_ot-supp-tot  no-undo
        field cat-id as character
        index pi is primary unique cat-id
    .
    define temp-table temp_cost_cli_ot-supp-tot     no-undo
        field cat-id            as character
        field cli-type          as character
        field cli-code          as integer
        field sum-rubl          as decimal
        field vat-rubl          as decimal
        field slt-rubl          as decimal
        field road-tax-rubl     as decimal
        field transport-rubl    as decimal
        field other-rubl        as decimal
        field excise-rubl       as decimal
        field sum-base          as decimal
        field vat-base          as decimal
        field slt-base          as decimal
        field road-tax-base     as decimal
        field transport-base    as decimal
        field other-base        as decimal
        field excise-base       as decimal
        field fact-qnty         as decimal
        index pi is primary unique cat-id cli-type cli-code
    .
    define temp-table temp_cost_cat-id_ot-supp-line no-undo
        field artic     as character
        field prod-type as character
        field prod-code as integer
        field cat-id    as character
        index pi is primary unique artic prod-type prod-code cat-id
    .
    define temp-table temp_cost_cli_ot-supp-line    no-undo
        field artic             as character
        field prod-type         as character
        field prod-code         as integer
        field cat-id            as character
        field cli-type          as character
        field cli-code          as integer
        field sum-rubl          as decimal
        field vat-rubl          as decimal
        field slt-rubl          as decimal
        field road-tax-rubl     as decimal
        field transport-rubl    as decimal
        field other-rubl        as decimal
        field excise-rubl       as decimal
        field sum-base          as decimal
        field vat-base          as decimal
        field slt-base          as decimal
        field road-tax-base     as decimal
        field transport-base    as decimal
        field other-base        as decimal
        field excise-base       as decimal
        field fact-qnty         as decimal
        index pi is primary unique artic prod-type prod-code cat-id cli-type cli-code
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-cpa-pcep no-undo
field cdpay-code like ub.cash-pay.cdpay-code
field curr-code like ub.cash-pay.cdpay-code
field prefix as character
index pi is primary
cdpay-code
curr-code
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cpapcep:
define variable ii as integer no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_temp-cpa-pcep for temp-cpa-pcep.
  do
  on error undo, return error
  :
     for each buf_cash-pay-attr no-lock where
            buf_Cash-pay-attr.attr-code = 'paycard-export-prefix':U:
       do ii = 1 to num-entries(buf_Cash-pay-attr.attr-value):
        create buf_temp-cpa-pcep.
        assign
        buf_temp-cpa-pcep.cdpay-code = buf_cash-pay-attr.cdpay-code
        buf_temp-cpa-pcep.curr-code = buf_cash-pay-attr.curr-code
        buf_temp-cpa-pcep.prefix = entry(ii, buf_Cash-pay-attr.attr-value)
        .
      end.
    end.
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS
  unique
  primary
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
        gds-code
        pay-desk
        cpay-code
        curr-code
        prefix
        is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-4 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
do
on error undo, return error
:
    ASSIGN
    v-exists-operation = NO.
    .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
    run cpapcep in this-procedure .
    RUN bgelib-write-cnt( hCNT, "" ).
    assign
        p-last-xml-file-name = p-xml-file-name
    .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
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
    define variable v-doc-code      as character    no-undo.
    define variable v-good-code     as character      no-undo.
    define variable v-good-type     as character      no-undo.
    define variable v-obj-type      as character    no-undo.
    define variable v-obj-code      as integer      no-undo.
    define variable v-fact-order    as decimal      no-undo.
    define variable v-sys-date      as date         no-undo.
    define variable v-sys-time      as character    no-undo.
    define variable v-exists-before as logical      no-undo.
    define variable v-exists-after  as logical      no-undo.
    define variable v-supp-dog-code     as character    no-undo.
    define variable v-supp-ndog         as character    no-undo.
    define variable v-supp-ddog         as character    no-undo.
    define variable v-need-new-file  as logical     no-undo.
    define variable v-need-disk-spc  as logical     no-undo.
    define variable v-cancel         as logical     no-undo.
    define variable v-prev-filename  as character   no-undo.
    define variable v-void-string    as character   no-undo.
    define variable v-scale-is-empty as logical     no-undo.
    define buffer buf_ot-tot-sale          for ub.ot-tot.
    define buffer buf_ot-tot-cost          for ub.ot-tot.
    define buffer buf_ot-tot-crsa          for ub.ot-tot.
    define buffer buf_ot-tot-crsa-loop     for ub.ot-tot.
    define buffer buf_ot-line-sale         for ub.ot-line.
    define buffer buf_ot-line-cost         for ub.ot-line.
    define buffer buf_ot-line-crsa         for ub.ot-line.
    define buffer buf_ot-line-crsa-loop    for ub.ot-line.
    define buffer buf_cost_ot-supp-line    for ub.ot-supp-line.
    define buffer buf_sale_ot-supp-line    for ub.ot-supp-line.
    define buffer buf_cost_ot-supp-tot     for ub.ot-supp-tot.
    define buffer buf_sale_ot-supp-tot     for ub.ot-supp-tot.
    define buffer buf_doc-line             for ub.doc-line.
    define buffer buf_doc-line-sum         for ub.doc-line-sum.
    define buffer buf_contract             for ub.contract.
    define buffer buf_trn-doc              for ub.trn-doc.
    define buffer buf_price-doc            for ub.price-doc.
    define buffer buf_inkas                for ub.inkas.
    define buffer buf_goods                for ub.goods.
    define buffer buf_units                for ub.units.
    for each temp_cost_cat-id_ot-supp-tot no-lock
    on error undo, return error
    :
        delete temp_cost_cat-id_ot-supp-tot.
    end.
    for each temp_cost_cli_ot-supp-tot no-lock
    on error undo, return error
    :
        delete temp_cost_cli_ot-supp-tot.
    end.
    for each temp_cost_cat-id_ot-supp-line no-lock
    on error undo, return error
    :
        delete temp_cost_cat-id_ot-supp-line.
    end.
    for each temp_cost_cli_ot-supp-line no-lock
    on error undo, return error
    :
        delete temp_cost_cli_ot-supp-line.
    end.
    assign
        p-last-xml-file-name    = p-xml-file-name
        p-last-xml-file-number  = p-xml-file-number
    .
    output stream stmxmlout to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    export-documents-arch:
    for each  buf_ot-tot-crsa-loop no-lock
       where buf_ot-tot-crsa-loop.obj-type     = p-obj-type
         and buf_ot-tot-crsa-loop.obj-code     = p-obj-code
         and buf_ot-tot-crsa-loop.ext-doc-type = p-ext-doc-type
         and buf_ot-tot-crsa-loop.fact-order   > p-fact-order-from
         and buf_ot-tot-crsa-loop.fact-order  <= p-fact-order-to
         and buf_ot-tot-crsa-loop.sum-type     = 'crsa':U
         and buf_ot-tot-crsa-loop.cat-id       = '##,##':U
    on error undo, return error
    :
        assign
            v-supp-dog-code = "":U
            v-supp-ndog     = "":U
            v-supp-ddog     = "":U
        .
        if v-need-new-file = yes
        then do:
            output stream stmxmlout close.
            assign
                v-prev-filename = p-xml-file-name
            .
            run bgelib-filename in this-procedure (
                  input "doc"
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
            v-doc-code      = buf_ot-tot-crsa-loop.doc-code
            v-obj-type      = buf_ot-tot-crsa-loop.obj-type
            v-obj-code      = buf_ot-tot-crsa-loop.obj-code
            v-fact-order    = buf_ot-tot-crsa-loop.fact-order
        .
        case p-ext-doc-type
        :
            when 'ot':U
            then do:
                find first buf_ot-tot-sale no-lock
                     where buf_ot-tot-sale.doc-code = v-doc-code
                       and buf_ot-tot-sale.sum-type = 'crsa':U
                       and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
                no-error.
                if not available buf_ot-tot-sale
                then do:
                    run bgelib-write-log in this-procedure ( p-log-file-name, 1, "Не найден документ переоценки " + string( v-doc-code ) ).
                    next export-documents-arch.
                end.
            end.
            otherwise do:
                find first buf_ot-tot-sale no-lock
                     where buf_ot-tot-sale.doc-code = v-doc-code
                       and buf_ot-tot-sale.sum-type = 'sale':U
                       and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
                no-error.
                if not available buf_ot-tot-sale
                then do:
                    find first buf_ot-tot-sale no-lock
                         where buf_ot-tot-sale.doc-code = v-doc-code
                           and buf_ot-tot-sale.sum-type = 'sasr':U
                           and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
                    no-error.
                end.
                if not available buf_ot-tot-sale
                then do:
                    if buf_ot-tot-crsa-loop.fact-qnty <> 0
                    then do:
                        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "В архивах нет записей sum-type = 'sale':U или 'sasr':U для документа номер " + string( v-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" ).
                    end.
                end.
                else do:
                    if buf_ot-tot-crsa-loop.fact-qnty <> buf_ot-tot-sale.fact-qnty
                    then do:
                        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "Не совпадает фактическое количество для записей архивов sum-type = 'sale':U и 'crsa':U для документа номер " + string( v-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" ).
                    end.
                end.
            end.
        end case.
        if not v-exists-operation
        then do:
            run bgelib-write-edt in this-procedure ( hEDT, 4, "Операция " + string( p-oper-name ) ).
            run bgelib-write-log in this-procedure ( p-log-file-name, 0, "&Line" ).
            run bgelib-write-log in this-procedure ( p-log-file-name, 1, "XML - Вывод операции " + string( p-oper-name ) + " (" + p-ext-doc-type + ")" ).
            assign
                v-exists-operation = yes
            .
        end.
        if p-ext-doc-type <> 'ot':U
        then do:
            find first buf_trn-doc no-lock
                where buf_trn-doc.doc-code = v-doc-code
            no-error.
            if not available buf_trn-doc
            then do:
                run bgelib-write-log in this-procedure (  p-log-file-name,
                                            1,
                                    "*** ERR: *** Не удалось найти документ N "
                                    + string( v-doc-code )
                ).
                assign
                    v-doc-date      = ?
                    v-fact-date     = ?
                    v-reason-code   = 0
                    v-doc-PS        = ""
                .
            end.
            else do:
                if p-ext-doc-type = 'ie':U
                or p-ext-doc-type = 'ap':U
                then  do:
                    if buf_trn-doc.contract-code <> 0
                    then do:
                        assign
                            v-supp-dog-code = string( buf_trn-doc.contract-code )
                        .
                        find first buf_contract no-lock
                             where buf_contract.host-code       = buf_trn-doc.host-code
                               and buf_contract.contract-code   = buf_trn-doc.contract-code
                        no-error.
                        if available buf_contract
                        then do:
                            assign
                                v-supp-ndog          = string( buf_contract.contract-prn-code )
                                v-supp-ddog          = string( buf_contract.contract-date, "99.99.9999" )
                            .
                        end.
                    end.
                end.
                assign
                    v-doc-date      = buf_trn-doc.doc-date
                    v-fact-date     = buf_trn-doc.fact-date
                    v-reason-code   = buf_trn-doc.reason-code
                    v-doc-PS        = buf_trn-doc.ps
                    v-sys-date      = buf_trn-doc.sys-date
                    v-sys-time      = buf_trn-doc.sys-time
                .
            end.
        end.
        else do:
            find first buf_price-doc no-lock
                 where buf_price-doc.doc-num = v-doc-code
            no-error.
            if not available buf_price-doc
            then do:
                run bgelib-write-log in this-procedure (  p-log-file-name,
                                            1,
                                    "*** ERR: *** Не удалось найти документ переоценки N "
                                    + string( v-doc-code )
                ).
                assign
                    v-doc-date      = ?
                    v-fact-date     = ?
                    v-reason-code   = 0
                    v-doc-PS        = ""
                .
            end.
            else do:
                assign
                    v-doc-date      = buf_price-doc.doc-date
                    v-fact-date     = buf_price-doc.fact-date
                    v-reason-code   = 0
                    v-doc-PS        = buf_price-doc.ps
                    v-sys-date      = buf_price-doc.sys-date
                    v-sys-time      = buf_price-doc.sys-time
                .
            end.
        end.
        run bgelib-write-cnt( hcnt, "   " + string( v-doc-code ) + " от " + string( v-fact-date ) ) .
        process events.
        run bgelib-tag-open in this-procedure ( input 0, "doc","" ).
        run bgelib-tag-put in this-procedure ( input 1, input "docID",        input string( v-doc-code                                             ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "codeOperation",      input string( p-ext-doc-type                                         ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "host",               input string( p-host-code                                            ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "store",              input v-obj-type + string( v-obj-code )                               , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "factOrder",          input string( v-fact-order )                   , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sysDate",            input string( v-sys-date, "99.99.9999" )       , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sysTime",            input string( v-sys-time )                     , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "dateDoc",            input string( v-doc-date,"99.99.9999"                                ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "dateFact",           input string( v-fact-date,"99.99.9999"                               ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "valutCode",          input string( v-base-code                                            ), input 0 ).
        if p-ext-doc-type <> 'ot':U
        then do:
            run fill_bgelib_clients in this-procedure (
                  input p-parent-handle
                , input buf_trn-doc.cli-type
                , input buf_trn-doc.cli-code
            ).
            run bgelib-tag-put in this-procedure ( input 1, input "firm",                 input buf_trn-doc.cli-type + string( buf_trn-doc.cli-code ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "extNumber",            input string( buf_trn-doc.ord-num                     ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "outNumber",            input string( buf_trn-doc.ship-num                    ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "outDate",              input string( buf_trn-doc.ship-date,  "99.99.9999"    ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "paymentCode",          input string( buf_trn-doc.pay-code                    ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "InterFirmDocChild",    input string( buf_trn-doc.hold-doc-code-child         ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "InterFirmDocParent",   input string( buf_trn-doc.hold-doc-code-parent        ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "InterFirmObjType",     input string( buf_trn-doc.hold-obj-type               ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "InterFirmObjCode",     input string( buf_trn-doc.hold-obj-code               ), input 0 ).
        end.
        run export-attribute in this-procedure (
              input v-doc-code
            , input 'dov':U
            , input "authority"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input 'nids':U
            , input "suppInDocNo"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input 'dids':U
            , input "suppInDocDate"
        ).
        run bgelib-tag-put in this-procedure ( input 1, input "contractSuppCode" , input v-supp-dog-code , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "contractSuppNo"   , input v-supp-ndog     , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "contractSuppDate" , input v-supp-ddog     , input 0 ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input 'ndog':U
            , input "contractNo"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input 'ddog':U
            , input "contractDate"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input 'nsf':U
            , input "sfNo"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input 'dsf':U
            , input "sfDate"
        ).
        run bgelib-tag-put in this-procedure ( input 1, input "reasonCode"  ,  input v-reason-code  , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "comment"     ,  input v-doc-PS       , input 0 ).
        run bgelib-tag-close in this-procedure ( input 0, input "doc" ).
        if p-ext-doc-type <> 'ot':U
        and p-pay-code = yes
        or ( p-chk-pay-code = yes
        and ( p-ext-doc-type = 'es':U or p-ext-doc-type = 'rs':U ) )
        then do:
            find first buf_trn-doc no-lock
                 where buf_trn-doc.doc-code = v-doc-code
            no-error.
            if not available buf_trn-doc
            then do:
                run bgelib-write-log in this-procedure (  p-log-file-name, 1, "*** ERR: *** Не удалось найти документ N " + string( v-doc-code ) ).
            end.
            else do:
                case p-ext-doc-type :
                    when 'es':U
                    then do:
                        assign
                            v-is-out                = 1
                            v-inkas-pay-desk-type   = 'при':U
                        .
                        find first buf_inkas no-lock
                             where buf_inkas.inkas-code = v-doc-code
                        no-error.
                    end.
                    when 'rs':U
                    then do:
                        assign
                            v-is-out                = -1
                            v-inkas-pay-desk-type   = 'рас':U
                        .
                        find first buf_inkas no-lock
                             where buf_inkas.inkas-code = buf_trn-doc.out-code
                        no-error.
                    end.
                end case.
                if available buf_inkas
                then do:
                    run bge/bgepych2.p (
                          input buf_inkas.inkas-code
                        , input p-ext-doc-type
                        , input p-pay-desk
                        , input p-pay-desk-cards
                        , input yes
                        , input yes
                        , input yes
                    ).
                    if p-pay-code = yes
                    then do:
                        run get-inkas-pay-desk in this-procedure (
                              input buf_inkas.inkas-code
                            , input buf_inkas.obj-type
                            , input buf_inkas.obj-code
                            , input v-inkas-pay-desk-type
                        ) no-error .
                        if error-status:error
                        then do:
                            run bgelib-write-log in this-procedure (  p-log-file-name, 1, "*** ERR: *** Не удалось рассчитать разбивку по кодам оплат по документу N "+ string( v-doc-code ) ).
                        end.
                        for each temp_inkas-pay
                        on error undo, return error
                        :
                            run bgelib-tag-open in this-procedure ( input 0, input "docCass", input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID" , input string( v-doc-code )                        , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( temp_inkas-pay.pay-code )           , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sum"         , input string( v-is-out * temp_inkas-pay.tot-sum ) , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * temp_inkas-pay.tot-base ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * temp_inkas-pay.tot-rubl ), input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0, input "docCass" ).
                        end.
                    end.
                end.
                else do:
                    if p-ext-doc-type = 'es':U
                    or p-ext-doc-type = 'rs':U
                    then do:
                        run bgelib-write-log in this-procedure (  p-log-file-name, 1, "*** ERR: *** Не найден inkas для документа расхода или возврата по кассе N " + string( v-doc-code ) ).
                    end.
                end.
            end.
        end.
        if available buf_ot-tot-sale
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "docSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, "docID"   , input string( v-doc-code )                           , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, "sumr"          , input string( abs( buf_ot-tot-sale.sum-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "VATr"          , input string( abs( buf_ot-tot-sale.vat-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "SLTr"          , input string( abs( buf_ot-tot-sale.slt-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "roadTaxr"      , input string( abs( buf_ot-tot-sale.road-tax-rubl  ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "transportr"    , input string( abs( buf_ot-tot-sale.transport-rubl ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "otherr"        , input string( abs( buf_ot-tot-sale.other-rubl     ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "exciser"       , input string( abs( buf_ot-tot-sale.excise-rubl    ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "sumb"          , input string( abs( buf_ot-tot-sale.sum-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "VATb"          , input string( abs( buf_ot-tot-sale.vat-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "SLTb"          , input string( abs( buf_ot-tot-sale.slt-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "roadTaxb"      , input string( abs( buf_ot-tot-sale.road-tax-base  ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "transportb"    , input string( abs( buf_ot-tot-sale.transport-base ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "otherb"        , input string( abs( buf_ot-tot-sale.other-base     ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "exciseb"       , input string( abs( buf_ot-tot-sale.excise-base    ) ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "docSum" ).
        end.
        if p-ext-doc-type <> 'ot':U
        then do:
            find first buf_ot-tot-cost no-lock
                 where buf_ot-tot-cost.doc-code    = v-doc-code
                   and buf_ot-tot-cost.sum-type    = 'cost':U
                   and buf_ot-tot-cost.cat-id      = '##,##':U
            no-error.
            if not available buf_ot-tot-cost
            then do:
                find first buf_ot-tot-cost no-lock
                     where buf_ot-tot-cost.doc-code    = v-doc-code
                       and buf_ot-tot-cost.sum-type    = 'cssr':U
                       and buf_ot-tot-cost.cat-id      = '##,##':U
                no-error.
            end.
            if available buf_ot-tot-cost
            then do:
                run bgelib-tag-open in this-procedure ( input 0, input "docCostSum", input "" ).
                run bgelib-tag-put in this-procedure ( input 1, "docID", input string( v-doc-code )                           , input 0 ).
                run bgelib-tag-put in this-procedure ( input 1, "sumr"       , input string( abs( buf_ot-tot-cost.sum-rubl       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "VATr"       , input string( abs( buf_ot-tot-cost.vat-rubl       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "SLTr"       , input string( abs( buf_ot-tot-cost.slt-rubl       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "roadTaxr"   , input string( abs( buf_ot-tot-cost.road-tax-rubl  ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "transportr" , input string( abs( buf_ot-tot-cost.transport-rubl ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "otherr"     , input string( abs( buf_ot-tot-cost.other-rubl     ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "exciser"    , input string( abs( buf_ot-tot-cost.excise-rubl    ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "sumb"       , input string( abs( buf_ot-tot-cost.sum-base       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "VATb"       , input string( abs( buf_ot-tot-cost.vat-base       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "SLTb"       , input string( abs( buf_ot-tot-cost.slt-base       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "roadTaxb"   , input string( abs( buf_ot-tot-cost.road-tax-base  ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "transportb" , input string( abs( buf_ot-tot-cost.transport-base ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "otherb"     , input string( abs( buf_ot-tot-cost.other-base     ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "exciseb"    , input string( abs( buf_ot-tot-cost.excise-base    ) ), input 2 ).
                run bgelib-tag-close in this-procedure ( input 0, input "docCostSum" ).
            end.
            else do:
                if available buf_ot-tot-sale
                then do:
                    run bgelib-write-log in this-procedure ( p-log-file-name, 1, "*** ERR: *** В архиве не найдена запись с sum-type = 'cost':U или 'cssr':U для документа " + string( v-doc-code ) ).
                end.
            end.
            for each temp_cost_cat-id_ot-supp-tot no-lock
            on error undo, return error
            :
                delete temp_cost_cat-id_ot-supp-tot.
            end.
            for each temp_cost_cli_ot-supp-tot no-lock
            on error undo, return error
            :
                delete temp_cost_cli_ot-supp-tot.
            end.
            for each buf_cost_ot-supp-tot no-lock
               where buf_cost_ot-supp-tot.doc-code = v-doc-code
            on error undo, return error
            :
                if buf_cost_ot-supp-tot.sum-type = 'cost':U + 'p':U
                then do:
                    find first temp_cost_cat-id_ot-supp-tot
                         where temp_cost_cat-id_ot-supp-tot.cat-id   = buf_cost_ot-supp-tot.cat-id
                    no-error.
                    if not available temp_cost_cat-id_ot-supp-tot
                    then do:
                        create temp_cost_cat-id_ot-supp-tot.
                        assign
                            temp_cost_cat-id_ot-supp-tot.cat-id   = buf_cost_ot-supp-tot.cat-id
                        .
                    end.
                    run fill_bgelib_clients in this-procedure (
                          input p-parent-handle
                        , input buf_cost_ot-supp-tot.cli-type
                        , input buf_cost_ot-supp-tot.cli-code
                    ).
                    find first temp_cost_cli_ot-supp-tot
                         where temp_cost_cli_ot-supp-tot.cat-id   = buf_cost_ot-supp-tot.cat-id
                           and temp_cost_cli_ot-supp-tot.cli-type = buf_cost_ot-supp-tot.cli-type
                           and temp_cost_cli_ot-supp-tot.cli-code = buf_cost_ot-supp-tot.cli-code
                    no-error.
                    if not available temp_cost_cli_ot-supp-tot
                    then do:
                        create temp_cost_cli_ot-supp-tot.
                        assign
                            temp_cost_cli_ot-supp-tot.cat-id            = buf_cost_ot-supp-tot.cat-id
                            temp_cost_cli_ot-supp-tot.cli-type          = buf_cost_ot-supp-tot.cli-type
                            temp_cost_cli_ot-supp-tot.cli-code          = buf_cost_ot-supp-tot.cli-code
                            temp_cost_cli_ot-supp-tot.sum-rubl          = buf_cost_ot-supp-tot.sum-rubl
                            temp_cost_cli_ot-supp-tot.vat-rubl          = buf_cost_ot-supp-tot.vat-rubl
                            temp_cost_cli_ot-supp-tot.slt-rubl          = buf_cost_ot-supp-tot.slt-rubl
                            temp_cost_cli_ot-supp-tot.road-tax-rubl     = buf_cost_ot-supp-tot.road-tax-rubl
                            temp_cost_cli_ot-supp-tot.transport-rubl    = buf_cost_ot-supp-tot.transport-rubl
                            temp_cost_cli_ot-supp-tot.other-rubl        = buf_cost_ot-supp-tot.other-rubl
                            temp_cost_cli_ot-supp-tot.excise-rubl       = buf_cost_ot-supp-tot.excise-rubl
                            temp_cost_cli_ot-supp-tot.sum-base          = buf_cost_ot-supp-tot.sum-base
                            temp_cost_cli_ot-supp-tot.vat-base          = buf_cost_ot-supp-tot.vat-base
                            temp_cost_cli_ot-supp-tot.slt-base          = buf_cost_ot-supp-tot.slt-base
                            temp_cost_cli_ot-supp-tot.road-tax-base     = buf_cost_ot-supp-tot.road-tax-base
                            temp_cost_cli_ot-supp-tot.transport-base    = buf_cost_ot-supp-tot.transport-base
                            temp_cost_cli_ot-supp-tot.other-base        = buf_cost_ot-supp-tot.other-base
                            temp_cost_cli_ot-supp-tot.excise-base       = buf_cost_ot-supp-tot.excise-base
                            temp_cost_cli_ot-supp-tot.fact-qnty         = buf_cost_ot-supp-tot.fact-qnty
                        .
                    end.
                end.
            end.
            for each temp_cost_cat-id_ot-supp-line no-lock
            on error undo, return error
            :
                delete temp_cost_cat-id_ot-supp-line.
            end.
            for each temp_cost_cli_ot-supp-line no-lock
            on error undo, return error
            :
                delete temp_cost_cli_ot-supp-line.
            end.
            for each buf_cost_ot-supp-line no-lock
               where buf_cost_ot-supp-line.doc-code = v-doc-code
            on error undo, return error
            :
                if buf_cost_ot-supp-line.sum-type = 'cost':U + 'p':U
                then do:
                    find first temp_cost_cat-id_ot-supp-line
                         where temp_cost_cat-id_ot-supp-line.artic      = buf_cost_ot-supp-line.artic
                           and temp_cost_cat-id_ot-supp-line.prod-type  = buf_cost_ot-supp-line.prod-type
                           and temp_cost_cat-id_ot-supp-line.prod-code  = buf_cost_ot-supp-line.prod-code
                           and temp_cost_cat-id_ot-supp-line.cat-id     = buf_cost_ot-supp-line.cat-id
                    no-error.
                    if not available temp_cost_cat-id_ot-supp-line
                    then do:
                        create temp_cost_cat-id_ot-supp-line.
                        assign
                            temp_cost_cat-id_ot-supp-line.artic     = buf_cost_ot-supp-line.artic
                            temp_cost_cat-id_ot-supp-line.prod-type = buf_cost_ot-supp-line.prod-type
                            temp_cost_cat-id_ot-supp-line.prod-code = buf_cost_ot-supp-line.prod-code
                            temp_cost_cat-id_ot-supp-line.cat-id    = buf_cost_ot-supp-line.cat-id
                        .
                    end.
                    run fill_bgelib_clients in this-procedure (
                          input p-parent-handle
                        , input buf_cost_ot-supp-line.cli-type
                        , input buf_cost_ot-supp-line.cli-code
                    ).
                    find first temp_cost_cli_ot-supp-line
                         where temp_cost_cli_ot-supp-line.artic      = buf_cost_ot-supp-line.artic
                           and temp_cost_cli_ot-supp-line.prod-type  = buf_cost_ot-supp-line.prod-type
                           and temp_cost_cli_ot-supp-line.prod-code  = buf_cost_ot-supp-line.prod-code
                           and temp_cost_cli_ot-supp-line.cat-id     = buf_cost_ot-supp-line.cat-id
                           and temp_cost_cli_ot-supp-line.cli-type   = buf_cost_ot-supp-line.cli-type
                           and temp_cost_cli_ot-supp-line.cli-code   = buf_cost_ot-supp-line.cli-code
                    no-error.
                    if not available temp_cost_cli_ot-supp-line
                    then do:
                        create temp_cost_cli_ot-supp-line.
                        assign
                            temp_cost_cli_ot-supp-line.artic             = buf_cost_ot-supp-line.artic
                            temp_cost_cli_ot-supp-line.prod-type         = buf_cost_ot-supp-line.prod-type
                            temp_cost_cli_ot-supp-line.prod-code         = buf_cost_ot-supp-line.prod-code
                            temp_cost_cli_ot-supp-line.cat-id            = buf_cost_ot-supp-line.cat-id
                            temp_cost_cli_ot-supp-line.cli-type          = buf_cost_ot-supp-line.cli-type
                            temp_cost_cli_ot-supp-line.cli-code          = buf_cost_ot-supp-line.cli-code
                            temp_cost_cli_ot-supp-line.sum-rubl          = buf_cost_ot-supp-line.sum-rubl
                            temp_cost_cli_ot-supp-line.vat-rubl          = buf_cost_ot-supp-line.vat-rubl
                            temp_cost_cli_ot-supp-line.slt-rubl          = buf_cost_ot-supp-line.slt-rubl
                            temp_cost_cli_ot-supp-line.road-tax-rubl     = buf_cost_ot-supp-line.road-tax-rubl
                            temp_cost_cli_ot-supp-line.transport-rubl    = buf_cost_ot-supp-line.transport-rubl
                            temp_cost_cli_ot-supp-line.other-rubl        = buf_cost_ot-supp-line.other-rubl
                            temp_cost_cli_ot-supp-line.excise-rubl       = buf_cost_ot-supp-line.excise-rubl
                            temp_cost_cli_ot-supp-line.sum-base          = buf_cost_ot-supp-line.sum-base
                            temp_cost_cli_ot-supp-line.vat-base          = buf_cost_ot-supp-line.vat-base
                            temp_cost_cli_ot-supp-line.slt-base          = buf_cost_ot-supp-line.slt-base
                            temp_cost_cli_ot-supp-line.road-tax-base     = buf_cost_ot-supp-line.road-tax-base
                            temp_cost_cli_ot-supp-line.transport-base    = buf_cost_ot-supp-line.transport-base
                            temp_cost_cli_ot-supp-line.other-base        = buf_cost_ot-supp-line.other-base
                            temp_cost_cli_ot-supp-line.excise-base       = buf_cost_ot-supp-line.excise-base
                            temp_cost_cli_ot-supp-line.fact-qnty         = buf_cost_ot-supp-line.fact-qnty
                        .
                    end.
                    else do:
                        run bgelib-write-log in this-procedure (  p-log-file-name,
                                                    1,
                                            "*** WARN: *** Найдено больше одной записи ot-supp-line для документа "
                                            + string( v-doc-code )
                        ).
                    end.
                end.
            end.
        end.
        else do:
        end.
        run bgelib-tag-open in this-procedure ( input 0, input "docSaleSum", input "" ).
        run bgelib-tag-put in this-procedure ( input 1, input "docID" , string( v-doc-code )                                 , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , string( abs( buf_ot-tot-crsa-loop.sum-rubl        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATr"        , string( abs( buf_ot-tot-crsa-loop.vat-rubl        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTr"        , string( abs( buf_ot-tot-crsa-loop.slt-rubl        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"    , string( abs( buf_ot-tot-crsa-loop.road-tax-rubl   ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "transportr"  , string( abs( buf_ot-tot-crsa-loop.transport-rubl  ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "otherr"      , string( abs( buf_ot-tot-crsa-loop.other-rubl      ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "exciser"     , string( abs( buf_ot-tot-crsa-loop.excise-rubl     ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , string( abs( buf_ot-tot-crsa-loop.sum-base        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATb"        , string( abs( buf_ot-tot-crsa-loop.vat-base        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTb"        , string( abs( buf_ot-tot-crsa-loop.slt-base        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"    , string( abs( buf_ot-tot-crsa-loop.road-tax-base   ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "transportb"  , string( abs( buf_ot-tot-crsa-loop.transport-base  ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "otherb"      , string( abs( buf_ot-tot-crsa-loop.other-base      ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "exciseb"     , string( abs( buf_ot-tot-crsa-loop.excise-base     ) ), input 2 ).
        run bgelib-tag-close in this-procedure ( input 0, input "docSaleSum" ).
        if p-ext-doc-type = 'vt':U
        or p-ext-doc-type = 'vp':U
        or p-ext-doc-type = 'ap':U
        or p-ext-doc-type = 'mp':U
        then do:
            run utl/cuaddsum.p (
                input v-doc-code
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** WARN: *** Не удалось проверить документ инвентаризации N: &1. &2. &3. &4"
                                        , v-doc-code
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                    )
                ).
            end.
            run export-before-and-after-inv-trn in this-procedure (
                  input v-doc-code
                , output v-exists-before
                , output v-exists-after
            ).
        end.
        if p-pay-code = yes
        then do:
            for each temp_cost_cat-id_ot-supp-tot
            on error undo, return error
            :
                for each temp_cost_cli_ot-supp-tot
                where temp_cost_cli_ot-supp-tot.cat-id = temp_cost_cat-id_ot-supp-tot.cat-id
                on error undo, return error
                :
                    run fill_bgelib_clients in this-procedure (
                          input p-parent-handle
                        , input temp_cost_cli_ot-supp-tot.cli-type
                        , input temp_cost_cli_ot-supp-tot.cli-code
                    ).
                    run bgelib-tag-open in this-procedure ( input 0, "docPaySupp", "" ).
                    run bgelib-tag-put in this-procedure ( input 1, input "docID" , input string( v-doc-code )                            , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( temp_cost_cat-id_ot-supp-tot.cat-id )   , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "firmType"    , input string( temp_cost_cli_ot-supp-tot.cli-type )    , input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "firmCode"    , input string( temp_cost_cli_ot-supp-tot.cli-code )    , input 2 ).
                    if temp_cost_cli_ot-supp-tot.sum-rubl < 0
                    then do:
                        run bgelib-tag-put in this-procedure ( input 1, input "sign", input "-1", input 0 ).
                    end.
                    run bgelib-tag-put in this-procedure ( input 1, "costSumr"        , input string( abs( temp_cost_cli_ot-supp-tot.sum-rubl         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costVatr"        , input string( abs( temp_cost_cli_ot-supp-tot.vat-rubl         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costSltr"        , input string( abs( temp_cost_cli_ot-supp-tot.slt-rubl         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costRoadtaxr"    , input string( abs( temp_cost_cli_ot-supp-tot.road-tax-rubl    ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costTransportr"  , input string( abs( temp_cost_cli_ot-supp-tot.transport-rubl   ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costOtherr"      , input string( abs( temp_cost_cli_ot-supp-tot.other-rubl       ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costExciser"     , input string( abs( temp_cost_cli_ot-supp-tot.excise-rubl      ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costSumb"        , input string( abs( temp_cost_cli_ot-supp-tot.sum-base         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costVatb"        , input string( abs( temp_cost_cli_ot-supp-tot.vat-base         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costSltb"        , input string( abs( temp_cost_cli_ot-supp-tot.slt-base         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costRoadtaxb"    , input string( abs( temp_cost_cli_ot-supp-tot.road-tax-base    ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costTransportb"  , input string( abs( temp_cost_cli_ot-supp-tot.transport-base   ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costOtherb"      , input string( abs( temp_cost_cli_ot-supp-tot.other-base       ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costExciseb"     , input string( abs( temp_cost_cli_ot-supp-tot.excise-base      ) ), input 2 ).
                    find first buf_sale_ot-supp-tot no-lock
                        where buf_sale_ot-supp-tot.doc-code = v-doc-code
                        and buf_sale_ot-supp-tot.cli-type = temp_cost_cli_ot-supp-tot.cli-type
                        and buf_sale_ot-supp-tot.cli-code = temp_cost_cli_ot-supp-tot.cli-code
                        and buf_sale_ot-supp-tot.sum-type = 'sale':U
                        and buf_sale_ot-supp-tot.cat-id   = '##':U
                    no-error.
                    if available buf_sale_ot-supp-tot
                    then do:
                        if buf_sale_ot-supp-tot.sum-rubl < 0
                        then do:
                            run bgelib-tag-put in this-procedure ( input 1, input "sign", input "-1", input 0 ).
                        end.
                        run bgelib-tag-put in this-procedure ( input 1, input "docSumr"      , input string( abs( buf_sale_ot-supp-tot.sum-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docVatr"      , input string( abs( buf_sale_ot-supp-tot.vat-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docSltr"      , input string( abs( buf_sale_ot-supp-tot.slt-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docRoadtaxr"  , input string( abs( buf_sale_ot-supp-tot.road-tax-rubl  ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docTransportr", input string( abs( buf_sale_ot-supp-tot.transport-rubl ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docOtherr"    , input string( abs( buf_sale_ot-supp-tot.other-rubl     ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docExciser"   , input string( abs( buf_sale_ot-supp-tot.excise-rubl    ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docSumb"      , input string( abs( buf_sale_ot-supp-tot.sum-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docVatb"      , input string( abs( buf_sale_ot-supp-tot.vat-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docSltb"      , input string( abs( buf_sale_ot-supp-tot.slt-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docRoadtaxb"  , input string( abs( buf_sale_ot-supp-tot.road-tax-base  ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docTransportb", input string( abs( buf_sale_ot-supp-tot.transport-base ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docOtherb"    , input string( abs( buf_sale_ot-supp-tot.other-base     ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docExciseb"   , input string( abs( buf_sale_ot-supp-tot.excise-base    ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                    end.
                    run bgelib-tag-close in this-procedure ( input 0,  input "docPaySupp" ).
                end.
            end.
        end.
        for each buf_ot-line-crsa-loop no-lock
           where buf_ot-line-crsa-loop.doc-code = v-doc-code
             and ( buf_ot-line-crsa-loop.sum-type = 'crsa':U
                or buf_ot-line-crsa-loop.sum-type = 'cgsr':U )
        on error undo, return error
        :
            run bgelib-tag-open in this-procedure ( input 0, input "line", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID",  input v-doc-code, input 0 ).
            find first buf_goods no-lock
                 where buf_goods.artic      = buf_ot-line-crsa-loop.artic
                   and buf_goods.prod-type  = buf_ot-line-crsa-loop.prod-type
                   and buf_goods.prod-code  = buf_ot-line-crsa-loop.prod-code
            no-error.
            if available buf_goods
            then do:
                assign
                    v-good-code = string( buf_goods.gds-code )
                    v-good-type = string( buf_goods.gds-type )
                .
                run fill_bgelib_goods in this-procedure (
                      input p-parent-handle
                    , input buf_goods.gds-code
                ).
            end.
            else do:
                assign
                    v-good-code = ""
                    v-good-type = ""
                .
            end.
            run bgelib-tag-put in this-procedure ( input 1, input "goodID",    input v-good-code, input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "type",    input v-good-type, input 0 ).
            find first buf_units no-lock
                 where buf_units.unit-name  = buf_goods.unit-base
            no-error.
            if available buf_units
            then do:
                run bgelib-tag-put in this-procedure ( input 1, input "unitType",    input string( buf_units.type ), input 0 ).
            end.
            else do:
                    run bgelib-tag-put in this-procedure ( input 1, input "unitType",   input "",   input 0 ).
            end.
            if p-ext-doc-type <> 'ot':U
            then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_ot-line-crsa-loop.artic
  ,  input buf_ot-line-crsa-loop.prod-type
  ,  input buf_ot-line-crsa-loop.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
                find first buf_doc-line no-lock
                    where buf_doc-line.doc-code = v-doc-code
                      and buf_doc-line.artic      = buf_ot-line-crsa-loop.artic
                      and buf_doc-line.prod-type  = buf_ot-line-crsa-loop.prod-type
                      and buf_doc-line.prod-code  = buf_ot-line-crsa-loop.prod-code
                no-error.
                if available buf_doc-line
                then do:
                    run bgelib-tag-put in this-procedure ( input 1, input "wait"        , input string( buf_doc-line.wt-brutto      ), input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "place"       , input string( buf_doc-line.num-place      ), input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "priceCli"    , input string( buf_doc-line.price-cli      ), input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "cliBaseRate" , input string( buf_doc-line.cli-base-rate  ), input 0 ).
                    if v-is-petrol  = yes
                    and v-is-pieces = no
                    then do:
                        run get-petrol-weight in this-procedure
                        (
                              input p-ext-doc-type
                            , input recid( buf_doc-line )
                            , input buf_trn-doc.out-code
                            , output v-petrol-weight
                            , output v-weight-not-specified
                        ).
                        if v-weight-not-specified = no
                        then do:
                            assign
                                v-petrol-density = ( if buf_ot-line-crsa-loop.fact-qnty = 0
                                                        then 0
                                                        else v-petrol-weight / buf_ot-line-crsa-loop.fact-qnty )
                            .
                            run bgelib-tag-put in this-procedure ( input 1, input "petrolWeight", input string( v-petrol-weight ), input 0 ).
                        end.
                    end.                                   define variable v-before-qnty      as decimal      no-undo.
                    define variable v-after-qnty       as decimal      no-undo.
                    define variable v-diff-qnty        as decimal      no-undo.
                    define variable v-abs-diff-qnty    as decimal      no-undo.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_getwtqty in g#lib-trn3 (  input buf_doc-line.doc-code ,
                        input buf_doc-line.artic ,
                        input buf_doc-line.prod-type ,
                        input buf_doc-line.prod-code ,
                       output v-before-qnty ,
                       output v-after-qnty ,
                       output v-diff-qnty ,
                       output v-abs-diff-qnty ) no-error.
                    if error-status :error
                    then do:
                        run bgelib-write-log in this-procedure (
                              input p-log-file-name
                            , input 1
                            , input substitute( "*** ERR: *** Ошибка вычисления количеств до и после для топлива. Документ &1. Товар &2 &3 &4. &5. &6. &7. &8."
                                                    , buf_doc-line.doc-code
                                                    , buf_doc-line.artic
                                                    , buf_doc-line.prod-type
                                                    , buf_doc-line.prod-code
                                                    , return-value
                                                    , trim(error-status :get-message(1))
                                                    , trim(error-status :get-message(2))
                                                    , trim(error-status :get-message(3)) )
                        ).
                    end.
                    else do:
                        run bgelib-tag-put in this-procedure ( input 4, input "petrolBeforeQnty"  , input string( v-before-qnty     ), input 1 ).
                        run bgelib-tag-put in this-procedure ( input 4, input "petrolAfterQnty"   , input string( v-after-qnty      ), input 1 ).
                        run bgelib-tag-put in this-procedure ( input 4, input "petrolDiffQnty"    , input string( v-diff-qnty       ), input 1 ).
                        run bgelib-tag-put in this-procedure ( input 4, input "petrolAbsDiffQnty" , input string( v-abs-diff-qnty   ), input 1 ).
                    end.
                end.
                else do:
                    run bgelib-write-log in this-procedure (
                          input p-log-file-name
                        , input 1
                        , input substitute( "*** ERR: *** Не найдена строка документа &1. Товар &2 &3 &4."
                                            , v-doc-code
                                            , buf_ot-line-crsa-loop.artic
                                            , buf_ot-line-crsa-loop.prod-type
                                            , buf_ot-line-crsa-loop.prod-code
                                           )
                    ).
                end.
            end.
            else do:
            end.
            if p-ext-doc-type = 'vt':U
            or p-ext-doc-type = 'vp':U
            or p-ext-doc-type = 'ap':U
            or p-ext-doc-type = 'mp':U
            then do:
                assign
                    v-qnty = buf_ot-line-crsa-loop.fact-qnty
                .
            end.
            else do:
                assign
                    v-qnty = abs( buf_ot-line-crsa-loop.fact-qnty )
                .
            end.
            run bgelib-tag-put in this-procedure ( input 1, input "qnty", input string( v-qnty )  , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "comment" , input string( buf_goods.ps ), input 0 ).
            run bgelib-tag-close in this-procedure ( input 0, input "line" ).
            if p-ext-doc-type <> 'ot':U
            then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'empty-scale=request':u
  ,output v-scale-is-empty
  )  .
                if v-scale-is-empty = no
                then do:
                    run export-gds-dtl in this-procedure (
                          input p-ext-doc-type
                        , input v-doc-code
                        , input buf_goods.gds-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                    ) no-error.
                    if error-status :error
                    then do:
                        run bgelib-write-log in this-procedure (
                              input p-log-file-name
                            , input 1
                            , input substitute( "*** ERR: *** Ошибка выгрузки признаков." )
                        ).
                    end.
                end.
                if p-cst = yes
                or p-parts = yes
                then do:
                    run export-parts in this-procedure (
                          input v-doc-code
                        , input ( if available buf_goods then buf_goods.gds-code else 0 )
                        , input buf_ot-line-crsa-loop.obj-type
                        , input buf_ot-line-crsa-loop.obj-code
                        , input buf_ot-line-crsa-loop.prod-type
                        , input buf_ot-line-crsa-loop.prod-code
                        , input buf_ot-line-crsa-loop.artic
                    ).
                end.
                if p-chk-pay-code = yes
                then do:
                    run export-chk-pay-code in this-procedure (
                          input recid( buf_doc-line )
                        , input v-doc-code
                        , input buf_trn-doc.out-code
                        , input v-is-petrol
                        , input v-is-pieces
                        , input buf_goods.gds-code
                        , input buf_goods.gds-type
                    ).
                end.
            end.
            else do:
            end.
            if available buf_ot-tot-sale
            then do:
                find first buf_ot-line-sale no-lock
                     where buf_ot-line-sale.doc-code    = v-doc-code
                       and buf_ot-line-sale.artic       = buf_ot-line-crsa-loop.artic
                       and buf_ot-line-sale.prod-type   = buf_ot-line-crsa-loop.prod-type
                       and buf_ot-line-sale.prod-code   = buf_ot-line-crsa-loop.prod-code
                       and buf_ot-line-sale.sum-type    = buf_ot-tot-sale.sum-type
                no-error.
                if available buf_ot-line-sale
                then do:
                    run bgelib-tag-open in this-procedure ( input 0, input "lineDocSum", input "" ).
                    run bgelib-tag-put in this-procedure ( input 1, input "docID" , input v-doc-code                                      , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "goodID"        , input v-good-code                                     , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "rateVAT"     , input string( entry( 1, buf_ot-line-sale.cat-id ) )   , input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "rateSLT"     , input string( entry( 2, buf_ot-line-sale.cat-id ) )   , input 2 ).
                    if p-ext-doc-type = 'ot':U
                    then do:
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"      , input string( buf_ot-line-sale.sum-rubl         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATr"      , input string( buf_ot-line-sale.vat-rubl         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"      , input string( buf_ot-line-sale.slt-rubl         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"  , input string( buf_ot-line-sale.road-tax-rubl    ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportr", input string( buf_ot-line-sale.transport-rubl   ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherr"    , input string( buf_ot-line-sale.other-rubl       ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciser"   , input string( buf_ot-line-sale.excise-rubl      ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"      , input string( buf_ot-line-sale.sum-base         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATb"      , input string( buf_ot-line-sale.vat-base         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"      , input string( buf_ot-line-sale.slt-base         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"  , input string( buf_ot-line-sale.road-tax-base    ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportb", input string( buf_ot-line-sale.transport-base   ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherb"    , input string( buf_ot-line-sale.other-base       ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"   , input string( buf_ot-line-sale.excise-base      ), input 2 ).
                    end.
                    else do:
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"      , input string( abs( buf_ot-line-sale.sum-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATr"      , input string( abs( buf_ot-line-sale.vat-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"      , input string( abs( buf_ot-line-sale.slt-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"  , input string( abs( buf_ot-line-sale.road-tax-rubl  ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportr", input string( abs( buf_ot-line-sale.transport-rubl ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherr"    , input string( abs( buf_ot-line-sale.other-rubl     ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciser"   , input string( abs( buf_ot-line-sale.excise-rubl    ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"      , input string( abs( buf_ot-line-sale.sum-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATb"      , input string( abs( buf_ot-line-sale.vat-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"      , input string( abs( buf_ot-line-sale.slt-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"  , input string( abs( buf_ot-line-sale.road-tax-base  ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportb", input string( abs( buf_ot-line-sale.transport-base ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherb"    , input string( abs( buf_ot-line-sale.other-base     ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"   , input string( abs( buf_ot-line-sale.excise-base    ) ), input 2 ).
                    end.
                    run bgelib-tag-close in this-procedure ( input 0, input "lineDocSum" ).
                end.
                else do:
                end.
            end.
            if p-ext-doc-type <> 'ot':U
            then do:
                if available buf_ot-tot-cost
                then do:
                    find first buf_ot-line-cost no-lock
                            where buf_ot-line-cost.doc-code   = v-doc-code
                            and buf_ot-line-cost.artic      = buf_ot-line-crsa-loop.artic
                            and buf_ot-line-cost.prod-type  = buf_ot-line-crsa-loop.prod-type
                            and buf_ot-line-cost.prod-code  = buf_ot-line-crsa-loop.prod-code
                            and buf_ot-line-cost.sum-type   = buf_ot-tot-cost.sum-type
                    no-error.
                    if available buf_ot-line-cost
                    then do:
                            run bgelib-tag-open in this-procedure ( input 0, input "lineCostSum", input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID" , input v-doc-code                                      , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"        , input v-good-code                                     , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( abs( buf_ot-line-cost.sum-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATr"        , input string( abs( buf_ot-line-cost.vat-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"        , input string( abs( buf_ot-line-cost.slt-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"    , input string( abs( buf_ot-line-cost.road-tax-rubl  ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportr"  , input string( abs( buf_ot-line-cost.transport-rubl ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherr"      , input string( abs( buf_ot-line-cost.other-rubl     ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciser"     , input string( abs( buf_ot-line-cost.excise-rubl    ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( abs( buf_ot-line-cost.sum-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATb"        , input string( abs( buf_ot-line-cost.vat-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"        , input string( abs( buf_ot-line-cost.slt-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"    , input string( abs( buf_ot-line-cost.road-tax-base  ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportb"  , input string( abs( buf_ot-line-cost.transport-base ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherb"      , input string( abs( buf_ot-line-cost.other-base     ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"     , input string( abs( buf_ot-line-cost.excise-base    ) ), input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0, input "lineCostSum" ).
                    end.
                    else do:
                    end.
                end.
                else do:
                end.
            end.
            else do:
            end.
            run bgelib-tag-open in this-procedure ( input 0, input "lineSaleSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID" , input v-doc-code                                           , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodID"        , input v-good-code                                          , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( abs( buf_ot-line-crsa-loop.sum-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATr"        , input string( abs( buf_ot-line-crsa-loop.vat-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"        , input string( abs( buf_ot-line-crsa-loop.slt-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"    , input string( abs( buf_ot-line-crsa-loop.road-tax-rubl  ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportr"  , input string( abs( buf_ot-line-crsa-loop.transport-rubl ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherr"      , input string( abs( buf_ot-line-crsa-loop.other-rubl     ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciser"     , input string( abs( buf_ot-line-crsa-loop.excise-rubl    ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( abs( buf_ot-line-crsa-loop.sum-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATb"        , input string( abs( buf_ot-line-crsa-loop.vat-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"        , input string( abs( buf_ot-line-crsa-loop.slt-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"    , input string( abs( buf_ot-line-crsa-loop.road-tax-base  ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportb"  , input string( abs( buf_ot-line-crsa-loop.transport-base ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherb"      , input string( abs( buf_ot-line-crsa-loop.other-base     ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"     , input string( abs( buf_ot-line-crsa-loop.excise-base    ) ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "lineSaleSum" ).
            if p-ext-doc-type = 'vt':U
            or p-ext-doc-type = 'vp':U
            or p-ext-doc-type = 'ap':U
            or p-ext-doc-type = 'mp':U
            then do:
                run export-before-and-after-inv-line in this-procedure (
                      input v-doc-code
                    , input buf_goods.gds-code
                    , input v-exists-before
                    , input v-exists-after
                    , input ( v-is-petrol = yes and v-is-pieces = no and v-weight-not-specified  = no )
                    , input v-petrol-density
                ).
            end.
            if p-ext-doc-type <> 'ot':U
            then do:
                if p-pay-code = yes
                then do:
                    for each temp_cost_cat-id_ot-supp-line
                        where temp_cost_cat-id_ot-supp-line.artic        = buf_ot-line-crsa-loop.artic
                            and temp_cost_cat-id_ot-supp-line.prod-type    = buf_ot-line-crsa-loop.prod-type
                            and temp_cost_cat-id_ot-supp-line.prod-code    = buf_ot-line-crsa-loop.prod-code
                    on error undo, return error
                    :
                        for each temp_cost_cli_ot-supp-line
                        where temp_cost_cli_ot-supp-line.artic        = temp_cost_cat-id_ot-supp-line.artic
                            and temp_cost_cli_ot-supp-line.prod-type  = temp_cost_cat-id_ot-supp-line.prod-type
                            and temp_cost_cli_ot-supp-line.prod-code  = temp_cost_cat-id_ot-supp-line.prod-code
                            and temp_cost_cli_ot-supp-line.cat-id     = temp_cost_cat-id_ot-supp-line.cat-id
                        on error undo, return error
                        :
                            run fill_bgelib_clients in this-procedure (
                                  input p-parent-handle
                                , input temp_cost_cli_ot-supp-line.cli-type
                                , input temp_cost_cli_ot-supp-line.cli-code
                            ).
                            run bgelib-tag-open in this-procedure ( input 0, input "linePaySupp", input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID" , input v-doc-code                                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"        , input v-good-code                                   , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( temp_cost_cat-id_ot-supp-line.cat-id ), input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "firmType"    , input string( temp_cost_cli_ot-supp-line.cli-type ) , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "firmCode"    , input string( temp_cost_cli_ot-supp-line.cli-code ) , input 2 ).
                            if temp_cost_cli_ot-supp-line.sum-rubl < 0
                            then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "sign", input "-1", input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"       , input string( abs( temp_cost_cli_ot-supp-line.sum-rubl         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"       , input string( abs( temp_cost_cli_ot-supp-line.vat-rubl         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"       , input string( abs( temp_cost_cli_ot-supp-line.slt-rubl         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"   , input string( abs( temp_cost_cli_ot-supp-line.road-tax-rubl    ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr" , input string( abs( temp_cost_cli_ot-supp-line.transport-rubl   ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"     , input string( abs( temp_cost_cli_ot-supp-line.other-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"    , input string( abs( temp_cost_cli_ot-supp-line.excise-rubl      ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"       , input string( abs( temp_cost_cli_ot-supp-line.sum-base         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"       , input string( abs( temp_cost_cli_ot-supp-line.vat-base         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"       , input string( abs( temp_cost_cli_ot-supp-line.slt-base         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"   , input string( abs( temp_cost_cli_ot-supp-line.road-tax-base    ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb" , input string( abs( temp_cost_cli_ot-supp-line.transport-base   ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"     , input string( abs( temp_cost_cli_ot-supp-line.other-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"    , input string( abs( temp_cost_cli_ot-supp-line.excise-base      ) ), input 2 ).
                            find first buf_sale_ot-supp-line no-lock
                                    where buf_sale_ot-supp-line.doc-code    = v-doc-code
                                    and buf_sale_ot-supp-line.cli-type    = temp_cost_cli_ot-supp-line.cli-type
                                    and buf_sale_ot-supp-line.cli-code    = temp_cost_cli_ot-supp-line.cli-code
                                    and buf_sale_ot-supp-line.artic       = temp_cost_cli_ot-supp-line.artic
                                    and buf_sale_ot-supp-line.prod-type   = temp_cost_cli_ot-supp-line.prod-type
                                    and buf_sale_ot-supp-line.prod-code   = temp_cost_cli_ot-supp-line.prod-code
                                    and buf_sale_ot-supp-line.sum-type    = 'sale':U
                                    and buf_sale_ot-supp-line.cat-id      = '##':U
                            no-error.
                            if available buf_sale_ot-supp-line
                            then do:
                                if buf_sale_ot-supp-line.sum-rubl < 0
                                then do:
                                    run bgelib-tag-put in this-procedure ( input 1, input "sign", input "-1", input 0 ).
                                end.
                                run bgelib-tag-put in this-procedure ( input 1, input "docSumr"      , input string( abs( buf_sale_ot-supp-line.sum-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docVatr"      , input string( abs( buf_sale_ot-supp-line.vat-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docSltr"      , input string( abs( buf_sale_ot-supp-line.slt-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docRoadtaxr"  , input string( abs( buf_sale_ot-supp-line.road-tax-rubl    ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docTransportr", input string( abs( buf_sale_ot-supp-line.transport-rubl   ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docOtherr"    , input string( abs( buf_sale_ot-supp-line.other-rubl       ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docExciser"   , input string( abs( buf_sale_ot-supp-line.excise-rubl      ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docSumb"      , input string( abs( buf_sale_ot-supp-line.sum-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docVatb"      , input string( abs( buf_sale_ot-supp-line.vat-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docSltb"      , input string( abs( buf_sale_ot-supp-line.slt-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docRoadtaxb"  , input string( abs( buf_sale_ot-supp-line.road-tax-base    ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docTransportb", input string( abs( buf_sale_ot-supp-line.transport-base   ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docOtherb"    , input string( abs( buf_sale_ot-supp-line.other-base       ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docExciseb"   , input string( abs( buf_sale_ot-supp-line.excise-base      ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                            end.
                            run bgelib-tag-close in this-procedure ( input 0, input "linePaySupp" ).
                        end.
                    end.
                end.
            end.
            else do:
            end.
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
procedure export-before-and-after-inv-trn :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define output parameter p-exists-before as logical      no-undo.
define output parameter p-exists-after  as logical      no-undo.
    define variable v-attr-value    as character     no-undo.
    define variable v-attr-type     as character     no-undo.
    define buffer buf_trn-doc-sum       for ub.trn-doc-sum.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'addsum':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    if lookup( 'bd':U, v-attr-value ) <> 0
    then do:
        assign
            p-exists-before = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = 'bd':U
        no-error.
        if available buf_trn-doc-sum
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "docInvBeforeSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"     , input p-doc-code                                   , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"            , input string( buf_trn-doc-sum.fact-qnty           ) , 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumr"        , input string( buf_trn-doc-sum.crsa-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatr"        , input string( buf_trn-doc-sum.crsa-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltr"        , input string( buf_trn-doc-sum.crsa-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxr"    , input string( buf_trn-doc-sum.crsa-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportr"  , input string( buf_trn-doc-sum.crsa-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherr"      , input string( buf_trn-doc-sum.crsa-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciser"     , input string( buf_trn-doc-sum.crsa-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumb"        , input string( buf_trn-doc-sum.crsa-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatb"        , input string( buf_trn-doc-sum.crsa-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltb"        , input string( buf_trn-doc-sum.crsa-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxb"    , input string( buf_trn-doc-sum.crsa-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportb"  , input string( buf_trn-doc-sum.crsa-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherb"      , input string( buf_trn-doc-sum.crsa-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciseb"     , input string( buf_trn-doc-sum.crsa-excise-base    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"        , input string( buf_trn-doc-sum.cost-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"        , input string( buf_trn-doc-sum.cost-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"        , input string( buf_trn-doc-sum.cost-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"    , input string( buf_trn-doc-sum.cost-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr"  , input string( buf_trn-doc-sum.cost-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"      , input string( buf_trn-doc-sum.cost-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"     , input string( buf_trn-doc-sum.cost-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"        , input string( buf_trn-doc-sum.cost-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"        , input string( buf_trn-doc-sum.cost-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"        , input string( buf_trn-doc-sum.cost-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"    , input string( buf_trn-doc-sum.cost-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb"  , input string( buf_trn-doc-sum.cost-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"      , input string( buf_trn-doc-sum.cost-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"     , input string( buf_trn-doc-sum.cost-excise-base    ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "docInvBeforeSum" ).
        end.
        else do:
            run bgelib-write-log in this-procedure ( input p-log-file-name, input 1, input "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = 'bd':U для документа " + string( p-doc-code ) ).
        end.
    end.
    if lookup( 'ad':U, v-attr-value ) <> 0
    then do:
        assign
            p-exists-after  = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = 'ad':U
        no-error.
        if available buf_trn-doc-sum
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "docInvAfterSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"    , input p-doc-code                                   , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"           , input string( buf_trn-doc-sum.fact-qnty           ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumr"       , input string( buf_trn-doc-sum.crsa-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatr"       , input string( buf_trn-doc-sum.crsa-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltr"       , input string( buf_trn-doc-sum.crsa-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxr"   , input string( buf_trn-doc-sum.crsa-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportr" , input string( buf_trn-doc-sum.crsa-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherr"     , input string( buf_trn-doc-sum.crsa-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciser"    , input string( buf_trn-doc-sum.crsa-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumb"       , input string( buf_trn-doc-sum.crsa-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatb"       , input string( buf_trn-doc-sum.crsa-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltb"       , input string( buf_trn-doc-sum.crsa-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxb"   , input string( buf_trn-doc-sum.crsa-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportb" , input string( buf_trn-doc-sum.crsa-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherb"     , input string( buf_trn-doc-sum.crsa-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciseb"    , input string( buf_trn-doc-sum.crsa-excise-base    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"       , input string( buf_trn-doc-sum.cost-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"       , input string( buf_trn-doc-sum.cost-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"       , input string( buf_trn-doc-sum.cost-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"   , input string( buf_trn-doc-sum.cost-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr" , input string( buf_trn-doc-sum.cost-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"     , input string( buf_trn-doc-sum.cost-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"    , input string( buf_trn-doc-sum.cost-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"       , input string( buf_trn-doc-sum.cost-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"       , input string( buf_trn-doc-sum.cost-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"       , input string( buf_trn-doc-sum.cost-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"   , input string( buf_trn-doc-sum.cost-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb" , input string( buf_trn-doc-sum.cost-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"     , input string( buf_trn-doc-sum.cost-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"    , input string( buf_trn-doc-sum.cost-excise-base    ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "docInvAfterSum" ).
        end.
        else do:
            run bgelib-write-log in this-procedure ( input p-log-file-name, input 1, input "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = 'ad':U для документа " + string( p-doc-code ) ).
        end.
    end.
end.
end procedure.
procedure export-before-and-after-inv-line :
do
on error undo, return error
:
define input parameter p-doc-code           as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-exists-before      as logical      no-undo.
define input parameter p-exists-after       as logical      no-undo.
define input parameter p-need-petrol-weight as logical      no-undo.
define input parameter p-petrol-density     as decimal      no-undo.
    define buffer buf_doc-line-sum      for ub.doc-line-sum.
    if p-exists-before = yes
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = 'bd':U
        no-error.
        if available buf_doc-line-sum
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "lineInvBeforeSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"     , input p-doc-code  , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodID"            , input p-gds-code  , input 0 ).
            if p-need-petrol-weight = yes
            then do:
                run bgelib-tag-put in this-procedure ( input 1, input "petrolWeightBefore", input string( buf_doc-line-sum.fact-qnty * p-petrol-density ), input 0 ).
            end.
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"           , input string( buf_doc-line-sum.fact-qnty ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumr"       , input string( buf_doc-line-sum.crsa-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatr"       , input string( buf_doc-line-sum.crsa-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltr"       , input string( buf_doc-line-sum.crsa-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxr"   , input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportr" , input string( buf_doc-line-sum.crsa-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherr"     , input string( buf_doc-line-sum.crsa-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciser"    , input string( buf_doc-line-sum.crsa-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumb"       , input string( buf_doc-line-sum.crsa-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatb"       , input string( buf_doc-line-sum.crsa-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltb"       , input string( buf_doc-line-sum.crsa-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxb"   , input string( buf_doc-line-sum.crsa-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportb" , input string( buf_doc-line-sum.crsa-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherb"     , input string( buf_doc-line-sum.crsa-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciseb"    , input string( buf_doc-line-sum.crsa-excise-base    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"       , input string( buf_doc-line-sum.cost-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"       , input string( buf_doc-line-sum.cost-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"       , input string( buf_doc-line-sum.cost-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"   , input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr" , input string( buf_doc-line-sum.cost-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"     , input string( buf_doc-line-sum.cost-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"    , input string( buf_doc-line-sum.cost-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"       , input string( buf_doc-line-sum.cost-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"       , input string( buf_doc-line-sum.cost-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"       , input string( buf_doc-line-sum.cost-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"   , input string( buf_doc-line-sum.cost-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb" , input string( buf_doc-line-sum.cost-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"     , input string( buf_doc-line-sum.cost-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"    , input string( buf_doc-line-sum.cost-excise-base    ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "lineInvBeforeSum" ).
        end.
        else do:
            run bgelib-write-log in this-procedure ( input p-log-file-name, input 1, input "*** ERR: *** Не найдена запись doc-line-sum с sum-type = 'bd':U для документа " + string( p-doc-code ) ).
        end.
    end.
    if p-exists-after = yes
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = 'ad':U
        no-error.
        if available buf_doc-line-sum
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "lineInvAfterSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"     , input p-doc-code  , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodID"            , input p-gds-code  , input 0 ).
            if p-need-petrol-weight = yes
            then do:
                run bgelib-tag-put in this-procedure ( input 1, input "petrolWeightAfter",  input string( buf_doc-line-sum.fact-qnty * p-petrol-density ), input 0 ).
            end.
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"           , input string( buf_doc-line-sum.fact-qnty           ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumr"       , input string( buf_doc-line-sum.crsa-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatr"       , input string( buf_doc-line-sum.crsa-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltr"       , input string( buf_doc-line-sum.crsa-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxr"   , input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportr" , input string( buf_doc-line-sum.crsa-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherr"     , input string( buf_doc-line-sum.crsa-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciser"    , input string( buf_doc-line-sum.crsa-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumb"       , input string( buf_doc-line-sum.crsa-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatb"       , input string( buf_doc-line-sum.crsa-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltb"       , input string( buf_doc-line-sum.crsa-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxb"   , input string( buf_doc-line-sum.crsa-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportb" , input string( buf_doc-line-sum.crsa-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherb"     , input string( buf_doc-line-sum.crsa-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciseb"    , input string( buf_doc-line-sum.crsa-excise-base    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"       , input string( buf_doc-line-sum.cost-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"       , input string( buf_doc-line-sum.cost-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"       , input string( buf_doc-line-sum.cost-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"   , input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr" , input string( buf_doc-line-sum.cost-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"     , input string( buf_doc-line-sum.cost-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"    , input string( buf_doc-line-sum.cost-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"       , input string( buf_doc-line-sum.cost-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"       , input string( buf_doc-line-sum.cost-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"       , input string( buf_doc-line-sum.cost-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"   , input string( buf_doc-line-sum.cost-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb" , input string( buf_doc-line-sum.cost-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"     , input string( buf_doc-line-sum.cost-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"    , input string( buf_doc-line-sum.cost-excise-base    ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "lineInvAfterSum" ).
        end.
        else do:
            run bgelib-write-log in this-procedure ( input p-log-file-name, input 1, input "*** ERR: *** Не найдена запись doc-line-sum с sum-type = 'ad':U для документа " + string( p-doc-code ) ).
        end.
    end.
end.
end procedure.
procedure get-petrol-weight :
do
on error undo, return error
:
define input parameter p-ext-doc-type           as character    no-undo.
define input parameter p-doc-line-recid         as recid        no-undo.
define input parameter p-trn-doc-out-code       as character    no-undo.
define output parameter p-petrol-weight         as decimal      no-undo.
define output parameter p-weight-not-specified  as logical      no-undo.
    define variable v-rvs-code              as character     no-undo.
    define variable v-found-last-rvs-doc    as logical       no-undo.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_rvs-doc       for ub.rvs-doc.
    define buffer buf_rvs-line      for ub.rvs-line.
    define buffer buf_goods         for ub.goods.
    define buffer buf_doc-pl        for ub.doc-pl.
    find first buf_doc-line no-lock
        where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_doc-line.artic
           and buf_goods.prod-type  = buf_doc-line.prod-type
           and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    assign
        p-weight-not-specified = yes
    .
    case p-ext-doc-type:
        when 'ie':U
        or when 're':U
        or when 'we':U
        or when 'ie':U
        or when 'rs':U
        or when 'ep':U
        then do:
            assign
                p-petrol-weight        = buf_doc-line.fact-qnty * buf_doc-line.fact-density
                p-weight-not-specified = no
            .
        end.
        when 'vt':U
        or when 'vp':U
        or when 'ap':U
        or when 'mp':U
        then do:
            find first buf_rvs-doc no-lock
                 where buf_rvs-doc.rvs-code = p-trn-doc-out-code
                   and buf_rvs-doc.status_  = 'факт':U
            no-error.
            if available buf_rvs-doc
            then do:
                assign
                    v-rvs-code           = buf_rvs-doc.rvs-code
                .
                for each buf_doc-pl no-lock
                   where buf_doc-pl.out-code = buf_doc-line.doc-code
                     and buf_doc-pl.gds-code = buf_goods.gds-code
                     and buf_doc-pl.obj-type = buf_doc-line.obj-type
                     and buf_doc-pl.obj-code = buf_doc-line.obj-code
                on error undo, return error
                :
                    for each buf_rvs-line no-lock
                       where buf_rvs-line.gds-code  = buf_doc-pl.gds-code
                         and buf_rvs-line.rvs-code  = v-rvs-code
                         and buf_rvs-line.obj-type  = buf_doc-pl.obj-type
                         and buf_rvs-line.obj-code  = buf_doc-pl.obj-code
                         and buf_rvs-line.pl-code   = buf_doc-pl.pl-code
                    on error undo, return error
                    :
                        assign
                            p-petrol-weight         = p-petrol-weight + buf_doc-pl.fact-qnty * buf_rvs-line.state-density
                            p-weight-not-specified  = no
                        .
                    end.
                end.
            end.
            else do:
                assign
                    v-found-last-rvs-doc = no
                .
                find-last-rvs:
                for each buf_rvs-doc no-lock
                   where buf_rvs-doc.obj-type = buf_doc-line.obj-type
                     and buf_rvs-doc.obj-code = buf_doc-line.obj-code
                     and buf_rvs-doc.status_  = 'факт':U
                use-index shift
                on error undo, return error
                :
                    assign
                        v-rvs-code           = buf_rvs-doc.rvs-code
                    .
                    for each buf_doc-pl no-lock
                       where buf_doc-pl.out-code = buf_doc-line.doc-code
                         and buf_doc-pl.gds-code = buf_goods.gds-code
                         and buf_doc-pl.obj-type = buf_doc-line.obj-type
                         and buf_doc-pl.obj-code = buf_doc-line.obj-code
                    on error undo, return error
                    :
                        for each buf_rvs-line no-lock
                           where buf_rvs-line.gds-code  = buf_doc-pl.gds-code
                             and buf_rvs-line.rvs-code  = v-rvs-code
                             and buf_rvs-line.obj-type  = buf_doc-pl.obj-type
                             and buf_rvs-line.obj-code  = buf_doc-pl.obj-code
                             and buf_rvs-line.pl-code   = buf_doc-pl.pl-code
                        on error undo, return error
                        :
                            assign
                                v-found-last-rvs-doc    = yes
                                p-petrol-weight         = p-petrol-weight + buf_doc-pl.fact-qnty * buf_rvs-line.state-density
                                p-weight-not-specified  = no
                            .
                            leave find-last-rvs.
                        end.
                    end.
                end.
            end.
        end.
        otherwise do:
            assign
                p-weight-not-specified = yes
            .
        end.
    end case.
end.
end procedure.
procedure get-cash-pay :
  do
  on error undo, return error
  :
  define input parameter p-ext-doc-type           as character    no-undo.
  define input parameter p-doc-line-recid         as recid        no-undo.
  define input parameter p-trn-doc-out-code       as character    no-undo.
  define output parameter p-cash-pay-not-specified  as logical      no-undo.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_goods         for ub.goods.
    find first buf_doc-line no-lock
        where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_doc-line.artic
           and buf_goods.prod-type  = buf_doc-line.prod-type
           and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    assign
        p-cash-pay-not-specified = yes
    .
    case p-ext-doc-type:
        when 'es':U
        then do:
            assign
                p-cash-pay-not-specified = no
            .
        end.
        when 'rs':U
        then do:
            assign
                p-cash-pay-not-specified = no
            .
        end.
        otherwise do:
            assign
                p-cash-pay-not-specified = yes
            .
        end.
      END CASE.
  end.
end procedure.
procedure get-inkas-pay-desk :
  define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
  do for buf_inkas-pay-desk
  on error undo, return error
  :
  define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
  define input parameter p-obj-type   like ub.inkas.obj-type no-undo .
  define input parameter p-obj-code   like ub.inkas.obj-code no-undo .
  define input parameter p-inkas-pay-desk-type like ub.inkas-pay-desk.doc-type no-undo .
    if can-find( first buf_inkas-pay-desk  NO-LOCK WHERE
                       buf_inkas-pay-desk.inkas-code = p-inkas-code ) then.
    else do:
      run trg/inkpdcr.p (
                     p-inkas-code
                    ,p-obj-type
                    ,p-obj-code
      ) no-error .
      if error-status:error then do:
        return error.
      end.
    end.
    for each temp_inkas-pay
    :
        delete temp_inkas-pay.
    end.
    for each buf_inkas-pay-desk no-lock
       where buf_inkas-pay-desk.inkas-code  = p-inkas-code
         and buf_inkas-pay-desk.doc-type    = p-inkas-pay-desk-type
    break by buf_inkas-pay-desk.pay-code
    on error undo, return error
    :
        if first-of( buf_inkas-pay-desk.pay-code )
        then do:
            create temp_inkas-pay.
            assign
                temp_inkas-pay.pay-code  = buf_inkas-pay-desk.pay-code
                temp_inkas-pay.tot-base  = 0
                temp_inkas-pay.tot-rubl  = 0
                temp_inkas-pay.tot-sum   = 0
            .
        end.
        assign
            temp_inkas-pay.tot-base  = temp_inkas-pay.tot-base + buf_inkas-pay-desk.tot-base
            temp_inkas-pay.tot-rubl  = temp_inkas-pay.tot-rubl + buf_inkas-pay-desk.tot-rubl
            temp_inkas-pay.tot-sum   = temp_inkas-pay.tot-sum  + buf_inkas-pay-desk.tot-sum
        .
    end.
  end.
end procedure.
procedure export-attribute :
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.
define input parameter p-attr-code  as character    no-undo.
define input parameter p-tag-name   as character    no-undo.
    define variable v-attr-exists    as logical        no-undo.
    define variable v-attr-value     as character      no-undo.
    define variable v-attr-type      as character      no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-xst in g#trdcalib (  input p-doc-code ,
                        input p-attr-code ,
                       output v-attr-exists )  .
    if v-attr-exists = yes
    then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input p-attr-code ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
        if error-status :error
        then do:
            run bgelib-write-log in this-procedure (
                  input p-log-file-name
                , input 1
                , input substitute( "*** ERR: *** Ошибка чтения атрибута &1 для документа N &2", p-attr-code, p-doc-code )
            ).
        end.
        else do:
            run bgelib-tag-put in this-procedure ( input 1, input p-tag-name, input v-attr-value, input 0 ).
        end.
    end.
end.
end procedure.
procedure export-parts :
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-prod-type  as character    no-undo.
define input parameter p-prod-code  as integer      no-undo.
define input parameter p-artic      as character    no-undo.
    define variable v-parts-cst-code        as character    no-undo.
    define variable v-fact-qnty             as decimal     no-undo.
    define variable v-sum-rubl              as decimal     no-undo.
    define variable v-vat-rubl              as decimal     no-undo.
    define variable v-slt-rubl              as decimal     no-undo.
    define variable v-road-tax-rubl         as decimal     no-undo.
    define variable v-transport-rubl        as decimal     no-undo.
    define variable v-other-rubl            as decimal     no-undo.
    define variable v-excise-rubl           as decimal     no-undo.
    define variable v-sum-base              as decimal     no-undo.
    define variable v-vat-base              as decimal     no-undo.
    define variable v-slt-base              as decimal     no-undo.
    define variable v-road-tax-base         as decimal     no-undo.
    define variable v-transport-base        as decimal     no-undo.
    define variable v-other-base            as decimal     no-undo.
    define variable v-excise-base           as decimal     no-undo.
    define variable v-parts-host-code       as integer       no-undo.
    define variable v-parts-contract-code   as integer       no-undo.
    define variable v-parts-price-cli       as decimal       no-undo.
    define variable v-parts-cli-base-rate   as decimal       no-undo.
    define variable v-parts-vat-type        as character     no-undo.
    define variable v-parts-exch-code       as integer       no-undo.
    define variable v-parts-attr-exch-rate  as decimal       no-undo.
    define variable v-parts-attr-exch-scale as integer       no-undo.
    define variable v-parts-attr-unit-cli   as character     no-undo.
    define variable v-country-code          as character    no-undo.
    define variable v-supp-type             as character   no-undo.
    define variable v-supp-code             as integer     no-undo.
    define variable v-in-code               as character   no-undo.
    define variable v-cst-code              as character   no-undo.
    define variable v-supp-dog-code         as character    no-undo.
    define variable v-supp-ndog             as character    no-undo.
    define variable v-supp-ddog             as character    no-undo.
    define buffer buf_parts             for ub.parts.
    define buffer buf_parts-attr        for ub.parts-attr.
    define buffer buf_contract          for ub.contract.
    assign
        v-parts-cst-code = "":U
        v-supp-dog-code  = "":U
        v-supp-ndog      = "":U
        v-supp-ddog      = "":U
    .
    for each buf_parts no-lock
        where buf_parts.out-code   = p-doc-code
          and buf_parts.obj-type   = p-obj-type
          and buf_parts.obj-code   = p-obj-code
          and buf_parts.prod-type  = p-prod-type
          and buf_parts.prod-code  = p-prod-code
          and buf_parts.artic      = p-artic
          and buf_parts.status_    = true
    on error undo, return error return-value
    :
        if p-parts = yes
        then do:
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
            ASSIGN
                v-fact-qnty           = buf_parts.fact-qnty
                v-sum-rubl            = price-rubl-with-tax-loc * v-fact-qnty
                v-vat-rubl            = vat-rubl-loc            * v-fact-qnty
                v-slt-rubl            = slt-rubl-loc            * v-fact-qnty
                v-road-tax-rubl       = road-tax-rubl-loc       * v-fact-qnty
                v-transport-rubl      = transport-rubl-loc      * v-fact-qnty
                v-other-rubl          = other-rubl-loc          * v-fact-qnty
                v-excise-rubl         = 0
                v-sum-base            = price-base-with-tax-loc * v-fact-qnty
                v-vat-base            = vat-base-loc            * v-fact-qnty
                v-slt-base            = slt-base-loc            * v-fact-qnty
                v-road-tax-base       = road-tax-base-loc       * v-fact-qnty
                v-transport-base      = transport-base-loc      * v-fact-qnty
                v-other-base          = other-base-loc          * v-fact-qnty
                v-excise-base         = 0
                v-parts-host-code     = buf_parts.host-code
                v-parts-contract-code = buf_parts.contract-code
                v-parts-price-cli     = buf_parts.price-cli
                v-parts-cli-base-rate = buf_parts.cli-base-rate
                v-parts-vat-type      = buf_parts.vat-type
                v-parts-exch-code     = buf_parts.exch-code
            .
            if buf_parts.contract-code <> 0
            then do:
                assign
                    v-supp-dog-code = string( buf_parts.contract-code )
                .
                find first buf_contract no-lock
                     where buf_contract.host-code       = v-parts-host-code
                       and buf_contract.contract-code   = v-parts-contract-code
                no-error.
                if available buf_contract
                then do:
                    assign
                        v-supp-ndog          = string( buf_contract.contract-prn-code )
                        v-supp-ddog          = string( buf_contract.contract-date, "99.99.9999" )
                    .
                end.
            end.
            if p-gds-code <> 0
            then do:
                find first buf_parts-attr no-lock
                     where buf_parts-attr.in-code   = buf_parts.in-code
                       and buf_parts-attr.gds-code  = p-gds-code
                       and buf_parts-attr.part-code = buf_parts.part-code
                no-error .
                if available buf_parts-attr
                then do:
                    assign
                        v-supp-type                 = buf_parts-attr.supp-type
                        v-supp-code                 = buf_parts-attr.supp-code
                        v-in-code                   = buf_parts-attr.income-in-code
                        v-cst-code                  = buf_parts-attr.cst-code
                        v-country-code              = string( buf_parts-attr.country-code )
                        v-parts-attr-exch-rate      = buf_parts-attr.exch-rate
                        v-parts-attr-exch-scale     = buf_parts-attr.exch-scale
                        v-parts-attr-unit-cli       = buf_parts-attr.unit-cli
                    .
                end.
                else do:
                    assign
                        v-supp-type                 = buf_parts.supp-type
                        v-supp-code                 = buf_parts.supp-code
                        v-in-code                   = buf_parts.in-code
                        v-cst-code                  = buf_parts.cst-code
                        v-country-code              = "":U
                        v-parts-attr-exch-rate      = 0.0
                        v-parts-attr-exch-scale     = 0
                        v-parts-attr-unit-cli       = "":U
                    .
                end.
            end.
            else do:
                assign
                    v-supp-type                 = buf_parts.supp-type
                    v-supp-code                 = buf_parts.supp-code
                    v-in-code                   = buf_parts.in-code
                    v-cst-code                  = buf_parts.cst-code
                    v-country-code              = "":U
                    v-parts-attr-exch-rate      = 0.0
                    v-parts-attr-exch-scale     = 0
                    v-parts-attr-unit-cli       = "":U
                .
            end.
            run bgelib-tag-open in this-procedure ( input 0, input "linePart", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"               , input p-doc-code                 , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodID"              , input ( if p-gds-code = 0 then "" else string( p-gds-code ) ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "inputDocID"          , input string( v-in-code               ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"                , input string( v-fact-qnty             ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "cst"                 , input string( v-cst-code              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "supp"                , input string( v-supp-type + string( v-supp-code ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "hostCode"            , input string( v-parts-host-code       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "contractCode"        , input string( v-parts-contract-code   ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumr"                , input string( v-sum-rubl              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATr"                , input string( v-vat-rubl              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"                , input string( v-slt-rubl              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"            , input string( v-road-tax-rubl         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportr"          , input string( v-transport-rubl        ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherr"              , input string( v-other-rubl            ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciser"             , input string( v-excise-rubl           ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumb"                , input string( v-sum-base              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATb"                , input string( v-vat-base              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"                , input string( v-slt-base              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"            , input string( v-road-tax-base         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportb"          , input string( v-transport-base        ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherb"              , input string( v-other-base            ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"             , input string( v-excise-base           ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "contractSuppCode"    , input v-supp-dog-code                  , input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "contractSuppNo"      , input v-supp-ndog                      , input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "contractSuppDate"    , input v-supp-ddog                      , input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "countryCode"         , input v-country-code                   , input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "priceCli":U          , input string( v-parts-price-cli       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "cliBaseRate":U       , input string( v-parts-cli-base-rate   ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "vatType":U           , input string( v-parts-vat-type        ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exchCode":U          , input string( v-parts-exch-code       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "attrExchRate":U      , input string( v-parts-attr-exch-rate  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "attrExchScale":U     , input string( v-parts-attr-exch-scale ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "attrUnitCli":U       , input string( v-parts-attr-unit-cli   ), input 0 ).
            run bgelib-tag-close in this-procedure ( input 0, input "linePart" ).
        end.
        if p-cst = yes
        then do:
            assign
                v-parts-cst-code = v-parts-cst-code
                                    + ( if ( v-cst-code <> ?
                                        and trim( v-cst-code )   <> ""
                                        and trim( v-parts-cst-code ) <> "" )
                                        then "; "
                                        else ""  )
                                    + v-cst-code
            .
        end.
    end.
    if p-cst = yes
    and v-parts-cst-code <> ""
    then do:
        run bgelib-tag-open in this-procedure ( input 0, input "lineCST", input "" ).
        run bgelib-tag-put in this-procedure ( input 1, input "docID"  , input p-doc-code       , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "goodID" , input ( if p-gds-code = 0 then "" else string( p-gds-code ) ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "CST"      , input v-parts-cst-code , input 0 ).
        run bgelib-tag-close in this-procedure ( input 0, input "lineCST" ).
    end.
end.
end procedure.
procedure export-gds-dtl :
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-artic          as character        no-undo.
define input parameter p-prod-type      as character        no-undo.
define input parameter p-prod-code      as integer          no-undo.
    define variable v-doc-qnty       as decimal       no-undo.
    define variable v-fact-qnty      as decimal       no-undo.
    define variable v-sum-base       as decimal       no-undo.
    define variable v-sum-rubl       as decimal       no-undo.
    define variable v-vat-base       as decimal       no-undo.
    define variable v-vat-rubl       as decimal       no-undo.
    define variable v-slt-base       as decimal       no-undo.
    define variable v-slt-rubl       as decimal       no-undo.
    define variable v-road-tax-base  as decimal       no-undo.
    define variable v-road-tax-rubl  as decimal       no-undo.
    define buffer buf_gds-dtl       for ub.gds-dtl.
    define buffer buf_gds-prt       for ub.gds-prt.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
do
for buf_gds-dtl
  , buf_gds-prt
  , buf_trn-doc
  , buf_doc-line
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    no-error.
    if not available buf_trn-doc
    then do:
        run bgelib-write-log in this-procedure (
              input p-log-file-name
            , input 1
            , input substitute( "*** ERR: *** Не найден документ '&1'."
                                , p-doc-code
                            )
        ).
        undo, return error.
    end.
    find first buf_doc-line no-lock
         where buf_doc-line.doc-code    = p-doc-code
           and buf_doc-line.artic       = p-artic
           and buf_doc-line.prod-type   = p-prod-type
           and buf_doc-line.prod-code   = p-prod-code
    no-error.
    if not available buf_doc-line
    then do:
        run bgelib-write-log in this-procedure (
              input p-log-file-name
            , input 1
            , input substitute( "*** ERR: *** Не найдена строка документа '&1' с артикулом товара '&2'."
                                , p-doc-code
                                , p-artic
                            )
        ).
        undo, return error.
    end.
    for each buf_gds-dtl no-lock
       where buf_gds-dtl.prod-type  = p-prod-type
         and buf_gds-dtl.prod-code  = p-prod-code
         and buf_gds-dtl.artic      = p-artic
         and buf_gds-dtl.doc-code   = p-doc-code
    :
        find first buf_gds-prt no-lock
             where buf_gds-prt.node-code = buf_gds-dtl.prt-code
        .
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
        assign
            v-doc-qnty            = buf_gds-dtl.doc-qnty
            v-fact-qnty           = buf_gds-dtl.fact-qnty
            v-sum-rubl            = price-rubl-with-tax-sale    * v-fact-qnty
            v-vat-rubl            = vat-rubl-buyer              * v-fact-qnty
            v-slt-rubl            = slt-rubl-sale               * v-fact-qnty
            v-road-tax-rubl       = road-tax-rubl-sale          * v-fact-qnty
            v-sum-base            = price-base-with-tax-sale    * v-fact-qnty
            v-vat-base            = vat-base-buyer              * v-fact-qnty
            v-slt-base            = slt-base-sale               * v-fact-qnty
            v-road-tax-base       = road-tax-base-sale          * v-fact-qnty
        .
        run bgelib-tag-open in this-procedure ( input 0, input "lineDtl", input "" ).
        run bgelib-tag-put in this-procedure ( input 1, input "docID"   , input p-doc-code                 , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "goodID"  , input ( if p-gds-code = 0 then "" else string( p-gds-code ) ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "dtlName"   , input string( buf_gds-prt.f-name ), input 2 ).
        if p-ext-doc-type = 'vt':U
        or p-ext-doc-type = 'vp':U
        or p-ext-doc-type = 'ap':U
        or p-ext-doc-type = 'mp':U
        then do:
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"      , input string( v-doc-qnty                ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "beforeQnty", input string( v-fact-qnty - v-doc-qnty  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "afterQnty" , input string( v-fact-qnty               ), input 2 ).
        end.
        else do:
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"      , input string( v-fact-qnty               ), input 2 ).
        end.
        run bgelib-tag-put in this-procedure ( input 1, input "sumr"      , input string( v-sum-rubl         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATr"      , input string( v-vat-rubl         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTr"      , input string( v-slt-rubl         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"  , input string( v-road-tax-rubl    ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sumb"      , input string( v-sum-base         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATb"      , input string( v-vat-base         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTb"      , input string( v-slt-base         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"  , input string( v-road-tax-base    ), input 2 ).
        run bgelib-tag-close in this-procedure ( input 0, input "lineDtl" ).
    end.
end.
end procedure.
procedure export-chk-pay-code :
define input parameter p-doc-line-recid     as recid            no-undo.
define input parameter p-trn-doc-doc-code   as character        no-undo.
define input parameter p-trn-doc-out-code   as character        no-undo.
define input parameter p-is-petrol          as logical          no-undo.
define input parameter p-is-pieces          as logical          no-undo.
define input parameter p-goods-gds-code     as integer          no-undo.
define input parameter p-goods-gds-type     as character        no-undo.
    define variable v-cash-pay-not-specified      as logical      no-undo.
do
on error undo, return error
:
    run get-cash-pay in this-procedure (
          input p-ext-doc-type
        , input p-doc-line-recid
        , input p-trn-doc-out-code
        , output v-cash-pay-not-specified
    ).
    if v-cash-pay-not-specified = no
    then do:
        if p-pay-desk = yes
        then do:
            if p-is-petrol = yes
            and p-is-pieces = no
            then do:
                for each treal-2
                    where treal-2.gds-code = p-goods-gds-code
                break by treal-2.pay-desk
                        by treal-2.cpay-code
                        by treal-2.curr-code
                        by treal-2.prefix
                on error undo, return error
                :
                    if treal-2.is-pay = no then do:
                       next.
                    end.
                    run bgelib-tag-open in this-procedure ( input 0
                                                            , input (if treal-2.prefix = '':U
                                                                    then "linePayDesk"
                                                                    else "linePayDeskCard")
                                                            , input "" ).
                    run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "PayDeskCode" , input string( treal-2.pay-desk )          , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( treal-2.cpay-code )         , input 0 ).
                    if treal-2.prefix <> '':U then do:
                        run bgelib-tag-put in this-procedure ( input 1, input "num"         , input string( treal-2.prefix )            , input 0 ).
                    end.
                    run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-2.qnty1 )  , input 3 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-2.netto-rubl )  , input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-2.netto )  , input 2 ).
                    run bgelib-tag-close in this-procedure ( input 0
                                                            , input (if treal-2.prefix = '':U
                                                                    then "linePayDesk"
                                                                    else "linePayDeskCard")
                                                            ).
                end.
            end.
            else do:
                case p-goods-gds-type:
                    when 'т':U
                    then do:
                        for each treal-3 no-lock
                            where treal-3.gds-code = p-goods-gds-code
                        break by treal-3.pay-desk
                                by treal-3.cpay-code
                                by treal-3.curr-code
                                by treal-3.prefix
                        on error undo, return error
                        :
                            if treal-3.is-pay = no  then do:
                                next.
                            end.
                            run bgelib-tag-open in this-procedure ( input 0
                                                                    , input (if treal-3.prefix = '':U
                                                                            then "linePayDesk"
                                                                            else "linePayDeskCard")
                                                                    , input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payDeskCode" , input string( treal-3.pay-desk )          , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( treal-3.cpay-code )         , input 0 ).
                            if treal-3.prefix <> '':U then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "num"         , input string( treal-3.prefix )            , input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-3.qnty1 )  , input 3 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-3.netto-rubl )  , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-3.netto )  , input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0
                                                                    , input (if treal-3.prefix = '':U
                                                                            then  "linePayDesk"
                                                                            else "linePayDeskCard"
                                                                            )
                                                                    ).
                        end.
                    end.
                    when 'у':U
                    then do:
                        for each treal-4 no-lock
                            where treal-4.gds-code = p-goods-gds-code
                        break by treal-4.pay-desk
                                by treal-4.cpay-code
                                by treal-4.curr-code
                                by treal-4.prefix
                        on error undo, return error
                        :
                            if treal-4.is-pay = no   then do:
                                next.
                            end.
                            run bgelib-tag-open in this-procedure ( input 0
                                                                    , input (if treal-4.prefix = '':U
                                                                            then "linePayDesk"
                                                                            else "linePayDeskCard")
                                                                    , input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payDeskCode" , input string( treal-4.pay-desk )          , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( treal-4.cpay-code )         , input 0 ).
                            if treal-4.prefix <> '':U then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "num"         , input string( treal-4.prefix )            , input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-4.qnty1 )  , input 3 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-4.netto-rubl )  , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-4.netto )  , input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0
                                                                    , input (if treal-4.prefix = '':U
                                                                            then "linePayDesk"
                                                                            else "linePayDeskCard"
                                                                            )
                                                                    ).
                        end.
                    end.
                end case.
            end.
        end.
        else do:
            if p-is-petrol = yes
            and p-is-pieces = no
            then do:
                for each treal-2 No-LOCK
                where treal-2.gds-code = p-goods-gds-code
                on error undo, return error
                :
                    if treal-2.is-pay = no then do:
                        next.
                    end.
                    run bgelib-tag-open in this-procedure ( input 0
                                                            , input (if treal-2.prefix = '':U
                                                                    then "linePayCode"
                                                                    else  "linePayCodeCard")
                                                            , input "" ).
                    run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "code"        , input string( treal-2.cpay-code )         , input 0 ).
                    if treal-2.prefix <> '':U then do:
                        run bgelib-tag-put in this-procedure ( input 1, input "num"     , input string( treal-2.prefix )            , input 0 ).
                    end.
                    run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-2.qnty1 )  , input 3 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-2.netto-rubl )  , input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-2.netto )  , input 2 ).
                    run bgelib-tag-close in this-procedure ( input 0
                                                            , input (if treal-2.prefix = '':U
                                                                    then "linePayCode"
                                                                    else "linePayCodeCard"
                                                                    )
                                                            ).
                end.
            end.
            else do:
                case p-goods-gds-type:
                    when 'т':U
                    then do:
                        for each treal-3 no-lock
                        where treal-3.gds-code = p-goods-gds-code
                        on error undo, return error
                        :
                            if treal-3.is-pay = no then NEXT.
                            run bgelib-tag-open in this-procedure ( input 0
                                                                    , input (if treal-3.prefix = '':U
                                                                            then "linePayCode"
                                                                            else "linePayCodeCard")
                                                                    , input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "code"        , input string( treal-3.cpay-code )         , input 0 ).
                            if treal-3.prefix <> '':U then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "num"     , input string( treal-3.prefix )            , input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-3.qnty1 )  , input 3 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-3.netto-rubl )  , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-3.netto )  , input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0
                                                                    , input (if treal-3.prefix = '':U
                                                                            then "linePayCode"
                                                                            else "linePayCodeCard"
                                                                            )
                                                                    ).
                        end.
                    end.
                    when 'у':U
                    then do:
                        for each treal-4 no-lock
                        where treal-4.gds-code = p-goods-gds-code
                        on error undo, return error
                        :
                            if treal-4.is-pay = no then NEXT.
                            run bgelib-tag-open in this-procedure ( input 0
                                                                    , input (if treal-4.prefix = '':U
                                                                            then "linePayCode"
                                                                            else "linePayCodeCard")
                                                                    , input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "code"        , input string( treal-4.cpay-code )         , input 0 ).
                            if treal-4.prefix <> '':U then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "num"     , input string( treal-4.prefix )            , input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-4.qnty1 )  , input 3 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-4.netto-rubl )  , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-4.netto )  , input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0
                                                                    , input (if treal-4.prefix = '':U
                                                                            then "linePayCode"
                                                                            else "linePayCodeCard" )
                                                                            ).
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end procedure.
procedure fill_bgelib_goods :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-gds-code       as integer          no-undo.
do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bgelib_goods" ) <> "":U
    then do:
        run cb-fill_bgelib_goods in p-parent-handle (
            input p-gds-code
        ).
    end.
end.
end procedure.
procedure fill_bgelib_clients :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bgelib_clients" ) <> "":U
    then do:
        run cb-fill_bgelib_clients in p-parent-handle (
              input p-obj-type
            , input p-obj-code
        ).
    end.
end.
end procedure.
