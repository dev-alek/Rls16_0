define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита пересчёта финансовых архивов".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "X(65)" no-undo
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
define variable v-twowin2-itm-key    as integer      no-undo.
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
        v-twowin2-itm-key = v-twowin2-itm-key + 1
    .
    create temp_twowin_items.
    assign
        temp_twowin_items.itm-key      = v-twowin2-itm-key
        temp_twowin_items.itmExtKey    = p-ext-key
        temp_twowin_items.itmName      = p-item-name
        temp_twowin_items.itmDesc      = p-item-desc
        temp_twowin_items.itmSelected  = p-selected
        temp_twowin_items.selLeft      = no
        temp_twowin_items.selRight     = no
    .
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define input parameter parParentProc  as widget-handle no-undo.
define variable v-user-select      as logical   no-undo .
define variable v-select-host-code as integer   no-undo .
define variable v-obj-count        as integer   no-undo .
define variable v-sel-type         as logical   no-undo .
define variable v-list             as character no-undo .
define buffer buf_clients for ub.clients.
define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.
DEFINE BUTTON b-doc-type
     LABEL "Изменить"
     SIZE 20 BY .96.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE x-doc-type AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "< ВСЕ > "," ''"
     SIZE 43 BY 6 NO-UNDO.
DEFINE VARIABLE x-fin-ob AS LOGICAL INITIAL no
     LABEL "Учитывать архивы по фин. обязательствам"
     VIEW-AS TOGGLE-BOX
     SIZE 43 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-doc-type AT ROW 1.5 COL 26 WIDGET-ID 16
     x-doc-type AT ROW 2.54 COL 3 NO-LABEL WIDGET-ID 12
     x-fin-ob AT ROW 8.92 COL 3.13 WIDGET-ID 18
     Btn_OK AT ROW 10.63 COL 5
     Btn_Cancel AT ROW 10.63 COL 28
     "Типы архивов:" VIEW-AS TEXT
          SIZE 16 BY .63 AT ROW 1.58 COL 3 WIDGET-ID 14
          FGCOLOR 4
     SPACE(32.24) SKIP(10.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилита пересчета фин. архивов"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-doc-type IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run select-doc-type in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  v-sel-type = true.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
  define variable glog as logical no-undo .
  assign x-fin-ob.
    run utl/rclcfarh.p(
      input v-cntxt-host-code-obj,
      input x-fin-ob,
      input v-list)
    .
  message "Готово!" view-as alert-box.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY x-doc-type x-fin-ob
      WITH FRAME Dialog-Frame.
  ENABLE b-doc-type x-doc-type x-fin-ob Btn_OK Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-sel-host :
  do
  on error undo, return error return-value
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userhsts_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,output v-user-select
  ,output v-select-host-code
  )  .
  end.
END PROCEDURE.
PROCEDURE select-doc-type :
    define variable v-counter       as integer      no-undo.
    define variable v-label         as character    no-undo.
    define variable v-value         as character    no-undo.
    define variable v-changed       as logical    no-undo.
    define variable v-accepted      as logical    no-undo.
    define variable v-list-edt      as character    no-undo.
    define variable v-list-edt-full as character    no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
      assign
          v-list-edt  = 'arh-fin-doc-an':U
              + ",":U + 'arh-fin-doc-an-nal':U
              + ",":U + 'arh-fin-doc-an-nal-obj':U
              + ",":U + 'arh-fin-doc-an-obj':U
              + ",":U + 'arh-fin-doc-c-s-tax-nal-obj':U
              + ",":U + 'arh-fin-doc-c-schet-tax-nal':U
              + ",":U + 'arh-fin-doc-contr-s-nal-obj':U
              + ",":U + 'arh-fin-doc-contr-s-tax-obj':U
              + ",":U + 'arh-fin-doc-contr-schet':U
              + ",":U + 'arh-fin-doc-contr-schet-nal':U
              + ",":U + 'arh-fin-doc-contr-schet-obj':U
              + ",":U + 'arh-fin-doc-contr-schet-tax':U
              + ",":U + 'arh-fin-doc-s-tax-nal-obj':U
              + ",":U + 'arh-fin-doc-schet':U
              + ",":U + 'arh-fin-doc-schet-nal':U
              + ",":U + 'arh-fin-doc-schet-nal-obj':U
              + ",":U + 'arh-fin-doc-schet-obj':U
              + ",":U + 'arh-fin-doc-schet-tax':U
              + ",":U + 'arh-fin-doc-schet-tax-nal':U
              + ",":U + 'arh-fin-doc-schet-tax-obj':U
      .
      assign
          v-list-edt-full   = 'Архив по счету по кодам':U
                    + ",":U + 'Архив по налсчету по кодам':U
                    + ",":U + 'Архив по налсчету по кодам по объектам':U
                    + ",":U + 'Архив по счету по кодам по объекту':U
                    + ",":U + 'Архив по нал.плат.догов.налоги по объектам':U
                    + ",":U + 'Архив по нал.плат.догов.налоги':U
                    + ",":U + 'Архивы по плат. налсч. по дог.':U
                    + ",":U + 'Архив по платеж. догов.налоги':U
                    + ",":U + 'Архивы по плат. счета по дог.':U
                    + ",":U + 'Архивы по плат. налсч. по дог.':U
                    + ",":U + 'Архивы по плат. счета по дог. по объекту':U
                    + ",":U + 'Архив по платеж. догов.налоги':U
                    + ",":U + 'Архив по платеж. налсчета нало':U
                    + ",":U + 'Архив по платежам по счету':U
                    + ",":U + 'Архив по платежам по налсчету':U
                    + ",":U + 'Архив по платежам по налсчету':U
                    + ",":U + 'Архив по платежам по счету по объекту':U
                    + ",":U + 'Архив по платеж. счета налоги':U
                    + ",":U + 'Архив по платеж. налсчета нало':U
                    + ",":U + 'Архив по платеж. счета налоги по объектам':U
      .
    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( v-list-edt-full )
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, v-list-edt-full )
            v-value = entry( v-counter, v-list-edt )
        .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Код вида документа: &1", v-value )
            , input ( x-doc-type :lookup( v-value ) <> 0 or x-doc-type :list-item-pairs = "< Все >,''":U  )
        ).
    end.
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор типов финансовых архивов":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected
        , output v-changed
        , output v-accepted
    ).
    do:
        assign
            x-doc-type :list-item-pairs    = "< ВСЕ >,''":U
            v-list                          = "":U
            v-counter = 0
        .
        for each temp_twowin_itemsSelected
        by temp_twowin_itemsSelected.itm-key
        :
            assign
                v-counter = v-counter + 1
                v-list = substitute( "&1&2&3"
                                , v-list
                                , ( if v-list = "":U then "":U else ",":U )
                                , temp_twowin_itemsSelected.itmExtKey
                                )
            .
            if v-counter = 1
            then do:
                assign
                    x-doc-type :list-item-pairs    = substitute( "&1,&2"
                                        , entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full )
                                        , temp_twowin_itemsSelected.itmExtKey
                                             )
                .
            end.
            else do:
                x-doc-type :add-last (
                    entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full )
                    , temp_twowin_itemsSelected.itmExtKey
                ).
            end.
        end.
        if v-list = v-list-edt
        then do:
            assign
                x-doc-type :list-item-pairs = "< ВСЕ >,''":U
            .
        end.
    end.
end.
END PROCEDURE.
