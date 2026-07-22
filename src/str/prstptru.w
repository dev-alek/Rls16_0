&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Установка значений в топливном товаре в пересортице

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/23/07
Author: Dmitry Ukhanov
Creation date: 10/23/07

*/



/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
DEFINE PARAMETER BUFFER bf_goods FOR ub.goods.
DEFINE PARAMETER BUFFER bf_place FOR ub.place.
DEFINE INPUT  PARAMETER parcalc-petrol-volume AS LOGICAL   NO-UNDO.
DEFINE INPUT  PARAMETER parmode               AS CHARACTER NO-UNDO.
DEFINE INPUT  PARAMETER parwrite-off          AS LOGICAL   NO-UNDO.
DEFINE INPUT  PARAMETER parfact-l             AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parfact-kg            AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parwork-l             AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parwork-kg            AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parwrite-off-doc-l    AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parwrite-off-doc-kg   AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parincome-doc-l       AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parincome-doc-kg      AS DECIMAL   NO-UNDO.
DEFINE OUTPUT PARAMETER parstate              AS LOGICAL   NO-UNDO.
DEFINE OUTPUT PARAMETER parqnty-l             AS DECIMAL   NO-UNDO.
DEFINE OUTPUT PARAMETER parqnty-kg            AS DECIMAL   NO-UNDO.

/* Local Variable Definitions ---                                         */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Установка значений в топливном товаре в пересортице".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-help
&Scoped-Define DISPLAYED-OBJECTS varfact-l varwork-l vardensity varwork-kg ~
varwrite-off-doc-l varwrite-off-doc-kg varincome-doc-l varincome-doc-kg ~
varfree-l

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE vardensity AS DECIMAL FORMAT "9.9999999999":U INITIAL 0
     LABEL "Плотность"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varfact-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Факт(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varfree-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Свободно(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varincome-doc-kg AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Оприходовано док(кг)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varincome-doc-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Оприходовано док(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varwork-kg AS DECIMAL FORMAT ">,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Кол-во(кг)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varwork-l AS DECIMAL FORMAT ">,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Кол-во(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varwrite-off-doc-kg AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Списано док(кг)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varwrite-off-doc-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Списано док(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varfact-l AT ROW 2.5 COL 20 COLON-ALIGNED
     varwork-l AT ROW 4 COL 20 COLON-ALIGNED
     vardensity AT ROW 4 COL 46.5 COLON-ALIGNED
     varwork-kg AT ROW 4 COL 78.5 COLON-ALIGNED
     varwrite-off-doc-l AT ROW 5.5 COL 20 COLON-ALIGNED
     varwrite-off-doc-kg AT ROW 5.5 COL 78.5 COLON-ALIGNED
     varincome-doc-l AT ROW 7 COL 20 COLON-ALIGNED
     varincome-doc-kg AT ROW 7 COL 78.5 COLON-ALIGNED
     varfree-l AT ROW 8.5 COL 20 COLON-ALIGNED
     SPACE(59.87) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
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

/* SETTINGS FOR BUTTON b-save IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vardensity IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varfact-l IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varfree-l IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varincome-doc-kg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varincome-doc-l IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwork-kg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwork-l IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwrite-off-doc-kg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwrite-off-doc-l IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  IF parcalc-petrol-volume THEN DO:
    IF varwork-l = 0 OR
       varwork-l = ? THEN DO:
      MESSAGE "У Вас не установлено количество в литрах." VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO varwork-l IN FRAME {&FRAME-NAME}.
      RETURN NO-APPLY.
    END.
    IF vardensity = 0 OR
       vardensity = ? THEN DO:
      MESSAGE "У Вас не установлена плотность." VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO vardensity IN FRAME {&FRAME-NAME}.
      RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    IF varwork-kg = 0 OR
       varwork-kg = ? THEN DO:
      MESSAGE "У Вас не установлено количество в килограммах." VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO varwork-kg IN FRAME {&FRAME-NAME}.
      RETURN NO-APPLY.
    END.
    IF vardensity = 0 OR
       vardensity = ? THEN DO:
      MESSAGE "У Вас не установлена плотность." VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO vardensity IN FRAME {&FRAME-NAME}.
      RETURN NO-APPLY.
    END.
  END.
  ASSIGN
    parstate   = YES
    parqnty-l  = varwork-l
    parqnty-kg = varwork-kg.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vardensity
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vardensity Dialog-Frame
ON LEAVE OF vardensity IN FRAME Dialog-Frame /* Плотность */
DO:
    if keyfunction(lastkey) <> "end-error" and
       not ( last-event :event-type   = "progress":u and
             last-event :widget-enter = b-cancel :handle ) then do:
     IF INPUT FRAME {&frame-name} vardensity = 0.00 or
        INPUT FRAME {&FRAME-NAME} vardensity = ?    THEN DO:
        MESSAGE "Вы не установили плотность." VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
     END.
     ASSIGN
       FRAME {&FRAME-NAME} vardensity.
     IF parcalc-petrol-volume THEN DO:
       IF varwork-l <> 0.00 AND
          varwork-l <> ?    THEN DO:
         ASSIGN
           varwork-kg = vardensity * varwork-l.
         DISPLAY varwork-kg WITH FRAME {&FRAME-NAME}.
       END.
     END.
     ELSE DO:
       IF varwork-kg <> 0.00 AND
          varwork-kg <> ?    THEN DO:
         ASSIGN
           varwork-l = varwork-kg / vardensity.
         DISPLAY varwork-l WITH FRAME {&FRAME-NAME}.
       END.
     END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varwork-kg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varwork-kg Dialog-Frame
ON LEAVE OF varwork-kg IN FRAME Dialog-Frame /* Кол-во(кг) */
DO:
    if keyfunction(lastkey) <> "end-error" and
       not ( last-event :event-type   = "progress":u and
             last-event :widget-enter = b-cancel :handle ) then do:
     IF INPUT FRAME {&frame-name} varwork-kg = 0.00 or
        INPUT FRAME {&FRAME-NAME} varwork-kg = ?    THEN DO:
        MESSAGE "Вы не установили количество в килограммах." VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
     END.
     ASSIGN
       FRAME {&FRAME-NAME} varwork-kg.
     IF vardensity <> 0.00 AND
        vardensity <> ?    THEN DO:
       ASSIGN
         varwork-l = varwork-l / vardensity.
       DISPLAY varwork-l WITH FRAME {&FRAME-NAME}.
     END.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varwork-kg Dialog-Frame
ON return OF varwork-kg IN FRAME Dialog-Frame /* Кол-во(кг) */
DO:
  APPLY "ENTRY" TO vardensity IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varwork-l
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varwork-l Dialog-Frame
ON LEAVE OF varwork-l IN FRAME Dialog-Frame /* Кол-во(л) */
DO:
  if keyfunction(lastkey) <> "end-error" and
     not ( last-event :event-type   = "progress":u and
           last-event :widget-enter = b-cancel :handle ) then do:
   IF INPUT FRAME {&frame-name} varwork-l = 0.00 or
      INPUT FRAME {&FRAME-NAME} varwork-l = ?    THEN DO:
      MESSAGE "Вы не установили количество в литрах." VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
   END.
   ASSIGN
     FRAME {&FRAME-NAME} varwork-l.
   IF vardensity <> 0.00 AND
      vardensity <> ?    THEN DO:
     ASSIGN
       varwork-kg = vardensity * varwork-l.
     DISPLAY varwork-kg WITH FRAME {&FRAME-NAME}.
   END.

 END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varwork-l Dialog-Frame
ON return OF varwork-l IN FRAME Dialog-Frame /* Кол-во(л) */
DO:
  APPLY "ENTRY" TO vardensity IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    frame {&FRAME-NAME} :title = "Товар:  " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code) + " " + bf_goods.gds-name + " Складское место: " + string(bf_place.pl-code) + "(" + bf_place.loc1 + ")" + " - " + parmode.
  .
  ASSIGN
    varfact-l           = parfact-l
    /*varfact-kg          = parfact-kg*/
    varwork-l           = parwork-l
    varwork-kg          = parwork-kg
    varwrite-off-doc-l  = parwrite-off-doc-l
    varwrite-off-doc-kg = parwrite-off-doc-kg
    varincome-doc-l     = parincome-doc-l
    varincome-doc-kg    = parincome-doc-kg
    varfree-l           = varfact-l  + (IF parwrite-off THEN - varwork-l  ELSE varwork-l)  - parwrite-off-doc-l  + parincome-doc-l
    /*varfree-kg          = varfact-kg + (IF parwrite-off THEN - varwork-kg ELSE varwork-kg) - parwrite-off-doc-kg + parincome-doc-kg*/
  .
  IF varwork-l <> 0 AND
     varwork-l <> ? THEN DO:
    ASSIGN
      vardensity = varwork-kg / varwork-l.
  END.
  RUN enable_UI.
  DISPLAY varfact-l /*varfact-kg*/ varwork-l varwork-kg varwrite-off-doc-l varwrite-off-doc-kg varincome-doc-l varincome-doc-kg varfree-l /*varfree-kg*/ WITH FRAME {&FRAME-NAME}.
  IF parmode = {&UPDATE} THEN DO:
    ENABLE b-save vardensity WITH FRAME {&FRAME-NAME}.
    IF parcalc-petrol-volume = YES THEN DO:
      ENABLE varwork-l WITH FRAME {&FRAME-NAME}.
      WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS varwork-l.
    END.
    ELSE DO:
      ENABLE varwork-kg WITH FRAME {&FRAME-NAME}.
      WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS varwork-kg.
    END.
  END.
  ELSE DO:
    WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS b-cancel.
  END.
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
  DISPLAY varfact-l varwork-l vardensity varwork-kg varwrite-off-doc-l
          varwrite-off-doc-kg varincome-doc-l varincome-doc-kg varfree-l
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME