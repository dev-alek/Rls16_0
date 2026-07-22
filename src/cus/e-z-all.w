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

Состояние запаса по объектам (с учетом признаков)

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06

Created: 06/08/01
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запасы по признакам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/rep-bt.i }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.

define variable    str-obj# as char no-undo.
define variable    str-obj2# as char no-undo.
define variable    rec-list as char no-undo.
define variable    temp-param-obj-type as char no-undo.
define variable    temp-param-obj as char no-undo.
def buffer cli-obj  for clients .
DEF VAR  ii             AS INTEGER no-undo.

{ cmp/obj-list.i new alt-obj-list}

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
&Scoped-Define ENABLED-OBJECTS RECT-12 RECT-3 Classify Itog x-cost x-sale ~
x-dis
&Scoped-Define DISPLAYED-OBJECTS Classify Itog x-cost x-sale x-dis

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE Classify AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", 1,
"По производителю", 2,
"По группам товаров", 3,
"По НДС из карточки товара", 4
     SIZE 28.63 BY 3.71 NO-UNDO.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 77.75 BY 16.75.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.13 BY 16.75.

DEFINE VARIABLE Itog AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.

DEFINE VARIABLE x-cost AS LOGICAL INITIAL no
     LABEL "Учетные цены с НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.

DEFINE VARIABLE x-dis AS LOGICAL INITIAL no
     LABEL "% Наценки"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.

DEFINE VARIABLE x-sale AS LOGICAL INITIAL no
     LABEL "Продажные цены"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Classify AT ROW 2.96 COL 2.88 NO-LABEL
     Itog AT ROW 8.33 COL 2.25
     x-cost AT ROW 9.38 COL 2.25
     x-sale AT ROW 10.38 COL 2.25
     x-dis AT ROW 11.5 COL 2.25
     "Классификация:":C28 VIEW-AS TEXT
          SIZE 28.75 BY .75 AT ROW 1.42 COL 3
          FGCOLOR 4
     "Показать:":C28 VIEW-AS TEXT
          SIZE 28.75 BY .75 AT ROW 7.29 COL 2.88
          FGCOLOR 4
     RECT-12 AT ROW 1.13 COL 1
     RECT-3 AT ROW 1.13 COL 32.63
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
         HEIGHT             = 17.25
         WIDTH              = 77.88.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI s-object  _DEFAULT-ENABLE
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
  DISPLAY Classify Itog x-cost x-sale x-dis
      WITH FRAME F-Main.
  ENABLE RECT-12 RECT-3 Classify Itog x-cost x-sale x-dis
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/

  if x-SelectGood = 1 Then DO:
      If x-SET_val_TYPE = 1 /* р у б */
        then
      run cus/r-z-all1.p
                     (input v-cntxt-obj-code ,
                      input v-cntxt-obj-type ,
                      input base-type ,
                      input base-code ,
                      input Classify,
                      input Itog ,
                      input x-cost,
                      input    x-sale,
                      input     x-dis ) .
      Else
      run cus/r-z-all2.p
                     (input v-cntxt-obj-code ,
                      input v-cntxt-obj-type ,
                      input base-type ,
                      input base-code ,
                      input Classify,
                      input Itog,
                      input x-cost,
                        input x-sale,
                        input x-dis ) .
  End.
  Else DO:
      If x-SET_val_TYPE = 1 /* р у б */
        then
      run cus/r-z-all3.p
         (input v-cntxt-obj-code ,
                      input v-cntxt-obj-type ,
                      input base-type ,
                      input base-code ,
                      input Classify,
                      input Itog,
                      input x-cost,
                        input x-sale,
                        input x-dis ) .
      Else
      run cus/r-z-all4.p
                      (input v-cntxt-obj-code ,
                      input v-cntxt-obj-type ,
                      input base-type ,
                      input base-code ,
                      input Classify,
                      input Itog,
                      input x-cost,
                      input x-sale,
                      input  x-dis ) .

  End.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }
assign frame {&frame-name}
 Classify itog x-cost x-dis x-sale .
x-date-start = to-day.
x-date-end = to-day.

Sheetf.Excel-Column-Lable = "N п\п,Код,Артикул,Название товара ,Признак товара,".
Sheetf.Sizes = "9,10,16,40,20,".


for each obj-list no-lock :

     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable + " Объект " + obj-list.obj-type + " " + string(obj-list.obj-code)
     + "," .
          if x-cost then Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     ",".
          if x-sale then Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "," .
          if x-dis then Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "," .

     Sheetf.Sizes = Sheetf.Sizes + "12," .
          if x-cost then Sheetf.Sizes = Sheetf.Sizes +     "13," .
          if x-sale then Sheetf.Sizes = Sheetf.Sizes +     "13," .
          if x-dis then Sheetf.Sizes  = Sheetf.Sizes +     "7," .

End.
     /* 2  */
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable  + {&new-line} +  ",,,,,".

for each obj-list no-lock :
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable + "Количество,".
          if x-cost then Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "Учетные цены с НДС,".
          if x-sale then Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "Суммы в продажных ценах," .
          if x-dis then Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "% наценки," .
End.
sheetf.make-correct =  "".
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
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME