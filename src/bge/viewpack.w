&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
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

Повторная отправка сообщений из пакета

Автор: Ростовцев Александр
Дата создания: 09/07/2025
Author: Aleksandr Rostovtsev
Creation date: 09/07/2025

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*define input  parameter parparentproc as widget-handle  no-undo.      */
/*define input  parameter p-log-handle as handle  no-undo.              */
define input parameter iEsysId   like ub.esys-route.esys-id no-undo.
define input parameter iDbNum    like ub.esys-route.db-num no-undo.
define input parameter iTargetDb like ub.esys-pck-sent.esps-cr-db-num no-undo.
define input parameter iPackNum  like ub.esys-route.esr-last-pack no-undo.

/* Local Variable Definitions ---                                       */


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ручной режим работы OpenXML".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i  }
{ bge/oxml-def.i }
{ gbl/prn-lib.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-route

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES esys-route esys-route-dump

/* Definitions for BROWSE BROWSE-route                                  */
&Scoped-define FIELDS-IN-QUERY-BROWSE-route esys-route-dump.esrd-action ~
esys-route-dump.esrd-dump-name esys-route-dump.esrd-dump-ord ~
esys-route-dump.esrd-uniq-key-rec 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-route ~
esys-route-dump.esrd-dump-name esys-route-dump.esrd-uniq-key-rec 
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-route esys-route-dump
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-route esys-route-dump
&Scoped-define QUERY-STRING-BROWSE-route FOR EACH esys-route ~
      WHERE esys-route.esys-id = iEsysId and  ~
esys-route.db-num  = iDbNum and esys-route.esr-last-pack = iPackNum NO-LOCK, ~
      EACH esys-route-dump WHERE esys-route-dump.esrd-dump-ord ~
  = esys-route.esr-dump-ord NO-LOCK ~
    BY esys-route.esr-dump-ord INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-route OPEN QUERY BROWSE-route FOR EACH esys-route ~
      WHERE esys-route.esys-id = iEsysId and  ~
esys-route.db-num  = iDbNum and esys-route.esr-last-pack = iPackNum NO-LOCK, ~
      EACH esys-route-dump WHERE esys-route-dump.esrd-dump-ord ~
  = esys-route.esr-dump-ord NO-LOCK ~
    BY esys-route.esr-dump-ord INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-route esys-route esys-route-dump
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-route esys-route
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-route esys-route-dump


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-route}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS bView BROWSE-route 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON bView 
     LABEL "Просмотр" 
     SIZE 15 BY 1.14.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-route FOR 
      esys-route, 
      esys-route-dump SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-route
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-route Dialog-Frame _STRUCTURED
  QUERY BROWSE-route NO-LOCK DISPLAY
      esys-route-dump.esrd-action FORMAT "X(15)":U WIDTH 12.2
      esys-route-dump.esrd-dump-name COLUMN-LABEL "Сообщение" FORMAT "X(20)":U
            WIDTH 14.2
      esys-route-dump.esrd-dump-ord COLUMN-LABEL "Уник. код выгрузки" FORMAT "->>>>>>>>>>>>>>>>>>9":U
            WIDTH 21.2
      esys-route-dump.esrd-uniq-key-rec COLUMN-LABEL "Ключ записи" FORMAT "X(30)":U
            WIDTH 26.4
  ENABLE
      esys-route-dump.esrd-dump-name
      esys-route-dump.esrd-uniq-key-rec
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 81 BY 15 ROW-HEIGHT-CHARS .62 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     bView AT ROW 1.24 COL 68.6 WIDGET-ID 4
     BROWSE-route AT ROW 2.67 COL 3 WIDGET-ID 200
     SPACE(2.19) SKIP(0.51)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Список сообщений" WIDGET-ID 100.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-route bView Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-route
/* Query rebuild information for BROWSE BROWSE-route
     _TblList          = "ub.esys-route,ub.esys-route-dump WHERE ub.esys-route ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "ub.esys-route.esr-dump-ord|yes"
     _Where[1]         = "esys-route.esys-id = iEsysId and 
esys-route.db-num  = iDbNum and esys-route.esr-last-pack = iPackNum"
     _JoinCode[2]      = "esys-route-dump.esrd-dump-ord
  = esys-route.esr-dump-ord"
     _FldNameList[1]   > ub.esys-route-dump.esrd-action
"esys-route-dump.esrd-action" ? ? "character" ? ? ? ? ? ? no ? no no "12.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.esys-route-dump.esrd-dump-name
"esys-route-dump.esrd-dump-name" "Сообщение" ? "character" ? ? ? ? ? ? yes ? no no "14.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.esys-route-dump.esrd-dump-ord
"esys-route-dump.esrd-dump-ord" "Уник. код выгрузки" ? "int64" ? ? ? ? ? ? no ? no no "21.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > ub.esys-route-dump.esrd-uniq-key-rec
"esys-route-dump.esrd-uniq-key-rec" "Ключ записи" "X(30)" "character" ? ? ? ? ? ? yes ? no no "26.4" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-route */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список сообщений */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bView
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bView Dialog-Frame
ON CHOOSE OF bView IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable vFile   as character no-undo.
  define variable vViewer as character no-undo.
 
  if esys-route-dump.esrd-blob-value-rec <> ? then
  do:
    vViewer = search("exe\ibsview.exe").
    if vViewer = ? then
    do:
      message "Не найден просмотрщик файлов ibsview.exe" view-as alert-box.
      return no-apply.
    end.
  
    vFile = substitute("&1mess&2.xml", session:temp-directory, esys-route-dump.esrd-dump-ord).
    
    copy-lob from esys-route-dump.esrd-blob-value-rec to file vFile no-error.
    if error-status:error then
      message "Файл занят" view-as alert-box.
    else
      os-command no-wait value(vViewer + " " + vFile).
    /*
    run prn-lib-reportviewer-report-name in this-procedure (
      input THIS-PROCEDURE
      ,input vFile
    ).
    */

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-route
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
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
run deleteFiles in this-procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE deleteFiles Dialog-Frame 
PROCEDURE deleteFiles :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cFileShort AS CHARACTER NO-UNDO .
DEFINE VARIABLE cFileLong  AS CHARACTER NO-UNDO.
DEFINE VARIABLE cType      AS CHARACTER NO-UNDO.

input from os-dir(session:temp-directory).
repeat:
  IMPORT cFileShort cFileLong cType . 

  IF cType MATCHES "*F*" and cFileShort begins "mess" THEN 
  DO:
    os-delete value(cFileLong).
  end. 
end.
input close.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  ENABLE bView BROWSE-route 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

