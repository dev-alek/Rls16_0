block-level on error undo, throw.
using Ibs.Th.Gbl.ProgressBar.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0040.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0040.p $":U .
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
  , input substitute("Клиенты")
  ).
define shared temp-table temp-clients no-undo like ub.clients
field base-code as integer
field new-issue-code as integer
field deleted-sysconf as logical
.
define shared temp-table temp-sysconf no-undo like ub.sysconf.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on write  of ub.clients   override do: end .
on delete of ub.clients   override do: end .
on write  of ub.store     override do: end .
on delete of ub.store     override do: end .
on delete of ub.c-store   override do: end .
on write  of ub.shop      override do: end .
on delete of ub.shop      override do: end .
on delete of ub.sysconf   override do: end .
on write  of ub.sysconf   override do: end .
on write  of ub.payment   override do: end .
on write  of ub.prt-obj   override do: end .
on delete of ub.prt-obj   override do: end .
on delete of ub.staff     override do: end .
on write  of ub.staff     override do: end .
  do
  on error undo, return error return-value
  :
  v-tot-rec = 0 .
  for each ub.clients no-lock where
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec ).
  run prg-bar_title in this-procedure ( input "Обработка таблиц Клиентов, складов и магазинов...":U).
  run prg-bar_show in this-procedure .
  for each ub.clients  exclusive-lock :
     run prg-bar_increment in this-procedure .
     if ub.clients.db-num <> p-db-num then do:
      case ub.clients.obj-type :
        when 'маг':U then do:
              for each ub.shop exclusive-lock where
                      ub.shop.obj-code = ub.clients.obj-code :
                      run del-obj-other (ub.clients.obj-type , ub.clients.obj-code) no-error .
                      if error-status :error then do:
                          run write-log-and-file in p-log-handle (
                                input 1
                              , input log-file-name
                              , input 1
                              , input substitute("err маг&2 - &1 &3", error-status :get-message(1) ,ub.clients.obj-code, return-value  )).
                              run prg-bar_delete-progress-bar in this-procedure .
                          return .
                      end.
                      delete ub.shop.
                      run del-cl-attr in this-procedure (ub.clients.obj-type,ub.clients.obj-code).
              end.
              create temp-clients.
              buffer-copy ub.clients to temp-clients.
              release temp-clients.
              delete ub.clients.
        end.
        when 'скл':U then do:
              for each ub.store exclusive-lock where
                      ub.store.obj-code = ub.clients.obj-code :
                      run del-obj-other (ub.clients.obj-type , ub.clients.obj-code) no-error .
                      if error-status :error then do:
                          run write-log-and-file in p-log-handle (
                                input 1
                              , input log-file-name
                              , input 1
                              , input substitute("err скл&2 - &1 &3", error-status :get-message(1) ,ub.clients.obj-code, return-value  )).
                          run prg-bar_delete-progress-bar in this-procedure .
                          return .
                      end.
                      delete ub.store.
                      run del-cl-attr in this-procedure (ub.clients.obj-type,ub.clients.obj-code).
              end.
              create temp-clients.
              buffer-copy ub.clients to temp-clients.
              release temp-clients.
              delete ub.clients.
        end.
        when 'орг':U then do:
            ub.clients.db-num = ?.
        end.
        otherwise do:
            ub.clients.db-num = ?.
        end.
      end case.
     end.
     else do:
       if ub.clients.db-num <> ? then  ub.clients.db-num = 0.
     end.
  end.
  run prg-bar_delete-progress-bar in this-procedure .
  v-tot-rec = 0 .
  for each ub.sysconf no-lock :
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка таблицы фирм...":U).
  run prg-bar_show in this-procedure .
for each ub.sysconf exclusive-lock :
    run prg-bar_increment in this-procedure .
    if can-find ( first ub.shop  no-lock where ub.shop.host-code = ub.sysconf.host-code  ) or
       can-find ( first ub.store no-lock where ub.store.host-code = ub.sysconf.host-code ) then do:
    end.
    else do:
       find first ub.clients exclusive-lock where
                  ub.clients.obj-type = 'орг':U and
                  ub.clients.obj-code = ub.sysconf.host-code no-error .
       if available ub.clients  then  ub.clients.db-num = ? .
        run del-host-other in this-procedure  ( ub.clients.obj-code ) no-error .
        if error-status :error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("err фирма&2 - &1 &3", error-status :get-message(1) ,ub.clients.obj-code, return-value  )).
            run prg-bar_delete-progress-bar in this-procedure .
            return .
        end.
        run del-cl-attr in this-procedure (ub.clients.obj-type,ub.clients.obj-code) no-error.
        if error-status :error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("err фирма&2 - &1 &3", error-status :get-message(1) ,ub.clients.obj-code, return-value  )).
            run prg-bar_delete-progress-bar in this-procedure .
            return .
        end.
        create temp-sysconf.
        buffer-copy ub.sysconf to temp-sysconf.
        release temp-sysconf.
        delete ub.sysconf .
    end.
end.
run prg-bar_delete-progress-bar in this-procedure .
  v-tot-rec = 0 .
  for each ub.staff no-lock :
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка таблицы ПЕРСОНАЛ...":U).
  run prg-bar_show in this-procedure .
  for each ub.staff exclusive-lock  where
         ub.staff.role-level = 'db':U
     and (ub.staff.db-num < p-db-num
          or
          ub.staff.db-num > p-db-num)
  by db-num
  :
      run prg-bar_increment in this-procedure .
      delete ub.staff.
  end.
  for each ub.staff exclusive-lock:
     ub.staff.db-num = 0.
  end.
  run prg-bar_delete-progress-bar in this-procedure .
end.
procedure del-cl-attr :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
on delete  of ub.c-clients         override do: end .
on delete  of ub.clients-attr      override do: end .
on delete  of ub.c-clients-attr      override do: end .
on delete  of ub.c-shop      override do: end .
on delete  of ub.c-clients   override do: end .
on delete  of ub.dis-thbj-rule override do: end.
on delete  of ub.c-dis-thbj-rule override do: end.
on delete  of ub.thbj-attr override do: end.
on delete  of ub.c-thbj-attr override do: end.
  do
  on error undo, return error return-value
  :
  if p-obj-type ='маг':U
  or p-obj-type = 'скл':U then do:
    for each ub.c-clients exclusive-lock where
            ub.c-clients.obj-type = p-obj-type and
            ub.c-clients.obj-code = p-obj-code :
            delete ub.c-clients.
    end.
    for each ub.c-clients-attr exclusive-lock where
            ub.c-clients-attr.obj-type = p-obj-type and
            ub.c-clients-attr.obj-code = p-obj-code :
            delete ub.c-clients-attr.
    end.
    for each ub.clients-attr exclusive-lock where
            ub.clients-attr.obj-type = p-obj-type and
            ub.clients-attr.obj-code = p-obj-code :
            delete ub.clients-attr.
    end.
    for each ub.dis-thbj-rule exclusive-lock where
            ub.dis-thbj-rule.obj-type = p-obj-type and
            ub.dis-thbj-rule.obj-code = p-obj-code :
            delete ub.dis-thbj-rule.
    end.
    for each ub.c-dis-thbj-rule exclusive-lock where
            ub.c-dis-thbj-rule.obj-type = p-obj-type and
            ub.c-dis-thbj-rule.obj-code = p-obj-code :
            delete ub.c-dis-thbj-rule.
    end.
  end.
  for each ub.thbj-attr exclusive-lock where
           ub.thbj-attr.obj-type = p-obj-type and
           ub.thbj-attr.obj-code = p-obj-code :
           delete ub.thbj-attr.
  end.
  for each ub.c-thbj-attr exclusive-lock where
           ub.c-thbj-attr.obj-type = p-obj-type and
           ub.c-thbj-attr.obj-code = p-obj-code :
           delete ub.c-thbj-attr.
  end.
  if p-obj-type = 'орг':U then do:
    for each ub.dis-thbj-rule exclusive-lock where
            ub.dis-thbj-rule.host-code = p-obj-code :
            delete ub.dis-thbj-rule.
    end.
    for each ub.c-dis-thbj-rule exclusive-lock where
            ub.c-dis-thbj-rule.host-code = p-obj-code :
            delete ub.c-dis-thbj-rule.
    end.
  end.
  if p-obj-type = 'маг':U then do:
      for each ub.c-shop exclusive-lock where
              ub.c-shop.obj-code = p-obj-code :
              delete ub.c-shop.
      end.
  end.
  if p-obj-type = 'скл':U then do:
      for each ub.c-store exclusive-lock where
              ub.c-store.obj-code = p-obj-code :
              delete ub.c-store.
      end.
  end.
  end.
end procedure.
procedure del-obj-other :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
on delete of ub.cash-pay-attr override do: end .
on delete of ub.c-cash-pay-attr override do: end .
on delete of ub.c-cash-pay override do: end .
on delete of ub.c-cash-pay override do: end .
on delete of ub.dis-cp-rule override do: end .
on delete of ub.c-dis-cp-rule override do: end .
on delete of ub.gds-grp-attr  override do: end .
on delete of ub.gds-grp-obj   override do: end .
on delete of ub.prt-obj       override do: end .
on delete of ub.s-coeff       override do: end .
on delete of ub.tax-rate-gds     override do: end .
on delete of ub.tax-rate-gds-grp override do: end .
on delete of ub.tax-rate-value   override do: end .
on delete of ub.recipe           override do: end .
on delete of ub.turnover-buyer             override do: end .
on delete of ub.turnover-buyer-attr        override do: end .
on delete of ub.turnover-buyer-gds         override do: end .
on delete of ub.turnover-buyer-gds-attr    override do: end .
on delete of ub.turnover-buyer-main        override do: end .
on delete of ub.turnover-buyer-main-attr   override do: end .
on delete of ub.user-obj                   override do: end .
on delete of ub.user-obj-attr              override do: end .
on delete of ub.trn-reason-obj             override do: end .
  do
  on error undo, return error return-value
  :
    for each ub.trn-reason-obj  exclusive-lock where
              ub.trn-reason-obj.obj-type = p-obj-type and
              ub.trn-reason-obj.obj-code = p-obj-code :
              delete ub.trn-reason-obj.
    end.
    for each ub.prt-obj exclusive-lock where
              ub.prt-obj.obj-type = p-obj-type and
              ub.prt-obj.obj-code = p-obj-code :
              delete ub.prt-obj.
    end.
    for each ub.cash-pay-attr exclusive-lock where
              ub.cash-pay-attr.obj-type = p-obj-type and
              ub.cash-pay-attr.obj-code = p-obj-code :
              delete ub.cash-pay-attr.
    end.
    for each ub.c-cash-pay-attr exclusive-lock where
              ub.c-cash-pay-attr.obj-type = p-obj-type and
              ub.c-cash-pay-attr.obj-code = p-obj-code,
       each ub.c-cash-pay exclusive-lock where
              ub.c-cash-pay.cdpay-code = ub.c-cash-pay-attr.cdpay-code and
              ub.c-cash-pay.curr-code = ub.c-cash-pay-attr.curr-code and
              ub.c-cash-pay.corr-user-db-num = ub.c-cash-pay-attr.corr-user-db-num and
              ub.c-cash-pay.chip-num = ub.c-cash-pay-attr.chip-num:
      delete ub.c-cash-pay-attr.
      delete ub.c-cash-pay.
    end.
    for each ub.dis-cp-rule exclusive-lock where
              ub.dis-cp-rule.obj-type = p-obj-type and
              ub.dis-cp-rule.obj-code = p-obj-code :
              delete ub.dis-cp-rule.
    end.
    for each ub.c-dis-cp-rule exclusive-lock where
              ub.c-dis-cp-rule.obj-type = p-obj-type and
              ub.c-dis-cp-rule.obj-code = p-obj-code :
              delete ub.c-dis-cp-rule.
    end.
    for each ub.gds-grp-attr exclusive-lock where
              ub.gds-grp-attr.obj-type = p-obj-type and
              ub.gds-grp-attr.obj-code = p-obj-code :
              delete ub.gds-grp-attr.
    end.
    for each ub.gds-grp-obj exclusive-lock where
             ub.gds-grp-obj.obj-type = p-obj-type and
             ub.gds-grp-obj.obj-code = p-obj-code :
             delete ub.gds-grp-obj.
    end.
    for each ub.s-coeff exclusive-lock where
              ub.s-coeff.obj-type = p-obj-type and
              ub.s-coeff.obj-code = p-obj-code :
              delete ub.s-coeff.
    end.
    for each ub.tax-rate-gds exclusive-lock where
              ub.tax-rate-gds.obj-type = p-obj-type and
              ub.tax-rate-gds.obj-code = p-obj-code :
              delete ub.tax-rate-gds.
    end.
    for each ub.tax-rate-gds-grp exclusive-lock where
              ub.tax-rate-gds-grp.obj-type = p-obj-type and
              ub.tax-rate-gds-grp.obj-code = p-obj-code :
              delete ub.tax-rate-gds-grp.
    end.
    for each ub.tax-rate-value exclusive-lock where
              ub.tax-rate-value.obj-type = p-obj-type and
              ub.tax-rate-value.obj-code = p-obj-code :
              delete ub.tax-rate-value.
    end.
    for each ub.recipe exclusive-lock where
              ub.recipe.obj-type = p-obj-type and
              ub.recipe.obj-code = p-obj-code :
              delete ub.recipe.
    end.
for each ub.turnover-buyer                  exclusive-lock where
          ub.turnover-buyer.obj-type = p-obj-type and
          ub.turnover-buyer.obj-code = p-obj-code :
          delete ub.turnover-buyer.
end.
for each ub.turnover-buyer-attr             exclusive-lock where
          ub.turnover-buyer-attr.obj-type = p-obj-type and
          ub.turnover-buyer-attr.obj-code = p-obj-code :
          delete ub.turnover-buyer-attr.
end.
for each ub.turnover-buyer-gds              exclusive-lock where
          ub.turnover-buyer-gds.obj-type = p-obj-type and
          ub.turnover-buyer-gds.obj-code = p-obj-code :
          delete ub.turnover-buyer-gds.
end.
for each ub.turnover-buyer-gds-attr         exclusive-lock where
          ub.turnover-buyer-gds-attr.obj-type = p-obj-type and
          ub.turnover-buyer-gds-attr.obj-code = p-obj-code :
          delete ub.turnover-buyer-gds-attr.
end.
for each ub.turnover-buyer-main             exclusive-lock where
          ub.turnover-buyer-main.obj-type = p-obj-type and
          ub.turnover-buyer-main.obj-code = p-obj-code :
          delete ub.turnover-buyer-main.
end.
for each ub.turnover-buyer-main-attr        exclusive-lock where
          ub.turnover-buyer-main-attr.obj-type = p-obj-type and
          ub.turnover-buyer-main-attr.obj-code = p-obj-code :
          delete ub.turnover-buyer-main-attr.
end.
for each ub.user-obj        exclusive-lock where
          ub.user-obj.obj-type = p-obj-type and
          ub.user-obj.obj-code = p-obj-code :
          delete ub.user-obj.
end.
for each ub.user-obj-attr        exclusive-lock where
          ub.user-obj-attr.obj-type = p-obj-type and
          ub.user-obj-attr.obj-code = p-obj-code :
          delete ub.user-obj-attr.
end.
  end.
end procedure.
procedure del-host-other :
define input  parameter p-host-code as integer   no-undo .
on delete of ub.fin-bank       override do: end .
on delete of ub.c-fin-bank       override do: end .
on delete of ub.fin-schet       override do: end .
on delete of ub.c-fin-schet       override do: end .
on delete of ub.fin-code-an-uchet       override do: end .
on delete of ub.c-fin-code-an-uchet     override do: end .
on delete of ub.fin-code-cel-nazn       override do: end .
on delete of ub.c-fin-code-cel-nazn     override do: end .
on delete of ub.fin-code-cor-acc       override do: end .
on delete of ub.c-fin-code-cor-acc     override do: end .
on delete of ub.dis-rule         override do: end .
on delete of ub.c-dis-rule       override do: end .
on delete of ub.dis-gds-rule     override do: end .
on delete of ub.c-dis-gds-rule   override do: end .
on delete of ub.gds-host-attr    override do: end .
on delete of ub.c-gds-host-attr  override do: end .
on delete of ub.user-host        override do: end .
on delete of ub.user-host-attr   override do: end .
on delete of ub.trn-reason-host  override do: end .
  do
  on error undo, return error return-value
  :
    for each ub.trn-reason-host exclusive-lock where
             ub.trn-reason-host.host-code = p-host-code
              :
      delete ub.trn-reason-host.
    end.
    for each ub.user-host exclusive-lock where
             ub.user-host.host-code = p-host-code
              :
      delete ub.user-host.
    end.
    for each ub.user-host-attr exclusive-lock where
             ub.user-host-attr.host-code = p-host-code
              :
      delete ub.user-host-attr.
    end.
    for each ub.fin-bank exclusive-lock where
             ub.fin-bank.host-code = p-host-code
              :
      delete ub.fin-bank.
    end.
    for each ub.c-fin-bank exclusive-lock where
             ub.c-fin-bank.host-code = p-host-code
              :
      delete ub.c-fin-bank.
    end.
    for each ub.fin-schet exclusive-lock where
             ub.fin-schet.host-code = p-host-code
              :
      delete ub.fin-schet.
    end.
    for each ub.c-fin-schet exclusive-lock where
             ub.c-fin-schet.host-code = p-host-code
              :
      delete ub.c-fin-schet.
    end.
    for each ub.fin-code-an-uchet exclusive-lock where
             ub.fin-code-an-uchet.host-code = p-host-code
              :
      delete ub.fin-code-an-uchet.
    end.
    for each ub.c-fin-code-an-uchet exclusive-lock where
             ub.c-fin-code-an-uchet.host-code = p-host-code
              :
      delete ub.c-fin-code-an-uchet.
    end.
    for each ub.fin-code-cel-nazn exclusive-lock where
             ub.fin-code-cel-nazn.host-code = p-host-code
              :
      delete ub.fin-code-cel-nazn.
    end.
    for each ub.c-fin-code-cel-nazn exclusive-lock where
             ub.c-fin-code-cel-nazn.host-code = p-host-code
              :
      delete ub.c-fin-code-cel-nazn.
    end.
    for each ub.fin-code-cor-acc exclusive-lock where
             ub.fin-code-cor-acc.host-code = p-host-code
              :
      delete ub.fin-code-cor-acc.
    end.
    for each ub.c-fin-code-cor-acc exclusive-lock where
             ub.c-fin-code-cor-acc.host-code = p-host-code
              :
      delete ub.c-fin-code-cor-acc.
    end.
    for each ub.dis-rule exclusive-lock where
              ub.dis-rule.host-code = p-host-code :
              delete ub.dis-rule.
    end.
    for each ub.c-dis-rule exclusive-lock where
              ub.c-dis-rule.host-code = p-host-code :
              delete ub.c-dis-rule.
    end.
    for each ub.dis-gds-rule exclusive-lock where
              ub.dis-gds-rule.obj-type = 'орг':U
           and ub.dis-gds-rule.obj-code =  p-host-code :
      delete ub.dis-gds-rule.
    end.
    for each ub.c-dis-gds-rule exclusive-lock where
              ub.c-dis-gds-rule.obj-type = 'орг':U
           and ub.c-dis-gds-rule.obj-code =  p-host-code :
      delete ub.dis-gds-rule.
    end.
    for each ub.gds-host-attr exclusive-lock where
              ub.gds-host-attr.host-code = p-host-code :
      delete ub.gds-host-attr.
    end.
    for each ub.c-gds-host-attr exclusive-lock where
              ub.c-gds-host-attr.host-code = p-host-code :
      delete ub.c-gds-host-attr.
    end.
  end.
end procedure.
