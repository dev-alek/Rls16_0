&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE NEW SHARED BUFFER buf_turnover-buyer FOR ub.turnover-buyer.
DEFINE BUFFER buf_turnover-buyer-gds FOR ub.turnover-buyer-gds.
DEFINE BUFFER buf_turnover-buyer-main FOR ub.turnover-buyer-main.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обороты покупателя для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as handle no-undo .
define input  parameter p-bttns        as character no-undo .
define input  parameter p-cli-recid   as recid no-undo  .
define output parameter p-rec-list    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обороты покупателя для ценообразовани ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ gbl/userobjs.i }
{ ref/calctur2.i }

/* Local Variable Definitions ---                                       */
define buffer root_clients for ub.clients  .
define variable v-rec-list-cli as character no-undo .
define variable g-log as logical   no-undo .
define variable v-obj-list as character no-undo .


function mark-string returns character
  ( buffer loc-table for ub.turnover-buyer-main, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function mark-string-2 returns character
  ( buffer loc-table for ub.turnover-buyer-gds , input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function type-string-2 returns character
  ( buffer loc-table for ub.turnover-buyer-gds   ) :
&scop status-code string(loc-table.type)
return {&status-int-name} .
end function.
function type-string returns character
  ( buffer loc-table for ub.turnover-buyer   ) :
return entry (lookup (string(loc-table.type), '0,1':U), 'А,Р':U) .
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-0ob

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES buf_turnover-buyer-main
&Scoped-define FIRST-EXTERNAL-TABLE buf_turnover-buyer-main


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR buf_turnover-buyer-main.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_turnover-buyer-main buf_clients ~
buf_turnover-buyer buf_turnover-buyer-gds buf_goods

/* Definitions for BROWSE BROWSE-0ob                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-0ob mark-string ( buffer buf_turnover-buyer-main, p-rec-list ) buf_turnover-buyer-main.obj-type + " " + STRING (buf_turnover-buyer-main.obj-code) buf_clients.obj-name buf_turnover-buyer-main.sum-doc-base-itog buf_turnover-buyer-main.sum-doc-rubl-itog buf_turnover-buyer-main.sum-acc-base-itog buf_turnover-buyer-main.sum-acc-rubl-itog buf_turnover-buyer-main.qnty-doc-itog buf_turnover-buyer-main.qnty-check-itog
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-0ob
&Scoped-define SELF-NAME BROWSE-0ob
&Scoped-define QUERY-STRING-BROWSE-0ob FOR EACH buf_turnover-buyer-main WHERE     ( r-obj-choose = 2 OR       lookup((buf_turnover-buyer-main.obj-type + string(buf_turnover-buyer-main.obj-code)) , ~
       v-obj-list ) > 0 ) AND     buf_turnover-buyer-main.cli-type = root_clients.obj-type AND     buf_turnover-buyer-main.cli-code = root_clients.obj-code NO-LOCK , ~
           EACH buf_clients WHERE buf_clients.obj-code = buf_turnover-buyer-main.obj-code                        AND buf_clients.obj-type = buf_turnover-buyer-main.obj-type                                                             NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-0ob OPEN QUERY {&SELF-NAME} FOR EACH buf_turnover-buyer-main WHERE     ( r-obj-choose = 2 OR       lookup((buf_turnover-buyer-main.obj-type + string(buf_turnover-buyer-main.obj-code)) , ~
       v-obj-list ) > 0 ) AND     buf_turnover-buyer-main.cli-type = root_clients.obj-type AND     buf_turnover-buyer-main.cli-code = root_clients.obj-code NO-LOCK , ~
           EACH buf_clients WHERE buf_clients.obj-code = buf_turnover-buyer-main.obj-code                        AND buf_clients.obj-type = buf_turnover-buyer-main.obj-type                                                             NO-LOCK .
&Scoped-define TABLES-IN-QUERY-BROWSE-0ob buf_turnover-buyer-main ~
buf_clients
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-0ob buf_turnover-buyer-main
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-0ob buf_clients


/* Definitions for BROWSE BROWSE-1ob                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1ob type-string ( buffer buf_turnover-buyer ) buf_turnover-buyer.fact-date buf_turnover-buyer.ext-doc-type buf_turnover-buyer.sum-doc-base buf_turnover-buyer.sum-doc-rubl buf_turnover-buyer.sum-acc-base buf_turnover-buyer.sum-acc-rubl buf_turnover-buyer.qnty-doc buf_turnover-buyer.qnty-check buf_turnover-buyer.doc-code buf_turnover-buyer.d-card buf_turnover-buyer.inkas-code buf_turnover-buyer.sum-doc-base-itog buf_turnover-buyer.sum-doc-rubl-itog buf_turnover-buyer.sum-acc-base-itog buf_turnover-buyer.sum-acc-rubl-itog buf_turnover-buyer.qnty-doc-itog buf_turnover-buyer.qnty-check-itog buf_turnover-buyer.sys-date buf_turnover-buyer.sys-time-char buf_turnover-buyer.shift-date buf_turnover-buyer.shift-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1ob
&Scoped-define SELF-NAME BROWSE-1ob
&Scoped-define QUERY-STRING-BROWSE-1ob FOR EACH buf_turnover-buyer NO-LOCK WHERE     ( r-type-add = 2 OR buf_turnover-buyer.type =  r-type-add ) AND buf_turnover-buyer.obj-type = buf_turnover-buyer-main.obj-type AND buf_turnover-buyer.obj-code = buf_turnover-buyer-main.obj-code AND buf_turnover-buyer.cli-type = buf_turnover-buyer-main.cli-type    AND buf_turnover-buyer.cli-code = buf_turnover-buyer-main.cli-code  USE-INDEX clients
&Scoped-define OPEN-QUERY-BROWSE-1ob OPEN QUERY {&SELF-NAME} FOR EACH buf_turnover-buyer NO-LOCK WHERE     ( r-type-add = 2 OR buf_turnover-buyer.type =  r-type-add ) AND buf_turnover-buyer.obj-type = buf_turnover-buyer-main.obj-type AND buf_turnover-buyer.obj-code = buf_turnover-buyer-main.obj-code AND buf_turnover-buyer.cli-type = buf_turnover-buyer-main.cli-type    AND buf_turnover-buyer.cli-code = buf_turnover-buyer-main.cli-code  USE-INDEX clients  .
&Scoped-define TABLES-IN-QUERY-BROWSE-1ob buf_turnover-buyer
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1ob buf_turnover-buyer


/* Definitions for BROWSE BROWSE-2ob-gds                                */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2ob-gds buf_turnover-buyer-gds.gds-code buf_goods.gds-name buf_turnover-buyer-gds.sum-doc-base buf_turnover-buyer-gds.sum-doc-rubl buf_turnover-buyer-gds.sum-acc-base buf_turnover-buyer-gds.sum-acc-rubl buf_turnover-buyer-gds.fact-date buf_turnover-buyer-gds.doc-code buf_turnover-buyer-gds.inkas-code buf_turnover-buyer-gds.d-card buf_turnover-buyer-gds.sys-date buf_turnover-buyer-gds.sys-time-char buf_turnover-buyer-gds.shift-date buf_turnover-buyer-gds.shift-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2ob-gds
&Scoped-define SELF-NAME BROWSE-2ob-gds
&Scoped-define QUERY-STRING-BROWSE-2ob-gds FOR EACH buf_turnover-buyer-gds      WHERE ( r-type-add = 2 OR buf_turnover-buyer-gds.type =  r-type-add ) AND     buf_turnover-buyer-gds.obj-type = buf_turnover-buyer-main.obj-type AND     buf_turnover-buyer-gds.obj-code = buf_turnover-buyer-main.obj-code AND     buf_turnover-buyer-gds.cli-type = buf_turnover-buyer-main.cli-type AND     buf_turnover-buyer-gds.cli-code = buf_turnover-buyer-main.cli-code     NO-LOCK     , ~
           FIRST buf_goods NO-LOCK WHERE buf_goods.gds-code = buf_turnover-buyer-gds.gds-code
&Scoped-define OPEN-QUERY-BROWSE-2ob-gds OPEN QUERY {&SELF-NAME} FOR EACH buf_turnover-buyer-gds      WHERE ( r-type-add = 2 OR buf_turnover-buyer-gds.type =  r-type-add ) AND     buf_turnover-buyer-gds.obj-type = buf_turnover-buyer-main.obj-type AND     buf_turnover-buyer-gds.obj-code = buf_turnover-buyer-main.obj-code AND     buf_turnover-buyer-gds.cli-type = buf_turnover-buyer-main.cli-type AND     buf_turnover-buyer-gds.cli-code = buf_turnover-buyer-main.cli-code     NO-LOCK     , ~
           FIRST buf_goods NO-LOCK WHERE buf_goods.gds-code = buf_turnover-buyer-gds.gds-code                 .
&Scoped-define TABLES-IN-QUERY-BROWSE-2ob-gds buf_turnover-buyer-gds ~
buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2ob-gds buf_turnover-buyer-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-2ob-gds buf_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-0ob}~
    ~{&OPEN-QUERY-BROWSE-1ob}~
    ~{&OPEN-QUERY-BROWSE-2ob-gds}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-mark B-sel B-add B-chg B-lkp ~
B-del B-doc B-Chk B-print B-Help r-obj-choose BROWSE-0ob r-type-add ~
BROWSE-1ob BROWSE-2ob-gds ITOGO-sum-doc-base ITOGO-sum-doc-rubl ~
ITOGO-sum-rash-base ITOGO-sum-rash ITOGO-sum-vozv-base ITOGO-sum-vozv ~
ITOGO-qnty-doc itogo-qnty-check FILL-IN-2 FILL-IN-1
&Scoped-Define DISPLAYED-OBJECTS r-obj-choose r-type-add ITOGO-sum-doc-base ~
ITOGO-sum-doc-rubl ITOGO-sum-rash-base ITOGO-sum-rash ITOGO-sum-vozv-base ~
ITOGO-sum-vozv ITOGO-qnty-doc itogo-qnty-check FILL-IN-2 FILL-IN-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Ручное добавление оборотов"
     BGCOLOR 8 .

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменение ~"ручных~" оборотов"
     BGCOLOR 8 .

DEFINE BUTTON B-Chk
     LABEL "Чек"
     SIZE 10 BY 1 TOOLTIP "Просмотр чека"
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удаление ~"ручных~" оборотов"
     BGCOLOR 8 .

DEFINE BUTTON B-doc
     LABEL "Документ"
     SIZE 10 BY 1 TOOLTIP "Просмотр документа"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "Просмотр"
     SIZE 9.5 BY 1 TOOLTIP "Просмотр ~"ручных~" оборотов"
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить оборот по объекту"
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 8 BY 1 TOOLTIP "Печать справочника"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип:"
      VIEW-AS TEXT
     SIZE 4.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Объекты:"
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE itogo-qnty-check AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Всего чеков"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE ITOGO-qnty-doc AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Всего документов"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE ITOGO-sum-doc-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Итого в ценах реализации(б.в.)"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE ITOGO-sum-doc-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Итого в ценах реализации(rub)"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE ITOGO-sum-rash AS DECIMAL FORMAT "->,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Расходный оборот"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE ITOGO-sum-rash-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Расходный оборот"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE ITOGO-sum-vozv AS DECIMAL FORMAT "->,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Возвратный оборот"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE ITOGO-sum-vozv-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Возвратный оборот"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE r-obj-choose AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"выборочно", 1
     SIZE 19.25 BY .67 TOOLTIP "Условие отбора записей" NO-UNDO.

DEFINE VARIABLE r-type-add AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Автоматические", 0,
"Ручные", 1
     SIZE 32.25 BY .67 TOOLTIP "Условие отбора записей" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-0ob FOR
      buf_turnover-buyer-main,
      buf_clients SCROLLING.

DEFINE QUERY BROWSE-1ob FOR
      buf_turnover-buyer SCROLLING.

DEFINE QUERY BROWSE-2ob-gds FOR
      buf_turnover-buyer-gds,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-0ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-0ob Dialog-Frame _FREEFORM
  QUERY BROWSE-0ob NO-LOCK DISPLAY
      mark-string ( buffer buf_turnover-buyer-main, p-rec-list ) COLUMN-LABEL "*" FORMAT "x(1)":U
      buf_turnover-buyer-main.obj-type + " " + STRING (buf_turnover-buyer-main.obj-code)  COLUMN-LABEL "Объект" FORMAT "x(10)"
      buf_clients.obj-name COLUMN-LABEL "Наименование"  FORMAT  "x(20)"
buf_turnover-buyer-main.sum-doc-base-itog  COLUMN-LABEL "В продаж.ценах(баз.в.)" FORMAT "->>>,>>>,>>>,>>9.99"
buf_turnover-buyer-main.sum-doc-rubl-itog   COLUMN-LABEL "В продаж.ценах ({&abbr_rub_allshift})" FORMAT "->>>,>>>,>>>,>>9.99"
buf_turnover-buyer-main.sum-acc-base-itog   COLUMN-LABEL "В учетных ценах(баз.в.)"  FORMAT "->>>,>>>,>>>,>>9.99"
buf_turnover-buyer-main.sum-acc-rubl-itog   COLUMN-LABEL "В учетных ценах({&abbr_rub_allshift})" FORMAT "->>>,>>>,>>>,>>9.99"
    buf_turnover-buyer-main.qnty-doc-itog  COLUMN-LABEL  "Кол-во документов"
    buf_turnover-buyer-main.qnty-check-itog  COLUMN-LABEL "Кол-во чеков"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.38 ROW-HEIGHT-CHARS .67 EXPANDABLE.

DEFINE BROWSE BROWSE-1ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1ob Dialog-Frame _FREEFORM
  QUERY BROWSE-1ob NO-LOCK DISPLAY
      type-string ( buffer buf_turnover-buyer ) COLUMN-LABEL "Т" FORMAT "x(1)":U
      buf_turnover-buyer.fact-date  COLUMN-LABEL "Дата" FORMAT "99/99/99":U
      buf_turnover-buyer.ext-doc-type  COLUMN-LABEL "TД" FORMAT "x(2)":U
      buf_turnover-buyer.sum-doc-base  COLUMN-LABEL "В прод.ценах(баз.в.)"  FORMAT "->>>,>>>,>>>,>>9.99"
      buf_turnover-buyer.sum-doc-rubl  COLUMN-LABEL "В прод.ценах({&abbr_rub_allshift})"  FORMAT "->>>,>>>,>>>,>>9.99"
      buf_turnover-buyer.sum-acc-base  COLUMN-LABEL "В учетных ценах(баз.в.)"  FORMAT "->>>,>>>,>>>,>>9.99"
      buf_turnover-buyer.sum-acc-rubl  COLUMN-LABEL "В учетных ценах({&abbr_rub_allshift})"  FORMAT "->>>,>>>,>>>,>>9.99"
          buf_turnover-buyer.qnty-doc    COLUMN-LABEL  "Кол-во документов"
          buf_turnover-buyer.qnty-check  COLUMN-LABEL "Кол-во чеков"
          buf_turnover-buyer.doc-code   COLUMN-LABEL "№ документа" FORMAT "x(16)":U
          buf_turnover-buyer.d-card     COLUMN-LABEL "№ ДК"   FORMAT "x(10)":U
          buf_turnover-buyer.inkas-code COLUMN-LABEL "№ чека" FORMAT "x(16)":U

buf_turnover-buyer.sum-doc-base-itog   COLUMN-LABEL "В прод.ценах(баз.в.)!нараст.итог"  FORMAT "->>>,>>>,>>>,>>9.99"
buf_turnover-buyer.sum-doc-rubl-itog   COLUMN-LABEL "В прод.ценах({&abbr_rub_allshift})!нараст.итог" FORMAT "->>>,>>>,>>>,>>9.99"
buf_turnover-buyer.sum-acc-base-itog   COLUMN-LABEL "В учетных ценах(баз.в.)!нараст.итог"  FORMAT "->>>,>>>,>>>,>>9.99"
buf_turnover-buyer.sum-acc-rubl-itog   COLUMN-LABEL "В учетных ценах({&abbr_rub_allshift})!нараст.итог"  FORMAT "->>>,>>>,>>>,>>9.99"
          buf_turnover-buyer.qnty-doc-itog    COLUMN-LABEL  "Кол-во докум!нараст.итог"
          buf_turnover-buyer.qnty-check-itog  COLUMN-LABEL "Кол-во чеков!нараст.итог"

          buf_turnover-buyer.sys-date   COLUMN-LABEL "Дата созд" FORMAT "99/99/99":U
          buf_turnover-buyer.sys-time-char COLUMN-LABEL "Время" FORMAT "X(5)":U
          buf_turnover-buyer.shift-date  COLUMN-LABEL "Смена" FORMAT "99/99/99":U
          buf_turnover-buyer.shift-name COLUMN-LABEL "№" FORMAT "X(2)"
          buf_turnover-buyer.shift-num  COLUMN-LABEL "П" FORMAT ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 48.13 BY 11.04
         TITLE "Обороты по покупателю по объекту" EXPANDABLE.

DEFINE BROWSE BROWSE-2ob-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2ob-gds Dialog-Frame _FREEFORM
  QUERY BROWSE-2ob-gds NO-LOCK DISPLAY
      buf_turnover-buyer-gds.gds-code   COLUMN-LABEL "Код товара" FORMAT "999999999":U
      buf_goods.gds-name COLUMN-LABEL "Наименование товара" FORMAT "x(20)":U
      buf_turnover-buyer-gds.sum-doc-base  COLUMN-LABEL "В прод.ценах(баз.в.)" FORMAT "->>>,>>>,>>9.99"
      buf_turnover-buyer-gds.sum-doc-rubl  COLUMN-LABEL "В прод.ценах({&abbr_rub_allshift})" FORMAT "->>>,>>>,>>9.99"
      buf_turnover-buyer-gds.sum-acc-base  COLUMN-LABEL "В учетных ценах(баз.в.)" FORMAT "->>>,>>>,>>9.99"
      buf_turnover-buyer-gds.sum-acc-rubl  COLUMN-LABEL "В учетных ценах({&abbr_rub_allshift})" FORMAT "->>>,>>>,>>9.99"
          buf_turnover-buyer-gds.fact-date  COLUMN-LABEL "Дата" FORMAT "99/99/99":U
          buf_turnover-buyer-gds.doc-code   COLUMN-LABEL "№ документа" FORMAT "x(16)":U
          buf_turnover-buyer-gds.inkas-code COLUMN-LABEL "№ чека" FORMAT "x(16)":U
          buf_turnover-buyer-gds.d-card     COLUMN-LABEL "№ ДК"   FORMAT "x(6)":U

      buf_turnover-buyer-gds.sys-date   COLUMN-LABEL "Дата созд" FORMAT "99/99/99":U
      buf_turnover-buyer-gds.sys-time-char COLUMN-LABEL "Время" FORMAT "X(5)":U
      buf_turnover-buyer-gds.shift-date  COLUMN-LABEL "Смена" FORMAT "99/99/99":U
      buf_turnover-buyer-gds.shift-name  COLUMN-LABEL "№" FORMAT "X(2)"
      buf_turnover-buyer-gds.shift-num  COLUMN-LABEL "П" FORMAT ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.5 BY 11.04
         TITLE "Обороты в разрезе товаров" EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 10.88
     B-sel AT ROW 1 COL 14.25
     B-add AT ROW 1 COL 22.38
     B-chg AT ROW 1 COL 32.5
     B-lkp AT ROW 1 COL 42.5
     B-del AT ROW 1 COL 51.88
     B-doc AT ROW 1 COL 62
     B-Chk AT ROW 1 COL 72.13
     B-print AT ROW 1 COL 82.13
     B-Help AT ROW 1 COL 90.25
     r-obj-choose AT ROW 4.17 COL 10.88 NO-LABEL
     BROWSE-0ob AT ROW 4.88 COL 1.5
     r-type-add AT ROW 11.25 COL 6.75 NO-LABEL
     BROWSE-1ob AT ROW 12 COL 1.38
     BROWSE-2ob-gds AT ROW 12 COL 49.5
     ITOGO-sum-doc-base AT ROW 2 COL 81 COLON-ALIGNED
     ITOGO-sum-doc-rubl AT ROW 2.04 COL 31 COLON-ALIGNED
     ITOGO-sum-rash-base AT ROW 2.63 COL 81 COLON-ALIGNED
     ITOGO-sum-rash AT ROW 2.79 COL 31 COLON-ALIGNED
     ITOGO-sum-vozv-base AT ROW 3.38 COL 81 COLON-ALIGNED
     ITOGO-sum-vozv AT ROW 3.54 COL 31 COLON-ALIGNED
     ITOGO-qnty-doc AT ROW 4.08 COL 61.5 COLON-ALIGNED
     itogo-qnty-check AT ROW 4.08 COL 87 COLON-ALIGNED
     FILL-IN-2 AT ROW 4.17 COL 2.13 NO-LABEL
     FILL-IN-1 AT ROW 11.25 COL 1.5 NO-LABEL
     SPACE(94.38) SKIP(11.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Обороты по покупателю"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   External Tables: Temp-Tables.buf_turnover-buyer-main
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_goods B "?" ? ub goods
      TABLE: buf_turnover-buyer B "NEW SHARED" ? ub turnover-buyer
      TABLE: buf_turnover-buyer-gds B "?" ? ub turnover-buyer-gds
      TABLE: buf_turnover-buyer-main B "?" ? ub turnover-buyer-main
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-0ob r-obj-choose Dialog-Frame */
/* BROWSE-TAB BROWSE-1ob r-type-add Dialog-Frame */
/* BROWSE-TAB BROWSE-2ob-gds BROWSE-1ob Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-0ob
/* Query rebuild information for BROWSE BROWSE-0ob
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_turnover-buyer-main WHERE
    ( r-obj-choose = 2 OR
      lookup((buf_turnover-buyer-main.obj-type + string(buf_turnover-buyer-main.obj-code)) , v-obj-list ) > 0 ) AND
    buf_turnover-buyer-main.cli-type = root_clients.obj-type AND
    buf_turnover-buyer-main.cli-code = root_clients.obj-code NO-LOCK ,
    EACH buf_clients WHERE buf_clients.obj-code = buf_turnover-buyer-main.obj-code
                       AND buf_clients.obj-type = buf_turnover-buyer-main.obj-type
                                                            NO-LOCK .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-0ob */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1ob
/* Query rebuild information for BROWSE BROWSE-1ob
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_turnover-buyer NO-LOCK WHERE
    ( r-type-add = 2 OR buf_turnover-buyer.type =  r-type-add ) AND
buf_turnover-buyer.obj-type = buf_turnover-buyer-main.obj-type AND
buf_turnover-buyer.obj-code = buf_turnover-buyer-main.obj-code AND
buf_turnover-buyer.cli-type = buf_turnover-buyer-main.cli-type    AND
buf_turnover-buyer.cli-code = buf_turnover-buyer-main.cli-code  USE-INDEX clients  .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1ob */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2ob-gds
/* Query rebuild information for BROWSE BROWSE-2ob-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_turnover-buyer-gds
     WHERE ( r-type-add = 2 OR buf_turnover-buyer-gds.type =  r-type-add ) AND
    buf_turnover-buyer-gds.obj-type = buf_turnover-buyer-main.obj-type AND
    buf_turnover-buyer-gds.obj-code = buf_turnover-buyer-main.obj-code AND
    buf_turnover-buyer-gds.cli-type = buf_turnover-buyer-main.cli-type AND
    buf_turnover-buyer-gds.cli-code = buf_turnover-buyer-main.cli-code
    NO-LOCK     ,
    FIRST buf_goods NO-LOCK WHERE buf_goods.gds-code = buf_turnover-buyer-gds.gds-code
                .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _Query            is OPENED
*/  /* BROWSE BROWSE-2ob-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Обороты по покупателю */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable v-rec-id as recid no-undo init ?.
define variable v-recid-main as recid no-undo .

find current buf_turnover-buyer-main no-error .
if available buf_turnover-buyer-main then do:
   v-recid-main = recid (buf_turnover-buyer-main) .
end.

  run ref/tov-bri.w ( Parparentproc, {&add-def} , root_clients.obj-type ,  root_clients.obj-code ,  input-output v-rec-id ) .
  define buffer bbuf_turnover-buyer for ub.turnover-buyer  .
  find first bbuf_turnover-buyer no-lock where recid(bbuf_turnover-buyer) =  v-rec-id no-error .
  if available  bbuf_turnover-buyer then do:

     run ref/calctur1.p ( bbuf_turnover-buyer.cli-type , bbuf_turnover-buyer.cli-code ,
                      bbuf_turnover-buyer.obj-type , bbuf_turnover-buyer.obj-code ,
                      bbuf_turnover-buyer.fact-order  ) .
  end.
  run refresh-itogo.
  {&OPEN-QUERY-BROWSE-0ob}
  reposition BROWSE-0ob to recid v-recid-main no-error .
  {&OPEN-QUERY-BROWSE-1ob}
  reposition BROWSE-1ob to recid v-rec-id no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:

define variable v-rec-id as recid no-undo init ?.
define variable v-recid-main as recid no-undo .
if not available buf_turnover-buyer then return.
  if buf_turnover-buyer.type = 0 then do:
     message "Автоматически созданные обороты изменять нельзя! " view-as alert-box information .
     return .
  end.

v-rec-id = recid(buf_turnover-buyer) .

find current buf_turnover-buyer-main no-error .
if available buf_turnover-buyer-main then do:
   v-recid-main = recid (buf_turnover-buyer-main) .
end.

  run ref/tov-bri.w ( Parparentproc, {&update} , root_clients.obj-type ,  root_clients.obj-code ,  input-output v-rec-id ) .
  define buffer bbuf_turnover-buyer for ub.turnover-buyer  .
  find first bbuf_turnover-buyer no-lock where recid(bbuf_turnover-buyer) =  v-rec-id no-error .
  if available  bbuf_turnover-buyer then do:

     run ref/calctur1.p ( bbuf_turnover-buyer.cli-type , bbuf_turnover-buyer.cli-code ,
                      bbuf_turnover-buyer.obj-type , bbuf_turnover-buyer.obj-code ,
                      bbuf_turnover-buyer.fact-order  ) .
  end.

  run refresh-itogo.
  {&OPEN-QUERY-BROWSE-0ob}
  reposition BROWSE-0ob to recid v-recid-main no-error .
  {&OPEN-QUERY-BROWSE-1ob}
  reposition BROWSE-1ob to recid v-rec-id no-error .



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Chk Dialog-Frame
ON CHOOSE OF B-Chk IN FRAME Dialog-Frame /* Чек */
DO:
if not available buf_turnover-buyer then return .

define variable p-br-handle as handle no-undo .
define variable p-next-prev as logical no-undo .
define variable p-doc-rec as recid no-undo .
define buffer buf1_chk-doc for ub.chk-doc  .
find first buf1_chk-doc no-lock where buf1_chk-doc.doc-code = buf_turnover-buyer.inkas-code no-error .
if not available buf1_chk-doc then return .

 run str/showchk.p (
                 input parparentproc
                ,input buf_turnover-buyer.inkas-code
                ,input false
                ,input ?
              ) no-error .


    /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  if not available buf_turnover-buyer then return .
  define variable v-recid-main as recid no-undo .
  find current buf_turnover-buyer-main no-error .
  v-recid-main = recid (buf_turnover-buyer-main) .

  if buf_turnover-buyer.type = 0 then do:
     message "Автоматически созданные обороты удалять нельзя! " view-as alert-box information .
     return .
  end.

  message "Удалять оборот " buf_turnover-buyer.obj-code  buf_turnover-buyer.obj-type " от " buf_turnover-buyer.fact-date "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
 define variable v-fact-order as decimal   no-undo .
 define variable v-cli-type as character no-undo .
 define variable v-cli-code as integer   no-undo .
 define variable v-obj-type as character no-undo .
 define variable v-obj-code as integer   no-undo .

 v-fact-order = buf_turnover-buyer.fact-order .
 v-cli-type   = buf_turnover-buyer.cli-type .
 v-cli-code   = buf_turnover-buyer.cli-code .
 v-obj-type   = buf_turnover-buyer.obj-type .
 v-obj-code   = buf_turnover-buyer.obj-code .
find current buf_turnover-buyer exclusive-lock no-error .
 delete buf_turnover-buyer.
 if error-status :error then return no-apply .

  run ref/calctur1.p ( v-cli-type , v-cli-code ,
                  v-obj-type , v-obj-code ,
                  v-fact-order  ) .
  run refresh-itogo.
 {&OPEN-QUERY-BROWSE-0ob}
 reposition BROWSE-0ob to recid v-recid-main no-error .
 {&OPEN-QUERY-BROWSE-1ob}
 {&OPEN-QUERY-BROWSE-2ob-gds}


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-doc Dialog-Frame
ON CHOOSE OF B-doc IN FRAME Dialog-Frame /* Документ */
DO:
  if not available buf_turnover-buyer then return .
  define variable v-rec-id as recid no-undo .
  v-rec-id = recid(buf_turnover-buyer) .
  run str/showdoc.p (
  input parparentproc  ,
  input buf_turnover-buyer.doc-code   ,
  input ?,
  input ?,
  input ?,
  input true ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable v-rec-id as recid no-undo .
if not available buf_turnover-buyer then return.
v-rec-id = recid(buf_turnover-buyer) .
run ref/tov-bri.w (Parparentproc, {&lookup} , root_clients.obj-type ,  root_clients.obj-code , input-output v-rec-id )  .
reposition BROWSE-1ob to recid v-rec-id no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
    if available buf_turnover-buyer-main then do:
      { gbl/markstrn.i buf_turnover-buyer-main p-rec-list }
        g-log = browse-0ob:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-0ob:select-next-row ().
          apply "VALUE-CHANGED" to browse-0ob in frame {&frame-name}.
      end.
    end.

    apply "display" to browse-0ob in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  /* */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  /**/
    if ( available buf_turnover-buyer ) AND ( p-rec-list = "" ) then
    p-rec-list = string( recid( buf_turnover-buyer ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-0ob
&Scoped-define SELF-NAME BROWSE-0ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-0ob Dialog-Frame
ON VALUE-CHANGED OF BROWSE-0ob IN FRAME Dialog-Frame
DO:
  {&OPEN-QUERY-BROWSE-1ob}
  {&OPEN-QUERY-BROWSE-2ob-gds}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1ob
&Scoped-define SELF-NAME BROWSE-1ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1ob Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1ob IN FRAME Dialog-Frame /* Обороты по покупателю по объекту */
DO:
  {&OPEN-QUERY-BROWSE-2ob-gds}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj-choose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj-choose Dialog-Frame
ON VALUE-CHANGED OF r-obj-choose IN FRAME Dialog-Frame
DO:
  define buffer bf_clients for ub.clients  .

  assign r-obj-choose .
  if r-obj-choose = 1
  then do:
    { gbl/uobjclr.i  }
    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true
    then do:
      message
        "Объект не выбран"
        view-as alert-box information .
      return .
    end.

    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      assign
        v-obj-list = v-obj-list  + buf_userobjs_temp-user-obj.obj-type
                  + string(buf_userobjs_temp-user-obj.obj-code) + ","
      .
    end.
  end.
  {&OPEN-QUERY-BROWSE-0ob}
  {&OPEN-QUERY-BROWSE-1ob}
  {&OPEN-QUERY-BROWSE-2ob-gds}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-type-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-type-add Dialog-Frame
ON VALUE-CHANGED OF r-type-add IN FRAME Dialog-Frame
DO:
    ASSIGN r-type-add .
  {&OPEN-QUERY-BROWSE-1ob}
  {&OPEN-QUERY-BROWSE-2ob-gds}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-0ob
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
  find first root_clients no-lock where  recid(root_clients) = p-cli-recid no-error .

RUN enable_UI.
run refresh-itogo.

IF NOT root_clients.turnover-buyer-gds THEN do:
    HIDE BROWSE-2ob-gds IN FRAME {&FRAME-NAME}.
    BROWSE-1ob:WIDTH IN FRAME {&FRAME-NAME} = 98 .
END.
  disable
    b-sel  when LOOKUP("b-sel":U,  p-bttns) = 0
    b-mark when LOOKUP("b-mark":U,  p-bttns) = 0
    b-add  when LOOKUP("b-add":U,  p-bttns) = 0
    b-del  when LOOKUP("b-del":U,  p-bttns) = 0
    b-chg  when LOOKUP("b-chg":U,  p-bttns) = 0
  with frame {&frame-name} .
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
  DISPLAY r-obj-choose r-type-add ITOGO-sum-doc-base ITOGO-sum-doc-rubl
          ITOGO-sum-rash-base ITOGO-sum-rash ITOGO-sum-vozv-base ITOGO-sum-vozv
          ITOGO-qnty-doc itogo-qnty-check FILL-IN-2 FILL-IN-1
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-add B-chg B-lkp B-del B-doc B-Chk B-print
         B-Help r-obj-choose BROWSE-0ob r-type-add BROWSE-1ob BROWSE-2ob-gds
         ITOGO-sum-doc-base ITOGO-sum-doc-rubl ITOGO-sum-rash-base
         ITOGO-sum-rash ITOGO-sum-vozv-base ITOGO-sum-vozv ITOGO-qnty-doc
         itogo-qnty-check FILL-IN-2 FILL-IN-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-itogo Dialog-Frame
PROCEDURE refresh-itogo :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

run pricing_calc-itogo-buyer (
         input  root_clients.obj-type
        ,input  root_clients.obj-code
        ,output itogo-sum-doc-rubl
        ,output itogo-sum-doc-base
        ,output itogo-sum-rash-base
        ,output itogo-sum-rash
        ,output itogo-sum-vozv-base
        ,output itogo-sum-vozv
        ,output itogo-qnty-doc
        ,output itogo-qnty-check    ).

ITOGO-sum-doc-rubl:label in frame {&frame-name}  = "Итого в ценах реализации({&abbr_rub_allshift})" .

display
  ITOGO-sum-doc-rubl
  ITOGO-sum-doc-base
  ITOGO-sum-rash-base
  ITOGO-sum-rash
  ITOGO-sum-vozv-base
  ITOGO-sum-vozv
  ITOGO-qnty-doc
  itogo-qnty-check
with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME