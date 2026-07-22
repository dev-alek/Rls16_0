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

Движение товара по месту хранени  (закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06

Created: 14/12/00
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Движение товара по месту хранени  (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.

define variable fo0    like ub.ot-tot.fact-order no-undo.
define variable fo02   like ub.ot-tot.fact-order no-undo.
define variable fo1    like ub.ot-tot.fact-order no-undo.
define variable fo12   like ub.ot-tot.fact-order no-undo.
define variable fo2    like ub.ot-tot.fact-order no-undo.
define variable fo22   like ub.ot-tot.fact-order no-undo.
define variable fo3    like ub.ot-tot.fact-order no-undo.
define variable fo32   like ub.ot-tot.fact-order no-undo.
define variable fo4    like ub.ot-tot.fact-order no-undo.
define variable fo42   like ub.ot-tot.fact-order no-undo.
define variable fo5    like ub.ot-tot.fact-order no-undo.
define variable fo52   like ub.ot-tot.fact-order no-undo.

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
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-6 RECT-9 SortType Classify ~
ShowZero Tog-Qnty ShowOrders tog-voz month-1 month-2 week-1 week-12 week-2 ~
week-22 week-3 week-32 week-4 week-42 week-5 week-52
&Scoped-Define DISPLAYED-OBJECTS SortType Classify ShowZero Tog-Qnty ~
ShowOrders tog-voz month-1 month-2 week-1 week-12 week-2 week-22 week-3 ~
week-32 week-4 week-42 week-5 week-52

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE BsAmount AS INTEGER FORMAT ">>9":U INITIAL 10
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1 TOOLTIP "Количество товаров с максимальной реализацмей" NO-UNDO.

DEFINE VARIABLE month-1 AS DATE FORMAT "99/99/9999":U
     LABEL "Месяц c"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE month-2 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE var-lavel AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE week-1 AS DATE FORMAT "99/99/9999":U
     LABEL "Неделя 1 с"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE week-12 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE week-2 AS DATE FORMAT "99/99/9999":U
     LABEL "Неделя 2 с"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE week-22 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE week-3 AS DATE FORMAT "99/99/9999":U
     LABEL "Неделя 3 с"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE week-32 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE week-4 AS DATE FORMAT "99/99/9999":U
     LABEL "Неделя 4 c"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE week-42 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE week-5 AS DATE FORMAT "99/99/9999":U
     LABEL "Неделя 5 с"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE week-52 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Производители", "prod":U,
"Группы товаров", "grp-goods":U,
"Производители/Группы товаров", "prod/grp-goods":U,
"Группы товаров/Производители", "grp-goods/prod":U,
"Ставка НДС", "vat-ps":U
     SIZE 30.88 BY 5.13 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по реализации", "sort-qunty":U
     SIZE 16.25 BY 2.63 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40.75 BY 9.21.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 27.75 BY 9.21.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 68.5 BY 7.58.

DEFINE VARIABLE ShowOrders AS LOGICAL INITIAL no
     LABEL "Заказы детально ":L
     VIEW-AS TOGGLE-BOX
     SIZE 18.38 BY .83 NO-UNDO.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Нулевые заказы":L
     VIEW-AS TOGGLE-BOX
     SIZE 16.88 BY .83 NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY 1 NO-UNDO.

DEFINE VARIABLE Tog-Qnty AS LOGICAL INITIAL no
     LABEL "Показать первые":L
     VIEW-AS TOGGLE-BOX
     SIZE 17.63 BY 1 TOOLTIP "Показать с наибольшей реализацией" NO-UNDO.

DEFINE VARIABLE tog-voz AS LOGICAL INITIAL yes
     LABEL "Внешний возврат"
     VIEW-AS TOGGLE-BOX
     SIZE 17.75 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SortType AT ROW 2.33 COL 42.75 NO-LABEL
     Classify AT ROW 2.5 COL 2.25 NO-LABEL
     Tog-lavel AT ROW 4 COL 21.5
     var-lavel AT ROW 4.04 COL 32.75 COLON-ALIGNED NO-LABEL
     ShowZero AT ROW 6.33 COL 42.75
     BsAmount AT ROW 7.13 COL 59 COLON-ALIGNED NO-LABEL
     Tog-Qnty AT ROW 7.17 COL 42.75
     ShowOrders AT ROW 8.21 COL 42.75
     tog-voz AT ROW 9.08 COL 42.75
     month-1 AT ROW 11.25 COL 12.13 COLON-ALIGNED
     month-2 AT ROW 11.25 COL 31.88 COLON-ALIGNED
     week-1 AT ROW 12.25 COL 12.13 COLON-ALIGNED
     week-12 AT ROW 12.29 COL 31.88 COLON-ALIGNED
     week-2 AT ROW 13.25 COL 12.13 COLON-ALIGNED
     week-22 AT ROW 13.29 COL 31.88 COLON-ALIGNED
     week-3 AT ROW 14.29 COL 12.13 COLON-ALIGNED
     week-32 AT ROW 14.33 COL 31.88 COLON-ALIGNED
     week-4 AT ROW 15.38 COL 12.13 COLON-ALIGNED
     week-42 AT ROW 15.42 COL 31.88 COLON-ALIGNED
     week-5 AT ROW 16.42 COL 12.13 COLON-ALIGNED
     week-52 AT ROW 16.46 COL 31.88 COLON-ALIGNED
     "Классификация :":C39 VIEW-AS TEXT
          SIZE 38.75 BY .75 AT ROW 1.46 COL 2.25
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          SIZE 13.63 BY .75 AT ROW 1.46 COL 42.88
          FGCOLOR 4
     "Показать :" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 5.25 COL 42.75
          FGCOLOR 4
     "Интервалы просмотра реализации":C45 VIEW-AS TEXT
          SIZE 45.75 BY .67 AT ROW 10.33 COL 2.25
          FGCOLOR 4
     RECT-5 AT ROW 1 COL 1
     RECT-6 AT ROW 1 COL 41.88
     RECT-9 AT ROW 10.13 COL 1
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
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN BsAmount IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX Tog-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN var-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
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
   if Classify = "grp-goods":U
         Then do:
            display TOG-lavel   with frame {&FRAME-NAME} .
            enable  TOG-lavel   with frame {&FRAME-NAME} .
        end.
         Else do:
            TOG-lavel = false.
            display  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
            disable  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
        end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ShowOrders
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ShowOrders s-object
ON VALUE-CHANGED OF ShowOrders IN FRAME F-Main /* Заказы детально  */
DO:
  assign showorders.
  if showorders = true then DO:
  disable week-1 week-12 week-2 week-22 week-3 week-32 week-4 week-42 week-5 week-52
     with frame {&frame-name}.
  End.
  Else DO:
    enable week-1 week-12 week-2 week-22 week-3 week-32 week-4 week-42 week-5 week-52
     with frame {&frame-name}.
end.
display  week-1 week-12 week-2 week-22 week-3 week-32 week-4 week-42 week-5 week-52
     with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-lavel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-lavel s-object
ON VALUE-CHANGED OF Tog-lavel IN FRAME F-Main /* с уровня */
DO:
   Assign tog-lavel.
  if tog-lavel =TRUE
        Then do:
            display  var-Lavel  with frame {&FRAME-NAME} .
            enable   var-Lavel  with frame {&FRAME-NAME} .
        end.
         Else do:
            display    var-Lavel with frame {&FRAME-NAME} .
            disable    var-Lavel with frame {&FRAME-NAME} .
        end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-Qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-Qnty s-object
ON VALUE-CHANGED OF Tog-Qnty IN FRAME F-Main /* Показать первые */
DO:
 define variable ret# as log no-undo.

  Assign tog-QNTY.
  if tog-QNTY =TRUE
        Then do:
            display  bsAmount  with frame {&FRAME-NAME} .
            enable   bsAmount  with frame {&FRAME-NAME} .
            Ret# = Sorttype:enable(Entry(5,Sorttype:radio-buttons)).
            Ret# = Classify:Disable(Entry(3,Classify:radio-buttons)).
            Ret# = Classify:Disable(Entry(5,Classify:radio-buttons)).
            Ret# = Classify:Disable(Entry(7,Classify:radio-buttons)).
            Ret# = Classify:Disable(Entry(9,Classify:radio-buttons)).
            Ret# = Classify:Disable(Entry(11,Classify:radio-buttons)).

        end.
         Else do:
            display    bsAmount with frame {&FRAME-NAME} .
            disable    bsAmount with frame {&FRAME-NAME} .
            Ret# = Classify:enable(Entry(3,Classify:radio-buttons)).
            Ret# = Classify:enable(Entry(5,Classify:radio-buttons)).
            Ret# = Classify:enable(Entry(7,Classify:radio-buttons)).
            Ret# = Classify:enable(Entry(9,Classify:radio-buttons)).
            Ret# = Classify:enable(Entry(11,Classify:radio-buttons)).
            Ret# = Sorttype:Disable(Entry(5,Sorttype:radio-buttons)).

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
{ gbl/ed_date.i "month-1, month-2, week-1, week-12, week-2, week-22, week-3, week-32, week-4, week-42, week-5, week-52" " " "disable" }

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-fo s-object
PROCEDURE find-fo :
define input  parameter date1 as date no-undo.
define input  parameter date2 as date no-undo.
define output parameter f-1   like ub.ot-line.fact-order no-undo.
define output parameter f-2   like ub.ot-line.fact-order no-undo.
   Assign f-1 = Integer(date1 - 1) + 0.99  f-2 = Integer(date2)  + 0.99.

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
 run cus/r-benet1.p
                 (input v-cntxt-obj-code,
                  input v-cntxt-obj-type,
                  input base-type ,
                  input base-code ,
                  input Classify  ,
                  input SortType  ,
                  input false     ,
                  input ShowZero  ,
                  input True      ,
                  input false     ,
                  input false     ,
                  input tog-lavel ,
                  input var-lavel ,
                  input fo0  ,
                  input fo02 ,
                  input fo1  ,
                  input fo12 ,
                  input fo2  ,
                  input fo22 ,
                  input fo3  ,
                  input fo32 ,
                  input fo4  ,
                  input fo42 ,
                  input fo5  ,
                  input fo52 ,
                  input Tog-Qnty,
                  input bsamount  ,
                  input tog-voz , ShowOrders ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
define variable v-check-date as date no-undo.

  define variable v-archive-ok as logical   no-undo .
  define variable v-comment    as character no-undo .
  define variable v-can-print  as logical   no-undo .

/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name}  ShowZero tog-qnty bsamount ShowOrders
tog-lavel var-lavel Classify SortType tog-voz
month-1
month-2
week-1
week-12
week-2
week-22
week-3
week-32
week-4
week-42
week-5
week-52
.
if
month-1 = ? OR
month-2 = ? OR
week-1  = ? OR
week-12 = ? OR
week-2  = ? OR
week-22 = ? OR
week-3  = ? OR
week-32 = ? OR
week-4  = ? OR
week-42 = ? OR
week-5  = ? OR
week-52 = ?  THEN DO:
     MEssage 'Не заданы интервалы просмотра реализации ! ' view-as alert-box error.
     RETURN 'Second-page':U  . End.

/*строки в которых содержатся выбранные объекты */
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.


ReportNAme = "Д В И Ж Е Н И Е   Т О В А Р А".
{ rep/claslabl.i }
ReportHeader = "Классификация : " + t-Class.
ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня  "  + String(var-lavel)  else " "    ).

ReportHeader = ReportHeader +
               (if tog-voz  then {&new-line} + "Включая  " + {&TDEDT_Vozvrat_Vnesh-full}  else " "    ).

ReportHeader = ReportHeader + {&new-line}.

ReportHeader = ReportHeader + "Интервалы реализации :" + {&new-line}.
ReportHeader = ReportHeader  + if month-1 <> DATE('') THEN  " Месяц с " + String(month-1,"99.99.9999")            ELSE "" .
ReportHeader = ReportHeader  + if month-2 <> DATE('')   THEN  " по " + String(month-2,"99.99.9999")      + {&new-line} ELSE "" .

  if showorders = false then do:
    assign
      ReportHeader = ReportHeader  + (if week-1  <> DATE('')   THEN  " 1я неделя " + String(week-1,"99.99.9999")          ELSE "" )
      ReportHeader = ReportHeader  + (if week-12 <> DATE('')   THEN  " по " + String(week-12,"99.99.9999")      + {&new-line} ELSE "" )
      ReportHeader = ReportHeader  + (if week-2  <> DATE('')   THEN  " 2я неделя " + String(week-2,"99.99.9999")          ELSE "" )
      ReportHeader = ReportHeader  + (if week-22 <> DATE('')   THEN  " по " + String(week-22,"99.99.9999")      + {&new-line} ELSE "" )
      ReportHeader = ReportHeader  + (if week-3  <> DATE('')   THEN  " 3я неделя " + String(week-3,"99.99.9999")          ELSE "" )
      ReportHeader = ReportHeader  + (if week-32 <> DATE('')   THEN  " по " + String(week-32,"99.99.9999")      + {&new-line} ELSE "" )
      ReportHeader = ReportHeader  + (if week-4  <> DATE('')   THEN  " 4я неделя " + String(week-4,"99.99.9999")          ELSE "" )
      ReportHeader = ReportHeader  + (if week-42 <> DATE('')   THEN  " по " + String(week-42,"99.99.9999")      + {&new-line} ELSE "" )
      ReportHeader = ReportHeader  + (if week-5  <> DATE('')   THEN  " 5я неделя " + String(week-5,"99.99.9999")          ELSE "" )
      ReportHeader = ReportHeader  + (if week-52 <> DATE('')   THEN  " по " + String(week-52,"99.99.9999")      + {&new-line} ELSE "" )
    .
  end.

  assign
    ReportHeader = ReportHeader +
                  "Сортировка " + t-Sort + {&new-line} +
                  "Показать : " +
                  (if ShowZero     then "Показывать нулевые заказы "  else "Не показывать нулевые заказы" )
  .

  assign
    ReportHeader = ReportHeader +
                  (if Tog-Qnty    then "   Показать первые   "   + StrinG(BsAmount) +  " товаров с максимальной среднесуточной реализацией "  else "" )
  .

  assign
    ReportHeader = ReportHeader +
                  (if Showorders   then "   Показать подробно заказы   "     else "" )
  .

  assign
    v-check-date = maximum(month-1
                          ,month-2
                          ,week-1
                          ,week-12
                          ,week-2
                          ,week-22
                          ,week-3
                          ,week-32
                          ,week-4
                          ,week-42
                          ,week-5
                          ,week-52 )
  .
  run rep/chk-ahz.p
    (input        v-cntxt-obj-type /* p-obj-type          */
    ,input        v-cntxt-obj-code /* p-obj-code          */
    ,input        false            /* p-verify-detail     */
    ,input        true             /* p-verify-arh        */
    ,input        false            /* p-verify-ahsp       */
    ,input        false            /* p-verify-aht        */
    ,input        true             /* p-check-act         */
    ,input        v-cntxt-db-num   /* p-check-act-db-num  */
    ,input        v-cntxt-userid   /* p-check-act-user-id */
    ,input-output v-check-date     /* p-date-start        */
    ,input-output v-check-date     /* p-date-end          */
    ,output       v-archive-ok     /* p-archive-ok        */
    ,output       v-comment        /* p-comment           */
    ,output       v-can-print      /* p-can-print         */
    ).

  run find-fo in this-procedure
    (input  month-1
    ,input  month-2
    ,output fo0
    ,output fo02
    ).
  run find-fo in this-procedure
    (input  week-1
    ,input  week-12
    ,output fo1
    ,output fo12
    ).
  run find-fo in this-procedure
    (input  week-2
    ,input  week-22
    ,output fo2
    ,output fo22
    ).
  run find-fo in this-procedure
    (input  week-3
    ,input  week-32
    ,output fo3
    ,output fo32
    ).
  run find-fo in this-procedure
    (input  week-4
    ,input  week-42
    ,output fo4
    ,output fo42
    ).
  run find-fo in this-procedure
    (input  week-5
    ,input  week-52
    ,output fo5
    ,output fo52
    ).

  if showorders = false
  then do:
    assign
      sheetf.Excel-Column-Lable = "№,Артикул,Заказ,Центральный склад, Приход, Остаток,Реализизация Среднесуточная,Касса за месяц,Касса за 1ю неделю ,Касса за 2ю неделю ,Касса за 3ю неделю ,Касса за 4ю неделю ,Касса за 5ю неделю "
      sheetf.Sizes = '10,16,13,13,13,13,16,13,13,13,13,13,13,'
    .
  end.
  else do:
    assign
      sheetf.Excel-Column-Lable = "№,Артикул,Суммарный Заказ,Центральный склад, Приход, Остаток,Реализация Среднесуточная,Касса за месяц,"
      sheetf.Sizes = '10,16,15,15,15,15,16,15,'
    .
  end.

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

  define variable nn as int no-undo.
  define variable ret# as log no-undo.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      /* link-changed */
  END CASE.





if month-1 = ? THEN   month-1 = DAte(month(x-Date-Start ),1,year(x-Date-Start )).
if month-2 = ? THEN   DO:
    month-2 = x-Date-Start  .
    run gbl/lastdate.p
      (input  month-2
      ,output month-2  ).
    End.
NN = Weekday(DAte(month(month-1 ),1,year(month-1)))  . /*ближайший понедельник*/
if week-1  = ? THEN   week-1  = month-1 + (2 - NN)                           .
if week-12 = ? THEN   week-12 = week-1 +  6                                  .
if week-2  = ? THEN   week-2  = week-12 + 1                                  .
if week-22 = ? THEN   week-22 = week-2  + 6                                  .
if week-3  = ? THEN   week-3  = week-22 + 1                                  .
if week-32 = ? THEN   week-32 = week-3  + 6                                  .
if week-4  = ? THEN   week-4  = week-32 + 1                                  .
if week-42 = ? THEN   week-42 = week-4  + 6                                  .
if week-5  = ? THEN   week-5  = week-42 + 1                                  .
if week-52 = ? THEN   week-52 = week-5 + 6                                   .

display month-1 month-2 week-1 week-12 week-2 week-22 week-3 week-32 week-4 week-42 week-5 week-52 with frame {&frame-name}.
  if tog-QNTY =TRUE
        Then do:
            Ret# = Sorttype:enable(Entry(5,Sorttype:radio-buttons)).

            Ret# = Classify:Disable(Entry(3,Classify:radio-buttons)).
            Ret# = Classify:Disable(Entry(5,Classify:radio-buttons)).
            Ret# = Classify:Disable(Entry(7,Classify:radio-buttons)).
            Ret# = Classify:Disable(Entry(9,Classify:radio-buttons)).
            Ret# = Classify:Disable(Entry(11,Classify:radio-buttons)).


        end.
         Else do:
            Ret# = Classify:enable(Entry(3,Classify:radio-buttons)).
            Ret# = Classify:enable(Entry(5,Classify:radio-buttons)).
            Ret# = Classify:enable(Entry(7,Classify:radio-buttons)).
            Ret# = Classify:enable(Entry(9,Classify:radio-buttons)).
            Ret# = Classify:enable(Entry(11,Classify:radio-buttons)).

            Ret# = Sorttype:Disable(Entry(5,Sorttype:radio-buttons)).
        end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
