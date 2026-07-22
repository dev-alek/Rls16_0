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

Пускальник тестов корректности архивов по дис картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/21/05
Author: Bakhtadze Natalya
Creation date: 10/21/05


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Интерфейс тестов корректности архивов по дис картам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }



DEFINE NEW SHARED STREAM test.
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-Help Rs-dctype RS-view-mode ~
F-d-card B-1 B-2 B-3 B-4 B-5 B-6 B-7 B-8 B-99 F-sch F-mess
&Scoped-Define DISPLAYED-OBJECTS Rs-dctype RS-view-mode F-d-card F-sch ~
F-mess

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-1
     LABEL "Количество чеков, товарные суммы и суммы оплат"
     SIZE 78 BY 1.

DEFINE BUTTON B-2
     LABEL "Сумма купленного товара в учетных ценах"
     SIZE 78 BY 1.

DEFINE BUTTON B-3
     LABEL "Суммы по объектам + платежи на фирму(не касс и не по накл) = Суммы по фирме"
     SIZE 78 BY 1.

DEFINE BUTTON B-4
     LABEL "Суммы по объектам  =  Кассовые платежи + Платежи по накладным"
     SIZE 78 BY 1.

DEFINE BUTTON B-5
     LABEL "Кредитные карты: Суммы по фирме - Сальдо карты"
     SIZE 78 BY 1.

DEFINE BUTTON B-6
     LABEL "Платеж по продаже/накл = Сумма по накл/чекам по продажи"
     SIZE 78 BY 1.

DEFINE BUTTON B-7
     LABEL "Корректность % скидки (на товар) по накопительной карте"
     SIZE 78 BY 1.

DEFINE BUTTON B-8
     LABEL "Частные итоги по объекту - чеки"
     SIZE 78 BY 1 TOOLTIP "В ГБД чеки по незакрытым продажам - СУММИРУЮТСЯ".

DEFINE BUTTON B-99
     LABEL "Грубый тест по количеству чеков"
     SIZE 78 BY 1 TOOLTIP "В ГБД чеки по незакрытым продажам - СУММИРУЮТСЯ".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-d-card AS CHARACTER FORMAT "X(256)":U
     LABEL "Введите N карты или all"
     VIEW-AS FILL-IN
     SIZE 15 BY 1.04 NO-UNDO.

DEFINE VARIABLE F-mess AS CHARACTER FORMAT "X(256)":U INITIAL "Для all рез-ты только по"
      VIEW-AS TEXT
     SIZE 34.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-sch AS CHARACTER FORMAT "X(256)":U
     LABEL "Фильтр"
      VIEW-AS TEXT
     SIZE 54.88 BY .67 NO-UNDO.

DEFINE VARIABLE Rs-dctype AS CHARACTER INITIAL "фирма"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1"
     SIZE 27.75 BY .79 NO-UNDO.

DEFINE VARIABLE RS-view-mode AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Показывать только ошибочные", 0,
"Показывать все", 1
     SIZE 50 BY .75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     B-Help AT ROW 1 COL 54.88
     Rs-dctype AT ROW 2.25 COL 3.5 NO-LABEL
     RS-view-mode AT ROW 2.25 COL 47 NO-LABEL
     F-d-card AT ROW 4.54 COL 25.38 COLON-ALIGNED
     B-1 AT ROW 6.17 COL 2
     B-2 AT ROW 7.54 COL 2
     B-3 AT ROW 8.96 COL 2
     B-4 AT ROW 10.25 COL 2
     B-5 AT ROW 11.67 COL 2
     B-6 AT ROW 13.25 COL 2
     B-7 AT ROW 14.75 COL 2
     B-8 AT ROW 16.25 COL 2
     B-99 AT ROW 17.75 COL 2
     F-sch AT ROW 3.38 COL 19.13 COLON-ALIGNED
     F-mess AT ROW 4.75 COL 41.5 COLON-ALIGNED NO-LABEL
     "test7dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 14.75 COL 80.5
          FGCOLOR 4
     "test4dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 10.25 COL 80.5
          FGCOLOR 4
     "test8dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 16.25 COL 80.5
          FGCOLOR 4
     "test5dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 11.63 COL 80.5
          FGCOLOR 4
     "test2dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 7.42 COL 80.5
          FGCOLOR 4
     "test6dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 13.25 COL 80.5
          FGCOLOR 4
     "test99dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 17.75 COL 80.5
          FGCOLOR 4
     "test3dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 8.92 COL 80.5
          FGCOLOR 4
     "Результаты ищите в:" VIEW-AS TEXT
          SIZE 19.5 BY 1 AT ROW 4.5 COL 79.5
          FGCOLOR 4
     "test1dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 6 COL 80.5
          FGCOLOR 4
     SPACE(4.62) SKIP(12.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тест корректности архивов по дисконтным картам"
         DEFAULT-BUTTON B-exit.


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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тест корректности архивов по дисконтным картам */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-1 Dialog-Frame
ON CHOOSE OF B-1 IN FRAME Dialog-Frame /* Количество чеков, товарные суммы и суммы оплат */
DO:
  assign
  f-d-card
  f-sch
  test-number = 1
  rs-dctype
  rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-2 Dialog-Frame
ON CHOOSE OF B-2 IN FRAME Dialog-Frame /* Сумма купленного товара в учетных ценах */
DO:
  assign
  f-d-card
  f-sch
  test-number = 2
  rs-dctype
   rs-view-mode
  .
  message "В процессе разработки!" view-as alert-box.
  return no-apply.
  /*
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
   */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-3 Dialog-Frame
ON CHOOSE OF B-3 IN FRAME Dialog-Frame /* Суммы по объектам + платежи на фирму(не касс и не по накл) = Суммы по фирме */
DO:
   assign
  f-d-card
  f-sch
  test-number = 3
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-4 Dialog-Frame
ON CHOOSE OF B-4 IN FRAME Dialog-Frame /* Суммы по объектам  =  Кассовые платежи + Платежи по накладным */
DO:
   assign
  f-d-card
  f-sch
  test-number = 4
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-5 Dialog-Frame
ON CHOOSE OF B-5 IN FRAME Dialog-Frame /* Кредитные карты: Суммы по фирме - Сальдо карты */
DO:
  assign
  f-d-card
  f-sch
  test-number = 5
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-6 Dialog-Frame
ON CHOOSE OF B-6 IN FRAME Dialog-Frame /* Платеж по продаже/накл = Сумма по накл/чекам по продажи */
DO:
  assign
  f-d-card
  f-sch
  test-number = 6
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-7 Dialog-Frame
ON CHOOSE OF B-7 IN FRAME Dialog-Frame /* Корректность % скидки (на товар) по накопительной карте */
DO:
  assign
  f-d-card
  f-sch
  test-number = 7
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-8 Dialog-Frame
ON CHOOSE OF B-8 IN FRAME Dialog-Frame /* Частные итоги по объекту - чеки */
DO:
  assign
  f-d-card
  f-sch
  test-number = 8
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-99
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-99 Dialog-Frame
ON CHOOSE OF B-99 IN FRAME Dialog-Frame /* Грубый тест по количеству чеков */
DO:
  assign
  f-d-card
  f-sch
  test-number = 99
  rs-dctype
   rs-view-mode
  .
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
  RS-dctype:RADIO-Buttons =  "Глобальные" + {&comma-char} +  {&all} + {&comma-char} +
                             "По фирме" + {&comma-char} + {&company}
                             .
  rs-dctype = {&ALL}.

  RUN enable_UI.
  ASSIGN
  f-mess = f-mess + {&space-char} + v-cntxt-obj-type + STRING(v-cntxt-obj-code).
  DISPLAY
  f-mess
  WITH FRAME {&FRAME-NAME}.
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
  DISPLAY Rs-dctype RS-view-mode F-d-card F-sch F-mess
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-Help Rs-dctype RS-view-mode F-d-card B-1 B-2 B-3 B-4 B-5 B-6
         B-7 B-8 B-99 F-sch F-mess
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
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

  IF F-d-card <> "all" AND
  F-sch = "" then do:
    FIND FIRST ub.dis-card No-LOCK WHERE ub.dis-card.d-card = f-d-card No-ERROR.
    IF NOT AVAIL ub.dis-card then do:
        message "Не найдена карта с номером " f-d-card
        view-as alert-box ERROR.
        return no-apply.
    end.
    if RS-dctype = {&company} AND ub.dis-card.emitent-host-code = 0 OR
       RS-dctype = {&all} and ub.dis-card.emitent-host-code <> 0 then do:
       message "Дисконтная карта не "
       (if RS-dctype = {&all} then " глобальна!" else " по фирме!")
       view-as alert-box ERROR.
       return no-apply.
    end.
    if dis-card.emitent-host-code > 0 and dis-card.emitent-host-code <> v-cntxt-host-code-obj then do:
        message "Дисконтная карта не принадлежит текущей фирме!"
        view-as alert-box ERROR.
        return no-apply.
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
       OUTPUT stream test to test1dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "М-н"    format "X(5)" space(1)
       "Кол. чеков" format "X(10)" space(1)
       "Сумма покупок {&abbr_rub}" format "X(15)" space(1)
       "Сумма скидок {&abbr_rub}" format "X(15)" space(1)
       "Сумма оплат {&abbr_rub}" format "X(15)" space(1)
       "Сумма покупок б.в." format "X(15)" space(1)
       "Сумма скидок б.в." format "X(15)" space(1)
       "Сумма оплат б.в." format "X(15)"
       SKIP
       .
    END.
    WHEN 2 then do:
       OUTPUT stream test to test2dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "М-н"    format "X(5)" space(1)
       "Сумма учетн.цен {&abbr_rub}" format "X(15)" space(1)
       "Сумма учетн.цен б.в." format "X(15)" space(1)
       SKIP
       .
    END.
    when 3 then do:
       OUTPUT stream test to test3dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "КОд фирмы" format "X(9)" space(3)
       "Число че-" format "X(9)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(3)
       "Прямые поступления" format "X(19)" space(1)
       "Прямые поступления" format "X(19)" space(3)
       "Число че-" format "X(9)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       " 17 - (8 + 10)" format "X(15)" space(1)
       " 18 - (9 + 11)" format "X(15)" space(1)
       SKIP
        " " format "X(16)" space(1)
       " " format "X(9)" space(3)
       "ков объек" format "X(9)" space(1)
       "объекты {&abbr_rub}" format "X(15)" space(1)
       "объекты б.в." format "X(15)" space(1)
       "объекты {&abbr_rub}" format "X(15)" space(1)
       "объекты б.в." format "X(15)" space(1)
       "объекты {&abbr_rub}" format "X(15)" space(1)
       "оъекты б.в." format "X(15)" space(3)
       "на карту {&abbr_rub}" format "X(19)" space(1)
       "на карту б.в." format "X(19)" space(3)
       "ков фирма" format "X(9)" space(1)
       "фирма {&abbr_rub}" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       "фирма {&abbr_rub}" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       "фирма {&abbr_rub}" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       "      1" format "X(16)" space(1)
       "      2" format "X(9)" space(3)
       "      3" format "X(9)" space(1)
       "      4" format "X(15)" space(1)
       "      5" format "X(15)" space(1)
       "      6" format "X(15)" space(1)
       "      7" format "X(15)" space(1)
       "      8" format "X(15)" space(1)
       "      9" format "X(15)" space(3)
       "      10" format "X(15)" space(1)
       "      11" format "X(15)" space(3)
       "      12" format "X(15)" space(1)
       "      13" format "X(9)" space(1)
       "      14" format "X(15)" space(1)
       "      15" format "X(15)" space(1)
       "      16" format "X(15)" space(1)
       "      17" format "X(15)" space(1)
       "      18" format "X(15)" space(1)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       .
    end.
    when 4 then do:
       OUTPUT stream test to test4dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(3)
       "Касс и накл" format "X(15)" space(1)
       "Касс и накл" format "X(15)" space(3)
       " 2 - 4" format "X(15)" space(1)
       " 3 - 5" format "X(15)" space(1)
       SKIP
        " " format "X(16)" space(1)
       "объекты {&abbr_rub}" format "X(15)" space(1)
       "оъекты б.в." format "X(15)" space(3)
       "платежи {&abbr_rub}" format "X(15)" space(1)
       "платежи б.в." format "X(15)" space(3)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       "      1" format "X(16)" space(1)
       "       2" format "X(15)" space(1)
       "       3" format "X(15)" space(3)
       "       4" format "X(15)" space(1)
       "       5" format "X(15)" space(3)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       .


    end. /**/
    when 5 then do:
       OUTPUT stream test to test5dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "Код фирмы" format "X(9)" space(3)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "(3-5)-7)" format "X(15)" space(1)
       "(4-6)-8)" format "X(15)" space(3)
       "Сальдо" format "X(15)" space(1)
       "Сальдо" format "X(15)" space(3)
       "((3-5)-7)-11)" format "X(15)" space(1)
       "((4-6)-8)-12)" format "X(15)" space(1)
       SKIP
       " " format "X(16)" space(1)
       " " format "X(9)" space(3)
       "фирма {&abbr_rub}" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       "фирма {&abbr_rub}" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       "фирма {&abbr_rub}" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       " " format "X(15)" space(1)
       " " format "X(15)" space(3)
       "{&abbr_rub}" format "X(15)" space(1)
       "б.в." format "X(15)" space(3)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       "       1" format "X(16)" space(1)
       " 2" format "X(9)" space(3)
       "       3" format "X(15)" space(1)
       "       4" format "X(15)" space(1)
       "       5" format "X(15)" space(1)
       "       6" format "X(15)" space(1)
       "       7" format "X(15)" space(1)
       "       8" format "X(15)" space(1)
       "       9" format "X(15)" space(1)
       "       10" format "X(15)" space(3)
       "       11" format "X(15)" space(1)
       "       12" format "X(15)" space(3)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       .
    end. /*when 5*/
    WHEN 6 THEN DO:
        OUTPUT stream test to test6dc.txt.
        PUT STREAM test UNFORMATTED
        "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
        SKIP
        "НОМЕР КАРТЫ" format "X(16)" space(1)
        "№ НАКЛ/ПРОД" format "X(14)" space(1)
        "Сумма по чекам" format "X(15)" space(1)
        "Сумма по чекам" format "X(15)" space(3)
        "Касс и накл" format "X(15)" space(1)
        "Касс и накл" format "X(15)" space(3)
        " 3 - 5" format "X(15)" space(1)
        " 4 - 6" format "X(15)" space(1)
        SKIP
         " " format "X(16)" space(1)
         " " format "X(14)" space(1)
        "объекты {&abbr_rub}" format "X(15)" space(1)
        "оъекты б.в." format "X(15)" space(3)
        "платежи {&abbr_rub}" format "X(15)" space(1)
        "платежи б.в." format "X(15)" space(3)
        " " format "X(15)" space(1)
        " " format "X(15)" space(1)
        SKIP
        "      1" format "X(16)" space(1)
        "       2" format "X(14)" space(1)
        "       3" format "X(15)" space(3)
        "       4" format "X(15)" space(1)
        "       5" format "X(15)" space(3)
        "       6" format "X(15)" space(3)
        " " format "X(15)" space(1)
        " " format "X(15)" space(1)
        SKIP
        .



    END.
    WHEN 7 THEN DO:
        OUTPUT stream test to test7dc.txt.
        PUT STREAM test UNFORMATTED
        "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
        SKIP
        "НОМЕР КАРТЫ" format "X(16)" space(1)
        "Тип"   FORMAT "X(8)"   space(1)
        "Сумма оплаченного" format "X(15)" space(1)
        "% скидки" format "X(9)" space(1)
        "Верный %" format "X(9)" space(1)
        SKIP
        .
   END.
    WHEN 8 then do:
       OUTPUT stream test to test1dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "М-н"    format "X(5)" space(1)
       "Кол. чеков в БД" format "X(19)" space(1)
       "Кол. чеков объект" format "X(19)" space(1)
       "Сумма нетто {&abbr_rub} чеков" format "X(19)" space(1)
       "Сумма нетто {&abbr_rub} объект" format "X(19)" space(1)
       SKIP
       .
    END.
    WHEN 99 THEN DO:
        OUTPUT stream test to test99dc.txt.
        PUT STREAM test UNFORMATTED
        "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
        SKIP
        FILL({&space-char}, 20)
        "НОМЕР КАРТЫ" format "X(16)" space(1)
        "Тип"   FORMAT "X(8)"   space(1)
        "Кол-во чеков в БД"   format "X(19)" space(1)
        "Кол-во чеков расчет" format "X(19)" space(1)
        SKIP
        .
   END.
END CASE.

  if f-d-card = "all" or f-d-card = "ALL" THEN DO:
   run utl/tstdisoq.p (
                 input parparentproc
                ,input "ALL":U
                ,input test-number
                ,input f-d-card
                ,input (if RS-dctype = {&company} then v-cntxt-host-code-obj else 0)
                ,INPUT rs-view-mode
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                 )
  .

  END.
  ELSE DO:
   run utl/tstdisoq.p (
                 input parparentproc
                ,input "":U
                ,input test-number
                ,input f-d-card
                ,input (if RS-dctype = {&company} then v-cntxt-host-code-obj else 0)
                ,INPUT rs-view-mode
                ,input "":U
                ,input 0
                 )
  .
  END.

run waitfram-hide in this-procedure .
OUTPUT STREAM test close.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME