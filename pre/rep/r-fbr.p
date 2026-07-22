block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle    no-undo.
define input parameter p-fbr-doc-recid      as recid     no-undo.
define input parameter p-print-in-rubl      as logical   no-undo.
define input parameter p-print-details      as logical   no-undo.
define input parameter p-fat                as logical   no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-fbr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-fbr.p $":U .
define variable vss-description as character no-undo init "Акт производства готовой продукции".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
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
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
function nutro_get-carbohydrate returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-carbohydrate as decimal   no-undo .
  run nutro_proc-get-carbohydrate in this-procedure ( input p-artic
                                                    , input p-prod-type
                                                    , input p-prod-code
                                                    , input p-obj-type
                                                    , input p-obj-code
                                                    , output v-carbohydrate
                                                    ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-carbohydrate = ?
    .
  end.
  return v-carbohydrate.
end function.
function nutro_get-fat returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-fat as decimal   no-undo .
  run nutro_proc-get-fat in this-procedure ( input p-artic
                                           , input p-prod-type
                                           , input p-prod-code
                                           , input p-obj-type
                                           , input p-obj-code
                                           , output v-fat
                                           ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-fat = ?
    .
  end.
  return v-fat.
end function.
function nutro_get-protein returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-protein as decimal   no-undo .
  run nutro_proc-get-protein in this-procedure ( input p-artic
                                               , input p-prod-type
                                               , input p-prod-code
                                               , input p-obj-type
                                               , input p-obj-code
                                               , output v-protein
                                               ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-protein = ?
    .
  end.
  return v-protein.
end function.
function nutro_get-calories returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-calories as decimal   no-undo .
  run nutro_proc-get-calories in this-procedure ( input  p-artic
                                                , input  p-prod-type
                                                , input  p-prod-code
                                                , input p-obj-type
                                                , input p-obj-code
                                                , output v-calories
                                                ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-calories = ?
    .
  end.
  return v-calories.
end function.
procedure nutro_proc-get-carbohydrate :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-carbohydrate  as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value   as character no-undo .
  define variable v-attr-type    as character no-undo .
  define variable v-calories     as decimal   no-undo .
  define variable v-protein      as decimal   no-undo .
  define variable v-carbohydrate as decimal   no-undo .
  define variable v-fat          as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-carbohydrate = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return .
  end.
  assign
    p-carbohydrate = v-carbohydrate
  .
end.
end procedure.
procedure nutro_proc-get-fat :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-fat           as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-fat = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return .
  end.
  assign
    p-fat = v-fat
  .
end.
end procedure.
procedure nutro_proc-get-protein :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-protein       as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value  as character no-undo .
  define variable v-attr-type   as character no-undo .
  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-protein = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return .
  end.
  assign
    p-protein = v-protein
  .
end.
end procedure.
procedure nutro_proc-get-calories :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-calories      as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-calories = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return .
  end.
  assign
    p-calories = v-calories
  .
end.
end procedure.
procedure nutro_get-nutrition-info :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-calories      as decimal   no-undo .
  define output parameter p-protein       as decimal   no-undo .
  define output parameter p-carbohydrate  as decimal   no-undo .
  define output parameter p-fat           as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-attr-code     as character no-undo .
  define variable v-exist         as logical   no-undo .
  define variable v-is-global     as logical   no-undo .
  define variable v-nutro-value   as decimal   no-undo .
  define buffer buf_fbr-gds-obj  for ub.fbr-gds-obj.
  define buffer buf_recipe       for ub.recipe.
do
on error undo, return error return-value
:
  assign
    p-carbohydrate  = ?
    p-fat           = ?
    p-protein       = ?
    p-calories      = ?
  .
  find first buf_goods no-lock
    where buf_goods.artic     = p-artic
      and buf_goods.prod-type = p-prod-type
      and buf_goods.prod-code = p-prod-code
  no-error .
  if not available buf_goods
  then do:
    return .
  end.
  assign
    v-is-global = yes
  .
  find first buf_fbr-gds-obj no-lock
    where buf_fbr-gds-obj.obj-type = p-obj-type
      and buf_fbr-gds-obj.obj-code = p-obj-code
      and buf_fbr-gds-obj.gds-code = buf_goods.gds-code
  no-error .
  if available buf_fbr-gds-obj
  then do:
    if  buf_fbr-gds-obj.is-semi-finished or
        buf_fbr-gds-obj.is-menu
    then do:
      assign
        v-is-global = no
      .
      find first buf_recipe no-lock
        where buf_recipe.recipe-code = buf_fbr-gds-obj.default-recipe-code
      no-error .
      if available buf_recipe
      then do:
        assign
          v-is-global = ( buf_recipe.host-code = 0    ) and
                        ( buf_recipe.obj-type  = "":U ) and
                        ( buf_recipe.obj-code  = 0    )
        .
      end.
    end.
  end.
  if v-is-global = yes
  then do:
    assign
      v-attr-code = 'calories':U
    .
    assign                       v-nutro-value = ?                     .                     run gds-attr-exist in this-procedure ( input  buf_goods.gds-code                                                          , input  v-attr-code                                                          , output v-exist                                                          ) no-error .                     if error-status :error = yes or                         v-exist = no                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     else do:                       run gds-attr-value in this-procedure ( input  buf_goods.gds-code                                                           , input  v-attr-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                       if error-status :error                       then do:                         assign                           v-nutro-value = ?                         .                       end.                       assign                         v-nutro-value = decimal( v-attr-value )                       no-error .                       if error-status :error = yes                       then do:                         assign                           v-nutro-value = ?                         .                       end.                     end.
    assign
      p-calories  = v-nutro-value
      v-attr-code = 'carbohydrate':U
    .
    assign                       v-nutro-value = ?                     .                     run gds-attr-exist in this-procedure ( input  buf_goods.gds-code                                                          , input  v-attr-code                                                          , output v-exist                                                          ) no-error .                     if error-status :error = yes or                         v-exist = no                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     else do:                       run gds-attr-value in this-procedure ( input  buf_goods.gds-code                                                           , input  v-attr-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                       if error-status :error                       then do:                         assign                           v-nutro-value = ?                         .                       end.                       assign                         v-nutro-value = decimal( v-attr-value )                       no-error .                       if error-status :error = yes                       then do:                         assign                           v-nutro-value = ?                         .                       end.                     end.
    assign
      p-carbohydrate  = v-nutro-value
      v-attr-code     = 'fat':U
    .
    assign                       v-nutro-value = ?                     .                     run gds-attr-exist in this-procedure ( input  buf_goods.gds-code                                                          , input  v-attr-code                                                          , output v-exist                                                          ) no-error .                     if error-status :error = yes or                         v-exist = no                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     else do:                       run gds-attr-value in this-procedure ( input  buf_goods.gds-code                                                           , input  v-attr-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                       if error-status :error                       then do:                         assign                           v-nutro-value = ?                         .                       end.                       assign                         v-nutro-value = decimal( v-attr-value )                       no-error .                       if error-status :error = yes                       then do:                         assign                           v-nutro-value = ?                         .                       end.                     end.
    assign
      p-fat       = v-nutro-value
      v-attr-code = 'protein':U
    .
    assign                       v-nutro-value = ?                     .                     run gds-attr-exist in this-procedure ( input  buf_goods.gds-code                                                          , input  v-attr-code                                                          , output v-exist                                                          ) no-error .                     if error-status :error = yes or                         v-exist = no                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     else do:                       run gds-attr-value in this-procedure ( input  buf_goods.gds-code                                                           , input  v-attr-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                       if error-status :error                       then do:                         assign                           v-nutro-value = ?                         .                       end.                       assign                         v-nutro-value = decimal( v-attr-value )                       no-error .                       if error-status :error = yes                       then do:                         assign                           v-nutro-value = ?                         .                       end.                     end.
    assign
      p-protein = v-nutro-value
    .
  end.
  else do:
    assign
      v-attr-code = 'calories-o':U
    .
    assign                      v-nutro-value = ?                    .                    run gdsoattr-exist in this-procedure ( input buf_goods.gds-code                                                         , input p-obj-type                                                         , input p-obj-code                                                         , input v-attr-code                                                         , output v-exist                                                         ) no-error .                    if error-status :error = yes or                       v-exist = no                    then do:                     assign                       v-nutro-value = ?                     .                    end.                    else do:                     run gdsoattr-value in this-procedure ( input  v-attr-code                                                           , input  buf_goods.gds-code                                                           , input  p-obj-type                                                           , input  p-obj-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     assign                       v-nutro-value = decimal(v-attr-value)                     no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                    end.
    assign
      p-calories  = v-nutro-value
      v-attr-code = 'carbohydrate-o':U
    .
    assign                      v-nutro-value = ?                    .                    run gdsoattr-exist in this-procedure ( input buf_goods.gds-code                                                         , input p-obj-type                                                         , input p-obj-code                                                         , input v-attr-code                                                         , output v-exist                                                         ) no-error .                    if error-status :error = yes or                       v-exist = no                    then do:                     assign                       v-nutro-value = ?                     .                    end.                    else do:                     run gdsoattr-value in this-procedure ( input  v-attr-code                                                           , input  buf_goods.gds-code                                                           , input  p-obj-type                                                           , input  p-obj-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     assign                       v-nutro-value = decimal(v-attr-value)                     no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                    end.
    assign
      p-carbohydrate  = v-nutro-value
      v-attr-code     = 'fat-o':U
    .
    assign                      v-nutro-value = ?                    .                    run gdsoattr-exist in this-procedure ( input buf_goods.gds-code                                                         , input p-obj-type                                                         , input p-obj-code                                                         , input v-attr-code                                                         , output v-exist                                                         ) no-error .                    if error-status :error = yes or                       v-exist = no                    then do:                     assign                       v-nutro-value = ?                     .                    end.                    else do:                     run gdsoattr-value in this-procedure ( input  v-attr-code                                                           , input  buf_goods.gds-code                                                           , input  p-obj-type                                                           , input  p-obj-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     assign                       v-nutro-value = decimal(v-attr-value)                     no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                    end.
    assign
      p-fat       = v-nutro-value
      v-attr-code = 'protein-o':U
    .
    assign                      v-nutro-value = ?                    .                    run gdsoattr-exist in this-procedure ( input buf_goods.gds-code                                                         , input p-obj-type                                                         , input p-obj-code                                                         , input v-attr-code                                                         , output v-exist                                                         ) no-error .                    if error-status :error = yes or                       v-exist = no                    then do:                     assign                       v-nutro-value = ?                     .                    end.                    else do:                     run gdsoattr-value in this-procedure ( input  v-attr-code                                                           , input  buf_goods.gds-code                                                           , input  p-obj-type                                                           , input  p-obj-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     assign                       v-nutro-value = decimal(v-attr-value)                     no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                    end.
    assign
      p-protein = v-nutro-value
    .
  end.
end.
end procedure.
do
on error undo, return error return-value
:
    define variable type-det as character init 'спи':U no-undo.
    define variable v-title                             as character    no-undo.
    define variable v-prices-string                     as character    no-undo.
    define variable v-write-off-title                   as character    no-undo.
    define variable v-income-title                      as character    no-undo.
    define variable v-write-off-doc                     as character    no-undo.
    define variable v-income-doc                        as character    no-undo.
    define variable v-doc-code                          as character    no-undo.
    define variable v-doc-date                          as date         no-undo.
    define variable v-barcode                           as character    no-undo.
    define variable v-is-waste                          as character    no-undo.
    define variable v-counter                           as integer      no-undo.
    define variable v-line-string                       as character    no-undo.
    define variable v-host-code                         as integer      no-undo.
    define variable v-print-sale                        as logical      no-undo.
    define variable v-sum-qnty                          as decimal      no-undo.
    define variable v-price-cost-rb                     as decimal      no-undo.
    define variable v-price-cost-not-rb                 as decimal      no-undo.
    define variable v-sum-cost-rb                       as decimal      no-undo.
    define variable v-sum-cost-not-rb                   as decimal      no-undo.
    define variable v-sum-cost-vat-rb                   as decimal      no-undo.
    define variable v-sum-cost-vat-not-rb               as decimal      no-undo.
    define variable v-price-sale                        as decimal      no-undo.
    define variable v-sum-sale                          as decimal      no-undo.
    define variable v-tot-sum-write-off-cost-rubl       as decimal      no-undo.
    define variable v-tot-sum-write-off-cost-base       as decimal      no-undo.
    define variable v-tot-sum-write-off-costvat-rubl    as decimal      no-undo.
    define variable v-tot-sum-write-off-costvat-base    as decimal      no-undo.
    define variable v-tot-sum-write-off-price           as decimal      no-undo.
    define variable v-tot-sum-income-cost-rubl          as decimal      no-undo.
    define variable v-tot-sum-income-cost-base          as decimal      no-undo.
    define variable v-tot-sum-income-cost-vat-rubl      as decimal      no-undo.
    define variable v-tot-sum-income-cost-vat-base      as decimal      no-undo.
    define variable v-tot-sum-income-price              as decimal      no-undo.
    define variable v-fat                               as decimal      no-undo.
    define variable v-calories                          as decimal      no-undo.
    define variable v-protein                           as decimal      no-undo.
    define variable v-carbohydrate                      as decimal      no-undo.
    define variable v-artic                             as character        no-undo.
    define variable v-gds-name                          as character        no-undo.
    define variable v-unit-base                         as character        no-undo.
    define variable v-rb-is-base                        as logical init no  no-undo.
    define buffer buf_fbr-doc   for ub.fbr-doc.
    define buffer buf_fbr-line  for ub.fbr-line.
    define buffer buf_goods     for ub.goods.
    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_clients for ub.clients.
define variable sym1  as character init "|"   no-undo.
define variable sym2  as character init "|"   no-undo.
define variable sym3  as character init "|"   no-undo.
define variable sym4  as character init "|"   no-undo.
define variable sym5  as character init "|"   no-undo.
define variable sym6  as character init "|"   no-undo.
define variable sym7  as character init "|"   no-undo.
define variable sym8  as character init "|"   no-undo.
define variable sym9  as character init "|"   no-undo.
define variable sym10 as character init "|"   no-undo.
define variable sym11 as character init "|"   no-undo.
define variable sym12 as character init "|"   no-undo.
define variable sym13 as character init "|"   no-undo.
define variable sym14 as character init "|"   no-undo.
define variable sym15 as character init "|"   no-undo.
define variable sym16 as character init "|"   no-undo.
define variable sym17 as character init "|"   no-undo.
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
    define stream Outstream.
define frame fbr-in-rb
    sym1                    column-label "|!|"                      format "X(1)"           space(0)
    v-counter               column-label "N!п/п"                    format ">>9"            space(0)
    sym2                    column-label "|!|"                      format "X(1)"           space(0)
    v-is-waste              column-label "Отх! "                    format "X(3)"           space(0)
    sym3                    column-label "|!|"                      format "X(1)"           space(0)
    v-barcode               column-label "Код! "                    format "X(10)" space(0)
    sym4                    column-label "|!|"                      format "X(1)"           space(0)
    v-artic                 column-label "Артикул! "                format "X(16)"          space(0)
    sym5                    column-label "|!|"                      format "X(1)"           space(0)
    v-gds-name              column-label "Название товара! "        format "X(39)"          space(0)
    sym6                    column-label "|!|"                      format "X(1)"           space(0)
    v-unit-base             column-label "Ед.!изм"                  format "X(3)"           space(0)
    sym7                    column-label "|!|"                      format "X(1)"           space(0)
    v-sum-qnty              column-label "Количество! "             format ">>,>>9.999"     space(0)
    sym8                    column-label "|!|"                      format "X(1)"           space(0)
    v-price-cost-rb         column-label "Уч.цена!без НДС"          format ">,>>>,>>9.99"   space(0)
    sym9                    column-label "|!|"                      format "X(1)"           space(0)
    v-sum-cost-rb           column-label "Сумма уч.цен!без НДС"     format ">>>,>>>,>>9.99" space(0)
    sym10                   column-label "|!|"                      format "X(1)"           space(0)
    v-sum-cost-vat-rb       column-label "Сумма НДС! "              format ">>>,>>>,>>9.99" space(0)
    sym11                   column-label "|!|"                      format "X(1)"           space(0)
    v-price-sale            column-label "Прод. цена! "             format ">,>>>,>>9.99"   space(0)
    sym12                   column-label "|!|"                      format "X(1)"           space(0)
    v-sum-sale              column-label "Сумма прод.!цен "         format ">>>,>>>,>>9.99" space(0)
    sym13                   column-label "|!|"                      format "X(1)"           space(0)
HEADER
    cur-time-print() at 5  format "X(35)"
           v-title at 45 format "X(60)"
           v-prices-string at 112 format "X(30)"
           string( "Страница " + string( page-number( OutStream ), ">>9" ) ) at  150 format "X(14)"
    skip v-line-string format  "X(163)" AT 1
with width 235 down stream-io NO-BOX.
define frame fbr-not-in-rb
    sym1                    column-label "|!|"                          format "X(1)"           space(0)
    v-counter               column-label "N!п/п"                        format ">>9"            space(0)
    sym2                    column-label "|!|"                          format "X(1)"           space(0)
    v-is-waste              column-label "Отх! "                        format "X(3)"           space(0)
    sym3                    column-label "|!|"                          format "X(1)"           space(0)
    v-barcode               column-label "Код! "                        format "X(10)" space(0)
    sym4                    column-label "|!|"                          format "X(1)"           space(0)
    v-artic                 column-label "Артикул! "                    format "X(16)"          space(0)
    sym5                    column-label "|!|"                          format "X(1)"           space(0)
    v-gds-name              column-label "Название товара! "            format "X(31)"          space(0)
    sym6                    column-label "|!|"                          format "X(1)"           space(0)
    v-unit-base             column-label "Ед.!изм"                      format "X(3)"           space(0)
    sym7                    column-label "|!|"                          format "X(1)"           space(0)
    v-sum-qnty              column-label "Количество! "                 format ">>,>>9.999"     space(0)
    sym8                    column-label "|!|"                          format "X(1)"           space(0)
    v-price-cost-not-rb     column-label "Уч.цена!без НДС"              format ">,>>>,>>9.99"   space(0)
    sym9                    column-label "|!|"                          format "X(1)"           space(0)
    v-sum-cost-not-rb       column-label "Сумма уч.цен!без НДС"         format ">>>,>>>,>>9.99" space(0)
    sym10                   column-label "|!|"                          format "X(1)"           space(0)
    v-sum-cost-vat-not-rb   column-label "Сумма НДС! "                  format ">>>,>>>,>>9.99" space(0)
    sym11                   column-label "|!|"                          format "X(1)"           space(0)
HEADER
    cur-time-print() at 5  format "X(35)"
           v-title at 45 format "X(60)"
           string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>9" ) ) at 114 format "X(14)"
    skip v-prices-string at 5 format "X(30)"
    skip v-line-string format  "X(127)" AT 1
with width 136 down stream-io NO-BOX.
define frame fbr-in-rb-fat
    sym1                    column-label "|!|"                      format "X(1)"           space(0)
    v-counter               column-label "N!п/п"                    format ">>9"            space(0)
    sym2                    column-label "|!|"                      format "X(1)"           space(0)
    v-is-waste              column-label "Отх! "                    format "X(3)"           space(0)
    sym3                    column-label "|!|"                      format "X(1)"           space(0)
    v-barcode               column-label "Код! "                    format "X(10)" space(0)
    sym4                    column-label "|!|"                      format "X(1)"           space(0)
    v-artic                 column-label "Артикул! "                format "X(16)"          space(0)
    sym5                    column-label "|!|"                      format "X(1)"           space(0)
    v-gds-name              column-label "Название товара! "        format "X(39)"          space(0)
    sym6                    column-label "|!|"                      format "X(1)"           space(0)
    v-unit-base             column-label "Ед.!изм"                  format "X(3)"           space(0)
    sym7                    column-label "|!|"                      format "X(1)"           space(0)
    v-sum-qnty              column-label "Количество! "             format ">>,>>9.999"     space(0)
    sym8                    column-label "|!|"                      format "X(1)"           space(0)
    v-price-cost-rb         column-label "Уч.цена!без НДС"          format ">,>>>,>>9.99"   space(0)
    sym9                    column-label "|!|"                      format "X(1)"           space(0)
    v-sum-cost-rb           column-label "Сумма уч.цен!без НДС"     format ">>>,>>>,>>9.99" space(0)
    sym10                   column-label "|!|"                      format "X(1)"           space(0)
    v-sum-cost-vat-rb       column-label "Сумма НДС! "              format ">>,>>>,>>9.99" space(0)
    sym11                   column-label "|!|"                      format "X(1)"           space(0)
    v-price-sale            column-label "Прод. цена! "             format ">,>>>,>>9.99"   space(0)
    sym12                   column-label "|!|"                      format "X(1)"           space(0)
    v-sum-sale              column-label "Сумма прод.!цен "         format ">>>,>>>,>>9.99" space(0)
    sym13                   column-label "|!|"                      format "X(1)"           space(0)
    v-calories              column-label "Калории! "                format ">>>>>>>9"       space(0)
    sym14                   column-label "|!|"                      format "X(1)"           space(0)
    v-protein               column-label "Белки! "                  format ">>>>>9.9"       space(0)
    sym15                   column-label "|!|"                      format "X(1)"           space(0)
    v-fat                   column-label "Жиры! "                   format ">>>>>9.9"       space(0)
    sym16                   column-label "|!|"                      format "X(1)"           space(0)
    v-carbohydrate          column-label "Углеводы! "               format ">>>>>9.9"       space(0)
    sym17                   column-label "|!|"                      format "X(1)"           space(0)
HEADER
    cur-time-print() at 5  format "X(35)"
           v-title at 45 format "X(60)"
           v-prices-string at 112 format "X(30)"
           string( "Страница " + string( page-number( OutStream ), ">>9" ) ) at  150 format "X(14)"
    skip v-line-string format  "X(198)" AT 1
with width 198 down stream-io NO-BOX.
define frame fbr-not-in-rb-fat
    sym1                    column-label "|!|"                          format "X(1)"           space(0)
    v-counter               column-label "N!п/п"                        format ">>9"            space(0)
    sym2                    column-label "|!|"                          format "X(1)"           space(0)
    v-is-waste              column-label "Отх! "                        format "X(3)"           space(0)
    sym3                    column-label "|!|"                          format "X(1)"           space(0)
    v-barcode               column-label "Код! "                        format "X(10)" space(0)
    sym4                    column-label "|!|"                          format "X(1)"           space(0)
    v-artic                 column-label "Артикул! "                    format "X(16)"          space(0)
    sym5                    column-label "|!|"                          format "X(1)"           space(0)
    v-gds-name              column-label "Название товара! "            format "X(31)"          space(0)
    sym6                    column-label "|!|"                          format "X(1)"           space(0)
    v-unit-base             column-label "Ед.!изм"                      format "X(3)"           space(0)
    sym7                    column-label "|!|"                          format "X(1)"           space(0)
    v-sum-qnty              column-label "Количество! "                 format ">>,>>9.999"     space(0)
    sym8                    column-label "|!|"                          format "X(1)"           space(0)
    v-price-cost-not-rb     column-label "Уч.цена!без НДС"              format ">,>>>,>>9.99"   space(0)
    sym9                    column-label "|!|"                          format "X(1)"           space(0)
    v-sum-cost-not-rb       column-label "Сумма уч.цен!без НДС"         format ">>>,>>>,>>9.99" space(0)
    sym10                   column-label "|!|"                          format "X(1)"           space(0)
    v-sum-cost-vat-not-rb   column-label "Сумма НДС! "                  format ">>,>>>,>>9.99"  space(0)
    sym11                   column-label "|!|"                          format "X(1)"           space(0)
    v-calories              column-label "Калории! "                    format ">>>>>>>9"       space(0)
    sym12                   column-label "|!|"                          format "X(1)"           space(0)
    v-protein               column-label "Белки! "                      format ">>>>>9.9"       space(0)
    sym13                   column-label "|!|"                          format "X(1)"           space(0)
    v-fat                   column-label "Жиры! "                       format ">>>>>9.9"       space(0)
    sym14                   column-label "|!|"                          format "X(1)"           space(0)
    v-carbohydrate          column-label "Углеводы! "                   format ">>>>>9.9"       space(0)
    sym15                   column-label "|!|"                          format "X(1)"           space(0)
HEADER
    cur-time-print() at 5  format "X(35)"
           v-title at 45 format "X(60)"
           string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>9" ) ) at 114 format "X(14)"
    skip v-prices-string at 5 format "X(30)"
    skip v-line-string format  "X(162)" AT 1
with width 198 down stream-io NO-BOX.
do
on error undo, return error
:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_fbr-doc no-lock
     where recid( buf_fbr-doc ) = p-fbr-doc-recid
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-host-code
  )  .
if ( v-rb-is-base = no  and p-print-in-rubl = yes )
or ( v-rb-is-base = yes and p-print-in-rubl = no  )
then do:
    assign
        v-print-sale = yes
    .
end.
else do:
    assign
        v-print-sale = no
    .
end.
if ( p-print-in-rubl = no and p-fat = no )
then do:
output stream Outstream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
end.
else do:
output stream Outstream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
end.
if session :set-wait-state( "compiler" ) then.
if p-fat
THEN DO:
   if v-print-sale = yes
   then do:
      assign
         v-line-string = fill( "-", 198 )
      .
   end.
   else do:
      assign
         v-line-string = fill( "-", 162 )
      .
   end.
END.
ELSE DO:
   if v-print-sale = yes
   then do:
      assign
         v-line-string = fill( "-", 163 )
      .
   end.
   else do:
      assign
         v-line-string = fill( "-", 127 )
      .
   end.
END.
form header
    v-line-string format "X(127)" at 1 skip
    "Продолжение - на следующей странице" at 30
with frame Bottomframe width 136 page-bottom no-labels no-box .
view stream Outstream frame Bottomframe .
find first buf_trn-doc no-lock
     where buf_trn-doc.out-code = buf_fbr-doc.doc-code
no-error.
assign
    v-doc-code      = buf_fbr-doc.doc-code
    v-doc-date      = ( if buf_fbr-doc.status_ = 'факт':U then buf_fbr-doc.fact-date else buf_fbr-doc.doc-date )
    v-write-off-doc = (if buf_fbr-doc.status_ = 'факт':U then string( "(по накладной N " + buf_fbr-doc.doc-code + ")" ) else "" )
    v-income-doc    = (if buf_fbr-doc.status_ = 'факт':U and available buf_trn-doc then string( "(по накладной N " + buf_trn-doc.doc-code + ")" ) else "" )
.
case buf_fbr-doc.doc-type:
    when 'разделка':U
    then do:
            assign
                v-title = "Акт производства полуфабрикатов N: " + v-doc-code + " от " +  string( v-doc-date, "99/99/9999" )
                v-write-off-title = "Товары, списанные для производства"
                type-det = 'при':U
            .
    end.
    when "Разукомплектация"
    then do:
            assign
                v-title = "Акт разукомплектации N: " + v-doc-code + " от " +  string( v-doc-date, "99/99/9999" )
                v-write-off-title = "Товары списанные"
                type-det = 'при':U
            .
    end.
    when 'производство':U
    then do:
            assign
                v-title = "Акт производства готовой продукции N: " + v-doc-code + " от " +  string( v-doc-date, "99/99/9999" )
                v-write-off-title = "Товары, списанные для производства"
                type-det = 'спи':U
            .
    end.
    when 'комплектация':U
    then do:
            assign
                v-title = "Акт комплектации N: " + v-doc-code + " от " +  string( v-doc-date, "99/99/9999" )
                v-write-off-title = "Товары списанные"
                type-det = 'спи':U
            .
    end.
end case.
assign
    v-prices-string = "Цены указаны в " + ( if p-print-in-rubl = yes then "рублях" else "базовой валюте" )
    v-income-title  = "Товары произведенные"
.
find first buf_clients no-lock
     where buf_clients.obj-type = buf_fbr-doc.obj-type
       and buf_clients.obj-code = buf_fbr-doc.obj-code
.
put stream Outstream
    string( "Объект: (" + buf_fbr-doc.obj-type + " " + string(buf_fbr-doc.obj-code) + ") " + '"' + trim(buf_clients.obj-name) + '"' ) format "X(160)"
    skip(2) space( 30 )
        caps( v-title ) format "X(160)"
    skip(2)
        string( caps( v-write-off-title ) + " " + v-write-off-doc )         format "X(160)"
    skip(1)
.
IF p-fat
THEN DO:
   if v-print-sale = yes
   then do:
      form with frame fbr-in-rb-fat.
   end.
   else do:
      form with frame fbr-not-in-rb-fat.
   end.
END.
ELSE DO:
   if v-print-sale = yes
   then do:
      form with frame fbr-in-rb.
   end.
   else do:
      form with frame fbr-not-in-rb.
   end.
END.
if p-print-details = yes
and type-det = 'спи':U
then do:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.trn-type = 'спи':U
    break by buf_fbr-line.recipe-code
    :
        assign
            v-counter = v-counter + 1
        .
        IF p-fat
        THEN DO:
            run nutro_get-nutrition-info in this-procedure ( input  buf_fbr-line.artic
                                                           , input  buf_fbr-line.prod-type
                                                           , input  buf_fbr-line.prod-code
                                                           , input  v-cntxt-obj-type
                                                           , input  v-cntxt-obj-code
                                                           , output v-calories
                                                           , output v-protein
                                                           , output v-carbohydrate
                                                           , output v-fat
                                                           ).
        END.
        ELSE DO:
            ASSIGN
              v-fat          = 0
              v-calories     = 0
              v-protein      = 0
              v-carbohydrate = 0
            .
        END.
        run print-fbr-line in this-procedure (
              input recid( buf_fbr-line )
            , input v-counter
            , input p-print-in-rubl
            , input buf_fbr-line.is-waste
            , input buf_fbr-line.fact-qnty
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            , input ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
            , input v-print-sale
            , input v-fat
            , input v-calories
            , input v-protein
            , input v-carbohydrate
        ).
        assign
            v-tot-sum-write-off-cost-rubl      = v-tot-sum-write-off-cost-rubl    + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            v-tot-sum-write-off-cost-base      = v-tot-sum-write-off-cost-base    + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            v-tot-sum-write-off-costvat-rubl   = v-tot-sum-write-off-costvat-rubl + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            v-tot-sum-write-off-costvat-base   = v-tot-sum-write-off-costvat-base + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            v-tot-sum-write-off-price          = v-tot-sum-write-off-price        + ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
        .
    end.
end.
else do:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.trn-type = 'спи':U
    break by string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) )
    :
        if first-of( string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) ) )
        then do:
            assign
                v-sum-qnty              = 0
                v-sum-cost-rb           = 0
                v-sum-cost-not-rb       = 0
                v-sum-cost-vat-rb       = 0
                v-sum-cost-vat-not-rb   = 0
                v-sum-sale              = 0
            .
        end.
        assign
            v-sum-qnty          = v-sum-qnty            + buf_fbr-line.fact-qnty
            v-sum-cost-rb     = v-sum-cost-rb       + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            v-sum-cost-not-rb     = v-sum-cost-not-rb       + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            v-sum-cost-vat-rb = v-sum-cost-vat-rb   + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            v-sum-cost-vat-not-rb = v-sum-cost-vat-not-rb   + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            v-sum-sale          = v-sum-sale            + ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
        .
        if last-of( string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) ) )
        then do:
            assign
                v-tot-sum-write-off-cost-rubl       = v-tot-sum-write-off-cost-rubl     + v-sum-cost-rb
                v-tot-sum-write-off-cost-base       = v-tot-sum-write-off-cost-base     + v-sum-cost-not-rb
                v-tot-sum-write-off-costvat-rubl    = v-tot-sum-write-off-costvat-rubl  + v-sum-cost-vat-rb
                v-tot-sum-write-off-costvat-base    = v-tot-sum-write-off-costvat-base  + v-sum-cost-vat-not-rb
                v-tot-sum-write-off-price           = v-tot-sum-write-off-price         + v-sum-sale
                v-counter = v-counter + 1
            .
            IF p-fat
            THEN DO:
              run nutro_get-nutrition-info in this-procedure ( input  buf_fbr-line.artic
                                                             , input  buf_fbr-line.prod-type
                                                             , input  buf_fbr-line.prod-code
                                                             , input  v-cntxt-obj-type
                                                             , input  v-cntxt-obj-code
                                                             , output v-calories
                                                             , output v-protein
                                                             , output v-carbohydrate
                                                             , output v-fat
                                                             ).
            END.
            ELSE DO:
                  ASSIGN
                     v-fat          = 0
                     v-calories     = 0
                     v-protein      = 0
                     v-carbohydrate = 0
                  .
            END.
            run print-fbr-line in this-procedure (
                  input recid( buf_fbr-line )
                , input v-counter
                , input p-print-in-rubl
                , input buf_fbr-line.is-waste
                , input v-sum-qnty
                , input v-sum-cost-rb
                , input v-sum-cost-not-rb
                , input v-sum-cost-vat-rb
                , input v-sum-cost-vat-not-rb
                , input v-sum-sale
                , input v-print-sale
                , input v-calories
                , input v-protein
                , input v-carbohydrate
                , input v-fat
            ).
        end.
    end.
end.
IF p-fat
THEN DO:
   if v-print-sale = yes
   then do:
      put stream outstream
         v-line-string   format "X(198)"
      .
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-cost-rubl
         else v-tot-sum-write-off-cost-base )    @ v-sum-cost-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-costvat-rubl
         else v-tot-sum-write-off-costvat-base ) @ v-sum-cost-vat-rb
         v-tot-sum-write-off-price               @ v-sum-sale
         with frame fbr-in-rb-fat.
      down stream outstream 1 with frame fbr-in-rb-fat.
   end.
   else do:
      put stream outstream
         v-line-string   format "X(162)"
      .
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-cost-rubl
         else v-tot-sum-write-off-cost-base )    @ v-sum-cost-not-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-costvat-rubl
         else v-tot-sum-write-off-costvat-base ) @ v-sum-cost-vat-not-rb
      with frame fbr-not-in-rb-fat.
      down stream outstream 1 with frame fbr-not-in-rb-fat.
   end.
END.
ELSE DO:
   if v-print-sale = yes
   then do:
      put stream outstream
         v-line-string   format "X(163)"
      .
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-cost-rubl
         else v-tot-sum-write-off-cost-base )    @ v-sum-cost-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-costvat-rubl
         else v-tot-sum-write-off-costvat-base ) @ v-sum-cost-vat-rb
         v-tot-sum-write-off-price               @ v-sum-sale
         with frame fbr-in-rb.
      down stream outstream 1 with frame fbr-in-rb.
   end.
   else do:
      put stream outstream
         v-line-string   format "X(127)"
      .
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-cost-rubl
         else v-tot-sum-write-off-cost-base )    @ v-sum-cost-not-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-costvat-rubl
         else v-tot-sum-write-off-costvat-base ) @ v-sum-cost-vat-not-rb
      with frame fbr-not-in-rb.
      down stream outstream 1 with frame fbr-not-in-rb.
   end.
END.
assign
    v-counter = 0
.
IF p-fat
THEN DO:
   if v-print-sale
   then do:
      put stream Outstream
         skip
         string( caps( v-income-title ) + " " + v-income-doc ) format "X(198)"
         skip(1)
         v-line-string   format "X(198)"
      .
      form with frame fbr-in-rb-fat.
   end.
   else do:
      put stream Outstream
         skip
         string( caps( v-income-title ) + " " + v-income-doc ) format "X(162)"
         skip(1)
         v-line-string   format "X(162)"
      .
      form with frame fbr-not-in-rb-fat.
   end.
end.
ELSE DO:
   if v-print-sale
   then do:
      put stream Outstream
         skip
         string( caps( v-income-title ) + " " + v-income-doc ) format "X(163)"
         skip(1)
         v-line-string   format "X(163)"
      .
      form with frame fbr-in-rb.
   end.
   else do:
      put stream Outstream
         skip
         string( caps( v-income-title ) + " " + v-income-doc ) format "X(127)"
         skip(1)
         v-line-string   format "X(127)"
      .
      form with frame fbr-not-in-rb.
   end.
END.
if p-print-details = yes
and type-det = 'при':U
then do:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.trn-type = 'при':U
    break by buf_fbr-line.recipe-code
    :
        assign
            v-counter = v-counter + 1
        .
         IF p-fat
         THEN DO:
            run nutro_get-nutrition-info in this-procedure ( input  buf_fbr-line.artic
                                                           , input  buf_fbr-line.prod-type
                                                           , input  buf_fbr-line.prod-code
                                                           , input  v-cntxt-obj-type
                                                           , input  v-cntxt-obj-code
                                                           , output v-calories
                                                           , output v-protein
                                                           , output v-carbohydrate
                                                           , output v-fat
                                                           ).
         END.
         ELSE DO:
               ASSIGN
                  v-fat          = 0
                  v-calories     = 0
                  v-protein      = 0
                  v-carbohydrate = 0
               .
         END.
        run print-fbr-line in this-procedure (
              input recid( buf_fbr-line )
            , input v-counter
            , input p-print-in-rubl
            , input buf_fbr-line.is-waste
            , input buf_fbr-line.fact-qnty
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            , input ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale )
            , input v-print-sale
            , input v-fat
            , input v-calories
            , input v-protein
            , input v-carbohydrate
        ).
        assign
            v-tot-sum-income-cost-rubl      = v-tot-sum-income-cost-rubl        + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            v-tot-sum-income-cost-base      = v-tot-sum-income-cost-base        + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            v-tot-sum-income-cost-vat-rubl  = v-tot-sum-income-cost-vat-rubl    + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            v-tot-sum-income-cost-vat-base  = v-tot-sum-income-cost-vat-base    + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            v-tot-sum-income-price          = v-tot-sum-income-price            + ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
        .
    end.
end.
else do:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.trn-type = 'при':U
    break by string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) )
    :
        if first-of( string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) ) )
        then do:
            assign
                v-sum-qnty          = 0
                v-sum-cost-rb     = 0
                v-sum-cost-not-rb     = 0
                v-sum-cost-vat-rb = 0
                v-sum-cost-vat-not-rb = 0
                v-sum-sale          = 0
            .
        end.
        assign
            v-sum-qnty          = v-sum-qnty            + buf_fbr-line.fact-qnty
            v-sum-cost-rb     = v-sum-cost-rb       + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            v-sum-cost-not-rb     = v-sum-cost-not-rb       + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            v-sum-cost-vat-rb = v-sum-cost-vat-rb   + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            v-sum-cost-vat-not-rb = v-sum-cost-vat-not-rb   + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            v-sum-sale          = v-sum-sale            + ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
        .
        if last-of( string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) ) )
        then do:
            assign
                v-tot-sum-income-cost-rubl      = v-tot-sum-income-cost-rubl        + v-sum-cost-rb
                v-tot-sum-income-cost-base      = v-tot-sum-income-cost-base        + v-sum-cost-not-rb
                v-tot-sum-income-cost-vat-rubl  = v-tot-sum-income-cost-vat-rubl    + v-sum-cost-vat-rb
                v-tot-sum-income-cost-vat-base  = v-tot-sum-income-cost-vat-base    + v-sum-cost-vat-not-rb
                v-tot-sum-income-price          = v-tot-sum-income-price            + v-sum-sale
                v-counter                       = v-counter + 1
            .
            IF p-fat
            THEN DO:
              run nutro_get-nutrition-info in this-procedure ( input  buf_fbr-line.artic
                                                             , input  buf_fbr-line.prod-type
                                                             , input  buf_fbr-line.prod-code
                                                             , input  v-cntxt-obj-type
                                                             , input  v-cntxt-obj-code
                                                             , output v-calories
                                                             , output v-protein
                                                             , output v-carbohydrate
                                                             , output v-fat
                                                             ).
            END.
            ELSE DO:
                  ASSIGN
                     v-fat          = 0
                     v-calories     = 0
                     v-protein      = 0
                     v-carbohydrate = 0
                  .
            END.
            run print-fbr-line in this-procedure (
                  input recid( buf_fbr-line )
                , input v-counter
                , input p-print-in-rubl
                , input buf_fbr-line.is-waste
                , input v-sum-qnty
                , input v-sum-cost-rb
                , input v-sum-cost-not-rb
                , input v-sum-cost-vat-rb
                , input v-sum-cost-vat-not-rb
                , input v-sum-sale
                , input v-print-sale
                , input v-calories
                , input v-protein
                , input v-carbohydrate
                , input v-fat
            ).
        end.
    end.
end.
IF p-fat
THEN DO:
   if v-print-sale = yes
   then do:
      if line-counter( Outstream ) <> 1
      then do:
        put stream outstream
          v-line-string format "X(198)"
        .
      end.
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-rubl
         else v-tot-sum-income-cost-base )     @ v-sum-cost-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-vat-rubl
         else v-tot-sum-income-cost-vat-base ) @ v-sum-cost-vat-rb
         v-tot-sum-income-price                @ v-sum-sale
         with frame fbr-in-rb-fat.
      down stream outstream 2 with frame fbr-in-rb-fat.
   end.
   else do:
      if line-counter( Outstream ) <> 1
      then do:
        put stream outstream
          v-line-string format "X(162)"
        .
      end.
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-rubl
         else v-tot-sum-income-cost-base )     @ v-sum-cost-not-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-vat-rubl
         else v-tot-sum-income-cost-vat-base )  @ v-sum-cost-vat-not-rb
      with frame fbr-not-in-rb-fat.
      down stream outstream 2 with frame fbr-not-in-rb-fat.
   end.
END.
ELSE DO:
   if v-print-sale = yes
   then do:
      if line-counter( Outstream ) <> 1
      then do:
        put stream outstream
          v-line-string format "X(163)"
        .
      end.
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-rubl
         else v-tot-sum-income-cost-base )     @ v-sum-cost-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-vat-rubl
         else v-tot-sum-income-cost-vat-base ) @ v-sum-cost-vat-rb
         v-tot-sum-income-price                @ v-sum-sale
         with frame fbr-in-rb.
      down stream outstream 2 with frame fbr-in-rb.
   end.
   else do:
      if line-counter( Outstream ) <> 1
      then do:
        put stream outstream
          v-line-string format "X(127)"
        .
      end.
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-rubl
         else v-tot-sum-income-cost-base )     @ v-sum-cost-not-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-vat-rubl
         else v-tot-sum-income-cost-vat-base )  @ v-sum-cost-vat-not-rb
      with frame fbr-not-in-rb.
      down stream outstream 2 with frame fbr-not-in-rb.
   end.
END.
if v-print-sale = yes
then do:
    if line-counter( Outstream ) + 11 > page-size( Outstream )
    then do:
        page stream Outstream .
    end.
end.
else do:
    if line-counter( Outstream ) + 8 > page-size( Outstream )
    then do:
        page stream Outstream .
    end.
end.
put stream Outstream
    "Всего списано товаров (в учетных ценах) на сумму" ": " at 57
    ( if p-print-in-rubl = no
      then v-tot-sum-write-off-cost-base + v-tot-sum-write-off-costvat-base
      else v-tot-sum-write-off-cost-rubl + v-tot-sum-write-off-costvat-rubl
    ) format ">>>,>>>,>>>,>>>,>>9.99"
    skip
    "Всего произведено товаров (в учетных ценах) на сумму" ": " at 57
    ( if p-print-in-rubl = no
      then v-tot-sum-income-cost-base + v-tot-sum-income-cost-vat-base
      else v-tot-sum-income-cost-rubl + v-tot-sum-income-cost-vat-rubl
    ) format ">>>,>>>,>>>,>>>,>>9.99"
    skip(1)
.
if v-print-sale = yes
then do:
    put stream Outstream
        "Всего списано товаров (в продажных ценах) на сумму" ": " at 57 v-tot-sum-write-off-price format ">>>,>>>,>>>,>>>,>>9.99"
        skip
        "Всего произведено товаров (в продажных ценах) на сумму" ": " at 57 v-tot-sum-income-price  format ">>>,>>>,>>>,>>>,>>9.99"
        skip(1)
    .
end.
    put stream Outstream
        "Материально ответственное лицо: ____________________ "
        skip(1)
        "Бухгалтер: ____________________ "
        skip(1)
        "Обработал: ____________________ "
        skip(1)
    .
    hide stream Outstream frame Bottomframe .
    output stream Outstream close.
if session :set-wait-state( "" ) then.
    define variable v-user-action           as character            no-undo.
    define variable v-printed               as logical              no-undo.
    if v-print-sale = yes or p-fat = yes
    then do:
        run gbl/prnfilen.w (
              input "":U
            , input 8
            , input string( session :temp-directory ) + "rpt" + string( g#report-num )
            , input 7
            , output v-user-action
            , output v-printed
        ) .
    end.
    else do:
        run gbl/prnfilen.w (
              input "":U
            , input 0
            , input string( session :temp-directory ) + "rpt" + string( g#report-num )
            , input 7
            , output v-user-action
            , output v-printed
        ) .
    end.
end.
end.
procedure print-fbr-line :
do
on error undo, return error
:
define input parameter p-fbr-line-recid     as recid        no-undo.
define input parameter p-counter            as integer      no-undo.
define input parameter p-print-in-rubl      as logical      no-undo.
define input parameter p-is-waste           as logical      no-undo.
define input parameter p-fact-qnty          as decimal      no-undo.
define input parameter p-sum-cost-rubl      as decimal      no-undo.
define input parameter p-sum-cost-base      as decimal      no-undo.
define input parameter p-sum-cost-vat-rubl  as decimal      no-undo.
define input parameter p-sum-cost-vat-base  as decimal      no-undo.
define input parameter p-sum-sale           as decimal      no-undo.
define input parameter p-print-price-sale   as logical      no-undo.
define input parameter p-calories           as decimal      no-undo.
define input parameter p-protein            as decimal      no-undo.
define input parameter p-carbohydrate       as decimal      no-undo.
define input parameter p-fat-1              as decimal      no-undo.
    define variable v-bar-code              as character     no-undo.
    define variable v-print-sum-cost        as decimal       no-undo.
    define variable v-print-sum-cost-vat    as decimal       no-undo.
    define buffer buf_fbr-line  for ub.fbr-line.
    define buffer buf_goods     for ub.goods.
    find first buf_fbr-line no-lock
        where recid( buf_fbr-line ) = p-fbr-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_fbr-line.artic
           and buf_goods.prod-type  = buf_fbr-line.prod-type
           and buf_goods.prod-code  = buf_fbr-line.prod-code
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
 .
    if p-print-in-rubl = yes
    then do:
        assign
            v-print-sum-cost        =  p-sum-cost-rubl
            v-print-sum-cost-vat    =  p-sum-cost-vat-rubl
        .
    end.
    else do:
        assign
            v-print-sum-cost        = p-sum-cost-base
            v-print-sum-cost-vat    = p-sum-cost-vat-base
        .
    end.
    IF p-fat
    THEN DO:
      if p-print-price-sale = yes
      then do:
         display stream OutStream
               sym1 p-counter                                                  @ v-counter
               sym2 " О"                       when p-is-waste = yes           @ v-is-waste
               sym3 string( v-bar-code )                                       @ v-barcode
               sym4 buf_fbr-line.artic                                         @ v-artic
               sym5 buf_goods.gds-name                                         @ v-gds-name
               sym6 buf_goods.unit-base                                        @ v-unit-base
               sym7 p-fact-qnty                                                @ v-sum-qnty
               sym8 v-print-sum-cost / p-fact-qnty                              @ v-price-cost-rb
               sym9 v-print-sum-cost                                            @ v-sum-cost-rb
               sym10 v-print-sum-cost-vat                                       @ v-sum-cost-vat-rb
               sym11
               sym12 p-sum-sale                                                @ v-sum-sale
               sym13 p-calories     @ v-calories
               sym14 p-protein      @ v-protein
               sym15 p-fat-1        @ v-fat
               sym16 p-carbohydrate @ v-carbohydrate
               sym17
         with frame fbr-in-rb-fat.
         down stream OutStream 1 with frame fbr-in-rb-fat.
      end.
      else do:
         display stream OutStream
               sym1 p-counter                                                  @ v-counter
               sym2 " О"                       when p-is-waste = yes           @ v-is-waste
               sym3 string( v-bar-code )                                       @ v-barcode
               sym4 buf_fbr-line.artic                                         @ v-artic
               sym5 buf_goods.gds-name                                         @ v-gds-name
               sym6 buf_goods.unit-base                                        @ v-unit-base
               sym7 p-fact-qnty                                                @ v-sum-qnty
               sym8 v-print-sum-cost / p-fact-qnty                              @ v-price-cost-not-rb
               sym9 v-print-sum-cost                                            @ v-sum-cost-not-rb
               sym10 v-print-sum-cost-vat                                       @ v-sum-cost-vat-not-rb
               sym11 p-calories     @ v-calories
               sym12 p-protein      @ v-protein
               sym13 p-fat-1        @ v-fat
               sym14 p-carbohydrate @ v-carbohydrate
               sym15
         with frame fbr-not-in-rb-fat.
         down stream OutStream 1 with frame fbr-not-in-rb-fat.
      end.
    END.
    ELSE DO:
      if p-print-price-sale = yes
      then do:
         display stream OutStream
               sym1 p-counter                                                  @ v-counter
               sym2 " О"                       when p-is-waste = yes           @ v-is-waste
               sym3 string( v-bar-code )                                       @ v-barcode
               sym4 buf_fbr-line.artic                                         @ v-artic
               sym5 buf_goods.gds-name                                         @ v-gds-name
               sym6 buf_goods.unit-base                                        @ v-unit-base
               sym7 p-fact-qnty                                                @ v-sum-qnty
               sym8 v-print-sum-cost / p-fact-qnty                              @ v-price-cost-rb
               sym9 v-print-sum-cost                                            @ v-sum-cost-rb
               sym10 v-print-sum-cost-vat                                       @ v-sum-cost-vat-rb
               sym11 p-sum-sale / p-fact-qnty                                  @ v-price-sale
               sym12 p-sum-sale                                                @ v-sum-sale
               sym13
         with frame fbr-in-rb.
         down stream OutStream 1 with frame fbr-in-rb.
      end.
      else do:
         display stream OutStream
               sym1 p-counter                                                  @ v-counter
               sym2 " О"                       when p-is-waste = yes           @ v-is-waste
               sym3 string( v-bar-code )                                       @ v-barcode
               sym4 buf_fbr-line.artic                                         @ v-artic
               sym5 buf_goods.gds-name                                         @ v-gds-name
               sym6 buf_goods.unit-base                                        @ v-unit-base
               sym7 p-fact-qnty                                                @ v-sum-qnty
               sym8 v-print-sum-cost / p-fact-qnty                              @ v-price-cost-not-rb
               sym9 v-print-sum-cost                                            @ v-sum-cost-not-rb
               sym10 v-print-sum-cost-vat                                       @ v-sum-cost-vat-not-rb
               sym11
         with frame fbr-not-in-rb.
         down stream OutStream 1 with frame fbr-not-in-rb.
      end.
    END.
    if line-counter( Outstream ) + 2 > page-size( Outstream )
    then do:
      if p-fat
      then do:
        if v-print-sale = yes
        then do:
          put stream outstream
            v-line-string format "X(198)"
          .
        end.
        else do:
          put stream outstream
            v-line-string format "X(162)"
          .
        end.
      end.
      else do:
        if v-print-sale = yes
        then do:
          put stream outstream
            v-line-string format "X(163)"
          .
        end.
        else do:
          put stream outstream
            v-line-string format "X(127)"
          .
        end.
      end.
      page stream Outstream .
    end.
end.
end procedure.
