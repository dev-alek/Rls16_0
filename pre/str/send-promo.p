block-level on error undo, throw.
using ibs.th.gbl.storage.*.
using ibs.th.ref.promo.*.
using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.promotion.
using ibs.th.ref.promo.enum-type-discount .
using ibs.th.ref.promo.enum-promo-status .
using ibs.th.ref.promo.enum-sched-status .
using ibs.th.bge.1crn.subjects.promotion_promoset from propath.
using ibs.th.bge.1crn.subjects.promotion_ps-section from propath.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter i-obj-code like ub.shop.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
DEFINE INPUT PARAMETER selective as integer no-undo.
define input parameter pSubs as class ibs.th.ref.promo.promoactionsubs no-undo .
define input parameter p-log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: e455fc319afd, 3602, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/28 12:56:37 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-promo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-promo.p $":U .
define variable vss-description as character no-undo init "Пересылка промоакций на кассы".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile: ds-promo.i $ $Revision: cf3f2bc9c0d7, 3321, rls $".
define temp-table tt-promoaction no-undo
  like ub.PromoAction
  field status_lbl as character
  field sub        as class     Progress.Lang.Object serialize-hidden
  FIELD mode       AS char
  field Chang      as logical
  .
define temp-table tt-promoaction-one no-undo
  like tt-promoaction
  before-table tt-promoaction-one-before
  //field TypeDiscontlbl   as character
  field TypeDiscontsolo  as logical
  field TypeDiscontCombo as logical
  field TypeDiscontVisa  as logical
  field methodCalclbl    as character
  field typecondlbl      as character
  field scheduleName     as character
  field changeBL         as logical
  field scheduleType     as logical
  field extCodeSched     as character
  field ChangDateFl      as logical
  field simpGiftFl       as logical
  field CritgoodsFl      as logical
  .
define temp-table tt-PromoBc no-undo
  like ub.PromoGoods
  field sub     as class Progress.Lang.Object
  field bc-code    as character
  field mode       as character
  FIELD gdsName AS char
  field Chang      as logical
  .
define temp-table tt-PromoGoodsAppl no-undo
  like ub.PromoGoods
  FIELD gdsName AS char
  field sub     as class Progress.Lang.Object //serialize-hidden
  FIELD mode    AS char
  field Chang      as logical
  .
define temp-table tt-PromoGoodsCrite no-undo
  like tt-PromoGoodsAppl
  .
define temp-table tt-PromoSet no-undo
  like tt-PromoGoodsAppl
  .
define temp-table tt-PromoSetGoods no-undo
  like tt-PromoGoodsAppl
  .
define temp-table tt-PromoCardsBin no-undo
  like tt-PromoGoodsAppl.
define temp-table tt-PromoCriterion no-undo
  like ub.PromoCriterion
  field span as character
  field sub  as Progress.Lang.Object serialize-hidden
  FIELD mode AS char
  field spanBef as character
  field maxcrit as decimal
  .
define temp-table tt-PromoGift no-undo
  like ub.PromoGift
  FIELD gdsName AS char
  field sub     as class Progress.Lang.Object serialize-hidden
  FIELD mode    AS char
  field mess-gks as character
  .
define temp-table tt-PromoObject no-undo
  like ub.PromoObject
  FIELD objName  AS char
  FIELD FirmCode AS integer
  FIELD FirmName AS char
  FIELD objDbNum AS integer
  field sub      as class   Progress.Lang.Object serialize-hidden
  FIELD mode     AS char
  .
define temp-table tt-CashPay no-undo
  like ub.Cash-Pay
  .
define temp-table tt-promo-schedule-week no-undo
  like ub.promo-schedule-week
  field dtime-beg as datetime
  field dtime-end as datetime
  field isday_mon as logical
  field isday_tue as logical
  field isday_wed as logical
  field isday_thu as logical
  field isday_fri as logical
  field isday_sat as logical
  field isday_sun as logical
  field sub       as class     Progress.Lang.Object serialize-hidden
  field mode      as character
  .
define temp-table tt-promo-schedule-week2 no-undo
  like ub.promo-schedule-week
  field dtime-beg as datetime
  field dtime-end as datetime
//field wdaylabel as character
  field wdaynum   as integer
  field sub       as class     Progress.Lang.Object serialize-hidden
  field mode      as character
  .
define temp-table tt-promo-schedule-week3 no-undo
  like tt-promo-schedule-week
  .
define buffer tt-PromoCriterion-two for tt-PromoCriterion .
define buffer tt-PromoGift-two      for tt-PromoGift .
define dataset ds-promoaction-one
  for tt-promoaction-one
  , tt-CashPay
  , tt-PromoGoodsAppl
  , tt-PromoGoodsCrite
  , tt-PromoCriterion
  , tt-PromoGift
  , tt-PromoSet
  , tt-PromoSetGoods
  , tt-PromoObject
  , tt-PromoCardsBin
  , tt-PromoBc
//  , tt-promo-schedule
  , tt-promo-schedule-week
  , tt-promo-schedule-week2
  , tt-promo-schedule-week3
//  data-relation relGoodsAppl  for tt-promoaction-one, tt-PromoGoodsAppl     relation-fields (id, idaction)
  //data-relation relGoodsCrite for tt-promoaction-one, tt-PromoGoodsCrite    relation-fields (id, idaction) nested
  //data-relation relCriterion  for tt-promoaction-one, tt-PromoCriterion     relation-fields (id, idaction) nested
  //data-relation relGift       for tt-promoaction-one, tt-PromoGift          relation-fields (id, idaction) nested
//  data-relation relPromo      for tt-promoaction-one, tt-promo-schedule     relation-fields (id, idaction)
//  data-relation relPromoWeek  for tt-promo-schedule, tt-promo-schedule-week relation-fields (id, promosched-id)
  .
define variable hBuf-tt-PromoGoodsAppl-two as handle no-undo .
define dataset ds-PromoCriterion
  for tt-PromoCriterion-two
  , tt-PromoGift-two
  data-relation relGoodsAppl  for tt-PromoCriterion-two, tt-PromoGift-two  relation-fields (id, idcrit)
  .
define variable hDset-ds-promoaction-two as handle no-undo .
define variable hQtop-ds-promoaction-two as handle no-undo .
define variable hQrel-ds-promoaction-two as handle no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
DEFINE VARIABLE kassa-rub-code       as integer.
DEFINE VARIABLE ibmnalc              as integer   no-undo .
define variable multicurr            as logical   no-undo .
define variable conf-attr            as character no-undo .
DEFINE VARIABLE conf-par             as character no-undo.
DEFINE VARIABLE par-type             as character no-undo.
DEFINE VARIABLE dopi                 as decimal   no-undo.
DEFINE VARIABLE ii                   as integer   no-undo.
define variable v-host-code          like ub.sysconf.host-code no-undo .
define variable v-cp-is-use          as logical   no-undo .
define variable mariapayg            as character no-undo .
define variable mariapayp            as character no-undo .
define variable dr-list              as character no-undo .
define variable drcprank             as character no-undo .
define variable v-record             as character no-undo .
define variable v-found-maria-discnt as logical   no-undo .
procedure putc-16 :
  define parameter buffer buf_cash-desk for ub.cash-desk.
  define input parameter par-cash-num like ub.cash-desk.cash-num no-undo .
  define input parameter p-pos-version like ub.cash-desk.version no-undo .
  define variable v-value              as character no-undo .
  define variable v-type               as character no-undo .
  define variable v-index              as integer   no-undo .
  define variable v-ii                 as integer   no-undo .
  define variable v-jj                 as integer   no-undo .
  define variable v-plu                as character no-undo .
  define variable v-dop                as character no-undo .
  define variable v-dop2               as character no-undo .
  define variable v-cp-attr-code       as character no-undo .
  define variable attr-value           as character no-undo .
  define variable attr-type            as character no-undo .
  define variable v-maria-rule-num     as integer   no-undo .
  define variable v-maria-discnt-value as character no-undo .
  define variable v-skip-fields        as integer   no-undo .
  define variable v-version-dec        as decimal   no-undo .
  define variable v-paymentetc         as character no-undo .
  define buffer BUF_DIS-RULE      for UB.DIS-RULE.
  define buffer buf_dis-cp-rule   for ub.dis-cp-rule.
  define buffer buf_cash-pay-attr for ub.cash-pay-attr.
  define variable v-mode             as character no-undo .
  define variable objImp             as class     promotion                           no-undo.
  define variable v-retfl            as logical   no-undo .
  define variable v-i-num            as integer   no-undo .
  define variable v-i-counter        as integer   no-undo .
  define variable v-j-num            as integer   no-undo .
  define variable v-j-counter        as integer   no-undo .
  define variable v-stub             as integer   no-undo .
  define variable vTypePay           as character no-undo.
  define variable vIp                as integer   no-undo.
  define variable v-promo-action     as class     ibs.th.ref.promo.promoactionsub       no-undo .
  define variable v-storage          as class     ibs.th.gbl.storage.promoactionstorage no-undo .
  define variable v-subs             as class     promoActionSubs                       no-undo .
  define variable v-sub              as class     promoactionsub                        no-undo .
  define variable v-subsCrit         as class     ibs.th.ref.promo.promoGoodsSubs       no-undo .
  define variable v-subCrit          as class     ibs.th.ref.promo.promoGoodsSub        no-undo .
  define variable m-storage          as class     promoactionstorage                    no-undo .
  define variable v-subShed          as class     PromoSchedSub                         no-undo .
  define variable v-subShedWs        as class     promoSchedwSubs                       no-undo .
  define variable v-subShedW         as class     PromoSchedwSub                        no-undo .
  define variable v-subGood          as class     PromoGoodsSub                         no-undo .
  define variable v-subGdCrs         as class     promoGoodsSubs                        no-undo .
  define variable v-subCardBins      as class     promoGoodsSubs                        no-undo .
  define variable v-subCardBin       as class     promoGoodsSub                         no-undo .
  define variable v-subGdCr          as class     PromoGoodsSub                         no-undo .
  define variable v-subGoods         as class     promoGoodsSubs                        no-undo .
  define variable v-subGDCrites      as class     promoCriterionSubs                    no-undo .
  define variable v-subGDCrite       as class     promoCriterionSub                     no-undo .
  define variable v-subGifts         as class     promoGiftSubs                         no-undo .
  define variable v-subGift          as class     promoGiftSub                          no-undo .
  define variable v-subCrGifts       as class     promoGiftSubs                         no-undo .
  define variable v-subCrGift        as class     promoGiftSub                          no-undo .
  define variable v-subPromoSets     as class     promoGoodssubs                        no-undo .
  define variable v-subPromoSet      as class     promoGoodssub                         no-undo .
  define variable v-subPromoSetGoods as class     promoGoodssubs                        no-undo .
  define variable v-subPromoSetGood  as class     promoGoodssub                         no-undo .
  define variable v-length        as integer   no-undo .
  define variable v-lengthSh      as integer   no-undo .
  define variable v-lengthGD      as integer   no-undo .
  define variable v-lengthGif     as integer   no-undo .
  define variable v-i             as integer   no-undo .
  define variable v-j             as integer   no-undo .
  define variable v-size          as integer   no-undo .
  define variable v-sizeGif       as integer   no-undo .
  define variable vPricePromoSets as decimal   no-undo.
  define variable v-mess          as character no-undo .
  define variable v-mess-gks      as character no-undo .
  define variable vgift           as logical   no-undo.
  define variable vSetGoods       as logical   no-undo.
  define variable producer-int    as integer   no-undo .
  define variable change-BL       as integer   no-undo .
  define buffer buf_PromoAction for ub.PromoAction .
  define buffer buf_PromoSched  for ub.promo-schedule .
  define buffer buf_promogoods  for ub.PromoGoods .
  define variable v-attr-emrc as character no-undo .
  define variable v-attr-type as character no-undo .
  do
    on error undo, return error
    :
    if selective = 0 then
    do:
      if action = "D" then
      do:
        FOR EACH ub.PromoAction
          EXCLUSIVE-LOCK where ub.PromoAction.Status_ <> 3
          :
          v-promo-action = new PromoActionSub(i-obj-code).
          v-promo-action:ID = ub.PromoAction.id .
          m-storage = new ibs.th.gbl.storage.promoactionstorage () . // создать экземпляр, который работает с БД
          m-storage:refreshObj(v-promo-action, i-obj-code) . // прочесть коллекцию акций (все акции)
          v-promo-action:refreshChildObj() . // возвращает
          if ub.PromoAction.typecond = 4 then
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-version-dec = decimal(p-pos-version)
    no-error .
for each ub.PromoGoods no-lock where ub.PromoGoods.db-num = ub.PromoAction.db-num and
  ub.PromoGoods.idAction = ub.PromoAction.id and
  ub.PromoGoods.gds-code <> 0:
  find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
    ub.PromoAttr.attr-code = "bc-code" and
    ub.PromoGoods.idAction = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.gds-code = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
  if available (ub.PromoAttr) then
  do:
    find first ub.goods no-lock where ub.goods.gds-code = ub.PromoGoods.gds-code no-error .
    for first ub.bar-code no-lock where ub.bar-code.gds-code = ub.goods.gds-code and ub.bar-code.b-code = ub.goods.gds-code :
      producer-int = (if ub.goods.prod-type = 'орг':U then 1000000 else 0 ) + ub.goods.prod-code .
      run gds-attr-value in this-procedure (
        input ub.goods.gds-code
        ,input 'emrc-type':U
        ,output v-attr-emrc
        ,output v-attr-type) no-error.
      run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"
        , "DEL":U
        , OS2-time
        , string(ub.PromoAttr.attr-value))).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"
        , input string( ub.bar-code.b-code )
        , input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"
        , input string(producer-int), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"
        , input trim(string( ub.goods.struct, "X(40)")), input 1 ).
      find first country no-lock where country.alpha1 = ub.goods.alpha1 no-error.
      if available country then
        run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"
          , input country.short-name, input 1 ).
      find last ub.price-all no-lock where ub.price-all.gds-code = ub.goods.gds-code and
        ub.price-all.obj-code = i-obj-code and
        ub.price-all.obj-type = 'маг':U and
        ub.price-all.main-indication = 0 and
        ub.price-all.type-price = 0 no-error .
      if available (ub.price-all) then
      do:
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
          , input string(ub.price-all.price-sale)
          , input 1 ).
      end.
      else
      do:
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
          , input string(0)
          , input 1 ).
      end.
      run bgelib-tag-put in this-procedure ( input 3, input "IBCType"
        , input string( 0 ), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                        ~
        , input  v-attr-emrc, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                   ~
        , input  string(ub.bar-code.cli-base-rate), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
    end.
  end.
end.
  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-version-dec = decimal(p-pos-version)
    no-error .
run bgelib-tag-open in this-procedure ( input 2, input "PromoAction"
  , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
  then "ADD":U
  else "DEL":U),
  OS2-time, v-promo-action:ID)).
        find first ub.promoAttr where
          ub.promoAttr.attr-code = "charge-BL" and
          ub.promoAttr.tablename = "PromoPay" and
          v-promo-action:ID = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
          v-promo-action:db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3)))
          no-error.
        if available (ub.PromoAttr) then do:
          if logical(ub.PromoAttr.attr-value) = true then change-BL = 1 .
          else change-BL = 0 .
        end.
        else change-BL = 0 .
run bgelib-tag-put in this-procedure ( input 3, input "PAName":U
  , input string(v-promo-action:NameAction), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAType":U
  , input string(v-promo-action:TypeDiscont), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PABeg":U
  , input Xml-CD-DateTimetoString(v-promo-action:beg-date,0), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAEnd":U
  , input Xml-CD-DateTimetoString(if v-promo-action:changeDate <> ? then v-promo-action:changeDate else v-promo-action:end-date,86399), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAPriority":U
  , input string(v-promo-action:priority), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PALoyalRest":U
  , input string(change-BL), input 1 ).
vTypePay = "".
do vIp = 1 to num-entries(v-promo-action:paymenttype,chr(4)):
  vTypePay = vTypePay + "," + LEFT-TRIM(entry(1,
    entry(vIp,
    v-promo-action:paymenttype,
    chr(4)
    ),
    chr(3)
    ),
    "0").
end.
vTypePay = substring(vTypePay,2).
run bgelib-tag-put in this-procedure ( input 3, input "PAPayment":U
  , input vTypePay, input 0 ).
run bgelib-tag-put in this-procedure ( input 3, input "PACalcMethod":U
  , input string(v-promo-action:methodCalc), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PACondType":U
  , input string(v-promo-action:typecond), input 1 ).
v-subShedWs = v-promo-action:ScheduleWeek .
v-lengthSh = v-subShedWs:iCounter .
do v-i = 1 to v-lengthSh:
  v-size = v-subShedWs:GetItem(v-i) .
  v-subShedW = v-subShedWs:promoSchedwObjCurr .
  do v-ii = 1 to num-entries(v-subShedW:wdaylist):
    if v-subShedW:wdaylist = "0"
      then
    do v-j = 1 to 7:
      run bgelib-tag-open in this-procedure ( input 3, input "PASched","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASDay":U
        , input string(v-j), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASBeg":U
          , input Xml-CD-DateTimetoString(12/31/1989,v-subShedW:timebeg), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASEnd":U
          , input Xml-CD-DateTimetoString(12/31/9999,v-subShedW:timeend), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASched").
    end.
    else
    do:
      run bgelib-tag-open in this-procedure ( input 3, input "PASched","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASDay":U
        , input string(entry(v-ii,v-subShedW:wdaylist)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASBeg":U
         , input Xml-CD-DateTimetoString(12/31/1989,v-subShedW:timebeg), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASEnd":U
        , input Xml-CD-DateTimetoString(12/31/9999,v-subShedW:timeend), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASched").
    end.
  end.
end.
v-subGoods = v-promo-action:GoodsAppl .
if valid-object (v-subGoods) then
do:
  v-lengthGd = v-subGoods:iCounter .
  if v-lengthGd eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
    run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
  end.
  else
  do v-i = 1 to v-lengthGD:
    v-size = v-subGoods:GetItem(v-i) .
    v-subGood = v-subGoods:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAGId":U
      , input string(v-promo-action:id), input 1 ).
    if v-promo-action:typecond <> 4 then
    do:
      run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
        , input if v-subGood:dtSeason = "" then string(v-subGood:GdsCode) else v-subGood:dtSeason, input 1 ).
    end.
    else
    do:
      if v-subGood:dtSeason <> "" then
      do:
        run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
          , input v-subGood:dtSeason, input 1 ).
      end.
      else
      do:
        find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
          ub.PromoAttr.attr-code = "bc-code" and
          ub.PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
          ub.PromoAction.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
          v-subGood:GdsCode = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
        if available (ub.PromoAttr) then run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
            , input string(ub.PromoAttr.attr-value), input 1 ).
        else run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
            , input string(v-subGood:GdsCode), input 1 ).
      end.
    end.
    run bgelib-tag-put in this-procedure ( input 4, input "PAGPrice":U
      , input string(v-subGood:price), input 0 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
    if v-promo-action:typecond <> 4 then
    do:
      for each bar-code where bar-code.gds-code      eq v-subGood:GdsCode
        and bar-code.b-code                       ne v-subGood:GdsCode
        and bar-code.in-code                      eq ""
        and bar-code.part-code                    eq ""
        no-lock:
        run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
        run bgelib-tag-put in this-procedure ( input 4, input "PAGId":U
          , input string(v-promo-action:id), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
          , input string(bar-code.b-code), input 1 ).
        if (    v-subGood:price ne 0
          and v-subGood:price ne ?)
          then
        do:
          run bgelib-tag-put in this-procedure ( input 4, input "PAGPrice":U
            , input string(v-subGood:price * bar-code.cli-base-rate), input 0 ).
        end.
        run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
      end.
    end.
  end.
end.
v-subGdCrs = v-promo-action:GoodsCrits .
if valid-object (v-subGdCrs) then
do:
  if v-subGdCrs:iCounter ne 0 and v-promo-action:typecond <> 4
    then
  do v-i = 1 to v-subGdCrs:iCounter:
    v-subGdCrs:GetItem(v-i) .
    v-subGdCr = v-subGdCrs:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
      , input if v-subGdCr:dtSeason = "" then string(v-subGdCr:GdsCode) else v-subGdCr:dtSeason, input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
    for each bar-code where bar-code.gds-code       eq v-subGdCr:GdsCode
      and bar-code.b-code         ne v-subGdCr:GdsCode
      and bar-code.in-code        eq ""
      and bar-code.part-code      eq ""
      no-lock:
      run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
      run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
        , input string(bar-code.b-code), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
    end.
  end.
  else
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
  end.
end.
v-subcardbins= v-promo-action:CardsBin .
if valid-object (v-subcardbins) then
do:
  if v-subcardbins:iCounter ne 0
    then
  do v-i = 1 to v-subcardbins:iCounter:
    v-subcardbins:GetItem(v-i) .
    v-subCardBin = v-subcardbins:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
      , input string(v-subCardBin:nameset), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
  end.
end.
if  valid-object (v-subGdCrs)    and v-subGdCrs   :iCounter eq 0
  and valid-object (v-subcardbins) and v-subcardbins:iCounter eq 0
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
end.
v-subGifts = v-promo-action:Gifts .
if VALID-OBJECT (v-subGifts) then
do:
  do v-i = 1 to v-subGifts:iCounter:
    vgift = yes.
    v-subGifts:GetItem(v-i).
    v-subGift = v-subGifts:promoGiftObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGCode":U
      , input if v-subGift:dtSeason = "" then string(v-subGift:GdsCode) else v-subGift:dtSeason, input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGAmount":U
      , input string(v-subGift:qnty), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
  end.
end.
v-subGDCrites = v-promo-action:Criterion .
if valid-object (v-subGDCrites) then
do:
  if v-subGDCrites:iCounter eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
    run bgelib-tag-close in this-procedure ( input 3, input "PACond").
  end.
  else
  do v-ii = 1 to v-subGDCrites:iCounter:
    v-subGDCrites:GetItem(v-ii) .
    v-subGDCrite = v-subGDCrites:promoCriterionObjCurr .
    v-subGDCrite:refreshChildObj() .
    v-subCrGifts = v-subGDCrite:Gifts .
    if VALID-OBJECT (v-subCrGifts) then
    do:
      do v-i = 1 to v-subCrGifts:iCounter:
        vgift = yes.
        v-subCrGifts:GetItem(v-i) .
        v-subCrGift = v-subCrGifts:promoGiftObjCurr .
        if v-i = 1 then do:
        if v-subCrGift:mess <> "" or v-subCrGift:mess <> ? then v-mess = v-subCrGift:mess .
        if v-subCrGift:mess-gks <> "" or v-subCrGift:mess-gks <> ? then v-mess-gks = v-subCrGift:mess-gks .
        end.
        if v-subCrGift:GdsCode <> 0 then
        do:
          run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGId":U
            , input string(v-promo-action:id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGNum":U
            , input string(v-subGDCrite:id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGCode":U
            , input if v-subCrGift:dtSeason = "" then string(v-subCrGift:GdsCode) else v-subCrGift:dtSeason, input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGAmount":U
            , input string(v-subCrGift:qnty), input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
        end.
      end.
    end.
    vPricePromoSets = v-subGDCrite:discont .
    if v-promo-action:typecond <> 4 then
    do:
      run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
      run bgelib-tag-put in this-procedure ( input 4, input "PACId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACNum":U
        , input string(v-subGDCrite:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACAmount":U
        , input string(v-subGDCrite:mincrit), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACUPAmount":U
        , input string(v-subGDCrite:maxcrit), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACDiscount":U
        , input string(v-subGDCrite:discont), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACMessage":U
        , input string(v-mess), input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACMessage-GKS":U
        , input string(v-mess-gks), input 0 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PACond").
    end.
    else
    do:
      if (v-promo-action:methodCalc = 2 or v-promo-action:methodCalc = 1) and v-ii = 1 then
      do:
        run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
        run bgelib-tag-put in this-procedure ( input 4, input "PACId":U
          , input string(v-promo-action:id), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PACDiscount":U
          , input string(v-subGDCrite:discont), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "PACond").
      end.
    end.
  end.
end.
v-subPromoSets = v-promo-action:PromoSet .
if valid-object (v-subPromoSets) then
do:
  if v-promo-action:typecond <> 4 then
  do:
    run bgelib-tag-put in this-procedure ( input 3, input "PASetPrice":U
      , input string(vPricePromoSets), input 1 ).
  end.
  if v-subPromoSets:iCounter eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PASetSection","").
    run bgelib-tag-close in this-procedure ( input 3, input "PASetSection").
  end.
  else
  do v-i = 1 to v-subPromoSets:iCounter:
    v-subPromoSets:GetItem(v-i).
    v-subPromoSet = v-subPromoSets:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PASetSection","").
    run bgelib-tag-put in this-procedure ( input 4, input "PASSId":U
      , input string(v-subPromoSet:idaction), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSAmount":U
      , input string(v-subPromoSet:qnty), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSDiscount":U
      , input string(v-subPromoSet:price), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSNum":U
      , input string(v-subPromoSet:id), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PASetSection").
  end.
  do v-i = 1 to v-subPromoSets:iCounter:
    v-subPromoSets:GetItem(v-i).
    v-subPromoSet = v-subPromoSets:promoGoodsObjCurr .
    v-subPromoSet:refreshChildObj().
    v-subPromoSetGoods = v-subPromoSet:promoSetGoods.
    do v-j = 1 to v-subPromoSetGoods:iCounter:
      vsetgoods = yes.
      v-subPromoSetGoods:GetItem(v-j).
      v-subPromoSetGood = v-subPromoSetGoods:promoGoodsObjCurr.
      run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASGId":U
        , input string(v-subPromoSetGood:idaction), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASGCode":U
        , input if v-subPromoSetGood:dtSeason = "" then string(v-subPromoSetGood:GdsCode) else v-subPromoSetGood:dtSeason, input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASGNum":U
        , input string(v-subPromoSetGood:idSet), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
      for each bar-code where bar-code.gds-code       eq v-subPromoSetGood:GdsCode
        and bar-code.b-code         ne v-subPromoSetGood:GdsCode
        and bar-code.in-code        eq ""
        and bar-code.part-code      eq ""
        no-lock:
        run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
        run bgelib-tag-put in this-procedure ( input 4, input "PASGId":U
          , input string(v-subPromoSetGood:idaction), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASGCode":U
          , input string(bar-code.b-code), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASGNum":U
          , input string(v-subPromoSetGood:idSet), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
      end.
    end.
  end.
end.
if not vGift
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
end.
if not vSetgoods
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
end.
run bgelib-tag-close in this-procedure ( input 2, input "PromoAction").
        END.
      end.
      else
      do:
        FOR EACH ub.PromoAction
          EXCLUSIVE-LOCK where ub.PromoAction.Status_ = 1
          :
          v-promo-action = new PromoActionSub(i-obj-code).
          v-promo-action:ID = ub.PromoAction.id .
          m-storage = new ibs.th.gbl.storage.promoactionstorage () . // создать экземпляр, который работает с БД
          m-storage:refreshObj(v-promo-action, i-obj-code) . // прочесть коллекцию акций (все акции)
          v-promo-action:refreshChildObj() . // возвращает
          if ub.PromoAction.typecond = 4 then
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-version-dec = decimal(p-pos-version)
    no-error .
for each ub.PromoGoods no-lock where ub.PromoGoods.db-num = ub.PromoAction.db-num and
  ub.PromoGoods.idAction = ub.PromoAction.id and
  ub.PromoGoods.gds-code <> 0:
  find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
    ub.PromoAttr.attr-code = "bc-code" and
    ub.PromoGoods.idAction = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.gds-code = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
  if available (ub.PromoAttr) then
  do:
    find first ub.goods no-lock where ub.goods.gds-code = ub.PromoGoods.gds-code no-error .
    for first ub.bar-code no-lock where ub.bar-code.gds-code = ub.goods.gds-code and ub.bar-code.b-code = ub.goods.gds-code :
      producer-int = (if ub.goods.prod-type = 'орг':U then 1000000 else 0 ) + ub.goods.prod-code .
      run gds-attr-value in this-procedure (
        input ub.goods.gds-code
        ,input 'emrc-type':U
        ,output v-attr-emrc
        ,output v-attr-type) no-error.
      run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"
        , "DEL":U
        , OS2-time
        , string(ub.PromoAttr.attr-value))).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"
        , input string( ub.bar-code.b-code )
        , input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"
        , input string(producer-int), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"
        , input trim(string( ub.goods.struct, "X(40)")), input 1 ).
      find first country no-lock where country.alpha1 = ub.goods.alpha1 no-error.
      if available country then
        run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"
          , input country.short-name, input 1 ).
      find last ub.price-all no-lock where ub.price-all.gds-code = ub.goods.gds-code and
        ub.price-all.obj-code = i-obj-code and
        ub.price-all.obj-type = 'маг':U and
        ub.price-all.main-indication = 0 and
        ub.price-all.type-price = 0 no-error .
      if available (ub.price-all) then
      do:
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
          , input string(ub.price-all.price-sale)
          , input 1 ).
      end.
      else
      do:
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
          , input string(0)
          , input 1 ).
      end.
      run bgelib-tag-put in this-procedure ( input 3, input "IBCType"
        , input string( 0 ), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                        ~
        , input  v-attr-emrc, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                   ~
        , input  string(ub.bar-code.cli-base-rate), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
    end.
  end.
end.
  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-version-dec = decimal(p-pos-version)
    no-error .
run bgelib-tag-open in this-procedure ( input 2, input "PromoAction"
  , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
  then "ADD":U
  else "DEL":U),
  OS2-time, v-promo-action:ID)).
        find first ub.promoAttr where
          ub.promoAttr.attr-code = "charge-BL" and
          ub.promoAttr.tablename = "PromoPay" and
          v-promo-action:ID = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
          v-promo-action:db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3)))
          no-error.
        if available (ub.PromoAttr) then do:
          if logical(ub.PromoAttr.attr-value) = true then change-BL = 1 .
          else change-BL = 0 .
        end.
        else change-BL = 0 .
run bgelib-tag-put in this-procedure ( input 3, input "PAName":U
  , input string(v-promo-action:NameAction), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAType":U
  , input string(v-promo-action:TypeDiscont), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PABeg":U
  , input Xml-CD-DateTimetoString(v-promo-action:beg-date,0), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAEnd":U
  , input Xml-CD-DateTimetoString(if v-promo-action:changeDate <> ? then v-promo-action:changeDate else v-promo-action:end-date,86399), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAPriority":U
  , input string(v-promo-action:priority), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PALoyalRest":U
  , input string(change-BL), input 1 ).
vTypePay = "".
do vIp = 1 to num-entries(v-promo-action:paymenttype,chr(4)):
  vTypePay = vTypePay + "," + LEFT-TRIM(entry(1,
    entry(vIp,
    v-promo-action:paymenttype,
    chr(4)
    ),
    chr(3)
    ),
    "0").
end.
vTypePay = substring(vTypePay,2).
run bgelib-tag-put in this-procedure ( input 3, input "PAPayment":U
  , input vTypePay, input 0 ).
run bgelib-tag-put in this-procedure ( input 3, input "PACalcMethod":U
  , input string(v-promo-action:methodCalc), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PACondType":U
  , input string(v-promo-action:typecond), input 1 ).
v-subShedWs = v-promo-action:ScheduleWeek .
v-lengthSh = v-subShedWs:iCounter .
do v-i = 1 to v-lengthSh:
  v-size = v-subShedWs:GetItem(v-i) .
  v-subShedW = v-subShedWs:promoSchedwObjCurr .
  do v-ii = 1 to num-entries(v-subShedW:wdaylist):
    if v-subShedW:wdaylist = "0"
      then
    do v-j = 1 to 7:
      run bgelib-tag-open in this-procedure ( input 3, input "PASched","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASDay":U
        , input string(v-j), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASBeg":U
          , input Xml-CD-DateTimetoString(12/31/1989,v-subShedW:timebeg), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASEnd":U
          , input Xml-CD-DateTimetoString(12/31/9999,v-subShedW:timeend), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASched").
    end.
    else
    do:
      run bgelib-tag-open in this-procedure ( input 3, input "PASched","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASDay":U
        , input string(entry(v-ii,v-subShedW:wdaylist)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASBeg":U
         , input Xml-CD-DateTimetoString(12/31/1989,v-subShedW:timebeg), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASEnd":U
        , input Xml-CD-DateTimetoString(12/31/9999,v-subShedW:timeend), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASched").
    end.
  end.
end.
v-subGoods = v-promo-action:GoodsAppl .
if valid-object (v-subGoods) then
do:
  v-lengthGd = v-subGoods:iCounter .
  if v-lengthGd eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
    run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
  end.
  else
  do v-i = 1 to v-lengthGD:
    v-size = v-subGoods:GetItem(v-i) .
    v-subGood = v-subGoods:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAGId":U
      , input string(v-promo-action:id), input 1 ).
    if v-promo-action:typecond <> 4 then
    do:
      run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
        , input if v-subGood:dtSeason = "" then string(v-subGood:GdsCode) else v-subGood:dtSeason, input 1 ).
    end.
    else
    do:
      if v-subGood:dtSeason <> "" then
      do:
        run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
          , input v-subGood:dtSeason, input 1 ).
      end.
      else
      do:
        find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
          ub.PromoAttr.attr-code = "bc-code" and
          ub.PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
          ub.PromoAction.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
          v-subGood:GdsCode = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
        if available (ub.PromoAttr) then run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
            , input string(ub.PromoAttr.attr-value), input 1 ).
        else run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
            , input string(v-subGood:GdsCode), input 1 ).
      end.
    end.
    run bgelib-tag-put in this-procedure ( input 4, input "PAGPrice":U
      , input string(v-subGood:price), input 0 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
    if v-promo-action:typecond <> 4 then
    do:
      for each bar-code where bar-code.gds-code      eq v-subGood:GdsCode
        and bar-code.b-code                       ne v-subGood:GdsCode
        and bar-code.in-code                      eq ""
        and bar-code.part-code                    eq ""
        no-lock:
        run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
        run bgelib-tag-put in this-procedure ( input 4, input "PAGId":U
          , input string(v-promo-action:id), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
          , input string(bar-code.b-code), input 1 ).
        if (    v-subGood:price ne 0
          and v-subGood:price ne ?)
          then
        do:
          run bgelib-tag-put in this-procedure ( input 4, input "PAGPrice":U
            , input string(v-subGood:price * bar-code.cli-base-rate), input 0 ).
        end.
        run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
      end.
    end.
  end.
end.
v-subGdCrs = v-promo-action:GoodsCrits .
if valid-object (v-subGdCrs) then
do:
  if v-subGdCrs:iCounter ne 0 and v-promo-action:typecond <> 4
    then
  do v-i = 1 to v-subGdCrs:iCounter:
    v-subGdCrs:GetItem(v-i) .
    v-subGdCr = v-subGdCrs:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
      , input if v-subGdCr:dtSeason = "" then string(v-subGdCr:GdsCode) else v-subGdCr:dtSeason, input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
    for each bar-code where bar-code.gds-code       eq v-subGdCr:GdsCode
      and bar-code.b-code         ne v-subGdCr:GdsCode
      and bar-code.in-code        eq ""
      and bar-code.part-code      eq ""
      no-lock:
      run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
      run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
        , input string(bar-code.b-code), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
    end.
  end.
  else
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
  end.
end.
v-subcardbins= v-promo-action:CardsBin .
if valid-object (v-subcardbins) then
do:
  if v-subcardbins:iCounter ne 0
    then
  do v-i = 1 to v-subcardbins:iCounter:
    v-subcardbins:GetItem(v-i) .
    v-subCardBin = v-subcardbins:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
      , input string(v-subCardBin:nameset), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
  end.
end.
if  valid-object (v-subGdCrs)    and v-subGdCrs   :iCounter eq 0
  and valid-object (v-subcardbins) and v-subcardbins:iCounter eq 0
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
end.
v-subGifts = v-promo-action:Gifts .
if VALID-OBJECT (v-subGifts) then
do:
  do v-i = 1 to v-subGifts:iCounter:
    vgift = yes.
    v-subGifts:GetItem(v-i).
    v-subGift = v-subGifts:promoGiftObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGCode":U
      , input if v-subGift:dtSeason = "" then string(v-subGift:GdsCode) else v-subGift:dtSeason, input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGAmount":U
      , input string(v-subGift:qnty), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
  end.
end.
v-subGDCrites = v-promo-action:Criterion .
if valid-object (v-subGDCrites) then
do:
  if v-subGDCrites:iCounter eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
    run bgelib-tag-close in this-procedure ( input 3, input "PACond").
  end.
  else
  do v-ii = 1 to v-subGDCrites:iCounter:
    v-subGDCrites:GetItem(v-ii) .
    v-subGDCrite = v-subGDCrites:promoCriterionObjCurr .
    v-subGDCrite:refreshChildObj() .
    v-subCrGifts = v-subGDCrite:Gifts .
    if VALID-OBJECT (v-subCrGifts) then
    do:
      do v-i = 1 to v-subCrGifts:iCounter:
        vgift = yes.
        v-subCrGifts:GetItem(v-i) .
        v-subCrGift = v-subCrGifts:promoGiftObjCurr .
        if v-i = 1 then do:
        if v-subCrGift:mess <> "" or v-subCrGift:mess <> ? then v-mess = v-subCrGift:mess .
        if v-subCrGift:mess-gks <> "" or v-subCrGift:mess-gks <> ? then v-mess-gks = v-subCrGift:mess-gks .
        end.
        if v-subCrGift:GdsCode <> 0 then
        do:
          run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGId":U
            , input string(v-promo-action:id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGNum":U
            , input string(v-subGDCrite:id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGCode":U
            , input if v-subCrGift:dtSeason = "" then string(v-subCrGift:GdsCode) else v-subCrGift:dtSeason, input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGAmount":U
            , input string(v-subCrGift:qnty), input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
        end.
      end.
    end.
    vPricePromoSets = v-subGDCrite:discont .
    if v-promo-action:typecond <> 4 then
    do:
      run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
      run bgelib-tag-put in this-procedure ( input 4, input "PACId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACNum":U
        , input string(v-subGDCrite:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACAmount":U
        , input string(v-subGDCrite:mincrit), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACUPAmount":U
        , input string(v-subGDCrite:maxcrit), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACDiscount":U
        , input string(v-subGDCrite:discont), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACMessage":U
        , input string(v-mess), input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACMessage-GKS":U
        , input string(v-mess-gks), input 0 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PACond").
    end.
    else
    do:
      if (v-promo-action:methodCalc = 2 or v-promo-action:methodCalc = 1) and v-ii = 1 then
      do:
        run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
        run bgelib-tag-put in this-procedure ( input 4, input "PACId":U
          , input string(v-promo-action:id), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PACDiscount":U
          , input string(v-subGDCrite:discont), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "PACond").
      end.
    end.
  end.
end.
v-subPromoSets = v-promo-action:PromoSet .
if valid-object (v-subPromoSets) then
do:
  if v-promo-action:typecond <> 4 then
  do:
    run bgelib-tag-put in this-procedure ( input 3, input "PASetPrice":U
      , input string(vPricePromoSets), input 1 ).
  end.
  if v-subPromoSets:iCounter eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PASetSection","").
    run bgelib-tag-close in this-procedure ( input 3, input "PASetSection").
  end.
  else
  do v-i = 1 to v-subPromoSets:iCounter:
    v-subPromoSets:GetItem(v-i).
    v-subPromoSet = v-subPromoSets:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PASetSection","").
    run bgelib-tag-put in this-procedure ( input 4, input "PASSId":U
      , input string(v-subPromoSet:idaction), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSAmount":U
      , input string(v-subPromoSet:qnty), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSDiscount":U
      , input string(v-subPromoSet:price), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSNum":U
      , input string(v-subPromoSet:id), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PASetSection").
  end.
  do v-i = 1 to v-subPromoSets:iCounter:
    v-subPromoSets:GetItem(v-i).
    v-subPromoSet = v-subPromoSets:promoGoodsObjCurr .
    v-subPromoSet:refreshChildObj().
    v-subPromoSetGoods = v-subPromoSet:promoSetGoods.
    do v-j = 1 to v-subPromoSetGoods:iCounter:
      vsetgoods = yes.
      v-subPromoSetGoods:GetItem(v-j).
      v-subPromoSetGood = v-subPromoSetGoods:promoGoodsObjCurr.
      run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASGId":U
        , input string(v-subPromoSetGood:idaction), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASGCode":U
        , input if v-subPromoSetGood:dtSeason = "" then string(v-subPromoSetGood:GdsCode) else v-subPromoSetGood:dtSeason, input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASGNum":U
        , input string(v-subPromoSetGood:idSet), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
      for each bar-code where bar-code.gds-code       eq v-subPromoSetGood:GdsCode
        and bar-code.b-code         ne v-subPromoSetGood:GdsCode
        and bar-code.in-code        eq ""
        and bar-code.part-code      eq ""
        no-lock:
        run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
        run bgelib-tag-put in this-procedure ( input 4, input "PASGId":U
          , input string(v-subPromoSetGood:idaction), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASGCode":U
          , input string(bar-code.b-code), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASGNum":U
          , input string(v-subPromoSetGood:idSet), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
      end.
    end.
  end.
end.
if not vGift
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
end.
if not vSetgoods
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
end.
run bgelib-tag-close in this-procedure ( input 2, input "PromoAction").
          if ub.PromoAction.typecond = 4 and action = "U":U then
          do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
   v-version-dec = decimal(p-pos-version)
    no-error .
for each ub.PromoGoods no-lock where ub.PromoGoods.db-num = ub.PromoAction.db-num and
  ub.PromoGoods.idAction = ub.PromoAction.id and
  ub.PromoGoods.gds-code <> 0:
  find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
    ub.PromoAttr.attr-code = "bc-code" and
    ub.PromoGoods.idAction = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.gds-code = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
  if available (ub.PromoAttr) then
  do:
    find first ub.goods no-lock where ub.goods.gds-code = ub.PromoGoods.gds-code no-error .
    for first ub.bar-code no-lock where ub.bar-code.gds-code = ub.goods.gds-code and ub.bar-code.b-code = ub.goods.gds-code:
      producer-int = (if ub.goods.prod-type = 'орг':U then 1000000 else 0 ) + ub.goods.prod-code .
      run gds-attr-value in this-procedure (
        input ub.goods.gds-code
        ,input 'emrc-type':U
        ,output v-attr-emrc
        ,output v-attr-type) no-error.
      run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"
         , "ADD":U
         , OS2-time
         , string(ub.PromoAttr.attr-value))).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"
         , input string( ub.bar-code.b-code )
         , input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"
         , input string(producer-int), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"
         , input trim(string( ub.goods.struct, "X(40)")), input 1 ).
      find first country no-lock where country.alpha1 = ub.goods.alpha1 no-error.
      if available country then
         run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"
            , input country.short-name, input 1 ).
      find last ub.price-all no-lock where ub.price-all.gds-code = ub.goods.gds-code and
         ub.price-all.obj-code = i-obj-code and
         ub.price-all.obj-type = 'маг':U and
         ub.price-all.main-indication = 0 and
         ub.price-all.type-price = 0 no-error .
      if available (ub.price-all) then do:
      run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
         , input string(ub.price-all.price-sale)
         , input 1 ).
      end.
      else do:
      run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
         , input string(0)
         , input 1 ).
      end.
      run bgelib-tag-put in this-procedure ( input 3, input "IBCType"
        , input string( 3 ), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                        ~
        , input  v-attr-emrc, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                   ~
        , input  string(ub.bar-code.cli-base-rate), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
    end.
  end.
end.
          end.
        END.
      end.
    end.
    else
    do:
      DO ii = 1 to pSubs:iCounter:
        pSubs:GetItem(ii).
        v-promo-action = pSubs:promoActionObjCurr .
        if action = "D" then
        do:
          FIND FIRST ub.PromoAction No-LOCK WHERE
            ub.PromoAction.id = v-promo-action:ID and ub.PromoAction.Status_ <> 3 No-ERROR.
          IF avail ub.PromoAction then
          do:
            m-storage = new ibs.th.gbl.storage.promoactionstorage () . // создать экземпляр, который работает с БД
            m-storage:refreshObj(v-promo-action, i-obj-code) . // прочесть коллекцию акций (все акции)
            v-promo-action:refreshChildObj() . // возвращает
            if ub.PromoAction.typecond = 4 then
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-version-dec = decimal(p-pos-version)
    no-error .
for each ub.PromoGoods no-lock where ub.PromoGoods.db-num = ub.PromoAction.db-num and
  ub.PromoGoods.idAction = ub.PromoAction.id and
  ub.PromoGoods.gds-code <> 0:
  find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
    ub.PromoAttr.attr-code = "bc-code" and
    ub.PromoGoods.idAction = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.gds-code = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
  if available (ub.PromoAttr) then
  do:
    find first ub.goods no-lock where ub.goods.gds-code = ub.PromoGoods.gds-code no-error .
    for first ub.bar-code no-lock where ub.bar-code.gds-code = ub.goods.gds-code and ub.bar-code.b-code = ub.goods.gds-code :
      producer-int = (if ub.goods.prod-type = 'орг':U then 1000000 else 0 ) + ub.goods.prod-code .
      run gds-attr-value in this-procedure (
        input ub.goods.gds-code
        ,input 'emrc-type':U
        ,output v-attr-emrc
        ,output v-attr-type) no-error.
      run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"
        , "DEL":U
        , OS2-time
        , string(ub.PromoAttr.attr-value))).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"
        , input string( ub.bar-code.b-code )
        , input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"
        , input string(producer-int), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"
        , input trim(string( ub.goods.struct, "X(40)")), input 1 ).
      find first country no-lock where country.alpha1 = ub.goods.alpha1 no-error.
      if available country then
        run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"
          , input country.short-name, input 1 ).
      find last ub.price-all no-lock where ub.price-all.gds-code = ub.goods.gds-code and
        ub.price-all.obj-code = i-obj-code and
        ub.price-all.obj-type = 'маг':U and
        ub.price-all.main-indication = 0 and
        ub.price-all.type-price = 0 no-error .
      if available (ub.price-all) then
      do:
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
          , input string(ub.price-all.price-sale)
          , input 1 ).
      end.
      else
      do:
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
          , input string(0)
          , input 1 ).
      end.
      run bgelib-tag-put in this-procedure ( input 3, input "IBCType"
        , input string( 0 ), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                        ~
        , input  v-attr-emrc, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                   ~
        , input  string(ub.bar-code.cli-base-rate), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
    end.
  end.
end.
  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-version-dec = decimal(p-pos-version)
    no-error .
run bgelib-tag-open in this-procedure ( input 2, input "PromoAction"
  , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
  then "ADD":U
  else "DEL":U),
  OS2-time, v-promo-action:ID)).
        find first ub.promoAttr where
          ub.promoAttr.attr-code = "charge-BL" and
          ub.promoAttr.tablename = "PromoPay" and
          v-promo-action:ID = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
          v-promo-action:db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3)))
          no-error.
        if available (ub.PromoAttr) then do:
          if logical(ub.PromoAttr.attr-value) = true then change-BL = 1 .
          else change-BL = 0 .
        end.
        else change-BL = 0 .
run bgelib-tag-put in this-procedure ( input 3, input "PAName":U
  , input string(v-promo-action:NameAction), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAType":U
  , input string(v-promo-action:TypeDiscont), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PABeg":U
  , input Xml-CD-DateTimetoString(v-promo-action:beg-date,0), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAEnd":U
  , input Xml-CD-DateTimetoString(if v-promo-action:changeDate <> ? then v-promo-action:changeDate else v-promo-action:end-date,86399), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAPriority":U
  , input string(v-promo-action:priority), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PALoyalRest":U
  , input string(change-BL), input 1 ).
vTypePay = "".
do vIp = 1 to num-entries(v-promo-action:paymenttype,chr(4)):
  vTypePay = vTypePay + "," + LEFT-TRIM(entry(1,
    entry(vIp,
    v-promo-action:paymenttype,
    chr(4)
    ),
    chr(3)
    ),
    "0").
end.
vTypePay = substring(vTypePay,2).
run bgelib-tag-put in this-procedure ( input 3, input "PAPayment":U
  , input vTypePay, input 0 ).
run bgelib-tag-put in this-procedure ( input 3, input "PACalcMethod":U
  , input string(v-promo-action:methodCalc), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PACondType":U
  , input string(v-promo-action:typecond), input 1 ).
v-subShedWs = v-promo-action:ScheduleWeek .
v-lengthSh = v-subShedWs:iCounter .
do v-i = 1 to v-lengthSh:
  v-size = v-subShedWs:GetItem(v-i) .
  v-subShedW = v-subShedWs:promoSchedwObjCurr .
  do v-ii = 1 to num-entries(v-subShedW:wdaylist):
    if v-subShedW:wdaylist = "0"
      then
    do v-j = 1 to 7:
      run bgelib-tag-open in this-procedure ( input 3, input "PASched","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASDay":U
        , input string(v-j), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASBeg":U
          , input Xml-CD-DateTimetoString(12/31/1989,v-subShedW:timebeg), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASEnd":U
          , input Xml-CD-DateTimetoString(12/31/9999,v-subShedW:timeend), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASched").
    end.
    else
    do:
      run bgelib-tag-open in this-procedure ( input 3, input "PASched","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASDay":U
        , input string(entry(v-ii,v-subShedW:wdaylist)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASBeg":U
         , input Xml-CD-DateTimetoString(12/31/1989,v-subShedW:timebeg), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASEnd":U
        , input Xml-CD-DateTimetoString(12/31/9999,v-subShedW:timeend), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASched").
    end.
  end.
end.
v-subGoods = v-promo-action:GoodsAppl .
if valid-object (v-subGoods) then
do:
  v-lengthGd = v-subGoods:iCounter .
  if v-lengthGd eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
    run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
  end.
  else
  do v-i = 1 to v-lengthGD:
    v-size = v-subGoods:GetItem(v-i) .
    v-subGood = v-subGoods:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAGId":U
      , input string(v-promo-action:id), input 1 ).
    if v-promo-action:typecond <> 4 then
    do:
      run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
        , input if v-subGood:dtSeason = "" then string(v-subGood:GdsCode) else v-subGood:dtSeason, input 1 ).
    end.
    else
    do:
      if v-subGood:dtSeason <> "" then
      do:
        run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
          , input v-subGood:dtSeason, input 1 ).
      end.
      else
      do:
        find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
          ub.PromoAttr.attr-code = "bc-code" and
          ub.PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
          ub.PromoAction.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
          v-subGood:GdsCode = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
        if available (ub.PromoAttr) then run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
            , input string(ub.PromoAttr.attr-value), input 1 ).
        else run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
            , input string(v-subGood:GdsCode), input 1 ).
      end.
    end.
    run bgelib-tag-put in this-procedure ( input 4, input "PAGPrice":U
      , input string(v-subGood:price), input 0 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
    if v-promo-action:typecond <> 4 then
    do:
      for each bar-code where bar-code.gds-code      eq v-subGood:GdsCode
        and bar-code.b-code                       ne v-subGood:GdsCode
        and bar-code.in-code                      eq ""
        and bar-code.part-code                    eq ""
        no-lock:
        run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
        run bgelib-tag-put in this-procedure ( input 4, input "PAGId":U
          , input string(v-promo-action:id), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
          , input string(bar-code.b-code), input 1 ).
        if (    v-subGood:price ne 0
          and v-subGood:price ne ?)
          then
        do:
          run bgelib-tag-put in this-procedure ( input 4, input "PAGPrice":U
            , input string(v-subGood:price * bar-code.cli-base-rate), input 0 ).
        end.
        run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
      end.
    end.
  end.
end.
v-subGdCrs = v-promo-action:GoodsCrits .
if valid-object (v-subGdCrs) then
do:
  if v-subGdCrs:iCounter ne 0 and v-promo-action:typecond <> 4
    then
  do v-i = 1 to v-subGdCrs:iCounter:
    v-subGdCrs:GetItem(v-i) .
    v-subGdCr = v-subGdCrs:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
      , input if v-subGdCr:dtSeason = "" then string(v-subGdCr:GdsCode) else v-subGdCr:dtSeason, input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
    for each bar-code where bar-code.gds-code       eq v-subGdCr:GdsCode
      and bar-code.b-code         ne v-subGdCr:GdsCode
      and bar-code.in-code        eq ""
      and bar-code.part-code      eq ""
      no-lock:
      run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
      run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
        , input string(bar-code.b-code), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
    end.
  end.
  else
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
  end.
end.
v-subcardbins= v-promo-action:CardsBin .
if valid-object (v-subcardbins) then
do:
  if v-subcardbins:iCounter ne 0
    then
  do v-i = 1 to v-subcardbins:iCounter:
    v-subcardbins:GetItem(v-i) .
    v-subCardBin = v-subcardbins:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
      , input string(v-subCardBin:nameset), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
  end.
end.
if  valid-object (v-subGdCrs)    and v-subGdCrs   :iCounter eq 0
  and valid-object (v-subcardbins) and v-subcardbins:iCounter eq 0
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
end.
v-subGifts = v-promo-action:Gifts .
if VALID-OBJECT (v-subGifts) then
do:
  do v-i = 1 to v-subGifts:iCounter:
    vgift = yes.
    v-subGifts:GetItem(v-i).
    v-subGift = v-subGifts:promoGiftObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGCode":U
      , input if v-subGift:dtSeason = "" then string(v-subGift:GdsCode) else v-subGift:dtSeason, input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGAmount":U
      , input string(v-subGift:qnty), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
  end.
end.
v-subGDCrites = v-promo-action:Criterion .
if valid-object (v-subGDCrites) then
do:
  if v-subGDCrites:iCounter eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
    run bgelib-tag-close in this-procedure ( input 3, input "PACond").
  end.
  else
  do v-ii = 1 to v-subGDCrites:iCounter:
    v-subGDCrites:GetItem(v-ii) .
    v-subGDCrite = v-subGDCrites:promoCriterionObjCurr .
    v-subGDCrite:refreshChildObj() .
    v-subCrGifts = v-subGDCrite:Gifts .
    if VALID-OBJECT (v-subCrGifts) then
    do:
      do v-i = 1 to v-subCrGifts:iCounter:
        vgift = yes.
        v-subCrGifts:GetItem(v-i) .
        v-subCrGift = v-subCrGifts:promoGiftObjCurr .
        if v-i = 1 then do:
        if v-subCrGift:mess <> "" or v-subCrGift:mess <> ? then v-mess = v-subCrGift:mess .
        if v-subCrGift:mess-gks <> "" or v-subCrGift:mess-gks <> ? then v-mess-gks = v-subCrGift:mess-gks .
        end.
        if v-subCrGift:GdsCode <> 0 then
        do:
          run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGId":U
            , input string(v-promo-action:id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGNum":U
            , input string(v-subGDCrite:id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGCode":U
            , input if v-subCrGift:dtSeason = "" then string(v-subCrGift:GdsCode) else v-subCrGift:dtSeason, input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGAmount":U
            , input string(v-subCrGift:qnty), input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
        end.
      end.
    end.
    vPricePromoSets = v-subGDCrite:discont .
    if v-promo-action:typecond <> 4 then
    do:
      run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
      run bgelib-tag-put in this-procedure ( input 4, input "PACId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACNum":U
        , input string(v-subGDCrite:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACAmount":U
        , input string(v-subGDCrite:mincrit), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACUPAmount":U
        , input string(v-subGDCrite:maxcrit), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACDiscount":U
        , input string(v-subGDCrite:discont), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACMessage":U
        , input string(v-mess), input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACMessage-GKS":U
        , input string(v-mess-gks), input 0 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PACond").
    end.
    else
    do:
      if (v-promo-action:methodCalc = 2 or v-promo-action:methodCalc = 1) and v-ii = 1 then
      do:
        run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
        run bgelib-tag-put in this-procedure ( input 4, input "PACId":U
          , input string(v-promo-action:id), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PACDiscount":U
          , input string(v-subGDCrite:discont), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "PACond").
      end.
    end.
  end.
end.
v-subPromoSets = v-promo-action:PromoSet .
if valid-object (v-subPromoSets) then
do:
  if v-promo-action:typecond <> 4 then
  do:
    run bgelib-tag-put in this-procedure ( input 3, input "PASetPrice":U
      , input string(vPricePromoSets), input 1 ).
  end.
  if v-subPromoSets:iCounter eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PASetSection","").
    run bgelib-tag-close in this-procedure ( input 3, input "PASetSection").
  end.
  else
  do v-i = 1 to v-subPromoSets:iCounter:
    v-subPromoSets:GetItem(v-i).
    v-subPromoSet = v-subPromoSets:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PASetSection","").
    run bgelib-tag-put in this-procedure ( input 4, input "PASSId":U
      , input string(v-subPromoSet:idaction), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSAmount":U
      , input string(v-subPromoSet:qnty), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSDiscount":U
      , input string(v-subPromoSet:price), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSNum":U
      , input string(v-subPromoSet:id), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PASetSection").
  end.
  do v-i = 1 to v-subPromoSets:iCounter:
    v-subPromoSets:GetItem(v-i).
    v-subPromoSet = v-subPromoSets:promoGoodsObjCurr .
    v-subPromoSet:refreshChildObj().
    v-subPromoSetGoods = v-subPromoSet:promoSetGoods.
    do v-j = 1 to v-subPromoSetGoods:iCounter:
      vsetgoods = yes.
      v-subPromoSetGoods:GetItem(v-j).
      v-subPromoSetGood = v-subPromoSetGoods:promoGoodsObjCurr.
      run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASGId":U
        , input string(v-subPromoSetGood:idaction), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASGCode":U
        , input if v-subPromoSetGood:dtSeason = "" then string(v-subPromoSetGood:GdsCode) else v-subPromoSetGood:dtSeason, input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASGNum":U
        , input string(v-subPromoSetGood:idSet), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
      for each bar-code where bar-code.gds-code       eq v-subPromoSetGood:GdsCode
        and bar-code.b-code         ne v-subPromoSetGood:GdsCode
        and bar-code.in-code        eq ""
        and bar-code.part-code      eq ""
        no-lock:
        run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
        run bgelib-tag-put in this-procedure ( input 4, input "PASGId":U
          , input string(v-subPromoSetGood:idaction), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASGCode":U
          , input string(bar-code.b-code), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASGNum":U
          , input string(v-subPromoSetGood:idSet), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
      end.
    end.
  end.
end.
if not vGift
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
end.
if not vSetgoods
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
end.
run bgelib-tag-close in this-procedure ( input 2, input "PromoAction").
          end.
        end.
        else
        do:
          FIND FIRST ub.PromoAction No-LOCK WHERE
            ub.PromoAction.id = v-promo-action:ID and ub.PromoAction.Status_ = 1 No-ERROR.
          IF avail ub.PromoAction then
          do:
            m-storage = new ibs.th.gbl.storage.promoactionstorage () . // создать экземпляр, который работает с БД
            m-storage:refreshObj(v-promo-action, i-obj-code) . // прочесть коллекцию акций (все акции)
            v-promo-action:refreshChildObj() . // возвращает
            if ub.PromoAction.typecond = 4 then
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-version-dec = decimal(p-pos-version)
    no-error .
for each ub.PromoGoods no-lock where ub.PromoGoods.db-num = ub.PromoAction.db-num and
  ub.PromoGoods.idAction = ub.PromoAction.id and
  ub.PromoGoods.gds-code <> 0:
  find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
    ub.PromoAttr.attr-code = "bc-code" and
    ub.PromoGoods.idAction = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.gds-code = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
  if available (ub.PromoAttr) then
  do:
    find first ub.goods no-lock where ub.goods.gds-code = ub.PromoGoods.gds-code no-error .
    for first ub.bar-code no-lock where ub.bar-code.gds-code = ub.goods.gds-code and ub.bar-code.b-code = ub.goods.gds-code :
      producer-int = (if ub.goods.prod-type = 'орг':U then 1000000 else 0 ) + ub.goods.prod-code .
      run gds-attr-value in this-procedure (
        input ub.goods.gds-code
        ,input 'emrc-type':U
        ,output v-attr-emrc
        ,output v-attr-type) no-error.
      run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"
        , "DEL":U
        , OS2-time
        , string(ub.PromoAttr.attr-value))).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"
        , input string( ub.bar-code.b-code )
        , input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"
        , input string(producer-int), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"
        , input trim(string( ub.goods.struct, "X(40)")), input 1 ).
      find first country no-lock where country.alpha1 = ub.goods.alpha1 no-error.
      if available country then
        run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"
          , input country.short-name, input 1 ).
      find last ub.price-all no-lock where ub.price-all.gds-code = ub.goods.gds-code and
        ub.price-all.obj-code = i-obj-code and
        ub.price-all.obj-type = 'маг':U and
        ub.price-all.main-indication = 0 and
        ub.price-all.type-price = 0 no-error .
      if available (ub.price-all) then
      do:
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
          , input string(ub.price-all.price-sale)
          , input 1 ).
      end.
      else
      do:
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
          , input string(0)
          , input 1 ).
      end.
      run bgelib-tag-put in this-procedure ( input 3, input "IBCType"
        , input string( 0 ), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                        ~
        , input  v-attr-emrc, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                   ~
        , input  string(ub.bar-code.cli-base-rate), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
    end.
  end.
end.
  .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-version-dec = decimal(p-pos-version)
    no-error .
run bgelib-tag-open in this-procedure ( input 2, input "PromoAction"
  , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
  then "ADD":U
  else "DEL":U),
  OS2-time, v-promo-action:ID)).
        find first ub.promoAttr where
          ub.promoAttr.attr-code = "charge-BL" and
          ub.promoAttr.tablename = "PromoPay" and
          v-promo-action:ID = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
          v-promo-action:db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3)))
          no-error.
        if available (ub.PromoAttr) then do:
          if logical(ub.PromoAttr.attr-value) = true then change-BL = 1 .
          else change-BL = 0 .
        end.
        else change-BL = 0 .
run bgelib-tag-put in this-procedure ( input 3, input "PAName":U
  , input string(v-promo-action:NameAction), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAType":U
  , input string(v-promo-action:TypeDiscont), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PABeg":U
  , input Xml-CD-DateTimetoString(v-promo-action:beg-date,0), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAEnd":U
  , input Xml-CD-DateTimetoString(if v-promo-action:changeDate <> ? then v-promo-action:changeDate else v-promo-action:end-date,86399), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PAPriority":U
  , input string(v-promo-action:priority), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PALoyalRest":U
  , input string(change-BL), input 1 ).
vTypePay = "".
do vIp = 1 to num-entries(v-promo-action:paymenttype,chr(4)):
  vTypePay = vTypePay + "," + LEFT-TRIM(entry(1,
    entry(vIp,
    v-promo-action:paymenttype,
    chr(4)
    ),
    chr(3)
    ),
    "0").
end.
vTypePay = substring(vTypePay,2).
run bgelib-tag-put in this-procedure ( input 3, input "PAPayment":U
  , input vTypePay, input 0 ).
run bgelib-tag-put in this-procedure ( input 3, input "PACalcMethod":U
  , input string(v-promo-action:methodCalc), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "PACondType":U
  , input string(v-promo-action:typecond), input 1 ).
v-subShedWs = v-promo-action:ScheduleWeek .
v-lengthSh = v-subShedWs:iCounter .
do v-i = 1 to v-lengthSh:
  v-size = v-subShedWs:GetItem(v-i) .
  v-subShedW = v-subShedWs:promoSchedwObjCurr .
  do v-ii = 1 to num-entries(v-subShedW:wdaylist):
    if v-subShedW:wdaylist = "0"
      then
    do v-j = 1 to 7:
      run bgelib-tag-open in this-procedure ( input 3, input "PASched","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASDay":U
        , input string(v-j), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASBeg":U
          , input Xml-CD-DateTimetoString(12/31/1989,v-subShedW:timebeg), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASEnd":U
          , input Xml-CD-DateTimetoString(12/31/9999,v-subShedW:timeend), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASched").
    end.
    else
    do:
      run bgelib-tag-open in this-procedure ( input 3, input "PASched","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASDay":U
        , input string(entry(v-ii,v-subShedW:wdaylist)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASBeg":U
         , input Xml-CD-DateTimetoString(12/31/1989,v-subShedW:timebeg), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASEnd":U
        , input Xml-CD-DateTimetoString(12/31/9999,v-subShedW:timeend), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASched").
    end.
  end.
end.
v-subGoods = v-promo-action:GoodsAppl .
if valid-object (v-subGoods) then
do:
  v-lengthGd = v-subGoods:iCounter .
  if v-lengthGd eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
    run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
  end.
  else
  do v-i = 1 to v-lengthGD:
    v-size = v-subGoods:GetItem(v-i) .
    v-subGood = v-subGoods:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAGId":U
      , input string(v-promo-action:id), input 1 ).
    if v-promo-action:typecond <> 4 then
    do:
      run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
        , input if v-subGood:dtSeason = "" then string(v-subGood:GdsCode) else v-subGood:dtSeason, input 1 ).
    end.
    else
    do:
      if v-subGood:dtSeason <> "" then
      do:
        run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
          , input v-subGood:dtSeason, input 1 ).
      end.
      else
      do:
        find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
          ub.PromoAttr.attr-code = "bc-code" and
          ub.PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
          ub.PromoAction.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
          v-subGood:GdsCode = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
        if available (ub.PromoAttr) then run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
            , input string(ub.PromoAttr.attr-value), input 1 ).
        else run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
            , input string(v-subGood:GdsCode), input 1 ).
      end.
    end.
    run bgelib-tag-put in this-procedure ( input 4, input "PAGPrice":U
      , input string(v-subGood:price), input 0 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
    if v-promo-action:typecond <> 4 then
    do:
      for each bar-code where bar-code.gds-code      eq v-subGood:GdsCode
        and bar-code.b-code                       ne v-subGood:GdsCode
        and bar-code.in-code                      eq ""
        and bar-code.part-code                    eq ""
        no-lock:
        run bgelib-tag-open in this-procedure ( input 3, input "PAGoods","").
        run bgelib-tag-put in this-procedure ( input 4, input "PAGId":U
          , input string(v-promo-action:id), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PAGCode":U
          , input string(bar-code.b-code), input 1 ).
        if (    v-subGood:price ne 0
          and v-subGood:price ne ?)
          then
        do:
          run bgelib-tag-put in this-procedure ( input 4, input "PAGPrice":U
            , input string(v-subGood:price * bar-code.cli-base-rate), input 0 ).
        end.
        run bgelib-tag-close in this-procedure ( input 3, input "PAGoods").
      end.
    end.
  end.
end.
v-subGdCrs = v-promo-action:GoodsCrits .
if valid-object (v-subGdCrs) then
do:
  if v-subGdCrs:iCounter ne 0 and v-promo-action:typecond <> 4
    then
  do v-i = 1 to v-subGdCrs:iCounter:
    v-subGdCrs:GetItem(v-i) .
    v-subGdCr = v-subGdCrs:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
      , input if v-subGdCr:dtSeason = "" then string(v-subGdCr:GdsCode) else v-subGdCr:dtSeason, input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
    for each bar-code where bar-code.gds-code       eq v-subGdCr:GdsCode
      and bar-code.b-code         ne v-subGdCr:GdsCode
      and bar-code.in-code        eq ""
      and bar-code.part-code      eq ""
      no-lock:
      run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
      run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
        , input string(bar-code.b-code), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
    end.
  end.
  else
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
  end.
end.
v-subcardbins= v-promo-action:CardsBin .
if valid-object (v-subcardbins) then
do:
  if v-subcardbins:iCounter ne 0
    then
  do v-i = 1 to v-subcardbins:iCounter:
    v-subcardbins:GetItem(v-i) .
    v-subCardBin = v-subcardbins:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAFGCode":U
      , input string(v-subCardBin:nameset), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
  end.
end.
if  valid-object (v-subGdCrs)    and v-subGdCrs   :iCounter eq 0
  and valid-object (v-subcardbins) and v-subcardbins:iCounter eq 0
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PAFreeGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PAFreeGoods").
end.
v-subGifts = v-promo-action:Gifts .
if VALID-OBJECT (v-subGifts) then
do:
  do v-i = 1 to v-subGifts:iCounter:
    vgift = yes.
    v-subGifts:GetItem(v-i).
    v-subGift = v-subGifts:promoGiftObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGId":U
      , input string(v-promo-action:id), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGCode":U
      , input if v-subGift:dtSeason = "" then string(v-subGift:GdsCode) else v-subGift:dtSeason, input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PAGGAmount":U
      , input string(v-subGift:qnty), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
  end.
end.
v-subGDCrites = v-promo-action:Criterion .
if valid-object (v-subGDCrites) then
do:
  if v-subGDCrites:iCounter eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
    run bgelib-tag-close in this-procedure ( input 3, input "PACond").
  end.
  else
  do v-ii = 1 to v-subGDCrites:iCounter:
    v-subGDCrites:GetItem(v-ii) .
    v-subGDCrite = v-subGDCrites:promoCriterionObjCurr .
    v-subGDCrite:refreshChildObj() .
    v-subCrGifts = v-subGDCrite:Gifts .
    if VALID-OBJECT (v-subCrGifts) then
    do:
      do v-i = 1 to v-subCrGifts:iCounter:
        vgift = yes.
        v-subCrGifts:GetItem(v-i) .
        v-subCrGift = v-subCrGifts:promoGiftObjCurr .
        if v-i = 1 then do:
        if v-subCrGift:mess <> "" or v-subCrGift:mess <> ? then v-mess = v-subCrGift:mess .
        if v-subCrGift:mess-gks <> "" or v-subCrGift:mess-gks <> ? then v-mess-gks = v-subCrGift:mess-gks .
        end.
        if v-subCrGift:GdsCode <> 0 then
        do:
          run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGId":U
            , input string(v-promo-action:id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGNum":U
            , input string(v-subGDCrite:id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGCode":U
            , input if v-subCrGift:dtSeason = "" then string(v-subCrGift:GdsCode) else v-subCrGift:dtSeason, input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "PAGGAmount":U
            , input string(v-subCrGift:qnty), input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
        end.
      end.
    end.
    vPricePromoSets = v-subGDCrite:discont .
    if v-promo-action:typecond <> 4 then
    do:
      run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
      run bgelib-tag-put in this-procedure ( input 4, input "PACId":U
        , input string(v-promo-action:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACNum":U
        , input string(v-subGDCrite:id), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACAmount":U
        , input string(v-subGDCrite:mincrit), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACUPAmount":U
        , input string(v-subGDCrite:maxcrit), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACDiscount":U
        , input string(v-subGDCrite:discont), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACMessage":U
        , input string(v-mess), input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PACMessage-GKS":U
        , input string(v-mess-gks), input 0 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PACond").
    end.
    else
    do:
      if (v-promo-action:methodCalc = 2 or v-promo-action:methodCalc = 1) and v-ii = 1 then
      do:
        run bgelib-tag-open in this-procedure ( input 3, input "PACond","").
        run bgelib-tag-put in this-procedure ( input 4, input "PACId":U
          , input string(v-promo-action:id), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PACDiscount":U
          , input string(v-subGDCrite:discont), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "PACond").
      end.
    end.
  end.
end.
v-subPromoSets = v-promo-action:PromoSet .
if valid-object (v-subPromoSets) then
do:
  if v-promo-action:typecond <> 4 then
  do:
    run bgelib-tag-put in this-procedure ( input 3, input "PASetPrice":U
      , input string(vPricePromoSets), input 1 ).
  end.
  if v-subPromoSets:iCounter eq 0
    then
  do:
    run bgelib-tag-open in this-procedure ( input 3, input "PASetSection","").
    run bgelib-tag-close in this-procedure ( input 3, input "PASetSection").
  end.
  else
  do v-i = 1 to v-subPromoSets:iCounter:
    v-subPromoSets:GetItem(v-i).
    v-subPromoSet = v-subPromoSets:promoGoodsObjCurr .
    run bgelib-tag-open in this-procedure ( input 3, input "PASetSection","").
    run bgelib-tag-put in this-procedure ( input 4, input "PASSId":U
      , input string(v-subPromoSet:idaction), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSAmount":U
      , input string(v-subPromoSet:qnty), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSDiscount":U
      , input string(v-subPromoSet:price), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PASSNum":U
      , input string(v-subPromoSet:id), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PASetSection").
  end.
  do v-i = 1 to v-subPromoSets:iCounter:
    v-subPromoSets:GetItem(v-i).
    v-subPromoSet = v-subPromoSets:promoGoodsObjCurr .
    v-subPromoSet:refreshChildObj().
    v-subPromoSetGoods = v-subPromoSet:promoSetGoods.
    do v-j = 1 to v-subPromoSetGoods:iCounter:
      vsetgoods = yes.
      v-subPromoSetGoods:GetItem(v-j).
      v-subPromoSetGood = v-subPromoSetGoods:promoGoodsObjCurr.
      run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
      run bgelib-tag-put in this-procedure ( input 4, input "PASGId":U
        , input string(v-subPromoSetGood:idaction), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASGCode":U
        , input if v-subPromoSetGood:dtSeason = "" then string(v-subPromoSetGood:GdsCode) else v-subPromoSetGood:dtSeason, input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PASGNum":U
        , input string(v-subPromoSetGood:idSet), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
      for each bar-code where bar-code.gds-code       eq v-subPromoSetGood:GdsCode
        and bar-code.b-code         ne v-subPromoSetGood:GdsCode
        and bar-code.in-code        eq ""
        and bar-code.part-code      eq ""
        no-lock:
        run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
        run bgelib-tag-put in this-procedure ( input 4, input "PASGId":U
          , input string(v-subPromoSetGood:idaction), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASGCode":U
          , input string(bar-code.b-code), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "PASGNum":U
          , input string(v-subPromoSetGood:idSet), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
      end.
    end.
  end.
end.
if not vGift
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PAGiftGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PAGiftGoods").
end.
if not vSetgoods
  then
do:
  run bgelib-tag-open in this-procedure ( input 3, input "PASetGoods","").
  run bgelib-tag-close in this-procedure ( input 3, input "PASetGoods").
end.
run bgelib-tag-close in this-procedure ( input 2, input "PromoAction").
            if ub.PromoAction.typecond = 4 and action = "U":U then
            do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
   v-version-dec = decimal(p-pos-version)
    no-error .
for each ub.PromoGoods no-lock where ub.PromoGoods.db-num = ub.PromoAction.db-num and
  ub.PromoGoods.idAction = ub.PromoAction.id and
  ub.PromoGoods.gds-code <> 0:
  find first ub.PromoAttr no-lock where ub.PromoAttr.tablename = "PromoGoods" and
    ub.PromoAttr.attr-code = "bc-code" and
    ub.PromoGoods.idAction = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3))) and
    ub.PromoGoods.gds-code = integer(entry(3,ub.PromoAttr.p-key,chr(3))) no-error .
  if available (ub.PromoAttr) then
  do:
    find first ub.goods no-lock where ub.goods.gds-code = ub.PromoGoods.gds-code no-error .
    for first ub.bar-code no-lock where ub.bar-code.gds-code = ub.goods.gds-code and ub.bar-code.b-code = ub.goods.gds-code:
      producer-int = (if ub.goods.prod-type = 'орг':U then 1000000 else 0 ) + ub.goods.prod-code .
      run gds-attr-value in this-procedure (
        input ub.goods.gds-code
        ,input 'emrc-type':U
        ,output v-attr-emrc
        ,output v-attr-type) no-error.
      run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"
         , "ADD":U
         , OS2-time
         , string(ub.PromoAttr.attr-value))).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"
         , input string( ub.bar-code.b-code )
         , input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"
         , input string(producer-int), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"
         , input trim(string( ub.goods.struct, "X(40)")), input 1 ).
      find first country no-lock where country.alpha1 = ub.goods.alpha1 no-error.
      if available country then
         run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"
            , input country.short-name, input 1 ).
      find last ub.price-all no-lock where ub.price-all.gds-code = ub.goods.gds-code and
         ub.price-all.obj-code = i-obj-code and
         ub.price-all.obj-type = 'маг':U and
         ub.price-all.main-indication = 0 and
         ub.price-all.type-price = 0 no-error .
      if available (ub.price-all) then do:
      run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
         , input string(ub.price-all.price-sale)
         , input 1 ).
      end.
      else do:
      run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
         , input string(0)
         , input 1 ).
      end.
      run bgelib-tag-put in this-procedure ( input 3, input "IBCType"
        , input string( 3 ), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                        ~
        , input  v-attr-emrc, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                   ~
        , input  string(ub.bar-code.cli-base-rate), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
    end.
  end.
end.
            end.
          end.
        end.
      END.
    end.
  end.
end procedure.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE   for-cash-cycle:
   DEFINE VARIABLE v-dir-remote     as character no-undo .
   DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
   define buffer for-cash-desk for ub.cash-desk.
   FOR EACH for-cash-desk NO-LOCK WHERE
      for-cash-desk.db-num = g#db-num AND
      for-cash-desk.pos-type = 'IBM-XML':U AND
      for-cash-desk.obj-code = i-obj-code AND
      for-cash-desk.cash-on  = yes:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка - касса &1", for-cash-desk.cash-num)
                                                      ).
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END CASE.
      RUN putc-16 in this-procedure (buffer for-cash-desk
         ,input for-cash-desk.cash-num
         ,input for-cash-desk.version
         ).
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                  then ('Ждите - ' + 'добавление промоакций ')
                  else ('Ждите - ' + 'удаление промоакций ') ) +
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
END CASE.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка cообщения - касса &1", for-cash-desk.cash-num)
                                                      ).
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    , input substitute( ("'отправка сообщения'" + " &1")
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
    , input 'control'
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
END CASE.
run bgelib-tag-open in this-procedure ( input 2, input "Command":U,"ctrl='ADD'").
run bgelib-tag-put in this-procedure ( input 3, input "CommType":U, input "message", input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "CommValue":U, input "Внимание!!! Перезагрузите кассу, для обновления промоакций!", input 1 ).
run bgelib-tag-close in this-procedure ( input 2, input "Command":U).
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream stmxmlout close.
run xml-cd-write-footer in this-procedure ( input for-cash-desk.pos-type, input v-xml-file-name-path
    , input 'control'
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
                  then ('Ждите - ' + 'отправка сообщения ')
                  else ('Ждите - ' + '') ) +
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
END CASE.
END .
END PROCEDURE.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = g#db-num
     AND ub.cash-desk.obj-code = i-obj-code
     and ub.cash-desk.pos-type = 'IBM-XML':U
     AND ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dflt-cd35 as character no-undo .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type36 as character no-undo .
define variable v-value-date36 as date no-undo .
define variable v-value-decimal36 as decimal no-undo .
define variable v-value-integer36 as INTEGER no-undo .
define variable v-value-logical36 AS LOGICAL no-undo .
define variable v-tth36 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.cash-desk.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd35
    ,output v-value-date36
    ,output v-value-decimal36
    ,output v-value-integer36
    ,output v-value-logical36
    ,output v-param-type36
    ,INPUT-OUTPUT table-handle v-tth36
    ) no-error .
delete object v-tth36 no-error.
case ub.cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END CASE.
    RUN for-cash-cycle no-error.
  END.
  IF LAST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case ub.cash-desk.pos-type:
END CASE.
  END.
END.
END PROCEDURE.
assign
  log-file-name = p-log-file-name
  .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  i-obj-code
  ,output v-host-code
  )  .
if action = "D" and not g#esys and not g#news and selective <> 1
  then
do:
  message
    "Вы действительно хотите удалить с кассы записи промоакций?"
    view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then return.
end.
if action = 'D':U then
do:
  assign
    v-cp-is-use = no.
end.
if action <> 'D':U then
do:
end.
RUN SENDING no-error.
if error-status:error then
do:
  run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute( "!!!Ошибки при отсылке промоакций на кассы  маг&1:&2&3 &4"
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
