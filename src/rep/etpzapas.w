&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Состояние запаса по типу приобретени

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Created: 20/10/00
no_app_help.i

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Состояние запаса(закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/r-page1.i  }
{ cmp/str-glbl.i  }
{ rep/rep-bt.i   }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE  type-pr  AS WIDGET-HANDLE.
def var State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-10 RECT-6 Classify SortType ~
ShowZero
&Scoped-Define DISPLAYED-OBJECTS Classify SortType SumsOnly ShowZero

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
     size 30.5 by 4.75 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименов.", "sort-name":U
     size 14 by 2.75 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.75 BY 6.63.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.25 BY 7.75.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 16.13 BY 7.79.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Показывать нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     size 31.13 by 1.13 NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги":L
     VIEW-AS TOGGLE-BOX
     size 16 by 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Classify at row 2.21 col 2.25 NO-LABEL
     SortType at row 2.71 col 35.38 NO-LABEL
     SumsOnly at row 7.28 col 2.25
     BUTTON-1 AT ROW 7.71 COL 35.13
     ShowZero at row 9.17 col 2.25
     RECT-5 AT ROW 1.13 COL 1.63
     RECT-10 AT ROW 11.42 COL 1.13
     "Классификация :" VIEW-AS TEXT
          size 15 by 0.75 at row 1.33 col 9.5
          FGCOLOR 4
     RECT-6 AT ROW 1.13 COL 34.25
     "Сортировка :" VIEW-AS TEXT
          size 11.5 by 0.75 at row 1.46 col 36.88
          FGCOLOR 4
     "Тип приобретения:" VIEW-AS TEXT
          SIZE 28.88 BY .67 AT ROW 10.67 COL 1.38
          FGCOLOR 4
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
         HEIGHT             = 17.17
         WIDTH              = 61.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME


/* ***************  Runtime Attributes and UIB Settings  ************** */

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




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
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
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object _DEFAULT-DISABLE
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
  run cr-ob in this-procedure (2,12,'Все,Выкуп,Консигнация,Ответственное хранение,Старая консигнация ':L
                 ,'all,r,cb,s' + "," + {&aht-old_cons} ).



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
 /*
 if Classify <> "no-classify":U   and  type-pr:screen-value = "all" then do:
   Message "Отчет не может быть сформирован по этому условию. Для этого есть потоварные отчеты ! "  view-as alert-box .
   type-pr:screen-value    = "r"      .
   return .
 end.
 */

  CASE Classify:
    WHEN "no-classify":U    THEN
        run rep/tpzapas1.p ( input type-pr:screen-value , input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero).
    WHEN "grp-goods":U      THEN
         run rep/tpzapas2.p ( input type-pr:screen-value , input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero).
    WHEN "prod":U           THEN
        run rep/tpzapas3.p ( input type-pr:screen-value , input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero).
    WHEN "prod/grp-goods":U THEN
         run rep/tpzapas4.p ( input type-pr:screen-value , input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero).
    WHEN "grp-goods/prod":U THEN
         run rep/tpzapas5.p ( input type-pr:screen-value , input v-cntxt-obj-code,input v-cntxt-obj-type,input base-type,input base-code,input Classify,input SortType,input SumsOnly,input ShowZero).
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
assign frame {&frame-name} SumsOnly ShowZero  Classify SortType.
 { rep/claslabl.i }
x-date-end = x-date-alone.

ReportNAme = "С О С Т О Я Н И Е   З А П А С А   П О Т И П У   П Р И О Б Р Е Т Е Н И Я  -   "
+ Caps ( entry( (lookup(type-pr:screen-value ,type-pr:RADIO-BUTTONS) - 1), type-pr:RADIO-BUTTONS )   )
.
ReportHeader = "Классификация : " + t-class + chr(10) +
               (if SumsOnly then "Только итоги "  else " " )  +  chr(10) +
              "Сортировка " + t-sort  + chr(10) +
               (if ShowZero then "Показывать нулевые остатки "  else "Не показывать нулевые остатки" ) .

if type-pr:screen-value = "all" then ReportHeader =  ReportHeader
/* +
chr(10) + "Итоги по типам приобретения показываются , если типов приобретения больше одного."*/
.

  if X-SET_PAY_TYPE <> 2 then str3 =  "в ценах РЕАЛИЗАЦИИ".

 sheetf.Excel-Column-Lable =
          "Код"
  + ","  + "Артикул"
  + ","  + "Название товара"
  + ","  + "Тип"
  + ","  + "Ед. изм"
  + ","  + "Количество"
  + ","  + "Цена"
  + ","  + "Стоимость"
  + ","  + "НДС"
  + ","  + "НП"
  + ","  + "Цена без НДС"
  + ","  + "Сумма без НДС".

 sheetf.Sizes        =  "10,16,40,6,5,15,15,15,15,15,15,15"                      .
 sheetf.make-correct = ""
 /* "true,true,true,true,true,true,true,true,true,true" */
 .
 sheetf.ColFormat = "2=@;3=@;" .
END PROCEDURE.
{ rep/tpcrr-b.i }

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