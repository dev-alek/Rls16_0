&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Дополнительная информация договора  

Автор: Носко Игорь Александрович
Дата создания: 03/02/2011
Author: Igor Nosko
Creation date: 03/02/2011

*/


/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* VSS  Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "$Дополнительная информация договора":U.

/* Parameters Definitions ---                                           */
DEFINE INPUT  PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT  PARAMETER parBackHandle  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT  PARAMETER p-Ref-mode     AS CHARACTER  NO-UNDO. /* ""  {&add-def}, {&update}, {&lookup}, "history" */
DEFINE INPUT  PARAMETER p-Doc-type     AS CHARACTER  NO-UNDO. /*  */
DEFINE INPUT  PARAMETER iRid           AS RECID      NO-UNDO. /*  */
DEFINE OUTPUT PARAMETER cError         AS CHARACTER  NO-UNDO INITIAL "". /*  */ 

/* */ 
{cmp/vssrevis.i}
{cmp/str-glbl.i}
{cmp/showinf.i}
{str/contattr.i}

/* BUFFERS Definitions ---                                       */
DEFINE BUFFER buf_Contract FOR ub.contract. 
/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-Ok b-Exit v-EdUvd 
&Scoped-Define DISPLAYED-OBJECTS v-EdUvd 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-Exit 
     LABEL "&Отмена" 
     SIZE 11.5 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-Ok 
     LABEL "&Ввод" 
     SIZE 12.5 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE v-EdUvd AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 83 BY 12.5 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-Ok AT ROW 1 COL 1
     b-Exit AT ROW 1 COL 13.5
     v-EdUvd AT ROW 2.67 COL 2.5 NO-LABEL WIDGET-ID 16
     SPACE(1.12) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Дополнительная информация" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       v-EdUvd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENTRY OF FRAME Dialog-Frame /* Дополнительная информация */
DO:
   IF p-Ref-mode <> {&UPDATE} THEN DO:          
      ASSIGN 
          b-Exit:HIDDEN = TRUE  
          b-Ok:LABEL     = "&Выход"
          . 
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Дополнительная информация */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Exit Dialog-Frame
ON CHOOSE OF b-Exit IN FRAME Dialog-Frame /* Отмена */
DO:
  {gbl/stdbtn.i}
   APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Ok Dialog-Frame
ON CHOOSE OF b-Ok IN FRAME Dialog-Frame /* Ввод */
DO:
   {gbl/stdbtn.i}
   IF v-EdUvd:SENSITIVE AND v-EdUvd:MODIFIED THEN DO:
      ASSIGN 
         v-EdUvd.
      /* Пишем данные  */ 
      RUN Modify-Contract-Attr IN THIS-PROCEDURE(
          buf_Contract.Host-code, 
          buf_Contract.Contract-code, 
          v-gl-Uvedomlenie,
          v-EdUvd, 
          OUTPUT cError       
          ). 

   END.
   APPLY "GO":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


FIND FIRST buf_Contract WHERE 
           RECID(buf_Contract) = iRid 
     NO-LOCK NO-ERROR. 
IF NOT AVAILABLE buf_Contract THEN DO:
   MESSAGE 
       "Не найден договор RECID(buf_Contract) = " iRid
       VIEW-AS ALERT-BOX INFO BUTTONS OK.
   RETURN. 
END.

/* Выводим номер договора и фирму   */ 
ASSIGN 
   FRAME Dialog-Frame:TITLE = FRAME Dialog-Frame:TITLE +  
         " для договора: " + buf_Contract.contract-prn-code + " " + 
         "Фирма: " + buf_Contract.own-name + " (Уведомление)" .


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  ASSIGN 
     v-EdUvd = Get-contract-attr(
               buf_Contract.Host-code, 
               buf_Contract.Contract-code, 
               v-gl-Uvedomlenie).  

  /* Включить редактирование данных  */ 
  IF p-Ref-mode = {&UPDATE} THEN DO:          
     ASSIGN 
        v-EdUvd:READ-ONLY = FALSE.  
  END. 

  RUN enable_UI.
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
  DISPLAY v-EdUvd 
      WITH FRAME Dialog-Frame.
  ENABLE b-Ok b-Exit v-EdUvd 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

