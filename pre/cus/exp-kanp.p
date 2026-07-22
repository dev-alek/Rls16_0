block-level on error undo, throw.
   define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
   define variable vss-author      as character no-undo init "$Author: expertek $":U .
   define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
   define variable vss-workfile    as character no-undo init "$Workfile: exp-kanp.p $":U .
   define variable vss-archive     as character no-undo init "$Archive: cus/exp-kanp.p $":U .
   define variable vss-description as character no-undo init "Экспорт текущих остатков ".
   define input parameter parparentproc    as widget-handle no-undo .
   define input parameter p-parent-handle  as widget-handle no-undo .
   define input parameter p-log-handle  as handle no-undo .
   define input parameter p-cre-db-num     as integer      no-undo .
   define input parameter p-task-type      as character    no-undo.
   define input parameter p-task-num       as integer      no-undo.
   define input parameter p-db-num         as integer      no-undo .
 define variable v-counter                   as integer      no-undo.
  define variable v-param-list                as character    no-undo.
  define variable v-param-type                as character    no-undo.
  define variable v-node-code   like gds-prt.upper-code       no-undo.
  define variable v-prt-name    as character no-undo .  .
  define variable v-val-attr as char no-undo.
  define variable v-attr-type as char no-undo.
   define var v-impstr as char.
   define var v-impstr-2 as char.
   define var v-impstr-3 as char.
   define var v-impstr-4 as char.
   define var v-impstr-5 as char.
   define var v-impstr-6 as char.
   define var v-impstr-9 as char.
   define stream v-s1.
   define variable v-dnow as char no-undo.
   define variable st as char no-undo.
   define variable st2 as char no-undo.
   define variable dateb as date no-undo.
   define variable dateend as date no-undo.
   define variable kol-vo as int no-undo.
   define variable t1 as char no-undo.
   define variable v-task-num    as integer      no-undo.
   define variable v-obj-list    as character    no-undo.
   define variable v-char-status as char no-undo.
   define variable i as integer no-undo.
   define variable v-dd as date no-undo.
   define variable v-email as char no-undo.
   define variable p-subject as char no-undo.
   define variable p-text-err as char no-undo.
   define variable p-attach-files2 as char no-undo.
   define variable v-emailpath as char no-undo.
   define variable v-count as integer.
   define variable e-mail2 as char.
   define variable e-mail3 as char.
   define var art as char no-undo.
   define var v-setrun as int no-undo.
   define var v-paramdop as char no-undo.
   define var v-pref as char no-undo.
   define variable varinv-prs     as character no-undo.
   define variable varinv-prstype as character no-undo.
   define buffer buf_schedule for ub.schedule.
   define buffer buf_schedule-attr for ub.schedule-attr.
   define buffer buf_trn-doc for ub.trn-doc.
   define buffer buf_c-trn-doc for ub.c-trn-doc.
   define buffer buf_gds-dtl for gds-dtl.
   define buffer buf_gds-prt for gds-prt.
   define buffer buf_doc-line      for ub.doc-line .
   define buffer buf_clients  for ub.clients.
   define buffer buf_person   for ub.person.
   define buffer buf_staff    for ub.staff.
   define buffer buf_goods    for ub.goods.
  DEFINE TEMP-TABLE imptable
     FIELD obj-type LIKE trn-doc.obj-type
     FIELD obj-code LIKE trn-doc.obj-code
     FIELD st AS CHARACTER FORMAT "x(76)".
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
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-doctype-type-list as character extent 54 init
[
      "приход внешний"                      , 'ie':U          , "ie"
    , "расход внешний"                      , 'ee':U          , "ee"
    , "расход внешний возврат поставщику"   , 'ep':U       , "ep"
    , "расход внешний продажа через кассу"  , 'es':U     , "es"
    , "возврат внешний"                     , 're':U      , "re"
    , "возврат внешний через кассу"         , 'rs':U , "rs"
    , "списание внешнее"                    , 'we':U          , "we"
    , "инвентаризация"                      , 'vt':U                , "vt"
    , "приход перемещение"                  , 'iv':U          , "iv"
    , "расход перемещение"                  , 'ev':U          , "ev"
    , "возврат перемещение"                 , 'rv':U      , "rv"
    , "списание производство"               , 'wm':U           , "wm"
    , "приход производство"                 , 'im':U           , "im"
    , "документ переоценки"                 , 'ot':U           , "ot"
    , "коррекция учетных цен"               , 'ap':U     , "ap"
    , "корректировка отрицательных партий"  , 'mp':U   , "mp"
    , "смена типа приобретения"             , 'pc':U     , "pc"
    , "пересортица"                         , 'vp':U           , "vp"
] no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
   if p-db-num = 0 and p-task-num = 0 and p-cre-db-num = 0 and entry(1, p-task-type , ";") = "noauto" then
   do:
      dateb = date(entry ( 2, p-task-type , ";")).
      dateend = date(entry (3 , p-task-type , ";")).
      v-impstr = entry ( 4 , p-task-type , ";" ).
      v-impstr-2 = entry ( 5 ,p-task-type , ";" ).
      v-impstr-3 = entry ( 6 , p-task-type , ";" ).
      v-impstr-4 = entry ( 7 , p-task-type , ";" ).
      v-impstr-5 = entry ( 10 , p-task-type , ";" ).
      v-impstr-6 = entry ( 8 , p-task-type , ";" ).
      v-impstr-9 = entry ( 9 , p-task-type , ";" ).
      v-email    = entry ( 2 , p-task-type , "!" ) no-error.
   end.
   else
   do:
      run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-param-list':U
        , output v-param-list
        , output v-param-type
    ).
        v-impstr = entry ( 1 , v-param-list , "!" ).
        v-impstr-2 = entry ( 2 , v-param-list , "!" ).
        v-impstr-3 = entry ( 3 , v-param-list , "!" ).
        v-impstr-4 = entry ( 4 , v-param-list , "!" ).
        v-impstr-5 = entry ( 8 , v-param-list , "!" ).
        v-impstr-6 = entry ( 5 , v-param-list , "!" ).
        v-impstr-9 = entry ( 6 , v-param-list , "!" ).
        v-email    = entry ( 7 , v-param-list , "!" ) no-error.
        v-dnow = string(today - 1).
        v-dnow =  REPLACE ( v-dnow , "/"  , "." ).
          if v-impstr <> "" then
        assign v-impstr = SUBSTRING(STRING(v-impstr), 1 ,length(v-impstr) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-2 <> "" then
        assign v-impstr-2 = SUBSTRING(STRING(v-impstr-2), 1 ,length(v-impstr-2) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-3 <> "" then
        assign v-impstr-3 = SUBSTRING(STRING(v-impstr-3), 1 ,length(v-impstr-3) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-5 <> "" then
        assign v-impstr-5 = SUBSTRING(STRING(v-impstr-5), 1 ,length(v-impstr-5) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-6 <> "" then
        assign v-impstr-6 = SUBSTRING(STRING(v-impstr-6), 1 ,length(v-impstr-6) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-9 <> "" then
        assign v-impstr-9 = SUBSTRING(STRING(v-impstr-9), 1 ,length(v-impstr-9) - 4 ) + STRING(v-dnow) + ".txt".
             assign  dateb = today - 1
               dateend = today - 1.
   end.
      do:
        def var v-file-line-str as character initial "" no-undo.
        def var v-file-line-str-t   as character    initial "" no-undo.
        def var v-file-line-num as integer initial 0 no-undo.
        def var v-count-err as integer initial 0 no-undo.
        def var v-complex-err as character initial "" no-undo.
        def var v-err-msg-string as character initial "" no-undo.
        def var v-sum-parameter as integer initial 0 no-undo.
        def var v-flag-err as logical INITIAL false no-undo.
        def var v-char-space        as integer      initial 0 no-undo.
        INPUT FROM value(v-impstr-4).
            repeat:
                import  unformatted v-file-line-str.
                    v-file-line-num = v-file-line-num + 1.
                    v-file-line-str-t = trim(v-file-line-str).
                    v-sum-parameter = NUM-ENTRIES(v-file-line-str-t, ",").
                    if length(v-file-line-str) <> ? and length(v-file-line-str) >= 0 and v-sum-parameter = 0 then
                        do:
                            v-char-space = v-char-space + 1.
                        end.
                    case v-sum-parameter:
                        WHEN 0 THEN
                            do:
                                next.
                            end.
                        WHEN 1 THEN
                            do:
                                v-complex-err = v-complex-err + string(v-file-line-num)
                                + ", ".
                                v-flag-err = true.
                                v-count-err = v-count-err + 1.
                            end.
                        WHEN 2 THEN
                            do:
                                v-complex-err = v-complex-err + string(v-file-line-num)
                                + ", ".
                                v-flag-err = true.
                                v-count-err = v-count-err + 1.
                            end.
                        WHEN 3 THEN
                            do:
                                next.
                            end.
                    END CASE.
            end.
        if v-file-line-num = 0 or (v-char-space = v-file-line-num and v-flag-err = false) then
            message
                "Уведомление:" skip
                "В выбранном файле соответствий не задано ни одного параметра." skip
                "В связи с этим, вся ыгрузка будет произведена с форматом по умолчанию."
            view-as alert-box.
        v-complex-err = substring(v-complex-err, 1, (length(v-complex-err) - 2)) + ".".
        if v-flag-err = true and v-file-line-num > 0 then
                message
                    "Ошибка в заполнении файла соответствий!" skip
                    "Проверьте формат заполнения файла соответствий (обязательно для каждой строки:" skip
                    "   - количество параметров в строке;" skip
                "   - наличие разделителей-запятых;" skip
                "   - в конце файла добавьте пустую строку (без текста))." skip
                "Найдены строки с ошибками (с учёт. пуст. строк): №№ " v-complex-err skip
                    "Итого ошибок = " v-count-err "."
                view-as alert-box error.
        INPUT CLOSE.
      if v-flag-err = false then
          do:
      INPUT FROM value(v-impstr-4).
      repeat:
         create imptable.
         IMPORT DELIMITER "," imptable.obj-type imptable.obj-code imptable.st.
              END.
              INPUT CLOSE.
      END.
      else
      return.
  end.
if v-impstr <> "" then
    do:
    assign p-attach-files2 = p-attach-files2 + v-impstr.
    OUTPUT STREAM v-s1 TO value(v-impstr).
    FOR EACH buf_trn-doc
    WHERE  buf_trn-doc.ext-doc-type = 'ev':U AND  buf_trn-doc.sys-date >= dateb and buf_trn-doc.sys-date <= dateend NO-LOCK
    BY buf_trn-doc.status_ BY buf_trn-doc.doc-code :
         find first imptable no-lock where imptable.obj-type = buf_trn-doc.obj-type and imptable.obj-code = buf_trn-doc.obj-code no-error.
         IF  AVAILABLE imptable THEN
         st = imptable.st.
         else
         do:
         st = "R" + string(buf_trn-doc.obj-code).
         end.
               find first imptable no-lock where imptable.obj-type = buf_trn-doc.cli-type and imptable.obj-code = buf_trn-doc.cli-code no-error.
               IF AVAILABLE imptable then
               st2 = imptable.st.
               else
               do:
               st2 = "R" + string(buf_trn-doc.cli-code).
               end.
               if st = st2 then  next.
               if buf_trn-doc.status_ = 'факт':U and buf_trn-doc.fact-date <> buf_trn-doc.doc-date then
                do:
                 v-char-status = 'o,c'.
                 v-dd = buf_trn-doc.doc-date.
                 end.
               else
               if buf_trn-doc.status_ = 'факт':U and buf_trn-doc.fact-date = buf_trn-doc.doc-date then
                 do:
                 v-char-status = 'o,c'.
                 v-dd = buf_trn-doc.doc-date.
                 end.
               else
                   do:
               v-char-status = 'o'.
               v-dd = buf_trn-doc.doc-date.
                   end.
                 do i = 1 to num-entries(v-char-status):
                   if i = 2 then v-dd = buf_trn-doc.fact-date.
                  for each buf_doc-line no-lock where
                  buf_trn-doc.doc-code = buf_doc-line.doc-code :
                       for each gds-dtl no-lock
                       where gds-dtl.prod-type = buf_doc-line.prod-type
                         and gds-dtl.prod-code = buf_doc-line.prod-code
                         and gds-dtl.artic     = buf_doc-line.artic
                         and gds-dtl.doc-code  = buf_doc-line.doc-code
                         :
                         kol-vo = gds-dtl.fact-qnty.
                               find first gds-prt no-lock
                               where gds-prt.node-code = gds-dtl.prt-code no-error
                               .
                               art = gds-dtl.artic.
                               if available (gds-prt) then do:
                                if gds-prt.node-name = '_Пустая шкала':U then next.
                                      else
                                      v-prt-name = gds-prt.f-name.
                               t1  = "-".
                              if r-index(v-prt-name, "/") > 0 then overlay ( v-prt-name, r-index(v-prt-name, "/"), 1) = t1.
                              end.
                              else next.
                   if v-prt-name = "-" or v-prt-name = "" then next.
                  PUT STREAM v-s1 UNFORMATTED "N10;"
                 st2   ";"
                 st    ";"
                 buf_trn-doc.doc-CODE substring(string(year(v-dd)),3,2) st ";"
                 year(v-dd) "-" string(month(v-dd),'99') "-" string(day(v-dd),'99') ";"
                 buf_trn-doc.doc-CODE substring(string(year(v-dd)),3,2) st  ";"
                 art + '-' +  v-prt-name ";"
                 string(kol-vo)   ";"
                 entry(i,v-char-status)
                 SKIP.
          end.
        end.
        end.
        end.
OUTPUT STREAM v-s1 CLOSE.
end.
if v-impstr-2 <> "" then
do:
    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2  + v-impstr-2.
    else
    assign  p-attach-files2 = p-attach-files2 + "," + v-impstr-2.
OUTPUT STREAM v-s1 TO value(v-impstr-2).
     FOR EACH buf_c-trn-doc
      WHERE buf_c-trn-doc.is-del = yes  AND buf_c-trn-doc.ext-doc-type = 'ev':U
          AND  buf_c-trn-doc.sys-date >= dateb and buf_c-trn-doc.sys-date <= dateend    NO-LOCK:
              find first imptable no-lock where imptable.obj-type = buf_c-trn-doc.obj-type
                                   and imptable.obj-code = buf_c-trn-doc.obj-code no-error.
                  IF AVAILABLE imptable THEN
                          st = imptable.st.
                       else
                       do:
                          st = "R" + string(buf_c-trn-doc.obj-code).
                       end.
                   PUT STREAM v-s1 UNFORMATTED "N1E;"
                        st  ";"
                        buf_c-trn-doc.doc-CODE substring(string(year(buf_c-trn-doc.doc-date)),3,2)  st  ";"
                        year(buf_c-trn-doc.doc-date) "-" string(month(buf_c-trn-doc.doc-date),'99') "-" string(day(buf_c-trn-doc.doc-date),'99')
                        SKIP.
        end.
 OUTPUT STREAM v-s1 CLOSE.
end.
if v-impstr-3 <> "" then
do:
    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2  + v-impstr-3.
    else
    assign  p-attach-files2 = p-attach-files2 + "," + v-impstr-3.
 OUTPUT STREAM v-s1 TO value(v-impstr-3).
       FOR EACH buf_trn-doc WHERE  buf_trn-doc.ext-doc-type = 'ie':U
                                   AND  buf_trn-doc.sys-date >= dateb
                                   and buf_trn-doc.sys-date <= dateend and buf_trn-doc.status_ = 'факт':U
                                   NO-LOCK
                                    BY buf_trn-doc.status_ BY buf_trn-doc.doc-code :
            find first imptable no-lock where imptable.obj-type = buf_trn-doc.obj-type
                                and imptable.obj-code = buf_trn-doc.obj-code no-error.
                IF AVAILABLE imptable then
                    st = imptable.st.
                else
                    do:
                        st = "R00":U.
                    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'nids':U ,
                       output v-val-attr ,
                       output v-attr-type ) no-error .
                    for each buf_doc-line no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
                                for each gds-dtl no-lock
                                where gds-dtl.prod-type = buf_doc-line.prod-type
                                and gds-dtl.prod-code = buf_doc-line.prod-code
                                and gds-dtl.artic     = buf_doc-line.artic
                                and gds-dtl.doc-code  = buf_doc-line.doc-code
                                :
                                kol-vo = gds-dtl.fact-qnty.
                                      find first gds-prt no-lock
                                      where gds-prt.node-code = gds-dtl.prt-code  no-error
                                      .
                                      art = gds-dtl.artic.
                                       if available (gds-prt) then do:
                                      if gds-prt.node-name = '_Пустая шкала':U then next.
                                      else
                                      v-prt-name = gds-prt.f-name.
                                      t1  = "-".
                                      if r-index(v-prt-name, "/") > 0 then overlay ( v-prt-name, r-index(v-prt-name, "/"), 1) = t1.
                                      end.
                                      else next.
                                       if v-prt-name = "-" or v-prt-name = "" then next.
      PUT STREAM v-s1 UNFORMATTED "N30;"
                 st  ";"
                 "MD" ";"
                 v-val-attr ";"
                 year(buf_trn-doc.doc-date) "-" string(month(buf_trn-doc.doc-date),'99') "-" string(day(buf_trn-doc.doc-date),'99') ";"
                 art + '-' +  v-prt-name ";"
                 string(kol-vo)  ";"
                 buf_trn-doc.doc-CODE  "MD"  ";"
                 buf_trn-doc.ps
              SKIP.
               end.
         end.
                end.
OUTPUT STREAM v-s1 CLOSE.
end.
if v-impstr-5 <> "" then
  do:
    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2 + v-impstr-5.
    else
    assign p-attach-files2 = p-attach-files2 + "," + v-impstr-5.
    OUTPUT STREAM v-s1 TO value(v-impstr-5).
    FOR EACH buf_trn-doc
            WHERE
            buf_trn-doc.ext-doc-type = 'ee':U
            AND  buf_trn-doc.sys-date >= dateb
            AND buf_trn-doc.sys-date <= dateend
            AND buf_trn-doc.status_ = 'факт':U
            NO-LOCK
            BY buf_trn-doc.status_ BY buf_trn-doc.doc-code :
        find first imptable no-lock where imptable.obj-type = buf_trn-doc.obj-type
                            and imptable.obj-code = buf_trn-doc.obj-code no-error.
            IF AVAILABLE imptable then
                st = imptable.st.
            else
                do:
                    st = "R00":U.
                end.
       for each buf_doc-line no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
            for each gds-dtl no-lock
            where gds-dtl.prod-type = buf_doc-line.prod-type
            and gds-dtl.prod-code = buf_doc-line.prod-code
            and gds-dtl.artic     = buf_doc-line.artic
            and gds-dtl.doc-code  = buf_doc-line.doc-code
            :
            kol-vo = gds-dtl.fact-qnty.
            find first gds-prt no-lock
                where gds-prt.node-code = gds-dtl.prt-code no-error.
                art = gds-dtl.artic.
                if available (gds-prt) then do:
                    if gds-prt.node-name = '_Пустая шкала':U then next.
                    else
                        v-prt-name = gds-prt.f-name.
                        t1  = "-".
                    if r-index(v-prt-name, "/") > 0 then overlay ( v-prt-name, r-index(v-prt-name, "/"), 1) = t1.
                end.
                else next.
                if v-prt-name = "-" or v-prt-name = "" then next.
            PUT STREAM v-s1 UNFORMATTED "N20;"
                st  ";"
                buf_trn-doc.cli-code ";"
                year(buf_trn-doc.fact-date) "-" string(month(buf_trn-doc.fact-date),'99') "-" string(day(buf_trn-doc.fact-date),'99') ";"
                art + '-' + v-prt-name ";"
                string(0 - kol-vo) ";"
                buf_trn-doc.doc-CODE
                st ";"
                buf_trn-doc.ps
            SKIP.
            end.
        end.
    end.
  OUTPUT STREAM v-s1 CLOSE.
  end.
 if v-impstr-6 <> "" then
  do:
    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2  + v-impstr-6.
    else
    assign  p-attach-files2 = p-attach-files2 + "," + v-impstr-6.
    OUTPUT STREAM v-s1 TO value(v-impstr-6).
               FOR EACH buf_staff where buf_staff.date-start <= dateb and buf_staff.role = "C":U  and
                                         (buf_staff.date-end >= dateend) or (string(buf_staff.date-end) = "")  no-lock:
                  for each buf_person NO-LOCK WHERE buf_person.psn-code = buf_staff.psn-code:
                         for each buf_clients
                         WHERE buf_clients.obj-type = 'чел':U
                         AND   buf_clients.obj-code = buf_staff.psn-code no-lock:
                         if buf_clients.stts > 0 then next.
                         PUT STREAM v-s1 UNFORMATTED "N40;" ";"
                         buf_staff.staff-code ";"
                         year(today) "-" string(month(today),'99') "-" string(day(today),'99') ";"
                         buf_clients.obj-name " "  buf_person.name1 " " buf_person.name2 ";"
                         buf_person.position
                         skip.
                         end.
           end.
           end.
  OUTPUT STREAM v-s1 CLOSE.
  end.
 if v-impstr-9 <> ""  then
    do:
    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2  + v-impstr-9.
    else
    assign  p-attach-files2 = p-attach-files2 + "," + v-impstr-9.
           OUTPUT STREAM v-s1 TO value(v-impstr-9).
          FOR EACH buf_trn-doc WHERE ( buf_trn-doc.ext-doc-type = 'vp':U
                                 or  buf_trn-doc.ext-doc-type = 'vt':U )
                                 AND  buf_trn-doc.fact-date >= dateb
                                 AND  buf_trn-doc.fact-date <= dateend
                                 AND  buf_trn-doc.status_ = 'факт':U   NO-LOCK
                            :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'inv-prs':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varinv-prs
  ,output varinv-prstype
  ) no-error .
        if integer(varinv-prs) <> 0  and integer(varinv-prs) = buf_trn-doc.reason-code then do:
          if  buf_trn-doc.ext-doc-type = 'vp':U  then  v-pref = "WM-EX". else v-pref = "WM-IN".
                            find first imptable no-lock where imptable.obj-type = buf_trn-doc.obj-type and imptable.obj-code = buf_trn-doc.obj-code no-error.
                              IF AVAILABLE imptable then
                               st2 = imptable.st.
                              else
                              do:
                               st2 = "R" + string(buf_trn-doc.obj-code).
                              end.
               for each buf_doc-line no-lock where
                  buf_trn-doc.doc-code = buf_doc-line.doc-code :
                for each gds-dtl no-lock
                       where gds-dtl.prod-type = buf_doc-line.prod-type
                         and gds-dtl.prod-code = buf_doc-line.prod-code
                         and gds-dtl.artic     = buf_doc-line.artic
                         and gds-dtl.doc-code  = buf_doc-line.doc-code
                         :
                          kol-vo = gds-dtl.doc-qnty.
                               find first gds-prt no-lock
                               where gds-prt.node-code = gds-dtl.prt-code no-error
                               .
                               art = gds-dtl.artic.
                               if available (gds-prt) then do:
                                if gds-prt.node-name = '_Пустая шкала':U then next.
                                      else
                                      v-prt-name = gds-prt.f-name.
                              t1  = "-".
                              if r-index(v-prt-name, "/") > 0 then overlay ( v-prt-name, r-index(v-prt-name, "/"), 1) = t1.
                              end.
                              else next.
                              if v-prt-name = "-" or v-prt-name = "" then next.
                           PUT STREAM v-s1 UNFORMATTED "N35;"
                           st2 ";"
                           v-pref buf_trn-doc.doc-code substring(string(year(buf_trn-doc.fact-date)),3,2)  ";"
                           year(buf_trn-doc.fact-date) "-" string(month(buf_trn-doc.fact-date),'99') "-" string(day(buf_trn-doc.fact-date),'99') ";"
                           art + '-' +  v-prt-name ";"
                           kol-vo
                           skip.
                 end.
                 end.
                 end.
                 end.
            OUTPUT STREAM v-s1 CLOSE.
    end.
       assign e-mail2 = "".
       DO i = 1 TO LENGTH(v-email):
       assign  e-mail3 = entry ( i , v-email , ";" ) no-error.
       if e-mail3 = e-mail2 then next.
       else
       assign e-mail2 = e-mail3.
       if e-mail2 <> "":U then do:
       run gbl/sendmail.p
        ( input e-mail2
        , input "Reports from Trade House"
        , input "Reports from Trade House"
        , input p-attach-files2
        ) no-error .
     end.
     end.
