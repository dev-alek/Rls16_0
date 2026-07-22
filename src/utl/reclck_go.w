&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME gDialog

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS gDialog 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Повторная выгрузка данных для 1С ERP

Автор: Кривошеин Александр Николаевич
Дата создания: 02/09/14
Author: Krivoshein Alexander
Creation date: 02/09/14

*/

/* ***************************  Definitions  ************************** */

/* VSS */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Повторная выгрузка данных для 1С ERP".

/* Includes */

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/cur-time.i }
{ ref/shd-attr.i }

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .

define variable v-obj-list as character no-undo.
define variable ii         as integer   no-undo.
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
define buffer buf_clients for ub.clients .
/* Local Variable Definitions ---                                       */

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME gDialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-3 b-start b-close 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */

/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Other Settings: APPSERVER
 */

/* ************************* Included-Libraries *********************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME gDialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-start b-close F-obj b-obj C-1 
&Scoped-Define DISPLAYED-OBJECTS F-obj C-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-close AUTO-END-KEY 
  LABEL "Отменить" 
  SIZE 15 BY 1.13.

DEFINE BUTTON b-obj 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "" 
  SIZE 3 BY .88.

DEFINE BUTTON b-start 
  LABEL "Запустить" 
  SIZE 15 BY 1.13.

DEFINE VARIABLE C-1   AS CHARACTER FORMAT "X(256)":U 
  VIEW-AS COMBO-BOX INNER-LINES 5
  LIST-ITEM-PAIRS "пересчет","calc",
  "проверка","prov"
  DROP-DOWN-LIST
  SIZE 19.25 BY 1 NO-UNDO.

DEFINE VARIABLE F-obj AS CHARACTER FORMAT "X(256)":U 
  LABEL "Выбрать объект" 
  VIEW-AS FILL-IN 
  SIZE 19.25 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME gDialog
  b-start AT ROW 1.25 COL 2 WIDGET-ID 8
  b-close AT ROW 1.25 COL 42
  F-obj AT ROW 3 COL 16.25 COLON-ALIGNED WIDGET-ID 68
  b-obj AT ROW 3.04 COL 37.75 WIDGET-ID 24
  C-1 AT ROW 4.5 COL 16.25 COLON-ALIGNED NO-LABEL WIDGET-ID 70
  SPACE(21.62) SKIP(2.33)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Выравнивание остатков по массе"
  CANCEL-BUTTON b-close WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Other Settings: APPSERVER
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX gDialog
   FRAME-NAME                                                           */
ASSIGN 
  FRAME gDialog:SCROLLABLE = FALSE
  FRAME gDialog:HIDDEN     = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX gDialog
/* Query rebuild information for DIALOG-BOX gDialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX gDialog */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME gDialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gDialog gDialog
ON WINDOW-CLOSE OF FRAME gDialog /* Выравнивание остатков по массе */
  DO:  
    /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-obj gDialog
ON CHOOSE OF b-obj IN FRAME gDialog
  DO:
    define variable v-exclude-obj-list as character no-undo.
    define variable v-user-select      as logical   no-undo.
    define variable v-object-available as logical   no-undo.

    { gbl/usobjava.i
     v-cntxt-db-num
     {&action-head-code-main}
     v-cntxt-userid
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-object-available
     no-error }
     
    if error-status :error then 
    do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      undo, return no-apply.
    end. /* if error-status */

    if v-object-available = true then 
    do:
      { gbl/uobjapnd.i
         v-cntxt-obj-type
         v-cntxt-obj-code }
    end.

    { gbl/uobjsman.i
     parparentproc
     v-cntxt-db-num
     v-cntxt-userid
     v-cntxt-host-code-obj
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-user-select
      }
     
    if v-user-select <> true then 
    do:
      message "Объект не выбран" view-as alert-box information.
      return no-apply.
    end.
        
    v-obj-list = "".
    f-obj:screen-value = "".
    
    for each userobjs_temp-user-obj:
      v-obj-list = userobjs_temp-user-obj.obj-type + {&comma-char} +
        string(userobjs_temp-user-obj.obj-code).
      find first buf_clients where buf_clients.obj-code = userobjs_temp-user-obj.obj-code
        and buf_clients.obj-type = userobjs_temp-user-obj.obj-type no-lock no-error.
      f-obj:screen-value =  
        (if buf_clients.obj-name <> '' then buf_clients.obj-name
        else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code))
        .
      v-obj-code = buf_clients.obj-code .
      v-obj-type = buf_clients.obj-type .                
    end. /* for each userobjs_temp-user-obj */

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start gDialog
ON CHOOSE OF b-start IN FRAME gDialog /* Запустить */
  DO:
    ASSIGN 
      F-obj
      C-1
      .
    
    run utl/reclckgo.p
      (input parparentproc,
      input v-obj-type,
      input v-obj-code,
      input c-1) no-error .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME C-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-1 gDialog
ON VALUE-CHANGED OF C-1 IN FRAME gDialog
  DO:
    assign
      c-1
      .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK gDialog 


/* ***************************  Main Block  *************************** */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{gbl/getcntxt.i get}
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  RUN enable_UI.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI gDialog  _DEFAULT-DISABLE
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
  HIDE FRAME gDialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI gDialog  _DEFAULT-ENABLE
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
  DISPLAY F-obj C-1 
    WITH FRAME gDialog.
  ENABLE b-start b-close F-obj b-obj C-1 
    WITH FRAME gDialog.
  VIEW FRAME gDialog.
  {&OPEN-BROWSERS-IN-QUERY-gDialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

