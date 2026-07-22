block-level on error undo, throw.
using ibs.th.gbl.gbl-hndllib from propath.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека  процедур".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)Workfile: str-glbt.p Revision ".
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-obj-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-obj.node-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-min-increase like ub.gds-grp-obj.min-increase  no-undo.
define input parameter p-max-increase like ub.gds-grp-obj.max-increase  no-undo.
define input parameter p-increase-pc like ub.gds-grp-obj.increase-pc  no-undo.
define input parameter p-calc-method like ub.gds-grp-obj.calc-method no-undo .
define input parameter p-round-method like ub.gds-grp-obj.round-method no-undo .
define input parameter p-round-coef like ub.gds-grp-obj.round-coef no-undo .
define input parameter p-cli-type   like ub.clients.obj-type            no-undo.
define input parameter p-cli-code   like ub.clients.obj-code            no-undo.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
    find first buf_gds-grp-obj exclusive-lock
         where buf_gds-grp-obj.node-code  = p-node-code
           and buf_gds-grp-obj.host-code  = p-host-code
           and buf_gds-grp-obj.obj-type   = p-obj-type
           and buf_gds-grp-obj.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-obj
    then do:
        create buf_gds-grp-obj.
        assign
                buf_gds-grp-obj.node-code  = p-node-code
                buf_gds-grp-obj.host-code  = p-host-code
                buf_gds-grp-obj.obj-type   = p-obj-type
                buf_gds-grp-obj.obj-code   = p-obj-code
        .
    end.
    assign
    buf_gds-grp-obj.min-increase = p-min-increase
    buf_gds-grp-obj.max-increase = p-max-increase
    buf_gds-grp-obj.increase-pc = p-increase-pc
    buf_gds-grp-obj.calc-method = p-calc-method
    buf_gds-grp-obj.round-method = p-round-method
    buf_gds-grp-obj.round-coef = p-round-coef
    buf_gds-grp-obj.cli-type   = p-cli-type
    buf_gds-grp-obj.cli-code   = p-cli-code
    .
end.
end procedure.
procedure grp-obj-margin-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-min-value as decimal      no-undo init ?.
define output parameter p-max-value as decimal      no-undo init ?.
define output parameter p-increase-pc as decimal      no-undo init ?.
define output parameter p-round-method as character no-undo init "":U.
define output parameter p-base as decimal no-undo init ?.
define output parameter p-range-margin     as integer      no-undo.
define output parameter p-exists-margin    as logical      no-undo.
define output parameter p-range-increase     as integer      no-undo.
define output parameter p-exists-increase    as logical      no-undo.
define output parameter p-range-rmethod     as integer no-undo .
define output parameter p-exists-rmethod    as logical no-undo .
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-margin-found as logical no-undo .
DEFINE VARIABLE v-increase-found as logical no-undo .
DEFINE VARIABLE v-min-value as decimal      no-undo.
DEFINE VARIABLE v-max-value as decimal      no-undo.
DEFINE VARIABLE v-increase-pc as decimal      no-undo.
define variable v-round-method as character no-undo .
define variable v-base as decimal no-undo .
define variable v-print-code as character no-undo .
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
if p-obj-type <> '' then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description
        skip "Не удалось найти фирму объекта"
        skip p-obj-type p-obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
      view-as alert-box error.
      undo, return error .
  end.
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-min-value    = buf_gds-grp-obj.min-increase
    v-max-value    = buf_gds-grp-obj.max-increase
    v-increase-pc  = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    .
    assign
    p-exists-margin = (if v-min-value <> ? and v-max-value <> ? and p-min-value = ?
                        then yes
                        else p-exists-margin)
    p-range-margin = if p-exists-margin and p-min-value = ?
                      then v-range
                      else p-range-margin
    p-min-value   =  if p-exists-margin and  p-min-value = ?
                      then v-min-value
                      else p-min-value
    p-max-value   =  if p-exists-margin and  p-max-value = ?
                      then v-max-value
                      else p-max-value
    p-exists-increase = (if v-increase-pc <> ? and p-increase-pc = ?
                        then yes
                        else p-exists-increase)
    p-range-increase = if p-exists-increase and p-increase-pc = ?
                      then v-range
                      else p-range-increase
    p-increase-pc = (if p-exists-increase and p-increase-pc = ?
                      then v-increase-pc
                      else p-increase-pc)
    p-exists-rmethod = if v-round-method <> "":U and p-round-method = "":U
                        then yes
                        else p-exists-rmethod
    p-range-rmethod = (if p-exists-rmethod and p-round-method = "":U
                        then v-range
                        else p-range-rmethod)
    p-round-method  = (if p-exists-rmethod and p-round-method = "":U
                        then v-round-method
                        else p-round-method)
    p-base          = (if p-exists-rmethod and p-base = ?
                        then v-base
                        else p-base)
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
procedure grp-obj-income-cli-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-cli-type as character    no-undo init ?.
define output parameter p-cli-code as integer      no-undo init ?.
define output parameter p-range-income-cli     as integer      no-undo.
define output parameter p-exists-income-cli    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-income-cli-found as logical no-undo .
DEFINE VARIABLE v-cli-type-value as char      no-undo.
DEFINE VARIABLE v-cli-code-value as int      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-cli-type-value    = buf_gds-grp-obj.cli-type
    v-cli-code-value    = buf_gds-grp-obj.cli-code
    .
    assign
    p-exists-income-cli = (if v-cli-type-value <> ? and v-cli-code-value <> ? and p-cli-type = ?
                        then yes
                        else p-exists-income-cli)
    p-range-income-cli = if p-exists-income-cli and p-cli-type = ?
                      then v-range
                      else p-range-income-cli
    p-cli-type   =  if p-exists-income-cli and  p-cli-type = ?
                      then v-cli-type-value
                      else p-cli-type
    p-cli-code   =  if p-exists-income-cli and  p-cli-code = ?
                      then v-cli-code-value
                      else p-cli-code
    v-found =  (p-exists-income-cli ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-income-cli  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile: frmlib.i $ $Revision: aea5316774be, 0, rls $".
FUNCTION Break-n-line RETURNS CHARACTER
  ( INPUT p-ost as char,
    INPUT p-lengths  as character,
    OUTPUT output-num-lines as integer
    ) :
define variable ii as integer no-undo.
define variable jj as integer no-undo.
define variable linei as character no-undo extent 10.
define variable line-length as integer no-undo extent 10.
define variable num-line as integer no-undo .
define variable v-line as character no-undo .
do ii = 1 to MIN(num-entries(p-lengths), 10):
  assign
  line-length[ii] = integer(entry(ii, p-lengths))
  num-line = ii
  .
end.
do jj = 1 to num-line:
  if Length ( p-ost ) <= line-length[jj] then do:
    assign
    output-num-lines = jj
    v-line = v-line + (if jj = 1 then "":U else chr(4)) + p-ost
    .
    return v-line.
  end.
  assign
  ii = 1
  .
  if length( entry( ii, p-ost , chr(32)) ) > line-length[jj]
  then do:
    assign
    linei[jj] = substr( p-ost , 1 , line-length[jj] )
    p-ost = trim( substr( p-ost , line-length[jj] + 1 ) )
    .
  end.
  else do:
    DO WHILE length( linei[jj] + entry( ii, p-ost , chr(32)) ) < ( line-length[jj] + 1 ) :
      assign
      linei[jj] = linei[jj] + entry( ii, p-ost , chr(32)) + chr(32)
      ii = ii + 1
      .
      if length( entry( ii, p-ost, chr(32) ) ) > line-length[jj] then
      assign
      linei[jj] = linei[jj] + substr( p-ost , length( linei[jj] ) , line-length[jj] - length( linei[jj] ) + 1 )
      .
    END.
    assign
    p-ost = trim( substr( p-ost , length(linei[jj]) + 1  ))
    .
  end.
  assign
  v-line = v-line + (if jj = 1 then "":U else chr(4)) + linei[jj]
  .
  if p-ost = "":U then LEAVE.
end.
assign
output-num-lines = jj.
RETURN v-line.
END FUNCTION.
FUNCTION Center-Field RETURNS CHARACTER
  ( INPUT p-str as char,
    INPUT p-format as integer,
    INPUT p-Length as integer,
    INPUT p-fill as character
    ) :
define variable v-str as character no-undo .
define variable v-left as integer no-undo .
define variable v-dop as integer no-undo .
assign
p-str = trim(p-str)
.
if p-str = "":U then return fill(p-fill, p-length).
if length(p-str) >= p-format then
p-str = substr(p-str, 1, p-format).
else do:
  p-format = length(p-str).
end.
if p-format < p-length then do:
  assign
  v-left = (p-length - p-format )
  v-dop = (if v-left modulo 2 = 1
           then 1
           else 0)
  v-left = (if (v-left modulo 2 = 1)
           then (v-left - 1 ) / 2
           else v-left / 2)
  v-str =  fill(p-fill, v-left) +
           string(p-str, "X(":U + string(p-format) + ")":U) +
           fill(p-fill, v-left) + fill(p-fill, v-dop)
  .
  return v-str.
end.
else do:
  return string(p-str, "X(":U + string(p-length) + ")":U).
end.
END FUNCTION.
FUNCTION Left-Field RETURNS CHARACTER
  ( INPUT p-str as char,
    INPUT p-format as integer,
    INPUT p-Length as integer,
    INPUT p-fill as character
    ) :
define variable v-str as character no-undo .
define variable v-left as integer no-undo .
define variable v-dop as integer no-undo .
assign
p-str = trim(p-str)
.
if p-str = "":U then return fill(p-fill, p-length).
if length(p-str) >= p-format then
p-str = substr(p-str, 1, p-format).
else do:
  p-format = length(p-str).
end.
if p-format < p-length then do:
  assign
  v-dop =  p-length - p-format
  v-str =  string(p-str, "X(":U + string(p-format) + ")":U) +
           fill(p-fill, v-dop)
  .
  return v-str.
end.
else do:
  return string(p-str, "X(":U + string(p-length) + ")":U).
end.
END FUNCTION.
FUNCTION Sum-Rub-Kop-Digit RETURNS CHARACTER
  ( INPUT p-sum as decimal,
    INPUT p-rub-length as integer,
    INPUT p-kop-length as integer,
    INPUT p-fill as character,
    INPUT p-razr-delim as character,
    INPUT p-rub-str  as character,
    INPUT p-kop-str  as character
    ) :
define variable v-str as character no-undo .
define variable v-format as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-dopi2 as integer no-undo .
assign
v-dopi = length(string(truncate(ABS(p-sum), 0)))
v-dopi2 = truncate(v-dopi / 3, 0) - (if v-dopi modulo  3 = 0 then 1 else 0)
.
if v-dopi > p-rub-length or p-kop-length < 2 then return "?".
assign
v-format = (if p-sum < 0 then "-":U else "":U) + fill((">>>":U + p-razr-delim), v-dopi2) + ">>9":U
v-dopi = length(trim(string(truncate(p-sum, 0), v-format)))
.
assign
v-str = fill(p-fill, p-rub-length - v-dopi) +
        string(truncate(p-sum, 0), v-format) +
        p-rub-str +
        fill(p-fill, p-kop-length - 2) +
        string(truncate((ABS(p-sum) - ABS(truncate(p-sum, 0))), 2) * 100, "99":U) + p-kop-str
.
return v-str.
END FUNCTION.
FUNCTION Sum-Invalut-Digit RETURNS CHARACTER
  ( INPUT p-sum as decimal,
    INPUT p-sum-length as integer,
    INPUT p-curr-code as integer,
    INPUT p-fill as character,
    INPUT p-razr-delim as character
    ) :
define variable v-str as character no-undo .
define variable v-format as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-curr-name as character no-undo .
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
          buf_currency.curr-code = p-curr-code no-error .
if not avail buf_currency
then v-curr-name = "неизвестная валюта".
else
assign
v-curr-name = buf_currency.curr-name
.
assign
v-dopi = length(string(truncate(ABS(p-sum), 0)))
v-dopi2 = truncate(v-dopi / 3, 0) - (if v-dopi modulo  3 = 0 then 1 else 0)
.
if v-dopi > p-sum-length then return "?".
assign
v-format = (if p-sum < 0 then "-":U else "":U) + fill((">>>":U + p-razr-delim), v-dopi2) + ">>9.99":U
v-dopi = length(trim(string(p-sum, v-format)))
.
assign
v-str = "(":U + chr(32) + v-curr-name +  chr(32) + ")":U +
        fill(p-fill, p-sum-length - v-dopi - length(v-curr-name) - 4)  +
        trim(string(p-sum, v-format))
.
return v-str.
END FUNCTION.
FUNCTION Sum-in-Words-Without-Dec RETURNS CHARACTER
(input v-sum as decimal
):
define variable v-str as character no-undo .
run gbl/num-rus.p ( input absolute( v-sum ) , output v-str).
v-str = trim( caps( substring( v-str, 1, 1 ) ) ) + substring( v-str, 2 ).
return v-str.
END FUNCTION.
FUNCTION Sum-in-Words-Invalut RETURNS CHARACTER
(input p-sum as decimal
 ,input p-curr-code as integer
):
define variable v-str as character no-undo .
define variable Copeck as character no-undo.
define variable Rouble as character no-undo.
define variable v-Word as character no-undo.
define variable ii as integer init 18 no-undo.
define variable v-str-rubl as character no-undo .
define variable v-kop as integer no-undo .
define buffer buf_currency for ub.currency.
assign
v-Word = string( absolute( p-sum ) , "999999999999999.99" ).
find first buf_currency no-lock where
          buf_currency.curr-code = p-curr-code no-error .
if not available buf_currency then return chr(63).
if decimal( substring(v-Word,1,ii - 3) ) <> 0 then do:
  CASE substring(v-Word, ii - 3,1):
    WHEN "1" THEN DO:
      if substring(v-Word, ii - 4,1) = "1" then
          Rouble = buf_currency.curr-name-five .
      else
          Rouble = buf_currency.curr-name-one .
    END.
    WHEN "2" OR WHEN "3" OR WHEN "4" THEN  DO:
      if substring(v-Word, ii - 4,1) = "1" then
         Rouble = buf_currency.curr-name-five .
         else
         Rouble = buf_currency.curr-name-three .
      END.
    WHEN "0" OR WHEN "5" OR WHEN "6" OR WHEN "7" OR WHEN "8" OR WHEN "9" THEN  DO:
       Rouble = buf_currency.curr-name-five .
    END.
  END CASE.
end.
CASE substring(v-Word, ii, 1):
  WHEN "1" THEN DO:
    if substring(v-Word, ii - 1, 1) = "1" then
        Copeck = buf_currency.part-name-five .
    else
        Copeck = buf_currency.part-name-one .
  END.
  WHEN "2" OR WHEN "3" OR WHEN "4" THEN DO:
    if substring(v-Word, ii - 1, 1) = "1" then
        Copeck = buf_currency.part-name-five .
    else
        Copeck = buf_currency.part-name-three .
  END.
  WHEN "0" OR WHEN "5" OR WHEN "6" OR WHEN "7" OR WHEN "8" OR WHEN "9" THEN DO:
    Copeck = buf_currency.part-name-five .
  END.
END CASE.
run gbl/num-rus.p ( input absolute( p-sum )
             , output v-str-rubl).
assign
v-kop = (absolute( p-sum ) - truncate(absolute(p-sum), 0)
        ) * 100
.
v-str = ( if p-Sum < 0 then "- " else "" ) +
            caps(substring(v-str-rubl, 1, 1)) +  substring(v-str-rubl, 2) + chr(32) + Rouble + chr(32) +
            string(v-kop, "99":U) + chr(32) + Copeck .
return v-str.
END FUNCTION.
FUNCTION Sum-delim-with-defis RETURNS CHARACTER
(input v-sum as decimal,
input v-razr as integer
):
define variable v-str as character no-undo .
define variable v-dec-separ as character no-undo .
case SESSION:NUMERIC-FORMAT:
  when "American":U then do:
    assign
    v-dec-separ = ".":U
    .
  end.
  when "European":U then do:
    assign
    v-dec-separ = ",":U
    .
  end.
END CASE.
assign
v-str = replace(string(v-sum, fill(">":U, v-razr - 1) + "9.99"), v-dec-separ, "-":U)
.
return v-str.
END FUNCTION.
FUNCTION MonthNameRusGen RETURNS CHARACTER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
  RUN get-month-name-gen IN THIS-PROCEDURE ( INPUT i-month, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION.
PROCEDURE get-month-name-gen :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO INITIAL "Января,Февраля,Марта,Апреля,Мая,Июня,Июля,Августа,Сентября,Октября,Ноября,Декабря".
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-name = ( IF p-month >= 1 AND p-month <= 12 THEN ENTRY( p-month, v-list ) ELSE ? ).
  END.
END PROCEDURE.
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info7 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info7, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info7, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info7 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info7, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info7, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info7, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info7, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info7, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info7, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info7 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info7, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info7 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
if valid-handle (g#attr-lib)
and g#attr-lib <> this-procedure :handle
and g#attr-lib :get-signature('attr-lib_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#attr-lib skip
    g#attr-lib :type skip
    g#attr-lib :file-name skip
    valid-handle(g#attr-lib) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#attr-lib = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#attr-lib", g#attr-lib).
  delete object gbl-hndllibObj.
end.
if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.
on delete of this-procedure
do:
  assign
    g#attr-lib = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#attr-lib", g#attr-lib).
  delete object gbl-hndllibObj.
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
end.
procedure attr-lib_testproc :
end.
procedure clntattr-code :
  do
  on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'doc-start':U then do:     assign     p-label = "Дата с которой существуют документы"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'arh-detail':U then do:     assign     p-label = "Дата начала подробного складского архива по товарам"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'arh-start':U then do:     assign     p-label = "Дата начала сжатого складского архива по товарам"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ahsp-detail':U then do:     assign     p-label = "Дата начала подробного складского архива по поставщикам"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ahsp-start':U then do:     assign     p-label = "Дата начала сжатого складского архива по поставщикам"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'aht-detail':U then do:     assign     p-label = "Дата начала подробного складского архива по типам приобретения"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'aht-start':U then do:     assign     p-label = "Дата начала сжатого складского архива по типам приобретения"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'arh-del':U then do:     assign     p-label = "Удаление складского архива по товарам прошло с ошибкой"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ahsp-del':U then do:     assign     p-label = "Удаление складского архива по поставщикам прошло с ошибкой"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'aht-del':U then do:     assign     p-label = "Удаление складского архива по типам приобретения прошло с ошибкой"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'arh-disable':U then do:     assign     p-label = "Расчет складского архива по товарам запрещен"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ahsp-disable':U then do:     assign     p-label = "Расчет складского архива по поставщикам запрещен "     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'aht-disable':U then do:     assign     p-label = "Расчет складского архива по типам приобретения запрещен"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'arh-calc':U then do:     assign     p-label = "Первоначальный расчет складского архива по товарам"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ahsp-calc':U then do:     assign     p-label = "Первоначальный расчет складского архива по поставщикам"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'aht-calc':U then do:     assign     p-label = "Первоначальный расчет складского архива по типам приобретения"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'arh-rest':U then do:     assign     p-label = "Восстановление архива по товарам прошло с ошибкой"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ahsp-rest':U then do:     assign     p-label = "Восстановление архива по поставщикам прошло с ошибкой"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'aht-rest':U then do:     assign     p-label = "Восстановлением архива по типам приобретения прошло с ошибкой"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'arh-recalc':U then do:     assign     p-label = "Дата перерасчёта складского архива по товарам"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ahsp-recalc':U then do:     assign     p-label = "Дата перерасчёта складского архива по поставщикам"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'aht-recalc':U then do:     assign     p-label = "Дата перерасчёта складского архива по типам приобретения"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'is-inkassator':U then do:     assign     p-label = "Организация-инкассатор"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'shftrep2':U then do:     assign     p-label = "РАСХОДЫ отдельной строкой"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'db':U then do:     assign     p-label = "Привязка к БД"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'is-superviser':U then do:     assign     p-label = "Супервайзер"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'purch-code':U then do:     assign     p-label = "Тип приобретения"     p-type = 'I':U      p-format = "9"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'als-gds':U then do:     assign     p-label = "Торговля чужим товаром"     p-type = 'L':U      p-format = "yes/no"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'alien':U then do:     assign     p-label = "ЧУЖАЯ фирма/клиент"     p-type = 'L':U      p-format = "yes/no"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'envd':U then do:     assign     p-label = "ЕНВД"     p-type = 'L':U      p-format = "yes/no"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'kpp':U then do:     assign     p-label = "КПП"     p-type = 'C':U      p-format = "X(20)"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'pharm':U then do:     assign     p-label = "Аптека"     p-type = 'L':U      p-format = "yes/no"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'upd-date-time':U then do:     assign     p-label = "Актуальность информации"     p-type = 'C':U      p-format = "X(19)"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'holdfirm-code':U then do:     assign     p-label = "Код фирмы для печати накладных"     p-type = 'I':U      p-format = ">>>>>9"     p-user-can-edit  = false     p-output-display = false     p-other = '':U      .   end.
            when 'arh-trn-doc-contract':U then do:     assign     p-label = "Неправильные архивы arh-trn-doc-contract по объекту"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = true     p-other = '':U      .   end.
            when 'vat-register':U then do:     assign     p-label = "Свидетельство о постановке на учет по НДС(Каз.)"     p-type = 'C':U      p-format = "X(24)"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=clntattr-vat-register':u      .   end.
            when 'bge-incr-last-shift-date':U then do:     assign     p-label = "Дата последней выгруженной смены"     p-type = 'C':U      p-format = "X(13)"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'bge-incr-last-shift-num':U then do:     assign     p-label = "Порядок последней выгруженной смены"     p-type = 'C':U      p-format = "X(13)"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'bge-incr-cur':U then do:     assign     p-label = "Выгружается ли смена в данный момент"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'bge-sap-sng-last-shift':U then do:     assign     p-label = "Дата последней выгруженной смены"     p-type = 'C':U      p-format = "X(13)"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'bge-exp-last-atd':U then do:     assign     p-label = "Дата и номер последней выгруженной смены в систему АТД "     p-type = 'C':U      p-format = "X(20)"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'bge-exp-malina-last-shift':U then do:     assign     p-label = "Дата и номер последней выгруженной смены в формате Малины"     p-type = 'C':U      p-format = "X(13)"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'egrip-date':U then do:     assign     p-label = "Дата ЕГРИП"     p-type = 'C':U      p-format = "X(13)"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'egrip-num':U then do:     assign     p-label = "Номер ЕГРИП"     p-type = 'C':U      p-format = "X(15)"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'fbr-pay-code':U then do:     assign     p-label = "Код оплаты для производства"     p-type = 'I':U      p-format = ">>>>>9"     p-user-can-edit  = false     p-output-display = false     p-other = '':U      .   end.
            when 'cargo-from':U then do:     assign     p-label = "Грузоотправитель"     p-type = 'C':U      p-format = "X(256)"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'cargo-to':U then do:     assign     p-label = "Грузополучатель"     p-type = 'C':U      p-format = "X(256)"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'cli-local':U then do:     assign     p-label = "Местный клиент"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'cli-alc-producer':U then do:     assign     p-label = "Производитель алкогольной продукции"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'region-code':U then do:     assign     p-label = "Код региона"     p-type = 'I':U      p-format = ">9"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'foreign-producer':U then do:     assign     p-label = "Импортный производитель"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'main-accholder':U then do:     assign     p-label = "Контрагент - держатель основного счета"     p-type = 'C':U      p-format = "X(12)"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=clntattr-main-accholder':u      .   end.
            when 'not-corr-op':U then do:     assign     p-label = "Обязателен авторасчет заказов ОП.Запрет на корректировку автоматич. рассчитанных заказов"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'veto-man-doc':U then do:     assign     p-label = "Запрет на созд. оператором док-тов для контрагента"     p-type = 'C':U      p-format = "X(255)"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=clntattr-veto-man-doc':u      .   end.
            when 'requisite-alc-decl':U then do:     assign     p-label = "Реквизиты для алкогольной декларации"     p-type = 'C':U      p-format = "X(255)"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=clntattr-requisite-alc-decl':u      .   end.
            when 'division-code':U then do:     assign     p-label = "Код подразделения"     p-type = 'I':U      p-format = ">>>>9"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'supp-np':U then do:     assign     p-label = "Поставщик НП"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'own-supp':U then do:     assign     p-label = "Собственный поставщик"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'supp-lgas':U then do:     assign     p-label = "Поставщик СУГ"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'tank-farm-for':U then do:     assign     p-label = "Является нефтебазой/ГНС для:"     p-type = 'C':U      p-format = "X(255)"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=clntattr-tank-farm-for':u      .   end.
            when 'NPZ':U then do:     assign     p-label = "Нефтеперерабатывающий завод"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'code-KSK':U then do:     assign     p-label = "Код КСК"     p-type = 'C':U      p-format = "X(256)"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'code-AIS':U then do:     assign     p-label = "Код АИС"     p-type = 'C':U      p-format = "X(256)"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'auto-tank-for':U then do:     assign     p-label = "Является перевозчиком для:"     p-type = 'C':U      p-format = "X(255)"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=clntattr-auto-tank-for':u      .   end.
            when 'owner-code':U then do:     assign     p-label = "Код ПНПО-владельца"     p-type = 'C':U      p-format = "X(255)"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=clntattr-owner-code':u      .   end.
            when 'cli-for-close-fo':U then do:     assign     p-label = "Список юр.лиц, платежами которых можно закрывать ФО:"     p-type = 'C':U      p-format = "X(255)"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=clntattr-cli-for-close-fo':u      .   end.
            when 'cli-clim-grp':U then do:     assign     p-label = "Климатическая группа:"     p-type = 'C':U      p-format = "X(21)"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=clntattr-cli-clim-grp':u      .   end.
            when 'cli-decommissioned':U then do:     assign     p-label = "Выведен из эксплуатации"     p-type = 'L':U      p-format = "+/"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'atd-alarm-schedule':U then do:     assign     p-label = "Расписание алармов АТД"     p-type = 'C':U      p-format = "X(40)"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'exp-isPM-last-date':U then do:     assign     p-label = "Последняя выгруженная для ИС ПМ дата"     p-type = 'T':U      p-format = "99/99/9999"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  do
  on error undo, return error return-value
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'doc-start':U then do:     assign     p-tooltip = "Дата с которой существуют документы"     p-label = "Дата с которой существуют документы" .   end.
            when 'arh-detail':U then do:     assign     p-tooltip = "Дата начала подробного складского архива по товарам"     p-label = "Дата начала подробного складского архива по товарам" .   end.
            when 'arh-start':U then do:     assign     p-tooltip = "Дата начала сжатого складского архива по товарам"     p-label = "Дата начала сжатого складского архива по товарам" .   end.
            when 'ahsp-detail':U then do:     assign     p-tooltip = "Дата начала подробного складского архива по поставщикам"     p-label = "Дата начала подробного складского архива по поставщикам" .   end.
            when 'ahsp-start':U then do:     assign     p-tooltip = "Дата начала сжатого складского архива по поставщикам"     p-label = "Дата начала сжатого складского архива по поставщикам" .   end.
            when 'aht-detail':U then do:     assign     p-tooltip = "Дата начала подробного складского архива по типам приобретения"     p-label = "Дата начала подробного складского архива по типам приобретения" .   end.
            when 'aht-start':U then do:     assign     p-tooltip = "Дата начала сжатого складского архива по типам приобретения"     p-label = "Дата начала сжатого складского архива по типам приобретения" .   end.
            when 'arh-del':U then do:     assign     p-tooltip = "Удаление складского архива по товарам прошло с ошибкой"     p-label = "Удаление складского архива по товарам прошло с ошибкой" .   end.
            when 'ahsp-del':U then do:     assign     p-tooltip = "Удаление складского архива по поставщикам прошло с ошибкой"     p-label = "Удаление складского архива по поставщикам прошло с ошибкой" .   end.
            when 'aht-del':U then do:     assign     p-tooltip = "Удаление складского архива по типам приобретения прошло с ошибкой"     p-label = "Удаление складского архива по типам приобретения прошло с ошибкой" .   end.
            when 'arh-disable':U then do:     assign     p-tooltip = "Расчет складского архива по товарам запрещен"     p-label = "Расчет складского архива по товарам запрещен" .   end.
            when 'ahsp-disable':U then do:     assign     p-tooltip = "Расчет складского архива по поставщикам запрещен "     p-label = "Расчет складского архива по поставщикам запрещен " .   end.
            when 'aht-disable':U then do:     assign     p-tooltip = "Расчет складского архива по типам приобретения запрещен"     p-label = "Расчет складского архива по типам приобретения запрещен" .   end.
            when 'arh-calc':U then do:     assign     p-tooltip = "Первоначальный расчет складского архива по товарам"     p-label = "Первоначальный расчет складского архива по товарам" .   end.
            when 'ahsp-calc':U then do:     assign     p-tooltip = "Первоначальный расчет складского архива по поставщикам"     p-label = "Первоначальный расчет складского архива по поставщикам" .   end.
            when 'aht-calc':U then do:     assign     p-tooltip = "Первоначальный расчет складского архива по типам приобретени "     p-label = "Первоначальный расчет складского архива по типам приобретения" .   end.
            when 'arh-rest':U then do:     assign     p-tooltip = "Восстановление архива по товарам прошло с ошибкой"     p-label = "Восстановление архива по товарам прошло с ошибкой" .   end.
            when 'ahsp-rest':U then do:     assign     p-tooltip = "Восстановление архива по поставщикам прошло с ошибкой"     p-label = "Восстановление архива по поставщикам прошло с ошибкой" .   end.
            when 'aht-rest':U then do:     assign     p-tooltip = "Восстановлением архива по типам приобретения прошло с ошибкой"     p-label = "Восстановлением архива по типам приобретения прошло с ошибкой" .   end.
            when 'arh-recalc':U then do:     assign     p-tooltip = "Дата перерасчёта складского архива по товарам"     p-label = "Дата перерасчёта складского архива по товарам" .   end.
            when 'ahsp-recalc':U then do:     assign     p-tooltip = "Дата перерасчёта складского архива по поставщикам"     p-label = "Дата перерасчёта складского архива по поставщикам" .   end.
            when 'aht-recalc':U then do:     assign     p-tooltip = "Дата перерасчёта складского архива по типам приобретения"     p-label = "Дата перерасчёта складского архива по типам приобретения" .   end.
            when 'is-inkassator':U then do:     assign     p-tooltip = "Организация-инкассатор"     p-label = "Организация-инкассатор" .   end.
            when 'shftrep2':U then do:     assign     p-tooltip = "Вывод РАСХОДОВ отдельной строкой в листе 2 сменного отчета"     p-label = "РАСХОДЫ отдельной строкой" .   end.
            when 'db':U then do:     assign     p-tooltip = "С клиентом работают в текущей БД"     p-label = "Привязка к БД" .   end.
            when 'is-superviser':U then do:     assign     p-tooltip = "Пользователь с правами супервайзера"     p-label = "Супервайзер" .   end.
            when 'purch-code':U then do:     assign     p-tooltip = "Тип приобретения"     p-label = "Тип приобретения" .   end.
            when 'als-gds':U then do:     assign     p-tooltip = "Торговля чужим товаром"     p-label = "Торговля чужим товаром" .   end.
            when 'alien':U then do:     assign     p-tooltip = "Фирма, товарный учет которой ведется в ДРУГОЙ СИСТЕМЕ TH или клиент, импортированный из ДРУГОЙ СИСТЕМЫ"     p-label = "ЧУЖАЯ фирма/клиент" .   end.
            when 'envd':U then do:     assign     p-tooltip = "Единый налог на вмененный доход"     p-label = "ЕНВД" .   end.
            when 'kpp':U then do:     assign     p-tooltip = "Код причины постановки на учет"     p-label = "КПП" .   end.
            when 'pharm':U then do:     assign     p-tooltip = "Объект работает как АПТЕКА"     p-label = "Аптека" .   end.
            when 'upd-date-time':U then do:     assign     p-tooltip = "Дата и время актуальности информации - при импорте из другой системы"     p-label = "Актуальность информации" .   end.
            when 'holdfirm-code':U then do:     assign     p-tooltip = "Код фирмы для печати накладных - если для объекта задан параметр outhold"     p-label = "Код фирмы для печати накладных" .   end.
            when 'arh-trn-doc-contract':U then do:     assign     p-tooltip = "Неправильные архивы arh-trn-doc-contract по объекту"     p-label = "Неправильные архивы arh-trn-doc-contract по объекту" .   end.
            when 'vat-register':U then do:     assign     p-tooltip = "Свидетельство о постановке на учет по НДС(Каз.)"     p-label = "Свидетельство о постановке на учет по НДС(Каз.)" .   end.
            when 'bge-incr-last-shift-date':U then do:     assign     p-tooltip = "Дата последней выгруженной смены"     p-label = "Дата последней выгруженной смены" .   end.
            when 'bge-incr-last-shift-num':U then do:     assign     p-tooltip = "Порядок последней выгруженной смены"     p-label = "Порядок последней выгруженной смены" .   end.
            when 'bge-incr-cur':U then do:     assign     p-tooltip = "Выгружается ли смена в данный момент"     p-label = "Выгружается ли смена в данный момент" .   end.
            when 'bge-sap-sng-last-shift':U then do:     assign     p-tooltip = "Дата последней выгруженной смены"     p-label = "Дата последней выгруженной смены" .   end.
            when 'bge-exp-last-atd':U then do:     assign     p-tooltip = "Дата и номер последней выгруженной смены в систему АТД "     p-label = "Дата и номер последней выгруженной смены в систему АТД " .   end.
            when 'bge-exp-malina-last-shift':U then do:     assign     p-tooltip = "Дата и номер последней выгруженной смены в формате Малины"     p-label = "Дата и номер последней выгруженной смены в формате Малины" .   end.
            when 'egrip-date':U then do:     assign     p-tooltip = "Дата ЕГРИП"     p-label = "Дата ЕГРИП" .   end.
            when 'egrip-num':U then do:     assign     p-tooltip = "Номер ЕГРИП"     p-label = "Номер ЕГРИП" .   end.
            when 'fbr-pay-code':U then do:     assign     p-tooltip = "Код оплаты для производства"     p-label = "Код оплаты для производства" .   end.
            when 'cargo-from':U then do:     assign     p-tooltip = "Грузоотправитель"     p-label = "Грузоотправитель" .   end.
            when 'cargo-to':U then do:     assign     p-tooltip = "Грузополучатель"     p-label = "Грузополучатель" .   end.
            when 'cli-local':U then do:     assign     p-tooltip = "Местный клиент"     p-label = "Местный клиент" .   end.
            when 'cli-alc-producer':U then do:     assign     p-tooltip = "Производитель алкогольной продукции"     p-label = "Производитель алкогольной продукции" .   end.
            when 'region-code':U then do:     assign     p-tooltip = "Код региона"     p-label = "Код региона" .   end.
            when 'foreign-producer':U then do:     assign     p-tooltip = "Импортный производитель"     p-label = "Импортный производитель" .   end.
            when 'main-accholder':U then do:     assign     p-tooltip = "Контрагент - держатель основного счета"     p-label = "Контрагент - держатель основного счета" .   end.
            when 'not-corr-op':U then do:     assign     p-tooltip = "Обязателен авторасчет заказов ОП.Запрет на корректировку автоматич. рассчитанных заказов ОП"     p-label = "Обязателен авторасчет заказов ОП.Запрет на корректировку автоматич. рассчитанных заказов" .   end.
            when 'veto-man-doc':U then do:     assign     p-tooltip = "Запрет на созд. оператором док-тов для данного контрагента"     p-label = "Запрет на созд. оператором док-тов для контрагента" .   end.
            when 'requisite-alc-decl':U then do:     assign     p-tooltip = "Реквизиты для алкогольной декларации"     p-label = "Реквизиты для алкогольной декларации" .   end.
            when 'division-code':U then do:     assign     p-tooltip = "Код подразделени "     p-label = "Код подразделения" .   end.
            when 'supp-np':U then do:     assign     p-tooltip = "Поставщик НП"     p-label = "Поставщик НП" .   end.
            when 'own-supp':U then do:     assign     p-tooltip = "Собственный поставщик"     p-label = "Собственный поставщик" .   end.
            when 'supp-lgas':U then do:     assign     p-tooltip = "Поставщик СУГ"     p-label = "Поставщик СУГ" .   end.
            when 'tank-farm-for':U then do:     assign     p-tooltip = "Является нефтебазой/ГНС для:"     p-label = "Является нефтебазой/ГНС для:" .   end.
            when 'NPZ':U then do:     assign     p-tooltip = "Нефтеперерабатывающий завод"     p-label = "Нефтеперерабатывающий завод" .   end.
            when 'code-KSK':U then do:     assign     p-tooltip = "Код КСК"     p-label = "Код КСК" .   end.
            when 'code-AIS':U then do:     assign     p-tooltip = "Код АИС"     p-label = "Код АИС" .   end.
            when 'auto-tank-for':U then do:     assign     p-tooltip = "Является перевозчиком для:"     p-label = "Является перевозчиком для:" .   end.
            when 'owner-code':U then do:     assign     p-tooltip = "Код ПНПО-владельца"     p-label = "Код ПНПО-владельца" .   end.
            when 'cli-for-close-fo':U then do:     assign     p-tooltip = "Список юр.лиц, платежами которых можно закрывать ФО:"     p-label = "Список юр.лиц, платежами которых можно закрывать ФО:" .   end.
            when 'cli-clim-grp':U then do:     assign     p-tooltip = "Климатическая группа:"     p-label = "Климатическая группа:" .   end.
            when 'cli-decommissioned':U then do:     assign     p-tooltip = "Выведен из эксплуатации"     p-label = "Выведен из эксплуатации" .   end.
            when 'atd-alarm-schedule':U then do:     assign     p-tooltip = "Интервал повторения для алармов на воду и уровень АТД"     p-label = "Расписание алармов АТД" .   end.
            when 'exp-isPM-last-date':U then do:     assign     p-tooltip = "Последняя выгруженная для ИС ПМ дата"     p-label = "Последняя выгруженная для ИС ПМ дата" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure clntattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define output parameter p-value    like ub.clients-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_clients-attr for ub.clients-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run clntattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_clients-attr no-lock
      where buf_clients-attr.obj-type  = p-obj-type
        and buf_clients-attr.obj-code  = p-obj-code
        and buf_clients-attr.attr-code = p-code
      no-error .
    if avail buf_clients-attr then do:
      assign
        p-value =  buf_clients-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure clntattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define input parameter p-value    like ub.clients-attr.attr-value no-undo .
    define buffer buf_clients-attr for ub.clients-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run clntattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_clients-attr exclusive-lock
      where buf_clients-attr.obj-type  = p-obj-type
        and buf_clients-attr.obj-code  = p-obj-code
        and buf_clients-attr.attr-code = p-code
      no-error .
    if not available buf_clients-attr then do:
      create buf_clients-attr .
      assign
        buf_clients-attr.obj-type  = p-obj-type
        buf_clients-attr.obj-code  = p-obj-code
        buf_clients-attr.attr-code = p-code
      .
    end.
    assign
      buf_clients-attr.attr-value = p-value
    .
    release buf_clients-attr no-error.
    if error-status:error then do:
      return error substitute("Ошибка при сохранение атрибута &1 клиента &2&3: &4 &5"
                             , p-code
                             , p-obj-type
                             , p-obj-code
                             , error-status:get-message(1)
                             , return-value ).
    end.
  end.
end procedure.
procedure clntattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_clients-attr for ub.clients-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run clntattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_clients-attr no-lock
      where buf_clients-attr.obj-type  = p-obj-type
        and buf_clients-attr.obj-code  = p-obj-code
        and buf_clients-attr.attr-code = p-code
      no-error .
    if  available buf_clients-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure clntattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_clients-attr for ub.clients-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run clntattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_clients-attr exclusive-lock
      where buf_clients-attr.obj-type  = p-obj-type
        and buf_clients-attr.obj-code  = p-obj-code
        and buf_clients-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_clients-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_clients-attr no-error .
      if error-status:error then do:
        return error substitute("Ошибка при удалении атрибута &1 клиента &2&3: &4 &5"
                              , p-code
                              , p-obj-type
                              , p-obj-code
                              , error-status:get-message(1)
                              , return-value ).
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure clntattr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'doc-start':U then do:     assign     p-news = false.   end.
            when 'arh-detail':U then do:     assign     p-news = false.   end.
            when 'arh-start':U then do:     assign     p-news = false.   end.
            when 'ahsp-detail':U then do:     assign     p-news = false.   end.
            when 'ahsp-start':U then do:     assign     p-news = false.   end.
            when 'aht-detail':U then do:     assign     p-news = false.   end.
            when 'aht-start':U then do:     assign     p-news = false.   end.
            when 'arh-del':U then do:     assign     p-news = false.   end.
            when 'ahsp-del':U then do:     assign     p-news = false.   end.
            when 'aht-del':U then do:     assign     p-news = false.   end.
            when 'arh-disable':U then do:     assign     p-news = false.   end.
            when 'ahsp-disable':U then do:     assign     p-news = false.   end.
            when 'aht-disable':U then do:     assign     p-news = false.   end.
            when 'arh-calc':U then do:     assign     p-news = false.   end.
            when 'ahsp-calc':U then do:     assign     p-news = false.   end.
            when 'aht-calc':U then do:     assign     p-news = false.   end.
            when 'arh-rest':U then do:     assign     p-news = false.   end.
            when 'ahsp-rest':U then do:     assign     p-news = false.   end.
            when 'aht-rest':U then do:     assign     p-news = false.   end.
            when 'arh-recalc':U then do:     assign     p-news = false.   end.
            when 'ahsp-recalc':U then do:     assign     p-news = false.   end.
            when 'aht-recalc':U then do:     assign     p-news = false.   end.
            when 'is-inkassator':U then do:     assign     p-news = true.   end.
            when 'shftrep2':U then do:     assign     p-news = true.   end.
            when 'db':U then do:     assign     p-news = false.   end.
            when 'is-superviser':U then do:     assign     p-news = true.   end.
            when 'purch-code':U then do:     assign     p-news = true.   end.
            when 'als-gds':U then do:     assign     p-news = true.   end.
            when 'envd':U then do:     assign     p-news = true.   end.
            when 'kpp':U then do:     assign     p-news = true.   end.
            when 'pharm':U then do:     assign     p-news = true.   end.
            when 'upd-date-time':U then do:     assign     p-news = true.   end.
            when 'holdfirm-code':U then do:     assign     p-news = true.   end.
            when 'upd-date-time':U then do:     assign     p-news = true.   end.
            when 'arh-trn-doc-contract':U then do:     assign     p-news = false.   end.
            when 'vat-register':U then do:     assign     p-news = yes.   end.
            when 'bge-incr-last-shift-date':U then do:     assign     p-news = false.   end.
            when 'bge-incr-last-shift-num':U then do:     assign     p-news = false.   end.
            when 'bge-incr-cur':U then do:     assign     p-news = false.   end.
            when 'bge-sap-sng-last-shift':U then do:     assign     p-news = false.   end.
            when 'bge-exp-last-atd':U then do:     assign     p-news = false.   end.
            when 'bge-exp-malina-last-shift':U then do:     assign     p-news = false.   end.
            when 'egrip-date':U then do:     assign     p-news = true.   end.
            when 'egrip-num':U then do:     assign     p-news = true.   end.
            when 'fbr-pay-code':U then do:     assign     p-news = true.   end.
            when 'cargo-from':U then do:     assign     p-news = false.   end.
            when 'cargo-to':U then do:     assign     p-news = false.   end.
            when 'cli-local':U then do:     assign     p-news = false.   end.
            when 'cli-alc-producer':U then do:     assign     p-news = true.   end.
            when 'region-code':U then do:     assign     p-news = false.   end.
            when 'foreign-producer':U then do:     assign     p-news = true.   end.
            when 'main-accholder':U then do:     assign     p-news = yes.   end.
            when 'not-corr-op':U then do:     assign     p-news = true.   end.
            when 'veto-man-doc':U then do:     assign     p-news = true.   end.
            when 'requisite-alc-decl':U then do:     assign     p-news = true.   end.
            when 'division-code':U then do:     assign     p-news = true.   end.
            when 'supp-np':U then do:     assign     p-news = true.   end.
            when 'own-supp':U then do:     assign     p-news = true.   end.
            when 'supp-lgas':U then do:     assign     p-news = true.   end.
            when 'tank-farm-for':U then do:     assign     p-news = true.   end.
            when 'NPZ':U then do:     assign     p-news = true.   end.
            when 'code-KSK':U then do:     assign     p-news = false.   end.
            when 'code-AIS':U then do:     assign     p-news = false.   end.
            when 'auto-tank-for':U then do:     assign     p-news = true.   end.
            when 'owner-code':U then do:     assign     p-news = true.   end.
            when 'cli-for-close-fo':U then do:     assign     p-news = true.   end.
            when 'cli-clim-grp':U then do:     assign     p-news = true.   end.
            when 'cli-decommissioned':U then do:     assign     p-news = true.   end.
            when 'atd-alarm-schedule':U then do:     assign     p-news = true.   end.
            when 'exp-isPM-last-date':U then do:     assign     p-news = false.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure clntattr-copy-to :
do
  on error undo, return error
  :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  define buffer buf-clients-attr for ub.clients-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  define variable v-type           as character no-undo .
  run  clntattr-code  in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-clients-attr no-lock where
                buf-clients-attr.attr-code = p-code
            and buf-clients-attr.obj-type = p-obj-type
            and buf-clients-attr.obj-code = p-obj-code
             no-error .
   if not p-bh:available then do:
     p-bh:buffer-create().
   end.
   if avail buf-clients-attr then do:
     assign
     p-bh:buffer-field("attr-value"):buffer-value = buf-clients-attr.attr-value.
   end.
   else do:
     assign
     p-bh:buffer-field("attr-value"):buffer-value = if v-type = 'L':U then "no":U else "".
   end.
end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-archive-attr-list = 'arh-detail':U
          + chr(44) + 'arh-start':U
          + chr(44) + 'ahsp-detail':U
          + chr(44) + 'ahsp-start':U
          + chr(44) + 'aht-detail':U
          + chr(44) + 'aht-start':U
          + chr(44) + 'arh-del':U
          + chr(44) + 'ahsp-del':U
          + chr(44) + 'aht-del':U
          + chr(44) + 'arh-disable':U
          + chr(44) + 'ahsp-disable':U
          + chr(44) + 'aht-disable':U
          + chr(44) + 'arh-calc':U
          + chr(44) + 'ahsp-calc':U
          + chr(44) + 'aht-calc':U
          + chr(44) + 'arh-rest':U
          + chr(44) + 'ahsp-rest':U
          + chr(44) + 'aht-rest':U
          + chr(44) + 'arh-recalc':U
          + chr(44) + 'ahsp-recalc':U
          + chr(44) + 'aht-recalc':U
    .
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-archive-attr-list =  'bge-incr-last-shift-date':U
          + chr(44) + 'bge-incr-last-shift-num':U
    .
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
    case p-archive-type
    :
      when 'arh':U
      then do:
        assign
          p-archive-attr-list = 'arh-detail':U
              + chr(44) + 'arh-start':U
              + chr(44) + 'arh-del':U
              + chr(44) + 'arh-disable':U
              + chr(44) + 'arh-calc':U
              + chr(44) + 'arh-rest':U
              + chr(44) + 'arh-recalc':U
        .
      end.
      when 'ahsp':U
      then do:
        assign
          p-archive-attr-list = 'ahsp-detail':U
              + chr(44) + 'ahsp-start':U
              + chr(44) + 'ahsp-del':U
              + chr(44) + 'ahsp-disable':U
              + chr(44) + 'ahsp-calc':U
              + chr(44) + 'ahsp-rest':U
              + chr(44) + 'ahsp-recalc':U
        .
      end.
      when 'aht':U
      then do:
        assign
          p-archive-attr-list = 'aht-detail':U
              + chr(44) + 'aht-start':U
              + chr(44) + 'aht-del':U
              + chr(44) + 'aht-disable':U
              + chr(44) + 'aht-calc':U
              + chr(44) + 'aht-rest':U
              + chr(44) + 'aht-recalc':U
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании входных параметров" skip
          "Неизвестное значение параметра p-archive-type" skip
          "p-archive-type" p-archive-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
      v-value = p-value
    .
    if  p-obj-type <> 'орг':U
    and p-obj-type <> 'чел':U
    and p-obj-type <> 'маг':U
    and p-obj-type <> 'скл':U
    then do :
      message
        substitute("Нельзя установить данный атрибут для клиента с типом &1", p-obj-type)
        view-as alert-box error .
        undo, return error .
    end.
    run ref/requis-alc.w
      ( input p-obj-type
       ,input p-obj-code
       ,input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.
procedure clntattr-tank-farm-for :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
      v-code = "tank-farm-for"
      v-value = p-value
    .
    run str/clisel1.p
       (input parparentproc
       ,input p-obj-type
       ,input p-obj-code
       ,input v-code
       ,input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.
procedure clntattr-auto-tank-for :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
      v-code = "auto-tank-for"
      v-value = p-value
    .
    run str/clisel1.p
      ( input parparentproc
       ,input p-obj-type
       ,input p-obj-code
       ,input v-code
       ,input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.
procedure clntattr-owner-code :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
      v-code = "owner-code"
      v-value = p-value
    .
    run str/clisel1.p
      ( input parparentproc
       ,input p-obj-type
       ,input p-obj-code
       ,input v-code
       ,input-output v-value
      ).
    if num-entries(v-value) > 1
    then do :
      message "Выбрать можно только одного контрагента!" view-as alert-box .
      return error .
    end .
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.
procedure clntattr-cli-for-close-fo :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
      v-code = "cli-for-close-fo"
      v-value = p-value
    .
    run str/clisel1.p
      ( input parparentproc
       ,input p-obj-type
       ,input p-obj-code
       ,input v-code
       ,input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.
procedure clntattr-cli-clim-grp :
  define input parameter parparentproc as handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .
  define variable v-dlg as class ibs.th.ref.dclimgrp no-undo .
  define variable v-err-msg as character no-undo .
  do on error undo, throw :
    v-dlg = new ibs.th.ref.dclimgrp().
    if num-entries (p-value) = 3 then do :
      assign
      v-dlg:climGrp     = entry(1, p-value)
      v-dlg:beginSummer = entry(2, p-value)
      v-dlg:beginWinter = entry(3, p-value)
      .
    end .
    v-dlg:ShowModalDialog().
    if v-dlg:DialogResult = System.Windows.Forms.DialogResult:Ok then do:
      assign
        p-value  = substitute("&1,&2,&3", v-dlg:climGrp, v-dlg:beginSummer, v-dlg:beginWinter)
        p-setted = yes
      .
    end .
    v-err-msg = "" .
    catch exAppErrors as class Progress.Lang.AppError :
      v-err-msg = exAppErrors:ReturnValue .
      if v-err-msg > "" then . else do :
        v-err-msg = exAppErrors:GetMessage(1) .
        if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\attr-lib.p" .
      end .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      v-err-msg = exProErrors:GetMessage(1) .
      if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\attr-lib.p" .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\attr-lib.p " + exAnyErrors:GetMessage(1).
    end catch .
    finally :
      if valid-object (v-dlg) then delete object v-dlg .
      if v-err-msg <> "" then undo, throw new Progress.Lang.AppError(
        substitute("&1 c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\attr-lib.p &2", v-err-msg, "clntattr-cli-clim-grp")
      ) .
    end finally .
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
      v-value = p-value
    .
    if  p-obj-type <> 'орг':U
    and p-obj-type <> 'чел':U
    then do:
      message
        substitute("Нельзя установить данный атрибут для клиента с типом &1", p-obj-type)
        view-as alert-box error .
    end.
    run ref/vatrg.w
      (input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.
procedure clntattr-main-accholder :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-holder-obj-type as character no-undo .
define variable v-holder-obj-code as integer no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
      if p-obj-type <> 'орг':U
      and p-obj-type <> 'чел':U then do:
        message
        substitute("Нельзя установить данный атрибут для клиента с типом &1", p-obj-type)
        view-as alert-box error .
        undo, return error .
      end.
      if p-value <> '':U then do:
        assign
        v-holder-obj-type = substring(p-value, 1, 3)
        v-holder-obj-code = integer(substring(p-value, 4))
        no-error.
        if error-status:error then do:
          assign
          v-holder-obj-type = '':U
          v-holder-obj-code = 0
          .
        end.
      end.
      run str/clisel.p ( input parparentproc
                    ,input-output v-holder-obj-type
                    ,input-output v-holder-obj-code) no-error.
      if not error-status:error then do:
        if not (v-holder-obj-type = 'орг':U
               or
               v-holder-obj-type = 'чел':U) then do:
          message
          substitute("Нельзя назначить держателем основного счета клиента с типом &1", v-holder-obj-type)
          view-as alert-box error .
          undo, return error .
        end.
        assign
        v-value = v-holder-obj-type + "," + string(v-holder-obj-code)
        .
        if v-value <> p-value then do:
          p-value = v-value.
          p-setted = yes.
        end.
     end.
  end.
end procedure.
procedure clntattr-veto-man-doc :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
      if p-value = '':U then do:
        p-value = "ALL".
        p-setted = yes.
        return.
      end.
      else do:
        message
        "Данный атрибут может либо отсутствовать," skip
        "либо принимать значение ALL"
        view-as alert-box warning.
      end.
  end.
end procedure.
procedure clntattr-manual-edit :
  do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'shftrep2':U then do:   assign   p-section-num = 1. end.
            when 'is-inkassator':U then do:   assign   p-section-num = 1. end.
            when 'is-superviser':U then do:   assign   p-section-num = 1. end.
            when 'db':U then do:   assign   p-section-num = 1. end.
            when 'vat-register':U then do:   assign   p-section-num = 1. end.
            when 'cargo-from':U then do:   assign   p-section-num = 1. end.
            when 'cargo-to':U then do:   assign   p-section-num = 1. end.
            when 'cli-local':U then do:   assign   p-section-num = 1. end.
            when 'cli-alc-producer':U then do:   assign   p-section-num = 1. end.
            when 'region-code':U then do:   assign   p-section-num = 1. end.
            when 'foreign-producer':U then do:   assign   p-section-num = 1. end.
            when 'main-accholder':U then do:   assign   p-section-num = 1. end.
            when 'not-corr-op':U then do:   assign   p-section-num = 1. end.
            when 'veto-man-doc':U then do:   assign   p-section-num = 1. end.
            when 'requisite-alc-decl':U then do:   assign   p-section-num = 1. end.
            when 'division-code':U then do:   assign   p-section-num = 1. end.
            when 'supp-np':U then do:   assign   p-section-num = 1. end.
            when 'own-supp':U then do:   assign   p-section-num = 1. end.
            when 'supp-lgas':U then do:   assign   p-section-num = 1. end.
            when 'tank-farm-for':U then do:   assign   p-section-num = 1. end.
            when 'NPZ':U then do:   assign   p-section-num = 1. end.
            when 'code-KSK':U then do:   assign   p-section-num = 1. end.
            when 'code-AIS':U then do:   assign   p-section-num = 1. end.
            when 'auto-tank-for':U then do:   assign   p-section-num = 1. end.
            when 'owner-code':U then do:   assign   p-section-num = 1. end.
            when 'cli-for-close-fo':U then do:   assign   p-section-num = 1. end.
            when 'cli-clim-grp':U then do:   assign   p-section-num = 1. end.
            when 'cli-decommissioned':U then do:   assign   p-section-num = 1. end.
            when 'atd-alarm-schedule':U then do:   assign   p-section-num = 0. end.
            when 'exp-isPM-last-date':U then do:   assign   p-section-num = 1. end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'shftrep2':U then do:     assign     p-section-num = 1.   end.
            when 'is-inkassator':U then do:     assign     p-section-num = 1.   end.
            when 'is-superviser':U then do:     assign     p-section-num = 1.   end.
            when 'db':U then do:     assign     p-section-num = 1.   end.
            when 'vat-register':U then do:     assign     p-section-num = 1.   end.
            when 'cargo-from':U then do:     assign     p-section-num = 1.   end.
            when 'cargo-to':U then do:     assign     p-section-num = 1.   end.
            when 'cli-local':U then do:     assign     p-section-num = 1.   end.
            when 'cli-alc-producer':U then do:     assign     p-section-num = 1.   end.
            when 'region-code':U then do:     assign     p-section-num = 1.   end.
            when 'foreign-producer':U then do:     assign     p-section-num = 1.   end.
            when 'main-accholder':U then do:     assign     p-section-num = 1.   end.
            when 'not-corr-op':U then do:     assign     p-section-num = 1.   end.
            when 'veto-man-doc':U then do:     assign     p-section-num = 1.   end.
            when 'requisite-alc-decl':U then do:     assign     p-section-num = 1.   end.
            when 'division-code':U then do:     assign     p-section-num = 1.   end.
            when 'supp-np':U then do:     assign     p-section-num = 1.   end.
            when 'own-supp':U then do:     assign     p-section-num = 1.   end.
            when 'supp-lgas':U then do:     assign     p-section-num = 1.   end.
            when 'tank-farm-for':U then do:     assign     p-section-num = 1.   end.
            when 'NPZ':U then do:     assign     p-section-num = 1.   end.
            when 'code-KSK':U then do:     assign     p-section-num = 1.   end.
            when 'code-AIS':U then do:     assign     p-section-num = 1.   end.
            when 'auto-tank-for':U then do:     assign     p-section-num = 1.   end.
            when 'owner-code':U then do:     assign     p-section-num = 1.   end.
            when 'cli-for-close-fo':U then do:     assign     p-section-num = 1.   end.
            when 'cli-clim-grp':U then do:     assign     p-section-num = 1.   end.
            when 'cli-decommissioned':U then do:     assign     p-section-num = 1.   end.
            when 'atd-alarm-schedule':U then do:     assign     p-section-num = 0.   end.
            when 'exp-isPM-last-date':U then do:     assign     p-section-num = 1.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thbjattr_code :
  do
  on error undo, return error return-value
  :
    define input  parameter p-upper-code     as character no-undo .
    define input  parameter p-code           as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    define output parameter p-prop-list      as character no-undo .
    define output parameter p-prop-type-list as character no-undo .
    define output parameter p-prop-label-list as character no-undo .
    define output parameter p-global          as logical no-undo .
    define output parameter p-host           as logical no-undo .
    define output parameter p-shop           as logical no-undo .
    define output parameter p-store          as logical no-undo .
    define output parameter p-db             as logical no-undo .
    define output parameter p-region         as logical no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-upper-code = entry(1, p-upper-code, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-upper-code :
            when 'autosale':U then do:     assign     p-label = "Набор опций работы с продажей"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr-1.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'automail,augetres,autocalc,autoclos,autocomp,one-curs,prcl-spl,autofbr,restdish,restingr,resttpsi,sale-filter,sale-add,neg-tpsi-weight,neg-tpsi-qnty,neg-tpsi-oper,tpsi-mode,main-tpsi,wrkr,agnt,boss,one-sale-per-day,close-day-period,close-in-rfsl,pay-gds-algo':U      p-prop-type-list = 'logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,character,logical,decimal,logical,integer,logical,integer,integer,integer,logical,logical,integer,character'      p-prop-label-list = 'автом. чтение чеков с кассы после входа в РАСЧЕТ ПРОДАЖИ,автом. резервирование после чтения чеков с кассы,автом. расчет шапки накл. после входа в РАСЧЕТ ПРОДАЖИ,автом. закрытие продажи после удачного резервирования,компенсация расход-возврат (в момент закрытия продажи),в продажу чеки только с одним значением курса баз.вал.,Значение цены в продаже брать из прайс-листа (не из чека),автом. пр-во необходимых блюд (для РЕСТОРАНА),учет остатков блюд при резервировании (для автом. пр-ва),учет остатков ингридиентов при резервировании (для автом. пр-ва),учет остатков товаров при резервировании (для ТПСИ),в продажу чеки только по фильтру (если задан),контрагенты доп.док-тов,уводить в отриц.ост-ки чужой весовой товар на объекте продажи (для ТПСИ),уводить в отриц.ост-ки чужой товар с количеством <,уводить в отриц.ост-ки чужой товар по отметке оператора (для ТПСИ),режим ТПСИ,Объект-распределитель,Кл-к,Исп,М-р,Одна продажа в день,Закрытие периода при закрытии продажи,Закрывать приход по техпроливу на факт,Алгоритмы для разброски сумм по платежам чека'      p-region = false     .   end.
            when 'get-chk':U then do:     assign     p-label = "Опции закачки чеков"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr-2.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'cas-curs,hnum,cas-shft,v-shft,t-shft,dc-mask,ptrl-check,card-by-mask,annu-check,no-get-chk,is-100-discnt,zero-cashier,z-check':U      p-prop-type-list = 'logical,logical,logical,integer,integer,logical,logical,logical,logical,logical,logical,integer,logical':U      p-prop-label-list = 'брать курсы валют в чек из спула,номер магазина для чеков брать из спулов,использовать смены на кассе,виртуальные смены,Время начала пересменки в магазине,использовать маски ДК при приеме чеков с касс для неперсонифицированных карт,принимать специф.чеки АЗК,использовать маски ДК при приеме чеков с касс для персонифицированных карт,принимать аннулированные чеки,НЕТ ПРИЕМА ЧЕКОВ В МАГАЗИНЕ,принимать чеки со 100% скидкой,<НУЛЕВОЙ> кассир,принимать чеки z-отчета'      p-region = false     .   end.
            when 'chk-view':U then do:     assign     p-label = "Опции интерфейса при работе с чеками"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr-3.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'ch-bc-ck,chk-inf,chk-spfc,paycardv,dc-change':U      p-prop-type-list = 'logical,logical,logical,character,logical':U      p-prop-label-list = 'Разрешена смена товара в чеке (при редакт. чека) на товар с другой ценой,Динамич. сбор инф по чекам и показ ее в пиктограммах главного меню,Видна кнопка <Cпецификация> в списке чеков - запуск заказной печати,Список префиксов номеров платежных карт ПОЛНОСТЬЮ показываемых в интерфейсе,Разрешена смена ДК при редактировании чека'      p-region = false     .   end.
            when 'cd-sending':U then do:     assign     p-label = "Общие опции коммуникации с кассами"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr-4.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'alllstcs,noautocs,cdpcknum,dflt-cd,process-sale,mask_s-c':U      p-prop-type-list = 'logical,logical,integer,character,logical,character':U      p-prop-label-list = 'Пересылка товаров на кассу только полным списком,Отключена автоматическая передача товаров на кассы,Кол-во записей в пакете для пересылки на кассы,Тип касс ПО УМОЛЧАНИЮ,Докачивать чеки в продажу после чтения с кассы или завершения чека в IBS TH POS,Маски коротких кодов'      p-region = false     .   end.
            when 'cd-inf-send':U then do:     assign     p-label = "Опции передачи данных на кассу"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr-5.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'tax-cass,nam-2str,nam-artc,cod-pcod,name-2cd,amntdisc,cp-is-use,how-temp-disc,how-pcnt-kat,code-system':U      p-prop-type-list = 'logical,logical,logical,logical,character,integer,logical,character,character,character':U      p-prop-label-list = 'Передача налогов на кассу,Передача основного названия товара на кассу в две строки,Как основн. назв. при передаче на кассу - англ. название товара или артикул,Как дополн. назв. при передаче на кассу - локальный код товара или код партии,Дополн.название на кассу,Категорийная/количественная скидка,На кассу передавать только типы касс. платежей с атрибутом ИСПОЛЬЗУЕТСЯ,Способ задания временной скидки,Способ задания категорийной скидки,Код внешней системы для передачи соответствий на кассу'      p-region = false     .   end.
            when 'scale-inf':U then do:     assign     p-label = "Параметры работы с весами"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr-6.w/init-ext=adm\shattri.p':U      p-global = false      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'scales-type,scales-pr,scallist,sclin-ld,noauto-scls':U      p-prop-type-list = 'character,character,character,integer,logical':U      p-prop-label-list = 'Разрешенные типы весов,Название программ для работы с весами,Номера весов на объекте,Установка сроков годности вес.товара при приходе и переоценке,Отключена автоматическая передача товаров на весы'      p-region = false     .   end.
            when 'cd-type-ibm':U then do:     assign     p-label = "Параметры POS IBM"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr-7.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'ibmrubc,ibmnalc,ibmspool,ibmgroup,multicurr,cd-vat,cdtaxlst,specgrp':U      p-prop-type-list = 'integer,integer,integer,logical,logical,integer,character,character':U      p-prop-label-list = 'Код нац.вал. НА КАССЕ,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Прием чеков с продажами по группам,Тип спула,Прием чеков с продажами по группам,Многовалютные НАЛИЧНЫЕ,Выделение ставок НДС в чеке,Соответствие ставок НДС категориям налога на кассе,Спецгруппы в справочнике суммовых групп'      p-region = false     .   end.
            when 'cd-type-ipc-servispl':U then do:     assign     p-label = "Параметры POS IPC-SERVIS+"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr-8.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'ipcsbasc,ipcspayn,ipcsdobc,ipcscpfx,ipcsccrd,ipcstcrd,ipcscurc,ipcpgpfx':U      p-prop-type-list = 'integer,integer,character,integer,character,character,character,integer':U      p-prop-label-list = 'Код валюты соответствующий баз. вал. КАССЫ,Тип касс.платежа НАЛИЧНЫЕ с кодом валюты равным коду баз. валюты НА КАССЕ,Код дополнительной валюты для прейскурантов,Префикс весового бар-кода,Список кодов платежей по картам на кассе,Список типов касс.платежей по картам,Список валют для типов касс.платежей по картам,Префикс штучного бар-кода для весов'      p-region = false     .   end.
            when 'cd-type-magia-xml':U then do:     assign     p-label = "Параметры POS MAGIA-XML"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr10.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'mag-bnal,magnopay,mag-vip,ret-item,wro-item,ret-chk,wro-chk,ret-ord,wro-ord':U      p-prop-type-list = 'integer,integer,integer,character,character,character,character,character,character':U      p-prop-label-list = 'Тип касс. платежа для безналичной оплаты НА КАССЕ,Тип касс. платежа для НЕОПЛАЧЕННОГО  НА КАССЕ,Тип касс. платежа для чеков VIP и представит. расходов,Код списания для возврата-списания строки чека,Код списания для списания строки чека,Код списания для возврата-списания целого чека,Код списания для cписания всего чека,Код списания для возврата-списания заказа,Код списания для списания заказа'      p-region = false     .   end.
            when 'cd-type-NCR-GM':U then do:     assign     p-label = "Параметры POS NCR-GM"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr-9.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'ncrscpfx,ncrdrank,save-param,ncrpgpfx':U      p-prop-type-list = 'integer,character,character,integer':U      p-prop-label-list = 'Префикс весового бар-кода,Приоритеты скидок на товар при наличии скидок неск. типов,Расположение резервных копий неизменяемых <ручных настроек> для кассы,Префикс штучного бар-кода для весов'      p-region = false     .   end.
            when 'cd-type-NCR-AS-R':U then do:     assign     p-label = "Параметры POS NCR-AS@R"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr14.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'ncrscpfx,ncrdrank,save-param,ncrpgpfx':U      p-prop-type-list = 'integer,character,character,integer':U      p-prop-label-list = 'Префикс весового бар-кода,Приоритеты скидок на товар при наличии скидок неск. типов,Расположение резервных копий неизменяемых <ручных настроек> для кассы,Префикс штучного бар-кода для весов'      p-region = false     .   end.
            when 'cd-type-omron':U then do:     assign     p-label = "Параметры POS OMRON"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr11.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'omrbase,omrnal,omrntnl,omrpayl,omrcurl':U      p-prop-type-list = 'integer,integer,integer,character,character':U      p-prop-label-list = 'Код валюты соответствующий баз. вал. КАССЫ,Тип кассового платежа соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ,Тип кассового платежа соответствующий оплате БЕЗНАЛИЧНЫЕ НА КАССЕ,Список кодов типов касс.платежа соответствующих типам платежа на кассе,Список кодов валют типов касс.платежа соответствующих типам платежа на кассе'      p-region = false     .   end.
            when 'cd-type-omron-new':U then do:     assign     p-label = "Параметры POS OMRON-NEW"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr12.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'omrnbase,omrnnal,omrnntnl,omrnpayl,omrncurl':U      p-prop-type-list = 'integer,integer,integer,character,character':U      p-prop-label-list = 'Код валюты соответствующий баз. вал. КАССЫ,Тип кассового платежа соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ,Тип кассового платежа соответствующий оплате БЕЗНАЛИЧНЫЕ НА КАССЕ,Список кодов типов касс.платежа соответствующих типам платежа на кассе,Список кодов валют типов касс.платежа соответствующих типам платежа на кассе'      p-region = false     .   end.
            when 'cd-type-IBM-XML':U then do:     assign     p-label = "Параметры POS IBM-XML"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr13.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'ibmrubc,ibmnalc,ibm-ccm,ibmgroup,multicurr,cd-vat,cdtaxlst,specgrp':U      p-prop-type-list = 'integer,integer,integer,logical,logical,integer,character,character':U      p-prop-label-list = 'Код валюты соответствующий баз. вал. КАССЫ,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Код платежа при оплате НАЛИЧНЫМИ CCM,прием чеков с продажами по группам,Многовалютные НАЛИЧНЫЕ,Выделение ставок НДС в чеке,Соответствие ставок НДС категориям налога на кассе,Спецгруппы в справочнике суммовых групп'      p-region = false     .   end.
            when 'cd-type-r-keeper':U then do:     assign     p-label = "Параметры POS R-Keeper"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr16.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'cash-pay-list,dis-rule-list,date-format':U      p-prop-type-list = 'character,character,character':U      p-prop-label-list = 'Список соответствий типов кассовых платежей,Список соответствий идентификатор скидки на кассе-правило скидки в IBS TH,Формат даты при экспорте на кассу'      p-region = false     .   end.
            when 'cd-type-maria':U then do:     assign     p-label = "Параметры Кассы MARIA"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr19.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'cdtaxlst,mariapayg,mariapayp,dr-list,drgrouprank,drgdsrank':U      p-prop-type-list = 'character,character,character,character,character,character':U      p-prop-label-list = 'Соответствие ставок НДС категориям налога на кассе,Соответствие типов касс.платежей для сопут.товары,Соответствие типов касс.платежей для топлива,Соответствие моделей скидок НА КАССЕ правилам скидок в IBS TH,Приоритеты скидок на товар,Приоритеты скидок на группы товаров'      p-region = false     .   end.
            when 'cd-type-IBS-TH':U then do:     assign     p-label = "Настройки и опции работы POS IBS TH"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr29.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'ibs-th_main,ibs-th_devices,ibs-th_fisreg,ibs-th_rec-print,ibs-th_interface':U      p-prop-type-list = 'void,void,void,void,void'      p-prop-label-list = 'Основные настройки,Работа с устройствами,Настройки для ФР,Настройки чеков,Интерфейс'      p-region = false     .   end.
            when 'ibs-th_main':U then do:     assign     p-label = "Основные настройки и опции"     p-user-can-edit  = true     p-output-display = false     p-other = 'init-ext=adm\shattri.p/copy-2cda=yes':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U      p-prop-type-list = 'integer,integer,integer,integer,integer,integer,integer'      p-prop-label-list = 'Работа со сменами,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Обязателен продавец,Разрешена ручная скидка,Уровень логирования,Обнулять счетчик наличности при Z-отчете,Разрешена коррекция кол-ва'      p-region = false     .   end.
            when 'ibs-th_devices':U then do:     assign     p-label = "Работа с устройствами"     p-user-can-edit  = true     p-output-display = false     p-other = 'init-ext=adm\shattri.p/copy-2cda=yes':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U      p-prop-type-list = 'integer,integer,integer,integer,integer,decimal,integer,integer,character,character,character,character,character,character,character,character'      p-prop-label-list = 'Подключать ДЯ,Тип подключения ДЯ,Порт подключения ДЯ,Кол-во имп. подключения ДЯ,Работа с открытым ДЯ,Предел наличности ДЯ,Подключать кардридер,Подключать дисплей покупателя,Текст рекламы на дисплее покупателя,Тип клавиатуры,Раскладка клавиатуры,Система безналичных платежей,Тип дисплея покупателя,Порт дисплея покупателя,Тип системы видеонаблюдения,Адрес/порт системы видеонаблюдения'      p-region = false     .   end.
            when 'ibs-th_fisreg':U then do:     assign     p-label = "Настройки для ФР"     p-user-can-edit  = true     p-output-display = false     p-other = 'init-ext=adm\shattri.p/copy-2cda=yes':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U      p-prop-type-list = 'integer,character,character,integer,character'      p-prop-label-list = 'Логический уровень датчика ДЯ в открытом состоянии,Типы кассовых платежей TH<->коды оплаты ФР,Наименования типов оплат ФР,Отрезание чеков,ФР подключен к'      p-region = false     .   end.
            when 'ibs-th_rec-print':U then do:     assign     p-label = "Настройки для чеков"     p-user-can-edit  = true     p-output-display = false     p-other = 'init-ext=adm\shattri.p/copy-2cda=yes':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U      p-prop-type-list = 'decimal,character,character,integer,character,decimal,integer,integer'      p-prop-label-list = 'Макс.сумма чека,Рекламный текст,Строки клише,Печатать код товара,Тип округления суммы чека,Коэфф. типа округления суммы чека,Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере'      p-region = false     .   end.
            when 'ibs-th_interface':U then do:     assign     p-label = "Настройки интерфейса"     p-user-can-edit  = true     p-output-display = false     p-other = 'init-ext=adm\shattri.p/copy-2cda=yes':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'screen-type,screen-layout-id':U      p-prop-type-list = 'character,character'      p-prop-label-list = 'Вид интерфейса,Раскладка'      p-region = false     .   end.
            when 'cd-type-IBS-TH-MOB':U then do:     assign     p-label = "Настройки и опции работы POS IBS TH-MOB"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr31.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'ibs-th-mob_main,ibs-th-mob_rec-print':U      p-prop-type-list = 'void,void'      p-prop-label-list = 'Основные настройки'      p-region = false     .   end.
            when 'ibs-th-mob_main':U then do:     assign     p-label = "Основные настройки и опции"     p-user-can-edit  = true     p-output-display = false     p-other = 'init-ext=adm\shattri.p/copy-2cda=yes':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'salesman-mandatory,pos-type-for-discnt':U      p-prop-type-list = 'integer,character'      p-prop-label-list = ',Обязателен продавец,Тип кассы, которого брать скидки'      p-region = false     .   end.
            when 'ibs-th-mob_rec-print':U then do:     assign     p-label = "Настройки для чеков"     p-user-can-edit  = true     p-output-display = false     p-other = 'init-ext=adm\shattri.p/copy-2cda=yes':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'rcpt-ord-slip-print,rcpt-ord-alt-print':U      p-prop-type-list = 'integer,integer'      p-prop-label-list = 'Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере'      p-region = false     .   end.
            when 'cd-type-autotank':U then do:     assign     p-label = "Параметры POS autotank"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr41.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = false      p-db = false      p-prop-list = 'cash-pay-list,ibmgroup,specgrp':U      p-prop-type-list = 'character,logical,character':U      p-prop-label-list = 'Список соответствий типов кассовых платежей,Прием чеков с продажами по группам,Спецгруппы в справочнике суммовых групп'      p-region = false     .   end.
            when 'alias-tpsi':U then do:     assign     p-label = "Настройки межфирменного перемещения через ТПСИ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\als-tppr.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'alias-type-price,alias-object-price':U      p-prop-type-list = 'integer,Character':U      p-prop-label-list = 'Тип цены при продаже товара другой фирмой,Объект-посредник для цены межфирменного перемещения'      p-region = false     .   end.
            when 'abc-sale-day':U then do:     assign     p-label = "Гарантийный запас по АBC-анализу в днях"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\abc-gar.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'A,B,C,D,E,F':U      p-prop-type-list = 'integer,integer,integer,integer,integer,integer':U      p-prop-label-list = 'A,B,C,D,E,F'      p-region = false     .   end.
            when 'abc-global':U then do:     assign     p-label = "Глобальные настройки АВС-анализа"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\assortpa.w':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'abc-mode,abc-type,abc-one,abc-two'      p-prop-type-list = 'character,character,character,character':U      p-prop-label-list = 'ABC-анализ - способ проведения,Количество параметров для ABC-анализа,Проценты по умолчанию для ABC-анализа (простого). Уровни ранжирования,Проценты по умолчанию по Двухуровневому ABC-анализу'      p-region = false     .   end.
            when 'ord-global':U then do:     assign     p-label = "Глобальные настройки для ЗАКАЗОВ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\orderpa.w':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'ord-log,ord-ofof,ord-oobj,ord-op,ord-min-ost-day,ordshipd,ordcyclg'      p-prop-type-list = 'logical,logical,logical,logical,logical,integer,logical':U      p-prop-label-list = 'Логировать расчет заказа,Заявки типа ОФ формируются в офисе,В заказах ОО учитывать остаток на объектах-поставщиках,Заказы типа ОП работают по полной схеме,MIN остаток учитывается в днях,Количество дней до заказа,Цикличные заказы по всем товарам группы из спецификации'      p-region = false     .   end.
            when 'ord-obj':U then do:     assign     p-label = "Настройки для ЗАКАЗОВ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\orderpa.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'ord-askp,ord-obj-rc,ord-wgt-div-prc,ord-11,ord-comp-prc'      p-prop-type-list = 'logical,character,decimal,logical,decimal':U      p-prop-label-list = 'Спрашивать о цене перемещения ОРЦ ,Объект РЦ,% отклонения принимаемого количества весового товара в ПОСТАВКЕ,По Заказу ОП только одна накладная,% исполнения заказа при котором он закрывается автоматически'      p-region = false     .   end.
            when 'Ass-obj':U then do:     assign     p-label = "Настройки по Ассортиментной политике"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\asspa.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'ass-srokiztdel,crit-srokgod,ass-num-days-igt,ass-proc-matr-shabl'      p-prop-type-list = 'integer,integer,integer,integer':U      p-prop-label-list = 'Срок удаления из Ассортиментных матриц товара с ИЖТ на ВЫВОД из АССОРТИМЕНТА,Критический срок годности товара,Количество дней в статусе ИЖТ (Новинка) для перевода в основную группу,Допустимый процент отклонения матрицы от шаблона'      p-region = false     .   end.
            when 'contr-in':U then do:     assign     p-label = "Настройки для Накладных в разрезе ВЗАИМОРАСЧЕТОВ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\naklpa.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'contr-in-income-NP,contr-in-income,contr-in-expense-NP,contr-in-expense,contr-qnty-spec,contr-recount'      p-prop-type-list = 'logical,logical,logical,logical,logical,logical,logical':U      p-prop-label-list = 'Договор в ПН с НП,Договор в ПН с СТ,Договор в РН с НП,Договор в РН с СТ,Сверять количества в ПН,Перенумерация ПКО и РКО'      p-region = false     .   end.
            when 'nakl_par':U then do:     assign     p-label = "Настройки для Складских документов"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\naklpa1.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'date-close-period,stfactdt,type-vat,type-slt,intprmvq,minusprt,avail-on-date,proxycrd,factorrt,inp_sum,reasonm,back-date,not-ord,reasonme,neg-ask,vat-goods,inv-ship,round-vat-sum,gtd-to-imp-prod,exc-max-qnty,mark-alchol,attr-PN,attr-mandatory-gds-in-wayb,attr-mandatory-gds-ret-wayb,attr-mandatory-gds-exp-wayb,edit-fact-wayb,reasons-for-return,reasons-write-off'      p-prop-type-list = 'date,logical,integer,integer,logical,logical,logical,logical,decimal,logical,logical,logical,logical,character,logical,logical,logical,logical,logical,logical,logical,character,character,character,character,logical,character,character':U      p-prop-label-list = 'Дата закрытия периода,Дата факт = Дате документа (для внешних ПН РН и МФ ),Тип заведения НДС по умолчанию,Тип заведения НсП по умолчанию,Спрашивать о цене перемещения,Автокоррекция отрицательных партий по Приходу и Возврату,В расход только партии доступные на дату док-та,Доверенность для внешней РН и возврата поставщику,Коэффициент дорожного налога,В ПН заведение по сумме или по цене нельзя изменить,Обязательное заведение ПРИЧИНЫ ЗАВЕДЕНИЯ ДОКУМЕНТА,Разрешено работать с документами задним числом,Запрет на ручной ввод ПН без Заказа,Документы-исключения,Предупреждение в РН при запрете отриц.остатков о нехватке товара,В ПН подставлять НДС из карточки товара,Инвойс-отгузка,Принудительное округление НДС до 2 знаков после запятой в ПН и РН,В ПН Обязательно указывать ГТД для товаров с импортным производителем,Запрещен приход при превышении максимальных остатков,Помарочный учет движения алкогольной продукции,Приход внешний топливо,Приход внешний товары,Возврат поставщику товары,Расход внешний товары,Разрешено вводить фактическое количество в статусе Накл-,Основания для возврата,Причины списания'      p-region = false     .   end.
            when 'overval':U then do:     assign     p-label = "Настройки для ПЕРЕОЦЕНОК"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\overval.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'pr-abs-d,pr-altex,pr-clt-q,pr-discm,pr-dpl-q,pr-dscnt,pr-equ-dq,pr-incpc,pr-list,pr-notls,pr-parex,pr-print,pr-rdc-q,pr-rndbs,pr-rndmt,pr-sclex,pr-sigma,pr-goods,pr-goods0,pr-nogds,pr-nogds0'      p-prop-type-list = 'logical,logical,logical,character,logical,logical,integer,decimal,character,logical,logical,logical,logical,decimal,character,logical,decimal,character,character,character,character':U      p-prop-label-list = 'Удалять строки товаров`по которым нет остатков,Добавлять имеющиеся неосновные цены,Запрос при замене цены при добавлении,Исходная цена для вычисления отклонения торговой наценки,Запрос при добавлении строки как в другом приказе,Предупреждать об изменении скидки,Действие над товаром`цена на который не изменилась,Для поля Наценка,Возможные методы расчета цены,Сохранять спец. и основные цены,Добавлять имеющиеся цены партий,Вызов окна печати ценников при закрытии на акт авто.переоценки,Запрос при уменьшении текущей цены,Для поля База округления,Для поля Метод округления,Добавлять имеющиеся цены признаков,MAX допустимое отклонение цены без назначения новой,Запрет на виды товаров в ДНЦ в УБД,Запрет на виды товаров в ДНЦ в ГБД,Исключения из запретов в ДНЦ на УБД,Исключения из запретов в ДНЦ на ГБД'      p-region = false     .   end.
            when 'inv-global':U then do:     assign     p-label = "Настройки для ИНВЕНТАРИЗАЦИИ глобально"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\inventpa.w':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'invclcas,invclcwt,inv-prs'      p-prop-type-list = 'logical,logical,integer':U      p-prop-label-list = 'Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ДОПОЛНИТЕЛЬНЫЕ СУММЫ ON-LINE в документы инвентаризации,Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ЕСТЕСТВЕННУЮ УБЫЛЬ ON-LINE в документе инвентаризации,Причина заведения документа для инвентаризации использующейся как документ пересортицы'      p-region = false     .   end.
            when 'inv-obj':U then do:     assign     p-label = "Настройки для ИНВЕНТАРИЗАЦИИ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\inventpa.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'invclcsp,invdnull,mxpcdcp,mxpcicp,mxsmdcp,mxsmicp,pstunqtn,wastage,pstgrp,pstunit,izlcstpr,minus'      p-prop-type-list = 'logical,logical,decimal,decimal,decimal,decimal,logical,logical,logical,logical,logical,logical,logical':U      p-prop-label-list = 'Рассчитывать суммы в единицах поставщика,Удаление нулевых строк в инвентаризации,Максимальное процентное отклонение уменьшения цены в документе пересортица,Максимальное процентное отклонение увеличения цены в документе пересортица,Максимальное абсолютное отклонение уменьшения цены в документе пересортица,Максимальное абсолютное отклонение увеличения цены в документе пересортица,Возможность пересортицы товаров с одной единицей измерения в разных количествах,Начисление естественной убыли,Запрещена пересортица товаров из разных групп,Запрещена пересортица товаров с разными единицами измерения,Приходовать излишки по продажным ценам без НДС,Разрешить создание инвентаризации с отрицательными количествами'      p-region = false     .   end.
            when 'arh-global':U then do:     assign     p-label = "Настройки для Архивов"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\arhglpa.w':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'apusharh,btprskip'      p-prop-type-list = 'logical,character':U      p-prop-label-list = 'Автоматический запуск расчета архивов после приема новостей,Список отложенных заданий которые надо пропустить'      p-region = false     .   end.
            when 'rezerv-global':U then do:     assign     p-label = "Настройки для РЕЗЕРВИРОВАНИЯ глобально"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\rezervpa.w':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'parts-bc'      p-prop-type-list = 'logical':U      p-prop-label-list = 'Создавать ли бар-коды партий'      p-region = false     .   end.
            when 'rezerv-obj':U then do:     assign     p-label = "Настройки для РЕЗЕРВИРОВАНИЯ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\rezervpa.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'invngbeg,invngend,negmanuf,negparts,prcshfc0,prcshrs0,prcshrs1,prdocfc0,prdocrs0,prdocrs1,prsalpr'      p-prop-type-list = 'date,date,character,character,logical,character,character,logical,character,character,logical':U      p-prop-label-list = 'Диапазон для резервирования отрицательных партии по <-Партии>,-,Запрещается порождение отрицательных партий в производстве,Запрещается порождение отрицательных партий во всех документах (дальнейший анализ не производится),Допускается закрытие порожденных партий с учетной ценой 0 в документах продажи` возврата в магазине,Действие при созд порожд партии для док расх-возв продажи в маг-не с 0 учет цен,Действие при созд порожд партии по док-ту расх-возвр прод в маг-не с уч цен <> 0,Допускается закрытие порожденных партий с учетной ценой 0 во всех документах` кроме расхода` возврата продажи в магазине,При порожд партии для всех док-ов кроме расх-возвр прод в маг-не с 0 уч цен,При порожд партии для всех док-ов кроме расх-возвр прод в маг-не с уч цен <> 0,Для порожд партий без закуп цены взять цену по розничной цене без НДС (TRN125)'      p-region = false     .   end.
            when 'nakl-glob':U then do:     assign     p-label = "По Складским документам глобально"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\naklpa1.w':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'nocurbas,chk-prs,convimp,curcli,is-bcdoc,is-ov,multdtyp,noapndsc,part-prc,prc-exp,rnd-znk,slt-ext,vat-ext,vat-sum'      p-prop-type-list = 'character,logical,logical,logical,logical,logical,logical,logical,logical,decimal,integer,character,character,logical':U      p-prop-label-list = 'Обработка товара в документе без текущей продажной цены,Проверять менеджера и исполнителя,Доступен ли импорт с конвертацией,Валюта клиента может отличаться от нац.вал. во внешней ПН,Работает ли кнопка бар-код в ПН,Работает ли поле наценки (калькулятор) в ПН,Редактирование типа НДС и НП для внешней ПН,Переписывать логи при чтении со сканера,Редактировать ли учетные цены создаваемых партий в ПН,Максимальный процент транспортных и прочих расходов в ПН,До какого знака следует округлять проверяя ПН,НсП поставщика в ПН,НДС во внешней ПН,Задание НДС через сумму в ПН,'      p-region = false     .   end.
            when 'prt-glob':U then do:     assign     p-label = "параметры по Печати форм глобально"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\prtpglob.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'invprn0,outprncd,outrecv,sort-prd,torg2-no,outprops,rep-artic'      p-prop-type-list = 'logical,logical,character,logical,logical,logical,logical':U      p-prop-label-list = 'Печатать строки с 0 до и после инвентаризации в инвент_описи,Печатать код фирмы (клиента) при печати названия,Печать реквизитов на две строки,Сортировка по производителю в старых формах,ТОРГ-2 -только товары с расхождениями,Печатать сумму в счете-фактуре прописью,Печатать артикул в названии товара в Счет-фактуре и Торг-12'      p-region = false     .   end.
            when 'prt-obj':U then do:     assign     p-label = "параметры по Печати ФОРМ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\prtpobj.p':U      p-global = false      p-host = false      p-shop = true      p-store = true      p-db = false      p-prop-list = 'fgdsnind,in-docpr,outappr,outdate,outdisc,outegrp,outhold,outnum,outobj,outprim,outrubl,outssdoc,outsubs,outt12,outares,outsend,outasend,outR,outB,outogr,outC'      p-prop-type-list = 'logical,character,character,character,character,character,character,character,character,character,character,character,character,character,character,character,character,character,character,character,character':U      p-prop-label-list = 'Наименование товара в накладных печатать в 2 стр,Файл для печати внеш. ПН,Печатать в заголовках форм <Утверждена Постановлением>,не печатать <дата>,не печатать <скидка>,не печатать <реквизиты ЕГРИП>,должна быть задана фирма для печати накладных,не печатать <номер документа>,Адрес фирмы в графе Грузоотправитель/Грузополучатель из настроек объекта,не печатать <примечание>,не печатать <Цены указаны в нац.вал.>,№ платёжно-расчёт. док-та в счёте-фактуре,не печатать <подписи из БД>,не печатать последнюю колонку,Адрес контрагента в графе Грузополучатель/Грузоотправитель почтовый,В графе <Грузоотправитель> печатаются реквизиты объекта,Адрес фирмы в графе Грузоотправитель/Грузополучатель почтовый,Печатать в графе «Руководитель»,Печатать в графе «Гл. бухгалтер»,В графе «Отпуск груза разрешил»,Печать в графе «Отпуск груза произвел»'      p-region = false     .   end.
            when 'prt-firm':U then do:     assign     p-label = "параметры по Печати форм фирма"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\prtpfrm.p':U      p-global = false      p-host = true      p-shop = false      p-store = false      p-db = false      p-prop-list = 'factur01,incurrat,tick-w'      p-prop-type-list = 'logical,logical,logical':U      p-prop-label-list = 'Печатать в счете-фактуре doc-date вместо fact-date,Печать приходной накладной в нац.вал. по текущему курсу,Печать ценников на весовой товар (везде)'      p-region = false     .   end.
            when 'report-glob':U then do:     assign     p-label = "параметры по Отчетам глобально"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\reptglob.p':U      p-global = true      p-host = false      p-shop = true      p-store = true      p-db = false      p-prop-list = 'actuate,ardecldt,rep-sort,sum-from,sum-step,sum-to,sumvals,alcgrpgd,cplot,rep-shift-format,cdens,rep-password,rep-excel'      p-prop-type-list = 'logical,date,character,decimal,decimal,decimal,character,integer,character,integer,integer,logical,logical':U      p-prop-label-list = 'Есть отчеты Actuate,Декларация об объемах розничной продажи алк-я,Сортировка топлива в отчете по октановому числу,Нижнее знач.,Шаг,Верхнее знач.,Список,Код группы <Алкогольные товары>,Сортировка типов касс.пл-жей в отчете по АВТОКУШ,Формат сменного отчета,Алгоритм расчета плотности в отчетах,Excel для отчетов - защита от редактирования,Вывод отчетов в EXCEL '      p-region = false     .   end.
            when 'report-obj':U then do:     assign     p-label = "параметры по Отчетам"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\reptobj.p':U      p-global = false      p-host = false      p-shop = true      p-store = true      p-db = false      p-prop-list = 'prt-z-no,shft-qty'      p-prop-type-list = 'logical,character':U      p-prop-label-list = 'Печатать номера Z-отчетов в сменном отчете (1-4 л.),1-ый лист сменного отчета (топливо)'      p-region = false     .   end.
            when 'report-firm':U then do:     assign     p-label = "параметры по Отчетам фирма"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\reptfrm.p':U      p-global = false      p-host = true      p-shop = false      p-store = false      p-db = false      p-prop-list = 'xl-delim'      p-prop-type-list = 'character':U      p-prop-label-list = 'Разделитель колонок при экспорте в Excel'      p-region = false     .   end.
            when 'fin-global':U then do:     assign     p-label = "Глобальные настройки для Взаиморасчетов"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\finglpa.w':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'fo-buyer-nws,fo-supp-nws,fo-fact,fo-mc-mode,add-conn-avt,del-conn-avt,fo-gen'      p-prop-type-list = 'integer,integer,logical,integer,logical,logical,integer':U      p-prop-label-list = 'Где могут создаваться ФО покупателей,Как ходят ФО поставщиков по новостям,Дата закрытия ФО соответствует дате закрытия накладной,Режим работы ФО с мастер договорами,Формирование связи ФО и платежей автоматически при оплате,Удалять связи платежа с ФО автоматом при удалении платежа,Генерировать ФО для:'      p-region = false     .   end.
            when 'fin-plan':U then do:     assign     p-label = "Плановые цифры денежных средств"     p-user-can-edit  = true     p-output-display = true     p-other = '':U      p-global = false      p-host = false      p-shop = true      p-store = true      p-db = false      p-prop-list = 'fin-ostatok-start,fin-plan-pri,fin-proch,fin-proch-ras':U      p-prop-type-list = 'decimal,decimal,decimal,decimal':U      p-prop-label-list = 'Остаток на начало дня в кассах,План прихода,Прочие доходы,Прочие расходы'      p-region = false     .   end.
            when 'rt-trn-doc':U then do:     assign     p-label = "Радиотерминал. Значения по умолчанию для создаваемых накладных"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\shattr20.w/init-ext=shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'wrkr,agnt,boss':U      p-prop-type-list = 'integer,integer,integer':U      p-prop-label-list = 'Кладовщик,Оператор,Менеджер'      p-region = false     .   end.
            when 'gds-ref':U then do:     assign     p-label = "Набор опций работы со справочником товаров"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr21.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'dif-nam1,dif-nam2,dpl-off,dif-pdbc,pbc-veto,tnvedimp,unq-artc,is-scgb,dfltggrp,shema-foto,gds-copy,gdsscrvw'      p-prop-type-list = 'logical,logical,logical,logical,logical,logical,logical,logical,integer,integer,character,character'      p-prop-label-list = 'Разрешено добавление товаров с одинаковыми именами,Обязательное заведение ДопБК при добавлении товара,Выключение повторных ДопБК при появлении новых,Запрет повторных ДопБК для одного производителя,Запрет повторных ДопБК,Импортировать код ТНВЭД в карточку товара,Уникальный цифровой артикул`создание доп. БК = артикулу,Разрешено создавать глобальный весовые коды,Гр.товаров по умолч.,Схема хранения фото,Опции копирования допинфо по товару ( при соз-дании товара копированием),Заказные поля в экране покупателя,Запрещена работа с Доп-БК'      p-region = false     .   end.
            when 'gds-ref_obj':U then do:     assign     p-label = "Набор опций работы со справочником товаров в контексте объекта"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr22.w/init-ext=adm\shattri.p':U      p-global = false      p-host = false      p-shop = true      p-store = true      p-db = false      p-prop-list = 'dfltggrp,gdsscrvw,chg-bcod,image-dir':U      p-prop-type-list = 'integer,character,logical,character'      p-prop-label-list = 'Гр.товаров по умолч.,Заказные поля в экране покупателя,Запрещена работа с Доп-БК'      p-region = false     .   end.
            when 'dc-ref':U then do:     assign     p-label = "Набор опций работы со справочником ДК"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr38.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'l-zeros,l-mask':U      p-prop-type-list = 'logical,logical'      p-prop-label-list = 'Разрешено добавление ДК с лидирующими нулями,Маскирование ДК'      p-region = false     .   end.
            when 'cli-all':U then do:     assign     p-label = "Набор опций работы со справочником клиентов"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr23.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'inn-uniq,nocorinn':U      p-prop-type-list = 'integer,logical'      p-prop-label-list = 'Опции уникальности ,Разрешен ввод некорректного '      p-region = false     .   end.
            when 'cashpays':U then do:     assign     p-label = "Набор опций работы со справочником типов кассовых платежей"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr24.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'cpgrpnam':U      p-prop-type-list = 'character'      p-prop-label-list = 'Определение групп типов кассовых платежей'      p-region = false     .   end.
            when 'wthdoc':U then do:     assign     p-label = "Набор опций работы c МЦ"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr33.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'clsfact,prsdoc':U      p-prop-type-list = 'logical,logical'      p-prop-label-list = 'Закрывать документы при формировании по чекам МЦ,Проверка на наличие физ. лиц в документах МЦ '      p-region = false     .   end.
            when 'wthdoc_obj':U then do:     assign     p-label = "Набор опций работы с МЦ в контексте объекта"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr25.w/init-ext=adm\shattri.p':U      p-global = false      p-host = false      p-shop = true      p-store = true      p-db = false      p-prop-list = 'stfactpref,rangerule,clsfact,inobjauto,inwpcode,numsfact,prsdoc'      p-prop-type-list = 'character,integer,logical,logical,integer,integer,logical'      p-prop-label-list = 'Префикс номера счета-фактуры,Правило автоматического установления срока годности партий серийных МЦ,Закрывать документы при формировании по чекам МЦ,При закрытии продажи автоматически формировать документ перемещения ,МХ формирования документов перемещени,Последний номер счет-фактуры,Проверка на наличие физ. лиц в документах МЦ'      p-region = false     .   end.
            when 'attr-wthrep':U then do:     assign     p-label = "Глобальные настройки для работы с МЦ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\shattr27.w':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'cligrplist,docdstnws':U      p-prop-type-list = 'character,logical':U      p-prop-label-list = 'Опции сводных отчетов по МЦ,Не передавать по СПН документы уничтожения и перемещения погашенных МЦ на УБД'      p-region = false     .   end.
            when 'rum':U then do:     assign     p-label = "Машина правил (встраиваемые процедуры)"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr26.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'goods,clients,gds-grp,cli-grp,chk-doc_ibs-th,chk-doc_ibs-th-mob,edoc,thref,pdf,rep,ord,cmb,fdoc':U      p-prop-type-list = 'logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical'      p-prop-label-list = 'Операции с товарами,Операции с клиентами,Операции с группами товаров,Операции с группами клиентов,Операции с чеками на POS IBS-TH,Операции с чеками на POS IBS-TH-MOB,Операции в системе электронного документооборота,Операции со справочниками,Операции с ДНЦ и переоценками,Отчеты,Операции с заказами,Комбинированные алгоритмы,Операции с фин.документами'      p-region = false     .   end.
            when 'rum_obj':U then do:     assign     p-label = "Машина правил (встраиваемые процедуры) в контексте объекта"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr26.w/init-ext=adm\shattri.p':U      p-global = false      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'chk-doc_ibs-th,chk-doc_ibs-th-mob,rep':U      p-prop-type-list = 'logical,logical,logical'      p-prop-label-list = 'Операции с чеками на POS IBS-TH,Операции с чеками на POS IBS-TH-MOB,Отчеты'      p-region = false     .   end.
            when 'easyfuel':U then do:     assign     p-label = "Опции работы с системой EasyFuel"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr28.w/init-ext=adm\shattri.p':U      p-global = false      p-host = false      p-shop = true      p-store = false      p-db = false      p-prop-list = 'master-key':U      p-prop-type-list = 'character'      p-prop-label-list = 'Номер МАСТЕР-КЛЮЧА'      p-region = false     .   end.
            when 'images':U then do:     assign     p-label = "Параметры для работы с изображениями"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr30.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'imgorder':U      p-prop-type-list = 'character'      p-prop-label-list = 'Порядок форматов файлов изображений для поиска и ввода (при хранении изображений вне БД)'      p-region = false     .   end.
            when 'code-range':U then do:     assign     p-label = "Опции работы с Диапазонами кодов"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr32.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = true      p-prop-list = 'cdrgbcgb,cdrgctgb,cdrgdcgb,cdrgdrgb,cdrgfmgb,cdrgpngb,cdrgscgb,cdrgsclc,cdrgsslc,cdrgssgb,cdrgcagb,cdrgpglc,cdrgfdgb':U      p-prop-type-list = 'integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer'      p-prop-label-list = 'Размер диапазона для соственных кодов товаров,Размер диапазона для кодов договоров,Размер диапазона для кодов ДК,Размер диапазона для кодов правил скидок и расписаний,Размер диапазона для кодов организаций,Размер диапазона для кодов физ.лиц,Размер диапазона для глобальных весовых кодов,Размер диапазона для локальных весовых кодов,Размер диапазона для локальных взвешиваемых кодов,Размер диапазона для глобальных взвешиваемых кодов,Размер диапазона для глобальных кодов точек привязки,Размер диапазона для локальных штучных кодов для весов,Размер диапазона для глобальных кодов финансовых документов'      p-region = false     .   end.
            when 'bge-export':U then do:     assign     p-label = "Настройки для экспорта"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr34.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = true      p-prop-list = 'bgeclall,bgedcard,bgedict,bgeflnm,bgeflold,bgefmt,bgeshift,bgecliiv':U      p-prop-type-list = 'logical,logical,logical,character,character,character,character,character'      p-prop-label-list = 'Экспорт всех объектов,Удалять нули в начале номеров дисконтных карт,Экспорт справочников видов оплат типов кассовых платежей и дисконтных карт,Список шаблонов названий файлов выгрузки документов и товаров по дням,Вариант создания файлов выгрузки,Форматы выгрузки,Способ выгрузки сменных объектов,Контрагенты для которых внешний приход экспортируется как внутренний'      p-region = false     .   end.
            when 'auto-task':U then do:     assign     p-label = "Настройки АВТОПРОЦЕССОВ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\shattrat.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = true      p-prop-list = 'send-msg-to-email,user-list,maxColMarks':U      p-prop-type-list = 'character,character,integer':U      p-prop-label-list = 'email на который отсылать сообщения,список пользователей для авто процессов,Максимальное количество очищаемых марок'      p-region = false     .   end.
            when 'wnd-size':U then do:     assign     p-label = "Настройки размеров окон"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr35.w/init-ext=adm\shattri.p':U      p-global = TRUE      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'max,store':U      p-prop-type-list = 'logical,logical'      p-prop-label-list = 'Максимизировать окна при открытии,Сохранять внешний вид окна'      p-region = false     .   end.
            when 'obj-date':U then do:     assign     p-label = "Настройки даты и смены на объекте"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr36.w/init-ext=adm\shattri.p':U      p-global = TRUE      p-host = TRUE      p-shop = TRUE      p-store = TRUE      p-db = false      p-prop-list = 'autodate,autodtsh,newordsh,diffshft,difftime':U      p-prop-type-list = 'logical,logical,logical,integer,integer'      p-prop-label-list = 'Автоматическое изменение даты на обычном объекте,Автоматическое изменение даты на сменном объекте,Новый принцип формирования номеров смен,Допустимая разница между календарной и сменной датами,Допустимое превышение ВРЕМЕНИ ЗАКРЫТИЯ СМЕНЫ над текущим (в минутах)'      p-region = false     .   end.
            when 'fbrattr':U then do:     assign     p-label = "Настройки производства"     p-user-can-edit  = true     p-output-display = false     p-other = 'spr-ext=adm\shattr37.w/init-ext=adm\shattri.p':U      p-global = TRUE      p-host = TRUE      p-shop = TRUE      p-store = TRUE      p-db = FALSE      p-prop-list = 'fbr-frcp,fbr-ioff,fbr-qntc,fbrrcpgb,fbrhstlv,fbr-mrgn-min,fbr-mrgn-max':U      p-prop-type-list = 'logical,logical,logical,logical,integer,decimal,decimal'      p-prop-label-list = 'Первый подходящий рецепт при рекурсивном производстве,Ручное заполнение альтернативного производства,При раскрутке рецептов прибавлять требуемое количество к уже произведенному,Возможность изменения локальных рецептов на глобальные,Детализация записи в историю,Мин. % наценки производства,Макс. % наценки производства'      p-region = FALSE     .   end.
            when 'petrol':U then do:     assign     p-label = "Настройки работы с ТОПЛИВНЫМ товаром"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\shattrpt-fld.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'rvsnmter,denstclc,autopump-izm,autopump,avtinvpm,inpptrl,expptrl,invclipt,olddens,algrvspt,temp-for-pomi,rvs-wt-email,CriticalDif,algoincome,mand-choice-autocar,Delta-mass-horiz,Delta-mass-vert,dop-info,otkl-fact-volue,otkl-temp,otkl-density,otkl-water,CriticalDifInLgas,calc-free-vol,trn-reas-sug,rvd-own-nb,sec-fields,qr-scan-time,trnscanqr,block-nozzle,timeout-block-nozzle,calc-free-vol-sug,autopump-skip-time':U      p-prop-type-list = 'logical,character,logical,logical,logical,character,character,integer,logical,integer,integer,character,integer,integer,logical,character,character,character,decimal,decimal,character,decimal,decimal,logical,logical,logical,character,integer,logical,logical,integer,logical,integer':U      p-prop-label-list = 'Расхождение в инвентаризации по сверке делать без учета погрешности измерения,Алгоритм вычисления плотности для продаж,Автоматические сверки создавать только по измеряемым резервуарам,Автоматические сверки создавать с чтением всех счетчиков ТРК,Автом. создание инв. счетчиков ТРК при переполнении разрядности эл. счетчика,Тип ввода топлива в документах прихода внешнего,Тип ввода топлива во всех документах кроме прихода внешнего,Контрагент для списания ЕУ при инвентаризации топлива по сверке,В документы по умолчанию ставится плотность и темп. из предыдущего документа,Настройки инвентаризации по сверке,Температура к которой приводится плотность и объем (°С),При воде в сверке отправлять сообщения на список адресов,Допустимый % расхождения массы в резервуаре,Алгоритм принятия топлива к учету,Обязательный выбор автотранспорта из справочника,Погрешность изм массы для горизонтальных резер,Погрешность изм массы для вертикальных резер,Обязательные поля доп.инфо ПН,Отклонение объема,Отклонение температуры,Отклонение плотности,Отклонение воды,Допустимый % расхождения массы при приеме СУГ,Контроль свободного объема в резервуаре при приеме НП,Обязательный выбор этапа для приема газовоза,Разрешить ручное заполнение документа приёма НП при поставках с собственных НБ,Обязательные поля в секциях ПН,Время на сканирование QR-кода (мс),Автозаполнение НП,Отправлять блокировку пистолетов при приемке,Timeout ожидания подтверждения блокировки пистолетов,Контроль свободного объема в резервуаре при приеме СУГ,Время пропуска данных автоматической сверки после приема НП'      p-region = false     .   end.
            when 'staff':U then do:     assign     p-label = "Параметры работы с пользователями и персоналом"     p-user-can-edit  = true     p-output-display = false     p-other = 'cd/spr-ext=adm\shattr40.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'noanshftstaff,obyznumbukv,obyznumbukvadm,minparol,minparoladm,TimeAvail,TimeAvailadm,TimeBlock,TimeBlockAdm,LastPaswd,LastPaswdAdm':U      p-prop-type-list = 'logical,logical,logical,integer,integer,integer,integer,integer,integer,integer,integer':U      p-prop-label-list = 'Запрет на ввод произвольных данных при вводе персонала смены,Обязательное сочетание цифровых и буквенных символов,Обязательное сочетание цифровых и буквенных символов (адм),Минимальная длина пароля,Минимальная длина пароля (адм),Время жизни пароля,Время жизни пароля (адм),Время до блокировки пользователя после окончания действия пароля,Время до блокировки пользователя после окончания действия пароля (адм),Колличество старых паролей с которыми не должен совпадать новый пароль,Колличество старых паролей с которыми не должен совпадать новый пароль (адм)'      p-region = false     .   end.
            when 'izt-rul':U then do:     assign     p-label = "Настройки правил ИЖТ"     p-user-can-edit  = false     p-output-display = false     p-other = '':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = false      p-prop-list = 'izt-rul':U      p-prop-type-list = 'character':U      p-prop-label-list = 'список ответов: можно ли работать с товаром по ИЖТ и по событию'      p-region = false     .   end.
            when 'srv-auth-ASU':U then do:     assign     p-label = "Сервер авторизации АСУ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=adm\shattrsa.w/init-ext=adm\shattri.p':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'pko-cli,srv-auth-adr':U      p-prop-type-list = 'character,character':U      p-prop-label-list = 'Код контрагента РКО обязательного к авторизации,Адрес сервера авторизации '      p-region = false     .   end.
            when 'egais':U then do:     assign     p-label = "Настройки для обмена с ЕГАИС"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\exegais.w/init-ext=adm\shattri.p':U      p-global = true      p-host = false      p-shop = true      p-store = true      p-db = false      p-prop-list = 'egais-fsrar,egais-utm,egais-ver-xsd,egais-inn,egais-exsys'      p-prop-type-list = 'character,character,character,character,integer':U      p-prop-label-list = 'Код ФСРАР,Адрес УТМ,Версия XSD схем,ИНН фирмы,Номер внешней системы'      p-region = false     .   end.
            when 'gisMT':U then do:     assign     p-label = "Настройки для подключения к ГИС МТ и проверки КМ"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\gis.w':U      p-global = true      p-host = false      p-shop = false      p-store = false      p-db = true      p-prop-list = 'adressPort,dopParam,gisAdress,proxyLogin,proxyPswd,maxTime,regKey,timeFalStart,waitTime,crashSituat,banDate,cdnTurnOn,cdnAdress,cdnRepeat,cdnChange,cdnTimeUpdate,UpdateRequest,OflineAdress,OflineLogin,OflinePswd,MACC_Timeout,Resp_TH_required,LmCHzPort,TH_IP,TH_Port,AddTimeoutPIoT,MaxApiToken,AgeConfirm'      p-prop-type-list = 'character,character,character,character,character,integer,character,integer,decimal,logical,integer,logical,character,logical,logical,integer,logical,character,character,character,decimal,integer,character,character,character,decimal,character,integer':U      p-prop-label-list = 'Адрес и порт проски-сервера,Дополнительные параметры запроса,Адрес ГИС МТ,Логин,Пароль,Макс.допуст. время разрешения продажи при сбое,ключ авторизации,Время с момента сбоя до начала уведомления персонала,Длительность ожидания ответа ГИС МТ,Аварийная ситуация в ГИС МТ,Опережение срабатывания запрета по сроку годности в минутах,Работа с cdn-площадками,Адрес cdn,Повторный опрос площадки,Смена площадки,Период обновления списка CDN-площадок,Обновление параметров при запросе КМ,Адрес ЛМ ЧЗ,Логин в ЛМ ЧЗ,Пароль в ЛМ ЧЗ,Время ожидания ответа ТН,Обязательность получения результатов проверки КМ в ТН,Порт для отправки запроса проверки марки в ЛМ ЧЗ,Адрес для отправки запроса проверки марки в ТН,Порт для отправки запроса проверки марки в ТН,Длительность обработки ответа ГИС МТ в ТС ПИоТ,Токен авторизации MAX,Проверка возраста при продаже НП'      p-region = true     .   end.
            when 'marking':U then do:     assign     p-label = "Электронный документооборот"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\marking.w':U      p-global = true      p-host = false      p-shop = true      p-store = true      p-db = false      p-prop-list = 'marking-EDO,marking-EDO-NotMark,marking-manual,gray_zone_qnty,marking-type-edo,ban-recipes,ban-altr,bar-code,rus-key,marking-type-artic,marking-type-transitional,marking-type-saleReturn,checkBlock,checkDate,checkMRC,checkOwner,checkStatusKM,checkTracking'      p-prop-type-list = 'logical,logical,logical,integer,character,logical,logical,logical,logical,character,character,character,character,character,character,character,character,character':U      p-prop-label-list = 'Включена работа с ЭДО для маркированных документов,Включена работа с ЭДО для не маркированных документов,Ручной ввод марок,Допустимое отсутствие КМ для "Серой зоны",Типы маркировок для поэкземплярного учета,Запрет на создание рецептов и маркетинговых акций с маркированными товарами,Использования рецепта Альтернатива только для получения ингредиентов,Определение товара по штрих-коду,Автоматическое переключение раскладки на русский,Типы маркировок для объемно-артикульного учета,Типы маркировок переходный период,Разрешена продажа возвращенных товаров,Проверка блокировок контролирующих органов,Проверка срока годности,Проверка МРЦ,Проверка владельца,Проверка статуса КМ,Проверка прослеживаемости'      p-region = false     .   end.
            when 'mercur':U then do:     assign     p-label = "Параметры для работы с ФГИС Меркурий"     p-user-can-edit  = true     p-output-display = true     p-other = 'spr-ext=gbl\mercur.w':U      p-global = true      p-host = true      p-shop = true      p-store = true      p-db = false      p-prop-list = 'apikey,login_is,login,password,manual-vcd,close,type-connect,qrcode,server,proxy-addres,proxy-login,proxy-pswd,proxy-ssl'      p-prop-type-list = 'character,character,character,character,logical,logical,integer,character,integer,character,character,character,logical':U      p-prop-label-list = 'APIKey,Логин входа в ИС,Логин,Пароль,Разрешено вводить код ВСД вручную,Разрешено закрывать документ без указ. ВСД,Тип взаимодействия,Настройки для печати QR-кода,Сервер,Адрес прокси-сервера,логин,пароль,SSL прокси'      p-region = false     .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут объекта TH &1", p-upper-code ).
      end.
    end.
  end.
end procedure.
procedure thbjattr_tooltip :
do
on error undo, return error return-value
:
  define input  parameter p-upper-code as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  define output parameter p-tooltip-code  as character no-undo .
  define variable v-tooltip-code-list as character no-undo .
  if index(p-code, chr(4)) > 0 then do:
    p-upper-code = entry(1, p-upper-code, chr(4)).
    p-code = entry(1, p-code, chr(4)).
  end.
  case p-upper-code :
        when 'autosale':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'автом. чтение чеков с кассы после входа в РАСЧЕТ ПРОДАЖИ,автом. резервирование после чтения чеков с кассы,автом. расчет шапки накл. после входа в РАСЧЕТ ПРОДАЖИ,автом. закрытие продажи после удачного резервирования,компенсация расход-возврат (в момент закрытия продажи),в продажу чеки только с одним значением курса баз.вал.,Значение цены в продаже брать из прайс-листа (не из чека),автом. пр-во необходимых блюд (для РЕСТОРАНА),учет остатков блюд при резервировании (для автом. пр-ва),учет остатков ингридиентов при резервировании (для автом. пр-ва),учет остатков товаров при резервировании (для ТПСИ),в продажу чеки только по фильтру (если задан),контрагенты доп.док-тов,уводить в отриц.ост-ки чужой весовой товар на объекте продажи (для ТПСИ),уводить в отриц.ост-ки чужой товар с количеством <,уводить в отриц.ост-ки чужой товар по отметке оператора (для ТПСИ),режим ТПСИ,Объект-распределитель,Кл-к,Исп,М-р,Одна продажа в день,Закрытие периода при закрытии продажи,Закрывать приход по техпроливу на факт,Алгоритмы для разброски сумм по платежам чека'.     assign     p-tooltip = "Набор опций работы с продажей"     p-label = "Набор опций работы с продажей"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'automail,augetres,autocalc,autoclos,autocomp,one-curs,prcl-spl,autofbr,restdish,restingr,resttpsi,sale-filter,sale-add,neg-tpsi-weight,neg-tpsi-qnty,neg-tpsi-oper,tpsi-mode,main-tpsi,wrkr,agnt,boss,one-sale-per-day,close-day-period,close-in-rfsl,pay-gds-algo':U ), 'автом. чтение чеков с кассы после входа в РАСЧЕТ ПРОДАЖИ,автом. резервирование после чтения чеков с кассы,автом. расчет шапки накл. после входа в РАСЧЕТ ПРОДАЖИ,автом. закрытие продажи после удачного резервирования,компенсация расход-возврат (в момент закрытия продажи),в продажу чеки только с одним значением курса баз.вал.,Значение цены в продаже брать из прайс-листа (не из чека),автом. пр-во необходимых блюд (для РЕСТОРАНА),учет остатков блюд при резервировании (для автом. пр-ва),учет остатков ингридиентов при резервировании (для автом. пр-ва),учет остатков товаров при резервировании (для ТПСИ),в продажу чеки только по фильтру (если задан),контрагенты доп.док-тов,уводить в отриц.ост-ки чужой весовой товар на объекте продажи (для ТПСИ),уводить в отриц.ост-ки чужой товар с количеством <,уводить в отриц.ост-ки чужой товар по отметке оператора (для ТПСИ),режим ТПСИ,Объект-распределитель,Кл-к,Исп,М-р,Одна продажа в день,Закрытие периода при закрытии продажи,Закрывать приход по техпроливу на факт,Алгоритмы для разброски сумм по платежам чека'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'automail,augetres,autocalc,autoclos,autocomp,one-curs,prcl-spl,autofbr,restdish,restingr,resttpsi,sale-filter,sale-add,neg-tpsi-weight,neg-tpsi-qnty,neg-tpsi-oper,tpsi-mode,main-tpsi,wrkr,agnt,boss,one-sale-per-day,close-day-period,close-in-rfsl,pay-gds-algo':U ), v-tooltip-code-list))) no-error.   end.
        when 'get-chk':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'брать курсы валют в чек из спула,номер магазина для чеков брать из спулов,использовать смены на кассе,виртуальные смены,Время начала пересменки в магазине,использовать маски ДК при приеме чеков с касс для неперсонифицированных карт,принимать специф.чеки АЗК,использовать маски ДК при приеме чеков с касс для персонифицированных карт,принимать аннулированные чеки,НЕТ ПРИЕМА ЧЕКОВ В МАГАЗИНЕ,принимать чеки со 100% скидкой,<НУЛЕВОЙ> кассир,принимать чеки z-отчета'.     assign     p-tooltip = "Опции закачки чеков"     p-label = "Опции закачки чеков"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cas-curs,hnum,cas-shft,v-shft,t-shft,dc-mask,ptrl-check,card-by-mask,annu-check,no-get-chk,is-100-discnt,zero-cashier,z-check':U ), 'брать курсы валют в чек из спула,номер магазина для чеков брать из спулов,использовать смены на кассе,виртуальные смены,Время начала пересменки в магазине,использовать маски ДК при приеме чеков с касс для неперсонифицированных карт,принимать специф.чеки АЗК,использовать маски ДК при приеме чеков с касс для персонифицированных карт,принимать аннулированные чеки,НЕТ ПРИЕМА ЧЕКОВ В МАГАЗИНЕ,принимать чеки со 100% скидкой,<НУЛЕВОЙ> кассир,принимать чеки z-отчета'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cas-curs,hnum,cas-shft,v-shft,t-shft,dc-mask,ptrl-check,card-by-mask,annu-check,no-get-chk,is-100-discnt,zero-cashier,z-check':U ), v-tooltip-code-list))) no-error.   end.
        when 'chk-view':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Разрешена смена товара в чеке (при редакт. чека) на товар с другой ценой,Динамич. сбор инф по чекам и показ ее в пиктограммах главного меню,Видна кнопка <Cпецификация> в списке чеков - запуск заказной печати,Список префиксов номеров платежных карт ПОЛНОСТЬЮ показываемых в интерфейсе,Разрешена смена ДК при редактировании чека'.     assign     p-tooltip = "Опции интерфейса при работе с чеками"     p-label = "Опции интерфейса при работе с чеками"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ch-bc-ck,chk-inf,chk-spfc,paycardv,dc-change':U ), 'Разрешена смена товара в чеке (при редакт. чека) на товар с другой ценой,Динамич. сбор инф по чекам и показ ее в пиктограммах главного меню,Видна кнопка <Cпецификация> в списке чеков - запуск заказной печати,Список префиксов номеров платежных карт ПОЛНОСТЬЮ показываемых в интерфейсе,Разрешена смена ДК при редактировании чека'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ch-bc-ck,chk-inf,chk-spfc,paycardv,dc-change':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-sending':U then do:     v-tooltip-code-list =  '",,,,В маске цифрами указывается префикс, который отрезается при передаче кодов на кассы , а звездочками количество символов короткого кода . Пример ввода 777***"' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Пересылка товаров на кассу только полным списком,Отключена автоматическая передача товаров на кассы,Кол-во записей в пакете для пересылки на кассы,Тип касс ПО УМОЛЧАНИЮ,Докачивать чеки в продажу после чтения с кассы или завершения чека в IBS TH POS,Маски коротких кодов'.     assign     p-tooltip = "Общие опции коммуникации с кассами"     p-label = "Общие опции коммуникации с кассами"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'alllstcs,noautocs,cdpcknum,dflt-cd,process-sale,mask_s-c':U ), 'Пересылка товаров на кассу только полным списком,Отключена автоматическая передача товаров на кассы,Кол-во записей в пакете для пересылки на кассы,Тип касс ПО УМОЛЧАНИЮ,Докачивать чеки в продажу после чтения с кассы или завершения чека в IBS TH POS,Маски коротких кодов'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'alllstcs,noautocs,cdpcknum,dflt-cd,process-sale,mask_s-c':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-inf-send':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Передача налогов на кассу,Передача основного названия товара на кассу в две строки,Как основн. назв. при передаче на кассу - англ. название товара или артикул,Как дополн. назв. при передаче на кассу - локальный код товара или код партии,Дополн.название на кассу,Категорийная/количественная скидка,На кассу передавать только типы касс. платежей с атрибутом ИСПОЛЬЗУЕТСЯ,Способ задания временной скидки,Способ задания категорийной скидки,Код внешней системы для передачи соответствий на кассу'.     assign     p-tooltip = "Вид и набор передаваемой на кассу информации, используемый более чем для одного типа касс"     p-label = "Опции передачи данных на кассу"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'tax-cass,nam-2str,nam-artc,cod-pcod,name-2cd,amntdisc,cp-is-use,how-temp-disc,how-pcnt-kat,code-system':U ), 'Передача налогов на кассу,Передача основного названия товара на кассу в две строки,Как основн. назв. при передаче на кассу - англ. название товара или артикул,Как дополн. назв. при передаче на кассу - локальный код товара или код партии,Дополн.название на кассу,Категорийная/количественная скидка,На кассу передавать только типы касс. платежей с атрибутом ИСПОЛЬЗУЕТСЯ,Способ задания временной скидки,Способ задания категорийной скидки,Код внешней системы для передачи соответствий на кассу'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'tax-cass,nam-2str,nam-artc,cod-pcod,name-2cd,amntdisc,cp-is-use,how-temp-disc,how-pcnt-kat,code-system':U ), v-tooltip-code-list))) no-error.   end.
        when 'scale-inf':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Разрешенные типы весов,Название программ для работы с весами,Номера весов на объекте,Установка сроков годности вес.товара при приходе и переоценке,Отключена автоматическая передача товаров на весы'.     assign     p-tooltip = "Данные, необходимые для работы весов"     p-label = "Параметры работы с весами"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'scales-type,scales-pr,scallist,sclin-ld,noauto-scls':U ), 'Разрешенные типы весов,Название программ для работы с весами,Номера весов на объекте,Установка сроков годности вес.товара при приходе и переоценке,Отключена автоматическая передача товаров на весы'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'scales-type,scales-pr,scallist,sclin-ld,noauto-scls':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-ibm':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Код нац.вал. НА КАССЕ,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Прием чеков с продажами по группам,Тип спула,Прием чеков с продажами по группам,Многовалютные НАЛИЧНЫЕ,Выделение ставок НДС в чеке,Соответствие ставок НДС категориям налога на кассе,Спецгруппы в справочнике суммовых групп'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS IBM"     p-label = "Параметры POS IBM"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ibmrubc,ibmnalc,ibmspool,ibmgroup,multicurr,cd-vat,cdtaxlst,specgrp':U ), 'Код нац.вал. НА КАССЕ,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Прием чеков с продажами по группам,Тип спула,Прием чеков с продажами по группам,Многовалютные НАЛИЧНЫЕ,Выделение ставок НДС в чеке,Соответствие ставок НДС категориям налога на кассе,Спецгруппы в справочнике суммовых групп'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ibmrubc,ibmnalc,ibmspool,ibmgroup,multicurr,cd-vat,cdtaxlst,specgrp':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-ipc-servispl':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Код валюты соответствующий баз. вал. КАССЫ,Тип касс.платежа НАЛИЧНЫЕ с кодом валюты равным коду баз. валюты НА КАССЕ,Код дополнительной валюты для прейскурантов,Префикс весового бар-кода,Список кодов платежей по картам на кассе,Список типов касс.платежей по картам,Список валют для типов касс.платежей по картам,Префикс штучного бар-кода для весов'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS SERVISPL"     p-label = "Параметры POS IPC-SERVIS+"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ipcsbasc,ipcspayn,ipcsdobc,ipcscpfx,ipcsccrd,ipcstcrd,ipcscurc,ipcpgpfx':U ), 'Код валюты соответствующий баз. вал. КАССЫ,Тип касс.платежа НАЛИЧНЫЕ с кодом валюты равным коду баз. валюты НА КАССЕ,Код дополнительной валюты для прейскурантов,Префикс весового бар-кода,Список кодов платежей по картам на кассе,Список типов касс.платежей по картам,Список валют для типов касс.платежей по картам,Префикс штучного бар-кода для весов'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ipcsbasc,ipcspayn,ipcsdobc,ipcscpfx,ipcsccrd,ipcstcrd,ipcscurc,ipcpgpfx':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-magia-xml':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Тип касс. платежа для безналичной оплаты НА КАССЕ,Тип касс. платежа для НЕОПЛАЧЕННОГО  НА КАССЕ,Тип касс. платежа для чеков VIP и представит. расходов,Код списания для возврата-списания строки чека,Код списания для списания строки чека,Код списания для возврата-списания целого чека,Код списания для cписания всего чека,Код списания для возврата-списания заказа,Код списания для списания заказа'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS MAGIA-XML"     p-label = "Параметры POS MAGIA-XML"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'mag-bnal,magnopay,mag-vip,ret-item,wro-item,ret-chk,wro-chk,ret-ord,wro-ord':U ), 'Тип касс. платежа для безналичной оплаты НА КАССЕ,Тип касс. платежа для НЕОПЛАЧЕННОГО  НА КАССЕ,Тип касс. платежа для чеков VIP и представит. расходов,Код списания для возврата-списания строки чека,Код списания для списания строки чека,Код списания для возврата-списания целого чека,Код списания для cписания всего чека,Код списания для возврата-списания заказа,Код списания для списания заказа'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'mag-bnal,magnopay,mag-vip,ret-item,wro-item,ret-chk,wro-chk,ret-ord,wro-ord':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-NCR-GM':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Префикс весового бар-кода,Приоритеты скидок на товар при наличии скидок неск. типов,Расположение резервных копий неизменяемых <ручных настроек> для кассы,Префикс штучного бар-кода для весов'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS NCR-GM"     p-label = "Параметры POS NCR-GM"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ncrscpfx,ncrdrank,save-param,ncrpgpfx':U ), 'Префикс весового бар-кода,Приоритеты скидок на товар при наличии скидок неск. типов,Расположение резервных копий неизменяемых <ручных настроек> для кассы,Префикс штучного бар-кода для весов'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ncrscpfx,ncrdrank,save-param,ncrpgpfx':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-NCR-AS-R':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Префикс весового бар-кода,Приоритеты скидок на товар при наличии скидок неск. типов,Расположение резервных копий неизменяемых <ручных настроек> для кассы,Префикс штучного бар-кода для весов'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS NCR-AS@R"     p-label = "Параметры POS NCR-AS@R"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ncrscpfx,ncrdrank,save-param,ncrpgpfx':U ), 'Префикс весового бар-кода,Приоритеты скидок на товар при наличии скидок неск. типов,Расположение резервных копий неизменяемых <ручных настроек> для кассы,Префикс штучного бар-кода для весов'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ncrscpfx,ncrdrank,save-param,ncrpgpfx':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-omron':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Код валюты соответствующий баз. вал. КАССЫ,Тип кассового платежа соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ,Тип кассового платежа соответствующий оплате БЕЗНАЛИЧНЫЕ НА КАССЕ,Список кодов типов касс.платежа соответствующих типам платежа на кассе,Список кодов валют типов касс.платежа соответствующих типам платежа на кассе'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS OMRON"     p-label = "Параметры POS OMRON"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'omrbase,omrnal,omrntnl,omrpayl,omrcurl':U ), 'Код валюты соответствующий баз. вал. КАССЫ,Тип кассового платежа соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ,Тип кассового платежа соответствующий оплате БЕЗНАЛИЧНЫЕ НА КАССЕ,Список кодов типов касс.платежа соответствующих типам платежа на кассе,Список кодов валют типов касс.платежа соответствующих типам платежа на кассе'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'omrbase,omrnal,omrntnl,omrpayl,omrcurl':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-omron-new':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Код валюты соответствующий баз. вал. КАССЫ,Тип кассового платежа соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ,Тип кассового платежа соответствующий оплате БЕЗНАЛИЧНЫЕ НА КАССЕ,Список кодов типов касс.платежа соответствующих типам платежа на кассе,Список кодов валют типов касс.платежа соответствующих типам платежа на кассе'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS OMRON-NEW"     p-label = "Параметры POS OMRON-NEW"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'omrnbase,omrnnal,omrnntnl,omrnpayl,omrncurl':U ), 'Код валюты соответствующий баз. вал. КАССЫ,Тип кассового платежа соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ,Тип кассового платежа соответствующий оплате БЕЗНАЛИЧНЫЕ НА КАССЕ,Список кодов типов касс.платежа соответствующих типам платежа на кассе,Список кодов валют типов касс.платежа соответствующих типам платежа на кассе'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'omrnbase,omrnnal,omrnntnl,omrnpayl,omrncurl':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-IBM-XML':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Код валюты соответствующий баз. вал. КАССЫ,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Код платежа при оплате НАЛИЧНЫМИ CCM,прием чеков с продажами по группам,Многовалютные НАЛИЧНЫЕ,Выделение ставок НДС в чеке,Соответствие ставок НДС категориям налога на кассе,Спецгруппы в справочнике суммовых групп'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS IBM-XML"     p-label = "Параметры POS IBM-XML"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ibmrubc,ibmnalc,ibm-ccm,ibmgroup,multicurr,cd-vat,cdtaxlst,specgrp':U ), 'Код валюты соответствующий баз. вал. КАССЫ,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Код платежа при оплате НАЛИЧНЫМИ CCM,прием чеков с продажами по группам,Многовалютные НАЛИЧНЫЕ,Выделение ставок НДС в чеке,Соответствие ставок НДС категориям налога на кассе,Спецгруппы в справочнике суммовых групп'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ibmrubc,ibmnalc,ibm-ccm,ibmgroup,multicurr,cd-vat,cdtaxlst,specgrp':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-autotank':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Список соответствий типов кассовых платежей,Прием чеков с продажами по группам,Спецгруппы в справочнике суммовых групп'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS autotank"     p-label = "Параметры POS autotank"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cash-pay-list,ibmgroup,specgrp':U ), 'Список соответствий типов кассовых платежей,Прием чеков с продажами по группам,Спецгруппы в справочнике суммовых групп'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cash-pay-list,ibmgroup,specgrp':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-r-keeper':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Список соответствий типов кассовых платежей,Список соответствий идентификатор скидки на кассе-правило скидки в IBS TH,Формат даты при экспорте на кассу'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS R-KEEPER"     p-label = "Параметры POS R-Keeper"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cash-pay-list,dis-rule-list,date-format':U ), 'Список соответствий типов кассовых платежей,Список соответствий идентификатор скидки на кассе-правило скидки в IBS TH,Формат даты при экспорте на кассу'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cash-pay-list,dis-rule-list,date-format':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-maria':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Соответствие ставок НДС категориям налога на кассе,Соответствие типов касс.платежей для сопут.товары,Соответствие типов касс.платежей для топлива,Соответствие моделей скидок НА КАССЕ правилам скидок в IBS TH,Приоритеты скидок на товар,Приоритеты скидок на группы товаров'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы кассы MARIA"     p-label = "Параметры Кассы MARIA"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cdtaxlst,mariapayg,mariapayp,dr-list,drgrouprank,drgdsrank':U ), 'Соответствие ставок НДС категориям налога на кассе,Соответствие типов касс.платежей для сопут.товары,Соответствие типов касс.платежей для топлива,Соответствие моделей скидок НА КАССЕ правилам скидок в IBS TH,Приоритеты скидок на товар,Приоритеты скидок на группы товаров'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cdtaxlst,mariapayg,mariapayp,dr-list,drgrouprank,drgdsrank':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-IBS-TH':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Основные настройки,Работа с устройствами,Настройки для ФР,Настройки чеков,Интерфейс'.     assign     p-tooltip = "Настройки и опции работы POS IBS TH"     p-label = "Настройки и опции работы POS IBS TH"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ibs-th_main,ibs-th_devices,ibs-th_fisreg,ibs-th_rec-print,ibs-th_interface':U ), 'Основные настройки,Работа с устройствами,Настройки для ФР,Настройки чеков,Интерфейс'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ibs-th_main,ibs-th_devices,ibs-th_fisreg,ibs-th_rec-print,ibs-th_interface':U ), v-tooltip-code-list))) no-error.   end.
        when 'ibs-th_main':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Работа со сменами,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Обязателен продавец,Разрешена ручная скидка,Уровень логирования,Обнулять счетчик наличности при Z-отчете,Разрешена коррекция кол-ва'.     assign     p-tooltip = "Основные настройки и опции работы POS IBS TH"     p-label = "Основные настройки и опции"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ), 'Работа со сменами,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Обязателен продавец,Разрешена ручная скидка,Уровень логирования,Обнулять счетчик наличности при Z-отчете,Разрешена коррекция кол-ва'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ), v-tooltip-code-list))) no-error.   end.
        when 'ibs-th_devices':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Подключать ДЯ,Тип подключения ДЯ,Порт подключения ДЯ,Кол-во имп. подключения ДЯ,Работа с открытым ДЯ,Предел наличности ДЯ,Подключать кардридер,Подключать дисплей покупателя,Текст рекламы на дисплее покупателя,Тип клавиатуры,Раскладка клавиатуры,Система безналичных платежей,Тип дисплея покупателя,Порт дисплея покупателя,Тип системы видеонаблюдения,Адрес/порт системы видеонаблюдения'.     assign     p-tooltip = "Работа с устройствами POS IBS TH"     p-label = "Работа с устройствами"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ), 'Подключать ДЯ,Тип подключения ДЯ,Порт подключения ДЯ,Кол-во имп. подключения ДЯ,Работа с открытым ДЯ,Предел наличности ДЯ,Подключать кардридер,Подключать дисплей покупателя,Текст рекламы на дисплее покупателя,Тип клавиатуры,Раскладка клавиатуры,Система безналичных платежей,Тип дисплея покупателя,Порт дисплея покупателя,Тип системы видеонаблюдения,Адрес/порт системы видеонаблюдения'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ), v-tooltip-code-list))) no-error.   end.
        when 'ibs-th_fisreg':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Логический уровень датчика ДЯ в открытом состоянии,Типы кассовых платежей TH<->коды оплаты ФР,Наименования типов оплат ФР,Отрезание чеков,ФР подключен к'.     assign     p-tooltip = "Настройки для ФР POS IBS TH"     p-label = "Настройки для ФР"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ), 'Логический уровень датчика ДЯ в открытом состоянии,Типы кассовых платежей TH<->коды оплаты ФР,Наименования типов оплат ФР,Отрезание чеков,ФР подключен к'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ), v-tooltip-code-list))) no-error.   end.
        when 'ibs-th_rec-print':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Макс.сумма чека,Рекламный текст,Строки клише,Печатать код товара,Тип округления суммы чека,Коэфф. типа округления суммы чека,Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере'.     assign     p-tooltip = "Настройки для чеков POS IBS TH"     p-label = "Настройки для чеков"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'Макс.сумма чека,Рекламный текст,Строки клише,Печатать код товара,Тип округления суммы чека,Коэфф. типа округления суммы чека,Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ), v-tooltip-code-list))) no-error.   end.
        when 'ibs-th_interface':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Вид интерфейса,Раскладка'.     assign     p-tooltip = "Настройки интерфейса POS IBS TH"     p-label = "Настройки интерфейса"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'screen-type,screen-layout-id':U ), 'Вид интерфейса,Раскладка'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'screen-type,screen-layout-id':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-IBS-TH-MOB':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Основные настройки'.     assign     p-tooltip = "Настройки и опции работы POS IBS TH-MOB"     p-label = "Настройки и опции работы POS IBS TH-MOB"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ibs-th-mob_main,ibs-th-mob_rec-print':U ), 'Основные настройки'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ibs-th-mob_main,ibs-th-mob_rec-print':U ), v-tooltip-code-list))) no-error.   end.
        when 'ibs-th-mob_main':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = ',Обязателен продавец,Тип кассы, которого брать скидки'.     assign     p-tooltip = "Основные настройки и опции работы POS IBS TH-MOB"     p-label = "Основные настройки и опции"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ), ',Обязателен продавец,Тип кассы, которого брать скидки'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ), v-tooltip-code-list))) no-error.   end.
        when 'ibs-th-mob_rec-print':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере'.     assign     p-tooltip = "Настройки для чеков POS IBS TH-MOB"     p-label = "Настройки для чеков"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ), v-tooltip-code-list))) no-error.   end.
        when 'cd-type-autotank':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Список соответствий типов кассовых платежей,Прием чеков с продажами по группам,Спецгруппы в справочнике суммовых групп'.     assign     p-tooltip = "Настроечные параметры, необходимые для работы POS autotank"     p-label = "Параметры POS autotank"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cash-pay-list,ibmgroup,specgrp':U ), 'Список соответствий типов кассовых платежей,Прием чеков с продажами по группам,Спецгруппы в справочнике суммовых групп'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cash-pay-list,ibmgroup,specgrp':U ), v-tooltip-code-list))) no-error.   end.
        when 'alias-tpsi':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Тип цены при продаже товара другой фирмой,Объект-посредник для цены межфирменного перемещения'.     assign     p-tooltip = "Настройки межфирменного перемещения через ТПСИ"     p-label = "Настройки межфирменного перемещения через ТПСИ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'alias-type-price,alias-object-price':U ), 'Тип цены при продаже товара другой фирмой,Объект-посредник для цены межфирменного перемещения'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'alias-type-price,alias-object-price':U ), v-tooltip-code-list))) no-error.   end.
        when 'abc-sale-day':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'A,B,C,D,E,F'.     assign     p-tooltip = "Гарантийный запас по АBC-анализу в днях"     p-label = "Гарантийный запас по АBC-анализу в днях"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'A,B,C,D,E,F':U ), 'A,B,C,D,E,F'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'A,B,C,D,E,F':U ), v-tooltip-code-list))) no-error.   end.
        when 'abc-global':U then do:     v-tooltip-code-list =  'Способ проведения АВС : простой и двухпроходный (анализ в два прохода; первый проход деление на две группы; второй проход - простой анализ 1й группы и отсечение низкого процента во 2й группе),Количество уровней ранжирования для ABC-анализа,Количество процентов определяется типом АВС-анализа,Первая пара процентов - деление первого уровня; далее идут проценты ABC первой группы второго уровня. Последний третий элемент в этом списке процент отсекания во второй группе второго уровня.' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'ABC-анализ - способ проведения,Количество параметров для ABC-анализа,Проценты по умолчанию для ABC-анализа (простого). Уровни ранжирования,Проценты по умолчанию по Двухуровневому ABC-анализу'.     assign     p-tooltip = "Общие параметры настройки АВС-анализа"     p-label = "Глобальные настройки АВС-анализа"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'abc-mode,abc-type,abc-one,abc-two' ), 'ABC-анализ - способ проведения,Количество параметров для ABC-анализа,Проценты по умолчанию для ABC-анализа (простого). Уровни ранжирования,Проценты по умолчанию по Двухуровневому ABC-анализу'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'abc-mode,abc-type,abc-one,abc-two' ), v-tooltip-code-list))) no-error.   end.
        when 'ord-global':U then do:     v-tooltip-code-list =  '(ord-log) Логировать расчет заказа в файл рабочей директории order_raschet.txt,(ord-ofof) Если - да` то заявки типа ОФ формируются только в офисе`а не на объектах,(ord-oobj) Если - да` то при распределении заказа ОО количество товара заказывается не больше` чем остаток на объекте-поставщике,(ord-op) Заказы ОП проходят согласование в офисе и возвращаются назад на объекты с отказом или одобренными,(min-ost-day) При расчете заказа параметр Минимальный остаток на объекте или на фирме будет учитываться в днях` а не в штуках,(ordshipd) Дата ЗАКАЗ НА устанавливается по формуле СЕГОДНЯ + УКАЗАННОЕ КОЛИЧЕСТВО ДНЕЙ,(ordcyclg) Цикличные заказы строятся по специфмикации по всей группе товаров` входящий в копируемый заказ' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Логировать расчет заказа,Заявки типа ОФ формируются в офисе,В заказах ОО учитывать остаток на объектах-поставщиках,Заказы типа ОП работают по полной схеме,MIN остаток учитывается в днях,Количество дней до заказа,Цикличные заказы по всем товарам группы из спецификации'.     assign     p-tooltip = "Общие параметры настройки Заказов"     p-label = "Глобальные настройки для ЗАКАЗОВ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ord-log,ord-ofof,ord-oobj,ord-op,ord-min-ost-day,ordshipd,ordcyclg' ), 'Логировать расчет заказа,Заявки типа ОФ формируются в офисе,В заказах ОО учитывать остаток на объектах-поставщиках,Заказы типа ОП работают по полной схеме,MIN остаток учитывается в днях,Количество дней до заказа,Цикличные заказы по всем товарам группы из спецификации'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ord-log,ord-ofof,ord-oobj,ord-op,ord-min-ost-day,ordshipd,ordcyclg' ), v-tooltip-code-list))) no-error.   end.
        when 'ord-obj':U then do:     v-tooltip-code-list =  '(ord-askp) В ОРЦ спрашивать по какой цене формировать заказ: по цене объекта или объекта поставщика,(ord-obj-rc) Номер объекта ОРЦ по умолчанию,(ord-wgt-div-prc) Процент отклонения количества весового товара в большую сторону от документарного количества  при создании документа ПОСТАВКИ,(ord-11) По одному заказу вручную можно создать одну поставку и только одну приходную накладную,(ord-comp-prc) Процент исполнения заказа при котором он закрывается автоматически' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Спрашивать о цене перемещения ОРЦ ,Объект РЦ,% отклонения принимаемого количества весового товара в ПОСТАВКЕ,По Заказу ОП только одна накладная,% исполнения заказа при котором он закрывается автоматически'.     assign     p-tooltip = "Параметры настройки Заказов по объектам"     p-label = "Настройки для ЗАКАЗОВ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ord-askp,ord-obj-rc,ord-wgt-div-prc,ord-11,ord-comp-prc' ), 'Спрашивать о цене перемещения ОРЦ ,Объект РЦ,% отклонения принимаемого количества весового товара в ПОСТАВКЕ,По Заказу ОП только одна накладная,% исполнения заказа при котором он закрывается автоматически'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ord-askp,ord-obj-rc,ord-wgt-div-prc,ord-11,ord-comp-prc' ), v-tooltip-code-list))) no-error.   end.
        when 'Ass-obj':U then do:     v-tooltip-code-list =  '(ass-srokiztdel) По ИЖТ в статусе на вывод из ассортимента` анализируется дата последнего изменения ИЖТ` сравнивается с текущей и если срок больше или равен заданному параметру` товар выводится из ассортимента,(crit-srokgod) Критический срок годности товара  в днях` для вывода из "Основной группы",(ass-num-days-igt) Количество дней в статусе ИЖТ "Новинка" для автоматического перевода в ИЖТ "Основная группа",(ass-proc-matr-shabl) Допустимый процент отклонения матрицы от шаблона' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Срок удаления из Ассортиментных матриц товара с ИЖТ на ВЫВОД из АССОРТИМЕНТА,Критический срок годности товара,Количество дней в статусе ИЖТ (Новинка) для перевода в основную группу,Допустимый процент отклонения матрицы от шаблона'.     assign     p-tooltip = "Параметры настройки по Ассортиментной политике по объектам"     p-label = "Настройки по Ассортиментной политике"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'ass-srokiztdel,crit-srokgod,ass-num-days-igt,ass-proc-matr-shabl' ), 'Срок удаления из Ассортиментных матриц товара с ИЖТ на ВЫВОД из АССОРТИМЕНТА,Критический срок годности товара,Количество дней в статусе ИЖТ (Новинка) для перевода в основную группу,Допустимый процент отклонения матрицы от шаблона'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'ass-srokiztdel,crit-srokgod,ass-num-days-igt,ass-proc-matr-shabl' ), v-tooltip-code-list))) no-error.   end.
        when 'contr-in':U then do:     v-tooltip-code-list =  'Обязательная ссылка на договор в приходной накладной с НП,,Обязательная ссылка на договор в расходной накладной с НП,,Сверять количество в ПН по спецификации,' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Договор в ПН с НП,Договор в ПН с СТ,Договор в РН с НП,Договор в РН с СТ,Сверять количества в ПН,Перенумерация ПКО и РКО'.     assign     p-tooltip = "Настройки для приходных и расходных накладных и договоров в разрезе взаиморасчетов"     p-label = "Настройки для Накладных в разрезе ВЗАИМОРАСЧЕТОВ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'contr-in-income-NP,contr-in-income,contr-in-expense-NP,contr-in-expense,contr-qnty-spec,contr-recount' ), 'Договор в ПН с НП,Договор в ПН с СТ,Договор в РН с НП,Договор в РН с СТ,Сверять количества в ПН,Перенумерация ПКО и РКО'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'contr-in-income-NP,contr-in-income,contr-in-expense-NP,contr-in-expense,contr-qnty-spec,contr-recount' ), v-tooltip-code-list))) no-error.   end.
        when 'overval':U then do:     v-tooltip-code-list =  '(pr-abs-d) При закрытии переоценки удалять строки` факт остаток товара по которым = 0 (главные цены удаляются только если нет специальных или неосновных),(pr-altex) При добавлении главной цены в переоценку автоматически добавлять строки для всех существующих в данных момент неосновных цен данного товара (в т.ч. на партии и признаки).,(pr-clt-q) При добавлении строк в переоценку` если там уже есть строка для такого товара и цена в ней рассчитана` запрашивать` нужно ли ее переписывать новой (если новая не ?),(pr-discm) Используется для расчета отклонения новой продажной цены от указанной цены ( cost = среднеучетная по объекту ; sale = последняя приходная;  sale- = выбранная в интерфейсе переоценки или последняя приходная ; cost-vat = среднеучетная чистая ; prod = цена производителя ;prod-vat = цена производителя без НДС  ),(pr-dpl-q) При добавлении строк в переоценку` если есть строка для такого товара в другом приказе по этому же объекту` запрашивать подтвержение,(pr-dscnt) При закрытии новой переоценки в статус приказ предупреждать в том случае` если хотя бы одна скидка (в неосновных ценах) была изменена,(pr-equ-dq) Выбор действия над строками главных цен` цена по которым не изменилась` если для них нет неосновных... Выбор действия над товаром. pr-equ-dq=1 - не удалять ; pr-equ-dq=2 - удалять с запросом ; pr-equ-dq=3 - удалять без запроса.,(pr-incpc) Значение поля Наценка в форме ТПЛ` которое подставляется при создании нового ТПЛ,(pr-list)  Список используемых методов расчета цены в системе (Товар`Группа`УчетнаяS`Учетная`Учет-рзрвS`Учет-резерв`ПриходнаяS`Приходная`Старая`Новая`Объект`Накладная`Переоценка`ДокФормЦены`Накл-безНДС`Учет-НДСS`Учет-безНДС`Стар-безНДС`Учет+накл`Уч+накл-НДС`Единая`Отсутствует`Откат_цен`Не-считать`Производит`Произв-НДС`ПорогПр-НДС`ПорогПр+НДС`Спецификация),(pr-notls) Сохранять все цены. При добавлении главной цены в переоценку автоматически добавлять строки для всех существующих в спеццен (признаки` партии свободной зоны)` а также неосновные цены. При закрытии переоценки проверять` что ни одна из этих цен не была удалена.,(pr-parex) При добавлении главной цены в переоценку автоматически добавлять строки для всех партий свободной зоны.,(pr-print) Автоматический вызов окна печати ценников при закрытии на акт автоматической переоценки,(pr-rdc-q) При закрытии переоценки запрашивать подтверждение каждый раз` когда встречается товар` цена на который снижена,(pr-rndbs) Значение поля База округления`  которое подставляется при создании нового ТПЛ. Видно на экране и имеет смысл только при Способе округления 9-99-окончание` произвольно` вверх или коэффициент.,(pr-rndmt) Значение поля Способ округления` которое подставляется при создании нового ТПЛ: pr-round-9end - 9-окончание` pr-round-9-99end - 9-99-окончание` pr-round-integer - без-дробных` pr-round-select - произвольно` pr-round-up - вверх` pr-round-coef - коэффициент` pr-round-off - отключено.,(pr-sclex) При добавлении главной цены в переоценку автоматически добавлять строки для всех существующих в данных момент цен на признаки.,(pr-sigma) Максимально допустимое отклонение рассчитываемой в переоценке цены от текущей цены продажи товара (в процентах)` в пределах которого не происходит назначение новой цены продажи товара,(pr-goods) Запрет на определенные виды товаров в ДНЦ в УБД,(pr-goods0) Запрет на определенные виды товаров в ДНЦ в ГБД,(pr-nogds) Исключения из Запретов по pr-goods на группы товаров в ДНЦ на активных объектах в УБД. Указанные группы разрешены к включению в ДНЦ . Можно указывать нетерминальные группы. При указании головной группы ТОВАРЫ - предыдущие запреты  снимаются - ДНЦ сделать можно на все товары.При указании пусто или 0 - исключений нет и действуют только запреты указанные в параметре ЗАПРЕТ НА ОПРЕДЕЛЕННЫЕ ВИДЫ ТОВАРОВ (pr-goods),(pr-nogds0) Исключения из Запретов по pr-goods на группы товаров в ДНЦ на ГБД. Указанные группы разрешены к включению в ДНЦ . Можно указывать нетерминальные группы. При указании головной группы ТОВАРЫ - предыдущие запреты  снимаются - ДНЦ сделать можно на все товары.При указании пусто или 0 - исключений нет и действуют только запреты указанные в параметре ЗАПРЕТ НА ОПРЕДЕЛЕННЫЕ ВИДЫ ТОВАРОВ (pr-goods)' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Удалять строки товаров`по которым нет остатков,Добавлять имеющиеся неосновные цены,Запрос при замене цены при добавлении,Исходная цена для вычисления отклонения торговой наценки,Запрос при добавлении строки как в другом приказе,Предупреждать об изменении скидки,Действие над товаром`цена на который не изменилась,Для поля Наценка,Возможные методы расчета цены,Сохранять спец. и основные цены,Добавлять имеющиеся цены партий,Вызов окна печати ценников при закрытии на акт авто.переоценки,Запрос при уменьшении текущей цены,Для поля База округления,Для поля Метод округления,Добавлять имеющиеся цены признаков,MAX допустимое отклонение цены без назначения новой,Запрет на виды товаров в ДНЦ в УБД,Запрет на виды товаров в ДНЦ в ГБД,Исключения из запретов в ДНЦ на УБД,Исключения из запретов в ДНЦ на ГБД'.     assign     p-tooltip = "Настройки для переоценок по объектам "     p-label = "Настройки для ПЕРЕОЦЕНОК"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'pr-abs-d,pr-altex,pr-clt-q,pr-discm,pr-dpl-q,pr-dscnt,pr-equ-dq,pr-incpc,pr-list,pr-notls,pr-parex,pr-print,pr-rdc-q,pr-rndbs,pr-rndmt,pr-sclex,pr-sigma,pr-goods,pr-goods0,pr-nogds,pr-nogds0' ), 'Удалять строки товаров`по которым нет остатков,Добавлять имеющиеся неосновные цены,Запрос при замене цены при добавлении,Исходная цена для вычисления отклонения торговой наценки,Запрос при добавлении строки как в другом приказе,Предупреждать об изменении скидки,Действие над товаром`цена на который не изменилась,Для поля Наценка,Возможные методы расчета цены,Сохранять спец. и основные цены,Добавлять имеющиеся цены партий,Вызов окна печати ценников при закрытии на акт авто.переоценки,Запрос при уменьшении текущей цены,Для поля База округления,Для поля Метод округления,Добавлять имеющиеся цены признаков,MAX допустимое отклонение цены без назначения новой,Запрет на виды товаров в ДНЦ в УБД,Запрет на виды товаров в ДНЦ в ГБД,Исключения из запретов в ДНЦ на УБД,Исключения из запретов в ДНЦ на ГБД'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'pr-abs-d,pr-altex,pr-clt-q,pr-discm,pr-dpl-q,pr-dscnt,pr-equ-dq,pr-incpc,pr-list,pr-notls,pr-parex,pr-print,pr-rdc-q,pr-rndbs,pr-rndmt,pr-sclex,pr-sigma,pr-goods,pr-goods0,pr-nogds,pr-nogds0' ), v-tooltip-code-list))) no-error.   end.
        when 'nakl_par':U then do:     v-tooltip-code-list =  '(date-close-period) Дата закрытия периода` нельзя удалять или корректировать на факт документы раньше этой даты,(stfactdt) При добавлении документов внешнего ПН` РН и межфирменного перемещения устанавливается дата факт равной дате документа. Объект должен быть несменным,(type-vat) Тип заведения НДС по умолчанию,(type-slt) Тип заведения НсП по умолчанию,(intprmvq) Спрашивать по какой цене делать внутр.расход` по цене источника или приемника,(minusprt) Автоматическая коррекция отрицательных партий по внешнему и внутреннему  приходу и возврату,(avail-on-date) В расходе резервируются  только партии доступные на дату док-та,(proxycrd) Обязательно ли нужно заполнять доверенность для внешнего расхода и возврата поставщику,(factorrt) Для румынской формулы расчета цены,(inp_sum)  В ПН заведение по сумме или по цене нельзя изменить,(reasonm) Обязательное заведение значения поля ПРИЧИНА ЗАВЕДЕНИЯ ДОКУМЕНТА,(back-date) Разрешено закрывать и удалять документы задним числом,(not-ord) Запрещено заводить приходную накладную` она порождается на основе заказа,(reasonme) Документы - исключения` по ним не Обязательное заведение значения поля ПРИЧИНА ЗАВЕДЕНИЯ ДОКУМЕНТА,(neg-ask) При резервированни товара` если отрицательные остатки запрещены и остатка не хватает выдавать предупреждение,(vat-goods) По-умолчанию в ПН подставлять НДС из карточки товара,(inv-ship) Требуется заполнять поля инвойс` номер и дату отгрузки в ПН,(round-vat-sum) В линии накладной округлять НДС до 2 знаков,(gtd-to-imp-prod) Запрещено закрытие на факт ПН` если не указана ГТД для товара` у производителя которого стоит атрибут - Импортный производитель,(exc-max-qnty) Запрещено закрытие на факт ПН` если после закрытия остатки товара будут больше` чем установленные максимальные остатки на объекте,(mark-alchol) Помарочный учет движения алкогольной продукции,(attr-PN) Обязательные атрибуты накладной приход внешний топливо,(attr-mandatory-gds-in-wayb)  Обязательные атрибуты накладной приход внешний товары,(attr-mandatory-gds-ret-wayb) Обязательные атрибуты накладной возврат поставщику товары,(attr-mandatory-gds-exp-wayb) Обязательные атрибуты накладной расход внешний товары,(edit-fact-wayb) Разрешено вводить фактическое количество в статусе Накл-,(reasons-for-return) Основания для внешнего расхода по которым будет определяться что делаем возврат поставщику,(reasons-write-off) Причины списания' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Дата закрытия периода,Дата факт = Дате документа (для внешних ПН РН и МФ ),Тип заведения НДС по умолчанию,Тип заведения НсП по умолчанию,Спрашивать о цене перемещения,Автокоррекция отрицательных партий по Приходу и Возврату,В расход только партии доступные на дату док-та,Доверенность для внешней РН и возврата поставщику,Коэффициент дорожного налога,В ПН заведение по сумме или по цене нельзя изменить,Обязательное заведение ПРИЧИНЫ ЗАВЕДЕНИЯ ДОКУМЕНТА,Разрешено работать с документами задним числом,Запрет на ручной ввод ПН без Заказа,Документы-исключения,Предупреждение в РН при запрете отриц.остатков о нехватке товара,В ПН подставлять НДС из карточки товара,Инвойс-отгузка,Принудительное округление НДС до 2 знаков после запятой в ПН и РН,В ПН Обязательно указывать ГТД для товаров с импортным производителем,Запрещен приход при превышении максимальных остатков,Помарочный учет движения алкогольной продукции,Приход внешний топливо,Приход внешний товары,Возврат поставщику товары,Расход внешний товары,Разрешено вводить фактическое количество в статусе Накл-,Основания для возврата,Причины списания'.     assign     p-tooltip = "Общие Настройки для Складских документов"     p-label = "Настройки для Складских документов"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'date-close-period,stfactdt,type-vat,type-slt,intprmvq,minusprt,avail-on-date,proxycrd,factorrt,inp_sum,reasonm,back-date,not-ord,reasonme,neg-ask,vat-goods,inv-ship,round-vat-sum,gtd-to-imp-prod,exc-max-qnty,mark-alchol,attr-PN,attr-mandatory-gds-in-wayb,attr-mandatory-gds-ret-wayb,attr-mandatory-gds-exp-wayb,edit-fact-wayb,reasons-for-return,reasons-write-off' ), 'Дата закрытия периода,Дата факт = Дате документа (для внешних ПН РН и МФ ),Тип заведения НДС по умолчанию,Тип заведения НсП по умолчанию,Спрашивать о цене перемещения,Автокоррекция отрицательных партий по Приходу и Возврату,В расход только партии доступные на дату док-та,Доверенность для внешней РН и возврата поставщику,Коэффициент дорожного налога,В ПН заведение по сумме или по цене нельзя изменить,Обязательное заведение ПРИЧИНЫ ЗАВЕДЕНИЯ ДОКУМЕНТА,Разрешено работать с документами задним числом,Запрет на ручной ввод ПН без Заказа,Документы-исключения,Предупреждение в РН при запрете отриц.остатков о нехватке товара,В ПН подставлять НДС из карточки товара,Инвойс-отгузка,Принудительное округление НДС до 2 знаков после запятой в ПН и РН,В ПН Обязательно указывать ГТД для товаров с импортным производителем,Запрещен приход при превышении максимальных остатков,Помарочный учет движения алкогольной продукции,Приход внешний топливо,Приход внешний товары,Возврат поставщику товары,Расход внешний товары,Разрешено вводить фактическое количество в статусе Накл-,Основания для возврата,Причины списания'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'date-close-period,stfactdt,type-vat,type-slt,intprmvq,minusprt,avail-on-date,proxycrd,factorrt,inp_sum,reasonm,back-date,not-ord,reasonme,neg-ask,vat-goods,inv-ship,round-vat-sum,gtd-to-imp-prod,exc-max-qnty,mark-alchol,attr-PN,attr-mandatory-gds-in-wayb,attr-mandatory-gds-ret-wayb,attr-mandatory-gds-exp-wayb,edit-fact-wayb,reasons-for-return,reasons-write-off' ), v-tooltip-code-list))) no-error.   end.
        when 'fin-global':U then do:     v-tooltip-code-list =  '(fo-buyer-nws) Где могут создаваться ФО покупателей,(fo-supp-nws) Как ходят ФО поставщиков по новостям,(fo-fact) Если параметр включен _то при закрытиии финансового обязательства на ФАКТ дата закрытия будет равна ДАТЕ ФАКТ накладной_ на основе которой и было создано ФО. Если ФО ручное или создано не по накладным дата закрытия = текущая дата объекта,(fo-mc-mode) 0-Простая старая схема / 1-Мастер договор / 2-Смешанная схема,(add-conn-avt) Если параметр включен _то при при оплате ФО связь с платежем будет формироваться автоматически,(del-conn-avt) Если параметр включен _то при удалении платежа связи платежа с ФО будут удаляться автоматически,Генерировать ФО для заказов и/или накладных' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Где могут создаваться ФО покупателей,Как ходят ФО поставщиков по новостям,Дата закрытия ФО соответствует дате закрытия накладной,Режим работы ФО с мастер договорами,Формирование связи ФО и платежей автоматически при оплате,Удалять связи платежа с ФО автоматом при удалении платежа,Генерировать ФО для:'.     assign     p-tooltip = "Общие параметры настройки для Взаиморасчетов"     p-label = "Глобальные настройки для Взаиморасчетов"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'fo-buyer-nws,fo-supp-nws,fo-fact,fo-mc-mode,add-conn-avt,del-conn-avt,fo-gen' ), 'Где могут создаваться ФО покупателей,Как ходят ФО поставщиков по новостям,Дата закрытия ФО соответствует дате закрытия накладной,Режим работы ФО с мастер договорами,Формирование связи ФО и платежей автоматически при оплате,Удалять связи платежа с ФО автоматом при удалении платежа,Генерировать ФО для:'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'fo-buyer-nws,fo-supp-nws,fo-fact,fo-mc-mode,add-conn-avt,del-conn-avt,fo-gen' ), v-tooltip-code-list))) no-error.   end.
        when 'fin-plan':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Остаток на начало дня в кассах,План прихода,Прочие доходы,Прочие расходы'.     assign     p-tooltip = "Плановые цифры денежных средств - Взаиморасчеты"     p-label = "Плановые цифры денежных средств"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'fin-ostatok-start,fin-plan-pri,fin-proch,fin-proch-ras':U ), 'Остаток на начало дня в кассах,План прихода,Прочие доходы,Прочие расходы'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'fin-ostatok-start,fin-plan-pri,fin-proch,fin-proch-ras':U ), v-tooltip-code-list))) no-error.   end.
        when 'gds-ref':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Разрешено добавление товаров с одинаковыми именами,Обязательное заведение ДопБК при добавлении товара,Выключение повторных ДопБК при появлении новых,Запрет повторных ДопБК для одного производителя,Запрет повторных ДопБК,Импортировать код ТНВЭД в карточку товара,Уникальный цифровой артикул`создание доп. БК = артикулу,Разрешено создавать глобальный весовые коды,Гр.товаров по умолч.,Схема хранения фото,Опции копирования допинфо по товару ( при соз-дании товара копированием),Заказные поля в экране покупателя,Запрещена работа с Доп-БК'.     assign     p-tooltip = "Набор опций работы со справочником товаров"     p-label = "Набор опций работы со справочником товаров"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'dif-nam1,dif-nam2,dpl-off,dif-pdbc,pbc-veto,tnvedimp,unq-artc,is-scgb,dfltggrp,shema-foto,gds-copy,gdsscrvw' ), 'Разрешено добавление товаров с одинаковыми именами,Обязательное заведение ДопБК при добавлении товара,Выключение повторных ДопБК при появлении новых,Запрет повторных ДопБК для одного производителя,Запрет повторных ДопБК,Импортировать код ТНВЭД в карточку товара,Уникальный цифровой артикул`создание доп. БК = артикулу,Разрешено создавать глобальный весовые коды,Гр.товаров по умолч.,Схема хранения фото,Опции копирования допинфо по товару ( при соз-дании товара копированием),Заказные поля в экране покупателя,Запрещена работа с Доп-БК'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'dif-nam1,dif-nam2,dpl-off,dif-pdbc,pbc-veto,tnvedimp,unq-artc,is-scgb,dfltggrp,shema-foto,gds-copy,gdsscrvw' ), v-tooltip-code-list))) no-error.   end.
        when 'gds-ref_obj':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Гр.товаров по умолч.,Заказные поля в экране покупателя,Запрещена работа с Доп-БК'.     assign     p-tooltip = "Набор опций работы со справочником товаров в контексте объекта"     p-label = "Набор опций работы со справочником товаров в контексте объекта"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'dfltggrp,gdsscrvw,chg-bcod,image-dir':U ), 'Гр.товаров по умолч.,Заказные поля в экране покупателя,Запрещена работа с Доп-БК'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'dfltggrp,gdsscrvw,chg-bcod,image-dir':U ), v-tooltip-code-list))) no-error.   end.
        when 'dc-ref':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Разрешено добавление ДК с лидирующими нулями,Маскирование ДК'.     assign     p-tooltip = "Набор опций работы со ДК"     p-label = "Набор опций работы со справочником ДК"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'l-zeros,l-mask':U ), 'Разрешено добавление ДК с лидирующими нулями,Маскирование ДК'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'l-zeros,l-mask':U ), v-tooltip-code-list))) no-error.   end.
        when 'cli-all':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Опции уникальности ,Разрешен ввод некорректного '.     assign     p-tooltip = "Набор опций работы со справочником клиентов"     p-label = "Набор опций работы со справочником клиентов"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'inn-uniq,nocorinn':U ), 'Опции уникальности ,Разрешен ввод некорректного '))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'inn-uniq,nocorinn':U ), v-tooltip-code-list))) no-error.   end.
        when 'cashpays':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Определение групп типов кассовых платежей'.     assign     p-tooltip = "Набор опций работы со справочником типов кассовых платежей"     p-label = "Набор опций работы со справочником типов кассовых платежей"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cpgrpnam':U ), 'Определение групп типов кассовых платежей'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cpgrpnam':U ), v-tooltip-code-list))) no-error.   end.
        when 'wthdoc':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Закрывать документы при формировании по чекам МЦ,Проверка на наличие физ. лиц в документах МЦ '.     assign     p-tooltip = "Набор опций работы c МЦ"     p-label = "Набор опций работы c МЦ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'clsfact,prsdoc':U ), 'Закрывать документы при формировании по чекам МЦ,Проверка на наличие физ. лиц в документах МЦ '))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'clsfact,prsdoc':U ), v-tooltip-code-list))) no-error.   end.
        when 'wthdoc_obj':U then do:     v-tooltip-code-list =  'stfactpref Префикс номера счета-фактуры при автоматической генерации номера в документах МЦ , rangerule  Срок годности устанавливается от даты счета-фактуры. Eсли счет-фактура не указан в документе` срок годности определяется от даты документа.,clsfact    Автоматически закрывать до статуса Факт документы МЦ в режиме формирования документов по чекам МЦ (инкассация` кассовый фонд...),inobjauto  Автоматическое формирование документов перемещения МЦ при закрытии продажи,inwpcode   МХ МЦ для документов перемещения` формируемых при закрытии продажи,numsfact   Последний сгенерированный номер счет-фактуры,prsdoc     При сохранении документа проверять корректно ли указаны ответственные лица' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Префикс номера счета-фактуры,Правило автоматического установления срока годности партий серийных МЦ,Закрывать документы при формировании по чекам МЦ,При закрытии продажи автоматически формировать документ перемещения ,МХ формирования документов перемещени,Последний номер счет-фактуры,Проверка на наличие физ. лиц в документах МЦ'.     assign     p-tooltip = "Набор опций работы с МЦ в контексте объекта"     p-label = "Набор опций работы с МЦ в контексте объекта"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'stfactpref,rangerule,clsfact,inobjauto,inwpcode,numsfact,prsdoc' ), 'Префикс номера счета-фактуры,Правило автоматического установления срока годности партий серийных МЦ,Закрывать документы при формировании по чекам МЦ,При закрытии продажи автоматически формировать документ перемещения ,МХ формирования документов перемещени,Последний номер счет-фактуры,Проверка на наличие физ. лиц в документах МЦ'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'stfactpref,rangerule,clsfact,inobjauto,inwpcode,numsfact,prsdoc' ), v-tooltip-code-list))) no-error.   end.
        when 'attr-wthrep':U then do:     v-tooltip-code-list =  'Список групп клиентов для формирования сводных отчетов,Не передавать по СПН документы уничтожения и перемещения в зоне погашения на УБД' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Опции сводных отчетов по МЦ,Не передавать по СПН документы уничтожения и перемещения погашенных МЦ на УБД'.     assign     p-tooltip = "Глобальные настройки для работы с МЦ"     p-label = "Глобальные настройки для работы с МЦ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cligrplist,docdstnws':U ), 'Опции сводных отчетов по МЦ,Не передавать по СПН документы уничтожения и перемещения погашенных МЦ на УБД'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cligrplist,docdstnws':U ), v-tooltip-code-list))) no-error.   end.
        when 'rum':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Операции с товарами,Операции с клиентами,Операции с группами товаров,Операции с группами клиентов,Операции с чеками на POS IBS-TH,Операции с чеками на POS IBS-TH-MOB,Операции в системе электронного документооборота,Операции со справочниками,Операции с ДНЦ и переоценками,Отчеты,Операции с заказами,Комбинированные алгоритмы,Операции с фин.документами'.     assign     p-tooltip = "Машина правил (настройка встраиваемых процедур)"     p-label = "Машина правил (встраиваемые процедуры)"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'goods,clients,gds-grp,cli-grp,chk-doc_ibs-th,chk-doc_ibs-th-mob,edoc,thref,pdf,rep,ord,cmb,fdoc':U ), 'Операции с товарами,Операции с клиентами,Операции с группами товаров,Операции с группами клиентов,Операции с чеками на POS IBS-TH,Операции с чеками на POS IBS-TH-MOB,Операции в системе электронного документооборота,Операции со справочниками,Операции с ДНЦ и переоценками,Отчеты,Операции с заказами,Комбинированные алгоритмы,Операции с фин.документами'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'goods,clients,gds-grp,cli-grp,chk-doc_ibs-th,chk-doc_ibs-th-mob,edoc,thref,pdf,rep,ord,cmb,fdoc':U ), v-tooltip-code-list))) no-error.   end.
        when 'rum_obj':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Операции с чеками на POS IBS-TH,Операции с чеками на POS IBS-TH-MOB,Отчеты'.     assign     p-tooltip = "Машина правил (настройка встраиваемых процедур) в контексте объекта"     p-label = "Машина правил (встраиваемые процедуры) в контексте объекта"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'chk-doc_ibs-th,chk-doc_ibs-th-mob,rep':U ), 'Операции с чеками на POS IBS-TH,Операции с чеками на POS IBS-TH-MOB,Отчеты'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'chk-doc_ibs-th,chk-doc_ibs-th-mob,rep':U ), v-tooltip-code-list))) no-error.   end.
        when 'easyfuel':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Номер МАСТЕР-КЛЮЧА'.     assign     p-tooltip = "Опции работы с системой EasyFuel"     p-label = "Опции работы с системой EasyFuel"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'master-key':U ), 'Номер МАСТЕР-КЛЮЧА'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'master-key':U ), v-tooltip-code-list))) no-error.   end.
        when 'arh-global':U then do:     v-tooltip-code-list =  '(apusharh) Автоматический запуск расчета арховов после приема новостей,(btprskip) Заблокировать выполнение некоторых типов отложенных заданий. Типы необходимо перечислить через запятую. Возможные типы: trntx - расчет trn-tax` trnhd - расчет шапки документов` arh - расчет архивов' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Автоматический запуск расчета архивов после приема новостей,Список отложенных заданий которые надо пропустить'.     assign     p-tooltip = "Настройки для Архивов глобально"     p-label = "Настройки для Архивов"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'apusharh,btprskip' ), 'Автоматический запуск расчета архивов после приема новостей,Список отложенных заданий которые надо пропустить'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'apusharh,btprskip' ), v-tooltip-code-list))) no-error.   end.
        when 'inv-global':U then do:     v-tooltip-code-list =  '(invclcas) Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ДОПОЛНИТЕЛЬНЫЕ СУММЫ ON-LINE в документы инвентаризации,(invclcwt) Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ЕСТЕСТВЕННУЮ УБЫЛЬ ON-LINE в документе инвентаризации,(inv-prs) Причина заведения документа для инвентаризации использующейся как документ пересортицы' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ДОПОЛНИТЕЛЬНЫЕ СУММЫ ON-LINE в документы инвентаризации,Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ЕСТЕСТВЕННУЮ УБЫЛЬ ON-LINE в документе инвентаризации,Причина заведения документа для инвентаризации использующейся как документ пересортицы'.     assign     p-tooltip = "Настройки для ИНВЕНТАРИЗАЦИИ global"     p-label = "Настройки для ИНВЕНТАРИЗАЦИИ глобально"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'invclcas,invclcwt,inv-prs' ), 'Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ДОПОЛНИТЕЛЬНЫЕ СУММЫ ON-LINE в документы инвентаризации,Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ЕСТЕСТВЕННУЮ УБЫЛЬ ON-LINE в документе инвентаризации,Причина заведения документа для инвентаризации использующейся как документ пересортицы'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'invclcas,invclcwt,inv-prs' ), v-tooltip-code-list))) no-error.   end.
        when 'inv-obj':U then do:     v-tooltip-code-list =  '(invclcsp) УСТАНОВКА В YES ЗАМЕДЛЯЕТ РАСЧЕТ ИНВЕНТАРИЗАЦИИ В ДВА РАЗА. Реально нужен только для отдела ЦУМа для обсчета золота,(invdnull) Удаление нулевых строк (с количествами <было> и <стало> равными 0) в документе инвентаризации в момент закрытия документа до статуса <факт> (для сокращения объемов документа инвентаризации),(mxpcdcp) Максимальное процентное отклонение уменьшения цены в документе пересортица,(mxpcicp) Максимальное процентное отклонение увеличения цены в документе пересортица,(mxsmdcp) Максимальное абсолютное отклонение уменьшения цены в документе пересортица,(mxsmicp) Максимальное абсолютное отклонение увеличения цены в документе пересортица,(pstunqtn) Возможность пересортицы товаров с одной единицей измерения в разных количествах,(wastage) Начисление естественной убыли,(pstgrp) Установка Yes запрещает добавлять товары из разных групп,(pstunit) Установка Yes запрещает добавлять товары с разными единицами измерения,(izlcstpr) Yes - излишки в инвентаризации приходуются по продажным ценам без НДС,' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Рассчитывать суммы в единицах поставщика,Удаление нулевых строк в инвентаризации,Максимальное процентное отклонение уменьшения цены в документе пересортица,Максимальное процентное отклонение увеличения цены в документе пересортица,Максимальное абсолютное отклонение уменьшения цены в документе пересортица,Максимальное абсолютное отклонение увеличения цены в документе пересортица,Возможность пересортицы товаров с одной единицей измерения в разных количествах,Начисление естественной убыли,Запрещена пересортица товаров из разных групп,Запрещена пересортица товаров с разными единицами измерения,Приходовать излишки по продажным ценам без НДС,Разрешить создание инвентаризации с отрицательными количествами'.     assign     p-tooltip = "Настройки для ИНВЕНТАРИЗАЦИИ по объектам"     p-label = "Настройки для ИНВЕНТАРИЗАЦИИ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'invclcsp,invdnull,mxpcdcp,mxpcicp,mxsmdcp,mxsmicp,pstunqtn,wastage,pstgrp,pstunit,izlcstpr,minus' ), 'Рассчитывать суммы в единицах поставщика,Удаление нулевых строк в инвентаризации,Максимальное процентное отклонение уменьшения цены в документе пересортица,Максимальное процентное отклонение увеличения цены в документе пересортица,Максимальное абсолютное отклонение уменьшения цены в документе пересортица,Максимальное абсолютное отклонение увеличения цены в документе пересортица,Возможность пересортицы товаров с одной единицей измерения в разных количествах,Начисление естественной убыли,Запрещена пересортица товаров из разных групп,Запрещена пересортица товаров с разными единицами измерения,Приходовать излишки по продажным ценам без НДС,Разрешить создание инвентаризации с отрицательными количествами'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'invclcsp,invdnull,mxpcdcp,mxpcicp,mxsmdcp,mxsmicp,pstunqtn,wastage,pstgrp,pstunit,izlcstpr,minus' ), v-tooltip-code-list))) no-error.   end.
        when 'rezerv-global':U then do:     v-tooltip-code-list =  '(parts-bc) Глобальный. При закрытии накладной в статус накл+ на партии создается бар-код,' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Создавать ли бар-коды партий'.     assign     p-tooltip = "Настройки для РЕЗЕРВИРОВАНИЯ глобально"     p-label = "Настройки для РЕЗЕРВИРОВАНИЯ глобально"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'parts-bc' ), 'Создавать ли бар-коды партий'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'parts-bc' ), v-tooltip-code-list))) no-error.   end.
        when 'rezerv-obj':U then do:     v-tooltip-code-list =  '(invngbeg) Начало диапазона для резервирования отрицательных партии по функции -Партии,(invngend) Конец диапазона для резервирования отрицательных партии по функции -Партии,(negmanuf) При указании значения disable запрещается порождение отрицательных партий в производстве,(negparts) При указании значения disable запрещается порождение отрицательных партий во всех документах (дальнейший анализ не производится),(prcshfc0) Допускается закрытие порожденных партий с учетной ценой 0 в документах продажи` возврата в магазине,(prcshrs0) Действие при созд порожд партии для док расх-возв продажи в маг-не с 0 учет цен    disable - партии не создаются` enable - партии создаются без подтверждения` prompt - выводится диалог подтверждения цены` manual - выводится диалог редактирования партий,(prcshrs1) Действие при созд порожд партии по док-ту расх-возвр прод в маг-не с уч цен <> 0   disable - партии не создаются` enable - партии создаются без подтверждения` prompt - выводится диалог подтверждения цены` manual - выводится диалог редактирования партий,(prdocfc0) Допускается закрытие порожденных партий с учетной ценой 0 во всех документах` кроме расхода`. возврата продажи в магазине,(prdocrs0) при порожд партии для всех док-ов кроме расх-возвр прод в маг-не с 0 уч цен    disable - партии не создаются` enable - партии создаются без подтверждения` prompt - выводится диалог подтверждения цены` manual - выводится диалог редактирования партий,(prdocrs1) при порожд партии для всех док-ов кроме расх-возвр прод в маг-не с уч цен <> 0  disable - партии не создаются` enable - партии создаются без подтверждения` prompt - выводится диалог подтверждения цены` manual - выводится диалог редактирования партий,(prsalpr)  Для порожд.партий без закуп.цены взять цену по розничной цене без НДС (TRN125) Производить порождение отрицательных партий в случае отсутствия закупочной цены по розничной цене без НДС' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Диапазон для резервирования отрицательных партии по <-Партии>,-,Запрещается порождение отрицательных партий в производстве,Запрещается порождение отрицательных партий во всех документах (дальнейший анализ не производится),Допускается закрытие порожденных партий с учетной ценой 0 в документах продажи` возврата в магазине,Действие при созд порожд партии для док расх-возв продажи в маг-не с 0 учет цен,Действие при созд порожд партии по док-ту расх-возвр прод в маг-не с уч цен <> 0,Допускается закрытие порожденных партий с учетной ценой 0 во всех документах` кроме расхода` возврата продажи в магазине,При порожд партии для всех док-ов кроме расх-возвр прод в маг-не с 0 уч цен,При порожд партии для всех док-ов кроме расх-возвр прод в маг-не с уч цен <> 0,Для порожд партий без закуп цены взять цену по розничной цене без НДС (TRN125)'.     assign     p-tooltip = "Настройки для РЕЗЕРВИРОВАНИЯ по объектам"     p-label = "Настройки для РЕЗЕРВИРОВАНИЯ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'invngbeg,invngend,negmanuf,negparts,prcshfc0,prcshrs0,prcshrs1,prdocfc0,prdocrs0,prdocrs1,prsalpr' ), 'Диапазон для резервирования отрицательных партии по <-Партии>,-,Запрещается порождение отрицательных партий в производстве,Запрещается порождение отрицательных партий во всех документах (дальнейший анализ не производится),Допускается закрытие порожденных партий с учетной ценой 0 в документах продажи` возврата в магазине,Действие при созд порожд партии для док расх-возв продажи в маг-не с 0 учет цен,Действие при созд порожд партии по док-ту расх-возвр прод в маг-не с уч цен <> 0,Допускается закрытие порожденных партий с учетной ценой 0 во всех документах` кроме расхода` возврата продажи в магазине,При порожд партии для всех док-ов кроме расх-возвр прод в маг-не с 0 уч цен,При порожд партии для всех док-ов кроме расх-возвр прод в маг-не с уч цен <> 0,Для порожд партий без закуп цены взять цену по розничной цене без НДС (TRN125)'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'invngbeg,invngend,negmanuf,negparts,prcshfc0,prcshrs0,prcshrs1,prdocfc0,prdocrs0,prdocrs1,prsalpr' ), v-tooltip-code-list))) no-error.   end.
        when 'nakl-glob':U then do:     v-tooltip-code-list =  '(nocurbas) no - запрещает закрывать документ  без текущей продажной цены по товару` yes - разрешает закрывать документ без текущей продажной цены по товару` no_today - запрещает закрывать документы сегодняшним числом без текущей пр. цены и  задает вопрос по заднему  числу` question - запрашивает подтверждение на закрытие документов с товарами без продажной цены,(chk-prs)  Проверять менеджера и исполнителя в документах,(convimp)  Доступен ли импорт с конвертацией,(curcli)   Валюта клиента может отличаться от нац.валюты во внешней приходной накладной,(is-bcdoc) Работает ли кнопка бар-код во внешней приходной накладной,(is-ov)    Работает ли поле наценки (калькулятор) в накладной внешнего прихода,(multdtyp) Редактирование типа НДС и НП для внешней ПН,(noapndsc) Переписывать логи при чтении со сканера,(part-prc) Редактировать ли учетные цены создаваемых партий в ПН,(prc-exp)  Максимальный процент транспортных и прочих расходов в ПН,(rnd-znk) 0 - не использовать копейки` 2 - копейки есть,(slt-ext) Значение НсП вводимое в ПН` Например «0`5»,(vat-ext) Значение НДС вводимое в ПН` Например «0`10`20»,(vat-sum) Задание НДС через сумму в приходной накладной' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Обработка товара в документе без текущей продажной цены,Проверять менеджера и исполнителя,Доступен ли импорт с конвертацией,Валюта клиента может отличаться от нац.вал. во внешней ПН,Работает ли кнопка бар-код в ПН,Работает ли поле наценки (калькулятор) в ПН,Редактирование типа НДС и НП для внешней ПН,Переписывать логи при чтении со сканера,Редактировать ли учетные цены создаваемых партий в ПН,Максимальный процент транспортных и прочих расходов в ПН,До какого знака следует округлять проверяя ПН,НсП поставщика в ПН,НДС во внешней ПН,Задание НДС через сумму в ПН,'.     assign     p-tooltip = "Настройки для Складским документам глобально"     p-label = "По Складским документам глобально"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'nocurbas,chk-prs,convimp,curcli,is-bcdoc,is-ov,multdtyp,noapndsc,part-prc,prc-exp,rnd-znk,slt-ext,vat-ext,vat-sum' ), 'Обработка товара в документе без текущей продажной цены,Проверять менеджера и исполнителя,Доступен ли импорт с конвертацией,Валюта клиента может отличаться от нац.вал. во внешней ПН,Работает ли кнопка бар-код в ПН,Работает ли поле наценки (калькулятор) в ПН,Редактирование типа НДС и НП для внешней ПН,Переписывать логи при чтении со сканера,Редактировать ли учетные цены создаваемых партий в ПН,Максимальный процент транспортных и прочих расходов в ПН,До какого знака следует округлять проверяя ПН,НсП поставщика в ПН,НДС во внешней ПН,Задание НДС через сумму в ПН,'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'nocurbas,chk-prs,convimp,curcli,is-bcdoc,is-ov,multdtyp,noapndsc,part-prc,prc-exp,rnd-znk,slt-ext,vat-ext,vat-sum' ), v-tooltip-code-list))) no-error.   end.
        when 'prt-glob':U then do:     v-tooltip-code-list =  '(invprn0)   Глобальный. Печатать строки с 0 до и после инвентаризации в инвент. описи,(outprncd)  Глобальный. В печатных формах печатать после названия фирмы или клиента в скобках код фирмы или клиента,(outrecv)   Глобальный. Через запятую без пробелов torg12 - ТОРГ12,(sort-prd)  Глобальный. Включение  сортировки по производителю в старых печатных формах,,(outprops)  Глобальный. Печатать сумму ВСЕГО К ОПЛАТЕ в счете-фактуре прописью,(rep-artic) Глобальный. Печатать артикул в названии товара в Счет-фактуре и Торг-12' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Печатать строки с 0 до и после инвентаризации в инвент_описи,Печатать код фирмы (клиента) при печати названия,Печать реквизитов на две строки,Сортировка по производителю в старых формах,ТОРГ-2 -только товары с расхождениями,Печатать сумму в счете-фактуре прописью,Печатать артикул в названии товара в Счет-фактуре и Торг-12'.     assign     p-tooltip = "параметры по Печати форм глобально"     p-label = "параметры по Печати форм глобально"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'invprn0,outprncd,outrecv,sort-prd,torg2-no,outprops,rep-artic' ), 'Печатать строки с 0 до и после инвентаризации в инвент_описи,Печатать код фирмы (клиента) при печати названия,Печать реквизитов на две строки,Сортировка по производителю в старых формах,ТОРГ-2 -только товары с расхождениями,Печатать сумму в счете-фактуре прописью,Печатать артикул в названии товара в Счет-фактуре и Торг-12'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'invprn0,outprncd,outrecv,sort-prd,torg2-no,outprops,rep-artic' ), v-tooltip-code-list))) no-error.   end.
        when 'prt-obj':U then do:     v-tooltip-code-list =  '(FGdsNinD) Наименование товара в накладных печатать полностью (в несколько строчек),(in-docpr) Вызывается процедура печати внешней накладной. Если пусто вызывается стандартная приходная накладна,(outappr)  Список печатных форм` для которых в заголовках печатать <Утверждена постанавлением...>,(outdate)  Список печатных форм` для которых не печатать поле <дата>,(outdisc)  Список печатных форм` для которых не печатать поле <скидка>,(outegrp)  Список печатных форм` для которых не печатать поле <реквизиты ЕГРИП>,(outhold)  Список печатных форм` для которых должна быть задана фирма для печати накладных,(outnum)   Список печатных форм` для которых не печатать <номер документа>,(outobj)   Список печатных форм` для которых в качестве адреса собственной фирмы  в графе <Грузоотправитель> для расходных документов и <Грузополучатель> для приходных накладных печатать адрес объекта,(outprim)  Список печатных форм` для которых не печатать <примечание>,(outrubl)  Список печатных форм` для которых не печатать <Цены указаны в нац.вал.>,(outssdoc) Как печатать номера платёжно-расчётного документа в счёт-фактуре. Номер и дата из: nacl - накладной` findoc - расчётного документа. Если ничего не задано или задано неверно` номер печататься не будет,(outsubs)  Список печатных форм` для которых не печатать <подписи из БД>,(outt12)   Список печатных форм` для которых не печатать последнюю колонку,(outares)  Список печатных форм` для которых вместо юридического адреса контрагента печатать почтовый адрес в графе <Грузополучатель> для расходных документов и  <Грузоотправитель> для приходных,(outsend)  Список печатных форм` для которых вместо реквизитов собственной фирмы в графе <Грузоотправитель> для расходных документов и <Грузополучатель> для приходных документов печатать наименование` адрес` банковские реквизиты объекта,(outasend) Список печатных форм` для которых вместо юридического адреса фирмы печатать  почтовый адрес в графе <Грузоотправитель> для расходных документов и <Грузополучатель> для приходных документов,(outR)     Кого печатать в графе «Руководитель»,(outB)     Кого печатать в графе «Главный бухгалтер»,(outogr)   Кого печатать в графе «Отпуск груза разрешил»,(outC)     Кого печатать в графе «Отпуск груза произвел»' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Наименование товара в накладных печатать в 2 стр,Файл для печати внеш. ПН,Печатать в заголовках форм <Утверждена Постановлением>,не печатать <дата>,не печатать <скидка>,не печатать <реквизиты ЕГРИП>,должна быть задана фирма для печати накладных,не печатать <номер документа>,Адрес фирмы в графе Грузоотправитель/Грузополучатель из настроек объекта,не печатать <примечание>,не печатать <Цены указаны в нац.вал.>,№ платёжно-расчёт. док-та в счёте-фактуре,не печатать <подписи из БД>,не печатать последнюю колонку,Адрес контрагента в графе Грузополучатель/Грузоотправитель почтовый,В графе <Грузоотправитель> печатаются реквизиты объекта,Адрес фирмы в графе Грузоотправитель/Грузополучатель почтовый,Печатать в графе «Руководитель»,Печатать в графе «Гл. бухгалтер»,В графе «Отпуск груза разрешил»,Печать в графе «Отпуск груза произвел»'.     assign     p-tooltip = "параметры по Печати ФОРМ по объектам"     p-label = "параметры по Печати ФОРМ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'fgdsnind,in-docpr,outappr,outdate,outdisc,outegrp,outhold,outnum,outobj,outprim,outrubl,outssdoc,outsubs,outt12,outares,outsend,outasend,outR,outB,outogr,outC' ), 'Наименование товара в накладных печатать в 2 стр,Файл для печати внеш. ПН,Печатать в заголовках форм <Утверждена Постановлением>,не печатать <дата>,не печатать <скидка>,не печатать <реквизиты ЕГРИП>,должна быть задана фирма для печати накладных,не печатать <номер документа>,Адрес фирмы в графе Грузоотправитель/Грузополучатель из настроек объекта,не печатать <примечание>,не печатать <Цены указаны в нац.вал.>,№ платёжно-расчёт. док-та в счёте-фактуре,не печатать <подписи из БД>,не печатать последнюю колонку,Адрес контрагента в графе Грузополучатель/Грузоотправитель почтовый,В графе <Грузоотправитель> печатаются реквизиты объекта,Адрес фирмы в графе Грузоотправитель/Грузополучатель почтовый,Печатать в графе «Руководитель»,Печатать в графе «Гл. бухгалтер»,В графе «Отпуск груза разрешил»,Печать в графе «Отпуск груза произвел»'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'fgdsnind,in-docpr,outappr,outdate,outdisc,outegrp,outhold,outnum,outobj,outprim,outrubl,outssdoc,outsubs,outt12,outares,outsend,outasend,outR,outB,outogr,outC' ), v-tooltip-code-list))) no-error.   end.
        when 'prt-firm':U then do:     v-tooltip-code-list =  '(factur01) По фирме. yes - впервые для Грин-Лайна,(incurrat) По фирме. Печать приходной накладной в нац.вал. по текущему курсу,(tick-w)   По фирме. Если YES` то по умолчанию включена опция «в том числе на весовой товар» при печати ценников. Параметр необязательный` по умолчанию NO' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Печатать в счете-фактуре doc-date вместо fact-date,Печать приходной накладной в нац.вал. по текущему курсу,Печать ценников на весовой товар (везде)'.     assign     p-tooltip = "параметры по Печати форм фирма"     p-label = "параметры по Печати форм фирма"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'factur01,incurrat,tick-w' ), 'Печатать в счете-фактуре doc-date вместо fact-date,Печать приходной накладной в нац.вал. по текущему курсу,Печать ценников на весовой товар (везде)'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'factur01,incurrat,tick-w' ), v-tooltip-code-list))) no-error.   end.
        when 'report-glob':U then do:     v-tooltip-code-list =  '(actuate)   Глобальный. Есть возможность формирования отчетов через внешнюю программу Actuate,(ardecldt)  Глобальный. Дата начала формирования отчета Декларация об объемах розничной продажи алк,(rep-sort)  Глобальный. Перечень топливных кодов. Предполагается` что топливо в списке будут перечисленны по возрастанию октанового числа. Порядок вывода видов топлива в отчетах <<Отчет диспетчера>> <<Расшифровка реализации>> <<Отчет по АВТОКУШ>> соответствует порядку перечисления кодов в этом параметре,(sum-from)  Глобальный. Нижнее знач для диапазонов сумм для почасового отчета по диапазонам сумм продаж. При наличии настройки sumvals или при отсутствии sum-step и sum-to игнорируетсЯ,(sum-step)  Глобальный. Шаг для диапазонов сумм для почасового отчета по диапазонам сумм продаж. При наличии настройки sumvals или при отсутствии sum-from и sum-to игнорируетсЯ,(sum-to)    Глобальный. Верхнее знач для диапазонов сумм для почасового отчета по диапазонам сумм продаж. При наличии настройки sumvals или при отсутствии sum-step и sum-from игнорируетсЯ,(sumvals)   Глобальный. Список диапазонов сумм для почасового отчета по диапазонам сумм продаж` например <20_30`30_40> – т.е. список непересекающихся` примыкающих диапазонов – [нижнее-значение]_[верхнее значение] – имеет приоритет на настройками sum-step` sum-from и sum-to,(alcgrpgd)  Глобальный. Для Отчета <Декларация об объемах розничной продажи алкогольной продукции (Калуга)> нужно выбрать из классификатора групп номер группы с АЛКОГОЛЕМ,(cplot)     Глобальный. Перечень типов касс.платежей - билетов лотереи АВТОКУШ. Порядок вывода типов касс.платежа в отчетах <<Отчет по АВТОКУШ>> соответствует порядку перечисления кодов в этом параметре,,(cdens)     Глобальный. По средней - плотность чека брать из документа продажи. По чекам - в каждом чеке плотность считается по выставленному алгоритму.,(rep-password) Глобальный. Excel для отчетов - защита от редактирования ,(rep-excel) Глобальный. Вывод отчетов в EXCEL' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Есть отчеты Actuate,Декларация об объемах розничной продажи алк-я,Сортировка топлива в отчете по октановому числу,Нижнее знач.,Шаг,Верхнее знач.,Список,Код группы <Алкогольные товары>,Сортировка типов касс.пл-жей в отчете по АВТОКУШ,Формат сменного отчета,Алгоритм расчета плотности в отчетах,Excel для отчетов - защита от редактирования,Вывод отчетов в EXCEL '.     assign     p-tooltip = "параметры по Отчетам глобально"     p-label = "параметры по Отчетам глобально"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'actuate,ardecldt,rep-sort,sum-from,sum-step,sum-to,sumvals,alcgrpgd,cplot,rep-shift-format,cdens,rep-password,rep-excel' ), 'Есть отчеты Actuate,Декларация об объемах розничной продажи алк-я,Сортировка топлива в отчете по октановому числу,Нижнее знач.,Шаг,Верхнее знач.,Список,Код группы <Алкогольные товары>,Сортировка типов касс.пл-жей в отчете по АВТОКУШ,Формат сменного отчета,Алгоритм расчета плотности в отчетах,Excel для отчетов - защита от редактирования,Вывод отчетов в EXCEL '))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'actuate,ardecldt,rep-sort,sum-from,sum-step,sum-to,sumvals,alcgrpgd,cplot,rep-shift-format,cdens,rep-password,rep-excel' ), v-tooltip-code-list))) no-error.   end.
        when 'report-obj':U then do:     v-tooltip-code-list =  '(prt-z-no) Печатать или нет номера Z-отчетов в 1 - 4 листах сменного отчета,(shft-qty) Какое количество (в кг) из сверки брать для 1-го листа сменного отчета system-cli-qnty или state-cli-qnty (расчетно-книжный остаток)' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Печатать номера Z-отчетов в сменном отчете (1-4 л.),1-ый лист сменного отчета (топливо)'.     assign     p-tooltip = "параметры по Отчетам по объектам"     p-label = "параметры по Отчетам"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'prt-z-no,shft-qty' ), 'Печатать номера Z-отчетов в сменном отчете (1-4 л.),1-ый лист сменного отчета (топливо)'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'prt-z-no,shft-qty' ), v-tooltip-code-list))) no-error.   end.
        when 'report-firm':U then do:     v-tooltip-code-list =  '(xl-delim) По фирме. Разделитель колонок при старом экспорте в Excel' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Разделитель колонок при экспорте в Excel'.     assign     p-tooltip = "параметры по Отчетам фирма"     p-label = "параметры по Отчетам фирма"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'xl-delim' ), 'Разделитель колонок при экспорте в Excel'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'xl-delim' ), v-tooltip-code-list))) no-error.   end.
        when 'images':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Порядок форматов файлов изображений для поиска и ввода (при хранении изображений вне БД)'.     assign     p-tooltip = "Параметры для работы с изображениями"     p-label = "Параметры для работы с изображениями"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'imgorder':U ), 'Порядок форматов файлов изображений для поиска и ввода (при хранении изображений вне БД)'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'imgorder':U ), v-tooltip-code-list))) no-error.   end.
        when 'code-range':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Размер диапазона для соственных кодов товаров,Размер диапазона для кодов договоров,Размер диапазона для кодов ДК,Размер диапазона для кодов правил скидок и расписаний,Размер диапазона для кодов организаций,Размер диапазона для кодов физ.лиц,Размер диапазона для глобальных весовых кодов,Размер диапазона для локальных весовых кодов,Размер диапазона для локальных взвешиваемых кодов,Размер диапазона для глобальных взвешиваемых кодов,Размер диапазона для глобальных кодов точек привязки,Размер диапазона для локальных штучных кодов для весов,Размер диапазона для глобальных кодов финансовых документов'.     assign     p-tooltip = "Опции работы с Диапазонами кодов"     p-label = "Опции работы с Диапазонами кодов"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cdrgbcgb,cdrgctgb,cdrgdcgb,cdrgdrgb,cdrgfmgb,cdrgpngb,cdrgscgb,cdrgsclc,cdrgsslc,cdrgssgb,cdrgcagb,cdrgpglc,cdrgfdgb':U ), 'Размер диапазона для соственных кодов товаров,Размер диапазона для кодов договоров,Размер диапазона для кодов ДК,Размер диапазона для кодов правил скидок и расписаний,Размер диапазона для кодов организаций,Размер диапазона для кодов физ.лиц,Размер диапазона для глобальных весовых кодов,Размер диапазона для локальных весовых кодов,Размер диапазона для локальных взвешиваемых кодов,Размер диапазона для глобальных взвешиваемых кодов,Размер диапазона для глобальных кодов точек привязки,Размер диапазона для локальных штучных кодов для весов,Размер диапазона для глобальных кодов финансовых документов'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cdrgbcgb,cdrgctgb,cdrgdcgb,cdrgdrgb,cdrgfmgb,cdrgpngb,cdrgscgb,cdrgsclc,cdrgsslc,cdrgssgb,cdrgcagb,cdrgpglc,cdrgfdgb':U ), v-tooltip-code-list))) no-error.   end.
        when 'bge-export':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Экспорт всех объектов,Удалять нули в начале номеров дисконтных карт,Экспорт справочников видов оплат типов кассовых платежей и дисконтных карт,Список шаблонов названий файлов выгрузки документов и товаров по дням,Вариант создания файлов выгрузки,Форматы выгрузки,Способ выгрузки сменных объектов,Контрагенты для которых внешний приход экспортируется как внутренний'.     assign     p-tooltip = "Настройки для экспорта"     p-label = "Настройки для экспорта"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'bgeclall,bgedcard,bgedict,bgeflnm,bgeflold,bgefmt,bgeshift,bgecliiv':U ), 'Экспорт всех объектов,Удалять нули в начале номеров дисконтных карт,Экспорт справочников видов оплат типов кассовых платежей и дисконтных карт,Список шаблонов названий файлов выгрузки документов и товаров по дням,Вариант создания файлов выгрузки,Форматы выгрузки,Способ выгрузки сменных объектов,Контрагенты для которых внешний приход экспортируется как внутренний'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'bgeclall,bgedcard,bgedict,bgeflnm,bgeflold,bgefmt,bgeshift,bgecliiv':U ), v-tooltip-code-list))) no-error.   end.
        when 'auto-task':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'email на который отсылать сообщения,список пользователей для авто процессов,Максимальное количество очищаемых марок'.     assign     p-tooltip = "Настройки АВТОПРОЦЕССОВ"     p-label = "Настройки АВТОПРОЦЕССОВ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'send-msg-to-email,user-list,maxColMarks':U ), 'email на который отсылать сообщения,список пользователей для авто процессов,Максимальное количество очищаемых марок'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'send-msg-to-email,user-list,maxColMarks':U ), v-tooltip-code-list))) no-error.   end.
        when 'wnd-size':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Максимизировать окна при открытии,Сохранять внешний вид окна'.     assign     p-tooltip = "Настройки размеров окон"     p-label = "Настройки размеров окон"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'max,store':U ), 'Максимизировать окна при открытии,Сохранять внешний вид окна'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'max,store':U ), v-tooltip-code-list))) no-error.   end.
        when 'obj-date':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Автоматическое изменение даты на обычном объекте,Автоматическое изменение даты на сменном объекте,Новый принцип формирования номеров смен,Допустимая разница между календарной и сменной датами,Допустимое превышение ВРЕМЕНИ ЗАКРЫТИЯ СМЕНЫ над текущим (в минутах)'.     assign     p-tooltip = "Настройки даты и смены на объекте"     p-label = "Настройки даты и смены на объекте"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'autodate,autodtsh,newordsh,diffshft,difftime':U ), 'Автоматическое изменение даты на обычном объекте,Автоматическое изменение даты на сменном объекте,Новый принцип формирования номеров смен,Допустимая разница между календарной и сменной датами,Допустимое превышение ВРЕМЕНИ ЗАКРЫТИЯ СМЕНЫ над текущим (в минутах)'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'autodate,autodtsh,newordsh,diffshft,difftime':U ), v-tooltip-code-list))) no-error.   end.
        when 'fbrattr':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Первый подходящий рецепт при рекурсивном производстве,Ручное заполнение альтернативного производства,При раскрутке рецептов прибавлять требуемое количество к уже произведенному,Возможность изменения локальных рецептов на глобальные,Детализация записи в историю,Мин. % наценки производства,Макс. % наценки производства'.     assign     p-tooltip = "Настройки производства"     p-label = "Настройки производства"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'fbr-frcp,fbr-ioff,fbr-qntc,fbrrcpgb,fbrhstlv,fbr-mrgn-min,fbr-mrgn-max':U ), 'Первый подходящий рецепт при рекурсивном производстве,Ручное заполнение альтернативного производства,При раскрутке рецептов прибавлять требуемое количество к уже произведенному,Возможность изменения локальных рецептов на глобальные,Детализация записи в историю,Мин. % наценки производства,Макс. % наценки производства'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'fbr-frcp,fbr-ioff,fbr-qntc,fbrrcpgb,fbrhstlv,fbr-mrgn-min,fbr-mrgn-max':U ), v-tooltip-code-list))) no-error.   end.
        when 'petrol':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Расхождение в инвентаризации по сверке делать без учета погрешности измерения,Алгоритм вычисления плотности для продаж,Автоматические сверки создавать только по измеряемым резервуарам,Автоматические сверки создавать с чтением всех счетчиков ТРК,Автом. создание инв. счетчиков ТРК при переполнении разрядности эл. счетчика,Тип ввода топлива в документах прихода внешнего,Тип ввода топлива во всех документах кроме прихода внешнего,Контрагент для списания ЕУ при инвентаризации топлива по сверке,В документы по умолчанию ставится плотность и темп. из предыдущего документа,Настройки инвентаризации по сверке,Температура к которой приводится плотность и объем (°С),При воде в сверке отправлять сообщения на список адресов,Допустимый % расхождения массы в резервуаре,Алгоритм принятия топлива к учету,Обязательный выбор автотранспорта из справочника,Погрешность изм массы для горизонтальных резер,Погрешность изм массы для вертикальных резер,Обязательные поля доп.инфо ПН,Отклонение объема,Отклонение температуры,Отклонение плотности,Отклонение воды,Допустимый % расхождения массы при приеме СУГ,Контроль свободного объема в резервуаре при приеме НП,Обязательный выбор этапа для приема газовоза,Разрешить ручное заполнение документа приёма НП при поставках с собственных НБ,Обязательные поля в секциях ПН,Время на сканирование QR-кода (мс),Автозаполнение НП,Отправлять блокировку пистолетов при приемке,Timeout ожидания подтверждения блокировки пистолетов,Контроль свободного объема в резервуаре при приеме СУГ,Время пропуска данных автоматической сверки после приема НП'.     assign     p-tooltip = "Настройки работы с ТОПЛИВНЫМ товаром"     p-label = "Настройки работы с ТОПЛИВНЫМ товаром"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'rvsnmter,denstclc,autopump-izm,autopump,avtinvpm,inpptrl,expptrl,invclipt,olddens,algrvspt,temp-for-pomi,rvs-wt-email,CriticalDif,algoincome,mand-choice-autocar,Delta-mass-horiz,Delta-mass-vert,dop-info,otkl-fact-volue,otkl-temp,otkl-density,otkl-water,CriticalDifInLgas,calc-free-vol,trn-reas-sug,rvd-own-nb,sec-fields,qr-scan-time,trnscanqr,block-nozzle,timeout-block-nozzle,calc-free-vol-sug,autopump-skip-time':U ), 'Расхождение в инвентаризации по сверке делать без учета погрешности измерения,Алгоритм вычисления плотности для продаж,Автоматические сверки создавать только по измеряемым резервуарам,Автоматические сверки создавать с чтением всех счетчиков ТРК,Автом. создание инв. счетчиков ТРК при переполнении разрядности эл. счетчика,Тип ввода топлива в документах прихода внешнего,Тип ввода топлива во всех документах кроме прихода внешнего,Контрагент для списания ЕУ при инвентаризации топлива по сверке,В документы по умолчанию ставится плотность и темп. из предыдущего документа,Настройки инвентаризации по сверке,Температура к которой приводится плотность и объем (°С),При воде в сверке отправлять сообщения на список адресов,Допустимый % расхождения массы в резервуаре,Алгоритм принятия топлива к учету,Обязательный выбор автотранспорта из справочника,Погрешность изм массы для горизонтальных резер,Погрешность изм массы для вертикальных резер,Обязательные поля доп.инфо ПН,Отклонение объема,Отклонение температуры,Отклонение плотности,Отклонение воды,Допустимый % расхождения массы при приеме СУГ,Контроль свободного объема в резервуаре при приеме НП,Обязательный выбор этапа для приема газовоза,Разрешить ручное заполнение документа приёма НП при поставках с собственных НБ,Обязательные поля в секциях ПН,Время на сканирование QR-кода (мс),Автозаполнение НП,Отправлять блокировку пистолетов при приемке,Timeout ожидания подтверждения блокировки пистолетов,Контроль свободного объема в резервуаре при приеме СУГ,Время пропуска данных автоматической сверки после приема НП'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'rvsnmter,denstclc,autopump-izm,autopump,avtinvpm,inpptrl,expptrl,invclipt,olddens,algrvspt,temp-for-pomi,rvs-wt-email,CriticalDif,algoincome,mand-choice-autocar,Delta-mass-horiz,Delta-mass-vert,dop-info,otkl-fact-volue,otkl-temp,otkl-density,otkl-water,CriticalDifInLgas,calc-free-vol,trn-reas-sug,rvd-own-nb,sec-fields,qr-scan-time,trnscanqr,block-nozzle,timeout-block-nozzle,calc-free-vol-sug,autopump-skip-time':U ), v-tooltip-code-list))) no-error.   end.
        when 'staff':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Запрет на ввод произвольных данных при вводе персонала смены,Обязательное сочетание цифровых и буквенных символов,Обязательное сочетание цифровых и буквенных символов (адм),Минимальная длина пароля,Минимальная длина пароля (адм),Время жизни пароля,Время жизни пароля (адм),Время до блокировки пользователя после окончания действия пароля,Время до блокировки пользователя после окончания действия пароля (адм),Колличество старых паролей с которыми не должен совпадать новый пароль,Колличество старых паролей с которыми не должен совпадать новый пароль (адм)'.     assign     p-tooltip = "Параметры работы с пользователями и персоналом"     p-label = "Параметры работы с пользователями и персоналом"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'noanshftstaff,obyznumbukv,obyznumbukvadm,minparol,minparoladm,TimeAvail,TimeAvailadm,TimeBlock,TimeBlockAdm,LastPaswd,LastPaswdAdm':U ), 'Запрет на ввод произвольных данных при вводе персонала смены,Обязательное сочетание цифровых и буквенных символов,Обязательное сочетание цифровых и буквенных символов (адм),Минимальная длина пароля,Минимальная длина пароля (адм),Время жизни пароля,Время жизни пароля (адм),Время до блокировки пользователя после окончания действия пароля,Время до блокировки пользователя после окончания действия пароля (адм),Колличество старых паролей с которыми не должен совпадать новый пароль,Колличество старых паролей с которыми не должен совпадать новый пароль (адм)'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'noanshftstaff,obyznumbukv,obyznumbukvadm,minparol,minparoladm,TimeAvail,TimeAvailadm,TimeBlock,TimeBlockAdm,LastPaswd,LastPaswdAdm':U ), v-tooltip-code-list))) no-error.   end.
         when 'izt-rul':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'список ответов: можно ли работать с товаром по ИЖТ и по событию'.     assign     p-tooltip = "Настройки правил ИЖТ"     p-label = "Настройки правил ИЖТ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'izt-rul':U ), 'список ответов: можно ли работать с товаром по ИЖТ и по событию'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'izt-rul':U ), v-tooltip-code-list))) no-error.   end.
        when 'srv-auth-ASU':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Код контрагента РКО обязательного к авторизации,Адрес сервера авторизации '.     assign     p-tooltip = "Сервер авторизации АСУ"     p-label = "Сервер авторизации АСУ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'pko-cli,srv-auth-adr':U ), 'Код контрагента РКО обязательного к авторизации,Адрес сервера авторизации '))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'pko-cli,srv-auth-adr':U ), v-tooltip-code-list))) no-error.   end.
        when 'egais':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Код ФСРАР,Адрес УТМ,Версия XSD схем,ИНН фирмы,Номер внешней системы'.     assign     p-tooltip = "Настройки для обмена с ЕГАИС"     p-label = "Настройки для обмена с ЕГАИС"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'egais-fsrar,egais-utm,egais-ver-xsd,egais-inn,egais-exsys' ), 'Код ФСРАР,Адрес УТМ,Версия XSD схем,ИНН фирмы,Номер внешней системы'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'egais-fsrar,egais-utm,egais-ver-xsd,egais-inn,egais-exsys' ), v-tooltip-code-list))) no-error.   end.
        when 'gisMT':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Адрес и порт проски-сервера,Дополнительные параметры запроса,Адрес ГИС МТ,Логин,Пароль,Макс.допуст. время разрешения продажи при сбое,ключ авторизации,Время с момента сбоя до начала уведомления персонала,Длительность ожидания ответа ГИС МТ,Аварийная ситуация в ГИС МТ,Опережение срабатывания запрета по сроку годности в минутах,Работа с cdn-площадками,Адрес cdn,Повторный опрос площадки,Смена площадки,Период обновления списка CDN-площадок,Обновление параметров при запросе КМ,Адрес ЛМ ЧЗ,Логин в ЛМ ЧЗ,Пароль в ЛМ ЧЗ,Время ожидания ответа ТН,Обязательность получения результатов проверки КМ в ТН,Порт для отправки запроса проверки марки в ЛМ ЧЗ,Адрес для отправки запроса проверки марки в ТН,Порт для отправки запроса проверки марки в ТН,Длительность обработки ответа ГИС МТ в ТС ПИоТ,Токен авторизации MAX,Проверка возраста при продаже НП'.     assign     p-tooltip = "Настройки для подключения к ГИС МТ и проверки КМ"     p-label = "Настройки для подключения к ГИС МТ и проверки КМ"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'adressPort,dopParam,gisAdress,proxyLogin,proxyPswd,maxTime,regKey,timeFalStart,waitTime,crashSituat,banDate,cdnTurnOn,cdnAdress,cdnRepeat,cdnChange,cdnTimeUpdate,UpdateRequest,OflineAdress,OflineLogin,OflinePswd,MACC_Timeout,Resp_TH_required,LmCHzPort,TH_IP,TH_Port,AddTimeoutPIoT,MaxApiToken,AgeConfirm' ), 'Адрес и порт проски-сервера,Дополнительные параметры запроса,Адрес ГИС МТ,Логин,Пароль,Макс.допуст. время разрешения продажи при сбое,ключ авторизации,Время с момента сбоя до начала уведомления персонала,Длительность ожидания ответа ГИС МТ,Аварийная ситуация в ГИС МТ,Опережение срабатывания запрета по сроку годности в минутах,Работа с cdn-площадками,Адрес cdn,Повторный опрос площадки,Смена площадки,Период обновления списка CDN-площадок,Обновление параметров при запросе КМ,Адрес ЛМ ЧЗ,Логин в ЛМ ЧЗ,Пароль в ЛМ ЧЗ,Время ожидания ответа ТН,Обязательность получения результатов проверки КМ в ТН,Порт для отправки запроса проверки марки в ЛМ ЧЗ,Адрес для отправки запроса проверки марки в ТН,Порт для отправки запроса проверки марки в ТН,Длительность обработки ответа ГИС МТ в ТС ПИоТ,Токен авторизации MAX,Проверка возраста при продаже НП'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'adressPort,dopParam,gisAdress,proxyLogin,proxyPswd,maxTime,regKey,timeFalStart,waitTime,crashSituat,banDate,cdnTurnOn,cdnAdress,cdnRepeat,cdnChange,cdnTimeUpdate,UpdateRequest,OflineAdress,OflineLogin,OflinePswd,MACC_Timeout,Resp_TH_required,LmCHzPort,TH_IP,TH_Port,AddTimeoutPIoT,MaxApiToken,AgeConfirm' ), v-tooltip-code-list))) no-error.   end.
        when 'marking':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'Включена работа с ЭДО для маркированных документов,Включена работа с ЭДО для не маркированных документов,Ручной ввод марок,Допустимое отсутствие КМ для "Серой зоны",Типы маркировок для поэкземплярного учета,Запрет на создание рецептов и маркетинговых акций с маркированными товарами,Использования рецепта Альтернатива только для получения ингредиентов,Определение товара по штрих-коду,Автоматическое переключение раскладки на русский,Типы маркировок для объемно-артикульного учета,Типы маркировок переходный период,Разрешена продажа возвращенных товаров,Проверка блокировок контролирующих органов,Проверка срока годности,Проверка МРЦ,Проверка владельца,Проверка статуса КМ,Проверка прослеживаемости'.     assign     p-tooltip = "Электронный документооборот"     p-label = "Электронный документооборот"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'marking-EDO,marking-EDO-NotMark,marking-manual,gray_zone_qnty,marking-type-edo,ban-recipes,ban-altr,bar-code,rus-key,marking-type-artic,marking-type-transitional,marking-type-saleReturn,checkBlock,checkDate,checkMRC,checkOwner,checkStatusKM,checkTracking' ), 'Включена работа с ЭДО для маркированных документов,Включена работа с ЭДО для не маркированных документов,Ручной ввод марок,Допустимое отсутствие КМ для "Серой зоны",Типы маркировок для поэкземплярного учета,Запрет на создание рецептов и маркетинговых акций с маркированными товарами,Использования рецепта Альтернатива только для получения ингредиентов,Определение товара по штрих-коду,Автоматическое переключение раскладки на русский,Типы маркировок для объемно-артикульного учета,Типы маркировок переходный период,Разрешена продажа возвращенных товаров,Проверка блокировок контролирующих органов,Проверка срока годности,Проверка МРЦ,Проверка владельца,Проверка статуса КМ,Проверка прослеживаемости'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'marking-EDO,marking-EDO-NotMark,marking-manual,gray_zone_qnty,marking-type-edo,ban-recipes,ban-altr,bar-code,rus-key,marking-type-artic,marking-type-transitional,marking-type-saleReturn,checkBlock,checkDate,checkMRC,checkOwner,checkStatusKM,checkTracking' ), v-tooltip-code-list))) no-error.   end.
        when 'mercur':U then do:     v-tooltip-code-list =  '' .    if v-tooltip-code-list = '' then v-tooltip-code-list = 'APIKey,Логин входа в ИС,Логин,Пароль,Разрешено вводить код ВСД вручную,Разрешено закрывать документ без указ. ВСД,Тип взаимодействия,Настройки для печати QR-кода,Сервер,Адрес прокси-сервера,логин,пароль,SSL прокси'.     assign     p-tooltip = "Параметры для работы с ФГИС Меркурий"     p-label = "Параметры для работы с ФГИС Меркурий"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'apikey,login_is,login,password,manual-vcd,close,type-connect,qrcode,server,proxy-addres,proxy-login,proxy-pswd,proxy-ssl' ), 'APIKey,Логин входа в ИС,Логин,Пароль,Разрешено вводить код ВСД вручную,Разрешено закрывать документ без указ. ВСД,Тип взаимодействия,Настройки для печати QR-кода,Сервер,Адрес прокси-сервера,логин,пароль,SSL прокси'))).     p-tooltip-code =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'apikey,login_is,login,password,manual-vcd,close,type-connect,qrcode,server,proxy-addres,proxy-login,proxy-pswd,proxy-ssl' ), v-tooltip-code-list))) no-error.   end.
    otherwise do:
      undo, return error substitute("неизвестный атрибут объекта TH &1 &2"
                                    , p-upper-code
                                    , p-code ).
    end.
  end.
end.
end procedure.
procedure thbjattr_value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-obj-type         like ub.thbj-attr.obj-type   no-undo .
    define input  parameter p-obj-code         like ub.thbj-attr.obj-code   no-undo .
    define input  parameter p-upper-code       like ub.thbj-attr.upper-prop-code no-undo .
    define input  parameter p-code             like ub.thbj-attr.prop-code no-undo .
    define output parameter p-value-character  like ub.thbj-attr.property-value-character no-undo .
    define output parameter p-value-date       like ub.thbj-attr.property-value-date no-undo .
    define output parameter p-value-decimal    like ub.thbj-attr.property-value-decimal no-undo .
    define output parameter p-value-integer    like ub.thbj-attr.property-value-integer no-undo .
    define output parameter p-value-logical    like ub.thbj-attr.property-value-logical no-undo .
    define output parameter p-type             as character no-undo .
    define output parameter p-found            as decimal no-undo .
    define buffer buf_thbj-attr for ub.thbj-attr .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list as character no-undo .
    define variable v-prop-type-list as character no-undo .
    define variable v-prop-label-list as character no-undo .
    define variable v-global as logical no-undo .
    define variable v-host as logical no-undo .
    define variable v-shop as logical no-undo .
    define variable v-store as logical no-undo .
    define variable v-db as logical no-undo .
    define variable v-region as logical no-undo .
    run thbjattr_code in this-procedure
      (input  p-upper-code
      ,input  p-code
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ,output v-region
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_thbj-attr no-lock
      where buf_thbj-attr.obj-type  = p-obj-type
        and buf_thbj-attr.obj-code  = p-obj-code
        and buf_thbj-attr.upper-prop-code = p-upper-code
        and buf_thbj-attr.prop-code = p-code
      no-error .
    if avail buf_thbj-attr then do:
      assign
      p-value-character =  buf_thbj-attr.property-value-character
      p-value-date      =  buf_thbj-attr.property-value-date
      p-value-decimal   =  buf_thbj-attr.property-value-decimal
      p-value-integer   =  buf_thbj-attr.property-value-integer
      p-value-logical   =  buf_thbj-attr.property-value-logical
      p-type            =  buf_thbj-attr.prop-value-type
      p-found           =  1.00
      .
    end.
  end.
end procedure.
procedure thbjattr_write :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type        like ub.thbj-attr.obj-type   no-undo .
    define input parameter p-obj-code        like ub.thbj-attr.obj-code   no-undo .
    define input parameter p-upper-code      like ub.thbj-attr.upper-prop-code  no-undo .
    define input parameter p-code            like ub.thbj-attr.prop-code  no-undo .
    define input parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
    define input parameter p-value-date      like ub.thbj-attr.property-value-date  no-undo .
    define input parameter p-value-decimal   like ub.thbj-attr.property-value-decimal  no-undo .
    define input parameter p-value-integer   like ub.thbj-attr.property-value-integer  no-undo .
    define input parameter p-value-logical   like ub.thbj-attr.property-value-logical  no-undo .
    define buffer buf_thbj-attr for ub.thbj-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list as character no-undo .
    define variable v-prop-type-list as character no-undo .
    define variable v-prop-label-list as character no-undo .
    define variable v-global as logical no-undo .
    define variable v-host as logical no-undo .
    define variable v-shop as logical no-undo .
    define variable v-store as logical no-undo .
    define variable v-db as logical no-undo .
    define variable v-dop as character no-undo .
    define variable v-region as logical no-undo .
    run thbjattr_code in this-procedure
      (input  p-upper-code
      ,input  p-code
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ,output v-region
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_thbj-attr exclusive-lock
      where buf_thbj-attr.obj-type  = p-obj-type
        and buf_thbj-attr.obj-code  = p-obj-code
        and buf_thbj-attr.upper-prop-code = p-upper-code
        and buf_thbj-attr.prop-code = p-code
      no-error .
    if not available buf_thbj-attr then do:
      create buf_thbj-attr .
      assign
        buf_thbj-attr.obj-type  = p-obj-type
        buf_thbj-attr.obj-code  = p-obj-code
        buf_thbj-attr.upper-prop-code = p-upper-code
        buf_thbj-attr.prop-code = p-code
        v-dop = entry(lookup(p-code, v-prop-list), v-prop-type-list)
        buf_thbj-attr.prop-value-type = v-dop
      .
    end.
    CASE buf_thbj-attr.prop-value-type:
      when 'character':U then do:
        assign
        buf_thbj-attr.property-value-character = p-value-character
        .
      end.
      when 'date':U then do:
        assign
        buf_thbj-attr.property-value-date = p-value-date
        .
      end.
      when 'decimal':U then do:
        assign
        buf_thbj-attr.property-value-decimal = p-value-decimal
        .
      end.
      when 'integer':U then do:
        assign
        buf_thbj-attr.property-value-integer = p-value-integer
        .
      end.
      when 'logical':U then do:
        assign
        buf_thbj-attr.property-value-logical = p-value-logical
        .
      end.
    end case.
    release buf_thbj-attr no-error.
    if error-status:error then do:
      return error substitute("Ошибка при сохранение атрибута &1 &2 объекта TH &3&5: &5 &6"
                             , p-upper-code
                             , p-code
                             , p-obj-type
                             , p-obj-code
                             , error-status:get-message(1)
                             , return-value ).
    end.
  end.
end procedure.
procedure thbjattr_delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
    define input parameter p-upper-code   like ub.thbj-attr.upper-prop-code  no-undo .
    define input parameter p-code     like ub.thbj-attr.prop-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_thbj-attr for ub.thbj-attr .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list as character no-undo .
    define variable v-prop-type-list as character no-undo .
    define variable v-prop-label-list as character no-undo .
    define variable v-global as logical no-undo .
    define variable v-host as logical no-undo .
    define variable v-shop as logical no-undo .
    define variable v-store as logical no-undo .
    define variable v-db as logical no-undo .
    define variable v-region as logical no-undo .
    run thbjattr_code in this-procedure
      (input  p-upper-code
      ,input  p-code
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ,output v-region
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_thbj-attr exclusive-lock
      where buf_thbj-attr.obj-type  = p-obj-type
        and buf_thbj-attr.obj-code  = p-obj-code
        and buf_thbj-attr.upper-prop-code = p-upper-code
        and buf_thbj-attr.prop-code = p-code
      no-error NO-WAIT.
    if not available buf_thbj-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_thbj-attr no-error .
      if error-status:error then do:
        return error substitute("Ошибка при удалении атрибута &1 &2 объекта TH &3&4: &5 &6"
                              , p-upper-code
                              , p-code
                              , p-obj-type
                              , p-obj-code
                              , error-status:get-message(1)
                              , return-value ).
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table for thbjattr_thbj-attr.
define output parameter p-all-found as decimal no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-jj as integer no-undo .
define variable v-all-found as decimal no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf_thbjattr_thbj-attr for thbjattr_thbj-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  run thbjattr_code in this-procedure
    (input  p-upper-code
    ,input  '':U
    ,output v-label
    ,output v-user-can-edit
    ,output v-output-display
    ,output v-other
    ,output v-prop-list
    ,output v-prop-type-list
    ,output v-prop-label-list
    ,output v-global
    ,output v-host
    ,output v-shop
    ,output v-store
    ,output v-db
    ,output v-region
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  for each buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = p-obj-type
      and buf_thbj-attr.obj-code = p-obj-code
      and buf_thbj-attr.upper-prop-code = p-upper-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
     if buf_thbj-attr.prop-code = '':U then next.
    if lookup( buf_thbj-attr.prop-code, v-prop-list) = 0 then next .
    if (lookup("compl", v-prop-type-list, chr(47)) > 0
    and v-prop-type-list <> buf_thbj-attr.prop-value-type)
    or (lookup("compl", v-prop-type-list, chr(47)) = 0
        and entry(lookup( buf_thbj-attr.prop-code, v-prop-list), v-prop-type-list) <> buf_thbj-attr.prop-value-type )
    then next .
    find first buf_thbjattr_thbj-attr where
              buf_thbjattr_thbj-attr.obj-type = p-obj-type
          and buf_thbjattr_thbj-attr.obj-code = p-obj-code
          and buf_thbjattr_thbj-attr.upper-prop-code = p-upper-code
          and buf_thbjattr_thbj-attr.prop-code = buf_thbj-attr.prop-code no-error.
    if not available buf_thbjattr_thbj-attr then do:
      create buf_thbjattr_thbj-attr.
      assign
      buf_thbjattr_thbj-attr.obj-type = p-obj-type
      buf_thbjattr_thbj-attr.obj-code = p-obj-code
      buf_thbjattr_thbj-attr.upper-prop-code = p-upper-code
      buf_thbjattr_thbj-attr.prop-code = buf_thbj-attr.prop-code
      .
    end.
    buffer-copy buf_thbj-attr
    except obj-type obj-code upper-prop-code prop-code
    to buf_thbjattr_thbj-attr
    .
    assign
    v-jj = v-jj + 1.
    if buf_thbj-attr.prop-value-type = 'void':U then do:
      v-all-found = 0.
      run thbjattr_get-section in this-procedure (
                                                    input p-obj-type
                                                   ,input p-obj-code
                                                   ,input buf_thbj-attr.prop-code
                                                   ,input p-mode
                                                   ,input-output table thbjattr_thbj-attr
                                                   ,output v-all-found
                                                   ) no-error.
      if error-status:error then do:
        undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
      end.
      if v-all-found < 1 then do:
        v-jj = v-jj - 1.
      end.
    end.
  end.
  assign
  p-all-found = v-jj / num-entries(v-prop-list).
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input parameter table for thbjattr_thbj-attr.
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-jj as integer no-undo .
define variable v-created as logical no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf_thbjattr_thbj-attr for thbjattr_thbj-attr.
define buffer sys-ctrl for ub.sys-ctrl.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  run thbjattr_code in this-procedure
    (input  p-upper-code
    ,input  '':U
    ,output v-label
    ,output v-user-can-edit
    ,output v-output-display
    ,output v-other
    ,output v-prop-list
    ,output v-prop-type-list
    ,output v-prop-label-list
    ,output v-global
    ,output v-host
    ,output v-shop
    ,output v-store
    ,output v-db
    ,output v-region
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_thbj-attr exclusive-lock where
            buf_thbj-attr.obj-type = p-obj-type
        and buf_thbj-attr.obj-code = p-obj-code
        and buf_thbj-attr.upper-prop-code = p-upper-code
        and buf_thbj-attr.prop-code = '':U  no-error.
  if not available buf_thbj-attr then do:
    create buf_thbj-attr.
    assign
    buf_thbj-attr.obj-type = p-obj-type
    buf_thbj-attr.obj-code = p-obj-code
    buf_thbj-attr.upper-prop-code = p-upper-code
    buf_thbj-attr.prop-code = '':U
    .
  end.
  for each buf_thbjattr_thbj-attr where
        buf_thbjattr_thbj-attr.upper-prop-code = p-upper-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if buf_thbjattr_thbj-attr.prop-code = '':U then next.
    if lookup( buf_thbjattr_thbj-attr.prop-code, v-prop-list) = 0 then next .
    if (lookup("compl", v-prop-type-list, chr(47)) > 0
    and v-prop-type-list <> buf_thbjattr_thbj-attr.prop-value-type)
    or (lookup("compl", v-prop-type-list, chr(47)) = 0
        and entry(lookup( buf_thbjattr_thbj-attr.prop-code, v-prop-list), v-prop-type-list) <> buf_thbjattr_thbj-attr.prop-value-type )
    then next .
    v-created = no.
    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = p-obj-type
          and buf_thbj-attr.obj-code = p-obj-code
          and buf_thbj-attr.upper-prop-code = buf_thbjattr_thbj-attr.upper-prop-code
          and buf_thbj-attr.prop-code = buf_thbjattr_thbj-attr.prop-code  no-error.
    if not available buf_thbj-attr then do:
      create buf_thbj-attr.
      assign
      buf_thbj-attr.obj-type = p-obj-type
      buf_thbj-attr.obj-code = p-obj-code
      buf_thbj-attr.upper-prop-code = buf_thbjattr_thbj-attr.upper-prop-code
      buf_thbj-attr.prop-code = buf_thbjattr_thbj-attr.prop-code
      buf_thbj-attr.prop-value-type = buf_thbjattr_thbj-attr.prop-value-type
      v-created = yes
      .
    end.
    if  (buf_thbjattr_thbj-attr.obj-type = '':U
    and buf_thbj-attr.obj-type = 'орг':U
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = '':U
    and buf_thbj-attr.obj-type = 'скл':U
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = '':U
    and buf_thbj-attr.obj-type = 'маг':U
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = '':U
    and buf_thbj-attr.obj-type = 'БД':U
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = 'орг':U
    and buf_thbj-attr.obj-type = 'скл':U
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = 'орг':U
    and buf_thbj-attr.obj-type = 'маг':U
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = buf_thbj-attr.obj-type)
    then do:
      buffer-copy
      buf_thbjattr_thbj-attr
      using
      property-value-character
      property-value-date
      property-value-decimal
      property-value-integer
      property-value-logical
      prop-value-type
      to buf_thbj-attr.
    end.
    if buf_thbj-attr.prop-value-type = 'void':U then do:
      run thbjattr_set-section in this-procedure (
                                                    input p-obj-type
                                                   ,input p-obj-code
                                                   ,input buf_thbj-attr.prop-code
                                                   ,input table thbjattr_thbj-attr
                                                   ) no-error.
     if error-status:error then do:
       undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
     end.
    end.
  end.
   find first sys-ctrl exclusive-lock.
   if     available sys-ctrl
   then do:
      sys-ctrl.whole-send-news = sys-ctrl.whole-send-news + 1.
      if sys-ctrl.whole-send-news > 1000
      then
         sys-ctrl.whole-send-news = 1.
   end.
   release sys-ctrl.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf2_thbj-attr for ub.thbj-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  for each buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = p-obj-type
      and buf_thbj-attr.obj-code = p-obj-code
      and buf_thbj-attr.upper-prop-code = p-upper-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf2_thbj-attr exclusive-lock where
              rowid(buf2_thbj-attr) = rowid(buf_thbj-attr) no-error.
    delete buf2_thbj-attr.
  end.
end.
end procedure.
procedure thbjattr_legacy :
do
on error undo, return error return-value
:
  define input  parameter p-upper-code as character no-undo .
  define output parameter p-level   as character no-undo .
  define output parameter p-up-way      as character no-undo .
  case p-upper-code :
        when 'autosale':U then do:   assign   p-level = "obj,host,global"   p-up-way = "autosale,autosale,autosale"   . end.
        when 'get-chk':U then do:   assign   p-level = "obj,host,global"   p-up-way = "get-chk,get-chk,get-chk"   . end.
        when 'chk-view':U then do:   assign   p-level = "obj,host,"   p-up-way = "chk-view,chk-view,chk-view"   . end.
        when 'cd-sending':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-sending,cd-sending,cd-sending"   . end.
        when 'cd-inf-send':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-inf-send,cd-inf-send,cd-inf-send"   . end.
        when 'scale-inf':U then do:   assign   p-level = "obj,,"   p-up-way = "scale-inf,,"   . end.
        when 'cd-type-ibm':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-ibm,cd-type-ibm,cd-type-ibm"   . end.
        when 'cd-type-ipc-servispl':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-ipc-servispl,cd-type-ipc-servispl,cd-type-ipc-servispl"   . end.
        when 'cd-type-magia-xml':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-magia-xml,cd-type-magia-xml,cd-type-magia-xml"   . end.
        when 'cd-type-NCR-GM':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-ncr-gm,cd-type-ncr-gm,cd-type-ncr-gm"   . end.
        when 'cd-type-NCR-AS-R':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-ncr-as-r,cd-type-ncr-as-r,cd-type-ncr-as-r"   . end.
        when 'cd-type-omron':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-omron,cd-type-omron,cd-type-omron"   . end.
        when 'cd-type-omron-new':U then do:   assign   p-level = "obj,host,gloabl"   p-up-way = "cd-type-omron-new,cd-type-omron-new,cd-type-omron-new"   . end.
        when 'cd-type-IBM-XML':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-ibm-xml,cd-type-ibm-xml,cd-type-ibm-xml"   . end.
        when 'cd-type-autotank':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-autotank,cd-type-autotank,cd-type-autotank"   . end.
        when 'cd-type-r-keeper':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-r-keeper,cd-type-r-keeper,cd-type-r-keeper"   . end.
        when 'cd-type-maria':U then do:   assign   p-level = "obj,host,global"   p-up-way = "cd-type-maria,cd-type-maria,cd-type-maria"   . end.
        when 'cd-type-IBS-TH':U then do:   assign   p-level = "obj,,global"   p-up-way = "cd-type-ibs-th,,cd-type-ibs-th"   . end.
        when 'ibs-th_main':U then do:   assign   p-level = "obj,,global"   p-up-way = "ibs-th_main,,ibs-th_main"   . end.
        when 'ibs-th_devices':U then do:   assign   p-level = "obj,,global"   p-up-way = "ibs-th_devices,,ibs-th_devices"   . end.
        when 'ibs-th_fisreg':U then do:   assign   p-level = "obj,,global"   p-up-way = "ibs-th_fisreg,,ibs-th_fisreg"   . end.
        when 'ibs-th_rec-print':U then do:   assign   p-level = "obj,,global"   p-up-way = "ibs-th_rec-print,,ibs-th_rec-print"   . end.
        when 'ibs-th_interface':U then do:   assign   p-level = "obj,,global"   p-up-way = "ibs-th_interface,,ibs-th_interface"   . end.
        when 'cd-type-IBS-TH-MOB':U then do:   assign   p-level = "obj,,global"   p-up-way = "cd-type-ibs-th-mob,,cd-type-ibs-th-mob"   . end.
        when 'ibs-th-mob_main':U then do:   assign   p-level = "obj,,global"   p-up-way = "ibs-th-mob_main,,ibs-th-mob_main"   . end.
        when 'ibs-th-mob_rec-print':U then do:   assign   p-level = "obj,,global"   p-up-way = "ibs-th-mob_rec-print,,ibs-th-mob_rec-print"   . end.
        when 'alias-tpsi':U then do:   assign   p-level = "obj,host,global"   p-up-way = "alias-tpsi,alias-tpsi,alias-tpsi"   . end.
        when 'abc-sale-day':U then do:   assign   p-level = "obj,host,global"   p-up-way = "abc-sale-day,abc-sale-day,abc-sale-day"   . end.
        when 'abc-global':U then do:   assign   p-level = ",,global"   p-up-way = ",,abc-global"   . end.
        when 'ord-global':U then do:   assign   p-level = ",,global"   p-up-way = ",,ord-global"   . end.
        when 'ord-obj':U then do:   assign   p-level = "obj,host,global"   p-up-way = "ord-obj,ord-obj,ord-obj"   . end.
        when 'Ass-obj':U then do:   assign   p-level = "obj,host,global"   p-up-way = "ass-obj,ass-obj,ass-obj"   . end.
        when 'contr-in':U then do:   assign   p-level = "obj,host,global"   p-up-way = "contr-in,contr-in,contr-in"   . end.
        when 'nakl_par':U then do:   assign   p-level = "obj,host,global"   p-up-way = "nakl_par,nakl_par,nakl_par"   . end.
        when 'overval':U then do:   assign   p-level = "obj,host,global"   p-up-way = "overval,overval,overval"   . end.
        when 'inv-global':U then do:   assign   p-level = ",,global"   p-up-way = ",,inv-global"   . end.
        when 'inv-obj':U then do:   assign   p-level = "obj,host,global"   p-up-way = "inv-obj,inv-obj,inv-obj"   . end.
        when 'arh-global':U then do:   assign   p-level = ",,global"   p-up-way = ",,arh-global"   . end.
        when 'rezerv-global':U then do:   assign   p-level = ",,global"   p-up-way = ",,rezerv-global"   . end.
        when 'rezerv-obj':U then do:   assign   p-level = "obj,host,global"   p-up-way = "rezerv-obj,rezerv-obj,rezerv-obj"   . end.
        when 'fin-global':U then do:   assign   p-level = ",,global"   p-up-way = ",,fin-global"   . end.
        when 'fin-plan':U then do:   assign   p-level = "obj,,"   p-up-way = "fin-plan,,"   . end.
        when 'gds-ref':U then do:   assign   p-level = ",,"   p-up-way = ",,gds-ref"   . end.
        when 'gds-ref_obj':U then do:   assign   p-level = "obj,,global"   p-up-way = "gds-ref_obj,,gds-ref"   . end.
        when 'dc-ref':U then do:   assign   p-level = "obj,,global"   p-up-way = "dc-ref,,dc-ref"   . end.
        when 'cli-all':U then do:   assign   p-level = ",,global"   p-up-way = ",,cli-all"   . end.
        when 'cashpays':U then do:   assign   p-level = ",,global"   p-up-way = ",,cashpays"   . end.
        when 'wthdoc':U then do:   assign   p-level = ",,global"   p-up-way = ",,wthdoc"   . end.
        when 'wthdoc_obj':U then do:   assign   p-level = "obj,,"   p-up-way = "wthdoc_obj,,"   . end.
        when 'attr-wthrep':U then do:   assign   p-level = ",,global"   p-up-way = ",,attr-wthrep"   . end.
        when 'rum':U then do:   assign   p-level = ",,global"   p-up-way = ",,rum"   . end.
    when 'rum':U then do:   assign   p-level = ",,global"   p-up-way = ",,rum"   . end.
        when 'rum_obj':U then do:   assign   p-level = "obj,,global"   p-up-way = "rum_obj,,rum"   . end.
        when 'prt-glob':U then do:   assign   p-level = ",,global"   p-up-way = ",,prt-glob"   . end.
        when 'report-glob':U then do:   assign   p-level = "obj,,global"   p-up-way = "prt-glob,,report-glob"   . end.
        when 'auto-task':U then do:   assign   p-level = ",db,global"   p-up-way = ",auto-task,auto-task"   . end.
        when 'izt-rul':U then do:   assign   p-level = ",,global"   p-up-way = ",,izt-rul"   . end.
        when 'nakl-glob':U then do:   assign   p-level = ",,global"   p-up-way = ",,nakl-glob"   . end.
        when 'prt-obj':U then do:   assign   p-level = "obj,,"   p-up-way = "prt-obj,,"   . end.
        when 'prt-firm':U then do:   assign   p-level = ",host,"   p-up-way = ",prt-firm,"   . end.
        when 'report-obj':U then do:   assign   p-level = "obj,,"   p-up-way = "report-obj,,"   . end.
        when 'report-firm':U then do:   assign   p-level = ",host,"   p-up-way = ",report-firm,"   . end.
        when 'rt-trn-doc':U then do:   assign   p-level = "obj,host,global"   p-up-way = "rt-trn-doc,rt-trn-doc,rt-trn-doc"   . end.
        when 'easyfuel':U then do:   assign   p-level = "obj,,"   p-up-way = "easyfuel,,"   . end.
        when 'images':U then do:   assign   p-level = ",,global"   p-up-way = ",,images"   . end.
        when 'code-range':U then do:   assign   p-level = ",db,global"   p-up-way = ",code-range,code-range"   . end.
        when 'bge-export':U then do:   assign   p-level = ",db,global"   p-up-way = ",bge-export,bge-export"   . end.
        when 'auto-task':U then do:   assign   p-level = ",db,global"   p-up-way = ",auto-task,auto-task"   . end.
        when 'wnd-size':U then do:   assign   p-level = ",,global"   p-up-way = ",,wnd-size"   . end.
        when 'obj-date':U then do:   assign   p-level = "obj,host,global"   p-up-way = "obj-date,obj-date,obj-date"   . end.
        when 'fbrattr':U then do:   assign   p-level = "obj,host,global"   p-up-way = "fbrattr,fbrattr,fbrattr"   . end.
        when 'petrol':U then do:   assign   p-level = "obj,host,global"   p-up-way = "petrol,petrol,petrol"   . end.
        when 'staff':U then do:   assign   p-level = ",,global"   p-up-way = "staff,staff,staff,staff,staff,staff,staff,staff,staff,staff,staff"   . end.
        when 'izt-rul':U then do:   assign   p-level = ",,global"   p-up-way = ",,izt-rul"   . end.
        when 'srv-auth-ASU':U then do:   assign   p-level = "obj,host,global"   p-up-way = "srv-auth-ASU,srv-auth-ASU,srv-auth-ASU"   . end.
        when 'egais':U then do:   assign   p-level = "obj,,global"   p-up-way = "egais,egais,egais,egais,egais"   . end.
        when 'gisMT':U then do:   assign   p-level = "db,region,global"   p-up-way = "gisMT,gisMT,gisMT"   . end.
            when 'marking':U then do:   assign   p-level = "obj,,global"   p-up-way = "marking,marking,marking"   . end.
        when 'mercur':U then do:   assign   p-level = "obj,host,global"   p-up-way = "mercur,mercur,mercur"   . end.
    otherwise do:
      undo, return error substitute("неизвестная секция параметров TH &1"
                                    , p-upper-code
                                    ).
    end.
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
do
  on error undo, return error
  :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-ucode :
            when 'rum':U then do:   if p-code <> '' AND lookup(p-code, 'goods,clients,gds-grp,cli-grp,chk-doc_ibs-th,chk-doc_ibs-th-mob,edoc,thref,pdf,rep,ord,cmb,fdoc':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'goods,clients,gds-grp,cli-grp,chk-doc_ibs-th,chk-doc_ibs-th-mob,edoc,thref,pdf,rep,ord,cmb,fdoc':U ), '0,0,0,0,1,1,0,0,0,1,0,0,0,0')). end.
            when 'rum_obj':U then do:   if p-code <> '' AND lookup(p-code, 'chk-doc_ibs-th,chk-doc_ibs-th-mob,rep':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'chk-doc_ibs-th,chk-doc_ibs-th-mob,rep':U ), '1,1,1')). end.
      otherwise do:
      end.
    end.
  end.
end procedure.
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
    case p-code :
            when 'lock':U then do:     assign     p-label = "Блокировка атрибутов на изменение"     p-type = 'L':U      p-format = "yes/no"     p-label = "Блокировка атрибутов на изменение"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'alcohol-prod':U then do:     assign     p-label = "Алкогольная продукция"     p-type = 'L':U      p-format = "+/ "     p-label = "Алкогольная продукция"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'egais-name':U then do:     assign     p-label = "Наименование товара в ЕГАИС"     p-type = 'C':U      p-format = "X(100)"     p-label = "Наименование товара в ЕГАИС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'ptrl-without-rvs':U then do:     assign     p-label = "Топливо - сверка не требуется"     p-type = 'L':U      p-format = "+/ "     p-label = "Топливо - сверка не требуется"     p-user-can-edit  = true     p-output-display = true     p-other = "check=gds-attr_check-ptrl-divis"      .   end.
            when 'office-type':U then do:     assign     p-label = "Тип услуги"     p-type = 'C':U      p-format = "X(50)"     p-label = "Тип услуги"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=ref\gds-ot.w/spr-param=office-type/check=gds-attr_check-office-type"      .   end.
            when 'mark-type':U then do:     assign     p-label = "Тип маркировки"     p-type = 'C':U      p-format = "X(50)"     p-label = "Тип маркировки"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=ref\mark-type.w/spr-param=mark-type/check=gds-attr_check-mark-type"      .   end.
            when 'emrc-type':U then do:     assign     p-label = "Тип ЕМЦ"     p-type = 'C':U      p-format = "X(50)"     p-label = "Тип ЕМЦ"     p-user-can-edit  = true     p-output-display = true     p-other = "cd/spr-ext=ref\emrc-type.w/spr-param=emrc-type/check=gds-attr_check-emrc-type"      .   end.
            when 'item-matter-mark':U then do:     assign     p-label = "Признак предмета расчета"     p-type = 'I':U      p-format = ">9"     p-label = "Признак предмета расчета"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=ref\gds-imm.w/spr-param=item-matter-mark/check=gds-attr_check-item-matter-mark"      .   end.
            when 'type-method-calc':U then do:     assign     p-label = "Признак способа расчета"     p-type = 'C':U      p-format = ">9"     p-label = "Признак способа расчета"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=ref\gds-tmc.w/spr-param=type-method-calc/check=gds-attr_check-type-method-calc/cd=IBM-XML"      .   end.
            when 'cash-book-id':U then do:     assign     p-label = "Кассовая книга"     p-type = 'I':U      p-format = ">>>>>>>>9"     p-label = "Кассовая книга"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'oper-serv-idd':U then do:     assign     p-label = "Платежный агент"     p-type = 'I':U      p-format = ">>>>>>>>9"     p-label = "Платежный агент"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'group-np':U then do:     assign     p-label = "Группа НП"     p-type = 'C':U      p-format = "X(50)"     p-label = "Группа НП"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=ref\group-np.w/spr-param=group-np/check=gds-attr_check-group-np"      .   end.
            when 'is-loyalty-payment':U then do:     assign     p-label = "Перечисление в систему лояльности"     p-type = 'L':U      p-format = "+/ "     p-label = "Перечисление в систему лояльности"     p-user-can-edit  = true     p-output-display = true     p-other = "check=gds-attr_check-is-loyalty-payment"      .   end.
            when 'ban-bonus':U then do:     assign     p-label = "Запрет на участие в бонусных программах\участие в скидке на итог"     p-type = 'L':U      p-format = "+/ "     p-label = "Запрет на участие в бонусных программах\участие в скидке на итог"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'null-price':U then do:     assign     p-label = "Разрешена нулевая цена"     p-type = 'L':U      p-format = "+/ "     p-label = "Разрешена нулевая цена"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'fasovka':U then do:     assign     p-label = "Товар фасуется"     p-type = 'L':U      p-format = "+/ "     p-label = "Товар фасуется"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'time-coock':U then do:     assign     p-label = "Печатать время приготовления в чеке"     p-type = 'L':U      p-format = "+/ "     p-label = "Печатать время приготовления в чеке"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'mark':U then do:     assign     p-label = "Товар требует обязательной маркировки"     p-type = 'L':U      p-format = "+/ "     p-label = "Товар требует обязательной маркировки"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'mercur_FGIS':U then do:     assign     p-label = "Является подконтрольным ФГИС Меркурий"     p-type = 'L':U      p-format = "+/-"     p-label = "Является подконтрольным ФГИС Меркурий"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'perishable':U then do:     assign     p-label = "Является скоропортящейся продукцией"     p-type = 'L':U      p-format = "+/-"     p-label = "Является скоропортящейся продукцией"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'production-only':U then do:     assign     p-label = "Только производство"     p-type = 'L':U      p-format = "+/-"     p-label = "Только производство"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'sum-grp-gl':U then do:     assign     p-label = "Группа товаров на кассе"     p-type = 'C':U      p-format = "X(5)"     p-label = "Группа товаров на кассе"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=gds-glob-sum-grps"      .   end.
            when '15x80':U then do:     assign     p-label = "Текст поля СОСТАВ 15x80 (DIGI-SM)"     p-type = 'C':U      p-format = "X(255)"     p-label = "Текст поля СОСТАВ 15x80 (DIGI-SM)"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=ref\struct-i.w/spr-param=15x80/init=gds-attr_init-15x80"      .   end.
            when '8x50':U then do:     assign     p-label = "Текст поля СОСТАВ 8x50 (CAS_LP-16x,SHTRIH-M)"     p-type = 'C':U      p-format = "X(255)"     p-label = "Текст поля СОСТАВ 8x50 (CAS_LP-16x,SHTRIH-M)"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=ref\struct-i.w/spr-param=8x50/init=gds-attr_init-8x50"      .   end.
            when '6x50':U then do:     assign     p-label = "Текст поля СОСТАВ 6x50 (CAS_CL5000 CAS_CL5000J)"     p-type = 'C':U      p-format = "X(255)"     p-label = "Текст поля СОСТАВ 6x50 (CAS_CL5000 CAS_CL5000J)"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=ref\struct-i.w/spr-param=6x50/init=gds-attr_init-6x50"      .   end.
            when 'calories':U then do:     assign     p-label = "Энерг.ценность ккал на 100г"     p-type = 'D':U      p-format = ">,>>9.9"     p-label = "Энерг.ценность ккал на 100г"     p-user-can-edit  = true     p-output-display = true     p-other = "check=gds-attr_check-can-energy-value"      .   end.
            when 'protein':U then do:     assign     p-label = "Белки г на 100г"     p-type = 'D':U      p-format = ">9.9"     p-label = "Белки г на 100г"     p-user-can-edit  = true     p-output-display = true     p-other = "check=gds-attr_check-can-energy-value"      .   end.
            when 'fat':U then do:     assign     p-label = "Жиры г на 100г"     p-type = 'D':U      p-format = ">9.9"     p-label = "Жиры г на 100г"     p-user-can-edit  = true     p-output-display = true     p-other = "check=gds-attr_check-can-energy-value"      .   end.
            when 'carbohydrate':U then do:     assign     p-label = "Углеводы г на 100г"     p-type = 'D':U      p-format = ">9.9"     p-label = "Углеводы г на 100г"     p-user-can-edit  = true     p-output-display = true     p-other = "check=gds-attr_check-can-energy-value"      .   end.
            when 'calc-cal-rec':U then do:     assign     p-label = "_Расчет энерг.ценн-ти из основного рец-та"     p-type = 'L':U      p-format = "+/-"     p-label = "_Расчет энерг.ценн-ти из основного рец-та"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'cash-parts':U then do:     assign     p-label = "По умолч.торгуется по партиям"     p-type = 'L':U      p-format = "+/-"     p-label = "По умолч.торгуется по партиям"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'ptrl-as-good':U then do:     assign     p-label = "ТНП продается через ТРК"     p-type = 'L':U      p-format = "+/ "     p-label = "ТНП продается через ТРК"     p-user-can-edit  = true     p-output-display = true     p-other = "check=gds-attr_check-ptrl-divis"      .   end.
            when 'dflt-insalepr':U then do:     assign     p-label = "По умолч. приходуется в продаж.ценах"     p-type = 'L':U      p-format = "+/ "     p-label = "По умолч. приходуется в продаж.ценах"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'gds-ptrl-densities':U then do:     assign     p-label = "Диапазон плотности"     p-type = 'C':U      p-format = "X(21)"     p-label = "Диапазон плотности"     p-user-can-edit  = true     p-output-display = true     p-other = "spr=gds-attr_gds-ptrl-densities"      .   end.
            when 'gds-CommodityCode':U then do:     assign     p-label = "Код номенклатурной классификации"     p-type = 'C':U      p-format = "X(21)"     p-label = "Код номенклатурной классификации"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'gds-code-AIS':U then do:     assign     p-label = "Коды АИС"     p-type = 'C':U      p-format = "X(21)"     p-label = "Коды АИС"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'length-of':U then do:     assign     p-label = "Длина"     p-type = 'I':U      p-format = ">>>>>>>>9"     p-label = "Длина"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'width-of':U then do:     assign     p-label = "Ширина"     p-type = 'I':U      p-format = ">>>>>>>>9"     p-label = "Ширина"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'height-of':U then do:     assign     p-label = "Высота"     p-type = 'I':U      p-format = ">>>>>>>>9"     p-label = "Высота"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'qnty-in-box':U then do:     assign     p-label = "Количество в коробке"     p-type = 'I':U      p-format = ">>>>>>>>9"     p-label = "Количество в коробке"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'weight-box':U then do:     assign     p-label = "Вес коробки (товар + коробка)"     p-type = 'D':U      p-format = ">>>>>>>>9.999"     p-label = "Вес коробки (товар + коробка)"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'qnty-on-pallet':U then do:     assign     p-label = "Количество на палете"     p-type = 'I':U      p-format = ">>>>>>>>9"     p-label = "Количество на палете"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'weight-of-pallet':U then do:     assign     p-label = "Вес палеты (товар + коробка)"     p-type = 'D':U      p-format = ">>>>>>>>9.999"     p-label = "Вес палеты (товар + коробка)"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'fuel-type':U then do:     assign     p-label = "Тип топлива"     p-type = 'C':U      p-format = "X(50)"     p-label = "Тип топлива"     p-user-can-edit  = true     p-output-display = true     p-other = "spr-ext=ref\gds-ft.p/spr-param=fuel-type/check=gds-attr_check-ptrl-divis"      .   end.
            when 'image-list':U then do:     assign     p-label = "Изображения"     p-type = 'C':U      p-format = "X(75)"     p-label = "Изображения"     p-user-can-edit  = false     p-output-display = true     p-other = ""      .   end.
            when 'MercUnits':U then do:     assign     p-label = "Дополнительные единицы измерения"     p-type = 'C':U      p-format = "X(100)"     p-label = "Дополнительные единицы измерения"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'weighed-gds':U then do:     assign     p-label = "Является весовым товаром"     p-type = 'L':U      p-format = "+/ "     p-label = "Является весовым товаром"     p-user-can-edit  = false     p-output-display = true     p-other = ""      .   end.
            when 'IS18Plus':U then do:     assign     p-label = "Наличие возрастных ограничений"     p-type = 'I':U      p-format = ">9"     p-label = "Наличие возрастных ограничений"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'loyalty-gift':U then do:     assign     p-label = "Оплата баллами Семейная команда"     p-type = 'I':U      p-format = ">9"     p-label = "Оплата баллами Семейная команда"     p-user-can-edit  = false     p-output-display = true     p-other = ""      .   end.
      otherwise do:
        undo, return error substitute("неизвестный глобальный атрибут товара &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'lock':U then do:     assign     p-tooltip = "Блокировка атрибутов на изменение"     p-label = "Блокировка атрибутов на изменение" .   end.
            when 'alcohol-prod':U then do:     assign     p-tooltip = "Алкогольная продукция"     p-label = "Алкогольная продукция" .   end.
            when 'egais-name':U then do:     assign     p-tooltip = "Наименование товара в ЕГАИС"     p-label = "Наименование товара в ЕГАИС" .   end.
            when 'ptrl-without-rvs':U then do:     assign     p-tooltip = "Топливо - сверка не требуется"     p-label = "Топливо - сверка не требуется" .   end.
            when 'office-type':U then do:     assign     p-tooltip = "Тип услуги"     p-label = "Тип услуги" .   end.
            when 'mark-type':U then do:     assign     p-tooltip = "Тип маркировки"     p-label = "Тип маркировки" .   end.
            when 'emrc-type':U then do:     assign     p-tooltip = "Тип ЕМЦ"     p-label = "Тип ЕМЦ" .   end.
            when 'item-matter-mark':U then do:     assign     p-tooltip = "Признак предмета расчета"     p-label = "Признак предмета расчета" .   end.
            when 'type-method-calc':U then do:     assign     p-tooltip = "Признак способа расчета"     p-label = "Признак способа расчета" .   end.
            when 'cash-book-id':U then do:     assign     p-tooltip = "Кассовая книга"     p-label = "Кассовая книга" .   end.
            when 'oper-serv-idd':U then do:     assign     p-tooltip = "Платежный агент"     p-label = "Платежный агент" .   end.
            when 'group-np':U then do:     assign     p-tooltip = "Группа НП"     p-label = "Группа НП" .   end.
            when 'is-loyalty-payment':U then do:     assign     p-tooltip = "Перечисление в систему лояльности"     p-label = "Перечисление в систему лояльности" .   end.
            when 'ban-bonus':U then do:     assign     p-tooltip = "Запрет на участие в бонусных программах\участие в скидке на итог"     p-label = "Запрет на участие в бонусных программах\участие в скидке на итог" .   end.
            when 'null-price':U then do:     assign     p-tooltip = "Разрешена нулевая цена"     p-label = "Разрешена нулевая цена" .   end.
            when 'fasovka':U then do:     assign     p-tooltip = "Товар фасуется"     p-label = "Товар фасуется" .   end.
                when 'time-coock':U then do:     assign     p-tooltip = "Печатать время приготовления в чеке"     p-label = "Печатать время приготовления в чеке" .   end.
            when 'mark':U then do:     assign     p-tooltip = "Товар требует обязательной маркировки"     p-label = "Товар требует обязательной маркировки" .   end.
            when 'mercur_FGIS':U then do:     assign     p-tooltip = "Является подконтрольным ФГИС Меркурий"     p-label = "Является подконтрольным ФГИС Меркурий" .   end.
            when 'perishable':U then do:     assign     p-tooltip = "Является скоропортящейся продукцией"     p-label = "Является скоропортящейся продукцией" .   end.
            when 'production-only':U then do:     assign     p-tooltip = "Используется только для производства (альтернатива)"     p-label = "Только производство" .   end.
            when 'sum-grp-gl':U then do:     assign     p-tooltip = "Номер группы товаров на кассе (IBM-POS)"     p-label = "Группа товаров на кассе" .   end.
            when '15x80':U then do:     assign     p-tooltip = "Текст поля СОСТАВ для этикетки 15x80 (DIGI-SM)"     p-label = "Текст поля СОСТАВ 15x80 (DIGI-SM)" .   end.
            when '8x50':U then do:     assign     p-tooltip = "Текст поля СОСТАВ для этикетки 8x50 (CAS_LP-16x,SHTRIH-M)"     p-label = "Текст поля СОСТАВ 8x50 (CAS_LP-16x,SHTRIH-M)" .   end.
            when '6x50':U then do:     assign     p-tooltip = "Текст поля СОСТАВ для этикетки 6x50 (CAS_CL5000 CAS_CL5000J)"     p-label = "Текст поля СОСТАВ 6x50 (CAS_CL5000 CAS_CL5000J)" .   end.
            when 'calories':U then do:     assign     p-tooltip = "Энерг.ценность ккал на 100г"     p-label = "Энерг.ценность ккал на 100г" .   end.
            when 'protein':U then do:     assign     p-tooltip = "Белки г на 100г"     p-label = "Белки г на 100г" .   end.
            when 'fat':U then do:     assign     p-tooltip = "Жиры г на 100г"     p-label = "Жиры г на 100г" .   end.
            when 'carbohydrate':U then do:     assign     p-tooltip = "Углеводы г на 100г"     p-label = "Углеводы г на 100г" .   end.
            when 'calc-cal-rec':U then do:     assign     p-tooltip = "Расчет энергетической ценности из основного рецепта"     p-label = "_Расчет энерг.ценн-ти из основного рец-та" .   end.
            when 'cash-parts':U then do:     assign     p-tooltip = "По умолч.торгуется по партиям"     p-label = "По умолч.торгуется по партиям" .   end.
            when 'ptrl-as-good':U then do:     assign     p-tooltip = "ТНП продается через ТРК"     p-label = "ТНП продается через ТРК" .   end.
            when 'dflt-insalepr':U then do:     assign     p-tooltip = "По умолч. приходуется в продаж.ценах"     p-label = "По умолч. приходуется в продаж.ценах" .   end.
            when 'gds-ptrl-densities':U then do:     assign     p-tooltip = "Диапазон плотности"     p-label = "Диапазон плотности" .   end.
            when 'gds-CommodityCode':U then do:     assign     p-tooltip = "Код номенклатурной классификации"     p-label = "Код номенклатурной классификации" .   end.
            when 'gds-code-AIS':U then do:     assign     p-tooltip = "Коды АИС"     p-label = "Коды АИС" .   end.
            when 'length-of':U then do:     assign     p-tooltip = "Длина"     p-label = "Длина" .   end.
            when 'width-of':U then do:     assign     p-tooltip = "Ширина"     p-label = "Ширина" .   end.
            when 'height-of':U then do:     assign     p-tooltip = "Высота"     p-label = "Высота" .   end.
            when 'qnty-in-box':U then do:     assign     p-tooltip = "Количество в коробке"     p-label = "Количество в коробке" .   end.
            when 'weight-box':U then do:     assign     p-tooltip = "Вес коробки (товар + коробка)"     p-label = "Вес коробки (товар + коробка)" .   end.
            when 'qnty-on-pallet':U then do:     assign     p-tooltip = "Количество на палете"     p-label = "Количество на палете" .   end.
            when 'weight-of-pallet':U then do:     assign     p-tooltip = "Вес палеты (товар + коробка)"     p-label = "Вес палеты (товар + коробка)" .   end.
            when 'fuel-type':U then do:     assign     p-tooltip = "Тип топлива"     p-label = "Тип топлива" .   end.
            when 'image-list':U then do:     assign     p-tooltip = "Изображения"     p-label = "Изображения" .   end.
            when 'MercUnits':U then do:     assign     p-tooltip = "Дополнительные единицы измерения"     p-label = "Дополнительные единицы измерения" .   end.
            when 'weighed-gds':U then do:     assign     p-tooltip = "Является весовым товаром"     p-label = "Является весовым товаром" .   end.
            when 'IS18Plus':U then do:     assign     p-tooltip = "Наличие возрастных ограничений"     p-label = "Наличие возрастных ограничений" .   end.
            when 'loyalty-gift':U then do:     assign     p-tooltip = "Оплата баллами Семейная команда"     p-label = "Оплата баллами Семейная команда" .   end.
      otherwise do:
        undo, return error substitute("Неизвестный глобальный атрибут товара &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gds-attr-value :
do
  on error undo, return error
  :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  define buffer goods          for ub.goods.
  define buffer buf-goods-attr for ub.goods-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
    run gds-attr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-goods-attr no-lock where
                buf-goods-attr.attr-code = p-code
           and  buf-goods-attr.gds-code  = p-gds-code no-error .
   if avail buf-goods-attr then do:
    assign
    p-value = buf-goods-attr.attr-value.
   end.
   else do:
      find first goods where goods.gds-code eq p-gds-code no-lock no-error.
      if available goods
      then do:
         run ggoattr-value (input  goods.grp-code,
                            input  0,
                            input  "",
                            input  0,
                            input  p-code,
                            output p-value,
                            output p-type) no-error.
         if error-status:error
         then
            p-value = if p-type = 'L':U then "no":U else "".
     end.
     else
        p-value = if p-type = 'L':U then "no":U else "".
     end.
end.
end procedure.
procedure gds-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define input parameter p-value    like ub.goods-attr.attr-value no-undo .
    define buffer buf_goods-attr for ub.goods-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gds-attr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_goods-attr exclusive-lock where
               buf_goods-attr.gds-code  = p-gds-code
          AND  buf_goods-attr.attr-code = p-code no-error .
    if not available buf_goods-attr then do:
      create buf_goods-attr .
      assign
        buf_goods-attr.gds-code  = p-gds-code
        buf_goods-attr.attr-code = p-code
        buf_goods-attr.attr-value = p-value no-error
      .
    end.
    ELSE
      buf_goods-attr.attr-value = p-value no-error.
    if error-status :error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-EXIST :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .
    define buffer buf_goods-attr for ub.goods-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gds-attr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_goods-attr NO-lock where
               buf_goods-attr.gds-code  = p-gds-code
           AND buf_goods-attr.attr-code = p-code no-error .
    if available buf_goods-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure gds-attr-DELETE :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define output parameter p-DELETED  AS LOGICAL no-undo .
    define buffer buf_goods-attr for ub.goods-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gds-attr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_goods-attr exclusive-lock where
               buf_goods-attr.gds-code  = p-gds-code
           AND buf_goods-attr.attr-code = p-code no-error .
    if not available buf_goods-attr then do:
      p-DELETED = NO.
    end.
    ELSE DO:
       delete buf_goods-attr.
      p-DELETED = YES.
    END.
  end.
end procedure.
procedure gds-attr-copy-to :
do
  on error undo, return error
  :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  define buffer buf-goods-attr for ub.goods-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  define variable v-type           as character no-undo .
    run gds-attr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-goods-attr no-lock where
                buf-goods-attr.attr-code = p-code
           and  buf-goods-attr.gds-code  = p-gds-code no-error .
   if not p-bh:available then do:
     p-bh:buffer-create().
   end.
   if avail buf-goods-attr then do:
     assign
     p-bh:buffer-field("attr-value"):buffer-value = buf-goods-attr.attr-value.
   end.
   else do:
     assign
     p-bh:buffer-field("attr-value"):buffer-value = if v-type = 'L':U then "no":U else "".
   end.
end.
end procedure.
procedure gds-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'alcohol-prod':U then do:     assign     p-news = true.   end.
            when 'egais-name':U then do:     assign     p-news = true.   end.
            when 'ptrl-without-rvs':U then do:     assign     p-news = true.   end.
            when 'office-type':U then do:     assign     p-news = true.   end.
            when 'mark-type':U then do:     assign     p-news = true.   end.
            when 'emrc-type':U then do:     assign     p-news = true.   end.
            when 'item-matter-mark':U then do:     assign     p-news = true.   end.
            when 'type-method-calc':U then do:     assign     p-news = true.   end.
            when 'cash-book-id':U then do:     assign     p-news = true.   end.
            when 'oper-serv-idd':U then do:     assign     p-news = true.   end.
            when 'group-np':U then do:     assign     p-news = true.   end.
            when 'is-loyalty-payment':U then do:     assign     p-news = true.   end.
            when 'ban-bonus':U then do:     assign     p-news = true.   end.
            when 'null-price':U then do:     assign     p-news = true.   end.
            when 'fasovka':U then do:     assign     p-news = true.   end.
                when 'time-coock':U then do:     assign     p-news = true.   end.
            when 'mark':U then do:     assign     p-news = true.   end.
            when 'sum-grp-gl':U then do:     assign     p-news = true.   end.
            when 'mercur_FGIS':U then do:     assign     p-news = true.   end.
            when 'perishable':U then do:     assign     p-news = true.   end.
            when 'production-only':U then do:     assign     p-news = true.   end.
            when '15x80':U then do:     assign     p-news = true.   end.
            when '8x50':U then do:     assign     p-news = true.   end.
            when '6x50':U then do:     assign     p-news = true.   end.
            when 'calories':U then do:     assign     p-news = true.   end.
            when 'protein':U then do:     assign     p-news = true.   end.
            when 'fat':U then do:     assign     p-news = true.   end.
            when 'carbohydrate':U then do:     assign     p-news = true.   end.
            when 'calc-cal-rec':U then do:     assign     p-news = true.   end.
            when 'cash-parts':U then do:     assign     p-news = true.   end.
            when 'ptrl-as-good':U then do:     assign     p-news = true.   end.
            when 'dflt-insalepr':U then do:     assign     p-news = true.   end.
            when 'gds-ptrl-densities':U then do:     assign     p-news = true.   end.
            when 'gds-CommodityCode':U then do:     assign     p-news = true.   end.
            when 'gds-code-AIS':U then do:     assign     p-news = true.   end.
            when 'length-of':U then do:     assign     p-news = true.   end.
            when 'width-of':U then do:     assign     p-news = true.   end.
            when 'height-of':U then do:     assign     p-news = true.   end.
            when 'qnty-in-box':U then do:     assign     p-news = true.   end.
            when 'weight-box':U then do:     assign     p-news = true.   end.
            when 'qnty-on-pallet':U then do:     assign     p-news = true.   end.
            when 'weight-of-pallet':U then do:     assign     p-news = true.   end.
            when 'fuel-type':U then do:     assign     p-news = true.   end.
            when 'image-list':U then do:     assign     p-news = true.   end.
            when 'MercUnits':U then do:     assign     p-news = true.   end.
            when 'weighed-gds':U then do:     assign     p-news = true.   end.
            when 'IS18Plus':U then do:     assign     p-news = true.   end.
           when 'loyalty-gift':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error substitute("неизвестный глобальный атрибут товара &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gds-attr-copy :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-copy           as logical   no-undo .
    case p-code :
            when 'alcohol-prod':U then do:     assign     p-copy = true.   end.
            when 'egais-name':U then do:     assign     p-copy = true.   end.
            when 'ptrl-without-rvs':U then do:     assign     p-copy = true.   end.
            when 'office-type':U then do:     assign     p-copy = true.   end.
            when 'mark-type':U then do:     assign     p-copy = true.   end.
            when 'emrc-type':U then do:     assign     p-copy = true.   end.
            when 'item-matter-mark':U then do:     assign     p-copy = true.   end.
            when 'type-method-calc':U then do:     assign     p-copy = true.   end.
            when 'cash-book-id':U then do:     assign     p-copy = true.   end.
            when 'oper-serv-idd':U then do:     assign     p-copy = true.   end.
            when 'group-np':U then do:     assign     p-copy = true.   end.
            when 'is-loyalty-payment':U then do:     assign     p-copy = true.   end.
            when 'ban-bonus':U then do:     assign     p-copy = true.   end.
            when 'null-price':U then do:     assign     p-copy = true.   end.
            when 'fasovka':U then do:     assign     p-copy = true.   end.
            when 'time-coock':U then do:     assign     p-copy = true.   end.
            when 'mark':U then do:     assign     p-copy = true.   end.
            when 'sum-grp-gl':U then do:     assign     p-copy = true.   end.
            when 'mercur_FGIS':U then do:     assign     p-copy = true.   end.
            when 'perishable':U then do:     assign     p-copy = true.   end.
            when 'production-only':U then do:     assign     p-copy = true.   end.
            when '15x80':U then do:     assign     p-copy = true.   end.
            when '8x50':U then do:     assign     p-copy = true.   end.
            when '6x50':U then do:     assign     p-copy = true.   end.
            when 'calories':U then do:     assign     p-copy = true.   end.
            when 'protein':U then do:     assign     p-copy = true.   end.
            when 'fat':U then do:     assign     p-copy = true.   end.
            when 'carbohydrate':U then do:     assign     p-copy = true.   end.
            when 'calc-cal-rec':U then do:     assign     p-copy = false.   end.
            when 'cash-parts':U then do:     assign     p-copy = true.   end.
            when 'ptrl-as-good':U then do:     assign     p-copy = true.   end.
            when 'dflt-insalepr':U then do:     assign     p-copy = false.   end.
            when 'gds-ptrl-densities':U then do:     assign     p-copy = false.   end.
            when 'gds-CommodityCode':U then do:     assign     p-copy = true.   end.
            when 'gds-code-AIS':U then do:     assign     p-copy = true.   end.
            when 'length-of':U then do:     assign     p-copy = true.   end.
            when 'width-of':U then do:     assign     p-copy = true.   end.
            when 'height-of':U then do:     assign     p-copy = true.   end.
            when 'qnty-in-box':U then do:     assign     p-copy = true.   end.
            when 'weight-box':U then do:     assign     p-copy = true.   end.
            when 'qnty-on-pallet':U then do:     assign     p-copy = true.   end.
            when 'weight-of-pallet':U then do:     assign     p-copy = true.   end.
            when 'fuel-type':U then do:     assign     p-copy = true.   end.
            when 'image-list':U then do:     assign     p-copy = true.   end.
            when 'MercUnits':U then do:     assign     p-copy = true.   end.
            when 'weighed-gds':U then do:     assign     p-copy = true.   end.
            when 'IS18Plus':U then do:     assign     p-copy = true.   end.
            when 'loyalty-gift':U then do:     assign     p-copy = true.   end.
      otherwise do:
        undo, return error substitute("неизвестный глобальный атрибут товара &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  define buffer buf_goods for ub.goods.
  define variable v-is-petrolium as logical no-undo .
  define variable v-is-pieces    as logical no-undo .
  do
  on error undo, return error return-value
  :
    if p-mode = 'удаление':U then do:
      p-correct = yes.
      return.
    end.
    find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
      return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                              , p-gds-code).
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) no-error.
    if error-status:error then do:
      assign
        p-error-code =  substitute("&1 &2", error-status:get-message(1) , return-value )
      .
      return.
    end.
    if not v-is-petrolium and not p-code = 'ptrl-as-good':U then do:
      case p-code:
        when 'ptrl-without-rvs':U then do:
          assign
            p-error-code = substitute("Товар-топливо не требующий сверки должен иметь топливную единицу измерения")
          .
        end.
      end case.
      return p-error-code.
    end.
    if v-is-pieces then do:
      case p-code:
        when 'ptrl-without-rvs':U  then do:
          assign
            p-error-code = substitute("Товар-топливо не требующий сверки должен иметь дробную единицу измерения")
          .
        end.
        when 'ptrl-as-good':U then do:
          assign
            p-error-code = substitute("ТНП продающийся через ТРК должен иметь дробную единицу измерения ")
          .
        end.
      end case.
      return p-error-code.
    end.
    assign
    p-correct = yes.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value        as character no-undo .
define variable v-is-petrolium as logical no-undo .
define variable v-is-pieces    as logical no-undo .
define buffer buf_goods for ub.goods.
  do
  on error undo, return error
  :
    find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
      message
        substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута", p-gds-code)
      view-as alert-box error.
      return.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) no-error.
    if error-status:error then do:
      message
        substitute("&1 &2", error-status:get-message(1) , return-value )
      view-as alert-box error.
      return.
    end.
    if not v-is-petrolium then do:
      message
        substitute("Товар-топливо должен иметь топливную единицу измерения для задания диапазона плотности")
      view-as alert-box error.
      return.
    end.
    if v-is-pieces then do:
      message
        substitute("Товар-топливо должен иметь дробную единицу измерения для задания диапазона плотности")
      view-as alert-box error.
      return.
    end.
    assign
    v-value = p-value.
    run ref/gdsptrdn.w (
                    input p-gds-code
                   ,input-output v-value
                   ) no-error .
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_gds-host-attr for ub.gds-host-attr.
do
on error undo, return error return-value
:
  CASE p-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
     find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
      if not available buf_goods then do:
        return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                                , p-gds-code).
      end.
      if buf_goods.gds-type <> 'у':U and p-value <> 'card-act':U  then do:
        p-error-code = "Товар должен быть услугой".
      end.
      if lookup(p-value, 'oss-pay,tso-ret,card-act':U) = 0 then do:
        p-error-code = "Значение атрибута должно быть одним из списка 'oss-pay,tso-ret,card-act':U".
      end.
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.
procedure gds-attr_check-mark-type :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
define variable MarkType as ibs.th.str.marking.Types no-undo.
define buffer buf_goods for ub.goods.
define buffer buf_gds-host-attr for ub.gds-host-attr.
do
on error undo, return error return-value
:
  CASE p-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
      MarkType = new ibs.th.str.marking.Types ().
      if MarkType:GetKeyIntDB(p-value) < 0 then do:
        p-error-code = "Неизвестное значение атрибута".
      end.
      delete object MarkType.
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.
procedure gds-attr_check-emrc-type :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
define buffer buf_code for ub.code.
do
on error undo, return error return-value
:
  if   ( p-mode eq 'ДОБАВЛЕНИЕ':U
     or p-mode eq 'ИЗМЕНЕНИЕ':U)
     and p-value ne ""
  then do:
     find first buf_code  where buf_code.parent = "EMC"
                            and buf_code.code   = p-value
     no-lock no-error .
     if not available buf_code then do:
        return error substitute("Нет такой группы в спрочнике ЕМЦ.").
     end.
  end.
end.
assign
p-correct = yes.
end procedure.
procedure gds-attr_check-item-matter-mark :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
do
on error undo, return error return-value
:
  CASE p-mode:
    when 'ДОБАВЛЕНИЕ':U
    or
    when 'ИЗМЕНЕНИЕ':U
    then do:
      if    lookup(p-value, '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19':U) = 0
      then do:
         p-error-code =  "Значение атрибута должно быть одним из списка '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19':U" .
      end.
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.
procedure gds-attr_check-type-method-calc :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
do
on error undo, return error return-value
:
  CASE p-mode:
    when 'ДОБАВЛЕНИЕ':U
    or
    when 'ИЗМЕНЕНИЕ':U
    then do:
      if num-entries(p-value) <> 2 or
         lookup(entry(1,p-value), '1,2,3,4,5,6,7':U) = 0 or
         lookup(entry(2,p-value), "1,2") = 0
      then do:
         p-error-code =  "Значение атрибута не соответствует допустимым значениям" .
      end.
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.
procedure gds-attr_check-cash-book-id :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
   define variable VValue as integer no-undo.
   do
   on error undo, return error return-value
   :
     CASE p-mode:
       when 'ДОБАВЛЕНИЕ':U
       or
       when 'ИЗМЕНЕНИЕ':U
       then do:
          VValue = int64(p-value) no-error.
          if     p-value ne ""
             and VValue eq 0
        then
           p-error-code = "Значение не может быть 0".
        else do:
            find first cashbook where CashBook.id eq VValue no-lock no-error.
            if not available  cashbook
            then
               p-error-code = "Не существует кассоdая книга с номером " + string( VValue).
        end.
        if p-error-code <> "" then
           return p-error-code.
       end.
     END CASE.
   end.
   assign
   p-correct = yes.
end procedure.
procedure gds-attr_check-oper-serv-id :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
   define variable VValue as integer no-undo.
   do
   on error undo, return error return-value
   :
     CASE p-mode:
       when 'ДОБАВЛЕНИЕ':U
       or
       when 'ИЗМЕНЕНИЕ':U
       then do:
          VValue = int64(p-value) no-error.
          if     p-value ne ""
             and VValue eq 0
        then
           p-error-code = "Значение не может быть 0".
        else do:
            find first operserv where operserv.id eq VValue no-lock no-error.
            if not available  operserv
            then
               p-error-code = "Не существует оператора с номером " + string( VValue).
        end.
        if p-error-code <> "" then
           return p-error-code.
       end.
     END CASE.
   end.
   assign
   p-correct = yes.
end procedure.
procedure gds-attr_check-group-np :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_gds-host-attr for ub.gds-host-attr.
  define variable v-is-petrolium as logical no-undo .
  define variable v-is-pieces    as logical no-undo .
do
on error undo, return error return-value
:
  CASE p-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
     find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
      if not available buf_goods then do:
        return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                                , p-gds-code).
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) no-error.
    if error-status:error then do:
      message
        substitute("&1 &2", error-status:get-message(1) , return-value )
      view-as alert-box error.
      return.
    end.
    if not v-is-petrolium then do:
      message
        substitute("Товар-топливо должен иметь топливную единицу измерения для задания диапазона плотности")
      view-as alert-box error.
      return.
    end.
    if v-is-pieces then do:
      message
        substitute("Товар-топливо должен иметь дробную единицу измерения для задания диапазона плотности")
      view-as alert-box error.
      return.
    end.
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_gds-host-attr for ub.gds-host-attr.
do
on error undo, return error return-value
:
  CASE p-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
     find first buf_goods no-lock where buf_goods.gds-code = p-gds-code.
      if not (
              buf_goods.gds-type = 'у':U
              and
              buf_goods.unit-base = "руб") then do:
        assign
        p-error-code = substitute("Перечисление в систему лояльности должно быть услугой,&1" +
                      "с единицей измерения равной единице измерения национальной валюты (&2)"
                      , chr(10)
                      , "руб"
                      ).
        return p-error-code.
      end.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.
procedure gds-attr_init-15x80 :
define input parameter p-gds-code as integer no-undo .
define output parameter p-attr-value as character no-undo .
define variable output-num-lines as integer no-undo init 1.
define variable v-value as character no-undo .
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  if p-gds-code > 0 then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = p-gds-code  .
      p-attr-value = Break-n-line
        ( INPUT buf_goods.struct,
          INPUT right-trim(fill(string(80) + chr(44), 15), chr(44)),
          OUTPUT output-num-lines
          ) .
  end.
end.
end procedure.
procedure gds-glob-sum-grps :
define input parameter p-mode  as character no-undo .
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input-output parameter p-value as integer no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE rid-list as character no-undo .
define buffer buf_sum-grp for ub.sum-grp.
  do
  on error undo, return error
  :
    find first buf_sum-grp no-lock where
               buf_sum-grp.grp-code = integer(p-value) no-error .
    if avail buf_sum-grp then do:
      assign
      rid-list = string(recid(buf_sum-grp))
      .
    end.
    if p-mode = 'ПРОСМОТР':U then do:
    run ref/gds-sumgrp.p ( input this-procedure
                          ,input ""
                          ,input-output rid-list).
    end.
    else do:
      run ref/gds-sumgrp.p ( input this-procedure
                          ,input "b-sel"
                          ,input-output rid-list).
    end.
    if rid-list <> "":U then do:
      find first buf_sum-grp no-lock where
                 recid(buf_sum-grp) = integer(entry(1, rid-list)) no-error .
      if not avail buf_sum-grp then return error.
      assign
      p-value = buf_sum-grp.grp-code
      p-setted = yes
      .
    end.
    else p-setted = no.
  end.
end procedure.
procedure gds-attr_init-8x50 :
define input parameter p-gds-code as integer no-undo .
define output parameter p-attr-value as character no-undo .
define variable output-num-lines as integer no-undo .
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  if p-gds-code > 0 then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = p-gds-code  .
    p-attr-value = Break-n-line
      ( INPUT buf_goods.struct,
        INPUT right-trim(fill(string(50) + chr(44), 8), chr(44)),
        OUTPUT output-num-lines
        ) .
  end.
end.
end procedure.
procedure gds-attr_init-6x50 :
define input parameter p-gds-code as integer no-undo .
define output parameter p-attr-value as character no-undo .
define variable output-num-lines as integer no-undo .
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  if p-gds-code > 0 then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = p-gds-code  .
    p-attr-value = Break-n-line
      ( INPUT buf_goods.struct,
        INPUT right-trim(fill(string(50) + chr(44), 6), chr(44)),
        OUTPUT output-num-lines
        ) .
  end.
end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  define buffer buf_goods for ub.goods.
  define variable v-label as character no-undo .
  define variable v-tool-tip as character no-undo .
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-mode = 'удаление':U then do:
      p-correct = yes.
      return.
    end.
    find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
      return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                              , p-gds-code).
    end.
    run  gds-attr-value in this-procedure (
                                            input buf_goods.gds-code
                                           ,input 'calc-cal-rec':U
                                           ,output v-value
                                           ,output v-type) .
    if logical(v-value) = no then do:
      assign
      p-correct = yes.
      return ''.
    end.
    else do:
      run gds-attr-tooltip in this-procedure ( input p-code
                                              ,output v-tool-tip
                                              ,output v-label) no-error.
      if error-status:error then do:
        v-label = p-code.
      end.
      assign
      p-error-code = substitute("Запрещено изменение атрибута &1&2" +
                    "на товаре &3 стоит флаг <Расчет энергетической ценности из основного рецепта>"
                    , v-label
                    , chr(10)
                    , buf_goods.gds-code
                    ).
      return p-error-code.
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'alcohol-prod':U then do:     assign     p-section-num = 0.   end.
            when 'egais-name':U then do:     assign     p-section-num = 0.   end.
            when 'ptrl-without-rvs':U then do:     assign     p-section-num = 6.   end.
            when 'office-type':U then do:     assign     p-section-num = 1.   end.
            when 'mark-type':U then do:     assign     p-section-num = 1.   end.
            when 'emrc-type':U then do:     assign     p-section-num = 1.   end.
            when 'item-matter-mark':U then do:     assign     p-section-num = 1.   end.
            when 'type-method-calc':U then do:     assign     p-section-num = 1.   end.
            when 'cash-book-id':U then do:     assign     p-section-num = 1.   end.
            when 'oper-serv-idd':U then do:     assign     p-section-num = 1.   end.
            when 'group-np':U then do:     assign     p-section-num = 6.   end.
            when 'is-loyalty-payment':U then do:     assign     p-section-num = 1.   end.
            when 'ban-bonus':U then do:     assign     p-section-num = 1.   end.
            when 'null-price':U then do:     assign     p-section-num = 1.   end.
            when 'fasovka':U then do:     assign     p-section-num = 1.   end.
            when 'time-coock':U then do:     assign     p-section-num = 1.   end.
            when 'mercur_FGIS':U then do:     assign     p-section-num = 1.   end.
            when 'perishable':U then do:     assign     p-section-num = 1.   end.
            when 'production-only':U then do:     assign     p-section-num = 1.   end.
            when 'mark':U then do:     assign     p-section-num = 0.   end.
            when 'sum-grp-gl':U then do:     assign     p-section-num = 1.   end.
            when '15x80':U then do:     assign     p-section-num = 5.   end.
            when '8x50':U then do:     assign     p-section-num = 5.   end.
            when '6x50':U then do:     assign     p-section-num = 5.   end.
            when 'calories':U then do:     assign     p-section-num = 2.   end.
            when 'protein':U then do:     assign     p-section-num = 2.   end.
            when 'fat':U then do:     assign     p-section-num = 2.   end.
            when 'carbohydrate':U then do:     assign     p-section-num = 2.   end.
            when 'calc-cal-rec':U then do:     assign     p-section-num = 2.   end.
            when 'cash-parts':U then do:     assign     p-section-num = 1.   end.
            when 'ptrl-as-good':U then do:     assign     p-section-num = 6.   end.
            when 'dflt-insalepr':U then do:     assign     p-section-num = 6.   end.
            when 'gds-ptrl-densities':U then do:     assign     p-section-num = 6.   end.
            when 'gds-CommodityCode':U then do:     assign     p-section-num = 1.   end.
            when 'gds-code-AIS':U then do:     assign     p-section-num = 6.   end.
            when 'length-of':U then do:     assign     p-section-num = 3.   end.
            when 'width-of':U then do:     assign     p-section-num = 3.   end.
            when 'height-of':U then do:     assign     p-section-num = 3.   end.
            when 'qnty-in-box':U then do:     assign     p-section-num = 4.   end.
            when 'weight-box':U then do:     assign     p-section-num = 4.   end.
            when 'qnty-on-pallet':U then do:     assign     p-section-num = 4.   end.
            when 'weight-of-pallet':U then do:     assign     p-section-num = 1.   end.
            when 'fuel-type':U then do:     assign     p-section-num = 6.   end.
            when 'image-list':U then do:     assign     p-section-num = 0.   end.
            when 'MercUnits':U then do:     assign     p-section-num = 0.   end.
            when 'weighed-gds':U then do:     assign     p-section-num = 1.   end.
            when 'IS18Plus':U then do:     assign     p-section-num = 4.   end.
            when 'loyalty-gift':U then do:     assign     p-section-num = 4.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'alcohol-prod':U then do:     assign     p-section-num = 7.   end.
            when 'egais-name':U then do:     assign     p-section-num = 0.   end.
            when 'ptrl-without-rvs':U then do:     assign     p-section-num = 6.   end.
            when 'office-type':U then do:     assign     p-section-num = 1.   end.
            when 'mark-type':U then do:     assign     p-section-num = 1.   end.
            when 'emrc-type':U then do:     assign     p-section-num = 1.   end.
            when 'item-matter-mark':U then do:     assign     p-section-num = 1.   end.
            when 'type-method-calc':U then do:     assign     p-section-num = 1.   end.
            when 'cash-book-id':U then do:     assign     p-section-num = 1.   end.
            when 'oper-serv-idd':U then do:     assign     p-section-num = 1.   end.
            when 'group-np':U then do:     assign     p-section-num = 6.   end.
            when 'is-loyalty-payment':U then do:     assign     p-section-num = 1.   end.
            when 'ban-bonus':U then do:     assign     p-section-num = 1.   end.
            when 'null-price':U then do:     assign     p-section-num = 1.   end.
            when 'fasovka':U then do:     assign     p-section-num = 1.   end.
                when 'time-coock':U then do:     assign     p-section-num = 1.   end.
            when 'mark':U then do:     assign     p-section-num = 7.   end.
            when 'sum-grp-gl':U then do:     assign     p-section-num = 1.   end.
            when 'mercur_FGIS':U then do:     assign     p-section-num = 1.   end.
            when 'perishable':U then do:     assign     p-section-num = 1.   end.
            when 'production-only':U then do:     assign     p-section-num = 1.   end.
            when 'calories':U then do:     assign     p-section-num = 2.   end.
            when 'protein':U then do:     assign     p-section-num = 2.   end.
            when 'fat':U then do:     assign     p-section-num = 2.   end.
            when 'carbohydrate':U then do:     assign     p-section-num = 2.   end.
            when 'calc-cal-rec':U then do:     assign     p-section-num = 2.   end.
            when 'cash-parts':U then do:     assign     p-section-num = 1.   end.
            when 'ptrl-as-good':U then do:     assign     p-section-num = 6.   end.
            when 'dflt-insalepr':U then do:     assign     p-section-num = 6.   end.
            when 'gds-ptrl-densities':U then do:     assign     p-section-num = 6.   end.
            when 'gds-CommodityCode':U then do:     assign     p-section-num = 1.   end.
            when 'gds-code-AIS':U then do:     assign     p-section-num = 6.   end.
            when 'length-of':U then do:     assign     p-section-num = 3.   end.
            when 'width-of':U then do:     assign     p-section-num = 3.   end.
            when 'height-of':U then do:     assign     p-section-num = 3.   end.
            when 'qnty-in-box':U then do:     assign     p-section-num = 4.   end.
            when 'weight-box':U then do:     assign     p-section-num = 4.   end.
            when 'qnty-on-pallet':U then do:     assign     p-section-num = 4.   end.
            when 'weight-of-pallet':U then do:     assign     p-section-num = 1.   end.
            when 'fuel-type':U then do:     assign     p-section-num = 6.   end.
            when 'image-list':U then do:     assign     p-section-num = 0.   end.
            when 'MercUnits':U then do:     assign     p-section-num = 0.   end.
            when 'weighed-gds':U then do:     assign     p-section-num = 1.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure bc-oattr_name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-range          as integer   no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'taracode-bc':U then do:     assign     p-label = "Код тары для сканер-весов NCR"     p-type = 'I':U      p-format = "99"     p-label = "Код тары для сканер-весов NCR"     p-range = 2     p-user-can-edit  = true     p-output-display = true     p-other = "spr=bc-oattr_taracode-bc":U      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут бар-кода &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure bc-oattr_tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'taracode-bc':U then do:     assign     p-tooltip = "Код тары для сканер-весов NCR"     p-label = "Код тары для сканер-весов NCR" .   end.
      otherwise do:
        undo, return error substitute("Неизвестный атрибут бар-кода &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure bc-oattr_value :
do
  on error undo, return error
  :
  define input  parameter p-b-code   as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-range          as integer   no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  run bc-oattr_name in this-procedure
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
  Find first  buf_bar-code-obj-attr no-lock where
              buf_bar-code-obj-attr.attr-code = p-code
          and buf_bar-code-obj-attr.obj-type = p-obj-type
          and buf_bar-code-obj-attr.obj-code = p-obj-code
          and  buf_bar-code-obj-attr.b-code  = p-b-code no-error .
  if avail buf_bar-code-obj-attr then do:
    assign
    p-value = buf_bar-code-obj-attr.attr-value.
  end.
  else do:
    assign
    p-value = if p-type = 'L':U then "no":U else "".
  end.
end.
end procedure.
procedure bc-oattr_write :
  do
  on error undo, return error
  :
    define input parameter p-b-code   like ub.bar-code-obj-attr.b-code   no-undo .
    define input parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer   no-undo .
    define input parameter p-value    like ub.bar-code-obj-attr.attr-value no-undo .
    define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr .
    define buffer buf_bar-code      for ub.bar-code.
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run bc-oattr_name in this-procedure
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
    find first buf_bar-code-obj-attr exclusive-lock where
              buf_bar-code-obj-attr.b-code  = p-b-code
          AND  buf_bar-code-obj-attr.attr-code = p-code
          and buf_bar-code-obj-attr.obj-type = p-obj-type
          and buf_bar-code-obj-attr.obj-code = p-obj-code
    no-error .
    if not available buf_bar-code-obj-attr then do:
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = p-b-code no-error.
      if not available buf_bar-code then do:
        undo, return error substitute("Не найден бар-код &1, для которого сохраняется атрибут &2"
                                                , p-b-code
                                                , p-code) .
      end.
      create buf_bar-code-obj-attr .
      assign
      buf_bar-code-obj-attr.b-code  = p-b-code
      buf_bar-code-obj-attr.attr-code = p-code + (if p-obj-type <> '' then  (chr(4) + p-obj-type + chr(4) + string(p-obj-code)) else '')
      buf_bar-code-obj-attr.attr-value = p-value
      buf_bar-code-obj-attr.gds-code = buf_bar-code.gds-code
      .
    end.
    ELSE
    assign
    buf_bar-code-obj-attr.attr-value = p-value no-error
    .
  end.
end procedure.
procedure bc-oattr_EXIST :
  do
  on error undo, return error
  :
    define input parameter p-b-code   like ub.bar-code-obj-attr.b-code   no-undo .
    define input parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer   no-undo .
    define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .
    define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run bc-oattr_name in this-procedure
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
    find first buf_bar-code-obj-attr no-lock where
              buf_bar-code-obj-attr.b-code  = p-b-code
          AND  buf_bar-code-obj-attr.attr-code = p-code
          and buf_bar-code-obj-attr.obj-type = p-obj-type
          and buf_bar-code-obj-attr.obj-code = p-obj-code
    no-error .
    if available buf_bar-code-obj-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure bc-oattr_DELETE :
  do
  on error undo, return error
  :
    define input parameter p-b-code   like ub.bar-code-obj-attr.b-code    no-undo .
    define input parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer   no-undo .
    define output parameter p-DELETED  AS LOGICAL no-undo .
    define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run bc-oattr_name in this-procedure
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
    find first buf_bar-code-obj-attr no-lock where
              buf_bar-code-obj-attr.b-code  = p-b-code
          AND  buf_bar-code-obj-attr.attr-code = p-code
          and buf_bar-code-obj-attr.obj-type = p-obj-type
          and buf_bar-code-obj-attr.obj-code = p-obj-code
    no-error .
    if not available buf_bar-code-obj-attr then do:
      p-DELETED = NO.
    end.
    ELSE DO:
       delete buf_bar-code-obj-attr.
      p-DELETED = YES.
    END.
  end.
end procedure.
procedure bc-oattr_manual-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'taracode-bc':U then do:     assign     p-section-num = 2.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут бар-кода &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure bc-oattr_batch-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'taracode-bc':U then do:     assign     p-section-num = 2.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут бар-кода &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure bc-oattr_taracode-bc :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-b-code like ub.bar-code-obj-attr.b-code no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE rid-list as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-obj-db-num as integer no-undo .
define variable par-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-new-value as character no-undo .
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer bc_units for ub.units.
  do
  on error undo, return error return-value
  :
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = p-b-code no-error.
    if not available buf_bar-code then do:
      message
      substitute("Не найден бар-код &1, для которого вводится атрибут!", p-b-code)
      view-as alert-box error.
      undo, return error.
    end.
    find first buf_goods no-lock where
              buf_goods.gds-code = buf_bar-code.gds-code no-error.
    if not available buf_goods then do:
      message
      substitute("Не найден товар &1, для бар-кода которого вводится атрибут!", buf_bar-code.gds-code)
      view-as alert-box error.
      undo, return error.
    end.
    find first buf_units no-lock where
              buf_units.unit-name = buf_goods.unit-base no-error.
    if not available buf_units then do:
      message
      substitute("Не найдена осн. ед.изм &1 товара &2, для бар-кода которого вводится атрибут!"
                  , buf_goods.unit-base
                 , buf_bar-code.gds-code)
      view-as alert-box error.
      undo, return error.
    end.
    find first bc_units no-lock where
              bc_units.unit-name = buf_bar-code.unit-cli no-error.
    if not available bc_units then do:
      message
      substitute("Не найдена изм &1 бар-кода &2, для которого вводится атрибут!"
                  , buf_bar-code.unit-cli
                 , buf_bar-code.b-code)
      view-as alert-box error.
      undo, return error.
    end.
    if not (LOOKUP( 'вес':U, buf_units.type ) > 0
    and (LOOKUP( 'дро':U, bc_units.type ) > 0
          or
          LOOKUP( 'вес':U, bc_units.type ) > 0)
          )
    then do:
      message
      substitute("Атрибут можно ввести только для весового или взвешиваемого бар-кода!"
                  , buf_bar-code.unit-cli
                 , buf_bar-code.b-code)
      view-as alert-box error.
      undo, return error.
    end.
    if buf_bar-code.unit-cli begins "№" then do:
      v-new-value = substring(buf_bar-code.unit-cli, 2).
    end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
    run adm/shattri.p (
      input "get":U
      ,input p-obj-type
      ,input p-obj-code
      ,input  'cd-sending':U
      ,input  "dflt-cd":U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    IF not error-status:error then
    assign
    dflt-cd = v-value-character .
    if v-new-value <> '' then do:
      find first buf_cash-desk-attr no-lock where
                buf_cash-desk-attr.obj-code = p-obj-code
          and buf_cash-desk-attr.cash-num = 0
          and buf_cash-desk-attr.pos-type = dflt-cd
          and buf_cash-desk-attr.attr-code = ('tara-ref':U  + chr(4) + v-new-value)
          and buf_cash-desk-attr.db-num  = v-obj-db-num  no-error .
      if available buf_cash-desk-attr then do:
        assign
        p-value = string(integer(entry(2, buf_cash-desk-attr.attr-code, chr(4)) ), "99")
        p-setted = yes
        .
        return.
      end.
    end.
    find first buf_cash-desk-attr no-lock where
              buf_cash-desk-attr.obj-code = p-obj-code
         and  buf_cash-desk-attr.cash-num = 0
         and  buf_cash-desk-attr.pos-type = dflt-cd
         and buf_cash-desk-attr.attr-code = ('tara-ref':U  + chr(4) + p-value)
         and buf_cash-desk-attr.db-num  = v-obj-db-num  no-error .
    if avail buf_cash-desk-attr then do:
      assign
      rid-list = string(recid(buf_cash-desk-attr))
      .
    end.
    run ref/ncrtarac.w ( input parparentproc
                    ,input ?
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input ?
                    ,input ?
                    ,input "b-sel"
                    ,input-output rid-list).
    if rid-list <> "":U then do:
      find first buf_cash-desk-attr no-lock where
                 recid(buf_cash-desk-attr) = integer(entry(1, rid-list)) no-error .
      if not avail buf_cash-desk-attr then return error.
      assign
      p-value = string(integer(entry(2, buf_cash-desk-attr.attr-code, chr(4)) ), "99")
      p-setted = yes
      .
    end.
    else p-setted = no.
  end.
end procedure.
procedure cd-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-ucode          as character no-undo .
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    define output parameter p-prop-list      as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-ucode :
            when 'MAGIA-XML_operative':U then do:     if p-code <> '' AND lookup(p-code, 'last-check-date-time':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Оперативные параметры"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'last-check-date-time':U ), 'Дата и время последнего принятого чека/док-та')))      p-format = (if p-code = ''                 then 'X(19)'                 else entry(lookup(p-code, 'last-check-date-time':U ), 'X(19)', "|"))     p-type   = (if p-code = '':U                  then   'character'                 else entry(lookup(p-code, 'last-check-date-time':U ), 'character'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'last-check-date-time':U ), 'true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'last-check-date-time':U ), 'true')))      p-other = 'spr=last-check-date-time'      p-prop-list = 'last-check-date-time':U      .   end.
            when 'IBM-XML_operative':U then do:     if p-code <> '' AND lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Оперативные параметры"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ), 'Параметры последнего принятого чека/док-та,Параметры последнего принятого кассового отчета,Версия кассовой программы,Версия ПО «Коннектор»,Признак исполнения кассы,ФФД версия,ККТ версия,Схема интеграции ККТ,Время последнего опроса касс,Дата последнего опроса касс,Быстрый ответ ГИСМТ,Таймаут ожидания,Таймаут ожидания проверки ГИСМТ,Таймаут  открытия соединения ГИСМТ')))      p-format = (if p-code = ''                 then 'X(19)|X(19)|X(255)|X(255)|9|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)'                 else entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ), 'X(19)|X(19)|X(255)|X(255)|9|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)', "|"))     p-type   = (if p-code = '':U                  then   'character,character,character,character,integer,character,character,character,character,character,character,character,character,character'                 else entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ), 'character,character,character,character,integer,character,character,character,character,character,character,character,character,character'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ), 'true,true,false,false,false,false,false,false,false,false,false,false,false,false')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ), 'true,true,true,true,true,true,true,true,true,true,true,true,true,true')))      p-other = 'spr=cd-attr-last-check-params,cd-attr-last-report-params,,'      p-prop-list = 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U      .   end.
            when 'IBM-XML_general':U then do:     if p-code <> '' AND lookup(p-code, 'use-kbo,easyfuel':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Общие настройки"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'use-kbo,easyfuel':U ), 'Использовать КБО,Работает с EasyFuel')))      p-format = (if p-code = ''                 then '+/|+/'                 else entry(lookup(p-code, 'use-kbo,easyfuel':U ), '+/|+/', "|"))     p-type   = (if p-code = '':U                  then   'logical,logical'                 else entry(lookup(p-code, 'use-kbo,easyfuel':U ), 'logical,logical'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'use-kbo,easyfuel':U ), 'true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'use-kbo,easyfuel':U ), 'true,true')))      p-other = '':U      p-prop-list = 'use-kbo,easyfuel':U      .   end.
            when 'AUTOTANK_operative':U then do:     if p-code <> '' AND lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Оперативные параметры"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ), 'Параметры последнего принятого чека/док-та,Параметры последнего принятого кассового отчета,Версия кассовой программы,Версия ПО «Коннектор»,Признак исполнения кассы')))      p-format = (if p-code = ''                 then 'X(19)|X(19)|X(255)|X(255)|X(9)'                 else entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ), 'X(19)|X(19)|X(255)|X(255)|X(9)', "|"))     p-type   = (if p-code = '':U                  then   'character,character,character,character,integer'                 else entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ), 'character,character,character,character,integer'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ), 'true,true,false,false,false')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ), 'true,true,true,true,true')))      p-other = 'spr=cd-attr-last-check-params,cd-attr-last-report-params,'      p-prop-list = 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U      .   end.
            when 'MARIA_operative':U then do:     if p-code <> '' AND lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Оперативные параметры"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ), 'Параметры последнего принятого чека,Актуальность данных кассы MARIA,Текущее количество товаров на кассе,Максимальный plu на кассе в данный момент,Признак на кассе есть товары не отправленные на кассу,Текущее количество нефтепродуктов на кассе,Максимальное значение plu топлива из содержащихся на кассе в данный момент,Признак на кассе есть топлива не отправленные на кассу,Текущее количество клиентов на кассе,Максимальное значение clu из содержащихся на кассе в данный момент,Признак на кассе есть клиентов не отправленные на кассу')))      p-format = (if p-code = ''                 then 'X(19)|X(19)|>>>>9|>>>>9|+/|9|9|+/|>>9|>>9|+/'                 else entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ), 'X(19)|X(19)|>>>>9|>>>>9|+/|9|9|+/|>>9|>>9|+/', "|"))     p-type   = (if p-code = '':U                  then   'character,character,integer,integer,logical,integer,integer,logical,integer,integer,logical'                 else entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ), 'character,character,integer,integer,logical,integer,integer,logical,integer,integer,logical'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ), 'true,false,false,false,false,false,false,false,false,false,false')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ), 'true,false,false,false,false,false,false,false,false,false,false')))      p-other = 'spr=cd-attr-last-check-maria,,,,,,,,,':U      p-prop-list = 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U      .   end.
            when 'MARIA_general':U then do:     if p-code <> '' AND lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Общие параметры"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ), 'Максимальное количество товаров на кассе,Начало диапазона plu для топлив на кассе,Размер диапазона plu для топлив на кассе,Максимальное количество клиентов на кассе')))      p-format = (if p-code = ''                 then '>>>>9|>>>>9|9|>>9'                 else entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ), '>>>>9|>>>>9|9|>>9', "|"))     p-type   = (if p-code = '':U                  then   'integer,integer,integer,integer'                 else entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ), 'integer,integer,integer,integer'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ), 'true,true,true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ), 'true,true,true,true')))      p-other = 'check=cd-attr_check-marketer,cd-attr_check-marketer,cd-attr_check-marketer,cd-attr_check-marketer':U      p-prop-list = 'max-gds,petrolium-start,petrolium-range,max-cli':U      .   end.
            when 'INFOKIOSK_operative':U then do:     if p-code <> '' AND lookup(p-code, 'last-grp-change,last-prt-change':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Оперативные параметры"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'last-grp-change,last-prt-change':U ), 'Последнее изменение справочника групп товаров,Последнее изменение справочника шкал')))      p-format = (if p-code = ''                 then 'X(32)|X(32)'                 else entry(lookup(p-code, 'last-grp-change,last-prt-change':U ), 'X(32)|X(32)', "|"))     p-type   = (if p-code = '':U                  then   'character,character'                 else entry(lookup(p-code, 'last-grp-change,last-prt-change':U ), 'character,character'))      p-user-can-edit  = (if p-code = '':U                          then  false                         else logical(entry(lookup(p-code, 'last-grp-change,last-prt-change':U ), 'false,false')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'last-grp-change,last-prt-change':U ), 'true,true')))      p-other = '':U      p-prop-list = 'last-grp-change,last-prt-change':U      .   end.
            when 'NCR-GM_general':U then do:     if p-code <> '' AND lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Общие параметры"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'Сообщение на кассе при превышении порогового значения суммы чека,Соответствие кодов тары весам тары для сканер-весов NCR')))      p-format = (if p-code = ''                 then '>>>>9.99|>>>>9.99'                 else entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), '>>>>9.99|>>>>9.99', "|"))     p-type   = (if p-code = '':U                  then   'decimal,character'                 else entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'decimal,character'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'true,true')))      p-other = 'copy=,yes/auto=,2/send=,yes/compl-root=,yes/spr=,cd-attr-spr-tara-ref/display=,cd-attr-di-tara-ref':U      p-prop-list = 'message-by-lim-sum-check,tara-ref':U      .   end.
            when 'NCR-AS-R_general':U then do:     if p-code <> '' AND lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Общие параметры"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'Сообщение на кассе при превышении порогового значения суммы чека,Соответствие кодов тары весам тары для сканер-весов NCR')))      p-format = (if p-code = ''                 then '>>>>9.99|>>>>9.99'                 else entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), '>>>>9.99|>>>>9.99', "|"))     p-type   = (if p-code = '':U                  then   'decimal,character'                 else entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'decimal,character'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'true,true')))      p-other = 'copy=yes/auto=2/send=yes/compl-root=yes/spr=cd-attr-spr-tara-ref/display=cd-attr-di-tara-ref':U      p-prop-list = 'message-by-lim-sum-check,tara-ref':U      .   end.
            when 'IBS-TH_main':U then do:     if p-code <> '' AND lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Основные настройки"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ), 'Работа со сменами,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Обязателен продавец,Разрешена ручная скидка,Уровень логирования,Обнулять счетчик наличности при Z-отчете,Разрешена коррекция кол-ва')))      p-format = (if p-code = ''                 then '9|>>9|9|9|9|9|9'                 else entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ), '9|>>9|9|9|9|9|9', "|"))     p-type   = (if p-code = '':U                  then   'integer,integer,integer,integer,integer,integer,integer'                 else entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ), 'integer,integer,integer,integer,integer,integer,integer'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ), 'true,true,true,true,true,true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ), 'true,true,true,true,true,true,true')))      p-other = 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U      p-prop-list = 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U      .   end.
            when 'IBS-TH_devices':U then do:     if p-code <> '' AND lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Работа с устройствами"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ), 'Подключать ДЯ,Тип подключения ДЯ,Порт подключения ДЯ,Кол-во имп. подключения ДЯ,Работа с открытым ДЯ,Предел наличности ДЯ,Подключать кардридер,Подключать дисплей покупателя,Текст рекламы на дисплее покупателя,Тип клавиатуры,Раскладка клавиатуры,Система безналичных платежей,Тип дисплея покупателя,Порт дисплея покупателя,Тип системы видеонаблюдения,Адрес/порт системы видеонаблюдения')))      p-format = (if p-code = ''                 then '9|9|9|>>9|9|9|>>>,>>>,>>9.99|9|X(40)|X(20)|X(15)|X(12)|X(15)|X(5)|X(10)|X(16)'                 else entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ), '9|9|9|>>9|9|9|>>>,>>>,>>9.99|9|X(40)|X(20)|X(15)|X(12)|X(15)|X(5)|X(10)|X(16)', "|"))     p-type   = (if p-code = '':U                  then   'integer,integer,integer,integer,integer,decimal,integer,integer,character,character,character,character,character,character'                 else entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ), 'integer,integer,integer,integer,integer,decimal,integer,integer,character,character,character,character,character,character'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ), 'true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ), 'true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true')))      p-other = 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U      p-prop-list = 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U      .   end.
            when 'IBS-TH_fisreg':U then do:     if p-code <> '' AND lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Настройки для ФР"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ), 'Логический уровень датчика ДЯ в открытом состоянии,Типы кассовых платежей<->коды оплаты ФР,Наименования типов оплат ФР,Отрезание чеков,ФР подключен к')))      p-format = (if p-code = ''                 then '>>>|X(255)|X(122)|9|X(4)|'                 else entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ), '>>>|X(255)|X(122)|9|X(4)|', "|"))     p-type   = (if p-code = '':U                  then   'integer,character,character,integer,character'                 else entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ), 'integer,character,character,integer,character'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ), 'true,true,true,true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ), 'true,true,true,true,true')))      p-other = 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U      p-prop-list = 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U      .   end.
            when 'IBS-TH_rec-print':U then do:     if p-code <> '' AND lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Настройки чеков"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'Макс.сумма чека,Рекламный текст,Строки клише,Печатать код товара,Тип округления суммы чека,Коэфф. типа округления суммы чека,Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере')))      p-format = (if p-code = ''                 then '>>>,>>>,>>9.99|X(120)|X(220)|9|X(8)|->>9.99|9|9'                 else entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ), '>>>,>>>,>>9.99|X(120)|X(220)|9|X(8)|->>9.99|9|9', "|"))     p-type   = (if p-code = '':U                  then   'decimal,character,character,integer,character,decimal,integer,integer'                 else entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'decimal,character,character,integer,character,decimal,integer,integer'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'true,true,true,true,true,true,true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'true,true,true,true,true,true,true,true')))      p-other = 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U      p-prop-list = 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U      .   end.
            when 'IBS-TH_interface':U then do:     if p-code <> '' AND lookup(p-code, 'screen-type,screen-layout-id':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Настройки интерфейса"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'screen-type,screen-layout-id':U ), 'Тип интерфейса,Раскладка')))      p-format = (if p-code = ''                 then 'X(120)|X(15)'                 else entry(lookup(p-code, 'screen-type,screen-layout-id':U ), 'X(120)|X(15)', "|"))     p-type   = (if p-code = '':U                  then   'character,character'                 else entry(lookup(p-code, 'screen-type,screen-layout-id':U ), 'character,character'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'screen-type,screen-layout-id':U ), 'true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'screen-type,screen-layout-id':U ), 'true,true')))      p-other = 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U      p-prop-list = 'screen-type,screen-layout-id':U      .   end.
            when 'IBS-TH-MOB_main':U then do:     if p-code <> '' AND lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Основные настройки"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ), ',Обязателен продавец,Тип POS, с которого брать скидки')))      p-format = (if p-code = ''                 then '9|X(40)'                 else entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ), '9|X(40)', "|"))     p-type   = (if p-code = '':U                  then   'integer,character'                 else entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ), 'integer,character'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ), 'true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ), 'true,true')))      p-other = 'sprlevel=cd/spr=ref\cda-31.w/display=ref\cda-31.w':U      p-prop-list = 'salesman-mandatory,pos-type-for-discnt':U      .   end.
            when 'IBS-TH-MOB_rec-print':U then do:     if p-code <> '' AND lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-label = "Настройки чеков"     p-label  = p-label +                (if p-code = '':U                  then   ''                 else (":" + entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ), ',Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере')))      p-format = (if p-code = ''                 then '9|9'                 else entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ), '9|9', "|"))     p-type   = (if p-code = '':U                  then   'integer,integer'                 else entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'integer,integer'))      p-user-can-edit  = (if p-code = '':U                          then  true                         else logical(entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'true,true')))      p-output-display = (if p-code = '':U                         then true                        else logical(entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'true,true')))      p-other = 'sprlevel=cd/spr=ref\cda-31.w/display=ref\cda-31.w':U      p-prop-list = 'rcpt-ord-slip-print,rcpt-ord-alt-print':U      .   end.
      otherwise do:
        undo, return error substitute("неизвестная секция настроек кассы &1", p-ucode ).
      end.
    end.
    return ''.
  end.
end procedure.
procedure cd-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-ucode    as character no-undo .
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
   if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-ucode :
            when 'MAGIA-XML_operative':U then do:     assign     p-tooltip = "Оперативные параметры POS MAGIA-XML"     p-label = "Оперативные параметры"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'last-check-date-time':U ), 'Дата и время последнего принятого чека/док-та')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'last-check-date-time':U ),''))) no-error.   end.
            when 'IBM-XML_operative':U then do:     assign     p-tooltip = "Оперативные параметры POS IBM-XML"     p-label = "Оперативные параметры"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ), 'Параметры последнего принятого чека/док-та,Параметры последнего принятого кассового отчета,Версия кассовой программы,Версия ПО «Коннектор»,Признак исполнения кассы,ФФД версия,ККТ версия,Схема интеграции ККТ,Время последнего опроса касс,Дата последнего опроса касс,Быстрый ответ ГИСМТ,Таймаут ожидания,Таймаут ожидания проверки ГИСМТ,Таймаут  открытия соединения ГИСМТ')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ),''))) no-error.   end.
            when 'IBM-XML_general':U then do:     assign     p-tooltip = "Общие настройки POS IBM-XML"     p-label = "Общие настройки"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'use-kbo,easyfuel':U ), 'Использовать КБО,Работает с EasyFuel')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'use-kbo,easyfuel':U ),''))) no-error.   end.
            when 'AUTOTANK_operative':U then do:     assign     p-tooltip = "Оперативные параметры POS AUTOTANK"     p-label = "Оперативные параметры"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ), 'Параметры последнего принятого чека/док-та,Параметры последнего принятого кассового отчета,Версия кассовой программы,Версия ПО «Коннектор»,Признак исполнения кассы')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ),''))) no-error.   end.
            when 'MARIA_operative':U then do:     assign     p-tooltip = "Оперативные параметры POS MARIA"     p-label = "Оперативные параметры"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ), 'Параметры последнего принятого чека,Актуальность данных кассы MARIA,Текущее количество товаров на кассе,Максимальный plu на кассе в данный момент,Признак на кассе есть товары не отправленные на кассу,Текущее количество нефтепродуктов на кассе,Максимальное значение plu топлива из содержащихся на кассе в данный момент,Признак на кассе есть топлива не отправленные на кассу,Текущее количество клиентов на кассе,Максимальное значение clu из содержащихся на кассе в данный момент,Признак на кассе есть клиентов не отправленные на кассу')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ),''))) no-error.   end.
            when 'MARIA_general':U then do:     assign     p-tooltip = "Общие параметры POS MARIA"     p-label = "Общие параметры"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ), 'Максимальное количество товаров на кассе,Начало диапазона plu для топлив на кассе,Размер диапазона plu для топлив на кассе,Максимальное количество клиентов на кассе')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ),''))) no-error.   end.
            when 'INFOKIOSK_operative':U then do:     assign     p-tooltip = "Оперативные параметры INFOKIOSK"     p-label = "Оперативные параметры"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'last-grp-change,last-prt-change':U ), 'Последнее изменение справочника групп товаров,Последнее изменение справочника шкал')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'last-grp-change,last-prt-change':U ),''))) no-error.   end.
            when 'NCR-GM_general':U then do:     assign     p-tooltip = "Общие параметры POS NCR-GM"     p-label = "Общие параметры"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'Сообщение на кассе при превышении порогового значения суммы чека,Соответствие кодов тары весам тары для сканер-весов NCR')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),''))) no-error.   end.
            when 'NCR-AS-R_general':U then do:     assign     p-tooltip = "Общие параметры POS NCR-AS-R"     p-label = "Общие параметры"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), 'Сообщение на кассе при превышении порогового значения суммы чека,Соответствие кодов тары весам тары для сканер-весов NCR')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),''))) no-error.   end.
            when 'IBS-TH_main':U then do:     assign     p-tooltip = "Основные настройки POS IBS-TH"     p-label = "Основные настройки"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ), 'Работа со сменами,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1),Обязателен продавец,Разрешена ручная скидка,Уровень логирования,Обнулять счетчик наличности при Z-отчете,Разрешена коррекция кол-ва')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ),''))) no-error.   end.
            when 'IBS-TH_devices':U then do:     assign     p-tooltip = "Работа с устройствами POS IBS-TH"     p-label = "Работа с устройствами"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ), 'Подключать ДЯ,Тип подключения ДЯ,Порт подключения ДЯ,Кол-во имп. подключения ДЯ,Работа с открытым ДЯ,Предел наличности ДЯ,Подключать кардридер,Подключать дисплей покупателя,Текст рекламы на дисплее покупателя,Тип клавиатуры,Раскладка клавиатуры,Система безналичных платежей,Тип дисплея покупателя,Порт дисплея покупателя,Тип системы видеонаблюдения,Адрес/порт системы видеонаблюдения')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ),''))) no-error.   end.
            when 'IBS-TH_fisreg':U then do:     assign     p-tooltip = "Настройки POS IBS-TH для фискального регистратора"     p-label = "Настройки для ФР"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ), 'Логический уровень датчика ДЯ в открытом состоянии,Типы кассовых платежей<->коды оплаты ФР,Наименования типов оплат ФР,Отрезание чеков,ФР подключен к')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ),''))) no-error.   end.
            when 'IBS-TH_rec-print':U then do:     assign     p-tooltip = "Настройки POS IBS-TH для чеков"     p-label = "Настройки чеков"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ), 'Макс.сумма чека,Рекламный текст,Строки клише,Печатать код товара,Тип округления суммы чека,Коэфф. типа округления суммы чека,Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ),''))) no-error.   end.
            when 'IBS-TH_interface':U then do:     assign     p-tooltip = "Настройки POS IBS-TH для интерфейса"     p-label = "Настройки интерфейса"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'screen-type,screen-layout-id':U ), 'Тип интерфейса,Раскладка')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'screen-type,screen-layout-id':U ),''))) no-error.   end.
            when 'IBS-TH-MOB_main':U then do:     assign     p-tooltip = "Основные настройки POS IBS-TH-MOB"     p-label = "Основные настройки"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ), ',Обязателен продавец,Тип POS, с которого брать скидки')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ),''))) no-error.   end.
            when 'IBS-TH-MOB_rec-print':U then do:     assign     p-tooltip = "Настройки POS IBS-TH-MOB для чеков"     p-label = "Настройки чеков"     p-label = p-label +     (if p-code = '':U then '':U else (":" + entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ), ',Печатать слип отлож.чека,Печатать отлож.чек на доп.принтере')))     p-tooltip =     (if p-code = '':U then '':U      else (entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ),''))) no-error.   end.
      otherwise do:
        undo, return error substitute("неизвестная секция настроек кассы &1", p-ucode ).
      end.
    end.
    return ''.
  end.
end procedure.
procedure cd-attr-value :
  do
  on error undo, return error
  :
    define input  parameter p-db-num   like ub.cash-desk-attr.db-num        no-undo .
    define input  parameter p-obj-code like ub.cash-desk-attr.obj-code      no-undo .
    define input  parameter p-pos-type like ub.cash-desk-attr.pos-type      no-undo .
    define input  parameter p-cash-num like ub.cash-desk-attr.cash-num      no-undo .
    define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code       no-undo .
    define input  parameter p-code     like ub.cash-desk-attr.attr-code      no-undo .
    define output parameter p-character like ub.cash-desk-attr.attr-value-character  no-undo .
    define output parameter p-date      like ub.cash-desk-attr.attr-value-date       no-undo .
    define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal    no-undo .
    define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer    no-undo .
    define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical    no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_cash-desk-attr for ub.cash-desk-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list      as character no-undo .
    define variable v-ucode as character no-undo .
    define variable v-code as character no-undo .
    assign
    v-ucode = p-ucode
    v-code = p-code
    .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    run cd-attr-code in this-procedure
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-desk-attr no-lock
      where buf_cash-desk-attr.db-num    = p-db-num
        and buf_cash-desk-attr.obj-code  = p-obj-code
        and buf_cash-desk-attr.pos-type  = p-pos-type
        and buf_cash-desk-attr.cash-num  = p-cash-num
        and buf_cash-desk-attr.upper-attr-code = v-ucode
        and buf_cash-desk-attr.attr-code = v-code
      no-error .
    if avail buf_cash-desk-attr then do:
      assign
        p-character =  buf_cash-desk-attr.attr-value-character
        p-date      =  buf_cash-desk-attr.attr-value-date
        p-decimal   =  buf_cash-desk-attr.attr-value-decimal
        p-integer   =  buf_cash-desk-attr.attr-value-integer
        p-logical   =  buf_cash-desk-attr.attr-value-logical
        p-type      =  buf_cash-desk-attr.attr-value-type.
      .
    end.
  end.
end procedure.
procedure cd-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
    define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
    define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
    define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
    define input parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
    define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
    define input parameter p-character like ub.cash-desk-attr.attr-value-character  no-undo .
    define input parameter p-date      like ub.cash-desk-attr.attr-value-date       no-undo .
    define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal    no-undo .
    define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer    no-undo .
    define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical    no-undo .
    define buffer buf_cash-desk-attr for ub.cash-desk-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-dop            as character no-undo .
    define variable v-prop-value-list as character no-undo .
    define variable v-prop-list      as character no-undo .
    define variable v-ucode as character no-undo .
    define variable v-code as character no-undo .
    assign
    v-ucode = p-ucode
    v-code = p-code
    .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    run cd-attr-code in this-procedure
      (input  p-ucode
      ,input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-desk-attr exclusive-lock
      where buf_cash-desk-attr.db-num  = p-db-num
        and buf_cash-desk-attr.obj-code  = p-obj-code
        and buf_cash-desk-attr.pos-type  = p-pos-type
        and buf_cash-desk-attr.cash-num  = p-cash-num
        and buf_cash-desk-attr.upper-attr-code = v-ucode
        and buf_cash-desk-attr.attr-code = v-code
      no-error .
    if not available buf_cash-desk-attr then do:
      create buf_cash-desk-attr .
      assign
      buf_cash-desk-attr.db-num    = p-db-num
      buf_cash-desk-attr.obj-code  = p-obj-code
      buf_cash-desk-attr.pos-type  = p-pos-type
      buf_cash-desk-attr.cash-num  = p-cash-num
      buf_cash-desk-attr.upper-attr-code = v-ucode
      buf_cash-desk-attr.attr-code = v-code
      buf_cash-desk-attr.attr-value-type = v-type
      .
    end.
    CASE buf_cash-desk-attr.attr-value-type:
      when 'character':U then do:
        assign
        buf_cash-desk-attr.attr-value-character = p-character
        .
      end.
      when 'date':U then do:
        assign
        buf_cash-desk-attr.attr-value-date = p-date
        .
      end.
      when 'decimal':U then do:
        assign
        buf_cash-desk-attr.attr-value-decimal = p-decimal
        .
      end.
      when 'integer':U then do:
        assign
        buf_cash-desk-attr.attr-value-integer = p-integer
      .
    end.
      when 'logical':U then do:
    assign
        buf_cash-desk-attr.attr-value-logical = p-logical
    .
      end.
    end case.
    release buf_cash-desk-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
    define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
    define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
    define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
    define input parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
    define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_cash-desk-attr for ub.cash-desk-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list      as character no-undo .
    define variable v-ucode as character no-undo .
    define variable v-code as character no-undo .
    assign
    v-ucode = p-ucode
    v-code = p-code
    .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    run cd-attr-code in this-procedure
      (input  p-ucode
      ,input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-desk-attr exclusive-lock
      where buf_cash-desk-attr.db-num  = p-db-num
        and buf_cash-desk-attr.obj-code  = p-obj-code
        and buf_cash-desk-attr.pos-type  = p-pos-type
        and buf_cash-desk-attr.cash-num  = p-cash-num
        and buf_cash-desk-attr.upper-attr-code = v-ucode
        and buf_cash-desk-attr.attr-code = v-code
      no-error .
    if  available buf_cash-desk-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure cd-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
    define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
    define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
    define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
    define input parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
    define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_cash-desk-attr for ub.cash-desk-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list      as character no-undo .
    define variable v-ucode as character no-undo .
    define variable v-code as character no-undo .
    assign
    v-ucode = p-ucode
    v-code = p-code
    .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    run cd-attr-code in this-procedure
      (input  p-ucode
      ,input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-desk-attr exclusive-lock
      where buf_cash-desk-attr.db-num  = p-db-num
        and buf_cash-desk-attr.obj-code  = p-obj-code
        and buf_cash-desk-attr.pos-type  = p-pos-type
        and buf_cash-desk-attr.cash-num  = p-cash-num
        and buf_cash-desk-attr.upper-attr-code = v-ucode
        and buf_cash-desk-attr.attr-code = v-code
      no-error NO-WAIT.
    if not available buf_cash-desk-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-desk-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure cd-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-ucode          as character no-undo .
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    define output parameter p-from-gbd       as logical   no-undo .
    define output parameter p-from-ubd       as logical   no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-ucode :
            when 'MAGIA-XML_operative':U then do:     if lookup(p-code, 'last-check-date-time':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'last-check-date-time':U ),'false' ))     p-from-gbd = logical(entry(lookup(p-code, 'last-check-date-time':U ),'false' ))     p-from-ubd = logical(entry(lookup(p-code, 'last-check-date-time':U ),'true' ))     no-error.   end.
            when 'IBM-XML_operative':U then do:     if lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ),'false,false,true,true,true,true,true,true,true,true,true,true,true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ),'false,false,false,false,false,false,false,false,false,false,false,false,false,false' ))     p-from-ubd = logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ),'true,true,true,true,true,true,true,true,true,true,true,true,true,true' ))     no-error.   end.
            when 'IBM-XML_general':U then do:     if lookup(p-code, 'use-kbo,easyfuel':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'use-kbo,easyfuel':U ),'true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'use-kbo,easyfuel':U ),'true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'use-kbo,easyfuel':U ),'true,true' ))     no-error.   end.
            when 'AUTOTANK_operative':U then do:     if lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ),'false,false,true,true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ),'false,false,false,false,false' ))     p-from-ubd = logical(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ),'true,true,true,true,true' ))     no-error.   end.
            when 'MARIA_operative':U then do:     if lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ),'false,false,false,false,false,false,false,false,false,false' ))     p-from-gbd = logical(entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ),'false,false,false,false,false,false,false,false,false,false,false' ))     p-from-ubd = logical(entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ),'true,true,true,true,true,true,true,true,true,true,true' ))     no-error.   end.
            when 'MARIA_general':U then do:     if lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ),'true,true,true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ),'false,false,false,false' ))     p-from-ubd = logical(entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ),'true,true,true,true' ))     no-error.   end.
            when 'INFOKIOSK_operative':U then do:     if lookup(p-code, 'last-grp-change,last-prt-change':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'last-grp-change,last-prt-change':U ),'true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'last-grp-change,last-prt-change':U ),'false,false' ))     p-from-ubd = logical(entry(lookup(p-code, 'last-grp-change,last-prt-change':U ),'true,true' ))     no-error.   end.
            when 'NCR-GM_general':U then do:     if lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     no-error.   end.
            when 'NCR-AS-R_general':U then do:     if lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     no-error.   end.
            when 'IBS-TH_main':U then do:     if lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ),'true,true,true,true,true,true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ),'true,true,true,true,true,true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ),'true,true,true,true,true,true,true' ))     no-error.   end.
            when 'IBS-TH_devices':U then do:     if lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ),'true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ),'true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ),'true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true' ))     no-error.   end.
            when 'IBS-TH_fisreg':U then do:     if lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ),'true,true,true,true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ),'true,true,true,true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ),'true,true,true,true,true' ))     no-error.   end.
            when 'IBS-TH_rec-print':U then do:     if lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'true,true,true,true,true,true,true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'true,true,true,true,true,true,true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'true,true,true,true,true,true,true,true' ))     no-error.   end.
            when 'IBS-TH_interface':U then do:     if lookup(p-code, 'screen-type,screen-layout-id':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'screen-type,screen-layout-id':U ),'true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'screen-type,screen-layout-id':U ),'true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'screen-type,screen-layout-id':U ),'true,true' ))     no-error.   end.
            when 'IBS-TH-MOB_main':U then do:     if lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ),'true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ),'true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ),'true,true' ))     no-error.   end.
            when 'IBS-TH-MOB_rec-print':U then do:     if lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-news = logical(entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'true,true' ))     p-from-gbd = logical(entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'true,true' ))     p-from-ubd = logical(entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'true,true' ))     no-error.   end.
      otherwise do:
        p-news = no.
        p-from-ubd = yes.
      end.
    end.
    return ''.
  end.
end procedure.
procedure cd-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-ucode          as character no-undo .
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-ucode :
            when 'MAGIA-XML_operative':U then do:     if p-code <> '' AND lookup(p-code, 'last-check-date-time':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'last-check-date-time':U ),'false' ))     no-error.   end.
            when 'IBM-XML_general':U then do:     if p-code <> '' AND lookup(p-code, 'use-kbo,easyfuel':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'use-kbo,easyfuel':U ),'true,true' ))     no-error.   end.
            when 'MARIA_operative':U then do:     if p-code <> '' AND lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ),'false,false,false,false,false,false,false,false,false,false,false' ))     no-error.   end.
            when 'MARIA_general':U then do:     if p-code <> '' AND lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ),'true,true,true,true' ))     no-error.   end.
            when 'INFOKIOSK_operative':U then do:     if p-code <> '' AND lookup(p-code, 'last-grp-change,last-prt-change':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'last-grp-change,last-prt-change':U ),'true,true' ))     no-error.   end.
            when 'NCR-GM_general':U then do:     if p-code <> '' AND lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     no-error.   end.
            when 'NCR-AS-R_general':U then do:     if p-code <> '' AND lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     no-error.   end.
            when 'IBS-TH_main':U then do:     if p-code <> '' AND lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ),'true,true,true,true,true,true,true' ))     no-error.   end.
            when 'IBS-TH_devices':U then do:     if p-code <> '' AND lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ),'true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true' ))     no-error.   end.
            when 'IBS-TH_fisreg':U then do:     if p-code <> '' AND lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ),'true,true,true,true,true' ))     no-error.   end.
            when 'IBS-TH_rec-print':U then do:     if p-code <> '' AND lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'true,true,true,true,true,true,true,true' ))     no-error.   end.
            when 'IBS-TH_interface':U then do:     if p-code <> '' AND lookup(p-code, 'screen-type,screen-layout-id':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'screen-type,screen-layout-id':U ),'true,true' ))     no-error.   end.
            when 'IBS-TH-MOB_main':U then do:     if p-code <> '' AND lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ),'true,true' ))     no-error.   end.
            when 'IBS-TH-MOB_rec-print':U then do:     if p-code <> '' AND lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-hist = logical(entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'true,true' ))     no-error.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
    return ''.
  end.
end procedure.
procedure cd-attr-parse-date-time-proc :
  define input  parameter p-string       as character no-undo .
  define output parameter p-time         as integer   no-undo .
  define output parameter p-return-value as date      no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-date as date.
    define variable v-shift as integer no-undo .
    if index(p-string, "-":U) = 0
    or NOT (length(p-string) = 10
            or
            length(p-string) = 19)
    then do:
      return error.
    end.
    assign
      v-date =  date(
              int( substr( p-string, 6, 2 ) ) ,
              int( substr( p-string, 9, 2 ) ),
              int( substr( p-string, 1, 4 ) )
                )
    no-error .
    if error-status:error
    then do:
      return error.
    end.
    if index(p-string, ":":U) = 0
    or not (
            length(p-string) = 19
            or
            length(p-string) = 8
            )
    then do:
      return error.
    end.
    if length(p-string) = 19 then v-shift = 11.
    assign
    p-time =  int( substr( p-string, v-shift + 1, 2 ) ) * 3600 +
              int( substr( p-string, v-shift + 4, 2 ) ) * 60  +
              int( substr( p-string, v-shift + 7, 2) )
    no-error .
    if error-status:error then do:
      return error.
    end.
    assign
      p-return-value = v-date
    .
  end.
end procedure.
procedure last-check-date-time :
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-value as character no-undo .
  define variable v-codes as character no-undo .
  define variable v-labels as character no-undo .
  define variable v-date as date no-undo .
  define variable v-time as integer no-undo .
  define variable v-date2 as date no-undo .
  define variable v-time2 as integer no-undo .
  define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
      v-value = p-character
    .
    run cd-attr-parse-date-time-proc in this-procedure
      (input  v-value
      ,output v-time
      ,output v-date
      ) no-error .
    run gbl/d-time.w (
                    input "Введите дату и время последнего полученного чека по данной кассе"
                   ,input ?
                   ,input 1
                   ,input-output v-date
                   ,input-output v-date2
                   ,input-output v-time
                   ,input-output v-time2
                   ,output v-ok
                   ) no-error .
    assign
    v-value = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +
             chr(32)  +  string(v-time, "HH:MM:SS":U).
    if
    v-ok and
    p-character <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-character = v-value
      .
    end.
  end.
end procedure.
procedure cd-attr-cd-datetostring-proc :
  define input  parameter p-date         as date      no-undo .
  define output parameter p-return-value as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-return-value = string(YEAR(p-date), "9999":U) + "-":U +
                       string(Month(p-date), "99":U) + "-":U +
                       string(DAY(p-date), "99":U)
    .
  end.
end procedure.
procedure cd-attr-last-report-params :
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-value as character no-undo .
  define variable v-codes as character no-undo .
  define variable v-labels as character no-undo .
  define variable v-date as date no-undo .
  define variable v-time as integer no-undo .
  define variable v-date2 as date no-undo .
  define variable v-time2 as integer no-undo .
  define variable v-shift-num as integer no-undo .
  define variable v-shift-num2 as integer no-undo .
  define variable v-z-count as integer no-undo .
  define variable v-z-count2 as integer no-undo .
  define variable v-chk-num as integer no-undo .
  define variable v-chk-num2 as integer no-undo .
  define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-character
    v-shift-num = (if num-entries(v-value, chr(32)) > 2
                   then integer(entry(3, v-value, chr(32)  ))
                   else 0)
    .
    run cd-attr-parse-date-time-proc in this-procedure
      (input  substring(v-value, 1 , 19)
      ,output v-time
      ,output v-date
      ) no-error .
    run str/lastchkd.w (
                    input "Введите параметры последнего полученного отчета по данной кассе"
                   ,input ?
                   ,input 1
                   ,input "report"
                   ,input-output v-date
                   ,input-output v-date2
                   ,input-output v-time
                   ,input-output v-time2
                   ,input-output v-shift-num
                   ,input-output v-shift-num2
                   ,input-output v-z-count
                   ,input-output v-z-count2
                   ,input-output v-chk-num
                   ,input-output v-chk-num2
                   ,output v-ok
                   )  .
    assign
    v-value = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +
             chr(32)  +  string(v-time, "HH:MM:SS":U) +
             chr(32) + string(v-shift-num)
             .
    if v-ok and
    p-character <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-character = v-value
      .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-value as character no-undo .
  define variable v-codes as character no-undo .
  define variable v-labels as character no-undo .
  define variable v-date as date no-undo .
  define variable v-time as integer no-undo .
  define variable v-date2 as date no-undo .
  define variable v-time2 as integer no-undo .
  define variable v-shift-num as integer no-undo .
  define variable v-shift-num2 as integer no-undo .
  define variable v-z-count as integer no-undo .
  define variable v-z-count2 as integer no-undo .
  define variable v-chk-num as integer no-undo .
  define variable v-chk-num2 as integer no-undo .
  define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-character
    v-shift-num = (if num-entries(v-value, chr(32)) > 2
                   then integer(entry(3, v-value, chr(32)  ))
                   else 0)
    v-z-count =  (if num-entries(v-value, chr(32)) > 3
                  then integer(entry(4, v-value, chr(32) ))
                  else 0)
    v-chk-num = (if num-entries(v-value, chr(32)) > 4
                 then integer(entry(5, v-value, chr(32)))
                 else  0)
    .
    run cd-attr-parse-date-time-proc in this-procedure
      (input  substring(v-value, 1 , 19)
      ,output v-time
      ,output v-date
      ) no-error .
    run str/lastchkd.w (
                    input "Введите параметры последнего полученного чека по данной кассе"
                   ,input ?
                   ,input 1
                   ,input ""
                   ,input-output v-date
                   ,input-output v-date2
                   ,input-output v-time
                   ,input-output v-time2
                   ,input-output v-shift-num
                   ,input-output v-shift-num2
                   ,input-output v-z-count
                   ,input-output v-z-count2
                   ,input-output v-chk-num
                   ,input-output v-chk-num2
                   ,output v-ok
                   ) no-error .
    assign
    v-value = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +
             chr(32)  +  string(v-time, "HH:MM:SS":U) +
             chr(32) + string(v-shift-num) +
             chr(32) + string(v-z-count) +
             chr(32) + string(v-chk-num)
             .
    if v-ok and
    p-character <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-character = v-value
      .
    end.
  end.
end procedure.
procedure cd-attr-last-check-maria :
define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-date as date no-undo .
define variable v-p-date as date no-undo .
define variable v-num-recs as decimal no-undo .
define variable v-p-num-recs as integer no-undo .
define variable v-z-count as integer no-undo .
define variable v-p-z-count as integer no-undo .
define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value
    v-date =  (if num-entries(entry(1, v-value, chr(32)), '-') > 1
              then  date( integer(entry(2, entry(1, v-value, chr(32)), '-':U))
                   ,integer(entry(3, entry(1, v-value, chr(32)), '-':U))
                   ,integer(entry(1, entry(1, v-value, chr(32)), '-':U))
                   )
                   else 01/01/1990)
    v-z-count =  (if num-entries(v-value, chr(32)) > 1
                  then integer(entry(2, v-value, chr(32) ))
                  else 0)
    v-num-recs =  (if num-entries(v-value, chr(32)) > 2
                  then decimal(entry(3, v-value, chr(32) ))
                  else 0)
    v-p-date =  (if num-entries(v-value, chr(32)) > 3
                then  date( integer(entry(2, entry(4, v-value, chr(32)), '-':U))
                            ,integer(entry(3, entry(4, v-value, chr(32)), '-':U))
                            ,integer(entry(1, entry(4, v-value, chr(32)), '-':U))
                            )
                else 01/01/1990)
    v-p-z-count =  (if num-entries(v-value, chr(32)) > 4
                  then integer(entry(5, v-value, chr(32) ))
                  else 0)
    v-p-num-recs =  (if num-entries(v-value, chr(32)) > 5
                  then integer(entry(6, v-value, chr(32) ))
                  else 0)
    .
    run ref/lastchkm.w (
                    input "Введите параметры последнего полученного чека по данной кассе"
                   ,input-output v-date
                   ,input-output v-z-count
                   ,input-output v-num-recs
                   ,input-output v-p-date
                   ,input-output v-p-z-count
                   ,input-output v-p-num-recs
                   ,output v-ok
                   ) no-error .
    assign
    v-value = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +  chr(32) +
             string(v-z-count) + chr(32) +
             string(v-num-recs) + chr(32) +
             string(YEAR(v-p-date), "9999":U) + "-":U +
             string(Month(v-p-date), "99":U) + "-":U +
             string(DAY(v-p-date), "99":U) + chr(32) +
             string(v-p-z-count) + chr(32) +
             string(v-p-num-recs)
             .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  define variable v-value as character no-undo .
  define variable v-ok as logical no-undo .
  define variable v-obj-list as character no-undo .
  define variable v-params as character no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value
    v-obj-list = entry(1, v-value , chr(32) )
    v-params = if num-entries(v-value, chr(32)) > 1 then entry(2, v-value , chr(32) ) else '':U
    .
    run ref/mariatsk.w (
                         input-output v-obj-list
                        ,input-output v-params
                        ,output v-ok
                        ) no-error .
    v-value = v-obj-list + chr(32) + v-params.
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure cd-attr_get-attr-int-proc :
  define parameter buffer buf_cash-desk  for ub.cash-desk .
  define input  parameter p-upper-attr-code    as character no-undo .
  define input  parameter p-attr-code    as character no-undo .
  define output parameter p-mes          as character no-undo .
  define output parameter p-return-value as integer   no-undo .
  define variable par-type as character no-undo .
  define variable v-character as character no-undo .
  define variable v-date as date no-undo .
  define variable v-decimal as decimal no-undo .
  define variable v-integer as integer no-undo .
  define variable v-logical as integer no-undo .
  do
  on error undo, return error return-value
  :
    run cd-attr-value in this-procedure
      (input   buf_cash-desk.db-num
      ,input  buf_cash-desk.obj-code
      ,input  buf_cash-desk.pos-type
      ,input  buf_cash-desk.cash-num
      ,input  p-upper-attr-code
      ,input  p-attr-code
      ,output v-character
      ,output v-date
      ,output v-decimal
      ,output v-integer
      ,output v-logical
      ,output par-type
      ) no-error .
    if error-status :error
    then do:
      assign
        p-mes = substitute("Не удалось получить значение атрибута &7 для кассы &1 &2&3:&4&5 &6"
                          ,buf_cash-desk.cash-num
                          , 'маг':U
                          ,buf_cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                          , p-attr-code
                          )
        p-return-value = ?
      .
      return .
    end.
    assign
    p-return-value = v-integer
    .
  end.
end procedure.
procedure cd-attr_get-attr-log-proc :
  define parameter buffer buf_cash-desk  for ub.cash-desk .
  define input  parameter p-upper-attr-code    as character no-undo .
  define input  parameter p-attr-code    as character no-undo .
  define output parameter p-mes          as character no-undo .
  define output parameter p-return-value as logical   no-undo .
  define variable v-character as character no-undo .
  define variable v-date as date no-undo .
  define variable v-decimal as decimal no-undo .
  define variable v-integer as integer no-undo .
  define variable v-logical as logical no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
    run cd-attr-value IN THIS-PROCEDURE
      (input  buf_cash-desk.db-num
      ,input  buf_cash-desk.obj-code
      ,input  buf_cash-desk.pos-type
      ,input  buf_cash-desk.cash-num
      ,input  p-upper-attr-code
      ,input  p-attr-code
      ,output v-character
      ,output v-date
      ,output v-decimal
      ,output v-integer
      ,output v-logical
      ,output par-type
      ) no-error .
    if error-status :error
    then do:
      assign
        p-mes = substitute("Не удалось получить значение атрибута &7 для кассы &1 &2&3:&4&5 &6"
                          ,buf_cash-desk.cash-num
                          , 'маг':U
                          ,buf_cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                          , p-attr-code
                          )
        p-return-value = ?
      .
      return.
    end.
    assign
      p-return-value = v-logical
    .
  end.
end procedure.
procedure cd-attr_check-marketer :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define input parameter p-upper-code  like ub.cash-desk-attr.upper-attr-code  no-undo .
define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
define input parameter p-character as character no-undo .
define input parameter p-date      as date      no-undo .
define input parameter p-decimal   as decimal   no-undo .
define input parameter p-integer   as integer   no-undo .
define input parameter p-logical   as logical   no-undo .
define input parameter p-mode  as character no-undo .
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
define variable v-int as integer no-undo .
  do
  on error undo, return error
  :
    if p-mode = 'удаление':U then do:
      assign
      p-correct = yes.
      return.
    end.
    if p-pos-type <> 'MARIA':U
    then do:
      return.
    end.
    assign
    v-int = integer(p-character)
    no-error .
    if error-status:error then do:
      return substitute("&1 &2", error-status:get-message(1) , return-value ).
    end.
    assign
    p-correct = yes.
  end.
end procedure.
procedure cd-attr-spr-tara-ref :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-character as character no-undo .
define input-output parameter p-date      as date      no-undo .
define input-output parameter p-decimal   as decimal   no-undo .
define input-output parameter p-integer   as integer   no-undo .
define input-output parameter p-logical   as logical   no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-attr-code as character no-undo .
define variable v-upper-attr-code as character no-undo .
define variable v-rid-list as character no-undo .
define buffer buf_cash-desk-attr for ub.cash-desk-attr .
  do
  on error undo, return error return-value
  :
   case p-pos-type:
     when  'NCR-GM':U then do:
      assign
      v-upper-attr-code = 'NCR-GM_general':U
      v-attr-code = 'tara-ref':U
      .
     end.
     when  'NCR-AS@R':U then do:
      assign
      v-upper-attr-code = 'NCR-AS-R_general':U
      v-attr-code = 'tara-ref':U
      .
     end.
   end case.
   find first buf_cash-desk-attr no-lock where
             buf_cash-desk-attr.db-num = p-db-num
         and buf_cash-desk-attr.obj-code = p-obj-code
         and buf_cash-desk-attr.cash-num = p-cash-num
         and buf_cash-desk-attr.pos-type = p-pos-type
         and buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
         and buf_cash-desk-attr.attr-code = (v-attr-code + chr(4) + "0":U) no-error.
   if available buf_Cash-desk-attr then do:
      assign
      v-value = p-character
      .
   end.
    run ref/ncrtarac.w (
                     input parparentproc
                   , input p-db-num
                   , input 'маг':U
                   , input p-obj-code
                   , input p-pos-type
                   , input p-cash-num
                   , input "b-add"
                   , input-output v-rid-list ) no-error.
   find first buf_cash-desk-attr no-lock where
             buf_cash-desk-attr.db-num = p-db-num
         and buf_cash-desk-attr.obj-code = p-obj-code
         and buf_cash-desk-attr.cash-num = p-cash-num
         and buf_cash-desk-attr.pos-type = p-pos-type
         and buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
         and buf_cash-desk-attr.attr-code = v-attr-code  no-error.
   if available buf_Cash-desk-attr then
   assign
   v-value = buf_cash-desk-attr.attr-value-character.
   if p-character <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-character = v-value
      .
    end.
  end.
end procedure.
procedure cd-attr-di-tara-ref :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input parameter p-ucode like ub.cash-desk-attr.upper-attr-code no-undo .
define input parameter p-attr-code like ub.cash-desk-attr.attr-code no-undo .
define input parameter p-character as character no-undo .
define input parameter p-date      as date      no-undo .
define input parameter p-decimal   as decimal   no-undo .
define input parameter p-integer   as integer   no-undo .
define input parameter p-logical   as logical   no-undo .
define variable v-rid-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/ncrtarac.w (
                     INPUT parparentproc
                   , input p-db-num
                   , input 'маг':U
                   , input p-obj-code
                   , input p-pos-type
                   , input p-cash-num
                   , input ""
                   , input-output v-rid-list ) no-error.
  end.
end procedure.
procedure cd-attr-manual-edit :
do
  on error undo, return error
  :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-ucode :
            when 'MAGIA-XML_operative':U then do:   if p-code <> '' AND lookup(p-code, 'last-check-date-time':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'last-check-date-time':U ), '1')). end.
            when 'IBM-XML_operative':U then do:   if p-code <> '' AND lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT':U ), '1,1,0,0,0,0,0,0,0,0,0,0,0,0')). end.
            when 'IBM-XML_general':U then do:   if p-code <> '' AND lookup(p-code, 'use-kbo,easyfuel':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'use-kbo,easyfuel':U ), '2,2')). end.
            when 'AUTOTANK_operative':U then do:   if p-code <> '' AND lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'last-check-params,last-report-params,fo-version,OptVer,device-kind':U ), '1,1,0,0,0,')). end.
            when 'MARIA_operative':U then do:   if p-code <> '' AND lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send':U ), '1,0,0,0,0,0,0,0,0,0')). end.
            when 'MARIA_general':U then do:   if p-code <> '' AND lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'max-gds,petrolium-start,petrolium-range,max-cli':U ), '2,2,2,2')). end.
            when 'NCR-GM_general':U then do:   if p-code <> '' AND lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), '1,1')). end.
            when 'NCR-AS-R_general':U then do:   if p-code <> '' AND lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ), '1,1')). end.
            when 'IBS-TH_main':U then do:   if p-code <> '' AND lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ), '1,1,1,1,1,1,1')). end.
            when 'IBS-TH_devices':U then do:   if p-code <> '' AND lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ), '2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2')). end.
            when 'IBS-TH_fisreg':U then do:   if p-code <> '' AND lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ), '3,3,3,3,3')). end.
            when 'IBS-TH_rec-print':U then do:   if p-code <> '' AND lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ), '4,4,4,4,4,4,4,4')). end.
            when 'IBS-TH_interface':U then do:   if p-code <> '' AND lookup(p-code, 'screen-type,screen-layout-id':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'screen-type,screen-layout-id':U ), '5,5')). end.
            when 'IBS-TH-MOB_main':U then do:   if p-code <> '' AND lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ), '1,1')). end.
            when 'IBS-TH-MOB_rec-print':U then do:   if p-code <> '' AND lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).   assign   p-section-num = integer(entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ), '2,2')). end.
      otherwise do:
      end.
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
do
  on error undo, return error
  :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-ucode :
      otherwise do:
      end.
    end.
  end.
end procedure.
procedure cd-attr-send-param :
do
  on error undo, return error
  :
  define input  parameter p-ucode         as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-ucode = entry(1, p-ucode, chr(4)).
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
                  when 'NCR-GM_general':U then do:     if lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     no-error.   end.
                  when 'NCR-AS-R_general':U then do:     if lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     no-error.   end.
                  when 'NCR-GM_general':U then do:     if lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     no-error.   end.
                  when 'NCR-AS-R_general':U then do:     if lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'message-by-lim-sum-check,tara-ref':U ),'true,true' ))     no-error.   end.
                  when 'IBM-XML_general':U then do:     if lookup(p-code, 'use-kbo,easyfuel':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'use-kbo,easyfuel':U ),'true,true' ))     no-error.   end.
            when 'IBS-TH_main':U then do:     if lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change':U ),'false,false,false,false,false,false,false' ))     no-error.   end.
            when 'IBS-TH_devices':U then do:     if lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address':U ),'false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false' ))     no-error.   end.
            when 'IBS-TH_fisreg':U then do:     if lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'cash-drawer-level,cash-pay-list,pay-names,cutter,com-port':U ),'false,false,false,false,false' ))     no-error.   end.
            when 'IBS-TH_rec-print':U then do:     if lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'false,false,false,false,false,false,false,false' ))     no-error.   end.
            when 'IBS-TH_interface':U then do:     if lookup(p-code, 'screen-type,screen-layout-id':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'screen-type,screen-layout-id':U ),'false,false' ))     no-error.   end.
            when 'IBS-TH-MOB_main':U then do:     if lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'salesman-mandatory,pos-type-for-discnt':U ),'false,false' ))     no-error.   end.
            when 'IBS-TH-MOB_rec-print':U then do:     if lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ).     assign     p-send-param = logical(entry(lookup(p-code, 'rcpt-ord-slip-print,rcpt-ord-alt-print':U ),'false,false' ))     no-error.   end.
      otherwise do:
      end.
    end.
  end.
end procedure.
procedure gdshattr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'no-envd':U then do:     assign     p-label = "Не попадает под действие ЕНВД"     p-type = 'L':U      p-format = "+/ "     p-label = "Не попадает под действие ЕНВД"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gdshattr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'no-envd':U then do:     assign     p-tooltip = "Не попадает под действие системы налогообложения ЕНВД, установленной на фирме"     p-label = "Не попадает под действие ЕНВД" .   end.
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара на фирме &1",  p-code) .
      end.
    end.
  end.
end procedure.
procedure gdshattr-value :
do
  on error undo, return error
  :
  define input  parameter p-code as character no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as int no-undo .
  define input  parameter p-gds-code as int no-undo .
  define output parameter p-value as character no-undo .
  define output parameter p-type     as character no-undo .
  define buffer buf-gds-host-attr for ub.gds-host-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  define var attr-host-code as int no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output attr-host-code
  ) no-error .
 .
    run gdshattr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-gds-host-attr no-lock where
                buf-gds-host-attr.host-code = attr-host-code and
                buf-gds-host-attr.attr-code = p-code and
                buf-gds-host-attr.gds-code  = p-gds-code no-error .
   if avail buf-gds-host-attr then do:
    assign
    p-value = buf-gds-host-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = 'L':U then "no":U else "".
   end.
end.
end procedure.
procedure gdshattr-h-value :
do
  on error undo, return error
  :
  define input  parameter p-code as character no-undo .
  define input  parameter p-host-code as integer no-undo .
  define input  parameter p-gds-code as int no-undo .
  define output parameter p-value as character no-undo .
  define output parameter p-type     as character no-undo .
  define buffer buf-gds-host-attr for ub.gds-host-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  define var attr-host-code as int no-undo .
     run gdshattr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-gds-host-attr no-lock where
                buf-gds-host-attr.host-code = p-host-code and
                buf-gds-host-attr.attr-code = p-code and
                buf-gds-host-attr.gds-code  = p-gds-code no-error .
   if avail buf-gds-host-attr then do:
    assign
    p-value = buf-gds-host-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = 'L':U then "no":U else "".
   end.
end.
end procedure.
procedure gdshattr-write :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.clients.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients.obj-code   no-undo .
    define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-host-attr.attr-value no-undo .
    define buffer buf_gds-host-attr for ub.gds-host-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define var attr-host-code as int no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output attr-host-code
  ) no-error .
 .
    run gdshattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-host-attr exclusive-lock where
               buf_gds-host-attr.gds-code  = p-gds-code AND
               buf_gds-host-attr.host-code  = attr-host-code AND
               buf_gds-host-attr.attr-code = p-code no-error .
    if not available buf_gds-host-attr then do:
      create buf_gds-host-attr .
      assign
        buf_gds-host-attr.gds-code  = p-gds-code
        buf_gds-host-attr.host-code  = attr-host-code
        buf_gds-host-attr.attr-code = p-code
        buf_gds-host-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    assign
    buf_gds-host-attr.attr-value = p-value no-error
    .
  end.
end procedure.
procedure gdshattr-EXIST :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.clients.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients.obj-code   no-undo .
    define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
    define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .
    define buffer buf_gds-host-attr for ub.gds-host-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define var attr-host-code as int no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output attr-host-code
  ) no-error .
 .
    run gdshattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-host-attr NO-lock where
               buf_gds-host-attr.gds-code  = p-gds-code AND
               buf_gds-host-attr.host-code  = attr-host-code AND
               buf_gds-host-attr.attr-code = p-code no-error .
    if available buf_gds-host-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure gdshattr-DELETE :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.clients.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients.obj-code   no-undo .
    define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
    define output parameter p-DELETED  AS LOGICAL no-undo .
    define buffer buf_gds-host-attr for ub.gds-host-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define var attr-host-code as int no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output attr-host-code
  ) no-error .
 .
    run gdshattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-host-attr exclusive-lock where
               buf_gds-host-attr.gds-code  = p-gds-code AND
               buf_gds-host-attr.host-code  = attr-host-code AND
               buf_gds-host-attr.attr-code = p-code no-error .
    if not available buf_gds-host-attr then do:
      p-DELETED = NO.
    end.
    ELSE DO:
       delete buf_gds-host-attr.
      p-DELETED = YES.
    END.
  end.
end procedure.
procedure gdshattr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'no-envd':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure gdshattr-copy :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-copy           as logical   no-undo .
    case p-code :
            when 'no-envd':U then do:     assign     p-copy = true.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure gdshattr-manual-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'no-envd':U then do:     assign     p-section-num = 1.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure gdshattr-batch-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'no-envd':U then do:     assign     p-section-num = 1.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure gdsoattr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'lock':U then do:     assign     p-label = "Блокировка атрибутов на изменение"     p-type = 'L':U      p-format = "yes/no"     p-label = "Блокировка атрибутов на изменение"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'scales-code':U then do:     assign     p-label = "Код для весов на объекте"     p-type = 'I':U      p-format = "99999"     p-label = "Код для весов на объекте"     p-user-can-edit  = false     p-output-display = true     p-other = ""      .   end.
            when 'free-price':U then do:     assign     p-label = "Товар со свободной ценой на кассе"     p-type = 'L':U      p-format = "+/ "     p-label = "Товар со свободной ценой на кассе"     p-user-can-edit  = true     p-output-display = true     p-other = "cd=gds"      .   end.
            when 'sum-grp':U then do:     assign     p-label = "Группа товаров на кассе"     p-type = 'I':U      p-format = "999"     p-label = "Группа товаров на кассе"     p-user-can-edit  = true     p-output-display = true     p-other = "spr=gds-obj-sum-grps/cd=gds"      .   end.
            when 'increase-pc':U then do:     assign     p-label = "Наценка"     p-type = 'D':U      p-format = "99999.99"     p-label = "Наценка"     p-user-can-edit  = true     p-output-display = true     p-other = "init=gds-obj-init-increase-pc"      .   end.
            when 'min-zapas':U then do:     assign     p-label = "Минимальный запас"     p-type = 'D':U      p-format = ">>>>>>>>>9"     p-label = "Минимальный запас"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'round-method':U then do:     assign     p-label = "Метод округления "     p-type = 'C':U      p-format = "X(21)"     p-label = "Метод округления "     p-user-can-edit  = true     p-output-display = true     p-other = "spr=gds-obj-round-method"      .   end.
            when 'petrol-purse':U then do:     assign     p-label = "Топливный кошелек (IBM-POS)"     p-type = 'L':U      p-format = "+/-"     p-label = "Топливный кошелек (IBM-POS)"     p-user-can-edit  = true     p-output-display = true     p-other = "cd=gds"      .   end.
            when 'need-auth':U then do:     assign     p-label = "Требует авторизации на кассе (IBM-XML)"     p-type = 'L':U      p-format = "+/-"     p-label = "Требует авторизации на кассе (IBM-XML)"     p-user-can-edit  = true     p-output-display = true     p-other = "cd=gds"      .   end.
            when 'gds-margins':U then do:     assign     p-label = "Диапазоны торговой наценки"     p-type = 'C':U      p-format = "X(21)"     p-label = "Диапазоны торговой наценки"     p-user-can-edit  = true     p-output-display = true     p-other = "spr=gds-obj-gds-margins"      .   end.
            when 'proprietor':U then do:     assign     p-label = "Принадлежность товара объекту"     p-type = 'L':U      p-format = "+/-"     p-label = "Принадлежность товара объекту"     p-user-can-edit  = true     p-output-display = true     p-other = "check-ext=ref\gopropri.p"      .   end.
            when 'fbr-cost-rubl':U then do:     assign     p-label = "Оценочная учетная цена ингредиента"     p-type = 'D':U      p-format = ">>>>>>>>>9.999"     p-label = "Оценочная учетная цена ингредиента"     p-user-can-edit  = true     p-output-display = true     p-other = "":U      .   end.
            when 'no-income-goods':U then do:     assign     p-label = "Запрещен внешний приход и заказ объект-поставщик по товару на объекте"     p-type = 'L':U      p-format = "+/ "     p-label = "Запрещен внешний приход и заказ объект-поставщик по товару на объекте"     p-user-can-edit  = false     p-output-display = false     p-other = "":U      .   end.
            when 'taracode':U then do:     assign     p-label = "Код тары для сканер-весов NCR"     p-type = 'I':U      p-format = "99"     p-label = "Код тары для сканер-весов NCR"     p-user-can-edit  = true     p-output-display = true     p-other = "spr=gds-obj-taracode":U      .   end.
            when 'calories-o':U then do:     assign     p-label = "Энерг.ценность ккал на 100г"     p-type = 'D':U      p-format = ">,>>9.9"     p-label = "Энерг.ценность ккал на 100г"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'protein-o':U then do:     assign     p-label = "Белки г на 100г"     p-type = 'D':U      p-format = ">9.9"     p-label = "Белки г на 100г"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'fat-o':U then do:     assign     p-label = "Жиры г на 100г"     p-type = 'D':U      p-format = ">9.9"     p-label = "Жиры г на 100г"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'carbohydrate-o':U then do:     assign     p-label = "Углеводы г на 100г"     p-type = 'D':U      p-format = ">9.9"     p-label = "Углеводы г на 100г"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'doc-tickets':U then do:     assign     p-label = "Количество ценников"     p-type = 'C':U      p-format = "X(21)"     p-label = "Количество ценников"     p-user-can-edit  = true     p-output-display = true     p-other = "spr=gds-obj-doc-tickets"      .   end.
            when 'normal-wastage-o':U then do:     assign     p-label = "Нормы естественной убыли для топлива кг/т"     p-type = 'C':U      p-format = "X(21)"     p-label = "Нормы естественной убыли для топлива кг/т"     p-user-can-edit  = true     p-output-display = true     p-other = "spr=gds-obj-normal-wastage"      .   end.
            when 'dop-alt-name-o':U then do:     assign     p-label = "Дополнение к названию товара"     p-type = 'C':U      p-format = "X(40)"     p-label = "Дополнение к названию товара"     p-user-can-edit  = true     p-output-display = true     p-other = "spr=gds-obj-dop-alt-name"      .   end.
            when 'dt-seasons':U then do:     assign     p-label = "Сезон ДТ"     p-type = 'C':U      p-format = "X(50)"     p-label = "Сезон ДТ"     p-user-can-edit  = true     p-output-display = true     p-other = "spr=gds-obj-dt-seasons/cd=IBM-XML/send2kassa=promoAction"      .   end.
            when 'change-dt-seasons':U then do:     assign     p-label = "дата/время изменения сезон"     p-type = 'C':U      p-format = "X(50)"     p-label = "дата/время изменения сезон"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'mark-collect-type':U then do:     assign     p-label = "Тип сбора марок"     p-type = 'I':U      p-format = "9"     p-label = "Тип сбора марок"     p-user-can-edit  = false     p-output-display = true     p-other = ""      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gdsoattr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'scales-code':U then do:     assign     p-tooltip = "Код для весов, который будет отослан на весы для данного товара на данном объекте"     p-label = "Код для весов на объекте" .   end.
            when 'free-price':U then do:     assign     p-tooltip = "Кассир вручную вводит цену товара на кассе (IBM-POS, IBS TH POS)"     p-label = "Товар со свободной ценой на кассе" .   end.
            when 'sum-grp':U then do:     assign     p-tooltip = "Номер группы товаров на кассе (IBM-POS, IBS TH POS)"     p-label = "Группа товаров на кассе" .   end.
            when 'increase-pc':U then do:     assign     p-tooltip = "Наценка на объекте"     p-label = "Наценка" .   end.
            when 'min-zapas':U then do:     assign     p-tooltip = "Минимальный запас на объекте"     p-label = "Минимальный запас" .   end.
            when 'round-method':U then do:     assign     p-tooltip = "Метод округления цены при расчете переоценки"     p-label = "Метод округления " .   end.
            when 'petrol-purse':U then do:     assign     p-tooltip = "Товар оплачивается топливным кошельком смарт карты (IBM-POS)"     p-label = "Топливный кошелек (IBM-POS)" .   end.
            when 'need-auth':U then do:     assign     p-tooltip = "Товар требует авторизации на кассе (IBM-XML)"     p-label = "Требует авторизации на кассе (IBM-XML)" .   end.
            when 'gds-margins':U then do:     assign     p-tooltip = "Диапазоны торговой наценки при расчете переоценки"     p-label = "Диапазоны торговой наценки" .   end.
            when 'proprietor':U then do:     assign     p-tooltip = "Принадлежность товара объекту в пределах одной ТПСИ"     p-label = "Принадлежность товара объекту" .   end.
            when 'fbr-cost-rubl':U then do:     assign     p-tooltip = "Оценочная учетная цена ингредиента для калькуляционной карточки"     p-label = "Оценочная учетная цена ингредиента" .   end.
            when 'no-income-goods':U then do:     assign     p-tooltip = "Запрещен внешний приход и заказ объект-поставщик по товару на объекте"     p-label = "Запрещен внешний приход и заказ объект-поставщик по товару на объекте" .   end.
            when 'taracode':U then do:     assign     p-tooltip = "Код тары для сканер-весов NCR"     p-label = "Код тары для сканер-весов NCR" .   end.
            when 'calories-o':U then do:     assign     p-tooltip = "Энерг.ценность ккал на 100г"     p-label = "Энерг.ценность ккал на 100г" .   end.
            when 'protein-o':U then do:     assign     p-tooltip = "Белки г на 100г"     p-label = "Белки г на 100г" .   end.
            when 'fat-o':U then do:     assign     p-tooltip = "Жиры г на 100г"     p-label = "Жиры г на 100г" .   end.
            when 'carbohydrate-o':U then do:     assign     p-tooltip = "Углеводы г на 100г"     p-label = "Углеводы г на 100г" .   end.
            when 'doc-tickets':U then do:     assign     p-tooltip = "Способ задания количества ценников при печати из документа"     p-label = "Количество ценников" .   end.
            when 'normal-wastage-o':U then do:     assign     p-tooltip = "Нормы естественной убыли для топлива кг/т"     p-label = "Нормы естественной убыли для топлива кг/т" .   end.
            when 'dop-alt-name-o':U then do:     assign     p-tooltip = "Дополнение к названию товара"     p-label = "Дополнение к названию товара" .   end.
            when 'dt-seasons':U then do:     assign     p-tooltip = "Сезон ДТ"     p-label = "Сезон ДТ" .   end.
            when 'change-dt-seasons':U then do:     assign     p-tooltip = "дата/время изменения сезон"     p-label = "дата/время изменения сезон" .   end.
            when 'mark-collect-type':U then do:     assign     p-tooltip = "Тип сбора марок"     p-label = "Тип сбора марок" .   end.
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gdsoattr-value :
 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gdsoattr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-obj-attr no-lock where
               buf_gds-obj-attr.gds-code  = p-gds-code AND
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code = p-code
      no-error .
    if avail buf_gds-obj-attr then do:
      assign
        p-value =  buf_gds-obj-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure gdsoattr-gds-code :
 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    find first buf_gds-obj-attr no-lock where
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code  = p-code AND
               buf_gds-obj-attr.attr-value = p-value
      no-error .
    if avail buf_gds-obj-attr then
      p-gds-code =  buf_gds-obj-attr.gds-code.
  end.
end procedure.
procedure gdsoattr-write :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define buffer lock_gds-obj-attr for ub.gds-obj-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gdsoattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-obj-attr exclusive-lock where
               buf_gds-obj-attr.gds-code  = p-gds-code AND
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code = p-code no-error .
    if not available buf_gds-obj-attr then do:
      create buf_gds-obj-attr .
      assign
        buf_gds-obj-attr.gds-code  = p-gds-code
        buf_gds-obj-attr.obj-type  = p-obj-type
        buf_gds-obj-attr.obj-code  = p-obj-code
        buf_gds-obj-attr.attr-code = p-code
        buf_gds-obj-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_gds-obj-attr.attr-value = p-value no-error.
  end.
end procedure.
procedure gdsoattr-exist :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .
    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gdsoattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-obj-attr no-lock where
               buf_gds-obj-attr.gds-code  = p-gds-code AND
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code = p-code no-error .
    if available buf_gds-obj-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure gdsoattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gdsoattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-obj-attr exclusive-lock where
               buf_gds-obj-attr.gds-code  = p-gds-code AND
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code = p-code no-error .
    if not available buf_gds-obj-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_gds-obj-attr.
       P-DELETED = YES.
    END.
  end.
end procedure.
procedure gds-obj-gds-margins :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/gdsprmar.w (
                    input p-gds-code
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input-output v-value) no-error .
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure gds-obj-normal-wastage :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/gdswastage.w (
                    input p-gds-code
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input-output v-value) no-error .
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure gds-obj-doc-tickets :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/dctiattr.w (
                    input p-gds-code
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input-output v-value) no-error .
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure gds-obj-dop-alt-name :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/dopaltn.w (
                    input p-gds-code
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input-output v-value) no-error .
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure gds-attr-margin-value :
do
on error undo, return error
:
define input parameter p-gds-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-min-value as decimal      no-undo init ?.
define output parameter p-max-value as decimal      no-undo init ?.
define output parameter p-increase-pc as decimal      no-undo init ?.
define output parameter p-rmethod as character no-undo init "":U.
define output parameter p-base as decimal no-undo init ?.
define output parameter p-range-margin     as integer      no-undo.
define output parameter p-exists-margin    as logical no-undo.
define output parameter p-range-increase     as integer      no-undo.
define output parameter p-exists-increase  as logical no-undo.
define output parameter p-range-rmethod     as integer no-undo .
define output parameter p-exists-rmethod   as logical no-undo .
define variable v-nume as integer no-undo .
DEFINE VARIABLE v-min-value as decimal      no-undo.
DEFINE VARIABLE v-max-value as decimal      no-undo.
DEFINE VARIABLE v-increase-pc as decimal      no-undo.
define variable v-rmethod as character no-undo .
define variable v-base as decimal no-undo .
define variable v-exists-margin as logical no-undo .
define variable v-exists-increase as logical no-undo .
define variable v-exists-rmethod as logical no-undo .
define variable v-mes as character no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_margins-gds-obj-attr      for ub.gds-obj-attr.
define buffer buf_increase-gds-obj-attr      for ub.gds-obj-attr.
define buffer buf_round-gds-obj-attr      for ub.gds-obj-attr.
find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code no-error .
if not avail buf_goods then do:
  message
    skip "Не удалось найти товар с кодом" p-gds-code
    view-as alert-box error .
  undo, return error .
end.
find first buf_margins-gds-obj-attr no-lock
    where buf_margins-gds-obj-attr.gds-code = p-gds-code
      and buf_margins-gds-obj-attr.attr-code = 'gds-margins':U
      and buf_margins-gds-obj-attr.obj-type  = p-obj-type
      and buf_margins-gds-obj-attr.obj-code  = p-obj-code
no-error .
if available buf_margins-gds-obj-attr then do:
  assign
  v-min-value   =  decimal(trim(entry(1, buf_margins-gds-obj-attr.attr-value, "-":U), "%":U))
  v-max-value   =  decimal(trim(entry(2, buf_margins-gds-obj-attr.attr-value, "-":U), "%":U))
  v-exists-margin = v-min-value <> ? and v-max-value <> ?
  .
end.
find first buf_increase-gds-obj-attr no-lock
    where buf_increase-gds-obj-attr.gds-code = p-gds-code
      and buf_increase-gds-obj-attr.attr-code = 'increase-pc':U
      and buf_increase-gds-obj-attr.obj-type  = p-obj-type
      and buf_increase-gds-obj-attr.obj-code  = p-obj-code
no-error .
if available buf_increase-gds-obj-attr then do:
  assign
  v-increase-pc = decimal(buf_increase-gds-obj-attr.attr-value)
  v-exists-increase = yes
  .
end.
find first buf_round-gds-obj-attr no-lock
    where buf_round-gds-obj-attr.gds-code = p-gds-code
      and buf_round-gds-obj-attr.attr-code = 'round-method':U
      and buf_round-gds-obj-attr.obj-type  = p-obj-type
      and buf_round-gds-obj-attr.obj-code  = p-obj-code
no-error .
if available buf_round-gds-obj-attr then do:
  assign
  v-rmethod =  entry(1, buf_round-gds-obj-attr.attr-value, chr(32))
  v-nume    = num-entries(buf_round-gds-obj-attr.attr-value, chr(32))
  v-base     = (if v-nume >= 2 and entry(v-nume, buf_round-gds-obj-attr.attr-value, chr(32)) <> "":U
                then decimal (entry(v-nume, buf_round-gds-obj-attr.attr-value, chr(32)))
                else 0
                    )
  v-exists-rmethod = yes
  no-error.
  if error-status :error   or (LOOKUP(p-rmethod, '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U) = 0 and p-rmethod <> "":U)
  then do:
    assign
    v-mes = "Ошибка при чтении метода округления" + chr(10) +
           return-value + chr(10) +
           trim(error-status :get-message(1)) + chr(10) +
           trim(error-status :get-message(2)) + chr(10) +
           trim(error-status :get-message(3)) + chr(10) +
           trim(error-status :get-message(4)) + chr(10) +
           trim(error-status :get-message(5)).
    return error v-mes.
  end.
end.
if not (v-exists-margin and v-exists-increase and v-exists-rmethod) then do:
  run grp-obj-margin-value  in this-procedure (
 input  buf_goods.grp-code
,input  p-obj-type
,input  p-obj-code
,output p-min-value
,output p-max-value
,output p-increase-pc
,output p-rmethod
,output p-base
,output p-range-margin
,output p-exists-margin
,output p-range-increase
,output p-exists-increase
,output p-range-rmethod
,output p-exists-rmethod ) no-error .
if error-status:error then do:
    assign
    v-mes = substitute("Ошибка при чтении параметров переоценки из группы для товара &1", p-gds-code) + chr(10) +
           return-value + chr(10) +
           trim(error-status :get-message(1)) + chr(10) +
           trim(error-status :get-message(2)) + chr(10) +
           trim(error-status :get-message(3)) + chr(10) +
           trim(error-status :get-message(4)) + chr(10) +
           trim(error-status :get-message(5)).
      return error v-mes.
end.
end.
assign
p-min-value = (if v-exists-margin then v-min-value else p-min-value)
p-max-value = (if v-exists-margin then v-max-value else p-max-value)
p-exists-margin = (if v-exists-margin then v-exists-margin else p-exists-margin)
p-increase-pc = (if v-exists-increase then v-increase-pc else p-increase-pc)
p-rmethod = (if v-exists-rmethod then v-rmethod else p-rmethod)
p-base    = (if v-exists-rmethod then v-base else p-base)
p-range-margin  = (if v-exists-margin then (- 1) else p-range-margin)
p-range-increase = (if v-exists-increase then (- 1) else p-range-increase)
p-range-rmethod  = (if v-exists-rmethod then  (- 1 )else p-range-rmethod)
.
end.
end procedure.
procedure gds-o-normal-wastage-value :
do
on error undo, return error
:
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
  define variable v-mes as character no-undo .
  define variable v-value as character no-undo.
  define variable v-type as character no-undo.
  if not valid-object (objNormWast)
  then do:
     message
      skip "objNormWast is null reference"
      view-as alert-box error .
    undo, return error .
  end.
  if not valid-object (objNormWast:ParGdsOAttr)
  then do:
     message
      skip "objNormWast:ParGdsOAttrObj is null reference"
      view-as alert-box error .
    undo, return error .
  end.
  define buffer buf_goods for ub.goods.
  define buffer buf_normal-wastage-gds-obj-attr      for ub.gds-obj-attr.
  find first buf_goods no-lock where
             buf_goods.gds-code = objNormWast:ParGdsOAttr:GdsCode no-error .
  if not avail buf_goods then do:
    message
      skip "Не удалось найти товар с кодом" objNormWast:ParGdsOAttr:GdsCode
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_normal-wastage-gds-obj-attr no-lock
      where buf_normal-wastage-gds-obj-attr.gds-code = objNormWast:ParGdsOAttr:GdsCode
        and buf_normal-wastage-gds-obj-attr.attr-code = 'normal-wastage-o':U
        and buf_normal-wastage-gds-obj-attr.obj-type  = objNormWast:ParGdsOAttr:ObjType
        and buf_normal-wastage-gds-obj-attr.obj-code  = objNormWast:ParGdsOAttr:ObjCode
  no-error .
  if available buf_normal-wastage-gds-obj-attr then do:
    define variable v-temp-str1 as character no-undo .
    v-temp-str1 = buf_normal-wastage-gds-obj-attr.attr-value.
    case num-entries (v-temp-str1, ";"):
      when 2 then do:
        assign
          objNormWast:NormalWastageSummer =  decimal(trim(entry(1, v-temp-str1, ";":U)))
          objNormWast:NormalWastageWinter =  decimal(trim(entry(2, v-temp-str1, ";":U)))
        .
      end.
      when 4 then do:
        assign
          objNormWast:NormalWastageTransSummer   =  decimal(trim(entry(1, v-temp-str1, ";":U)))
          objNormWast:NormalWastageTransWinter   =  decimal(trim(entry(2, v-temp-str1, ";":U)))
          objNormWast:NormalWastageSummer   =  decimal(trim(entry(3, v-temp-str1, ";":U)))
          objNormWast:NormalWastageWinter   =  decimal(trim(entry(4, v-temp-str1, ";":U)))
        .
      end.
      when 0 then do:
        assign
          objNormWast:NormalWastageSummer   =  decimal(trim(v-temp-str1))
          objNormWast:NormalWastageWinter   =  decimal(trim(v-temp-str1))
        .
      end.
    end case.
    find first buf_normal-wastage-gds-obj-attr no-lock
        where buf_normal-wastage-gds-obj-attr.gds-code = objNormWast:ParGdsOAttr:GdsCode
          and buf_normal-wastage-gds-obj-attr.attr-code = 'cli-decommissioned':U
          and buf_normal-wastage-gds-obj-attr.obj-type  = objNormWast:ParGdsOAttr:ObjType
          and buf_normal-wastage-gds-obj-attr.obj-code  = objNormWast:ParGdsOAttr:ObjCode
    no-error .
    run clntattr-value in this-procedure (input objNormWast:ParGdsOAttr:ObjType,
                                          input objNormWast:ParGdsOAttr:ObjCode,
                                          input 'cli-decommissioned':U,
                                          output v-value,
                                          output v-type) no-error.
    objNormWast:IsDecommissioned = (v-value = "yes":u).
    run clntattr-value in this-procedure (input objNormWast:ParGdsOAttr:ObjType,
                                          input objNormWast:ParGdsOAttr:ObjCode,
                                          input 'cli-clim-grp':U,
                                          output v-value,
                                          output v-type) no-error.
    if num-entries(v-value) = 3 then assign
      objNormWast:BeginSummer = date (entry(2, v-value))
      objNormWast:BeginWinter  = date (entry(3, v-value))
    .
    else do:
      objNormWast:BeginSummer = 01/03.
      objNormWast:BeginWinter = 01/10.
    end.
    if objNormWast:ParGdsOAttr:OnDate <> ?
    then do:
      if objNormWast:BeginSummer <= objNormWast:ParGdsOAttr:OnDate and objNormWast:ParGdsOAttr:onDate < objNormWast:BeginWinter
      then do:
        objNormWast:NormalWastageDate = objNormWast:NormalWastageSummer.
        objNormWast:NormalWastageTransDate = objNormWast:NormalWastageTransSummer.
      end.
      else do:
        objNormWast:NormalWastageDate = objNormWast:NormalWastageWinter.
        objNormWast:NormalWastageTransDate = objNormWast:NormalWastageTransWinter.
      end.
    end.
  end.
end.
end procedure.
procedure gdsoattr-copy :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-copy           as logical   no-undo .
    case p-code :
            when 'scales-code':U then do:     assign     p-copy = false.   end.
            when 'free-price':U then do:     assign     p-copy = false.   end.
            when 'sum-grp':U then do:     assign     p-copy = true.   end.
            when 'increase-pc':U then do:     assign     p-copy = true.   end.
            when 'min-zapas':U then do:     assign     p-copy = true.   end.
            when 'round-method':U then do:     assign     p-copy = true.   end.
            when 'petrol-purse':U then do:     assign     p-copy = false.   end.
            when 'need-auth':U then do:     assign     p-copy = false.   end.
            when 'gds-margins':U then do:     assign     p-copy = true.   end.
            when 'proprietor':U then do:     assign     p-copy = false.   end.
            when 'fbr-cost-rubl':U then do:     assign     p-copy = true.   end.
            when 'no-income-goods':U then do:     assign     p-copy = true.   end.
            when 'taracode':U then do:     assign     p-copy = true.   end.
            when 'calories-o':U then do:     assign     p-copy = false.   end.
            when 'protein-o':U then do:     assign     p-copy = false.   end.
            when 'fat-o':U then do:     assign     p-copy = false.   end.
            when 'carbohydrate-o':U then do:     assign     p-copy = false.   end.
            when 'doc-tickets':U then do:     assign     p-copy = true.   end.
            when 'normal-wastage-o':U then do:     assign     p-copy = true.   end.
            when 'dop-alt-name-o':U then do:     assign     p-copy = true.   end.
            when 'dt-seasons':U then do:     assign     p-copy = true.   end.
            when 'change-dt-seasons':U then do:     assign     p-copy = false.   end.
            when 'mark-collect-type':U then do:     assign     p-copy = false.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на объекте &1",  p-code ).
      end.
    end.
  end.
end procedure.
procedure gdsoattr-manual-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'scales-code':U then do:     assign     p-section-num = 0.   end.
            when 'gds-margins':U then do:     assign     p-section-num = 1.   end.
            when 'free-price':U then do:     assign     p-section-num = 2.   end.
            when 'sum-grp':U then do:     assign     p-section-num = 2.   end.
            when 'increase-pc':U then do:     assign     p-section-num = 1.   end.
            when 'min-zapas':U then do:     assign     p-section-num = 1.   end.
            when 'round-method':U then do:     assign     p-section-num = 1.   end.
            when 'petrol-purse':U then do:     assign     p-section-num = 2.   end.
            when 'need-auth':U then do:     assign     p-section-num = 2.   end.
            when 'gds-margins':U then do:     assign     p-section-num = 1.   end.
            when 'proprietor':U then do:     assign     p-section-num = 1.   end.
            when 'fbr-cost-rubl':U then do:     assign     p-section-num = 4.   end.
            when 'taracode':U then do:     assign     p-section-num = 2.   end.
            when 'calories-o':U then do:     assign     p-section-num = 0.   end.
            when 'protein-o':U then do:     assign     p-section-num = 0.   end.
            when 'fat-o':U then do:     assign     p-section-num = 0.   end.
            when 'carbohydrate-o':U then do:     assign     p-section-num = 0.   end.
            when 'doc-tickets':U then do:     assign     p-section-num = 1.   end.
            when 'normal-wastage-o':U then do:     assign     p-section-num = 1.   end.
            when 'dop-alt-name-o':U then do:     assign     p-section-num = 1.   end.
            when 'dt-seasons':U then do:     assign     p-section-num = 2.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gdsoattr-batch-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'scales-code':U then do:     assign     p-section-num = 0.   end.
            when 'gds-margins':U then do:     assign     p-section-num = 1.   end.
            when 'free-price':U then do:     assign     p-section-num = 2.   end.
            when 'sum-grp':U then do:     assign     p-section-num = 2.   end.
            when 'increase-pc':U then do:     assign     p-section-num = 1.   end.
            when 'min-zapas':U then do:     assign     p-section-num = 1.   end.
            when 'round-method':U then do:     assign     p-section-num = 1.   end.
            when 'petrol-purse':U then do:     assign     p-section-num = 2.   end.
            when 'need-auth':U then do:     assign     p-section-num = 2.   end.
            when 'gds-margins':U then do:     assign     p-section-num = 1.   end.
            when 'proprietor':U then do:     assign     p-section-num = 1.   end.
            when 'fbr-cost-rubl':U then do:     assign     p-section-num = 4.   end.
            when 'no-income-goods':U then do:     assign     p-section-num = 5.   end.
            when 'taracode':U then do:     assign     p-section-num = 2.   end.
            when 'calories-o':U then do:     assign     p-section-num = 0.   end.
            when 'protein-o':U then do:     assign     p-section-num = 0.   end.
            when 'fat-o':U then do:     assign     p-section-num = 0.   end.
            when 'carbohydrate-o':U then do:     assign     p-section-num = 0.   end.
            when 'doc-tickets':U then do:     assign     p-section-num = 1.   end.
            when 'normal-wastage-o':U then do:     assign     p-section-num = 1.   end.
            when 'dop-alt-name-o':U then do:     assign     p-section-num = 1.   end.
            when 'dt-seasons':U then do:     assign     p-section-num = 2.   end.
            when 'change-dt-seasons':U then do:     assign     p-section-num = 2.   end.
            when 'mark-collect-type':U then do:     assign     p-section-num = 0.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gds-obj-sum-grps :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE rid-list as character no-undo .
define buffer buf_sum-grp for ub.sum-grp.
  do
  on error undo, return error
  :
    find first buf_sum-grp no-lock where
               buf_sum-grp.grp-code = integer(p-value) no-error .
    if avail buf_sum-grp then do:
      assign
      rid-list = string(recid(buf_sum-grp))
      .
    end.
    run ref/sum-grps.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output rid-list).
    if rid-list <> "":U then do:
      find first buf_sum-grp no-lock where
                 recid(buf_sum-grp) = integer(entry(1, rid-list)) no-error .
      if not avail buf_sum-grp then return error.
      assign
      p-value = string(buf_sum-grp.grp-code, "999")
      p-setted = yes
      .
    end.
    else p-setted = no.
  end.
end procedure.
procedure gds-obj-init-increase-pc :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .
define output parameter p-value as character no-undo .
define buffer buf_goods for ub.goods.
  do
  on error undo, return error
  :
    find first buf_goods no-lock where
               buf_goods.gds-code = p-gds-code no-error .
    if avail buf_goods then
    assign
    p-value = string(buf_goods.increase-pc)
    .
  end.
end procedure.
procedure gds-obj-round-method :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/r-method.w (input-output v-value) no-error .
    if p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure gds-obj-taracode :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE rid-list as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-obj-db-num as integer no-undo .
define variable par-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
  do
  on error undo, return error return-value
  :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
    run adm/shattri.p (
      input "get":U
      ,input p-obj-type
      ,input p-obj-code
      ,input  'cd-sending':U
      ,input  "dflt-cd":U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    IF not error-status:error then
    assign
    dflt-cd = v-value-character .
    find first buf_cash-desk-attr no-lock where
              buf_cash-desk-attr.obj-code = p-obj-code
         and  buf_cash-desk-attr.cash-num = 0
         and  buf_cash-desk-attr.pos-type = dflt-cd
         and buf_cash-desk-attr.attr-code = ('tara-ref':U  + chr(4) + p-value)
         and buf_cash-desk-attr.db-num  = v-obj-db-num  no-error .
    if avail buf_cash-desk-attr then do:
      assign
      rid-list = string(recid(buf_cash-desk-attr))
      .
    end.
    run ref/ncrtarac.w ( input parparentproc
                    ,input ?
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input ?
                    ,input ?
                    ,input "b-sel"
                    ,input-output rid-list).
    if rid-list <> "":U then do:
      find first buf_cash-desk-attr no-lock where
                 recid(buf_cash-desk-attr) = integer(entry(1, rid-list)) no-error .
      if not avail buf_cash-desk-attr then return error.
      assign
      p-value = string(integer(entry(2, buf_cash-desk-attr.attr-code, chr(4)) ), "99")
      p-setted = yes
      .
    end.
    else p-setted = no.
  end.
end procedure.
procedure gds-obj-attr_check-ptrl-divis :
  define input parameter  p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input parameter  p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input parameter  p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define output parameter p-correct     as logical   no-undo .
  define output parameter p-error-code  as character no-undo .
  define buffer buf_goods for ub.goods.
  define variable v-is-petrolium as logical no-undo .
  define variable v-is-pieces    as logical no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
      return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                              , p-gds-code).
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) no-error.
    if error-status:error then do:
      assign
      p-error-code =  substitute("&1 &2", error-status:get-message(1) , return-value ).
      return.
    end.
    if not v-is-petrolium then do:
      assign
      p-error-code = substitute("Товар-топливо должен иметь топливную единицу измерения для задания норм естественной убыли для топлива").
      return p-error-code.
    end.
    if v-is-pieces then do:
      assign
      p-error-code = substitute("Товар-топливо должен иметь дробную единицу измерения для задания норм естественной убыли для топлива").
      return p-error-code.
    end.
    assign
    p-correct = yes.
  end.
end procedure.
procedure gdspoatr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'corrcoeff-po':U then do:     assign     p-label = "Корр.коэфф для расчета заказов"     p-type = 'D':U      p-format = ">>9.99"     p-label = "Корр.коэфф для расчета заказов"     p-user-can-edit  = true     p-output-display = false     p-other = "init-value=1"      .   end.
            when 'CorrIztDel':U then do:     assign     p-label = "Дата НА ВЫВОД ИЗ АССОРТ"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата НА ВЫВОД ИЗ АССОРТ"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара для ЗАКАЗОВ на объекте/фирме &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gdspoatr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'corrcoeff-po':U then do:     assign     p-tooltip = "Корректирующий коэффициент для расчета кол-ва в заказах ОБЪЕКТ-ПОСТАВЩИК"     p-label = "Корр.коэфф для расчета заказов" .   end.
            when 'CorrIztDel':U then do:     assign     p-tooltip = "Дата простановки статуса НА ВЫВОД ИЗ АССОРТИМЕНТА"     p-label = "Дата НА ВЫВОД ИЗ АССОРТ" .   end.
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара для ЗАКАЗОВ на объекте/фирме &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gdspoatr-value :
 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
    define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
    define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
    define output parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable jj as integer no-undo .
    define variable v-found as logical no-undo .
    run gdspoatr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-obj-prop-attr no-lock where
               buf_gds-obj-prop-attr.gds-code  = p-gds-code AND
               buf_gds-obj-prop-attr.obj-type  = p-obj-type AND
               buf_gds-obj-prop-attr.obj-code  = p-obj-code AND
               buf_gds-obj-prop-attr.attr-code = p-code
      no-error .
    if avail buf_gds-obj-prop-attr then do:
      assign
        p-value =  buf_gds-obj-prop-attr.attr-value
      .
    end.
    else do:
      do jj = 1 to num-entries(v-other, chr(47)):
        if entry(1, entry(jj, v-other, chr(47)), "=":U) = "init-value":U then do:
          assign
          p-value = string(entry(2, entry(jj, v-other, chr(47)), "=":U))
          v-found = yes
          .
        end.
      end.
      if not v-found then do:
        assign
        p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
    end.
  end.
end procedure.
procedure gdspoatr-write :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
    define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr .
    define buffer lock_gds-obj-prop-attr for ub.gds-obj-prop-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gdspoatr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-obj-prop-attr exclusive-lock where
               buf_gds-obj-prop-attr.gds-code  = p-gds-code
           AND buf_gds-obj-prop-attr.obj-type  = p-obj-type
           AND buf_gds-obj-prop-attr.obj-code  = p-obj-code
           AND buf_gds-obj-prop-attr.attr-code = p-code no-error .
    if not available buf_gds-obj-prop-attr then do:
      create buf_gds-obj-prop-attr .
      assign
        buf_gds-obj-prop-attr.gds-code  = p-gds-code
        buf_gds-obj-prop-attr.obj-type  = p-obj-type
        buf_gds-obj-prop-attr.obj-code  = p-obj-code
        buf_gds-obj-prop-attr.attr-code = p-code
        buf_gds-obj-prop-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_gds-obj-prop-attr.attr-value = p-value no-error.
  end.
end procedure.
procedure gdspoatr-exist :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .
    define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gdspoatr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-obj-prop-attr no-lock where
               buf_gds-obj-prop-attr.gds-code  = p-gds-code
           AND buf_gds-obj-prop-attr.obj-type  = p-obj-type
           AND buf_gds-obj-prop-attr.obj-code  = p-obj-code
           AND buf_gds-obj-prop-attr.attr-code = p-code no-error .
    if available buf_gds-obj-prop-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure gdspoatr-delete :
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run gdspoatr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-obj-prop-attr exclusive-lock where
               buf_gds-obj-prop-attr.gds-code  = p-gds-code
           AND buf_gds-obj-prop-attr.obj-type  = p-obj-type
           AND buf_gds-obj-prop-attr.obj-code  = p-obj-code
           AND buf_gds-obj-prop-attr.attr-code = p-code no-error .
    if not available buf_gds-obj-prop-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_gds-obj-prop-attr.
       P-DELETED = YES.
    END.
  end.
end procedure.
procedure gdspoatr-copy :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-copy           as logical   no-undo .
    case p-code :
            when 'corrcoeff-po':U then do:     assign     p-copy = false.   end.
            when 'CorrIztDel':U then do:     assign     p-copy = false.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара ДЛЯ ЗАКАЗОВ на объекте/фирме &1",  p-code ).
      end.
    end.
  end.
end procedure.
procedure gdspoatr-manual-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'corrcoeff-po':U then do:     assign     p-section-num = 0.   end.
            when 'CorrIztDel':U then do:     assign     p-section-num = 0.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара ДЛЯ ЗАКАЗОВ на объекте/фирме &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gdspoatr-batch-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'corrcoeff-po':U then do:     assign     p-section-num = 0.   end.
            when 'CorrIztDel':U then do:     assign     p-section-num = 0.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара ДЛЯ ЗАКАЗОВ на объекте/фирме &1", p-code ).
      end.
    end.
  end.
end procedure.
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
    case p-code :
            when 'schedule-nws':U then do:     assign     p-label = "Расписание новостей для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание новостей для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-merc':U then do:     assign     p-label = "Расписание обмена с ФГИС Меркурий для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание обмена с ФГИС Меркурий для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-hdd':U then do:     assign     p-label = "Расписание мониторинга HDD для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание мониторинга HDD для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-motp':U then do:     assign     p-label = "Расписание обмена с ИС МОТП для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание обмена с ИС МОТП для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-diadoc':U then do:     assign     p-label = "Расписание обмена с Диадок для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание обмена с Диадок для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ver-met':U then do:     assign     p-label = "Версия метаданных"     p-type = 'I':U      p-format = "999999999"     p-label = "Версия метаданных"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-isPM':U then do:     assign     p-label = "Расписание выгрузки в ИС ПМ для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание выгрузки в ИС ПМ для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-arc':U then do:     assign     p-label = "Расписание расчета архивов для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание расчета архивов для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-exp':U then do:     assign     p-label = "Расписание экспорта для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание экспорта для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-oxml':U then do:     assign     p-label = "Расписание OpenXML для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание OpenXML для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'need-gen-new-pack':U then do:     assign     p-label = "Необходимость формирования нового пакета(ов) для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Необходимость формирования нового пакета(ов) для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'last-unload-db-key':U then do:     assign     p-label = "Ключ с которым последний раз выгружали БД"     p-type = 'C':U      p-format = "X(12)"     p-label = "Ключ с которым последний раз выгружали БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-getcd':U then do:     assign     p-label = "Расписание получения информации с касс для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание получения информации с касс для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-sale':U then do:     assign     p-label = "Расписание обработки документов продаж для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание обработки документов продаж для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-suz':U then do:     assign     p-label = "Расписание запуска отчетов для БД"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание запуска отчетов для БД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cut-date':U then do:     assign     p-label = "Дата по которую усечены документы по БД в ГБД"     p-type = 'T':U      p-format = "99.99.9999"     p-label = "Дата по которую усечены документы по БД в ГБД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cut-fin-date':U then do:     assign     p-label = "Дата по которую усечены финансовые документы по БД в ГБД"     p-type = 'T':U      p-format = "99.99.9999"     p-label = "Дата по которую усечены финансовые документы по БД в ГБД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'unload-after-cut':U then do:     assign     p-label = "БД выгружена после усечения документов по ней в ГБД"     p-type = 'L':U      p-format = "+/-"     p-label = "БД выгружена после усечения документов по ней в ГБД"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cut-db-list':U then do:     assign     p-label = "Список БД в которых усекаются документы"     p-type = 'C':U      p-format = "X(256)"     p-label = "Список БД в которых усекаются документы"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-cbnk':U then do:     assign     p-label = "Расписание эксп/имп в КЛИЕНТ-БАНК"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание эксп/имп в КЛИЕНТ-БАНК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'arh-disable':U then do:     assign     p-label = "Расчет складского архива по товарам запрещен"     p-type = 'L':U      p-format = "+/-"     p-label = "Расчет складского архива по товарам запрещен"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ahsp-disable':U then do:     assign     p-label = "Расчет складского архива по поставщикам запрещен"     p-type = 'L':U      p-format = "+/-"     p-label = "Расчет складского архива по поставщикам запрещен"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'aht-disable':U then do:     assign     p-label = "Расчет складского архива по типам приобретения запрещен"     p-type = 'L':U      p-format = "+/-"     p-label = "Расчет складского архива по типам приобретения запрещен"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'schedule-free':U then do:     assign     p-label = "Расписание произвольных задач"     p-type = 'L':U      p-format = "+/-"     p-label = "Расписание произвольных задач"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ora-exp-seq':U then do:     assign     p-label = "Номер последней выгрузки в Oracle Retail"     p-type = 'I':U      p-format = "999999999"     p-label = "Номер последней выгрузки в Oracle Retail"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'mess-id-video':U then do:     assign     p-label = "Номер сообщения видеонаблюдения"     p-type = 'L':U      p-format = "+/-"     p-label = "Номер сообщения видеонаблюдения"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'int-point':U then do:     assign     p-label = "Точка интеграции ERPRN"     p-type = 'C':U      p-format = "+/-"     p-label = "Точка интеграции ERPRN"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ver-code':U then do:     assign     p-label = "Версия справочников"     p-type = 'I':U      p-format = "999999999"     p-label = "Версия справочников"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'hist-code':U then do:     assign     p-label = "Исторический код объекта"     p-type = 'C':U      p-format = "x(50)"     p-label = "Исторический код объекта"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'hist-name':U then do:     assign     p-label = "Историческое наименование объекта"     p-type = 'C':U      p-format = "x(50)"     p-label = "Историческое наименование объекта"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'asiip':U then do:     assign     p-label = "АСИ IP"     p-type = 'C':U      p-format = "X(20)"     p-label = "АСИ IP"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'asiport':U then do:     assign     p-label = "АСИ Port"     p-type = 'C':U      p-format = "X(12)"     p-label = "АСИ Port"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'asitype':U then do:     assign     p-label = "АСИ Type"     p-type = 'C':U      p-format = "X(12)"     p-label = "АСИ Type"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'reg-code':U then do:     assign     p-label = "Регион"     p-type = 'I':U      p-format = "999999999"     p-label = "Регион"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'last-nws-sync':U then do:     assign     p-label = "Время последней синхронизации обмена СПН"     p-type = 'C':U      p-format = "X(60)"     p-label = "Время последней синхронизации обмена СПН"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
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
    case p-code :
            when 'schedule-nws':U then do:     assign     p-tooltip = "Составлено ли расписание отправки новостей для базы данных"     p-label = "Расписание новостей для БД" .   end.
            when 'schedule-merc':U then do:     assign     p-tooltip = "Составлено ли расписание обмена с ФГИС Меркурий для базы данных"     p-label = "Расписание обмена с ФГИС Меркурий для БД" .   end.
            when 'schedule-hdd':U then do:     assign     p-tooltip = "Составлено ли расписание мониторинга HDD для базы данных"     p-label = "Расписание мониторинга HDD для БД" .   end.
            when 'schedule-motp':U then do:     assign     p-tooltip = "Составлено ли расписание обмена с ИС МОТП для базы данных"     p-label = "Расписание обмена с ИС МОТП для БД" .   end.
            when 'schedule-diadoc':U then do:     assign     p-tooltip = "Составлено ли расписание обмена с Диадок для базы данных"     p-label = "Расписание обмена с Диадок для БД" .   end.
            when 'ver-met':U then do:     assign     p-tooltip = "Версия метаданных"     p-label = "Версия метаданных" .   end.
            when 'schedule-isPM':U then do:     assign     p-tooltip = "Составлено ли расписание выгрузки в ИС ПМ для базы данных"     p-label = "Расписание выгрузки в ИС ПМ для БД" .   end.
            when 'schedule-arc':U then do:     assign     p-tooltip = "Составлено ли расписание расчета архивов для базы данных"     p-label = "Расписание расчета архивов для БД" .   end.
            when 'schedule-exp':U then do:     assign     p-tooltip = "Составлено ли расписание экспорта для базы данных"     p-label = "Расписание экспорта для БД" .   end.
            when 'schedule-oxml':U then do:     assign     p-tooltip = "Составлено ли расписание OpenXML для базы данных"     p-label = "Расписание OpenXML для БД" .   end.
            when 'need-gen-new-pack':U then do:     assign     p-tooltip = "Необходимо ли формировать новый пакет(ы) для базы данных"     p-label = "Необходимость формирования нового пакета(ов) для БД" .   end.
            when 'last-unload-db-key':U then do:     assign     p-tooltip = "Ключ с которым последний раз выгружали БД"     p-label = "Ключ с которым последний раз выгружали БД" .   end.
            when 'schedule-getcd':U then do:     assign     p-tooltip = "Составлено ли расписание получения информации с касс для базы данных"     p-label = "Расписание получения информации с касс для БД" .   end.
            when 'schedule-sale':U then do:     assign     p-tooltip = "Составлено ли расписание обработки документов продаж для базы данных"     p-label = "Расписание обработки документов продаж для БД" .   end.
            when 'schedule-suz':U then do:     assign     p-tooltip = "Составлено ли расписание запуска отчетов для базы данных"     p-label = "Расписание запуска отчетов для БД" .   end.
            when 'cut-date':U then do:     assign     p-tooltip = "Дата по которую усечены документы по БД в ГБД"     p-label = "Дата по которую усечены документы по БД в ГБД" .   end.
            when 'cut-fin-date':U then do:     assign     p-tooltip = "Дата по которую усечены финансовые документы по БД в ГБД"     p-label = "Дата по которую усечены финансовые документы по БД в ГБД" .   end.
            when 'unload-after-cut':U then do:     assign     p-tooltip = "БД выгружена после усечения документов по ней в ГБД"     p-label = "БД выгружена после усечения документов по ней в ГБД" .   end.
            when 'cut-db-list':U then do:     assign     p-tooltip = "Список БД в которых усекаются документы"     p-label = "Список БД в которых усекаются документы" .   end.
            when 'schedule-cbnk':U then do:     assign     p-tooltip = "Составлено ли расписание для эксп/имп в КЛИЕНТ-БАНК"     p-label = "Расписание эксп/имп в КЛИЕНТ-БАНК" .   end.
            when 'arh-disable':U then do:     assign     p-tooltip = "Расчет складского архива по товарам запрещен"     p-label = "Расчет складского архива по товарам запрещен" .   end.
            when 'ahsp-disable':U then do:     assign     p-tooltip = "Расчет складского архива по поставщикам запрещен"     p-label = "Расчет складского архива по поставщикам запрещен" .   end.
            when 'aht-disable':U then do:     assign     p-tooltip = "Расчет складского архива по типам приобретения запрещен"     p-label = "Расчет складского архива по типам приобретения запрещен" .   end.
            when 'schedule-free':U then do:     assign     p-tooltip = "Составлено ли расписание произвольных задач"     p-label = "Расписание произвольных задач" .   end.
            when 'ora-exp-seq':U then do:     assign     p-tooltip = "Номер последней выгрузки в Oracle Retail"     p-label = "Номер последней выгрузки в Oracle Retail" .   end.
            when 'mess-id-video':U then do:     assign     p-tooltip = "Номер сообщения видеонаблюдения"     p-label = "Номер сообщения видеонаблюдения" .   end.
            when 'int-point':U then do:     assign     p-tooltip = "Точка интеграции ERPRN"     p-label = "Точка интеграции ERPRN" .   end.
            when 'ver-code':U then do:     assign     p-tooltip = "Версия справочников"     p-label = "Версия справочников" .   end.
            when 'hist-code':U then do:     assign     p-tooltip = "Исторический код объекта"     p-label = "Исторический код объекта" .   end.
            when 'hist-name':U then do:     assign     p-tooltip = "Историческое наименование объекта"     p-label = "Историческое наименование объекта" .   end.
            when 'asiip':U then do:     assign     p-tooltip = "АСИ IP"     p-label = "АСИ IP" .   end.
            when 'asiport':U then do:     assign     p-tooltip = "АСИ port"     p-label = "АСИ Port" .   end.
            when 'asitype':U then do:     assign     p-tooltip = "АСИ Type"     p-label = "АСИ Type" .   end.
            when 'reg-code':U then do:     assign     p-tooltip = "Регион"     p-label = "Регион" .   end.
            when 'last-nws-sync':U then do:     assign     p-tooltip = "Время последней синхронизации обмена СПН"     p-label = "Время последней синхронизации обмена СПН" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
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
    define buffer buf_db-attr for ub.db-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run db-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1))
  :
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1)) .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'schedule-nws':U then do:     assign     p-news = no.   end.
            when 'schedule-merc':U then do:     assign     p-news = no.   end.
            when 'schedule-hdd':U then do:     assign     p-news = no.   end.
            when 'schedule-motp':U then do:     assign     p-news = no.   end.
            when 'schedule-diadoc':U then do:     assign     p-news = no.   end.
            when 'ver-met':U then do:     assign     p-news = no.   end.
            when 'schedule-isPM':U then do:     assign     p-news = no.   end.
            when 'schedule-arc':U then do:     assign     p-news = no.   end.
            when 'schedule-exp':U then do:     assign     p-news = no.   end.
            when 'schedule-oxml':U then do:     assign     p-news = no.   end.
            when 'need-gen-new-pack':U then do:     assign     p-news = no.   end.
            when 'last-unload-db-key':U then do:     assign     p-news = no.   end.
            when 'schedule-getcd':U then do:     assign     p-news = no.   end.
            when 'schedule-sale':U then do:     assign     p-news = no.   end.
            when 'schedule-suz':U then do:     assign     p-news = no.   end.
            when 'cut-date':U then do:     assign     p-news = yes.   end.
            when 'cut-fin-date':U then do:     assign     p-news = yes.   end.
            when 'unload-after-cut':U then do:     assign     p-news = yes.   end.
            when 'cut-db-list':U then do:     assign     p-news = no.   end.
            when 'schedule-cbnk':U then do:     assign     p-news = no.   end.
            when 'arh-disable':U then do:     assign     p-news = no.   end.
            when 'ahsp-disable':U then do:     assign     p-news = no.   end.
            when 'aht-disable':U then do:     assign     p-news = no.   end.
            when 'schedule-free':U then do:     assign     p-news = no.   end.
            when 'ora-exp-seq':U then do:     assign     p-news = no.   end.
            when 'mess-id-video':U then do:     assign     p-news = no.   end.
            when 'int-point':U then do:     assign     p-news = yes.   end.
            when 'hist-code':U then do:     assign     p-news = yes.   end.
            when 'hist-name':U then do:     assign     p-news = yes.   end.
            when 'asiip':U then do:     assign     p-news = no.   end.
            when 'asiport':U then do:     assign     p-news = no.   end.
            when 'asitype':U then do:     assign     p-news = no.   end.
            when 'reg-code':U then do:     assign     p-news = true.   end.
            when 'last-nws-sync':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code like ub.goods.gds-code     no-undo .
  define output parameter p-can-set  as   logical no-undo .
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  run gds-attr-value in this-procedure (
    input p-gds-code
    ,input "fuel-type"
    ,output v-value
    ,output v-type) .
  p-can-set = v-value = "diesel".
end procedure.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     as   integer             no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  define buffer buf_code for ub.code.
  p-dt-code = 0.
  if can-find(first buf_code where
                  buf_code.code = string(p-code)
              and buf_code.parent = "DTSeasons") then
  do:
    p-dt-code = p-code.
    run gdsoattr-gds-code in this-procedure
      ("dt-seasons", string(p-code), p-obj-type, p-obj-code, output p-gds-code).
    if p-gds-code = 0 then
      p-gds-code = p-code.
  end.
  else
    p-gds-code = p-code.
end procedure.
procedure gds-obj-dt-seasons :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  define variable rid            as recid no-undo .
  define variable canSetDtSeason as logical no-undo.
  define variable gdsCode        like ub.gds-obj-attr.gds-code no-undo.
  define buffer buf_code       for ub.code.
  define buffer buf_goods      for ub.goods.
  run gds-attr_check-can-set-dt-seasons in this-procedure
    (p-gds-code, output canSetDtSeason).
  if not canSetDtSeason then
  do:
    find first buf_goods where
               buf_goods.gds-code = p-gds-code
         no-lock no-error.
    message "Атрибут ~"Сезон ДТ~| может быть настроен только для дизельного топлива.~n"
            "Для товара " if available buf_goods then substitute("<&1 &2 &3>",buf_goods.gds-code, buf_goods.artic, buf_goods.gds-name) else ""
            "~nне установлен атрибут ~"Тип топлива~" в значении ~"ДТ~".~n"
            "В установке атрибута «Сезон ДТ» отказано." view-as alert-box.
    p-setted = no.
    return.
  end.
  do
  on error undo, return error
  :
    run ref/dtseasons.p
      (input  parparentproc
      , p-gds-code
      ,output rid
      ) no-error.
    if rid <> ? then
    do:
      find first buf_code no-lock where
                 recid(buf_code) = rid no-error .
      if not avail buf_code then return error.
      run gdsoattr-gds-code in this-procedure
        ("dt-seasons", buf_code.code, p-obj-type, p-obj-code, output gdsCode).
      if gdsCode <> 0 and gdsCode <> p-gds-code then
      do:
        find first buf_goods where
                   buf_goods.gds-code = gdsCode
             no-lock no-error.
        message "Атрибут ~"Сезон ДТ~" может быть настроен только для одного дизельного топлива для одного объекта.~n"
                "Для товара " if available buf_goods then substitute("<&1 &2 &3>",buf_goods.gds-code, buf_goods.artic, buf_goods.gds-name) else ""
                "~nуже настроен атрибут ~"Сезон ДТ~" в значении " buf_code.code ".~n"
                "В установке атрибута «Сезон ДТ» отказано." view-as alert-box.
        undo, return error.
      end.
      assign
        p-value = buf_code.code
        p-setted = yes
      .
    end.
    else
    do:
      if error-status:error then
      do:
        message
          return-value skip
          "В установке атрибута «Сезон ДТ» отказано." view-as alert-box
        .
      end.
      p-setted = no.
    end.
  end.
end procedure.
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
    case p-code :
            when 'need-gen-new-xpack':U then do:     assign     p-label = "Необходимость формирования нового пакета(ов) для ВС"     p-type = 'L':U      p-format = "+/-"     p-label = "Необходимость формирования нового пакета(ов) для ВС"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'FTP':U then do:     assign     p-label = "FTP"     p-type = 'C':U      p-format = "X(256)"     p-label = "FTP"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'Login':U then do:     assign     p-label = "Login"     p-type = 'C':U      p-format = "X(256)"     p-label = "Login"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'Password':U then do:     assign     p-label = "Password"     p-type = 'C':U      p-format = "X(256)"     p-label = "Password"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'Path':U then do:     assign     p-label = "Путь"     p-type = 'C':U      p-format = "X(256)"     p-label = "Путь"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'IN-dir':U then do:     assign     p-label = "Вход"     p-type = 'C':U      p-format = "X(256)"     p-label = "Вход"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'OUT-dir':U then do:     assign     p-label = "Исход"     p-type = 'C':U      p-format = "X(256)"     p-label = "Исход"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'cert-sign':U then do:     assign     p-label = "Использовать цифровую подпись"     p-type = 'L':U      p-format = "+/-"     p-label = "Использовать цифровую подпись"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'cert-sign-subject':U then do:     assign     p-label = "Владелец подписи (Субъект)"     p-type = 'C':U      p-format = "X(256)"     p-label = "Владелец подписи (Субъект)"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'cert-sign-issuer':U then do:     assign     p-label = "Издатель подписи"     p-type = 'C':U      p-format = "X(256)"     p-label = "Издатель подписи"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'cert-file-ext':U then do:     assign     p-label = "Расширение имени файла"     p-type = 'C':U      p-format = "X(6)"     p-label = "Расширение имени файла"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'cert-repository':U then do:     assign     p-label = "Хранилище сертификатов"     p-type = 'I':U      p-format = ">>9"     p-label = "Хранилище сертификатов"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'AuthToken':U then do:     assign     p-label = "Токен авторизации"     p-type = 'C':U      p-format = "X(16000)"     p-label = "Токен авторизации"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'AuthTokenDT':U then do:     assign     p-label = "Дата и время запроса токена авторизации"     p-type = 'C':U      p-format = "X(256)"     p-label = "Дата и время запроса токена авторизации"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'host-code':U then do:     assign     p-label = "Код фирмы"     p-type = 'I':U      p-format = ">>>>>>>>>9"     p-label = "Код фирмы"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'obj':U then do:     assign     p-label = "Объект"     p-type = 'C':U      p-format = "X(15)"     p-label = "Объект"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'user-id':U then do:     assign     p-label = "Пользователь"     p-type = 'C':U      p-format = "X(256)"     p-label = "Пользователь"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'server-addr':U then do:     assign     p-label = "Адрес сервера МОТП или Диадок"     p-type = 'C':U      p-format = "X(256)"     p-label = "Адрес сервера МОТП или Диадок"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'proxy-addr':U then do:     assign     p-label = "Адрес прокси"     p-type = 'C':U      p-format = "X(256)"     p-label = "Адрес прокси"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'proxy-login':U then do:     assign     p-label = "Логин прокси"     p-type = 'C':U      p-format = "X(256)"     p-label = "Логин прокси"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'proxy-pswd':U then do:     assign     p-label = "Пароль прокси"     p-type = 'C':U      p-format = "X(256)"     p-label = "Пароль прокси"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'proxy-ssl':U then do:     assign     p-label = "SSL прокси"     p-type = 'L':U      p-format = "+/-"     p-label = "SSL прокси"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'AuthToken-send':U then do:     assign     p-label = "Просроченный токен авторизации"     p-type = 'C':U      p-format = "X(16000)"     p-label = "Просроченный токен авторизации"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'mail-list':U then do:     assign     p-label = "Список адресов эл. почты"     p-type = 'C':U      p-format = "X(1000)"     p-label = "Список адресов эл. почты"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'diadoc-user':U then do:     assign     p-label = "Пользователь Диадок"     p-type = 'C':U      p-format = "X(256)"     p-label = "Пользователь Диадок"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'diadoc-pwd':U then do:     assign     p-label = "Пароль пользователя Диадок"     p-type = 'C':U      p-format = "X(256)"     p-label = "Пароль пользователя Диадок"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'diadoc-key':U then do:     assign     p-label = "Ключ разработчика Диадок"     p-type = 'C':U      p-format = "X(256)"     p-label = "Ключ разработчика Диадок"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'diadoc-lastload':U then do:     assign     p-label = "Дата последнего загруженого документа Диадок"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата последнего загруженого документа Диадок"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
            when 'diadoc-ssl':U then do:     assign     p-label = "Отключение проверки шифрования Диадок"     p-type = 'L':U      p-format = "yes/no"     p-label = "Отключение проверки шифрования Диадок"     p-user-can-edit  = true     p-output-display = false     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
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
    case p-code :
            when 'need-gen-new-xpack':U then do:     assign     p-tooltip = "Необходимо ли формировать новый пакет(ы) для внешней системы"     p-label = "Необходимость формирования нового пакета(ов) для ВС" .   end.
            when 'FTP':U then do:     assign     p-tooltip = "FTP (адрес)"     p-label = "FTP" .   end.
            when 'Login':U then do:     assign     p-tooltip = "Login FTP"     p-label = "Login" .   end.
            when 'Password':U then do:     assign     p-tooltip = "Password FTP"     p-label = "Password" .   end.
            when 'Path':U then do:     assign     p-tooltip = "Путь (от HOME-директории)"     p-label = "Путь" .   end.
            when 'IN-dir':U then do:     assign     p-tooltip = "Папка Входящие"     p-label = "Вход" .   end.
            when 'OUT-dir':U then do:     assign     p-tooltip = "Папка исходящие"     p-label = "Исход" .   end.
            when 'cert-sign':U then do:     assign     p-tooltip = "Использовать цифровую подпись при обмене с внешней системой"     p-label = "Использовать цифровую подпись" .   end.
            when 'cert-sign-subject':U then do:     assign     p-tooltip = "Владелец подписи (Субъект)"     p-label = "Владелец подписи (Субъект)" .   end.
            when 'cert-sign-issuer':U then do:     assign     p-tooltip = "Издатель подписи"     p-label = "Издатель подписи" .   end.
            when 'cert-file-ext':U then do:     assign     p-tooltip = "Расширение имени файла с цифровой подписью"     p-label = "Расширение имени файла" .   end.
            when 'cert-repository':U then do:     assign     p-tooltip = "Расположение хранилища сертификатов"     p-label = "Хранилище сертификатов" .   end.
            when 'AuthToken':U then do:     assign     p-tooltip = "Токен авторизации"     p-label = "Токен авторизации" .   end.
            when 'AuthTokenDT':U then do:     assign     p-tooltip = "Дата и время запроса токена авторизации"     p-label = "Дата и время запроса токена авторизации" .   end.
            when 'host-code':U then do:     assign     p-tooltip = "Код фирмы"     p-label = "Код фирмы" .   end.
            when 'obj':U then do:     assign     p-tooltip = "Объект"     p-label = "Объект" .   end.
            when 'user-id':U then do:     assign     p-tooltip = "Пользователь"     p-label = "Пользователь" .   end.
            when 'server-addr':U then do:     assign     p-tooltip = "Адрес сервера МОТП или Диадок"     p-label = "Адрес сервера МОТП или Диадок" .   end.
            when 'proxy-addr':U then do:     assign     p-tooltip = "Адрес прокси"     p-label = "Адрес прокси" .   end.
            when 'proxy-login':U then do:     assign     p-tooltip = "Логин прокси"     p-label = "Логин прокси" .   end.
            when 'proxy-pswd':U then do:     assign     p-tooltip = "Пароль прокси"     p-label = "Пароль прокси" .   end.
            when 'proxy-ssl':U then do:     assign     p-tooltip = "SSL прокси"     p-label = "SSL прокси" .   end.
            when 'AuthToken-send':U then do:     assign     p-tooltip = "Просроченный токен авторизации"     p-label = "Просроченный токен авторизации" .   end.
            when 'mail-list':U then do:     assign     p-tooltip = "Список адресов эл. почты для отправки уведомлений. Указывать через запятую."     p-label = "Список адресов эл. почты" .   end.
            when 'diadoc-user':U then do:     assign     p-tooltip = "Пользователь Диадок"     p-label = "Пользователь Диадок" .   end.
            when 'diadoc-pwd':U then do:     assign     p-tooltip = "Пароль пользователя Диадок"     p-label = "Пароль пользователя Диадок" .   end.
            when 'diadoc-key':U then do:     assign     p-tooltip = "Ключ разработчика Диадок"     p-label = "Ключ разработчика Диадок" .   end.
            when 'diadoc-lastload':U then do:     assign     p-tooltip = "Дата последнего загруженого документа Диадок"     p-label = "Дата последнего загруженого документа Диадок" .   end.
            when 'diadoc-ssl':U then do:     assign     p-tooltip = "Отключение проверки шифрования Диадок"     p-label = "Отключение проверки шифрования Диадок" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
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
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run ext-system-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ext-system-attr no-lock
      where buf_ext-system-attr.esys-id   = p-esys-id
        and buf_ext-system-attr.db-num    = p-db-num
        and buf_ext-system-attr.esya-attr-code = p-code
      no-error .
    if avail buf_ext-system-attr then do:
      assign
        p-value =  buf_ext-system-attr.esya-attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
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
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run ext-system-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ext-system-attr exclusive-lock
      where buf_ext-system-attr.esys-id   = p-esys-id
        and buf_ext-system-attr.db-num    = p-db-num
        and buf_ext-system-attr.esya-attr-code = p-code
      no-error .
    if not available buf_ext-system-attr then do:
      create buf_ext-system-attr .
      assign
        buf_ext-system-attr.esys-id   = p-esys-id
        buf_ext-system-attr.db-num    = p-db-num
        buf_ext-system-attr.esya-attr-code = p-code
      .
    end.
    assign
      buf_ext-system-attr.esya-attr-value = p-value
    .
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
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run ext-system-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ext-system-attr no-lock
      where buf_ext-system-attr.esys-id   = p-esys-id
        and buf_ext-system-attr.db-num    = p-db-num
        and buf_ext-system-attr.esya-attr-code = p-code
      no-error .
    if  available buf_ext-system-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure ext-system-attr-delete :
  define input parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run ext-system-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ext-system-attr exclusive-lock
      where buf_ext-system-attr.esys-id   = p-esys-id
        and buf_ext-system-attr.db-num    = p-db-num
        and buf_ext-system-attr.esya-attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ext-system-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ext-system-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure ext-system-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'need-gen-new-xpack':U then do:     assign     p-news = no.   end.
            when 'FTP':U then do:     assign     p-news = yes.   end.
            when 'Login':U then do:     assign     p-news = yes.   end.
            when 'Password':U then do:     assign     p-news = yes.   end.
            when 'Path':U then do:     assign     p-news = yes.   end.
            when 'IN-dir':U then do:     assign     p-news = yes.   end.
            when 'OUT-dir':U then do:     assign     p-news = yes.   end.
            when 'cert-sign':U then do:     assign     p-news = yes.   end.
            when 'cert-sign-subject':U then do:     assign     p-news = yes.   end.
            when 'cert-sign-issuer':U then do:     assign     p-news = yes.   end.
            when 'cert-file-ext':U then do:     assign     p-news = yes.   end.
            when 'cert-repository':U then do:     assign     p-news = yes.   end.
            when 'ver-code':U then do:     assign     p-news = no.   end.
            when 'AuthToken':U then do:     assign     p-news = false.   end.
            when 'AuthTokenDT':U then do:     assign     p-news = false.   end.
            when 'host-code':U then do:     assign     p-news = false.   end.
            when 'obj':U then do:     assign     p-news = false.   end.
            when 'user-id':U then do:     assign     p-news = false.   end.
            when 'server-addr':U then do:     assign     p-news = false.   end.
            when 'proxy-addr':U then do:     assign     p-news = false.   end.
            when 'proxy-login':U then do:     assign     p-news = false.   end.
            when 'proxy-pswd':U then do:     assign     p-news = yes.   end.
            when 'proxy-ssl':U then do:     assign     p-news = false.   end.
            when 'AuthToken-send':U then do:     assign     p-news = false.   end.
            when 'mail-list':U then do:     assign     p-news = false.   end.
            when 'diadoc-user':U then do:     assign     p-news = false.   end.
            when 'diadoc-pwd':U then do:     assign     p-news = false.   end.
            when 'diadoc-key':U then do:     assign     p-news = false.   end.
            when 'diadoc-lastload':U then do:     assign     p-news = false.   end.
            when 'diadoc-ssl':U then do:     assign     p-news = false.   end.
            when 'reg-code':U then do:     assign     p-news = true.   end.
            when 'last-nws-sync':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure ext-system-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure ext-system-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure pck-attr-code :
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
    case p-code :
            when 'beg-imp-date':U then do:     assign     p-label = "Дата начала приема пакета"     p-type = 'T':U      p-format = "99.99.9999"     p-label = "Дата начала приема пакета"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'beg-imp-time':U then do:     assign     p-label = "Время начала разбора пакета"     p-type = 'I':U      p-format = ">>>>>>>>>9"     p-label = "Время начала разбора пакета"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ) .
      end.
    end.
  end.
end procedure.
procedure pck-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'beg-imp-date':U then do:     assign     p-tooltip = "Дата начала приема пакета"     p-label = "Дата начала приема пакета" .   end.
            when 'beg-imp-time':U then do:     assign     p-tooltip = "Время начала разбора пакета"     p-label = "Время начала разбора пакета" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ) .
      end.
    end.
  end.
end procedure.
procedure pck-attr-value :
  define input  parameter p-tbl-pck   as   character                   no-undo .
  define input  parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .
  define output parameter p-type      as   character                   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_pck-sent-attr for ub.pck-sent-attr .
    define buffer buf_pck-rcvd-attr for ub.pck-rcvd-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run pck-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-tbl-pck = "pck-rcvd":U then do:
      find first buf_pck-rcvd-attr no-lock
        where buf_pck-rcvd-attr.db-num    = p-db-num
          and buf_pck-rcvd-attr.pack-num  = p-pack-num
          and buf_pck-rcvd-attr.attr-code = p-code
        no-error .
      if available buf_pck-rcvd-attr then do:
        assign
          p-value = buf_pck-rcvd-attr.attr-value
        .
      end.
      else do:
        assign
          p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
    end.
    else do:
      find first buf_pck-sent-attr no-lock
        where buf_pck-sent-attr.db-num    = p-db-num
          and buf_pck-sent-attr.pack-num  = p-pack-num
          and buf_pck-sent-attr.attr-code = p-code
        no-error .
      if available buf_pck-sent-attr then do:
        assign
          p-value = buf_pck-sent-attr.attr-value
        .
      end.
      else do:
        assign
          p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
    end.
  end.
end procedure.
procedure pck-attr-write :
  define input parameter p-tbl-pck   as   character                   no-undo .
  define input parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define input parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .
  do
  on error undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1))
  :
    define buffer buf_pck-sent-attr for ub.pck-sent-attr .
    define buffer buf_pck-rcvd-attr for ub.pck-rcvd-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run pck-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1)) .
    end.
    if p-tbl-pck = "pck-rcvd":U then do:
      find first buf_pck-rcvd-attr exclusive-lock
        where buf_pck-rcvd-attr.db-num    = p-db-num
          and buf_pck-rcvd-attr.pack-num  = p-pack-num
          and buf_pck-rcvd-attr.attr-code = p-code
        no-error .
      if not available buf_pck-rcvd-attr then do:
        create buf_pck-rcvd-attr .
        assign
          buf_pck-rcvd-attr.db-num    = p-db-num
          buf_pck-rcvd-attr.pack-num  = p-pack-num
          buf_pck-rcvd-attr.attr-code = p-code
        .
      end.
      assign
        buf_pck-rcvd-attr.attr-value = p-value
      .
    end.
    else do:
      find first buf_pck-sent-attr exclusive-lock
        where buf_pck-sent-attr.db-num    = p-db-num
          and buf_pck-sent-attr.pack-num  = p-pack-num
          and buf_pck-sent-attr.attr-code = p-code
        no-error .
      if not available buf_pck-sent-attr then do:
        create buf_pck-sent-attr .
        assign
          buf_pck-sent-attr.db-num    = p-db-num
          buf_pck-sent-attr.pack-num  = p-pack-num
          buf_pck-sent-attr.attr-code = p-code
        .
      end.
      assign
        buf_pck-sent-attr.attr-value = p-value
      .
    end.
  end.
end procedure.
procedure pck-attr-exist :
  define input  parameter p-tbl-pck   as   character                   no-undo .
  define input  parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
    define buffer buf_pck-sent-attr for ub.pck-sent-attr .
    define buffer buf_pck-rcvd-attr for ub.pck-rcvd-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run pck-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-tbl-pck = "pck-rcvd":U then do:
      find first buf_pck-rcvd-attr no-lock
        where buf_pck-rcvd-attr.db-num    = p-db-num
          and buf_pck-rcvd-attr.pack-num  = p-pack-num
          and buf_pck-rcvd-attr.attr-code = p-code
        no-error .
      if available buf_pck-rcvd-attr then do:
        assign
          p-exist = yes
        .
      end.
    end.
    else do:
      find first buf_pck-sent-attr no-lock
        where buf_pck-sent-attr.db-num    = p-db-num
          and buf_pck-sent-attr.pack-num  = p-pack-num
          and buf_pck-sent-attr.attr-code = p-code
        no-error .
      if available buf_pck-sent-attr then do:
        assign
          p-exist = yes
        .
      end.
    end.
  end.
end procedure.
procedure pck-attr-delete :
  define input  parameter p-tbl-pck  as   character                   no-undo .
  define input  parameter p-db-num   like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code     like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
    define buffer buf_pck-sent-attr for ub.pck-sent-attr .
    define buffer buf_pck-rcvd-attr for ub.pck-rcvd-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run pck-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-tbl-pck = "pck-rcvd":U then do:
      find first buf_pck-rcvd-attr exclusive-lock
        where buf_pck-rcvd-attr.db-num    = p-db-num
          and buf_pck-rcvd-attr.pack-num  = p-pack-num
          and buf_pck-rcvd-attr.attr-code = p-code
        no-error NO-WAIT.
      if not available buf_pck-rcvd-attr then do:
        p-deleted = no.
      end.
      else do:
        delete buf_pck-rcvd-attr.
        p-deleted = yes.
      end.
    end.
    else do:
      find first buf_pck-sent-attr exclusive-lock
        where buf_pck-sent-attr.db-num    = p-db-num
          and buf_pck-sent-attr.pack-num  = p-pack-num
          and buf_pck-sent-attr.attr-code = p-code
        no-error NO-WAIT.
      if not available buf_pck-sent-attr then do:
        p-deleted = no.
      end.
      else do:
        delete buf_pck-sent-attr.
        p-deleted = yes.
      end.
    end.
  end.
end procedure.
procedure pck-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'beg-imp-date':U then do:     assign     p-news = no.   end.
            when 'beg-imp-time':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ) .
      end.
    end.
  end.
end procedure.
procedure pck-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'beg-imp-date':U then do:     assign     p-section-num = 0.   end.
            when 'beg-imp-time':U then do:     assign     p-section-num = 0.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure pck-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'beg-imp-date':U then do:     assign     p-section-num = 0.   end.
            when 'beg-imp-time':U then do:     assign     p-section-num = 0.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure ggoattr-code :
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
    case p-code :
            when 'NotCorrOP':U then do:     assign     p-label = "Запрет на корректировку автоматически рассчитанного заказа ОП"     p-type = 'L':U      p-format = "+/-"     p-label = "Запрет на корректировку автоматически рассчитанного заказа ОП"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'alc-min-price':U then do:     assign     p-label = "Правила определения минимальной цены алкоголя"     p-type = 'C':U      p-format = "X(256)"     p-label = "Правила определения минимальной цены алкоголя"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
                when 'marg-pr-paraf':U then do:     assign     p-label = "Правила определения наценки к цене внутреннего прихода партии"     p-type = 'C':U      p-format = "X(256)"     p-label = "Правила определения наценки к цене внутреннего прихода партии"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'level-dis':U then do:     assign     p-label = "Правила определения границ пороговой наценки"     p-type = 'C':U      p-format = "X(256)"     p-label = "Правила определения границ пороговой наценки"     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'no-inc-auto-rep':U then do:     assign     p-label = "Не учитывать в автоматической отчетности"     p-type = 'C':U      p-format = "X(256)"     p-label = "Не учитывать в автоматической отчетности"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'ban-sales-via-cd':U then do:     assign     p-label = "Запрет продажи через кассу"     p-type = 'C':U      p-format = "X(256)"     p-label = "Запрет продажи через кассу"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'alchol-grp':U then do:     assign     p-label = "По умолчанию алкоголь"     p-type = 'C':U      p-format = "X(256)"     p-label = "По умолчанию алкоголь"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'mark-grp':U then do:     assign     p-label = "По умолчанию обязательная маркировка"     p-type = 'C':U      p-format = "X(256)"     p-label = "По умолчанию обязательная маркировка"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'sum-grps':U then do:     assign     p-label = "Группа товаров на кассе"     p-type = 'I':U      p-format = "999"     p-label = "Группа товаров на кассе"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'gg-mark-type':U then do:     assign     p-label = "Тип маркировки"     p-type = 'C':U      p-format = "X(256)"     p-label = "Тип маркировки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'emrc-type':U then do:     assign     p-label = "Тип маркировки"     p-type = 'C':U      p-format = "X(256)"     p-label = "Тип маркировки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'NotCorrOP':U then do:     assign     p-tooltip = "Запрет на корректировку авт.рассчит.заказа ОП"     p-label = "Запрет на корректировку автоматически рассчитанного заказа ОП" .   end.
            when 'alc-min-price':U then do:     assign     p-tooltip = "Правила определения минимальной цены алкоголя"     p-label = "Правила определения минимальной цены алкоголя" .   end.
            when 'marg-pr-paraf':U then do:     assign     p-tooltip = "Правила определения наценки к цене внутреннего прихода партии"     p-label = "Правила определения наценки к цене внутреннего прихода партии" .   end.
            when 'level-dis':U then do:     assign     p-tooltip = "Правила определения границ пороговой наценки"     p-label = "Правила определения границ пороговой наценки" .   end.
            when 'no-inc-auto-rep':U then do:     assign     p-tooltip = "Не учитывать в автоматической отчетности"     p-label = "Не учитывать в автоматической отчетности" .   end.
            when 'ban-sales-via-cd':U then do:     assign     p-tooltip = "Запрет продажи через кассу"     p-label = "Запрет продажи через кассу" .   end.
            when 'alchol-grp':U then do:     assign     p-tooltip = "По умолчанию алкоголь"     p-label = "По умолчанию алкоголь" .   end.
            when 'mark-grp':U then do:     assign     p-tooltip = "По умолчанию обязательная маркировка"     p-label = "По умолчанию обязательная маркировка" .   end.
            when 'sum-grps':U then do:     assign     p-tooltip = "Группа товаров на кассе"     p-label = "Группа товаров на кассе" .   end.
            when 'gg-mark-type':U then do:     assign     p-tooltip = "Тип маркировки"     p-label = "Тип маркировки" .   end.
            when 'emrc-type':U then do:     assign     p-tooltip = "Тип маркировки"     p-label = "Тип маркировки" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code         like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value        like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type         as character no-undo .
  do
  on error undo, return error
  :
    define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run ggoattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = p-host-code
        and buf_gds-grp-obj-attr.obj-type    = p-obj-type
        and buf_gds-grp-obj-attr.obj-code    = p-obj-code
        and buf_gds-grp-obj-attr.attr-code   = p-code
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        p-value =  buf_gds-grp-obj-attr.attr-value
      .
    end.
    else do:
      if p-obj-type <> "" then do:
          find first buf_gds-grp-obj-attr no-lock
            where buf_gds-grp-obj-attr.node-code   = p-node-code
              and buf_gds-grp-obj-attr.host-code   = p-host-code
              and buf_gds-grp-obj-attr.obj-type    = ""
              and buf_gds-grp-obj-attr.obj-code    = 0
              and buf_gds-grp-obj-attr.attr-code   = p-code
            no-error .
          if available buf_gds-grp-obj-attr then do:
              assign
                p-value =  buf_gds-grp-obj-attr.attr-value
              .
          end.
          else do:
                find first buf_gds-grp-obj-attr no-lock
                  where buf_gds-grp-obj-attr.node-code   = p-node-code
                    and buf_gds-grp-obj-attr.host-code   = 0
                    and buf_gds-grp-obj-attr.obj-type    = ""
                    and buf_gds-grp-obj-attr.obj-code    = 0
                    and buf_gds-grp-obj-attr.attr-code   = p-code
                  no-error .
                if available buf_gds-grp-obj-attr then do:
                    assign
                      p-value =  buf_gds-grp-obj-attr.attr-value
                    .
                end.
                else do:
                   assign
                     p-value = if p-type = 'L':U then "no":U else ""
                   .
                 end.
           end.
      end.
      if p-obj-type = "" and p-host-code <> 0 then do:
          find first buf_gds-grp-obj-attr no-lock
            where buf_gds-grp-obj-attr.node-code   = p-node-code
              and buf_gds-grp-obj-attr.host-code   = 0
              and buf_gds-grp-obj-attr.obj-type    = ""
              and buf_gds-grp-obj-attr.obj-code    = 0
              and buf_gds-grp-obj-attr.attr-code   = p-code
            no-error .
          if available buf_gds-grp-obj-attr then do:
              assign
                p-value =  buf_gds-grp-obj-attr.attr-value
              .
          end.
          else do:
              assign
                p-value = if p-type = 'L':U then "no":U else ""
              .
          end.
      end.
      if p-obj-type = "" and p-host-code = 0 then do:
        assign
          p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1))
  :
    define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run ggoattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1)) .
    end.
    find first buf_gds-grp-obj-attr exclusive-lock
      where buf_gds-grp-obj-attr.node-code    = p-node-code
        and buf_gds-grp-obj-attr.host-code   = p-host-code
        and buf_gds-grp-obj-attr.obj-type    = p-obj-type
        and buf_gds-grp-obj-attr.obj-code    = p-obj-code
        and buf_gds-grp-obj-attr.attr-code = p-code
      no-error .
    if not available buf_gds-grp-obj-attr then do:
      create buf_gds-grp-obj-attr .
      assign
        buf_gds-grp-obj-attr.host-code   = p-host-code
        buf_gds-grp-obj-attr.obj-type    = p-obj-type
        buf_gds-grp-obj-attr.obj-code    = p-obj-code
        buf_gds-grp-obj-attr.node-code    = p-node-code
        buf_gds-grp-obj-attr.attr-code = p-code
      .
    end.
    assign
      buf_gds-grp-obj-attr.attr-value = p-value
    .
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
    define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run ggoattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code    = p-node-code
        and buf_gds-grp-obj-attr.host-code   = p-host-code
        and buf_gds-grp-obj-attr.obj-type    = p-obj-type
        and buf_gds-grp-obj-attr.obj-code    = p-obj-code
        and buf_gds-grp-obj-attr.attr-code = p-code
      no-error .
    if  available buf_gds-grp-obj-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
    define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run ggoattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-grp-obj-attr exclusive-lock
      where buf_gds-grp-obj-attr.node-code    = p-node-code
        and buf_gds-grp-obj-attr.host-code   = p-host-code
        and buf_gds-grp-obj-attr.obj-type    = p-obj-type
        and buf_gds-grp-obj-attr.obj-code    = p-obj-code
        and buf_gds-grp-obj-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_gds-grp-obj-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_gds-grp-obj-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'NotCorrOP':U then do:     assign     p-news = true.   end.
            when 'alc-min-price':U then do:     assign     p-news = true.   end.
                when 'marg-pr-paraf':U then do:     assign     p-news = true.   end.
            when 'level-dis':U then do:     assign     p-news = true.   end.
            when 'no-inc-auto-rep':U then do:     assign     p-news = true.   end.
            when 'ban-sales-via-cd':U then do:     assign     p-news = true.   end.
            when 'alchol-grp':U then do:     assign     p-news = true.   end.
            when 'mark-grp':U then do:     assign     p-news = true.   end.
            when 'sum-grps':U then do:     assign     p-news = true.   end.
            when 'gg-mark-type':U then do:     assign     p-news = true.   end.
            when 'emrc-type':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure assmatat-code :
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
    case p-code :
            when 'RootShablon':U then do:     assign     p-label = "Указание на шаблон"     p-type = 'C':U      p-format = "X(40)"     p-label = "Указание на шаблон"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'alchol-grp':U then do:     assign     p-label = "По умолчанию алкоголь"     p-type = 'C':U      p-format = "X(256)"     p-label = "По умолчанию алкоголь"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'mark-grp':U then do:     assign     p-label = "По умолчанию обязательная маркировка"     p-type = 'C':U      p-format = "X(256)"     p-label = "По умолчанию обязательная маркировка"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'sum-grps':U then do:     assign     p-label = "Группа товаров на кассе"     p-type = 'I':U      p-format = "999"     p-label = "Группа товаров на кассе"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'gg-mark-type':U then do:     assign     p-label = "Тип маркировки"     p-type = 'C':U      p-format = "X(256)"     p-label = "Тип маркировки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'emrc-type':U then do:     assign     p-label = "Тип маркировки"     p-type = 'C':U      p-format = "X(256)"     p-label = "Тип маркировки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure assmatat-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'RootShablon':U then do:     assign     p-tooltip = "Шаблон к которому привязана АссМатрица"     p-label = "Указание на шаблон" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure assmatat-value :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code         like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-value        like ub.assortment-matrix-attr.attr-value no-undo .
  define output parameter p-type         as character no-undo .
  do
  on error undo, return error
  :
    define buffer buf_assortment-matrix-attr for ub.assortment-matrix-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run assmatat-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_assortment-matrix-attr no-lock
        where  buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        and buf_assortment-matrix-attr.db-num        = p-db-num
        and buf_assortment-matrix-attr.attr-code     = p-code
      no-error .
    if available buf_assortment-matrix-attr then do:
      assign
        p-value =  buf_assortment-matrix-attr.attr-value
      .
    end.
    else do:
        assign
          p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
 end.
end procedure.
procedure assmatat-write :
  define input parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define input parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  do
  on error undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1))
  :
    define buffer buf_assortment-matrix-attr for ub.assortment-matrix-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run assmatat-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1)) .
    end.
    find first buf_assortment-matrix-attr exclusive-lock
      where
            buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        and buf_assortment-matrix-attr.db-num    = p-db-num
        and buf_assortment-matrix-attr.attr-code = p-code
      no-error .
    if not available buf_assortment-matrix-attr then do:
      create buf_assortment-matrix-attr .
      assign
        buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        buf_assortment-matrix-attr.db-num    = p-db-num
        buf_assortment-matrix-attr.attr-code = p-code
      .
    end.
    assign
      buf_assortment-matrix-attr.attr-value = p-value
    .
  end.
end procedure.
procedure assmatat-exist :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
    define buffer buf_assortment-matrix-attr for ub.assortment-matrix-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run assmatat-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_assortment-matrix-attr no-lock
      where
         buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        and buf_assortment-matrix-attr.db-num    = p-db-num
        and buf_assortment-matrix-attr.attr-code = p-code
      no-error .
    if  available buf_assortment-matrix-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure assmatat-delete :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code     like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
    define buffer buf_assortment-matrix-attr for ub.assortment-matrix-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run assmatat-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_assortment-matrix-attr exclusive-lock
      where
         buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        and buf_assortment-matrix-attr.db-num    = p-db-num
        and buf_assortment-matrix-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_assortment-matrix-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_assortment-matrix-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure assmatat-news :
define input  parameter p-code           as character no-undo .
define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'RootShablon':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure assmatat-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure assmatat-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure attr-write :
   define input  parameter iBuffHand as handle no-undo.
   define input  parameter iCode           as character no-undo .
   define input  parameter iValue          as character no-undo .
   do
   on error undo, return error
   :
      define variable vWhere as character no-undo.
      define variable vTables as character no-undo.
      define variable vTablesAttr as character no-undo.
      define variable vBhTbl as handle no-undo.
      define variable vGroupObj as character no-undo.
      vTables = iBuffHand:table.
      vTablesAttr = vTables + "-attr".
      run gen-where-keyr-tab  in this-procedure
                   (vTables + "-attr",
                    vTables,
                    vTables + "-attr",
                    iBuffHand,
                    "ub",
                    ?,
                    output vWhere).
      create buffer vBhTbl for table vTablesAttr .
      vGroupObj = iBuffHand:buffer-field ("GroupObj"):buffer-value ()no-error.
      if error-status:error
      then do:
         vBhTbl:find-first( substitute("&1 and &2.attr-code eq 'GroupObj'",vwhere,vTablesAttr), no-lock ) no-error .
         vGroupObj = if vBhTbl:available then vBhTbl:buffer-field ("attr-value"):buffer-value () else vTables.
      end.
      run attr-Check-group(vGroupObj,iCode,iValue) no-error.
      if error-status:error
      then
         return error return-value.
      find first xattr where Xattr.GroupObj-code eq  vGroupObj
                         and Xattr.Xattr-Code    eq  iCode
      no-lock no-error.
      if available  Xattr
      then do trans:
         vBhTbl:find-first( substitute("&1 and &2.attr-code eq '&3'",vwhere,vTablesAttr,iCode), exclusive-lock ) no-error .
         if vBhTbl:available
         then do:
            vBhTbl:buffer-field ("attr-value"):buffer-value () = iValue.
         end.
         else do :
            define variable v-field-list as character no-undo.
            define variable vi as integer no-undo.
            run gen-key-field in this-procedure ( input vTables
                                                 ,output v-field-list
                                              ).
            vBhTbl:buffer-create ().
            do vi = 1 to num-entries(v-field-list,chr(3)):
               vBhTbl:buffer-field (entry(vi,v-field-list,chr(3))):buffer-value () = iBuffHand:buffer-field (entry(vi,v-field-list,chr(3))):buffer-value ().
            end.
            vBhTbl:buffer-field ("attr-code") :buffer-value () =  iCode.
            vBhTbl:buffer-field ("attr-value"):buffer-value () =  if Xattr.Data-Type eq 'decimal':U
                                                                  then string(decimal (ivalue))
                                                                  else if Xattr.Data-Type eq 'date':U
                                                                  then string(date    (ivalue))
                                                                  else if Xattr.Data-Type eq 'integer':U
                                                                  then string(integer (ivalue))
                                                                  else if Xattr.Data-Type eq 'logical':U
                                                                  then string(logical (ivalue))
                                                                  else                 ivalue no-error.
            if error-status:error
            then
               return error error-status:get-message (1).
            vBhTbl:buffer-field ("attr-value"):buffer-value () = iValue.
         end.
      end.
      else do:
         return error substitute ("Для группы &1 нет реквизита",vGroupObj,iCode).
      end.
   end.
   finally:
      delete object vBhTbl no-error.
   end.
end procedure.
procedure attr-Check-group :
   define input  parameter iGroupObj       as character no-undo.
   define input  parameter iCode           as character no-undo .
   define input  parameter iValue          as character no-undo .
   do
   on error undo, return error
   :
      define variable vdec as character  no-undo.
      define variable vPos as integer no-undo.
      define variable vMaxDec as decimal no-undo init ?.
      define variable vMinDec as decimal no-undo init ?.
      define variable vMaxDat as date no-undo init ?.
      define variable vMinDat as date no-undo init ?.
      define variable vMaxStr as character  no-undo.
      define variable vMinStr as character  no-undo.
      define variable vValDec as decimal no-undo.
      define variable vValDat as date    no-undo.
      define variable vValLog as logical no-undo.
      find first xattr where Xattr.GroupObj-code eq  GroupObj
                         and Xattr.Xattr-Code    eq  iCode
      no-lock no-error.
      if available  Xattr
      then do:
         if Xattr.Data-Type eq 'decimal':U
         then do:
            vValDec = decimal (ivalue) no-error.
            if error-status:error
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
            if Xattr.Validation ne ""
            then do:
               vpos = index(Xattr.Validation,"<<").
               if vpos ne 0
               then do:
                  vminstr = substring(Xattr.Validation,1,vpos - 1).
                  vmaxStr = substring(Xattr.Validation,vpos + 2).
                  if vminstr ne ""
                  then
                     vmindec = decimal (vminstr)no-error.
                  if vmaxStr ne ""
                  then
                     vmaxdec = decimal (vmaxStr)no-error.
               end.
            end.
            vdec =  replace(entry(1,Xattr.Data-Format,"."),",","").
            if vdec begins "-"
            then do:
               assign
                  vmindec = decimal("-" + fill("9",length(vdec) - 1) + if Xattr.Accuracy > 0 then ("." + fill("9",Xattr.Accuracy)) else "" ) when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec) - 1) + if Xattr.Accuracy > 0 then ("." + fill("9",Xattr.Accuracy)) else "")  when vmaxdec eq ?
               .
            end.
            else
               assign
                  vmindec = 0                                                                                                               when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec)    ) + if Xattr.Accuracy > 0 then ("." + fill("9",Xattr.Accuracy)) else "") when vmaxdec eq ?
               .
            if vmindec > vValDec
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть больше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmindec,vValDec).
            if vmaxdec < vValDec
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть меньше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmaxdec,vValDec).
         end.
         else if Xattr.Data-Type eq 'date':U
         then do :
            vValDat = date (ivalue) no-error.
            if error-status:error
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
            if Xattr.Validation ne ""
            then do:
               vpos = index(Xattr.Validation,"<<").
               if vpos ne 0
               then do:
                  vminstr = substring(Xattr.Validation,1,vpos - 1).
                  vmaxStr = substring(Xattr.Validation,vpos + 2).
                  if vminstr ne ""
                  then
                     vmindat = date  (vminstr) no-error.
                  if vmaxStr ne ""
                  then
                     vmaxdat = date (vmaxStr) no-error.
                  if vmindat > vValDat
                  then
                     return error substitute ("Для группы &1 значение атрибута &2 должно быть больше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmindat,vValDat).
                  if vmaxdat < vValDat
                  then
                     return error substitute ("Для группы &1 значение атрибута &2 должно быть меньше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmaxdat,vValDat).
               end.
            end.
         end.
         else if Xattr.Data-Type eq 'integer':U
         then do:
            vValDec = integer (ivalue) no-error.
            if error-status:error
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
            if vValDec ne decimal (ivalue)
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть целым числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
            if Xattr.Validation ne ""
            then do:
               vpos = index(Xattr.Validation,"<<").
               if vpos ne 0
               then do:
                  vminstr = substring(Xattr.Validation,1,vpos - 1).
                  vmaxStr = substring(Xattr.Validation,vpos + 2).
                  if vminstr ne ""
                  then
                     vmindec = integer  (vminstr)no-error.
                  if vmaxStr ne ""
                  then
                     vmaxdec = integer (vmaxStr)no-error.
               end.
            end.
            vdec =  replace(entry(1,Xattr.Data-Format,"."),",","").
            if vdec begins "-"
            then do:
               assign
                  vmindec = decimal("-" + fill("9",length(vdec) - 1)  ) when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec) - 1)  ) when vmaxdec eq ?
               .
            end.
            else
               assign
                  vmindec = 0                                          when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec)    ) ) when vmaxdec eq ?
               .
            if vmindec > vValDec
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть больше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmindec,vValDec).
            if vmaxdec < vValDec
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть меньше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmaxdec,vValDec).
         end.
         else if Xattr.Data-Type eq 'logical':U
         then do:
            vValLog = logical (ivalue) no-error.
            if    error-status:error
               or (    Xattr.Validation ne ""
                   and num-entries(Xattr.Validation,"/") eq 2
                   and ivalue ne entry(1,Xattr.Validation,"/")
                   and ivalue ne entry(2,Xattr.Validation,"/"))
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
         end.
         else do:
            if Xattr.Domain-Code ne ""
            then do:
               define variable vParent as character no-undo.
               define variable vi      as integer no-undo.
               define variable vValStr as character no-undo.
               define buffer code for code.
               vParent = replace(Xattr.Domain-Code, "\", chr(4)).
               do vi = 1 to num-entries(ivalue):
                  vValStr = entry(vi,ivalue).
                  find first code where code.parent  eq  vParent
                                    and code.status_ ne 1
                                    and code.code    eq vValStr
                  no-lock no-error.
                  if not available code
                  then
                     return error substitute ("Для группы &1 значение атрибута &2 должно в справочнике &4. Переданное значение '&3'",iGroupObj,iCode,vValStr,Xattr.Domain-Code).
               end.
            end.
            if     Xattr.Validation ne ""
            then do:
               do vi = 1 to num-entries(ivalue):
                  vValStr = entry(vi,ivalue).
                  if not can-do(Xattr.Validation, vValStr)
                  then
                     return error substitute ("Для группы &1 значение атрибута &2 должно удовлетворять маске '&4'. Переданное значение '&3'",iGroupObj,iCode,vValStr,Xattr.Validation).
               end.
            end.
         end.
      end.
      else do:
         return error substitute ("Для группы &1 нет реквизита",iGroupObj,iCode).
      end.
   end.
end procedure.
procedure attr-read :
   define input   parameter iBuffHand as handle no-undo.
   define input   parameter iCode           as character no-undo .
   define output  parameter oValue          as character no-undo .
   do
   on error undo, return error
   :
      define variable vWhere as character no-undo.
      define variable vTables as character no-undo.
      define variable vTablesAttr as character no-undo.
      define variable vBhTbl as handle no-undo.
      vTables = iBuffHand:table.
      vTablesAttr = vTables + "-attr".
      run GenWhereKeyrTab in this-procedure
                   (vTables + "-attr",
                    vTables,
                    vTables + "-attr",
                    iBuffHand,
                    "ub",
                    ?,
                    output vWhere).
      create buffer vBhTbl for table vTablesAttr .
      oValue = iBuffHand:buffer-field (iCode):buffer-value ()no-error.
      if error-status:error
      then do:
         vBhTbl:find-first( substitute("&1 and &2.attr-code eq '&3'",vwhere,vTablesAttr,icode), no-lock ) no-error .
         oValue = if vBhTbl:available then vBhTbl:buffer-field ("attr-value"):buffer-value () else ?.
      end.
   end.
   finally:
      delete object vBhTbl no-error.
   end.
end procedure.
procedure isExemplarGoods:
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  define variable vAttrValue as character no-undo.
  define variable vAttrType  as character no-undo.
  define variable EDOParSec  as class ibs.th.gbl.env.prmtrs.edo .
  def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
  run gbl/getobjsrvhndl.p (input-output ObjSrv).
  run gds-attr-value in this-procedure
      (input  p-gds-code
      ,input  'mark-type':U
      ,output vAttrValue
      ,output vAttrType
      ) .
  if vAttrValue <> "" then
  do:
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
    o-result = EDOParSec:GetIsEDOForType(vAttrValue).
  end.
  else
    o-result = false.
end procedure.
procedure isVolumArticGoods:
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  define variable vAttrValue as character no-undo.
  define variable vAttrType  as character no-undo.
  define variable EDOParSec  as class ibs.th.gbl.env.prmtrs.edo .
  def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
  run gbl/getobjsrvhndl.p (input-output ObjSrv).
  run gds-attr-value in this-procedure
      (input  p-gds-code
      ,input  'mark-type':U
      ,output vAttrValue
      ,output vAttrType
      ) .
  if vAttrValue <> "" then
  do:
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
    o-result = EDOParSec:GetIsArticForType(vAttrValue).
  end.
  else
    o-result = false.
end procedure.
