DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-user-id     AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-db-num      AS integer       NO-UNDO.
DEFINE TEMP-TABLE tt-work-place NO-UNDO
    FIELD wp-code AS INTEGER   column-label "Код"           FORMAT ">>>>>>>>>9"
    FIELD wp-type AS CHARACTER column-label "Тип"           FORMAT "x(3)"
    FIELD wp-host AS INTEGER   column-label "фирма"         FORMAT ">>>>>>>>>9"
    FIELD wp-name AS CHARACTER column-label "наименование"  FORMAT "x(40)"
    FIELD context AS CHARACTER column-label "привязка"
    FIELD db-num  AS INTEGER   column-label "БД"            FORMAT ">>>>>>>>>9"
    field marked  as logical
    field deleted  as logical
INDEX i-code-type IS PRIMARY UNIQUE
      wp-code
      wp-type
INDEX i-host
      wp-host
index i-context
      context
.
DEFINE TEMP-TABLE tt-user-login-action-role NO-UNDO like ub.user-login-action-role
    FIELD role-name AS CHARACTER column-label "название"  FORMAT "x(40)"
    FIELD description AS CHARACTER column-label "описание"  FORMAT "x(40)"
    field deleted  as logical
    field marked  as logical
index i-name
      role-name
.
define temp-table  tt-gds-grp no-undo
    field node-code as integer column-label "Вн.код группы" format ">>>>>>>>9"
    field full-name as character COLUMN-LABEL "Название группы" format "X(255)"
index i-code
      node-code
.
define buffer br_tt-gds-grp                  for tt-gds-grp.
define buffer br_tt-work-place               for tt-work-place.
define buffer br_tt-user-login-action-role   for tt-user-login-action-role.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование привязки группы прав к пользователю".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrnickf returns character ( input p-user-id as character):
   define variable v-nick      as character    no-undo.
   if p-user-id = ?
   OR p-user-id = "":U
   then do:
      return '':U .
   end.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrnick in g#library
  (input  p-user-id
  ,output v-nick
  ) no-error .
   if error-status :error
   then do:
      return p-user-id.
   end.
   else do:
      return v-nick.
   end.
end function.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userhsts_temp-user-host no-undo
  field host-code as integer
  index xpk is primary unique host-code
  .
procedure userhsts_clear :
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      delete buf_userhsts_temp-user-host .
    end.
  end.
end procedure.
procedure userhsts_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end procedure.
procedure userhsts_append :
  define input  parameter p-host-code as integer   no-undo .
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    find first buf_userhsts_temp-user-host
      where buf_userhsts_temp-user-host.host-code = p-host-code
      no-error .
    if not available buf_userhsts_temp-user-host
    then do:
      create buf_userhsts_temp-user-host .
      assign
        buf_userhsts_temp-user-host.host-code = p-host-code
      .
    end.
  end.
end procedure.
procedure userhsts_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    find first buf_userhsts_temp-user-host
      no-error .
    if not available buf_userhsts_temp-user-host
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end procedure.
procedure userhsts_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userhsts_transfer: Передача списка объектов".
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userhsts_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userhsts_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      run userhsts_append in p-callback-handle
        (input  buf_userhsts_temp-user-host.host-code
        ) .
    end.
  end.
end procedure.
procedure userhsts_select-one :
  define input  parameter parparentproc      as widget-handle no-undo .
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-curr-host-code   as integer   no-undo .
  define output parameter p-user-select      as logical   no-undo .
  define output parameter p-select-host-code as character no-undo .
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".
  do
  on error undo, return error return-value
  :
    run gbl/userhsts.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-curr-host-code
      ,input  "b-sel"
      ,output p-user-select
      ,output p-select-host-code
      ,OUTPUT v-List-Select-host-code
      ) .
  end.
end procedure.
procedure userhsts_select-many :
  define input  parameter parparentproc      as widget-handle no-undo .
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-curr-host-code   as integer   no-undo .
  define output parameter p-user-select      as logical   no-undo .
  define variable v-select-host-code as integer   no-undo .
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".
  do
  on error undo, return error return-value
  :
    run gbl/userhsts.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-curr-host-code
      ,input  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-host-code
      ,OUTPUT v-List-Select-host-code
      ) .
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_twowin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_twowin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-twowin7-itm-key    as integer      no-undo.
procedure twowin_clear :
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    empty temp-table buf_temp_twowin_items.
end.
end procedure.
procedure twowin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    assign
        v-twowin7-itm-key = v-twowin7-itm-key + 1
    .
    create temp_twowin_items.
    assign
        temp_twowin_items.itm-key      = v-twowin7-itm-key
        temp_twowin_items.itmExtKey    = p-ext-key
        temp_twowin_items.itmName      = p-item-name
        temp_twowin_items.itmDesc      = p-item-desc
        temp_twowin_items.itmSelected  = p-selected
        temp_twowin_items.selLeft      = no
        temp_twowin_items.selRight     = no
    .
end.
end procedure.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_onewin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_onewin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-onewin8-itm-key    as integer      no-undo.
procedure onewin_clear :
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    empty temp-table buf_temp_onewin_items.
end.
end procedure.
procedure onewin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    find last buf_temp_onewin_items no-error.
    if available buf_temp_onewin_items then do:
      v-onewin8-itm-key = buf_temp_onewin_items.itm-key.
    end.
    else do:
      v-onewin8-itm-key = 0.
    end.
    assign
        v-onewin8-itm-key = v-onewin8-itm-key + 1
    .
    create buf_temp_onewin_items.
    assign
    buf_temp_onewin_items.itm-key      = v-onewin8-itm-key
    buf_temp_onewin_items.itmExtKey    = p-ext-key
    buf_temp_onewin_items.itmName      = p-item-name
    buf_temp_onewin_items.itmDesc      = p-item-desc
    buf_temp_onewin_items.itmSelected  = p-selected
    .
end.
end procedure.
procedure onewin_create-selection :
define input parameter p-itm-key as integer no-undo .
define input parameter p-itmextkey as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected .
do
on error undo, return error
:
  find last buf_temp_onewin_itemsSelected use-index pi no-error.
  if available buf_temp_onewin_itemsSelected then do:
    v-counter = buf_temp_onewin_itemsSelected.its-key.
  end.
  find first buf_temp_onewin_itemsSelected where
       buf_temp_onewin_itemsSelected.itm-key = p-itm-key no-error.
  if not available buf_temp_onewin_itemsSelected then do:
    create buf_temp_onewin_itemsSelected.
    assign
    buf_temp_onewin_itemsSelected.its-key   = v-counter + 1
    v-counter = v-counter + 1
    buf_temp_onewin_itemsSelected.itm-key   = p-itm-key
    buf_temp_onewin_itemsSelected.itmExtKey = p-itmExtKey
    .
  end.
end.
end procedure.
procedure onewin_check-item :
define input parameter p-ext-key   as character        no-undo.
define output parameter p-exists as logical no-undo .
define buffer buf_temp_onewin_items for temp_onewin_items.
find first buf_temp_onewin_items where
buf_temp_onewin_items.itmExtKey    = p-ext-key no-error.
if available buf_temp_onewin_items then do:
  p-exists = yes.
end.
end procedure.
define variable v-context  as character no-undo format "x(8)" column-label "Привязка".
define variable v-state    as character no-undo format "x(3)" column-label "Вкл" .
DEFINE VARIABLE g#log      AS LOGICAL   NO-UNDO.
define variable v-on-grp    as logical      no-undo.
define variable v-on-gbl    as logical      no-undo.
FUNCTION get-full-name RETURNS CHARACTER
  ( INPUT p-node-code AS INTEGER )  FORWARD.
FUNCTION get-role-context RETURNS CHARACTER
  ( BUFFER buf_tt-user-login-action-role FOR tt-user-login-action-role )  FORWARD.
DEFINE BUTTON b-add
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-all
     LABEL "Все права"
     SIZE 11 BY 1 TOOLTIP "Просмотр всех прав пользователя".
DEFINE BUTTON b-del
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр прав, входящих в текущую группу".
DEFINE BUTTON b-wp
     LABEL "Изменить"
     SIZE 10 BY 1.
DEFINE VARIABLE object-EDITOR AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 50.5 BY 1.75 TOOLTIP "описание, того где выдано право" NO-UNDO.
DEFINE VARIABLE role-editor AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 47.5 BY 1.79 TOOLTIP "описание группы прав" NO-UNDO.
DEFINE VARIABLE RADIO-SET-1 AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Объекты(Фирмы)", "obj-firm",
"Группы товаров", "gds-grp"
     SIZE 36.5 BY 1 NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      br_tt-work-place SCROLLING.
DEFINE QUERY BROWSE-3 FOR
      br_tt-gds-grp SCROLLING.
DEFINE QUERY browse-br_user-login-action-role FOR
      br_tt-user-login-action-role SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 DISPLAY
      br_tt-work-place.wp-type
      br_tt-work-place.wp-code
      br_tt-work-place.wp-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.5 BY 16.75
         TITLE "Объекты(Фирмы)" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN TOOLTIP "Объекты и фирмы, где включена группа прав".
DEFINE BROWSE BROWSE-3
  QUERY BROWSE-3 DISPLAY
      br_tt-gds-grp.node-code
      br_tt-gds-grp.full-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.5 BY 16.75
         TITLE "Группы товаров" ROW-HEIGHT-CHARS .67 TOOLTIP "Группы товаров, для которых включена группа прав".
DEFINE BROWSE browse-br_user-login-action-role
  QUERY browse-br_user-login-action-role DISPLAY
      get-role-context(BUFFER br_tt-user-login-action-role) @ v-context column-label "Привязка" FORMAT "x(12)"
      br_tt-user-login-action-role.role-name                                column-label "Название группы прав"
       br_tt-user-login-action-role.db-num  column-label "БД"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 47.5 BY 16.75
         TITLE "Группы прав" ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-all AT ROW 1 COL 11 WIDGET-ID 44
     b-help AT ROW 1 COL 89.5
     b-add AT ROW 2 COL 1 WIDGET-ID 6
     b-lkp AT ROW 2 COL 11 WIDGET-ID 38
     b-del AT ROW 2 COL 21 WIDGET-ID 8
     RADIO-SET-1 AT ROW 2 COL 49.5 NO-LABEL WIDGET-ID 46
     b-wp AT ROW 2 COL 89.5 WIDGET-ID 30
     browse-br_user-login-action-role AT ROW 3.25 COL 1 WIDGET-ID 200
     BROWSE-3 AT ROW 3.25 COL 49 WIDGET-ID 500
     BROWSE-2 AT ROW 3.25 COL 49 WIDGET-ID 400
     role-editor AT ROW 20.25 COL 1 NO-LABEL WIDGET-ID 40
     object-EDITOR AT ROW 20.25 COL 49 NO-LABEL WIDGET-ID 42
     SPACE(0.00) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Права пользователя"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       object-EDITOR:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       role-editor:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
   RUN add-action-roles in this-procedure no-error.
   IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE RETURN-VALUE SKIP
               ERROR-STATUS:GET-MESSAGE(1)
      VIEW-AS ALERT-BOX.
      UNDO, RETURN NO-APPLY.
   END.
   run refresh-action-role in this-procedure .
   run post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF b-all IN FRAME Dialog-Frame
DO:
   if available br_tt-user-login-action-role then do:
      run view-all-item in this-procedure .
   end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
   IF NOT AVAILABLE br_tt-user-login-action-role then do:
      return no-apply.
   end.
      MESSAGE SUBSTITUTE( "Отключить группу прав (&1) для пользователя &2?"
                        , br_tt-user-login-action-role.role-name
                        , usrnickf( p-user-id )
                        )
   VIEW-AS ALERT-BOX
   BUTTONS YES-NO
   UPDATE v-yes AS LOGICAL
   .
   IF v-yes THEN DO:
      RUN delete-user-role.
   END.
   run refresh-action-role in this-procedure .
   run post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
   if available br_tt-user-login-action-role then do:
      run view-item in this-procedure
                     ( INPUT br_tt-user-login-action-role.action-head-code
                     , INPUT br_tt-user-login-action-role.action-role-code
                     , INPUT br_tt-user-login-action-role.role-name
                     ) .
   end.
END.
ON CHOOSE OF b-wp IN FRAME Dialog-Frame
DO:
   if available br_tt-user-login-action-role then do:
     if radio-set-1:visible =  true then do :
       case radio-set-1 :
         when "obj-firm" then do :
           RUN change-object in this-procedure .
           run mark-object in this-procedure .
           OPEN QUERY BROWSE-2 FOR EACH br_tt-work-place where br_tt-work-place.marked = true .
         end.
         when "gds-grp" then do :
           run change-gds-grp in this-procedure.
           run fill-gds-grp in this-procedure .
           OPEN QUERY BROWSE-3 FOR EACH br_tt-gds-grp .
         end.
       end case.
     end.
     else do :
       RUN change-object in this-procedure .
       run mark-object in this-procedure .
       OPEN QUERY BROWSE-2 FOR EACH br_tt-work-place where br_tt-work-place.marked = true .
     end.
   end.
END.
ON VALUE-CHANGED OF browse-br_user-login-action-role IN FRAME Dialog-Frame
DO:
  run mark-object in this-procedure .
  OPEN QUERY BROWSE-2 FOR EACH br_tt-work-place where br_tt-work-place.marked = true .
  run fill-gds-grp in this-procedure .
  OPEN QUERY BROWSE-3 FOR EACH br_tt-gds-grp .
  RUN post_enable_UI IN THIS-PROCEDURE .
  if available br_tt-user-login-action-role then do:
     assign
         role-editor = br_tt-user-login-action-role.description
     .
     display
         role-editor
     with frame Dialog-Frame.
   end.
END.
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  assign
    RADIO-SET-1
  .
  case RADIO-SET-1 :
    when "obj-firm" then do :
      browse-3:visible = false.
      browse-2:visible = true.
    end.
    when "gds-grp" then do :
      browse-2:visible = false.
      browse-3:visible = true.
    end.
  end case.
  run post_enable_UI in this-procedure.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-2 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
       ASSIGN
        FRAME Dialog-Frame:TITLE = SUBSTITUTE ( "Права пользователя &1", usrnickf( p-user-id ) )
     .
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-grp in g#library2
    ( output v-on-grp
    ) no-error .
end.
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-gbl in g#library2
    ( output v-on-gbl
    ) no-error .
end.
  RUN enable_UI.
  RUN post_enable_UI IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE add-action-roles :
  define variable v-action-role-code     as integer   no-undo .
  define variable current-role           as integer   no-undo .
  define variable v-rid-list             as character no-undo .
  define variable v-context              as character no-undo .
  define variable v-obj-code             as integer   no-undo .
  define variable v-obj-type             as character no-undo .
  define variable v-host-code            as integer   no-undo .
  define variable v-user-select          as logical   no-undo .
  define variable v-not-first-obj        as logical   no-undo .
  define variable v-not-first-firm       as logical   no-undo .
  define variable v-rec-list             as character no-undo .
  define variable ii                     as integer   no-undo .
  define variable v-gds-grp              as logical   no-undo .
  define buffer buf_clients      for ub.clients .
  define buffer buf_gds-grp      for ub.gds-grp.
  define buffer buf_action-role     for ub.action-role .
  define buffer buf_action-role-item for ub.action-role-item.
  define buffer buf_action-item for ub.action-item.
  define buffer buf_action-item-attr for ub.action-item-attr.
   do
   on error undo, return error return-value
   :
      ASSIGN
         v-context = "All"
      .
      run str/actnrole.w ( input parparentproc
                        , input  'b-sel,b-mark':U
                        , input-output v-context
                        , output v-action-role-code
                        , INPUT-OUTPUT v-rid-list
                        , input p-db-num
                        ) .
      IF v-rid-list <> "" THEN
      DO current-role = 1 TO NUM-ENTRIES(v-rid-list) :
         find first buf_action-role
              where RECID(buf_action-role) = INTEGER(ENTRY(current-role, v-rid-list))
              no-lock
              .
         v-rec-list = "" .
         v-gds-grp = false .
         if v-on-grp then for each buf_action-role-item no-lock
           where buf_action-role-item.action-head-code = buf_action-role.action-head-code
             and buf_action-role-item.action-role-code = buf_action-role.action-role-code
             :
             find first buf_action-item no-lock
                 where buf_action-item.action-item-code = buf_action-role-item.action-item-code
                   and buf_action-item.action-head-code = buf_action-role-item.action-head-code no-error.
             if available buf_action-item then do :
                 if can-find (first buf_action-item-attr no-lock
                              where buf_action-item-attr.attr-code = "Linking"
                                and buf_action-item-attr.action-item-code = buf_action-item.action-item-code)
                 then do :
                     assign
                       v-gds-grp = true
                     .
                     leave.
                 end.
             end.
         end.
         case buf_action-role.action-role-context :
            WHEN 'object':U THEN DO:
               IF v-not-first-obj = FALSE THEN DO:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  p-db-num
  ,input  p-user-id
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-not-first-obj
  ) NO-ERROR .
                  IF v-not-first-obj = FALSE THEN DO:
                     return.
                  end.
               end.
               if v-gds-grp = true then do :
                  run ref/gds-grp.w (
                      input parparentproc
                    , input "b-sel,b-mark,b-actn-mark"
                    , input 0
                    , input "":U
                    , input-output v-rec-list).
               end.
               for each  userobjs_temp-user-obj
                  :
                  FIND FIRST buf_clients
                        WHERE buf_clients.obj-code = userobjs_temp-user-obj.obj-code
                        AND buf_clients.obj-type   = userobjs_temp-user-obj.obj-type
                     NO-LOCK
                     .
                  IF  buf_clients.db-num <> p-db-num
                  and p-db-num <> 0
                  then do:
                     next.
                  end.
                  if v-rec-list <> "" then do :
                    do ii = 1 to num-entries(v-rec-list) :
                      find buf_gds-grp where recid (buf_gds-grp) = integer(entry(ii,v-rec-list)).
                      if available buf_gds-grp then do :
                        RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT userobjs_temp-user-obj.obj-code
                                                , INPUT userobjs_temp-user-obj.obj-type
                                                , INPUT 0
                                                , input ?
                                                ).
                        RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT userobjs_temp-user-obj.obj-code
                                                , INPUT userobjs_temp-user-obj.obj-type
                                                , INPUT 0
                                                , input buf_gds-grp.node-code
                                                ).
                      end.
                    end.
                  end.
                  else do :
                    RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                            , INPUT userobjs_temp-user-obj.obj-code
                                            , INPUT userobjs_temp-user-obj.obj-type
                                            , INPUT 0
                                            , input ?
                                            ).
                  end.
               end.
            END.
            WHEN 'firm':U THEN DO:
               IF v-not-first-firm = FALSE THEN DO:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userhsts_select-many in this-procedure
  (input  parparentproc
  ,input  p-db-num
  ,input  p-user-id
  ,input  v-cntxt-host-code-obj
  ,output v-not-first-firm
  ) NO-ERROR .
                  IF v-not-first-firm = FALSE THEN DO:
                     return.
                  end.
               end.
               if v-gds-grp = true then do :
                  run ref/gds-grp.w (
                      input parparentproc
                    , input "b-sel,b-mark,b-actn-mark"
                    , input 0
                    , input "":U
                    , input-output v-rec-list).
               end.
               for each userhsts_temp-user-host
                  :
                  if v-rec-list <> "" then do :
                    do ii = 1 to num-entries(v-rec-list) :
                      find buf_gds-grp where recid (buf_gds-grp) = integer(entry(ii,v-rec-list)).
                      if available buf_gds-grp then do :
                        RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT 0
                                                , INPUT '':U
                                                , INPUT userhsts_temp-user-host.host-code
                                                , input ?
                                                ).
                        RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT 0
                                                , INPUT '':U
                                                , INPUT userhsts_temp-user-host.host-code
                                                , input buf_gds-grp.node-code
                                                ).
                      end.
                    end.
                  end.
                  else do :
                    RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                            , INPUT 0
                                            , INPUT '':U
                                            , INPUT userhsts_temp-user-host.host-code
                                            , input ?
                                            ).
                  end.
               end.
            END.
            OTHERWISE DO:
               if v-gds-grp = true then do :
                 run ref/gds-grp.w (
                     input parparentproc
                   , input "b-sel,b-mark,b-actn-mark"
                   , input 0
                   , input "":U
                   , input-output v-rec-list).
              end.
              if v-rec-list <> "" then do :
                do ii = 1 to num-entries(v-rec-list) :
                  find buf_gds-grp where recid (buf_gds-grp) = integer(entry(ii,v-rec-list)).
                  if available buf_gds-grp then do :
                    RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT 0
                                                , INPUT '':U
                                                , INPUT 0
                                                , input ?
                                                ).
                    RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                            , INPUT 0
                                            , INPUT '':U
                                            , INPUT 0
                                            , input buf_gds-grp.node-code
                                            ).
                  end.
                end.
              end.
              else do :
                RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                            , INPUT 0
                                            , INPUT '':U
                                            , INPUT 0
                                            , input ?
                                            ).
              end.
            END.
         END.
      END.
   end.
END PROCEDURE.
PROCEDURE add-one-action-role :
DEFINE INPUT PARAMETER p-rid AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code      AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type      AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-host-code     AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER p-node-code     AS INTEGER   NO-UNDO.
DEFINE BUFFER buf_action-role            FOR ub.action-role.
DEFINE BUFFER buf_user-login-action-role FOR ub.user-login-action-role.
   do
   on error undo, return error return-value
   :
      FIND FIRST buf_action-role WHERE RECID(buf_action-role) = INTEGER(p-rid)
                                 NO-LOCK.
      IF NOT CAN-FIND( FIRST buf_user-login-action-role
                       WHERE buf_user-login-action-role.db-num           = p-db-num
                         AND buf_user-login-action-role.action-head-code = buf_action-role.action-head-code
                         AND buf_user-login-action-role.action-role-code = buf_action-role.action-role-code
                         AND buf_user-login-action-role.action-role-context  = buf_action-role.action-role-context
                         AND buf_user-login-action-role.user-id          = p-user-id
                         AND buf_user-login-action-role.host-code            = p-host-code
                         AND buf_user-login-action-role.obj-type             = p-obj-type
                         AND buf_user-login-action-role.obj-code             = p-obj-code
                         and buf_user-login-action-role.gds-grp-code         = p-node-code
                     )
      THEN DO:
         create buf_user-login-action-role .
         assign
           buf_user-login-action-role.db-num               = p-db-num
           buf_user-login-action-role.action-head-code     = buf_action-role.action-head-code
           buf_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
           buf_user-login-action-role.user-id              = p-user-id
           buf_user-login-action-role.action-role-code     = buf_action-role.action-role-code
           buf_user-login-action-role.action-role-context  = buf_action-role.action-role-context
           buf_user-login-action-role.host-code            = p-host-code
           buf_user-login-action-role.obj-type             = p-obj-type
           buf_user-login-action-role.obj-code             = p-obj-code
           buf_user-login-action-role.gds-grp-code         = p-node-code
           buf_user-login-action-role.gds-code             = ?
           buf_user-login-action-role.cli-grp-code         = ?
         .
      END.
    END.
END PROCEDURE.
PROCEDURE change-object :
define buffer buf_user-login-action-role     for ub.user-login-action-role .
define buffer buf_action-role     for ub.action-role .
define variable v-changed    as logical      no-undo.
define variable v-accepted    as logical      no-undo.
define variable v-space-pos    as integer      no-undo.
define variable v-code    as integer      no-undo.
define variable v-type    as character    no-undo.
do
on error undo, return error
:
   run twowin_clear in this-procedure.
   FOR EACH tt-work-place
      WHERE tt-work-place.context = br_tt-user-login-action-role.action-role-context
      :
      case tt-work-place.context :
      WHEN 'object':U THEN DO:
         IF  tt-work-place.db-num <> p-db-num
         and p-db-num <> 0
         then do:
               next.
         end.
         FIND FIRST buf_user-login-action-role
            where  buf_user-login-action-role.db-num              = br_tt-user-login-action-role.db-num
               and buf_user-login-action-role.user-id             = br_tt-user-login-action-role.user-id
               and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
               and buf_user-login-action-role.action-role-context = tt-work-place.context
               and buf_user-login-action-role.obj-type            = tt-work-place.wp-type
               and buf_user-login-action-role.obj-code            = tt-work-place.wp-code
               and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
            no-lock
            no-error
            .
      end.
      WHEN 'firm':U THEN DO:
         FIND FIRST buf_user-login-action-role
            where buf_user-login-action-role.db-num               = br_tt-user-login-action-role.db-num
               and buf_user-login-action-role.user-id             = br_tt-user-login-action-role.user-id
               and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
               and buf_user-login-action-role.action-role-context = tt-work-place.context
               and buf_user-login-action-role.host-code           = tt-work-place.wp-code
               and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
            no-lock
            no-error
            .
      end.
      OTHERWISE DO:
         RETURN.
      END.
      end case.
      run twowin_add-item in this-procedure
         ( input SUBSTITUTE ( "&1 &2"
                              , tt-work-place.wp-type
                              , tt-work-place.wp-code
                              )
         , input SUBSTITUTE ( "&1&2 &3"
                              , tt-work-place.wp-type
                              , tt-work-place.wp-code
                              , tt-work-place.wp-name
                              )
         , input ""
         , input ( available buf_user-login-action-role )
         ) .
   END.
   run gbl/twowin.w
      ( input parparentproc
      , input 1
      , input SUBSTITUTE( "Добавление права &1 на объектах", br_tt-user-login-action-role.role-name )
      , input "":U
      , input "&Тест"
      , input table temp_twowin_items
      , output table temp_twowin_itemsSelected
      , output v-changed
      , output v-accepted
      ) .
   IF NOT v-accepted
   THEN DO:
      RETURN.
   END.
   IF v-changed then do:
      find first buf_action-role
           where buf_action-role.db-num = (if v-on-gbl then 0 else br_tt-user-login-action-role.db-num)
             and buf_action-role.action-head-code = br_tt-user-login-action-role.action-head-code
             and buf_action-role.action-role-code = br_tt-user-login-action-role.action-role-code
             no-lock
             .
      for each  buf_user-login-action-role
          where buf_user-login-action-role.db-num           = br_tt-user-login-action-role.db-num
            and buf_user-login-action-role.user-id          = br_tt-user-login-action-role.user-id
            and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
            and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
         exclusive-lock
         on error undo, return error
         :
         case buf_user-login-action-role.action-role-context :
         WHEN 'object':U THEN DO:
            find first temp_twowin_itemsSelected
              where temp_twowin_itemsSelected.itmExtKey = SUBSTITUTE ( "&1 &2"
                              , buf_user-login-action-role.obj-type
                              , buf_user-login-action-role.obj-code
                              )
                     no-error.
         end.
         WHEN 'firm':U THEN DO:
            find first temp_twowin_itemsSelected
              where temp_twowin_itemsSelected.itmExtKey = SUBSTITUTE ( "&1 &2"
                              , 'орг':U
                              , buf_user-login-action-role.host-code
                              )
                     no-error.
         end.
         OTHERWISE DO:
         end.
         end case.
         if not available temp_twowin_itemsSelected
         then do:
            delete buf_user-login-action-role.
         end.
      end.
      for each temp_twowin_itemsSelected
      :
         assign
            v-space-pos = INDEX( temp_twowin_itemsSelected.itmExtKey
                               , " "
                               )
            v-code = integer( SUBSTRING( temp_twowin_itemsSelected.itmExtKey
                                       , v-space-pos
                                       ) )
            v-type =  SUBSTRING( temp_twowin_itemsSelected.itmExtKey
                               , 1
                               , v-space-pos
                               )
         no-error.
         if error-status :error
         then do:
            message
                  vss-workfile vss-revision vss-description
               skip(1)
               skip "Ошибка передачи первичного ключа из двухоконного интерфейса."
               skip return-value
               skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return error.
         end.
         case v-type:
         when 'орг':U then do:
            FIND FIRST buf_user-login-action-role
               where buf_user-login-action-role.db-num               = br_tt-user-login-action-role.db-num
                  and buf_user-login-action-role.user-id             = br_tt-user-login-action-role.user-id
                  and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.action-role-context = 'firm':U
                  and buf_user-login-action-role.host-code           = v-code
                  and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
               no-lock
               no-error
               .
            if not available buf_user-login-action-role
            then do:
               RUN add-one-action-role ( INPUT STRING(RECID(buf_action-role))
                                       , INPUT 0
                                       , INPUT '':U
                                       , INPUT v-code
                                       , INPUT ?
                                       ).
            end.
         end.
         otherwise do:
            FIND FIRST buf_user-login-action-role
               where  buf_user-login-action-role.db-num              = br_tt-user-login-action-role.db-num
                  and buf_user-login-action-role.user-id             = br_tt-user-login-action-role.user-id
                  and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.action-role-context = 'object':U
                  and buf_user-login-action-role.obj-type            = v-type
                  and buf_user-login-action-role.obj-code            = v-code
                  and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
               no-lock
               no-error
               .
            if not available buf_user-login-action-role
            then do:
               RUN add-one-action-role ( INPUT STRING(RECID(buf_action-role))
                                       , INPUT v-code
                                       , INPUT v-type
                                       , INPUT 0
                                       , INPUT ?
                                       ).
            end.
         end.
         end case.
      end.
   end.
end.
END PROCEDURE.
PROCEDURE change-gds-grp :
define buffer buf_user-login-action-role for ub.user-login-action-role .
define buffer buf2_user-login-action-role for ub.user-login-action-role .
define buffer buf_gds-grp for ub.gds-grp .
define variable old-rec-list as character no-undo .
define variable rec-list as character no-undo.
define variable ii       as integer   no-undo.
do
on error undo, return error
:
  assign
    rec-list = ""
  .
  if available br_tt-user-login-action-role then do :
    for each buf_user-login-action-role
      where buf_user-login-action-role.db-num           = p-db-num
        and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
        and buf_user-login-action-role.user-id          = p-user-id
        and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
        and buf_user-login-action-role.gds-grp-code <> 0
        and buf_user-login-action-role.gds-grp-code <> ?
        no-lock
        :
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_user-login-action-role.gds-grp-code no-error.
        if available buf_gds-grp then do :
        assign
          rec-list = rec-list + ( if rec-list = "" then "" else "," ) + string( recid( buf_gds-grp ) )
        .
        end.
    end.
    run ref/gds-grp.w (
                      input parparentproc
                    , input "b-sel,b-mark,b-actn-mark"
                    , input 0
                    , input "":U
                    , input-output rec-list).
    if ( NOT error-status:error) then do :
      case br_tt-user-login-action-role.action-role-context :
        when 'object':U then do :
          for each buf_user-login-action-role
            where buf_user-login-action-role.db-num              = p-db-num
              and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
              and buf_user-login-action-role.user-id             = p-user-id
              and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
              and buf_user-login-action-role.action-role-context = br_tt-user-login-action-role.action-role-context
              and buf_user-login-action-role.obj-code            <> 0
              and buf_user-login-action-role.obj-type            <> ""
              and buf_user-login-action-role.gds-grp-code <> 0
              and buf_user-login-action-role.gds-grp-code <> ?
              exclusive-lock
              :
              delete buf_user-login-action-role .
          end.
        end.
        when 'firm':U then do :
          for each buf_user-login-action-role
            where buf_user-login-action-role.db-num              = p-db-num
              and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
              and buf_user-login-action-role.user-id             = p-user-id
              and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
              and buf_user-login-action-role.action-role-context = br_tt-user-login-action-role.action-role-context
              and buf_user-login-action-role.host-code           <> 0
              and buf_user-login-action-role.gds-grp-code <> 0
              and buf_user-login-action-role.gds-grp-code <> ?
              exclusive-lock
              :
              delete buf_user-login-action-role .
          end.
        end.
        otherwise do :
          for each buf_user-login-action-role
            where buf_user-login-action-role.db-num              = p-db-num
              and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
              and buf_user-login-action-role.user-id             = p-user-id
              and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
              and buf_user-login-action-role.action-role-context = br_tt-user-login-action-role.action-role-context
              and buf_user-login-action-role.host-code           = 0
              and buf_user-login-action-role.obj-code            = 0
              and buf_user-login-action-role.gds-grp-code <> 0
              and buf_user-login-action-role.gds-grp-code <> ?
              exclusive-lock
              :
              delete buf_user-login-action-role .
          end.
        end.
      end case.
    end.
    if ( NOT error-status:error )
    AND ( rec-list <> "" ) then do :
      do ii = 1 to num-entries(rec-list) :
        find buf_gds-grp where recid (buf_gds-grp) = integer(entry(ii,rec-list)).
        if available buf_gds-grp then do :
          case br_tt-user-login-action-role.action-role-context :
            when 'object':U then do :
              for each buf_user-login-action-role
                where buf_user-login-action-role.db-num           = p-db-num
                  and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.user-id          = p-user-id
                  and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
                  and buf_user-login-action-role.obj-code <> 0
                  and buf_user-login-action-role.obj-type <> ""
                  no-lock
                  :
                  if not can-find
                     ( first buf2_user-login-action-role no-lock
                       where buf2_user-login-action-role.db-num           = buf_user-login-action-role.db-num
                         and buf2_user-login-action-role.action-head-code = buf_user-login-action-role.action-head-code
                         and buf2_user-login-action-role.user-id          = p-user-id
                         and buf2_user-login-action-role.action-role-code = buf_user-login-action-role.action-role-code
                         and buf2_user-login-action-role.obj-code <> 0
                         and buf2_user-login-action-role.obj-type <> ""
                         and buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code )
                  then do :
                    create buf2_user-login-action-role.
                    buffer-copy buf_user-login-action-role except buf_user-login-action-role.user-login-role-code to buf2_user-login-action-role no-error.
                    assign
                      buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code
                      buf2_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
                    .
                  end.
              end.
            end.
            when 'firm':U then do :
              for each buf_user-login-action-role
                where buf_user-login-action-role.db-num           = p-db-num
                  and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.user-id          = p-user-id
                  and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
                  and buf_user-login-action-role.host-code <> 0
                  no-lock
                  :
                  if not can-find
                     ( first buf2_user-login-action-role no-lock
                       where buf2_user-login-action-role.db-num           = buf_user-login-action-role.db-num
                         and buf2_user-login-action-role.action-head-code = buf_user-login-action-role.action-head-code
                         and buf2_user-login-action-role.user-id          = p-user-id
                         and buf2_user-login-action-role.action-role-code = buf_user-login-action-role.action-role-code
                         and buf2_user-login-action-role.host-code <> 0
                         and buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code )
                  then do :
                    create buf2_user-login-action-role.
                    buffer-copy buf_user-login-action-role except buf_user-login-action-role.user-login-role-code to buf2_user-login-action-role no-error.
                    assign
                      buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code
                      buf2_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
                    .
                  end.
              end.
            end.
            otherwise do :
              for each buf_user-login-action-role
                where buf_user-login-action-role.db-num           = p-db-num
                  and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.user-id          = p-user-id
                  and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
                  and buf_user-login-action-role.host-code        = 0
                  and buf_user-login-action-role.obj-code         = 0
                  no-lock
                  :
                  if not can-find
                     ( first buf2_user-login-action-role no-lock
                       where buf2_user-login-action-role.db-num           = buf_user-login-action-role.db-num
                         and buf2_user-login-action-role.action-head-code = buf_user-login-action-role.action-head-code
                         and buf2_user-login-action-role.user-id          = p-user-id
                         and buf2_user-login-action-role.action-role-code = buf_user-login-action-role.action-role-code
                         and buf2_user-login-action-role.host-code        = 0
                         and buf2_user-login-action-role.obj-code         = 0
                         and buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code )
                  then do :
                    create buf2_user-login-action-role.
                    buffer-copy buf_user-login-action-role except buf_user-login-action-role.user-login-role-code to buf2_user-login-action-role no-error.
                    assign
                      buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code
                      buf2_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
                    .
                  end.
              end.
            end.
          end case.
        end.
      end.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE delete-user-role :
   define buffer buf_user-login-action-role     for user-login-action-role.
   DO
   TRANSACTION
   ON ERROR UNDO, RETURN
   :
      FOR EACH buf_user-login-action-role
         where buf_user-login-action-role.db-num           = p-db-num
           AND buf_user-login-action-role.user-id          = p-user-id
           and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
           and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
         exclusive-lock
         :
         DELETE buf_user-login-action-role.
      end.
      DELETE br_tt-user-login-action-role.
   END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY  radio-set-1 role-editor object-EDITOR
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-all b-help b-add b-lkp b-del RADIO-SET-1 b-wp
         browse-br_user-login-action-role BROWSE-3 BROWSE-2 role-editor
         object-EDITOR
      WITH FRAME Dialog-Frame.
find first ub.global-state no-lock .
if can-find ( first ub.global-state-attr no-lock
     where ub.global-state-attr.gls-id = ub.global-state.gls-id
       and ub.global-state-attr.attr-code = "action-gds-groups"
       and logical(ub.global-state-attr.attr-value ) = true    )
then do :
  radio-set-1:visible = true.
  browse-3:visible = true.
end.
else do :
  radio-set-1:visible = false.
  browse-3:visible = false.
end.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH br_tt-work-place where br_tt-work-place.marked = true .    OPEN QUERY BROWSE-3 FOR EACH br_tt-gds-grp .    RUN refresh-action-role IN THIS-PROCEDURE .
END PROCEDURE.
PROCEDURE fill-action-role :
define buffer buf_action-role                for ub.action-role .
define buffer buf_user-login-action-role     for ub.user-login-action-role .
define buffer buf_tt-user-login-action-role  for tt-user-login-action-role .
define buffer buf_action-role-item           for ub.action-role-item .
define buffer buf_action-item                for ub.action-item .
do
on error undo, return error
:
   empty temp-table buf_tt-user-login-action-role.
   FOR EACH buf_user-login-action-role
      WHERE buf_user-login-action-role.db-num           = p-db-num
        AND buf_user-login-action-role.action-head-code = 0
        AND buf_user-login-action-role.user-id          = p-user-id
      no-lock
      :
      IF CAN-FIND( FIRST buf_tt-user-login-action-role
                   WHERE buf_tt-user-login-action-role.db-num = p-db-num
                     AND buf_tt-user-login-action-role.action-head-code = 0
                     AND buf_tt-user-login-action-role.user-id          = p-user-id
                     AND buf_tt-user-login-action-role.action-role-code = buf_user-login-action-role.action-role-code
                 )
      then do:
         next.
      end.
      FIND
      FIRST buf_action-role
      WHERE buf_action-role.db-num                      = (if v-on-gbl then 0 else p-db-num)
        AND buf_action-role.action-head-code            = 0
        AND buf_action-role.action-role-code            = buf_user-login-action-role.action-role-code
      NO-LOCK
      NO-ERROR
      .
      IF NOT AVAILABLE buf_action-role
      THEN DO:
         NEXT.
      END.
      create buf_tt-user-login-action-role.
      buffer-copy buf_user-login-action-role to buf_tt-user-login-action-role.
      assign
         buf_tt-user-login-action-role.role-name   = buf_action-role.action-role-name
         buf_tt-user-login-action-role.description = buf_action-role.action-role-description
         buf_tt-user-login-action-role.marked      = TRUE
      .
   end.
end.
END PROCEDURE.
PROCEDURE fill-gds-grp :
DEFINE BUFFER buf_user-login-action-role  FOR ub.user-login-action-role.
DEFINE BUFFER buf_tt-gds-grp FOR tt-gds-grp.
do
on error undo, return error
:
  for each buf_tt-gds-grp exclusive-lock :
    delete buf_tt-gds-grp .
  end.
  if available br_tt-user-login-action-role then do :
    for each buf_user-login-action-role
      where buf_user-login-action-role.db-num           = p-db-num
        and buf_user-login-action-role.action-head-code = 0
        and buf_user-login-action-role.user-id          = p-user-id
        and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
        and buf_user-login-action-role.gds-grp-code <> 0
        and buf_user-login-action-role.gds-grp-code <> ?
        no-lock
        :
        if not can-find ( first buf_tt-gds-grp no-lock
              where buf_tt-gds-grp.node-code = buf_user-login-action-role.gds-grp-code ) then do :
          create buf_tt-gds-grp .
          assign
            buf_tt-gds-grp.node-code = buf_user-login-action-role.gds-grp-code.
            buf_tt-gds-grp.full-name = get-full-name(buf_user-login-action-role.gds-grp-code)
          .
        end.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE fill-wp :
DEFINE BUFFER buf_user-obj  FOR user-obj.
DEFINE BUFFER buf_user-host FOR user-host.
DEFINE BUFFER buf_clients   FOR clients.
do
on error undo, return error
:
   empty temp-table br_tt-work-place.
   FOR EACH buf_user-obj
      WHERE buf_user-obj.db-num  = p-db-num
        AND buf_user-obj.USER-ID = p-user-id
      NO-LOCK
      :
      FIND FIRST buf_clients
           WHERE buf_clients.obj-code = buf_user-obj.obj-code
             AND buf_clients.obj-type = buf_user-obj.obj-type
           NO-LOCK
         .
      IF  buf_clients.db-num <> p-db-num
      and p-db-num <> 0
      then do:
         next.
      end.
      CREATE br_tt-work-place.
      ASSIGN
         br_tt-work-place.wp-code = buf_clients.obj-code
         br_tt-work-place.wp-type = buf_clients.obj-type
         br_tt-work-place.wp-host = buf_clients.host-code
         br_tt-work-place.db-num  = buf_clients.db-num
         br_tt-work-place.context = 'object':U
         br_tt-work-place.wp-name = buf_clients.obj-name
      .
   END.
   FOR EACH  buf_user-host
      WHERE buf_user-host.db-num  = p-db-num
         AND buf_user-host.USER-ID = p-user-id
      NO-LOCK
      :
      FIND FIRST buf_clients
            WHERE buf_clients.obj-code = buf_user-host.host-code
            AND buf_clients.obj-type = 'орг':U
            NO-LOCK
         .
      CREATE br_tt-work-place.
      ASSIGN
         br_tt-work-place.wp-code = buf_clients.obj-code
         br_tt-work-place.wp-type = buf_clients.obj-type
         br_tt-work-place.wp-host = buf_clients.obj-code
         br_tt-work-place.db-num  = buf_clients.db-num
         br_tt-work-place.context = 'firm':U
         br_tt-work-place.wp-name = buf_clients.obj-name
      .
   END.
    CREATE br_tt-work-place.
    ASSIGN
       br_tt-work-place.wp-code = 0
       br_tt-work-place.wp-type = '---':U
       br_tt-work-place.wp-name = 'По всей системе':U
       br_tt-work-place.context = 'global':U
       br_tt-work-place.db-num  = 0
    .
end.
END PROCEDURE.
PROCEDURE mark-object :
define buffer buf_tt-work-place     for tt-work-place .
define buffer buf_user-login-action-role     for user-login-action-role .
do
on error undo, return error
:
   FOR EACH buf_tt-work-place:
       assign
         buf_tt-work-place.marked = FALSE
       .
   end.
   IF available br_tt-user-login-action-role then do:
      FOR EACH buf_user-login-action-role
         WHERE buf_user-login-action-role.db-num           = p-db-num
         AND buf_user-login-action-role.action-head-code = 0
         AND buf_user-login-action-role.user-id          = p-user-id
         AND buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
         no-lock
         :
         case buf_user-login-action-role.action-role-context :
         WHEN 'object':U then do:
            find first buf_tt-work-place
               where buf_tt-work-place.wp-code = buf_user-login-action-role.obj-code
                 and buf_tt-work-place.wp-type = buf_user-login-action-role.obj-type
            .
               assign
                  buf_tt-work-place.marked = TRUE
               .
         end.
         when 'firm':U then do:
            find first buf_tt-work-place
               where buf_tt-work-place.wp-code = buf_user-login-action-role.host-code
                 and buf_tt-work-place.wp-type = 'орг':U
            .
            assign
               buf_tt-work-place.marked = TRUE
            .
         end.
         otherwise do:
            find first buf_tt-work-place
               where buf_tt-work-place.wp-code = 0
                 and buf_tt-work-place.wp-type = '---':U
            .
            assign
               buf_tt-work-place.marked = TRUE
            .
         end.
         end case.
      end.
   end.
end.
END PROCEDURE.
PROCEDURE post_enable_UI :
   define buffer buf_tt-work-place     for tt-work-place.
   define buffer buf_action-role-item  for action-role-item.
   define buffer buf_action-item       for action-item.
   define buffer buf_action-item-attr  for action-item-attr.
   define variable v-ok    as logical      no-undo.
do
on error undo, return error
:
    IF p-db-num <> v-cntxt-db-num and v-cntxt-db-num <> 0 THEN DO:
        DISABLE
              b-add
              b-del
        WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
        IF AVAILABLE br_tt-user-login-action-role THEN DO:
          if radio-set-1:visible = true and radio-set-1 = "gds-grp" then do :
            for each buf_action-role-item
              where buf_action-role-item.action-head-code = br_tt-user-login-action-role.action-head-code
                and buf_action-role-item.action-role-code = br_tt-user-login-action-role.action-role-code
                no-lock,
                each buf_action-item no-lock
                    where buf_action-item.action-item-code = buf_action-role-item.action-item-code
                      and buf_action-item.action-head-code = buf_action-role-item.action-head-code
                :
                    find first buf_action-item-attr no-lock
                                where buf_action-item-attr.attr-code = "Linking"
                                  and buf_action-item-attr.action-item-code = buf_action-item.action-item-code no-error.
                    if available buf_action-item-attr then do :
                      ENABLE
                        b-wp
                      WITH FRAME Dialog-Frame.
                      leave.
                    end.
                    else do :
                      DISABLE
                        b-wp
                      WITH FRAME Dialog-Frame.
                    end.
            end.
          end.
          else do :
            ENABLE
                  b-add
                  b-del
            WITH FRAME Dialog-Frame.
            IF br_tt-user-login-action-role.action-role-context = 'global':U THEN DO:
              DISABLE
                b-wp
              WITH FRAME Dialog-Frame.
            end.
            else do:
              ENABLE
                b-wp
              WITH FRAME Dialog-Frame.
            end.
          end.
        END.
        ELSE DO:
            ENABLE
                  b-add
            WITH FRAME Dialog-Frame.
            DISABLE
                  b-del
                  b-wp
            WITH FRAME Dialog-Frame.
        END.
    END.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_users-update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  FALSE
    ,output v-ok
    )  .
end.
    if v-ok = FALSE
    then do:
        disable
            b-add
            b-del
            b-wp
        WITH FRAME Dialog-Frame.
    end.
end.
END PROCEDURE.
PROCEDURE procedure-get-role-context :
  define input  parameter p-action-context as character no-undo .
  define output parameter p-action-name    as character no-undo .
  do
  on error undo, return error return-value
  :
    case p-action-context
    :
      when 'global':U
      then do:
        assign
          p-action-name = "Без привязки"
        .
      end.
      when 'firm':U
      then do:
        assign
          p-action-name = "Фирма"
        .
      end.
      when 'object':U
      then do:
        assign
          p-action-name = "Объект"
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Незвестное значение контекста" skip
          "p-action-context" p-action-context skip
          view-as alert-box error .
      end.
    end case .
  end.
END PROCEDURE.
PROCEDURE query-action-role :
  DO
  ON ERROR UNDO, RETURN ERROR RETURN-VALUE
  :
      run fill-action-role in this-procedure .
      OPEN QUERY browse-br_user-login-action-role
            FOR EACH br_tt-user-login-action-role
               where br_tt-user-login-action-role.deleted = FALSE
                 AND br_tt-user-login-action-role.marked  = TRUE
               NO-LOCK
               by br_tt-user-login-action-role.action-role-context
       INDEXED-REPOSITION .
        if available br_tt-user-login-action-role then do:
           assign
               role-editor = br_tt-user-login-action-role.description
           .
           display
               role-editor
           with frame Dialog-Frame.
        end.
  END.
END PROCEDURE.
PROCEDURE refresh-action-role :
  do
  on error undo, return error return-value
  :
    run query-action-role in this-procedure .
    run fill-wp in this-procedure.
    run mark-object in this-procedure .
    OPEN QUERY BROWSE-2 FOR EACH br_tt-work-place where br_tt-work-place.marked = true .
    run fill-gds-grp in this-procedure .
    OPEN QUERY BROWSE-3 FOR EACH br_tt-gds-grp .
  end.
END PROCEDURE.
PROCEDURE view-all-item :
define buffer buf_action-role-item     for action-role-item .
define buffer buf_action-item    for action-item .
define buffer buf_tt-user-login-action-role    for tt-user-login-action-role .
define buffer buf_temp_onewin_items    for temp_onewin_items .
define variable v-ok    as logical      no-undo.
define variable v-code    as character    no-undo.
do
on error undo, return error
:
   run onewin_clear in this-procedure.
   FOR EACH buf_tt-user-login-action-role
       where buf_tt-user-login-action-role.db-num  = p-db-num
         and buf_tt-user-login-action-role.user-id = p-user-id
       no-lock
       ,
       EACH buf_action-role-item
         where buf_action-role-item.db-num = (if v-on-gbl then 0 else p-db-num)
         and buf_action-role-item.action-head-code = buf_tt-user-login-action-role.action-head-code
         and buf_action-role-item.action-role-code = buf_tt-user-login-action-role.action-role-code
         no-lock
         ,
         first buf_action-item
         where buf_action-item.action-head-code = buf_action-role-item.action-head-code
           and buf_action-item.action-item-code = buf_action-role-item.action-item-code
         no-lock
         :
        IF NOT CAN-FIND( first buf_temp_onewin_items
                         where buf_temp_onewin_items.itm-key = buf_action-item.action-item-code NO-LOCK)
        THEN DO:
            run onewin_add-item in this-procedure
                  ( input buf_action-item.action-item-code
                  , input buf_action-item.action-item-name
                  , input buf_action-item.action-item-description
                  , input FALSE
                  ) .
        END.
   end.
   run gbl/onewin.w
      ( input parParentProc
      , input 0
      , input SUBSTITUTE ( "Детализация прав пользователя &1", usrnickf( p-user-id ) )
      , input "":U
      , input "":U
      , input table temp_onewin_items
      , output table temp_onewin_itemsSelected
      , output v-code
      , output v-ok
   ).
end.
END PROCEDURE.
PROCEDURE view-item :
define input parameter p-action-head-code as integer          no-undo.
define input parameter p-action-role-code as integer          no-undo.
define input parameter p-action-role-name as character        no-undo.
define buffer buf_action-role-item     for action-role-item .
define buffer buf_action-item    for action-item .
define variable v-ok    as logical      no-undo.
define variable v-code    as character    no-undo.
do
on error undo, return error
:
   run onewin_clear in this-procedure.
   FOR EACH  buf_action-role-item
         where buf_action-role-item.db-num = ( if v-on-gbl then 0 else p-db-num)
         and buf_action-role-item.action-head-code = p-action-head-code
         and buf_action-role-item.action-role-code = p-action-role-code
         no-lock,
         first buf_action-item
         where buf_action-item.action-head-code = buf_action-role-item.action-head-code
           and buf_action-item.action-item-code = buf_action-role-item.action-item-code
         no-lock
         :
        run onewin_add-item in this-procedure
            ( input buf_action-item.action-item-code
            , input buf_action-item.action-item-name
            , input buf_action-item.action-item-description
            , input FALSE
            ) .
   end.
   run gbl/onewin.w
      ( input parParentProc
      , input 0
      , input SUBSTITUTE( "Права входящие в группу &1", p-action-role-name )
      , input "":U
      , input "":U
      , input table temp_onewin_items
      , output table temp_onewin_itemsSelected
      , output v-code
      , output v-ok
   ).
end.
END PROCEDURE.
FUNCTION get-full-name RETURNS CHARACTER
  ( INPUT p-node-code AS INTEGER ) :
DEFINE VARIABLE v-full-grpname AS CHARACTER NO-UNDO.
RUN grplib-get-full-name in this-procedure( input p-node-code, output v-full-grpname ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   v-full-grpname = "!!!НЕИЗВЕСТНАЯ ГРУППА".
END.
RETURN v-full-grpname.
END FUNCTION.
FUNCTION get-role-context RETURNS CHARACTER
  ( BUFFER buf_tt-user-login-action-role FOR tt-user-login-action-role ) :
  define variable v-return-value as character no-undo .
  run procedure-get-role-context in this-procedure
    (input  buf_tt-user-login-action-role.action-role-context
    ,output v-return-value
    ) .
  return v-return-value .
END FUNCTION.
