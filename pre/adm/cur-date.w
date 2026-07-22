define input  parameter parParentProc   as widget-handle    no-undo.
define input  parameter p-obj-type      as character        no-undo .
define input  parameter p-obj-code      as integer          no-undo .
define input  parameter p-date-change   as character        no-undo .
define output parameter p-error-code    as integer          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запрос текущей даты".
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
      p-vss-parameters = substitute('&1|&2|&3':u,p-obj-type,p-obj-code,p-date-change)
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
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
      .
      if v-curr-sv-date = ?
      then do:
        run gbl/getcurdt.p
          (output v-curr-sv-date
          ) .
      end.
      if v-curr-sv-date <> ?
      then do:
        run gbl/d-inpday.w
          (input ?
          ,input "Выбор даты"
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable v-today                 as date                    no-undo.
define variable v-time                  as integer                 no-undo.
define variable v-obj-date              as date                    no-undo.
define variable v-allow-date-change     as logical                 no-undo.
define variable v-auto-date-change      as logical                 no-undo.
define variable v-conf-parameter-string as character               no-undo.
define variable v-obj-date-is-from-base as logical init yes        no-undo.
define variable v-shift-obj-on          as logical                 no-undo.
define variable v-shift-start-date      as date                    no-undo.
define variable v-max-shift-days        as integer                 no-undo.
define variable v-par-type              as character               no-undo.
define variable v-shift-num             as integer                 no-undo.
define variable v-shift-name            as character               no-undo.
define variable v-void-date             as date                    no-undo.
define variable v-endkey-error          as logical init no         no-undo.
define variable v-exit-enabled          as logical init no         no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer buf_obj-date      for ub.obj-date.
DEFINE BUTTON b-choose-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-date"
     SIZE 3 BY .88.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ed-info AS CHARACTER
     VIEW-AS EDITOR
     SIZE 36.38 BY 3.29
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE cur-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(256)":U INITIAL "Текущая дата:"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE FRAME d-cur-date
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     ed-info AT ROW 2.5 COL 1 NO-LABEL
     cur-date AT ROW 6.46 COL 14.13 COLON-ALIGNED NO-LABEL
     b-choose-date AT ROW 6.54 COL 28.75
     fi-description AT ROW 6.67 COL 1.38 NO-LABEL
     SPACE(23.48) SKIP(0.94)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод даты"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-cur-date:SCROLLABLE       = FALSE
       FRAME d-cur-date:HIDDEN           = TRUE.
ASSIGN
       ed-info:READ-ONLY IN FRAME d-cur-date        = TRUE.
ON WINDOW-CLOSE OF FRAME d-cur-date
DO:
    if v-exit-enabled = no
    then do:
        return no-apply.
    end.
    APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-choose-date IN FRAME d-cur-date
DO:
  run sel-date in this-procedure
    (input cur-date :handle
    ,input replace(ed-info :screen-value, chr(10), '. ') + chr(10) +
           'Новая дата: &1'
    ) .
END.
ON CHOOSE OF b-quit IN FRAME d-cur-date
DO:
  define variable v-ok as logical   no-undo .
  assign
    cur-date
  .
  if cur-date <> ?
  then do:
    message
      "Отказаться от изменения даты?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.
  end.
  assign
    v-endkey-error = yes
    v-exit-enabled = yes
  .
END.
ON RETURN OF cur-date IN FRAME d-cur-date
DO:
  assign
      v-exit-enabled = yes
  .
  apply "choose" to b-exit in frame d-cur-date.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-cur-date:PARENT eq ?
THEN FRAME d-cur-date:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-cur-date
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame d-cur-date
do:
  apply "help":u to frame d-cur-date .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame d-cur-date:width - 0.3
                fh            = frame d-cur-date:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of cur-date in frame d-cur-date
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of cur-date in frame d-cur-date
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of cur-date in frame d-cur-date
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of cur-date in frame d-cur-date
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of cur-date in frame d-cur-date
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of cur-date in frame d-cur-date
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date6
    MENU-ITEM m-ed-date6-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date6-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date6-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date6-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if cur-date :POPUP-MENU in frame d-cur-date = ?
  then do:
    ASSIGN
      cur-date :POPUP-MENU in frame d-cur-date = MENU m-ed-date6 :HANDLE
      cur-date :MENU-MOUSE in frame d-cur-date = 3
    .
  end.
  define variable v-label-handle6 as handle no-undo .
  assign
    v-label-handle6 = cur-date :side-label-handle in frame d-cur-date
  .
  if valid-handle (v-label-handle6)
  then do:
    if v-label-handle6 :tooltip = ""
    or v-label-handle6 :tooltip = ?
    then do:
      assign
        v-label-handle6 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date6-1 in menu m-ed-date6 DO:
    apply "ctrl-b":U to cur-date in frame d-cur-date .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-2 in menu m-ed-date6 DO:
    apply "ctrl-d":U to cur-date in frame d-cur-date .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-3 in menu m-ed-date6 DO:
    apply "ctrl-e":U to cur-date in frame d-cur-date .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-4 in menu m-ed-date6 DO:
    apply "ctrl-f":U to cur-date in frame d-cur-date .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if v-cntxt-level <> 'object':U then do:
    message
    "Объект не определен"
    view-as alert-box  warning.
  end.
  else do:
    assign
        p-error-code = 0
    .
    run cur-time in this-procedure ( output v-today
                                  , output v-time
                                  ).
    run enter-on-object in this-procedure no-error.
    if error-status :error
    then do:
        if v-endkey-error = yes
        then do:
            if p-date-change <> 'change-date':U
            then do:
                message
                    "Без ввода даты работа на объекте невозможна."
                view-as alert-box error.
            end.
            undo, return error .
        end.
        else do:
            message
            vss-workfile vss-revision vss-description
            skip  "Ошибка входа на объект"
            skip
            skip  return-value
                    trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return error .
        end.
    end.
  end.
END.
RUN disable_UI.
PROCEDURE check-shift-days :
define output parameter p-error-code    as integer          no-undo.
do
on error undo, return error
:
    assign
        p-error-code = 0
    .
    if v-shift-obj-on = yes
    then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-shift-start-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
        if not error-status :error
        then do:
            define variable v-host-code like ub.shop.host-code     no-undo.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
            define variable v-value-character as character  no-undo .
            define variable v-value-date      as date       no-undo .
            define variable v-value-decimal   as decimal    no-undo .
            define variable v-value-logical   as logical    no-undo .
            define variable v-tth             as handle     no-undo .
            define variable v-param-type            as character no-undo .
            run adm/shattri.p ( input "get":U
                              , input  p-obj-type
                              , input  p-obj-code
                              , input  'obj-date':U
                              , input  'diffshft':U
                              , output v-value-character
                              , output v-value-date
                              , output v-value-decimal
                              , output v-max-shift-days
                              , output v-value-logical
                              , output v-param-type
                              , input-output table-handle v-tth
                              ) no-error .
            if error-status :error
            then do:
               assign
                  v-max-shift-days = 3
               .
            end.
            delete object v-tth.
            if v-obj-date - v-shift-start-date > integer( v-max-shift-days )
            then do:
                if v-cntxt-is-admin = yes
                then do:
                    message
                        skip "С момента открытия смены N " v-shift-name " порядок " v-shift-num " от " v-shift-start-date
                        skip " до введенной даты: " v-obj-date
                        skip " прошло более " v-max-shift-days + 1 " дней"
                        skip (1)
                        skip "Вход на объект возможен"
                        skip "только для администратора системы."
                        skip "Для работы остальных пользователей на объекте"
                        skip "необходимо установить корректную дату ."
                    view-as alert-box error.
                    assign
                       p-error-code = 0
                    .
                end.
                else do:
                    assign
                       p-error-code = 1
                    .
                    message
                        skip "С момента открытия смены N " v-shift-name " порядок " v-shift-num " от " v-shift-start-date
                        skip " до введенной даты: " v-obj-date
                        skip " прошло более " v-max-shift-days + 1 " дней"
                        skip (1)
                        skip "Вход на объект возможен"
                        skip "только для администратора системы."
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-cur-date.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ed-info cur-date fi-description
      WITH FRAME d-cur-date.
  ENABLE b-exit b-quit b-help ed-info cur-date b-choose-date fi-description
      WITH FRAME d-cur-date.
  VIEW FRAME d-cur-date.
END PROCEDURE.
PROCEDURE enter-on-object :
  define variable v-obj-is-active as logical   no-undo .
  define variable v-shift-string  as character no-undo .
  define variable v-is-admin as logical no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_object-date_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-allow-date-change
    )  .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-obj-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении типа сменный/не-сменный для объекта" skip
        "Объект" p-obj-type p-obj-code skip
        "Атрибут" 'autodate=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-shift-obj-on = yes
    then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-shift-start-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
      if not error-status :error
      then do:
        assign
          v-shift-string = "Открыта смена " + string( v-shift-name ) + " от " + string( v-shift-start-date )
        .
      end.
      else do:
        assign
          v-shift-string = "Смена закрыта"
        .
      end.
    end.
    for each buf_obj-date exclusive-lock
      where buf_obj-date.status_  = 'новый':U
    on error undo, return error return-value
    :
      assign
        buf_obj-date.status_  = 'тек':U
      .
    end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'autodate=request'
  ,output v-auto-date-change
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        "Атрибут" 'autodate=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'active=request'
  ,output v-obj-is-active
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не удалось определить активность объекта." skip
        "Объект" p-obj-type p-obj-code skip
        return-value skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_obj-date
      where buf_obj-date.obj-type = p-obj-type
        and buf_obj-date.obj-code = p-obj-code
        and buf_obj-date.status_  = 'тек':U
    no-error .
    if not available buf_obj-date
    then do:
        if v-obj-is-active = no
        then do:
            find first buf_obj-date
                where buf_obj-date.obj-type = p-obj-type
                  and buf_obj-date.obj-code = p-obj-code
            no-error .
            if not available buf_obj-date
            then do:
                assign
                    v-obj-date              = v-today
                    v-obj-date-is-from-base = yes
                .
            end.
            else do:
                message
                    "Не удалось получить дату на неактивном объекте " p-obj-type p-obj-code "."
                    skip "Необходимо установить дату на активном объекте."
                    skip (1) "Обратитесь к администратору системы."
                view-as alert-box error.
                undo, return error .
            end.
        end.
        else do:
            if v-allow-date-change = no
            then do:
                message
                    "Это первый вход в систему на объекте " p-obj-type p-obj-code "."
                    skip "Необходимо установить дату на объекте."
                    skip (1) "Обратитесь к администратору системы."
                view-as alert-box error.
                undo, return error .
            end.
            else do:
                message
                    "Это первый вход в систему на этом объекте."
                    skip (1) "Установите, пожалуйста, дату на объекте."
                view-as alert-box information.
                run get-date-from-admin in this-procedure(
                        input "is-obj-date"
                        , input v-shift-obj-on
                        , input v-shift-string
                        , input v-auto-date-change
                        , input " не установлена"
                ) no-error.
                if error-status :error or v-endkey-error = yes
                then do:
                    undo, return no-apply .
                end.
            end.
        end.
    end.
    else do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtget in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-date
  )  .
        if v-obj-is-active = no
        then do:
            assign
                v-obj-date-is-from-base = yes
            .
        end.
        else do:
            if v-obj-date > v-today
            then do:
                undo, return error "Дата на объекте больше текущей даты".
            end.
            if v-obj-date = ?
            or v-obj-date + 10 < v-today
            then do:
                if v-auto-date-change = no
                and v-obj-date <> ?
                and p-date-change <> 'change-date':U
                then do:
                    message
                        "Дата на объекте " p-obj-type p-obj-code
                        skip "отличается от текущей более чем на 10 дней."
                        skip "Вы можете изменить дату на объекте вручную."
                        skip "Для этого воспользуйтесь меню системы, пункт"
                        skip "        Сервис / Изменить дату."
                    view-as alert-box warning.
                    assign
                        v-obj-date-is-from-base = yes
                    .
                end.
                else do:
                    if v-allow-date-change = no
                    then do:
                        message
                            "Дата на объекте " p-obj-type p-obj-code " не определена"
                            skip "или на объект не входили более 10 дней."
                            skip "Необходимо установить дату на объекте."
                            skip (1) "Обратитесь к администратору системы."
                        view-as alert-box error.
                        undo, return error .
                    end.
                    else do:
                        if p-date-change <> 'change-date':U
                        then do:
                            message
                                "Дата на объекте " p-obj-type p-obj-code " не определена"
                                skip "или на объект не входили более 10 дней."
                                skip (1) "Установите, пожалуйста, дату на объекте."
                            view-as alert-box information.
                        end.
                        run get-date-from-admin in this-procedure(
                            input "is-obj-date"
                            , input v-shift-obj-on
                            , input v-shift-string
                            , input v-auto-date-change
                            , input ( if v-obj-date = ? then " не установлена" else string( v-obj-date, '99/99/9999':u ) )
                        ) no-error .
                        if error-status :error or v-endkey-error = yes
                        then do:
                            undo, return error .
                        end.
                    end.
                end.
            end.
            else do:
                if v-obj-date < v-today
                then do:
                    if v-auto-date-change = yes
                    or p-date-change = 'change-date':U
                    then do:
                        run get-date-from-admin in this-procedure(
                                          input ""
                                        , input v-shift-obj-on
                                        , input v-shift-string
                                        , input v-auto-date-change
                                        , input string( v-obj-date, '99/99/9999':u )
                        ) no-error.
                        if error-status :error or v-endkey-error = yes
                        then do:
                            undo, return error .
                        end.
                    end.
                    else do:
                        assign
                            v-obj-date-is-from-base = yes
                        .
                    end.
                    run check-shift-days in this-procedure (
                        output p-error-code
                    ) no-error.
                    if error-status :error
                    then do:
                        message
                          vss-workfile vss-revision vss-description
                          skip "Ошибка продолжительности смены."
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
                else do:
                    if p-date-change = 'change-date':U
                    then do:
                        message
                            "Дата на объекте равна или больше сегодняшней даты."
                            skip(1) "Изменение даты невозможно."
                        view-as alert-box information.
                    end.
                end.
            end.
        end.
    end.
    if v-obj-is-active = yes
    then do:
        run check-shift-days in this-procedure (
            output p-error-code
        ) no-error.
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка продолжительности смены."
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
    else do:
        if p-date-change = 'change-date':U
        then do:
            message
                skip "Изменение даты невозможно:"
                skip "Объект не активен."
            view-as alert-box error.
        end.
    end.
    if v-obj-date-is-from-base = no
    then do:
        find first buf_obj-date no-lock
             where buf_obj-date.obj-type = p-obj-type
               and buf_obj-date.obj-code = p-obj-code
               and buf_obj-date.status_  = 'тек':U
        no-error .
        if not available buf_obj-date
        then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtcr in g#library
  (input p-obj-type
  ,input p-obj-code
  ,input v-obj-date
  ) no-error .
            if error-status :error then do:
                message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка при создании даты на объекте"
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
        else do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtset in g#library
  (input p-obj-type
  ,input p-obj-code
  ,input v-obj-date
  )  .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE get-date-from-admin :
do
on error undo, return error
:
define input parameter p-is-obj-date        as character    no-undo.
define input parameter p-shift-enabled      as logical      no-undo.
define input parameter p-shift-string       as character    no-undo.
define input parameter p-auto-date          as logical      no-undo.
define input parameter p-last-date-string   as character    no-undo.
    define variable v-entered-date-ok as logical    no-undo.
    RUN enable_UI.
    assign
        ed-info :screen-value in frame d-cur-date = "Объект: " + p-obj-type + " " + string( p-obj-code )
                                + ( if p-shift-enabled then ", сменный" else "" )
                                + ( if p-shift-enabled then chr(10) + p-shift-string else "" )
                                + chr(10) + ( if p-auto-date     then "Автоматическая смена даты" else "Не автоматическая смена даты" )
                                + chr(10) + "Дата на объекте: " + p-last-date-string
        v-entered-date-ok   = no
        v-endkey-error      = no
    .
    do while v-entered-date-ok = no
    and v-endkey-error = no
    :
        WAIT-FOR GO OF FRAME d-cur-date focus cur-date.
        assign cur-date.
        if ( cur-date > v-obj-date
            and cur-date <= v-today )
        or v-obj-date = ?
        then do:
            assign
                v-entered-date-ok   = yes
            .
        end.
        else do:
            message
            "Введенная дата меньше или равна дате на объекте"
            skip "или больше текущей даты."
            skip (1) "Установите дату правильно или отмените операцию."
            view-as alert-box error.
        end.
    end.
    RUN disable_UI.
    if p-is-obj-date = "is-obj-date"
    then do:
        assign
            v-obj-date = cur-date
        .
    end.
    if cur-date < v-obj-date
    or cur-date > v-today
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Введенная дата больше даты на сервере"
          skip "или меньше текущей даты на объекте."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    if v-auto-date-change = yes
    and cur-date <> v-today
    then do:
        undo, return error.
    end.
    assign
        v-obj-date = cur-date
        v-obj-date-is-from-base = no
    .
    run set-all-active-auto-objects in this-procedure (
        input v-obj-date
    ) no-error.
end.
END PROCEDURE.
PROCEDURE set-all-active-auto-objects :
do
on error undo, return error
:
define input parameter p-obj-date   as date         no-undo.
    define buffer buf_obj-date      for ub.obj-date.
    define variable v-auto-date-change  as logical       no-undo.
    define variable v-obj-is-active     as logical       no-undo.
    define buffer buf_db for ub.db .
    define buffer buf_clients for ub.clients .
    objects-of-base:
    for each buf_db no-lock
    on error undo, return error return-value
    :
      for each buf_clients no-lock
        where buf_clients.db-num = buf_db.db-num
      :
          if  buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
          then do:
              next objects-of-base.
          end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,input  'autodate=request'
  ,output v-auto-date-change
  ) no-error .
          if error-status :error
          then do:
              message
                  vss-workfile vss-revision vss-description
                  skip "Ошибка при определении атрибута объекта."
                  skip "Объект" buf_clients.obj-type buf_clients.obj-code
                  skip "Атрибут" 'autodate=request':u
                  skip "(автоматическая/ручная смена даты на объекте)"
                  skip error-status :get-message(1)
                  skip return-value
                  skip "Дата на объекте не изменится."
              view-as alert-box error .
              undo, next objects-of-base.
          end.
          if v-auto-date-change = yes
          then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,input  'active=request'
  ,output v-obj-is-active
  ) no-error .
              if error-status :error
              then do:
                  message
                      vss-workfile vss-revision vss-description
                      skip "Ошибка при определении атрибута объекта."
                      skip "Объект" buf_clients.obj-type buf_clients.obj-code
                      skip "Атрибут" 'active=request':u
                      skip "(активность объекта)"
                      skip error-status :get-message(1)
                      skip return-value
                      skip "Дата на объекте не изменится."
                  view-as alert-box error .
                  undo, next objects-of-base.
              end.
              if v-obj-is-active = yes
              then do:
                  find first buf_obj-date no-lock
                      where buf_obj-date.obj-type = buf_clients.obj-type
                        and buf_obj-date.obj-code = buf_clients.obj-code
                        and buf_obj-date.status_  = 'тек':U
                  no-error .
                  if not available buf_obj-date
                  then do:
                      do transaction
                      on error undo, return error
                      :
                          find last buf_obj-date exclusive-lock
                              where buf_obj-date.obj-type = buf_clients.obj-type
                                and buf_obj-date.obj-code = buf_clients.obj-code
                          use-index pi
                          no-error
                          no-wait.
                          if not available buf_obj-date
                          then do:
                          end.
                          else do:
                              if buf_obj-date.status_ = 'зкр':U
                              then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtcr in g#library
  (input buf_clients.obj-type
  ,input buf_clients.obj-code
  ,input p-obj-date
  ) no-error .
                                  if error-status :error
                                  then do:
                                      message
                                          vss-workfile vss-revision vss-description
                                          skip "Ошибка при создании даты на объекте."
                                          skip "Объект" buf_clients.obj-type buf_clients.obj-code
                                          skip "Дата  " string( p-obj-date, "99/99/9999" )
                                          skip return-value
                                          skip trim(error-status :get-message(1))
                                      view-as alert-box error.
                                      undo, return error .
                                  end.
                              end.
                          end.
                      end.
                  end.
                  else do:
                      if buf_obj-date.sys-date < p-obj-date
                      then do:
                          do transaction
                          :
                              find last buf_obj-date exclusive-lock
                                  where buf_obj-date.obj-type = buf_clients.obj-type
                                    and buf_obj-date.obj-code = buf_clients.obj-code
                              use-index pi
                              no-error
                              no-wait.
                              if available buf_obj-date
                              and buf_obj-date.status_ = 'тек':U
                              and buf_obj-date.sys-date < p-obj-date
                              then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtset in g#library
  (input buf_clients.obj-type
  ,input buf_clients.obj-code
  ,input p-obj-date
  ) no-error .
                                  if error-status :error
                                  then do:
                                      message
                                          vss-workfile vss-revision vss-description
                                          skip "Ошибка при изменении даты на объекте."
                                          skip "Объект" buf_clients.obj-type buf_clients.obj-code
                                          skip "Дата  " string( p-obj-date, "99/99/9999" )
                                          skip return-value
                                          skip trim(error-status :get-message(1))
                                      view-as alert-box error.
                                      undo, return error .
                                  end.
                              end.
                          end.
                      end.
                  end.
              end.
          end.
      end.
   end.
end.
END PROCEDURE.
