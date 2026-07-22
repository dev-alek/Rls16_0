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

Отчет по срокам годности товаров

Автор: Чернова Светлана Александровна
Дата создания: 11/20/09
Author: Svetlana Chernova
Creation date: 11/20/09

Автор1: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по срокам годности товаров.".
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
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-5 fi-days-amount ~
rs-classificator rs-sort-type tg-empty-disabled T-free v-godendo
&Scoped-Define DISPLAYED-OBJECTS fi-days-amount rs-classificator ~
rs-sort-type tg-empty-disabled ed-empty-disabled-label T-free v-godendo

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE ed-empty-disabled-label AS CHARACTER INITIAL "Только если срок годности задан"
     VIEW-AS EDITOR NO-BOX
     SIZE 17.5 BY 2 NO-UNDO.

DEFINE VARIABLE fi-days-amount AS INTEGER FORMAT ">>>>>>9":U INITIAL 1
     LABEL "Дней опережения"
     VIEW-AS FILL-IN
     SIZE 7.88 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-godendo AS DATE FORMAT "99/99/9999":U
     LABEL "Годность до"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 9  NO-UNDO.

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
     SIZE 16.13 BY 5.08.

DEFINE VARIABLE T-free AS LOGICAL INITIAL no
     LABEL "Показывать количество СВОБОДНОЕ"
     VIEW-AS TOGGLE-BOX
     SIZE 35 BY .83 NO-UNDO.

DEFINE VARIABLE tg-empty-disabled AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .75 TOOLTIP "Выводить только товары с заданным сроком годности" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     fi-days-amount AT ROW 1.54 COL 17.75 COLON-ALIGNED
     rs-classificator AT ROW 4.25 COL 1.5 NO-LABEL
     rs-sort-type AT ROW 4.58 COL 35.13 NO-LABEL
     tg-empty-disabled AT ROW 8.25 COL 34
     ed-empty-disabled-label AT ROW 8.25 COL 36 NO-LABEL
     T-free AT ROW 11 COL 1.5 WIDGET-ID 4
     v-godendo AT ROW 1.71 COL 39 COLON-ALIGNED WIDGET-ID 2
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
         HEIGHT             = 13.63
         WIDTH              = 57.88.
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

/* SETTINGS FOR EDITOR ed-empty-disabled-label IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       ed-empty-disabled-label:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME fi-days-amount
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-days-amount s-object
ON LEAVE OF fi-days-amount IN FRAME F-Main /* Дней опережения */
DO:
  assign fi-days-amount.
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).

    run godendo-offset-to-date in this-procedure (
          input  v-today
        , input  fi-days-amount
        , output v-godendo
    ).

  if fi-days-amount = 0 then display 'ВСЕ' @ v-godendo with frame {&frame-name}.
  else
  display v-godendo with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
    assign
        fi-days-amount = 1
        ed-empty-disabled-label = "Только если срок годности задан"
    .
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).

    run godendo-offset-to-date in this-procedure (
          input  v-today
        , input  fi-days-amount
        , output v-godendo
    ).

    display
        fi-days-amount
        ed-empty-disabled-label
        v-godendo
    with frame {&frame-name}.

  if fi-days-amount = 0 then display 'ВСЕ' @ v-godendo with frame {&frame-name}.

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
    assign frame {&frame-name}
        tg-empty-disabled
    .
    run rep/r-sroki.p (
          input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , input fi-days-amount
        , input rs-classificator
        , input rs-sort-type
        , input tg-empty-disabled
        , input t-free
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
    assign frame {&frame-name}
        fi-days-amount
        rs-classificator
        rs-sort-type
        t-free
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
        ReportName      =   "С Р О К И    Г О Д Н О С Т И"
        ReportHeader    =   substitute( "Дней опережения: &1", fi-days-amount )
                            + chr(10) + substitute( "Классификация: &1", v-class-string )
                            + chr(10) + substitute( "Сортировка: &1", v-sort-string )
    .

 sheetf.Excel-Column-Lable =
           "БарКод"
  + ","  + "Артикул"
  + ","  + "Производитель"
  + ","  + "Наименование товара"
  + ","  + "Поставщик"
  + ","  + "Имя поставщика"
  + ","  + "Партия"
  + ","  + "Количество" + ( if t-free then " Свободное" else " Факт")
  + ","  + "Объект и Место хранения"
  + ","  + "Дата срока годности"
  .
 sheetf.Sizes         =  "10,16,20,35,15,40,15,15,20,15" .
 sheetf.make-correct  =  "" .












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
