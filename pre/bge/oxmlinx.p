block-level on error undo, throw.
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle      as widget-handle    no-undo.
define input parameter p-log-handle         as handle           no-undo.
define input parameter p-parameter-string   as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: 10060ac8659a, 2974, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:42 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlinx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlinx.p $":U .
define variable vss-description as character no-undo init "Импорт из файла OpenXML".
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
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream stmXMLOut.
define stream stmXMLLog.
define stream strXMLIn.
define temp-table temp_xmllib_rec-list no-undo
    field recName       as character
    field recLevel      as integer
    field recOpenLine   as integer
    field recCloseLine  as integer
    field closed        as logical
    index pi is primary unique
        recName
        recLevel
    index cl
        closed
.
define temp-table temp_xmllib_rec-fld-list no-undo
    field recName       as character
    field recLevel      as integer
    field fldName       as character
    field fldOpenLine   as integer
    field fldCloseLine  as integer
    field closed        as logical
    index pi is primary unique
        recName
        recLevel
        fldName
    index fn
        fldName
    index cl
        closed
.
define temp-table temp_xmllib_rec no-undo
    field rec-key       as integer
    field recLevel      as integer
    field recOpenLine   as integer
    field recCloseLine  as integer
    field recName       as character
    field closed        as logical
    index pi is primary unique
        rec-key
    index nm
        recName
        closed
        rec-key
    index cl
        closed
    index rlv
        recName
        recLevel
        closed
        rec-key
.
define temp-table temp_xmllib_rec-fld no-undo
    field fld-key       as integer
    field rec-key       as integer
    field fldOpenLine   as integer
    field fldCloseLine  as integer
    field fldName       as character
    field fldValue      as character
    field closed        as logical
    index pi is primary unique
        fld-key
    index nm
        rec-key
        fldName
        closed
        fld-key
    index cl
        closed
.
define variable v-xmllib-rec-key            as integer      no-undo .
define variable v-xmllib-rec-fld-key        as integer      no-undo .
define variable v-xmllib-dirname            as character    no-undo .
define variable v-xmllib-filename           as character    no-undo .
define variable v-xmllib-log-filename       as character    no-undo .
define variable v-xmllib-log-handle         as handle       no-undo .
define variable v-xmllib-log-proc-name      as character    no-undo .
define variable v-xmllib-error-status       as logical      no-undo .
define variable v-xmllib-sax-reader-handle  as handle       no-undo .
define variable v-xmllib-prg-bar-handle     as handle       no-undo .
define variable v-xmllib-codepage-convert   as logical      no-undo .
define variable v-xmllib-codepage-source    as character    no-undo .
define variable v-xmllib-codepage-target    as character    no-undo .
procedure xmllib-clear-parse-data :
do
on error undo, return error
:
    empty temp-table temp_xmllib_rec-list.
    empty temp-table temp_xmllib_rec-fld-list.
    empty temp-table temp_xmllib_rec.
    empty temp-table temp_xmllib_rec-fld.
end.
end procedure.
procedure xmllib-add-rec-fld :
define input parameter p-rec-name       as character        no-undo.
define input parameter p-rec-fld-name   as character        no-undo.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    find first buf_rec-list
         where buf_rec-list.recName = p-rec-name
    no-error.
    if not available buf_rec-list
    then do:
        create buf_rec-list.
        assign
            buf_rec-list.recName        = p-rec-name
            buf_rec-list.recOpenLine    = 0
            buf_rec-list.recCloseLine   = 0
            buf_rec-list.closed         = yes
        .
    end.
    find first buf_rec-fld-list
         where buf_rec-fld-list.recName = p-rec-name
           and buf_rec-fld-list.fldName = p-rec-fld-name
    no-error.
    if not available buf_rec-fld-list
    then do:
        create buf_rec-fld-list.
        assign
            buf_rec-fld-list.recName        = p-rec-name
            buf_rec-fld-list.fldName        = p-rec-fld-name
            buf_rec-fld-list.fldOpenLine    = 0
            buf_rec-fld-list.fldCloseLine   = 0
            buf_rec-fld-list.closed         = yes
        .
    end.
end.
end procedure.
procedure xmllib-tag-open:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.
do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( "&1&2<&3&4&5>"
            , chr(10)
            , fill(" ", 4 * v-tag-level)
            , v-tag-name
            , ( if v-tag-value = "":U or v-tag-value = ? then "":U else " ":U )
            , v-tag-value
        )
    .
end.
end procedure.
procedure xmllib-tag-put:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "":U and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "":U and v-tag-value <> ? and v-tag-value <> "0":U))
    or (v-empty-mode = 3 and (v-tag-value <> "":U and v-tag-value <> ? and caps(v-tag-value) <> "no":U))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            substitute( "&1&2<&3>&4</&3>"
                , chr(10)
                , fill(" ":U, 4 * v-tag-level)
                , v-tag-name
                , v-tag-value
            )
        .
    end.
end.
end procedure.
procedure xmllib-tag-put-null :
define input parameter p-tag-level  as integer      no-undo.
define input parameter p-tag-name   as character    no-undo.
do
on error undo, return error
:
    assign
        p-tag-name = trim( p-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( '&1&2<&3 nil="true" /&3>'
            , chr(10)
            , fill(" ":U, 4 * p-tag-level)
            , p-tag-name
        )
    .
end.
end procedure.
procedure xmllib-tag-close:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.
do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( "&1&2</&3>"
            , chr(10)
            , fill( " ":U, 4 * v-tag-level)
            , v-tag-name
        )
    .
end.
end procedure.
procedure xmllib-write-log:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.
do
on error undo, return error
:
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        chr(10)
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine":U
          or v-out-string = "&Line":U
          then "":U
          else cur-time-string-sec() + " ":U )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line":U
          then fill( "-":U, 80 )
          else if v-out-string = "&DLine":U
               then fill( "=":U, 80 )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.
procedure xmllib-write-edt:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.
do
on error undo, return error
:
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine":U
                                          or v-out-string = "&Line":U
                                          then "":U
                                          else cur-time-string-sec() + " ":U
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line":U
                                          then fill( "-":U, 80 )
                                          else if v-out-string = "&DLine":U then fill("=":U, 80)
                                          else fill( " ":U, v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( chr(10) ).
    end.
end.
end procedure.
procedure xmllib-show-cnt:
define input parameter v-fillin-handle     as handle   no-undo.
do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.
procedure xmllib-hide-cnt:
define input parameter v-fillin-handle     as handle   no-undo.
do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.
procedure xmllib-write-cnt:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.
do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.
procedure xmllib-write-header:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.
    define variable v-counter    as integer        no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run xmllib-tag-open( input 0, input "root"          , input "":U ).
    run xmllib-tag-open( input 0, input "THheader"        , input "":U ).
    run xmllib-tag-put( input 1 , input "THfileName"      , input p-xml-file-name + "xml":U  , input 0 ).
    run xmllib-tag-put( input 1 , input "THfileNumber"    , input string( p-file-number     ), input 0 ).
    run xmllib-tag-put( input 1 , input "THhavePrev"      , input string( p-have-prev       ), input 3 ).
    run xmllib-tag-put( input 1 , input "THprevFileName"  , input p-prev-filename            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run xmllib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run xmllib-tag-close( input 0, input "THheader" ).
    output stream stmXMLOut close.
    if p-list-file-name <> "":U
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
        if p-first-file = yes
        then do:
            put stream stmXMLOut unformatted
                "<?xml version='1.0' encoding='windows-1251'?>"
            .
            run xmllib-tag-open( input 0, input "OpenXML", input "" ).
        end.
        run xmllib-tag-open( input 1, input "THfile", input "" ).
        run xmllib-tag-put( input 2, input "THfileName"       , input p-xml-file-name + "xml":U  , input 0 ).
        run xmllib-tag-put( input 2, input "THfileNumber"     , input string( p-file-number     ), input 0 ).
        run xmllib-tag-put( input 2, input "THhavePrev"       , input string( p-have-prev       ), input 3 ).
        run xmllib-tag-put( input 2, input "THprevFileName"   , input p-prev-filename            , input 0 ).
        do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
        :
            run xmllib-tag-put(
                input 2
                , input entry( 2 * v-counter, p-parameter-list )
                , input entry( 2 * v-counter + 1, p-parameter-list )
                , input 0
            ).
        end.
        run xmllib-tag-close( input 1, input "THfile" ).
        output stream stmXMLOut close.
    end.
end.
end procedure.
procedure xmllib-write-footer:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run xmllib-tag-open( input 0, input "footer", "" ).
        run xmllib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run xmllib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run xmllib-tag-close( input 0, input "footer" ).
    end.
    run xmllib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + "tmp"
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    and p-list-file-name <> "":U
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
            run xmllib-tag-close( input 0, input "OpenXML" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + "tmp"
            , input p-list-file-name + "xml":U
            , output v-error-num
        ).
    end.
end.
end procedure.
procedure xmllib-filename :
define input parameter p-subdir             as character        no-undo.
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.
    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.
do
on error undo, return error
:
    get-key-value section "OXML" key "oxml-dir" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip "Нет параметра oxml-dir в секции [OXML]."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if p-subdir <> "":U
    then do:
        assign
            v-home-dir = substitute( "&1/out/&2", v-home-dir, p-subdir )
        .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта в ini-файле."
          skip "Не удаётся создать каталог, указанный параметром"
          skip "oxml-dir в секции [OXML]."
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
procedure xmllib-check-file-size :
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.
    define variable v-current-position    as integer        no-undo.
do
on error undo, return error
:
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
procedure xmllib-parse-file :
define input parameter p-full-filename      as character        no-undo.
    define variable v-num-dirs              as integer      no-undo .
    define variable v-str                   as character    no-undo .
    define variable v-str-count             as int64        no-undo .
do
on error undo, return error
:
    assign
        v-num-dirs              = num-entries( p-full-filename,"\/":U )
        v-xmllib-error-status   = no
    .
    if v-num-dirs > 1
    then do:
        assign
            v-xmllib-filename = entry( v-num-dirs, p-full-filename, "\/":U )
            v-xmllib-dirname  = substring( p-full-filename, 1, length( p-full-filename ) - length( v-xmllib-filename ) - 1 )
        .
    end.
    else do:
        assign
            v-xmllib-filename = p-full-filename
            v-xmllib-dirname  = "":U
        .
    end.
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
if session :set-wait-state( "compiler" ) then.
      input stream strXMLIn from value(p-full-filename) .
      repeat
      :
        import stream strXMLIn unformatted v-str no-error .
        assign
          v-str-count = v-str-count + 1
        .
      end.
      input stream strXMLIn close .
if session :set-wait-state( "" ) then.
      run prg-bar_init-cb-handle in this-procedure ( input v-xmllib-prg-bar-handle ) .
      run prg-bar_new in this-procedure ( input 1 , input v-str-count) .
      run prg-bar_show in this-procedure .
    end.
    create sax-reader v-xmllib-sax-reader-handle.
    v-xmllib-sax-reader-handle :set-input-source( "FILE":U, p-full-filename ).
    v-xmllib-sax-reader-handle :sax-parse( ) no-error.
    if error-status :error
    then do:
        run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                    ,vss-workfile
                                                                    ,vss-revision
                                                                    ,vss-description
                                                                    ,chr(10)
                                                                    ,return-value
                                                                    ,trim(error-status :get-message(1))
                                                                    ,trim(error-status :get-message(2))
                                                                    ,trim(error-status :get-message(3)))
                                                  ).
        undo, return error .
    end.
    if v-xmllib-error-status <> no
    then do:
        run xmllib-parse-error in this-procedure (
            input "*** При обработке XML файла были ошибки."
        ).
        delete object v-xmllib-sax-reader-handle.
    end.
    delete object v-xmllib-sax-reader-handle.
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
      run prg-bar_delete in this-procedure .
    end.
end.
end procedure.
procedure xmllib-parse-progressive :
define input parameter p-full-filename      as character no-undo .
define input parameter p-pack-data          as memptr no-undo .
define input parameter p-parse-first        as logical no-undo .
define input parameter p-first-err          as logical no-undo .
define output parameter p-parse-status as integer no-undo .
define variable v-num-dirs              as integer no-undo .
define variable glog                    as logical no-undo .
define variable v-pack-size             as int64 no-undo .
do
on error undo, return error
:
  if p-parse-first then do:
    if valid-handle(v-xmllib-sax-reader-handle)
    then do:
    end.
    assign
        v-num-dirs              = num-entries( p-full-filename,"\/":U )
        v-xmllib-error-status   = no
    .
    if v-num-dirs > 1
    then do:
        assign
            v-xmllib-filename = entry( v-num-dirs, p-full-filename, "\/":U )
            v-xmllib-dirname  = substring( p-full-filename, 1, length( p-full-filename ) - length( v-xmllib-filename ) - 1 )
        .
    end.
    else do:
        assign
            v-xmllib-filename = p-full-filename
            v-xmllib-dirname  = "":U
        .
    end.
    create sax-reader v-xmllib-sax-reader-handle.
    v-pack-size = get-size (p-pack-data) .
    if v-pack-size > 0 then
      glog = v-xmllib-sax-reader-handle :set-input-source( "MEMPTR":U, p-pack-data ) no-error.
    else
      glog = v-xmllib-sax-reader-handle :set-input-source( "FILE":U, p-full-filename ) no-error.
    if error-status :error
    or not glog
    then do:
      delete object v-xmllib-sax-reader-handle.
      run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                  ,vss-workfile
                                                                  ,vss-revision
                                                                  ,vss-description
                                                                  ,chr(10)
                                                                  ,return-value
                                                                  ,trim(error-status :get-message(1))
                                                                  ,trim(error-status :get-message(2))
                                                                  ,trim(error-status :get-message(3)) )
                                                ).
      undo, return error .
    end.
    v-xmllib-sax-reader-handle :sax-parse-first( ) no-error.
  end.
  else do:
    v-xmllib-sax-reader-handle :sax-parse-next( ) no-error.
  end.
  if error-status :error
  then do:
    delete object v-xmllib-sax-reader-handle.
    run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                ,vss-workfile
                                                                ,vss-revision
                                                                ,vss-description
                                                                ,chr(10)
                                                                ,return-value
                                                                ,trim(error-status :get-message(1))
                                                                ,trim(error-status :get-message(2))
                                                                ,trim(error-status :get-message(3)) )
                                              ).
    undo, return error .
  end.
  if v-xmllib-error-status <> no
  then do:
    run xmllib-parse-error in this-procedure (
        input "*** При обработке XML файла были ошибки."
    ).
    if p-first-err then do:
      delete object v-xmllib-sax-reader-handle.
    end.
    else do:
      v-xmllib-error-status = no.
    end.
  end.
  if v-xmllib-sax-reader-handle:parse-status = SAX-COMPLETE  then do:
    p-parse-status = SAX-COMPLETE.
    delete object v-xmllib-sax-reader-handle.
    return '':U.
  end.
  else do:
    p-parse-status = v-xmllib-sax-reader-handle:parse-status.
    return '':U.
  end.
end.
end procedure.
procedure StartElement :
define input parameter p-name-space     as character        no-undo.
define input parameter p-local-name     as character        no-undo.
define input parameter p-q-name         as character        no-undo.
define input parameter p-attributes     as handle           no-undo.
    define buffer buf_rec             for temp_xmllib_rec.
    define buffer buf_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec
  , buf_rec-fld
  , buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
      run prg-bar_stepto in this-procedure ( input SELF:LOCATOR-LINE-NUMBER ) .
    end.
    find first buf_rec-list
         where buf_rec-list.recName = p-q-name
    no-error.
    if available buf_rec-list
    then do:
        if buf_rec-list.closed = no
        then do:
            find first buf_rec-fld-list
                 where buf_rec-fld-list.recName = buf_rec-list.recName
                   and buf_rec-fld-list.fldName = p-q-name
            no-error.
            if available buf_rec-fld-list
            and buf_rec-list.recName = buf_rec-fld-list.recName
            then do:
                if buf_rec-fld-list.closed = no
                then do:
                    run xmllib-parse-error in this-procedure (
                        input substitute( "Ошибка 1 открытия поля <&1> записи <&2>: Поле с этим именем уже открыто на строке &3."
                                        , p-q-name
                                        , p-q-name
                                        , buf_rec-fld-list.fldOpenLine
                                        )
                    ).
                end.
                else do:
                    run xmllib-parse-rec-fld-open in this-procedure (
                          input buf_rec-list.recName
                        , input buf_rec-list.recLevel
                        , input buf_rec-fld-list.fldName
                    ).
                    assign
                        buf_rec-fld-list.closed         = no
                        buf_rec-fld-list.fldOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                        buf_rec-fld-list.fldCloseLine   = 0
                    .
                end.
            end.
            else do:
                assign
                    buf_rec-list.recLevel = buf_rec-list.recLevel + 1
                .
                run xmllib-parse-rec-open in this-procedure (
                      input buf_rec-list.recName
                    , input buf_rec-list.recLevel
                ).
                assign
                    buf_rec-list.closed         = no
                    buf_rec-list.recOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                    buf_rec-list.recCloseLine   = 0
                .
            end.
        end.
        else do:
            run xmllib-parse-rec-open in this-procedure (
                  input buf_rec-list.recName
                , input buf_rec-list.recLevel
            ).
            assign
                buf_rec-list.closed         = no
                buf_rec-list.recOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                buf_rec-list.recCloseLine   = 0
            .
        end.
    end.
    else do:
        open-record:
        for each buf_rec-fld-list
           where buf_rec-fld-list.fldName = p-q-name
        :
            find first buf_rec-list
                 where buf_rec-list.recName = buf_rec-fld-list.recName
                   and buf_rec-list.closed  = no
            no-error.
            if available buf_rec-list
            then do:
                run xmllib-parse-rec-fld-open in this-procedure (
                      input buf_rec-list.recName
                    , input buf_rec-list.recLevel
                    , input buf_rec-fld-list.fldName
                ).
                assign
                    buf_rec-fld-list.recLevel       = buf_rec-list.recLevel
                    buf_rec-fld-list.closed         = no
                    buf_rec-fld-list.fldOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                    buf_rec-fld-list.fldCloseLine   = 0
                .
                leave open-record.
            end.
        end.
    end.
end.
end procedure.
procedure Characters :
define input parameter p-char-data  as memptr.
define input parameter p-numchars   as integer.
    define variable v-data-string    as character    no-undo.
    define variable v-cp-utf8           as integer no-undo init 65001 .
    define variable v-cp-windows1251    as integer no-undo init 1251 .
    define buffer buf_xmllib_rec             for temp_xmllib_rec.
    define buffer buf_xmllib_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_xmllib_rec-list        for temp_xmllib_rec-list.
    define buffer buf_xmllib_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_xmllib_rec
  , buf_xmllib_rec-fld
  , buf_xmllib_rec-list
  , buf_xmllib_rec-fld-list
on error undo, return error
:
    find first buf_xmllib_rec-list
         where buf_xmllib_rec-list.closed = no
    no-error.
    if available buf_xmllib_rec-list
    then do:
        find first buf_xmllib_rec-fld-list
             where buf_xmllib_rec-fld-list.closed = no
        no-error.
        if available buf_xmllib_rec-fld-list
        and buf_xmllib_rec-fld-list.recName  = buf_xmllib_rec-list.recName
        and buf_xmllib_rec-fld-list.recLevel = buf_xmllib_rec-list.recLevel
        then do:
            find last buf_xmllib_rec
                where buf_xmllib_rec.recName  = buf_xmllib_rec-list.recName
                  and buf_xmllib_rec.recLevel = buf_xmllib_rec-list.recLevel
                  and buf_xmllib_rec.closed   = no
            use-index nm
            no-error.
            if available buf_xmllib_rec
            then do:
                find last buf_xmllib_rec-fld
                    where buf_xmllib_rec-fld.rec-key = buf_xmllib_rec.rec-key
                      and buf_xmllib_rec-fld.fldName = buf_xmllib_rec-fld-list.fldName
                      and buf_xmllib_rec-fld.closed = no
                use-index nm
                no-error.
                if available buf_xmllib_rec-fld
                then do:
                    assign
                        v-data-string = get-string( p-char-data, 1, get-size( p-char-data ) )
                    .
                    if v-xmllib-codepage-convert = yes
                    then do:
                      assign
                          v-data-string = codepage-convert( v-data-string , v-xmllib-codepage-target , v-xmllib-codepage-source )
                      .
                    end.
                    run xmlchar-decode in this-procedure (
                        input v-data-string
                        , output v-data-string
                    ).
                    assign
                        buf_xmllib_rec-fld.fldValue = trim( substitute( "&1&2", buf_xmllib_rec-fld.fldValue, v-data-string ) )
                    .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure EndElement :
define input parameter p-name-space     as character        no-undo.
define input parameter p-local-name     as character        no-undo.
define input parameter p-q-name         as character        no-undo.
    define buffer buf_rec             for temp_xmllib_rec.
    define buffer buf_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec
  , buf_rec-fld
  , buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    find last buf_rec-list
        where buf_rec-list.recName = p-q-name
    use-index pi
    no-error.
    if available buf_rec-list
    then do:
        if buf_rec-list.closed = yes
        then do:
            run xmllib-parse-error in this-procedure (
                input substitute( "Ошибка закрытия записи или поля <&1>: Нет метки открытой записи."
                                , p-q-name
                                )
            ).
        end.
        else do:
            find last buf_rec
                where buf_rec.recName  = buf_rec-list.recName
                  and buf_rec.recLevel = buf_rec-list.recLevel
                  and buf_rec.closed   = no
            use-index nm
            no-error.
            if not available buf_rec
            then do:
                run xmllib-parse-error in this-procedure (
                    input substitute( "Ошибка закрытия записи или поля <&1> уровня &2: Нет открытой записи."
                                    , p-q-name
                                    , buf_rec-list.recLevel
                                    )
                ).
            end.
            else do:
                find first buf_rec-fld-list
                     where buf_rec-fld-list.recName  = buf_rec.recName
                       and buf_rec-fld-list.recLevel = buf_rec.recLevel
                       and buf_rec-fld-list.fldName  = p-q-name
                       and buf_rec-fld-list.closed   = no
                no-error.
                if not available buf_rec-fld-list
                then do:
                    if buf_rec.recName <> p-q-name
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка закрытия записи <&1>: Имя открытой записи не совпадает с именем метки."
                                            , buf_rec.recName
                                            )
                        ).
                    end.
                    else do:
                        assign
                            buf_rec.closed              = yes
                            buf_rec.recCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-list.recCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                        if buf_rec-list.recLevel > 0
                        then do:
                            assign
                                buf_rec-list.recLevel = buf_rec-list.recLevel - 1
                            .
                            for each buf_rec-fld-list
                               where buf_rec-fld-list.recName = buf_rec-list.recName
                            :
                                assign
                                    buf_rec-fld-list.recLevel = buf_rec-fld-list.recLevel - 1
                                .
                            end.
                        end.
                        else do:
                            assign
                                buf_rec-list.closed         = yes
                            .
                        end.
                    end.
                end.
                else do:
                    find last buf_rec-fld
                        where buf_rec-fld.rec-key = buf_rec.rec-key
                          and buf_rec-fld.fldName = buf_rec-fld-list.fldName
                          and buf_rec-fld.closed  = no
                    use-index nm
                    no-error.
                    if not available buf_rec-fld
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка 2 закрытия поля <&1>: Не найдено открытое поле с этим именем в записи <&2> уровня &3."
                                            , buf_rec-fld-list.fldName
                                            , buf_rec.recName
                                            , buf_rec.recLevel
                                            )
                        ).
                    end.
                    else do:
                        assign
                            buf_rec-fld.closed              = yes
                            buf_rec-fld-list.closed         = yes
                            buf_rec-fld.fldCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-fld-list.fldCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                    end.
                end.
            end.
        end.
    end.
    else do:
        close-field-rec:
        for each buf_rec-fld-list
           where buf_rec-fld-list.fldName = p-q-name
        :
            find first buf_rec-list
                 where buf_rec-list.recName  = buf_rec-fld-list.recName
                   and buf_rec-list.recLevel = buf_rec-fld-list.recLevel
                   and buf_rec-list.closed   = no
            no-error.
            if available buf_rec-list
            then do:
                find last buf_rec
                    where buf_rec.recName  = buf_rec-list.recName
                      and buf_rec.recLevel = buf_rec-list.recLevel
                      and buf_rec.closed   = no
                use-index nm
                no-error.
                if not available buf_rec
                then do:
                    run xmllib-parse-error in this-procedure (
                        input substitute( "Ошибка закрытия поля <&1>: Нет открытой записи."
                                        , p-q-name
                                        )
                    ).
                end.
                else do:
                    find last buf_rec-fld
                        where buf_rec-fld.rec-key = buf_rec.rec-key
                          and buf_rec-fld.fldName = buf_rec-fld-list.fldName
                          and buf_rec-fld.closed  = no
                    use-index nm
                    no-error.
                    if not available buf_rec-fld
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка 1 закрытия поля <&1>: Не найдено открытое поле с этим именем в записи <&2> уровня &3."
                                            , buf_rec-fld-list.fldName
                                            , buf_rec.recName
                                            , buf_rec.recLevel
                                            )
                        ).
                    end.
                    else do:
                        assign
                            buf_rec-fld.closed              = yes
                            buf_rec-fld-list.closed         = yes
                            buf_rec-fld.fldCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-fld-list.fldCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                    end.
                end.
                leave close-field-rec.
            end.
        end.
    end.
end.
end procedure.
procedure Error :
define input parameter p-error-message     as character        no-undo.
do
on error undo, return error
:
    run xmllib-parse-error in this-procedure (
        input p-error-message
    ).
    assign
        v-xmllib-error-status = yes
    .
end.
end procedure.
procedure xmllib-parse-error :
define input parameter p-err-message    as character        no-undo.
do
on error undo, return error
:
    if valid-handle(v-xmllib-log-handle) then do:
      run value(v-xmllib-log-proc-name) in  v-xmllib-log-handle
               (input substitute("&1Файл:    &2 &3&1Строка &4&1&5"
                                 ,chr(10)
                                 ,v-xmllib-dirname
                                 ,v-xmllib-filename
                                 ,(if valid-handle(v-xmllib-sax-reader-handle)
                                   then v-xmllib-sax-reader-handle :locator-line-number
                                   else ?)
                                 ,p-err-message)).
    end.
    else do:
      if v-xmllib-log-filename = "":U
      then do:
          message
                  vss-workfile vss-revision vss-description
              skip "Файл:   " v-xmllib-dirname v-xmllib-filename
              skip "Строка: " (if valid-handle(v-xmllib-sax-reader-handle)
                               then v-xmllib-sax-reader-handle :locator-line-number
                               else ?)
              skip(1)
              skip p-err-message
              skip return-value
              skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
          view-as alert-box error.
          undo, return error.
      end.
      else do:
        output to value( v-xmllib-log-filename ).
        put unformatted
            substitute( "&1&2", chr(10), p-err-message )
        .
        output close.
      end.
    end.
end.
end procedure.
procedure xmllib-set-log-filename :
define input parameter p-log-filename   as character        no-undo.
do
on error undo, return error
:
    run gbl/fileapnd.p (
          input p-log-filename
        , input "":U
        , input 10
    ) no-error.
    if error-status :error
    then do:
        assign
            v-xmllib-log-filename = "":U
        .
    end.
    else do:
        assign
            v-xmllib-log-filename = p-log-filename
        .
    end.
end.
end procedure.
procedure xmllib-set-log-handle :
define input parameter p-log-handle    as handle        no-undo.
define input parameter p-log-proc-name as character no-undo .
do
on error undo, return error
:
    if valid-handle(p-log-handle)
    and lookup(p-log-proc-name, p-log-handle:internal-entries) > 0
    then do:
      assign
      v-xmllib-log-handle    = p-log-handle
      v-xmllib-log-proc-name = p-log-proc-name
      .
    end.
    else do:
      assign
      v-xmllib-log-handle    = ?
      v-xmllib-log-proc-name = '':U
      .
    end.
end.
end procedure.
procedure xmllib-set-prg-bar-handle :
define input parameter p-handle    as handle        no-undo.
do
on error undo, return error
:
    if valid-handle(p-handle)
    then do:
      assign
        v-xmllib-prg-bar-handle = p-handle
      .
    end.
    else do:
      assign
        v-xmllib-prg-bar-handle = ?
      .
    end.
end.
end procedure.
procedure xmllib-set-codepage-convert :
  define input  parameter p-codepage-source as character no-undo .
  define input  parameter p-codepage-target as character no-undo .
do
on error undo, return error return-value
:
  if ( p-codepage-source <> "" and p-codepage-target <> "" )
  then do:
    assign
      v-xmllib-codepage-convert = yes
      v-xmllib-codepage-source  = p-codepage-source
      v-xmllib-codepage-target  = p-codepage-target
    .
  end.
  else do:
    assign
      v-xmllib-codepage-convert = no
      v-xmllib-codepage-source  = ""
      v-xmllib-codepage-target  = ""
    .
  end.
end.
end procedure.
procedure xmllib-parse-rec-open :
define input parameter p-rec-name   as character        no-undo.
define input parameter p-rec-level  as integer          no-undo.
    define buffer buf_temp_xmllib_rec       for temp_xmllib_rec.
do
for buf_temp_xmllib_rec
on error undo, return error
:
     find first buf_temp_xmllib_rec
         where buf_temp_xmllib_rec.recName = p-rec-name
           and buf_temp_xmllib_rec.recLevel = p-rec-level
           and buf_temp_xmllib_rec.closed  = no
    use-index nm
    no-error.
    if available buf_temp_xmllib_rec
    then do:
        run xmllib-parse-error in this-procedure (
            input substitute( "Ошибка 2 открытия записи <&1>: Запись с этим именем и уровнем &2 уже открыта на строке &3."
                            , p-rec-name
                            , p-rec-level
                            , buf_temp_xmllib_rec.recOpenLine
                            )
        ).
    end.
    else do:
        assign
            v-xmllib-rec-key    = v-xmllib-rec-key + 1
        .
        create buf_temp_xmllib_rec.
        assign
            buf_temp_xmllib_rec.rec-key         = v-xmllib-rec-key
            buf_temp_xmllib_rec.recOpenLine     = v-xmllib-sax-reader-handle :locator-line-number
            buf_temp_xmllib_rec.recCloseLine    = 0
            buf_temp_xmllib_rec.recName         = p-rec-name
            buf_temp_xmllib_rec.recLevel        = p-rec-level
            buf_temp_xmllib_rec.closed          = no
        .
    end.
end.
end procedure.
procedure xmllib-parse-rec-fld-open :
define input parameter p-rec-name   as character        no-undo.
define input parameter p-rec-level  as integer          no-undo.
define input parameter p-fld-name   as character        no-undo.
    define buffer buf_temp_xmllib_rec       for temp_xmllib_rec.
    define buffer buf_temp_xmllib_rec-fld   for temp_xmllib_rec-fld.
do
for buf_temp_xmllib_rec
  , buf_temp_xmllib_rec-fld
on error undo, return error substitute( "Ошибка в xmllib-parse-rec-fld-open. &1. &2. &3"
                                        , return-value
                                        , trim( error-status :get-message( 1 ) )
                                        , trim( error-status :get-message( 2 ) ) )
:
    find last buf_temp_xmllib_rec
        where buf_temp_xmllib_rec.recName   = p-rec-name
          and buf_temp_xmllib_rec.recLevel  = p-rec-level
          and buf_temp_xmllib_rec.closed    = no
    use-index nm
    no-error.
    if not available buf_temp_xmllib_rec
    then do:
        run xmllib-parse-error in this-procedure (
            input substitute( "Ошибка 2 открытия поля <&2> в записи <&1> уровня &3: Нет открытой записи."
                            , p-rec-name
                            , p-fld-name
                            , p-rec-level
                            )
        ).
    end.
    else do:
        find last buf_temp_xmllib_rec-fld
            where buf_temp_xmllib_rec-fld.rec-key  = buf_temp_xmllib_rec.rec-key
              and buf_temp_xmllib_rec-fld.fldName  = p-fld-name
              and buf_temp_xmllib_rec-fld.closed   = no
        use-index nm
        no-error.
        if available buf_temp_xmllib_rec-fld
        then do:
            run xmllib-parse-error in this-procedure (
                input substitute( "Ошибка 3 открытия поля <&2> в записи <&1>: Поле с этим именем уже открыто на строке &3."
                                , p-rec-name
                                , p-fld-name
                                , buf_temp_xmllib_rec-fld.fldOpenLine
                                )
            ).
        end.
        else do:
            assign
                v-xmllib-rec-fld-key    = v-xmllib-rec-fld-key + 1
            .
            create buf_temp_xmllib_rec-fld.
            assign
                buf_temp_xmllib_rec-fld.fld-key         = v-xmllib-rec-fld-key
                buf_temp_xmllib_rec-fld.rec-key         = buf_temp_xmllib_rec.rec-key
                buf_temp_xmllib_rec-fld.fldOpenLine     = v-xmllib-sax-reader-handle :locator-line-number
                buf_temp_xmllib_rec-fld.fldCloseLine    = 0
                buf_temp_xmllib_rec-fld.fldName         = p-fld-name
                buf_temp_xmllib_rec-fld.closed          = no
            .
        end.
    end.
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table temp-param-name no-undo
field profile_id as integer
field profile-type as character
field schema-name as character
field esys-id as integer
field call_id as character
field once-more as integer
field codex_id as integer
field ruleset_id as integer
field order_id as integer
field param-name as character
field param-type as character
field pack-process-uniq-key-rec as character
index pi is primary unique
esys-id
schema-name
profile_id
call_id
.
procedure xmlischn_fill :
define input  parameter p-codex-id  as integer   no-undo .
define input  parameter p-ruleset-id as integer   no-undo .
define buffer buf_rule-call-param  for ub.rule-call-param.
define buffer buf2_rule-call-param for ub.rule-call-param.
define buffer buf_temp-param-name for temp-param-name.
define variable v-esys-id-list as character no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_rule-call-param where
            buf_rule-call-param.codex_id = p-codex-id
        and buf_rule-call-param.ruleset_id = p-ruleset-id
    break
    by buf_rule-call-param.call_id
    by buf_rule-call-param.profile_id
    by buf_rule-call-param.once-more
    :
      if first-of(buf_rule-call-param.once-more) then do:
        v-esys-id-list = ''.
        for each buf2_rule-call-param no-lock
           where buf2_rule-call-param.call_id    = buf_rule-call-param.call_id
             and buf2_rule-call-param.codex_id   = buf_rule-call-param.codex_id
             and buf2_rule-call-param.ruleset_id = buf_rule-call-param.ruleset_id
             and buf2_rule-call-param.profile_id = buf_rule-call-param.profile_id
             and buf2_rule-call-param.once-more  = buf_rule-call-param.once-more
             and buf2_rule-call-param.param-2-data-type = 'ext-system':U :
          if buf2_rule-call-param.param-name = "p-esys-id"
               or
               (buf2_rule-call-param.param-name = "p-esys-id-list"
               and
               buf2_rule-call-param.p-index > 0)
          then do:
            assign
            v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else chr(44)) +
                            string( buf2_rule-call-param.param-value-integer)
            .
          end.
        end.
      end.
      if v-esys-id-list = "" then v-esys-id-list = "-1".
      if buf_rule-call-param.param-2-data-type = "xsd" then do:
        find first buf_temp-param-name where
                buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          and buf_temp-param-name.call_id = buf_rule-call-param.call_id
          and buf_temp-param-name.once-more = buf_rule-call-param.once-more
          no-error.
        if not available buf_temp-param-name then do:
          do v-ii = 1 to num-entries(v-esys-id-list):
            find first buf_temp-param-name where
                    buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
              and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
              and buf_temp-param-name.call_id = buf_rule-call-param.call_id
              and buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
              no-error.
            if not available buf_temp-param-name then do:
          create buf_temp-param-name.
          assign
          buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          buf_temp-param-name.call_id = buf_rule-call-param.call_id
          buf_temp-param-name.once-more = buf_rule-call-param.once-more
          buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
          buf_temp-param-name.ruleset_id = buf_rule-call-param.ruleset_id
          buf_temp-param-name.codex_id = buf_rule-call-param.codex_id
          buf_temp-param-name.order_id = buf_rule-call-param.order_id
          buf_temp-param-name.param-name = buf_rule-call-param.param-name
            buf_temp-param-name.param-type = "xsd"
            buf_temp-param-name.profile-type = entry (buf_rule-call-param.codex_id, 'dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,,,,,goods,clients,gds-grp,cli-grp,,,,edoc,chk-doc,thref,pdf,rep,ord,fdoc':U)
            buf_temp-param-name.pack-process-uniq-key-rec =
            substitute("&2&1&3&1&4&1&5"
                                                                      , chr(4)
                                                                      , buf_rule-call-param.call_id
                                                                      , buf_rule-call-param.codex_id
                                                                      , buf_rule-call-param.ruleset_id
                                                                      , buf_rule-call-param.order_id)
            .
            end.
          end.
        end.
      end.
      if buf_rule-call-param.param-2-data-type = "sub-type" then do:
        find first buf_temp-param-name where
                buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          and buf_temp-param-name.call_id = buf_rule-call-param.call_id
          and buf_temp-param-name.once-more = buf_rule-call-param.once-more
          no-error.
        if not available buf_temp-param-name then do:
          do v-ii = 1 to num-entries(v-esys-id-list):
            find first buf_temp-param-name where
                    buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
              and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
              and buf_temp-param-name.call_id = buf_rule-call-param.call_id
              and buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
              no-error.
            if not available buf_temp-param-name then do:
            create buf_temp-param-name.
            assign
            buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
            buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
            buf_temp-param-name.call_id = buf_rule-call-param.call_id
            buf_temp-param-name.once-more = buf_rule-call-param.once-more
            buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
            buf_temp-param-name.ruleset_id = buf_rule-call-param.ruleset_id
            buf_temp-param-name.codex_id = buf_rule-call-param.codex_id
            buf_temp-param-name.order_id = buf_rule-call-param.order_id
            buf_temp-param-name.param-name = buf_rule-call-param.param-name
            buf_temp-param-name.param-type = "no-xsd"
          buf_temp-param-name.profile-type = entry (buf_rule-call-param.codex_id, 'dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,,,,,goods,clients,gds-grp,cli-grp,,,,edoc,chk-doc,thref,pdf,rep,ord,fdoc':U)
          buf_temp-param-name.pack-process-uniq-key-rec =
          substitute("&2&1&3&1&4&1&5"
                                                                     , chr(4)
                                                                     , buf_rule-call-param.call_id
                                                                     , buf_rule-call-param.codex_id
                                                                     , buf_rule-call-param.ruleset_id
                                                                     , buf_rule-call-param.order_id)
          .
        end.
      end.
    end.
    end.
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define stream LogStream .
define variable mNoTime as logical no-undo.
procedure write-to-log-notime :
  define input param i-str as character no-undo .
  mNoTime = yes.
  run write-to-log (i-str).
  mNoTime = no.
end.
procedure write-to-log :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-log). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-log). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-log). endkey", vss-workfile )
  :
    define variable log-res        as logical   no-undo .
    define variable v-jj           as integer   no-undo .
    if    mNoTime
       or writelogvalue eq "AsyncProc"
    then
       p-str = substitute( "&1 (pid: &2) &3&4"   , g#auto-user-id, g#auto-pid,                        p-str, chr(10) ).
    else
       p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) ).
    if auto-log-msg-h <> ? then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ? then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
    assign
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    if add-log-file-name <> ? then do:
      do v-jj = 1 to num-entries(add-log-file-name, chr(1)):
        run gbl/fileapnd.p
          ( input entry(v-jj, add-log-file-name, chr(1) )
          ,input p-str
          ,input 20
          ) no-error .
        if error-status:error then do:
          return error return-value .
        end.
      end.
    end.
    if writelogvalue eq "AsyncProc"
    then do:
       p-str = trim(p-str, (chr(13) + chr(10)) )
    .
       Publish "WriteLogAsunc" (p-str,yes).
    end.
    else if writelogvalue <> "yes" then do:
      run gbl/fileapnd.p
        ( input log-file-name
        ,input p-str
        ,input 20
        ) no-error .
      if error-status:error then do:
        return error return-value .
      end.
    end.
  end.
end procedure.
procedure write-to-screen :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-screen). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-screen). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-screen). endkey", vss-workfile )
  :
    define variable log-res as logical no-undo.
    assign
      p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) )
    .
    if auto-log-msg-h <> ?
    then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ?
    then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
  end.
end procedure.
procedure send-msg-to-email :
  define input  parameter p-subject      as character no-undo .
  define input  parameter p-text-err     as character no-undo .
  define input  parameter p-attach-files as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-msg-to-email). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-msg-to-email). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-msg-to-email). endkey", vss-workfile )
  :
    define variable v-tth             as handle    no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-param-type      as character no-undo .
    define variable v-email       as character no-undo .
    define variable v-tmp-str     as character no-undo .
    define variable v-tmp1-str    as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    delete object v-tth no-error.
    run adm/shattri.p
      ( input "get":U
       ,input  "":U
       ,input  0
       ,input  'auto-task':U
       ,input  'send-msg-to-email':U
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,input-output table-handle v-tth
      ) no-error .
    if not error-status :error  then do:
      assign
        v-tmp-str = v-value-character
      .
    end.
    delete object v-tth no-error.
    assign
      v-tmp-str     = replace(v-tmp-str, (chr(10) + chr(13)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, (chr(13) + chr(10)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, chr(10), chr(44) )
      v-num-entries = num-entries( v-tmp-str, chr(44) )
      v-email       = "":U
    .
    do v-ind = 1 to v-num-entries
    :
      assign
        v-tmp1-str = entry( v-ind, v-tmp-str, chr(44) )
      .
      if trim( v-tmp1-str ) <> "":U then do:
        if v-email = "":U then do:
          assign
            v-email = v-tmp1-str
          .
        end.
        else do:
          assign
            v-email = v-email + chr(44) + v-tmp1-str
          .
        end.
      end.
    end.
    if v-email <> "":U then do:
      run gbl/sendmail.p
        ( input v-email
        , input p-subject
        , input p-text-err
        , input p-attach-files
        ) no-error .
      if error-status :error
        or return-value <> "":U
      then do:
        return error substitute( "&1 (send-msg-to-email). &2", vss-workfile, return-value ) .
      end.
    end.
  end.
end procedure.
define  shared variable oxml-exch-dir as character no-undo .
define  shared variable oxml-heap-dir as character no-undo .
define variable err-mess as character no-undo .
define temp-table t-pck-conf no-undo
  field esys-id         as integer
  field db-num          as integer
  field current-db-num  as integer
  field pack-num        as integer
  field rcvd-recs       as integer
  field total-recs      as integer
  field sys-key         as character
  field src_db-key      as character
  field ver-num         as character
  field prev-crc        as character
  field actual-date     as date
  field actual-time-int as integer
.
FUNCTION ora-rcpt_get-rcpt-name returns character ( input p-file-name as character):
define variable v-file-name as character no-undo .
assign
v-file-name = substitute("&1-&2_&3"
                          ,entry(2, entry(1, p-file-name, "_"), "-")
                          ,entry(1, entry(1, p-file-name, "_"), "-")
                          ,entry(2, p-file-name, "_")) no-error.
if error-status:error then v-file-name = p-file-name.
return v-file-name.
END FUNCTION.
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-filelist-total-file-num           as integer      no-undo .
define variable v-filelist-total-dir-num            as integer      no-undo .
define variable v-filelist-main-procedure-handle    as handle       no-undo .
define variable v-filelist-main-procedure-name      as character    no-undo .
define temp-table temp-dirlist no-undo
    field dir-full-name     as character
    field dir-short-name    as character
    field need-process      as logical
    index xpk is primary unique dir-full-name
.
define temp-table temp-filelist no-undo
  field file-name        as character
  field file-name-no-ext as character
  field file-extension   as character
  field directory-name   as character
  field full-name        as character
  field dir-short-name   as character
  field need-process     as logical
  index xpk is unique primary full-name
  index xie1 directory-name file-name
  index xie2 directory-name file-name-no-ext
  index xie3 file-name
  index xie4 file-name-no-ext
  index xie5 need-process file-name
  .
define stream dir-list .
procedure filelist-get-file-num :
  define output parameter p-file-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-file-num = v-filelist-total-file-num
    .
  end.
end procedure.
procedure filelist-clear :
  do
  on error undo, return error return-value
  :
    define buffer buf_filelist for temp-filelist .
    assign
      v-filelist-total-file-num = 0
    .
    for each buf_filelist
    on error undo, return error
    :
      delete buf_filelist .
    end.
  end.
end procedure.
procedure filelist-init :
  do
  on error undo, return error
  :
    define input parameter p-dir-name       as character no-undo .
    define input parameter p-filter-ext     as logical   no-undo .
    define input parameter p-ext-list       as character no-undo .
    define input parameter p-dir-short-name as character no-undo .
    define buffer buf_temp-filelist for temp-filelist .
    if p-filter-ext = true
       and p-ext-list = ?
    or (p-filter-ext = false
       and p-ext-list <> ?
       and p-ext-list <> "":U
       )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "p-filter-ext" p-filter-ext skip
        "p-ext-list"   p-ext-list   skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_temp-filelist
      where buf_temp-filelist.directory-name = p-dir-name
    on error undo, return error return-value
    :
      delete buf_temp-filelist .
    end.
    input stream dir-list from os-dir( p-dir-name ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    define variable v-extension             as character no-undo .
    define variable v-file-name-without-ext as character no-undo .
    repeat
    on error undo, return error
    :
      import stream dir-list v-file v-path v-mask .
      if  v-mask <> ?
      and v-mask begins 'F':u
      then do:
      end.
      else do:
        next .
      end.
      if num-entries(v-file, '.':u) > 1
      then do:
        assign
          v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
          v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
        .
      end.
      else do:
        assign
          v-extension = ''
          v-file-name-without-ext = v-file
        .
      end.
      if p-filter-ext = true
      then do:
        if lookup(v-extension, p-ext-list) = 0
        then do:
          next .
        end.
      end.
      create buf_temp-filelist .
      assign
        buf_temp-filelist.file-name        = v-file
        buf_temp-filelist.directory-name   = p-dir-name
        buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
        buf_temp-filelist.file-extension   = v-extension
        buf_temp-filelist.full-name        = p-dir-name + '/':u + v-file
        buf_temp-filelist.dir-short-name   = p-dir-short-name
      .
      assign
        v-filelist-total-file-num = v-filelist-total-file-num + 1
      .
      if v-filelist-main-procedure-handle <> ?
      then do:
        run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle
          (input "file":U
          , input v-filelist-total-file-num
          , input buf_temp-filelist.full-name
          , input buf_temp-filelist.file-name
          ) no-error.
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-subdir-init" skip(1)
            skip "Ошибка при вызове процедуры вывода"
            skip "результатов сканирования каталогов."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
          undo, return error .
        end.
      end.
    end.
    input stream dir-list close .
    return.
  end.
end procedure.
procedure filelist-dirlist-init-by-list :
  do
  on error undo, return error
  :
    define input parameter p-root-dir   as character no-undo .
    define input parameter p-dir-list   as character no-undo .
    define input parameter p-filter-ext as logical   no-undo .
    define input parameter p-ext-list   as character no-undo .
    define variable v-num-appdir as integer   no-undo .
    do v-num-appdir = 1 to num-entries(p-dir-list)
    :
      define variable v-curr-dir  as character no-undo .
      assign
        v-curr-dir = entry(v-num-appdir, p-dir-list)
      .
      run filelist-init in this-procedure
        (input p-root-dir + '/':u + v-curr-dir
        ,input p-filter-ext
        ,input p-ext-list
        ,input v-curr-dir
        ) .
    end.
  end.
end procedure.
procedure filelist-dirlist-clear :
  do
  on error undo, return error
  :
    define buffer buf_temp-dirlist for temp-dirlist .
    assign
        v-filelist-total-dir-num = 0
    .
    for each buf_temp-dirlist
    on error undo, return error
    :
      delete buf_temp-dirlist .
    end.
  end.
end procedure.
procedure filelist-dirlist-subdir-init :
define input parameter p-dir-name   as character no-undo .
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    input stream dir-list from os-dir( p-dir-name ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    file-in-directory:
    repeat
    on error undo, return error
    :
        import stream dir-list
            v-file
            v-path
            v-mask
        .
        if  v-mask = ?
        or index( v-mask, 'D':u ) = 0
        or v-file = ".":U
        or v-file = "..":U
        then do:
            next file-in-directory.
        end.
        else do:
            find first buf_temp-dirlist
                 where buf_temp-dirlist.dir-full-name    = v-path
            no-error.
            if not available buf_temp-dirlist
            then do:
                create buf_temp-dirlist .
                assign
                    buf_temp-dirlist.dir-full-name    = v-path
                    buf_temp-dirlist.dir-short-name   = v-file
                    buf_temp-dirlist.need-process     = yes
                .
            end.
            assign
                v-filelist-total-dir-num = v-filelist-total-dir-num + 1
            .
            if v-filelist-main-procedure-handle <> ?
            then do:
                run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle (
                      input "dir":U
                    , input v-filelist-total-dir-num
                    , input buf_temp-dirlist.dir-full-name
                    , input buf_temp-dirlist.dir-short-name
                ) no-error.
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "filelist-dirlist-subdir-init"
                        skip(1)
                        skip "Ошибка при вызове процедуры вывода"
                        skip "результатов сканирования каталогов."
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
    input stream dir-list close .
end.
end procedure.
procedure filelist-dirlist-init :
define input parameter p-dir-name   as character no-undo .
    define variable v-file  as character no-undo.
    define variable v-path  as character no-undo.
    define variable v-mask  as character no-undo.
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    for each buf_temp-dirlist
       where buf_temp-dirlist.dir-full-name begins file-info :full-pathname
    on error undo, return error return-value
    :
        delete buf_temp-dirlist .
    end.
    create buf_temp-dirlist .
    assign
        buf_temp-dirlist.dir-full-name    = file-info :full-pathname
        buf_temp-dirlist.dir-short-name   = file-info :file-name
        buf_temp-dirlist.need-process     = yes
    .
    do
    while available buf_temp-dirlist
    on error undo, return error
    :
        run filelist-dirlist-subdir-init in this-procedure (
            input buf_temp-dirlist.dir-full-name
        ).
        assign
            buf_temp-dirlist.need-process = no
        .
        find first buf_temp-dirlist
             where buf_temp-dirlist.need-process = yes
        no-error.
    end.
end.
end procedure.
procedure filelist-set-procedure-handle :
define input parameter p-proc-handle    as handle           no-undo.
define input parameter p-proc-name      as character        no-undo.
    define variable v-signature    as character    no-undo.
do
on error undo, return error
:
    if p-proc-handle = ?
    or not valid-handle( p-proc-handle )
    or p-proc-handle :get-signature( p-proc-name ) = ""
    then do:
        assign
            v-filelist-main-procedure-handle = ?
            v-filelist-main-procedure-name   = ""
        .
        undo, return error "filelist-set-procedure-handle: Ошибка передачи handle основной процедуры или имени процедуры обработки результатов сканирования каталогов.".
    end.
    else do:
        assign
            v-signature = p-proc-handle :get-signature( p-proc-name )
        .
        if entry(   1, v-signature )    = "PROCEDURE":U
        and entry( 1, entry(  3, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  3, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  4, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  4, v-signature ), " ":U ) = "INTEGER":U
        and entry( 1, entry(  5, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  5, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  6, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  6, v-signature ), " ":U ) = "CHARACTER":U
        then do:
            assign
                v-filelist-main-procedure-handle = p-proc-handle
                v-filelist-main-procedure-name   = p-proc-name
            .
        end.
        else do:
            assign
                v-filelist-main-procedure-handle = ?
                v-filelist-main-procedure-name   = ""
            .
            undo, return error "filelist-set-procedure-handle: Ошибка задания параметров процедуры обработки результатов сканирования каталогов.".
        end.
    end.
end.
end procedure.
procedure filelist-clear-procedure-handle :
do
on error undo, return error
:
    assign
        v-filelist-main-procedure-handle = ?
        v-filelist-main-procedure-name   = ?
    .
end.
end procedure.
procedure filelist-build-by-dirlist :
    define buffer buf_temp-dirlist      for temp-dirlist.
do
for buf_temp-dirlist
on error undo, return error
:
    for each buf_temp-dirlist
    on error undo, return error
    :
        run filelist-init in this-procedure (
              input buf_temp-dirlist.dir-full-name
            , input no
            , input "":U
            , input buf_temp-dirlist.dir-short-name
        ).
    end.
end.
end procedure.
procedure filelist-check-dir-exists :
define input parameter p-dir-name   as character        no-undo.
define output parameter p-exists    as logical          no-undo.
do
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :file-type <> ?
    and substring( file-info :file-type, 1, 1 ) = "D":U
    then do:
        assign
            p-exists = yes
        .
    end.
    else do:
        assign
            p-exists = no
        .
    end.
end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
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
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
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
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
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
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ext-system-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-code in g#attr-lib
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
procedure ext-system-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-tooltip in g#attr-lib
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
procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
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
procedure ext-system-attr-write :
  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (input p-esys-id
      ,input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-exist in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-delete :
  define input  parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-delete in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
  // ext-system-attr-value для проверки сертификатов
function checkCertSubject returns logical private (input p-cert-subject as character,
                                                   input p-1cou-subject as character) :
// p-cert-subject приходит как "CN=ERP, OU=00000", p-1cou-subject содержит только сам код - "00000"
// lookup не ищет без пробела "OU=00000" в "CN=ERP, OU=00000"
return index(
               p-cert-subject,
               substitute("OU=&1", p-1cou-subject)
            ) > 0 .
end function .
define variable v-num-params        as integer      no-undo.
define variable v-cur-db-num        as integer      no-undo.
define variable v-cr-db-num         as integer      no-undo.
define variable v-pack-num          as integer      no-undo.
define variable v-esys-id           as integer      no-undo.
define variable v-esys-db-num       as integer      no-undo init 0.
define variable v-action            as character    no-undo.
define variable v-xml-file-name     as character    no-undo.
define variable v-log-file-name     as character    no-undo.
define variable v-list-file-name    as character    no-undo.
define variable v-source-dir        as character no-undo .
define variable v-target-dir        as character no-undo .
define variable v-temp-dir          as character no-undo .
define variable v-file-hash         as character no-undo .
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.
define variable v-parameter-list    as character    no-undo.
define variable v-file-name         as character    no-undo.
DEFINE VARIABLE v-full-path         as character    no-undo.
DEFINE VARIABLE v-file-name-no-ext  as character    no-undo.
DEFINE VARIABLE v-file-name-ext     as character    no-undo.
define variable v-path              as character    no-undo.
define variable v-success           as logical      no-undo.
define variable v-espr-pack-num     as integer      no-undo.
define variable v-espr-pack-name    as character    no-undo.
define variable v-rcvd-pack         as logical      no-undo.
define variable v-custom-pack-name  as character no-undo .
define variable v-custom-pack-flag  as logical   no-undo .
define variable v-msg-templ-start   as character no-undo .
define variable v-msg-templ-finish  as character no-undo .
define variable v-return-message    as character no-undo .
define variable v-take-count        as integer no-undo .
define variable v-analys-count      as integer no-undo .
define variable v-analys-ack        as integer no-undo .
define variable v-err-msg as character no-undo .
define variable v-ver-num as character no-undo .
define variable add-log-file-name0 as character no-undo .
define variable m-add-log-file-name as character no-undo .
define variable v-err-type as character no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-exch-file-date as character no-undo .
define variable v-return-error as integer no-undo .
define variable v-extsys-list as character no-undo .
define variable v-ack-snum_pack as character no-undo .
define variable v-1c-stat as integer no-undo .
define variable v-ack-err as character no-undo .
define variable v-sender-id as character no-undo .
define variable v-type as character no-undo .
define variable v-cert-enabled as logical no-undo . // true - проверить цифровую подпись
define variable v-cert-enstr   as character no-undo . // чтение v-cert-enabled строкой
define variable v-pack-data    as memptr no-undo .
define variable v-sign-data    as memptr no-undo .
define variable v-pkcs         as class ibs.th.gbl.pkcs no-undo .
define variable v-sign-file    as character no-undo . // имя файла с электронной подписью
define variable v-sign-fileext as character no-undo . // расширение файла с электронной подписью
define variable v-cert-issuer-name as character no-undo .
define variable v-cert-subj-name   as character no-undo .
define variable v-cert-repository  as integer no-undo .
define variable v-position     as integer no-undo . // позиция точки в имени файла
define variable v-attr-type    as character no-undo . // для чтения значений из ext-system-attr
define variable v-cert-subject as character no-undo . // владелец сертификата из входящего пакета
define variable v-1c-subj      as character initial "00000" no-undo . // так мы решили называть 1с
def var i as int.
define buffer buf_ext-system         for ub.ext-system.
define buffer buf_esys-pck-keys      for ub.esys-pck-keys.
define buffer next_filelist          for temp-filelist .
define temp-table tt-espcknum no-undo
  field tt-espr-pack-num  as integer
  field tt-espr-pack-name as character
  field tt-espr-pack-date as datetime
  index inum tt-espr-pack-num ascending
  index idate tt-espr-pack-date     ascending
.
do
for buf_ext-system
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  run write-log in p-log-handle ( 1, "Загрузка данных из внешних систем..." ).
  do : // чтение параметров
    v-num-params = num-entries(p-parameter-string) .
    assign
      v-action      =          entry( 1, p-parameter-string )
      v-cur-db-num  = integer( entry( 2, p-parameter-string ) )
    .
    if v-num-params > 2 then do:
      assign
      v-extsys-list =          entry( 3, p-parameter-string )
      v-esys-db-num = integer( entry( 4, p-parameter-string ) )
      .
      if v-extsys-list = '' then v-extsys-list = '0'.
    end.
    if v-num-params > 4 then do:
      assign
      v-pack-num  = integer( entry( 4, p-parameter-string ) )
      v-cr-db-num = integer( entry( 5, p-parameter-string ) )
      .
    end.
    else v-pack-num = -1.
    run get-version-num in parparentproc ( output v-ver-num ).
  end . // end_of чтение параметров
  case v-action:
    when "take":U then do:
      v-msg-templ-start  = "Прием пакетов данных из ВС &1 '&2'" .
      v-msg-templ-finish = "Завершен прием пакетов данных из ВС '&1'" .
    end.
    when "analys":U then do:
      v-msg-templ-start  = "Разбор данных из ВС &1 '&2'" .
      v-msg-templ-finish = "Завершен разбор данных из ВС '&1'" .
    end.
    when "take+analys":U then do:
      v-msg-templ-start  = "Прием и разбор пакетов данных из ВС &1 '&2'" .
      v-msg-templ-finish = "Завершен прием и разбор пакетов данных из ВС '&1'" .
    end.
    otherwise do:
      v-return-message = substitute( "Не предусмотрена операция &1", v-action ) .
      return error v-return-message.
    end.
  end case.
  run db-attr-value in this-procedure
               (input  ibs.th.gbl.gbl-var:g#db-num
               ,input 'int-point':U
               ,output v-sender-id
               ,output v-type
  ) no-error .
    run xmlischn_fill in this-procedure ( input 4, input 2).
    run xmlischn_fill in this-procedure ( input 4, input 3).
    run xmlischn_fill in this-procedure ( input 11, input 4).
    run xmlischn_fill in this-procedure ( input 12, input 5).
    run xmlischn_fill in this-procedure ( input 13, input 4).
    run xmlischn_fill in this-procedure ( input 18, input 4).
    run xmlischn_fill in this-procedure ( input 18, input 8).
    run xmlischn_fill in this-procedure ( input 18, input 12).
    run xmlischn_fill in this-procedure ( input 18, input 16).
    run xmlischn_fill in this-procedure ( input 18, input 20).
    run xmlischn_fill in this-procedure ( input 18, input 24).
    run xmlischn_fill in this-procedure ( input 20, input 4).
    _ext-system:
    do i = 1 to num-entries(v-extsys-list)
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      v-esys-id = int(entry(i,v-extsys-list,';')).
      for each buf_ext-system no-lock
        where buf_ext-system.esys-have-import = yes
          and buf_ext-system.esys-db-num-imp = v-cur-db-num
          and (v-esys-id = 0
                or
                (buf_ext-system.esys-id = v-esys-id
                and
                buf_ext-system.db-num = v-esys-db-num)
              )
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      :
        assign
        add-log-file-name  = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.LOG", buf_ext-system.esys-id )
        g#esys-source-esys = buf_ext-system.esys-id
        m-add-log-file-name = add-log-file-name
        .
          if buf_ext-system.delivery-method = integer('11':U)
          then do :
              if (v-sender-id = ? or trim(v-sender-id) = "")
              then do :
                  run write-log in p-log-handle (
                        input 2
                      , input 'Нет атрибута БД "Номер точки интеграции". Без него работа с системой 1С-ERP не возможна!'
                  ).
                  undo _ext-system, next _ext-system.
              end.
          end.
        do:
          run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  'cert-sign':U
                                     ,output v-cert-enstr
                                     ,output v-attr-type) no-error .
          if not error-status:error then v-cert-enabled = logical (v-cert-enstr) no-error .
          if error-status:error then do :
            run write-log in p-log-handle (
                                                  input 2
                                                , substitute("&1 Ошибка при чтении параметров ВС.&2&3&2&4&2&5"
                                                              ,vss-workfile
                                                              ,chr(10)
                                                            ,substitute( "Параметр &1", 'cert-sign':U )
                                                            ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                            ,substitute( "&1", return-value )
                                                            )
                                  ) .
            undo _ext-system, next _ext-system.
          end .
          if v-cert-enabled then do :
            run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  'cert-file-ext':U
                                     ,output v-sign-fileext
                                     ,output v-attr-type) no-error .
            if not error-status:error then
            run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  'cert-sign-issuer':U
                                     ,output v-cert-issuer-name
                                     ,output v-attr-type) no-error .
            if not error-status:error then
            run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  'cert-sign-subject':U
                                     ,output v-cert-subj-name
                                     ,output v-attr-type) no-error .
            if error-status:error then do:
              run write-log in p-log-handle (
                                                  input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3&2&4"
                                                  ,vss-workfile
                                                  ,chr(10)
                                                  ,error-status:get-message(error-status:num-messages)
                                                  ,return-value
                                                  )
                                  ) .
              undo _ext-system, next _ext-system.
            end.
            v-cert-repository = ? .
            run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  'cert-repository':U
                                     ,output v-cert-enstr
                                     ,output v-attr-type) no-error .
            if v-cert-enstr > ""
            then
              v-cert-repository = integer(v-cert-enstr) no-error .
            if v-cert-repository = ?
            then
              v-cert-repository = 0 .
            if v-cert-subj-name > "" then . else do :
              run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3"
                                                  ,vss-workfile
                                                  ,chr(10)
                                                  ,"Отсутствует имя Владельца сертификата (~"Субъект~") в параметрах настройки внешней системы"
                                                  )
                        ) .
              undo _ext-system, next _ext-system.
            end .
            if v-cert-issuer-name > "" then . else do :
              run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3"
                                                  ,vss-workfile
                                                  ,chr(10)
                                                  ,"Отсутствует имя Издателя сертификата в параметрах настройки внешней системы"
                                                  )
                        ) .
              undo _ext-system, next _ext-system.
            end .
            if not valid-object (v-pkcs) then v-pkcs = new ibs.th.gbl.pkcs().
          end .
          else assign
            v-cert-issuer-name = ""
            v-cert-subj-name   = ""
            v-sign-fileext     = ""
          .
        end . // end_of параметры настройки ЭЦП
          run bge/lockesys.p (
             input buf_ext-system.esys-id
            ,input buf_ext-system.db-num
            ,buffer buf_ext-system
            ,output v-success) no-error.
          if error-status:error or v-success = no
          then do:
              run write-log in p-log-handle (
                    input 2
                  , input return-value
              ).
              undo _ext-system, next _ext-system.
          end.
        run write-log in p-log-handle (  input 2
               ,substitute(v-msg-templ-start, buf_ext-system.esys-id, buf_ext-system.esys-name ) ) .
        run write-log in p-log-handle (  input 2
                 ,( if v-cert-enabled then substitute("Используются файлы электронной подписи с расширением '.&1'", v-sign-fileext)
                                      else "Файлы электронной подписи не используются." )
                                          ) .
          do:
            assign
              v-espr-pack-num = -1
              v-custom-pack-name = ''
            .
            // внутри espcknum.p очищается temp-filelist и вызывается его заполнение через run filelist-init
            run bge/espcknum.p ( input "get":U
                          ,input buf_ext-system.esys-id
                          ,input buf_ext-system.db-num
                          ,input buf_ext-system.delivery-method
                          ,input oxml-exch-dir
                          ,input oxml-heap-dir
                          ,input v-sign-fileext
                          ,input-output v-espr-pack-num    // передаётся в sxg-pack.p
                          ,input-output v-custom-pack-name // снаружи не используется; перед анализом обнуляется
                          ,output v-espr-pack-name // до анализа не используется; в анализе читается повторно
                          ,output v-source-dir // передаётся в sxg-pack.p
                          ,output v-target-dir // передаётся в sxg-pack.p
                          ,output v-temp-dir   // передаётся в sxg-pack.p
                          ,output v-log-file-name // до анализа не используется; в анализе - только для oracle-retail
                          ,output v-list-file-name // не используется
                          ,output v-custom-pack-flag // до анализа не используется; в анализе читается повторно
                        ) no-error.
            if error-status:error then do:
              run write-log in p-log-handle (
                                              input 2
                                            , substitute("&1 Ошибка при генерации номера пакета.&2&3&2&4"
                                                          ,vss-workfile
                                                          ,chr(10)
                                                        , error-status:get-message(error-status:num-messages)
                                                        , return-value
                                                        )
                              ) .
              undo _ext-system, next _ext-system.
            end.
            assign
              v-take-count   = 0
              v-analys-count = 0
              v-analys-ack   = 0
              v-rcvd-pack = false
            .
            if lookup( v-action, "take,take+analys":U ) <> 0 then do:
              run write-log in p-log-handle (input 2 ,  substitute ("Копирование пакетов данных из &1 в &2", v-source-dir, v-target-dir)  ) .
                v-filelist-total-file-num = 0 .
                empty temp-table temp-filelist .
              run bge/sxg-pack.p (
                            input parparentproc
                            ,input this-procedure:handle
                            ,input p-log-handle
                            ,input "get":U
                            ,input true
                            ,input ?
                            ,input v-source-dir // получено из espcknum.p
                            ,input v-target-dir // получено из espcknum.p
                            ,input v-temp-dir   // получено из espcknum.p
                            ,input v-espr-pack-num
                            ,input buf_ext-system.esys-id
                            ,input buf_ext-system.db-num
                            ,input v-cr-db-num
                            ,input buf_ext-system.delivery-method
                            ) no-error.
              if error-status:error then do:
                run write-log in p-log-handle ( input 2
                                                ,input substitute("&1 &2"
                                                          ,vss-workfile
                                                          ,return-value )
                                              ).
                undo _ext-system, next _ext-system.
              end.
            end.
            if buf_ext-system.delivery-method = integer('9':U)
            or buf_ext-system.delivery-method = integer('11':U)
            then do:
              run get-num-namepack in this-procedure
                ( input v-target-dir
                , input buf_Ext-system.esys-id
                , input buf_Ext-system.db-num
                , input buf_ext-system.delivery-method
                )
              no-error.
              if error-status:error then do:
                  run write-log in p-log-handle (
                                                  input 2
                                                , substitute("&1 Ошибка при создание списка пакетов для приема. &2&3&2&4"
                                                              ,vss-workfile
                                                              ,chr(10)
                                                            ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                            ,substitute( "&1", return-value )
                                                            )
                                  ) .
                undo _ext-system, next _ext-system.
              end.
            end.
            if lookup( v-action, "analys,take+analys":U ) <> 0 then do:
              run write-log in p-log-handle (input 2 ,  substitute ("Разбор пакетов данных из &1", v-target-dir)  ) .
              rcvd-pack:
              do while TRUE
              on error undo, return error
              :
              v-custom-pack-name = ''.
              v-espr-pack-num = - abs(v-espr-pack-num).
              if buf_ext-system.delivery-method = integer('5':U) then do:
                find first temp-filelist no-error.
                if not available temp-filelist then do:
                  leave rcvd-pack.
                end.
                assign
                v-custom-pack-name = temp-filelist.file-name.
                delete temp-filelist.
              end.
              if buf_ext-system.delivery-method = integer('9':U) then do:
                find first tt-espcknum use-index inum no-error.
                if not available tt-espcknum then do:
                  leave rcvd-pack.
                end.
                assign
                v-custom-pack-name = tt-espcknum.tt-espr-pack-name.
                delete tt-espcknum.
              end.
              if buf_ext-system.delivery-method = integer('11':U)
              then do:
                for each temp-filelist where temp-filelist.file-name begins "ack_" :
                        assign
                           v-custom-pack-name = temp-filelist.file-name
                           v-analys-ack = v-analys-ack + 1
                         .
                  run gbl/filename.p (
                                      input temp-filelist.full-name
                                      ,output v-full-path
                                      ,output v-path
                                      ,output v-file-name
                                      ,output v-file-name-no-ext
                                      ,output v-file-name-ext
                                      ) no-error .
                  if error-status :error then do:
                    run write-log in p-log-handle (
                                                  input 2
                      , ("Ошибка приёма подтверждения из файла " + temp-filelist.full-name + " : " + return-value)
                                                ) .
                    delete temp-filelist .
                    next .
                  end.
                  v-ack-snum_pack = entry(4, v-file-name, "_") .
                  run write-log in p-log-handle (input 2 ,
                    substitute ("Прием подтверждения на пакет номер &1 (файл &2)"
                              , v-ack-snum_pack
                              , v-full-path
                               )
                                                ) .
                  run gbl/md5.p(v-full-path, output v-file-hash).
                  run write-to-log( substitute("Файл: &1; Контрольная сумма: &2.", v-full-path,  v-file-hash) ) .
                  // 26/IX-2018 - загрузить данные в mem-ptr и отдать их на вход в x-document вместо файла
                  set-size(v-pack-data) = 0 .
                  COPY-LOB FROM FILE v-full-path TO OBJECT v-pack-data NO-CONVERT NO-ERROR .
                  // 26/IX-2018 Да, аски тоже надо подписывать.
                  // Далее скопирована проверка подписи пакета данных
                  if v-cert-enabled then do on error undo, throw :
                    v-position = r-index(v-full-path, ".") .
                    v-sign-file = if v-position > 0 then substring(v-full-path, 1, v-position - 1) else v-full-path .
                    v-sign-file = substitute("&1.&2", v-sign-file, v-sign-fileext) .
                    file-info:file-name = v-sign-file .
                    if file-info:file-type = ? then
                      v-err-msg = substitute("Отсутствует файл электронной подписи &1", v-sign-file) .
                    else do :
                      v-err-msg = "" .
                      COPY-LOB FROM FILE v-sign-file TO OBJECT v-sign-data NO-CONVERT .
                      v-pkcs:putSign(v-sign-data) .
                      v-cert-subject = v-pkcs:getCertSubject() .
                      if checkCertSubject (v-cert-subject, v-1c-subj) then do :
                        v-pkcs:verifySign(v-pack-data) .
                      end .
                      else do :
                        v-err-msg = substitute("Идентификатор отправителя [&1] отличается от идентификатора подписавшей стороны [&2]"
                                             , v-1c-subj, v-cert-subject) .
                      end .
                    end .
                    catch exAppErrors as class Progress.Lang.AppError :
                      v-err-msg = exAppErrors:ReturnValue .
                      if v-err-msg > "" then . else do :
                        v-err-msg = exAppErrors:GetMessage(1) .
                        if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\bge\oxmlinx.p" .
                      end .
                    end catch .
                    catch exProErrors as class Progress.Lang.ProError :
                      v-err-msg = exProErrors:GetMessage(1) .
                      if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\bge\oxmlinx.p" .
                    end catch .
                    catch exAnyErrors as class Progress.Lang.Error:
                      v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\bge\oxmlinx.p " + exAnyErrors:GetMessage(1).
                    end catch .
                    finally:
                      set-size(v-sign-data) = 0 .
                      if v-err-msg > "" then do :
                        set-size(v-pack-data) = 0 .
                        run write-log in p-log-handle ( input 2, input v-err-msg ).
                        // ack_ на ack_ не отправляем
                        undo _ext-system, next _ext-system.
                      end .
                    end finally.
                  end . // end_of if_cert
                  run rul/rcv-ack_1c.p (input v-pack-data
                                       ,input buf_ext-system.esys-id
                                       ,output v-1c-stat
                                       ,output v-ack-err
                                        ) .
                  set-size(v-pack-data) = 0 .
                  case v-1c-stat : // Статус приема пакета:
                    when 0 then do : // успешно
                      os-delete value(v-full-path) .
                      run write-log in p-log-handle (input 2 ,
                        substitute ("Подтверждение на пакет номер &1 обработано. Статус: успешно. Файл &2 успешно удалён."
                              , v-ack-snum_pack
                              , v-full-path
                               )
                                                ) .
                    end .
                    when 1 then do : // отсутствует пакет, следующий за последним принятым (для данной ошибки в поле error указывается номер отсутствующего пакета);
                      define variable v-one-pack-num as integer no-undo .
                      v-one-pack-num = integer (v-ack-err) no-error .
                      if v-one-pack-num > 0 then do :
                        run write-log in p-log-handle (input 2 ,
                        substitute ("Подтверждение на пакет номер &1 обработано. Статус: 1 - отсутствует пакет, следующий за последним принятым. Запрошена повторная отправка пакета [&2]."
                              , v-ack-snum_pack
                              , v-ack-err
                               )
                                                ) .
                        run bge/oxmloutx.p ( input parparentproc
                                        ,input p-parent-handle
                                        ,input p-log-handle
                                        ,input substitute("one-pack,&1,&2,&3,&4,&5"
                                                    ,v-cur-db-num
                                                    ,buf_ext-system.esys-id
                                                    ,buf_ext-system.db-num
                                                    ,g#db-num
                                                    ,v-ack-err)
                                  ) no-error.
                        if error-status:error then do:
                          run write-log in p-log-handle (
                                                  input 2
                                                , ( vss-workfile + chr(32)
                                        + substitute( "ERROR!!! Ошибка при отправке одного пакета данных в ВС &1", buf_ext-system.esys-id ) + chr(10)
                                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                                        + substitute( "&1", return-value ) )
                                                ) .
                        end.
                        else os-delete value(v-full-path) .
                      end.
                      else do :
                        run write-log in p-log-handle (input 2 ,
                        substitute ("Ошибка обработки подтверждения на пакет номер &1. Статус: 1 - отсутствует пакет, следующий за последним принятым. Номер отсутствующего пакета [&2] не является числом."
                              , v-ack-snum_pack
                              , v-ack-err
                               )
                                                ) .
                      end .
                    end .
                    when 4 then do : // прочие ошибки (приходит после возникновения различных run-time ошибок в 1с)
                      os-delete value(v-full-path) .
                      run write-log in p-log-handle (input 2 ,
                        substitute ("Подтверждение на пакет номер &1 обработано. Статус: 4 - прочие ошибки. Текст ошибки: &2. Файл &3 успешно удалён."
                              , v-ack-snum_pack
                              , v-ack-err
                              , v-full-path
                                    )
                                                ) .
                    end .
                    otherwise do :
                      os-delete value(v-full-path) .
                      run write-log in p-log-handle (input 2 ,
                        substitute ("Подтверждение на пакет номер &1 обработано. Статус: &2. Текст ошибки: &3. Файл &4 успешно удалён."
                              , v-ack-snum_pack
                              , v-1c-stat
                              , v-ack-err
                              , v-full-path
                               )
                                                ) .
                    end .
                  end case .
                  delete temp-filelist .
                end.
                run write-log in p-log-handle (input 2 ,  substitute ("Разбор подтверждений из &1. Просмотрено файлов &2", v-target-dir, v-analys-ack)  ) .
              do : // выбор имени файла для импорта
                  if not can-find (first temp-filelist
                                   where num-entries(temp-filelist.file-name, "_") = 4
                                     and integer(entry(3, temp-filelist.file-name, "_")) = abs(v-espr-pack-num)) then do :
                    find first temp-filelist
                         where num-entries(temp-filelist.file-name, "_") = 4
                           and integer(entry(3, temp-filelist.file-name, "_")) > abs(v-espr-pack-num) no-error .
                    if available temp-filelist then do :
                      run write-log in p-log-handle ( input 2
                                  , ("Ожидается прием пакета с номером " + string(abs(v-espr-pack-num)) +
                             ", а в каталоге следующий пакет с номером " + entry(3, temp-filelist.file-name, "_"))
                                                            ) .
                      run rul/send-ack_1c.p ( input v-sender-id
                                          , input (abs(v-espr-pack-num))
                                          ,input 1
                                          ,input string(abs(v-espr-pack-num))
                                          ,input buf_ext-system.esys-id
                                          ,input v-cert-subj-name
                                          ,input v-cert-issuer-name
                                          ,input v-sign-fileext
                                          ,input v-cert-repository
                                          ,input v-pkcs
                                          ) no-error .
                      if error-status:error then do :
                          run write-log in p-log-handle ( input 2
                                                , ( vss-workfile + chr(32)
                                        + substitute( "Ошибка при отправке ack_ в ВС &1", buf_ext-system.esys-id) + chr(10)
                                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                                        + substitute( "&1", return-value ) )
                                                ) .
                      end .
                    end .
                    else do :
                      run write-log in p-log-handle ( input 2
                                                ,substitute(" для ВС '&1' отсутствуют пакеты, подлежащие разбору", buf_ext-system.esys-name ) ) .
                      leave rcvd-pack.
                    end .
                  end .
                for each temp-filelist no-lock :
                    if integer(entry(3, temp-filelist.file-name, "_")) = abs(v-espr-pack-num)
                    or temp-filelist.file-name begins "ack_"
                    or temp-filelist.file-name begins "err_"
                    then do :
                        assign v-custom-pack-name = temp-filelist.file-name.
                        if temp-filelist.file-name begins "ack_"
                        then
                        delete temp-filelist .
                        leave.
                    end.
                    delete temp-filelist.
                end.
              end . // end_of выбор имени файла для импорта
              end.
              run bge/espcknum.p ( input "get":U
                            ,input buf_ext-system.esys-id
                            ,input buf_ext-system.db-num
                            ,input buf_ext-system.delivery-method
                            ,input oxml-exch-dir
                            ,input oxml-heap-dir
                            ,input v-sign-fileext
                            ,input-output v-espr-pack-num
                            ,input-output v-custom-pack-name
                            ,output v-espr-pack-name
                            ,output v-source-dir
                            ,output v-target-dir
                            ,output v-temp-dir
                            ,output v-log-file-name
                            ,output v-list-file-name
                            ,output v-custom-pack-flag
                          ) no-error.
                if error-status:error then do:
                  run write-log in p-log-handle (
                                                  input 2
                                                , substitute("&1 Ошибка при генерации номера пакета.&2&3&2&4"
                                                              ,vss-workfile
                                                              ,chr(10)
                                                            ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                            ,substitute( "&1", return-value )
                                                            )
                                  ) .
                  undo _ext-system, next _ext-system.
                end.
                if v-espr-pack-name = '' then do:
                  next rcvd-pack.
                end.
                assign
                v-file-name = v-target-dir + chr(92) + v-espr-pack-name +
                            (if v-custom-pack-flag
                              then ''
                              else 'xml')
                .
                run write-log in p-log-handle (input 2 ,  substitute ("Разбор пакетов из &1. Обработка пакета &2", v-target-dir, v-file-name)  ) .
                run gbl/filename.p (
                                      input v-file-name
                                      ,output v-full-path
                                      ,output v-path
                                      ,output v-file-name
                                      ,output v-file-name-no-ext
                                      ,output v-file-name-ext
                                      ) no-error .
                if error-status :error then do:
                  leave rcvd-pack.
                end.
                if buf_ext-system.delivery-method = integer('3':U) then do:
                  assign
                  add-log-file-name0 = add-log-file-name
                  add-log-file-name = add-log-file-name0 + chr(1) + v-log-file-name + chr(92) + ora-rcpt_get-rcpt-name(v-file-name-no-ext) + ".LOG"
                  .
                  run gbl/dir-cre.p (
                                      input v-log-file-name
                                      ) no-error.
                  os-delete value(v-log-file-name + chr(92) + ora-rcpt_get-rcpt-name(v-file-name-no-ext) + ".LOG").
                end.
                v-err-type = ''.
                v-return-error = 0.
                run gbl/md5.p(v-full-path, output v-file-hash).
                run write-to-log( substitute("Файл: &1; Контрольная сумма: &2.", v-full-path,  v-file-hash) ) .
                do :
                  // 23/VIII-2018 - загрузить данные в mem-ptr и отдать их на вход в sax-reader вместо файла
                  set-size(v-pack-data) = 0 .
                  COPY-LOB FROM FILE v-full-path TO OBJECT v-pack-data NO-CONVERT NO-ERROR .
                  if v-cert-enabled then do on error undo, throw :
                    v-position = r-index(v-full-path, ".") .
                    v-sign-file = if v-position > 0 then substring(v-full-path, 1, v-position - 1) else v-full-path .
                    v-sign-file = substitute("&1.&2", v-sign-file, v-sign-fileext) .
                    file-info:file-name = v-sign-file .
                    if file-info:file-type = ? then
                      v-err-msg = substitute("Отсутствует файл электронной подписи &1", v-sign-file) .
                    else do :
                      v-err-msg = "" .
                      COPY-LOB FROM FILE v-sign-file TO OBJECT v-sign-data NO-CONVERT .
                      v-pkcs:putSign(v-sign-data) .
                      v-cert-subject = v-pkcs:getCertSubject() .
                      if checkCertSubject (v-cert-subject, v-1c-subj) then do :
                        v-pkcs:verifySign(v-pack-data) .
                      end .
                      else do :
                        v-err-msg = substitute("Идентификатор отправителя [&1] отличается от идентификатора подписавшей стороны [&2]"
                                             , v-1c-subj, v-cert-subject) .
                      end .
                    end .
                    // ошибки - в лог, и ...
                    catch exAppErrors as class Progress.Lang.AppError :
                      v-err-msg = exAppErrors:ReturnValue .
                      if v-err-msg > "" then . else do :
                        v-err-msg = exAppErrors:GetMessage(1) .
                        if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\bge\oxmlinx.p" .
                      end .
                    end catch .
                    catch exProErrors as class Progress.Lang.ProError :
                      v-err-msg = exProErrors:GetMessage(1) .
                      if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\bge\oxmlinx.p" .
                    end catch .
                    catch exAnyErrors as class Progress.Lang.Error:
                      v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\bge\oxmlinx.p " + exAnyErrors:GetMessage(1).
                    end catch .
                    finally:
                      set-size(v-sign-data) = 0 .
                      if v-err-msg > "" then do :
                        v-return-error = 1.
                        set-size(v-pack-data) = 0 .
                        v-err-msg = substitute("Пакет &1. Файл &2. &3", v-espr-pack-num, v-full-path, v-err-msg) .
                        run write-log in p-log-handle ( input 2, input v-err-msg ).
                        // ... - и без сертификата блокируем дальнейшую работу
                        run rul/send-ack_1c.p
                        (input v-sender-id
                        ,input v-espr-pack-num // номер пакета
                        ,input 2               // status = 2 – несоответствие файла данных и ЭП;
                        ,input v-err-msg       // error - описание ошибки
                        ,input buf_ext-system.esys-id
                        ,input v-cert-subj-name
                        ,input v-cert-issuer-name
                        ,input v-sign-fileext
                        ,input v-cert-repository
                        ,input v-pkcs
                        ) no-error .
                        if error-status:error then do :
                          run write-log in p-log-handle (
                                                  input 2
                                                , ( vss-workfile + chr(32)
                                        + substitute( "Ошибка отправки ack_ в ВС &1", buf_ext-system.esys-id) + chr(10)
                                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                                        + substitute( "&1", return-value ) )
                                                ) .
                        end .
                        // undo _ext-system, next _ext-system.
                      end .
                    end finally.
                  end . // end_of if_cert
                  if v-return-error = 0 then do :
                    if transaction then do:
                      message vss-workfile vss-revision vss-description skip
                        substitute("Вызов процедуры в действующей транзакции недопустим") skip
                      view-as alert-box error .
                      return error substitute( "&1. Вызов процедуры в действующей транзакции недопустим", vss-workfile ) .
                    end.
                    if add-log-file-name = ? and m-add-log-file-name > "" then
                       add-log-file-name = m-add-log-file-name.
                  run bge/cmdeigen.p (
                                        input parparentproc
                                        ,input this-procedure:handle
                                        ,input p-log-handle
                                        ,input buf_ext-system.esys-id
                                        ,input buf_ext-system.db-num
                                        ,input v-cur-db-num
                                        ,input v-full-path
                                        ,input v-file-name
                                        ,input v-pack-data
                                        ,input v-espr-pack-num
                                        ,input add-log-file-name
                                        ) no-error.
                  if error-status:error then v-return-error = 1.
                  end .
                  set-size(v-pack-data) = 0 .
                  if not can-find(first  ub.esys-pck-rcvd no-lock
                                    where ub.esys-pck-rcvd.esys-id  = buf_Ext-system.esys-id
                                      and ub.esys-pck-rcvd.db-num   = buf_Ext-system.db-num
                                      and ub.esys-pck-rcvd.espr-cr-db-num   = g#db-num
                                      and ub.esys-pck-rcvd.espr-pack-num = v-espr-pack-num
                                      )
                  then do:
                    v-return-error = 2.
                  end.
                  else v-analys-count = v-analys-count + 1 . // для итогового сообщения о количестве обработанных пакетов
                end.
                if v-return-error > 0 then do:
                if v-err-type = '' then do:
                  assign
                  v-err-type = 'PROCESSING'.
                end.
                v-err-msg = substitute( "Ошибка при разборе файла &1.&2&3&2&4"
                                        , v-file-name
                                        ,chr(10)
                                        , return-value
                                        , (if v-return-error = 1
                                          then trim( error-status :get-message( 1 ) )
                                          else "Пакет принят неполностью")
                                      )         .
                run write-log in p-log-handle (
                                                input 2
                                                ,input v-err-msg ).
                  run send-msg-to-email in parparentproc
                      ( input substitute( "ТН (ver &2) БД &1. Ошибка OXML при импорте пакета из ВС &2"
                                        , v-ver-num
                                        , v-cur-db-num
                                        , buf_ext-system.esys-id )
                      ,input v-err-msg
                      ,input (if buf_ext-system.delivery-method = integer('3':U)
                              then entry(num-entries(add-log-file-name, chr(1)), add-log-file-name, chr(1))
                              else '')
                      ) no-error .
                  if error-status :error then do:
                    run write-log in p-log-handle (
                      input 2
                    , input substitute( "&1. &3&2&4", vss-workfile, chr(10), error-status:get-message(1), return-value )
                                                      ) .
                  end.
                end.
                if buf_ext-system.delivery-method = integer('3':U) then do:
                  if v-exch-file-date = "" then do:
                    run cur-time in this-procedure ( output v-today, output v-time).
                    v-exch-file-date = string(datetime(v-today, mtime), "99/99/9999 HH:MM:SS").
                  end.
                  run rul/ora-rcpt.p (
                                        input parparentproc
                                      ,input this-procedure:handle
                                      ,input p-log-handle
                                      ,input v-cmd-proc-handle
                                      ,input v-cmd-code
                                      ,input buf_ext-system.esys-id
                                      ,input v-espr-pack-num
                                      ,input v-file-name
                                      ,input v-exch-file-date
                                      ,input entry(num-entries(add-log-file-name, chr(1)), add-log-file-name, chr(1))
                                      ,input v-err-type) no-error.
                  if error-status:error then do:
                    v-err-msg = substitute( "Ошибка при разборе файла &1&2Не удалось сформировать квитанцию для пакета.&2&3&2&4"
                                            , v-file-name
                                            ,chr(10)
                                            , return-value
                                            , error-status:get-message(1)
                                          )         .
                    os-delete value(entry(num-entries(add-log-file-name, chr(1)), add-log-file-name, chr(1))).
                    assign
                    add-log-file-name = add-log-file-name0
                    .
                    run write-log in p-log-handle (
                                                    input 2
                                                    ,input v-err-msg
                                                                      ).
                    run send-msg-to-email in parparentproc
                      ( input substitute( "ТН (ver &2) БД &1. Ошибка OXML при импорте пакета из ВС &2"
                                        , v-ver-num
                                        , v-cur-db-num
                                        , buf_ext-system.esys-id )
                      ,input v-err-msg
                      ,input (if buf_ext-system.delivery-method = integer('3':U)
                              then entry(num-entries(add-log-file-name, chr(1)), add-log-file-name, chr(1))
                              else '')
                      ) no-error .
                    if error-status :error then do:
                    run write-log in p-log-handle (
                      input 2
                    , input substitute( "&1. &3&2&4", vss-workfile, chr(10), error-status:get-message(1), return-value )
                                                      ) .
                    end.
                  end.
                  if v-err-type = '' then  do:
                    os-delete value(entry(num-entries(add-log-file-name, chr(1)), add-log-file-name, chr(1))).
                  end.
                  assign
                  add-log-file-name = add-log-file-name0
                  .
                end.
                if buf_ext-system.delivery-method = integer('11':U)
                and v-return-error > 0
                then do:
                  run gbl/ren-file.p (input v-full-path,
                                      input (v-path + "\err_" + v-file-name)
                                      ) no-error.
                  if v-cert-enabled then do :
                    v-position = r-index(v-sign-file, "\") .
                  run gbl/ren-file.p (input v-sign-file,
                                      input (v-path + "\err_" + substring(v-sign-file, v-position + 1))
                                      ) no-error.
                  end .
                end.
                if v-return-error > 0
                and buf_ext-system.delivery-method <> integer('5':U)
                then do:
                  return error ''.
                end.
                assign
                  v-rcvd-pack = true
                .
                if not (v-espr-pack-name begins "ack_") then
                v-espr-pack-num = v-espr-pack-num + 1 .
                if ( v-pack-num <> -1
                    and v-espr-pack-num > v-pack-num
                  )
                  or lookup( v-action, "analys":U ) <> 0
                then do:
                  leave rcvd-pack.
                end.
              end.
            end.
            run gbl/del-file.p ( input v-temp-dir ) no-error .
            if error-status:error then do:
              run write-to-log( vss-workfile + chr(32)
                                + substitute( "&1", return-value )
                              ).
            end.
            if (v-analys-count = 0) and (lookup( v-action, "take,take+analys":U ) > 0) then
              run write-log in p-log-handle (  input 2
                                                ,substitute(" для ВС '&1' нет разобранных пакетов", buf_ext-system.esys-name ) ) .
            run write-log in p-log-handle (  input 2
                                                ,substitute(v-msg-templ-finish, buf_ext-system.esys-name ) ) .
        end.
        add-log-file-name = ?.
      end.
    end.
    if valid-object(v-pkcs) then delete object v-pkcs .
    run write-log in p-log-handle (
          input 1
        , input "Загрузка данных по внешним системам завершена."
    ).
end.
procedure get-log-file-name :
define output parameter p-log-file-name as character no-undo .
  do
  on error undo, return error
  :
    p-log-file-name = add-log-file-name.
  end.
end procedure.
procedure set-err-type :
define input parameter p-err-type as character no-undo .
if v-err-type = '' then v-err-type = p-err-type.
end procedure.
procedure set-exch-date-time :
define input parameter p-exch-file-date as character no-undo .
v-exch-file-date = p-exch-file-date.
end procedure.
procedure cb_fill-filelist :
define input parameter p-file-name as character no-undo .
define input parameter p-dm as integer no-undo .
define variable v-file-name as character no-undo .
do
on error undo, return error
:
  find first temp-filelist where
            temp-filelist.file-name = p-file-name no-error.
  if p-dm = integer('9':U)
  then do:
    if not available temp-filelist then do:
      create temp-filelist.
      if num-entries(p-file-name, '.':u) > 1
      then do:
        assign
          temp-filelist.file-extension = entry(num-entries(p-file-name, '.':u), p-file-name,  '.':u )
          temp-filelist.file-name-no-ext = entry(num-entries(p-file-name, '.':u) - 1, p-file-name, '.':u )
        .
      end.
      else do:
        assign
          temp-filelist.file-extension = ''
          temp-filelist.file-extension = p-file-name
        .
      end.
      assign
      temp-filelist.file-name = p-file-name.
      release temp-filelist.
    end.
  end.
  else do:
    if not available temp-filelist then do:
      v-file-name = p-file-name.
      entry(1, v-file-name, "_") = "".
      create temp-filelist.
      assign
      temp-filelist.file-name = p-file-name
      temp-filelist.full-name = v-file-name
      .
      release temp-filelist.
    end.
  end.
end.
end procedure.
procedure get-num-namepack :
define input parameter p-target-dir as character no-undo .
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-ext-sys-met as integer no-undo .
define variable v-file-pack-num as integer no-undo .
define variable datestr as character no-undo.
define variable timestr as character no-undo.
  define variable xml-source as character no-undo.
  define variable xml-result as character no-undo.
  define variable java as character no-undo.
  define variable saxon as character no-undo.
  define variable xsl as character no-undo.
  define variable ii as integer no-undo.
do
on error undo, return error
:
  case p-ext-sys-met :
    when 11 then do :
      run filelist-init in this-procedure
      (input p-target-dir
      ,input true
      ,input "xml" // ,p7s,p7c"

      ,input ""
      ) no-error.
      if error-status:error then do:
        undo, return error .
      end.
      
      for each temp-filelist:
        /* пакеты и аски оставляем;
           прочие файлы игнорируем:
           - where temp-filelist.file-name begins "err_"
           - исключаем файлы с электронной подисью (такая же стоит в bge/espcknum.p):
             if (v-sign-fileext > "") and (temp-filelist.file-extension = v-sign-fileext)
           - ещё электронная подпись, связанная с bge/espcknum.p и bge/oxmlspci.w:
             if can-do("p7s,p7c", temp-filelist.file-extension)
           - в директорию импорта стали попадать файлы иконок, сслылок, и прочего,
             у которых другая структура имени и потом они ругаются на entry(3, ...):
             if num-entries(temp-filelist.file-name, "_") > 2 then . else delete temp-filelist .
        */
        if  num-entries(temp-filelist.file-name, "_") = 4 then do :
         /* if p-esys-id = integer (entry (2, temp-filelist.file-name-no-ext, "_")) then .
          else do :
            delete temp-filelist.
            next .  
          end . */
          v-file-pack-num = integer (entry (3, temp-filelist.file-name-no-ext, "_")) no-error .
          if error-status:error then do:
            /* ошибка возникнет при присвоении, если неверное имя пакета - например начинается не с номера пакета, пропускаем идем дальше.*/
            delete temp-filelist.
            next .  
          end.
          if v-espr-pack-num > v-file-pack-num then next .  
          create tt-espcknum.
          assign
            tt-espcknum.tt-espr-pack-name = temp-filelist.file-name
            tt-espcknum.tt-espr-pack-num  = v-file-pack-num
          .
        end .
        else if (  num-entries(temp-filelist.file-name, "_") = 5
                   and temp-filelist.file-name begins "ack"  ) then do :
          /*if p-esys-id = integer (entry (3, temp-filelist.file-name-no-ext, "_")) then .
          else do :
            delete temp-filelist.
            next .  
          end .*/
        end .
        else do :
          /* прочие файлы игнорируем */
          delete temp-filelist.
          next.
        end.
      end. /* end_of for_each temp-filelist */

    end . /* end_of when esys-dm-erp-1C-RN */
    when 9 then do :
      
      ii = 0.
      for each temp-filelist
         where temp-filelist.file-name begins "fail" 
      and not (temp-filelist.file-name matches "*Stsmsg*"
           or  temp-filelist.file-name matches "*unknown*") :
        ii = ii + 1.
        create tt-espcknum.
        assign
          tt-espcknum.tt-espr-pack-name = temp-filelist.file-name + "."
          tt-espcknum.tt-espr-pack-num = ii
        no-error.      
      end.
      for each temp-filelist where temp-filelist.file-name begins "ok" 
      and  not (temp-filelist.file-name matches "*Stsmsg*"
                or  temp-filelist.file-name matches "*unknown*") :
      ii = ii + 1.
      create tt-espcknum.
      assign
        tt-espcknum.tt-espr-pack-name = temp-filelist.file-name + "."
        tt-espcknum.tt-espr-pack-num = ii
      no-error.
      end.
      for each temp-filelist where temp-filelist.file-name begins "ORDRSP" :
      ii = ii + 1.
      create tt-espcknum.
      assign
        tt-espcknum.tt-espr-pack-name = temp-filelist.file-name + "."
        tt-espcknum.tt-espr-pack-num = ii
      no-error.
      end.
      for each temp-filelist where temp-filelist.file-name begins "DESADV" :
      ii = ii + 1.
      create tt-espcknum.
      assign
        tt-espcknum.tt-espr-pack-name = temp-filelist.file-name + "."
        tt-espcknum.tt-espr-pack-num = ii
      no-error.            
      end.
      
    end . /* end_of when esys-dm-contour-edi */
    otherwise return .
  end case .

  

/* 04/III-2019 - не используется
  if v-l-err then
    run write-log in p-log-handle (
          input 1
        , input substitute( "При преобразовании файла(ов) возникли ошибки. Проверьте целостность xml пакетов.")
    ).
*/
end.

end procedure. /* get-num-namepack */
