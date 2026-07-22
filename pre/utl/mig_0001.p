block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0001.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0001.p $":U .
define variable vss-description as character no-undo init "Модификация таблиц раздела Пользователи".
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
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute ( "Пользователи" )
    ).
on write   of ub.user-login                   override do: end .
on delete  of ub.user-login                   override do: end .
on delete  of ub.user-login-action-item       override do: end .
on delete  of ub.user-login-action-item-attr  override do: end .
on delete  of ub.user-login-action-role       override do: end .
on delete  of ub.user-login-action-role-attr  override do: end .
on delete  of ub.user-login-attr              override do: end .
on delete  of ub.user-menu-group              override do: end .
on delete  of ub.user-menu-group-attr         override do: end .
on delete  of ub.action-role                  override do: end .
on delete  of ub.action-role-attr             override do: end .
on delete  of ub.action-role-item             override do: end .
on delete  of ub.action-role-item-attr        override do: end .
on write   of ub.user-login-action-item       override do: end .
on write   of ub.user-login-action-item-attr  override do: end .
on write   of ub.user-login-action-role       override do: end .
on write   of ub.user-login-action-role-attr  override do: end .
on write   of ub.user-login-attr              override do: end .
on write   of ub.user-menu-group              override do: end .
on write   of ub.user-menu-group-attr         override do: end .
on write   of ub.action-role                  override do: end .
on write   of ub.action-role-attr             override do: end .
on write   of ub.action-role-item             override do: end .
on write   of ub.action-role-item-attr        override do: end .
on write   of ub.user-host                    override do: end .
on write   of ub.user-host-attr               override do: end .
on write   of ub.user-obj                     override do: end .
on write   of ub.user-obj-attr                override do: end .
  do
  on error undo, return error return-value
  :
    for each ub.user-login exclusive-lock   :
         ub.user-login.db-num = 0.
    end.
    for each ub.user-login-action-item exclusive-lock   where
             ub.user-login-action-item.db-num <>  p-db-num
    :
             delete ub.user-login-action-item.
    end.
    for each ub.user-login-action-item-attr exclusive-lock   where
             ub.user-login-action-item-attr.db-num <> p-db-num
    :
              delete ub.user-login-action-item-attr.
    end.
    for each ub.user-login-action-role exclusive-lock   where
             ub.user-login-action-role.db-num <> p-db-num
    :
              delete ub.user-login-action-role.
    end.
    for each ub.user-login-action-role-attr exclusive-lock   where
             ub.user-login-action-role-attr.db-num <> p-db-num
    :
              delete ub.user-login-action-role-attr.
    end.
    for each ub.user-login-attr exclusive-lock  where
             ub.user-login-attr.db-num <> p-db-num
      :
             delete ub.user-login-attr .
    end.
    for each ub.user-menu-group exclusive-lock  where
             ub.user-menu-group.db-num <> p-db-num
    :
        delete ub.user-menu-group.
    end.
    for each ub.user-menu-group-attr exclusive-lock  where
             ub.user-menu-group-attr.db-num <> p-db-num
      :
        delete ub.user-menu-group-attr.
    end.
    for each ub.action-role           exclusive-lock  where
             ub.action-role.db-num <> p-db-num           :
             delete ub.action-role.
    end.
    for each ub.action-role-attr      exclusive-lock  where
             ub.action-role-attr.db-num <> p-db-num      :
             delete ub.action-role-attr.
    end.
    for each ub.action-role-item      exclusive-lock  where
             ub.action-role-item.db-num <> p-db-num      :
             delete ub.action-role-item.
    end.
    for each ub.action-role-item-attr exclusive-lock  where
             ub.action-role-item-attr.db-num <> p-db-num :
             delete ub.action-role-item-attr.
    end.
    for each ub.user-login-action-item exclusive-lock   where
             ub.user-login-action-item.db-num =  p-db-num
    :
              ub.user-login-action-item.db-num = 0.
    end.
    for each ub.user-login-action-item-attr exclusive-lock   where
             ub.user-login-action-item-attr.db-num = p-db-num
    :
              ub.user-login-action-item-attr.db-num = 0.
    end.
    for each ub.user-login-action-role exclusive-lock   where
             ub.user-login-action-role.db-num = p-db-num
    :
              ub.user-login-action-role.db-num = 0.
    end.
    for each ub.user-login-action-role-attr exclusive-lock   where
             ub.user-login-action-role-attr.db-num = p-db-num
    :
              ub.user-login-action-role-attr.db-num = 0 .
    end.
    for each ub.user-login-attr exclusive-lock  where
             ub.user-login-attr.db-num = p-db-num
      :
             ub.user-login-attr.db-num = 0 .
    end.
    for each ub.user-menu-group exclusive-lock  where
             ub.user-menu-group.db-num = p-db-num
    :
        ub.user-menu-group.db-num = 0.
    end.
    for each ub.user-menu-group-attr exclusive-lock  where
             ub.user-menu-group-attr.db-num = p-db-num
      :
        ub.user-menu-group-attr.db-num = 0.
    end.
    for each ub.action-role           exclusive-lock  where
             ub.action-role.db-num = p-db-num           :
             ub.action-role.db-num            = 0 .
    end.
    for each ub.action-role-attr      exclusive-lock  where
             ub.action-role-attr.db-num = p-db-num      :
             ub.action-role-attr.db-num       = 0 .
    end.
    for each ub.action-role-item      exclusive-lock  where
             ub.action-role-item.db-num = p-db-num      :
             ub.action-role-item.db-num       = 0 .
    end.
    for each ub.action-role-item-attr exclusive-lock  where
             ub.action-role-item-attr.db-num = p-db-num :
             ub.action-role-item-attr.db-num = 0 .
    end.
    for each ub.user-host exclusive-lock  where
             ub.user-host.db-num = p-db-num :
             ub.user-host.db-num = 0 .
    end.
    for each ub.user-host-attr exclusive-lock  where
             ub.user-host-attr.db-num = p-db-num :
             ub.user-host-attr.db-num = 0 .
    end.
    for each ub.user-obj exclusive-lock  where
             ub.user-obj.db-num = p-db-num :
             ub.user-obj.db-num = 0 .
    end.
    for each ub.user-obj-attr exclusive-lock  where
             ub.user-obj-attr.db-num = p-db-num :
             ub.user-obj-attr.db-num = 0 .
    end.
end.
