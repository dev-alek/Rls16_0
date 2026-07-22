&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
/*DEFINE TEMP-TABLE output-tax NO-UNDO LIKE tax
       field rate-code like ub.tax-rate.rate-code
       field rate-value like ub.tax-rate-value.rate-value
       field tax-rate-gds-rc as recid
       FIELD fact-date like ub.tax-rate-value.fact-date
       FIELD fact-order like ub.tax-rate-value.fact-order
       FIELD next-order like ub.tax-rate-value.fact-order
       FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
       FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
       FIELD corr-date like ub.tax-rate-gds.corr-date
       FIELD corr-time like ub.tax-rate-gds.corr-time
       index tax-code is unique primary tax-code rate-code fact-order.*/
DEFINE TEMP-TABLE tt-tax-rate-value NO-UNDO LIKE ub.tax-rate-value
       field rc as recid
       field exp as logical
       index pi is unique primary
       tax-code
       rate-code
       host-code
       obj-type
       obj-code
       fact-order
       index irc is unique
       rc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Дерево ставок налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*******************************ВНИМАНИЕ!!!!!!!!!!!!!!!!!!!!!!!*/
/* чтобы загрузить файл в UIB раскоментарьте определение временной таблицы  output-tax (строчка 10) и*/
/* измените имя второй таблицы-параметра output-tax */
/* при сохрании в VSS или тестировании проделайте все действия в обратном порядке      */

{ str/tt-tax.i INPUT  tt-tax full }
{ str/tt-tax.i OUTPUT output-tax full }
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER parlist-mode as character no-undo.
/*{&update} {&add-def} {&lookup}*/
DEFINE INPUT PARAMETER partable-mode as character no-undo.
/*может быть GOODS или GDS-GRP*/
DEFINE INPUT PARAMETER pargds-code like ub.goods.gds-code no-undo.
/*если partable-mode = "GDS-GRP" то 0 еслии товара еще нет то 0*/
DEFINE INPUT PARAMETER parnode-code like ub.gds-grp.node-code no-undo.
/*если partable-mode = "GOODS" то 0 */
DEFINE INPUT PARAMETER parhost-code like ub.sysconf.host-code no-undo.
DEFINE INPUT PARAMETER parobj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER parobj-code like ub.clients.obj-code no-undo.
DEFINE INPUT PARAMETER par-title as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Дерево ставок налогов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ trg/factord.i }
{ gbl/color.i }
{ str/tt-tax.i '' safe-tax full }
{ gbl/cur-time.i }
{ gbl/get-regf.i }
{ gbl/usrfulnf.i }
&scop tax-error -1
&scop tax-global 0
&scop tax-host 1
&scop tax-object 2

&scop  current-date 1
&scop  all-dates 0
/*
&scop set-v-today  if parlist-mode = {&add-def} and partable-mode = "GOODS":U then do: ~
    assign ~
    v-today = 01/01/1990 ~
    . ~
  end. ~
  else do: ~
    run cur-time in this-procedure ( output v-today ~
                                  , output v-time ~
                                  ). ~
  end.
*/

&scop set-v-today    run cur-time in this-procedure ( output v-today ~
                                  , output v-time ~
                                  ).




/*recid tax-rate-value соответствующего текущему значению output-tax.rate-code*/
define var var-rc as recid.
/*какой налог восстанавливать - если 0 то все*/
define var fill-table-option as integer no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-tax-rate

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tax-rate tt-tax-rate-value output-tax

/* Definitions for BROWSE BR-tax-rate                                   */
&Scoped-define FIELDS-IN-QUERY-BR-tax-rate ~
IF tax-rate.rate-code = output-tax.rate-code and get-mark0(buffer output-tax) then "*" else "" ~
tax-rate.rate-code tax-rate.rate-name tax-rate.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tax-rate
&Scoped-define QUERY-STRING-BR-tax-rate FOR EACH tax-rate ~
      WHERE tax-rate.tax-code = output-tax.tax-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-tax-rate OPEN QUERY BR-tax-rate FOR EACH tax-rate ~
      WHERE tax-rate.tax-code = output-tax.tax-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tax-rate tax-rate
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tax-rate tax-rate


/* Definitions for BROWSE BR-tax-rate-value                             */
&Scoped-define FIELDS-IN-QUERY-BR-tax-rate-value if tt-tax-rate-value.rc = var-rc and get-mark0(buffer output-tax) then "*" else "" tt-tax-rate-value.rate-value tt-tax-rate-value.fact-date tt-tax-rate-value.status_ get-region(tt-tax-rate-value.host-code, tt-tax-rate-value.obj-type, tt-tax-rate-value.obj-code) usrfulnf(tt-tax-rate-value.corr-user-name) tt-tax-rate-value.corr-user-db-num tt-tax-rate-value.corr-date string(tt-tax-rate-value.corr-time, "HH:MM")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tax-rate-value
&Scoped-define SELF-NAME BR-tax-rate-value
&Scoped-define QUERY-STRING-BR-tax-rate-value FOR EACH tt-tax-rate-value NO-LOCK
&Scoped-define OPEN-QUERY-BR-tax-rate-value OPEN QUERY {&SELF-NAME} FOR EACH tt-tax-rate-value NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tax-rate-value tt-tax-rate-value
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tax-rate-value tt-tax-rate-value


/* Definitions for BROWSE BR-tt-tax                                     */
&Scoped-define FIELDS-IN-QUERY-BR-tt-tax if get-mark0(buffer output-tax) then "*" else '':U output-tax.tax-code output-tax.tax-name output-tax.tax-type output-tax.to-cashdesk output-tax.individual output-tax.rate-code output-tax.rate-value output-tax.fact-date usrfulnf(output-tax.corr-user-name) output-tax.corr-user-db-num output-tax.corr-date string(output-tax.corr-time, "HH:MM")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tt-tax
&Scoped-define SELF-NAME BR-tt-tax
&Scoped-define QUERY-STRING-BR-tt-tax FOR EACH output-tax       WHERE output-tax.individual = FALSE NO-LOCK
&Scoped-define OPEN-QUERY-BR-tt-tax OPEN QUERY {&SELF-NAME} FOR EACH output-tax       WHERE output-tax.individual = FALSE NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tt-tax output-tax
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tt-tax output-tax


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-tt-tax}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-hist B-Help RS-date ~
BR-tt-tax set-date B-ext B-selrate B-restore BR-tax-rate BR-tax-rate-value
&Scoped-Define DISPLAYED-OBJECTS RS-date set-date

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark0 Dialog-Frame
FUNCTION get-mark0 RETURNS LOGICAL
  ( buffer loc-output-tax for output-tax )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-var-rc Dialog-Frame
FUNCTION get-var-rc RETURNS RECID
  ( input locpar-date as date)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-restore
       MENU-ITEM m_one          LABEL "Вернуть первоначальную ставку  по данному налогу"
       MENU-ITEM m_all          LABEL "Вернуть первоначальное ставку по всем налогам".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-ext
     LABEL "&>>"
     SIZE 5 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-restore
     LABEL "Во&сстановить"
     SIZE 15 BY 1.

DEFINE BUTTON B-selrate
     LABEL "Вы&бор ставки"
     SIZE 15 BY 1.

DEFINE VARIABLE set-date AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 11.25 BY 1.04 TOOLTIP "Время включения ставки" NO-UNDO.

DEFINE VARIABLE RS-date AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущая дата", 1,
"Все", 0
     SIZE 22.88 BY .88 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-tax-rate FOR
      ub.tax-rate SCROLLING.

DEFINE QUERY BR-tax-rate-value FOR
      tt-tax-rate-value SCROLLING.

DEFINE QUERY BR-tt-tax FOR
      output-tax SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-tax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tax-rate Dialog-Frame _STRUCTURED
  QUERY BR-tax-rate DISPLAY
      IF tax-rate.rate-code = output-tax.rate-code and get-mark0(buffer output-tax) then "*" else "" FORMAT "X(1)":U
      tax-rate.rate-code COLUMN-LABEL "Код!ставки" FORMAT ">>9":U
      tax-rate.rate-name FORMAT "X(25)":U
      tax-rate.status_ FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.5 BY 11.29
         TITLE "Коды ставок".

DEFINE BROWSE BR-tax-rate-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tax-rate-value Dialog-Frame _FREEFORM
  QUERY BR-tax-rate-value DISPLAY
      if tt-tax-rate-value.rc = var-rc and get-mark0(buffer output-tax) then "*" else "" FORMAT "X(1)":U
      tt-tax-rate-value.rate-value FORMAT ">,>>>,>>>,>>9.99":U
      tt-tax-rate-value.fact-date FORMAT "99/99/9999":U
      tt-tax-rate-value.status_ FORMAT "X(8)":U
      get-region(tt-tax-rate-value.host-code, tt-tax-rate-value.obj-type, tt-tax-rate-value.obj-code) COLUMN-LABEL "Область!действия" FORMAT "X(14)":U
      usrfulnf(tt-tax-rate-value.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      tt-tax-rate-value.corr-user-db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
            WIDTH 3
      tt-tax-rate-value.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      string(tt-tax-rate-value.corr-time, "HH:MM") COLUMN-LABEL "Время корр" FORMAT "X(5)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 52.5 BY 11.25
         TITLE "Значения ставок неинд. налогов".

DEFINE BROWSE BR-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tt-tax Dialog-Frame _FREEFORM
  QUERY BR-tt-tax DISPLAY
      if get-mark0(buffer output-tax) then  "*" else '':U COLUMN-LABEL "*"
      output-tax.tax-code FORMAT "9":U
      output-tax.tax-name FORMAT "X(20)":U
      output-tax.tax-type FORMAT "X(1)":U
      output-tax.to-cashdesk COLUMN-LABEL "Посылать!на кассу" FORMAT "+/":U
      output-tax.individual COLUMN-LABEL "Инд." FORMAT "+/":U
      output-tax.rate-code COLUMN-LABEL "Код!ставки"
      output-tax.rate-value COLUMN-LABEL "Знач.!ставки" format "->>>9.99"
      output-tax.fact-date COLUMN-LABEL "Включена" FORMAT "99/99/9999":U
      usrfulnf(output-tax.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(10)":U
      output-tax.corr-user-db-num COLUMN-LABEL "БД" FORMAT ">>>9":U
            WIDTH 6
      output-tax.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      string(output-tax.corr-time, "HH:MM") COLUMN-LABEL "Время корр" FORMAT "X(5)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1.13
     B-exit AT ROW 1 COL 11.13
     B-hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 71
     RS-date AT ROW 1.13 COL 21.75 NO-LABEL
     BR-tt-tax AT ROW 2.08 COL 1
     set-date AT ROW 9.67 COL 17.13 COLON-ALIGNED
     B-ext AT ROW 9.67 COL 47.25
     B-selrate AT ROW 9.71 COL 1
     B-restore AT ROW 9.71 COL 31.38
     BR-tax-rate AT ROW 10.88 COL 1
     BR-tax-rate-value AT ROW 10.92 COL 46.88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Значения ставок неиндивид. налогов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: output-tax T "?" NO-UNDO ub tax
      ADDITIONAL-FIELDS:
          field rate-code like ub.tax-rate.rate-code
          field rate-value like ub.tax-rate-value.rate-value
          field tax-rate-gds-rc as recid
          FIELD fact-date like ub.tax-rate-value.fact-date
          FIELD fact-order like ub.tax-rate-value.fact-order
          FIELD next-order like ub.tax-rate-value.fact-order
          FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
          FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
          FIELD corr-date like ub.tax-rate-gds.corr-date
          FIELD corr-time like ub.tax-rate-gds.corr-time
          index tax-code is unique primary tax-code rate-code fact-order
      END-FIELDS.
      TABLE: tt-tax-rate-value T "?" NO-UNDO ub tax-rate-value
      ADDITIONAL-FIELDS:
          field rc as recid
          field exp as logical
          index pi is unique primary
          tax-code
          rate-code
          host-code
          obj-type
          obj-code
          fact-order
          index irc is unique
          rc
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-tt-tax RS-date Dialog-Frame */
/* BROWSE-TAB BR-tax-rate B-restore Dialog-Frame */
/* BROWSE-TAB BR-tax-rate-value BR-tax-rate Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-restore:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-restore:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tax-rate
/* Query rebuild information for BROWSE BR-tax-rate
     _TblList          = "ub.tax-rate"
     _Where[1]         = "ub.tax-rate.tax-code = output-tax.tax-code"
     _FldNameList[1]   > "_<CALC>"
"IF tax-rate.rate-code = output-tax.rate-code and get-mark0(buffer output-tax) then ""*"" else """"" ? "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.tax-rate.rate-code
"tax-rate.rate-code" "Код!ставки" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.tax-rate.rate-name
"tax-rate.rate-name" ? "X(25)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   = ub.tax-rate.status_
     _Query            is NOT OPENED
*/  /* BROWSE BR-tax-rate */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tax-rate-value
/* Query rebuild information for BROWSE BR-tax-rate-value
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-tax-rate-value NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-tax-rate-value */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tt-tax
/* Query rebuild information for BROWSE BR-tt-tax
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH output-tax
      WHERE output-tax.individual = FALSE NO-LOCK.
     _END_FREEFORM
     _Where[1]         = "Temp-Tables.output-tax.individual = FALSE"
     _Query            is OPENED
*/  /* BROWSE BR-tt-tax */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Значения ставок неиндивид. налогов */
DO:
  RUn initialize-table(0).
  RUn fill-table(0, {&current-date}).
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ext Dialog-Frame
ON CHOOSE OF B-ext IN FRAME Dialog-Frame /* >> */
DO:
   if not avail tt-tax-rate-value then RETURN NO-APPLY.

  RUN proc-ext(var-rc, Rs-date) no-error.
  if error-status:error then return no-apply.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
        run ref/cgdshist.w (
                        input parparentproc
                      , input parhost-code /*p-curr-host-code*/
                      , input parobj-type  /*p-curr-obj-type*/
                      , input parobj-code  /*p-curr-obj-code*/
                      , input "":U /*bttns*/
                      , "subject":U /*p-mode*/
                      , input pargds-code
                      , input ? /*p-host-code*/
                      , input ? /*p-obj-type*/
                      , input ? /*p-obj-code*/
                      , input ? /* p-corr-user-db-num  */
                      , input "":U /* p-corr-user-name  */
                      , input {&table_tax-rate-gds} /* p-subject  */
                      , input g#db-num /* p-db-num */
                      , input-output v-rid-list  ) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
    RUn initialize-table(0).
       RUn fill-table(0, {&current-date}).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-restore
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-restore Dialog-Frame
ON CHOOSE OF B-restore IN FRAME Dialog-Frame /* Восстановить */
DO:
 if rs-date = {&all-dates} then return no-apply.
    if fill-table-option = -1 then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
 if fill-table-option = -1 then return no-apply.
 run proc-b-restore(fill-table-option) no-error.
 if error-status:error then do:
     fill-table-option = -1.
     return no-apply.
 end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-selrate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-selrate Dialog-Frame
ON CHOOSE OF B-selrate IN FRAME Dialog-Frame /* Выбор ставки */
DO:
  assign set-date.
  if not avail ub.tax-rate or
  (ub.tax-rate.rate-code = output-tax.rate-code AND
  (output-tax.fact-date = set-date or partable-mode = "GDS-GRP":U))  then do:
    bell.
    return no-apply.
  end.
  if rs-date = {&all-dates} then return no-apply.
  run proc-b-selrate no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tax-rate
&Scoped-define SELF-NAME BR-tax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tax-rate Dialog-Frame
ON INSERT-MODE OF BR-tax-rate IN FRAME Dialog-Frame /* Коды ставок */
DO:
  APPLY "CHOOSE" to b-selrate.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tax-rate Dialog-Frame
ON VALUE-CHANGED OF BR-tax-rate IN FRAME Dialog-Frame /* Коды ставок */
DO:
  run Openbr-tax-rate-value(rs-date).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tax-rate-value
&Scoped-define SELF-NAME BR-tax-rate-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tax-rate-value Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-tax-rate-value IN FRAME Dialog-Frame /* Значения ставок неинд. налогов */
DO:
  APPLY "CHOOSE" to b-ext.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tt-tax
&Scoped-define SELF-NAME BR-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tt-tax Dialog-Frame
ON VALUE-CHANGED OF BR-tt-tax IN FRAME Dialog-Frame
DO:
if not avail output-tax then return no-apply.
  run OpenBr-tax-rate.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* Вернуть первоначальное ставку по всем налогам */
DO:
    if rs-date = {&all-dates} then return no-apply.
  fill-table-option = 0.
  run proc-b-restore(fill-table-option) no-error.
    if error-status:error then do:
         fill-table-option = -1.
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Вернуть первоначальную ставку  по данному налогу */
DO:
    if rs-date = {&all-dates} then return no-apply.
  fill-table-option = output-tax.tax-code.
  run proc-b-restore(fill-table-option) no-error.
    if error-status:error then do:
        fill-table-option = -1.
        return no-apply.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-date Dialog-Frame
ON VALUE-CHANGED OF RS-date IN FRAME Dialog-Frame
DO:
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  assign RS-date.
  case rs-date:
    when {&current-date} then do:
      enable
      b-selrate when lookup({&lookup}, parlist-mode) = 0
      /*b-restore when lookup({&lookup}, parlist-mode) = 0*/
      set-date when lookup({&lookup}, parlist-mode) = 0
      with frame {&frame-name}.
    end.
    when {&all-dates} then do:
      disable
      b-selrate /*b-restore*/ set-date
      with frame {&frame-name}.
      hide set-date in frame {&frame-name}.
    end.
  end case.
  run fill-table(0, rs-date) no-error.
  if error-status:error then return no-apply.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  {&set-v-today}
  var-rc = get-var-rc( v-today ).
  APPLY "Value-changed" to br-tt-tax.
  run Openbr-tax-rate-value(rs-date).
  APPLY "ENTRY" to br-tax-rate.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME set-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL set-date Dialog-Frame
ON LEAVE OF set-date IN FRAME Dialog-Frame /* с */
DO:
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo.
{&set-v-today}
  if date(self:screen-value) < v-today then do:
    bell.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tax-rate
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize=true }
{ gbl/diasize.i &browse-name=BR-tt-tax }

{ gbl/ed_date.i set-date }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-tax-rate :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BR-tax-rate-value :handle
  ) .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   define variable v-today as date      no-undo.
   define variable v-time  as integer   no-undo.

  if (partable-mode = "GOODS" and pargds-code = 0 and parnode-code = 0)  OR
    (partable-mode = "GDS-GRP" and parnode-code = 0 ) then do:
        message vss-workfile vss-revision vss-description skip
        "Неверный параметры partable-mode и/или pargds-code и/или parnode-code"
        view-as alert-box ERROR.
        return error.
    end.
    if parhost-code = 0 or parobj-type = "" or parobj-code = 0 then do:
        message vss-workfile vss-revision vss-description skip
        "Неверный параметры parhost-code и/или parobj-type и/или parobj-code"
        view-as alert-box ERROR.
        return error.
    end.
    run initialize-table in this-procedure(0).
  run fill-table in this-procedure(0, rs-date).
  run MyEnable.
  {&set-v-today}
  var-rc = get-var-rc( v-today ).
  run diasize_init in this-procedure .
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
  DISPLAY RS-date set-date
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-hist B-Help RS-date BR-tt-tax set-date B-ext B-selrate
         B-restore BR-tax-rate BR-tax-rate-value
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter partax-code like ub.tax.tax-code no-undo.
define input parameter parrs-date as integer no-undo.

define variable var-rate-value like ub.tax-rate-value.rate-value no-undo.
define variable varfact-date as date no-undo.
CASE parrs-date:
    when {&current-date} then do:
        for each output-tax:
          if partax-code = 0 or partax-code = output-tax.tax-code then do:
            delete output-tax.
          end.
        end.
        for each safe-tax no-lock:
          if partax-code = 0 or partax-code = safe-tax.tax-code then do:
            create output-tax.
            buffer-copy safe-tax to output-tax.
          end.
        end.
    end. /*when {&current-date}*/
    when {&all-dates} then do:
      CASE partable-mode:
        when "GOODS":U then do:
          if pargds-code = 0 then return error.
          run gds-all-history in this-procedure(pargds-code) no-error.
          if error-status:error then return error.
        end.
        otherwise do:
            return error.
        end.
      END CASE.
    end.

end CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gds-all-history Dialog-Frame
PROCEDURE gds-all-history :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter locgds-code like ub.goods.gds-code no-undo.
define variable is-first as logical no-undo.
define variable nextfact-order like ub.tax-rate-gds.fact-order no-undo.
define variable max-fact-order like ub.tax-rate-gds.fact-order no-undo.
define variable var-rate-value like ub.tax-rate-value .rate-value no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer b_output-tax for output-tax.
for each output-tax:
  delete output-tax.
end.
{&set-v-today}
run factord-max-fact-order in this-procedure(output max-fact-order) .

for each tt-tax No-LOCK
         break by tt-tax.tax-code:

  if first-of(tt-tax.tax-code) then do:
    is-first = yes.

    for each safe-tax No-LOCK WHERE
              safe-tax.tax-code = tt-tax.tax-code
        BY safe-tax.fact-order descending:
    /*это новые*/
      IF safe-tax.rate-code <> tt-tax.rate-code OR safe-tax.fact-date > v-today then do:
        { gbl/pftxvalo.i  ? tt-tax.tax-code safe-tax.rate-code safe-tax.fact-order parhost-code parobj-type parobj-code var-rate-value no-error }
        create output-tax.
        buffer-copy tt-tax except tax-rate-gds-rc to output-tax
        assign
        output-tax.rate-code = safe-tax.rate-code
        output-tax.rate-value = var-rate-value
        output-tax.fact-date = safe-tax.fact-date
        output-tax.next-order = if is-first then max-fact-order else nextfact-order
        output-tax.fact-order = safe-tax.fact-order
        output-tax.tax-rate-gds-rc = if safe-tax.fact-date > v-today then ? else tt-tax.tax-rate-gds-rc
        .
        assign
        is-first = no
        nextfact-order = output-tax.fact-order
        .

      end. /*safe-tax.rate-code <> tt-tax.tax-code*/
    END. /*for eac safe-tax*/
    FOR each ub.tax-rate-gds No-lock where
              ub.tax-rate-gds.gds-coDe = locgds-code AND
              ub.tax-rate-gds.tax-code = tt-tax.tax-code AND
              ub.tax-rate-gds.host-code = 0 AND
              ub.tax-rate-gds.obj-type = "":U AND
              ub.tax-rate-gds.obj-code = 0
              BY ub.tax-rate-gds.fact-order descending:
      FIND FIRST output-tax where
                output-tax.tax-code = tt-tax.tax-code AND
                /*output-tax.rate-code = ub.tax-rate-gds.rate-code AND*/
                output-tax.fact-order = ub.tax-rate-gds.fact-order No-ERROR.
      if not avail output-tax then do:

        /*найдем по факт-ордеру */
        { gbl/pftxvalo.i  ? ub.tax-rate-gds.tax-code ub.tax-rate-gds.rate-code ub.tax-rate-gds.fact-order parhost-code parobj-type parobj-code var-rate-value no-error }
        create output-tax.
        buffer-copy tt-tax except tax-rate-gds-rc to output-tax
        assign
        output-tax.rate-code = ub.tax-rate-gds.rate-code
        output-tax.rate-value = var-rate-value
        output-tax.fact-date = ub.tax-rate-gds.fact-date
        output-tax.next-order = if is-first then max-fact-order else nextfact-order
        output-tax.fact-order = ub.tax-rate-gds.fact-order
        output-tax.tax-rate-gds-rc = (if ub.tax-rate-gds.fact-date = tt-tax.fact-date then tt-tax.tax-rate-gds-rc else ?)
        .
        assign
        is-first = no
        nextfact-order = output-tax.fact-order
        .
      end. /*if not avil output-tax*/
    end. /*for each tax-rate-gds*/
  end. /*if first-of */
END. /*for each tt-tax*/
/*теперь имеем временную таблицу с историей изменения КОДА СТАВКИ в товаре*/
/*надо запихнуть еще туда историю изменения значения самой ставки!*/

for each output-tax No-LOCK:
  var-rate-value = ?.
  for each ub.tax-rate-value No-LOCK WHERE
          ub.tax-rate-value.rate-code = output-tax.rate-code AND
          ub.tax-rate-value.tax-code = output-tax.tax-code AND
          ub.tax-rate-value.fact-order >= output-tax.fact-order AND
          ub.tax-rate-value.fact-order < output-tax.next-order AND
          ub.tax-rate-value.status_ = {&current-status}
  break
  by ub.tax-rate-value.fact-order
  by ub.tax-rate-value.host-code
  by ub.tax-rate-value.obj-type
  by ub.tax-rate-value.obj-code
  :
    if ub.tax-rate-value.host-code = 0 OR
        (ub.tax-rate-value.host-code = parhost-code
        and ub.tax-rate-value.obj-code = 0
        and ub.tax-rate-value.obj-type = "":U)
        or
        (ub.tax-rate-value.obj-type = parobj-type and
        ub.tax-rate-value.obj-code = parobj-code) then do:
        var-rate-value = ub.tax-rate-value.rate-value.
    end.
    if last-of(ub.tax-rate-value.fact-order) and var-rate-value <> ? then do:
      FIND FIRST b_output-tax where
                  b_output-tax.tax-code = output-tax.tax-code AND
                  b_output-tax.fact-order = ub.tax-rate-value.fact-order No-ERROR.
      if not avail b_output-tax then do:
        create b_output-tax.
        buffer-copy output-tax except tax-rate-gds-rc  to b_output-tax
        assign
        b_output-tax.rate-value = var-rate-value
        b_output-tax.fact-date = ub.tax-rate-value.fact-date
        b_output-tax.fact-order = ub.tax-rate-value.fact-order
        .
      end.
    end. /*if last-of*/
  end.   /*for each ub.tax-rate-value*/
END. /*for each output-tax*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initialize-table Dialog-Frame
PROCEDURE initialize-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter partax-code like ub.tax.tax-code no-undo.
for each safe-tax:
  if partax-code = 0 or partax-code = safe-tax.tax-code then do:
    delete safe-tax.
  end.
end.
for each tt-tax no-lock:
  if partax-code = 0 or partax-code = tt-tax.tax-code then do:
    create safe-tax.
    buffer-copy tt-tax to safe-tax.
  end.
end.

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
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
find first ub.clients no-lock where
           ub.clients.obj-type = {&cmp} and
           ub.clients.obj-code = parhost-code No-error.

{&set-v-today}
ASSIGN
br-tt-tax:title in frame {&frame-name} = par-title
set-date = v-today
set-date:visible in frame {&frame-name} = if LOOKUP({&lookup}, parlist-mode) > 0 then no else yes
set-date:visible in frame {&frame-name} = (partable-mode = "GOODS":U)
b-quit:label in frame {&frame-name}  = if LOOKUP({&lookup}, parlist-mode) > 0 then "Выход" else b-quit:label
b-exit:visible in frame {&frame-name} = if LOOKUP({&lookup}, parlist-mode) > 0 then no else yes
b-restore:visible in frame {&frame-name} = no
b-restore:MENU-MOUSE in frame {&frame-name} = 1
RS-date = {&current-date}
RS-date:visible in frame {&frame-name} = (partable-mode = "GOODS":U)
frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} +
                            "Фирма: " + (if avail ub.clients
                                         then string(clients.obj-name, "x(30)")
                                         else string(parhost-code)) + {&space-char} +
                            parobj-type + string(parobj-code)
.
if (partable-mode = "GOODS":U)
then
DISPLAY
RS-date
WITH FRAME Dialog-Frame.
if LOOKUP({&lookup}, parlist-mode) = 0 AND partable-mode = "GOODS":U then
display set-date
WITH FRAME Dialog-Frame.
ENABLE
B-exit when lookup({&lookup}, parlist-mode) = 0
b-quit
B-Help
b-hist WHEN partable-mode = "GOODS":U
B-selrate when lookup({&lookup}, parlist-mode) = 0
set-date when lookup({&lookup}, parlist-mode) = 0 and partable-mode = "GOODS":U
BR-tt-tax
BR-tax-rate
BR-tax-rate-value
/*B-restore when lookup({&lookup}, parlist-mode) = 0*/
B-ext
RS-date when ((pargds-code <> ? or parnode-code <> ?) AND partable-mode = "GOODS":U)
WITH FRAME Dialog-Frame.

VIEW FRAME Dialog-Frame.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
var-rc = get-var-rc( v-today ).
/*APPLY "Value-changed" to rs-date.*/
APPLY "Value-changed" to br-tt-tax.
APPLY "ENTRY" to br-tax-rate.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr-tax-rate Dialog-Frame
PROCEDURE OpenBr-tax-rate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable locvar-rc as recid     no-undo.
define variable v-today   as date      no-undo.
define variable v-time    as integer   no-undo.

define buffer b_tax-rate for ub.tax-rate.
Open query br-tax-rate for each ub.tax-rate where
ub.tax-rate.tax-code = output-tax.tax-code.
{&set-v-today}
assign
    var-rc = get-var-rc( v-today )
.
find first b_tax-rate No-LOCK WHERE
            b_tax-rate.rate-code = output-tax.rate-code AND
            b_tax-rate.tax-code = output-tax.tax-code no-error.

if avail b_tax-rate then do:
    locvar-rc = recid(b_tax-rate).
end.
reposition br-tax-rate to recid locvar-rc no-error.
APPLY "VALUE-CHANGED" to br-tax-rate in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr-tax-rate-value Dialog-Frame
PROCEDURE OpenBr-tax-rate-value :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-date-option as integer no-undo.
/*recid записи временно таблицы*/
define var var-tt-rc as recid.
define var var-fact-order like ub.tax-rate-value.fact-order no-undo.
/*обасть действия значения ставки*/
define var var-reg as integer no-undo.
/*recid tax-rate-value соответствующего tax-rate выбранного в br-tax-rate */
define var curvar-rc as recid no-undo.
define var upnode-rc as recid no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable loc#log as logical no-undo .
define buffer b_tax-rate-value for ub.tax-rate-value.
define buffer b_tt-tax-rate-value for tt-tax-rate-value.
{&set-v-today}
run factord-end-day in this-procedure (input v-today, output var-fact-order).

for each tt-tax-rate-value:
    delete tt-tax-rate-value.
end.
/*определим область действия текущей ставки на текущем объекте*/
find last b_tax-rate-value No-LOCK WHERE
            b_tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            b_tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = parobj-type AND
            b_tax-rate-value.obj-code = parobj-code AND
            b_tax-rate-value.fact-order <= var-fact-order AND
            b_tax-rate-value.status_ = {&current-status}
            no-error.
if avail b_tax-rate-value then do:
    assign
    var-reg = {&tax-object}
    curvar-rc = recid(b_tax-rate-value)
        .
end.
else do:
    find last b_tax-rate-value No-LOCK WHERE
            b_tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            b_tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = "":U AND
            b_tax-rate-value.obj-code = 0 AND
            b_tax-rate-value.fact-order <= var-fact-order AND
            b_tax-rate-value.status_ = {&current-status}
            no-error.
    if avail b_tax-rate-value then do:
        assign
        var-reg = {&tax-host}
          curvar-rc = recid(b_tax-rate-value)
                .
    end.
    else do:
        find last b_tax-rate-value No-LOCK WHERE
                b_tax-rate-value.rate-code = ub.tax-rate.rate-code AND
                b_tax-rate-value.tax-code = ub.tax-rate.tax-code AND
                b_tax-rate-value.host-code = 0 AND
                b_tax-rate-value.obj-type = "":U AND
                b_tax-rate-value.obj-code = 0 AND
                b_tax-rate-value.fact-order <= var-fact-order AND
                b_tax-rate-value.status_ = {&current-status}
                no-error.
        if avail b_tax-rate-value then do:
            assign
            var-reg = {&tax-global}
            curvar-rc = recid(b_tax-rate-value)
            .
        end.
        else do:
            assign
            var-reg = {&tax-error}
            curvar-rc = ?
            .
        end.
    end.
end.

/*заполним таблитцу tt-tax-rate-value*/

CASE par-date-option:
    when {&all-dates} then do:
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0
            :
    create
    tt-tax-rate-value.
    buffer-copy ub.tax-rate-value to tt-tax-rate-value
    assign
    tt-tax-rate-value.rc = recid(ub.tax-rate-value)
    .
    end.
  end. /*when {&all-date}*/
  when {&current-date} then do:
    FIND LAST ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0 AND
            ub.tax-rate-value.fact-order <= var-fact-order AND
            ub.tax-rate-value.status_ = {&current-status} No-ERROR.
    if avail ub.tax-rate-value then  do:
        create
        tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to tt-tax-rate-value
        assign
        tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
    end.
  end.
END CASE.

if var-reg = {&tax-host} or var-reg = {&tax-object} then do:
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code > 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0 AND
            (par-date-option = {&all-dates} or ub.tax-rate-value.fact-order <= var-fact-order)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
                  :
      if par-date-option = {&all-dates} or last-of(ub.tax-rate-value.obj-code) then do:

          create
          tt-tax-rate-value.
          buffer-copy ub.tax-rate-value to tt-tax-rate-value
          assign
          tt-tax-rate-value.rc = recid(ub.tax-rate-value)
          .
      end.
    end.
   for each tt-tax-rate-value where
            tt-tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            tt-tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            tt-tax-rate-value.host-code = 0:
    tt-tax-rate-value.exp = yes.
   end.

end. /*if {&tax-host}*/
if var-reg = {&tax-object} then do:
    /*добавим все по данной фирме*/
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = parhost-code AND
            ub.tax-rate-value.obj-type <> "" AND
            ub.tax-rate-value.obj-code <> 0 AND
            (par-date-option = {&all-dates} or ub.tax-rate-value.fact-order <= var-fact-order)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
    :
    if par-date-option = {&all-dates} or last-of(ub.tax-rate-value.obj-code) then do:
        create
        tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to tt-tax-rate-value
        assign
        tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
    end.
  end.
  for each tt-tax-rate-value where
        tt-tax-rate-value.tax-code = ub.tax-rate.tax-code AND
        tt-tax-rate-value.rate-code = ub.tax-rate.rate-code AND
        tt-tax-rate-value.host-code = parhost-code :
     tt-tax-rate-value.exp = yes.
  end.
end. /*if tax-object*/
find first b_tt-tax-rate-value where
    b_tt-tax-rate-value.rc = curvar-rc no-lock no-error.
    if avail b_tt-tax-rate-value then
    var-tt-rc = recid(b_tt-tax-rate-value).

open query br-tax-rate-value for each tt-tax-rate-value no-lock.
reposition br-tax-rate-value to recid var-tt-rc no-error.

if br-tax-rate-value:focused-row in frame {&frame-name} = 1 then do:

    loc#log = br-tax-rate-value:SELECT-PREV-ROW( ) .
    if loc#log then do:
        APPLY "CURSOR-DOWN" to br-tax-rate-value.
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-restore Dialog-Frame 
PROCEDURE proc-b-restore :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-fill-table-option as integer no-undo.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

  RUn initialize-table(par-fill-table-option) no-error.
 RUn fill-table(par-fill-table-option, {&current-date}) no-error.
 if error-status:error then do:
    fill-table-option = -1.
    return error.
 end.
 Open query br-tt-tax for each output-tax NO-LOCK WHERE output-tax.individual = FALSE.
 {&set-v-today}
 assign
    var-rc = get-var-rc( v-today )
 .
Run openbr-tax-rate no-error.
 if error-status:error then do:
    return error.
 end.
Run openbr-tax-rate-value(RS-date) no-error.
 if error-status:error then do:
    return error.
 end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-selrate Dialog-Frame 
PROCEDURE proc-b-selrate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable vartax-value like ub.tax-rate-value.rate-value no-undo.
define variable curtax-rc as recid no-undo.
define variable var-fact-order like ub.tax-rate-gds.fact-order no-undo.
define variable loc#log as logical no-undo .
define buffer b_output-tax for output-tax.
DEFINE VARIABLE var-old-date as date no-undo .
DEFINE VARIABLE var-old-order like ub.tax-rate-gds.fact-order no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

  curtax-rc  = recid(output-tax).
  {&set-v-today}
  run factord-end-day in this-procedure (input set-date, output var-fact-order).
  var-old-date = output-tax.fact-date.
  if var-old-date <> ? then
  run factord-end-day in this-procedure (input var-old-date, output var-old-order).
  CASE set-date:
    when v-today then do:
      find first b_output-tax where
                  recid(b_output-tax) = recid(output-tax) No-ERROR.
    end.
    otherwise do:
      /*future*/

      find first b_output-tax where
                 b_output-tax.tax-code = ub.tax-rate.tax-code AND
                 b_output-tax.rate-code = ub.tax-rate.rate-code AND
                 b_output-tax.fact-order = var-fact-order No-ERROR.
      if not avail b_output-tax then do:
        find first b_output-tax where
                  b_output-tax.tax-code = ub.tax-rate.tax-code AND
                  b_output-tax.fact-order = var-fact-order No-ERROR.
        if not avail b_output-tax then do:
          create b_output-tax.
        end.
      end. /*if not avail b_output-tax*/
    end.  /*otherwise*/
  END CASE.
  { gbl/pftaxval.i recid(ub.tax-rate) 0 0 ? parhost-code parobj-type parobj-code vartax-value no-error }
  if error-status:error or vartax-value = ? then do:
     message "Неверное значение по ставке налога" view-as alert-box ERROR.
     return error.
  end.
  buffer-copy output-tax except tax-rate-gds-rc to b_output-tax
  assign
  b_output-tax.rate-code = ub.tax-rate.rate-code
  b_output-tax.rate-value = vartax-value
  b_output-tax.fact-date = (if partable-mode = "GOODS":U then set-date else ?)
  b_output-tax.fact-order = var-fact-order
  .
  if new(b_output-tax) then do:
    create safe-tax.
  end.
  else do:
    find first safe-tax where
               safe-tax.tax-code = b_output-tax.tax-code AND
               (safe-tax.fact-order = var-old-order or partable-mode = "GDS-GRP":U) No-ERROR.
    if not avail safe-tax then do:
      return error.
    end.
  end.
  buffer-copy output-tax except tax-rate-gds-rc to safe-tax
  assign
  safe-tax.rate-code = ub.tax-rate.rate-code
  safe-tax.rate-value = vartax-value
  safe-tax.fact-date = (if partable-mode = "GOODS":U then set-date else ?)
  safe-tax.fact-order = var-fact-order
  .
  var-rc = get-var-rc( v-today ).
  Open query br-tt-tax for each output-tax No-LOCK WHERE output-tax.individual = FALSE.
  REPOSITION br-tt-tax to recid curtax-rc No-ERROR.
  if br-tt-tax:focused-row in frame {&frame-name} = 1 then do:
    loc#log = br-tt-tax:SELECT-PREV-ROW( ) .
    if loc#log then do:
        APPLY "CURSOR-DOWN" to br-tt-tax.
    end.
  end.
  Run openbr-tax-rate.
  Run openbr-tax-rate-value(RS-date).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-ext Dialog-Frame 
PROCEDURE proc-ext :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-rc as recid no-undo.
define input parameter par-date-option as integer no-undo.
define var var-tt-rc as recid no-undo.
define var var-fact-order like ub.tax-rate-value.fact-order no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer b_tt-tax-rate-value for tt-tax-rate-value.
/*самый подробный уровень уходим*/
if tt-tax-rate-value.host-code <> 0 and
   tt-tax-rate-value.obj-type <> "":U and
   tt-tax-rate-value.obj-code <> 0 THEN do:
   BELL.
   return error.
end.
{&set-v-today}
run factord-end-day in this-procedure (input v-today, output var-fact-order).
var-tt-rc = recid(tt-tax-rate-value).
IF tt-tax-rate-value.host-code = 0 then do:
  /*текущий уровень глобальный*/
  if tt-tax-rate-value.exp = yes then do:
    /*он уже раскрыт убиваем* если только внутри не стоит звездочка*/
    FIND FIRST b_tt-tax-rate-value where
               b_tt-tax-rate-value.rc = par-rc No-ERROR.
    if avail b_tt-tax-rate-value and
             b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
             b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code
    then.
    /*он уже раскрыт убиваем*/
    else do:
      FOR EACH b_tt-tax-rate-value where
              b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
              b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
              b_tt-tax-rate-value.host-code <> 0:
        delete b_tt-tax-rate-value.
      END.
      find first b_tt-tax-rate-value where
                 recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
      if avail b_tt-tax-rate-value then do:
        b_tt-tax-rate-value.exp = no.
      end.
    end. /*нет звездочки внутри*/
  end. /*убиваем*/
  else do: /*расширяем*/
   /*расширяем до фирм*/
    FOR EACH ub.tax-rate-value NO-LOCK where
             ub.tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
             ub.tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
             ub.tax-rate-value.host-code <> 0 AND
             ub.tax-rate-value.obj-type = "" AND
             ub.tax-rate-value.obj-code = 0 AND
            (par-date-option = {&all-dates} or ub.tax-rate-value.fact-order <= var-fact-order)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
    :
      if par-date-option = {&all-dates} or last-of(ub.tax-rate-value.obj-code) then do:
        create
        b_tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to b_tt-tax-rate-value
        assign
        b_tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
      end.
    end. /*FOR EACH ub.tax-rate-value*/
    find first b_tt-tax-rate-value where
                recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
    if avail b_tt-tax-rate-value then do:
        b_tt-tax-rate-value.exp = yes.
    end.
  end. /*раширяем*/
end.
else do:
  /*текущий уровень фирмы*/
  if tt-tax-rate-value.exp = yes then do:
    /*он уже раскрыт убиваем если внутри нет звездочки */
    FIND FIRST b_tt-tax-rate-value where
               b_tt-tax-rate-value.rc = par-rc No-ERROR.
    if avail b_tt-tax-rate-value and
             b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
             b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
             b_tt-tax-rate-value.host-code = tt-tax-rate-value.host-code
    then.
    else do:
      FOR EACH b_tt-tax-rate-value where
              b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
              b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
              b_tt-tax-rate-value.host-code = tt-tax-rate-value.host-code AND
              b_tt-tax-rate-value.obj-type <> "" and
              b_tt-tax-rate-value.obj-code <> 0:
        delete b_tt-tax-rate-value.
      END.
      find first b_tt-tax-rate-value where
                 recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
      if avail b_tt-tax-rate-value then do:
                b_tt-tax-rate-value.exp = no.
      end.
    end. /*нет звездочки внутри*/
  end. /**убиваем*/
  else do: /*расширяем*/
    /* расширяем до объектов*/
    FOR EACH ub.tax-rate-value NO-LOCK where
        ub.tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
        ub.tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
        ub.tax-rate-value.host-code = tt-tax-rate-value.host-code AND
        ub.tax-rate-value.obj-type <> "" AND
        ub.tax-rate-value.obj-code <> 0 AND
        (par-date-option = {&all-dates} or ub.tax-rate-value.fact-order <= var-fact-order)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
    :
      if par-date-option = {&all-dates} or last-of(ub.tax-rate-value.obj-code) then do:
        create
        b_tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to b_tt-tax-rate-value
        assign
        b_tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
      end.
    end. /*for each*/
    find first b_tt-tax-rate-value where
               recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
    if avail b_tt-tax-rate-value then do:
             b_tt-tax-rate-value.exp = yes.
    end.
  END. /*РАСШИРЯЕМ*/
end.
open query br-tax-rate-value for each tt-tax-rate-value no-lock.
reposition br-tax-rate-value to recid var-tt-rc no-error.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark0 Dialog-Frame 
FUNCTION get-mark0 RETURNS LOGICAL
  ( buffer loc-output-tax for output-tax ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
{&set-v-today}
if loc-output-tax.tax-rate-gds-rc <> ? or
   (parlist-mode = {&add-def} and
   partable-mode = 'GOODS':U and loc-output-tax.fact-date = v-today)
   then return true.
  RETURN FALSE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-var-rc Dialog-Frame 
FUNCTION get-var-rc RETURNS RECID
  ( input locpar-date as date) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define var locvar-rc as recid no-undo.
define var var-fact-order like ub.tax-rate-value.fact-order no-undo.
define buffer b_tax-rate-value for ub.tax-rate-value.
run factord-end-day in this-procedure (input locpar-date, output var-fact-order).
find last b_tax-rate-value No-LOCK WHERE
            b_tax-rate-value.rate-code = output-tax.rate-code AND
            b_tax-rate-value.tax-code = output-tax.tax-code AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = parobj-type AND
            b_tax-rate-value.obj-code = parobj-code AND
            b_tax-rate-value.fact-order <= var-fact-order AND
            b_tax-rate-value.status_ = {&current-status}
            no-error.
if avail b_tax-rate-value then do:
    assign
    locvar-rc = recid(b_tax-rate-value)
        .
end.
else do:
    find last b_tax-rate-value No-LOCK WHERE
            b_tax-rate-value.rate-code = output-tax.rate-code AND
            b_tax-rate-value.tax-code = output-tax.tax-code AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = "":U AND
            b_tax-rate-value.obj-code = 0 AND
            b_tax-rate-value.fact-order <= var-fact-order AND
            b_tax-rate-value.status_ = {&current-status}
            no-error.
    if avail b_tax-rate-value then do:
        assign
        locvar-rc = recid(b_tax-rate-value)
                .
    end.
    else do:
        find last b_tax-rate-value No-LOCK WHERE
                b_tax-rate-value.rate-code = output-tax.rate-code AND
                b_tax-rate-value.tax-code = output-tax.tax-code AND
                b_tax-rate-value.host-code = 0 AND
                b_tax-rate-value.obj-type = "":U AND
                b_tax-rate-value.obj-code = 0 AND
                b_tax-rate-value.fact-order <= var-fact-order AND
                b_tax-rate-value.status_ = {&current-status}
                no-error.
        if avail b_tax-rate-value then do:
            assign
                        locvar-rc = recid(b_tax-rate-value)
                        .
        end.
        else do:
            assign
            locvar-rc = ?
            .
        end.
    end.
end.
RETURN locvar-rc.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

