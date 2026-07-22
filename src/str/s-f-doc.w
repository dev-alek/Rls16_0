&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр и изменения счета-фактуры

Автор: Чернова Светлана Александровна
Дата создания: 10/18/05
Author: Svetlana Chernova
Creation date: 10/18/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code as integer   no-undo .
define input  parameter p-db-num    as integer   no-undo .
define input  parameter ref-mode    as character no-undo .   /* {&add-def}, {&update}, {&lookup}, "history" */
define input  parameter p-doc-code  as character no-undo .
define input  parameter p-chip-num  as integer   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Просмотр и изменения счета-фактуры":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ cmp/library.i }
/*{ gbl/fltfield.i }*/
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }

define variable g-log as logical   no-undo .
define variable res as logical   no-undo .
define variable ii as integer   no-undo .
define variable s-no-VAT as decimal   no-undo .
define variable s-0-VAT  as decimal   no-undo .
define variable s-10-VAT as decimal   no-undo .
define variable s-20-VAT  as decimal   no-undo .
define variable p-sys-time as character no-undo .

define buffer buf_schet-fact-doc for  ub.schet-fact-doc .
define buffer buf_c-schet-fact-doc for  ub.c-schet-fact-doc .
define buffer buf_person for ub.person.
define buffer buf_firm for ub.firm.
define buffer buf_clients for ub.clients.
define buffer buf_goods for ub.goods  .

define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
define new shared buffer   buf_contract for ub.contract.

define temp-table temp-line no-undo like ub.schet-fact-line
  field   artic as character init  ""
  field   edit  as logical init no
  index pi1 edit
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-line

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 temp-line.artic temp-line.gds-name ~
temp-line.unit-base temp-line.fact-qnty temp-line.price-rubl ~
temp-line.sum-rubl temp-line.excise temp-line.VAT-pc temp-line.VAT-rubl ~
temp-line.sum-rubl-VAT temp-line.country temp-line.gtd temp-line.part-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH temp-line WHERE TRUE /* Join to temp-line incomplete */ NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY BROWSE-1 FOR EACH temp-line WHERE TRUE /* Join to temp-line incomplete */ NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp-line
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp-line


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK b-exit B-sel-contract B-sel-docum ~
b-hist B-Help doc-code book-code doc-date ext-doc-type status_ ~
contract-code BUTTON-contr own-name own-address own-inn own-KPP cli-code ~
cli-type BUTTON-cli cli-name cli-inn cli-KPP cli-address Gruz-otprav ~
Gruz-poluch gtd country pay-date in-date PS plat-ras-doc B-add b-chg B-del ~
BROWSE-1 VAT-10-rubl sum-rubl VAT-20-rubl
&Scoped-Define DISPLAYED-OBJECTS doc-code book-code doc-date ext-doc-type ~
status_ contract-code own-name own-address own-inn own-KPP cli-code ~
cli-type cli-name cli-inn cli-KPP cli-address Gruz-otprav Gruz-poluch gtd ~
country pay-date in-date PS plat-ras-doc VAT-10-rubl sum-rubl VAT-20-rubl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1.

DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1.

DEFINE BUTTON B-sel-contract
     LABEL "До&говор"
     SIZE 10 BY 1 TOOLTIP "Просмотр договора".

DEFINE BUTTON B-sel-docum
     LABEL "Доку&мент"
     SIZE 10 BY 1 TOOLTIP "Просмотр документа-родителя".

DEFINE BUTTON BUTTON-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.

DEFINE BUTTON BUTTON-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.88 BY 1.

DEFINE VARIABLE book-code AS CHARACTER FORMAT "X(14)"
     LABEL "№ в кн."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE cli-address LIKE ub.schet-fact-doc.cli-address
     LABEL "Адрес"
     VIEW-AS FILL-IN
     SIZE 90.63 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE cli-inn LIKE ub.schet-fact-doc.cli-inn
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE cli-KPP AS CHARACTER FORMAT "X(20)"
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE cli-name LIKE ub.schet-fact-doc.cli-name
     VIEW-AS FILL-IN
     SIZE 47 BY 1 NO-UNDO.

DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1.

DEFINE VARIABLE contract-code LIKE ub.schet-fact-doc.contract-code
     LABEL "Договор"
     VIEW-AS FILL-IN
     SIZE 6.5 BY 1 NO-UNDO.

DEFINE VARIABLE country AS CHARACTER FORMAT "X(30)"
     LABEL "Страна "
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE doc-code LIKE ub.schet-fact-doc.doc-code
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE doc-date LIKE ub.schet-fact-doc.doc-date
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE ext-doc-type LIKE ub.schet-fact-doc.ext-doc-type
     LABEL "Тип"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE Gruz-otprav LIKE ub.schet-fact-doc.Gruz-otprav
     VIEW-AS FILL-IN
     SIZE 79.63 BY 1 NO-UNDO.

DEFINE VARIABLE Gruz-poluch LIKE ub.schet-fact-doc.Gruz-poluch
     VIEW-AS FILL-IN
     SIZE 79.63 BY 1 NO-UNDO.

DEFINE VARIABLE gtd LIKE ub.schet-fact-doc.gtd
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE in-date LIKE ub.schet-fact-doc.in-date
     LABEL "Оприход"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 TOOLTIP "Дата оприходывания по документу" NO-UNDO.

DEFINE VARIABLE own-address LIKE ub.schet-fact-doc.own-address
     LABEL "Адрес"
     VIEW-AS FILL-IN
     SIZE 56.63 BY 1 NO-UNDO.

DEFINE VARIABLE own-inn LIKE ub.schet-fact-doc.own-inn
     VIEW-AS FILL-IN
     SIZE 19 BY .92 NO-UNDO.

DEFINE VARIABLE own-KPP AS CHARACTER FORMAT "X(20)"
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE own-name LIKE ub.schet-fact-doc.own-name
     VIEW-AS FILL-IN
     SIZE 26.5 BY 1 NO-UNDO.

DEFINE VARIABLE pay-date LIKE ub.schet-fact-doc.pay-date
     LABEL "Оплата"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 TOOLTIP "Дата оплаты" NO-UNDO.

DEFINE VARIABLE plat-ras-doc LIKE ub.schet-fact-doc.plat-ras-doc
     LABEL "К док-ту №"
     VIEW-AS FILL-IN
     SIZE 23.5 BY 1 TOOLTIP "К пл.-рас. док-ту №" NO-UNDO.

DEFINE VARIABLE PS LIKE ub.schet-fact-doc.PS
     VIEW-AS FILL-IN
     SIZE 85.5 BY 1 NO-UNDO.

DEFINE VARIABLE status_ LIKE ub.schet-fact-doc.status_
     VIEW-AS FILL-IN
     SIZE 7.13 BY 1 NO-UNDO.

DEFINE VARIABLE sum-rubl LIKE ub.schet-fact-doc.sum-rubl
     LABEL "Сумма с НДС"
      VIEW-AS TEXT
     SIZE 21.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE VAT-10-rubl LIKE ub.schet-fact-doc.VAT-10-rubl
     LABEL "НДС 10%"
      VIEW-AS TEXT
     SIZE 18.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE VAT-20-rubl LIKE ub.schet-fact-doc.VAT-20-rubl
     LABEL "НДС 18%"
      VIEW-AS TEXT
     SIZE 18.5 BY .67
     FGCOLOR 1  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      temp-line SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _STRUCTURED
  QUERY BROWSE-1 NO-LOCK DISPLAY
      temp-line.artic COLUMN-LABEL "Артикул" WIDTH 10
      temp-line.gds-name WIDTH 38
      temp-line.unit-base
      temp-line.fact-qnty COLUMN-LABEL "Кол-во"
      temp-line.price-rubl COLUMN-LABEL "Цена" WIDTH 17.5
      temp-line.sum-rubl COLUMN-LABEL "Стоим. без НДС" WIDTH 17
      temp-line.excise WIDTH 7.5
      temp-line.VAT-pc COLUMN-LABEL "% НДС"
      temp-line.VAT-rubl COLUMN-LABEL "Сумма НДС" WIDTH 14
      temp-line.sum-rubl-VAT COLUMN-LABEL "Сумма" WIDTH 20.25
      temp-line.country WIDTH 21.13
      temp-line.gtd WIDTH 18.38
      temp-line.part-code WIDTH 9.38
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 9.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1 COL 1
     b-exit AT ROW 1 COL 11
     b-next AT ROW 1 COL 21
     b-prev AT ROW 1 COL 26
     B-sel-contract AT ROW 1 COL 31 WIDGET-ID 12
     B-sel-docum AT ROW 1 COL 41 WIDGET-ID 14
     b-hist AT ROW 1 COL 80
     B-Help AT ROW 1 COL 90
     doc-code AT ROW 2 COL 7 COLON-ALIGNED HELP
          ""
     book-code AT ROW 2 COL 26.38 COLON-ALIGNED WIDGET-ID 2
     doc-date AT ROW 2 COL 43.75 COLON-ALIGNED HELP
          "" FORMAT "99/99/9999"
     ext-doc-type AT ROW 2 COL 60.13 COLON-ALIGNED HELP
          ""
          LABEL "Тип"
     status_ AT ROW 2 COL 72.38 COLON-ALIGNED HELP
          ""
     contract-code AT ROW 2 COL 88.88 COLON-ALIGNED HELP
          ""
          LABEL "Договор" FORMAT ">>>>>>>>9"
     BUTTON-contr AT ROW 2 COL 97.5 WIDGET-ID 10
     own-name AT ROW 3.04 COL 7 COLON-ALIGNED HELP
          "" NO-LABEL
     own-address AT ROW 3.04 COL 36.5 HELP
          ""
          LABEL "Адрес"
     own-inn AT ROW 4.08 COL 11.5 COLON-ALIGNED HELP
          ""
     own-KPP AT ROW 4.08 COL 41.5 COLON-ALIGNED WIDGET-ID 18
     cli-code AT ROW 5.04 COL 11.5 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     cli-type AT ROW 5.04 COL 17.88 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     BUTTON-cli AT ROW 5.04 COL 24.88 WIDGET-ID 4
     cli-name AT ROW 5.04 COL 26.5 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "X(47)"
     cli-inn AT ROW 6.08 COL 11.5 COLON-ALIGNED HELP
          ""
     cli-KPP AT ROW 6.08 COL 41.5 COLON-ALIGNED WIDGET-ID 20
     cli-address AT ROW 7.08 COL 2.5 HELP
          ""
          LABEL "Адрес"
     Gruz-otprav AT ROW 8.13 COL 2.5 HELP
          ""
     Gruz-poluch AT ROW 9.17 COL 3.5 HELP
          ""
     gtd AT ROW 10.21 COL 4.38 COLON-ALIGNED HELP
          ""
     country AT ROW 10.25 COL 40 COLON-ALIGNED
     pay-date AT ROW 10.25 COL 68.5 COLON-ALIGNED HELP
          ""
          LABEL "Оплата" FORMAT "99/99/99"
     in-date AT ROW 10.25 COL 86.88 COLON-ALIGNED HELP
          ""
          LABEL "Оприход"
     PS AT ROW 11.25 COL 2 HELP
          "" FORMAT "X(255)"
     plat-ras-doc AT ROW 12.25 COL 12 COLON-ALIGNED HELP
          ""
          LABEL "К док-ту №"
     B-add AT ROW 13.42 COL 1
     b-chg AT ROW 13.42 COL 11
     B-del AT ROW 13.42 COL 21
     BROWSE-1 AT ROW 14.5 COL 1
     VAT-10-rubl AT ROW 12.58 COL 79 COLON-ALIGNED HELP
          ""
          LABEL "НДС 10%"
          FGCOLOR 1
     sum-rubl AT ROW 12.63 COL 48.75 COLON-ALIGNED HELP
          ""
          LABEL "Сумма с НДС"
          FGCOLOR 4
     VAT-20-rubl AT ROW 13.42 COL 79 COLON-ALIGNED HELP
          ""
          LABEL "НДС 18%"
          FGCOLOR 1
     "Контрагент:" VIEW-AS TEXT
          SIZE 11.5 BY .67 AT ROW 5.17 COL 1.5
          FGCOLOR 4
     "Фирма:" VIEW-AS TEXT
          SIZE 7.25 BY .67 AT ROW 3.25 COL 1.5
          FGCOLOR 4
     SPACE(91.63) SKIP(20.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Cчет-фактура".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1 B-del Dialog-Frame */
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

/* SETTINGS FOR FILL-IN cli-address IN FRAME Dialog-Frame
   ALIGN-L LIKE = ub.schet-fact-doc. EXP-LABEL EXP-SIZE                 */
/* SETTINGS FOR FILL-IN cli-inn IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-SIZE                                   */
/* SETTINGS FOR FILL-IN cli-name IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-LABEL EXP-FORMAT                       */
/* SETTINGS FOR FILL-IN contract-code IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-LABEL EXP-FORMAT EXP-SIZE              */
/* SETTINGS FOR FILL-IN doc-code IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-HELP EXP-SIZE                          */
/* SETTINGS FOR FILL-IN doc-date IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-FORMAT EXP-SIZE                        */
/* SETTINGS FOR FILL-IN ext-doc-type IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-LABEL EXP-HELP EXP-SIZE                */
/* SETTINGS FOR FILL-IN Gruz-otprav IN FRAME Dialog-Frame
   ALIGN-L LIKE = ub.schet-fact-doc. EXP-HELP EXP-SIZE                  */
/* SETTINGS FOR FILL-IN Gruz-poluch IN FRAME Dialog-Frame
   ALIGN-L LIKE = ub.schet-fact-doc. EXP-SIZE                           */
/* SETTINGS FOR FILL-IN gtd IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-SIZE                                   */
/* SETTINGS FOR FILL-IN in-date IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-LABEL EXP-SIZE                         */
/* SETTINGS FOR FILL-IN own-address IN FRAME Dialog-Frame
   ALIGN-L LIKE = ub.schet-fact-doc. EXP-LABEL EXP-SIZE                 */
/* SETTINGS FOR FILL-IN own-inn IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-SIZE                                   */
/* SETTINGS FOR FILL-IN own-name IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-SIZE                                   */
/* SETTINGS FOR FILL-IN pay-date IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE     */
/* SETTINGS FOR FILL-IN plat-ras-doc IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-LABEL EXP-SIZE                         */
/* SETTINGS FOR FILL-IN PS IN FRAME Dialog-Frame
   ALIGN-L LIKE = ub.schet-fact-doc. EXP-FORMAT                         */
/* SETTINGS FOR FILL-IN status_ IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-SIZE                                   */
/* SETTINGS FOR FILL-IN sum-rubl IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-LABEL EXP-SIZE                         */
/* SETTINGS FOR FILL-IN VAT-10-rubl IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-LABEL EXP-SIZE                         */
/* SETTINGS FOR FILL-IN VAT-20-rubl IN FRAME Dialog-Frame
   LIKE = ub.schet-fact-doc. EXP-LABEL EXP-SIZE                         */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _TblList          = "temp-line WHERE temp-line ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"temp-line.artic" "Артикул" ? "character" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"temp-line.gds-name" ? ? "character" ? ? ? ? ? ? no ? no no "38" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"temp-line.unit-base" ? ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"temp-line.fact-qnty" "Кол-во" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"temp-line.price-rubl" "Цена" ? "decimal" ? ? ? ? ? ? no ? no no "17.5" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"temp-line.sum-rubl" "Стоим. без НДС" ? "decimal" ? ? ? ? ? ? no ? no no "17" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > "_<CALC>"
"temp-line.excise" ? ? "decimal" ? ? ? ? ? ? no ? no no "7.5" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"temp-line.VAT-pc" "% НДС" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > "_<CALC>"
"temp-line.VAT-rubl" "Сумма НДС" ? "decimal" ? ? ? ? ? ? no ? no no "14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > "_<CALC>"
"temp-line.sum-rubl-VAT" "Сумма" ? "decimal" ? ? ? ? ? ? no ? no no "20.25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > "_<CALC>"
"temp-line.country" ? ? "character" ? ? ? ? ? ? no ? no no "21.13" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > "_<CALC>"
"temp-line.gtd" ? ? "character" ? ? ? ? ? ? no ? no no "18.38" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > "_<CALC>"
"temp-line.part-code" ? ? "character" ? ? ? ? ? ? no ? no no "9.38" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Cчет-фактура */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable gds-name   as character no-undo .
define variable unit-base  as character no-undo .
define variable fact-qnty  as decimal   no-undo .
define variable price-rubl as decimal   no-undo .
define variable sum-rubl1  as decimal   no-undo .
define variable excise     as decimal   no-undo .
define variable VAT-pc     as decimal   no-undo .
define variable VAT-rubl   as decimal   no-undo .
define variable sum-rubl-VAT as decimal   no-undo .
define variable country1   as character no-undo .
define variable gtd1       as character no-undo .
  assign gtd country .
  assign
    country1 = country
    gtd1     = gtd
  .

  assign res = no .
  run str/s-f-line.w
      ( input parParentProc,
        input-output gds-name, input-output unit-base, input-output fact-qnty, input-output price-rubl,
        input-output sum-rubl1, input-output excise,    input-output VAT-pc,    input-output VAT-rubl,
        input-output sum-rubl-VAT, input-output country1,   input-output gtd1 ,  input-output res) .
  if res then do:
    create temp-line .
    assign
      temp-line.db-num        = p-db-num
      temp-line.gds-name      = gds-name
      temp-line.unit-base     = unit-base
      temp-line.fact-qnty     = fact-qnty
      temp-line.price-rubl    = price-rubl
      temp-line.sum-rubl      = sum-rubl1
      temp-line.excise        = excise
      temp-line.VAT-pc        = VAT-pc
      temp-line.VAT-rubl      = VAT-rubl
      temp-line.sum-rubl-VAT  = sum-rubl-VAT
      temp-line.country       = country1
      temp-line.gtd           = gtd1
      temp-line.artic         = ""
      temp-line.edit          = yes
    .
    if gtd = "" or gtd = ?  then assign gtd = gtd1 .
    if country = "" then assign country = country1 .

    run proc-calc .

    DISPLAY VAT-10-rubl VAT-20-rubl  sum-rubl gtd country  WITH FRAME Dialog-Frame.
    OPEN QUERY BROWSE-1 FOR EACH temp-line INDEXED-REPOSITION.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not available temp-line then return no-apply.
define variable gds-name   as character no-undo .
define variable unit-base  as character no-undo .
define variable fact-qnty  as decimal   no-undo .
define variable price-rubl as decimal   no-undo .
define variable sum-rubl1  as decimal   no-undo .
define variable excise     as decimal   no-undo .
define variable VAT-pc     as decimal   no-undo .
define variable VAT-rubl   as decimal   no-undo .
define variable sum-rubl-VAT as decimal   no-undo .
define variable country1   as character no-undo .
define variable gtd1       as character no-undo .
    assign
      gds-name      = temp-line.gds-name
      unit-base     = temp-line.unit-base
      fact-qnty     = temp-line.fact-qnty
      price-rubl    = temp-line.price-rubl
      sum-rubl1     = temp-line.sum-rubl
      excise        = temp-line.excise
      VAT-pc        = temp-line.VAT-pc
      VAT-rubl      = temp-line.VAT-rubl
      sum-rubl-VAT  = temp-line.sum-rubl-VAT
      country1      = temp-line.country
      gtd1          = temp-line.gtd
   .

  assign res = no .
  run str/s-f-line.w
    ( input parParentProc,
      input-output gds-name, input-output unit-base, input-output fact-qnty, input-output price-rubl,
      input-output sum-rubl1, input-output excise,    input-output VAT-pc,    input-output VAT-rubl,
      input-output sum-rubl-VAT, input-output country1,   input-output gtd1 ,  input-output res) .
  if res then do:
    assign
      temp-line.gds-name      = gds-name
      temp-line.unit-base     = unit-base
      temp-line.fact-qnty     = fact-qnty
      temp-line.price-rubl    = price-rubl
      temp-line.sum-rubl      = sum-rubl1
      temp-line.excise        = excise
      temp-line.VAT-pc        = VAT-pc
      temp-line.VAT-rubl      = VAT-rubl
      temp-line.sum-rubl-VAT  = sum-rubl-VAT
      temp-line.country       = country1
      temp-line.gtd           = gtd1
      temp-line.artic         = ""
      temp-line.edit          = yes
    .
    run proc-calc .

    if gtd = "" then assign gtd = gtd1 .
    if country = "" then assign country = country1 .

    OPEN QUERY BROWSE-1 FOR EACH temp-line INDEXED-REPOSITION.
    DISPLAY VAT-10-rubl VAT-20-rubl  sum-rubl gtd country  WITH FRAME Dialog-Frame.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  if not avail temp-line then return no-apply.
  DISPLAY VAT-10-rubl VAT-20-rubl  sum-rubl   WITH FRAME Dialog-Frame.
  delete temp-line .
  run proc-calc .
  DISPLAY VAT-10-rubl VAT-20-rubl  sum-rubl  WITH FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH temp-line INDEXED-REPOSITION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Отмена */
DO:  /* отказ - выход  */
  /*next-prev = ?.*/
  if ref-mode = {&update} or ref-mode = {&add-def} then do:
    message "Отменить сделанные изменения?"  view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  run str/s-f-hist.w (input parparentproc, input p-host-code, p-doc-code) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
/*  run step-next.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK Dialog-Frame
ON CHOOSE OF b-OK IN FRAME Dialog-Frame /* Ввод  */
DO:
/*    next-prev = ?.*/
  if ref-mode = {&update} or ref-mode = {&add-def} then do:
    { gbl/stdbtn.i }
    assign contract-code doc-code book-code  doc-date  own-name  own-inn  own-address  cli-code  cli-type  cli-name  cli-address
           cli-inn ext-doc-type  status_ Gruz-otprav Gruz-poluch  gtd  /*user-name*/  country /*fact-user-name*/ plat-ras-doc
           pay-date  in-date         PS  own-kpp cli-kpp .

    find first temp-line no-error .
    if not available temp-line then do:
      message  "Нет товарных строк!"   view-as alert-box.
      return no-apply .
    end.

    if doc-date > pay-date then do:
      message  "Дата оплаты " pay-date " меньше даты создания "  doc-date "!"   view-as alert-box.
      return no-apply .
    end.
    define variable str as character init "" no-undo .
    /* проверяем данные клиента и фирмы */
    find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error .
    if error-status :error then do:
       message "Не верно задан Контрагент"  view-as alert-box information .
       return no-apply .
    end.
    if cli-name <> buf_clients.obj-name then assign str = str + "наименование контрагента в с-ф " + cli-name + " не совпадает с наименованием в справочнике " + buf_clients.obj-name + {&new-line} .

    if buf_clients.obj-type = {&cmp} then do:
      find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code .
      if cli-inn <> buf_firm.inn then assign str = str + "{&abbr_inn_allshift} контрагента в с-ф " + cli-inn + " не совпадает с {&abbr_inn_allshift} в справочнике " + buf_firm.inn + {&new-line} .
      if cli-kpp <> buf_firm.kpp then assign str = str + "{&abbr_kpp_allshift} контрагента в с-ф " + cli-kpp + " не совпадает с {&abbr_kpp_allshift} в справочнике " + buf_firm.kpp + {&new-line} .
      if cli-address <> (trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)) then assign str = str + "адрес контрагента в с-ф " + cli-address + " не совпадает с адресом в справочнике " + (trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)) + {&new-line} .
    end.
    else do:
      find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
      if cli-address <> buf_person.address then assign str = str + "адрес контрагента в с-ф " + cli-address + " не совпадает с адресом в справочнике " + buf_person.address + {&new-line} .
    end.
    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = p-host-code .
    if own-name <> buf_clients.obj-name then assign str = str + "наименование фирмы в с-ф " + own-name + " не совпадает с наименованием в справочнике " + buf_clients.obj-name + {&new-line} .
    find first buf_firm no-lock where buf_firm.firm-code = p-host-code .
    if own-inn <> buf_firm.inn then assign str = str + "{&abbr_inn_allshift} фирмы в с-ф " + own-inn + " не совпадает с {&abbr_inn_allshift} в справочнике " + buf_firm.inn + {&new-line} .
    if own-kpp <> buf_firm.kpp then assign str = str + "{&abbr_kpp_allshift} фирмы в с-ф " + own-inn + " не совпадает с {&abbr_kpp_allshift} в справочнике " + buf_firm.kpp + {&new-line} .
    if own-address <> (trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)) then assign str = str + "адрес фирмы в с-ф " + own-address + " не совпадает с адресом в справочнике " + (trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)) + {&new-line} .
    if str <> "" then do:
      message str "Продолжить?"  view-as alert-box QUESTION BUTTONS YES-NO update g-log .
      if g-log = no then return no-apply.
    end.
    /* Проверить суммы */
    define variable v-sum-all as decimal   no-undo init 0.
    define variable v-sum-all-vat as decimal   no-undo init 0.
    for each  temp-line :
       v-sum-all = v-sum-all + temp-line.sum-rubl-VAT.
       v-sum-all-vat = v-sum-all-vat + temp-line.vat-rubl.
    end.
    if v-sum-all <> sum-rubl then do:
       message "Не верно введены суммы" skip v-sum-all skip  sum-rubl view-as alert-box information .
       return no-apply .
    end.
    if v-sum-all-vat  <> (VAT-10-rubl + VAT-20-rubl) then do:
       message "Не верно введены суммы НДС" skip 'по строкам ' v-sum-all-vat skip  VAT-10-rubl VAT-20-rubl view-as alert-box information .
       return no-apply .
    end.


    if ref-mode = {&add-def} then do:
      if book-code <> "" and book-code <> ? then do:
        find first ub.schet-fact-doc no-lock where ub.schet-fact-doc.host-code = p-host-code and ub.schet-fact-doc.book-code = book-code no-error .
        if available ub.schet-fact-doc and year(ub.schet-fact-doc.doc-date) = year(doc-date) then do:
          message substitute("Уже есть счет-фактура с таким № &2 в книге продаж за &1 год ." , year(doc-date) , book-code ) view-as alert-box.
          return no-apply .
        end.
      end.
      create buf_schet-fact-doc .
      { gbl/curdburt.i  buf_schet-fact-doc.user-db-num  buf_schet-fact-doc.user-name  buf_schet-fact-doc.sys-date  p-sys-time  buf_schet-fact-doc.sys-time }
      assign
        buf_schet-fact-doc.doc-code           = string(next-value(s-sf-doc, {&db-name_schema}))
        buf_schet-fact-doc.db-num             = v-cntxt-db-num
        buf_schet-fact-doc.status_            = {&fin-new}
        buf_schet-fact-doc.ext-doc-type       = ""
        buf_schet-fact-doc.host-code          = p-host-code
        buf_schet-fact-doc.contract-code      = contract-code
        buf_schet-fact-doc.doc-date           = doc-date
        buf_schet-fact-doc.cli-code           = cli-code
        buf_schet-fact-doc.cli-type           = cli-type
        buf_schet-fact-doc.obj-code           = v-cntxt-obj-code
        buf_schet-fact-doc.obj-type           = v-cntxt-obj-type
        buf_schet-fact-doc.sum-rubl           = sum-rubl
        buf_schet-fact-doc.VAT-10-rubl        = VAT-10-rubl
        buf_schet-fact-doc.VAT-20-rubl        = VAT-20-rubl
        buf_schet-fact-doc.office             = yes
      .
      ii = 0.
      for each temp-line :
         ii = ii + 1 .
        create ub.schet-fact-line .
        buffer-copy temp-line  to ub.schet-fact-line
        assign
          ub.schet-fact-line.line-num      = ii
          ub.schet-fact-line.doc-code      = buf_schet-fact-doc.doc-code
          ub.schet-fact-line.db-num        = buf_schet-fact-doc.user-db-num
          ub.schet-fact-line.gds-code      = ?
          ub.schet-fact-line.type          = {&fin-new}
          ub.schet-fact-line.ext-doc-type  = buf_schet-fact-doc.ext-doc-type
          ub.schet-fact-line.fact-order    = buf_schet-fact-doc.fact-order
          ub.schet-fact-line.status_       = buf_schet-fact-doc.status_
          ub.schet-fact-line.obj-code      = v-cntxt-obj-code
          ub.schet-fact-line.obj-type      = v-cntxt-obj-type
          ub.schet-fact-line.host-code     = p-host-code
          ub.schet-fact-line.in-code       = ""
          ub.schet-fact-line.other-base    = 0
          ub.schet-fact-line.other-rubl    = 0
        .
      end.
    end.
    else do:
      if book-code <> "" and book-code <> ? then do:
        find first ub.schet-fact-doc no-lock
          where ub.schet-fact-doc.host-code = p-host-code
            and ub.schet-fact-doc.book-code = book-code
        no-error .
        if available ub.schet-fact-doc and ub.schet-fact-doc.doc-code <> p-doc-code and year(ub.schet-fact-doc.doc-date) = year(doc-date) then do:
          message substitute("Уже есть счет-фактура с таким № &1 в книге продаж за &2 год .", p-doc-code , year(doc-date)) view-as alert-box.
          return no-apply .
        end.
      end.
      find first buf_schet-fact-doc exclusive-lock where buf_schet-fact-doc.doc-code = p-doc-code and buf_schet-fact-doc.db-num = p-db-num no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      if  B-add:visible = yes then do:
        assign
          buf_schet-fact-doc.contract-code   = contract-code
          buf_schet-fact-doc.doc-type        = {&income}
          buf_schet-fact-doc.VAT-20-rubl     = VAT-20-rubl
          buf_schet-fact-doc.sum-rubl        = sum-rubl
          buf_schet-fact-doc.VAT-10-rubl     = VAT-10-rubl
          buf_schet-fact-doc.sum-VAT-no-rubl = s-no-VAT
          buf_schet-fact-doc.sum-VAT-0-rubl  = s-0-VAT
          buf_schet-fact-doc.sum-VAT-10-rubl = s-10-VAT
          buf_schet-fact-doc.sum-VAT-20-rubl = s-20-VAT
          buf_schet-fact-doc.office     = yes
        .
        for each ub.schet-fact-line exclusive-lock where ub.schet-fact-line.doc-code = p-doc-code and ub.schet-fact-line.db-num = buf_schet-fact-doc.db-num :
          delete ub.schet-fact-line .
        end.
        ii = 0 .
        for each temp-line :
          ii = ii + 1.
          create ub.schet-fact-line .
          buffer-copy temp-line to ub.schet-fact-line
          assign
            ub.schet-fact-line.line-num      = ii
            ub.schet-fact-line.type          = {&fin-new}
            ub.schet-fact-line.doc-code      = buf_schet-fact-doc.doc-code
            ub.schet-fact-line.gds-code      = ?
            ub.schet-fact-line.ext-doc-type  = buf_schet-fact-doc.ext-doc-type
            ub.schet-fact-line.fact-order    = buf_schet-fact-doc.fact-order
            ub.schet-fact-line.status_       = buf_schet-fact-doc.status_
            ub.schet-fact-line.host-code     = p-host-code
            ub.schet-fact-line.obj-code      = v-cntxt-obj-code
            ub.schet-fact-line.obj-type      = v-cntxt-obj-type
            ub.schet-fact-line.in-code       = ""
            ub.schet-fact-line.other-base    = 0
            ub.schet-fact-line.other-rubl    = 0
          .
        end.
      end.
    end.
    assign
      buf_schet-fact-doc.book-code      =     book-code
      buf_schet-fact-doc.own-name       =     own-name
      buf_schet-fact-doc.own-inn        =     own-inn
      buf_schet-fact-doc.own-kpp        =     own-kpp
      buf_schet-fact-doc.own-address    =     own-address
      buf_schet-fact-doc.cli-name       =     cli-name
      buf_schet-fact-doc.cli-address    =     cli-address
      buf_schet-fact-doc.cli-inn        =     cli-inn
      buf_schet-fact-doc.cli-kpp        =     cli-kpp
      buf_schet-fact-doc.Gruz-otprav    =     Gruz-otprav
      buf_schet-fact-doc.Gruz-poluch    =     Gruz-poluch
      buf_schet-fact-doc.gtd            =     gtd
      buf_schet-fact-doc.country        =     country
      buf_schet-fact-doc.plat-ras-doc   =     plat-ras-doc
      buf_schet-fact-doc.pay-date       =     pay-date
      buf_schet-fact-doc.in-date        =     in-date
      buf_schet-fact-doc.PS             =     PS
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
/*   run step-prev.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel-contract Dialog-Frame
ON CHOOSE OF B-sel-contract IN FRAME Dialog-Frame /* Договор */
DO:
assign
  contract-code
.
  if contract-code = 0 or contract-code = ? then do:
  end.

define variable ri as recid no-undo .
define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = contract-code and
                                     b_contract.host-code         = p-host-code
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


&Scoped-define SELF-NAME B-sel-docum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel-docum Dialog-Frame
ON CHOOSE OF B-sel-docum IN FRAME Dialog-Frame /* Документ */
DO:
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_fin-ob  for ub.fin-ob  .
define buffer buf_add-doc for ub.add-doc  .

define variable v-r as recid no-undo .

  if buf_schet-fact-doc.in-doc-code = "" and buf_schet-fact-doc.in-doc-code = ? then do:
     return no-apply .
  end.

  case buf_schet-fact-doc.in-doc-type :
    when 'fo' then do:
        find first buf_fin-ob no-lock where buf_fin-ob.doc-code =  buf_schet-fact-doc.in-doc-code and
                                          buf_fin-ob.host-code = p-host-code no-error .
        if available buf_fin-ob then do:
            run str/sh-finob.p ( input parParentProc, input v-cntxt-host-code-obj, input recid(buf_fin-ob)).
        end.
    end.
    when 'fd' then do:
       run ref/showfind.p
        (  input parparentproc
          ,input v-cntxt-host-code-obj
          ,input p-host-code
          ,input buf_schet-fact-doc.in-doc-code)
          .
    end.
    when 'td' then do:
      find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = buf_schet-fact-doc.in-doc-code no-error .
      if available buf_trn-doc then
          run str/fishdoc.p
            (  parparentproc,
              buf_trn-doc.host-code ,
              buf_trn-doc.obj-type,
              buf_trn-doc.obj-code,
              buf_trn-doc.doc-code ,
              ? ) .
    end.

    when  {&SFEDT_add_doc} then do:
      find first buf_add-doc no-lock  where buf_add-doc.doc-code = buf_schet-fact-doc.in-doc-code no-error .
      if available buf_add-doc then
          v-r = recid(buf_add-doc) .
          run str/add-docu.w ( input parparentproc  ,
                               input-output v-r ,
                               input {&lookup}  ,
                               input ?
                               ).
    end.
   end case .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-cli Dialog-Frame
ON CHOOSE OF BUTTON-cli IN FRAME Dialog-Frame /* 2 */
DO:
  define variable agnt-list as character no-undo .
  run ref/cli-all.w (parParentProc, "b-sel", {&all}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (agnt-list) no-error.
    if buf_clients.obj-type <> {&prs} and buf_clients.obj-type <> {&cmp} then do:
      message
        "Контрагент может быть только " {&cmp} " или " {&prs}
        view-as alert-box ERROR .
      return no-apply.
    end.
    assign
      cli-name = buf_clients.obj-name
      cli-code = buf_clients.obj-code
      cli-type = buf_clients.obj-type
    .
    if buf_clients.obj-type = {&cmp} then do:
      find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
      if available buf_firm then
         assign
           cli-kpp = buf_firm.kpp
           cli-inn = buf_firm.inn
           cli-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)
         .
    end.
    else do:
      find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
      if available buf_person then assign  cli-address = buf_person.address   cli-inn = ""  cli-kpp = "".
    end.
  end.
  else assign cli-name = ""  cli-inn = "" cli-kpp = ""  cli-address = ""  cli-code = ?  cli-type  = ? .
  display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-contr Dialog-Frame
ON CHOOSE OF BUTTON-contr IN FRAME Dialog-Frame
DO:
  if ( ref-mode = {&update} and buf_schet-fact-doc.office = yes ) or ref-mode = {&add-def} then do:
    define variable cont-list as character no-undo .
    find first buf_contract no-lock where buf_contract.contract-code = contract-code and buf_contract.host-code = p-host-code no-error .
    if available buf_contract then assign cont-list = string(recid(buf_contract)) .
    /* показываем список */
    run str/cont-all.w ( parParentProc, p-host-code, "b-sel", {&company}, ?, ?, ?, ?, "current":U, {&income}, input-output cont-list ) .
    if cont-list = "" then do:
      assign  contract-code = ? .
    end.
    else do:
      define variable ii as integer   no-undo .
      do ii = 1 to num-entries (cont-list):
        find first ub.contract no-lock where recid(ub.contract) = integer (entry (ii, cont-list)) .
        assign contract-code = ub.contract.contract-code .
      end.
    end.
    display contract-code with frame {&frame-name}.
  end.
  else do:
    find first buf_contract no-lock where buf_contract.contract-code = contract-code and buf_contract.host-code = p-host-code no-error .
    if not avail buf_contract then return no-apply.
    { gbl/chk-actg.i p-db-num v-cntxt-userid {&action-head-code-main} 'actn_fin-contract_lookup':U {&cntxt-firm} p-host-code '':U 0 0 0 0 true g-log }
    if not g-log then return no-apply .
    define variable ri as recid     no-undo .
    assign ri = recid( buf_contract ) .
    run str/contr.w ( input parParentProc,input p-host-code, input {&lookup}, input {&income}, input-output ri)/* no-error*/.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code Dialog-Frame
ON LEAVE OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  if cli-type <> {&cmp} and cli-type <> {&prs} then do:
    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = cli-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.

  if not available buf_clients then do:
    if cli-code = 0 then assign cli-code = ? .
    if cli-code = ? then do:
      assign cli-name = ""  cli-inn = ""  cli-kpp = "" cli-address = ""  cli-code = ?  cli-type  = ? .
      display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address   with frame {&frame-name}.
    end.
    else do:
      apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign
    cli-name = buf_clients.obj-name
    cli-code = buf_clients.obj-code
    cli-type = buf_clients.obj-type
  .
  if buf_clients.obj-type = {&cmp} then do:
    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
    if available buf_firm then
       assign
         cli-kpp = buf_firm.kpp
         cli-inn = buf_firm.inn
         cli-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)
      .
  end.
  else do:
    find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
    if available buf_person then assign  cli-address = buf_person.address   cli-inn = "" cli-kpp = "".
  end.
  display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address   with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code Dialog-Frame
ON RETURN OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  if cli-type <> {&cmp} and cli-type <> {&prs} then do:
    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = cli-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.

  if not available buf_clients then do:
    if cli-code = 0 then assign cli-code = ? .
    if cli-code = ? then do:
      assign cli-name = ""  cli-inn = "" cli-kpp = "" cli-address = ""  cli-code = ?  cli-type  = ? .
      display cli-name    cli-code     cli-type  cli-inn  cli-kpp  cli-address   with frame {&frame-name}.
    end.
    else do:
      apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign
    cli-name = buf_clients.obj-name
    cli-code = buf_clients.obj-code
    cli-type = buf_clients.obj-type
  .
  if buf_clients.obj-type = {&cmp} then do:
    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
    if available buf_firm then
     assign
       cli-kpp = buf_firm.kpp
       cli-inn = buf_firm.inn
       cli-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)
       .
  end.
  else do:
    find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
    if available buf_person then assign  cli-address = buf_person.address   cli-inn = ""  cli-kpp = "".
  end.
  display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address   with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-type Dialog-Frame
ON LEAVE OF cli-type IN FRAME Dialog-Frame
DO:
  assign cli-type.
  if cli-type <> {&cmp} and cli-type <> {&prs} then do:
    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = cli-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.

  if not available buf_clients then do:
    if cli-code = 0 then assign cli-code = ? .
    if cli-code = ? then do:
      assign cli-name = ""  cli-inn = "" cli-kpp = ""  cli-address = ""  cli-code = ?  cli-type  = ? .
      display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address   with frame {&frame-name}.
    end.
    else do:
      apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign
    cli-name = buf_clients.obj-name
    cli-code = buf_clients.obj-code
    cli-type = buf_clients.obj-type
  .
  if buf_clients.obj-type = {&cmp} then do:
    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
    if available buf_firm then
      assign
       cli-kpp = buf_firm.kpp
       cli-inn = buf_firm.inn
       cli-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)   .
  end.
  else do:
    find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
    if available buf_person then assign  cli-address = buf_person.address   cli-inn = "" cli-kpp = "".
  end.
  display cli-name    cli-code     cli-type  cli-inn  cli-kpp cli-address   with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/app_help.i }
  { gbl/ed_date.i doc-date }
  { gbl/ed_date.i in-date }
  { gbl/ed_date.i pay-date }
  { gbl/getcntxt.i get }
  temp-line.gds-name:resizable in browse {&browse-name}   = true .
  own-kpp:label = "{&abbr_kpp_allshift}" .
  cli-kpp:label = "{&abbr_kpp_allshift}" .
  run enable_ui .
  run go-proc no-error.
  if error-status:error then return no-apply.

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
  DISPLAY doc-code book-code doc-date ext-doc-type status_ contract-code
          own-name own-address own-inn own-KPP cli-code cli-type cli-name
          cli-inn cli-KPP cli-address Gruz-otprav Gruz-poluch gtd country
          pay-date in-date PS plat-ras-doc VAT-10-rubl sum-rubl VAT-20-rubl
      WITH FRAME Dialog-Frame.
  ENABLE b-OK b-exit B-sel-contract B-sel-docum b-hist B-Help doc-code
         book-code doc-date ext-doc-type status_ contract-code BUTTON-contr
         own-name own-address own-inn own-KPP cli-code cli-type BUTTON-cli
         cli-name cli-inn cli-KPP cli-address Gruz-otprav Gruz-poluch gtd
         country pay-date in-date PS plat-ras-doc B-add b-chg B-del BROWSE-1
         VAT-10-rubl sum-rubl VAT-20-rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE go-proc Dialog-Frame
PROCEDURE go-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
on stop undo, return error
:
  case ref-mode :
    when {&add-def} then do:
      assign frame {&frame-name}:title =  "Новый счет-фактура  БД " + string(p-db-num) + "  Фирма: (" + string(p-host-code) + ")":U + " опер. " + usrfulnf(v-cntxt-userid) .
      find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = p-host-code no-error .
      find first buf_firm no-lock where buf_firm.firm-code = p-host-code no-error .

      assign
        own-name    = buf_clients.obj-name
        own-inn     = buf_firm.inn
        own-kpp     = buf_firm.kpp
        own-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)
        Gruz-otprav = "он же"
        Gruz-poluch   = substitute( "&1 &2 &3", caps( own-name ),  buf_firm.post-addr1 )
      .
      DISABLE  doc-code ext-doc-type status_ contract-code /*user-name fact-user-name*/
       b-sel-contract b-sel-docum
      WITH FRAME Dialog-Frame.
    end.

    when {&update} or when {&lookup} then do:
      find first buf_schet-fact-doc no-lock where buf_schet-fact-doc.doc-code = p-doc-code and  buf_schet-fact-doc.db-num = p-db-num no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      assign frame {&frame-name}:title =  "Счет-фактура № " + string(buf_schet-fact-doc.doc-code) + "  БД " + string(buf_schet-fact-doc.db-num) + "  Фирма: (" + string(buf_schet-fact-doc.host-code) + ")":U .

      if buf_schet-fact-doc.ext-doc-type <> "" then
        assign frame {&frame-name}:title = frame {&frame-name}:title + " создан по " + buf_schet-fact-doc.ext-doc-type + " " + buf_schet-fact-doc.in-doc-code + " от " + string(buf_schet-fact-doc.in-doc-date,"99/99/9999") .

      for each ub.schet-fact-line no-lock
        where ub.schet-fact-line.doc-code  = p-doc-code
          and ub.schet-fact-line.db-num = p-db-num
        :
        find first buf_goods no-lock where buf_goods.gds-code = ub.schet-fact-line.gds-code no-error .
        create temp-line .
        buffer-copy ub.schet-fact-line to temp-line
        assign
          temp-line.artic = if available buf_goods then buf_goods.artic else ""
        .
      end.

      assign
        contract-code     = buf_schet-fact-doc.contract-code
        doc-code          = buf_schet-fact-doc.doc-code
        book-code         = buf_schet-fact-doc.book-code
        doc-date          = buf_schet-fact-doc.doc-date
        own-name          = buf_schet-fact-doc.own-name
        own-inn           = buf_schet-fact-doc.own-inn
        own-kpp           = buf_schet-fact-doc.own-kpp
        own-address       = buf_schet-fact-doc.own-address
        cli-code          = buf_schet-fact-doc.cli-code
        cli-type          = buf_schet-fact-doc.cli-type
        cli-name          = buf_schet-fact-doc.cli-name
        cli-address       = buf_schet-fact-doc.cli-address
        cli-inn           = buf_schet-fact-doc.cli-inn
        cli-kpp           = buf_schet-fact-doc.cli-kpp
        ext-doc-type      = buf_schet-fact-doc.ext-doc-type
        status_           = buf_schet-fact-doc.status_
        Gruz-otprav       = buf_schet-fact-doc.Gruz-otprav
        Gruz-poluch       = buf_schet-fact-doc.Gruz-poluch
        gtd               = buf_schet-fact-doc.gtd
        country           = buf_schet-fact-doc.country
        plat-ras-doc      = buf_schet-fact-doc.plat-ras-doc
        pay-date          = buf_schet-fact-doc.pay-date
        in-date           = buf_schet-fact-doc.in-date
        VAT-20-rubl       = buf_schet-fact-doc.VAT-20-rubl
        sum-rubl          = buf_schet-fact-doc.sum-rubl
        VAT-10-rubl       = buf_schet-fact-doc.VAT-10-rubl
        PS                = buf_schet-fact-doc.PS
        s-no-VAT          = buf_schet-fact-doc.sum-VAT-no-rubl
        s-0-VAT           = buf_schet-fact-doc.sum-VAT-0-rubl
        s-10-VAT          = buf_schet-fact-doc.sum-VAT-10-rubl
        s-20-VAT          = buf_schet-fact-doc.sum-VAT-20-rubl
      .
      if ref-mode = {&lookup} then do:
        b-OK:label in frame {&frame-name} = "&Выход" .
        b-exit:visible = no .
        B-add:visible = no .
        b-chg:visible = no .
        B-del:visible = no .
        DISABLE  doc-code book-code doc-date ext-doc-type status_ contract-code own-name own-inn own-kpp own-address cli-code cli-type
           cli-name cli-inn cli-kpp cli-address Gruz-otprav Gruz-poluch gtd country /*user-name fact-user-name*/ plat-ras-doc
           pay-date in-date PS sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli BUTTON-contr
        WITH FRAME Dialog-Frame.
      end.

      else do:
        if buf_schet-fact-doc.office = no then do:
          B-add:visible = no .
          b-chg:visible = no .
          B-del:visible = no .
        end.
        if contract-code > 0 then DISABLE BUTTON-contr WITH FRAME Dialog-Frame.
        if v-cntxt-db-num = 0 and buf_schet-fact-doc.db-num > 0 then do:
          B-add:visible = no .
          b-chg:visible = no .
          B-del:visible = no .
          DISABLE  doc-code doc-date ext-doc-type status_ contract-code own-name own-inn own-kpp own-address cli-code cli-type
             cli-name cli-inn cli-kpp cli-address Gruz-otprav Gruz-poluch gtd country /*user-name fact-user-name*/ plat-ras-doc
             pay-date in-date sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli BUTTON-contr
          WITH FRAME Dialog-Frame.
        end.
        if buf_schet-fact-doc.ext-doc-type <> "" then DISABLE BUTTON-contr WITH FRAME Dialog-Frame.
        DISABLE  doc-code ext-doc-type status_ contract-code cli-code cli-type
           /*user-name fact-user-name */ sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli
        WITH FRAME Dialog-Frame.
      end.
      enable b-sel-contract b-sel-docum with frame {&frame-name} .
      if buf_schet-fact-doc.in-doc-code = "" and buf_schet-fact-doc.in-doc-code = ? then hide b-sel-docum in frame {&frame-name} .
      if buf_schet-fact-doc.status_ = {&fact} then do:
          B-add:visible = no .
          b-chg:visible = no .
          B-del:visible = no .
          DISABLE  doc-code doc-date ext-doc-type status_ contract-code own-name own-inn own-kpp own-address cli-code cli-type
             cli-name cli-inn cli-kpp cli-address Gruz-otprav Gruz-poluch gtd country /*user-name fact-user-name*/ plat-ras-doc
             pay-date in-date sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli BUTTON-contr
          WITH FRAME Dialog-Frame.
      end.
    end.
    when "history" then do:
        B-add:visible = no .
        b-chg:visible = no .
        B-del:visible = no .
      find first buf_c-schet-fact-doc no-lock
        where buf_c-schet-fact-doc.doc-code = p-doc-code
          and buf_c-schet-fact-doc.db-num   = p-db-num
          and buf_c-schet-fact-doc.chip-num = p-chip-num
        .
      for each ub.c-schet-fact-line no-lock
        where ub.c-schet-fact-line.doc-code  = p-doc-code
          and ub.c-schet-fact-line.db-num    = p-db-num
        :
        create temp-line .
        buffer-copy ub.c-schet-fact-line except chip-num  corr-user-db-num  corr-user-name  corr-date  corr-time to temp-line .
      end.
      assign
        contract-code     = buf_c-schet-fact-doc.contract-code
        doc-code          = buf_c-schet-fact-doc.doc-code
        book-code         = buf_c-schet-fact-doc.book-code
        doc-date          = buf_c-schet-fact-doc.doc-date
        own-name          = buf_c-schet-fact-doc.own-name
        own-inn           = buf_c-schet-fact-doc.own-inn
        own-kpp           = buf_c-schet-fact-doc.own-kpp
        own-address       = buf_c-schet-fact-doc.own-address
        cli-code          = buf_c-schet-fact-doc.cli-code
        cli-type          = buf_c-schet-fact-doc.cli-type
        cli-name          = buf_c-schet-fact-doc.cli-name
        cli-address       = buf_c-schet-fact-doc.cli-address
        cli-inn           = buf_c-schet-fact-doc.cli-inn
        cli-kpp           = buf_c-schet-fact-doc.cli-kpp
        ext-doc-type      = buf_c-schet-fact-doc.ext-doc-type
        status_           = buf_c-schet-fact-doc.status_
        Gruz-otprav       = buf_c-schet-fact-doc.Gruz-otprav
        Gruz-poluch       = buf_c-schet-fact-doc.Gruz-poluch
        gtd               = buf_c-schet-fact-doc.gtd
        country           = buf_c-schet-fact-doc.country
        plat-ras-doc       = buf_c-schet-fact-doc.plat-ras-doc
        pay-date          = buf_c-schet-fact-doc.pay-date
        in-date           = buf_c-schet-fact-doc.in-date
        VAT-20-rubl       = buf_c-schet-fact-doc.VAT-20-rubl
        sum-rubl          = buf_c-schet-fact-doc.sum-rubl
        VAT-10-rubl       = buf_c-schet-fact-doc.VAT-10-rubl
        PS                = buf_c-schet-fact-doc.PS
      .
      b-OK:label in frame {&frame-name} = "&Выход" .
      b-exit:visible = no .
      DISABLE  doc-code book-code doc-date ext-doc-type status_ contract-code own-name own-inn own-kpp own-address cli-code cli-type
           cli-name cli-inn cli-kpp cli-address Gruz-otprav Gruz-poluch gtd country /*user-name fact-user-name*/ plat-ras-doc
           pay-date in-date PS sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli BUTTON-contr
      WITH FRAME Dialog-Frame.
    end.
  end.
  display {&DISPLAYED-OBJECTS} with frame {&frame-name}.
  OPEN QUERY BROWSE-1 FOR EACH temp-line INDEXED-REPOSITION.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc Dialog-Frame
PROCEDURE proc-calc :
do on error undo, return error return-value :
    define buffer b_temp-line for temp-line.
    assign
      sum-rubl    = 0
      s-no-VAT    = 0
      VAT-10-rubl = 0
      s-10-VAT    = 0
      VAT-20-rubl = 0
      s-20-VAT    = 0
    .
    for each b_temp-line :
      assign sum-rubl = sum-rubl + b_temp-line.sum-rubl-VAT .

      if b_temp-line.VAT-pc < 1 then do:
        assign s-no-VAT = s-no-VAT + b_temp-line.sum-rubl - b_temp-line.VAT-rubl .
      end.
      else do:
        if b_temp-line.VAT-pc < 11 then
          assign
            VAT-10-rubl = VAT-10-rubl + b_temp-line.VAT-rubl
            s-10-VAT    = s-10-VAT + b_temp-line.sum-rubl - b_temp-line.VAT-rubl
        .
        else
          assign
            VAT-20-rubl = VAT-20-rubl + b_temp-line.VAT-rubl
            s-20-VAT = s-20-VAT + b_temp-line.sum-rubl - b_temp-line.VAT-rubl
          .
      end.
    end.
  end.
end procedure. /* proc-calc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME