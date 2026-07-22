&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Анализ продаж (закладка № 2)

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Анализ продаж  ( (закладка № 2)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
def var rserv as char init "all" no-undo .
def var print-o as char init "" no-undo .

/*def input parameter Itog as logical init FALSE no-undo .*/

  { cmp/str-glbl.i }
{ cmp/r-page1.i }
  { cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-5 FILL-IN-1 FILL-IN-2 RADIO-sel ~
SumObj ShowNull TOGGLE-3 TOGGLE-1
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1 FILL-IN-2 RADIO-sel SumObj ~
ShowNull TOGGLE-3 TOGGLE-1 FILL-IN-3 TOGGLE-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE FILL-IN-1 AS DATE FORMAT "99/99/9999":U
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 11.38 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS DATE FORMAT "99/99/9999":U INITIAL 01/01/99
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.38 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5.25 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-sel AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "сумме", 1,
"кол-ву", 2
     SIZE 12.5 BY 1.75 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.25 BY 5.21.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.38 BY 8.08.

DEFINE VARIABLE ShowNull AS LOGICAL INITIAL no
     LABEL "Нулевые строки"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

DEFINE VARIABLE SumObj AS LOGICAL INITIAL no
     LABEL "Раздельно по объектам"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 17.38 BY .83 NO-UNDO.

DEFINE VARIABLE TOGGLE-2 AS LOGICAL INITIAL no
     LABEL "по группам с уровня"
     VIEW-AS TOGGLE-BOX
     SIZE 23.63 BY .83 NO-UNDO.

DEFINE VARIABLE TOGGLE-3 AS LOGICAL INITIAL no
     LABEL "C учетом возвратов"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     FILL-IN-1 AT ROW 2.75 COL 4.38 COLON-ALIGNED
     FILL-IN-2 AT ROW 2.75 COL 20.5 COLON-ALIGNED
     RADIO-sel AT ROW 4.25 COL 16.88 NO-LABEL
     SumObj AT ROW 8 COL 3
     ShowNull AT ROW 9 COL 3
     TOGGLE-3 AT ROW 10 COL 3
     TOGGLE-1 AT ROW 11 COL 3
     FILL-IN-3 AT ROW 11.92 COL 25.75 COLON-ALIGNED NO-LABEL
     TOGGLE-2 AT ROW 12 COL 2.88
     "сравнить по:" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 4.75 COL 3.5
          FGCOLOR 4
     "Просмотр :" VIEW-AS TEXT
          SIZE 26.88 BY 1 AT ROW 6.83 COL 3.13
          FGCOLOR 4
     "Сравнительный период:" VIEW-AS TEXT
          SIZE 26.88 BY 1 AT ROW 1.33 COL 2.5
          FGCOLOR 4
     RECT-6 AT ROW 6.71 COL 1.75
     RECT-5 AT ROW 1.21 COL 1.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.88
         WIDTH              = 76.13.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX TOGGLE-2 IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME TOGGLE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOGGLE-1 s-object
ON VALUE-CHANGED OF TOGGLE-1 IN FRAME F-Main /* Только итоги */
DO:
  assign TOGGLE-1 .
  if TOGGLE-1 = yes then ENABLE  TOGGLE-2 FILL-IN-3 WITH FRAME F-Main.
  else                   DISABLE TOGGLE-2 FILL-IN-3 WITH FRAME F-Main.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */

  assign
    FILL-IN-1 :screen-value in frame {&frame-name} = string(TODAY,"99/99/9999")
    FILL-IN-2 :screen-value in frame {&frame-name} = string(TODAY,"99/99/9999")
  .
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF
/*  DISABLE TOGGLE-2 FILL-IN-3 WITH FRAME F-Main.*/
/*  DISPLAY TOGGLE-2 FILL-IN-3 WITH FRAME F-Main.*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
Assign frame {&frame-name} FILL-IN-1 FILL-IN-2 FILL-IN-3 TOGGLE-1 TOGGLE-2 SumObj ShowNull RADIO-sel .

  define variable date1 as date    no-undo .
  define variable date2 as date    no-undo .
  define variable lavel as integer no-undo .

  if TOGGLE-2 = yes then assign lavel = int ( FILL-IN-3 :screen-value ) .
  else                   assign lavel = -1 .

  assign
    date1 = DATE( FILL-IN-1 :screen-value )
    date2 = DATE( FILL-IN-2 :screen-value )
  .
  if date1 > date2 then  message "Дата начала интервала больше даты конца!"  view-as alert-box.
  else  run rep/r-slg-s.p ( date1, date2, TOGGLE-1, lavel, TOGGLE-3, SumObj, ShowNull, RADIO-sel) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

  Assign frame {&frame-name} FILL-IN-1 FILL-IN-2 FILL-IN-3 TOGGLE-1 TOGGLE-2  TOGGLE-3 .

  /*строки в которых содержатся выбранные объекты */
  Assign
    STR-obj-type = ''
    STR-obj-code = ''
    STR-obj-name = ''
    STR-obj      = ''
  .

  For each obj-list no-lock:
    Assign
      STR-obj-type = STR-obj-type + obj-list.obj-type + ','
      STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
      STR-obj-name = STR-obj-name + obj-list.obj-name + ','
      STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ','
    .
  End.
  assign
    str1 = "Сравнительный период с " + String(FILL-IN-1,"99/99/9999") + " по " + String(FILL-IN-2,"99/99/9999")
    str2 =  if TOGGLE-3 = yes then "С учетом возвратов."  else  "Без учета возвратов."
    str3 =  if x-SET_PAY_TYPE = 1 then "В ценах продажи."  else  "В учетных ценах."
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
    when "link-changed":U then  DO:
         Run my-var.
         End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME