&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запуск тестов корректности чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 31/08/00
Author: Bakhtadze Natalya
Creation date: 31/08/00

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Запуск тестов корректности чеков" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/waitfram.i }
{ str/libbcrcn.i }
{ gbl/getcntxt.i def }
DEFINE NEW SHARED STREAM PrnLibstream.
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable MY-where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable sort-phrase-rus as char no-undo.
def NEW SHARED var ff as decimal.
def NEW SHARED var gg as decimal.
DEF NEW SHARED VAR accum1 as decimal.
DEF NEW SHARED VAR accum2 as decimal.
define variable test-number as integer no-undo.
define buffer c-doc for ub.chk-doc.
DEFINE VARIABLE v-curr-r-b AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-base-code LIKE ub.sysconf.base-code no-undo.
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-sch B-Help my-inkas BUTTON-1 ~
BUTTON-2 BUTTON-3 BUTTON-4 BUTTON-5 BUTTON-9 BUTTON-10 BUTTON-11 BUTTON-12 ~
BUTTON-6 BUTTON-7 BUTTON-8 BUTTON-13 BUTTON-14 F-sch
&Scoped-Define DISPLAYED-OBJECTS my-inkas F-sch

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "Фильтр"
     SIZE 10 BY 1.

DEFINE BUTTON BUTTON-1
     LABEL "Нераспознанные товары"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-10
     LABEL "Товарная сумма по строкам - нетто"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-11
     LABEL "Товарная сумма по строкам - брутто-скидка"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-12
     LABEL "Один код - разные цены в одном чеке"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-13
     LABEL "Сумма списания - сумма по строкам списания"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-14
     LABEL "Скидки погрешностей и округления"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-2
     LABEL "Товарная сумма по строкам и оплаты (abbr_rubli)"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-3
     LABEL "Товарная сумма по строкам и оплаты (баз вал)"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-4
     LABEL "Оплаты (abbr_rubli) - нетто"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-5
     LABEL "Оплаты (баз вал) - нетто"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-6
     LABEL "Нераспознанные платежи"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-7
     LABEL "Оплаты abbr_rubli - оплаты баз вал (только для баз вал=0)"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-8
     LABEL "Скидки по строкам - общая скидка чека"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-9
     LABEL "Нетто - брутто-скидка"
     SIZE 56.38 BY 1.08.

DEFINE VARIABLE F-sch AS CHARACTER FORMAT "X(256)":U
     LABEL "Фильтр"
      VIEW-AS TEXT
     SIZE 54.88 BY .67 NO-UNDO.

DEFINE VARIABLE my-inkas AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер продажи или ? или all"
     VIEW-AS FILL-IN
     SIZE 14.63 BY .92 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-sch AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     my-inkas AT ROW 3.08 COL 29 COLON-ALIGNED
     BUTTON-1 AT ROW 4.25 COL 1.75
     BUTTON-2 AT ROW 5.42 COL 1.75
     BUTTON-3 AT ROW 6.58 COL 1.75
     BUTTON-4 AT ROW 7.79 COL 1.75
     BUTTON-5 AT ROW 9 COL 1.75
     BUTTON-9 AT ROW 10.21 COL 1.75
     BUTTON-10 AT ROW 11.42 COL 1.75
     BUTTON-11 AT ROW 12.58 COL 1.75
     BUTTON-12 AT ROW 13.79 COL 1.75
     BUTTON-6 AT ROW 15 COL 1.75
     BUTTON-7 AT ROW 16.21 COL 1.75
     BUTTON-8 AT ROW 17.42 COL 1.75
     BUTTON-13 AT ROW 18.58 COL 1.75
     BUTTON-14 AT ROW 19.75 COL 1.75
     F-sch AT ROW 2.21 COL 21.63 COLON-ALIGNED
     "test8.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 17.42 COL 59.5
          FGCOLOR 4
     "test1.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 4.25 COL 59.25
          FGCOLOR 4
     "Результаты ищите в файле:" VIEW-AS TEXT
          SIZE 25.25 BY 1 AT ROW 3.08 COL 51.63
          FGCOLOR 4
     "test10.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 11.42 COL 59.25
          FGCOLOR 4
     "test9.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 10.21 COL 59.25
          FGCOLOR 4
     "test12.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 13.79 COL 59.25
          FGCOLOR 4
     "test11.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 12.58 COL 59.25
          FGCOLOR 4
     "test3.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 6.58 COL 59.25
          FGCOLOR 4
     "test2.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 5.42 COL 59.25
          FGCOLOR 4
     "test5.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 9 COL 59.25
          FGCOLOR 4
     "test4.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 7.79 COL 59.25
          FGCOLOR 4
     "test14.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 19.75 COL 59.5
          FGCOLOR 4
     "test7.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 16.21 COL 59.25
          FGCOLOR 4
     "test6.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 15 COL 59.25
          FGCOLOR 4
     "test13.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 18.58 COL 59.5
          FGCOLOR 4
     SPACE(2.74) SKIP(1.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тесты корректности чеков"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тесты корректности чеков */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  if v-cntxt-obj-type = {&stock} then do:
    message
    "Опция ФИЛЬТР работает только при запуске утилиты на объекте типа МАГАЗИН!"
    view-as alert-box ERROR.
    return no-apply.
  end.
  assign
  c-point = "chk-docs" + {&g___object}
  tbl = 'chk-doc'
  join-tbl = 'c-DOC'
  fld = 'doc-code,chk-date,office,shift-date,shift-num,chk-num,pay-desk,cashier,sales-man,tot-doc,discnt,sub-discnt,netto,out-code,d-card'
  lab = 'Номер в базе,,,Смена от,Номер смены,Номер по кассе,,,,,,Сумма списанного,Нетто сумма (выручка),Номер продажи,N дис.карты'
  spr = ',,,,,,,,,,,,,,'
  dim = '15'.
  run gbl/filter.w ( input parparentproc
                   , input (c-point + {&delim-par} + "Список чеков, один объект")
                   , input tbl
                   , input join-tbl
                   , input fld
                   , input lab
                   , input spr
                   , input dim).
  define variable v-flt-rec as recid no-undo .
  run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
  MY-WHERE-PHRASE = REPLACE(WHERE-PHRASE, "C-DOC", "CHK-DOC").
  assign f-sch = filter-name.
  display f-sch with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame /* Нераспознанные товары */
DO:
  assign my-inkas.
  if my-inkas =  "?" then my-inkas = ?.
  assign test-number = 1.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-10
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-10 Dialog-Frame
ON CHOOSE OF BUTTON-10 IN FRAME Dialog-Frame /* Товарная сумма по строкам - нетто */
DO:
  assign my-inkas.
  if my-inkas  = "?" then my-inkas = ?.
  assign test-number = 10.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-11
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-11 Dialog-Frame
ON CHOOSE OF BUTTON-11 IN FRAME Dialog-Frame /* Товарная сумма по строкам - брутто-скидка */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 11.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-12
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-12 Dialog-Frame
ON CHOOSE OF BUTTON-12 IN FRAME Dialog-Frame /* Один код - разные цены в одном чеке */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 12.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-13
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-13 Dialog-Frame
ON CHOOSE OF BUTTON-13 IN FRAME Dialog-Frame /* Сумма списания - сумма по строкам списания */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 13.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-14
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-14 Dialog-Frame
ON CHOOSE OF BUTTON-14 IN FRAME Dialog-Frame /* Скидки погрешностей и округления */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 14.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 Dialog-Frame
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame /* Товарная сумма по строкам и оплаты (abbr_rubli) */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 2.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-3 Dialog-Frame
ON CHOOSE OF BUTTON-3 IN FRAME Dialog-Frame /* Товарная сумма по строкам и оплаты (баз вал) */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 3.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-4 Dialog-Frame
ON CHOOSE OF BUTTON-4 IN FRAME Dialog-Frame /* Оплаты (abbr_rubli) - нетто */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 4.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-5 Dialog-Frame
ON CHOOSE OF BUTTON-5 IN FRAME Dialog-Frame /* Оплаты (баз вал) - нетто */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 5.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-6 Dialog-Frame
ON CHOOSE OF BUTTON-6 IN FRAME Dialog-Frame /* Нераспознанные платежи */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 6.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-7 Dialog-Frame
ON CHOOSE OF BUTTON-7 IN FRAME Dialog-Frame /* Оплаты abbr_rubli - оплаты баз вал (только для баз вал=0) */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 7.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-8 Dialog-Frame
ON CHOOSE OF BUTTON-8 IN FRAME Dialog-Frame /* Скидки по строкам - общая скидка чека */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 8.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-9
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-9 Dialog-Frame
ON CHOOSE OF BUTTON-9 IN FRAME Dialog-Frame /* Нетто - брутто-скидка */
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 9.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
 { gbl/curr-r-b.i v-curr-r-b }
 { gbl/basecode.i v-cntxt-host-code-obj v-base-code }
 { str/sclspref.i varscales-pref varpgscales-pref }
  assign
  BUTTON-2:LABEL in frame {&frame-name} = "Товарная сумма по строкам и оплаты ({&abbr_rubli})"
  BUTTON-4:LABEL in frame {&frame-name} = "Оплаты ({&abbr_rubli}) - нетто"
  BUTTON-7:LABEL in frame {&frame-name} = "Оплаты {&abbr_rubli} - оплаты баз вал (только для баз вал=0)"
  .
  RUN MyEnable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY my-inkas F-sch
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-sch B-Help my-inkas BUTTON-1 BUTTON-2 BUTTON-3 BUTTON-4
         BUTTON-5 BUTTON-9 BUTTON-10 BUTTON-11 BUTTON-12 BUTTON-6 BUTTON-7
         BUTTON-8 BUTTON-13 BUTTON-14 F-sch
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame
PROCEDURE MyENable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DISPLAY my-inkas F-sch
      WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  B-sch
  B-Help
  my-inkas
  BUTTON-1
  BUTTON-2 WHEN v-curr-r-b = {&r-b-rubl} OR v-base-code = 0
  BUTTON-3 WHEN v-curr-r-b = {&r-b-base} OR v-base-code = 0
  BUTTON-4 WHEN v-curr-r-b = {&r-b-rubl} OR v-base-code = 0
  BUTTON-5 WHEN v-curr-r-b = {&r-b-base} OR v-base-code = 0
  BUTTON-9
  BUTTON-10
  BUTTON-11
  BUTTON-12
  BUTTON-6
  BUTTON-7 WHEN v-base-code = 0
  BUTTON-8
  BUTTON-13
  BUTTON-14
  F-sch
  WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test0 Dialog-Frame
PROCEDURE test0 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if not my-inkas = ? then do:
    IF my-inkas = "ALL" OR my-inkas = "all" then.
    else do:
        FIND FIRST ub.inkas no-lock where ub.inkas.inkas-code = my-inkas NO-ERROR.
        if not avail ub.inkas then do:
            message "Нет такой продажи!" view-as alert-box ERROR.
            return error.
        END.
        if test-number = 7 then do:
            FIND FIRST ub.shop no-lock where ub.shop.obj-code = ub.inkas.obj-code No-ERROR.
            FIND FIRST ub.sysconf NO-LOCK where ub.sysconf.host-code = ub.shop.host-code NO-ERROR.
            if NOT ub.sysconf.base-code = 0 then do:
                message "Базовая валюта фирмы для продажи " my-inkas " не {&abbr_rubli}!" skip
                "Тестирование лишено смысла!" view-as alert-box.
                return error.
            end.
        end.
    end.
end.
else do:
    if v-cntxt-obj-type = {&stock} then do:
        message
        "Тестирование незакрытых чеков возможно только на объекте типа магазин!"
        view-as alert-box ERROR.
        return error.
    end.
    if test-number = 7 then do:
      FIND FIRST sysconf NO-LOCK where sysconf.host-code = v-cntxt-host-code-obj NO-ERROR.
      if NOT sysconf.base-code = 0 then do:
        message "Базовая валюта текущей фирмы не {&abbr_rubli}!" skip
        "Тестирование лишено смысла!" view-as alert-box.
        return error.
      end.
    end.
end.

assign
ff = 0
gg = 0
accum1 = 0
accum2 = 0
.

run waitfram-show in this-procedure ("Ждите - идет обработка " ).

case test-number:
    WHEN 1 then do:
       OUTPUT stream PrnLibStream to test1.txt.
       PUT stream PrnLibStream UNFORMATTED
       "ЧЕКИ С НЕРАСПОЗНАННЫМ ТОВАРОМ ПО ПРОДАЖЕ " my-inkas " Фильтр - " filter-name
       SKIP
       "НОМЕР ЧЕКА" format "X(20)" space(1)
       "Касса"    format "X(5)" space(1)
       "Чек" format "X(6)" space(1)
       "БАР-КОД" format "X(9)" space(1)
       "Ош-ка номера продажи" format "X(20)"
       SKIP
       .
    END.
    WHEN 2 then do:
       OUTPUT stream PrnLibStream to test2.txt.
       PUT stream PrnLibStream UNFORMATTED
       "Разница между товарной суммой по строкам и оплатам ({&abbr_rubli}) по чеку по продаже " my-inkas " Фильтр - " filter-name skip
       "Номер чека"  format "X(20)" space(1)
       "Касса"    format "X(5)" space(1)
       "Чек" format "X(6)" space(1)
       "Товарная сумма"     format "X(19)" space(1)
       "Сумма оплат"  format "X(19)" space(1)
       "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END.
    WHEN 3 then do:
       OUTPUT stream PrnLibStream to test3.txt.
       PUT stream PrnLibStream UNFORMATTED
       "Разница между товарной суммой по строкам и оплатам (баз вал) по чеку по продаже " my-inkas " Фильтр - " filter-name skip
       "Номер чека"  format "X(20)" space(1)
       "Касса"    format "X(5)" space(1)
       "Чек" format "X(6)" space(1)
       "Товарная сумма"     format "X(19)" space(1)
       "Сумма оплат"  format "X(19)" space(1)
       "Погрешность"  format "X(19)" space(1)
       "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END.
    WHEN 4 then do:
        OUTPUT stream PrnLibStream to test4.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой оплат ({&abbr_rubli}) и суммой нетто по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма нетто"     format "X(19)" space(1)
        "Сумма оплат"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
       "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END. /*WHEN 4*/
    WHEN 5 then do:
        OUTPUT stream PrnLibStream to test5.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой оплат (баз вал) и суммой нетто по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма нетто"     format "X(19)" space(1)
        "Сумма оплат"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
       "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END. /*WHEN 5*/
    WHEN 6 then do:
        OUTPUT stream PrnLibStream to test6.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Нераспознанные платежи по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма в валюте продаж"  format "X(19)" space(1)
        "Нет такого типа касс. платежа" format "X(29)" space(1)
        "Код валюты платежа в системе" format "X(28)" space(1)
        "Код валюты платежа в чеке" format  "X(25)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END. /*when 6*/
    WHEN 7 then do:
        OUTPUT stream PrnLibStream to test7.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой оплат ({&abbr_rubli}) и суммой оплат (баз вал) чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма оплат {&abbr_rubli}"   format "X(19)" space(1)
        "Сумма оплат баз вал"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    end.
    WHEN 8 then do:
        OUTPUT stream PrnLibStream to test8.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой скидок по строкам и общей скидкой чека продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма скидок строк"   format "X(19)" space(1)
        "Общая скидка чека"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    end.
    WHEN 9 then do:
        output stream PrnLibStream to test9.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой нетто по чеку и брутто-скидка  по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Брутто" format "X(19)" space(1)
        "Скидка" format "X(19)" space(1)
        "Нетто"     format "X(19)" space(1)
        "Разность брутто-скидка"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        SKIP.
    END. /*when 9*/
    WHEN 10 then do:
        output stream PrnLibStream to TEST10.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между товарной суммой по строкам чека и суммой нетто по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Товарная сумма"     format "X(19)" space(1)
        "Сумма нетто по чеку"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        SKIP.
    END. /*when 10*/
    WHEN 11 then do:
        output stream PrnLibStream to test11.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между товарной суммой по строкам чека и брутто-скидка по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Брутто" format "X(19)" space(1)
        "Скидка" format "X(19)" space(1)
        "Скидка на итог" format "X(19)" space(1)
        "Товарная сумма"     format "X(19)" space(1)
        "Разность брутто-скидка"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END. /*WHEN 11*/
    WHEN 12 then do:
        output stream PrnLibStream to test12.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой оплат ({&abbr_rubli}) и суммой нетто по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Бар-код" format "X(9)" space(1)
        "Цена1" format "X(12)" space(1)
        "Цена2" format "X(12)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END. /*WHEN 12*/
    WHEN 13 then do:
        output stream PrnLibStream to test13.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой списания и суммой по строкам списания" my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма списания" format "X(19)" space(1)
        "Сумма по строкам списания"     format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
   END. /*WHEN 13*/
   WHEN 14 then do:
        output stream PRnLibStream to test14.txt.
        PUT STREAM PrnLibStream UNFORMATTED
        "Скидки погрешностей и округления" my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Дата"  format "X(10)" space(1)
        "№ продажи"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "№№" format "X(6)" /*"99999"*/ space(1)
        "Бар-код" FORMAT "X(9)" /*"999999999"*/ SPACE(1)
        "Цена" FORMAT "X(15)" /*"->>>,>>>,>>9.99"*/ SPACE(1)
        "Кол-во" FORMAT "X(11)" /*"->>>,>>9.99"*/  SPACE(1)
        "Сумма нетто" FORMAT "X(22)" /*"->>>,>>>,>>9.999999999"*/ SPACE(1)
        "Скидка погрешности" format "X(22)" /*"->>>,>>>,>>9.999999999"*/ space(1)
        "Сумма погрешности" format "X(22)" /*"->>>,>>>,>>9.999999999"*/
        SKIP.
   END. /*WHEN 14*/
END CASE.

define variable v-prepare-phrase as character no-undo .
if my-inkas = "ALL" OR my-inkas = "all" then do:
  v-prepare-phrase = substitute('FOR EACH inkas NO-LOCK where ' +
                                ' inkas.obj-type = &1&2&1 ' +
                                ' AND  inkas.obj-code = &3,' +
                                ' EACH chk-doc NO-LOCK where ' +
                                ' chk-doc.out-code = inkas.inkas-code &4'
                              ,{&double-quote}
                              ,{&shop}
                              ,v-cntxt-obj-code
                              ,my-where-phrase).
  run utl/testq00.p (
             input parparentproc
            ,input test-number
            ,input my-inkas
            ,INPUT v-cntxt-obj-type
            ,INPUT v-cntxt-obj-code
            ,input v-prepare-phrase
            ,input varscales-pref
            ,input varpgscales-pref
            )
   no-error.
end.
else do:
  if my-inkas = ?
  or my-inkas = {&question-mark} then do:
  v-prepare-phrase = substitute('FOR EACH chk-doc NO-LOCK where ' +
                                ' chk-doc.obj-type = &1&2&1 ' +
                                ' AND chk-doc.obj-code = &3' +
                                ' and chk-doc.out-code = ? &4'
                              ,{&double-quote}
                              ,{&shop}
                              ,v-cntxt-obj-code
                              ,my-where-phrase).
  end.
  else do:
  v-prepare-phrase = substitute('FOR EACH chk-doc NO-LOCK where ' +
                                ' chk-doc.obj-type = &1&2&1 ' +
                                ' AND chk-doc.obj-code = &3' +
                                ' and chk-doc.out-code = &1&4&1 &5'
                              ,{&double-quote}
                              ,{&shop}
                              ,v-cntxt-obj-code
                              ,my-inkas
                              ,my-where-phrase).
  end.
  run utl/testq00.p (
             input parparentproc
            ,input test-number
            ,input my-inkas
            ,INPUT v-cntxt-obj-type
            ,INPUT v-cntxt-obj-code
            ,input v-prepare-phrase
            ,input varscales-pref
            ,input varpgscales-pref
            )
  no-error.
end.
if not test-number = 1 and NOT test-number = 6 then
PUT stream PrnLibStream UNFORMATTED
"Накопленная погрешность"
SKIP
accum1 format "-999,999.9999999999"
SKIP.
run waitfram-hide in this-procedure .
OUTPUT stream PrnLibStream close.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME