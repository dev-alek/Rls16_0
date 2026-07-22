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

Отчет по исполнению заявок (закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 12/11/08
Author: Svetlana Chernova
Creation date: 12/11/08

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по исполнению заявок  (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable  State-source as  WIDGET-HANDLE.
define variable  cli-lst as character no-undo .

{ cmp/r-page1.i }
{ cmp/str-glbl.i }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .

/*define variable ii as integer no-undo .*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-8 RECT-9 RAD-otkl Ed-otkl-prc ~
Ed-otkl-tmh Ed-otkl-tmm RAD-Post-2 tg-zay 
&Scoped-Define DISPLAYED-OBJECTS RAD-otkl Ed-otkl-prc Ed-otkl-tmh ~
Ed-otkl-tmm RAD-Post-2 tg-zay 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE Ed-otkl-prc AS INTEGER FORMAT ">>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 8.63 BY .96 NO-UNDO.

DEFINE VARIABLE Ed-otkl-tmh AS INTEGER FORMAT "9999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE Ed-otkl-tmm AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3.63 BY 1 NO-UNDO.

DEFINE VARIABLE RAD-otkl AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все товары", 1,
"Отклонения по кол-ву (%)", 2,
"Отклонения по времени ", 3,
"Все отклонения", 4
     SIZE 31.63 BY 6.21
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE RAD-Post-2 AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "По поставкам", 1,
"По накладным", 2
     SIZE 27.63 BY 2.75 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43.5 BY 7.67.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28.63 BY 2.08.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43.5 BY 4.38.

DEFINE VARIABLE tg-zay AS LOGICAL INITIAL no 
     LABEL "Итоги по заявкам" 
     VIEW-AS TOGGLE-BOX
     SIZE 25.25 BY .83 TOOLTIP "Раздельно по заявкам" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RAD-otkl AT ROW 2.13 COL 2.38 NO-LABEL
     Ed-otkl-prc AT ROW 3.83 COL 32.38 COLON-ALIGNED NO-LABEL
     Ed-otkl-tmh AT ROW 5.46 COL 31.5 COLON-ALIGNED NO-LABEL
     Ed-otkl-tmm AT ROW 5.46 COL 37.38 COLON-ALIGNED NO-LABEL
     RAD-Post-2 AT ROW 10.04 COL 2.25 NO-LABEL
     tg-zay AT ROW 14.21 COL 2.88
     "Сравнение:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 9.13 COL 7.38
          FGCOLOR 4 
     "Выбор товаров:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.29 COL 11.63
          FGCOLOR 4 
     ":" VIEW-AS TEXT
          SIZE .75 BY .96 TOOLTIP ":" AT ROW 5.54 COL 38.63
     RECT-5 AT ROW 1 COL 1.63
     RECT-8 AT ROW 13.58 COL 1.88
     RECT-9 AT ROW 8.83 COL 1.75
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
         WIDTH              = 70.38.
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
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
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

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME RAD-otkl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RAD-otkl s-object
ON VALUE-CHANGED OF RAD-otkl IN FRAME F-Main
DO:
 assign RAD-otkl.
 assign Ed-otkl-prc.
 assign Ed-otkl-tmh.
 assign Ed-otkl-tmm.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
 define variable Ed-otkl-tm as integer   no-undo initial 0 .

 case RAD-otkl :
   when 3 then do:
     assign
       Ed-otkl-tm = Ed-otkl-tmh * 60 + Ed-otkl-tmm
     .
   end.
   when 4 then do:
     assign
       Ed-otkl-tm  = 0
       Ed-otkl-prc = 0
     .
   end.
 end.


 run cus/r-isp-zy.p ( tg-zay, RAD-otkl, Ed-otkl-prc, Ed-otkl-tm, RAD-Post-2) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
  assign frame {&frame-name}   RAD-otkl .
  assign frame {&frame-name}   Ed-otkl-prc .
  assign frame {&frame-name}   Ed-otkl-tmm .
  assign frame {&frame-name}   Ed-otkl-tmh .
  assign frame {&frame-name}   RAD-Post-2 .
  assign frame {&frame-name}   tg-zay .

  str2 = "Выбор товаров: " .
  case RAD-otkl :
    when 1 then do:
      str2 = str2 + "все" .
    end.
    when 2 then do:
      str2 = str2 + "отклонения по кол-ву больше " + String(Ed-otkl-prc) + "  %" .
    end.
    when 3 then do:
      str2 = str2 + "отклонения по времени больше " + String(Ed-otkl-tmh) + " ч. " + String(Ed-otkl-tmm) + " м. " .
    end.
    when 4 then do:
      str2 = str2 + "все отклонения" .
    end.
  end.

  case RAD-post-2 :
    when 1 then do:
      str3 = "Сравнивать по поставкам" .
    end.
    when 2 then do:
      str3 = "Сравнивать по накладным" .
    end.
  end.


 ReportNAme   = "Отчет по исполнению поставок" .

/* ReportHeader = "Контрагенты : " + PostName + chr(10) .*/
/* sheetf.Excel-Column-Lable = "Код,Артикул,Наименование,Ед.изм,Кол-во по поставке,Дата поставки,Время поставки,Цена поставки,Кол-во по накладной,Дата накладной,Время накладной,Цена накладной".*/
/* sheetf.Sizes = "10,10,60,6,13,13,13,13,13,13,13,13".*/

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
      /* link-changed */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

