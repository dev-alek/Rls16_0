block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clatrlst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/clatrlst.p $":U .
define variable vss-description as character no-undo init "ѕакетное изменение по списку атрибутов клиента".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов дл€ складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def shared temp-table cli-list no-undo like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table cli-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дн€" ] .
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
  return "ƒата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
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
define variable parhost-code like ub.sysconf.host-code no-undo .
define variable parobj-type like ub.clients.obj-type no-undo .
define variable parobj-code like ub.clients.obj-code no-undo .
define variable pardelete-ok as logical no-undo .
DEFINE VARIABLE var-object as character no-undo init 'clients-attr':U.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
def var vl_bin as char no-undo init "".
if vl_int < 0 OR vl_int = ? then return ?.
do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .
END FUNCTION.
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.
assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.
DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.
return yes.
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-attr no-undo
field attr-code like ub.gds-obj-attr.attr-code
field attr-value like ub.gds-obj-attr.attr-value
field host-code as integer
field obj-type as character
field obj-code as integer
field user-can-edit as log
field code as char
field action as logical
field other-inf as character
index pi is  unique primary
attr-code host-code obj-type obj-code ASCENDING
index action
action
.
procedure tempattr-value :
 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input  parameter p-host-code as integer no-undo .
    define input  parameter p-obj-type as character no-undo .
    define input  parameter p-obj-code as integer no-undo .
    define input  parameter p-mode      as character no-undo .
    define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_temp-attr for temp-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable jj               as integer   no-undo .
    define variable v-spr            as logical   no-undo .
    define variable v-spr-name       as character no-undo .
    define variable v-spr-param      as character no-undo .
    define variable v-setted         as logical   no-undo .
    case var-object:
      when 'gds-obj-attr':U
      then do:
        run gdsoattr-name in this-procedure
          (input  p-code
          ,output p-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'gds-host-attr':U
      then do:
        run gdshattr-name in this-procedure
          (input  p-code
          ,output p-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'clients-attr':U
      then do:
        run clntattr-code in this-procedure
          (input  p-code
          ,output p-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'goods-attr':U
      then do:
        run gds-attr-name in this-procedure
          (input  p-code
          ,output p-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    end case.
    if error-status :error
    then do:
      undo, return error return-value .
    end.
    if v-user-can-edit
    then do:
      do jj = 1 to num-entries(v-other, chr(47)):
        if entry(1, entry(jj, v-other, chr(47)), "=":U) = "spr":U then do:
          assign
          v-spr-name = entry(2, entry(jj, v-other, chr(47)), "=":U)
          .
        end.
        if entry(1, entry(jj, v-other, chr(47)), "=":U) = "spr-param":U then do:
          assign
          v-spr-param = entry(2, entry(jj, v-other, chr(47)), "=":U)
          .
        end.
     end.
      if v-spr-name <> "":U then do:
        if p-mode = "change":U
        then do:
          find first buf_temp-attr no-lock where
                    buf_temp-attr.attr-code = p-code
                and buf_temp-attr.host-code = p-host-code
                and buf_temp-attr.obj-type = p-obj-type
                and buf_temp-attr.obj-code = p-obj-code
            no-error .
          if avail buf_temp-attr then do:
            assign
              p-value =  buf_temp-attr.attr-value
            .
          end.
          else do:
            assign
              p-value = if p-type = 'L':U then "no":U else ""
            .
          end.
        end.
        CASE var-object:
          when 'gds-obj-attr':U then do:
            if v-spr-param = "":U then do:
              run value (
                          v-spr-name)
                          in this-procedure (
                                                input 0
                                              ,input parobj-type
                                              ,input parobj-code
                                              ,input-output p-value
                                              ,output v-setted) no-error .
            end.
            else do:
              run value (
                          v-spr-name)
                          in this-procedure (
                                                input 0
                                              ,input parobj-type
                                              ,input parobj-code
                                              ,input v-spr-param
                                              ,input-output p-value
                                              ,output v-setted) no-error .
            end.
            if error-status :error then do:
              undo, return error "Ќеизвестный справочник дл€ получени€ значени€ атрибут товара на объекте" + " " + p-code .
            end.
          end.
          when 'clients-attr':U then do:
          if v-spr-param = "":U then do:
            run   value ( v-spr-name ) in this-procedure
                (  input 0
                  ,input parobj-type
                  ,input parobj-code
                  ,input-output p-value
                  ,output v-setted )
                  no-error .
          end.
          end.
          END CASE.
        if v-setted = no then do:
          return "not-set":U.
        end.
        assign
        v-spr = yes
        .
      end.
    end.
    if not v-spr then do:
      find first buf_temp-attr no-lock where
                buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code
        no-error .
      if avail buf_temp-attr then do:
        assign
          p-value =  buf_temp-attr.attr-value
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
procedure tempattr-write :
  do
  on error undo, return error
  :
    define input parameter p-add      as logical no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define input parameter p-action   like temp-attr.action no-undo .
    define buffer buf_temp-attr for temp-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable var-region  as character no-undo.
    DEFINE VARIABLE v-sel-vals as character no-undo .
    DEFINE VARIABLE v-sel-labels as character no-undo .
    define variable varhost-code like ub.sysconf.host-code no-undo.
    define variable varobj-type like ub.clients.obj-type no-undo.
    define variable varobj-code like ub.clients.obj-code no-undo.
    define variable choice as integer no-undo .
    case var-object:
      when 'gds-obj-attr':U
      then do:
        run gdsoattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'gds-host-attr':U
      then do:
        run gdshattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'clients-attr':U
      then do:
        run clntattr-code in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'goods-attr':U
      then do:
        run gds-attr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.
    if error-status :error then do:
      undo, return error return-value .
    end.
    if not v-user-can-edit then do:
      message
      "«апрещено редактировать атрибут" v-label
      view-as alert-box error .
      undo, return error.
    end.
    find first buf_temp-attr exclusive-lock where
               buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code no-error .
    if not available buf_temp-attr then do:
      create buf_temp-attr .
      assign
        buf_temp-attr.attr-code = p-code
        buf_temp-attr.host-code = p-host-code
        buf_temp-attr.obj-type = p-obj-type
        buf_temp-attr.obj-code = p-obj-code
        buf_temp-attr.attr-value = p-value
        buf_temp-attr.action = p-action
        buf_temp-attr.code = v-label
        buf_temp-attr.other-inf = v-other
        no-error
      .
    end.
    ELSE
    ASSIGN
    buf_temp-attr.attr-value = p-value no-error.
  end.
end procedure.
procedure tempattr-exist :
  do
  on error undo, return error
  :
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define output parameter p-exist    as logical no-undo .
    define output parameter p-action as logical no-undo .
    define buffer buf_temp-attr for temp-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    case var-object:
      when 'gds-obj-attr':U then do:
        run gdsoattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'gds-host-attr':U
      then do:
        run gdshattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'clients-attr':U
      then do:
        run clntattr-code in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'goods-attr':U then do:
        run gds-attr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    end case.
    if error-status :error
    then do:
      undo, return error return-value .
    end.
    find first buf_temp-attr no-lock where
               buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code no-error .
    if available buf_temp-attr then do:
      P-EXIST = YES.
      p-action = buf_temp-attr.action.
    end.
  end.
end procedure.
procedure tempattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_temp-attr for temp-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    case var-object:
      when 'gds-obj-attr':U
      then do:
        run gdsoattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'gds-host-attr':U
      then do:
        run gdshattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'clients-attr':U
      then do:
        run clntattr-code in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'goods-attr':U
      then do:
        run gds-attr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-attr exclusive-lock where
               buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code no-error .
    if not available buf_temp-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_temp-attr.
       P-DELETED = YES.
    END.
  end.
end procedure.
define variable v-no-ask as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name                as character      no-undo init "clatrlst.txt".
define variable v-stop                       as logical        no-undo .
define variable v-choice as integer no-undo .
DEFINE VARIABLE num-rec as integer no-undo .
DEFINE VARIABLE num-rec-ok as integer no-undo .
define variable v-mes as character no-undo .
assign
parhost-code = integer(entry(1, p-parameter, chr(4)))
parobj-type  = entry(2, p-parameter, chr(4))
parobj-code = integer(entry(3, p-parameter, chr(4)))
pardelete-ok = logical(entry(4, p-parameter, chr(4)))
no-error
.
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("ќшибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!ѕри изменении атрибутов клиента по списку клиентов произошли ошибки!!!'  skip
  "!!!¬нимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action7   as character no-undo .
  define variable v-printed7       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!ѕри изменении атрибутов клиента по списку клиентов произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'clatrlst.txt')
    ,input  7
    ,output v-user-action7
    ,output v-printed7
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'clatrlst.txt').
end.
  return .
end.
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("»зменение атрибутов клиентов по списку клиентов")).
_cli-list:
for each cli-list No-LOCK ,
    first ub.clients No-LOCK WHERE
          ub.clients.obj-type = cli-list.obj-type AND
          ub.clients.obj-code = cli-list.obj-code
  ON ERROR undo, NEXT:
    num-rec = num-rec + 1.
    run do-changes in this-procedure (
                                       input ub.clients.obj-type
                                      ,input ub.clients.obj-code) no-error .
    if error-status:error then do:
      assign
      v-view-log = yes.
      run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input return-value
                                          ).
       if v-no-ask  then do:
        run gbl/d-askw.w (
                      input "»зменение атрибутов клиентов по списку"
                      ,input substitute("клиент &1&2 - не удалось провести изменение атрибутов клиента"
                                      , cli-list.obj-type
                                      , cli-list.obj-code
                                      )
                      ,input "|"
                      ,input ("ѕродолжить|" +
                            "ѕродолжить и больше не запрашивать подтверждени€ на продолжение|" +
                            "ѕрекратить")
                      ,input "||"
                      ,input 1
                      ,input 3
                      ,output v-choice).
        if v-choice = 3 then do:
          leave.
        end.
        if v-choice = 2 then do:
          assign
          v-no-ask = yes.
        end.
       end.
    end.
    else do:
      num-rec-ok = num-rec-ok + 1.
      if pardelete-ok then delete cli-list.
    end.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("ќбработано &1 из них успешно &2"
                                                , num-rec
                                                , num-rec-ok
                                                )) no-error.
    run get-stop-state in p-log-handle (
        output v-stop
    ).
    if v-stop then do:
      leave _cli-list.
    end.
END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("ѕакетное изменение атрибутов по списку клиентов завершено: из &1 клиентов списка успешно изменено &2", num-rec, num-rec-ok )).
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!ѕри изменении атрибутов клиентов по списку клиентов произошли ошибки!!!'  skip
  "!!!¬нимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action9   as character no-undo .
  define variable v-printed9       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!ѕри изменении атрибутов клиентов по списку клиентов произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'clatrlst.txt')
    ,input  7
    ,output v-user-action9
    ,output v-printed9
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'clatrlst.txt').
end.
procedure do-changes :
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-deleted as logical no-undo .
    _main:
  do
  on error undo, return error
  :
    for each temp-attr no-lock
        on error undo _main, return error:
      CASE temp-attr.action:
        when yes then do:
          run clntattr-write in this-procedure(
                                                input parobj-type,
                                                input parobj-code,
                                                input temp-attr.attr-code,
                                                input temp-attr.attr-value
                                                    )  no-error.
          IF ERROR-STATUS:ERROR THEN DO:
              assign v-mes = substitute("клиент &1&2: ошибка при записи атрибута клиента &3:&4&5 &6&4"  +                    "ќбратитесь к администратору системы"                     , cli-list.obj-type                    , cli-list.obj-code                     , temp-attr.attr-value                    , chr(10)                        , error-status:get-message(1)                    , return-value ).
              undo _main,   return error v-mes.
          END.
        end.
        when no then do:
          var-deleted = no.
          run clntattr-delete in this-procedure(
                                                input parobj-type,
                                                input parobj-code,
                                                input temp-attr.attr-code,
                                                output var-deleted
                                                    )  no-error.
          IF ERROR-STATUS:ERROR THEN DO:
              assign v-mes = substitute("клиент &1&2: ошибка при удалении атрибута клиента &3:&4&5 &6&4"  +                    "ќбратитесь к администратору системы"                     , cli-list.obj-type                    , cli-list.obj-code                     , temp-attr.attr-value                    , chr(10)                        , error-status:get-message(1)                    , return-value ).
              undo _main, return error v-mes.
          END.
        end.
      END CASE.
    end.
  end.
end procedure.
