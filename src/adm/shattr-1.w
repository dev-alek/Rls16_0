&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE TEMP-TABLE tt-sale-add NO-UNDO LIKE ub.clients
       field doc-kind as character
       field doc-kind-label as character
       index pi is primary unique doc-kind.
DEFINE TEMP-TABLE tt-trn-doc NO-UNDO LIKE ub.trn-doc.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "autosale"

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
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'autosale'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/clntattr.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ rep/r-pychk0.i defalgo }
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
define variable v-ref-rec as recid no-undo .
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER cli-buf FOR ub.clients .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-sale-add

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-sale-add tt-trn-doc

/* Definitions for BROWSE BR-sale-add                                   */
&Scoped-define FIELDS-IN-QUERY-BR-sale-add doc-kind-label ~
tt-sale-add.obj-type tt-sale-add.obj-code tt-sale-add.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-sale-add
&Scoped-define QUERY-STRING-BR-sale-add FOR EACH tt-sale-add NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-sale-add OPEN QUERY BR-sale-add FOR EACH tt-sale-add NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-sale-add tt-sale-add
&Scoped-define FIRST-TABLE-IN-QUERY-BR-sale-add tt-sale-add


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-trn-doc.wrkr tt-trn-doc.agnt ~
tt-trn-doc.boss
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-trn-doc.wrkr ~
tt-trn-doc.agnt tt-trn-doc.boss
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-trn-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-trn-doc
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-sale-add}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-trn-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-trn-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-trn-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-trn-doc.wrkr tt-trn-doc.agnt ~
tt-trn-doc.boss
&Scoped-define ENABLED-TABLES tt-trn-doc
&Scoped-define FIRST-ENABLED-TABLE tt-trn-doc
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help t-automail ~
t-one-sale-per-day t-augetres t-close-day-period t-autocalc t-pay-gds-algo ~
t-autoclos t-autocomp t-one-curs t-sale-filter t-prcl-spl t-autofbr ~
t-restdish t-restingr rs-tpsi-mode t-main-tpsi t-resttpsi t-neg-tpsi-weight ~
f-neg-tpsi-qnty t-neg-tpsi-oper t-close-in-rfsl BR-sale-add B-sc-update ~
B-sc-clear r-wrkr r-agnt r-boss wrkr-name agnt-name boss-name
&Scoped-Define DISPLAYED-FIELDS tt-trn-doc.wrkr tt-trn-doc.agnt ~
tt-trn-doc.boss
&Scoped-define DISPLAYED-TABLES tt-trn-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-trn-doc
&Scoped-Define DISPLAYED-OBJECTS t-automail t-one-sale-per-day t-augetres ~
t-close-day-period t-autocalc t-pay-gds-algo t-autoclos t-autocomp ~
t-one-curs t-sale-filter t-prcl-spl t-autofbr t-restdish t-restingr ~
rs-tpsi-mode t-main-tpsi t-resttpsi t-neg-tpsi-weight f-neg-tpsi-qnty ~
t-neg-tpsi-oper t-close-in-rfsl wrkr-name agnt-name boss-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sc-clear 
     LABEL "&Сбросить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-sc-update
     LABEL "<-&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .87.

DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .87.

DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .87.

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 10.5 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 10.5 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE f-neg-tpsi-qnty AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0
     LABEL "уводить в отриц.ост-ки чужой товар с количеством <"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 TOOLTIP "если чужого товара недостаточно" NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 10.5 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE rs-tpsi-mode AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", 1,
"2", 2
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-augetres AS LOGICAL INITIAL no
     LABEL "автом. резервирование после чтения чеков с кассы"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-autocalc AS LOGICAL INITIAL no
     LABEL "автом. расчет шапки накл. после входа в РАСЧЕТ ПРОДАЖИ"
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE t-autoclos AS LOGICAL INITIAL no
     LABEL "автом. закрытие продажи после удачного резервирования"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-autocomp AS LOGICAL INITIAL no
     LABEL "компенсация расход-возврат (в момент закрытия продажи)"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-autofbr AS LOGICAL INITIAL no
     LABEL "автом. пр-во необходимых блюд (для РЕСТОРАНА)"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-automail AS LOGICAL INITIAL no
     LABEL "автом. чтение чеков с кассы после входа в РАСЧЕТ ПРОДАЖИ"
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE t-close-day-period AS LOGICAL INITIAL no 
     LABEL "закрыть период по дате продажи" 
     VIEW-AS TOGGLE-BOX
     SIZE 37.3 BY 1 TOOLTIP "Не разрешено делать более одной продажи в день (за смену)" NO-UNDO.

DEFINE VARIABLE t-close-in-rfsl AS LOGICAL INITIAL no
     LABEL "закрывать приход по техпроливу на факт"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-main-tpsi AS LOGICAL INITIAL no
     LABEL "Объект-распределитель"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY 1 TOOLTIP "объект, принимающий чеки с <общих> касс ТПСИ" NO-UNDO.

DEFINE VARIABLE t-neg-tpsi-oper AS LOGICAL INITIAL no
     LABEL "уводить в отриц.ост-ки чужой товар по отметке оператора (для ТПСИ)"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-neg-tpsi-weight AS LOGICAL INITIAL no
     LABEL "уводить в отриц.ост-ки чужой весовой товар на объекте продажи (для ТПСИ)"
     VIEW-AS TOGGLE-BOX
     SIZE 76 BY 1 TOOLTIP "если чужого вес.товара недостаточно" NO-UNDO.

DEFINE VARIABLE t-one-curs AS LOGICAL INITIAL no
     LABEL "в продажу чеки только с одним значением курса баз.вал."
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-one-sale-per-day AS LOGICAL INITIAL no
     LABEL "один день-одна продажа"
     VIEW-AS TOGGLE-BOX
     SIZE 37.3 BY 1 TOOLTIP "Не разрешено делать более одной продажи в день (за смену)" NO-UNDO.

DEFINE VARIABLE t-pay-gds-algo AS LOGICAL INITIAL no
     LABEL "разбивка по типам касс.плат."
     VIEW-AS TOGGLE-BOX
     SIZE 37.3 BY 1 TOOLTIP "Разбивка строк чека по типам касс.плат. при закачке чека в продажу для дальнейш" NO-UNDO.

DEFINE VARIABLE t-prcl-spl AS LOGICAL INITIAL no
     LABEL "Значение цены в продаже брать из прайс-листа (не из чека)"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-restdish AS LOGICAL INITIAL no
     LABEL "учет остатков блюд при резервировании (для автом. пр-ва)"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-restingr AS LOGICAL INITIAL no
     LABEL "учет остатков ингридиентов при резервировании (для автом. пр-ва)"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-resttpsi AS LOGICAL INITIAL no
     LABEL "учет остатков товаров при резервировании (для ТПСИ)"
     VIEW-AS TOGGLE-BOX
     SIZE 66.5 BY 1 TOOLTIP "резервировать остатки чужого товара на объекте продажи" NO-UNDO.

DEFINE VARIABLE t-sale-filter AS LOGICAL INITIAL no
     LABEL "в продажу чеки только по фильтру (если задан)"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-sale-add FOR
      tt-sale-add SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-trn-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-sale-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-sale-add Dialog-Frame _STRUCTURED
  QUERY BR-sale-add NO-LOCK DISPLAY
      doc-kind-label COLUMN-LABEL "Предназначен" FORMAT "X(20)":U
            WIDTH 22
      tt-sale-add.obj-type FORMAT "X(3)":U
      tt-sale-add.obj-code COLUMN-LABEL "Код" FORMAT ">>>>>>>>9":U
      tt-sale-add.obj-name FORMAT "X(40)":U WIDTH 28.3
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 66 BY 4.5
         TITLE "Контрагенты для дополнительных документов, создаваемых по продаже" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     t-automail AT ROW 2 COL 1
     t-one-sale-per-day AT ROW 2 COL 62 WIDGET-ID 22
     t-augetres AT ROW 3 COL 1
     t-close-day-period AT ROW 3 COL 62 WIDGET-ID 24
     t-autocalc AT ROW 4 COL 1
     t-pay-gds-algo AT ROW 4 COL 62 WIDGET-ID 28
     t-autoclos AT ROW 5 COL 1
     t-autocomp AT ROW 6 COL 1
     t-one-curs AT ROW 7 COL 1
     t-sale-filter AT ROW 8 COL 1
     t-prcl-spl AT ROW 9 COL 1
     t-autofbr AT ROW 10 COL 1
     t-restdish AT ROW 11 COL 1
     t-restingr AT ROW 12 COL 1
     rs-tpsi-mode AT ROW 13 COL 28 NO-LABEL
     t-main-tpsi AT ROW 13 COL 71
     t-resttpsi AT ROW 14 COL 1
     t-neg-tpsi-weight AT ROW 15 COL 1
     f-neg-tpsi-qnty AT ROW 16 COL 54 COLON-ALIGNED
     t-neg-tpsi-oper AT ROW 17 COL 1
     t-close-in-rfsl AT ROW 18 COL 1 WIDGET-ID 26
     BR-sale-add AT ROW 19 COL 1
     B-sc-update AT ROW 19.13 COL 67.5
     B-sc-clear AT ROW 19 COL 78 WIDGET-ID 30
     tt-trn-doc.wrkr AT ROW 20.47 COL 74 COLON-ALIGNED WIDGET-ID 18
          LABEL "К&л-к"
          VIEW-AS FILL-IN
          SIZE 8.8 BY 1
          FONT 4
     r-wrkr AT ROW 20.47 COL 96.1 WIDGET-ID 14
     tt-trn-doc.agnt AT ROW 21.47 COL 74 COLON-ALIGNED WIDGET-ID 2
          LABEL "И&сп"
          VIEW-AS FILL-IN
          SIZE 8.8 BY 1
          FONT 4
     r-agnt AT ROW 21.47 COL 96 WIDGET-ID 10
     tt-trn-doc.boss AT ROW 22.47 COL 74 COLON-ALIGNED WIDGET-ID 6
          LABEL "&М-р"
          VIEW-AS FILL-IN
          SIZE 8.8 BY 1
          FONT 4
     r-boss AT ROW 22.47 COL 96 WIDGET-ID 12
     wrkr-name AT ROW 20.47 COL 83.5 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     agnt-name AT ROW 21.47 COL 83.5 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     boss-name AT ROW 22.47 COL 83.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     "Режим работы ТПСИ" VIEW-AS TEXT
          SIZE 19.5 BY 1 AT ROW 13 COL 4
          FGCOLOR 4
     "Проставлять в док-ты:" VIEW-AS TEXT
          SIZE 20.5 BY 1 AT ROW 19.13 COL 78.5 WIDGET-ID 16
          FGCOLOR 4
     SPACE(0.30) SKIP(3.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Набор опций работы с продажей"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-sale-add T "?" NO-UNDO ub clients
      ADDITIONAL-FIELDS:
          field doc-kind as character
          field doc-kind-label as character
          index pi is primary unique doc-kind
      END-FIELDS.
      TABLE: tt-trn-doc T "?" NO-UNDO ub trn-doc
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-sale-add t-close-in-rfsl Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-trn-doc.agnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-trn-doc.boss IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-trn-doc.wrkr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-sale-add
/* Query rebuild information for BROWSE BR-sale-add
     _TblList          = "Temp-Tables.tt-sale-add"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"doc-kind-label" "Предназначен" "X(20)" ? ? ? ? ? ? ? no ? no no "22" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.tt-sale-add.obj-type
     _FldNameList[3]   > Temp-Tables.tt-sale-add.obj-code
"tt-sale-add.obj-code" "Код" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-sale-add.obj-name
"tt-sale-add.obj-name" ? ? "character" ? ? ? ? ? ? no ? no no "28.3" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BR-sale-add */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-trn-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Набор опций работы с продажей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-trn-doc.agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.agnt Dialog-Frame
ON LEAVE OF tt-trn-doc.agnt IN FRAME Dialog-Frame /* Исп */
DO:
  if input frame {&frame-name} tt-trn-doc.agnt <> tt-trn-doc.agnt then do:
    run local-psn-chk ("agnt", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.agnt Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.agnt IN FRAME Dialog-Frame /* Исп */
OR RETURN OF tt-trn-doc.agnt IN FRAME {&frame-name} DO:
  run local-psn-chk ("agnt", "ret-mouse").
  apply "entry" to tt-trn-doc.boss in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-sc-clear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sc-clear Dialog-Frame
ON CHOOSE OF B-sc-clear IN FRAME Dialog-Frame /* Сбросить */
DO:
    /* Очистим от контрагента */
    DEFINE BUFFER buf_tt-sale-add FOR tt-sale-add.

    FIND FIRST buf_tt-sale-add WHERE
              buf_tt-sale-add.doc-kind = tt-sale-add.doc-kind.
    ASSIGN
    buf_tt-sale-add.obj-type = ''
    buf_tt-sale-add.obj-code = 0
    buf_tt-sale-add.obj-name = ''
    .
    br-sale-add:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME B-sc-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sc-update Dialog-Frame
ON CHOOSE OF B-sc-update IN FRAME Dialog-Frame /* <-Изменить */
DO:
  define VARIable v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_tt-sale-add FOR tt-sale-add.
  DEFINE BUFFER buf_clients FOR ub.clients.

  IF NOT AVAILABLE tt-sale-add THEN DO:
      message
      "Выберите Предназначение документа, для которого вы хотите установить КОНТРАГЕНТА"
      VIEW-AS ALERT-BOX.
  END.
  run ref/cli-all.w (
                 input parparentproc
                ,input "b-sel"
                ,input {&cmp}
                ,input {&all}
                ,input {&current}
                ,input ?
                ,input ",,,,,,NO,,"
                ,input ""
                ,output v-rid-list ) NO-ERROR.
  IF v-rid-list = '':U THEN RETURN NO-APPLY.
  FIND FIRST buf_clients NO-LOCK WHERE
            recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
  FIND FIRST buf_tt-sale-add WHERE
            buf_tt-sale-add.doc-kind = tt-sale-add.doc-kind.
  ASSIGN
  buf_tt-sale-add.obj-type = buf_clients.obj-type
  buf_tt-sale-add.obj-code = buf_clients.obj-code
  buf_tt-sale-add.obj-name = buf_clients.obj-name
  .
  br-sale-add:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-trn-doc.boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.boss Dialog-Frame
ON LEAVE OF tt-trn-doc.boss IN FRAME Dialog-Frame /* М-р */
DO:
  if input frame {&frame-name} tt-trn-doc.boss <> tt-trn-doc.boss then do:
    run local-psn-chk ("boss", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.boss Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.boss IN FRAME Dialog-Frame /* М-р */
OR RETURN OF tt-trn-doc.boss IN FRAME {&frame-name} DO:
  run local-psn-chk ("boss", "ret-mouse").
  apply "entry" to tt-trn-doc.boss in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-agnt Dialog-Frame
ON CHOOSE OF r-agnt IN FRAME Dialog-Frame /* r-acc */
DO:
  RUN local-psn-chk ("agnt", "button").
  apply "entry" to tt-trn-doc.agnt in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-boss Dialog-Frame
ON CHOOSE OF r-boss IN FRAME Dialog-Frame /* r-acc */
DO:
  RUN local-psn-chk ("boss", "button").
  apply "entry" to tt-trn-doc.boss in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-wrkr Dialog-Frame
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame /* r-acc */
DO:
  RUN local-psn-chk ("wrkr", "button").
  apply "entry" to tt-trn-doc.wrkr in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-tpsi-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-tpsi-mode Dialog-Frame
ON VALUE-CHANGED OF rs-tpsi-mode IN FRAME Dialog-Frame
DO:
    ASSIGN
  rs-tpsi-mode.
  CASE rs-tpsi-mode:
    WHEN 1 THEN DO:
      ASSIGN
      t-main-tpsi = NO.
      DISPLAY
      t-main-tpsi
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      t-main-tpsi
      WITH FRAME {&FRAME-NAME}.
      if p-mode = {&update} then
      ENABLE
      f-neg-tpsi-qnty
      t-neg-tpsi-oper
      t-neg-tpsi-weight
      t-resttpsi
      WITH FRAME {&FRAME-NAME}.
    END.
    WHEN 2 THEN DO:
      ASSIGN
      f-neg-tpsi-qnty  = 0
      t-neg-tpsi-oper  = NO
      t-neg-tpsi-weight  = NO
      t-resttpsi = NO.
      DISPLAY
      f-neg-tpsi-qnty
      t-neg-tpsi-oper
      t-neg-tpsi-weight
      t-resttpsi
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      f-neg-tpsi-qnty
      t-neg-tpsi-oper
      t-neg-tpsi-weight
      t-resttpsi
      WITH FRAME {&FRAME-NAME}.
      if p-mode = {&update} then
      ENABLE
      t-main-tpsi
      WITH FRAME {&FRAME-NAME}.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-autofbr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-autofbr Dialog-Frame
ON VALUE-CHANGED OF t-autofbr IN FRAME Dialog-Frame /* автом. пр-во необходимых блюд (для РЕСТОРАНА) */
DO:
  IF p-mode = {&LOOKUP}  THEN RETURN NO-APPLY.
  ASSIGN
  t-autofbr.
  CASE t-autofbr:
      WHEN YES THEN DO:
         ENABLE
         t-restdish
         t-restingr
         WITH FRAME {&FRAME-NAME}.
      END.
      WHEN NO THEN DO:
          ASSIGN
           t-restdish = NO
           t-restingr = NO.
          DISPLAY
          t-restdish
          t-restingr
          WITH FRAME {&frame-name}.
          disable
          t-restdish
          t-restingr
          WITH FRAME {&FRAME-NAME}.
     END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-one-sale-per-day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-one-sale-per-day Dialog-Frame
ON VALUE-CHANGED OF t-one-sale-per-day IN FRAME Dialog-Frame /* один день-одна продажа */
DO:
  ASSIGN
  t-one-sale-per-day.
  CASE t-one-sale-per-day:
    WHEN NO THEN DO:
      if p-mode <> {&lookup} then do:
        ASSIGN
        t-close-day-period = NO
        .
      end.
      DISPLAY
      t-close-day-period
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      t-close-day-period
      WITH FRAME {&FRAME-NAME}.
    END.
    WHEN YES THEN DO:
      if p-mode <> {&lookup} then do:
        Enable
        t-close-day-period
        WITH FRAME {&FRAME-NAME}.
      end.
   END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-trn-doc.wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.wrkr Dialog-Frame
ON LEAVE OF tt-trn-doc.wrkr IN FRAME Dialog-Frame /* Кл-к */
DO:
  if input frame {&frame-name} tt-trn-doc.wrkr <> tt-trn-doc.wrkr then do:
    run local-psn-chk ("wrkr", "leave").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.wrkr Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.wrkr IN FRAME Dialog-Frame /* Кл-к */
OR RETURN OF tt-trn-doc.wrkr IN FRAME {&frame-name} DO:
  run local-psn-chk ("wrkr", "ret-mouse").
  apply "entry" to tt-trn-doc.agnt in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-sale-add
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
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
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
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-autosale}
        AND LOCKED_thbj-attr.prop-code = "":U
        NO-WAIT NO-ERROR.
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
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-autosale}
    AND   LOCKED_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.
  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN Myenable in this-procedure .
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY t-automail t-one-sale-per-day t-augetres t-close-day-period t-autocalc 
          t-pay-gds-algo t-autoclos t-autocomp t-one-curs t-sale-filter
          t-prcl-spl t-autofbr t-restdish t-restingr rs-tpsi-mode t-main-tpsi
          t-resttpsi t-neg-tpsi-weight f-neg-tpsi-qnty t-neg-tpsi-oper
          t-close-in-rfsl wrkr-name agnt-name boss-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-trn-doc THEN 
    DISPLAY tt-trn-doc.wrkr tt-trn-doc.agnt tt-trn-doc.boss 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help t-automail t-one-sale-per-day t-augetres
         t-close-day-period t-autocalc t-pay-gds-algo t-autoclos t-autocomp
         t-one-curs t-sale-filter t-prcl-spl t-autofbr t-restdish t-restingr
         rs-tpsi-mode t-main-tpsi t-resttpsi t-neg-tpsi-weight f-neg-tpsi-qnty
         t-neg-tpsi-oper t-close-in-rfsl BR-sale-add B-sc-update B-sc-clear 
         tt-trn-doc.wrkr r-wrkr tt-trn-doc.agnt r-agnt tt-trn-doc.boss r-boss
         wrkr-name agnt-name boss-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-sale-add as character no-undo .
DEFINE VARIABLE v-doc-kind AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-kind-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cli-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE VARIABLE v-cli-code LIKE ub.clients.obj-code NO-UNDO.
DEFINE VARIABLE v-obj-name LIKE ub.clients.obj-name NO-UNDO.
DEFINE BUFFER buf_clients FOR ub.clients.
FOR EACH tt-trn-doc:
  DELETE tt-trn-doc.
END.
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.

CREATE tt-trn-doc.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-autosale}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT table-handle v-tth
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
  IF v-entry = {&attr-autosale_autoclos} THEN DO:
    ASSIGN
    t-autoclos = thbjattr_thbj-attr.property-value-logical
    t-autoclos:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_automail} THEN DO:
    ASSIGN
    t-automail = thbjattr_thbj-attr.property-value-logical
    t-automail:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_augetres} THEN DO:
    ASSIGN
    t-augetres = thbjattr_thbj-attr.property-value-logical
    t-augetres:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_autocalc} THEN DO:
    ASSIGN
    t-autocalc = thbjattr_thbj-attr.property-value-logical
    t-autocalc:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_autocomp} THEN DO:
    ASSIGN
    t-autocomp = thbjattr_thbj-attr.property-value-logical
    t-autocomp:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_one-curs} THEN DO:
    ASSIGN
    t-one-curs = thbjattr_thbj-attr.property-value-logical
    t-one-curs:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_prcl-spl} THEN DO:
    ASSIGN
    t-prcl-spl = thbjattr_thbj-attr.property-value-logical
    t-prcl-spl:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_autofbr} THEN DO:
    ASSIGN
    t-autofbr = thbjattr_thbj-attr.property-value-logical
    t-autofbr:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_restdish} THEN DO:
    ASSIGN
    t-restdish = t-autofbr AND thbjattr_thbj-attr.property-value-logical = yes
    t-restdish:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_restingr} THEN DO:
    ASSIGN
    t-restingr = t-autofbr AND thbjattr_thbj-attr.property-value-logical = yes
    t-restingr:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_resttpsi} THEN DO:
    ASSIGN
    t-resttpsi = thbjattr_thbj-attr.property-value-logical
    t-resttpsi:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_sale-filter} THEN DO:
    ASSIGN
    t-sale-filter = thbjattr_thbj-attr.property-value-logical
    t-sale-filter:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_sale-add} THEN DO:
    ASSIGN
    v-sale-add = thbjattr_thbj-attr.property-value-character
    .
  END.
  IF v-entry = {&attr-autosale_neg-tpsi-weight} THEN DO:
    ASSIGN
    t-neg-tpsi-weight = thbjattr_thbj-attr.property-value-logical
    t-neg-tpsi-weight:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_neg-tpsi-qnty} THEN DO:
    ASSIGN
    f-neg-tpsi-qnty = thbjattr_thbj-attr.property-value-decimal
    f-neg-tpsi-qnty:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_neg-tpsi-oper} THEN DO:
    ASSIGN
    t-neg-tpsi-oper = thbjattr_thbj-attr.property-value-logical
    t-neg-tpsi-oper:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_tpsi-mode} THEN DO:
    ASSIGN
    rs-tpsi-mode = thbjattr_thbj-attr.property-value-integer
    rs-tpsi-mode:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_main-tpsi} THEN DO:
    ASSIGN
    t-main-tpsi = thbjattr_thbj-attr.property-value-logical
    t-main-tpsi:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_wrkr} THEN DO:
    ASSIGN
    tt-trn-doc.wrkr = thbjattr_thbj-attr.property-value-integer
    tt-trn-doc.wrkr:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry BEGINS {&attr-autosale_agnt} THEN DO:
    ASSIGN
    tt-trn-doc.agnt = thbjattr_thbj-attr.property-value-integer
    tt-trn-doc.agnt:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF v-entry BEGINS {&attr-autosale_boss} THEN DO:
    ASSIGN
    tt-trn-doc.boss = thbjattr_thbj-attr.property-value-integer
    tt-trn-doc.boss:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
    .
  END.
  IF v-entry = {&attr-autosale_one-sale-per-day} THEN DO:
    ASSIGN
    t-one-sale-per-day = thbjattr_thbj-attr.property-value-logical
    t-one-sale-per-day:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_close-day-period} THEN DO:
    ASSIGN
    t-close-day-period = thbjattr_thbj-attr.property-value-logical
    t-close-day-period:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-autosale_close-in-rfsl} THEN DO:
    ASSIGN
    t-close-in-rfsl = (if thbjattr_thbj-attr.property-value-integer = 1 then yes else no)
    .
  END.
  IF v-entry = {&attr-autosale_pay-gds-algo} THEN DO:
    ASSIGN
    t-pay-gds-algo = (if thbjattr_thbj-attr.property-value-character <> '' then yes else no)
    .
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
if tt-trn-doc.wrkr = 0 then tt-trn-doc.wrkr = ?.
if tt-trn-doc.agnt = 0 then tt-trn-doc.agnt = ?.
if tt-trn-doc.boss = 0 then tt-trn-doc.boss = ?.


&scop sale-doc-kind v-doc-kind

_ii:
DO ii = 1 TO NUM-ENTRIES(v-sale-add, ';'):
    ASSIGN
    v-entry =  ENTRY(ii, v-sale-add, ';':U)
    v-doc-kind = ENTRY(1, v-entry)
    v-cli-type = ENTRY(2, v-entry)
    v-cli-code = integer(ENTRY(3, v-entry))
    v-doc-kind-label = '':U
    .
    if v-doc-kind = {&sale-add-ret-nat-gas} then next _ii .
    assign
    v-doc-kind-label = {&sale-doc-name}
    no-error
    .
    if v-doc-kind-label = '':U then do:
        NEXT _ii.
    END.
    FIND FIRST tt-sale-add WHERE
                tt-sale-add.doc-kind = v-doc-kind NO-ERROR.
    IF NOT AVAILABLE tt-sale-add THEN DO:
        FIND FIRST buf_clients NO-LOCK WHERE
                  buf_clients.obj-type = v-cli-type
              AND buf_clients.obj-code =v-cli-code NO-ERROR.
        IF NOT AVAILABLE buf_clients THEN DO:
            ASSIGN
            v-cli-type = '':U
            v-cli-code = 0
            v-obj-name = '':U
            .
        END.
        ELSE DO:
            ASSIGN
            v-obj-name = buf_clients.obj-name
            .
        END.
        CREATE tt-sale-add.
        ASSIGN
        tt-sale-add.doc-kind = v-doc-kind
        tt-sale-add.doc-kind-label = v-doc-kind-label
        tt-sale-add.obj-type = v-cli-type
        tt-sale-add.obj-code = v-cli-code
        tt-sale-add.obj-name = v-obj-name
        .
        release tt-sale-add.
    END.
END.
do ii = 1 to num-entries({&sale-add-kinds}):
  if entry(ii, {&sale-add-kinds}) = {&sale-add-ret-nat-gas} then next .
  find first tt-sale-add where
            tt-sale-add.doc-kind = entry(ii, {&sale-add-kinds}) no-error .
&scop sale-doc-kind entry(ii, ~{&sale-add-kinds~})
  if not available tt-sale-add then do:
    CREATE tt-sale-add.
    ASSIGN
    tt-sale-add.doc-kind = entry(ii, {&sale-add-kinds})
    tt-sale-add.doc-kind-label = {&sale-doc-name}
    tt-sale-add.obj-type = '':U
    tt-sale-add.obj-code = 0
    tt-sale-add.obj-name = '':U
    .
    release tt-sale-add.
  end.
end.




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-psn-chk Dialog-Frame 
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
if p-man = {&attr-autosale_wrkr} and p-action = "ret-mouse" then do:
   { str/psn-chk.i wrkr ret-mouse tt-trn-doc v-ref-rec }
end.
if p-man = {&attr-autosale_wrkr} and p-action = "button" then do:
   { str/psn-chk.i wrkr button tt-trn-doc v-ref-rec }
end.
if p-man = {&attr-autosale_wrkr} and p-action = "leave" then do:
   { str/psn-chk.i wrkr leave tt-trn-doc v-ref-ref }
end.
if p-man = {&attr-autosale_agnt} and p-action = "ret-mouse" then do:
   { str/psn-chk.i agnt ret-mouse tt-trn-doc v-ref-rec }
end.
if p-man = {&attr-autosale_agnt} and p-action = "button" then do:
   { str/psn-chk.i agnt button tt-trn-doc v-ref-rec }
end.
if p-man = {&attr-autosale_agnt} and p-action = "leave" then do:
   { str/psn-chk.i agnt leave tt-trn-doc v-ref-rec }
end.
if p-man = {&attr-autosale_boss} and p-action = "ret-mouse" then do:
   { str/psn-chk.i boss ret-mouse tt-trn-doc v-ref-rec }
end.
if p-man = {&attr-autosale_boss} and p-action = "button" then do:
   { str/psn-chk.i boss button tt-trn-doc v-ref-rec }
end.
if p-man = {&attr-autosale_boss} and p-action = "leave" then do:
   { str/psn-chk.i boss leave tt-trn-doc v-ref-rec }
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
v-tab-order = "t-automail,t-one-day-per-sale,t-autocalc,t-close-day-period,t-augetres,t-pay-gds-algo,t-autoclos,t-autocomp,t-one-curs,t-autofbr,t-restdish,t-restingr,t-resttpsi," +
              "t-neg-tpsi-weight,f-neg-tpsi-qnty,t-neg-tpsi-oper,t-close-in-rfsl,br-sale-add,wrkr,r-wrkr,agnt,r-agnt,boss,r-boss".
find first tt-trn-doc.
{ str/psn-chk.i wrkr on tt-trn-doc v-ref-rec }
{ str/psn-chk.i agnt on tt-trn-doc v-ref-rec }
{ str/psn-chk.i boss on tt-trn-doc v-ref-rec }

DISPLAY
t-automail
t-autocalc
t-augetres
t-autoclos
t-autocomp
t-autofbr
t-restdish
t-restingr
t-one-curs
t-prcl-spl
t-resttpsi
t-neg-tpsi-weight
f-neg-tpsi-qnty
t-neg-tpsi-oper
t-sale-filter
t-one-sale-per-day
t-close-day-period
t-pay-gds-algo
rs-tpsi-mode
t-main-tpsi
tt-trn-doc.wrkr
tt-trn-doc.agnt
tt-trn-doc.boss
t-close-in-rfsl
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
t-automail WHEN p-mode = {&UPDATE}
t-one-sale-per-day WHEN p-mode = {&UPDATE}
t-pay-gds-algo WHEN p-mode = {&UPDATE}
t-autocalc WHEN p-mode = {&UPDATE}
t-augetres WHEN p-mode = {&UPDATE}
t-autoclos WHEN p-mode = {&UPDATE}
t-autocomp WHEN p-mode = {&UPDATE}
t-one-curs WHEN p-mode = {&UPDATE}
t-prcl-spl WHEN p-mode = {&UPDATE}
t-autofbr  WHEN p-mode = {&UPDATE}
t-restdish WHEN p-mode = {&UPDATE} AND t-autofbr
t-restingr WHEN p-mode = {&UPDATE} AND t-autofbr
t-resttpsi WHEN p-mode = {&UPDATE}
t-neg-tpsi-weight WHEN p-mode = {&UPDATE}
f-neg-tpsi-qnty   WHEN p-mode = {&UPDATE}
t-neg-tpsi-oper   WHEN p-mode = {&UPDATE}
t-sale-filter WHEN p-mode = {&UPDATE}
t-close-in-rfsl WHEN p-mode = {&UPDATE}
br-sale-add
b-sc-update WHEN p-mode = {&UPDATE}
b-sc-clear WHEN p-mode = {&UPDATE}
rs-tpsi-mode WHEN p-mode = {&UPDATE}
t-main-tpsi WHEN p-mode = {&UPDATE}
tt-trn-doc.wrkr WHEN p-mode = {&UPDATE}
tt-trn-doc.agnt WHEN p-mode = {&UPDATE}
tt-trn-doc.boss WHEN p-mode = {&UPDATE}
r-wrkr WHEN p-mode = {&UPDATE}
r-agnt WHEN p-mode = {&UPDATE}
r-boss WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    .
END.
APPLY "value-changed" TO t-autofbr.
APPLY "value-changed" TO rs-tpsi-mode.
APPLY "value-changed" TO t-one-sale-per-day.
{&OPEN-QUERY-{&BROWSE-NAME}}
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
define variable v-sale-add as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
DEFINE BUFFER buf_tt-sale-add FOR tt-sale-add.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
t-augetres
t-autocalc
t-autoclos
t-autocomp
t-one-curs
t-autofbr
t-automail
t-prcl-spl
t-sale-filter
rs-tpsi-mode
t-main-tpsi
t-one-sale-per-day
t-pay-gds-algo
t-close-in-rfsl
tt-trn-doc.wrkr
tt-trn-doc.agnt
tt-trn-doc.boss
tt-trn-doc.wrkr = if tt-trn-doc.wrkr = ? then 0 else tt-trn-doc.wrkr
tt-trn-doc.agnt = if tt-trn-doc.agnt = ? then 0 else tt-trn-doc.agnt
tt-trn-doc.boss = if tt-trn-doc.boss = ? then 0 else tt-trn-doc.boss
.
if t-one-sale-per-day then do:
  assign t-close-day-period .
end.
if p-obj-type = {&shop}
or p-obj-type = {&stock} then do:
  define variable l-shift-on as logical no-undo .
  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'shift-on=request'"
    l-shift-on
  }
  if l-shift-on and t-close-day-period then do:
    message
    "Не могут быть одновременно включены СМЕНЫ на объекте и режим закрытия периода по продаже"
    view-as alert-box error .
    undo, return no-apply.
  end.
end.
IF  t-autofbr then
ASSIGN
t-restdish
t-restingr
.
assign
t-resttpsi
t-neg-tpsi-weight
f-neg-tpsi-qnty
t-neg-tpsi-oper
.
FOR EACH buf_tt-sale-add :
   ASSIGN
   v-sale-add = v-sale-add + (IF v-sale-add = '':U THEN '':U ELSE ';':U) +
                    buf_tt-sale-add.doc-kind + {&comma-char} +
                    buf_tt-sale-add.obj-type + {&comma-char} +
                    string(buf_tt-sale-add.obj-code).
  if buf_tt-sale-add.doc-kind = {&sale-add-tech-refuell} then do:
    assign
    v-trf-type = buf_tt-sale-add.obj-type
    v-trf-code = buf_tt-sale-add.obj-code
    .
  end.
END.
assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  wh = wh:next-sibling.
end.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-autosale_sale-add}.
assign
thbjattr_thbj-attr.property-value-character = v-sale-add
.
release thbjattr_thbj-attr.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-autosale_close-in-rfsl}.
assign
thbjattr_thbj-attr.property-value-integer = (if t-close-in-rfsl then 1 else 0)
.
release thbjattr_thbj-attr.

find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-autosale_pay-gds-algo}.
assign
thbjattr_thbj-attr.property-value-character = (if t-pay-gds-algo then {&current-algo-1} else '')
.
release thbjattr_thbj-attr.


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
            , input {&attr-autosale}
            , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output table-handle v-tth
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
      ,input {&attr-autosale}
      ,INPUT table thbjattr_thbj-attr
  ) NO-ERROR.
  IF ERROR-STATUS:error THEN do:
    MESSAGE ERROR-STATUS:get-message(1)  SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
  if v-trf-code <> 0 then do:
    RUN clntattr-write IN THIS-PROCEDURE (
        input v-trf-type
        ,input v-trf-code
        ,input {&attr-shftrep2}
        ,input string(yes)
    ) NO-ERROR.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

