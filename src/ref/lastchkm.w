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

Редактирование атрибута кассы МАРИЯ - параметры последнего принятого чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/06/06
Author: Bakhtadze Natalya
Creation date: 04/06/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
/*тайтл окан*/
DEFINE INPUT-OUTPUT PARAMETER p-date AS DATE NO-UNDO.
/*дата чеков товарных*/
DEFINE INPUT-OUTPUT PARAMETER p-z-num AS integer NO-UNDO.
/*смена чеков товарных*/
define input-output parameter p-num-recs as decimal no-undo .
/*количество считанных записей - строк*/
DEFINE INPUT-OUTPUT PARAMETER p-p-date AS DATE NO-UNDO.
/*дата чеков топливных*/
DEFINE INPUT-OUTPUT PARAMETER p-p-z-num AS integer NO-UNDO.
/*смена чеков топливных*/
define input-output parameter p-p-num-recs as integer no-undo .
/*количество считанных записей - строк*/


DEFINE OUTPUT PARAMETER p-ok AS LOGICAL NO-UNDO.

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE vss-revision    as character no-undo init "$Revision$":U .
DEFINE VARIABLE vss-author      as character no-undo init "$Author$":U .
DEFINE varIABLE vss-date        as character no-undo init "$Date$":U .
DEFINE varIABLE vss-workfile    as character no-undo init "$Workfile$":U .
DEFINE varIABLE vss-archive     as character no-undo init "$Archive$":U .
DEFINE varIABLE vss-description as character no-undo init "Редактирование атрибута кассы МАРИЯ - параметры последнего принятого чека".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-date f-p-date f-z-num ~
f-p-z-num f-num-recs f-p-num-recs
&Scoped-Define DISPLAYED-OBJECTS f-date f-p-date f-z-num f-p-z-num ~
f-num-recs f-p-num-recs

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

DEFINE VARIABLE f-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата товарных чеков"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-recs AS DECIMAL FORMAT ">>>9.9999":U INITIAL 0.0
     LABEL "Кол-во считанных записей (строк)"
      VIEW-AS TEXT
     SIZE 6 BY .67 NO-UNDO.

DEFINE VARIABLE f-p-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата топливных чеков"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-p-num-recs AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Кол-во считанных записей (строк)"
      VIEW-AS TEXT
     SIZE 6 BY .67 NO-UNDO.

DEFINE VARIABLE f-p-z-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "№ смены посл. принятого топл. чека"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-z-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "№ смены посл. принятого тов. чека"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-date AT ROW 3 COL 26.5 COLON-ALIGNED
     f-p-date AT ROW 3 COL 72 COLON-ALIGNED
     f-z-num AT ROW 5 COL 34 COLON-ALIGNED
     f-p-z-num AT ROW 5 COL 79.5 COLON-ALIGNED
     f-num-recs AT ROW 6.75 COL 33.5 COLON-ALIGNED
     f-p-num-recs AT ROW 6.75 COL 78.5 COLON-ALIGNED
     SPACE(12.74) SKIP(0.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame
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


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/ed_date.i f-date }
{ gbl/ed_date.i f-p-date }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN Myenable.
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
  DISPLAY f-date f-p-date f-z-num f-p-z-num f-num-recs f-p-num-recs
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-date f-p-date f-z-num f-p-z-num f-num-recs
         f-p-num-recs
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
ASSIGN
f-date = p-date
f-p-date = p-p-date
f-z-num = p-z-num
f-p-z-num = p-p-z-num
f-num-recs = p-num-recs
f-p-num-recs = p-p-num-recs
FRAME {&frame-name}:TITLE = ENTRY(1, p-title, {&delim-par})
f-date:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title, {&delim-par}) > 1
                                         THEN ENTRY(2, p-title, {&delim-par})
                                         ELSE f-date:LABEL IN FRAME {&frame-name})
f-p-date:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title, {&delim-par}) > 2
                                        THEN ENTRY(3, p-title, {&delim-par})
                                        ELSE f-p-date:LABEL IN FRAME {&frame-name})
f-z-num:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title, {&delim-par}) > 3
                                         THEN ENTRY(4, p-title, {&delim-par})
                                         ELSE f-z-num:LABEL IN FRAME {&frame-name})
f-p-z-num:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title, {&delim-par}) > 4
                                        THEN ENTRY(5, p-title, {&delim-par})
                                        ELSE f-p-z-num:LABEL IN FRAME {&frame-name})

.
DISPLAY
f-date
f-p-date
f-z-num
f-p-z-num
f-num-recs
f-p-num-recs
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
f-date
f-p-date
f-z-num
f-p-z-num
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-ok as logical no-undo .
define variable v-mes as character no-undo .
ASSIGN
f-date FRAME {&FRAME-NAME}
f-p-date
f-z-num
f-p-z-num
.
IF f-date = ?
OR f-p-date = ? THEN DO:
    MESSAGE
    "Дата чека должна быть определена"
    VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
END.
IF f-z-num = 0
OR f-p-z-num = 0
OR f-z-num > 100
OR f-p-z-num > 100
THEN DO:
    MESSAGE
    "№ смены (для кассы MARIA - это последние две цифры z-отчета - или 100)" SKIP
    "не может быть равен 0"
    VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
END.
IF p-date <> f-date
OR p-z-num <> f-z-num
THEN DO:
    p-num-recs = 0.0.
END.
IF p-p-date <> f-p-date
OR p-p-z-num <> f-p-z-num THEN DO:
    p-p-num-recs = 0.
END.

ASSIGN
p-date = f-date
p-p-date = f-p-date
p-z-num = f-z-num
p-p-z-num = f-p-z-num
p-ok = yes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME