define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DEFINE temp-table tt-obj no-undo
    field   obj-code    as integer
    field   obj-type    as character
    field   obj-name    as character
    field   host-code   as integer
    INDEX   pi          IS PRIMARY UNIQUE
            obj-type
            obj-code
  .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры автоматической выгрузки для Nielsen".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-rid-list    as character    no-undo.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
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
DEFINE BUTTON BUTTON-1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.6 BY 1 TOOLTIP "Выбор фирм".
DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Все"
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 40.6 BY 4 NO-UNDO.
DEFINE VARIABLE v-ftp-address AS CHARACTER FORMAT "X(40)":U
     LABEL "ftp"
     VIEW-AS FILL-IN
     SIZE 47 BY 1 NO-UNDO.
DEFINE VARIABLE v-Host-code-List AS CHARACTER FORMAT "X(256)":U
     LABEL "Коды Фирм"
     VIEW-AS FILL-IN
     SIZE 26.2 BY 1 TOOLTIP "Для режима все по фирме - здесь должен быть указан список кодов фирм." NO-UNDO.
DEFINE VARIABLE v-login AS CHARACTER FORMAT "X(25)":U
     LABEL "Логин"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Префикс"
     VIEW-AS FILL-IN
     SIZE 16.2 BY 1 TOOLTIP "Префикс имени выходного файла." NO-UNDO.
DEFINE VARIABLE v-password AS CHARACTER FORMAT "X(25)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Все по фирме", 3,
"Выборочно", 4
     SIZE 15 BY 3 NO-UNDO.
DEFINE VARIABLE v-place AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Локальную папку", 1,
"FTP адрес", 2
     SIZE 19.6 BY 2.24 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 60 BY 5.86.
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 60 BY 6.24.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2.6
     b-quit AT ROW 1 COL 12.6
     b-help AT ROW 1 COL 49
     EDITOR-1 AT ROW 2.52 COL 21.2 NO-LABEL
     RADIO-SET-1 AT ROW 3.1 COL 4 NO-LABEL
     BUTTON-1 AT ROW 6.71 COL 40
     v-Host-code-List AT ROW 6.76 COL 12 COLON-ALIGNED
     v-place AT ROW 8.71 COL 4.6 NO-LABEL
     v-ftp-address AT ROW 11 COL 11 COLON-ALIGNED
     v-login AT ROW 12.14 COL 11 COLON-ALIGNED
     v-password AT ROW 13.29 COL 11 COLON-ALIGNED BLANK
     v-name AT ROW 14.76 COL 11 COLON-ALIGNED
     " Выбор объектов:" VIEW-AS TEXT
          SIZE 17 BY .67 AT ROW 2.05 COL 3.4
          FGCOLOR 4
     " Выгрузка в:" VIEW-AS TEXT
          SIZE 13.6 BY .67 AT ROW 8.05 COL 5
          FGCOLOR 4
     RECT-1 AT ROW 2.29 COL 2.6
     RECT-8 AT ROW 8.29 COL 2.6
     SPACE(1.39) SKIP(1.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "параметры выгрузки для Nielsen"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE .
END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
  MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\rep\exp-sale.w" VIEW-AS ALERT-BOX INFORMATION.
END.
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  def var pHost-code-list as character no-undo.
  do with frame Dialog-Frame:
    run procedure-user-login-user-host in this-procedure (
          input v-cntxt-db-num
        , input v-cntxt-userid
        , output pHost-code-list
    ) no-error .
    if pHost-code-list > '' then do:
      v-Host-code-List = pHost-code-list.
      display v-Host-code-List.
      apply "LEAVE":U to v-Host-code-List.
    end.
  end.
END.
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  ASSIGN
      Radio-set-1
  .
  CASE RADIO-SET-1:
  WHEN 4
  THEN DO:
     hide v-Host-code-List button-1 in frame Dialog-Frame.
     run ref/cli-all.w ( parParentProc
                   , input "b-sel,b-mark"
                   , 'маг':U
                   , ?
                   , ?
                   , ?
                   , ?
                   , ?
                   , output  v-rid-list
                   ) .
     IF  v-rid-list <> "":U
     AND v-rid-list <> ?
     THEN DO:
         EDITOR-1 = "":U.
         define variable v-ii1    as integer      no-undo.
         define variable v-text    as character    no-undo.
         EMPTY TEMP-TABLE tt-obj.
         DO v-ii1 = 1 to num-entries(v-rid-list):
            FIND FIRST ub.clients
                 WHERE RECID( ub.clients ) = integer(entry(v-ii1, v-rid-list))
                 NO-LOCK
                 .
            ASSIGN
               v-text = v-text + chr(10) + ub.clients.obj-name
            .
            CREATE tt-obj.
            ASSIGN
               tt-obj.obj-code  = ub.clients.obj-code
               tt-obj.obj-type  = ub.clients.obj-type
               tt-obj.obj-name  = ub.clients.obj-name
               tt-obj.host-code = ub.clients.host-code
            .
         END.
         ASSIGN
            v-text = TRIM(v-text, chr(10))
            EDITOR-1 = v-text
         .
     END.
  END.
  WHEN 3 THEN DO:
      view v-Host-code-List button-1 in frame Dialog-Frame.
      EDITOR-1 = "":U.
      EMPTY TEMP-TABLE tt-obj.
      FOR EACH ub.clients NO-LOCK
        WHERE ub.clients.obj-type = 'маг':U
      :
        if lookup( string( ub.clients.host-code ), v-Host-code-List ) = 0 then
          next.
        CREATE tt-obj.
        ASSIGN
           tt-obj.obj-code  = ub.clients.obj-code
           tt-obj.obj-type  = ub.clients.obj-type
           tt-obj.obj-name  = ub.clients.obj-name
           tt-obj.host-code = ub.clients.host-code
        .
        ASSIGN
           v-text = v-text + chr(10) + ub.clients.obj-name
        .
      END.
      ASSIGN
         v-text = TRIM(v-text, chr(10))
         EDITOR-1 = v-text
      .
  END.
  WHEN 1 THEN DO:
      hide v-Host-code-List button-1 in frame Dialog-Frame.
      EDITOR-1 = "Все":U.
      EMPTY TEMP-TABLE tt-obj.
      FOR EACH ub.clients
            WHERE ub.clients.obj-type = 'маг':U
            NO-LOCK
            :
            CREATE tt-obj.
            ASSIGN
               tt-obj.obj-code  = ub.clients.obj-code
               tt-obj.obj-type  = ub.clients.obj-type
               tt-obj.obj-name  = ub.clients.obj-name
               tt-obj.host-code = ub.clients.host-code
            .
            ASSIGN
               v-text = v-text + chr(10) + ub.clients.obj-name
            .
      END.
  END.
  OTHERWISE DO:
  END.
  END case.
   DISPLAY
      EDITOR-1
   WITH FRAME Dialog-Frame.
END.
ON LEAVE OF v-Host-code-List IN FRAME Dialog-Frame
DO:
do with frame Dialog-Frame:
  ASSIGN
    v-Host-code-List
  .
  run check-host-list( input-output v-Host-code-List ).
  display v-Host-code-List.
  apply "VALUE-CHANGED" TO RADIO-SET-1.
end.
END.
ON LEAVE OF v-name IN FRAME Dialog-Frame
DO:
  ASSIGN
    v-name
  .
END.
ON VALUE-CHANGED OF v-place IN FRAME Dialog-Frame
DO:
  ASSIGN
   v-place
  .
  CASE v-place:
      WHEN 2
      THEN DO:
        ENABLE
            v-ftp-address
            v-login
            v-password
        WITH FRAME Dialog-Frame.
          DISPLAY
             v-ftp-address
             v-login
             v-password
          WITH FRAME Dialog-Frame.
      END.
      OTHERWISE DO:
          DISABLE
              v-ftp-address
              v-login
              v-password
          WITH FRAME Dialog-Frame.
      END.
  END CASE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   if p-mode = 'shd':U then do:
      assign
      frame Dialog-Frame :title = frame Dialog-Frame :title +
                        substitute(". &1: БД &2, Задача номер &3"
                        , p-task-type
                        , p-db-num-char
                        , p-task-num )
      .
  end.
  run init-param-values in this-procedure ( input p-task-type
                                          , input p-db-num-char
                                          , input p-task-num
                                          ) .
  RUN enable_UI.
  apply "VALUE-CHANGED" TO RADIO-SET-1.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE attach-attr-to-schedule-line :
DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
define input  parameter p-obj-list as character no-undo .
define buffer buf_schedule      for schedule.
define buffer buf_schedule-attr for schedule-attr.
define buffer lock-batchprocess for ub.batchprocess.
CASE p-mode:
  when 'shd':U then do:
      run gbl/lock-prc.p
          (input 'schd':U
          ,input 'exp-sale':U
          ,input 0
          ,input 0
          ,input '':U
          ,input ""
          ,input ""
          ,input (
                  "выгрузки для Nielsen"
                )
          ,input yes
          ,buffer lock-batchprocess
          ) no-error .
      FIND FIRST buf_schedule-attr NO-LOCK WHERE
                 buf_schedule-attr.task-type   = p-task-type
             and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
             and buf_schedule-attr.attr-code = ('schd-free-id':U + chr(4) + 'exp-sale') NO-ERROR.
      IF AVAILABLE  buf_schedule-attr
          AND buf_schedule-attr.task-num <> p-task-num
          AND buf_schedule-attr.task-num <> - 1
          and p-task-num <> - 1
          THEN DO:
        MESSAGE
        substitute("Уже есть расписание выгрузки для Nielsenпо ДК для БД &1&2" +
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
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Не найдена строка расписания."
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
    run schedule-attr-write in this-procedure (
          input INTEGER(p-db-num-char)
        , input p-task-type
        , input p-task-num
        , input 'schedule-obj-list':U
        , input p-obj-list
    ).
  end.
  when 'run':U then do:
    p-params = p-param-list.
  end.
END CASE.
END PROCEDURE.
PROCEDURE check-host-list :
define input-output parameter pHost-code-list as character no-undo.
define variable iCount as integer no-undo.
define variable cTemp as character no-undo.
define variable iTempHostCode as integer no-undo.
define variable cNewHostList as character no-undo.
define variable lOk as logical no-undo.
do iCount = 1 to num-entries( pHost-code-list ):
  cTemp = entry( iCount, pHost-code-list ).
  assign
    iTempHostCode = integer( cTemp ) no-error
  .
  run validate-host( iTempHostCode, no, no, output lOk ).
  if lOk and lookup( string( iTempHostCode ), cNewHostList ) = 0
  then do:
    assign
      cNewHostList = cNewHostList + ',' + string( iTempHostCode )
    .
  end.
end.
pHost-code-list = trim( cNewHostList, ',' ).
return.
END PROCEDURE.
PROCEDURE convert :
  define input-output parameter v-rid-list as character no-undo.
  define variable v-list as character no-undo .
  define variable v-ind  as integer   no-undo .
  define buffer buf_sysconf for ub.sysconf.
  do
  on error undo, return error return-value
  :
    do v-ind = 1 to num-entries(v-rid-list)
    :
      find first buf_sysconf no-lock
        where recid(buf_sysconf) = integer(entry(v-ind, v-rid-list))
        no-error .
      if available buf_sysconf
      then do:
        assign
          v-list = v-list
                  + (if v-list = '':U
                    then '':U
                    else chr(44)
                    )
                  + string(buf_sysconf.host-code)
        .
      end.
    end.
    assign
      v-rid-list = v-list
    .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY EDITOR-1 RADIO-SET-1 v-Host-code-List v-place v-ftp-address v-login
          v-password v-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help RECT-1 RECT-8 EDITOR-1 RADIO-SET-1 BUTTON-1
         v-Host-code-List v-place v-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-fields :
END PROCEDURE.
PROCEDURE init-param-values :
do
on error undo, return error
:
define input parameter p-task-type              as character    no-undo.
define input parameter p-db-num-char            as character    no-undo.
define input parameter p-task-num               as integer      no-undo.
define variable v-param-list    as character     no-undo.
define variable v-param-type    as character     no-undo.
define variable v-obj-list      as character no-undo .
define variable ii as integer   no-undo .
define variable v-entry  as character no-undo .
define variable v-task-num as integer   no-undo .
define variable v-ii1    as integer      no-undo.
define variable v-text    as character    no-undo.
define variable v-ii2    as integer      no-undo.
define buffer buf_tt-obj for tt-obj.
define buffer buf_schedule for ub.schedule.
define buffer buf_schedule-attr for ub.schedule-attr.
DO WITH FRAME Dialog-Frame:
  CASE p-mode:
    when 'shd':U then do:
      if p-task-num > 0
      then do:
        v-task-num = p-task-num.
      end.
      else do:
         for each buf_schedule
            where buf_schedule.task-type     = p-task-type
              AND buf_schedule.cre-db-num    = INTEGER(p-db-num-char)
            no-lock
            ,
            first buf_schedule-attr
            where buf_schedule-attr.task-type   = p-task-type
              AND buf_schedule-attr.cre-db-num  = INTEGER(p-db-num-char)
              AND buf_schedule-attr.task-num    = buf_schedule.task-num
              AND buf_schedule-attr.attr-code   = ('schd-free-id':U + chr(4) + 'exp-sale')
            no-lock
            :
            ASSIGN
               v-task-num = buf_schedule.task-num
            .
            leave .
         end.
      end.
      if v-task-num > 0
      then do:
        run schedule-attr-value in this-procedure  ( input p-db-num-char
                                                   , input p-task-type
                                                   , input v-task-num
                                                   , input 'schedule-param-list':U
                                                   , output v-param-list
                                                   , output v-param-type
                                                   ) .
        run schedule-attr-value in this-procedure  ( input p-db-num-char
                                                   , input p-task-type
                                                   , input v-task-num
                                                   , input 'schedule-obj-list':U
                                                   , output v-obj-list
                                                   , output v-param-type
                                                   ) .
      end.
      v-ii2 = num-entries( v-param-list, chr(4) ).
      if v-ii2 < 6 THEN do:
        do v-ii1 = v-ii2 to 6:
          v-param-list = v-param-list
                       + '':U
                       + chr(4).
        end.
      end.
      ASSIGN
        v-ftp-address    = ENTRY(1, v-param-list, chr(4))
        v-login          = ENTRY(2, v-param-list, chr(4))
        v-password       = ENTRY(3, v-param-list, chr(4))
        v-name           = ENTRY(4, v-param-list, chr(4))
        RADIO-SET-1      = INTEGER( ENTRY(5, v-param-list, chr(4)) )
        v-Host-code-List = ENTRY(6, v-param-list, chr(4))
      .
      DISPLAY
         v-ftp-address
         v-login
         v-password
         v-name
         RADIO-SET-1
         v-Host-code-List
      .
      EMPTY TEMP-TABLE buf_tt-obj.
      IF v-obj-list <> "":U
      and RADIO-SET-1 = 4
      THEN
      do ii = 1 to num-entries(v-obj-list, chr(4))
      on error undo, next
      :
         assign
            v-entry = entry(ii, v-obj-list, chr(4))
         .
         FIND FIRST ub.clients
              WHERE ub.clients.obj-type = ENTRY(1, v-entry, chr(44))
                AND ub.clients.obj-code = INTEGER(ENTRY(2, v-entry, chr(44)))
              NO-LOCK
              NO-ERROR
              .
         IF AVAILABLE ub.clients
         THEN DO:
            create tt-obj.
            ASSIGN
               tt-obj.obj-code  = ub.clients.obj-code
               tt-obj.obj-type  = ub.clients.obj-type
               tt-obj.obj-name  = ub.clients.obj-name
               tt-obj.host-code = ub.clients.host-code
               v-text = v-text + chr(10) + ub.clients.obj-name
            .
         END.
         ASSIGN
            v-text = TRIM(v-text, chr(10))
            EDITOR-1 = v-text
         .
      end.
      ELSE DO:
        if RADIO-SET-1 = 1 then do:
         EDITOR-1 = "Все":U.
         FOR EACH ub.clients
               WHERE ub.clients.obj-type = 'маг':U
               NO-LOCK
               :
               CREATE tt-obj.
               ASSIGN
                  tt-obj.obj-code  = ub.clients.obj-code
                  tt-obj.obj-type  = ub.clients.obj-type
                  tt-obj.obj-name  = ub.clients.obj-name
                  tt-obj.host-code = ub.clients.host-code
               .
         END.
       end.
       else do:
         apply "VALUE-CHANGED" TO RADIO-SET-1.
       end.
      END.
      DISPLAY
        EDITOR-1
        WITH FRAME Dialog-Frame.
    END.
    WHEN 'run'
    THEN DO:
      v-param-list = '':U
                   + chr(4)
                   + '':U
                   + chr(4)
                   + '':U
                   + chr(4)
                   + '':U
                   + chr(4)
                   + '':U
                   + chr(4).
    END.
  END CASE.
  IF v-ftp-address = "":U THEN v-place = 1.
  ELSE DO:
      v-place = 2.
      ENABLE
          v-ftp-address
          v-login
          v-password
      .
      DISPLAY
         v-ftp-address
         v-login
         v-password
      .
  END.
END.
END.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-param-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-file-name AS CHARACTER NO-UNDO.
define variable v-dop-file-name as character no-undo .
define variable v-obj-list as character no-undo .
define variable ii as integer   no-undo .
define variable v-exists as logical no-undo .
define buffer buf_tt-obj      for tt-obj .
   ASSIGN
   FRAME Dialog-Frame
      v-ftp-address
      v-login
      v-password
      v-place
      v-name
      RADIO-SET-1
      v-Host-code-List
   .
   case v-place:
   WHEN 2
   then do:
      IF trim(v-ftp-address) = '':U
      THEN DO:
         message
         "Не задано FTP адрес"
         view-as alert-box error .
         return error.
      END.
   end.
   OTHERWISE do:
      ASSIGN
         v-ftp-address = "":U
      .
   end.
   END CASE.
   if not can-find( first buf_tt-obj ) then do:
      message
      "Не заданы объекты для выгрузки"
      view-as alert-box error .
      return error.
   end.
   v-obj-list = ''.
   for each buf_tt-obj :
      assign
      v-obj-list = v-obj-list
                 + buf_tt-obj.obj-type + chr(44)
                 + string(buf_tt-obj.obj-code) + chr(4)
      .
   end.
   v-ftp-address = trim(trim(replace(v-ftp-address,'ftp:',""),chr(47)),chr(92)).
   ASSIGN
      v-obj-list = TRIM(v-obj-list, chr(4)).
      v-param-list = v-ftp-address + chr(4) +
                     v-login       + chr(4) +
                     v-password    + chr(4) +
                     v-name        + chr(4) +
                     STRING( RADIO-SET-1 ) + chr(4) +
                     v-Host-code-List
   .
   IF p-mode = 'shd' THEN DO:
      run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list
                                                         , INPUT v-obj-list
                                                         ) .
   END.
END PROCEDURE.
PROCEDURE procedure-user-login-user-host :
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.
define output parameter v-List-select-host-code as character        no-undo.
define variable v-current-host-code    as integer      no-undo.
do with frame Dialog-Frame:
  v-List-select-host-code = v-Host-code-List.
end.
do
on error undo, return error
:
    run adm/sconfs.w (
          input parParentProc
        , input "b-sel,b-mark,convert":U
        , input no
        , input 0
        , output v-current-host-code
        , input-output v-List-select-host-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора фирмы."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run convert( input-output v-List-select-host-code ).
end.
END PROCEDURE.
PROCEDURE userhsts_append :
  define input  parameter p-host-code as integer   no-undo .
end procedure.
PROCEDURE userhsts_clear :
end procedure.
PROCEDURE validate-host :
define input  parameter pHost-code as integer no-undo.
define input  parameter plMessageYN as logical no-undo.
define input  parameter plEmptyIsAvailYN as logical no-undo.
define output parameter plOk as logical no-undo.
if pHost-code = 0 then do:
  if plEmptyIsAvailYN then do:
    plOk = yes.
    return.
  end.
  plOk = no.
  if plMessageYN then do:
    message "Код фирмы не может быть пустым." view-as alert-box.
  end.
end.
else do:
  find first ub.clients no-lock
    where ub.clients.obj-code = pHost-code
      and ub.clients.obj-type = 'орг':U
    no-error.
  if not avail ub.clients then do:
    plOk = no.
    if plMessageYN then do:
      message substitute( "Не верный код фирмы &1.", pHost-code ) view-as alert-box.
    end.
  end.
  else do:
    plOk = yes.
  end.
end.
return.
END PROCEDURE.
