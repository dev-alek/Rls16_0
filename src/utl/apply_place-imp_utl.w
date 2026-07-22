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

/* Parameters Definitions ---                                           */

define input        parameter parparentproc as handle    no-undo .

/* Local Variable Definitions ---                                       */
define variable v-pl-code as integer no-undo .
define variable pl-recid-list as character no-undo .

define buffer buf_user-login        for ub.user-login .

{ cmp/trg-def.i       }
{ gbl/getcntxt.i def  }
{ gbl/getcntxt.i get  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-place-imp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES place-imp

/* Definitions for BROWSE br-place-imp                                  */
&Scoped-define FIELDS-IN-QUERY-br-place-imp place-imp.table-version ~
place-imp.corr-date place-imp.corr-time 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-place-imp 
&Scoped-define QUERY-STRING-br-place-imp FOR EACH place-imp ~
      WHERE place-imp.status_ = 0 ~
and place-imp.obj-type = v-cntxt-obj-type ~
and place-imp.obj-code = v-cntxt-obj-code ~
and place-imp.pl-code = v-pl-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-place-imp OPEN QUERY br-place-imp FOR EACH place-imp ~
      WHERE place-imp.status_ = 0 ~
and place-imp.obj-type = v-cntxt-obj-type ~
and place-imp.obj-code = v-cntxt-obj-code ~
and place-imp.pl-code = v-pl-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-place-imp place-imp
&Scoped-define FIRST-TABLE-IN-QUERY-br-place-imp place-imp


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-place-imp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel Btn_OK f-pl-num b-place ~
br-place-imp 
&Scoped-Define DISPLAYED-OBJECTS f-pl-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-place 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-place" 
     SIZE 3 BY .86.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK 
     LABEL "Применить" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE f-pl-num AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-place-imp FOR 
      place-imp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-place-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-place-imp Dialog-Frame _STRUCTURED
  QUERY br-place-imp NO-LOCK DISPLAY
      place-imp.table-version column-label "Номер версии" FORMAT ">>>>>>>>>9":U 
      place-imp.corr-date column-label 'Дата получения статуса!"Ожидает применения"' FORMAT "99/99/9999":U
      string(place-imp.corr-time, "hh:mm:ss") column-label 'Время получения статуса!"Ожидает применения"' FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 75 BY 6.19 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1.24 COL 2
     Btn_OK AT ROW 1.24 COL 17
     f-pl-num AT ROW 3.3 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     b-place AT ROW 3.3 COL 18.4 WIDGET-ID 38
     br-place-imp AT ROW 4.9 COL 3 WIDGET-ID 200
     "Выбор резервуара:" VIEW-AS TEXT
          SIZE 20 BY .86 AT ROW 2.38 COL 2 WIDGET-ID 2
     SPACE(56.99) SKIP(7.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Утилита применения новых градуировочных таблиц"
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
/* BROWSE-TAB br-place-imp b-place Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       f-pl-num:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-place-imp
/* Query rebuild information for BROWSE br-place-imp
     _TblList          = "ub.place-imp"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "place-imp.status_ = 0
and place-imp.obj-type = v-cntxt-obj-type
and place-imp.obj-code = v-cntxt-obj-code
and place-imp.pl-code = v-pl-code"
     _FldNameList[1]   = ub.place-imp.table-version
     _FldNameList[2]   = ub.place-imp.corr-date
     _FldNameList[3]   = ub.place-imp.corr-time
     _Query            is OPENED
*/  /* BROWSE br-place-imp */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Утилита применения новых градуировочных таблиц */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-place Dialog-Frame
ON CHOOSE OF b-place IN FRAME Dialog-Frame /* b-place */
DO:
  define buffer buf_place for ub.place .
    
  run ref/pl-list.w (
     input parparentproc
    ,input "b-sel"
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input {&g___object}
    ,input-output pl-recid-list).
  if pl-recid-list = "cancel"
  then do :
    return no-apply .
  end .
  
  find first buf_place no-lock where recid(buf_place) = integer(pl-recid-list) no-error .
  if available buf_place
  then do :
    assign
      v-pl-code = buf_place.pl-code
      f-pl-num = buf_place.loc1  
    .
    display f-pl-num with frame {&frame-name} .
  end .
  else do :
    assign
      v-pl-code = ?
      f-pl-num = "?"
    .
    display f-pl-num with frame {&frame-name} .
  end .
  
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Применить */
DO:
  define buffer buf_place-imp for ub.place-imp .
  define buffer buf_place-attr for ub.place-attr .
  if available place-imp
  then do :
    for each buf_place-imp no-lock where buf_place-imp.obj-type = v-cntxt-obj-type
                                     and buf_place-imp.obj-code = v-cntxt-obj-code
                                     and buf_place-imp.pl-code  = v-pl-code
                                     and buf_place-imp.status_  = 0
                                     by buf_place-imp.table-version
    :
      run str/apply_place-imp.p (input buf_place-imp.obj-type,
                                 input buf_place-imp.obj-code,
                                 input buf_place-imp.pl-code,
                                 input buf_place-imp.table-version)
                                 no-error .
    end .
    find first buf_place-attr exclusive-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                               and buf_place-attr.obj-code = v-cntxt-obj-code
                                               and buf_place-attr.pl-code  = v-pl-code
                                               and buf_place-attr.attr-code = "pending-table-version"
                                               no-error .
    if available buf_place-attr
    then do :
      delete buf_place-attr .
    end .
    
    message "Новые данные успешно применены!" view-as alert-box .
    
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define BROWSE-NAME br-place-imp
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
  find first buf_user-login no-lock
      where buf_user-login.db-num  = g#db-num
        and buf_user-login.user-id = g#userid
      no-error .
  if not available buf_user-login
  then do :
    message "Неизвестный пользователь!" view-as alert-box error .
    return .
  end .
  if not buf_user-login.user-administrator
  then do :
    message "Данный функционал доступен только для администратора!" view-as alert-box .
    return .
  end .
  
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
  DISPLAY f-pl-num 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_OK f-pl-num b-place br-place-imp 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

