&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt_fin-ob-tax NO-UNDO LIKE fin-ob-tax.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма ввода и корректировки фин-обязательства ПОСТАВЩИКУ

Автор: Чернова Светлана Александровна
Дата создания: 10/22/03
Author: Svetlana Chernova
Creation date: 10/22/03

Открывается  9


*/
/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc   as widget-handle no-undo.
define input parameter ref-mode        as character no-undo .
define input-output parameter ri       as recid no-undo.
define input parameter par-host-code as integer no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-status_  as character no-undo .
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма ввода и корректировки фин-обязательства ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ gbl/usr-flt.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }

&scop singl-mode  'singl-mode':u
&scop trio-mode   'trio-mode':u

define variable tcode as character no-undo .
define variable loc_contract-code-id  like fin-ob.contract-code        no-undo .
define variable g-log                 as logical   no-undo .
define variable pp-modif              as logical init false  no-undo .
define variable p-doc-date            like fin-ob.doc-date             no-undo .
define variable p-payer-name          like fin-ob.payer-name             no-undo .
define variable p-receiver-name       like fin-ob.receiver-name             no-undo .
define variable p-curr-code           like fin-ob.curr-code            no-undo .
define variable p-sum-doc             like fin-ob.sum-doc              no-undo .
define variable p-user-db-num-doc     like fin-ob.user-db-num-doc      no-undo .
define variable p-user-name-doc       like fin-ob.user-name-doc        no-undo .
define variable p-base-rate           like fin-ob.base-rate            no-undo .
define variable p-base-scale          like fin-ob.base-scale           no-undo .
define variable p-receiver-code       like fin-ob.receiver-code             no-undo .
define variable p-receiver-type       like fin-ob.receiver-type             no-undo .
define variable p-contract-code       like fin-ob.contract-code        no-undo .
define variable p-contract-curr       like fin-ob.contract-curr        no-undo .
define variable p-contract-rate       like fin-ob.contract-rate        no-undo .
define variable p-contract-scale      like fin-ob.contract-scale      no-undo .
define variable p-exch-rate           like fin-ob.exch-rate            no-undo .
define variable p-exch-scale          like fin-ob.exch-scale           no-undo .
define variable p-fact-date           like fin-ob.fact-date            no-undo .
define variable p-fact-order          like fin-ob.fact-order           no-undo .
define variable p-host-code           like fin-ob.host-code            no-undo .
define variable p-payer-code          like fin-ob.payer-code         no-undo .
define variable p-payer-type          like fin-ob.payer-type         no-undo .
define variable p-pay-date            like fin-ob.pay-date            no-undo .
define variable p-prn-doc-code        like fin-ob.prn-doc-code         no-undo .
define variable p-sum-base-orig       like fin-ob.sum-base-orig        no-undo .
define variable p-sum-base            like fin-ob.sum-base             no-undo .
define variable p-sum-doc-orig        like fin-ob.sum-doc-orig         no-undo .
define variable p-sum-rubl-orig       like fin-ob.sum-rubl-orig        no-undo .
define variable p-sum-rubl            like fin-ob.sum-rubl             no-undo .
define variable p-sum-contract        like fin-ob.sum-contract         no-undo .
define variable p-trn-doc-code        like fin-ob.trn-doc-code         no-undo .
define variable p-user-db-num-fact    like fin-ob.user-db-num-fact     no-undo .
define variable p-user-db-num-pay     like fin-ob.user-db-num-pay      no-undo .
define variable p-user-name-fact      like fin-ob.user-name-fact       no-undo .
define variable p-user-name-pay       like fin-ob.user-name-pay        no-undo .
define variable p-in-type             like fin-ob.in-type              no-undo .
define variable p-sum-tax-rubl        like fin-ob.sum-tax-rubl         no-undo .
define variable p-sum-tax-base        like fin-ob.sum-tax-base         no-undo .
define variable p-sum-tax-doc         like fin-ob.sum-tax-doc          no-undo .
define variable p-sum-tax-contract    like fin-ob.sum-tax-contract     no-undo .
define variable p-obj-code            like fin-ob.payer-code         no-undo .
define variable p-obj-type            like fin-ob.payer-type         no-undo .


define variable loc_doc-type as character no-undo .
define variable loc_status_  as character no-undo .
define variable loc_in-type as integer no-undo .
define variable glob-vat-pc as decimal no-undo .
define variable glob-slt-pc as decimal no-undo .
define variable p-basecode as integer no-undo .

define variable var-fin-calc as integer no-undo .


define variable g#log as logical no-undo .

define  shared variable br-handle as handle  no-undo .
define  shared variable next-prev as logical no-undo .
DEFINE  SHARED BUFFER buf_fin-liab FOR fin-ob .

&Scoped-define List-mode-nal r-acc-receiver r-acc-payer  ~
b-1 loc_receiver-bank-name ~
loc_receiver-r-schet loc_receiver-c-schet loc_receiver-bik  ~
loc_payer-bank-name b-2 loc_payer-r-schet loc_payer-c-schet ~
loc_payer-bik

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_fin-ob-tax

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 tt_fin-ob-tax.sum-line-doc ~
tt_fin-ob-tax.with-slt tt_fin-ob-tax.slt-pc tt_fin-ob-tax.sum-slt-line-doc ~
tt_fin-ob-tax.with-vat tt_fin-ob-tax.vat-pc tt_fin-ob-tax.sum-vat-line-doc
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH tt_fin-ob-tax NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY BROWSE-1 FOR EACH tt_fin-ob-tax NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt_fin-ob-tax
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt_fin-ob-tax


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-contract B-receiver B-payer ~
B-parts B-hist B-help RECT-1 RECT-2 RECT-4 RECT-5 RADIO-SET-dogovor ~
loc_contract-code r-con loc_pay-date loc_receiver-code r-cli ~
loc_prn-doc-code loc_payer-code loc_corr-doc r-obj r-cur loc_exch-rate ~
loc_exch-scale loc_sum-doc loc_sum-contract BROWSE-1 B-calc-exch B-ins ~
B-chg B-del loc_PS FI-obj FI-obj-type FI-obj-code FI-obj-name loc_doc-date ~
loc_fact-date loc_receiver-type loc_receiver-name f-receiver loc_payer-type ~
loc_payer-name f-payer FILL-IN-4 FILL-IN-5 FILL-IN-6 FILL-IN-7 ~
loc_curr-code loc_abbr-doc loc_abbr-rubl loc_abbr-base f-contract-curr ~
loc_contract-curr loc_abbr-contract
&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-dogovor loc_contract-code ~
loc_pay-date loc_receiver-code loc_prn-doc-code loc_payer-code loc_corr-doc ~
loc_exch-rate loc_exch-scale loc_sum-doc loc_sum-tax-doc loc_sum-rubl ~
loc_sum-tax-rubl loc_base-rate loc_base-scale loc_sum-base loc_sum-tax-base ~
loc_contract-rate loc_contract-scale loc_sum-contract loc_sum-tax-contract ~
loc_PS FI-obj FI-obj-type FI-obj-code FI-obj-name loc_doc-date ~
loc_fact-date p-doc-code loc_receiver-type loc_receiver-name f-receiver ~
loc_payer-type loc_payer-name f-payer FILL-IN-4 FILL-IN-5 FILL-IN-6 ~
FILL-IN-7 loc_curr-code loc_abbr-doc loc_abbr-rubl loc_abbr-base ~
f-contract-curr loc_contract-curr loc_abbr-contract

/* Custom List Definitions                                              */
/* str-contract,list-input,List-full-mode,List-read-only,str-rubl,str-base */
&Scoped-define str-contract loc_contract-rate loc_contract-scale ~
loc_sum-contract loc_sum-tax-contract f-contract-curr loc_contract-curr ~
loc_abbr-contract
&Scoped-define list-input loc_contract-code loc_pay-date loc_receiver-code ~
loc_prn-doc-code loc_payer-code loc_corr-doc loc_exch-rate loc_exch-scale ~
loc_sum-doc loc_base-rate loc_base-scale loc_contract-rate ~
loc_contract-scale loc_PS FI-obj-type FI-obj-code loc_receiver-type ~
loc_payer-type loc_curr-code loc_contract-curr
&Scoped-define List-read-only loc_sum-tax-doc loc_sum-tax-rubl ~
loc_sum-tax-base loc_sum-tax-contract
&Scoped-define str-rubl loc_sum-rubl loc_sum-tax-rubl loc_abbr-rubl
&Scoped-define str-base loc_base-rate loc_base-scale loc_sum-base ~
loc_sum-tax-base loc_abbr-base

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
  ( p-curr-code as int )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-calc-exch DEFAULT
     LABEL "Расчет су&мм и курсов"
     SIZE 26 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить налог".

DEFINE BUTTON B-contract
     LABEL "До&говор"
     SIZE 10 BY 1 TOOLTIP "Просмотр атрибутов договора".

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить налог".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist DEFAULT
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-ins
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить налог".

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1.

DEFINE BUTTON B-parts
     LABEL "П&артии"
     SIZE 10 BY 1 TOOLTIP "Просмотр партий".

DEFINE BUTTON B-payer
     LABEL "П&лательщик"
     SIZE 13.25 BY 1 TOOLTIP "Просмотр атрибутов Плательщика".

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON B-receiver
     LABEL "П&олучатель"
     SIZE 13.25 BY 1 TOOLTIP "Просмотр атрибутов Получателя".

DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-con
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-con"
     SIZE 3 BY 1 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-cur
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-obj"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-obj-firm
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Выбор из списка объектов".

DEFINE VARIABLE loc_PS AS CHARACTER
     VIEW-AS EDITOR MAX-CHARS 6000 SCROLLBAR-VERTICAL
     SIZE 96 BY 2.5 TOOLTIP "Основание для фин.обязательства или примечание"
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-contract-curr AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:"
      VIEW-AS TEXT
     SIZE 9.5 BY .67 TOOLTIP "Валюта договора" NO-UNDO.

DEFINE VARIABLE f-payer AS CHARACTER FORMAT "X(256)":U INITIAL "Плательщик:"
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-receiver AS CHARACTER FORMAT "X(256)":U INITIAL "Получатель:"
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FI-obj AS CHARACTER FORMAT "X(256)":U INITIAL "Объект:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67 NO-UNDO.

DEFINE VARIABLE FI-obj-code AS INTEGER FORMAT ">>>>>":U INITIAL 0
      VIEW-AS TEXT
     SIZE 5.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI-obj-name AS CHARACTER FORMAT "X(40)":U
      VIEW-AS TEXT
     SIZE 31 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI-obj-type AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 3.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":C20 INITIAL "ВАЛЮТА"
      VIEW-AS TEXT
     SIZE 19.13 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":C17 INITIAL "КУРС"
      VIEW-AS TEXT
     SIZE 17.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":C23 INITIAL "СУММА"
      VIEW-AS TEXT
     SIZE 22 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":C22 INITIAL "НАЛОГ"
      VIEW-AS TEXT
     SIZE 22 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE loc_abbr-base AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 19.13 BY 1 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_abbr-contract AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4.13 BY .67 TOOLTIP "Валюта договора"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_abbr-doc AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4.13 BY .67 TOOLTIP "Валюта платежа"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_abbr-rubl AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 19.13 BY 1 TOOLTIP "Национальная валюта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_base-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.

DEFINE VARIABLE loc_base-scale AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.

DEFINE VARIABLE loc_contract-code AS CHARACTER FORMAT "X(20)"
     LABEL "№ договора"
     VIEW-AS FILL-IN
     SIZE 18.75 BY 1.

DEFINE VARIABLE loc_contract-curr AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Валюта договора".

DEFINE VARIABLE loc_contract-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.

DEFINE VARIABLE loc_contract-scale AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.

DEFINE VARIABLE loc_corr-doc LIKE fin-ob.corr-doc
     LABEL "Корр.ФО"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 TOOLTIP "Ссылка на внутренний № корректируемого ФО" NO-UNDO.

DEFINE VARIABLE loc_curr-code AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     LABEL "Платеж"
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Валюта платежа".

DEFINE VARIABLE loc_doc-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата док-та"
      VIEW-AS TEXT
     SIZE 11 BY .67.

DEFINE VARIABLE loc_exch-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.

DEFINE VARIABLE loc_exch-scale AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.

DEFINE VARIABLE loc_fact-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата факт"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE loc_pay-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата платежа"
     VIEW-AS FILL-IN
     SIZE 11.13 BY 1 TOOLTIP "Дата платежа".

DEFINE VARIABLE loc_payer-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1.

DEFINE VARIABLE loc_payer-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 39 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE loc_payer-type AS CHARACTER FORMAT "X(3)" INITIAL "~{&cmp}"
      VIEW-AS TEXT
     SIZE 2.88 BY 1.

DEFINE VARIABLE loc_prn-doc-code AS CHARACTER FORMAT "X(16)"
     LABEL "Номер"
     VIEW-AS FILL-IN
     SIZE 16 BY 1.

DEFINE VARIABLE loc_receiver-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1.

DEFINE VARIABLE loc_receiver-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 40 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE loc_receiver-type AS CHARACTER FORMAT "X(3)" INITIAL "~{&cmp}"
      VIEW-AS TEXT
     SIZE 2.88 BY 1.

DEFINE VARIABLE loc_sum-base LIKE fin-ob.sum-base
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 TOOLTIP "<<F5>> - пересчет курса баз.вал." NO-UNDO.

DEFINE VARIABLE loc_sum-contract LIKE fin-ob.sum-contract
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 TOOLTIP "<<F5>> - пересчет курса валюты договора" NO-UNDO.

DEFINE VARIABLE loc_sum-doc LIKE fin-ob.sum-doc
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 TOOLTIP "<<F5>> - пересчет курса платежа" NO-UNDO.

DEFINE VARIABLE loc_sum-rubl LIKE fin-ob.sum-rubl
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY .83 NO-UNDO.

DEFINE VARIABLE loc_sum-tax-base LIKE fin-ob.sum-tax-base
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.

DEFINE VARIABLE loc_sum-tax-contract LIKE fin-ob.sum-tax-contract
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.

DEFINE VARIABLE loc_sum-tax-doc LIKE fin-ob.sum-tax-doc
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.

DEFINE VARIABLE loc_sum-tax-rubl LIKE fin-ob.sum-tax-rubl
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY .83 NO-UNDO.

DEFINE VARIABLE p-doc-code AS CHARACTER FORMAT "x(16)"
     LABEL "Внут.№"
      VIEW-AS TEXT
     SIZE 15.75 BY .67 TOOLTIP "Внутренний код документа"
     FGCOLOR 7 .

DEFINE VARIABLE RADIO-SET-dogovor AS LOGICAL INITIAL yes
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "по договору", yes,
"без договора", no
     SIZE 28.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 20.5 BY 5.13.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 24 BY 5.13.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 19.25 BY 5.13.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 24 BY 5.13.

DEFINE VARIABLE T-base AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY .83 TOOLTIP "Ввод суммы в базовой валюте" NO-UNDO.

DEFINE VARIABLE T-contract AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY .83 TOOLTIP "Ввод суммы в валюте договора" NO-UNDO.

DEFINE VARIABLE T-doc AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY .83 TOOLTIP "Ввод суммы в валюте документа" NO-UNDO.

DEFINE VARIABLE T-rubl AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY .83 TOOLTIP "Ввод суммы в нац. валюте" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      tt_fin-ob-tax SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _STRUCTURED
  QUERY BROWSE-1 NO-LOCK DISPLAY
      tt_fin-ob-tax.sum-line-doc COLUMN-LABEL "Сумма c налогом!в вал.док-та" FORMAT "->>>>>>>>>>9.99":U
      tt_fin-ob-tax.with-slt COLUMN-LABEL "НП" FORMAT "  /без":U
      tt_fin-ob-tax.slt-pc COLUMN-LABEL "Ставка!НП" FORMAT ">9.9<%":U
      tt_fin-ob-tax.sum-slt-line-doc COLUMN-LABEL "Сумма НП!в вал.док-та" FORMAT "->>>>>>>>>9.99":U
      tt_fin-ob-tax.with-vat COLUMN-LABEL "НДС" FORMAT " /без":U
      tt_fin-ob-tax.vat-pc COLUMN-LABEL "Ставка!НДС" FORMAT ">9.9<%":U
      tt_fin-ob-tax.sum-vat-line-doc COLUMN-LABEL "Сумма НДС!в вал.док-та" FORMAT "->>>>>>>>>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 68 BY 4.5
         BGCOLOR 15  ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-contract AT ROW 1 COL 31.5
     B-receiver AT ROW 1 COL 41.5
     B-payer AT ROW 1 COL 54.75
     B-parts AT ROW 1 COL 68
     B-hist AT ROW 1 COL 78
     B-help AT ROW 1 COL 88
     b-prev AT ROW 2 COL 1
     b-next AT ROW 2 COL 6
     r-obj-firm AT ROW 2 COL 64
     RADIO-SET-dogovor AT ROW 2.25 COL 15.5 NO-LABEL
     loc_contract-code AT ROW 3 COL 13 COLON-ALIGNED
     r-con AT ROW 3 COL 34
     loc_pay-date AT ROW 4 COL 13 COLON-ALIGNED
     loc_receiver-code AT ROW 5 COL 13 COLON-ALIGNED NO-LABEL
     r-cli AT ROW 5 COL 27.63
     loc_prn-doc-code AT ROW 5 COL 79.5 COLON-ALIGNED
     loc_payer-code AT ROW 6 COL 13 COLON-ALIGNED NO-LABEL
     loc_corr-doc AT ROW 6 COL 79.5 COLON-ALIGNED HELP
          ""
          LABEL "Корр.ФО" FORMAT ">>>>>>>"
     r-obj AT ROW 6.04 COL 27.63
     r-cur AT ROW 8.25 COL 12.88
     loc_exch-rate AT ROW 8.25 COL 20 COLON-ALIGNED NO-LABEL
     loc_exch-scale AT ROW 8.25 COL 32.38 COLON-ALIGNED NO-LABEL
     loc_sum-doc AT ROW 8.25 COL 39.13 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "->>>,>>>,>>>,>>9.99"
     loc_sum-tax-doc AT ROW 8.25 COL 62.88 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     T-doc AT ROW 8.25 COL 92.88
     loc_sum-rubl AT ROW 9.21 COL 39.13 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     loc_sum-tax-rubl AT ROW 9.21 COL 62.88 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     T-rubl AT ROW 9.21 COL 92.88
     loc_base-rate AT ROW 10.08 COL 20 COLON-ALIGNED NO-LABEL
     loc_base-scale AT ROW 10.08 COL 32.5 COLON-ALIGNED NO-LABEL
     loc_sum-base AT ROW 10.08 COL 39.13 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     loc_sum-tax-base AT ROW 10.08 COL 62.88 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     T-base AT ROW 10.08 COL 92.88
     loc_contract-rate AT ROW 11.13 COL 20 COLON-ALIGNED NO-LABEL
     loc_contract-scale AT ROW 11.13 COL 32.5 COLON-ALIGNED NO-LABEL
     loc_sum-contract AT ROW 11.13 COL 39.13 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     loc_sum-tax-contract AT ROW 11.13 COL 62.88 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     T-contract AT ROW 11.13 COL 92.88
     BROWSE-1 AT ROW 12.5 COL 1.5
     B-calc-exch AT ROW 12.5 COL 70
     B-ins AT ROW 17.25 COL 1.5
     B-chg AT ROW 17.25 COL 11.5
     B-del AT ROW 17.25 COL 21.5
     loc_PS AT ROW 18.5 COL 1 NO-LABEL
     FI-obj AT ROW 2.25 COL 44.5 COLON-ALIGNED NO-LABEL
     FI-obj-type AT ROW 2.25 COL 52.5 COLON-ALIGNED NO-LABEL
     FI-obj-code AT ROW 2.25 COL 56.5 COLON-ALIGNED NO-LABEL
     FI-obj-name AT ROW 2.25 COL 65 COLON-ALIGNED NO-LABEL
     loc_doc-date AT ROW 2.75 COL 79.5 COLON-ALIGNED
     loc_fact-date AT ROW 3.42 COL 79.5 COLON-ALIGNED
     p-doc-code AT ROW 4.17 COL 79.5 COLON-ALIGNED
     loc_receiver-type AT ROW 5 COL 22.5 COLON-ALIGNED NO-LABEL
     loc_receiver-name AT ROW 5 COL 28.5 COLON-ALIGNED NO-LABEL
     f-receiver AT ROW 5.25 COL 1 NO-LABEL
     loc_payer-type AT ROW 5.96 COL 22.5 COLON-ALIGNED NO-LABEL
     loc_payer-name AT ROW 6.04 COL 28.5 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     f-payer AT ROW 6.25 COL 1 NO-LABEL
     FILL-IN-4 AT ROW 7.5 COL 1.75 NO-LABEL
     FILL-IN-5 AT ROW 7.5 COL 22 NO-LABEL
     FILL-IN-6 AT ROW 7.5 COL 41.13 NO-LABEL
     FILL-IN-7 AT ROW 7.5 COL 64.88 NO-LABEL
     loc_curr-code AT ROW 8.25 COL 7.88 COLON-ALIGNED
     loc_abbr-doc AT ROW 8.25 COL 14.38 COLON-ALIGNED NO-LABEL
     loc_abbr-rubl AT ROW 9.08 COL 1.75 NO-LABEL
     loc_abbr-base AT ROW 10.08 COL 1.75 NO-LABEL
     f-contract-curr AT ROW 11.13 COL 1.75 NO-LABEL
     loc_contract-curr AT ROW 11.13 COL 10.88 COLON-ALIGNED NO-LABEL
     loc_abbr-contract AT ROW 11.13 COL 14.88 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 7.25 COL 1
     RECT-2 AT ROW 7.25 COL 40.5
     RECT-4 AT ROW 7.25 COL 21.38
     RECT-5 AT ROW 7.25 COL 64.13
     SPACE(9.88) SKIP(8.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Финансовые обязательства"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt_fin-ob-tax T "?" NO-UNDO ub fin-ob-tax
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1 T-contract Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-next IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-prev IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-prev:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-contract-curr IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN f-payer IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-receiver IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FI-obj-code IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN FI-obj-type IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-4 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-5 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-6 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-7 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc_abbr-base IN FRAME Dialog-Frame
   ALIGN-L 6                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-contract IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN loc_abbr-rubl IN FRAME Dialog-Frame
   ALIGN-L 5                                                            */
/* SETTINGS FOR FILL-IN loc_base-rate IN FRAME Dialog-Frame
   NO-ENABLE 2 6                                                        */
/* SETTINGS FOR FILL-IN loc_base-scale IN FRAME Dialog-Frame
   NO-ENABLE 2 6                                                        */
/* SETTINGS FOR FILL-IN loc_contract-code IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_contract-curr IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN loc_contract-rate IN FRAME Dialog-Frame
   NO-ENABLE 1 2                                                        */
/* SETTINGS FOR FILL-IN loc_contract-scale IN FRAME Dialog-Frame
   NO-ENABLE 1 2                                                        */
/* SETTINGS FOR FILL-IN loc_corr-doc IN FRAME Dialog-Frame
   2 LIKE = ub.fin-ob.corr-doc EXP-LABEL EXP-FORMAT                     */
/* SETTINGS FOR FILL-IN loc_curr-code IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_exch-rate IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_exch-scale IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_pay-date IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_payer-code IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_payer-type IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_prn-doc-code IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR EDITOR loc_PS IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_receiver-code IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_receiver-type IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc_sum-base IN FRAME Dialog-Frame
   NO-ENABLE 6 LIKE = ub.fin-ob.sum-base EXP-FORMAT EXP-SIZE            */
/* SETTINGS FOR FILL-IN loc_sum-contract IN FRAME Dialog-Frame
   1 LIKE = ub.fin-ob.sum-contract EXP-FORMAT EXP-SIZE                  */
/* SETTINGS FOR FILL-IN loc_sum-doc IN FRAME Dialog-Frame
   2 LIKE = ub.fin-ob.sum-doc EXP-FORMAT EXP-SIZE                       */
/* SETTINGS FOR FILL-IN loc_sum-rubl IN FRAME Dialog-Frame
   NO-ENABLE 5 LIKE = ub.fin-ob.sum-rubl EXP-FORMAT                     */
/* SETTINGS FOR FILL-IN loc_sum-tax-base IN FRAME Dialog-Frame
   NO-ENABLE 4 6 LIKE = ub.fin-ob.sum-tax-base EXP-FORMAT EXP-SIZE      */
/* SETTINGS FOR FILL-IN loc_sum-tax-contract IN FRAME Dialog-Frame
   NO-ENABLE 1 4 LIKE = ub.fin-ob.sum-tax-contract EXP-FORMAT           */
/* SETTINGS FOR FILL-IN loc_sum-tax-doc IN FRAME Dialog-Frame
   NO-ENABLE 4 LIKE = ub.fin-ob.sum-tax-doc EXP-FORMAT                  */
/* SETTINGS FOR FILL-IN loc_sum-tax-rubl IN FRAME Dialog-Frame
   NO-ENABLE 4 5 LIKE = ub.fin-ob.sum-tax-rubl EXP-FORMAT EXP-SIZE      */
/* SETTINGS FOR FILL-IN p-doc-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-obj-firm IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-base IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-contract IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-contract:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-doc IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-doc:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-rubl IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _TblList          = "Temp-Tables.tt_fin-ob-tax"
     _Options          = "NO-LOCK"
     _FldNameList[1]   > Temp-Tables.tt_fin-ob-tax.sum-line-doc
"tt_fin-ob-tax.sum-line-doc" "Сумма c налогом!в вал.док-та" "->>>>>>>>>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt_fin-ob-tax.with-slt
"tt_fin-ob-tax.with-slt" "НП" "  /без" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt_fin-ob-tax.slt-pc
"tt_fin-ob-tax.slt-pc" "Ставка!НП" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt_fin-ob-tax.sum-slt-line-doc
"tt_fin-ob-tax.sum-slt-line-doc" "Сумма НП!в вал.док-та" "->>>>>>>>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.tt_fin-ob-tax.with-vat
"tt_fin-ob-tax.with-vat" "НДС" " /без" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.tt_fin-ob-tax.vat-pc
"tt_fin-ob-tax.vat-pc" "Ставка!НДС" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.tt_fin-ob-tax.sum-vat-line-doc
"tt_fin-ob-tax.sum-vat-line-doc" "Сумма НДС!в вал.док-та" "->>>>>>>>>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Финансовые обязательства */
DO:
  /* message "trigger go frame" . */
  if input loc_prn-doc-code = ""
        or loc_prn-doc-code = ?
  then do:
      message "Номер документа  не может быть не задан" view-as alert-box.
      apply "ENTRY":U to loc_prn-doc-code.
      return no-apply.
  end.

  if ref-mode =  {&add-def} then do:
  end.
  /* Запишем с экрана */
  if ref-mode <> {&lookup} then do:
      assign
      {&list-input}
      .
/*    message loc_sum-doc              p-sum-doc . */

  end.
 run save-p no-error .
 if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Финансовые обязательства */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-calc-exch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-calc-exch Dialog-Frame
ON CHOOSE OF B-calc-exch IN FRAME Dialog-Frame /* Расчет сумм и курсов */
DO:
define variable p-hide-rubl  as logical init false   no-undo .
define variable p-hide-base  as logical init false no-undo .
define variable p-hide-contr as logical init false no-undo .
define variable p-res as logical no-undo .

 if p-basecode = 0         then   p-hide-base  = true .
 if loc_contract-curr = 0  then   p-hide-contr  = true .
 /*
message
"на входе"   skip
return-value skip
 loc_curr-code  skip
 "sum-rubl     "     loc_sum-rubl       skip
 "sum-base     "     loc_sum-base       skip
 "sum-contract "     loc_sum-contract   skip
                   skip
 "base-rate    "     loc_base-rate      skip
 "base-scale   "     loc_base-scale     skip
                   skip
 "contract-rate "    loc_contract-rate  skip
 "contract-scale"    loc_contract-scale skip
 .
 */
 run str/fo-curr.w (
 input  parParentProc ,
 input  par-host-code ,
 input-output  loc_sum-rubl  ,
 input-output  loc_sum-base  ,
 input-output  loc_sum-contract ,
 input         p-basecode ,
 input-output  loc_base-rate  ,
 input-output  loc_base-scale ,
 input         loc_contract-curr ,
 input-output  loc_contract-rate  ,
 input-output  loc_contract-scale ,
 input loc_curr-code ,
 input p-hide-rubl  ,
 input p-hide-base  ,
 input p-hide-contr ,
 output p-res
      ).
      /*
message
"на выходе"   skip
return-value skip
 loc_curr-code  skip
 "sum-rubl     "     loc_sum-rubl       skip
 "sum-base     "     loc_sum-base       skip
 "sum-contract "     loc_sum-contract   skip
                   skip
 "base-rate    "     loc_base-rate      skip
 "base-scale   "     loc_base-scale     skip
                   skip
 "contract-rate "    loc_contract-rate  skip
 "contract-scale"    loc_contract-scale skip
 .

*/


if p-res = false then return.


define variable t-v as logical no-undo .
      case loc_curr-code:
        when 0 then do :
         assign
          loc_sum-doc = loc_sum-rubl
          loc_exch-rate = 1
          loc_exch-scale = 1
         .
        end.
        when p-basecode then do :
         assign
          loc_sum-doc    = loc_sum-base
          loc_exch-rate  = loc_base-rate
          loc_exch-scale = loc_base-scale
         .
        end.
        when loc_contract-curr then do :
         assign
          loc_sum-doc    = loc_sum-contract
          loc_exch-rate  = loc_contract-rate
          loc_exch-scale = loc_contract-scale
         .
        end.


      end case.

/* Договор равен БАЗ валюте не Р_УБ */

if loc_curr-code <> 0 and
    p-basecode = loc_contract-curr and
    loc_curr-code = loc_contract-curr
    and ( loc_base-rate <> loc_contract-rate or
          loc_sum-base  <> loc_sum-contract)
    then do:
    t-v = true .
    message
      "Базовая и валюта договора одна , но курс или сумма разные" skip
      "Платеж будет по валюте договора ?"
      view-as alert-box question
      Buttons yes-no
      update t-v    .
        if t-v = true then do:
         assign
          loc_sum-doc    = loc_sum-contract
          loc_exch-rate  = loc_contract-rate
          loc_exch-scale = loc_contract-scale
         .

        end.
        else do:
         assign
          loc_sum-doc    = loc_sum-base
          loc_exch-rate  = loc_base-rate
          loc_exch-scale = loc_base-scale
         .
        end.
    end.



  run create-tax (
     input loc_sum-doc ,
     input loc_sum-rubl  ,
     input loc_sum-base   ,
     input loc_sum-contract ,
     input "doc":U ,
     output loc_sum-tax-doc) .

loc_sum-tax-rubl       = (  loc_exch-rate       / loc_exch-scale)    * loc_sum-tax-doc .
loc_sum-tax-base       = (  loc_base-scale      / loc_base-rate)     * loc_sum-tax-rubl .
loc_sum-tax-contract   = (  loc_contract-scale  / loc_contract-rate) * loc_sum-tax-rubl .

display
 loc_sum-doc
 loc_sum-tax-doc
 loc_exch-rate
 loc_exch-scale
 loc_sum-rubl          when loc_sum-rubl     :visible
 loc_sum-tax-rubl      when loc_sum-rubl     :visible

 with frame {&frame-name}
 .

 if loc_sum-contract <> loc_sum-doc or loc_contract-rate   <> loc_exch-rate then
    display {&str-contract}  with frame {&frame-name} .

 if loc_contract-curr <> 0 then do:
 if loc_sum-base <> loc_sum-doc or loc_base-rate   <> loc_exch-rate then
    display {&str-base}  with frame {&frame-name} .
 end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable p-recid            as  recid   no-undo .
  define variable p-res              as  logical no-undo .
  define variable v-slt-pc           like fin-ob-tax.slt-pc           no-undo.
  define variable v-loc_sum-doc      like fin-ob-tax.sum-line-doc     no-undo.
  define variable v-sum-vat-line-doc like fin-ob-tax.sum-vat-line-doc no-undo.
  define variable v-sum-slt-line-doc like fin-ob-tax.sum-slt-line-doc no-undo.
  define variable v-vat-pc           like fin-ob-tax.vat-pc           no-undo.
  define variable v-with-slt         like fin-ob-tax.with-slt         no-undo.
  define variable v-with-vat         like fin-ob-tax.with-vat         no-undo.

  find current tt_fin-ob-tax no-error .
  if not available tt_fin-ob-tax then find first tt_fin-ob-tax no-error .
    if not available tt_fin-ob-tax then return no-apply.
    assign
      p-recid            = recid(tt_fin-ob-tax)
      v-slt-pc           = tt_fin-ob-tax.slt-pc
      v-loc_sum-doc      = tt_fin-ob-tax.sum-line-doc
      v-sum-vat-line-doc = tt_fin-ob-tax.sum-vat-line-doc
      v-sum-slt-line-doc = tt_fin-ob-tax.sum-slt-line-doc
      v-vat-pc           = tt_fin-ob-tax.vat-pc
      v-with-slt         = tt_fin-ob-tax.with-slt
      v-with-vat         = tt_fin-ob-tax.with-vat
    .

run str/fi-txli.w (
 INPUT  parParentProc ,
 input  par-host-code   ,
 input  {&update}             ,
 input  par-host-code         ,
 input  p-doc-code            ,
 input  p-doc-type            ,
 input  loc_sum-doc           ,
 input  loc_curr-code ,
 input  loc_base-rate ,
 input  loc_base-scale,
 input  loc_exch-rate ,
 input  loc_exch-scale,
 input-output v-slt-pc          ,
 input-output v-loc_sum-doc     ,
 input-output v-sum-vat-line-doc,
 input-output v-sum-slt-line-doc,
 input-output v-vat-pc          ,
 input-output v-with-slt        ,
 input-output v-with-vat        ,
 INPUT TABLE tt_fin-ob-tax      ,
 input recid(tt_fin-ob-tax)     ,
 input ?      ,
 output p-res
  ) no-error .

if p-res = true then do:
    assign
      tt_fin-ob-tax.slt-pc           = v-slt-pc
      tt_fin-ob-tax.sum-line-doc     = v-loc_sum-doc
      tt_fin-ob-tax.sum-vat-line-doc = v-sum-vat-line-doc
      tt_fin-ob-tax.sum-slt-line-doc = v-sum-slt-line-doc
      tt_fin-ob-tax.vat-pc           = v-vat-pc
      tt_fin-ob-tax.with-slt         = v-with-slt
      tt_fin-ob-tax.with-vat         = v-with-vat
    .
    {&OPEN-QUERY-BROWSE-1}
    reposition BROWSE-1 TO RECID p-recid NO-ERROR .
    run calc-tax .
end.

/* перевести фокус на ВЫХОД ? */

END.


ON return OF B-chg IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-contract Dialog-Frame
ON CHOOSE OF B-contract IN FRAME Dialog-Frame /* Договор */
DO:
assign
   loc_contract-code
.

define variable ri as recid no-undo .
define buffer b_contract for contract.
find first b_contract no-lock  where b_contract.contract-code     = loc_contract-code-id and
                                     b_contract.host-code         = par-host-code
                                     no-error .
if error-status :error then return no-apply.

ri = recid (b_contract) .
run str/sh-contr.p
    ( input parParentProc ,
      input ri
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
/* Право на удаление */

find current tt_fin-ob-tax   no-error .
if not available tt_fin-ob-tax  then return .

define variable g-log as log no-undo.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_deletion':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}

if not g-log then  return .
  else do:
      message "Удалить запись ?"
      view-as alert-box question
      buttons yes-no
      update g-log.
      if g-log = false then return no-apply.
  end.

  define variable v-code as integer no-undo .
  delete tt_fin-ob-tax .

  run calc-tax .

  {&OPEN-QUERY-BROWSE-1}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:

    next-prev = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
    define variable  rid-list AS CHAR NO-UNDO.
       run str/fincliab.w
         (input  parparentproc          ,
          input  ""                      ,
          input  {&company}                  ,
          input  par-host-code           ,
          input  p-doc-code   ,
          output rid-list       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ins Dialog-Frame
ON CHOOSE OF B-ins IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable p-recid            as  recid   no-undo .
  define variable p-res              as  logical no-undo .
  define variable v-slt-pc           like fin-ob-tax.slt-pc           no-undo.
  define variable v-loc_sum-doc      like fin-ob-tax.sum-line-doc      no-undo.
  define variable v-sum-vat-line-doc like fin-ob-tax.sum-vat-line-doc no-undo.
  define variable v-sum-slt-line-doc like fin-ob-tax.sum-slt-line-doc no-undo.
  define variable v-vat-pc           like fin-ob-tax.vat-pc           no-undo.
  define variable v-with-slt         like fin-ob-tax.with-slt         no-undo.
  define variable v-with-vat         like fin-ob-tax.with-vat         no-undo.


run str/fi-txli.w (
 INPUT  parParentProc ,
 input  par-host-code ,
 input  {&add-def}    ,
 input  par-host-code ,
 input  p-doc-code    ,
 input  p-doc-type    ,
 input  loc_sum-doc   ,
 input  loc_curr-code ,
 input  loc_base-rate ,
 input  loc_base-scale,
 input  loc_exch-rate ,
 input  loc_exch-scale,
 input-output v-slt-pc          ,
 input-output v-loc_sum-doc     ,
 input-output v-sum-vat-line-doc,
 input-output v-sum-slt-line-doc,
 input-output v-vat-pc          ,
 input-output v-with-slt        ,
 input-output v-with-vat        ,
 INPUT TABLE tt_fin-ob-tax ,
 input ?      ,
 input ?      ,
 output p-res
  ).


define variable l-num as integer no-undo .

l-num = 0.
if p-res = true then do:
  find last tt_fin-ob-tax use-index pi no-error .
     if not available tt_fin-ob-tax
            then l-num = 0.
            else l-num = tt_fin-ob-tax.line-num.

    l-num = l-num + 1.
    create tt_fin-ob-tax.
    assign
      tt_fin-ob-tax.doc-code         = p-doc-code
      tt_fin-ob-tax.host-code        = par-host-code
      tt_fin-ob-tax.line-num         = l-num
      tt_fin-ob-tax.slt-pc           = v-slt-pc
      tt_fin-ob-tax.sum-line-doc     = v-loc_sum-doc
      tt_fin-ob-tax.sum-vat-line-doc = v-sum-vat-line-doc
      tt_fin-ob-tax.sum-slt-line-doc = v-sum-slt-line-doc
      tt_fin-ob-tax.vat-pc           = v-vat-pc
      tt_fin-ob-tax.with-slt         = v-with-slt
      tt_fin-ob-tax.with-vat         = v-with-vat
    .
end.
run calc-tax .

{&OPEN-QUERY-BROWSE-1}
reposition BROWSE-1 TO RECID p-recid NO-ERROR .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
run step-next.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партии */
DO:

    run str/fi-parts.w
      ( input parParentProc ,
        input p-doc-code ,
        input par-host-code  )
        .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-payer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-payer Dialog-Frame
ON CHOOSE OF B-payer IN FRAME Dialog-Frame /* Плательщик */
DO:
assign loc_payer-code loc_payer-type .
run lookup-cli (loc_payer-code , loc_payer-type) no-error .
    if error-status :error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
   run step-prev.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
    next-prev = ?.
    message "Выходим без сохранения изменений ?" view-as alert-box question
            buttons yes-no
            update ll as log
            .
    if ll = no then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-receiver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-receiver Dialog-Frame
ON CHOOSE OF B-receiver IN FRAME Dialog-Frame /* Получатель */
DO:
   assign loc_receiver-code loc_receiver-type .
   run lookup-cli (loc_receiver-code , loc_receiver-type) no-error .
       if error-status :error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-rate Dialog-Frame
ON LEAVE OF loc_base-rate IN FRAME Dialog-Frame
OR "LEAVE" Of loc_base-scale
OR "LEAVE" Of loc_exch-rate
OR "LEAVE" Of loc_exch-scale
OR "LEAVE" Of loc_contract-rate
OR "LEAVE" Of loc_contract-scale

DO:
  assign loc_base-rate loc_base-scale loc_exch-rate loc_exch-scale
  loc_contract-rate
  loc_contract-scale
  .
   if T-doc  then apply "leave" to loc_sum-doc  in frame {&frame-name} .
   if T-rubl then apply "leave" to loc_sum-rubl in frame {&frame-name} .
   if T-base then apply "leave" to loc_sum-base in frame {&frame-name} .
   if T-contract then apply "leave" to loc_sum-contract in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-rate Dialog-Frame
ON return OF loc_base-rate IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_base-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-scale Dialog-Frame
ON return OF loc_base-scale IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_contract-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-code Dialog-Frame
ON LEAVE OF loc_contract-code IN FRAME Dialog-Frame /* № договора */
DO:

 define buffer buf_contract for contract.
 define buffer buf_contract1 for contract.
 assign
    loc_contract-code
 .
  find  buf_contract1 where buf_contract1.contract-prn-code = loc_contract-code
                            and buf_contract1.host-code         = par-host-code
                            no-lock no-error .


  find first buf_contract where buf_contract.contract-prn-code = loc_contract-code
                            and buf_contract.host-code         = par-host-code
                        no-lock no-error .
  if not available buf_contract1  and available buf_contract then  do:
    message "С номером "  loc_contract-code " найдено несколько договоров !!! "
             view-as alert-box information .
    apply "CHOOSE":U  to r-con in frame {&frame-name} .
    return.
  end.
  if not available buf_contract then do:
     loc_contract-code = "".
     loc_contract-code-id = 0.
     DISPLAY loc_contract-code WITH FRAME {&FRAME-NAME} .
     message "Не верно введен Номер договора!!! "
              view-as alert-box information .
     apply "CHOOSE":U  to r-con in frame {&frame-name}.
     return .
  end.
  /* а если есть то */
  ELSE DO:
   loc_contract-code    = buf_contract.contract-prn-code.
   loc_contract-code-id = buf_contract.contract-code.

   run from-contract (
            input buf_contract.contract-code ,
            input buf_contract.host-code,
            input {&singl-mode}
            )
            no-error .
            if error-status :error then return no-apply.

      END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-code Dialog-Frame
ON return OF loc_contract-code IN FRAME Dialog-Frame /* № договора */
DO:


  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_contract-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-curr Dialog-Frame
ON return OF loc_contract-curr IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_contract-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-rate Dialog-Frame
ON return OF loc_contract-rate IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_contract-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-scale Dialog-Frame
ON return OF loc_contract-scale IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_curr-code Dialog-Frame
ON return OF loc_curr-code IN FRAME Dialog-Frame /* Платеж */
DO:
      run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_exch-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_exch-rate Dialog-Frame
ON return OF loc_exch-rate IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_exch-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_exch-scale Dialog-Frame
ON return OF loc_exch-scale IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_pay-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_pay-date Dialog-Frame
ON return OF loc_pay-date IN FRAME Dialog-Frame /* Дата платежа */
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_payer-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_payer-code Dialog-Frame
ON LEAVE OF loc_payer-code IN FRAME Dialog-Frame
DO:
assign loc_payer-code loc_payer-type.
def buffer b#clients for clients.

 find first b#clients WHERE
    b#clients.obj-code = loc_payer-code  and
    b#clients.obj-type = loc_payer-type
    no-lock no-error.

    if avail b#clients then dO:
        Assign
          loc_payer-code = b#clients.obj-code
          loc_payer-type = b#clients.obj-type
          loc_payer-name = b#clients.obj-name
          .

        Display
         loc_payer-code loc_payer-name loc_payer-type
        with frame {&frame-name} .

        Enable
         loc_payer-code  loc_payer-type
        with frame {&frame-name} .

        run ver-data no-error .
        if error-status :error then apply "CHOOSE" to r-obj IN FRAME Dialog-Frame        .
    end.
    else
      apply "CHOOSE" to r-obj IN FRAME Dialog-Frame        .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_payer-code Dialog-Frame
ON RETURN OF loc_payer-code IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_prn-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_prn-doc-code Dialog-Frame
ON return OF loc_prn-doc-code IN FRAME Dialog-Frame /* Номер */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_receiver-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_receiver-code Dialog-Frame
ON LEAVE OF loc_receiver-code IN FRAME Dialog-Frame
DO:

assign loc_receiver-code loc_receiver-type.
def buffer b#clients for clients.
 find first b#clients WHERE
    b#clients.obj-code = loc_receiver-code   and
    b#clients.obj-type = loc_receiver-type
     no-lock no-error.
 if avail b#clients then do:
    Assign
        loc_receiver-code = b#clients.obj-code
        loc_receiver-type = b#clients.obj-type
        loc_receiver-name = b#clients.obj-name
        .

    Display
      loc_receiver-code loc_receiver-name loc_receiver-type
    with frame {&frame-name} .
    Enable
       loc_receiver-code
    with frame {&frame-name} .

    run ver-data no-error .
    if error-status :error then do:
       apply "CHOOSE" to r-cli IN FRAME Dialog-Frame        .
       end.
end.
else   do:
  apply "CHOOSE" to r-cli IN FRAME Dialog-Frame        .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_receiver-code Dialog-Frame
ON return OF loc_receiver-code IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-base Dialog-Frame
ON F5 OF loc_sum-base IN FRAME Dialog-Frame
DO:
  loc_base-rate = loc_sum-rubl / (loc_base-scale * DECIMAL ( loc_sum-base:SCREEN-VALUE )) .
  DISPLAY loc_base-rate  WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-base Dialog-Frame
ON LEAVE OF loc_sum-base IN FRAME Dialog-Frame
DO:
define variable v-mod as logical no-undo .
 v-mod = loc_sum-base:MODIFIED.

assign loc_sum-base loc_sum-tax-base
 loc_base-rate loc_base-scale
 loc_exch-rate loc_exch-scale
 loc_contract-rate loc_contract-scale

 .
  loc_sum-rubl    = ( loc_base-rate  / loc_base-scale) * loc_sum-base .
  loc_sum-doc   = (  loc_exch-scale   / loc_exch-rate) * loc_sum-rubl .
  loc_sum-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-rubl .

  if v-mod  then
     run create-tax (
          input loc_sum-doc ,
          input loc_sum-rubl  ,
          input loc_sum-base   ,
          input loc_sum-contract ,
          input "base":U ,
          output loc_sum-tax-base) .

  loc_sum-tax-rubl    = ( loc_base-rate  / loc_base-scale) * loc_sum-tax-base .
  loc_sum-tax-doc   = (  loc_exch-scale   / loc_exch-rate) * loc_sum-tax-rubl .
  loc_sum-tax-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-tax-rubl .

  display
    loc_sum-doc          when loc_sum-doc          :visible
    loc_sum-base         when loc_sum-base         :visible
    loc_sum-rubl         when loc_sum-rubl         :visible
    loc_sum-contract     when loc_sum-contract     :visible
    loc_sum-tax-doc      when loc_sum-tax-doc      :visible
    loc_sum-tax-rubl     when loc_sum-tax-rubl     :visible
    loc_sum-tax-contract when loc_sum-tax-contract :visible
    loc_sum-tax-base     when loc_sum-tax-base     :visible
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-base Dialog-Frame
ON return OF loc_sum-base IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-contract Dialog-Frame
ON F5 OF loc_sum-contract IN FRAME Dialog-Frame
DO:
  loc_contract-rate = loc_sum-rubl / (loc_contract-scale * DECIMAL ( loc_sum-contract:SCREEN-VALUE )) .
  DISPLAY loc_contract-rate  WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-contract Dialog-Frame
ON LEAVE OF loc_sum-contract IN FRAME Dialog-Frame
DO:
define variable v-mod as logical no-undo .
 v-mod = loc_sum-contract:MODIFIED.


 assign loc_sum-contract loc_sum-tax-contract
 loc_base-rate loc_base-scale
 loc_exch-rate loc_exch-scale
 loc_contract-rate loc_contract-scale
 .
  loc_sum-rubl  =  ( loc_contract-rate  / loc_contract-scale) * loc_sum-contract .
  loc_sum-base   = (  loc_base-scale   / loc_base-rate) * loc_sum-rubl .
  loc_sum-doc   = (  loc_exch-scale   / loc_exch-rate) * loc_sum-rubl .

  if v-mod  then
     run create-tax (
          input loc_sum-doc   ,
          input loc_sum-rubl  ,
          input loc_sum-base  ,
          input loc_sum-contract ,
          input "contract":U ,
          output loc_sum-tax-contract) .


  loc_sum-tax-rubl  =  ( loc_contract-rate  / loc_contract-scale) * loc_sum-tax-contract .
  loc_sum-tax-base   = (  loc_base-scale   / loc_base-rate) * loc_sum-tax-rubl .
  loc_sum-tax-doc   = (  loc_exch-scale   / loc_exch-rate) * loc_sum-tax-rubl .

  display
  loc_sum-base           when loc_sum-base         :visible
  loc_sum-rubl           when loc_sum-rubl         :visible
  loc_sum-tax-base       when loc_sum-tax-base     :visible
  loc_sum-tax-rubl       when loc_sum-tax-rubl     :visible
  loc_sum-contract       when loc_sum-contract     :visible
  loc_sum-tax-contract   when loc_sum-tax-contract :visible
  loc_sum-doc            when loc_sum-doc          :visible
  loc_sum-tax-doc        when loc_sum-tax-doc      :visible
  loc_sum-tax-contract   when loc_sum-tax-contract :visible
  with frame {&frame-name}.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-contract Dialog-Frame
ON return OF loc_sum-contract IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-doc Dialog-Frame
ON F5 OF loc_sum-doc IN FRAME Dialog-Frame
DO:
  IF loc_curr-code <> 0 THEN DO:
      loc_exch-rate = loc_sum-rubl / (loc_exch-scale * DECIMAL ( loc_sum-doc:SCREEN-VALUE )) .
      DISPLAY loc_exch-rate  WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-doc Dialog-Frame
ON LEAVE OF loc_sum-doc IN FRAME Dialog-Frame
DO:
define variable v-mod as logical no-undo .
 v-mod = loc_sum-doc:MODIFIED.
 if v-mod = true then  assign loc_sum-doc  .

  loc_sum-rubl    =  ( loc_exch-rate  / loc_exch-scale) * loc_sum-doc .
  loc_sum-base    = (  loc_base-scale   / loc_base-rate) * loc_sum-rubl .
  loc_sum-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-rubl .

  if v-mod  then
     run create-tax (
          input loc_sum-doc ,
          input loc_sum-rubl  ,
          input loc_sum-base   ,
          input loc_sum-contract ,
          input "doc":U ,
          output loc_sum-tax-doc) .

  loc_sum-tax-rubl       = ( loc_exch-rate        / loc_exch-scale)    * loc_sum-tax-doc .
  loc_sum-tax-base       = (  loc_base-scale      / loc_base-rate)     * loc_sum-tax-rubl .
  loc_sum-tax-contract   = (  loc_contract-scale  / loc_contract-rate) * loc_sum-tax-rubl .

  display
      loc_sum-base          when loc_sum-base         :visible
      loc_sum-rubl          when loc_sum-rubl         :visible
      loc_sum-contract      when loc_sum-contract     :visible
      loc_sum-tax-base      when loc_sum-tax-base     :visible
      loc_sum-tax-rubl      when loc_sum-tax-rubl     :visible
      loc_sum-tax-contract  when loc_sum-tax-contract :visible
      loc_sum-tax-doc       when loc_sum-tax-doc      :visible
      with frame {&frame-name}
      .

 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-doc Dialog-Frame
ON return OF loc_sum-doc IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-rubl Dialog-Frame
ON LEAVE OF loc_sum-rubl IN FRAME Dialog-Frame
DO:
define variable v-mod as logical no-undo .
 v-mod = loc_sum-rubl:MODIFIED.

assign loc_sum-rubl loc_sum-tax-rubl
 loc_base-rate loc_base-scale
 loc_exch-rate loc_exch-scale
 loc_contract-rate loc_contract-scale
 .
  loc_sum-base    = ( loc_base-scale  / loc_base-rate) * loc_sum-rubl .
  loc_sum-doc      = (  loc_exch-scale    / loc_exch-rate) * loc_sum-rubl .
  loc_sum-contract      = (  loc_contract-scale    / loc_contract-rate) * loc_sum-rubl .
  if v-mod  then
     run create-tax (
          input loc_sum-doc   ,
          input loc_sum-rubl  ,
          input loc_sum-base  ,
          input loc_sum-contract ,
          input "rubl":U ,
          output loc_sum-tax-rubl) .

  loc_sum-tax-base     = ( loc_base-scale  / loc_base-rate) * loc_sum-tax-rubl .
  loc_sum-tax-doc      = (  loc_exch-scale    / loc_exch-rate) * loc_sum-tax-rubl .
  loc_sum-tax-contract = (  loc_contract-scale    / loc_contract-rate) * loc_sum-tax-rubl .
  display
  loc_sum-base            when loc_sum-base         :visible
  loc_sum-doc             when loc_sum-doc          :visible
  loc_sum-tax-base        when loc_sum-tax-base     :visible
  loc_sum-tax-doc         when loc_sum-tax-doc      :visible
  loc_sum-contract        when loc_sum-contract     :visible
  loc_sum-tax-contract    when loc_sum-tax-contract :visible
  loc_sum-tax-rubl        when loc_sum-tax-rubl     :visible
  with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-rubl Dialog-Frame
ON return OF loc_sum-rubl IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME p-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-doc-code Dialog-Frame
ON return OF p-doc-code IN FRAME Dialog-Frame /* Внут.№ */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli Dialog-Frame
ON CHOOSE OF r-cli IN FRAME Dialog-Frame /* r-cli */
DO:
    if radio-set-dogovor = true and loc_contract-code-id <> 0 then do:
       run from-contract (
           loc_contract-code-id ,
           par-host-code ,
           {&trio-mode}
            ).
    end.
    else do:
          define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */
          define variable rep-rec2 as recid no-undo .
          def buffer b#clients for clients.
          run ref/cli-all.w ( parParentProc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  rid-list).
          Assign rep-rec2 = integer(rid-list) no-error.
          find first b#clients WHERE recid(b#clients) = rep-rec2 No-LOCK No-ERROR.
          if avail b#clients then do:
              Assign
                  loc_receiver-code = b#clients.obj-code
                  loc_receiver-type = b#clients.obj-type
                  loc_receiver-name = b#clients.obj-name .
          end.
    end.

    Display  loc_receiver-code loc_receiver-name loc_receiver-type
    with frame {&frame-name} .
    Enable  loc_receiver-code  /* loc_receiver-type */
    with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-con
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-con Dialog-Frame
ON CHOOSE OF r-con IN FRAME Dialog-Frame /* r-con */
DO:
define variable   p-rid-list   as character no-undo . /* recid выбранных договоров */
define buffer buf_contract for contract.

  run str/cont-all.w (
      input   parParentProc   ,
      input   par-host-code   ,
      input   "b-sel"         ,
      input   {&company}      ,
      input   ?               ,
      input   ?               ,
      input   ?               ,
      input   ?               ,
      input   "current"       ,
      input   (if p-doc-type = {&income} then {&expense}  else {&income}  )  ,
      input-output p-rid-list )
      .
find first buf_contract no-lock where recid(buf_contract) = integer(p-rid-list) no-error .
if available buf_contract then do:
   loc_contract-code = buf_contract.contract-prn-code.
   loc_contract-code-id = buf_contract.contract-code.
   display loc_contract-code with frame {&frame-name}.
         run from-contract (
              input buf_contract.contract-code ,
              input buf_contract.host-code,
              input {&singl-mode}
              ) no-error .
    if error-status :error then do:
        if error-status :get-message(1) <> "" then    message error-status :get-message(1) return-value 'from-contract' .
        return no-apply.
    end.
run next-focus in this-procedure  (input loc_contract-code:handle ) .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cur Dialog-Frame
ON CHOOSE OF r-cur IN FRAME Dialog-Frame
DO:

define variable ref-rec as recid no-undo.

run ref/currency.w (input  parparentproc , "b-sel", input-output ref-rec ).
if ref-rec = ? then return no-apply.
find currency where recid ( currency ) = ref-rec no-lock.

IF NOT (currency.curr-code = loc_contract-curr   OR
   currency.curr-code = p-basecode        OR
   currency.curr-code = 0 )
    THEN DO:
    MESSAGE "Можно выбрать только национальную валюту, базовую валюту или валюту договора !!! ".
    RETURN NO-APPLY.

END.
loc_curr-code  = currency.curr-code .
loc_abbr-doc   = currency.curr-abbr .

{ gbl/exchrate.i
  loc_curr-code
  loc_doc-date
  loc_exch-rate
  loc_exch-scale
  loc_abbr-doc }

display
  loc_curr-code
  loc_abbr-doc
  loc_exch-rate
  loc_exch-scale
  with frame {&frame-name} .
 apply "LEAVE" to loc_exch-rate  in frame {&frame-name} .
 run hide-curr ( input "pay":U ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj Dialog-Frame
ON CHOOSE OF r-obj IN FRAME Dialog-Frame /* r-obj */
DO:
    if radio-set-dogovor = true and loc_contract-code-id <> 0 then do:
       run from-contract (
           loc_contract-code-id ,
           par-host-code ,
           {&trio-mode}
            ).
    end.
  else do:
  define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */
  define variable rep-rec2 as recid no-undo .

  def buffer b#clients for clients.
    run ref/cli-all.w ( parParentProc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  rid-list).
    Assign rep-rec2 = integer(rid-list) no-error.
    find first b#clients WHERE recid(b#clients) = rep-rec2 No-LOCK No-ERROR.
    if avail b#clients then do:
        Assign
            loc_payer-code = b#clients.obj-code
            loc_payer-type = b#clients.obj-type
            loc_payer-name = b#clients.obj-name .
    end.
 end.
    Display  loc_payer-code loc_payer-name loc_payer-type
    with frame {&frame-name} .
    Enable  loc_payer-code  /* loc_payer-type */ with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj-firm Dialog-Frame
ON CHOOSE OF r-obj-firm IN FRAME Dialog-Frame
DO:
define buffer b#clients for clients.
define variable v-type as char no-undo.
define variable v-code as int no-undo.

      run str/chshobj.w (par-host-code, "", 0, output v-type,OUTPUT v-code).

      find first b#clients WHERE
          v-code = b#clients.obj-code AND
          v-type = b#clients.obj-type
          No-LOCK No-ERROR.

      if avail b#clients then do:
          Assign
              fi-obj-code = b#clients.obj-code
              fi-obj-type = b#clients.obj-type
              fi-obj-name = b#clients.obj-name .
      end.

      Display   fi-obj-code  fi-obj-name  fi-obj-type
      with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-dogovor
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-dogovor Dialog-Frame
ON return OF RADIO-SET-dogovor IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
    return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-dogovor Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-dogovor IN FRAME Dialog-Frame
DO:
  /* */
    ASSIGN radio-set-dogovor.
    IF  radio-set-dogovor = NO THEN DO:
        DISABLE
            B-contract loc_abbr-contract loc_contract-code loc_contract-curr loc_contract-rate loc_contract-scale r-con  T-contract
            WITH FRAME {&FRAME-NAME}.
            loc_contract-code = ""  .
            loc_contract-code-id = 0 .
            DISPLAY loc_contract-code WITH FRAME {&FRAME-NAME}.

    END.
    ELSE DO:
        enable
            B-contract loc_contract-code r-con
            WITH FRAME {&FRAME-NAME}.

    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-base Dialog-Frame
ON VALUE-CHANGED OF T-base IN FRAME Dialog-Frame
DO:
 assign t-base.
  if t-base = yes then do:
      enable
        loc_sum-base
        with frame {&frame-name}.
      disable
        loc_sum-rubl     loc_sum-doc      loc_sum-contract
        with frame {&frame-name}.
      t-rubl = no.
      t-doc = no.
      t-contract = no.
      display
          t-rubl      when t-rubl:visible
          t-doc
          t-contract  when t-contract:visible
          with frame  {&frame-name}.
    end.
        else do:
         t-base = yes.
         display t-base with frame  {&frame-name}.
         end.
loc_in-type            = 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-contract Dialog-Frame
ON VALUE-CHANGED OF T-contract IN FRAME Dialog-Frame
DO:
  assign t-contract.
  if t-contract = yes then do:
      enable
         loc_sum-contract
         with frame {&frame-name}.
      disable
         loc_sum-rubl     loc_sum-base     loc_sum-doc
         with frame {&frame-name}.
      t-rubl = no.
      t-base = no.
      t-doc = no.
      display
         t-rubl   when t-rubl:visible
         t-base   when t-base:visible
         t-doc
         with frame  {&frame-name}.
    end.
    else do:
         t-contract = yes.
         display t-contract with frame  {&frame-name}.
         end.
  loc_in-type = 3.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-doc Dialog-Frame
ON VALUE-CHANGED OF T-doc IN FRAME Dialog-Frame
DO:
  assign t-doc.
  if t-doc = yes then do:
      enable
         loc_sum-doc
         with frame {&frame-name}.
      disable
         loc_sum-rubl     loc_sum-base     loc_sum-contract
         with frame {&frame-name}.
      t-rubl = no.
      t-base = no.
      t-contract = no.
      display
         t-rubl  when t-rubl:visible
         t-base  when t-base:visible
         t-contract  when t-contract:visible
         with frame  {&frame-name}.
    end.
    else do:
         t-doc = yes.
         display t-doc with frame  {&frame-name}.
         end.
  loc_in-type = 0.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-rubl Dialog-Frame
ON VALUE-CHANGED OF T-rubl IN FRAME Dialog-Frame
DO:
  assign t-rubl.
  if t-rubl = yes then do:
      enable
         loc_sum-rubl
         with frame {&frame-name}.
      disable
        loc_sum-doc     loc_sum-base     loc_sum-contract
        with frame {&frame-name}.
      t-doc = no.
      t-base = no.
      t-contract = no.
      display
      t-doc
      t-base      when t-base:visible
      t-contract  when t-contract:visible
      with frame  {&frame-name}.
    end.
    else do:
         t-rubl = yes.
         display t-rubl with frame  {&frame-name}.
         end.
  loc_in-type            = 2.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


{ str/crfinob.i  fin-ob }

/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
{ gbl/ed_date.i loc_pay-date}
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

next-prev = yes.
n-p: do while next-prev :

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }


   run init-p in this-procedure .

     if ref-mode = {&lookup} then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_fin-liability_lookup':U
            {&cntxt-firm}
            par-host-code
            '':U
            0
            0
            0
            0
            true
            g-log
          }
        if not g-log then  return .

        run myenable_lkp in this-procedure .
        run hide-curr in this-procedure ( input "lookup":u ) .
        wait-for go of frame {&frame-name} focus b-exit.
     end.
     else do:
        run myenable_chg in this-procedure .
        if ref-mode = {&add-def}
            then do:
                 run hide-curr ( input "init":u ) .
                 wait-for go of frame {&frame-name} focus RADIO-SET-dogovor .
            end.
            else do:
                /* Для разных статусов */
                 run hide-curr ( input "pay":u ) .
                 if p-status_ <> {&fin-new} then do:
                    run disable-contract  .
                    wait-for go of frame {&frame-name} focus  loc_pay-date.
                 end.
                 else do:
                    wait-for go of frame {&frame-name} focus loc_pay-date .
                 end.
            end.
   end.

END.
end.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-tax Dialog-Frame
PROCEDURE calc-tax :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

define variable v-nalog  as decimal no-undo .
  v-nalog = 0 .

  for each  tt_fin-ob-tax :
     v-nalog = v-nalog + ( tt_fin-ob-tax.sum-vat-line-doc + tt_fin-ob-tax.sum-slt-line-doc ) .
  end.

  loc_sum-tax-doc       = v-nalog .
  loc_sum-tax-rubl      = (  loc_exch-rate       / loc_exch-scale   ) * loc_sum-tax-doc  .
  loc_sum-tax-base      = (  loc_base-scale      / loc_base-rate    ) * loc_sum-tax-rubl .
  loc_sum-tax-contract  = (  loc_contract-scale  / loc_contract-rate) * loc_sum-tax-rubl .

  display
    loc_sum-tax-doc      when loc_sum-tax-doc:visible
    loc_sum-tax-base     when loc_sum-tax-base     :visible
    loc_sum-tax-rubl     when loc_sum-tax-rubl     :visible
    loc_sum-tax-contract when loc_sum-tax-contract :visible
    with frame {&frame-name}
    .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-tax Dialog-Frame
PROCEDURE create-tax :
/* создание налога по умолчанию */
define input parameter  v-sum-doc    as decimal no-undo .
define input parameter  v-sum-rubl   as decimal no-undo .
define input parameter  v-sum-base   as decimal no-undo .
define input parameter  v-sum-contr  as decimal no-undo .
define input parameter  v-type as character no-undo .
define output parameter v-tax  as decimal no-undo .

define variable v-1 as decimal no-undo .
define variable  v-col as integer init 0  no-undo .
define variable v-ok as logical init true no-undo .

define variable v-vat-pc-init as decimal init ? no-undo .
define variable v-slt-pc-init as decimal init ? no-undo .

for each tt_fin-ob-tax :
    v-col = v-col + 1 .
    v-vat-pc-init = tt_fin-ob-tax.vat-pc .
    v-slt-pc-init = tt_fin-ob-tax.slt-pc .
end.

if v-vat-pc-init = ? then v-vat-pc-init = glob-vat-pc .
if v-slt-pc-init = ? then v-slt-pc-init = glob-slt-pc .

    if v-col > 1 then do:
        v-ok = true .
        message
                "Вы уже ввели несколько строк сумм оплат"   skip
                "с разбивкой по налогам!"                   skip "" skip

                "Да- Создать одну новую"                   skip
                "Нет - Оставить введенные строки"           skip
                view-as alert-box question
                buttons yes-no
                update v-ok .

    end.
    if not v-ok then return .


if v-col = 1 then do:
   find first  tt_fin-ob-tax no-error .
end.

if v-col > 1  or v-col = 0 then do:
  for each tt_fin-ob-tax : delete tt_fin-ob-tax. end.
  v-vat-pc-init = glob-vat-pc .
  v-slt-pc-init = glob-slt-pc .
  create tt_fin-ob-tax.
end.

assign
    tt_fin-ob-tax.doc-code                =  p-doc-code
    tt_fin-ob-tax.host-code               =  par-host-code
    tt_fin-ob-tax.line-num                =  1

    tt_fin-ob-tax.sum-line-doc            = v-sum-doc
    tt_fin-ob-tax.sum-line-base           = v-sum-base
    tt_fin-ob-tax.sum-line-contr          = v-sum-contr
    tt_fin-ob-tax.sum-line-rubl           = v-sum-rubl

    tt_fin-ob-tax.with-slt                = true
    tt_fin-ob-tax.slt-pc                  = v-slt-pc-init
    tt_fin-ob-tax.sum-slt-line-doc        = tt_fin-ob-tax.slt-PC *  tt_fin-ob-tax.sum-line-doc   / ( 100 + tt_fin-ob-tax.slt-PC )
    tt_fin-ob-tax.sum-slt-line-base       = tt_fin-ob-tax.slt-PC *  tt_fin-ob-tax.sum-line-base  / ( 100 + tt_fin-ob-tax.slt-PC )
    tt_fin-ob-tax.sum-slt-line-contr      = tt_fin-ob-tax.slt-PC *  tt_fin-ob-tax.sum-line-contr / ( 100 + tt_fin-ob-tax.slt-PC )
    tt_fin-ob-tax.sum-slt-line-rubl       = tt_fin-ob-tax.slt-PC *  tt_fin-ob-tax.sum-line-rubl  / ( 100 + tt_fin-ob-tax.slt-PC )

    tt_fin-ob-tax.with-vat                = true
    tt_fin-ob-tax.vat-pc                  = v-vat-pc-init
    tt_fin-ob-tax.sum-vat-line-doc        = tt_fin-ob-tax.vat-PC * (( tt_fin-ob-tax.sum-line-doc   - tt_fin-ob-tax.sum-slt-line-doc   ) / ( 100  + tt_fin-ob-tax.vat-PC))
    tt_fin-ob-tax.sum-vat-line-base       = tt_fin-ob-tax.vat-PC * (( tt_fin-ob-tax.sum-line-base  - tt_fin-ob-tax.sum-slt-line-base  ) / ( 100  + tt_fin-ob-tax.vat-PC))
    tt_fin-ob-tax.sum-vat-line-contr      = tt_fin-ob-tax.vat-PC * (( tt_fin-ob-tax.sum-line-contr - tt_fin-ob-tax.sum-slt-line-contr ) / ( 100  + tt_fin-ob-tax.vat-PC))
    tt_fin-ob-tax.sum-vat-line-rubl       = tt_fin-ob-tax.vat-PC * (( tt_fin-ob-tax.sum-line-rubl  - tt_fin-ob-tax.sum-slt-line-rubl  ) / ( 100  + tt_fin-ob-tax.vat-PC))

.
case v-type :
when "doc":U then do:
      v-tax = tt_fin-ob-tax.sum-slt-line-doc + tt_fin-ob-tax.sum-vat-line-doc.
end.
when "rubl":U then do:
      v-tax = tt_fin-ob-tax.sum-slt-line-rubl + tt_fin-ob-tax.sum-vat-line-rubl.
end.
when "base":U then do:
      v-tax = tt_fin-ob-tax.sum-slt-line-base + tt_fin-ob-tax.sum-vat-line-base.
end.
when "contract":U then do:
      v-tax = tt_fin-ob-tax.sum-slt-line-contr + tt_fin-ob-tax.sum-vat-line-contr.
end.
end case.

{&OPEN-QUERY-BROWSE-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-contract Dialog-Frame
PROCEDURE disable-contract :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

run from-contract (
    input loc_contract-code-id ,
    input par-host-code               ,
    input {&singl-mode}
      ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
             error-status :get-message(1) skip
             "из договора"
             view-as alert-box error .
     return error.
     end.

disable loc_contract-code  r-con
        loc_payer-code     r-obj
        loc_receiver-code  r-cli
        loc_sum-doc  loc_sum-tax-doc
        loc_sum-rubl loc_sum-tax-rubl
        loc_sum-base loc_sum-tax-base
        loc_sum-contract loc_sum-tax-contract
        loc_exch-rate
        loc_exch-scale
        loc_base-rate
        loc_base-scale
        loc_contract-rate
        loc_contract-scale
        t-doc
        t-rubl
        t-base
        t-contract
        b-ins
        b-chg
        b-del
        radio-set-dogovor
        r-cur
   with frame {&frame-name} .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY RADIO-SET-dogovor loc_contract-code loc_pay-date loc_receiver-code
          loc_prn-doc-code loc_payer-code loc_corr-doc loc_exch-rate
          loc_exch-scale loc_sum-doc loc_sum-tax-doc loc_sum-rubl
          loc_sum-tax-rubl loc_base-rate loc_base-scale loc_sum-base
          loc_sum-tax-base loc_contract-rate loc_contract-scale loc_sum-contract
          loc_sum-tax-contract loc_PS FI-obj FI-obj-type FI-obj-code FI-obj-name
          loc_doc-date loc_fact-date p-doc-code loc_receiver-type
          loc_receiver-name f-receiver loc_payer-type loc_payer-name f-payer
          FILL-IN-4 FILL-IN-5 FILL-IN-6 FILL-IN-7 loc_curr-code loc_abbr-doc
          loc_abbr-rubl loc_abbr-base f-contract-curr loc_contract-curr
          loc_abbr-contract
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-contract B-receiver B-payer B-parts B-hist B-help
         RECT-1 RECT-2 RECT-4 RECT-5 RADIO-SET-dogovor loc_contract-code r-con
         loc_pay-date loc_receiver-code r-cli loc_prn-doc-code loc_payer-code
         loc_corr-doc r-obj r-cur loc_exch-rate loc_exch-scale loc_sum-doc
         loc_sum-contract BROWSE-1 B-calc-exch B-ins B-chg B-del loc_PS FI-obj
         FI-obj-type FI-obj-code FI-obj-name loc_doc-date loc_fact-date
         loc_receiver-type loc_receiver-name f-receiver loc_payer-type
         loc_payer-name f-payer FILL-IN-4 FILL-IN-5 FILL-IN-6 FILL-IN-7
         loc_curr-code loc_abbr-doc loc_abbr-rubl loc_abbr-base f-contract-curr
         loc_contract-curr loc_abbr-contract
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE from-contract Dialog-Frame
PROCEDURE from-contract :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

define input parameter p-code like contract.contract-code no-undo .
define input parameter p-host-code like contract.host-code no-undo .
define input parameter p-local-mode as character no-undo .


define buffer buf_contract for contract.

  find first buf_contract no-lock where buf_contract.contract-code = p-code
                                    and buf_contract.host-code     = p-host-code
                                    no-error .
if error-status :error then do:
   message error-status :get-message(1) "from-contract".
   return error .
   end.

define variable v-num as integer no-undo .
define variable v-buttons as character no-undo .
define variable v-desc as character no-undo .
define variable v-t as character no-undo .
if p-doc-type = {&income} then assign
  v-t = "Плательщика"
.

else assign
  v-t = "Получателя"
.
v-num = 1.
if not( buf_contract.posr-name = "" and
        buf_contract.agnt-name = "" ) then do:

    v-buttons  = "Контрагент" + "|" +
                (if buf_contract.posr-name <> "" then "Посредник" else "Посредник^disable") + "|" +
                (if buf_contract.agnt-name <> "" then "Агент"     else "Агент^disable" )    + "|" +
                "Отмена"
    .
    v-desc     = buf_contract.cli-name + "|" +
                buf_contract.posr-name + "|" +
                buf_contract.agnt-name + "|" +
                "Не выбираем ни кого"
      .
    IF p-local-mode = {&singl-mode} THEN v-num = 1.
       ELSE
        run gbl/d-askw.w
          (input "Внимание!" /* Заголовок окна */
          ,input "Выберите " + v-t + " по фин.обязательству."  /* Общее сообщение */
          ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
          ,input v-buttons /* список названий кнопок  */
          ,input v-desc    /* список описаний кнопок */
          ,input 1 /* значение возвращаемое при нажатии enter */
          ,input 4 /* значение возвращаемое при нажатии escape */
          ,output v-num /* выбор пользователя */
          ).
end.


if v-num = 4 then do:
   return error .
end.

  case p-doc-type :
  when {&income} then do:
   case v-num :
     when 1 then do:
      assign
        loc_payer-code       =  buf_contract.cli-code
        loc_payer-type       =  buf_contract.cli-type
        loc_payer-name       =  buf_contract.cli-name

        .
     end.

     when 2 then do:
      assign
        loc_payer-code       =  buf_contract.posr-code
        loc_payer-type       =  buf_contract.posr-type
        loc_payer-name       =  buf_contract.posr-name
        .

     end.

     when 3 then do:
      assign
        loc_payer-code       =  buf_contract.agnt-code
        loc_payer-type       =  buf_contract.agnt-type
        loc_payer-name       =  buf_contract.agnt-name
        .
     end.
     end case.

       assign
        loc_receiver-code       =  par-host-code
        loc_receiver-type       =  {&cmp}
        loc_receiver-name       =  buf_contract.own-name
      .


  end.
  when {&expense} then do:
     case v-num :
     when 1 then do:
          assign
              loc_receiver-code       =  buf_contract.cli-code
              loc_receiver-type       =  buf_contract.cli-type
              loc_receiver-name       =  buf_contract.cli-name
              .
     end.
     when 2 then do:
          assign
              loc_receiver-code       =  buf_contract.posr-code
              loc_receiver-type       =  buf_contract.posr-type
              loc_receiver-name       =  buf_contract.posr-name
              .
     end.
     when 3 then do:
          assign
              loc_receiver-code       =  buf_contract.agnt-code
              loc_receiver-type       =  buf_contract.agnt-type
              loc_receiver-name       =  buf_contract.agnt-name
              .
     end.

     end case.
        assign
        loc_payer-code       =  par-host-code
        loc_payer-type       =  {&cmp}
        loc_payer-name       =  buf_contract.own-name
      .
  end.
  end case.

  assign
    loc_contract-code-id   =  buf_contract.contract-code
    loc_contract-curr      =  buf_contract.curr-code
    .
 /* Курс валюты договора  */

{ gbl/exchrate.i
  loc_contract-curr
  loc_doc-date
  loc_contract-rate
  loc_contract-scale
  loc_abbr-contract }
  /* дополнительная информация */

    display
      loc_receiver-code
      loc_receiver-name
      loc_receiver-type
      loc_abbr-contract
      loc_payer-code
      loc_payer-name
      loc_payer-type
      loc_contract-curr
      loc_contract-rate
      loc_contract-scale
    with frame {&frame-name} .

 if loc_sum-contract:visible then
    apply "LEAVE" to loc_sum-contract in frame {&frame-name} .

 run hide-curr ( input "contract":U ) .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-curr Dialog-Frame
PROCEDURE hide-curr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 define input parameter p-mode as character no-undo .
/* init , update  , lookup */

/*
  1. loc_curr-code      - валюта платежа
  2. 0                  - р_убл  {&str-rubl}
  3. p-basecode         - баз вал {&str-base}
  4. loc_contract-curr  - договора {&str-contract}
 */


 do
 on error undo, return error return-value
 with frame {&frame-name} :

  disable loc_exch-rate  loc_exch-scale  .

 case p-mode :
 when "init" then do:
      if loc_curr-code = 0 then do: /* Закрываем строку р_убли    2  */
        hide {&str-rubl} in frame {&frame-name} .
      end.

      if p-basecode = 0 then do:  /* Закрываем строку баз вал    3 */
        hide {&str-base} in frame {&frame-name} .
      end.

      if loc_contract-curr = 0  or
          (   loc_contract-curr = p-basecode
           and loc_contract-rate = loc_base-rate ) then do:  /* Закрываем строку договора  4 */
          hide {&str-contract} in frame {&frame-name} .
      end.
 end.

 when "contract" then do:
      if  loc_contract-curr = 0  or
          loc_contract-curr = p-basecode or
          loc_contract-curr = loc_curr-code  then do:  /* Закрываем строку договора  4 */
          hide {&str-contract} in frame {&frame-name} .
      end.
      else do:
         display  {&str-contract} .
      end.
 end.

 when "pay" then do:
      if loc_curr-code <> 0 then do: /* Открыть строку р_убли    2  */
        display {&str-rubl}  .
      end.
      else do:
          hide {&str-rubl} .
      end.

      if ( p-basecode = loc_curr-code and
           loc_exch-rate = loc_base-rate )
         or
         p-basecode = 0   then do:  /* Закрываем строку баз вал    3 */
        hide {&str-base} in frame {&frame-name} .
      end.
      else do:
         display  {&str-base} .
      end.

      if  loc_contract-curr = 0  or
          (loc_contract-curr = p-basecode  and
           loc_contract-rate = loc_base-rate)
          or
          (loc_contract-curr = loc_curr-code  and
           loc_exch-rate = loc_contract-rate )
          then do:  /* Закрываем строку договора  4 */
          hide {&str-contract} in frame {&frame-name} .
      end.
      else do:
         display  {&str-contract} .
      end.
 end.
 when "lookup" then do:
      if loc_curr-code <> 0 then do: /* Открыть строку р_убли    2  */
        display {&str-rubl}  .
      end.
      else do:
          hide {&str-rubl} .
      end.

      if ( p-basecode = loc_curr-code
          and loc_exch-rate = loc_base-rate)
         or
         p-basecode = 0   then do:  /* Закрываем строку баз вал    3 */
        hide {&str-base} in frame {&frame-name} .
      end.
      else do:
         display  {&str-base} .
      end.

      if  loc_contract-curr = 0  or
          (loc_contract-curr = p-basecode  and
           loc_contract-rate = loc_base-rate)
          or
          (loc_contract-curr = loc_curr-code  and
           loc_exch-rate = loc_contract-rate )
           then do:  /* Закрываем строку договора  4 */
          hide {&str-contract} in frame {&frame-name} .
      end.
      else do:
         display  {&str-contract} .
      end.
      hide b-quit in frame {&frame-name} .
 end.

end case .


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-p Dialog-Frame
PROCEDURE init-p :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
define buffer buff_contract for contract.
  { gbl/basecode.i par-host-code p-basecode }
    find first sysconf no-lock where sysconf.host-code = par-host-code no-error .
    glob-vat-pc  = sysconf.fin-vat-pc .
    glob-slt-pc  = sysconf.fin-slt-pc .
    var-fin-calc = sysconf.fin-calc   .
    /* Надо считать из user-flt  */
    define variable g-log as logical no-undo.
    define variable v-view as character no-undo .



    if ref-mode =  {&add-def}
        then  do:
            ri = ?.
            run fin-ob-code (input g#db-num , output p-doc-code) .
            assign
                  p-prn-doc-code     = string(p-doc-code)
                  p-host-code        = par-host-code
                  p-doc-date         = today
                  p-status_          = {&g___new}
                  p-payer-name       = ""
                  p-receiver-name    = ""
                  p-payer-code       = 0
                  p-receiver-code    = 0
                  p-payer-type       = {&cmp}
                  p-receiver-type    = {&cmp}
                  p-in-type          = 0
                  p-sum-doc          = 0
                  p-user-db-num-doc  = g#db-num
                  p-user-name-doc    = g#userid
                  radio-set-dogovor  = YES
            .
                  define buffer b#clients for clients.
                  find first b#clients WHERE
                        b#clients.obj-code = par-host-code and
                        b#clients.obj-type = {&cmp}
                        No-LOCK No-ERROR.

                  if p-doc-type <> {&income} then do:
                      if avail b#clients then
                          Assign
                              p-payer-code = b#clients.obj-code
                              p-payer-type = b#clients.obj-type
                              p-payer-name = b#clients.obj-name .
                  end.
                  else do:
                      if avail b#clients then
                          Assign
                              p-receiver-code = b#clients.obj-code
                              p-receiver-type = b#clients.obj-type
                              p-receiver-name = b#clients.obj-name .

                  end.
            { gbl/baserate.i
              par-host-code
              today
              p-base-rate
              p-base-scale     }
              /* валюта платежа по умолчанию Р_УБЛИ */
              p-curr-code  = 0.
              p-exch-rate  = 1.
              p-exch-scale = 1.
              /* валюта договора по умолчанию если его нет = БазВал*/
              p-contract-curr  = p-basecode  .
              p-contract-rate  = p-base-rate .
              p-contract-scale = p-base-scale.
            /* На экран */
            assign
              loc_base-rate          =  p-base-rate
              loc_base-scale         =  p-base-scale
              loc_receiver-code      =  p-receiver-code
              loc_receiver-name      =  p-receiver-name
              loc_receiver-type      =  p-receiver-type
              loc_contract-code-id   =  p-contract-code
              loc_curr-code          =  p-curr-code
              loc_doc-date           =  p-doc-date
              loc_exch-rate          =  p-exch-rate
              loc_exch-scale         =  p-exch-scale
              loc_fact-date          =  p-fact-date
              loc_payer-code         =  p-payer-code
              loc_payer-name         =  p-payer-name
              loc_payer-type         =  p-payer-type
              loc_pay-date           =  p-pay-date
              loc_prn-doc-code       =  p-prn-doc-code
              loc_sum-base           =  p-sum-base
              loc_sum-doc            =  p-sum-doc
              loc_sum-rubl           =  p-sum-rubl
              loc_doc-type           =  p-doc-type
              loc_status_            =  p-status_
              loc_in-type            =  p-in-type
              loc_sum-tax-rubl       =  p-sum-tax-rubl
              loc_sum-tax-base       =  p-sum-tax-base
              loc_sum-tax-doc        =  p-sum-tax-doc

              loc_contract-curr     = p-contract-curr
              loc_contract-rate     = p-contract-rate
              loc_contract-scale    = p-contract-scale
              loc_sum-contract      = p-sum-contract
              loc_sum-tax-contract  = p-sum-tax-contract
              loc_contract-code   = ""
              loc_abbr-contract   = ""
              .


    end. /* add*/

    else dO:  /*  all */

       find fin-ob where recid( fin-ob ) = ri no-error .
       if error-status :error then return  error .
            assign
              p-doc-code             =  fin-ob.doc-code
              loc_base-rate          =  fin-ob.base-rate
              loc_base-scale         =  fin-ob.base-scale
              loc_receiver-code      =  fin-ob.receiver-code
              loc_receiver-name      =  fin-ob.receiver-name
              loc_receiver-type      =  fin-ob.receiver-type
              loc_contract-code-id   =  fin-ob.contract-code
              radio-set-dogovor      =  IF ( fin-ob.contract-code = 0 OR fin-ob.contract-code = ?)
                                           THEN NO ELSE YES
              loc_curr-code          =  fin-ob.curr-code
              loc_doc-date           =  fin-ob.doc-date
              loc_exch-rate          =  fin-ob.exch-rate
              loc_exch-scale         =  fin-ob.exch-scale
              loc_fact-date          =  fin-ob.fact-date
              loc_payer-code         =  fin-ob.payer-code
              loc_payer-name         =  fin-ob.payer-name
              loc_payer-type         =  fin-ob.payer-type
              loc_pay-date           =  fin-ob.pay-date
              loc_prn-doc-code       =  fin-ob.prn-doc-code
              loc_sum-base           =  fin-ob.sum-base
              loc_sum-doc            =  fin-ob.sum-doc
              loc_sum-rubl           =  fin-ob.sum-rubl
              loc_doc-type           =  fin-ob.doc-type
              loc_status_            =  fin-ob.status_
              loc_in-type            =  fin-ob.in-type
              loc_sum-tax-rubl       =  fin-ob.sum-tax-rubl
              loc_sum-tax-base       =  fin-ob.sum-tax-base
              loc_sum-tax-doc        =  fin-ob.sum-tax-doc
              loc_contract-curr      =  fin-ob.contract-curr
              loc_contract-rate      =  fin-ob.contract-rate
              loc_contract-scale     =  fin-ob.contract-scale
              loc_sum-contract       =  fin-ob.sum-contract
              loc_sum-tax-contract   =  fin-ob.sum-tax-contract
              loc_ps                 =  fin-ob.ps
              loc_corr-doc           =  fin-ob.corr-doc
              .

/*------------*/
  assign
    fi-obj-type            =  fin-ob.obj-type
    fi-obj-code            =  fin-ob.obj-code
  .
 define buffer b2#clients for clients .
    find first b2#clients where
        b2#clients.obj-code = fi-obj-code and
        b2#clients.obj-type = fi-obj-type
        no-lock no-error.
    if available b2#clients then do:
        fi-obj-name = b2#clients.obj-name.
    end.

/*------------*/


    find first buff_contract no-lock where buff_contract.host-code = fin-ob.host-code and
                                           buff_contract.contract-code = fin-ob.contract-code no-error .
    if available buff_contract then
       loc_contract-code        =  buff_contract.contract-prn-code .
       else loc_contract-code   = "".

    loc_abbr-contract  = sel-abbr(loc_contract-curr) .


end.
/* all */
    loc_abbr-base = "Баз.вал "  + sel-abbr(p-basecode) .
    loc_abbr-doc  = sel-abbr(loc_curr-code) .


    case loc_in-type :
      when 0 then do:
        t-doc = yes.
      end.
      when 1 then do:
        t-base = yes.
      end.
      when 2 then do:
        t-rubl = yes.
      end.
      when 3 then do:
        t-contract = yes.
      end.
    end case.


 /* с 07.05.2004 только в сумме платежа */
    ASSIGN
    loc_in-type = 0
    t-doc = YES
    t-base = NO
    t-rubl = NO
    t-contract = NO
        .

   /* налоги */
   define buffer buf_fin-ob-tax for fin-ob-tax.
   for each tt_fin-ob-tax : delete tt_fin-ob-tax. end.


   for each buf_fin-ob-tax no-lock where
            buf_fin-ob-tax.host-code = par-host-code and
            buf_fin-ob-tax.doc-code  = p-doc-code
   :
      create tt_fin-ob-tax.
      BUFFER-COPY buf_fin-ob-tax to tt_fin-ob-tax .
   end.
   {&OPEN-QUERY-BROWSE-1}
   define variable loc_doc-type-fff as character no-undo .
   if loc_doc-type = {&income} then loc_doc-type-fff = "с покупателем " .
      else  loc_doc-type-fff = "с поставщиком " .
   ASSIGN frame {&frame-name}:TITLE = "Фин.обязательство  "  + " № " + loc_prn-doc-code
   + " Тип: " +     loc_doc-type-fff
   + " Статус: "  +  loc_status_
   + " - " + caps(ref-mode).



  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lookup-cli Dialog-Frame
PROCEDURE lookup-cli :
do
on error undo, return error return-value
:
define input parameter loc_cli-code as integer no-undo .
define input parameter loc_cli-type as character no-undo .

  run ref/showcli.p (
    input parParentProc
    ,input loc_cli-type /* p-obj-type */
    ,input loc_cli-code /* p-obj-code */
    ).
end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable_chg Dialog-Frame
PROCEDURE myenable_chg :
/* -----------------------------------------------------------
  Purpose: для корректировки
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

  DISPLAY loc_prn-doc-code  loc_payer-code loc_payer-type
          loc_contract-code loc_receiver-code loc_receiver-type loc_pay-date loc_sum-doc
          loc_contract-rate loc_contract-scale
          loc_exch-rate loc_exch-scale
          loc_base-rate loc_sum-rubl
          loc_sum-base
          /* T-doc T-contract T-rubl T-base */
          loc_base-scale loc_doc-date
          loc_fact-date
          loc_payer-name loc_receiver-name
          loc_curr-code loc_abbr-doc loc_abbr-base
          p-doc-code
          loc_contract-code
          loc_sum-tax-doc
          loc_sum-tax-rubl
          loc_sum-tax-base
          loc_sum-tax-contract
          loc_sum-contract
          loc_contract-curr
          loc_abbr-contract
          loc_abbr-doc
          loc_abbr-base
          RADIO-SET-dogovor
          b-prev b-next loc_abbr-rubl
          B-parts
          FILL-IN-4 FILL-IN-5 FILL-IN-6 FILL-IN-7
          {&List-full-mode}
          f-payer
          f-receiver
          B-contract
          B-payer
          B-receiver
          f-contract-curr
          loc_PS
          loc_corr-doc
          b-calc-exch
          loc_fact-date
          fi-obj        when var-fin-calc = {&fin-calc-obj}
          fi-obj-type   when var-fin-calc = {&fin-calc-obj}
          fi-obj-code   when var-fin-calc = {&fin-calc-obj}
          fi-obj-name   when var-fin-calc = {&fin-calc-obj}
          WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help b-quit
         loc_prn-doc-code
         r-con                 when radio-set-dogovor = true

         loc_payer-code        when p-doc-type = {&income}
         loc_payer-type        when p-doc-type = {&income}
         r-obj                 when p-doc-type = {&income}
         loc_receiver-code     when p-doc-type <> {&income}
         loc_receiver-type     when p-doc-type <> {&income}
         r-cli                 when p-doc-type <> {&income}
         loc_pay-date
         /* T-doc T-rubl T-base t-contract

         loc_contract-rate     when radio-set-dogovor = true
         loc_contract-scale    when radio-set-dogovor = true
         loc_base-rate
         loc_base-scale
         loc_exch-rate
         loc_exch-scale
         */
        BROWSE-1
        B-ins B-chg B-del
        loc_doc-date

        loc_curr-code
        r-cur
        loc_sum-doc       when t-doc      = yes
        loc_sum-rubl      when t-rubl     = yes
        loc_sum-base      when t-base     = yes
        loc_sum-contract  when t-contract = yes
        loc_contract-code   when radio-set-dogovor = true
        RADIO-SET-dogovor
        B-contract          when radio-set-dogovor = true
        B-payer
        B-receiver
        B-parts
        loc_PS
        loc_corr-doc
        b-hist
        B-calc-exch         when  p-status_ = {&fin-new}
        r-obj-firm          when  p-status_ = {&fin-new} and var-fin-calc = {&fin-calc-obj}
      WITH FRAME Dialog-Frame.

      b-exit:label in frame {&frame-name}  = "&Ввод" .

  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}



  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable_lkp Dialog-Frame
PROCEDURE myenable_lkp :
/*------------------------------------------------------------------------------
  Purpose: для просмотра
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  IF AVAILABLE fin-ob THEN
    DISPLAY
    loc_base-rate
    loc_base-scale
    loc_receiver-code
    loc_receiver-name
    loc_receiver-type
    loc_contract-code
    loc_contract-rate
    loc_contract-scale
    loc_curr-code
    loc_doc-date loc_exch-rate loc_exch-scale loc_fact-date loc_payer-code loc_payer-name loc_payer-type loc_pay-date
    loc_prn-doc-code
    loc_sum-base
    loc_sum-doc
    loc_sum-rubl

    loc_abbr-base
    loc_abbr-doc
    p-doc-code
    loc_sum-tax-doc
    loc_sum-tax-rubl
    loc_sum-tax-base
    b-prev
    b-next
    B-parts
/*    T-base T-contract T-doc T-rubl */
    loc_sum-contract
    loc_sum-tax-contract
    loc_contract-curr
    loc_abbr-contract
    loc_abbr-rubl
    FILL-IN-4 FILL-IN-5 FILL-IN-6 FILL-IN-7
          {&List-full-mode}
          f-payer
          f-receiver
          B-contract
          B-payer
          B-receiver
          f-contract-curr
          RADIO-SET-dogovor
          loc_PS
          loc_corr-doc
          fi-obj       when var-fin-calc = {&fin-calc-obj}
          fi-obj-type  when var-fin-calc = {&fin-calc-obj}
          fi-obj-code  when var-fin-calc = {&fin-calc-obj}
          fi-obj-name  when var-fin-calc = {&fin-calc-obj}
          WITH FRAME Dialog-Frame.
   enable b-exit b-help
          BROWSE-1
          b-next  b-prev
          B-contract  when radio-set-dogovor = true
          B-payer
          B-receiver
          B-parts
          b-hist
      WITH FRAME Dialog-Frame.
      disable {&orig} WITH FRAME Dialog-Frame.

  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-focus Dialog-Frame
PROCEDURE next-focus :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .

  assign
    l-apply-entry = /* false */  true
  .

  do with frame {&frame-name} :
    if  loc_prn-doc-code   :handle = p-widget-handle then do:  if loc_contract-code    :sensitive then do:
                                                                                        apply "entry":u to loc_contract-code .  return .
                                                                                        end.
                                                                                        else do:  if loc_pay-date      :sensitive then do:
                                                                                                  apply "entry":u to loc_pay-date      .  return . end.
                                                                                        end.
    end.
    if  radio-set-dogovor  :handle = p-widget-handle then do:  if loc_contract-code    :sensitive
                                                                  then do: apply "entry":u to loc_contract-code .  return . end.
                                                                  else do:  if loc_pay-date      :sensitive then do: apply "entry":u to loc_pay-date      .  return . end. end.
    end.
    if  loc_contract-code  :handle = p-widget-handle then do:  if loc_pay-date      :sensitive then do: apply "entry":u to loc_pay-date      .  return . end. end.
    if  loc_pay-date       :handle = p-widget-handle then do:  if loc_receiver-code :sensitive then do: apply "entry":u to loc_receiver-code .  return . end. end.
    if  loc_receiver-code  :handle = p-widget-handle then do:  if loc_payer-code    :sensitive then do:
                                                                 apply "entry":u to loc_payer-code    .  return .
                                                               end.
                                                               else do:
                                                                  if loc_sum-doc      :sensitive then do: apply "entry":u to loc_sum-doc      .  return . end.
                                                                  if loc_sum-base     :sensitive then do: apply "entry":u to loc_sum-base     .  return . end.
                                                                  if loc_sum-rubl     :sensitive then do: apply "entry":u to loc_sum-rubl     .  return . end.
                                                                  if loc_sum-contract :sensitive then do: apply "entry":u to loc_sum-contract .  return . end.
                                                               end.
                                                          end.

    if  loc_payer-code     :handle = p-widget-handle then do:
        if loc_sum-doc      :sensitive then do: apply "entry":u to loc_sum-doc      .  return . end.
        if loc_sum-base     :sensitive then do: apply "entry":u to loc_sum-base     .  return . end.
        if loc_sum-rubl     :sensitive then do: apply "entry":u to loc_sum-rubl     .  return . end.
        if loc_sum-contract :sensitive then do: apply "entry":u to loc_sum-contract .  return . end.
    end.

    if  loc_sum-doc        :handle = p-widget-handle then do:  if B-chg     :sensitive then do:       apply "entry":u to B-chg     .        return . end. end.
    if  loc_sum-base       :handle = p-widget-handle then do:  if B-chg     :sensitive then do:       apply "entry":u to B-chg     .        return . end. end.
    if  loc_sum-rubl       :handle = p-widget-handle then do:  if B-chg     :sensitive then do:       apply "entry":u to B-chg     .        return . end. end.
    if  loc_sum-contract   :handle = p-widget-handle then do:  if B-chg     :sensitive then do:       apply "entry":u to B-chg     .        return . end. end.
    if  b-chg              :handle = p-widget-handle then do:  if B-exit    :sensitive then do:       apply "entry":u to B-exit    .        return . end. end.

    end. /* do with frame */
  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-p Dialog-Frame
PROCEDURE save-p :
do
 on error undo, return error return-value
 :
if ref-mode <> {&lookup} then do:

/* ОШИБКИ ---------------------------------------------------------------------------------------------------------------*/
       if loc_sum-doc  = 0 or loc_sum-doc  = ?  or
          loc_sum-base = 0 or loc_sum-base = ?  or
          loc_sum-rubl = 0 or loc_sum-rubl = ?  then do:
          message "Не задана сумма финансового обязательства !" view-as alert-box information  title "Ошибка при вводе".
          return error.
      end.

      if var-fin-calc = {&fin-calc-obj} and ( fi-obj-code = 0 or fi-obj-code = ? )  then do:
        message "Не задан Объект !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.


      if loc_receiver-code = 0 or loc_receiver-code = ? then do:
        message "Не задан код получателя !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.
      if loc_payer-code = 0 or loc_payer-code = ? then do:
        message "Не задан код плательщика !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.

      if not( loc_receiver-type = {&cmp} or loc_receiver-type = {&prs} ) then do:
        message "Не верно задан тип получателя !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.

      if not( loc_payer-type = {&cmp} or loc_payer-type = {&prs} ) then do:
        message "Не верно задан тип плательщика !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.


      if loc_receiver-code = loc_payer-code  and
         loc_receiver-type = loc_payer-type then do:
        message "Код получателя равен коду плательщика !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.


      if not can-find (first clients where clients.obj-code = loc_receiver-code
                                      and clients.obj-type = loc_receiver-type no-lock )
        then do:
        message "Не верно выбран получатель !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.
      if not can-find (first clients where clients.obj-code = loc_payer-code
                                      and clients.obj-type = loc_payer-type no-lock )
        then do:
        message "Не верно выбран плательшик !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.

/* проверка правельности ПОК и ПЛАТ */
  case p-doc-type :
  when {&income} then do:
    if not  ( loc_receiver-code       =  par-host-code       and loc_receiver-type       =  {&cmp})
        then do:
         message
            "Внимание !!!"  skip
            "Данные по ПОЛУЧАТЕЛЮ не верны ! "  skip
            view-as alert-box information
              .
            return error .
        end.
  end.
  when {&expense} then do:
    if not         ( loc_payer-code       =  par-host-code       and loc_payer-type       =  {&cmp})    then do:
         message
            "Внимание !!!"  skip
            "Данные по ПЛАТЕЛЬЩИКУ не верны ! "  skip
            view-as alert-box information
              .
            return error .
        end.

  end.
  end case.


/*  проверка на совпадение по строкам налогов  */
      define variable v-sum1 as decimal no-undo .
      define variable v-ok as logical init true no-undo .

      v-sum1 = 0 .
      for each tt_fin-ob-tax :
          v-sum1  = v-sum1 + tt_fin-ob-tax.sum-line-doc .
      end.
      if  v-sum1 = 0  then do:
        message
         "Не введены налоги !!! "
        view-as alert-box information  title "Ошибка при вводе налогов".
        return error .
      end.

 /* проверка суммы налогов */
      if p-status_ = {&fin-new}   then do:
          if loc_sum-doc <> v-sum1      then do:
            message
            substitute ( "Общая сумма документа &1, а сумма всех компонент , по которым исчислялся налог = &2", loc_sum-doc, v-sum1 )
            view-as alert-box information  title "Ошибка при вводе налогов".
            return error .
          end.
      end.

/* ВОПРОСЫ --------------------------------------------------------------------------------------------------------------*/
 /* проверка даты платежа */
      if  loc_pay-date = ?
        then do:
          message  "Не задана дата платежа!"  skip
                   "Сохраняем фин.обязательство ? "          skip
                  view-as alert-box question
                  buttons yes-no
                  update v-ok
                .
           if v-ok = false then  return error.
      end.
 if radio-set-dogovor = true and (
    loc_contract-code-id = 0  or
    loc_contract-code-id = ?
    )
   then do:
          message  "Договор не задан , но указано что ФО с договором !"  skip
                   "Сохраняем фин.обязательство без договора ? "          skip
                  view-as alert-box question
                  buttons yes-no
                  update v-ok
                .
           if v-ok = false then  return error.
  end.
/*  проверка заполнения данных из контракта */
 run ver-data in this-procedure no-error .
 if error-status :error then do:
 return error .
end.
/*-----------------------------------------------------*/
if ref-mode = {&add-def} then do:
       run create-fin-liab in this-procedure (
                input no ,
        input  p-doc-code            ,
        input  p-doc-date            ,
        input  p-doc-type            ,
        input  p-payer-name          ,
        input  p-receiver-name       ,
        input  p-curr-code           ,
        input  p-sum-doc             ,
        input  p-user-db-num-doc     ,
        input  p-user-name-doc       ,
        input  p-base-rate           ,
        input  p-base-scale          ,
        input  p-receiver-code       ,
        input  p-receiver-type       ,
        input  p-contract-code       ,
        input  p-exch-rate           ,
        input  p-exch-scale          ,
        input  p-contract-curr       ,
        input  p-contract-rate       ,
        input  p-contract-scale      ,
        input  p-fact-date           ,
        input  p-fact-order          ,
        input  p-host-code           ,
        input  p-payer-code          ,
        input  p-payer-type          ,
        input  p-pay-date            ,
        input  p-prn-doc-code        ,
        input  p-status_             ,
        input  p-sum-base-orig       ,
        input  p-sum-base            ,
        input  p-sum-doc-orig        ,
        input  p-sum-rubl-orig       ,
        input  p-sum-rubl            ,
        input  p-sum-contract        ,
        input  p-trn-doc-code        ,
        input  p-user-db-num-fact    ,
        input  p-user-db-num-pay        ,
        input  p-user-name-fact         ,
        input  p-user-name-pay          ,
        input  p-in-type                ,
        input  p-sum-tax-base           ,
        input  p-sum-tax-doc            ,
        input  p-sum-tax-rubl           ,
        input  p-sum-tax-contract       ,
        input  ""                       ,
        output ri ).
end.

    find current fin-ob  exclusive-lock   no-error.
    if available fin-ob then do:
      assign
        fin-ob.obj-code             = fi-obj-code
        fin-ob.obj-type             = fi-obj-type
        fin-ob.contract-code        = loc_contract-code-id
        fin-ob.receiver-code        = loc_receiver-code
        fin-ob.receiver-name        = loc_receiver-name
        fin-ob.receiver-type        = loc_receiver-type
        fin-ob.doc-date             = loc_doc-date
        fin-ob.base-rate            = loc_base-rate
        fin-ob.base-scale           = loc_base-scale
        fin-ob.curr-code            = loc_curr-code
        fin-ob.exch-rate            = loc_exch-rate
        fin-ob.exch-scale           = loc_exch-scale
        fin-ob.fact-date            = loc_fact-date
        fin-ob.payer-code           = loc_payer-code
        fin-ob.payer-name           = loc_payer-name
        fin-ob.payer-type           = loc_payer-type
        fin-ob.pay-date             = loc_pay-date
        fin-ob.prn-doc-code         = loc_prn-doc-code
        .
        if p-status_ = {&fin-new} then do:
        assign
            fin-ob.sum-base             = loc_sum-base
            fin-ob.sum-doc              = loc_sum-doc
            fin-ob.sum-rubl             = loc_sum-rubl
            fin-ob.sum-contract         = loc_sum-contract

            fin-ob.sum-tax-base             = loc_sum-tax-base
            fin-ob.sum-tax-doc              = loc_sum-tax-doc
            fin-ob.sum-tax-rubl             = loc_sum-tax-rubl
            fin-ob.sum-tax-contract         = loc_sum-tax-contract
        .
        end.
        assign
          fin-ob.contract-curr        = loc_contract-curr
          fin-ob.contract-rate        = loc_contract-rate
          fin-ob.contract-scale       = loc_contract-scale
          fin-ob.ps                   = loc_ps
          fin-ob.corr-doc             = loc_corr-doc
        .
      if t-doc      then fin-ob.in-type  = 0 .
      if t-base     then fin-ob.in-type  = 1 .
      if t-rubl     then fin-ob.in-type  = 2 .
      if t-contract then fin-ob.in-type  = 3 .
        if p-status_ = {&fin-new} then do:
              for each fin-ob-tax  exclusive-lock  where  fin-ob-tax.host-code = fin-ob.host-code and
                                                          fin-ob-tax.doc-code  = fin-ob.doc-code :
                  delete fin-ob-tax .
              end .
              for each tt_fin-ob-tax :
                  create fin-ob-tax .
                  BUFFER-COPY tt_fin-ob-tax to fin-ob-tax
                  assign
                    fin-ob-tax.host-code = fin-ob.host-code
                    fin-ob-tax.doc-code  = fin-ob.doc-code
                .
              end.
        end.

end.
else do:
 message "Ошибка при сохранении данных "  skip vss-workfile vss-revision vss-description skip
         error-status :get-message(1) .
 return no-apply.
end.
end.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE step-next Dialog-Frame
PROCEDURE step-next :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
if valid-handle (br-handle) then do:
  g#log = br-handle:select-next-row() no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
     end.

  if not g#log then message "Это последний документ списка.".
end.

    ri = recid ( buf_fin-liab ).
    next-prev = yes.
  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE step-prev Dialog-Frame
PROCEDURE step-prev :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

if valid-handle (br-handle) then do:
  g#log = br-handle:select-prev-row() no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
  end.
  if not g#log then do: message "Это первый документ списка.".   end.
end.
ri = recid (buf_fin-liab).
next-prev = yes .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-data Dialog-Frame
PROCEDURE ver-data :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

/*  проверка заполнения данных из контракта */
IF  loc_contract-code-id <> 0 THEN DO:
    define buffer buf_contract for contract.
  find first buf_contract where buf_contract.contract-code     = loc_contract-code-id
                            and buf_contract.host-code         = par-host-code
                        no-lock no-error .
  if not available buf_contract then do:
     message "Не верно введен Номер договора!!! " view-as alert-box error  .
     return error .
  end.

  case p-doc-type :
  when {&income} then do:
    if not ((
        ( loc_payer-code       =  buf_contract.cli-code  and loc_payer-type       =  buf_contract.cli-type  ) or
        ( loc_payer-code       =  buf_contract.posr-code and loc_payer-type       =  buf_contract.posr-type ) or
        ( loc_payer-code       =  buf_contract.agnt-code and loc_payer-type       =  buf_contract.agnt-type ))
        and
        ( loc_receiver-code       =  par-host-code       and loc_receiver-type       =  {&cmp}))
        then do:
         message
         "Внимание !!!"  skip
         "Данные по ПЛАТЕЛЬЩИКУ или ПОЛУЧАТЕЛЮ взяты не из договора ! "  skip
         view-as alert-box information
         title "Приходное ФО"
          .
         return error .
        end.
  end.


  when {&expense} then do:
/*
  message
         "cli-code  " loc_receiver-code       =  buf_contract.cli-code   buf_contract.contract-code skip
         "cli-type  " loc_receiver-type       =  buf_contract.cli-type  skip
         "posr-code " loc_receiver-code       =  buf_contract.posr-code skip
         "posr-type " loc_receiver-type       =  buf_contract.posr-type skip
         "agnt-code " loc_receiver-code       =  buf_contract.agnt-code skip
         "agnt-type " loc_receiver-type       =  buf_contract.agnt-type skip
         skip
         loc_payer-code       =  par-host-code             skip
         loc_payer-type       =  {&cmp}                 skip
          .
  */
    if not ((
        ( loc_receiver-code       =  buf_contract.cli-code  and loc_receiver-type       =  buf_contract.cli-type  ) or
        ( loc_receiver-code       =  buf_contract.posr-code and loc_receiver-type       =  buf_contract.posr-type ) or
        ( loc_receiver-code       =  buf_contract.agnt-code and loc_receiver-type       =  buf_contract.agnt-type ))
        and
        ( loc_payer-code       =  par-host-code       and loc_payer-type       =  {&cmp}))
        then do:
         message
         "Внимание !!!"  skip
         "Данные по ПЛАТЕЛЬЩИКУ или ПОЛУЧАТЕЛЮ взяты не из договора ! "  skip
         view-as alert-box information
         title "Расходное ФО"
          .
         return error .
        end.
  end.
  end case.

END.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
  ( p-curr-code as int ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable rr as character no-undo .
  find first currency no-lock where  currency.curr-code  = p-curr-code no-error.
  rr = currency.curr-abbr .
  RETURN rr.



END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
