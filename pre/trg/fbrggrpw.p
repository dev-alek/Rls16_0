block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.fbr-gds-grp OLD oldb.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись группы блюд".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3', ub.fbr-gds-grp.obj-type, ub.fbr-gds-grp.obj-code, ub.fbr-gds-grp.node-code)
    .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fbr-gds-grph_write-fbr-gds-grp-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-fbr-gds-grp-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-fbr-gds-grp-hist.source-ref no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-fbr-gds-grp-hist for ub.c-fbr-gds-grp-hist.
define buffer buf_c-fbr-gds-grp for ub.c-fbr-gds-grp.
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fbr-gds-grp.
    buffer-copy oldb to buf_c-fbr-gds-grp
    assign
    buf_c-fbr-gds-grp.obj-type           = (if p-new-record then ub.fbr-gds-grp.obj-type else oldb.obj-type)
    buf_c-fbr-gds-grp.obj-code           = (if p-new-record then ub.fbr-gds-grp.obj-code else oldb.obj-code)
    buf_c-fbr-gds-grp.node-code           = (if p-new-record then ub.fbr-gds-grp.node-code else oldb.node-code)
    buf_c-fbr-gds-grp.chip-num           = next-value (s-fbr-gds-grp-chip, ub)
    buf_c-fbr-gds-grp.corr-time          = v-time
    buf_c-fbr-gds-grp.corr-user-db-num   = g#db-num
    buf_c-fbr-gds-grp.corr-user-name     = (if g#news
                                            then (chr(4) +  'СПН':U)
                                            else (if g#esys
                                                  then (chr(4) +  'ВС':U)
                                                  else g#userid)
                                            )
    buf_c-fbr-gds-grp.corr-date          = v-date
    .
    create buf_c-fbr-gds-grp-hist.
    buffer-copy buf_c-fbr-gds-grp to buf_c-fbr-gds-grp-hist
    assign
    buf_c-fbr-gds-grp-hist.obj-type           = buf_c-fbr-gds-grp.obj-type
    buf_c-fbr-gds-grp-hist.obj-code           = buf_c-fbr-gds-grp.obj-code
    buf_c-fbr-gds-grp-hist.node-code           = buf_c-fbr-gds-grp.node-code
    buf_c-fbr-gds-grp-hist.action = p-action
    buf_c-fbr-gds-grp-hist.subject = 'fbr-gds-grp':U
    buf_c-fbr-gds-grp-hist.is-news = g#news
    buf_c-fbr-gds-grp-hist.source-type = p-source-type
    buf_c-fbr-gds-grp-hist.source-ref = p-source-ref
    .
  end.
end procedure.
procedure fbr-gds-grph_write-fbr-gds-grp-attr-proc  :
define parameter buffer buf_fbr-gds-grp-attr for ub.fbr-gds-grp-attr .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-fbr-gds-grp-hist for ub.c-fbr-gds-grp-hist.
define buffer buf_c-fbr-gds-grp-attr for ub.c-fbr-gds-grp-attr.
  do
  on error undo, return error
  :
    if not available buf_fbr-gds-grp-attr then do:
      undo, return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description  + chr(10) +
                    "Ошибка задания входных параметров:Не определен атрибут группы блюд" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fbr-gds-grp-attr.
    buffer-copy buf_fbr-gds-grp-attr to buf_c-fbr-gds-grp-attr
    assign
    buf_c-fbr-gds-grp-attr.obj-type           = buf_fbr-gds-grp-attr.obj-type
    buf_c-fbr-gds-grp-attr.obj-code           = buf_fbr-gds-grp-attr.obj-code
    buf_c-fbr-gds-grp-attr.node-code          = buf_fbr-gds-grp-attr.node-code
    buf_c-fbr-gds-grp-attr.attr-code          = buf_fbr-gds-grp-attr.attr-code
    buf_c-fbr-gds-grp-attr.chip-num           = next-value (s-fbr-gds-grp-chip, ub)
    buf_c-fbr-gds-grp-attr.corr-time          = v-time
    buf_c-fbr-gds-grp-attr.corr-user-db-num   = g#db-num
    buf_c-fbr-gds-grp-attr.corr-user-name     = (if g#news
                                            then (chr(4) +  'СПН':U)
                                            else (if g#esys
                                                  then (chr(4) +  'ВС':U)
                                                  else g#userid)
                                            )
    buf_c-fbr-gds-grp-attr.corr-date          = v-date
    .
    create buf_c-fbr-gds-grp-hist.
    buffer-copy buf_c-fbr-gds-grp-attr to buf_c-fbr-gds-grp-hist
    assign
    buf_c-fbr-gds-grp-hist.action =  p-action
    buf_c-fbr-gds-grp-hist.subject = 'fbr-gds-grp-attr':U
    buf_c-fbr-gds-grp-hist.is-news = g#news
    buf_c-fbr-gds-grp-hist.source-type = p-source-type
    buf_c-fbr-gds-grp-hist.source-ref = p-source-ref
    .
  end.
end procedure.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer other_fbr-gds-grp for ub.fbr-gds-grp.
DEFINE VARIABLE conf-par as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .
define variable v-l as logical no-undo .
define variable v-fbrggrp-root-code like ub.fbr-gds-grp.node-code no-undo .
on write of ub.fbr-gds-grp override do: end.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if g#db-num > 0
  and ub.fbr-gds-grp.obj-type = "":U
  and ub.fbr-gds-grp.obj-code = 0
  and not g#news
  then do:
    message
     vss-workfile vss-revision vss-description skip
    "Нельзя изменять запись глобальной ГРУППЫ БЛЮД (рубрикатора) в УБД" skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not (g#news and g#db-num = 0)
  and ub.fbr-gds-grp.obj-type <> '':U
  and ub.fbr-gds-grp.obj-code <> 0 then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  ub.fbr-gds-grp.obj-type
  ,input  ub.fbr-gds-grp.obj-code
  ,output v-obj-db-num
  )  .
      if v-obj-db-num <> g#db-num then do:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя изменять запись ГРУППЫ БЛЮД (рубрикатора) в чужой БД" skip
        view-as alert-box error .
        undo main-block, return error .
      end.
  end.
  if ub.fbr-gds-grp.node-code <> oldb.node-code then do:
      find buf_fbr-gds-grp
        where buf_fbr-gds-grp.node-code = ub.fbr-gds-grp.upper-code
        AND buf_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
        AND buf_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code
        no-error .
        if available buf_fbr-gds-grp then
      assign
        ub.fbr-gds-grp.lvl-num = buf_fbr-gds-grp.lvl-num + 1
        buf_fbr-gds-grp.is-term = no
      .
  end.
  else if ub.fbr-gds-grp.upper-code <> oldb.upper-code then do:
     run fbrglib-get-root-code in this-procedure ( output v-fbrggrp-root-code ) no-error.
    if error-status :error
    then do:
        undo main-block, return error "Не найден корневой узел." + chr(10) + return-value.
    end.
    if ub.fbr-gds-grp.upper-code = v-fbrggrp-root-code then do:
      find buf_fbr-gds-grp
        where buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
         no-error
        .
    end.
    else do:
      find buf_fbr-gds-grp
        where buf_fbr-gds-grp.node-code = ub.fbr-gds-grp.upper-code
        AND buf_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
        AND buf_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code no-error
        .
    end.
      if available buf_fbr-gds-grp then
      assign
        buf_fbr-gds-grp.is-term = no
        ub.fbr-gds-grp.lvl-num = if ub.fbr-gds-grp.upper-code = v-fbrggrp-root-code
                                 then 0
                                 else (buf_fbr-gds-grp.lvl-num + 1)
      .
    find first buf_fbr-gds-grp where
             buf_fbr-gds-grp.node-code = oldb.upper-code
          AND buf_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
          AND buf_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code
             no-error .
    if available buf_fbr-gds-grp
    and not can-find(first other_fbr-gds-grp no-lock where
                           other_fbr-gds-grp.upper-code = buf_fbr-gds-grp.node-code
                        AND other_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
                        AND other_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code
                      ) then do:
      assign
      buf_fbr-gds-grp.is-term = yes
      .
    end.
  end.
  else do:
    assign
      ub.fbr-gds-grp.is-term = yes
    .
  end.
  run fbr-grp-tree in this-procedure
    (input ub.fbr-gds-grp.node-code
     ,input ub.fbr-gds-grp.obj-type
     ,input ub.fbr-gds-grp.obj-code
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры fbr-grp-tree" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error.
  end.
    run str/callnews.p (
          input "fbr-gds-grp"
        , input (buffer ub.fbr-gds-grp:handle)
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка пересылки группы блюд по новостям."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo main-block, return error .
    end.
   if ub.fbr-gds-grp.obj-type <> "":U
   AND ub.fbr-gds-grp.obj-code <> 0 then do:
     find first buf_fbr-gds-grp where
               buf_fbr-gds-grp.node-code = ub.fbr-gds-grp.upper-code
            AND buf_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
            AND buf_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code no-error.
      if available buf_Fbr-gds-grp then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable send-ref as logical no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'send-ref'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
  send-ref = (IF error-status:error or conf-par <> "yes" then no else yes).
        if not g#news and send-ref then do:
          assign
          v-l = yes
          .
          buffer-compare ub.fbr-gds-grp using
          out-code
          upper-code
          node-name
          to oldb
          case-sensitive
          save result in v-l .
          if not v-l then do:
            run trg/nu_fgrp.p (
                          input  ub.fbr-gds-grp.obj-type
                          ,input  ub.fbr-gds-grp.obj-code
                          ,input  ub.fbr-gds-grp.node-code
                          ,input  ub.fbr-gds-grp.upper-code
                          ,input  ub.fbr-gds-grp.out-code
                          ,input  buf_Fbr-gds-grp.out-code
                          ,input  ub.Fbr-gds-grp.lvl-num
                          ,input  "U":U
                          ).
          end.
      end.
     end.
   end.
    if not g#news
    and not new(ub.fbr-gds-grp)
    then do:
      buffer-compare oldb to ub.fbr-gds-grp
      case-sensitive
      save result in v-l.
    end.
    if not v-l or new(ub.fbr-gds-grp) then
    run fbr-gds-grph_write-fbr-gds-grp-trigger in this-procedure (
                                                            new(ub.fbr-gds-grp)
                                                          ,"":U
                                                          ,"":U
                                                          , (if new(ub.fbr-gds-grp) then integer('1':U) else integer('2':U))
                                                          ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'fbr-gds-grp':U
        , input ( buffer ub.fbr-gds-grp:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
procedure fbr-grp-tree :
  define input  parameter nc       as integer   no-undo .
  define input parameter p-obj-type like ub.fbr-gds-grp.obj-type no-undo .
  define input parameter p-obj-code like ub.fbr-gds-grp.obj-code no-undo .
  def buffer buf_fbr-gds-grp for ub.fbr-gds-grp .
  do
  on error undo, return error return-value
  :
    for each buf_fbr-gds-grp
      where buf_fbr-gds-grp.upper-code = nc
      AND buf_fbr-gds-grp.obj-type = p-obj-type
      AND buf_fbr-gds-grp.obj-code = p-obj-code
    on error undo, return error
    :
      if nc = ub.fbr-gds-grp.node-code then do:
        assign
          ub.fbr-gds-grp.is-term = no
        .
      end.
      run fbr-grp-tree
        (input buf_fbr-gds-grp.node-code
         ,input buf_fbr-gds-grp.obj-type
         ,input buf_fbr-gds-grp.obj-code
        ).
    end.
  end.
end procedure.
procedure fbrglib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.upper-code = 0
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_fbr-gds-grp.node-code
        .
    end.
end.
end procedure.
