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

ОТЧЕТ О СОСТОЯНИИ ЗАПАСА И ПРОДАЖАХ (закладка № 2)

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
def var vss-description as character no-undo init "ОТЧЕТ О СОСТОЯНИИ ЗАПАСА И ПРОДАЖАХ (закладка № 2)".
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

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-8 Classify ShowZero-2 ~
RADIO-SET-1 ShowZero B-columns
&Scoped-Define DISPLAYED-OBJECTS Classify ShowZero-2 RADIO-SET-1 ShowZero

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-columns
     LABEL "Выбор колонок для печати"
     SIZE 28.75 BY 1 TOOLTIP "Выбор колонок для печати".

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Производители", "prod":U,
"Группы товаров", "grp-goods":U
     size 46.88 by 7.83 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Суммы в продажных ценах", 1,
"Суммы в учетных ценах", 2
     SIZE 31 BY 3.54 TOOLTIP "Показывать суммы в учетных или продажных ценах" NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.13 BY 9.33.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 75.25 BY 7.25.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     size 19 by 0.83 NO-UNDO.

DEFINE VARIABLE ShowZero-2 AS LOGICAL INITIAL no
     LABEL "Нулевые обороты":L
     VIEW-AS TOGGLE-BOX
     size 19 by 0.83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Classify at row 2.29 col 2.88 NO-LABEL
     ShowZero-2 at row 12.04 col 49.38
     RADIO-SET-1 AT ROW 12.25 COL 3 NO-LABEL
     ShowZero at row 12.96 col 49.38
     B-columns AT ROW 16.5 COL 3
     "Классификация :":C47 VIEW-AS TEXT
          size 46.25 by 0.75 at row 1.42 col 2.5
          FGCOLOR 4
     "Показать :":C40 VIEW-AS TEXT
          size 39.88 by 0.75 at row 11.17 col 3
          FGCOLOR 4
     RECT-5 AT ROW 1.21 COL 1.75
     RECT-8 AT ROW 10.63 COL 1.75
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

ASSIGN
       B-columns:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME B-columns
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-columns s-object
ON CHOOSE OF B-columns IN FRAME F-Main /* Выбор колонок для печати */
DO:
  /* Процедура задания колонок в отчете */
  /* run rep/askfield.w ( input "r-oborot":U, output print-o ) . */
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :

def var  l-ind as integer no-undo .
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :

if x-SelectGood = 1 then do:
  if x-SET_val_TYPE = 1 /* р_у_б */
  then do:
    run rep/r-zap-p1.p  (input classify ,
                      input RADIO-SET-1 ,
                      input ShowZero ,
                      input ShowZero-2 ) .
  end.
  else do:
    run rep/r-zap-p2.p  (input classify,
                      input RADIO-SET-1 ,
                      input ShowZero ,
                      input ShowZero-2 ) .
  end.
end.
else do:
  if x-SET_val_TYPE = 1 /* р_у_б */
  then do:
    run rep/r-zap-p3.p  (input classify,
                      input RADIO-SET-1 ,
                      input ShowZero ,
                      input ShowZero-2 ) .
  end.
  else do:
    run rep/r-zap-p4.p  (input classify,
                      input RADIO-SET-1 ,
                      input ShowZero ,
                      input ShowZero-2 ) .

  End.
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
Assign frame {&frame-name} ShowZero Classify ShowZero-2 RADIO-SET-1 .

/*строки в которых содержатся выбранные объекты */
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = '' .

For each obj-list no-lock:
  Assign
    STR-obj-type = STR-obj-type + obj-list.obj-type + ','
    STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
    STR-obj-name = STR-obj-name + obj-list.obj-name + ','
    STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ','
  .
End.

ReportNAme = "О Т Ч Е Т   О   С О С Т О Я Н И И   З А П А С А   И   П Р О Д А Ж А Х ".

def var t-class as char no-undo.
  CASE Classify:
    WHEN "no-classify":U    THEN t-class =   "Без классификации" .
    WHEN "prod":U           THEN t-class =   "Производители"   .
    WHEN "post":U           THEN t-class =   "Поставщики"   .
    WHEN "grp-goods":U      THEN t-class =   "Группы товаров"  .
    WHEN "prod/grp-goods":U THEN t-class =   "Производители/Группы товаров" .
    WHEN "grp-goods/prod":U THEN t-class =   "Группы товаров/Производители" .
    WHEN  "vat-ps":U        THEN t-class =   "Ставка НДС" .
    WHEN  "sort":U          THEN t-class =   "Проба(Сорт)" .
    WHEN  "n-level":U       THEN t-class =   "Группы с уровнем вложенности " .
    WHEN  "t-level":U       THEN t-class =   "Терминальные группы" .
 End case.

ReportHeader = "Классификация : " + t-Class + chr(10) .
ReportHeader = ReportHeader +
               "Показать : " +
               (if RADIO-SET-1 = 1    then " Суммы в продажных ценах "  else " Суммы в учетных ценах " ) +
               (if x-SET_val_TYPE = 1 then "в {&abbr_rublyah}, "  else "в валюте, " ) +
               (if ShowZero           then " Показывать нулевые остатки "  else " Не показывать нулевые остатки " ) +
               (if ShowZero-2         then " Показывать нулевые обороты "  else " Не показывать нулевые обороты " )
             .

Sheetf.Excel-Column-Lable = "Артикул,Название товара,".
Sheetf.Sizes = "16,60,".

for each obj-list no-lock :
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable + " Объект " + obj-list.obj-type + " " + string(obj-list.obj-code) + ",,,,," .
     Sheetf.Sizes = Sheetf.Sizes + Fill("15,", 5)  .
End.
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable  + {&new-line} +  ",,".
for each obj-list no-lock :
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable + "Цена на конец периода,Остаток на начало - кол-во,Реализация - кол-во,Остаток на конец - кол-во, Остаток на конец - сумма," .
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
    when "link-changed":U then  DO:
         Run my-var.
         End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME