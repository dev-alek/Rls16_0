&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
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

Справочник видов налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER BTTNS AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER ref-mode AS CHAR No-UNDO.
/*ALL - броузы налогов, ставок и значений синхронизированы */
/*ALL-TAX-RATES - броузы ставок и значений не синхронизированы - все ставки*/
DEFINE INPUT PARAMETER parhost-code like ub.sysconf.host-code No-UNDO.
DEFINE INPUT PARAMETER  parobj-type like ub.clients.obj-type No-UNDO.
DEFINE INPUT PARAMETER  parobj-code like ub.clients.obj-code No-UNDO.
DEFINE INPUT PARAMETER rid# As recid NO-UNDO. /* фиктивный параметр для вызовов процедур*/
DEFINE INPUT-OUTPUT PARAMETER p-tax-rate-rid As char NO-UNDO. /* фиктивный параметр для вызовов процедур*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник видов налогов" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

&scop tax-type-code tax.tax-type
&scop  current-date 1
&scop  all-dates 0

define variable ri as recid no-undo.

define variable unittype like ub.units.type.
/*recid маркируемой tax-rate-value*/
define variable var-rc as recid no-undo.
/*опция добавления tax-rate-value - "GLOBAL":U "HOST":U "OBJECT":U*/
define variable add-tax-rate-value-option as character no-undo.
/*налог по которому отроется br-tax-rate если показываются только КОДЫ СТАВОК без самих налогов*/
define variable var-tax-code like ub.tax.tax-code no-undo.
/*режим отмечания в br-tax-rate когда есть кнопки b-seltax-rate или b-marktax-rate*/
define variable var-ismarked as logical no-undo.
/*работа с региональными налогами*/
define variable v-tax-rate-rid as character no-undo .
define variable glog as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-tax-rate

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tax-rate tt-tax-rate-value tax

/* Definitions for BROWSE BR-tax-rate                                   */
&Scoped-define FIELDS-IN-QUERY-BR-tax-rate ~
get-marktax-rate(var-ismarked, recid(tax-rate), v-tax-rate-rid ) ~
tax-rate.tax-code tax-rate.rate-code tax-rate.rate-name tax-rate.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tax-rate
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-tax-rate
&Scoped-define OPEN-QUERY-BR-tax-rate OPEN QUERY BR-tax-rate FOR EACH ub.tax-rate NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tax-rate tax-rate
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tax-rate tax-rate


/* Definitions for BROWSE BR-tax-rate-value                             */
&Scoped-define FIELDS-IN-QUERY-BR-tax-rate-value ~
if tt-tax-rate-value.rc = var-rc then "*" else "" ~
tt-tax-rate-value.rate-value ~
get-region(tt-tax-rate-value.host-code, tt-tax-rate-value.obj-type, tt-tax-rate-value.obj-code) ~
tt-tax-rate-value.fact-date tt-tax-rate-value.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tax-rate-value
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-tax-rate-value
&Scoped-define OPEN-QUERY-BR-tax-rate-value OPEN QUERY BR-tax-rate-value FOR EACH tt-tax-rate-value ~
      WHERE tt-tax-rate-value.tax-code = tax-rate.tax-code ~
 AND tt-tax-rate-value.rate-code = tax-rate.rate-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tax-rate-value tt-tax-rate-value
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tax-rate-value tt-tax-rate-value


/* Definitions for BROWSE BR-taxes                                      */
&Scoped-define FIELDS-IN-QUERY-BR-taxes tax.tax-code tax.tax-name ~
tax.to-cashdesk ~
(IF (ub.tax.tax-type = "" ) THEN ("") ELSE ({&tax-type-name})) ~
tax.individual tax.status_ get-types(tax.tax-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-taxes
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-taxes
&Scoped-define OPEN-QUERY-BR-taxes OPEN QUERY BR-taxes FOR EACH ub.tax NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-taxes tax
&Scoped-define FIRST-TABLE-IN-QUERY-BR-taxes tax


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-taxes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-seltax B-addtax B-chgtax B-Help ~
BR-taxes RS-date B-seltax-rate B-marktax-rate B-addtax-rate B-chgtax-rate ~
B-deltax-rate B-addtax-rate-value B-deltax-rate-value B-gdstax-rate ~
B-histtax-rate B-ext B-overvalue-rate-value B-histtax-rate-value ~
BR-tax-rate BR-tax-rate-value mark-numtax-rate
&Scoped-Define DISPLAYED-OBJECTS RS-date br-tax-rate-name ~
br-tax-rate-value-name mark-numtax-rate

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-marktax-rate Dialog-Frame
FUNCTION get-marktax-rate RETURNS CHARACTER
  ( input par-ismarked as logical, input par-rid as recid, input par-tax-rate-rid as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-region Dialog-Frame
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-types Dialog-Frame
FUNCTION get-types RETURNS CHARACTER
  ( input partax-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-marktax-rate Dialog-Frame
FUNCTION get-envd RETURNS CHARACTER
  ( input i-tax-code as integer, i-rate-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-addtax-rate-value
       MENU-ITEM m_global       LABEL "Глобальная"
       MENU-ITEM m_host         LABEL "Фирма"
       MENU-ITEM m_object       LABEL "Объект"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-addtax
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-addtax-rate
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-addtax-rate-value
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chgtax
     LABEL "Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chgtax-rate
     LABEL "Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-deltax
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-deltax-rate
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-deltax-rate-value
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-ext
     LABEL ">>"
     SIZE 4 BY 1.

DEFINE BUTTON B-gdstax-rate
     LABEL "Товары"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-histtax-rate
     IMAGE FILE "cmp/b-hist.bmp":U
     LABEL "История"
     SIZE 3 BY 1.

DEFINE BUTTON B-histtax-rate-value
     IMAGE FILE "cmp/b-hist.bmp":U
     LABEL "История"
     SIZE 3 BY 1.

DEFINE BUTTON B-marktax-rate
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON B-overvalue-rate-value
     LABEL "ДНЦ"
     tooltip "Создать ДНЦ для объектов по товарам сменившим ставку"
     SIZE 10 BY 1.

DEFINE BUTTON B-seltax AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE BUTTON B-seltax-rate AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE BUTTON B-taxgds
     LABEL "Товары"
     SIZE 10 BY 1.

DEFINE BUTTON B-taxhist
     IMAGE FILE "cmp/b-hist.bmp":U
     LABEL "История"
     SIZE 3 BY 1.

DEFINE VARIABLE br-tax-rate-name AS CHARACTER FORMAT "X(256)":U INITIAL "Ставки по всем налогам"
      VIEW-AS TEXT
     SIZE 42.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE br-tax-rate-value-name AS CHARACTER FORMAT "X(256)":U INITIAL "Значения ставок"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-numtax-rate AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE RS-date AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие дата/статус", 1,
"Все", 0
     SIZE 29.25 BY .79 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-tax-rate FOR
      ub.tax-rate SCROLLING.

DEFINE QUERY BR-tax-rate-value FOR
      tt-tax-rate-value SCROLLING.

DEFINE QUERY BR-taxes FOR
      ub.tax SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-tax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tax-rate Dialog-Frame _STRUCTURED
  QUERY BR-tax-rate DISPLAY
      get-marktax-rate(var-ismarked, recid(tax-rate), v-tax-rate-rid ) FORMAT "X(1)"
      tax-rate.tax-code
      tax-rate.rate-code
      tax-rate.rate-name FORMAT "X(20)"
      tax-rate.status_
      get-envd(tax-rate.tax-code, tax-rate.rate-code) COLUMN-LABEL "без НДС" FORMAT "X(1)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 43 BY 10.67.

DEFINE BROWSE BR-tax-rate-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tax-rate-value Dialog-Frame _STRUCTURED
  QUERY BR-tax-rate-value DISPLAY
      if tt-tax-rate-value.rc = var-rc then "*" else "" FORMAT "X(1)"
      tt-tax-rate-value.rate-value
      get-region(tt-tax-rate-value.host-code, tt-tax-rate-value.obj-type, tt-tax-rate-value.obj-code) COLUMN-LABEL "Область!действия" FORMAT "X(14)"
      tt-tax-rate-value.fact-date
      tt-tax-rate-value.status_
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 54.5 BY 10.63.

DEFINE BROWSE BR-taxes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-taxes Dialog-Frame _STRUCTURED
  QUERY BR-taxes DISPLAY
      tax.tax-code
      tax.tax-name
      tax.to-cashdesk COLUMN-LABEL "На!кассу" FORMAT "+/"
      (IF (ub.tax.tax-type = "" ) THEN ("") ELSE ({&tax-type-name})) COLUMN-LABEL "Тип" FORMAT "x(10)"
      tax.individual COLUMN-LABEL "Инд." FORMAT "+/"
      tax.status_ FORMAT "X(12)"
      get-types(tax.tax-code) COLUMN-LABEL "Типы товаров" FORMAT "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     B-seltax AT ROW 1 COL 20
     B-addtax AT ROW 1 COL 30
     B-chgtax AT ROW 1 COL 40
     B-deltax AT ROW 1 COL 50
     B-taxgds AT ROW 1 COL 60
     B-taxhist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-taxes AT ROW 2.17 COL 1.25
     RS-date AT ROW 9.29 COL 45.75 NO-LABEL
     B-seltax-rate AT ROW 9.33 COL 1
     B-marktax-rate AT ROW 9.33 COL 11
     B-addtax-rate AT ROW 9.33 COL 14
     B-chgtax-rate AT ROW 9.33 COL 24
     B-deltax-rate AT ROW 9.33 COL 34
     B-addtax-rate-value AT ROW 9.33 COL 77
     B-deltax-rate-value AT ROW 9.33 COL 87
     B-gdstax-rate AT ROW 10.33 COL 24
     B-histtax-rate AT ROW 10.33 COL 34
     B-ext AT ROW 10.33 COL 45
     B-overvalue-rate-value AT ROW 10.33 COL 77
     B-histtax-rate-value AT ROW 10.33 COL 87
     BR-tax-rate AT ROW 11.58 COL 1
     BR-tax-rate-value AT ROW 11.58 COL 44.75
     br-tax-rate-name AT ROW 8.54 COL 1.5 NO-LABEL
     br-tax-rate-value-name AT ROW 8.58 COL 45.63 NO-LABEL
     mark-numtax-rate AT ROW 10.67 COL 4.5 NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Налоги"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
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


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-taxes B-Help Dialog-Frame */
/* BROWSE-TAB BR-tax-rate B-histtax-rate-value Dialog-Frame */
/* BROWSE-TAB BR-tax-rate-value BR-tax-rate Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-addtax-rate-value:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-addtax-rate-value:HANDLE.

/* SETTINGS FOR BUTTON B-deltax IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-deltax:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-taxgds IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-taxgds:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-taxhist IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-taxhist:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN br-tax-rate-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN br-tax-rate-value-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN mark-numtax-rate IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tax-rate
/* Query rebuild information for BROWSE BR-tax-rate
     _TblList          = "ub.tax-rate"
     _FldNameList[1]   > "_<CALC>"
"get-marktax-rate(var-ismarked, recid(tax-rate), v-tax-rate-rid )" ? "X(1)" ? ? ? ? ? ? ? no ?
     _FldNameList[2]   = ub.tax-rate.tax-code
     _FldNameList[3]   = ub.tax-rate.rate-code
     _FldNameList[4]   > ub.tax-rate.rate-name
"tax-rate.rate-name" ? "X(20)" "character" ? ? ? ? ? ? no ?
     _FldNameList[5]   = ub.tax-rate.status_
     _Query            is NOT OPENED
*/  /* BROWSE BR-tax-rate */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tax-rate-value
/* Query rebuild information for BROWSE BR-tax-rate-value
     _TblList          = "Temp-Tables.tt-tax-rate-value"
     _Where[1]         = "Temp-Tables.tt-tax-rate-value.tax-code = tax-rate.tax-code
 AND Temp-Tables.tt-tax-rate-value.rate-code = tax-rate.rate-code"
     _FldNameList[1]   > "_<CALC>"
"if tt-tax-rate-value.rc = var-rc then ""*"" else """"" ? "X(1)" ? ? ? ? ? ? ? no ?
     _FldNameList[2]   = Temp-Tables.tt-tax-rate-value.rate-value
     _FldNameList[3]   > "_<CALC>"
"get-region(tt-tax-rate-value.host-code, tt-tax-rate-value.obj-type, tt-tax-rate-value.obj-code)" "Область!действия" "X(14)" ? ? ? ? ? ? ? no ?
     _FldNameList[4]   = Temp-Tables.tt-tax-rate-value.fact-date
     _FldNameList[5]   = Temp-Tables.tt-tax-rate-value.status_
     _Query            is NOT OPENED
*/  /* BROWSE BR-tax-rate-value */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-taxes
/* Query rebuild information for BROWSE BR-taxes
     _TblList          = "ub.tax"
     _FldNameList[1]   = ub.tax.tax-code
     _FldNameList[2]   = ub.tax.tax-name
     _FldNameList[3]   > ub.tax.to-cashdesk
"tax.to-cashdesk" "На!кассу" "+/" "logical" ? ? ? ? ? ? no ?
     _FldNameList[4]   > "_<CALC>"
"(IF (ub.tax.tax-type = """" ) THEN ("""") ELSE ({&tax-type-name}))" "Тип" "x(10)" ? ? ? ? ? ? ? no ?
     _FldNameList[5]   > ub.tax.individual
"tax.individual" "Инд." "+/" "logical" ? ? ? ? ? ? no ?
     _FldNameList[6]   > ub.tax.status_
"tax.status_" ? "X(12)" "character" ? ? ? ? ? ? no ?
     _FldNameList[7]   > "_<CALC>"
"get-types(tax.tax-code)" "Типы товаров" "X(40)" ? ? ? ? ? ? ? no ?
     _Query            is OPENED
*/  /* BROWSE BR-taxes */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Налоги */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-addtax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-addtax Dialog-Frame
ON CHOOSE OF B-addtax IN FRAME Dialog-Frame /* Добавить */
DO:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_tax-kinds_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
    }
    if NOT glog then return no-apply .
    ri = ?.
    run ref/taxesi.w ( {&add-def}, input-output ri ).
    if ri <> ? then do:
        OPEN QUERY br-taxes FOR EACH ub.tax NO-LOCK.
        reposition br-taxes to recid ri.
        apply "ENTRY" to br-taxes.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-addtax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-addtax-rate Dialog-Frame
ON CHOOSE OF B-addtax-rate IN FRAME Dialog-Frame /* Добавить */
DO:

   if ref-mode = "ALL-TAX-RATES":U then return no-apply.
   /*запрметим когда можды броузеров несенихронизированы - непонятно к какому налогу привыязытваь ставку*/
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_tax-rates_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
    if NOT glog then return no-apply .
    if not avail ub.tax then return no-apply.
    if ub.tax.individual = yes then do:
      message "Нельзя добавить ставки к индивидуальному налогу"
      view-as alert-box ERROR.
      return no-apply.
    end.
    ri = recid(tax).
    run ref/taxratei.w ( {&add-def}, input-output ri ).
    if ri <> ? then  do:
        run OpenBr-tax-rate.
        reposition br-tax-rate to recid ri no-error.
        apply "ENTRY" to br-tax-rate.
        apply "VALUE-CHANGED" to br-tax-rate.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-addtax-rate-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-addtax-rate-value Dialog-Frame
ON CHOOSE OF B-addtax-rate-value IN FRAME Dialog-Frame /* Добавить */
DO:
  if add-tax-rate-value-option = "":U then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
  if add-tax-rate-value-option = "":U then return no-apply.
  run proc-b-addtax-rate-value in this-procedure (add-tax-rate-value-option, RS-date) no-error   .
  if error-status:error then do:
    add-tax-rate-value-option = "":U.
     return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chgtax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chgtax Dialog-Frame
ON CHOOSE OF B-chgtax IN FRAME Dialog-Frame /* Изменить */
DO:

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_tax-kinds_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
    }
    if NOT glog then return no-apply .
    If available ub.tax then do:
        ri = recid( ub.TAX ) .
        run ref/taxesi.w ( {&update}, input-output ri ).
        OPEN QUERY br-taxes FOR EACH ub.tax NO-LOCK.
        reposition br-taxes to recid ri no-error.
        apply "ENTRY" to br-taxes.
    end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chgtax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chgtax-rate Dialog-Frame
ON CHOOSE OF B-chgtax-rate IN FRAME Dialog-Frame /* Изменить */
DO:

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_tax-rates_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
   if NOT glog then return no-apply .
   If available ub.tax-rate then do:
    ri = recid( ub.TAX-rate ) .
    run ref/taxratei.w ( {&update}, input-output ri ).
    RUn OpenBr.
    reposition br-tax-rate to recid ri NO-ERROR.
    apply "ENTRY" to br-tax-rate.
    apply "VALUE-CHANGED" to br-tax-rate.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-deltax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-deltax Dialog-Frame
ON CHOOSE OF B-deltax IN FRAME Dialog-Frame /* Удалить */
DO:

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_tax-kinds_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
    }
    if NOT glog then return no-apply .
    run ref/tax-tr01.p (input recid(ub.tax)) no-error.
        if error-status:error then return no-apply.
     glog = browse br-taxes:refresh().
    apply "ENTRY" to br-taxes.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-deltax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-deltax-rate Dialog-Frame
ON CHOOSE OF B-deltax-rate IN FRAME Dialog-Frame /* Удалить */
DO:

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_tax-rates_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
   if NOT glog then return no-apply .
   If available ub.tax-rate then do:
    ri = recid( ub.TAX-rate ) .
    /*изменение статуса*/
    run ref/taxrati2.p ( input ri ).
    RUn OpenBr-tax-rate.
    reposition br-tax-rate to recid ri NO-ERROR.
    apply "ENTRY" to br-tax-rate.
    APPLY "Value-changed" to br-tax-rate.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-deltax-rate-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-deltax-rate-value Dialog-Frame
ON CHOOSE OF B-deltax-rate-value IN FRAME Dialog-Frame /* Удалить */
DO:
  define var tt-ri as recid no-undo.
    if not avail tt-tax-rate-value then return no-apply.

    if tt-tax-rate-value.obj-code <> 0
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_tax-rate-values_object-update':U
        {&cntxt-object}
        tt-tax-rate-value.host-code
        tt-tax-rate-value.obj-type
        tt-tax-rate-value.obj-code
        0
        0
        0
        true
        glog
      }
    end.
    else do:
      if tt-tax-rate-value.host-code <> 0
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_tax-rate-values_firm-update':U
          {&cntxt-firm}
          tt-tax-rate-value.host-code
          '':U
          0
          0
          0
          0
          true
          glog
        }
      end.
      else do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_tax-rate-values_global-update':U
          {&cntxt-firm}
          0
          '':U
          0
          0
          0
          0
          true
          glog
        }
      end.
    end.
  if NOT glog then return no-apply .
  if tt-tax-rate-value.host-code <> 0 and parhost-code <> tt-tax-rate-value.host-code then return no-apply.
  If available ub.tax-rate then do:
    assign
    tt-ri = recid(tt-tax-rate-value)
    ri = tt-TAX-rate-value.rc
       .
    /*изменение статуса*/
    run ref/taxvali2.p ( input ri
                        ,input no
                          ).
    RUn OpenBr-tax-rate-value(rs-date).
    reposition br-tax-rate-value to recid tt-ri NO-ERROR.
    apply "ENTRY" to br-tax-rate-value.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ext Dialog-Frame
ON CHOOSE OF B-ext IN FRAME Dialog-Frame /* >> */
DO:
  if not avail tt-tax-rate-value then RETURN NO-APPLY.
  RUN proc-b-ext(var-rc, Rs-date) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gdstax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gdstax-rate Dialog-Frame
ON CHOOSE OF B-gdstax-rate IN FRAME Dialog-Frame /* Товары */
DO:
define variable v-list-mode as character no-undo .
define variable v-rid-list as character no-undo .
  if avail ub.tax-rate then do:
    v-list-mode = "TAX-RATE".
    run ref/taxgdss.w (  input parparentproc
                    ,input ''
                    ,input v-list-mode
                    ,input ub.tax-rate.tax-code
                    ,input ub.tax-rate.rate-code
                    ,input-output v-rid-list ).
 end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-histtax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-histtax-rate Dialog-Frame
ON CHOOSE OF B-histtax-rate IN FRAME Dialog-Frame /* История */
DO:
define variable rid-list as character no-undo .
    if available ub.tax-rate THEN
    run ref/ctaxhist.w (
                     input parparentproc
                    ,INPUT "":U /* bttns */
                    ,INPUT "tax-rate":U /*parref-mode */
                    ,OUTPUT rid-list
                    ,INPUT ub.tax-rate.tax-code
                    ,INPUT ub.tax-rate.rate-code
                    ,input "":U /*p-subject*/
       ) .
    apply "entry" to br-tax-rate.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-histtax-rate-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-histtax-rate-value Dialog-Frame
ON CHOOSE OF B-histtax-rate-value IN FRAME Dialog-Frame /* История */
DO:
define variable rid-list as character no-undo .
    if available tt-tax-rate-value THEN
    run ref/ctaxhist.w (
                     input parparentproc
                    ,INPUT "":U /* bttns */
                    ,INPUT "tax-rate-value":U /*parref-mode */
                    ,OUTPUT rid-list
                    ,INPUT tt-tax-rate-value.tax-code
                    ,INPUT tt-tax-rate-value.rate-code
                    ,input "":U /*p-subject*/
       ) .

    apply "entry" to br-tax-rate-value.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-marktax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-marktax-rate Dialog-Frame
ON CHOOSE OF B-marktax-rate IN FRAME Dialog-Frame /* * */
DO:
  if available ub.tax-rate then do:
    { gbl/markstrn.i ub.tax-rate v-tax-rate-rid }
    glog = br-tax-rate:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      glog = br-tax-rate:select-next-row ().
      apply "Value-changed" to br-tax-rate in frame {&frame-name}.
    end.
    if num-entries( v-tax-rate-rid ) = 0
    then
    hide mark-numtax-rate in frame {&frame-name}.
    else
    disp num-entries( v-tax-rate-rid ) @ mark-numtax-rate with frame {&frame-name}.
  end.
  apply "entry" to br-tax-rate in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-overvalue-rate-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-overvalue-rate-value Dialog-Frame
ON CHOOSE OF B-overvalue-rate-value IN FRAME Dialog-Frame /* Переоценка */
DO:
    if available tt-tax-rate-value THEN
    run ref/tax-ovr.w ( input parparentproc, input tt-tax-rate-value.rc ) .
    apply "entry" to br-tax-rate-value.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-seltax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-seltax Dialog-Frame
ON CHOOSE OF B-seltax IN FRAME Dialog-Frame /* Выбор */
DO:
    if available ub.tax then do:
       rid# = recid( ub.tax).
       apply  "GO" to FRAME {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-seltax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-seltax-rate Dialog-Frame
ON CHOOSE OF B-seltax-rate IN FRAME Dialog-Frame /* Выбор */
DO:
    if (( available ub.tax-rate ) AND ( v-tax-rate-rid = "" )) OR
               b-marktax-rate:sensitive = no then do:
        v-tax-rate-rid = string( recid( ub.tax-rate ) ) .
    end.
    br-tax-rate:refresh().
    RUn OpenBR-tax-rate-value in this-procedure (RS-date) no-error .
    p-tax-rate-rid = v-tax-rate-rid.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-taxgds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-taxgds Dialog-Frame
ON CHOOSE OF B-taxgds IN FRAME Dialog-Frame /* Товары */
DO:
define variable v-list-mode as character no-undo .
define variable v-rid-list as character no-undo .
 if avail ub.tax then do:
    if ub.tax.individual then dO:
      run ref/taxigds.w ( input parparentproc
                         ,input ''
                         ,input "TAX"
                         ,input ub.tax.tax-code
                         ,input-output v-rid-list ) no-error.
    end.
    else do:
      run ref/taxgdss.w ( input parparentproc
                   , input ''
                   , input "TAX"
                   , input ub.tax.tax-code
                   , input 0 /*p-rate-code*/
                   , input-output v-rid-list ).
    end.
 end.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-taxhist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-taxhist Dialog-Frame
ON CHOOSE OF B-taxhist IN FRAME Dialog-Frame /* История */
DO:
define variable rid-list as character no-undo .
    if available ub.tax THEN do:
      run ref/ctaxhist.w (
                       input parparentproc
                      ,INPUT "":U /* bttns */
                      ,INPUT "tax":U /*parref-mode */
                      ,OUTPUT rid-list
                      ,INPUT ub.tax.tax-code
                      ,INPUT 0
                      ,input "":U /*p-subject*/
        ) .
     end.
    apply "entry" to br-taxes.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tax-rate
&Scoped-define SELF-NAME BR-tax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tax-rate Dialog-Frame
ON INSERT-MODE OF BR-tax-rate IN FRAME Dialog-Frame
DO:
   IF b-marktax-rate:sensitive then do:
    APPLY "CHOOSE" to b-marktax-rate.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tax-rate Dialog-Frame
ON RETURN OF BR-tax-rate IN FRAME Dialog-Frame
DO:
  if not ref-mode = "ALL-TAX-RATES":U then do:
  return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tax-rate Dialog-Frame
ON VALUE-CHANGED OF BR-tax-rate IN FRAME Dialog-Frame
DO:
  Run OpenBR-tax-rate-value(rs-date).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tax-rate-value
&Scoped-define SELF-NAME BR-tax-rate-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tax-rate-value Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-tax-rate-value IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE" to b-ext.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-taxes
&Scoped-define SELF-NAME BR-taxes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-taxes Dialog-Frame
ON VALUE-CHANGED OF BR-taxes IN FRAME Dialog-Frame
DO:
  if not avail ub.tax then return no-apply.
  if ref-mode <> "ALL-TAX-RATES":U then
  run OpenBr-tax-rate.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_global Dialog-Frame
ON CHOOSE OF MENU-ITEM m_global /* Глобальная */
DO:
  add-tax-rate-value-option = "GLOBAL":U.
  run proc-b-addtax-rate-value in this-procedure(add-tax-rate-value-option, RS-date) No-ERROR.
  if error-status:error then do:
    add-tax-rate-value-option = "":U.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_host Dialog-Frame
ON CHOOSE OF MENU-ITEM m_host /* Фирма */
DO:
  add-tax-rate-value-option = "HOST":U.
  run proc-b-addtax-rate-value in this-procedure(add-tax-rate-value-option, rs-date) No-ERROR.
  if error-status:error then do:
    add-tax-rate-value-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object /* Объект */
DO:
  add-tax-rate-value-option = "OBJECT":U.
  run proc-b-addtax-rate-value in this-procedure(add-tax-rate-value-option, rs-date) No-ERROR.
  if error-status:error then do:
    add-tax-rate-value-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-date Dialog-Frame
ON VALUE-CHANGED OF RS-date IN FRAME Dialog-Frame
DO:
  assign rs-date.
  run OpenBr-tax-rate-value (rs-date).
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

{ gbl/diasize.i &browse-name=BR-tax-rate }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-taxes :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse BR-tax-rate-value :handle
  ) .
run diasize_init in this-procedure .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if ref-mode = "ALL-TAX-RATES" then do:
      if rid# <> ? then do:
        find first tax no-lock where
                            recid(tax) = rid# No-ERROR.
        if not avail tax then return error.
        var-tax-code = tax.tax-code.
     end.
  end.
  assign
  v-tax-rate-rid = p-tax-rate-rid
  .
  RUN Myenable.
  if ref-mode = "ALL-TAX-RATES" then do:
     var-ismarked = if LOOKUP("b-seltax-rate", bttns) > 0 or LOOKUP("b-markltax-rate", bttns) > 0 then yes else no.
     run OpenBr-tax-rate.
  end.
  else do:
     RUn OpenBr.
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY RS-date br-tax-rate-name br-tax-rate-value-name mark-numtax-rate
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-seltax B-addtax B-chgtax B-Help BR-taxes RS-date
         B-seltax-rate B-marktax-rate B-addtax-rate B-chgtax-rate B-deltax-rate
         B-addtax-rate-value B-deltax-rate-value B-gdstax-rate B-histtax-rate
         B-ext B-overvalue-rate-value B-histtax-rate-value BR-tax-rate
         BR-tax-rate-value mark-numtax-rate
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*----------------------f--------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable nr as integer no-undo.
HIDE
mark-numtax-rate
in frame {&frame-name} .
assign
RS-DATE = 1
B-addtax-rate-value:POPUP-MENU IN FRAME Dialog-Frame  = MENU MENU-B-addtax-rate-value:HANDLE
b-addtax-rate-value:MENU-MOUSE in frame {&frame-name} = 1
nr = BR-taxes:height-chars
menu-item m_global:sensitive in menu menu-b-addtax-rate-value = (if v-cntxt-db-num > 0 then no  else yes)
menu-item m_host:sensitive in menu menu-b-addtax-rate-value = (if v-cntxt-db-num > 0 then no  else yes)
.

ENABLE
B-exit
B-seltax when lookup("b-seltax":U, bttns) > 0
B-chgtax when (v-cntxt-db-num = 0 AND not (parobj-type = "":U and parobj-code = 0))
b-taxgds
B-Help
b-taxhist
BR-taxes
B-seltax-rate when lookup("b-seltax-rate":U, bttns) > 0
B-addtax-rate when (v-cntxt-db-num = 0 AND NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
B-chgtax-rate when (v-cntxt-db-num = 0 AND NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
B-deltax-rate  when (v-cntxt-db-num = 0 AND NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
B-marktax-rate when lookup("b-marktax-rate":U, bttns) > 0
B-histtax-rate
b-gdstax-rate
BR-tax-rate
RS-DATE
b-addtax-rate-value when (NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
b-deltax-rate-value when (NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
b-histtax-rate-value when NOT ref-mode = "ALL-TAX-RATES":U
b-overvalue-rate-value when (NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
b-ext
BR-tax-rate-value
WITH FRAME Dialog-Frame.
if ref-mode = "ALL-TAX-RATES":U then dO:
    hide
    B-chgtax BR-taxes b-seltax B-taxgds B-taxhist
    in frame {&frame-name}.
        assign
        B-addtax-rate:row in frame {&frame-name} = B-addtax-rate:row in frame {&frame-name} - nr
        B-addtax-rate-value:row in frame {&frame-name} =  B-addtax-rate-value:row - nr
        B-chgtax-rate:row in frame {&frame-name} =  B-chgtax-rate:row - nr
        B-deltax-rate:row in frame {&frame-name} =  B-deltax-rate:row - nr
        B-deltax-rate-value:row in frame {&frame-name} =  B-deltax-rate-value:row - nr
        B-ext:row in frame {&frame-name} =  B-ext:row - nr
        B-gdstax-rate:row in frame {&frame-name} =  B-gdstax-rate:row - nr
        B-histtax-rate:row in frame {&frame-name} =  B-histtax-rate:row - nr
        B-histtax-rate-value:row in frame {&frame-name} =  B-histtax-rate-value:row - nr
        B-overvalue-rate-value:row in frame {&frame-name} =  B-overvalue-rate-value:row - nr
        B-marktax-rate:row in frame {&frame-name} =  B-marktax-rate:row - nr
        BR-tax-rate:row in frame {&frame-name} =  BR-tax-rate:row - nr
        br-tax-rate-name:row in frame {&frame-name} =  br-tax-rate-name:row - nr
        BR-tax-rate-value:row in frame {&frame-name} =  BR-tax-rate-value:row - nr
        br-tax-rate-value-name:row in frame {&frame-name} =  br-tax-rate-value-name:row - nr
        B-seltax-rate:row in frame {&frame-name} =  B-seltax-rate:row - nr
        mark-numtax-rate:row in frame {&frame-name} =  mark-numtax-rate:row - nr
        RS-date:row in frame {&frame-name} = RS-date:row - nr
        .
        DISPLAY br-tax-rate-name
                with frame {&frame-name}.
end.
HIDE
b-addtax
b-deltax
in frame {&frame-name}.


VIEW FRAME Dialog-Frame.

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
CASE ref-mode:
    when "ALL":U then do:
        OPEN QUERY BR-taxes FOR EACH ub.tax NO-LOCK.
    end.
    otherwise do:
           OPEN QUERY BR-taxes FOR EACH ub.tax NO-LOCK.
       end.
END CASE.
APPLY "VALUE-CHANGED" to br-taxes in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr-tax-rate Dialog-Frame
PROCEDURE Openbr-tax-rate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
CASE ref-mode:
    when "ALL":U then do:
        Open query br-tax-rate for each ub.tax-rate where
                                        ub.tax-rate.tax-code = ub.tax.tax-code NO-LOCK.
        br-tax-rate-name = "Ставки по налогу с кодом " + string(ub.tax.tax-code).
            display
            br-tax-rate-name
            with frame {&frame-name}.
    end.
    when "ALL-TAX-RATES":U then do:
        if var-tax-code = 0 then
        /*заменяет taxrates.w*/
        Open query br-tax-rate for each ub.tax-rate NO-LOCK.
        else do:
          br-tax-rate-name = "Ставки по налогу с кодом " + string(ub.tax.tax-code).
          Open query br-tax-rate for each ub.tax-rate where
                                          ub.tax-rate.tax-code = var-tax-code NO-LOCK.
          display
          br-tax-rate-name
          with frame {&frame-name}.

          REPOSITION BR-tax-rate to recid integer(v-tax-rate-rid) no-error.
          APPLY "ENTRY" to BR-tax-rate.
        end.
    end.
END CASE.

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
define var var-tt-rc as recid.
define var var-fact-order like ub.tax-rate-value.fact-order no-undo.
define var var-ismarked-rate as logical no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer bf_tt-tax-rate-value for tt-tax-rate-value.
run cur-time in this-procedure(output v-today, output v-time).
run factord-end-day in this-procedure (input v-today, output var-fact-order).
for each tt-tax-rate-value:
    delete tt-tax-rate-value.
end.
if not available ub.tax-rate then do:
  open query br-tax-rate-value for each tt-tax-rate-value no-lock.
  return.
end.
var-ismarked-rate = var-ismarked and CAN-DO (v-tax-rate-rid, string( recid(ub.tax-rate))).
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
      if tax-rate-value.fact-date <= v-today AND
        (not var-ismarked or var-ismarked-rate)  AND
        tax-rate-value.status_ = {&current-status}
      then
      var-rc = recid(ub.tax-rate-value).
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
        if (not var-ismarked or var-ismarked-rate) then
        var-rc = recid(ub.tax-rate-value).
    end.
  end.
END CASE.

    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code > 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0 AND
            (par-date-option = {&all-dates} or ub.tax-rate-value.fact-order <= var-fact-order) AND
            (par-date-option = {&all-dates} or ub.tax-rate-value.status_ = {&current-status})

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
            if tax-rate-value.fact-date <= v-today AND
               tax-rate-value.host-code = parhost-code AND
               (not var-ismarked or var-ismarked-rate) AND
               tax-rate-value.status_ = {&current-status}
            then
            var-rc = recid(ub.tax-rate-value).

      end.
    end.
   for each tt-tax-rate-value where
            tt-tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            tt-tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            tt-tax-rate-value.host-code = 0:
    tt-tax-rate-value.exp = yes.
   end.
    /*добавим все по данной фирме*/
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = parhost-code AND
            ub.tax-rate-value.obj-type <> "" AND
            ub.tax-rate-value.obj-code <> 0 AND
            (par-date-option = {&all-dates} or ub.tax-rate-value.fact-order <= var-fact-order) AND
            (par-date-option = {&all-dates} or ub.tax-rate-value.status_ = {&current-status})
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
    :
    if par-date-option = {&all-dates}
    or last-of(ub.tax-rate-value.obj-code)
    then do:
        create
        tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to tt-tax-rate-value
        assign
        tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
               if tax-rate-value.fact-date <= v-today AND
                   tax-rate-value.host-code = parhost-code AND
                   tax-rate-value.obj-type = parobj-type AND
                   tax-rate-value.obj-code = parobj-code AND
                   (not var-ismarked or var-ismarked-rate) AND
                   tax-rate-value.status_ = {&current-status}
               then
               var-rc = recid(ub.tax-rate-value).
    end.
  end.
  for each tt-tax-rate-value where
        tt-tax-rate-value.tax-code = ub.tax-rate.tax-code AND
        tt-tax-rate-value.rate-code = ub.tax-rate.rate-code AND
        tt-tax-rate-value.host-code = parhost-code :
     tt-tax-rate-value.exp = yes.
  end.
find first tt-tax-rate-value where
    tt-tax-rate-value.rc = var-rc no-lock no-error.
    if avail tt-tax-rate-value then
    var-tt-rc = recid(tt-tax-rate-value).

open query br-tax-rate-value for each tt-tax-rate-value no-lock.
reposition br-tax-rate-value to recid var-tt-rc no-error.
br-tax-rate-value-name = "Значения ставки налога с кодом " +
                                                  string(tax-rate.tax-code) +
                         ": код ставки " + string(tax-rate.rate-code).
display
br-tax-rate-value-name
with frame {&frame-name}.
if br-tax-rate-value:focused-row in frame {&frame-name} = 1 then do:
    glog = br-tax-rate-value:SELECT-PREV-ROW( ) .
    if glog then do:
        APPLY "CURSOR-DOWN" to br-tax-rate-value.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-addtax-rate-value Dialog-Frame
PROCEDURE proc-b-addtax-rate-value :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER par-option as character no-undo.
DEFINE INPUT PARAMETER par-date as integer no-undo.
define buffer b_tt-tax-rate-value for tt-tax-rate-value.

case par-option
:
  when "GLOBAL":U
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_tax-rate-values_global-update':U
      {&cntxt-firm}
      0
      '':U
      0
      0
      0
      0
      true
      glog
    }
  end.
  when "HOST":U
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_tax-rate-values_firm-update':U
      {&cntxt-firm}
      parhost-code
      '':U
      0
      0
      0
      0
      true
      glog
    }
  end.
  when "OBJECT":U
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_tax-rate-values_object-update':U
      {&cntxt-object}
      parhost-code
      parobj-type
      parobj-code
      0
      0
      0
      true
      glog
    }
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение режима" skip
      "par-option" par-option skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end case .
if not glog then return error.
if not avail ub.tax-rate then return no-apply.
if ub.tax-rate.status_ = {&deleted-status} then do:
  message "Нельзя добавить значениe к удаленной ставке"
  view-as alert-box error .
  return error.
end.
ri = recid(ub.tax-rate).
CASE par-option:
    when "GLOBAL":U then do:
        run ref/taxvali.w ( input {&add-def},
                            input 0,
                            input "":U,
                            input 0,
                            input-output ri ) no-error.
        if error-status:error then return error.
    end.
    when "HOST":U then do:
        run ref/taxvali.w ( input {&add-def},
                            input parhost-code,
                            input "":U,
                            input 0,
                            input-output ri ) no-error.
        if error-status:error then return error.
    end.
    when "OBJECT":U then do:
        run ref/taxvali.w ( input {&add-def},
                            input parhost-code,
                            input parobj-type,
                            input parobj-code,
                            input-output ri ) no-error.
        if error-status:error then return error.
    end.
END CASE.
if ri <> ? then  do:
    run OpenBr-tax-rate-value(par-date).
    if var-rc <> ri then do:
      FIND FIRST b_tt-tax-rate-value No-LOCK WHERE
                 b_tt-tax-rate-value.rc = ri No-ERROR.
      if avail b_tt-tax-rate-value then
      reposition br-tax-rate-value to recid recid(b_tt-tax-rate-value) no-error.
      apply "ENTRY" to br-tax-rate-value in frame {&frame-name}.
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-ext Dialog-Frame
PROCEDURE proc-b-ext :
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
define buffer bf_tt-tax-rate-value for tt-tax-rate-value.
/*самый подробный уровень уходим*/
if tt-tax-rate-value.host-code <> 0 and
   tt-tax-rate-value.obj-type <> "":U and
   tt-tax-rate-value.obj-code <> 0 THEN do:
   BELL.
   return error.
end.
run cur-time in this-procedure(output v-today, output v-time).
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
      else dO:
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
      end. /*вгутри звездочки нет*/
    end. /*удаляем*/
    else do: /*расширяем*/
      /*расширяем до фирм*/
      FOR EACH ub.tax-rate-value NO-LOCK where
              ub.tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
              ub.tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
              ub.tax-rate-value.host-code <> 0 AND
              ub.tax-rate-value.obj-type = "" AND
              ub.tax-rate-value.obj-code = 0 AND
              (par-date-option = {&all-dates} or ub.tax-rate-value.fact-order <= var-fact-order) AND
              (par-date-option = {&all-dates} or ub.tax-rate-value.status_ = {&current-status})
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
              b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
              b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
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
     end. /*звездочки нет*/
   end. /*убиваем*/
   else do: /*расширяем*/
      /* расширяем до объектов*/
      FOR EACH ub.tax-rate-value NO-LOCK where
            ub.tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
            ub.tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
            ub.tax-rate-value.host-code = tt-tax-rate-value.host-code AND
            ub.tax-rate-value.obj-type <> "" AND
            ub.tax-rate-value.obj-code <> 0 AND
            (par-date-option = {&all-dates} or ub.tax-rate-value.fact-order <= var-fact-order) AND
            (par-date-option = {&all-dates} or ub.tax-rate-value.status_ = {&current-status})
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-marktax-rate Dialog-Frame
FUNCTION get-envd RETURNS CHARACTER
  ( input i-tax-code as integer, i-rate-code as integer) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer tax-rate-attr for tax-rate-attr.

define variable vIsENVD as logical no-undo.

find first tax-rate-attr where
           tax-rate-attr.tax-code  = i-tax-code
       and tax-rate-attr.rate-code = i-rate-code
       and tax-rate-attr.attr-code = "envd"
no-lock no-error.
vIsENVD =  AVAILABLE tax-rate-attr.
return string(vIsENVD, "+/").
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-marktax-rate Dialog-Frame
FUNCTION get-marktax-rate RETURNS CHARACTER
  ( input par-ismarked as logical, input par-rid as recid, input par-tax-rate-rid as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable var-mark as character no-undo.
var-mark = IF par-ismarked and  CAN-DO (par-tax-rate-rid, string( par-rid )) THEN ("*") ELSE (" ").
return var-mark.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-region Dialog-Frame
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = "" and
       parobj-code = 0 then do:
       par-region = fill({&space-char}, 2) + "Фирма" + {&space-char} + string(parhost-code).
       return par-region.
    end.
    par-region = fill({&space-char}, 4) + parobj-type + {&space-char} + string(parobj-code).
    return par-region.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-types Dialog-Frame
FUNCTION get-types RETURNS CHARACTER
  ( input partax-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER loc-tax-units for ub.tax-units.
DEFINE VARIABLE var-units-types as character no-undo .
define variable is-first as logical no-undo init yes.
    FOR EACH loc-tax-units No-LOCK WHERE
            loc-tax-units.tax-code = partax-code:
            var-units-types = var-units-types +
                              (if is-first then "":U else ({&comma-char} + {&space-char})) +
                              loc-tax-units.type.
        is-first = no.
    END.


  RETURN var-units-types.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME