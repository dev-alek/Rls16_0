&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр истории по таблицам

Автор: Ростовцев Александр
Дата создания: 16/04/2026
Author: 
Creation date:


------------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр истории по таблицам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ gbl/getcntxt.i def }
/* Local Variable Definitions ---                                       */

&scoped-define FILE_TABLES "cmp\history.txt"

define temp-table ttHistory no-undo
  field fTable as character label "Таблица" format "X(15)"
  field fName  as character label "Наименование объекта" format "X(30)"
  field fProc  as character label "Процедура просмотра"
  field fLabel as character
  field fField as character
  field fType  as character
.

define stream inStr.
define variable mMode as character no-undo.
define variable mIdList as character no-undo.

&scoped-define PARAMS parparentproc,v-cntxt-host-code-obj,v-cntxt-obj-type,v-cntxt-obj-code,'',mMode,?,'','',sys-ctrl.db-num,?,input-output mIdList

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-tables

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttHistory

/* Definitions for BROWSE BROWSE-tables                                 */
&Scoped-define FIELDS-IN-QUERY-BROWSE-tables ttHistory.fTable ttHistory.fName   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-tables   
&Scoped-define SELF-NAME BROWSE-tables
&Scoped-define QUERY-STRING-BROWSE-tables FOR EACH ttHistory by ttHistory.fTable
&Scoped-define OPEN-QUERY-BROWSE-tables OPEN QUERY {&SELF-NAME} FOR EACH ttHistory by ttHistory.fTable.
&Scoped-define TABLES-IN-QUERY-BROWSE-tables ttHistory
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-tables ttHistory


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-tables}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-view BROWSE-tables 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-view 
       MENU-ITEM m_one          LABEL "По одному объекту"
       MENU-ITEM m_all          LABEL "По всем объектам".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit 
     LABEL "Выход" 
     SIZE 15 BY 1.14.

DEFINE BUTTON b-view 
     LABEL "Просмотр" 
     SIZE 15 BY 1.14.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-tables FOR 
      ttHistory SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-tables
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-tables Dialog-Frame _FREEFORM
  QUERY BROWSE-tables DISPLAY
      ttHistory.fTable
      ttHistory.fName
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84 BY 15.24 ROW-HEIGHT-CHARS .76 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.48 COL 3 WIDGET-ID 2
     b-view AT ROW 1.48 COL 20 WIDGET-ID 4
     BROWSE-tables AT ROW 3.14 COL 3 WIDGET-ID 200
     SPACE(1.59) SKIP(0.94)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История изменений"
         CANCEL-BUTTON b-exit WIDGET-ID 100.


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
/* BROWSE-TAB BROWSE-tables b-view Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.

ASSIGN 
       b-view:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-view:HANDLE.
ASSIGN 
   b-view:MENU-MOUSE = 1.
   
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-tables
/* Query rebuild information for BROWSE BROWSE-tables
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttHistory by ttHistory.fTable.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-tables */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История изменений */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-tables
&Scoped-define SELF-NAME BROWSE-tables
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-tables Dialog-Frame
ON RETURN OF BROWSE-tables IN FRAME Dialog-Frame
DO:
  apply "choose":U to b-view in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* По всем объектам */
DO:
  if not avail ttHistory then
    return no-apply.

  if ttHistory.fProc = "" then 
  do:
    message "В настройках просмотра истории не задана процедура просмотра истории." skip
            "Обратитесь к разработчикам." view-as alert-box.
    return no-apply.
  end.
  
  if ttHistory.fField = "" then
    run getIdent in this-procedure (ttHistory.fTable). 

  mMode = {&all}.
  run runHistoryProc in this-procedure("", ttHistory.fProc ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* По одному объекту */
DO:
  define variable vIdent  as character no-undo.
  
  if not avail ttHistory then
    return no-apply.
    
  if ttHistory.fProc = "" then 
  do:
    message "В настройках просмотра истории не задана процедура просмотра истории по одному объекту." skip
            "Обратитесь к разработчикам." view-as alert-box.
    return no-apply.
  end.
  
  if ttHistory.fField = "" then
    run getIdent in this-procedure (ttHistory.fTable). 
    
/*  message ttHistory.fField skip*/
/*          ttHistory.fLabel skip*/
/*          ttHistory.fType      */
/*  view-as alert-box.           */
  
  run str/histparam.w (ttHistory.fLabel, ttHistory.fType, output vIdent).

/*  message vIdent view-as alert-box. */
  if vIdent = "" then
    return no-apply.
  mMode = "one".
  run runHistoryProc in this-procedure(vIdent, ttHistory.fProc).
  
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

  run getTables in this-procedure no-error.
  if error-status:error then return.

  find first sys-ctrl no-lock.
  { gbl/getcntxt.i get }

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
  ENABLE b-exit b-view BROWSE-tables 
      WITH FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getIdent Dialog-Frame 
PROCEDURE getIdent :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter iTable as character no-undo.  
  
  define buffer buf_ttHistory for ttHistory.
  define buffer buf_file  for ub._File.
  define buffer buf_field for ub._Field.
  define buffer buf_index for ub._Index.
  define buffer buf_index-field for ub._Index-Field.
  define variable vComma as character no-undo.  
  
  find first buf_ttHistory where buf_ttHistory.fTable = iTable.
  
  for first buf_file no-lock where
          buf_file._file-name = iTable
     ,first buf_index no-lock where
            recid(buf_index) = buf_file._prime-index
     ,each  buf_index-field no-lock where
            buf_index-field._Index-recid = recid(buf_index)
     ,first buf_field no-lock where
            recid(buf_field) = buf_index-field._Field-recid
  : 
    assign
      vComma = if buf_ttHistory.fField = "" then "" else ","
      buf_ttHistory.fField = substitute("&1&2&3", buf_ttHistory.fField, vComma, buf_field._Field-name)
      buf_ttHistory.fType  = substitute("&1&2&3", buf_ttHistory.fType, vComma, buf_field._Data-type)
      buf_ttHistory.fLabel  = substitute(
        "&1&2&3", buf_ttHistory.fLabel, 
        vComma, 
        if buf_field._Label <> "" and buf_field._Label <> ? then buf_field._Label else buf_field._Field-name
      )
    . 
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTables Dialog-Frame 
PROCEDURE getTables :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define variable vTable as character no-undo.
define variable vName  as character no-undo.
define variable vProc  as character no-undo.

if search({&FILE_TABLES}) = ? then
do:
  message substitute("Не найден файл настроек &1.",{&FILE_TABLES}) view-as alert-box.
  return error.
end.


input stream inStr from value(search({&FILE_TABLES})).
READ_FILE:
repeat:
  import stream inStr vTable vName vProc.
  if vTable begins "//" then next READ_FILE.
  create ttHistory.
  assign
    ttHistory.fTable    = vTable
    ttHistory.fName     = vName
    ttHistory.fProc     = vProc
  .
end.
input stream inStr close.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE runHistoryProc Dialog-Frame 
PROCEDURE runHistoryProc :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter pIdent as character no-undo.
  define input parameter pProc  as character no-undo.

  case ttHistory.fType:
    when "character" then do:
/*      vIdent = '0104606532014339215iEdGpjf"K?qB'.*/
      run value(pProc) (
        if pIdent <> "" then pIdent else ?,
        {&PARAMS}
      ).
    end.
    when "character,character" then do:
      run value(pProc) (
        if pIdent <> "" then entry(1,pIdent) else ?,
        if pIdent <> "" then entry(2,pIdent) else ?,
        {&PARAMS}
      ).
    end.
    when "integer,integer" then do:
      run value(pProc) (
        if pIdent <> "" then int(entry(1,pIdent)) else ?,
        if pIdent <> "" then int(entry(2,pIdent)) else ?,
        {&PARAMS}
      ).
    end.
    when "int64" then do:
      run value(pProc) (
        if pIdent <> "" then int64(pIdent) else ?,
        {&PARAMS}
      ).
    end.
    when "integer" then do:
      run value(pProc) (
        if pIdent <> "" then int(pIdent) else ?,
        {&PARAMS}
      ).
    end.
    otherwise do:
      message
        substitute("Для входных параметров типа &1 необходимо доработать вызов просмотра истории.", ttHistory.fType)
        view-as alert-box.
    end.
  end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

