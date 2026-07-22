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

Бестселлеры

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Created: 10/11/00

*/

/*
 {&bs-1}, {&bs-1},
 {&bs-2}, {&bs-2},
 {&bs-3}, {&bs-3},
 {&bs-4}, {&bs-4},
 {&bs-5}, {&bs-5},
 {&bs-6}, {&bs-6}
  */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Бестселлеры".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ rep/rep-bt.i  }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .
def var     scale_recid       as  recid    no-undo.
DEF var Sort as int no-undo.
DEF var Crit as int no-undo.
DEF var Sc-node like gds-prt.node-code no-undo.
DEF var Sc-upper like gds-prt.upper-code no-undo.

&glob bs-1    "Макс. количество"
&glob bs-2    "Макс. сумма продаж в учетных ценах"
&glob bs-3    "Макс. сумма продаж в ценах док-та"
&glob bs-4    "Макс. эффективность"
&glob bs-5    "Макс. количество по кассе"
&glob bs-6    "Макс. сумма по кассе в ценах док-та"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-11 RECT-12 COMBO-crit COMBO-Sort ~
RECT-10 Tog-Scale Sc_Name BSAmount FILL-IN-1 
&Scoped-Define DISPLAYED-OBJECTS COMBO-crit COMBO-Sort Tog-Scale Sc_Name ~
Scale BSAmount FILL-IN-1 


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE Sc_Name AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL
     SIZE 49 BY 1.83
     BGCOLOR 8 FONT 4 NO-UNDO.

DEFINE VARIABLE BSAmount AS INTEGER FORMAT ">>>>9":U INITIAL 10
     LABEL "Сколько показать товаров"
     VIEW-AS FILL-IN
     SIZE 6.88 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Шкалы:"
      VIEW-AS TEXT
     SIZE 7.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE COMBO-crit AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
 {&bs-1}, {&bs-1},
 {&bs-2}, {&bs-2},
 {&bs-3}, {&bs-3},
 {&bs-4}, {&bs-4},
 {&bs-5}, {&bs-5},
 {&bs-6}, {&bs-6}

     SIZE 47.13 BY 5.17 NO-UNDO.

DEFINE VARIABLE COMBO-Sort AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
 {&bs-1}, {&bs-1},
 {&bs-2}, {&bs-2},
 {&bs-3}, {&bs-3},
 {&bs-4}, {&bs-4},
 {&bs-5}, {&bs-5},
 {&bs-6}, {&bs-6}

     SIZE 47.75 BY 5.13 NO-UNDO.

DEFINE VARIABLE Scale AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все", {&all} ,
"Выбор шкалы", "Choice-scala":U
     SIZE 14.88 BY 1.58 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.63 BY 3.75.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.63 BY 12.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.63 BY 16.75.

DEFINE VARIABLE Tog-Scale AS LOGICAL INITIAL no
     LABEL "По признакам"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 NO-UNDO.



/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     COMBO-crit AT ROW 1.79 COL 3 NO-LABEL
     COMBO-Sort AT ROW 7.79 COL 2.88 NO-LABEL
     Tog-Scale AT ROW 13.83 COL 2.5
     Sc_Name AT ROW 14.5 COL 19.88 NO-LABEL
     Scale AT ROW 14.83 COL 3 NO-LABEL
     BSAmount AT ROW 16.79 COL 26.63 COLON-ALIGNED
     FILL-IN-1 AT ROW 13.04 COL 4.38 COLON-ALIGNED NO-LABEL
     RECT-11 AT ROW 1 COL 1.38
     RECT-12 AT ROW 1.04 COL 1.38
     "Критерий отбора" VIEW-AS TEXT
          SIZE 29.13 BY .67 AT ROW 1.13 COL 3.25
          FGCOLOR 4
     "Сортировка" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 7.08 COL 2.75
          FGCOLOR 4
     RECT-10 AT ROW 12.92 COL 1.38
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "should only be RUN PERSISTENT."
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.83
         WIDTH              = 68.63.
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
       FRAME F-Main:HIDDEN           = TRUE
       FRAME F-Main:PRIVATE-DATA     =
                "DLGCLOSE".

ASSIGN
       FILL-IN-1:HIDDEN IN FRAME F-Main           = false .

/* SETTINGS FOR RADIO-SET Scale IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       Scale:HIDDEN IN FRAME F-Main           = false .

ASSIGN
       Sc_Name:READ-ONLY IN FRAME F-Main        = false .

ASSIGN
       Tog-Scale:HIDDEN IN FRAME F-Main            = false  .

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

&Scoped-define SELF-NAME Scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Scale s-object
ON VALUE-CHANGED OF Scale IN FRAME F-Main
DO:
    assign Scale .
    Sc-node = 0.
    Sc-Upper = 0 .
    if Scale = "Choice-scala":U then
    do:
             run ref/gdsprts.w (my-handle, yes, output scale_recid).
             if scale_recid = ? then
             do:
                  Scale:screen-value = {&all} .
                  Sc_Name:screen-value IN FRAME {&FRAME-NAME} = {&all} .
                  Sc-node = 0.
                  Sc-Upper = 0.
             end.
             else
             do:
                  find first gds-prt where recid (gds-prt) = scale_recid.
                  Sc_Name:screen-value IN FRAME {&FRAME-NAME} = gds-prt.node-name.
                  Sc-node = gds-prt.node-code.
                  Sc-Upper = gds-prt.upper-code.
             end.
    end.
    else
             Sc_Name:screen-value IN FRAME {&FRAME-NAME} = {&all} .
 aSSIGN Sc_Name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-Scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-Scale s-object
ON VALUE-CHANGED OF Tog-Scale IN FRAME F-Main /* По признакам */
DO:
Assign Tog-scale.
IF Tog-scale = TRUE then DO:
   Enable Scale with frame {&FRAME-NAME} .

  End.
  Else DO:
   Disable Scale   with frame {&FRAME-NAME} .
   Display Scale  with frame {&FRAME-NAME} .
  End.
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
def var Ret# as logical no-undo .

  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  ASSIGN
   BSAmount:screen-value IN FRAME {&FRAME-NAME} = "10"

   COMBO-crit:screen-value IN FRAME {&FRAME-NAME} = {&bs-5}
   COMBO-Sort:screen-value IN FRAME {&FRAME-NAME} = {&bs-5}

   FILL-IN-1:screen-value IN FRAME {&FRAME-NAME}  = "Шкалы:"

   Scale:screen-value IN FRAME {&FRAME-NAME}      = {&all}
   Sc_Name:screen-value IN FRAME {&FRAME-NAME}    = {&all}
  .
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
   if not g#log then do:
      Ret# = COMBO-crit:Disable ({&bs-2}) .
      Ret# = COMBO-crit:Disable ({&bs-4}) .
      Ret# = COMBO-sort:Disable ({&bs-2}) .
      Ret# = COMBO-sort:Disable ({&bs-4}) .
   end.

   ENABLE BSAmount COMBO-crit COMBO-Sort FILL-IN-1 Scale  with frame {&FRAME-NAME} .
   DISPLAY BSAmount COMBO-crit COMBO-Sort FILL-IN-1 Scale  with frame {&FRAME-NAME} .


   /* WHITH FRAME {&FRAME-NAME}. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета
------------------------------------------------------------------------------*/
if BSAmount = ? or
   BSAmount = 0 then do:
  message "Задайте поле 'Сколько показать товаров' на второй закладке." view-as alert-box error.
  apply "entry" to BSAmount in frame {&frame-name}.
  return.
end.

 

 assign sheetf.Excel-Column-Lable = ""  sheetf.Sizes = "" .
    if use-column[1]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Код,"                     sheetf.Sizes              = sheetf.Sizes +  "10," .
    if use-column[2]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Артикул,"                 sheetf.Sizes              = sheetf.Sizes +  "16," .
    if use-column[3]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Название товара,"         sheetf.Sizes              = sheetf.Sizes +  "40," .
    if use-column[4]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Ед. изм,"                 sheetf.Sizes              = sheetf.Sizes +  "6," .
    if use-column[5]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Количество,"              sheetf.Sizes              = sheetf.Sizes +  "15," .
    if use-column[6]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "в т.ч. Касса,"            sheetf.Sizes              = sheetf.Sizes +  "15," .
    if use-column[7]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Сумма в учетных ценах,"        sheetf.Sizes              = sheetf.Sizes +  "15," .
    if use-column[8]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "в т.ч. Касса в учетных ценах,"          sheetf.Sizes              = sheetf.Sizes +  "15," .
    if use-column[9]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Сумма в ценах док-та,"          sheetf.Sizes              = sheetf.Sizes +  "15," .
    if use-column[10]   = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "в т.ч. Касса в ценах док-та,"          sheetf.Sizes              = sheetf.Sizes +  "15," .
    if use-column[11]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Эффективность ,"  sheetf.Sizes              = sheetf.Sizes +  "16," .
    if use-column[12]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "% (по критерию отбора),"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[13]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Количество (с учетом внеш.расходов),"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[14]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Сумма продажи в уч.ценах (с учетом внеш.расходов),"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[15]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Сумма продажи в ценах документа (с учетом внеш.расходов),"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[16]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Доля в доходах,"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[17]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Остаток на начало,"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[18]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Остаток на конец,"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[19]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Средняя учетная цена,"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[20]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Средняя цена продажи,"           sheetf.Sizes              = sheetf.Sizes +  "12," .  
    if use-column[21]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Наценка в руб.,"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[22]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Наценка в %,"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[23]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Оборачиваемость в днях,"           sheetf.Sizes              = sheetf.Sizes +  "12," .
    if use-column[24]  = yes then assign sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "Срок реализации остатка,"           sheetf.Sizes              = sheetf.Sizes +  "12," .
 
 
 if LENGTH( sheetf.Excel-Column-Lable ) > 0 then do:
   substr ( sheetf.Excel-Column-Lable, LENGTH( sheetf.Excel-Column-Lable )) = "" .
   substr ( sheetf.Sizes, LENGTH( sheetf.Sizes )) = "" .
 run rep/r-bestsl.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input crit ,
                  input Sort ,
                  input BSAmount ,
                  input Sc-node,
                  input Sc-upper,
                  input Tog-Scale
                  ).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки ???
------------------------------------------------------------------------------*/
assign frame {&frame-name}
        BSAmount COMBO-crit COMBO-Sort FILL-IN-1
        Sc_Name Scale Tog-Scale  .

v-show-all-goods  = false  .
/*строки в которых содержатся выбранные обекты */
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
 sheetf.Excel-Column-Lable =
              "Код        "
      + "," + "Артикул         "
      + "," + "Название товара "
      + "," + "Ед.изм "
      + "," + "Количество "
      + "," + "в т.ч. Касса "
      + "," + "Сумма в учетных ценах"
      + "," + "в т.ч. Касса в учетных ценах"
      + "," + "Сумма в ценах док-та" 
      + "," + "в т.ч. Касса в ценах док-та"
      + "," + "Эффективность "
      + "," + " % (по критерию отбора)" 
      + "," + "Количество (с учетом внеш.расходов)"
      + "," + "Сумма продажи в уч.ценах (с учетом внеш.расходов)"
      + "," + "Сумма продажи в ценах документа (с учетом внеш.расходов)"
      + "," + "Доля в доходах"
      + "," + "Остаток на начало"
      + "," + "Остаток на конец"
      + "," +  "Средняя учетная цена"
      + "," + "Средняя цена продажи"
      + "," + "Наценка в руб."
      + "," + "Наценка в %"
      + "," + "Оборачиваемость в днях"
      + "," + "Срок реализации остатка".
/*Количество (с учетом внеш.расходов)                     */
/*Сумма продажи в уч.ценах (с учетом внеш.расходов)       */
/*Сумма продажи в ценах документа (с учетом внеш.расходов)*/
/*Доля в доходах                                          */
/*Остаток на начало                                       */
/*Остаток на конец                                        */
/*Средняя учетная цена                                    */
/*Средняя цена продажи                                    */
/*Наценка в руб.                                          */
/*Наценка в %                                             */
/*Оборачиваемость в днях                                  */
/*Срок реализации остатка                                 */

    sheetf.Sizes =  "10,16,40,6,15,15,15,15,15,15,16,12,16,16,16,16,16,16,16,16,16,16,16,16".
    sheetf.ColFormat = "2=@;3=@;" .
    Sheetf.make-correct = "false,false,false,false,true,true,treu,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true" .
ReportNAme = "Б Е С Т С Е Л Л Е Р Ы ".
            Case COMBO-crit:
                when {&bs-1}                   then   crit = 1.
                when {&bs-2}                   then   crit = 2.
                when {&bs-3}                   then   crit = 3.
                when {&bs-4}                   then   crit = 4.
                when {&bs-5}                   then   crit = 5.
                when {&bs-6}                   then   crit = 6.
            End case.

            Case COMBO-Sort:
                when {&bs-1}                   then   Sort = 1.
                when {&bs-2}                   then   Sort = 2.
                when {&bs-3}                   then   Sort = 3.
                when {&bs-4}                   then   Sort = 4.
                when {&bs-5}                   then   Sort = 5.
                when {&bs-6}                   then   Sort = 6.
            End case.

ReportHeader = " Критерий отбора : " + COMBO-crit + chr(10) +
               " Сортировка по " + COMBO-Sort + chr(10) +
               " Показано " + StrinG(BSAmount) + " товаров"   .
If  Tog-Scale Then
ReportHeader = ReportHeader + chr(10) + " Шкалы : "  + Sc_Name .



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
