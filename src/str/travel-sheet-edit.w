&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

def input param parparentproc as Widget-handle no-undo .
def input param p-mode as char no-undo. /* {&add-def} {&update}  */
def output param p-result as logical no-undo.
def input-output param p-recid as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование Путевого листа. Документы->Путевые листы".

{ str/travel-sheets-inc.i }
{ cmp/vssrevis.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES cd-doc

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH cd-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH cd-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame cd-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame cd-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel num ts-date ~
permitted-filling fuel-code-str BUTTON-sel-fuel card-code-str ~
BUTTON-sel-car 
&Scoped-Define DISPLAYED-OBJECTS num ts-date permitted-filling ~
fuel-code-str card-code-str 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-sel-car 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON BUTTON-sel-fuel 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE VARIABLE card-code-str AS CHARACTER FORMAT "X(256)":U 
     LABEL "Номер карты" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE fuel-code-str AS CHARACTER FORMAT "X(256)":U 
     LABEL "Топливо" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE num AS CHARACTER FORMAT "X(20)" 
     LABEL "Номер ПЛ" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 NO-UNDO.

DEFINE VARIABLE permitted-filling AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Разрешенный налив" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE ts-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      cd-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 2
     Btn_Cancel AT ROW 1 COL 12
     num AT ROW 2.91 COL 12 COLON-ALIGNED WIDGET-ID 2
     ts-date AT ROW 4.33 COL 12 COLON-ALIGNED WIDGET-ID 8
     permitted-filling AT ROW 4.33 COL 51 COLON-ALIGNED WIDGET-ID 10
     fuel-code-str AT ROW 7.67 COL 12 COLON-ALIGNED WIDGET-ID 16
     BUTTON-sel-fuel AT ROW 7.67 COL 30 WIDGET-ID 18
     card-code-str AT ROW 7.67 COL 49 COLON-ALIGNED WIDGET-ID 4
     BUTTON-sel-car AT ROW 7.67 COL 72 WIDGET-ID 6
     SPACE(2.19) SKIP(0.89)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


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
       card-code-str:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fuel-code-str:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.cd-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:       
    assign frame {&frame-name}
        num
        ts-date
        fuel-code-str
        card-code-str
        permitted-filling
    .
    
    if ts-date = ? then do:
        message "Дата не указана" view-as alert-box.
        return no-apply.
    end.
    
    run update-or-create-travel-sheet(
          input-output p-recid
        , num
        , ts-date
        , permitted-filling
        , integer(fuel-code-str)
        , card-code-str
        , ?
    ) no-error.
    
    if error-status:ERROR then do:
        message return-value view-as alert-box.
        return no-apply.
    end.
    else do:
        p-result = true.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-sel-car
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-sel-car Dialog-Frame
ON CHOOSE OF BUTTON-sel-car IN FRAME Dialog-Frame
DO:
    def var rid-list as char no-undo.
    
    { gbl/getcntxt.i get }
    
    run ref/discards.w (
                 input parparentproc
                ,input "b-sel":U
                ,input {&all}
                ,input v-cntxt-host-code-obj
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input '':U
                ,input ?
                ,output rid-list ) no-error.
                
    if num-entries(rid-list) <> 1 then return.
    
    find first ub.dis-card no-lock
        where recid(ub.dis-card) = integer(rid-list).
    card-code-str = string(ub.dis-card.d-card).
    
    disp card-code-str
        with frame {&frame-name}.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-sel-fuel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-sel-fuel Dialog-Frame
ON CHOOSE OF BUTTON-sel-fuel IN FRAME Dialog-Frame
DO:  
  def var rid-list as char no-undo. /* recid для выбранных товаров */
  
  run ref/petrlref.p ( parParentProc, "b-sel", output rid-list) no-error.
  if num-entries(rid-list) <> 1 then return.
  
  find first ub.goods no-lock
    where recid(ub.goods) = integer(rid-list).
  fuel-code-str = string(ub.goods.gds-code).
  
  disp fuel-code-str
    with frame {&frame-name}.
  
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
       
  { gbl/ed_date.i ts-date }
       
  run my-init no-error.
  if error-status:ERROR then do:
      message return-value view-as alert-box.
      p-result = false.
  end.
  else do:
      RUN enable_UI.
      WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS num.
  end.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY num ts-date permitted-filling fuel-code-str card-code-str 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel num ts-date permitted-filling fuel-code-str 
         BUTTON-sel-fuel card-code-str BUTTON-sel-car 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-init Dialog-Frame 
PROCEDURE my-init :
frame {&frame-name}:TITLE = (if p-mode = {&add-def} then "Добавить" else "Изменить") + " ПЛ".
        
    if p-mode <> {&add-def} and p-mode <> {&update} then
        return error "Параметр p-mode может быть только одним из &add-def или &update".
    
    if p-mode = {&update} then do:
        find first ub.cd-doc no-lock
            where recid(ub.cd-doc) = p-recid no-error.
        if not avail ub.cd-doc then
            return error "Запись с recid = " + string(p-recid) + " не найдена".
        
        if ub.cd-doc.doc-type <> {&travel-sheet} then
            return error "Запись с recid = " + string(p-recid) + " ; № ПЛ = " + ub.cd-doc.CharKey_One + " не является путевым листом".
        
        if ub.cd-doc.Key#_One = 1 then
            return error "Нельзя редактировать закрытый документ".
        
        assign
            num                 = ub.cd-doc.CharKey_One
            ts-date             = ub.cd-doc.datekey_one
            permitted-filling   = ub.cd-doc.DecKey_One
            fuel-code-str       = string(ub.cd-doc.Key#_Two)
            card-code-str       = ub.cd-doc.CharKey_Two
        .
        disp
            num
            ts-date
            permitted-filling
            fuel-code-str
            card-code-str
            with frame {&frame-name}.
    end.
    
    num:SENSITIVE = true.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

