&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита простановки налогов по группам товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/29/03
Author: Bakhtadze Natalya
Creation date: 08/29/03

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
define variable vss-description as character no-undo init "Утилита простановки налогов по группам товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }


define variable v-RID-LIST as character no-undo .
{ str/tt-tax.i "new shared"}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-tt-tax

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tax

/* Definitions for BROWSE BR-tt-tax                                     */
&Scoped-define FIELDS-IN-QUERY-BR-tt-tax tt-tax.tax-code tt-tax.tax-name tt-tax.tax-type tt-tax.rate-code tt-tax.rate-name tt-tax.rate-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tt-tax
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-tt-tax
&Scoped-define SELF-NAME BR-tt-tax
&Scoped-define OPEN-QUERY-BR-tt-tax OPEN QUERY {&SELF-NAME} FOR EACH tt-tax NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tt-tax tt-tax
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tt-tax tt-tax


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-tt-tax}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-Help B-add-tt-tax ~
B-del-tt-tax RS-method RS-values RS-groups B-groups B-groups-tree ~
label-fill-method label-fill-values label-fill-subject
&Scoped-Define DISPLAYED-OBJECTS RS-method RS-values RS-groups ~
label-fill-method label-fill-values label-fill-subject

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add-tt-tax
     LABEL "Налог+"
     SIZE 10 BY 1.

DEFINE BUTTON B-del-tt-tax
     LABEL "Налог-"
     SIZE 10 BY 1.

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

DEFINE VARIABLE label-fill-method AS CHARACTER FORMAT "X(256)":U INITIAL "Как заполнять"
      VIEW-AS TEXT
     SIZE 26.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE label-fill-subject AS CHARACTER FORMAT "X(256)":U INITIAL "Какие группы заполнять"
      VIEW-AS TEXT
     SIZE 26.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE label-fill-values AS CHARACTER FORMAT "X(256)":U INITIAL "Чем заполнять"
      VIEW-AS TEXT
     SIZE 26.5 BY .67
     FGCOLOR 4  NO-UNDO.

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
"Все поля", "all"
     SIZE 48.13 BY 3.67 NO-UNDO.

DEFINE VARIABLE RS-values AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Выбранные значения", "default",
"Из группы верх. ур-ня(группа ур. 1 не мен.)", "group"
     SIZE 47.75 BY 2.5 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-tt-tax FOR
      tt-tax SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tt-tax Dialog-Frame _FREEFORM
  QUERY BR-tt-tax DISPLAY
      tt-tax.tax-code
      tt-tax.tax-name
      tt-tax.tax-type
      tt-tax.rate-code
      tt-tax.rate-name
      tt-tax.rate-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 58.63 BY 6.29
         TITLE "Ставки налогов".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     B-add-tt-tax AT ROW 2.29 COL 2.15
     B-del-tt-tax AT ROW 2.29 COL 12.15
     BR-tt-tax AT ROW 3.33 COL 2.13
     RS-method AT ROW 11.54 COL 2.5 NO-LABEL
     RS-values AT ROW 11.58 COL 51.25 NO-LABEL
     RS-groups AT ROW 15.96 COL 2.5 NO-LABEL
     B-groups AT ROW 16.92 COL 41.5
     B-groups-tree AT ROW 17.79 COL 41.5
     label-fill-method AT ROW 10.71 COL 2.25 NO-LABEL
     label-fill-values AT ROW 10.83 COL 51 NO-LABEL
     label-fill-subject AT ROW 15.21 COL 2.38 NO-LABEL
     SPACE(70.36) SKIP(3.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Простановка налогов по группам товаров"
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
/* BROWSE-TAB BR-tt-tax B-del-tt-tax Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BROWSE BR-tt-tax IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN label-fill-method IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-fill-subject IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-fill-values IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tt-tax
/* Query rebuild information for BROWSE BR-tt-tax
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-tax NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-tt-tax */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Простановка налогов по группам товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-tt-tax Dialog-Frame
ON CHOOSE OF B-add-tt-tax IN FRAME Dialog-Frame /* Налог+ */
DO:
DEFINE var tax-rate-rid As char NO-UNDO init "".
DEFINE var taxvalue like ub.tax-rate-value.rate-value NO-UNDO.
DEFINE buffer bf-tt-tax for tt-tax.
  run ref/tax-tree.w ( parparentproc,
                  "b-seltax-rate":U,
                  "ALL-TAX-RATES":U,
                  v-cntxt-host-code-obj,
                  v-cntxt-obj-type,
                  v-cntxt-obj-code,
                  ?,
                  input-output tax-rate-rid) no-error .
  IF ERROR-STATUS:error then return no-apply.
  if tax-rate-rid <> "" then do:
    FIND FIRST ub.tax-rate NO-LOCK WHERE recid(ub.tax-rate) = integer(tax-rate-rid) NO-ERROR.
    if NOT AVAIL ub.tax-rate then return no-apply.
    /*сначала проверим нет ли уже в списке ставки налога такого типа*/
    FIND first bf-tt-tax No-LOCK WHERE
                                   bf-tt-tax.tax-code = tax-rate.tax-code NO-ERROR.
    IF avail bf-tt-tax then do:
        message "В списке ставок налогов уже есть ставка по такому налогу!" view-as
        alert-box ERROR.
        return no-apply.
    end.

    FIND FIRST ub.tax NO-LOCK WHERE ub.tax.tax-code = ub.tax-rate.tax-code NO-ERROR.
    if NOT AVAIL ub.tax then return no-apply.
    if ub.tax.individual then do:
        message "Нельзя редактировать налоги на товар, если налог индивидуальный!"
        view-as alert-box ERROR.
        return no-apply.
    end.
    { gbl/pftaxval.i ? ub.tax-rate.tax-code ub.tax-rate.rate-code ? v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code taxvalue no-error}
    if error-status:error or taxvalue = ? then return no-apply.
    create
    tt-tax.
    assign
    tt-tax.tax-code = ub.tax.tax-code
    tt-tax.tax-name = ub.tax.tax-name
    tt-tax.rate-code = ub.tax-rate.rate-code
    tt-tax.rate-name = ub.tax-rate.rate-name
    tt-tax.tax-type = ub.tax.tax-type
    tt-tax.rate-value = taxvalue
    tt-tax.tax-rate-gds-rc = recid(tax-rate)
    .
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-tt-tax Dialog-Frame
ON CHOOSE OF B-del-tt-tax IN FRAME Dialog-Frame /* Налог- */
DO:
    DEFINE BUFFER bf-tt-tax for tt-tax.
    IF AVAIL tt-tax then do:
        FIND FIRST bf-tt-tax WHERE bf-tt-tax.tax-rate-gds-rc = tt-tax.tax-rate-gds-rc NO-ERROR.
        if avail bf-tt-tax then delete bf-tt-tax.
        OPEN QUERY BR-tt-tax for each tt-tax NO-LOCK.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
  RS-groups RS-method RS-values.
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-groups
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-groups Dialog-Frame
ON CHOOSE OF B-groups IN FRAME Dialog-Frame /* Btn 1 */
DO:

  run ref/gds-grp.w ( input parparentproc
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
                ,input "b-sel,b-mark"
               , input v-cntxt-obj-type
               , input v-cntxt-obj-code
               , input-output v-rid-list ).

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


&Scoped-define BROWSE-NAME BR-tt-tax
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
  RUN enable_UI.
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
  DISPLAY RS-method RS-values RS-groups label-fill-method label-fill-values
          label-fill-subject
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help B-add-tt-tax B-del-tt-tax RS-method RS-values
         RS-groups B-groups B-groups-tree label-fill-method label-fill-values
         label-fill-subject
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run utl/in-grptx.p (
                 input RS-method
                , input RS-groups
                                , input Rs-values
                , input V-RID-LIST) no-error.
if error-status:error then return error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME