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

Отчет по продажам ниже учетной цены

Автор: Демин Алексей Сергеевич
Дата создания: 09/16/05
Author: Alexey Demin
Creation date: 09/16/05

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет по продажам ниже учетной цены  (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
{ cmp/str-glbl.i }
{ cmp/r-page1.i }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get  }


  define variable g#userid as character no-undo .
  run get-userid  in parParentProc ( output g#userid ).

def var fo0    like ot-tot.fact-order no-undo.
def var fo02   like ot-tot.fact-order no-undo.
def var fo1    like ot-tot.fact-order no-undo.
def var fo12   like ot-tot.fact-order no-undo.
def var fo2    like ot-tot.fact-order no-undo.
def var fo22   like ot-tot.fact-order no-undo.
def var fo3    like ot-tot.fact-order no-undo.
def var fo32   like ot-tot.fact-order no-undo.
def var fo4    like ot-tot.fact-order no-undo.
def var fo42   like ot-tot.fact-order no-undo.
def var fo5    like ot-tot.fact-order no-undo.
def var fo52   like ot-tot.fact-order no-undo.
define variable ParamStr as character no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-9 RECT-6 SortType1 Classify ~
month-3 month-4 DetalWeek month-1 month-2 week-1 week-12 week-2 week-22 ~
week-3 week-32 week-4 week-42 week-5 week-52 BUTTON-1 
&Scoped-Define DISPLAYED-OBJECTS SortType1 Classify Itog month-3 month-4 ~
DetalWeek month-1 month-2 week-1 week-12 week-2 week-22 week-3 week-32 ~
week-4 week-42 week-5 week-52 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-1 
     LABEL "Колонки для отчета" 
     SIZE 21.5 BY 1.13.

DEFINE VARIABLE month-1 AS DATE FORMAT "99/99/9999":U 
     LABEL "Реализация c" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE month-2 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE month-3 AS DATE FORMAT "99/99/9999":U 
     LABEL "Сред. суточ. реализ. c" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE month-4 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-1 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 1 с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-12 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-2 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 2 с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-22 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-3 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 3 с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-32 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-4 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 4 c" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-42 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-5 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 5 с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE week-52 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Без классификации", "no-classify":U,
"Группы товаров", "grp-goods":U
     SIZE 19.75 BY 2.21
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE DetalWeek AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Понедельно", 1,
"Помесячно", 2
     SIZE 17.63 BY 2.21
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE SortType1 AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "по кол-ву реализов.", 1,
"по кол-ву заказанного", 2,
"по кол-ву оставшегося", 3
     SIZE 25.25 BY 3.13
     FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 40.75 BY 4.92.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 27.75 BY 4.92.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 68.5 BY 9.54.

DEFINE VARIABLE Itog AS LOGICAL INITIAL no 
     LABEL "Только итоги":L 
     VIEW-AS TOGGLE-BOX
     SIZE 16.88 BY .83
     FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SortType1 AT ROW 2.33 COL 42.75 NO-LABEL
     Classify AT ROW 2.5 COL 2.25 NO-LABEL
     Itog AT ROW 3.88 COL 22.75
     month-3 AT ROW 7.67 COL 24.38 COLON-ALIGNED
     month-4 AT ROW 7.71 COL 40.88 COLON-ALIGNED
     DetalWeek AT ROW 9.08 COL 47.88 NO-LABEL
     month-1 AT ROW 9.13 COL 14.25 COLON-ALIGNED
     month-2 AT ROW 9.13 COL 31.5 COLON-ALIGNED
     week-1 AT ROW 10.08 COL 14.38 COLON-ALIGNED
     week-12 AT ROW 10.17 COL 31.5 COLON-ALIGNED
     week-2 AT ROW 11.08 COL 14.38 COLON-ALIGNED
     week-22 AT ROW 11.17 COL 31.5 COLON-ALIGNED
     week-3 AT ROW 12.13 COL 14.38 COLON-ALIGNED
     week-32 AT ROW 12.21 COL 31.5 COLON-ALIGNED
     week-4 AT ROW 13.21 COL 14.38 COLON-ALIGNED
     week-42 AT ROW 13.29 COL 31.5 COLON-ALIGNED
     week-5 AT ROW 14.25 COL 14.38 COLON-ALIGNED
     week-52 AT ROW 14.33 COL 31.5 COLON-ALIGNED
     BUTTON-1 AT ROW 16.29 COL 6
     "Классификация :":C39 VIEW-AS TEXT
          SIZE 38.75 BY .75 AT ROW 1.46 COL 2.25
          FGCOLOR 4 
     "Интервалы просмотра реализации":C45 VIEW-AS TEXT
          SIZE 45.75 BY .67 AT ROW 6.71 COL 1.75
          FGCOLOR 4 
     "Сортировка :" VIEW-AS TEXT
          SIZE 13.63 BY .75 AT ROW 1.46 COL 42.88
          FGCOLOR 4 
     RECT-5 AT ROW 1 COL 1
     RECT-9 AT ROW 6.38 COL 1.25
     RECT-6 AT ROW 1 COL 41.88
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

/* SETTINGS FOR TOGGLE-BOX Itog IN FRAME F-Main
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
ON CHOOSE OF BUTTON-1 IN FRAME F-Main /* Колонки для отчета */
DO:
  /* Процедура задания колонок в отчете */
  run rep/askfld2.w (input-output ParamStr) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify s-object
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
    Assign Classify.
   if Classify = "grp-goods":U
         Then do:
            display Itog   with frame {&FRAME-NAME} .
            enable  Itog   with frame {&FRAME-NAME} .
        end.
         Else do:
            Itog = false.
            display  Itog  with frame {&FRAME-NAME} .
            disable  Itog  with frame {&FRAME-NAME} .
        end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME DetalWeek
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DetalWeek s-object
ON VALUE-CHANGED OF DetalWeek IN FRAME F-Main
DO:
Assign DetalWeek.
  if DetalWeek = 1 then do:
    enable  week-1 week-2 week-3 week-4 week-5 week-12 week-22 week-32 week-42 week-52 with frame {&FRAME-NAME} .
  end.
  else do:
/*    message*/
/*      "Временно работает только понедельный отчет"*/
/*      view-as alert-box.*/
/*      assign  DetalWeek = 1 .*/
/*      display DetalWeek with frame {&frame-name}.*/
    disable week-1 week-2 week-3 week-4 week-5 week-12 week-22 week-32 week-42 week-52 with frame {&FRAME-NAME} .
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

{ gbl/ed_date.i "month-1, month-2, month-3, month-4, week-1, week-12, week-2, week-22, week-3, week-32, week-4, week-42, week-5, week-52" " " "disable" }
/* month-3, month-4, */

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
def input  parameter date1 as date no-undo.
def input  parameter date2 as date no-undo.
def output parameter f-1   like ot-line.fact-order no-undo.
def output parameter f-2   like ot-line.fact-order no-undo.
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

  disable  Itog  with frame {&FRAME-NAME} .
  assign
    month-3 :screen-value in frame {&frame-name} = string(x-Date-Start,"99/99/9999")
    month-4 :screen-value in frame {&frame-name} = string(x-Date-End,"99/99/9999")
  .
  /* Code placed here will execute AFTER standard behavior.    */
 find first ubflt.usr-flt no-lock
   where ubflt.usr-flt.user-name = g#userid
     and ubflt.usr-flt.call-point   = "e-ben-dt":U
 no-error .
 if available ubflt.usr-flt then do:
   assign
     ParamStr = ubflt.usr-flt.list_
   .
 end.
 else run rep/askfld2.w (input-output ParamStr) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
 run rep/r-ben-dt.p  (
   input  SortType1,
   input  Classify ,
   input  DetalWeek,
   input  Itog ,
   input  month-1  ,
   input  month-2  ,
   input  month-3  ,
   input  month-4  ,
   input  week-1   ,
   input  week-12  ,
   input  week-2   ,
   input  week-22  ,
   input  week-3   ,
   input  week-32  ,
   input  week-4   ,
   input  week-42  ,
   input  week-5   ,
   input  week-52  ,
   input  ParamStr
   ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
define variable v-check-date as date      no-undo .
  define variable v-archive-ok as logical   no-undo .
  define variable v-comment    as character no-undo .
  define variable v-can-print  as logical   no-undo .


define variable NumObj as integer initial 0  no-undo .
define variable NumWeek as integer initial 0  no-undo .
define variable NumPrice as integer initial 0  no-undo .
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} Itog DetalWeek Classify SortType1 month-1 month-2 month-3 month-4 week-1 week-12 week-2 week-22
                           week-3 week-32 week-4 week-42 week-5 week-52 .

if week-1 <> ? and week-12 <> ? then NumWeek = NumWeek + 1 .
if week-2 <> ? and week-22 <> ? then NumWeek = NumWeek + 1 .
if week-3 <> ? and week-32 <> ? then NumWeek = NumWeek + 1 .
if week-4 <> ? and week-42 <> ? then NumWeek = NumWeek + 1 .
if week-5 <> ? and week-52 <> ? then NumWeek = NumWeek + 1 .
  if DetalWeek = 1 and NumWeek = 0 then do:
    message 'Не заданы понедельные интервалы просмотра реализации ! ' view-as alert-box error.
    return 'second-page':u  .
  end.

/*строки в которых содержатся выбранные объекты */
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

For each obj-list no-lock:
  Assign
    NumObj = NumObj + 1
    STR-obj-type = STR-obj-type + obj-list.obj-type + ','
    STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
    STR-obj-name = STR-obj-name + obj-list.obj-name + ','
    STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.


ReportNAme = "Д В И Ж Е Н И Е   Т О В А Р А".
/*{ rep/claslabl.i }*/
def var t-class as char no-undo.
  CASE Classify:
    WHEN "no-classify":U    THEN t-class =   "Без классификации" .
    WHEN "grp-goods":U      THEN t-class =   "Группы товаров"  .
 End case.
ReportHeader = "Классификация : " + t-Class.
ReportHeader = ReportHeader + chr(10).

if x-SET_val_TYPE = 1 then ReportHeader = ReportHeader + "Цены указаны в: {&abbr_rublyah}" + chr(10).
else                       ReportHeader = ReportHeader + "Цены указаны в: валюте" + chr(10).

ReportHeader = ReportHeader + "Интервал реализации : " .
ReportHeader = ReportHeader  + if month-1 <> DATE('') THEN  " с " + String(month-1,"99.99.9999")            ELSE "" .
ReportHeader = ReportHeader  + if month-2 <> DATE('') THEN  " по " + String(month-2,"99.99.9999")      + chr(10) ELSE "" .

  if DetalWeek = 1 then do:
    ReportHeader = ReportHeader  + if week-1  <> DATE('')   THEN  " 1я неделя " + String(week-1,"99.99.9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-12 <> DATE('')   THEN  " по " + String(week-12,"99.99.9999")      + chr(10) ELSE ""  .
    ReportHeader = ReportHeader  + if week-2  <> DATE('')   THEN  " 2я неделя " + String(week-2,"99.99.9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-22 <> DATE('')   THEN  " по " + String(week-22,"99.99.9999")      + chr(10) ELSE ""  .
    ReportHeader = ReportHeader  + if week-3  <> DATE('')   THEN  " 3я неделя " + String(week-3,"99.99.9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-32 <> DATE('')   THEN  " по " + String(week-32,"99.99.9999")      + chr(10) ELSE ""  .
    ReportHeader = ReportHeader  + if week-4  <> DATE('')   THEN  " 4я неделя " + String(week-4,"99.99.9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-42 <> DATE('')   THEN  " по " + String(week-42,"99.99.9999")      + chr(10) ELSE ""  .
    ReportHeader = ReportHeader  + if week-5  <> DATE('')   THEN  " 5я неделя " + String(week-5,"99.99.9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-52 <> DATE('')   THEN  " по " + String(week-52,"99.99.9999")      + chr(10) ELSE "" .
  end.
  else do:
    ReportHeader = ReportHeader  + "реализация с разбивкой по месяцам"  + chr(10) .
  end.
ReportHeader = ReportHeader + "Интервал среднесуточной реализации : " .
ReportHeader = ReportHeader  + if month-3 <> DATE('') THEN  " с " + String(month-3,"99.99.9999")            ELSE "" .
ReportHeader = ReportHeader  + if month-4 <> DATE('') THEN  " по " + String(month-4,"99.99.9999")      + chr(10) ELSE "" .

  define variable t-Sort as character no-undo .
  case SortType1 :
    when 1 then  t-Sort = "по кол-ву реализованного" .
    when 2 then  t-Sort = "по кол-ву заказанного" .
    when 3 then  t-Sort = "по кол-ву остатков" .
  end.
  ReportHeader = ReportHeader + "Сортировка " + t-Sort .

  assign
    v-check-date = maximum( month-1 ,
                      month-2 ,
                      week-1  ,
                      week-12 ,
                      week-2  ,
                      week-22 ,
                      week-3  ,
                      week-32 ,
                      week-4  ,
                      week-42 ,
                      week-5  ,
                      week-52 )
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

 /* временная  заглушка */
/*  DO ii = 1 TO 20 :*/
/*    assign use-column1 [ii] = no .*/
/*  end.*/
/* assign*/
/*   Use-column[1]  = yes*/
/*   Use-column[2]  = yes*/
/*   Use-column[3]  = yes*/
/*   Use-column[4]  = no*/
/*   Use-column[5]  = yes*/
/*   Use-column[6]  = no*/
/*   Use-column[7]  = no*/
/*   Use-column[8]  = no*/
/*   Use-column[9]  = no*/
/*   Use-column[10] = no*/
/*   Use-column[11] = yes*/
/*   Use-column[12] = yes*/
/*   Use-column[13] = yes*/
/*   Use-column[14] = yes*/
/*   Use-column[15] = yes*/
/*   Use-column[16] = no*/
/*   Use-column[17] = no*/
/*   Use-column[18] = no*/
/* .*/

/*  End.*/
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

  def var nn as int no-undo.
  def var ret# as log no-undo.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      /* link-changed */
  END CASE.

if month-1 = ? THEN   month-1 = DAte(month(x-Date-Start ),1,year(x-Date-Start )).
if month-2 = ? THEN   DO:
    month-2 = x-Date-End  .
/*    run gbl/lastdate.p*/
/*      (input  month-2*/
/*      ,output month-2  ).*/
    End.
      Nn = Weekday(Date(Month(Month-1 ),1,Year(Month-1)))  . /*ближайший понедельник*/
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

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

