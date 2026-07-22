block-level on error undo, throw.
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle      as widget-handle    no-undo.
define input parameter p-log-handle         as handle           no-undo.
define input parameter p-parameter-string   as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт в файл OpenXML".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "X(65)" no-undo
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
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "X(65)" no-undo
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream out-stream.
define variable v-action as character no-undo .
define variable v-ver-num as character no-undo .
define variable v-err-msg as character no-undo .
define temp-table t-list-pack no-undo
field pack-num    like ub.esys-pck-sent.esps-pack-num
field re-gen-time as   logical                 initial false
field SendTxtDate like ub.esys-pck-sent.esps-SendTxtDate initial ?
index pi is unique primary pack-num ascending
index iregen re-gen-time SendTxtDate
.
define temp-table temp_esys-route no-undo
    field tesr-key  as int64
    field esys-id           as integer
    field db-num            as integer
    field esr-cr-db-num     as integer
    field esr-last-pack     as integer
    field esr-tbl-ord       as int64
    index pi is primary unique
        tesr-key
.
    define variable v-cur-db-num        as integer      no-undo.
    define variable v-tesr-key          as integer      no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-time-wait         as integer      no-undo.
    define variable v-success           as logical      no-undo.
    define variable v-esys-id           as integer      no-undo.
    define variable v-esys-db-num       as integer      no-undo.
    define variable v-esps-cr-db-num    as integer      no-undo.
    define variable v-esps-pack-num     as integer      no-undo .
    define variable v-esps-pack-name    as character no-undo .
    define variable v-pack-file-name    as character no-undo .
    define variable v-custom-pack-name  as character no-undo .
    define variable v-custom-pack-flag  as logical   no-undo .
    define variable v-source-dir        as character no-undo .
    define variable v-target-dir        as character no-undo .
    define variable v-temp-dir          as character no-undo .
    define variable v-log-file-name     as character    no-undo.
    define variable v-list-file-name    as character    no-undo.
    define variable v-err-gen-pack      as integer   no-undo .
    define variable v-ind               as integer   no-undo .
    define variable v-max-p-queue       as integer   no-undo .
    define variable v-max-p-time        as integer   no-undo .
define variable v-attr-type        as character no-undo . // для чтения значений из ext-system-attr
define variable v-cert-enstr       as character no-undo . // чтение v-cert-enabled строкой
define variable v-cert-enabled     as logical no-undo . // true - добавить цифровую подпись
define variable v-cert-subj-name   as character no-undo . // поле SubjectName (моё имя) в сертификате
define variable v-cert-issuer-name as character no-undo . // поле IssuerName (кем выдан) в сертификате
define variable v-sign-fileext     as character no-undo . // расширение файла с электронной подписью
define variable v-cert-repository  as integer no-undo .
    define buffer buf_ext-system         for ub.ext-system.
    define buffer buf_esys-pck-sent      for ub.esys-pck-sent.
    define buffer buf_temp_esys-route for temp_esys-route.
    define buffer buf_esys-route for ub.esys-route.
    define temp-table tt_esys-route no-undo like ub.esys-route.
    define stream 1c-log .
do
for buf_ext-system
on error undo, return error
:
  assign
      v-action =  entry( 1, p-parameter-string )
      v-cur-db-num = integer( entry( 2, p-parameter-string ) )
      no-error
  .
  if error-status:error then do:
      assign
      add-log-file-name = ?
      .
      message vss-workfile vss-revision vss-description skip
              substitute( "Неверная структура составного параметра p-parameter-string = &1", p-parameter-string )
              view-as alert-box error.
      return error.
  end.
  case v-action:
    when "all" then do:
    end.
    when "one-esys" then do:
      assign
      v-esys-id = integer( entry( 3, p-parameter-string ) )
      v-esys-db-num  = integer( entry( 4, p-parameter-string ) )
      no-error .
    end.
    when "all-unconf" then do:
      assign
      v-esys-id = 0
      v-esys-db-num  = 0
      v-esps-cr-db-num = -1
      v-esps-pack-num  = -1
      no-error
      .
    end.
    when "one-esys-unconf" then do:
      assign
      v-esys-id = integer( entry( 3, p-parameter-string ) )
      v-esys-db-num  = integer( entry( 4, p-parameter-string ) )
      v-esps-cr-db-num = -1
      v-esps-pack-num  = -1
      no-error
      .
    end.
    when "one-pack" then do:
      assign
      v-esys-id = integer( entry( 3, p-parameter-string ) )
      v-esys-db-num  = integer( entry( 4, p-parameter-string ) )
      v-esps-cr-db-num = integer( entry( 5, p-parameter-string ) )
      v-esps-pack-num  = integer( entry( 6, p-parameter-string ) )
      no-error
      .
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
              substitute( "Не предусмотрена операция &1", v-action )
              view-as alert-box error.
      return error.
    end.
  end.
  if error-status:error then do:
      message vss-workfile vss-revision vss-description skip
              substitute( "Неверная структура составного параметра p-parameter-string = &1", p-parameter-string )
              view-as alert-box error.
      return error.
  end.
   run get-version-num in parparentproc
    ( output v-ver-num
    ).
  run write-log in p-log-handle (
        input 1
      , input substitute( "Выгрузка данных по внешним системам..." )
  ).
  start-export:
  for each buf_ext-system no-lock
      where (buf_ext-system.esys-have-export = yes
        and buf_ext-system.esys-db-num-exp = v-cur-db-num
        and (v-esys-id = 0
              or
              (buf_ext-system.esys-id = v-esys-id
              and
              buf_ext-system.db-num = v-esys-db-num)
            )
           )
        or
       (buf_ext-system.esys-have-import = yes
        and buf_ext-system.imp-conf-send = integer('1':U)
        and buf_ext-system.esys-db-num-imp = v-cur-db-num
        and (v-esys-id = 0
              or
              (buf_ext-system.esys-id = v-esys-id
              and
              buf_ext-system.db-num = v-esys-db-num)
            )
           )
  by buf_ext-system.esys-id
  on error undo, return error
  :
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", buf_ext-system.esys-id )
    .
    case v-action:
      when "all"
      or
      when "one-esys"
      then do:
        run write-log in p-log-handle (
              input 2
            , input substitute( "Выгрузка данных по внешней системе '&1'...", buf_ext-system.esys-name )
        ).
      end.
      when "one-pack":U then do:
        find first buf_esys-pck-sent no-lock
          where buf_esys-pck-sent.esys-id = buf_ext-system.esys-id
            and buf_esys-pck-sent.db-num = buf_ext-system.db-num
            and buf_esys-pck-sent.esps-pack-num = v-esps-pack-num
          no-error
        .
        if buf_esys-pck-sent.esps-rcvd = no or
           can-find(first buf_esys-route no-lock where
                          buf_esys-route.esys-id = buf_esys-pck-sent.esys-id
                      and buf_esys-route.db-num = buf_esys-pck-sent.db-num
                      and buf_esys-route.esr-cr-db-num = g#db-num
                      and Buf_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
                   )
        then do:
          run write-log in p-log-handle (
                input 2
               ,input substitute("Отправка одного пакета данных в ВС &1 пакет номер &2", buf_ext-system.esys-name, v-esps-pack-num )
          ).
        end.
        else do:
          run write-log in p-log-handle (
                input 2
               ,input substitute("Отправить пакет N &1 для ВС N &2 нельзя. Получено подтверждение о его приеме и данные удалены. Дата и время подтверждения: &3 &4.", v-esps-pack-num, buf_ext-system.esys-id, buf_esys-pck-sent.esps-rcvdDate, buf_esys-pck-sent.esps-rcvdTime )
          ).
          return.
        end.
      end.
      when "one-esys-unconf":U
      or
      when "all-unconf"
      then do:
        run write-log in p-log-handle (
              input 2
            ,input substitute("Отправка всех неподтвержденных пакетов данных в ВС &1", buf_ext-system.esys-name )
        ).
      end.
      otherwise do:
        message vss-workfile vss-revision vss-description skip
                substitute( "Не предусмотрена операция &1", v-action )
                view-as alert-box error.
        return error.
      end.
    end case.
    run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  'cert-sign':U
                                     ,output v-cert-enstr
                                     ,output v-attr-type) no-error .
    if not error-status:error then v-cert-enabled = logical (v-cert-enstr) no-error .
    if error-status:error then do:
      run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3&2&4&2&5"
                                                  ,vss-workfile
                                                  ,chr(10)
                                                  ,substitute( "Параметр &1", 'cert-sign':U )
                                                  ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                  ,substitute( "&1", return-value )
                                                  )
                        ) .
      return error.
    end.
    if v-cert-enabled then do :
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
      if not error-status:error then
      run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  'cert-file-ext':U
                                     ,output v-sign-fileext
                                     ,output v-attr-type) no-error .
      if error-status:error then do:
        run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3&2&4"
                                                  ,vss-workfile
                                                  ,chr(10)
                                                  ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                  ,substitute( "&1", return-value )
                                                  )
                        ) .
        return error.
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
        return error.
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
        return error.
      end .
    end .
    else assign
      v-cert-issuer-name = ""
      v-cert-subj-name   = ""
      v-sign-fileext     = ""
    .
    empty temp-table temp_esys-route .
    assign
    v-success = no
    g#esys-source-esys = -1
    .
    run bge/lockesys.p (
        input buf_ext-system.esys-id
      ,input buf_ext-system.db-num
      ,buffer buf_ext-system
      ,output v-success) no-error.
    if error-status:error
    or v-success = no
    then do:
        run write-log in p-log-handle (
              input 2
            , input return-value
        ).
        undo start-export, next start-export.
    end.
    assign
      v-max-p-queue = (if buf_ext-system.exp-conf-wait = integer('1':U)
                       then buf_ext-system.max-p-queue
                       else 1000)
      v-max-p-time  = buf_ext-system.max-p-time
      v-err-gen-pack = 0
    .
    for each t-list-pack
    on error undo, return error
    :
      delete t-list-pack .
    end.
    if v-action = "one-pack":U then do:
      create t-list-pack .
      assign
        t-list-pack.pack-num = v-esps-pack-num
      .
    end.
    else do:
      run cur-time( output v-today
                    ,output v-time
                  ) no-error .
      if error-status :error then do:
        run write-log in p-log-handle(
                          input 2
                          ,input substitute("&1 Ошибка при определении текущего времени"
                                            ,vss-workfile )
                        ) .
        return error.
      end.
      assign
        v-time-wait    = -1
      .
      for each tt_esys-route exclusive-lock:
          delete tt_esys-route.
      end.
      for each buf_esys-route no-lock
        where buf_esys-route.esys-id       = buf_ext-system.esys-id
              and buf_esys-route.db-num = buf_ext-system.db-num
      :
          create tt_esys-route.
          buffer-copy buf_esys-route to tt_esys-route.
      end.
      _buf_esys-pck-sent:
      for each buf_esys-pck-sent no-lock
        where buf_esys-pck-sent.esys-id = buf_ext-system.esys-id
          and buf_esys-pck-sent.db-num = buf_ext-system.db-num
          and buf_esys-pck-sent.esps-cr-db-num = v-cur-db-num
      on error undo, leave
      :
        if buf_esys-pck-sent.esps-rcvd = yes then next _buf_esys-pck-sent.
        find first t-list-pack no-lock
          where t-list-pack.pack-num = buf_esys-pck-sent.esps-pack-num
          no-error
        .
        if not available t-list-pack then do:
          create t-list-pack .
          assign
            t-list-pack.pack-num    = buf_esys-pck-sent.esps-pack-num
            t-list-pack.SendTxtDate = buf_esys-pck-sent.esps-SendTxtDate
            v-ind = v-ind + 1
          .
        end.
        if v-max-p-time <> 0
          and
          buf_esys-pck-sent.esps-SendTxtDate <> ?
          and buf_esys-pck-sent.esps-SendTxtTimeInt <> 0
          and ( buf_esys-pck-sent.esps-SendTxtDate < v-today
                or ( buf_esys-pck-sent.esps-SendTxtDate = v-today
                    and buf_esys-pck-sent.esps-SendTxtTimeInt <= v-time
                  )
              )
        then do:
          assign
            v-time-wait = ( v-today - buf_esys-pck-sent.esps-SendTxtDate ) * 24 * 60 * 60
                          + ( v-time - buf_esys-pck-sent.esps-SendTxtTimeInt )
          .
        end.
        if v-time-wait >= v-max-p-time * 60 then do:
          assign
            t-list-pack.re-gen-time = true
          .
        end.
        if buf_ext-system.esys-num-days-keep-exp > 0
        and (v-today - buf_esys-pck-sent.esps-Credate) > buf_ext-system.esys-num-days-keep-exp
        and buf_ext-system.exp-conf-wait = integer('0':U)
        then do:
          run delete-old-pck in this-procedure ( buffer buf_esys-pck-sent
                                                ,input buf_esys-pck-sent.esys-id
                                                ,input buf_esys-pck-sent.db-num
                                                ,input buf_esys-pck-sent.esps-cr-db-num
                                                ,input buf_esys-pck-sent.esps-pack-num
                                                ,input buf_ext-system.esys-name
                                                ) no-error.
          delete t-list-pack.
        end.
      end.
      if buf_ext-system.exp-conf-wait = integer('1':U)
      and buf_ext-system.esys-num-days-keep-exp > 0
      then do:
        find first buf_esys-route no-lock where
                  buf_esys-route.esys-id = buf_ext-system.esys-id
              and buf_esys-route.db-num = buf_ext-system.db-num
              and buf_esys-route.esr-last-pack > 0
              no-error.
        if available buf_esys-route then do:
          for each buf_esys-pck-sent no-lock
            where buf_esys-pck-sent.esys-id = buf_ext-system.esys-id
              and buf_esys-pck-sent.db-num = buf_ext-system.db-num
              and buf_esys-pck-sent.esps-cr-db-num = v-cur-db-num
              and buf_esys-pck-sent.esps-pack-num >= buf_esys-route.esr-last-pack
              and buf_esys-pck-sent.esps-rcvd = yes:
            if (v-today - buf_esys-pck-sent.esps-Credate) > buf_ext-system.esys-num-days-keep-exp
            then do:
              run delete-old-pck in this-procedure ( buffer buf_esys-pck-sent
                                                    ,input buf_esys-pck-sent.esys-id
                                                    ,input buf_esys-pck-sent.db-num
                                                    ,input buf_esys-pck-sent.esps-cr-db-num
                                                    ,input buf_esys-pck-sent.esps-pack-num
                                                    ,input buf_ext-system.esys-name
                                                    ) no-error.
            end.
          end.
        end.
      end.
      if v-action = "all":U
      or v-action = "one-esys"
        and v-ind < v-max-p-queue
      then do:
        for each t-list-pack
          where t-list-pack.re-gen-time = false
            and t-list-pack.SendTxtDate <> ?
        on error undo, return error
        :
          delete t-list-pack .
        end.
      end.
    end.
    output stream 1c-log to value ("1c-tech.log") append.
    gen-pack:
    for each t-list-pack
      by t-list-pack.pack-num
    on error undo, return error
    :
      assign
        v-esps-pack-num = t-list-pack.pack-num
      .
      delete t-list-pack .
      v-custom-pack-name = ?.
      run bge/espcknum.p ( input "put":U
                    ,input buf_ext-system.esys-id
                    ,input buf_ext-system.db-num
                    ,input buf_ext-system.delivery-method
                    ,input oxml-exch-dir
                    ,input oxml-heap-dir
                    ,input ""
                    ,input-output v-esps-pack-num
                    ,input-output v-custom-pack-name
                    ,output v-esps-pack-name
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
        return error.
      end.
      if buf_ext-system.esys-have-export = yes
     and buf_ext-system.esys-db-num-exp = v-cur-db-num then do :
        v-pack-file-name = substitute("&1&2&3", v-source-dir, chr(92), v-esps-pack-name) .
        run start-exp-pack in this-procedure  (
                      buffer buf_ext-system
                    ,input v-esps-pack-num
                    ,input (  v-pack-file-name  +  (if v-custom-pack-flag then '' else 'xml')  )
                    ,input v-cert-enabled
                    ,input v-cert-subj-name
                    ,input v-cert-issuer-name
                    ,input v-sign-fileext
                    ,input v-cert-repository
                    ,output v-err-gen-pack
                  ) no-error.
        if error-status:error then do:
          run write-log in p-log-handle (
                                        input 2
                                        , substitute("&1 Ошибка при формировании пакета.&2&3&2&4"
                                                    ,vss-workfile
                                                    ,chr(10)
                                                    ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                    , substitute( "&1", return-value ))
                        ) .
          leave gen-pack.
        end.
      end .
      if v-err-gen-pack <> 2 then do:
        run bge/sxg-pack.p (
                       input parparentproc
                      ,input this-procedure:handle
                      ,input p-log-handle
                      ,input "put":U
                      ,input true
                      ,input (v-esps-pack-name + (if v-custom-pack-flag then '' else "xml"))
                      ,input v-source-dir
                      ,input v-target-dir
                      ,input v-temp-dir
                      ,input v-esps-pack-num
                      ,input buf_ext-system.esys-id
                      ,input buf_ext-system.db-num
                      ,input v-cur-db-num
                      ,input buf_ext-system.delivery-method
                      ) no-error.
        if error-status:error then do:
          run write-log in p-log-handle (
                                          input 2
                                        , substitute("&1 &2"
                                                      ,vss-workfile
                                                      , return-value )
                          ).
          leave gen-pack.
        end.
      end.
      if v-err-gen-pack <> 0 then do:
        leave gen-pack.
      end.
    end.
    output stream 1c-log close.
    for each t-list-pack
    on error undo, return error
    :
      delete t-list-pack .
    end.
    run gbl/del-file.p ( input v-temp-dir ) no-error .
    if error-status:error then do:
      run write-log in p-log-handle ( input 2
                                    , substitute("&1 &2"
                                                  ,vss-workfile
                                                  , return-value )
                      ).
    end.
    case v-action:
      when "one-pack":U then do:
        run write-log in p-log-handle ( input 2
                                        ,input substitute("Завершена отправка одного пакета данных в ВС &1", buf_Ext-system.esys-name ) ) .
      end.
      when "one-esys-unconf":U
      or
      when "all-unconf"
      then do:
        run write-log in p-log-handle ( input 2
                                        ,input substitute("Завершена отправка всех неподтвержденных пакетов данных в ВС &1", buf_Ext-system.esys-name ) ) .
      end.
      when "all":U
      or
      when "one-esys"
      then do:
        run write-log in p-log-handle ( input 2
                                        ,input substitute("Завершена отправка новостей в ВС &1", buf_Ext-system.esys-name ) ) .
      end.
    end case.
    run bge/rem-xpck.p
      ( input buf_Ext-system.esys-id
       ,input buf_Ext-system.db-num
      ) no-error.
    if error-status:error then do:
      run write-log in p-log-handle (
                                     input 2
                                    ,input (substitute( "&1. ERROR!!! Ошибка при удалении файлов OXML по ВС &2&3&4&5&6"
                                    ,vss-workfile
                                    ,buf_ext-system.esys-id
                                    ,chr(10)
                                    ,error-status:get-message(error-status:num-messages)
                                    ,chr(10)
                                    ,return-value
                                              ))
                      ) .
    end.
    assign
    add-log-file-name = ?
    .
  end.
  run write-log in p-log-handle (
        input 1
      , input "Выгрузка данных по внешним системам завершена."
  ).
end.
procedure expand-dump-and-export :
define input parameter p-action             as character        no-undo.
define input parameter p-unique-key         as character        no-undo.
define input parameter p-esrd-dump-name     as character        no-undo.
define input parameter p-value-rec-handle   as handle           no-undo.
    define variable v-temp-table-handle     as handle       no-undo.
    define variable v-temp-table-name       as character    no-undo.
    define variable v-buf-temp-table-handle as handle       no-undo.
    define variable v-ok                    as logical      no-undo.
do
on error undo, return error
:
    create temp-table v-temp-table-handle.
    assign
        v-temp-table-name   = "temp_":U + p-esrd-dump-name
    .
    assign
        v-ok                = v-temp-table-handle :create-like( "ub.":U + p-esrd-dump-name )
    no-error.
    if v-ok <> yes
    then do:
        delete object v-temp-table-handle.
        undo, return error substitute( "&1. Ошибка при создании временной таблицы &2 (1)", vss-workfile, v-temp-table-name ) .
    end.
    assign
        v-ok = v-temp-table-handle :temp-table-prepare( v-temp-table-name )
    no-error.
    if v-ok <> yes
    then do:
        undo, return error substitute( "&1. Ошибка при создании временной таблицы &2 (2)", vss-workfile, v-temp-table-name ) .
    end.
    assign
        v-buf-temp-table-handle = v-temp-table-handle :default-buffer-handle
    .
    assign
        v-ok = v-buf-temp-table-handle :buffer-create
    no-error.
    if v-ok <> true
    then do:
        delete object v-buf-temp-table-handle.
        delete object v-temp-table-handle.
        undo, return error substitute( "&1. Ошибка при создании буфера временной таблицы.", vss-workfile, v-temp-table-name ).
    end.
    assign
        v-ok = v-buf-temp-table-handle :raw-transfer ( no, p-value-rec-handle )
    no-error.
    if v-ok <> true
    then do:
        delete object v-buf-temp-table-handle.
        delete object v-temp-table-handle.
        undo, return error substitute( "&1. RAW-TRANSFER не прошел для таблицы &2", vss-workfile, v-temp-table-name ).
    end.
    run exp-pack in this-procedure (
          input p-action
        , input p-unique-key
        , input v-buf-temp-table-handle
        , input p-esrd-dump-name
    ) no-error.
    if error-status :error
    then do:
        delete object v-buf-temp-table-handle.
        delete object v-temp-table-handle.
        return error substitute( "&1. Ошибка exp-pack для таблицы &2", vss-workfile, v-temp-table-name ).
    end.
    if valid-handle ( v-temp-table-handle )
    then do:
        delete object v-temp-table-handle.
    end.
    if valid-handle ( v-buf-temp-table-handle )
    then do:
        delete object v-buf-temp-table-handle.
    end.
end.
end procedure.
procedure start-exp-pack :
define parameter buffer buf_ext-system for ub.ext-system.
define input  parameter p-pack-num as integer   no-undo .
define input  parameter p-pack-file as character no-undo .
define input  parameter p-cert-enabled     as logical no-undo .
define input  parameter p-cert-subj-name   as character no-undo .
define input  parameter p-cert-issuer-name as character no-undo .
define input  parameter p-sign-fileext     as character no-undo .
define input  parameter p-cert-repository  as integer   no-undo .
define output parameter p-err-gen-pack as integer   no-undo . // 20/VIII-2018 - не используется, снаружи не проверяется
define variable v-buffer-handle        as handle       no-undo.
define variable v-parameter-list       as character    no-undo.
define variable v-esr-action           as character    no-undo.
define variable v-start-regular-pack   as logical      no-undo.
define variable v-end-regular-pack     as logical      no-undo.
define variable rec-cnt                as integer      no-undo.
define variable v-start                as logical      no-undo init yes.
define variable v-error-num            as integer      no-undo.
define variable v-found-route          as logical      no-undo .
define variable sw as handle no-undo.
define variable sender-id as character no-undo.
define variable v-longdata as longchar no-undo.
define variable v-type as character no-undo .
define variable v-packdata as memptr no-undo .
define buffer buf_esys-route         for ub.esys-route.
define buffer buf_esys-route-dump    for ub.esys-route-dump.
define buffer buf_temp_esys-route    for temp_esys-route.
define buffer buf_esys-pck-sent      for ub.esys-pck-sent.
define variable v-pkcs             as class ibs.th.gbl.pkcs no-undo .
define variable v-signdata         as memptr no-undo .
define variable v-sign-file        as character no-undo . // имя файла с электронной подписью
define variable v-position         as integer no-undo . // позиция точки в имени файла
do
on error undo, return error return-value
:
      if buf_Ext-system.delivery-method = integer('11':U)
      then do :
        run db-attr-value in this-procedure
           (input ibs.th.gbl.gbl-var:g#db-num
           ,input 'int-point':U
           ,output sender-id
           ,output v-type
           ) no-error .
        put stream 1c-log unformatted string(now) "  Начало формирования пакета " string(p-pack-num) "  " p-pack-file skip .
        create sax-writer sw.
        sw:formatted = true.
        sw:set-output-destination ("memptr", v-packdata).
        sw:encoding = "UTF-8".
        sw:start-document () .
        sw:start-element ("GC-ERPRN") .
        sw:insert-attribute ("xmlns", "http://www.rosneft.ru/GasComplex/Retail/11.0") .
        sw:insert-attribute ("xmlns:xs", "http://www.w3.org/2001/XMLSchema") .
        sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
        put stream 1c-log unformatted string(now) "  Заполнение шапки" skip .
          sw:start-element ("header") .
            sw:write-data-element ("num", string(p-pack-num)) .
            sw:write-data-element ("sender-id", sender-id) .
            sw:write-data-element ("reciever-id", "00000") .
            sw:write-data-element ("created-date", iso-date (now)) .
          sw:end-element ("header") .
        put stream 1c-log unformatted string(now) "  Шапка заполнена" skip .
      end.
      assign
          v-start-regular-pack = yes
          v-end-regular-pack = no
          v-found-route = no
      .
      _buf_esys-route:
      for each buf_esys-route no-lock
          where buf_esys-route.esys-id     = buf_ext-system.esys-id
            and buf_esys-route.db-num      = buf_Ext-system.db-num
            and buf_esys-route.esr-last-pack = p-pack-num
      on error undo, return error
      break by buf_esys-route.esr-oper by buf_esys-route.esr-tbl-ord
      :
        assign
            rec-cnt    = rec-cnt + (if v-start then 1 else 0)
            v-tesr-key = v-tesr-key + 1
            v-esr-action   = buf_esys-route.esr-action
            v-found-route = yes
          .
        create buf_temp_esys-route.
        assign
            buf_temp_esys-route.tesr-key         = v-tesr-key
            buf_temp_esys-route.esys-id          = buf_esys-route.esys-id
            buf_temp_esys-route.db-num           = buf_esys-route.db-num
            buf_temp_esys-route.esr-cr-db-num    = buf_esys-route.esr-cr-db-num
            buf_temp_esys-route.esr-last-pack    = buf_esys-route.esr-last-pack
            buf_temp_esys-route.esr-tbl-ord      = buf_esys-route.esr-tbl-ord
        .
        case buf_esys-route.esr-action
        :
          when 'command-bush':U
          or
          when 'command-pbush':U
          then do:
            if buf_Ext-system.delivery-method = integer('11':U)
            then do :
                if first-of(buf_esys-route.esr-oper)
                then put stream 1c-log unformatted string(now) "  Запись секции " buf_esys-route.esr-oper skip .
                if first-of(buf_esys-route.esr-oper)
                then sw:start-element (buf_esys-route.esr-oper) .
                if buf_esys-route.esr-oper = "sales-p-shifts"
                then do :
                  sw:start-element ("sales-p-shift") .
                    sw:write-data-element ("tbl-ord", string(buf_esys-route.esr-tbl-ord)) .
                end.
                for each buf_esys-route-dump where buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord:
                  v-longdata = "" .
                  fix-codepage(v-longdata) = "UTF-8" .
                  copy-lob from buf_esys-route-dump.esrd-blob-value-rec to v-longdata no-convert.
                  sw:write-fragment (v-longdata) .
                end.
                if buf_esys-route.esr-oper = "sales-p-shifts"
                then do :
                  sw:end-element ("sales-p-shift") .
                end.
                if last-of(buf_esys-route.esr-oper)
                then sw:end-element (buf_esys-route.esr-oper) .
                if last-of(buf_esys-route.esr-oper)
                then put stream 1c-log unformatted string(now) "  Запись секции " buf_esys-route.esr-oper " завершена" skip .
            end.
            else do :
                if v-start then do:
                run bge/cmdesgen.p (
                                      input parparentproc
                                      ,input p-log-handle
                                      ,input buf_ext-system.esys-id
                                      ,input buf_ext-system.db-num
                                      ,input buf_ext-system.esys-db-num-exp
                                      ,input buf_esys-route.esr-cr-db-num
                                      ,input buf_esys-route.esr-dump-ord
                                      ,input buf_esys-route.uniq-gate-rec
                                      ,input p-pack-file
                                      ,input 1
                                      ,input buf_esys-route.esr-last-pack
                                      ,output rec-cnt
                                      ) no-error.
                if error-status:error then do:
                  v-err-msg =  substitute( "Ошибка 1 разбора esys-route-dump. &1. &2. &3"
                                          , return-value
                                          , trim( error-status :get-message( 1 ) ))
                  .
                  run write-log in p-log-handle (
                        input 2
                      , input v-err-msg
                  ).
                  run send-msg-to-email in parparentproc
                      ( input substitute( "ТН (ver &2) БД &1. Ошибка OXML при экспорте пакета из ВС &2"
                                          , v-ver-num
                                          , v-cur-db-num
                                          , buf_ext-system.esys-id )
                      ,input v-err-msg
                      ,input "":U
                      ) no-error .
                  if error-status :error then do:
                      run write-log in p-log-handle (
                      input 2
                    , input substitute( "&1. &3&2&4", vss-workfile, chr(10), error-status:get-message(1), return-value )
                                                      ) .
                  end.
                  undo, return error .
                end.
                end.
                v-start = no.
                next _buf_esys-route.
            end.
          end.
          when 'update':U
          or when 'delete':U
          then do:
             if v-start-regular-pack then do:
                assign
                v-list-file-name = "":U
                v-parameter-list = substitute( "&1,&2,&3,&4,&5,&6,&7"
                                                , 6
                                                , "THformat":U
                                                , "Trade House OpenXML 1.0":U
                                                , "THversion":U
                                                , trim( replace( substring( vss-archive, 15, 4 ), "$":U, "":U ) )
                                                , "THrevision":U
                                                , trim( replace( substring( vss-revision, 12 ), "$":U, "":U ) )
                                            )
                v-parameter-list = substitute( "&1,&2,&3,&4,&5,&6,&7"
                                                , v-parameter-list
                                                , "THesysName":U
                                                , buf_ext-system.esys-name
                                                , "THcurrentDbNum":U
                                                , string( v-cur-db-num )
                                                , "THpack-num":U
                                                , string( p-pack-num )
                                            )
                .
                run xmllib-write-header in this-procedure (
                      input yes
                    , input p-pack-file
                    , input v-list-file-name
                    , input 1
                    , input no
                    , input "":U
                    , input v-parameter-list
                ).
                output STREAM stmXMLOut TO VALUE( p-pack-file + "tmp" ) CONVERT TARGET "1251" APPEND.
                v-start-regular-pack = no.
                v-end-regular-pack = yes.
              end.
              for each buf_esys-route-dump no-lock
                where buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
              on error undo, return error
              :
                  assign
                     v-buffer-handle = buffer buf_esys-route-dump :handle
                  .
                  run expand-dump-and-export in this-procedure (
                        input v-esr-action
                      , input buf_esys-route.esr-uniq-key-rec
                      , input buf_esys-route-dump.esrd-dump-name
                      , input v-buffer-handle :buffer-field( "esrd-value-rec":U )
                  ) no-error.
                  if error-status :error
                  then do:
                      run write-log in p-log-handle (
                            input 2
                          , input substitute( "Ошибка 1 разбора esys-route-dump. &1. &2. &3"
                                              , return-value
                                              , trim( error-status :get-message( 1 ) )
                                              , trim( error-status :get-message( 2 ) )
                                          )
                      ).
                      run write-log in p-log-handle (
                          input 0
                          , input substitute( "&1.", return-value )
                      ).
                      run write-log in p-log-handle (
                          input 0
                          , input substitute( "&1.", trim( error-status :get-message( 1 ) ) )
                      ).
                      run write-log in p-log-handle (
                          input 0
                          , input substitute( "&1.", trim( error-status :get-message( 2 ) ) )
                      ).
                      undo, return error .
                  end.
              end.
            end.
        end case.
      end.
      if buf_Ext-system.delivery-method = integer('11':U)
      then do :
          sw:end-element ("GC-ERPRN") .
          sw:end-document () .
        put stream 1c-log unformatted string(now) "  Окончание формирования пакета" skip .
        COPY-LOB FROM OBJECT v-packdata TO FILE p-pack-file NO-CONVERT NO-ERROR .
        if p-cert-enabled then do on error undo, throw :
          define variable v-err-msg as character no-undo .
          v-err-msg = "" .
          // p-cert-subj-name > "" и p-cert-issuer-name > "" были проверены при чтении параметров
            v-pkcs = new ibs.th.gbl.pkcs().
            v-signdata = v-pkcs:computeSign(v-packdata, p-cert-subj-name, p-cert-issuer-name, p-cert-repository) .
            // взять имя файла p-pack-file без расширения
            v-position = r-index(p-pack-file, ".") .
            v-sign-file = if v-position > 0 then substring(p-pack-file, 1, v-position - 1) else p-pack-file .
            v-sign-file = substitute("&1.&2", v-sign-file, p-sign-fileext) .
            COPY-LOB FROM OBJECT v-signdata TO FILE v-sign-file NO-CONVERT .
          // ошибки - в лог, и ...
          catch exAppErrors as class Progress.Lang.AppError :
            v-err-msg = exAppErrors:ReturnValue .
            if v-err-msg > "" then . else do :
              v-err-msg = exAppErrors:GetMessage(1) .
              if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\bge\oxmloutx.p" .
            end .
          end catch .
          catch exProErrors as class Progress.Lang.ProError :
            v-err-msg = exProErrors:GetMessage(1) .
            if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\bge\oxmloutx.p" .
          end catch .
          catch exAnyErrors as class Progress.Lang.Error:
            v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\bge\oxmloutx.p " + exAnyErrors:GetMessage(1).
          end catch .
          finally:
            set-size(v-signdata) = 0 .
            if valid-object(v-pkcs) then delete object v-pkcs .
            if v-err-msg > "" then do :
              run write-log in p-log-handle ( input 0, input v-err-msg ).
              undo, return error . // ... - и прекращаем выгрузку
            end .
          end finally.
        end . // end_of if_cert
        set-size(v-packdata) = 0 .
        put stream 1c-log unformatted string(now) "  Пакет " string(p-pack-num) "  " p-pack-file "   СФОРМИРОВАН" skip .
        file-info:file-name = p-pack-file .
        if file-info:file-size = 0
        then put stream 1c-log unformatted "!!!!!!!!! " string(now) "  Пакет " string(p-pack-num) "  " p-pack-file "   ПУСТОЙ" skip .
      end.
    if v-found-route = no
    and buf_ext-system.esys-type > integer('0':U)
    then do:
      if buf_Ext-system.delivery-method = integer('11':U)
      then put stream 1c-log unformatted string(now) "  1_cmdesgen.p  Пакет " string(p-pack-num) "  " p-pack-file skip .
      run bge/cmdesgen.p (
                            input parparentproc
                            ,input p-log-handle
                            ,input buf_ext-system.esys-id
                            ,input buf_ext-system.db-num
                            ,input buf_ext-system.esys-db-num-exp
                            ,input v-cur-db-num
                            ,input -1
                            ,input ''
                            ,input p-pack-file
                            ,input 1
                            ,input p-pack-num
                            ,output rec-cnt
                            ) no-error.
      if error-status:error then do:
        run write-log in p-log-handle (
              input 2
            , input substitute( "Ошибка 1 разбора esys-route-dump. &1. &2. &3"
                                , return-value
                                , trim( error-status :get-message( 1 ) )
                            )
        ).
        undo, return error .
      end.
      if buf_Ext-system.delivery-method = integer('11':U)
      then put stream 1c-log unformatted string(now) "  2_cmdesgen.p  Пакет " string(p-pack-num) "  " p-pack-file skip .
    end.
    if v-end-regular-pack
    and v-found-route = yes
    then do:
      output STREAM stmXMLOut close.
      run bge/os_copy.p (
            input "D"
          , input (p-pack-file + "xml")
          , input ""
          , output v-error-num
      ).
      run xmllib-write-footer in this-procedure (
            input yes
          , input p-pack-file
          , input v-list-file-name
          , input no
          , input "":U
      ).
       v-end-regular-pack = no.
    end.
    run cur-time in this-procedure (
              output v-today
            , output v-time
    ).
    for each buf_temp_esys-route
    on error undo, return error
    :
        find first buf_esys-route exclusive-lock
            where buf_esys-route.esys-id        = buf_temp_esys-route.esys-id
              and buf_esys-route.db-num         = buf_temp_esys-route.db-num
              and buf_esys-route.esr-cr-db-num  = buf_temp_esys-route.esr-cr-db-num
              and buf_esys-route.esr-last-pack  = buf_temp_esys-route.esr-last-pack
              and buf_esys-route.esr-tbl-ord    = buf_temp_esys-route.esr-tbl-ord
        .
        assign
            buf_esys-route.esr-status            = 1
            buf_esys-route.esr-sys-date          = v-today
            buf_esys-route.esr-sys-time-int      = v-time
            buf_esys-route.esr-sys-time          = string( v-time, "hh:mm:ss" )
        .
       delete buf_temp_esys-route.
    end.
    find first buf_esys-pck-sent exclusive-lock
      where buf_esys-pck-sent.esys-id   = buf_ext-system.esys-id
        and buf_esys-pck-sent.db-num   = buf_ext-system.db-num
        and buf_esys-pck-sent.esps-cr-db-num = v-cur-db-num
        and buf_esys-pck-sent.esps-pack-num = p-pack-num
    .
    assign
      buf_esys-pck-sent.esps-total-recs     = rec-cnt + (if buf_ext-system.delivery-method = integer('5':U)
                                                          then 0
                                                          else 1)
      buf_esys-pck-sent.esps-CreNum         = buf_esys-pck-sent.esps-CreNum + 1
      buf_esys-pck-sent.esps-SendTxtDate    = v-today
      buf_esys-pck-sent.esps-SendTxtTimeInt = v-time
      buf_esys-pck-sent.esps-SendTxtTime    = string( v-time, "HH:MM:SS" )
      .
end.
end procedure.
procedure exp-pack :
define input parameter p-action         as character        no-undo.
define input parameter p-unique-key     as character        no-undo.
define input parameter p-tbl-handle     as handle           no-undo.
define input parameter p-table-name     as character        no-undo.
      define variable v-num-fields      as integer          no-undo.
      define variable v-counter         as integer          no-undo.
      define variable v-field-handle    as handle           no-undo.
      define buffer buf_datatype-table          for ub.datatype-table.
      define buffer buf_datatype-table-field    for ub.datatype-table-field.
do
for buf_datatype-table
  , buf_datatype-table-field
on error  undo, return error substitute( "&1 (oxmloutx). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1 (oxmloutx). stop", vss-workfile )
on endkey undo, return error substitute( "&1 (oxmloutx). endkey", vss-workfile )
:
    find first buf_datatype-table no-lock
         where buf_datatype-table.dtt-name = p-table-name
    no-error.
    if available buf_datatype-table
    then do:
        run xmllib-tag-open in this-procedure ( input 1, input buf_datatype-table.dtt-xml-tag, input "":U ).
        run xmllib-tag-put in this-procedure ( input 2, input "TH__record-action"       , input p-action    , input 0 ).
        run xmllib-tag-put in this-procedure ( input 2, input "TH__record-unique-key"   , input p-unique-key, input 0 ).
        assign
            v-num-fields = p-tbl-handle :num-fields
        .
        do v-counter = 1 to v-num-fields
        on error undo, return error substitute( "&1 (nws-exp). &2", vss-workfile, error-status :get-message ( 1 ) )
        :
            assign
                v-field-handle = p-tbl-handle :buffer-field( v-counter )
            .
            find first buf_datatype-table-field no-lock
                 where buf_datatype-table-field.dtt-name = buf_datatype-table.dtt-name
                   and buf_datatype-table-field.dtf-name = v-field-handle :name
            no-error.
            if available buf_datatype-table-field
            then do:
                if v-field-handle :buffer-value = ?
                then do:
                    run xmllib-tag-put-null in this-procedure ( input 2, input buf_datatype-table-field.dtf-xml-tag ).
                end.
                else do:
                    run xmllib-tag-put in this-procedure ( input 2, input buf_datatype-table-field.dtf-xml-tag  , input v-field-handle :buffer-value, input 0 ).
                end.
            end.
        end.
        run xmllib-tag-close in this-procedure ( input 1, input buf_datatype-table.dtt-xml-tag ).
    end.
end.
end procedure.
procedure delete-old-pck :
define parameter buffer buf_esys-pck-sent for ub.esys-pck-sent.
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-esps-cr-db-num as integer no-undo .
define input parameter p-esps-pack-num as integer no-undo .
define input parameter p-esys-name as character no-undo .
define variable v-del-pck-num as integer   no-undo.
define variable v-del-cnt     as integer   no-undo.
define variable v-today as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.
define frame del-route
v-del-pck-num   label "Пакет N" format ">>>>>>>>>9" skip
v-del-cnt       label "Записей" format ">>>>>>>>>9"
with view-as dialog-box side-labels 1 columns three-d title "Удаление маршрутизации" .
do
on error undo, return error
:
  run write-log in p-log-handle (
        input 2
      , input substitute( "Удаление данных пакета &1 ВС '&2'&3:истек срок хранения"
                         ,p-esps-pack-num
                         ,p-esys-name
                         ,chr(10)
                          )
      ).
  view frame del-route .
  for each buf_esys-route
    where buf_esys-route.esys-id    = p-esys-id
      and buf_esys-route.db-num    = p-db-num
      and buf_esys-route.esr-cr-db-num = p-esps-cr-db-num
      and buf_esys-route.esr-last-pack = p-esps-pack-num
  on error  undo, return error substitute("&1. error buf_esys-route &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on endkey undo, return error substitute("&1. endkey buf_esys-route")
  on stop   undo, return error substitute("&1. stop buf_esys-route")
  :
    assign
      v-del-cnt = v-del-cnt + 1
    .
    do with frame del-route
    :
      assign
        v-del-pck-num :screen-value   = string( buf_esys-route.esr-last-pack, v-del-pck-num :format)
        v-del-cnt :screen-value       = string( v-del-cnt, v-del-cnt :format)
      .
    end.
    delete buf_esys-route.
  end.
  hide frame del-route .
  run cur-time in this-procedure ( output v-today, output v-time).
  transaction_block_pck-rcvd:
  do transaction
  on error  undo, return error substitute("&1. error transaction_block_esys-pck-rcvd &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on endkey undo, return error substitute("&1. endkey transaction_block_esys-pck-rcvd")
  on stop   undo, return error substitute("&1. stop transaction_block_esys-pck-rcvd")
  :
    find current buf_esys-pck-sent exclusive-lock.
    assign
    buf_esys-pck-sent.esps-rcvd        = yes
    buf_esys-pck-sent.esps-rcvdDate    = v-today
    buf_esys-pck-sent.esps-RcvdTimeInt = v-time
    buf_esys-pck-sent.esps-RcvdTime    = string( v-time, "HH:MM:SS" )
    .
  end.
  run write-log in p-log-handle (
        input 2
      , input substitute( ".....Удален" )
      ).
end.
end procedure.
procedure get-log-file-name :
define output parameter p-log-file-name as character no-undo .
  do
  on error undo, return error
  :
    p-log-file-name = add-log-file-name.
  end.
end procedure.
