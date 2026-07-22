&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_base-currency FOR ub.currency.
DEFINE BUFFER buf_contract-currency FOR ub.currency.
DEFINE BUFFER buf_currency FOR ub.currency.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования сумм и курсов платежного документа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/10/03
Author: Bakhtadze Natalya
Creation date: 11/10/03

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT        PARAMETER parParentProc    AS WIDGET-HANDLE               NO-UNDO.
define input        parameter p-mode           as character                   no-undo. /*про запас*/
DEFINE INPUT        PARAMETER p-doc-date       LIKE ub.fin-doc.doc-date       NO-UNDO.
DEFINE INPUT        PARAMETER p-curr-code      LIKE ub.fin-doc.curr-code      NO-UNDO.
DEFINE INPUT        PARAMETER p-base-code      LIKE ub.sysconf.base-code      NO-UNDO.
DEFINE INPUT        PARAMETER p-contract-curr  LIKE ub.fin-doc.contract-curr  NO-UNDO.

DEFINE INPUT-OUTPUT PARAMETER p-sum-doc        LIKE ub.fin-doc.sum-doc        NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-exch-rate      LIKE ub.fin-doc.exch-rate      NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-exch-scale     LIKE ub.fin-doc.exch-scale     NO-UNDO.

DEFINE INPUT-OUTPUT PARAMETER p-sum-rubl       LIKE ub.fin-doc.sum-rubl       NO-UNDO.

DEFINE INPUT-OUTPUT PARAMETER p-sum-base       LIKE ub.fin-doc.sum-base       NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-base-rate      LIKE ub.fin-doc.base-rate      NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-base-scale     LIKE ub.fin-doc.base-scale     NO-UNDO.

DEFINE INPUT-OUTPUT PARAMETER p-sum-contr      LIKE ub.fin-doc.sum-contr      NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-contract-rate  LIKE ub.fin-doc.contract-rate  NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-contract-scale LIKE ub.fin-doc.contract-scale NO-UNDO.




/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования сумм и курсов платежного документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }

define variable v-rubf          as logical no-undo .
define variable v-exchf         as logical no-undo .
define variable v-basef         as logical no-undo .
define variable v-baseratef     as logical no-undo .
define variable v-contractf     as logical no-undo .
define variable v-contractratef as logical no-undo .
/*методы задания полей*/
define variable v-sum-doc-m        AS INTEGER NO-UNDO.
define variable v-exch-rate-m      AS INTEGER NO-UNDO.

define variable v-sum-rubl-m       AS INTEGER NO-UNDO.

define variable v-sum-base-m       AS INTEGER NO-UNDO.
define variable v-base-rate-m      AS INTEGER NO-UNDO.

define variable v-sum-contr-m      AS INTEGER NO-UNDO.
define variable v-contract-rate-m  AS INTEGER NO-UNDO.

DEFINE VARIABLE v-rubl-calc-option AS CHARACTER NO-UNDO.

/*методы РАСЧЕТА полей*/
define variable v-sum-doc-c        as character no-undo init "0":U .
define variable v-exch-rate-c      as character no-undo init "0":U.
define variable v-sum-rubl-c       as character no-undo init "0":U.
define variable v-sum-base-c       as character no-undo init "0":U.
define variable v-base-rate-c      as character no-undo init "0":U.
define variable v-sum-contr-c      as character no-undo init "0":U.
define variable v-contract-rate-c  as character no-undo init "0":U.

define variable v-tab-order as character no-undo .

&Scop  check-on-leave ~
if round(base-rate-1           , 4) <> input frame ~{&frame-name~} base-rate-1             then apply "leave" to base-rate-1            in frame ~{&frame-name~}. ~
if       base-scale-1               <> input frame ~{&frame-name~} base-scale-1            then apply "leave" to base-scale-1           in frame ~{&frame-name~}. ~
if round(sum-base-1          , 3) <> input frame ~{&frame-name~} sum-base-1            then apply "leave" to sum-base-1           in frame ~{&frame-name~}. ~
if round(sum-rubl-1          , 3) <> input frame ~{&frame-name~} sum-rubl-1            then apply "leave" to sum-rubl-1           in frame ~{&frame-name~}. ~
if round(exch-rate-1           , 4) <> input frame ~{&frame-name~} exch-rate-1             then apply "leave" to exch-rate-1            in frame ~{&frame-name~}. ~
if       exch-scale-1               <> input frame ~{&frame-name~} exch-scale-1            then apply "leave" to exch-scale-1           in frame ~{&frame-name~}. ~
if round(sum-doc-1          , 3) <> input frame ~{&frame-name~} sum-doc-1            then apply "leave" to sum-doc-1           in frame ~{&frame-name~}. ~
if round(contract-rate-1           , 4) <> input frame ~{&frame-name~} contract-rate-1             then apply "leave" to contract-rate-1            in frame ~{&frame-name~}. ~
if       contract-scale-1               <> input frame ~{&frame-name~} contract-scale-1            then apply "leave" to contract-scale-1           in frame ~{&frame-name~}. ~
if round(sum-contr-1          , 3) <> input frame ~{&frame-name~} sum-contr-1            then apply "leave" to sum-contr-1           in frame ~{&frame-name~}. ~


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES fin-doc

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH fin-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH fin-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame fin-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help BUTTON-1 sum-doc-1 ~
B-doc-sum exch-rate-1 exch-scale-1 B-get-rate B-rate sum-rubl-1 B-rubl-sum ~
sum-base-1 B-base-sum sum-contr-1 B-contract-sum base-rate-1 base-scale-1 ~
B-get-base B-base-rate contract-rate-1 contract-scale-1 B-get-contract ~
B-contract-rate RECT-1 RECT-2
&Scoped-Define DISPLAYED-OBJECTS doc-date-0 curr-code-0 F-curr-abbr-0 ~
sum-doc-0 exch-rate-0 exch-scale-0 sum-rubl-0 base-code-0 F-base-abbr-0 ~
contract-curr-code-0 F-contract-curr-abbr-0 sum-base-0 sum-contr-0 ~
base-rate-0 base-scale-0 contract-rate-0 contract-scale-0 curr-code-1 ~
F-curr-abbr-1 sum-doc-1 exch-rate-1 exch-scale-1 sum-rubl-1 base-code-1 ~
F-base-abbr-1 contract-curr-code-1 F-contract-curr-abbr-1 sum-base-1 ~
sum-contr-1 base-rate-1 base-scale-1 contract-rate-1 contract-scale-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-rubl-sum
       MENU-ITEM m_doc          LABEL "По сумме в вал. платежа и курсу вал. платежа"
       MENU-ITEM m_base         LABEL "По сумме в баз.вал. и курсу баз.вал."
       MENU-ITEM m_contr        LABEL "По сумме в вал. дог-ра и курсу вал. дог-ра".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-base-rate
     LABEL "Расчет"
     SIZE 10 BY 1.

DEFINE BUTTON B-base-sum
     LABEL "Расчет"
     SIZE 10 BY 1.

DEFINE BUTTON B-contract-rate
     LABEL "Расчет"
     SIZE 10 BY 1.

DEFINE BUTTON B-contract-sum
     LABEL "Расчет"
     SIZE 10 BY 1.

DEFINE BUTTON B-doc-sum
     LABEL "Расчет"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-get-base
     LABEL "<-Справ-ник"
     SIZE 8.5 BY 1 TOOLTIP "Получить курс базовой валюты из справочника на дату платежа"
     FONT 4.

DEFINE BUTTON B-get-contract
     LABEL "<-Справ-ник"
     SIZE 8.5 BY 1 TOOLTIP "Получить курс валюты договора из справочника на дату платежа"
     FONT 4.

DEFINE BUTTON B-get-rate
     LABEL "<-Справ-ник"
     SIZE 9 BY 1 TOOLTIP "Получить курс валюты платежа из справочника на дату платежа"
     FONT 4.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-rate
     LABEL "Расчет"
     SIZE 10 BY 1.

DEFINE BUTTON B-rubl-sum
     LABEL "Расчет"
     SIZE 10 BY 1.

DEFINE BUTTON BUTTON-1
     LABEL "Отлад. кнопка!!!!"
     SIZE 19.5 BY 1.25.

DEFINE VARIABLE base-code-0 LIKE ub.fin-doc.curr-code
     LABEL "Базовая валюта"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE base-code-1 LIKE ub.fin-doc.curr-code
     LABEL "Базовая валюта"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE base-rate-0 LIKE ub.fin-doc.base-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE base-rate-1 LIKE ub.fin-doc.base-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE base-scale-0 LIKE ub.fin-doc.base-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.

DEFINE VARIABLE base-scale-1 LIKE ub.fin-doc.base-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.

DEFINE VARIABLE contract-curr-code-0 LIKE ub.fin-doc.curr-code
     LABEL "Валюта договора"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE contract-curr-code-1 LIKE ub.fin-doc.curr-code
     LABEL "Валюта договора"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE contract-rate-0 LIKE ub.fin-doc.contract-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE contract-rate-1 LIKE ub.fin-doc.contract-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE contract-scale-0 LIKE ub.fin-doc.contract-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.

DEFINE VARIABLE contract-scale-1 LIKE ub.fin-doc.contract-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.

DEFINE VARIABLE curr-code-0 LIKE ub.fin-doc.curr-code
     LABEL "Валюта платежа"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE curr-code-1 LIKE ub.fin-doc.curr-code
     LABEL "Валюта платежа"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE doc-date-0 LIKE ub.fin-doc.doc-date
     LABEL "Дата платежа"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE exch-rate-0 LIKE ub.fin-doc.exch-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE exch-rate-1 LIKE ub.fin-doc.exch-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE exch-scale-0 LIKE ub.fin-doc.exch-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.

DEFINE VARIABLE exch-scale-1 LIKE ub.fin-doc.exch-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.

DEFINE VARIABLE F-base-abbr-0 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-base-abbr-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-contract-curr-abbr-0 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-contract-curr-abbr-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-curr-abbr-0 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-curr-abbr-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sum-base-0 LIKE ub.fin-doc.sum-base
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE sum-base-1 LIKE ub.fin-doc.sum-base
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE sum-contr-0 LIKE ub.fin-doc.sum-contr
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE sum-contr-1 LIKE ub.fin-doc.sum-contr
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE sum-doc-0 LIKE ub.fin-doc.sum-doc
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sum-doc-1 LIKE ub.fin-doc.sum-doc
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sum-rubl-0 LIKE ub.fin-doc.sum-rubl
     LABEL "abbr_rubli_firstshift"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE sum-rubl-1 LIKE ub.fin-doc.sum-rubl
     LABEL "abbr_rubli_firstshift"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.25 BY 10.54.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.25 BY 9.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.fin-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 83
     doc-date-0 AT ROW 2.5 COL 17.5 COLON-ALIGNED
          LABEL "Дата платежа"
          FGCOLOR 4
     curr-code-0 AT ROW 2.5 COL 49.5 COLON-ALIGNED
          LABEL "Валюта платежа"
     F-curr-abbr-0 AT ROW 2.5 COL 54.5 COLON-ALIGNED NO-LABEL
     sum-doc-0 AT ROW 3.5 COL 33.5 COLON-ALIGNED
          LABEL "Сумма" FORMAT ">,>>>,>>>,>>>,>>9.99"
          FGCOLOR 4
     exch-rate-0 AT ROW 4.5 COL 33.5 COLON-ALIGNED
          LABEL "Курс"
     exch-scale-0 AT ROW 4.5 COL 43.75 COLON-ALIGNED NO-LABEL
     sum-rubl-0 AT ROW 6.5 COL 33.5 COLON-ALIGNED
          LABEL "abbr_rubli_firstshift"
     base-code-0 AT ROW 8 COL 24.5 COLON-ALIGNED
          LABEL "Базовая валюта"
     F-base-abbr-0 AT ROW 8 COL 30 COLON-ALIGNED NO-LABEL
     contract-curr-code-0 AT ROW 8 COL 75 COLON-ALIGNED
          LABEL "Валюта договора"
     F-contract-curr-abbr-0 AT ROW 8 COL 80 COLON-ALIGNED NO-LABEL
     sum-base-0 AT ROW 9 COL 9 COLON-ALIGNED
          LABEL "Сумма"
     sum-contr-0 AT ROW 9 COL 59 COLON-ALIGNED
          LABEL "Сумма"
     base-rate-0 AT ROW 10 COL 9 COLON-ALIGNED
          LABEL "Курс"
     base-scale-0 AT ROW 10 COL 19.5 COLON-ALIGNED NO-LABEL
     contract-rate-0 AT ROW 10 COL 59 COLON-ALIGNED
          LABEL "Курс"
     contract-scale-0 AT ROW 10 COL 69.5 COLON-ALIGNED NO-LABEL
     curr-code-1 AT ROW 12 COL 49.5 COLON-ALIGNED
          LABEL "Валюта платежа"
     F-curr-abbr-1 AT ROW 12 COL 54.5 COLON-ALIGNED NO-LABEL
     BUTTON-1 AT ROW 12 COL 73.5
     sum-doc-1 AT ROW 13 COL 33.5 COLON-ALIGNED
          LABEL "Сумма" FORMAT ">,>>>,>>>,>>>,>>9.99"
          FGCOLOR 4
     B-doc-sum AT ROW 13 COL 61
     exch-rate-1 AT ROW 14 COL 33.5 COLON-ALIGNED
          LABEL "Курс"
     exch-scale-1 AT ROW 14 COL 43.75 COLON-ALIGNED NO-LABEL
     B-get-rate AT ROW 14 COL 51.5
     B-rate AT ROW 14 COL 61
     sum-rubl-1 AT ROW 16 COL 33.5 COLON-ALIGNED
          LABEL "abbr_rubli_firstshift"
     B-rubl-sum AT ROW 16 COL 61
     base-code-1 AT ROW 17.5 COL 22 COLON-ALIGNED
          LABEL "Базовая валюта"
     F-base-abbr-1 AT ROW 17.5 COL 27.5 COLON-ALIGNED NO-LABEL
     contract-curr-code-1 AT ROW 17.5 COL 75 COLON-ALIGNED
          LABEL "Валюта договора"
     F-contract-curr-abbr-1 AT ROW 17.5 COL 80 COLON-ALIGNED NO-LABEL
     sum-base-1 AT ROW 18.5 COL 6.5 COLON-ALIGNED
          LABEL "Сумма"
     B-base-sum AT ROW 18.5 COL 34
     sum-contr-1 AT ROW 18.5 COL 59 COLON-ALIGNED
          LABEL "Сумма"
     B-contract-sum AT ROW 18.5 COL 86.5
     base-rate-1 AT ROW 19.5 COL 6.5 COLON-ALIGNED
          LABEL "Курс"
     base-scale-1 AT ROW 19.5 COL 17 COLON-ALIGNED NO-LABEL
     B-get-base AT ROW 19.5 COL 25
     B-base-rate AT ROW 19.5 COL 34
     contract-rate-1 AT ROW 19.5 COL 59 COLON-ALIGNED
          LABEL "Курс"
     contract-scale-1 AT ROW 19.5 COL 69.5 COLON-ALIGNED NO-LABEL
     B-get-contract AT ROW 19.5 COL 77.5
     B-contract-rate AT ROW 19.5 COL 86.5
     RECT-1 AT ROW 11.5 COL 1
     RECT-2 AT ROW 2.25 COL 1
     "Старые значения" VIEW-AS TEXT
          SIZE 21 BY 1 AT ROW 1 COL 42
          FGCOLOR 3
     SPACE(36.25) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Расчет сумм и курсов платежа"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_base-currency B "?" ? ub currency
      TABLE: buf_contract-currency B "?" ? ub currency
      TABLE: buf_currency B "?" ? ub currency
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-rubl-sum:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-rubl-sum:HANDLE.

/* SETTINGS FOR FILL-IN base-code-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.curr-code EXP-LABEL EXP-SIZE    */
/* SETTINGS FOR FILL-IN base-code-1 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.curr-code EXP-LABEL EXP-SIZE    */
/* SETTINGS FOR FILL-IN base-rate-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.base-rate EXP-LABEL EXP-SIZE    */
/* SETTINGS FOR FILL-IN base-rate-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.base-rate EXP-LABEL EXP-SIZE              */
/* SETTINGS FOR FILL-IN base-scale-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.base-scale EXP-LABEL EXP-SIZE   */
/* SETTINGS FOR FILL-IN base-scale-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.base-scale EXP-LABEL EXP-SIZE             */
/* SETTINGS FOR FILL-IN contract-curr-code-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.curr-code EXP-LABEL EXP-SIZE    */
/* SETTINGS FOR FILL-IN contract-curr-code-1 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.curr-code EXP-LABEL EXP-SIZE    */
/* SETTINGS FOR FILL-IN contract-rate-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.contract-rate EXP-LABEL EXP-SIZE */
/* SETTINGS FOR FILL-IN contract-rate-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.contract-rate EXP-LABEL EXP-SIZE          */
/* SETTINGS FOR FILL-IN contract-scale-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.contract-scale EXP-LABEL EXP-SIZE */
/* SETTINGS FOR FILL-IN contract-scale-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.contract-scale EXP-LABEL EXP-SIZE         */
/* SETTINGS FOR FILL-IN curr-code-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.curr-code EXP-LABEL EXP-SIZE    */
/* SETTINGS FOR FILL-IN curr-code-1 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.curr-code EXP-LABEL EXP-SIZE    */
/* SETTINGS FOR FILL-IN doc-date-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.doc-date EXP-LABEL EXP-SIZE     */
/* SETTINGS FOR FILL-IN exch-rate-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.exch-rate EXP-LABEL EXP-SIZE    */
/* SETTINGS FOR FILL-IN exch-rate-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.exch-rate EXP-LABEL EXP-SIZE              */
/* SETTINGS FOR FILL-IN exch-scale-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.exch-scale EXP-LABEL EXP-SIZE   */
/* SETTINGS FOR FILL-IN exch-scale-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.exch-scale EXP-LABEL EXP-SIZE             */
/* SETTINGS FOR FILL-IN F-base-abbr-0 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-base-abbr-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-contract-curr-abbr-0 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-contract-curr-abbr-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-curr-abbr-0 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-curr-abbr-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN sum-base-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.sum-base EXP-LABEL EXP-SIZE     */
/* SETTINGS FOR FILL-IN sum-base-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.sum-base EXP-LABEL EXP-SIZE               */
/* SETTINGS FOR FILL-IN sum-contr-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.sum-contr EXP-LABEL EXP-SIZE    */
/* SETTINGS FOR FILL-IN sum-contr-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.sum-contr EXP-LABEL EXP-SIZE              */
/* SETTINGS FOR FILL-IN sum-doc-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.sum-doc EXP-LABEL EXP-FORMAT EXP-SIZE */
/* SETTINGS FOR FILL-IN sum-doc-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.sum-doc EXP-LABEL EXP-FORMAT EXP-SIZE     */
/* SETTINGS FOR FILL-IN sum-rubl-0 IN FRAME Dialog-Frame
   NO-ENABLE LIKE = Temp-Tables.fin-doc.sum-rubl EXP-LABEL EXP-SIZE     */
/* SETTINGS FOR FILL-IN sum-rubl-1 IN FRAME Dialog-Frame
   LIKE = Temp-Tables.fin-doc.sum-rubl EXP-LABEL EXP-SIZE               */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.fin-doc"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Расчет сумм и курсов платежа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-base-rate Dialog-Frame
ON CHOOSE OF B-base-rate IN FRAME Dialog-Frame /* Расчет */
DO:
  { gbl/stdbtn.i }
  RUN proc-calc-base-rate IN this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-base-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-base-sum Dialog-Frame
ON CHOOSE OF B-base-sum IN FRAME Dialog-Frame /* Расчет */
DO:
  { gbl/stdbtn.i }
  RUN proc-calc-base-sum IN this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-contract-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-contract-rate Dialog-Frame
ON CHOOSE OF B-contract-rate IN FRAME Dialog-Frame /* Расчет */
DO:
  { gbl/stdbtn.i }
  RUN proc-calc-contract-rate IN this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-contract-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-contract-sum Dialog-Frame
ON CHOOSE OF B-contract-sum IN FRAME Dialog-Frame /* Расчет */
DO:
  { gbl/stdbtn.i }
  RUN proc-calc-contract-sum IN this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-doc-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-doc-sum Dialog-Frame
ON CHOOSE OF B-doc-sum IN FRAME Dialog-Frame /* Расчет */
DO:
  { gbl/stdbtn.i }
  RUN proc-calc-doc-sum IN this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-get-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-get-base Dialog-Frame
ON CHOOSE OF B-get-base IN FRAME Dialog-Frame /* <-Справ-ник */
DO:
  { gbl/stdbtn.i }

  define variable v-base-abbr like ub.currency.curr-abbr no-undo .
  define variable v-old-base-rate-1 like ub.fin-doc.base-rate no-undo .
  define variable v-old-base-scale-1 like ub.fin-doc.base-scale no-undo .
  assign
  v-old-base-rate-1 =  base-rate-1
  v-old-base-scale-1 = base-scale-1
  .
  { gbl/exchrate.i  p-base-code p-doc-date base-rate-1 base-scale-1 v-base-abbr }
  display
  base-rate-1
  base-scale-1
  with frame {&frame-name}.
  if
  v-old-base-rate-1 <> base-rate-1
  or
  v-old-base-scale-1 <> base-scale-1
  then do:
    assign
    v-base-rate-c = "!":U
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-get-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-get-contract Dialog-Frame
ON CHOOSE OF B-get-contract IN FRAME Dialog-Frame /* <-Справ-ник */
DO:
  { gbl/stdbtn.i }

  define variable v-contract-curr-abbr like ub.currency.curr-abbr no-undo .
  define variable v-old-contract-rate-1 like ub.fin-doc.contract-rate no-undo .
  define variable v-old-contract-scale-1 like ub.fin-doc.contract-scale no-undo .
  assign
  v-old-contract-rate-1 =  contract-rate-1
  v-old-contract-scale-1 = contract-scale-1
  .
  { gbl/exchrate.i  p-contract-curr p-doc-date contract-rate-1 contract-scale-1 v-contract-curr-abbr }
   display
   contract-rate-1
   contract-scale-1
   with frame {&frame-name}.
  if
  v-old-contract-rate-1 <> contract-rate-1
  or
  v-old-contract-scale-1 <> contract-scale-1
  then do:
    assign
    v-contract-rate-c = "!":U
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-get-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-get-rate Dialog-Frame
ON CHOOSE OF B-get-rate IN FRAME Dialog-Frame /* <-Справ-ник */
DO:
  { gbl/stdbtn.i }

  define variable v-curr-abbr like ub.currency.curr-abbr no-undo .
  define variable v-old-exch-rate-1 like ub.fin-doc.exch-rate no-undo .
  define variable v-old-exch-scale-1 like ub.fin-doc.exch-scale no-undo .
  assign
  v-old-exch-rate-1 =  exch-rate-1
  v-old-exch-scale-1 = exch-scale-1
  .
  { gbl/exchrate.i  p-curr-code p-doc-date exch-rate-1 exch-scale-1 v-curr-abbr }
  display
  exch-rate-1
  exch-scale-1
  with frame {&frame-name}.
  if
  v-old-exch-rate-1 <> exch-rate-1
  or
  v-old-exch-scale-1 <> exch-scale-1
  then do:
    assign
    v-exch-rate-c = "!":U
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rate Dialog-Frame
ON CHOOSE OF B-rate IN FRAME Dialog-Frame /* Расчет */
DO:
  RUN proc-calc-exch-rate IN this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rubl-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rubl-sum Dialog-Frame
ON CHOOSE OF B-rubl-sum IN FRAME Dialog-Frame /* Расчет */
DO:
  { gbl/stdbtn.i }
  IF b-rubl-sum:POPUP-MENU = ? THEN DO:
    RUN proc-calc-rubl-sum IN THIS-PROCEDURE ("doc":U).
  END.
  ELSE DO:
    run gbl/pop-up.p (self:handle, no) no-error.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME base-rate-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL base-rate-1 Dialog-Frame
ON LEAVE OF base-rate-1 IN FRAME Dialog-Frame /* Курс */
DO:
   if input frame {&frame-name} {&self-name} <> round ({&self-name}, 4) then do:
    assign
    v-base-rate-m = 1
    v-base-rate-c = "!":U
    v-sum-base-c = "!":U
    v-sum-rubl-c = "sum-base/!":U
    frame {&frame-name}
    {&self-name}
    {&self-name}:tooltip = string({&self-name})
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME base-scale-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL base-scale-1 Dialog-Frame
ON LEAVE OF base-scale-1 IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    assign
    v-base-rate-m = 1
    v-base-rate-c = "!":U
    v-sum-base-c = "!":U
    v-sum-rubl-c = "!":U
    frame {&frame-name}
    {&self-name}
    {&self-name}:tooltip = string({&self-name})
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame /* Отлад. кнопка!!!! */
DO:
  MESSAGE
  "Вал платежа" sum-doc-1 SKIP
  "курс валюты платежа" exch-rate-1 SKIP
  "{&abbr_rubli_firstshift}" sum-rubl-1 SKIP
  "Баз вал" sum-base-1 SKIP
   "Курс вазвал" base-rate-1 SKIP
   "Вал дог-ра" sum-contr-1 SKIP
   "Курс валю дог-ра" contract-rate-1 skip
"v-sum-doc-c"                     v-sum-doc-c        skip
"v-exch-rate-c"                   v-exch-rate-c      skip
"v-sum-rubl-c"                    v-sum-rubl-c       skip
"v-sum-base-c"                    v-sum-base-c        skip
"v-base-rate-c"                   v-base-rate-c       skip
"v-sum-contr-c"                   v-sum-contr-c       skip
"v-contract-rate-c"               v-contract-rate-c    skip
    VIEW-AS ALERT-BOX.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME contract-rate-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL contract-rate-1 Dialog-Frame
ON LEAVE OF contract-rate-1 IN FRAME Dialog-Frame /* Курс */
DO:
   if input frame {&frame-name} {&self-name} <> round ({&self-name}, 4) then do:
    assign
    v-contract-rate-m = 1
    v-contract-rate-c = "!":U
    v-sum-contr-c = "!":Uc
    v-sum-rubl-c = "!":U
    frame {&frame-name}
    {&self-name}
    {&self-name}:tooltip = string({&self-name})
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME contract-scale-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL contract-scale-1 Dialog-Frame
ON LEAVE OF contract-scale-1 IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    assign
    v-contract-rate-m = 1
    v-contract-rate-c = "!":U
    v-sum-rubl-c = "!":U
    v-sum-contr-c = "!":U
    frame {&frame-name}
    {&self-name}
    {&self-name}:tooltip = string({&self-name})
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME exch-rate-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL exch-rate-1 Dialog-Frame
ON LEAVE OF exch-rate-1 IN FRAME Dialog-Frame /* Курс */
DO:
    if input frame {&frame-name} {&self-name} <> round ({&self-name}, 4) then do:
    assign
    v-exch-rate-m = 1
    v-exch-rate-c = "!":U
    v-sum-rubl-c = "!":U
    v-sum-doc-c = "!":U
    frame {&frame-name}
    {&self-name}
    {&self-name}:tooltip = string({&self-name})
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME exch-scale-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL exch-scale-1 Dialog-Frame
ON LEAVE OF exch-scale-1 IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    assign
    v-exch-rate-m = 1
    v-exch-rate-c = "!":U
    v-sum-rubl-c = "!":U
    v-sum-doc-c = "!":U
    frame {&frame-name}
    {&self-name}
    {&self-name}:tooltip = string({&self-name})
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_base Dialog-Frame
ON CHOOSE OF MENU-ITEM m_base /* По сумме в баз.вал. и курсу баз.вал. */
DO:
  RUN proc-calc-rubl-sum IN THIS-PROCEDURE ("base":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_contr Dialog-Frame
ON CHOOSE OF MENU-ITEM m_contr /* По сумме в вал. дог-ра и курсу вал. дог-ра */
DO:
  RUN proc-calc-rubl-sum IN THIS-PROCEDURE ("contract":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_doc Dialog-Frame
ON CHOOSE OF MENU-ITEM m_doc /* По сумме в вал. платежа и курсу вал. платежа */
DO:
  RUN proc-calc-rubl-sum IN THIS-PROCEDURE ("doc":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sum-base-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sum-base-1 Dialog-Frame
ON LEAVE OF sum-base-1 IN FRAME Dialog-Frame /* Сумма */
DO:
   if input frame {&frame-name} {&self-name} <> round ({&self-name}, 2) then do:
    assign
     v-sum-base-m = 1
     v-sum-base-c = "!":U
     v-sum-rubl-c = "!":U
     v-base-rate-c = "!":U
     frame {&frame-name}
     {&self-name}
     {&self-name}:tooltip = string({&self-name})
     .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sum-contr-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sum-contr-1 Dialog-Frame
ON LEAVE OF sum-contr-1 IN FRAME Dialog-Frame /* Сумма */
DO:
   if input frame {&frame-name} {&self-name} <> round ({&self-name}, 2) then do:
    assign
    v-sum-contr-m = 1
    v-sum-contr-c = "!":U
    v-sum-rubl-c = "!":U
    v-contract-rate-c = "!":U
    frame {&frame-name}
    {&self-name}
    {&self-name}:tooltip = string({&self-name})
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sum-doc-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sum-doc-1 Dialog-Frame
ON LEAVE OF sum-doc-1 IN FRAME Dialog-Frame /* Сумма */
DO:
   if input frame {&frame-name} {&self-name} <> round ({&self-name}, 2) then do:

    assign
    v-sum-doc-m = 1
    v-sum-doc-c = "!":U
    v-sum-rubl-c = "!":U
    v-exch-rate-c = "!":U
    frame {&frame-name}
    {&self-name}
    {&self-name}:tooltip = string({&self-name})
    .
  end.
  RUN proc-not-enable-rubl IN THIS-PROCEDURE.
  RUN proc-not-enable-base IN THIS-PROCEDURE.
  RUN proc-not-enable-contr IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sum-rubl-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sum-rubl-1 Dialog-Frame
ON LEAVE OF sum-rubl-1 IN FRAME Dialog-Frame /* abbr_rubli_firstshift */
DO:
   if input frame {&frame-name} {&self-name} <> round ({&self-name}, 2) then do:
    assign
    v-sum-rubl-m = 1
    v-sum-rubl-c = "!":U
    v-sum-base-c = "!":U
    v-sum-doc-c = "!":U
    v-sum-contr-c = "!":U
    v-exch-rate-c = "!":U
    v-base-rate-c = "!":U
    v-contract-rate-c = "!":U
    frame {&frame-name}
    {&self-name}
    {&self-name}:tooltip = string({&self-name})
    .
  end.
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

{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  FIND FIRST buf_currency NO-LOCK WHERE
            buf_Currency.curr-code = p-curr-code  NO-ERROR.
  IF NOT AVAILABLE buf_currency THEN DO:
      MESSAGE
    "Неверное значение параметра p-curr-code:" p-curr-code
    vss-workfile vss-revision vss-description skip
    view-as alert-box .

  END.
  FIND FIRST buf_base-currency NO-LOCK WHERE
            buf_base-currency.curr-code = p-base-code NO-ERROR.
  IF NOT available buf_base-currency THEN DO:
      MESSAGE
    "Неверное значение параметра p-base-code:" p-base-code
    vss-workfile vss-revision vss-description skip
    view-as alert-box .
    RETURN ERROR.
  END.
  FIND FIRST buf_contract-currency NO-LOCK WHERE
            buf_contract-currency.curr-code = p-contract-curr NO-ERROR.
  IF NOT AVAILABLE buf_contract-currency THEN DO:
      MESSAGE
        "Неверное значение параметра p-contract-curr:" p-contract-curr
        vss-workfile vss-revision vss-description skip
        view-as alert-box .
    RETURN ERROR.
  END.
  RUN Myenable.
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
  DISPLAY doc-date-0 curr-code-0 F-curr-abbr-0 sum-doc-0 exch-rate-0
          exch-scale-0 sum-rubl-0 base-code-0 F-base-abbr-0 contract-curr-code-0
          F-contract-curr-abbr-0 sum-base-0 sum-contr-0 base-rate-0 base-scale-0
          contract-rate-0 contract-scale-0 curr-code-1 F-curr-abbr-1 sum-doc-1
          exch-rate-1 exch-scale-1 sum-rubl-1 base-code-1 F-base-abbr-1
          contract-curr-code-1 F-contract-curr-abbr-1 sum-base-1 sum-contr-1
          base-rate-1 base-scale-1 contract-rate-1 contract-scale-1
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help BUTTON-1 sum-doc-1 B-doc-sum exch-rate-1
         exch-scale-1 B-get-rate B-rate sum-rubl-1 B-rubl-sum sum-base-1
         B-base-sum sum-contr-1 B-contract-sum base-rate-1 base-scale-1
         B-get-base B-base-rate contract-rate-1 contract-scale-1 B-get-contract
         B-contract-rate RECT-1 RECT-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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

assign
b-rubl-sum:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1
curr-code-0  = p-curr-code
F-curr-abbr-0 = buf_currency.curr-abbr
curr-code-1  = p-curr-code
F-curr-abbr-1  =  buf_currency.curr-abbr
doc-date-0   =  p-doc-date
sum-doc-0  =  p-sum-doc
exch-rate-0  = p-exch-rate
exch-scale-0  =  p-exch-scale
sum-rubl-0 = p-sum-rubl
base-code-0  = p-base-code
F-base-abbr-0 =  buf_base-currency.curr-abbr
contract-curr-code-0 = p-contract-curr
F-contract-curr-abbr-0  = buf_contract-currency.curr-abbr
sum-base-0  = p-sum-base
sum-contr-0  = p-sum-contr
base-rate-0  = p-base-rate
base-scale-0 = p-base-scale
contract-rate-0  = p-contract-rate
contract-scale-0  = p-contract-scale
sum-doc-1 = p-sum-doc
exch-rate-1  = p-exch-rate
exch-scale-1  = p-exch-scale
sum-rubl-1 = p-sum-rubl
base-code-1  = p-base-code
F-base-abbr-1 = buf_base-currency.curr-abbr
contract-curr-code-1  = p-contract-curr
F-contract-curr-abbr-1 = buf_contract-currency.curr-abbr
sum-base-1 = p-sum-base
sum-contr-1 = p-sum-contr
base-rate-1  = p-base-rate
base-scale-1  = p-base-scale
contract-rate-1 = p-contract-rate
contract-scale-1 = p-contract-scale
sum-doc-1:tooltip                         =    string(p-sum-doc)
exch-rate-1:tooltip                       =    string(p-exch-rate)
exch-scale-1:tooltip                      =    string(p-exch-scale)
sum-rubl-1:tooltip                        =    string(p-sum-rubl)
base-code-1:tooltip                       =    string(p-base-code)
F-base-abbr-1:tooltip                     =    string(buf_base-currency.curr-abbr)
contract-curr-code-1:tooltip              =    string(p-contract-curr)
F-contract-curr-abbr-1:tooltip            =    string(buf_contract-currency.curr-abbr)
sum-base-1:tooltip                        =    string(p-sum-base)
sum-contr-1:tooltip                       =    string(p-sum-contr)
base-rate-1:tooltip                       =    string(p-base-rate)
base-scale-1:tooltip                      =    string(p-base-scale)
contract-rate-1:tooltip                   =    string(p-contract-rate)
contract-scale-1:tooltip                  =    string(p-contract-scale)
sum-rubl-0 :label                         =    "{&abbr_rubli_firstshift}"
sum-rubl-1 :label                         =    "{&abbr_rubli_firstshift}"
.
if p-curr-code <> 0
then do:
  assign
  v-rubf = yes
  v-exchf = yes
  .
end.
if /*p-base-code <> p-curr-code and */ /*закоментарено по поруч СУСЛОВА*/
p-base-code <> 0
then do:
  assign
  v-basef = yes
  v-baseratef = yes
  v-rubf = yes
  v-exchf = yes
  .
end.
if
  (p-contract-curr <> 0
  /*and p-contract-curr <> p-curr-code*/  /*закоментарено по поруч СУСЛОВА*/
  /*and p-contract-curr <> p-base-code*/  /*закоментарено по поруч СУСЛОВА*/
    )
  then do:
  assign
  v-contractf = yes
  v-contractratef = yes
  v-rubf = yes
  v-exchf = yes

  .
end.
ASSIGN
MENU-ITEM m_base:SENSITIVE IN MENU menu-b-rubl-sum = v-basef OR v-baseratef
MENU-ITEM m_contr:SENSITIVE IN MENU menu-b-rubl-sum = v-contractf OR v-contractratef
.
IF NOT (MENU-ITEM m_base:SENSITIVE IN MENU menu-b-rubl-sum OR MENU-ITEM m_contr:SENSITIVE IN MENU menu-b-rubl-sum)
THEN
b-rubl-sum:POPUP-MENU = ?
.
ASSIGN
v-tab-order = "sum-doc-1,B-doc-sum," +
              (IF v-exchf THEN "exch-rate-1,exch-scale-1,B-get-rate,B-rate,":U ELSE "":U) +
              (IF v-rubf THEN "sum-rubl-1,b-rubl-sum,":U ELSE "":U) +
              (IF v-basef THEN "sum-base-1,b-base-sum,":U ELSE "":U) +
              (IF v-basef THEN "base-rate-1,base-scale-1,B-get-base,B-base-rate,":U ELSE "":U) +
              (IF v-contractf THEN "sum-contr-1,b-contract-sum,":U ELSE "":U) +
              (IF v-contractratef THEN "contract-rate-1,contract-scale-1,b-get-contract,b-contract-rate,":U ELSE "":U) +
              "b-exit,b-quit,b-help":U
              .


 DISPLAY doc-date-0 curr-code-0 F-curr-abbr-0 sum-doc-0 exch-rate-0
          exch-scale-0 sum-rubl-0 base-code-0 F-base-abbr-0 contract-curr-code-0
          F-contract-curr-abbr-0 sum-base-0 sum-contr-0 base-rate-0 base-scale-0
          contract-rate-0 contract-scale-0 curr-code-1 F-curr-abbr-1 sum-doc-1
          exch-rate-1 exch-scale-1 sum-rubl-1 base-code-1 F-base-abbr-1
          contract-curr-code-1 F-contract-curr-abbr-1 sum-base-1 sum-contr-1
          base-rate-1 base-scale-1 contract-rate-1 contract-scale-1
      WITH FRAME {&frame-name} .
ENABLE
B-exit b-quit B-Help
sum-doc-1 B-doc-sum
exch-rate-1 WHEN v-exchf
exch-scale-1 WHEN v-exchf
B-get-rate WHEN v-exchf
B-rate WHEN v-exchf

sum-rubl-1  WHEN v-rubf
B-rubl-sum WHEN v-rubf

sum-base-1 WHEN v-basef
base-rate-1 WHEN v-baseratef
base-scale-1 WHEN v-baseratef
B-base-sum WHEN v-basef
B-get-base  WHEN v-baseratef
B-base-rate WHEN v-baseratef

sum-contr-1 WHEN v-contractf
B-contract-sum WHEN v-contractf
contract-rate-1 WHEN v-contractratef = yes
contract-scale-1 WHEN v-contractratef = yes
B-get-contract WHEN v-contractratef = yes
B-contract-rate WHEN v-contractratef = yes

RECT-1 RECT-2
button-1
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
hide
button-1 in frame {&frame-name} .
APPLY "ENTRY" TO sum-doc-1 IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-base-rate Dialog-Frame
PROCEDURE proc-calc-base-rate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
v-base-rate-c = "sum-rubl/sum-base":U
v-sum-base-c = "":U
v-sum-rubl-c = "":U
base-scale-1 = 1
base-rate-1 = sum-rubl-1 / sum-base-1
base-rate-1:tooltip in frame {&frame-name}  = string(base-rate-1)
v-sum-base-m = 0
.
DISPLAY
base-rate-1
base-scale-1
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-base-sum Dialog-Frame
PROCEDURE proc-calc-base-sum :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
v-sum-base-c = "sum-rubl/base-rate":U
v-base-rate-c = "":U
v-sum-rubl-c = "":U
sum-base-1 = sum-rubl-1 / ( base-rate-1 / base-scale-1 )
sum-base-1:tooltip in frame {&frame-name} = string(sum-base-1)
v-base-rate-m = 0
.
DISPLAY
SUM-base-1
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-contract-rate Dialog-Frame
PROCEDURE proc-calc-contract-rate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
v-contract-rate-c = "sum-rubl/sum-contr":U
v-sum-rubl-c = "":U
v-sum-contr-c = "":U
contract-scale-1 = 1
contract-rate-1 = sum-rubl-1 / sum-contr-1
contract-rate-1:tooltip  in frame {&frame-name} = string(contract-rate-1)
v-sum-contr-m = 0
.
DISPLAY
contract-rate-1
contract-scale-1
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-contract-sum Dialog-Frame
PROCEDURE proc-calc-contract-sum :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
v-sum-contr-c = "sum-rubl/contract-rate":U
v-sum-rubl-c = "":U
v-contract-rate-c = "":U
sum-contr-1 = sum-rubl-1 / ( contract-rate-1 / contract-scale-1 )
sum-contr-1:tooltip in frame {&frame-name}  = string(sum-contr-1)
v-contract-rate-m = 0
.
DISPLAY
SUM-contr-1
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-doc-sum Dialog-Frame
PROCEDURE proc-calc-doc-sum :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
v-sum-doc-c = "sum-rubl/exch-rate":U
v-sum-rubl-c = "":U
v-exch-rate-c = "":U
sum-doc-1 = sum-rubl-1 / ( exch-rate-1 / exch-scale-1 )
sum-doc-1:tooltip in frame {&frame-name}  = string(sum-doc-1)
v-exch-rate-m = 0
.
DISPLAY
SUM-doc-1
WITH FRAME {&FRAME-NAME}.
RUN proc-not-enable-base IN THIS-PROCEDURE.
RUN proc-not-enable-contr IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-exch-rate Dialog-Frame
PROCEDURE proc-calc-exch-rate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
v-exch-rate-c = "sum-rubl/sum-doc":U
v-sum-rubl-c = "":U
v-sum-doc-c = "":U
exch-scale-1 = 1
exch-rate-1 = sum-rubl-1 / sum-doc-1
exch-rate-1:tooltip in frame {&frame-name}  = string(exch-rate-1)
v-sum-doc-m = 0
.
DISPLAY
exch-rate-1
exch-scale-1
WITH FRAME {&FRAME-NAME}.
RUN proc-not-enable-base IN THIS-PROCEDURE.
RUN proc-not-enable-contr IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-rubl-sum Dialog-Frame
PROCEDURE proc-calc-rubl-sum :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-calc-option AS CHARACTER NO-UNDO.
{&check-on-leave}
CASE p-calc-option:
  WHEN "doc":U  THEN DO:
    ASSIGN
    v-sum-rubl-c = "sum-doc*exch-rate":U
    v-exch-rate-c = "":U
    v-sum-doc-c = "":U
    v-base-rate-c = "!":U
    v-sum-base-c = "!":U
    v-contract-rate-c = "!":U
    v-sum-contr-c = "!":U
    sum-rubl-1 = sum-doc-1 * ( exch-rate-1 / exch-scale-1 )
    v-exch-rate-m = 0
    v-sum-doc-m = 0
    .
    RUN proc-not-enable-base IN THIS-PROCEDURE.
    RUN proc-not-enable-contr IN THIS-PROCEDURE.
  END.
  WHEN "base":U  THEN DO:
    ASSIGN
    v-sum-rubl-c = "sum-base*base-rate":U
    v-base-rate-c = "":U
    v-sum-base-c = "":U
    v-exch-rate-c = "!":U
    v-sum-doc-c = "!":U
    v-contract-rate-c = "!":U
    v-sum-contr-c = "!":U
    sum-rubl-1 = sum-base-1 * ( base-rate-1 / base-scale-1 )
    v-base-rate-m = 0
    v-sum-base-m = 0
    .
     RUN proc-not-enable-contr IN THIS-PROCEDURE.
  END.
  WHEN "contract":U THEN DO:
      ASSIGN
      v-sum-rubl-c = "sum-contr*contract-rate":U
      v-contract-rate-c = "":U
      v-sum-contr-c = "":U
      v-base-rate-c = "!":U
      v-sum-base-c = "!":U
      v-exch-rate-c = "!":U
      v-sum-doc-c = "!":U
      sum-rubl-1 = sum-contr-1 * ( contract-rate-1 / contract-scale-1 )
      v-contract-rate-m = 0
      v-sum-contr-m = 0
      .
      RUN proc-not-enable-base IN THIS-PROCEDURE.
  END.
END CASE.
assign
sum-rubl-1:tooltip  in frame {&frame-name} = string(sum-rubl-1)
.
DISPLAY
sum-rubl-1
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-not-enable-base Dialog-Frame
PROCEDURE proc-not-enable-base :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*если запрещены другие окна нам самим надо все суммы пересчитать*/
    IF NOT v-basef OR NOT v-baseratef THEN  DO:
        IF p-base-code = 0 THEN DO:
            ASSIGN
            sum-base-1 = SUM-rubl-1
            base-rate-1 = 1
            base-scale-1 = 1
            .
        END.
        ELSE IF p-base-code = p-curr-code THEN DO:
            ASSIGN
            sum-base-1 = sum-doc-1
            base-rate-1 = exch-rate-1
            base-scale-1 = exch-scale-1
            .
        END.
    END.
assign
sum-base-1:tooltip in frame {&frame-name} = string(sum-base-1)
base-rate-1:tooltip in frame {&frame-name}  = string(base-rate-1)
base-scale-1:tooltip in frame {&frame-name}  = string(base-scale-1)
.
DISPLAY
sum-base-1
base-rate-1
base-scale-1
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-not-enable-contr Dialog-Frame
PROCEDURE proc-not-enable-contr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF NOT v-contractf OR NOT v-contractratef THEN DO:
       IF p-contract-curr = 0  THEN DO:
            ASSIGN
            sum-contr-1 = SUM-rubl-1
            contract-rate-1 = 1
            contract-scale-1 = 1
            .
       END.
       ELSE DO:
           IF p-contract-curr = p-curr-code THEN DO:
                ASSIGN
                sum-contr-1 = SUM-doc-1
                contract-rate-1 = exch-rate-1
                contract-scale-1 = exch-scale-1
                .
           END.
           IF p-contract-curr = p-base-code THEN DO:
                 ASSIGN
                 sum-contr-1 = SUM-base-1
                 contract-rate-1 = base-rate-1
                 contract-scale-1 = base-scale-1
                 .
            END.
       END. /*IF p-contract-curr <> 0  THEN DO:*/
    END. /*IF NOT v-contract-f OR NOT v-contractratef THEN DO:*/
assign
sum-contr-1:tooltip in frame {&frame-name}  = string(sum-contr-1)
contract-rate-1:tooltip in frame {&frame-name}  = string(contract-rate-1)
contract-scale-1:tooltip in frame {&frame-name}  = string(contract-scale-1)
.
DISPLAY
sum-contr-1
contract-rate-1
contract-scale-1
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-not-enable-rubl Dialog-Frame
PROCEDURE proc-not-enable-rubl :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  IF NOT v-rubf OR NOT v-exchf THEN DO:
      ASSIGN
      exch-rate-1 = 1
      exch-scale-1 = 1
      sum-rubl-1 = sum-doc-1
      .
  END.
  assign
  sum-rubl-1:tooltip in frame {&frame-name}  = string(sum-rubl-1)
  exch-rate-1:tooltip in frame {&frame-name}  = string(exch-rate-1)
  exch-scale-1:tooltip in frame {&frame-name}  = string(exch-scale-1)
  .
  DISPLAY
  exch-rate-1
  exch-scale-1
  sum-rubl-1
  WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-rate-correct AS CHARACTER NO-UNDO.
/*Если не отработали триггера на leave*/
{&check-on-leave}
RUN rate-correct IN THIS-PROCEDURE (OUTPUT v-rate-correct) NO-ERROR.
if error-status:error then do:
  message "Ошибка при вызове процедуры rate-correct." skip
          return-value
          error-status:get-message(1)
          error-status:get-message(2)
  view-as alert-box error.
  return no-apply.
end.
CASE v-rate-correct:
    WHEN "sum-doc":U then do:
      message
      "Неверная сумма платежа или сумма платежа не согласована с другими суммами"
      view-as alert-box .
       apply "entry" to sum-doc-1.
       return error .
    end.
    WHEN "sum-rubl":U then do:
      message
      "Неверная сумма в {&abbr_rublyah} или сумма в {&abbr_rublyah} не согласована с другими суммами"
      view-as alert-box .
       apply "entry" to sum-rubl-1.
       return error .
    end.
    when "sum-base":U then do:
      message
      "Неверная сумма в баз вал или сумма в баз. вал. не согласована с суммой в {&abbr_rublyah} и курсом баз.вал."
      view-as alert-box .
       apply "entry" to sum-base-1.
       return error .
    end.
    when "sum-contr":U then do:
      message
      "Неверная сумма в вал дог-ра или сумма в вал. дог-ра не согласована с суммой в {&abbr_rublyah} и курсом вал.дог-ра"
      view-as alert-box .
       apply "entry" to sum-contr-1.
       return error .
    end.
    WHEN "exch-rate" THEN DO:
        message
          "Курс валюты платежа не согласован с суммой платежа и суммой в национальной валюте" skip
          "Сумма в валюте платежа: " sum-doc-1 skip
          "Сумма в {&abbr_rublyah}: " sum-rubl-1 skip
          "Курс валюты платежа: " exch-rate-1 skip
          "Шкала валюты платежа: " exch-scale-1
        view-as alert-box information.
      if b-rate:sensitive IN FRAME {&frame-name} then do:
        apply "entry" to b-rate.
      end.
      else do:
        apply "entry" to sum-doc-1.
      end.
        return ERROR.
    END.
    WHEN "base-rate":U THEN DO:
           message
          "Курс базовой валюты не согласован с суммой в базовой валюте и суммой в национальной валюте" skip
          "Сумма в базовой валюте: " sum-base-1 skip
          "Сумма в {&abbr_rublyah}: " sum-rubl-1 skip
          "Курс базовой валюты: " base-rate-1 skip
          "Шкала базовой валюты: " base-scale-1
  view-as alert-box information.
      if b-base-rate:sensitive then do:
        apply "entry" to b-base-rate.
      end.
      else do:
        apply "entry" to sum-doc-1.
      end.
        RETURN error.
    END.
    WHEN "contract-rate":U THEN DO:
        message
          "Курс валюты договора не согласован с суммой платежа и суммой в национальной валюте" skip
          "Сумма в валюте договора: " sum-contr-1 skip
          "Сумма в {&abbr_rublyah}: " sum-rubl-1 skip
          "Курс валюты договора: " contract-rate-1 skip
          "Шкала валюты договора: " contract-scale-1
  view-as alert-box information.
      if b-contract-rate:sensitive then do:
        apply "entry" to b-contract-rate.
      end.
      else do:
        apply "entry" to sum-contr-1.
      end.
        return error.
  END.
END CASE.
ASSIGN
p-sum-rubl = sum-rubl-1
p-sum-doc = sum-doc-1
p-exch-rate = exch-rate-1
p-exch-scale = exch-scale-1
p-sum-base = sum-base-1
p-base-rate = base-rate-1
p-base-scale = base-scale-1
p-sum-contr = sum-contr-1
p-contract-rate = contract-rate-1
p-contract-scale = contract-scale-1
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rate-correct Dialog-Frame
PROCEDURE rate-correct :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER p-rate-correct AS CHARACTER NO-UNDO.
if sum-doc-0 = sum-doc-1
AND sum-rubl-0 = sum-rubl-1
and exch-rate-0 = exch-rate-1
and exch-scale-0 = exch-scale-1
AND sum-base-0 = sum-base-1
and base-rate-0 = base-rate-1
and base-scale-0 = base-scale-1
AND sum-contr-0 = sum-contr-1
and contract-rate-0 = contract-rate-1
and contract-scale-0 = contract-scale-1 then do:
  p-rate-correct = "":U.
  return .
end.
if (sum-doc-1 = 0
and not (sum-rubl-1 = 0 and sum-base-1 = 0 and sum-contr-1 = 0))
or sum-doc-1 < 0
or sum-doc-1 = ?
then do:
  p-rate-correct = "sum-doc":U.
  return.
end.
if sum-rubl-1 = ?
or sum-rubl-1 < 0
or ( sum-doc-1 <> 0  and sum-rubl-1 = 0)
then do:
   p-rate-correct = "sum-rubl":U.
   return.
end.
if sum-base-1 < 0
or ( sum-doc-1 <> 0  and sum-base-1 = 0)
or sum-base-1 = ?
then do:
   p-rate-correct = "sum-base":U.
   return.
end.
if sum-contr-1 < 0
or ( sum-doc-1 <> 0  and sum-contr-1 = 0)
or sum-contr-1 = ?
then do:
   p-rate-correct = "sum-contr":U.
   return.
end.
IF EXCH-RATE-1 = ? or exch-scale-1 = ?
or EXCH-RATE-1 = 0 or exch-scale-1 = 0
then do:
    p-rate-correct = "exch-rate":U.
    RETURN.
END.
IF v-exch-rate-c <> "":U AND v-exch-rate-c <> "0":U
AND abs((exch-rate-1 / exch-scale-1) - (sum-rubl-1 / sum-doc-1)) >  0.0001 THEN DO:
    p-rate-correct = "exch-rate":U.
    RETURN.
END.
IF v-sum-doc-c <> "":U AND v-sum-doc-c <> "0":U
AND abs(sum-doc-1 - (sum-rubl-1 / ( exch-rate-1 / exch-scale-1 ))) >  0.01 THEN DO:
    p-rate-correct = "sum-doc":U.
    RETURN.
END.
IF base-rate-1 = ? or  base-scale-1 = ?
or base-rate-1 = 0 or  base-scale-1 = 0
then do:
  p-rate-correct = "base-rate":U.
  RETURN.
end.
IF  v-baseratef
and v-base-rate-c <> "":U AND v-base-rate-c <> "0":U
AND abs((base-rate-1 / base-scale-1) - (sum-rubl-1 / sum-base-1)) > 0.0001 THEN DO:
    p-rate-correct = "base-rate":U.
    RETURN.
END.
IF v-basef
and v-sum-base-c <> "":U AND v-sum-base-c <> "0":U
AND abs(sum-base-1 - (sum-rubl-1 / ( base-rate-1 / base-scale-1 ))) >  0.0001 THEN DO:
  p-rate-correct = "sum-base":U.
  RETURN.
END.
IF contract-rate-1 = ? or  contract-scale-1 = ?
or contract-rate-1 = 0 or  contract-scale-1 = 0
then do:
    p-rate-correct = "contract-rate":U.
    RETURN.
end.
IF v-contractratef
and v-contract-rate-c <> "":U AND v-contract-rate-c <> "0":U
AND abs((contract-rate-1 / contract-scale-1) - (sum-rubl-1 / sum-contr-1)) > 0.0001 THEN DO:
    p-rate-correct = "contract-rate":U.
    RETURN.
END.
IF v-contractf
and v-sum-contr-c <> "":U AND v-sum-contr-c <> "0":U
AND abs(sum-contr-1 - (sum-rubl-1 / ( contract-rate-1 / contract-scale-1 ))) >  0.0001 THEN DO:
  p-rate-correct = "sum-contract":U.
  RETURN.
END.
if v-rubf then do:
CASE v-sum-rubl-c:
  when "sum-doc*exch-rate":U then do:
    if ABS(sum-rubl-1 - sum-doc-1 * (exch-rate-1 / exch-scale-1)) > 0.0001 then do:
      p-rate-correct = "sum-rubl":U.
      RETURN.
    end.
  end.
  when "sum-contr*contract-rate":U then do:
    if ABS(sum-rubl-1 - sum-contr-1 * (contract-rate-1 /  contract-scale-1)) > 0.0001 then do:
      p-rate-correct = "sum-rubl":U.
      RETURN.
    end.
  end.
  when "sum-base*base-rate":U then do:
    if ABS(sum-rubl-1 - sum-base-1 * (base-rate-1 /  base-scale-1)) > 0.0001 then do:
      p-rate-correct = "sum-rubl":U.
      RETURN.
    end.
  end.
  when "":U then do:
  end.
  when "!":U then do:
    p-rate-correct = "sum-rubl":U.
    RETURN.
  end.
END CASE.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME