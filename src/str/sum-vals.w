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

Выбор диапазонов сумм для почасового отчета по диапазонам сумм продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/10/99
Author: Bakhtadze Natalya
Creation date: 08/10/99

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор диапазонов сумм для почасового отчета по диапазонам сумм продаж ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getsect.i def }

DEFINE SHARED temp-table sum-vals no-undo
field sum1   like ub.chk-doc.netto
field sum2   like ub.chk-doc.netto
field num-chk   like ub.inkas.num-chk extent 24
field tot like ub.inkas.num-chk
INDEX pi IS PRIMARY sum1 ASCENDING .
/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable sum-step as decimal no-undo.
define variable sum-from as decimal no-undo.
define variable sum-to as decimal no-undo.
define variable sum-current as decimal no-undo.
define variable idec  as decimal no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_EXIT B-help SEL-0 SEL-1 BTN_Select ~
BTN_Delete BTN-delete-all Btn-ALL
&Scoped-Define DISPLAYED-OBJECTS SEL-0 SEL-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON Btn-ALL
     LABEL "ВСЕ"
     SIZE 9.63 BY 1.08.

DEFINE BUTTON BTN-delete-all
     LABEL "ВСЕ"
     SIZE 9.13 BY 1.

DEFINE BUTTON BTN_Delete
     LABEL "Удалить"
     SIZE 9.5 BY 1.25.

DEFINE BUTTON Btn_EXIT
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BTN_Select
     LABEL "Выбрать"
     SIZE 9.5 BY 1.25.

DEFINE VARIABLE SEL-0 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "0_10","10_20","20_30","30_40","40_50","50_60","60_70","70_80","80_90","90_100","100_150","150_200","200_300","300_400","400_500","500_1000","1000_1500","1500_2000","2000_3000","3000_4000","4000_5000","5000_7500","7500_10000","10000_10000000"
     SIZE 17 BY 7 TOOLTIP "Доступные диапазоны" NO-UNDO.

DEFINE VARIABLE SEL-1 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 17 BY 7 TOOLTIP "Выбранные диапазоны" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_EXIT AT ROW 1 COL 1
     B-help AT ROW 1 COL 31
     SEL-0 AT ROW 2.96 COL 2.13 NO-LABEL
     SEL-1 AT ROW 3.04 COL 29.5 NO-LABEL
     BTN_Select AT ROW 10.79 COL 4.5
     BTN_Delete AT ROW 10.79 COL 33
     BTN-delete-all AT ROW 12.25 COL 33.25
     Btn-ALL AT ROW 12.29 COL 4.5
     SPACE(33.86) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выберите диапазоны"
         DEFAULT-BUTTON Btn_EXIT.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выберите диапазоны */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn-ALL
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-ALL Dialog-Frame
ON CHOOSE OF Btn-ALL IN FRAME Dialog-Frame /* ВСЕ */
DO:
define variable i as integer.
define variable sum-1 like ub.chk-doc.netto.
define variable sum-2 like ub.chk-doc.netto.

  do i = 1 to SEL-0:num-items:
      assign
      sum-1 = DEC(ENTRY(1,ENTRY(i,SEL-0:list-items),"_"))
      sum-2 = DEC(ENTRY(2,ENTRY(i,SEL-0:list-items),"_")).
      find first sum-vals where sum-vals.sum1 = sum-1 no-lock no-error.
      if not avail sum-vals then do:
          create sum-vals.
          assign sum1 = sum-1
             sum2 = sum-2.
          SEL-1:ADD-LAST(string(sum-1) + "_" + string(sum-2)).
      end.
  end.
  apply "entry" to sel-0.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BTN-delete-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BTN-delete-all Dialog-Frame
ON CHOOSE OF BTN-delete-all IN FRAME Dialog-Frame /* ВСЕ */
DO:
  define variable for_sums as character.
  define variable i as integer.
  define variable j as integer.
  j = SEL-1:num-items.
  do i = 1 to j:
      for_sums = ENTRY(1,Sel-1:LIST-ITEMS).
      SEL-1:DELETE(1).
      FIND FIRST sum-vals where sum1 = DEC(ENTRY(1,for_sums,"_")) NO-ERROR.
      IF AVAILABLE sum-vals then delete sum-vals.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BTN_Delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BTN_Delete Dialog-Frame
ON CHOOSE OF BTN_Delete IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable for_sums as character.
  assign sel-1.
  for_sums = Sel-1.
  SEL-1:DELETE(for_sums).
  FIND FIRST sum-vals where sum1 = DEC(ENTRY(1,for_sums,"_")) NO-ERROR.
  IF AVAILABLE sum-vals then delete sum-vals.
  APPLY "ENTRY" to sel-1.
  APPLY "CURSOR-UP" to sel-1.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BTN_Select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BTN_Select Dialog-Frame
ON CHOOSE OF BTN_Select IN FRAME Dialog-Frame /* Выбрать */
DO:
  define variable for_sums as char.
  define variable sum-1 like ub.chk-doc.netto.
  define variable sum-2 like ub.chk-doc.netto.


  assign SEl-0.
  assign
  sum-1 = DEC(ENTRY(1,SEL-0,"_"))
  sum-2 = DEC(ENTRY(2,SEl-0,"_")).
  find first sum-vals where sum-vals.sum1 = sum-1 no-lock no-error.
  if available sum-vals then do:
    bell.
    message "Этот диапазон уже выбран" .
    apply "entry" to sel-0.
    return.
  end.
  create sum-vals.
  assign sum1 = sum-1
         sum2 = sum-2.
  SEL-1:ADD-LAST(SEl-0).
  apply "entry" to sel-0.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SEL-0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SEL-0 Dialog-Frame
ON LEFT-MOUSE-DBLCLICK OF SEL-0 IN FRAME Dialog-Frame
DO:
     APPLY "CHOOSE" to Btn_select.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SEL-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SEL-1 Dialog-Frame
ON DELETE-CHARACTER OF SEL-1 IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE" to BTN_Delete.
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


{ gbl/getsect.i run "''" 0 {&attr-report-glob}}
  for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-report-glob_sumvals}  then  dops = thbjattr_thbj-attr.property-value-character.
    if thbjattr_thbj-attr.prop-code = {&attr-report-glob_sum-step} then  sum-step = thbjattr_thbj-attr.property-value-decimal .
    if thbjattr_thbj-attr.prop-code = {&attr-report-glob_sum-from} then  sum-from = thbjattr_thbj-attr.property-value-decimal .
    if thbjattr_thbj-attr.prop-code = {&attr-report-glob_sum-to}   then  sum-to = thbjattr_thbj-attr.property-value-decimal .
  end.


/*   !!!    ПОСМОТРЕЛА */
  IF dops <> "" and dops <> ? and dops <> "0" then
  sel-0:list-items = dops.
  else do:
    assign
    sum-current = sum-from
    sel-0:list-items = "".
    DO while sum-current < sum-to:
          SEL-0:ADD-LAST(string(sum-current) + "_" + string(sum-current + sum-step)).
        assign
        sum-current = sum-current + sum-step.
    end.
  end.

  RUN enable_UI.

  for each sum-vals no-lock:
    sel-1:add-last(string(sum-vals.sum1) + "_" + string(sum-vals.sum2)).
  end.

  WAIT-FOR CHOOSE OF BTN_exit.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY SEL-0 SEL-1
      WITH FRAME Dialog-Frame.
  ENABLE Btn_EXIT B-help SEL-0 SEL-1 BTN_Select BTN_Delete BTN-delete-all
         Btn-ALL
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME