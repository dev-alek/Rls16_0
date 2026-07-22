&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-ask-pswd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-ask-pswd
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запрос парол

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/12/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  param ittl     as character no-undo .
define output param en-pswd as character no-undo .

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Запрос пароля".
{ cmp/vssrevis.i "substitute('&1':u,ittl)" }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-ask-pswd

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help pswd
&Scoped-Define DISPLAYED-OBJECTS TTL pswd 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE TTL AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 52 BY 6 NO-UNDO.

DEFINE VARIABLE pswd AS CHARACTER FORMAT "X(50)":U 
     LABEL "&Пароль"
     VIEW-AS FILL-IN
     SIZE 44 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-ask-pswd
     pswd AT ROW 9.75 COL 10 COLON-ALIGNED BLANK  PASSWORD-FIELD 
     
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     TTL AT ROW 3 COL 4 NO-LABEL WIDGET-ID 4
     SPACE(2.99) SKIP(1.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод пароля "
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-ask-pswd
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-ask-pswd:SCROLLABLE       = FALSE
       FRAME d-ask-pswd:HIDDEN           = TRUE.

/* SETTINGS FOR EDITOR TTL IN FRAME d-ask-pswd
   NO-ENABLE                                                            */
ASSIGN 
       TTL:READ-ONLY IN FRAME d-ask-pswd        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-ask-pswd
/* Query rebuild information for DIALOG-BOX d-ask-pswd
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-ask-pswd */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-ask-pswd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-ask-pswd d-ask-pswd
ON WINDOW-CLOSE OF FRAME d-ask-pswd /* ВВод пароля  */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-ask-pswd
ON CHOOSE OF b-exit IN FRAME d-ask-pswd /* Ввод  */
DO:
   en-pswd = encode (input pswd).
  /* apply "leave" to pswd IN FRAME d-ask-pswd. */ 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-ask-pswd
ON CHOOSE OF b-quit IN FRAME d-ask-pswd /* Ввод  */
DO:
   en-pswd = ?.
   /* apply "leave" to pswd IN FRAME d-ask-pswd. */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME pswd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL pswd d-ask-pswd
ON LEAVE OF pswd IN FRAME d-ask-pswd /* Пароль */
DO:
  /* if input pswd = "" then do:
    message "Пароль не может быть пустым!" view-as alert-box.
    return no-apply.
  end.
  else */ 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-ask-pswd


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
  en-pswd = "".
  RUN enable_UI.
/*  frame {&frame-name}:title = ttl.*/
  ttl:screen-value = iTTL.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-ask-pswd  _DEFAULT-DISABLE
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
  HIDE FRAME d-ask-pswd.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-ask-pswd  _DEFAULT-ENABLE
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
  DISPLAY TTL pswd 
      WITH FRAME d-ask-pswd.
  ENABLE b-exit b-quit b-help pswd
      WITH FRAME d-ask-pswd.
  VIEW FRAME d-ask-pswd.
  {&OPEN-BROWSERS-IN-QUERY-d-ask-pswd}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

