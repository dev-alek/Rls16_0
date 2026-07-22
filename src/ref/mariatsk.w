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

Периодические задания кассы MARIA


Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/01/06
Author: Bakhtadze Natalya
Creation date: 06/01/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINe INPUT-OUTPUT PARAMETER p-obj-list AS CHARACTER NO-UNDO.
DEFINe INPUT-OUTPUT PARAMETER p-params AS CHARACTER NO-UNDO.
define output parameter p-ok as logical no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Периодические задания кассы MARIA".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ str/tekkatsk.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help t-spool dtime dtime-par ~
t-income checktime checktime-par t-rsrv-line zfactor
&Scoped-Define DISPLAYED-OBJECTS t-spool dtime dtime-par t-income checktime ~
checktime-par t-rsrv-line zfactor

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

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE checktime-par AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Мин"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE dtime-par AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Мин"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE checktime AS LOGICAL INITIAL no
     LABEL "Периодичность выгрузки"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY 1 NO-UNDO.

DEFINE VARIABLE dtime AS LOGICAL INITIAL no
     LABEL "Периодичность выгрузки журналов"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY 1 NO-UNDO.

DEFINE VARIABLE t-income AS LOGICAL INITIAL no
     LABEL "Выгрузка данных по приходу топлива"
     VIEW-AS TOGGLE-BOX
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE t-rsrv-line AS LOGICAL INITIAL no
     LABEL "Выгрузка данных с уровнемеров"
     VIEW-AS TOGGLE-BOX
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE t-spool AS LOGICAL INITIAL no
     LABEL "Выгрузка чеков"
     VIEW-AS TOGGLE-BOX
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE zfactor AS LOGICAL INITIAL no
     LABEL "Выгрузка после z-отчета"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 71
     t-spool AT ROW 2.5 COL 1
     dtime AT ROW 2.5 COL 46.5
     dtime-par AT ROW 2.5 COL 84.5 COLON-ALIGNED
     t-income AT ROW 4 COL 1
     checktime AT ROW 4 COL 46.5
     checktime-par AT ROW 4 COL 84.5 COLON-ALIGNED
     t-rsrv-line AT ROW 5.5 COL 1
     zfactor AT ROW 5.5 COL 46.5
     SPACE(13.99) SKIP(1.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Определение периодического задания для кассы MARIA"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Определение периодического задания для кассы MARIA */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME checktime
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL checktime Dialog-Frame
ON VALUE-CHANGED OF checktime IN FRAME Dialog-Frame /* Периодичность выгрузки */
DO:
   ASSIGN
  checktime.
  CASE checktime:
      WHEN YES THEN DO:
         ENABLE
         checktime-par
         WITH FRAME {&FRAME-NAME}.
      END.
      WHEN no THEN DO:
          checktime-par =0.
          DISPLAY
          checktime-par
          WITH FRAME {&FRAME-NAME}.
          DISABLE
          checktime-par
          WITH FRAME {&FRAME-NAME}.

      END.

  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME dtime
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL dtime Dialog-Frame
ON VALUE-CHANGED OF dtime IN FRAME Dialog-Frame /* Периодичность выгрузки журналов */
DO:
  ASSIGN
  dtime.
  CASE dtime:
      WHEN YES THEN DO:
         ENABLE
         dtime-par
         WITH FRAME {&FRAME-NAME}.
      END.
      WHEN no THEN DO:
          dtime-par =0.
          DISPLAY
          dtime-par
          WITH FRAME {&FRAME-NAME}.
          DISABLE
          dtime-par
          WITH FRAME {&FRAME-NAME}.
      END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-income
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-income Dialog-Frame
ON VALUE-CHANGED OF t-income IN FRAME Dialog-Frame /* Выгрузка данных по приходу топлива */
DO:

ASSIGN  t-income.
RUN proc-non-spool IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rsrv-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rsrv-line Dialog-Frame
ON VALUE-CHANGED OF t-rsrv-line IN FRAME Dialog-Frame /* Выгрузка данных с уровнемеров */
DO:
  ASSIGN  t-rsrv-line.
RUN proc-non-spool IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
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
  DISPLAY t-spool dtime dtime-par t-income checktime checktime-par t-rsrv-line
          zfactor
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help t-spool dtime dtime-par t-income checktime
         checktime-par t-rsrv-line zfactor
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-exists-spool AS INTEGER NO-UNDO.
DEFINE VARIABLE v-exists-income AS INTEGER NO-UNDO.
DEFINE VARIABLE v-exists-rsrv-line AS INTEGER NO-UNDO.
define variable v-entry as character no-undo .
DO ii = 1 TO NUM-ENTRIES({&spool-objects}):
    ASSIGN
    v-exists-spool = v-EXISTS-spool + (IF LOOKUP(ENTRY(ii, {&spool-objects} ), p-obj-list) > 0
                                      THEN 1
                                      ELSE 0)
    v-exists-income = v-EXISTS-income + (IF LOOKUP(ENTRY(ii, {&income-objects} ), p-obj-list) > 0
                                        THEN 1
                                        ELSE 0)
    v-exists-rsrv-line = v-EXISTS-rsrv-line + (IF LOOKUP(ENTRY(ii, {&rsrv-line-objects} ), p-obj-list) > 0
                                              THEN 1
                                              ELSE 0)
    .

END.
ASSIGN
t-spool = (v-exists-spool = NUM-ENTRIES({&spool-objects}))
t-income = (v-exists-income = NUM-ENTRIES({&income-objects}))
t-rsrv-line = (v-exists-rsrv-line = NUM-ENTRIES({&rsrv-line-objects}))
.
DO ii = 1 TO NUM-ENTRIES(p-params):
    v-entry = ENTRY(ii, p-params).
   IF v-entry BEGINS 'dtime':U THEN DO:
       ASSIGN
       dtime = YES
       dtime-par = INTEGER(ENTRY(2, v-entry, '=':U))
       .
   END.
   IF v-entry BEGINS 'checktime':U THEN DO:
       ASSIGN
       checktime = YES
       checktime-par = INTEGER(ENTRY(2, v-entry, '=':U))
       .

   END.
   IF v-entry BEGINS 'zfactor':U THEN DO:
       ASSIGN
       checktime = YES
       .

   END.

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DISPLAY
t-spool
dtime
dtime-par
checktime
checktime-par
zfactor
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
t-spool
dtime
dtime-par
/*checktime
checktime-par*/
/*это разрешим когда будем выгружать еще и приходы?*/
zfactor
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-non-spool Dialog-Frame
PROCEDURE proc-non-spool :
define variable income-and-rsrv-line as logical no-undo .
income-and-rsrv-line = t-income and t-rsrv-line.
  CASE income-and-rsrv-line:
      WHEN yes THEN DO:
        ENABLE
        checktime
        WITH FRAME {&FRAME-NAME}.
        APPLY "VALUE-changed" TO checktime.
      END.
      WHEN no THEN DO:
          ASSIGN
          checktime = NO.
          disable
          checktime
          WITH FRAME {&FRAME-NAME}.
          APPLY "VALUE-changed" TO checktime.
     END.
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
ASSIGN
FRAME {&FRAME-NAME}
t-spool
checktime
checktime-par WHEN checktime
dtime
dtime-par when dtime
zfactor
.
ASSIGN
p-obj-list = (IF t-spool
              then ({&spool-objects} + {&comma-char} + string({&closed-shift-info}))
              ELSE '')
p-obj-list = p-obj-list +
            (IF t-income
            then ((if p-obj-list = '':U then '':U else {&comma-char}) +
                  {&income-objects} + {&comma-char} + string({&closed-shift-info})
                  )
            else '':U)
p-obj-list = p-obj-list +
            (IF t-rsrv-line
            then ( (if p-obj-list = '':U then '':U else {&comma-char}) +
                   {&rsrv-line-objects} + {&comma-char} + string({&closed-shift-info})
                   )
            else '':U)
p-params = (IF dtime
          THEN ('dtime=' + string(dtime-par))
           ELSE '':U) +
          (IF checktime
          THEN ('checktime=':U + string(checktime-par))
          ELSE '':U) +
          (IF zfactor THEN 'zfactor=1' ELSE '':U)
p-ok = yes.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME