&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

инициализация поля СПОСОБ РАСЧЕТА в gds-grp

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Инициализация поля СПОСОБ РАСЧЕТА в gds-grp".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

define variable v-RID-LIST as character no-undo .
define variable v-curr-db-num like ub.db.db-num no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit l-round-method l-increase-pc l-minmax ~
RECT-2 RECT-1 RECT-5 RECT-3 l-income-cli RECT-4 l-calc-method B-exit B-Help ~
F-base S-round-method Scalc-method T-calc-method T-increase-pc T-minmax ~
T-round-method T-income-cli Fi-cli-type Fi-cli-code Fincrease-pc Fimin ~
Fimax RS-method RS-values RS-groups T-global B-groups T-firm B-groups-tree ~
T-object label-calc-method-2 label-round-method-2 label-increase-pc ~
label-diap label-diap-2 label-fill-method label-fill-values ~
label-fill-subject label-fill-tree
&Scoped-Define DISPLAYED-OBJECTS F-base S-round-method Scalc-method ~
T-calc-method T-increase-pc T-minmax T-round-method T-income-cli ~
Fi-cli-type Fi-cli-code Fincrease-pc Fimin Fimax RS-method RS-values ~
RS-groups T-global T-firm T-object label-calc-method-2 label-round-method-2 ~
label-increase-pc label-diap label-diap-2 label-fill-method ~
label-fill-values label-fill-subject label-fill-tree

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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


/* ************************  Frame Definitions  *********************** */

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


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN label-calc-method-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-diap IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-diap-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-fill-method IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-fill-subject IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-fill-tree IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-fill-values IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-increase-pc IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заполнение полей ПАРАМЕТРЫ НА ОБЪЕКТАХ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
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
    lookup(Scalc-method, {&pr-calc-methods-grp-list}) = 0) AND
    t-calc-method then do:
      message
      "Выберите значение для заполнения поля СПОСОБ РАСЧЕТА"
      view-as alert-box .
      return no-apply .
  end.
  if RS-values = "default":U AND
    (S-round-method = ? or
    S-round-method = "":U or
    lookup(S-round-method, {&pr-rounds}) = 0) AND
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
      when {&pr-rounds-need-coef} then do:
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-groups
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-groups Dialog-Frame
ON CHOOSE OF B-groups IN FRAME Dialog-Frame /* Btn 1 */
DO:

  run ref/gds-grp.w (
                input parparentproc
              , input "b-sel,b-mark"
              , input v-cntxt-obj-type
              , input v-cntxt-obj-code
              , input-output v-rid-list ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-groups-tree
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-groups-tree Dialog-Frame
ON CHOOSE OF B-groups-tree IN FRAME Dialog-Frame /* Btn 1 */
DO:
  run ref/gds-grp.w (
                input parparentproc
              , input "b-sel,b-mark"
              , input v-cntxt-obj-type
              , input v-cntxt-obj-code
              , input-output v-rid-list ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Fi-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Fi-cli-code Dialog-Frame
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
    in frame {&frame-name}.
    ENABLE l-income-cli
    with frame {&frame-name}.
    display t-income-cli
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Fi-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Fi-cli-type Dialog-Frame
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
    in frame {&frame-name}.
    ENABLE l-income-cli
    with frame {&frame-name}.
    display
    t-income-cli
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Fimax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Fimax Dialog-Frame
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
    in frame {&frame-name}.
    ENABLE l-minmax
    with frame {&frame-name}.
    display t-minmax
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Fimin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Fimin Dialog-Frame
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
    in frame {&frame-name}.
    ENABLE l-minmax
    with frame {&frame-name}.
    display
    t-minmax
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Fincrease-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Fincrease-pc Dialog-Frame
ON RIGHT-MOUSE-CLICK OF Fincrease-pc IN FRAME Dialog-Frame
DO:
    assign
    label-increase-pc:fgcolor = 15
    l-increase-pc:visible = true
    t-increase-pc = no
    .
    hide Fincrease-pc in frame {&frame-name}.
    disable Fincrease-pc with frame {&frame-name}.
    display
    t-increase-pc
    with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-calc-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-calc-method Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-calc-method IN FRAME Dialog-Frame
DO:
   IF l-calc-method:visible then do:
    assign
    label-calc-method-2:fgcolor = ?
    l-calc-method:visible = false
    t-calc-method = yes
    .
    enable Scalc-method with frame {&frame-name}.
    display t-calc-method with frame {&frame-name} .
    APPLY "ENTRY" TO Scalc-method.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-income-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-income-cli Dialog-Frame
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
     with frame {&frame-name}.
    display t-income-cli with frame {&frame-name} .
    APPLY "ENTRY" TO Fi-cli-type.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-increase-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-increase-pc Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-increase-pc IN FRAME Dialog-Frame
DO:
   IF l-increase-pc:visible then do:
    assign
    label-increase-pc:fgcolor = ?
    l-increase-pc:visible = false
    t-increase-pc = yes
    .
    enable Fincrease-pc with frame {&frame-name}.
    display t-increase-pc with frame {&frame-name} .
    APPLY "ENTRY" TO Fincrease-pc.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-minmax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-minmax Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-minmax IN FRAME Dialog-Frame
DO:
   IF l-minmax:visible then do:
    assign
    label-diap:fgcolor = ?
    l-minmax:visible = false
    t-minmax = yes
    .
    enable Fimax Fimin with frame {&frame-name}.
    display t-minmax with frame {&frame-name} .
    APPLY "ENTRY" TO Fimin.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-round-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-round-method Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-round-method IN FRAME Dialog-Frame
DO:
   IF l-round-method:visible then do:
    assign
    label-round-method-2:fgcolor = ?
    l-round-method:visible = false
    t-round-method = yes
    .
    enable S-round-method with frame {&frame-name}.
    display t-round-method with frame {&frame-name} .
    APPLY "ENTRY" TO S-round-method.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-groups
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-groups Dialog-Frame
ON VALUE-CHANGED OF RS-groups IN FRAME Dialog-Frame
DO:
  assign
  RS-groups.
  CASE rs-groups:
    when "all" then do:
        disable
         b-groups
         b-groups-tree
         with frame {&frame-name}.
    end.
    when "select" then do:
         disable
         b-groups-tree
         with frame {&frame-name}.
        enable
         b-groups
         with frame {&frame-name}.
    end.
   when "select-tree" then do:
         disable
         b-groups
         with frame {&frame-name}.
        enable
         b-groups-tree
         with frame {&frame-name}.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME S-round-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL S-round-method Dialog-Frame
ON RIGHT-MOUSE-CLICK OF S-round-method IN FRAME Dialog-Frame
DO:
    assign
    label-round-method-2:fgcolor = 15
    l-round-method:visible = true
    t-round-method = no
    .
    display S-round-method with frame {&frame-name}.
    display t-round-method with frame {&frame-name}.
    disable S-round-method with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL S-round-method Dialog-Frame
ON VALUE-CHANGED OF S-round-method IN FRAME Dialog-Frame
DO:
    assign
  S-round-method
  .
  if lookup(S-round-method,  {&pr-rounds-need-coef}) > 0 then do:
    display
    f-base
    with frame {&frame-name}.
    enable
    f-base
    with frame {&frame-name}.
  end.
  else do:
    hide
    f-base
    in frame {&frame-name}.
    disable
    f-base
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Scalc-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Scalc-method Dialog-Frame
ON RIGHT-MOUSE-CLICK OF Scalc-method IN FRAME Dialog-Frame
DO:
   assign
    label-calc-method-2:fgcolor = 15
    l-calc-method:visible = true
    t-calc-method = no
    .
    display Scalc-method with frame {&frame-name}.
    display t-calc-method with frame {&frame-name}.
    disable Scalc-method with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
{ gbl/curdbnum.i v-curr-db-num }
if v-curr-db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
  "Утилиту можно запустить только в ГБД"
  view-as alert-box error .
  return error .
end.

  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
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
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
Scalc-method:list-items in frame {&frame-name} = {&pr-calc-methods-grp-list}.
S-round-method:list-items in frame {&frame-name} = {&pr-rounds}.
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME