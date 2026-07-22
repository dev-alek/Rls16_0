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

Отчет о динамике реализации (закладка № 2)

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
def var vss-description as character no-undo init "Отчет о динамике реализации (закладка № 2)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
def var rserv as char init "all" no-undo .
def var print-o as char init "" no-undo .

define variable Obj1-list  as character no-undo .
define variable Obj2-list  as character no-undo .

/*def input parameter Itog as logical init FALSE no-undo .*/

  { cmp/str-glbl.i }
{ cmp/r-page1.i }
  { cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-13 RECT-12 RECT-14 RECT-11 RECT-7 ~
RECT-8 RECT-6 SortType Classify num-col sum-only null-obort TOGGLE-1
&Scoped-Define DISPLAYED-OBJECTS SortType Classify num-col sum-only ~
null-obort TOGGLE-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE num-col AS INTEGER FORMAT ">9":U INITIAL 3
     VIEW-AS FILL-IN
     SIZE 4.63 BY 1 NO-UNDO.

DEFINE VARIABLE Classify AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", 1,
"Производители", 2,
"Группы товаров", 3,
"Производители/Группы товаров", 4,
"Группы товаров/Производители", 5
     size 33.13 by 6.29 NO-UNDO.

DEFINE VARIABLE SortType AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", 1,
"по артикулу", 2,
"по наименованию", 3,
"по остаткам на начало", 4,
"по приходу", 5,
"по реализации", 6,
"по остаткам на конец", 7
     size 31.13 by 8.75 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 74.38 BY 6.13.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 17.38 BY 2.21.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 17.38 BY 2.21.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 17.38 BY 2.21.

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 17.38 BY 2.21.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 34.75 BY 10.33.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.25 BY 8.08.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.38 BY 1.83.

DEFINE VARIABLE null-obort AS LOGICAL INITIAL yes
     LABEL "Нулевые обороты"
     VIEW-AS TOGGLE-BOX
     SIZE 20.75 BY .83 NO-UNDO.

DEFINE VARIABLE sum-only AS LOGICAL INITIAL yes
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no
     LABEL "Экспорт в текст. файл с разделителем"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SortType at row 2.25 col 42.63 NO-LABEL
     Classify at row 2.5 col 4.38 NO-LABEL
     num-col AT ROW 9.92 COL 33.38 COLON-ALIGNED NO-LABEL
     sum-only AT ROW 13.83 COL 50
     null-obort AT ROW 14.92 COL 50
     TOGGLE-1 AT ROW 16.5 COL 35
     "возврат реализ." VIEW-AS TEXT
          SIZE 15.63 BY .92 AT ROW 16.21 COL 6.25
     "возврат постав." VIEW-AS TEXT
          SIZE 15.63 BY .92 AT ROW 13.96 COL 5.75
     "Показать  :" VIEW-AS TEXT
          SIZE 15.88 BY 1 AT ROW 12.46 COL 50.63
          FGCOLOR 4
     "Кол-во интервалов разбиения :" VIEW-AS TEXT
          SIZE 30.38 BY 1 AT ROW 9.88 COL 3.63
          FGCOLOR 4
     "Данные для печати :" VIEW-AS TEXT
          SIZE 22.5 BY 1 AT ROW 11.75 COL 10.13
          FGCOLOR 4
     "Остаток на" VIEW-AS TEXT
          SIZE 12 BY .92 AT ROW 13.17 COL 24.13
     "Классификация :":C47 VIEW-AS TEXT
          size 35 by 0.75 at row 1.42 col 4.25
          FGCOLOR 4
     "Приход внеш. -" VIEW-AS TEXT
          SIZE 14.63 BY .92 AT ROW 13.08 COL 6.13
     "Сортировка :" VIEW-AS TEXT
          size 13.63 by 0.75 at row 1.42 col 42.63
          FGCOLOR 4
     "Реализ. внеш. -" VIEW-AS TEXT
          SIZE 15.63 BY .92 AT ROW 15.38 COL 6
     "конец интервала" VIEW-AS TEXT
          SIZE 15.88 BY .92 AT ROW 14 COL 24.13
     RECT-13 AT ROW 15.21 COL 5
     RECT-12 AT ROW 12.79 COL 5
     RECT-14 AT ROW 12.79 COL 23.13
     RECT-11 AT ROW 12.83 COL 5
     RECT-7 AT ROW 1.21 COL 2.5
     RECT-8 AT ROW 9.46 COL 2.5
     RECT-6 AT ROW 1.13 COL 41.63
     RECT-10 AT ROW 11.54 COL 2.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
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
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-10 IN FRAME F-Main
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




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

display num-col WITH FRAME {&frame-name}.

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
/*define variable num-col as integer   no-undo .*/
/*assign num-col = 3 .*/
if x-date-end > x-date-start then run rep/r-dinrel.p ( SortType, Classify, sum-only, num-col, null-obort, TOGGLE-1) .
else message   "Отчет о динамике за 1 день не имеет смысла!"  view-as alert-box.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

  Assign frame {&frame-name}  SortType Classify sum-only num-col null-obort TOGGLE-1 .

  /*строки в которых содержатся выбранные объекты */
  Assign
    STR-obj-type = ''
    STR-obj-code = ''
    STR-obj-name = ''
    STR-obj      = ''
    str1 = "Классификация : "
  .

  For each obj-list no-lock:
    Assign
      STR-obj-type = STR-obj-type + obj-list.obj-type + ','
      STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
      STR-obj-name = STR-obj-name + obj-list.obj-name + ','
      STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ','
    .
  End.

  CASE Classify:
    WHEN 1 THEN str1 = str1 + "Без классификации" .
    WHEN 2 THEN str1 = str1 + "Производители"   .
    WHEN 3 THEN str1 = str1 + "Группы товаров"  .
    WHEN 4 THEN str1 = str1 + "Производители/Группы товаров" .
    WHEN 5 THEN str1 = str1 + "Группы товаров/Производители" .
  End case.

  assign  str1 = str1 + "  Сортировка : " .
  CASE SORTtype:
    WHEN 1 THEN str1 = str1 + "по коду" .
    WHEN 2 THEN str1 = str1 + "по артикулу"  .
    WHEN 3 THEN str1 = str1 + "по наименованию".
    WHEN 4 THEN str1 = str1 + "по остаткам на начало".
    WHEN 5 THEN str1 = str1 + "по приходу".
    WHEN 6 THEN str1 = str1 + "по реализации".
    WHEN 7 THEN str1 = str1 + "по остаткам на конец".
  End case.

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
