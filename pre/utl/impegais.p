block-level on error undo, throw.
using Ibs.Th.Gbl.ProgressBar.
define input  parameter parparentproc         as handle    no-undo .
define input  parameter p-alc-codes-filename  as character no-undo .
define input  parameter p-sup-codes-filename  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: impegais.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/impegais.p $":U .
define variable vss-description as character no-undo init "Импорт кодов ЕГАИС".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prg-bar_progress-bar  as class ProgressBar  no-undo .
  procedure prg-bar_new-progress-bar :
    define input  parameter p-min as int64   no-undo .
    define input  parameter p-max as int64   no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      run prg-bar_delete-progress-bar in this-procedure .
    end.
    v-prg-bar_progress-bar = new progressbar( p-min , p-max ).
  end.
  end procedure.
  procedure prg-bar_delete-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      delete object v-prg-bar_progress-bar.
      assign
        v-prg-bar_progress-bar = ?
      .
    end.
  end.
  end procedure.
  procedure prg-bar_show-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      v-prg-bar_progress-bar :show-bar() .
    end.
  end.
  end procedure.
  procedure prg-bar_increment-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      v-prg-bar_progress-bar :increment() .
    end.
  end.
  end procedure.
  procedure prg-bar_title-progress-bar :
    define input  parameter p-str as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      assign
        v-prg-bar_progress-bar :frame-title = p-str
      .
    end.
  end.
  end procedure.
  procedure prg-bar_stepto-progress-bar :
    define input  parameter p-val as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
        v-prg-bar_progress-bar :stepto( p-val ) .
    end.
  end.
  end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prg-bar_cb-handle     as handle             no-undo .
  procedure prg-bar_init-cb-handle :
    define input  parameter p-cb-handle as handle    no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle( p-cb-handle )
    then do:
      assign
        v-prg-bar_cb-handle = p-cb-handle
      .
    end.
    else do:
      assign
        v-prg-bar_cb-handle = ?
      .
    end.
  end.
  end procedure.
  procedure prg-bar_new :
    define input  parameter p-min as int64   no-undo .
    define input  parameter p-max as int64   no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_new-progress-bar in v-prg-bar_cb-handle ( input p-min , input p-max ).
    end.
  end.
  end procedure.
  procedure prg-bar_delete :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_delete-progress-bar in v-prg-bar_cb-handle .
    end.
  end.
  end procedure.
  procedure prg-bar_show :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_show-progress-bar in v-prg-bar_cb-handle .
    end.
  end.
  end procedure.
  procedure prg-bar_increment :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_increment-progress-bar in v-prg-bar_cb-handle.
    end.
  end.
  end procedure.
  procedure prg-bar_title :
    define input  parameter p-str as character no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_title-progress-bar in v-prg-bar_cb-handle ( input p-str ) .
    end.
  end.
  end procedure.
  procedure prg-bar_stepto :
    define input  parameter p-val as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_stepto-progress-bar in v-prg-bar_cb-handle ( input p-val ) .
    end.
  end.
  end procedure.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
define variable v-i           as integer   no-undo .
define variable v-is-error    as logical   no-undo .
define variable v-err-count   as integer   no-undo .
define variable v-frame-label as character no-undo .
define variable v-today       as date      no-undo .
define variable v-time        as integer   no-undo .
define variable v-time-start  as integer   no-undo .
define variable v-time-finish as integer   no-undo .
define variable v-alc-count-l as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-alc-count-t as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-alc-count-b as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-sup-count-l as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-sup-count-t as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-sup-count-b as integer format ">>>,>>>,>>>,>>9" no-undo .
function get-date return date (input p-str as character) forward.
define stream sinp.
define stream serr.
define temp-table tt-alc-container no-undo
 field kcont_id          as decimal
 field kcont_code        as character
 field kcont_name        as character
 field rcont_date_bg_nw  as date
 field rcont_date_end_nw as date
 field rcont_date_nw     as date
 field rcont_aktl        as decimal
index pi is primary unique
  kcont_id
.
define temp-table tt-alc-volume no-undo
  field volf_id         as decimal
  field volf_code       as character
  field volf_volume     as decimal
  field vlf_date_bg_nw  as date
  field vlf_date_end_nw as date
  field vlf_date_nw     as date
  field vlf_aktl        as decimal
index pi is primary unique
  volf_id
.
define temp-table tt-territory no-undo
  field terr_id           as decimal
  field terr_code         as character
  field terr_name         as character
  field terr_date_bg_nw   as date
  field terr_date_end_nw  as date
  field terr_date_nw      as date
  field terr_countr       as decimal
index pi is primary unique
  terr_id
.
define temp-table tt-alc-manufacturer no-undo
  field manf_id          as decimal
  field manf_name        as character
  field manf_address     as character
  field manf_egais       as character
  field manf_inn         as character
  field manf_date_bg_nw  as date
  field manf_date_end_nw as date
  field manf_aktl        as decimal
  field manf_date_nw     as date
index pi is primary unique
  manf_id
.
define temp-table tt-alc-products no-undo
  field alpr_id        as decimal
  field kalpr_id       as decimal
  field kcont_id       as decimal
  field volf_id        as decimal
  field manf_id        as decimal
  field alpr_egais     as character
  field alpr_code      as character
  field alpr_name      as character
  field alpr_scan_code as character
  field alpr_frtr      as decimal
  field alpr_status    as character
index pi is primary unique
  alpr_id
.
define temp-table tt-alc-supplier no-undo
  field supp_id               as decimal
  field supp_name             as character
  field supp_adr_ur           as character
  field supp_head_fio         as character
  field supp_inn              as character
  field supp_code_reas_state  as character
  field supp_code_egais       as character
  field supp_date_bg_nw       as date
  field supp_date_end_nw      as date
  field supp_date_nw          as date
  field supp_prz_aktl         as decimal
index pi is primary unique
  supp_id
.
define temp-table tt-countries no-undo
  field country-code as character
  field short-name   as character
  field full-name    as character
index pi is primary unique
  country-code
.
do on error undo, return error return-value
:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run clear-tt in this-procedure .
  assign
    v-time-start = time
  .
  run xmllib-set-prg-bar-handle in this-procedure ( input this-procedure ) .
  run load-xml-alcohol in this-procedure .
  run proc-xml-alcohol in this-procedure .
  run load-xml-supplier in this-procedure .
  run proc-xml-supplier in this-procedure .
  run fill-alcohol in this-procedure .
  run fill-suppliers in this-procedure .
  run clear-tt in this-procedure .
  run xmllib-clear-parse-data in this-procedure.
  assign
    v-time-finish = time - v-time-start
  .
  run calc-egais-gds in this-procedure ( output v-alc-count-b ) .
  run calc-egais-clients in this-procedure ( output v-sup-count-b ) .
  message
    "Импорт завершен!":U skip
    "Время импорта: ":U string( v-time-finish , "HH:MM:SS" ) skip(2)
    "Разобрано записей алкогольной продукции: ":U  v-alc-count-t skip
    "Загружено новых записей: ":U v-alc-count-l skip
    "Записей в БД: ":U v-alc-count-b skip(1)
    "Разобрано записей поставщиков: ":U  v-sup-count-t skip
    "Загружено новых записей: ":U v-sup-count-l skip
    "Записей в БД: ":U v-sup-count-b
  view-as alert-box information.
  if v-is-error = yes then do:
    message
      "Во время импорта были обнаружены ошибки." skip
      "Количество ошибок: " v-err-count skip
      "Отчет выведен в файл impegais.err"
    view-as alert-box warning.
  end.
end.
procedure put-error :
define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-is-error  = yes
    v-err-count = v-err-count + 1
  .
  output stream serr to "impegais.err" append.
  put stream serr unformatted string( today , "99/99/99") + " " + string( time , "hh:mm:ss") + " " + p-message + chr(10) .
  output stream serr close.
end.
end procedure.
procedure clear-tt :
do
on error undo, return error return-value
:
  empty temp-table tt-alc-container .
  empty temp-table tt-alc-volume .
  empty temp-table tt-territory .
  empty temp-table tt-alc-manufacturer .
  empty temp-table tt-alc-products .
  empty temp-table tt-alc-supplier .
end.
end procedure.
procedure find-client :
define input  parameter p-inn as character no-undo .
define output parameter p-obj-type  like ub.clients.obj-type no-undo .
define output parameter p-obj-code  like ub.clients.obj-code no-undo .
do
on error undo, return error return-value
:
  define buffer buf_firm    for ub.firm.
  define buffer buf_person  for ub.person.
  find first buf_firm no-lock
    where buf_firm.inn = p-inn
  no-error .
  if available buf_firm then do:
    assign
      p-obj-type = 'орг':U
      p-obj-code = buf_firm.firm-code
    .
    return.
  end.
  find first buf_person no-lock
    where buf_person.inn = p-inn
  no-error .
  if available buf_person then do:
    assign
      p-obj-type = 'чел':U
      p-obj-code = buf_person.psn-code
    .
    return.
  end.
end.
end procedure.
procedure load-xml-alcohol :
do
on error undo, return error return-value
:
  define variable v-full-filename as character  no-undo.
  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define buffer buf_rec          for temp_xmllib_rec.
do
for buf_rec-fld
  , buf_rec
on error undo, return error
:
    assign
        v-full-filename   = search( p-alc-codes-filename )
    .
    if v-full-filename <> ?
    then do:
        run xmllib-clear-parse-data in this-procedure.
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_ID":U           ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_NAME":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_ADDRESS":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_EGAIS":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_INN":U          ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_DATE_BG_NW":U   ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_DATE_END_NW":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_AKTL":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_DATE_NW":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_ID":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "KALPR_ID":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "KCONT_ID":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "VOLF_ID":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "MANF_ID":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_EGAIS":U     ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_CODE":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_NAME":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_SCAN_CODE":U ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_FRTR":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_STATUS":U    ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "KCONT_ID":U           ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "KCONT_CODE":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "KCONT_NAME":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "RCONT_DATE_BG_NW":U   ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "RCONT_DATE_END_NW":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "RCONT_DATE_NW":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "RCONT_AKTL":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VOLF_ID":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VOLF_CODE":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VOLF_VOLUME":U     ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VLF_DATE_BG_NW":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VLF_DATE_END_NW":U ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VLF_DATE_NW":U     ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VLF_AKTL":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_ID":U          ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_CODE":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_NAME":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_DATE_BG_NW":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_DATE_END_NW":U ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_DATE_NW":U     ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_COUNTR":U      ) .
        run xmllib-parse-file in this-procedure (
            input v-full-filename
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip substitute( "Ошибка разбора файла &1", v-full-filename )
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
end.
run waitfram-hide in this-procedure .
end.
end procedure.
procedure load-xml-supplier :
do
on error undo, return error return-value
:
  define variable v-full-filename as character  no-undo.
  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define buffer buf_rec          for temp_xmllib_rec.
do
for buf_rec-fld
  , buf_rec
on error undo, return error
:
    assign
        v-full-filename   = search( p-sup-codes-filename )
    .
    if v-full-filename <> ?
    then do:
        run xmllib-clear-parse-data in this-procedure.
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_ID":U               ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_NAME":U             ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_ADR_UR":U           ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_HEAD_FIO":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_INN":U              ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_CODE_REAS_STATE":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_CODE_EGAIS":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_DATE_BG_NW":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_DATE_END_NW":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_DATE_NW":U          ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_PRZ_AKTL":U         ) .
        run xmllib-parse-file in this-procedure (
            input v-full-filename
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip substitute( "Ошибка разбора файла &1", v-full-filename )
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
end.
run waitfram-hide in this-procedure .
end.
end procedure.
procedure proc-xml-alcohol :
    define buffer buf_rec          for temp_xmllib_rec.
    define buffer buf_rec-fld      for temp_xmllib_rec-fld.
do
on error undo, return error return-value
:
  run waitfram-show in this-procedure ( "Разбор товаров...":U ) .
  for each buf_rec
  on error undo, return error
  :
    case buf_rec.recName :
      when "MD_ALC_CONTAINER":U then do:
        run parse-alc-containers in this-procedure ( input buf_rec.rec-key ) .
      end.
      when "MD_ALC_VOLUME":U then do:
        run parse-alc-volumes in this-procedure ( input buf_rec.rec-key ) .
      end.
      when "MD_TERRITORY":U then do:
        run parse-territorys in this-procedure ( input buf_rec.rec-key ) .
      end.
      when "MD_ALC_MANUFACTURER":U then do:
        run parse-alc-manufacturers in this-procedure ( input buf_rec.rec-key ) .
      end.
      when "MD_ALC_PRODUCT":U then do:
        run parse-alc-products in this-procedure ( input buf_rec.rec-key) .
      end.
    end case.
  end.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure proc-xml-supplier :
    define buffer buf_rec          for temp_xmllib_rec.
    define buffer buf_rec-fld      for temp_xmllib_rec-fld.
do
on error undo, return error return-value
:
  run waitfram-show in this-procedure ( "Разбор поставщиков...":U ) .
  for each buf_rec
  on error undo, return error
  :
    case buf_rec.recName :
      when "MD_ALC_SUPPLIER":U then do:
        run parse-alc-suppliers in this-procedure ( input buf_rec.rec-key ) .
      end.
    end case.
  end.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure parse-alc-containers :
  define input  parameter p-rec-key as integer   no-undo .
  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define variable v-kcont_id          as decimal   no-undo .
  define variable v-kcont_code        as character no-undo .
  define variable v-kcont_name        as character no-undo .
  define variable v-rcont_date_bg_nw  as date      no-undo .
  define variable v-rcont_date_end_nw as date      no-undo .
  define variable v-rcont_date_nw     as date      no-undo .
  define variable v-rcont_aktl        as decimal   no-undo .
do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "KCONT_ID":U then do:
        assign
          v-kcont_id = decimal(buf_rec-fld.fldValue)
        no-error .
      end.
      when "KCONT_CODE":U then do:
        assign
          v-kcont_code = buf_rec-fld.fldValue
        .
      end.
      when "KCONT_NAME":U then do:
        assign
          v-kcont_name = buf_rec-fld.fldValue
        .
      end.
      when "RCONT_DATE_BG_NW":U then do:
        assign
          v-rcont_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "RCONT_DATE_END_NW":U then do:
        assign
          v-rcont_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "RCONT_DATE_NW":U then do:
        assign
          v-rcont_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "RCONT_AKTL":U then do:
        assign
          v-rcont_aktl = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
    end case.
  end.
  if v-kcont_id = ? then return.
  find first tt-alc-container
    where tt-alc-container.kcont_id = v-kcont_id
  no-error .
  if not available tt-alc-container then do:
    create tt-alc-container.
    assign
      tt-alc-container.kcont_id           = v-kcont_id
      tt-alc-container.kcont_code         = v-kcont_code
      tt-alc-container.kcont_name         = v-kcont_name
      tt-alc-container.rcont_date_bg_nw   = v-rcont_date_bg_nw
      tt-alc-container.rcont_date_end_nw  = v-rcont_date_end_nw
      tt-alc-container.rcont_date_nw      = v-rcont_date_nw
      tt-alc-container.rcont_aktl         = v-rcont_aktl
    .
  end.
end.
end procedure.
procedure parse-alc-volumes :
  define input  parameter p-rec-key as integer   no-undo .
  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define variable v-volf_id         as decimal    no-undo .
  define variable v-volf_code       as character  no-undo .
  define variable v-volf_volume     as decimal    no-undo .
  define variable v-vlf_date_bg_nw  as date       no-undo .
  define variable v-vlf_date_end_nw as date       no-undo .
  define variable v-vlf_date_nw     as date       no-undo .
  define variable v-vlf_aktl        as decimal    no-undo .
do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "VOLF_ID":U        then do:
        assign
          v-volf_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VOLF_CODE":U      then do:
        assign
          v-volf_code = buf_rec-fld.fldValue
        .
      end.
      when "VOLF_VOLUME":U    then do:
        assign
          v-volf_volume = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VLF_DATE_BG_NW":U then do:
        assign
          v-vlf_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VLF_DATE_END_NW":U then do:
        assign
          v-vlf_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VLF_DATE_NW":U    then do:
        assign
          v-vlf_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VLF_AKTL":U       then do:
        assign
          v-vlf_aktl = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
    end case.
  end.
  if v-volf_id = ? then return.
  find first tt-alc-volume
    where tt-alc-volume.volf_id = v-volf_id
  no-error .
  if not available tt-alc-volume then do:
    create tt-alc-volume.
    assign
      tt-alc-volume.volf_id         = v-volf_id
      tt-alc-volume.volf_code       = v-volf_code
      tt-alc-volume.volf_volume     = v-volf_volume
      tt-alc-volume.vlf_date_bg_nw  = v-vlf_date_bg_nw
      tt-alc-volume.vlf_date_end_nw = v-vlf_date_end_nw
      tt-alc-volume.vlf_date_nw     = v-vlf_date_nw
      tt-alc-volume.vlf_aktl        = v-vlf_aktl
    .
  end.
end.
end procedure.
procedure parse-territorys :
  define input  parameter p-rec-key as integer   no-undo .
  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define variable v-terr_id           as decimal    no-undo .
  define variable v-terr_code         as character  no-undo .
  define variable v-terr_name         as character  no-undo .
  define variable v-terr_date_bg_nw   as date       no-undo .
  define variable v-terr_date_end_nw  as date       no-undo .
  define variable v-terr_date_nw      as date       no-undo .
  define variable v-terr_countr       as decimal    no-undo .
do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "TERR_ID":U         then do:
        assign
          v-terr_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "TERR_CODE":U       then do:
        assign
          v-terr_code = buf_rec-fld.fldValue
        .
      end.
      when "TERR_NAME":U       then do:
        assign
          v-terr_name = buf_rec-fld.fldValue
        .
      end.
      when "TERR_DATE_BG_NW":U then do:
        assign
          v-terr_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "TERR_DATE_END_NW":U then do:
        assign
          v-terr_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "TERR_DATE_NW":U    then do:
        assign
          v-terr_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "TERR_COUNTR":U     then do:
        assign
          v-terr_countr = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
    end case.
  end.
  if v-terr_id = ? then return .
  find first tt-territory
    where tt-territory.terr_id = v-terr_id
  no-error .
  if not available tt-territory then do:
    create tt-territory.
    assign
      tt-territory.terr_id          = v-terr_id
      tt-territory.terr_code        = v-terr_code
      tt-territory.terr_name        = v-terr_name
      tt-territory.terr_date_bg_nw  = v-terr_date_bg_nw
      tt-territory.terr_date_end_nw = v-terr_date_end_nw
      tt-territory.terr_date_nw     = v-terr_date_nw
      tt-territory.terr_countr      = v-terr_countr
    .
  end.
end.
end procedure.
procedure parse-alc-manufacturers :
  define input  parameter p-rec-key as integer   no-undo .
  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define variable v-manf_id          as decimal    no-undo .
  define variable v-manf_name        as character  no-undo .
  define variable v-manf_address     as character  no-undo .
  define variable v-manf_egais       as character  no-undo .
  define variable v-manf_inn         as character  no-undo .
  define variable v-manf_date_bg_nw  as date       no-undo .
  define variable v-manf_date_end_nw as date       no-undo .
  define variable v-manf_aktl        as decimal    no-undo .
  define variable v-manf_date_nw     as date       no-undo .
do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "MANF_ID":U         then do:
        assign
          v-manf_id = decimal(buf_rec-fld.fldValue)
        no-error .
      end.
      when "MANF_NAME":U       then do:
        assign
          v-manf_name = buf_rec-fld.fldValue
        .
      end.
      when "MANF_ADDRESS":U    then do:
        assign
          v-manf_address = buf_rec-fld.fldValue
        .
      end.
      when "MANF_EGAIS":U      then do:
        assign
          v-manf_egais = buf_rec-fld.fldValue
        .
      end.
      when "MANF_INN":U        then do:
        assign
          v-manf_inn =  buf_rec-fld.fldValue
        no-error .
      end.
      when "MANF_DATE_BG_NW":U then do:
        assign
          v-manf_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "MANF_DATE_END_NW":U then do:
        assign
          v-manf_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "MANF_AKTL":U       then do:
        assign
          v-manf_aktl = decimal(buf_rec-fld.fldValue)
        no-error .
      end.
      when "MANF_DATE_NW":U    then do:
        assign
          v-manf_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
    end case.
  end.
  if v-manf_id = ? then return .
  find first tt-alc-manufacturer
    where tt-alc-manufacturer.manf_id = v-manf_id
  no-error .
  if not available tt-alc-manufacturer then do:
    create tt-alc-manufacturer.
    assign
      tt-alc-manufacturer.manf_id          = v-manf_id
      tt-alc-manufacturer.manf_name        = v-manf_name
      tt-alc-manufacturer.manf_address     = v-manf_address
      tt-alc-manufacturer.manf_egais       = v-manf_egais
      tt-alc-manufacturer.manf_inn         = v-manf_inn
      tt-alc-manufacturer.manf_date_bg_nw  = v-manf_date_bg_nw
      tt-alc-manufacturer.manf_date_end_nw = v-manf_date_end_nw
      tt-alc-manufacturer.manf_aktl        = v-manf_aktl
      tt-alc-manufacturer.manf_date_nw     = v-manf_date_nw
    .
  end.
end.
end procedure.
procedure parse-alc-products :
  define input  parameter p-rec-key as integer   no-undo .
  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define variable v-alpr_id        as decimal   no-undo .
  define variable v-kalpr_id       as decimal   no-undo .
  define variable v-kcont_id       as decimal   no-undo .
  define variable v-volf_id        as decimal   no-undo .
  define variable v-manf_id        as decimal   no-undo .
  define variable v-alpr_egais     as character no-undo .
  define variable v-alpr_code      as character no-undo .
  define variable v-alpr_name      as character no-undo .
  define variable v-alpr_scan_code as character no-undo .
  define variable v-alpr_frtr      as decimal   no-undo .
  define variable v-alpr_status    as character no-undo .
do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "ALPR_ID":U       then do:
        assign
          v-alpr_id =  decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "KALPR_ID":U      then do:
        assign
          v-kalpr_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "KCONT_ID":U      then do:
        assign
          v-kcont_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VOLF_ID":U       then do:
        assign
          v-volf_id =  decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "MANF_ID":U       then do:
        assign
          v-manf_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "ALPR_EGAIS":U    then do:
        assign
          v-alpr_egais =  buf_rec-fld.fldValue
        .
      end.
      when "ALPR_CODE":U     then do:
        assign
          v-alpr_code =  buf_rec-fld.fldValue
        .
      end.
      when "ALPR_NAME":U     then do:
        assign
          v-alpr_name =  buf_rec-fld.fldValue
        .
      end.
      when "ALPR_SCAN_CODE":U then do:
        assign
          v-alpr_scan_code =  buf_rec-fld.fldValue
        .
      end.
      when "ALPR_FRTR":U     then do:
        assign
          v-alpr_frtr = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "ALPR_STATUS":U   then do:
        assign
          v-alpr_status = buf_rec-fld.fldValue
        no-error .
      end.
    end case.
  end.
  if v-alpr_id = ? then return .
  find first tt-alc-products
    where tt-alc-products.alpr_id = v-alpr_id
  no-error .
  if not available tt-alc-products then do:
    create tt-alc-products .
    assign
      tt-alc-products.alpr_id         = v-alpr_id
      tt-alc-products.kalpr_id        = v-kalpr_id
      tt-alc-products.kcont_id        = v-kcont_id
      tt-alc-products.volf_id         = v-volf_id
      tt-alc-products.manf_id         = v-manf_id
      tt-alc-products.alpr_egais      = v-alpr_egais
      tt-alc-products.alpr_code       = v-alpr_code
      tt-alc-products.alpr_name       = v-alpr_name
      tt-alc-products.alpr_scan_code  = v-alpr_scan_code
      tt-alc-products.alpr_frtr       = v-alpr_frtr
      tt-alc-products.alpr_status     = v-alpr_status
    .
  end.
end.
end procedure.
procedure parse-alc-suppliers :
  define input  parameter p-rec-key as integer   no-undo .
  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define variable v-supp_id               as decimal    no-undo .
  define variable v-supp_name             as character  no-undo .
  define variable v-supp_adr_ur           as character  no-undo .
  define variable v-supp_head_fio         as character  no-undo .
  define variable v-supp_inn              as character  no-undo .
  define variable v-supp_code_reas_state  as character  no-undo .
  define variable v-supp_code_egais       as character  no-undo .
  define variable v-supp_date_bg_nw       as date       no-undo .
  define variable v-supp_date_end_nw      as date       no-undo .
  define variable v-supp_date_nw          as date       no-undo .
  define variable v-supp_prz_aktl         as decimal    no-undo .
do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "SUPP_ID":U              then do:
        assign
          v-supp_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "SUPP_NAME":U            then do:
        assign
          v-supp_name = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_ADR_UR":U          then do:
        assign
          v-supp_adr_ur = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_HEAD_FIO":U        then do:
        assign
          v-supp_head_fio = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_INN":U             then do:
        assign
          v-supp_inn = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_CODE_REAS_STATE":U then do:
        assign
          v-supp_code_reas_state = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_CODE_EGAIS":U      then do:
        assign
          v-supp_code_egais = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_DATE_BG_NW":U      then do:
        assign
          v-supp_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "SUPP_DATE_END_NW":U     then do:
        assign
          v-supp_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "SUPP_DATE_NW":U         then do:
        assign
          v-supp_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "SUPP_PRZ_AKTL":U        then do:
        assign
          v-supp_prz_aktl = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
    end case.
  end.
  if v-supp_id = ? then return .
  find first tt-alc-supplier
    where tt-alc-supplier.supp_id = v-supp_id
  no-error .
  if not available tt-alc-supplier then do:
    create tt-alc-supplier.
    assign
      tt-alc-supplier.supp_id               = v-supp_id
      tt-alc-supplier.supp_name             = v-supp_name
      tt-alc-supplier.supp_adr_ur           = v-supp_adr_ur
      tt-alc-supplier.supp_head_fio         = v-supp_head_fio
      tt-alc-supplier.supp_inn              = v-supp_inn
      tt-alc-supplier.supp_code_reas_state  = v-supp_code_reas_state
      tt-alc-supplier.supp_code_egais       = v-supp_code_egais
      tt-alc-supplier.supp_date_bg_nw       = v-supp_date_bg_nw
      tt-alc-supplier.supp_date_end_nw      = v-supp_date_end_nw
      tt-alc-supplier.supp_date_nw          = v-supp_date_nw
      tt-alc-supplier.supp_prz_aktl         = v-supp_prz_aktl
    .
  end.
end.
end procedure.
procedure fill-alcohol :
  define buffer buf_egais-gds for ub.egais-gds.
do
on error undo, return error return-value
:
assign v-account = ( if integer( 100 ) = 0 then 100 else integer( 100 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
  assign
    v-i = 0
  .
  _alc-product:
  for each tt-alc-products :
    assign
      v-i = v-i + 1
      v-alc-count-t = v-alc-count-t + 1
    .
IF ( v-i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH('Запись в БД алкогольных товаров...')) / 2
    RecordsString = fill(' ',v-kol-spice) + string('Запись в БД алкогольных товаров...')
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-i @ RecordsDone
              RecordsString   @ RecordsString
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    find first tt-alc-container
      where tt-alc-container.kcont_id = tt-alc-products.kcont_id
    no-error .
    if not available tt-alc-container then do:
      run put-error in this-procedure ( substitute( "В записи товара &1 неизвестный код тары &2 . Товар не импортирован."
                                                  , tt-alc-products.alpr_id
                                                  , tt-alc-products.kcont_id
                                                  )
                                      ) .
      next _alc-product.
    end.
    find first tt-alc-volume
      where tt-alc-volume.volf_id = tt-alc-products.volf_id
    no-error .
    if not available tt-alc-volume then do :
      run put-error in this-procedure ( substitute( "В записи товара &1 неизвестный код объема &2 . Товар не импортирован."
                                                  , tt-alc-products.alpr_id
                                                  , tt-alc-products.volf_id
                                                  )
                                      ) .
      next _alc-product.
    end.
    find first tt-alc-manufacturer
      where tt-alc-manufacturer.manf_id = tt-alc-products.manf_id
    no-error .
    if not available tt-alc-manufacturer then do:
      run put-error in this-procedure ( substitute( "В записи товара &1 неизвестный код производителя &2 . Товар не импортирован."
                                                  , tt-alc-products.alpr_id
                                                  , tt-alc-products.manf_id
                                                  )
                                      ) .
      next _alc-product.
    end.
    find first buf_egais-gds no-lock
      where buf_egais-gds.alpr-id = tt-alc-products.alpr_id
    no-error .
    if not available buf_egais-gds
    then do:
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      create buf_egais-gds.
      assign
        buf_egais-gds.alpr-id         = tt-alc-products.alpr_id
        buf_egais-gds.alpr-code-egais = tt-alc-products.alpr_egais
        buf_egais-gds.alpr-code       = tt-alc-products.alpr_code
        buf_egais-gds.alpr-frtr       = tt-alc-products.alpr_frtr
        buf_egais-gds.alpr-name       = tt-alc-products.alpr_name
        buf_egais-gds.alpr-scan-code  = tt-alc-products.alpr_scan_code
        buf_egais-gds.alpr-status     = tt-alc-products.alpr_status
        buf_egais-gds.kalpr-id        = tt-alc-products.kalpr_id
        buf_egais-gds.kcont-id        = tt-alc-products.kcont_id
        buf_egais-gds.manf-id         = tt-alc-products.manf_id
        buf_egais-gds.producer-name   = tt-alc-manufacturer.manf_name
        buf_egais-gds.tare            = tt-alc-container.kcont_name
        buf_egais-gds.volf-id         = tt-alc-products.volf_id
        buf_egais-gds.volume          = tt-alc-volume.volf_volume
        buf_egais-gds.imp-date        = v-today
        buf_egais-gds.imp-time        = v-time
        buf_egais-gds.imp-user-id     = v-cntxt-userid
      .
      release buf_egais-gds no-error .
      if error-status :error
      then do:
        run put-error in this-procedure ( substitute( "Ошибка записи в БД товара с кодом : &1 - &2. Товар не импортирован. &3&4&3&5&3&6"
                                                    , tt-alc-products.alpr_id
                                                    , tt-alc-products.alpr_name
                                                    , chr(10)
                                                    , error-status :get-message(1)
                                                    , error-status :get-message(2)
                                                    , error-status :get-message(3)
                                                    )
                                        ) .
        next _alc-product.
      end.
      else do:
         assign
           v-alc-count-l = v-alc-count-l + 1
         .
      end.
    end.
    else do:
      run put-error in this-procedure ( substitute( "Уже есть запись товара с кодом : &1 - &2. Товар не импортирован. "
                                                  , tt-alc-products.alpr_id
                                                  , tt-alc-products.alpr_name
                                                  )
                                      ) .
    end.
  end.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
end.
end procedure.
procedure fill-suppliers :
  define buffer buf_egais-clients for ub.egais-clients.
  define variable v-obj-type like ub.clients.obj-type no-undo .
  define variable v-obj-code like ub.clients.obj-code no-undo .
do
on error undo, return error return-value
:
assign v-account = ( if integer( 100 ) = 0 then 100 else integer( 100 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
  assign
    v-i = 0
  .
  _alc-supplier :
  for each tt-alc-supplier :
    assign
      v-obj-type  = "":U
      v-obj-code  = 0
      v-i           = v-i + 1
      v-sup-count-t = v-sup-count-t + 1
    .
IF ( v-i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH('Запись в БД поставщиков...')) / 2
    RecordsString = fill(' ',v-kol-spice) + string('Запись в БД поставщиков...')
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-i @ RecordsDone
              RecordsString   @ RecordsString
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    find first buf_egais-clients no-lock
      where buf_egais-clients.supp-id = tt-alc-supplier.supp_id
    no-error .
    if not available buf_egais-clients
    then do:
      if tt-alc-supplier.supp_inn <> "":U then do :
        run find-client in this-procedure ( input tt-alc-supplier.supp_inn
                                          , output v-obj-type
                                          , output v-obj-code
                                          ) .
      end.
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ) .
      create buf_egais-clients.
      assign
        buf_egais-clients.supp-id               = tt-alc-supplier.supp_id
        buf_egais-clients.obj-code              = v-obj-code
        buf_egais-clients.obj-type              = v-obj-type
        buf_egais-clients.supp-adr-ur           = tt-alc-supplier.supp_adr_ur
        buf_egais-clients.supp-code-egais       = tt-alc-supplier.supp_code_egais
        buf_egais-clients.supp-code-reas-state  = tt-alc-supplier.supp_code_reas_state
        buf_egais-clients.supp-head-fio         = tt-alc-supplier.supp_head_fio
        buf_egais-clients.supp-inn              = tt-alc-supplier.supp_inn
        buf_egais-clients.supp-name             = tt-alc-supplier.supp_name
        buf_egais-clients.imp-date              = v-today
        buf_egais-clients.imp-time              = v-time
        buf_egais-clients.imp-user-id           = v-cntxt-userid
      .
      release buf_egais-clients no-error .
      if error-status :error
      then do:
        run put-error in this-procedure ( substitute( "Ошибка при записи в БД поставщика с кодом : &1  - &2. Поставщик не импортирован. &3&4&3&5&3&6"
                                                    , tt-alc-supplier.supp_id
                                                    , tt-alc-supplier.supp_name
                                                    , chr(10)
                                                    , error-status :get-message(1)
                                                    , error-status :get-message(2)
                                                    , error-status :get-message(3)
                                                    )
                                        ) .
        next _alc-supplier.
      end.
      else do:
         assign
           v-sup-count-l = v-sup-count-l + 1
         .
      end.
    end.
    else do:
      run put-error in this-procedure ( substitute( "Уже есть запись поставщика с кодом : &1  - &2. Поставщик не импортирован. "
                                                  , tt-alc-supplier.supp_id
                                                  , tt-alc-supplier.supp_name
                                                  )
                                      ) .
    end.
  end.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
end.
end procedure.
procedure calc-egais-gds :
  define output parameter p-tot-records as integer   no-undo .
  define buffer buf_egais-gds for ub.egais-gds.
  define variable v-i as integer   no-undo .
do
on error undo, return error return-value
:
  for each buf_egais-gds no-lock
  :
    assign
      v-i = v-i + 1
    .
  end.
  assign
    p-tot-records = v-i
  .
end.
end procedure.
procedure calc-egais-clients :
  define output parameter p-tot-records as integer   no-undo .
  define buffer buf_egais-clients for ub.egais-clients.
  define variable v-i as integer   no-undo .
do
on error undo, return error return-value
:
  for each buf_egais-clients no-lock
  :
    assign
      v-i = v-i + 1
    .
  end.
  assign
    p-tot-records = v-i
  .
end.
end procedure.
function get-date return date (input p-str as character) .
  define variable v-year  as integer   no-undo .
  define variable v-month as integer   no-undo .
  define variable v-day   as integer   no-undo .
  define variable v-date  as date      no-undo .
  define variable v-count as integer   no-undo .
  assign
    v-count = num-entries( p-str , '-' )
  .
  if v-count <> 3 then return ?.
  assign
    v-year  = integer( entry( 1 , p-str , '-' ) )
    v-month = integer( entry( 2 , p-str , '-' ) )
    v-day   = integer( entry( 3 , p-str , '-' ) )
    v-date  = date( v-month , v-day , v-year )
  no-error
  .
  return v-date.
end function.
