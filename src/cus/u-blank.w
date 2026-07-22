&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Бланк заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06


*/

define input parameter t-action   as character no-undo.
define input parameter x-cli-type like ub.ord-blank.cli-type no-undo.
define input parameter x-cli-code like ub.ord-blank.cli-code no-undo.
define input parameter rec-blank  as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Бланк заказа" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.ord-blank

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ub.ord-blank.blank-name ~
ord-blank.File-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ub.ord-blank.blank-name ~
ord-blank.File-name
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ub.ord-blank
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.ord-blank
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.ord-blank SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.ord-blank SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.ord-blank
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.ord-blank


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.ord-blank.blank-name ub.ord-blank.File-name
&Scoped-define ENABLED-TABLES ub.ord-blank
&Scoped-define FIRST-ENABLED-TABLE ub.ord-blank
&Scoped-Define ENABLED-OBJECTS B-OK RECT-1 B-exit B-Excel B-Help B-find
&Scoped-Define DISPLAYED-FIELDS ub.ord-blank.blank-name ub.ord-blank.File-name
&Scoped-define DISPLAYED-TABLES ub.ord-blank
&Scoped-define FIRST-DISPLAYED-TABLE ub.ord-blank


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Excel AUTO-GO
     LABEL "Excel"
     SIZE 10 BY 1 TOOLTIP "Создание или корректировка шаблона бланка"
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-find
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B-find"
     SIZE 3.13 BY 1.13 TOOLTIP "Поиск файла".

DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.38 BY 2.96.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.ord-blank SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Excel AT ROW 1 COL 21
     B-Help AT ROW 1 COL 59
     ub.ord-blank.blank-name AT ROW 2.63 COL 2.63 FORMAT "X(40)"
          VIEW-AS FILL-IN
          SIZE 52.25 BY 1
     B-find AT ROW 3.88 COL 65.25
     ub.ord-blank.File-name AT ROW 3.92 COL 1.63
          LABEL "Имя файла"
          VIEW-AS FILL-IN
          SIZE 52.25 BY 1 TOOLTIP "Полное Имя файла-шаблона Excel(*.xlt)"
     RECT-1 AT ROW 2.33 COL 1.38
     SPACE(0.23) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Бланк заказа"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-exit.


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

/* SETTINGS FOR FILL-IN ub.ord-blank.blank-name IN FRAME Dialog-Frame
   ALIGN-L EXP-FORMAT                                                   */
/* SETTINGS FOR FILL-IN ub.ord-blank.File-name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.ord-blank"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Бланк заказа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Excel Dialog-Frame
ON CHOOSE OF B-Excel IN FRAME Dialog-Frame /* Excel */
DO:
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .


  CREATE "Excel.Application" chExcelApplication.
assign
   /* chExcelApplication:Interactive = true */
   /* chExcelApplication:ScreenUpdating = true */
   chExcelApplication:Visible = TRUE
   chWorkbook = chExcelApplication:Workbooks:Open( ub.ord-blank.file-name:screen-value , TRUE , false , , ,TRUE,TRUE , TRUE, TRUE ,TRUE, TRUE, TRUE ,TRUE)
    /*Open(Filename As String, [UpdateLinks], [ReadOnly], [Format], [Password], [WriteResPassword], [IgnoreReadOnlyRecommended], [Origin], [Delimiter], [Editable], [Notify], [Converter], [AddToMru]) As Workbook
    Компонент Excel.Workbooks   */
   no-error .
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.

 return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-find
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-find Dialog-Frame
ON CHOOSE OF B-find IN FRAME Dialog-Frame /* B-find */
DO:
DEFINE VARIABLE OKpressed AS LOGICAL INITIAL TRUE no-undo.
DEFINE VARIABLE ff AS char no-undo.
if avail ub.ord-blank  then ff = ub.ord-blank.File-name.

SYSTEM-DIALOG GET-FILE ff
    TITLE      "Выберите шаблон ..."
    FILTERS    "Excel-шаблон (*.xlt)"   "*.xlt"
                 USE-FILENAME
                 UPDATE OKpressed.
                 IF OKpressed = TRUE THEN DO:
                 ub.ord-blank.File-name:screen-value in frame {&frame-name} = ff .
                 END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Ввод */
DO:
 Case t-action.
      when "add":U then DO:
      Create ub.ord-blank.
      Assign ub.ord-blank.File-name ub.ord-blank.blank-name .
      Assign
        ub.ord-blank.cli-code   = x-cli-code
        ub.ord-blank.cli-type   = x-cli-type.
      End.

      when "chg":U then DO:
        Assign ub.ord-blank.File-name ub.ord-blank.blank-name .
      End.
End case.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

 If t-action = "add":U THEN  frame {&frame-name}:TITLE = frame {&frame-name}:TITLE + " - " + {&add-def}.
 If t-action = "chg":U THEN  frame {&frame-name}:TITLE = frame {&frame-name}:TITLE + " - " + {&update}.

Case t-action.
when "add":U then DO:
      End.
when "chg":U then DO:
      find first ub.ord-blank  WHERE recid(ub.ord-blank) = rec-blank  no-error.
     End.
End.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

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
  IF AVAILABLE ub.ord-blank THEN
    DISPLAY ub.ord-blank.blank-name ub.ord-blank.File-name
      WITH FRAME Dialog-Frame.
  ENABLE B-OK RECT-1 B-exit B-Excel B-Help ub.ord-blank.blank-name B-find
         ub.ord-blank.File-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME