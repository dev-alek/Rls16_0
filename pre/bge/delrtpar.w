DEFINE NEW GLOBAL SHARED VARIABLE appSrvUtils AS HANDLE                NO-UNDO.
IF NOT VALID-HANDLE(appSrvUtils) THEN
  RUN adecomm/as-utils.w PERSISTENT SET appSrvUtils.
THIS-PROCEDURE:ADD-SUPER-PROCEDURE(appSrvUtils).
CREATE WIDGET-POOL.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
define input parameter p-db-num-char    as character    no-undo.
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define input parameter p-action         as character    no-undo.
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.
FUNCTION assignFocusedWidget RETURNS LOGICAL
  ( INPUT pcName AS CHARACTER )
   IN SUPER.
FUNCTION assignWidgetValue RETURNS LOGICAL
  ( INPUT pcName  AS CHARACTER,
    INPUT pcValue AS CHARACTER )
   IN SUPER.
FUNCTION assignWidgetValueList RETURNS LOGICAL
  ( INPUT pcNameList  AS CHARACTER,
    INPUT pcValueList AS CHARACTER,
    INPUT pcDelimiter AS CHARACTER )
   IN SUPER.
FUNCTION blankWidget RETURNS LOGICAL
  ( INPUT pcNameList AS CHARACTER )
   IN SUPER.
FUNCTION clearWidget RETURNS LOGICAL
    ( INPUT pcNameList AS CHARACTER )
     IN SUPER.
FUNCTION disableRadioButton RETURNS LOGICAL
  ( INPUT pcNameList  AS CHARACTER,
    INPUT piButtonNum AS INTEGER )
   IN SUPER.
FUNCTION disableWidget RETURNS LOGICAL
  ( INPUT pcNameList AS CHARACTER )
   IN SUPER.
FUNCTION enableRadioButton RETURNS LOGICAL
  ( INPUT pcNameList  AS CHARACTER,
    INPUT piButtonNum AS INTEGER )
   IN SUPER.
FUNCTION enableWidget RETURNS LOGICAL
  ( INPUT pcNameList AS CHARACTER )
   IN SUPER.
FUNCTION formattedWidgetValue RETURNS CHARACTER
  ( INPUT pcName AS CHARACTER )
   IN SUPER.
FUNCTION formattedWidgetValueList RETURNS CHARACTER
  ( INPUT pcNameList  AS CHARACTER,
    INPUT pcDelimiter AS CHARACTER)
   IN SUPER.
FUNCTION hideWidget RETURNS LOGICAL
  ( INPUT pcNameList AS CHARACTER )
   IN SUPER.
FUNCTION highlightWidget RETURNS LOGICAL
  ( INPUT pcNameList      AS CHARACTER,
    INPUT pcHighlightType AS CHARACTER )
   IN SUPER.
FUNCTION resetWidgetValue RETURNS LOGICAL
  ( INPUT pcNameList AS CHARACTER )
   IN SUPER.
FUNCTION toggleWidget RETURNS LOGICAL
  ( INPUT pcNameList AS CHARACTER )
   IN SUPER.
FUNCTION viewWidget RETURNS LOGICAL
  ( INPUT pcNameList AS CHARACTER )
   IN SUPER.
FUNCTION widgetHandle RETURNS HANDLE
  ( INPUT pcName AS CHARACTER )
   IN SUPER.
FUNCTION widgetLongcharValue RETURNS LONGCHAR
  (INPUT pcName AS CHARACTER )
   IN SUPER.
FUNCTION widgetIsBlank RETURNS LOGICAL
  ( INPUT pcNameList AS CHARACTER )
   IN SUPER.
FUNCTION widgetIsFocused RETURNS LOGICAL
  ( INPUT pcName AS CHARACTER )
   IN SUPER.
FUNCTION widgetIsModified RETURNS LOGICAL
  ( INPUT pcNameList AS CHARACTER )
   IN SUPER.
FUNCTION widgetIsTrue RETURNS LOGICAL
  ( INPUT pcName AS CHARACTER )
   IN SUPER.
FUNCTION widgetValue RETURNS CHARACTER
  (INPUT pcName AS CHARACTER )
   IN SUPER.
FUNCTION widgetValueList RETURNS CHARACTER
  (INPUT pcNameList  AS CHARACTER,
   INPUT pcDelimiter AS CHARACTER )
   IN SUPER.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки по автоматическому удалению маршрутизации ВС, работающих без подтверждения".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-schedule-free no-undo
field free-id as character
field free-task-name as character
field proc-run-name as character
field proc-param-edit-name as character
field conf-param as character
field is-gbd as logical
field is-ubd as logical
field enable-concurrent-0 as logical
field enable-concurrent-db as logical
field other-info as character
field enc-key as character
field is-rum as logical
index pi is unique primary
free-id.
procedure schedule-attr-name :
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
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-obj-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-oss-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-gds-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-doc-type-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-date-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-filter':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-filter-2':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schd-free-id':U then do:     assign     p-label = "Идентификатор произвольной задачи"     p-type = 'C':U      p-format = "X(30)"     p-label = "Идентификатор произвольной задачи"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure schedule-attr-tooltip :
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
            when 'schedule-param-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-obj-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-oss-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-gds-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-doc-type-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-date-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-filter':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-filter-2':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schd-free-id':U then do:     assign     p-tooltip = "Идентификатор произвольной задачи"     p-label = "Идентификатор произвольной задачи" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure schedule-attr-value :
do
on error undo, return error return-value
:
define input parameter  p-cre-db-num as integer    no-undo.
define input parameter  p-task-type  as character  no-undo.
define input parameter  p-task-num   as integer    no-undo.
define input parameter  p-code       as character  no-undo.
define output parameter p-value      as character  no-undo.
define output parameter p-type       as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_schedule-attr for ub.schedule-attr.
    run schedule-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    if p-code begins ('schd-free-id':U + chr(4))
    and entry(2, p-code, chr(4)) = '':U then do:
      find first buf_schedule-attr no-lock
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  begins p-code
      no-error .
    end.
    else do:
      find first buf_schedule-attr no-lock
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  = p-code
      no-error .
    end.
    if available buf_schedule-attr
    then do:
        assign
            p-value = buf_schedule-attr.attr-value
        .
    end.
    else do:
      if p-code begins ('schd-free-id':U + chr(4) ) then do:
         run schedule-attr-get-free-props in this-procedure (input entry(2, p-code, chr(4)), output p-value).
      end.
      else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
    end.
end.
end procedure.
procedure schedule-attr-write :
do
on error undo, return error
:
define input parameter p-cre-db-num  as integer   no-undo.
define input parameter p-task-type   as character no-undo.
define input parameter p-task-num    as integer   no-undo.
define input parameter p-code        as character no-undo.
define input parameter p-value       as character no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_schedule-attr for ub.schedule-attr .
    run schedule-attr-name in this-procedure (
          input  p-code
        , output v-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        create buf_schedule-attr.
        assign
          buf_schedule-attr.cre-db-num = p-cre-db-num
          buf_schedule-attr.task-type  = p-task-type
          buf_schedule-attr.task-num   = p-task-num
          buf_schedule-attr.attr-code  = p-code
          buf_schedule-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_schedule-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure schedule-attr-delete :
do
on error undo, return error
:
define input  parameter p-cre-db-num  as integer   no-undo.
define input  parameter p-task-type   as character no-undo.
define input  parameter p-task-num    as integer   no-undo.
define input  parameter p-code        as character no-undo.
define output parameter p-deleted     as logical   no-undo.
    define buffer buf_schedule-attr for ub.schedule-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run schedule-attr-name in this-procedure (
          input p-code
        , output v-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
        delete buf_schedule-attr.
        assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure schedule-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-news = false.   end.
            when 'schedule-obj-list':U then do:     assign     p-news = false.   end.
            when 'schedule-oss-list':U then do:     assign     p-news = false.   end.
            when 'schedule-gds-list':U then do:     assign     p-news = false.   end.
            when 'schedule-doc-type-list':U then do:     assign     p-news = false.   end.
            when 'schedule-date-list':U then do:     assign     p-news = false.   end.
            when 'schedule-filter':U then do:     assign     p-news = false.   end.
            when 'schedule-filter-2':U then do:     assign     p-news = false.   end.
            when 'schd-free-id':U then do:     assign     p-news = false.   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure schedule-attr-extract-logical :
do
on error undo, return error
:
define input  parameter p-parameter-number   as integer      no-undo.
define input  parameter p-parameter-list     as character    no-undo.
define output parameter p-parameter-value   as logical      no-undo.
    if num-entries( p-parameter-list ) > p-parameter-number - 1
    then do:
        assign
            p-parameter-value   = ( entry( p-parameter-number, p-parameter-list ) = "yes" )
        .
    end.
    else do:
        assign
            p-parameter-value   = no
        .
    end.
end.
end procedure.
procedure schedule-attr-get-free-id :
do
on error undo, return error return-value
:
  define input  parameter p-cre-db-num  as integer   no-undo.
  define input  parameter p-task-type   as character no-undo.
  define input  parameter p-task-num    as integer   no-undo.
  define output parameter p-free-id     as character no-undo.
  define buffer buf_schedule-attr for ub.schedule-attr.
  find first buf_schedule-attr no-lock
      where buf_schedule-attr.cre-db-num = p-cre-db-num
        and buf_schedule-attr.task-type  = p-task-type
        and buf_schedule-attr.task-num   = p-task-num
        and buf_schedule-attr.attr-code  begins  ('schd-free-id':U + chr(4))
  no-error .
  if available buf_schedule-attr then
  assign
  p-free-id = entry(2, buf_schedule-attr.attr-code, chr(4))
  no-error
  .
end.
end procedure.
procedure schedule-attr-get-free-props :
  define input parameter p-free-id as character no-undo .
  define output parameter p-value as character no-undo .
  define buffer buf_temp-schedule-free for temp-schedule-free.
  do
  on error undo, return error return-value
  :
    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free then do:
      assign
      p-value = buf_temp-schedule-free.free-task-name       + chr(4) +
                buf_temp-schedule-free.proc-run-name        + chr(4) +
                buf_temp-schedule-free.proc-param-edit-name + chr(4) +
                buf_temp-schedule-free.conf-param           + chr(4) +
                string(buf_temp-schedule-free.is-gbd)       + chr(4) +
                string(buf_temp-schedule-free.is-ubd)       + chr(4) +
                string(buf_temp-schedule-free.enable-concurrent-0) + chr(4) +
                string(buf_temp-schedule-free.enable-concurrent-db) + chr(4) +
                buf_temp-schedule-free.other-info
      .
    end.
    else do:
     if p-free-id <> '':U then return error substitute("&1 &2 &3&4Неопределены процедуры для работы с произвольной задачей по расписанию&4" +
                           "id произвольной задачи - &5"
                           ,vss-workfile
                           ,vss-revision
                           ,vss-description
                           ,chr(10)
                           ,p-free-id).
    end.
  end.
end procedure.
procedure schedule-attr-is-rum-free-id :
define input parameter p-free-id as character no-undo .
define output parameter p-is-rum as logical no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
do
on error undo, return error
:
    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free
    and buf_temp-schedule-free.is-rum
    then do:
      p-is-rum = yes.
    end.
end.
end procedure.
procedure schedule-attr-fill-free-props :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
define variable v-answer as logical no-undo .
  do
  on error undo, return error substitute("&1 &2 &3&4&5&4"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        ,error-status:get-message(1) )
  :
    run gbl/filename.p (
                    input 'cmp/shd-free.d'
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) .
    input from value(v-full-path).
    repeat :
      create buf_temp-schedule-free.
      import buf_temp-schedule-free.
    END.
    input close.
    _ff:
    for each buf_temp-schedule-free :
      if buf_temp-schedule-free.free-id = '':U then do:
         delete buf_temp-schedule-free.
         next _ff.
       end.
       run schedule-attr-check-enc in this-procedure (
                                                    input  buf_temp-schedule-free.free-id
                                                   ,input  (buf_temp-schedule-free.proc-run-name +
                                                            buf_temp-schedule-free.proc-param-edit-name +
                                                            buf_temp-schedule-free.conf-param +
                                                            string(buf_temp-schedule-free.is-gbd) +
                                                            string(buf_temp-schedule-free.is-ubd) +
                                                            string(buf_temp-schedule-free.enable-concurrent-0) +
                                                            string(buf_temp-schedule-free.enable-concurrent-db) +
                                                            string(buf_temp-schedule-free.other-info)
                                                            )
                                                    ,input  buf_temp-schedule-free.enc-key
                                                    ,output v-answer    ) no-error .
       if error-status:error
       or not v-answer then delete buf_temp-schedule-free.
     end.
  end.
end procedure.
Function schedule-attr-reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.
procedure schedule-attr-check-enc.
  define input  parameter p-free-id   as character no-undo .
  define input  parameter p-value     as character no-undo .
  define input  parameter p-enc-value as character no-undo .
  define output parameter p-answer    as logical   no-undo .
  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .
  assign
  tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value)) .
  .
  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.
end.
procedure schedule-attr-conf-enc.
  define input  parameter p-free-id   as character no-undo .
  define input  parameter p-value     as character no-undo .
  define output parameter p-enc-value as character no-undo .
  define variable tmp         as character no-undo .
  assign
    tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value))
  .
  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output p-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure schedule-attr-pswd-enc :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
define variable mark        as character no-undo.
define variable mark-string as character no-undo .
define variable mark-list   as character no-undo .
define variable g#log       as logical   no-undo .
DEFINE BUTTON b-delmark
  LABEL "Снять *"
  SIZE 13.8 BY 1.14.
DEFINE BUTTON b-enter AUTO-GO
  LABEL "Ввод"
  SIZE 22.8 BY 1.14.
DEFINE BUTTON B-exit AUTO-END-KEY
  LABEL "Отмена"
  SIZE 15 BY 1.14.
DEFINE BUTTON B-mark
  LABEL "*"
  SIZE 5 BY 1.14.
DEFINE VARIABLE f-day-shift AS INTEGER INITIAL 10
  LABEL "Кол. дней хранения"
  VIEW-AS FILL-IN
  SIZE 14 BY 1.19 NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
  ext-system SCROLLING.
FUNCTION mark-string RETURN CHAR (buffer loc-ext-sys for ext-system , input mark-list as character ).
  if lookup ( string(recid (loc-ext-sys)) , mark-list ) > 0 then RETURN "*".
  else RETURN "".
END FUNCTION.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 NO-LOCK DISPLAY
  mark-string ( buffer ext-system , input mark-list) @ mark COLUMN-LABEL "*" FORMAT "x(1)"
  ext-system.esys-name COLUMN-LABEL "Название ВС" FORMAT "X(30)":U
  WIDTH 72
  ext-system.esys-id FORMAT "->,>>>,>>9":U WIDTH 5.8
  ext-system.esys-db-num-exp COLUMN-LABEL "БД экс" FORMAT ">>>>9":U
  WIDTH 7.6
  ext-system.esys-db-num-imp COLUMN-LABEL "БД имп" FORMAT ">>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 96 BY 24.05 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME gDialog
  B-mark AT ROW 1.24 COL 2.2 WIDGET-ID 4
  b-delmark AT ROW 1.24 COL 7.8 WIDGET-ID 6
  f-day-shift AT ROW 1.24 COL 40 COLON-ALIGNED WIDGET-ID 8
  b-enter AT ROW 1.24 COL 57 WIDGET-ID 2
  B-exit AT ROW 1.24 COL 80.8
  BROWSE-2 AT ROW 2.91 COL 1 WIDGET-ID 200
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Настройки по автоматическому удалению маршрутизации ВС, работающих без подтверждения"
  CANCEL-BUTTON B-exit WIDGET-ID 100.
  IF CURRENT-WINDOW <> CURRENT-WINDOW THEN
  DO:
    IF CURRENT-WINDOW:MAX-WIDTH = CURRENT-WINDOW:VIRTUAL-WIDTH THEN
      CURRENT-WINDOW:MAX-WIDTH  = SESSION:WIDTH - 1 NO-ERROR.
    IF CURRENT-WINDOW:MAX-HEIGHT = CURRENT-WINDOW:VIRTUAL-HEIGHT THEN
      CURRENT-WINDOW:MAX-HEIGHT = SESSION:HEIGHT - 1 NO-ERROR.
  END.
PROCEDURE assignPageProperty IN SUPER:
  DEFINE INPUT PARAMETER pcProp AS CHARACTER.
  DEFINE INPUT PARAMETER pcValue AS CHARACTER.
END PROCEDURE.
PROCEDURE changePage IN SUPER:
END PROCEDURE.
PROCEDURE confirmExit IN SUPER:
  DEFINE INPUT-OUTPUT PARAMETER plCancel AS LOGICAL.
END PROCEDURE.
PROCEDURE constructObject IN SUPER:
  DEFINE INPUT PARAMETER pcProcName AS CHARACTER.
  DEFINE INPUT PARAMETER phParent AS HANDLE.
  DEFINE INPUT PARAMETER pcPropList AS CHARACTER.
  DEFINE OUTPUT PARAMETER phObject AS HANDLE.
END PROCEDURE.
PROCEDURE createObjects IN SUPER:
END PROCEDURE.
PROCEDURE deletePage IN SUPER:
  DEFINE INPUT PARAMETER piPageNum AS INTEGER.
END PROCEDURE.
PROCEDURE destroyObject IN SUPER:
END PROCEDURE.
PROCEDURE hidePage IN SUPER:
  DEFINE INPUT PARAMETER piPageNum AS INTEGER.
END PROCEDURE.
PROCEDURE initializeObject IN SUPER:
END PROCEDURE.
PROCEDURE initializeVisualContainer IN SUPER:
END PROCEDURE.
PROCEDURE initPages IN SUPER:
  DEFINE INPUT PARAMETER pcPageList AS CHARACTER.
END PROCEDURE.
PROCEDURE notifyPage IN SUPER:
  DEFINE INPUT PARAMETER pcProc AS CHARACTER.
END PROCEDURE.
PROCEDURE passThrough IN SUPER:
  DEFINE INPUT PARAMETER pcLinkName AS CHARACTER.
  DEFINE INPUT PARAMETER pcArgument AS CHARACTER.
END PROCEDURE.
PROCEDURE removePageNTarget IN SUPER:
  DEFINE INPUT PARAMETER phTarget AS HANDLE.
  DEFINE INPUT PARAMETER piPage AS INTEGER.
END PROCEDURE.
PROCEDURE selectPage IN SUPER:
  DEFINE INPUT PARAMETER piPageNum AS INTEGER.
END PROCEDURE.
PROCEDURE toolbar IN SUPER:
  DEFINE INPUT PARAMETER pcValue AS CHARACTER.
END PROCEDURE.
PROCEDURE viewObject IN SUPER:
END PROCEDURE.
PROCEDURE viewPage IN SUPER:
  DEFINE INPUT PARAMETER piPageNum AS INTEGER.
END PROCEDURE.
FUNCTION disablePagesInFolder RETURNS LOGICAL
  (INPUT pcPageInformation AS CHARACTER) IN SUPER.
FUNCTION enablePagesInFolder RETURNS LOGICAL
  (INPUT pcPageInformation AS CHARACTER) IN SUPER.
FUNCTION getCallerProcedure RETURNS HANDLE IN SUPER.
FUNCTION getCallerWindow RETURNS HANDLE IN SUPER.
FUNCTION getContainerMode RETURNS CHARACTER IN SUPER.
FUNCTION getContainerTarget RETURNS CHARACTER IN SUPER.
FUNCTION getContainerTargetEvents RETURNS CHARACTER IN SUPER.
FUNCTION getCurrentPage RETURNS INTEGER IN SUPER.
FUNCTION getDisabledAddModeTabs RETURNS CHARACTER IN SUPER.
FUNCTION getDynamicSDOProcedure RETURNS CHARACTER IN SUPER.
FUNCTION getFilterSource RETURNS HANDLE IN SUPER.
FUNCTION getMultiInstanceActivated RETURNS LOGICAL IN SUPER.
FUNCTION getMultiInstanceSupported RETURNS LOGICAL IN SUPER.
FUNCTION getNavigationSource RETURNS CHARACTER IN SUPER.
FUNCTION getNavigationSourceEvents RETURNS CHARACTER IN SUPER.
FUNCTION getNavigationTarget RETURNS HANDLE IN SUPER.
FUNCTION getOutMessageTarget RETURNS HANDLE IN SUPER.
FUNCTION getPageNTarget RETURNS CHARACTER IN SUPER.
FUNCTION getPageSource RETURNS HANDLE IN SUPER.
FUNCTION getPrimarySdoTarget RETURNS HANDLE IN SUPER.
FUNCTION getReEnableDataLinks RETURNS CHARACTER IN SUPER.
FUNCTION getRunDOOptions RETURNS CHARACTER IN SUPER.
FUNCTION getRunMultiple RETURNS LOGICAL IN SUPER.
FUNCTION getSavedContainerMode RETURNS CHARACTER IN SUPER.
FUNCTION getSdoForeignFields RETURNS CHARACTER IN SUPER.
FUNCTION getTopOnly RETURNS LOGICAL IN SUPER.
FUNCTION getUpdateSource RETURNS CHARACTER IN SUPER.
FUNCTION getUpdateTarget RETURNS CHARACTER IN SUPER.
FUNCTION getWaitForObject RETURNS HANDLE IN SUPER.
FUNCTION getWindowTitleViewer RETURNS HANDLE IN SUPER.
FUNCTION getStatusArea RETURNS LOGICAL IN SUPER.
FUNCTION pageNTargets RETURNS CHARACTER
  (INPUT phTarget AS HANDLE,
   INPUT piPageNum AS INTEGER) IN SUPER.
FUNCTION setCallerObject RETURNS LOGICAL
  (INPUT h AS HANDLE) IN SUPER.
FUNCTION setCallerProcedure RETURNS LOGICAL
  (INPUT h AS HANDLE) IN SUPER.
FUNCTION setCallerWindow RETURNS LOGICAL
  (INPUT h AS HANDLE) IN SUPER.
FUNCTION setContainerMode RETURNS LOGICAL
  (INPUT cContainerMode AS CHARACTER) IN SUPER.
FUNCTION setContainerTarget RETURNS LOGICAL
  (INPUT pcObject AS CHARACTER) IN SUPER.
FUNCTION setCurrentPage RETURNS LOGICAL
  (INPUT iPage AS INTEGER) IN SUPER.
FUNCTION setDisabledAddModeTabs RETURNS LOGICAL
  (INPUT cDisabledAddModeTabs AS CHARACTER) IN SUPER.
FUNCTION setDynamicSDOProcedure RETURNS LOGICAL
  (INPUT pcProc AS CHARACTER) IN SUPER.
FUNCTION setFilterSource RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setInMessageTarget RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setMultiInstanceActivated RETURNS LOGICAL
  (INPUT lMultiInstanceActivated AS LOGICAL) IN SUPER.
FUNCTION setMultiInstanceSupported RETURNS LOGICAL
  (INPUT lMultiInstanceSupported AS LOGICAL) IN SUPER.
FUNCTION setNavigationSource RETURNS LOGICAL
  (INPUT pcSource AS CHARACTER) IN SUPER.
FUNCTION setNavigationSourceEvents RETURNS LOGICAL
  (INPUT pcEvents AS CHARACTER) IN SUPER.
FUNCTION setNavigationTarget RETURNS LOGICAL
  (INPUT cTarget AS CHARACTER) IN SUPER.
FUNCTION setOutMessageTarget RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setPageNTarget RETURNS LOGICAL
  (INPUT pcObject AS CHARACTER) IN SUPER.
FUNCTION setPageSource RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setPrimarySdoTarget RETURNS LOGICAL
  (INPUT hPrimarySdoTarget AS HANDLE) IN SUPER.
FUNCTION setReEnableDataLinks RETURNS LOGICAL
  (INPUT cReEnableDataLinks AS CHARACTER) IN SUPER.
FUNCTION setRouterTarget RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setRunDOOptions RETURNS LOGICAL
  (INPUT pcOptions AS CHARACTER) IN SUPER.
FUNCTION setRunMultiple RETURNS LOGICAL
  (INPUT plMultiple AS LOGICAL) IN SUPER.
FUNCTION setSavedContainerMode RETURNS LOGICAL
  (INPUT cSavedContainerMode AS CHARACTER) IN SUPER.
FUNCTION setSdoForeignFields RETURNS LOGICAL
  (INPUT cSdoForeignFields AS CHARACTER) IN SUPER.
FUNCTION setTopOnly RETURNS LOGICAL
  (INPUT plTopOnly AS LOGICAL) IN SUPER.
FUNCTION setUpdateSource RETURNS LOGICAL
  (INPUT pcSource AS CHARACTER) IN SUPER.
FUNCTION setUpdateTarget RETURNS LOGICAL
  (INPUT pcTarget AS CHARACTER) IN SUPER.
FUNCTION setWaitForObject RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setWindowTitleViewer RETURNS LOGICAL
  (INPUT phViewer AS HANDLE) IN SUPER.
FUNCTION getObjectType RETURNS CHARACTER IN SUPER.
FUNCTION setStatusArea RETURNS LOGICAL
  (INPUT plStatusArea AS LOGICAL) IN SUPER.
PROCEDURE applyLayout IN SUPER:
END PROCEDURE.
PROCEDURE disableObject IN SUPER:
END PROCEDURE.
PROCEDURE enableObject IN SUPER:
END PROCEDURE.
PROCEDURE initializeObject IN SUPER:
END PROCEDURE.
PROCEDURE processAction IN SUPER:
  DEFINE INPUT PARAMETER pcAction AS CHARACTER.
END PROCEDURE.
FUNCTION getAllFieldHandles RETURNS CHARACTER IN SUPER.
FUNCTION getAllFieldNames RETURNS CHARACTER IN SUPER.
FUNCTION getCol RETURNS DECIMAL IN SUPER.
FUNCTION getDefaultLayout RETURNS CHARACTER IN SUPER.
FUNCTION getDisableOnInit RETURNS LOGICAL IN SUPER.
FUNCTION getEnabledObjFlds RETURNS CHARACTER IN SUPER.
FUNCTION getEnabledObjHdls RETURNS CHARACTER IN SUPER.
FUNCTION getHeight RETURNS DECIMAL IN SUPER.
FUNCTION getHideOnInit RETURNS LOGICAL IN SUPER.
FUNCTION getLayoutOptions RETURNS CHARACTER IN SUPER.
FUNCTION getLayoutVariable RETURNS CHARACTER IN SUPER.
FUNCTION getObjectEnabled RETURNS LOGICAL IN SUPER.
FUNCTION getObjectLayout RETURNS CHARACTER IN SUPER.
FUNCTION getRow RETURNS DECIMAL IN SUPER.
FUNCTION getWidth RETURNS DECIMAL IN SUPER.
FUNCTION getResizeHorizontal RETURNS LOGICAL IN SUPER.
FUNCTION getResizeVertical RETURNS LOGICAL IN SUPER.
FUNCTION setAllFieldHandles RETURNS LOGICAL
  (INPUT pcValue AS CHARACTER) IN SUPER.
FUNCTION setAllFieldNames RETURNS LOGICAL
  (INPUT pcValue AS CHARACTER) IN SUPER.
FUNCTION setDefaultLayout RETURNS LOGICAL
  (INPUT pcDefault AS CHARACTER) IN SUPER.
FUNCTION setDisableOnInit RETURNS LOGICAL
  (INPUT plDisable AS LOGICAL) IN SUPER.
FUNCTION setHideOnInit RETURNS LOGICAL
  (INPUT plHide AS LOGICAL) IN SUPER.
FUNCTION setLayoutOptions RETURNS LOGICAL
  (INPUT pcOptions AS CHARACTER) IN SUPER.
FUNCTION setObjectLayout RETURNS LOGICAL
  (INPUT pcLayout AS CHARACTER) IN SUPER.
FUNCTION setResizeHorizontal RETURNS LOGICAL
  (INPUT plResizeHorizontal AS LOGICAL) IN SUPER.
FUNCTION setResizeVertical RETURNS LOGICAL
  (INPUT plResizeVertical AS LOGICAL) IN SUPER.
FUNCTION getObjectType RETURNS CHARACTER IN SUPER.
FUNCTION getObjectTranslated RETURNS LOGICAL IN SUPER.
FUNCTION getObjectSecured RETURNS LOGICAL IN SUPER.
FUNCTION createUiEvents RETURNS LOGICAL IN SUPER.
PROCEDURE bindServer IN SUPER:
END PROCEDURE.
PROCEDURE destroyObject IN SUPER:
END PROCEDURE.
PROCEDURE destroyServerObject IN SUPER:
END PROCEDURE.
PROCEDURE disconnectObject IN SUPER:
END PROCEDURE.
PROCEDURE initializeServerObject IN SUPER:
END PROCEDURE.
PROCEDURE restartServerObject IN SUPER:
END PROCEDURE.
PROCEDURE runServerObject IN SUPER:
  DEFINE INPUT PARAMETER phAppService AS HANDLE.
END PROCEDURE.
PROCEDURE startServerObject IN SUPER:
END PROCEDURE.
PROCEDURE unbindServer IN SUPER:
  DEFINE INPUT PARAMETER pcMode AS CHARACTER.
END PROCEDURE.
FUNCTION getAppService RETURNS CHARACTER IN SUPER.
FUNCTION getASBound RETURNS LOGICAL IN SUPER.
FUNCTION getAsDivision RETURNS CHARACTER IN SUPER.
FUNCTION getASHandle RETURNS HANDLE IN SUPER.
FUNCTION getASHasStarted RETURNS LOGICAL IN SUPER.
FUNCTION getASInfo RETURNS CHARACTER IN SUPER.
FUNCTION getASInitializeOnRun RETURNS LOGICAL IN SUPER.
FUNCTION getASUsePrompt RETURNS LOGICAL IN SUPER.
FUNCTION getServerFileName RETURNS CHARACTER IN SUPER.
FUNCTION getServerOperatingMode RETURNS CHARACTER IN SUPER.
FUNCTION runServerProcedure RETURNS HANDLE
  (INPUT pcServerFileName AS CHARACTER,
   INPUT phAppService AS HANDLE) IN SUPER.
FUNCTION setAppService RETURNS LOGICAL
  (INPUT pcAppService AS CHARACTER) IN SUPER.
FUNCTION setASDivision RETURNS LOGICAL
  (INPUT pcDivision AS CHARACTER) IN SUPER.
FUNCTION setASHandle RETURNS LOGICAL
  (INPUT phASHandle AS HANDLE) IN SUPER.
FUNCTION setASInfo RETURNS LOGICAL
  (INPUT pcInfo AS CHARACTER) IN SUPER.
FUNCTION setASInitializeOnRun RETURNS LOGICAL
  (INPUT plInitialize AS LOGICAL) IN SUPER.
FUNCTION setASUsePrompt RETURNS LOGICAL
  (INPUT plFlag AS LOGICAL) IN SUPER.
FUNCTION setServerFileName RETURNS LOGICAL
  (INPUT pcFileName AS CHARACTER) IN SUPER.
FUNCTION setServerOperatingMode RETURNS LOGICAL
  (INPUT pcServerOperatingMode AS CHARACTER) IN SUPER.
FUNCTION getObjectType RETURNS CHARACTER IN SUPER.
DEFINE NEW GLOBAL SHARED VARIABLE  gshAstraAppserver     AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshSessionManager     AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshRIManager          AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshSecurityManager    AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshProfileManager     AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshRepositoryManager  AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshTranslationManager AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshWebManager         AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gscSessionId          AS CHARACTER NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdSessionObj         AS DECIMAL DECIMALS 9 NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshFinManager         AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshGenManager         AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshAgnManager         AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdTempUniqueID       AS DECIMAL DECIMALS 9  NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdUserObj            AS DECIMAL DECIMALS 9  NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdRenderTypeObj      AS DECIMAL DECIMALS 9  NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdSessionScopeObj    AS DECIMAL DECIMALS 9  NO-UNDO.
 DEFINE VARIABLE ghProp                AS HANDLE  NO-UNDO.
 DEFINE VARIABLE ghADMProps            AS HANDLE  NO-UNDO.
 DEFINE VARIABLE ghADMPropsBuf         AS HANDLE  NO-UNDO.
 DEFINE VARIABLE glADMLoadFromRepos    AS LOGICAL NO-UNDO.
 DEFINE VARIABLE glADMOk               AS LOGICAL NO-UNDO.
FUNCTION getObjectType RETURNS CHARACTER
  ( )  FORWARD.
PROCEDURE addLink IN SUPER:
  DEFINE INPUT PARAMETER phSource AS HANDLE.
  DEFINE INPUT PARAMETER pcLink AS CHARACTER.
  DEFINE INPUT PARAMETER phTarget AS HANDLE.
END PROCEDURE.
PROCEDURE addMessage IN SUPER:
  DEFINE INPUT PARAMETER pcText AS CHARACTER.
  DEFINE INPUT PARAMETER pcField AS CHARACTER.
  DEFINE INPUT PARAMETER pcTable AS CHARACTER.
END PROCEDURE.
PROCEDURE adjustTabOrder IN SUPER:
  DEFINE INPUT PARAMETER phObject AS HANDLE.
  DEFINE INPUT PARAMETER phAnchor AS HANDLE.
  DEFINE INPUT PARAMETER pcPosition AS CHARACTER.
END PROCEDURE.
PROCEDURE applyEntry IN SUPER:
  DEFINE INPUT PARAMETER pcField AS CHARACTER.
END PROCEDURE.
PROCEDURE changeCursor IN SUPER:
  DEFINE INPUT PARAMETER pcCursor AS CHARACTER.
END PROCEDURE.
PROCEDURE createControls IN SUPER:
END PROCEDURE.
PROCEDURE destroyObject IN SUPER:
END PROCEDURE.
PROCEDURE displayLinks IN SUPER:
END PROCEDURE.
PROCEDURE editInstanceProperties IN SUPER:
END PROCEDURE.
PROCEDURE exitObject IN SUPER:
END PROCEDURE.
PROCEDURE hideObject IN SUPER:
END PROCEDURE.
PROCEDURE initializeObject IN SUPER:
END PROCEDURE.
PROCEDURE modifyListProperty IN SUPER:
  DEFINE INPUT PARAMETER phCaller AS HANDLE.
  DEFINE INPUT PARAMETER pcMode AS CHARACTER.
  DEFINE INPUT PARAMETER pcListName AS CHARACTER.
  DEFINE INPUT PARAMETER pcListValue AS CHARACTER.
END PROCEDURE.
PROCEDURE modifyUserLinks IN SUPER:
  DEFINE INPUT PARAMETER pcMod AS CHARACTER.
  DEFINE INPUT PARAMETER pcLinkName AS CHARACTER.
  DEFINE INPUT PARAMETER phObject AS HANDLE.
END PROCEDURE.
PROCEDURE removeAllLinks IN SUPER:
END PROCEDURE.
PROCEDURE removeLink IN SUPER:
  DEFINE INPUT PARAMETER phSource AS HANDLE.
  DEFINE INPUT PARAMETER pcLink AS CHARACTER.
  DEFINE INPUT PARAMETER phTarget AS HANDLE.
END PROCEDURE.
PROCEDURE repositionObject IN SUPER:
  DEFINE INPUT PARAMETER pdRow AS DECIMAL.
  DEFINE INPUT PARAMETER pdCol AS DECIMAL.
END PROCEDURE.
PROCEDURE returnFocus IN SUPER:
  DEFINE INPUT PARAMETER hTarget AS HANDLE.
END PROCEDURE.
PROCEDURE showMessageProcedure IN SUPER:
  DEFINE INPUT PARAMETER pcMessage AS CHARACTER.
  DEFINE OUTPUT PARAMETER plAnswer AS LOGICAL.
END PROCEDURE.
PROCEDURE toggleData IN SUPER:
  DEFINE INPUT PARAMETER plEnabled AS LOGICAL.
END PROCEDURE.
PROCEDURE viewObject IN SUPER:
END PROCEDURE.
FUNCTION anyMessage RETURNS LOGICAL IN SUPER.
FUNCTION assignLinkProperty RETURNS LOGICAL
  (INPUT pcLink AS CHARACTER,
   INPUT pcPropName AS CHARACTER,
   INPUT pcPropValue AS CHARACTER) IN SUPER.
FUNCTION fetchMessages RETURNS CHARACTER IN SUPER.
FUNCTION getChildDataKey RETURNS CHARACTER IN SUPER.
FUNCTION getContainerHandle RETURNS HANDLE IN SUPER.
FUNCTION getContainerHidden RETURNS LOGICAL IN SUPER.
FUNCTION getContainerSource RETURNS HANDLE IN SUPER.
FUNCTION getContainerSourceEvents RETURNS CHARACTER IN SUPER.
FUNCTION getContainerType RETURNS CHARACTER IN SUPER.
FUNCTION getDataLinksEnabled RETURNS LOGICAL IN SUPER.
FUNCTION getDataSource RETURNS HANDLE IN SUPER.
FUNCTION getDataSourceEvents RETURNS CHARACTER IN SUPER.
FUNCTION getDataSourceNames RETURNS CHARACTER IN SUPER.
FUNCTION getDataTarget RETURNS CHARACTER IN SUPER.
FUNCTION getDataTargetEvents RETURNS CHARACTER IN SUPER.
FUNCTION getDBAware RETURNS LOGICAL IN SUPER.
FUNCTION getDesignDataObject RETURNS CHARACTER IN SUPER.
FUNCTION getDynamicObject RETURNS LOGICAL IN SUPER.
FUNCTION getInstanceProperties RETURNS CHARACTER IN SUPER.
FUNCTION getLogicalObjectName RETURNS CHARACTER IN SUPER.
FUNCTION getLogicalVersion RETURNS CHARACTER IN SUPER.
FUNCTION getObjectHidden RETURNS LOGICAL IN SUPER.
FUNCTION getObjectInitialized RETURNS LOGICAL IN SUPER.
FUNCTION getObjectName RETURNS CHARACTER IN SUPER.
FUNCTION getObjectPage RETURNS INTEGER IN SUPER.
FUNCTION getObjectParent RETURNS HANDLE IN SUPER.
FUNCTION getObjectVersion RETURNS CHARACTER IN SUPER.
FUNCTION getObjectVersionNumber RETURNS CHARACTER IN SUPER.
FUNCTION getParentDataKey RETURNS CHARACTER IN SUPER.
FUNCTION getPassThroughLinks RETURNS CHARACTER IN SUPER.
FUNCTION getPhysicalObjectName RETURNS CHARACTER IN SUPER.
FUNCTION getPhysicalVersion RETURNS CHARACTER IN SUPER.
FUNCTION getPropertyDialog RETURNS CHARACTER IN SUPER.
FUNCTION getQueryObject RETURNS LOGICAL IN SUPER.
FUNCTION getRunAttribute RETURNS CHARACTER IN SUPER.
FUNCTION getSupportedLinks RETURNS CHARACTER IN SUPER.
FUNCTION getTranslatableProperties RETURNS CHARACTER IN SUPER.
FUNCTION getUIBMode RETURNS CHARACTER IN SUPER.
FUNCTION getUserProperty RETURNS CHARACTER
  (INPUT pcPropName AS CHARACTER) IN SUPER.
FUNCTION instancePropertyList RETURNS CHARACTER
  (INPUT pcPropList AS CHARACTER) IN SUPER.
FUNCTION linkHandles RETURNS CHARACTER
  (INPUT pcLink AS CHARACTER) IN SUPER.
FUNCTION linkProperty RETURNS CHARACTER
  (INPUT pcLink AS CHARACTER,
   INPUT pcPropName AS CHARACTER) IN SUPER.
FUNCTION mappedEntry RETURNS CHARACTER
  (INPUT pcEntry AS CHARACTER,
   INPUT pcList AS CHARACTER,
   INPUT plFirst AS LOGICAL,
   INPUT pcDelimiter AS CHARACTER) IN SUPER.
FUNCTION messageNumber RETURNS CHARACTER
  (INPUT piMessage AS INTEGER) IN SUPER.
FUNCTION propertyType RETURNS CHARACTER
  (INPUT pcPropName AS CHARACTER) IN SUPER.
FUNCTION reviewMessages RETURNS CHARACTER IN SUPER.
FUNCTION setChildDataKey RETURNS LOGICAL
  (INPUT cChildDataKey AS CHARACTER) IN SUPER.
FUNCTION setContainerHidden RETURNS LOGICAL
  (INPUT plHidden AS LOGICAL) IN SUPER.
FUNCTION setContainerSource RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setContainerSourceEvents RETURNS LOGICAL
  (INPUT pcEvents AS CHARACTER) IN SUPER.
FUNCTION setDataLinksEnabled RETURNS LOGICAL
  (INPUT lDataLinksEnabled AS LOGICAL) IN SUPER.
FUNCTION setDataSource RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setDataSourceEvents RETURNS LOGICAL
  (INPUT pcEventsList AS CHARACTER) IN SUPER.
FUNCTION setDataSourceNames RETURNS LOGICAL
  (INPUT pcSourceNames AS CHARACTER) IN SUPER.
FUNCTION setDataTarget RETURNS LOGICAL
  (INPUT pcTarget AS CHARACTER) IN SUPER.
FUNCTION setDataTargetEvents RETURNS LOGICAL
  (INPUT pcEvents AS CHARACTER) IN SUPER.
FUNCTION setDBAware RETURNS LOGICAL
  (INPUT lAware AS LOGICAL) IN SUPER.
FUNCTION setDesignDataObject RETURNS LOGICAL
  (INPUT pcDataObject AS CHARACTER) IN SUPER.
FUNCTION setDynamicObject RETURNS LOGICAL
  (INPUT lTemp AS LOGICAL) IN SUPER.
FUNCTION setInstanceProperties RETURNS LOGICAL
  (INPUT pcPropList AS CHARACTER) IN SUPER.
FUNCTION setLogicalObjectName RETURNS LOGICAL
  (INPUT c AS CHARACTER) IN SUPER.
FUNCTION setLogicalVersion RETURNS LOGICAL
  (INPUT cVersion AS CHARACTER) IN SUPER.
FUNCTION setObjectName RETURNS LOGICAL
  (INPUT pcName AS CHARACTER) IN SUPER.
FUNCTION setObjectParent RETURNS LOGICAL
  (INPUT phParent AS HANDLE) IN SUPER.
FUNCTION setObjectVersion RETURNS LOGICAL
  (INPUT cObjectVersion AS CHARACTER) IN SUPER.
FUNCTION setParentDataKey RETURNS LOGICAL
  (INPUT cParentDataKey AS CHARACTER) IN SUPER.
FUNCTION setPassThroughLinks RETURNS LOGICAL
  (INPUT pcLinks AS CHARACTER) IN SUPER.
FUNCTION setPhysicalObjectName RETURNS LOGICAL
  (INPUT cTemp AS CHARACTER) IN SUPER.
FUNCTION setPhysicalVersion RETURNS LOGICAL
  (INPUT cVersion AS CHARACTER) IN SUPER.
FUNCTION setRunAttribute RETURNS LOGICAL
  (INPUT cRunAttribute AS CHARACTER) IN SUPER.
FUNCTION setSupportedLinks RETURNS LOGICAL
  (INPUT pcLinkList AS CHARACTER) IN SUPER.
FUNCTION setTranslatableProperties RETURNS LOGICAL
  (INPUT pcPropList AS CHARACTER) IN SUPER.
FUNCTION setUIBMode RETURNS LOGICAL
  (INPUT pcMode AS CHARACTER) IN SUPER.
FUNCTION setUserProperty RETURNS LOGICAL
  (INPUT pcPropName AS CHARACTER,
   INPUT pcPropValue AS CHARACTER) IN SUPER.
FUNCTION showmessage RETURNS LOGICAL
  (INPUT pcMessage AS CHARACTER) IN SUPER.
FUNCTION Signature RETURNS CHARACTER
  (INPUT pcName AS CHARACTER) IN SUPER.
FUNCTION getObjectType RETURNS CHARACTER IN SUPER.
  IF VALID-HANDLE(gshRepositoryManager) THEN
  DO:
    IF TRUE THEN
    DO:
      IF NOT
      DYNAMIC-FUNC('prepareInstance':U IN gshRepositoryManager,
                          STRING(THIS-PROCEDURE) + ',':U + STRING(FRAME gDialog:HANDLE) + ',':U + STRING(BROWSE BROWSE-2:HANDLE),SOURCE-PROCEDURE)
      then
      DO:
        STOP.
      END.
      ASSIGN
        ghADMPropsBuf      = WIDGET-HANDLE(ENTRY(1, THIS-PROCEDURE:ADM-DATA, CHR(1))).
        glADMLoadFromRepos = VALID-HANDLE(ghADMPropsBUF).
    END.
  END.
 IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
 DO:
  CREATE TEMP-TABLE ghADMProps.
  ghADMProps:UNDO    = FALSE.
  ghADMProps:ADD-NEW-FIELD('ObjectName':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ObjectVersion':U, 'CHAR':U, 0, ?,
    'ADM2.2':U).
  ghADMProps:ADD-NEW-FIELD('ObjectType':U, 'CHAR':U, 0, ?,
    'SmartDialog':U).
  ghADMProps:ADD-NEW-FIELD('ContainerType':U, 'CHAR':U, 0, ?,
    'DIALOG-BOX':U).
  ghADMProps:ADD-NEW-FIELD('PropertyDialog':U, 'CHAR':U, 0, ?,
    'adm2/support/visuald.w':U).
  ghADMProps:ADD-NEW-FIELD('QueryObject':U, 'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('ContainerHandle':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('InstanceProperties':U, 'CHAR':U, 0, ?,
    'LogicalObjectName,PhysicalObjectName,DynamicObject,RunAttribute,HideOnInit,DisableOnInit,ObjectLayout':U ).
  ghADMProps:ADD-NEW-FIELD('SupportedLinks':U, 'CHAR':U, 0, ?,
    'Data-Target,Data-Source,Page-Target,Update-Source,Update-Target':U).
  ghADMProps:ADD-NEW-FIELD('ContainerHidden':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('ObjectInitialized':U, 'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('ObjectHidden':U, 'LOGICAL':U, 0, ?, yes).
  ghADMProps:ADD-NEW-FIELD('HideOnInit':U, 'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('UIBMode':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ContainerSource':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('ContainerSourceEvents':U, 'CHAR':U, 0, ?,
    'initializeObject,hideObject,viewObject,destroyObject,enableObject,confirmExit,confirmCancel,confirmOk,isUpdateActive':U).
  ghADMProps:ADD-NEW-FIELD('DataSource':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('DataSourceEvents':U, 'CHAR':U, 0, ?,
    'dataAvailable,queryPosition,updateState,deleteComplete,fetchDataSet,confirmContinue,confirmCommit,confirmUndo,assignMaxGuess,isUpdatePending':U).
  ghADMProps:ADD-NEW-FIELD('TranslatableProperties':U, 'CHAR':U, 0, ?,
    '':U).
  ghADMProps:ADD-NEW-FIELD('ObjectPage':U, 'INT':U, 0, ?, 0).
  ghADMProps:ADD-NEW-FIELD('DBAware':U, 'LOGICAL':U, 0, ?,
                          no).
  ghADMProps:ADD-NEW-FIELD('DesignDataObject':U, 'CHAR':U, 0, ?,'':U).
  ghADMProps:ADD-NEW-FIELD('DataSourceNames':U, 'CHAR':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('DataTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('DataTargetEvents':U, 'CHARACTER':U, 0, ?,
     'updateState,rowObjectState,fetchBatch,LinkState':U).
  ghADMProps:ADD-NEW-FIELD('LogicalObjectName':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PhysicalObjectName':U, 'CHARACTER':U, ?, ?, "":U).
  ghADMProps:ADD-NEW-FIELD('LogicalVersion':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PhysicalVersion':U, 'CHARACTER':U, ?, ?, "":U).
  ghADMProps:ADD-NEW-FIELD('DynamicObject':U, 'LOGICAL':U).
  ghADMProps:ADD-NEW-FIELD('RunAttribute':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ChildDataKey':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ParentDataKey':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('DataLinksEnabled':U, 'LOGICAL':U, ?, ?, YES).
  ghADMProps:ADD-NEW-FIELD('InactiveLinks':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('InstanceId':U, 'DECIMAL':U).
  ghADMProps:ADD-NEW-FIELD('SuperProcedure':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('SuperProcedureMode':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('SuperProcedureHandle':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('LayoutPosition':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ClassName':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('RenderingProcedure':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ThinRenderingProcedure':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('Label':U, 'CHAR':U, 0, ?, ?).
END.
FUNCTION getObjectType RETURNS CHARACTER
  ( ) :
  DEFINE VARIABLE cType AS CHARACTER NO-UNDO.
ASSIGN
 ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
 glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
          ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
 cType = ghProp:BUFFER-FIELD('ObjectType':U):BUFFER-VALUE
  NO-ERROR.
  RETURN cType.
END FUNCTION.
IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
DO:
  ghADMProps:ADD-NEW-FIELD('AppService':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ASDivision':U, 'CHAR':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ASHandle':U, 'HANDLE':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ASHasConnected':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('ASHasStarted':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('ASInfo':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ASInitializeOnRun':U, 'LOGICAL':U, 0, ?, YES).
  ghADMProps:ADD-NEW-FIELD('ASUsePrompt':U, 'LOGICAL':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('BindSignature':U, 'CHAR':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('BindScope':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ServerOperatingMode':U, 'CHAR':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ServerFileName':U,  'CHAR':U, 0, ?,?).
  ghADMProps:ADD-NEW-FIELD('ServerFirstCall':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('NeedContext':U, 'LOGICAL':U, 0, ?, ?).
END.
IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
DO:
  ghADMProps:ADD-NEW-FIELD('ObjectLayout':U,     'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('LayoutOptions':U,    'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ObjectEnabled':U,    'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('LayoutVariable':U,   'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('DefaultLayout':U,    'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('DisableOnInit':U,    'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('EnabledObjFlds':U,   'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('EnabledObjHdls':U,   'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('FieldSecurity':U,    'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('SecuredTokens':U,    'CHARACTER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('AllFieldHandles':U,  'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('AllFieldNames':U,    'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('MinHeight':U,        'DECIMAL':U, 0, ?, 0).
  ghADMProps:ADD-NEW-FIELD('MinWidth':U,         'DECIMAL':U, 0, ?, 0).
  ghADMProps:ADD-NEW-FIELD('ResizeHorizontal':U, 'LOGICAL':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ResizeVertical':U,   'LOGICAL':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ObjectSecured':U,    'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('ObjectTranslated':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('PopupButtonsInFields':U, 'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('ColorInfoBG':U,      'INTEGER':U, 0, ?, 10).
  ghADMProps:ADD-NEW-FIELD('ColorInfoFG':U,      'INTEGER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ColorWarnBG':U,      'INTEGER':U, 0, ?, 3).
  ghADMProps:ADD-NEW-FIELD('ColorWarnFG':U,      'INTEGER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ColorErrorBG':U,     'INTEGER':U, 0, ?, 12).
  ghADMProps:ADD-NEW-FIELD('ColorErrorFG':U,     'INTEGER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('BGColor':U,          'INTEGER':U, 0, ?, 12).
  ghADMProps:ADD-NEW-FIELD('FGColor':U,          'INTEGER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('FieldPopupMapping','CHARACTER':U, 0, ?, '':U).
END.
IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
DO:
  ghADMProps:ADD-NEW-FIELD('CurrentPage':U, 'INT':U, 0, ?, 0).
  ghADMProps:ADD-NEW-FIELD('PendingPage':U, 'INT':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ContainerTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ContainerTargetEvents':U, 'CHAR':U, 0, ?,
    'exitObject,okObject,cancelObject,updateActive':U).
  ghADMProps:ADD-NEW-FIELD('ContainerToolbarSource':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ContainerToolbarSourceEvents':U, 'CHAR':U, 0, ?,
    'toolbar,okObject,cancelObject':U).
  ghADMProps:ADD-NEW-FIELD('OutMessageTarget':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('PageNTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('PageSource':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('FilterSource':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('UpdateSource':U, 'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('UpdateTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('CommitSource':U, 'HANDLE':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('CommitSourceEvents':U, 'CHAR':U, 0, ?,
          'commitTransaction,undoTransaction':U).
  ghADMProps:ADD-NEW-FIELD('CommitTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('CommitTargetEvents':U, 'CHAR':U, 0, ?, 'rowObjectState':U).
  ghADMProps:ADD-NEW-FIELD('StartPage':U, 'INT':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('RunMultiple':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('WaitForObject':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('DynamicSDOProcedure':U, 'CHAR':U, 0, ?,
      'adm2/dyndata.w':U).
  ghADMProps:ADD-NEW-FIELD('RunDOOptions':U, 'CHARACTER':U, 0, ?,'':U).
  ghADMProps:ADD-NEW-FIELD('InitialPageList':U, 'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('WindowFrameHandle':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('Page0LayoutManager':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('MultiInstanceSupported':U, 'LOGICAL':U, ?, ? , NO ).
  ghADMProps:ADD-NEW-FIELD('MultiInstanceActivated':U, 'LOGICAL':U).
  ghADMProps:ADD-NEW-FIELD('ContainerMode':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('SavedContainerMode':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('SdoForeignFields':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('NavigationSource':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('NavigationTarget':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PrimarySdoTarget':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('NavigationSourceEvents':U, 'CHAR':U, 0, ?,
    'fetchFirst,fetchNext,fetchPrev,fetchLast,startFilter':U).
  ghADMProps:ADD-NEW-FIELD('CallerWindow':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('CallerProcedure':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('CallerObject':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('DisabledAddModeTabs':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ReEnableDataLinks':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('WindowTitleViewer':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('UpdateActive':U, 'LOGICAL':U).
  ghADMProps:ADD-NEW-FIELD('ObjectsCreated':U, 'LOGICAL':U).
  ghADMProps:ADD-NEW-FIELD('InstanceNames':U, 'CHARACTER':U, 0, ?,'':U) .
  ghADMProps:ADD-NEW-FIELD('ClientNames':U, 'CHARACTER':U, 0, ?,'':U) .
  ghADMProps:ADD-NEW-FIELD('ContainedDataObjects':U, 'CHARACTER':U, 0, ?,'':U).
  ghADMProps:ADD-NEW-FIELD('ContainedAppServices':U, 'CHARACTER':U, 0, ?,'':U).
  ghADMProps:ADD-NEW-FIELD('DataContainer':U, 'LOGICAL':U, 0, ?,NO).
  ghADMProps:ADD-NEW-FIELD('HasDbAwareObjects':U, 'LOGICAL':U, 0, ?,?).
  ghADMProps:ADD-NEW-FIELD('HasDynamicProxy':U, 'LOGICAL':U, 0, ?,NO).
  ghADMProps:ADD-NEW-FIELD('HideOnClose':U, 'LOGICAL':U, 0, ?,NO).
  ghADMProps:ADD-NEW-FIELD('HideChildContainersOnClose':U, 'LOGICAL':U, 0, ?,?).
  ghADMProps:ADD-NEW-FIELD('HasObjectMenu':U, 'LOGICAL':U, 0, ?,NO).
  ghADMProps:ADD-NEW-FIELD('RequiredPages':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('RemoveMenuOnHide':U, 'LOGICAL':U, 0, ?, TRUE).
  ghADMProps:ADD-NEW-FIELD('ProcessList':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PageLayoutInfo':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PageTokens':U, 'CHARACTER':U).
END.
DEFINE VARIABLE ghContainer AS HANDLE NO-UNDO.
ghContainer = FRAME gDialog:HANDLE.
    IF NOT glADMLoadFromRepos THEN
      RUN start-super-proc ("adm2/smart.p":U).
    DEFINE VARIABLE cObjectName AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE iStart      AS INTEGER    NO-UNDO.
  IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
  DO:
    ghADMProps:TEMP-TABLE-PREPARE('ADMProps':U).
    ghADMPropsBuf = ghADMProps:DEFAULT-BUFFER-HANDLE.
    ghADMPropsBuf:BUFFER-CREATE().
    THIS-PROCEDURE:ADM-DATA = STRING(ghADMPropsBuf) + CHR(1) + CHR(1).
    cObjectName =  'LogicalObjectName,PhysicalObjectName,DynamicObject,RunAttribute,HideOnInit,DisableOnInit,ObjectLayout':U.
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('InstanceProperties':U):BUFFER-VALUE = cObjectName
 .
    ASSIGN cObjectName = REPLACE(THIS-PROCEDURE:FILE-NAME, "~\":U, "~/":U)
           iStart = R-INDEX(cObjectName, "~/":U) + 1
           cObjectName =
                IF R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U) <= iStart THEN
                   SUBSTR(cObjectName, iStart)
                ELSE
                   SUBSTR(cObjectName,
                          iStart,
                          R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U) - iStart).
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('ObjectName':U):BUFFER-VALUE = cObjectName
 .
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('ContainerHandle':U):BUFFER-VALUE = FRAME gDialog:HANDLE
 .
  END.
  ELSE DO:
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('ObjectType':U):BUFFER-VALUE = 'SmartDialog':U
  ghProp:BUFFER-FIELD('ContainerType':U):BUFFER-VALUE = 'DIALOG-BOX':U
  ghProp:BUFFER-FIELD('PhysicalVersion':U):BUFFER-VALUE = '':U
  ghProp:BUFFER-FIELD('PhysicalObjectName':U):BUFFER-VALUE = (IF '':U <> '':U THEN '':U ELSE THIS-PROCEDURE:FILE-NAME)
    .
  END.
PROCEDURE adm-clone-props :
  DEFINE VARIABLE hReposBuffer AS HANDLE     NO-UNDO.
  DEFINE VARIABLE hPropTable   AS HANDLE     NO-UNDO.
  DEFINE VARIABLE hBuffer      AS HANDLE     NO-UNDO.
  DEFINE VARIABLE hTable       AS HANDLE     NO-UNDO.
  hReposBuffer = WIDGET-H(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1))).
  IF VALID-HANDLE(hReposBuffer) AND hReposBuffer:NAME <> 'ADMProps':U THEN
  DO:
    hReposBuffer:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(THIS-PROCEDURE) + '")':U)
    NO-ERROR.
    IF hReposBuffer:AVAIL THEN
    DO:
      CREATE TEMP-TABLE hPropTable.
      hPropTable:CREATE-LIKE(hReposBuffer).
      hPropTable:TEMP-TABLE-PREPARE('ADMProps':U).
      hBuffer = hPropTable:DEFAULT-BUFFER-HANDLE.
      hBuffer:BUFFER-CREATE().
      hBuffer:BUFFER-COPY(hReposBuffer).
      dynamic-function("deleteProperties":U IN TARGET-PROCEDURE)
 .
      THIS-PROCEDURE:ADM-DATA = STRING(hBuffer) + CHR(1) + CHR(1).
    END.
  END.
END PROCEDURE.
PROCEDURE start-super-proc :
  DEFINE INPUT PARAMETER pcProcName AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE        hProc      AS HANDLE     NO-UNDO.
  hProc = SESSION:FIRST-PROCEDURE.
  DO WHILE VALID-HANDLE(hProc) AND hProc:FILE-NAME NE pcProcName:
    hProc = hProc:NEXT-SIBLING.
  END.
  IF NOT VALID-HANDLE(hProc) THEN
    RUN VALUE(pcProcName) PERSISTENT SET hProc.
  THIS-PROCEDURE:ADD-SUPER-PROCEDURE(hProc, SEARCH-TARGET).
  RETURN.
END PROCEDURE.
  DEFINE VARIABLE cAppService          AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cASDivision          AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cServerOperatingMode AS CHARACTER  NO-UNDO.
  IF NOT glADMLoadFromRepos THEN
    RUN start-super-proc("adm2/appserver.p":U).
 cAppService = DYNAMIC-FUNC('getAppService':U IN TARGET-PROCEDURE)
 .
  IF SESSION:REMOTE THEN
  DO:
    ASSIGN cAppService          = '':U
           cASDivision          = 'Server':U
           cServerOperatingMode = CAPS(SESSION:SERVER-OPERATING-MODE).
  END.
  ELSE IF cAppService = '':U THEN
    ASSIGN cAppService  = '':U.
  IF cASDivision = '':U THEN
     cServerOperatingMode = 'NONE':U.
  ELSE
   DYNAMIC-FUNC('setASDivision':U IN TARGET-PROCEDURE,cASDivision)
 .
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('ServerOperatingMode':U):BUFFER-VALUE = cServerOperatingMode
 .
   DYNAMIC-FUNC('setAppService':U IN TARGET-PROCEDURE,cAppService)
 .
DEFINE VARIABLE cFields AS CHARACTER NO-UNDO.
IF NOT glADMLoadFromRepos THEN
  RUN start-super-proc ("adm2/visual.p":U).
  cFields =  REPLACE("B-mark b-delmark f-day-shift b-enter B-exit BROWSE-2":U, " ":U, ",":U).
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('EnabledObjFlds':U):BUFFER-VALUE = cFields
 .
  IF VALID-HANDLE(gshSessionManager) THEN
  DO:
    ON HELP OF FRAME gDialog ANYWHERE
      RUN contextHelp IN gshSessionManager (INPUT THIS-PROCEDURE, INPUT FOCUS).
  END.
  ON CTRL-PAGE-UP OF FRAME gDialog ANYWHERE DO:
    RUN processAction IN TARGET-PROCEDURE (INPUT "CTRL-PAGE-UP":U).
  END.
  ON CTRL-PAGE-DOWN OF FRAME gDialog ANYWHERE DO:
    RUN processAction IN TARGET-PROCEDURE (INPUT "CTRL-PAGE-DOWN":U).
  END.
IF NOT glADMLoadFromRepos THEN
DO:
  RUN start-super-proc("adm2/containr.p":U).
  RUN modifyListProperty IN TARGET-PROCEDURE
                         (TARGET-PROCEDURE,
                          'Add':U,
                          'ContainerSourceEvents':U,
                          'initializeDataObjects':U).
  IF  CAN-DO(dynamic-function("getSupportedLinks":U IN TARGET-PROCEDURE)
 ,'data-target':U)
  AND CAN-DO(dynamic-function("getSupportedLinks":U IN TARGET-PROCEDURE)
 ,'data-source':U) THEN
    RUN modifyListProperty IN TARGET-PROCEDURE
                           (TARGET-PROCEDURE,
                            'Add':U,
                            'ContainerSourceEvents':U,
                            'buildDataRequest':U).
  IF NOT CAN-DO(dynamic-function("getSupportedLinks":U IN TARGET-PROCEDURE)
 ,'containertoolbar-target':U) THEN
    RUN modifyListProperty IN TARGET-PROCEDURE
                          (TARGET-PROCEDURE,
                           'Add':U,
                           'SupportedLinks':U,
                           'ContainerToolbar-Target':U).
END.
PAUSE 0 BEFORE-HIDE.
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('WindowFrameHandle':U):BUFFER-VALUE = FRAME gDialog:handle
 .
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('DataContainer':U):BUFFER-VALUE = TRUE
 .
ASSIGN
  FRAME gDialog:SCROLLABLE = FALSE
  FRAME gDialog:HIDDEN     = TRUE.
ON WINDOW-CLOSE OF FRAME gDialog
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.
ON CHOOSE OF b-enter IN FRAME gDialog
DO:
  define variable v-param-list  as character  no-undo.
  if not (mark-list = "" or mark-list = ?) then do:
    if f-day-shift = ?
    then do:
      message "Количество дней хранения маршрутизации" skip "не должно быть пустым" view-as alert-box.
      return no-apply.
    end.
    else do:
      v-param-list = mark-list + "!" + string(f-day-shift).
      run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list ).
      message "Параметры сохранены!" view-as alert-box information.
    end.
  end.
  else do:
    message "Заданны пустые параметры, сохранить?"
      view-as alert-box question buttons OK-Cancel
      update g#log.
    if g#log then run attach-attr-to-schedule-line in this-procedure ( INPUT "" ).
      else return no-apply.
  end.
END.
ON LEAVE OF f-day-shift IN FRAME gDialog
DO:
  assign
    f-day-shift.
END.
ON CHOOSE OF b-delmark IN FRAME gDialog
DO:
  define variable v-rec as rowid no-undo.
  v-rec = rowid (ext-system) .
  assign
    mark-list = "" .
  OPEN QUERY BROWSE-2 FOR EACH ext-system       WHERE ext-system.esys-type = 6  OR ext-system.esys-type = 7 NO-LOCK INDEXED-REPOSITION.
  reposition BROWSE-2 to rowid (v-rec) no-error.
  apply "entry" to BROWSE-2 in frame gDialog.
  apply "iteration-changed" to BROWSE-2 in frame gDialog.
  BROWSE-2:select-focused-row ().
END.
ON CHOOSE OF b-mark IN FRAME gDialog
DO:
  define variable n    as integer no-undo.
  define variable l-ok as logical no-undo.
  define variable v-rec as rowid no-undo.
  do n = 1 to BROWSE-2:num-selected-rows :
    l-ok = BROWSE-2:FETCH-SELECTED-ROW ( n ).
    if l-ok then do:
      run local-mark in this-procedure .
    end.
  end.
  v-rec = rowid (ext-system) .
  OPEN QUERY BROWSE-2 FOR EACH ext-system       WHERE ext-system.esys-type = 6  OR ext-system.esys-type = 7 NO-LOCK INDEXED-REPOSITION.
  reposition BROWSE-2 to rowid (v-rec) no-error.
  apply "entry" to BROWSE-2 in frame gDialog.
  apply "iteration-changed" to BROWSE-2 in frame gDialog.
  BROWSE-2:select-focused-row ().
  BROWSE-2:select-next-row ().
END.
DEFINE VARIABLE iStartPage AS INTEGER NO-UNDO.
IF THIS-PROCEDURE:PERSISTENT THEN DO:
    MESSAGE "A SmartDialog is not intended to be run " + CHR(10) +
            "Persistent or to be placed in another ":U + CHR(10) +
            "SmartObject at AppBuilder design time."
            VIEW-AS ALERT-BOX ERROR.
    RUN disable_UI.
    DELETE PROCEDURE THIS-PROCEDURE.
    RETURN.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME gDialog:PARENT eq ?
THEN FRAME gDialog:PARENT = ACTIVE-WINDOW.
RUN createObjects.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN initializeObject.
  WAIT-FOR GO OF FRAME gDialog .
END.
RUN destroyObject.
PROCEDURE adm-create-objects :
END PROCEDURE.
PROCEDURE attach-attr-to-schedule-line :
DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
  define buffer buf_schedule      for schedule.
  define buffer buf_schedule-attr for schedule-attr.
  define buffer lock-batchprocess for ub.batchprocess.
  run gbl/lock-prc.p
    (input 'schd':U
    ,input 'delrt-auto':U
    ,input 0
    ,input 0
    ,input '':U
    ,input ""
    ,input ""
    ,input (
    "удаление маршрутизации ВС"
    )
    ,input yes
    ,buffer lock-batchprocess
    ) no-error .
  FIND FIRST buf_schedule-attr NO-LOCK WHERE
    buf_schedule-attr.task-type   = p-task-type
    and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
    and buf_schedule-attr.attr-code = ('schd-free-id':U + chr(4) + 'delrt-auto') NO-ERROR.
  IF AVAILABLE  buf_schedule-attr
    AND buf_schedule-attr.task-num <> p-task-num
    AND buf_schedule-attr.task-num <> - 1
    and p-task-num <> - 1
    THEN
  DO:
    MESSAGE
      substitute("Уже есть расписание удаления маршрутизации ВС для БД &1&2" +
      "номер расписания &3"
      ,buf_schedule-attr.cre-db-num
      ,chr(10)
      ,buf_schedule-attr.task-num)
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  find first buf_schedule no-lock
    where buf_schedule.task-type   = p-task-type
    and buf_schedule.cre-db-num  = INTEGER(p-db-num-char)
    and buf_schedule.task-num    = p-task-num
    no-error.
  if not available buf_schedule
    and (  p-task-type   <> 'autofree':U
    or p-db-num-char <> p-db-num-char
    or p-task-num    <> -1 )
    then
  do:
    message
      vss-workfile vss-revision vss-description
      skip
      "Не найдена строка расписания."
      skip return-value
      skip trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      view-as alert-box error.
    undo, return error .
  end.
  run schedule-attr-write in this-procedure (
    input INTEGER(p-db-num-char)
    , input p-task-type
    , input p-task-num
    , input 'schedule-param-list':U
    , input p-param-list
    ).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME gDialog.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE B-mark b-delmark b-enter B-exit BROWSE-2
      WITH FRAME gDialog.
  VIEW FRAME gDialog.
  run getschedule .
  OPEN QUERY BROWSE-2 FOR EACH ext-system       WHERE ext-system.esys-type = 6  OR ext-system.esys-type = 7 NO-LOCK INDEXED-REPOSITION.
  BROWSE-2:select-focused-row () no-error.
END PROCEDURE.
PROCEDURE local-mark:
  if not available ext-system then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid4 as character no-undo .
define variable v-num-entry4 as integer   no-undo .
assign
  v-str-recid4 = trim( string( recid( ext-system ) , "->>>>>>>>>>>9":U ) )
  v-num-entry4 = lookup( v-str-recid4 , mark-list )
.
if v-num-entry4 > 0 then do:
  assign
    entry( v-num-entry4, mark-list ) = "":U
    mark-list = trim( replace( mark-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    mark-list = mark-list + ( if mark-list = "":U then "":U else chr(44) ) + v-str-recid4
  .
end.
   if lookup(string( recid(ext-system) ), mark-list ) = 0
      then display  "" @ mark with browse BROWSE-2.
      else display "*" @ mark with browse BROWSE-2.
END PROCEDURE.
procedure getschedule:
  define variable v-param-list as character no-undo.
  define variable v-param-type as character no-undo.
  run schedule-attr-value in this-procedure (
    input integer(p-db-num-char)
    , input p-task-type
    , input p-task-num
    , input 'schedule-param-list':U
    , output v-param-list
    , output v-param-type
    ) no-error.
  if v-param-list <> "" then
  do:
    assign
      mark-list = entry (1, v-param-list, "!")
      f-day-shift = integer(entry (2, v-param-list, "!"))
      f-day-shift:screen-value  in frame gDialog = entry (2, v-param-list, "!").
  end.
end.
