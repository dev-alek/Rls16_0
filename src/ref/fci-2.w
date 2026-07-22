&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_fin-code FOR ub.fin-code-cel-nazn.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка справочника в ФИНБлоке цел.назн

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 12/03/03 5:57

*/
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Корректировка справочника в ФИНБлоке цел.назн    ".
{ cmp/vssrevis.i }
define input parameter        ref-mode as character no-undo .
define input-output parameter ri       as recid no-undo.
define input parameter par-host-code as integer no-undo .
/* Local Variable Definitions ---                                       */
define variable tcode as character no-undo .
define variable p-fin-code as integer no-undo .
{ cmp/trg-def.i }
{ cmp/showinf.i  }
{ gbl/cur-time.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES fin-code-cel-nazn buf_fin-code

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame fin-code-cel-nazn.code-value ~
fin-code-cel-nazn.descr fin-code-cel-nazn.level-1 fin-code-cel-nazn.level-2 ~
fin-code-cel-nazn.level-3 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
fin-code-cel-nazn.code-value fin-code-cel-nazn.descr ~
fin-code-cel-nazn.level-1 fin-code-cel-nazn.level-2 ~
fin-code-cel-nazn.level-3 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame fin-code-cel-nazn
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame fin-code-cel-nazn
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH fin-code-cel-nazn SHARE-LOCK, ~
      EACH buf_fin-code WHERE TRUE /* Join to fin-code-cel-nazn incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH fin-code-cel-nazn SHARE-LOCK, ~
      EACH buf_fin-code WHERE TRUE /* Join to fin-code-cel-nazn incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame fin-code-cel-nazn buf_fin-code
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame fin-code-cel-nazn
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame buf_fin-code


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS fin-code-cel-nazn.code-value ~
fin-code-cel-nazn.descr fin-code-cel-nazn.level-1 fin-code-cel-nazn.level-2 ~
fin-code-cel-nazn.level-3 
&Scoped-define ENABLED-TABLES fin-code-cel-nazn
&Scoped-define FIRST-ENABLED-TABLE fin-code-cel-nazn
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help RECT-1 FILL-IN-1 
&Scoped-Define DISPLAYED-FIELDS fin-code-cel-nazn.code-value ~
fin-code-cel-nazn.descr fin-code-cel-nazn.level-1 fin-code-cel-nazn.level-2 ~
fin-code-cel-nazn.level-3 
&Scoped-define DISPLAYED-TABLES fin-code-cel-nazn
&Scoped-define FIRST-DISPLAYED-TABLE fin-code-cel-nazn
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод " 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Уровни для сбора аналитики" 
      VIEW-AS TEXT 
     SIZE 27.2 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 68.8 BY 2.52.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      fin-code-cel-nazn, 
      buf_fin-code SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 62.2
     fin-code-cel-nazn.code-value AT ROW 2.43 COL 7 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN 
          SIZE 13 BY 1 TOOLTIP "Код спрпавочника"
     fin-code-cel-nazn.descr AT ROW 5.29 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 69.8 BY 1
     fin-code-cel-nazn.level-1 AT ROW 7.76 COL 11.2 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     fin-code-cel-nazn.level-2 AT ROW 7.76 COL 35.6 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     fin-code-cel-nazn.level-3 AT ROW 7.76 COL 59 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     FILL-IN-1 AT ROW 6.71 COL 20.6 COLON-ALIGNED NO-LABEL
     "Наименование" VIEW-AS TEXT
          SIZE 16 BY .62 AT ROW 4.33 COL 1 WIDGET-ID 2
     RECT-1 AT ROW 6.81 COL 1
     SPACE(2.45) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Корректировка справочника"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_fin-code B "?" ? ub ub.fin-code-cel-nazn
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fin-code-cel-nazn.code-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN fin-code-cel-nazn.descr IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.fin-code-cel-nazn,Temp-Tables.buf_fin-code WHERE ub.fin-code-cel-nazn ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Корректировка справочника */
DO:
  def var rr as recid no-undo.
  if input ub.fin-code-cel-nazn.code-value = "" then do:
      message "Код  не может быть не задан" view-as alert-box.
      apply "ENTRY":U to ub.fin-code-cel-nazn.code-value.
      return no-apply.
  end.
  if  input ub.fin-code-cel-nazn.descr = ""  then do:
      message "Введите наименование " view-as alert-box WARNING.
      apply "ENTRY":U to ub.fin-code-cel-nazn.descr.
      return no-apply.
  end.
  rr = recid( ub.fin-code-cel-nazn ).

  if ref-mode =  {&add-def} then do:
    if can-find(first ub.fin-code-cel-nazn where ub.fin-code-cel-nazn.code-value = input ub.fin-code-cel-nazn.code-value
                                       AND recid( ub.fin-code-cel-nazn ) <> rr
                                       and ub.fin-code-cel-nazn.host-code = par-host-code
                                         ) then do:
        message "Запись с кодом" input ub.fin-code-cel-nazn.code-value "уже существует!" skip
              "Если ее нет в списке, то она логически удалена."
              view-as alert-box warning.
        apply "ENTRY":U to ub.fin-code-cel-nazn.code-value.
        return no-apply.
    end.
  end.
  /* Запишем с экрана */
    if ref-mode <> {&lookup} then
  assign ub.fin-code-cel-nazn.code-value
         ub.fin-code-cel-nazn.descr
         ub.fin-code-cel-nazn.level-1
         ub.fin-code-cel-nazn.level-2
         ub.fin-code-cel-nazn.level-3
         ri = recid( ub.fin-code-cel-nazn )
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Корректировка справочника */
DO:
apply "CHOOSE" to b-quit IN FRAME {&frame-name} .
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
    ri = ? .
  if ref-mode =  {&add-def} then do:
      find current ub.fin-code-cel-nazn  exclusive-lock   no-error.
      if available ub.fin-code-cel-nazn then do:
         delete ub.fin-code-cel-nazn.
      end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */
{ ref/crfincd.i  ub.fin-code-cel-nazn }
{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if ref-mode =  {&add-def}
        then  do:
            ri = ?.
            run fin-code in this-procedure (input par-host-code , output p-fin-code) .
            tcode = string(p-fin-code) .
            run create-ref-fin-code in this-procedure (
                input no ,
                input par-host-code ,
                input p-fin-code    ,
                input tcode ,
                input ""    ,
                input 0 ,
                input 0 ,
                input 0 ,
                input 0 ).
        end.
        else  do:
         find ub.fin-code-cel-nazn where recid( ub.fin-code-cel-nazn ) = ri no-error .
         if error-status :error then return  error .
         end.

frame {&frame-name}:title = frame {&frame-name}:title + "  - " + caps(ref-mode).
b-quit:label = (if  ref-mode = {&lookup} then "&Выход" else b-quit:label ).

    session:data-entry-return = yes .
     if ref-mode = {&lookup} then do:
        run myenable_UI in this-procedure.
        WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS b-quit.
     end.
     else do:

    run enable_UI in this-procedure.
    if ref-mode = {&add-def}
        then  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS ub.fin-code-cel-nazn.code-value .
        else  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS ub.fin-code-cel-nazn.descr .
    end.
END.
run disable_UI in this-procedure.

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
  DISPLAY FILL-IN-1 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE fin-code-cel-nazn THEN 
    DISPLAY fin-code-cel-nazn.code-value fin-code-cel-nazn.descr 
          fin-code-cel-nazn.level-1 fin-code-cel-nazn.level-2 
          fin-code-cel-nazn.level-3 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help RECT-1 fin-code-cel-nazn.code-value 
         fin-code-cel-nazn.descr fin-code-cel-nazn.level-1 
         fin-code-cel-nazn.level-2 fin-code-cel-nazn.level-3 FILL-IN-1 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable_UI Dialog-Frame 
PROCEDURE myenable_UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  IF AVAILABLE ub.fin-code-cel-nazn THEN
    DISPLAY ub.fin-code-cel-nazn.code-value ub.fin-code-cel-nazn.descr FILL-IN-1
          ub.fin-code-cel-nazn.level-1 ub.fin-code-cel-nazn.level-2
          ub.fin-code-cel-nazn.level-3

      WITH FRAME Dialog-Frame.
     enable b-quit b-help
      WITH FRAME Dialog-Frame.

  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

