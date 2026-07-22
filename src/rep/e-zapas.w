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

Состояние запаса(закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 20/10/00
Author: Svetlana Chernova
Creation date: 20/10/00

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Состояние запаса(закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/library.i }
{ gbl/thbjattr.i }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-6 Classify SortType ShowZero ~
Long-name PartsDet v-photo  
&Scoped-Define DISPLAYED-OBJECTS Classify SortType SumsOnly ShowZero ~
Long-name PartsDet v-photo v-alc-marks 

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
"Группы товаров/Производители", "grp-goods/prod":U
     SIZE 30.5 BY 4.75 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименов.", "sort-name":U
     SIZE 14 BY 2.75 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 32.25 BY 7.75.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 16.13 BY 7.79.

DEFINE VARIABLE PartsDet AS LOGICAL INITIAL no
     LABEL "Детализировать по партиям":L
     VIEW-AS TOGGLE-BOX
     SIZE 31.15 BY 1.08 NO-UNDO.

DEFINE VARIABLE Long-name AS LOGICAL INITIAL no 
     LABEL "В Excel-> ( Английское назв. + Назв. на этикетке)":L 
     VIEW-AS TOGGLE-BOX
     SIZE 51.75 BY 1 TOOLTIP "В Excel вместо колонки название выводить длинное название товара" NO-UNDO.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no 
     LABEL "Показывать нулевые остатки":L 
     VIEW-AS TOGGLE-BOX
     SIZE 31.13 BY 1.08 NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no 
     LABEL "Только итоги":L 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE v-alc-marks AS LOGICAL INITIAL no 
     LABEL "Печать акцизных марок":L 
     VIEW-AS TOGGLE-BOX
     SIZE 23.63 BY 1.08 NO-UNDO.

DEFINE VARIABLE v-photo AS LOGICAL INITIAL no 
     LABEL "Фото":L 
     VIEW-AS TOGGLE-BOX
     SIZE 21.13 BY 1.08 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Classify AT ROW 2.21 COL 2.25 NO-LABEL
     SortType AT ROW 2.71 COL 35.38 NO-LABEL
     SumsOnly AT ROW 7.29 COL 2.25
     BUTTON-1 AT ROW 7.5 COL 35
     ShowZero AT ROW 9.17 COL 2.25
     Long-name AT ROW 10.13 COL 2.25
     PartsDet AT ROW 11.08 COL 2.25
     v-photo AT ROW 12.21 COL 2.38 WIDGET-ID 2
     v-alc-marks AT ROW 13.25 COL 2.38 WIDGET-ID 4
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
         HEIGHT             = 13.67
         WIDTH              = 56.13.
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
/* SETTINGS FOR TOGGLE-BOX v-alc-marks IN FRAME F-Main
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

&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 s-object
ON CHOOSE OF BUTTON-1 IN FRAME F-Main /* Button 1 */
DO:
/*
/* Получить параметры C ПЕРВОЙ ЗАКЛАДКИ если нужны какие-то незашаренные переменные */
/* пока не знаю какие */
{ rep/get-link.i 'State':U }
 Run get-attribute IN State-source("str").
  message RETURN-value view-as alert-box.
  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify s-object
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
    Assign Classify.
    if Classify  Begins "prod":U OR
       Classify  Begins "grp-goods":U then
        enable SumsOnly with frame {&FRAME-NAME} .
    else
        do:
            SumsOnly = FALSE .
            display SumsOnly with frame {&FRAME-NAME} .
            disable SumsOnly with frame {&FRAME-NAME} .
            enable PartsDet with frame {&FRAME-NAME} .
        end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Long-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Long-name s-object
ON VALUE-CHANGED OF Long-name IN FRAME F-Main /* В Excel-> ( Английское назв. + Назв. на этикетке) */
DO:
  ASSIGN long-name .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME PartsDet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PartsDet s-object
ON VALUE-CHANGED OF PartsDet IN FRAME F-Main /* Детализировать по партиям */
DO:
define variable v-value-character            as   character                   no-undo.
define variable v-value-date                 as   date                        no-undo.
define variable v-value-decimal              as   decimal                     no-undo.
define variable v-value-integer              as   integer                     no-undo.
define variable v-value-mark                 as   logical                     no-undo.
define variable par-type                     as   character                   no-undo.                  
    
  ASSIGN PartsDet .

      run adm/shattri.p (
        input "get":U
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&attr-nakl_par}
        ,input  "mark-alchol"
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-mark
        ,output par-type
        ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
        ) no-error .

if v-value-mark and PartsDet then do:
    enable v-alc-marks with frame {&FRAME-NAME} . 
end.    
else do:
    DISABLE v-alc-marks with frame {&frame-name} .
end.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SumsOnly
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SumsOnly s-object
ON VALUE-CHANGED OF SumsOnly IN FRAME F-Main /* Только итоги */
DO:
  ASSIGN SumsOnly .
  if not SumsOnly then do:
      enable PartsDet with frame {&FRAME-NAME} .
      enable v-photo  with frame {&FRAME-NAME} .
  end.    
  else do :
      PartsDet = FALSE .
      display PartsDet with frame {&FRAME-NAME} .
      disable PartsDet with frame {&FRAME-NAME} .
      v-photo = FALSE .
      display v-photo with frame {&FRAME-NAME} .
      disable v-photo with frame {&FRAME-NAME} .

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-alc-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-alc-marks s-object
ON VALUE-CHANGED OF v-alc-marks IN FRAME F-Main /* Печать акцизных марок */
DO:
  ASSIGN v-alc-marks .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-photo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-photo s-object
ON VALUE-CHANGED OF v-photo IN FRAME F-Main /* Фото */
DO:
  ASSIGN v-photo .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&Scoped-define SELF-NAME v-photo-size                          */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-photo-size s-object*/
/*ON LEAVE OF v-photo-size IN FRAME F-Main /* Размер фото */     */
/*DO:                                                            */
/*  ASSIGN v-photo-size .                                        */
/*END.                                                           */
/*                                                               */
/*/* _UIB-CODE-BLOCK-END */                                      */
/*&ANALYZE-RESUME                                                */


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
define variable v-kol as integer no-undo .
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
    'actn_reports_lookup-crsa':U
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

 IF  v-kol >= 3  then DO:
   Message "Отчет не может быть сформирован без указания цен. Но на просмотр цен у вас нет прав!             "  view-as alert-box .
   return .
 End.
  CASE Classify:
    WHEN "no-classify":U    THEN
        run rep/r-zapas1.p (input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero, INPUT long-name, INPUT PartsDet, INPUT v-photo, INPUT v-alc-marks).
    WHEN "grp-goods":U      THEN
         run rep/r-zapas2.p (input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero, INPUT long-name, INPUT PartsDet, INPUT v-photo, INPUT v-alc-marks).
    WHEN "prod":U           THEN
        run rep/r-zapas3.p (input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero, INPUT long-name, INPUT PartsDet, INPUT v-photo, INPUT v-alc-marks).
    WHEN "prod/grp-goods":U THEN
         run rep/r-zapas4.p (input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero, INPUT long-name, INPUT PartsDet, INPUT v-photo, INPUT v-alc-marks).
    WHEN "grp-goods/prod":U THEN
         run rep/r-zapas5.p (input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero, INPUT long-name, INPUT PartsDet, INPUT v-photo, INPUT v-alc-marks).
 End case.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} SumsOnly ShowZero  Classify SortType long-name PartsDet v-alc-marks.
 { rep/claslabl.i }
x-date-end = x-date-alone.

ReportNAme = "С О С Т О Я Н И Е    З А П А С А ".
ReportHeader = "Классификация : " + t-class + chr(10) +
               (if SumsOnly then "Только итоги "  else " " )  +  chr(10) +
              "Сортировка " + t-sort  + chr(10) +
               (if ShowZero then "Показывать нулевые остатки "  else "Не показывать нулевые остатки " ) + chr(10) +
               (if PartsDet then "Детализировать по партиям"  else "" ).
  if X-SET_PAY_TYPE <> 2 then str3 =  "в ценах РЕАЛИЗАЦИИ".

/*if PartsDet then do :                                                                                   */
/*  sheetf.Excel-Column-Lable =                                                                           */
/*            "Код"                                                                                       */
/*    + ","  + "Артикул"                                                                                  */
/*    + ","  + "Название товара"                                                                          */
/*    + ","  + "Бар-код партии"                                                                           */
/*    + ","  + "Ед. изм"                                                                                  */
/*    + ","  + "Количество"                                                                               */
/*    + ","  + "Цена"                                                                                     */
/*    + ","  + "Стоимость"                                                                                */
/*    + ","  + "НДС"                                                                                      */
/*    + ","  + "НП"                                                                                       */
/*    + ","  + "Цена без НДС"                                                                             */
/*    + ","  + "Сумма без НДС".                                                                           */
/*  IF  long-name THEN sheetf.Sizes        =  "10,16,100,10,5,15,15,15,15,15,15,15"                      .*/
/*  ELSE sheetf.Sizes        =  "10,16,40,10,5,15,15,15,15,15,15,15"                                     .*/
/*end.                                                                                                    */
/*else do :                                                                                               */
/*  sheetf.Excel-Column-Lable =                                                                           */
/*            "Код"                                                                                       */
/*    + ","  + "Артикул"                                                                                  */
/*    + ","  + "Название товара"                                                                          */
/*    + ","  + "Ед. изм"                                                                                  */
/*    + ","  + "Количество"                                                                               */
/*    + ","  + "Цена"                                                                                     */
/*    + ","  + "Стоимость"                                                                                */
/*    + ","  + "НДС"                                                                                      */
/*    + ","  + "НП"                                                                                       */
/*    + ","  + "Цена без НДС"                                                                             */
/*    + ","  + "Сумма без НДС".                                                                           */
/*  IF  long-name THEN sheetf.Sizes        =  "10,16,100,5,15,15,15,15,15,15,15"                      .   */
/*  ELSE sheetf.Sizes        =  "10,16,40,5,15,15,15,15,15,15,15"                                     .   */
/*end.                                                                                                    */

 sheetf.make-correct = ""
 /* "true,true,true,true,true,true,true,true,true,true" */
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
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

