define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Инициализация поля СПОСОБ РАСЧЕТА в gds-grp".
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
define variable v-RID-LIST as character no-undo .
define variable v-curr-db-num like ub.db.db-num no-undo .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-groups
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-groups-tree
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE F-base AS DECIMAL FORMAT "->>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE Fi-cli-code AS INTEGER FORMAT ">>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.38 BY .96 NO-UNDO.
DEFINE VARIABLE Fi-cli-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 3.75 BY .96 NO-UNDO.
DEFINE VARIABLE Fimax AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.38 BY .96 NO-UNDO.
DEFINE VARIABLE Fimin AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.75 BY .96 NO-UNDO.
DEFINE VARIABLE Fincrease-pc AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.88 BY .96 NO-UNDO.
DEFINE VARIABLE label-calc-method-2 AS CHARACTER FORMAT "X(256)":U INITIAL "СПОСОБ РАСЧЕТА"
      VIEW-AS TEXT
     SIZE 20.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE label-diap AS CHARACTER FORMAT "X(256)":U INITIAL "min/max НАЦЕНКИ"
      VIEW-AS TEXT
     SIZE 16.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE label-diap-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Вн.ПОСТАВЩИК"
      VIEW-AS TEXT
     SIZE 12.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE label-fill-method AS CHARACTER FORMAT "X(256)":U INITIAL "Как заполнять"
      VIEW-AS TEXT
     SIZE 26.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE label-fill-subject AS CHARACTER FORMAT "X(256)":U INITIAL "Какие группы заполнять"
      VIEW-AS TEXT
     SIZE 26.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE label-fill-tree AS CHARACTER FORMAT "X(256)":U INITIAL "Область действия"
      VIEW-AS TEXT
     SIZE 26.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE label-fill-values AS CHARACTER FORMAT "X(256)":U INITIAL "Чем заполнять"
      VIEW-AS TEXT
     SIZE 26.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE label-increase-pc AS CHARACTER FORMAT "X(256)":U INITIAL "НАЦЕНКА"
      VIEW-AS TEXT
     SIZE 11.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE label-round-method-2 AS CHARACTER FORMAT "X(256)":U INITIAL "МЕТОД ОКРУГЛЕНИЯ"
      VIEW-AS TEXT
     SIZE 21 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE IMAGE l-calc-method
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.
DEFINE IMAGE l-income-cli
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.
DEFINE IMAGE l-increase-pc
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.
DEFINE IMAGE l-minmax
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.
DEFINE IMAGE l-round-method
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.
DEFINE VARIABLE RS-groups AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все группы", "all",
"Выборочно", "select",
"Выборочно с нижележащими группами", "select-tree"
     SIZE 38.75 BY 2.58 NO-UNDO.
DEFINE VARIABLE RS-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Незаполненные и неправильно заполненные поля", "error-or-space",
"Неправильно заполненные поля", "error",
"Незаполненные поля", "space",
"Все поля", "all"
     SIZE 48.13 BY 3.67 NO-UNDO.
DEFINE VARIABLE RS-values AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Выбранные значения", "default",
"Из группы верх. ур-ня(группа ур. 1 не мен.)", "group"
     SIZE 47.75 BY 2.5 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.5 BY 7.21.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40.5 BY 7.29.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.38 BY 1.17.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40.5 BY 1.17.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 27.88 BY 1.17.
DEFINE VARIABLE S-round-method AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 20.75 BY 5.83 NO-UNDO.
DEFINE VARIABLE Scalc-method AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 20.75 BY 5.71 NO-UNDO.
DEFINE VARIABLE T-calc-method AS LOGICAL INITIAL no
     LABEL "Способ расчета"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE T-firm AS LOGICAL INITIAL no
     LABEL "Фирма"
     VIEW-AS TOGGLE-BOX
     SIZE 23.25 BY 1 NO-UNDO.
DEFINE VARIABLE T-global AS LOGICAL INITIAL no
     LABEL "Глобально"
     VIEW-AS TOGGLE-BOX
     SIZE 23.25 BY 1 NO-UNDO.
DEFINE VARIABLE T-income-cli AS LOGICAL INITIAL no
     LABEL "Внутр.поставщик"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE T-increase-pc AS LOGICAL INITIAL no
     LABEL "Наценка"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE T-minmax AS LOGICAL INITIAL no
     LABEL "Диапазоны наценки"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE T-object AS LOGICAL INITIAL no
     LABEL "Объекты"
     VIEW-AS TOGGLE-BOX
     SIZE 23.25 BY 1 NO-UNDO.
DEFINE VARIABLE T-round-method AS LOGICAL INITIAL no
     LABEL "Метод округления"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 89.13
     F-base AT ROW 3 COL 48.88 COLON-ALIGNED NO-LABEL
     S-round-method AT ROW 3.13 COL 28.88 NO-LABEL
     Scalc-method AT ROW 3.29 COL 1.63 NO-LABEL
     T-calc-method AT ROW 3.54 COL 73.13
     T-increase-pc AT ROW 4.54 COL 73.13
     T-minmax AT ROW 5.54 COL 73.13
     T-round-method AT ROW 6.54 COL 73.13
     T-income-cli AT ROW 7.54 COL 73.13
     Fi-cli-type AT ROW 9.5 COL 81.63 COLON-ALIGNED NO-LABEL
     Fi-cli-code AT ROW 9.5 COL 85.38 COLON-ALIGNED NO-LABEL
     Fincrease-pc AT ROW 9.54 COL 12 COLON-ALIGNED NO-LABEL
     Fimin AT ROW 9.54 COL 43 COLON-ALIGNED NO-LABEL
     Fimax AT ROW 9.54 COL 53 COLON-ALIGNED NO-LABEL
     RS-method AT ROW 11.54 COL 2.5 NO-LABEL
     RS-values AT ROW 11.58 COL 51.25 NO-LABEL
     RS-groups AT ROW 15.96 COL 2.5 NO-LABEL
     T-global AT ROW 16.13 COL 55.13
     B-groups AT ROW 16.92 COL 41.5
     T-firm AT ROW 17.13 COL 55.13
     B-groups-tree AT ROW 17.79 COL 41.5
     T-object AT ROW 18.13 COL 55.13
     label-calc-method-2 AT ROW 2.25 COL 1.75 NO-LABEL
     label-round-method-2 AT ROW 2.25 COL 27 COLON-ALIGNED NO-LABEL
     label-increase-pc AT ROW 9.67 COL 2.13 NO-LABEL
     label-diap AT ROW 9.67 COL 28 NO-LABEL
     label-diap-2 AT ROW 9.67 COL 70.38 NO-LABEL
     label-fill-method AT ROW 10.71 COL 2.25 NO-LABEL
     label-fill-values AT ROW 10.83 COL 51 NO-LABEL
     label-fill-subject AT ROW 15.21 COL 2.38 NO-LABEL
     label-fill-tree AT ROW 15.25 COL 54.75 NO-LABEL
     l-round-method AT ROW 4.38 COL 51.38
     l-increase-pc AT ROW 9.58 COL 24
     l-minmax AT ROW 9.58 COL 63.88
     RECT-2 AT ROW 2 COL 27.5
     RECT-1 AT ROW 2.08 COL 1.38
     "Заполнять поля" VIEW-AS TEXT
          SIZE 20 BY 1 AT ROW 2.54 COL 73.13
          FGCOLOR 4
     RECT-5 AT ROW 9.42 COL 68.38
     RECT-3 AT ROW 9.42 COL 1.63
     l-income-cli AT ROW 9.54 COL 96.25
     RECT-4 AT ROW 9.42 COL 27.5
     l-calc-method AT ROW 3.29 COL 23.25
     SPACE(73.00) SKIP(15.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заполнение полей ПАРАМЕТРЫ НА ОБЪЕКТАХ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable v-field as integer no-undo .
define variable v-region as integer no-undo .
define variable glog as logical no-undo .
  assign
  Scalc-method
  S-round-method
  f-base
  fimin
  fimax
  fi-cli-type
  fi-cli-code
  RS-method
  RS-groups
  RS-values T-firm T-global T-object
  fincrease-pc
  T-calc-method  = if scalc-method:sensitive then yes else no
  T-increase-pc  = if fincrease-pc:sensitive then yes else no
  T-round-method = if s-round-method:sensitive then yes else no
  T-minmax       = if fimin:sensitive then yes else no
  T-income-cli   = if fi-cli-type:sensitive then yes else no
  .
  if RS-values = "default":U AND
    (Scalc-method = ? or
    Scalc-method = "":U or
    lookup(Scalc-method, 'Учетная,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U) = 0) AND
    t-calc-method then do:
      message
      "Выберите значение для заполнения поля СПОСОБ РАСЧЕТА"
      view-as alert-box .
      return no-apply .
  end.
  if RS-values = "default":U AND
    (S-round-method = ? or
    S-round-method = "":U or
    lookup(S-round-method, '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U) = 0) AND
    t-round-method then do:
      message
      "Выберите значение для заполнения поля МЕТОД ОКРУГЛЕНИЯ"
      view-as alert-box .
      return no-apply .
  end.
  if RS-values = "default":U AND
    t-minmax = yes AND
    (fimax = ? or fimin = ? ) then do:
      message
      "Выберите значения для заполнения полей min и max НАЦЕНКИ"
      view-as alert-box .
      return no-apply .
  end.
  if t-minmax then do:
    if fimin > fimax then do:
        message
        "Значение минимальной наценки не должно быть больше значения максимальной наценки"
        view-as alert-box error.
        return no-apply.
    end.
  end.
  if T-round-method then do:
    CASE S-round-method:
      when 'Произвольно,Вверх,Коэффициент,9-99окончание':U then do:
        if f-base = 0 then do:
          message
          "Введите ненулевое значение коэффициента"
          view-as alert-box error .
          return no-apply.
        end.
      end.
    END CASE.
 end.
  assign
  v-field = v-field + (if T-calc-method then 1 else 0)
  v-field = v-field + (if T-increase-pc then 2 else 0)
  v-field = v-field + (if T-round-method then 4 else 0)
  v-field = v-field + (if T-minmax then 8 else 0)
  v-field = v-field + (if T-income-cli then 16 else 0)
  .
 assign
  v-region = v-region + (if T-global then 1 else 0)
  v-region = v-region + (if T-firm then 2 else 0)
  v-region = v-region + (if T-object then 4 else 0)
.
  if v-field = 0 then do:
    message
    "Вы не выбрали для заполнения ни одного поля"
    view-as alert-box Error.
    return no-apply.
  end.
  if v-region = 0 and v-field <> 1 then do:
    message
    "Вы не выбрали область действия"
    view-as alert-box Error.
    return no-apply.
  end.
  if rs-groups <> "ALL" and v-rid-list = "":U then do:
    message
    "В списке групп нет ни одной группы"
    VIEW-AS ALERT-BOX ERROR.
    return no-apply .
  end.
  message
  "Вы уверены, что хотите провести изменения согласно выбранным Вами параметрам?"
  view-as alert-box QUestion buttons yes-no update glog.
  if not glog then return no-apply.
  run utl/ini-grpc.p (
                  Scalc-method
                , fincrease-pc
                , fimin
                , fimax
                , s-round-method
                , f-base
                , fi-cli-type
                , fi-cli-code
                , RS-method
                , RS-groups
                , RS-values
                , v-field
                , v-region
                , V-RID-LIST
              ).
END.
ON CHOOSE OF B-groups IN FRAME Dialog-Frame
DO:
  run ref/gds-grp.w (
                input parparentproc
              , input "b-sel,b-mark"
              , input v-cntxt-obj-type
              , input v-cntxt-obj-code
              , input-output v-rid-list ).
END.
ON CHOOSE OF B-groups-tree IN FRAME Dialog-Frame
DO:
  run ref/gds-grp.w (
                input parparentproc
              , input "b-sel,b-mark"
              , input v-cntxt-obj-type
              , input v-cntxt-obj-code
              , input-output v-rid-list ).
END.
ON RIGHT-MOUSE-CLICK OF Fi-cli-code IN FRAME Dialog-Frame
DO:
    assign
    label-diap-2:fgcolor = 15
    l-income-cli:visible = true
    t-income-cli = no
    .
    hide
    FI-cli-type
    FI-cli-code
    in frame Dialog-Frame.
    ENABLE l-income-cli
    with frame Dialog-Frame.
    display t-income-cli
    with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF Fi-cli-type IN FRAME Dialog-Frame
DO:
    assign
    label-diap-2:fgcolor = 15
    l-income-cli:visible = true
    t-income-cli = no
    .
    hide
    FI-cli-type
    FI-cli-code
    in frame Dialog-Frame.
    ENABLE l-income-cli
    with frame Dialog-Frame.
    display
    t-income-cli
    with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF Fimax IN FRAME Dialog-Frame
DO:
    assign
    label-diap:fgcolor = 15
    l-minmax:visible = true
    t-minmax = no
    .
    hide
    FIMIN
    FIMAX
    in frame Dialog-Frame.
    ENABLE l-minmax
    with frame Dialog-Frame.
    display t-minmax
    with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF Fimin IN FRAME Dialog-Frame
DO:
    assign
    label-diap:fgcolor = 15
    l-minmax:visible = true
    t-minmax = no
    .
    hide
    FIMIN
    FIMAX
    in frame Dialog-Frame.
    ENABLE l-minmax
    with frame Dialog-Frame.
    display
    t-minmax
    with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF Fincrease-pc IN FRAME Dialog-Frame
DO:
    assign
    label-increase-pc:fgcolor = 15
    l-increase-pc:visible = true
    t-increase-pc = no
    .
    hide Fincrease-pc in frame Dialog-Frame.
    disable Fincrease-pc with frame Dialog-Frame.
    display
    t-increase-pc
    with frame Dialog-Frame .
END.
ON MOUSE-SELECT-CLICK OF l-calc-method IN FRAME Dialog-Frame
DO:
   IF l-calc-method:visible then do:
    assign
    label-calc-method-2:fgcolor = ?
    l-calc-method:visible = false
    t-calc-method = yes
    .
    enable Scalc-method with frame Dialog-Frame.
    display t-calc-method with frame Dialog-Frame .
    APPLY "ENTRY" TO Scalc-method.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-income-cli IN FRAME Dialog-Frame
DO:
   IF l-income-cli:visible then do:
    assign
    label-diap-2:fgcolor = ?
    l-income-cli:visible = false
    t-income-cli = yes
    .
    enable
     Fi-cli-type
     Fi-cli-code
     with frame Dialog-Frame.
    display t-income-cli with frame Dialog-Frame .
    APPLY "ENTRY" TO Fi-cli-type.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-increase-pc IN FRAME Dialog-Frame
DO:
   IF l-increase-pc:visible then do:
    assign
    label-increase-pc:fgcolor = ?
    l-increase-pc:visible = false
    t-increase-pc = yes
    .
    enable Fincrease-pc with frame Dialog-Frame.
    display t-increase-pc with frame Dialog-Frame .
    APPLY "ENTRY" TO Fincrease-pc.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-minmax IN FRAME Dialog-Frame
DO:
   IF l-minmax:visible then do:
    assign
    label-diap:fgcolor = ?
    l-minmax:visible = false
    t-minmax = yes
    .
    enable Fimax Fimin with frame Dialog-Frame.
    display t-minmax with frame Dialog-Frame .
    APPLY "ENTRY" TO Fimin.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-round-method IN FRAME Dialog-Frame
DO:
   IF l-round-method:visible then do:
    assign
    label-round-method-2:fgcolor = ?
    l-round-method:visible = false
    t-round-method = yes
    .
    enable S-round-method with frame Dialog-Frame.
    display t-round-method with frame Dialog-Frame .
    APPLY "ENTRY" TO S-round-method.
  end.
END.
ON VALUE-CHANGED OF RS-groups IN FRAME Dialog-Frame
DO:
  assign
  RS-groups.
  CASE rs-groups:
    when "all" then do:
        disable
         b-groups
         b-groups-tree
         with frame Dialog-Frame.
    end.
    when "select" then do:
         disable
         b-groups-tree
         with frame Dialog-Frame.
        enable
         b-groups
         with frame Dialog-Frame.
    end.
   when "select-tree" then do:
         disable
         b-groups
         with frame Dialog-Frame.
        enable
         b-groups-tree
         with frame Dialog-Frame.
    end.
  END CASE.
END.
ON RIGHT-MOUSE-CLICK OF S-round-method IN FRAME Dialog-Frame
DO:
    assign
    label-round-method-2:fgcolor = 15
    l-round-method:visible = true
    t-round-method = no
    .
    display S-round-method with frame Dialog-Frame.
    display t-round-method with frame Dialog-Frame.
    disable S-round-method with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF S-round-method IN FRAME Dialog-Frame
DO:
    assign
  S-round-method
  .
  if lookup(S-round-method,  'Произвольно,Вверх,Коэффициент,9-99окончание':U) > 0 then do:
    display
    f-base
    with frame Dialog-Frame.
    enable
    f-base
    with frame Dialog-Frame.
  end.
  else do:
    hide
    f-base
    in frame Dialog-Frame.
    disable
    f-base
    with frame Dialog-Frame.
  end.
END.
ON RIGHT-MOUSE-CLICK OF Scalc-method IN FRAME Dialog-Frame
DO:
   assign
    label-calc-method-2:fgcolor = 15
    l-calc-method:visible = true
    t-calc-method = no
    .
    display Scalc-method with frame Dialog-Frame.
    display t-calc-method with frame Dialog-Frame.
    disable Scalc-method with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
if v-curr-db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
  "Утилиту можно запустить только в ГБД"
  view-as alert-box error .
  return error .
end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY F-base S-round-method Scalc-method T-calc-method T-increase-pc
          T-minmax T-round-method T-income-cli Fi-cli-type Fi-cli-code
          Fincrease-pc Fimin Fimax RS-method RS-values RS-groups T-global T-firm
          T-object label-calc-method-2 label-round-method-2 label-increase-pc
          label-diap label-diap-2 label-fill-method label-fill-values
          label-fill-subject label-fill-tree
      WITH FRAME Dialog-Frame.
  ENABLE b-quit l-round-method l-increase-pc l-minmax RECT-2 RECT-1 RECT-5
         RECT-3 l-income-cli RECT-4 l-calc-method B-exit B-Help F-base
         S-round-method Scalc-method T-calc-method T-increase-pc T-minmax
         T-round-method T-income-cli Fi-cli-type Fi-cli-code Fincrease-pc Fimin
         Fimax RS-method RS-values RS-groups T-global B-groups T-firm
         B-groups-tree T-object label-calc-method-2 label-round-method-2
         label-increase-pc label-diap label-diap-2 label-fill-method
         label-fill-values label-fill-subject label-fill-tree
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
Scalc-method:list-items in frame Dialog-Frame = 'Учетная,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U.
S-round-method:list-items in frame Dialog-Frame = '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U.
DISPLAY
label-increase-pc
label-calc-method-2
label-round-method-2
label-diap
label-diap-2
label-fill-method
label-fill-subject
label-fill-tree
label-fill-values
RS-groups
RS-method
RS-values
T-firm
T-global
T-object
t-income-cli
B-groups
B-groups-tree
l-calc-method
l-increase-pc
l-minmax
l-round-method
l-income-cli
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-exit
B-Help
RS-groups
RS-method
RS-values
T-firm
T-global
T-object
l-calc-method
l-increase-pc
l-minmax
l-round-method
l-income-cli
B-groups
B-groups-tree
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
APPLY "VAlue-changed" to RS-groups.
END PROCEDURE.
