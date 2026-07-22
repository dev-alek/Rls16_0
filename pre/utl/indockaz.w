DEFINE INPUT PARAMETER parparentproc AS HANDLE NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Главное окно утилиты импорта документов по датам".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
DEFINE BUTTON b-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-cli"
     SIZE 3 BY .88.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-file-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-file-cli"
     SIZE 3 BY .88.
DEFINE BUTTON b-file-doc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-file-doc"
     SIZE 3 BY .88.
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE VARIABLE varstatus AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Статус накладных"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "накл-",0,
                     "накл+",1,
                     "факт",2
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE varagnt AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Исполнитель"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE varagnt-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 34 BY 1 NO-UNDO.
DEFINE VARIABLE varboss AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Менеджер"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE varboss-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 34 BY 1 NO-UNDO.
DEFINE VARIABLE varfile-cli AS CHARACTER FORMAT "X(256)":U INITIAL "id.txt"
     LABEL "Файл идентификации поставщиков"
     VIEW-AS FILL-IN
     SIZE 62 BY 1 NO-UNDO.
DEFINE VARIABLE varfile-doc AS CHARACTER FORMAT "X(256)":U INITIAL "parts.txt"
     LABEL "Файл данных для накладных"
     VIEW-AS FILL-IN
     SIZE 62 BY 1 NO-UNDO.
DEFINE VARIABLE varobj-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varobj-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varwrkr AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Кладовщик"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE varwrkr-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 34 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      ub.clients SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varobj-code AT ROW 2 COL 31 COLON-ALIGNED
     varobj-type AT ROW 2 COL 41.5 COLON-ALIGNED NO-LABEL
     b-cli AT ROW 2 COL 48.5
     varfile-cli AT ROW 4 COL 1.5
     b-file-cli AT ROW 4 COL 96
     varfile-doc AT ROW 6 COL 31 COLON-ALIGNED
     b-file-doc AT ROW 6 COL 96
     varstatus AT ROW 8 COL 31 COLON-ALIGNED
     varagnt AT ROW 10 COL 31 COLON-ALIGNED
     varagnt-name AT ROW 10 COL 37.5 COLON-ALIGNED NO-LABEL
     b-agnt AT ROW 10 COL 74
     varboss AT ROW 12 COL 31 COLON-ALIGNED
     varboss-name AT ROW 12 COL 37.5 COLON-ALIGNED NO-LABEL
     b-boss AT ROW 12 COL 74
     varwrkr AT ROW 14 COL 31 COLON-ALIGNED
     varwrkr-name AT ROW 14 COL 37.5 COLON-ALIGNED NO-LABEL
     b-wrkr AT ROW 14 COL 74
     SPACE(24.12) SKIP(1.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилита импорта внешнего прихода по датам"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-agnt IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE ref-rec  AS RECID     NO-UNDO.
  DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varrecid AS RECID NO-UNDO.
  DEFINE BUFFER bf_clients FOR ub.clients.
  run ref/cli-all.w (  input parparentproc
                ,  input "b-sel"
                ,  input 'чел':U
                ,  input ?
                ,  input ?
                ,  input ref-rec
                ,  input ?
                ,  input ?
                , output ref-list ) .
  IF NUM-ENTRIES(ref-list) > 0 THEN DO:
    ASSIGN
      varrecid = INTEGER(ENTRY(1, ref-list)).
    FIND FIRST bf_clients WHERE recid(bf_clients) = varrecid NO-LOCK.
    DISPLAY bf_clients.obj-code @ varagnt bf_clients.obj-name @ varagnt-name WITH FRAME Dialog-Frame.
  END.
END.
ON CHOOSE OF b-boss IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE ref-rec  AS RECID     NO-UNDO.
    DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
    DEFINE VARIABLE varrecid AS RECID NO-UNDO.
    DEFINE BUFFER bf_clients FOR ub.clients.
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ?
                  ,  input ?
                  , output ref-list ) .
    IF NUM-ENTRIES(ref-list) > 0 THEN DO:
      ASSIGN
        varrecid = INTEGER(ENTRY(1, ref-list)).
      FIND FIRST bf_clients WHERE recid(bf_clients) = varrecid NO-LOCK.
      DISPLAY bf_clients.obj-code @ varboss bf_clients.obj-name @ varboss-name WITH FRAME Dialog-Frame.
    END.
END.
ON CHOOSE OF b-cli IN FRAME Dialog-Frame
DO:
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
  if v-user-select <> true
  then do:
    RETURN NO-APPLY.
  end.
  DISPLAY
    v-obj-type @ varobj-type
    v-obj-code @ varobj-code
    WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER bf_clients FOR ub.clients.
  define variable varchk-prs      as logical   no-undo .
  define variable varchk-prs-type as character no-undo.
  ASSIGN FRAME Dialog-Frame
    varfile-cli
    varfile-doc
    varobj-type
    varobj-code
    varagnt
    varboss
    varwrkr
    varstatus.
  IF SEARCH(varfile-cli) = ? THEN DO:
    MESSAGE "Не найден файл идентификации поставщиков: " varfile-cli VIEW-AS ALERT-BOX ERROR.
    APPLY "entry" TO varfile-cli IN FRAME Dialog-Frame.
    RETURN NO-APPLY.
  END.
  IF SEARCH(varfile-doc) = ? THEN DO:
      MESSAGE "Не найден файл данных для накладных: " varfile-doc VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO varfile-doc IN FRAME Dialog-Frame.
      RETURN NO-APPLY.
  END.
  IF varobj-type <> 'маг':U AND varobj-type <> 'скл':U THEN DO:
    MESSAGE "Объект должен быть типа " 'маг':U " или " 'скл':U " ."  VIEW-AS ALERT-BOX ERROR.
    APPLY "ENTRY" TO varobj-type IN FRAME Dialog-Frame.
    RETURN NO-APPLY.
  END.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = varobj-type AND
                              bf_clients.obj-code = varobj-code NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_clients THEN DO:
    MESSAGE "Не найден объект " varobj-type " " varobj-code VIEW-AS ALERT-BOX ERROR.
    APPLY "ENTRY" TO varobj-code IN FRAME Dialog-Frame.
    RETURN NO-APPLY.
  END.
  if varagnt <> 0 and varagnt <> ? then do:
    FIND FIRST bf_clients WHERE bf_clients.obj-type = 'чел':U  AND
                                bf_clients.obj-code = varagnt NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bf_clients THEN DO:
      MESSAGE "Не найден исполнитель " varagnt VIEW-AS ALERT-BOX ERROR.
      APPLY "ENTRY" TO varagnt IN FRAME Dialog-Frame.
      RETURN NO-APPLY.
    END.
  END.
  if varboss <> 0 and varboss <> ? then do:
    FIND FIRST bf_clients WHERE bf_clients.obj-type = 'чел':U  AND
                                bf_clients.obj-code = varboss NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bf_clients THEN DO:
      MESSAGE "Не найден менеджер " varboss VIEW-AS ALERT-BOX ERROR.
      APPLY "ENTRY" TO varboss IN FRAME Dialog-Frame.
      RETURN NO-APPLY.
    END.
  END.
  if varwrkr <> 0 and varwrkr <> ? then do:
    FIND FIRST bf_clients WHERE bf_clients.obj-type = 'чел':U  AND
                                bf_clients.obj-code = varwrkr NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bf_clients THEN DO:
      MESSAGE "Не найден кладовщик " varwrkr VIEW-AS ALERT-BOX ERROR.
      APPLY "ENTRY" TO varwrkr IN FRAME Dialog-Frame.
      RETURN NO-APPLY.
    END.
  END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'chk-prs'   then varchk-prs     = thbjattr_thbj-attr.property-value-logical .
end.
  if varchk-prs then do:
    if varagnt = 0 or varagnt = ? then do:
      message "Не указан исполнитель " varagnt view-as alert-box error.
      apply "entry" to varagnt in frame Dialog-Frame.
      return no-apply.
    end.
    if varboss = 0 or varboss = ? then do:
      message "Не указан менеджер " varboss view-as alert-box error.
      apply "entry" to varboss in frame Dialog-Frame.
      return no-apply.
    end.
    if varwrkr = 0 or varwrkr = ? then do:
      message "Не указан кладовщик " varwrkr view-as alert-box error.
      apply "entry" to varwrkr in frame Dialog-Frame.
      return no-apply.
    end.
  end.
  run utl/indocka.p (INPUT parparentproc, INPUT varobj-type, INPUT varobj-code, INPUT varfile-cli, INPUT varfile-doc, INPUT varstatus, INPUT varagnt, INPUT varboss, INPUT varwrkr) NO-ERROR.
END.
ON CHOOSE OF b-file-cli IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE varfile-txt AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varlog      AS LOGICAL   NO-UNDO.
  system-dialog get-file varfile-txt
  title "Выберите файл идентификации поставщиков"
       filters "txt" "*.txt",
               "Все файлы" "*.*"
       update varlog.
  IF varlog THEN DO:
    DISPLAY varfile-txt @ varfile-cli WITH FRAME Dialog-Frame.
  END.
END.
ON CHOOSE OF b-file-doc IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE varfile-txt AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varlog      AS LOGICAL   NO-UNDO.
  system-dialog get-file varfile-txt
  title "Выберите файл данных для накладных"
       filters "txt" "*.txt",
               "Все файлы" "*.*"
       update varlog.
  IF varlog THEN DO:
    DISPLAY varfile-txt @ varfile-doc WITH FRAME Dialog-Frame.
  END.
END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
  MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\utl\indockaz.w" VIEW-AS ALERT-BOX INFORMATION.
END.
ON CHOOSE OF b-wrkr IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE ref-rec  AS RECID     NO-UNDO.
    DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
    DEFINE VARIABLE varrecid AS RECID NO-UNDO.
    DEFINE BUFFER bf_clients FOR ub.clients.
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ?
                  ,  input ?
                  , output ref-list ) .
    IF NUM-ENTRIES(ref-list) > 0 THEN DO:
      ASSIGN
        varrecid = INTEGER(ENTRY(1, ref-list)).
      FIND FIRST bf_clients WHERE recid(bf_clients) = varrecid NO-LOCK.
      DISPLAY bf_clients.obj-code @ varwrkr bf_clients.obj-name @ varwrkr-name WITH FRAME Dialog-Frame.
    END.
END.
ON LEAVE OF varagnt IN FRAME Dialog-Frame
DO:
    DEFINE BUFFER bf_clients FOR ub.clients.
    FIND FIRST bf_clients WHERE bf_clients.obj-type = 'чел':U AND
                                bf_clients.obj-code = INPUT FRAME Dialog-Frame varagnt NO-LOCK NO-ERROR.
    IF AVAILABLE bf_clients THEN DO:
      DISPLAY bf_clients.obj-name @ varagnt-name WITH FRAME Dialog-Frame.
    END.
END.
ON LEAVE OF varboss IN FRAME Dialog-Frame
DO:
   DEFINE BUFFER bf_clients FOR ub.clients.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = 'чел':U AND
                              bf_clients.obj-code = INPUT FRAME Dialog-Frame varboss NO-LOCK NO-ERROR.
  IF AVAILABLE bf_clients THEN DO:
    DISPLAY bf_clients.obj-name @ varboss-name WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF varwrkr IN FRAME Dialog-Frame
DO:
    DEFINE BUFFER bf_clients FOR ub.clients.
    FIND FIRST bf_clients WHERE bf_clients.obj-type = 'чел':U AND
                                bf_clients.obj-code = INPUT FRAME Dialog-Frame varwrkr NO-LOCK NO-ERROR.
    IF AVAILABLE bf_clients THEN DO:
      DISPLAY bf_clients.obj-name @ varwrkr-name WITH FRAME Dialog-Frame.
    END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  OPEN QUERY Dialog-Frame FOR EACH ub.clients SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY varobj-code varobj-type varfile-cli varfile-doc varstatus varagnt
          varagnt-name varboss varboss-name varwrkr varwrkr-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help varobj-code varobj-type b-cli varfile-cli
         b-file-cli varfile-doc b-file-doc varstatus varagnt b-agnt varboss
         b-boss varwrkr b-wrkr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
