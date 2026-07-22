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

Отчет по ФиБ

Автор: Чернова Светлана Александровна
Дата создания: 11/20/09
Author: Svetlana Chernova
Creation date: 11/20/09


*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по ФиБ".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i  }
{ gbl/godendo.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def " " my-handle }
define variable v-today as date      no-undo .
define variable v-time as integer   no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-5 rs-classificator rs-sort-type
&Scoped-Define DISPLAYED-OBJECTS rs-classificator rs-sort-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE rs-classificator AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Производители", "prod":U,
"Группы товаров", "grp-goods":U,
"Производители/Группы товаров", "prod/grp-goods":U,
"Группы товаров/Производители", "grp-goods/prod":U
     SIZE 30.5 BY 5.75 NO-UNDO.

DEFINE VARIABLE rs-sort-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименов.", "sort-name":U
     SIZE 14 BY 2.75 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.25 BY 7.17.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 16 BY 7.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     rs-classificator AT ROW 4.25 COL 1.5 NO-LABEL
     rs-sort-type AT ROW 4.58 COL 35.13 NO-LABEL
     "Сортировка :" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 3.33 COL 36.63
          FGCOLOR 4
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 3.21 COL 9.25
          FGCOLOR 4
     RECT-6 AT ROW 3 COL 34
     RECT-5 AT ROW 3 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 FGCOLOR 0 .


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
         HEIGHT             = 9.58
         WIDTH              = 50.63.
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

&Scoped-define SELF-NAME rs-classificator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-classificator s-object
ON VALUE-CHANGED OF rs-classificator IN FRAME F-Main
DO:
    Assign rs-classificator.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
{ gbl/getcntxt.i get " " my-handle }

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

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/

    run rep/r-defect.p
    (     input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , input rs-classificator
        , input rs-sort-type
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
{ rep/rvarpage.i }
    assign frame {&frame-name}
        rs-classificator
        rs-sort-type
    .
    define variable v-class-string as character no-undo.
    define variable v-sort-string  as character no-undo.
    case rs-classificator:
        WHEN "no-classify":U    THEN v-class-string = "Без классификации" .
        WHEN "prod":U           THEN v-class-string = "Производители"   .
        WHEN "post":U           THEN v-class-string = "Поставщики"   .
        WHEN "grp-goods":U      THEN v-class-string = "Группы товаров"  .
        WHEN "post/grp-goods":U THEN v-class-string = "Поставщики/Группы товаров" .
        WHEN "prod/grp-goods":U THEN v-class-string = "Производители/Группы товаров" .
        WHEN "grp-goods/prod":U THEN v-class-string = "Группы товаров/Производители" .
        WHEN "grp-goods/post":U THEN v-class-string = "Группы товаров/Поставщики" .
        WHEN "vat-ps":U         THEN v-class-string = "Ставка НДС" .
        WHEN "sort":U           THEN v-class-string = "Проба(Сорт)" .
        WHEN "n-level":U        THEN v-class-string = "Группы с уровнем вложенности " .
        WHEN "t-level":U        THEN v-class-string = "Терминальные группы" .
    end case.
    case rs-sort-type:
        WHEN "sort-code":U          THEN v-sort-string = "по коду" .
        WHEN "sort-artic":U         THEN v-sort-string = "по артикулу"  .
        WHEN "sort-qunty":U         THEN v-sort-string = "по реализации".
        WHEN "sort-name":U          THEN v-sort-string = "по наименованию".
        WHEN "sort-type":U          THEN v-sort-string = "по типу ткани".
        WHEN "sort-doc-code":U      THEN v-sort-string = "по номеру документа".
        WHEN "sort-recipe-code":U   THEN v-sort-string = "по номеру рецепта".
    end case.
    assign
        ReportName   = substitute(  "Отчет по фальсифицированным и забракованным партиям на &1" , string( today , "99/99/9999") ).

        ReportHeader    = substitute( "Приходы c &1 по &2" , string(x-date-start , "99/99/9999") , string(x-date-end , "99/99/9999")  )
                        + chr(10) + substitute( "Классификация: &1", v-class-string )
                        + chr(10) + substitute( "Сортировка: &1", v-sort-string )
                        .
      find first g#customer no-error .
      if available  g#customer then do:
      ReportHeader = ReportHeader + " По списку поставщиков" .
      end.

 sheetf.Excel-Column-Lable =
           "Код"
  + ","  + "Артикул"
  + ","  + "Производитель"
  + ","  + "Наименование товара"
  + ","  + "Поставщик"
  + ","  + "Имя поставщика"
  + ","  + "Партия"
  + ","  + "Остаток"
  + ","  + "Объект"
  + ","  + "ПН"
  + ","  + "Дата ПН"
  + ","  + "Цена учетная"
  + ","  + "Цена продажная"
  + ","  + "Цена производителя"
  .
 sheetf.Sizes         =  "10,16,20,35,15,40,15,15,20,15,15,15,15,15" .
 sheetf.make-correct  =  "" .
END PROCEDURE.
{ rep/varfpage.i }

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