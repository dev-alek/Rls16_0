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

Состояние запаса с учетом резервов (закладка № 2)

Автор: Демин Алексей Сергеевич
Дата создания: 01/11/06
Author: Alexey Demin
Creation date: 01/11/06

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Состояние запаса с учетом резервов(закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
define variable g#log  as logical   no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-6 Tog-obj SortType Classify ~
ShowZero
&Scoped-Define DISPLAYED-OBJECTS Tog-obj SortType Classify SumsOnly ~
ShowZero

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-1
     LABEL "Button 1"
     SIZE 15 BY 1.13.

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Производители", "prod":U,
"Группы товаров", "grp-goods":U,
"Производители/Группы товаров", "prod/grp-goods":U,
"Группы товаров/Производители", "grp-goods/prod":U,
"Поставщики", "post":U,
"Поставщики/Группы товаров", "post/grp-goods":U,
"Группы товаров/Поставщики", "grp-goods/post":U,
"НДС", "vat-pc":U
     SIZE 30.5 BY 9 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименов.", "sort-name":U
     SIZE 14 BY 2.75 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.25 BY 11.88.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 16.13 BY 5.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Показывать нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     SIZE 31.13 BY 1.13 NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги":L
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes
     LABEL "Раздельно по объектам":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.75 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Tog-obj AT ROW 2 COL 2.75
     SortType AT ROW 2.71 COL 35.38 NO-LABEL
     Classify AT ROW 3.63 COL 2.25 NO-LABEL
     SumsOnly AT ROW 12.96 COL 2.25
     BUTTON-1 AT ROW 13 COL 36
     ShowZero AT ROW 13.88 COL 2.25
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 1.33 COL 9.5
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 1.46 COL 36.88
          FGCOLOR 4
     RECT-5 AT ROW 1.13 COL 1.63
     RECT-6 AT ROW 1.13 COL 34.25
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
         HEIGHT             = 14.33
         WIDTH              = 53.5.
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

/* SETTINGS FOR BUTTON BUTTON-1 IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       BUTTON-1:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX SumsOnly IN FRAME F-Main
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


&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify s-object
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
    Assign Classify.
    if Classify <>  "no-classify":U then enable SumsOnly with frame {&FRAME-NAME} .
    else  do:
      SumsOnly = FALSE .
      display SumsOnly with frame {&FRAME-NAME} .
      disable SumsOnly with frame {&FRAME-NAME} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  run dispatch IN THIS-PROCEDURE ('initialize':U).
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
def var v-kol as integer no-undo .
v-kol = 0.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-cost':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    g#log
  }
 if not g#log then v-kol = v-kol + 1.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-sale':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    g#log
  }
 if not g#log then v-kol = v-kol + 1.

 IF  v-kol >= 2  then DO:
   Message "Отчет не может быть сформирован без указания цен. Но на просмотр цен у вас нет прав!             "  view-as alert-box .
   return .
 End.

 assign sheetf.Excel-Column-Lable = ""  sheetf.Sizes = "" .
 if use-column[1]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "№ п\п,"                   sheetf.Sizes = sheetf.Sizes +  "5," .
 if use-column[2]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Код,"                     sheetf.Sizes = sheetf.Sizes +  "10," .
 if use-column[3]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Артикул,"                 sheetf.Sizes = sheetf.Sizes +  "16," .
 if use-column[4]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Название товара,"         sheetf.Sizes = sheetf.Sizes +  "40," .
 if use-column[5]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Ед. изм,"                 sheetf.Sizes = sheetf.Sizes +  "3," .
 if use-column[6]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Факт. кол-во,"            sheetf.Sizes = sheetf.Sizes +  "14," .
 if use-column[7]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Своб. кол-во,"            sheetf.Sizes = sheetf.Sizes +  "14," .
 if use-column[8]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Учет. цена с НДС,"        sheetf.Sizes = sheetf.Sizes +  "15," .
 if use-column[9]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Продажная цена,"          sheetf.Sizes = sheetf.Sizes +  "15," .
 if use-column[10]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Сумма в уч.ценах с НДС,"  sheetf.Sizes = sheetf.Sizes +  "15," .
 if use-column[11]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Сумма наценки,"           sheetf.Sizes = sheetf.Sizes +  "15," .
 if use-column[12]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "% наценки,"               sheetf.Sizes = sheetf.Sizes +  "9," .
 if use-column[13]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Ожидаемое кол-во,"        sheetf.Sizes = sheetf.Sizes +  "13," .
 if LENGTH( sheetf.Excel-Column-Lable ) > 0 then do:
   substr ( sheetf.Excel-Column-Lable, LENGTH( sheetf.Excel-Column-Lable )) = "" .
   substr ( sheetf.Sizes, LENGTH( sheetf.Sizes )) = "" .
   run rep/r-zapasr.p (input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero, input Tog-obj).
 end.
 else do:
   run my-var.
   return error "format-page".
   /*message "Необходимо сходить на закладку <Формат...> !".*/
 end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} SumsOnly ShowZero  Classify SortType Tog-obj.
 { rep/claslabl.i }
x-date-end = x-date-alone.

ReportNAme = "С О С Т О Я Н И Е    З А П А С А (с учетом резервов) на " + string(x-date-alone,"99/99/9999") .
ReportHeader = "Классификация : " + t-class + chr(10) +
               (if SumsOnly then ("Только итоги " + chr(10))  else "" )   +
              "Сортировка " + t-sort  + chr(10) +
               (if ShowZero then "Показывать нулевые остатки "  else "Не показывать нулевые остатки" ) + chr(10) +
               "Цены указаны в " + (if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type )  .

 sheetf.Excel-Column-Lable =
          "№ п\п"
  + ","  + "Код"
  + ","  + "Артикул"
  + ","  + "Название товара"
  + ","  + "Ед. изм"
  + ","  + "Факт. кол-во"
  + ","  + "Своб. кол-во"
  + ","  + "Учет. цена с НДС"
  + ","  + "Продажная цена"
  + ","  + "Сумма в уч.ценах с НДС"
  + ","  + "Сумма наценки"
  + ","  + "% наценки"
  + ","  + "Ожидаемое кол-во"
 .
 sheetf.Sizes        =  "5,10,16,40,3,14,14,15,15,15,15,9,13" .
 sheetf.ColFormat = "2=@;3=@;" .
 Sheetf.make-correct = "true,true,true,true,true,true,true,true,true,true,true,true,true" .

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