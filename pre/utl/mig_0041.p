block-level on error undo, throw.
using Ibs.Th.Gbl.ProgressBar.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0041.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0041.p $":U .
define variable vss-description as character no-undo init "Модификация таблиц раздела Клиенты".
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
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .
define input parameter p-db-num         as integer   no-undo .
define input parameter p-cli-code       as integer   no-undo .
define input parameter log-file-name   as character  no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-progress-bar as class ProgressBar no-undo .
run prg-bar_init-cb-handle in this-procedure ( this-procedure ) .
define variable v-tot-rec as int64 no-undo .
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("ДК") ).
define shared temp-table temp-clients no-undo like ub.clients
field base-code as integer
field new-issue-code as integer
field deleted-sysconf as logical
.
define shared temp-table temp-sysconf no-undo like ub.sysconf.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_c-dis-obj for ub.c-dis-obj.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_c-dis-host for ub.c-dis-host.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
on write of ub.dis-host override do: end.
on delete of ub.dis-card override do: end.
on delete of ub.dis-host override do: end.
on delete of ub.dis-obj override do: end.
on delete of ub.dis-card-property override do: end.
on delete of ub.c-dis-host override do: end.
on delete of ub.c-dis-obj override do: end.
on delete of ub.c-dis-card-property override do: end.
on delete of ub.dis-card-type override do: end.
on delete of ub.dis-card-type-attr override do: end.
on delete of ub.dis-dct-rule override do: end.
on delete of ub.c-dis-dct-rule override do: end.
on delete of ub.dis-card-mask override do: end.
on delete of ub.c-dis-card-type override do: end.
on delete of ub.c-dis-card-type-attr override do: end.
on delete of ub.c-dis-card-mask override do: end.
on write of ub.trn-doc override do: end.
on delete of ub.hist-nws-option override do: end.
on delete of ub.c-hist-nws-option override do: end.
on delete of ub.rp-by-call override do: end.
on delete of ub.c-rp-by-call override do: end.
on delete of ub.rule-by-call override do: end.
on delete of ub.c-rule-by-call override do: end.
on delete of ub.rule-call-param override do: end.
on delete of ub.c-rule-call-param override do: end.
on delete of ub.prop-ref-call override do: end.
  do
  on error undo, return error return-value
  :
  v-tot-rec = 0 .
  for each buf_dis-card no-lock where
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка таблицы ДК...":U).
  run prg-bar_show in this-procedure .
  for each buf_dis-card no-lock:
    run prg-bar_increment in this-procedure .
    find first buf_dis-host no-lock where
              buf_dis-host.d-card = buf_dis-card.d-card
          and buf_dis-host.host-code = 0
          and buf_dis-host.dt-code = 0
          no-error .
    if not available buf_dis-host then do:
      run create-dis-host-0 in this-procedure ( input buf_dis-card.d-card, input buf_dis-card.card-num) no-error .
      if error-status :error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("err ДК&2 - &1 &3", error-status :get-message(1) , buf_Dis-card.d-card, return-value  )).
              run prg-bar_delete-progress-bar in this-procedure .
          return .
      end.
    end.
  end.
  v-tot-rec = 0 .
  for each ub.sysconf no-lock :
    v-tot-rec = v-tot-rec + 1.
  end.
  for each  ub.staff no-lock :
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_delete-progress-bar in this-procedure .
  v-tot-rec = 0 .
  for each temp-clients where
           temp-clients.obj-type = 'маг':U
       and temp-clients.obj-type = 'скл':U
          :
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Определение базовых валют удаляемых объектов и фирм...":U).
  run prg-bar_show in this-procedure .
  for each temp-clients where
          temp-clients.obj-type = 'маг':U:
    run prg-bar_increment in this-procedure .
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = temp-clients.host-code no-error.
    if not available buf_sysconf then do:
      find first temp-sysconf no-lock where
                temp-sysconf.host-code = temp-clients.host-code.
      assign
      temp-clients.base-code = temp-sysconf.base-code.
    end.
    else do:
      assign
      temp-clients.base-code = buf_sysconf.base-code.
    end.
    for each buf_shop no-lock,
           first buf_sysconf no-lock where
               buf_sysconf.host-code = buf_shop.host-code
           and buf_sysconf.base-code = temp-clients.base-code :
      leave.
    end.
    if not available buf_shop then do:
      find first buf_shop.
    end.
    assign
    temp-clients.new-issue-code = buf_shop.obj-code.
  end.
  for each temp-clients where
          temp-clients.obj-type = 'скл':U:
    run prg-bar_increment in this-procedure .
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = temp-clients.host-code no-error.
    if not available buf_sysconf then do:
      find first temp-sysconf no-lock where
                temp-sysconf.host-code = temp-clients.host-code.
      assign
      temp-clients.base-code = temp-sysconf.base-code.
    end.
    else do:
      assign
      temp-clients.base-code = buf_sysconf.base-code.
    end.
  end.
  run prg-bar_delete-progress-bar in this-procedure .
  v-tot-rec = 0 .
  for each temp-sysconf   :
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка НЕглобальных ДК (по удаляемым фирмам)...":U).
  run prg-bar_show in this-procedure .
  for each temp-sysconf no-lock  :
    for each temp-clients where
            temp-clients.host-code = temp-sysconf.host-code:
      assign
      temp-clients.deleted-sysconf = yes.
    end.
    run delete-sysconf-dc in this-procedure ( input temp-sysconf.host-code) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("delete-sysconf-dc - host-code = &1 &2"
                            , temp-sysconf.host-code
                            , error-status :get-message(1) )).
      return .
    end.
    find first buf_sysconf no-lock where buf_sysconf.base-code = temp-sysconf.base-code no-error.
    if not available buf_sysconf then do:
      find first buf_sysconf no-lock.
    end.
    for each buf_dis-host share-lock where
            buf_dis-host.host-code = temp-sysconf.host-code,
        first buf_dis-card no-lock where
              buf_Dis-card.d-card = buf_dis-host.d-card:
      if buf_dis-host.dt-code = 0 then do:
        run create-dh-sum-record in this-procedure (
                                                    input buf_sysconf.host-code
                                                  ,input temp-sysconf.base-code
                                                  ,input buf_sysconf.base-code
                                                  ,buffer buf_Dis-host
                                                  ,buffer buf_dis-card) no-error.
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("create-dh-sum-record err - d-card=&1 host-code = &2 &3"
                                , buf_dis-card.d-card
                                , temp-sysconf.host-code
                                , error-status :get-message(1) )).
          return .
        end.
      end.
      delete buf_Dis-host.
      for each buf_c-dis-host share-lock where
            buf_c-dis-host.d-card = buf_Dis-host.d-card
        and buf_c-dis-host.host-code = temp-sysconf.host-code
        and buf_c-dis-host.dt-code = buf_Dis-host.dt-code
        :
        delete buf_c-dis-host.
      end.
    end.
    delete temp-sysconf.
    run prg-bar_increment in this-procedure .
  end.
  run prg-bar_delete-progress-bar in this-procedure .
  v-tot-rec = 0 .
  for each temp-clients   :
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка ДК (по удаляемым объектам)...":U).
  run prg-bar_show in this-procedure .
  for each temp-clients:
    find first buf_sysconf no-lock where buf_sysconf.base-code = temp-clients.base-code no-error.
    if not available buf_sysconf then do:
      find first buf_sysconf no-lock.
    end.
    for each buf_dis-obj share-lock where
            buf_dis-obj.obj-type = temp-clients.obj-type
        and buf_dis-obj.obj-code = temp-clients.obj-code,
        first buf_dis-card no-lock where
              buf_Dis-card.d-card = buf_dis-obj.d-card  :
      if not temp-clients.deleted-sysconf then do:
        if buf_dis-obj.dt-code = 0 then do:
          run create-do-sum-record in this-procedure (
                                                      input buf_sysconf.host-code
                                                    ,input temp-clients.base-code
                                                    ,input buf_sysconf.base-code
                                                    ,buffer buf_Dis-obj
                                                    ,buffer buf_dis-card) no-error.
          if error-status:error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("create-do-sum-record err - d-card=&1 &2&3 &4"
                                  , buf_dis-card.d-card
                                  , temp-clients.obj-type
                                  , temp-clients.obj-code
                                  , error-status :get-message(1) )).
            return .
          end.
        end.
      end.
      for each buf_c-dis-obj share-lock where
            buf_c-dis-obj.d-card = buf_Dis-obj.d-card
        and buf_c-dis-obj.obj-type = temp-clients.obj-type
        and buf_c-dis-obj.obj-code = temp-clients.obj-code:
        delete buf_c-dis-obj.
      end.
      delete buf_Dis-obj.
    end.
    if temp-clients.obj-type = 'маг':U then do:
      run rename-issue-code in this-procedure ( input temp-clients.obj-code) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("rename-issue-code err - d-card=&1 &2", buf_dis-card.d-card, error-status :get-message(1) )).
        return .
      end.
    end.
    run prg-bar_increment in this-procedure .
  end.
  run prg-bar_delete-progress-bar in this-procedure .
  v-tot-rec = 0 .
  for each buf_sysconf   :
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка ДК - создание записей платежей...":U).
  run prg-bar_show in this-procedure .
  for each buf_sysconf no-lock
  :
    for each buf_dis-host no-lock where
            buf_dis-host.host-code = buf_sysconf.host-code,
        first buf_dis-card no-lock where
              buf_Dis-card.d-card = buf_dis-host.d-card
    :
      if buf_dis-host.dt-code = 0 then do:
        run create-dh-sum-record in this-procedure (
                                                    input buf_sysconf.host-code
                                                  ,input buf_sysconf.base-code
                                                  ,input buf_sysconf.base-code
                                                  ,buffer buf_Dis-host
                                                  ,buffer buf_dis-card) no-error.
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("create-dh-sum-record err - d-card=&1 host-code=&2 &3"
                                , buf_dis-card.d-card
                                , buf_sysconf.host-code
                                , error-status :get-message(1) )).
          return .
        end.
      end.
    end.
    run prg-bar_increment in this-procedure .
  end.
  run prg-bar_delete-progress-bar in this-procedure .
end.
procedure create-do-sum-record :
define input parameter p-host-code as integer no-undo .
define input parameter p-old-base-code as integer no-undo .
define input parameter p-base-code as integer no-undo .
define parameter buffer buf_dis-obj for ub.dis-obj.
define parameter buffer buf_dis-card for ub.dis-card.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-source-ref as character no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-exch-scale as integer no-undo .
define variable v-curr-abbr as character no-undo .
define buffer buf_payment for ub.payment.
do
on error undo, return error return-value
:
    run cur-time in this-procedure ( output v-today, output v-time).
    v-source-ref = substitute('&1&2-&3'
                            , buf_dis-obj.obj-type
                            , buf_dis-obj.obj-code
                            , string(v-today, '99/99/9999')
                            ).
    find first buf_payment where
            buf_payment.host-code = p-host-code
        and buf_payment.d-card = buf_dis-obj.d-card
        and buf_payment.source-type = ''
        and buf_payment.source-ref = v-source-ref
        and buf_payment.status_ = 'факт':U
        and buf_payment.fact-date = v-today
        no-error.
    if not available buf_payment then do:
      create buf_payment.
      assign
      buf_payment.host-code = p-host-code
      buf_payment.d-card = buf_dis-obj.d-card
      buf_payment.source-type = ''
      buf_payment.source-ref = v-source-ref
      buf_payment.fact-date = v-today
      buf_payment.base-scale = 1
      buf_payment.cli-code = buf_Dis-card.cli-code
      buf_payment.cli-type = buf_Dis-card.cli-type
      buf_payment.closid = userid("ub")
      buf_payment.creid = userid("ub")
      buf_payment.due-date = v-today
      buf_payment.exch-code = p-old-base-code
      buf_payment.exch-date = v-today
      buf_payment.exch-scale = 1
      buf_payment.pay-code = 1
      buf_payment.payer-type = buf_Dis-card.cli-type
      buf_payment.payer-code = buf_Dis-card.cli-code
      buf_payment.pmnt-code = string(next-value(s-pmnt-code, ub))
      buf_payment.ps = ''
      buf_payment.status_ =  'факт':U
      .
    end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-old-base-code
  ,input  v-today
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr
  )  .
    assign
    buf_payment.tot-base = buf_payment.tot-base + (if buf_dis-card.credit-card
                                                  then buf_dis-obj.pay-tot-base
                                                  else (buf_dis-obj.gds-tot-base - buf_dis-obj.gds-dis-base)
                                                  )
    buf_payment.tot-rubl = buf_payment.tot-rubl + (if buf_dis-card.credit-card
                                                  then buf_dis-obj.pay-tot-rubl
                                                  else (buf_dis-obj.gds-tot-rubl - buf_dis-obj.gds-dis-rubl)
                                                  )
    buf_payment.tot-cli  = (if p-old-base-code = 0 then buf_payment.tot-rubl else buf_payment.tot-base)
    buf_payment.tot-base = (if p-old-base-code = p-base-code then buf_payment.tot-base else buf_payment.tot-rubl / v-exch-rate * v-exch-scale)
    buf_payment.base-rate = (if p-old-base-code = 0 then 1 else buf_payment.tot-rubl / buf_payment.tot-base)
    buf_payment.exch-rate = (if p-old-base-code = 0 then 1 else buf_payment.tot-rubl / buf_payment.tot-base)
    .
end.
end procedure.
procedure create-dh-sum-record :
define input parameter p-host-code as integer no-undo .
define input parameter p-old-base-code as integer no-undo .
define input parameter p-base-code as integer no-undo .
define parameter buffer buf_dis-host for ub.dis-host.
define parameter buffer buf_dis-card for ub.dis-card.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-source-ref as character no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-exch-scale as integer no-undo .
define variable v-curr-abbr as character no-undo .
define buffer buf_payment for ub.payment.
do
on error undo, return error return-value
:
    run cur-time in this-procedure ( output v-today, output v-time).
    v-source-ref = substitute('&1&2-&3'
                            , 'орг':U
                            , buf_dis-host.host-code
                            , string(v-today, '99/99/9999')
                            ).
    find first buf_payment where
            buf_payment.host-code = p-host-code
        and buf_payment.d-card = buf_dis-host.d-card
        and buf_payment.source-type = ''
        and buf_payment.source-ref = v-source-ref
        and buf_payment.status_ = 'факт':U
        and buf_payment.fact-date = v-today
        no-error.
    if not available buf_payment then do:
      create buf_payment.
      assign
      buf_payment.host-code = p-host-code
      buf_payment.d-card = buf_dis-host.d-card
      buf_payment.source-type = ''
      buf_payment.source-ref = v-source-ref
      buf_payment.fact-date = v-today
      buf_payment.base-scale = 1
      buf_payment.cli-code = buf_Dis-card.cli-code
      buf_payment.cli-type = buf_Dis-card.cli-type
      buf_payment.closid = userid("ub")
      buf_payment.creid = userid("ub")
      buf_payment.due-date = v-today
      buf_payment.exch-code = p-old-base-code
      buf_payment.exch-date = v-today
      buf_payment.exch-scale = 1
      buf_payment.pay-code = 1
      buf_payment.payer-type = buf_Dis-card.cli-type
      buf_payment.payer-code = buf_Dis-card.cli-code
      buf_payment.pmnt-code = string(next-value(s-pmnt-code, ub))
      buf_payment.ps = ''
      buf_payment.status_ =  'факт':U
      .
    end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-old-base-code
  ,input  v-today
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr
  )  .
    assign
    buf_payment.tot-base = buf_payment.tot-base + (if buf_dis-card.credit-card
                                                  then buf_dis-host.pay-tot-base
                                                  else (buf_dis-host.gds-tot-base - buf_dis-host.gds-dis-base)
                                                  )
    buf_payment.tot-rubl = buf_payment.tot-rubl + (if buf_dis-card.credit-card
                                                  then buf_dis-host.pay-tot-rubl
                                                  else (buf_dis-host.gds-tot-rubl - buf_dis-host.gds-dis-rubl)
                                                  )
    buf_payment.tot-cli  = (if p-old-base-code = 0 then buf_payment.tot-rubl else buf_payment.tot-base)
    buf_payment.tot-base = (if p-old-base-code = p-base-code then buf_payment.tot-base else buf_payment.tot-rubl / v-exch-rate * v-exch-scale)
    buf_payment.base-rate = (if p-old-base-code = 0 then 1 else buf_payment.tot-rubl / buf_payment.tot-base)
    buf_payment.exch-rate = (if p-old-base-code = 0 then 1 else buf_payment.tot-rubl / buf_payment.tot-base)
    .
end.
end procedure.
procedure delete-sysconf-dc :
define input parameter p-host-code as integer no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
define buffer buf_c-dis-host for ub.c-dis-host.
define buffer buf_c-dis-obj for ub.c-dis-obj.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-type-attr for ub.dis-card-type-attr.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_c-dis-dct-rule for ub.c-dis-dct-rule.
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_c-dis-card-type for ub.c-dis-card-type.
define buffer buf_c-dis-card-type-attr for ub.c-dis-card-type-attr.
define buffer buf_c-dis-card-mask for ub.c-dis-card-mask.
define buffer buf_clients for ub.clients.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf_c-hist-nws-option for ub.c-hist-nws-option.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_c-rp-by-call for ub.c-rp-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_c-rule-by-call for ub.c-rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_c-rule-call-param for ub.c-rule-call-param.
define buffer buf_prop-ref-call for ub.prop-ref-call.
do
on error undo, return error
:
  find first buf_dis-card-type no-lock where
            buf_dis-card-type.emitent-host-code = p-host-code no-error.
  if not available buf_dis-card-type then return.
  for each buf_dis-card share-lock where
         buf_Dis-card.emitent-host-code = p-host-code:
    for each buf_Dis-card-property share-lock where
            buf_dis-card-property.d-card = buf_Dis-card.d-card :
      delete buf_dis-card-property.
    end.
    for each buf_c-Dis-card-property share-lock where
            buf_c-dis-card-property.d-card = buf_Dis-card.d-card :
      delete buf_c-dis-card-property.
    end.
    for each buf_Dis-obj share-lock where
            buf_dis-obj.d-card = buf_Dis-card.d-card :
      delete buf_dis-obj.
    end.
    for each buf_c-Dis-obj share-lock where
            buf_c-dis-obj.d-card = buf_Dis-card.d-card :
      delete buf_c-dis-obj.
    end.
    for each buf_Dis-host share-lock where
            buf_dis-host.d-card = buf_Dis-card.d-card :
      delete buf_dis-host.
    end.
    for each buf_c-Dis-host share-lock where
            buf_c-dis-host.d-card = buf_Dis-card.d-card :
      delete buf_c-dis-host.
    end.
    for each buf_dis-dc-rule share-lock where
            buf_dis-dc-rule.d-card = buf_Dis-card.d-card :
      delete buf_dis-dc-rule.
    end.
    for each buf_c-dis-dc-rule share-lock where
            buf_c-dis-dc-rule.d-card = buf_Dis-card.d-card :
      delete buf_c-dis-dc-rule.
    end.
    for each buf_clients no-lock where
           buf_clients.host-code = p-host-code:
       for each buf_trn-doc no-lock where
                buf_trn-doc.obj-type = buf_Clients.obj-type
            and buf_trn-doc.obj-code = buf_Clients.obj-code
            and buf_trn-doc.cli-type = buf_dis-card.cli-type
            and buf_trn-doc.cli-code = buf_dis-card.cli-code:
         if buf_trn-doc.d-card = buf_dis-card.d-card then do:
           buf_trn-doc.d-card = ''.
         end.
       end.
    end.
    delete buf_Dis-card.
  end.
  for each buf_Dis-card-type share-lock where
          buf_Dis-card-type.emitent-host-code = p-host-code:
    for each buf_Dis-card-type-attr share-lock where
            buf_Dis-card-type-attr.emitent-host-code = p-host-code
        and buf_Dis-card-type-attr.type = buf_dis-card-type.type
            :
       delete buf_dis-card-type-attr.
    end.
    for each buf_Dis-card-mask share-lock where
            buf_Dis-card-mask.emitent-host-code = p-host-code
        and buf_Dis-card-mask.type = buf_dis-card-type.type
            :
       delete buf_dis-card-mask.
    end.
    for each buf_Dis-dct-rule share-lock where
            buf_Dis-dct-rule.emitent-host-code = p-host-code
        and buf_Dis-dct-rule.type = buf_dis-card-type.type
            :
       delete buf_dis-dct-rule.
    end.
    for each buf_c-Dis-dct-rule share-lock where
            buf_c-Dis-dct-rule.emitent-host-code = p-host-code
        and buf_c-Dis-dct-rule.type = buf_dis-card-type.type
            :
       delete buf_c-dis-dct-rule.
    end.
    for each buf_hist-nws-option share-lock where
            buf_hist-nws-option.subject-group = 'c-dc-hist':U
        and buf_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
        and buf_hist-nws-option.charkey_one = buf_dis-card-type.type:
     delete buf_hist-nws-option.
    end.
    for each buf_c-hist-nws-option share-lock where
            buf_c-hist-nws-option.subject-group = 'c-dc-hist':U
        and buf_c-hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
        and buf_c-hist-nws-option.charkey_one = buf_dis-card-type.type:
     delete buf_c-hist-nws-option.
    end.
    for each  buf_rp-by-call share-lock where
            buf_rp-by-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_rp-by-call.
    end.
    for each  buf_c-rp-by-call share-lock where
            buf_c-rp-by-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_c-rp-by-call.
    end.
    for each  buf_rule-by-call share-lock where
            buf_rule-by-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_rule-by-call.
    end.
    for each  buf_c-rule-by-call share-lock where
            buf_c-rule-by-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_c-rule-by-call.
    end.
    for each  buf_rule-call-param share-lock where
            buf_rule-call-param.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_rule-call-param.
    end.
    for each  buf_c-rule-call-param share-lock where
            buf_c-rule-call-param.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_c-rule-call-param.
    end.
    for each  buf_prop-ref-call share-lock where
            buf_prop-ref-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_prop-ref-call.
    end.
    delete buf_dis-card-type.
  end.
end.
end procedure.
procedure rename-issue-code :
define input parameter p-obj-code as integer no-undo .
define buffer buf_dis-card for ub.dis-card.
on write of ub.dis-card override do: end.
do
on error undo, return error
:
  for each buf_dis-card share-lock:
    if can-find(first temp-clients no-lock where
                    temp-clients.obj-type = 'маг':U
                and temp-clients.obj-code = buf_dis-card.issue-code) then do:
      assign
      buf_dis-card.issue-code = temp-clients.new-issue-code.
    end.
  end.
end.
end procedure.
define temp-table tt-dis-host no-undo like ub.dis-host.
procedure create-dis-host-0 :
define input parameter p-d-card like ub.dis-card.d-card no-undo .
define input parameter p-card-num like ub.dis-card.card-num no-undo .
define buffer buf_dis-host for ub.dis-host.
  do
  on error undo, return error return-value
  :
    if available tt-dis-host then delete tt-dis-host.
    create tt-dis-host.
    assign
    tt-dis-host.d-card = p-d-card
    tt-dis-host.card-num = p-card-num
    tt-dis-host.dt-code = 0
    .
    for each buf_Dis-host no-lock where
          buf_dis-host.d-card = p-d-card
      and buf_dis-host.host-code > 0
      on error undo, return error
      on stop undo, return error :
      assign
      tt-dis-host.gds-dis-base = tt-dis-host.gds-dis-base + buf_dis-host.gds-dis-base
      tt-dis-host.gds-dis-rubl = tt-dis-host.gds-dis-rubl + buf_dis-host.gds-dis-rubl
      tt-dis-host.gds-tot-base = tt-dis-host.gds-tot-base + buf_dis-host.gds-tot-base
      tt-dis-host.gds-tot-rubl = tt-dis-host.gds-tot-rubl + buf_dis-host.gds-tot-rubl
      tt-dis-host.num-chk      = tt-dis-host.num-chk      + buf_dis-host.num-chk
      tt-dis-host.pay-tot-base = tt-dis-host.pay-tot-base + buf_dis-host.pay-tot-base
      tt-dis-host.pay-tot-rubl = tt-dis-host.pay-tot-rubl + buf_dis-host.pay-tot-rubl
      .
    end.
    create buf_Dis-host.
    buffer-copy tt-dis-host to buf_dis-host.
    release buf_dis-host.
    delete tt-dis-host.
  end.
end procedure.
