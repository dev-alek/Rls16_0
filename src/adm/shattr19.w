&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE TEMP-TABLE tt-cash-pay-mar NO-UNDO LIKE ub.cash-pay
       field cdpay-code-mar like ub.cash-pay.cdpay-code
       field obj-name-mar as character
       index pi is unique primary cdpay-code-mar.
DEFINE TEMP-TABLE tt-cash-pay-mar-pet NO-UNDO LIKE ub.cash-pay
       field cdpay-code-mar-pet like ub.cash-pay.cdpay-code
       field emitent like ub.cash-pay.cdpay-code
       field obj-name-mar as character
       index pi is unique primary cdpay-code-mar-pet
       emitent.
DEFINE TEMP-TABLE tt-tax-rate-code NO-UNDO LIKE ub.tax-rate
       field bo-tax-code like ub.tax-rate.tax-code
       index pi is unique primary rate-code.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "cd-type-maria"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'cd-type-maria'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-host-code LIKE ub.shop.host-code NO-UNDO.
DEFINE VARIABLE v-base-code LIKE ub.sysconf.base-code NO-UNDO.
DEFINE VARIABLE dr-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE drgrouprank AS CHARACTER NO-UNDO.
DEFINE VARIABLE drcprank AS CHARACTER NO-UNDO.
DEFINE VARIABLE drdcrank AS CHARACTER NO-UNDO.
DEFINE VARIABLE drgdsrank AS CHARACTER NO-UNDO.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .


&SCOPED-DEFINE mariapayg-name-list 'Наличные,Безнал 1,Безнал 2,Безнал 3'
&SCOPED-DEFINE mariapayp-name-list0 'Наличные,Дебетовая ведомость,Кредитная ведомость,Платежные карты'
&SCOPED-DEFINE mariapayp-name-liste 'Наличные,Дебетовые карты(талоны),Кредитные карты(талоны),Платежные карты'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cash-pay

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cash-pay-mar tt-cash-pay-mar-pet ~
tt-tax-rate-code

/* Definitions for BROWSE BR-cash-pay                                   */
&Scoped-define FIELDS-IN-QUERY-BR-cash-pay tt-cash-pay-mar.cdpay-code-mar tt-cash-pay-mar.obj-name-mar tt-cash-pay-mar.cdpay-code tt-cash-pay-mar.curr-code tt-cash-pay-mar.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-pay
&Scoped-define SELF-NAME BR-cash-pay
&Scoped-define QUERY-STRING-BR-cash-pay FOR EACH tt-cash-pay-mar NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cash-pay OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-pay-mar NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cash-pay tt-cash-pay-mar
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-pay tt-cash-pay-mar


/* Definitions for BROWSE BR-cash-payp                                  */
&Scoped-define FIELDS-IN-QUERY-BR-cash-payp tt-cash-pay-mar-pet.cdpay-code-mar-pet tt-cash-pay-mar-pet.emitent tt-cash-pay-mar-pet.obj-name-mar tt-cash-pay-mar-pet.cdpay-code tt-cash-pay-mar-pet.curr-code tt-cash-pay-mar-pet.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-payp
&Scoped-define SELF-NAME BR-cash-payp
&Scoped-define QUERY-STRING-BR-cash-payp FOR EACH tt-cash-pay-mar-pet NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cash-payp OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-pay-mar-pet NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cash-payp tt-cash-pay-mar-pet
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-payp tt-cash-pay-mar-pet


/* Definitions for BROWSE BR-tax-rate-code                              */
&Scoped-define FIELDS-IN-QUERY-BR-tax-rate-code tt-tax-rate-code.rate-code bo-tax-code tt-tax-rate-code.rate-name tt-tax-rate-code.tax-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tax-rate-code tt-tax-rate-code.tax-code
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-tax-rate-code tt-tax-rate-code
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-tax-rate-code tt-tax-rate-code
&Scoped-define SELF-NAME BR-tax-rate-code
&Scoped-define QUERY-STRING-BR-tax-rate-code FOR EACH tt-tax-rate-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-tax-rate-code OPEN QUERY {&SELF-NAME} FOR EACH tt-tax-rate-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-tax-rate-code tt-tax-rate-code
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tax-rate-code tt-tax-rate-code


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-discnt B-Help ~
BR-tax-rate-code BR-cash-pay BR-cash-payp

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add  NO-FOCUS
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-add-cpp  NO-FOCUS
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg-cp  NO-FOCUS
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del-cpp
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-discnt
     LABEL "&Скидки"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-pay FOR
      tt-cash-pay-mar SCROLLING.

DEFINE QUERY BR-cash-payp FOR
      tt-cash-pay-mar-pet SCROLLING.

DEFINE QUERY BR-tax-rate-code FOR
      tt-tax-rate-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-pay Dialog-Frame _FREEFORM
  QUERY BR-cash-pay NO-LOCK DISPLAY
      tt-cash-pay-mar.cdpay-code-mar COLUMN-LABEL "Код оплаты!на кассе" FORMAT ">>>>9":U
tt-cash-pay-mar.obj-name-mar COLUMN-LABEL "Описание" FORMAT "X(10)":U
tt-cash-pay-mar.cdpay-code COLUMN-LABEL "Тип кассового!платежа (в BO)" FORMAT ">>>9":U
tt-cash-pay-mar.curr-code COLUMN-LABEL "Код!валюты" FORMAT ">>9":U
tt-cash-pay-mar.obj-name COLUMN-LABEL "Название типа кассового платежа" FORMAT "X(40)":U
    WIDTH 40
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6
         TITLE "Соответствие кодов оплат ТОВАРОВ НА КАССЕ типам кассовых платежей в BO" EXPANDABLE.

DEFINE BROWSE BR-cash-payp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-payp Dialog-Frame _FREEFORM
  QUERY BR-cash-payp NO-LOCK DISPLAY
      tt-cash-pay-mar-pet.cdpay-code-mar-pet COLUMN-LABEL "Код оплаты!на кассе" FORMAT "9":U
tt-cash-pay-mar-pet.emitent COLUMN-LABEL "Код!эмитента" FORMAT ">9":U
tt-cash-pay-mar-pet.obj-name-mar COLUMN-LABEL "Описание" FORMAT "X(25)":U
tt-cash-pay-mar-pet.cdpay-code COLUMN-LABEL "Тип кассового!платежа (в BO)" FORMAT ">>>9":U
tt-cash-pay-mar-pet.curr-code COLUMN-LABEL "Код!валюты" FORMAT ">>9":U
tt-cash-pay-mar-pet.obj-name COLUMN-LABEL "Название типа кассового платежа" FORMAT "X(40)":U
    WIDTH 50
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.42
         TITLE "Соответствие кодов оплат ТОПЛИВА НА КАССЕ типам кассовых платежей в BO" ROW-HEIGHT-CHARS .67 EXPANDABLE.

DEFINE BROWSE BR-tax-rate-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tax-rate-code Dialog-Frame _FREEFORM
  QUERY BR-tax-rate-code NO-LOCK DISPLAY
      tt-tax-rate-code.rate-code COLUMN-LABEL "Код!ставки" FORMAT ">>9":U
bo-tax-code COLUMN-LABEL "Код налога" FORMAT ">9":U WIDTH 16.75
tt-tax-rate-code.rate-name COLUMN-LABEL "Название ставки" FORMAT "X(40)":U
tt-tax-rate-code.tax-code COLUMN-LABEL "Схема налогооблож!на кассе" FORMAT "9":U
    WIDTH 8
ENABLE
tt-tax-rate-code.tax-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 86 BY 5.5
         TITLE "Соответствие ставок налогов категориям налога на кассе" EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-discnt AT ROW 1 COL 31
     B-Help AT ROW 1 COL 54.88
     B-del AT ROW 2 COL 11
     BR-tax-rate-code AT ROW 3 COL 1
     BR-cash-pay AT ROW 9.5 COL 1
     B-del-cpp AT ROW 15.5 COL 11
     B-add-cpp AT ROW 15.5 COL 1
     BR-cash-payp AT ROW 16.5 COL 1
     B-chg-cp AT ROW 8.5 COL 1
     B-add AT ROW 2 COL 1
     "(Для платежей через MAGIC достаточно задать префиксы карт в атрибутах платежа)" VIEW-AS TEXT
          SIZE 77.5 BY 1 AT ROW 15.5 COL 21
          FGCOLOR 4
     SPACE(0.74) SKIP(6.42)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры кассы Maria"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-cash-pay-mar T "?" NO-UNDO ub cash-pay
      ADDITIONAL-FIELDS:
          field cdpay-code-mar like ub.cash-pay.cdpay-code
          field obj-name-mar as character
          index pi is unique primary cdpay-code-mar
      END-FIELDS.
      TABLE: tt-cash-pay-mar-pet T "?" NO-UNDO ub cash-pay
      ADDITIONAL-FIELDS:
          field cdpay-code-mar-pet like ub.cash-pay.cdpay-code
          field emitent like ub.cash-pay.cdpay-code
          field obj-name-mar as character
          index pi is unique primary cdpay-code-mar-pet
          emitent
      END-FIELDS.
      TABLE: tt-tax-rate-code T "?" NO-UNDO ub tax-rate
      ADDITIONAL-FIELDS:
          field bo-tax-code like ub.tax-rate.tax-code
          index pi is unique primary rate-code
      END-FIELDS.
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-tax-rate-code B-del Dialog-Frame */
/* BROWSE-TAB BR-cash-pay BR-tax-rate-code Dialog-Frame */
/* BROWSE-TAB BR-cash-payp B-add-cpp Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-add-cpp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-chg-cp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del-cpp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-pay
/* Query rebuild information for BROWSE BR-cash-pay
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-pay-mar NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-cash-pay */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-payp
/* Query rebuild information for BROWSE BR-cash-payp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-pay-mar-pet NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-cash-payp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tax-rate-code
/* Query rebuild information for BROWSE BR-tax-rate-code
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-tax-rate-code NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-tax-rate-code */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры кассы Maria */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-log AS logical NO-UNDO.
  DEFINE VARIABLE v-tax-rid AS RECID NO-UNDO.
  DEFINE VARIABLE v-tax-rate-rid AS RECID NO-UNDO.
  DEFINE BUFFER buf_tax FOR ub.tax.
  DEFINE BUFFER buf_tax-rate FOR ub.tax-rate.
  FIND FIRST buf_tax NO-LOCK WHERE
            buf_tax.tax-code = INTEGER({&vat-tax-code}).
  run ref/tax-tree.w (
      input parparentproc
      ,INPUT "b-seltax-rate"
      ,INPUT "ALL-TAX-RATES" /* ref-mode */
      ,INPUT 0 /*parhost-code */
      ,INPUT p-obj-type
      ,INPUT p-obj-code
      ,INPUT RECID(buf_tax)
      ,INPUT-OUTPUT v-tax-rate-rid
      ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
IF v-tax-rate-rid <> ? THEN DO:
    FIND FIRST buf_tax-rate NO-LOCK WHERE
          recid(buf_tax-rate) = v-tax-rate-rid.
   FIND FIRST tt-tax-rate-code NO-LOCK WHERE
              tt-tax-rate-code.rate-code = buf_tax-rate.rate-code NO-ERROR.
    IF AVAILABLE tt-tax-rate-code THEN DO:
        MESSAGE
        "Вы уже выбрали ставку налога с кодом ставки" tt-tax-rate-code.rate-code
        VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
   END.
   IF buf_tax-rate.STATUS_ = {&deleted-status}  THEN DO:
        MESSAGE
        "Нельзя выбрать ставку налога в статусе УДАЛЕН"
        VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
   END.

   CREATE tt-tax-rate-code.
   BUFFER-COPY buf_tax-rate
   TO tt-tax-rate-code
   ASSIGN
   tt-tax-rate-code.bo-tax-code = buf_tax-rate.tax-code
   tt-tax-rate-code.tax-code = 0
   v-tax-rate-rid = RECID(tt-tax-rate-code)
   .
   run openbr IN THIS-PROCEDURE.
   REPOSITION br-tax-rate-code TO RECID v-tax-rate-rid.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-cpp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-cpp Dialog-Frame
ON CHOOSE OF B-add-cpp IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-log AS logical NO-UNDO.
  DEFINE variable v-rid AS RECID NO-UNDO.
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-emitent AS integer NO-UNDO.
  DEFINE BUFFER buf_tt-cash-pay-mar-pet FOR tt-cash-pay-mar-pet.
  DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.

  run gbl/d-list.w (
              INPUT "b-sel":U
              ,INPUT "Выберите типы оплаты на кассе"
              ,INPUT "1,2,3,4-5"
              ,INPUT "Наличные,Дебетовая ведомость и Дебетные талоны(карты),Кредитная ведомость или Кредитные талоны(карты),Платежные карты"
              ,INPUT {&comma-char}
              ,INPUT "":U
              ,output v-type).
IF v-type = "":u THEN do:
  RETURN no-apply.
end.
if v-type = "4-5" then v-type = "4".

  run ref/cashpays.w (
               input parparentproc
              ,input  "b-sel":U
              ,input {&all}
              ,input (if p-obj-type = {&cmp} then p-obj-code else v-host-code)
              ,input (if p-obj-type = {&cmp} then '':U else p-obj-type)
              ,input (if p-obj-type = {&cmp} then 0 else p-obj-code)
              ,OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR OR v-rid-list = "":U  THEN RETURN no-apply.
FIND FIRST buf_cash-pay NO-LOCK WHERE
        RECID(buf_cash-pay) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
IF NOT AVAILABLE buf_cash-pay  THEN RETURN NO-APPLY.
if v-type <> "1" then do:
    run gbl/d-prompt.w (
      'title=':u + "Введите идентификатор эмитента НА КАССЕ" + '\':u
    + 'text1=':u + "0 для ВЕДОМОСТИ" + '\':u
    + 'text2=':u + "1-20 для КАРТ НП-ТАЛОНОВ" + '\':u
    + 'format=' + ">9" + '\':u
    + 'type=' + {&type-int} + '\':u
    + 'fillin_row=4\':u
    + 'fillin_col=4\':u
    + 'fillin_width=7\':u
    + 'fillin_height=1\':u
    + 'max-chars=5\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output v-value
    ).
    if return-value = 'false':u then return NO-apply.
   IF INTEGER(v-value) > 20 OR
   integer(v-value) < 0 THEN DO:
       MESSAGE
       "Значение идентификатора эмитента может быть только числом от 0 до 20"
       VIEW-AS ALERT-BOX ERROR.
       RETURN NO-APPLY.
   END.
end.
else do:
  v-value = "0".
end.
   v-emitent = INTEGER(v-value).
   FIND FIRST buf_tt-cash-pay-mar-pet WHERE
             buf_tt-cash-pay-mar-pet.cdpay-code-mar-pet = INTEGER(v-type)
         AND buf_tt-cash-pay-mar-pet.emitent = v-emitent NO-ERROR.
   IF AVAILABLE buf_tt-cash-pay-mar-pet THEN DO:
       MESSAGE
       SUBSTITUTE("Уже есть КОД ОПЛАТЫ ТОПЛИВА НА КАССЕ типа &1 с эмитентом &2"
                  ,buf_tt-cash-pay-mar-pet.obj-name-mar
                  ,v-emitent)
       VIEW-AS ALERT-BOX ERROR.
       RETURN NO-APPLY.
   END.
   CREATE tt-cash-pay-mar-pet.
   BUFFER-COPY buf_cash-pay
   TO tt-cash-pay-mar-pet
   ASSIGN
   tt-cash-pay-mar-pet.cdpay-code-mar-pet = INTEGER(v-type)
   tt-cash-pay-mar-pet.emitent = v-emitent
   tt-cash-pay-mar-pet.obj-name-mar = IF tt-cash-pay-mar-pet.emitent = 0
                                      THEN ENTRY(tt-cash-pay-mar-pet.cdpay-code-mar-pet, {&mariapayp-name-list0})
                                      ELSE ENTRY(tt-cash-pay-mar-pet.cdpay-code-mar-pet, {&mariapayp-name-liste})
   v-rid = RECID(tt-cash-pay-mar-pet)
   .
   run openbr-cpp IN THIS-PROCEDURE.
   REPOSITION br-cash-payp TO RECID v-rid.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg-cp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg-cp Dialog-Frame
ON CHOOSE OF B-chg-cp IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-log AS logical NO-UNDO.
  DEFINE variable v-rid AS RECID NO-UNDO.
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable glog as logical no-undo .
  DEFINE BUFFER buf_tt-cash-pay-mar FOR tt-cash-pay-mar.
  DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
  IF NOT AVAILABLE tt-cash-pay-mar  THEN DO:
     MESSAGE
     "Выберите КОД ОПЛАТЫ ТОВАРА НА КАССE, для которого Вы хотите изменить соответствие"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY.
  END.

  run ref/cashpays.w (
               input parparentproc
              ,input  "b-sel":U
              ,input {&all}
              ,input (if p-obj-type = {&cmp} then p-obj-code else v-host-code)
              ,input (if p-obj-type = {&cmp} then '':U else p-obj-type)
              ,input (if p-obj-type = {&cmp} then 0 else p-obj-code)
              ,OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
if v-rid-list = "":U  THEN do:
  MESSAGE
  substitute("Вы действительно хотите удалить соответствие между КОДОМ ОПЛАТЫ ТОВАРА &1 &2&3" +
             "и типом кассового платежа &4"
             , tt-cash-pay-mar.cdpay-code-mar
             , tt-cash-pay-mar.obj-name-mar
             , {&NEW-LINE}
             , tt-cash-pay-mar.obj-name
             ) VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog THEN RETURN NO-APPLY.
  FIND FIRST buf_tt-cash-pay-mar WHERE recid(buf_tt-cash-pay-mar) = RECID(tt-cash-pay-mar).
  ASSIGN
  buf_tt-cash-pay-mar.cdpay-code = 0
  buf_tt-cash-pay-mar.curr-code = 0
  buf_tt-cash-pay-mar.obj-name = ''
  v-rid = RECID(tt-cash-pay-mar)
  .
  br-cash-pay:REFRESH().

END.
ELSE DO:
    FIND FIRST buf_cash-pay NO-LOCK WHERE
            RECID(buf_cash-pay) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
   IF NOT AVAILABLE buf_cash-pay THEN RETURN NO-APPLY.
   BUFFER-COPY buf_cash-pay TO tt-cash-pay-mar
   ASSIGN
   v-rid = RECID(tt-cash-pay-mar)
   .
   run openbr-cp IN THIS-PROCEDURE.
   REPOSITION br-cash-pay TO RECID v-rid.

END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-tax-rate-code THEN RETURN NO-APPLY.
  DELETE tt-tax-rate-code.
  run openbr IN THIS-PROCEDURE.
  REPOSITION br-tax-rate-code TO ROW 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-cpp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-cpp Dialog-Frame
ON CHOOSE OF B-del-cpp IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-cash-pay-mar-pet THEN RETURN NO-APPLY.
  DELETE tt-cash-pay-mar-pet.
  run openbr-cpp IN THIS-PROCEDURE.
  REPOSITION br-cash-payp TO ROW 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-discnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-discnt Dialog-Frame
ON CHOOSE OF B-discnt IN FRAME Dialog-Frame /* Скидки */
DO:
  run adm/shatt19d.w (
                  INPUT parparentproc
                 ,INPUT p-mode
                 ,input p-obj-type
                 ,input p-obj-code
                 ,INPUT-OUTPUT dr-list
                 ,INPUT-OUTPUT drgrouprank
                 ,INPUT-OUTPUT drcprank
                 ,INPUT-OUTPUT drdcrank
                 ,INPUT-OUTPUT drgdsrank).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-pay
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


ON LEAVE OF tt-cash-pay-mar.cdpay-code-mar IN BROWSE br-cash-pay DO:
DEFINE VARIABLE old-cdpay-code-mar AS INTEGER NO-UNDO.
 DEFINE BUFFER buf_tt-cash-pay-mar FOR tt-cash-pay-mar.
ASSIGN
old-cdpay-code-mar = tt-cash-pay-mar.cdpay-code-mar.
 FIND FIRST buf_tt-cash-pay-mar NO-LOCK WHERE
           buf_tt-cash-pay-mar.cdpay-code = INPUT BROWSE br-cash-pay tt-cash-pay-mar.cdpay-code-mar
       AND recid(buf_tt-cash-pay-mar) <> recid(tt-cash-pay-mar) NO-ERROR.
 IF AVAILABLE buf_tt-cash-pay-mar  THEN DO:
     MESSAGE
     "Уже задано соответствие для КОДА ОПЛАТЫ НА КАССЕ" INPUT BROWSE br-cash-pay tt-cash-pay-mar.cdpay-code-mar
     VIEW-AS ALERT-BOX ERROR.
     ASSIGN
     tt-cash-pay-mar.cdpay-code-mar = old-cdpay-code-mar.
     DISPLAY
     tt-cash-pay-mar.cdpay-code-mar
     WITH BROWSE br-cash-pay.
     RETURN NO-APPLY.
 END.
 ASSIGN
 tt-cash-pay-mar.cdpay-code-mar = INPUT BROWSE br-cash-pay tt-cash-pay-mar.cdpay-code-mar
 .
END.

ON LEAVE OF tt-cash-pay-mar-pet.cdpay-code-mar-pet IN BROWSE br-cash-payp,
            tt-cash-pay-mar-pet.emitent IN BROWSE br-cash-payp DO:
DEFINE VARIABLE old-cdpay-code-mar-pet AS INTEGER NO-UNDO.
DEFINE VARIABLE old-emitent AS INTEGER NO-UNDO.
 DEFINE BUFFER buf_tt-cash-pay-mar-pet FOR tt-cash-pay-mar-pet.
ASSIGN
old-cdpay-code-mar-pet = tt-cash-pay-mar-pet.cdpay-code-mar-pet
old-emitent =     tt-cash-pay-mar-pet.emitent
    .
 FIND FIRST buf_tt-cash-pay-mar-pet NO-LOCK WHERE
           buf_tt-cash-pay-mar-pet.cdpay-code-mar-pet = INPUT BROWSE br-cash-payp tt-cash-pay-mar-pet.cdpay-code-mar-pet
       AND buf_tt-cash-pay-mar-pet.emitent = INPUT BROWSE br-cash-payp tt-cash-pay-mar-pet.emitent
       AND recid(buf_tt-cash-pay-mar-pet) <> recid(tt-cash-pay-mar) NO-ERROR.
 IF AVAILABLE buf_tt-cash-pay-mar-pet  THEN DO:
     MESSAGE
     substitute("Уже задано соответствие для КОДА ОПЛАТЫ НА КАССЕ &1 для ЭМИТЕНТА &2"
                , (INPUT BROWSE br-cash-payp tt-cash-pay-mar-pet.cdpay-code-mar)
                ,  (INPUT BROWSE br-cash-payp tt-cash-pay-mar-pet.emitent))
     VIEW-AS ALERT-BOX ERROR.
     ASSIGN
     tt-cash-pay-mar-pet.cdpay-code-mar = old-cdpay-code-mar-pet
     tt-cash-pay-mar-pet.emitent = old-emitent
     .
     DISPLAY
     tt-cash-pay-mar-pet.cdpay-code-mar-pet
     tt-cash-pay-mar-pet.emitent
     WITH BROWSE br-cash-payp.
     RETURN NO-APPLY.
 END.
 ASSIGN
 tt-cash-pay-mar-pet.cdpay-code-mar-pet = INPUT BROWSE br-cash-payp tt-cash-pay-mar-pet.cdpay-code-mar-pet
 tt-cash-pay-mar-pet.emitent = INPUT BROWSE br-cash-payp tt-cash-pay-mar-pet.emitent
 .
END.
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
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&cmp}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num AND v-cntxt-db-num <> 0 THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  end.
  if p-obj-type = {&cmp} then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
    v-host-code = p-obj-code.
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-maria}
        AND   locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-maria}
    AND   locked_thbj-attr.prop-code = "":u NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.

  end.
  run FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.

  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  ENABLE B-exit b-quit B-discnt B-Help BR-tax-rate-code BR-cash-pay
         BR-cash-payp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rate-code LIKE ub.tax-rate.rate-code NO-UNDO.
DEFINE VARIABLE v-cdtaxlst AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-mariapayg AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-mariapayp AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tax-rate FOR ub.tax-rate.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
DEFINE VARIABLE v-cdpay-code LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-curr-code LIKE ub.cash-pay.curr-code NO-UNDO.
DEFINE VARIABLE v-cdpay-code-mar LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-cdpay-code-mar-pet LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-emitent AS INTEGER NO-UNDO.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-cd-type-maria}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT TABLE-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  IF v-entry = {&attr-cd-type-maria_cdtaxlst} THEN DO:
    ASSIGN
    v-cdtaxlst = thbjattr_thbj-attr.property-value-character
    .
  END.
  IF v-entry = {&attr-cd-type-maria_mariapayg} THEN DO:
    ASSIGN
    v-mariapayg = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-maria_mariapayp} THEN DO:
    ASSIGN
    v-mariapayp = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-maria_dr-list} THEN DO:
    ASSIGN
    dr-list = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-maria_drgrouprank} THEN DO:
    ASSIGN
    drgrouprank = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-maria_drgdsrank} THEN DO:
    ASSIGN
    drgdsrank = thbjattr_thbj-attr.property-value-character.
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
if v-cdtaxlst <> "":U then do:
  _ii:
  DO ii = 1 TO NUM-ENTRIES(v-cdtaxlst, ";"):
    ASSIGN
    v-rate-code = INTEGER (ENTRY(1, ENTRY(ii, v-cdtaxlst, ";":U), "-":U))
    .
    FIND FIRST buf_tax-rate NO-LOCK WHERE
                  buf_tax-rate.rate-code = v-rate-code NO-ERROR.
    IF NOT AVAILABLE buf_tax-rate THEN NEXT _ii.

      CREATE tt-tax-rate-code.
      BUFFER-COPY buf_tax-rate TO tt-tax-rate-code
      ASSIGN
      tt-tax-rate-code.tax-code = integer(ENTRY(2, ENTRY(ii, v-cdtaxlst, ";":U), "-":U))
      tt-tax-rate-code.bo-tax-code = buf_tax-rate.tax-code
      .
  END.
end.
if v-mariapayg = '':u then do:
  v-mariapayg = '1/1,0;2/0,0;3/0,0;4/0,0'.
end.
if v-mariapayg <> "":U then do:
_ii:
DO ii = 1 TO  NUM-ENTRIES(v-mariapayg, ";"):
   ASSIGN
   v-entry = entry(ii, v-mariapayg, ";":U)
   v-cdpay-code-mar = integer(entry(1, entry(1, v-entry, {&slash-char}), {&comma-char}))
   v-cdpay-code = integer(entry(1, entry(2, v-entry, {&slash-char}), {&comma-char}))
   v-curr-code = integer(entry(2, entry(2, v-entry, {&slash-char}), {&comma-char}))
   .
   FIND FIRST buf_cash-pay NO-LOCK WHERE
                buf_cash-pay.cdpay-code = v-cdpay-code
        AND buf_cash-pay.curr-code = v-curr-code  NO-ERROR.
    CREATE tt-cash-pay-mar.
    ASSIGN
    tt-cash-pay-mar.cdpay-code-mar = v-cdpay-code-mar
    tt-cash-pay-mar.cdpay-code = (IF AVAILABLE buf_cash-pay THEN buf_cash-pay.cdpay-code ELSE 0)
    tt-cash-pay-mar.curr-code = (IF AVAILABLE buf_cash-pay THEN buf_cash-pay.curr-code ELSE 0)
    tt-cash-pay-mar.obj-name = (IF AVAILABLE buf_cash-pay THEN buf_cash-pay.obj-name ELSE '':U)
    tt-cash-pay-mar.obj-name-mar = entry(tt-cash-pay-mar.cdpay-code-mar, {&mariapayg-name-list})

    .
    RELEASE tt-cash-pay-mar.
END.
end.
if v-mariapayp <> "":U then do:
_ii:
DO ii = 1 TO  NUM-ENTRIES(v-mariapayp, ";"):
   ASSIGN
   v-entry = entry(ii, v-mariapayp, ";":U)
   v-cdpay-code-mar-pet = integer(entry(1, entry(1, v-entry, {&slash-char}), {&comma-char}))
   v-emitent = integer(entry(2, entry(1, v-entry, {&slash-char}), {&comma-char}))
   v-cdpay-code = integer(entry(1, entry(2, v-entry, {&slash-char}), {&comma-char}))
   v-curr-code = integer(entry(2, entry(2, v-entry, {&slash-char}), {&comma-char}))
   .
   FIND FIRST buf_cash-pay NO-LOCK WHERE
                buf_cash-pay.cdpay-code = v-cdpay-code
        AND buf_cash-pay.curr-code = v-curr-code  NO-ERROR.
   CREATE tt-cash-pay-mar-pet.
   ASSIGN
   tt-cash-pay-mar-pet.cdpay-code-mar-pet = v-cdpay-code-mar-pet
   tt-cash-pay-mar-pet.emitent = v-emitent
   tt-cash-pay-mar-pet.cdpay-code = (IF AVAILABLE buf_cash-pay THEN buf_cash-pay.cdpay-code ELSE 0)
   tt-cash-pay-mar-pet.curr-code = (IF AVAILABLE buf_cash-pay THEN buf_cash-pay.curr-code ELSE 0)
   tt-cash-pay-mar-pet.obj-name = (IF AVAILABLE buf_cash-pay THEN buf_cash-pay.obj-name ELSE '')
   tt-cash-pay-mar-pet.obj-name-mar = (IF tt-cash-pay-mar-pet.emitent = 0
                                       THEN entry(tt-cash-pay-mar-pet.cdpay-code-mar-pet, {&mariapayp-name-list0})
                                       ELSE entry(tt-cash-pay-mar-pet.cdpay-code-mar-pet, {&mariapayp-name-liste}))
   .
   RELEASE tt-cash-pay-mar-pet.
END.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "b-exit,b-quit,b-discnt,b-help,b-add,b-del,br-tax-rate-code,b-chg-cp,br-cash-pay,b-add-cpp,b-del-cpp,br-cash-payp".
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
br-tax-rate-code
br-cash-pay
br-cash-payp
b-add   WHEN p-mode = {&UPDATE}
b-del   WHEN p-mode = {&UPDATE}
b-chg-cp   WHEN p-mode = {&UPDATE}
b-add-cpp   WHEN p-mode = {&UPDATE}
b-del-cpp   WHEN p-mode = {&UPDATE}
b-discnt
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    tt-tax-rate-code.tax-code:read-only  in browse br-tax-rate-code = yes
    .
END.
ELSE DO:
  ASSIGN
  tt-tax-rate-code.tax-code:read-only  in browse br-tax-rate-code = NO
  .
END.
run openbr IN THIS-PROCEDURE.
run openbr-cp IN THIS-PROCEDURE.
run openbr-cpp IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY br-tax-rate-code FOR EACH tt-tax-rate-code SHARE-LOCK.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr-cp Dialog-Frame
PROCEDURE OpenBr-cp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY br-cash-pay FOR EACH tt-cash-pay-mar SHARE-LOCK.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr-cpp Dialog-Frame
PROCEDURE OpenBr-cpp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY br-cash-payp FOR EACH tt-cash-pay-mar-pet SHARE-LOCK.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable ii as integer no-undo .
DEFINE VARIABLE v-cdtaxlst AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-mariapayg AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-mariapayp AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-nal AS INTEGER NO-UNDO.
DEFINE VARIABLE v-2 AS INTEGER NO-UNDO.
DEFINE VARIABLE v-3 AS INTEGER NO-UNDO.
DEFINE VARIABLE v-4 AS INTEGER NO-UNDO.
DEFINE VARIABLE v-5 AS INTEGER NO-UNDO.
define variable v-same as logical no-undo .
define variable v-param-type as character no-undo .

DEFINE BUFFER buf_tt-tax-rate-code FOR tt-tax-rate-code.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
FIND FIRST buf_tt-tax-rate-code NO-LOCK WHERE
          buf_tt-tax-rate-code.tax-code = 0 NO-ERROR.
IF AVAILABLE buf_tt-tax-rate-code THEN DO:
    MESSAGE
    "Вы не ввели категорию налога НА КАССЕ для ставки с кодом " buf_tt-tax-rate-code.rate-code
    VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
END.
ASSIGN
v-cdtaxlst = "cdtaxlst=".

FOR EACH tt-tax-rate-code BY tt-tax-rate-code.rate-code:
    IF tt-tax-rate-code.tax-code > 8 THEN DO:
        MESSAGE
        "Неверное значение СХЕМЫ НАЛООГБЛОЖЕНИЯ НАЛОГА НА КАССЕ" SKIP
        "Разрешены в виде значений только 0, 1, 2, 3, 4, 5, 6, 8"
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    ASSIGN
    ii = ii + 1
    v-cdtaxlst = v-cdtaxlst + (if ii = 1 then "":U else ";":U)  +
                  STRING(tt-tax-rate-code.rate-code) + "-":U + STRING(tt-tax-rate-code.tax-code)
    .
END.
ASSIGN
v-mariapayg = "mariapayg="
ii = 0    .
FOR EACH tt-cash-pay-mar BY tt-cash-pay-mar.cdpay-code-mar:
    IF tt-cash-pay-mar.cdpay-code-mar < 1
    OR tt-cash-pay-mar.cdpay-code-mar > 4 THEN DO:
        MESSAGE
        "Неверное значение КОДА ОПЛАТЫ ТОВАРОВ НА КАССЕ" SKIP
        "Разрешены в виде значений только 1, 2, 3, 4"
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.


     END.
    ASSIGN
    ii = ii + 1
    v-mariapayg = v-mariapayg  + (IF ii = 1 THEN '':U ELSE ';') +
                  STRING(tt-cash-pay-mar.cdpay-code-mar) + {&slash-char} +
                  STRING(tt-cash-pay-mar.cdpay-code) + {&comma-char} +
                  STRING(tt-cash-pay-mar.curr-code)
    .
END.
ASSIGN
v-mariapayp = "mariapayp="
ii = 0.
FOR EACH tt-cash-pay-mar-pet
    BY tt-cash-pay-mar-pet.cdpay-code-mar-pet
    BY tt-cash-pay-mar-pet.emitent:
    IF tt-cash-pay-mar-pet.cdpay-code-mar < 1
    OR tt-cash-pay-mar-pet.cdpay-code-mar > 5 THEN DO:
        MESSAGE
        "Неверное значение КОДА ОПЛАТЫ ТОПЛИВА НА КАССЕ" SKIP
        "Разрешены в виде значений только 1, 2, 3, 4, 5"
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
    IF NOT (tt-cash-pay-mar-pet.emitent <= 20
    or tt-cash-pay-mar-pet.cdpay-code-mar = 31) THEN DO:
        MESSAGE
        "Неверное значение КОДА ОПЛАТЫ ТОПЛИВА НА КАССЕ" SKIP
        "Разрешены в виде значений только 0-20 или 31"
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
   END.
   IF tt-cash-pay-mar-pet.cdpay-code-mar-pet = 1 THEN DO:
       ASSIGN
       v-nal = v-nal + 1.
       IF v-nal > 1 THEN DO:
           MESSAGE
           "Не может быть более одного кода оплаты типа НАЛИЧНЫЕ"
           VIEW-AS ALERT-BOX.
           RETURN no-apply.
       END.
   END.
   IF tt-cash-pay-mar-pet.cdpay-code-mar-pet = 2 THEN DO:
       ASSIGN
       v-2 = v-2 + 1.
       IF v-2 > 21 THEN DO:
           MESSAGE
           "Не может быть более 21 кода оплаты типа ДЕБЕТОВАЯ ВЕДОМОСТЬ ИЛИ ДЕБЕТОВЫЕ КАРТЫ/ТАЛОНЫ"
           VIEW-AS ALERT-BOX.
           RETURN no-apply.
       END.
   END.
   IF tt-cash-pay-mar-pet.cdpay-code-mar-pet = 3 THEN DO:
       ASSIGN
       v-3 = v-3 + 1.
       IF v-3 > 21 THEN DO:
           MESSAGE
           "Не может быть более 21 кода оплаты типа КРЕДИТНАЯ ВЕДОМОСТЬ ИЛИ КРЕДИТНЫЕ КАРТЫ ТАЛОНЫ"
           VIEW-AS ALERT-BOX.
           RETURN no-apply.
       END.
   END.
   IF tt-cash-pay-mar-pet.cdpay-code-mar-pet = 4 THEN DO:
       ASSIGN
       v-4 = v-4 + 1.
       IF v-4 > 20 THEN DO:
           MESSAGE
           "Не может быть более 20 кодов оплаты типа ПЛАТЕЖНЫЕ КАРТЫ"
           VIEW-AS ALERT-BOX.
           RETURN no-apply.
       END.

   END.
   ASSIGN
   ii = ii + 1
   v-mariapayp = v-mariapayp + (IF ii = 1 THEN '':U ELSE ';') +
                 STRING(tt-cash-pay-mar-pet.cdpay-code-mar-pet) + {&comma-char} +
                 STRING(tt-cash-pay-mar-pet.emitent)  + {&slash-char} +
                 STRING(tt-cash-pay-mar-pet.cdpay-code) + {&comma-char} +
                 STRING(tt-cash-pay-mar-pet.curr-code)
   .

END.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-maria_cdtaxlst}.
assign
thbjattr_thbj-attr.property-value-character = v-cdtaxlst.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-maria_mariapayg}.
assign
thbjattr_thbj-attr.property-value-character = v-mariapayg.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-maria_mariapayp}.
assign
thbjattr_thbj-attr.property-value-character = v-mariapayp.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-maria_dr-list}.
assign
thbjattr_thbj-attr.property-value-character = dr-list.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-maria_drgrouprank}.
assign
thbjattr_thbj-attr.property-value-character =  (if drgrouprank = '':U
                                                then '%-46,%сумма-49':U
                                                else drgrouprank).
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-maria_drgdsrank}.
assign
thbjattr_thbj-attr.property-value-character =   (if drgdsrank = '':U
                                                then '%/std-discnt-rule,abs/abs-discnt-rule,%кол-во/qnty-discnt-rule,%сумма/tot-discnt-rule':U
                                                else drgdsrank).
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
/*проверим корректность*/
run adm/shattri.p (
              input "check":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-cd-type-maria}
            , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output TABLE-handle v-tth
             ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
do TRANSACTION
on error undo, return error return-value
:
  RUN thbjattr_set-section IN THIS-PROCEDURE (
       input p-obj-type
      ,input p-obj-code
      ,input {&attr-cd-type-maria}
      ,INPUT table thbjattr_thbj-attr
  ) NO-ERROR.
  IF ERROR-STATUS:error THEN do:
    MESSAGE ERROR-STATUS:get-message(1)  SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME