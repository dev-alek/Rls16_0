&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME gDialog
{adecomm/appserv.i}
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
{ utl/tt-test-1c.i new}


/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .

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
&Scoped-Define ENABLED-OBJECTS RECT-3 b-start b-close T-1 T-2 T-3 T-4 T-5 ~
T-6 T-7 T-9 T-10 T-8 
&Scoped-Define DISPLAYED-OBJECTS T-1 T-2 T-3 T-4 T-5 T-6 T-7 T-9 T-10 T-8 

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

DEFINE BUTTON b-start 
     LABEL "Запустить" 
     SIZE 15 BY 1.13.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 54 BY 11.75.

DEFINE VARIABLE T-1 AS LOGICAL INITIAL no 
     LABEL "Документа (накл., инв., перес.)" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE T-2 AS LOGICAL INITIAL no 
     LABEL "Смены" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE T-3 AS LOGICAL INITIAL no 
     LABEL "Сверки" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE T-4 AS LOGICAL INITIAL no 
     LABEL "Переоценки" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE T-5 AS LOGICAL INITIAL no 
     LABEL "Фин.документа" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE T-6 AS LOGICAL INITIAL no 
     LABEL "Документа производства" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE T-7 AS LOGICAL INITIAL no 
     LABEL "Документа электронного документооборота" 
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-8 AS LOGICAL INITIAL no 
     LABEL "Общая выгрузка" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE T-9 AS LOGICAL INITIAL no 
     LABEL "Текущая топология" 
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-10 AS LOGICAL INITIAL no 
     LABEL "Контрольная плотность НП" 
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY .83 NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME gDialog
     b-start AT ROW 1.25 COL 2 WIDGET-ID 8
     b-close AT ROW 1.25 COL 42
     T-1 AT ROW 4 COL 13.5 WIDGET-ID 54
     T-2 AT ROW 5 COL 13.5 WIDGET-ID 56
     T-3 AT ROW 6 COL 13.5 WIDGET-ID 58
     T-4 AT ROW 7 COL 13.5 WIDGET-ID 60
     T-5 AT ROW 8 COL 13.5 WIDGET-ID 62
     T-6 AT ROW 9 COL 13.5 WIDGET-ID 64
     T-7 AT ROW 10 COL 13.5 WIDGET-ID 68
     T-9 AT ROW 11 COL 13.5 WIDGET-ID 70
     T-10 AT ROW 12 COL 13.5 WIDGET-ID 70
     T-8 AT ROW 13 COL 13.5 WIDGET-ID 66
     "Выгрузка:" VIEW-AS TEXT
          SIZE 9.5 BY .67 AT ROW 3 COL 4.5 WIDGET-ID 52
     RECT-3 AT ROW 3.25 COL 3 WIDGET-ID 50
     SPACE(2.12) SKIP(1.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Повторная выгрузка данных для 1С ERP"
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
       FRAME gDialog:SCROLLABLE       = FALSE
       FRAME gDialog:HIDDEN           = TRUE.

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
ON WINDOW-CLOSE OF FRAME gDialog /* Повторная выгрузка данных для 1С ERP */
DO:  
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start gDialog
ON CHOOSE OF b-start IN FRAME gDialog /* Запустить */
DO:
  ASSIGN 
  t-1
  t-2
  t-3
  t-4
  t-5
  t-6
  t-7
  t-8
  t-9
  t-10
    .
    
if t-1 then do:
run  utl/send1c.p.
end.  

if t-2 then do:
  run utl/send2c.p (parparentproc).
end.  

if t-3 then do:
  run utl/send3c.p.
end.  

if t-4 then do:
  run utl/send4c.p.
end.  

if t-5 then do:
  run utl/send5c.p.
end.  

if t-6 then do:
  run utl/send6c.p.
end.  

if t-7 then do:
  run utl/send7c.p.
end.

if t-9 then do:
  run utl/send9c.p.
end.

if t-10 then do:
  run utl/send10c.p .
end.

if t-8 then do:
  run utl/all-send1c.p (parparentproc).
end.  

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-1 gDialog
ON VALUE-CHANGED OF T-1 IN FRAME gDialog /* Документа (накл., инв., перес.) */
DO:
  assign
  t-1
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-2 gDialog
ON VALUE-CHANGED OF T-2 IN FRAME gDialog /* Смены */
DO:
  assign
  t-2
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-3 gDialog
ON VALUE-CHANGED OF T-3 IN FRAME gDialog /* Сверки */
DO:
  assign
  t-3
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-4 gDialog
ON VALUE-CHANGED OF T-4 IN FRAME gDialog /* Переоценки */
DO:
  assign
  t-4
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-5 gDialog
ON VALUE-CHANGED OF T-5 IN FRAME gDialog /* Фин.документа */
DO:
  assign
  t-5
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-6 gDialog
ON VALUE-CHANGED OF T-6 IN FRAME gDialog /* Документа производства */
DO:
  assign
  t-6
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-7 gDialog
ON VALUE-CHANGED OF T-7 IN FRAME gDialog /* Документа электронного документооборота */
DO:
  assign
  t-7
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-8 gDialog
ON VALUE-CHANGED OF T-8 IN FRAME gDialog /* Общая выгрузка */
DO:
  assign
  t-8
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-9
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-9 gDialog
ON VALUE-CHANGED OF T-9 IN FRAME gDialog /* Текущая топология */
DO:
  assign
  t-9
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-10
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-10 gDialog
ON VALUE-CHANGED OF T-10 IN FRAME gDialog /* Текущая топология */
DO:
  assign
  t-10
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK gDialog 


/* ***************************  Main Block  *************************** */
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
  DISPLAY T-1 T-2 T-3 T-4 T-5 T-6 T-7 T-9 T-10 T-8 
      WITH FRAME gDialog.
  ENABLE RECT-3 b-start b-close T-1 T-2 T-3 T-4 T-5 T-6 T-7 T-9 T-10 T-8 
      WITH FRAME gDialog.
  VIEW FRAME gDialog.
  {&OPEN-BROWSERS-IN-QUERY-gDialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

