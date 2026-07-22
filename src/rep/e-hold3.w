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

Отчет по межфирменным операциям - Рейтинг товаров в реализации (закладка № 2)

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
def var vss-description as character no-undo init "Отчет по межфирменным операциям - Рейтинг товаров в реализации (закладка № 2)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
  { cmp/str-glbl.i }
{ cmp/r-page1.i }
  { cmp/showinf.i }
{ gbl/holdattr.i }

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
&Scoped-Define ENABLED-OBJECTS RECT-5 RADIO-SET-1 dat
&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-1 dat dat-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE dat AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Отчетный год"
     VIEW-AS FILL-IN
     SIZE 6.13 BY 1 NO-UNDO.

DEFINE VARIABLE dat-2 AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Отчетный месяц"
     VIEW-AS FILL-IN
     SIZE 3.75 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Год", 1,
"Месяц", 2
     SIZE 19.63 BY 1.83 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 28.5 BY 6.88.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RADIO-SET-1 AT ROW 2.63 COL 4.38 NO-LABEL
     dat AT ROW 4.96 COL 16.25 COLON-ALIGNED
     dat-2 AT ROW 6.29 COL 18.38 COLON-ALIGNED
     "Отчетный период:" VIEW-AS TEXT
          SIZE 20.88 BY .67 AT ROW 1.67 COL 4.25
          FGCOLOR 4
     RECT-5 AT ROW 1.13 COL 1.5
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
         HEIGHT             = 16.75
         WIDTH              = 68.75.
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

/* SETTINGS FOR FILL-IN dat-2 IN FRAME F-Main
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

&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 s-object
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME F-Main
DO:
  Assign RADIO-SET-1.
  if RADIO-SET-1 = 2 Then do:
/*    display dat-2   with frame {&FRAME-NAME} .*/
    enable  dat-2   with frame {&FRAME-NAME} .
  end.
  Else do:
/*    display  dat-2  with frame {&FRAME-NAME} .*/
    disable  dat-2  with frame {&FRAME-NAME} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  assign
    dat :screen-value in frame {&frame-name} = string(year(x-Date-Start))
    dat-2 :screen-value in frame {&frame-name} = string(month(x-Date-Start))
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
  define variable v-hold-date-value as character no-undo .
  define variable v-hold-date-type  as character no-undo .
  define variable v-cat-code as integer initial 1 no-undo .
  run holdattr-value in this-procedure (input v-cat-code, input  {&hold-attr-begin-date}, output v-hold-date-value, output v-hold-date-type) .
  define variable dat1 as date   no-undo .
  if RADIO-SET-1 = 1 then assign dat1 = date(1,1,dat) .
  else                    assign dat1 = date(dat-2,1,dat) .
  if dat1 < date(v-hold-date-value) then message
    "Дата начала отчетного периода "  dat1 " меньше"  skip
    "даты начала рассчитаных архивов " v-hold-date-value "!" skip
    "Отчет будет сформирован начиная с " v-hold-date-value
    view-as alert-box WARNING TITLE "В Н И М А Н И Е ! " .

 if RADIO-SET-1 = 2 then run rep/r-hold3.p  ( input dat, input dat-2 ) .
 else                    run rep/r-hold3.p  ( input dat, input 0 ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
  assign frame {&frame-name} RADIO-SET-1 dat dat-2 .

  if RADIO-SET-1 = 2 then do:
    if dat-2 < 1 or dat-2 > 12 then message "Ошибка задания месяца!"  view-as alert-box.
    else do:
      case dat-2 :
        when 1 then ReportNAme = "Динамика продаж за январь "  + String(dat) + " года." .
        when 2 then ReportNAme = "Динамика продаж за февраль " + String(dat) + " года." .
        when 3 then ReportNAme = "Динамика продаж за март "    + String(dat) + " года." .
        when 4 then ReportNAme = "Динамика продаж за апрель "  + String(dat) + " года." .
        when 5 then ReportNAme = "Динамика продаж за май "     + String(dat) + " года." .
        when 6 then ReportNAme = "Динамика продаж за июнь "    + String(dat) + " года." .
        when 7 then ReportNAme = "Динамика продаж за июль "    + String(dat) + " года." .
        when 8 then ReportNAme = "Динамика продаж за август "  + String(dat) + " года." .
        when 9 then ReportNAme = "Динамика продаж за сентябр " + String(dat) + " года." .
        when 10 then ReportNAme = "Динамика продаж за октябрь " + String(dat) + " года." .
        when 11 then ReportNAme = "Динамика продаж за ноябрь "  + String(dat) + " года." .
        when 12 then ReportNAme = "Динамика продаж за декабрь " + String(dat) + " года." .
      end.
    end.
  end.
  else ReportNAme = "Рейтинг товаров в реализации за "  + String(dat) + " год." .

  if x-SET_val_TYPE = 1 then ReportHeader = "Цены указаны в: {&abbr_rublyah}".
  else                       ReportHeader = "Цены указаны в: валюте".


/*  End.*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
